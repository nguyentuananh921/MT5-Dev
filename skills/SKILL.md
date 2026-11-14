---
name: combination
description: >-
  Rules, repo map, commands and workflow for Anhnt's MT5-Dev repo (D:\MT5-Dev).
  Only two folders are edited: Combination Lib V5 (D:\MT5-Dev\Library, except vendor
  tradecanvas\ and Kronos\) and EA V5 (Experts\Anhnt\Example EA\4. Combination EA V5);
  every other folder is read-only reference. Covers GUIPannel, Library\Python, Web/TradeCanvas,
  RAM vs DB, events, collections vs managers, naming, comments, debug prints, compile.
  Use for any work in D:\MT5-Dev or on files that include <Combination Lib V5\...>.
---

## Rules gate: mục tiêu tối thượng

Chạy trước mọi đề xuất, ghi kết quả vào đề xuất. Luật trong `references\` là cách làm cụ thể của Rules gate; chỗ nào trái nhau thì theo Rules gate.

1. **CleanArchitecture**: Tuân thủ CleanArchitecture dependency rule, tức tầng trong không được biết tầng ngoài.
2. **No Duplicate**: cái này đã được tính hoặc có sẵn ở đâu chưa (Library, base class, MT5, Python)?
3. **MVC**: đây là Model (DB, Manager), Controller (EA, Manager OnInit) hay View (EA vẽ, TradeCanvas)? View chỉ nhận data và hiển thị, không tính, không lọc.
4. **Event Rule**: class nào đổi data thì class đó tự fire event; listener có cần đổi không?
5. **Sync Everywhere**: liệt kê mọi thứ phải đổi theo: MQL ↔ Python ↔ `references/Python.md` ↔ ghi chú; EA vẽ ↔ TradeCanvas vẽ.
6. **Conventions**: các luật trong `references/CodingRule.md`.

## References

- [references/communication.md](references/communication.md): cách giao tiếp với Anhnt. Đọc ngay khi nạp skill, trước câu trả lời đầu tiên.
- [references/CodingRule.md](references/CodingRule.md): luật code (kế thừa, event, đặt tên, comment, debug print). Đọc trước khi đề xuất, viết hoặc review code.
- [references/WorkingOnRamSaveToDB.md](references/WorkingOnRamSaveToDB.md): RAM vs DB, Setting vs result, list trên RAM. Đọc trước khi đề xuất, viết hoặc review code đụng tới data, DB, Manager, Collection hay Python.
- [references/ParentChild.md](references/ParentChild.md): quan hệ cha–con giữa các object (ai fire event, ai relay, ai nghe). Đọc trước khi đề xuất, viết hoặc review code có Collection, list con hoặc event.
- [references/Python.md](references/Python.md): Python của V5 (tiến trình, worker Current/Live/History, `Setting_Sync`, ghi DB, server/socket, Kronos). Đọc trước khi đề xuất, viết hoặc review code Python, hoặc trước khi nói data đã sẵn sàng.
- [references/ToolBugNote.md](references/ToolBugNote.md): bẫy công cụ (UTF-16, Grep, Edit "not found", tô màu VS Code). Đọc trước khi sửa code MQL5, và khi Read/Grep/Edit cho kết quả lạ.

## Repo

Chi tiết 2 thư mục làm việc:
- `Library\`: Collections, Controllers, Entities, Services, Trading, UseCases.
  - `Library\Python\`: tính toán, ghi DB, server cho Web.
  - `Library\tradecanvas\`, `Library\Kronos\`: Vendor Library (git clone, nằm trong `.git\info\exclude`), không sửa.
- EA V5: `EA V5 SQLLite.mq5`, `GUIPannel\`, `Services\`, `Web\` (TradeCanvas).

## Lệnh

```powershell
# /log must be a scratchpad path; a bare /log drops the log next to the source.
Start-Process "C:\Program Files\MetaTrader 5\MetaEditor64.exe" -Wait -ArgumentList '/compile:"<file.mq5>"','/log:"<scratchpad>\compile.log"'
Get-Content "<scratchpad>\compile.log" -Encoding Unicode
```

- Anhnt đóng tab file trong MetaEditor trước khi agent sửa (MetaEditor không tự reload, buffer cũ sẽ đè lên).
- Sau mỗi lần agent sửa MQL5: tự compile `EA V5 SQLLite.mq5` (include toàn bộ Library V5) để compiler bắt lỗi, đọc log, sửa lỗi của mình rồi mới báo. Khi Anhnt nói đã tự sửa và compile xong thì không compile lại.
- Python: kiểm tra cú pháp bằng `ast.parse`; Python do Anhnt hoặc EA khởi động lại.
- Web: `npm run build` trong `EA V5\Web`.
- Log Experts tab: `MQL5\Logs\YYYYMMDD.log`. Log Journal tab (lỗi trade): `Logs\YYYYMMDD.log`. Tự grep, không bắt Anhnt dán log.

## Luôn làm

- **Đọc trước khi hỏi.** Grep skill này (cả `references\`) và memory theo từ khoá. Chỉ hỏi khi không có câu trả lời ở đó, và nói đã tìm ở đâu.
- Không tự commit hoặc push.
