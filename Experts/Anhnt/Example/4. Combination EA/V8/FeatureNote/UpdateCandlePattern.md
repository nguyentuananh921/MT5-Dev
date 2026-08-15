# Update Candle Pattern — 2 khái niệm & luồng update

## 2 khái niệm (đừng nhầm lẫn 2 cái này)

1. **Live (Bar 0 đang hình thành, chưa đóng)** — `CGUIPannel::CheckCandlePatternAlerts`/`DetectPatternOnBar0`, dùng OHLC "fake" của nến hiện tại để check pattern real-time trước khi nến đóng. **Đang lỗi, tạm dừng** — xem mục "Bug Live (tạm dừng)" bên dưới. Đây là chuyện Sound/Message alert cho bar đang chạy, KHÔNG liên quan tới việc marker có hiện trên chart hay không.
2. **UpdatePatternOnNewBar (nến đã đóng, thành lịch sử)** — chạy mỗi khi có NewBar đóng ở **bất kỳ TF nào** của Symbol đang mở trên Chart (không chỉ TF đang active). Đây là luồng quyết định marker Pattern có hiện lên chart real-time hay không. **Đã xác nhận bug + fix xong** (2026-08-10) — xem mục "Luồng update" + "Bug đã fix" bên dưới.

Anhnt (2026-08-10): *"Việc Live tức là cái Bar0 chưa đóng, cái đấy đang lỗi và chúng ta đang tạm dừng. Còn việc UpdatePatternOnNewBar là chạy mỗi khi có NewBar ở bất kỳ TF nào của Symbol trên Chart ấy."*

---

