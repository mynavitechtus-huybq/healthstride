# Báo cáo Task 1

## Phạm vi đã hoàn thành

- Đã thêm dependency `http` bằng `flutter pub add http`, để resolver cập nhật `App/pubspec.yaml` và `App/pubspec.lock`.
- Đã tạo `App/lib/core/config/app_environment.dart` với `AppEnvironment.fromApiBaseUrl(...)` và `AppEnvironment.instance` đọc từ `String.fromEnvironment('API_BASE_URL')`.
- Đã tạo `App/lib/core/network/http_get_request.dart` với `GetRequest createHttpGetRequest({required Uri baseUrl, http.Client? client})`.
- Đã mở rộng `AuthRepository` bằng `Future<String?> getIdToken({bool forceRefresh = false})`.
- Đã cập nhật `FirebaseAuthRepository.getIdToken(...)` để forward sang `_firebaseAuth.currentUser?.getIdToken(forceRefresh)`.
- Đã cập nhật các fake `AuthRepository` trong test để khớp interface mới.

## TDD đã thực hiện

1. Viết `App/test/core/config/app_environment_test.dart` trước khi có `app_environment.dart`.
2. Chạy `flutter test test/core/config/app_environment_test.dart` và xác nhận đỏ vì file production chưa tồn tại.
3. Implement tối thiểu `AppEnvironment` để kéo test môi trường sang xanh.
4. Viết `App/test/core/network/http_get_request_test.dart` và `App/test/features/auth/data/firebase_auth_repository_test.dart` trước khi có `http_get_request.dart` và `getIdToken(...)`.
5. Chạy test và xác nhận đỏ vì `createHttpGetRequest(...)` cùng `getIdToken(...)` chưa tồn tại.
6. Implement tối thiểu transport HTTP và Firebase token boundary.
7. Sửa các vấn đề analyzer nhỏ phát sinh trong test để vòng verify cuối cùng sạch hoàn toàn.

## Tệp đã tạo hoặc sửa

- Tạo `App/lib/core/config/app_environment.dart`
- Tạo `App/lib/core/network/http_get_request.dart`
- Sửa `App/lib/features/auth/domain/auth_repository.dart`
- Sửa `App/lib/features/auth/data/firebase_auth_repository.dart`
- Sửa `App/pubspec.yaml`
- Sửa `App/pubspec.lock`
- Tạo `App/test/core/config/app_environment_test.dart`
- Tạo `App/test/core/network/http_get_request_test.dart`
- Tạo `App/test/features/auth/data/firebase_auth_repository_test.dart`
- Sửa `App/test/auth_gate_test.dart`
- Sửa `App/test/widget_test.dart`

## Kết quả kiểm chứng

Đã chạy thành công:

```bash
cd App
flutter test test/core/config/app_environment_test.dart test/core/network/http_get_request_test.dart test/features/auth/data/firebase_auth_repository_test.dart
flutter analyze
```

Kết quả cuối:

- `6` test pass.
- `flutter analyze` báo `No issues found!`.

## Ghi chú kỹ thuật

- `createHttpGetRequest(...)` hiện giữ nguyên `statusCode` của response khi body không decode thành JSON object, đồng thời trả failure envelope với `NETWORK_REQUEST_FAILED`.
- Khi request ném `Exception` trước khi có response, transport trả `ApiResponse` failure với `statusCode: 500` để không throw lên UI.
- `AppEnvironment` hiện mới tạo boundary cấu hình; wiring thực tế vào `ApiClient` hoặc feature dashboard/home sẽ nằm ở task tiếp theo.
