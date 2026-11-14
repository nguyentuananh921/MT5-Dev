# Coding Rule
## Coding Rule

1. **Mỗi class một file**, có include guard. Chỉ getter/setter tách rõ Declaration và Implementation chỉ viết inline khi method ngắn gọn. Module: `<Class>_Define.mqh`, `<Class>.mqh`, `<Class>_Lifecycle.mqh`, `<Class>_Window_<Name>.mqh`.
2. **Comment của agent: tiếng Anh, tối đa một dòng**, chỉ cho điều không hiển nhiên. Không viết banner kể chuyện, không gắn tag tên/ngày. Header của method theo khung `//+---+`. Python: docstring một dòng.
3. **Note của Anhnt trong code (header file, dòng `// Update in V4…`) agent chỉ đọc**, không sửa, không xoá, không đề xuất xoá. `[]` là việc chưa xong, `[v]` là đã xong: đưa `[]` vào danh sách rà soát. Giữ nguyên tên member và màu mặc định của vendor; chỉ đổi tên khi nó che mất member của base class.
4. **Debug print:** `::Print("MY DEBUG CClass::Method: …")`. Dòng log nói rõ đơn vị và ngữ cảnh ("1311 rows on 709 of the 1000 bars"). Ghi file chỉ vào `MQL5\Files\<program>\` qua `GetFolderName()`.
5. **Dùng enum, không dùng số trần.** Ưu tiên enum của MT5. Enum dùng chung đặt trong `CommonDefines.mqh`, enum riêng đặt trong class. Mỗi `case` của `switch` có thân riêng, không fallthrough.
6. **Kiểm tra cái kế thừa trước.** CBaseObj đã có `m_available`, `m_first_start`, `m_object_type`, `GetFolderName()` và các method `Event*` (xem ParentChild.md). Không override `CBaseObjExt::Refresh`; đặt tên `RefreshX` (RefreshSeries, RefreshAccount…).
7. **Sửa method cũ, đừng thêm method song song.** Grep class đó (và CMarketCollection, `CommonDELib.mqh` với các hàm `XxxDescription`, `CommonDefines.mqh`) tìm method hoặc enum sẵn có trước khi viết; control GUI thì tìm `ChangeSize`. Số liệu theo symbol lấy từ CSymbol (`Spread()`, `TradeStopLevel()`, `Point()`, `Digits()`), không tự tính. Member, tham số hay enum mới: báo và chờ đồng ý trước.
8. **"Không ai gọi" chưa chắc là dead code.** Tra lineage Library `2. DoEasy. Service functions Lib` → `4. Combination Lib` (V1) → V2 → V3 → V4; EA `4. Combination EA` → V2 → V3 Old → V3 → V4. Method public của bản gốc chưa được port thì giữ lại. Code Anhnt tự comment out là thay thế có chủ ý: không bật lại.
9. **Chart change (REASON_CHARTCHANGE/PARAMETERS) không ghi gì và không tạo lại gì.** Class dùng guard `m_first_start`. Đọc luôn `new`/`delete` trong OnInit/OnDeinit của EA cho object đó trong cùng lượt.
10. **Logic thuần thuộc về Engine/Manager, không thuộc CGUIPannel.** Method không đụng control GUI thì không đặt trong CGUIPannel. Data đổi trước, Layer 1 theo sau.

## Cách làm một thay đổi

1. **Rules gate** (SKILL.md) trước khi viết code. Ghi kết quả trong đề xuất. Đề xuất nào trượt một mục thì không đưa ra.
2. **Trace mọi nơi ghi/đọc/so sánh dữ liệu** (EA, Library, Python, lineage) trước lần sửa đầu tiên. Báo cả danh sách một lần, sửa một lượt.
3. **Đề xuất trọn vẹn** một lần, chờ đồng ý với thay đổi cấu trúc, member mới, tham số mới, cột DB mới (cột mới: đo dung lượng DB trên mẫu thật trước).
4. **Chỉ sửa đúng phạm vi được nêu.** Làm dần: comment out → compile để thấy call site → sửa → compile sạch. Chỉ đổi thân method thì sửa tại chỗ; chỉ comment out khi đổi signature. Trước khi sửa, nói rõ diff (file, dòng). Khi Anhnt đang tự sửa tay một file thì chỉ đưa code trong chat.
5. **Đọc cả method trước khi sửa**, grep cả class tìm lời gọi trùng (cùng data, cùng việc) và sửa luôn trong lần đó. Review thì căn cứ code hiện tại, không căn cứ comment hay ghi chú cũ.
6. **Dọn cái thay đổi này để lại:** method/member mất caller cuối cùng vì thay đổi này, dòng mình comment out kèm header box mồ côi, comment hoặc tên method mô tả cách cũ. Không quét xoá cả Library theo "không ai gọi". "Kiểm tra" nghĩa là báo cáo; không xoá hay ghi đè file chưa xem nội dung; chỉ xoá khi đã quét đủ (lineage, không filter tên, đọc được UTF-16) và nói rõ đã quét gì.
7. **Port hoặc dời file:** tra DoEasy/V1/V2 xem class nào giữ state, method nào làm việc; đặt đúng tầng đó. Copy từng concept/method, không bê nguyên file. Dời file: copy nguyên văn → comment out file cũ → compile → sửa tại chỗ, không viết lại từ đầu.
8. **Bug runtime/GUI:** chứng minh bằng `MY DEBUG` print đặt trong chính hàm nghi ngờ và log thật trước khi vá. Grep xem cơ chế tương đương (redraw, guard, flag) đã có chưa trước khi thêm. Bug nằm trong một Control: dựng test EA tối giản.


