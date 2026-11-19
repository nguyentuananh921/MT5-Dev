# Problem Note
ProblemNote là History Update: tóm tắt vấn đề và các bước đã xử lý theo thành phần/phạm vi, theo thứ tự implementation.
- **Theo `ProblemNote routing` và `Sync Everywhere` trong AGENTS.md:** ghi vấn đề tại thành phần bị ảnh hưởng.
- **Theo implementation** (cuối file, `## <Tên> (ngày)`): ghi bước xử lý theo thứ tự; một implementation có thể ảnh hưởng nhiều thư mục. Mục Repo tương ứng trỏ về implementation, không chép lại chi tiết.

Không xoá lịch sử. Với việc mới, kết luận, căn cứ, trạng thái và việc còn mở ghi trong Imp tương ứng; ProblemNote chỉ giữ tóm tắt History Update và link. `[v]`: bước đã xử lý; `[]`: việc còn mở. Để fold được: `##` = Repo hoặc implementation, `###` = chủ đề, mỗi việc một dòng `- [ ]`, chi tiết là dòng con thụt 2 dấu cách. Các Q&A cũ được giữ như lịch sử, không dùng làm nguồn trạng thái hiện tại.

## Library
### Trading (rà soát hẹn từ nhánh CAccountsCollection, 2026-11-14)
- [v] `Trading.mqh:4243` gọi `m_account.RefreshAccount()` trước khi tính lot: hỏi lại terminal và fire event account lần nữa.
- [] Trading chỉ lấy entry của strategy đang bật trading (`CStrategySetting::EnabledTrading()`). Thiết kế đã rõ (Concept_Strategy.md: Trading nghe `STRATEGY_EVENT_ENTRY` / `_EXIT`, chỉ thực hiện khi `EnabledTrading()`). Chưa làm: mới có 1 strategy (Profitunity), bật lên cũng phải chờ rất lâu mới có entry để test.
- [v] `CSyncManager::m_rows[]` (`SyncManager.mqh:42`) là struct member, trái quy ước RAM trong [Imp_WorkingOnRamSaveToDB.md](../Implementaion/Imp_WorkingOnRamSaveToDB.md).
- [v] History/TradeEvents: table `Orders`, `TradeEvent` do EA ghi, trái luật "kết quả cần lưu: chỉ Python".
  - 2026-11-16 đổi: Position close thì Library save lifecycle và dữ liệu MT5 không giữ lại sau đó: xem `## RiskManagement implementation` / `### Đã bàn đã làm` (Track lifecycle của Position).
- [v] Listener của account phải dùng `ACCOUNT_EVENT_PROPERTY_CHANGED` + `EventUnpack`, không dùng `CHARTEVENT_CUSTOM+ACCOUNT_PROP_*`.
- [] RiskManagement (tầng Trade, Basket, Portfolio, `Setting_Risk`): xem [Imp_RiskManagement.md](../Implementaion/Imp_RiskManagement.md).

### Strategy
- [] Strategy (engine, judge, `StrategyCollection`, các việc còn mở): xem `## Strategy implementation`.

### Comment
- [v] Comment "(Event Rule)" trong code đổi thành "(Working with Event)" (Library, `PythonBridge.mqh`); note của Anhnt giữ nguyên.

## Library\Python
### Strategy
- [v] Python theo engine chung (`Strategy\engine.py`): xem `## Strategy implementation`.

