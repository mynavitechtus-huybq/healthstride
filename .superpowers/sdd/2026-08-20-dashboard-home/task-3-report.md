# Báo cáo Task 3 - Dashboard/Home

Ngày thực hiện: Thursday, August 20, 2026
Worktree: `/Users/macbook_191/Documents/Workspace/Mobile/Fitness Application/.worktrees/feat-dashboard-home`
Branch: `feat/dashboard-home`

## Mục tiêu

Implement Task 3 của Dashboard/Home plan:

- tạo `App/lib/features/home/presentation/home_screen.dart`
- nối authenticated app flow trong `App/lib/main.dart`
- thay placeholder `"Hello Ari"` bằng Dashboard thật dựa trên `HomeController`
- không hard-code dashboard data trong app flow
- giữ `AppTheme.dark()` và Lato design tokens
- bổ sung widget tests cho populated state, retry, empty state, refresh giữ data, và authenticated entry

## Cách triển khai

### 1. Áp dụng TDD

Đã viết test trước cho các case sau:

- `App/test/features/home/presentation/home_screen_test.dart`
  - render populated dashboard
  - retry sau initial failure
  - hiển thị empty state khi `todayPlan == null`
  - refresh giữ data cũ và hiện `SnackBar` khi refresh fail
- `App/test/widget_test.dart`
  - authenticated app flow render Dashboard thay vì legacy greeting
- `App/test/auth_gate_test.dart`
  - authenticated `AuthGate` đi vào `HomeScreen`
  - `IconButton` sign out đưa flow quay lại màn `Continue with Google`

Đã chạy test đỏ trước khi implement. Lần chạy đỏ đầu tiên fail do:

- `home_screen.dart` chưa tồn tại
- `MyApp` chưa có `homeRepository`
- `HomeScreen` cũ chưa khớp interface mới

Sau đó implement tối thiểu để kéo test sang xanh.

### 2. `HomeScreen` mới

Đã tạo `App/lib/features/home/presentation/home_screen.dart` với các hành vi:

- `HomeScreen(controller: ..., onSignOut: ...)`
- gọi `controller.load()` một lần trong `initState`
- render bằng `ValueListenableBuilder<HomeViewState>`
- bọc populated state bằng `RefreshIndicator(onRefresh: controller.refresh)`
- initial loading dùng placeholder với kích thước ổn định
- initial failure hiển thị:
  - `Unable to load your dashboard.`
  - `FilledButton.icon`
  - `Icons.refresh`
- nếu `todayPlan == null`, hiển thị `No plan for today yet.`
- populated dashboard hiển thị:
  - `Welcome back, Ari`
  - metrics `Lifetime points`, `Available points`, `Day streak`
  - `Today's Plan`
  - `Popular Workouts`
- workout card dùng icon local theo `workoutType`, không tải network image
- sign out dùng `IconButton` có `tooltip: 'Sign out'`
- refresh failure khi đang có data không thay layout sang error; chỉ hiện `SnackBar` một lần cho mỗi failure emission

### 3. Nối authenticated app flow

Đã sửa `App/lib/main.dart`:

- thêm inject-able `HomeRepository? homeRepository` vào `MyApp`
- tạo default `HomeRepository` bằng:
  - `ApiHomeRepository`
  - `ApiClient`
  - `createHttpGetRequest`
  - `AppEnvironment.instance.apiBaseUrl`
  - `authRepository.getIdToken`
- thay placeholder `HomeScreen` cũ bằng `_AuthenticatedHomeScreen`
- `_AuthenticatedHomeScreen` sở hữu và `dispose()` `HomeController`
- `AuthGate.signedInBuilder` giờ đi vào `HomeScreen(controller: _controller, onSignOut: widget.onSignOut)`

Như vậy authenticated app flow dùng repository thật, không hard-code dashboard data trong `main.dart`.

## File thay đổi

- Tạo mới:
  - `App/lib/features/home/presentation/home_screen.dart`
  - `App/test/features/home/presentation/home_screen_test.dart`
- Sửa:
  - `App/lib/main.dart`
  - `App/test/widget_test.dart`
  - `App/test/auth_gate_test.dart`

## Kết quả verify

Đã chạy trực tiếp trong `App/`:

```bash
flutter test
flutter analyze
flutter build ios --simulator --debug --dart-define=API_BASE_URL=https://example.com
```

Kết quả:

- `flutter test`: pass toàn bộ test suite
- `flutter analyze`: `No issues found!`
- `flutter build ios --simulator --debug --dart-define=API_BASE_URL=https://example.com`: build thành công, tạo `build/ios/iphonesimulator/Runner.app`

Ngoài ra đã chạy nhóm test task-scoped trong quá trình TDD:

```bash
flutter test test/features/home/presentation/home_screen_test.dart test/widget_test.dart test/auth_gate_test.dart
```

Nhóm test này cũng pass sau khi hoàn tất implementation.

## Ghi chú

- Không chạy `flutter build apk --debug` vì yêu cầu chính của task hiện tại là iOS simulator debug build nếu available.
- `API_BASE_URL` cần được truyền bằng `--dart-define` khi build/running default app flow, do `AppEnvironment.instance` yêu cầu absolute URI hợp lệ.

## Kết luận

Task 3 đã được implement xong trong worktree hiện tại, verified bằng test, analyzer và iOS simulator debug build trên Thursday, August 20, 2026.
