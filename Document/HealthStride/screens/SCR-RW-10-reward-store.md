# Screen Spec — SCR-RW-10 Cửa hàng phần thưởng

> **Trạng thái**: Draft v1.0
> **Cập nhật lần cuối**: 2026-08-11
> **Owner**: BA/PM
> **Nguồn chính**: `business-understanding.md` §6.8, `decision-log.md` D-003/D-006, `business-entities.md` (RewardCatalogItem, RewardRedemption)
> **Design system**: `Document/DESIGN-SYSTEM.md`

- **Screen ID:** `SCR-RW-10`
- **Business name:** Cửa hàng phần thưởng
- **Route / entry trigger:** `/reward/store` — vào từ thẻ cửa hàng quà trên `SCR-HOME-10` hoặc từ `SCR-PROF-10`. **Không** có tab riêng trên thanh điều hướng dưới
- **Related screens:** mở `SCR-RW-11` (xác nhận đổi quà), `SCR-RW-12` (lịch sử đổi quà)
- **Kiểu trình bày:** Trang đầy, danh sách thẻ theo mốc điểm
- **Nguồn chính:** `[FROM-CUSTOMER]`, `[DECISION]` D-003, D-006

---

## 1. Mục đích (Purpose)

Cửa hàng phần thưởng là **đích cuối của vòng lặp động lực**: nơi điểm tích lũy từ việc tập luyện chuyển thành giá trị thực tế. Nhân viên vào đây để xem mình đổi được gì với số điểm hiện có, và để biết cần thêm bao nhiêu điểm nữa cho phần thưởng mong muốn.

Điểm thiết kế then chốt: màn phải làm rõ khoảng cách giữa "điểm tôi đang có" và "điểm tôi cần", vì chính khoảng cách đó tạo động lực tập tiếp. Vì vậy phần thưởng ngoài tầm với **không bị ẩn** mà hiển thị kèm số điểm còn thiếu.

Toàn bộ yêu cầu đổi quà đều phải qua bộ phận nhân sự duyệt; ứng dụng không phát hành mã quà tự động. `[DECISION]` D-006

## 2. Điều kiện trước và phân quyền (Preconditions / Permissions)

Người dùng phải **đã đăng nhập**. Không yêu cầu vai trò đặc biệt.

Việc **xem** danh mục không yêu cầu điều kiện gì thêm. Việc **đổi** một phần thưởng yêu cầu điểm khả dụng lớn hơn hoặc bằng mức điểm của phần thưởng đó — đây là `[PERMISSION-CLIENT]`, máy khách tự tính từ số điểm trong hồ sơ, và máy chủ kiểm tra lại khi nhận yêu cầu.

**Loại permission gate:** route guard ở mức "đã đăng nhập"; điều kiện đủ điểm là ràng buộc nghiệp vụ ở mức hành động, không phải ở mức màn.

## 3. Thành phần giao diện (UI components)

