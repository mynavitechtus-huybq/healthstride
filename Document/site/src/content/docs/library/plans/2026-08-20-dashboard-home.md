---
title: 'HealthStride: 2026 08 20 dashboard home'
description: 'Tài liệu nghiệp vụ, kế hoạch và kiến trúc của HealthStride.'
---
# Kế hoạch triển khai Dashboard/Home HealthStride

> **Dành cho agentic workers:** BẮT BUỘC dùng `superpowers:subagent-driven-development` (khuyến nghị) hoặc `superpowers:executing-plans` để thực hiện theo từng task. Các bước dùng checkbox (`- [ ]`) để theo dõi.

**Mục tiêu:** Thay Hello screen sau đăng nhập bằng Dashboard Flutter lấy dữ liệu thật từ `GET /v1/home`, có remote state hoàn chỉnh và Vlog Mobile/Backend bằng tiếng Việt.

**Kiến trúc:** `features/home` dùng ranh giới domain-data-presentation. `ApiHomeRepository` decode envelope qua `ApiClient`; `HomeController` sở hữu state; Dashboard chỉ render state. Composition root tạo HTTP adapter và token provider. FastAPI giữ Home contract hiện có.

**Tech stack:** Flutter/Dart, Firebase Auth, `package:http`, FastAPI, pytest, Astro Starlight, pnpm, Vercel.

**Đặc tả:** `Document/HealthStride/2026-08-20-dashboard-home-design.md`

## Ràng buộc chung

- Tài liệu mới viết bằng tiếng Việt; giữ nguyên identifier, endpoint, JSON, command và package name.
- Dùng Lato và `AppTheme.dark()`; không copy Figma bằng absolute positioning.
- `API_BASE_URL` chỉ đọc từ `--dart-define`; không commit URL local, Firebase token, credential hoặc `.env`.
- Chỉ render các field hiện có trong `GET /v1/home`: profile, today plan và popular workouts.
- Không thêm Riverpod, BLoC, persistent cache, auto-sign-out hoặc Backend refactor ngoài contract regression test.
- Trước push phải rebase `origin/main`; chỉ cập nhật PR, không push trực tiếp `main`.

## Cấu trúc file

- `App/lib/core/config/app_environment.dart`: đọc/validate `API_BASE_URL`.
- `App/lib/core/network/http_get_request.dart`: production adapter từ `package:http` sang `GetRequest`.
- `App/lib/features/home/domain/`: immutable models và `HomeRepository` interface.
- `App/lib/features/home/data/api_home_repository.dart`: decode `/v1/home`.
- `App/lib/features/home/presentation/`: controller và Dashboard screen.
- `Document/site/src/content/docs/daily/`: hai bài Vlog public và index links.

---

### Task 1: Tạo HTTP transport, cấu hình môi trường và Firebase token boundary

**Files:**
- Create: `App/lib/core/config/app_environment.dart`, `App/lib/core/network/http_get_request.dart`
- Modify: `App/pubspec.yaml`, `App/lib/features/auth/domain/auth_repository.dart`, `App/lib/features/auth/data/firebase_auth_repository.dart`
- Test: `App/test/core/config/app_environment_test.dart`, `App/test/core/network/http_get_request_test.dart`, `App/test/features/auth/data/firebase_auth_repository_test.dart`

**Interfaces:**
- `AppEnvironment.apiBaseUrl` là absolute URI từ `String.fromEnvironment('API_BASE_URL')`.
- `GetRequest createHttpGetRequest({required Uri baseUrl, http.Client? client})`.
- `Future<String?> AuthRepository.getIdToken({bool forceRefresh = false})`.

- [ ] **Bước 1: Khai báo dependency và viết test cấu hình thất bại trước**

Chạy `cd App && flutter pub add http` để resolver ghi version stable hiện hành vào `pubspec.yaml` và `pubspec.lock`; không tự đoán version. Viết test:

```dart
test('rejects an absent API base URL', () {
  expect(() => AppEnvironment.fromApiBaseUrl(''), throwsArgumentError);
});

test('accepts an absolute API base URL', () {
  final value = AppEnvironment.fromApiBaseUrl('http://127.0.0.1:8000');
  expect(value.apiBaseUrl.toString(), 'http://127.0.0.1:8000');
});
```

- [ ] **Bước 2: Xác nhận test đỏ**

Run: `cd App && flutter test test/core/config/app_environment_test.dart`

Expected: FAIL vì `app_environment.dart` chưa tồn tại.

