# Web Module
`EA V5\Web`. Tuân thủ Rules gate như mọi module (AGENTS.md). Phía server (`server.py`: route, `/socket`, mở tab trình duyệt): Python.md. Việc chưa làm: ProblemNote.md (`Python / Web`).

## Input
- Setting: `GET /strategies` (strategy, slot, params, condition; `libdb.strategies`).
- Symbol: `GET /symbols` (các symbol của account, table `symbols`), danh sách của nút symbol thay `DEFAULT_SYMBOLS` của TradeCanvas.
- Nến: `GET /bars`, `GET /timeframes`; dòng mới của pair: WebSocket `/socket` (hub).

## Function
Dùng TradeCanvas để tính, vẽ và backtest strategy (signal, indicator) trên nến của chart; tự tính, không cần Python.

## Output
- Trên chart TradeCanvas: indicator của slot, signal, lệnh của backtest, bảng các lần chạy (strategy và từng base).
- Sửa params của slot trong settings của strategy để backtest lại. Không ghi kết quả theo nguyên tắc [Concept_WorkingOnRamSaveToDB.md](../concept/Concept_WorkingOnRamSaveToDB.md) và hiện trạng [Imp_WorkingOnRamSaveToDB.md](../Implementaion/Imp_WorkingOnRamSaveToDB.md).

## File (`src\`)
| File | Việc |
|---|---|
| `main.ts` | Khởi động, chart (`mountWidget` từ demo TradeCanvas), nối `/socket` |
| `indicators\index.ts` | Buffer của indicator chuẩn từ indicator của TradeCanvas, theo thứ tự buffer của MT5 (như `indicators.py`); chỉ các type strategy đang đọc |
| `signals\index.ts` | Bản soi của `signals.py`: cùng luật, cùng tên, cùng buffer; `directions()`, `flips()` |
| `strategies\conditions.ts` | Engine strategy (`conditionStrategy`, `STRATEGY_RULES`) |
| `strategies\base.ts` | Base: một slot giao dịch theo signal của nó, để so với strategy |
| `strategies\plugin.ts` | Strategy của `/strategies` thành một indicator của TradeCanvas: slot, settings, bảng các lần backtest, lệnh trên chart |
| `strategies\types.ts` | Kiểu các dòng `GET /strategies` (tên cột như EA và Python) |
| `backtest\index.ts` | Backtest bằng `Backtester` của `@tradecanvas/analytics`: strategy và từng base trên cùng nến |
| `sampleData.ts` | Nến giả (random walk) cho chế độ không server (`staticBars`) |

## TradeCanvas: có gì, thiếu gì (đã đo)
- Khớp MT5 1e-10: rsi, ema, sma, dema, tema trên RSI, ghép bằng `indicatorSource` (indicator trên indicator).
- Không có indicator Volumes; `source:'volume'` lùi về close.

## Lệnh
- Build: `npm run build` trong `EA V5\Web` (ra `Web\dist`, server.py phục vụ qua `web_folder`).
