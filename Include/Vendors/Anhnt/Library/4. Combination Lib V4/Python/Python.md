# Python (Model của Lib V4)
Các module còn lại rỗng chủ ý (Refactor Rule): code lấy từ Lib V3 Python từng mảnh khi có gì đòi.

## Chạy

Chạy EA trước (EA tạo bảng trong OnInit và tự mở Python), hoặc chạy tay:

```
python main.py
python main.py --terminal "C:\Program Files\MetaTrader 5\terminal64.exe"
```

Cần: `pip install MetaTrader5 pandas numpy`. 

## Tiến trình
- **Cấu hình đi qua DB, không qua dòng lệnh.** Bảng `Setting_PythonBridge` có hai cột `name` và `value`. Các dòng còn lại do EA ghi trong OnInit (`CPythonBridge::CreateTable`), Python chỉ đọc (`libdb.setting`), không có bản sao nào trong Python. Gồm cấu hình (`write_rows`, `store_bars`, `alive_ms`, `hung_ms`, `write_queue`, `write_flag`, `chart_symbol`, `chart_tf`), enum và define của Library (`signal_buy/sell/none`, `object_python`, `collection_series/signals`, `swing_price_basis_wick`, `structure_lookback`) và tên các file cờ (`file_current_*`, `file_history_done`, `file_jobs`). Python không chạy tiếp khi EA chưa ghi (`settings_ready`).
- EA chỉ mở MỘT Python (cha). Cha chiếm chỗ trong `Setting_PythonBridge` (hai dòng `pid` của cha, 0 là không ai, và `alive_at`) bằng cập nhật có điều kiện (`claim_python_bridge`: hai cha khởi động cùng lúc thì chỉ một cái được), rồi đọc Market Watch và mở các worker. Mỗi giây cha ghi nhịp tim, chỉ khi chỗ còn là của nó (`heartbeat_python_bridge`); mất chỗ thì cha tự thoát và ngắt các worker. Worker dừng khi chỗ không còn là của cha nó hoặc nhịp tim cũ quá 60 s; worker chết thì cha mở lại.
- **EA đóng** (`REASON_REMOVE`, `REASON_CLOSE`): EA xoá dòng (`pid = 0`), cha thấy mất chỗ trong một giây và thoát cùng worker. Đổi chart, biên dịch lại, đổi tham số thì không xoá: Python chạy tiếp, history chỉ nạp một lần. Cha thoát bình thường thì tự trả chỗ (`release_python_bridge`).
- **Cha cũ im lặng** (nhịp tim cũ quá 10 s): nếu tiến trình còn chạy và im dưới 120 s thì nó đang bận nạp history, cha mới tự dừng, EA cũng không mở thêm (`IsBusy`). Từ 120 s (lớn hơn watchdog 90 s) là treo: bị giết cùng worker bằng `taskkill /T /F`. Giết một cha đang bận chỉ làm vòng nạp history bắt đầu lại, đó là nguyên nhân Python "chạy loạn" ngày 2026-10-26.
- **Worker Current** (`--current`, một cái): chạy MỘT lượt rồi thoát (parent chỉ mở lại khi đổi symbol hoặc số job). Tính bar mới nhất của mọi cặp theo thứ tự: cặp trên chart (dòng `chart_symbol`, `chart_tf` do EA ghi trong OnInit), các cặp còn lại của `Setting_SymbolTF`, mọi cặp khác. Hai nhóm đầu ghi ngay, nhóm ba gom đủ `write_rows`. Cặp chưa có dòng `Setting_Sync`: chunk đầu (bar mới nhất), phần trước chunk là việc của History. Cặp đã có dòng mà tắt máy lâu: chunk mới không chạm `last_update` cũ thì để lại khoảng trống cho History.
- **`Setting_Sync`** (`last_update`, `lost_from_time`, `lost_to_time`, `sync_by`): `last_update` là bar mới nhất đã sync (không giảm: `MAX`). `lost_from_time .. lost_to_time` là đoạn còn thiếu cho History (`lost_from_time` 0: về tới bar đầu tiên; `0, 0`: không thiếu gì). History đi lùi từ `lost_to_time`, mỗi bước kéo nó xuống; chạm `lost_from_time` hoặc bar đầu tiên thì đặt `(0, 0)`. Live chỉ làm cặp có `last_update` mà cửa sổ `REALTIME_BARS` chạm tới, cặp còn khoảng trống lớn thì đợi Current (trả -1). EA không vẽ lại theo bảng này: nó vẽ theo Event (`SERIES_EVENTS_PATTERN`), View đọc table UNION phần RAM của series (Readme: RAM và DB).
  + Mốc của Library (`sync_by` = 30591, 30602) chỉ được ghi khi Library bàn giao cặp (bỏ khỏi `Setting_SymbolTF`) hoặc ở OnDeinit; trong phiên chúng nằm trong RAM (CSyncManager). EA chết đột ngột thì Current tính lại phần đó.
