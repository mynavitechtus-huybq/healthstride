---
title: 'HealthStride: healthstride readme'
description: 'Nhật ký và tài liệu tham chiếu của dự án HealthStride.'
---
# HealthStride — Bộ tài liệu phân tích nghiệp vụ

Ứng dụng di động chăm sóc sức khỏe nội bộ dành cho nhân viên: theo dõi tập luyện, trò chơi hóa để tạo động lực, kết nối cộng đồng, và đổi điểm lấy phần thưởng.

> **Trạng thái bộ tài liệu**: Draft v1.1 — 7 quyết định cốt lõi đã chốt, phạm vi MVP đã xác định
> **Ngày tạo**: 2026-08-10 · **Cập nhật**: 2026-08-10
> **Quy trình áp dụng**: ai-framework — chain `context-extraction` → `foundation-design` → `agile-breakdown`

---

## Mục lục tài liệu

| Tài liệu | Nội dung | Đọc khi nào |
|---|---|---|
| [Business Understanding](/library/business/business-understanding/) | Mục tiêu kinh doanh, actors, business rules, dữ liệu và phạm vi | Đọc đầu tiên |
| [Decision Log](/library/business/decision-log/) | Các quyết định đã chốt và lý do | Khi cần biết vì sao hệ thống hoạt động như hiện tại |
| [Use case overview](/library/business/usecase-overview/) | Danh sách use case theo module, actor và ưu tiên | Khi cần biết hệ thống làm được gì |
| [Business entities](/library/business/business-entities/) | Thực thể, từ điển trường và ràng buộc | Khi thiết kế database hoặc API |
| [Screen flow](/library/business/screen-flow/) | Sitemap, Screen ID và luồng điều hướng | Khi thiết kế UI/UX |
| [Backlog](/library/business/backlog/) | Epic, Feature, User Story và acceptance criteria | Khi lập sprint |
| [Function list](/library/business/function-list/) | Chức năng, độ ưu tiên và phạm vi MVP | Khi estimate công sức |
| [Screen specifications](/library/business/screens/) | Đặc tả chi tiết các màn ưu tiên | Khi implement hoặc viết test |
| [Design System](/library/design-system/) | Màu, chữ, spacing, layout, motion và component | Khi dựng giao diện |

### Screen spec đã viết

| Screen ID | Màn | Spec |
|---|---|---|
| `SCR-WO-11` | Log buổi tập | [Mở đặc tả](/library/business/screens/scr-wo-11-log-workout/) |
| `SCR-HOME-10` | Trang chủ / Dashboard | [Mở đặc tả](/library/business/screens/scr-home-10-dashboard/) |
| `SCR-SC-10` | Bảng xếp hạng | [Mở đặc tả](/library/business/screens/scr-sc-10-leaderboard/) |
| `SCR-RW-10` | Cửa hàng phần thưởng | [Mở đặc tả](/library/business/screens/scr-rw-10-reward-store/) |

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