| Thành phần | Kiểu | Bắt buộc? | Nguồn giá trị / option | Điều kiện enable/disable/hiển thị | Quy tắc nghiệp vụ | Ánh xạ entity | Validation và cách phản hồi (UX) | Ghi chú |
|---|---|---|---|---|---|---|---|---|
| Số điểm khả dụng | `Label / Văn bản tĩnh` | — | `API` hồ sơ người dùng | Luôn hiển thị, ghim ở đỉnh màn khi cuộn | Đây là số điểm dùng để đổi quà, **không** phải điểm xếp hạng | `Employee.available_points` | Khi API lỗi, hiển thị "—" và vô hiệu hóa toàn bộ nút Đổi kèm dòng giải thích. | Lato Bold, màu trắng, biểu tượng ví, nhãn "có thể đổi" — theo design system `[DECISION]` D-003 |
| Chú thích điểm | `Tooltip` | — | `static` | Hiển thị khi chạm biểu tượng dấu hỏi cạnh số điểm | Giải thích vì sao số này khác điểm trên bảng xếp hạng | — | Nội dung: "Đổi quà chỉ dùng điểm khả dụng. Điểm tích lũy dùng để xếp hạng và lên cấp sẽ không bị trừ." | Quan trọng — đây là điểm dễ gây hiểu nhầm nhất của sản phẩm |
| Liên kết lịch sử đổi quà | `Link / Liên kết` | — | — | Luôn hiển thị ở app bar | Dẫn sang `SCR-RW-12` | — | Không có trạng thái lỗi tại chỗ. | |
| Danh sách phần thưởng | `Data table (hàng biến thiên)` | — | `API` danh mục phần thưởng | Luôn hiển thị khi có dữ liệu | Sắp xếp theo mốc điểm tăng dần | `RewardCatalogItem` | Khi API lỗi, hiển thị khối lỗi giữa màn kèm nút Thử lại. Khi rỗng, xem `Empty` ở §5. | Dạng thẻ, không phải bảng — theo triết lý Gamified Social |
| Tên phần thưởng | `Label / Văn bản tĩnh` | — | `API` danh mục | Luôn hiển thị trong mỗi thẻ | — | `RewardCatalogItem.reward_name` | Khi tên quá dài, cắt sau 2 dòng kèm dấu ba chấm. | |
| Mốc điểm yêu cầu | `Badge / Nhãn trạng thái` | — | `API` danh mục | Luôn hiển thị trong mỗi thẻ | Số điểm khả dụng cần có để đổi | `RewardCatalogItem.points_cost` | Không có lỗi tại chỗ. | Màu `color-accent` khi đủ điểm, `color-neutral-500` khi chưa đủ |
| Thanh tiến độ tới phần thưởng | `Progress indicator` | — | Tính từ điểm khả dụng chia mốc điểm | Chỉ hiển thị trên thẻ **chưa** đủ điểm | Trực quan hóa khoảng cách còn lại | — | Khi điểm khả dụng bằng 0, thanh hiển thị 0% chứ không ẩn. | Kèm dòng chữ "Còn thiếu {N} điểm" — không dùng thanh đơn lẻ |
| Số lượng còn lại | `Badge / Nhãn trạng thái` | — | `API` danh mục | Chỉ hiển thị khi phần thưởng có giới hạn số lượng | Cảnh báo khan hiếm | `RewardCatalogItem.available_quantity` | Khi số lượng bằng 0, thẻ chuyển sang trạng thái hết hàng và nút Đổi bị vô hiệu hóa kèm nhãn "Đã hết". | `[NEEDS-CONFIRMATION]` — cơ chế giới hạn số lượng chưa được chốt |
| Nút Đổi | `Button (hành động chính)` | — | — | Bật khi điểm khả dụng đủ **và** còn số lượng; vô hiệu hóa trong các trường hợp còn lại | Mở màn xác nhận đổi quà | — | Khi chưa đủ điểm, nút hiển thị dạng vô hiệu hóa với nhãn "Còn thiếu {N} điểm" thay vì chữ "Đổi" — nêu rõ lý do thay vì chỉ làm mờ nút. Khi hết hàng, nhãn là "Đã hết". | Không dùng hộp thoại cảnh báo khi bấm nút vô hiệu hóa; lý do đã nằm ngay trên nút |
| Thẻ Top 1 tháng | `Label / Văn bản tĩnh` | — | `static` | Luôn hiển thị ở cuối danh sách | Giải thích phần thưởng đặc biệt không đổi bằng điểm | — | Không có nút Đổi vì đây không phải phần thưởng đổi được. | Nội dung: "Người dẫn đầu bảng xếp hạng tháng nhận thưởng riêng từ công ty" |
| Kéo để làm mới | `Button (hành động chính)` (cử chỉ) | — | — | Luôn khả dụng | Tải lại danh mục và số điểm | — | Khi lỗi, giữ dữ liệu cũ và hiển thị toast. | |

### 3.1 Trạng thái của một thẻ phần thưởng

| Trạng thái thẻ | Điều kiện | Hiển thị nút | Hiển thị thanh tiến độ |
|---|---|---|---|
| Đổi được | Đủ điểm khả dụng và còn số lượng | Nút "Đổi" màu `color-accent`, bật | Ẩn |
| Chưa đủ điểm | Điểm khả dụng nhỏ hơn mốc điểm | Nút vô hiệu hóa, nhãn "Còn thiếu {N} điểm" | Hiển thị |
| Hết hàng | Số lượng còn lại bằng 0 | Nút vô hiệu hóa, nhãn "Đã hết" | Ẩn |
| Đang chờ duyệt | Người dùng đã có một yêu cầu chưa xử lý cho chính phần thưởng này | Nút vô hiệu hóa, nhãn "Đang chờ duyệt" | Ẩn |

