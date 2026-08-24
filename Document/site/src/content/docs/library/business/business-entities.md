---
title: 'HealthStride: business entities'
description: 'Tài liệu nghiệp vụ, kế hoạch và kiến trúc của HealthStride.'
---
# Business Entities — HealthStride

> **Trạng thái**: Draft
> **Cập nhật lần cuối**: 2026-08-10
> **Owner**: BA/PM
> **Nguồn chính**: `business-understanding.md`, `decision-log.md` (D-001 → D-007)
> **Mức tin cậy tổng thể**: Cao — các quyết định về cơ chế điểm, cấp độ và đổi thưởng đã được chốt
> **Phiên bản**: v1.1

---

## 1. Danh sách thực thể (Entity list)

| Entity | Ý nghĩa nghiệp vụ | Owner nghiệp vụ | Ghi chú |
|---|---|---|---|
| Employee | Tài khoản nhân viên sử dụng ứng dụng | HR | |
| ExerciseCatalog | Danh mục bài tập chuẩn (Squat, Deadlift, Yoga...) | Admin/HR | Có thể do đội phát triển khởi tạo sẵn |
| WorkoutLog | Một buổi tập đã được nhân viên ghi nhận | Nhân viên | Nguồn phát sinh điểm chính |
| WeightLog | Bản ghi cân nặng theo thời điểm | Nhân viên | Bổ sung theo D-005 — phục vụ mục tiêu giảm cân và biểu đồ weight trend |
| Goal | Mục tiêu cá nhân theo tuần/tháng | Nhân viên | |
| PointsTransaction | Một giao dịch tăng/giảm điểm | Hệ thống | Log để truy vết mọi thay đổi điểm |
| Level | Định nghĩa cấp độ và ngưỡng điểm | Admin/HR | Bảng cấu hình, không phải dữ liệu người dùng |
| Badge | Định nghĩa một loại huy hiệu và điều kiện đạt | Admin/HR | Bảng cấu hình |
| EmployeeBadge | Huy hiệu cụ thể một nhân viên đã đạt | Hệ thống | Quan hệ Employee–Badge |
| Challenge | Định nghĩa một thử thách tuần | Admin/HR | Bảng cấu hình theo chu kỳ |
| ChallengeParticipation | Tiến độ của một nhân viên trong một thử thách | Hệ thống | |
| LeaderboardSnapshot | Bảng xếp hạng tại một kỳ (tuần/tháng) | Hệ thống | Có thể tính realtime hoặc snapshot theo lịch — `[NEEDS-CONFIRMATION]` |
| Friendship | Quan hệ bạn bè giữa hai nhân viên | Nhân viên | |
| GymTeam | Nhóm 3–5 nhân viên cạnh tranh cùng nhau | Nhân viên | |
| TeamMembership | Quan hệ Employee–GymTeam | Nhân viên | |
| FeedPost | Một mục hoạt động trên bảng tin | Hệ thống/Nhân viên | Sinh tự động khi có sự kiện (workout, badge) hoặc đăng thủ công `[NEEDS-CONFIRMATION]` |
| FeedComment | Bình luận trên một FeedPost | Nhân viên | |
| FeedReaction | Reaction/cheer trên một FeedPost | Nhân viên | |
| MotivationContent | Tip tập luyện hoặc quote động viên trong ngày | Admin/HR | Nội dung do HR biên soạn hoặc nguồn ngoài |
| RewardCatalogItem | Một phần thưởng khả đổi trong danh mục | Admin/HR | |
| RewardRedemption | Một yêu cầu đổi thưởng của nhân viên | Nhân viên/Admin | |
| NutritionLog | Bản ghi calories tiêu thụ trong ngày | Nhân viên | |
| WaterLog | Bản ghi số cốc nước uống trong ngày | Nhân viên | |
| SleepLog | Bản ghi thời lượng/chất lượng giấc ngủ | Nhân viên | |

---

## 2. Đặc tả từng thực thể — từ điển trường (Field dictionary)

### Employee

