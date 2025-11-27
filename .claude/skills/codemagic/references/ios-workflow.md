# iOS Native Workflow

Complete workflow template for building native iOS applications with Codemagic.

## Basic iOS Workflow

```yaml
workflows:
  ios-workflow:
    name: iOS Build
    instance_type: mac_mini_m2
    max_build_duration: 60
    environment:
      groups:
        - app_store_credentials
      vars:
        XCODE_WORKSPACE: "MyApp.xcworkspace"
        XCODE_SCHEME: "MyApp"
        BUNDLE_ID: "com.example.myapp"
        APP_STORE_APPLE_ID: "1234567890"
      xcode: latest
      cocoapods: default
    triggering:
      events:
        - push
      branch_patterns:
        - pattern: 'main'
          include: true
        - pattern: 'release/*'
          include: true
    scripts:
      - name: Install CocoaPods dependencies
        script: |
          pod install
      
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
      
      - name: Set up code signing
        script: |
          xcode-project use-profiles
      
      - name: Increment build number
        script: |
          agvtool new-version -all $(( \
            $(app-store-connect get-latest-testflight-build-number "$APP_STORE_APPLE_ID") + 1 \
          ))
      
      - name: Build archive
        script: |
          xcode-project build-ipa \
            --workspace "$XCODE_WORKSPACE" \
            --scheme "$XCODE_SCHEME"
    
    artifacts:
      - build/ios/ipa/*.ipa
      - $HOME/Library/Developer/Xcode/DerivedData/**/Build/**/*.dSYM
    
    publishing:
      email:
        recipients:
          - team@example.com
        notify:
          success: true
          failure: true
      app_store_connect:
        api_key: $APP_STORE_CONNECT_PRIVATE_KEY
        key_id: $APP_STORE_CONNECT_KEY_IDENTIFIER
        issuer_id: $APP_STORE_CONNECT_ISSUER_ID
        submit_to_testflight: true
```

## Swift Package Manager (SPM) Project

```yaml
workflows:
  ios-spm:
    name: iOS SPM Build
    instance_type: mac_mini_m2
    environment:
      xcode: latest
    scripts:
      - name: Resolve SPM dependencies
        script: |
          xcodebuild -resolvePackageDependencies \
            -project MyApp.xcodeproj \
            -scheme MyApp
      
      - name: Build
        script: |
          xcodebuild -project MyApp.xcodeproj \
            -scheme MyApp \
            -configuration Release \
            -archivePath build/MyApp.xcarchive \
            archive
```

## iOS with Testing

```yaml
workflows:
  ios-test-and-build:
    name: iOS Test & Build
    instance_type: mac_mini_m2
    environment:
      groups:
        - app_store_credentials
      vars:
        XCODE_WORKSPACE: "MyApp.xcworkspace"
        XCODE_SCHEME: "MyApp"
      xcode: latest
      cocoapods: default
    scripts:
      - name: Install dependencies
        script: |
          pod install
      
      - name: Run unit tests
        script: |
          xcodebuild test \
            -workspace "$XCODE_WORKSPACE" \
            -scheme "$XCODE_SCHEME" \
            -destination 'platform=iOS Simulator,name=iPhone 14,OS=16.0' \
            -only-testing:MyAppTests
      
      - name: Run UI tests
        script: |
          xcodebuild test \
            -workspace "$XCODE_WORKSPACE" \
            -scheme "$XCODE_SCHEME" \
            -destination 'platform=iOS Simulator,name=iPhone 14,OS=16.0' \
            -only-testing:MyAppUITests
      
      - name: Build archive
        script: |
          keychain initialize
          app-store-connect fetch-signing-files "$BUNDLE_ID" --type IOS_APP_STORE
          keychain add-certificates
          xcode-project use-profiles
          xcode-project build-ipa \
            --workspace "$XCODE_WORKSPACE" \
            --scheme "$XCODE_SCHEME"
    
    artifacts:
      - build/ios/ipa/*.ipa
      - build/ios/test/*.xml
```

