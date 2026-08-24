---
title: 'HealthStride: backend daily 2026 08 20'
description: 'Nhật ký và tài liệu tham chiếu của dự án HealthStride.'
---
# Backend Daily Record - 20 August 2026

## Mục tiêu

Kiểm chứng Backend Home contract cho Dashboard/Home và ghi lại evidence thật của lần chạy local.

## Hoàn thành

- Bổ sung assertion đầy đủ trong `Backend/tests/api/test_auth_and_home.py` cho response `/v1/home`:
  - `profile.display_name`
  - `profile.email`
  - `lifetime_points`
  - `available_points`
  - `current_streak`
  - toàn bộ field của `popular_workouts[0]`
  - `today_plan` bằng đúng phần tử đầu tiên của `popular_workouts`
- Chạy `uv run pytest tests/api/test_auth_and_home.py -q` trong `Backend/`.
- Probe local API startup bằng biến môi trường inline trỏ vào Docker services local rồi gọi `GET /health`.

## Evidence

- `uv run pytest tests/api/test_auth_and_home.py -q`
  - Kết quả: `8 passed, 1 warning in 0.76s`
- `docker ps --format '{{.Names}}'`
  - Kết quả có `backend-postgres-1` và `backend-redis-1`
- Khởi động local API với:
  - `DATABASE_URL=postgresql+asyncpg://healthstride@127.0.0.1:5432/healthstride`
  - `REDIS_URL=redis://127.0.0.1:6379/0`
  - `uv run fastapi dev app/main.py --host 0.0.0.0 --port 8000`
  - Log xác nhận: `Server started at http://0.0.0.0:8000`
- `curl -s http://127.0.0.1:8000/health`
  - Kết quả: `{"data":{"status":"ok"},"meta":{},"error":null}`

## Bài học

Home API contract hiện tại đã khớp với Flutter decoder fields trong brief; Task 4 chủ yếu cần siết test contract và xác minh local startup evidence thay vì đổi business rule.

## Rủi ro hoặc blocker

- `Backend/.env` không tồn tại tại thời điểm làm task.
- `DATABASE_URL`, `REDIS_URL`, `FIREBASE_PROJECT_ID`, `GOOGLE_APPLICATION_CREDENTIALS` không được export sẵn trong shell.
- Chưa có Firebase Admin credentials local, nên không thể xác minh thật luồng `/v1/home` với Google ID token trên môi trường local trong record này.

## Hành động tiếp theo

Khi có Firebase project config và ADC local hợp lệ, chạy simulator/emulator sign-in flow để xác minh Dashboard hiển thị dữ liệu seed và refresh end-to-end.
