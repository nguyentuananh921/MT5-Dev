# CIndicatorTemplateManager — ghi lại yêu cầu (2026-08-21, thảo luận, CHƯA code)

Bản này chỉ note lại các yêu cầu/quyết định đã thống nhất trong buổi thảo luận — chưa vào Plan mode, chưa đụng code.

**Đổi từ V9 sang V10**: cả buổi thảo luận này áp dụng cho `V10` (README V10 dòng 44: "V10 đang Update Struct thành Class" — đúng scope này). Không đụng vào V9 nữa, tránh chồng chéo.

## 1. Vấn đề gốc

`CGUIPannel` hiện đang ôm quá nhiều trách nhiệm không thuộc về 1 class GUI:
- Dựng GUI (đúng việc của nó)
- Sở hữu Pure Data — `m_symbol_tf_Setting[]` / `m_indicator_template_setting[]` (Single Source of Truth)
- Đọc/ghi JSON (`LoadIndicatorTemplateSettingFromJSON`, `SaveGUIConfigToJSON`...)
- Điều phối Layer 1/Layer 3 (scan chart, sync bridge, alert...)

`SynIndicatorPlan.md`/`SynIndicatorActionPlan.md` đã tách được "Pure Data" ra khỏi cách lưu (struct thay vì tự parse rải rác), nhưng CÁI CLASS giữ Pure Data đó vẫn là `CGUIPannel` — chưa tách khỏi GUI thật sự.

Nhân tiện: đã phát hiện `CGUIPannel::SynIndicatorOnChart` (nhánh CHANGE, GUIPannel_TabSettingIndicator.mqh dòng ~720-733) có đoạn lặp lại logic của `IsIndicatorInTemplateSetting(type, params)` (tự viết vòng for tìm `owned_row` thay vì gọi thẳng hàm đã có) — fix nhỏ này **gộp chung vào refactor lớn dưới đây**, không fix riêng lẻ trước nữa vì dù gì struct `SJsonIndicatorEntry` cũng sẽ đổi thành class.

## 2. Hướng giải quyết đã chốt

- `SJsonIndicatorEntry` (struct, có `string params[]`/`MqlParam raw_params[]` nên KHÔNG phải POD, không dùng được `ArrayCopy()`) → chuyển thành **class** `CIndicatorSetting`.
- Chứa trong `CArrayObj`/`CListObj` (có sẵn trong Library) bên trong 1 class mới: **`CIndicatorTemplateManager`** — sở hữu list này + JSON load/save + bridge/alert sync liên quan tới indicator template.
- Lý do đổi: tận dụng `Add`/`Delete`/`Insert`/`Total()`/`Search()` có sẵn của `CArrayObj`, khỏi tự `ArrayResize` + shift tay ở mọi nơi (Add/Remove/Scan hiện đang tự viết vòng lặp y hệt nhau ở 3 chỗ khác nhau).

## 2b. Ai own CIndicatorTemplateManager — EA, không phải CGUIPannel

Đối chiếu code thật `EA Using Combination Lib V10.mq5`: hiện tại EA chỉ khai báo `tradingEngine`/`timeSeriesEngine` (Layer 1) ở top-level, rồi `Set*()` CON TRỎ collection của chúng xuống `mGUIPannel` (`SetSymbolsCollection`, `SetTimeSeriesEngine`...). `mGUIPannel` (CGUIPannel) thì tự khai báo và tự own mọi thứ nội bộ của chính nó.

**Chốt**: đúng rule đã ghi sẵn ở README V10 ("CGUIPannel chỉ hold pointer các collection, không own gì thuộc PureData") — `CIndicatorTemplateManager` (PureData thật) phải được **EA.mq5 khai báo trực tiếp**, y hệt cách `tradingEngine`/`timeSeriesEngine` đang được khai báo:

```mql
// EA Using Combination Lib V10.mq5
CIndicatorTemplateManager  mIndicatorTemplateManager;
...
mGUIPannel.SetIndicatorTemplateManager(&mIndicatorTemplateManager);   // giống hệt SetTimeSeriesEngine(&timeSeriesEngine)
```

