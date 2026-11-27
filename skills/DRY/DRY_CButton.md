# DRY CButton

> [!NOTE] Đã sửa code 2026-11-27, compile 0/0, chưa đo lại trên terminal.

 ## Vấn đề
  - `CButton` (V5, chưa commit) thêm `m_value_text`, `m_value_color`, `ValueText()` để vẽ một giá trị ở mép phải ([Button.mqh](../../Library/Entities/Controls/Button.mqh)); `DrawContent` vẽ thêm, `TextMaxWidth` trừ chỗ cho nó.
  - Chỉ 5 button Action dùng (`CGUIPannel::SyncButtons_Action`, [GUIPannel_TabTrading.mqh](../../Experts/Anhnt/Example%20EA/4.%20Combination%20EA%20V5/GUIPannel/GUIPannel_TabTrading.mqh)): "Buy" + lãi/lỗ của nhóm.

 ## Vì sao lặp
  - `CButton : CLabel : CGElement : CGBaseObj`: đã có `AddChild` ([Parent Child](../Notes/ParentChild.md)), `CLabel` đã vẽ text / màu / căn phải. Giá trị là một `CLabel` child, không cần property mới trong `CButton`.
  - Tiền lệ đúng trong panel: `m_status_value[i]`, `m_status_equity_icon` là `CLabel` child của item status bar (`GUIPannel_Window_Main.mqh`).
  - `CLabel` `IsAvailable(false)` thì `CGElement` bỏ qua mouse ([GElement.mqh](../../Library/Entities/GBases/GElement.mqh), `OnChartEvent`): bấm vùng số vẫn là bấm button.

 ## Hệ quả hiệu năng
  - Profit đổi mỗi tick → `Draw` cả button: Erase + viền, blend icon từng pixel (`DrawImage`), text, value, `Update` cả canvas: ~5 ms một button (đo 2026-11-27, [RiskManagement.md](../Implementation/RiskManagement.md), mục GUI chậm).
  - Value là child `CLabel`: chỉ vẽ label nhỏ đổi số, button giữ nguyên ([Avoid Bug](../rules/2.%20CodingRule.md#avoid-bug): View chỉ làm phần thay đổi).

 ## Đề xuất
  - [v] Gỡ `m_value_text`, `m_value_color`, `ValueText()` và phần tương ứng trong `DrawContent` / `TextMaxWidth` (`git checkout` về bản commit): `CButton` về như gốc Kazharski; bỏ `M_BUTTON_VALUE_GAP` (GUIDefines).
  - [v] `CGUIPannel`: `CLabel m_label_action_value[5]`, child của từng button Action (nửa phải, `LabelRightGap(M_TRADE_ACTION_VALUE_GAP)`, `IsAvailable(false)`), `ActionButton(i)`.
  - [v] `SyncButtons_Action`: chỉ `SetText` + màu + `Draw` label đang hiện có số đổi (`m_action_value_drawn`); text và màu nhóm của button set một lần lúc tạo.
  - Đặt label ở `CGUIPannel` (mẫu status bar), không làm member của `CButton`: Controls là code vendor, chỉ Action cần. Nhiều nơi cần "button kèm giá trị" mới đưa vào Library.
  - [] Sau khi sửa: đo lại `SyncButtons_Action`, gỡ debug `CGElement::s_debug_draw_us` và `MY DEBUG CGUIPannel::SyncButtons_Action`.
