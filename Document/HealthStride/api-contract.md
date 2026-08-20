# HealthStride API Contract

## Envelope

Every endpoint returns the same top-level envelope:

```json
{
  "data": {},
  "meta": {},
  "error": null
}
```

`data` contains the endpoint result on success. `meta` is an object reserved for response metadata. On error, `data` is `null`, `meta` remains an object, and `error` contains a stable code and a user-safe message.

Request validation errors return HTTP `422` with `error.code` set to `REQUEST_VALIDATION_FAILED` and `error.message` set to `Request validation failed.`. The optional `error.details` value is a list of safe field errors containing `loc`, `msg`, and `type`; invalid input values are not echoed.

```json
{
  "data": null,
  "meta": {},
  "error": {
    "code": "AUTHENTICATION_REQUIRED",
    "message": "A valid Bearer token is required."
  }
}
```

## Authentication

`GET /v1/me` and `GET /v1/home` require an HTTP Authorization header:

```http
Authorization: Bearer <Firebase ID token>
```

The API verifies the token server-side through Firebase Admin before it reads or writes local user data. The verified Firebase UID, email, and display name are the only identity inputs used to upsert the local user. Client-supplied identity headers and request-body user identifiers are never accepted as authority.

Missing, malformed, expired, revoked, or invalid tokens return `401 AUTHENTICATION_REQUIRED` in the error envelope.

Firebase Admin initializes its default app once before token verification. It uses the configured Firebase project ID and Application Default Credentials, including a configured `GOOGLE_APPLICATION_CREDENTIALS` path when supplied. The API does not embed service-account credentials.

The local identity write is a PostgreSQL atomic upsert keyed by the verified Firebase UID. Later verified email or display-name changes update only those identity fields; accumulated points and streak values are preserved.

## Endpoints

### `GET /health`

```json
{
  "data": {"status": "ok"},
  "meta": {},
  "error": null
}
```

### `GET /v1/me`

The endpoint upserts the server-verified identity, then returns the local profile summary.

```json
{
  "data": {
    "profile": {
      "display_name": "Ari",
      "email": "user@example.com",
      "lifetime_points": 0,
      "available_points": 0,
      "current_streak": 0
    }
  },
  "meta": {},
  "error": null
}
```

### `GET /v1/home`

The home payload is assembled only from the August `users` and `workout_catalog` schema. `popular_workouts` contains featured catalog rows in sort order, and `today_plan` is the first row or `null` when no featured workout exists.

```json
{
  "data": {
    "profile": {
      "display_name": "Ari",
      "email": "user@example.com",
      "lifetime_points": 0,
      "available_points": 0,
      "current_streak": 0
    },
    "popular_workouts": [
      {
        "slug": "morning-cardio",
        "name": "Morning Cardio",
        "description": "A focused cardio session to start the day.",
        "workout_type": "cardio",
        "duration_minutes": 30,
        "estimated_calories": 220,
        "image_url": null
      }
    ],
    "today_plan": {
      "slug": "morning-cardio",
      "name": "Morning Cardio",
      "description": "A focused cardio session to start the day.",
      "workout_type": "cardio",
      "duration_minutes": 30,
      "estimated_calories": 220,
      "image_url": null
    }
  },
  "meta": {},
  "error": null
}
```

## Generated API Reference

OpenAPI documents structured `200` success envelopes and `401` error envelopes for both protected endpoints. Swagger UI is the generated reference for the `profile`, Home, and authentication-envelope schemas. Routing errors also use the standard error envelope.
