# HealthStride — Bộ tài liệu phân tích nghiệp vụ

Ứng dụng di động chăm sóc sức khỏe nội bộ dành cho nhân viên: theo dõi tập luyện, trò chơi hóa để tạo động lực, kết nối cộng đồng, và đổi điểm lấy phần thưởng.

> **Trạng thái bộ tài liệu**: Draft v1.1 — 7 quyết định cốt lõi đã chốt, phạm vi MVP đã xác định
> **Ngày tạo**: 2026-08-10 · **Cập nhật**: 2026-08-10
> **Quy trình áp dụng**: ai-framework — chain `context-extraction` → `foundation-design` → `agile-breakdown`

---

## Mục lục tài liệu

| Tài liệu | Nội dung | Đọc khi nào |
|---|---|---|
| [business-understanding.md](business-understanding.md) | Mục tiêu kinh doanh, actors, toàn bộ business rules (công thức điểm, badge, bảng cấp độ, thử thách, phần thưởng), dữ liệu, NFR, phạm vi, câu hỏi mở | Đọc đầu tiên — nền tảng của mọi tài liệu khác |
| [decision-log.md](decision-log.md) | 7 quyết định đã chốt (D-001 → D-007): công thức điểm, bảng cấp độ, cơ chế hai loại điểm, đăng nhập, nhập tay, quy trình duyệt thưởng, trần chống gian lận | Khi cần biết vì sao hệ thống hoạt động theo cách hiện tại |
| [usecase-overview.md](usecase-overview.md) | Danh sách use case theo 6 module, actor, độ ưu tiên, sơ đồ use case | Khi cần biết hệ thống làm được những gì |
| [business-entities.md](business-entities.md) | 24 thực thể nghiệp vụ, từ điển trường, ràng buộc trong và giữa các thực thể | Khi thiết kế cơ sở dữ liệu hoặc hợp đồng API |
| [screen-flow.md](screen-flow.md) | Sitemap, 29 màn hình có Screen ID, sơ đồ điều hướng, 3 luồng đi sâu | Khi thiết kế UI/UX hoặc lập kế hoạch triển khai màn hình |
| [backlog.md](backlog.md) | 5 Epic → 14 Feature → 26 User Story kèm acceptance criteria | Khi lập sprint hoặc giao việc cho đội phát triển |
| [function-list.md](function-list.md) | 35 chức năng kèm độ ưu tiên, độ phức tạp, traceability và **phạm vi MVP** | Khi estimate công sức và chốt phạm vi phát hành |
| [screens/](screens/) | Screen spec chi tiết cho 4 màn ưu tiên cao — thành phần, behavior, trạng thái, lỗi | Khi implement hoặc viết test case cho từng màn |
| [../DESIGN-SYSTEM.md](../DESIGN-SYSTEM.md) | Design system Flutter: màu, chữ, spacing, layout, motion, component gamification | Khi dựng giao diện |

### Screen spec đã viết

| Screen ID | Màn | Spec |
|---|---|---|
| `SCR-WO-11` | Log buổi tập | [screens/SCR-WO-11-log-workout.md](screens/SCR-WO-11-log-workout.md) |
| `SCR-HOME-10` | Trang chủ / Dashboard | [screens/SCR-HOME-10-dashboard.md](screens/SCR-HOME-10-dashboard.md) |
| `SCR-SC-10` | Bảng xếp hạng | [screens/SCR-SC-10-leaderboard.md](screens/SCR-SC-10-leaderboard.md) |
| `SCR-RW-10` | Cửa hàng phần thưởng | [screens/SCR-RW-10-reward-store.md](screens/SCR-RW-10-reward-store.md) |

---

## Thứ tự đọc gợi ý cho người mới

1. `business-understanding.md` — hiểu bối cảnh và quy tắc nghiệp vụ.
2. `usecase-overview.md` — nắm phạm vi chức năng.
3. `screen-flow.md` — hình dung sản phẩm sẽ trông như thế nào.
4. `backlog.md` hoặc `function-list.md` — tùy mục đích lập kế hoạch hay ước lượng.

---

## Quy ước nhãn trong tài liệu

| Nhãn | Ý nghĩa |
|---|---|
| `[FROM-CUSTOMER]` | Thông tin lấy trực tiếp từ mô tả khách hàng cung cấp |
| `[ASSUMED]` | Giả định hợp lý do BA đưa ra khi chờ xác nhận |
| `[NEEDS-CONFIRMATION]` | Cần Product Owner / HR xác nhận trước khi chốt |
| `[DECISION]` | Đã chốt chính thức — xem `decision-log.md` |
| `[CONFLICT]` | Mâu thuẫn giữa các nguồn — hiện chưa phát sinh |

---

## Bảy quyết định cốt lõi đã chốt

