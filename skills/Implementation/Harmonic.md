# Implementation Harmonic Note


## Concept
 - Harmonic Pattern là một loại object. Thêm nhóm BAR_INFORMATION_HARMONIC, các type từ 401 trở đi, mỗi bài của tác giả là một type: Gartley, Bat, Butterfly, Crab, Cypher, Shark, AB=CD, Three Drives.
 - Cả 8 bài dùng chung swing 5/5 và Tolerance 0.10. Chỗ khác nhau chỉ là các tỷ lệ Fibonacci. Vì vậy dùng một judge CHarmonicPattern : CJudge (HarmonicPattern.mqh, file mới), tổ chức giống CBarPattern:
 - IsFound(type), SetJudge(list, names[], values[]), Param(name).
 Find(type, index) switch sang FindGartley, FindCypher…
 Tỷ lệ và tolerance của từng type nằm trong Setting_BarSetup, default lấy theo tác giả.
 - Swing không có param riêng cho harmonic: đọc rows của Swing High / Swing Low, như BOS đang làm.
## Working with Event
### Ai sở hữu và fire:
 - Rows swing là bit trên CBar, chủ sở hữu là CBarControl của cặp. CBarSwing báo SERIES_EVENTS_SWING khi có swing mới.
 - Harmonic chỉ đổi khi có swing mới (chính là D). Vì vậy CBarControl của đúng symbol/TF nghe SERIES_EVENTS_SWING rồi judge các type harmonic tại swing đó. Không quét lại mỗi nến.
 - Có pattern thì StoreRow rồi fire SERIES_EVENTS_HARMONIC. Đây là ID mới, contract giống SERIES_EVENTS_PATTERN: EventPack(time, type, side, is_new), dparam = TF, sparam = symbol.
## No Duplicate:
 - CHarmonicPattern đọc rows swing đã có trên bar (InformationSide(SWING_HIGH/LOW)) để lấy 5 swing xen kẽ X-A-B-C-D gần nhất. Không tính lại swing (BOS hiện đang tính lại qua CBarSwing).
 - Các điểm X..D không lưu thêm. Rows swing đã có, nên CHarmonicPattern cho thêm một method lấy điểm (time/price) từ rows. View (vẽ XABCD) và Trading (SL/TP) cùng dùng method này, đúng như BarDefines ghi: "the View builds them in RAM from these rows".
 - Listener có sẵn tự nhận:
 - CBarMarkerCollection và GUIPannel_SoundAndMessageAlerts thêm SERIES_EVENTS_HARMONIC vào danh sách ID đang lọc.
Strategy đọc rows qua slot Bar information. Việc này cũng giải quyết mục treo "Slot Bar information".
## Sync Everywhere
### Library:
BarDefines: thêm group, các type, param names và default.
CBar::InformationGroup thêm nhóm mới.
CBarControl::Judge / Prepare nhận CHarmonicPattern.
EventDefines thêm SERIES_EVENTS_HARMONIC.
Database: Setting_BarInformation thêm các type mới, Setting_BarSetup thêm param. Rows đi vào bảng BarTimeSeriesCollection như hiện tại.
### Python Library
 viết harmonic.py, dùng swing.py find_swings để tính lịch sử. Sau đó đo parity với EA.
### EA Module:### 
 - tab Candle thêm switch cho group thứ 4 (BAR_INFORMATION_GROUP_TOTAL từ 3 thành 4). Marker vẽ tại D.
### EA Web: ###  để sau.
## Thứ tự làm: ##
 - Phát hiện pattern + Event + Python + marker, đo parity với log phát hiện của từng EA gốc.
 - Strategy cho từng harmonic (mỗi bài của tác giả một Strategy), với SL/TP lấy từ các điểm X..D. Đây là mục treo "Params của event Entry", tớ sẽ trao đổi riêng khi tới bước này.
## Cần cậu chốt## 
 - Bit của row: nhóm Candle đã dùng 30/32 bit.
 - Khuyến nghị: thêm property BAR_PROP_INFORMATION_HARMONIC, mỗi group một property giống Smart Money.
