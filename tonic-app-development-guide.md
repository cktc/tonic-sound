# Tonic — App Development Guide

## Document Purpose

This document provides comprehensive direction for building **Tonic**, a sleep and focus sound app with an apothecary/sound potions theme. It covers brand identity, visual design, naming conventions, copy guidelines, and technical requirements.

**Target Platforms:** iOS and Android (Flutter)  
**Primary Audience:** ADHD professionals, sleep strugglers, health-conscious adults  
**Differentiators:** Real-time noise generation (no loops), personalization quiz, science-backed positioning, unique apothecary theme

---

## Part 1: Brand Overview

### The Concept

**Tonic** is an apothecary for the mind. Users don't just play white noise—they receive personalized "prescriptions" of sound remedies formulated for their specific needs. The app feels like visiting a charming old-world apothecary where a knowledgeable chemist crafts the perfect tonic for what ails you.

### Core Metaphor

| Real World | Tonic World |
|------------|-------------|
| Using the app | Visiting the apothecary |
| Choosing a sound | Selecting a remedy |
| Playing audio | Dispensing a tonic |
| Adjusting volume | Setting the strength |
| Setting a timer | Choosing your dosage |
| Mixing sounds | Compounding a formula |
| Saving a preset | Saving a remedy |
| Taking the quiz | Having a consultation |
| Getting recommendations | Receiving a prescription |

### Brand Voice

**Warm but knowledgeable.** Like a friendly apothecary who genuinely wants to help you feel better. Not clinical or cold, but also not flippant or overly casual. There's craft and care behind everything.

**Tone attributes:**
- Caring and empathetic
- Gently confident (we know this works)
- Slightly old-fashioned charm
- Never condescending
- Subtly playful

**Example copy:**
- ✅ "Your prescription is ready. Shall we dispense?"
- ✅ "A tonic for the tired mind"
- ❌ "Click here to play white noise!!!"
- ❌ "Studies show that pink noise enhances slow-wave sleep duration by..."

### Tagline

**Primary:** "A tonic for the tired mind"

**Alternatives for different contexts:**
- "Sound remedies for restless minds"
- "Formulated for rest"
- "The apothecary is open"

---

## Part 2: Naming System

### App Identity

| Element | Value |
|---------|-------|
| **App Name** | Tonic |
| **App Store Title** | Tonic: Sleep & Focus Sounds |
| **App Store Subtitle** | Sound remedies for your mind |
| **Bundle ID suggestion** | com.tonic.app or app.tonic |

### Sound/Noise Types

| Technical Name | Tonic Name | Description | Icon Suggestion |
|----------------|------------|-------------|-----------------|
| White noise | **Bright Tonic** | Light, alert, broadest frequency range | Clear/white bottle |
| Pink noise | **Rest Tonic** | Balanced, optimal for deep sleep | Rose/pink bottle |
| Brown noise | **Focus Tonic** | Deep, grounding, concentration aid | Amber/brown bottle |

### Nature Sounds (Botanicals Collection)

Nature sounds are referred to as **"Botanicals"** — natural ingredients to add to formulas.

| Sound | Botanical Name |
|-------|----------------|
| Rain (steady) | Rainfall Extract |
| Rain (heavy/thunder) | Storm Essence |
| Ocean waves | Sea Salt Tincture |
| River/stream | Streamwater |
| Forest ambience | Woodland Blend |
| Wind | Breeze Distillate |
| Campfire | Ember Essence |
| Night crickets | Evening Chirp |
| Waterfall | Cascade |
| Thunder (distant) | Rumble Root |

### App Modes

| Mode | Tonic Name | Purpose |
|------|------------|---------|
| Sleep mode | **Nightcap** | Optimized for falling/staying asleep |
| Focus mode | **Morning Dose** | Optimized for concentration/work |

### Features & UI Elements

