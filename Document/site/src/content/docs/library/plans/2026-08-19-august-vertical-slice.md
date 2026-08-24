---
title: 'HealthStride: 2026 08 19 august vertical slice'
description: 'Tài liệu nghiệp vụ, kế hoạch và kiến trúc của HealthStride.'
---
# HealthStride August Vertical Slice Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Deliver the approved Flutter fitness vertical slice, FastAPI/PostgreSQL/Redis backend, and Vercel-deployed learning journal with measurable data and API evidence.

**Architecture:** Flutter is a feature-first client using Firebase Authentication for Google sign-in and FastAPI for all application data. FastAPI verifies Firebase ID tokens, owns transactional PostgreSQL business rules, uses Redis only for sliding-window rate limiting and leaderboard cache-aside, and publishes OpenAPI. `Document/site` is an Astro static site built from Markdown learning records.

**Tech Stack:** Flutter 3.44.9/Dart 3.12.2, Firebase Auth/Analytics/FCM, Python 3.12 with uv, FastAPI, SQLAlchemy 2 async, Alembic, PostgreSQL 16, Redis 7, pytest, Docker Compose, Astro Starlight, pnpm, Vercel.

**Spec:** `Document/HealthStride/2026-08-19-vertical-slice-design.md`

## Global Constraints

- PostgreSQL is the application source of truth; Firebase Firestore is not introduced.
- Firebase Auth is the identity provider. FastAPI verifies ID tokens server-side and never accepts a client user ID as authority.
- August production sign-in provider is Google only. Facebook and LINE are documented as September backlog items.
- Flutter uses the existing local Lato family, `AppTheme`, and Figma nodes `1:604`, `1:479`, and `1:350` as visual references; do not copy Figma absolute layout into Flutter.
- All API output uses `{ data, meta, error }`; do not return unwrapped feature payloads.
- `POST /v1/workouts` requires `Idempotency-Key` and writes workout, point transaction, user summary, and streak atomically.
- Rate limiting is custom Redis sorted-set sliding window: GET 100/minute/user, mutations 10/minute/user.
- Leaderboard uses cache-aside with 60-second TTL, write invalidation, and a short lock to avoid cache stampede.
- Every Alembic migration must implement upgrade and downgrade and be tested locally both directions.
- Seed at least 1,000 rows and publish before/after `EXPLAIN ANALYZE` evidence for Home, history, and weekly leaderboard.
- Keep `Backend`, `App`, and `Document` boundaries separate. Secrets reside only in ignored local `.env` files.
- The root Git repository has no commits; do not initialize, reset, delete, or commit Git history during this plan.

## File Structure

### Backend

- `Backend/pyproject.toml`: Python project and dependency definitions.
- `Backend/app/main.py`: FastAPI composition and exception handlers.
- `Backend/app/core/config.py`: typed environment configuration.
- `Backend/app/core/security.py`: Firebase token verifier protocol and production implementation.
- `Backend/app/core/api_envelope.py`: response/error models and error codes.
- `Backend/app/core/rate_limit.py`: Redis sorted-set sliding window.
- `Backend/app/db/models/*.py`: SQLAlchemy models only.
- `Backend/app/db/session.py`: database and Redis clients.
- `Backend/app/db/seed.py`: deterministic development/performance seed.
- `Backend/app/features/auth/`, `home/`, `workouts/`, `leaderboard/`: schema, repository, service, and router for each bounded feature.
- `Backend/alembic/versions/`: forward and rollback migrations.
- `Backend/tests/`: unit, API, integration, and query-plan tests.
- `Backend/docker-compose.yml`: local PostgreSQL and Redis only.

### App

- `App/lib/app.dart`: application shell, router, and app-wide providers.
- `App/lib/core/`: API client, auth token attachment, result/error type, routing.
- `App/lib/features/auth/`: Firebase sign-in and auth gate.
- `App/lib/features/home/`: Home DTOs, repository, controller, and Figma-informed page.
- `App/lib/features/workouts/`: catalog, workout log form, and submit use case.
- `App/lib/features/leaderboard/`: weekly leaderboard repository, controller, and page.
- `App/lib/shared/widgets/`: reusable loading, error, empty, and section UI.
- `App/test/` and `App/integration_test/`: unit/widget/smoke coverage.