- **Worker History theo symbol** (`--symbol-id N`, số worker bằng số symbol): chỉ đi lùi trong đoạn còn thiếu của cặp đã có chunk đầu (chỉ hỏi terminal số bar của khoảng trống cộng bar ngữ cảnh khi đó là khoảng trống). Không tính chunk đầu, không tính bar mới. Khi hết việc của symbol mình thì đi giúp các cặp còn dở của symbol khác (xem "Giúp việc").
- **Worker `live`** (`--live`, một cái): bar mới của các cặp symbol + TF KHÔNG có trong `Setting_SymbolTF`. Cặp của `Setting_SymbolTF` là việc của EA/Library, Python không bao giờ tính bar mới của chúng (kể cả khi Library chậm). Kết quả của nó là để dự phòng, không ai chờ. **Live chỉ tính khi Current đã xong** (`history_done_0.flag`, Current xoá nó khi chạy lượt mới): Live đi tiếp từ chỗ Current dừng, hai worker không cùng tính một cặp. Cặp của `Setting_SymbolTF` bị bỏ qua từ đầu vòng (không hỏi terminal, không hỏi DB).
  + Tick mới (cùng luật `CNewTickObj` của Library, 2026-10-31; bên Library nó thuộc `CBarTimeSeriesDE` như DoEasy `CTimeSeriesDE`; tick series tạm không dùng nên Python cũng không có): mỗi lượt hỏi terminal một tick cho mỗi symbol (`data.fetch_last_tick`, class `NewTick`). Symbol không có tick mới thì không có nến đóng mới: bỏ qua mọi TF của nó. Không symbol nào có tick thì lượt đó không hỏi DB (`Round`, `build_jobs`). `db.pairs()` đọc theo nhịp `WORKER_CHECK_SECONDS`, không mỗi lượt.
    Không có tick trong `TICK_PAUSE_SECONDS` (60 s, giờ server ước từ tick mới nhất như `TimeTradeServer`) thì symbol nghỉ (thị trường đóng), báo một lần vào Python_Timing.txt; tick đầu tiên sau đó thì tính tiếp (như `TICK_EVENT_PAUSE` / `TICK_EVENT_RESUME`).
    Cặp chưa xong (chunk đầu chưa có, DB bận) được thử lại ở tick sau của symbol, không phải lượt sau.
  + Bàn giao: cặp bị bỏ khỏi `Setting_SymbolTF` thì Library ghi nốt (SyncDataToDB) rồi thôi tính; Live đọc `Setting_SymbolTF` mỗi lượt (`rnd.library`) nên tự tính tiếp cặp đó từ `last_update`, không cần lệnh riêng. Thêm cặp thì ngược lại.
- **Ghi:** tính song song, ghi xếp hàng một người một lúc (mutex `Local\EA_V4_SQLLite_DatabaseWrite`). Mỗi worker gom đủ `write_rows` kết quả (dòng của `Setting_PythonBridge`, lấy từ `EA_PYTHON_WRITE_ROWS` trong `Configuration` của EA) rồi mới ra xếp hàng ghi (khoảng 10 ms), hoặc sau 60 s nếu gom chưa đủ. Phần chờ ghi vẫn tính được trong `state()`, nên worker không tính lại đoạn vừa tính. Dừng bình thường thì ghi nốt phần chờ. Checkpoint của SQLite để mặc định (đặt 100 MB làm một commit đứng 9 s, đã đo).
- **EA ưu tiên:** EA giương file cờ `EA_Writes.flag` (thư mục `SQLite`) trước khi ghi; worker thấy cờ thì nhả lượt và chờ cờ biến mất (tối đa 10 s).
- **EA báo việc mới:** template hay cặp Symbol+TF thêm / xoá thì EA tạo `Python_Jobs.flag` (thư mục `SQLite`, `CPythonBridge::OnChartEvent`); process cha thấy file mỗi nhịp (`libdb.jobs_changed`) thì xoá file, dừng Current đang chạy và chạy lại ngay với việc mới, không chờ `WORKER_CHECK_SECONDS`.
- **Timeframe:** đọc bảng `timeframes` (`libdb.timeframes()`: tên -> `tf_enum`, chính là `TIMEFRAME_*` của gói MetaTrader5), không còn bảng chép tay trong `data.py`.
- **Thứ tự ghi:** EA/Library, rồi Current và Live, rồi History. Current và Live đứng trong hàng riêng (mutex `<write_queue>_Urgent`, `libdb.urgent`); History thấy hàng đó có người thì nhả lượt như với cờ của EA (tối đa 10 s).
- Mỗi worker tự báo mỗi 30 s: `calculation`, `written in the database` (bars / rows / marks), `waiting for its turn`, `terminal`, `the rest`; log trong `Files\EA V4 SQLLite\Debug` (`Python_<symbol>.txt`, `Python_live.txt`, `Python_Parent.txt`, `Python_Timing.txt`).

