# EA Module
 Child của [skills\AGENTS.md](../../../../skills/AGENTS.md) ([working-area-ea](../../../../skills/AGENTS.md#working-area-ea)); luật chung ở [CodingRule Avoid Bug](../../../../skills/rules/2.%20CodingRule.md#avoid-bug). `README.md` ở đây do `scripts\gen-ai-docs.mjs` sinh: không ghi tay.
 ## Event
  - EA là [Parent](../../../../skills/Notes/Event.md#system-concept-parentchild) dispatch Event cho các Object: sau callback `OnInit`, `OnTick`, `OnTimer`, `OnTrade` hoặc `OnChartEvent`, EA drain [Bus Channel](../../../../skills/Notes/Event.md#system-concept-event-channel-bus) bằng `DispatchBusEvents` rồi `DispatchEvent` tới từng Object (`EA V5 SQLLite.mq5`).
  - **Terminal không có Event sẵn:** EA gọi Refresh trong callback, Object sở hữu data phát hiện thay đổi rồi tự fire.
   + Tick / bar: `CNewTickObj` (`TICK_EVENT_*`), `CBarSeriesDE` (`SERIES_EVENTS_NEW_BAR`).
   + Account: `CAccount`; Symbol: `CSymbol`; Market Watch: `CSymbolsCollection`.
 ## Avoid Bug
  - **Data chưa sẵn sàng:** `CPendingPairs` thử lại trong `OnTimer`.
  - **Strategy Tester không có `OnChartEvent`:** nhánh `MQL_TESTER` trong `OnTick`.
 ## Việc chưa làm
  - [] **MY DEBUG đo bus** (`DebugBusReport`, `DebugEventName`, `Breadcrumb` trong `EA V5 SQLLite.mq5`): chờ chốt gỡ.
