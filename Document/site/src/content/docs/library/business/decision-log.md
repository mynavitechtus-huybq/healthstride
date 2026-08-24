---
title: 'Nhật ký quyết định (Decision Log)'
description: 'Các quyết định đã chốt chính thức, lý do và ảnh hưởng tới phạm vi.'
---
# Nhật ký quyết định — HealthStride (Decision Log)

Đây là nơi mình tra lại mỗi khi tự hỏi "sao hệ thống lại làm thế này". Thay vì hỏi lại từ đầu, mình chỉ cần lật đúng quyết định đã chốt và lý do đứng sau nó.

> **Cập nhật lần cuối**: 2026-08-10
> **Mục đích**: Ghi lại các quyết định đã chốt chính thức, lý do, và ảnh hưởng tới tài liệu/phạm vi.

---

## Bảng quyết định

| ID | Quyết định | Câu hỏi gốc | Lý do | Ảnh hưởng | Người chốt | Ngày |
|---|---|---|---|---|---|---|
| D-001 | Điểm workout tính theo công thức tuyến tính: số phút × hệ số loại hình | Q-001 | Khớp chính xác cả hai ví dụ gốc, dễ giải thích cho nhân viên, dễ mở rộng khi thêm loại hình mới | FN-003, FN-009; BU §6.1 | Product Owner | 2026-08-10 |
| D-002 | Ngưỡng cấp độ theo công thức bậc hai: điểm cần để đạt level N = 50 × N² | Q-002 | Lũy tiến nhẹ — lên cấp nhanh giai đoạn đầu tạo đà, chậm dần về sau giữ giá trị cấp cao | FN-010; BU §6.3 | Product Owner | 2026-08-10 |
| D-003 | Tách biệt hai loại điểm: `lifetime_points` (xếp hạng, cấp độ — chỉ tăng) và `available_points` (đổi thưởng — tăng/giảm) | Q-004 | Đổi quà không làm tụt hạng hay tụt cấp, tránh tâm lý giữ điểm không dám đổi | FN-009, FN-014, FN-022, FN-025; entity Employee, PointsTransaction | Product Owner | 2026-08-10 |
| D-004 | Hỗ trợ đồng thời hai cách đăng nhập: tài khoản riêng của app (email công ty + mật khẩu) và SSO Google Workspace | Q-006 | Tài khoản riêng đảm bảo triển khai được ngay kể cả khi chưa phối hợp xong với đội IT; SSO cho trải nghiệm liền mạch với nhân viên đã dùng Google Workspace | FN-001; SCR-AUTH-10 | Product Owner | 2026-08-10 |
| D-005 | Ở bản phát hành đầu tiên, toàn bộ dữ liệu tập luyện và sức khỏe do nhân viên nhập tay; không tích hợp Apple Health / Google Fit | Q-007 | Triển khai nhanh, không phụ thuộc quyền truy cập dữ liệu sức khỏe của hệ điều hành. Đồng bộ tự động chuyển sang giai đoạn sau | FN-003, FN-008, FN-013, FN-028, FN-030 | Product Owner | 2026-08-10 |
| D-006 | Mọi yêu cầu đổi thưởng đều do HR duyệt thủ công; việc giao quà thực hiện ngoài ứng dụng | Q-005 | Kiểm soát được ngân sách, không cần tích hợp nhà cung cấp voucher ở giai đoạn đầu | FN-022, FN-025; SCR-ADM-12 | Product Owner | 2026-08-10 |
| D-007 | Áp dụng trần điểm chống gian lận: tối đa 300 điểm/buổi tập và 500 điểm/ngày | Q-001 (kèm theo), Q-003 | Hệ quả trực tiếp của công thức tuyến tính — không có trần thì nhập thời lượng lớn sẽ phá vỡ cân bằng điểm | FN-003, FN-009; BU §6.1, §7.2 | Product Owner | 2026-08-10 |
| D-008 | Chính sách thông báo cho bản phát hành đầu tiên gồm bốn loại: báo HR khi có yêu cầu đổi quà mới, báo nhân viên khi yêu cầu được duyệt, báo nhân viên khi yêu cầu bị từ chối, và nhắc uống nước định kỳ | Q-011 và các câu hỏi mở trong 4 screen spec | Quy trình duyệt thủ công theo D-006 chỉ vận hành trơn nếu hai đầu đều được báo; thông báo từ chối quan trọng vì đi kèm hoàn điểm. Loại trừ thông báo xã hội để tránh làm phiền khiến nhân viên tắt toàn bộ thông báo | FN-022, FN-025, FN-029, FN-031, FN-034; SCR-RW-10, SCR-RW-11, SCR-ADM-12 | Product Owner | 2026-08-12 |
| D-009 | Nhân viên chọn được một trong ba mức hiển thị: Công khai, Ẩn danh, Riêng tư. Mặc định là Công khai. Dữ liệu sức khỏe không bao giờ hiển thị công khai ở bất kỳ mức nào | Q-008 | Mức Ẩn danh giữ được động lực thi đua cho người ngại lộ danh tính, thay vì buộc họ rời hẳn cuộc chơi. Mặc định Công khai vì động lực cộng đồng là lý do tồn tại của sản phẩm | FN-014, FN-018, FN-032; SCR-SC-10, SCR-SC-20, SCR-PROF-10 | Product Owner | 2026-08-12 |