| Field | Nhãn hiển thị | Bắt buộc? | Kiểu dữ liệu | Quy tắc trên một trường | Giá trị mặc định | Ai xem/sửa | Ví dụ | Nguồn |
|---|---|---|---|---|---|---|---|---|
| employee_id | Mã nhân viên | Có | Văn bản (định danh) | Duy nhất trong hệ thống | — | Hệ thống tạo, không ai sửa | EMP-0231 | `[ASSUMED]` |
| full_name | Họ tên | Có | Văn bản | — | — | Employee xem, HR sửa | Nguyễn Văn Minh | `[ASSUMED]` |
| department | Phòng ban | Không | Danh mục | — | — | HR sửa | Kỹ thuật | `[NEEDS-CONFIRMATION]` |
| email | Email công ty | Có | Văn bản (định dạng email) | Dùng để đăng nhập, duy nhất trong hệ thống | — | Chỉ HR sửa | minh.nv@company.com | `[DECISION]` D-004 |
| auth_provider | Cách đăng nhập đã dùng | Có | Danh mục (mật khẩu / Google Workspace / cả hai) | Cùng một email luôn trỏ về một hồ sơ duy nhất | Mật khẩu | Chỉ hệ thống cập nhật | Cả hai | `[DECISION]` D-004 |
| lifetime_points | Điểm tích lũy trọn đời | Có | Số nguyên | **Chỉ tăng, không bao giờ giảm.** Dùng cho cấp độ và bảng xếp hạng | 0 | Chỉ hệ thống cập nhật | 2000 | `[DECISION]` D-003 |
| available_points | Điểm khả dụng để đổi thưởng | Có | Số nguyên | Không âm. Tăng khi tập luyện, giảm khi đổi quà | 0 | Chỉ hệ thống cập nhật | 1500 | `[DECISION]` D-003 |
| current_level | Cấp độ hiện tại | Có | Số nguyên (1–50) | Tính từ `lifetime_points` theo công thức 50 × N² | 1 | Chỉ hệ thống cập nhật | 12 | `[DECISION]` D-002 |
| current_streak_days | Số ngày streak hiện tại | Có | Số nguyên | Reset về 0 khi bỏ lỡ điều kiện streak | 0 | Chỉ hệ thống cập nhật | 14 | `[FROM-CUSTOMER]` |
| privacy_visibility | Mức hiển thị dữ liệu cá nhân | Có | Danh mục — Công khai (public), Ẩn danh (anonymous), Riêng tư (private) | Chỉ điều chỉnh dữ liệu trò chơi hóa và hoạt động tập luyện; không áp dụng cho dữ liệu sức khỏe vốn luôn riêng tư | Công khai | Employee tự cấu hình trong `SCR-PROF-10` | Công khai | `[DECISION]` D-009 |

### WorkoutLog

| Field | Nhãn hiển thị | Bắt buộc? | Kiểu dữ liệu | Quy tắc trên một trường | Giá trị mặc định | Ví dụ | Nguồn |
|---|---|---|---|---|---|---|---|
| workout_id | Mã buổi tập | Có | Định danh | Duy nhất | — | WO-99213 | `[ASSUMED]` |
| employee_id | Nhân viên thực hiện | Có | Tham chiếu Employee | — | — | EMP-0231 | `[FROM-CUSTOMER]` |
| workout_type | Loại hình tập | Có | Danh mục (cardio / weight lifting / yoga / khác) | — | — | Cardio | `[FROM-CUSTOMER]` |
| exercise_ref | Bài tập cụ thể | Không | Tham chiếu ExerciseCatalog | Bắt buộc với weight lifting `[NEEDS-CONFIRMATION]` | — | Squat | `[FROM-CUSTOMER]` |
| duration_minutes | Thời lượng (phút) | Có | Số nguyên dương | Tối thiểu 10 phút mới được tính điểm; áp dụng trần điểm 300/buổi | — | 30 | `[DECISION]` D-007 |
| distance_km | Quãng đường (km) | Không | Số thập phân | Chỉ áp dụng cho cardio; nhân viên nhập tay; dùng cho thử thách Cardio King | — | 5.2 | `[DECISION]` D-005 |
| weight_lifted_kg | Khối lượng tạ nâng (kg) | Không | Số thập phân | Chỉ áp dụng cho weight lifting | — | 100 | `[NEEDS-CONFIRMATION]` — cần cho badge Powerlifter |
| logged_at | Thời điểm log | Có | Ngày giờ | Không được ở tương lai | Thời điểm hiện tại | 2026-08-10 19:20 | `[FROM-CUSTOMER]` — dùng xét badge Night Warrior |
| calories_burned | Calories tiêu hao ước tính | Không | Số nguyên | Có thể tự tính theo loại hình + thời lượng | `[NEEDS-CONFIRMATION]` | 280 | `[FROM-CUSTOMER]` |
| points_awarded | Điểm được cộng | Có | Số nguyên | Tính theo công thức D-001, sau khi áp trần D-007 | — | 100 | `[DECISION]` D-001 |
| points_capped | Có bị chạm trần điểm không | Có | Boolean | Đánh dấu để hiển thị thông báo giải thích cho nhân viên | false | false | `[DECISION]` D-007 |

