# Python (Library\Python)

Ai tính, ai ghi DB: xem `WorkingOnRamSaveToDB.md`.

## Luật
- Theo cùng CodingRule.md: đặt tên theo table/class phía MQL.
- Không chép tay hằng số: đọc từ DB (`Setting_PythonBridge`, `timeframes`, `indicators`).
- Python làm việc nặng; join, đăng ký symbol và việc nhỏ thì Library làm.

## Chạy

EA tự mở Python trong OnInit (`--database`, giữ trong biến môi trường `LIBDB_FILE` cho các worker). Chạy tay:

```
python main.py --database "<file dưới MQL5\Files>"
python main.py --database "<...>" --terminal "C:\Program Files\MetaTrader 5\terminal64.exe"
```

Cần: `pip install MetaTrader5 pandas numpy`; Kronos thêm `torch einops huggingface_hub safetensors`.

## Cấu hình
- Đi qua DB, không qua dòng lệnh: `Setting_PythonBridge` (`name`, `value`), EA ghi trong OnInit (`CPythonBridge::CreateTable`), Python chỉ đọc (`libdb.setting`). Python không chạy khi EA chưa ghi (`settings_ready`).
- Timeframe đọc từ bảng `timeframes` (`libdb.timeframes()`), loại indicator từ bảng `indicators` (`libdb.templates()`, kèm `level_high`/`level_low`).
- Chỉ làm cho account đang login; `account_key` theo WorkingOnRamSaveToDB.md mục 4. Chưa có thì đợi.

## Tiến trình
- **Cha** (một cái): chiếm chỗ trong `Setting_PythonBridge` (`pid`, `alive_at`) bằng cập nhật có điều kiện, ghi nhịp tim mỗi giây, mở và mở lại các worker. Mất chỗ thì thoát cùng worker. Cha cũ im quá 10 s mà chưa tới 120 s là đang bận, cha mới tự dừng; từ 120 s là treo, bị `taskkill /T /F`.
- **EA đóng** (`REASON_REMOVE`, `REASON_CLOSE`): EA đặt `pid = 0`, cha thoát. Đổi chart, compile lại, đổi tham số: Python chạy tiếp.
- **Worker** dừng khi chỗ không còn của cha hoặc nhịp tim cũ quá `PARENT_GONE_SECONDS` (60 s). Cha mở: `current`, `live`, `server` (`main.py` `run_parent`). History đang tạm dừng.

| Worker | Việc |
|---|---|
| `current` | Một lượt rồi thoát. Bar mới nhất của mọi cặp theo thứ tự: cặp trên chart (`chart_symbol`, `chart_tf`), cặp của `Setting_SymbolTF`, các cặp khác. Cặp chưa có `Setting_Sync`: chunk đầu (`CHUNK_BARS`). |
| `live` | Bar mới của mọi cặp (kể cả `Setting_SymbolTF`), chỉ khi Current đã xong (`history_done_0.flag`). Mỗi lượt hỏi terminal một tick mỗi symbol (`NewTick`); không tick mới thì bỏ qua symbol; không tick trong `TICK_PAUSE_SECONDS` (60 s) thì symbol nghỉ. Tính y hệt EA và ghi DB. |
| `history` (`--symbol-id N`, tạm dừng) | Đi lùi trong đoạn còn thiếu của cặp đã có chunk đầu. Hết việc thì giúp cặp dở của symbol khác (khoá `pair_turn`), rồi tạo `history_done_<symbol_id>.flag` và ngủ. |
| `server` (`server.py --parent-pid`) | Trang Web, nến, Kronos. |

## Socket (một port `socket_port`, 8765)
- Chỉ cho thứ không lưu DB: Kronos forecast và trang Web. Kết quả có trong DB thì EA đọc DB, không qua socket.
- 4 byte đầu là HTTP: trình duyệt (`web_folder` = `EA V5\Web\dist`, `/timeframes`, `/bars`, WebSocket `/socket`). Còn lại: EA, dòng `\n`, trường `|`.
- Client gửi `watch|<symbol>|<tf>[|<symbol>|<tf>...]`.
- Python gửi `forecast|<symbol>|<tf>|<from_time>|<bar_time>|o|h|l|c|v`, `forecast_end|<symbol>|<tf>|<from_time>|<số nến>` (chỉ nến tương lai).
- Kronos (`Kronos_forecast.py`): nạp từ `Library\Kronos` (vendor), 512 nến đóng → 24 nến (`FORECAST_BARS`), chỉ ở RAM của `server.py`.

