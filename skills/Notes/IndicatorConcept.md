# Indicator Concept

 Các mục trong Note thống nhất khái niệm Indicator, Indicator on Indicator và Base Indicator Strategy theo [Clear Understand](../AGENTS.md#clear-understand).

## Indicator defines

 - **Standard Indicator:** tính output từ dữ liệu thị trường được chọn làm input, ví dụ `Close`.
  + Value của Standard Indicator được đọc khi cần tính, không dùng Event như nguồn giá trị trực tiếp ([Event.md](Event.md#nguyên-tắc-chung)).

 - **Source Indicator:** Standard Indicator cung cấp buffer/value làm input cho Standard Indicator khác.

 - **Indicator on Indicator:** dùng cùng phương pháp tính của Standard Indicator, nhưng input `applied` là buffer/value của Source Indicator.
  + Chỉ thay nguồn input; không tạo thuật toán hay loại indicator mới. Output thuộc về Standard Indicator đang tính.
  + Ví dụ: MA trên RSI vẫn là MA; RSI thay `Close` làm đầu vào cho MA.
 - Mọi indicator được identify trong toàn system bởi cặp `type` + `params` (`UNIQUE (type_enum, params)` của `Setting_IndicatorTemplate`).

## Base Indicator Strategy

- Base Indicator Strategy là một [Strategy](Concepts.md#strategy) dựa trên Standard Indicator hoặc Indicator on Indicator ([Indicator](#indicator-defines)).
- Mỗi Indicator template có một Base, định danh bằng `id` của template.
- `CIndicatorTemplateManager` sở hữu CRUD template qua `CDatabaseService`, theo [Working with Event](Event.md#working-with-event).
- Base tự bật với mọi role của nó khi Indicator có trong template; không có flag bật/tắt, không dùng `CStrategySetting` riêng.

### Rule và role

- Rule theo role là judge chuẩn của `CSignalsCollection`, theo loại trong [Indicator defines](#indicator-defines):
  + Standard Indicator: judge theo type (`CSignalSAR`, `CSignalMA`…).
  + Indicator on Indicator: judge theo Source Indicator (`CSignalSourceMA` / `CSignalJudge::Price`).
- Mỗi rule xác định role của base; role là ô trong [Quyết định × Phạm vi](Concepts.md#quyết-định--phạm-vi).
- Vd PSAR cung cấp Entry, SL, Trailing và Exit; ATR cung cấp SL.
- Role phải lấy từ rule của base; không viết cứng loại indicator trong GUI hoặc controller.
- Nhiều base cùng role: theo [Ghép role](Concepts.md#trading).
- [v] `SERIES_EVENTS_SIGNAL` gửi khi signal của template lật phía.

 Các mục dưới ghi trạng thái theo Working Area; No Duplicate và Sync Everywhere theo [Rules gate](../AGENTS.md#rules-gate-mục-tiêu-xuyên-suốt).

## MT5 Library

- [v] `CIndicatorDE::SetSource` gắn `applied` của Indicator on Indicator với handle Source Indicator.
- [v] `CIndicatorTemplateManager` hỗ trợ `SplitParams`, `SourceOf`, `SourceText`, `TakesSource`, `Group`.
- [v] `CIndicatorsCollection::DeleteUnusedSources` và `CChartObj` quản lý vòng đời Source Indicator.
- [v] `CSignalSourceMA` / `CSignalJudge::Price` xử lý signal trên đường trung bình của Source Indicator.
- [v] `CTradingControl::StopLossPrice` và `CTradingControl::BuildPlan` lấy SL/TP theo base.

## EA Module

- [v] Tạo [Indicator on Indicator](#indicator-on-indicator) từ panel, vd Close -> [Source Indicator](#indicator-on-indicator) RSI 14 -> MA 9 ([Indicator on Indicator](#indicator-on-indicator), EMA).
- [v] [Source Indicator](#indicator-on-indicator) và [Indicator on Indicator](#indicator-on-indicator) nằm cùng subwindow; panel thể hiện quan hệ phụ thuộc.
- [v] Gỡ [Source Indicator](#indicator-on-indicator) thì gỡ các [Indicator on Indicator](#indicator-on-indicator) phụ thuộc.
- [v] Test Indicator on Indicator tại `Test\Indicator Parity OnIndicator.mq5`.

## Python Library

- [v] `indicators.py` hỗ trợ `split_params`, `source_of`, `compute`, `valid_applied`.
- [v] `compute` tính Source trên mọi nến rồi tính indicator phụ thuộc từ nến nguồn đầu tiên có giá trị.
- [v] MA dùng Source Indicator khớp MT5 1e-10.
- [v] `signals.source_ma` hỗ trợ MA, AMA, DEMA, TEMA, VIDYA.
- [v] FRAMA không nhận Source Indicator.
- [v] Không còn template `Volumes V4`.

## EA Web

- [v] TradeCanvas đo được RSI và EMA/SMA/DEMA/TEMA nhận RSI làm Source Indicator.
- [v] `indicatorSource` khớp kết quả MT5 1e-10.
- [ ] TradeCanvas chưa có indicator Volumes; `source: 'volume'` hiện lùi về close.
- [ ] Chưa hoàn tất hướng hiển thị cho mọi Indicator on Indicator.

## Database

- Standard Indicator lưu loại indicator trong bảng `indicators`.
- Indicator instance/template lưu cấu hình trong `Setting_IndicatorTemplate`; thông tin Source Indicator nằm trong `params`, vd `9,0,EMA,RSI(14,CLOSE)`.
- Không tạo table riêng cho Indicator on Indicator.

## Việc chưa làm

- [] **Hai tầng trở lên:** Close -> RSI 14 -> MA 9 -> MA 5. Python đã có đệ quy; chưa đo; EA chưa cho chọn MA 9 làm source.
- [] **Buffer khác 0 của Source:** bổ sung chọn buffer trong `SourceText` / `SourceOf`; `CIndicatorDE::SetSource(source, buffer)` đã nhận buffer. Form của EA chưa chọn buffer.
- [] **Source Overlay:** hỗ trợ nguồn MA/AMA vẽ trên nến; MT5 cần `CChartObj::SourceWindow` hỗ trợ `IsOverlay`, EA chưa lấy template overlay làm source.
- [] **Role theo judge:** đổi GUI và `CTradingControl::StopLossPrice` để đọc role của base từ `CSignalsCollection`; hiện còn viết cứng `IND_SAR` / `IND_ATR`.
