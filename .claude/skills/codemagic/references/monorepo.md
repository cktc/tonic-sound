# Monorepo Setup Guide

Configure Codemagic workflows for monorepo projects with multiple apps, packages, or platforms.

## Overview

Monorepos contain multiple projects in a single repository. Use Codemagic's changeset filtering and working directories to build only what changed.

## Basic Monorepo Structure

```
my-monorepo/
├── apps/
│   ├── mobile-app/
│   │   ├── android/
│   │   ├── ios/
│   │   └── lib/
│   ├── admin-dashboard/
│   └── customer-portal/
├── packages/
│   ├── shared-ui/
│   ├── api-client/
│   └── utils/
└── codemagic.yaml
```

## Strategy 1: Separate Workflows per App

Create dedicated workflows for each app, triggered only by changes to that app.

```yaml
workflows:
  mobile-app-ios:
    name: Mobile App - iOS
    instance_type: mac_mini_m2
    working_directory: apps/mobile-app
    triggering:
      events:
        - push
      when:
        changeset:
          includes:
            - 'apps/mobile-app/**'
            - 'packages/**'  # Shared packages affect mobile app
          excludes:
            - '**/*.md'
            - 'apps/mobile-app/android/**'  # iOS doesn't need Android changes
    scripts:
      - name: Build iOS
        script: |
          flutter pub get
          flutter build ios --release
    artifacts:
      - build/ios/ipa/*.ipa

  mobile-app-android:
    name: Mobile App - Android
    instance_type: linux
    working_directory: apps/mobile-app
    triggering:
      events:
        - push
      when:
        changeset:
          includes:
            - 'apps/mobile-app/**'
            - 'packages/**'
          excludes:
            - '**/*.md'
            - 'apps/mobile-app/ios/**'  # Android doesn't need iOS changes
    scripts:
      - name: Build Android
        script: |
          flutter pub get
          flutter build apk --release
    artifacts:
      - build/app/outputs/flutter-apk/*.apk

  admin-dashboard:
    name: Admin Dashboard
    instance_type: linux
    working_directory: apps/admin-dashboard
    triggering:
      events:
        - push
      when:
        changeset:
          includes:
            - 'apps/admin-dashboard/**'
            - 'packages/shared-ui/**'
            - 'packages/api-client/**'
    scripts:
      - name: Build dashboard
        script: |
          npm install
          npm run build
```

## Strategy 2: Conditional Steps in Single Workflow

Use conditional script execution for selective builds.

```yaml
workflows:
  monorepo-build:
    name: Monorepo Build
    instance_type: mac_mini_m2
    scripts:
      - name: Check what changed
        script: |
          # Store changed paths
          git diff --name-only $CM_PREVIOUS_COMMIT $CM_COMMIT > changed_files.txt
          
          # Set flags for what to build
          if grep -q "^apps/mobile-app/" changed_files.txt; then
            echo "BUILD_MOBILE=true" >> $CM_ENV
          fi
          if grep -q "^apps/admin-dashboard/" changed_files.txt; then
            echo "BUILD_DASHBOARD=true" >> $CM_ENV
          fi
          if grep -q "^packages/" changed_files.txt; then
            echo "BUILD_ALL=true" >> $CM_ENV
          fi
      
      - name: Build mobile app
        working_directory: apps/mobile-app
        script: |
          flutter pub get
          flutter build ios --release
          flutter build apk --release
        when:
          condition: env.BUILD_MOBILE == "true" or env.BUILD_ALL == "true"
      
      - name: Build dashboard
        working_directory: apps/admin-dashboard
        script: |
          npm install
          npm run build
        when:
          condition: env.BUILD_DASHBOARD == "true" or env.BUILD_ALL == "true"
```

## Strategy 3: Matrix Builds

Build multiple apps in parallel using YAML anchors.

```yaml
definitions:
  flutter_env: &flutter_env
    flutter: stable
    xcode: latest
  
  build_mobile: &build_mobile
    - name: Get dependencies
      script: flutter pub get
    - name: Run tests
      script: flutter test
    - name: Build
      script: |
        flutter build ios --release
        flutter build apk --release

workflows:
  mobile-app-1:
    name: Mobile App 1
    instance_type: mac_mini_m2
    working_directory: apps/mobile-app-1
    environment:
      <<: *flutter_env
    triggering:
      events:
        - push
      when:
        changeset:
          includes:
            - 'apps/mobile-app-1/**'
            - 'packages/**'
    scripts: *build_mobile
  
  mobile-app-2:
    name: Mobile App 2
    instance_type: mac_mini_m2
    working_directory: apps/mobile-app-2
    environment:
      <<: *flutter_env
    triggering:
      events:
        - push
      when:
        changeset:
          includes:
            - 'apps/mobile-app-2/**'
            - 'packages/**'
    scripts: *build_mobile
```

