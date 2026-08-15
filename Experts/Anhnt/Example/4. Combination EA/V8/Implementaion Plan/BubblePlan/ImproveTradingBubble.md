# Improve Trading Bubble 

## Goal
- Khi Position có SL hoặc TP trên MT5 sẽ xuất hiện các đường kẻ ngang để có thể dịch chuyển được SL, TP.
Thay vì dịch chuyển cái đường đó chúng ta tạo ra CTradingLevelBubble với ý tưởng rằng, chỉ cần dịch chuyển cái CTradingLevelBubble đó thì tất cả các SL của tất cả các Position sẽ thay đổi theo.
- Trong CTradingLevelBubble::DrawBubble chúng ta có 
 + m_canvas.FillTriangle ->
 + m_canvas.FillRectangle ->Chính là cái đường ngang trên Chart
- Việc dịch chuyển TraddingBubble bằng cách Move Mouse tới đường ngang rồi dịch chuyển lên xuống y như với BUildin SL, TP

## Implementation
Trong GUIPannel.mqh đã có properties là m_trading_bubble

## Problem
- Hiện rất khó để di chuyển m_trading_bubble

---

## Bug Note & Analysis

### Structure Analysis

#### Bubble Types (4):
- BUBBLE_SL_BUY = 0
- BUBBLE_TP_BUY = 1
- BUBBLE_SL_SELL = 2
- BUBBLE_TP_SELL = 3

#### Bubble Geometry:
- BUBBLE_TIP_W = 18px (tam giác mũi tên)
- BUBBLE_BDY_W = 155px (chiều rộng hình chữ nhật)
- BUBBLE_BDY_H = 52px (chiều cao = 26px trên + 26px dưới)
- BUBBLE_XSZ = 18px (nút X để close)
- BUBBLE_RPAD = 52px (padding phải từ chart edge)
- BUBBLE_LOOKAHEAD = 30px (khoảng cách từ bar cuối)

#### Vùng tương tác:
- `m_dragbox[BUBBLE_TOTAL]` - thân bubble để kéo (kích thước hiện tại khá nhỏ)
- `m_hitbox[BUBBLE_TOTAL]` - nút X để close position

---

### Current Drag Mechanism

#### 1. Detect drag start (OnChartEvent MOUSE_MOVE):
- Phải phân biệt "genuine grab" vs "wandered in" (user pan chart qua bubble)
- Dùng `m_prev_left_btn`, `m_prev_over` để tracking state trước đó
- **Phức tạp và dễ sai**

#### 2. Capture anchor (khi bắt đầu drag):
- `m_drag_anchor_y` = pixel Y khi bắt
- `m_drag_price_anchor` = giá tương ứng 
- `m_price_per_pixel` = tỉ lệ giá/pixel (từ ChartXYToTimePrice)
- Có fallback dùng SYMBOL_TRADE_TICK_SIZE nếu ChartXYToTimePrice fail

#### 3. During drag:
- MOUSE_MOVE liên tục cập nhật `m_drag_y`
- Draw() tính `dy = m_drag_y - m_drag_anchor_y`
- Tính giá mới: `new_price = m_drag_price_anchor + dy * m_price_per_pixel`

#### 4. End drag:
- OnPoll() detect button released
- Gọi ModifyAll(m_drag_type, new_price)

---

### Issues Identified

#### Issue 1: Dragbox quá nhỏ
- Dragbox bị constrain bởi bubble body (155px)
- Nút X (18px) ở phía phải → dragbox còn ~137px
- Padding chỉ +8px → tổng ~153px
- **Khó bắt, dễ bỏ tay vô tình**

#### Issue 2: Drag detection logic phức tạp
- Phải detect "wandered in" để tránh hijack chart-pan gesture
- Code kiểm tra: `bool wandered_in = left_btn && m_prev_left_btn && !m_prev_over`
- Nếu logic sai → hoặc chart pan bị block, hoặc drag bị reject

#### Issue 3: Không có visual hints
- Cursor không đổi khi hover dragbox
- Dragbox không highlight/change color khi hover
- **User không biết bubble draggable**

