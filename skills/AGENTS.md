## Rules gate: mục tiêu xuyên suốt

 Cả project nằm trong thư mục D:\MT5-Dev. Gồm nhiều thư mục được chia thành các Working Area khác nhau.

 Rules gate là bộ lọc trước mỗi câu hỏi và mỗi đề xuất, áp dụng tại các bước của [Working workflow](#working-workflow), để trao đổi không lặp lại hay luẩn quẩn. Luật trong `rules\` và hướng dẫn trong `Notes\` bổ sung cách thực hiện cụ thể; nếu có mâu thuẫn, ưu tiên Rules gate.

0. <a id="clear-understand"></a>**Clear Understand**: hiểu rõ Concept, Code, Project, Working Area và Document trước khi làm.
 1. **CleanArchitecture**: Tuân thủ CleanArchitecture dependency rule, tức tầng trong không được biết tầng ngoài.
 2. **No Duplicate**: no duplicate in concept, code, document.
 3. **MVC**: đây là Model (DB), Controller (EA, Manager) hay View (EA vẽ)?
   - View chỉ nhận data và hiển thị, không tính, không lọc.
   - EA Web là thành phần riêng trong Working Area.
 4. **Working with Event**: theo [Event.md](Notes/Event.md) và [ParentChild.md](Notes/ParentChild.md).
   - <a id="automation"></a>**Automation:** mỗi **loại object** ([Luồng thêm Event](Notes/Event.md#luồng-thêm-event)) tự làm việc của mình khi nhận Event; không loại object nào hỏi hộ hay làm hộ loại khác.
   - Event sinh ra để Automation: loại object sở hữu thay đổi data tự fire; loại object có việc liên quan tự nghe và tự làm.
   - Automation diễn ra ở mọi loại object trong System, không riêng Strategy hay Trading.
   - Trace thay đổi từ object sở hữu data qua thành phần phát sinh tới các thành phần/listener anh em cần nhận; dùng đúng contract liên thành phần.
   - Trong một Event Bus, object phát hiện thay đổi có ý nghĩa tự fire, parent không relay.
   - Chỉ xử lý khi có thay đổi, không poll.
 5. **Sync Everywhere**: theo [SyncEverywhere.md](Notes/SyncEverywhere.md).
 6. **Conventions**: các luật trong [CodingRule.md](rules/2.%20CodingRule.md).

## System

Current System là một system tự động ([Automation](#automation)) dựa trên [Event](Notes/Event.md#event-note).

- **Kiến trúc:** System là parent; các Sub-System trong [Working Area](#working-area-và-sync-everywhere) là anh em, theo [Parent Child Note](Notes/ParentChild.md#parent-child-note).
  - Các thành phần trao đổi trực tiếp qua contract phù hợp (DB, Event, socket...), không qua một thành phần trung gian; contract theo [CommunicationNote.md](Notes/CommunicationNote.md).
  - Bên trong từng thành phần, “module” là đơn vị tổ chức code.
  - Thay đổi một thành phần thì đồng bộ theo [Sync Everywhere](Notes/SyncEverywhere.md#sync-everywhere).
- **Reference chỉ là mảnh nhỏ:** mỗi EA/Reference thường một strategy, một symbol, không Event.
  - Lấy concept của Reference theo New Concept ([CodingRule.md](rules/2.%20CodingRule.md#implementation-rule)).
  - Phần Reference thiếu cho nhiều Strategy và Automation thì tự thiết kế theo Notes; không hỏi lại "Reference không có".

## Working Area và Sync Everywhere

 Các Working Area của [System](#system) và phạm vi sửa được nêu rõ, ngoại lệ ở dưới.Khi Update sửa một Working Area thì phải đồng bộ với các working area khác nếu có.
 - **EA Web:**
   - `D:\MT5-Dev\Experts\Anhnt\Example EA\4. Combination EA V5\Web\`.
   - Đồng bộ với EA Module, MT5 Library, Python Library và Database.
   - [] Plan kết hợp với các Sub-System khác để backtest.
 - **EA Module:**
  + `D:\MT5-Dev\Experts\Anhnt\Example EA\4. Combination EA V5\`, ngoại trừ `EA Web`.
 - **Python Library:**
  + `D:\MT5-Dev\Library\Python\`; đồng bộ calculation, setting và dữ liệu lưu DB với EA Module, EA Web và MT5 Library.
 - **Vendor Library:**
  + `D:\MT5-Dev\Library\Kronos\`
  + `D:\MT5-Dev\Library\tradecanvas\`
  + `D:\MT5-Dev\Library\xgboost\`
  - Được đọc và dùng như dependency; không sửa hay cập nhật thủ công. Khi cần cập nhật vendor, chỉ dùng [`git pull`](Notes/Command.md#pull-all).
 - Khi thêm thư mục vào danh sách này, đồng thời thêm đúng đường dẫn vào `.gitignore` để quy tắc áp dụng cho mọi người.
 - **MT5 Library:**
  + `D:\MT5-Dev\Library\`, ngoại trừ `Python\` (thuộc Python Library) và các thư mục trong `D:\MT5-Dev\Library\Kronos\`, `tradecanvas\`, `xgboost\`; phần MQL5 Library.

 - **Database:** SQLite runtime của EA V5 tại `<MT5_EA_DATABASE>\`:
  + alias: `<MT5_TERMINAL_DATA>\MQL5\Files\EA V5 SQLLite\Database`
  + `<MT5_TERMINAL_DATA>`: `%APPDATA%\MetaQuotes\Terminal\<terminal-id>`
  + terminal đang dùng: `C:\Users\nguye\AppData\Roaming\MetaQuotes\Terminal\D0E8209F77C8CF37AD8BF550E51FF075`
  + đồng bộ schema, luồng đọc/ghi và các Setting liên quan.
 - **Skills:** 
  - `D:\MT5-Dev\skills\`: Dùng làm document ngắn gọn.
  - Mọi thay đổi phải hỏi lại Anhnt trước khi sửa, ngoại trừ `memory\` (agent được tự ghi).
  - Ghi cập nhật tài liệu và implementation sau khi code hoặc xác nhận kết quả.

## Reference-only

 - Tất cả thư mục khác trong `D:\MT5-Dev\` không thuộc các phạm vi đã liệt kê bên trên.
 - Chỉ mở khi task cần tham khảo; không chỉnh sửa.
 - Code ở đây là mảnh nhỏ so với System: cách dùng theo [System](#system).

## Working workflow

 1. **Communication (trước khi hỏi):**
   - Đọc [1. CommunicationRule.md](rules/1.%20CommunicationRule.md) khi nạp skill, trước câu trả lời đầu tiên.
 2. **Plan (trong đề xuất):**
   - Trước khi code, xác định Working Area, Sub-System và thay đổi dự kiến ở từng thành phần.
 3. **Coding:**
   - Đọc [CodingRule.md](rules/2.%20CodingRule.md); theo [SyncEverywhere.md](Notes/SyncEverywhere.md), triển khai các thay đổi đã chốt ở mọi thành phần liên quan.
 4. **Update documentation:**
    - Ghi kết luận đã chốt và căn cứ (Note, code) ngay khi phát hiện mâu thuẫn và khi implementation kết thúc; không ghi trong quá trình chưa chốt, không chép hội thoại hoặc lịch sử.
    - [Clear Understand](#clear-understand) là gate trước khi hành động; bước này là nơi lưu kết quả hiểu biết và quyết định để đồng bộ mọi Working Area.
    - Chi tiết implementation ghi trong code (header class, comment member) theo [CodingRule.md](rules/2.%20CodingRule.md#comment).
    - Note chỉ giữ concept, điểm đã chốt, việc chưa làm và link tới code; sửa Note tuân thủ Workspace access policy.

## References

 - [WorkingOnRamSaveToDB.md](Notes/WorkingOnRamSaveToDB.md): nguyên tắc RAM/DB; đọc khi làm việc với data, DB, Manager, Collection hoặc Python.
 - [ParentChild.md](Notes/ParentChild.md): quan hệ parent–child/composition; đọc khi làm việc với object cha–con.
 - [Event.md](Notes/Event.md): Event và cơ chế Event Bus; đọc khi đề xuất, viết hoặc review event.
 - [SyncEverywhere.md](Notes/SyncEverywhere.md): rà soát tác động chéo và đồng bộ thay đổi; đọc khi thêm class/feature hoặc thay đổi contract dùng chung.
 - [Concepts.md](Notes/Concepts.md): concept Strategy và RiskManagement; đọc khi làm việc với strategy, signal hoặc Bar information.
 - [IndicatorConcept.md](Notes/IndicatorConcept.md): Indicator, Indicator on Indicator và Base Indicator Strategy; đọc khi làm việc với source/applied hoặc role của indicator.
 - [CommunicationNote.md](Notes/CommunicationNote.md): contract giao tiếp giữa các Working Area; đọc khi làm việc với TCP, HTTP API, WebSocket, File hoặc Database.
 - [README.md](../Experts/Anhnt/Example%20EA/4.%20Combination%20EA%20V5/Web/README.md): hướng dẫn hiện có của EA Web.
 - [README.md](../Library/Kronos/README.md): cách dùng vendor Kronos (Read-only).
 - [2. CodingRule.md](rules/2.%20CodingRule.md) và [1. CommunicationRule.md](rules/1.%20CommunicationRule.md): coding và trao đổi.
 - [Command.md](Notes/Command.md): các command Anhnt cần nhớ theo thành phần; đọc khi cần chạy lệnh (build, pull vendor, git, DB). Agent chỉ đề xuất thêm, không tự ghi.
 - [Module.md](Notes/Module.md): danh sách module theo thành phần, do Anhnt ghi; đọc ở bước Plan để biết module nào đã có (No Duplicate) và module nào bị ảnh hưởng.
 - [Update.md](Notes/Update.md): các bản EA/Library cũ; chỉ đọc khi cần tra lại cách làm cũ. Code trong các bản này là Reference-only: không sửa, không coi là chuẩn hiện tại.
