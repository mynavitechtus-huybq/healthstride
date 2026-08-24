# Nhật ký xây dựng: Ghi nhận Workout trên Mobile

## Phạm vi đã chốt

Sau khi Leaderboard gọi được dữ liệu tuần, bước tiếp theo là cho người dùng ghi một workout từ Mobile. Màn hình này sẽ gửi workout lên Backend, hiển thị kết quả điểm vừa nhận và tạo nền tảng để kiểm tra Leaderboard được cập nhật sau khi cache bị invalidation.

## Mobile

### Hôm nay tôi đã làm gì?

- Tạo form ghi workout với loại bài tập, số phút và quãng đường tùy loại cardio.
- Thêm nút `Log workout` vào Home để mở form.
- Gửi request `POST /v1/workouts` kèm `Idempotency-Key`.
- Hiển thị loading, kết quả điểm/calories và lỗi API.

### Tôi làm như thế nào?

Tôi thêm `PostRequest` vào `ApiClient`, tạo repository riêng cho workout và giữ controller tách khỏi UI. Form chỉ cho nhập distance khi workout là cardio, còn thời gian gửi lấy từ thời điểm hiện tại.

### Tôi gặp khó khăn gì?

`ApiClient` lúc đầu chỉ có GET nên form chưa thể gửi dữ liệu. Test dropdown cũng không thể bấm trực tiếp khi menu chưa mở.

### Tôi tháo gỡ ra sao?

Tôi thêm POST request có JSON body, tự thêm authorization và idempotency header. Trong widget test, tôi mở dropdown rồi mới chọn Cardio, giống trình tự người dùng thao tác thật.

### Tôi học được gì?

Một form nhỏ vẫn cần nhiều trạng thái: validate, đang gửi, thành công và lỗi. Tách repository giúp test form không cần chạy Backend thật.

### Kiểm tra

- `flutter analyze`: không có lỗi.
- `flutter test`: tất cả test pass.
- Test form: kiểm tra cardio có distance và chặn duration bằng 0.

### Lỗi phát sinh sau khi chạy thật

Khi chọn Strength hoặc Flexibility, API trả `422` vì label trên form chưa trùng enum Backend. Backend dùng `weight_lifting` và `yoga`, còn UI đang gửi `strength` và `flexibility`. Cardio đi qua validation nhưng vẫn cần kiểm tra log Backend vì đang trả `500`.

Leaderboard cũng đang có thông báo chung khi request thất bại. Tôi sẽ hiển thị message an toàn từ `ApiFailure` để biết lỗi nằm ở token, URL, rate limit hay Backend.

## Backend

Backend đã có endpoint `POST /v1/workouts`, rate limit POST theo user và invalidation cache Leaderboard. Trong slice này tôi sẽ dùng contract hiện tại, chưa thay đổi business rule.

## Việc chưa làm

Chưa kiểm tra manual end-to-end với PostgreSQL, Redis và Firebase token thật trên iOS Simulator.
