---
title: 'HealthStride: android emulator recovery plan'
description: 'Nhật ký và tài liệu tham chiếu của dự án HealthStride.'
---
# Android Emulator Recovery Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Establish a stable, clickable Android emulator inside Android Studio and run the Flutter application with hot reload on the M1 Mac.

**Architecture:** Android Studio owns the emulator UI through `Running Devices`; the existing ARM64 `Fitness_API_35` AVD provides Android, ADB provides transport, and Flutter provides build/debug tooling. Standalone QEMU and scrcpy windows are excluded from the primary path.

**Tech Stack:** macOS 26.6 on Apple Silicon M1, Android Studio 2026.1.3.7, Android Emulator 37.1.11, Android 15/API 35 ARM64 AVD, Flutter 3.44.9, Dart 3.12.2, ADB.

## Global Constraints

- Keep the existing `Fitness_API_35` ARM64 AVD and installed SDK versions.
- Do not modify Flutter application source code.
- Do not delete AVD data, system images, crash reports, or user files.
- Stop only the known `com.fitness.android.headless` launch agent and its emulator process.
- Treat the embedded emulator as successful only after click, input, ADB, Flutter launch, and hot reload checks pass.
- Use the scrcpy `.app` fallback only if Android Studio's embedded emulator fails its interaction check.

---

### Task 1: Capture Baseline and Release the AVD

**Files:**
- Read: `App/pubspec.yaml`
- Read: `~/Library/LaunchAgents/com.fitness.android.headless.plist` if present
- Create: none
- Modify: none

**Interfaces:**
- Consumes: the installed `Fitness_API_35` AVD and current launch-agent state
- Produces: an unlocked AVD with baseline command output retained in the session

- [ ] **Step 1: Record current device and emulator state**

Run:

```bash
flutter emulators
flutter devices
adb devices -l
pgrep -afil 'emulator|qemu-system|scrcpy'
launchctl print "gui/$(id -u)/com.fitness.android.headless"
```

Expected: `Fitness_API_35` is listed; the existing headless Android emulator may appear as `emulator-5554`; the launch-agent command identifies only the known headless job.

- [ ] **Step 2: Stop the known headless launch agent**

Run:

```bash
launchctl bootout "gui/$(id -u)/com.fitness.android.headless"
```

Expected: the job exits. If launchctl reports that the service is not loaded, continue because the desired state is already satisfied.

- [ ] **Step 3: Wait for the old emulator transport to disappear**

Run:

```bash
for attempt in {1..20}; do
  adb devices | grep -q '^emulator-' || break
  sleep 1
done
adb devices -l
pgrep -afil 'emulator.*Fitness_API_35|qemu-system-aarch64'
```

Expected: no online instance of `Fitness_API_35` and no matching QEMU process remain. Do not kill unrelated Android Studio processes.

- [ ] **Step 4: Confirm the AVD is no longer locked**

Run:

```bash
find "$HOME/.android/avd/Fitness_API_35.avd" -maxdepth 1 -name '*.lock' -print
```

Expected: no active lock files are reported. Stale lock files may be removed only after confirming no emulator/QEMU process exists.

### Task 2: Configure Android Studio Embedded Emulator

**Files:**
- Read: Android Studio preferences under `~/Library/Application Support/Google/AndroidStudio*`
- Create: none
- Modify: Android Studio emulator preference through the Settings UI

**Interfaces:**
- Consumes: the unlocked `Fitness_API_35` AVD from Task 1
- Produces: a booted AVD displayed inside Android Studio's `Running Devices` panel

- [ ] **Step 1: Open the Flutter project's Android module**

Run:

```bash
open -a "Android Studio" "/Users/macbook_191/Documents/Workspace/Mobile/Fitness Application/App/android"
```

Expected: Android Studio opens the Android module and completes project loading without changing Flutter source files.

- [ ] **Step 2: Enable embedded emulator launch**

In Android Studio, open `Settings > Tools > Emulator`, enable `Launch in the Running Devices tool window`, and apply the setting.

Expected: Android Studio is configured to host emulator rendering in its signed application window.

- [ ] **Step 3: Launch the existing ARM64 AVD**

In `Tools > Device Manager`, locate `Fitness_API_35` and click its Run icon exactly once.

Expected: Android Studio opens `View > Tool Windows > Running Devices` and displays the Android boot screen there. Do not run `emulator -avd` separately.

- [ ] **Step 4: Verify window lifecycle and input**

Click inside the embedded screen at least five times, unlock Android if needed, open Settings, return Home, and type into any available text field.

Expected: the panel remains visible, clicks do not terminate the emulator, and Android responds to pointer and keyboard input.

### Task 3: Verify ADB and Flutter Debugging

**Files:**
- Read: `App/lib/main.dart`
- Create: none
- Modify: none

**Interfaces:**
- Consumes: the interactive embedded emulator from Task 2
- Produces: a running debug build of `Hello Application` attached to Flutter tooling

- [ ] **Step 1: Verify Android boot and ADB transport**

Run:

```bash
adb devices -l
adb shell getprop sys.boot_completed
adb shell getprop ro.product.cpu.abi
```

Expected: one emulator is in `device` state, `sys.boot_completed` is `1`, and the ABI is `arm64-v8a`.

- [ ] **Step 2: Verify Flutter device discovery**

Run:

```bash
flutter devices
```

Expected: Flutter lists the Android emulator with an ID such as `emulator-5554`; use the exact reported ID in later commands.

- [ ] **Step 3: Run the Flutter application**

