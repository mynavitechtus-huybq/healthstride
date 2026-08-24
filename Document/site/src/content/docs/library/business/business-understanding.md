---
title: 'Hiểu bài toán nghiệp vụ (Business Understanding)'
description: 'Mục tiêu kinh doanh, actor, business rules và phạm vi của HealthStride.'
---
# Hiểu bài toán nghiệp vụ — HealthStride (Business Understanding)

Đây là tài liệu đầu tiên mình đọc khi mới nhận dự án — lúc chưa biết gì về nghiệp vụ HealthStride cả. Mình dùng nó để hiểu ai dùng app, vì sao họ dùng, và những quy tắc nào đã chốt trước khi động tay vào code.

> **Trạng thái**: Draft
> **Cập nhật lần cuối**: 2026-08-10
> **Owner**: BA/PM
> **Reviewer**: TBD (Product Owner / HR)
> **Scope**: Design Pack (Foundation)
> **Nguồn chính**: Mô tả tính năng do khách hàng cung cấp trực tiếp qua trao đổi (2026-08-10) `[FROM-CUSTOMER]`; các quyết định D-001 → D-007 trong `decision-log.md` `[DECISION]`
> **Mức tin cậy tổng thể**: Cao — 6 câu hỏi chặn ước lượng đã được chốt (xem `decision-log.md`); các điểm còn lại không ảnh hưởng phạm vi lớn.
> **Phiên bản**: v1.1

---

## 1. Tổng quan nghiệp vụ (Business overview)

HealthStride là một ứng dụng di động chăm sóc sức khỏe và thể chất dành cho **nhân viên nội bộ của một công ty** (corporate wellness app). Ứng dụng giúp nhân viên ghi nhận hoạt động tập luyện hàng ngày, tạo động lực duy trì thói quen tập luyện thông qua cơ chế trò chơi hóa (điểm số, huy hiệu, cấp độ, thử thách), kết nối cộng đồng nội bộ (bảng xếp hạng, bạn bè, nhóm tập, bảng tin hoạt động), và khuyến khích tham gia bằng cách cho phép đổi điểm tích lũy lấy phần thưởng thực tế. Song song đó, ứng dụng còn theo dõi các chỉ số sức khỏe cơ bản như dinh dưỡng, nước uống và giấc ngủ.

Người dùng chính là **toàn thể nhân viên công ty**. Bên hưởng lợi thứ hai là **bộ phận HR/quản trị**, đơn vị dùng ứng dụng để theo dõi mức độ tham gia phong trào rèn luyện sức khỏe của nhân viên, quản lý danh mục phần thưởng, và công bố kết quả thi đua hàng tháng. Đây là một dự án **hoàn toàn mới**, chưa có hệ thống tiền nhiệm nội bộ nào tương tự `[ASSUMED]`.

## 2. Mục tiêu kinh doanh & tiêu chí thành công (Business goals & success criteria)

| Mục tiêu | Tiêu chí thành công (đề xuất) | Mức tin cậy |
|---|---|---|
| Tăng tần suất vận động của nhân viên | % nhân viên đạt mục tiêu tập luyện cá nhân hàng tuần | `[NEEDS-CONFIRMATION]` — chưa có con số mục tiêu cụ thể |
| Tạo văn hóa cộng đồng, gắn kết nội bộ qua thể thao | Số lượng tương tác (cheer, comment, gym team) hàng tuần | `[NEEDS-CONFIRMATION]` |
| Duy trì động lực dài hạn qua phần thưởng | Tỷ lệ nhân viên hoạt động liên tục (streak) trên 30 ngày | `[NEEDS-CONFIRMATION]` |
| Cải thiện nhận thức sức khỏe toàn diện | Số lượt log dinh dưỡng/nước/giấc ngủ mỗi tuần | `[NEEDS-CONFIRMATION]` |

## 3. Stakeholder & vai trò nghiệp vụ (Stakeholders & roles)

| Vai trò | Mô tả | Ghi chú |
|---|---|---|
| Nhân viên (Employee) | Người dùng chính — log workout, tham gia gamification, kết nối xã hội, đổi thưởng, theo dõi sức khỏe | |
| Quản trị viên (HR/Admin) | Cấu hình danh mục phần thưởng, duyệt yêu cầu đổi thưởng, theo dõi bảng xếp hạng toàn công ty, công bố Top 1 hàng tháng | `[NEEDS-CONFIRMATION]` — chưa rõ admin có cấu hình được luật điểm/badge hay luật này cố định do đội phát triển set cứng |
| Hệ thống (Scheduler/Notification) | Tác nhân tự động: reset thử thách tuần, gửi nhắc uống nước, tính điểm, xét badge | Không phải actor người dùng nhưng cần mô tả trong luồng |

