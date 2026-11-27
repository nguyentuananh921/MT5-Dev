# Trading (Entities)
 Child của [skills\AGENTS.md](../../../skills/AGENTS.md); luật chung ở [CodingRule Avoid Bug](../../../skills/rules/2.%20CodingRule.md#avoid-bug).
 ## Avoid Bug
  - **`CAccount` (`ACCOUNT_EVENT_PROPERTY_CHANGED`) đổi liên tục nhưng không là ngoại lệ như Indicator** ([Ngoại lệ](../../../skills/Notes/Event.md#system-concept-working-on-event)): vẫn fire lên [Bus Channel](../../../skills/Notes/Event.md#system-concept-event-channel), không đổi sang đọc trong `OnTimer`. Đo 2026-11-26: listener lọc ID trước khi hỏi chart thì ~0.1 ms một event.
