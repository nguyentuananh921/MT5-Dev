# Imp_Kronos

Kronos là vendor read-only, không thuộc code do V5 tự triển khai. Tài liệu này chỉ ghi phần V5 tích hợp Kronos và trạng thái theo [Working scope và Sync Everywhere](../AGENTS.md#working-scope-và-sync-everywhere); không thay thế README của vendor.

## EA Module

- [v] Nhận forecast từ Library\Python qua protocol dòng TCP trên `socket_port`; không ghi forecast vào DB.

## EA Web

- [v] Nhận forecast realtime qua WebSocket `/socket`; không ghi forecast vào DB.

## Library

- [v] Library MQL5 không có implementation Kronos riêng; không sửa hoặc fork code vendor.

## Working — Read-only (Vendor)

- [v] Nguồn vendor là [`Library\Kronos\README.md`](../../Library/Kronos/README.md); chỉ đọc và dùng như dependency theo AGENTS.md.

## Library\Python

- [v] `Kronos_forecast.py` dùng vendor Kronos để tính forecast; `server.py` giữ kết quả hiện tại trong RAM và đẩy tới client đang theo dõi.
- [v] Client đăng ký cặp đang xem bằng `watch|<symbol>|<tf>[|<symbol>|<tf>...]`. Python gửi mỗi nến forecast bằng `forecast|<symbol>|<tf>|<from_time>|<bar_time>|<open>|<high>|<low>|<close>|<volume>`, rồi gửi `forecast_end|<symbol>|<tf>|<from_time>|<bars>` để báo đủ lượt; chỉ gửi các nến forecast tương lai.
- [v] Đã thử tối ưu theo tài liệu nhưng hardware hiện tại vẫn không đáp ứng tốt; forecast live có thể thay đổi liên tục, nên không xem là kết quả ổn định.

## Database

- [v] Không lưu forecast Kronos; không thêm table hoặc schema cho dữ liệu này. Đây là kết quả live chưa ổn định, chỉ phục vụ truyền realtime.

## Skills

- [v] Chi tiết tích hợp và trạng thái theo scope được tập trung tại tài liệu này; [Python.md](../references/Python.md), [Imp_Event.md](Imp_Event.md) và [Imp_WorkingOnRamSaveToDB.md](Imp_WorkingOnRamSaveToDB.md) chỉ trỏ tới đây.

## Việc chưa làm

- [] Đánh giá lại khả năng tối ưu khi có hardware phù hợp và phép đo mới; hiện chưa có cơ sở để coi forecast là ổn định hoặc lưu bền.