## Luồng update đầy đủ (3 Layer, cho khái niệm 2 — UpdatePatternOnNewBar)
Layer 1 (Pure Data: detect + lưu pattern)
   → Layer 2 (EA: ghi Bridge file)
      → Layer 3 (SignalMarkers.mq5: đọc Bridge + vẽ marker trên chart)```

### Layer 1 — Detect + lưu (`BarPatternsControl.mqh` / `BarSeriesDE.mqh`)
2 đường ghi vào cùng 1 nơi (`m_list_all_patterns` của `CBarPatternControl`, per-series thật — lấy qua `bar_series.GetPatternsCtrlObj()`):
- **Historical backfill** — `CreateAndRefreshPatternList()` (quét TOÀN BỘ lịch sử, 28 loại pattern), đồng bộ, chạy tại `OnInitEvent` (1 series - TF chart lúc khởi động), `LoadConfigurationFromJSON` loop (N series - mọi Symbol+TF khác trong Config), `OnChartEvent` (1 series - TF vừa đổi).
- **Update khi NewBar** — `UpdateAll()` → `UpdatePatternList(n_bars=4)` (rẻ, chỉ quét 4 nến gần nhất), wire vào nhánh `IsNewBarManual()` của `BarSeriesDE.mqh:428-429`, chạy cho **mọi series** đã đăng ký pattern registry — tức mọi TF của symbol, không riêng TF đang active trên chart.

Đã xác nhận (2026-08-10): backfill và new-bar KHÔNG lệch nhau, cùng ghi 1 list — phần Layer 1 này đúng, không phải nguồn bug.

### Layer 2 — EA ghi Bridge file (`CSignalBridgeWriter::BuildAndWriteSignalBridge`, `V8/Services/SignalBridgeWriter.mqh`)
- Gọi mỗi `OnTimerEvent` (`GUIPannel_Lifecycle.mqh:276`) — liên tục, không phải chỉ lúc OnInit.
- Đọc pattern **trực tiếp** từ `m_BarTimeSeriesCollection.GetListAllPatterns()` (Layer 1) — **hoàn toàn độc lập** với `CheckCandlePatternAlerts`/`DetectPatternOnBar0`/`m_BarPatterns_Control` (mấy cái đó chỉ phục vụ khái niệm 1 - Live/Sound-Message, không liên quan tới việc ghi Bridge).
- Có 1 cổng watermark (`fresh` / `newest_seen` vs `m_signal_bridge_last_time`) để tránh ghi lại toàn bộ mỗi lần gọi — đây chính là chỗ có bug (xem bên dưới).

### Layer 3 — SignalMarkers.mq5 đọc & vẽ (`MQL5/Indicators/Vendors/Anhnt/Custom Buildin/SignalMarkers.mq5`)
- `OnInit`: đọc bridge file 1 lần, set Timer 250ms.
- `OnTimer` (mỗi 250ms): chỉ đọc header (magic + `last_update`), so với watermark cũ — đổi mới mới đọc lại full (`ReadBridgeFile()` → `g_dirty=true`).
- `OnCalculate`: nếu `g_dirty` thì quét lại toàn bộ bar (rẻ, data ít); không thì chỉ tính bar mới nhất.
- Đã xác nhận (2026-08-10): cơ chế này tự động bắt thay đổi bridge file liên tục, reactive đúng — **không phải nguồn bug**.
- Lưu ý: shape (Single/Multi/Pattern/Combo Buy-Sell) tổng hợp từ TẤT CẢ TF trong 1 bucket thời gian; color chỉ lấy từ own-TF của chart — nên marker Pattern của 1 TF khác vẫn hiện trên chart hiện tại (đúng ý "bất kỳ TF nào của Symbol"), chỉ khác màu (gray/non-related nếu khác own-TF).

---

## Thiết kế ban đầu (lịch sử) — Hệ thống 8 Signal Markers

Plan gốc khi mới xây hệ thống marker (trước khi bug ở trên xuất hiện), giữ lại làm tài liệu tham khảo — một số điểm đã lệch so với code thực tế hiện tại (ghi rõ bên dưới).

**Nguyên tắc phân loại marker** (tại mỗi bar `t`, gom tín hiệu):
- `ind_buy_count`/`ind_sell_count` — số tín hiệu Buy/Sell từ Indicator.
- `has_pattern_buy`/`has_pattern_sell` — boolean có Pattern Buy/Sell trong bar (ban đầu định thiết kế dạng boolean gộp, KHÔNG đếm số lượng).
- Hướng: có indicator → majority direction của indicator (pattern chỉ là secondary); chỉ có pattern → theo pattern direction.
- 8 shape family: `!has_pattern && total_ind==1` → Single Buy/Sell; `!has_pattern && total_ind>1` → Multi Buy/Sell; `has_pattern && total_ind==0` → Pattern Buy/Sell; `has_pattern && total_ind>0` → Combo Buy/Sell.

**Component đã triển khai theo plan này:**
- `GUIPannel_TabSettingMarker.mqh` — 8 dòng ComboBox + Preview shape (Single/Multi/Pattern/Combo × Buy/Sell), lưu/đọc `Config_Setting.json`, `EnsureMarkerIndicatorAttached()` truyền đủ 8 mã Wingdings.
- `SignalMarkers.mq5` — 8 plot `DRAW_COLOR_ARROW`, 16 buffers (value + color_idx mỗi plot), nhận 8 input mã icon. Logic `ComputeBar()` đếm `ind_count`/`pat_count` trong bucket và chọn shape đúng như 4 rule trên (xem "Luồng update" → Layer 3).

**Điểm ĐÃ LỆCH so với plan gốc (Q2 trong plan gốc quyết định 1 kiểu, code thực tế làm khác):**
- Plan gốc quyết định: *"1 signal per closed bar"* — nếu 1 bar có nhiều pattern (vd Hammer+Doji cùng hướng Buy) thì gộp lại ghi **1 dòng** vào bridge, lấy majority direction nếu pattern nhiều hướng khác nhau; bridge file **không có** field `source_type`; **live bar 0 patterns KHÔNG ghi vào bridge**.
- Code thực tế (`SignalBridgeWriter.mqh`, bridge format v2 20260808): ghi **MỖI pattern instance riêng** thành 1 dòng (không gộp theo bar), có thêm field `source` (0=Indicator/1=Pattern) để `SignalMarkers.mq5` tự đếm `pat_count` phía đọc thay vì phía ghi. Live bar 0 vẫn không ghi (đúng plan gốc) nhưng lý do giờ là vì `GetListAllPatterns()` chỉ chứa closed-bar patterns (Layer 1 chỉ `AddPatterns()` cho bar đã đóng), không phải vì cố tình exclude ở Layer 2 như plan gốc mô tả.
- Kết luận: 2 cách đều ra cùng kết quả hiển thị (SignalMarkers tự đếm lại từ field `source`), nhưng cách hiện tại đơn giản hơn ở Layer 2 (không cần logic gộp/majority ở phía ghi).

---

## Bug đã fix (2026-08-10): Pattern mới không đẩy được watermark ở Layer 2

**Triệu chứng**: marker Pattern trên chart chỉ hiện sau khi Attach lại EA (chạy lại full backfill); lúc EA chạy liên tục, Pattern mới hình thành trên NewBar (bất kỳ TF nào của Symbol) không được vẽ thêm.

**Nguyên nhân** (`SignalBridgeWriter.mqh`, hàm `BuildAndWriteSignalBridge`):
- `newest_seen` (mốc thời gian dùng để quyết định có ghi lại bridge hay không) chỉ được tính từ lịch sử tín hiệu **Indicator** (dòng 127-163 cũ) — hoàn toàn không tính đến Pattern.
- Cổng chặn `if(!fresh && newest_seen <= m_signal_bridge_last_time) return;` → nếu không có Indicator signal mới (chỉ có Pattern mới) thì hàm return sớm, không bao giờ chạm tới đoạn thu thập Pattern (Layer 1 → Bridge) phía dưới.
- Lúc Attach lại EA: `m_signal_bridge_symbol` reset về rỗng → `fresh=true` ngay lần gọi đầu → bỏ qua cổng chặn → ghi lại toàn bộ (gồm cả Pattern) một lượt → đúng như Anhnt quan sát.

**Fix đã áp dụng**: thêm 1 đoạn quét `m_BarTimeSeriesCollection.GetListAllPatterns()` (lọc theo symbol) để cập nhật `newest_seen` từ `pat.Time()`, chèn ngay trước cổng chặn (giữa đoạn quét Indicator cũ và dòng `if(!fresh && ...)`). Giờ Pattern mới cũng làm watermark nhảy lên, không bị chặn ghi nữa.

```cpp
// Fix (2026-08-10): newest_seen above only scanned indicator/BBand signal history, so a
// NEW PATTERN with no accompanying new indicator signal never advanced the watermark - the
// early-return below then skipped writing the bridge, and the pattern marker only showed up
// after a re-attach reset m_signal_bridge_symbol (forcing fresh=true). Patterns must also
// count toward newest_seen.
CArrayObj *all_patterns_wm = m_BarTimeSeriesCollection.GetListAllPatterns();
if(all_patterns_wm != NULL)
 {
  int pat_total_wm = all_patterns_wm.Total();
  for(int p = 0; p < pat_total_wm; p++)
   {
    CBarPattern *pat_wm = all_patterns_wm.At(p);
    if(pat_wm == NULL || pat_wm.Symbol() != sym) continue;
    datetime pt = pat_wm.Time();
    if(pt > newest_seen) newest_seen = pt;
   }
 }