`CGUIPannel` chỉ giữ con trỏ, gọi qua nó để đọc/vẽ table — không tự `new`/own instance. Đây chính là "Separation": `CGUIPannel` quay lại đúng việc Layer 2 của nó (dựng GUI + điều khiển Show/Hide Layer 3), không ôm PureData nữa.

`m_chart_obj_collection` (Layer 3 observer, không phải PureData) — **giữ nguyên** trong `CGUIPannel`, không cần dời lên EA.

## 3. Class mới kế thừa gì

Bám theo pattern có sẵn trong Library (không tự chế): mọi object trong Library đều kế thừa `CObject` → `CBaseObj` → (`CBaseObjExt` nếu cần theo dõi property biến động).

**Quyết định: `CIndicatorSetting : public CBaseObj`** (không phải `CBaseObjExt`).

Lý do:
- `CBaseObjExt` mang theo bộ máy INC/DEC/LEVEL — cơ chế theo dõi **property SỐ biến động liên tục** (vd `CChartWnd` theo dõi `YDISTANCE`/`HEIGHT_IN_PIXELS` đổi theo pixel mỗi tick), có mảng `m_long_prop_event[property][10]` lưu ngưỡng tăng/giảm/mốc + cờ đã vượt ngưỡng chưa. Đây là engine "cảnh báo khi giá/khoảng cách tăng thêm X" — hoàn toàn không liên quan tới 1 dòng config tĩnh (Buy/Sell/Sound/Message chỉ đổi khi user bấm, không có khái niệm "tăng dần").
- `CBaseObj` đã đủ: `Type()`, `Print()`/`PrintShort()` virtual (đúng convention debug của Lib), error handling, và quan trọng nhất — **`m_chart_id_main`** (qua `SetMainChartID()`/`GetMainChartID()`), thứ duy nhất `SendEvent()` cần dùng.

## 4. Khả năng tự bắn Event ("làm xong thì báo")

Đã verify: `SendEvent()` trong Lib (`CChartWnd::SendEvent`, `CChartObj::SendEvent`...) chỉ là wrapper mỏng gọi thẳng `::EventChartCustom(m_chart_id_main, ...)` — không phụ thuộc gì vào bộ máy INC/DEC/LEVEL của `CBaseObjExt`. Nên `CIndicatorTemplateManager` (kế thừa `CBaseObj`) tự viết 1 `SendEvent()` tương tự là đủ, không cần `CBaseObjExt`.

### Luồng Event đề xuất

```
CChartWnd::Refresh() phát hiện indicator mới trên chart
   → SendEvent(CHART_OBJ_EVENT_CHART_WND_IND_ADD)          [ĐÃ CÓ, không đổi]
        ↓
CGUIPannel::OnEvent nhận được
   → gọi m_indicator_template_manager.OnChartIndicatorAdd(win_num)
        (Manager tự lo: mutate Data + gọi Layer 1 AddNewIndicatorToAllSeries)
        ↓
   Manager làm xong → tự SendEvent(CHART_OBJ_EVENT_TEMPLATE_CHANGED)   [EVENT MỚI, cần thêm]
        ↓
CGUIPannel::OnEvent nhận event MỚI này
   → chỉ lo phần GUI: InitializeTable_IndicatorTemplateSetting() + ChartRedraw()
```

Mục đích: tách rạch ròi "ai sửa Data" khỏi "ai vẽ lại GUI" bằng chuỗi event, thay vì gọi hàm lồng nhau trực tiếp trong cùng 1 hàm như `SynIndicatorOnChart` hiện tại (mutate Data và gọi `InitializeTable_IndicatorTemplateSetting()` nằm chung 1 khối). Đúng kiểu bậc thang Layer3 → Layer2-Data → Layer2-GUI đã có sẵn cho các event khác (`CHART_OBJ_EVENT_CHART_SYMB_TF_CHANGE`...).

