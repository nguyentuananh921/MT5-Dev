# Pivot Point Reversal — Ngưỡng detect quá lỏng

**Ngày:** 2026-08-15
**Trạng thái:** Đang xử lý — đã xác nhận nguyên nhân + fix 1 phần, còn chờ chốt hướng ngưỡng (point cố định hay ratio %)
**Mức độ:** Medium — không sai vị trí vẽ, không sai hướng màu, chỉ sai *độ nhạy* detect

## Hiện tượng

Anhnt (2026-08-15): Alt+Hover vào box "Pivot Point Reversal" trên chart, thấy 3 nến trong box không có hình dạng pivot rõ ràng — cây ở giữa (bar1) "chả đúng cái" so với mắt nhìn thường (không giống 1 đỉnh/đáy cục bộ rõ rệt).

## Quá trình rà soát (đã loại trừ)

1. **Vị trí vẽ box** — `ShowPatternBitmapAtBar` (`GUIPannel_CandleInfoWindow.mqh`) tính `t_old = t_new - (n-1)*period`, `t_new = bar2.Time()` (bar xác nhận = bar đang hover) → đối chiếu log thực tế, box vẽ đúng khít 3 nến. **Không phải bug rendering.**
2. **Định nghĩa hướng (Bullish/Bearish)** — đúng quy ước chuẩn candlestick reversal toàn thư viện (giống MorningStar/EveningStar): Bullish = pivot LOW (đáy) → kỳ vọng đảo chiều lên; Bearish = pivot HIGH (đỉnh) → kỳ vọng đảo chiều xuống. Không phải đặt tên theo hình dạng nến tại chỗ.
3. **Màu sắc** — khớp đúng quy ước (`GCnvPatternBitmap.mqh`): Bullish=xanh (CornflowerBlue/RoyalBlue), Bearish=đỏ (LightSalmon/Crimson). Box hồng cam + viền đỏ trong ảnh = đúng Bearish.
4. **bar0/bar1/bar2 thứ tự thời gian** — `BarPatternControlPivotPointReversal.mqh:83-87`: bar2 = mới nhất/bar đang hover (phải), bar1 = giữa (pivot), bar0 = cũ nhất (trái). Đúng logic, không lệch index.

## Nguyên nhân (CONFIRMED qua debug log)

`m_min_body_size = 0` hardcode trong constructor PPR (trước khi sửa) → `protrusion = Point() * 0 = 0` → điều kiện `bar1.High() > bar0.High() + 0 && bar1.High() > bar2.High() + 0` chấp nhận **bất kỳ chênh lệch dương nào**, kể cả nhỏ tới mức mắt thường không nhận ra.

**Log thực tế xác nhận** (thêm debug tạm trong `FindPattern`, XAUUSDm M1, `Point()=0.001`):
```
FindPattern(Bearish): protrusion=0.0
bar0 t=19:28  H=4377.575
bar1 t=19:29  H=4377.916   ← pivot, nhưng chỉ hơn bar2 có 0.085 (~85 points)
bar2 t=19:30  H=4377.831
margin_vs_bar0 = 0.341   margin_vs_bar2 = 0.085
```
Range trung bình mỗi nến M1 gold ~1-2$ (1000-2000 points) → margin 85 points là nhiễu, không phải pivot rõ.

## Đã sửa (một phần)

1. **Debug tạm** — `BarPatternControlPivotPointReversal.mqh::FindPattern`: in `MY DEBUG CBarPatternControlPivotPointReversal::FindPattern(Bullish/Bearish)` với O/H/L/C bar0/bar1/bar2 + margin, trước mỗi `return`. *(Cần xoá sau khi xong việc tuning threshold.)*
2. **Library — đọc PatternParams** — constructor PPR đổi từ `this.m_min_body_size = 0;` (hardcode) sang đọc `PatternParams[0]` giống PinBar:
   ```cpp
   int param_size = ArraySize(this.PatternParams);
   this.m_min_body_size = (param_size > 0) ? (uint)this.PatternParams[0].integer_value : 0;
   ```
3. **Library — thêm define** — `BarPatternControl.mqh` (UTF-16LE, sửa qua PowerShell): thêm `#define PATTERN_DEF_PPR_MIN_BODY_SIZE 30 // PivotPointReversal param[0]`.
4. **EA — wire param** — `TimeSeriesEngine_CandlePattern.mqh::RegisterAllCandlePatterns`: tách PPR ra khỏi nhóm dùng `p[]` rỗng chung, thêm `ppr_params[]` riêng (1 phần tử TYPE_INT) truyền `PATTERN_DEF_PPR_MIN_BODY_SIZE` vào `SetUsedPattern`.

