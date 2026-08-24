---
title: 'Thiết kế Vertical Slice tháng 8'
description: 'Phạm vi và mục tiêu vertical slice HealthStride cho tới 31/8/2026.'
---
# Thiết kế Vertical Slice tháng 8 — HealthStride

Đây là bản thiết kế mình lập trước khi bắt tay viết code, để tự trả lời câu hỏi "làm gì trước, làm gì sau, và dừng ở đâu trong tháng 8". Mỗi khi phân vân có nên mở rộng phạm vi hay không, mình quay lại đọc phần Scope bên dưới.

**Trạng thái:** Thiết kế đã duyệt

**Mục tiêu:** Hoàn thành một vertical slice thể thao chạy được trước 31 tháng 8 năm 2026, đồng thời tạo ra evidence cụ thể cho Fullstack Engineer Hard Skills Matrix.

## Phạm vi

Slice tháng 8 gồm:

- Onboarding, đăng nhập Google, Home, log workout và bảng xếp hạng tuần.
- Giao diện Flutter dựa trên design system Lato hiện có và ngôn ngữ Figma đã cung cấp.
- Firebase Authentication, FastAPI, PostgreSQL, Alembic và Redis.
- Trang tài liệu kỹ thuật công khai, triển khai trên Vercel.

Ngoài phạm vi tháng 8:

- Triển khai đăng nhập Facebook và LINE. Luồng của các provider này được ghi vào backlog tháng 9.
- Đổi thưởng, social feed, gym team, thử thách, dinh dưỡng, nước uống, giấc ngủ và quản lý hồ sơ đầy đủ.
- Dùng Firebase Firestore làm database ứng dụng.

## Kiến trúc

Flutter phụ trách phần hiển thị, gửi Firebase ID token dạng Bearer token tới FastAPI. FastAPI verify token qua Firebase Admin, upsert profile local vào PostgreSQL, và giữ toàn bộ business rules. PostgreSQL là nguồn dữ liệu chuẩn (source of truth); Redis chỉ dùng cho rate limiting và cache leaderboard đọc. Firebase phụ trách Authentication, Cloud Messaging và Analytics.

Document là một site Astro tĩnh riêng dưới `Document/site`. Nó lấy nội dung Markdown từ `Document/HealthStride` và deploy lên Vercel.

## Luồng tính năng Mobile

1. Màn onboarding theo node Figma `1:604`, điều hướng người dùng tới màn đăng nhập.
2. Đăng nhập Google được xử lý bởi Firebase Authentication.
3. Sau khi xác thực, Home theo node Figma `1:479`, tải profile, popular workouts và kế hoạch hiện tại.
4. Người dùng chọn một workout từ trải nghiệm Explore/catalog gọn nhẹ dựa trên node `1:350`, sau đó ghi nhận buổi tập đã hoàn thành.
5. App tải lại tóm tắt Home và bảng xếp hạng tuần.

Flutter dùng module theo tính năng (feature-first): `auth`, `home`, `workouts`, `leaderboard` và các UI primitive dùng chung. Mọi màn đều dùng `AppTheme`, asset Lato và màu ngữ nghĩa hiện có. Layout tham chiếu từ Figma được chuyển thành widget Flutter responsive thay vì copy nguyên layout dạng absolute-positioned.

## Luồng dữ liệu Backend

### Xác thực

1. Flutter nhận Firebase ID token từ đăng nhập Google.
2. Flutter gọi FastAPI với `Authorization: Bearer <Firebase ID token>`.
3. FastAPI verify token bằng Firebase Admin và dùng Firebase UID đã xác thực làm ranh giới định danh.
4. FastAPI tạo mới hoặc cập nhật dòng `users` local tương ứng.

### Ghi Workout

`POST /v1/workouts` yêu cầu request có `Idempotency-Key`. Trong một transaction PostgreSQL duy nhất, FastAPI tạo workout log, tính điểm, tạo points transaction, cập nhật tóm tắt user và streak, rồi commit. Sau đó nó invalidate cache key của bảng xếp hạng tuần bị ảnh hưởng. Bất kỳ lỗi nào cũng rollback toàn bộ transaction.

### Đọc Leaderboard

`GET /v1/leaderboards/weekly` trước tiên đọc `leaderboard:weekly:<week-start>` từ Redis. Khi cache miss, một request giữ lock Redis ngắn hạn, query PostgreSQL, lưu leaderboard đã render với TTL 60 giây, rồi giải phóng lock. Các reader đồng thời chờ ngắn rồi thử lại cache thay vì tạo ra database stampede. Một lần ghi workout thành công sẽ xoá ngay cache key của tuần.

### Giới hạn tốc độ (Rate Limiting)

FastAPI triển khai sliding window bằng Redis sorted-set, khoá theo Firebase UID đã xác thực. Request GET cho phép 100 request/phút, request mutation cho phép 10 request/phút. Request bị từ chối trả về `429` kèm lỗi rate-limit có thể đọc được bằng máy.

## Data Model ban đầu

- `users`: Firebase UID, display name, email, điểm tích luỹ trọn đời, điểm khả dụng, streak hiện tại, timestamp tạo/cập nhật.
- `workout_logs`: tham chiếu user, loại workout, thời lượng, quãng đường, thời điểm log, calories tính được, điểm được cộng, cờ đã bị chặn trần, idempotency key.
- `points_transactions`: tham chiếu user, loại nguồn và reference, delta điểm trọn đời, delta điểm khả dụng, timestamp tạo.
- `workout_catalog`: catalog chỉ dùng để seed, phục vụ Home và view Explore gọn nhẹ.

