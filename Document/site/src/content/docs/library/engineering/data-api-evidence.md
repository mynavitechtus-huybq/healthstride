---
title: 'Evidence Data và API'
description: 'EXPLAIN ANALYZE thật, chi tiết Redis cache-aside, migration rollback và rate limit tự viết.'
---

# Evidence Data và API

Trang này gom bằng chứng cụ thể — trích trực tiếp từ code và test trong `Backend/`, không phải mô tả chung chung — cho ba mục tiêu của trụ cột **Data & Database (M1)** và mục tiêu rate limiting của trụ cột **API Design & Integration (M2)**. Đối chiếu với [Báo cáo cải thiện trụ cột kỹ thuật](/library/reports/august-2026-hard-skills-report/) để thấy từng mục tiêu đã được đáp ứng ở đâu.

## Kết quả local

- PostgreSQL và Redis chạy bằng Docker.
- Migration `20260824_02` chạy thành công.
- Seed thành công ít nhất 1.000 user/workout.
- Rollback về `20260821_01` rồi upgrade lại thành công.
- Backend test: `33 passed`.
- Ruff và MyPy không có lỗi.

## 1. `EXPLAIN ANALYZE` và tối ưu index

Ba nhóm query được đo bằng `scripts.query_plans` trên dữ liệu seed (~1.000 dòng).

### Leaderboard — `Index Only Scan` nhờ composite index

```text
Limit  (cost=16.75..16.75 rows=1 width=282) (actual time=0.546..0.552 rows=50 loops=1)
  ->  Sort  (cost=16.75..16.75 rows=1 width=282) (actual time=0.545..0.548 rows=50 loops=1)
        Sort Key: (COALESCE(sum(w.awarded_points), '0'::bigint)) DESC, u.id
        ->  GroupAggregate  (cost=16.72..16.74 rows=1 width=282) (actual time=0.443..0.492 rows=180 loops=1)
              ->  Nested Loop  (cost=0.54..16.71 rows=1 width=278) (actual time=0.045..0.402 rows=180 loops=1)
                    ->  Index Only Scan using ix_workout_logs_leaderboard_logged_at_user_points on workout_logs w
                          (cost=0.27..8.29 rows=1 width=20) (actual time=0.037..0.182 rows=180 loops=1)
                          Index Cond: ((logged_at >= '2026-08-17 00:00:00+00') AND (logged_at < '2026-08-24 00:00:00+00'))
                          Heap Fetches: 180
                    ->  Index Scan using pk_users on users u (cost=0.27..8.29 rows=1 width=274) (actual time=0.001..0.001 rows=1 loops=180)
Execution Time: 0.570 ms
```

`ix_workout_logs_leaderboard_logged_at_user_points` là composite index trên `(logged_at, user_id, awarded_points)`. Nhờ đó PostgreSQL đọc thẳng từ index (`Index Only Scan`) để lọc theo tuần và gom điểm, thay vì quét toàn bảng `workout_logs`.

### Home và lịch sử workout

```text
-- Home
->  Index Scan using ix_workout_catalog_featured_sort on workout_catalog
      (cost=0.14..44.66 rows=30 width=610) (actual time=0.008..0.008 rows=2 loops=1)
      Index Cond: (is_featured = true)
Execution Time: 0.041 ms

-- Lịch sử workout
->  Index Scan Backward using ix_workout_logs_leaderboard_logged_at_user_points on workout_logs
      (cost=0.27..8.29 rows=1 width=114) (actual time=0.380..0.384 rows=1 loops=1)
      Index Cond: ((logged_at >= '2026-08-17 00:00:00+00') AND (logged_at < '2026-08-24 00:00:00+00') AND (user_id = $0))
Execution Time: 0.394 ms
```

Cả hai đều dùng Index Scan trên index có sẵn, không có `Seq Scan` nào trong ba câu query đã đo.

### Giới hạn — việc còn cần làm

Đây chỉ là bản đo **sau khi** đã thêm index, trên dữ liệu seed nhỏ (~1.000 dòng). Mình chưa lưu lại bản đo **trước khi** thêm index để so sánh trực tiếp before/after cùng một query, và chưa benchmark ở quy mô dữ liệu lớn hơn — đây là việc còn để ngỏ ở mục "Việc còn cần củng cố" của báo cáo.