Việc cần làm thêm ở `EventDefines.mqh`: thêm 1 giá trị mới vào `ENUM_CHART_OBJ_EVENT` (tạm đặt tên `CHART_OBJ_EVENT_TEMPLATE_CHANGED`, tên chính thức quyết sau).

## 4b. JSONConfig.mqh cũng bị đụng theo

Vì `SJsonIndicatorEntry`/`SJsonSymbolTF` biến mất, `JSONConfig.mqh` phải tách:

**Dời ra khỏi JSONConfig.mqh** (vào bên trong `CIndicatorTemplateManager`, sau này là Manager tương ứng của SymbolTF nếu làm - xem mục 5):
- `struct SJsonIndicatorEntry` / `SJsonSymbolTF` — bỏ hẳn, không cần struct trung gian.
- `IndicatorConfig_ReadEntry`/`ReadEntryArray` (đọc domain-specific "Indicator_Templates") — nên nằm ngay trong `CIndicatorTemplateManager::LoadFromJSON(text)`, tự gọi thẳng tokenizer thấp cấp để dựng `CIndicatorSetting` trực tiếp, KHÔNG qua struct trung gian (bỏ ý tưởng `LoadFromEntries(SJsonIndicatorEntry&[])` đã nghĩ tới lúc đầu).
- Tương tự `IndicatorConfig_ReadSymbolTFEntry`/`ReadSymbolTFArray` sẽ dời sang Manager của SymbolTF sau này.

**Ở lại JSONConfig.mqh** (hạ tầng dùng chung, không riêng Indicator Template):
- Tokenizer thấp cấp thuần text: `SkipSpace`, `ReadString`, `ReadRawNumber`, `ReadBool`, `SkipValue`.
- `IndicatorConfig_ReadWholeFile`, `IndicatorConfig_ExtractRawSection`, `JsonIntValue`/`JsonStringValue`/`JsonBoolValue` — `LoadMarkerSettingsFromJSON`/`LoadPatternAlertConfigFromJSON` cũng đang dùng chung, không liên quan Indicator Template.

`IndicatorConfig_ParseText`/`ParseIndicatorConfigFile` (hàm gộp parse cả 2 section 1 lượt) sẽ phải tách — mỗi Manager tự đọc đúng section của mình.

**Không phải section nào cũng cần Manager riêng** - chia rõ:
- Cần Manager (PureData thật, EA own): `"Indicator_Templates"` (`CIndicatorTemplateManager`, đã quyết), `"Symbols_TFs_List"` (Manager tương tự sau này - mục 5, chưa quyết chi tiết) - lý do: 2 cái này Layer 1 cần đọc để tạo Series/Indicator, dùng chung xuyên Layer.
- KHÔNG cần Manager, `CGUIPannel` vẫn tự đọc/ghi như hiện tại, không đổi gì: `"Markers_Setting"`/`"Sound_Settings"` (màu sắc, icon, file âm thanh) và `"Pattern_Alerts_Setting"` (checkbox Sound/Message theo pattern) - đây là config THUẦN GUI/hiển thị, không Layer 1 nào cần đọc, nên không vi phạm rule "CGUIPannel không own PureData" (chúng vốn không phải PureData).

**Ai ghi file thật (`FileOpen(FILE_WRITE)` + preserve section không sở hữu)**: vẫn là `CGUIPannel` (nơi nút Save nằm) - không dời việc ghi file lên EA. Khác biệt duy nhất: `CGUIPannel` giờ **hỏi qua con trỏ Manager** để lấy `BuildJsonSection()` (text "Indicator_Templates") thay vì tự đọc mảng của chính nó như bây giờ.

**Đọc file lúc Load**: theo mục "LoadFromText(content) thay LoadFromJSON(full_path)" đang bàn ở trên (chưa chốt hẳn) - nếu áp dụng, EA đọc file 1 lần (`IndicatorConfig_ReadWholeFile`) rồi truyền `content` cho từng Manager tự parse phần của mình, tránh đọc trùng file nhiều lần khi có >1 Manager.

