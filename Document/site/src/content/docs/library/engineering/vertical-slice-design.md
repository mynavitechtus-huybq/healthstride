---
title: 'HealthStride: vertical slice design'
description: 'Tài liệu nghiệp vụ, kế hoạch và kiến trúc của HealthStride.'
---
# HealthStride August Vertical Slice Design

**Status:** Approved design

**Goal:** Deliver a working fitness vertical slice by 31 August 2026 while producing concrete evidence for the Fullstack Engineer Hard Skills Matrix.

## Scope

The August slice contains:

- Onboarding, Google sign-in, Home, workout logging, and weekly leaderboard.
- Flutter application UI based on the existing Lato design system and the supplied Figma language.
- Firebase Authentication, FastAPI, PostgreSQL, Alembic, and Redis.
- A public technical documentation site deployed on Vercel.

Out of scope for August:

- Facebook and LINE sign-in implementation. Their provider flows are documented as September backlog items.
- Reward redemption, social feed, teams, challenges, nutrition, water, sleep, and full profile management.
- Firebase Firestore as an application database.

## Architecture

Flutter owns presentation and sends the Firebase ID token as a Bearer token to FastAPI. FastAPI verifies the token with Firebase Admin, upserts the local profile in PostgreSQL, and owns all business rules. PostgreSQL is the source of truth; Redis is used only for rate limiting and cached leaderboard reads. Firebase owns Authentication, Cloud Messaging, and Analytics.

Document is a separate Astro static site under `Document/site`. It consumes Markdown content from `Document/HealthStride` and deploys to Vercel.

## Mobile Feature Flow

1. The onboarding screen follows Figma node `1:604` and routes users to sign-in.
2. Google sign-in is handled by Firebase Authentication.
3. After authentication, Home follows Figma node `1:479` and loads profile, popular workouts, and the current plan.
4. The user selects a workout from the lightweight Explore/catalog experience informed by node `1:350`, then records a completed workout.
5. The app reloads the Home summary and weekly leaderboard.

Flutter uses feature-first modules: `auth`, `home`, `workouts`, `leaderboard`, and shared UI primitives. All screens use the existing `AppTheme`, Lato assets, and semantic colors. Figma reference layouts are adapted to responsive Flutter widgets rather than copied as absolute-positioned layouts.

## Backend Data Flow

### Authentication

1. Flutter receives a Firebase ID token from Google sign-in.
2. Flutter calls FastAPI with `Authorization: Bearer <Firebase ID token>`.
3. FastAPI verifies the token using Firebase Admin and uses the verified Firebase UID as the identity boundary.
4. FastAPI creates or updates the corresponding local `users` row.

### Workout Write

`POST /v1/workouts` requires a request `Idempotency-Key`. In a single PostgreSQL transaction, FastAPI creates a workout log, calculates points, creates a points transaction, updates the user summary and streak, and commits. It then invalidates the affected weekly leaderboard cache key. Any failure rolls back the entire transaction.

### Leaderboard Read

`GET /v1/leaderboards/weekly` first reads `leaderboard:weekly:<week-start>` from Redis. On miss, one request owns a short-lived Redis lock, queries PostgreSQL, stores the rendered leaderboard with a 60-second TTL, and releases the lock. Concurrent readers wait briefly and retry the cache rather than creating a database stampede. A successful workout write deletes the weekly cache key immediately.

### Rate Limiting

FastAPI implements a Redis sorted-set sliding window keyed by verified Firebase UID. GET requests allow 100 requests per minute and mutation requests allow 10 requests per minute. A rejected request returns `429` with a machine-readable rate-limit error.

## Initial Data Model

- `users`: Firebase UID, display name, email, lifetime points, available points, current streak, created/updated timestamps.
- `workout_logs`: user reference, workout type, duration, distance, logged time, calculated calories, awarded points, capped flag, idempotency key.
- `points_transactions`: user reference, source type and reference, lifetime delta, available delta, created timestamp.
- `workout_catalog`: seed-only catalog used by Home and the lightweight Explore view.

The schema applies the existing HealthStride business rules: workouts below 10 minutes are stored but receive no points; a workout award is capped at 300; a daily award is capped at 500; lifetime points never decrease; available points must not become negative.

