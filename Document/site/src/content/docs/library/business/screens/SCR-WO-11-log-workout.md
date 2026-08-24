---
title: 'HealthStride: SCR WO 11 log workout'
description: 'Tài liệu nghiệp vụ, kế hoạch và kiến trúc của HealthStride.'
---
# Screen Spec — SCR-WO-11 Log buổi tập

> **Trạng thái**: Draft v1.0
> **Cập nhật lần cuối**: 2026-08-11
> **Owner**: BA/PM
> **Nguồn chính**: `business-understanding.md` §6.1, `decision-log.md` D-001/D-003/D-005/D-007, `business-entities.md` (WorkoutLog)
> **Design system**: `Document/DESIGN-SYSTEM.md`

- **Screen ID:** `SCR-WO-11`
- **Business name:** Log buổi tập
- **Route / entry trigger:** `/workout/log` — mở từ nút hành động trung tâm trên thanh điều hướng dưới (có mặt ở mọi tab), hoặc từ nút "Log workout" trên `SCR-HOME-10`
- **Related screens:** đến từ `SCR-HOME-10`, `SCR-WO-10`; mở `SCR-WO-12` (danh mục bài tập); sau khi lưu quay về màn gọi
- **Kiểu trình bày:** Bottom sheet (không phải trang đầy) — giữ ngữ cảnh màn phía sau, theo quy tắc "Bottom sheets" trong design system
- **Nguồn chính:** `[FROM-CUSTOMER]`, `[DECISION]` D-001, D-005, D-007

---

## 1. Mục đích (Purpose)

Màn này để nhân viên ghi nhận một buổi tập vừa hoàn thành, với số liệu đủ để hệ thống tính điểm và xét huy hiệu. Đây là màn quan trọng nhất của sản phẩm: toàn bộ vòng lặp động lực (tập luyện → nhận điểm → thấy thứ hạng → đổi thưởng) bắt đầu từ đây, nên thao tác phải nhanh và phản hồi phần thưởng phải tức thì.

Người dùng thường mở màn này ngay sau khi tập xong, có thể đang ở phòng gym với tay ướt mồ hôi. Vì vậy màn được thiết kế theo hướng ít trường bắt buộc nhất có thể, các trường phụ chỉ hiện khi thực sự liên quan đến loại hình đã chọn.

## 2. Điều kiện trước và phân quyền (Preconditions / Permissions)

Người dùng phải **đã đăng nhập**. Không yêu cầu vai trò đặc biệt — mọi nhân viên đều log được buổi tập của chính mình.

Không có dữ liệu nền bắt buộc; danh mục bài tập được tải khi người dùng mở `SCR-WO-12`, không chặn việc mở màn này.

**Loại permission gate:** route guard ở mức "đã đăng nhập". Khi phiên hết hạn, hệ thống đóng bottom sheet và điều hướng về `SCR-AUTH-10` — xem §6 nhóm lỗi quyền.

Nhân viên chỉ log được buổi tập cho **chính mình**; không có luồng log hộ người khác. `[DECISION]` D-005

## 3. Thành phần giao diện (UI components)