`[NEEDS-CONFIRMATION]` — Trạng thái "Đang chờ duyệt" giả định mỗi nhân viên chỉ được có một yêu cầu chưa xử lý cho mỗi phần thưởng. Cần xác nhận có giới hạn này không, hay nhân viên đổi được nhiều lần cùng lúc.

## 4. Tương tác và luồng nhỏ trên màn (User interactions / flows)

| Mã luồng | Tên luồng | Trigger | Tiền điều kiện | Xử lý hệ thống | Kết quả UI | Điều hướng / side effect | Ghi chú |
|---|---|---|---|---|---|---|---|
| F-01 | Tải màn | Mở từ trang chủ hoặc hồ sơ | Đã đăng nhập | Gọi API danh mục phần thưởng và số điểm khả dụng | Khung xương rồi lấp dữ liệu | Không | Số điểm và danh mục nên đến từ cùng một lời gọi để tránh lệch nhịp |
| F-02 | Bấm Đổi | Chạm nút Đổi trên thẻ đủ điều kiện | Đủ điểm, còn số lượng | — | Mở `SCR-RW-11` dạng bottom sheet với thông tin phần thưởng | — | Việc trừ điểm xảy ra ở `SCR-RW-11`, không phải ở đây |
| F-03 | Quay lại sau khi đổi thành công | Đóng `SCR-RW-11` sau khi xác nhận | — | Làm mới số điểm khả dụng và danh mục | Số điểm ở đỉnh màn giảm xuống bằng `motion-reward` (chạy số giảm); thẻ vừa đổi chuyển sang trạng thái "Đang chờ duyệt" | Toast xác nhận đã gửi yêu cầu | Người dùng phải thấy điểm mình vừa dùng bị trừ |
| F-04 | Bấm nút vô hiệu hóa | Chạm nút "Còn thiếu {N} điểm" | — | — | Không có phản hồi ngoài hiệu ứng chạm nhẹ | Không | Lý do đã hiển thị trên nút, không cần thông báo thêm |
| F-05 | Xem lịch sử đổi quà | Chạm liên kết ở app bar | — | — | Đẩy `SCR-RW-12` lên stack | — | |
| F-06 | Xem chú thích điểm | Chạm biểu tượng dấu hỏi | — | — | Hiển thị overlay giải thích, không có backdrop | Chạm ra ngoài để đóng | `Overlay / Popover`, không phải modal |
| F-07 | Kéo để làm mới | Kéo màn xuống | — | Gọi lại API | Chỉ báo tải ở đỉnh, dữ liệu cũ vẫn hiển thị | Không | |
| F-08 | Đạt đủ điểm cho một phần thưởng mới | Làm mới màn sau khi tích thêm điểm | Điểm khả dụng vừa vượt một mốc | — | Thẻ tương ứng chuyển từ trạng thái "Chưa đủ điểm" sang "Đổi được" kèm hiệu ứng nhấn nhẹ | Không | Khoảnh khắc mở khóa phần thưởng cần được nhìn thấy |

## 5. Trạng thái màn hình (States)

| State | Điều kiện vào | Người dùng thấy gì | Còn thao tác gì được | Cách thoát state | Ghi chú |
|---|---|---|---|---|---|
| `Initial` | Vừa mở màn | Khung xương của khối điểm và 3 thẻ đầu | Quay lại | API phản hồi | |
| `Loading` | Đang gọi API | Khung xương (lần đầu) hoặc chỉ báo ở đỉnh (làm mới) | Cuộn, quay lại | API phản hồi | |
| `Empty` | Danh mục phần thưởng chưa có mục nào | Văn bản: **"Danh mục phần thưởng đang được cập nhật. Điểm của bạn vẫn đang được tích lũy."** | Quay lại, kéo làm mới | Có phần thưởng | Xảy ra khi HR chưa nạp danh mục — không được để người dùng nghĩ điểm của họ vô nghĩa |
| `Error` | API lỗi và không có cache | Khối lỗi giữa vùng nội dung kèm nút Thử lại | Bấm Thử lại, quay lại | Thử lại thành công | |
| `Error` (thiếu số điểm) | Tải được danh mục nhưng không lấy được số điểm khả dụng | Danh mục hiển thị, số điểm hiển thị "—", toàn bộ nút Đổi vô hiệu hóa kèm dòng "Không xác định được số điểm của bạn" | Kéo làm mới | Làm mới thành công | Tuyệt đối không cho đổi khi chưa biết chắc số điểm |
| `Timeout` | API không phản hồi trong 15 giây | Cache kèm dòng cảnh báo, hoặc màn lỗi nếu chưa có cache | Bấm Thử lại | Thử lại thành công | Khi dùng cache, các nút Đổi vẫn bật nhưng máy chủ sẽ kiểm tra lại điểm khi nhận yêu cầu |
| `Concurrent / Race` | Phần thưởng hết hàng do người khác đổi trước, hoặc điểm thay đổi từ thiết bị khác | Màn vẫn hiển thị dữ liệu cũ; lỗi phát sinh khi xác nhận ở `SCR-RW-11` | Kéo làm mới | Làm mới | Máy chủ là nơi phán quyết cuối cùng — xem §6 |
| `Success` | Quay lại sau khi đổi thành công | Toast xác nhận, số điểm giảm, thẻ chuyển trạng thái chờ duyệt | Toàn bộ | Tự động | |
| `Session expired` | API trả 401 | Toast rồi điều hướng đăng nhập | Không | Tự động | |
| `No permission` | N/A | — | — | — | Mọi nhân viên đều xem được cửa hàng |