## API Contract

All FastAPI responses use one envelope:

```json
{
  "data": {},
  "meta": {},
  "error": null
}
```

Errors use the same shape, with `data` set to `null` and an error object containing a stable code and user-safe message. Status code policy: `401` invalid or expired token, `403` authorization failure, `409` duplicate idempotency key, `422` request validation failure, `429` rate limited, and `500` unexpected server failure without stack traces.

Initial endpoints:

- `GET /v1/me`
- `GET /v1/home`
- `GET /v1/workouts/catalog`
- `POST /v1/workouts`
- `GET /v1/leaderboards/weekly`
- `GET /health`

OpenAPI and Swagger UI are enabled and treated as the generated API reference.

## Quality And Security

- Alembic migrations must define both `upgrade` and `downgrade`, with a local forward-and-rollback verification before use.
- Secrets are environment variables and are never committed.
- Firebase ID tokens are verified server-side. The API never trusts a client-supplied user ID.
- Flutter presents loading, empty, retryable error, and unauthenticated states for every remote feature.
- Token refresh is attempted once; failed refresh returns the user to sign-in.

## Test And Evidence Strategy

- Python unit tests: points, streak, request validation, rate-window decisions, cache-key behavior.
- Python integration tests: PostgreSQL transaction behavior, Redis cache-aside, invalidation, lock/stampede behavior, authenticated HTTP API.
- API tests use a Firebase verifier fake; production uses Firebase Admin.
- Flutter: unit tests for repositories/use cases; widget tests for all loading, empty, error, and success states; integration smoke test against the local API.
- Database performance: seed at least 1,000 rows, capture `EXPLAIN ANALYZE` for Home, workout history, and leaderboard before and after composite indexes, and publish measured deltas.
- Performance evidence covers uncached, cached, and concurrent leaderboard requests.

## Documentation Site

`Document/site` is an Astro site deployed to Vercel. Its content is Markdown and includes:

- Architecture and API contract pages.
- Data and performance reports, migration diary, and security notes.
- Daily entries under `daily/mobile` and `daily/backend`.
- August retrospective.

Every daily entry records objective, work completed, command/test/metric evidence, lesson learned, risk or blocker, and next action. The site makes Mobile and Backend learning trails independently navigable.

## Matrix Evidence Mapping

| Matrix pillar | August evidence |
| --- | --- |
| Programming & Frameworks | Flutter feature modules and FastAPI module delivered end-to-end. |
| Software Design & Architecture | Approved design, feature boundaries, ADRs for Firebase/Python/PostgreSQL/Redis. |
| Data & Database | Schema, Alembic up/down, seeded data, EXPLAIN ANALYZE, composite index, Redis cache-aside. |
| API Design & Integration | Firebase token verification, stable response envelope, OpenAPI, custom rate limiting. |
| UI/UX Engineering | Responsive Flutter adaptation of the approved Figma screens plus all remote UI states. |
| Testing & QA | Unit, integration, widget, and smoke-test evidence. |
| Performance & Optimization | Before/after query plans and cached versus uncached leaderboard measurements. |
| Security Engineering | Server-side token verification, environment secrets, validation, rate limiting, error redaction. |
| Engineering Process | Feature backlog, DoR/DoD, review record, daily evidence. |
| Technical Documentation | Vercel documentation site, API docs, migration diary, measured retrospective. |
| Business & Domain Understanding | Existing HealthStride entities and point/streak rules reflected in the implementation. |

## Schedule

| Dates | Outcome |
| --- | --- |
| 19-20 August | FastAPI/PostgreSQL/Alembic/Redis and Firebase foundations; Astro site and daily templates. |
| 21-23 August | Schema, seed data, migration upgrade/downgrade, query-plan baseline, indexes. |
| 24-26 August | Google Auth, Firebase token verification, API envelope, Swagger, custom rate limiter, Redis leaderboard. |
| 27-29 August | Flutter onboarding, sign-in, Home, catalog/workout log, leaderboard. |
| 30 August | Integration testing, performance evidence, security review. |
| 31 August | Vercel deploy and Mobile/Backend retrospectives. |
