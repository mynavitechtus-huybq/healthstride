# Screen Spec — SCR-HOME-10 Trang chủ / Dashboard

> **Trạng thái**: Draft v1.0
> **Cập nhật lần cuối**: 2026-08-11
> **Owner**: BA/PM
> **Nguồn chính**: `business-understanding.md` §6.1–6.3, `decision-log.md` D-002/D-003, `screen-flow.md`
> **Design system**: `Document/DESIGN-SYSTEM.md`

- **Screen ID:** `SCR-HOME-10`
- **Business name:** Trang chủ / Dashboard
- **Route / entry trigger:** `/home` — màn mặc định sau khi đăng nhập; tab đầu tiên trên thanh điều hướng dưới
- **Related screens:** mở `SCR-WO-11` (log buổi tập), `SCR-GM-11` (chi tiết cấp độ), `SCR-GM-10` (huy hiệu), `SCR-SC-10` (bảng xếp hạng), `SCR-RW-10` (cửa hàng quà), `SCR-WO-13` (đặt mục tiêu)
- **Kiểu trình bày:** Trang đầy, cuộn dọc một cột
- **Nguồn chính:** `[FROM-CUSTOMER]`, `[DECISION]` D-002, D-003

---

## 1. Mục đích (Purpose)

Trang chủ trả lời ba câu hỏi mà nhân viên cần biết mỗi lần mở ứng dụng: **tôi đang ở đâu** (điểm, cấp độ, streak), **tôi còn thiếu gì** (tiến độ mục tiêu tuần), và **tôi nên làm gì tiếp** (nút log buổi tập, thử thách đang mở).

Đây là màn được mở nhiều nhất, nên nó phải đọc được trong vài giây mà không cần cuộn. Các chỉ số quan trọng nhất nằm trong vùng nhìn thấy đầu tiên; phần khám phá thêm nằm bên dưới.

Trang chủ **không** là nơi thao tác sâu — mọi thẻ trên màn đều là lối vào một màn chuyên biệt hơn.

## 2. Điều kiện trước và phân quyền (Preconditions / Permissions)

Người dùng phải **đã đăng nhập**. Không yêu cầu vai trò đặc biệt.

Với nhân viên mới hoàn toàn (chưa log buổi tập nào), màn vẫn hiển thị đầy đủ cấu trúc nhưng các chỉ số ở giá trị khởi đầu và các thẻ chuyển sang trạng thái mời gọi — xem §5 trạng thái `Empty`.

**Loại permission gate:** route guard ở mức "đã đăng nhập". Tài khoản có vai trò Admin/HR nhìn thấy **thêm** một lối vào khu vực quản trị ở cuối màn; nhân viên thường không thấy mục này. Đây là `[PERMISSION-SERVER]` — máy chủ trả về cờ vai trò trong hồ sơ người dùng, giá trị mặc định là không phải admin. `[NEEDS-CONFIRMATION]` tên trường cụ thể và điều kiện máy chủ đặt cờ.

## 3. Thành phần giao diện (UI components)