| Feature | Tonic Name | Notes |
|---------|------------|-------|
| Home screen | **The Counter** | Where you're served |
| Sound library | **The Dispensary** | Browse all available tonics |
| Play button | **Dispense** | Or simply show a pouring animation |
| Stop button | **Cap** | Like corking a bottle |
| Volume control | **Strength** | Low/Medium/High strength labels |
| Timer | **Dosage** | "Set your dosage" |
| Mixer/layering | **Compounding Station** | Where you create custom blends |
| Saved presets | **My Remedies** | Your go-to formulas |
| Custom mix | **My Formula** | User-created blend |
| Settings | **Lab Notes** | Configuration and preferences |
| Profile/account | **My Chart** | Your history and preferences |
| History | **Treatment Log** | Past sessions |
| Favorites | **Go-To Remedies** | Quick access to favorites |
| Premium tier | **Full Dispensary** | All access |
| Free tier | **Sample Vials** | Limited but useful |
| Onboarding quiz | **Consultation** | Personalization flow |
| Quiz results | **Your Prescription** | Recommended formula |
| Volume safety indicator | **Safety Seal** | Green/yellow/red indicator |
| Featured/new | **Fresh Batches** | New additions |

### Premium Feature Names

| Feature | Name |
|---------|------|
| Premium subscription | **Full Dispensary Access** |
| Lifetime purchase | **Lifetime Membership** |
| Free trial | **7-Day Trial** or "Sample the Full Dispensary" |

---

## Part 3: Visual Design System

### Color Palette

```
Primary Colors:
- Amber Gold (primary accent): #D4A03C
- Aged Cream (backgrounds, light): #F5F0E6
- Apothecary Green (secondary accent): #2D5A4A
- Warm Copper (highlights, CTAs): #B87333

Dark Mode Colors:
- Rich Brown-Black (base): #1A1614
- Dark Walnut (cards/surfaces): #2C2420
- Muted Gold (text accent): #C9A227
- Soft Cream (primary text): #EDE6D9
- Dim Cream (secondary text): #A69F92

Semantic Colors:
- Safe (volume OK): #4A7C59 (muted green)
- Caution (volume moderate): #D4A03C (amber)
- Warning (volume high): #C75D3A (warm red)

Tonic Colors (for bottle visuals):
- Bright Tonic (white noise): #F5F0E6 with subtle shimmer
- Rest Tonic (pink noise): #D4899A (dusty rose)
- Focus Tonic (brown noise): #8B6914 (deep amber)
```

### Typography

**Recommended Font Pairing:**

```
Headlines/Display:
- Primary: Playfair Display (serif, elegant, apothecary feel)
- Alternative: Freight Display, Lora, or Crimson Text

Body/UI:
- Primary: Inter (clean, readable)
- Alternative: SF Pro (iOS), Roboto (Android)

Labels/Small Caps:
- Use primary body font in small caps for labels
- Letter-spacing: 0.05em - 0.1em for that apothecary label feel

Monospace (for dosage/timer):
- JetBrains Mono or SF Mono
```

**Type Scale:**
```
Display: 32px / 40px line-height
H1: 28px / 36px
H2: 22px / 28px
H3: 18px / 24px
Body: 16px / 24px
Caption: 14px / 20px
Label: 12px / 16px (small caps)
```

### Visual Elements

**Bottle Designs:**
- Each tonic type has a distinct bottle shape
- Bottles should feel hand-blown, slightly imperfect
- Liquid inside has subtle movement/glow when playing
- Cork or glass stopper at top
- Aged paper label with handwritten-style text

**Iconography Style:**
- Line icons with slight weight variation (not perfectly uniform)
- Rounded corners, organic feel
- Could have subtle "hand-drawn" quality
- Icons should feel like they belong in an apothecary

**UI Components:**
- Cards: Slightly rounded corners (12-16px), subtle shadow
- Buttons: Rounded rectangle, copper/amber for primary actions
- Progress bars: Look like liquid filling a vessel
- Sliders: Dropper or dial aesthetic
- Toggles: Old-fashioned switch feel

