# Implementation Plan: 8 Signal Markers System (Indicator, Pattern, Combo)

Triển khai hệ thống **8 Signal Markers** cho phép hiển thị các dạng tín hiệu linh hoạt trên Chart thông qua chỉ báo `SignalMarkers.mq5` và cài đặt trong `TabSetting` của `CGUIPannel`.

---

## 1. Nguyên tắc phân loại & Tính toán Marker

Tại mỗi bar `t` (cho tất cả Timeframe của Symbol đang theo dõi), gom toàn bộ tín hiệu xảy ra:
- **Indicator Signals**: Đếm số lượng tín hiệu từ Indicator
  - `ind_buy_count`: Số lượng tín hiệu Buy từ Indicator.
  - `ind_sell_count`: Số lượng tín hiệu Sell từ Indicator.
- **Candle Pattern Signal**: Boolean "có Candle Pattern" (không count)
  - `has_pattern_buy`: Có Pattern Buy signal xảy ra trong bar này (1 signal trả về BUY từ 28 patterns kết hợp)
  - `has_pattern_sell`: Có Pattern Sell signal xảy ra trong bar này (1 signal trả về SELL từ 28 patterns kết hợp)

### Tổng hợp:
- `total_ind = ind_buy_count + ind_sell_count`
- `has_pattern = has_pattern_buy OR has_pattern_sell` (boolean)
- `pattern_dir = has_pattern_buy ? BUY : SELL` (hướng pattern nếu có)

### Quy tắc xác định:
1. **Hướng Tín hiệu (Direction):**
   - Nếu có indicator signals, hướng = majority direction của indicators
   - Nếu chỉ có pattern (không indicator), hướng = pattern direction
   - Nếu cả hai, hướng = majority của indicators (pattern là secondary)

2. **Dạng Marker (Shape Family - 8 loại):**
   - **Chỉ có 1 Indicator** (`!has_pattern && total_ind == 1`):
     - $\rightarrow$ **Single Buy** / **Single Sell**
   - **Nhiều Indicator** (`!has_pattern && total_ind > 1`):
     - $\rightarrow$ **Multi Buy** / **Multi Sell**
   - **Chỉ có Candle Pattern** (`has_pattern && total_ind == 0`):
     - $\rightarrow$ **Pattern Buy** / **Pattern Sell**
   - **Combo (Cả Indicator và Candle Pattern)** (`has_pattern && total_ind > 0`):
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

### Component 2: Signal Bridge Writer (`CSignalBridgeWriter`)

#### [MODIFY] [SignalBridgeWriter.mqh](file:///c:/Users/nguye/AppData/Roaming/MetaQuotes/Terminal/D0E8209F77C8CF37AD8BF550E51FF075/MQL5/Experts/Anhnt/Example/4.%20Combination%20EA/V8/Services/SignalBridgeWriter.mqh)
- Nâng cấp `BuildAndWriteSignalBridge()`:
  - **Coi Candle Pattern giống Indicator**: Duyệt pattern list từ `m_BarTimeSeriesCollection.GetListPatterns()` (chỉ **CLOSED BARS**, không xử lý live bar 0)
  - Ghi pattern signals vào bridge file giống cách ghi indicator signals (không thêm source_type field)
  - Định dạng bridge file **vẫn giữ nguyên**:
    `{ long flip_time; int tf; int dir; }`
  - Ghi pattern buy/sell signals với `dir = +1` (buy) hoặc `-1` (sell) giống indicator

#### **Q2: Mỗi closed bar có bao nhiêu pattern signals?**
- **Decision: 1 signal per closed bar (nếu có pattern)**
- **Cơ chế**: 
  - Mỗi closed bar có `BAR_PROP_PATTERNS_TYPE` = bitmask (có thể chứa 2-3 patterns)
  - Ví dụ: bar có Hammer + Doji cùng Buy direction → **ghi 1 signal Buy** vào bridge, không ghi 2 signals riêng
  - Direction = direction của pattern trên bar đó
  - Nếu bar có multiple patterns với direction khác nhau → take majority direction
- **Chú ý**: 
  - **Live bar 0 patterns KHÔNG được ghi** vào bridge file (live bar 0 pattern detection chưa được implement đầy đủ)
  - Chỉ xử lý patterns từ các closed bars via `GetListPatterns()`
  - Không ghi từng pattern type riêng lẻ, chỉ 1 signal per bar

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
- Nâng cấp `indicator_buffers` từ 8 → 12 (mỗi plot = 2 buffers: value + color_idx)
- Nâng cấp `indicator_plots` từ 4 → 8
- Nhận 8 tham số `input int` mã Wingdings icon (từ `m_marker_*_code[]` ở CGUIPannel)
- **Cập nhật ComputeBar()** logic đếm:
  - Đếm `ind_count` = toàn bộ indicator signals trong bucket
  - Đếm `pat_count` = toàn bộ pattern signals trong bucket  
  - Xác định shape dựa trên (ind_count, pat_count):
    - `ind_count==1 && pat_count==0` → **SingleBuy/Sell**
    - `ind_count>1 && pat_count==0` → **MultiBuy/Sell**
    - `ind_count==0 && pat_count>0` → **PatternBuy/Sell**
    - `ind_count>0 && pat_count>0` → **ComboBuy/Sell**
  - Color logic vẫn giữ nguyên: dựa trên own-TF signals

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
