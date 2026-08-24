---
title: 'Design System'
description: 'Hợp đồng thiết kế Flutter: màu, chữ, spacing, layout, motion và component gamification.'
---
# Design System — Fitness Application

Đây là tài liệu mình tra mỗi lần dựng một màn Flutter mới: token màu nào dùng ở đâu, spacing bao nhiêu, animation dài mấy mili-giây. Ban đầu mình hay tự đặt hex color hoặc font tùy hứng trong widget, sau đó phải sửa lại toàn bộ nên giờ mọi thứ đi qua theme trước.

## Mục đích

Tài liệu này là hợp đồng thiết kế cho Fitness Application. Mọi màn Flutter phải dùng các token ngữ nghĩa (semantic token) này thông qua app theme, thay vì đặt thẳng hex color, tên font hay text style tuỳ ý trong widget.

Nguồn là board Figma `Fonts_and_Colors`, node `1:2` trong file cộng đồng Fitness App. Phần triển khai Flutter nằm ở `App/lib/theme/`.

## Nền tảng (Foundations)

### Typography

Font chữ của sản phẩm là `Lato`. Nguồn Figma cung cấp các weight sau:

| Token | Lato weight | Flutter `FontWeight` | Dùng khi nào |
| --- | --- | --- | --- |
| `font-regular` | Regular | `w400` | Body copy, helper text |
| `font-medium` | Medium | `w500` | Body nhấn mạnh, label |
| `font-semibold` | SemiBold | `w600` | Button, tab, section label |
| `font-bold` | Bold | `w700` | Title, chỉ số chính |
| `font-extrabold` | ExtraBold | `w800` | Display heading, hero metric |

Bản theme Flutter đầu tiên dùng text role của Material 3 với các weight trên. Font size và line height sẽ được tinh chỉnh dần theo từng màn Figma khi triển khai; không màn nào được tạo thêm font family thứ hai.

### Token màu

Bảng màu dưới đây lấy trực tiếp từ nguồn Figma. Tên ngữ nghĩa định nghĩa cách code dùng một màu; chúng không thay đổi giá trị gốc.

| Token | Hex | Vai trò ngữ nghĩa |
| --- | --- | --- |
| `color-background` | `#192126` | Nền chính của app |
| `color-accent` | `#BBF246` | Hành động chính, trạng thái đang chọn, điểm nhấn tiến độ |
| `color-neutral-500` | `#8B8F92` | Text phụ, icon inactive |
| `color-neutral-600` | `#5E6468` | Text cấp ba, nội dung disabled |
| `color-neutral-800` | `#384046` | Viền surface, surface tối nổi khối |
| `color-violet` | `#A48AED` | Chuỗi biểu đồ/workout A |
| `color-danger` | `#ED4747` | Hành động huỷ/xoá, trạng thái lỗi, chỉ số cảnh báo |
| `color-warning` | `#FCC46F` | Trạng thái warning, chuỗi biểu đồ B |
| `color-info` | `#95CCE3` | Trạng thái thông tin, chuỗi biểu đồ C |

### Vai trò ngữ nghĩa dẫn xuất

`ThemeData` map các token nền tảng sang vai trò Material 3 như sau:

| Vai trò Material | Token |
| --- | --- |
| `ColorScheme.surface` / `scaffoldBackgroundColor` | `color-background` |
| `ColorScheme.primary` | `color-accent` |
| `ColorScheme.onPrimary` | `color-background` |
| `ColorScheme.secondary` | `color-violet` |
| `ColorScheme.error` | `color-danger` |
| `ColorScheme.onSurface` | trắng, để text nổi rõ trên nền tối |
| `ColorScheme.onSurfaceVariant` | `color-neutral-500` |
| `ColorScheme.outline` | `color-neutral-800` |

Màu trắng cho text nổi là một ngữ nghĩa triển khai bắt buộc để đủ độ tương phản trên nền primary tối, không phải một màu thương hiệu mới.

## Quy tắc Component

### Button

- Button chính: nền `color-accent`, label `color-background`, Lato SemiBold.
- Button huỷ/xoá: nền hoặc viền `color-danger` tuỳ theo mức độ ưu tiên hành động huỷ của từng màn.
- Button disabled dùng tông neutral nhạt; không bao giờ tái sử dụng màu accent ở full opacity.

### Text

