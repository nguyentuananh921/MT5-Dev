# Implemenation RiskManagement Note 

 Note lại một số vướng mắc trong quá trình implemenation RiskManagement để tránh lặp lại.


 [] Giá SL lúc vào lệnh: STRATEGY_EVENT_ENTRY chưa mang giá SL. Tớ đề xuất tạm dùng cách của tác giả, tức ATR × ATRMultiplier với ATR(14) lấy từ CIndicatorsCollection, cho tới khi có BaseATR. Lúc đó sẽ xử lý luôn mục "Hai nguồn SL/TP".
 - Cái giá SL lúc vào lênh có phải strategy nào cũng có đâu. 
Tức là Strategy có thì mới dùng. Đâu có nhất thiết đâu.
Ở phần sau tác giả quản lý theo Basket theo Porfilo cơ mà. Cậu nghía lại cái.
Chúng ta đang plan working on Event và Automation Trading mà
Sau này khi chúng ta bật các Strategy lên thì tất cả các Strategy đấy đều có Event của nó và nó sẽ tự động update những cái SL, TP 

 [] MaxSpreadPips: tác giả đặt input này trong group Trading Signal, nhưng thực chất nó là một cổng chặn vào lệnh. Tớ đề xuất thêm vào Setting_Risk ở tier trade, default 2.0.
 [] TradeSetupBox: LossPerLot và LotsToTrade đang tự tính lot theo % balance trong View, vừa trùng chức năng vừa trái MVC. Tớ đề xuất cho nó gọi CTradeRisk để lấy lot.
 - Chúng ta đang plan làm lại TradeSetupBox. Chúng ta sẽ implemenation cái TradeSetupBox đúng với Risk Management

 

