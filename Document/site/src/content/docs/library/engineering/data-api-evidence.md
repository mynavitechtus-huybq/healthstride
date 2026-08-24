---
title: 'Evidence Data và API'
description: 'Kết quả kiểm tra migration, seed và EXPLAIN ANALYZE trên local.'
---

# Evidence Data và API

## Kết quả local

- PostgreSQL và Redis chạy bằng Docker.
- Migration `20260824_02` chạy thành công.
- Seed thành công ít nhất 1.000 user/workout.
- Rollback về `20260821_01` rồi upgrade lại thành công.
- Backend test: `33 passed`.
- Ruff và MyPy không có lỗi.

## EXPLAIN ANALYZE

Ba nhóm query đã được đo: Home, lịch sử workout và leaderboard. Leaderboard dùng `Index Only Scan` trên index `ix_workout_logs_leaderboard_logged_at_user_points` trong lần đo local.

Số đo này phụ thuộc dữ liệu và máy chạy. Không dùng nó như cam kết production; khi dữ liệu thật lớn hơn cần đo lại.

## Chạy lại

```bash
cd Backend
uv run python -m scripts.query_plans --output-dir ../Document/HealthStride/evidence/performance
```