- [ ] **Bước 3: Implement adapter tối thiểu**

`AppEnvironment.fromApiBaseUrl` chỉ nhận URI có scheme và host. `createHttpGetRequest` resolve relative path từ base URI, gọi `client.get`, decode JSON object và trả `ApiResponse`. Non-object JSON/`FormatException` trả failure body với code `NETWORK_REQUEST_FAILED`, không throw tới UI.

Mở rộng tất cả fake `AuthRepository` trong test. Firebase implementation trả:

```dart
Future<String?> getIdToken({bool forceRefresh = false}) =>
    _firebaseAuth.currentUser?.getIdToken(forceRefresh);
```

- [ ] **Bước 4: Viết adapter test cho URL, header và invalid JSON**

```dart
test('resolves a path and forwards headers', () async {
  final request = createHttpGetRequest(
    baseUrl: Uri.parse('http://localhost:8000'),
    client: FakeClient((request) async {
      expect(request.url, Uri.parse('http://localhost:8000/v1/home'));
      expect(request.headers['Authorization'], 'Bearer firebase-token');
      return http.Response('{"data": {}, "meta": {}, "error": null}', 200);
    }),
  );
  expect((await request('/v1/home', headers: {'Authorization': 'Bearer firebase-token'})).statusCode, 200);
});
```

- [ ] **Bước 5: Verify và commit**

Run:

```bash
cd App
flutter test test/core/config/app_environment_test.dart test/core/network/http_get_request_test.dart test/features/auth/data/firebase_auth_repository_test.dart
flutter analyze
```

Expected: test pass, analyzer không issue.

```bash
git add App/pubspec.yaml App/pubspec.lock App/lib/core App/lib/features/auth App/test/core App/test/features/auth
git commit -m "feat: add authenticated API transport"
```

### Task 2: Xây dựng Home domain, repository và controller bằng TDD

**Files:**
- Create: `App/lib/features/home/domain/home_dashboard.dart`, `App/lib/features/home/domain/home_repository.dart`
- Create: `App/lib/features/home/data/api_home_repository.dart`, `App/lib/features/home/presentation/home_controller.dart`
- Test: `App/test/features/home/data/api_home_repository_test.dart`, `App/test/features/home/presentation/home_controller_test.dart`

**Interfaces:**
- `HomeDashboard`, `HomeProfile`, `WorkoutSummary` là immutable models.
- `abstract interface class HomeRepository { Future<ApiResult<HomeDashboard>> fetchDashboard(); }`.
- `HomeController.load()`, `refresh()`, `retry()` và immutable `HomeViewState` có `dashboard`, `failure`, `isInitialLoading`, `isRefreshing`.

- [ ] **Bước 1: Viết repository test đỏ**

```dart
test('decodes the complete home payload', () async {
  final repository = ApiHomeRepository(FakeApiClient.success({
    'profile': {'display_name': 'Ari', 'email': 'ari@example.com', 'lifetime_points': 120, 'available_points': 90, 'current_streak': 3},
    'today_plan': {'slug': 'morning-cardio', 'name': 'Morning Cardio', 'description': 'Start strong.', 'workout_type': 'cardio', 'duration_minutes': 30, 'estimated_calories': 220, 'image_url': null},
    'popular_workouts': [],
  }));
  final result = await repository.fetchDashboard();
  expect(result.data?.profile.currentStreak, 3);
  expect(result.data?.todayPlan?.slug, 'morning-cardio');
});
```

- [ ] **Bước 2: Xác nhận module chưa tồn tại**

Run: `cd App && flutter test test/features/home/data/api_home_repository_test.dart`

Expected: FAIL do import `features/home` chưa tồn tại.

- [ ] **Bước 3: Implement model và decoder**

Model dùng `final` fields và constructor `const` khi khả thi. Missing/sai kiểu field bắt buộc trả `ApiResult.failure(ApiFailure(code: 'INVALID_RESPONSE', message: 'Invalid API response.'))`; `today_plan: null` hợp lệ. Repository chỉ gọi `ApiClient.get('/v1/home', decoder)`.

- [ ] **Bước 4: Viết controller test trước implementation**