### WeightLog

| Field | Nhãn hiển thị | Bắt buộc? | Kiểu dữ liệu | Quy tắc trên một trường | Ví dụ | Nguồn |
|---|---|---|---|---|---|---|
| employee_id | Nhân viên | Có | Tham chiếu Employee | — | EMP-0231 | `[DECISION]` D-005 |
| weight_kg | Cân nặng (kg) | Có | Số thập phân | Nhân viên nhập tay; giá trị dương trong khoảng hợp lý | 68.5 | `[DECISION]` D-005 |
| recorded_at | Thời điểm ghi nhận | Có | Ngày | Không được ở tương lai | 2026-08-10 | — |

### Goal

| Field | Nhãn hiển thị | Bắt buộc? | Kiểu dữ liệu | Quy tắc trên một trường | Ví dụ | Nguồn |
|---|---|---|---|---|---|---|
| goal_id | Mã mục tiêu | Có | Định danh | Duy nhất | GOAL-102 | `[ASSUMED]` |
| employee_id | Nhân viên | Có | Tham chiếu Employee | — | EMP-0231 | `[FROM-CUSTOMER]` |
| goal_type | Loại mục tiêu | Có | Danh mục (tần suất / giảm cân / tăng sức mạnh) | — | Tần suất | `[FROM-CUSTOMER]` |
| target_value | Giá trị mục tiêu | Có | Số | Ví dụ 4 (lần/tuần) hoặc 5 (kg) | 4 | `[FROM-CUSTOMER]` |
| period | Chu kỳ | Có | Danh mục (tuần / tháng) | — | Tuần | `[FROM-CUSTOMER]` |
| current_progress | Tiến độ hiện tại | Có | Số | Cập nhật tự động | 2 | `[ASSUMED]` |

### PointsTransaction

| Field | Nhãn hiển thị | Bắt buộc? | Kiểu dữ liệu | Quy tắc | Ví dụ | Nguồn |
|---|---|---|---|---|---|---|
| transaction_id | Mã giao dịch | Có | Định danh | Duy nhất | PT-88213 | `[ASSUMED]` |
| employee_id | Nhân viên | Có | Tham chiếu Employee | — | EMP-0231 | — |
| source_type | Nguồn phát sinh | Có | Danh mục (workout / daily goal bonus / challenge / redemption / refund) | — | Workout | `[FROM-CUSTOMER]` |
| source_ref | Tham chiếu bản ghi nguồn | Không | Tham chiếu (WorkoutLog/Challenge/RewardRedemption) | — | WO-99213 | — |
| lifetime_amount | Thay đổi điểm tích lũy | Có | Số nguyên | **Luôn ≥ 0** — điểm tích lũy không bao giờ giảm | +100 | `[DECISION]` D-003 |
| available_amount | Thay đổi điểm khả dụng | Có | Số nguyên (có dấu) | Âm khi đổi thưởng, dương khi tập luyện hoặc khi hoàn điểm | +100 / −500 | `[DECISION]` D-003 |
| created_at | Thời điểm | Có | Ngày giờ | — | 2026-08-10 19:20 | — |