| Thành phần | Kiểu | Bắt buộc? | Nguồn giá trị / option | Điều kiện enable/disable/hiển thị | Quy tắc nghiệp vụ | Ánh xạ entity | Validation và cách phản hồi (UX) | Ghi chú |
|---|---|---|---|---|---|---|---|---|
| Loại hình tập | `Segmented control` | Có | `static` — Cardio (cardio), Tập tạ (weight_lifting), Yoga (yoga) | Luôn hiển thị, luôn bật | Quyết định hệ số tính điểm và các trường phụ nào hiển thị | `WorkoutLog.workout_type` | Mặc định chọn "Cardio". Không thể bỏ chọn nên không phát sinh lỗi rỗng. Khi đổi loại hình, hệ thống ẩn/hiện trường phụ tương ứng và **giữ nguyên** giá trị thời lượng đã nhập. | Đặt ở đầu màn vì quyết định phần còn lại |
| Thời lượng | `Number input` | Có | Người dùng nhập | Luôn hiển thị, luôn bật | Đơn vị phút, số nguyên. Là cơ sở tính điểm theo D-001 | `WorkoutLog.duration_minutes` | Khi rời ô mà để trống hoặc bằng 0, hiển thị dòng đỏ dưới ô: "Nhập thời lượng buổi tập" và vô hiệu hóa nút Lưu. Khi nhập dưới 10, hiển thị dòng cảnh báo màu `color-warning` dưới ô: "Buổi tập dưới 10 phút sẽ không được tính điểm" — **không** chặn lưu. Khi nhập trên 300, hiển thị dòng cảnh báo: "Thời lượng vượt mức thông thường, điểm sẽ được tính đến mức tối đa". | `[DECISION]` D-007 |
| Bài tập | `Autocomplete` | Không | `API` — danh mục từ `ExerciseCatalog`; mở `SCR-WO-12` khi bấm vào | Chỉ hiển thị khi loại hình là Tập tạ hoặc Yoga | Gắn buổi tập với một bài tập chuẩn để thống kê theo bài tập | `WorkoutLog.exercise_ref` | Không bắt buộc nên không có lỗi rỗng. Khi danh mục tải lỗi, hiển thị dòng dưới ô: "Không tải được danh mục bài tập, bạn vẫn lưu được buổi tập" và cho phép tiếp tục. | Ẩn với Cardio vì không mang ý nghĩa |
| Quãng đường | `Number input` | Không | Người dùng nhập | Chỉ hiển thị khi loại hình là **Cardio** | Đơn vị km, cho phép một chữ số thập phân. Dùng để tính tiến độ thử thách Cardio King | `WorkoutLog.distance_km` | Khi nhập số âm, hiển thị dòng đỏ: "Quãng đường phải lớn hơn 0" và vô hiệu hóa nút Lưu. Để trống là hợp lệ. | `[DECISION]` D-005 — nhập tay, không lấy từ GPS |
| Khối lượng tạ | `Number input` | Không | Người dùng nhập | Chỉ hiển thị khi loại hình là **Tập tạ** | Đơn vị kg. Dùng để xét huy hiệu Powerlifter khi đạt 100 kg | `WorkoutLog.weight_lifted_kg` | Khi nhập số âm, hiển thị dòng đỏ: "Khối lượng phải lớn hơn 0" và vô hiệu hóa nút Lưu. Để trống là hợp lệ. | Ý nghĩa chính xác của mốc 100 kg chưa chốt — `[NEEDS-CONFIRMATION]` |
| Thời điểm tập | `Datetime picker` | Có | Mặc định là thời điểm hiện tại | Luôn hiển thị, luôn bật | Quyết định huy hiệu Night Warrior (từ 18:00) và ngày nào được tính streak | `WorkoutLog.logged_at` | Khi chọn thời điểm ở tương lai, hiển thị dòng đỏ dưới ô: "Không thể ghi nhận buổi tập trong tương lai" và vô hiệu hóa nút Lưu. Khi chọn quá 7 ngày về trước, hiển thị cảnh báo: "Buổi tập quá 7 ngày sẽ không tính vào streak hiện tại". | Ngưỡng 7 ngày là đề xuất của BA — `[NEEDS-CONFIRMATION]` |
| Điểm dự kiến | `Label / Văn bản tĩnh` | — | Tính tại máy khách theo công thức D-001 | Luôn hiển thị, cập nhật realtime khi đổi loại hình hoặc thời lượng | Cho người dùng thấy trước phần thưởng — đây là động lực bấm Lưu | — | Khi thời lượng chưa hợp lệ, hiển thị "—" thay vì số. Khi giá trị tính ra vượt trần, hiển thị số đã áp trần kèm ghi chú nhỏ "đã đạt mức tối đa mỗi buổi". | Chỉ là ước tính; số chính thức do máy chủ trả về |
| Lưu | `Button (hành động chính)` | — | — | Bật khi mọi trường bắt buộc hợp lệ; hiển thị vòng quay khi đang gọi máy chủ | Tạo bản ghi buổi tập và kích hoạt tính điểm | — | Chặn bấm lần hai khi đang gửi. Khi máy chủ lỗi, giữ nguyên dữ liệu đã nhập và hiển thị thông báo — xem §6. | Chiều cao 48 dp theo design system |
| Hủy | `Button (phụ / hủy)` | — | — | Luôn bật | Đóng bottom sheet | — | Khi người dùng đã nhập bất kỳ trường nào, hiển thị hộp thoại xác nhận: "Bỏ buổi tập chưa lưu?" với hai lựa chọn Ở lại / Bỏ. Khi chưa nhập gì, đóng ngay không hỏi. | |

