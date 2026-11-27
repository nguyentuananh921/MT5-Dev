# Implementation RiskManagement Note

> [!NOTE] Draft — chưa ổn định, sẽ dần được move sang `Notes/` khi đã chốt, fix bug.

Vướng mắc còn treo khi implement Risk, xếp theo thành phần của [Working Area và Sync Everywhere](../AGENTS.md#working-area-và-sync-everywhere). Trạng thái đã làm ở [Concepts.md](../Notes/Concepts.md#mt5-library).

## Đi tắt

- Lẽ ra mỗi Automation phải backtest kiểm chứng rồi mới bật ([gate 0](../AGENTS.md#rules-gate-mục-tiêu-tối-thượng)).
  - Đi tắt vì backtest xong cũng chỉ đổi Strategy này sang Strategy khác, parameter này sang parameter khác; cơ chế Automation không đổi.
  - Mới có 2 strategy nên quá ít Position được mở tự động, Risk chưa có việc để làm.
- Vì thế tab Trading có các control Manual để mở Position cật lực ([EA Module](#ea-module)).
- [] **Chưa backtest** Risk (Strategy Tester, so với EA gốc Part 7).

 ### EA Module:

 - [] **Manual bỏ qua một phần Risk:** Manual Buy / Sell, Manual Order Type, Manual Close All ở tab Trading; lệnh Manual mang StrategyID 0 trong magic.
  + Manual không qua ngưỡng spread (`MaxSpreadPips`, ngưỡng của Entry tự động); Risk không tính được thì lấy lot đã chọn, không SL/TP.
  + [v] 2026-11-23: lot không tính được vẫn qua margin cap (`ValidatePlan`) → `CheckBasketRisk` → `CheckPortfolioRisk` rồi mới mở (trước đó mở thẳng `OpenPosition`, bỏ qua Basket / Portfolio). Compile 0/0, chưa test terminal.
 - [v] **Magic của lệnh Manual** (Anhnt 2026-11-24, để test Basket với lệnh không Magic): ô `Magic` dưới `Lot` ở mục Manual, danh sách do `CTradingControl::ManualMagics` đưa (0 = không magic như lệnh Terminal; MagicID của EA + StrategyID 0; + StrategyID của từng strategy trên RAM), không hardcode; nút Buy / Sell gửi `TRADE_SETUP_EVENT_SEND` với sparam `symbol;magic`. Compile 0/0, chưa test terminal.
 - [] **Chưa test trên terminal:** nút Close All của panel theo strategy / symbol (`TRADE_SETUP_EVENT_CLOSE_ALL`).

 ## EA Web

- [] **Sửa `Setting_Risk` trên Web:** GUI của EA đã sửa được   (`CRiskSetting::SetValue`), Web chưa có chỗ sửa.

 ### MT5 Library: 
  - [] **GUI chậm khi profit đổi (nhiều Position):** đo 2026-11-26, 11 Position: `ACCOUNT_EVENT_PROPERTY_CHANGED` → `m_GUIPannel` 25–43 ms một event (2–3 event/s, 0.6–1.4 s mỗi 10 s); 2–3 Position chỉ ~2 ms.
   + Chỗ gọi: `CGUIPannel::OnChartEvent` (`GUIPannel_Lifecycle.mqh`), mỗi `ACCOUNT_PROP_PROFIT`: `UpdateCaption_Position`, `SyncButtons_Action`; Trade Manage mở thì thêm `FillTable_TradeManagerPosition`, `FillTable_TradeManagerOpenPositionByBasket` (vẽ lại cả bảng).
   + (a) Giữ Event, View chỉ ghi ô đổi giá trị (Price, Profit), không vẽ lại cả bảng: cùng bài học [Avoid Bug](../rules/2.%20CodingRule.md#avoid-bug). Khuyến nghị.
   + (b) Ngoại lệ "giống Indicator" cho View: profit trên GUI cập nhật theo `OnTimer`, Trading / Risk vẫn nghe Event.
   + Đo từng hàm (`MY DEBUG CGUIPannel::OnChartEvent ACCOUNT_PROP_PROFIT`), Trade Manage đóng, 5–12 Position: `UpdateCaption_Position` 1–7 ms một event, `SyncButtons_Action` ~0.1 ms; cả `ACCOUNT_EVENT_PROPERTY_CHANGED` 40–150 ms mỗi 10 s (chấp nhận được). [] Chưa đo lúc Trade Manage mở (nghi 2 `FillTable_*` là phần 25–43 ms lần trước).
   + [v] Làm (a): `CGUIPannel::UpdateTable_TradeCells` (`GUIPannel_Window_TradeManager.mqh`): cùng các row đang hiện (position id / symbol + side) thì chỉ `SetValue` và `CTable::Update` (vẽ ô đổi), row đổi mới fill + `Rebuild` cả bảng. Đo 2026-11-26 (Trade Manage mở, 5–6 Position): 2 `FillTable_*` ~1–3 ms một event (trước 25–43 ms).
   + [] Phần còn lại của `m_GUIPannel` ở `ACCOUNT_EVENT_PROPERTY_CHANGED` (~10–15 ms một event, tới 12 event/s: 0.4–1.7 s mỗi 10 s) nằm ngoài nhánh `ACCOUNT_PROP_PROFIT`: nghi `UpdateStatusBar_Equity`, `UpdateStatusBar_MarginLevel`. Đo 2026-11-27: không phải (`EQUITY` ~1 ms, children 0.1–0.2 ms); gần như toàn bộ là `SyncButtons_Action` trong nhánh `ACCOUNT_PROP_PROFIT` (mục dưới).
   + [] Mở / đóng cửa sổ Trade Manage (`WINDOW_EVENT_OPEN_DIALOG_BOX` / `CLOSE_DIALOG_BOX`): `m_GUIPannel` 4.0–4.8 s mỗi lần. Nguyên nhân: `OnEvent_Window_AddIndicator` → `m_window_main.IsLocked` vẽ lại mọi control của cửa sổ chính, cả tab ẩn.
    * [v] Sửa: `CGElement::IsLocked` chỉ `Draw` control đang hiện, control ẩn vẽ khi `Show` (`DrawIfPending`; `CTabs::Show` gọi riêng). Đo 2026-11-26: `IsLocked(true)` 77 ms (trước 4.0–4.8 s).
   + [] Cùng code mà thời gian GUI mỗi event dao động mạnh giữa các lượt chạy: `SyncButtons_Action` 0.1 → ~50 ms, 2 `FillTable_*` 1–3 → ~50 ms, mọi `ACCOUNT_EVENT_PROPERTY_CHANGED` ~100 ms (7 Position): nghi chart / máy đang bận việc khác, chưa xác định.
    * Đo 2026-11-27 (18 Position, section Action mở, Trade Manage đóng): `SyncButtons_Action` 35–70 ms một event (0.2–0.7 s mỗi 10 s), `UpdateCaption_Position` 1–2 ms, `EQUITY` ~1 ms. Lúc Action đóng (02:48, 1 Position) chỉ 0.03 ms: phần nặng là `Draw` của 5 button Action (`FloatingProfit` chỉ 5 vòng trên RAM). Đo tách 2026-11-27 (16 Position): `FloatingProfit` x5 ~0.05 ms một lần gọi; `Draw` ~5 ms một button (x52 = 259 ms trong 10 s). Đang đo các bước của `CGElement::Draw` (`DrawFrame` / `DrawImage` / `DrawContent` / `m_canvas.Update`, `CGElement::s_debug_draw_us`).
   + [v] Account event ngoài Profit: `EQUITY` ~1.5 ms một event, children 0.1–0.2 ms: không cần sửa.
   + Tiêu chí chốt (Anhnt 2026-11-26): GUI phải cập nhật **realtime**; cập nhật theo Event hay refresh theo `OnTick` / `OnTimer` thì chọn theo số đo.
  - [] **Sang nến giật ~1.7 s:** một nến 14 event (`SERIES_EVENTS_SIGNAL` mỗi template, `SERIES_EVENTS_PATTERN`…), mỗi event một `CBarMarkerCollection::SyncMarkers(bar)` 110–520 ms.
   + [v] Sửa: `OnChartEvent` chỉ ghi lại nến cần vẽ (`AddPending`, `m_pending_all`), EA gọi `CBarMarkerCollection::SyncPending` một lần cuối mỗi lần drain (`DispatchBusEvents`). Đo 2026-11-26: sang nến `SERIES_EVENTS_SIGNAL` x12 77–242 ms (trước x7 1230 ms), drain dài nhất lúc sang nến 29–179 ms (trước 1.7 s).

 
  - [] **Chưa thấy Basket / Portfolio cắt lệnh thật:** lỗ chưa chạm ngưỡng lúc đo hiệu năng 2026-11-26 (Trading mở Position bình thường, RAM khớp terminal).

- [] **Event cho RiskManagement Strategy:** chốt dữ liệu/Event đầu vào, quyết định theo scope Trade, Basket, Portfolio và Event đầu ra cho Trading.
  - Hiện có đầu ra `RISK_EVENT_ENTRY_BLOCKED`; Basket đóng lệnh bằng gọi thẳng `ClosePositions`, chưa phải Event.
- [] **Ngưỡng spread theo symbol:** pending request của Entry tự động kích hoạt khi spread (point) ≤ `MaxSpreadPips` × 10 ([TradingControl.mqh](../../Library/Trading/TradingControl.mqh), `SetNewActivationProperties`).
  - × 10 chỉ đúng với forex 5/3 chữ số (1 pip = 10 point); `CSymbol` chưa có khái niệm pip.
  - XAUUSD / BTCUSD: spread tính theo point lớn hơn ngưỡng nên request treo mãi, basket bị coi là "full" sai.
  - Cần chốt: ngưỡng tính theo pip của từng symbol (data ở `CSymbol`), hay đổi `MaxSpreadPips` sang point / theo symbol trong Setting ([Database](#database)).
- [v] **Basket = symbol + `ORDER_TYPE_BUY` / `ORDER_TYPE_SELL`** ([Concepts.md](../Notes/Concepts.md#trading)); trước đây code giữ một basket mỗi symbol như tác giả Part 7 (trộn hai chiều, `SBasketState.netDirection` 1 / −1 / 0 định nghĩa lại chiều):
  - Bỏ `netDirection`; `SBasketState.type` là chiều của basket; `CMarketCollection::BasketState(symbol, type, …)` lọc theo chiều.
  - Mỗi symbol hai basket: `BasketManage` → `BasketManageSide` cho từng chiều, cắt chỉ đóng chiều đó (`ClosePositions(symbol, 0, type, …)`); excursion / mốc chờ cắt theo symbol + chiều (`BasketIndexOf(symbol, type)`).
  - `CheckBasketRisk` xét basket cùng chiều với lệnh; `AllowHedging` off = không mở chiều ngược khi basket chiều kia đang có position.
  - Chiều trong Risk / Trading là `ENUM_ORDER_TYPE` (bỏ `int direction` 1 / −1 của tác giả: `STradePlan`, `BuildPlan`, `TradeEntry`, `ManualPlan`, `StopLossPrice`, `ClosePositions`); `ENUM_SIGNAL_DIRECTION` của Event đổi sang `ORDER_TYPE_*` ở chỗ nhận Entry / Exit.
  - Compile 0/0, chưa test terminal.
- [v] **Basket xét theo tick, trên RAM, gồm cả lệnh không Magic** (không tính được SL / TP thì thôi, nhưng position phải vào Basket và lỗ quá % thì Close All):
  - Lỗi gốc: position trên RAM (`CMarketCollection`) chỉ dựng lại ở `OnTrade`, `Profit()` đứng yên giữa hai giao dịch; `BasketManage` chỉ chạy lúc sang nến và chỉ thấy lệnh có MagicID của EA (lệnh `Terminal` Magic 0 lọt ngoài).
  - Sửa: `CMarketCollection::RefreshMoney(symbol)` cập nhật profit / swap / giá hiện tại của position trên RAM; `TICK_EVENT_NEW` của symbol → `RefreshMoney` → `BasketManage(symbol, 0)` (magic 0 = mọi position của symbol); cắt thì `ClosePositions(..., every_magic)`; `CheckBasketRisk` của Entry cũng xét mọi position. Sau một lần cắt, chờ `RISK_CUT_WAIT_MS` cho `OnTrade` (không đóng hai lần).
  - Compile 0/0, chưa test terminal.
- [v] **Portfolio có Exit:** trước đây code chỉ chặn Entry như tác giả (`PortfolioCanOpenPosition`), trong khi bảng Quyết định × Phạm vi có ô Exit × Portfolio ([Concepts.md](../Notes/Concepts.md#quyết-định--phạm-vi)).
  - Sửa: `PortfolioManage` theo `TICK_EVENT_NEW` (sau `BasketManage`): lỗ floating của portfolio (`PortfolioScan`, theo `PortfolioScope`) chạm `MaxPortfolioLossPercent` của balance thì đóng mọi position của portfolio (source `Portfolio`), chờ `RISK_CUT_WAIT_MS`. Cùng ngưỡng với chặn Entry. Compile 0/0, chưa test terminal.
  - 2026-11-23 cháy tài khoản demo: 4 lệnh XAUUSD không Magic (0.60 Sell ×2, 1.10 Buy ×2, `TradingOrderDetail.source` = `Terminal`; journal không có dòng request của terminal này) lỗ ≈ −4,039 USD; 2 lệnh 1.10 bị broker `StopOut`. Basket chỉ quản lệnh của EA (MagicID) nên không thấy chúng (lỗ basket −64 trong khi Portfolio −1,281); Portfolio chỉ chặn Entry nên không cắt.
- [] **`canOpenTrade` không port:** System mỗi Entry là một Event nên không cần chặn OnTick mở lại; `AllowHedging` chuyển thành luật của Basket. Nhiều Strategy cùng Entry trên một nến vẫn mở chồng lệnh, giới hạn chỉ còn margin / loss của Basket (đã bỏ `MaxBasketPositions`).
- [] **Chưa test trên terminal:** Trailing (`TrailPositions`), Exit (`OnStrategyExit`), cắt basket (loss / hold bars).

## Python Library

- Chưa có phần Risk.

## Database

- [] **Key spread của `Setting_Risk`:** nếu đổi `MaxSpreadPips` ([Library](#library)) thì Sync Everywhere cả key trong DB (owner xoá row không còn trong `CRiskSetting`).
- [] **Thống kê basket chỉ trên RAM** như tác giả: restart EA là mất; chưa chốt có lưu DB không.

## Reference-only

- [] **Series 1** (`D:\MT5-Dev\Experts\Solomon Anietie Sunday\Risk Management`): đã implement Part 7, chưa test đủ (các mục `Chưa test` ở trên).
- [] **Series 2** (`D:\MT5-Dev\Experts\Niquel Mendoza\Risk Management`): chưa làm.
## Việc chưa làm

- [] **Trading nhận đủ dữ liệu từ Strategy:** chốt params SL/TP đi cùng `STRATEGY_EVENT_ENTRY`; chốt event riêng cho trailing mỗi bar (đề xuất `STRATEGY_EVENT_SL`) để Trading gọi `ModifyPosition`.
- [] **Event cho RiskManagement Strategy:** chuyển sang [RiskManagement.md](../Implementation/RiskManagement.md#vướng-mắc).
- [] **Automation × Event:** ghi rõ loại object nào nghe Event nào để làm việc của mình.
- [] **Params của event Entry:** giá vào, SL, TP; vd Harmonic lấy từ pivot.
- [] **Quản lý lệnh:** trung bình giá, breakeven; vd Pin Bar Averaging.
- [] **Role của base theo judge:** GUI và `StopLossPrice` đang viết cứng `IND_SAR` / `IND_ATR` ([IndicatorConcept.md](../Notes/IndicatorConcept.md#việc-chưa-làm)).
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
    - MT5 Library: `ConditionMACross.mqh` (`CConditionMACross`, `ma_cross`) và `Setting_MACrossover.mqh` (id 2, slot FastMA/SlowMA, Entry BUY/SELL) đã thêm vào catalog.
    - Python Library: `Strategy\engine.py` có rule `_ma_cross`; rule nhận `buffers_of(slot)`; `ast.parse` đã pass.
    - EA Web: chưa làm; `STANDARD` trong `src\indicators\index.ts` chưa có MA phù hợp và `conditions.ts` chỉ nhận buffer của một slot.
    - Test: compile, bật Strategy, so EA với `StrategyCollection` của Python và EA gốc Part 7 trong Strategy Tester; parity test hiện viết cứng 4 slot Profitunity.
- [] **Strategy có slot là indicator trên indicator:** ví dụ `MA 9,0,EMA,RSI(14,CLOSE)`.
  - MT5 Library: `CStrategyManager::Create_IndicatorTemplate`, `CIndicatorsCollection`, `RefreshAvailable`, `CStrategyPairSlots::Indicator`.
  - Python Library: `Strategy\engine.py` qua `indicators.compute`.
  - EA Module: parity test cần thêm slot có nguồn thay vì giữ handle cứng cho slot Profitunity.
  - EA Web: `STANDARD` trong `src\indicators\index.ts` chưa có MA đủ để backtest/vẽ slot có nguồn.
  Lỗi gốc mà Basket mắc phải:

- [] Lời/lỗ trên RAM đứng yên. Position trong CMarketCollection chỉ được dựng lại ở OnTrade, nên Profit() mà Basket đọc là lời/lỗ ở lần giao dịch gần nhất, không chạy theo giá. Đây là lý do log ghi basket chỉ lỗ −64 trong khi thực tế đã lỗ hơn −1,000.
-[] Chỉ kiểm lúc sang nến. Trong một phút M1, giá có thể chạy rất xa trước khi Basket kịp nhìn.
-[] Chỉ thấy lệnh của EA (lọc theo MagicID), nên các lệnh Terminal Magic 0 lọt ngoài.
= []Giới hạn còn lại: symbol nằm ngoài Setting_SymbolTF thì không có series, nên không có TICK_EVENT_NEW và Basket không kiểm theo tick được. XAUUSD và BTCUSD của cậu có trong đó nên không bị ảnh hưởng. Tớ đã ghi vào RiskManagement.md (mục [v]) và memory.