```dart
test('keeps previous dashboard while refreshing', () async {
  final controller = HomeController(repository: QueuedHomeRepository([successDashboard, successDashboard]));
  await controller.load();
  final refresh = controller.refresh();
  expect(controller.value.dashboard?.profile.displayName, 'Ari');
  expect(controller.value.isRefreshing, isTrue);
  await refresh;
});

test('publishes a retryable initial failure', () async {
  final controller = HomeController(repository: FailureHomeRepository());
  await controller.load();
  expect(controller.value.failure?.code, 'NETWORK_REQUEST_FAILED');
  expect(controller.value.dashboard, isNull);
});
```

- [ ] **Bước 5: Implement controller, verify và commit**

`load()` chỉ bật initial loading khi chưa có Dashboard. `refresh()` giữ data cũ, bật `isRefreshing`, rồi thay data hoặc lưu failure. `retry()` gọi `load()`. Controller extends `ValueNotifier<HomeViewState>`, không giữ `BuildContext`.

Run:

```bash
cd App
flutter test test/features/home/data/api_home_repository_test.dart test/features/home/presentation/home_controller_test.dart
flutter analyze
```

Expected: test pass, analyzer không issue.

```bash
git add App/lib/features/home App/test/features/home
git commit -m "feat: add dashboard home data flow"
```

### Task 3: Render Dashboard responsive và nối authenticated app flow

**Files:**
- Create: `App/lib/features/home/presentation/home_screen.dart`
- Modify: `App/lib/main.dart`, `App/test/widget_test.dart`, `App/test/auth_gate_test.dart`
- Test: `App/test/features/home/presentation/home_screen_test.dart`

**Interfaces:**
- `HomeScreen(controller: ..., onSignOut: ...)` render loading, error/retry, empty plan, populated Dashboard và pull-to-refresh.

- [ ] **Bước 1: Viết widget test populated state trước**

```dart
testWidgets('renders greeting, metrics, today plan, and popular workouts', (tester) async {
  final controller = HomeController(repository: FakeHomeRepository.withDashboard(sampleDashboard));
  await tester.pumpWidget(testApp(HomeScreen(controller: controller, onSignOut: () async {})));
  await tester.pumpAndSettle();
  expect(find.text('Welcome back, Ari'), findsOneWidget);
  expect(find.text('120'), findsOneWidget);
  expect(find.text('Morning Cardio'), findsWidgets);
  expect(find.text('Popular Workouts'), findsOneWidget);
});
```

- [ ] **Bước 2: Xác nhận screen chưa tồn tại**

Run: `cd App && flutter test test/features/home/presentation/home_screen_test.dart`

Expected: FAIL do `home_screen.dart` chưa tồn tại.

- [ ] **Bước 3: Implement remote state và layout**

`HomeScreen` gọi `controller.load()` một lần trong `initState`, dùng `ValueListenableBuilder`, và bọc nội dung bằng `RefreshIndicator(onRefresh: controller.refresh)`. Initial loading dùng placeholder có stable dimension. Initial failure render `Unable to load your dashboard.` cùng `FilledButton.icon`/`Icons.refresh`. Failure khi có data chỉ hiện `SnackBar` một lần sau refresh. Khi `todayPlan == null`, render `No plan for today yet.`.

Metrics có label `Lifetime points`, `Available points`, `Day streak`. Workout card chọn icon theo `workoutType`, không tải network image. Dùng `IconButton` có tooltip để sign out; text wrap trên phone width.

- [ ] **Bước 4: Hoàn thiện widget test states**

Thêm test cho `Retry`, empty today plan, refresh giữ data, và authenticated entry không còn `Hello Ari`. Toàn bộ test dùng fake auth/home, không gọi Firebase/HTTP thật.

- [ ] **Bước 5: Verify và commit**

Run:

```bash
cd App
flutter test
flutter analyze
flutter build ios --simulator --debug
```

Expected: test pass, analyzer không issue, iOS simulator debug build thành công. Nếu Android SDK sẵn sàng, chạy thêm `flutter build apk --debug`.

```bash
git add App/lib/main.dart App/lib/features/home/presentation App/test
git commit -m "feat: render authenticated dashboard home"
```

### Task 4: Kiểm chứng Home contract ở Backend và manual integration local

**Files:**
- Modify: `Backend/tests/api/test_auth_and_home.py` chỉ khi cần assertion cho field Flutter decode.
- Create: `Document/HealthStride/daily/mobile/2026-08-20.md`, `Document/HealthStride/daily/backend/2026-08-20.md`

**Interfaces:**
- FastAPI response `/v1/home` có đầy đủ profile, `popular_workouts` và `today_plan` theo Flutter decoder.