### Document

- `Document/site/`: Astro Starlight project and Vercel deployment configuration.
- `Document/HealthStride/daily/mobile/`: daily Flutter records.
- `Document/HealthStride/daily/backend/`: daily backend records.
- `Document/HealthStride/evidence/`: query plans, benchmark results, migration proof, and screenshots.

---

### Task 1: Establish Local Services, Backend Skeleton, and Documentation Site

**Files:**
- Create: `Backend/pyproject.toml`, `Backend/docker-compose.yml`, `Backend/.env.example`, `Backend/app/main.py`, `Backend/app/core/config.py`, `Backend/app/core/api_envelope.py`, `Backend/tests/test_health.py`
- Create: `Document/site/package.json`, `Document/site/astro.config.mjs`, `Document/site/src/content.config.ts`, `Document/site/src/content/docs/index.mdx`, `Document/site/src/content/docs/daily/mobile/index.mdx`, `Document/site/src/content/docs/daily/backend/index.mdx`
- Create: `Document/HealthStride/daily/mobile/2026-08-19.md`, `Document/HealthStride/daily/backend/2026-08-19.md`

**Interfaces:**
- Produces `GET /health` returning HTTP 200 and `{ "data": { "status": "ok" }, "meta": {}, "error": null }`.
- Produces a Starlight site that builds with `pnpm build`.

- [ ] **Step 1: Write the health endpoint test before the application exists**

```python
from fastapi.testclient import TestClient
from app.main import app


def test_health_returns_the_standard_envelope() -> None:
    response = TestClient(app).get('/health')

    assert response.status_code == 200
    assert response.json() == {
        'data': {'status': 'ok'},
        'meta': {},
        'error': None,
    }
```

- [ ] **Step 2: Run the test to confirm the missing application fails**

Run: `cd Backend && uv run pytest tests/test_health.py -q`

Expected: collection fails because `app.main` does not exist.

- [ ] **Step 3: Create the local service contract and minimal FastAPI implementation**

Define these environment variables in `.env.example` without values: `DATABASE_URL`, `REDIS_URL`, `FIREBASE_PROJECT_ID`, `GOOGLE_APPLICATION_CREDENTIALS`, `CORS_ORIGINS`.

Use Docker Compose services named `postgres` and `redis`, with PostgreSQL 16 and Redis 7, persistent named volumes, and host ports `5432` and `6379`.

Implement `success(data, meta=None)` and `error_response(status_code, code, message, details=None)` in `api_envelope.py`; both must set all three top-level fields. Add a FastAPI health router and a global exception handler that returns `INTERNAL_SERVER_ERROR` without stack trace content.

- [ ] **Step 4: Pass the health test and static checks**

Run:

```bash
cd Backend
uv run pytest tests/test_health.py -q
uv run ruff check .
uv run mypy app
```

Expected: all commands exit 0.

- [ ] **Step 5: Create the documentation site and daily record templates**

Use Starlight with docs content collections. The Mobile and Backend daily entry template must include exact headings: `Objective`, `Completed`, `Evidence`, `Lesson Learned`, `Risk or Blocker`, and `Next Action`. Add the 19 August entries describing this approved vertical-slice foundation, with no invented execution evidence.

- [ ] **Step 6: Verify the documentation build**

Run:

```bash
cd Document/site
pnpm install
pnpm build
```

Expected: static site build succeeds.

### Task 2: Create the Transactional Schema, Migrations, Seed, and Rollback Evidence

**Files:**
- Create: `Backend/app/db/base.py`, `Backend/app/db/session.py`, `Backend/app/db/models/user.py`, `Backend/app/db/models/workout.py`, `Backend/app/db/models/points_transaction.py`, `Backend/app/db/models/workout_catalog.py`, `Backend/app/db/seed.py`
- Create: `Backend/alembic.ini`, `Backend/alembic/env.py`, `Backend/alembic/versions/20260821_01_create_vertical_slice_tables.py`
- Create: `Backend/tests/integration/test_migrations.py`, `Backend/tests/unit/test_points_rules.py`
- Create: `Document/HealthStride/evidence/migrations/2026-08-21-up-down.md`, `Document/HealthStride/daily/backend/2026-08-21.md`

