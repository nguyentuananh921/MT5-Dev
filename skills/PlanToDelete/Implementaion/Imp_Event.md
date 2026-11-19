# Imp_Event

Concept: [Concept_Event.md](../concept/Concept_Event.md).

## EA Module

- [v] **Đã có dispatch cho event của chart và event bus:** `OnChartEvent` gọi `DispatchEvent`; cuối `OnInit`, `OnTick`, `OnTimer`, `OnTrade`, `OnChartEvent` gọi `DispatchBusEvents`.
- [v] **Đã có hàng đợi event trong process EA:** `CBaseObj::EventSend` đẩy event vào bus; `CBaseObj::EventNext` lấy event ra để dispatch tới listeners.
- [v] **Đã chuyển event dữ liệu khỏi chart bus:** dùng bus của EA thay `EventChartCustom`, vốn có thể thất bại trong `OnTrade` (`ERR_CHART_NO_EXPERT`, 4104).
- [v] **Event của control GUI vẫn đi qua chart** như `GElement`, `Mouse`, `TableView`, `BarMarker`, `TradeSetupBox`, `TradingLevelBubble`.

## Library

- [v] **Đã có API event ở `CBaseObj`:** class đổi dữ liệu tự gửi event; parent điều phối child nhưng không relay event.
- [v] **Đã có đóng gói params:** `EventPack` / `EventUnpack` cho `lparam`; `EventPackText` / `EventUnpackText` cho `sparam`. Event ID và ý nghĩa params khai báo trong `Entities\Defines\EventDefines.mqh`.
- [v] **Đã chuyển `CTradeEvent` sang kế thừa `CBaseObj`** để gửi event qua bus.
- [v] **Đã dùng event cho account:** listener nhận `ACCOUNT_EVENT_PROPERTY_CHANGED` và unpack params.
- [v] **Đã tập trung đọc dữ liệu terminal không có event sẵn:** chỉ những class đọc terminal được refresh tại callback phù hợp; các class xử lý dữ liệu khác làm việc theo event, không poll trong `OnTick` / `OnTimer`.
  - Tick/bar: `CNewTickObj` phát hiện tick mới từ `OnTick` hoặc `IsNewTick` trong `OnTimer`; `CBarSeriesDE` phát `SERIES_EVENTS_NEW_BAR`. Symbol không có tick quá `TICK_PAUSE_SECONDS` tạm nghỉ tới `TICK_EVENT_RESUME`.
  - Account: `CAccount::RefreshMoney` trong `OnTick` khi có Position; `RefreshAccount` trong `OnTrade`.
  - Symbol: `CSymbol::RefreshTick` trong `OnTick` cho symbol chart; symbol khác được Trading refresh trước khi đặt lệnh.
  - Market Watch: `CSymbolsCollection` refresh mỗi giây trong `OnTimer`.
- [v] **Đã có hàng chờ cho dữ liệu chưa sẵn sàng:** `CPendingPairs` được thử lại trong `OnTimer`; bỏ qua symbol đang nghỉ.
- [v] **Đã xử lý Strategy Tester:** do không có `OnChartEvent`, nhánh `MQL_TESTER` gọi `RefreshSeries` trong `OnTick`.
- [v] **Direction không bắt buộc:** một số event có hướng (vd AO cắt 0), một số không (vd button, Pin Bar, Swing High, Inside Bar).

## Library\Python

- [v] **Đã nối tiến độ Python với event phía EA:** Python ghi file cờ tiến độ; `CPythonBridge` nhận `SymbolTF` completion, fire `PYTHON_BRIDGE_EVENT_SYMBOLTF_DONE` để các collection nạp lại dữ liệu từ DB.
- [v] **Kronos forecast dùng socket, không phải EA Event Bus:** chi tiết protocol và các scope nhận dữ liệu ở [Imp_Kronos.md](Imp_Kronos.md).

## EA V5\Web

- [v] **Không dùng EA Event Bus:** dữ liệu realtime được Python server đẩy qua WebSocket `/socket`; phần Kronos xem [Imp_Kronos.md](Imp_Kronos.md).

## Việc chưa làm

- [] **Trading nhận đủ dữ liệu từ Strategy:** chốt params SL/TP đi cùng `STRATEGY_EVENT_ENTRY`; chốt event riêng cho trailing mỗi bar (đề xuất `STRATEGY_EVENT_SL`) để Trading gọi `ModifyPosition`.
- [] **Event cho RiskManagement Strategy:** chốt dữ liệu/Event đầu vào, quyết định theo scope Trade, Basket, Portfolio và Event đầu ra cho Trading. Theo dõi chi tiết trong [Imp_RiskManagement.md](Imp_RiskManagement.md).