- [ ] **Bước 1: Thêm assertion đầy đủ cho contract hiện có**

Trong `test_home_upserts_the_verified_identity_and_returns_data`, assert `display_name`, `email`, ba metrics, toàn bộ field của một popular workout và `today_plan` bằng popular workout đầu tiên. JSON key phải đúng: `slug`, `name`, `description`, `workout_type`, `duration_minutes`, `estimated_calories`, `image_url`.

- [ ] **Bước 2: Chạy API test trước khi sửa Backend**

Run: `cd Backend && uv run pytest tests/api/test_auth_and_home.py -q`

Expected: PASS với contract hiện có. Chỉ khi FAIL mới sửa schema/service/router ở mức tối thiểu; không đổi migration hoặc business rule.

- [ ] **Bước 3: Kiểm tra integration local trên simulator**

Run API với `.env` local hợp lệ:

```bash
cd Backend
uv run fastapi dev app/main.py --host 0.0.0.0 --port 8000
```

Run iOS simulator:

```bash
cd App
flutter run --dart-define=API_BASE_URL=http://127.0.0.1:8000
```

Run Android emulator trên macOS host:

```bash
flutter run --dart-define=API_BASE_URL=http://10.0.2.2:8000
```

Đăng nhập Google, verify Dashboard hiển thị profile/workout seeded và kéo để refresh. Ghi evidence thật vào daily record; không ghi token, email cá nhân hoặc secret.

- [ ] **Bước 4: Commit task**

```bash
git add Backend/tests/api/test_auth_and_home.py Document/HealthStride/daily
git commit -m "test: verify dashboard home contract"
```

### Task 5: Xuất bản Vlog Mobile/Backend và quality gate

**Files:**
- Create: `Document/site/src/content/docs/daily/mobile/2026-08-20-dashboard-home.mdx`, `Document/site/src/content/docs/daily/backend/2026-08-20-dashboard-home.mdx`
- Modify: `Document/site/src/content/docs/daily/mobile/index.mdx`, `Document/site/src/content/docs/daily/backend/index.mdx`

**Interfaces:**
- Public routes: `/daily/mobile/2026-08-20-dashboard-home/` và `/daily/backend/2026-08-20-dashboard-home/`.

- [ ] **Bước 1: Viết Mobile Vlog từ evidence thực tế**

Frontmatter và heading bắt buộc:

```mdx
---
title: 'Dashboard/Home: từ Hello đến dữ liệu thật'
description: 'Nhật ký triển khai Dashboard Flutter với Firebase ID token và FastAPI.'
---

## Tôi đã làm gì
## Tôi đã làm như thế nào
## Tôi gặp khó khăn gì
## Tôi tháo gỡ ra sao
## Tôi học được gì
```

Đề cập transport, typed envelope, controller state, test count và simulator URL thực tế. Không bịa blocker.

- [ ] **Bước 2: Viết Backend Vlog từ evidence thực tế**

Dùng cùng năm heading. Nêu verified Firebase identity, stable envelope, contract assertion, lý do không phải mở rộng Backend schema/service; liên kết bài học với API Design & Integration và Testing & QA.

- [ ] **Bước 3: Link Vlog, build Docs và chạy quality gate**

Run:

```bash
cd Document/site && pnpm build
cd ../../App && flutter analyze && flutter test
cd ../Backend && uv run pytest
```

Expected: Astro không diagnostics, Flutter analyzer sạch/test pass, Backend test pass (migration integration có thể skip nếu local database không chạy).

- [ ] **Bước 4: Commit, rebase và cập nhật PR**

```bash
git add Document/site Document/HealthStride/daily
git commit -m "docs: publish dashboard home learning vlog"
git fetch origin main
git rebase origin/main
git push --force-with-lease origin feat/dashboard-home
```

Đổi PR #6 từ draft sang ready for review chỉ sau khi có đủ evidence quality gate.

## Tự rà soát

- Đặc tả được phủ bởi transport/token (Task 1), domain/state (Task 2), UI (Task 3), contract/manual integration (Task 4), Vlog/publication (Task 5).
- Interfaces nhất quán: `AuthRepository.getIdToken` cấp token cho `ApiClient`; `HomeRepository.fetchDashboard` cấp `ApiResult<HomeDashboard>` cho `HomeController`; `HomeScreen` chỉ nhận controller và sign-out action.
- Không có placeholder hoặc work deferred; các hạng mục ngoài scope đã được ghi rõ trong đặc tả và ràng buộc chung.
