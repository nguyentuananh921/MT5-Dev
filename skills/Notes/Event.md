# Event Note

## Nguyên tắc chung

 Event là thông báo về một thay đổi có ý nghĩa trong state của object. thay đổi value của [Indicator](IndicatorConcept.md#indicator-defines) không tạo ra Event. Quan hệ sở hữu và vai trò parent–child được mô tả trong [ParentChild.md](ParentChild.md).
 - Mục đích của Event là [Automation](../AGENTS.md#automation).
 - Object phát hiện thay đổi có ý nghĩa thì fire Event cho listener liên quan theo.
 - **Ngoại lệ:** object cần value của Indicator để tính (vd parameter của MqlTradeRequest) tự Refresh rồi đọc khi Event của nó gọi tới.

## Nguồn Event

 Event có thể phát sinh từ nhiều loại nguồn:

 | Nguồn | Ví dụ |
 |---|---|
 | [Indicator](IndicatorConcept.md#indicator-defines) (Signal) | AO cắt 0, RSI rời vùng quá mua |
 | [Indicator on Indicator](IndicatorConcept.md#indicator-defines) (Signal) | RSI cắt MA của nó |
 | Trạng thái Trading / account | P/L của Position hoặc Basket, margin level, equity / drawdown |
 | Object | Swing, BOS, Candle Pattern (Pin Bar…), Chart Pattern, Harmonic Pattern, Zone |

 Hướng (direction) là thuộc tính tùy loại Event: AO cắt 0 có hướng; button, Pin Bar, Swing High hoặc Inside Bar có thể không có hướng. Hướng của Event tự nó không phải quyết định giao dịch; Strategy diễn giải nó trong ngữ cảnh các Event được ghép.

### Reference

 - **Event-Driven Design:** Event Swing, internal/external BOS và CHoCH lấy concept từ `D:\MT5-Dev\Experts\Stanley Kimathi Kibaara\Market Structure Framework`. 
 
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

- EA sở hữu Event Bus trong process; sau callback `OnInit`, `OnTick`, `OnTimer`, `OnTrade` hoặc `OnChartEvent`, EA drain queue bằng `DispatchBusEvents` rồi `DispatchEvent` tới listener.
- [v] **Đã chuyển event dữ liệu khỏi chart bus:** dùng Event Bus thay `EventChartCustom`, vốn có thể thất bại trong `OnTrade` (`ERR_CHART_NO_EXPERT`, 4104).
- [v] **Event của control GUI vẫn đi qua chart** như `GElement`, `Mouse`, `TableView`, `BarMarker`, `TradeSetupBox`, `TradingLevelBubble`.

## EA Web

- EA Web không sử dụng [EA Event Bus](#ea-module) của MQL5.
- Dữ liệu realtime đi trực tiếp giữa EA Web và [Python Library](CommunicationNote.md#working-area-connections) qua WebSocket `/socket`.
- Request/response đi qua HTTP API của Python Library.
- Không dùng `CBaseObj::EventSend` hoặc `MQL5 Event Bus` thay cho [contract Web](CommunicationNote.md#channel-contracts).

## MT5 Library

- Object sở hữu data đổi state tự gửi event; listener lọc ID quan tâm, unpack payload và xử lý phần của mình.
- Contract:
  - Event ID, `lparam`, `dparam`, `sparam`: khai báo trong `Entities\Defines\EventDefines.mqh`.
  - `CBaseObj::EventPack` / `EventUnpack`: đóng gói chuẩn cho `lparam`.
  - `CBaseObj::EventPackText` / `EventUnpackText`: đóng gói và tách `sparam`.
- Ví dụ:
  - Sender: `CStrategyBase::StoreRow` lưu row rồi gửi `STRATEGY_EVENT_ENTRY` hoặc `STRATEGY_EVENT_EXIT`.
  - Listener: `CAccountsCollection::OnChartEvent` lọc `ACCOUNT_EVENT_PROPERTY_CHANGED`, unpack payload rồi cập nhật account.
- Event của control GUI có thể đi qua chart event thật; không nhầm với event queue của `CBaseObj::EventSend`.
- [v] **Object sở hữu data fire Event:** không để parent relay thay.
- [v] **Đã đóng gói params:** `EventPack` / `EventUnpack` cho `lparam`; `EventPackText` / `EventUnpackText` cho `sparam`.
- [v] **Đã dùng event cho Trading và account:** `CTradeEvent` kế thừa `CBaseObj`; listener account nhận `ACCOUNT_EVENT_PROPERTY_CHANGED`.
- [v] **Terminal không có Event sẵn:**
  - Tick/bar: `CNewTickObj` phát hiện tick trong `OnTick` hoặc `IsNewTick` trong `OnTimer`; `CBarSeriesDE` phát `SERIES_EVENTS_NEW_BAR`. Symbol không có tick quá `TICK_PAUSE_SECONDS` tạm nghỉ tới `TICK_EVENT_RESUME`.
  - Account: `CAccount::RefreshMoney` trong `OnTick` khi có Position; `RefreshAccount` trong `OnTrade`.
  - Symbol: `CSymbol::RefreshTick` trong `OnTick` cho symbol chart; symbol khác được Trading refresh trước khi đặt lệnh.
  - Market Watch: `CSymbolsCollection` refresh mỗi giây trong `OnTimer`.
- [v] **Data chưa sẵn sàng:** `CPendingPairs` thử lại trong `OnTimer`; bỏ qua symbol đang nghỉ.
- [v] **Strategy Tester:** không có `OnChartEvent`; nhánh `MQL_TESTER` gọi `RefreshSeries` trong `OnTick`.

## Python Library

 Python không gọi trực tiếp Event Bus trong process EA. `CPythonBridge` quan sát tiến độ qua file; khi worker hoàn tất, bridge phát event trong EA để các collection xử lý tiếp.

 [v] **Đã nối tiến độ Python với event phía EA:** Python ghi file cờ tiến độ; `CPythonBridge` nhận `SymbolTF` completion, fire `PYTHON_BRIDGE_EVENT_SYMBOLTF_DONE` để các collection nạp lại dữ liệu từ DB.

 ## Database

 Database lưu state/dữ liệu bền vững, không phải Event Bus. Event thông báo thay đổi trong runtime; việc đọc/ghi DB vẫn do component sở hữu dữ liệu và lifecycle của nó thực hiện.

