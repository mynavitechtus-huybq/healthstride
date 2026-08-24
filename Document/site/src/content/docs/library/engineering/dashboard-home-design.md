---
title: 'Đặc tả triển khai Dashboard/Home'
description: 'Kế hoạch kỹ thuật đưa dữ liệu thật từ API vào màn Dashboard/Home.'
---
# Đặc tả triển khai Dashboard/Home HealthStride

Đây là bản kế hoạch mình viết trước khi đụng vào Home thật — lúc đó mình vẫn còn đang quen dần với việc nối một màn Flutter tĩnh vào dữ liệu API thật. Ghi rõ phạm vi và trade-off ra đây để không bị cuốn theo việc mở rộng ngoài dự kiến.

**Trạng thái:** Đã duyệt, sẵn sàng lập kế hoạch

**Mục tiêu:** Thay màn hình Hello sau đăng nhập bằng Dashboard responsive, hiển thị dữ liệu Home của người dùng đã được xác thực từ `GET /v1/home`; đồng thời xuất bản Vlog có bằng chứng kỹ thuật cho Mobile và Backend.

## Phạm vi

Đợt triển khai này chỉ dùng dữ liệu đã có trong Home contract tháng 8:

- lời chào cá nhân hóa từ `profile.display_name`;
- điểm tích lũy, điểm khả dụng và streak hiện tại;
- thẻ Today Plan khi `today_plan` tồn tại;
- danh sách Popular Workouts từ `popular_workouts`;
- trạng thái tải lần đầu, lỗi có thể thử lại và kéo để làm mới;
- request Bearer đã xác thực, dùng Firebase ID token mới lấy.

Không thuộc phạm vi đợt này: tiến độ cấp độ, mục tiêu, thử thách, huy hiệu, cửa hàng quà, navigation tabs, log workout, cache bền vững trên thiết bị và tự động đăng xuất khi `401`. Đây là các slice kế tiếp vì contract `/v1/home` hiện chưa trả dữ liệu hoặc luồng điều hướng cần thiết.

## Kiến trúc

### Ranh giới Mobile

`App/lib/features/home` trở thành module theo feature, gồm ba tầng:

| Tầng | Trách nhiệm |
| --- | --- |
| `domain` | Model Dashboard bất biến và interface `HomeRepository`. Không phụ thuộc Flutter hay HTTP. |
| `data` | `ApiHomeRepository`, gọi `GET /v1/home` qua `ApiClient` hiện có, decode success envelope và trả kết quả typed. |
| `presentation` | `HomeController` sở hữu trạng thái loading, refreshing, data và failure. Dashboard widgets chỉ render state và gọi `load` hoặc `refresh`. |

Composition root của app tạo production transport bằng `package:http`, lấy Firebase ID token qua `AuthRepository` và truyền dependency vào màn Home sau đăng nhập. `API_BASE_URL` chỉ đến từ `--dart-define`; không commit URL local hay secret.

`AuthRepository` được thêm `Future<String?> getIdToken({bool forceRefresh = false})`. Firebase implementation gọi đến Firebase user đang hoạt động. `ApiClient` hiện đã nhận token provider, vì vậy Firebase và HTTP không rò rỉ vào Home domain layer.

### Luồng dữ liệu

1. Firebase Auth phát ra `AuthUser` đã đăng nhập.
2. App dựng Home feature với `ApiClient`; token provider lấy ID token hiện tại từ `AuthRepository`.
3. `HomeController.load()` vào trạng thái tải lần đầu và gọi `HomeRepository.fetchDashboard()`.
4. `ApiHomeRepository` gọi `/v1/home`; `ApiClient` thêm `Accept: application/json` và `Authorization: Bearer <Firebase ID token>`.
5. FastAPI xác thực token, upsert user local, đọc workout nổi bật và trả standard envelope `{ data, meta, error }`.
6. Repository decode `data.profile`, `data.today_plan` và `data.popular_workouts` thành domain model. Controller phát success state để screen render.
7. Kéo để làm mới gọi cùng operation nhưng giữ dữ liệu cũ trên màn. Slice Log Workout sau này có thể gọi refresh khi quay về Home.

## Thiết kế hiển thị

Màn hình bám theo `SCR-HOME-10` và dark `AppTheme` hiện có, không copy Figma bằng vị trí tuyệt đối. Đây là một màn cuộn dọc trong `SafeArea`:

1. hàng trên cùng: `HealthStride` và icon button đăng xuất;
2. lời chào, ưu tiên display name hợp lệ, sau đó email, cuối cùng là `Athlete`;
3. metrics band gọn gồm Lifetime points, Available points và current streak;
4. Today Plan là card chính, hoặc thông điệp thân thiện khi `today_plan` là `null`;
5. Popular Workouts là các compact card có workout type, duration, calories và description.

Card dùng spacing trong design system, Lato typography, neutral surfaces và accent colors. Ở slice này không tải image URL vì dữ liệu seed hiện trả `null`; card dùng icon chọn theo `workout_type`. Text phải wrap và layout dùng được trên cả iPhone lẫn Android phone width.

