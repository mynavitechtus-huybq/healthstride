# Nhật ký xây dựng: Welcome và Theme đa chế độ

> **Ngày:** 20/08/2026  
> **Feature:** Welcome/Onboarding và đổi theme trong app  
> **Branch:** `feat/welcome-theme`

## Mobile

### Hôm nay đã làm gì?

- Đọc node Welcome `1:604` trong Figma và chuyển bố cục sang Flutter.
- Thêm ảnh fitness, lớp chuyển màu ở đáy ảnh, indicator, tiêu đề và nút `Get Started`.
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

### Khó khăn gặp phải

- Firebase Auth giữ session trên Simulator nên app mở thẳng Dashboard, không hiển thị Welcome sau khi build lại.
- Một số card Home đang dùng `AppColors.neutral800` cố định; khi bật light theme, nền card vẫn tối và độ tương phản không phù hợp.
- Test cũ giả định AuthGate mở thẳng nút Google, trong khi flow mới có thêm bước Welcome.

### Cách tháo gỡ

- Kiểm tra log Flutter và trạng thái simulator thay vì kết luận từ ảnh màn hình.
- Dùng semantic colors `surfaceContainer` và `surfaceContainerHighest` cho các surface phụ thuộc theme.
- Cập nhật test theo hành vi mới: kiểm tra `Get Started`, sau đó mới kiểm tra `Continue with Google`.
- Xóa app khỏi Simulator trước khi chạy lại để kiểm tra trạng thái khởi đầu.

### Tôi học được gì?

- Theme không chỉ là đổi `scaffoldBackgroundColor`; mọi card, icon container, border và text phụ đều phải dùng semantic role.
- Auth state và app state có vòng đời khác nhau; gỡ app chưa chắc xóa được session Firebase trên iOS Keychain.
- Test UI theo hành vi giúp phát hiện contract cũ bị thay đổi khi thêm một màn hình vào flow.
- Asset từ công cụ thiết kế cần được tải về và quản lý trong repo để tránh phụ thuộc URL có thời hạn.

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