## 4. Quy trình hiện tại — As-Is (mức tổng quan)

Hiện tại công ty chưa có công cụ tập trung để nhân viên ghi nhận hoạt động thể thao hay nhận động lực từ tổ chức. Việc tập luyện diễn ra rời rạc, không có ghi nhận, không có kênh chia sẻ nội bộ, và không có cơ chế khen thưởng gắn với hoạt động thể chất. `[ASSUMED]` — vì đây là dự án khởi tạo mới, chưa xác nhận công ty có dùng công cụ nào khác (Excel, app bên thứ ba) trước đó.

## 5. Quy trình mong muốn — To-Be (mức tổng quan)

1. Nhân viên đăng nhập vào HealthStride bằng tài khoản công ty.
2. Nhân viên log buổi tập (loại hình, thời lượng, bài tập cụ thể) — hệ thống tự tính điểm theo quy tắc đã định.
3. Hệ thống cập nhật cấp độ, xét badge mới đạt được, cập nhật tiến độ thử thách tuần.
4. Hoạt động được đẩy lên bảng tin công ty; đồng nghiệp có thể xem và cổ vũ (cheer, comment).
5. Bảng xếp hạng tuần/tháng cập nhật theo điểm và theo streak.
6. Nhân viên dùng điểm tích lũy đổi phần thưởng trong cửa hàng quà tặng nội bộ.
7. Song song, nhân viên có thể log lượng calories tiêu thụ, số cốc nước uống, giờ ngủ; hệ thống nhắc uống nước định kỳ trong ngày.

## 6. Quy tắc nghiệp vụ (nhóm theo chủ đề)

### 6.1 Quy tắc tính điểm (Points system) `[DECISION]` D-001, D-007

Điểm của một buổi tập được tính theo công thức tuyến tính:

```
Điểm = làm tròn(số phút tập × hệ số loại hình)
```

| Loại hình | Hệ số (điểm/phút) | Ví dụ kiểm chứng |
|---|---|---|
| Cardio | 3.33 | 30 phút → 100 điểm |
| Weight lifting | 3.33 | 45 phút → 150 điểm |
| Yoga | 2.5 | 60 phút → 150 điểm |

**Điểm bonus:** hoàn thành mục tiêu hàng ngày được cộng thêm **50 điểm**.

**Giới hạn chống gian lận (D-007):**

- Một buổi tập được tính tối đa **300 điểm**.
- Một ngày được tính tối đa **500 điểm**, bao gồm cả điểm bonus.
- Buổi tập dưới **10 phút** không được tính điểm. `[ASSUMED]` — đề xuất của BA nhằm tránh chia nhỏ buổi tập để gom điểm.

Khi vượt trần, phần điểm vượt không được cộng và hệ thống hiển thị thông báo giải thích cho nhân viên.

**Hai loại điểm (D-003):** hệ thống theo dõi riêng biệt điểm tích lũy trọn đời (dùng cho cấp độ và bảng xếp hạng, chỉ tăng) và điểm khả dụng (dùng để đổi thưởng, giảm khi đổi quà). Chi tiết xem §6.8 và `decision-log.md` D-003.

### 6.2 Thành tích & Huy hiệu (Achievements & Badges)

| Badge | Điều kiện đạt |
|---|---|
| Starter | Hoàn thành buổi tập đầu tiên |
| Streak | Tập liên tục 7 / 14 / 30 ngày (ba mốc riêng biệt) |
| Night Warrior | Tập sau 18:00 |
| Powerlifter | Nâng tạ đạt mốc 100kg (một set/một lần nâng) `[NEEDS-CONFIRMATION]` — cần rõ đây là mức tạ tối đa 1 lần nâng (1RM) hay tổng khối lượng buổi tập |
| Consistent | Không bỏ lỡ tuần nào (đạt mục tiêu tối thiểu mỗi tuần trong một khoảng thời gian) `[NEEDS-CONFIRMATION]` — cần định nghĩa "không miss 1 tuần" nghĩa là gì cụ thể |

### 6.3 Levels `[DECISION]` D-002

Từ Level 1 đến Level 50, tính dựa trên **điểm tích lũy trọn đời** (`lifetime_points`) theo công thức lũy tiến bậc hai:

```
Điểm cần để đạt Level N = 50 × N²
```

