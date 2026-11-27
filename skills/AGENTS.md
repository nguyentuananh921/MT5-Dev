## Rules gate: mục tiêu xuyên suốt
 0. <a id="clear-understand"></a>**Clear Understand**: hiểu rõ Concept, Code, [System](#system), [Project](#project-and-working-area), [Working Area](#project-and-working-area), [Document](#skills-and-document) trước khi làm.
 1. **CleanArchitecture**: Tuân thủ CleanArchitecture dependency rule, tức tầng trong (base class , library)  không được biết tầng ngoài (EA, Manager). 
 2. <a id="dry"></a>**DRY — Don't Repeat Yourself**: trong mọi bước của [Working workflow](#working-workflow), không lặp concept, code, [Document](#skills-and-document) hoặc hỏi lại câu hỏi cũ đã được trả lời gây mất việc.
 3. **Sync Everywhere**: theo [SyncEverywhere.md](Notes/SyncEverywhere.md). 
## System
 Tuân thủ [Rule Gate](#rules-gate-mục-tiêu-xuyên-suốt).
 0. **Kiến trúc:** System được thiết kế Modular Architecture and [Event-Driven](Notes/Event.md) trong đó system là parent gồm nhiều sub-System được mô tả trong [Working Area](#project-and-working-area) là anh em tuân thủ theo [Parent Child](Notes/Event.md#system-concept-parentchild).
 1. **MVC (Model-View-Controller):** Mỗi Sub-System được tổ chức theo mô hình MVC với Model (DB, Entities), Controller (EA, Manager) và View (EA vẽ).
## Project and Working Area
 Các Working Area của [System](#system) và phạm vi sửa được nêu rõ, ngoại lệ ở dưới.
 ### EA Web:
  - `D:\MT5-Dev\Experts\Anhnt\Example EA\4. Combination EA V5\Web\`.  
  - Plan kết hợp với các Sub-System khác để backtest hiện đang chưa làm còn thiếu nhiều chỗ (đừng thắc mắc).
 ### EA Module:
  - <a id="working-area-ea"></a>`D:\MT5-Dev\Experts\Anhnt\Example EA\4. Combination EA V5\`, ngoại trừ `EA Web`.
 ### Python Library:<a id="working-area-python-lib">
  -  `D:\MT5-Dev\Library\Python\`.
 ### Vendor Library:  <a id="working-area-vendor-lib">
  - Chỉ đọc và dùng như dependency; không sửa hay cập nhật thủ công. Khi cần update dùng [`git pull`](Notes/Command.md#pull-all).
  - Khi thêm thư mục vào danh sách này, cần thêm đúng đường dẫn vào `.gitignore`.
   + `D:\MT5-Dev\Library\Kronos\`
   + `D:\MT5-Dev\Library\tradecanvas\`
   + `D:\MT5-Dev\Library\xgboost\`
   + `D:\MT5-Dev\skills\Addon\.claude\skills\`
 ### MT5 Library:<a id="working-area-MT5-lib">
  - Thư mục `D:\MT5-Dev\Library\`
  - Ngoại trừ
   + [`Python\`](#python-library) (thuộc [Python Library](#python-library)) 
   + Các thư mục trong [Vendor Library](#vendor-library)
  - **Base Class** <a id="mt5-library-base-objects"></a> `D:\MT5-Dev\Library\Entities\Bases`
  - **Base Class for Graphic** <a id="mt5-library-base-graphic-objects"></a> `D:\MT5-Dev\Library\Entities\GBases`
  - **Control for GUI** <a id="mt5-library-gui-control-object"></a> ([Easy and Fast GUI](Notes/Concepts.md#easy-and-fast-gui)) `D:\MT5-Dev\Library\Entities\Controls`
  - **Enum and Define** <a id="mt5-library-enum-define"></a> `D:\MT5-Dev\Library\Entities\Defines`
  - **Setting** `D:\MT5-Dev\Library\Entities\Settings`
  - **Manager** manage Setting `D:\MT5-Dev\Library\Collections\Settings`
  - **Working with Chart** `D:\MT5-Dev\Library\Entities\Chart`
  - **Objects** 
   + <a id="mt5-library-objects"></a> 
   + khai báo ở enum ENUM_OBJECT_DE_TYPE trong `D:\MT5-Dev\Library\Entities\Defines\CommonDefines.mqh`
  - **EventDefine** 
   + <a id="mt5-library-eventDefine"></a> 
   + khai báo ở trong `D:\MT5-Dev\Library\Entities\Defines\EventDefines.mqh`
 ### Database: <a id="working-area-database">
  - SQLite runtime của EA V5 tại `<MT5_EA_DATABASE>\`:
  - alias: `<MT5_TERMINAL_DATA>\MQL5\Files\EA V5 SQLLite\Database`
   + `<MT5_TERMINAL_DATA>`: `%APPDATA%\MetaQuotes\Terminal\<terminal-id>`
   + terminal đang dùng: `C:\Users\nguye\AppData\Roaming\MetaQuotes\Terminal\D0E8209F77C8CF37AD8BF550E51FF075`
   + đồng bộ schema, luồng đọc/ghi và các Setting liên quan.
 ### Agent Memory <a id="working-area-agent-mem">
  - Thư mục: `D:\MT5-Dev\skills\memory` tùy ý ghi đọc.
 ### Skills and Document: <a id="working-area-document"></a>
  - `D:\MT5-Dev\skills\`: Dùng làm document ngắn gọn ngoại trừ [`memory\`](#agent-memory) (agent được tự ghi).
  - `skills\` là Parent (concept, luật chung, dẫn đường); mỗi thư mục code có `AGENTS.md` riêng là Child (Avoid Bug, việc chưa làm của chính thư mục đó) theo [Parent Child](Notes/Event.md#system-concept-parentchild). Làm việc với thư mục nào thì đọc `AGENTS.md` của thư mục đó (nếu có) trước khi sửa. Không ghi tay vào `README.md` do `scripts\gen-ai-docs.mjs` sinh.
  - Mọi thay đổi cần trao đổi lại theo [Rule Gate 0 — Clear Understand](#clear-understand).
  - Ghi cập nhật tài liệu và implementation sau khi code hoặc xác nhận kết quả.
 ### Reference-only <a id="working-area-Reference-only"></a>
  - Tất cả thư mục khác trong `D:\MT5-Dev\` không thuộc các phạm vi đã liệt kê bên trên.
  - Chỉ mở khi task cần tham khảo; không chỉnh sửa. 
  - Rất nhiều Reference đã được Implementation vào [System](#system)
## Working workflow
 Make sure to follow [Clear Understand](#clear-understand).
 1. **Communication (trước khi hỏi):**
  - Đọc [1. CommunicationRule.md](rules/1.%20CommunicationRule.md) khi nạp skill, trước câu trả lời đầu tiên.   
 2. **Plan (trong đề xuất):**
  - Trước khi code, xác định [Working Area](#project-and-working-area), [Sub-System](#system) và thay đổi dự kiến trong từng thành phần liên quan.
  - Đưa thiết kế trọn vẹn, không nhỏ giọt từng phần..
 3. **Coding:**
  - Đọc [CodingRule.md](rules/2.%20CodingRule.md); theo [SyncEverywhere.md](Notes/SyncEverywhere.md), triển khai các thay đổi đã chốt ở mọi thành phần liên quan.
 4. **Update documentation:** goal của việc update document là [Rule Gate](#rules-gate-mục-tiêu-xuyên-suốt).
   - Cùng xác định các Document cần cập nhật theo thay đổi và các [Working Area](#project-and-working-area) bị ảnh hưởng, gồm cả [Skills and Document](#skills-and-document). Cập nhật ngắn gọn, dễ hiểu để đạt [Clear Understand](#clear-understand) và tránh lặp theo [DRY — Don't Repeat Yourself](#dry).