- Display và title màn dùng Lato ExtraBold hoặc Bold.
- Heading của section dùng Lato Bold hoặc SemiBold.
- Button và nhãn điều hướng dùng Lato SemiBold.
- Body copy dùng Lato Regular; giá trị quan trọng có thể dùng Medium hoặc Bold.
- Text phụ và inactive dùng `color-neutral-500` hoặc `color-neutral-600`.

### Surface và trạng thái

- Nền toàn app dùng `color-background`.
- Phần tử tối nổi khối và đường phân cách dùng `color-neutral-800`.
- Không dùng `color-violet`, `color-warning`, hay `color-info` làm màu CTA chung. Các màu này dành riêng cho chuỗi biểu đồ, danh mục workout và trạng thái ngữ nghĩa.
- Nội dung lỗi phải dùng `color-danger`; nội dung warning phải dùng `color-warning`.

### Biểu đồ và chỉ số thể chất

- Thứ tự chuỗi mặc định: violet, warning, info, rồi accent.
- Không bao giờ truyền đạt trạng thái chỉ số chỉ bằng màu sắc; phải đi kèm label, icon hoặc thay đổi giá trị.
- Giữ `color-danger` chỉ dành cho ý nghĩa tiêu cực/cảnh báo, không dùng cho tiến độ bình thường.

## Triết lý UX — Gamified Social

> Nguồn: quyết định sản phẩm cho HealthStride, 2026-08-10. Không lấy từ Figma.

HealthStride là sự lai giữa hai preset **Social & Community** và **Emotional & Hedonic**. Sản phẩm tồn tại để khiến nhân viên *muốn* tập luyện, nên giao diện phải thưởng ngay cho hành động và làm tiến độ hiển thị rõ với đồng nghiệp.

| Yếu tố | Thiết lập | Hệ quả cho thiết kế |
| --- | --- | --- |
| Mật độ nội dung | Thấp–trung bình | Mỗi màn một hành động chính. Dùng card, không dùng bảng. |
| Thiết bị mục tiêu | Mobile-first | Bottom tab bar, hành động chính trong tầm ngón cái. |
| Ngân sách animation | Trung bình–cao | Điểm, lên level và huy hiệu có animation. Điều hướng thì không. |
| Kiểu xác nhận | Inline + undo | `AlertDialog` chỉ dùng cho hành động không thể hoàn tác (đổi điểm, xoá log). |
| Gamification | Đậm | Điểm, level, huy hiệu, streak và rank là thành phần UI chính, không phải chi tiết phụ. |
| Độ sâu định danh | Cao | Avatar, level và rank xuất hiện ở mọi nơi có tên người dùng. |
| Empty state | Mời gọi | "Log buổi tập đầu tiên để nhận 100 điểm", không bao giờ chỉ ghi "Không có dữ liệu". |

### Quy tắc không thương lượng

1. **Mọi hành động được điểm phải có phản hồi hiển thị trong vòng 300 ms.** Log một buổi tập phải có animation tăng điểm — vòng lặp thưởng chính là sản phẩm.
2. **Log một buổi tập không bao giờ quá hai lần chạm từ bất kỳ màn nào.** Nút hành động cố định nằm trong bottom navigation.
3. **Điểm tích luỹ trọn đời và điểm khả dụng luôn được gắn nhãn phân biệt rõ ràng.** Không bao giờ hiển thị một con số trần có thể hiểu nhầm là loại kia (xem `business-understanding.md` §6.8).
4. **Tiến độ được thể hiện bằng hình ảnh, không chỉ bằng câu chữ.** Ưu tiên ring, bar hoặc sparkline hơn một câu mô tả.
5. **Vùng chạm tối thiểu 48×48 dp.** Người dùng thao tác giữa buổi tập với tay ướt mồ hôi.

### Anti-pattern

- Bảng dữ liệu dày đặc (chỉ dùng layout dạng bảng cho màn admin)
- Wizard nhiều bước để log một buổi tập
- Dialog xác nhận cho hành động không mang tính huỷ/xoá
- Truyền đạt rank, streak hay thành tích chỉ bằng màu sắc
- Điều hướng kiểu sidebar hoặc drawer làm nav chính

## Thang Spacing

> Nguồn: quyết định sản phẩm, lưới cơ sở 8 dp. Không lấy từ Figma. Sẽ điều chỉnh khi có frame layout Figma.

| Token | Giá trị | Dùng khi nào |
| --- | --- | --- |
| `space-2xs` | 4 dp | Khoảng cách icon–label, padding trong chip |
| `space-xs` | 8 dp | Các phần tử liên quan trong cùng một card |
| `space-sm` | 12 dp | Padding trong card ở card compact |
| `space-md` | 16 dp | Padding card mặc định, margin ngang của màn |
| `space-lg` | 24 dp | Giữa các section riêng biệt trong một màn |
| `space-xl` | 32 dp | Phía trên call-to-action chính của màn |
| `space-2xl` | 48 dp | Khoảng thở cho hero metric, padding empty-state |

