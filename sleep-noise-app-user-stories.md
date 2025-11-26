# Sleep Noise App: User Stories

## Document Overview

This document contains user stories for the sleep noise app, organized by epic and prioritized according to the product roadmap. Stories follow the standard format: **As a [user type], I want [goal], so that [benefit].**

Acceptance criteria are provided for each story using the Given/When/Then format where applicable.

---

## User Personas

### Primary Personas

| Persona | Description | Key Needs |
|---------|-------------|-----------|
| **Alex (ADHD Professional)** | 32, software developer, diagnosed ADHD, discovered brown noise on TikTok | Focus during work, quieting racing thoughts, evidence that it works |
| **Sarah (Sleep Struggler)** | 45, marketing manager, light sleeper in noisy apartment, tried multiple apps | Block out city noise, fall asleep faster, no jarring ads or loops |
| **Marcus (Older Adult)** | 67, retired teacher, experiencing age-related sleep quality decline | Deeper sleep, better memory, simple interface |
| **Emma (New Parent)** | 29, first-time mom, exhausted, needs baby to sleep | Safe sounds for infant, volume guidance, quick access |

### Secondary Personas

| Persona | Description | Key Needs |
|---------|-------------|-----------|
| **Jordan (Student)** | 20, university student, needs focus for studying | Concentration aid, affordable/free option |
| **Dr. Chen (Health-Conscious)** | 38, physician, skeptical of wellness apps | Scientific backing, evidence-based features |

---

## Epic 1: Core Noise Generation

### E1-S1: White Noise Playback ⭐ MVP
**As a** sleep struggler,  
**I want** to play continuous white noise,  
**So that** I can mask environmental sounds and fall asleep.

**Acceptance Criteria:**
- Given I open the app, when I tap the white noise option, then audio begins playing within 500ms
- Given white noise is playing, when I lock my phone, then audio continues uninterrupted
- Given white noise is playing, when I adjust the system volume, then the noise volume changes accordingly
- Given white noise is playing for 8+ hours, then no audio artifacts, loops, or glitches occur

**Story Points:** 5  
**Priority:** P0 (MVP)

---

### E1-S2: Pink Noise Playback ⭐ MVP
**As a** user seeking better deep sleep,  
**I want** to play pink noise,  
**So that** I can potentially enhance my slow-wave sleep and memory consolidation.

**Acceptance Criteria:**
- Given I open the app, when I select pink noise, then audio with correct -3dB/octave frequency rolloff plays
- Given pink noise is playing, when compared to white noise, then it sounds noticeably deeper and softer
- Given I am a new user, when I select pink noise, then I see a brief tooltip explaining its benefits for deep sleep

**Story Points:** 5  
**Priority:** P0 (MVP)

---

### E1-S3: Brown Noise Playback ⭐ MVP
**As an** ADHD professional,  
**I want** to play brown noise,  
**So that** I can quiet my racing thoughts and focus on my work.

**Acceptance Criteria:**
- Given I open the app, when I select brown noise, then audio with correct -6dB/octave frequency rolloff plays
- Given brown noise is playing, when compared to pink noise, then it sounds noticeably deeper with more bass
- Given I am a new user, when I select brown noise, then I see a tooltip explaining its popularity for focus/ADHD

**Story Points:** 5  
**Priority:** P0 (MVP)

---

### E1-S4: Real-Time Generation (No Loops) ⭐ MVP
**As a** light sleeper,  
**I want** noise that never loops or repeats,  
**So that** I don't hear jarring restarts that wake me up.

**Acceptance Criteria:**
- Given any noise type is playing, when I listen for 10+ minutes, then I cannot detect any repeating pattern
- Given the app generates noise, when analyzed technically, then it uses real-time PCM generation, not pre-recorded audio files
- Given noise plays for 8 hours continuously, then memory usage remains stable (no leaks)

**Story Points:** 8  
**Priority:** P0 (MVP)

---

### E1-S5: Seamless Noise Type Switching
**As a** user exploring different noise types,  
**I want** to switch between white, pink, and brown noise smoothly,  
**So that** I can find my preferred sound without jarring transitions.

**Acceptance Criteria:**
- Given white noise is playing, when I tap pink noise, then the audio crossfades over 1-2 seconds
- Given I switch noise types, when the transition completes, then there is no audio gap or pop
- Given I switch noise types rapidly, when tapping multiple times, then the app remains stable