## Setting_Sync
- Tiến độ ghi DB của Python: Python tính y hệt EA và tự ghi kết quả cùng mốc. EA tính trên RAM để làm việc, không ghi mốc.
- `last_update`: bar mới nhất đã ghi (chỉ tăng). `lost_from_time .. lost_to_time`: đoạn còn thiếu cho History (`0, 0`: không thiếu).
- Live tính tối đa `REALTIME_BARS` (5000) nến mới mỗi cặp; cửa sổ không chạm `last_update` là khoảng trống: Live trả -1, Current lấp khi chạy lại (History đang tạm dừng).
- Trước khi nói data đã sẵn sàng hay đang chờ: grep log của worker hôm nay và đọc `Setting_Sync`.

## Ghi
- Tính song song, ghi một người một lúc (mutex tên `write_queue` trong `Setting_PythonBridge`). Worker gom đủ `write_rows` dòng, hoặc sau `WRITE_AGE_SECONDS` (60 s), rồi mới ghi.
- Thứ tự: EA (setting), rồi Current và Live (hàng `<write_queue>_Urgent`), rồi History.
- EA ưu tiên: EA giương file cờ (`write_flag`) trước khi ghi; worker nhả lượt, chờ tối đa 10 s.
- EA báo việc mới (template, cặp Symbol+TF): file cờ `file_jobs`; cha xoá file, chạy lại Current ngay.
- File cờ tiến độ của Current (`file_current_*`, theo thứ tự): Start, Chart, SymbolTF, Done. Cờ SymbolTF → `CPythonBridge` fire `PYTHON_BRIDGE_EVENT_SYMBOLTF_DONE` → các collection nạp lại từ DB; `CURRENT_START`: dừng tới DONE của lượt đó.
- Current xong (Done) thì mọi cặp (mọi symbol × mọi TF) đã có trong DB, Live tính tiếp và ghi mọi cặp. EA chuyển Symbol+TF chỉ đọc DB. Current chỉ chạy lại khi có việc mới (`file_jobs`: template, symbol, cặp `Setting_SymbolTF` thêm/xoá).
- Ghi vào file của account (`Accounts\<account_key>.sqlite3`): `BarTimeSeriesCollection`, `SignalsCollection`, `StrategyCollection`. `Setting_Sync` ở file Common. Nến không lưu DB.
- Log: `MQL5\Files\<program>\Debug` (`Python_<symbol>.txt`, `Python_live.txt`, `Python_Parent.txt`, `Python_Timing.txt`), mỗi worker báo mỗi 30 s.

## Quy tắc ngữ cảnh (mọi job, mọi worker)
- Mỗi job khai `context` (số nến cần phía trước) và `right` (số nến cần phía sau). Pattern: `patterns.CONTEXT`; Momentum: `momentum.context(params)`; Swing: `swing.context(params)`; Indicator: `indicators.context(params)` = `max(WARMUP_BARS, WARMUP_PERIODS × chu kỳ dài nhất)`.
- Tính đoạn `[từ .. tới]` thì đọc `[từ - context .. tới + right]`, chỉ ghi kết quả trong đoạn của mình (INSERT OR IGNORE).
- Current (chunk đầu): `context` nến cũ nhất không tính, `lost_to_time` đặt ở nến thứ `context` cho History. Live: swing của nến cũ được xác nhận bây giờ thì ghi bây giờ.

## File
| File | Việc |
|---|---|
| `main.py` | Cha, worker, vòng lặp |
| `libdb.py` | Đọc/ghi DB, mutex, file cờ |
| `data.py` | Nến, tick từ terminal |
| `patterns.py`, `momentum.py`, `swing.py`, `structure.py` | Bar information |
| `indicators.py`, `signals.py` | Tín hiệu indicator |
| `Strategy\<Name>.py` | Điểm vào/ra của strategy (vd `Profitunity.py`) |
| `server.py`, `hub.py` | Web, socket, hub đẩy dòng |
| `Kronos_forecast.py`, `Kronos_finetune.py` | Kronos |
| `parity.py` | So với buffer của MT5 |
| `condition.py`, `fvg.py`, `model.py`, `movement.py`, `supplydemand.py`, `tradesync.py`, `trendline.py`, `zone.py` | Rỗng chủ ý, lấy từ Lib V3 khi cần |
