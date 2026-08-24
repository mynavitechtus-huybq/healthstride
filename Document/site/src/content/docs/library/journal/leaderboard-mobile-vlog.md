---
title: 'Vlog: Leaderboard Mobile - 24 tháng 8 năm 2026'
description: 'Câu chuyện nối màn Leaderboard Flutter với API Backend.'
---

# Nhật ký xây dựng: Leaderboard Mobile

## Tôi đã làm gì?

Tôi thay tab Explore đang báo “coming soon” bằng màn Leaderboard. Màn gọi API tuần, hiển thị thứ hạng hiện tại và danh sách người dùng cùng số điểm. Màn nằm trong cùng shell của Home nên bottom menu vẫn còn khi chuyển tab.

## Tôi làm như thế nào?

Tôi tạo model, repository, controller và screen. Home giữ `selectedTab` và chỉ thay phần nội dung; tab active hiển thị icon cùng title. Controller tách loading, dữ liệu, empty và lỗi để UI dễ đọc và dễ test.

## Khó khăn và cách tháo gỡ

Test bị lỗi vì `MyApp` tạo API repository thật dù đang dùng fake Home repository, làm `API_BASE_URL` rỗng bị đọc sớm. Tôi sửa để production mới tạo repository thật; test double không cần network.

## Tôi học được gì?

Feature Mobile cần cả UI, API decoder, trạng thái và dependency có thể thay thế. Flutter hiển thị dữ liệu; điểm số và cache vẫn thuộc Backend.

## Kiểm tra

- `flutter analyze`: không lỗi.
- `flutter test`: pass.
- Leaderboard repository và widget tests: pass.

Manual simulator với Firebase token thật vẫn là bước tiếp theo.

## Chốt UI menu

- Icon active và inactive cùng kích thước `24px`.
- Icon và text active được căn giữa trong cùng pill và padding.
- Các label dùng cùng cỡ chữ.
- Khối active vẫn trượt giữa các item bằng animation.

Sau chốt này chỉ còn kiểm thử responsive và simulator.