### 3.1 Ràng buộc hiển thị theo loại hình

| Loại hình | Trường phụ hiển thị | Trường phụ ẩn |
|---|---|---|
| Cardio | Quãng đường | Bài tập, Khối lượng tạ |
| Tập tạ | Bài tập, Khối lượng tạ | Quãng đường |
| Yoga | Bài tập | Quãng đường, Khối lượng tạ |

`[AUTO-CONSTRAINT]` Khi người dùng đổi loại hình, giá trị của các trường bị ẩn được **xóa** khỏi dữ liệu gửi đi, nhưng vẫn được giữ trong bộ nhớ tạm của màn. Nếu người dùng quay lại loại hình cũ trong cùng phiên mở sheet, giá trị đã nhập được khôi phục. Lý do: tránh mất công nhập lại khi người dùng chỉ đang thử đổi qua lại.

## 4. Tương tác và luồng nhỏ trên màn (User interactions / flows)

| Mã luồng | Tên luồng | Trigger | Tiền điều kiện | Xử lý hệ thống | Kết quả UI | Điều hướng / side effect | Ghi chú |
|---|---|---|---|---|---|---|---|
| F-01 | Mở màn | Bấm nút hành động trung tâm hoặc nút Log workout | Đã đăng nhập | Khởi tạo form với loại hình Cardio, thời điểm hiện tại | Bottom sheet trượt lên từ đáy, `motion-quick` | Bàn phím số bật sẵn ở ô Thời lượng | Tối ưu cho thao tác nhanh |
| F-02 | Đổi loại hình | Chạm một phân đoạn khác | — | Ẩn/hiện trường phụ, tính lại điểm dự kiến | Trường phụ chuyển đổi bằng cross-fade `motion-quick`; số điểm dự kiến cập nhật | Không gọi máy chủ | Xem §3.1 |
| F-03 | Nhập thời lượng | Gõ vào ô Thời lượng | — | Tính lại điểm dự kiến sau mỗi lần gõ | Số điểm dự kiến đếm lên bằng `motion-instant` | Không gọi máy chủ | Phản hồi tức thì tạo động lực |
| F-04 | Chọn bài tập | Chạm ô Bài tập | Loại hình là Tập tạ hoặc Yoga | Gọi API danh mục bài tập | Mở `SCR-WO-12` dạng bottom sheet chồng lên | Sau khi chọn, quay lại F-01 với ô đã điền | Sheet chồng sheet, không phải modal |
| F-05 | Lưu buổi tập | Bấm Lưu | Mọi trường bắt buộc hợp lệ | Gửi bản ghi lên máy chủ; máy chủ tính điểm chính thức theo D-001, áp trần D-007, cộng vào cả điểm tích lũy và điểm khả dụng, xét huy hiệu, cập nhật tiến độ thử thách và mục tiêu | Nút chuyển sang trạng thái đang tải; khi thành công, sheet đóng và toast điểm thưởng chạy số từ 0 bằng `motion-reward` | Đẩy hoạt động lên `SCR-SC-20`; cập nhật `SCR-HOME-10` | Xem F-06, F-07 |
| F-06 | Đạt huy hiệu mới | Máy chủ trả về có huy hiệu mới trong phản hồi của F-05 | — | — | Sau khi toast điểm kết thúc, hiển thị lớp phủ chúc mừng huy hiệu bằng `motion-celebrate` | Chạm bất kỳ đâu để đóng; có liên kết "Xem huy hiệu" sang `SCR-GM-10` | Nếu đạt nhiều huy hiệu cùng lúc, hiển thị lần lượt tối đa 3, phần còn lại gộp thành một dòng |
| F-07 | Lên cấp | Máy chủ trả về cấp độ mới trong phản hồi của F-05 | — | — | Hiển thị sau lớp phủ huy hiệu (nếu có), dùng `motion-celebrate` | Chạm để đóng | Không bao giờ tụt cấp nên chỉ có chiều tăng — `[DECISION]` D-002 |
| F-08 | Chạm trần điểm | Máy chủ trả về cờ đã áp trần | — | — | Toast điểm hiển thị số đã áp trần kèm câu giải thích lý do | Không có | `[DECISION]` D-007 |
| F-09 | Hủy khi form đã sửa | Bấm Hủy hoặc vuốt sheet xuống | Có ít nhất một trường đã nhập | — | Hộp thoại xác nhận bỏ dữ liệu | Nếu xác nhận, đóng sheet | Bảo vệ dữ liệu đang nhập |

