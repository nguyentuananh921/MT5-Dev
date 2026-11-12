# Bug: Nháy cả 2 cửa sổ + dropdown đè sai z-order khi Add TF

**Ngày phát hiện:** 2026-09-09
**Trạng thái:** Đã tìm ra nguyên nhân gốc, CHƯA fix - đang chờ quyết định thiết kế.

## Triệu chứng

1. Mỗi lần thêm 1 TF mới để track (ở tab Symbol TF của Setting Time Series), **cả 2 cửa sổ** (`m_window_main` và `m_window_setting_timeseries`) đều nháy.
2. Khi thao tác dạng này lặp lại, thấy hiện tượng z-order sai: dropdown/list (VD danh sách Symbol khi mở TreeView) bị vẽ **đè lên trên** control ở cửa sổ khác đáng lẽ phải nằm trên nó (ảnh minh hoạ: dropdown Symbol TreeView đè lên nút "Sell"/khu vực New Order form).

## Nguyên nhân gốc (đã xác nhận qua đọc code)

Mỗi khi có 1 TF mới được Add (event `SYMBOLTF_MANAGER_EVENT_ADDED`) hoặc click vào 1 TF đã track trong TreeView (event `SYMBOLTF_MANAGER_EVENT_SETTING_CHANGED`), `EA Using Combination Lib V10.mq5::OnChartEvent` đều gọi:

```cpp
void SetActiveChartSymbolTF(const string sym, const ENUM_TIMEFRAMES tf)
 {
  ...
  ::ChartSetSymbolPeriod(chart.ID(), sym, tf);   // EA Using Combination Lib V10.mq5:236
 }
```

`::ChartSetSymbolPeriod()` là API **native của MT5** - đổi Symbol/TF của 1 chart khiến MT5 **reload lại toàn bộ chart** (nạp lại dữ liệu giá, vẽ lại nến). Toàn bộ panel GUI của EA được vẽ dưới dạng chart object gắn trên chính chart đó, nên native reload này:
- Gây nháy toàn bộ panel (không phải bug ở code GUI của mình - đây là hành vi gốc của MT5 khi đổi Symbol/TF trên chart, không GUI library nào tránh được hoàn toàn).
- Rất có thể làm gián đoạn cơ chế z-order của Kazharski Lib (`CWndEvents::SetZorders()`/`ResetZorders()`, xem `WndEvents.mqh:OnOpenDialogBox`) - vì việc reload chart nằm ngoài luồng event bình thường mà Library dùng để duy trì z-order, nên sau khi reload, thứ tự vẽ có thể bị sai lệch.

## Call site cụ thể

- `SYMBOLTF_MANAGER_EVENT_ADDED` → `EA Using Combination Lib V10.mq5:186-191` → `SetActiveChartSymbolTF(entry.Symbol(), entry.TFEnum())`
- `SYMBOLTF_MANAGER_EVENT_SETTING_CHANGED` → `EA Using Combination Lib V10.mq5:193-200` → `SetActiveChartSymbolTF(parts[1], new_tf)`
- Cả 2 đều bắt nguồn từ `GUIPannel_SettingWindows_TimeSeries.mqh` (dòng ~242-254 cho case đổi TF/Symbol từ chính chart, dòng ~256-287 cho case click TreeView) gọi `m_SymbolTFManager.Add_SymbolTFSetting(...)`/`NotifySettingChanged(...)`, rồi Manager tự bắn event, EA lắng nghe và gọi `SetActiveChartSymbolTF`.

## Câu hỏi thiết kế còn mở (chưa quyết)

Mỗi lần Add 1 TF mới, EA có **thực sự cần** tự động nhảy chart sang đúng Symbol+TF đó không, hay chỉ cần âm thầm track ở nền (thêm vào danh sách quản lý) mà không đụng vào chart đang xem?

- Nếu **giữ auto-switch**: chấp nhận nháy (vì là hành vi gốc MT5, không sửa được triệt để), đổi lại được tự động nhảy tới xem ngay TF vừa thêm.
- Nếu **bỏ auto-switch**: hết nháy hẳn, nhưng user phải tự chuyển tab/chart thủ công sau khi Add.

**Chưa quyết định - Anhnt cần chọn hướng trước khi code.**