| ID | Quyết định |
|---|---|
| D-001 | Điểm workout = làm tròn(số phút × hệ số loại hình). Cardio và tạ 3.33 điểm/phút, yoga 2.5 điểm/phút |
| D-002 | Điểm cần để đạt Level N = 50 × N². Level 50 tương ứng 125.000 điểm |
| D-003 | Tách hai loại điểm: điểm tích lũy trọn đời (xếp hạng, cấp độ — chỉ tăng) và điểm khả dụng (đổi thưởng) |
| D-004 | Hỗ trợ cả đăng nhập bằng mật khẩu và SSO Google Workspace; HR nạp danh sách nhân viên hợp lệ |
| D-005 | Toàn bộ dữ liệu nhập tay ở bản đầu tiên — không tích hợp Apple Health / Google Fit |
| D-006 | HR duyệt thủ công mọi yêu cầu đổi thưởng; giao quà thực hiện ngoài ứng dụng |
| D-007 | Trần chống gian lận: tối đa 300 điểm/buổi, 500 điểm/ngày, buổi dưới 10 phút không tính điểm |
| D-008 | Bốn loại thông báo trong bản đầu tiên: báo nhân sự khi có yêu cầu mới, báo nhân viên khi được duyệt, báo nhân viên khi bị từ chối (kèm số điểm hoàn lại), nhắc uống nước. Loại trừ thông báo xã hội và thông báo huy hiệu |
| D-009 | Ba mức hiển thị: Công khai (mặc định), Ẩn danh, Riêng tư. Dữ liệu sức khỏe không bao giờ công khai ở bất kỳ mức nào |

---

## Phạm vi bản phát hành đầu tiên (MVP)

**23 chức năng `Must`** — vòng lặp động lực cốt lõi (*tập luyện → nhận điểm → thấy thứ hạng → đổi thưởng*) cộng nhánh nhắc uống nước và cơ chế quyền riêng tư.

| Nhóm | Chức năng trong MVP |
|---|---|
| Nền tảng | Đăng nhập (mật khẩu + SSO), nạp danh sách nhân viên, dashboard, hồ sơ & cài đặt, thông báo mức hiển thị mặc định, job định kỳ, dịch vụ thông báo đẩy |
| Workout | Log buổi tập, danh mục bài tập, lịch sử workout, đặt mục tiêu |
| Gamification | Engine tính điểm, engine tính cấp độ, engine xét huy hiệu, màn huy hiệu |
| Social | Bảng xếp hạng, activity feed |
| Reward | Cửa hàng phần thưởng, đổi điểm lấy quà, lịch sử đổi quà, duyệt yêu cầu (HR) |
| Health | Log nước uống, nhắc nhở uống nước |

**Hoãn sang giai đoạn 2:** thử thách tuần, bạn bè & cheer, gym team, comment/reaction, log dinh dưỡng, log giấc ngủ, biểu đồ tiến độ, báo cáo quản trị. Chi tiết và lý do tại `function-list.md`.

**Lưu ý về lịch triển khai:** `FN-034` Dịch vụ thông báo đẩy là hạng mục hạ tầng có độ phức tạp cao và có bốn chức năng khác phụ thuộc vào nó. Nên bắt đầu sớm trong lịch triển khai.

---

## Câu hỏi còn mở

**Không còn câu hỏi nào chặn ước lượng, chốt phạm vi, hay thiết kế chi tiết các màn thuộc bản phát hành đầu tiên.** Các câu hỏi còn lại giải quyết được song song trong giai đoạn thiết kế — xem `business-understanding.md` §14.

Cần chốt trước khi bắt đầu **giai đoạn 2**:

- **Q-010** — Mốc reset thử thách tuần và bảng xếp hạng, múi giờ nào.
- **Q-009** — Công thức tính điểm Gym Team, và mức Ẩn danh/Riêng tư ứng xử thế nào trong phạm vi một nhóm mà chính người đó chủ động tham gia.

Có thể chốt muộn hơn:

- **Q-011b** — Khung giờ nhắc uống nước. BA đề xuất 10:00, 14:00, 16:00 các ngày làm việc.
- **Q-008b** — Có công bố tên người ở mức ẩn khi họ đứng đầu bảng xếp hạng tháng không.
- **Q-012** — Chính sách dữ liệu khi nhân viên nghỉ việc.
- **Q-015** — Điều kiện chính xác của huy hiệu "Consistent".

---

## Bước tiếp theo đề xuất

1. **Ước lượng công sức cho 17 chức năng MVP** — nay đã đủ dữ kiện để cho con số đáng tin.
2. **Viết screen spec cho các màn MVP còn lại** — SCR-AUTH-10 Đăng nhập, SCR-RW-11 Xác nhận đổi quà, SCR-GM-10 Huy hiệu, SCR-SC-20 Activity Feed, SCR-ADM-12 Duyệt đổi thưởng.
3. **Bổ sung `app_spacing.dart` và `app_motion.dart`** — hai module token còn thiếu theo hợp đồng trong `DESIGN-SYSTEM.md`.
4. **Rà soát lại ước lượng sau D-008 và D-009** — hai quyết định này đưa MVP từ 17 lên 23 chức năng và làm tăng độ phức tạp của bảng xếp hạng lẫn bảng tin.
5. **Chốt Q-009 và Q-010 trước khi lập kế hoạch giai đoạn 2.**
