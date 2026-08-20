# Function List (Estimation Input) — HealthStride

> **Trạng thái**: Draft
> **Cập nhật lần cuối**: 2026-08-10
> **Owner**: BA/PM
> **Nguồn chính**: `backlog.md`, `usecase-overview.md`, `screen-flow.md`, `business-entities.md`, `decision-log.md`
> **Mức tin cậy tổng thể**: Cao — toàn bộ blocker ước lượng đã được gỡ sau đợt chốt quyết định D-001 → D-007
> **Phiên bản**: v1.1

**Ký hiệu độ ưu tiên:** Must (bắt buộc cho bản phát hành đầu tiên) / Should (nên có) / Could (có thì tốt)
**Ký hiệu độ phức tạp:** Thấp / Trung bình / Cao

---

## Bảng chức năng

| Function ID | Name | Description | Usecases | Screens | Entities | Priority | Phức tạp | Notes |
|---|---|---|---|---|---|---|---|---|
| FN-001 | Đăng nhập nhân viên | Hai cách: email công ty + mật khẩu, và SSO Google Workspace; cùng email trỏ về một hồ sơ | — | SCR-AUTH-10 | Employee | Must | Cao | `[DECISION]` D-004 — làm cả hai cách nên phức tạp hơn ước lượng ban đầu |
| FN-001b | Nạp danh sách nhân viên hợp lệ (Admin) | HR import danh sách email nhân viên được phép dùng ứng dụng | — | SCR-ADM-14 | Employee | Must | Trung bình | `[DECISION]` D-004 — chức năng mới phát sinh từ quyết định |
| FN-002 | Trang chủ / Dashboard | Hiển thị tổng quan điểm, level, streak, tiến độ mục tiêu, tip ngày, lối vào các module | UC-GM-01, UC-SC-06 | SCR-HOME-10 | Employee, Goal, MotivationContent | Must | Trung bình | Tổng hợp dữ liệu từ nhiều module |
| FN-003 | Log buổi tập | Nhập loại hình, bài tập, thời lượng, quãng đường (cardio), khối lượng tạ; lưu và kích hoạt tính điểm | UC-WO-01 | SCR-WO-11 | WorkoutLog, ExerciseCatalog | Must | Trung bình | DoD: lưu thành công, điểm cộng đúng theo D-001, áp trần D-007, xuất hiện trong lịch sử |
| FN-004 | Danh mục bài tập | Hiển thị và tìm kiếm bài tập chuẩn (Squat, Deadlift, Yoga...) | UC-WO-03 | SCR-WO-12 | ExerciseCatalog | Must | Thấp | DoD: chọn được bài tập gắn vào workout log |
| FN-005 | Lịch sử workout | Danh sách các buổi tập đã log, lọc theo thời gian/loại hình | UC-WO-02 | SCR-WO-10 | WorkoutLog | Must | Thấp | DoD: hiển thị đúng thứ tự, có trạng thái rỗng |
| FN-006 | Thống kê workout | Số liệu tổng hợp: tổng buổi tập, tổng thời lượng, tổng calories theo kỳ | UC-WO-02 | SCR-WO-10, SCR-WO-14 | WorkoutLog | Should | Trung bình | |
| FN-007 | Đặt mục tiêu cá nhân | Thiết lập mục tiêu tuần/tháng và theo dõi tiến độ tự động | UC-WO-04 | SCR-WO-13 | Goal | Must | Trung bình | Mục tiêu giảm cân đọc dữ liệu từ FN-007b |
| FN-007b | Log cân nặng | Nhân viên nhập cân nặng định kỳ | UC-WO-04, UC-WO-05 | SCR-WO-15 | WeightLog | Should | Thấp | `[DECISION]` D-005 — chức năng mới, cần cho mục tiêu giảm cân và biểu đồ weight trend |
| FN-008 | Biểu đồ tiến độ | Vẽ biểu đồ calories burned, weight trend, workout frequency | UC-WO-05 | SCR-WO-14 | WorkoutLog, WeightLog | Should | Cao | Phụ thuộc FN-007b để có dữ liệu cân nặng |
| FN-009 | Engine tính điểm | Tính điểm theo công thức phút × hệ số, áp trần chống gian lận, ghi PointsTransaction cho cả hai loại điểm | UC-GM-01 | (nền tảng) | PointsTransaction, WorkoutLog | Must | Cao | `[DECISION]` D-001, D-003, D-007 — đã đủ rõ để ước lượng |
| FN-010 | Engine tính cấp độ | Xác định level từ `lifetime_points` theo công thức 50 × N², phát sự kiện lên cấp | UC-GM-01 | SCR-GM-11 | Level, Employee | Must | Thấp | `[DECISION]` D-002 — công thức đơn giản, độ phức tạp giảm từ Trung bình xuống Thấp |
| FN-011 | Engine xét huy hiệu | Kiểm tra điều kiện và cấp badge tự động sau mỗi sự kiện liên quan | UC-GM-02 | SCR-GM-10 | Badge, EmployeeBadge | Must | Cao | 7 loại badge, mỗi loại một điều kiện riêng |
| FN-012 | Màn hình huy hiệu | Hiển thị badge đã đạt và chưa đạt kèm điều kiện | UC-GM-02 | SCR-GM-10 | EmployeeBadge, Badge | Must | Thấp | |
| FN-013 | Thử thách tuần | Quản lý chu kỳ thử thách, theo dõi tiến độ (quãng đường nhập tay), ghi nhận hoàn thành | UC-GM-03 | SCR-GM-12 | Challenge, ChallengeParticipation | Should | Trung bình | `[DECISION]` D-005 — bỏ tích hợp GPS nên độ phức tạp giảm từ Cao xuống Trung bình. Vẫn cần job reset tuần (Q-010) |
| FN-014 | Bảng xếp hạng | Tính và hiển thị Top 10 điểm, Top 10 streak theo tuần/tháng, rank cá nhân — dựa trên `lifetime_points`; lọc theo mức hiển thị và tính lại thứ hạng liền mạch ở phía máy chủ | UC-SC-01 | SCR-SC-10 | LeaderboardSnapshot, Employee | Must | Cao | `[DECISION]` D-003, D-009 — logic lọc quyền riêng tư làm tăng độ phức tạp |
| FN-015 | Hệ thống bạn bè | Tìm kiếm, gửi/chấp nhận yêu cầu kết bạn, xem hoạt động bạn bè | UC-SC-02 | SCR-SC-11 | Friendship | Should | Trung bình | Cơ chế chấp thuận hai chiều chưa xác nhận |
| FN-016 | Cheer | Gửi lời cổ vũ trên hoạt động của người khác | UC-SC-03 | SCR-SC-21 | FeedReaction | Should | Thấp | |
| FN-017 | Gym Team | Tạo nhóm 3–5 người, mời thành viên, tính điểm nhóm | UC-SC-04 | SCR-SC-12, SCR-SC-13 | GymTeam, TeamMembership | Should | Cao | **Blocker** — công thức điểm nhóm chưa chốt (Q-009) |
| FN-018 | Activity Feed | Sinh bài đăng tự động từ sự kiện — **chỉ với nhân viên ở mức Công khai**; gỡ bài đăng cũ khi nhân viên chuyển sang mức ẩn | UC-SC-05 | SCR-SC-20 | FeedPost, Employee.privacy_visibility | Must | Cao | `[DECISION]` D-009 |
| FN-019 | Comment & Reaction | Bình luận và thả reaction trên bài đăng | UC-SC-05 | SCR-SC-21 | FeedComment, FeedReaction | Should | Trung bình | |
| FN-020 | Tip & Quote hàng ngày | Hiển thị nội dung động lực thay đổi mỗi ngày | UC-SC-06 | SCR-HOME-10 | MotivationContent | Could | Thấp | Cần nguồn nội dung từ HR |
| FN-021 | Cửa hàng phần thưởng | Hiển thị danh mục quà theo mốc điểm, trạng thái khả dụng | UC-RW-01 | SCR-RW-10 | RewardCatalogItem | Must | Trung bình | |
| FN-022 | Đổi điểm lấy quà | Kiểm tra đủ `available_points`, tạo yêu cầu ở trạng thái Chờ duyệt, trừ điểm khả dụng ngay | UC-RW-02 | SCR-RW-11 | RewardRedemption, PointsTransaction | Must | Trung bình | `[DECISION]` D-003, D-006 — cơ chế đã rõ, độ phức tạp giảm từ Cao xuống Trung bình |
| FN-023 | Lịch sử đổi quà | Danh sách yêu cầu và trạng thái xử lý | UC-RW-03 | SCR-RW-12 | RewardRedemption | Should | Thấp | |
| FN-024 | Quản lý danh mục phần thưởng (Admin) | Thêm/sửa/xóa phần thưởng và số lượng | UC-RW-04 | SCR-ADM-11 | RewardCatalogItem | Should | Trung bình | Phụ thuộc cơ chế phân quyền admin |
| FN-025 | Duyệt yêu cầu đổi thưởng (Admin) | Duyệt/từ chối kèm lý do, hoàn `available_points` khi từ chối, đánh dấu đã giao | UC-RW-05 | SCR-ADM-12 | RewardRedemption | **Must** | Trung bình | `[DECISION]` D-006 — nâng từ Should lên Must vì mọi yêu cầu đều bắt buộc qua HR duyệt |
| FN-026 | Công bố Top 1 tháng (Admin) | Xác định người dẫn đầu tháng và công bố kết quả | UC-RW-06 | SCR-ADM-13 | LeaderboardSnapshot | Should | Trung bình | Quy tắc xử lý đồng điểm chưa chốt |
| FN-027 | Báo cáo tổng hợp (Admin) | Thống kê mức độ tham gia toàn công ty theo kỳ | UC-AD-01 | SCR-ADM-13 | (tổng hợp) | Should | Cao | Nội dung báo cáo cụ thể chưa xác nhận |
| FN-028 | Log dinh dưỡng | Ghi nhận calories tiêu thụ theo ngày | UC-HE-01 | SCR-HE-10 | NutritionLog | Should | Trung bình | Cách nhập chưa xác nhận (danh mục món ăn hay tự do) |
| FN-029 | Log nước uống | Ghi nhận số cốc nước, hiển thị tiến độ 8 cốc/ngày | UC-HE-02 | SCR-HE-11 | WaterLog | **Must** | Thấp | `[DECISION]` D-008 — nâng từ Should lên Must vì FN-031 cần nơi ghi nhận |
| FN-030 | Log giấc ngủ | Ghi nhận thời lượng giấc ngủ theo ngày | UC-HE-03 | SCR-HE-12 | SleepLog | Should | Thấp | |
| FN-031 | Nhắc nhở uống nước | Gửi thông báo theo lịch khi chưa đạt mục tiêu 8 cốc trong ngày | UC-HE-04 | (notification) | WaterLog | **Must** | Trung bình | `[DECISION]` D-008 — nâng từ Could lên Must. Khung giờ cụ thể còn mở (Q-011b) |
| FN-032 | Hồ sơ cá nhân & cài đặt | Xem/sửa thông tin cá nhân, bật/tắt từng nhóm thông báo, **chọn một trong ba mức hiển thị** | — | SCR-PROF-10 | Employee | **Must** | Trung bình | `[DECISION]` D-008, D-009 |
| FN-032b | Thông báo mức hiển thị mặc định | Báo cho nhân viên ở lần đăng nhập đầu tiên rằng mặc định là Công khai, kèm lối tắt sang cài đặt | — | SCR-HOME-10 hoặc SCR-AUTH-10 | Employee | **Must** | Thấp | `[DECISION]` D-009 — nghĩa vụ thông báo khi mặc định là công khai |
| FN-033 | Job định kỳ hệ thống | Reset thử thách/leaderboard theo tuần, cập nhật streak, chốt kỳ tháng, kích hoạt nhắc uống nước | UC-GM-03, UC-SC-01, UC-HE-04 | (nền tảng) | Challenge, LeaderboardSnapshot, Employee, WaterLog | Must | Cao | Cần xác nhận mốc thời gian và múi giờ (Q-010, Q-011b) |
| FN-034 | Dịch vụ thông báo đẩy | Đăng ký thiết bị, gửi và theo dõi bốn loại thông báo theo D-008, tôn trọng cấu hình bật/tắt của nhân viên | UC-RW-02, UC-RW-05, UC-HE-04 | (nền tảng) | Employee, RewardRedemption, WaterLog | **Must** | Cao | `[DECISION]` D-008 — chức năng mới, là hạ tầng bắt buộc cho cả nhóm phần thưởng lẫn nhắc uống nước |

