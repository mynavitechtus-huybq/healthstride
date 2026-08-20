# Báo cáo Task 4 - Dashboard/Home

Ngày thực hiện: Thursday, August 20, 2026
Worktree: `/Users/macbook_191/Documents/Workspace/Mobile/Fitness Application/.worktrees/feat-dashboard-home`
Branch: `feat/dashboard-home`
Commit: `41bbe9a8469210ab21c49c2f0d980d9942b38f61`

## Mục tiêu

Thực hiện Task 4 của Dashboard/Home plan:

- siết Backend Home contract test theo Flutter decoder fields
- chạy API test bắt buộc
- thử local integration chỉ khi environment hỗ trợ
- tạo daily record tiếng Việt cho Mobile và Backend chỉ với evidence thật
- commit trên branch hiện tại

## Triển khai

### 1. Kiểm tra contract hiện có

Đã đọc `Backend/tests/api/test_auth_and_home.py`, `Backend/app/features/home/service.py`, `Backend/app/features/home/router.py`, và `Backend/app/features/home/schemas.py`.

Kết luận trước khi sửa:

- `/v1/home` đã trả `profile`, `popular_workouts`, và `today_plan`
- `today_plan` được lấy từ `popular_workouts[0]`
- schema field names đã khớp brief:
  - `slug`
  - `name`
  - `description`
  - `workout_type`
  - `duration_minutes`
  - `estimated_calories`
  - `image_url`

### 2. Sửa test ở mức tối thiểu

Đã sửa duy nhất `Backend/tests/api/test_auth_and_home.py` trong test:

- `test_home_upserts_the_verified_identity_and_returns_data`

Assertion mới bao phủ đầy đủ:

- `profile.display_name`
- `profile.email`
- `profile.lifetime_points`
- `profile.available_points`
- `profile.current_streak`
- toàn bộ payload của `popular_workouts[0]`
- `today_plan == popular_workouts[0]`

Không có thay đổi nào ở schema, service, router, migration, hay business rule vì test contract mới đã pass với implementation hiện tại.

## Verification

### API test bắt buộc

Command:

```bash
cd Backend
uv run pytest tests/api/test_auth_and_home.py -q
```

Kết quả:

- `8 passed, 1 warning in 0.76s`
- Warning duy nhất đến từ `StarletteDeprecationWarning` trong `fastapi.testclient`, không phải lỗi contract của Task 4

### Probe local API startup

Do `Backend/.env` không tồn tại và shell không có sẵn biến môi trường backend, đã probe local API bằng biến inline trỏ vào Docker services đang chạy:

```bash
DATABASE_URL=postgresql+asyncpg://healthstride@127.0.0.1:5432/healthstride
REDIS_URL=redis://127.0.0.1:6379/0
uv run fastapi dev app/main.py --host 0.0.0.0 --port 8000
```

Evidence:

- `docker ps --format '{{.Names}}'` trả về:
  - `backend-postgres-1`
  - `backend-redis-1`
- FastAPI log:
  - `Server started at http://0.0.0.0:8000`
- Health probe:

```bash
curl -s http://127.0.0.1:8000/health
```

Kết quả:

- `{"data":{"status":"ok"},"meta":{},"error":null}`

### Local integration trên simulator

Không có evidence để claim manual integration pass.

Đã kiểm tra environment:

- `flutter devices` chỉ thấy:
  - `macOS (desktop)`
  - `Chrome (web)`
- `xcrun simctl list devices booted`: không có iOS simulator nào đang boot
- `adb devices`: không có Android emulator/device nào attached
- `Backend/.env`: thiếu
- `DATABASE_URL`, `REDIS_URL`, `FIREBASE_PROJECT_ID`, `GOOGLE_APPLICATION_CREDENTIALS`: không được export sẵn

Vì vậy chưa thể chạy đúng brief:

- `flutter run` trên iOS simulator hoặc Android emulator
- đăng nhập Google thật
- verify Dashboard hiển thị profile/workout seeded
- kéo để refresh end-to-end

## Files thay đổi

- Sửa:
  - `Backend/tests/api/test_auth_and_home.py`
- Tạo:
  - `Document/HealthStride/daily/backend/2026-08-20.md`
  - `Document/HealthStride/daily/mobile/2026-08-20.md`

## Blocker

1. Không có iOS simulator đang boot hoặc Android emulator đang attach tại thời điểm chạy task.
2. Không có `.env` backend local trong worktree.
3. Không có Firebase Admin credentials local được cấu hình sẵn, nên không thể tạo evidence thật cho Google sign-in và `/v1/home` end-to-end trên local simulator.

## Kết luận

Task 4 đã hoàn tất phần nằm trong khả năng xác minh thật của environment hiện tại:

- contract test đã được siết đúng brief
- API test bắt buộc pass
- local backend startup được probe thành công với Docker services đang chạy
- daily records tiếng Việt đã được ghi với evidence thật và blocker rõ ràng

Phần manual simulator integration chưa thể xác nhận pass do thiếu simulator/emulator active và thiếu Firebase local credentials.

## Bổ sung sau review - Thursday, August 20, 2026

Review issue:

- Assertion mới ở `Backend/tests/api/test_auth_and_home.py` đã over-constrain contract vì dùng equality cho toàn bộ `profile` object và ép `popular_workouts` phải đúng một phần tử.

Fix đã áp dụng:

- đổi assertion `profile` sang kiểm tra từng field bắt buộc:
  - `display_name`
  - `email`
  - `lifetime_points`
  - `available_points`
  - `current_streak`
- đổi assertion `popular_workouts` sang:
  - `assert len(popular_workouts) >= 1`
  - kiểm tra từng field bắt buộc trên `popular_workouts[0]`
- giữ nguyên assertion:
  - `today_plan == popular_workouts[0]`
- không có thay đổi production Backend

Verification bổ sung:

Command:

```bash
cd Backend
uv run pytest tests/api/test_auth_and_home.py -q
```

Kết quả:

- `8 passed, 1 warning in 0.59s`
