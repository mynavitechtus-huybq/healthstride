---
title: 'HealthStride: welcome theme vlog'
description: 'Nhật ký và tài liệu tham chiếu của dự án HealthStride.'
---
# Nhật ký xây dựng: Welcome và Theme đa chế độ

> **Ngày:** 20/08/2026  
> **Feature:** Welcome/Onboarding và đổi theme trong app  
> **Branch:** `feat/welcome-theme`

## Mobile

### Hôm nay đã làm gì?

- Đọc node Welcome `1:604` trong Figma và chuyển bố cục sang Flutter.
- Thêm 3 fake onboarding slides để có thể swipe qua trong lúc Backend chưa cần cung cấp dữ liệu onboarding.
- Thêm ảnh fitness, lớp chuyển màu ở đáy ảnh, indicator, tiêu đề và nút `Next`/`Get Started` theo từng slide.
- Chuyển flow chưa đăng nhập thành `Welcome -> Continue with Google`.
- Bổ sung ba lựa chọn giao diện: `Light`, `Dark`, `System`.
- Lưu lựa chọn theme bằng `shared_preferences` và áp dụng tức thời qua `ThemeMode`.
- Đưa theme picker lên cả Welcome và Dashboard để người dùng không cần logout mới đổi được giao diện.
- Thay icon đăng nhập bằng logo Google asset và icon đăng xuất bằng `logout_rounded`.
- Chuyển các card Home từ màu cố định sang semantic surface của Material 3 để light/dark hiển thị đúng.

### Tôi đã làm như thế nào?

1. Viết test trước cho `ThemeController`, `WelcomeScreen`, ba mode theme và flow `Get Started`.
2. Tạo `ThemeController` nhận `SharedPreferences`, khôi phục mode đã lưu và phát thông báo khi mode thay đổi.
3. Tách `ThemeModePickerButton` dùng chung cho Welcome và Home.
4. Tách `AppTheme.light()` và giữ `AppTheme.dark()` cùng dùng chung typography Lato và design tokens.
5. Dùng asset ảnh lấy từ Figma, không nhúng URL tạm thời vào runtime.
6. Dùng `PageView` và `PageController` để đồng bộ swipe, nút `Next`, indicator và slide hiện tại.

### Khó khăn gặp phải

- Firebase Auth giữ session trên Simulator nên app mở thẳng Dashboard, không hiển thị Welcome sau khi build lại.
- Một số card Home đang dùng `AppColors.neutral800` cố định; khi bật light theme, nền card vẫn tối và độ tương phản không phù hợp.
- Test cũ giả định AuthGate mở thẳng nút Google, trong khi flow mới có thêm bước Welcome.

### Cách tháo gỡ

- Kiểm tra log Flutter và trạng thái simulator thay vì kết luận từ ảnh màn hình.
- Dùng semantic colors `surfaceContainer` và `surfaceContainerHighest` cho các surface phụ thuộc theme.
- Cập nhật test theo hành vi mới: kiểm tra `Get Started`, sau đó mới kiểm tra `Continue with Google`.
- Xóa app khỏi Simulator trước khi chạy lại để kiểm tra trạng thái khởi đầu.

### Sự cố khi kiểm tra carousel

Sau khi push carousel, Simulator vẫn hiển thị Welcome phiên bản cũ với nút `Get Started`. Mình kiểm tra screenshot và tiến trình hệ thống, phát hiện không còn tiến trình `flutter run` attach vào iPhone 17. Simulator chỉ đang giữ app instance cũ, nên source mới chưa được build/cài lại.

Cách xử lý:

```bash
cd App
flutter run -d FEC1792F-0FEE-47E7-BA03-D53D3076E41B \
  --dart-define=API_BASE_URL=http://127.0.0.1:8000
```

Sau khi chạy lại, màn hình đã hiển thị đúng `Next`, indicator 3 slide và có thể swipe qua từng onboarding slide trên iPhone 17.

### Tôi học được gì?

- Theme không chỉ là đổi `scaffoldBackgroundColor`; mọi card, icon container, border và text phụ đều phải dùng semantic role.
- Auth state và app state có vòng đời khác nhau; gỡ app chưa chắc xóa được session Firebase trên iOS Keychain.
- Test UI theo hành vi giúp phát hiện contract cũ bị thay đổi khi thêm một màn hình vào flow.
- Asset từ công cụ thiết kế cần được tải về và quản lý trong repo để tránh phụ thuộc URL có thời hạn.
- Fake data ở presentation layer giúp hoàn thiện trải nghiệm và kiểm thử gesture trước khi có API thật.
- Một screenshot cũ không đủ để kết luận source mới chưa hoạt động; cần xác minh cả process `flutter run`, build timestamp và device đang được attach.

## Backend

### Hôm nay đã làm gì?

- Không thay đổi API, schema, Redis hoặc Firebase Admin verifier.
- Giữ nguyên contract đăng nhập và endpoint Dashboard để thay đổi Welcome/Theme chỉ nằm ở Mobile.

### Kiểm tra

- FastAPI `/health` vẫn trả `200 OK` với envelope `{ data, meta, error }`.
- Flutter analyzer: không có issue.
- Flutter tests: `45` tests passed.
- iOS Simulator `iPhone 17`: build, cài đặt và chạy debug thành công.

### Bài học Backend

- Khi feature chỉ thay đổi presentation layer, cần xác nhận rõ API contract không bị kéo theo thay đổi ngoài phạm vi.
- Việc tách `ThemeController` khỏi auth repository giúp Backend không phải biết hoặc lưu preference giao diện của thiết bị.