## Xử lý lỗi

| Tình huống | Trạng thái Controller | Trải nghiệm người dùng |
| --- | --- | --- |
| Request đầu tiên đang chờ | loading không có data | progress placeholder có cấu trúc; vẫn có thể đăng xuất |
| Refresh đang chờ khi đã có data | refreshing có data | `RefreshIndicator`; dữ liệu cũ vẫn hiển thị |
| Lỗi mạng, timeout, JSON sai dạng, `5xx` hoặc error envelope không phải auth | failure | lỗi trong nội dung có nút Retry; không hiện raw backend detail |
| `401 AUTHENTICATION_REQUIRED` | failure | message an toàn về session và Retry. Slice này không tự động sign out; refresh/sign-out là thay đổi auth lifecycle riêng. |
| Payload hợp lệ nhưng không có workout nổi bật | success | vẫn có metrics, Today Plan empty message và Popular Workouts rỗng |

UI chỉ dùng `ApiFailure.code` ổn định cho control flow và test. Nội dung hiển thị là copy đã chọn, không lộ backend message hay exception.

## Chiến lược kiểm thử

### Flutter

- Unit test `ApiHomeRepository` với fake `ApiClient`: decode thành công, `today_plan: null`, propagate error và invalid payload.
- Unit test `HomeController`: tải lần đầu thành công, refresh giữ data cũ, failure và Retry state.
- Widget test Dashboard: loading, error có Retry, empty plan và populated summary; assert thấy metrics và workout titles.
- Mở rộng authenticated app test để xác minh Hello greeting cũ đã được thay bằng Dashboard entry state.
- Chạy `flutter analyze` và toàn bộ `flutter test`. Chạy tay app với FastAPI local theo URL dành cho simulator được ghi trong Vlog.

### Backend

Endpoint đã được implement và test. Slice này chạy Home API test hiện có như contract regression check. Nếu mobile decoder phát hiện contract mơ hồ, thêm backend contract test nhỏ nhất để chốt response shape; không refactor Backend ngoài phạm vi.

### Trang tài liệu

Chạy `pnpm build` trong `Document/site`. Các trang Vlog phải có route riêng dưới `daily/mobile` và `daily/backend`, đồng thời được đưa vào index tương ứng.

## Định dạng tài liệu Vlog

Mỗi feature có hai MDX entry public: một trong `Document/site/src/content/docs/daily/mobile/` và một trong `Document/site/src/content/docs/daily/backend/`. Markdown diary hiện có trong `Document/HealthStride/daily/` vẫn là project record chi tiết; MDX là Vlog dành cho người đọc.

Mỗi Vlog đi theo cùng một mạch kể chuyện:

1. **Tôi đã làm gì**: user outcome, scope boundary và UI/API artifact.
2. **Tôi đã làm như thế nào**: kiến trúc nhỏ nhất cần thiết, các quyết định chính, command và test.
3. **Tôi gặp khó khăn gì**: integration constraint hoặc discovery có thật. Nếu không có blocker, nói rõ điều đó và nêu risk đã kiểm tra; không bịa vấn đề.
4. **Tôi tháo gỡ ra sao**: chẩn đoán, lựa chọn đã cân nhắc, quyết định triển khai và bằng chứng verify.
5. **Tôi học được gì**: bài học có thể tái sử dụng, liên kết với hard-skills matrix.

Mobile Vlog tập trung vào Firebase ID-token injection, typed envelope, state ownership, networking từ simulator tới local server và widget tests. Backend Vlog tập trung vào contract cho mobile, verified identity boundary, regression test và lý do không cần mở rộng Backend cho màn này.

## Tiêu chí chấp nhận

- Người dùng đã đăng nhập thấy Dashboard lấy từ FastAPI local `/v1/home`, không còn lời chào hard-code.
- Mỗi request gửi Firebase ID token trong Bearer header.
- Dashboard có loading, populated, empty-plan, refresh, failure và Retry state.
- UI dùng dark theme và Lato tokens hiện có, đọc được trên iPhone và Android phone width.
- Không commit base URL, Firebase credential, token hoặc local `.env` value.
- Flutter feature tests, toàn bộ Flutter tests, static analysis, Backend contract tests và Documentation build đều pass.
- Mobile và Backend Vlog được publish qua Astro site đã gắn Vercel, có evidence từ implementation.

## Trade-off

- Chọn controller nhẹ thay vì Riverpod/BLoC vì đây mới là một remote-read feature, chưa có shared state graph. Repository interface giữ đường nâng cấp rõ ràng.
- Không thêm persistent offline cache. Pull-to-refresh và Retry đáp ứng nhu cầu hiện tại mà chưa cần storage invalidation policy trước khi có Workout logging.
- `401` có thể Retry thay vì bắt buộc sign out. Token refresh và sign-out cần auth policy xuyên feature nên sẽ được thiết kế riêng.
- UI chỉ render những field contract hiện có. Không fake level, goals, challenges hay rewards để làm giống một Figma screen lớn hơn.
