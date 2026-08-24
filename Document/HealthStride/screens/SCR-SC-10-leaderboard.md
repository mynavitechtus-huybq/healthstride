# Screen Spec — SCR-SC-10 Bảng xếp hạng

> **Trạng thái**: Draft v1.0
> **Cập nhật lần cuối**: 2026-08-11
> **Owner**: BA/PM
> **Nguồn chính**: `business-understanding.md` §6.5, `decision-log.md` D-003, `screen-flow.md`
> **Design system**: `Document/HealthStride/design-system.md`

- **Screen ID:** `SCR-SC-10`
- **Business name:** Bảng xếp hạng
- **Route / entry trigger:** `/community/leaderboard` — tab "Rank" trên thanh điều hướng dưới; cũng vào được từ thẻ thứ hạng trên `SCR-HOME-10`
- **Related screens:** mở `SCR-PROF-10` (hồ sơ người khác), `SCR-SC-12` (chi tiết Gym Team — giai đoạn 2)
- **Kiểu trình bày:** Trang đầy, có tab chuyển kỳ và tab chuyển tiêu chí
- **Nguồn chính:** `[FROM-CUSTOMER]`, `[DECISION]` D-003

---

## 1. Mục đích (Purpose)

Bảng xếp hạng biến việc tập luyện cá nhân thành một cuộc thi đua có tính cộng đồng. Nhân viên vào đây để biết mình đang đứng ở đâu so với đồng nghiệp, và để thấy những người đang dẫn đầu.

Điểm thiết kế then chốt: người dùng phải tìm thấy **chính mình** ngay lập tức, kể cả khi họ đứng thứ 200. Một bảng xếp hạng chỉ hiển thị Top 10 mà không cho biết vị trí bản thân sẽ khiến đa số nhân viên cảm thấy bị loại khỏi cuộc chơi.

Thứ hạng tính theo **điểm tích lũy trọn đời**, nên việc đổi quà không bao giờ làm tụt hạng. `[DECISION]` D-003

## 2. Điều kiện trước và phân quyền (Preconditions / Permissions)

Người dùng phải **đã đăng nhập**. Không yêu cầu vai trò đặc biệt — mọi nhân viên đều xem được bảng xếp hạng toàn công ty.

**Loại permission gate:** route guard ở mức "đã đăng nhập".

**Mức hiển thị của từng nhân viên** quyết định họ xuất hiện thế nào với người khác, theo `[DECISION]` D-009:

| Mức của nhân viên A | Người khác nhìn thấy A trên bảng xếp hạng |
|---|---|
| Công khai | Hàng đầy đủ: thứ hạng, ảnh đại diện, họ tên, chỉ số |
| Ẩn danh | Hàng vẫn tồn tại và vẫn chiếm thứ hạng, nhưng hiển thị ảnh mặc định và nhãn "Ẩn danh"; không chạm vào được để mở hồ sơ |
| Riêng tư | Hàng không xuất hiện; thứ hạng của những người còn lại được tính lại liền mạch |

**Quy tắc bắt buộc — thứ hạng hiển thị phải liền mạch.** Khi loại bỏ người ở mức Riêng tư, thứ hạng hiển thị cho người khác không được để lỗ trống. Nếu bảng hiển thị hạng 1, 2 rồi nhảy sang 4, người xem sẽ suy ra có người đang ẩn ở hạng 3 — làm hỏng chính mục đích của mức Riêng tư.

**Hệ quả:** thứ hạng một người thấy cho chính mình có thể **khác** thứ hạng người khác thấy về họ. Đây là chủ đích của thiết kế, không phải lỗi. Hàng ghim luôn hiển thị thứ hạng thật trong toàn công ty.

`[NEEDS-CONFIRMATION]` Q-008b — Khi một nhân viên ở mức Ẩn danh hoặc Riêng tư đứng đầu bảng xếp hạng tháng, có công bố tên họ khi trao thưởng Top 1 không?

## 3. Thành phần giao diện (UI components)