**Textures & Backgrounds:**
- Subtle paper/parchment texture (very subtle, not distracting)
- Wood grain hints for shelving/navigation
- Glass reflections on bottles
- Warm vignette in dark mode

**Animations:**
- Liquid pouring when starting playback
- Gentle bubbling/steaming while playing
- Cork pop when stopping
- Swirling when mixing sounds
- Droplets for volume adjustment
- Gentle glow pulse on active tonic

### App Icon Concepts

**Primary direction:** A simple, elegant bottle silhouette containing a sound wave or representing liquid/contents.

**Options to explore:**
1. Amber bottle silhouette with subtle sound wave as liquid
2. Minimalist dropper/vial shape
3. Stylized "T" that forms a bottle shape
4. Bottle with gentle glow emanating from within

**Icon should:**
- Read clearly at small sizes
- Work on both light and dark backgrounds
- Feel premium and distinctive
- Hint at the apothecary theme without being too literal

---

## Part 4: Screen-by-Screen UX Copy

### Onboarding Flow

**Screen 1: Welcome**
```
[Tonic logo/bottle animation]

"Welcome to Tonic"

Your mind is restless. Racing thoughts keep you up at night.
Distractions scatter your focus.

You've tried everything.

[Continue]
```

**Screen 2: Differentiation**
```
[Visual of sound waves transforming into liquid]

"We're not just another sound app"

Tonic uses sound science—not just sounds—to craft 
remedies matched to YOUR brain.

Real-time generated. Never loops.
Personalized to you.

[Continue]
```

**Screen 3: Quiz Intro**
```
[Apothecary consultation visual]

"Let's find your formula"

Answer a few quick questions.
We'll prescribe your perfect tonic.

[Begin Consultation]
[Skip for now]
```

### Consultation Quiz

**Question 1:**
```
"What brings you to the apothecary today?"

○ I need better sleep
○ I need help focusing  
○ Both, please

[Next]
```

**Question 2:**
```
"How noisy is your environment?"

○ Quiet — I can hear a pin drop
○ Moderate — Some background noise
○ Noisy — City sounds, snoring partner, chaos

[Next]
```

**Question 3:**
```
"Do any of these sound familiar?"

□ Racing thoughts at bedtime
□ Difficulty concentrating
□ ADHD (diagnosed or suspected)
□ Sensitivity to certain sounds
□ None of these

[Next]
```

**Question 4:**
```
"What's your age range?"

○ Under 30
○ 30-50
○ 50-65
○ 65+

[Next]
```

**Question 5:**
```
"Have you tried sound for sleep or focus before?"

○ Yes, and it helped
○ Yes, but it didn't work for me
○ No, I'm new to this

[Get My Prescription]
```

### Quiz Results

**Example result (sleep + ADHD indicators):**
```
[Prescription card visual]

"Your Prescription"

Based on your consultation, we recommend:

┌─────────────────────────────┐
│  REST TONIC                 │
│  Pink noise                 │
│  ─────────────────          │
│  Strength: Moderate         │
│  Best for: Deep sleep       │
│  ─────────────────          │
│  "Clinically shown to       │
│   enhance slow-wave sleep"  │
└─────────────────────────────┘

For focus during the day, try FOCUS TONIC.

[Dispense Rest Tonic]
[Explore the Dispensary]
```

### Main Screen (The Counter)

**Default state:**
```
┌──────────────────────────────────────┐
│  ☾  Good evening                      │
│                                       │
│  ┌─────────────────────────────────┐ │
│  │                                 │ │
│  │      [Large bottle visual]     │ │
│  │         REST TONIC             │ │
│  │        ──────────────          │ │
│  │         Tap to dispense        │ │
│  │                                 │ │
│  └─────────────────────────────────┘ │
│                                       │
│  STRENGTH  ●───────○────○  Moderate  │
│                                       │
│  DOSAGE    [2 hours      ▼]          │
│                                       │
│  ─────────────────────────────────── │
│  🧪 Dispensary    ⚗️ Compound    ⚙️   │
└──────────────────────────────────────┘
```

