# Nhật ký xây dựng: Home theo Figma

> **Ngày:** 20/08/2026  
> **Feature:** Màn Home/Dashboard  
> **Branch:** `feat/home-figma`  
> **Phạm vi:** Mobile UI và contract dữ liệu hiện có; Backend chưa thay đổi

## Mobile

### Hôm nay đã làm gì?

- Phân tích node Home `1:479` trong Figma ở kích thước mobile 390 x 844.
- Chuyển bố cục sang Flutter gồm lời chào, tên người dùng, tìm kiếm, Popular Workouts, Today Plan và bottom navigation.
- Tải và tối ưu các ảnh workout từ Figma thành asset local để app không phụ thuộc URL tạm thời.
- Thêm carousel ngang cho Popular Workouts với ảnh, calories, thời lượng và nút play.
- Thêm ba card Today Plan có ảnh, độ khó và progress bar.
- Thêm tìm kiếm local theo tên, mô tả và loại workout.
- Giữ lại refresh, loading, error state và retry của Home vertical slice.
- Thêm dữ liệu fallback để có thể review đầy đủ màn hình trước khi API trả về danh sách workout hoàn chỉnh.
- Gắn bottom navigation theo ngôn ngữ thiết kế Figma; các tab Explore, Statistics và Profile hiện báo coming soon.
- Điều chỉnh nền light theme thành `#F7F6FA` để khớp Figma, trong khi dark theme vẫn dùng token hiện tại.

### Tôi đã làm như thế nào?

1. Viết test trước cho composition Home, search filter, fallback plans và responsive phone size.
2. Tái sử dụng `HomeController`, `HomeDashboard` và `WorkoutSummary` thay vì tạo một data flow riêng cho UI.
3. Tách các khối thành widget nhỏ: popular card, plan card, progress bar, image fallback và bottom navigation.
4. Map workout sang asset bằng tên workout; API có `imageUrl` thì ưu tiên ảnh từ API, lỗi tải ảnh sẽ fallback về asset local.
5. Dùng semantic Material colors cho surface, text phụ và trạng thái để light/dark không bị khóa vào một palette.
6. Dùng `AlwaysScrollableScrollPhysics` để pull-to-refresh hoạt động cả khi dữ liệu ít.

### Khó khăn gặp phải

- Figma có ba plan mẫu nhưng API model hiện tại chỉ có một `todayPlan` và danh sách popular chưa chắc đủ ba item.
- Ảnh tải từ Figma có kích thước rất lớn, không phù hợp để đưa nguyên bản vào mobile bundle.
- Khi thêm carousel ngang, các test cũ tìm `ListView` mà không chỉ rõ hướng nên bị ambiguous.
- Layout Home mới không còn hiển thị điểm lifetime ở vị trí cũ, nên một số test vẫn kiểm tra copy Dashboard trước đây.

### Cách tháo gỡ

- Giữ API model hiện tại và chỉ bổ sung fallback presentation data cho phần còn thiếu; khi Backend mở rộng contract, UI có thể thay dữ liệu mà không đổi layout.
- Dùng `sips` resize ảnh về cạnh dài 1200px và nén JPEG quality 82 trước khi commit.
- Cập nhật test dùng `find.byType(ListView).first` cho scroll dọc và test riêng hành vi carousel bằng search field.
- Cập nhật expectation theo Home contract mới: `Good Morning`, tên người dùng, Today Plan và Popular Workouts.

### Tôi học được gì?

- Khi chuyển Figma sang code, cần phân biệt phần visual cố định với phần dữ liệu có thể thiếu từ API.
- Fallback data nên nằm ở presentation layer và có slug ổn định để không tạo duplicate khi ghép với dữ liệu thật.
- Asset local giúp build reproducible hơn, nhưng phải tối ưu dung lượng ngay khi đưa vào repo.
- Một màn hình có nhiều vùng scroll cần đặt key hoặc chọn finder rõ ràng trong widget test.
- Design token không chỉ áp dụng cho màu nền; progress, card, icon container và text phụ cũng cần có semantic role.

### Kiểm tra

- `flutter analyze`: không có issue.
- `flutter test`: toàn bộ test suite pass.
- Home widget tests: composition, search, retry, fallback data, refresh failure và viewport 390 x 844 đều pass.
- Backend không thay đổi trong feature này; Home vẫn dùng API contract vertical slice hiện có.

## Backend

### Hôm nay đã làm gì?

- Không thay đổi FastAPI endpoint, PostgreSQL schema, Redis hay Firebase Admin authentication.
- Giữ nguyên contract dashboard để Mobile có thể triển khai UI độc lập.

### Việc cần cải thiện tiếp theo

- Mở rộng response dashboard thành danh sách `today_plans` thay vì chỉ một `today_plan`.
- Bổ sung `image_url`, `progress`, `difficulty` và metadata calories/thời lượng cho từng workout.
- Sau khi contract ổn định, thay fallback data bằng response thật và bổ sung contract tests cho các trạng thái rỗng.

### Bài học Backend

- UI bám Figma thường làm lộ ra những điểm API còn quá hẹp; đây là tín hiệu để cải thiện model thay vì nhồi logic vào widget.
- Tách rõ dữ liệu bắt buộc và dữ liệu bổ sung giúp Mobile vẫn có graceful degradation khi Backend chưa hoàn thiện.