## 5. Trạng thái màn hình (States)

| State | Điều kiện vào | Người dùng thấy gì | Còn thao tác gì được | Cách thoát state | Ghi chú |
|---|---|---|---|---|---|
| `Initial` | Vừa mở sheet | Form với loại hình Cardio, thời điểm hiện tại, điểm dự kiến "—" | Toàn bộ | Nhập liệu | Không có bước tải nào chặn màn |
| `Loading` | Đang gửi buổi tập lên máy chủ | Nút Lưu hiển thị vòng quay, các trường chuyển sang chỉ đọc | Không thao tác được, trừ chờ | Máy chủ phản hồi | Chặn bấm Lưu lần hai |
| `Empty` | N/A | — | — | — | Màn này là form nhập liệu, không có danh sách nên không có trạng thái rỗng. Riêng danh mục bài tập rỗng được xử lý trong `SCR-WO-12`. |
| `Error` | Máy chủ trả về lỗi khi lưu | Toast đỏ ở đáy màn, form giữ nguyên toàn bộ dữ liệu đã nhập | Sửa lại và bấm Lưu lại | Lưu thành công hoặc Hủy | Tuyệt đối không xóa dữ liệu người dùng đã nhập |
| `Timeout` | Máy chủ không phản hồi trong 15 giây | Toast: "Không nhận được phản hồi. Buổi tập của bạn chưa được lưu." kèm nút Thử lại | Bấm Thử lại hoặc sửa rồi Lưu lại | Lưu thành công hoặc Hủy | Dữ liệu đang nhập được giữ nguyên |
| `Concurrent / Race` | Người dùng bấm Lưu hai lần rất nhanh, hoặc mở app trên hai thiết bị | Chỉ một bản ghi được tạo | — | — | Máy khách chặn bấm lần hai; máy chủ cần cơ chế chống trùng theo khóa idempotency — `[NEEDS-CONFIRMATION]` cơ chế cụ thể |
| `Success` | Máy chủ xác nhận đã lưu | Sheet đóng, toast điểm chạy số, có thể kèm lớp phủ huy hiệu/lên cấp | Chạm để đóng lớp phủ | Tự động sau khi hết hoạt ảnh | Đây là khoảnh khắc phần thưởng — không được rút gọn |
| `Session expired` | Máy chủ trả 401 | Toast: "Phiên đăng nhập đã hết hạn" | Không | Tự động điều hướng | Đóng sheet, điều hướng `SCR-AUTH-10` |
| `No permission` | N/A | — | — | — | Mọi nhân viên đã đăng nhập đều log được buổi tập của mình |