## Flutter Monorepo with Melos

For Flutter monorepos using Melos:

```yaml
workflows:
  flutter-monorepo:
    name: Flutter Monorepo
    instance_type: mac_mini_m2
    environment:
      flutter: stable
      xcode: latest
    scripts:
      - name: Install Melos
        script: |
          dart pub global activate melos
      
      - name: Bootstrap packages
        script: |
          melos bootstrap
      
      - name: Run tests for all packages
        script: |
          melos run test
      
      - name: Build app 1
        working_directory: apps/app1
        script: |
          flutter build ios --release
        when:
          changeset:
            includes:
              - 'apps/app1/**'
              - 'packages/**'
      
      - name: Build app 2
        working_directory: apps/app2
        script: |
          flutter build android --release
        when:
          changeset:
            includes:
              - 'apps/app2/**'
              - 'packages/**'
```

## React Native Monorepo with Yarn Workspaces

```yaml
workflows:
  rn-monorepo:
    name: React Native Monorepo
    instance_type: mac_mini_m2
    environment:
      node: 18
      xcode: latest
    scripts:
      - name: Install dependencies
        script: |
          yarn install --frozen-lockfile
      
      - name: Build shared packages
        script: |
          yarn workspace @myapp/shared build
          yarn workspace @myapp/components build
      
      - name: Build iOS app
        working_directory: apps/mobile
        script: |
          cd ios && pod install && cd ..
          npx react-native build-ios --mode Release
        when:
          changeset:
            includes:
              - 'apps/mobile/**'
              - 'packages/**'
      
      - name: Build Android app
        working_directory: apps/mobile
        script: |
          cd android && ./gradlew assembleRelease
        when:
          changeset:
            includes:
              - 'apps/mobile/**'
              - 'packages/**'
```

## Multi-Platform Monorepo

```yaml
definitions:
  shared_packages: &shared_packages
    - 'packages/**'
    - '**/*.md'

workflows:
  ios-app:
    name: iOS App
    instance_type: mac_mini_m2
    working_directory: apps/ios-app
    triggering:
      events:
        - push
      when:
        changeset:
          includes:
            - 'apps/ios-app/**'
            - *shared_packages
    scripts:
      - name: Build iOS
        script: |
          pod install
          xcodebuild -workspace MyApp.xcworkspace \
            -scheme MyApp \
            -configuration Release \
            archive
  
  android-app:
    name: Android App
    instance_type: linux
    working_directory: apps/android-app
    triggering:
      events:
        - push
      when:
        changeset:
          includes:
            - 'apps/android-app/**'
            - *shared_packages
    scripts:
      - name: Build Android
        script: |
          ./gradlew assembleRelease
  
  web-app:
    name: Web App
    instance_type: linux
    working_directory: apps/web-app
    triggering:
      events:
        - push
      when:
        changeset:
          includes:
            - 'apps/web-app/**'
            - *shared_packages
    scripts:
      - name: Build Web
        script: |
          npm install
          npm run build
```

## Advanced Patterns

### Dependency Detection

Automatically detect which apps depend on changed packages:

```yaml
workflows:
  smart-monorepo:
    name: Smart Monorepo Build
    instance_type: mac_mini_m2
    scripts:
      - name: Detect affected apps
        script: |
          #!/usr/bin/env python3
          import os
          import json
          
          # Read changed files
          changed = os.popen(f'git diff --name-only {os.environ["CM_PREVIOUS_COMMIT"]} {os.environ["CM_COMMIT"]}').read().split('\n')
          
          # Determine which apps are affected
          affected = set()
          
          for file in changed:
              if file.startswith('packages/'):
                  # If package changed, all apps are affected
                  affected.update(['app1', 'app2', 'app3'])
              elif file.startswith('apps/app1/'):
                  affected.add('app1')
              elif file.startswith('apps/app2/'):
                  affected.add('app2')
          
          # Write to environment
          with open(os.environ['CM_ENV'], 'a') as f:
              for app in affected:
                  f.write(f'BUILD_{app.upper()}=true\n')
          
          print(f"Affected apps: {affected}")
      
      - name: Build app1
        working_directory: apps/app1
        script: flutter build ios
        when:
          condition: env.BUILD_APP1 == "true"
      
      - name: Build app2
        working_directory: apps/app2
        script: flutter build android
        when:
          condition: env.BUILD_APP2 == "true"
```