## Các giai đoạn
1. **OnInit complete:** worker `Current` đã làm xong bar mới nhất của cặp trên chart và của các cặp còn lại trong `Setting_SymbolTF` (đủ số nến của chart và của Manager). Chính `Current` báo "OnInit complete" trong `Python_Timing.txt` rồi làm tiếp các cặp khác. Các file cờ của `Current` cho EA, theo thứ tự: `Python_CurrentStart.flag` (bắt đầu), `Python_CurrentChart.flag` (xong cặp trên chart), `Python_CurrentSymbolTF.flag` (xong các cặp của `Setting_SymbolTF`), `Python_CurrentDone.flag` (xong mọi cặp, thoát). Cặp của `Setting_SymbolTF` xong thì Library nhận lại theo Event: CPythonBridge thấy `Python_CurrentSymbolTF.flag` thì bắn `PYTHON_BRIDGE_EVENT_SYMBOLTF_DONE`, CBarTimeSeriesCollection gọi SyncDataFromDB (CBarControl của mỗi CBarSeriesDE nạp lại dòng của cửa sổ nến series giữ, báo `SERIES_EVENTS_PATTERN_ALL`, series chuyển event lên), rồi CBarControl của mỗi series tự tính nến mới từ `last_update`. **Library chỉ đọc và tính sau mốc này** (CSyncManager::IsPythonDone): trước đó Current là người duy nhất ghi các cặp của `Setting_SymbolTF`, không ai tính chồng. `Python_CurrentSymbolTF.flag` nằm lại suốt lúc Python chạy (EA nạp lại khi Python còn chạy vẫn thấy nó), Current xoá nó khi bắt đầu lượt mới (`milestone_clear`); EA thấy `Python_CurrentStart.flag` thì bắn `PYTHON_BRIDGE_EVENT_CURRENT_START`, Library dừng tính tới DONE của lượt đó.
2. **Sau OnInit:** các worker `History` (một worker cho mỗi symbol) lấp phần còn thiếu, 1 worker `live` tính nến mới của các cặp ngoài `Setting_SymbolTF`; `live` chỉ ra xếp hàng ghi khi gom đủ `write_rows` kết quả.
   [] TẠM DỪNG từ 2026-10-29: `run_parent` (main.py) chỉ mở worker Current; vòng mở History và vai "live" đang comment. Trong lúc này EA + Library tự tính các cặp của `Setting_SymbolTF`, các cặp khác không có nến mới, khoảng trống không được lấp.
3. **Worker lịch sử hết việc thì báo "history done, going to sleep"** và tạo file cờ `history_done_<symbol_id>.flag` (thư mục `SQLite`); ngủ 5 s một lần, dậy khi có việc (template mới, symbol mới).
4. **`Current` và mọi worker `History` đã ngủ:** worker `live` đổi chế độ, một mình nên "có gì ghi nấy", không đợi đủ `write_rows`. Cha báo "history complete".

## Giúp việc
- Một cặp (symbol, TF) có các bước lịch sử nối tiếp nhau, không chia song song trong cặp. Nhưng các cặp độc lập. Symbol sâu (vàng, dầu, BTCUSD) có nhiều cặp dở; worker của symbol khác xong sớm thì không ngủ mà lấy các cặp dở đó.
- Mỗi bước của một cặp được lấy bằng khoá `pair_turn` (mutex `Local\EA_V4_SQLLite_Pair_<symbol_id>_<tf_enum>`, thử rồi bỏ qua, không chờ): hai worker không bao giờ ở cùng một cặp. Worker chết thì khoá tự nhả.
- Thứ tự: các cặp của symbol mình trước (xoay vòng), rồi cặp của symbol khác, TF ngắn (sâu) trước. Mỗi bước ghi xong (kết quả và dấu tiến độ) trước khi nhả khoá, để worker khác thấy đúng điểm đã tới.
- Cặp mà worker thấy hết lịch sử thì bỏ qua 60 s rồi xem lại.

