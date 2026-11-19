# Imp_Strategy

Concept: [Concept_Strategy.md](../concept/Concept_Strategy.md).

Nguồn strategy trước mắt: các EA trong `Experts\Allan Munene Mutiiria\Automating Trading Strategies\` (52 file `.mq5`, đánh số theo bài; Profitunity là số 01). Ba bên cùng kết quả:

- EA: `UseCases\Strategies\StrategyEngine.mqh` (judge trong `Conditions\`)
- Library\Python: `Strategy\engine.py`
- EA V5\Web: `src\strategies\conditions.ts`

## EA Module

- [v] **Đã có engine Strategy:** `StrategyEngine.mqh`, `Conditions\*`, `CStrategyPairSlots` judge `close_cross_jaw`, `rising`, `last_fractal`.
- [v] **Đã chạy parity Profitunity:** `Test\Strategy Parity Engine.mq5` replay 1000 nến khớp 6/6 BTCUSD M1; compile 0/0 và chạy không lỗi.
- [v] **Đã chốt Profitunity:** fractal dùng shift 3; shift 2 của EA gốc làm fractal trống nên không vào lệnh.
- [v] **Đã có strategy flags:** enabled / available / show_on_chart đã compile, chưa test trên terminal.
- [v] **Đã đổi tên judge dữ liệu:** `color` thành `rising`; màu chỉ là cách vẽ.
- [v] EA nạp `StrategyCollection` vào RAM một lần qua `CStrategyCollection`; bar mới tự judge trên `CStrategyBase`.

## Library

- [v] **Đã có engine chung:** `CStrategyCollection::Calculate` dùng judge chung thay switch theo tên.
- [v] **Đã có strategy trên từng cặp:** `CStrategyCollection` và `CStrategyBase` cho mỗi cặp của `Setting_SymbolTF`.
- [v] `SLOT_CHANGED` / `TF_CHANGED` đã biết nhưng chưa cho Python tính lại.

## Library\Python

- [v] **Đã có engine chung:** `Strategy\engine.py` đọc `Setting_StrategyCondition` và RULES.
- [v] **Đã chuyển Profitunity sang engine chung:** kết quả khớp EA.
- [v] `SLOT_CHANGED` / `TF_CHANGED` chưa tính lại.

## EA V5\Web

- [v] **Đã có engine/judge chung:** `src\strategies\conditions.ts` theo cùng rule với EA và Python.
- [v] **Đã có backtest strategy trên TradeCanvas:** xem [WebModule.md](../references/WebModule.md).

## Database

- [v] **Đã lưu điểm quyết định Strategy:** Python ghi `StrategyCollection` trong file của account.
- [v] Một row gồm `name`, `tf_enum`, `strategy_id`, `role`, `bar_time`, `signal_direction`; không phải lệnh thật.
- [v] Không thêm table riêng cho engine Strategy; kết quả và Setting theo nguyên tắc [Concept_WorkingOnRamSaveToDB.md](../concept/Concept_WorkingOnRamSaveToDB.md) và phân công ghi trong [Imp_WorkingOnRamSaveToDB.md](Imp_WorkingOnRamSaveToDB.md).

## Việc chưa làm

- [] **Params của event Entry:** giá vào, SL, TP; vd Harmonic lấy từ pivot.
- [] **Quản lý lệnh:** trung bình giá, trailing, breakeven; vd Pin Bar Averaging.
- [] **Tham số riêng của strategy:** `Tolerance`, `PivotLeft`…, chỗ lưu trong Setting.
- [] **Phương án áp dụng khi live:** lưu/chọn Strategy nào cung cấp Entry, SL, Trailing, TP và Exit cho từng phương án.
- [] **Slot Bar information:** `COLLECTION_SERIES_ID` (Pin Bar, Swing…) chưa có strategy nào đọc.
- [] **Strategy MA Crossover (SMA 10 cắt SMA 20 trên nến vừa đóng):** Entry = judge `ma_cross`, đọc slot `FastMA` / `SlowMA`. Backtest các phương án exit cùng nến và bộ số:
  - A (EA gốc Part 7): SL = ATR × 1.5, TP = khoảng SL × 2.
  - B: SL = giá PSAR, TP = khoảng SL × 2.
  - C: SL = giá PSAR, trailing theo PSAR, không TP.
  - D: như C, thêm Exit = PSAR lật phía.
  - E: SL = ATR × 1.5, Exit = MA cắt ngược, không TP.
  - Entry đã code ngày 2026-11-16, chưa compile/test.
    - Library: `ConditionMACross.mqh` (`CConditionMACross`, `ma_cross`) và `Setting_MACrossover.mqh` (id 2, slot FastMA/SlowMA, Entry BUY/SELL) đã thêm vào catalog.
    - Library\Python: `Strategy\engine.py` có rule `_ma_cross`; rule nhận `buffers_of(slot)`; `ast.parse` đã pass.
    - EA V5\Web: chưa làm; `STANDARD` trong `src\indicators\index.ts` chưa có MA phù hợp và `conditions.ts` chỉ nhận buffer của một slot.
    - Test: compile, bật Strategy, so EA với `StrategyCollection` của Python và EA gốc Part 7 trong Strategy Tester; parity test hiện viết cứng 4 slot Profitunity.
- [] **TF gắn với source, không với strategy:** `NULL` = TF của chart; quyết định theo nến TF chart; source ở TF khác đọc nến đã đóng gần nhất.
  - EA Module: bỏ Timeframe của strategy khỏi tab và form; source có combobox TF; cập nhật `CStrategySetting`/event TF.
  - Library: `CStrategySetting::m_tf`, `Setting_Strategy.tf_enum`, `STRATEGY_MANAGER_EVENT_TF_CHANGED` không dùng nữa; `CStrategyPairSlots`, `CStrategyCollection`, `CBarMarkerCollection::StrategyTimeframe` đọc TF của chart.
  - Library\Python: `engine.py` / `main.py` tính theo TF của cặp; slot có TF riêng đọc nến đã đóng gần nhất.
  - Kiểm tra `StrategyCollection` theo `name, tf_enum`.
- [] **Strategy có slot là indicator trên indicator:** ví dụ `MA 9,0,EMA,RSI(14,CLOSE)`.
  - Library: `CStrategyManager::Create_IndicatorTemplate`, `CIndicatorsCollection`, `RefreshAvailable`, `CStrategyPairSlots::Indicator`.
  - Library\Python: `Strategy\engine.py` qua `indicators.compute`.
  - EA Module: parity test cần thêm slot có nguồn thay vì giữ handle cứng cho slot Profitunity.
  - EA V5\Web: `STANDARD` trong `src\indicators\index.ts` chưa có MA đủ để backtest/vẽ slot có nguồn.