| Thành phần | Kiểu | Bắt buộc? | Nguồn giá trị / option | Điều kiện enable/disable/hiển thị | Quy tắc nghiệp vụ | Ánh xạ entity | Validation và cách phản hồi (UX) | Ghi chú |
|---|---|---|---|---|---|---|---|---|
| Lời chào và avatar | `Avatar` + `Label / Văn bản tĩnh` | — | `API` hồ sơ người dùng | Luôn hiển thị | Xưng hô theo tên nhân viên | `Employee.full_name` | Khi thiếu ảnh đại diện, hiển thị chữ cái đầu của tên trên nền `color-neutral-800`. Khi tên rỗng, hiển thị "Bạn". | Chạm vào mở `SCR-PROF-10` |
| Vòng tiến độ cấp độ | `Progress indicator` | — | `API` tổng hợp dashboard | Luôn hiển thị | Tiến độ tính theo công thức 50 × N² của D-002 | `Employee.lifetime_points`, `current_level` | Khi API lỗi, khối chuyển sang khung xám kèm nút Thử lại. Khi người dùng ở Level 50, vòng hiển thị đầy 100% và dòng dưới ghi "Đã đạt cấp tối đa". | Thành phần Level ring theo design system |
| Điểm tích lũy | `Label / Văn bản tĩnh` | — | `API` tổng hợp dashboard | Luôn hiển thị | Chỉ tăng, không bao giờ giảm | `Employee.lifetime_points` | Khi giá trị bằng 0, vẫn hiển thị số 0 kèm nhãn, không hiển thị dấu gạch. | Lato ExtraBold, `color-accent`, nhãn "tổng điểm" — `[DECISION]` D-003 |
| Điểm khả dụng | `Label / Văn bản tĩnh` | — | `API` tổng hợp dashboard | Luôn hiển thị, đặt ngay cạnh điểm tích lũy | Giảm khi đổi quà | `Employee.available_points` | Như trên. | Lato Bold, màu trắng, biểu tượng ví, nhãn "có thể đổi" — hai số **bắt buộc** hiển thị cạnh nhau và đều có nhãn |
| Chỉ báo streak | `Badge / Nhãn trạng thái` | — | `API` tổng hợp dashboard | Luôn hiển thị | Màu ngọn lửa leo thang theo số ngày | `Employee.current_streak_days` | Khi streak bằng 0, hiển thị ngọn lửa xám kèm chữ "Bắt đầu streak hôm nay". | Số ngày luôn hiển thị dạng chữ bên cạnh icon, không dùng màu đơn lẻ |
| Thẻ mục tiêu tuần | `Progress indicator` + `Label / Văn bản tĩnh` | — | `API` tổng hợp dashboard | Ẩn khi người dùng chưa đặt mục tiêu nào | Hiển thị tiến độ mục tiêu đang hoạt động của kỳ hiện tại | `Goal.current_progress`, `target_value` | Khi chưa có mục tiêu, thay bằng thẻ mời gọi "Đặt mục tiêu tuần của bạn" dẫn sang `SCR-WO-13`. | Chỉ hiển thị mục tiêu của kỳ hiện tại; nhiều mục tiêu thì hiển thị mục tiêu tần suất trước |
| Nút Log buổi tập | `Button (hành động chính)` | — | — | Luôn bật | Lối vào chính của vòng lặp động lực | — | Không có trạng thái lỗi tại chỗ; lỗi xử lý trong `SCR-WO-11`. | Ngoài nút này, thanh điều hướng dưới cũng có nút hành động trung tâm — hai lối vào cùng đích |
| Thẻ thử thách tuần | `Data table (hàng biến thiên)` | — | `API` danh sách thử thách đang mở | Ẩn toàn bộ khối khi không có thử thách nào đang mở | Hiển thị tối đa 2 thử thách có tiến độ cao nhất | `Challenge`, `ChallengeParticipation` | Khi API lỗi, ẩn khối và không báo lỗi (khối phụ, không chặn màn). Khi không có thử thách nào, ẩn khối. | Chạm vào mở `SCR-GM-12` |
| Thẻ huy hiệu gần đây | `Data table (hàng biến thiên)` | — | `API` huy hiệu mới đạt | Ẩn khi người dùng chưa đạt huy hiệu nào | Hiển thị tối đa 3 huy hiệu đạt gần nhất | `EmployeeBadge` | Khi chưa có huy hiệu, thay bằng thẻ mời gọi "Hoàn thành buổi tập đầu tiên để nhận huy hiệu Starter". | Chạm vào mở `SCR-GM-10` |
| Thẻ thứ hạng của tôi | `Label / Văn bản tĩnh` | — | `API` tổng hợp dashboard | Luôn hiển thị | Thứ hạng theo điểm tích lũy trong kỳ tuần hiện tại | `LeaderboardSnapshot` | Khi chưa có dữ liệu xếp hạng (nhân viên mới), hiển thị "Chưa xếp hạng — hãy log buổi tập đầu tiên". | Chạm vào mở `SCR-SC-10` |
| Thẻ cửa hàng quà | `Link / Liên kết` | — | `API` tổng hợp dashboard | Luôn hiển thị | Gợi ý phần thưởng gần nhất trong tầm điểm khả dụng | `RewardCatalogItem` | Khi không có phần thưởng nào trong tầm với, hiển thị mốc thấp nhất kèm số điểm còn thiếu. | Cửa hàng quà không có tab riêng nên lối vào này là chính |
| Tip và quote hàng ngày | `Label / Văn bản tĩnh` | — | `API` nội dung động lực theo ngày | Ẩn khối khi API lỗi hoặc không có nội dung | Mỗi ngày một nội dung, không lặp lại liên tiếp | `MotivationContent` | Khi API lỗi, ẩn khối im lặng — đây là nội dung trang trí, không đáng báo lỗi. | Đặt ở cuối màn |
| Lối vào khu vực quản trị | `Link / Liên kết` | — | Cờ vai trò từ hồ sơ người dùng | **Chỉ hiển thị với vai trò Admin/HR** | Dẫn sang `SCR-ADM-10` | `Employee` (cờ vai trò) | Không hiển thị với nhân viên thường — ẩn hẳn, không hiển thị dạng vô hiệu hóa. | `[PERMISSION-SERVER]` — mặc định ẩn |
| Kéo để làm mới | `Button (hành động chính)` (cử chỉ) | — | — | Luôn khả dụng | Tải lại toàn bộ dữ liệu dashboard | — | Khi làm mới lỗi, giữ nguyên dữ liệu cũ và hiển thị toast lỗi, không xóa màn. | Cử chỉ kéo xuống chuẩn của nền tảng |

