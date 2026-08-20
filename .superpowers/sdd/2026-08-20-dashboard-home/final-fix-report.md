# Báo cáo fix cuối Dashboard/Home

Ngày: 20 August 2026

## Trạng thái

Đã sửa toàn bộ finding trong final whole-branch review bằng một fix wave có regression test tập trung. Không thêm token, credential, `.env` hoặc evidence integration giả.

## Fix đã thực hiện

1. `ApiClient.get(...)` map exception từ `tokenProvider` và `getRequest` sang `NETWORK_REQUEST_FAILED`; `createHttpGetRequest(...)` có timeout production mặc định 15 giây.
2. Mọi `statusCode >= 400` đều trả failure trước khi decode `data`; error thiếu hoặc sai kiểu dùng fallback `UNKNOWN_ERROR` và `Request failed.`.
3. `HomeController` dùng request generation chung cho `load()`/`refresh()`, bỏ qua completion cũ và completion sau `dispose()`; refresh failure vẫn giữ Dashboard cũ.
4. Android source set `debug` bật `android:usesCleartextTraffic="true"` để gọi `http://10.0.2.2:8000`; manifest `main`/release không bật cleartext.
5. AppBar hiển thị `HealthStride`; greeting ưu tiên display name, email, rồi `Athlete`; widget test chạy ở `390x844` và cleanup test view.
6. Mobile daily record và public Vlog phân biệt rõ `https://example.com` chỉ là URL xác minh build, không phải URL local integration.

## TDD evidence

Red phase đã xác nhận đúng lỗi cần bắt:

- exception lấy token/request thoát khỏi `ApiClient`;
- `400` có map-shaped `data` bị decode thành success;
- malformed error gây `TypeError`;
- HTTP adapter chưa có timeout inject được;
- completion sau `dispose()` gây lỗi `HomeController was used after being disposed`;
- completion load cũ ghi đè refresh mới;
- phone test không tìm thấy `HealthStride`.

Green phase:

- focused network/controller/Home screen suite: `24` test pass;
- full Flutter suite: `40` test pass.

## Quality gates

| Gate | Kết quả |
| --- | --- |
| `flutter analyze` | `No issues found!` |
| `flutter test` | `40` test pass |
| `flutter build ios --simulator --debug --dart-define=API_BASE_URL=https://example.com` | Build thành công, tạo `Runner.app` |
| `flutter build apk --debug` | Build thành công, tạo `app-debug.apk` |
| `uv run pytest` | `29 passed, 4 skipped, 1 warning` |
| `pnpm build` | Astro check `0 errors`, `0 warnings`, `0 hints`; build 6 pages thành công |

Generated Android debug manifest đã được kiểm tra và có `android:usesCleartextTraffic="true"`.

## Blocker còn lại

Chưa có simulator/emulator đang chạy và chưa có Firebase credentials local, nên chưa xác minh manual Google sign-in, Dashboard từ FastAPI local hoặc pull-to-refresh end-to-end. Không claim các luồng này đã pass. `https://example.com` chỉ chứng minh iOS debug artifact build được với `--dart-define`.

Backend test còn một `StarletteDeprecationWarning` từ dependency `fastapi.testclient`; bốn migration integration test được skip theo điều kiện môi trường hiện có.
