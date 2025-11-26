<!--
Sync Impact Report
==================
Version change: 0.0.0 → 1.0.0 (MAJOR - initial constitution creation)

Modified principles: N/A (initial creation)

Added sections:
- Core Principles (6 principles)
- Brand & Design Standards
- Development Workflow
- Governance

Removed sections: N/A (initial creation)

Templates requiring updates:
- .specify/templates/plan-template.md ✅ (compatible - uses generic Constitution Check)
- .specify/templates/spec-template.md ✅ (compatible - no principle-specific references)
- .specify/templates/tasks-template.md ✅ (compatible - generic task structure)
- .specify/templates/checklist-template.md ✅ (compatible - generic structure)
- .specify/templates/agent-file-template.md ✅ (compatible - no constitution references)

Follow-up TODOs: None
==================
-->

# Tonic Constitution

## Core Principles

### I. Real-Time Audio Generation (NON-NEGOTIABLE)

All noise types (white, pink, brown) MUST be generated algorithmically in real-time using PCM
streaming. Pre-recorded audio loops are strictly prohibited.

**Technical requirements:**
- Sample rate: 44100 Hz
- Buffer size: ~50ms chunks (2205 samples)
- Bit depth: 16-bit
- White noise: Random values, normalized
- Pink noise: IIR filter with documented coefficients
- Brown noise: Leaky integrator (~0.02 coefficient on white noise)

**Rationale:** Real-time generation is Tonic's core differentiator from competitors. Loops create
audible repetition that degrades the user experience and undermines our scientific positioning.

### II. Brand Consistency

All user-facing elements MUST use the Tonic naming system and apothecary metaphor. Technical
terminology MUST NOT appear in UI, copy, or user-facing errors.

**Naming requirements:**
- Sounds → Tonics/Botanicals (never "noise types" or "audio files")
- Play → Dispense (never "play" or "start")
- Volume → Strength (never "volume" or "level")
- Timer → Dosage (never "timer" or "duration")
- Library → Dispensary (never "library" or "collection")
- Saved items → Remedies (never "presets" or "favorites")

**Rationale:** Consistent metaphor creates a premium, differentiated experience that reinforces
brand value and memorability.

### III. Background Audio Reliability

Audio playback MUST continue uninterrupted when the app is backgrounded, the device is locked, or
during system interruptions.

**Platform requirements:**
- iOS: AVAudioSession category configured for playback; proper interruption handling
- Android: Foreground service with notification controls
- Both: Lock screen controls integration; graceful handling of phone calls/Siri/Assistant

**Rationale:** Users depend on Tonic for sleep and focus sessions lasting hours. Any audio
interruption breaks trust and renders the app unusable for its core purpose.

### IV. User Safety First

Volume/strength controls MUST include safety indicators and warnings. The app MUST NOT encourage
or enable hearing damage.

**Requirements:**
- Visual indicator at three levels: Safe (<60dB), Moderate (60-70dB), High (>70dB)
- Warning message displayed when volume exceeds safe threshold
- Default strength MUST be in the safe range
- Extended high-volume usage MUST trigger an educational prompt

**Rationale:** Users may listen for 8+ hours during sleep. We have a duty of care to protect
hearing health, and liability exposure requires clear warnings.

### V. Phased Delivery

Features MUST be delivered in the defined phases. Phase 1 (MVP) scope is fixed; scope creep into
later phases is prohibited until MVP is shipped.

**MVP (Phase 1) scope - immutable:**
1. Core tonics: Bright, Rest, Focus (white, pink, brown noise)
2. Real-time generation
3. Background playback
4. Dosage timer with fade-out
5. Strength control with safety indicator
6. Consultation quiz (5 questions)
7. Dark mode apothecary UI
8. Lock screen controls
9. Basic botanicals (rain, ocean, forest)

**Rationale:** Shipping a polished MVP validates the core value proposition before investing in
advanced features. Feature creep delays launch and dilutes focus.

### VI. Simplicity Over Abstraction

Start with the simplest implementation that works. Add complexity only when proven necessary
through actual usage or explicit requirements.

**Guidelines:**
- YAGNI: Do not build for hypothetical future requirements
- No premature optimization before profiling identifies bottlenecks
- Prefer Flutter built-in solutions before adding dependencies
- Maximum 3 sound layers (1 tonic + 2 botanicals) - do not over-engineer mixing

**Rationale:** Mobile apps must be lightweight and maintainable. Over-engineering increases bundle
size, complexity, and bug surface area.

## Brand & Design Standards

### Visual Identity

**Color palette (dark mode primary):**
- Base: Rich Brown-Black #1A1614
- Surfaces: Dark Walnut #2C2420
- Accent: Muted Gold #C9A227
- Text primary: Soft Cream #EDE6D9
- Text secondary: Dim Cream #A69F92

**Typography:**
- Headlines: Playfair Display (serif)
- Body/UI: Inter
- Labels: Small caps with 0.05em-0.1em letter-spacing

**UI principles:**
- Rounded corners (12-16px)
- Subtle shadows for depth
- Bottle visuals with liquid animations
- Cork/stopper interactions for stop actions
- Liquid pour animations for play actions

### Voice & Tone

**Brand voice:** Warm but knowledgeable - like a friendly apothecary who genuinely wants to help.

**Do:**
- "Your prescription is ready. Shall we dispense?"
- "A tonic for the tired mind"
- Use caring, gently confident language

**Do not:**
- "Click here to play white noise!!!"
- Clinical or overly technical language
- Condescending or flippant tone

## Development Workflow

### Testing Strategy

- Unit tests for audio generation algorithms (sample output verification)
- Integration tests for audio session handling (background, interruptions)
- Widget tests for UI components
- Manual testing on physical devices for audio quality and battery impact

### Code Organization

```text
lib/
├── core/           # Audio engine, noise generators
├── features/       # Feature modules (counter, dispensary, compounding)
├── shared/         # Shared widgets, theme, constants
└── main.dart

test/
├── unit/           # Algorithm tests
├── widget/         # UI component tests
└── integration/    # Audio session tests
```

### Platform Configuration

- iOS: Configure Info.plist for background audio, audio session category
- Android: Configure foreground service, notification channel
- Both: Proper permission handling and user-facing explanations

## Governance

This constitution supersedes all other development practices for the Tonic project.

**Amendment process:**
1. Proposed changes MUST be documented with rationale
2. Changes to NON-NEGOTIABLE principles require explicit product owner approval
3. All amendments MUST include migration plan for existing code
4. Version number incremented per semantic versioning rules

**Compliance:**
- All PRs MUST pass constitution compliance review
- Plan documents MUST include Constitution Check section
- Violations MUST be justified in Complexity Tracking with rejected alternatives

**Guidance:** Use `tonic-app-development-guide.md` for detailed implementation reference.

**Version**: 1.0.0 | **Ratified**: 2025-11-25 | **Last Amended**: 2025-11-25