### 3.1 Thứ tự ưu tiên hiển thị

Vùng nhìn thấy đầu tiên (trước khi cuộn) **bắt buộc** chứa: lời chào, vòng tiến độ cấp độ, hai chỉ số điểm, chỉ báo streak, và nút Log buổi tập. Mọi khối còn lại nằm dưới. Lý do: đây là các thông tin trả lời câu hỏi "tôi đang ở đâu và nên làm gì" — mục đích chính của màn.

## 4. Tương tác và luồng nhỏ trên màn (User interactions / flows)

| Mã luồng | Tên luồng | Trigger | Tiền điều kiện | Xử lý hệ thống | Kết quả UI | Điều hướng / side effect | Ghi chú |
|---|---|---|---|---|---|---|---|
| F-01 | Tải màn lần đầu | Mở tab Home hoặc đăng nhập thành công | Đã đăng nhập | Gọi API tổng hợp dashboard | Hiển thị khung xương (skeleton) rồi lấp dữ liệu vào | Không | Một lần gọi API duy nhất cho toàn màn để tránh nhiều trạng thái tải rời rạc |
| F-02 | Quay lại từ màn log buổi tập | Đóng `SCR-WO-11` sau khi lưu thành công | — | Làm mới dữ liệu dashboard | Điểm và vòng tiến độ chạy số bằng `motion-reward` | Không | Người dùng phải **thấy** điểm mình vừa kiếm được thay đổi trên trang chủ |
| F-03 | Kéo để làm mới | Kéo màn xuống | — | Gọi lại API tổng hợp | Chỉ báo tải ở đỉnh màn, dữ liệu cũ vẫn hiển thị bên dưới | Không | Không được xóa trắng màn khi đang làm mới |
| F-04 | Mở chi tiết cấp độ | Chạm vòng tiến độ cấp độ | — | — | Mở `SCR-GM-11` dạng bottom sheet | — | |
| F-05 | Mở bảng xếp hạng | Chạm thẻ thứ hạng | — | — | Chuyển sang tab Rank, mở `SCR-SC-10` | Tab dưới đổi trạng thái active | Dùng chuyển tab, không đẩy màn mới lên stack |
| F-06 | Mở cửa hàng quà | Chạm thẻ cửa hàng quà | — | — | Đẩy `SCR-RW-10` lên stack | — | Cửa hàng không có tab riêng nên đẩy màn mới |
| F-07 | Đặt mục tiêu đầu tiên | Chạm thẻ mời gọi đặt mục tiêu | Chưa có mục tiêu nào | — | Mở `SCR-WO-13` dạng bottom sheet | Sau khi lưu, thẻ mục tiêu thay thế thẻ mời gọi | |
| F-08 | Quay lại app sau thời gian dài | Đưa app từ nền lên trước sau hơn 5 phút | — | Gọi lại API tổng hợp im lặng | Dữ liệu cập nhật, không có chỉ báo tải toàn màn | Không | Ngưỡng 5 phút là đề xuất — `[NEEDS-CONFIRMATION]` |

