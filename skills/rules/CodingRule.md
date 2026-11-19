# Coding Rule

- **Khi coding:**
  - Theo [Working workflow](../AGENTS.md#working-workflow).
  - Đảm bảo Rules gate trong [AGENTS.md](../AGENTS.md).
  - Đồng bộ các thành phần liên quan theo [Concept_SyncEverywhere.md](../concept/Concept_SyncEverywhere.md).

Các mục dưới đây bổ sung chi tiết implementation.

## Cấu trúc class và file

- **Class:** mỗi class một file, có include guard.
- **Getter/setter:** tách rõ Declaration và Implementation; chỉ viết inline khi method ngắn gọn.
- **Module:** `<Class>_Define.mqh`, `<Class>.mqh`, `<Class>_Lifecycle.mqh`, `<Class>_Window_<Name>.mqh`.

## Comment

- **Comment của agent:** tiếng Anh, tối đa một dòng, chỉ cho điều không hiển nhiên; không viết banner kể chuyện, không gắn tag tên/ngày.
- **Header method:** theo khung `//+---+`.
- **Python:** docstring một dòng.

## Debug print

- **Bug runtime/GUI:**
  - Đặt `::Print("MY DEBUG CClass::Method: …")` trong chính hàm nghi ngờ; đo log thật trước khi vá.
  - Dòng log nói rõ đơn vị và ngữ cảnh ("1311 rows on 709 of the 1000 bars").
  - Ghi file chỉ vào `MQL5\Files\<program>\` qua `GetFolderName()`.
  - Đọc kết quả qua [Log Experts tab](#log-experts-tab).
- **Trước khi thêm debug hay vá:** grep cơ chế tương đương đã có (redraw, guard, flag).
- **Bug nằm trong một Control:** dựng test EA tối giản.

## Note của Anhnt trong code

- **Note của Anhnt:** trong code (header file, dòng `// Update in V4…`) agent chỉ đọc, không sửa, không xoá, không đề xuất xoá.
- **Trạng thái:** `[]` là việc chưa xong, `[v]` là đã xong; đưa `[]` vào danh sách rà soát.

## Kiểm tra cái kế thừa trước

- **CBaseObj:** đã có `m_available`, `m_first_start`, `m_object_type`, `GetFolderName()` và các method `Event*` (xem [Concept_Event.md](../concept/Concept_Event.md)).
- **Refresh:** không override `CBaseObjExt::Refresh`; đặt tên `RefreshX` (RefreshSeries, RefreshAccount…).

## Log Experts tab

- **Log sources:**
  - Experts tab: `MQL5\Logs\YYYYMMDD.log`.
  - Journal tab (lỗi trade): `Logs\YYYYMMDD.log`.
- **Quy tắc:** tự grep, không bắt Anhnt dán log.

## Lệnh

- **Lệnh compile:**
  ```powershell
  # /log must be a scratchpad path; a bare /log drops the log next to the source.
  Start-Process "C:\Program Files\MetaTrader 5\MetaEditor64.exe" -Wait -ArgumentList '/compile:"<file.mq5>"','/log:"<scratchpad>\compile.log"'
  Get-Content "<scratchpad>\compile.log" -Encoding Unicode
  ```
- **Trước khi sửa:** Anhnt đóng tab file trong MetaEditor (MetaEditor không tự reload, buffer cũ sẽ đè lên).
- **Sau khi sửa MQL5:** tự compile `EA V5 SQLLite.mq5` (include toàn bộ Library V5), đọc log và sửa lỗi của mình trước khi báo. Nếu Anhnt nói đã tự sửa và compile xong thì không compile lại.
- **Python:** kiểm tra cú pháp bằng `ast.parse`; Python do Anhnt hoặc EA khởi động lại.

## Implementation Rule

- **Tên và màu vendor:** giữ nguyên tên member và màu mặc định; chỉ đổi tên khi nó che mất member của base class.
- **Tái sử dụng code:**
  - Sửa method cũ, đừng thêm method song song.
  - Grep class đó (và `CMarketCollection`, `CommonDELib.mqh` với các hàm `XxxDescription`, `CommonDefines.mqh`) tìm method hoặc enum sẵn có trước khi viết; control GUI thì tìm `ChangeSize`.
  - Số liệu theo symbol lấy từ `CSymbol` (`Spread()`, `TradeStopLevel()`, `Point()`, `Digits()`), không tự tính.
  - Member, tham số hay enum mới: báo và chờ đồng ý trước.
- **Giữ code gốc:**
  - "Không ai gọi" chưa chắc là dead code. Tra lineage Library `2. DoEasy. Service functions Lib` → `4. Combination Lib` (V1) → V2 → V3 → V4; EA `4. Combination EA` → V2 → V3 Old → V3 → V4.
  - Method public của bản gốc chưa được port thì giữ lại. Code Anhnt tự comment out là thay thế có chủ ý: không bật lại.
- **Chart change (`REASON_CHARTCHANGE/PARAMETERS`):** không ghi gì và không tạo lại gì. Class dùng guard `m_first_start`. Đọc luôn `new`/`delete` trong OnInit/OnDeinit của EA cho object đó trong cùng lượt.
- **Phân tầng:** logic thuần thuộc về Engine/Manager, không thuộc `CGUIPannel`. Method không đụng control GUI thì không đặt trong `CGUIPannel`. Data đổi trước, Layer 1 theo sau.
- **Giao tiếp/review:**
  - Không phân đúng/sai, không xin lỗi: nói ngắn mình hiểu gì, đề xuất gì (một khuyến nghị), đã sửa gì.
  - Khác ý thì đưa dữ kiện (code, log, số đo, backtest), không tranh ai đúng (Rules gate 0: thị trường luôn đúng).
  - Anhnt soát kỹ, bắt ngay fix chưa kiểm chứng hoặc thừa. Log/data đã chứng minh thì nói thẳng là xong, không hỏi lại "cậu xem đúng chưa".
- **Ngôn ngữ:** file ghi chú, kế hoạch viết tiếng Việt; comment trong code tiếng Anh.

## Cách làm một thay đổi

0. **Bàn trước, làm một thể:** theo bước Communication/Plan trong `AGENTS.md`.
   - Trước khi đề xuất, đọc Imp hiện tại, ProblemNote theo thành phần và `references\` theo từ khoá; dẫn tài liệu làm căn cứ, không hỏi lại điều đã chốt.
   - Ghi kết luận, lý do/dữ kiện, trạng thái, thay đổi theo thành phần và việc còn mở vào Imp tương ứng. ProblemNote chỉ ghi History Update tóm tắt theo thứ tự implementation.
   - Khi còn việc cần chốt thì không code/compile. Chốt xong mới code; sau khi làm, cập nhật Imp và ghi bước đã xử lý vào ProblemNote.
1. **Rules gate:** áp dụng và ghi kết quả theo Rules gate trong `AGENTS.md`.
2. **Trace mọi nơi ghi/đọc/so sánh dữ liệu** (EA, Library, Python, lineage) trước lần sửa đầu tiên.
   - Với event, trace cả listener: event mới thì ai phải nghe, params đổi thì ai phải `EventUnpack` lại, data đổi mà không fire thì ai bị lỡ (vd `SLOT_CHANGED` chưa có `CPythonBridge` nghe).
   - Báo cả danh sách một lần, sửa một lượt.
3. **Chỉ sửa đúng phạm vi được nêu.**
   - Làm dần: comment out → compile để thấy call site → sửa → compile sạch.
   - Chỉ đổi thân method thì sửa tại chỗ; chỉ comment out khi đổi signature.
   - Trước khi sửa, nói rõ diff (file, dòng). Khi Anhnt đang tự sửa tay một file thì chỉ đưa code trong chat.
4. **Đọc cả method trước khi sửa:** grep cả class tìm lời gọi trùng (cùng data, cùng việc) và sửa luôn trong lần đó. Review thì căn cứ code hiện tại, không căn cứ comment hay ghi chú cũ.
5. **Dọn cái thay đổi này để lại:**
   - Method/member mất caller cuối cùng vì thay đổi này, dòng mình comment out kèm header box mồ côi, comment hoặc tên method mô tả cách cũ.
   - Không quét xoá cả Library theo "không ai gọi". "Kiểm tra" nghĩa là báo cáo; không xoá hay ghi đè file chưa xem nội dung.
   - Chỉ xoá khi đã quét đủ (lineage, không filter tên, đọc được UTF-16) và nói rõ đã quét gì.
6. **Port hoặc dời file:**
   - Tra DoEasy/V1/V2 xem class nào giữ state, method nào làm việc; đặt đúng tầng đó. Copy từng concept/method, không bê nguyên file.
   - Dời file: copy nguyên văn → comment out file cũ → compile → sửa tại chỗ, không viết lại từ đầu.
7. Không tự commit hoặc push.