## iOS with Fastlane

```yaml
workflows:
  ios-fastlane:
    name: iOS Fastlane
    instance_type: mac_mini_m2
    environment:
      groups:
        - ios_credentials
        - fastlane_credentials
      vars:
        FASTLANE_XCODE_LIST_TIMEOUT: "120"
        FASTLANE_APPLE_APPLICATION_SPECIFIC_PASSWORD: $APP_SPECIFIC_PASSWORD
      xcode: latest
      cocoapods: default
    scripts:
      - name: Install dependencies
        script: |
          bundle install
      
      - name: Set up keychain
        script: |
          keychain initialize
      
      - name: Fetch certificates
        script: |
          app-store-connect fetch-signing-files "$BUNDLE_ID" --type IOS_APP_STORE
          keychain add-certificates
      
      - name: Run Fastlane
        script: |
          bundle exec fastlane beta
    
    artifacts:
      - build/ios/ipa/*.ipa
```

## iOS Multi-Environment

```yaml
definitions:
  ios_setup: &ios_setup
    instance_type: mac_mini_m2
    environment:
      xcode: latest
      cocoapods: default
    scripts:
      - &install_deps
        name: Install dependencies
        script: pod install
      - &setup_keychain
        name: Set up keychain
        script: keychain initialize

workflows:
  ios-dev:
    name: iOS Development
    <<: *ios_setup
    environment:
      groups:
        - dev_credentials
      vars:
        XCODE_SCHEME: "MyApp-Dev"
        BUNDLE_ID: "com.example.myapp.dev"
    scripts:
      - *install_deps
      - *setup_keychain
      - name: Build
        script: |
          app-store-connect fetch-signing-files "$BUNDLE_ID" --type IOS_APP_DEVELOPMENT
          keychain add-certificates
          xcode-project use-profiles
          xcode-project build-ipa --scheme "$XCODE_SCHEME"
    publishing:
      firebase:
        firebase_token: $FIREBASE_TOKEN
        ios:
          app_id: $FIREBASE_IOS_DEV_APP_ID
          groups:
            - dev-testers

  ios-prod:
    name: iOS Production
    <<: *ios_setup
    environment:
      groups:
        - prod_credentials
      vars:
        XCODE_SCHEME: "MyApp"
        BUNDLE_ID: "com.example.myapp"
        APP_STORE_APPLE_ID: "1234567890"
    scripts:
      - *install_deps
      - *setup_keychain
      - name: Build
        script: |
          app-store-connect fetch-signing-files "$BUNDLE_ID" --type IOS_APP_STORE
          keychain add-certificates
          xcode-project use-profiles
          agvtool new-version -all $(( \
            $(app-store-connect get-latest-testflight-build-number "$APP_STORE_APPLE_ID") + 1 \
          ))
          xcode-project build-ipa --scheme "$XCODE_SCHEME"
    publishing:
      app_store_connect:
        api_key: $APP_STORE_CONNECT_PRIVATE_KEY
        key_id: $APP_STORE_CONNECT_KEY_IDENTIFIER
        issuer_id: $APP_STORE_CONNECT_ISSUER_ID
        submit_to_testflight: true
```

## iOS with Custom Build Scripts