---

## Chi tiết quyết định

### D-001 — Công thức tính điểm workout

```
Điểm một buổi tập = làm tròn(số phút × hệ số loại hình)
```

| Loại hình | Hệ số (điểm/phút) | Kiểm chứng với ví dụ gốc |
|---|---|---|
| Cardio | 3.33 | 30 phút × 3.33 = 99.9 → **100 điểm** (khớp mô tả gốc) |
| Weight lifting | 3.33 | 45 phút × 3.33 = 149.85 → **150 điểm** (khớp mô tả gốc) |
| Yoga | 2.5 | 60 phút × 2.5 = **150 điểm** |

**Điểm bonus:** hoàn thành mục tiêu hàng ngày được cộng thêm **50 điểm**.

**Ràng buộc (D-007):** một buổi tập tối đa 300 điểm; một ngày tối đa 500 điểm kể cả điểm bonus. Khi vượt trần, phần vượt không được cộng và hệ thống thông báo cho nhân viên.

**Quy tắc bổ sung:** buổi tập dưới 10 phút không được tính điểm — tránh việc log nhiều buổi rất ngắn để gom điểm. `[ASSUMED]` — đề xuất của BA, có thể điều chỉnh.

### D-002 — Bảng ngưỡng cấp độ

```
Điểm tích lũy (lifetime_points) cần để đạt Level N = 50 × N²
```

| Level | Điểm cần | Level | Điểm cần |
|---|---|---|---|
| 1 | 0 | 25 | 31.250 |
| 2 | 200 | 30 | 45.000 |
| 5 | 1.250 | 35 | 61.250 |
| 10 | 5.000 | 40 | 80.000 |
| 15 | 11.250 | 45 | 101.250 |
| 20 | 20.000 | 50 | 125.000 |

**Ước tính nhịp độ:** nhân viên tập 4 buổi/tuần (khoảng 500 điểm/tuần) sẽ đạt Level 10 sau khoảng 10 tuần, Level 20 sau khoảng 40 tuần.

**Lưu ý:** cấp độ tính trên `lifetime_points`, nên **không bao giờ tụt cấp** khi đổi thưởng (theo D-003).

### D-003 — Cơ chế hai loại điểm

| Chỉ số | Dùng cho | Hành vi |
|---|---|---|
| `lifetime_points` | Cấp độ, bảng xếp hạng, huy hiệu | Chỉ tăng, không bao giờ giảm |
| `available_points` | Đổi thưởng | Tăng khi tập luyện, giảm khi đổi quà thành công |

**Ví dụ:** nhân viên kiếm được tổng 2.000 điểm, đã đổi quà hết 500 điểm → bảng xếp hạng vẫn tính 2.000 điểm, số điểm còn đổi được là 1.500.

**Quy tắc hoàn điểm:** khi HR từ chối một yêu cầu đổi thưởng, `available_points` được hoàn lại đúng số điểm đã trừ; `lifetime_points` không thay đổi trong mọi trường hợp.

### D-004 — Hai cách đăng nhập

Màn `SCR-AUTH-10` cung cấp đồng thời:

1. **Đăng nhập bằng email công ty + mật khẩu** — tài khoản do ứng dụng quản lý. HR nạp danh sách nhân viên hợp lệ; chỉ email nằm trong danh sách mới đăng ký/đăng nhập được.
2. **Đăng nhập bằng Google Workspace (SSO)** — nhân viên dùng tài khoản công ty sẵn có.

Hai cách đăng nhập trỏ về **cùng một hồ sơ nhân viên** nếu trùng địa chỉ email. `[ASSUMED]` — cần xác nhận cách xử lý khi nhân viên đã tạo mật khẩu riêng rồi sau đó dùng SSO.

### D-005 — Nhập tay hoàn toàn ở bản đầu tiên

Ảnh hưởng cụ thể tới các chức năng:

- **FN-003 Log buổi tập** — nhân viên nhập loại hình, thời lượng, khối lượng tạ bằng tay.
- **FN-013 Thử thách tuần** — thử thách "Cardio King 20km" yêu cầu nhân viên nhập quãng đường chạy khi log buổi cardio. Cần bổ sung trường `distance_km` vào entity WorkoutLog.
- **FN-008 Biểu đồ tiến độ** — dữ liệu cân nặng do nhân viên tự nhập định kỳ. Cần bổ sung entity `WeightLog`.
- **FN-028, FN-030** — calories và giấc ngủ nhập tay.