| Thành phần | Kiểu | Bắt buộc? | Nguồn giá trị / option | Điều kiện enable/disable/hiển thị | Quy tắc nghiệp vụ | Ánh xạ entity | Validation và cách phản hồi (UX) | Ghi chú |
|---|---|---|---|---|---|---|---|---|
| Chọn kỳ | `Segmented control` | Có | `static` — Tuần này (week), Tháng này (month) | Luôn hiển thị, luôn bật | Quyết định phạm vi thời gian tính điểm | `LeaderboardSnapshot.period` | Mặc định chọn "Tuần này". Không thể bỏ chọn nên không có lỗi rỗng. Khi đổi kỳ, danh sách tải lại. | Đặt ngay dưới app bar |
| Chọn tiêu chí | `Tab` | Có | `static` — Điểm (points), Streak (streak) | Luôn hiển thị, luôn bật | Quyết định sắp xếp theo điểm tích lũy hay theo số ngày streak | — | Mặc định chọn "Điểm". Khi đổi tab, danh sách tải lại và vị trí cuộn về đầu. | Hai bảng xếp hạng độc lập theo mô tả nghiệp vụ |
| Bục vinh danh Top 3 | `Data table (tĩnh)` | — | `API` bảng xếp hạng | Ẩn khi số người có xếp hạng ít hơn 3 | Hiển thị 3 người dẫn đầu với avatar lớn và huy chương | `LeaderboardSnapshot` | Khi có ít hơn 3 người xếp hạng, ẩn khối này và hiển thị tất cả trong danh sách thường. | Huy chương luôn kèm số thứ hạng. Người ở mức Ẩn danh vẫn lên bục nhưng với ảnh mặc định và nhãn "Ẩn danh" |
| Danh sách xếp hạng | `Data table (hàng biến thiên)` | — | `API` bảng xếp hạng | Luôn hiển thị khi có dữ liệu | Hiển thị hạng, avatar, tên, chỉ số theo tiêu chí đang chọn, chỉ báo streak. Áp dụng mức hiển thị theo D-009 | `LeaderboardSnapshot`, `Employee.privacy_visibility` | Khi API lỗi, hiển thị khối lỗi giữa màn kèm nút Thử lại. Khi rỗng, xem trạng thái `Empty` ở §5. | Thành phần Leaderboard row theo design system |
| Hàng ẩn danh | `Data table (hàng biến thiên)` | — | `API` bảng xếp hạng | Hiển thị khi người ở vị trí đó có mức Ẩn danh | Vẫn chiếm thứ hạng và hiển thị chỉ số thật, nhưng không lộ danh tính | `Employee.privacy_visibility` | Không chạm vào được; khi người dùng chạm, không có phản hồi ngoài hiệu ứng chạm nhẹ. | Ảnh mặc định `color-neutral-800`, nhãn "Ẩn danh" màu `color-neutral-500` |
| Hàng của tôi (ghim) | `Data table (tĩnh)` | — | `API` bảng xếp hạng | **Luôn hiển thị**, ghim ở đáy màn khi hàng của người dùng nằm ngoài vùng đang cuộn | Cho người dùng luôn thấy vị trí của mình. **Luôn hiển thị tên thật và thứ hạng thật**, kể cả khi người dùng đang ở mức Ẩn danh hoặc Riêng tư | `LeaderboardSnapshot` | Khi người dùng chưa có thứ hạng, hàng ghim hiển thị "Chưa xếp hạng — log buổi tập để tham gia". | Nền Level 2, viền trái 1 dp `color-accent` |
| Nhắc mức hiển thị | `Badge / Nhãn trạng thái` | — | `Employee.privacy_visibility` | Chỉ hiển thị khi người dùng đang ở mức Ẩn danh hoặc Riêng tư | Cho người dùng biết vì sao đồng nghiệp không thấy tên mình | `Employee.privacy_visibility` | Nội dung: "Bạn đang ở chế độ {Ẩn danh / Riêng tư}" kèm liên kết sang cài đặt. | Đặt trong hàng ghim; tránh việc người dùng tưởng hệ thống lỗi |
| Chỉ số theo tiêu chí | `Label / Văn bản tĩnh` | — | `API` bảng xếp hạng | Luôn hiển thị trong mỗi hàng | Tab Điểm hiển thị điểm tích lũy; tab Streak hiển thị số ngày | `Employee.lifetime_points` hoặc `current_streak_days` | Khi giá trị bằng 0, hiển thị số 0, không hiển thị dấu gạch. | Nhãn "tổng điểm" phải rõ để không nhầm với điểm khả dụng |
| Kéo để làm mới | `Button (hành động chính)` (cử chỉ) | — | — | Luôn khả dụng | Tải lại bảng xếp hạng | — | Khi làm mới lỗi, giữ dữ liệu cũ và hiển thị toast. | |
| Tải thêm | `Pagination` | — | `API` bảng xếp hạng, phân trang | Chỉ hiển thị khi còn dữ liệu chưa tải | Tải thêm 20 hàng mỗi lần | — | Khi tải thêm lỗi, hiển thị nút Thử lại ở cuối danh sách, giữ nguyên các hàng đã tải. | Cuộn vô hạn với ngưỡng kích hoạt trước khi chạm đáy |
| Thời điểm cập nhật | `Label / Văn bản tĩnh` | — | `API` bảng xếp hạng | Luôn hiển thị ở cuối danh sách | Cho biết dữ liệu tính đến thời điểm nào | `LeaderboardSnapshot` | Khi không có thông tin thời điểm, ẩn dòng này. | Quan trọng vì bảng xếp hạng có thể tính theo snapshot chứ không thời gian thực |