---

## Assumptions impacting estimate

1. Ứng dụng là mobile app (Flutter), phục vụ một công ty duy nhất, không có mô hình đa công ty. `[ASSUMED]`
2. Toàn bộ dữ liệu tập luyện và sức khỏe nhập tay ở bản đầu tiên. `[DECISION]` D-005 — đã chốt, không còn là giả định.
3. Khu vực Admin (FN-001b, FN-024 → FN-027) nằm trong cùng ứng dụng, không phải một cổng web riêng. `[ASSUMED]` — nếu tách cổng riêng, cần cộng thêm khối lượng cho một ứng dụng độc lập.
4. Danh mục bài tập và nội dung tip/quote được khởi tạo sẵn khi phát triển, không cần màn quản trị riêng ở giai đoạn đầu. `[ASSUMED]`
5. Bảng xếp hạng tính toán theo lịch định kỳ (snapshot), không yêu cầu cập nhật realtime tuyệt đối. `[ASSUMED]` — nếu yêu cầu realtime, FN-014 tăng độ phức tạp.

## Open questions impacting estimate

Toàn bộ câu hỏi mức ảnh hưởng **Cao** đã được giải quyết (xem `decision-log.md`). Các câu hỏi còn lại không chặn ước lượng:

| # | Câu hỏi | Chức năng bị ảnh hưởng | Mức ảnh hưởng |
|---|---|---|---|
| Q-009 | Công thức tính điểm Gym Team | FN-017 | Trung bình |
| Q-010 | Mốc reset thử thách/leaderboard và múi giờ | FN-013, FN-014, FN-033 | Trung bình |
| Q-016 | Cách nhập calories (tự do hay danh mục món ăn) | FN-028 | Trung bình |
| Q-011b | Khung giờ và tần suất nhắc uống nước | FN-031, FN-033 | Thấp |
| Q-008b | Công bố tên người ẩn danh khi trao thưởng Top 1 | FN-026 | Thấp |
| Q-015 | Điều kiện badge "Consistent" | FN-011 | Thấp |
| Q-013 | Quyền lợi mở khóa khi lên cấp | FN-010, FN-012 | Thấp |

