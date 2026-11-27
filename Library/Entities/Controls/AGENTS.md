# Controls
 Child của [skills\AGENTS.md](../../../skills/AGENTS.md); luật chung ở [CodingRule Avoid Bug](../../../skills/rules/2.%20CodingRule.md#avoid-bug). Control theo [Easy and Fast GUI](../../../skills/Notes/Concepts.md#easy-and-fast-gui): code vendor, càng ít thêm càng tốt.
 ## Avoid Bug
  - **Phần hiển thị thêm cho một control là Child object (`AddChild`), không phải property** ([Parent Child](../../../skills/Notes/Event.md#system-concept-parentchild)): giá trị đổi liên tục chỉ vẽ lại Child nhỏ, không vẽ lại cả control.
   + Mẫu: lãi / lỗ của các button Action là `CLabel` child của button (`CGUIPannel::m_label_action_value`); `CButton::m_value_text` đã gỡ 2026-11-27 ([DRY_CButton.md](../../../skills/DRY/DRY_CButton.md)).
