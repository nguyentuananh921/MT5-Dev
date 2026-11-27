# Bases
 Child của [skills\AGENTS.md](../../../skills/AGENTS.md); luật chung ở [CodingRule Avoid Bug](../../../skills/rules/2.%20CodingRule.md#avoid-bug). `CBaseObj` là gốc của mọi Object: type (`ENUM_OBJECT_DE_TYPE`), [Bus Channel](../../../skills/Notes/Event.md#system-concept-event-channel-bus) (`EventSend` / `EventNext`), đóng gói params (`EventPack` / `EventUnpack`): chi tiết trong code `BaseObj.mqh`.
 ## Việc chưa làm
  - [] **Sender chưa xử lý `EventSend` trả `false`** (fire xong phải biết đã vào queue, [Working on Event](../../../skills/Notes/Event.md#system-concept-working-on-event)): hầu hết Sender (vd `CStrategyBase::StoreRow`) bỏ qua kết quả, chỉ `CBaseObjExt::CheckEvents` có kiểm tra.
