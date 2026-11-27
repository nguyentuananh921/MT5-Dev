# Implementation TradeSetupBox Note

> [!NOTE] Draft — đã code 2026-11-27, compile 0/0, **chưa test trên terminal**. Test xong sẽ chuyển concept sang [Concepts.md](../Notes/Concepts.md).

Mục tiêu: mỗi row của `m_table_open_position_by_basket` (tab By Basket của Trade Manage) có 2 nút **Manage** và **Close**. Manage hiện `CTradeSetupBox` để sửa SL / TP chung của basket.
Basket = symbol + side, mọi magic ([Concepts.md](../Notes/Concepts.md#quyết-định--phạm-vi), [RiskManagement.md](RiskManagement.md)).

## Đã chốt với Anhnt

- Manage = **sửa SL / TP của basket** (không phải thêm leg).
- Basket khác symbol chart: **đổi symbol chart** rồi mới hiện box.

## EA Module

- [v] **Bảng By Basket** ([GUIPannel_Window_TradeManagerOpenPositionByBasket.mqh](../../Experts/Anhnt/Example%20EA/4.%20Combination%20EA%20V5/GUIPannel/GUIPannel_Window_TradeManagerOpenPositionByBasket.mqh), `GUIPannel_Define.mqh`):
  - Thêm 2 cột cuối `COL_B_MANAGE` (icon `SETTING_PNG`), `COL_B_CLOSE` (icon `CLOSE_RED_PNG`), ô `CELL_BUTTON` sẵn có của `CTable` (click → `CLICK_EVENT_BUTTON`, row).
  - `FixedColumns(2,1)` → `(2,3)`: Profit, Manage, Close đứng yên bên phải. File layout cũ tự về thứ tự mặc định (`LoadLayout_Table`).
- [v] **Click** (`OnEvent_Window_TradeManage`): row → `m_shown_open_position_by_basket[row]` → symbol + side.
  - Close: `TRADE_SETUP_EVENT_CLOSE_BASKET` (lparam side, sparam symbol).
  - Manage cùng symbol chart: hiện box ngay.
  - Manage khác symbol: nhớ basket đang chờ, `Update_SymbolTF_Setting(symbol, Period(), SYMBOLTF_MANAGER_EVENT_SETTING_CHANGED)` (cùng đường combobox symbol). `REASON_CHARTCHANGE` giữ object, nên `CGUIPannel::OnInit` (nhánh `else`) thấy `::Symbol()` khớp thì hiện box.
- [v] **Box** `m_box_basket` (`CGUIPannel` sở hữu): tạo ẩn trong `CreateGUIPannel`, `AddChild` vào `m_GraphElementsCollection` (box cần mouse move ngoài cửa sổ; `CGUIPannel::OnChartEvent` lọc mất).
  - Hiện (`ShowBox_Basket`): `Setup(nến 20 bar trước, 30, giá đóng hiện tại, BasketStop)` (không lấy `oldestOpenTime`: basket mở lâu thì box nằm ngoài màn hình), `SetLots(totalVolume)` → P&L của cả basket tại SL / TP. Bắt đầu TP 1:1 (`SetLevels(1)`).
  - Entry = giá hiện tại (Bid Buy / Ask Sell), không phải giá vào bình quân: SL đã trail qua giá vào sẽ làm `Setup` hiểu nhầm side; từ giá hiện tại SL / TP luôn đúng phía broker đòi.

## MT5 Library

- [v] **`CTradeSetupBox::SetManage(true)`** ([TradeSetupBox.mqh](../../Library/Entities/Graph/Composite/TradeSetupBox.mqh)):
  - Khoá side (nút Buy/Sell chỉ là icon, không Flip); ẩn `RPT` và combo lot.
  - Nút Send thành "Modify" → `TRADE_SETUP_EVENT_MODIFY` (lparam side, dparam `Stop()`, sparam `symbol;target`, ghép vào biến trước theo [CodingRule](../rules/2.%20CodingRule.md#avoid-bug)).
  - Icon X chỉ ẩn box, không đóng lệnh.
  - TP = `Target()`, một mức chung cho basket ("TP chung" của Concepts.md).
- [v] **Kéo được cả SL và TP** (Anhnt 2026-11-27: box sinh ra để dịch SL / TP của basket; trước chỉ kéo được hộp Stop, TP theo ratio): `TSB_TARGET` = hộp Target; kéo thì TP tự do (`m_target_free`), dời Stop / cả box vẫn giữ TP; chọn lại ratio trong combo thì TP theo ratio. Chữ hộp Target hiện ratio thực.
- [v] **SL không kéo được trên terminal** (Anhnt 2026-11-27): debug `MY DEBUG CTradeSetupBox::OnChartEvent press` cho thấy hộp Stop ở y −156 … −4219 (SL basket xa giá, ngoài chart). Sửa: `Layout` giữ hộp Stop / Target trong mép chart, vùng màu vẫn tới giá. [] Chưa test lại; test xong gỡ debug.
- [v] Modify đã chạy trên terminal: `modify the basket BTCUSD SELL ... 28 of 28 positions`.
- [v] **Event** ([EventDefines.mqh](../../Library/Entities/Defines/EventDefines.mqh)): thêm `TRADE_SETUP_EVENT_MODIFY`, `TRADE_SETUP_EVENT_CLOSE_BASKET` sau `TRADE_SETUP_EVENT_LOT`, sửa `TRADE_SETUP_EVENTS_NEXT_CODE`.
- [v] **`CTradingControl`** ([TradingControl.mqh](../../Library/Trading/TradingControl.mqh)):
  - `CLOSE_BASKET` → `ClosePositions(symbol, 0, side, "Manual", every_magic=true)` (khác `TRADE_SETUP_EVENT_CLOSE` của Action: chỉ MagicID của EA).
  - `MODIFY` → `SelectPositions(symbol, 0, side, true, 0, tickets)` → `ModifyPosition(ticket, sl, tp)` từng ticket, Print số đã sửa.
  - Public `BasketStop(symbol, type)` (logic ở Controller, không ở `CGUIPannel`): SL gần giá nhất của basket (chạm trước); không có → `StopLossPrice` của base ON; vẫn không có → 1% giá.

## Test trên terminal

- [] Bảng By Basket hiện 2 nút Manage / Close mỗi row.
- [] Close: đóng mọi Position của basket (cả lệnh không Magic).
- [] Manage cùng symbol: box hiện, kéo Stop, chọn ratio, Modify → SL / TP của mọi Position đổi (journal + TradingOrderDetail.source = Manual).
- [] Manage khác symbol: chart đổi symbol rồi box hiện.

## Database, Python Library, EA Web

- Không đổi: event chỉ chạy runtime, không có Setting mới.

## Giới hạn

- Box không đi theo SL bị trailing sau lúc mở; bấm Manage lại để lấy mới.
- TP một mức chung cho basket, chưa partial close theo nhiều mức.