Margin ngang của màn là `space-md` (16 dp) trên mọi màn. Không thay đổi theo từng màn.

## Radius và Elevation

> Nguồn: quyết định sản phẩm. Không lấy từ Figma.

| Token | Giá trị | Dùng khi nào |
| --- | --- | --- |
| `radius-sm` | 8 dp | Chip, badge, input nhỏ |
| `radius-md` | 12 dp | Button, text field, dòng list |
| `radius-lg` | 16 dp | Card, sheet |
| `radius-xl` | 24 dp | Hero card, modal sheet |
| `radius-full` | 999 dp | Avatar, progress ring, pill button |

App có nền tối, nên **elevation được thể hiện bằng màu surface, không bằng đổ bóng**.

| Cấp | Surface | Dùng khi nào |
| --- | --- | --- |
| Level 0 | `color-background` | Nền toàn app |
| Level 1 | `color-neutral-800` ở 40% trên nền | Card, dòng list |
| Level 2 | `color-neutral-800` | Bottom sheet, dialog, trạng thái đang chọn |
| Level 3 | `color-neutral-800` + viền 1 dp `color-neutral-600` | Chỉ dùng cho modal dialog |

Đổ bóng chỉ được phép dùng cho floating action button và bottom sheet, ở opacity thấp. Không bao giờ dùng bóng để tách hai card trên cùng một surface — dùng `space-sm` thay thế.

## Mẫu Layout (Layout Pattern)

Mobile-first, một cột. App dùng **bottom tab bar** với năm điểm đến và một floating action ở giữa để log buổi tập.

```
┌──────────────────────────────┐
│  App bar (theo ngữ cảnh)     │  56 dp — title + hành động tuỳ chọn
├──────────────────────────────┤
│                              │
│  Nội dung cuộn được          │  margin ngang 16 dp
│  (card, feed, list)          │
│                              │
├──────────────────────────────┤
│  Home  Feed  [+]  Rank  Me   │  Bottom navigation, 64 dp + safe area
└──────────────────────────────┘
```

| Điểm đến | Màn | Ý nghĩa icon |
| --- | --- | --- |
| Home | `SCR-HOME-10` Dashboard | Tổng quan điểm, level, streak, mục tiêu |
| Feed | `SCR-SC-20` Activity Feed | Hoạt động toàn công ty |
| **Log** | `SCR-WO-11` Log workout | Floating action ở giữa, nền `color-accent` |
| Rank | `SCR-SC-10` Leaderboard | Bảng xếp hạng |
| Me | `SCR-PROF-10` Profile | Định danh, lịch sử, cài đặt |

Cửa hàng phần thưởng `SCR-RW-10` được truy cập từ Home dashboard và từ màn Profile; nó không chiếm một tab riêng vì tần suất truy cập thấp hơn năm điểm đến trên.

Các màn admin (`SCR-ADM-*`) dùng layout list-and-detail thông thường, không có bottom tab bar, vì chúng phục vụ vai trò và nhịp thao tác khác.

## Motion

> Nguồn: quyết định sản phẩm. Không lấy từ Figma.

| Token | Thời lượng | Curve | Dùng khi nào |
| --- | --- | --- | --- |
| `motion-instant` | 100 ms | `Curves.easeOut` | Nhấn button, chọn chip |
| `motion-quick` | 200 ms | `Curves.easeInOut` | Mở sheet, chuyển tab, item list xuất hiện |
| `motion-reward` | 600 ms | `Curves.easeOutBack` | Bộ đếm tăng điểm, progress ring fill |
| `motion-celebrate` | 1200 ms | `Curves.elasticOut` | Overlay lên level và nhận huy hiệu |

Motion reward và celebrate là nơi duy nhất được phép dùng easing "vui nhộn". Điều hướng phải giữ cảm giác điềm tĩnh — người dùng mở app 40 lần một tháng sẽ thấy mệt nếu nav nào cũng nảy.

Tôn trọng thiết lập reduced-motion của hệ điều hành: khi bật, thay `motion-reward` và `motion-celebrate` bằng cross-fade ở `motion-quick`, giữ nguyên kết quả số liệu.

## Quy tắc Component — Mở rộng

### Card

