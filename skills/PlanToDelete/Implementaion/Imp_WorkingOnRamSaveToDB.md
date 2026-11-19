# Imp_WorkingOnRamSaveToDB

Concept: [Concept_WorkingOnRamSaveToDB.md](../concept/Concept_WorkingOnRamSaveToDB.md).

## EA Module

- [v] **Đã có luật chỉ ghi Setting qua Manager/Library:** GUIPannel không ghi DB thẳng.
- [v] **Đã có `Setting_PythonBridge`:** EA tạo hằng số trong OnInit và build `account_key`.
- [v] **Đã có RAM object:** bar mới tính trên RAM; loại nặng nhận kết quả từ Python qua socket.
- [v] **Đã quy ước `account_key`:** EA build một lần từ company + server + login, không tự build ở module khác.

## Library

- [v] **Đã có quyền CREATE table:** Manager/Collection tạo table và lưu `Setting_*`, kể cả khi live.
- [v] **Đã có danh mục/table chung:** `accounts`, `symbols`, `symbol_base`, `timeframes`, `indicators`.
- [v] **Đã có save lifecycle Trading:** `CTradingControl` ghi `TradingOrderDetail` cho thông tin MT5 không giữ lại sau khi Position/terminal đóng.
- [v] **Đã quy ước RAM object:** dùng object trong `CArrayObj`, không giữ `struct S…Row m_rows[]` làm member.
- [v] **Đã quy ước method DB:** `ReadDataFromDB`, `UpdateDataToDB`, `Read_RAM`, `Update_<Table>_Setting`, `Create_<Thing>`.

## Library\Python

- [v] **Đã có kết quả lưu DB:** `SignalsCollection`, `BarTimeSeriesCollection`, `StrategyCollection`.
- [v] **Đã có Setting_Sync:** Python đánh dấu state/tác vụ cần tính lại.
- [v] **Đã chỉ làm cho account đang login:** dùng `account_key` do EA tạo.
- [v] **Kronos forecast:** không lưu DB; tích hợp và luồng truyền realtime xem [Imp_Kronos.md](Imp_Kronos.md).

## EA V5\Web

- [v] **Chỉ đọc Setting và danh mục:** `/strategies`, `/symbols`, `/timeframes`.
- [v] **Chưa ghi kết quả backtest:** thay đổi Setting sau backtest và route cập nhật Setting còn chưa làm.

## Database

- [v] **Đã có Single Source of Truth:** dữ liệu cần giữ lưu DB; RAM là bản sao làm việc.
- [v] **Đã có phân công ghi theo module:** chỉ module được ghi ở table mới được ghi; module khác chỉ đọc.
- [v] **Đã loại dữ liệu thô khỏi DB:** tick/bar không lưu, live hỏi lại terminal.
- [v] **Kronos forecast không thuộc dữ liệu lưu bền:** xem chi tiết và trạng thái theo scope ở [Imp_Kronos.md](Imp_Kronos.md).
- [v] **Nguồn DB dùng chung cho Library\Python:** `Setting_PythonBridge` (`name`, `value`) đọc qua `libdb.setting()`; timeframe lấy từ `timeframes` qua `libdb.timeframes()`; loại indicator và `level_high` / `level_low` lấy từ `indicators` qua `libdb.templates()`.

## Việc chưa làm

- [] Chốt quyền ghi table theo từng implementation cụ thể.
- [] Hoàn tất route EA V5\Web ghi Setting sau backtest thành công.
- [] Hoàn tất cơ chế Setting được Python tính lại sau khi Web thay đổi.
