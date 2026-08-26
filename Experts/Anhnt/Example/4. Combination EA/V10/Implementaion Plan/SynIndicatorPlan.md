# Sync Indicator-Template giữa các Layer — Plan (rà soát lại 2026-08-19)
Mục tiêu là rà soát xóa bỏ các Properties, method thừa ở các Layer
Bản này thay thế toàn bộ nội dung cũ — rà soát lại từ hiện trạng code thật, không phải từ thiết kế lý thuyết ban đầu nữa.

## 1. Concept (không đổi)
Một Indicator phân biệt duy nhất bởi **type + params**. Symbol/TF KHÔNG thuộc identity — theo bất biến "mọi series mang cùng 1 template set".

## 2. Center Point Data
`SJsonIndicatorEntry m_indicator_template_setting[]` (CGUIPannel hold, định nghĩa trong `Anatoli Kazharski\JSONConfig.mqh`) là **nguồn sự thật DUY NHẤT** — mọi Layer đọc/ghi qua nó, không Layer nào giữ bản sao riêng. `m_table_indicator_template` chỉ là VIEW của nó (Mirror 1-1: 1 phần tử mảng = 1 row).

Struct hiện tại:
```cpp
struct SJsonIndicatorEntry
   {
     string type;      // text hiển thị (catalog name, vd "PSAR")
     string params[];   // text theo schema, full precision - dùng để lưu JSON + build identity key
     bool   buy;
     bool   sell;
     bool   sound;
     bool   message;
   };
```

**ĐÃ LÀM (2026-08-19)**: thêm 2 field để Layer 1 dùng thẳng, khỏi tự tra catalog / tìm đại diện:
```cpp
     ENUM_INDICATOR type_enum;    // giá trị enum thật
     MqlParam       raw_params[]; // Layer 1 dùng thẳng, không cần tìm đại diện
```
Populate: `LoadGUIConfigFromJSON` parse text→raw theo schema NGAY TRONG THÂN HÀM (không tách hàm riêng - Layer 1 tuyệt đối không đụng JSON/text, và không cần thêm 1 hàm dùng chung chỉ có đúng 1 caller). `AddIndicatorToTemplate`/`ScanIndicatorOnChart` (đang treo, xem `SynIndicatorActionPlan.md` Phase 1) sẽ gán trực tiếp vì đã có raw sẵn trong tay.

**ĐÃ LÀM**: xóa hẳn `CTimeSeriesEngine::ApplyIndicatorTemplateSetting` - startup giờ coi là "mọi Series đều mới", `LoadGUIConfigFromJSON` gọi thẳng `AddAllIndicatorsToNewSeries` (dùng chung với CHARTCHANGE) 1 lần cho mỗi Series vừa tạo, thay vì có 2 path riêng biệt làm cùng 1 việc.

Đã rà soát đủ cả 4 Layer (mục 3 dưới) — kết luận chỉ thiếu đúng 2 field này, không Layer nào cần thêm gì khác.

## 3. Mỗi Layer cần Parameter gì cho Add/Delete (đã rà soát code thật)

**Layer 1 (CTimeSeriesEngine)** — identity RAW:
- `AddNewIndicatorToAllSeries(type, params)` / `RemoveIndicatorFromAllSeries(type, params)` — nhận `ENUM_INDICATOR` + `MqlParam[]`. Cả 2 CÙNG dùng (type,params) raw, không cần gì khác từ caller (Signal/buffer lifecycle là việc NỘI BỘ Layer 1 tự lo, không cần thêm input).
- `AddAllIndicatorsToNewSeries(symbol, tf, m_indicator_template_setting[])` — nhận mảng, đọc thẳng `.type_enum`/`.raw_params[]` (đã sửa, xem mục 4) — không còn `BuildTemplateMatchKey`/tìm đại diện nữa.

**Layer 2 (CGUIPannel / m_indicator_template_setting[])** — identity TEXT (để lưu JSON+hiển thị):
- Add: append `SJsonIndicatorEntry` mới — `type_key` + `params_key` (text) + buy/sell/sound/message=false.
- Delete: xóa phần tử tại `row`, `row` tìm qua `GetRowForIdentity(type_key, params_key)`.

**Layer 3 (Chart)** — không có khái niệm type+params trong chính API của nó:
- `ChartIndicatorAdd(chart_id, sub_window, handle)` — cần handle (Layer 2 có sẵn qua `GetIndicatorForRow`) + sub_window (Layer 2 tự quyết theo Group).
- `ChartIndicatorDelete(chart_id, sub_window, name)` — cần tên+window, THỨ NÀY KHÔNG NẰM Ở ĐÂU CẢ (không trong Data, không trong Layer1) - chỉ có trên chính Chart, nên `DetachIndicatorFromChart` phải quét `CChartWnd`/`CWndInd` để lấy ra trước khi gọi được.
- Show/Hide state + handle: cố ý KHÔNG lưu trong Data (runtime/per-chart, dễ stale) - luôn resolve qua `GetIndicatorForRow(row)` mỗi lần cần.

