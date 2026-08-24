# Nhật ký xây dựng: Leaderboard Mobile

## Mobile

### Hôm nay tôi đã làm gì?

Tôi thay tab Explore đang báo “coming soon” bằng màn Leaderboard. Màn này gọi API tuần, hiển thị thứ hạng hiện tại của tôi và danh sách người dùng cùng số điểm. Leaderboard nằm trong cùng shell của Home, nên bottom menu vẫn còn khi chuyển tab.

### Tôi làm như thế nào?

Tôi tạo model `WeeklyLeaderboard`, repository `ApiLeaderboardRepository`, controller `LeaderboardController` và màn `LeaderboardScreen`. Controller tách rõ loading, dữ liệu, empty và lỗi để UI không phải tự đoán trạng thái. Home giữ `selectedTab` và chỉ thay phần body; menu active hiển thị icon cùng title.

### Tôi gặp khó khăn gì?

Khi chạy test, `MyApp` cố tạo API repository thật dù test đã truyền fake Home repository. Vì `API_BASE_URL` không có trong test nên app bị lỗi ngay lúc khởi tạo.

### Tôi tháo gỡ ra sao?

Tôi chỉ tạo Leaderboard repository thật khi app chạy với repository mặc định. Khi test truyền fake dependency, Leaderboard có thể để trống và không đụng vào network.

### Tôi học được gì?

Một feature Mobile tốt không chỉ có màn hình đẹp. Repository phải đọc đúng API contract, controller phải xử lý trạng thái, và dependency phải dễ thay thế khi test.

### Kiểm tra

- `flutter analyze`: không có lỗi.
- `flutter test`: tất cả test pass.
- Leaderboard focused tests: repository và widget đều pass.

### Việc chưa làm

Chưa chạy manual end-to-end trên iOS Simulator với Firebase ID token thật. Đây là bước tiếp theo sau khi Backend local và Firebase session sẵn sàng.

## Backend

Backend đã có sẵn endpoint leaderboard, Redis cache-aside TTL 60 giây, invalidation sau workout và lock chống cache stampede. Mobile chỉ gọi API; không tự tính lại điểm.