**Story Points:** 3  
**Priority:** P1 (Phase 2)

---

## Epic 2: Playback Controls

### E2-S1: Background Audio Playback ⭐ MVP
**As a** user going to sleep,  
**I want** the noise to continue playing when I lock my phone or switch apps,  
**So that** I don't have to keep the app open all night.

**Acceptance Criteria:**
- Given noise is playing, when I press the lock button, then audio continues
- Given noise is playing, when I switch to another app, then audio continues
- Given noise is playing in background, when I receive a phone call, then audio pauses and resumes after
- Given noise is playing, when I open Control Center/Notification shade, then playback controls are visible

**Story Points:** 5  
**Priority:** P0 (MVP)

---

### E2-S2: Sleep Timer with Fade-Out ⭐ MVP
**As a** user who doesn't need noise all night,  
**I want** to set a timer that gradually fades out the sound,  
**So that** I fall asleep to noise but it doesn't play until morning.

**Acceptance Criteria:**
- Given I want to set a timer, when I tap the timer icon, then I see preset options (30m, 1h, 2h, 4h, 8h)
- Given I set a 1-hour timer, when 55 minutes have passed, then the volume begins fading out over 5 minutes
- Given the timer completes, when audio stops, then there is no abrupt cutoff (smooth fade to silence)
- Given a timer is active, when I view the player screen, then I see remaining time displayed

**Story Points:** 5  
**Priority:** P0 (MVP)

---

### E2-S3: Custom Timer Duration
**As a** user with specific sleep timing needs,  
**I want** to set a custom timer duration,  
**So that** I can match the noise to my exact sleep routine.

**Acceptance Criteria:**
- Given I tap the timer icon, when I select "Custom", then I can input any duration from 1 minute to 12 hours
- Given I set a custom duration, when I use it frequently, then it appears in my recent/favorite timers

**Story Points:** 3  
**Priority:** P1 (Phase 2)

---

### E2-S4: Adjustable Fade Duration
**As a** premium user,  
**I want** to customize how long the fade-out takes,  
**So that** I can have a very gradual transition to silence.

**Acceptance Criteria:**
- Given I have premium, when I access timer settings, then I can choose fade duration (1m, 5m, 10m, 15m, 30m)
- Given I set a 30-minute fade, when the timer nears completion, then volume decreases linearly over 30 minutes

**Story Points:** 2  
**Priority:** P2 (Phase 3) — Premium Feature

---

### E2-S5: Lock Screen Controls ⭐ MVP
**As a** user who wakes up at night,  
**I want** to control playback from my lock screen,  
**So that** I can pause or adjust without fully waking up to unlock my phone.

**Acceptance Criteria:**
- Given noise is playing, when I view my lock screen, then I see play/pause controls
- Given I'm on the lock screen, when I tap pause, then audio stops immediately
- Given audio is paused from lock screen, when I tap play, then the same noise type resumes

**Story Points:** 3  
**Priority:** P0 (MVP)

---

## Epic 3: Volume & Safety

### E3-S1: Volume Safety Indicator ⭐ MVP
**As a** health-conscious user,  
**I want** to see if my volume level is safe for extended listening,  
**So that** I don't damage my hearing over time.

**Acceptance Criteria:**
- Given noise is playing, when volume is below 60dB equivalent, then indicator shows green
- Given noise is playing, when volume is 60-70dB, then indicator shows yellow with "Moderate" label
- Given noise is playing, when volume exceeds 70dB, then indicator shows red with warning
- Given I tap the indicator, when the info panel opens, then I see explanation of safe volume levels

**Story Points:** 5  
**Priority:** P0 (MVP)

---

### E3-S2: Volume Warning Modal
**As a** user who accidentally set volume too high,  
**I want** to receive a warning before potentially harmful levels,  
**So that** I'm aware of the risk and can make an informed choice.

**Acceptance Criteria:**
- Given I increase volume above 70dB threshold, when the threshold is crossed, then a modal appears
- Given the warning modal appears, when I read it, then it explains hearing damage risks
- Given the warning modal appears, when I tap "I understand", then I can continue at high volume
- Given I dismissed a warning, when I lower and raise volume again, then warning shows again (not permanently dismissed)

**Story Points:** 3  
**Priority:** P0 (MVP)

---

### E3-S3: Baby Mode Volume Limits
**As a** new parent,  
**I want** a mode that limits maximum volume to safe levels for infants,  
**So that** I can confidently use the app near my baby.