**Interfaces:**
- Produces SQLAlchemy rows `User`, `WorkoutLog`, `PointsTransaction`, `WorkoutCatalog`.
- Produces pure function `calculate_workout_points(duration_minutes: int, workout_type: WorkoutType, points_awarded_today: int) -> WorkoutPointsResult`.

- [ ] **Step 1: Write unit tests for the point rules**

```python
def test_short_workout_is_saved_with_no_points() -> None:
    result = calculate_workout_points(9, WorkoutType.cardio, 0)
    assert result.awarded == 0
    assert result.capped is False


def test_workout_and_daily_caps_are_applied() -> None:
    result = calculate_workout_points(180, WorkoutType.weight_lifting, 450)
    assert result.awarded == 50
    assert result.capped is True
```

- [ ] **Step 2: Run tests before the domain module exists**

Run: `cd Backend && uv run pytest tests/unit/test_points_rules.py -q`

Expected: import failure for `calculate_workout_points`.

- [ ] **Step 3: Implement models and business constraints**

Use UUID primary keys, UTC timestamps, a unique `users.firebase_uid`, and a unique constraint on `(user_id, idempotency_key)` in `workout_logs`. Store duration, optional distance, logged time, calories, awarded points, and capped flag. Ensure `PointsTransaction.lifetime_amount >= 0`; preserve `User.lifetime_points >= User.available_points >= 0` in the workout service transaction.

Seed at least 1,000 users, workout logs, and point transactions deterministically using a fixed random seed. Include a seeded workout catalog used by Home and Explore.

- [ ] **Step 4: Create a reversible Alembic migration**

`upgrade()` must create the four tables, foreign keys, constraints, and baseline indexes. `downgrade()` must remove them in dependency-safe reverse order. Do not use ORM metadata creation in production startup.

- [ ] **Step 5: Verify upgrade, seed, and downgrade on local PostgreSQL**

Run:

```bash
cd Backend
docker compose up -d postgres redis
uv run alembic upgrade head
uv run python -m app.db.seed --users 1000
uv run pytest tests/unit/test_points_rules.py tests/integration/test_migrations.py -q
uv run alembic downgrade base
uv run alembic upgrade head
```

Expected: forward migration, seed, rollback, and re-upgrade all succeed. Record exact command output and observed rollback risks in the migration evidence document.

### Task 3: Implement Firebase Authentication Boundary, API Envelope, and Home Contract

**Files:**
- Create: `Backend/app/core/security.py`, `Backend/app/features/auth/dependencies.py`, `Backend/app/features/auth/service.py`, `Backend/app/features/home/schemas.py`, `Backend/app/features/home/service.py`, `Backend/app/features/home/router.py`
- Create: `Backend/tests/api/test_auth_and_home.py`, `Backend/tests/fakes/firebase_verifier.py`
- Create: `Document/HealthStride/api-contract.md`, `Document/HealthStride/daily/backend/2026-08-24.md`

**Interfaces:**
- `FirebaseVerifier.verify(id_token: str) -> VerifiedIdentity` exposes `uid`, `email`, and `display_name`.
- `get_current_user` yields an existing/upserted `User` for protected routes.
- `GET /v1/me` and `GET /v1/home` return the standard envelope.

- [ ] **Step 1: Write API tests with a fake verifier**

```python
def test_home_upserts_the_verified_identity_and_returns_data(client, fake_verifier) -> None:
    fake_verifier.identity = VerifiedIdentity(
        uid='firebase-user-1', email='user@example.com', display_name='Ari',
    )
    response = client.get('/v1/home', headers={'Authorization': 'Bearer valid-token'})

    assert response.status_code == 200
    assert response.json()['error'] is None
    assert response.json()['data']['profile']['display_name'] == 'Ari'


def test_home_rejects_missing_bearer_token(client) -> None:
    response = client.get('/v1/home')
    assert response.status_code == 401
    assert response.json()['error']['code'] == 'AUTHENTICATION_REQUIRED'
```

- [ ] **Step 2: Run the tests to prove the protected API is absent**

Run: `cd Backend && uv run pytest tests/api/test_auth_and_home.py -q`

Expected: route and dependency failures.

- [ ] **Step 3: Implement the verified identity boundary**