**Ví dụ minh họa cơ chế hai loại điểm:**

| Sự kiện | lifetime_amount | available_amount | Kết quả tích lũy / khả dụng |
|---|---|---|---|
| Log cardio 30 phút | +100 | +100 | 100 / 100 |
| Log tạ 45 phút | +150 | +150 | 250 / 250 |
| Đổi voucher cà phê (100đ) | 0 | −100 | 250 / 150 |
| HR từ chối yêu cầu, hoàn điểm | 0 | +100 | 250 / 250 |

### Level (bảng cấu hình)

| Field | Nhãn hiển thị | Bắt buộc? | Kiểu dữ liệu | Quy tắc | Ví dụ | Nguồn |
|---|---|---|---|---|---|---|
| level_number | Cấp độ | Có | Số nguyên (1–50) | Duy nhất | 12 | `[FROM-CUSTOMER]` |
| points_required | Điểm tích lũy tối thiểu cần đạt | Có | Số nguyên | Tính theo công thức 50 × N²; so sánh với `lifetime_points` | 7.200 (Level 12) | `[DECISION]` D-002 |
| unlocked_status | Trạng thái/quyền lợi mở khóa | Không | Văn bản | — | `[NEEDS-CONFIRMATION]` Q-013 | `[FROM-CUSTOMER]` |

### Badge (bảng cấu hình) / EmployeeBadge

| Field | Nhãn hiển thị | Bắt buộc? | Kiểu dữ liệu | Quy tắc | Ví dụ | Nguồn |
|---|---|---|---|---|---|---|
| badge_code | Mã badge | Có | Danh mục cố định | Starter/Streak7/Streak14/Streak30/NightWarrior/Powerlifter/Consistent | Streak7 | `[FROM-CUSTOMER]` |
| condition_description | Mô tả điều kiện đạt | Có | Văn bản | — | Tập liên tục 7 ngày | `[FROM-CUSTOMER]` |
| employee_id (EmployeeBadge) | Nhân viên đạt badge | Có | Tham chiếu Employee | — | EMP-0231 | — |
| achieved_at (EmployeeBadge) | Thời điểm đạt | Có | Ngày giờ | — | 2026-08-10 | — |

### Challenge (bảng cấu hình) / ChallengeParticipation

| Field | Nhãn hiển thị | Bắt buộc? | Kiểu dữ liệu | Quy tắc | Ví dụ | Nguồn |
|---|---|---|---|---|---|---|
| challenge_code | Mã thử thách | Có | Danh mục (CardioKing/MondayMotivation/WeekendWarrior) | — | CardioKing | `[FROM-CUSTOMER]` |
| target_value | Mục tiêu | Có | Số | Ví dụ 20 (km) | 20 | `[FROM-CUSTOMER]` |
| period_start / period_end | Thời gian hiệu lực | Có | Ngày | Reset theo tuần — `[NEEDS-CONFIRMATION]` mốc reset | — | `[NEEDS-CONFIRMATION]` |
| employee_id (Participation) | Nhân viên tham gia | Có | Tham chiếu Employee | — | EMP-0231 | — |
| current_progress (Participation) | Tiến độ hiện tại | Có | Số | — | 12 | — |
| completed (Participation) | Đã hoàn thành? | Có | Boolean | — | true | — |

### GymTeam / TeamMembership

| Field | Nhãn hiển thị | Bắt buộc? | Kiểu dữ liệu | Quy tắc | Ví dụ | Nguồn |
|---|---|---|---|---|---|---|
| team_id | Mã nhóm | Có | Định danh | Duy nhất | TEAM-14 | `[ASSUMED]` |
| team_name | Tên nhóm | Có | Văn bản | — | Iron Squad | `[FROM-CUSTOMER]` |
| member_count | Số thành viên | Có | Số nguyên | Từ 3 đến 5 | 4 | `[FROM-CUSTOMER]` |
| team_score | Điểm nhóm | Có | Số nguyên | Cách tính (tổng/trung bình) `[NEEDS-CONFIRMATION]` | — | `[NEEDS-CONFIRMATION]` |