Cách còn lại là nhét vào các bit trống của Smart Money.
Row đặt ở bar nào:
 - Khuyến nghị: bar của pivot D, giống swing (Shift = swing_strength). Event mang time của D, marker vẽ đúng tại D.
Lock một nến của tác giả (thấy pattern rồi chờ nến sau mới vào lệnh):
 - Swing của System chỉ có khi đã được xác nhận, nên pattern không repaint.
 - Khuyến nghị: bỏ lock. Đây là thay đổi hành vi so với tác giả, nên tớ ghi vào phần parity để backtest chứng minh (gate 0).

## Đã code đợt 1 (2026-11-23): phát hiện 9 Harmonic + 3 Chart Pattern

EA compile 0/0; Python chạy test tổng hợp (Gartley, Bat, QM, Double Top) đúng; chưa chạy trên terminal.
- [v] **Library:**
  - `BarDefines.mqh`: group `BAR_INFORMATION_HARMONIC`, `BAR_INFORMATION_CHART_PATTERN` (trước `SIGNAL`, `GROUP_TOTAL` 5); type 401–409, 501–503, `BAR_INFOR_TYPE_LAST`; param + default theo input của từng EA.
  - `Bar.mqh`: `InformationGroup` đưa type mới vào bit trống của `BAR_PROP_INFORMATION_SMART_MONEY` (bit 5–16).
  - `Judge.mqh`: `Shift()` → `Shift(type, index)`; `BarSwing.mqh`: `Strength()`, `IsWick()`.
  - `BarPattern.mqh`: `Pivots` (zigzag từ bit swing), `RuleXABCD` / `RuleABCD` / `RuleThreeDrives` / `RuleFiveDrives` / `RuleHeadShoulders` / `RuleDoubleTopBottom` / `RuleQuasimodo`, `FindPivot` (CONFIRM), `FindEarly` (FOUND), `Points`, `IsBeyond`.
  - `BarControl.mqh`: `Prepare` cho pivot pattern (param của type + Swing High / Low), `StoreRow` báo CONFIRM dù bit đã có từ FOUND, `CalculatePivotPatterns` (FOUND / INVALID một lần mỗi nến, sau mọi row của nến).
  - `EventDefines.mqh`: `SERIES_EVENTS_PATTERN_FOUND`, `SERIES_EVENTS_PATTERN_INVALID`; CONFIRM dùng `SERIES_EVENTS_PATTERN`.
  - `BarInformationManager.mqh`: tên group, catalog type / param, đổi param swing thì báo cả pivot pattern.
  - `BarMarkerCollection.mqh`: vòng type tới `BAR_INFOR_TYPE_LAST`, nghe FOUND / INVALID.
- [v] **Library\Python:** `pivot_patterns.py` (cùng luật, chỉ CONFIRM), job trong `main.py`.
- [v] **EA Module:** icon group mới ở `GUIPannel_Window_CandleInfo.mqh`; tab Candle tự thêm switch.
- [v] **Database:** rows type / param mới do `CBarInformationManager` ghi default khi EA chạy.
- [v] **View vẽ pattern như tác giả** (badge vẫn ở nến của pivot cuối): `CPivotPatternShape` (Composite, object native gắn time / price, nằm sau nến), `CBarMarkerCollection::SyncPivotPatterns` (pattern của cặp chart có pivot cuối trong view, theo Show Buy / Sell của type), điểm lấy từ `CBarControl::PivotPoints`.
  - Harmonic: 2 tam giác tô màu (X A B, B C D; AB=CD: A B C, B C D; Drives: B C D, D E F), các leg, X B, B D, chữ X..D, tên ở giữa.
  - H&S: neckline qua 2 đáy, tam giác vai trái / đầu / vai phải trên neckline, LS / HEAD / RS / NECKLINE. Double: 2 leg + neckline. QM: các leg, leg bị phá (chấm), QM line (gạch).
- [] Chạy trên terminal: kiểm rows CONFIRM của Python, FOUND / INVALID live, marker và hình vẽ.

## Vướng mắc

