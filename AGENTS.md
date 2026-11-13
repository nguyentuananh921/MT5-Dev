# Làm việc trên MT5-Dev

Ghi chú cho coding agent (Claude Code, Cursor, Codex…) khi **sửa** repo này.
Luật khi **viết code dùng Library V5** nằm trong skill
[`skills/combination-lib-v5`](skills/combination-lib-v5/SKILL.md).
Luật gốc là của Anhnt, nằm trong Readme của EA (xem bảng dưới); file này chỉ
trỏ tới đó, không chép lại.

## Giao tiếp

- Trả lời bằng tiếng Việt, xưng cậu/tớ, ngắn gọn, đi thẳng vào việc.
- Dùng thẳng tên class, method, property và thuật ngữ tiếng Anh (Position,
  business rules, use case), không dịch.
- Không phán đúng/sai, không xin lỗi: nói ngắn mình hiểu gì, đề xuất gì (một
  khuyến nghị), đã sửa gì.

## Repo

| Đường dẫn | Có gì |
|---|---|
| `Library\` | **Combination Lib V5** (Collections, Controllers, Entities, Services, Trading, UseCases). MT5 thấy nó qua junction `MQL5\Include\Combination Lib V5`. |
| `Library\Python\` | Python của V5 (tính toán, ghi DB, server cho Web). Quy tắc: `Library\Python\Python.md`. |
| `Library\tradecanvas\`, `Library\Kronos\` | Vendor: git clone, **chỉ đọc**, nằm trong `.git\info\exclude`. |
| `Experts\Anhnt\Example EA\4. Combination EA V5\` | EA V5 (`EA V5 SQLLite.mq5`), `GUIPannel\`, `Services\`, `Web\` (TradeCanvas), `Readme\`. |
| `…\4. Combination EA V5\Readme\` | **Luật của Anhnt**: `Readme.md`, `CommonRule.md`, `Update\Update.md`, các file `<task> Task.md` (của Anhnt) và `<task> My Note.md` (của agent). |
| `Include\Vendors\Anhnt\Old Library\` | Lib V1–V4. Dùng để tra lineage, không sửa. |
| `Include\Vendors\<tác giả>\` | Reference/vendor (DoEasy Artyom Trishkin, Anatoli Kazharski…). Chỉ đọc. |
| `Indicators\Vendors\Anhnt\Custom Buildin\` | Indicator tự viết. |
| `skills\` | Skill cho agent, link vào `C:\Users\nguye\.claude\skills\` bằng junction. |

Thư mục MT5: `C:\Users\nguye\AppData\Roaming\MetaQuotes\Terminal\D0E8209F77C8CF37AD8BF550E51FF075\MQL5`.
`D:\MT5-Dev` và thư mục MT5 chứa cùng mã nguồn: trước khi sửa, xác nhận
đang sửa đúng bản nào.

Lineage (tra khi port hoặc khi định xoá "code không ai gọi"):
- Library: `2. DoEasy. Service functions Lib` → `4. Combination Lib` (V1) → V2 → V3 → V4 → V5
- EA: `4. Combination EA` → V2 → V3 Old → V3 → V4 → V5

## Lệnh

```powershell
# Compile (sau mỗi lần agent sửa MQL5). /log phải là đường dẫn trong scratchpad,
# không để trống, nếu không log rơi cạnh file nguồn.
Start-Process "C:\Program Files\MetaTrader 5\MetaEditor64.exe" -Wait -ArgumentList '/compile:"<file.mq5>"','/log:"<scratchpad>\compile.log"'
Get-Content "<scratchpad>\compile.log" -Encoding Unicode
```

- EA V5: compile `Experts\Anhnt\Example EA\4. Combination EA V5\EA V5 SQLLite.mq5` (nó include toàn bộ Library V5).
- Python: kiểm tra cú pháp bằng `ast.parse`; Python do Anhnt hoặc EA khởi động lại.
- Web: `npm run build` trong `EA V5\Web`.
- Log Experts tab: `MQL5\Logs\YYYYMMDD.log`. Log Journal tab (lỗi trade): `<Terminal>\Logs\YYYYMMDD.log`. Tự grep, không bắt Anhnt dán log.
- Khi Anhnt nói đã tự sửa và compile xong thì không compile lại.

## Cách làm một thay đổi

1. **Đọc trước khi hỏi.** Grep `Readme\`, `Update\`, `Python.md` và memory theo từ khoá. Chỉ hỏi khi không có câu trả lời ở đó, và nói đã tìm ở đâu.
2. **Rules gate trước khi viết code** (luật không đổi từ V1 đến V5). Ghi kết quả trong đề xuất:
   No Duplicate · MVC · Event Rule · Sync Everywhere · Conventions. Đề xuất nào trượt một mục thì không đưa ra.
3. **Trace mọi nơi ghi/đọc/so sánh dữ liệu** (EA, Library, Python, lineage) trước lần sửa đầu tiên. Báo cả danh sách một lần, sửa một lượt.
4. **Đề xuất trọn vẹn** một lần, chờ đồng ý với thay đổi cấu trúc, member mới, tham số mới, cột DB mới (cột mới: đo dung lượng DB trước).
5. **Chỉ sửa đúng phạm vi được nêu.** Làm dần: comment out → compile để thấy call site → sửa → compile sạch.
6. **Dọn cái thay đổi này để lại:** method/member mất caller cuối cùng vì thay đổi này, dòng mình comment out, comment mô tả cách cũ. Không quét xoá cả Library theo "không ai gọi".
7. **Compile**, đọc log, sửa lỗi của mình rồi mới báo.
8. **Ghi chú:** chi tiết thay đổi vào `Readme\Update\<task> My Note.md`. Chỉ sửa `Readme.md` khi Anhnt nói "ghi vào README" (một dòng). Không bao giờ sửa file `Task.md` của Anhnt.
9. Không tự commit hoặc push.

## Ranh giới

- Vendor và `Old Library`: chỉ đọc.
- File trong `Library\` dùng chung cho nhiều EA: sửa xong kiểm tra mọi EA/indicator include nó.
- Không xoá hay ghi đè file khi chưa xem nội dung. Xoá thì nói rõ đã quét những gì.
- Đóng tab file trong MetaEditor trước khi agent sửa (MetaEditor không tự reload, buffer cũ sẽ đè lên).
- Thảo luận thiết kế còn mở thì ghi vào memory hoặc `My Note.md`, không ghi vào comment code.

## Hội thoại cũ

Đổi workspace thì hội thoại cũ không mất: nó nằm trong `C:\Users\nguye\.claude\projects\`, mỗi thư mục làm việc một chỗ. Mở lại bằng `/resume` từ đúng thư mục đó.

## Bẫy công cụ

- Một số `.mqh` là UTF-16LE (ví dụ file DoEasy). Đọc/sửa bằng PowerShell `-Encoding Unicode`; `git diff` hiện "Bin".
- Grep trên cả gốc `MQL5\` có thể trả về rỗng sai. Grep trong thư mục con cụ thể; không search cả ổ, lần theo `#include`.
- Grep đôi khi hiện `//` thành `\`. Khi Edit báo "not found" trên dòng comment, kiểm tra byte bằng `sed -n 'Np' file | cat -A`.
- VS Code tô màu `.mqh` theo grammar C++: không đặt toán tử ba ngôi giữa hai string, không truyền `":"` làm một tham số riêng của `Print`. Ghép string trước rồi mới in.
