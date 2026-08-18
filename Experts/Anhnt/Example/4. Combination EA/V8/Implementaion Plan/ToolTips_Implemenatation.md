# Tooltip cho Header của m_table_indicator_template

> Ghi lại 2026-08-17 (Claude). Mục tiêu: Hover vào Header của `m_table_indicator_template`
> (Settings tab → Indicator) hiện Tooltip giải thích cột đó check vào thì ảnh hưởng gì —
> hiện tại 5/7 cột chỉ có icon, không có chữ, dễ nhầm không biết check vào để làm gì.

## Bối cảnh kỹ thuật đã rà (từ hội thoại trước, không đoán lại)

- Cột hiện có (`CreateTableIndicator`, `GUIPannel_TabSettingIndicator*.mqh`):
  0=Indicator name, 1=Group, 2=Buy, 3=Sell, 4=Show on Chart, 5=Sound, 6=Message.
  Cột 2/3/4/5/6 chỉ có icon (`SetHeaderText(i, "")`), không có chữ.
- `CTable` (Kazharski Lib) vẽ Header là **1 vùng canvas gộp chung** (`m_headers`) — toạ độ biên
  từng cột (`m_columns[i].m_x/m_x2`) chỉ track nội bộ, KHÔNG có API public để hỏi "đang hover cột
  nào". Không có sẵn cơ chế per-column hit-test.
- GUIPannel tự biết mảng độ rộng cột (`widths[]`) lúc tạo bảng — đủ để tự tính biên X từng cột
  (cộng dồn `widths[]`) mà không cần Library expose gì thêm.
- Đã có tiền lệ style tương tự trong chính project: popup "Shift + hover candle info"
  (`GUIPannel_Lifecycle.mqh`) — tự hover-detect bằng `m_mouse.X()/Y()` + tính rect thủ công ở tầng
  `CGUIPannel::OnEvent()`.

## Đã chốt: dùng `CTooltip` (Library GUI Lib), không dùng native `OBJPROP_TOOLTIP`

Lý do: `CTooltip` đã được PROVEN hoạt động đúng trong tính năng Alt+hover Pattern-name
(`GUIPannel_CandleInfo.mqh::ShowPatternHoverLabel`, xong 2026-08-17) — đã giải quyết xong các vướng
mắc kỹ thuật:
- `CTooltip::ClearStrings()` (thêm vào `Tooltip.mqh`) — xoá nội dung cũ trước khi `AddString()` lại,
  đồng thời tự reset `m_alpha=0` để lần `ShowTooltip()` kế tiếp LUÔN vẽ lại (không bị guard
  `alpha>=255` chặn khi đổi nội dung liên tiếp).
- `CTooltip::Moving(const int x, const int y)` (thêm vào `Tooltip.mqh`) — định vị tuyệt đối theo
  toạ độ pixel bất kỳ, mirror `CWindow::Moving(x,y)`. Cần thiết vì `CElement::Moving(bool)` kế thừa
  mặc định KHÔNG dùng được cho vị trí di chuyển tự do (nó dùng `m_canvas.XGap()` bị đóng băng lúc
  `CreateCanvas()`, không bao giờ cập nhật lại).
- Đã KHÔNG dùng native `OBJPROP_TOOLTIP` vì đã thử fail trước đó cho case tương tự (hover-delay
  không đáng tin khi chuột di chuyển liên tục — xem comment cũ ở `ShowPatternHoverLabel`).

**Đã chốt (không còn là câu hỏi mở): phải tự tính `Moving(x,y)` theo cột, giống hệt Pattern-hover.**
`ElementPointer()` mặc định của `CTooltip` chỉ định vị "ngay dưới 1 Element cố định" — tức là dù
hover cột nào trong Header, tooltip cũng hiện y hệt 1 chỗ, KHÔNG di chuyển theo cột đang hover. Mà
mục tiêu ở đây là tooltip phải hiện ĐÚNG vị trí cột đang hover để user biết nó đang nói về cột nào —
nên bắt buộc phải tự tính X theo `widths[]` mỗi lần hover đổi cột, rồi `Moving(x,y)` như đã làm cho
Pattern-hover. Không cần thử nghiệm Cách A nữa.