## 6. Validation, lỗi và trường hợp ngoại lệ

| Nhóm lỗi | Điều kiện phát sinh | Phản hồi UI mong đợi | Mã message | Vị trí hiển thị | Có nút Retry | Có chặn action | Ghi chú QA |
|---|---|---|---|---|---|---|---|
| Dữ liệu rỗng | Danh mục chưa có phần thưởng nào | Thông báo trấn an về việc điểm vẫn đang tích lũy | `MSG-RW-001` | Giữa vùng nội dung | Không | Không | Xóa hết danh mục phía quản trị rồi mở màn |
| Lỗi nhập liệu | N/A | — | — | — | — | — | Màn không có ô nhập |
| Lỗi nghiệp vụ | Không đủ điểm khả dụng | Nút hiển thị "Còn thiếu {N} điểm" ngay tại thẻ | `MSG-RW-002` | Trên nút | Không | Có | Tài khoản 0 điểm mở màn |
| Lỗi nghiệp vụ | Phần thưởng hết số lượng | Nút hiển thị "Đã hết" | `MSG-RW-003` | Trên nút | Không | Có | Đặt số lượng về 0 phía quản trị |
| Lỗi nghiệp vụ | Máy chủ từ chối vì hết hàng đúng lúc xác nhận | Toast, làm mới danh mục, thẻ chuyển sang "Đã hết" | `MSG-RW-004` | Toast | Không | Có | Hai người cùng đổi phần thưởng cuối cùng |
| Lỗi nghiệp vụ | Máy chủ từ chối vì điểm không đủ tại thời điểm xử lý | Toast, làm mới số điểm | `MSG-RW-005` | Toast | Không | Có | Đổi quà trên hai thiết bị gần như đồng thời |
| Lỗi quyền (401) | Phiên hết hạn | Toast rồi điều hướng đăng nhập | `MSG-AUTH-401` | Toast | Không | Có | |
| Lỗi quyền (403) | Tài khoản bị vô hiệu hóa | Màn thông báo kèm nút Đăng xuất | `MSG-AUTH-403` | Toàn màn | Không | Có | |
| Không tìm thấy (404) | Phần thưởng bị xóa khỏi danh mục khi người dùng đang xem | Toast, làm mới danh mục, thẻ biến mất | `MSG-RW-006` | Toast | Không | Có | HR xóa phần thưởng giữa lúc người dùng đang xem |
| Lỗi mạng / timeout | Mất kết nối | Cache kèm dòng cảnh báo, hoặc màn lỗi | `MSG-SYS-NET` | Dòng dưới app bar hoặc giữa màn | **Có** | Không | |
| Thao tác đồng thời | Điểm hoặc số lượng thay đổi trong lúc đang xem | Không xử lý tại màn; máy chủ phán quyết khi xác nhận | `MSG-RW-004` / `MSG-RW-005` | Toast | Không | Có | Đây là nhóm lỗi quan trọng nhất của màn — cần test kỹ |
| Lỗi hệ thống | Lỗi không lường trước | Khối lỗi kèm nút Thử lại | `MSG-SYS-500` | Giữa vùng nội dung | **Có** | Không | |