| Level | Điểm cần | Level | Điểm cần |
|---|---|---|---|
| 1 | 0 | 25 | 31.250 |
| 2 | 200 | 30 | 45.000 |
| 5 | 1.250 | 35 | 61.250 |
| 10 | 5.000 | 40 | 80.000 |
| 15 | 11.250 | 45 | 101.250 |
| 20 | 20.000 | 50 | 125.000 |

Với nhịp độ tập 4 buổi/tuần (khoảng 500 điểm/tuần), nhân viên đạt Level 10 sau khoảng 10 tuần và Level 20 sau khoảng 40 tuần.

Vì cấp độ tính trên điểm tích lũy trọn đời, nhân viên **không bao giờ bị tụt cấp** khi đổi thưởng.

**Chưa xác nhận:** "trạng thái đặc biệt" mở khóa khi lên cấp cụ thể là gì (danh hiệu hiển thị cạnh tên, khung ảnh đại diện, hay quyền lợi thực tế). `[NEEDS-CONFIRMATION]`

### 6.4 Thử thách tuần (Weekly Challenges)

| Challenge | Điều kiện |
|---|---|
| Cardio King | Chạy tổng cộng 20km trong tuần |
| Monday Motivation | Tập luyện vào thứ Hai |
| Weekend Warrior | Tập luyện cả thứ Bảy và Chủ Nhật |

**Cách đo quãng đường (D-005):** nhân viên **nhập tay** quãng đường đã chạy khi log buổi tập cardio. Không tích hợp GPS hay thiết bị đeo ở bản phát hành đầu tiên.

**Chưa xác nhận:** thời điểm reset thử thách tuần (theo tuần dương lịch, bắt đầu thứ Hai hay Chủ Nhật) và phần thưởng cụ thể khi hoàn thành mỗi thử thách (điểm bonus hay badge riêng). `[NEEDS-CONFIRMATION]`

### 6.5 Bảng xếp hạng (Leaderboard)

- Bảng xếp hạng Top 10 theo tổng điểm (tuần/tháng).
- Bảng xếp hạng Top 10 theo streak dài nhất.
- Nhân viên xem được thứ hạng cá nhân so với toàn công ty.

**Quyền riêng tư trên bảng xếp hạng (D-009):** nhân viên chọn được một trong ba mức hiển thị — Công khai (mặc định), Ẩn danh, hoặc Riêng tư. Người ở mức Ẩn danh vẫn chiếm thứ hạng nhưng hiển thị nhãn "Ẩn danh"; người ở mức Riêng tư không xuất hiện với người khác. Ở cả ba mức, nhân viên vẫn thấy thứ hạng thật của chính mình. Chi tiết xem `decision-log.md` D-009.

- **Chưa xác nhận:** có xếp hạng theo phòng ban hoặc nhóm nhỏ hơn toàn công ty không. `[NEEDS-CONFIRMATION]`

### 6.6 Bạn bè & Gym Team (Friend & Gym Team)

- Nhân viên có thể kết bạn và xem hoạt động tập luyện của bạn bè.
- "Cheer" — gửi lời động viên sau mỗi buổi tập của người khác.
- Tạo "Gym Team" gồm 3–5 người, các nhóm cạnh tranh với nhau.
- **Chưa xác nhận:** cách tính điểm/thứ hạng của một Gym Team (tổng điểm thành viên hay trung bình), ai được quyền tạo/giải tán team, giới hạn số team một nhân viên có thể tham gia. `[NEEDS-CONFIRMATION]`

### 6.7 Bảng tin hoạt động (Activity Feed)

- Bảng tin hiển thị hoạt động dạng: "Minh vừa tập Legs 60 phút", "Lan đạt Badge Streaker 🔥".
- Hỗ trợ comment và reaction.
- Mỗi ngày hiển thị một tip tập luyện và một câu quote động viên (ngẫu nhiên).

**Quyền riêng tư trên bảng tin (D-009):** chỉ nhân viên ở mức Công khai mới có hoạt động được đăng lên bảng tin. Nhân viên ở mức Ẩn danh hoặc Riêng tư không xuất hiện trên bảng tin dưới bất kỳ hình thức nào. Khi nhân viên chuyển từ Công khai sang một mức ẩn, các bài đăng cũ của họ được gỡ khỏi bảng tin.

- **Chưa xác nhận:** nguồn nội dung tips và quote — do bộ phận nhân sự biên soạn sẵn hay lấy từ nguồn ngoài. `[NEEDS-CONFIRMATION]`

### 6.8 Hệ thống phần thưởng (Reward System)

