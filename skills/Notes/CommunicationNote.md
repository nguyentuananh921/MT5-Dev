## Communication Note

Liệt kê contract giao tiếp trực tiếp giữa các [Working Area](../AGENTS.md#working-area-và-sync-everywhere) trong [System](../AGENTS.md#system).

## Working Area Connections

 - **EA Module ↔ Python Library:** TCP socket thuần qua [`CPythonBridge`](../../Library/Services/DELib/PythonBridge.mqh). Python gửi forecast; EA gửi danh sách Symbol+TF theo dõi.
 - **EA Module ↔ Database:** SQLite contract qua [`CDatabaseService`](../../Library/Services/DELib/DatabaseService.mqh) và các service liên quan.
 - **EA Module ↔ MT5 Library:** contract MQL5 trong process EA; adapter được EA sử dụng, không tạo kênh network riêng.
 - **EA Web ↔ Python Library:** HTTP API cho request/response; WebSocket `/socket` cho dữ liệu realtime.
 - **Python Library ↔ Database:** Python worker đọc/ghi dữ liệu phụ thuộc Worker và service; contract theo table hiện có, không suy ra schema mới trong Note.
 - **Python Library ↔ MT5 terminal/MT5 Library:** Python lấy rates và trạng thái market cần cho calculation; phần MQL5 của Library không triển khai WebSocket cho luồng này.
 - **EA Module ↔ EA Web:** không có kênh trực tiếp; trao đổi gián tiếp qua Python Library hoặc Database theo contract riêng.
 - **Vendor Library:** dependency read-only cho EA Module và Python Library; không thêm kênh network mới.
 - **Skills:** tài liệu và rule; không tham gia runtime communication.

## Channel Contracts

### Database

 Lưu và chia sẻ dữ liệu bền vững. SQLite runtime của V5 được EA và các component liên quan truy cập qua contract Database. Forecast Kronos là dữ liệu realtime, được giữ trong RAM của `server.py`; không lưu vào DB và không có schema riêng cho WebSocket. EA Web không truy cập Database trực tiếp; dữ liệu phục vụ setting/API đi qua Python Library hoặc service được xác nhận trong implementation.

### HTTP API

 Request/response giữa EA Web và Python Library. Ví dụ `/bars` và `/strategies`.

### TCP

 Socket thuần giữa EA Module và Python Library. Không dùng để truyền điều khiển Worker qua `Event Bus`.

### WebSocket

 Realtime connection giữa EA Web và Python Library tại `/socket`.

### File

 Cờ điều khiển/tiến độ giữa EA Module và Python Library; không truyền forecast hoặc thay TCP/WebSocket.

 `Event Bus` của EA chỉ dispatch trong process EA. Không phải kênh trao đổi trực tiếp giữa các Working Area.

## Python Library

 `Kronos_forecast.py` dùng vendor Kronos để tính forecast; `server.py` giữ kết quả hiện tại trong RAM và đẩy tới client đang theo dõi. Server dùng cùng port cho kết nối TCP thuần của EA và WebSocket của browser; WebSocket endpoint là `/socket`.

 Client đăng ký cặp bằng `watch|<symbol>|<tf>[|<symbol>|<tf>...]`. Khi nhận `watch`, server cập nhật danh sách cặp client theo dõi và gửi forecast đang giữ trong RAM nếu có. Forecast mới chỉ được gửi tới client theo dõi đúng cặp.

 Protocol dùng các dòng kết thúc bằng newline, field phân cách bằng `|`. WebSocket truyền các dòng trong text frame; TCP thuần truyền trực tiếp trên socket.

 - Client -> server: `watch|<symbol>|<tf>[|<symbol>|<tf>...]`; Web hiện gửi một cặp đang xem, EA có thể gửi nhiều cặp.
 - Server -> client: `forecast|<symbol>|<tf>|<from_time>|<bar_time>|<open>|<high>|<low>|<close>|<volume>` cho từng bar.
 - Server -> client: `forecast_end|<symbol>|<tf>|<from_time>|<bars>` báo đã gửi đủ lượt forecast; chỉ chứa các nến forecast tương lai.

 Giữ contract đồng bộ giữa `server.py`, `CPythonBridge` và `Web\src\main.ts`. Thời gian trong protocol là giây theo server/MT5; không đổi đơn vị một phía.

 Các file cờ phục vụ điều khiển/tiến độ worker, tách biệt với TCP socket truyền forecast: Python ghi `Python_CurrentStart.flag`, `Python_CurrentChart.flag`, `Python_CurrentSymbolTF.flag`, `Python_CurrentDone.flag` và `Python_HistoryDone.flag` để báo milestone; EA ghi `Python_Jobs.flag` để yêu cầu Python chạy lại Current sau khi thay đổi template hoặc cặp Symbol+TF.