### Server / Web tab
- [v] `web_seen.flag` nằm trong `Database\`: xoá DB thì mở thêm một tab web.
- [v] **Đóng tab Web rồi gắn lại EA trong 10 phút: Web không tự bật.** `web_seen.flag` chạm trong 600 s (`WEB_SEEN_SECONDS`) thì server coi tab còn mở, không phân biệt tab chạy nền (nối lại chậm) với tab đã đóng. Sửa 2026-11-16: tab ngắt khi server còn chạy = đã đóng → `forget_closed_web()` xoá flag (còn tab Web khác thì giữ); EA đóng thì server `os._exit`, flag còn → không mở tab thứ hai. Chưa chạy thật.
  - Library\Python: `server.py` (`web_socket` → `forget_closed_web`).
- [] **Vẫn mở hai tab Web: chưa sửa được, lặp lại lỗi cũ** (Anhnt thấy 2026-11-16 ~20:30, sau khi EA chạy lại 20:28; hai lần sửa trên chưa đủ). Chưa có dữ kiện: `server.py` không ghi log (worker `server` của `main.py` chạy `server.py` thẳng, không `start_log`: không có `Debug\Python_server.txt`), nên không biết lần nào mở tab và vì sao. `web_seen.flag` sửa lúc 20:29:01 (server mới thấy một tab đang nối).
  - Bước 1: `server.py` ghi log vào `Debug\Python_server.txt` (như các worker khác), rồi gắn lại EA để đo; có log mới sửa ([CodingRule.md](../rules/CodingRule.md) mục 8).

### Log
- [v] `Python_current.txt` 3,5 MB traceback cũ: xoá được.
- [v] Log `Debug\Python_*.txt` không bao giờ xoá, phình qua các lần chạy: `main.rotate_logs()` lúc process cha khởi động đổi chúng thành `Python_*.prev.txt` (giữ một lần chạy trước để đọc sau khi treo / crash); worker chạy lại giữa chừng vẫn nối vào file của lần này. Chưa chạy thật: EA khởi động Python lần tới sẽ thấy `.prev.txt`.

## EA V5
### Event / GUIPannel
- [v] **Caption (số position, profit) và Equity không cập nhật sau khi đóng lệnh.** Sửa 2026-11-16: các con gửi event qua bus của EA thay chart MT5.
  - Hiện tượng: 2026-11-16 07:18:52 đóng lệnh cuối (−56.61), caption vẫn "1" và "−56.61".
  - Đo lần 1 (09:51:54): RAM đúng sau `OnTrade` (0 position, profit 0.00, khớp terminal) nhưng `UpdateCaption_Position` không được gọi nữa (cả event `ACCOUNT_PROP_PROFIT` lẫn event trade).
  - Đo lần 2 (10:05:52): account có event (`12/0` balance tăng, `14/1` profit giảm) nhưng `sent false`: `EventChartCustom` thất bại (lúc có lệnh mọi tick đều `sent true`).
  - Đo lần 3 (10:18:19): `EventChartCustom` lỗi 4104 (`ERR_CHART_NO_EXPERT`), 9 lần trong ngày, luôn ở `OnTrade` đầu tiên sau khi mở / đóng lệnh; event trade (`TradeEvent*`) chưa lần nào tới panel.
  - Test (10:53:14): Close All 2 lệnh → event account `sent true`, panel nghe event account (191) và event trade (24, mỗi lệnh một), caption `0 buys, 0 sells, profit 0.00`; bar mới, marker vẫn chạy; không lỗi. MY DEBUG đã gỡ.
  - Library: `CBaseObj::EventSend` đẩy vào hàng đợi static, `CBaseObj::EventNext` lấy ra; `CTradeEvent` kế thừa `CBaseObj` (trước: `CObject`); `TradeEvent*.mqh` (6 file), `CTickSeriesCollection`, `CChartObj::SendEvent` gọi `this.EventSend`. Event của control GUI (`GElement`, `Mouse`, `TableView`, `BarMarker`, `TradeSetupBox`, `TradingLevelBubble`) vẫn qua chart.
  - EA V5: `OnChartEvent` tách thành `DispatchEvent` (chia cho các con) + `DispatchBusEvents` (rút bus) gọi cuối `OnInit`, `OnTick`, `OnTimer`, `OnTrade`, `OnChartEvent`.
  - skills: [Imp_Event.md](../Implementaion/Imp_Event.md): đã ghi lại cơ chế bus của EA thay "chart bus".
- [v] Chưa test trên terminal: caption profit, mũi tên equity, về flat sau khi đóng lệnh.

### Theo dõi
- [] Theo dõi MT5 treo (2026-11-15 ~14:10): vài `OnChartEvent` 2–5 s chưa rõ nguyên nhân; bị lại thì ghi giờ phút.

## EA V5\Web
### Input
- [v] **Danh sách symbol của Web.** Nút symbol hiện `DEFAULT_SYMBOLS` của TradeCanvas (BTCUSDT, ETHUSDT, SOLUSDT, BNBUSDT: demo Binance) vì `main.ts` không truyền `symbols`. Nay lấy các symbol của account trong table `symbols` (EA ghi: `CSymbolTFManager`; 2026-11-16: 10 symbol BTCUSD, ETHUSD, XAUUSD, XAGUSD, USOIL, UKOIL, USDJPY, USDVND, BTCUSDT, TETUSD); symbol đã nhớ không còn trong danh sách thì mở symbol đầu tiên. Build xong, chưa mở trên trình duyệt (server.py phải chạy lại).
  - Library\Python: `server.py` `GET /symbols` (`symbols()` → `LibDatabase.symbols`, có sẵn: Python dùng nó để chạy worker cho từng symbol).
  - EA V5\Web: `main.ts` gọi `/symbols`, truyền `symbols` cho `ChartWidget`.

### Backtest / Setting
- [v] Web: Input (Setting `/strategies`, nến `/bars`, `/socket`), Function (tính, vẽ, backtest strategy trên TradeCanvas), Output trên chart (indicator của slot, lệnh backtest, bảng các lần chạy), sửa params của slot để backtest lại (`plugin.ts`, `backtest\index.ts`).
- [] Web cập nhật lại Setting sau khi backtest đạt, rồi bật Trade (Python tính lại, EA đọc lại): chưa có route ghi (server.py chỉ GET), `plugin.ts` sửa params chỉ để backtest; event báo EA đọc lại Setting chưa thiết kế.
- [] Bàn: bước đưa strategy đã backtest đạt vào Library. Bản cũ: "EA (`UseCases\Strategies`) + Python (`Strategy\<Name>.py`), cùng kết quả với bản đã backtest trên TradeCanvas"; nay đã có engine chung (thêm data + judge / `RULES`).

## skills
### Cập nhật tài liệu đã làm (2026-11-16)
- [v] Event (2026-11-16): concept ở [Concept_Event.md](../concept/Concept_Event.md), cơ chế/hiện trạng ở [Imp_Event.md](../Implementaion/Imp_Event.md); Strategy là cha các slot và tự fire quyết định cho Trading. Rules gate 4 = Working with Event; trace listener ở [CodingRule.md](../rules/CodingRule.md).
- [v] Concept_Strategy.md: `### Hiện thực` chỉ trỏ ba bên (EA, Python, Web); "Chưa chốt (Strategy)" chuyển sang ProblemNote; luật "khớp EA gốc trước" vào phần Strategy.
- [v] WebModule.md: Input / Function / Output, file `src\`, TradeCanvas có gì thiếu gì, build; "Thử trên TradeCanvas" bỏ khỏi AGENTS.md (gate 0 trỏ backtest trên Web, gate 5 "TradeCanvas vẽ trước"); `npm run build` chuyển từ [CodingRule.md](../rules/CodingRule.md).
- [v] RAM/DB tách thành [Concept_WorkingOnRamSaveToDB.md](../concept/Concept_WorkingOnRamSaveToDB.md); implementation phân công ghi DB và làm việc trên RAM ở [Imp_WorkingOnRamSaveToDB.md](../Implementaion/Imp_WorkingOnRamSaveToDB.md).
- [v] AGENTS.md định tuyến Library và EA V5 sang mục ProblemNote tương ứng; thay đổi trong `skills\` ghi vào `## skills` theo Sync Everywhere.
- [v] Quyết định ghi `TradingOrderDetail`: `Library\Trading\` (`CTradingControl`) lưu lifecycle của Position (dữ liệu MT5 không giữ lại sau khi Position đóng; EA tự lưu, Python không đụng); xem [Imp_WorkingOnRamSaveToDB.md](../Implementaion/Imp_WorkingOnRamSaveToDB.md) và `## RiskManagement implementation`.
- [v] Concept_Strategy.md `## Strategy`: "mỗi strategy tự đủ" thành "Entry, và Exit, SL, TP nếu nó có"; SL, TP, Exit dùng lại được giữa các strategy; ba scope của RiskManagement (Trade, Basket, Account): xem `## RiskManagement implementation`.
- [v] Nguồn strategy (các EA trong `Allan Munene Mutiiria\Automating Trading Strategies\`): ghi ở Concept_Strategy.md rồi chuyển sang `## Strategy implementation` (là danh sách việc, không phải concept).
- [v] Concept_Strategy.md `## Strategy`: `tf_enum` gắn với source (NULL = chart), quyết định theo nến của TF chart (luật TF trước đây chỉ có trong memory): xem `## Strategy implementation`.
- [v] Concept_Strategy.md `## Strategy` viết lại (2026-11-16, bỏ các câu trùng): strategy = quyết định × phạm vi (Order / Basket / Portfolio) dựa trên event từ nhiều nguồn (Indicator, Indicator on Indicator, trạng thái Trading/account, Object, luật riêng); Basket vs Position group; lot là việc của Trading; mục `### Trading dùng strategy` (bật trading, phương án). Phân loại RiskManagement đã đổi từ nguồn Event sang một Strategy ngày 2026-11-18; xem concept hiện tại phía trên.
- [v] Concept_Strategy.md `## Strategy`: bảng thêm Trailing (tách khỏi SL); strategy cho ra một hoặc nhiều quyết định; bật trading thì Trading tự áp; một lệnh ghép từ nhiều strategy theo phương án; basket = `StrategyId()` của strategy Entry. Bỏ "mỗi strategy tự đủ / Trading không tự thêm".
- [v] [CodingRule.md](../rules/CodingRule.md) `## Cách làm một thay đổi` mục 0: bàn trước, làm một thể (đọc `### Đã bàn đã làm` trước khi đề xuất, chốt hết `### Việc chưa làm` rồi mới code; lúc bàn không code, không compile).
- [v] Tên method đọc / ghi DB (`ReadDataFromDB`, `UpdateDataToDB`, `Read_RAM`, `Update_<Table>_Setting`, `Create_<Thing>`) theo quy ước đang có trong code (`CAccountsCollection`, `CSymbolTFManager`, `CStrategyManager`, `CIndicatorTemplateManager`…); xem [Imp_WorkingOnRamSaveToDB.md](../Implementaion/Imp_WorkingOnRamSaveToDB.md).

### Cập nhật tài liệu (2026-11-18)
- [v] Tạo [Imp_Kronos.md](../Implementaion/Imp_Kronos.md) làm nguồn hiện trạng tích hợp Kronos theo Working scope; Python, RAM/DB và Event trỏ về đây.

## Strategy implementation
Chi tiết đã làm/chưa làm: [Imp_Strategy.md](../Implementaion/Imp_Strategy.md).

## Indicator on indicator (2026-11-15)
Chi tiết trạng thái và update theo từng repo: [Imp_indicatorOnIndicator.md](../Implementaion/Imp_indicatorOnIndicator.md).

## RiskManagement implementation (2026-11-16)
Concept: [Concept_RiskManagement.md](../concept/Concept_RiskManagement.md). Hiện trạng theo thành phần và việc còn làm: [Imp_RiskManagement.md](../Implementaion/Imp_RiskManagement.md). Phần dưới giữ lịch sử thảo luận và căn cứ, không thay thế concept/status hiện tại.
2026-11-18: RiskManagement được xác định là một Strategy, áp dụng cùng mô hình quyết định × phạm vi; không phải nguồn Event đứng ngoài để Strategy khác quyết định thay. Cập nhật hiện tại ở hai concept và implementation được liên kết phía trên.
Nguồn: `Experts\Solomon Anietie Sunday\Risk Management\7. 24477 Consolidating the Risk Framework` (`CTradeRisk` → `CBasketRisk` → `CPortfolioRisk`).

### Đã bàn đã làm
- [v] Có phải thêm strategy không, Part 7 còn dùng MA không?
  - Có: series dùng MA Crossover ở mọi part (`iMA` SMA fast / slow; Part 7: `FixedMACrossover_Part7.mq5:128`, `ReadSignal`); từ Part 5 thêm EA Mean Reversion (`iBands`) để chỉ cách tính lot theo target profit. V5 chưa có cả hai. Làm MA Crossover trước.
- [v] SL, TP, Trailing, Exit thuộc ai, tính trên lệnh hay portfolio, dùng lại được không?
  - Part 7: SL/TP từng lệnh (`TradeRisk.mqh:650`); Basket chỉ cắt lỗ cả nhóm (`CBasketRisk::Manage`, `CloseAll`); Portfolio không đóng lệnh, chỉ chặn lệnh mới (`PortfolioRisk.mqh:420`).
  - V5: SL/TP thuộc Strategy theo role/scope (RiskManagement cũng là một Strategy); Trading thực hiện. Có Strategy cung cấp thì dùng, không có thì thôi. Bản Lib V3 (Fixed / Indicator theo Setting của symbol) không port.
  - Dùng lại được (Concept_Strategy.md `## Strategy`). Judge direction (entry, exit) trả BUY / SELL; judge level (stoploss, takeprofit, trailing) trả giá. Tên role theo code (`StrategyConditionSetting.mqh:17`: `"entry", "exit", "stoploss", "takeprofit"`).
  - MA Crossover không cố định SL/TP như EA gốc: bản EA gốc là phương án A; cùng Entry, backtest các phương án exit khác (PSAR…), kết quả quyết (Rules gate 0). Các phương án ở `### Việc chưa làm`.
- [v] Ai đặt lệnh: TradeCanvas hay EA?
  - EA đặt lệnh và tính trên Live. Setting nằm trong DB nên Web đọc được để tính. Nơi kiểm chứng: theo Rules gate 0.
- [v] Setting_Risk có ghi lại khi account / symbol đổi không?
  - Không: Setting nạp một lần và live trên RAM theo [Concept_WorkingOnRamSaveToDB.md](../concept/Concept_WorkingOnRamSaveToDB.md).
- [v] Phía EA đã có gì?
  - Hầu hết; chỉ đối chiếu với Part 7 để không duplicate ([CodingRule.md](../rules/CodingRule.md) mục 7):
    - Lot: `CSymbol::NormalizedLot`, `LotsMin`, `LotsStep`.
    - Margin: `CTrading::CheckMoneyFree`, `CAccount::MarginForAction`, `MarginFree`, `MarginLevel`.
    - Stops / freeze level: `CheckStopLossByStopLevel`, `CorrectStopLoss`, `CorrectTakeProfit`…
    - TP ratio: `ENUM_RISK_REWARD_RATIO` + `RiskRewardRatioValue` (`RiskManagementDefines.mqh`, dời từ `TradingDefines.mqh`).
    - Lệnh: `OpenBuy` / `OpenSell`, `PlaceBuyStop` / `Limit`…, `ModifyPosition`, `ClosePosition`.
    - Đếm: `PositionsTotalAll` / `Long` / `Short`.
    - Basket: `CMarketCollection::SumFloatingProfit`, `SumVolume`, `CTradingControl::ClosePositions(symbol, dir)`.
- [v] MA Crossover có phải thêm cột vào `Setting_StrategyCondition` (slot thứ hai, `plan`, role `trailing`) không?
  - Không: MA Crossover là một strategy có 3 slot (SMA 10, SMA 20, ATR 14: `AddIndicator` × 3), cột giữ nguyên (role, side, slot, rule).
    - SMA 10 cắt SMA 20: judge nhận cả `CStrategySlots` (`StrategyEngine.mqh:93`), tự đọc slot kia theo tên, như `close_cross_jaw` của Profitunity. Không cần cột slot thứ hai.
    - Phương án exit (`plan`) và role `trailing`: làm phương án A trước (không có trailing); chốt khi phương án B–E cần.
  - Hệ số (ATR × 1.5, TP = SL × 2) là chỗ duy nhất chưa có nơi chứa (dòng `[]` "Tham số riêng của strategy" ở `## Strategy implementation`; `m_params` của slot là params của indicator, `StrategyIndicatorSetting.mqh:20`): chọn ở `### Việc chưa làm`.
- [v] Part 7 có làm việc với Event không?
  - Không: mỗi bar mới, `OnTick` tự gọi (poll) `risk.ManagePendingOrders()`, `basket.Manage()`; trước khi vào lệnh gọi lần lượt `BuildPlan` → `ValidatePlan` → `AcceptsNewTrade` → `CanOpenPosition` (`FixedMACrossover_Part7.mq5:315-370`). Lấy concept của tác giả (ba scope), không lấy cách chạy.
  - V5 (Concept_Strategy.md `## Strategy`, [Concept_Event.md](../concept/Concept_Event.md)): ba scope Trade / Basket / Account ↔ ba phạm vi Order / Basket / Portfolio. Cách mô tả RiskManagement là **nguồn event** và để một Strategy khác quyết định được cập nhật ngày 2026-11-18; xem concept hiện tại phía trên.
- [v] Tổ chức RiskManagement thế nào?
  - Theo ba scope của tác giả, chạy theo Event (dòng trên). Mỗi class một file trong `Trading\RiskManagement\` (không tạo thư mục gốc mới trong Library: RiskManagement là một phần của Trading).
  - Khác Part 7: enum của RiskManagement tập trung ở `Entities\Defines\RiskManagementDefines.mqh`; config tầng 1, 2 là object Setting đọc từ `Setting_Risk` (`Entities\Settings\Risk\`), không giữ struct làm member ([Imp_WorkingOnRamSaveToDB.md](../Implementaion/Imp_WorkingOnRamSaveToDB.md)); `CTradeRisk` không tự tính SL/TP, nhận khoảng SL từ strategy.
- [v] Basket của RiskManagement có phải `BasketInfo` của Grid EA (`Allan Munene Mutiiria\Automating Trading Strategies\11. 17350 Multi-Level_Grid_System_EA.mq5`) không?
  - Không, khác nhau; implementation cả hai, giữ hai tên (Concept_Strategy.md `## Strategy`):
    - Basket (RiskManagement, tầng 2): mọi lệnh của một strategy, magic = `StrategyId()`; chặn lệnh mới, cắt lỗ cả nhóm (`CBasketRisk`).
    - Position group (strategy): một lần vào theo signal = lệnh đầu + các lệnh thêm (grid, averaging), một hướng, đóng chung (hoà vốn có trọng số, TP chung); nhiều group cùng lúc trong một strategy (Grid EA: `BasketInfo`, magic riêng mỗi group dòng 174; Part 7: `MeanReversionSizing_Part7`). Phân biệt group bằng `GroupID2` (4 bit: tối đa 15 group cùng lúc mỗi strategy).
- [v] ATR × 1.5 là strategy hay "bộ exit"? Hệ số thuộc strategy MA Crossover không?
  - Là strategy (chỉ cho SL); hệ số không thuộc MA Crossover (Part 7: `stopATRMultiplier`, `tpRatio` nằm trong `SRiskConfig`, không trong `ReadSignal`). Strategy cho ra một hoặc nhiều quyết định, không cần đủ; bật trading thì Trading tự áp; một lệnh ghép Entry / SL / Trailing / TP / Exit từ nhiều strategy theo **phương án** (`GroupID1`): Concept_Strategy.md `## Strategy`.
- [v] Basket lọc theo gì, magic gắn thế nào?
  - Basket = magic = `StrategyId()` (Concept_Strategy.md `## Strategy`, bảng ba scope). Magic là số mình tự gắn vào lệnh (`CTrading::SetMagic`; EA V5 chưa gắn), theo DoEasy (`BaseObjExt.mqh:98`): `MagicID` (16 bit) = `StrategyId()`, `GroupID1` (4 bit) = phương án exit, `GroupID2` (4 bit) = Position group. Lệnh tay không thuộc basket nào.
- [v] Track lifecycle của Position (mở / sửa SL / sửa TP / đóng) ở đâu, save gì?
  - Object trên RAM đã có, không thêm: `CMarketCollection` (live, `COrderControl` giữ SL/TP trước / sau), `CTradeEvent*` (từng bước), `CHistoryCollection` (đã close). Trước đây chỉ trên RAM nên không biết Position đã thay đổi thế nào: thiếu việc save.
  - Position close thì Library save lifecycle và các giá trị MT5 không giữ lại sau khi Position/terminal đóng ([Concept_WorkingOnRamSaveToDB.md](../concept/Concept_WorkingOnRamSaveToDB.md)); dữ liệu còn đọc được hoặc suy ra được từ MT5 thì không lưu trùng.
  - Ai ghi: `CTradingControl`, không phải `CTrading` (EA giữ `m_TradingControl`; điểm vào request `SendNewOrder` / `ModifyPositions` / `ClosePositions` nên biết lý do; nghe event qua `OnChartEvent`: bước không qua nó (sửa tay, broker khớp SL / TP, SO) lấy lý do theo `DEAL_REASON`; save khi `TradeEventPositionClose`). Table `TradingOrderDetail` (↔ `m_table_order_detail`); EA tự làm tự save, Python không đụng: xem [Imp_WorkingOnRamSaveToDB.md](../Implementaion/Imp_WorkingOnRamSaveToDB.md). Đổi quyết định `[v]` "table `Orders` … trái luật" ở `## Library` / `### Trading`.
    - Save: các bước của lifecycle (mở, sửa SL / TP: time, giá trước / sau, đóng); Bid / Ask của mỗi deal (spread để tính phí; `COrder::BidAskFromTicks`: hiện chỉ gọi khi mở cửa sổ Order detail, `GUIPannel_Window_OrderDetail.mqh:69`, giữ trên RAM).
    - Không save: spread lúc gửi request.
  - Panel có hai table; DB chỉ một ([Concept_WorkingOnRamSaveToDB.md](../concept/Concept_WorkingOnRamSaveToDB.md): dữ liệu còn suy ra được từ MT5 thì không lưu trùng; dữ liệu tạm thời cần giữ thì persist):
    - `m_table_trade_history` (tab History, `GUIPannel_Window_TradeManagerTabHistory.mqh`): list Position đã close. Suy ra từ deal của MT5 như hiện nay, join `TradingOrderDetail` (Fee từ Bid / Ask). Không có table DB riêng.
    - `m_table_order_detail` (cửa sổ Order detail, `GUIPannel_Window_OrderDetail.mqh`, mở bằng nút Detail của một row): lifecycle của Position, một row mỗi bước. Order, deal: suy ra từ MT5; join `TradingOrderDetail` cho dữ liệu cần xem lại nhưng MT5 không giữ sau khi Position đóng: Bid / Ask của deal, các lần sửa SL / TP.
  - Table `TradingOrderDetail` (một row mỗi bước theo `position_id`): Bid / Ask của mỗi deal; mỗi lần sửa SL / TP (time, SL, TP), để xem lại sau khi MT5 không còn giữ các chi tiết này.
  - Position đã close trước khi có table: Bid / Ask tạm suy ra một lần (`BidAskFromTicks`) rồi save; terminal hết tick thì để trống; các lần sửa SL / TP đã mất.
  - Luồng (`CTradingControl`): theo [Concept_WorkingOnRamSaveToDB.md](../concept/Concept_WorkingOnRamSaveToDB.md) và [Imp_WorkingOnRamSaveToDB.md](../Implementaion/Imp_WorkingOnRamSaveToDB.md).
    - OnInit: chưa có table thì tạo; nạp lên RAM; deal trong history của terminal chưa có Bid / Ask trong table (lần đầu: tất cả; sau: Position đóng lúc EA tắt) thì suy ra, ghi.
    - Live: các bước của Position trên RAM; Position close thì chủ động ghi xuống DB.
- [v] Lifecycle của Position (2026-11-16, Anhnt compile, chạy trên terminal): `CTradingControl` save vào `TradingOrderDetail` khi Position close (xem Track lifecycle của Position ở trên).
  - Library `Trading\TradingControl.mqh`: `m_CDatabaseService`, `SetDatabaseService`, `OnInitEvent` (tạo table, Bid / Ask lên `COrder` của deal, thiếu thì lấy từ tick rồi ghi), `ReadDataFromDB` (các lần sửa SL / TP của Position, theo yêu cầu), `UpdateDataToDB`, `DealsBidAsk`, `OnChartEvent` nghe event trade của Position.
  - EA V5: `EA V5 SQLLite.mq5` (`SetDatabaseService`, `OnInitEvent`, `SetTradingControl`); `GUIPannel` (`m_TradingControl`, `FillTable_OrderDetail` thêm các lần sửa SL / TP, bỏ `BidAskFromTicks` trong View). Tab History không đổi: Fee có số vì Bid / Ask đã ở trên `COrder`.
  - Cột `TradingOrderDetail`: `position_id, time_msc, ticket, event, sl, tp, bid, ask` (deal: `ticket` + Bid / Ask; sửa SL / TP: `ticket` = 0 + SL / TP).
  - Đo OnInit: lần đầu `0 read, 3064 deals from the ticks written, 200563 ms` (3055 có Bid / Ask, 9 hết tick), chặn EA một lần; lần sau `3064 read, 0 written, 0 ms`.
  - Test live 18:32: Position 4157556536 SELL: DEAL IN (Bid / Ask), MODIFY SL 3874.000 (`ticket` 0, event 49), DEAL OUT (Bid / Ask); Order detail hiện dòng MODIFY SL. 5 Position mở / đóng trước đó: đủ Bid / Ask của deal IN và OUT.
- [v] Tạo thư mục, file rỗng và dời enum (2026-11-16, compile `EA V5 SQLLite.mq5` 0/0).
  - Library: `Trading\RiskManagement\` (`TradeRisk.mqh`, `BasketRisk.mqh`, `PortfolioRisk.mqh`), `Entities\Settings\Risk\RiskSetting.mqh`: file rỗng.
  - Library: `Entities\Defines\RiskManagementDefines.mqh` mới: `ENUM_RISK_REWARD_RATIO`, `RISK_REWARD_RATIOS_TOTAL`, `RiskRewardRatioValue` chép nguyên văn từ `TradingDefines.mqh` (bản cũ comment out); nơi dùng duy nhất `Entities\Graph\Composite\TradeSetupBox.mqh` include file mới thay `TradingDefines.mqh`.
- [v] Tab History (`GUIPannel_Window_TradeManagerTabHistory.mqh`) hiện gì?
  - Tạm thời chỉ cái suy ra từ deal của MT5 (`FillTable_TradeManagerTabHistory` gom deal theo Position, tính trung bình, Fee), vì chưa lưu dữ liệu tạm thời cần để tính lại Fee: cột Fee trống trừ khi Bid / Ask còn trên RAM (`BidAskFromTicks` chỉ gọi khi mở cửa sổ Order detail của Position đó); Reason chỉ là `DEAL_REASON` (EXPERT, SL…), không có strategy, phương án exit, các lần sửa SL / TP. Làm lại: đọc từ DB (mục Track lifecycle ở trên).

### Việc chưa làm (snapshot 2026-11-16; trạng thái hiện tại ở Imp_RiskManagement.md)
- [] **Strategy MA Crossover:** xem chi tiết và các phương án exit trong [Imp_Strategy.md](../Implementaion/Imp_Strategy.md).
  - Lịch sử: SMA 10 cắt SMA 20 trên nến vừa đóng, Entry = judge `ma_cross` đọc slot `FastMA`/`SlowMA`; các phương án exit được backtest trên cùng nến và bộ số, không lẫn với lifecycle của Position:
  - Phương án A (EA gốc Part 7, để so trước): SL = ATR × 1.5, TP = khoảng SL × 2.
  - Phương án B: SL = giá PSAR, TP = khoảng SL × 2.
  - Phương án C: SL = giá PSAR, Trailing theo PSAR, không TP.
  - Phương án D: như C, thêm Exit = PSAR lật phía.
  - Phương án E: SL = ATR × 1.5, Exit = MA cắt ngược, không TP.
  - 2026-11-16 Entry: code xong, chưa compile, chưa test.
    - Library: `UseCases\Strategies\Conditions\ConditionMACross.mqh` (`CConditionMACross`, rule `ma_cross`: `fast[1] > slow[1] && fast[2] <= slow[2]` = BUY, ngược lại = SELL, như `ReadSignal` của Part 7), đăng ký trong `CStrategyEngine`; `Entities\Settings\Strategy\Setting_MACrossover.mqh` (`CSetting_MACrossover`, id 2, slot `FastMA` `10,0,SMA,CLOSE`, `SlowMA` `20,0,SMA,CLOSE`, entry BUY / SELL), thêm vào `CStrategyManager::Catalog`.
    - Library\Python: `Strategy\engine.py` rule `_ma_cross`; mọi rule nhận thêm `buffers_of(slot)` (buffer của slot khác) (`ast.parse` ok).
    - [] EA V5\Web: chưa làm (`STANDARD` của `src\indicators\index.ts` chưa có MA; rule của `conditions.ts` chỉ nhận buffer của một slot).
    - [] Test: compile, bật strategy, so entry của EA với `StrategyCollection` của Python (`Test\Strategy Parity Engine.mq5` đang viết cứng 4 slot Profitunity) và với EA gốc Part 7 trên Strategy Tester.
- [] Thiết kế RiskManagement chạy theo Event cho ba scope: chốt event, class giữ data/fire và Strategy nghe theo từng tầng. Contract chung ở [Imp_Event.md](../Implementaion/Imp_Event.md).
- [] Tầng 1, Trade (`CTradeRisk`, Trading): lot theo risk (%, cash, fixed; `CorrectVolume` chỉ tính lot tối đa theo free margin), margin cap, drawdown scaling, entry mode pending (offset, expiry N bar).
- [] Tầng 2, Basket: nguồn event (basket loss %, basket margin %, max hold bars, MAE; lọc theo magic) + strategy ở phạm vi Basket (Exit cả basket, chặn Entry).
- [] Position group (khác Basket, xem `### Đã bàn đã làm`): lệnh đầu + lệnh thêm (grid, averaging), đóng chung; nguồn Grid EA 17350 và `MeanReversionSizing_Part7`. Cùng dòng `[]` "Quản lý lệnh (trung bình giá…)" ở `## Strategy implementation`.
- [] Tầng 3, Portfolio: nguồn event (max Position / mỗi symbol / số symbol, margin %, loss %, net lots theo currency, scope) + strategy ở phạm vi Portfolio (chặn Entry, Exit khi drawdown).
- [] Table `Setting_Risk`.
- [] Chỗ chứa hệ số của strategy SL (ATR × 1.5) và TP (× 2): cùng dòng `[]` "Tham số riêng của strategy" ở `## Strategy implementation`.
- [] Phương án (Entry / SL / Trailing / TP / Exit lấy từ strategy nào) lưu ở đâu, chọn thế nào khi live.
- [] Chốt event cho Trading: xem contract cần chốt trong [Imp_Event.md](../Implementaion/Imp_Event.md).
- [] Strategy không có SL mà Setting chọn lot theo % risk: chặn lệnh hay lùi về fixed lot.
- [] CTradingControl::SendNewOrder vẫn đang gửi magic = 20260910;