| Mốc điểm | Phần thưởng |
|---|---|
| 100 điểm | Voucher cà phê / nước cam |
| 500 điểm | Massage 30 phút |
| 1.000 điểm | Voucher phòng gym ngoài / thực phẩm bổ sung (supplement) |
| 3.000 điểm | Laptop / tai nghe / smartwatch |
| Top 1 tháng | Thưởng tiền / PTO 1 ngày / quà |

**Cơ chế điểm khi đổi thưởng (D-003):** hệ thống theo dõi hai chỉ số riêng biệt cho mỗi nhân viên.

| Chỉ số | Dùng cho | Hành vi |
|---|---|---|
| Điểm tích lũy trọn đời | Cấp độ, bảng xếp hạng, huy hiệu | Chỉ tăng, không bao giờ giảm |
| Điểm khả dụng | Đổi thưởng | Tăng khi tập luyện, giảm khi đổi quà |

Nhờ tách biệt như vậy, nhân viên đổi quà không bị tụt hạng trên bảng xếp hạng và không tụt cấp độ — tránh tâm lý giữ điểm mà không dám đổi.

**Quy trình đổi thưởng (D-006):** nhân viên gửi yêu cầu, điểm khả dụng bị trừ ngay và yêu cầu chuyển sang trạng thái chờ duyệt. Bộ phận HR xem danh sách yêu cầu, duyệt hoặc từ chối. Khi từ chối, điểm khả dụng được hoàn lại đầy đủ kèm lý do. Việc giao quà thực tế do HR thực hiện **bên ngoài ứng dụng** — ứng dụng không xử lý phát hành mã voucher, kho hàng hay vận chuyển.

**Chưa xác nhận:** ngân sách và giới hạn số lượng quà mỗi mốc; cách xác định Top 1 tháng khi có nhiều người đồng điểm. `[NEEDS-CONFIRMATION]`

### 6.9 Dinh dưỡng & Theo dõi sức khỏe (Nutrition & Health Tracking)

- Theo dõi lượng calories tiêu thụ.
- Log nước uống, mục tiêu 8 cốc/ngày.
- Theo dõi giấc ngủ.
- Nhắc nhở uống nước theo chu kỳ định kỳ trong ngày.

**Cách nhập dữ liệu (D-005):** toàn bộ dữ liệu sức khỏe do nhân viên **nhập tay** — calories tiêu thụ, số cốc nước, số giờ ngủ, và cân nặng. Không tích hợp Apple Health hay Google Fit ở bản phát hành đầu tiên.

**Nhắc uống nước (D-008):** đây là **loại thông báo duy nhất** của nhóm sức khỏe có trong bản phát hành đầu tiên. Thông báo chỉ gửi khi nhân viên chưa đạt mục tiêu 8 cốc trong ngày. Vì có nhắc nhở nên chức năng **log nước uống cũng phải có** trong bản đầu tiên — nhắc mà không có nơi ghi nhận thì thông báo trở nên vô nghĩa.

Các chức năng còn lại của nhóm sức khỏe (log calories, log giấc ngủ) vẫn thuộc giai đoạn sau.

**Chưa xác nhận:** cách nhập calories cụ thể (nhập tổng số tự do hay chọn từ danh mục món ăn có sẵn); khung giờ và tần suất nhắc uống nước cụ thể. `[NEEDS-CONFIRMATION]` Q-011b

## 7. Kịch bản nghiệp vụ (Business scenarios)

### 7.1 Luồng thành công (Happy paths)

- Nhân viên mở app, log một buổi tập cardio 30 phút → nhận 100 điểm → đây là buổi tập đầu tiên nên nhận thêm badge "Starter" → hoạt động xuất hiện trên bảng tin, đồng nghiệp cheer.
- Nhân viên hoàn thành mục tiêu tuần (4 lần/tuần) → nhận điểm bonus → cấp độ tăng lên → bảng xếp hạng tuần cập nhật vị trí mới.
- Nhân viên tích lũy đủ 500 điểm → vào cửa hàng quà tặng → đổi voucher massage → trạng thái yêu cầu đổi quà chuyển sang chờ xử lý.

### 7.2 Trường hợp biên / ngoại lệ (Edge cases / exceptions)

