## Concept Note

 Các mục trong note là [Concept](../AGENTS.md#clear-understand) dùng để thống nhất cách hiểu giữa EA Module, EA Web, MT5 Library, Python Library và Database; chưa phải spec implementation chi tiết.

### DoEasy Data Object

**Concept** theo [bài 1 của DoEasy](https://www.mql5.com/en/articles/5654#concept):

- Một Data Object biểu diễn một thực thể dữ liệu; các object cùng loại có cùng tập property.
- Class định nghĩa tập property của object và các thao tác tối thiểu để lưu trữ, sắp xếp, hiển thị và truy xuất dữ liệu.
**Ví dụ trong bài:** `COrder` biểu diễn dữ liệu order, deal hoặc position; `ENUM_ORDER_STATUS` cho biết object đang đại diện cho loại nào.
**Implementation hiện tại trong System:** đã được update từ phiên bản DoEasy được ghi tại [Update.md — Library](Update.md#library).
 - `COrder` lưu property trong các mảng 
  + `m_long_prop[]`, `m_double_prop[]`, `m_string_prop[]`;
  + `ENUM_ORDER_PROP_INTEGER`, `ENUM_ORDER_PROP_DOUBLE`, `ENUM_ORDER_PROP_STRING` định danh property được khai báo trong [TradingDefines.mqh](../../Library/Entities/Defines/TradingDefines.mqh).
 - `SetProperty` và `GetProperty` truy cập property theo enum. `IndexProp` ánh xạ enum `double` và `string` sang index mảng; enum `integer` dùng trực tiếp làm index trong [Order.mqh](../../Library/Entities/Trading/Order.mqh).
 **Mẫu tương tự** `CBar`, `CTick`, `COrder`, `CAccount`, `CSymbol`, `CTradeEvent`, `CPendRequest`, `CIndicatorDE`, `CRiskSetting`

### Easy and Fast GUI

**Concept** theo chuỗi bài về EasyAndFastGUI: [bài mở đầu 2125 (2016)](https://www.mql5.com/en/articles/2125) và [bài cuối 19073 (2018)](https://www.mql5.com/en/articles/19073):

- EasyAndFastGUI là thư viện hướng đối tượng để xây dựng giao diện đồ họa cho ứng dụng MQL4/MQL5 bằng các control có thể tái sử dụng.
- Một control có thể gồm nhiều phần tử đồ họa; các control chia sẻ thuộc tính chung, còn control phức tạp có thể kết hợp các control khác.
- Reference code là [EasyAndFastGUI 19703 trên CodeBase](https://www.mql5.com/en/code/19703); bản lưu trong project được liệt kê tại [Update.md — Library](Update.md#library).
### Trading
 - Trading thực chất là gửi một `MqlTradeRequest` ra ngoài System, do `CTradingControl` thực hiện; mọi parameter của `MqlTradeRequest` do System điền bằng [Automation](Event.md#system-concept-automation) dựa trên [Event](Event.md#system-concept-event).
 - **Phạm vi:** những position / lệnh chờ mà request tác động.
  - Order: một lệnh (một ticket: position hoặc lệnh chờ).
  - Basket: các position đã deal trên một symbol + `ORDER_TYPE_BUY` / `ORDER_TYPE_SELL`, gộp mọi Strategy, kể cả lệnh không Magic; BasketID = `position_id` của position đầu tiên, giữ qua restart.
  - Portfolio: mọi position của account.
 - **Trading Action:** đc định nghĩa bởi enum `ENUM_TRADE_REQUEST_ACTIONS`
 - **Ghép role:** `CTradingControl` ghép các parameter do nhiều Strategy tính.
  - Vd `type` của MA Crossover, `sl` của Base PSAR / ATR, `volume` và Exit Basket của RiskManagement.
  - Cùng một parameter từ nhiều Strategy: lấy giá trị tốt nhất (`sl` gần giá vào nhất; Trailing = `sl` tính lại khi lệnh đang chạy, dời có lợi nhất); riêng `volume` và `type` loại trừ nhau.
 - **Trading Setting:** On / Off từng role lấy từ Strategy nào; `Setting_Risk` là một phần ([MT5 Library](#mt5-library), mục Risk Setting). Phương án ghép: [Việc chưa làm](#việc-chưa-làm).

### Strategy
 - Strategy chỉ là một Automation calculation các Parameter của `MqlTradeRequest` và SendEvent cho `CTradingControl`.
 - Manual cũng là một Strategy, StrategyID 0, có 2 role:
  - Entry: User chọn control trên GUI rồi Open Position.
  - Exit: User chủ động đóng lệnh.
 - Parameter mà Strategy tính là **role** của nó, trên một [Phạm vi](#trading) ([Quyết định × Phạm vi](#quyết-định--phạm-vi)); không cần đủ mọi parameter.
 - Đầu vào: [Event](Event.md#system-concept-event) của mọi **loại object** ([Event đầu vào](#event-đầu-vào)) trên các timeframe ([TF của Slot](#tf-của-slot)), ghép trên cùng nến, trong N nến hoặc theo thứ tự; value của [Indicator](IndicatorConcept.md#indicator-defines); hoặc Setting.
  * Vd Head & Shoulders (Reference 13. 17618), Cypher Harmonic (Reference 15. 17865) chỉ dựa trên Pattern: `sl` = pivot X, `tp` theo các pivot.
 - <a id="event-đầu-vào"></a>**Event đầu vào** của Strategy, theo loại Object fire:
   | Object fire | Ví dụ |
   |---|---|
   | Signal trên [Indicator](IndicatorConcept.md#indicator-defines) | AO cắt 0, RSI rời vùng quá mua |
   | Signal trên [Indicator on Indicator](IndicatorConcept.md#indicator-defines) | RSI cắt MA của nó |
   | Trading / Account | P/L của Position hoặc Basket, margin level, equity / drawdown |
   | Market Structure / Pattern | Swing, BOS, Candle Pattern (Pin Bar…), Chart Pattern, Harmonic Pattern, Zone |
  * Hướng (direction) là thuộc tính tùy loại Event: AO cắt 0 có hướng; button, Pin Bar, Swing High hoặc Inside Bar có thể không có hướng. Hướng của Event tự nó không phải quyết định giao dịch; Strategy diễn giải nó trong ngữ cảnh các Event được ghép.
 - Strategy gồm Slot và điều kiện; Judge là luật của điều kiện, dùng lại giữa các Strategy.
 - Mỗi indicator với rule theo role của nó là một [Base Indicator Strategy](IndicatorConcept.md#base-indicator-strategy).
 - **Position group:** một lần Entry cùng các lệnh thêm (grid / averaging), thường cùng hướng và đóng chung.

### TF của Slot

 - Strategy không có TF; chỉ Slot có TF, mỗi Slot có thể đặt riêng.
 - Slot không chỉ định Period (Default):
  + Các role của Slot được tính trên Period của Slot trong strategy; Trading action được thực hiện theo tick.
  + **EA Module:** vẽ Position / marker của Strategy theo Period của chart.
  + **Python Library:** tính sẵn trên mọi Period của symbol có trong CSymbolTFManager, để đổi Period là có dữ liệu vẽ.
 - Slot có TF cụ thể (vd H1): luôn đọc TF đó, trên Period nào cũng vậy; TF đó phải có trong Setting Symbol + TF.
  - Đọc nến đã đóng gần nhất của TF Slot tại lúc nến của Period đang tính đóng; không nhìn trước.
  - Ví dụ: chart M1, Slot 1 H1, các Slot khác Default (M1).
 - Đổi params / TF của Slot thì kết quả cũ không còn đúng: **Python Library:** tính lại.

### RiskManagement

 - RiskManagement là một loại Strategy, tự ra quyết định risk:
  - Concept Risk lấy của tác giả, cách làm theo [Reference-only](#reference-only).
  - Nghe [Event](Event.md#system-concept-event) về Trading và account (position mở/đóng, equity, nến mới, Entry của Strategy).
 - Parameter của `MqlTradeRequest` mà RiskManagement tính và cách tính:
  - `volume`: theo `RiskMode`; cap theo margin.
    - Risk %, Fixed cash: từ khoảng `sl`; không có `sl` thì Min lot (Manual: lot đã chọn).
    - Fixed lot size: lot của symbol trên RAM, khởi đầu Min lot, sau đó là lot chọn cuối ở Manual (`TRADE_SETUP_EVENT_LOT`, [CTradingControl::FixedLot](../../Library/Trading/TradingControl.mqh)); không ghi DB.
  - `tp`: giá vào ± khoảng `sl` × `TakeProfitRatio`.
  - Chặn Entry (không gửi request) chỉ khi margin không đủ cho `volume` hoặc vượt giới hạn Basket / Portfolio; không có `sl` / `tp` không chặn.
  - Exit Basket: 
   * Khi có 1 position lỗ chạm `percentage_risk_per_operation`.
   * Khi có từ 2 position lỗ chạm `MaxBasketLossPercent`.
  - Exit Portfolio: lỗ chạm `MaxPortfolioLossPercent`.
  - Take Profit với Basket và Portfolio đều dùng chung TakeProfitRatio x Lost
   * Với Basket lỗ MaxBasketLossPercent (3%) thì cắt lỗ thì lãi TakeProfitRatio x  MaxBasketLossPercent cũng take profit  
- Setting riêng là `Setting_Risk`, độc lập với Setting của Strategy.

### BackTest

Hai mức đo, không thay nhau:

 - **Một Strategy:** độ tin cậy của Strategy đó trước khi bật Trading On; Strategy ghép còn phải hơn các base của nó ([IndicatorConcept.md](IndicatorConcept.md#base-indicator-strategy)).
 - **Một phương án:** khi Trading ghép role từ nhiều Strategy ([Trading](#trading)), backtest cả phương án đó; không suy ra từ kết quả của từng Strategy riêng lẻ.
- [] Tạm hoãn cả hai: Trading On hiện chưa đòi backtest (lý do đi tắt ở [RiskManagement.md](../Implementation/RiskManagement.md#đi-tắt)).

## Quyết định × Phạm vi

| Quyết định | Order (một lệnh) | Basket | Portfolio (account) |
|---|---|---|---|
| **Entry** (giá vào: market hoặc lệnh chờ) | Strategy mở theo signal ([Rule và role](IndicatorConcept.md#rule-và-role)) | Thêm leg: grid, averaging | Chặn Entry theo giới hạn account ([RiskManagement](#riskmanagement)) |
| **Lot** (khối lượng lệnh: lot, margin cap) | RiskManagement tính volume theo khoảng SL ([RiskManagement](#riskmanagement)) | | |
| **SL** (mức dừng lỗ lúc vào lệnh) | [Base Indicator](IndicatorConcept.md#rule-và-role) hoặc Strategy cung cấp SL | | |
| **Trailing** (dời SL khi lệnh đang chạy) | [Base Indicator](IndicatorConcept.md#rule-và-role) hoặc Strategy cung cấp Trailing | | |
| **TP** (một hoặc nhiều mức) | Base và Strategy cung cấp TP ([RiskManagement](#riskmanagement)) | TP chung hoặc hoà vốn có trọng số | |
| **Exit** | Strategy cung cấp Exit theo điều kiện signal ([Rule và role](IndicatorConcept.md#rule-và-role)) | Cắt lỗ hoặc quản lý Basket ([RiskManagement](#riskmanagement)) | Cắt theo giới hạn Portfolio ([RiskManagement](#riskmanagement)) |

## Reference-only

- **Strategy:** `D:\MT5-Dev\Experts\Allan Munene Mutiiria\Automating Trading Strategies`
  - Các file `.mq5` được đánh số theo bài; Profitunity là bài 01.
- **Risk Management:** `D:\MT5-Dev\Experts\Solomon Anietie Sunday\Risk Management`
  - Concept giữ tên của tác giả để rà soát đối chiếu được với bản gốc ([Clear Understand](../AGENTS.md#clear-understand)).
- **Khác biệt chung của cả hai reference so với [System](../AGENTS.md#system):**
  - Không có Event: hỏi trong OnTick, nên không có [Automation](Event.md#system-concept-automation).
  - Mỗi EA làm đơn lẻ với một strategy; System chạy nhiều Strategy cùng lúc, phân biệt bằng StrategyID trong magic.
  - Khi implement: chỉ lấy concept, làm lại theo [Working on Event](Event.md#system-concept-working-on-event) và đồng bộ theo [Sync Everywhere](SyncEverywhere.md#sync-everywhere).
- **Cách dùng:**
  - Trước tiên cần khớp kết quả EA gốc; khác biệt về hành vi (vd nến đang chạy, phạm vi account, nhiều strategy) cần có backtest chứng minh.
  - Mục tiêu là tìm ra quyết định chung của Strategy, không sao chép logic riêng của từng EA.

## No Duplicate và Sync Everywhere

- No Duplicate: concept Strategy, role, Judge và Trading đã có trong [AGENTS.md](../AGENTS.md#rules-gate-mục-tiêu-xuyên-suốt); implementation không thêm class/method khi đã có object sở hữu data hoặc behavior tương đương.
- Sync Everywhere: thay đổi Strategy contract hoặc Setting phải đồng bộ EA Module, MT5 Library, Python Library, EA Web và Database theo [Working Area](../AGENTS.md#project-and-working-area) và [Sync Everywhere](SyncEverywhere.md#sync-everywhere).
- Còn lệch: Python Library chưa gióng `tf_enum` của Slot; EA Web chưa đủ MA để backtest/vẽ slot source; [Việc chưa làm](#việc-chưa-làm) ghi các phần chưa hoàn tất.

Các mục dưới đây ghi cách triển khai và trạng thái theo từng thành phần, không định nghĩa lại khái niệm.

## EA Module

- [v] **Đã có strategy flags:** trading_enabled / available / show_on_chart.
  - Tab Strategy, toggle Trade (`trading_enabled`): khởi tạo Strategy, tạo template cho các slot (`Create_IndicatorTemplate`); không quyết định vào lệnh.
- [v] **Tab Trading** ([GUIPannel_TabTrading.mqh](../../Experts/Anhnt/Example%20EA/4.%20Combination%20EA%20V5/GUIPannel/GUIPannel_TabTrading.mqh)): hàng trên Auto, Manual (hai cách Entry), Risk (mọi Position), Trade Manage; mở một thì hai cái kia đóng.
  - Auto: mỗi Strategy available một row, switch = tham gia Trading (`Setting_Risk.EntryStrategies`, `CTradingControl` dùng); Manual Open không phụ thuộc Auto.
  - Manual: Buy/Sell + Open, Order Type, SL, TP, MaxLot, Lot (MaxLot → MinLot; Risk không tính được lot thì MinLot), Magic.
    - Action trong Manual: Buy / Sell / Lose / Profit (Position của EA trên symbol), All (account); mỗi nút kèm lãi/lỗ của nhóm nó đóng (`CTradingControl::FloatingProfit`).
  - Risk: `Setting_Risk` trên RAM; Lot Size, Stop Loss, Trailing, Adaptive Risk, Broker & Margin Safety, Basket Risk, Portfolio Risk, mỗi lúc mở một.
    - Header Lot Size, Stop Loss, Trailing có "ON/OFF" + switch (bật/tắt mọi row; Lot Size luôn ON); Adaptive Risk, Basket Risk, Portfolio Risk: switch = `EnableAdaptiveRisk` / `EnableBasketRisk` / `EnablePortfolioRisk`, bật thì mở section.
- [v] **Tab Risk:** section theo `grp` (input group của tác giả), control theo `type` (bool switch, ENUM_ combobox chữ của tác giả, int/double spin box); key group V5 ở tab Trading.
- [v] **Đã đổi tên judge dữ liệu:** `color` thành `rising`; màu chỉ là cách vẽ.
- [v] EA nạp `StrategyCollection` vào RAM một lần qua `CStrategyCollection`; bar mới tự judge trên `CStrategyBase`.
- [v] **TF của Slot:** tab Strategy có combobox TF cho từng slot (`Update_StrategyIndicator_Setting` → `SLOT_CHANGED`).
- [v] **Bỏ `tf_enum` của Strategy:** `SaveSlot_Strategy` chỉ lưu slot; tab Strategy không còn nghe `TF_CHANGED`. Compile 0/0.
- [v] **Sửa Setting_Risk:** 
 * GUI gọi `CRiskSetting::SetValue`, 
 * còn `CTradingControl` chỉ ghi DB (Web: [RiskManagement.md](../Implementation/RiskManagement.md#vướng-mắc)).
 * Tab Risk Management hiện mọi key lưu DB (cả `RiskMode`, `percentage_risk_per_operation`, `FixedCashRisk`), sửa là ghi DB ngay (`save_now`, `lparam` 1 của `RISK_SETTING_EVENT_CHANGED`).
 * Tab Trading (Lot Size) làm việc trên RAM, ghi khi OnDeinit; hai tab cùng nghe Event nên hiện một giá trị ([GUIPannel_TabQuickSetting_Risk.mqh](../../Experts/Anhnt/Example%20EA/4.%20Combination%20EA%20V5/GUIPannel/GUIPannel_TabQuickSetting_Risk.mqh)). Compile 0/0, chưa test terminal.

## MT5 Library

### Strategy Implemenation
#### MT5 Library:
 - [v] **Engine chung:** `UseCases\Strategies\StrategyEngine.mqh`; `CStrategyCollection::Calculate` dùng judge chung thay switch theo tên.
 - [v] **Conditions:** `D:\MT5-Dev\Library\UseCases\Strategies\Conditions` 
 - [v] **Event của Strategy:** `CStrategyBase` (sở hữu kết quả) tự `EventSend` khi có row mới: `STRATEGY_EVENT_ENTRY` / `STRATEGY_EVENT_EXIT`, contract `lparam` / `dparam` / `sparam` khai trong `EventDefines.mqh`; role mới thì thêm Event ID theo [Working on Event](Event.md#system-concept-working-on-event).
 - [v] **Đã có strategy trên từng cặp:** `CStrategyCollection` và `CStrategyBase` cho mỗi cặp của `Setting_SymbolTF`.
 - [v] **Bỏ `tf_enum` của Strategy:** `
  + CStrategySetting` không còn `m_tf` / `Timeframe()`, 
  + Bỏ `STRATEGY_MANAGER_EVENT_TF_CHANGED`; 
 - `CStrategyCollection::Calculate` judge live trên `::Period()`.
 -`CBarMarkerCollection` vẽ series của Period chart. 
 - **TF của Slot** ([TF của Slot](#tf-của-slot)): `CStrategyPairSlots` lấy indicator / signal theo `tf_enum` của slot (`PERIOD_CURRENT` = TF của cặp); `CStrategyEngine::Calculate` gióng shift của cặp sang nến đã đóng gần nhất của TF slot.
 - Series của TF slot có trên RAM khi TF đó có trong `Setting_SymbolTF`; chưa có thì bar của Strategy chờ (`WRONG_VALUE`, `RetryPending`).
 - Rule nhiều slot (`ma_cross`): đọc giá trị theo thời gian của TF slot của row; các slot của rule nên cùng TF.
 - [v] **Tính lại khi đổi:** `SLOT_CHANGED` → `CSyncManager` xoá mark của Strategy, `CPythonBridge` ghi `Python_Jobs.flag`; code đã có, chưa đo trên terminal.
 - **Profitunity:** fractal sift 2 trống (theo cách của EA gốc) nên dùng shift 3.
  + Setting_Profitunity.mqh,  
  + CSetting_Profitunity : CStrategySetting
  + CStrategyManager ghi nó vào các bảng Setting_Strategy*.
  + [v] **Parity Profitunity:** `Test\Strategy Parity Engine.mq5` đã kiểm tra 1000 nến khớp 6/6 BTCUSD M1.
### Python Library:
 - Strategy\engine.py, cùng rule với EA.
 - main.py.
### Risk Management 
#### MT5 Library:
 - [v] **CRiskSetting:**
   + [RiskSetting.mqh](../../Library/Entities/Settings/Risk/RiskSetting.mqh), `Setting_Risk` trên RAM: mỗi input của Part 7 đúng như tác giả khai (group, type, name, default, comment), theo thứ tự; tìm theo `name`.
    - Group V5 (tab Trading): `EntryStrategies`, `StopLossTemplates`, `TrailingTemplates` (danh sách id, `IsIdOn` / `SetIdOn`).
    - Chữ của giá trị enum: `RiskModeText` / `RiskBaseText` / `PortfolioScopeText`, `RiskEnumItems(type)` ([RiskManagementDefines.mqh](../../Library/Entities/Defines/RiskManagementDefines.mqh)).
    - [v] `EnableBasketRisk` cho `CTradingControl::BasketManage`
 - [v] **RiskManagementDefines:** [RiskManagementDefines.mqh](../../Library/Entities/Defines/RiskManagementDefines.mqh), enum và tier của Part 7, `STradePlan`, `FloorToVolumeStep`.
 - [v] **EventDefines:** [EventDefines.mqh](../../Library/Entities/Defines/EventDefines.mqh), `ENUM_RISK_SETTING_EVENT`, `ENUM_RISK_EVENT` (`RISK_EVENT_ENTRY_BLOCKED`).
 - [v] **Risk (3 tầng của Part 7):** [TradingControl_Risk.mqh](../../Library/Trading/TradingControl_Risk.mqh), module của `CTradingControl`; chỉ lấy concept, không giữ class của tác giả (Reference ghi cạnh từng method: `Solomon Anietie Sunday\Risk Management\7. 24477 ...\Include\TradeRisk.mqh`, `BasketRisk.mqh`, `PortfolioRisk.mqh`). Tầng chặn Entry fire `RISK_EVENT_ENTRY_BLOCKED` (dparam 0 trade, 1 basket, 2 portfolio).
    - Data ở object sở hữu: `CSymbol::ValuePerLot`, `CSymbol::StopLevelMin` (một luật khoảng cách stop, `CTrading::CorrectStopLoss` dùng chung), `CAccount::DrawdownPercent` (đỉnh equity), `CAccount::BaseAmount` (Balance / Equity / Free Margin theo `ENUM_RISK_BASE`, Free Margin theo NRTR 47. 21096), `CMarketCollection::BasketState`.
    - Trade (`BuildPlan`, `ValidatePlan`, `CheckTradeRisk`): áp cho mọi lệnh lúc vào: SL, lot, margin cap; position đã mở thuộc Basket. SL lấy từ base (`CTradingControl::StopLossPrice`), TP theo [RiskManagement](#riskmanagement). Không port `canOpenTrade` (chặn OnTick mở lại; System mỗi Entry là một Event), [RiskManagement.md](../Implementation/RiskManagement.md). Entry mode/pending offset không port: Strategy quyết định `ENUM_ORDER_TYPE`.
    - Basket (`BasketAcceptsNewTrade`, `CheckBasketRisk`, `BasketManage`): [Basket](#strategy) của Part 7. Chặn Entry khi vượt margin, hoặc ngược chiều basket khi tắt `AllowHedging`; không đếm số position (bỏ `MaxBasketPositions`). `BasketManage` trên nến mới của TF chart: cắt lỗ, giữ quá N bar → `ClosePositions(symbol, 0, 0, "Basket")`.
    - Portfolio (`PortfolioCanOpenPosition`, `CheckPortfolioRisk`, `PortfolioPrintSnapshot`): chỉ chặn Entry như tác giả; snapshot theo `LogPortfolioSnapshot`.
  - [v] **CMarketCollection:** [MarketCollection.mqh](../../Library/Collections/MarketCollection.mqh), `HasPosition` / `PositionsCount` lọc thêm MagicID, StrategyID; `ClosePositions` / `TrailPositions` duyệt position trên RAM qua `HasPosition`.
  - [v] **CTradingControl:** [TradingControl.mqh](../../Library/Trading/TradingControl.mqh), đọc/ghi `Setting_Risk`.
    - `TradeEntry`: `STRATEGY_EVENT_ENTRY` của strategy có trong `EntryStrategies`, hoặc Manual (`TRADE_SETUP_EVENT_SEND` từ `CButton`, StrategyID 0, comment "Manual") → Trade (`CheckTradeRisk`; không `sl`: `LotsMin`, Manual: lot đã chọn) → Basket → Portfolio → `OpenPosition` ngay.
    - Exit của Manual: Close All của panel, source `Manual`.
    - `OnRiskNewBar`: `SERIES_EVENTS_NEW_BAR` của TF chart → `BasketManage`.
    - `StopLossPrice(key, shift)`: một chỗ đọc giá trị base cho role SL; Entry `StopLossTemplates` shift 1 (nến đã đóng), Trailing `TrailingTemplates` shift 0 (nến hiện tại).
    - [v] **Trailing:** `TICK_EVENT_NEW` của symbol, có base ON trong `TrailingTemplates` → `TrailPositions` (refresh rồi đọc base, theo ngoại lệ của [Event.md](Event.md#nguyên-tắc-chung)): SL của mọi position của EA trên symbol (MagicID, cả Manual) dời tới giá trị base khi có lợi (BUY cao hơn, SELL thấp hơn), TP giữ; `ModifyPosition` (CTrading) kiểm StopLevel/FreezeLevel. Bỏ `ModifyPositions` (không lọc magic). Compile 0/0, chưa test terminal.
    - TP: đặt một lần lúc Entry, khoảng SL × `TakeProfitRatio`; không đổi khi Trailing.
    - [v] **Exit:** `STRATEGY_EVENT_EXIT` (side = phía bị đóng, chỉ event mới) của strategy có trong `EntryStrategies` → `OnStrategyExit` → `ClosePositions(symbol, strategy_id, direction)`: đóng position của EA (MagicID) trên symbol theo StrategyID và phía; Close All dùng chung `ClosePositions(symbol, 0, 0)`. Bỏ `ClosePositions` cũ (không lọc magic) và `SendNewOrder` (không ai gọi). Compile 0/0, chưa test terminal.
    - `TRADE_SETUP_EVENT_CLOSE_ALL` (nút Close All của panel): lparam > 0 chỉ đóng position của strategy đó; sparam = symbol chỉ đóng position của EA trên symbol đó.
  - [v] **CBaseObjExt:** [BaseObjExt.mqh](../../Library/Entities/Bases/BaseObjExt.mqh), StrategyID trong magic.
    - Magic `ulong`: bit 0–15 MagicID (EA, `inpMagicNumber`), 32–63 StrategyID.
    - GroupID1/2 còn trống.
  - [v] **CTrading:** [Trading.mqh](../../Library/Trading/Trading.mqh), magic giữ đủ 64 bit khi ghép PendReqID.
- [v] **CChartObj:** `OnInitEvent` tắt `CHART_SHOW_TRADE_LEVELS` (đường SL/TP của terminal).
- `Setting_Risk` đọc đủ các key của `CRiskSetting`. vướng mắc ở [RiskManagement.md](../Implementation/RiskManagement.md#vướng-mắc).

## Python Library

- [v] **Python engine:** `Strategy\engine.py` đọc `Setting_StrategyCondition` và RULES.
- [v] **Đã chuyển Profitunity sang engine chung:** kết quả khớp EA.
- [v] **Tính lại khi đổi:** `jobs_changed()` chạy lại Current worker; Strategy không còn mark thì `calculate_new` xoá kết quả cũ rồi tính lại; `libdb.strategies()` đọc lại params / `tf_enum` của Slot mỗi lần. Code đã có, chưa đo trên terminal.
- [v] Engine tính Strategy trên mọi cặp: mọi symbol × mọi TF của bảng `timeframes` (`pairs_in_order`, cặp chart và `Setting_SymbolTF` trước); `libdb.strategies()` không còn đọc `tf_enum` của Strategy (`ast.parse` pass).
- [] **TF của Slot:** `engine._buffers` tính mọi slot trên nến của cặp, chưa đọc `tf_enum` của slot (slot H1 trên cặp M1 vẫn tính trên M1).
  - `StrategyCollection` (lịch sử EA đọc) vì vậy lệch với EA live khi slot có TF riêng; cần gióng như `CStrategyEngine::Calculate`.

## EA Web

 - [v] **Đã có engine/judge chung:** `src\strategies\conditions.ts` theo cùng rule với EA và Python.
 - [v] `StrategyRow` (`src\strategies\types.ts`) không còn `tf_enum`; `tsc --noEmit` pass.
 - [] **Backtest strategy trên TradeCanvas:** Tạm thời chưa test.

## Database

 - [v] **Strategy:** 
  + `Setting_Strategy` (`trading_enabled` = khởi tạo / tạo template slot; tham gia Trading
  + `Setting_Risk.EntryStrategies`), Slot ở `Setting_StrategyIndicator` (source, params, tf), điều kiện ở `Setting_StrategyCondition` (role, side, slot, rule).
- [v] **tf_enum của Slot:** `Setting_StrategyIndicator.tf_enum` (NULL = TF của cặp), theo [TF của Slot](#tf-của-slot).
- [v] **Bỏ `Setting_Strategy.tf_enum`:** 
- [v] **Python Library:** Python ghi `StrategyCollection` trong DB account.
  - Một row gồm `name`, `tf_enum`, `strategy_id`, `role`, `bar_time`, `signal_direction`; không phải lệnh thật.
- [v] Không thêm table riêng cho engine Strategy.
  - Kết quả và Setting theo nguyên tắc và phân công ghi trong [WorkingOnRamSaveToDB.md](WorkingOnRamSaveToDB.md).
- [v] **Risk Setting:** table `Setting_Risk` trong DB của account: `ord` (khoá chính, thứ tự input), `grp`, `type`, `name` (UNIQUE), `value`, `comment`.
  - `CTradingControl` ghi default, giữ giá trị đã sửa, cập nhật ord/grp/type/comment theo `CRiskSetting`, xoá key không còn trong `CRiskSetting`.
- [v] **BasketID:** `TradingOrderDetail.basket_id` (0 = không biết), `CTradingControl` ghi ở mọi row của position;


