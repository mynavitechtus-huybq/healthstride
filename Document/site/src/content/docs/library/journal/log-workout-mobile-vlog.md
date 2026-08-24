---
title: 'Vlog: Ghi nhận Workout trên Mobile - 24 tháng 8 năm 2026'
description: 'Nhật ký nối form Flutter với API, PostgreSQL, Redis và Leaderboard.'
---

# Nhật ký xây dựng: Ghi nhận Workout trên Mobile

> Đây là một ngày có nhiều lỗi thật. Tôi ghi lại để lần sau không lặp lại và để người mới học có thể theo dõi được cả phần khó, không chỉ phần đã chạy thành công.

## Mục tiêu

Sau Leaderboard, tôi làm form ghi workout để kiểm tra chuỗi:

```text
Mobile -> API -> PostgreSQL -> Redis invalidation -> Leaderboard
```

## Mobile: tôi đã làm gì?

- Thêm nút `Log workout` ở Home.
- Tạo form chọn loại workout, nhập duration và nhập distance cho Cardio.
- Gọi `POST /v1/workouts` với Firebase Bearer token.
- Gửi `Idempotency-Key`.
- Hiển thị loading, points, calories và lỗi.

## Backend: tôi đã làm gì?

Endpoint workout xác thực user, validate payload, tính points/calories, ghi Database trong transaction, xóa cache Leaderboard và giới hạn POST theo user.

## Tôi làm như thế nào?

Tôi thêm POST vào `ApiClient`, sau đó tách repository, controller và screen. Mobile không tự tính points; Backend là nơi giữ business rule.

## Khó khăn thật

### Thiếu `API_BASE_URL`

Flutter không tự đọc `.env`, nên phải chạy bằng `--dart-define`. Với iOS Simulator, URL local là `http://127.0.0.1:8000`.

### Enum UI khác enum API

UI dùng chữ dễ hiểu, còn Backend dùng value kỹ thuật:

```text
Strength -> weight_lifting
Flexibility -> yoga
```

Không map hai giá trị này làm API trả `422`.

### Backend trả 500

Sau khi ghi stack trace, tôi tìm thấy lỗi `A transaction is already begun on this Session`. `refresh(user)` sau bước xác thực đã mở transaction đọc, rồi workout lại mở transaction ghi.

### Chạy nhầm Backend

Port `8000` đã có process từ worktree cũ. Tôi phải kiểm tra process và restart Backend đúng từ source hiện tại.

## Cách tôi tháo gỡ

- Map label UI sang enum API.
- Bổ sung POST JSON và idempotency header.
- Bắt exception để nút Save không kẹt loading.
- Hiển thị mã lỗi an toàn ở Mobile.
- Log stack trace ở Backend.
- Đóng transaction sau `refresh()` trước khi mở transaction workout.

## Kinh nghiệm tôi học được

1. Luôn kiểm tra URL và port trước khi debug giao diện.
2. Label UI và enum API cần được mapping rõ ràng.
3. Lỗi 500 cần xem log server, không nên đoán từ Mobile.
4. Một session Database có thể đã mở transaction dù tôi không gọi `begin()` ngay trước đó.
5. Test fake bảo vệ UI, nhưng chỉ manual end-to-end mới phát hiện được lỗi transaction thật.

## Kết quả

- Lưu workout thành công trên iOS Simulator với Firebase token thật.
- Points và calories được Backend trả về.
- Cache Leaderboard được invalidation.
- Backend: `33 passed`.
- Flutter analyzer, Flutter tests và Ruff đều pass.

## Việc còn lại

Merge PR #13 và kiểm tra Leaderboard sau khi lưu workout để xác nhận dữ liệu mới đã được tải lại.
