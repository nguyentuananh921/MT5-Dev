# Communication Note

## Nguyên tắc chung

Các kênh trao đổi giữa các module:

### Database

Lưu và chia sẻ dữ liệu bền vững. Database runtime của V5 dùng SQLite; server có thể đọc DB rồi trả dữ liệu qua API.

### HTTP API

Request/response giữa client và server, ví dụ Web lấy `/bars` và `/strategies` từ Python server.

### TCP

Socket thuần, truyền dòng dữ liệu giữa EA Module và Python server.

### WebSocket

Truyền dữ liệu realtime giữa Python server và trình duyệt EA Web.

### File

Cờ điều khiển/tiến độ giữa EA và các Python worker; không dùng để truyền forecast trên kết nối server–EA.

`Event Bus` của EA chỉ dispatch trong cùng process, không phải kênh trao đổi giữa các module.

## EA Module

EA tạo và sở hữu instance `CPythonBridge`, rồi kết nối instance đó với các collection cần nhận dữ liệu. Instance chạy trong process EA.

## EA Web

Web browser gọi [HTTP API](#http-api) của Python server.
Các setting `/symbols`, `/timeframes`, `/strategies` được server đọc từ [Database](#database) rồi trả về; browser không kết nối Database trực tiếp.

`/bars` lấy rates từ MT5 qua Python, không đọc từ Database. Forecast realtime đi qua [WebSocket](#websocket) `/socket`; protocol xem tại [Library\Python](#librarypython).

## Library

Các service adapter của Library triển khai những kênh giao tiếp:

- [`CPythonBridge`](../../Library/Services/DELib/PythonBridge.mqh) do EA sở hữu instance; service kết nối TCP socket thuần tới Python server để nhận forecast và các dòng kết quả. Chi tiết protocol nằm ở [Library\Python](#librarypython).
- [`CDatabaseService`](../../Library/Services/DELib/DatabaseService.mqh) truy cập SQLite để EA và các component liên quan đọc/ghi dữ liệu bền vững.

MQL5 Library không triển khai WebSocket cho luồng này. Không dùng `CBaseObj::EventSend` thay cho giao thức giữa browser và Python server.

## Library\Python

`Kronos_forecast.py` dùng vendor Kronos để tính forecast; `server.py` giữ kết quả hiện tại trong RAM và đẩy tới client đang theo dõi. Server dùng cùng port cho kết nối TCP thuần của EA và WebSocket của browser; WebSocket endpoint là `/socket`.

Client đăng ký cặp bằng `watch|<symbol>|<tf>[|<symbol>|<tf>...]`. Khi nhận `watch`, server cập nhật danh sách cặp client theo dõi và gửi forecast đang giữ trong RAM nếu có. Forecast mới chỉ được gửi tới client theo dõi đúng cặp.

Protocol dùng các dòng kết thúc bằng newline, field phân cách bằng `|`. WebSocket truyền các dòng trong text frame; TCP thuần truyền trực tiếp trên socket.

- Client -> server: `watch|<symbol>|<tf>[|<symbol>|<tf>...]`; Web hiện gửi một cặp đang xem, EA có thể gửi nhiều cặp.
- Server -> client: `forecast|<symbol>|<tf>|<from_time>|<bar_time>|<open>|<high>|<low>|<close>|<volume>` cho từng bar.
- Server -> client: `forecast_end|<symbol>|<tf>|<from_time>|<bars>` báo đã gửi đủ lượt forecast; chỉ chứa các nến forecast tương lai.

Giữ contract đồng bộ giữa `server.py`, `CPythonBridge` và `Web\src\main.ts`. Thời gian trong protocol là giây theo server/MT5; không đổi đơn vị một phía.

Các file cờ phục vụ điều khiển/tiến độ worker, tách biệt với TCP socket truyền forecast: Python ghi `Python_CurrentStart.flag`, `Python_CurrentChart.flag`, `Python_CurrentSymbolTF.flag`, `Python_CurrentDone.flag` và `Python_HistoryDone.flag` để báo milestone; EA ghi `Python_Jobs.flag` để yêu cầu Python chạy lại Current sau khi thay đổi template hoặc cặp Symbol+TF.

## Database

Forecast Kronos là dữ liệu realtime, được giữ trong RAM của `server.py`; không lưu vào DB và không có schema riêng cho WebSocket.
