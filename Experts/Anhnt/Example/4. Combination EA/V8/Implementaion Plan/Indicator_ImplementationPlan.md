# Indicator Signal Wiring - Implementation Plan

> Cập nhật 2026-08-17 (Claude) - list rà lại trực tiếp từ code (`GetIndicatorCatalog`,
> `SignalsCollection::GetOrCreateSignal`, và doc-comment sẵn có trong từng file
> `Timeseries/Signal/Signal*.mqh`), KHÔNG dựa vào con số cũ trong memory (đã stale vì
> lúc đó `CSignalADX`/`CSignalZeroCross`/`CSignalEnvelopes`/`CSignalTwoLineCross` có
> thể chưa viết).

## Tổng quan

`GetOrCreateSignal()` (`Collections/SignalsCollection.mqh`) map 1-1 `CIndicatorDE` -> `CSignalBase`
qua 1 switch theo `TypeIndicator()`. Catalog hiện có 38 loại indicator (`GetIndicatorCatalog`,
không tính `IND_CUSTOM`). Hiện chỉ 6/38 có `case` trong switch.

## ✅ Đã wire (6)

SAR, MA, AMA, RSI, MACD, BBands

## 🟢 Quick-win - class Signal đã viết sẵn, chỉ cần thêm `case` (22)

Không cần viết logic mới, chỉ `new` đúng class + set tham số theo default trong comment của
từng file.

| Class có sẵn | Indicator cần thêm case | Ghi chú |
|---|---|---|
| `CSignalMA` (slope buffer 0) | DEMA, TEMA, FRAMA, VIDYA | Doc comment `SignalMA.mqh` ghi rõ áp dụng cho cả 6 loại MA-family (đã trừ MA/AMA) |
| `CSignalOscillator` (ngưỡng OB/OS) | CCI, DeMarker, WPR, MFI | Default threshold mỗi loại đã có sẵn trong comment `SignalOscillator.mqh`: CCI(100/-100), DeMarker(0.7/0.3), WPR(-20/-80), MFI(80/20) |
| `CSignalZeroCross` (cross qua mức) | AO, AC, Force, Momentum, OsMA, TRIX, Chaikin, OBV | Momentum dùng level=100 thay vì 0 (đã ghi rõ trong comment `SignalZeroCross.mqh`) |
| `CSignalADX` (DI+/DI- cross) | ADX, ADX Wilder (ADXW) | Buffer 0=ADX, 1=+DI, 2=-DI - `min_adx` gate tùy chọn |
| `CSignalTwoLineCross` (2 line cross) | Stochastic, RVI, Alligator | Usage mẫu có sẵn trong comment `SignalCrossover.mqh`: Stochastic `SetBuffers(0,1)+SetGate(80,20)`, RVI `SetBuffers(0,1)`, Alligator `SetBuffers(jaw_buf,lips_buf)` |
| `CSignalEnvelopes` | Envelopes | Buffer 0=upper, 1=lower |

## 🔴 Chưa có class, cần viết mới (10)

Ichimoku, StdDev, ATR, Gator Oscillator, Bears Power, Bulls Power, A/D, Volumes,
Market Facilitation Index (BWMFI), Fractals

**Lưu ý trước khi viết**: ATR / StdDev / Volumes / BWMFI về bản chất là đo biến động hoặc
khối lượng, không có hướng Buy/Sell tự nhiên - cần bàn với Anhnt xem có thật sự cần Signal
cho nhóm này không, hay để trống (chỉ hiển thị giá trị, không có icon Buy/Sell).

## Việc cần làm

- [ ] Quyết định thứ tự làm: chắc nên làm hết nhóm Quick-win (22) trước vì rẻ, rồi mới bàn
      tiếp nhóm cần class mới (10).
- [ ] Với nhóm Quick-win: thêm `case` trong `GetOrCreateSignal()`, verify default threshold/
      buffer index đúng với comment của từng class trước khi merge.
- [ ] Với nhóm cần class mới: bàn từng loại có cần Signal thật hay không trước khi code.