### 3.1 Ghi chú về cách tính hạng

Thứ hạng tính trên **điểm tích lũy trọn đời** (`lifetime_points`), không phải điểm khả dụng. Người dùng đổi quà bao nhiêu cũng không ảnh hưởng vị trí. `[DECISION]` D-003

`[NEEDS-CONFIRMATION]` Q-010 — Mốc reset của kỳ tuần và kỳ tháng chưa được chốt (bắt đầu thứ Hai hay Chủ Nhật, múi giờ nào). Điều này quyết định nội dung nhãn "Tuần này" và thời điểm bảng xếp hạng đổi số liệu.

`[NEEDS-CONFIRMATION]` — Quy tắc xử lý khi hai người đồng điểm chưa được chốt (Q-014). Đề xuất của BA: người đạt mốc điểm đó **sớm hơn** xếp trên; nếu vẫn bằng, sắp theo thứ tự bảng chữ cái của tên.

## 4. Tương tác và luồng nhỏ trên màn (User interactions / flows)

| Mã luồng | Tên luồng | Trigger | Tiền điều kiện | Xử lý hệ thống | Kết quả UI | Điều hướng / side effect | Ghi chú |
|---|---|---|---|---|---|---|---|
| F-01 | Tải màn lần đầu | Mở tab Rank | Đã đăng nhập | Gọi API bảng xếp hạng với kỳ tuần, tiêu chí điểm, trang đầu | Khung xương rồi lấp dữ liệu; cuộn tự động sao cho hàng của người dùng nằm trong tầm nhìn nếu ở trong 50 hàng đầu | Không | Nếu người dùng ngoài top 50, không cuộn tự động — dùng hàng ghim ở đáy |
| F-02 | Đổi kỳ | Chạm phân đoạn Tuần/Tháng | — | Gọi lại API với kỳ mới | Danh sách chuyển bằng cross-fade `motion-quick`, cuộn về đầu | Không | Giữ nguyên tiêu chí đang chọn |
| F-03 | Đổi tiêu chí | Chạm tab Điểm/Streak | — | Gọi lại API với tiêu chí mới | Như F-02 | Không | Giữ nguyên kỳ đang chọn |
| F-04 | Xem hồ sơ người khác | Chạm một hàng | Hàng đó thuộc người ở mức Công khai | — | Đẩy `SCR-PROF-10` của người đó lên stack, hiển thị tên, ảnh, cấp độ, huy hiệu, điểm tích lũy | — | Hồ sơ người khác **không bao giờ** hiển thị cân nặng, calories hay giấc ngủ `[DECISION]` D-009 |
| F-04b | Chạm hàng ẩn danh | Chạm một hàng của người ở mức Ẩn danh | — | — | Không có phản hồi ngoài hiệu ứng chạm nhẹ | Không | Không hiển thị thông báo giải thích — làm vậy sẽ xác nhận rằng có một người thật đứng sau hàng đó |
| F-05 | Chạm hàng của mình | Chạm hàng ghim ở đáy | — | — | Cuộn danh sách tới đúng vị trí hàng của người dùng | — | Nếu người dùng chưa xếp hạng, chạm vào mở `SCR-WO-11` |
| F-06 | Tải thêm | Cuộn gần đáy danh sách | Còn dữ liệu chưa tải | Gọi API trang tiếp theo | Thêm 20 hàng vào cuối, chỉ báo tải nhỏ ở đáy | Không | Hàng ghim vẫn nằm trên cùng lớp, không bị đẩy đi |
| F-07 | Kéo để làm mới | Kéo màn xuống | — | Gọi lại API trang đầu | Chỉ báo tải ở đỉnh, dữ liệu cũ vẫn hiển thị | Reset về trang đầu | |
| F-08 | Quay lại sau khi log buổi tập | Chuyển sang tab Rank sau khi lưu buổi tập | — | Gọi lại API | Nếu thứ hạng người dùng tăng, hàng ghim hiển thị chỉ báo tăng hạng bằng `motion-reward` | Không | Khoảnh khắc thấy mình vượt lên là phần thưởng xã hội — cần được nhấn mạnh |

