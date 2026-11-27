# GBases
 Child của [skills\AGENTS.md](../../../skills/AGENTS.md); luật chung ở [CodingRule Avoid Bug](../../../skills/rules/2.%20CodingRule.md#avoid-bug).
 ## Parent Child
  - `CGBaseObj` có thêm cây `AddChild` ([Parent Child](../../../skills/Notes/Event.md#system-concept-parentchild)): Child tạo sau `AddChild` lấy toạ độ tương đối với Parent, đi theo Parent khi `Move` / `Show` / `Hide`. Vd `CGUIPannel` `AddChild` các `CWindow`; `m_label_PositionBuy` là member của `CGUIPannel` nhưng `AddChild` vào caption bar.
 ## Avoid Bug
  - **Control đang ẩn không vẽ, vẽ khi hiện:** mẫu `CGElement::IsLocked` → `DrawIfPending` (comment tại `CGElement::IsLocked`).
  - **Một lượt hỏi symbol / TF của chart một lần rồi truyền xuống;** `Create` của object native không đọc lại property vừa tạo: mẫu `CGStdBaseObj::CreateObject` (header class `CGStdBaseObj`).
 ## Việc chưa làm
  - [] **`CGElement::SendEvent` dùng `::EventChartCustom`** dù đã kế thừa `CBaseObj::EventSend` ([Event Channel](../../../skills/Notes/Event.md#system-concept-event-channel)): chờ chốt GUI ở Chart Channel hay chuyển Bus Channel.
  - [] **MY DEBUG `CGElement::s_debug_draw_us`** (đo các bước của `Draw`, 2026-11-27): gỡ sau khi sửa [DRY_CButton.md](../../../skills/DRY/DRY_CButton.md).
