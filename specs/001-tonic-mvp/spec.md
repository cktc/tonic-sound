# Feature Specification: Tonic MVP - Sleep & Focus Sound App

**Feature Branch**: `001-tonic-mvp`
**Created**: 2025-11-25
**Status**: Draft
**Input**: User description: "Build Tonic MVP sleep and focus sound app with apothecary theme"

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Play a Sound Tonic for Sleep (Priority: P1)

A user wants to fall asleep using calming sound. They open the app, see their recommended tonic displayed prominently on the main screen (The Counter), and tap to start playing. The sound plays continuously even after they lock their phone and place it on the nightstand. In the morning, the sound has stopped automatically after the set duration.

**Why this priority**: This is the core value proposition of the app. Without reliable sound playback that works in the background, the app has no utility. This validates the fundamental audio engine.

**Independent Test**: Can be fully tested by opening the app, tapping to dispense any tonic, locking the device, and verifying sound continues for the full dosage duration. Delivers the primary sleep aid value.

**Acceptance Scenarios**:

1. **Given** a user is on The Counter screen with Rest Tonic displayed, **When** they tap the bottle, **Then** sound begins playing immediately with a visual "pouring" indication.
2. **Given** sound is playing and the user locks their device, **When** 5 minutes pass, **Then** sound continues playing uninterrupted.
3. **Given** sound is playing with a 2-hour dosage set, **When** 2 hours elapse, **Then** sound fades out gradually over the final 5 minutes and stops.
4. **Given** sound is playing, **When** the user receives a phone call and ends it, **Then** sound resumes automatically after the call.

---

### User Story 2 - Adjust Strength and Dosage (Priority: P2)

A user wants to customize their listening experience. They adjust the strength (volume) slider to find a comfortable level and set a specific dosage (timer) for how long the sound should play. The app shows a safety indicator so they know if the volume is at a hearing-safe level.

**Why this priority**: Customization enables users to tailor the experience to their needs, but it builds on the core playback functionality. Without P1, these controls have nothing to control.

**Independent Test**: Can be tested by adjusting strength slider and observing safety indicator changes, setting various dosage times, and verifying sound stops at the correct time with fade-out.

**Acceptance Scenarios**:

1. **Given** a user is on The Counter screen, **When** they drag the strength slider, **Then** the audio volume changes in real-time and the safety indicator updates (green/amber/red).
2. **Given** strength is set to high (red indicator), **When** the user views the indicator, **Then** a warning message is displayed explaining potential hearing impact.
3. **Given** a user selects 30-minute dosage, **When** the tonic is dispensed, **Then** a countdown timer shows remaining time and sound fades out at 25 minutes.
4. **Given** dosage is running, **When** the user taps the Cap button, **Then** playback stops immediately with a "corking" animation.

---

### User Story 3 - Complete Personalization Consultation (Priority: P3)

A first-time user wants to know which tonic is best for them. During onboarding, they answer a 5-question consultation quiz about their sleep/focus needs. Based on their answers, the app provides a personalized prescription recommending the optimal tonic.

**Why this priority**: Personalization increases engagement and conversion, but the app is usable without it. Users can manually select tonics even without completing the quiz.

**Independent Test**: Can be tested by going through the onboarding flow, answering all 5 questions, and verifying the prescription result matches the expected recommendation logic.

**Acceptance Scenarios**:

1. **Given** a first-time user launches the app, **When** they reach the consultation screen, **Then** they see "Let's find your formula" with a Begin Consultation button.
2. **Given** a user is in the consultation, **When** they answer all 5 questions, **Then** they receive a prescription card showing their recommended tonic with rationale.
3. **Given** a user indicates "I need better sleep" and "ADHD," **When** the prescription is generated, **Then** Rest Tonic (pink noise) is recommended as optimal for deep sleep.
4. **Given** a user skips the consultation, **When** they proceed, **Then** they can still access The Counter with a default tonic displayed.

---

### User Story 4 - Browse and Select Different Tonics (Priority: P4)

A user wants to try different sound types. They navigate to The Dispensary to browse available tonics (Bright, Rest, Focus) and basic botanicals (rain, ocean, forest). They select a different tonic and it becomes their active sound on The Counter.

**Why this priority**: Variety enhances the product, but MVP can ship with a single default tonic. This expands choice after core playback works.

**Independent Test**: Can be tested by navigating to The Dispensary, viewing all available tonics and botanicals, selecting one, and verifying it loads on The Counter ready to dispense.

**Acceptance Scenarios**:

1. **Given** a user taps the Dispensary navigation item, **When** the screen loads, **Then** they see three tonics (Bright, Rest, Focus) and three botanicals (Rain, Ocean, Forest).
2. **Given** a user is viewing The Dispensary, **When** they tap Focus Tonic, **Then** they return to The Counter with Focus Tonic displayed and ready to dispense.
3. **Given** a user selects Rainfall Extract botanical, **When** they return to The Counter, **Then** the botanical plays when dispensed (nature sound, not algorithmic noise).

---

### User Story 5 - Control Playback from Lock Screen (Priority: P5)

A user has the tonic playing while their phone is locked. They want to pause or stop the sound without unlocking the device. They use the lock screen media controls to manage playback.

**Why this priority**: Convenience feature that improves user experience, but users can unlock and use the app if needed. Enhances polish of P1 functionality.

