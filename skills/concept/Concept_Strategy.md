# Concept Strategy

Strategy là một **quyết định trong trading**, áp dụng trên một **phạm vi** (Order, Basket hoặc Portfolio), dựa trên việc ghép các event từ các nguồn khác nhau và có thể xảy ra ở các nến khác nhau. Strategy chỉ quyết định; Trading thực hiện. Cơ chế phát, truyền và nhận event xem [Concept_Event.md](Concept_Event.md).

## Timeframe

- `tf_enum` gắn với source (`Setting_StrategyIndicator.tf_enum`), không gắn với strategy: NULL = TF của chart. Strategy ra quyết định theo nến của TF chart; source ở TF khác thì đọc nến đã đóng gần nhất của nó.

## Quyết định × Phạm vi
| Quyết định | Order (một lệnh) | Basket | Portfolio (account) |
|---|---|---|---|
| **Entry** (giá vào: market, hoặc lệnh chờ ở một mức) | Mở lệnh theo signal (Profitunity: 4 event cùng BUY trên nến) | Thêm leg: grid, averaging | Chặn Entry khi vượt giới hạn (Part 7 `CPortfolioRisk::CanOpenPosition`) |
| **SL** (mức dừng lỗ lúc vào lệnh) | ATR × 1.5; Harmonic: pivot X / fibo extension | | |
| **Trailing** (dời SL khi lệnh đang chạy: trailing, breakeven) | PSAR | | |
| **TP** (một hoặc nhiều mức) | Ratio × khoảng SL; Harmonic: TP1/TP2/TP3 theo các pivot | TP chung, hoà vốn có trọng số (Grid EA 17350) | |
| **Exit** | AO cắt 0 xuống đóng Buy (Profitunity); MA cắt ngược | Cắt lỗ cả basket, giữ quá N bar (Part 7 `CBasketRisk::Manage`) | Cắt khi drawdown account |

- Một strategy cho ra một hoặc nhiều ô trong bảng, không cần đủ (vd Profitunity: Entry, Exit; ATR × 1.5: chỉ SL; PSAR: SL, Trailing, Exit). Mức giá (SL, TP, giá vào) lấy từ params của event hoặc từ Setting.
- Basket có hai nghĩa, giữ hai tên: **Basket** = mọi lệnh của một strategy Entry (magic = `StrategyId()` của nó, Part 7); **Position group** = một lần vào theo signal (lệnh đầu + lệnh thêm: grid, averaging), một hướng, đóng chung (vd `BasketInfo` của Grid EA 17350; magic: `GroupID2`).
- Lot (theo % risk, cash, fixed; margin cap) không phải quyết định của strategy: là cách Trading thực hiện Entry (Part 7 `CTradeRisk`).

## Nguồn event
| Nguồn | Ví dụ |
|---|---|
| Indicator (signal cơ bản của một template: `CSignal`, luật `signal`) | AO cắt 0, RSI rời vùng quá mua |
| Indicator on Indicator | RSI cắt MA của nó ([Concept_IndicatorOnIndicator.md](Concept_IndicatorOnIndicator.md)) |
| Trạng thái Trading / account | P/L của Position hoặc Basket, margin level, equity / drawdown |
| Object (`BarTimeSeriesCollection`…) | Swing, BOS, Candle Pattern (Pin Bar…), Chart Pattern, Harmonic Pattern, Zone |
| Luật riêng (judge viết một lần, strategy nào cũng dùng lại) | `close_cross_jaw`, `rising` (vd AC tăng so với nến trước), `last_fractal`, `ma_cross` (MA của slot cắt MA của slot `SlowMA`: judge đọc được slot khác của strategy) |

`signal_direction` của một Object (vd bóng dài phía dưới của Pin Bar) là thuộc tính của event, không phải quyết định giao dịch: strategy gán ý nghĩa bằng cách ghép nó với bối cảnh.

RiskManagement cũng là một Strategy trong mô hình này; nó dùng dữ liệu/Event về trạng thái Trading và account để ra quyết định theo scope Trade, Basket hoặc Portfolio. Nó không phải nguồn Event để một Strategy khác quyết định thay; xem [Concept_RiskManagement.md](Concept_RiskManagement.md).

## Ghép event
- Strategy là data: `Setting_StrategyCondition` (role, side, slot, rule). Role là quyết định trong bảng; judge viết một lần, strategy nào cũng dùng lại.
- Cách ghép: cùng nến; trong N nến; theo thứ tự (vd Harmonic X → A → B → C → D).
- Một engine chung đánh giá phép ghép. Thêm strategy = thêm data, cộng judge mới nếu có điều kiện chưa có.
- Strategy lấy từ một EA gốc: khớp EA gốc trước; chỗ nào khác EA gốc (nến đang chạy, phạm vi account…) phải có backtest chứng minh, lý do ghi ngay tại condition trong `Setting_<Name>` (vd `last_fractal` của Profitunity).

## Ví dụ: Profitunity
| Role / side | Event cần có trên nến |
|---|---|
| entry BUY | `last_fractal` = BUY (fractal dưới), `close_cross_jaw` = BUY, AC `rising` = BUY, AO `signal` = BUY |
| exit BUY | AO `signal` = SELL, khi đang có BUY mở |

## Trading dùng strategy
- **Trading Setting** là cấu hình giao dịch lưu trong DB, gồm bật/tắt giao dịch cho từng Strategy (`EnabledTrading()`) và các cấu hình giao dịch khác. `Setting_Risk` chỉ là phần cấu hình risk theo scope, không phải toàn bộ Trading Setting.
- Strategy bật trading (`EnabledTrading()`) thì Trading tự áp những quyết định nó có.
- Một lệnh ghép từ nhiều strategy: Entry bằng strategy này, SL bằng strategy khác, Trailing bằng cái khác nữa, Exit bằng cái khác. **Phương án** chỉ định mỗi quyết định lấy từ strategy nào; lệnh mở theo phương án nào thì dùng đúng các strategy của phương án đó (magic: `GroupID1`). Backtest theo phương án, không theo từng strategy một mình.
- Nhiều strategy cùng lúc (hai strategy ngược nhau, cùng symbol…): Trading quyết, luật linh hoạt, nằm ở Trading.
- Quyết định đi tới Trading bằng event của strategy (`STRATEGY_EVENT_ENTRY` / `_EXIT`; [Concept_Event.md](Concept_Event.md)).

## Hiện thực
EA `UseCases\Strategies\StrategyEngine.mqh` (judge trong `Conditions\`), Python `Strategy\engine.py` ([Python.md](../references/Python.md)), Web `src\strategies\conditions.ts` ([WebModule.md](../references/WebModule.md)); ba bên phải ra cùng kết quả (Sync Everywhere). RiskManagement xem [Concept_RiskManagement.md](Concept_RiskManagement.md) và [Imp_RiskManagement.md](../Implementaion/Imp_RiskManagement.md).
