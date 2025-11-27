# Built-in Environment Variables

Codemagic exports these environment variables during every build. They're available in all scripts automatically.

## Build Identification

| Variable | Description | Example |
|----------|-------------|---------|
| `CM_BUILD_ID` | Unique build identifier | `5d7c2dcf06357739c1e61e04` |
| `CM_PROJECT_ID` | Project identifier | `5d7c2d6406357739c1e61e03` |
| `CM_BUILD_NUMBER` | Incremental build number | `12` |
| `CM_BUILD_URL` | URL to build in Codemagic UI | `https://codemagic.io/app/.../build/...` |

## Repository Information

| Variable | Description | Example |
|----------|-------------|---------|
| `CM_REPO_SLUG` | Repository slug | `username/repository` |
| `CM_BRANCH` | Git branch name | `main`, `feature/new-ui` |
| `CM_TAG` | Git tag (if build triggered by tag) | `v1.0.0` |
| `CM_COMMIT` | Git commit SHA | `f02b425db3a405b5dbf8fc1e490e232f45b77ad3` |
| `CM_COMMIT_MESSAGE` | Full commit message | `Fix login bug` |
| `CM_PREVIOUS_COMMIT` | Previous commit SHA | `a1b2c3d4...` |

## Pull Request Information

| Variable | Description | Example |
|----------|-------------|---------|
| `CM_PULL_REQUEST` | Boolean if build is from PR | `true` or `false` |
| `CM_PULL_REQUEST_NUMBER` | PR number | `42` |
| `CM_PULL_REQUEST_DEST` | Target branch of PR | `main` |
| `CM_PULL_REQUEST_SOURCE` | Source branch of PR | `feature/new-feature` |

## Build Environment

| Variable | Description | Example |
|----------|-------------|---------|
| `CM_BUILD_DIR` | Build working directory | `/Users/builder/clone` |
| `CM_BUILD_OUTPUT_DIR` | Output directory for artifacts | `/Users/builder/export_output` |
| `CM_ENV` | File for persisting variables | `/tmp/codemagic_env.txt` |
| `CI` | Always `true` in CI environment | `true` |
| `CODEMAGIC` | Always `true` | `true` |
| `CONTINUOUS_INTEGRATION` | Always `true` | `true` |

## Platform Detection

| Variable | Description | Example |
|----------|-------------|---------|
| `CM_INSTANCE_TYPE` | Build machine type | `mac_mini_m2`, `linux`, `windows_x2` |
| `CM_PLATFORM` | Build platform | `darwin`, `linux`, `windows` |

## Flutter-Specific

| Variable | Description | Example |
|----------|-------------|---------|
| `CM_FLUTTER_SCHEME` | iOS scheme name | `Runner` |
| `FCI_FLUTTER_VERSION` | Flutter version being used | `3.10.5` |
| `FCI_FLUTTER_CHANNEL` | Flutter channel | `stable` |

## Xcode/iOS-Specific

| Variable | Description | Example |
|----------|-------------|---------|
| `CM_XCODE_VERSION` | Xcode version | `14.3` |
| `CM_XCODE_SCHEME` | Xcode scheme | `MyApp` |
| `CM_XCODE_WORKSPACE` | Xcode workspace path | `ios/Runner.xcworkspace` |
| `CM_XCODE_PROJECT` | Xcode project path | `ios/Runner.xcodeproj` |
| `CM_CERTIFICATE` | iOS certificate path | `/tmp/cert.p12` |
| `CM_PROVISIONING_PROFILE` | Provisioning profile path | `/tmp/profile.mobileprovision` |

## Android-Specific

| Variable | Description | Example |
|----------|-------------|---------|
| `CM_KEYSTORE` | Android keystore path | `/tmp/keystore.jks` |
| `CM_KEYSTORE_PATH` | Alias for CM_KEYSTORE | `/tmp/keystore.jks` |
| `CM_KEYSTORE_PASSWORD` | Keystore password | From encrypted variable |
| `CM_KEY_PASSWORD` | Key password | From encrypted variable |
| `CM_KEY_ALIAS` | Key alias | `my-key-alias` |
| `CM_ANDROID_SDK_TOOLS` | Android SDK tools path | `/usr/local/share/android-sdk` |

## Artifact Information

| Variable | Description | Example |
|----------|-------------|---------|
| `CM_ARTIFACT_LINKS` | JSON array of artifact metadata | See below |

### CM_ARTIFACT_LINKS Format

JSON array with details about generated artifacts:

```json
[
  {
    "name": "app-release.ipa",
    "type": "ipa",
    "url": "https://api.codemagic.io/artifacts/.../app-release.ipa",
    "md5": "d2884be6985dad3ffc4d6f85b3a3642a",
    "versionName": "1.0.2",
    "bundleId": "com.example.app"
  }
]
```

## User Information

| Variable | Description | Example |
|----------|-------------|---------|
| `CM_USER_EMAIL` | Email of user who triggered build | `user@example.com` |
| `CM_USER_NAME` | Name of user who triggered build | `John Doe` |

## Usage Examples

### Accessing Variables

```yaml
scripts:
  - name: Display build info
    script: |
      echo "Building branch: $CM_BRANCH"
      echo "Commit: $CM_COMMIT"
      echo "Build ID: $CM_BUILD_ID"
```

### Conditional Logic Based on Branch

```yaml
scripts:
  - name: Deploy to environment
    script: |
      if [ "$CM_BRANCH" = "main" ]; then
        echo "Deploying to production"
        ./deploy-prod.sh
      elif [ "$CM_BRANCH" = "develop" ]; then
        echo "Deploying to staging"
        ./deploy-staging.sh
      fi
```

### Using Commit Message

```yaml
scripts:
  - name: Check commit message
    script: |
      if echo "$CM_COMMIT_MESSAGE" | grep -q "hotfix"; then
        echo "Hotfix detected"
        # Special hotfix handling
      fi
```

### Processing Artifacts

```yaml
scripts:
  - name: Process artifacts
    script: |
      #!/usr/bin/env python3
      import json
      import os
      
      artifacts = json.loads(os.environ.get('CM_ARTIFACT_LINKS', '[]'))
      for artifact in artifacts:
          print(f"Artifact: {artifact['name']} at {artifact['url']}")
```

### Using in Publishing

```yaml
publishing:
  scripts:
    - name: Custom notification
      script: |
        curl -X POST https://api.example.com/notify \
          -H "Content-Type: application/json" \
          -d "{
            \"branch\": \"$CM_BRANCH\",
            \"commit\": \"$CM_COMMIT\",
            \"build_url\": \"$CM_BUILD_URL\",
            \"status\": \"success\"
          }"
```

## Important Notes

1. **User-defined variables override** built-in variables if they have the same name
2. **Not all variables are available** in all contexts (e.g., `CM_TAG` only exists for tag-triggered builds)
3. **PR variables** are only available when building pull requests
4. **Platform-specific variables** only exist on relevant platforms (e.g., `CM_XCODE_VERSION` only on macOS)
5. **Secure variables** from groups are injected but not visible in logs