## 6. Validation, lỗi và trường hợp ngoại lệ

| Nhóm lỗi | Điều kiện phát sinh | Phản hồi UI mong đợi | Mã message | Vị trí hiển thị | Có nút Retry | Có chặn action | Ghi chú QA |
|---|---|---|---|---|---|---|---|
| Dữ liệu rỗng | N/A cho màn form này | — | — | — | — | — | Không có danh sách trên màn |
| Lỗi nhập liệu | Thời lượng trống hoặc bằng 0 | Dòng đỏ dưới ô, nút Lưu vô hiệu hóa | `MSG-WO-001` | Inline dưới ô Thời lượng | Không | Có | Thử bỏ trống, nhập 0, nhập chữ |
| Lỗi nhập liệu | Quãng đường hoặc khối lượng tạ là số âm | Dòng đỏ dưới ô tương ứng, nút Lưu vô hiệu hóa | `MSG-WO-002` | Inline dưới ô liên quan | Không | Có | Thử số âm, số 0, số thập phân nhiều chữ số |
| Lỗi nhập liệu | Thời điểm tập nằm ở tương lai | Dòng đỏ dưới ô, nút Lưu vô hiệu hóa | `MSG-WO-003` | Inline dưới ô Thời điểm | Không | Có | Thử chọn ngày mai, thử đúng thời điểm hiện tại |
| Cảnh báo nghiệp vụ | Thời lượng dưới 10 phút | Dòng màu `color-warning`, **không** chặn lưu | `MSG-WO-004` | Inline dưới ô Thời lượng | Không | Không | Buổi tập vẫn được lưu nhưng điểm bằng 0 — kiểm tra lịch sử vẫn hiện buổi tập |
| Cảnh báo nghiệp vụ | Điểm buổi tập vượt 300 hoặc tổng ngày vượt 500 | Toast sau khi lưu nêu rõ số điểm thực nhận và lý do | `MSG-WO-005` | Toast ở đáy màn | Không | Không | Thử log 2 buổi dài trong cùng ngày để chạm trần ngày |
| Lỗi nghiệp vụ | Máy chủ từ chối vì trùng bản ghi | Toast: "Buổi tập này đã được ghi nhận" | `MSG-WO-006` | Toast | Không | Có | Bấm Lưu hai lần thật nhanh |
| Lỗi quyền (401) | Phiên hết hạn | Toast rồi điều hướng về đăng nhập | `MSG-AUTH-401` | Toast | Không | Có | Kiểm tra dữ liệu đang nhập có được giữ sau khi đăng nhập lại không — `[NEEDS-CONFIRMATION]` |
| Lỗi quyền (403) | N/A | — | — | — | — | — | Không có hành động nào trên màn cần quyền đặc biệt |
| Không tìm thấy (404) | Bài tập đã chọn bị xóa khỏi danh mục | Toast: "Bài tập không còn tồn tại, vui lòng chọn lại" và xóa giá trị ô Bài tập | `MSG-WO-007` | Toast | Không | Có | Hiếm gặp; xảy ra khi admin xóa bài tập giữa lúc người dùng đang nhập |
| Lỗi mạng / timeout | Mất kết nối hoặc quá 15 giây | Toast kèm nút Thử lại, giữ nguyên dữ liệu | `MSG-SYS-NET` | Toast | **Có** | Có | Bật chế độ máy bay giữa lúc bấm Lưu |
| Thao tác đồng thời | Cùng buổi tập được gửi từ hai thiết bị | Chỉ tạo một bản ghi; thiết bị thứ hai nhận `MSG-WO-006` | `MSG-WO-006` | Toast | Không | Có | `[NEEDS-CONFIRMATION]` cơ chế idempotency phía máy chủ |
| Lỗi hệ thống | Lỗi không lường trước | Toast: "Đã có lỗi xảy ra, vui lòng thử lại" kèm nút Thử lại; giữ nguyên form | `MSG-SYS-500` | Toast | **Có** | Có | Không được đóng sheet khi gặp lỗi |

