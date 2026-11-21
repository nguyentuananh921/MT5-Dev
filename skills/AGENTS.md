## Rules gate: mục tiêu tối thượng

Rules gate là bộ lọc trước mỗi câu hỏi và mỗi đề xuất, áp dụng tại các bước của [Working workflow](#working-workflow), để trao đổi không lặp lại hay luẩn quẩn. Luật trong `rules\` và hướng dẫn trong `Notes\` bổ sung cách thực hiện cụ thể; nếu có mâu thuẫn, ưu tiên Rules gate.

0. **Thị trường luôn đúng**: chỉ có tớ với cậu sai.
   - Mọi quyết định (logic, tham số, luật) chốt bằng dữ kiện: số đo, parity với MT5, backtest hoặc Strategy Tester; không theo ý agent hay ý Anhnt.
   - Chưa có dữ kiện thì đề xuất cách đo trước.
1. **CleanArchitecture**: Tuân thủ CleanArchitecture dependency rule, tức tầng trong không được biết tầng ngoài.
2. **No Duplicate**: method/member/key/enum định thêm đã có sẵn ở đâu chưa?
   - Tìm theo [Tránh thêm Method mới](rules/CodingRule.md#implementation-rule) và ghi kết quả vào đề xuất.
   - Rà soát các thành phần theo [Working scope và Sync Everywhere](#working-scope-và-sync-everywhere) và nguyên tắc trong [SyncEverywhere.md](Notes/SyncEverywhere.md).
3. **MVC**: đây là Model (DB), Controller (EA, Manager) hay View (EA vẽ)?
   - View chỉ nhận data và hiển thị, không tính, không lọc.
   - EA Web là thành phần riêng trong Working scope.
4. **Working with Event**: theo [Event.md](Notes/Event.md) và [ParentChild.md](Notes/ParentChild.md).
   - <a id="automation"></a>**Automation:** mỗi **loại object** ([Luồng thêm Event](Notes/Event.md#luồng-thêm-event)) tự làm việc của mình khi nhận Event; không loại object nào hỏi hộ hay làm hộ loại khác.
     - Event sinh ra để có Automation: loại object sở hữu thay đổi tự fire; loại object có việc liên quan tự nghe và tự làm.
     - Automation diễn ra ở mọi loại object trong System, không riêng Strategy hay Trading.
   - Trace thay đổi từ object sở hữu data qua thành phần phát sinh tới các thành phần/listener anh em cần nhận; dùng đúng contract liên thành phần.
   - Trong một Event Bus, object phát hiện thay đổi có ý nghĩa tự fire, parent không relay.
   - Chỉ xử lý khi có thay đổi, không poll.
5. **Sync Everywhere**: theo [SyncEverywhere.md](Notes/SyncEverywhere.md).
6. **Conventions**: các luật trong [CodingRule.md](rules/CodingRule.md).

## System

Current System là một system tự động ([Automation](#automation)) dựa trên [Event](Notes/Event.md#event-note).

- **Kiến trúc:** System là parent; các thành phần trong [Working scope](#working-scope-và-sync-everywhere) là anh em, theo [Parent Child Note](Notes/ParentChild.md#parent-child-note).
  - Các thành phần trao đổi trực tiếp qua contract phù hợp (DB, Event, socket...), không qua một thành phần trung gian; contract theo [Communication Note](Notes/Communication.md#communication-note).
  - Bên trong từng thành phần, “module” là đơn vị tổ chức code.
  - Thay đổi một thành phần thì đồng bộ theo [Sync Everywhere](Notes/SyncEverywhere.md#sync-everywhere).
- **Reference chỉ là mảnh nhỏ:** mỗi EA/Reference thường một strategy, một symbol, không Event.
  - Lấy concept của Reference theo New Concept ([CodingRule.md](rules/CodingRule.md#implementation-rule)).
  - Phần Reference thiếu cho nhiều Strategy và Automation thì tự thiết kế theo Notes; không hỏi lại "Reference không có".

## Workspace access policy

Áp dụng quy tắc khớp cụ thể nhất; ngoại lệ bên dưới ghi đè thư mục cha.

### Working scope và Sync Everywhere

Các thành phần của [System](#system):

- **EA Module:** `D:\MT5-Dev\Experts\Anhnt\Example EA\4. Combination EA V5\`, ngoại trừ `Web\`; MQL5 của EA cần đồng bộ với Library khi có contract hoặc data chung.
- **EA Web:** `D:\MT5-Dev\Experts\Anhnt\Example EA\4. Combination EA V5\Web\`; đồng bộ Input/Function/Output và Setting khi thay đổi contract.
- **Library:** `D:\MT5-Dev\Library\`, ngoại trừ `Python\` (thuộc Library\Python) và các thư mục trong [Working — Read-only (Vendor)](#working--read-only-vendor); phần MQL5 Library.
- **Library\Python:** `D:\MT5-Dev\Library\Python\`; đồng bộ calculation, setting và dữ liệu lưu DB với EA/Library/Web.
- **Database:** SQLite runtime của EA V5 tại `<MT5_EA_DATABASE>\`:
  - alias: `<MT5_TERMINAL_DATA>\MQL5\Files\EA V5 SQLLite\Database`
  - `<MT5_TERMINAL_DATA>`: `%APPDATA%\MetaQuotes\Terminal\<terminal-id>`
  - terminal đang dùng: `C:\Users\nguye\AppData\Roaming\MetaQuotes\Terminal\D0E8209F77C8CF37AD8BF550E51FF075`
  - đồng bộ schema, luồng đọc/ghi và các Setting liên quan.
- **Skills:** `D:\MT5-Dev\skills\`
  - Mọi thay đổi phải hỏi lại Anhnt trước khi sửa, ngoại trừ `memory\` (agent được tự ghi).
  - Ghi cập nhật tài liệu và implementation sau khi code hoặc xác nhận kết quả.

### Working — Read-only (Vendor)

- `D:\MT5-Dev\Library\Kronos\`
- `D:\MT5-Dev\Library\tradecanvas\`
- `D:\MT5-Dev\Library\xgboost\`
- Được đọc và dùng như dependency; không sửa hay cập nhật thủ công.
  - Khi cần cập nhật vendor, chỉ dùng [`git pull`](Notes/Command.md#pull-all).
- Khi thêm thư mục vào danh sách này, đồng thời thêm đúng đường dẫn vào `.gitignore` để quy tắc áp dụng cho mọi người.
  - Kiểm tra bằng `git check-ignore`; lệnh mẫu tại [Command.md](Notes/Command.md#git-ignore).

### Reference-only

- Tất cả thư mục khác trong `D:\MT5-Dev\` không thuộc các phạm vi đã liệt kê bên trên.
- Chỉ mở khi task cần tham khảo; không chỉnh sửa.
- Code ở đây là mảnh nhỏ so với System: cách dùng theo [System](#system).

## Working workflow

1. **Communication (trước khi hỏi):**
   - Đọc [CommunicationRule.md](rules/CommunicationRule.md) khi nạp skill, trước câu trả lời đầu tiên.
   - Tự chạy các [Rules gate](#rules-gate-mục-tiêu-tối-thượng) 0–6 trên Note, rule, memory và code (tìm theo từ khoá, kể cả `Notes\`).
     - Gate nào đã trả lời được thì áp dụng luôn, không hỏi.
   - Chỉ hỏi phần gate không tự quyết được (lựa chọn thuộc về Anhnt, hoặc chưa có dữ kiện) và nói rõ đã tra ở đâu.
   - Làm rõ thay đổi theo Sync Everywhere và phạm vi ở [Working scope và Sync Everywhere](#working-scope-và-sync-everywhere).
2. **Plan (trong đề xuất):**
   - Trước khi code, xác định các thành phần bị ảnh hưởng và thay đổi dự kiến ở từng thành phần.
   - Ghi kết quả ngắn của từng gate có liên quan, mỗi gate một dòng kèm căn cứ.
     - Ví dụ: `No Duplicate: grep spread trong Library\Trading → PEND_REQ_ACTIVATE_BY_SYMBOL_SPREAD`.
     - Gate không liên quan thì bỏ qua.
3. **Coding:**
   - Đọc [CodingRule.md](rules/CodingRule.md); theo [SyncEverywhere.md](Notes/SyncEverywhere.md), triển khai các thay đổi đã chốt ở mọi thành phần liên quan.
4. **Update documentation (sau khi chốt):**
   - Ghi kết luận vào Note liên quan ngay trong lượt đó (hoặc memory nếu là cách làm việc).
     - Điểm đã chốt chỉ được mở lại khi có dữ kiện mới (gate 0).
   - Chi tiết implementation ghi trong code (header class, comment member) theo [CodingRule.md](rules/CodingRule.md#comment).
   - Note chỉ giữ concept, điểm đã chốt, việc chưa làm và link tới code; sửa Note tuân thủ Workspace access policy.

## References

- [WorkingOnRamSaveToDB.md](Notes/WorkingOnRamSaveToDB.md): nguyên tắc RAM/DB; đọc khi làm việc với data, DB, Manager, Collection hoặc Python.
- [ParentChild.md](Notes/ParentChild.md): quan hệ parent–child/composition; đọc khi làm việc với object cha–con.
- [Event.md](Notes/Event.md): Event và cơ chế Event Bus; đọc khi đề xuất, viết hoặc review event.
- [SyncEverywhere.md](Notes/SyncEverywhere.md): rà soát tác động chéo và đồng bộ thay đổi; đọc khi thêm class/feature hoặc thay đổi contract dùng chung.
- [Strategy.md](Notes/Strategy.md): concept Strategy và RiskManagement; đọc khi làm việc với strategy, signal hoặc Bar information.
- [IndicatorOnIndicator.md](Notes/IndicatorOnIndicator.md): Indicator trên indicator; đọc khi làm việc với source/applied của indicator.
- [Communication.md](Notes/Communication.md): contract giao tiếp giữa EA, Python server và Web; đọc khi làm việc với TCP, HTTP API, WebSocket hoặc file bridge.
- [README.md](../Experts/Anhnt/Example%20EA/4.%20Combination%20EA%20V5/Web/README.md): hướng dẫn hiện có của EA Web.
- [README.md](../Library/Kronos/README.md): cách dùng vendor Kronos (Read-only).
- [CodingRule.md](rules/CodingRule.md) và [CommunicationRule.md](rules/CommunicationRule.md): coding và trao đổi.
- [Command.md](Notes/Command.md): các command Anhnt cần nhớ theo thành phần; đọc khi cần chạy lệnh (build, pull vendor, git, DB). Agent chỉ đề xuất thêm, không tự ghi.
- [Module.md](Notes/Module.md): danh sách module theo thành phần, do Anhnt ghi; đọc ở bước Plan để biết module nào đã có (No Duplicate) và module nào bị ảnh hưởng.
- [Update.md](Notes/Update.md): các bản EA/Library cũ; chỉ đọc khi cần tra lại cách làm cũ. Code trong các bản này là Reference-only: không sửa, không coi là chuẩn hiện tại.