## Quy tắc ngữ cảnh (mọi job, mọi worker)
- Mỗi job khai hai số: `context` (số nến cần ở phía trước một nến) và `right` (số nến cần ở phía sau, ví dụ swing được xác nhận sau `strength` nến).
  + Pattern: `patterns.CONTEXT`. Momentum: `momentum.context(params)`. Swing: `swing.context(params)` cho cả `context` và `right`.
  + Indicator: `indicators.context(params)` = `max(WARMUP_BARS, WARMUP_PERIODS × chu kỳ dài nhất)`, hiện là `max(1000, 10 × chu kỳ)`. Shift không phải chu kỳ.
- Worker tính đoạn `[từ .. tới]` thì hỏi `[từ - context .. tới + right]`, nhưng chỉ ghi kết quả của đoạn của mình (INSERT OR IGNORE: chỗ chồng lấn không trùng dòng).
  + Current và Live: `bars_needed` = số nến từ `last_update` cũ nhất của các job của cặp tới nến đóng mới nhất (tối đa `CHUNK_BARS` / `REALTIME_BARS`) + `context + right` lớn nhất. Cặp có job chưa sync gì: chunk đầu `CHUNK_BARS`. Nhiều nến mới hơn giới hạn là khoảng trống: Current đánh dấu cho History, Live trả -1.
  + Current (chunk đầu): `context` nến cũ nhất không được tính, `lost_to_time` đặt ở nến thứ `context` để History tính lại.
  + Live: swing của nến cũ được xác nhận bây giờ thì ghi bây giờ (`since` so với nến xác nhận).
  + History: để lại `context` nến cũ nhất cho bước sau; job có `right` lấy thêm `right` nến sau chunk.
- Library phải theo cùng quy tắc (Readme: cả hai phía tính như nhau): luật của pattern và Momentum nằm ở `CBarPattern` (= `patterns.py`, `momentum.py`), luật của swing ở `CBarSwing` (= `swing.py`), BOS / CHoCH ở `CBarBOS`, `CBarCHoCH` dùng `CBarSwing::FindBrokenHigh / FindBrokenLow` (= `structure.py`, `lookback()` đọc `STRUCTURE_LOOKBACK` từ DB), CBarControl điều phối, giữ dòng và ghi DB.

## Đổi tham số thì tính lại (LÀM DỞ, cần thống nhất)
- `CBarInformationManager` gửi `BAR_INFORMATION_MANAGER_EVENT_SETUP_CHANGED` khi đổi tham số của một loại. CBarTimeSeriesCollection nghe: CBarControl của mỗi CBarSeriesDE bỏ dòng của type trên RAM ngay (báo PATTERN_ALL, series chuyển event lên), dòng trong table của MỌI cặp và mốc `Setting_Sync` được xoá dần theo timer (Reset_, `CSyncManager::ResetStep`). Template indicator mới thì có id mới nên tự được tính (chunk đầu rồi lịch sử).
- Xoá xong mọi type đang chờ thì CBarTimeSeriesCollection gửi `BAR_INFORMATION_MANAGER_EVENT_RESET_DONE`; `CPythonBridge::OnChartEvent` tạo `Python_Jobs.flag`, process cha chạy lại Current. Báo sau khi xoá xong, không báo lúc đổi tham số: Current chạy sớm thì mark vừa ghi sẽ bị bước xoá tiếp theo xoá mất.
- [] Chưa có: cờ "đang tính lại" lưu trong `Setting_BarInformation` (hàng đợi `m_reset_types` hiện chỉ ở RAM).
- Ý định: đổi tham số của một nguồn (một `type_infor` hoặc một `template_id`) thì xoá dòng kết quả và dòng `Setting_Sync` của đúng nguồn đó (mọi cặp), rồi cờ "đã ngủ" của các worker lịch sử bị xoá để chúng dậy tính lại chỉ nguồn đó. Chỉ tính lại một nguồn trong 41, nên khoảng 2–3% công việc của lần đầu, không phải tính lại toàn bộ.
- Việc xoá nên do một nơi làm (CSyncManager) khi nghe sự kiện, không để Python tự đoán.