### 6.1 Đặc tả message

| Mã | Nội dung (VI) | Vị trí | Thời điểm | Hành vi sau message | Phân loại |
|---|---|---|---|---|---|
| `MSG-WO-001` | Nhập thời lượng buổi tập | Inline | Khi rời ô hoặc khi bấm Lưu | Chặn gửi, không gọi API | Validation |
| `MSG-WO-002` | Giá trị phải lớn hơn 0 | Inline | Khi rời ô | Chặn gửi, không gọi API | Validation |
| `MSG-WO-003` | Không thể ghi nhận buổi tập trong tương lai | Inline | Ngay khi chọn | Chặn gửi, không gọi API | Validation |
| `MSG-WO-004` | Buổi tập dưới 10 phút sẽ không được tính điểm | Inline | Khi rời ô | Không chặn, vẫn gọi API khi bấm Lưu | Business |
| `MSG-WO-005` | Đã cộng {điểm} điểm — đã đạt mức tối đa {mỗi buổi / mỗi ngày} | Toast | Sau khi máy chủ phản hồi | Không chặn | Business |
| `MSG-WO-006` | Buổi tập này đã được ghi nhận | Toast | Sau khi máy chủ phản hồi | Đóng sheet, làm mới màn nền | Business |
| `MSG-WO-007` | Bài tập không còn tồn tại, vui lòng chọn lại | Toast | Sau khi máy chủ phản hồi | Xóa giá trị ô Bài tập, giữ sheet mở | Business |
| `MSG-AUTH-401` | Phiên đăng nhập đã hết hạn | Toast | Sau khi máy chủ phản hồi | Đóng sheet, điều hướng đăng nhập | Auth |
| `MSG-SYS-NET` | Không nhận được phản hồi. Buổi tập của bạn chưa được lưu. | Toast | Sau 15 giây hoặc khi mất mạng | Giữ sheet và dữ liệu, có nút Thử lại | System |
| `MSG-SYS-500` | Đã có lỗi xảy ra, vui lòng thử lại | Toast | Sau khi máy chủ phản hồi | Giữ sheet và dữ liệu, có nút Thử lại | System |

Toàn bộ message hướng tới **người dùng cuối là nhân viên phổ thông**, nên dùng ngôn ngữ đời thường, không nhắc mã lỗi kỹ thuật hay tên trường trong cơ sở dữ liệu.

## 7. Mapping dữ liệu vào / ra (Data mapping)

| Nhóm dữ liệu | Thành phần UI | Đọc từ đâu | Ghi ra đâu | Mục đích nghiệp vụ | Ghi chú |
|---|---|---|---|---|---|
| Danh mục bài tập | Ô Bài tập, `SCR-WO-12` | API danh mục `ExerciseCatalog` | — | Chuẩn hóa tên bài tập để thống kê | Tải khi mở `SCR-WO-12`, không chặn màn chính |
| Thông tin buổi tập | Toàn bộ form | Người dùng nhập | Bản ghi `WorkoutLog` | Nguồn phát sinh điểm chính | Bao gồm loại hình, thời lượng, quãng đường, khối lượng tạ, thời điểm |
| Điểm dự kiến | Nhãn Điểm dự kiến | Tính tại máy khách theo D-001 | — | Tạo động lực trước khi bấm Lưu | Chỉ ước tính, số chính thức từ máy chủ |
| Điểm chính thức | Toast phần thưởng | Phản hồi của máy chủ sau khi lưu | `PointsTransaction` (cả điểm tích lũy và điểm khả dụng) | Ghi nhận phần thưởng | `[DECISION]` D-003 |
| Huy hiệu mới | Lớp phủ chúc mừng | Phản hồi của máy chủ | `EmployeeBadge` | Ghi nhận thành tích | Máy chủ xét, máy khách chỉ hiển thị |
| Cấp độ mới | Lớp phủ lên cấp | Phản hồi của máy chủ | `Employee.current_level` | Ghi nhận tiến bộ | Tính từ điểm tích lũy theo D-002 |
| Tiến độ thử thách và mục tiêu | (không hiển thị trên màn này) | — | `ChallengeParticipation`, `Goal.current_progress` | Cập nhật ngầm | Người dùng thấy kết quả ở `SCR-HOME-10` và `SCR-GM-12` |