## 4c. Interface Layer 1 (`AddAllIndicatorsToNewSeries`) — ĐÃ CHỐT: sửa luôn Layer 1

Hàm thật hiện tại (`TimeSeriesEngine_Indicator.mqh:122`):
```mql
void CTimeSeriesEngine::AddAllIndicatorsToNewSeries(const string symbol, const ENUM_TIMEFRAMES timeframe,
                                                     SJsonIndicatorEntry &m_indicator_template_setting[])
```
Layer 1 nhận thẳng mảng struct, đọc `.type_enum`/`.raw_params[]` từng phần tử để tạo indicator (`m_IndicatorsCollection.CreateIndicator(...)`).

**Chốt: Cách A** — sửa luôn chữ ký hàm này ở Layer 1, nhận `CArrayObj *template_list` (hoặc thẳng `CIndicatorTemplateManager *manager`), đọc qua `.TypeEnum()`/`.GetRawParams()` thay vì `.type_enum`/`.raw_params` struct field. KHÔNG dựng struct tạm để giữ tương thích ngược - struct cũ đang bị khai tử, giữ sống lại chỉ để tương thích là ngược hướng refactor.

```mql
void CTimeSeriesEngine::AddAllIndicatorsToNewSeries(const string symbol, const ENUM_TIMEFRAMES timeframe,
                                                     CArrayObj *template_list)
```

Đụng code Trishkin (`TimeSeriesEngine_Indicator.mqh`, `TimeSeriesEngine.mqh:92`, call site `TimeSeriesEngine_Lifecycle.mqh:63`) - liệt vào phạm vi refactor luôn, không tách riêng.

## 4d. 2 loại Text - Save (JSON) vs Display (Table + Message Alert)

Đối chiếu code cũ: `BuildIndicatorTextLabel()` (làm tròn 2 chữ số) được CẢ `UpdateRow_IndicatorTemplateSetting` (Table col 0) LẪN `CheckIndicatorAlerts` (Message Alert, `GUIPannel_SoundAndMessageAlerts.mqh:118`) gọi TRỰC TIẾP, tính FRESH mỗi lần, KHÔNG lưu thành field ở đâu cả. Nên thực ra chỉ có 2 loại text (không phải 3):
1. `TypeText()`/`GetParamsText()` (đã có, field lưu trữ) — full precision (8 chữ số), chỉ dùng khi Save JSON.
2. `DisplayLabel()` (MỚI thêm, method TÍNH TOÁN không lưu field) — gọi `BuildIndicatorTextLabel(m_type_enum, raw_params, catalog)` bên trong, dùng chung cho Table + Message Alert.

Đã thêm `DisplayLabel()` vào `CIndicatorSetting` (Services\IndicatorTemplateManager.mqh).

## 4e. Bất biến (invariant): KHÔNG BAO GIỜ so sánh Indicator bằng Text

Từ V9 tới giờ, mọi so khớp/identity của 1 indicator PHẢI đi qua **RAW** (`TypeEnum()`/`GetRawParams()` → `MatchesIdentity()`, dùng `IsEqualMqlParamArrays`) — **tuyệt đối không** dùng `TypeText()`/`GetParamsText()` (2 field text) để so sánh, dù chỉ 1 chỗ.

Lý do 2 field text tồn tại CHỈ để phục vụ đúng 2 việc, không hơn:
1. Ghi JSON (`BuildJsonSection()`/`TypeText()`/`GetParamsText()` - full precision, 8 chữ số).
2. Hiển thị Table/Message Alert (`DisplayLabel()` - làm tròn 2 chữ số, và thực ra KHÔNG đọc lại field text đã lưu mà TỰ TÍNH LẠI fresh từ RAW mỗi lần gọi, xem mục 4d).

Code hiện tại (`CIndicatorSetting::MatchesIdentity`, `CIndicatorTemplateManager::FindRow/Exists/Add`) đã tuân thủ đúng — invariant này ghi lại để bất kỳ code MỚI thêm sau này (Table paint, JSON dedup, SymbolTF Manager tương lai...) không lỡ tay dùng Text để so khớp.

