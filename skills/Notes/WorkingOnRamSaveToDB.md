# Working on RAM, save to DB Note

## Database role

Database là một Working Area của System, được dùng làm **Single Source of Truth (SoT)** cho dữ liệu cần lưu bền vững hoặc chia sẻ giữa các [Working Area](../AGENTS.md#working-area-và-sync-everywhere) và plan để dùng [XGBoost (Vendor Library)](../AGENTS.md#working-area-và-sync-everywhere). Quy tắc về phạm vi và đồng bộ xem [Working Area và Sync Everywhere](../AGENTS.md#working-area-và-sync-everywhere) và [Sync Everywhere](SyncEverywhere.md).
 - Mỗi table có một Working Area/component sở hữu việc ghi; các thành phần liên quan đọc theo contract.
 - Khi dữ liệu, schema hoặc ý nghĩa của dữ liệu thay đổi, đồng bộ các luồng đọc/ghi, setting và Working Area bị ảnh hưởng. Chưa đồng bộ xong thì chưa coi thay đổi là hoàn tất.

## Save to DB Rule

Lưu vào DB những dữ liệu cần giữ hoặc chia sẻ, gồm:

- Dữ liệu MT5 chỉ lấy được khi sự kiện xảy ra, không có trong history hoặc không thể khôi phục sau khi Position/terminal đóng.
- Setting dùng chung giữa các [Working Area và Sync Everywhere](../AGENTS.md#working-area-và-sync-everywhere). 
- **Python Library** thực hiện các công việc khối lượng lớn. 
 + Tính các kết quả của Strategy theo mô hình trong [Concepts.md](Concepts.md) dựa theo các setting.
 + Xóa các tính toán cũ khi thay đổi Setting.
- **MT5 Library:** thực hiện việc Create các table, và ghi các số liệu nhỏ.
 + Các Setting Manager trong `D:\MT5-Dev\Library\Collections\Settings` sẽ create các table tương ứng trong Oninit nếu chưa có và update thay đổi trong Runtime và thông báo cho listener liên quan qua [Event](Event.md)
 + CAccountsCollection là collection riêng, tự tạo/quản lý table accounts, update nó khi MT5 login bằng account mới.
 + CTradingControl sẽ create các table trong OnInitEvent và cập nhật khi có thay đổi.
  * Setting_Risk: tab Risk Management ghi DB ngay; 
  * Tab Trading TAB_TAB_MAIN_TRADING trong CGUIPannel làm việc trên RAM, ghi khi EA OnDeinit (`CRiskSetting::SetValue` `save_now`).
  * TradingOrderDetail: Lưu lại Life-Cycle của một Position từ lúc deal đến lúc trở thành history kèm các Action tương ứng, ghi rõ các action đó được thực hiện bởi strategy nào.
 + Mọi công việc ghi đọc đều thông qua các control ở trên rồi thông qua CDatabaseService trong `D:\MT5-Dev\Library\Services\DELib`

## Working on RAM Rule

- Khi khởi tạo, mỗi thành phần đọc từ DB những dữ liệu cần dùng, như Setting và kết quả đã lưu. Sau đó các object liên quan làm việc trên RAM, không đọc DB lặp lại trong luồng runtime.
- Dữ liệu MT5 hiện có được thành phần liên quan tự đọc lên RAM và kết hợp với dữ liệu từ DB khi cần.
- Chỉ ghi DB khi có thay đổi có ý nghĩa:
  - Object sở hữu dữ liệu cập nhật state trên RAM rồi fire [Event](Event.md); listener trong EA xử lý theo contract.
  - Component sở hữu table nghe Event liên quan và ghi DB. Các Working Area ngoài EA, như Python Library và EA Web, đọc dữ liệu đã đồng bộ qua DB.
- Event thông báo thay đổi trong runtime, không thay thế DB làm SoT. Không polling DB để dò thay đổi; xử lý theo Event và contract của từng Working Area.

Ví dụ: `CRiskSetting::SetValue` đổi RAM và fire `RISK_SETTING_EVENT_CHANGED`; `CTradingControl`, component sở hữu `Setting_Risk`, nghe Event và ghi DB qua `CTradingControl::UpdateRiskSettingToDB`. Xem mục "Sửa Setting_Risk" trong [Concepts.md](Concepts.md#việc-chưa-làm).