Run from `App`:

```bash
flutter run -d emulator-5554
```

Expected: Flutter builds and installs a debug APK, attaches the Dart VM service, and the embedded emulator displays `Hello Application`.

- [ ] **Step 4: Verify hot reload without modifying source**

With `flutter run` attached, press:

```text
r
```

Expected: Flutter prints `Reloaded` and the application remains running. This verifies the hot-reload channel without introducing a source change.

- [ ] **Step 5: Verify final stability**

Interact with the app for at least 60 seconds, switch between Android Studio tool windows, return to `Running Devices`, and click the emulator repeatedly.

Expected: the emulator remains connected, the display remains interactive, and `flutter run` remains attached.

### Task 4: Disable the Obsolete Automatic Headless Workflow

**Files:**
- Read: `~/Library/LaunchAgents/com.fitness.android.headless.plist`
- Modify: none unless explicit user approval is given to delete or archive the launch-agent file

**Interfaces:**
- Consumes: successful verification from Task 3
- Produces: a documented normal startup workflow without automatic AVD lock conflicts

- [ ] **Step 1: Confirm the launch agent stays unloaded**

Run:

```bash
launchctl print "gui/$(id -u)/com.fitness.android.headless"
```

Expected: launchctl reports that the service cannot be found.

- [ ] **Step 2: Preserve the plist but prevent automatic loading**

Leave `~/Library/LaunchAgents/com.fitness.android.headless.plist` on disk for diagnostic history. Do not bootstrap it again.

Expected: future emulator sessions are started from Android Studio Device Manager and cannot conflict with an automatically started copy of the same AVD.

- [ ] **Step 3: Record the normal developer commands**

Normal workflow after Android Studio has booted the AVD:

```bash
cd "/Users/macbook_191/Documents/Workspace/Mobile/Fitness Application/App"
flutter devices
flutter run -d emulator-5554
```

Expected: the device ID is confirmed before launch; if Android assigns a different port, replace `emulator-5554` with the ID printed by `flutter devices`.

### Task 5: Execute the Fallback Only After Embedded Failure

**Files:**
- Create only on fallback: `~/Applications/Fitness Android Screen.app/Contents/Info.plist`
- Create only on fallback: `~/Applications/Fitness Android Screen.app/Contents/MacOS/FitnessAndroidScreen`
- Copy only on fallback: scrcpy executable and required server asset into the app bundle

**Interfaces:**
- Consumes: a reproducible Task 2 failure with Android Studio's embedded panel
- Produces: a signed macOS app bundle that displays the already-running emulator

- [ ] **Step 1: Gate fallback execution**

Do not execute this task when Tasks 2 and 3 pass. If Task 2 fails, preserve Android Studio logs and confirm the emulator remains online in `adb devices -l` before proceeding.

- [ ] **Step 2: Build a proper macOS app bundle**

Create `Info.plist` with this exact content:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>CFBundleDevelopmentRegion</key>
  <string>en</string>
  <key>CFBundleExecutable</key>
  <string>FitnessAndroidScreen</string>
  <key>CFBundleIdentifier</key>
  <string>local.fitness.android-screen</string>
  <key>CFBundleInfoDictionaryVersion</key>
  <string>6.0</string>
  <key>CFBundleName</key>
  <string>Fitness Android Screen</string>
  <key>CFBundlePackageType</key>
  <string>APPL</string>
  <key>CFBundleShortVersionString</key>
  <string>1.0.0</string>
  <key>CFBundleVersion</key>
  <string>1</string>
  <key>LSMinimumSystemVersion</key>
  <string>13.0</string>
</dict>
</plist>
```

Create `Contents/MacOS/FitnessAndroidScreen` with this exact content:

```bash
#!/bin/zsh
set -eu
CONTENTS_DIR="${0:A:h:h}"
export ADB="$HOME/Library/Android/sdk/platform-tools/adb"
export SCRCPY_SERVER_PATH="$CONTENTS_DIR/Resources/scrcpy-server"
exec "$CONTENTS_DIR/MacOS/scrcpy" --serial emulator-5554
```

Copy the scrcpy 4.1 ARM64 executable to `Contents/MacOS/scrcpy`, copy its matching server to `Contents/Resources/scrcpy-server`, mark both executables in `Contents/MacOS` executable, then run:

```bash
plutil -lint "$HOME/Applications/Fitness Android Screen.app/Contents/Info.plist"
codesign --force --deep --sign - "$HOME/Applications/Fitness Android Screen.app"
codesign --verify --deep --strict "$HOME/Applications/Fitness Android Screen.app"
```

Expected: `plutil -lint` passes for `Info.plist`, and `codesign --verify --deep --strict` passes after ad-hoc signing.

- [ ] **Step 3: Verify LaunchServices ownership**

Run:

```bash
open "$HOME/Applications/Fitness Android Screen.app"
```

Expected: macOS launches the app through LaunchServices, the process has bundle identifier `local.fitness.android-screen`, and clicking the window no longer produces `SDL_EVENT_QUIT`.

- [ ] **Step 4: Repeat the interaction and Flutter checks**

Repeat Task 3 against the same online emulator.

Expected: app display, click interaction, ADB connection, Flutter launch, and hot reload all remain stable.

## Completion Criteria

The recovery is complete when Task 3 passes using the embedded emulator. Task 5 is unnecessary unless Task 2 reproducibly fails. No source commit is required because this plan changes local development tooling rather than application code, and the workspace currently has no Git repository.
