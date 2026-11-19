# Concept Working on RAM, save to DB

Database là nơi các thành phần trong [Working scope và Sync Everywhere](../AGENTS.md#working-scope-và-sync-everywhere) lưu và chia sẻ dữ liệu: một thành phần ghi, các thành phần liên quan đọc.

## Dữ liệu lưu trong DB

DB là Single Source of Truth cho:

- Setting.
- Dữ liệu MT5 có thể cung cấp khi sự kiện xảy ra nhưng không được giữ trong history hoặc không còn khôi phục được sau khi Position/terminal đóng.
- Kết quả tính toán tốn công tạo lại.

## Cách các module sử dụng dữ liệu

- OnInit, mỗi thành phần đọc dữ liệu cần dùng từ DB lên RAM.
- Dữ liệu MT5 có sẵn được từng thành phần tự đọc lên RAM và join với dữ liệu từ DB khi cần.
- Dữ liệu còn đọc được từ MT5 thì lấy từ đó; dữ liệu cần cho việc sau này nhưng MT5 không giữ lại thì phải lưu khi còn có thể đọc được.
- Thay đổi cần được giữ hoặc chia sẻ thì lưu xuống DB.
- Quan hệ sở hữu object trong mỗi module theo [Concept_ParentChild.md](Concept_ParentChild.md); object phát hiện thay đổi có ý nghĩa thì fire Event cho listener liên quan theo [Concept_Event.md](Concept_Event.md).