### D-006 — Quy trình đổi thưởng thủ công

```
Nhân viên gửi yêu cầu → available_points bị trừ ngay, trạng thái "Chờ duyệt"
   → HR xem danh sách trên SCR-ADM-12
      → Duyệt   → trạng thái "Đã duyệt" → HR liên hệ giao quà → "Đã giao"
      → Từ chối → hoàn lại available_points → trạng thái "Từ chối" (kèm lý do)
```

Ứng dụng **không** xử lý phát hành mã voucher, kho hàng, hay vận chuyển. HR quản lý các khâu này bên ngoài ứng dụng.

### D-008 — Chính sách thông báo

**Bốn loại thông báo có trong bản phát hành đầu tiên:**

| Mã | Người nhận | Điều kiện kích hoạt | Nội dung | Thời điểm |
|---|---|---|---|---|
| `NOTIF-RW-01` | Toàn bộ tài khoản vai trò Admin/HR | Nhân viên gửi một yêu cầu đổi quà mới | "{Tên nhân viên} vừa yêu cầu đổi {tên phần thưởng}" | Ngay khi yêu cầu được tạo |
| `NOTIF-RW-02` | Nhân viên gửi yêu cầu | HR duyệt yêu cầu | "Yêu cầu đổi {tên phần thưởng} đã được duyệt. Bộ phận nhân sự sẽ liên hệ với bạn." | Ngay khi HR bấm Duyệt |
| `NOTIF-RW-03` | Nhân viên gửi yêu cầu | HR từ chối yêu cầu | "Yêu cầu đổi {tên phần thưởng} không được duyệt. {N} điểm đã được hoàn lại. Lý do: {lý do}" | Ngay khi HR bấm Từ chối |
| `NOTIF-HE-01` | Nhân viên | Đến khung giờ nhắc uống nước và nhân viên chưa đạt mục tiêu 8 cốc trong ngày | "Đã đến giờ uống nước. Hôm nay bạn mới uống {N}/8 cốc." | Theo lịch định kỳ trong ngày |

`NOTIF-RW-03` **bắt buộc** nêu rõ số điểm đã được hoàn lại. Đây là điểm nhạy cảm nhất trong toàn bộ luồng phần thưởng: nhân viên bị từ chối mà không thấy điểm quay lại sẽ khiếu nại trực tiếp lên nhân sự.

**Ba loại thông báo bị loại trừ khỏi bản phát hành đầu tiên:**

| Loại | Lý do loại trừ |
|---|---|
| Báo khi đạt huy hiệu mới hoặc lên cấp | Trong ứng dụng đã có lớp phủ chúc mừng ngay sau khi log buổi tập; thông báo đẩy chỉ có giá trị khi người dùng đang không mở ứng dụng, là trường hợp hiếm với luồng này |
| Báo khi bạn bè hoàn thành buổi tập | Tính năng bạn bè thuộc giai đoạn 2 |
| Báo khi vào hoặc rời Top 10 | Dễ gây phiền, và rủi ro lớn là nhân viên tắt toàn bộ quyền thông báo của ứng dụng — làm mất luôn ba thông báo phần thưởng vốn quan trọng hơn |

**Hệ quả với phạm vi bản phát hành đầu tiên:**

1. Hạ tầng thông báo đẩy trở thành **hạng mục bắt buộc** của bản đầu tiên, không còn là tùy chọn. Bổ sung `FN-034` Dịch vụ thông báo.
2. `FN-029` Log nước uống được **kéo vào** bản đầu tiên. Nhắc uống nước mà không có nơi ghi nhận thì thông báo trở nên vô nghĩa và gây khó chịu.
3. Nhân viên phải có nơi bật/tắt từng nhóm thông báo. Bổ sung phần cấu hình thông báo vào `FN-032` Hồ sơ và cài đặt, đồng thời kéo `FN-032` vào bản đầu tiên.

`[NEEDS-CONFIRMATION]` — Khung giờ và tần suất nhắc uống nước cụ thể vẫn chưa chốt (phần còn lại của Q-011). Đề xuất của BA: ba lần mỗi ngày vào 10:00, 14:00 và 16:00 các ngày làm việc, cho phép nhân viên tự điều chỉnh trong phần cài đặt.

### D-009 — Ba mức hiển thị dữ liệu cá nhân