## Quy tắc chung: Python tuân thủ CommonRule như EA + Library
- Python là Controller thứ hai của cùng DB: tên hằng, hàm, cột phải đồng bộ với table và class tương ứng ở phía MQL (Sync Everywhere), để nhìn tên biết maintain cái gì.
- No Duplicate: không có bản sao giá trị của EA trong Python; cái gì EA quyết thì đọc từ DB (`Setting_PythonBridge`, `Setting_BarInformation`, `Setting_BarSetup`...). Chỗ còn chép tay phải ghi trong Update.md.
- Mỗi thay đổi ở phía MQL (tên table, cột, enum, cách chia việc) phải rà lại phía Python cùng lúc, và ngược lại (Update & Implementation Rule).
- Loại indicator của template: bảng `indicators` (EA + Library tạo, `CIndicatorsCollection::OnInitEvent / SyncDataToDB`), Python chỉ đọc: `libdb.templates()` nối `Setting_IndicatorTemplate` với `indicators` qua `type_enum`, lấy `type_name` (ENUM_INDICATOR bỏ IND_: "MA", "BANDS"...) và `params_total`. `indicators.PARAM_KEYS` (khoá theo `type_name`) chỉ giữ tên Python đặt cho từng tham số theo thứ tự form EA (khoá nội bộ của hàm tính); số tham số khác `params_total` thì không tính. Không còn cắt chữ cột `display`.
- Chỗ chép tay bắt buộc: đường dẫn DB (Python phải mở file trước khi đọc được gì từ DB). `libdb.py` dùng đúng tên macro của `Services\DELib\DatabaseDELib.mqh`: `LIB_DATABASE_FOLDER` ("SQLite"), `LIB_DATABASE_FILE` ("<program>_Common.sqlite3"), `LIB_ACCOUNTS_FOLDER` ("Accounts"); `PROGRAM_NAME` = MQL_PROGRAM_NAME. Đổi bên MQL thì đổi ở đây. `LIBDB_FILE` chỉ là đường dẫn đặt tay khi chạy Python riêng (EA không gửi).
- Còn là khoá (không phải giá trị): tên table (`TABLE_*`), tên tham số (`PARAM_*` = `BAR_PARAM_*`), tên type (`NAME*` = `Setting_BarInformation.name`).
- [] Rà soát tên các hàm `write_result`, `flush_results`, `state` so với `SyncDataToDB`, `SyncDataFromDB`, `Ranges`.

## Đã thử và không làm: một worker cho mỗi (symbol, TF) = 294 worker
- Máy 15,7 GB RAM, mỗi tiến trình Python khoảng 103 MB: 294 tiến trình cần khoảng 30 GB.
- Tổng thời gian bị giới hạn bởi một người ghi: cộng thời gian ghi của các worker bằng 97% thời gian chạy (1373 s trên 1418 s), thêm worker không nhanh hơn. Phần đuôi (symbol sâu chạy một mình) được xử lý bằng "Giúp việc".

## Python làm gì
- Phần History: mọi Symbol của `symbols` (account này, có `symbol_id`) x mọi TF của bảng `timeframes`, tới bar đầu tiên.
- `symbol_base` / `symbols` chỉ đọc (2026 1101: `symbol_base` = symbol duy nhất XAUUSD, `symbols` = symbol của từng account XAUUSDm + `symbol_id` vào `symbol_base`, bỏ `symbol_account`): Library (`CSymbolsCollection::OnInitEvent` -> `RegisterSymbol`, tự thêm tên bỏ hậu tố vào `symbol_base`) đăng ký symbol của chart và Market Watch trong OnInit (2026 1031: việc nhỏ, chuyển từ Python sang; bỏ `register_market_watch`, `register_symbols`, `find_symbol`, `canonical` của `libdb.py` và vòng `MARKET_WATCH_SECONDS` của `main.py`).
- Phần Live: chỉ các cặp không có trong `Setting_SymbolTF`.
- Chỉ làm cho account đang login: tìm dòng của nó trong `accounts` theo `login` + `server` (`current_account`) để lấy `account_key`, không tự tính. Chưa có dòng (EA chưa chạy OnInit trên account này) thì không làm gì và đợi. Các dòng account khác trong bảng không được đụng tới.
- Ghi kết quả vào file của account (`Accounts\<account_key>.sqlite3`): `BarSeriesDE`, `BarTimeSeriesCollection`, `SignalsCollection`.
- Ghi đã sync từ đâu đến đâu vào `Setting_Sync` (file Common): `last_update`, `lost_from_time`, `lost_to_time`, `sync_by`. Số của `sync_object` và `sync_by` lấy từ `CommonDefines.mqh` (hằng số ở đầu `libdb.py`).

## Đã có
- `data.py` lấy nến từ terminal, `libdb.py` đọc/ghi DB, `main.py` vòng lặp.
- `patterns.py`, `momentum.py`, `swing.py`, `structure.py` tính các loại thông tin; `indicators.py`, `signals.py` tính tín hiệu indicator; `parity.py` so với buffer của MT5.
