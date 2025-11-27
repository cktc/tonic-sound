# Code Signing for iOS and Android

Comprehensive guide for configuring code signing in Codemagic workflows.

## iOS Code Signing

### Prerequisites

Upload to Codemagic Team Settings > Code signing identities:

1. **Distribution Certificate** (.p12 file)
   - Password-protected PKCS#12 archive
   - Contains certificate + private key
   - Reference name: e.g., `DIST_CERT`

2. **Provisioning Profile** (.mobileprovision file)
   - Reference name: e.g., `DIST_PROFILE`

3. **App Store Connect API Key** (for automatic signing)
   - Key ID
   - Issuer ID
   - Private key (.p8 file)

### Method 1: Automatic Code Signing (Recommended)

Uses App Store Connect API to manage certificates and profiles automatically.

#### Environment Variables

Add to variable group `app_store_credentials`:

```yaml
APP_STORE_CONNECT_ISSUER_ID: xxx-xxx-xxx-xxx-xxx
APP_STORE_CONNECT_KEY_IDENTIFIER: ABCD1234EF
APP_STORE_CONNECT_PRIVATE_KEY: |
  -----BEGIN PRIVATE KEY-----
  MIGTAgEAMBMGByqGSM...
  -----END PRIVATE KEY-----
CERTIFICATE_PRIVATE_KEY: |
  -----BEGIN RSA PRIVATE KEY-----
  MIIEowIBAAKCAQEA...
  -----END RSA PRIVATE KEY-----
```

#### Workflow Configuration

```yaml
workflows:
  ios-automatic-signing:
    name: iOS Automatic Signing
    instance_type: mac_mini_m2
    environment:
      groups:
        - app_store_credentials
      vars:
        XCODE_WORKSPACE: "ios/Runner.xcworkspace"
        XCODE_SCHEME: "Runner"
        BUNDLE_ID: "com.example.app"
      xcode: latest
      cocoapods: default
    scripts:
      - name: Install dependencies
        script: |
          flutter pub get
          cd ios && pod install
      
      - name: Set up keychain
        script: |
          keychain initialize
      
      - name: Fetch signing files
        script: |
          app-store-connect fetch-signing-files "$BUNDLE_ID" \
            --type IOS_APP_STORE \
            --create
      
      - name: Add certificates to keychain
        script: |
          keychain add-certificates
      
      - name: Set up code signing settings
        script: |
          xcode-project use-profiles
      
      - name: Increment build number
        script: |
          cd ios
          agvtool new-version -all $(( \
            $(app-store-connect get-latest-testflight-build-number "$APP_STORE_APPLE_ID") + 1 \
          ))
      
      - name: Build .ipa
        script: |
          xcode-project build-ipa \
            --workspace "$XCODE_WORKSPACE" \
            --scheme "$XCODE_SCHEME"
    
    artifacts:
      - build/ios/ipa/*.ipa
      - $HOME/Library/Developer/Xcode/DerivedData/**/Build/**/*.dSYM
    
    publishing:
      app_store_connect:
        api_key: $APP_STORE_CONNECT_PRIVATE_KEY
        key_id: $APP_STORE_CONNECT_KEY_IDENTIFIER
        issuer_id: $APP_STORE_CONNECT_ISSUER_ID
        submit_to_testflight: true
```

### Method 2: Manual Code Signing

Uses manually uploaded certificates and provisioning profiles.

#### Environment Variables

Add to variable group `manual_cert_credentials`:

```yaml
CM_CERTIFICATE: <base64-encoded .p12 file>
CM_CERTIFICATE_PASSWORD: password123
CM_PROVISIONING_PROFILE: <base64-encoded .mobileprovision file>
```

#### Workflow Configuration

```yaml
workflows:
  ios-manual-signing:
    name: iOS Manual Signing
    instance_type: mac_mini_m2
    environment:
      groups:
        - manual_cert_credentials
      vars:
        XCODE_WORKSPACE: "ios/Runner.xcworkspace"
        XCODE_SCHEME: "Runner"
      xcode: latest
      cocoapods: default
    scripts:
      - name: Install dependencies
        script: |
          flutter pub get
          cd ios && pod install
      
      - name: Set up keychain
        script: |
          keychain initialize
      
      - name: Set up provisioning profiles
        script: |
          PROFILES_HOME="$HOME/Library/MobileDevice/Provisioning Profiles"
          mkdir -p "$PROFILES_HOME"
          PROFILE_PATH="$PROFILES_HOME/$(uuidgen).mobileprovision"
          echo ${CM_PROVISIONING_PROFILE} | base64 --decode > "$PROFILE_PATH"
          echo "Saved provisioning profile: $PROFILE_PATH"
      
      - name: Set up signing certificate
        script: |
          echo $CM_CERTIFICATE | base64 --decode > /tmp/certificate.p12
          keychain add-certificates \
            --certificate /tmp/certificate.p12 \
            --certificate-password $CM_CERTIFICATE_PASSWORD
      
      - name: Build .ipa
        script: |
          xcode-project build-ipa \
            --workspace "$XCODE_WORKSPACE" \
            --scheme "$XCODE_SCHEME"
    
    artifacts:
      - build/ios/ipa/*.ipa
```

### Flutter-Specific iOS Signing

For Flutter projects, simplified approach:

```yaml
scripts:
  - name: Set up code signing
    script: |
      keychain initialize
      app-store-connect fetch-signing-files "$BUNDLE_ID" \
        --type IOS_APP_STORE \
        --create
      keychain add-certificates
      xcode-project use-profiles
  
  - name: Build iOS
    script: |
      flutter build ipa --release \
        --export-options-plist=$HOME/export_options.plist
```

## Android Code Signing

### Prerequisites