## 5. Trạng thái màn hình (States)

| State | Điều kiện vào | Người dùng thấy gì | Còn thao tác gì được | Cách thoát state | Ghi chú |
|---|---|---|---|---|---|
| `Initial` | Vừa vào tab, chưa có dữ liệu cache | Khung xương của các khối chính | Chuyển tab được | API phản hồi | Không dùng vòng quay toàn màn — khung xương giữ được cảm giác cấu trúc |
| `Loading` | Đang gọi API tổng hợp | Khung xương (lần đầu) hoặc chỉ báo ở đỉnh (khi làm mới) | Cuộn và chuyển tab | API phản hồi | Khi làm mới, dữ liệu cũ vẫn hiển thị |
| `Empty` | Nhân viên mới, chưa log buổi tập nào | Cấu trúc đầy đủ với chỉ số ở 0; các thẻ chuyển sang dạng mời gọi. Văn bản chính: **"Chào mừng bạn đến HealthStride. Log buổi tập đầu tiên để nhận 100 điểm và huy hiệu Starter."** | Toàn bộ, đặc biệt nút Log buổi tập được làm nổi bật | Log buổi tập đầu tiên | Đây là màn quyết định người dùng có gắn bó hay không — không được để trống lạnh lẽo |
| `Error` | API tổng hợp lỗi và không có dữ liệu cache | Thông báo giữa màn kèm nút Thử lại | Bấm Thử lại, chuyển tab | Thử lại thành công | Vị trí: khối thay thế toàn bộ vùng nội dung, giữ nguyên thanh điều hướng dưới |
| `Error` (một phần) | Chỉ khối phụ lỗi (thử thách, tip/quote) | Khối đó bị ẩn, phần còn lại hiển thị bình thường | Toàn bộ | Lần làm mới tiếp theo | Không báo lỗi ồn ào cho khối phụ |
| `Timeout` | API không phản hồi trong 15 giây | Nếu có dữ liệu cache, hiển thị cache kèm dòng "Dữ liệu có thể chưa mới nhất". Nếu không có cache, hiển thị như `Error`. | Bấm Thử lại | Thử lại thành công | Ưu tiên hiển thị dữ liệu cũ hơn là màn trắng |
| `Concurrent / Race` | Người dùng log buổi tập trên thiết bị khác trong lúc đang xem | Dữ liệu chỉ cập nhật ở lần làm mới kế tiếp | Kéo để làm mới | Làm mới | Không cần đồng bộ thời gian thực trên màn này |
| `Success` | N/A | — | — | — | Màn chỉ đọc, không có thao tác lưu |
| `Session expired` | API trả 401 | Toast rồi điều hướng đăng nhập | Không | Tự động | Xóa dữ liệu cache khi đăng xuất |
| `No permission` | N/A cho toàn màn | — | — | — | Chỉ khối quản trị bị ẩn theo vai trò, phần còn lại ai cũng xem được |