if(!fresh && newest_seen <= m_signal_bridge_last_time)
   return;
```

**Chưa test thực tế** — cần Anhnt compile lại, để EA chạy liên tục qua ít nhất 1 NewBar đóng (bất kỳ TF nào của symbol trên chart), xác nhận marker Pattern tự hiện lên mà không cần Attach lại hay đổi TF.

---

## Bug Live (tạm dừng — KHÔNG phải phạm vi UpdatePatternOnNewBar)

`CGUIPannel::m_BarPatterns_Control` (set qua `SetPatternsControl(timeSeriesEngine.GetPatternsControl())`) trỏ vào object TEMPLATE cấp Engine (`m_symbol=""`, default-constructed, dùng để seed pattern registry cho series mới) — KHÔNG PHẢI object per-series thật (`bar_series.GetPatternsCtrlObj()`). `DetectPatternOnBar0()` (`GUIPannel_SoundAndMessageAlerts.mqh:455-473`) dùng nhầm object template này, so `ctrl.Symbol()==::Symbol()` không bao giờ khớp (""≠ symbol thật) → luôn trả `WRONG_VALUE`.

Hệ quả: `CheckCandlePatternAlerts()` (`GUIPannel_SoundAndMessageAlerts.mqh:189`) không hề có nhánh riêng đọc pattern đã detect từ Layer 1 cho closed-bar — nó fetch đúng object per-series (`patterns_manager`/`pattern_controls`, dòng 258-262) nhưng rồi KHÔNG dùng, vẫn gọi thẳng `DetectPatternOnBar0()` (dòng 274) cho mọi TF — nên hàm này không bao giờ tạo ra Sound/Message alert nào, kể cả cho closed-bar. Đây khớp với quan sát thực tế cũ: "Không show một alert nào từ CheckCandlePatternAlerts".

**Trạng thái**: đã xác nhận nguyên nhân, nhưng đang tạm dừng theo yêu cầu Anhnt — không sửa trong lượt này.

### Ghi chú thiết kế thô (lịch sử, chưa xử lý — để tham khảo khi quay lại)

Class hierarchy liên quan: `CBarPattern : public CBaseObj` (mọi `CBarPatternXxx` inherit từ đây) → `CBarPatternControl` (1 loại pattern) và các `CBarPatternControlXxxx` inherit từ đó → `CBarPatternsControl` (có chữ "s", quản lý chung nhiều `CBarPatternControl`).

Vấn đề cốt lõi khi detect Live bar 0: bar 0 chưa đóng nên `GetListAllPatterns()`/`GetListPatterns()` chưa có gì cho nó. Ý tưởng đã nghĩ tới:
1. Tạo `bar_0_temp` (fake OHLC như bar 0 đã đóng) từ giá hiện tại.
2. Gọi `DetectPatternOnBar0()` → `ctrl.FindPattern(bar_0_temp.time, bar_0_temp)` → chỉ **return direction**, KHÔNG populate pattern object vào list nào cả (không chỉ vì bug wiring `m_BarPatterns_Control` đã tìm ra — kể cả sửa đúng object thì cũng chỉ có direction, không có object pattern đầy đủ).
3. Muốn lấy `candle_count` (1/2/3 nến) của pattern vừa detect thì cần access vào pattern object đã detect trong controller — nhưng `GetListPatterns()` là `protected`, và `CreatePattern()` cũng `protected` → không tạo/soi được từ ngoài.
4. Hướng giải quyết đã phác nhưng chưa code: tạo `m_list_all_patterns_live_temp` (list tạm riêng cho live bar 0), populate vào đó khi detect trên `bar_0_temp`, extract `candle_count` từ đó, rồi clear lại sau mỗi tick. 1-candle pattern chỉ cần `bar_0_temp`; 2-candle cần thêm bar -1 (đã đóng); 3-candle cần thêm bar -1 + bar -2.
5. Hiện tại `GetPatternCandleCount()` (`GUIPannel_SoundAndMessageAlerts.mqh:325`) đã có sẵn 1 bản static mapping candle-count theo pattern type (không cần lấy từ object thật) — có thể đã đủ dùng, chưa xác nhận có match với ý tưởng #4 ở trên hay override nó.

Kết quả quan sát thực tế trước khi tạm dừng: không show alert nào từ `CheckCandlePatternAlerts` — chỉ có alert của TF hiện tại từ `CheckIndicatorAlerts` (đường Indicator, khác hệ thống).

---

## Việc 1 (Historical backfill chia nhỏ) — vẫn pending, chưa quyết định

Backfill hiện vẫn đi qua `SetUsedPattern()` (trong `SeriesApplyPatternRegistry()`) chạy full-scan `CreateAndRefreshPatternList()` đồng bộ — nặng nhất ở vòng lặp `LoadConfigurationFromJSON` (N series). Từng gây "abnormal termination" lúc attach EA trước khi bỏ redundant `RefreshAll()` (xem lịch sử fix bên dưới).

`UpdatePatternList(n_bars)` KHÔNG thể thay thế trực tiếp cho full backfill (chỉ quét n_bars nến gần nhất, mặc định 4) — muốn dùng để "chia nhỏ" backfill thì phải gọi lặp lại nhiều lần qua nhiều tick `OnTimerEvent`, mỗi lần 1 phần nhỏ, và cần track tiến độ backfill tới đâu cho từng series (queue + progress marker) — chưa thiết kế.

- [ ] Thiết kế queue (symbol+tf pending list) + progress tracking cho backfill rải qua `OnTimerEvent`
- [ ] Xác định N series trong JSON-load loop có thực sự đủ nặng để cần chia nhỏ không (test thực tế sau khi đã xóa redundant RefreshAll)

---

## Lịch sử fix (Layer 1 performance, trước bug Bridge ở trên)

1. **`BarPatternsControl.mqh`** — thêm method `UpdateAll(const int n_bars = 4)`: loop `m_list_controls`, gọi `obj.UpdatePatternList(n_bars)` thay vì `CreateAndRefreshPatternList()`.
2. **`BarSeriesDE.mqh:428-429`** — đổi `this.m_patterns_control.RefreshAll()` → `this.m_patterns_control.UpdateAll()`, trong nhánh `IsNewBarManual()`.
3. **`TimeSeriesEngine_CandlePattern.mqh` (`SeriesApplyPatternRegistry`)** — xóa dòng `ctrl.RefreshAll();` thừa ở cuối hàm (double-scan với `SetUsedPattern()` đã tự chạy full scan cho control mới tạo).

---

## Trạng thái tổng hợp

- [x] Layer 1 (detect + lưu, backfill vs new-bar): đúng, không lệch nhau
- [x] Layer 3 (SignalMarkers.mq5 đọc + vẽ): đúng, reactive
- [x] Layer 2 (Bridge watermark bug): xác nhận nguyên nhân + fix xong (2026-08-10)
- [ ] Test thực tế fix Layer 2 — chờ Anhnt compile + chạy qua ít nhất 1 NewBar
- [ ] Bug Live (`m_BarPatterns_Control`/`DetectPatternOnBar0`) — tạm dừng, chưa sửa
- [ ] Việc 1 (backfill chia nhỏ qua queue) — chưa thiết kế

---

## File liên quan
- `V8/Services/SignalBridgeWriter.mqh` — `BuildAndWriteSignalBridge` (đã fix), `WriteSignalBridgeFile`
- `SignalMarkers.mq5` (`MQL5/Indicators/Vendors/Anhnt/Custom Buildin/SignalMarkers.mq5`) — đọc bridge + vẽ
- `V8/Anatoli Kazharski/GUIPannel_SoundAndMessageAlerts.mqh` — `CheckCandlePatternAlerts`/`DetectPatternOnBar0` (bug Live, tạm dừng)
- `Vendors\Anhnt\Library\4. Combination Lib\Timeseries\Bars\BarSeries\BarSeriesDE.mqh` — new-bar handler
- `Vendors\Anhnt\Library\4. Combination Lib\...\BarPatternsControl.mqh` — `UpdateAll`/`UpdatePatternList`/`CreateAndRefreshPatternList`

*(File này hợp nhất toàn bộ nhóm doc "UpdateCandlePattern": `UpdateCandlePatternLive.md`, `UpdatePatternOnNewBar.md`, `implementation_planCandlePattern.md`, `DetectCandlePatternLive.md` — cả 4 file đó đã xoá, nội dung còn giữ lại nằm trong các mục "Thiết kế ban đầu" và "Ghi chú thiết kế thô" ở trên.)*