```yaml
workflows:
  ios-custom:
    name: iOS Custom Build
    instance_type: mac_mini_m2
    environment:
      xcode: latest
      vars:
        BUILD_NUMBER: $((CM_BUILD_NUMBER))
    scripts:
      - name: Set version and build number
        script: |
          # Update version in Info.plist
          /usr/libexec/PlistBuddy -c "Set :CFBundleShortVersionString 1.0.0" \
            "${XCODE_PROJECT}/Info.plist"
          
          # Update build number
          /usr/libexec/PlistBuddy -c "Set :CFBundleVersion ${BUILD_NUMBER}" \
            "${XCODE_PROJECT}/Info.plist"
      
      - name: Custom preprocessing
        script: |
          # Run custom scripts
          ./scripts/preprocess.sh
      
      - name: Build with custom options
        script: |
          xcodebuild \
            -workspace "$XCODE_WORKSPACE" \
            -scheme "$XCODE_SCHEME" \
            -configuration Release \
            -archivePath build/MyApp.xcarchive \
            -allowProvisioningUpdates \
            CODE_SIGN_STYLE=Automatic \
            DEVELOPMENT_TEAM="ABCD123456" \
            archive
      
      - name: Export IPA
        script: |
          xcodebuild \
            -exportArchive \
            -archivePath build/MyApp.xcarchive \
            -exportPath build/ios/ipa \
            -exportOptionsPlist ExportOptions.plist
```

## iOS with Conditional Deployments

```yaml
workflows:
  ios-smart-deploy:
    name: iOS Smart Deploy
    instance_type: mac_mini_m2
    environment:
      groups:
        - app_store_credentials
      xcode: latest
      cocoapods: default
    scripts:
      - name: Build
        script: |
          pod install
          keychain initialize
          app-store-connect fetch-signing-files "$BUNDLE_ID" --type IOS_APP_STORE
          keychain add-certificates
          xcode-project use-profiles
          xcode-project build-ipa --workspace "$XCODE_WORKSPACE" --scheme "$XCODE_SCHEME"
      
      - name: Deploy to TestFlight
        script: |
          app-store-connect publish --path build/ios/ipa/*.ipa
        when:
          condition: env.CM_BRANCH == "main"
      
      - name: Deploy to Firebase
        script: |
          firebase appdistribution:distribute build/ios/ipa/*.ipa \
            --app $FIREBASE_IOS_APP_ID \
            --groups "qa-team"
        when:
          condition: env.CM_BRANCH != "main"
    
    artifacts:
      - build/ios/ipa/*.ipa
```

## Best Practices

### Performance Optimization

1. **Cache CocoaPods**:
```yaml
environment:
  cache:
    cache_paths:
      - $HOME/Library/Caches/CocoaPods
```

2. **Use specific Xcode versions** for reproducible builds
3. **Parallelize tests** when possible
4. **Skip unnecessary steps** with conditions

### Version Management

1. **Automatic build number increments**:
```yaml
scripts:
  - name: Increment build
    script: |
      agvtool new-version -all $((CM_BUILD_NUMBER))
```

2. **Version from Git tags**:
```yaml
scripts:
  - name: Set version from tag
    script: |
      if [ -n "$CM_TAG" ]; then
        VERSION=${CM_TAG#v}  # Remove 'v' prefix
        /usr/libexec/PlistBuddy -c "Set :CFBundleShortVersionString $VERSION" Info.plist
      fi
```

### Error Handling

1. **Fail fast on errors**:
```yaml
scripts:
  - name: Build
    script: |
      set -e
      xcodebuild ...
```

2. **Continue on test failures** (for reporting):
```yaml
scripts:
  - name: Run tests
    script: xcodebuild test ...
    ignore_failure: true
```

### Security

1. **Never hardcode credentials**
2. **Use environment variable groups**
3. **Limit API key permissions**
4. **Rotate secrets regularly**

## Common Issues

**"No such module" errors**
- Run `pod install` before building
- Clean derived data: `rm -rf ~/Library/Developer/Xcode/DerivedData`
- Check Podfile.lock is committed

**Code signing issues**
- Verify certificates in Codemagic UI
- Check bundle ID matches provisioning profile
- Ensure Xcode project uses automatic signing or matches manual settings

**Build timeouts**
- Increase `max_build_duration`
- Enable caching for dependencies
- Parallelize tests if possible

**Simulator not found**
- List available simulators: `xcrun simctl list`
- Use exact simulator name and iOS version
- Pre-boot simulator before tests