Production `FirebaseAdminVerifier` calls `firebase_admin.auth.verify_id_token`. Tests inject `FakeFirebaseVerifier`; no test accesses Firebase credentials. The bearer dependency rejects missing/malformed/invalid tokens with the same envelope and does not accept `X-User-Id` or body user IDs.

Home returns `profile`, `popular_workouts`, and `today_plan`. Select only data defined in the August schema.

- [ ] **Step 4: Generate and verify API reference**

Run:

```bash
cd Backend
uv run pytest tests/api/test_auth_and_home.py -q
uv run fastapi dev app/main.py
curl -fsS http://127.0.0.1:8000/openapi.json > /tmp/healthstride-openapi.json
```

Expected: protected tests pass and OpenAPI contains `/v1/me`, `/v1/home`, and `/health`. Stop the dev server after verification.

- [ ] **Step 5: Document exact request/response examples**

Write `api-contract.md` covering successful and error envelopes, Bearer token requirement, and the fact that Firebase client identity is verified by the server.

### Task 4: Implement Workout Logging, Redis Rate Limiting, and Leaderboard Cache-Aside

**Files:**
- Create: `Backend/app/core/rate_limit.py`, `Backend/app/features/workouts/schemas.py`, `Backend/app/features/workouts/service.py`, `Backend/app/features/workouts/router.py`, `Backend/app/features/leaderboard/service.py`, `Backend/app/features/leaderboard/router.py`
- Create: `Backend/tests/unit/test_rate_limit.py`, `Backend/tests/integration/test_workout_transaction.py`, `Backend/tests/integration/test_leaderboard_cache.py`, `Backend/tests/api/test_workouts_and_leaderboard.py`
- Create: `Document/HealthStride/daily/backend/2026-08-26.md`

**Interfaces:**
- `POST /v1/workouts` accepts `workout_type`, `duration_minutes`, optional `distance_km`, and `logged_at`; it requires `Idempotency-Key`.
- `GET /v1/leaderboards/weekly` returns `week_start`, ranked rows, and the current user rank in `data`.
- `SlidingWindowLimiter.allow(key: str, limit: int, window_seconds: int) -> RateLimitDecision` is called after authentication.

- [ ] **Step 1: Write failing transaction and cache tests**

```python
async def test_workout_write_is_atomic_and_invalidates_weekly_leaderboard(session, redis) -> None:
    await cache_weekly_leaderboard(redis, week_start, [{'rank': 1, 'user_id': 'other'}])
    result = await log_workout(session, redis, user, workout_request, 'request-1')

    assert result.points_awarded > 0
    assert await redis.get(weekly_leaderboard_key(week_start)) is None
    assert await count_points_transactions(session, user.id) == 1


def test_rate_limit_rejects_the_next_post_within_the_window(limiter) -> None:
    for _ in range(10):
        assert limiter.allow('user-1:POST', 10, 60).allowed
    assert limiter.allow('user-1:POST', 10, 60).allowed is False
```

- [ ] **Step 2: Run tests before implementations exist**

Run: `cd Backend && uv run pytest tests/unit/test_rate_limit.py tests/integration/test_workout_transaction.py tests/integration/test_leaderboard_cache.py -q`

Expected: import failures for limiter, workout service, and leaderboard service.

- [ ] **Step 3: Implement atomic workout logging**

Validate duration is positive, distance is supplied only for cardio, and logged time is not future. Use the database transaction to insert the workout, calculate award/cap, create a point transaction, and update user totals/streak. Repeat of the same user/idempotency key returns `409 IDEMPOTENCY_CONFLICT` without double-awarding points.

- [ ] **Step 4: Implement rate limit and cache stampede protection**

For each request, remove sorted-set entries older than 60 seconds, count remaining entries, conditionally add the current timestamp, set the key expiry, and return `429 RATE_LIMIT_EXCEEDED` when the limit is reached. For leaderboard misses, acquire `leaderboard:weekly:<week-start>:lock` using `SET NX EX`; non-owners poll the cache for a bounded short interval, then return a normal cache-backed result or query only after lock expiry. Cache successful results for 60 seconds. Delete the cache after successful workout commit.

- [ ] **Step 5: Pass API and integration checks**

Run:

```bash
cd Backend
uv run pytest tests/unit/test_rate_limit.py tests/integration/test_workout_transaction.py tests/integration/test_leaderboard_cache.py tests/api/test_workouts_and_leaderboard.py -q
uv run ruff check .
uv run mypy app
```

Expected: all tests and static checks pass.

### Task 5: Measure Queries, Add Composite Indexes, and Publish Backend Evidence

**Files:**
- Create: `Backend/app/db/query_plans.py`, `Backend/alembic/versions/20260830_01_add_query_indexes.py`, `Backend/tests/integration/test_query_indexes.py`
- Create: `Document/HealthStride/evidence/performance/home-before.md`, `Document/HealthStride/evidence/performance/home-after.md`, `Document/HealthStride/evidence/performance/history-before.md`, `Document/HealthStride/evidence/performance/history-after.md`, `Document/HealthStride/evidence/performance/leaderboard-before.md`, `Document/HealthStride/evidence/performance/leaderboard-after.md`, `Document/HealthStride/daily/backend/2026-08-30.md`

**Interfaces:**
- `query_plans.py` runs exactly the Home, history, and weekly leaderboard SQL used by the feature, using `EXPLAIN (ANALYZE, BUFFERS, FORMAT TEXT)`.

- [ ] **Step 1: Capture plans before the composite-index migration**

Run the queries against seeded data and write raw output plus a short interpretation to the three `*-before.md` files. The queries must be:

```sql
SELECT * FROM workout_logs WHERE user_id = :user_id ORDER BY logged_at DESC LIMIT 20;
SELECT * FROM workout_logs WHERE user_id = :user_id AND logged_at >= :week_start ORDER BY logged_at DESC;
SELECT user_id, SUM(points_awarded) AS score FROM workout_logs
WHERE logged_at >= :week_start GROUP BY user_id ORDER BY score DESC LIMIT 50;
```

- [ ] **Step 2: Write an index expectation test**

```python
def test_migration_creates_workout_access_indexes(connection) -> None:
    names = index_names(connection, 'workout_logs')
    assert 'ix_workout_logs_user_logged_at' in names
    assert 'ix_workout_logs_logged_at_user_points' in names
```

- [ ] **Step 3: Implement reversible indexes**

Create `ix_workout_logs_user_logged_at` on `(user_id, logged_at DESC)` and `ix_workout_logs_logged_at_user_points` on `(logged_at, user_id, points_awarded)`. The Alembic downgrade must drop both indexes.

- [ ] **Step 4: Apply, re-measure, and compare**

Run:

```bash
cd Backend
uv run alembic upgrade head
uv run pytest tests/integration/test_query_indexes.py -q
uv run python -m app.db.query_plans --output ../Document/HealthStride/evidence/performance
```

Expected: test passes and each `*-after.md` records planning/execution time and whether the query plan changed. Do not claim an improvement if the plan shows no meaningful improvement.

### Task 6: Establish Flutter App Shell, Firebase Auth Gate, and API Client

**Files:**
- Modify: `App/pubspec.yaml`, `App/lib/main.dart`
- Create: `App/lib/app.dart`, `App/lib/core/network/api_client.dart`, `App/lib/core/network/api_result.dart`, `App/lib/core/auth/firebase_auth_service.dart`, `App/lib/core/routing/app_router.dart`, `App/lib/shared/widgets/app_loading_view.dart`, `App/lib/shared/widgets/app_error_view.dart`, `App/lib/features/auth/presentation/auth_gate.dart`, `App/lib/features/auth/presentation/sign_in_page.dart`
- Create: `App/test/core/network/api_client_test.dart`, `App/test/features/auth/auth_gate_test.dart`

**Interfaces:**
- `FirebaseAuthService.idToken()` returns the current Firebase ID token or `null`.
- `ApiClient.get<T>(path, decoder)` adds the Bearer token and maps `{data,meta,error}` into `ApiResult<T>`.
- `AuthGate` chooses onboarding/sign-in or authenticated shell from Firebase auth state.

- [ ] **Step 1: Add failing auth gate and API envelope tests**