Schema áp dụng đúng các business rule hiện có của HealthStride: buổi tập dưới 10 phút vẫn được lưu nhưng không tính điểm; một buổi tập bị chặn trần ở 300 điểm; một ngày bị chặn trần ở 500 điểm; điểm trọn đời không bao giờ giảm; điểm khả dụng không được âm.

## API Contract

Mọi response FastAPI dùng chung một envelope:

```json
{
  "data": {},
  "meta": {},
  "error": null
}
```

Lỗi cũng dùng cùng cấu trúc, với `data` là `null` và một error object chứa mã lỗi ổn định cùng thông điệp an toàn cho người dùng. Chính sách status code: `401` token không hợp lệ hoặc hết hạn, `403` lỗi phân quyền, `409` trùng idempotency key, `422` lỗi validate request, `429` bị rate limit, `500` lỗi server ngoài dự kiến, không kèm stack trace.

Endpoint ban đầu:

- `GET /v1/me`
- `GET /v1/home`
- `GET /v1/workouts/catalog`
- `POST /v1/workouts`
- `GET /v1/leaderboards/weekly`
- `GET /health`

OpenAPI và Swagger UI được bật và dùng làm tài liệu API tự sinh.

## Chất lượng và Bảo mật

- Migration Alembic phải định nghĩa cả `upgrade` và `downgrade`, kiểm chứng forward-and-rollback ở local trước khi dùng.
- Secret là environment variable, không bao giờ commit vào source.
- Firebase ID token được verify ở phía server. API không bao giờ tin user ID do client gửi lên.
- Flutter hiển thị đủ trạng thái loading, empty, lỗi có thể thử lại, và chưa xác thực cho mọi tính năng remote.
- Refresh token được thử một lần; nếu refresh thất bại, đưa người dùng về màn đăng nhập.

## Chiến lược Test và Evidence

- Unit test Python: điểm, streak, validate request, quyết định rate-window, hành vi cache-key.
- Integration test Python: hành vi transaction PostgreSQL, cache-aside Redis, invalidation, hành vi lock/stampede, API HTTP có xác thực.
- Test API dùng Firebase verifier giả lập; production dùng Firebase Admin thật.
- Flutter: unit test cho repository/use case; widget test cho mọi trạng thái loading, empty, lỗi, thành công; integration smoke test chạy với API local.
- Hiệu năng database: seed ít nhất 1.000 dòng, chụp `EXPLAIN ANALYZE` cho Home, lịch sử workout và leaderboard trước/sau khi thêm composite index, công bố chênh lệch đo được.
- Evidence hiệu năng bao gồm request leaderboard chưa cache, đã cache và đồng thời (concurrent).

## Trang tài liệu

`Document/site` là site Astro deploy lên Vercel. Nội dung là Markdown, gồm:

- Trang kiến trúc và API contract.
- Báo cáo data/hiệu năng, nhật ký migration và ghi chú bảo mật.
- Nhật ký hằng ngày dưới `daily/mobile` và `daily/backend`.
- Retrospective tháng 8.

Mỗi nhật ký hằng ngày ghi lại mục tiêu, việc đã làm, evidence (lệnh chạy/test/số đo), bài học, rủi ro hoặc điểm nghẽn, và hành động tiếp theo. Site giúp hai track học tập Mobile và Backend điều hướng độc lập với nhau.

## Đối chiếu Evidence với Matrix

| Trụ cột trong Matrix | Evidence tháng 8 |
| --- | --- |
| Programming & Frameworks | Module tính năng Flutter và module FastAPI được giao end-to-end. |
| Software Design & Architecture | Thiết kế đã duyệt, ranh giới tính năng rõ ràng, ADR cho Firebase/Python/PostgreSQL/Redis. |
| Data & Database | Schema, Alembic up/down, dữ liệu seed, EXPLAIN ANALYZE, composite index, cache-aside Redis. |
| API Design & Integration | Verify Firebase token, envelope response ổn định, OpenAPI, rate limiting tự viết. |
| UI/UX Engineering | Chuyển đổi responsive từ màn Figma đã duyệt sang Flutter, đủ mọi trạng thái UI từ xa. |
| Testing & QA | Evidence unit, integration, widget và smoke test. |
| Performance & Optimization | Query plan trước/sau và số đo leaderboard có cache so với không cache. |
| Security Engineering | Verify token phía server, secret qua environment, validation, rate limiting, che thông tin lỗi. |
| Engineering Process | Backlog tính năng, DoR/DoD, biên bản review, evidence hằng ngày. |
| Technical Documentation | Trang tài liệu trên Vercel, tài liệu API, nhật ký migration, retrospective có số đo. |
| Business & Domain Understanding | Thực thể và quy tắc điểm/streak của HealthStride được phản ánh đúng trong triển khai. |

## Lịch trình

| Ngày | Kết quả |
| --- | --- |
| 19-20/8 | Nền tảng FastAPI/PostgreSQL/Alembic/Redis và Firebase; site Astro và template nhật ký. |
| 21-23/8 | Schema, dữ liệu seed, migration upgrade/downgrade, baseline query plan, index. |
| 24-26/8 | Google Auth, verify Firebase token, envelope API, Swagger, rate limiter tự viết, leaderboard Redis. |
| 27-29/8 | Flutter onboarding, đăng nhập, Home, catalog/log workout, leaderboard. |
| 30/8 | Integration testing, evidence hiệu năng, security review. |
| 31/8 | Deploy Vercel và retrospective Mobile/Backend. |
