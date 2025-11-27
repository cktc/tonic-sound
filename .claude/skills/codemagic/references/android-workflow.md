# Android Native Workflow

Complete workflow template for building native Android applications with Codemagic.

## Basic Android Workflow

```yaml
workflows:
  android-workflow:
    name: Android Build
    instance_type: linux
    max_build_duration: 60
    environment:
      groups:
        - keystore_credentials
        - google_play_credentials
      vars:
        PACKAGE_NAME: "com.example.myapp"
      java: 11
      node: 16
    triggering:
      events:
        - push
      branch_patterns:
        - pattern: 'main'
          include: true
        - pattern: 'release/*'
          include: true
    scripts:
      - name: Set up local.properties
        script: |
          echo "sdk.dir=$ANDROID_SDK_ROOT" > "$CM_BUILD_DIR/local.properties"
      
      - name: Set up keystore
        script: |
          echo $CM_KEYSTORE | base64 --decode > $CM_KEYSTORE_PATH
      
      - name: Run tests
        script: |
          ./gradlew test
      
      - name: Build APK
        script: |
          ./gradlew assembleRelease
      
      # Or build App Bundle:
      # - name: Build AAB
      #   script: |
      #     ./gradlew bundleRelease
    
    artifacts:
      - app/build/outputs/**/*.apk
      - app/build/outputs/**/*.aab
    
    publishing:
      email:
        recipients:
          - team@example.com
        notify:
          success: true
          failure: true
      google_play:
        credentials: $GCLOUD_SERVICE_ACCOUNT_CREDENTIALS
        track: internal
```

## Android with Multiple Build Variants

```yaml
workflows:
  android-variants:
    name: Android Build Variants
    instance_type: linux
    environment:
      groups:
        - keystore_credentials
      java: 11
    scripts:
      - name: Set up keystore
        script: |
          echo $CM_KEYSTORE | base64 --decode > $CM_KEYSTORE_PATH
      
      - name: Build all variants
        script: |
          ./gradlew assembleDevelopmentDebug
          ./gradlew assembleDevelopmentRelease
          ./gradlew assembleStagingDebug
          ./gradlew assembleStagingRelease
          ./gradlew assembleProductionDebug
          ./gradlew assembleProductionRelease
    
    artifacts:
      - app/build/outputs/**/*.apk
```

## Android with Flavors and Dimensions

```yaml
workflows:
  android-multi-flavor:
    name: Android Multi-Flavor
    instance_type: linux
    environment:
      groups:
        - keystore_credentials
      vars:
        BUILD_FLAVOR: production
        BUILD_TYPE: release
      java: 11
    scripts:
      - name: Set up keystore
        script: |
          echo $CM_KEYSTORE | base64 --decode > $CM_KEYSTORE_PATH
      
      - name: Build specific flavor
        script: |
          TASK="assemble${BUILD_FLAVOR^}${BUILD_TYPE^}"
          echo "Building: $TASK"
          ./gradlew $TASK
    
    artifacts:
      - app/build/outputs/**/*.apk
```

## Android with Testing

```yaml
workflows:
  android-test:
    name: Android Test & Build
    instance_type: linux
    environment:
      groups:
        - keystore_credentials
      java: 11
    scripts:
      - name: Run unit tests
        script: |
          ./gradlew test
      
      - name: Run lint
        script: |
          ./gradlew lint
      
      - name: Run instrumented tests
        script: |
          ./gradlew connectedAndroidTest
        ignore_failure: true  # Continue even if tests fail
      
      - name: Build APK
        script: |
          echo $CM_KEYSTORE | base64 --decode > $CM_KEYSTORE_PATH
          ./gradlew assembleRelease
    
    artifacts:
      - app/build/outputs/**/*.apk
      - app/build/test-results/**/*.xml
      - app/build/reports/**
```

## Android with Firebase

```yaml
workflows:
  android-firebase:
    name: Android Firebase Build
    instance_type: linux
    environment:
      groups:
        - keystore_credentials
        - firebase_credentials
      vars:
        FIREBASE_SERVICE_ACCOUNT: $FIREBASE_SERVICE_ACCOUNT_JSON
      java: 11
    scripts:
      - name: Decode Firebase config
        script: |
          echo $FIREBASE_SERVICE_ACCOUNT | base64 --decode > $CM_BUILD_DIR/firebase-key.json
      
      - name: Build with Firebase
        script: |
          echo $CM_KEYSTORE | base64 --decode > $CM_KEYSTORE_PATH
          ./gradlew assembleRelease
      
      - name: Upload to Crashlytics
        script: |
          ./gradlew crashlyticsUploadDistributionRelease
    
    publishing:
      firebase:
        firebase_token: $FIREBASE_TOKEN
        android:
          app_id: $FIREBASE_ANDROID_APP_ID
          groups:
            - qa-team
            - beta-testers
```

