# Base Indicator Strategy

## Base Indicator Strategy Concept

- Mỗi indicator, với role của nó, là một strategy đứng riêng: Base Strategy.
- Strategy ghép phải được so thống kê với từng base của nó.
  - Nếu bản ghép không hơn base tốt nhất thì việc ghép không có giá trị.
  - Ví dụ: [Profitunity](../../Library/Entities/Settings/Strategy/Setting_Profitunity.mqh) (`CSetting_Profitunity`) = 4 Entry (Fractal, Alligator, AC, AO) + Exit (AO).

## Base Strategy

- [v] **Base = Indicator Template:** indicator nào có trong `Setting_IndicatorTemplate` thì base của nó tự ON.
  - Định danh theo indicator + params: `UNIQUE (type_enum, params)`, `id` của template.
  - ON chỉ là được tính (signal của template), không vào lệnh.
  - Không có flag bật/tắt, không khai `CStrategySetting` riêng cho base.
- [v] **Rule theo role** là judge chuẩn của `CSignalsCollection` cho từng loại indicator (`CSignalSAR`, `CSignalMA`…).
  - Ví dụ PSAR: Entry = lật phía, SL = giá PSAR, Trailing = dời theo PSAR, Exit = lật ngược.
  - ATR không có hướng (`CSignalJudge`): chỉ có role SL.
- [v] **Logic của base gửi ra theo [Event](Event.md):** `SERIES_EVENTS_SIGNAL` khi signal của template lật phía.
- [v] **Role SL:** base có role SL thì SL là giá trị buffer của chính template (`CIndicatorsCollection`), vd SL = giá PSAR.
  - Riêng ATR (khoảng cách, không phải giá): SL = giá vào ∓ ATR × `ATRMultiplier` (Setting_Risk, key của tác giả Part 7).
  - TP = giá vào ± khoảng SL × `TakeProfitRatio` (Setting_Risk), cho mọi base cung cấp SL (`CTradeRisk::BuildPlan`).
  - Một nguồn: `ATRMultiplier`, `TakeProfitRatio` (bê nguyên Part 7) chính là hệ số của base ATR và của TP, không phải nguồn SL/TP thứ hai của Strategy.
  - Nhiều base cùng role SL / Trailing: giá trị tốt nhất thắng, như mọi Strategy ([Strategy.md](Strategy.md#trading)).
  - **Giá trị của base đi theo tick, qua [Event](Event.md):** base có role SL / Trailing đang ON tự làm mới theo tick, không ai phải hỏi.
    - Trước khi có base: indicator không gửi Event, Event của indicator là Signal (`CSignalsCollection`); giá trị trên RAM chỉ được refresh khi judge chấm nến mới.
    - `CNewTickObj` (chủ của tick) fire `TICK_EVENT_NEW`; thị trường đóng thì không có tick, không có Event, không ai hỏi `CIndicatorDE`.
    - Indicator đang dùng role (template ON ở Stop Loss / Trailing, TF chart; `CTradingControl` đánh dấu) tự `Refresh` rồi fire `INDICATOR_EVENT_REFRESHED`.
    - Trading / View nghe `INDICATOR_EVENT_REFRESHED` để tính lại (vd panel Manual Entry: SL, TP, MaxLot).
    - [v] Code 2026-11-21, compile 0/0, chưa test trên terminal.
  - Có SL thì `CTradeRisk` tính lot theo `RiskMode` 0/1 (xem [Strategy.md](Strategy.md)).
  - [v] Code: `CTradeRisk::BuildPlan` nhận SL từ base (`CTradingControl::StopLossPrice`); user chọn base ở tab Trading, section Stop Loss.
  - [] **Role lấy từ judge, không viết cứng loại indicator:** đã hiểu chưa đúng concept này khi code.
    - GUI (`CGUIPannel::PopulateSections_TradingRisk`) và `CTradingControl::StopLossPrice` đang viết cứng `IND_SAR` / `IND_ATR`, nên section Trailing chỉ có PSAR.
    - Phải lấy role của base từ judge của `CSignalsCollection` (Rule theo role ở trên); thêm base mới có role SL thì không phải sửa code.
    - Rộng hơn: SL / Trailing lấy từ mọi Strategy có role đó đang On, không chỉ base ([Strategy.md](Strategy.md#trading)).
- [] **So thống kê** strategy ghép với các base của nó: cách đo bàn sau.
