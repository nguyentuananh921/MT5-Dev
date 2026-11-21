# Strategy Note

Strategy là một **quyết định trong trading**, áp dụng trên một **phạm vi** (Order, Basket hoặc Portfolio), dựa trên việc ghép các [Event](Event.md) do các **loại object** tạo ra trên các timeframe khác nhau.

Các mục trong note là **concept dùng để thống nhất cách hiểu** giữa EA, Library, Python và Web; chưa phải spec implementation chi tiết.

## Concept

### Strategy

- Một Strategy cung cấp một hoặc nhiều role; mỗi **role** là một ô trong bảng [Quyết định × Phạm vi](#quyết-định--phạm-vi); không cần đủ tất cả.
  - Strategy luôn tính và send Event cho mọi role của nó; không Off role nào của Strategy.
  - On/Off là role ở [Trading](#trading): Trading có dùng role đó của Strategy hay không.
    - `Setting_Strategy.enabled` = Trading dùng tất cả các role mà Strategy đang có; vẫn Off được từng role ở Trading.
  - Mức giá (Entry, SL, TP) lấy từ params của Event hoặc từ Setting.
- **Basket** là các Position của EA (MagicID) trên một symbol, gộp mọi Strategy (concept của tác giả Part 5–7).
  - Mỗi lệnh mang StrategyID trong magic (bit 32–63, `CBaseObjExt::GetStrategyID`) để biết strategy nào mở/đóng lệnh khi chạy thật và khi test; không dùng để chia basket.
- **Position group** là một lần Entry cùng các lệnh thêm (grid/averaging), thường cùng hướng và đóng chung.

### RiskManagement

RiskManagement là một loại Strategy, tự ra quyết định risk:

- [System](../AGENTS.md#system) chỉ implement concept Risk của tác giả trên hệ Event sẵn có (xem [Reference-only](#reference-only)).
- Nghe [Event](Event.md) về Trading và account (position mở/đóng, equity, nến mới, Entry của Strategy).
- Send Event như mọi Strategy để thực hiện quyết định: chặn Entry, đóng Basket, close all khi vượt giới hạn Portfolio.
- Setting riêng là `Setting_Risk`, độc lập với Setting của Strategy.

### Trading

Trading là nơi thực hiện quyết định theo role; mỗi role lấy từ một hoặc nhiều Strategy:

- Role của Strategy và phạm vi của Trading độc lập: không phải Strategy nào cũng có đủ role, nên Trading ghép role từ nhiều Strategy.
  - Vd Entry của MA Crossover, SL của Base PSAR / ATR, Lot của RiskManagement, Exit Basket của RiskManagement.
  - Một role ghép được nhiều Strategy cùng lúc (không loại trừ nhau): lấy giá trị tốt nhất của các Strategy có role đó đang On.
    - SL: stop hợp lệ gần giá vào nhất (bảo vệ nhất) thắng.
    - Trailing = role SL tính lại khi lệnh đang chạy: giá dời SL có lợi nhất thắng; không cần cơ chế riêng cho từng loại Strategy.
    - Chỉ Lot Size, Order Type (và Buy / Sell) loại trừ nhau.
  - Lưu/chọn phương án ghép: [Phương án áp dụng khi live](#việc-chưa-làm).
- Khi nhiều Strategy cùng ra quyết định cho cùng một lệnh, Trading là nơi áp dụng luật ưu tiên và giải quyết xung đột.
- Khi áp dụng nhiều phương án Strategy, backtest theo từng phương án thay vì backtest từng Strategy riêng lẻ.
- `CTradeRisk` (lot, margin cap, `canOpenTrade`) áp cho mọi lệnh; Event từ `CButton` (Manual) chỉ không qua `canOpenTrade`.
  - Ngưỡng spread (`MaxSpreadPips`) nằm ở `CTradingControl::TradeEntry`, cũng không áp cho Manual.
- **Trading Setting** cấu hình cách Trading ghép role, gồm On/Off từng role lấy từ Strategy nào và các cấu hình trading khác.
  - `Setting_Risk` chỉ là một phần của Trading Setting.
  - Công tắc hiện có: xem [Library](#library), mục Risk Setting.

### TF của Strategy và source

- TF thuộc về source/slot của Event, không thuộc về Strategy.
  - `NULL` nghĩa là dùng TF của chart đang chạy Strategy.
- Strategy ra quyết định theo nến của TF chart.
  - Source ở TF khác đọc nến đã đóng gần nhất của TF đó.

## Quyết định × Phạm vi

| Quyết định | Order (một lệnh) | Basket | Portfolio (account) |
|---|---|---|---|
| **Entry** (giá vào: market, hoặc lệnh chờ ở một mức) | Mở lệnh theo signal (Profitunity: 4 event cùng BUY trên nến) | Thêm leg: grid, averaging | Chặn Entry khi vượt giới hạn (Part 7 `CPortfolioRisk::CanOpenPosition`) |
| **Lot** (khối lượng lệnh: lot, margin cap) | RiskManagement: `RiskMode` (Risk %, Fixed cash, Fixed lot) theo khoảng SL, cap theo margin (Part 2–4 `CTradeRisk`) | | |
| **SL** (mức dừng lỗ lúc vào lệnh) | ATR × 1.5; Harmonic: pivot X / fibo extension | | |
| **Trailing** (dời SL khi lệnh đang chạy: trailing, breakeven) | PSAR | | |
| **TP** (một hoặc nhiều mức) | Ratio × khoảng SL; Harmonic: TP1/TP2/TP3 theo các pivot | TP chung, hoà vốn có trọng số (Grid EA 17350) | |
| **Exit** | AO cắt 0 xuống đóng Buy (Profitunity); MA cắt ngược | Cắt lỗ cả basket, giữ quá N bar (Part 7 `CBasketRisk::Manage`) | Cắt khi drawdown account |

## Ghép Event thành quyết định

- Strategy được mô tả bằng các điều kiện (role, side, slot, rule); mỗi role tương ứng một ô (quyết định × phạm vi) trong bảng phía trên.
- Strategy không phụ thuộc indicator: Event đến từ mọi **loại object** ([Nguồn Event](Event.md#nguồn-event)).
  - Vd Head & Shoulders (Reference 13. 17618), Cypher Harmonic (Reference 15. 17865) chỉ dựa trên Pattern, không có indicator.
  - Với mỗi Event, Strategy khai Event đó cho role nào và role thực hiện thế nào (vd Harmonic: SL = pivot X, TP theo các pivot).
- Các Event có thể được ghép trên cùng nến, trong một khoảng N nến, hoặc theo thứ tự (vd Harmonic X → A → B → C → D).
- Judge là luật dùng để đánh giá điều kiện và có thể dùng lại giữa nhiều Strategy.
  - Một Strategy mới chủ yếu là một tổ hợp điều kiện mới.
- Mỗi indicator với các rule theo role của nó là một BaseStrategy.
  - Strategy ghép phải được so thống kê với các base của nó: xem [BaseIndicatorStrategy.md](BaseIndicatorStrategy.md).

## Ví dụ: Profitunity

| Role / side | Event cần có trên nến |
|---|---|
| entry BUY | `last_fractal` = BUY (fractal dưới), `close_cross_jaw` = BUY, AC `rising` = BUY, AO `signal` = BUY |
| exit BUY | AO `signal` = SELL, khi đang có BUY mở |

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

## EA Module

- [v] **Đã có strategy flags:** enabled / available / show_on_chart.
- [v] **Đã đổi tên judge dữ liệu:** `color` thành `rising`; màu chỉ là cách vẽ.
- [v] EA nạp `StrategyCollection` vào RAM một lần qua `CStrategyCollection`; bar mới tự judge trên `CStrategyBase`.
- [v] Bỏ Timeframe khỏi tab và form của strategy; source có combobox TF; cập nhật `CStrategySetting` và event TF.

## Library

- [v] **engine Strategy:** `UseCases\Strategies\StrategyEngine.mqh`
- [v] **Conditions:** `D:\MT5-Dev\Library\UseCases\Strategies\Conditions`
- [v] **Parity Profitunity:** `Test\Strategy Parity Engine.mq5` replay 1000 nến khớp 6/6 BTCUSD M1.
  - Compile 0/0 và chạy không lỗi.
- [v] **Đã chốt Profitunity:** fractal dùng shift 3.
  - Shift 2 của EA gốc làm fractal trống nên không vào lệnh.
- [v] **Đã có engine chung:** `CStrategyCollection::Calculate` dùng judge chung thay switch theo tên.
- [v] **Đã có strategy trên từng cặp:** `CStrategyCollection` và `CStrategyBase` cho mỗi cặp của `Setting_SymbolTF`.
- [] `SLOT_CHANGED` / `TF_CHANGED` đã biết nhưng chưa cho Python tính lại; xem mục Library\Python.
- [v] **Strategy Setting:** timeframe của strategy theo TF của chart.
  - `CStrategySetting::m_tf`, `Setting_Strategy.tf_enum` và `STRATEGY_MANAGER_EVENT_TF_CHANGED` không dùng cho timeframe của strategy.
  - `CStrategyPairSlots`, `CStrategyCollection` và `CBarMarkerCollection::StrategyTimeframe` theo TF của chart.
- Risk Setting, StrategyID và CTradeRisk: compile 0/0.
  - Chi tiết ghi trong header/comment của từng file.
  - Đã chạy trên terminal: `Setting_Risk` đọc đủ 35 row. Phần còn lại chưa test.
  - [v] **CRiskSetting:** [RiskSetting.mqh](../../Library/Entities/Settings/Risk/RiskSetting.mqh), `Setting_Risk` trên RAM, key theo tên input của Part 7.
    - Công tắc hiện có: `StopLossTemplates` / `TrailingTemplates` (tab Trading, section Stop Loss / Trailing), `EnablePortfolioRisk` (chưa có trên GUI).
    - [v] `EnableBasketRisk` cho `CBasketRisk::Manage`
  - [v] **RiskManagementDefines:** [RiskManagementDefines.mqh](../../Library/Entities/Defines/RiskManagementDefines.mqh), enum và tier của Part 7, `STradePlan`, `FloorToVolumeStep`.
  - [v] **EventDefines:** [EventDefines.mqh](../../Library/Entities/Defines/EventDefines.mqh), `ENUM_RISK_SETTING_EVENT`, `ENUM_RISK_EVENT` (`RISK_EVENT_ENTRY_BLOCKED`).
  - [v] **CTradeRisk:** [TradeRisk.mqh](../../Library/Trading/RiskManagement/TradeRisk.mqh), tầng trade của Part 7: lot, margin cap, `AllowHedging` theo MagicID + symbol.
    - SL lấy từ base (`CTradingControl::StopLossPrice`), TP theo [BaseIndicatorStrategy.md](BaseIndicatorStrategy.md#base-strategy).
    - `ValidatePlan`: `canOpenTrade` (`AllowHedging`, `CountPositions*`) bỏ qua khi StrategyID 0 (Manual); margin cap vẫn áp.
    - Entry mode/pending offset không port: Strategy quyết định `ENUM_ORDER_TYPE`.
  - [v] **CBasketRisk:** [BasketRisk.mqh](../../Library/Trading/RiskManagement/BasketRisk.mqh), basket = position của EA trên một symbol.
    - Chặn Entry khi đầy/vượt margin; `Manage` trên nến mới của TF chart: cắt lỗ, giữ quá N bar → `TRADE_SETUP_EVENT_CLOSE_ALL` (sparam = symbol).
  - [v] **CPortfolioRisk:** [PortfolioRisk.mqh](../../Library/Trading/RiskManagement/PortfolioRisk.mqh), chỉ chặn Entry như tác giả; snapshot theo `LogPortfolioSnapshot`.
  - [v] **CMarketCollection:** [MarketCollection.mqh](../../Library/Collections/MarketCollection.mqh), `HasPosition` / `PositionsCount` lọc thêm MagicID, StrategyID.
  - [v] **CTradingControl:** [TradingControl.mqh](../../Library/Trading/TradingControl.mqh), đọc/ghi `Setting_Risk`; `SendNewOrder` dùng magic của EA.
    - `OnStrategyEntry`: `STRATEGY_EVENT_ENTRY` của strategy bật trading → `CTradeRisk` → `CBasketRisk` → `CPortfolioRisk` → pending request (spread ≤ `MaxSpreadPips` × 10).
    - Manual: `TRADE_SETUP_EVENT_SEND` từ `CButton` → `TradeEntry` StrategyID 0 → mở ngay bằng `OpenPosition`, không qua ngưỡng spread.
    - `OnRiskNewBar`: `SERIES_EVENTS_NEW_BAR` của TF chart → `CBasketRisk::Manage`.
    - `TRADE_SETUP_EVENT_CLOSE_ALL`: lparam > 0 chỉ đóng position của strategy đó; sparam = symbol chỉ đóng position của EA trên symbol đó.
  - [v] **CBaseObjExt:** [BaseObjExt.mqh](../../Library/Entities/Bases/BaseObjExt.mqh), StrategyID trong magic.
    - Magic `ulong`: bit 0–15 MagicID (EA, `inpMagicNumber`), 32–63 StrategyID.
    - GroupID1/2 còn trống.
  - [v] **CTrading:** [Trading.mqh](../../Library/Trading/Trading.mqh), magic giữ đủ 64 bit khi ghép PendReqID.

## Library\Python

- [v] **Python engine:** `Strategy\engine.py` đọc `Setting_StrategyCondition` và RULES.
- [v] **Đã chuyển Profitunity sang engine chung:** kết quả khớp EA.
- [] `SLOT_CHANGED` / `TF_CHANGED` chưa tính lại.
  - Tạm thời để sau.
- [v] Engine tính theo TF của cặp; source/slot ở TF khác đọc nến đã đóng gần nhất.

## EA V5\Web

- [v] **Đã có engine/judge chung:** `src\strategies\conditions.ts` theo cùng rule với EA và Python.
- [] **Backtest strategy trên TradeCanvas:**
  - Tạm thời chưa test.

## Database

- [v] **tf_enum:** `tf_enum` gắn với source (`Setting_StrategyIndicator.tf_enum`), không gắn với strategy.
  - NULL = TF của chart.
  - Strategy ra quyết định theo chart hiện tại, source ở TF khác thì strategy ứng với TF đó.
- [v] **Đã lưu điểm quyết định Strategy:** Python ghi `StrategyCollection` trong file của account.
  - [v] Một row gồm `name`, `tf_enum`, `strategy_id`, `role`, `bar_time`, `signal_direction`; không phải lệnh thật.
- [v] Không thêm table riêng cho engine Strategy.
  - Kết quả và Setting theo nguyên tắc và phân công ghi trong [WorkingOnRamSaveToDB.md](WorkingOnRamSaveToDB.md).
- [v] **Risk Setting:** table `Setting_Risk` trong DB của account.
  - `CTradingControl` ghi default, giữ giá trị đã sửa.
  - Key/value (tier, name, value, comment); tier là trade / basket / portfolio.

## Việc chưa làm

- [] **Params của event Entry:** giá vào, SL, TP; vd Harmonic lấy từ pivot.
- [] **Quản lý lệnh:** trung bình giá, trailing, breakeven; vd Pin Bar Averaging.
- [] **Trailing:** chưa có code dời SL; `TrailingTemplates` mới lưu lựa chọn.
  - Concept và việc sửa role theo judge: [BaseIndicatorStrategy.md](BaseIndicatorStrategy.md#base-strategy).
- [] **Tham số riêng của strategy:** `Tolerance`, `PivotLeft`…, chỗ lưu trong Setting.
- [] **Sửa Setting_Risk:** chưa có nơi sửa (GUI của EA hoặc Web).
  - Nơi sửa gọi `CRiskSetting::SetValue` và ghi DB.
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
  - Entry đã code ngày 2026-11-16, chưa compile/test.
    - Library: `ConditionMACross.mqh` (`CConditionMACross`, `ma_cross`) và `Setting_MACrossover.mqh` (id 2, slot FastMA/SlowMA, Entry BUY/SELL) đã thêm vào catalog.
    - Library\Python: `Strategy\engine.py` có rule `_ma_cross`; rule nhận `buffers_of(slot)`; `ast.parse` đã pass.
    - EA V5\Web: chưa làm; `STANDARD` trong `src\indicators\index.ts` chưa có MA phù hợp và `conditions.ts` chỉ nhận buffer của một slot.
    - Test: compile, bật Strategy, so EA với `StrategyCollection` của Python và EA gốc Part 7 trong Strategy Tester; parity test hiện viết cứng 4 slot Profitunity.
- [] **Strategy có slot là indicator trên indicator:** ví dụ `MA 9,0,EMA,RSI(14,CLOSE)`.
  - Library: `CStrategyManager::Create_IndicatorTemplate`, `CIndicatorsCollection`, `RefreshAvailable`, `CStrategyPairSlots::Indicator`.
  - Library\Python: `Strategy\engine.py` qua `indicators.compute`.
  - EA Module: parity test cần thêm slot có nguồn thay vì giữ handle cứng cho slot Profitunity.
  - EA V5\Web: `STANDARD` trong `src\indicators\index.ts` chưa có MA đủ để backtest/vẽ slot có nguồn.
