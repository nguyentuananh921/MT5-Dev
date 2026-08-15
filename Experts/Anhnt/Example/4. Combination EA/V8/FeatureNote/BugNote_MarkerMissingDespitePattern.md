# Marker không hiện dù Pattern đã detect (Alt+Hover thấy, dot marker thì không)

**Ngày:** 2026-08-15
**Trạng thái:** ROOT CAUSE ĐÃ CONFIRM (Inside Bar / `PATTERN_DIRECTION_BOTH`) — fix tạm hoãn, quay lại sau (Anhnt, 2026-08-15). 2 giả thuyết trước (stale instance, gap vị trí marker) đều SAI, đã loại trừ bằng chứng cụ thể — xem "Diễn biến điều tra" bên dưới.
**Liên quan:** phát hiện trong lúc rà [BugNote_PivotPointReversalThreshold.md](BugNote_PivotPointReversalThreshold.md), nhưng đây là bug KHÁC — không liên quan threshold, liên quan đường truyền Layer1→Layer2→Layer3.

## ROOT CAUSE (CONFIRMED)

**File:** `Services\SignalBridgeWriter.mqh:264-267` (hàm `BuildAndWriteSignalBridge`, đoạn thu thập Pattern):
```cpp
ENUM_PATTERN_DIRECTION pdir = pat.Direction();
ENUM_SIGNAL_DIR pdir_signal = (pdir == PATTERN_DIRECTION_BULLISH) ? SIGNAL_BUY :
                              (pdir == PATTERN_DIRECTION_BEARISH) ? SIGNAL_SELL : SIGNAL_NONE;
if(pdir_signal == SIGNAL_NONE) continue;   // ← bị skip, không ghi vào bridge
```
`ENUM_PATTERN_DIRECTION` (`Defines\TimeseriesDefines.mqh:122-127`) chỉ có 3 giá trị: `BULLISH`, `BEARISH`, `BOTH`. **Inside Bar là pattern DUY NHẤT trong 28 loại trả về `PATTERN_DIRECTION_BOTH`** (`BarPatternControlInsideBar.mqh:99,116,146`) — đúng bản chất, vì Inside Bar là nến consolidation/trung lập, không có thiên hướng Buy/Sell rõ ràng. Nhưng `BOTH` không khớp `BULLISH` cũng không khớp `BEARISH` → rơi vào `SIGNAL_NONE` → bị `continue`, **không bao giờ ghi vào bridge file**, dù Layer 1 (Alt+Hover) vẫn thấy pattern bình thường.

**Đã grep xác nhận**: không có pattern nào khác dùng `PATTERN_DIRECTION_BOTH` — đây là gap DUY NHẤT loại này trong toàn hệ thống. 27 pattern còn lại (PPR, Engulfing, Doji, Hammer...) đều BULLISH/BEARISH, đã tự verify trực tiếp bridge file cho PPR + Engulfing, không dính lỗi.

**Bằng chứng**: bar 2026.08.14 20:31 (Inside Bar id=1178, Alt+Hover xác nhận) — parse bridge file trực tiếp thấy **0 dòng** cho tf=1 tại 20:31/20:32 (dòng gần nhất trước/sau là 20:30 và 20:33), trong khi Data Window xác nhận `SingleBuy/Sell/MultiBuy/Sell/PatternBuy/Sell/ComboBuy/Sell` đều trống cho bar này — khớp hoàn toàn với việc bridge không hề có dữ liệu.

## Việc cần làm (PAUSED — Anhnt, 2026-08-15: quay lại sau)

Chọn hướng xử lý Inside Bar trong hệ marker Buy/Sell:
1. Thêm marker "Neutral" riêng (mở rộng bridge format thêm `dir=0`, thêm shape/màu xám trong `SignalMarkers.mq5`) — đúng bản chất nhất, tốn công nhất.
2. Bỏ qua có chủ đích (không phải bug) — giữ nguyên, document rằng Inside Bar chỉ xem qua Alt+Hover, không cần marker Buy/Sell.
3. Gán tạm 1 hướng (Buy hoặc suy từ ngữ cảnh) — ít việc nhất, mất ý nghĩa "trung lập".

## Diễn biến điều tra (2 giả thuyết đã loại trừ, để tránh lặp lại)

## Hiện tượng

Anhnt (2026-08-15): 1 cây nến (XAUUSDm M1, bar 2026.08.14 20:44) rõ ràng KHÔNG có dot marker hiện trên chart, nhưng Alt+Hover vào đúng cây đó thì hiện box "Pivot Point Reversal" (id=4915) bình thường — tức pattern đã được detect, nhưng marker (dot icon) không hiện.

## Quá trình loại trừ

