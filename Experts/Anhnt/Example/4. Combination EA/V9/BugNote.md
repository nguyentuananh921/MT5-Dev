# Combination EA V9 — BugNote: hồ sơ vụ án & luật rút ra

> Archive hồ sơ bug (root cause + bằng chứng log). Sổ chính/checklist: README.md.
> Quy ước chung: hội thoại tiếng Việt, comment trong code tiếng Anh.

## 1. VẤN ĐỀ ĐANG MỞ (trao đổi tiếp)

### 1a. Indicator tự "mọc lại" trên chart sau khi xoá hết Template (⚠ ĐANG ĐIỀU TRA, 2026-08-20)

**Triệu chứng**: Xoá dần từng indicator trong `m_table_indicator_template` cho tới khi
`m_indicator_template_setting[]` về 0 (bảng trắng trơn, đúng) — nhưng vài giây sau, TỰ NHIÊN
xuất hiện 1 native indicator MỚI trên chart (handle khác hẳn handle cũ), kéo theo
`ScanIndicatorOnChart` coi nó là "thêm tay" và nhận nuôi lại vào Data. User không hề bấm gì.

**Bằng chứng log (chart BTCUSDm, 2026-08-20 16:48)**:
```
16:48:25.601  native=1 tracked=2 change=-1        (đúng, vừa xoá AMA, còn lại 'MA' duy nhất)
16:48:31.521  native=2 tracked=1 change=1          ← TỰ NHIÊN TĂNG, không ai bấm gì cả!
16:48:31.521  sending IND_ADD for name='MA(14)' handle=29   ← native MA MỚI xuất hiện, handle khác
16:48:31.522  ScanIndicatorOnChart: MA already exists - skip
```
Gap ~6 giây, không có click nào ở giữa. Handle=29 là handle MỚI (không trùng handle MA cũ đã bị xoá).

**Đã làm / đã loại trừ**:
- Thêm debug Print vào `CChartWnd::Refresh()` (Chart\ChartWnd.mqh, Library — tạm thời, dễ xoá)
  in `chart_id`/`sym`/`per`/`win`/`native`/`tracked`/`change` mỗi lần chạy — xác nhận log trên
  là thật, không phải nhầm lẫn giữa nhiều chart (M1/M5/M15/BTCUSDm chạy song song).
- Thêm debug Print vào cả 3 chỗ EA tự gọi `ChartIndicatorAdd` (Show toggle
  `OnClickToggleShowIndicatorOnChart`, `OnClickAddIndicatorBtn`, `SynIndicatorOnChart` CHANGE
  branch) — **CHƯA có log mới xác nhận** chỗ nào trong 3 chỗ này (nếu có) đã fire đúng lúc
  16:48:31. Cần test lại và xem log.
- Đã xác nhận `ScanIndicatorOnChart` chỉ REACT (không phải nguyên nhân) — nó không tự gọi
  `ChartIndicatorAdd`/`IndicatorCreate` gì cả, chỉ đọc `CWndInd` đã có sẵn trên chart.
- Đã đọc kỹ `CChartObj`/`CChartWnd`/`CWndInd`/`CChartObjCollection` — không tìm thấy cơ chế nội
  bộ Library nào tự động "hồi sinh" 1 indicator đã xoá.

**Nghi vấn còn treo**: `GetLastChangedIndicator()`/`GetLastDeletedIndicator()` (cả ở
`CChartObjCollection` lẫn `CChartObj`) dùng chung 1 list GLOBAL, KHÔNG lọc theo `chart_id` —
khi chạy nhiều chart cùng lúc, sự kiện CHANGE/DELETE ở chart A có thể lọt sang xử lý ở chart B.
Chưa xác nhận đây có phải nguyên nhân trực tiếp của case 1a hay không.

**Bước tiếp theo**: test lại với đủ 4 điểm debug Print đang có, xem log tại đúng thời điểm
indicator tự mọc — xác định print nào (nếu có) fire, hoặc xác nhận việc này KHÔNG đến từ code
EA (khả năng MT5 tự làm gì đó, hoặc script/indicator khác trên chart).
