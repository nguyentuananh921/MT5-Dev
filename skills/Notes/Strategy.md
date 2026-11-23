# Strategy Note

Strategy là một **quyết định trong trading**, áp dụng trên một **phạm vi** (Order, Basket hoặc Portfolio), dựa trên việc ghép các [Event](Event.md) do các **loại object** tạo ra trên các timeframe khác nhau.

Các mục trong note là **concept dùng để thống nhất cách hiểu** giữa EA, Library, Python và Web; chưa phải spec implementation chi tiết.

## Concept

### Strategy

- Một Strategy cung cấp một hoặc nhiều role; mỗi **role** là một ô trong bảng [Quyết định × Phạm vi](#quyết-định--phạm-vi); không cần đủ tất cả.
- Strategy gồm nhiều Slot và các điều kiện; role nằm ở điều kiện, mỗi điều kiện đọc một Slot ([TF của Slot](#tf-của-slot)).
- Strategy không phụ thuộc indicator: Event đến từ mọi **loại object** ([Nguồn Event](Event.md#nguồn-event)).
  - Vd Head & Shoulders (Reference 13. 17618), Cypher Harmonic (Reference 15. 17865) chỉ dựa trên Pattern; Harmonic: SL = pivot X, TP theo các pivot.
- Các Event có thể được ghép trên cùng nến, trong một khoảng N nến, hoặc theo thứ tự (vd Harmonic X → A → B → C → D).
- Judge là luật đánh giá điều kiện, dùng lại được giữa nhiều Strategy; một Strategy mới chủ yếu là một tổ hợp điều kiện mới.
- Mỗi indicator với các rule theo role của nó là một BaseStrategy ([BaseIndicatorStrategy.md](BaseIndicatorStrategy.md)); so với base: [BackTest](#backtest).
- Strategy luôn tính mọi role của nó và send Event theo [Event.md](Event.md#working-with-event); Trading và các listener khác tự nghe và làm việc của mình.
- Trading On = [Trading](#trading) dùng tất cả các role mà Strategy đang có; Trading Off từng role của Strategy là hoàn toàn độc lập.
- Mức giá (Entry, SL, TP) lấy từ params của Event hoặc từ Setting.
- **Basket** là các Position của EA trên một symbol, gộp mọi Strategy (concept của tác giả Part 5–7).
  - Mỗi lệnh mang StrategyID để biết strategy nào mở/đóng lệnh khi chạy thật và khi test; không dùng để chia basket.
- **Position group** là một lần Entry cùng các lệnh thêm (grid/averaging), thường cùng hướng và đóng chung.

### TF của Slot

- Strategy không có TF; chỉ Slot có TF, mỗi Slot đặt riêng.
- Slot không chỉ định Period (Default):
  - Trading (Open Position, Modify SL, Trailing…): trên Period hiện tại; việc thực hiện theo tick.
  - Display: vẽ Position / marker của Strategy theo Period của chart.
  - Calculation: tính sẵn trên mọi Period của symbol có trong Setting Symbol + TF, để đổi Period là có dữ liệu vẽ.
- Slot có TF cụ thể (vd H1): luôn đọc TF đó, trên Period nào cũng vậy; TF đó phải có trong Setting Symbol + TF.
  - Đọc nến đã đóng gần nhất của TF Slot tại lúc nến của Period đang tính đóng; không nhìn trước.
  - Ví dụ: chart M1, Slot 1 H1, các Slot khác Default (M1).
- Đổi params / TF của Slot thì kết quả cũ không còn đúng: tính lại.

### RiskManagement

RiskManagement là một loại Strategy, tự ra quyết định risk:

- Concept Risk lấy của tác giả, cách làm theo [Reference-only](#reference-only).
- Nghe [Event](Event.md) về Trading và account (position mở/đóng, equity, nến mới, Entry của Strategy).
- Send Event như mọi Strategy để thực hiện quyết định: chặn Entry, đóng Basket, close all khi vượt giới hạn Portfolio.
- Setting riêng là `Setting_Risk`, độc lập với Setting của Strategy.

### Trading

Trading là nơi thực hiện quyết định theo role; mỗi role lấy từ một hoặc nhiều Strategy:

- Role của Strategy và phạm vi của Trading độc lập: không phải Strategy nào cũng có đủ role, nên Trading ghép role từ nhiều Strategy.
  - Vd Entry của MA Crossover, SL của Base PSAR / ATR, Lot của RiskManagement, Exit Basket của RiskManagement.
  - Một role của trading ghép được nhiều Strategy cùng lúc (không loại trừ nhau): lấy giá trị tốt nhất của các Strategy có role đó đang On.
    - SL: stop hợp lệ gần giá vào nhất (bảo vệ nhất) thắng.
    - Trailing = role SL tính lại khi lệnh đang chạy: giá dời SL có lợi nhất thắng; không cần cơ chế riêng cho từng loại Strategy.
    - Chỉ Lot Size, Order Type (và Buy / Sell) loại trừ nhau.
  - Lưu/chọn phương án ghép: [Phương án áp dụng khi live](#việc-chưa-làm).
- Khi nhiều Strategy cùng ra quyết định cho cùng một lệnh, Trading là nơi áp dụng luật ưu tiên và giải quyết xung đột.
- **Trading Setting** cấu hình cách Trading ghép role, gồm On/Off từng role lấy từ Strategy nào và các cấu hình trading khác.
  - `Setting_Risk` chỉ là một phần của Trading Setting.
  - Công tắc hiện có: xem [Library](#library), mục Risk Setting.

### BackTest

Hai mức đo, không thay nhau:

- **Một Strategy:** độ tin cậy của Strategy đó trước khi bật Trading On; Strategy ghép còn phải hơn các base của nó ([BaseIndicatorStrategy.md](BaseIndicatorStrategy.md)).
- **Một phương án:** khi Trading ghép role từ nhiều Strategy ([Trading](#trading)), backtest cả phương án đó; không suy ra từ kết quả của từng Strategy riêng lẻ.
- [] Tạm hoãn cả hai: Trading On hiện chưa đòi backtest (lý do đi tắt ở [Update.md](Update.md)).

## Quyết định × Phạm vi

| Quyết định | Order (một lệnh) | Basket | Portfolio (account) |
|---|---|---|---|
| **Entry** (giá vào: market, hoặc lệnh chờ ở một mức) | Mở lệnh theo signal (Profitunity: 4 event cùng BUY trên nến) | Thêm leg: grid, averaging | Chặn Entry khi vượt giới hạn (Part 7 `CPortfolioRisk::CanOpenPosition`) |
| **Lot** (khối lượng lệnh: lot, margin cap) | RiskManagement: `RiskMode` (Risk %, Fixed cash, Fixed lot) theo khoảng SL, cap theo margin (Part 2–4 `CTradeRisk`) | | |
| **SL** (mức dừng lỗ lúc vào lệnh) | ATR × 1.5; Harmonic: pivot X / fibo extension | | |
| **Trailing** (dời SL khi lệnh đang chạy: trailing, breakeven) | PSAR | | |
| **TP** (một hoặc nhiều mức) | Ratio × khoảng SL; Harmonic: TP1/TP2/TP3 theo các pivot | TP chung, hoà vốn có trọng số (Grid EA 17350) | |
| **Exit** | AO cắt 0 xuống đóng Buy (Profitunity); MA cắt ngược | Cắt lỗ cả basket, giữ quá N bar (Part 7 `CBasketRisk::Manage`) | Cắt khi drawdown account |

## Reference-only

- **Strategy:** `D:\MT5-Dev\Experts\Allan Munene Mutiiria\Automating Trading Strategies`
  - Các file `.mq5` được đánh số theo bài; Profitunity là bài 01.
- **Risk Management:** `D:\MT5-Dev\Experts\Solomon Anietie Sunday\Risk Management`
  - Concept giữ tên của tác giả theo **New Concept** ([CodingRule.md](../rules/CodingRule.md#implementation-rule)).
- **Khác biệt chung của cả hai reference so với [System](../AGENTS.md#system):**
  - Không có Event: hỏi trong OnTick, nên không có [Automation](../AGENTS.md#automation).
  - Mỗi EA làm đơn lẻ với một strategy; System chạy nhiều Strategy cùng lúc, phân biệt bằng StrategyID trong magic.
  - Khi implement: chỉ lấy concept, làm lại theo [Working with Event](Event.md) và đồng bộ theo [Sync Everywhere](SyncEverywhere.md#sync-everywhere).
- **Cách dùng:**
  - Trước tiên cần khớp kết quả EA gốc; khác biệt về hành vi (vd nến đang chạy, phạm vi account, nhiều strategy) cần có backtest chứng minh.
  - Mục tiêu là tìm ra quyết định chung của Strategy, không sao chép logic riêng của từng EA.

Các mục dưới đây ghi cách triển khai và trạng thái theo từng thành phần, không định nghĩa lại khái niệm.

## EA Module

- [v] **Đã có strategy flags:** trading_enabled / available / show_on_chart.
  - Tab Strategy, toggle Trade (`trading_enabled`): khởi tạo Strategy, tạo template cho các slot (`Create_IndicatorTemplate`); không quyết định vào lệnh.
- [v] **Tab Trading** ([GUIPannel_TabTrading.mqh](../../Experts/Anhnt/Example%20EA/4.%20Combination%20EA%20V5/GUIPannel/GUIPannel_TabTrading.mqh)): section Auto, Lot Size, Stop Loss, Trailing; header có "ON/OFF" + switch (bật/tắt mọi row; Lot Size luôn ON), row chỉ có switch.
  - Auto: mỗi Strategy available một row, switch = tham gia Trading (`Setting_Risk.EntryStrategies`, `CTradingControl` dùng); Manual Open không phụ thuộc Auto.
  - Section Manual: header "Manual: MaxLot" (hoặc "no risk"), nút Buy/Sell, SL, TP, MaxLot, Lot (MaxLot → MinLot; Risk không tính được thì MinLot trở lên).
- [v] **Tab Risk:** section theo `grp` (input group của tác giả), control theo `type` (bool switch, ENUM_ combobox chữ của tác giả, int/double spin box); key group V5 ở tab Trading.
- [v] **Đã đổi tên judge dữ liệu:** `color` thành `rising`; màu chỉ là cách vẽ.
- [v] EA nạp `StrategyCollection` vào RAM một lần qua `CStrategyCollection`; bar mới tự judge trên `CStrategyBase`.
- [v] **TF của Slot:** tab Strategy có combobox TF cho từng slot (`Update_StrategyIndicator_Setting` → `SLOT_CHANGED`).
- [v] **Bỏ `tf_enum` của Strategy:** `SaveSlot_Strategy` chỉ lưu slot; tab Strategy không còn nghe `TF_CHANGED`. Compile 0/0.
- [v] **Sửa Setting_Risk:** GUI gọi `CRiskSetting::SetValue`, còn `CTradingControl` chỉ ghi DB (Web chưa có chỗ sửa sẽ làm sau).

## Library

- [v] **Engine chung:** `UseCases\Strategies\StrategyEngine.mqh`; `CStrategyCollection::Calculate` dùng judge chung thay switch theo tên.
- [v] **Conditions:** `D:\MT5-Dev\Library\UseCases\Strategies\Conditions`
- [v] **Parity Profitunity:** `Test\Strategy Parity Engine.mq5` đã kiểm tra 1000 nến khớp 6/6 BTCUSD M1.
- [v] **Đã chốt Profitunity:** fractal dùng shift 3.
  - Shift 2 của EA gốc làm fractal trống nên không vào lệnh.
- [v] **Event của Strategy:** `CStrategyBase` (sở hữu kết quả) tự `EventSend` khi có row mới: `STRATEGY_EVENT_ENTRY` / `STRATEGY_EVENT_EXIT`, contract `lparam` / `dparam` / `sparam` khai trong `EventDefines.mqh`; role mới thì thêm Event ID theo [Luồng thêm Event](Event.md#luồng-thêm-event).
- [v] **Đã có strategy trên từng cặp:** `CStrategyCollection` và `CStrategyBase` cho mỗi cặp của `Setting_SymbolTF`.
- [v] **Bỏ `tf_enum` của Strategy:** `CStrategySetting` không còn `m_tf` / `Timeframe()`, bỏ `STRATEGY_MANAGER_EVENT_TF_CHANGED`; `CStrategyCollection::Calculate` judge live trên `::Period()`, `CBarMarkerCollection` vẽ series của Period chart. Compile 0/0, chưa chạy trên terminal.
- [v] **TF của Slot** ([TF của Slot](#tf-của-slot)): `CStrategyPairSlots` lấy indicator / signal theo `tf_enum` của slot (`PERIOD_CURRENT` = TF của cặp); `CStrategyEngine::Calculate` gióng shift của cặp sang nến đã đóng gần nhất của TF slot. Compile 0/0, chưa chạy trên terminal.
  - Series của TF slot có trên RAM khi TF đó có trong `Setting_SymbolTF`; chưa có thì bar của Strategy chờ (`WRONG_VALUE`, `RetryPending`).
  - Rule nhiều slot (`ma_cross`): đọc giá trị theo thời gian của TF slot của row; các slot của rule nên cùng TF.
- [v] **Tính lại khi đổi:** `SLOT_CHANGED` → `CSyncManager` xoá mark của Strategy, `CPythonBridge` ghi `Python_Jobs.flag`; code đã có, chưa đo trên terminal.
- Risk Setting, StrategyID và Risk của Part 7: compile 0/0.
  - Chi tiết ghi trong header/comment của từng file.
  - Đã chạy trên terminal: `Setting_Risk` đọc đủ các key của `CRiskSetting`. Phần còn lại chưa test.
  - [v] **CRiskSetting:**
    - [RiskSetting.mqh](../../Library/Entities/Settings/Risk/RiskSetting.mqh), `Setting_Risk` trên RAM: mỗi input của Part 7 đúng như tác giả khai (group, type, name, default, comment), theo thứ tự; tìm theo `name`.
    - Group V5 (tab Trading): `EntryStrategies`, `StopLossTemplates`, `TrailingTemplates` (danh sách id, `IsIdOn` / `SetIdOn`).
    - Chữ của giá trị enum: `RiskModeText` / `RiskBaseText` / `PortfolioScopeText`, `RiskEnumItems(type)` ([RiskManagementDefines.mqh](../../Library/Entities/Defines/RiskManagementDefines.mqh)).
    - [v] `EnableBasketRisk` cho `CTradingControl::BasketManage`
  - [v] **RiskManagementDefines:** [RiskManagementDefines.mqh](../../Library/Entities/Defines/RiskManagementDefines.mqh), enum và tier của Part 7, `STradePlan`, `FloorToVolumeStep`.
  - [v] **EventDefines:** [EventDefines.mqh](../../Library/Entities/Defines/EventDefines.mqh), `ENUM_RISK_SETTING_EVENT`, `ENUM_RISK_EVENT` (`RISK_EVENT_ENTRY_BLOCKED`).
  - [v] **Risk (3 tầng của Part 7):** [TradingControl_Risk.mqh](../../Library/Trading/TradingControl_Risk.mqh), module của `CTradingControl`; chỉ lấy concept, không giữ class của tác giả (Reference ghi cạnh từng method: `Solomon Anietie Sunday\Risk Management\7. 24477 ...\Include\TradeRisk.mqh`, `BasketRisk.mqh`, `PortfolioRisk.mqh`). Tầng chặn Entry fire `RISK_EVENT_ENTRY_BLOCKED` (dparam 0 trade, 1 basket, 2 portfolio).
    - Data ở object sở hữu: `CSymbol::ValuePerLot`, `CSymbol::StopLevelMin` (một luật khoảng cách stop, `CTrading::CorrectStopLoss` dùng chung), `CAccount::DrawdownPercent` (đỉnh equity), `CMarketCollection::BasketState`.
    - Trade (`BuildPlan`, `ValidatePlan`, `CheckTradeRisk`): áp cho mọi lệnh lúc vào: SL, lot, margin cap; position đã mở thuộc Basket. SL lấy từ base (`CTradingControl::StopLossPrice`), TP theo [BaseIndicatorStrategy.md](BaseIndicatorStrategy.md#base-strategy). Không port `canOpenTrade` (chặn OnTick mở lại; System mỗi Entry là một Event), [RiskManagement.md](../Implementation/RiskManagement.md). Entry mode/pending offset không port: Strategy quyết định `ENUM_ORDER_TYPE`.
    - Basket (`BasketAcceptsNewTrade`, `CheckBasketRisk`, `BasketManage`): [Basket](#strategy) của Part 7. Chặn Entry khi vượt margin, hoặc ngược chiều basket khi tắt `AllowHedging`; không đếm số position (bỏ `MaxBasketPositions`). `BasketManage` trên nến mới của TF chart: cắt lỗ, giữ quá N bar → `ClosePositions(symbol, 0, 0, "Basket")`.
    - Portfolio (`PortfolioCanOpenPosition`, `CheckPortfolioRisk`, `PortfolioPrintSnapshot`): chỉ chặn Entry như tác giả; snapshot theo `LogPortfolioSnapshot`.
  - [v] **CMarketCollection:** [MarketCollection.mqh](../../Library/Collections/MarketCollection.mqh), `HasPosition` / `PositionsCount` lọc thêm MagicID, StrategyID; `ClosePositions` / `TrailPositions` duyệt position trên RAM qua `HasPosition`.
  - [v] **CTradingControl:** [TradingControl.mqh](../../Library/Trading/TradingControl.mqh), đọc/ghi `Setting_Risk`.
    - `OnStrategyEntry`: `STRATEGY_EVENT_ENTRY` của strategy có trong `EntryStrategies` → Trade → Basket → Portfolio → pending request (spread ≤ `MaxSpreadPips` × 10).
    - Manual: `TRADE_SETUP_EVENT_SEND` từ `CButton` → `TradeEntry` StrategyID 0 → plan của Risk (`ManualPlan`) nếu tính được, không thì lot đã chọn, không SL/TP, không Risk → mở ngay bằng `OpenPosition`, không qua ngưỡng spread.
    - `OnRiskNewBar`: `SERIES_EVENTS_NEW_BAR` của TF chart → `BasketManage`.
    - `StopLossPrice(key, shift)`: một chỗ đọc giá trị base cho role SL; Entry `StopLossTemplates` shift 1 (nến đã đóng), Trailing `TrailingTemplates` shift 0 (nến hiện tại).
    - [v] **Trailing:** `INDICATOR_EVENT_REFRESHED` (base refresh mỗi tick) của template ON trong `TrailingTemplates`, TF chart → `TrailPositions`: SL của mọi position của EA trên symbol (MagicID, cả Manual) dời tới giá trị base khi có lợi (BUY cao hơn, SELL thấp hơn), TP giữ; `ModifyPosition` (CTrading) kiểm StopLevel/FreezeLevel. Bỏ `ModifyPositions` (không lọc magic). Compile 0/0, chưa test terminal.
    - TP: đặt một lần lúc Entry, khoảng SL × `TakeProfitRatio`; không đổi khi Trailing.
    - [v] **Exit:** `STRATEGY_EVENT_EXIT` (side = phía bị đóng, chỉ event mới) của strategy có trong `EntryStrategies` → `OnStrategyExit` → `ClosePositions(symbol, strategy_id, direction)`: đóng position của EA (MagicID) trên symbol theo StrategyID và phía; Close All dùng chung `ClosePositions(symbol, 0, 0)`. Bỏ `ClosePositions` cũ (không lọc magic) và `SendNewOrder` (không ai gọi). Compile 0/0, chưa test terminal.
    - `TRADE_SETUP_EVENT_CLOSE_ALL` (nút Close All của panel): lparam > 0 chỉ đóng position của strategy đó; sparam = symbol chỉ đóng position của EA trên symbol đó.
  - [v] **CBaseObjExt:** [BaseObjExt.mqh](../../Library/Entities/Bases/BaseObjExt.mqh), StrategyID trong magic.
    - Magic `ulong`: bit 0–15 MagicID (EA, `inpMagicNumber`), 32–63 StrategyID.
    - GroupID1/2 còn trống.
  - [v] **CTrading:** [Trading.mqh](../../Library/Trading/Trading.mqh), magic giữ đủ 64 bit khi ghép PendReqID.
- [v] **CChartObj:** `OnInitEvent` tắt `CHART_SHOW_TRADE_LEVELS` (đường SL/TP của terminal).

## Library\Python

- [v] **Python engine:** `Strategy\engine.py` đọc `Setting_StrategyCondition` và RULES.
- [v] **Đã chuyển Profitunity sang engine chung:** kết quả khớp EA.
- [v] **Tính lại khi đổi:** `jobs_changed()` chạy lại Current worker; Strategy không còn mark thì `calculate_new` xoá kết quả cũ rồi tính lại; `libdb.strategies()` đọc lại params / `tf_enum` của Slot mỗi lần. Code đã có, chưa đo trên terminal.
- [v] Engine tính Strategy trên mọi cặp: mọi symbol × mọi TF của bảng `timeframes` (`pairs_in_order`, cặp chart và `Setting_SymbolTF` trước); `libdb.strategies()` không còn đọc `tf_enum` của Strategy (`ast.parse` pass).
- [] **TF của Slot:** `engine._buffers` tính mọi slot trên nến của cặp, chưa đọc `tf_enum` của slot (slot H1 trên cặp M1 vẫn tính trên M1).
  - `StrategyCollection` (lịch sử EA đọc) vì vậy lệch với EA live khi slot có TF riêng; cần gióng như `CStrategyEngine::Calculate`.

## EA V5\Web

- [v] **Đã có engine/judge chung:** `src\strategies\conditions.ts` theo cùng rule với EA và Python.
- [v] `StrategyRow` (`src\strategies\types.ts`) không còn `tf_enum`; `tsc --noEmit` pass.
- [] **Backtest strategy trên TradeCanvas:**
  - Tạm thời chưa test.

## Database

- [v] **Strategy:** `Setting_Strategy` (`trading_enabled` = khởi tạo / tạo template slot; tham gia Trading ở `Setting_Risk.EntryStrategies`), Slot ở `Setting_StrategyIndicator` (source, params, tf), điều kiện ở `Setting_StrategyCondition` (role, side, slot, rule).
- [v] **tf_enum của Slot:** `Setting_StrategyIndicator.tf_enum` (NULL = TF của cặp), theo [TF của Slot](#tf-của-slot).
- [v] **Bỏ `Setting_Strategy.tf_enum`:** 2026-11-21 dựng lại bảng bằng tay (cột có `REFERENCES timeframes` nên không `DROP COLUMN` được); mọi row đều NULL, không mất dữ liệu.
- [v] **Đã lưu điểm quyết định Strategy:** Python ghi `StrategyCollection` trong file của account.
  - Một row gồm `name`, `tf_enum`, `strategy_id`, `role`, `bar_time`, `signal_direction`; không phải lệnh thật.
- [v] Không thêm table riêng cho engine Strategy.
  - Kết quả và Setting theo nguyên tắc và phân công ghi trong [WorkingOnRamSaveToDB.md](WorkingOnRamSaveToDB.md).
- [v] **Risk Setting:** table `Setting_Risk` trong DB của account: `ord` (khoá chính, thứ tự input), `grp`, `type`, `name` (UNIQUE), `value`, `comment`.
  - `CTradingControl` ghi default, giữ giá trị đã sửa, cập nhật ord/grp/type/comment theo `CRiskSetting`, xoá key không còn trong `CRiskSetting`.
  - Sửa bảng bằng script chỉ khi EA đã gỡ khỏi chart (DB chạy WAL).

## Việc chưa làm

- [] **Params của event Entry:** giá vào, SL, TP; vd Harmonic lấy từ pivot.
- [] **Quản lý lệnh:** trung bình giá, breakeven; vd Pin Bar Averaging.
- [] **Role của base theo judge:** GUI và `StopLossPrice` đang viết cứng `IND_SAR` / `IND_ATR` ([BaseIndicatorStrategy.md](BaseIndicatorStrategy.md#base-strategy)).
- [] **Tham số riêng của strategy:** `Tolerance`, `PivotLeft`…, chỗ lưu trong Setting.
- [] **Phương án áp dụng khi live:** lưu/chọn Strategy nào cung cấp Entry, SL, Trailing, TP và Exit cho từng phương án.
- [] **Slot Bar information:** `COLLECTION_SERIES_ID` (Pin Bar, Swing…) chưa có strategy nào đọc.
- [] **Strategy MA Crossover (SMA 10 cắt SMA 20 trên nến vừa đóng):**
  - Entry = judge `ma_cross`, đọc slot `FastMA` / `SlowMA`.
  - Backtest các phương án exit cùng nến và bộ số:
    - A (EA gốc Part 7): SL = ATR × 1.5, TP = khoảng SL × 2.
    - B: SL = giá PSAR, TP = khoảng SL × 2.
    - C: SL = giá PSAR, trailing theo PSAR, không TP.
    - D: như C, thêm Exit = PSAR lật phía.
    - E: SL = ATR × 1.5, Exit = MA cắt ngược, không TP.
  - Entry đã code ngày 2026-11-16; EA compile 0/0 (2026-11-21), chưa test trên terminal.
    - Library: `ConditionMACross.mqh` (`CConditionMACross`, `ma_cross`) và `Setting_MACrossover.mqh` (id 2, slot FastMA/SlowMA, Entry BUY/SELL) đã thêm vào catalog.
    - Library\Python: `Strategy\engine.py` có rule `_ma_cross`; rule nhận `buffers_of(slot)`; `ast.parse` đã pass.
    - EA V5\Web: chưa làm; `STANDARD` trong `src\indicators\index.ts` chưa có MA phù hợp và `conditions.ts` chỉ nhận buffer của một slot.
    - Test: compile, bật Strategy, so EA với `StrategyCollection` của Python và EA gốc Part 7 trong Strategy Tester; parity test hiện viết cứng 4 slot Profitunity.
- [] **Strategy có slot là indicator trên indicator:** ví dụ `MA 9,0,EMA,RSI(14,CLOSE)`.
  - Library: `CStrategyManager::Create_IndicatorTemplate`, `CIndicatorsCollection`, `RefreshAvailable`, `CStrategyPairSlots::Indicator`.
  - Library\Python: `Strategy\engine.py` qua `indicators.compute`.
  - EA Module: parity test cần thêm slot có nguồn thay vì giữ handle cứng cho slot Profitunity.
  - EA V5\Web: `STANDARD` trong `src\indicators\index.ts` chưa có MA đủ để backtest/vẽ slot có nguồn.