---

## Phạm vi bản phát hành đầu tiên (MVP)

Đề xuất MVP gồm **23 chức năng `Must`** — đủ để vận hành trọn vẹn vòng lặp động lực cốt lõi: *tập luyện → nhận điểm → thấy thứ hạng → đổi thưởng*, cộng thêm nhánh nhắc uống nước theo D-008 và cơ chế quyền riêng tư theo D-009.

### Trong phạm vi MVP

| Nhóm | Function |
|---|---|
| Nền tảng | FN-001 Đăng nhập (mật khẩu + SSO), FN-001b Nạp danh sách nhân viên, FN-002 Dashboard, FN-032 Hồ sơ & cài đặt, FN-032b Thông báo mức hiển thị mặc định, FN-033 Job định kỳ, FN-034 Dịch vụ thông báo đẩy |
| Workout | FN-003 Log buổi tập, FN-004 Danh mục bài tập, FN-005 Lịch sử workout, FN-007 Đặt mục tiêu |
| Gamification | FN-009 Engine tính điểm, FN-010 Engine tính cấp độ, FN-011 Engine xét huy hiệu, FN-012 Màn huy hiệu |
| Social | FN-014 Bảng xếp hạng, FN-018 Activity Feed |
| Reward | FN-021 Cửa hàng phần thưởng, FN-022 Đổi điểm lấy quà, FN-023 Lịch sử đổi quà, FN-025 Duyệt yêu cầu (Admin) |
| Health | FN-029 Log nước uống, FN-031 Nhắc nhở uống nước |