### 6.1 Đặc tả message

| Mã | Nội dung (VI) | Vị trí | Thời điểm | Hành vi sau message | Phân loại |
|---|---|---|---|---|---|
| `MSG-RW-001` | Danh mục phần thưởng đang được cập nhật. Điểm của bạn vẫn đang được tích lũy. | Giữa vùng nội dung | Khi tải xong và danh mục rỗng | Không chặn | Business |
| `MSG-RW-002` | Còn thiếu {N} điểm | Trên nút của thẻ | Ngay khi hiển thị thẻ | Chặn mở màn xác nhận | Business |
| `MSG-RW-003` | Đã hết | Trên nút của thẻ | Ngay khi hiển thị thẻ | Chặn mở màn xác nhận | Business |
| `MSG-RW-004` | Phần thưởng này vừa hết. Điểm của bạn chưa bị trừ. | Toast | Sau khi máy chủ từ chối | Làm mới danh mục, không trừ điểm | Business |
| `MSG-RW-005` | Số điểm khả dụng không đủ. Vui lòng kiểm tra lại. | Toast | Sau khi máy chủ từ chối | Làm mới số điểm, không trừ điểm | Business |
| `MSG-RW-006` | Phần thưởng này không còn trong danh mục | Toast | Sau khi máy chủ phản hồi | Làm mới danh mục | Business |
| `MSG-AUTH-401` | Phiên đăng nhập đã hết hạn | Toast | Sau khi máy chủ phản hồi | Điều hướng đăng nhập | Auth |
| `MSG-AUTH-403` | Tài khoản của bạn không còn quyền sử dụng ứng dụng. Vui lòng liên hệ bộ phận nhân sự. | Toàn màn | Sau khi máy chủ phản hồi | Chỉ còn nút Đăng xuất | Auth |
| `MSG-SYS-NET` | Dữ liệu có thể chưa mới nhất | Dòng nhỏ dưới app bar | Khi mất mạng nhưng có cache | Không chặn | System |
| `MSG-SYS-500` | Không tải được danh mục phần thưởng. Vui lòng thử lại. | Giữa vùng nội dung | Sau khi máy chủ phản hồi | Có nút Thử lại | System |

Hai message `MSG-RW-004` và `MSG-RW-005` **bắt buộc** nói rõ "điểm của bạn chưa bị trừ". Đây là nỗi lo lớn nhất của người dùng khi một giao dịch điểm thất bại; không trấn an rõ ràng sẽ tạo ra khiếu nại tới bộ phận nhân sự.

## 7. Mapping dữ liệu vào / ra (Data mapping)

| Nhóm dữ liệu | Thành phần UI | Đọc từ đâu | Ghi ra đâu | Mục đích nghiệp vụ | Ghi chú |
|---|---|---|---|---|---|
| Điểm khả dụng | Khối điểm ở đỉnh màn | `Employee.available_points` | — | Xác định phần thưởng nào đổi được | `[DECISION]` D-003 — không dùng điểm tích lũy |
| Danh mục phần thưởng | Danh sách thẻ | `RewardCatalogItem` | — | Hiển thị lựa chọn | Sắp xếp theo mốc điểm tăng dần |
| Số lượng còn lại | Nhãn khan hiếm trên thẻ | `RewardCatalogItem.available_quantity` | — | Cảnh báo khan hiếm | `[NEEDS-CONFIRMATION]` cơ chế giới hạn |
| Yêu cầu đang chờ | Trạng thái thẻ "Đang chờ duyệt" | `RewardRedemption` lọc theo người dùng và trạng thái chờ duyệt | — | Tránh đổi trùng | `[NEEDS-CONFIRMATION]` có giới hạn một yêu cầu mỗi phần thưởng không |
| Yêu cầu đổi quà mới | (tạo ở `SCR-RW-11`) | — | `RewardRedemption` trạng thái "Chờ duyệt" + `PointsTransaction` trừ điểm khả dụng | Ghi nhận yêu cầu | Màn này chỉ mở màn xác nhận, không tự tạo bản ghi |

## 8. Email / Thông báo phát sinh từ màn

**Không phát sinh email.** Toàn bộ trao đổi diễn ra qua thông báo trong ứng dụng.