**Playing state:**
```
┌──────────────────────────────────────┐
│  ☾  Dispensing...                    │
│                                       │
│  ┌─────────────────────────────────┐ │
│  │                                 │ │
│  │      [Bottle with liquid       │ │
│  │       pouring animation]       │ │
│  │         REST TONIC             │ │
│  │        ──────────────          │ │
│  │        advancement text         │ │
│  │                                 │ │
│  └─────────────────────────────────┘ │
│                                       │
│  ▐▐  1:47:32 remaining               │
│                                       │
│  STRENGTH  ●────────●────○           │
│            ● Safe dosage             │
│                                       │
│  ─────────────────────────────────── │
│  [Cap]                    [My Remedies]│
└──────────────────────────────────────┘
```

### The Dispensary (Library)

```
┌──────────────────────────────────────┐
│  ← The Dispensary                    │
│                                       │
│  TONICS                              │
│  ┌─────┐ ┌─────┐ ┌─────┐            │
│  │ 🤍  │ │ 💗  │ │ 🤎  │            │
│  │Bright│ │Rest │ │Focus│            │
│  └─────┘ └─────┘ └─────┘            │
│                                       │
│  BOTANICALS                          │
│  ┌─────┐ ┌─────┐ ┌─────┐ ┌─────┐   │
│  │ 🌧️  │ │ 🌊  │ │ 🔥  │ │ 🌲  │   │
│  │Rain │ │Ocean│ │Ember│ │Forest│   │
│  └─────┘ └─────┘ └─────┘ └─────┘   │
│  ┌─────┐ ┌─────┐ ┌─────┐ ┌─────┐   │
│  │ 🦗  │ │ ⛈️  │ │ 💨  │ │ 🔒  │   │
│  │Night│ │Storm│ │Breeze│ │More │   │
│  └─────┘ └─────┘ └─────┘ └─────┘   │
│                        ↑ Premium     │
│  MY REMEDIES                         │
│  ┌─────────────────────────────────┐ │
│  │ "Rainy Focus" - Focus + Rain    │ │
│  │ "Deep Sleep" - Rest + Thunder   │ │
│  └─────────────────────────────────┘ │
└──────────────────────────────────────┘
```

### Compounding Station (Mixer)

```
┌──────────────────────────────────────┐
│  ← Compounding Station               │
│                                       │
│  "Create your formula"               │
│                                       │
│  BASE TONIC                          │
│  ┌─────────────────────────────────┐ │
│  │ 🤎 Focus Tonic          ●●●○○  │ │
│  └─────────────────────────────────┘ │
│                                       │
│  ADD BOTANICALS (up to 2)            │
│  ┌─────────────────────────────────┐ │
│  │ 🌧️ Rainfall Extract     ●●○○○  │ │
│  └─────────────────────────────────┘ │
│  ┌─────────────────────────────────┐ │
│  │ + Add another botanical         │ │
│  └─────────────────────────────────┘ │
│                                       │
│  ─────────────────────────────────── │
│                                       │
│  [Preview Formula]   [Save to Remedies]│
│                                       │
└──────────────────────────────────────┘
```

### Volume Safety Indicator

```
Safe (Green):
┌─────────────────────────────┐
│ ● Safe dosage               │
│ Volume is hearing-safe      │
└─────────────────────────────┘

Moderate (Yellow/Amber):
┌─────────────────────────────┐
│ ● Moderate strength         │
│ Consider lowering for       │
│ extended use                │
└─────────────────────────────┘

High (Red/Warning):
┌─────────────────────────────┐
│ ⚠️ High strength            │
│ May affect hearing with     │
│ prolonged use               │
│ [Learn more]                │
└─────────────────────────────┘
```