**FN-023 được kéo vào MVP** như một hệ quả kỹ thuật của D-008: thông báo duyệt hoặc từ chối cần có một màn để dẫn người dùng tới khi họ chạm vào thông báo.

### Hoãn sang giai đoạn 2

| Nhóm | Function | Lý do hoãn |
|---|---|---|
| Workout | FN-006 Thống kê, FN-007b Log cân nặng, FN-008 Biểu đồ tiến độ | Giá trị bổ trợ, không chặn vòng lặp cốt lõi |
| Gamification | FN-013 Thử thách tuần | Cần chốt Q-010 (mốc reset) |
| Social | FN-015 Bạn bè, FN-016 Cheer, FN-017 Gym Team, FN-019 Comment/Reaction, FN-020 Tip & Quote | FN-017 cần chốt Q-009; nhóm còn lại là lớp tương tác nâng cao |
| Reward | FN-024 Quản lý danh mục, FN-026 Top 1 tháng, FN-027 Báo cáo | Giai đoạn đầu HR có thể quản lý danh mục trực tiếp trong cơ sở dữ liệu |
| Health | FN-028 Log dinh dưỡng, FN-030 Log giấc ngủ | Không gắn với thông báo nào trong D-008 |

**Lưu ý về FN-024:** nếu HR muốn tự thêm/sửa phần thưởng ngay từ đầu mà không cần đội kỹ thuật can thiệp, nên kéo FN-024 vào MVP — đây là chức năng đáng cân nhắc nhất trong nhóm hoãn.