```dart
testWidgets('shows sign in when the Firebase user is absent', (tester) async {
  await tester.pumpWidget(const TestApp(authState: AsyncData(null)));
  expect(find.text('Continue with Google'), findsOneWidget);
});

test('maps an API error envelope to a typed failure', () async {
  final result = await client.get('/v1/home', HomeDto.fromJson);
  expect(result.failure?.code, 'AUTHENTICATION_REQUIRED');
});
```

- [ ] **Step 2: Run tests before the feature shell exists**

Run: `cd App && flutter test test/core/network/api_client_test.dart test/features/auth/auth_gate_test.dart`

Expected: import failures for the client and auth gate.

- [ ] **Step 3: Add current Firebase and state-management packages**

Add `firebase_core`, `firebase_auth`, `google_sign_in`, `flutter_riverpod`, `go_router`, `dio`, and `freezed_annotation` runtime packages plus matching generator/test packages. Run `flutterfire configure` only after the user provides a Firebase project; keep generated Firebase options out of the plan until that credentialed operation is available.

- [ ] **Step 4: Implement the app shell and recoverable remote errors**

Refactor `main.dart` to initialize Firebase before `runApp`, retain `AppTheme.dark()`, and put `ProviderScope` at the root. The API client sends the token, performs one token-refresh retry on `401`, and returns an unauthenticated failure after that retry. `AppErrorView` exposes a retry callback; `AppLoadingView` keeps fixed layout dimensions.

- [ ] **Step 5: Verify Flutter quality**

Run:

```bash
cd App
flutter pub get
dart run build_runner build --delete-conflicting-outputs
flutter test
flutter analyze
```

Expected: tests pass and analyzer has no issues.

### Task 7: Implement Figma-Informed Home, Catalog, and Workout Logging

**Files:**
- Create: `App/lib/features/home/data/home_repository.dart`, `App/lib/features/home/domain/home_models.dart`, `App/lib/features/home/presentation/home_page.dart`, `App/lib/features/workouts/data/workout_repository.dart`, `App/lib/features/workouts/domain/workout_models.dart`, `App/lib/features/workouts/presentation/workout_catalog_page.dart`, `App/lib/features/workouts/presentation/log_workout_page.dart`, `App/lib/shared/widgets/section_header.dart`, `App/lib/shared/widgets/workout_card.dart`
- Create: `App/test/features/home/home_page_test.dart`, `App/test/features/workouts/log_workout_page_test.dart`
- Create: `Document/HealthStride/daily/mobile/2026-08-27.md`, `Document/HealthStride/daily/mobile/2026-08-28.md`

**Interfaces:**
- `HomeRepository.fetchHome() -> Future<ApiResult<HomeData>>` calls `GET /v1/home`.
- `WorkoutRepository.fetchCatalog() -> Future<ApiResult<List<WorkoutCatalogItem>>>` calls `GET /v1/workouts/catalog`.
- `WorkoutRepository.logWorkout(LogWorkoutRequest request, String idempotencyKey) -> Future<ApiResult<LoggedWorkout>>` calls `POST /v1/workouts`.

- [ ] **Step 1: Obtain required Figma assets before UI implementation**

Use Figma `get_design_context` for nodes `1:479` and `1:350`, then download only the exact licensed visual assets required by the Home and catalog cards into `App/assets/images/`. Register image assets in `pubspec.yaml`. Reuse existing `AppColors`, `AppTypography`, and `AppTheme`; do not recreate them.

- [ ] **Step 2: Write Home state tests first**

```dart
testWidgets('renders a retry state when Home loading fails', (tester) async {
  await tester.pumpWidget(TestApp(homeResult: ApiResult.failure('NETWORK_ERROR')));
  expect(find.text('Try again'), findsOneWidget);
});

testWidgets('renders the popular workout and today plan on success', (tester) async {
  await tester.pumpWidget(TestApp(homeResult: ApiResult.success(fixtureHomeData)));
  expect(find.text('Popular Workouts'), findsOneWidget);
  expect(find.text('Today Plan'), findsOneWidget);
});
```

- [ ] **Step 3: Write log-workout validation tests**

```dart
testWidgets('blocks a future workout time before submission', (tester) async {
  await tester.pumpWidget(const TestLogWorkoutApp());
  await tester.tap(find.text('Save workout'));
  expect(find.text('Choose a time that is not in the future'), findsOneWidget);
});
```

- [ ] **Step 4: Implement responsive pages and request states**

