# Parent Child Note

- Ở cấp kiến trúc, [System](../AGENTS.md#system) chứa các [Working Area](../AGENTS.md#working-area-và-sync-everywhere); các Working Area là anh em, trao đổi trực tiếp theo [CommunicationNote.md](CommunicationNote.md).
- Trong một Sub-System, Parent là object chứa và quản lý Child. Child là object instance được Parent giữ làm member và quản lý vòng đời.
- Ví dụ: `CGUIPannel` là Parent của `m_label_PositionBuy`, `m_label_PositionSell` nếu chúng là object label mà panel chứa và quản lý. Member là `int` hoặc `string` là property, không phải Child object.
- Parent–Child là quan hệ composition, không phải kế thừa class.

## Working on Event

- Parent–Child mô tả cấu trúc sở hữu, không thay thế quy trình Event.
- Các loại object trong System, gồm Parent, Child và object độc lập, thuộc cùng mô hình [Working with Event](Event.md#working-with-event).
- Object sở hữu dữ liệu, không phụ thuộc vị trí Parent/Child, tự fire Event khi state thay đổi; listener liên quan tự xử lý; Parent không relay.
- Thiết kế và contract Event, gồm Event ID, payload, owner, sender, listener và dispatch, nằm trong [Event.md](Event.md); Note này chỉ xác định quan hệ composition.

