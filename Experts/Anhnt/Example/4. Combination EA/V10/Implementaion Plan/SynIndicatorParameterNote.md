# SynIndicator Parameter Note

Rà soát (2026-08-22): match 1-1 giữa 1 `CIndicatorDE` (Layer 1) và 1 Indicator quét được trên Chart (Layer 3, qua `CChartObjCollection`/`CWndInd`) có đúng ý nghĩa không, và `(type,params)` khi đi qua từng lớp có bị "gà lai vịt" chỗ nào không. Bổ sung cho `SynIndicatorPlan.md`/`SynIndicatorActionPlan.md`.

## 1. Audit từng field của `CWndInd` (Layer 3)

| Field | Là gì | Khớp với `CIndicatorDE` (Layer 1) không? |
|---|---|---|
| `m_name` | Tên chart tự sinh cho 1 instance cụ thể đang gắn (MT5 tự đặt) | **KHÔNG.** `CIndicatorDE::Name()`/`ShortName()` (`INDICATOR_PROP_NAME`/`SHORTNAME`) là string do CALLER truyền tay lúc `new CIndBands(...)` (nhãn tĩnh theo TYPE) — khác nguồn, khác format với tên MT5 tự sinh bên Chart. Không dùng để so khớp.
| `m_handle` (số) | Số handle MT5 gán | **KHÔNG đáng tin để so trực tiếp** với `CIndicatorDE.Handle()`. Bug đã dính: `SAR(0.05,0.20)` handle=17 (Chart) vs handle=18 (Layer 1 owned) — cùng 1 indicator về logic nhưng MT5 không đảm bảo dùng chung 1 handle khi tạo qua 2 đường khác nhau (code Layer 1 gọi `IndicatorCreate` vs user tự tay attach).
| `m_handle` → `IndicatorParameters(m_handle, type, params)` | Tra cứu ra `(ENUM_INDICATOR type, MqlParam params[])` — đúng tham số gốc đã tạo ra handle đó, bất kể ai tạo | **CÓ** — đây là thứ DUY NHẤT dùng để so khớp Layer 3 ↔ Layer 1/Data, không phải bản thân `m_handle`/`m_name`.

`CWndInd::GetIdentity(type, params)` (mới thêm, `WndInd.mqh`) chính là wrap gọn dòng tra cứu này.

## 2. Chuỗi `(type,params)` xuyên các lớp — có bị lai không?

| Nguồn | Field | Ý nghĩa |
|---|---|---|
| Built-in `IndicatorParameters(handle,...)` | `type`, `params` | Tham số gốc truyền cho `IndicatorCreate()` lúc tạo handle |
| `CIndicatorDE.m_mql_param[]` | constructor `IndicatorDE.mqh:153-159` | Copy y hệt mảng `params` truyền vào constructor, NGAY TRƯỚC khi tự gọi `IndicatorCreate()` |
| `CIndicatorSetting.m_type_enum` / `m_raw_params[]` | `Add()`/`LoadFromJSON` | Cũng chính là `(type,params)` gốc, không convert lại — **KHÔNG PHẢI `m_indicator_type`** (field đó là string display "BBands", chỉ để Table/JSON, không dùng để so identity) |

Cả 3 chỗ đều CÙNG 1 khái niệm, truyền tay qua tay, không ai tự suy diễn lại → không có chỗ "gà lai vịt" trong chuỗi truyền giá trị.

## 3. Cơ chế so sánh — 2 bản KHÔNG giống nhau, dùng đúng bản nào ở đâu