**Quy tắc cứng, không phụ thuộc lựa chọn của người dùng:** dữ liệu sức khỏe — cân nặng, calories tiêu thụ, giờ ngủ — **không bao giờ** xuất hiện trên bảng xếp hạng, bảng tin, hay hồ sơ mà người khác xem được. Đây là nhóm dữ liệu nhạy cảm cao theo phân loại ở `business-understanding.md` §8.1, không phải một tùy chọn để bật tắt. Ba mức dưới đây chỉ điều chỉnh phạm vi hiển thị của **dữ liệu trò chơi hóa** (điểm, cấp độ, thứ hạng, huy hiệu) và **hoạt động tập luyện**.

| Mức | Bảng xếp hạng | Bảng tin | Hồ sơ khi người khác xem |
|---|---|---|---|
| **Công khai** (mặc định) | Hiện tên và ảnh đại diện | Hoạt động được đăng | Tên, ảnh, cấp độ, huy hiệu, điểm tích lũy |
| **Ẩn danh** | Vẫn chiếm thứ hạng nhưng hiển thị nhãn "Ẩn danh" và ảnh mặc định | Không đăng hoạt động | Không mở được từ bảng xếp hạng |
| **Riêng tư** | Không xuất hiện | Không đăng hoạt động | Không mở được |

Ở cả ba mức, nhân viên vẫn **tích điểm, lên cấp, nhận huy hiệu và đổi quà bình thường**. Việc chọn ẩn không làm giảm quyền lợi.

**Người chọn ẩn vẫn thấy chính mình.** Trên thiết bị của người dùng, hàng ghim ở đáy bảng xếp hạng luôn hiển thị tên thật và thứ hạng thật của họ, kể cả ở mức Riêng tư. Nếu không, họ mất hoàn toàn cảm giác tham gia.

**Cách tính lại thứ hạng khi có người ở mức Riêng tư:** thứ hạng hiển thị cho người khác phải **liền mạch**, không để lỗ trống. Nếu bảng hiển thị hạng 1, 2, rồi nhảy sang 4, người xem sẽ suy ra được có một người đang ẩn ở hạng 3 — điều này làm hỏng chính mục đích của mức Riêng tư. Người ở mức Ẩn danh thì ngược lại: họ vẫn chiếm một dòng nên thứ hạng tự nhiên liền mạch.

Hệ quả: **thứ hạng một người nhìn thấy cho chính mình có thể khác thứ hạng người khác nhìn thấy.** Đây là chủ đích. Hàng ghim của người dùng luôn hiển thị thứ hạng thật trong toàn công ty.

**Mặc định Công khai và nghĩa vụ thông báo.** Vì mặc định là Công khai, ứng dụng **bắt buộc** thông báo rõ điều này cho nhân viên ở lần đăng nhập đầu tiên, kèm lối tắt vào màn cài đặt. Không được để nhân viên phát hiện tên mình đã nằm trên bảng xếp hạng công ty mà chưa từng được báo. `[ASSUMED]` — hình thức thông báo (hộp thoại một lần hay dải thông báo trên trang chủ) do đội thiết kế quyết định.

**Bài đăng cũ khi đổi mức.** Khi nhân viên chuyển từ Công khai sang Ẩn danh hoặc Riêng tư, các bài đăng hoạt động cũ của họ **được gỡ khỏi bảng tin**. `[ASSUMED]` — đề xuất của BA; cách khác là chỉ áp dụng cho hoạt động mới, nhưng như vậy nhân viên vẫn lộ lịch sử cũ và sẽ thắc mắc.

**Bộ phận nhân sự vẫn thấy danh tính thật** trong khu vực quản trị, bất kể mức hiển thị của nhân viên. Lý do vận hành: nhân sự phải biết ai gửi yêu cầu đổi quà để giao quà, và phải xác định được người dẫn đầu tháng để trao thưởng.

`[NEEDS-CONFIRMATION]` — Khi một nhân viên ở mức Ẩn danh hoặc Riêng tư đứng đầu bảng xếp hạng tháng, có công bố tên họ khi trao thưởng Top 1 không? Đề xuất của BA: nhân sự liên hệ riêng và hỏi ý kiến trước khi công bố; nếu người đó từ chối, công bố dưới dạng ẩn danh. Câu hỏi này gắn với Q-014 về quy tắc trao thưởng Top 1.

`[NEEDS-CONFIRMATION]` — Tính năng Gym Team ở giai đoạn 2 cần các thành viên trong nhóm nhìn thấy nhau. Cần quyết định mức Ẩn danh và Riêng tư ứng xử thế nào trong phạm vi một nhóm mà chính người đó đã chủ động tham gia.

---

## Câu hỏi mở còn lại

Sau các đợt chốt, 7 câu hỏi ưu tiên và chính sách thông báo đã được giải quyết. Các câu hỏi còn lại (mức ảnh hưởng thấp hơn, không chặn ước lượng) xem tại `business-understanding.md` §14.
