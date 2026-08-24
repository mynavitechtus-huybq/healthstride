# Nhật ký xây dựng: Ghi nhận Workout trên Mobile

> Đây là một ngày khá nhiều lỗi nhỏ. Nhờ vậy tôi hiểu rõ hơn cách một form Flutter đi qua API, Database và Redis.

## Mục tiêu trong ngày

Sau khi làm xong Leaderboard, tôi muốn người dùng có thể ghi lại một workout ngay trên Mobile. Tôi cũng muốn kiểm tra được chuỗi hoạt động đầy đủ:

```text
Mobile -> API -> PostgreSQL -> Redis invalidation -> Leaderboard
```

## Mobile: tôi đã làm gì?

- Thêm nút `Log workout` ở Home.
- Tạo form chọn loại workout, nhập số phút và nhập quãng đường cho Cardio.
- Gọi `POST /v1/workouts` với Firebase Bearer token.
- Gửi `Idempotency-Key` để tránh tạo bản ghi trùng.
- Hiển thị trạng thái đang gửi, thành công và lỗi.
- Hiển thị số calories và points Backend trả về.

## Tôi đã làm như thế nào?

Tôi mở rộng `ApiClient` để hỗ trợ POST JSON. Sau đó tôi tách thành ba phần:

1. `ApiWorkoutRepository` chuẩn bị payload và đọc response.
2. `LogWorkoutController` giữ trạng thái submit.
3. `LogWorkoutScreen` chỉ phụ trách form và hiển thị kết quả.

Tôi để Backend tính calories và points. Mobile chỉ gửi dữ liệu và hiển thị kết quả, vì nếu Mobile tự tính điểm thì hai bên có thể cho ra kết quả khác nhau.

## Backend: tôi đã làm gì?

Backend đã có sẵn endpoint `POST /v1/workouts`. Endpoint này:

- Xác thực Firebase user.
- Kiểm tra dữ liệu workout.
- Tính points và calories.
- Ghi workout và points transaction trong một transaction Database.
- Xóa cache Leaderboard sau khi lưu thành công.
- Giới hạn POST tối đa 10 request mỗi phút theo user.

## Những khó khăn tôi gặp phải

### 1. Không chạy được App vì thiếu API base URL

Khi chạy Flutter bình thường, app báo:

```text
API base URL must be an absolute URI.: ""
```

Tôi quên rằng Flutter không tự đọc `.env`. URL phải truyền bằng `--dart-define` khi chạy app.

### 2. Strength và Flexibility bị lỗi validation

Form hiển thị `Strength` và `Flexibility`, nhưng tôi gửi luôn hai chữ này lên API. Backend lại dùng enum:

```text
Strength -> weight_lifting
Flexibility -> yoga
```

Vì vậy API trả `422 Request validation failed`.

### 3. Cardio trả lỗi 500

Cardio qua được validation nhưng Backend trả:

```text
INTERNAL_SERVER_ERROR: An unexpected error occurred
```

Ban đầu tôi chưa biết lỗi nằm ở đâu vì API cố tình không trả stack trace về Mobile.

### 4. Port 8000 đã bị chiếm

Tôi chạy Backend mới nhưng nhận lỗi `address already in use`. Sau khi kiểm tra process, tôi phát hiện một Backend khác đang chạy từ worktree cũ. Điều này làm tôi dễ nhầm rằng code hiện tại đã được dùng.

### 5. SQLAlchemy báo transaction đã được mở

Traceback cuối cùng cho thấy lỗi thật:

```text
A transaction is already begun on this Session.
```

Sau bước xác thực, `refresh(user)` đã mở một transaction đọc. Workout service lại gọi `session.begin()` để mở transaction ghi nên bị lỗi.

## Tôi đã tháo gỡ ra sao?

- Chạy Flutter với URL đúng cho iOS Simulator: `http://127.0.0.1:8000`.
- Map label thân thiện của UI sang enum Backend chuẩn.
- Bắt exception ở Mobile để nút Save không bị kẹt loading.
- Hiển thị mã lỗi an toàn trên Mobile.
- Ghi stack trace ở Backend nhưng không trả thông tin nhạy cảm về client.
- Đóng transaction sau bước `refresh()` của user trước khi workout mở transaction mới.
- Restart Backend đúng từ thư mục source hiện tại.

## Kinh nghiệm tôi rút ra

1. Khi app dùng `--dart-define`, cần kiểm tra URL ngay từ lệnh chạy đầu tiên.
2. Label hiển thị cho người dùng và enum gửi lên API không nhất thiết giống nhau. Nên có mapping rõ ràng.
3. Một request thành công không chỉ phụ thuộc vào UI. Nó còn phụ thuộc vào auth, Database, Redis và transaction lifecycle.
4. Khi API trả lỗi 500, không nên đoán. Cần log stack trace ở server và giữ message an toàn ở client.
5. Khi dùng SQLAlchemy, phải biết query hoặc `refresh()` có thể tự mở transaction.
6. Không nên chạy nhiều worktree Backend cùng một port vì rất dễ kiểm tra nhầm source code.
7. Test fake giúp kiểm tra UI nhanh, nhưng manual end-to-end với Database thật vẫn rất cần thiết.

## Kết quả cuối cùng

- Lưu workout thành công trên iOS Simulator bằng Firebase token thật.
- Backend tính points và calories đúng.
- Cache Leaderboard được invalidation sau khi lưu workout.
- Flutter tests pass.
- Backend tests: `33 passed`.
- Ruff và Flutter analyzer pass.

## Việc còn lại

Tôi chỉ còn cần merge PR #13 và kiểm tra lại Leaderboard sau khi lưu workout để chắc chắn thứ hạng hiển thị dữ liệu mới.