**Acceptance Criteria:**
- Given I enable Baby Mode, when I try to increase volume, then it caps at 50dB equivalent
- Given Baby Mode is active, when I view the player, then a "Baby Safe" badge is visible
- Given I enable Baby Mode, when a tooltip appears, then it recommends placing device 7+ feet from crib
- Given Baby Mode is enabled, when I try to disable it, then I must confirm the action

**Story Points:** 3  
**Priority:** P2 (Phase 3)

---

### E3-S4: Distance Recommendations
**As a** parent or safety-conscious user,  
**I want** guidance on how far to place my device from the listener,  
**So that** I follow best practices for safe noise exposure.

**Acceptance Criteria:**
- Given I'm using Baby Mode, when I view settings, then I see "Place device at least 7 feet (2m) from baby"
- Given I'm viewing volume info, when I scroll down, then I see distance recommendations for different scenarios

**Story Points:** 2  
**Priority:** P2 (Phase 3)

---

## Epic 4: Personalization

### E4-S1: Onboarding Personalization Quiz ⭐ MVP
**As a** new user,  
**I want** to answer a few questions about my needs,  
**So that** the app can recommend the best noise type for me.

**Acceptance Criteria:**
- Given I am a first-time user, when I complete onboarding, then I am presented with a 5-question quiz
- Given I'm taking the quiz, when I answer each question, then I can go back to change previous answers
- Given I complete the quiz, when results are calculated, then I see a personalized recommendation with explanation
- Given I want to skip the quiz, when I tap "Skip", then I can proceed to the main app
- Given I skipped the quiz, when I go to settings later, then I can take it at any time