- Nhân viên log thời lượng bất thường (ví dụ 500 phút cardio) — đã được xử lý bằng trần điểm 300/buổi và 500/ngày theo D-007; phần vượt trần không được cộng điểm.
- Nhân viên log nhiều buổi tập rất ngắn để gom điểm — đã được xử lý bằng ngưỡng tối thiểu 10 phút mỗi buổi.
- Nhân viên đã tạo tài khoản bằng mật khẩu riêng, sau đó đăng nhập bằng Google Workspace với cùng email — hai cách đăng nhập trỏ về cùng hồ sơ. `[ASSUMED]` — cần xác nhận cách xử lý chi tiết (tự động liên kết hay yêu cầu xác thực lại).
- Nhân viên nghỉ việc hoặc chuyển phòng ban — xử lý dữ liệu leaderboard, gym team, và điểm thưởng còn tồn như thế nào. `[NEEDS-CONFIRMATION]`
- Phần thưởng hết số lượng khi nhân viên cố đổi. `[NEEDS-CONFIRMATION]`
- Hai nhân viên đồng điểm ở vị trí Top 1 cuối tháng. `[NEEDS-CONFIRMATION]`
- Nhân viên không muốn hoạt động cá nhân (cân nặng, calories) hiển thị công khai trên bảng tin/leaderboard. `[NEEDS-CONFIRMATION]`

## 8. Dữ liệu và báo cáo (Data & reporting)

### 8.1. Nhóm dữ liệu nghiệp vụ

| Nhóm dữ liệu | Ý nghĩa nghiệp vụ | Ai tạo ra / ai sử dụng | Mức nhạy cảm | Ràng buộc lưu trữ | Nguồn |
|---|---|---|---|---|---|
| Hồ sơ nhân viên | Thông tin định danh, phòng ban, cấp bậc | HR tạo / toàn hệ thống dùng | Thông tin cá nhân cơ bản | `[NEEDS-CONFIRMATION]` | `[ASSUMED]` |
| Nhật ký tập luyện (Workout log) | Loại bài tập, thời lượng, thời điểm, calories ước tính | Nhân viên tạo / hệ thống, đồng nghiệp xem | Trung bình — gắn với thói quen cá nhân | `[NEEDS-CONFIRMATION]` | `[FROM-CUSTOMER]` |
| Điểm & cấp độ (Points/Level) | Lịch sử giao dịch điểm, cấp độ hiện tại | Hệ thống tạo tự động | Thấp | `[NEEDS-CONFIRMATION]` | `[FROM-CUSTOMER]` |
| Huy hiệu & thử thách (Badge/Challenge) | Trạng thái đạt được, tiến độ | Hệ thống tạo tự động | Thấp | `[NEEDS-CONFIRMATION]` | `[FROM-CUSTOMER]` |
| Dữ liệu xã hội (Friend/Team/Feed) | Quan hệ bạn bè, thành viên nhóm, bài đăng, bình luận | Nhân viên tạo | Trung bình — nội dung công khai nội bộ | `[NEEDS-CONFIRMATION]` | `[FROM-CUSTOMER]` |
| Đổi thưởng (Reward redemption) | Lịch sử đổi quà, trạng thái xử lý | Nhân viên tạo / HR xử lý | Trung bình — liên quan chi phí công ty | `[NEEDS-CONFIRMATION]` | `[FROM-CUSTOMER]` |
| Dữ liệu sức khỏe (Nutrition/Water/Sleep) | Calories, nước uống, giờ ngủ | Nhân viên tạo | **Cao** — thông tin sức khỏe cá nhân | `[NEEDS-CONFIRMATION]` | `[FROM-CUSTOMER]` |

### 8.2. Báo cáo và kết xuất

| Báo cáo / kết xuất | Ai đọc | Tần suất | Nội dung chính | Định dạng mong muốn | Nguồn |
|---|---|---|---|---|---|
| Bảng xếp hạng tuần/tháng | Nhân viên, HR | Tuần/tháng | Top 10 điểm, Top 10 streak, rank cá nhân | In-app | `[FROM-CUSTOMER]` |
| Báo cáo tham gia tổng hợp | HR | `[NEEDS-CONFIRMATION]` | % nhân viên hoạt động, tổng điểm phát ra | `[NEEDS-CONFIRMATION]` | `[NEEDS-CONFIRMATION]` |
| Báo cáo ngân sách phần thưởng | HR | `[NEEDS-CONFIRMATION]` | Số quà đã phát, chi phí quy đổi | `[NEEDS-CONFIRMATION]` | `[NEEDS-CONFIRMATION]` |

**Về chính sách lưu trữ:** dữ liệu sức khỏe cá nhân (calories, giấc ngủ, cân nặng) có mức nhạy cảm cao. Thời hạn lưu trữ, quyền xóa dữ liệu khi nhân viên nghỉ việc, và yêu cầu tuân thủ nội bộ chưa được xác nhận. `[NEEDS-CONFIRMATION]`

