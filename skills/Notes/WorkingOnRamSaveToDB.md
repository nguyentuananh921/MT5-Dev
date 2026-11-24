# Working on RAM, save to DB Note

Database là nơi các Sub-System trong [Working Area và Sync Everywhere](../AGENTS.md#working-area-và-sync-everywhere) lưu và chia sẻ dữ liệu: một thành phần ghi, các thành phần liên quan đọc.

## Save to DB Rule

DB là Single Source of Truth cho:

- Setting cần được giữ hoặc chia sẻ.
- Dữ liệu MT5 có thể cung cấp khi sự kiện xảy ra nhưng không được giữ trong history hoặc không còn khôi phục được sau khi Position/terminal đóng.
- Kết quả tính toán tốn công tạo lại.
- Setting và kết quả tính toán quyết định của Strategy, theo mô hình trong [Concepts.md](Concepts.md).
- Việc ghi lớn sẽ do **Python Library:** ghi, việc nhỏ do các [Working Area và Sync Everywhere](../AGENTS.

## Working On RAM rule

- OnInit, mỗi thành phần đọc dữ liệu cần dùng từ DB lên RAM (Setting, kết quả).
  - Sau đó các object liên quan làm việc trên RAM, không đọc lại DB.
- Dữ liệu MT5 có sẵn được từng thành phần tự đọc lên RAM và join với dữ liệu từ DB khi cần.
- Chỉ khi có thay đổi mới ghi xuống DB:
  - Object sở hữu data đổi giá trị trên RAM rồi fire [Event](Event.md); listener trong EA biết qua Event.
  - Thành phần sở hữu table (một người ghi) nghe Event đó và ghi DB, để [các thành phần](../AGENTS.md#working-scope-và-sync-everywhere) ngoài EA (Python, Web) biết qua DB.
- Ví dụ: `CRiskSetting::SetValue` đổi RAM và fire `RISK_SETTING_EVENT_CHANGED`; `CTradingControl` (chủ của `Setting_Risk`) nghe và ghi DB.
  - [v] Nhánh ghi DB này đã có: `CTradingControl::UpdateRiskSettingToDB`; mục "Sửa Setting_Risk" trong [Concepts.md](Concepts.md#việc-chưa-làm).
