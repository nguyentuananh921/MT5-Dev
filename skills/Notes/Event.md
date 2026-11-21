# Event Note

 ## Nguyên tắc chung

  Event là thông báo về một thay đổi có ý nghĩa trong state của object. Quan hệ sở hữu và vai trò parent–child được mô tả trong [ParentChild.md](ParentChild.md).

- Mục đích của Event là [Automation](../AGENTS.md#automation).

 ## Nguồn Event

  Event có thể phát sinh từ nhiều loại nguồn:

  | Nguồn | Ví dụ |
  |---|---|
  | Indicator | AO cắt 0, RSI rời vùng quá mua |
  | Indicator on Indicator | RSI cắt MA của nó ([Concept_IndicatorOnIndicator.md](Concept_IndicatorOnIndicator.md)) |
  | Trạng thái Trading / account | P/L của Position hoặc Basket, margin level, equity / drawdown |
  | Object | Swing, BOS, Candle Pattern (Pin Bar…), Chart Pattern, Harmonic Pattern, Zone |

  Hướng (direction) là thuộc tính tùy loại Event: AO cắt 0 có hướng; button, Pin Bar, Swing High hoặc Inside Bar có thể không có hướng. Hướng của Event tự nó không phải quyết định giao dịch; Strategy diễn giải nó trong ngữ cảnh các Event được ghép.

 ## Working with Event

  ### Luồng thêm Event

   Khi thêm một **loại object** mới, khai báo giá trị `OBJECT_DE_TYPE_*` trong `ENUM_OBJECT_DE_TYPE` tại `Entities\Defines\CommonDefines.mqh` và gán giá trị đó cho `m_object_type` của class. Đây là loại object, không phải event ID.

   1. Khai báo event ID trong enum phù hợp của `EventDefines.mqh` (ví dụ `SERIES_EVENTS_NEW_BAR` thuộc `ENUM_SERIES_EVENT`); ghi contract của `lparam`, `dparam`, `sparam` và cập nhật `*_NEXT_CODE` để các nhóm ID không chồng lấn.
   2. Object sở hữu dữ liệu gọi `EventSend` sau khi state thực sự đổi; truyền đủ dữ liệu theo contract và xử lý nếu hàm trả `false`.
   3. Parent dispatch event, không relay thay object sở hữu dữ liệu. Listener lọc đúng ID, unpack theo contract và xử lý; không poll để tìm thay đổi.
   4. Xác nhận EA dispatch queue tại callback phù hợp.

   Event ID truyền vào `EventSend` là ID riêng trong `EventDefines.mqh`; EA thêm `CHARTEVENT_CUSTOM` khi dispatch. Không truyền sẵn phần offset này vào `EventSend`.

  ### API của `CBaseObj`

   | Method | Cách dùng |
   |---|---|
   | `EventPack(time, key, side, is_new)` | Đóng gói các trường chuẩn vào `lparam`: time ở bit 0–31, key 16-bit ở bit 32–47, side 2-bit ở bit 48–49, `is_new` ở bit 50. |
   | `EventUnpack(lparam, ...)` | Giải mã đúng contract đã đóng gói bằng `EventPack`. |
   | `EventPackText(symbol)` | Mặc định trả về symbol; có thể override nếu có contract riêng. |
   | `EventUnpackText(sparam, symbol, extra)` | Tách `sparam` tại dấu `;` đầu tiên thành symbol và phần extra. |
   | `EventSend(id, lparam, dparam, sparam)` | Đưa event vào queue của EA; trả `false` nếu không thêm được event. |
   | `EventNext(...)` | Lấy event cũ nhất khỏi queue; do dispatcher của EA sử dụng để drain queue. |

   Chỉ dùng `EventPack` khi payload phù hợp schema chuẩn; mỗi event vẫn phải ghi rõ ý nghĩa của ID và kiểu/ý nghĩa của từng parameter. Event được queue, không gọi listener ngay tại `EventSend`. Event được gửi trong lúc dispatch sẽ nối cuối queue và được xử lý tiếp.

 ## EA Module

  EA có queue Event Bus riêng trong process. Sau khi xử lý `OnInit`, `OnTick`, `OnTimer`, `OnTrade` và `OnChartEvent`, EA gọi `DispatchBusEvents`; queue được lấy theo thứ tự gửi và mỗi event được chuyển qua `DispatchEvent` đến các child.

 ## EA Web

  EA Web không dùng Event Bus của MQL5; dữ liệu realtime của Web đi qua WebSocket (xem [Websocket.md](Websocket.md)). Không dùng `EventSend` thay cho contract Web.

 ## Library

  `CBaseObj` cung cấp pack/unpack và queue API. Event ID cùng payload contract được khai báo trong `Entities\Defines\EventDefines.mqh`. Class làm đổi dữ liệu tự gửi event; listener xử lý trong `OnChartEvent` và chỉ phản ứng với ID mình quan tâm.

  - Ví dụ sender: `CStrategyBase::StoreRow` lưu row rồi gửi `STRATEGY_EVENT_ENTRY` hoặc `STRATEGY_EVENT_EXIT`.
  - Ví dụ listener: `CAccountsCollection::OnChartEvent` lọc `ACCOUNT_EVENT_PROPERTY_CHANGED`, unpack property rồi cập nhật row account.
  - Event GUI của control vẫn có thể đi qua chart event thật; không nhầm đường đó với queue của `EventSend`.

 ## Library\Python

  Python không gọi trực tiếp Event Bus trong process EA. `CPythonBridge` quan sát tiến độ qua file; khi worker hoàn tất, bridge phát event trong EA để các collection xử lý tiếp.

 ## Database

  Database lưu state/dữ liệu bền vững, không phải Event Bus. Event thông báo thay đổi trong runtime; việc đọc/ghi DB vẫn do component sở hữu dữ liệu và lifecycle của nó thực hiện.


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
 ## Library\Python

  - [v] **Đã nối tiến độ Python với event phía EA:** Python ghi file cờ tiến độ; `CPythonBridge` nhận `SymbolTF` completion, fire `PYTHON_BRIDGE_EVENT_SYMBOLTF_DONE` để các collection nạp lại dữ liệu từ DB.
  

 ## EA V5\Web

  - [v] **Không dùng EA Event Bus:** dữ liệu realtime được Python server đẩy qua WebSocket `/socket`; phần Kronos xem [Imp_Kronos.md](Imp_Kronos.md).

 ## Việc chưa làm

  - [] **Trading nhận đủ dữ liệu từ Strategy:** chốt params SL/TP đi cùng `STRATEGY_EVENT_ENTRY`; chốt event riêng cho trailing mỗi bar (đề xuất `STRATEGY_EVENT_SL`) để Trading gọi `ModifyPosition`.
  - [] **Event cho RiskManagement Strategy:** chốt dữ liệu/Event đầu vào, quyết định theo scope Trade, Basket, Portfolio và Event đầu ra cho Trading. 
  - [] **Automation × Event:** ghi rõ loại object nào nghe Event nào để làm việc của mình.