**Independent Test**: Can be tested by starting playback, locking the device, and using lock screen controls to pause/resume and stop playback.

**Acceptance Scenarios**:

1. **Given** a tonic is playing and device is locked, **When** the user views lock screen, **Then** they see Tonic app media controls with pause and stop options.
2. **Given** lock screen controls are visible, **When** the user taps pause, **Then** playback pauses and the control changes to a play button.
3. **Given** playback is paused via lock screen, **When** the user taps play, **Then** playback resumes from where it left off.

---

### Edge Cases

- What happens when the device battery is critically low during playback? Playback continues until device shuts down; app state is saved so settings persist on restart.
- What happens if the user switches to another audio app while tonic is playing? Tonic audio ducks or pauses based on system behavior; resumes when other audio stops (follows platform conventions).
- How does the system handle audio interruptions from alarms? System alarm takes priority; tonic playback resumes automatically when alarm is dismissed.
- What happens if a user force-quits the app during playback? Playback stops; on next launch, previous settings are restored but playback does not auto-resume.
- How does the app behave offline? All tonics are generated locally; no network required for core functionality.

## Requirements *(mandatory)*

### Functional Requirements

**Core Audio**
- **FR-001**: System MUST generate white, pink, and brown noise algorithmically in real-time (no pre-recorded loops).
- **FR-002**: System MUST continue audio playback when the app is backgrounded or device is locked.
- **FR-003**: System MUST handle audio interruptions gracefully (phone calls, alarms, other apps) and resume playback when appropriate.
- **FR-004**: System MUST provide lock screen media controls for play/pause/stop.

**Playback Controls**
- **FR-005**: Users MUST be able to start playback by tapping the displayed tonic bottle.
- **FR-006**: Users MUST be able to stop playback by tapping a Cap/stop button.
- **FR-007**: Users MUST be able to adjust playback strength via a slider control.
- **FR-008**: System MUST display a volume safety indicator at three levels (safe, moderate, high).
- **FR-009**: System MUST display a warning when volume exceeds safe threshold.
- **FR-010**: Users MUST be able to set a dosage timer with preset options (30m, 1h, 2h, 4h, 8h, continuous).
- **FR-011**: System MUST fade out audio over the final 5 minutes when dosage timer expires.

**Personalization**
- **FR-012**: System MUST present a 5-question consultation quiz during onboarding.
- **FR-013**: System MUST generate a personalized tonic prescription based on quiz responses.
- **FR-014**: Users MUST be able to skip the consultation and proceed with default settings.
- **FR-015**: System MUST persist quiz responses and prescription for returning users.

**Content Library**
- **FR-016**: System MUST provide three core tonics: Bright (white noise), Rest (pink noise), Focus (brown noise).
- **FR-017**: System MUST provide three basic botanicals: Rainfall Extract, Sea Salt Tincture, Woodland Blend.
- **FR-018**: Users MUST be able to browse all available tonics and botanicals in The Dispensary.
- **FR-019**: Users MUST be able to select a tonic or botanical for playback.

**Persistence**
- **FR-020**: System MUST persist user preferences (last selected tonic, strength, dosage defaults) locally.
- **FR-021**: System MUST restore user settings on app launch.

### Key Entities

- **Tonic**: A generated noise type with properties including name (display name in apothecary style), type (white/pink/brown), description, and visual representation (bottle design, color).
- **Botanical**: A nature sound with properties including name (apothecary style), audio source reference, description, and visual representation.
- **Prescription**: A personalized recommendation containing recommended tonic, recommended strength, rationale text, and association to quiz responses.
- **Quiz Response**: User's answers to the 5 consultation questions, used to generate prescription.
- **User Preferences**: Persisted settings including last selected tonic, default strength, default dosage, quiz completion status, and prescription.
- **Playback Session**: Current or historical playback state including active tonic/botanical, strength level, dosage setting, start time, and status (playing/paused/stopped).

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: Users can start sound playback within 3 taps from app launch.
- **SC-002**: Sound playback continues uninterrupted for 8+ hours with device locked and screen off.
- **SC-003**: Audio resumes within 2 seconds after a phone call or system interruption ends.
- **SC-004**: 90% of first-time users can complete the consultation quiz in under 2 minutes.
- **SC-005**: Users can adjust strength and dosage settings in under 5 seconds.
- **SC-006**: App launches and displays The Counter screen in under 2 seconds on supported devices.
- **SC-007**: 100% of algorithmically generated noise is non-repeating (no audible loops or patterns).
- **SC-008**: Volume safety indicator accurately reflects hearing-safe levels per standard guidelines.
- **SC-009**: Lock screen controls respond to user input within 500ms.
- **SC-010**: All user preferences persist correctly across app restarts.

## Assumptions

- Target platforms are iOS (15.0+) and Android (8.0+) via a cross-platform framework.
- No user accounts or cloud sync required for MVP; all data stored locally on device.
- Nature sounds (botanicals) are bundled audio assets, not generated algorithmically.
- No premium/subscription features in MVP scope; all content is freely accessible.
- App operates entirely offline; no network connectivity required.
- Default fade-out duration is 5 minutes; custom fade duration is deferred to a future phase.
- App uses dark mode by default with the apothecary color palette.
