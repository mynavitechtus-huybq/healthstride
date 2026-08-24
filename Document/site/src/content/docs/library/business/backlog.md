---
title: 'HealthStride: backlog'
description: 'Tài liệu nghiệp vụ, kế hoạch và kiến trúc của HealthStride.'
---
# Backlog — Epic / Feature / User Story — HealthStride

> **Trạng thái**: Draft
> **Cập nhật lần cuối**: 2026-08-10
> **Owner**: BA/PM
> **Nguồn chính**: `business-understanding.md`, `usecase-overview.md`, `business-entities.md`, `screen-flow.md`, `decision-log.md`
> **Mức tin cậy tổng thể**: Cao — acceptance criteria của các story cốt lõi đã được chốt bằng quyết định D-001 → D-007
> **Phiên bản**: v1.1
> **Phạm vi MVP**: xem `function-list.md` § Phạm vi bản phát hành đầu tiên

---

## 1. Epics

### EP-01 Workout Tracking

- **Goal:** Cho phép nhân viên ghi nhận và theo dõi hoạt động tập luyện hàng ngày, đặt mục tiêu và xem tiến độ.
- **In scope:** Log workout, quản lý danh mục bài tập, lịch sử & thống kê, đặt mục tiêu cá nhân, biểu đồ tiến độ.
- **Out of scope:** Đồng bộ tự động từ thiết bị đeo (xem `business-understanding.md` §11).
- **Related usecases:** UC-WO-01 → UC-WO-05
- **Related screens:** SCR-WO-10 → SCR-WO-14
- **Acceptance outline:** Nhân viên log được ít nhất 3 loại hình tập (cardio, weight lifting, yoga), điểm được tính tự động, mục tiêu cá nhân theo dõi được tiến độ.

### EP-02 Gamification & Motivation

- **Goal:** Tạo động lực duy trì thói quen tập luyện qua điểm số, huy hiệu, cấp độ và thử thách tuần.
- **In scope:** Points system, badges, levels, weekly challenges.
- **Out of scope:** Cấu hình động quy tắc điểm/badge bởi Admin (chờ xác nhận Q-mở trong BU §3).
- **Related usecases:** UC-GM-01 → UC-GM-03
- **Related screens:** SCR-GM-10 → SCR-GM-12, SCR-HOME-10
- **Acceptance outline:** Điểm/level cập nhật đúng ngay sau khi log workout; badge được cấp tự động khi đủ điều kiện; thử thách tuần theo dõi được tiến độ.

### EP-03 Social & Community

- **Goal:** Xây dựng kết nối cộng đồng nội bộ để tăng động lực qua tương tác xã hội.
- **In scope:** Leaderboard, friend system, gym team, activity feed, tip/quote hàng ngày.
- **Out of scope:** Nhắn tin trực tiếp (chat 1-1) — không có trong mô tả gốc.
- **Related usecases:** UC-SC-01 → UC-SC-06
- **Related screens:** SCR-SC-10 → SCR-SC-21
- **Acceptance outline:** Nhân viên xem được rank cá nhân vs công ty, kết bạn và cheer được, tạo/tham gia gym team 3–5 người, feed hiển thị hoạt động thời gian thực.

### EP-04 Reward System

- **Goal:** Kích thích tham gia bằng cách cho phép đổi điểm tích lũy lấy phần thưởng thực tế.
- **In scope:** Xem danh mục quà, đổi thưởng, lịch sử đổi thưởng, quản lý danh mục và duyệt yêu cầu (Admin), công bố Top 1 tháng.
- **Out of scope:** Logistics giao quà vật lý ngoài app (xem `business-understanding.md` §11).
- **Related usecases:** UC-RW-01 → UC-RW-06
- **Related screens:** SCR-RW-10 → SCR-RW-12, SCR-ADM-11 → SCR-ADM-13
- **Acceptance outline:** Nhân viên đổi được quà khi đủ điểm; Admin duyệt/từ chối được yêu cầu; Top 1 tháng được xác định và công bố.

### EP-05 Nutrition & Health Tracking

