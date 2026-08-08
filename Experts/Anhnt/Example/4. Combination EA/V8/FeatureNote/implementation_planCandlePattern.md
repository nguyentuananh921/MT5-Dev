# Implementation Plan: 8 Signal Markers System (Indicator, Pattern, Combo)

Triển khai hệ thống **8 Signal Markers** cho phép hiển thị các dạng tín hiệu linh hoạt trên Chart thông qua chỉ báo `SignalMarkers.mq5` và cài đặt trong `TabSetting` của `CGUIPannel`.

---

## 1. Nguyên tắc phân loại & Tính toán Marker

Tại mỗi bar `t` (cho tất cả Timeframe của Symbol đang theo dõi), gom toàn bộ tín hiệu xảy ra:
- `ind_buy_count`: Số lượng tín hiệu Buy từ Indicator.
- `ind_sell_count`: Số lượng tín hiệu Sell từ Indicator.
- `pat_buy_count`: Số lượng tín hiệu Buy từ Candle Pattern.
- `pat_sell_count`: Số lượng tín hiệu Sell từ Candle Pattern.

### Tổng hợp:
- `total_buy = ind_buy_count + pat_buy_count`
- `total_sell = ind_sell_count + pat_sell_count`
- `total_ind = ind_buy_count + ind_sell_count`
- `total_pat = pat_buy_count + pat_sell_count`
- `total = total_ind + total_pat`

### Quy tắc xác định:
1. **Hướng Tín hiệu (Direction):**
   - Nếu `total_buy > total_sell` $\rightarrow$ **BUY**
   - Nếu `total_sell > total_buy` $\rightarrow$ **SELL**
   - Nếu `total_buy == total_sell` $\rightarrow$ Ưu tiên hướng có Candle Pattern hoặc hướng Buy.

2. **Dạng Marker (Shape Family - 8 loại):**
   - **Chỉ có 1 Indicator** (`total_pat == 0 && total_ind == 1`):
     - $\rightarrow$ **Single Buy** / **Single Sell**
   - **Nhiều Indicator** (`total_pat == 0 && total_ind > 1`):
     - $\rightarrow$ **Multi Buy** / **Multi Sell**
   - **Chỉ có Candle Pattern** (`total_pat > 0 && total_ind == 0`):
     - $\rightarrow$ **Pattern Buy** / **Pattern Sell**
   - **Combo (Cả Indicator và Candle Pattern)** (`total_pat > 0 && total_ind > 0`):
     - $\rightarrow$ **Combo Buy** / **Combo Sell**

---

## 2. Proposed Changes

### Component 1: GUI Settings (`GUIPannel_TabSetting.mqh`)

#### [MODIFY] [GUIPannel_TabSetting.mqh](file:///c:/Users/nguye/AppData/Roaming/MetaQuotes/Terminal/D0E8209F77C8CF37AD8BF550E51FF075/MQL5/Experts/Anhnt/Example/4.%20Combination%20EA/V8/Anatoli%20Kazharski/GUIPannel_TabSetting.mqh)
- Mở rộng subtab **Marker** từ 4 lên 8 hàng ComboBox + Preview shape:
  1. `Single Buy` (Default: 233)
  2. `Single Sell` (Default: 234)
  3. `Multi Buy` (Default: 217)
  4. `Multi Sell` (Default: 218)
  5. `Pattern Buy` (Default: 67)
  6. `Pattern Sell` (Default: 68)
  7. `Combo Buy` (Default: 225 - Arrow Head Up / Star / Flame)
  8. `Combo Sell` (Default: 226 - Arrow Head Down)
- Nâng cấp `LoadMarkerSettings()` & `SaveMarkerSettingsToJSON()` để lưu/đọc 8 mã icon trong `Config_Setting.json`.
- Nâng cấp `EnsureMarkerIndicatorAttached()` truyền đủ 8 tham số `iCustom` cho `SignalMarkers`.

---

### Component 2: Signal Bridge Writer (`GUIPannel.mqh`)

#### [MODIFY] [GUIPannel.mqh](file:///c:/Users/nguye/AppData/Roaming/MetaQuotes/Terminal/D0E8209F77C8CF37AD8BF550E51FF075/MQL5/Experts/Anhnt/Example/4.%20Combination%20EA/V8/Anatoli%20Kazharski/GUIPannel.mqh)
- Nâng cấp `BuildAndWriteSignalBridge()`:
  - Duyệt và ghi cả tín hiệu Indicator lẫn tín hiệu từ Candle Pattern (`m_BarTimeSeriesCollection.GetListAllPatterns()`).
  - Định dạng record mới trong `SignalBridge_<SYMBOL>.dat`:
    `{ long flip_time; int tf; int dir; int source_type; }`
    (`source_type`: 0 = Indicator, 1 = Candle Pattern).

---

### Component 3: Custom Indicator Chart Renderer (`SignalMarkers.mq5`)

#### [MODIFY] [SignalMarkers.mq5](file:///c:/Users/nguye/AppData/Roaming/MetaQuotes/Terminal/D0E8209F77C8CF37AD8BF550E51FF075/MQL5/Indicators/Vendors/Anhnt/Custom%20Buildin/SignalMarkers.mq5)
- Nâng cấp số plot từ 4 lên 8 (`DRAW_COLOR_ARROW`):
  1. `SingleBuy`
  2. `SingleSell`
  3. `MultiBuy`
  4. `MultiSell`
  5. `PatternBuy`
  6. `PatternSell`
  7. `ComboBuy`
  8. `ComboSell`
- Nhận 8 tham số `input int` mã Wingdings icon.
- Đọc định dạng bridge file mới chứa `source_type`.
- Thực hiện logic đếm số lượng & xác định đúng 1 trong 8 plot buffer để hiển thị trên chart.

---

## 3. Verification Plan

### Automated Tests / Compile Verification
- Biên dịch lại `SignalMarkers.mq5` bằng MetaEditor/MQL5 Compiler hoặc kiểm tra lỗi cú pháp MQL5.
- Biên dịch lại EA `EA Ussing Combination Lib V8.mq5`.

### Manual Verification
- Mở bảng GUI `Settings` -> subtab `Marker` trên MT5.
- Xác nhận hiển thị đủ 8 dòng cài đặt Shape ComboBox & Preview.
- Chọn thay đổi các icon khác nhau cho Single, Multi, Pattern, Combo và ấn **Save**.
- Kiểm tra file `Config_Setting.json` đã lưu đúng 8 mã `arrow_code`.
- Kiểm tra các Marker vẽ chính xác vị trí nến trên Chart theo đúng phân loại (Single, Multi, Pattern, Combo).
