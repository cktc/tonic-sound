---
name: ios-app-store-submission
description: Generate all copywriting and asset specifications needed for iOS App Store submissions. Use when preparing an app for App Store Connect, creating app descriptions, keywords, screenshots specs, promotional text, release notes, or any App Store metadata. Covers iPhone/iPad/Watch screenshots, App Clips, iMessage apps, and review information.
---

# iOS App Store Submission

Generate App Store Connect metadata, copywriting, and asset specifications.

## Workflow

1. **Gather app information** - Collect app name, core features, target audience, and unique value proposition
2. **Generate copywriting** - Create description, keywords, promotional text, and release notes
3. **Specify screenshot requirements** - Output device-specific dimensions and content recommendations
4. **Prepare review materials** - Generate review notes and test account details if needed
5. **Output as structured document** - Deliver all content in a copy-paste-ready format

## Required Information

Before generating content, collect from user:
- App name and version
- Core functionality (3-5 key features)
- Target audience
- Unique selling points vs competitors
- Pricing model (free/paid/subscription)
- Languages/localizations needed
- Whether app requires sign-in
- Special capabilities (App Clips, iMessage, Apple Watch)

## Copywriting Elements

### Description (max 4000 characters)
Structure:
1. **Opening hook** (1-2 sentences) - Immediate value proposition
2. **Core features** (bulleted list) - 3-5 key capabilities
3. **Social proof** (optional) - Awards, press, user counts
4. **Call to action** - Download motivation

Guidelines:
- Lead with benefits, not features
- Use keywords naturally (helps search ranking)
- Avoid mentioning price (may change)
- No references to other platforms
- Front-load important info (truncated in search)

### Keywords (max 100 characters)
- Comma-separated, no spaces after commas
- Skip words already in app name
- Include common misspellings if relevant
- Prioritize high-intent search terms
- Avoid: trademarked terms, category names already assigned

### Promotional Text (max 170 characters)
- Can update without new app version
- Use for timely messaging, sales, events
- Shows above description in App Store

### What's New / Release Notes (max 4000 characters)
- Bullet format works well
- Lead with most impactful changes
- Keep concise—users scan quickly

### App Clip Metadata (if applicable)
- **Subtitle**: Max 56 characters
- **Header Image**: 1920 × 640 pixels
- **Action**: Verb describing clip function

See [references/metadata.md](references/metadata.md) for detailed examples and templates.

## Screenshot Specifications

See [references/screenshots.md](references/screenshots.md) for complete device dimensions.

Key requirements:
- **iPhone 6.7"**: 1290 × 2796 or 1284 × 2778 px
- **iPhone 6.5"**: 1242 × 2688 px
- **iPad 12.9"**: 2048 × 2732 px
- Up to 10 screenshots per device, minimum 1
- First 3 screenshots most critical (visible in search)

Screenshot content tips:
- Show app in action, not empty states
- Use captions/overlays for context
- Localize text for each language
- Consistent visual style across all screens

## App Review Information

If sign-in required, provide:
- Demo account credentials
- Any special instructions for testing
- Notes about features requiring specific conditions

See [references/review-checklist.md](references/review-checklist.md) for pre-submission validation.

## Output Format

Generate a structured markdown document with all content organized by section:

```markdown
# App Store Submission: [App Name] v[X.X]

## Metadata

### App Name
[Name - max 30 chars]

### Subtitle
[Subtitle - max 30 chars]

### Promotional Text
[Text - max 170 chars] (X/170 characters)

### Description
[Full description - max 4000 chars]

Character count: X/4000

### Keywords
[comma,separated,keywords - max 100 chars total]

Character count: X/100

### What's New
[Release notes for this version]

## Review Information

### Demo Account
- Username: 
- Password: 

### Review Notes
[Any special instructions]

## Screenshot Requirements

### iPhone 6.7" Display
- Dimensions: 1290 × 2796 px (portrait) or 2796 × 1290 px (landscape)
- Recommended screens: [list based on app features]

### iPad 12.9" Display  
- Dimensions: 2048 × 2732 px (portrait) or 2732 × 2048 px (landscape)
- Recommended screens: [list based on app features]

## Localization Checklist
- [ ] English (Primary)
- [ ] [Other languages as needed]
```