## ⚠️ Sai sót đã phát hiện, CHƯA sửa

Giá trị `30` ở bước 3 giả định `Point()=0.01`, nhưng XAUUSDm broker này quote **3 chữ số thập phân** (`Digits()=3` → `Point()=0.001`, xác nhận qua Market Watch: `4375.738/4375.998`). Vậy `30 points × 0.001 = 0.03$` — **còn nhỏ hơn** margin 0.085$ ở case đáng ngờ đã xem → threshold hiện tại chưa lọc được gì, coi như fix bước 2-4 ở trên **chưa có tác dụng thật cho tới khi sửa lại con số**.

## Điểm phát hiện thêm (lưu ý dùng sau)

`m_min_body_size` (field chung trong `CBarPatternControl`) bị dùng KHÔNG nhất quán đơn vị giữa các pattern:
- **Tweezer, PPR**: dùng như **point tuyệt đối** (`Point() * m_min_body_size`)
- **PinBar**: dùng như **ratio % trực tiếp**, so với `BAR_PROP_RATIO_BODY_TO_CANDLE_SIZE` (không nhân `Point()`)

Cùng tên field, khác đơn vị tuỳ subclass — dễ gây nhầm lẫn nếu sau này thêm pattern mới copy nhầm cách dùng.

`CBarPatternControlOutsideBar.mqh:99-100` có sẵn cơ chế **ratio tương đối theo range nến** (không cần Point cố định):
```cpp
double ratio = (bar0.Size() > 0 ? bar1.Size() * 100.0 / bar0.Size() : 0.0);
if(ratio < this.RatioCandleSizeValue()) return false;
```
Đây là ứng viên cho hướng "Option 2" bên dưới nếu chọn — không cần viết logic mới từ đầu, field `m_ratio_candle_sizes` + `RatioCandleSizeValue()` đã có sẵn trong base class.

## Đang chờ quyết định (PAUSED — Anhnt: "Từ từ xem nào")

Chọn 1 trong 3 hướng để hoàn thiện threshold PPR:
1. **Point cố định** — chỉ cần sửa lại số `PATTERN_DEF_PPR_MIN_BODY_SIZE` cho đúng đơn vị (>85 points để lọc case đã xem, có thể cần 300-500 để rõ mắt hẳn). Đơn giản nhất nhưng không tự thích nghi theo symbol/TF khác.
2. **Ratio = Protrusion / Size(bar1)** — phần High/Low bar1 vượt quá bar0,bar2 phải ≥ X% chiều cao chính nến bar1.
3. **Ratio = Size(bar1) / Size(bar0 hoặc bar2)** — giống hệt cách OutsideBar đang làm, so độ lớn nến liền kề, không quan tâm phần protrusion cụ thể.

## File liên quan
- `Vendors\Anhnt\Library\4. Combination Lib\Timeseries\Bars\BarSeries\TrCandles\BarPatternControlPivotPointReversal.mqh` — `FindPattern` (logic detect + debug), constructor (đọc param)
- `Vendors\Anhnt\Library\4. Combination Lib\Timeseries\Bars\BarSeries\BarPatternControl.mqh` — field `m_min_body_size`/`m_ratio_candle_sizes`, khối `#define PATTERN_DEF_*` (UTF-16LE)
- `Vendors\Anhnt\Library\4. Combination Lib\Timeseries\Bars\BarSeries\DCandles\BarPatternControlOutsideBar.mqh` — mẫu tham khảo cơ chế ratio tương đối
- `V8\Artyom Trishkin\TimeSeriesEngine_CandlePattern.mqh` — `RegisterAllCandlePatterns` (wire `ppr_params[]`)
- `V8\Anatoli Kazharski\GUIPannel_CandleInfoWindow.mqh` — `ShowPatternBitmapAtBar`/`ShowPatternHoverLabel` (Alt+Hover box, đã xác nhận đúng, không phải nguồn bug)
- `Vendors\Anhnt\Library\4. Combination Lib\Graph\Bitmaps\GCnvPatternBitmap.mqh` — màu sắc box (đã xác nhận đúng)