### Tác động của D-008 lên khối lượng công việc

Quyết định về chính sách thông báo làm MVP tăng từ 17 lên 22 chức năng. Cụ thể:

| Thay đổi | Chức năng | Lý do |
|---|---|---|
| Thêm mới | FN-034 Dịch vụ thông báo đẩy (độ phức tạp **Cao**) | Hạ tầng bắt buộc: đăng ký thiết bị, gửi theo sự kiện và theo lịch, tôn trọng cấu hình tắt/bật |
| Nâng lên Must | FN-029 Log nước uống | Nhắc uống nước cần nơi ghi nhận |
| Nâng lên Must | FN-031 Nhắc nhở uống nước | Được chọn vào chính sách thông báo |
| Nâng lên Must | FN-032 Hồ sơ & cài đặt | Cần nơi để nhân viên tắt từng nhóm thông báo |
| Kéo vào MVP | FN-023 Lịch sử đổi quà | Đích đến khi nhân viên chạm vào thông báo duyệt/từ chối |

FN-034 là hạng mục đáng chú ý nhất: đây là công việc hạ tầng có độ phức tạp cao, cần cấu hình riêng cho cả iOS lẫn Android, và nên được bắt đầu sớm trong lịch triển khai vì bốn chức năng khác phụ thuộc vào nó.

### Tác động của D-009 lên khối lượng công việc

| Thay đổi | Chức năng | Lý do |
|---|---|---|
| Thêm mới | FN-032b Thông báo mức hiển thị mặc định | Nghĩa vụ báo cho nhân viên khi mặc định là Công khai |
| Tăng độ phức tạp | FN-014 Bảng xếp hạng | Phải lọc theo mức hiển thị **ở phía máy chủ** và tính lại thứ hạng liền mạch sau khi loại người ở mức Riêng tư |
| Tăng độ phức tạp | FN-018 Activity Feed | Chỉ sinh bài đăng với người ở mức Công khai; phải gỡ bài đăng cũ khi nhân viên đổi mức |
| Mở rộng phạm vi | FN-032 Hồ sơ & cài đặt | Thêm phần chọn mức hiển thị bên cạnh phần cấu hình thông báo |

**Rủi ro kỹ thuật cần lưu ý khi ước lượng:** logic tính lại thứ hạng liền mạch không phải một phép lọc đơn giản. Máy chủ phải loại bỏ bản ghi của người ở mức Riêng tư **trước khi** đánh số thứ hạng, đồng thời vẫn giữ được thứ hạng thật của chính người đó để trả về cho hàng ghim. Điều này khiến bảng xếp hạng cần hai cách tính song song, và cần được nêu rõ với đội phát triển ngay từ đầu.

---

## Tóm tắt phân bổ

| Module | Function | Must | Should | Could |
|---|---|---|---|---|
| Nền tảng & Auth | FN-001, FN-001b, FN-002, FN-032, FN-032b, FN-033, FN-034 | 7 | 0 | 0 |
| Workout Tracking | FN-003 → FN-008 (gồm FN-007b) | 4 | 3 | 0 |
| Gamification | FN-009 → FN-013 | 4 | 1 | 0 |
| Social & Community | FN-014 → FN-020 | 2 | 4 | 1 |
| Reward System | FN-021 → FN-027 | 4 | 3 | 0 |
| Health Tracking | FN-028 → FN-031 | 2 | 2 | 0 |
| **Tổng** | **37 function** | **23** | **13** | **1** |