## 4f. API public làm việc bằng CON TRỎ, không lộ "row index" ra ngoài

`CIndicatorTemplateManager` là `CArrayObj` chứa con trỏ - đúng mục đích đổi từ struct array sang class là để KHỎI phải nghĩ theo kiểu "tìm index rồi thao tác trên mảng". API public chỉ trả về/nhận `CIndicatorSetting*`:
- `FindByIdentity(type, params)` → trả `CIndicatorSetting*` (NULL nếu không có), KHÔNG trả `int` row.
- `Exists()` → `FindByIdentity(...) != NULL`.
- `IndexOfIdentity()` (private, không public) - CHỈ tồn tại vì `CArrayObj::Delete()` của Library bắt buộc cần `int index` (không có API xoá theo con trỏ trực tiếp) - `RemoveByIdentityFromTemplate()` dùng nội bộ, caller bên ngoài không bao giờ thấy khái niệm "row".

## 4g. Đã làm xong (cập nhật 2026-08-21, sau khi wire vào GUI thật)

- Field/method rename hoàn tất: `m_buy_signal`/`m_sell_signal`/`m_sound_alert`/`m_message_alert`/`m_indicator_type`/`m_indicator_params`, method `BuySignal()`/`SellSignal()`/`SoundAlert()`/`MessageAlert()`.
- Thêm `m_show_on_chart`/`ShowOnChart()` (mục 4 - preference, chưa wire vào JSON, xem dưới).
- `this.m_type = OBJECT_DE_TYPE_INDICATOR_SETTING;` trong constructor `CIndicatorSetting` (giá trị enum mới thêm cuối `ENUM_OBJECT_DE_TYPE`, Library).
- `FindByIdentity()`/`IndexOfIdentity()` (mục 4f) đã xong.
- `EA Using Combination Lib V10.mq5` giờ own trực tiếp `m_IndicatorTemplateManager` VÀ `m_ChartObjCollection` (dời từ `CGUIPannel` sang - Layer 3 do EA điều phối, không phải CGUIPannel nữa, khác quyết định cũ ở mục 2b).
- `CGUIPannel` đã có con trỏ `m_indicator_template_manager` + setter (đúng lúc cần - Table sắp port lại).
- Đã port xong `m_window_setting` + `m_tabs_main_setting_config` (Indicator/SymbolTF/CandlePattern/Marker/Sound tabs) + `m_treeview_indicator` - build chạy được, scrollbar treeview đã fix (gọi `RedrawTreeList()` trong `ShowSettingWindow()`).

## 5. Việc còn treo / chưa quyết

- **Wire `m_show_on_chart` vào JSON** - `ReadTemplateEntry()`/`BuildJsonSection()` (`IndicatorTemplateManager.mqh`) chưa đọc/ghi key `"show"` - hiện field này tồn tại nhưng không persist.
- Port nốt `CreateAddIndicatorParaInfor` (form nhập tham số) + `CreateTable_IndicatorTemplateSetting` (bảng Indicator, đọc qua `CIndicatorTemplateManager`) - còn comment trong `CreateGUIPannel()`.
- Tên chính xác các method còn lại của `CIndicatorTemplateManager` (Scan/SaveToJSON section merge với các section khác...).
- Tên event mới trong `ENUM_CHART_OBJ_EVENT` — chưa chốt, chưa thêm vào Library.
- `m_symbol_tf_Setting[]` (struct `SJsonSymbolTF`, cũng không phải POD vì có `string`) có nên đi theo cùng hướng (class + Manager riêng, hay gộp chung 1 Manager) — chưa bàn tới.

## 6. Bước tiếp theo

Vào Plan mode để phác thảo chi tiết: field/method của `CIndicatorSetting` + `CIndicatorTemplateManager`, thứ tự các bước sửa, và quyết các điểm "chưa quyết" ở mục 5 — trước khi đụng code thật.