- **Goal:** Hỗ trợ nhân viên theo dõi các chỉ số sức khỏe cơ bản song song với vận động.
- **In scope:** Log calories, log nước uống, log giấc ngủ, nhắc nhở uống nước định kỳ.
- **Out of scope:** Tư vấn dinh dưỡng cá nhân hóa, tích hợp thiết bị đo sức khỏe tự động.
- **Related usecases:** UC-HE-01 → UC-HE-04
- **Related screens:** SCR-HE-10 → SCR-HE-12
- **Acceptance outline:** Nhân viên log được calories/nước/giấc ngủ theo ngày; nhận được nhắc nhở uống nước.

---

## 2. Features

### EP-01 Workout Tracking

#### FE-01 Log & quản lý buổi tập
- Epic: EP-01
- Description: Nhập và lưu một buổi tập với loại hình, bài tập cụ thể, thời lượng.
- Related usecases/screens: UC-WO-01, UC-WO-03 / SCR-WO-11, SCR-WO-12

#### FE-02 Lịch sử & thống kê
- Epic: EP-01
- Description: Xem lại các buổi tập đã log, lọc theo khoảng thời gian.
- Related usecases/screens: UC-WO-02 / SCR-WO-10

#### FE-03 Mục tiêu cá nhân & biểu đồ tiến độ
- Epic: EP-01
- Description: Thiết lập mục tiêu tuần/tháng và trực quan hóa tiến độ.
- Related usecases/screens: UC-WO-04, UC-WO-05 / SCR-WO-13, SCR-WO-14

### EP-02 Gamification & Motivation

#### FE-04 Points & Level
- Epic: EP-02
- Description: Tính điểm tự động từ hoạt động, cập nhật cấp độ.
- Related usecases/screens: UC-GM-01 / SCR-HOME-10, SCR-GM-11

#### FE-05 Badges & Achievements
- Epic: EP-02
- Description: Xét và cấp huy hiệu tự động theo điều kiện.
- Related usecases/screens: UC-GM-02 / SCR-GM-10

#### FE-06 Weekly Challenges
- Epic: EP-02
- Description: Theo dõi và hoàn thành thử thách theo tuần.
- Related usecases/screens: UC-GM-03 / SCR-GM-12

### EP-03 Social & Community

#### FE-07 Leaderboard
- Epic: EP-03
- Description: Bảng xếp hạng điểm/streak theo tuần/tháng.
- Related usecases/screens: UC-SC-01 / SCR-SC-10

#### FE-08 Friend & Cheer
- Epic: EP-03
- Description: Kết bạn, xem hoạt động bạn bè, cổ vũ.
- Related usecases/screens: UC-SC-02, UC-SC-03 / SCR-SC-11, SCR-SC-21

#### FE-09 Gym Team
- Epic: EP-03
- Description: Tạo và tham gia nhóm 3–5 người cạnh tranh cùng nhau.
- Related usecases/screens: UC-SC-04 / SCR-SC-12, SCR-SC-13

#### FE-10 Activity Feed
- Epic: EP-03
- Description: Bảng tin hoạt động toàn công ty với comment/reaction, tip/quote hàng ngày.
- Related usecases/screens: UC-SC-05, UC-SC-06 / SCR-SC-20, SCR-HOME-10

### EP-04 Reward System

#### FE-11 Reward Store (phía nhân viên)
- Epic: EP-04
- Description: Xem danh mục, đổi điểm lấy quà, xem lịch sử đổi thưởng.
- Related usecases/screens: UC-RW-01, UC-RW-02, UC-RW-03 / SCR-RW-10, SCR-RW-11, SCR-RW-12

#### FE-12 Quản trị phần thưởng (phía Admin)
- Epic: EP-04
- Description: Quản lý danh mục, duyệt yêu cầu đổi thưởng, công bố Top 1 tháng.
- Related usecases/screens: UC-RW-04, UC-RW-05, UC-RW-06 / SCR-ADM-11, SCR-ADM-12, SCR-ADM-13

### EP-05 Nutrition & Health Tracking

#### FE-13 Nutrition & Water Log
- Epic: EP-05
- Description: Ghi nhận calories tiêu thụ và số cốc nước uống trong ngày.
- Related usecases/screens: UC-HE-01, UC-HE-02 / SCR-HE-10, SCR-HE-11