## 2. Redis cache-aside cho leaderboard

Implement ở `app/features/leaderboard/service.py` (`LeaderboardService`), gọi từ `GET /v1/leaderboards/weekly`.

- **TTL:** hằng số `_CACHE_TTL_SECONDS = 60` — mỗi bản leaderboard theo tuần (`leaderboard:weekly:<week-start>`) sống trong cache 60 giây.
- **Invalidation đúng lúc, không theo lịch:** `WorkoutService.log_workout` (`app/features/workouts/service.py`) xoá đúng cache key của tuần chứa buổi tập, ngay sau khi transaction ghi workout vào PostgreSQL thành công — cache chỉ mất hiệu lực khi dữ liệu thật sự đổi.
- **Chống cache stampede:** khi cache miss, một request giữ lock bằng `SET <lock-key> <token> NX EX 1` (`_LOCK_TTL_SECONDS = 1`). Các request khác không giành được lock sẽ poll lại cache mỗi 50 ms, tối đa 20 lần — khoảng 1 giây (`_POLL_INTERVAL_SECONDS`, `_POLL_ATTEMPTS`) — thay vì tự query PostgreSQL cùng lúc. Lock được giải phóng bằng một đoạn Lua chạy nguyên tử, so khớp đúng `token` trước khi `DEL`, để một lock đã hết hạn không xoá nhầm lock của owner mới — đúng lớp bảo vệ mà một `DEL` đơn thuần không có.
- **Test xác nhận đúng hành vi này:**
  - `test_weekly_leaderboard_reads_cached_rows_before_querying_database` — cache hit thì không query database.
  - `test_expired_lock_owner_cannot_delete_a_later_owners_lock` — đúng kịch bản chống stampede: một lock đã hết hạn không được phép xoá lock của owner mới.
  - `test_cached_top_fifty_uses_repository_for_current_users_rank`.

## 3. Migration rollback

```bash
cd Backend
uv run alembic upgrade head
uv run python -m app.db.seed --users 1000
uv run alembic downgrade 20260821_01
uv run alembic upgrade head
```

`upgrade head` thêm `ix_workout_logs_leaderboard_logged_at_user_points`; `downgrade 20260821_01` gỡ đúng index mới và giữ nguyên bảng, dữ liệu; `upgrade head` lần hai tạo lại index và ứng dụng đọc schema bình thường. Mình chọn rollback riêng migration index thay vì rollback toàn bộ schema để giảm rủi ro mất dữ liệu.

**Rủi ro đã ghi lại nhưng chưa test thật:** downgrade migration baseline (`20260821_01`) mang tính phá huỷ — nó xoá toàn bộ bảng `points_transactions`, `workout_logs`, `workout_catalog`, `users` theo đúng thứ tự phụ thuộc ngược. Việc rollback khi có request đang ghi dữ liệu, hoặc khi chính migration đó fail giữa chừng, **chưa được thực hành thật** — đây là gap rõ trong "Việc còn cần củng cố" của báo cáo, không phải điều đã làm xong.

## 4. Rate limiting tự viết — không dùng middleware có sẵn

Implement ở `app/core/rate_limit.py` (`SlidingWindowLimiter`), dùng Redis sorted-set (`ZADD`/`ZREMRANGEBYSCORE`/`ZCARD`) qua một Lua script chạy nguyên tử trong một round-trip — không dùng middleware rate-limit có sẵn của FastAPI/Starlette hay thư viện ngoài.

- GET: 100 request/phút theo user. POST: 10 request/phút theo user.
- Key rate-limit chứa Firebase UID đã xác thực, không dựa vào IP — đúng với yêu cầu "per-user" của matrix.
- Request bị chặn trả về `429` theo error envelope chuẩn của API.
- **Test:** `test_rate_limit_rejects_the_next_post_within_the_window`, `test_rate_limit_allows_requests_after_the_window_expires`, `test_concurrent_requests_never_exceed_the_limit`.

## Chạy lại

```bash
cd Backend
uv run python -m scripts.query_plans --output-dir ../Document/HealthStride/evidence/performance
uv run pytest tests/unit/test_rate_limit.py tests/integration/test_leaderboard_cache.py tests/integration/test_migrations.py -q
```