- **Free function** `IsEqualMqlParams`/`IsEqualMqlParamArrays` (`TimeseriesDELib.mqh:458-488`): so double bằng `NormalizeDouble(a-b, DBL_DIG) == 0` — bền với nhiễu làm tròn. Dùng bởi `CIndicatorSetting::MatchesIdentity()` (Data layer) và `CTimeSeriesEngine::RemoveIndicatorFromAllSeries`/`GetIndicatorHandle` (Layer 1, đã đọc code thật xác nhận cùng kiểu so giá trị, không so số handle).
- **Method riêng của `CIndicatorDE`** (`IndicatorDE.mqh:240-249`, cùng tên nhưng khác thân hàm): so double bằng `==` chính xác tuyệt đối (không normalize), VÀ `CIndicatorDE::IsEqual()` còn so thêm TOÀN BỘ `ENUM_INDICATOR_PROP_INTEGER/DOUBLE/STRING` khác (name, symbol, digits...) chứ không chỉ raw params. Dùng bởi `CIndicatorsCollection::Index()` — bookkeeping NỘI BỘ riêng của Layer 1 (36+ call site trong chính `IndicatorsCollection.mqh`), Template feature của mình **chưa bao giờ gọi tới** (grep xác nhận). Không đụng vào, không xoá — thuộc về Layer 1, không liên quan Template.

**Kết luận:** Template feature luôn đi theo nhánh free-function (bền hơn), tự tách biệt hoàn toàn khỏi cơ chế `CIndicatorDE::IsEqual()` (dễ vỡ hơn, có scope rộng hơn nhiều).

## 4. Schema tay viết (`GetIndicatorParamSchema`, `TimeseriesDELib.mqh:160`) vs thứ tự tham số MT5 thật

Đối chiếu 4 loại đang thật sự dùng trong `Config_Setting.json`:

| `IND_XXX` | Schema | Thứ tự thật MT5 `iXXX()` | Khớp |
|---|---|---|---|
| IND_SAR | `[0]=Step,[1]=Maximum` | `iSAR(sym,tf,step,max)` | ✓ |
| IND_MA | `[0]=Period,[1]=Shift,[2]=Method,[3]=Price` | `iMA(sym,tf,period,shift,method,price)` | ✓ |
| IND_BANDS | `[0]=Period,[1]=Shift,[2]=Deviation,[3]=Price` | `iBands(sym,tf,period,shift,deviation,price)` | ✓ |
| IND_AMA | `[0]=AMAPeriod,[1]=Fast,[2]=Slow,[3]=Shift,[4]=Price` | `iAMA(sym,tf,ama,fast,slow,shift,price)` | ✓ |

4/4 đang dùng thật đều khớp. Rủi ro còn lại chỉ là lỗi tay khi viết thêm 1 `case` mới trong schema (cần soát thủ công từng loại lúc thêm), không phải lỗi hệ thống của cơ chế Scan/So sánh.

## 5. Phát hiện thật — `AddAllIndicatorsToNewSeries` LỆCH signature, chưa dùng được với V10

```mql5
void CTimeSeriesEngine::AddAllIndicatorsToNewSeries(const string symbol, const ENUM_TIMEFRAMES timeframe,
                                                     SJsonIndicatorEntry &m_indicator_template_setting[])
```

Khác với `AddNewIndicatorToAllSeries(type,params)`/`RemoveIndicatorFromAllSeries(type,params)` (nhận đúng 1 cặp identity, đã xác nhận đúng ý nghĩa) — hàm này nhận nguyên **mảng `SJsonIndicatorEntry[]`** (struct V9 cũ, `.type_enum`/`.raw_params`). Struct này **không còn tồn tại trong V10** (đã thay bằng `CIndicatorTemplateManager`/`CIndicatorSetting`).

→ Khi nào cần seed 1 Series MỚI (Symbol+TF mới) bằng toàn bộ Template, KHÔNG thể gọi thẳng hàm này với `m_IndicatorTemplateManager`. 2 hướng xử lý sau này:
- (a) Sửa lại signature nhận class mới, hoặc
- (b) EA tự loop `m_IndicatorTemplateManager.Total()/At(i)` rồi gọi `AddNewIndicatorToAllSeries(type,params)` từng dòng (tái dùng hàm đã đúng), bỏ hẳn `AddAllIndicatorsToNewSeries`.

Chưa cấp bách — Symbol+TF đang tạm hoãn (README §3). Ghi lại để không quên khi động tới phần đó.
