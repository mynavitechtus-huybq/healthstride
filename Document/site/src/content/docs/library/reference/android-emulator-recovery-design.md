---
title: 'HealthStride: android emulator recovery design'
description: 'Nhật ký và tài liệu tham chiếu của dự án HealthStride.'
---
# Android Emulator Recovery Design

## Context

The Apple Silicon Android virtual device boots successfully and is visible to
`adb`, but its standalone display is unusable:

- The standalone Android Emulator process crashes while Qt renders the crash
  consent dialog.
- The standalone `scrcpy` executable receives `SDL_EVENT_QUIT` when its window
  is activated.
- Changing Android API level, snapshots, and GPU backends has not corrected the
  window lifecycle failure.

This isolates the problem to the standalone macOS display processes rather than
the ARM64 Android image, Flutter application, or ADB connection.

## Goal

Provide a stable local Flutter development loop on the M1 Mac:

1. Launch an Android virtual device.
2. Keep its display open and interactive after clicking it.
3. Detect the device through both ADB and Flutter.
4. Run the Flutter application with hot reload and debugger support.

## Architecture

Android Studio will own the emulator user interface through its embedded
`Running Devices` panel. The existing ARM64 `Fitness_API_35` AVD remains the
Android runtime. ADB remains the device transport, and Flutter continues to
build, install, launch, and debug the application.

The normal flow is:

```text
Android Studio -> embedded emulator -> ADB -> Flutter tool -> Flutter app
```

Standalone QEMU windows and the current naked `scrcpy` executable are excluded
from the primary workflow because their macOS window lifecycle is the failing
component.

## Configuration

- Enable launching emulator tools inside Android Studio.
- Launch `Fitness_API_35` from Device Manager.
- Confirm the device appears in the `Running Devices` tool window.
- Stop the existing headless launch agent when it conflicts with Android
  Studio's ownership of the same AVD.
- Keep the existing Android SDK, ARM64 system image, and Flutter SDK versions.
- Do not modify Flutter application source code for this recovery.

## Verification

The primary approach is successful only when all checks pass:

1. The embedded Android screen remains visible after repeated clicks and input.
2. Android finishes booting and accepts input.
3. `adb devices` reports the emulator as `device`.
4. `flutter devices` lists the Android emulator.
5. `flutter run` launches `Hello Application` on that emulator.
6. A Dart source edit can be applied with Flutter hot reload.

## Error Handling

- If the AVD is already locked, stop only the known headless emulator job and
  retry from Android Studio.
- If Android Studio does not show an embedded panel, verify its emulator setting
  and restart Android Studio before changing the AVD.
- If ADB is stale, restart the ADB server and re-check the device state.
- Preserve crash reports and command logs used for diagnosis.

## Fallback

If Android Studio's embedded emulator also exits or cannot accept input, package
`scrcpy` as a proper macOS `.app` bundle with a bundle identifier, `Info.plist`,
resources, and ad-hoc signing. That fallback will be tested independently before
it replaces the primary workflow.

## Non-Goals

- Rebuilding the Android Emulator or scrcpy from source.
- Changing the Flutter UI or application architecture.
- Adding Backend or Document application features.
- Supporting Intel Android system images on Apple Silicon.