## Android with ProGuard/R8

```yaml
workflows:
  android-obfuscated:
    name: Android Obfuscated Build
    instance_type: linux
    environment:
      groups:
        - keystore_credentials
      java: 11
    scripts:
      - name: Set up keystore
        script: |
          echo $CM_KEYSTORE | base64 --decode > $CM_KEYSTORE_PATH
      
      - name: Build with R8
        script: |
          ./gradlew assembleRelease \
            -Pandroid.enableR8=true \
            -Pandroid.enableR8.fullMode=true
    
    artifacts:
      - app/build/outputs/**/*.apk
      - app/build/outputs/mapping/release/mapping.txt  # ProGuard mapping
```

## Android Multi-Environment

```yaml
definitions:
  android_setup: &android_setup
    instance_type: linux
    environment:
      java: 11
      node: 16

workflows:
  android-dev:
    name: Android Development
    <<: *android_setup
    environment:
      groups:
        - dev_keystore
      vars:
        PACKAGE_NAME: "com.example.app.dev"
        BUILD_FLAVOR: "development"
    scripts:
      - name: Build Dev
        script: |
          echo $CM_KEYSTORE | base64 --decode > $CM_KEYSTORE_PATH
          ./gradlew assembleDevelopmentRelease
    publishing:
      firebase:
        firebase_token: $FIREBASE_TOKEN
        android:
          app_id: $FIREBASE_ANDROID_DEV_APP_ID
          groups:
            - dev-testers

  android-staging:
    name: Android Staging
    <<: *android_setup
    environment:
      groups:
        - staging_keystore
      vars:
        PACKAGE_NAME: "com.example.app.staging"
        BUILD_FLAVOR: "staging"
    scripts:
      - name: Build Staging
        script: |
          echo $CM_KEYSTORE | base64 --decode > $CM_KEYSTORE_PATH
          ./gradlew assembleStagingRelease
    publishing:
      firebase:
        firebase_token: $FIREBASE_TOKEN
        android:
          app_id: $FIREBASE_ANDROID_STAGING_APP_ID

  android-prod:
    name: Android Production
    <<: *android_setup
    environment:
      groups:
        - prod_keystore
        - google_play_credentials
      vars:
        PACKAGE_NAME: "com.example.app"
    scripts:
      - name: Build Production
        script: |
          echo $CM_KEYSTORE | base64 --decode > $CM_KEYSTORE_PATH
          ./gradlew bundleProductionRelease
    artifacts:
      - app/build/outputs/bundle/**/*.aab
    publishing:
      google_play:
        credentials: $GCLOUD_SERVICE_ACCOUNT_CREDENTIALS
        track: production
        submit_as_draft: true
```

## Android with Custom Gradle Tasks

```yaml
workflows:
  android-custom:
    name: Android Custom Build
    instance_type: linux
    environment:
      groups:
        - keystore_credentials
      vars:
        VERSION_NAME: "1.0.0"
        VERSION_CODE: $((CM_BUILD_NUMBER))
      java: 11
    scripts:
      - name: Set version
        script: |
          # Update version in build.gradle
          sed -i "s/versionName .*/versionName \"$VERSION_NAME\"/" app/build.gradle
          sed -i "s/versionCode .*/versionCode $VERSION_CODE/" app/build.gradle
      
      - name: Run custom preprocessing
        script: |
          ./gradlew preprocessRelease
      
      - name: Build with custom task
        script: |
          echo $CM_KEYSTORE | base64 --decode > $CM_KEYSTORE_PATH
          ./gradlew customBuildTask --stacktrace
      
      - name: Run custom postprocessing
        script: |
          ./gradlew postprocessRelease
```

## Android with Dependency Updates