### RewardCatalogItem / RewardRedemption

| Field | Nhãn hiển thị | Bắt buộc? | Kiểu dữ liệu | Quy tắc | Ví dụ | Nguồn |
|---|---|---|---|---|---|---|
| reward_id | Mã phần thưởng | Có | Định danh | Duy nhất | RW-004 | `[ASSUMED]` |
| reward_name | Tên phần thưởng | Có | Văn bản | — | Massage 30 phút | `[FROM-CUSTOMER]` |
| points_cost | Điểm cần để đổi | Có | Số nguyên | — | 500 | `[FROM-CUSTOMER]` |
| available_quantity | Số lượng khả dụng | `[NEEDS-CONFIRMATION]` | Số nguyên | Giảm khi có redemption thành công | `[NEEDS-CONFIRMATION]` | — |
| redemption_id | Mã yêu cầu đổi | Có | Định danh | Duy nhất | RD-2210 | `[ASSUMED]` |
| employee_id (Redemption) | Người yêu cầu | Có | Tham chiếu Employee | — | EMP-0231 | — |
| status (Redemption) | Trạng thái | Có | Danh mục (Chờ duyệt / Đã duyệt / Đã giao / Từ chối) | Mọi yêu cầu đều bắt đầu ở "Chờ duyệt" — không có tự động duyệt | Chờ duyệt | `[DECISION]` D-006 |
| requested_at | Thời điểm yêu cầu | Có | Ngày giờ | — | 2026-08-10 | — |
| reviewed_by | Người duyệt | Không | Tham chiếu Employee (vai trò Admin/HR) | Bắt buộc khi trạng thái khác "Chờ duyệt" | EMP-0007 | `[DECISION]` D-006 |
| reviewed_at | Thời điểm duyệt | Không | Ngày giờ | — | 2026-08-11 | `[DECISION]` D-006 |
| rejection_reason | Lý do từ chối | Không | Văn bản | Bắt buộc khi trạng thái là "Từ chối" | Hết số lượng trong tháng | `[DECISION]` D-006 |

### NutritionLog / WaterLog / SleepLog

| Field | Nhãn hiển thị | Bắt buộc? | Kiểu dữ liệu | Quy tắc | Ví dụ | Nguồn |
|---|---|---|---|---|---|---|
| employee_id | Nhân viên | Có | Tham chiếu Employee | — | EMP-0231 | — |
| log_date | Ngày ghi nhận | Có | Ngày | — | 2026-08-10 | — |
| calories_consumed (Nutrition) | Calories tiêu thụ | Có | Số nguyên | Cách nhập `[NEEDS-CONFIRMATION]` | 1800 | `[FROM-CUSTOMER]` |
| water_cups (Water) | Số cốc nước đã uống | Có | Số nguyên | Mục tiêu 8 cốc/ngày | 6 | `[FROM-CUSTOMER]` |
| sleep_hours (Sleep) | Số giờ ngủ | Có | Số thập phân | Nhập tay hay tự động `[NEEDS-CONFIRMATION]` | 7.5 | `[FROM-CUSTOMER]` |

---

## 3. Ràng buộc trong một thực thể (cross-field / quy tắc kết hợp)

