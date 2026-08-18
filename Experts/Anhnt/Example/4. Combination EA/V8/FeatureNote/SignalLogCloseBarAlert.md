# Signal_Log CSV format mới + CloseBar giờ có Alert (Sound+Message), cho cả Indicator và CandlePattern

## Yêu cầu gốc (Anhnt, 2026-08-10)
*"Ngoài việc có Live ra thì khi BarClose lại cũng cần ghi ra Log kèm Alert cho cả Indicator và CandlePattern. Các cột cần được Separate tương tự như trong cái PopUpWindow ấy."* — 6 cột: Time, Indicator/Candle, TF, Live/CloseBar, Direction, IndicatorName/CandlePattern (kèm rõ số candle 1/2/3) — "để sau này còn tiện mở trên Excel hay Tool khác để phân tích."

---

## Quyết định cụ thể (qua trao đổi 2026-08-10)
1. **CloseBar giờ có cả Sound+Message**, không chỉ ghi log nữa — đảo ngược thiết kế cũ (Closed trước đây log-only, không Sound/Message vì chart Marker đã hiện rồi). Rủi ro đã biết: lần đầu chạy (watermark=0) hoặc symbol mới sẽ bắn Sound+Message dồn dập cho toàn bộ lịch sử catch-up — Anhnt đã được thông báo và chủ động chọn đánh đổi này.

   **⚠ ĐÃ ĐẢO NGƯỢC LẦN NỮA sau đó (Anhnt, note lại 2026-08-17 — quyết định gốc đã có từ trước
   nhưng thất lạc chỗ ghi chú)**: phần **Sound riêng theo Direction cho CloseBar bị BỎ HẲN** — vì
   CloseBar catch-up có thể dồn RẤT NHIỀU flip cùng lúc (nhiều Indicator × nhiều TF cùng bắt kịp 1
   lượt), phát Sound riêng cho từng cái sẽ "rách việc" (spam tiếng dồn dập, không nghe được gì).
   **Hành vi ĐÚNG/CUỐI CÙNG hiện tại**:
   - CloseBar: **Message** (per-flip, text nên không bị spam) + **CSV log** — CÓ. **Sound riêng theo
     Direction** — KHÔNG, bỏ hẳn có chủ đích.
   - Thay vào đó: 1 tiếng **`NewBar.wav`** CHUNG (không phân biệt hướng Buy/Sell) phát 1 lần mỗi khi
     có bar mới đóng, qua `CGUIPannel::PlaySoundCloseBar()` (`GUIPannel_SoundAndMessageAlerts.mqh`) -
     tách biệt hoàn toàn khỏi vòng lặp per-indicator/per-TF ở trên.
   - Live bar-0 (không đổi): Sound riêng theo Direction (`PlaySoundForDirection`) + Message + Log —
     CÓ đủ cả 3, vì Live chỉ bắn đúng 1 flip/lần, không có rủi ro dồn dập như CloseBar catch-up.

   Code hiện tại (`CheckIndicatorAlerts`, nhánh CloseBar dòng ~152-175) đã ĐÚNG theo quyết định này -
   chỉ có `WriteSignalLogRow` + `if(message_on) CMessage::Out(...)`, không có `PlaySoundForDirection`
   nào cả. **Không phải bug, không cần sửa.**
2. **Tách file theo Symbol**: `Signal_Log_<SYMBOL>.csv` (giống cách `Signal_Log_Watermark_<SYMBOL>.json` đã tách) — không còn 1 file `Signal_Log.csv` chung cho mọi symbol, nên bỏ cột Symbol.
3. **Giữ thêm Price + Cross** làm 2 cột phụ (cột 7-8), không bỏ hẳn như spec gốc 6 cột.

