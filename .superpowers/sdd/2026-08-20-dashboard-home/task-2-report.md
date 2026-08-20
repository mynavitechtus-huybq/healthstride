# Báo cáo Task 2: Home domain, repository và controller

## Phạm vi đã thực hiện

- Tạo `HomeDashboard`, `HomeProfile`, `WorkoutSummary` trong `App/lib/features/home/domain/home_dashboard.dart`.
- Tạo `HomeRepository` trong `App/lib/features/home/domain/home_repository.dart`.
- Tạo `ApiHomeRepository` trong `App/lib/features/home/data/api_home_repository.dart`.
- Tạo `HomeController` và `HomeViewState` trong `App/lib/features/home/presentation/home_controller.dart`.
- Tạo test:
  - `App/test/features/home/data/api_home_repository_test.dart`
  - `App/test/features/home/presentation/home_controller_test.dart`

## Quy trình TDD

### Repository

1. Viết test đỏ cho:
   - decode payload đầy đủ;
   - chấp nhận `today_plan: null`;
   - trả `INVALID_RESPONSE` khi field bắt buộc sai kiểu;
   - giữ nguyên transport failure từ `ApiClient`.
2. Chạy:

```bash
cd App
flutter test test/features/home/data/api_home_repository_test.dart
```

Kết quả đỏ đúng kỳ vọng: import `features/home` chưa tồn tại.

3. Implement tối thiểu:
   - decode `/v1/home` qua `ApiClient.get('/v1/home', decoder)`;
   - parse chặt các field bắt buộc;
   - map lỗi shape/kiểu dữ liệu về `ApiFailure(code: 'INVALID_RESPONSE', message: 'Invalid API response.')`;
   - cho phép `today_plan` là `null`.

4. Chạy lại repository test và pass.

### Controller

1. Viết test đỏ cho:
   - initial load bật `isInitialLoading` trước khi data về;
   - refresh giữ dashboard cũ và bật `isRefreshing`;
   - initial failure publish `failure` retryable;
   - `retry()` gọi lại luồng load và phục hồi state thành công.
2. Chạy:

```bash
cd App
flutter test test/features/home/presentation/home_controller_test.dart
```

Kết quả đỏ đúng kỳ vọng: `home_controller.dart` chưa tồn tại.

3. Implement tối thiểu:
   - `HomeController` extends `ValueNotifier<HomeViewState>`;
   - `load()` chỉ bật `isInitialLoading` khi chưa có dashboard;
   - `refresh()` giữ data cũ trong lúc fetch;
   - `retry()` gọi lại `load()`;
   - success/failure đều publish immutable `HomeViewState`.

4. Chạy lại controller test và pass.

## Verify cuối task

Đã chạy đúng quality gate của brief:

```bash
cd App
flutter test test/features/home/data/api_home_repository_test.dart test/features/home/presentation/home_controller_test.dart
flutter analyze
```

Kết quả:

- `flutter test`: pass 8/8 test.
- `flutter analyze`: `No issues found!`

## Ghi chú triển khai

- `popularWorkouts` được bọc `List.unmodifiable(...)` để tránh mutate từ bên ngoài.
- `ApiHomeRepository` không nuốt transport failure từ `ApiClient`; chỉ chuyển decode error sang `INVALID_RESPONSE`.
- `HomeController.refresh()` fallback sang `load()` khi chưa có dashboard, để không tạo nhánh state thừa.

## Concerns

- Chưa có concern mở trong phạm vi Task 2.
