---
title: 'Báo cáo cải thiện trụ cột kỹ thuật - Tháng 8 năm 2026'
description: 'Báo cáo Data & Database và API Design & Integration dựa trên bằng chứng trong dự án HealthStride.'
---

# Báo cáo cải thiện trụ cột kỹ thuật

<div class="journal-callout">
  <strong>Tháng 8 năm 2026</strong>
  <p>Một trang tổng hợp để nối file matrix đánh giá với kế hoạch, bằng chứng, nhật ký và bài học thật trong HealthStride.</p>
</div>

## Cách đọc báo cáo

Mỗi trụ cột có bốn loại bằng chứng:

- **Kế hoạch:** tôi dự định học và làm gì.
- **Evidence:** lệnh chạy, test và kết quả đo.
- **Nhật ký:** tôi đã làm gì mỗi ngày.
- **Vlog:** khó khăn và kinh nghiệm viết lại bằng lời dễ hiểu.

## 3. Data & Database - M1

### Mục tiêu

Mục tiêu củng cố kiến thức còn thiếu ở level M1 — trước slice này mình chưa từng đọc execution plan thật:

- Dùng `EXPLAIN ANALYZE` để đọc query execution plan và tự tối ưu index.
- Implement Redis cache-aside hoàn chỉnh: TTL strategy, cache invalidation đúng lúc, xử lý cache stampede.
- Viết và chạy migration rollback — hiểu rủi ro và cách xử lý khi fail giữa chừng.

### Kế hoạch theo tuần

**Tuần 1 (7/8 – 14/8):** Setup PostgreSQL + Alembic, thiết kế schema, viết migration up/down, seed 1.000+ dòng. Thực hành rollback trên local, ghi lại những gì có thể fail. ✅ Hoàn thành.

**Tuần 2 (14/8 – 21/8):** Chạy `EXPLAIN ANALYZE` trên 3 query chính, thêm composite index, so sánh kết quả. Implement Redis cache-aside cho leaderboard: TTL, invalidation, xử lý cache stampede. ✅ Hoàn thành phần đo và cache-aside; chưa có bản đo "before" để so sánh trực tiếp.

**Tuần 3 (21/8 – 31/8):** Viết blog tổng kết: những gì đã làm, bài học, kết quả đo được. ✅ Xem [Vlog Ghi nhận Workout trên Mobile](/library/journal/log-workout-mobile-vlog/) và trang báo cáo này.

### Kết quả đã đạt được