### 1. Layer 1 (detect) — OK
Alt+Hover xác nhận pattern tồn tại trong `m_BarTimeSeriesCollection.GetListAllPatterns()`:
```
best.Time()=2026.08.14 20:44  best.ID()=4915  candles=3  Pivot Point Reversal
```

### 2. Layer 2 (Bridge file) — OK, đã verify trực tiếp bằng cách parse binary
File `MQL5\Files\EA Using Combination Lib V8\SignalBridge_XAUUSDm.dat`, parse thủ công theo đúng format trong `SignalBridgeWriter.mqh` (magic + update(long) + count(int) + count×{time(long),tf(int),dir(int),source(int)}):
```
magic=20260808  update=2026-08-14 20:50:00 (mới, không phải data cũ)
→ có đúng dòng: time=2026-08-14 20:44:00  tf=1(M1)  dir=1(Buy)  source=1(Pattern)
```
→ **Bridge file có đủ data đúng**, watermark fix 2026-08-10 (xem `UpdateCandlePattern.md`) hoạt động tốt, không phải nguồn bug lần này.

### 3. Layer 3 — logic code đúng trên giấy
Đọc `SignalMarkers.mq5::ComputeBar()` (D:\MT5-Dev\Indicators\Vendors\Anhnt\Custom Buildin\SignalMarkers.mq5), trace tay với input thật ở trên:
- Bucket `[20:44, 20:45)` chỉ có 1 dòng: `total_ind=0, total_pat=1, pat_buy=1`
- Rơi đúng nhánh `else if(total_ind == 0 && total_pat > 0)` → "Only patterns" → set `BufPatternBuyValue[i]` + `color_idx=1` (Buy/Lime, vì `tf==own_tf`)
- **Về lý thuyết PHẢI hiện marker "PatternBuy"** (Wingdings code 67, màu Lime)

→ Data đúng + logic đúng nhưng thực tế không hiện = nghịch lý, cần tìm ở tầng khác.

### 4. Kiểm tra file compile trên đĩa — chưa loại trừ hẳn được
```
SignalMarkers.ex5   LastWriteTime: 2026-08-12 20:51:36   (compiled)
SignalMarkers.mq5   LastWriteTime: 2026-08-10 03:48:04   (source)
```
- `.ex5` mới hơn logic "Pattern-only" (comment trong code ghi thêm từ 2026-08-08) → trên đĩa, bản compile PHẢI đã có nhánh xử lý đúng.
- Đã confirm hash SHA256 file `.mq5` trong terminal folder khớp 100% với bản dev tree `D:\MT5-Dev\Indicators\...` — không có sự khác biệt source, và **tớ (Claude) chưa hề Edit file này trong session** (chỉ Read).

### 5. Giả thuyết "stale instance" — ĐÃ LOẠI TRỪ
Test quyết định: Anhnt xoá tay SignalMarkers khỏi chart + đổi TF (M1→M30→M1) để ép `EnsureMarkerIndicatorAttached()` (`GUIPannel_Lifecycle.mqh:193`, nhánh `REASON_CHARTCHANGE`) tạo instance HOÀN TOÀN MỚI (log xác nhận handle đổi, thời điểm khớp) — **vẫn không hiện marker**. Loại trừ hẳn giả thuyết cache/stale instance.