#### Issue 4: Offset calculation không chính xác
- `m_drag_offset_y = my - anchor` để compensate mouse position
- Nhưng dragbox có padding → offset không perfectly align
- Có thể cảm giác "jump" khi bắt đầu drag

#### Issue 5: Price-to-pixel accuracy
- ChartXYToTimePrice() có thể fail (return false)
- Fallback dùng SYMBOL_TRADE_TICK_SIZE có thể không chính xác
- Giá có thể bị quantize không mịn

#### Issue 6: Scroll lock complexity
- Phải lock CHART_MOUSE_SCROLL + CHART_AUTOSCROLL khi drag
- Phải track `m_scroll_locked_by_me` để tránh conflict với CWindow
- Nếu logic sai → scroll bị "stuck off" hoặc "flap" liên tục

---

### Root Causes

1. **Dragbox design**: Quá nhỏ + nằm trên bubble body nhỏ
2. **Drag detection**: Quá phức tạp, dễ sai
3. **UX**: Không rõ ràng bubble draggable, cursor không thay đổi
4. **Precision**: Price mapping và offset logic có lỗi tinh tế

---

### Known Fixes (already applied)

- ✅ "Chạy ngang" (horizontal drift) → frozen m_drag_bx at drag-start
- ✅ "Mất khi đổi TF" (disappear on TF change) → m_need_redraw flag + CHART_CHANGE event
- ✅ "Scroll ảnh hưởng chart" (scroll flapping) → m_scroll_locked_by_me tracking

---

### Proposed Solutions (waiting for discussion) — SUPERSEDED, xem mục cuối

**A:** Fix dragbox nhỏ → làm lớn/dễ bắt hơn
**B:** Add visual hints → cursor change + highlight hover
**C:** Simplify drag detection → bỏ "wandered in" logic phức tạp
**D:** Fix price-to-pixel accuracy → cải thiện mapping
**E:** Khác?

---

## Đã thử A→D (2026-08-14, trước khi đổi hướng) — vẫn không dứt điểm

Áp lần lượt: dragbox phủ hết đường kẻ ngang (A), hint hover đổi màu (B), debounce release
time-based + `OnPoll()` re-lock scroll mỗi 16ms (không chỉ MOUSE_MOVE), pin `CHART_FIRST_VISIBLE_BAR`.

**Bằng chứng qua log thật (quyết định đổi hướng)**: trong ĐÚNG 1 lượt user giữ chuột kéo liên
tục, `ModifyAll()` bị gọi **3 lần** (SL đổi `4332.000→4328.864→4328.538→4329.620` trong ~3s) —
mỗi lần là 1 lượt kéo bị cắt ngắn rồi tự khởi động lại. **Root cause thật**: `CMouseCombine::OnEvent`
ghi đè `m_state_flags` từ `sparam` của MỖI `CHARTEVENT_MOUSE_MOVE` — khi kéo nhanh, MT5 thỉnh
thoảng gửi 1 event `sparam` báo "không giữ nút" dù tay vẫn giữ (quirc dồn event của MT5) →
`OnPoll()` (timer riêng 16ms) đọc trúng khoảnh khắc đó → tưởng đã thả tay → `ModifyAll()` thật +
kết thúc kéo → `MOUSE_MOVE` thật kế tiếp lại bắt đầu kéo mới. Dù đã thêm debounce time-based,
vẫn còn sót (anchor đôi khi vẫn reset giữa chừng cách nhau vài giây).

**Bước ngoặt**: user detach EA, thử kéo native SL/TP line có sẵn của MT5 → mượt mà tuyệt đối
(MT5 tự quản lý toàn bộ, không qua code EA). → Quyết định bỏ hẳn hướng "tự vẽ tự kéo".

---

## HƯỚNG CUỐI: Hybrid Native Line (2026-08-14) — ĐÃ TRIỂN KHAI

**Ý tưởng**: để MT5 lo phần kéo (đã mượt sẵn), EA chỉ lo phần native KHÔNG làm được — đồng bộ SL/TP
sang các position khác cùng chiều, cộng thêm hiển thị P&L đẹp qua bubble.