### Premium Upsell

```
┌──────────────────────────────────────┐
│                                       │
│  🔓 Unlock the Full Dispensary       │
│                                       │
│  Get access to:                       │
│  ✓ All 10+ Botanicals                │
│  ✓ Unlimited custom formulas         │
│  ✓ Extended dosage options           │
│  ✓ Strength fine-tuning              │
│  ✓ Treatment insights                │
│                                       │
│  ┌─────────────────────────────────┐ │
│  │  $19.99/year                    │ │
│  │  Just $1.67/month               │ │
│  │  [Start 7-Day Free Trial]       │ │
│  └─────────────────────────────────┘ │
│                                       │
│  ┌─────────────────────────────────┐ │
│  │  $39.99 Lifetime                │ │
│  │  One-time purchase              │ │
│  │  [Get Lifetime Access]          │ │
│  └─────────────────────────────────┘ │
│                                       │
│  [Continue with Sample Vials]        │
│                                       │
└──────────────────────────────────────┘
```

---

## Part 5: Technical Requirements

### Core Audio Engine

**Real-time noise generation (critical differentiator):**
- Generate white, pink, and brown noise algorithmically in real-time
- NO pre-recorded audio loops
- Use flutter_soloud or equivalent for real-time PCM streaming

**Technical specifications:**
```
Sample rate: 44100 Hz
Buffer size: ~50ms chunks (2205 samples)
Bit depth: 16-bit

White noise: Random values, normalized
Pink noise: IIR filter with coefficients:
  B = [0.049922035, -0.095993537, 0.050612699, -0.004408786]
  A = [1, -2.494956002, 2.017265875, -0.522189400]
Brown noise: Leaky integrator, coefficient ~0.02 on white noise
```

**Audio session requirements:**
- Background audio playback (continues when app is backgrounded/locked)
- Proper audio session configuration for iOS (AVAudioSession category: playback)
- Mix with other audio OR duck other audio (user preference)
- Lock screen controls integration
- Interruption handling (phone calls, Siri, etc.)

### Playback Features

**Timer/Dosage system:**
- Preset options: 30m, 1h, 2h, 4h, 8h, Continuous
- Custom duration input (premium)
- Fade-out over final 5 minutes (default)
- Adjustable fade duration (premium): 1m, 5m, 10m, 15m, 30m

**Volume/Strength:**
- System volume integration
- In-app volume adjustment (0-100%)
- dB estimation for safety indicator
- Visual feedback: Safe (<60dB), Moderate (60-70dB), High (>70dB)

**Mixing/Compounding:**
- Layer up to 3 sounds simultaneously (1 tonic + 2 botanicals)
- Individual volume control per layer
- Crossfade when switching sounds (1-2 second transition)
- Save custom mixes with user-defined names

### Data & Storage

**Local storage:**
- User preferences (selected tonic, strength, dosage defaults)
- Quiz responses and prescription
- Saved remedies/formulas
- Treatment log (session history)
- Premium status

**No backend required for MVP**, but structure for future:
- User accounts (optional)
- Cloud sync of remedies
- Analytics events

### Platform Requirements

**iOS:**
- Minimum: iOS 15.0
- Background audio entitlement
- HealthKit integration (Phase 3)
- Widget support (Phase 3)
- Siri Shortcuts (Phase 3)

**Android:**
- Minimum: Android 8.0 (API 26)
- Foreground service for background playback
- Notification controls
- Health Connect integration (Phase 3)

---

## Part 6: Information Architecture

