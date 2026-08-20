# HealthStride Dashboard/Home Delivery Design

**Status:** Approved for planning

**Goal:** Replace the authenticated Hello screen with a responsive Dashboard that renders the verified user's Home summary from `GET /v1/home`, while publishing an evidence-led Mobile and Backend Vlog for the feature.

## Scope

This delivery implements only the data already provided by the August Home contract:

- personalized greeting from `profile.display_name`;
- lifetime points, available points, and current streak;
- one Today Plan card when `today_plan` exists;
- a Popular Workouts list from `popular_workouts`;
- initial loading, retryable failure, and pull-to-refresh states;
- an authenticated bearer request using a freshly obtained Firebase ID token.

The following stay out of this delivery: level progress, goals, challenges, badges, reward store, navigation tabs, workout logging, local persistent cache, and automatic sign-out on a `401`. Those requirements remain future slices because the current `/v1/home` contract does not yet provide their data or destination flows.

## Architecture

### Mobile boundaries

`App/lib/features/home` becomes a feature-first module with three layers:

| Layer | Responsibility |
| --- | --- |
| `domain` | Immutable dashboard models and the `HomeRepository` interface. No Flutter or HTTP dependency. |
| `data` | `ApiHomeRepository`, which calls `GET /v1/home` through the existing `ApiClient`, decodes the success envelope, and returns a typed result. |
| `presentation` | `HomeController` owns loading, refreshing, data, and failure state. Dashboard widgets render those states and invoke `load` or `refresh`. |

The app composition root creates the production transport with `package:http`, obtains the Firebase ID token through `AuthRepository`, and passes dependencies into the signed-in Home screen. `API_BASE_URL` comes only from `--dart-define`; there is no committed local URL or secret.

`AuthRepository` gains one token method, `Future<String?> getIdToken({bool forceRefresh = false})`. Its Firebase implementation delegates to the active Firebase user. The API client already accepts a token provider, so no Firebase or HTTP type leaks into the Home domain layer.

### Data flow

1. Firebase Auth emits an authenticated `AuthUser`.
2. The app builds the Home feature with an `ApiClient` whose token provider asks `AuthRepository` for the current ID token.
3. `HomeController.load()` enters initial loading and asks `HomeRepository.fetchDashboard()` for data.
4. `ApiHomeRepository` calls `/v1/home`; `ApiClient` adds `Accept: application/json` and `Authorization: Bearer <Firebase ID token>`.
5. FastAPI verifies the token, upserts the local user, reads featured workouts, and returns the standard `{ data, meta, error }` envelope.
6. The repository decodes `data.profile`, `data.today_plan`, and `data.popular_workouts` into domain models. The controller publishes the success state; the screen renders it.
7. A pull-to-refresh calls the same repository operation while keeping previous data on screen. A successful future Log Workout slice can call the controller refresh when it returns to Home.

## Presentation Design

The screen adapts `SCR-HOME-10` and the established dark `AppTheme` without absolute-positioned Figma copying. It is one vertically scrollable screen with a `SafeArea`:

1. top row: `HealthStride` and a sign-out icon button;
2. greeting using the first non-empty display-name fallback, then email, then `Athlete`;
3. a compact metrics band for Lifetime points, Available points, and current streak;
4. Today Plan as the primary card, or a friendly empty message when `today_plan` is null;
5. Popular Workouts as compact cards with workout type, duration, calories, and description.

Cards use the design-system spacing, Lato typography, neutral surfaces, and accent colors. Image URLs are not loaded in this slice because the seeded contract returns `null`; the card uses an icon selected from `workout_type` instead. Text wraps and the layout stays usable on both iPhone and Android phone widths.

## Error Handling