### Kiến trúc mới
- `CHART_SHOW_TRADE_LEVELS = true` (bật lại native line, không ẩn đi nữa).
- Bỏ sạch code tự kéo: `m_is_dragging`, debounce, `OnPoll`/`OnChartEvent(MOUSE_MOVE)` phần tính
  giá, `ModifyAll()` gọi tay khi thả chuột — tất cả xoá, không còn tồn tại trong code.
- `SyncFromModifiedPosition(ticket)`: nghe `TRADE_EVENT_MODIFY_POSITION_SL/TP/SL_TP` (event có
  sẵn từ `CTradeEventsCollection`, mang theo `lparam`=ticket + `dparam`=giá mới) → đọc SL/TP THẬT
  của position đó từ `m_market` (đã refresh trước khi event bắn) → áp lại cho các position còn
  lại cùng chiều (trừ chính ticket đó, tránh tự sửa lại chính mình).
- Nút X đóng hết vị trí: giữ nguyên 100%, không đụng gì (dùng `CHARTEVENT_CLICK` + `m_hitbox`,
  độc lập hoàn toàn với phần kéo).

### 2 phát hiện quan trọng khi làm hybrid (đáng nhớ nếu đụng lại sau này)

**1. Không có event nào đáng tin cậy để bắt "bắt đầu kéo native line".** Thử cả
`CHARTEVENT_MOUSE_MOVE` (giữ nút + gần đường) lẫn `CHARTEVENT_CLICK` (click 1 phát) — cả 2 đều
KHÔNG fire trong lúc đang kéo thật (MT5 giữ quyền chuột cho việc kéo native của chính nó, không
gửi tiếp cho EA). **Giải pháp cuối**: bỏ hẳn cách "bắt event", chuyển sang **polling trong
`OnPoll()`** (chạy timer 16ms, không phụ thuộc event) — đọc `m_mouse.IsLeftBtn()/X()/Y()` (giá trị
này tự nó cũng chỉ cập nhật qua `MOUSE_MOVE`, nhưng "đứng yên đúng" ở lần cập nhật thật cuối cùng
trước khi MT5 giữ quyền chuột, nên vẫn phản ánh đúng "đang giữ" suốt cả lúc kéo).

**2. Bug "nháy loạn xạ" (flicker) sau khi ẩn bubble lúc kéo**: `Draw()` reset toàn bộ `m_linezone[]`
(vùng OnPoll dùng để quyết định ẩn/hiện) về `active=false` mỗi lần vẽ, rồi chỉ set lại cho bubble
NÀO THỰC SỰ ĐƯỢC VẼ — bubble đang ẩn thì bị bỏ qua luôn, `m_linezone` của nó không bao giờ được
đăng ký lại → `OnPoll()` lần sau thấy "không có vùng nào" → tưởng chuột đã rời đi → tự hiện lại →
Draw() đăng ký lại linezone → OnPoll() lần sau lại thấy đang trong vùng + vẫn giữ chuột → ẩn lại
→ lặp vô hạn = nháy liên tục. **Fix**: tách `DrawBubble(type, by, visible)` — đăng ký `m_linezone`
LUÔN LUÔN (kể cả khi `visible=false`), chỉ bỏ qua phần vẽ pixel thật khi ẩn.

### Trạng thái (2026-08-14)
- ✅ Kéo mượt (native lo hết) - không còn "chạy lăng nhăng"/mid-drag ModifyAll nhiều lần.
- ✅ Đồng bộ nhiều position cùng chiều khi kéo 1 native line.
- ✅ Bubble ẩn lúc kéo, hiện lại đúng lúc thả tay (sau khi fix bug nháy loạn xạ) - user xác nhận
  "đỡ hơn nhiều rồi".
- ✅ Nút X đóng hết vẫn hoạt động bình thường (không đụng tới).
- File: `Graph/Trading/TradingLevelBubble.mqh` (Vendors/Anhnt/Library) - đã viết lại gần như
  toàn bộ, không còn dòng nào của cơ chế tự-kéo cũ.