## 9. Yêu cầu phi chức năng ở mức nghiệp vụ (Non-functional)

| Nhóm | Kỳ vọng của nghiệp vụ | Vì sao quan trọng | Mã NFR liên quan | Mức tin cậy |
|---|---|---|---|---|
| Bảo mật và phân quyền | Nhân viên chỉ đăng nhập bằng tài khoản công ty. Dữ liệu sức khỏe (cân nặng, calories, giấc ngủ) **không bao giờ** hiển thị công khai, bất kể lựa chọn của người dùng. Dữ liệu trò chơi hóa và hoạt động tập luyện hiển thị theo một trong ba mức do nhân viên tự chọn | Dữ liệu sức khỏe là thông tin nhạy cảm; đồng thời nhân viên cần quyền kiểm soát mức độ lộ diện của mình trong môi trường công ty | `[DECISION]` D-009 | Cao — đã chốt |
| Hiệu năng | Bảng xếp hạng và bảng tin cần cập nhật nhanh, không bị trễ đáng kể sau khi log hoạt động | Trải nghiệm động lực phụ thuộc vào phản hồi tức thời (điểm, badge) | `[NEEDS-CONFIRMATION]` | Thấp |
| Nền tảng sử dụng | Ứng dụng di động (iOS/Android), nhân viên dùng chủ yếu ngoài giờ tập luyện, có thể cả trong và ngoài văn phòng | Ảnh hưởng thiết kế UI và khả năng hoạt động offline khi ở phòng gym/công viên | `[NEEDS-CONFIRMATION]` | Thấp |
| Tính sẵn sàng | Không yêu cầu vận hành liên tục 24/7 nghiêm ngặt nhưng cần ổn định trong giờ sinh hoạt của nhân viên | Gián đoạn ảnh hưởng trải nghiệm nhưng không phải hệ thống nghiệp vụ cốt lõi công ty | `[NEEDS-CONFIRMATION]` | Thấp |
| Tuân thủ | Cần tuân thủ chính sách bảo vệ dữ liệu cá nhân nội bộ và quy định lao động liên quan đến dữ liệu sức khỏe nhân viên | Rủi ro pháp lý nếu xử lý sai dữ liệu sức khỏe | `[NEEDS-CONFIRMATION]` | Thấp |

## 10. Tích hợp và phụ thuộc bên ngoài (Integrations & dependencies)

| Hệ thống / dịch vụ | Bên sở hữu | Chiều dữ liệu | Dữ liệu trao đổi | Thời điểm hoặc tần suất | Khi hệ thống đó lỗi thì nghiệp vụ xử lý thế nào | Mức tin cậy |
|---|---|---|---|---|---|---|
| Google Workspace (SSO) `[DECISION]` D-004 | Công ty | Vào | Danh tính nhân viên khi đăng nhập bằng SSO | Mỗi lần đăng nhập | Nhân viên vẫn đăng nhập được bằng email công ty và mật khẩu do ứng dụng quản lý | Cao — đã chốt |
| Dịch vụ push notification `[DECISION]` D-008 | Nhà cung cấp nền tảng di động | Ra | Bốn loại thông báo theo D-008: yêu cầu đổi quà mới (tới nhân sự), yêu cầu được duyệt, yêu cầu bị từ chối, nhắc uống nước | Khi có sự kiện, và theo lịch với nhắc uống nước | Ứng dụng vẫn dùng được bình thường. Nhân viên phải tự vào màn lịch sử đổi quà để biết kết quả; bộ phận nhân sự phải tự kiểm tra danh sách yêu cầu định kỳ | Cao — đã chốt là bắt buộc có |
| Wearable/health platform (Apple Health, Google Fit...) | — | — | — | — | **Ngoài phạm vi bản phát hành đầu tiên** theo D-005 | Cao — đã chốt là không tích hợp |
| Nhà cung cấp voucher/quà tặng | — | — | — | — | **Ngoài phạm vi** theo D-006 — HR xử lý giao quà thủ công bên ngoài ứng dụng | Cao — đã chốt là không tích hợp |

**Kết luận:** ở bản phát hành đầu tiên, ứng dụng có **hai** phụ thuộc bên ngoài, cả hai đều **bắt buộc**: Google Workspace cho đăng nhập SSO (D-004), và dịch vụ push notification (D-008). Hai phụ thuộc còn lại đã được quyết định đưa ra ngoài phạm vi.

## 11. Ngoài phạm vi (Out of scope)