## 5. Trạng thái màn hình (States)

| State | Điều kiện vào | Người dùng thấy gì | Còn thao tác gì được | Cách thoát state | Ghi chú |
|---|---|---|---|---|---|
| `Initial` | Vừa mở tab, chưa có cache | Khung xương của bục vinh danh và 5 hàng đầu | Chuyển tab, đổi kỳ/tiêu chí | API phản hồi | |
| `Loading` | Đang gọi API | Khung xương (lần đầu) hoặc chỉ báo ở đỉnh (làm mới) hoặc chỉ báo ở đáy (tải thêm) | Cuộn, chuyển tab | API phản hồi | Ba vị trí chỉ báo khác nhau cho ba tình huống tải khác nhau |
| `Empty` | Chưa có nhân viên nào có điểm trong kỳ đang chọn | Văn bản: **"Chưa có ai ghi điểm trong tuần này. Hãy là người đầu tiên."** kèm nút Log buổi tập | Bấm nút, đổi kỳ | Có người ghi điểm | Xảy ra vào đầu mỗi kỳ, đặc biệt sáng thứ Hai — là cơ hội tạo động lực chứ không phải lỗi |
| `Empty` (cá nhân) | Có người xếp hạng nhưng người dùng chưa có điểm | Danh sách hiển thị bình thường; hàng ghim ghi "Chưa xếp hạng — log buổi tập để tham gia" | Toàn bộ | Log buổi tập đầu tiên | Không được để hàng ghim trống |
| `Error` | API lỗi và không có cache | Khối lỗi giữa vùng nội dung kèm nút Thử lại | Bấm Thử lại, chuyển tab, đổi kỳ | Thử lại thành công | Thanh điều hướng dưới và bộ chọn kỳ vẫn dùng được |
| `Error` (tải thêm) | Lỗi khi tải trang tiếp theo | Nút Thử lại ở cuối danh sách; các hàng đã tải giữ nguyên | Bấm Thử lại, cuộn | Thử lại thành công | Không được xóa dữ liệu đã tải |
| `Timeout` | API không phản hồi trong 15 giây | Nếu có cache, hiển thị cache kèm dòng "Dữ liệu có thể chưa mới nhất". Nếu không, hiển thị như `Error`. | Bấm Thử lại | Thử lại thành công | |
| `Concurrent / Race` | Thứ hạng thay đổi do người khác ghi điểm trong lúc đang xem | Không cập nhật tự động; dữ liệu đổi ở lần làm mới kế tiếp | Kéo làm mới | Làm mới | Không dùng cập nhật thời gian thực — sẽ gây nhảy hàng khó chịu khi đang cuộn |
| `Success` | N/A | — | — | — | Màn chỉ đọc |
| `Session expired` | API trả 401 | Toast rồi điều hướng đăng nhập | Không | Tự động | |
| `No permission` | N/A | — | — | — | Mọi nhân viên đều xem được bảng xếp hạng |

## 6. Validation, lỗi và trường hợp ngoại lệ