**Quiz Questions:**
1. What's your main goal? (Sleep / Focus / Both)
2. How noisy is your environment? (Quiet / Moderate / Noisy)
3. Do you experience any of these? (Difficulty concentrating / Racing thoughts / ADHD / Sound sensitivity / None)
4. What's your age range? (Under 30 / 30-50 / 50-65 / 65+)
5. Have you tried noise for sleep/focus before? (Yes-helped / Yes-didn't work / No)

**Story Points:** 8  
**Priority:** P0 (MVP)

---

### E4-S2: Personalized Noise Recommendation
**As a** user who completed the quiz,  
**I want** to receive a tailored noise type recommendation,  
**So that** I start with the option most likely to work for me.

**Acceptance Criteria:**
- Given I indicated ADHD or focus difficulties, when I see results, then brown noise is recommended with focus positioning
- Given I indicated I'm 60+ and want better sleep, when I see results, then pink noise is recommended with memory/deep sleep benefits
- Given I indicated high noise sensitivity, when I see results, then lower starting volume is recommended
- Given I see my recommendation, when I tap "Why this?", then I see scientific explanation

**Story Points:** 5  
**Priority:** P1 (Phase 2)

---

### E4-S3: Personalized Volume Defaults
**As a** user with specific characteristics,  
**I want** the app to suggest an appropriate starting volume,  
**So that** I don't have to guess what level is right for me.

**Acceptance Criteria:**
- Given I indicated ADHD traits, when I start playback, then volume defaults to 65dB range
- Given I indicated sound sensitivity, when I start playback, then volume defaults to 45dB range
- Given I indicated I'm 65+, when I start playback, then volume accounts for typical age-related hearing changes
- Given my defaults are set, when I manually adjust, then my preference is remembered for next session

**Story Points:** 3  
**Priority:** P1 (Phase 2)

---

### E4-S4: Retake Quiz
**As a** user whose needs have changed,  
**I want** to retake the personalization quiz,  
**So that** I can update my recommendations.

**Acceptance Criteria:**
- Given I go to Settings, when I tap "Retake Quiz", then I can complete the quiz again
- Given I retake the quiz, when I finish, then my new recommendations replace the old ones
- Given I retake the quiz, when recommendations change, then I see what's different from before

**Story Points:** 2  
**Priority:** P1 (Phase 2)

---

## Epic 5: Sleep Mode vs Focus Mode

### E5-S1: Mode Toggle
**As a** user who uses noise for both sleep and work,  
**I want** to quickly switch between Sleep Mode and Focus Mode,  
**So that** the app optimizes for my current context.

**Acceptance Criteria:**
- Given I open the app, when I view the main screen, then I see a Sleep/Focus mode toggle
- Given I select Sleep Mode, when I view the interface, then it uses darker colors and sleep-oriented defaults
- Given I select Focus Mode, when I view the interface, then it shows a minimal distraction-free design
- Given I switch modes, when I start playback, then noise type defaults to my preference for that mode

**Story Points:** 5  
**Priority:** P1 (Phase 2)

---

### E5-S2: Sleep Mode Defaults
**As a** user going to bed,  
**I want** Sleep Mode to be optimized for falling and staying asleep,  
**So that** I don't have to manually configure everything each night.

**Acceptance Criteria:**
- Given I'm in Sleep Mode, when I view timer options, then longer durations (4h, 8h) are prominently shown
- Given I'm in Sleep Mode, when I start playback, then screen dims automatically after 30 seconds
- Given I'm in Sleep Mode, when I view noise options, then pink noise is highlighted as "Best for deep sleep"

**Story Points:** 3  
**Priority:** P1 (Phase 2)

---

### E5-S3: Focus Mode Defaults
**As an** ADHD professional trying to work,  
**I want** Focus Mode to be optimized for concentration sessions,  
**So that** I can quickly start a productive work block.

**Acceptance Criteria:**
- Given I'm in Focus Mode, when I view timer options, then work-session durations (25m, 45m, 90m) are shown
- Given I'm in Focus Mode, when I view noise options, then brown noise is highlighted as "Popular for ADHD/focus"
- Given I'm in Focus Mode, when a timer completes, then I hear a gentle notification sound

**Story Points:** 3  
**Priority:** P1 (Phase 2)

---

### E5-S4: Focus Session Statistics
**As a** user tracking my productivity,  
**I want** to see how many focus sessions I've completed,  
**So that** I can monitor my habits over time.

**Acceptance Criteria:**
- Given I complete a Focus Mode session, when the timer ends, then the session is logged
- Given I go to Stats, when I view Focus stats, then I see total sessions, total time, and streak
- Given I view my stats, when I look at weekly view, then I see which days I used Focus Mode

**Story Points:** 5  
**Priority:** P2 (Phase 3) — Premium Feature

---

## Epic 6: Nature Sounds & Mixing

### E6-S1: Nature Sound Library
**As a** user who prefers natural sounds,  
**I want** access to nature sounds like rain and ocean waves,  
**So that** I can choose sounds that feel more organic.

**Acceptance Criteria:**
- Given I go to the sound library, when I browse, then I see at least 10 nature sounds
- Given I select "Rain", when it plays, then it sounds realistic without obvious loops
- Given I'm a free user, when I browse, then I have access to 3 free nature sounds
- Given I'm a premium user, when I browse, then all nature sounds are unlocked

**Nature sounds to include:**
- Rain (steady)
- Rain (thunderstorm)
- Ocean waves
- River/stream
- Wind through trees
- Campfire crackling
- Forest ambience
- Waterfall
- Night crickets
- Gentle thunder

**Story Points:** 8  
**Priority:** P1 (Phase 2)

---

### E6-S2: Sound Mixing
**As a** user who wants a custom soundscape,  
**I want** to layer multiple sounds together,  
**So that** I can create my perfect sleep or focus environment.

**Acceptance Criteria:**
- Given I'm on the mixer screen, when I select sounds, then I can add up to 3 sounds simultaneously
- Given I have multiple sounds selected, when I adjust individual volumes, then each sound's level changes independently
- Given I create a mix, when I tap "Save", then I can name and save it for later
- Given I'm a free user, when I try to mix, then I can only mix 2 sounds

**Story Points:** 8  
**Priority:** P1 (Phase 2) — Premium Feature for 3+ sounds

---

### E6-S3: Saved Mixes
**As a** user who found my perfect combination,  
**I want** to save my custom mixes,  
**So that** I can quickly access them in the future.

**Acceptance Criteria:**
- Given I create a mix, when I save it, then I can give it a custom name
- Given I have saved mixes, when I go to My Mixes, then I see all my saved combinations
- Given I view a saved mix, when I tap it, then playback starts with all sounds at saved levels
- Given I want to edit a mix, when I tap edit, then I can adjust sounds and resave

**Story Points:** 5  
**Priority:** P1 (Phase 2) — Premium Feature

---

### E6-S4: Frequency Customization Slider
**As a** power user,  
**I want** to adjust the frequency balance of my noise,  
**So that** I can fine-tune it to exactly what works for me.

**Acceptance Criteria:**
- Given I'm on the noise player, when I tap "Customize", then I see a frequency slider
- Given I move the slider left, when I listen, then sound becomes brighter (more white noise character)
- Given I move the slider right, when I listen, then sound becomes deeper (more brown noise character)
- Given I find a sweet spot, when I save it, then this becomes my default for that noise type

**Story Points:** 5  
**Priority:** P1 (Phase 2) — Premium Feature

---

## Epic 7: User Interface & Experience

### E7-S1: Dark Mode Interface ⭐ MVP
**As a** user going to sleep,  
**I want** a dark interface that doesn't strain my eyes,  
**So that** using the app at night doesn't wake me up.

**Acceptance Criteria:**
- Given I open the app at any time, when the interface loads, then it uses dark colors by default
- Given the app is in dark mode, when I view it in a dark room, then no bright elements cause eye strain
- Given I prefer light mode, when I go to settings, then I can switch to light theme

**Story Points:** 3  
**Priority:** P0 (MVP)

---

### E7-S2: Minimal Player Interface ⭐ MVP
**As a** user who just wants to sleep,  
**I want** a simple, uncluttered player screen,  
**So that** I can start noise playback with minimal effort.

**Acceptance Criteria:**
- Given I open the app, when the player loads, then I see noise options and play button prominently
- Given I view the player, when I count interactive elements, then there are no more than 5 primary actions visible
- Given I want to start noise, when I tap once on a noise type, then playback begins (single tap to play)

**Story Points:** 3  
**Priority:** P0 (MVP)

---

### E7-S3: Educational Tooltips ⭐ MVP
**As a** new user,  
**I want** to understand why different noise types exist,  
**So that** I can make informed choices about what to try.

**Acceptance Criteria:**
- Given I'm a new user viewing noise options, when I see each type, then there's an info icon next to it
- Given I tap the info icon for pink noise, when the tooltip appears, then I see "Best for deep sleep" with 1-2 sentence explanation
- Given I tap the info icon for brown noise, when the tooltip appears, then I see "Popular for ADHD & focus" with explanation
- Given I've seen a tooltip, when I view it again, then it shows "Don't show again" option

**Story Points:** 3  
**Priority:** P0 (MVP)

---

### E7-S4: Quick Start Widget (iOS)
**As an** iPhone user,  
**I want** a home screen widget to start noise quickly,  
**So that** I can begin playback without opening the app.

**Acceptance Criteria:**
- Given I add the widget to my home screen, when I view it, then I see my favorite noise type
- Given I tap the widget, when it activates, then noise begins playing immediately
- Given I long-press the widget, when options appear, then I can choose which noise type it triggers

**Story Points:** 5  
**Priority:** P2 (Phase 3)

---

### E7-S5: Siri/Voice Integration
**As a** user lying in bed,  
**I want** to start noise with my voice,  
**So that** I don't have to pick up my phone.

**Acceptance Criteria:**
- Given I say "Hey Siri, play brown noise on [App Name]", when Siri processes it, then brown noise begins playing
- Given I say "Hey Siri, stop [App Name]", when processed, then playback stops
- Given I say "Hey Siri, play my sleep sounds", when I've set a default, then my preferred noise plays

**Story Points:** 5  
**Priority:** P2 (Phase 3)

---

## Epic 8: Sleep Tracking & Insights

### E8-S1: Basic Sleep Session Logging
**As a** user curious about my habits,  
**I want** the app to track when I use it for sleep,  
**So that** I can see patterns over time.

**Acceptance Criteria:**
- Given I play noise in Sleep Mode for 4+ hours, when I wake up, then a sleep session is logged
- Given sessions are logged, when I view History, then I see date, duration, and noise type used
- Given I view my history, when I look at the last 7 days, then I see which nights I used the app

**Story Points:** 5  
**Priority:** P2 (Phase 3)

---

### E8-S2: Sleep Quality Check-In
**As a** user trying to optimize my sleep,  
**I want** to rate how I slept each morning,  
**So that** I can correlate noise settings with sleep quality.

**Acceptance Criteria:**
- Given I used the app for sleep, when I open it the next morning, then I see "How did you sleep?" prompt
- Given I see the prompt, when I rate my sleep (1-5 stars), then the rating is saved with that session
- Given I've rated multiple nights, when I view insights, then I see average rating by noise type
- Given I don't want to rate, when I dismiss the prompt, then it doesn't appear again that day

**Story Points:** 5  
**Priority:** P2 (Phase 3) — Premium Feature

---

### E8-S3: HealthKit Integration
**As an** Apple Watch user,  
**I want** my sleep data to sync with Apple Health,  
**So that** I have all my health data in one place.

**Acceptance Criteria:**
- Given I grant HealthKit permission, when I log a sleep session, then it syncs to Apple Health
- Given data is synced, when I view Apple Health, then I see sleep duration from the app
- Given I revoke permission, when future sessions occur, then they are not sent to HealthKit

**Story Points:** 5  
**Priority:** P2 (Phase 3)

---

### E8-S4: Personalized Recommendations Based on Data
**As a** long-term user,  
**I want** the app to learn what works best for me,  
**So that** I get smarter recommendations over time.

**Acceptance Criteria:**
- Given I've used the app 20+ times with ratings, when I view recommendations, then they're based on my data
- Given I rate sleep higher with pink noise, when I open Sleep Mode, then pink noise is suggested first
- Given my patterns change, when new data is collected, then recommendations update accordingly

**Story Points:** 8  
**Priority:** P3 (Future)

---

## Epic 9: Monetization & Premium

### E9-S1: Free Tier Access ⭐ MVP
**As a** free user,  
**I want** meaningful functionality without paying,  
**So that** I can evaluate if the app works for me before upgrading.

**Acceptance Criteria:**
- Given I'm a free user, when I use the app, then I have access to: white/pink/brown noise, basic timer (up to 2h), background playback, volume safety, personalization quiz, 3 nature sounds
- Given I'm a free user, when I encounter premium features, then I see clear indication they require upgrade
- Given I'm a free user, when I use the app, then I am never interrupted by audio ads during playback

**Story Points:** 3  
**Priority:** P0 (MVP)

---

### E9-S2: Premium Subscription
**As a** user who wants full features,  
**I want** to subscribe to premium,  
**So that** I can unlock advanced functionality.

**Acceptance Criteria:**
- Given I tap "Upgrade", when I view options, then I see monthly ($2.99) and annual ($19.99) plans
- Given I choose annual, when I subscribe, then I save 44% vs monthly
- Given I subscribe, when payment completes, then premium features unlock immediately
- Given I'm premium, when I view my account, then I see subscription status and renewal date

**Premium Features:**
- Unlimited timer options
- All nature sounds (20+)
- Sound mixing (3+ sounds)
- Frequency customization
- Sleep quality insights
- Unlimited saved mixes
- Priority support

**Story Points:** 8  
**Priority:** P1 (Phase 2)

---

### E9-S3: Lifetime Purchase Option
**As a** user who dislikes subscriptions,  
**I want** to pay once for permanent access,  
**So that** I don't have recurring charges.

**Acceptance Criteria:**
- Given I view upgrade options, when I scroll down, then I see "Lifetime Access" for $39.99
- Given I purchase lifetime, when payment completes, then I have permanent premium access
- Given I have lifetime access, when I check account, then it shows "Lifetime" instead of renewal date

**Story Points:** 3  
**Priority:** P1 (Phase 2)

---

### E9-S4: Free Trial
**As a** user unsure about premium,  
**I want** to try premium features for free,  
**So that** I can experience the value before paying.

**Acceptance Criteria:**
- Given I'm a new free user, when I view premium, then I see "Start 7-Day Free Trial" option
- Given I start a trial, when I use the app, then all premium features are unlocked
- Given my trial is active, when I view account, then I see days remaining
- Given my trial expires, when I open the app, then I'm prompted to subscribe or continue with free tier

**Story Points:** 5  
**Priority:** P1 (Phase 2)

---

## Epic 10: Onboarding & First-Time Experience

### E10-S1: Welcome Screens ⭐ MVP
**As a** first-time user,  
**I want** to understand what makes this app different,  
**So that** I know why I should use it over competitors.

**Acceptance Criteria:**
- Given I open the app for the first time, when onboarding starts, then I see 3-4 welcome screens
- Given I view welcome screens, when I read them, then key differentiators are highlighted (no loops, personalized, science-backed)
- Given I want to skip, when I tap "Skip", then I go directly to the main app
- Given I complete onboarding, when I open app again, then onboarding doesn't repeat

**Story Points:** 3  
**Priority:** P0 (MVP)

---

### E10-S2: Permission Requests with Context ⭐ MVP
**As a** user being asked for permissions,  
**I want** to understand why each permission is needed,  
**So that** I feel comfortable granting access.

**Acceptance Criteria:**
- Given the app needs notification permission, when asking, then I see "To remind you of bedtime routines"
- Given the app requests HealthKit, when asking, then I see "To sync sleep data with Apple Health"
- Given I deny a permission, when I continue, then the app works without that feature

**Story Points:** 2  
**Priority:** P0 (MVP)

---

### E10-S3: First Play Celebration
**As a** new user who just started noise for the first time,  
**I want** positive reinforcement,  
**So that** I feel good about using the app.

**Acceptance Criteria:**
- Given it's my first time playing noise, when playback starts, then I see a brief celebratory animation
- Given I see the celebration, when it completes, then it fades out without interrupting the experience
- Given I've played noise before, when I play again, then no celebration appears

**Story Points:** 2  
**Priority:** P1 (Phase 2)

---

## Story Summary by Phase

### MVP (Phase 1) — 14 Stories
| ID | Story | Points |
|----|-------|--------|
| E1-S1 | White Noise Playback | 5 |
| E1-S2 | Pink Noise Playback | 5 |
| E1-S3 | Brown Noise Playback | 5 |
| E1-S4 | Real-Time Generation | 8 |
| E2-S1 | Background Audio | 5 |
| E2-S2 | Sleep Timer with Fade | 5 |
| E2-S5 | Lock Screen Controls | 3 |
| E3-S1 | Volume Safety Indicator | 5 |
| E3-S2 | Volume Warning Modal | 3 |
| E4-S1 | Personalization Quiz | 8 |
| E7-S1 | Dark Mode Interface | 3 |
| E7-S2 | Minimal Player Interface | 3 |
| E7-S3 | Educational Tooltips | 3 |
| E9-S1 | Free Tier Access | 3 |
| E10-S1 | Welcome Screens | 3 |
| E10-S2 | Permission Requests | 2 |
| **Total** | | **69 pts** |

### Phase 2 — 15 Stories
| ID | Story | Points |
|----|-------|--------|
| E1-S5 | Seamless Noise Switching | 3 |
| E2-S3 | Custom Timer Duration | 3 |
| E4-S2 | Personalized Recommendation | 5 |
| E4-S3 | Personalized Volume Defaults | 3 |
| E4-S4 | Retake Quiz | 2 |
| E5-S1 | Mode Toggle | 5 |
| E5-S2 | Sleep Mode Defaults | 3 |
| E5-S3 | Focus Mode Defaults | 3 |
| E6-S1 | Nature Sound Library | 8 |
| E6-S2 | Sound Mixing | 8 |
| E6-S3 | Saved Mixes | 5 |
| E6-S4 | Frequency Slider | 5 |
| E9-S2 | Premium Subscription | 8 |
| E9-S3 | Lifetime Purchase | 3 |
| E9-S4 | Free Trial | 5 |
| E10-S3 | First Play Celebration | 2 |
| **Total** | | **71 pts** |

### Phase 3 — 10 Stories
| ID | Story | Points |
|----|-------|--------|
| E2-S4 | Adjustable Fade Duration | 2 |
| E3-S3 | Baby Mode Volume Limits | 3 |
| E3-S4 | Distance Recommendations | 2 |
| E5-S4 | Focus Session Statistics | 5 |
| E7-S4 | Quick Start Widget | 5 |
| E7-S5 | Siri/Voice Integration | 5 |
| E8-S1 | Sleep Session Logging | 5 |
| E8-S2 | Sleep Quality Check-In | 5 |
| E8-S3 | HealthKit Integration | 5 |
| **Total** | | **37 pts** |

### Future (Phase 4+) — 1 Story
| ID | Story | Points |
|----|-------|--------|
| E8-S4 | Personalized Recommendations | 8 |
| **Total** | | **8 pts** |

---

## Appendix: Acceptance Criteria Glossary

- **dB (decibels):** Unit of sound measurement; 50dB ≈ quiet conversation, 70dB ≈ vacuum cleaner
- **Crossfade:** Audio transition technique where one sound fades out while another fades in
- **PCM (Pulse-Code Modulation):** Digital audio format used for real-time sound generation
- **Sleep Mode:** App configuration optimized for nighttime use (longer timers, darker UI)
- **Focus Mode:** App configuration optimized for concentration (shorter sessions, minimal UI)

---

*Document Version: 1.0*  
*Last Updated: November 2025*  
*Total Stories: 40*  
*Total Story Points: 185*