| Nội dung | Kết quả | Bằng chứng |
| --- | --- | --- |
| PostgreSQL + Alembic | Đã setup schema, migration up/down và chạy lại migration sau rollback | [Evidence Data/API §3](/library/engineering/data-api-evidence/#3-migration-rollback) |
| Seed dữ liệu | Đã seed ít nhất 1.000 user/workout ở local | [Evidence Data/API](/library/engineering/data-api-evidence/) |
| `EXPLAIN ANALYZE` | Đã đo Home, history và leaderboard; leaderboard dùng composite index và `Index Only Scan` trong lần đo local — xem query plan thật | [Evidence Data/API §1](/library/engineering/data-api-evidence/#1-explain-analyze-và-tối-ưu-index) |
| Redis cache-aside | TTL 60 giây, xoá cache đúng lúc ngay sau khi ghi workout, lock có token (Lua CAS) chống stampede, có test riêng cho từng hành vi | [Evidence Data/API §2](/library/engineering/data-api-evidence/#2-redis-cache-aside-cho-leaderboard) |
| Rollback | Đã rollback migration index rồi upgrade lại; rủi ro mất dữ liệu đã được ghi lại, nhưng rollback khi có request đang chạy hoặc khi migration fail giữa chừng chưa được thực hành thật | [Evidence Data/API §3](/library/engineering/data-api-evidence/#3-migration-rollback) |

### Điều tôi đã cải thiện

Trước đây tôi chưa từng đọc execution plan thực tế. Sau slice này, tôi đã biết nhìn vào loại scan, index được dùng và sự khác nhau giữa một query chạy được với một query có thể chịu tải lớn hơn.

Tôi cũng hiểu cache không chỉ là `get` rồi `set`. Cần có thời gian sống, thời điểm xóa cache, lock khi nhiều request cùng hụt cache và test cho từng tình huống — kể cả tình huống lock đã hết hạn nhưng vẫn có request cũ cố xoá nhầm lock của owner mới.

### Việc còn cần củng cố

- Lưu lại bản đo "before" (chưa có index) để so sánh trực tiếp before/after, và đo lại với dữ liệu lớn hơn dữ liệu seed hiện tại.
- Thực hành rollback khi có request đang chạy và khi migration thất bại giữa chừng — hiện mới có evidence cho rollback "sạch", chưa test hai kịch bản này.
- Bổ sung test PostgreSQL thật cho transaction workout, không chỉ dùng repository fake.

## 4. API Design & Integration - M2

### Mục tiêu

Mục tiêu củng cố kiến thức còn thiếu ở level M2:

- Tự implement rate limiting per-user từ đầu đến cuối — không dùng middleware có sẵn.
- Build OAuth2/Google/Facebook/LINE login flow hoàn chỉnh — hiểu từng bước thay vì chỉ copy code.
- Own response format toàn bộ API: chuẩn hoá `{ data, meta, error }`, generate OpenAPI/Swagger tự động.

### Kế hoạch theo tuần

**Tuần 1 (7/8 – 14/8):** Implement Google OAuth2, Facebook, LINE login từ đầu đến cuối, tự vẽ lại flow sau khi xong. ⚠️ Chỉ hoàn thành Google; Facebook/LINE chưa có credential thật nên vẫn là backlog, chưa vẽ lại flow.

**Tuần 2 (14/8 – 21/8):** Implement rate limiting per-user bằng Redis sliding window (GET 100/phút, POST 10/phút); chuẩn hoá toàn bộ API về `{ data, meta, error }`, bật Swagger UI. ✅ Hoàn thành.

**Tuần 3 (21/8 – 31/8):** Viết blog tổng kết: những gì đã làm, bài học, kết quả đo được. ✅ Xem trang báo cáo này.

### Kết quả đã đạt được

| Nội dung | Kết quả | Bằng chứng |
| --- | --- | --- |
| Rate limiting | Tự viết sliding window bằng Redis sorted-set + Lua script nguyên tử — không dùng middleware có sẵn; GET 100/phút, POST 10/phút theo Firebase UID | [Evidence Data/API §4](/library/engineering/data-api-evidence/#4-rate-limiting-tự-viết--không-dùng-middleware-có-sẵn) |
| Firebase/Google auth | Mobile đăng nhập Google, Backend verify Firebase ID token và upsert user. Facebook/LINE chưa implement — chưa có credential thật | [Daily Backend 20/8](/daily/backend/2026-08-20-dashboard-home/) |
| Response envelope | Các API dùng `{ data, meta, error }`, gồm cả lỗi 401, 404, 422 và 500 | [API contract](/library/engineering/api-contract/) |
| OpenAPI/Swagger | FastAPI tự sinh OpenAPI; contract test kiểm tra schema success/error | [API contract](/library/engineering/api-contract/) |
| Mobile integration | Home, Leaderboard và Log workout đã gọi API thật trên iOS Simulator | [Vlog Log workout Mobile](/library/journal/log-workout-mobile-vlog/) |

### Điều tôi đã cải thiện

Tôi không còn xem API chỉ là một URL để gọi. Tôi đã hiểu thêm về identity boundary, response contract, rate limit tự viết bằng Lua script thay vì middleware có sẵn, idempotency và cách để Mobile không tự lặp lại business rule của Backend.

### Việc còn cần củng cố

- Build hoàn chỉnh Facebook và LINE login — Tuần 1 dự kiến làm cả ba provider nhưng thực tế chỉ Google có credential thật; đây là phần chưa đạt so với kế hoạch ban đầu.
- Vẽ lại flow OAuth2/Firebase bằng sơ đồ sau khi hoàn tất từng provider.
- Bổ sung test integration có Database và Redis thật cho toàn bộ flow Mobile -> API -> cache.

## Bài học lớn nhất trong tháng

Lỗi khó nhất không nằm ở một màn hình riêng lẻ. Nó nằm ở chỗ các hệ thống gặp nhau: URL local, Firebase token, enum API, Database transaction, Redis và process đang chạy.

Tôi học được cách đi từ lỗi trên simulator xuống log Backend, rồi từ traceback quay lại đúng dòng code cần sửa. Đây là kỹ năng tôi muốn tiếp tục luyện ở các feature sau.

## Liên kết tổng

- [Thiết kế vertical slice tháng 8](/library/engineering/vertical-slice-design/)
- [Kế hoạch Data, Database và API](/library/plans/2026-08-24-data-api/)
- [Evidence Data và API](/library/engineering/data-api-evidence/)
- [API contract và OpenAPI](/library/engineering/api-contract/)
- [Daily Backend](/daily/backend/)
- [Daily Mobile](/daily/mobile/)
- [Vlog Leaderboard Mobile](/library/journal/leaderboard-mobile-vlog/)
- [Vlog Log workout Mobile](/library/journal/log-workout-mobile-vlog/)

## Bằng chứng trực quan

Ảnh dưới đây là ảnh chụp thật từ iPhone 17 Simulator sau khi đăng nhập Firebase và tải thành công Home Dashboard.

![Home Dashboard trên iPhone 17 Simulator](/images/evidence/mobile/home-dashboard.png)

Các ảnh `Log workout`, kết quả lưu thành công và Leaderboard sau khi cập nhật sẽ được bổ sung sau khi tôi điều hướng thủ công đến từng màn hình trên Simulator.