| Hạng mục | Vì sao nằm ngoài phạm vi | Ai đã xác nhận | Ngày | Có thể đưa vào giai đoạn sau không |
|---|---|---|---|---|
| Đồng bộ tự động từ thiết bị đeo/GPS (Apple Health, Google Fit) | Quyết định nhập tay hoàn toàn ở bản đầu tiên để triển khai nhanh và tránh phụ thuộc quyền truy cập dữ liệu sức khỏe | Product Owner `[DECISION]` D-005 | 2026-08-10 | Có — đề xuất giai đoạn 2 |
| Phát hành mã voucher tự động / tích hợp nhà cung cấp quà tặng | HR duyệt và giao quà thủ công bên ngoài ứng dụng | Product Owner `[DECISION]` D-006 | 2026-08-10 | Có — cân nhắc khi số lượng giao dịch tăng |
| Thanh toán/logistics giao quà vật lý (Laptop, headphone...) | App chỉ quản lý yêu cầu đổi quà, không xử lý vận chuyển/tồn kho | Product Owner `[DECISION]` D-006 | 2026-08-10 | Không |
| Huấn luyện viên trực tuyến 1-1 / tư vấn dinh dưỡng cá nhân hóa | Không có trong mô tả tính năng gốc | Chưa ai xác nhận | — | `[NEEDS-CONFIRMATION]` |
| Bản đồ chi tiết lộ trình chạy bộ (route map) | Quãng đường nhập tay, không cần định vị | Product Owner `[DECISION]` D-005 | 2026-08-10 | Có — gắn với giai đoạn tích hợp thiết bị đeo |
| Chuyển dữ liệu từ hệ thống cũ, đào tạo người dùng, tài liệu hướng dẫn sử dụng | Dự án mới, chưa có hệ thống cũ | `[ASSUMED]` | — | Không áp dụng |

## 12. Khái niệm chính & thuật ngữ (glossary)

| Thuật ngữ | Giải thích |
|---|---|
| Points | Điểm tích lũy từ hoạt động tập luyện, dùng để xếp hạng và đổi thưởng |
| Badge | Huy hiệu ghi nhận thành tích đặc biệt |
| Streak | Số ngày/tuần tập luyện liên tục không gián đoạn |
| Level | Cấp độ của nhân viên, tăng theo tổng điểm tích lũy (1–50) |
| Challenge | Thử thách theo tuần với điều kiện hoàn thành cụ thể |
| Cheer | Hành động động viên đồng nghiệp sau buổi tập |
| Gym Team | Nhóm 3–5 nhân viên cạnh tranh cùng nhau |
| Leaderboard | Bảng xếp hạng điểm/streak |
| Reward Redemption | Việc dùng điểm tích lũy đổi lấy phần thưởng |

## 13. Giả định / Ràng buộc (Assumptions / constraints)

- Công ty có danh sách nhân viên sẵn có; HR nạp danh sách này vào ứng dụng để kiểm soát ai được phép đăng ký. `[DECISION]` D-004
- HealthStride phục vụ một công ty duy nhất (single-tenant), không có mô hình nhiều công ty dùng chung. `[ASSUMED]`
- Toàn bộ dữ liệu tập luyện và sức khỏe do nhân viên nhập tay ở bản phát hành đầu tiên. `[DECISION]` D-005
- Ngân sách và số lượng phần thưởng do HR quản lý; ứng dụng chỉ ghi nhận và theo dõi trạng thái yêu cầu đổi thưởng. `[DECISION]` D-006
- Khu vực quản trị nằm trong cùng ứng dụng di động, không phải một cổng web riêng. `[ASSUMED]`

## 14. Câu hỏi còn mở (Open questions)

### Đã chốt (xem `decision-log.md`)

| # | Câu hỏi | Quyết định |
|---|---|---|
| Q-001 | Công thức tính điểm đầy đủ | D-001 — điểm = số phút × hệ số loại hình |
| Q-002 | Bảng ngưỡng điểm 50 cấp độ | D-002 — điểm cần đạt Level N = 50 × N² |
| Q-003 | Cơ chế chống gian lận khi log workout | D-007 — trần 300 điểm/buổi, 500 điểm/ngày, tối thiểu 10 phút |
| Q-004 | Điểm xếp hạng và điểm đổi thưởng có tách biệt không | D-003 — tách biệt điểm tích lũy trọn đời và điểm khả dụng |
| Q-005 | Ai duyệt và xử lý phần thưởng | D-006 — HR duyệt thủ công, giao quà ngoài ứng dụng |
| Q-006 | Cơ chế xác thực nhân viên | D-004 — hỗ trợ cả tài khoản riêng và SSO Google Workspace |
| Q-007 | Có tích hợp thiết bị đeo không | D-005 — không, nhập tay hoàn toàn ở bản đầu tiên |
| Q-011 (một phần) | Chính sách thông báo của sản phẩm | D-008 — bốn loại thông báo trong bản đầu tiên; loại trừ thông báo xã hội và thông báo huy hiệu |
| Q-008 | Nhân viên có được ẩn dữ liệu cá nhân khỏi bảng xếp hạng và bảng tin không | D-009 — ba mức Công khai / Ẩn danh / Riêng tư, mặc định Công khai; dữ liệu sức khỏe không bao giờ công khai |