| Mã quy tắc | Mô tả bằng lời | Các trường liên quan | Khi vi phạm | Nguồn / mức tin cậy |
|---|---|---|---|---|
| R-ENT-001 | `weight_lifted_kg` chỉ được nhập khi `workout_type` là weight lifting | WorkoutLog.workout_type, weight_lifted_kg | Chặn lưu / ẩn trường trên UI | `[ASSUMED]` |
| R-ENT-002 | `points_awarded` được tính tự động theo `workout_type` × `duration_minutes` (D-001), không cho nhập tay | WorkoutLog | Chặn sửa trực tiếp | `[DECISION]` D-001 |
| R-ENT-003 | Badge "Night Warrior" chỉ được xét khi `logged_at` có giờ từ 18:00 trở đi | WorkoutLog.logged_at, EmployeeBadge | Không cấp badge nếu sai điều kiện giờ | `[FROM-CUSTOMER]` |
| R-ENT-004 | `RewardRedemption` chỉ được tạo khi `Employee.available_points` đủ `points_cost` tại thời điểm yêu cầu | Employee.available_points, RewardCatalogItem.points_cost | Chặn tạo yêu cầu, báo lỗi thiếu điểm | `[DECISION]` D-003 |
| R-ENT-005 | `current_streak_days` reset về 0 nếu nhân viên bỏ lỡ điều kiện duy trì streak (không tập trong ngày yêu cầu) | Employee.current_streak_days, WorkoutLog | Reset tự động qua job hệ thống | `[NEEDS-CONFIRMATION]` — cần rõ điều kiện duy trì streak là "mỗi ngày" hay "theo mục tiêu tuần" |
| R-ENT-006 | Buổi tập dưới 10 phút không được tính điểm; điểm một buổi tối đa 300; tổng điểm một ngày tối đa 500 | WorkoutLog.duration_minutes, points_awarded, points_capped | Vẫn lưu buổi tập nhưng chỉ cộng điểm đến mức trần, đánh dấu `points_capped` và thông báo cho nhân viên | `[DECISION]` D-007 |
| R-ENT-007 | `lifetime_points` của một nhân viên luôn lớn hơn hoặc bằng `available_points` | Employee.lifetime_points, available_points | Bất biến hệ thống — vi phạm nghĩa là có lỗi logic tính điểm | `[DECISION]` D-003 |
| R-ENT-008 | `distance_km` chỉ được nhập khi `workout_type` là cardio | WorkoutLog.workout_type, distance_km | Ẩn trường trên giao diện với loại hình khác | `[DECISION]` D-005 |
| R-ENT-009 | Dữ liệu của `WeightLog`, `NutritionLog` và `SleepLog` không bao giờ hiển thị cho người dùng khác, bất kể `privacy_visibility` | WeightLog, NutritionLog, SleepLog, Employee.privacy_visibility | Là bất biến hệ thống — mọi truy vấn phục vụ bảng xếp hạng, bảng tin, hồ sơ công khai đều không được chạm tới ba nhóm dữ liệu này | `[DECISION]` D-009 |
| R-ENT-010 | `FeedPost` chỉ được tạo khi tác giả có `privacy_visibility` bằng Công khai | Employee.privacy_visibility, FeedPost | Không tạo bài đăng với nhân viên ở mức Ẩn danh hoặc Riêng tư | `[DECISION]` D-009 |
| R-ENT-011 | Khi `privacy_visibility` chuyển từ Công khai sang mức khác, toàn bộ `FeedPost` cũ của nhân viên đó bị gỡ khỏi bảng tin | Employee.privacy_visibility, FeedPost | Gỡ tự động ngay khi lưu thay đổi cài đặt | `[DECISION]` D-009, chi tiết `[ASSUMED]` |

---

## 4. Quan hệ và ràng buộc giữa các thực thể

### 4.1. Bảng quan hệ tổng quan

