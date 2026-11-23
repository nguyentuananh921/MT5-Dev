# Parent Child Note

- Ở cấp kiến trúc, System là parent của các thành phần như EA Module, EA Web, Library, Library\Python, Database và Skills; các thành phần này là anh em, trao đổi trực tiếp qua contract phù hợp (DB, Event, socket...), không cần parent relay.
- Bên trong một thành phần, Parent là object chứa và quản lý các object con. Child là object instance được parent giữ làm member và quản lý vòng đời.
- Ví dụ: `CGUIPannel` là parent của `m_label_PositionBuy`, `m_label_PositionSell` nếu chúng là các object label mà panel chứa/quản lý. Nếu member chỉ là giá trị như `int` hay `string` thì đó là property, không phải child object.
- Parent–Child là quan hệ composition, không phải kế thừa class. Ở cấp object, nó mô tả cấu trúc sở hữu; tự nó không quyết định object nào fire hay nghe event.
- Event là gì: [Event.md](Event.md).
- Object phát hiện một thay đổi có ý nghĩa sẽ phát event lên Event Bus.
- Event Bus gửi event tới các listener đã đăng ký. Child, anh chị em, parent hoặc chú đều có thể tự nghe và xử lý phần của mình; parent không cần nhận rồi relay event.
- Các listener xử lý theo event, không lặp lại việc hỏi “có gì mới chưa?” trong OnTick/OnTimer. Chỉ nơi tiếp nhận dữ liệu terminal không có event sẵn mới đọc dữ liệu tại callback cần thiết rồi phát event.