Build Home with a searchable workout entry, horizontal popular-workout cards, today-plan cards, and an anchored bottom navigation inspired by Figma node `1:479`. Build Explore/catalog from node `1:350` with semantic Flutter cards. The workout form validates positive duration, shows distance only for cardio, generates a UUID idempotency key per submission, disables repeated submit while pending, and displays the server-safe error message on failure.

- [ ] **Step 5: Verify UI tests and visual rendering**

Run:

```bash
cd App
flutter test test/features/home/home_page_test.dart test/features/workouts/log_workout_page_test.dart
flutter analyze
```

Expected: test and analyzer success. Run on iOS Simulator and Android Studio embedded emulator when available; capture screenshots under `Document/HealthStride/evidence/mobile/`.

### Task 8: Implement Weekly Leaderboard, Complete App Flow, and Publish Retrospective

**Files:**
- Create: `App/lib/features/leaderboard/data/leaderboard_repository.dart`, `App/lib/features/leaderboard/domain/leaderboard_models.dart`, `App/lib/features/leaderboard/presentation/leaderboard_page.dart`, `App/integration_test/vertical_slice_test.dart`
- Create: `App/test/features/leaderboard/leaderboard_page_test.dart`, `Backend/tests/integration/test_vertical_slice.py`
- Create: `Document/HealthStride/daily/mobile/2026-08-29.md`, `Document/HealthStride/august-retrospective.md`, `Document/site/src/content/docs/retrospective/august-2026.mdx`

**Interfaces:**
- `LeaderboardRepository.fetchWeekly() -> Future<ApiResult<WeeklyLeaderboard>>` calls `GET /v1/leaderboards/weekly`.
- The app route graph supports onboarding/sign-in -> Home -> catalog -> log workout -> leaderboard.

- [ ] **Step 1: Write leaderboard cache-visible UI tests**

```dart
testWidgets('renders current user rank and top rows', (tester) async {
  await tester.pumpWidget(TestLeaderboardApp(result: fixtureLeaderboard));
  expect(find.text('Weekly leaderboard'), findsOneWidget);
  expect(find.text('Your rank: #3'), findsOneWidget);
});
```

- [ ] **Step 2: Write backend full-flow integration test**

```python
async def test_workout_changes_the_following_weekly_leaderboard(client, authenticated_headers) -> None:
    before = await client.get('/v1/leaderboards/weekly', headers=authenticated_headers)
    created = await client.post('/v1/workouts', headers={**authenticated_headers, 'Idempotency-Key': 'flow-1'}, json=payload)
    after = await client.get('/v1/leaderboards/weekly', headers=authenticated_headers)

    assert created.status_code == 201
    assert after.json()['data']['current_user']['score'] > before.json()['data']['current_user']['score']
```

- [ ] **Step 3: Implement leaderboard state handling and routes**

Show loading skeleton, empty leaderboard, retryable server/network failure, and ranked data. Ensure accessible text labels accompany rank and visual color. Route from the Home navigation to leaderboard and refresh Home/leaderboard after a successful workout.

- [ ] **Step 4: Run complete verification**

Run:

```bash
cd Backend && uv run pytest -q && uv run ruff check . && uv run mypy app
cd ../App && flutter test && flutter analyze
```

Expected: all backend and Flutter checks pass.

- [ ] **Step 5: Complete documentation, build, and deploy**

Write the 31 August retrospective with separate Mobile and Backend sections, measured query/cache results, migration rollback result, API/security results, Figma implementation notes, and next-month Facebook/LINE backlog. Build locally:

```bash
cd Document/site
pnpm build
vercel --prod
```

Expected: local build passes. Vercel deployment requires the user's authenticated Vercel account; record the resulting URL in the retrospective and site configuration only after the command succeeds.

## Plan Self-Review

- Scope coverage: Tasks 1-8 cover every approved architecture, data, API, mobile, quality, documentation, and evidence requirement.
- Dependency order: service foundation -> schema -> protected API -> cache/rate -> performance -> Flutter shell -> mobile features -> flow/deployment.
- Explicit external prerequisites: Firebase project configuration and Vercel authentication are isolated to credentialed commands and do not block local tests that use fakes.
- No Git operations are included because the repository has no commits and the approved work is in-place.