1. **Keystore file** (.jks or .keystore)
2. **Keystore password**
3. **Key alias**
4. **Key password**

### Upload Keystore

**Option 1:** Upload to Codemagic UI (recommended)
- Team Settings > Code signing identities > Android keystores
- Upload .jks file with reference name

**Option 2:** Base64 encode in environment variable

```bash
base64 -i keystore.jks | pbcopy
```

### Environment Variables

Add to variable group `keystore_credentials`:

```yaml
CM_KEYSTORE: <base64-encoded keystore>  # If using Option 2
CM_KEYSTORE_PASSWORD: myKeystorePassword
CM_KEY_ALIAS: my-key-alias
CM_KEY_PASSWORD: myKeyPassword
```

### Gradle Configuration

Modify `android/app/build.gradle`:

```groovy
android {
    ...
    signingConfigs {
        release {
            if (System.getenv()["CI"]) { // CI=true on Codemagic
                storeFile file(System.getenv()["CM_KEYSTORE_PATH"])
                storePassword System.getenv()["CM_KEYSTORE_PASSWORD"]
                keyAlias System.getenv()["CM_KEY_ALIAS"]
                keyPassword System.getenv()["CM_KEY_PASSWORD"]
            } else {
                // Local development signing
                storeFile file("path/to/local/keystore.jks")
                storePassword "localPassword"
                keyAlias "localAlias"
                keyPassword "localPassword"
            }
        }
    }
    
    buildTypes {
        release {
            signingConfig signingConfigs.release
            minifyEnabled true
            proguardFiles getDefaultProguardFile('proguard-android.txt'), 'proguard-rules.pro'
        }
    }
}
```

### Workflow Configuration

```yaml
workflows:
  android-signing:
    name: Android Signing
    instance_type: linux
    max_build_duration: 60
    environment:
      groups:
        - keystore_credentials
      vars:
        PACKAGE_NAME: "com.example.app"
      java: 11
    scripts:
      - name: Set up keystore
        script: |
          echo $CM_KEYSTORE | base64 --decode > $CM_KEYSTORE_PATH
      
      - name: Set up local.properties
        script: |
          echo "flutter.sdk=$HOME/programs/flutter" > "$CM_BUILD_DIR/android/local.properties"
      
      - name: Get Flutter dependencies
        script: |
          flutter pub get
      
      - name: Build Android
        script: |
          flutter build apk --release
          # Or for app bundle:
          # flutter build appbundle --release
    
    artifacts:
      - build/app/outputs/flutter-apk/*.apk
      - build/app/outputs/bundle/**/*.aab
    
    publishing:
      google_play:
        credentials: $GCLOUD_SERVICE_ACCOUNT_CREDENTIALS
        track: internal
```

### Native Android Signing

For native Android projects:

```yaml
scripts:
  - name: Set up keystore
    script: |
      echo $CM_KEYSTORE | base64 --decode > $CM_KEYSTORE_PATH
  
  - name: Build signed APK
    script: |
      ./gradlew assembleRelease
  
  # Or for app bundle:
  - name: Build signed AAB
    script: |
      ./gradlew bundleRelease
```

## Best Practices

### Security

1. **Never commit credentials** to version control
2. **Use environment variable groups** to organize credentials
3. **Mark sensitive variables as "Secure"** in Codemagic UI
4. **Rotate credentials** regularly
5. **Use separate keystores** for different build variants

### iOS Signing

1. **Prefer automatic signing** when possible - less maintenance
2. **Keep provisioning profiles updated** - they expire
3. **Use App Store Connect API** for better automation
4. **Test signing locally** before CI to catch issues early
5. **Monitor certificate expiration dates**

### Android Signing

1. **Back up your keystore** - losing it means you can't update your app
2. **Use release signing** for production builds only
3. **Configure ProGuard/R8** for release builds
4. **Test signed builds** on real devices
5. **Keep keystore passwords secure** - use environment variables

## Troubleshooting

### iOS Issues

**"No signing certificate found"**
- Verify certificate uploaded to Codemagic
- Check certificate hasn't expired
- Ensure correct reference name in workflow

**"Provisioning profile doesn't match"**
- Verify bundle ID matches
- Check provisioning profile includes all devices
- Ensure profile hasn't expired

**"Code signing entitlements error"**
- Check entitlements in Xcode project
- Verify capabilities match provisioning profile
- Review App ID capabilities in App Store Connect

### Android Issues

**"Keystore not found"**
- Verify `CM_KEYSTORE_PATH` environment variable
- Check base64 decoding succeeded
- Ensure keystore uploaded to Codemagic

**"Incorrect keystore password"**
- Verify `CM_KEYSTORE_PASSWORD` matches actual password
- Check for trailing spaces or special characters
- Test password locally first

**"Key alias not found"**
- Verify `CM_KEY_ALIAS` matches keystore
- List aliases with: `keytool -list -v -keystore keystore.jks`
- Ensure case sensitivity is correct

## Examples

### Multi-flavor Android App

```yaml
workflows:
  android-dev:
    name: Android Development
    environment:
      groups:
        - dev_keystore
    scripts:
      - flutter build apk --release --flavor dev

  android-prod:
    name: Android Production
    environment:
      groups:
        - prod_keystore
    scripts:
      - flutter build apk --release --flavor prod
```

### iOS with Different Provisioning Profiles

```yaml
workflows:
  ios-development:
    name: iOS Development
    environment:
      groups:
        - dev_signing
    scripts:
      - app-store-connect fetch-signing-files "$BUNDLE_ID" --type IOS_APP_DEVELOPMENT

  ios-appstore:
    name: iOS App Store
    environment:
      groups:
        - prod_signing
    scripts:
      - app-store-connect fetch-signing-files "$BUNDLE_ID" --type IOS_APP_STORE
```