#### FE-14 Sleep Log & Nhắc nhở
- Epic: EP-05
- Description: Ghi nhận giấc ngủ, gửi nhắc nhở uống nước định kỳ.
- Related usecases/screens: UC-HE-03, UC-HE-04 / SCR-HE-12

---

## 3. User stories

### FE-00 Đăng nhập & quản lý tài khoản

#### US-24 Nhân viên đăng nhập bằng email công ty hoặc Google Workspace
As a nhân viên, I want đăng nhập bằng email công ty với mật khẩu riêng hoặc bằng tài khoản Google Workspace, so that tôi vào được ứng dụng theo cách thuận tiện nhất với mình.
- **Acceptance criteria:**
  - Màn đăng nhập cung cấp đồng thời hai lựa chọn: nhập email + mật khẩu, và nút đăng nhập bằng Google.
  - Chỉ email nằm trong danh sách nhân viên hợp lệ do HR nạp mới đăng nhập được.
  - Hai cách đăng nhập với cùng một địa chỉ email luôn trỏ về cùng một hồ sơ nhân viên.
- **Notes/edge cases:** Cách xử lý khi nhân viên đã tạo mật khẩu riêng rồi chuyển sang dùng SSO (tự động liên kết hay yêu cầu xác thực lại) cần làm rõ ở giai đoạn thiết kế. `[DECISION]` D-004

#### US-25 HR nạp danh sách nhân viên hợp lệ
As an Admin/HR, I want nạp danh sách email nhân viên được phép sử dụng ứng dụng, so that chỉ người trong công ty mới truy cập được hệ thống.
- **Acceptance criteria:**
  - Nhập danh sách nhân viên theo lô (import tệp) hoặc thêm từng người.
  - Vô hiệu hóa được tài khoản khi nhân viên nghỉ việc.
- **Notes/edge cases:** Chính sách xử lý dữ liệu của nhân viên đã nghỉ việc chưa chốt `[NEEDS-CONFIRMATION]` (Q-012).

### FE-01 Log & quản lý buổi tập

#### US-01 Nhân viên log một buổi tập cardio
As a nhân viên, I want ghi nhận một buổi tập cardio với thời lượng cụ thể, so that tôi nhận được điểm tương ứng và theo dõi được hoạt động của mình.
- **Acceptance criteria:**
  - Chọn loại hình "Cardio", nhập thời lượng (phút) và quãng đường (km, tùy chọn).
  - Sau khi lưu, hệ thống tính điểm theo công thức `làm tròn(số phút × 3.33)` — 30 phút cho đúng 100 điểm.
  - Điểm được cộng vào **cả** điểm tích lũy trọn đời và điểm khả dụng.
  - Buổi tập xuất hiện trong lịch sử workout (SCR-WO-10).
- **Notes/edge cases:**
  - Buổi tập dưới 10 phút được lưu nhưng không cộng điểm.
  - Buổi tập vượt 300 điểm chỉ được cộng tối đa 300; tổng trong ngày vượt 500 chỉ được cộng đến 500 — kèm thông báo giải thích. `[DECISION]` D-007

#### US-02 Nhân viên log buổi tập weight lifting với khối lượng tạ
As a nhân viên, I want ghi nhận buổi tập tạ kèm khối lượng đã nâng, so that tôi có thể đạt badge Powerlifter khi đủ điều kiện.
- **Acceptance criteria:**
  - Chọn loại hình "Weight lifting", chọn bài tập (Squat/Deadlift), nhập thời lượng và khối lượng tạ (kg).
  - Điểm được tính theo quy tắc weight lifting (VD 45 phút = 150 điểm).
  - Nếu khối lượng đạt ngưỡng 100kg, hệ thống xét cấp badge Powerlifter.
- **Notes/edge cases:** Định nghĩa "100kg" là 1RM hay tổng khối lượng buổi tập chưa rõ `[NEEDS-CONFIRMATION]` (BU §6.2).

#### US-03 Nhân viên chọn bài tập từ danh mục chuẩn
As a nhân viên, I want chọn bài tập cụ thể (Squat, Deadlift, Yoga) từ danh mục có sẵn khi log workout, so that dữ liệu tập luyện của tôi chính xác và có thể thống kê theo bài tập.
- **Acceptance criteria:**
  - Danh mục hiển thị tối thiểu Squat, Deadlift, Yoga.
  - Có thể tìm kiếm/lọc bài tập trong danh mục.