*(Phát hiện phụ trong lúc điều tra, ĐÃ FIX 2026-08-15 — 2 lớp bug chồng nhau:*

*1. `EnsureMarkerIndicatorAttached()` chỉ tạo indicator nếu CHƯA có trên chart (early-return nếu đã thấy tên "SignalMarkers") — `ReattachSignalMarkersIndicator()` (hàm remove+re-add đúng cách) trước đó không được gọi ở bất kỳ đâu trong code. Fix: thêm `ReattachSignalMarkersIndicator()` ngay sau `SaveGUIConfigToJSON()` trong handler `m_btn_save_marker_settings.Id()`.*

*2. SÂU HƠN — root cause thật khiến fix #1 ban đầu vẫn không đủ: Anhnt đổi Buy Color → Orange rồi Yellow, Save nhiều lần, kể cả compile+attach lại cả EA lẫn SignalMarkers, chart vẫn không đổi màu. Grep toàn bộ chỗ gán `m_marker_buy_color`/`m_marker_*_code` thì chỉ có 2 nơi: default hardcode (`clrLime`...) và load từ JSON lúc khởi động — KHÔNG hề có chỗ nào ghi giá trị từ ComboBox/ColorPicker vào các biến này. Toàn bộ handler `ON_CLICK_COMBOBOX_ITEM` cho shape/color (dòng 554-627) chỉ gọi `UpdateShapePreview()`/`UpdateColorPreview()` (preview UI thôi), chưa từng "commit" vào `m_marker_*` — khác hẳn combo Sound file (dòng 628-644) commit ngay lập tức. Tức nút Save trước giờ luôn re-serialize đúng giá trị Lime/mặc định cũ, bất kể user chọn gì trên UI — code làm dở dang, phần "lưu khi bấm Save" (đúng comment cũ ghi ý định) chưa từng được viết.*

*Fix cả 2: thêm đoạn đọc `SelectedItemIndex()` của 8 combo shape + 3 combo màu, ghi vào đúng `m_marker_*`, ngay TRƯỚC `SaveGUIConfigToJSON()` + `ReattachSignalMarkersIndicator()` — toàn bộ nằm trong handler `m_btn_save_marker_settings.Id()`, [GUIPannel_Lifecycle.mqh:528-570](../Anatoli%20Kazharski/GUIPannel_Lifecycle.mqh#L528-L570). Chỉ áp dụng cho nút Save của tab Marker, không đụng 2 nút Save khác (SymbolTF, Pattern Config). CHƯA test thực tế — chờ Anhnt build+attach+thử đổi màu lại.)*

### 6. Giả thuyết "gap vị trí marker quá xa, dễ bị bỏ sót" — ĐÃ LOẠI TRỪ (không phải nguyên nhân chính)
Thêm debug trực tiếp vào `ComputeBar()`/`OnCalculate()` (`SignalMarkers.mq5`) để đo runtime thật:
- Bar 20:36: `total_ind=1 total_pat=1 own_buy=1 own_sell=1 color_idx=1 branch=Combo` → tính đúng, ra 2 lần độc lập giống hệt nhau.
- Data Window (View → Data Window) xác nhận `ComboBuy=4373.3805` tại đúng bar — khớp chính xác công thức `value_buy = low[i] - gap`.
- Anhnt confirm: bar 20:36 **CÓ marker thật**, chỉ là nằm khá xa dưới nến (`gap = (high-low)*0.5`, khá lớn) nên dễ bị bỏ sót khi nhìn lướt — không phải bug.
- Nhưng khi check tiếp bar 20:31 (Inside Bar, id=1178) thì Data Window trống HẲN cả 8 mục (Single/Multi/Pattern/Combo Buy/Sell) → khác hẳn case 20:36, dẫn tới điều tra ra root cause thật ở mục trên (bridge không có data cho bar này).

## Lưu ý kỹ thuật phát sinh (không phải bug, ghi nhớ cho lần sau)
Glob tool không quét được các path nằm trong "additional working directory" (vd `MQL5\Include\Vendors\...`, `MQL5\Indicators\Vendors\...` của terminal `D0E8209F77C8CF37AD8BF550E51FF075`) dù Read tool và PowerShell truy cập bình thường — trả về "No files found" sai. Từ nay khi cần liệt kê/tìm file trong các path dạng này, dùng PowerShell (`Test-Path`, `Get-ChildItem`) thay vì Glob.

## File liên quan
- `Services\SignalBridgeWriter.mqh:264-267` — **ROOT CAUSE ở đây**, đoạn lọc `pdir_signal == SIGNAL_NONE` bỏ qua pattern `PATTERN_DIRECTION_BOTH`
- `Defines\TimeseriesDefines.mqh:122-127` — định nghĩa `ENUM_PATTERN_DIRECTION` (3 giá trị: BULLISH/BEARISH/BOTH)
- `Timeseries\Bars\BarSeries\DCandles\BarPatternControlInsideBar.mqh:99,116,146` — pattern duy nhất trả `PATTERN_DIRECTION_BOTH`
- `MQL5\Files\EA Using Combination Lib V8\SignalBridge_XAUUSDm.dat` — bridge file, đã verify: có data đúng cho PPR/Engulfing, KHÔNG có data cho Inside Bar
- `D:\MT5-Dev\Indicators\Vendors\Anhnt\Custom Buildin\SignalMarkers.mq5` (= terminal path, cùng 1 file vật lý qua junction — không phải 2 bản riêng như tưởng lúc đầu) — Layer 3, logic đã verify đúng qua debug + Data Window. **Có debug tạm `MY DEBUG SignalMarkers::ComputeBar/OnCalculate` — cần xoá sau khi đóng bug này.**
- `Anatoli Kazharski\GUIPannel_SignalMarkers.mqh` — `EnsureMarkerIndicatorAttached()` (early-return nếu đã attached) / `ReattachSignalMarkersIndicator()` (hiện không được gọi ở đâu cả — phát hiện phụ, xem mục 5)
- [UpdateCandlePattern.md](UpdateCandlePattern.md) — tài liệu gốc về luồng Layer 1→2→3 và bug watermark đã fix trước đó (2026-08-10)
