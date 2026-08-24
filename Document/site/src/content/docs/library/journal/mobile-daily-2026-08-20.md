---
title: 'HealthStride: mobile daily 2026 08 20'
description: 'Nhật ký và tài liệu tham chiếu của dự án HealthStride.'
---
# Mobile Daily Record - 20 August 2026

## Mục tiêu

Ghi lại evidence Mobile cho Task 4 Dashboard/Home và xác nhận khả năng chạy local integration trên thiết bị giả lập.

## Hoàn thành

- Kiểm tra trạng thái thiết bị có thể dùng cho `flutter run`.
- Đối chiếu điều kiện cần cho manual integration theo brief: local API, iOS simulator hoặc Android emulator, và Google sign-in end-to-end.
- Bổ sung `android:usesCleartextTraffic="true"` chỉ trong `App/android/app/src/debug/AndroidManifest.xml` để Android debug có thể gọi FastAPI host qua `http://10.0.2.2:8000`; manifest `main`/release không bật cleartext.
- Bổ sung regression test cho timeout 15 giây, failure boundary, lifecycle/race của `HomeController`, và layout phone `390x844`.

## Evidence

- `flutter devices`
  - Kết quả chỉ có:
    - `macOS (desktop)`
    - `Chrome (web)`
- `xcrun simctl list devices booted`
  - Kết quả không có iOS simulator nào đang boot.
- `adb devices`
  - Kết quả không có Android emulator/device nào attached.
- Focused Flutter regression suite cho network, controller và Home screen:
  - Kết quả: `24` test pass.
- Full Mobile gate:
  - `flutter analyze`: `No issues found!`
  - `flutter test`: `40` test pass.
  - `flutter build ios --simulator --debug --dart-define=API_BASE_URL=https://example.com`: tạo `build/ios/iphonesimulator/Runner.app`.
  - `flutter build apk --debug`: tạo `build/app/outputs/flutter-apk/app-debug.apk`.
  - Merged Android debug manifest có `android:usesCleartextTraffic="true"`.
- `https://example.com` chỉ được dùng làm URL xác minh compile/build cho `--dart-define`; đây không phải URL Backend local và không phải evidence cho integration trên simulator.

## Bài học

Android 9 trở lên chặn cleartext theo mặc định, nên URL host emulator `http://10.0.2.2:8000` cần opt-in dành riêng cho debug. Environment hiện tại đủ để chạy test và build, nhưng chưa đủ để xác minh manual Dashboard/Home flow trên iOS/Android simulator như brief yêu cầu.

## Rủi ro hoặc blocker

- Không có iOS simulator đang chạy.
- Không có Android emulator/device đang attach.
- Backend local không có Firebase credentials được cấu hình sẵn, nên kể cả khi mở được app vẫn chưa có evidence thật cho Google sign-in end-to-end trong record này.

## Hành động tiếp theo

Boot một iOS simulator hoặc Android emulator và cung cấp Firebase local credentials hợp lệ. Với Android emulator, chạy `flutter run --debug --dart-define=API_BASE_URL=http://10.0.2.2:8000`, đăng nhập Google, rồi xác minh Dashboard và pull-to-refresh bằng evidence thật.