- **Notes/edge cases:** Việc quản lý (thêm/sửa/xóa) danh mục bài tập do ai thực hiện (Admin hay set cứng khi phát triển) chưa xác nhận.

### FE-02 Lịch sử & thống kê

#### US-04 Nhân viên xem lịch sử các buổi tập đã log
As a nhân viên, I want xem lại danh sách các buổi tập đã ghi nhận, so that tôi biết mình đã tập những gì và khi nào.
- **Acceptance criteria:**
  - Danh sách hiển thị theo thứ tự thời gian gần nhất, có thể lọc theo loại hình hoặc khoảng thời gian.
  - Mỗi mục hiển thị loại hình, bài tập, thời lượng, điểm nhận được.
- **Notes/edge cases:** Chưa có buổi tập nào — hiển thị trạng thái rỗng phù hợp.

### FE-03 Mục tiêu cá nhân & biểu đồ tiến độ

#### US-05 Nhân viên đặt mục tiêu tuần
As a nhân viên, I want đặt mục tiêu tập luyện theo tuần (VD 4 lần/tuần), so that tôi có động lực rõ ràng để phấn đấu và nhận điểm bonus khi hoàn thành.
- **Acceptance criteria:**
  - Chọn loại mục tiêu (tần suất/giảm cân/tăng sức mạnh), nhập giá trị mục tiêu và chu kỳ.
  - Tiến độ mục tiêu cập nhật tự động theo hoạt động thực tế trong kỳ.
  - Khi hoàn thành mục tiêu ngày, nhận +50 điểm bonus (tính vào trần 500 điểm/ngày).
- **Notes/edge cases:** Mục tiêu giảm cân đọc dữ liệu từ US-26 (log cân nặng). Mục tiêu "tăng strength" đo bằng khối lượng tạ tối đa ghi nhận trong kỳ. `[ASSUMED]` — cần xác nhận ở giai đoạn thiết kế.

#### US-26 Nhân viên log cân nặng định kỳ
As a nhân viên, I want ghi nhận cân nặng của mình theo thời gian, so that tôi theo dõi được tiến độ mục tiêu giảm cân và xem biểu đồ weight trend.
- **Acceptance criteria:**
  - Nhập cân nặng (kg) kèm ngày ghi nhận.
  - Dữ liệu được dùng làm nguồn cho biểu đồ weight trend (US-06) và tiến độ mục tiêu giảm cân (US-05).
- **Notes/edge cases:** Nhập tay hoàn toàn, không lấy tự động từ cân điện tử hay ứng dụng sức khỏe. `[DECISION]` D-005

#### US-06 Nhân viên xem biểu đồ tiến độ
As a nhân viên, I want xem biểu đồ calories burned, weight trend và tần suất tập theo thời gian, so that tôi đánh giá được hiệu quả tập luyện của mình.
- **Acceptance criteria:**
  - Có tối thiểu 3 loại biểu đồ: calories burned, weight trend, workout frequency.
  - Có thể chọn khoảng thời gian xem (tuần/tháng).
- **Notes/edge cases:** Biểu đồ weight trend lấy dữ liệu từ US-26 (log cân nặng); khi chưa có bản ghi nào cần hiển thị trạng thái rỗng phù hợp.

### FE-04 Points & Level

#### US-07 Hệ thống tự động cập nhật điểm và cấp độ
As a nhân viên, I want điểm và cấp độ của tôi được cập nhật ngay sau khi log hoạt động, so that tôi thấy được kết quả tức thời và có động lực tiếp tục.
- **Acceptance criteria:**
  - Sau khi log workout hoặc hoàn thành mục tiêu, điểm cập nhật ngay trên Home.
  - Home hiển thị rõ **hai** con số: điểm tích lũy (dùng cho cấp độ và xếp hạng) và điểm khả dụng (dùng để đổi quà).
  - Cấp độ tính từ điểm tích lũy theo công thức `điểm cần đạt Level N = 50 × N²`; khi đủ ngưỡng, cấp độ tăng kèm thông báo/hiệu ứng lên cấp.
