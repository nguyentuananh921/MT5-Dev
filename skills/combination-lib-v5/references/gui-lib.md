# GUI Lib: các bẫy đã gặp

- **`element.Update(true)` khác `element.CanvasPointer().Update(true)`.** Chỉ `CElement::Update` gọi `Draw()`; `CanvasPointer().Update` chỉ đẩy lại bitmap cũ lên chart. Control nào sở hữu object con không đăng ký qua `CWndContainer::AddToElementsArray` thì tự gọi `child.Update(true)` sau khi tạo và sau mỗi lần reposition.
- **`CTable::RedrawCell` chỉ vẽ icon khi `ALIGN_LEFT`.** Với `ALIGN_RIGHT`, icon biến mất mà không báo lỗi.
- **Bảng live không nháy:** so từng ô với cache; ô nào đổi thì gọi `SetValue(col,row,value,digits,true)`; cuối vòng lặp gọi `Update(false)` khi có thay đổi và trả về cờ changed để caller quyết định `ChartRedraw()`.
- **`CWndEvents::Show(window)` gọi `Show()` trên mọi element đã đăng ký.** Popup có field ẩn/hiện theo mode phải áp lại visibility sau mỗi chỗ gọi Show (grep hết các chỗ). `CWindow::Hide()` không ẩn các con do EA đăng ký: phải lặp `ElementsTotal(w)`.
- **Resize control:** tìm `ChangeSize` hoặc `Change*Size` trong class trước khi tự vá từng property từ bên ngoài.
- **`m_table_indicator_SymbolTFValue` và `m_table_candle_information_atBar` gần như là một bảng:** sửa logic icon hoặc value ở bảng này thì sửa luôn bảng kia.
- **Bug nằm trong một Control:** dựng một test EA tối giản chỉ có Control đó, đừng debug qua cả GUIPannel.
- Màu mặc định lấy nguyên từ vendor (Kazharski, DoEasy, MVC), không tự chọn.
- Gọi đúng tên class: CWindow (form GUI), CChartObj/CChartWnd/CWndInd (chart, subwindow, indicator). Không viết "cửa sổ".
