---
title: 'Khắc phục Android Emulator trên Apple Silicon'
description: 'Phân tích nguyên nhân và phương án khắc phục Android Emulator không hiển thị.'
---
# Khắc phục Android Emulator trên Apple Silicon

Đây là lúc mình mới chuyển sang máy Apple Silicon và Android Emulator đột nhiên không mở lên được nữa — build Flutter vẫn chạy, chỉ là không nhìn thấy màn hình. Ghi lại đây cách mình khoanh vùng nguyên nhân trước khi sửa, để lần sau gặp lại không phải dò lại từ đầu.

## Bối cảnh

Thiết bị ảo Android trên Apple Silicon khởi động thành công và `adb` nhìn thấy được, nhưng màn hình hiển thị dạng standalone thì không dùng được:

- Tiến trình Android Emulator standalone crash trong lúc Qt render dialog xác nhận crash.
- File thực thi `scrcpy` standalone nhận `SDL_EVENT_QUIT` ngay khi cửa sổ được kích hoạt.
- Đổi API level Android, snapshot và GPU backend đều không sửa được lỗi vòng đời cửa sổ.

Điều này khoanh vùng được vấn đề nằm ở các tiến trình hiển thị standalone trên macOS, chứ không phải ở image Android ARM64, ứng dụng Flutter, hay kết nối ADB.

## Mục tiêu

Có một vòng lặp phát triển Flutter local ổn định trên máy M1:

1. Khởi chạy một thiết bị ảo Android.
2. Giữ màn hình mở và tương tác được sau khi click vào nó.
3. Nhận diện thiết bị qua cả ADB lẫn Flutter.
4. Chạy ứng dụng Flutter với hot reload và hỗ trợ debugger.

## Kiến trúc

Android Studio sẽ đảm nhiệm giao diện emulator thông qua panel `Running Devices` tích hợp sẵn. AVD `Fitness_API_35` ARM64 hiện có vẫn là runtime Android. ADB vẫn là transport thiết bị, Flutter vẫn build, install, launch và debug ứng dụng như bình thường.

Luồng bình thường là:

```text
Android Studio -> emulator tích hợp -> ADB -> Flutter tool -> Flutter app
```

Cửa sổ QEMU standalone và file thực thi `scrcpy` trần hiện tại bị loại khỏi luồng làm việc chính, vì vòng đời cửa sổ macOS của chúng chính là thành phần đang lỗi.

## Cấu hình

- Bật tính năng khởi chạy emulator tool trong Android Studio.
- Khởi chạy `Fitness_API_35` từ Device Manager.
- Xác nhận thiết bị xuất hiện trong tool window `Running Devices`.
- Dừng launch agent headless hiện có khi nó xung đột với việc Android Studio đang giữ cùng một AVD.
- Giữ nguyên phiên bản Android SDK, system image ARM64 và Flutter SDK hiện có.
- Không sửa source code ứng dụng Flutter cho lần khắc phục này.

## Kiểm chứng

Phương án chính chỉ được coi là thành công khi mọi bước sau đều đạt:

1. Màn hình Android tích hợp vẫn hiển thị sau nhiều lần click và nhập liệu.
2. Android khởi động xong và nhận input.
3. `adb devices` báo cáo emulator ở trạng thái `device`.
4. `flutter devices` liệt kê được Android emulator.
5. `flutter run` chạy được `Hello Application` trên emulator đó.
6. Một thay đổi trong source Dart áp dụng được bằng Flutter hot reload.

## Xử lý lỗi

- Nếu AVD đã bị khoá, chỉ dừng đúng job emulator headless đã biết rồi thử lại từ Android Studio.
- Nếu Android Studio không hiển thị panel tích hợp, kiểm tra lại cấu hình emulator của nó và khởi động lại Android Studio trước khi đổi AVD.
- Nếu ADB bị treo/cũ, restart ADB server rồi kiểm tra lại trạng thái thiết bị.
- Giữ lại crash report và log lệnh đã dùng để chẩn đoán.

## Phương án dự phòng

Nếu emulator tích hợp của Android Studio cũng thoát hoặc không nhận input, đóng gói `scrcpy` thành một `.app` bundle macOS đúng chuẩn, có bundle identifier, `Info.plist`, resource và ad-hoc signing. Phương án dự phòng này sẽ được test riêng trước khi thay thế luồng làm việc chính.

## Không thuộc phạm vi

- Build lại Android Emulator hoặc scrcpy từ source.
- Thay đổi UI hoặc kiến trúc ứng dụng Flutter.
- Thêm tính năng cho Backend hoặc Document.
- Hỗ trợ system image Android Intel trên Apple Silicon.
