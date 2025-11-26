# Tonic App - Bug Report & Testing Results

**Test Date:** 2025-11-26
**Device:** iPhone 17 Pro Simulator (iOS 26.0)
**App Version:** 1.0.0

---

## Testing Summary

| Feature | Status | Notes |
|---------|--------|-------|
| Counter Screen | ✅ Pass | Displays tonic, timer, controls |
| Tap to Dispense | ✅ Pass | Starts playback, timer counts down |
| Tap to Cap (Stop) | ✅ Pass | Stops playback, timer resets |
| Tonic Selection | ✅ Pass | Selection panel shows, "Use This" works |
| Botanical Selection | ✅ Pass | Selection panel shows correctly |
| Tab Navigation | ✅ Pass | Counter, Dispensary, Lab Notes work |
| Strength Slider | ✅ Pass | 0-100%, updates safety indicator |
| Safety Indicator | ✅ Pass | Green/Orange/Red based on strength |
| Lab Notes Screen | ✅ Pass | Shows version, actions, credits |
| Session Persistence | ✅ Pass | Sessions saved to storage |
| Dosage Selector | ✅ Pass | Visible without scrolling |

---

## Bugs Fixed During Development

### 1. ✅ PCM Audio Crash on Tonic Selection
**File:** `lib/core/audio/services/tonic_audio_service.dart`
**Issue:** App crashed with "must call setup first" when selecting a tonic.
**Fix:** Reordered `_stopPlayback()` and `_initializeAudio()` calls.

### 2. ✅ Blank Screen on "Use This" Button
**File:** `lib/features/dispensary/dispensary_screen.dart`
**Issue:** Navigator.pop() on non-pushed screen caused blank screen.
**Fix:** Changed to `AppShell.switchTab(context, 0)`.

### 3. ✅ Multiple Tonics Showing "SELECTED"
**File:** `lib/features/dispensary/dispensary_screen.dart`
**Issue:** Both highlighted and previously selected items showed SELECTED.
**Fix:** Changed `isSelected` to only use highlighted state.

### 4. ✅ Excessive Console Logging
**Files:** Multiple providers and services
**Issue:** Hundreds of `[PCM] invoke: feed` logs per second.
**Fix:**
- Removed all `print()` statements from app code
- Added `FlutterPcmSound.setLogLevel(LogLevel.none)`

### 5. ✅ Session History Not Persisted
**File:** `lib/core/audio/services/tonic_audio_service.dart`
**Issue:** Sessions created but not saved to storage.
**Fix:** Added `StorageService` dependency and call to `storageService.recordSession()`.

### 6. ✅ Dosage Selector Below the Fold
**Files:** `counter_screen.dart`, `tonic_bottle.dart`, `timer_display.dart`
**Issue:** Dosage selector required scrolling to see.
**Fix:** Reduced spacing and component sizes to fit all controls on screen.

---

## Known Limitations (Not Bugs)

### ⚠️ Botanical Playback Not Implemented
**File:** `lib/core/audio/services/tonic_audio_service.dart:134`
**Status:** Feature not yet implemented
**Reason:** Botanicals require audio file playback (rain, ocean, forest sounds), not PCM generation. Implementation needs:
- Audio asset files added to project
- Audio player package (e.g., `just_audio`)
- File-based playback in `dispenseBotanical()`

**Impact:** Selecting a botanical shows UI but no sound plays.

---

## UI/UX Observations

1. **Positive:** Clean, consistent apothecary theme throughout
2. **Positive:** Safety indicator provides good feedback on volume levels
3. **Positive:** Smooth tab navigation with highlighted states
4. **Positive:** Selection panel shows relevant tonic/botanical details
5. **Minor:** No haptic feedback when tapping dispense button
6. **Minor:** No loading indicator when audio is initializing

---

## Test Screenshots

| Screenshot | Description |
|------------|-------------|
| test-01-current-state.png | Counter screen initial state |
| test-02-playing.png | Playback active (29:51 remaining) |
| test-03-capped.png | After stopping playback |
| test-04-dispensary.png | Dispensary tonics grid |
| test-06-rest-tapped.png | Rest tonic selected with panel |
| test-08-use-this-correct.png | After "Use This" - Counter with Rest |
| test-09-botanicals.png | Botanicals tab |
| test-10-ocean.png | Ocean botanical selected |
| test-11-lab-notes.png | Lab Notes/Settings screen |
| test-13-slider-high.png | Strength at 100% with warning |

---

## Recommendations for Future Testing

1. **Background Audio:** Lock device while playing, verify audio continues
2. **Phone Interruption:** Test incoming call handling during playback
3. **Memory Usage:** Run playback for 30+ minutes, monitor for leaks
4. **Rapid Actions:** Quick tonic switching to test stability
5. **Edge Cases:** Test with device on low battery, low storage

---

*Generated from iOS Simulator testing session - 2025-11-26*
*Updated after bug fixes*
