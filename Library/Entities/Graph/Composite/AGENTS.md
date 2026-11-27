# Graph Composite
 Child của [skills\AGENTS.md](../../../../skills/AGENTS.md); luật chung ở [CodingRule Avoid Bug](../../../../skills/rules/2.%20CodingRule.md#avoid-bug).
 ## Avoid Bug
  - **Phần kéo được trên chart phải nằm trong chart:** giá ở xa (SL của basket) làm hộp Stop ra ngoài màn hình, không nắm được. Mẫu `CTradeSetupBox::Layout`: hộp giữ trong mép chart, vùng màu vẫn tới giá.
 ## Việc chưa làm
  - [] **MY DEBUG `CTradeSetupBox::OnChartEvent press`**: gỡ sau khi test kéo SL trên terminal ([TradeSetupBox.md](../../../../skills/Implementation/TradeSetupBox.md)).