| Situation | Controller state | User experience |
| --- | --- | --- |
| First request pending | loading without data | structured progress placeholders; sign-out stays available |
| Refresh pending with data | refreshing with data | `RefreshIndicator`; existing data remains visible |
| Network, timeout, malformed JSON, `5xx`, or non-auth envelope error | failure | retryable in-content error with a Retry button; no raw backend error details |
| `401 AUTHENTICATION_REQUIRED` | failure | user-safe session message and Retry. This slice does not sign out automatically; automatic refresh/sign-out is a dedicated auth lifecycle change. |
| Valid payload with no featured workout | success | metrics plus the Today Plan empty message and an empty Popular Workouts section |

The UI uses the stable `ApiFailure.code` only for control flow and tests. It renders curated copy rather than exposing backend messages or exceptions.

## Testing Strategy

### Flutter

- Unit-test `ApiHomeRepository` with a fake `ApiClient`: success decoding, `today_plan: null`, error propagation, and invalid payload handling.
- Unit-test `HomeController`: initial load success, refresh keeps previous data, and failure/retry state.
- Widget-test Dashboard: loading, error with Retry, empty plan, and populated summary; assert metrics and workout titles are visible.
- Extend the authenticated app test to verify the previous Hello greeting is replaced by the Dashboard entry state.
- Run `flutter analyze` and the complete `flutter test` suite. Manually run the app against local FastAPI using a simulator-specific base URL documented in the Vlog.

### Backend

The endpoint is already implemented and tested. This slice runs the existing Home API test suite as a contract regression check. If the mobile decoder exposes an ambiguity, add the smallest backend contract test that makes the response shape explicit; no unrelated backend refactor is in scope.

### Documentation site

Run `pnpm build` in `Document/site`. The published Vlog pages must be reachable under distinct `daily/mobile` and `daily/backend` routes and be included in their respective indexes.

## Vlog Documentation Format

Each feature has two public MDX entries, one in `Document/site/src/content/docs/daily/mobile/` and one in `Document/site/src/content/docs/daily/backend/`. The existing Markdown diary under `Document/HealthStride/daily/` remains the detailed project record; the MDX pages are the reader-facing Vlog.

Every Vlog entry follows the same narrative sequence:

1. **What I built**: user outcome, scope boundary, and the UI/API artifact.
2. **How I built it**: the smallest useful architecture diagram in prose, key decisions, commands, and tests.
3. **What was difficult**: a real integration constraint or discovery from the work. It must not invent a problem; when no blocker occurs, it explicitly states that and explains the risk checked.
4. **How I resolved it**: diagnosis, option considered, implementation choice, and verification evidence.
5. **What I learned**: reusable engineering lesson connected to the hard-skills matrix.

The Mobile Vlog focuses on Firebase ID-token injection, typed envelopes, state ownership, simulator-to-local-server networking, and widget tests. The Backend Vlog focuses on maintaining a mobile-consumable contract, verified identity boundaries, regression tests, and why no backend expansion was needed for this screen.

## Acceptance Criteria

- An authenticated user sees Dashboard data from the local FastAPI `/v1/home` endpoint, not a hard-coded greeting.
- Each request sends a Firebase ID token in the Bearer header.
- The Dashboard has loading, populated, empty-plan, refresh, failure, and Retry states.
- The UI uses the existing dark theme and Lato design tokens and remains readable on iPhone and Android phone widths.
- No base URL, Firebase credential, token, or local `.env` value is committed.
- Flutter feature tests, complete Flutter tests, static analysis, Backend contract tests, and Documentation build pass.
- Mobile and Backend Vlog entries are published through the Vercel-bound Astro site and include evidence from the implementation.

## Trade-offs

- A lightweight controller is chosen over Riverpod/BLoC because this is one remote read feature and there is no shared state graph yet. The repository interface preserves a clean migration path.
- No persistent offline cache is added. Pull-to-refresh and retry deliver the needed behavior without introducing storage invalidation policy before Workout logging exists.
- `401` remains retryable rather than forcing sign-out. Token refresh and sign-out behavior need a cross-feature auth policy and will be designed separately.
- The UI intentionally renders only fields provided by the current backend contract. It does not fake level, goals, challenges, or rewards to imitate a larger Figma screen.