- **Notes/edge cases:** Cấp độ **không bao giờ tụt** kể cả khi nhân viên đổi quà, vì tính trên điểm tích lũy trọn đời. `[DECISION]` D-002, D-003

### FE-05 Badges & Achievements

#### US-08 Nhân viên nhận badge tự động khi đủ điều kiện
As a nhân viên, I want được cấp huy hiệu tự động khi đạt điều kiện tương ứng, so that tôi cảm thấy được ghi nhận thành tích.
- **Acceptance criteria:**
  - Badge Starter được cấp ngay sau buổi tập đầu tiên.
  - Badge Streak (7/14/30 ngày) được cấp khi đạt đủ số ngày liên tục.
  - Badge Night Warrior được cấp khi log workout có giờ từ 18:00 trở đi.
  - Màn Badges hiển thị cả badge đã đạt và badge chưa đạt kèm điều kiện.
- **Notes/edge cases:** Điều kiện chính xác cho badge Consistent ("không miss 1 tuần") chưa rõ `[NEEDS-CONFIRMATION]` (BU Q — liên quan §6.2).

### FE-06 Weekly Challenges

#### US-09 Nhân viên theo dõi tiến độ thử thách tuần
As a nhân viên, I want xem tiến độ của tôi trong các thử thách tuần đang mở, so that tôi biết cần làm gì để hoàn thành và nhận thưởng.
- **Acceptance criteria:**
  - Danh sách thử thách hiển thị mục tiêu và tiến độ hiện tại (VD Cardio King: đã chạy X/20km).
  - Khi hoàn thành, trạng thái chuyển "Đã hoàn thành" và phần thưởng được ghi nhận.
- **Notes/edge cases:** Mốc reset thử thách tuần và phần thưởng cụ thể khi hoàn thành chưa xác nhận `[NEEDS-CONFIRMATION]` (BU Q-010).

### FE-07 Leaderboard

#### US-10 Nhân viên xem bảng xếp hạng
As a nhân viên, I want xem Top 10 điểm và Top 10 streak, cũng như thứ hạng của bản thân, so that tôi có động lực cạnh tranh lành mạnh với đồng nghiệp.
- **Acceptance criteria:**
  - Có tab chuyển đổi giữa xếp hạng tuần và tháng.
  - Hiển thị rõ vị trí của nhân viên hiện tại kể cả khi ngoài Top 10.
  - Người ở mức Ẩn danh vẫn chiếm thứ hạng nhưng hiển thị nhãn "Ẩn danh"; người ở mức Riêng tư không xuất hiện.
  - Thứ hạng hiển thị cho người khác phải liền mạch, không để lỗ trống sau khi loại người ở mức Riêng tư.
- **Notes/edge cases:** Việc lọc theo mức hiển thị **phải** thực hiện ở phía máy chủ — không được trả tên thật rồi để giao diện tự che. Thứ hạng người dùng thấy cho chính mình có thể khác thứ hạng người khác thấy về họ; đây là chủ đích. `[DECISION]` D-009

#### US-29 Nhân viên chọn mức hiển thị dữ liệu cá nhân
As a nhân viên, I want chọn mức độ hiển thị của mình trên bảng xếp hạng và bảng tin, so that tôi kiểm soát được mức lộ diện của mình trong công ty.
- **Acceptance criteria:**
  - Ba lựa chọn: Công khai (mặc định), Ẩn danh, Riêng tư — kèm mô tả rõ mỗi mức đồng nghiệp sẽ thấy gì.
  - Đổi mức có hiệu lực ngay, không cần đăng xuất.
  - Khi chuyển từ Công khai sang mức ẩn, các bài đăng cũ trên bảng tin được gỡ.
  - Ở mọi mức, nhân viên vẫn tích điểm, lên cấp, nhận huy hiệu và đổi quà bình thường.
  - Ở mọi mức, nhân viên vẫn thấy tên thật và thứ hạng thật của chính mình trên bảng xếp hạng.
- **Notes/edge cases:** Dữ liệu sức khỏe (cân nặng, calories, giấc ngủ) không bao giờ hiển thị công khai ở bất kỳ mức nào — đây là quy tắc cứng, không phải tùy chọn. `[DECISION]` D-009