Card là container nội dung chính. Card mặc định: `color-neutral-800` ở 40% trên nền, `radius-lg`, padding `space-md`. Card không bao giờ có viền trừ khi thể hiện trạng thái đang chọn, khi đó viền là 1 dp `color-accent`.

### Bottom navigation

Năm mục, `color-accent` cho mục đang active, `color-neutral-500` cho mục inactive. Trạng thái active phải kết hợp màu accent với biến thể icon filled — màu sắc một mình không được phép làm chỉ báo trạng thái. Nút Log ở giữa là hình tròn 56 dp, nền `color-accent`, icon `color-background`.

### Input

`radius-md`, nền `color-neutral-800`, không viền khi ở trạng thái nghỉ. Trạng thái focus có viền 1 dp `color-accent`. Trạng thái lỗi có viền 1 dp `color-danger` cộng dòng helper `color-danger` bên dưới — không bao giờ chỉ dùng màu sắc.

### Bottom sheet

Các luồng log (workout, nước uống, cân nặng) mở dưới dạng bottom sheet thay vì full screen, để người dùng giữ được ngữ cảnh. `radius-xl` chỉ ở hai góc trên, drag handle màu `color-neutral-600`, surface Level 2.

### Empty state

Mọi empty state gồm ba phần: icon minh hoạ màu `color-neutral-600`, một câu giải thích nội dung sẽ xuất hiện ở đây, và một hành động chính để lấp đầy nó. Không bao giờ chỉ hiển thị "Không có dữ liệu".

## Component Gamification

Đây là các thành phần riêng của HealthStride. Chúng là hợp đồng thiết kế, không phải widget Material.

### Hiển thị điểm

Hai cách trình bày khác nhau để hai loại số không bao giờ bị nhầm lẫn:

| Giá trị | Cách trình bày | Ở đâu |
| --- | --- | --- |
| Điểm tích luỹ trọn đời | Lato ExtraBold, `color-accent`, kèm nhãn nhỏ "total" | Hero của Dashboard, dòng trên leaderboard |
| Điểm khả dụng | Lato Bold, trắng, kèm icon ví và nhãn "available" | Header cửa hàng phần thưởng, sheet đổi thưởng |

Ở bất kỳ đâu hai loại điểm xuất hiện cùng nhau, chúng phải nằm sát nhau về mặt thị giác và đều có nhãn.

### Level ring

Vòng tròn progress thể hiện tiến độ tới level tiếp theo. Track màu `color-neutral-800`, fill `color-accent`, `radius-full`. Giữa vòng là số level bằng Lato ExtraBold. Bên dưới vòng, một dòng ghi "X / Y điểm để lên Level N+1" — bản thân vòng tròn không bao giờ tự mang đủ ý nghĩa.

### Badge tile

Ô vuông, `radius-lg`. Huy hiệu đã đạt dùng artwork đầy đủ màu trên surface Level 1. Huy hiệu chưa đạt dùng cùng artwork ở 30% opacity trên nền, kèm điều kiện mở khoá hiển thị bên dưới bằng `color-neutral-500`. Huy hiệu chưa đạt không bao giờ bị ẩn — nhìn thấy mục tiêu chính là mục đích.

### Streak indicator

Icon ngọn lửa cộng số ngày. Màu tăng dần theo độ dài streak để tạo cảm xúc cho con số, nhưng số ngày luôn được hiển thị bằng text bên cạnh:

| Streak | Màu icon |
| --- | --- |
| 1–6 ngày | `color-neutral-500` |
| 7–13 ngày | `color-warning` |
| 14–29 ngày | `color-accent` |
| 30+ ngày | `color-danger` dùng làm điểm nhấn "hot", kèm icon ngọn lửa filled |

Đây là ngoại lệ duy nhất được cho phép với quy tắc dành `color-danger` cho ý nghĩa tiêu cực. Ngoại lệ này chỉ áp dụng cho streak indicator ở mốc 30+ ngày, và chỉ khi icon ngọn lửa ở dạng filled để trạng thái đọc là "cường độ cao" chứ không phải lỗi.

### Leaderboard row

Số thứ hạng, avatar, tên, điểm tích luỹ trọn đời và streak indicator. Dòng của chính người dùng hiện tại dùng surface Level 2 với viền trái 1 dp `color-accent` để dễ tìm khi cuộn. Hạng 1–3 có huy hiệu medal màu `color-warning`, `color-neutral-500` và tông đồng lần lượt, luôn đi kèm số hạng.

### Point-gain toast