## Nội dung Tooltip từng cột (lấy đúng nghĩa đã ghi trong comment code hiện có)

| Cột | Icon | Nội dung Tooltip đề xuất |
|---|---|---|
| 2 | Buy | "Hiện mũi tên Buy trên Chart khi Indicator này phát tín hiệu Buy" |
| 3 | Sell | "Hiện mũi tên Sell trên Chart khi Indicator này phát tín hiệu Sell" |
| 4 | Show on Chart | "Gắn/gỡ Indicator này trên Chart (live - không lưu JSON)" |
| 5 | Sound | "Phát âm thanh cảnh báo khi Indicator này đổi tín hiệu" |
| 6 | Message | "Hiện thông báo (Message/Alert) khi Indicator này đổi tín hiệu" |

(Cột 0/1 có chữ sẵn, chưa chắc cần Tooltip — Anhnt xác nhận thêm.)

## Việc cần làm — CHƯA code, đang lên plan

- [ ] Xác nhận nội dung Tooltip từng cột đúng ý Anhnt (bảng trên chỉ là đề xuất).
- [x] Cơ chế định vị: tự tính `Moving(x,y)` theo cột (đã chốt, xem lý do ở mục trên).

## Plan cụ thể (2026-08-17) — đã rà code hiện tại, chưa viết gì

### Việc đã xác nhận sẵn có / cần verify
- Cột thật hiện tại (`GUIPannel_TabSettingIndicatorTable.mqh:31`):
  `int widths[7] = {180, 70, 40, 40, 40, 40, 40};` — col0=Name(180), col1=Group(70),
  col2..6=Buy/Sell/Show/Sound/Message (40 mỗi cột) — hiện là **biến local**, chưa lưu thành member.
- Kiểm tra "tab Indicator có đang hiển thị hay không" → dùng thẳng
  `m_table_indicator_template.IsVisible()` (public, `CElementBase`) — ĐƠN GIẢN HƠN việc tự hỏi
  `m_tabs_main_setting_config` đang chọn tab nào: tab không active thì bảng tự `Hide()` sẵn (theo
  cơ chế `CTabs` của Library), chỉ cần check `IsVisible()` là đủ, không cần đụng gì thêm.

### 1. `GUIPannel.mqh` — thêm member
```cpp
CTooltip m_tooltip_indicator_header;      // Header hover tooltip cho m_table_indicator_template
int      m_indicator_table_col_widths[7]; // luu lai widths[] luc tao bang - tai dung de tinh bien cot luc hover
int      m_indicator_header_hovered_col;  // cot dang hien tooltip, -1 = khong cot nao (dirty-check, tranh ve lai moi frame)
```

### 2. `GUIPannel_TabSettingIndicatorTable.mqh` — lúc tạo bảng (chỗ có `int widths[7] = {...}`)
- Copy `widths[]` vào `m_indicator_table_col_widths[]` (`ArrayCopy` hoặc gán tay từng phần tử) —
  để hover-detect dùng lại đúng số đang thật sự áp dụng cho bảng, không hardcode 2 lần dễ lệch.
- Khởi tạo `m_tooltip_indicator_header`: `MainPointer(m_window_main)` + `ElementPointer(m_window_main)`
  (chỉ để thoả điều kiện `CreateTooltip()`, vị trí luôn override tay) + `XSize()/YSize()` (cỡ đủ cho
  2 dòng text, xem mục 4) + `CreateTooltip()` + `Show()` 1 lần — đúng pattern đã dùng cho
  `m_tooltip_candle_info` (`GUIPannel_CandleInfo.mqh::CreateWindowCandleInfo`).
- `m_indicator_header_hovered_col = -1;` (init).

