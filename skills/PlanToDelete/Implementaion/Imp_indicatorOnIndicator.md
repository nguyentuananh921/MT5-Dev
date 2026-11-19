# Imp_indicatorOnIndicator

Concept: [Concept_IndicatorOnIndicator.md](../concept/Concept_IndicatorOnIndicator.md).

## EA Module

- [v] **Đã có cấu trúc tính một indicator trên indicator khác.** Close -> RSI 14 -> MA 9 có thể lưu bằng template `9,0,EMA,RSI(14,CLOSE)`.
- [v] **Đã làm trên chart và panel:** nguồn và indicator đọc nó nằm cùng subwindow; trên panel nhóm template có nguồn ngay dưới nguồn.
- [v] **Đã làm vòng đời nguồn:** gỡ nguồn khỏi chart thì gỡ luôn các indicator đọc nó.
- [v] **Đã chốt FRAMA không nhận nguồn:** MT5 trả `-nan` vì FRAMA cần high/low.
- [v] **Đã bỏ `MigrateVolumesAverage`:** ngày 2026-11-16, DB không còn template Volumes V4.
- [v] **Đã chạy parity trên terminal:** `Test\Indicator Parity OnIndicator.mq5`.

## Library

- [v] **Đã có source trong `params` của template:** không thêm type mới vào [Standard Indicator](#standard-indicator); tên hiển thị tự sinh bằng `DisplayLabel`.
- [v] **Đã làm handle source trên MT5:** `CIndicatorDE::SetSource` gắn `applied` với handle của nguồn.
- [v] **Đã làm chọn, phân nhóm và gỡ nguồn:** `CIndicatorTemplateManager` (`SplitParams`, `SourceOf`, `SourceText`, `TakesSource`, `Group`), `CIndicatorsCollection` (`DeleteUnusedSources`) và `CChartObj`.
- [v] **Đã làm signal trên đường trung bình của nguồn:** `CSignalSourceMA` / `CSignalJudge::Price`.

## Library\Python

- [v] **Đã có tính indicator trên nguồn:** `indicators.py` (`split_params`, `source_of`, `compute`, `valid_applied`). `compute` tính source trên mọi nến, rồi tính indicator từ nến đầu tiên source có giá trị; source là buffer cuối.
- [v] **Đã có signal trên nguồn:** `signals.source_ma`; các đường trung bình (MA, AMA, DEMA, TEMA, VIDYA) dùng luật này, loại indicator khác giữ luật riêng.
- [v] **Đã đo khớp MT5:** kết quả MA trên nguồn khớp 1e-10.
- [v] **Đã loại FRAMA khỏi moving average nhận nguồn.**

## EA V5\Web

- [v] **Đã đo khả năng standard indicator trên nguồn bằng TradeCanvas:** xem [WebModule.md](../references/WebModule.md).
- [v] **Đã có hướng hiển thị MA trên nguồn trong standard indicator.**

## Database

- [v] **Standard Indicator:** định nghĩa loại indicator được lưu trong bảng `indicators`; Indicator on Indicator không tạo loại mới.
- [v] **Indicator instance/template:** cấu hình cụ thể, trong đó source nằm trong `params` của `Setting_IndicatorTemplate`; không thêm table riêng.

## Việc chưa làm

- [] **Hai tầng trở lên:** nguồn có thể là MA trên indicator nguồn, ví dụ Close -> RSI 14 -> MA 9 -> MA 5. Python đã có đệ quy, chưa đo; EA chưa cho chọn MA 9 làm nguồn vì form chỉ nhận line 0 của subwindow.
  - Library: `CChartObj::SourceWindow`.
- [] **Nguồn là buffer khác 0:** ví dụ MA trên đường signal của MACD. Hiện chỉ lấy buffer 0.
  - Library: bổ sung cách ghi buffer vào `SourceText` / `SourceOf`; `CIndicatorDE::SetSource(source, buffer)` đã nhận buffer.
  - Library\Python: `applied_price` hiện lấy buffer 0.
  - EA V5: form chưa cho chọn buffer.
- [] **Nguồn nằm trên cửa sổ giá:** ví dụ MA trên AMA vẽ trên nến. Hiện nguồn chỉ tìm trong subwindow.
  - Library: `CChartObj::SourceWindow`; cần hỗ trợ `IsOverlay`.
  - EA V5: form chưa lấy template overlay làm nguồn.
