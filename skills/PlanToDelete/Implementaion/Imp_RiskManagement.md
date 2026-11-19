# Imp_RiskManagement

Concept: [Concept_RiskManagement.md](../concept/Concept_RiskManagement.md).

Nguồn tham khảo: `Experts\Solomon Anietie Sunday\Risk Management\7. 24477 Consolidating the Risk Framework` (`CTradeRisk` → `CBasketRisk` → `CPortfolioRisk`). RiskManagement áp dụng cùng mô hình Strategy và Event của V5, không port cách poll của EA gốc.

## Library

- [v] **Đã có nhiều API có thể dùng thay vì duplicate:** lệnh (`OpenBuy`, `OpenSell`, `PlaceBuyStop` / `Limit`, `ModifyPosition`, `ClosePosition`), kiểm tra margin/stops, chuẩn hóa lot và đếm Position; xem lịch sử trong [ProblemNote.md](../references/ProblemNote.md).
- [v] **Đã tạo vị trí cho RiskManagement:** `Trading\RiskManagement\` gồm `TradeRisk.mqh`, `BasketRisk.mqh`, `PortfolioRisk.mqh`; hiện là file rỗng.
- [v] **Đã tạo chỗ cho Setting:** `Entities\Settings\Risk\RiskSetting.mqh`; hiện là file rỗng.
- [v] **Đã chuyển enum risk-reward:** `Entities\Defines\RiskManagementDefines.mqh` chứa `ENUM_RISK_REWARD_RATIO`, `RISK_REWARD_RATIOS_TOTAL`, `RiskRewardRatioValue`; `TradeSetupBox` dùng file mới.
- [v] **Đã xác định class tầng Trade không tự tính SL/TP:** nhận mức từ Strategy; lot và việc thực thi lệnh thuộc Trading.
- [v] Các API hiện có gồm `CSymbol::NormalizedLot` / `LotsMin` / `LotsStep`, kiểm tra margin và stop, `CAccount` margin properties, `CMarketCollection::SumFloatingProfit` / `SumVolume`, `CTradingControl::ClosePositions`.
- [] `CTradingControl::SendNewOrder` còn gán magic cố định `20260910`; chưa gắn `StrategyId()` / Basket và các ID theo thiết kế.
- [] Chưa có implementation logic cho `CTradeRisk`, `CBasketRisk`, `CPortfolioRisk`.

## Database

- [] Chưa có table `Setting_Risk` để lưu phần cấu hình RiskManagement theo scope trong Trading Setting.
- [v] Lifecycle lưu trong `TradingOrderDetail` là việc của Trading/persistence, không phải RiskManagement; xem [Imp_WorkingOnRamSaveToDB.md](Imp_WorkingOnRamSaveToDB.md).

## Việc chưa làm

- [] **Thiết kế Event-driven cho ba scope:** chốt dữ liệu/Event đầu vào, quyết định và Event đầu ra của RiskManagement Strategy cho từng scope; theo [Imp_Event.md](Imp_Event.md).
- [] **Trade:** lot theo risk (% / cash / fixed), margin cap, drawdown scaling, pending entry (offset, expiry N bar); xử lý trường hợp chọn lot theo % risk nhưng Strategy không có SL.
- [] **Basket:** dữ liệu/Event cho basket loss %, margin %, max hold bars, MAE; lọc Basket theo `StrategyId()`; RiskManagement Strategy quyết định chặn Entry hoặc Exit toàn Basket.
- [] **Portfolio:** dữ liệu/Event cho giới hạn Position, symbol, margin/loss %, net lots theo currency và scope; RiskManagement Strategy quyết định chặn Entry hoặc Exit do drawdown.
- [] Chốt Setting cho từng scope và cách nạp/cập nhật `Setting_Risk`.
- [] RiskManagement dùng magic `StrategyId()` để lọc Basket; phân biệt `GroupID1` (phương án exit) và `GroupID2` (Position group) theo [Concept_Strategy.md](../concept/Concept_Strategy.md).