| Nhóm lỗi | Điều kiện phát sinh | Phản hồi UI mong đợi | Mã message | Vị trí hiển thị | Có nút Retry | Có chặn action | Ghi chú QA |
|---|---|---|---|---|---|---|---|
| Dữ liệu rỗng | Không ai có điểm trong kỳ | Trạng thái mời gọi kèm nút Log buổi tập | `MSG-LB-001` | Giữa vùng nội dung | Không | Không | Kiểm tra vào đầu kỳ mới |
| Dữ liệu rỗng (cá nhân) | Người dùng chưa có điểm | Hàng ghim hiển thị "Chưa xếp hạng" | `MSG-LB-002` | Hàng ghim ở đáy | Không | Không | Tài khoản mới |
| Lỗi nhập liệu | N/A | — | — | — | — | — | Màn chỉ đọc, không có ô nhập |
| Lỗi nghiệp vụ | N/A | — | — | — | — | — | Không có thao tác nghiệp vụ |
| Lỗi quyền (401) | Phiên hết hạn | Toast rồi điều hướng đăng nhập | `MSG-AUTH-401` | Toast | Không | Có | |
| Lỗi quyền (403) | Tài khoản bị vô hiệu hóa | Màn thông báo kèm nút Đăng xuất | `MSG-AUTH-403` | Toàn màn | Không | Có | |
| Không tìm thấy (404) | Chạm vào hồ sơ một nhân viên đã nghỉ việc | Toast: "Không tìm thấy nhân viên này" và ở lại màn xếp hạng | `MSG-LB-003` | Toast | Không | Có | Liên quan Q-012 — chính sách dữ liệu khi nghỉ việc |
| Lỗi mạng / timeout | Mất kết nối | Cache kèm dòng cảnh báo, hoặc màn lỗi | `MSG-SYS-NET` | Dòng dưới app bar hoặc giữa màn | **Có** | Không | Bật chế độ máy bay |
| Thao tác đồng thời | Thứ hạng đổi trong lúc đang cuộn | Không xử lý đặc biệt | — | — | — | — | Chấp nhận độ trễ đến lần làm mới |
| Lỗi hệ thống | Lỗi không lường trước | Khối lỗi kèm nút Thử lại | `MSG-SYS-500` | Giữa vùng nội dung | **Có** | Không | |

### 6.1 Đặc tả message

| Mã | Nội dung (VI) | Vị trí | Thời điểm | Hành vi sau message | Phân loại |
|---|---|---|---|---|---|
| `MSG-LB-001` | Chưa có ai ghi điểm trong {kỳ}. Hãy là người đầu tiên. | Giữa vùng nội dung | Khi tải xong và danh sách rỗng | Không chặn; kèm nút Log buổi tập | Business |
| `MSG-LB-002` | Chưa xếp hạng — log buổi tập để tham gia | Hàng ghim ở đáy | Khi người dùng không có trong bảng | Không chặn; chạm vào mở màn log | Business |
| `MSG-LB-003` | Không tìm thấy nhân viên này | Toast | Sau khi máy chủ phản hồi | Ở lại màn xếp hạng | Business |
| `MSG-AUTH-401` | Phiên đăng nhập đã hết hạn | Toast | Sau khi máy chủ phản hồi | Điều hướng đăng nhập | Auth |
| `MSG-AUTH-403` | Tài khoản của bạn không còn quyền sử dụng ứng dụng. Vui lòng liên hệ bộ phận nhân sự. | Toàn màn | Sau khi máy chủ phản hồi | Chỉ còn nút Đăng xuất | Auth |
| `MSG-SYS-NET` | Dữ liệu có thể chưa mới nhất | Dòng nhỏ dưới app bar | Khi mất mạng nhưng có cache | Không chặn | System |
| `MSG-SYS-500` | Không tải được bảng xếp hạng. Vui lòng thử lại. | Giữa vùng nội dung | Sau khi máy chủ phản hồi | Có nút Thử lại | System |

## 7. Mapping dữ liệu vào / ra (Data mapping)

