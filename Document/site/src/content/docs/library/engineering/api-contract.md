---
title: 'API Contract'
description: 'Envelope response, endpoint và quy ước lỗi dùng chung của HealthStride API.'
---
# API Contract — HealthStride

Đây là tài liệu mình dùng làm điểm tựa mỗi khi mở một endpoint mới: envelope response, cách xác thực, và những giới hạn request cần nhớ. Ban đầu mình hay quên field nào bắt buộc, nên viết hẳn ra đây để tra lại thay vì đoán.

## Envelope

Mọi endpoint đều trả về cùng một envelope ở tầng ngoài cùng:

```json
{
  "data": {},
  "meta": {},
  "error": null
}
```

`data` chứa kết quả của endpoint khi thành công. `meta` là object dành riêng cho metadata của response. Khi có lỗi, `data` là `null`, `meta` vẫn là object, còn `error` chứa một mã lỗi ổn định cùng thông điệp an toàn để hiển thị cho người dùng.

Lỗi validate request trả về HTTP `422` với `error.code` là `REQUEST_VALIDATION_FAILED` và `error.message` là `Request validation failed.`. Giá trị `error.details` (không bắt buộc) là danh sách lỗi theo field gồm `loc`, `msg`, `type`; giá trị input không hợp lệ sẽ không bị echo lại.

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

`GET /v1/me` và `GET /v1/home` yêu cầu header Authorization:

```http
Authorization: Bearer <Firebase ID token>
```

API xác thực token ở phía server qua Firebase Admin trước khi đọc hoặc ghi dữ liệu user local. Firebase UID, email và display name đã được xác thực là các input định danh duy nhất dùng để upsert user local. Header định danh hoặc user identifier do client gửi lên trong request body không bao giờ được chấp nhận làm nguồn xác thực.

Token bị thiếu, sai định dạng, hết hạn, bị thu hồi hoặc không hợp lệ đều trả về `401 AUTHENTICATION_REQUIRED` trong error envelope.

Firebase Admin khởi tạo default app một lần duy nhất trước khi verify token, dùng Firebase project ID đã cấu hình và Application Default Credentials, kể cả đường dẫn `GOOGLE_APPLICATION_CREDENTIALS` nếu có cấu hình. API không nhúng sẵn service-account credentials trong code.

Việc ghi identity local là một atomic upsert trong PostgreSQL, khóa theo Firebase UID đã xác thực. Những lần thay đổi email hoặc display name sau này chỉ cập nhật đúng các field định danh đó; điểm tích lũy và streak được giữ nguyên.

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

Endpoint này upsert identity đã xác thực ở server, sau đó trả về profile summary local.

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

Payload của Home chỉ được dựng từ schema `users` và `workout_catalog` của tháng 8. `popular_workouts` chứa các dòng catalog nổi bật theo đúng thứ tự sắp xếp, còn `today_plan` là dòng đầu tiên trong đó, hoặc `null` nếu chưa có workout nổi bật nào.

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

## Tài liệu API tự sinh

OpenAPI mô tả có cấu trúc cả envelope thành công `200` lẫn envelope lỗi `401` cho hai endpoint được bảo vệ. Swagger UI là tài liệu tham chiếu tự sinh cho schema `profile`, Home và authentication envelope. Lỗi routing cũng dùng chung envelope lỗi chuẩn.

## Giới hạn request và cache

- GET theo user: tối đa 100 request/phút.
- POST theo user: tối đa 10 request/phút.
- Rate limit dùng Redis sliding window và Lua script nguyên tử.
- Leaderboard dùng cache-aside, TTL 60 giây, invalidation sau khi ghi workout.
- Lock cache có token để request cũ không xóa nhầm lock của request mới.

## Provider đăng nhập

Trong scope tháng 8, Mobile dùng Google Sign-In và Backend kiểm tra Firebase ID token. Facebook và LINE vẫn là backlog cho slice riêng; secret không được đưa vào source code hoặc tài liệu public.