## 8. Email / Thông báo phát sinh từ màn

**Không phát sinh email.** Việc log buổi tập không gửi thư điện tử cho bất kỳ ai.

**Có cập nhật bảng tin** `SCR-SC-20`: hoạt động của người dùng xuất hiện trên bảng tin công ty ngay sau khi lưu thành công.

**Không gửi thông báo đẩy cho đồng nghiệp.** Việc cập nhật bảng tin diễn ra im lặng. `[DECISION]` D-008 loại trừ nhóm thông báo xã hội khỏi bản phát hành đầu tiên, với lý do: thông báo hoạt động của người khác dễ gây phiền và rủi ro lớn là nhân viên tắt toàn bộ quyền thông báo của ứng dụng, làm mất luôn ba thông báo phần thưởng vốn quan trọng hơn.

**Không gửi thông báo đẩy khi đạt huy hiệu mới hoặc lên cấp** từ màn này. Người dùng đang mở ứng dụng nên đã thấy lớp phủ chúc mừng ở luồng F-06 và F-07; một thông báo đẩy song song sẽ thừa. `[DECISION]` D-008

## 9. Xuất dữ liệu: CSV / PDF / Excel

**Không có chức năng xuất dữ liệu** trên màn này. Việc xuất lịch sử tập luyện, nếu cần, thuộc về `SCR-WO-10`.

## 10. Liên kết use case và chức năng

| Loại | Mã | Tên |
|---|---|---|
| Use case | `UC-WO-01` | Log buổi tập |
| Use case | `UC-WO-03` | Quản lý danh mục bài tập (liên quan qua `SCR-WO-12`) |
| Function | `FN-003` | Log buổi tập |
| Function | `FN-009` | Engine tính điểm (kích hoạt bởi màn này) |
| Function | `FN-011` | Engine xét huy hiệu (kích hoạt bởi màn này) |
| User story | `US-01`, `US-02`, `US-03` | Log cardio, log tạ, chọn bài tập |

## 11. Câu hỏi mở (Open questions)

| # | Câu hỏi | Ảnh hưởng đến màn này |
|---|---|---|
| 1 | Mốc 100 kg của huy hiệu Powerlifter là khối lượng một lần nâng tối đa hay tổng khối lượng buổi tập? | Quyết định nhãn và chú thích của ô Khối lượng tạ |
| 2 | Có giới hạn ghi nhận buổi tập lùi về quá khứ bao nhiêu ngày? Đề xuất 7 ngày. | Quyết định ngưỡng cảnh báo và ràng buộc của ô Thời điểm |
| 3 | Cơ chế chống trùng bản ghi phía máy chủ là gì? | Quyết định cách xử lý trạng thái Concurrent/Race |
| 4 | Sau khi đăng nhập lại do hết phiên, dữ liệu đang nhập có được khôi phục không? | Quyết định có cần lưu nháp cục bộ hay không |

Câu hỏi về thông báo đẩy cho bạn bè trước đây ở mục này đã được chốt bằng `[DECISION]` D-008 — không gửi, xem §8.
