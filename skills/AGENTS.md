## Rules gate: mục tiêu tối thượng

  Rules gate áp dụng xuyên suốt Working workflow. Trong Communication, ghi kết quả kiểm tra vào đề xuất; ở các bước sau, tiếp tục ghi nhận thay đổi và trạng thái đồng bộ theo Sync Everywhere để giữ bối cảnh, tránh lặp lại. Luật trong `rules\` và hướng dẫn trong `references\` bổ sung cách thực hiện cụ thể; nếu có mâu thuẫn, ưu tiên Rules gate.

  0. **Thị trường luôn đúng**: chỉ có tớ với cậu sai. Mọi quyết định (logic, tham số, luật) chốt bằng dữ kiện: số đo, parity với MT5, backtest (trên Web trước, chạy thật sau: `references/WebModule.md`); không theo ý agent hay ý Anhnt. Chưa có dữ kiện thì đề xuất cách đo trước.
  1. **CleanArchitecture**: Tuân thủ CleanArchitecture dependency rule, tức tầng trong không được biết tầng ngoài.
  2. **No Duplicate**: cái này đã có tính hoặc có sẵn ở đâu chưa? Rà soát các thành phần theo [Working scope và Sync Everywhere](#working-scope-và-sync-everywhere) và nguyên tắc trong [Concept_SyncEverywhere.md](concept/Concept_SyncEverywhere.md).
  3. **MVC**: đây là Model (DB, Manager), Controller (EA, Manager OnInit) hay View (EA vẽ)? View chỉ nhận data và hiển thị, không tính, không lọc. TradeCanvas không thuộc vòng này: xem `references/WebModule.md`.
  4. **Working with Event**: theo [Concept_Event.md](concept/Concept_Event.md), [Concept_ParentChild.md](concept/Concept_ParentChild.md) và [Imp_Event.md](Implementaion/Imp_Event.md). Trace thay đổi từ object sở hữu data qua thành phần phát sinh tới các thành phần/listener anh em cần nhận; dùng đúng contract liên thành phần. Trong một Event Bus, object phát hiện thay đổi có ý nghĩa tự fire, parent không relay. Chỉ xử lý khi có thay đổi, không poll.
  5. **Sync Everywhere**: theo [concept/Concept_SyncEverywhere.md](concept/Concept_SyncEverywhere.md).
  6. **Conventions**: các luật trong [CodingRule.md](rules/CodingRule.md).

## Workspace access policy

Áp dụng quy tắc khớp cụ thể nhất; ngoại lệ bên dưới ghi đè thư mục cha.

### Working scope và Sync Everywhere

System là cha ở cấp kiến trúc; các mục dưới đây là **thành phần/phạm vi làm việc** ngang hàng trong System. Các thành phần trao đổi qua contract phù hợp (DB, Event, socket...), không mặc định qua một thành phần trung gian. Bên trong từng thành phần, “module” là đơn vị tổ chức code. Khi thay đổi một thành phần, đồng bộ mọi thành phần liên quan để chúng phản ánh thay đổi nhất quán.

- **EA Module:** `D:\MT5-Dev\Experts\Anhnt\Example EA\4. Combination EA V5\`, ngoại trừ `Web\`; MQL5 của EA cần đồng bộ với Library khi có contract hoặc data chung.
- **EA Web:** `D:\MT5-Dev\Experts\Anhnt\Example EA\4. Combination EA V5\Web\`; đồng bộ Input/Function/Output và Setting khi thay đổi contract.
- **Library:** `D:\MT5-Dev\Library\`, ngoại trừ `Python\`, `Kronos\` và `tradecanvas\`; phần MQL5 Library.
- **Library\Python:** `D:\MT5-Dev\Library\Python\`; đồng bộ calculation, setting và dữ liệu lưu DB với EA/Library/Web.
- **Database:** `<MT5_EA_DATABASE>\`; database runtime của EA V5:
  - alias: `<MT5_TERMINAL_DATA>\MQL5\Files\EA V5 SQLLite\Database`
  - `<MT5_TERMINAL_DATA>`: `%APPDATA%\MetaQuotes\Terminal\<terminal-id>`
  - terminal đang dùng: `C:\Users\nguye\AppData\Roaming\MetaQuotes\Terminal\D0E8209F77C8CF37AD8BF550E51FF075`
  - đồng bộ schema, luồng đọc/ghi và các Setting liên quan.
- **Skills:** `D:\MT5-Dev\skills\` (chỉ sửa khi có yêu cầu rõ trong lượt hiện tại); ghi cập nhật tài liệu và implementation sau khi code hoặc xác nhận kết quả.

Nếu thành phần liên quan chưa đồng bộ được, ghi rõ phần còn lệch, lý do hoãn và việc cần làm tiếp; chưa coi thay đổi là hoàn tất.

### Working — Read-only (Vendor)
- `D:\MT5-Dev\Library\Kronos\`
- `D:\MT5-Dev\Library\tradecanvas\`
- `D:\MT5-Dev\Library\xgboost\`
- Được đọc và dùng như dependency; không sửa hay cập nhật thủ công. Khi cần cập nhật vendor, chỉ dùng [`git pull`](Notes/CommandNote.md#pull-all).
- Khi thêm thư mục vào danh sách này, đồng thời thêm đúng đường dẫn vào `.gitignore` để quy tắc áp dụng cho mọi người; kiểm tra bằng `git check-ignore`. Xem lệnh mẫu tại [CommandNote.md](Notes/CommandNote.md#git-ignore).

### Reference-only
- Tất cả thư mục khác trong `D:\MT5-Dev\` không thuộc các phạm vi đã liệt kê bên trên.
- Chỉ mở khi task cần tham khảo; không chỉnh sửa.

## Working workflow

  1. **Communication:** Đọc [CommunicationRule.md](rules/CommunicationRule.md) khi nạp skill, trước câu trả lời đầu tiên. Trước khi hỏi, grep skill này (cả `references\`) và memory theo từ khoá; chỉ hỏi nếu chưa có câu trả lời, và nói rõ đã tìm ở đâu. Làm rõ thay đổi theo [Sync Everywhere trong Rules gate](#rules-gate-mục-tiêu-tối-thượng) và phạm vi ở [Working scope và Sync Everywhere](#working-scope-và-sync-everywhere); ghi kết luận, căn cứ, trạng thái và việc còn mở vào Imp tương ứng. ProblemNote là History Update tóm tắt theo thứ tự implementation.
  2. **Plan:** Cập nhật tài liệu Plan để thể hiện rõ các thành phần bị ảnh hưởng và thay đổi dự kiến ở từng thành phần trước khi code.
  3. **Coding:** Đọc [CodingRule.md](rules/CodingRule.md); theo [Concept_SyncEverywhere.md](concept/Concept_SyncEverywhere.md), triển khai các thay đổi đã chốt ở mọi thành phần liên quan. Nếu chưa đồng bộ được thành phần nào, ghi rõ lý do và việc cần làm tiếp.
  4. **Update documentation:** Cập nhật Imp theo kết quả thực tế ở từng thành phần; cập nhật Concept nếu nguyên tắc đã chốt thay đổi; ghi History Update tóm tắt vào ProblemNote theo thứ tự implementation. Ghi rõ phần đã đồng bộ và việc còn lại, tuân thủ Workspace access policy.

## References

- [concept/Concept_WorkingOnRamSaveToDB.md](concept/Concept_WorkingOnRamSaveToDB.md) và [Implementaion/Imp_WorkingOnRamSaveToDB.md](Implementaion/Imp_WorkingOnRamSaveToDB.md): nguyên tắc RAM/DB và hiện trạng theo thành phần (ai ghi table nào, cách lưu Setting/result, cách làm việc trên RAM). Đọc cả hai trước khi đề xuất hoặc review code đụng data, DB, Manager, Collection hoặc Python.
- [concept/Concept_ParentChild.md](concept/Concept_ParentChild.md): định nghĩa quan hệ parent–child/composition. Đọc khi làm việc với object cha–con.
- [references/Python.md](references/Python.md): Python của V5 (tiến trình, worker Current/Live/History, `Setting_Sync`, ghi DB, server/socket, Kronos). Đọc trước khi đề xuất, viết hoặc review code Python, hoặc trước khi nói data đã sẵn sàng.
- [Implementaion/Imp_Kronos.md](Implementaion/Imp_Kronos.md): hiện trạng tích hợp Kronos theo Working scope; đọc khi làm việc với phần tích hợp V5. Khi cần tra concept hoặc cách dùng Kronos vendor, xem trực tiếp [README.md](../Library/Kronos/README.md) (Read-only).
- [references/ToolBugNote.md](references/ToolBugNote.md): bẫy công cụ (UTF-16, Grep, Edit "not found", tô màu VS Code). Đọc trước khi sửa code MQL5, và khi Read/Grep/Edit cho kết quả lạ.
- [concept/Concept_Event.md](concept/Concept_Event.md) và [Implementaion/Imp_Event.md](Implementaion/Imp_Event.md): concept, cơ chế và hiện trạng Event. Đọc trước khi đề xuất, viết hoặc review event.
- [concept/Concept_SyncEverywhere.md](concept/Concept_SyncEverywhere.md): cách rà soát tác động chéo và đồng bộ thay đổi. Đọc khi thêm class/feature hoặc thay đổi contract dùng chung.
- [concept/Concept_Strategy.md](concept/Concept_Strategy.md): Strategy là quyết định dựa trên việc ghép các event. Đọc trước khi đề xuất, viết hoặc review strategy, signal, Bar information.
- [concept/Concept_RiskManagement.md](concept/Concept_RiskManagement.md) và [Implementaion/Imp_RiskManagement.md](Implementaion/Imp_RiskManagement.md): concept, hiện trạng và việc còn làm của RiskManagement.
- [concept/Concept_IndicatorOnIndicator.md](concept/Concept_IndicatorOnIndicator.md): Indicator trên indicator. Đọc khi làm việc với nguồn/applied của indicator.
- [references/WebModule.md](references/WebModule.md): Web / TradeCanvas (input, function, output, file `src\`, TradeCanvas có gì thiếu gì đã đo, build). Đọc trước khi đề xuất, viết hoặc review code Web, và trước khi thử hay implementation một strategy, signal, cách vẽ.
- [references/ProblemNote.md](references/ProblemNote.md): History Update tóm tắt vấn đề và các bước đã xử lý, theo thành phần và thứ tự implementation; đọc khi bắt đầu việc liên quan và giữ lịch sử, không xoá dòng.

## ProblemNote routing

ProblemNote là History Update: ghi tóm tắt vấn đề và bước đã xử lý theo thành phần/phạm vi, theo thứ tự implementation. Kết luận, căn cứ, trạng thái và việc còn mở ghi chi tiết trong `Implementaion\Imp_<Name>.md`; ProblemNote giữ link trỏ tới đó.

- `Library\Python\` → `## Library\Python`; phần còn lại của `Library\` → `## Library`.
- `EA V5\Web\` → `## EA V5\Web`; phần còn lại của EA V5 → `## EA V5`.
- `skills\` → `## skills`.

## Memory migration
- Thư mục Auto Memory hiện tại: `D:\MT5-Dev\skills\memory`
- Thư mục Auto Memory cũ: `C:\Users\nguye\.claude\projects\D--MT5-Dev\memory`; chỉ dùng để rà soát và chuyển dần, không ghi thêm vào đó.
- Migration đang diễn ra: chỉ chuyển những ghi nhớ còn đúng, không bê nguyên các mục đã cũ. Không xóa thư mục cũ cho đến khi Anhnt xác nhận.