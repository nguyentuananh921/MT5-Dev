# CLAUDE.md

## Ngôn ngữ
- Trả lời bằng tiếng Việt, ngắn gọn, đi thẳng vào việc.

## Dự án
- Phát triển EA / Indicator / thư viện bằng MQL5 cho MetaTrader 5.
- Mã nguồn gốc: `D:\MT5-Dev` (Experts, Include, Indicators).
- Thư mục MetaTrader tương ứng: `C:\Users\nguye\AppData\Roaming\MetaQuotes\Terminal\D0E8209F77C8CF37AD8BF550E51FF075\MQL5`.
- Hai nơi này chứa cùng mã nguồn. Trước khi sửa, xác nhận đang sửa đúng bản nào.

## Cấu trúc chính
- `Experts\Anhnt\Example EA\4. Combination EA` (cùng bản V2, V3): EA ví dụ dùng thư viện Combination.
- `Include\Vendors\Anhnt\Library\`: thư viện tự viết
  - `4. Combination Lib V2`, `4. Combination Lib V3`
  - `3. MVC Table`
  - `2. DoEasy\Service functions Lib`
- `Indicators\Vendors\Anhnt\Custom Buildin`: indicator tự viết.
- `Experts\Anhnt\Document\Workspace`: các file `.code-workspace` (thư mục này).

## Quy ước làm việc
- Đọc code xung quanh trước khi sửa, giữ đúng phong cách, tên biến và mật độ comment hiện có.
- Không tự động commit hoặc push. Chỉ làm khi được yêu cầu.
- Không xoá hay ghi đè file khi chưa xem nội dung.
- Khi sửa file `.mqh` dùng chung, kiểm tra các EA và indicator đang include nó có bị ảnh hưởng không.
- Phân biệt rõ Combination Lib V2 và V3, không trộn lẫn.

## Ghi chú
- Mất hội thoại thường do đổi Workspace. Hội thoại cũ nằm ở `C:\Users\nguye\.claude\projects\` theo từng thư mục, dùng `/resume` ở đúng thư mục để mở lại.

## Quy tắc làm việc chi tiết (README)
- Đầu mỗi phiên, đọc `D:\MT5-Dev\Experts\Anhnt\Example EA\4. Combination EA V3\README.md` trước khi làm việc trên EA/Lib V3. Trong đó có Working Rule (Print Debug, đặt tên, Enum, method), cấu trúc EA và ghi chú phiên bản. Không bắt người dùng nhắc lại những gì đã ghi ở đó.
- Khi người dùng nói "ghi vào README" hoặc đưa ra quy tắc mới, cập nhật chính file README này.