Sau khi lưu một buổi tập, toast animate số điểm nhận được từ 0 bằng `motion-reward`. Khi trần theo ngày hoặc theo buổi đã được áp dụng, toast phải nêu thêm lý do bằng ngôn ngữ dễ hiểu, ví dụ "Được cộng 300 điểm — mức tối đa cho một buổi tập".

## Accessibility

- Độ tương phản text trên `color-background` phải đạt WCAG AA. `color-neutral-600` chỉ được duyệt cho nội dung trang trí và disabled, không dùng cho nội dung người dùng cần đọc.
- Không bao giờ truyền đạt trạng thái chỉ bằng màu sắc. Mọi quy tắc gán màu ở trên đều đi kèm icon, nhãn hoặc giá trị số.
- Vùng chạm tối thiểu 48×48 dp, kể cả icon button trong app bar.
- Mọi progress ring và biểu đồ đều có phương án thay thế bằng text qua `Semantics`.
- Tôn trọng thiết lập reduced-motion của hệ điều hành như mô tả ở phần Motion.

## Hợp đồng Flutter

Phần triển khai theme Flutter được tổ chức thành các module sau:

| File | Trách nhiệm | Trạng thái |
| --- | --- | --- |
| `lib/theme/app_colors.dart` | Hằng số màu nền tảng và ngữ nghĩa, bất biến | Đã triển khai |
| `lib/theme/app_typography.dart` | Text theme Material 3 dựa trên Lato | Đã triển khai |
| `lib/theme/app_theme.dart` | `ThemeData` Material 3 tối và mặc định component-theme | Đã triển khai |
| `lib/theme/app_spacing.dart` | Hằng số spacing, radius và elevation-surface | Chưa xây dựng |
| `lib/theme/app_motion.dart` | Hằng số duration và curve | Chưa xây dựng |

Code widget phải lấy màu và typography dùng chung từ `Theme.of(context).colorScheme` và `Theme.of(context).textTheme`. Chỉ được tham chiếu `AppColors` cho các chuỗi biểu đồ có tên riêng hoặc chỉ số thể chất đặc thù không có vai trò Material color tương ứng.

Component gamification nằm dưới `lib/widgets/gamification/` và phải dùng lại các token ở trên thay vì định nghĩa giá trị mới.

## Yêu cầu về Asset

Trước khi bật theme Flutter, project phải có đủ file font Lato cho các weight Regular, Medium, SemiBold, Bold, ExtraBold trong `App/assets/fonts/` và khai báo trong `App/pubspec.yaml`. Không dựa vào tải font qua mạng lúc runtime.

## Kiểm chứng

- So khớp mỗi màn Figma đã triển khai với tài liệu này trước khi review.
- Chạy `flutter analyze` và `flutter test` sau khi tích hợp theme.
- Test trên cả simulator Android và iOS.
- Kiểm tra độ tương phản text trên nền tối và xác nhận màu sắc không phải chỉ báo duy nhất của một trạng thái.

## Phạm vi

Hệ thống này gồm hai lớp, và sự phân biệt này quan trọng khi frame Figma xuất hiện.

**Lớp 1 — từ Figma** (`Fonts_and_Colors`, node `1:2`): font family, các weight và bảng màu. Các giá trị này là chuẩn (authoritative); không thay đổi nếu chưa có nguồn Figma mới.

**Lớp 2 — từ quyết định sản phẩm** (2026-08-10): triết lý UX, thang spacing, radius, elevation, layout pattern, motion, quy tắc component mở rộng và component gamification. Các giá trị này được suy ra từ tài liệu nghiệp vụ HealthStride trong `Document/HealthStride/` vì chưa có frame layout Figma. Khi Figma cung cấp frame layout, đối chiếu chúng với lớp này và ghi lại mọi thay đổi ở đây thay vì trong code widget.

Icon chưa được quy định. App hiện chỉ phụ thuộc `cupertino_icons`; quyết định bộ icon vẫn còn để ngỏ.

## Tài liệu liên quan

| Tài liệu | Liên quan |
| --- | --- |
| `Document/HealthStride/screen-flow.md` | Nguồn danh sách màn mà layout pattern này phục vụ |
| `Document/HealthStride/business-understanding.md` | Business rules đằng sau component gamification |
| `Document/HealthStride/decision-log.md` | Vì sao điểm trọn đời và điểm khả dụng được hiển thị tách biệt (D-003) |
| `Document/HealthStride/screens/` | Đặc tả thiết kế và hành vi cho từng màn |