#### US-30 Nhân viên được báo về mức hiển thị mặc định
As a nhân viên mới, I want được biết rằng mặc định tên tôi hiển thị công khai trên bảng xếp hạng, so that tôi không bất ngờ khi thấy tên mình xuất hiện với toàn công ty.
- **Acceptance criteria:**
  - Ở lần đăng nhập đầu tiên, hệ thống thông báo rõ mức hiển thị mặc định là Công khai.
  - Thông báo có lối tắt sang màn cài đặt để đổi ngay.
  - Thông báo chỉ hiển thị một lần, không lặp lại ở các lần đăng nhập sau.
- **Notes/edge cases:** Hình thức thông báo (hộp thoại một lần hay dải trên trang chủ) do đội thiết kế quyết định. `[DECISION]` D-009

### FE-08 Friend & Cheer

#### US-11 Nhân viên kết bạn và cổ vũ đồng nghiệp
As a nhân viên, I want kết bạn với đồng nghiệp và gửi lời cổ vũ sau buổi tập của họ, so that chúng tôi động viên nhau duy trì thói quen tập luyện.
- **Acceptance criteria:**
  - Tìm kiếm và gửi yêu cầu kết bạn.
  - Gửi "Cheer" trên một hoạt động của bạn bè, số lượt cheer hiển thị trên bài đăng.
- **Notes/edge cases:** Kết bạn có cần chấp thuận hai chiều hay tự động — chưa xác nhận.

### FE-09 Gym Team

#### US-12 Nhân viên tạo Gym Team và cạnh tranh theo nhóm
As a nhân viên, I want tạo hoặc tham gia một Gym Team từ 3–5 người, so that chúng tôi có thể cùng nhau cạnh tranh với các nhóm khác.
- **Acceptance criteria:**
  - Tạo nhóm mới, mời thành viên (tối thiểu 3, tối đa 5).
  - Nhóm có điểm tổng hợp hiển thị trên bảng xếp hạng nhóm.
- **Notes/edge cases:** Công thức tính điểm nhóm (tổng hay trung bình) chưa xác nhận `[NEEDS-CONFIRMATION]` (BU Q-009).

### FE-10 Activity Feed

#### US-13 Nhân viên xem và tương tác với bảng tin hoạt động
As a nhân viên, I want xem hoạt động của đồng nghiệp trên bảng tin công ty và bình luận, so that tôi cảm thấy kết nối với cộng đồng nội bộ.
- **Acceptance criteria:**
  - Feed hiển thị hoạt động dạng "X vừa tập Y", "X đạt Badge Z".
  - Có thể bình luận và reaction trên mỗi mục.
  - **Chỉ** nhân viên ở mức Công khai mới có hoạt động được đăng lên feed.
- **Notes/edge cases:** Khi một nhân viên chuyển sang mức Ẩn danh hoặc Riêng tư, các bài đăng cũ của họ được gỡ khỏi feed. Nhân viên ở mức ẩn không xuất hiện trên feed dưới bất kỳ hình thức nào, kể cả ẩn danh. `[DECISION]` D-009

#### US-14 Nhân viên xem tip và quote hàng ngày
As a nhân viên, I want thấy một tip tập luyện và một câu quote động viên mỗi ngày trên trang chủ, so that tôi có thêm động lực và kiến thức.
- **Acceptance criteria:**
  - Nội dung thay đổi mỗi ngày, không lặp lại liên tiếp trong thời gian ngắn.
- **Notes/edge cases:** Nguồn nội dung (do HR biên soạn hay lấy từ nguồn ngoài) chưa xác nhận.

### FE-11 Reward Store

#### US-15 Nhân viên đổi điểm lấy phần thưởng
As a nhân viên, I want dùng điểm tích lũy để đổi lấy một phần thưởng trong danh mục, so that nỗ lực tập luyện của tôi được đền đáp bằng giá trị thực tế.
- **Acceptance criteria:**
  - Danh mục hiển thị các mốc điểm (100/500/1000/3000) và phần thưởng tương ứng.
  - Nút đổi chỉ khả dụng khi **điểm khả dụng** đủ mức yêu cầu.
  - Sau khi xác nhận, điểm khả dụng bị trừ ngay và yêu cầu chuyển sang trạng thái "Chờ duyệt".
  - Thứ hạng trên bảng xếp hạng và cấp độ **không thay đổi** sau khi đổi quà.