Bản thân màn cửa hàng không trực tiếp gửi thông báo nào — hành động đổi quà hoàn tất ở `SCR-RW-11`. Tuy nhiên màn này là nơi bắt đầu chuỗi ba thông báo sau, đặc tả đầy đủ theo `[DECISION]` D-008:

| Mã | Điều kiện kích hoạt | Người nhận | Nội dung | Nguồn dữ liệu biến | Thời điểm gửi | Xử lý khi gửi lỗi |
|---|---|---|---|---|---|---|
| `NOTIF-RW-01` | Nhân viên xác nhận đổi quà tại `SCR-RW-11` | Mọi tài khoản vai trò Admin/HR | "{ho_ten} vừa yêu cầu đổi {ten_phan_thuong}" | `Employee.full_name`, `RewardCatalogItem.reward_name` | Ngay khi bản ghi `RewardRedemption` được tạo | Ghi log và thử lại tối đa 3 lần; yêu cầu vẫn nằm trong danh sách chờ duyệt nên nhân sự không mất việc |
| `NOTIF-RW-02` | Nhân sự bấm Duyệt tại `SCR-ADM-12` | Nhân viên đã gửi yêu cầu | "Yêu cầu đổi {ten_phan_thuong} đã được duyệt. Bộ phận nhân sự sẽ liên hệ với bạn." | `RewardCatalogItem.reward_name` | Ngay khi trạng thái chuyển sang Đã duyệt | Như trên; nhân viên vẫn xem được trạng thái ở `SCR-RW-12` |
| `NOTIF-RW-03` | Nhân sự bấm Từ chối tại `SCR-ADM-12` | Nhân viên đã gửi yêu cầu | "Yêu cầu đổi {ten_phan_thuong} không được duyệt. {so_diem} điểm đã được hoàn lại. Lý do: {ly_do}" | `RewardCatalogItem.reward_name`, `RewardCatalogItem.points_cost`, `RewardRedemption.rejection_reason` | Ngay khi trạng thái chuyển sang Từ chối | Như trên |

**Điều hướng khi chạm vào thông báo:** cả `NOTIF-RW-02` và `NOTIF-RW-03` mở thẳng `SCR-RW-12` (lịch sử đổi quà) chứ không mở màn cửa hàng này.

`NOTIF-RW-03` **bắt buộc** nêu rõ số điểm đã hoàn lại. Nhân viên bị từ chối mà không thấy điểm quay lại sẽ khiếu nại trực tiếp lên bộ phận nhân sự — đây là rủi ro vận hành lớn nhất của luồng phần thưởng.

Nhân viên tắt được từng nhóm thông báo trong `SCR-PROF-10`. Khi nhân viên đã tắt nhóm thông báo phần thưởng, hệ thống vẫn cập nhật trạng thái trong `SCR-RW-12` bình thường.

## 9. Xuất dữ liệu: CSV / PDF / Excel

**Không có chức năng xuất dữ liệu** trên màn này. Báo cáo ngân sách phần thưởng thuộc về `SCR-ADM-13` (giai đoạn 2).

## 10. Liên kết use case và chức năng

| Loại | Mã | Tên |
|---|---|---|
| Use case | `UC-RW-01` | Xem danh mục phần thưởng |
| Use case | `UC-RW-02` | Đổi điểm lấy phần thưởng (hoàn tất ở `SCR-RW-11`) |
| Function | `FN-021` | Cửa hàng phần thưởng |
| Function | `FN-022` | Đổi điểm lấy quà |
| User story | `US-15` | Nhân viên đổi điểm lấy phần thưởng |

## 11. Câu hỏi mở (Open questions)

| # | Câu hỏi | Ảnh hưởng đến màn này |
|---|---|---|
| 1 | Phần thưởng có cơ chế giới hạn số lượng không, và giới hạn theo tháng hay tổng thể? | Quyết định có hiển thị nhãn khan hiếm và trạng thái "Đã hết" hay không |
| 2 | Mỗi nhân viên được có bao nhiêu yêu cầu chưa xử lý cùng lúc? | Quyết định logic trạng thái "Đang chờ duyệt" ở §3.1 |
| 3 | Có giới hạn tần suất đổi quà (ví dụ mỗi tháng một lần cho quà giá trị cao) không? | Quyết định có cần thêm điều kiện vô hiệu hóa nút Đổi hay không |

Hai câu hỏi về thông báo trước đây ở mục này đã được chốt bằng `[DECISION]` D-008 — xem §8.