### Parallel Package Builds

```yaml
workflows:
  package-builds:
    name: Build All Packages
    instance_type: linux
    scripts:
      - name: Build packages in parallel
        script: |
          #!/bin/bash
          
          build_package() {
              local pkg=$1
              echo "Building $pkg..."
              cd "packages/$pkg"
              npm run build
              cd ../..
          }
          
          # Export function for parallel
          export -f build_package
          
          # Build all packages in parallel
          find packages -maxdepth 1 -type d ! -path packages | \
            xargs -I {} basename {} | \
            parallel -j 4 build_package {}
```

### Selective Testing

```yaml
workflows:
  selective-tests:
    name: Selective Testing
    instance_type: linux
    scripts:
      - name: Test changed packages only
        script: |
          # Get changed packages
          CHANGED_DIRS=$(git diff --name-only $CM_PREVIOUS_COMMIT $CM_COMMIT | \
            grep "^packages/" | \
            cut -d/ -f1-2 | \
            sort -u)
          
          # Run tests for each changed package
          for dir in $CHANGED_DIRS; do
            echo "Testing $dir"
            cd $dir
            npm test || true
            cd $CM_BUILD_DIR
          done
```

## Best Practices

### Changeset Configuration

1. **Be specific with includes/excludes**:
```yaml
when:
  changeset:
    includes:
      - 'apps/specific-app/**'
      - 'packages/shared-*/**'  # Only shared packages
    excludes:
      - '**/*.md'
      - '**/test/**'
      - '**/*.test.ts'
```

2. **Consider transitive dependencies**:
```yaml
# If package-a depends on package-b, changes to package-b affect package-a
when:
  changeset:
    includes:
      - 'packages/package-a/**'
      - 'packages/package-b/**'  # Dependency
```

### Performance

1. **Cache at root level**:
```yaml
environment:
  cache:
    cache_paths:
      - ~/.npm
      - ~/.gradle/caches
      - node_modules
      - packages/*/node_modules
```

2. **Use working_directory** to avoid full repo operations:
```yaml
working_directory: apps/mobile-app
scripts:
  - name: Build
    script: flutter build  # Runs in apps/mobile-app
```

3. **Skip unnecessary workflows**:
```yaml
triggering:
  when:
    changeset:
      includes:
        - 'apps/my-app/**'
# No build triggered if only other apps changed
```

### Organization

1. **Use YAML anchors** for repeated configuration
2. **Group related workflows** with consistent naming
3. **Document dependencies** in workflow names or labels
4. **Use labels** to categorize workflows

## Common Patterns

### Branch-Specific Deployments

```yaml
workflows:
  app-dev:
    name: App Development
    triggering:
      events:
        - push
      branch_patterns:
        - pattern: 'develop'
          include: true
      when:
        changeset:
          includes:
            - 'apps/my-app/**'
    # Deploy to dev environment

  app-prod:
    name: App Production
    triggering:
      events:
        - push
      branch_patterns:
        - pattern: 'main'
          include: true
      when:
        changeset:
          includes:
            - 'apps/my-app/**'
    # Deploy to production
```

### Version Syncing

```yaml
scripts:
  - name: Sync versions
    script: |
      # Read version from root package.json
      VERSION=$(jq -r .version package.json)
      
      # Update all app versions
      for app in apps/*/package.json; do
        jq ".version = \"$VERSION\"" $app > $app.tmp
        mv $app.tmp $app
      done
```

## Troubleshooting

**Workflow not triggering**
- Verify changeset includes match actual file paths
- Check if branch patterns are correct
- Ensure [skip ci] is not in commit message
- Review webhook configuration

**Too many workflows triggering**
- Make changeset filters more specific
- Use excludes to filter out non-functional changes
- Consider using separate repositories for truly independent apps

**Long build times**
- Enable caching for dependencies
- Use parallel builds where possible
- Split into smaller, more focused workflows
- Consider building only changed apps

**Cache issues**
- Each workflow has its own cache
- Verify cache paths are correct
- Check cache hit rates in build logs
- Consider cache size limits