- **Notes/edge cases:** Mọi yêu cầu đều phải qua HR duyệt, không có tự động duyệt. Khi HR từ chối, điểm khả dụng được hoàn lại đầy đủ kèm lý do. `[DECISION]` D-003, D-006. Phần thưởng hết số lượng cần thông báo lỗi rõ ràng `[NEEDS-CONFIRMATION]`.

#### US-16 Nhân viên xem lịch sử đổi thưởng
As a nhân viên, I want xem lại các yêu cầu đổi thưởng đã gửi và trạng thái xử lý, so that tôi biết khi nào nhận được quà.
- **Acceptance criteria:**
  - Danh sách hiển thị trạng thái: Chờ duyệt / Đã duyệt / Đã giao / Từ chối.
  - Khi bị từ chối, hiển thị lý do và số điểm đã được hoàn lại.
  - Là đích đến khi nhân viên chạm vào thông báo duyệt hoặc từ chối.
- **Notes/edge cases:** Được kéo vào bản phát hành đầu tiên như hệ quả của `[DECISION]` D-008.

#### US-27 Nhân viên nhận thông báo về kết quả yêu cầu đổi quà
As a nhân viên, I want được thông báo khi yêu cầu đổi quà của tôi được duyệt hoặc bị từ chối, so that tôi không phải liên tục vào ứng dụng kiểm tra.
- **Acceptance criteria:**
  - Khi nhân sự duyệt, nhân viên nhận thông báo nêu tên phần thưởng và lời nhắc rằng nhân sự sẽ liên hệ.
  - Khi nhân sự từ chối, thông báo **bắt buộc** nêu rõ số điểm đã được hoàn lại và lý do từ chối.
  - Chạm vào thông báo mở màn lịch sử đổi quà.
  - Nhân viên tắt được nhóm thông báo này trong phần cài đặt; khi tắt, trạng thái vẫn cập nhật bình thường trong ứng dụng.
- **Notes/edge cases:** Khi gửi thông báo lỗi, hệ thống thử lại tối đa 3 lần; trạng thái trong ứng dụng vẫn đúng nên nhân viên không mất thông tin. `[DECISION]` D-008

#### US-28 Nhân sự nhận thông báo khi có yêu cầu đổi quà mới
As an Admin/HR, I want được thông báo ngay khi có nhân viên gửi yêu cầu đổi quà, so that tôi xử lý kịp thời và nhân viên không phải chờ lâu.
- **Acceptance criteria:**
  - Mọi tài khoản có vai trò Admin/HR đều nhận thông báo, nêu tên nhân viên và tên phần thưởng.
  - Chạm vào thông báo mở màn duyệt yêu cầu đổi thưởng.
- **Notes/edge cases:** Khi có nhiều yêu cầu trong thời gian ngắn, cân nhắc gộp thông báo để tránh làm phiền — `[NEEDS-CONFIRMATION]` ngưỡng gộp cụ thể. `[DECISION]` D-008

### FE-12 Quản trị phần thưởng

#### US-17 Admin quản lý danh mục phần thưởng
As an Admin/HR, I want thêm, sửa, xóa các phần thưởng trong danh mục, so that tôi có thể cập nhật ưu đãi phù hợp ngân sách theo thời gian.
- **Acceptance criteria:**
  - Thêm phần thưởng mới với tên, điểm yêu cầu, số lượng khả dụng (nếu có).
  - Ẩn/xóa phần thưởng không còn áp dụng.
- **Notes/edge cases:** Cơ chế phân quyền xác định ai là Admin chưa xác nhận `[NEEDS-CONFIRMATION]`.

#### US-18 Admin duyệt yêu cầu đổi thưởng
As an Admin/HR, I want xem và duyệt/từ chối các yêu cầu đổi thưởng đang chờ, so that quá trình phát quà được kiểm soát đúng và có căn cứ.
- **Acceptance criteria:**
  - Danh sách yêu cầu chờ duyệt hiển thị nhân viên, phần thưởng, thời điểm yêu cầu.
  - Có thể duyệt hoặc từ chối kèm lý do (bắt buộc khi từ chối).
  - Sau khi giao quà cho nhân viên, HR đánh dấu trạng thái "Đã giao".