| Entity A | Entity B | Quan hệ nghiệp vụ | Bắt buộc tồn tại B khi tạo A? | Ghi chú |
|---|---|---|---|---|
| Employee | WorkoutLog | Một nhân viên có nhiều buổi tập | Không | |
| Employee | Goal | Một nhân viên có nhiều mục tiêu (theo kỳ) | Không | |
| Employee | PointsTransaction | Một nhân viên có nhiều giao dịch điểm | Không | |
| Employee | EmployeeBadge | Một nhân viên có nhiều badge đã đạt | Không | |
| Badge | EmployeeBadge | Một badge được cấp cho nhiều nhân viên | Có | EmployeeBadge phải tham chiếu một Badge hợp lệ |
| Employee | ChallengeParticipation | Một nhân viên tham gia nhiều thử thách | Không | |
| Challenge | ChallengeParticipation | Một thử thách có nhiều người tham gia | Có | |
| Employee | GymTeam (qua TeamMembership) | Nhiều-nhiều, một nhân viên có thể ở nhiều team `[NEEDS-CONFIRMATION]` giới hạn số team | | |
| Employee | Friendship | Nhiều-nhiều, quan hệ hai chiều | Không | Cần xác nhận có yêu cầu chấp thuận (accept) hay kết bạn một chiều |
| Employee | FeedPost | Một nhân viên có nhiều hoạt động trên feed | Không | FeedPost có thể sinh tự động từ WorkoutLog/EmployeeBadge |
| FeedPost | FeedComment / FeedReaction | Một post có nhiều comment/reaction | Không | |
| Employee | RewardRedemption | Một nhân viên có nhiều yêu cầu đổi thưởng | Không | |
| RewardCatalogItem | RewardRedemption | Một phần thưởng được đổi nhiều lần (đến khi hết số lượng) | Có | |
| Employee | NutritionLog / WaterLog / SleepLog | Một nhân viên có nhiều bản ghi theo ngày | Không | |
| ExerciseCatalog | WorkoutLog | Một bài tập được dùng trong nhiều buổi tập | Không | |

### 4.2. Ràng buộc tham chiếu và hành vi nghiệp vụ

| Mã | Từ entity | Đến entity | Khi tạo mới | Khi cập nhật | Khi xóa hoặc vô hiệu | Ghi chú |
|---|---|---|---|---|---|---|
| REL-001 | WorkoutLog | Employee | Tạo PointsTransaction cộng cả `lifetime_points` và `available_points` | Không cho sửa điểm trực tiếp | Không xóa cứng, chuyển trạng thái vô hiệu để giữ vết điểm `[NEEDS-CONFIRMATION]` | |
| REL-002 | RewardRedemption | RewardCatalogItem | Trừ `available_points` ngay khi tạo yêu cầu; giảm `available_quantity` nếu có giới hạn số lượng | Chỉ Admin/HR đổi được trạng thái | Khi HR từ chối, hoàn lại đúng số `available_points` đã trừ; `lifetime_points` không đổi | `[DECISION]` D-003, D-006 |
| REL-003 | TeamMembership | GymTeam | Kiểm tra `member_count` không vượt 5 | — | Khi thành viên rời nhóm, cập nhật `team_score` | |
| REL-004 | EmployeeBadge | Badge | Chỉ tạo khi điều kiện Badge được thỏa | Không cho sửa tay | Không xóa | |

---

## 5. Câu hỏi mở (Open questions)

Các câu hỏi ảnh hưởng đến entity đã được chốt: Q-001 (công thức điểm → D-001), Q-002 (ngưỡng Level → D-002), Q-004 (cơ chế hai loại điểm → D-003), Q-007 (nhập tay → D-005), Q-008 (`privacy_visibility` → D-009). Còn lại ảnh hưởng đến entity: Q-009 (cách tính `team_score`), Q-010 (mốc reset Challenge/Leaderboard), Q-015 (điều kiện badge Consistent). Chi tiết tại `business-understanding.md` §14.

---

## Checklist rà soát

- [x] Danh sách entity bao phủ các khái niệm chính trong Business Understanding.
- [x] Công thức tính điểm workout và bảng ngưỡng Level đã chốt (D-001, D-002).
- [x] Cơ chế điểm khi đổi thưởng đã chốt: trừ `available_points` ngay khi tạo yêu cầu, hoàn lại khi HR từ chối, `lifetime_points` không bao giờ giảm (D-003, D-006).
- [x] Đã bổ sung entity `WeightLog` và trường `distance_km` để phục vụ mục tiêu giảm cân, biểu đồ weight trend và thử thách Cardio King khi nhập tay (D-005).
- [x] Trường `privacy_visibility` đã chốt tập giá trị (Công khai / Ẩn danh / Riêng tư) và giá trị mặc định (Công khai) theo D-009; đã bổ sung R-ENT-009 đến R-ENT-011 cho các ràng buộc đi kèm.
- [ ] Cardinality Employee–GymTeam và Employee–Friendship cần Product Owner xác nhận (Q-009).
