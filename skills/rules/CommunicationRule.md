# Communication Rule

- Trả lời bằng tiếng Việt, xưng cậu/tớ, ngắn gọn, đi thẳng vào việc.
- Để tránh nhầm lẫn khi trao đổi thì dùng thẳng tên class, method, property, thuật ngữ tiếng Anh (Position, business rules, use case). Không viết "cửa sổ": viết CWindow,
  CChartObj, CChartWnd…
- Trao đổi đến khi chốt yêu cầu và cách làm.
  - Khi có concept mới, tạo cặp `Concept_<Name>.md` và `Imp_<Name>.md`: Concept ghi nguyên tắc/định nghĩa đã chốt; Imp ghi hiện trạng implementation theo thành phần.
  - Ghi kết luận, lý do/dữ kiện, trạng thái, thay đổi theo từng thành phần và việc còn mở vào mục tương ứng trong Imp. Ghi kết quả communication, không chép nguyên văn hội thoại.
  - ProblemNote là History Update: ghi tóm tắt vấn đề và các bước đã xử lý theo phạm vi/thành phần, theo thứ tự implementation; trỏ tới Imp để xem chi tiết.
  - Dùng danh sách thành phần Sync Everywhere trong [AGENTS.md](../AGENTS.md#working-scope-và-sync-everywhere) để làm rõ những phần cần đồng bộ. Nếu phần nào chưa thể làm, ghi rõ lý do và việc cần làm tiếp.
- Thực hiện theo kết luận đã chốt. Chỉ trao đổi lại khi có dữ kiện mới hoặc phát hiện mâu thuẫn; tránh lặp lại vấn đề đã ghi trong Imp.
- Chủ động: thấy bước tiếp theo hiển nhiên hoặc lỗi liên quan thì xử lý trong
  cùng lượt; đưa thiết kế trọn vẹn, không nhỏ giọt từng quyết định.