## 6. Validation, lỗi và trường hợp ngoại lệ

| Nhóm lỗi | Điều kiện phát sinh | Phản hồi UI mong đợi | Mã message | Vị trí hiển thị | Có nút Retry | Có chặn action | Ghi chú QA |
|---|---|---|---|---|---|---|---|
| Dữ liệu rỗng | Nhân viên chưa log buổi tập nào | Trạng thái mời gọi như mô tả ở §5 | `MSG-HOME-001` | Giữa vùng nội dung | Không | Không | Tạo tài khoản mới và mở app lần đầu |
| Lỗi nhập liệu | N/A | — | — | — | — | — | Màn chỉ đọc, không có ô nhập |
| Lỗi nghiệp vụ | N/A | — | — | — | — | — | Không có thao tác nghiệp vụ trên màn |
| Lỗi quyền (401) | Phiên hết hạn | Toast rồi điều hướng đăng nhập | `MSG-AUTH-401` | Toast | Không | Có | Để app chạy nền qua thời hạn phiên |
| Lỗi quyền (403) | Người dùng bị thu hồi quyền truy cập ứng dụng | Màn thông báo "Tài khoản của bạn không còn quyền sử dụng ứng dụng" kèm nút Đăng xuất | `MSG-AUTH-403` | Toàn màn | Không | Có | HR vô hiệu hóa tài khoản trong lúc người dùng đang đăng nhập |
| Không tìm thấy (404) | Hồ sơ nhân viên không tồn tại phía máy chủ | Xử lý như 403 | `MSG-AUTH-403` | Toàn màn | Không | Có | Trường hợp hiếm, thường do dữ liệu bị xóa |
| Lỗi mạng / timeout | Mất kết nối | Hiển thị cache kèm dòng cảnh báo, hoặc màn lỗi nếu chưa có cache | `MSG-SYS-NET` | Dòng dưới app bar, hoặc giữa màn | **Có** | Không | Bật chế độ máy bay rồi mở tab Home |
| Thao tác đồng thời | Dữ liệu thay đổi từ thiết bị khác | Không xử lý đặc biệt | — | — | — | — | Chấp nhận dữ liệu có độ trễ đến lần làm mới kế tiếp |
| Lỗi hệ thống | Lỗi không lường trước | Màn lỗi kèm nút Thử lại | `MSG-SYS-500` | Giữa vùng nội dung | **Có** | Không | Thanh điều hướng dưới vẫn phải dùng được |

### 6.1 Đặc tả message

| Mã | Nội dung (VI) | Vị trí | Thời điểm | Hành vi sau message | Phân loại |
|---|---|---|---|---|---|
| `MSG-HOME-001` | Chào mừng bạn đến HealthStride. Log buổi tập đầu tiên để nhận 100 điểm và huy hiệu Starter. | Giữa vùng nội dung | Khi tải xong và không có dữ liệu hoạt động | Không chặn; nút Log buổi tập được làm nổi bật | Business |
| `MSG-AUTH-401` | Phiên đăng nhập đã hết hạn | Toast | Sau khi máy chủ phản hồi | Điều hướng đăng nhập, xóa cache | Auth |
| `MSG-AUTH-403` | Tài khoản của bạn không còn quyền sử dụng ứng dụng. Vui lòng liên hệ bộ phận nhân sự. | Toàn màn | Sau khi máy chủ phản hồi | Chỉ còn nút Đăng xuất | Auth |
| `MSG-SYS-NET` | Dữ liệu có thể chưa mới nhất | Dòng nhỏ dưới app bar | Khi mất mạng nhưng có cache | Không chặn; có thể kéo làm mới | System |
| `MSG-SYS-500` | Không tải được dữ liệu. Vui lòng thử lại. | Giữa vùng nội dung | Sau khi máy chủ phản hồi | Có nút Thử lại | System |