| Nhóm dữ liệu | Thành phần UI | Đọc từ đâu | Ghi ra đâu | Mục đích nghiệp vụ | Ghi chú |
|---|---|---|---|---|---|
| Danh sách xếp hạng | Bục vinh danh, danh sách, hàng ghim | `LeaderboardSnapshot` kết hợp `Employee` | — | So sánh với đồng nghiệp | Phân trang 20 hàng mỗi lần |
| Thứ hạng cá nhân | Hàng ghim | `LeaderboardSnapshot` lọc theo người dùng hiện tại | — | Người dùng luôn thấy vị trí mình | Trả về cùng lời gọi API, không gọi riêng |
| Điểm tích lũy | Cột chỉ số ở tab Điểm | `Employee.lifetime_points` | — | Tiêu chí xếp hạng chính | `[DECISION]` D-003 — không dùng điểm khả dụng |
| Streak | Cột chỉ số ở tab Streak, chỉ báo trong mỗi hàng | `Employee.current_streak_days` | — | Tiêu chí xếp hạng phụ | |
| Thông tin nhận dạng | Avatar, tên | `Employee.full_name`, ảnh đại diện, `privacy_visibility` | — | Nhận ra đồng nghiệp | Máy chủ **phải** lọc theo mức hiển thị trước khi trả dữ liệu về máy khách — không được gửi tên thật của người ẩn rồi để máy khách tự che |
| Thời điểm cập nhật | Dòng cuối danh sách | `LeaderboardSnapshot` | — | Minh bạch về độ mới của dữ liệu | |

**Ghi chú bảo mật quan trọng:** việc áp dụng mức hiển thị D-009 phải diễn ra **ở phía máy chủ**. Nếu máy chủ trả về danh sách đầy đủ kèm tên thật rồi để giao diện tự ẩn đi, bất kỳ ai xem được phản hồi mạng đều đọc được danh tính người đã chọn ẩn. Với người ở mức Riêng tư, máy chủ phải loại bỏ hẳn bản ghi và tính lại thứ hạng trước khi trả về.

## 8. Email / Thông báo phát sinh từ màn

**Không phát sinh email hay notification.** Đây là màn chỉ đọc.

**Không gửi thông báo khi nhân viên vào hoặc rời Top 10.** `[DECISION]` D-008 loại trừ loại thông báo này khỏi bản phát hành đầu tiên. Lý do: thứ hạng thay đổi liên tục nên loại thông báo này có tần suất cao khó kiểm soát, và rủi ro là nhân viên tắt toàn bộ quyền thông báo của ứng dụng, làm mất luôn ba thông báo phần thưởng vốn quan trọng hơn.

Có thể xem xét lại ở giai đoạn sau, khi đã có dữ liệu thực tế về tần suất thay đổi thứ hạng và khi màn cài đặt cho phép nhân viên bật riêng nhóm thông báo này.

## 9. Xuất dữ liệu: CSV / PDF / Excel

**Không có chức năng xuất dữ liệu** cho nhân viên. Việc xuất báo cáo xếp hạng phục vụ trao thưởng thuộc về `SCR-ADM-13` (giai đoạn 2).

## 10. Liên kết use case và chức năng

| Loại | Mã | Tên |
|---|---|---|
| Use case | `UC-SC-01` | Xem bảng xếp hạng |
| Function | `FN-014` | Bảng xếp hạng |
| User story | `US-10` | Nhân viên xem bảng xếp hạng |

## 11. Câu hỏi mở (Open questions)

| # | Câu hỏi | Ảnh hưởng đến màn này |
|---|---|---|
| 1 | Q-010 — Mốc reset kỳ tuần và kỳ tháng, múi giờ nào? | Quyết định nhãn bộ chọn kỳ và thời điểm số liệu đổi |
| 2 | Q-014 — Quy tắc xử lý đồng điểm là gì? | Quyết định thứ tự sắp xếp; BA đề xuất ưu tiên người đạt mốc sớm hơn |
| 3 | Q-008b — Có công bố tên người ở mức ẩn khi họ đứng đầu bảng xếp hạng tháng không? | Quyết định quy trình trao thưởng Top 1 |
| 4 | Bảng xếp hạng tính thời gian thực hay theo snapshot định kỳ? | Quyết định có cần dòng "cập nhật lúc" hay không, và tần suất làm mới |
| 5 | Có bổ sung bảng xếp hạng theo phòng ban ngoài toàn công ty không? | Quyết định có cần thêm một chiều lọc nữa hay không |

Câu hỏi về thông báo khi vào hoặc rời Top 10 đã được chốt bằng `[DECISION]` D-008 — không gửi, xem §8.