**Layer 4 (SignalBridge)**:
- Chỉ cần `buy`/`sell` (đã có sẵn trong Data) + con trỏ sống (resolve runtime qua `GetIndicatorForRow`, không lưu Data).
- `CSignalBridgeWriter::TemplateBuySellFor` đã tự so khớp bằng **RAW** (`IsEqualMqlParamArrays`) từ trước - không đụng `BuildTemplateMatchKey`/text key gì cả. Đây là bằng chứng cho thấy so khớp RAW đã là "phong cách" có sẵn trong hệ thống, không phải hướng mới bịa ra.

## 4. Các hàm đã viết lại hôm nay (2026-08-19) - CGUIPannel

- `InitializeTable_IndicatorTemplateSetting()` — thuần vẽ lại `m_table_indicator_template` từ `m_indicator_template_setting[]`, không quét Layer 1 nữa (row count = `ArraySize(m_indicator_template_setting)`).
- `UpdateRow_IndicatorTemplateSetting(row)` — paint 1 row từ Data; `GetIndicatorForRow(row)` chỉ dùng cho cosmetics cần live instance (Label, Group, Show).
- `AddIndicatorToTemplate(type, params)` — check tồn tại → gọi Layer 1 tạo → append Data → `ChartIndicatorAdd` hiện ngay trên chart → resync table. Dùng cho `OnClickAddIndicator` + `SynIndicatorOnChart` nhánh CHANGE.
- `RemoveIndicatorFromTemplate(type, params)` (đổi tên từ `RemoveIndicatorInstance`) — detach chart (qua `GetIndicatorForRow`, không quét `m_IndicatorsCollection` nữa) → xóa Data TRƯỚC → gọi Layer 1 xóa SAU (Layer 2 quyết, Layer 1 chấp hành).
- `ScanIndicatorOnChart(void)` (đổi tên từ `ImportForeignChartIndicators`) — quét Chart, indicator MỚI (chưa có trong Data) thì gọi `AddNewIndicatorToAllSeries` (Layer 1) RỒI MỚI append Data; indicator ĐÃ CÓ (re-Insert) thì chỉ `SyncTable_IndicatorTemplateSetting()`, không đụng gì cả. **SỬA LẠI 2026-08-19** (bản đầu "KHÔNG gọi Layer 1" SAI - đã test thật: row không có object Layer 1 backing thì `GetIndicatorForRow` luôn NULL, khiến Remove/Show-toggle/Label silently no-op cho MỌI row đến từ đường này - xem `SynIndicatorActionPlan.md` mục sự cố).
- `SyncTable_IndicatorTemplateSetting()` — dirty-check cột Show, dùng `m_bool_table_indicator_template_cache_show[]` (đổi từ `int` sang `bool`, bỏ sentinel `-1` vì `UpdateRow_IndicatorTemplateSetting` luôn ghi cache trước khi hàm này có cơ hội thấy size lệch).
- `GetIndicatorForRow(row)` / `GetRowForIdentity(type_key, params_key)` / `IndicatorTemplateSettingExists(type_key, params_key)` — không đổi logic, chỉ uncomment lại khai báo.

- `LoadGUIConfigFromJSON` — sau khi copy `entries[]` vào `m_indicator_template_setting[]`, parse text→raw NGAY TẠI CHỖ (inline, không tách hàm) để điền `.type_enum`/`.raw_params[]`; sau đó gọi `AddAllIndicatorsToNewSeries` 1 lần/Series thay vì `ApplyIndicatorTemplateSetting` (đã xóa).
- `AddAllIndicatorsToNewSeries` (Layer 1) — đọc thẳng `.type_enum`/`.raw_params[]`, không còn tìm đại diện + `BuildTemplateMatchKey`; entry nào `raw_params` rỗng thì skip. Dùng chung cho CẢ startup lẫn CHARTCHANGE.

## 5. Việc còn treo (chưa làm)
- `AddIndicatorToTemplate`/`ScanIndicatorOnChart` (Layer 2) chưa điền `.type_enum`/`.raw_params[]` khi append entry MỚI lúc đang chạy - xem `SynIndicatorActionPlan.md` Phase 1 (đã có sẵn raw trong tay, chỉ cần gán trực tiếp, không cần parse).
- Cân nhắc (chưa quyết): có chuyển hẳn `GetRowForIdentity`/`IndicatorTemplateSettingExists`/`GetIndicatorForRow` sang so khớp RAW (`IsEqualMqlParamArrays`) thay vì text key không, giờ Data đã có raw rồi (khớp phong cách `TemplateBuySellFor` đã dùng sẵn).
