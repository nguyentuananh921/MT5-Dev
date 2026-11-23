# Indicator on Indicator Note

## Nguyên tắc chung

- **Standard Indicator:** tính giá trị indicator từ dữ liệu thị trường được chọn làm đầu vào, ví dụ `Close`.
- **Source Indicator:** Standard Indicator cung cấp buffer/value làm đầu vào cho Standard Indicator khác.
- **Indicator on Indicator:** dùng cùng một phương pháp tính của Standard Indicator, nhưng đầu vào `applied` là buffer/value của Source Indicator.
- **Điểm khác:** chỉ thay nguồn đầu vào; không tạo thuật toán hay loại indicator mới. Output là buffer của Standard Indicator đang tính, không phải buffer của Source Indicator.

Ví dụ: MA trên RSI vẫn là MA; các giá trị RSI được dùng làm đầu vào thay vì giá thị trường.

Các mục dưới đây ghi cách triển khai và trạng thái theo từng thành phần, không định nghĩa lại khái niệm.

## EA Module

- [v] **Indicator on Indicator.** Price Close -> RSI 14 (Source Indicator) -> MA 9 có thể lưu bằng template `9,0,EMA,RSI(14,CLOSE)`.
- [v] **Chart và panel:** Source Indicator và Indicator on Indicator nằm cùng subwindow; panel thể hiện quan hệ giữa nguồn và indicator phụ thuộc vào nguồn.
- [v] **Vòng đời Source Indicator:** gỡ Source Indicator khỏi chart thì gỡ luôn các Indicator on Indicator phụ thuộc vào nó.
- [v] **FRAMA không nhận Source Indicator:** MT5 trả `-nan` vì FRAMA cần high/low.
- [v] **Test Indicator on Indicator** `Test\Indicator Parity OnIndicator.mq5`.

## Library

- [v] **Lưu thông tin chọn Source Indicator trong `params` của template Indicator on Indicator:** không thêm type mới vào Standard Indicator; tên hiển thị tự sinh bằng `DisplayLabel`.
- [v] **Handle Source Indicator trên MT5:** `CIndicatorDE::SetSource` gắn `applied` của Indicator on Indicator với handle của Source Indicator.
- [v] **Phân nhóm và gỡ Source Indicator:** `CIndicatorTemplateManager` (`SplitParams`, `SourceOf`, `SourceText`, `TakesSource`, `Group`), `CIndicatorsCollection` (`DeleteUnusedSources`) và `CChartObj`.
- [v] **Signal trên đường trung bình của Source Indicator:** `CSignalSourceMA` / `CSignalJudge::Price`.

## Library\Python

- [v] **Tính Indicator on Indicator:** `indicators.py` (`split_params`, `source_of`, `compute`, `valid_applied`). `compute` tính Source Indicator trên mọi nến, rồi tính indicator phụ thuộc từ nến đầu tiên nguồn có giá trị; dùng buffer cuối của nguồn.
- [v] **Đã có signal dùng Source Indicator:** `signals.source_ma`; các đường trung bình (MA, AMA, DEMA, TEMA, VIDYA) dùng luật này, loại indicator khác giữ luật riêng.
- [v] **Đo khớp MT5:** kết quả MA dùng Source Indicator khớp 1e-10.
- [v] **Loại FRAMA khỏi nhóm moving average nhận Source Indicator.**
- [v] **Bỏ `MigrateVolumesAverage`:** ngày 2026-11-16, DB không còn template Volumes V4.

## EA Web

- [v] **Đo khả năng của TradeCanvas:** RSI và EMA/SMA/DEMA/TEMA nhận RSI làm Source Indicator; kết quả khớp MT5 1e-10 bằng `indicatorSource`.
- [v] TradeCanvas chưa có indicator Volumes; `source: 'volume'` hiện lùi về close.
- [v] Đã có hướng hiển thị Indicator on Indicator cho MA trong standard indicator.

## Database

- [v] **Standard Indicator:** định nghĩa loại indicator được lưu trong bảng `indicators`; Indicator on Indicator không tạo loại mới.
- [v] **Indicator instance/template:** cấu hình cụ thể, trong đó thông tin chọn Source Indicator nằm trong `params` của `Setting_IndicatorTemplate`; không thêm table riêng.

## Việc chưa làm

- [] **Hai tầng trở lên:** Source Indicator có thể là một Indicator on Indicator, ví dụ Close -> RSI 14 -> MA 9 -> MA 5. Python đã có đệ quy, chưa đo; EA chưa cho chọn MA 9 làm nguồn vì form chỉ nhận line 0 của subwindow.
  - Library: `CChartObj::SourceWindow`.
- [] **Chọn buffer khác 0 của Source Indicator:** ví dụ dùng đường signal của MACD làm đầu vào cho MA. Hiện chỉ lấy buffer 0.
  - Library: bổ sung cách ghi buffer vào `SourceText` / `SourceOf`; `CIndicatorDE::SetSource(source, buffer)` đã nhận buffer.
  - Library\Python: `applied_price` hiện lấy buffer 0.
  - EA Module: form chưa cho chọn buffer.
- [] **Source Indicator nằm trên cửa sổ giá:** ví dụ MA nhận AMA vẽ trên nến làm đầu vào. Hiện nguồn chỉ tìm trong subwindow.
  - Library: `CChartObj::SourceWindow`; cần hỗ trợ `IsOverlay`.
  - EA Module: form chưa lấy template overlay làm nguồn.
