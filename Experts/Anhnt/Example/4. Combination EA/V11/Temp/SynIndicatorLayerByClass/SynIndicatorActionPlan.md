# SynIndicator Action Plan

Danh sách việc cụ thể còn phải làm/đã làm, theo Phase. Bổ sung cho `SynIndicatorPlan.md` (tài liệu kiến trúc/tham chiếu) — file này là TODO list + nhật ký sự cố thực thi.

## Phase 1: Điền `type_enum`/`raw_params[]` tại 2 điểm append trực tiếp trong CGUIPannel — XONG (2026-08-19)

Đã thêm vào cả `AddIndicatorToTemplate` (`GUIPannel_TabSettingIndicatorTable.mqh`) và `ScanIndicatorOnChart` (`GUIPannel_TabSettingIndicator.mqh`), ngay sau đoạn điền `.params[]` (text):
```cpp
m_indicator_template_setting[new_row].type_enum = type;
ArrayResize(m_indicator_template_setting[new_row].raw_params, ArraySize(params));
for(int p = 0; p < ArraySize(params); p++)
   m_indicator_template_setting[new_row].raw_params[p] = params[p];
```
Cả 2 chỗ đều có sẵn raw `(type, params)` tại chỗ append, không cần parse gì. Giờ `CTimeSeriesEngine::AddAllIndicatorsToNewSeries` (CHARTCHANGE) sẽ nhân bản đúng cho MỌI template, kể cả template thêm lúc đang chạy (không chỉ template từ JSON lúc startup).

## Sự cố đã xử lý (test thật trên chart, 2026-08-19)

**#1 - Dangling pointer crash `SignalBridgeWriter.mqh` (99,29)`** — CONFIRMED + ĐÃ SỬA.
- Log: xóa 1 template (`RemoveIndicatorFromTemplate`) → Layer 1 hủy object thật (`RemoveIndicatorFromAllSeries`) → tick tiếp theo `CSignalBridgeWriter::TemplateBuySellFor` dereference `m_template_ptrs[row]` (con trỏ CŨ, chưa được refresh) → crash "invalid pointer access".
- Nguyên nhân: `RemoveIndicatorFromTemplate` không gọi `SyncIndicatorTemplateSettingToBridge()` sau khi xóa (khác `OnClickToggleBuySignal`/`OnClickToggleSellSignal` đã gọi).
- Sửa: thêm `SyncIndicatorTemplateSettingToBridge();` vào CẢ `RemoveIndicatorFromTemplate` (bắt buộc, tránh crash) LẪN `AddIndicatorToTemplate`/`ScanIndicatorOnChart` (tránh staleness, buy/sell mặc định không được Bridge nhận ra kịp).

**#2 - Click nút X không xóa được template thêm qua `ScanIndicatorOnChart`** — CONFIRMED + ĐÃ SỬA.
- Log: click tới đúng `OnEvent` (`col=0 row=0`, không bị reject), nhưng không có dòng `RemoveIndicatorFromTemplate` nào xuất hiện, không crash, không log lỗi.
- Nguyên nhân gốc: bản `ScanIndicatorOnChart` trước đó (2026-08-18) cố ý KHÔNG gọi Layer 1 khi phát hiện indicator mới trên Chart - chỉ append vào `m_indicator_template_setting[]`. Hệ quả: row đó KHÔNG CÓ object `CIndicatorDE` nào ở Layer 1 (`m_IndicatorsCollection`) - `GetIndicatorForRow(row)` luôn trả `NULL` cho row này, khiến `OnClickRemoveIndicator`'s `if(ref_indicator == NULL) return;` âm thầm no-op. Cùng lý do khiến cả 5 checkbox (kể cả Show, dù đang hiện thật trên Chart) của row đó luôn hiện trống.
- Sửa: `ScanIndicatorOnChart` giờ gọi `m_time_series_engine.AddNewIndicatorToAllSeries(type, params)` TRƯỚC khi append Data (giống hệt `AddIndicatorToTemplate`) - phục hồi đúng bất biến "Layer 1 luôn đồng bộ đầy đủ với `m_indicator_template_setting[]`".

## Phase 2+: chưa xác định — cần compile + test lại toàn bộ luồng (Add/Remove/Insert-trên-chart/CHARTCHANGE) sau các fix trên trước khi coi là xong.