Xếp theo thành phần của [Workspace access policy](../AGENTS.md#workspace-access-policy). Mục chưa chốt ghi kèm khuyến nghị.

### Library
 -
 - [v] **Event của Harmonic đã đổi so với mục Working with Event ở trên:** X, A, B, C là swing đã xác nhận; D phát hiện sớm →  `SERIES_EVENTS_HARMONIC_FOUND`, swing xác nhận D →  `SERIES_EVENTS_HARMONIC_CONFIRM` (thay cho một `SERIES_EVENTS_HARMONIC`).
  - **Library\Python:** số liệu cũ chỉ tính CONFIRM (có hay không) rồi ghi DB; không tính FOUND, không có Event.
  - Live: **Library** (`CBarControl`) chủ động tính FOUND / CONFIRM trên RAM rồi SendEvent; DB do Python ghi.

- [v] **Nguồn D sớm:** PPR (1 nến phải, `SERIES_EVENTS_PATTERN` fire mỗi row, cùng chủ `CBarControl`); không dùng Fractal (`SERIES_EVENTS_SIGNAL` chỉ fire khi lật phía, cần template).
  - [] Đo sau, khi đã có Strategy: tỷ lệ FOUND → CONFIRM, tỷ lệ CONFIRM không có FOUND (PPR lọt D vì `protrude_min`) trong Strategy Tester.
- [v] **Giá D giữa FOUND và CONFIRM:** PPR chỉ cho biết nến D; giá mọi điểm X..D (cả D lúc FOUND) lấy theo `price_basis` của swing (default wick, như tác giả) → FOUND và CONFIRM cùng giá, không tính lại tỷ lệ.
- [v] **FOUND không thành CONFIRM:** `SERIES_EVENTS_HARMONIC_INVALID`, như FOUND chỉ live (RAM + Event, không vào DB). FOUND đang mở = bit FOUND trên `CBar` của D trong `swing_strength` nến gần nhất (không giữ list riêng); mỗi `SERIES_EVENTS_NEW_BAR`, nến vượt D → `CBarControl` xoá bit (`AddPatternType(type, SIGNAL_DIRECTION_NO_PATTERN)`) và fire INVALID.
- [v] **Lưu FOUND / CONFIRM:** CONFIRM là type của harmonic (401–409), row trong DB do Python ghi; FOUND chỉ có trên RAM + Event (live), không vào DB. FOUND và CONFIRM là **cùng một bit** của type trên `CBar` của D: bit có trong `swing_strength` nến sau D = FOUND; tới nến xác nhận mà bit còn = CONFIRM; không thành swing thì xoá bit = INVALID. Bit nằm trong `BAR_PROP_INFORMATION_SMART_MONEY` có sẵn; DB giữ schema.
  - Hệ quả: Strategy vào lệnh ở FOUND không backtest được từ DB; cần thì Python tính thêm FOUND sau (gate 0).
- [] **Harmonic và Chart Pattern dùng luôn `CBarPattern`, không thêm class judge mới** (No Duplicate).
  - Lý do: cả hai là N pivot xen kẽ đỉnh / đáy, pivot cuối phát hiện sớm (PPR) rồi swing xác nhận; chỉ khác luật hình học — đúng khuôn của `CBarPattern`: `Find(type, index)` switch sang `FindXxx`, param từng type ở `Setting_BarSetup` (`Param(name)`), bars của series là `m_list`.
    - Harmonic: XABCD 5 pivot, AB=CD 4, Drives nhiều hơn; luật = tỷ lệ Fibo + `Tolerance`.
    - Chart Pattern: H&S 5 pivot (vai trái, đáy 1, đầu, đáy 2, vai phải), Double Top / Bottom 3, QML 4–5; luật = độ cao tương đối + neckline.
  - MVC: Model đã có là `CBar` (bit type + side, `AddPatternType` / `InformationSide`); rows swing và PPR cũng là bit trên chính các `CBar` của `m_list` → `CBarPattern` đọc được, không tính lại. Không thêm property hay member: `CBar` đã có `m_long_prop[BAR_PROP_INTEGER_TOTAL]`, `BAR_PROP_INFORMATION_SMART_MONEY` mới dùng 5/32 bit (Momentum, Swing High, Swing Low, BOS, CHoCH). Chỉ thêm type vào `ENUM_BAR_INFOR_TYPE` + nhánh `CBar::InformationGroup` đưa type mới vào bit trống của `BAR_PROP_INFORMATION_SMART_MONEY` (như Price Action nối sau Japanese Candle trong `BAR_PROP_INFORMATION_CANDLE`). FOUND / CONFIRM cùng một bit (xem mục Lưu); row DB chỉ khi CONFIRM (Python ghi). Control = `CBarControl` (lifecycle, Event) + `CBarPattern` (luật). View đọc bit, điểm X..D dựng lại từ rows swing.
  - Thêm vào `CBarPattern`:
    - Helper chung (private) `Pivots(index, count, early, times[], prices[], highs[])`: N pivot xen kẽ từ bit Swing High / Low trên `m_list`; pivot cuối là PPR (FOUND) hoặc swing (CONFIRM); giá theo `price_basis` của swing.
    - `FindCypher`, `FindGartley`… (9 harmonic), `FindHeadShoulders`, `FindDoubleTop`, `FindQML`…; `Points(...)` và `Neckline(type, index)` cho Trading (SL/TP), View và BREAK / RETEST.
  - Phải đổi để dùng chung:
    - `CJudge::Shift()` → `Shift(type)` (virtual): nến thì 0, pivot pattern thì `swing_strength` (row CONFIRM ở nến D). `CJudge::Calculate` và `CBarSwing` gọi theo chữ ký mới.
    - `CBarControl::Prepare`: type pivot pattern lấy param của type + param Swing High / Low (như BOS / CHoCH).
  - Event: CONFIRM là row do `CJudge::Calculate` tìm → dùng luôn `SERIES_EVENTS_PATTERN` (key = type), listener sẵn có (`CBarMarkerCollection`, alert) tự nhận. Chỉ thêm ID cho phần ngoài row: `SERIES_EVENTS_PATTERN_FOUND`, `_INVALID`, `_BREAK`, `_RETEST`; thay tên `SERIES_EVENTS_HARMONIC_*` ở trên.
  - Lifecycle do `CBarControl` chạy: FOUND (live, nghe PPR) → CONFIRM (row) / INVALID (live, xoá bit FOUND); type có `Neckline` thêm BREAK → RETEST (luật kiểm "mức đang mở" chung với BOS/CHoCH/Sweep).
  - Bit: hai group (Harmonic, Chart Pattern) dùng bit trống của `BAR_PROP_INFORMATION_SMART_MONEY` (5 + 9 harmonic + 3 chart = 17/32, còn chỗ cho Sweep); không thêm property (thay khuyến nghị `BAR_PROP_INFORMATION_HARMONIC` ở mục Cần cậu chốt phía trên).
  - Library\Python: luật đặt cạnh `patterns.py` (cùng chỗ với nến), chuỗi pivot từ `swing.find_swings`.
- [] **Strategy đợt đầu vào lệnh ở CONFIRM:** engine Strategy judge theo rows tại `SERIES_EVENTS_NEW_BAR`, FOUND không phải row. CONFIRM cũng đúng concept tác giả (swing 5/5 + lock một nến), Python backtest được. Vào lệnh ở FOUND để sau (`CStrategyCollection` nghe `..._FOUND`).
- [v] **Swing:** dùng swing của System (`CBarSwing`), làm đúng concept của Reference; không chép chi tiết so `>` / `>=` của từng bài.
- [] **Chuỗi pivot dùng chung:** BOS/CHoCH đang tự tìm lại swing (`CBarSwing::FindBroken` quét lùi `STRUCTURE_LOOKBACK` 300 nến); Harmonic, Chart Pattern, Sweep cũng cần chuỗi pivot → một method chung đọc rows swing, BOS/CHoCH chuyển sang dùng (kết quả không đổi).
- [] **CHoCH chưa theo trend:** hiện là phá swing LH / HL; CHoCH chuẩn là phá ngược trend đang có. Khuyến nghị giữ, đo bằng backtest sau.
- [] **Sweep:** luật thứ hai trên "mức đang mở" (close vượt = Break, wick vượt mà close quay lại = Sweep). Tách nguồn mức (swing: bài 46; N-bar high/low: bài 50) khỏi luật Sweep: một luật, mỗi nguồn một type, param `window`, `confirm_closes`, `depth_points`, `depth_pct` (N-bar thêm `lookback`, `min_age`).
- [] **BOS của bài 46 khác System:** tác giả báo BOS lúc swing HH / LL được xác nhận, System báo lúc close phá. Concept của tác giả: trend = nhãn swing HH / LL → Strategy Liquidity Sweep đọc trend theo nhãn swing.
- [] **Chart Pattern (`CChartPattern`):** lifecycle như Harmonic, thêm `BREAK` (phá neckline = luật break của BOS/CHoCH) và `RETEST`. H&S (13. 17618): lấy concept (hình vai–đầu–vai, tolerance vai / đáy, neckline) trên swing của System; không chép cách tìm điểm bằng `ThresholdPoints`.
- [] **Param theo point:** `SL_Buffer_Pips × _Point` (46), `InpSLBufferPoints`, `InpMinSweepDepthPoints` (50) phụ thuộc symbol, cùng vấn đề pip/point ở [RiskManagement.md](RiskManagement.md#library).
- [] **SL/TP theo điểm của pattern:** mục treo "Params của event Entry" ([Concepts.md](../Notes/Concepts.md#việc-chưa-làm)).
  - Cypher: code SL = X ∓ (C − Entry), comment ghi SL = X; TP = C, TP1/TP2 chỉ vẽ.
  - Turtle Soup: TP = cạnh đối diện của range.
- [] **Strategy đọc Bar information:** `CStrategySlots` mới có `Indicator` / `Signal`; slot `COLLECTION_SERIES_ID` chưa đọc được (mục treo "Slot Bar information"; `CStrategyManager::SlotAvailable` đã nhận slot này).
  - Đề xuất: rule chung `bar_info` (`CConditionBarInfo`) đọc `InformationSide(type)` trên bar, lùi thêm `Shift()` của type (row CONFIRM ở nến D, nến vừa đóng là nến xác nhận); dùng cho mọi type Bar information (Pin Bar, BOS, Sweep…). `engine.py` có rule tương ứng.
- [] **SL/TP làm hai bước:** (a) Entry trước với SL/TP hiện có của Trading (base SL, `TakeProfitRatio`) để đo phát hiện + Entry; (b) sau đó `CTradingControl` nhận `STRATEGY_EVENT_ENTRY`, lấy điểm từ `CBarControl` (`CPivotPattern::Points`), luật SL/TP từng type theo tác giả.

### Library\Python
- [] Luật Harmonic / Chart Pattern cạnh `patterns.py`, Sweep trong `structure.py`: dùng `swing.find_swings`; cùng luật với EA (Sync Everywhere).

### Database
- [] Type mới (Harmonic FOUND/CONFIRM, Sweep, Chart Pattern) vào `Setting_BarInformation`, param vào `Setting_BarSetup`; Sync Everywhere với `BarDefines`.

### EA Module
- [] Tab Candle: switch cho group mới (`BAR_INFORMATION_GROUP_TOTAL`).
- [] View: vẽ XABCD, neckline, vùng sweep từ rows (method lấy điểm của judge), không lưu thêm.

### EA Web
- Để sau.

### Reference-only
- [] Harmonic có **9** bài, không phải 8 như mục Concept: thêm 32. 19463 **5 Drives**. Danh sách: 08 Butterfly, 15 Cypher, 27 Crab, 28 Bat, 29 Gartley, 30 AB=CD, 31 3 Drives, 32 5 Drives, 33 Shark.
- [] Chart Pattern: 13 H&S, 49 Quasimodo (QML), 53 Double Top / Bottom.
- [] Sweep: 46 Liquidity Sweep, 50 Turtle Soup.
- [] Mức theo range phiên (chưa đọc code): 09 Asian Breakout, 24 London Breakout, 41 CRT, 42 ORB.