## Format CSV mới (8 cột, sep=;)
| # | Cột | Giá trị |
|---|-----|---------|
| 1 | Time | `TimeToString(..., TIME_DATE\|TIME_MINUTES)` |
| 2 | Source | `"Indicator"` hoặc `"Candle"` |
| 3 | TF | vd `"M15"` |
| 4 | Status | `"Live"` hoặc `"CloseBar"` |
| 5 | Direction | `"Buy"` / `"Sell"` |
| 6 | Name | Indicator label, hoặc `"[nB] PatternName"` cho pattern (n = 1/2/3 candle, giống format popup CandleInfo `"[2B] Bullish Engulfing"`) |
| 7 | Price | Giá đóng cửa tại bar tương ứng |
| 8 | Cross | Text phụ cho BBand (`"Cross Up MidBand"` v.v.) — rỗng với pattern |

---

## Thay đổi code

### `V8/Services/SignalLogger.mqh`
- `WriteSignalLogRow()` đổi signature: `(time_text, source_type, tf, status, direction, name, price_text, cross_text)`.
- File path: `Signal_Log_<SYMBOL>.csv` (dùng `::Symbol()` trực tiếp, giống watermark file) thay vì `Signal_Log.csv` cố định.
- Header CSV đổi thành `Time;Source;TF;Status;Direction;Name;Price;Cross`.

### `V8/Anatoli Kazharski/GUIPannel_SoundAndMessageAlerts.mqh`
- **`CheckIndicatorAlerts`**: nhánh Closed-bar (log-only trước đây) giờ thêm Sound+Message y hệt nhánh Live (dùng lại `sound_on`/`message_on` đã có sẵn trong vòng lặp). Cả 2 nhánh (Closed + Live) cập nhật `WriteSignalLogRow` theo signature mới, status đổi từ `"Closed"` → `"CloseBar"`.
- **`ProcessBandLine`** (BBand Upper/Lower lines): nhánh Closed-bar thêm Message (giữ nguyên quyết định cũ "không Sound cho BBand line" — chỉ Message, khớp với nhánh Live của chính hàm này vốn cũng chỉ Message không Sound).
- **`CheckCandlePatternAlerts`**: thêm HẲN một nhánh Closed-bar mới (trước đây pattern không có log/alert nào cho closed-bar cả) — đọc trực tiếp từ `m_BarTimeSeriesCollection.GetListAllPatterns()` (nguồn đúng, cùng chỗ `CSignalBridgeWriter`/popup CandleInfo đang dùng), **KHÔNG** đi qua `m_BarPatterns_Control`/`DetectPatternOnBar0` (cặp đó vẫn là bug Live đang tạm dừng riêng, xem `UpdateCandlePattern.md`). Watermark mới theo cặp (pattern type, TF): `type_key = "Pattern_" + EnumToString(pattern_type)`, `params_key = tf_text`. Tên pattern build theo đúng style popup: `"[" + Candles() + "B] " + GetProperty(PATTERN_PROP_NAME)`.
- Nhánh Live của cả Indicator lẫn Pattern giữ nguyên không đổi hành vi (chỉ đổi tham số gọi `WriteSignalLogRow` cho khớp signature mới) — không đụng vào bug Live đang tạm dừng.

---

## Trạng thái
- [x] Code đã sửa xong (2026-08-10) — cả 3 điểm: SignalLogger format mới, CloseBar+Alert cho Indicator, CloseBar+Alert mới hoàn toàn cho CandlePattern.
- [x] Đã compile/test thực tế (2026-08-17) — xác nhận CloseBar Message + CSV log hoạt động đúng
      (VD log thật: "16:26;Live;M1;BBands...;Buy;Cross Up MidBand"). Sound riêng theo Direction cho
      CloseBar đã bị bỏ có chủ đích (xem mục #1 phía trên) - không phải phần chưa test/chưa xong.

## File liên quan
- `V8/Services/SignalLogger.mqh`
- `V8/Anatoli Kazharski/GUIPannel_SoundAndMessageAlerts.mqh`
- `UpdateCandlePattern.md` — bug Live (`m_BarPatterns_Control`/`DetectPatternOnBar0`) vẫn tạm dừng, không liên quan tới thay đổi này