## 7. Mapping dữ liệu vào / ra (Data mapping)

| Nhóm dữ liệu | Thành phần UI | Đọc từ đâu | Ghi ra đâu | Mục đích nghiệp vụ | Ghi chú |
|---|---|---|---|---|---|
| Hồ sơ người dùng | Lời chào, avatar, cờ vai trò | API tổng hợp dashboard | — | Cá nhân hóa và phân quyền hiển thị | |
| Điểm và cấp độ | Vòng tiến độ, hai chỉ số điểm | `Employee.lifetime_points`, `available_points`, `current_level` | — | Trả lời "tôi đang ở đâu" | `[DECISION]` D-003 — hai số riêng biệt |
| Streak | Chỉ báo streak | `Employee.current_streak_days` | — | Duy trì thói quen | |
| Mục tiêu kỳ hiện tại | Thẻ mục tiêu tuần | `Goal` | — | Trả lời "tôi còn thiếu gì" | Chỉ đọc mục tiêu đang hoạt động |
| Thử thách đang mở | Thẻ thử thách | `Challenge`, `ChallengeParticipation` | — | Gợi ý hành động | Tối đa 2 mục |
| Huy hiệu gần đây | Thẻ huy hiệu | `EmployeeBadge` | — | Ghi nhận thành tích | Tối đa 3 mục |
| Thứ hạng | Thẻ thứ hạng | `LeaderboardSnapshot` | — | Tạo động lực cạnh tranh | Kỳ tuần hiện tại |
| Gợi ý phần thưởng | Thẻ cửa hàng quà | `RewardCatalogItem` so với `available_points` | — | Dẫn dắt tới đích cuối của vòng lặp | |
| Nội dung động lực | Tip và quote | `MotivationContent` | — | Duy trì hứng thú | Khối trang trí, lỗi thì ẩn im lặng |

**Ghi chú kiến trúc:** toàn bộ dữ liệu trên đến từ **một** lời gọi API tổng hợp, không phải nhiều lời gọi rời rạc. Lý do: tránh việc các khối hiện lên lệch nhịp, gây cảm giác giật. `[NEEDS-CONFIRMATION]` với đội kỹ thuật về tính khả thi.

## 8. Email / Thông báo phát sinh từ màn

**Không phát sinh email hay notification.** Đây là màn chỉ đọc, không có hành động nào kích hoạt gửi thông báo.

## 9. Xuất dữ liệu: CSV / PDF / Excel

**Không có chức năng xuất dữ liệu** trên màn này.

## 10. Liên kết use case và chức năng

| Loại | Mã | Tên |
|---|---|---|
| Use case | `UC-GM-01` | Xem điểm và cấp độ hiện tại |
| Use case | `UC-SC-06` | Xem tip và quote hàng ngày |
| Function | `FN-002` | Trang chủ / Dashboard |
| User story | `US-07`, `US-14` | Cập nhật điểm và cấp độ, tip và quote hàng ngày |

## 11. Câu hỏi mở (Open questions)

| # | Câu hỏi | Ảnh hưởng đến màn này |
|---|---|---|
| 1 | Tên trường và điều kiện máy chủ đặt cờ vai trò Admin/HR là gì? | Quyết định cách ẩn/hiện lối vào khu vực quản trị |
| 2 | Ngưỡng thời gian nào thì làm mới dữ liệu khi đưa app từ nền lên trước? Đề xuất 5 phút. | Quyết định hành vi F-08 |
| 3 | Một lời gọi API tổng hợp cho toàn màn có khả thi không, hay phải tách nhiều lời gọi? | Quyết định thiết kế trạng thái tải |
| 4 | Khi nhân viên có nhiều mục tiêu cùng kỳ, ưu tiên hiển thị mục tiêu nào trên trang chủ? | Quyết định logic thẻ mục tiêu tuần |