```yaml
workflows:
  android-dependency-check:
    name: Android Dependency Check
    instance_type: linux
    environment:
      java: 11
    scripts:
      - name: Check for dependency updates
        script: |
          ./gradlew dependencyUpdates
      
      - name: Run security scan
        script: |
          ./gradlew dependencyCheckAnalyze
    
    artifacts:
      - build/reports/dependencyUpdates/**
      - build/reports/dependency-check-report.html
```

## Android Native with NDK

```yaml
workflows:
  android-ndk:
    name: Android NDK Build
    instance_type: linux
    environment:
      groups:
        - keystore_credentials
      vars:
        NDK_VERSION: "21.4.7075529"
      java: 11
      ndk: r21d
    scripts:
      - name: Set up NDK
        script: |
          echo "ndk.dir=$ANDROID_NDK_ROOT" >> local.properties
      
      - name: Build native libraries
        script: |
          ./gradlew externalNativeBuildRelease
      
      - name: Build APK
        script: |
          echo $CM_KEYSTORE | base64 --decode > $CM_KEYSTORE_PATH
          ./gradlew assembleRelease
```

## Best Practices

### Performance Optimization

1. **Enable Gradle caching**:
```yaml
environment:
  cache:
    cache_paths:
      - ~/.gradle/caches
      - ~/.android/build-cache
```

2. **Use Gradle daemon**:
```yaml
scripts:
  - name: Build with daemon
    script: |
      ./gradlew --daemon assembleRelease
```

3. **Parallelize builds**:
```yaml
scripts:
  - name: Parallel build
    script: |
      ./gradlew --parallel assembleRelease
```

### Version Management

1. **Version from environment**:
```groovy
// build.gradle
android {
    defaultConfig {
        versionCode System.getenv("CM_BUILD_NUMBER")?.toInteger() ?: 1
        versionName System.getenv("VERSION_NAME") ?: "1.0.0"
    }
}
```

2. **Version from Git tags**:
```yaml
scripts:
  - name: Set version from tag
    script: |
      if [ -n "$CM_TAG" ]; then
        VERSION=${CM_TAG#v}
        echo "VERSION_NAME=$VERSION" >> $CM_ENV
        echo "VERSION_CODE=$CM_BUILD_NUMBER" >> $CM_ENV
      fi
```

### Build Configuration

1. **Separate debug/release configurations**:
```groovy
buildTypes {
    debug {
        applicationIdSuffix ".debug"
        debuggable true
    }
    release {
        minifyEnabled true
        proguardFiles getDefaultProguardFile('proguard-android-optimize.txt'), 'proguard-rules.pro'
        signingConfig signingConfigs.release
    }
}
```

2. **Use build flavors**:
```groovy
flavorDimensions "environment"
productFlavors {
    development {
        dimension "environment"
        applicationIdSuffix ".dev"
        buildConfigField "String", "API_URL", '"https://dev-api.example.com"'
    }
    production {
        dimension "environment"
        buildConfigField "String", "API_URL", '"https://api.example.com"'
    }
}
```

### Security

1. **Never commit keystores** to version control
2. **Use environment variables** for sensitive data
3. **Enable ProGuard/R8** for release builds
4. **Validate signing configuration** before release

### Testing

1. **Run tests before builds**:
```yaml
scripts:
  - name: Unit tests
    script: ./gradlew test
  - name: Build only if tests pass
    script: ./gradlew assembleRelease
```

2. **Generate coverage reports**:
```yaml
scripts:
  - name: Test with coverage
    script: |
      ./gradlew testDebugUnitTestCoverage
artifacts:
  - app/build/reports/coverage/**
```

## Common Issues

**"Execution failed for task ':app:lintVitalRelease'"**
- Disable lint checks for release: `lintOptions { checkReleaseBuilds false }`
- Or fix lint errors: `./gradlew lint`

**"Could not find com.android.tools.build:gradle"**
- Verify Gradle version matches Android Gradle Plugin
- Check `gradle-wrapper.properties`
- Update dependencies

**"Keystore was tampered with, or password was incorrect"**
- Verify `CM_KEYSTORE_PASSWORD` is correct
- Check keystore file wasn't corrupted
- Ensure base64 encoding/decoding is correct

**"No toolchains found in the NDK toolchains folder"**
- Specify NDK version in build.gradle: `ndkVersion "21.4.7075529"`
- Ensure NDK is installed
- Check NDK path in local.properties

**Build timeout**
- Increase `max_build_duration`
- Enable Gradle caching
- Use `--parallel` flag
- Reduce number of variants built simultaneously