### Còn mở

| # | Câu hỏi | Ảnh hưởng | Impact |
|---|---|---|---|
| Q-008b | Khi nhân viên ở mức Ẩn danh hoặc Riêng tư đứng đầu bảng xếp hạng tháng, có công bố tên họ khi trao thưởng không? BA đề xuất hỏi ý kiến riêng trước khi công bố. | Quy trình trao thưởng Top 1 | Ops, Compliance |
| Q-009 | Cách tính điểm/thứ hạng của một Gym Team (tổng hay trung bình), ai được tạo/quản lý team, và mức Ẩn danh/Riêng tư ứng xử thế nào trong phạm vi một nhóm? | Logic tính năng xã hội | Scope |
| Q-010 | Thời điểm reset Weekly Challenge và Leaderboard tuần là khi nào (thứ mấy, múi giờ nào)? | Logic hệ thống, job lịch | Scope |
| Q-011b | Khung giờ và tần suất nhắc uống nước cụ thể là gì? BA đề xuất 10:00, 14:00, 16:00 các ngày làm việc, cho phép nhân viên tự điều chỉnh. | Thiết kế notification và màn cài đặt | UX |
| Q-012 | Chính sách xử lý dữ liệu khi nhân viên nghỉ việc (workout log, điểm, team, feed)? | Tuân thủ, vận hành | Compliance, Ops |
| Q-013 | "Trạng thái đặc biệt" mở khóa khi lên cấp cụ thể là gì? | Thiết kế UI, giá trị động lực của hệ thống cấp độ | UX |
| Q-014 | Quy tắc xử lý khi hai nhân viên đồng điểm ở vị trí Top 1 tháng? | Quy trình trao thưởng | Ops |
| Q-015 | Điều kiện chính xác của badge "Consistent" ("không miss 1 tuần") là gì? | Logic xét badge | Scope |
| Q-016 | Cách nhập calories: nhập tổng số tự do hay chọn từ danh mục món ăn có sẵn? | Khối lượng công việc của FN-028 | Scope, UX |

## 15. Nhật ký Hỏi–Đáp (Q&A log, link)

Đợt hỏi đáp đầu tiên (6 câu hỏi ưu tiên) đã hoàn tất ngày 2026-08-10 — kết quả ghi tại `decision-log.md`.

## 16. Nhật ký quyết định (Decision log, link)

Xem `decision-log.md` — 7 quyết định D-001 đến D-007 đã được chốt ngày 2026-08-10.

---

## Điểm chưa xác nhận (tổng hợp)

| # | Điểm cần chốt | Section | Marker | Impact |
|---|---|---|---|---|
| 1 | Công thức tính điểm Gym Team và cách xử lý mức ẩn trong nhóm (Q-009) | §6.6 | `[NEEDS-CONFIRMATION]` | Scope |
| 2 | Mốc reset thử thách và bảng xếp hạng tuần (Q-010) | §6.4, §6.5 | `[NEEDS-CONFIRMATION]` | Scope |
| 3 | Khung giờ nhắc uống nước (Q-011b) | §6.9 | `[NEEDS-CONFIRMATION]` | UX |
| 4 | Chính sách dữ liệu khi nhân viên nghỉ việc (Q-012) | §7.2, §8 | `[NEEDS-CONFIRMATION]` | Compliance, Ops |
| 5 | Điều kiện badge "Consistent" (Q-015) | §6.2 | `[NEEDS-CONFIRMATION]` | Scope |
| 6 | Công bố tên người ẩn danh khi trao thưởng Top 1 (Q-008b) | §6.5, §6.8 | `[NEEDS-CONFIRMATION]` | Ops |

**Đánh giá:** không còn điểm nào chặn việc ước lượng, chốt phạm vi, hay thiết kế chi tiết các màn thuộc bản phát hành đầu tiên. Các câu hỏi còn lại giải quyết được song song trong giai đoạn thiết kế; Q-009 và Q-010 cần chốt trước khi bắt đầu giai đoạn 2.