```
Tonic App
│
├── Onboarding (first launch only)
│   ├── Welcome screens (3)
│   └── Consultation quiz (5 questions)
│
├── The Counter (home)
│   ├── Current tonic display
│   ├── Dispense/Cap controls
│   ├── Strength slider
│   ├── Dosage selector
│   └── Quick access to last remedy
│
├── The Dispensary (library)
│   ├── Tonics section
│   │   ├── Bright Tonic
│   │   ├── Rest Tonic
│   │   └── Focus Tonic
│   ├── Botanicals section
│   │   ├── Free botanicals (3)
│   │   └── Premium botanicals (7+)
│   └── My Remedies (saved mixes)
│
├── Compounding Station (mixer)
│   ├── Base tonic selector
│   ├── Botanical layers (up to 2)
│   ├── Individual strength controls
│   ├── Preview
│   └── Save formula
│
├── Lab Notes (settings)
│   ├── Nightcap/Morning Dose defaults
│   ├── Default strength
│   ├── Default dosage
│   ├── Fade-out duration
│   ├── Retake consultation
│   ├── Manage subscription
│   ├── About/Credits
│   └── Support
│
├── My Chart (profile) — Phase 2+
│   ├── Treatment log
│   ├── Sleep quality ratings
│   ├── Insights
│   └── Export data
│
└── Premium
    ├── Full Dispensary unlock
    ├── Pricing options
    └── Restore purchases
```

---

## Part 7: MVP Scope

### Must Have (Launch)

1. **Core tonics:** Bright, Rest, Focus (white, pink, brown noise)
2. **Real-time generation:** No loops, algorithmically generated
3. **Background playback:** Continue when app closed/locked
4. **Dosage timer:** Preset options with fade-out
5. **Strength control:** With safety indicator
6. **Consultation quiz:** 5 questions with prescription result
7. **Dark mode UI:** Apothecary themed
8. **Lock screen controls:** Play/pause
9. **Basic botanicals:** 3 free nature sounds (rain, ocean, forest)

### Phase 2 (Month 2-3)

1. **Compounding station:** Mix tonic + botanicals
2. **My Remedies:** Save custom formulas
3. **Nightcap/Morning Dose modes:** Preset configurations
4. **Full botanicals library:** 10+ sounds
5. **Premium subscription:** Full Dispensary access
6. **Onboarding refinements:** Based on feedback

### Phase 3 (Month 4-6)

1. **Treatment log:** Session history
2. **Sleep quality check-ins:** Morning ratings
3. **HealthKit integration**
4. **Widgets**
5. **Siri shortcuts**

---

## Part 8: Reference Documents

The following documents contain additional detail:

1. **Product Strategy Document** — Market research, ASO strategy, competitive analysis, revenue projections

2. **User Stories Document** — 40 detailed user stories with acceptance criteria, organized by epic and phase

---

## Part 9: Design Assets Needed

### For MVP Launch

**App Icon:**
- 1024x1024 master file
- All required sizes for iOS/Android

**Bottle Illustrations:**
- Bright Tonic bottle (white/clear)
- Rest Tonic bottle (pink/rose)
- Focus Tonic bottle (brown/amber)
- Generic botanical vials (3 for free tier)

**UI Elements:**
- Cork/stopper graphics
- Liquid pour animation frames
- Bubbling/steaming animation frames
- Progress bar as filling liquid
- Strength slider custom design
- Safety indicator icons

**Backgrounds:**
- Counter surface (wood grain subtle)
- Dispensary shelving
- Subtle parchment texture overlay

**Onboarding:**
- Welcome illustration
- Consultation/apothecary scene
- Prescription card design

**App Store:**
- 6 screenshot templates
- Feature graphic (Android)
- Preview video storyboard

---

## Summary

**App Name:** Tonic  
**Tagline:** A tonic for the tired mind  
**Theme:** Apothecary / Sound Potions  
**Differentiators:** Real-time generation, personalization, science-backed, unique theme  

**Key Experience Principles:**
1. Feel like visiting a caring apothecary, not using a utility
2. Every interaction reinforces the potion/remedy metaphor
3. Warm and premium, never clinical or cold
4. Personalization makes users feel seen and understood
5. Sound quality and reliability above all else

---

*Document Version: 1.0*  
*Last Updated: November 2025*
