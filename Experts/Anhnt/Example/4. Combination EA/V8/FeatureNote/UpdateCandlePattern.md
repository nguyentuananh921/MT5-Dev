# Update Candle Pattern - Performance (Historical Backfill vs New Bar)

**Date:** 2026-08-10
**Status:** Việc 2 done, Việc 1 pending

## 2 việc cần phân biệt

1. **Update dữ liệu quá khứ (historical backfill)** — có thể chia nhỏ, làm dần trong OnTimer, không cần gấp.
2. **Update khi có New Bar** — cần làm ngay, làm sớm, để có dữ liệu quyết định Trading kịp thời.

## Đã sửa (3 chỗ)

1. **`BarPatternsControl.mqh`** — thêm method mới `UpdateAll(const int n_bars = 4)`:
   loop `m_list_controls`, gọi `obj.UpdatePatternList(n_bars)` (rẻ - chỉ quét `n_bars` nến gần nhất) thay vì `CreateAndRefreshPatternList()` (nặng - quét toàn bộ lịch sử).
2. **`BarSeriesDE.mqh:428-429`** — đổi `this.m_patterns_control.RefreshAll()` → `this.m_patterns_control.UpdateAll()`. Dòng gọi này nằm trong nhánh `IsNewBarManual()` — tức mỗi khi 1 series có nến mới đóng.
3. **`TimeSeriesEngine_CandlePattern.mqh` (`SeriesApplyPatternRegistry`)** — xóa dòng `ctrl.RefreshAll();` thừa ở cuối hàm. `SetUsedPattern()` (vòng lặp phía trên) đã tự chạy `CreateAndRefreshPatternList()` cho từng control MỚI TẠO rồi (`BarPatternsControl.mqh` dòng ~340-341) — `RefreshAll()` sau đó là quét trùng lần 2, gây double cost.

## Trạng thái sau khi sửa

### Việc 2 (New Bar) — ĐÃ XONG, không cần gọi thêm gì
`UpdateAll()` được gọi tự động trong `BarSeriesDE.mqh`'s new-bar handler, cho **mọi series** có `m_patterns_control` (tức mọi Symbol+TF đã đăng ký pattern registry — nhờ fix riêng ở `SeriesApplyPatternRegistry`/`TimeSeriesEngine_JSONConfig.mqh`/`TimeSeriesEngine_Lifecycle.mqh` trước đó). Không cần thêm call site.

### Việc 1 (Historical backfill) — CHƯA dùng `UpdateAll()`/`UpdatePatternList()`
Vẫn đi qua đường cũ: `SetUsedPattern()` (bên trong `SeriesApplyPatternRegistry()`) tự chạy full-scan `CreateAndRefreshPatternList()` (quét TOÀN BỘ lịch sử, 28 loại pattern), đồng bộ, tại:
- `OnInitEvent` (1 series - TF của chart lúc khởi động) — nhẹ, OK
- `LoadConfigurationFromJSON` loop (N series - mọi Symbol+TF khác trong Config_Setting.json) — **đây là chỗ nặng nhất**, đã gây "abnormal termination" lúc attach EA trước khi bỏ redundant RefreshAll()
- `OnChartEvent` (1 series - TF vừa đổi trên chart) — nhẹ, OK

**Lưu ý:** `UpdatePatternList(n_bars)` KHÔNG thể thay thế trực tiếp cho full backfill (nó chỉ quét `n_bars` nến gần nhất, mặc định 4) — muốn dùng để "chia nhỏ" backfill thì phải gọi LẶP LẠI nhiều lần qua nhiều tick `OnTimerEvent`, mỗi lần 1 phần nhỏ, và **cần track tiến độ backfill tới đâu** cho từng series (queue + progress marker) — không tránh được việc thêm 1 chút state mới cho việc này (đã thống nhất với user).

## Việc chưa làm / cần quyết định tiếp

- [ ] Thiết kế queue (symbol+tf pending list) + progress tracking cho backfill rải qua `OnTimerEvent`
- [ ] Xác định N series trong JSON-load loop có thực sự đủ nặng để cần chia nhỏ không (test thực tế sau khi đã xóa redundant RefreshAll - có thể đã đủ nhanh)

## Liên quan nhưng KHÁC chủ đề (đang tạm gác)

**`DetectCandlePatternLive.md`** — về độ CHÍNH XÁC của live bar-0 detection (`CGUIPannel::CheckCandlePatternAlerts`/`DetectPatternOnBar0`), không phải performance. Phát hiện phụ trong lúc điều tra: `CGUIPannel::m_BarPatterns_Control` được wire vào `CTimeSeriesEngine::m_BarPatterns_Control` (registry TEMPLATE cấp Engine, dùng để seed pattern registry cho series mới), KHÔNG PHẢI per-series control thật (`bar_series.GetPatternsCtrlObj()`) — nghi vấn đây là lý do `DetectPatternOnBar0()` không bao giờ tìm thấy match, khiến live pattern alert không bao giờ fire. Chưa xử lý, quay lại sau.
