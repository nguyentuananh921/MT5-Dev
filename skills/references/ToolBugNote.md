# Tool Bug Note

- Một số `.mqh` là UTF-16LE (ví dụ file DoEasy). Đọc/sửa bằng PowerShell `-Encoding Unicode`; `git diff` hiện "Bin".
- Grep trên cả gốc `MQL5\` có thể trả về rỗng sai. Grep trong thư mục con cụ thể; không search cả ổ, lần theo `#include`.
- Grep đôi khi hiện `//` thành `\`. Khi Edit báo "not found" trên dòng comment, kiểm tra byte bằng `sed -n 'Np' file | cat -A`.
- VS Code tô màu `.mqh` theo grammar C++: không đặt toán tử ba ngôi giữa hai string, không truyền `":"` làm một tham số riêng của `Print`. Ghép string trước rồi mới in.