### 3. Hàm mới — đặt cùng file với bảng (`GUIPannel_TabSettingIndicatorTable.mqh`)
```cpp
void CGUIPannel::CheckIndicatorHeaderTooltip(void)
 {
  if(!m_table_indicator_template.IsVisible()) { HideIndicatorHeaderTooltip(); return; }
  int hx = m_table_indicator_template.X(), hy = m_table_indicator_template.Y();
  int header_h = /* HeaderYSize da set luc CreateTable, 24 theo code hien tai */;
  if(m_mouse.Y() < hy || m_mouse.Y() >= hy + header_h ||
     m_mouse.X() < hx || m_mouse.X() >= hx + m_table_indicator_template.XSize())
   { HideIndicatorHeaderTooltip(); return; }
  // --- Tim cot: cong don m_indicator_table_col_widths[] cho toi khi vuot qua mouse.X()-hx
  int col = -1, acc = 0;
  for(int c = 0; c < 7; c++) { acc += m_indicator_table_col_widths[c]; if(m_mouse.X() - hx < acc) { col = c; break; } }
  if(col == m_indicator_header_hovered_col) return; // van cung cot - khoi ve lai (dirty-check)
  m_indicator_header_hovered_col = col;
  string line1 = "", line2 = "";
  switch(col) // col 0/1 (Name/Group) - Anhnt xac nhan co can tooltip khong, tam de trong = khong hien
   {
    case 2: line1 = "Buy";     line2 = "Hien mui ten Buy tren Chart"; break;
    case 3: line1 = "Sell";    line2 = "Hien mui ten Sell tren Chart"; break;
    case 4: line1 = "Show";    line2 = "Gan/go Indicator tren Chart (live)"; break;
    case 5: line1 = "Sound";   line2 = "Phat am thanh khi doi tin hieu"; break;
    case 6: line1 = "Message"; line2 = "Hien Message khi doi tin hieu"; break;
    default: HideIndicatorHeaderTooltip(); return;
   }
  int col_x = hx; for(int c = 0; c < col; c++) col_x += m_indicator_table_col_widths[c];
  m_tooltip_indicator_header.ClearStrings();
  m_tooltip_indicator_header.HeaderText(line1);
  m_tooltip_indicator_header.AddString(line2);
  m_tooltip_indicator_header.Moving(col_x, hy + header_h);   // ngay duoi Header, thang cot
  m_tooltip_indicator_header.ShowTooltip();
 }
void CGUIPannel::HideIndicatorHeaderTooltip(void)
 {
  if(m_indicator_header_hovered_col == -1) return;
  m_indicator_header_hovered_col = -1;
  m_tooltip_indicator_header.FadeOutTooltip();
 }
```
(Code trên là bản NHÁP minh hoạ luồng, không phải final — cần Anhnt duyệt lại tên/text tiếng Việt
có dấu hay không dấu, và `header_h` nên đọc từ đâu thay vì hardcode.)

### 4. Text tiếng Việt có dấu — cần kiểm tra encoding
`Tooltip.mqh` dùng `m_canvas.TextOut()` (Canvas vẽ chữ, không phải OBJ_LABEL native) — CẦN TEST xem
tiếng Việt có dấu (VD "Hiện mũi tên Buy...") có render đúng qua `CCanvas::TextOut` hay bị vỡ font/
encoding không, trước khi chốt nội dung tiếng Việt. Nếu vỡ thì phải viết tiếng Việt không dấu hoặc
tiếng Anh cho phần Tooltip này (khác với hội thoại - hội thoại luôn tiếng Việt, nhưng đây là text
hiển thị trong UI, không phải code comment/hội thoại).

### 5. Hook vào `OnEvent()` (`GUIPannel_Lifecycle.mqh`)
Thêm `CheckIndicatorHeaderTooltip();` vào nhánh `CHARTEVENT_MOUSE_MOVE` — không cần modifier phím gì
(khác Shift/Alt của 2 hover kia), nên đặt ở nhánh nào ORTHOGONAL với logic Shift/Alt hiện có, chạy
độc lập không phụ thuộc `m_keys.KeyShiftState()`/`KeyAltState()`.

### 6. Test checklist
- [ ] Hover từng cột 2→6, đúng tooltip từng cột, đúng vị trí (ngay dưới, thẳng cột).
- [ ] Rê chuột nhanh qua nhiều cột liên tiếp - không giật/không kẹt tooltip cũ (nhờ dirty-check `col`).
- [ ] Chuyển tab khác (rời Settings→Indicator) lúc đang hiện tooltip - tự ẩn, không treo lại.
- [ ] Không xung đột với candle-info popup (Shift+hover) / pattern-hover (Alt+hover) khi test đồng thời.
- [ ] Tiếng Việt có dấu render đúng qua Canvas (mục 4) - nếu vỡ, đổi sang không dấu/tiếng Anh.
