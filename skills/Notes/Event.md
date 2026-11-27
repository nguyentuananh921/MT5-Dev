# Event Note
 ## Nguyên tắc chung
  - **Event** <a id="system-concept-event"></a> là thông báo về một thay đổi có ý nghĩa trong state của Object; loại Object khai báo theo [`ENUM_OBJECT_DE_TYPE`](../AGENTS.md#mt5-library-objects).
  - Mục đích của Event là **Automation** <a id="system-concept-automation"></a>: mỗi Object tự làm việc của mình khi nhận Event; không Object nào hỏi hộ hay làm hộ Object khác.
  - **Parent Child** <a id="system-concept-parentchild"></a>: quan hệ composition (Parent chứa Child), không phải kế thừa class; có ở mọi cấp:
   + **System:** [System](../AGENTS.md#system) là Parent của các [Working Area](../AGENTS.md#project-and-working-area); các Working Area là anh em, trao đổi trực tiếp qua [Communication Channel](#system-concept-communication-channel).
   + **Working Area:** vd [EA Module](../AGENTS.md#working-area-ea): EA là Parent của các Object (`m_GUIPannel`, `m_TradingControl`, Collection, Manager…), giữ vòng đời của chúng.
   + **Object:** Parent giữ Child làm member và quản lý vòng đời; member `int` / `string` là property, không phải Child.
  - **Channel** <a id="system-concept-channel"></a>: đường trao đổi; theo cấp của [Parent Child](#system-concept-parentchild):
   + **Communication Channel** <a id="system-concept-communication-channel"></a> (cấp System): giữa các Working Area anh em (Database, HTTP API, TCP, WebSocket, File); chi tiết ở [CommunicationNote.md](CommunicationNote.md#communication-channel).
   + **Event Channel** <a id="system-concept-event-channel"></a> (cấp Working Area EA): Event đi từ Object fire tới listener trong process EA; listener nhận ở cùng `OnChartEvent`, chi tiết ở [EA Module](../../Experts/Anhnt/Example%20EA/4.%20Combination%20EA%20V5/AGENTS.md#event):
    * **Chart Channel** <a id="system-concept-event-channel-chart"></a>: hàng đợi chart của terminal ([Avoid Bug](../rules/2.%20CodingRule.md#avoid-bug)).
    * **Bus Channel** <a id="system-concept-event-channel-bus"></a>: hàng đợi trong process EA, gửi bằng `CBaseObj::EventSend` ([Base Class](../AGENTS.md#mt5-library-base-objects)); EA drain cuối mỗi callback.
   + Object nhận tin từ Communication Channel tự fire Event lên Bus Channel: vd `CPythonBridge` (`PYTHON_BRIDGE_EVENT_SYMBOLTF_DONE`).
  - **Working on Event** <a id="system-concept-working-on-event"></a>: Object sở hữu data tự fire Event (ID và contract `lparam` / `dparam` / `sparam` khai ở [EventDefine](../AGENTS.md#mt5-library-eventDefine)) lên một [Event Channel](#system-concept-event-channel); Object nào có việc liên quan thì nghe ở `OnChartEvent`, lọc đúng ID rồi tự làm việc của mình. [Parent](#system-concept-parentchild) chỉ dispatch, không fire hộ; không ai poll.
  - **Ngoại lệ:** [Indicator](IndicatorConcept.md#indicator-defines) là Object không fire Event khi value thay đổi; Object nào cần value của Indicator để tính (vd parameter của `MqlTradeRequest`) thì tự Refresh rồi đọc khi Event của chính nó tới.
 ## Event Reference
  - **Event-Driven Design:** Event Swing, internal/external BOS và CHoCH lấy concept từ `D:\MT5-Dev\Experts\Stanley Kimathi Kibaara\Market Structure Framework` 