- **Notes/edge cases:** Khi từ chối, hệ thống tự hoàn lại đúng số điểm khả dụng đã trừ; điểm tích lũy không đổi trong mọi trường hợp. Việc giao quà thực tế diễn ra ngoài ứng dụng. `[DECISION]` D-006

#### US-19 Admin công bố Top 1 tháng
As an Admin/HR, I want xác định và công bố nhân viên dẫn đầu bảng xếp hạng tháng, so that phần thưởng đặc biệt (tiền/PTO/quà) được trao đúng người.
- **Acceptance criteria:**
  - Hệ thống xác định Top 1 dựa trên điểm tích lũy trong tháng.
  - Kết quả được công bố (VD trên Activity Feed hoặc thông báo riêng).
- **Notes/edge cases:** Trường hợp đồng điểm ở vị trí Top 1 chưa có quy tắc xử lý `[NEEDS-CONFIRMATION]`.

### FE-13 Nutrition & Water Log

#### US-20 Nhân viên log calories tiêu thụ
As a nhân viên, I want ghi nhận lượng calories đã tiêu thụ trong ngày, so that tôi theo dõi được chế độ dinh dưỡng song song với luyện tập.
- **Acceptance criteria:**
  - Nhập được lượng calories cho một hoặc nhiều bữa trong ngày.
  - Tổng calories trong ngày hiển thị rõ.
- **Notes/edge cases:** Cách nhập (tự do hay chọn từ danh mục món ăn) chưa xác nhận `[NEEDS-CONFIRMATION]` (BU §6.9).

#### US-21 Nhân viên log nước uống
As a nhân viên, I want ghi nhận số cốc nước đã uống trong ngày, so that tôi đạt được mục tiêu 8 cốc/ngày.
- **Acceptance criteria:**
  - Thao tác thêm 1 cốc nhanh (một chạm) từ widget trên Home hoặc màn riêng.
  - Tiến độ hiển thị dạng X/8 cốc.

### FE-14 Sleep Log & Nhắc nhở

#### US-22 Nhân viên log giấc ngủ
As a nhân viên, I want ghi nhận số giờ đã ngủ, so that tôi theo dõi được chất lượng nghỉ ngơi của mình.
- **Acceptance criteria:**
  - Nhập số giờ ngủ cho ngày hôm trước.
- **Notes/edge cases:** Nhập tay hay tự động từ thiết bị đeo chưa xác nhận.

#### US-23 Nhân viên nhận nhắc nhở uống nước định kỳ
As a nhân viên, I want nhận thông báo nhắc uống nước vào các khung giờ trong ngày, so that tôi duy trì thói quen uống đủ nước.
- **Acceptance criteria:**
  - Thông báo được gửi theo lịch định kỳ trong ngày.
  - Thông báo **chỉ gửi khi** nhân viên chưa đạt mục tiêu 8 cốc trong ngày; đã đủ thì bỏ qua lượt nhắc.
  - Nội dung nêu rõ tiến độ hiện tại, ví dụ "Hôm nay bạn mới uống 3/8 cốc".
  - Chạm vào thông báo mở màn log nước uống.
  - Nhân viên tắt được nhóm thông báo này trong phần cài đặt.
- **Notes/edge cases:** Khung giờ và tần suất cụ thể chưa chốt `[NEEDS-CONFIRMATION]` Q-011b — BA đề xuất 10:00, 14:00, 16:00 các ngày làm việc. Chức năng này thuộc bản phát hành đầu tiên theo `[DECISION]` D-008, kéo theo US-21 (log nước uống) cũng vào bản đầu tiên.

---

## Khi nào dừng ở Epic

Nếu cần chốt phạm vi/estimate gấp trước khi có đầy đủ xác nhận từ Product Owner, có thể dừng ở mức Epic + Function List (xem `function-list.md`) và để lại phần User Story chi tiết cho giai đoạn thiết kế (Design phase) sau khi các câu hỏi mở ở `business-understanding.md` §14 được trả lời.
