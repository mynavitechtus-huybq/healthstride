# Evidence migration và index - 24 tháng 8 năm 2026

## Các lệnh đã chạy

```bash
cd Backend
uv run alembic upgrade head
uv run python -m app.db.seed --users 1000
uv run alembic downgrade 20260821_01
uv run alembic upgrade head
```

## Kết quả mong đợi

- `upgrade head` thêm `ix_workout_logs_leaderboard_logged_at_user_points`.
- `downgrade 20260821_01` gỡ đúng index mới, giữ nguyên các bảng và dữ liệu.
- `upgrade head` tạo lại index và ứng dụng tiếp tục đọc được schema.

## Ý nghĩa

Tôi chọn rollback riêng migration index thay vì rollback toàn bộ schema. Cách này giảm rủi ro mất dữ liệu. Trước khi chạy trên môi trường thật vẫn cần backup, kiểm tra lock của PostgreSQL và có kế hoạch rollback rõ ràng.
