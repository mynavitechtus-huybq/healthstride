---
title: 'Vlog: Ghi nhận Workout trên Mobile - 24 tháng 8 năm 2026'
description: 'Phạm vi và bài học dự kiến khi nối form Flutter với API ghi workout.'
---

# Nhật ký xây dựng: Ghi nhận Workout trên Mobile

## Phạm vi đã chốt

Sau Leaderboard, tôi làm form ghi workout để kiểm tra một vòng đi đầy đủ: Mobile gửi dữ liệu, Backend tính điểm, Redis xóa cache cũ và Leaderboard có thể tải dữ liệu mới.

## Mobile

### Hôm nay tôi đã làm gì?

- Tạo form chọn loại workout, nhập số phút và nhập quãng đường nếu là cardio.
- Thêm nút mở form từ Home.
- Gửi `POST /v1/workouts` cùng `Idempotency-Key`.
- Hiển thị trạng thái đang gửi, thành công và lỗi.

### Tôi làm như thế nào?

Tôi thêm khả năng POST vào `ApiClient`, rồi tạo repository và controller riêng cho workout. UI chỉ phụ trách form và trạng thái; việc tính calories, points và invalidation cache vẫn do Backend xử lý.

### Tôi gặp khó khăn gì?

ApiClient ban đầu mới hỗ trợ GET. Widget test cũng cần mở dropdown trước khi chọn loại workout.

### Tôi tháo gỡ ra sao?

Tôi thêm POST JSON request có Bearer token và idempotency header. Test được viết theo đúng thứ tự thao tác của người dùng.

### Tôi học được gì?

Validation, loading và lỗi phải được thiết kế cùng lúc với form. Repository fake giúp tôi kiểm tra UI nhanh mà không phụ thuộc môi trường Backend.

## Backend

Tôi dùng endpoint `POST /v1/workouts` đang có sẵn. Backend đã có validation, rate limit theo user và invalidation cache Leaderboard.

## Kiểm tra

- `flutter analyze`: không lỗi.
- `flutter test`: pass.
- Widget test kiểm tra submit cardio và chặn duration không hợp lệ.

## Lỗi phát sinh khi chạy thật

Strength và Flexibility bị `422` vì UI gửi label kỹ thuật khác enum Backend. Backend nhận `weight_lifting` và `yoga`, nên Mobile cần map label dễ hiểu sang value API. Cardio qua được validation nhưng đang trả `500`, cần xem log Backend để sửa đúng nguyên nhân thay vì đoán.

Leaderboard cũng đang chỉ hiện một câu lỗi chung. Tôi sẽ cho hiển thị message an toàn từ API để việc kiểm tra local dễ hiểu hơn.

Form workout cũng cần bắt exception ngoài dự kiến để không kẹt nút Save ở trạng thái loading. Mã lỗi sẽ được hiển thị để kiểm tra local rõ ràng hơn.

## Mục tiêu học tập

Tôi muốn hiểu rõ hơn cách một form Flutter giữ trạng thái, chờ API trả lời và không tạo dữ liệu trùng khi người dùng bấm nút nhiều lần.

## Việc chưa làm

Chưa kiểm tra manual end-to-end với PostgreSQL, Redis và Firebase token thật trên iOS Simulator.
