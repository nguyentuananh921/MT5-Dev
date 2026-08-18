# Tách rõ Layer 1 / Layer 2 cho phần Buy/Sell/Sound/Message per-Template & per-SymbolTF

## Bối cảnh
Ngày: 2026-08-16. Phát hiện trong lúc rà `CGUIPannel::SyncIndicatorTemplateSettingToBridge` — soi ra `CTimeSeriesEngine` (Layer 1, "Pure Data") đang giữ 2 cụm cache không thuộc phạm vi của nó.

## Vấn đề (CONFIRMED qua grep)

`CTimeSeriesEngine` hiện có 2 cụm field cache, cả 2 đều: (1) parse ra từ JSON, (2) không hề được chính Layer 1 đọc lại để dùng cho việc gì của nó, (3) người dùng DUY NHẤT là Layer 2 (`CGUIPannel`) — tức Layer 1 chỉ đang làm hộ việc parse+giữ tạm cho Layer 2.

### 1. Per-Template (`TimeSeriesEngine.mqh:57-62`)
```cpp
string m_loaded_tmpl_type[];         // ĐÚNG phạm vi Layer 1 (identity template)
string m_loaded_tmpl_params_key[];   // ĐÚNG phạm vi Layer 1
bool   m_loaded_tmpl_buy[];          // SAI phạm vi — bản chất Marker/Signal filter (Layer 2)
bool   m_loaded_tmpl_sell[];         // SAI phạm vi
bool   m_loaded_tmpl_sound[];        // SAI phạm vi — Alert opt-in (Layer 2)
bool   m_loaded_tmpl_message[];      // SAI phạm vi
```
- Populate: `TimeSeriesEngine_JSONConfig.mqh:41-58` (trong `LoadConfigurationFromJSON`)
- Expose: `GetLoadedTemplateSettings()` (`TimeSeriesEngine.mqh:104`, impl `TimeSeriesEngine_JSONConfig.mqh:323`)
- Người dùng duy nhất: `CGUIPannel::ApplyLoadedIndicatorBuySell()` (`GUIPannel_TabSettingIndicator.mqh:957`, gọi 1 lần từ `OnInitEvent` — `GUIPannel_Lifecycle.mqh:159`) — seed checkbox cột 2/3 (Buy/Sell) của `m_table_indicator_template`.

### 2. Per-Symbol+TF (`TimeSeriesEngine.mqh:48-51`)
```cpp
string m_loaded_sf_symbols[];   // ĐÚNG phạm vi Layer 1 (khớp "Symbols_TFs_List")
string m_loaded_sf_tfs[];       // ĐÚNG phạm vi Layer 1
bool   m_loaded_sf_buy[];       // SAI phạm vi
bool   m_loaded_sf_sell[];      // SAI phạm vi
```
- Populate: `TimeSeriesEngine_JSONConfig.mqh:24-37`
- Expose: `GetLoadedSymbolTFSettings()` (`TimeSeriesEngine.mqh:103`, impl `TimeSeriesEngine_JSONConfig.mqh:316`)
- Người dùng duy nhất: `GUIPannel_TabSettingSymbolTF.mqh:190` — seed checkbox `m_table_indicator_SymbolTFSeting`.

### Đối chiếu với README (mục 6, bảng sở hữu JSON section)
- Layer 1 (`CTimeSeriesEngine`) chính thức sở hữu: `"Symbols_TFs_List"`, `"Indicator_Templates"`.
- Layer 2 (`CGUIPannel`) chính thức sở hữu: `"Markers_Setting"`, `"Pattern_Alerts_Setting"`, `"Sound_Settings"`.
- Vấn đề: `buy/sell/sound/message` hiện bị nhét CHUNG vào từng entry của `"Indicator_Templates"`/`"Symbols_TFs_List"` (JSON section Layer 1 sở hữu) — đúng về mặt file, nhưng SAI về mặt ý nghĩa (đây là data thuộc phạm trù Marker/Alert opt-in, cùng nhóm với `"Markers_Setting"`/`"Pattern_Alerts_Setting"` mà Layer 2 đang sở hữu).

## Bug phụ phát hiện trong lúc soi (KHÔNG liên quan layering, nhưng liên quan trực tiếp)

`TimeSeriesEngine_JSONConfig.mqh:205-212`, trong `SaveConfigurationToJSON` — phần Template:
```cpp
for(int i = 0; i < tmpl_total; i++)
  {
   tmpl_ptrs[i] = templates.At(i);
   tmpl_buy[i] = true;      // ← HARDCODE true, không đọc checkbox thật
   tmpl_sell[i] = true;
   tmpl_sound[i] = true;
   tmpl_message[i] = true;
  }
```
Buy/Sell/Sound/Message của **Template** khi Save luôn ghi `true` cứng, KHÔNG đọc checkbox thật từ `m_table_indicator_template` (cột 2/3/5/6). Khác hẳn phần **Symbol/TF** — đã ĐÚNG, nhận `buys[]`/`sells[]` làm tham số từ `CGUIPannel::BuildSymbolTFBuySellArrays` (đọc checkbox thật). Cần fix cùng đợt refactor này — thêm tham số tương tự cho template.

## Hướng sửa ĐÃ CHỐT (v2, 2026-08-16 — đơn giản hơn bản đầu, KHÔNG đổi JSON format)

Bản đầu định thêm 2 section JSON mới (`"Indicator_Template_Setting"`/`"Symbol_TF_Setting"`) — bị huỷ vì không cần thiết: cách Symbol/TF đang Save (Layer 2 đọc checkbox thật → truyền vào Layer 1 như tham số → Layer 1 chỉ viết hộ) **đã đúng kiểu tách layer muốn có**, chỉ cần áp dụng y hệt cho Template (đang hardcode) và dọn lại phần LOAD. **File JSON giữ nguyên format hiện tại, không cần migrate.**

### Nguyên tắc
- Layer 1 chỉ **parse hộ rồi trả ngay ra ngoài** — không giữ `buy/sell/sound/message` làm state riêng của nó nữa (không giữ = không có gì để "SAI phạm vi" cả).
- Layer 1 chỉ giữ lại state cho phần **identity thuần** (symbol/tf, type/params_key) — đổi sang **struct array** cho gọn & rõ nghĩa, thay vì nhiều mảng song song như hiện tại.
- Layer 2 tự đọc/tự giữ phần setting (buy/sell/sound/message) của riêng nó, và khi Save thì tự đọc checkbox thật rồi truyền vào Layer 1 như tham số (đúng pattern Symbol/TF đã có).

### Đổi tên + đổi cấu trúc (Anhnt, 2026-08-16 — dùng struct thay vì mảng song song)

**Layer 1 (`CTimeSeriesEngine`)** — chỉ identity, KHÔNG có buy/sell/sound/message:
```cpp
struct SSymbolTF          { string symbol; string tf; };
struct SIndicatorTemplate { string type; string params_key; };
SSymbolTF          m_symbol_tf[];
SIndicatorTemplate m_indicator_template[];
```
(Layer 1's `m_indicator_template[]` là **mirror** của các indicator template thực tế đang tồn tại trên Chart/`CIndicatorsCollection` — không phải nguồn gốc, chỉ phản chiếu lại.)

**Layer 2 (`CGUIPannel`)** — dự tính ban đầu là tạo struct riêng `SSymbolTFSetting`/`SIndicatorTemplateSetting`, nhưng lúc code thực tế đổi ý: **tận dụng thẳng** `SJsonSymbolTF`/`SJsonIndicatorEntry` sẵn có trong `IndicatorConfigLoader.mqh` làm luôn kiểu lưu trữ của Layer 2 (đã chứa đúng field cần, không cần định nghĩa thêm struct trùng lặp):
```cpp
SJsonSymbolTF       m_symbol_tf_Setting[];          // thay vì tự định nghĩa SSymbolTFSetting
SJsonIndicatorEntry m_indicator_template_setting[]; // thay vì tự định nghĩa SIndicatorTemplateSetting
```
`GUIPannel.mqh` include thẳng `IndicatorConfigLoader.mqh` để có 2 type này (file đó chỉ có struct + hàm parse thuần, không kéo theo phần nào khác của Layer 1, an toàn để include trực tiếp).

## Việc cần làm — ĐÃ CODE XONG (2026-08-16), chờ Anhnt build/test

### Layer 1
- [x] `TimeSeriesEngine.mqh`: xoá `m_loaded_sf_*`/`m_loaded_tmpl_*` + 2 getter cũ. Thêm struct `SSymbolTF`/`SIndicatorTemplate` + field `m_symbol_tf[]`/`m_indicator_template[]` (chỉ identity).
- [x] `LoadConfigurationFromJSON` **tách làm 2** (theo đề xuất Anhnt) thay vì giữ 1 hàm + out-param như dự tính ban đầu:
  - `LoadSymbolTFFromJSON(filename, out SJsonSymbolTF &out_symbols_tf[])` — populate `m_symbol_tf[]`, tạo Series+Pattern registry, trả `out_symbols_tf[]` (có buy/sell) ra ngoài.
  - `LoadIndicatorTemplateFromJSON(filename, out SJsonIndicatorEntry &out_entries[])` — populate `m_indicator_template[]`, tạo Indicator instance, trả `out_entries[]` (có buy/sell/sound/message) ra ngoài.
  - Mỗi hàm tự `ParseIndicatorConfigFile` riêng (đọc file 2 lần, chấp nhận đổi lấy tách bạch). Gọi tuần tự đúng thứ tự (SymbolTF trước) trong `OnInitEvent`.
- [x] `OnInitEvent` (`TimeSeriesEngine_Lifecycle.mqh`) đổi signature, thêm `out_entries[]`/`out_symbols_tf[]`, chỉ điền khi thực sự Load lần đầu (nhánh `ind_total==0`).
- [x] `SaveConfigurationToJSON`: bỏ hardcode `true`, nhận thêm `tmpl_handle[]` + `tmpl_buy/sell/sound/message[]` từ Layer 2, match theo **`Handle()`** (đổi từ dự tính ban đầu type+params_key — handle là join key sẵn có, gọn hơn, khớp quy ước `LineRepresentsIndicator` đã dùng).

### Layer 2 (`CGUIPannel`)
- [x] **Không tạo struct mới** `SIndicatorTemplateSetting`/`SSymbolTFSetting` như dự tính — tận dụng thẳng `SJsonIndicatorEntry`/`SJsonSymbolTF` (đã có sẵn trong `IndicatorConfigLoader.mqh`, include thẳng vào `GUIPannel.mqh`) làm kiểu lưu trữ luôn, vì đã chứa đúng field cần. Field mới: `m_indicator_template_setting[]` (kiểu `SJsonIndicatorEntry`), `m_symbol_tf_Setting[]` (kiểu `SJsonSymbolTF`).
- [x] Hàm mới `SetLoadedIndicatorSettings(entries[], symbols_tf[])` — copy thẳng data Layer 1 vừa trả ra vào 2 field trên. Gọi 1 lần từ EA's `OnInit()`, TRƯỚC `mGUIPannel.OnInitEvent(...)`.
- [x] `BuildTemplateBuySellSoundMessageArrays()` (mẫu theo `BuildSymbolTFBuySellArrays`) — đọc checkbox thật cột 2/3/5/6 + `Handle()` mỗi indicator → truyền vào `SaveConfigurationToJSON(...)`.
- [x] `ApplyLoadedIndicatorBuySell` đổi nguồn đọc sang `m_indicator_template_setting[]` (match qua `BuildTemplateMatchKey` có sẵn + params_key tự build lại theo đúng cách Layer 1 build).
- [x] `ApplyLoadedSymbolTFSettings` (`GUIPannel_TabSettingSymbolTF.mqh`) đổi nguồn đọc sang `m_symbol_tf_Setting[]`.

### Threading qua `OnInit()` (phát sinh trong lúc code — blast radius nhỏ hơn lo ban đầu)
- [x] `timeSeriesEngine.OnInitEvent(...)` và `mGUIPannel.OnInitEvent(...)` hoá ra được gọi TRỰC TIẾP, TUẦN TỰ từ CÙNG 1 chỗ (`EA Using Combination Lib V8.mq5:OnInit()`) — không phải xuyên nhiều lớp như lo lúc đầu. Chỉ cần sửa đúng 1 file `.mq5` để khai báo `loaded_entries[]`/`loaded_symbols_tf[]`, truyền qua `timeSeriesEngine.OnInitEvent(...)`, rồi gọi `mGUIPannel.SetLoadedIndicatorSettings(...)` trước `mGUIPannel.OnInitEvent(...)`.

### Phát hiện phụ (KHÔNG do refactor này gây ra — pre-existing) — ✅ ĐÃ XÁC NHẬN KHÔNG PHẢI BUG (2026-08-17)
`BuildTemplateMatchKey`/`BuildIndicatorLabel` đã có implementation đầy đủ — `Services/DELib/TimeseriesDELib.mqh:345-379` (`BuildIndicatorLabel`) và `:387-415` (`BuildTemplateMatchKey`, kèm doc comment giải thích lý do tách riêng: dùng 8 số thập phân khớp đúng format JSON đã lưu, khác `BuildIndicatorLabel` dùng 2 số thập phân cho hiển thị). Cả 2 là **free function của Library**, không phải method của `CGUIPannel` — nên declaration bị comment out ở `GUIPannel.mqh:236-237` là ĐÚNG (không cần khai báo trong class vì không phải member), không phải dấu hiệu thiếu code. Không cần Anhnt làm gì thêm ở mục này.

## Vấn đề liên quan phát sinh: Column 4 (Show/Hide on Chart) — ĐÃ CHỐT: giữ nguyên, KHÔNG đưa vào JSON

**Kết luận (Anhnt, 2026-08-16)**: cột này là **live mirror 2 chiều với chart thật**, không phải giá trị đã lưu — đọc thẳng `IsIndicatorShownOnChart()` (hỏi chart "đang gắn thật không") mỗi lần hiện bảng, và click thì gắn/gỡ thật trên chart ngay (`OnClickToggleShowIndicatorOnChart`). Chart chính là nguồn sự thật duy nhất — thêm 1 lớp lưu JSON song song sẽ dư thừa, thậm chí có thể lệch với chart thật nếu 2 nguồn không đồng bộ kịp. **Giữ nguyên như hiện tại, không đụng gì.**

Bối cảnh: có 1 `Indicator-Template` ở Layer 1 (registry identity). Bên `CGUIPannel`, `m_table_indicator_template` có Column 4 riêng cho việc này (`GUIPannel_TabSettingIndicator.mqh:178-181`):
```cpp
//Column 4 Setting for Visiable on Chart
 uint resource_indices_visiable[] = {IMAGE_RESOURCE_BMP16_VISIBLE_PNG};
 m_table_indicator_template.SetHeaderImage(4, resource_indices_visiable);
 m_table_indicator_template.SetHeaderText(4, "");   //On to show on Chart
```
Ý nghĩa: lúc thích thì cho hiện Indicator đó lên chart, lúc không thích thì ẩn đi cho đỡ rối. **Hiện tại state này KHÔNG được lưu JSON** (grep xác nhận không có field `"show"` nào trong code Save/Load) — nó là live, tự suy ra mỗi lần từ `IsIndicatorShownOnChart()` (kiểm tra thực tế có đang gắn trên chart hay không), khác hẳn Buy/Sell/Sound/Message (có lưu, dù đang bug hardcode).

*(2 rủi ro "Insert trùng khi ẩn" / "đồng bộ tham số khi đổi màu" được nêu ra lúc đang cân nhắc persist — không còn áp dụng vì đã chốt KHÔNG persist. Giữ lại đây làm ghi chú lịch sử, không cần xử lý gì thêm.)*

## Câu hỏi mở — ĐÃ CHỐT CẢ 2

- [x] **Layer 2 tự parse JSON riêng, hay Layer 1 parse 1 lần rồi trả buy/sell/sound/message ra ngoài qua tham số/return ngay lúc Load?** → **Chốt: Cách B.** Layer 1 (`LoadSymbolTFFromJSON`/`LoadIndicatorTemplateFromJSON`) đằng nào cũng phải đọc JSON lúc `OnInit` để tạo Series/Indicator — tận dụng luôn lần đọc đó, đưa buy/sell/sound/message ra ngoài ngay lúc parse (qua tham số/return), KHÔNG lưu lại thành field của class.
- [x] **Tick checkbox tự lưu JSON hay chỉ khi bấm Save?** → Giữ nguyên hành vi cũ: tick chỉ update live bridge (`SyncIndicatorTemplateSettingToBridge`/`ResetSignalBridge`), KHÔNG tự ghi JSON — chỉ ghi khi bấm nút Save (giờ Save đã đọc đúng checkbox thật nhờ `BuildTemplateBuySellSoundMessageArrays`, không còn hardcode `true` nữa).

## File đã sửa (2026-08-16)
- `Artyom Trishkin\TimeSeriesEngine.mqh` — struct `SSymbolTF`/`SIndicatorTemplate`, field `m_symbol_tf[]`/`m_indicator_template[]`, declare `LoadSymbolTFFromJSON`/`LoadIndicatorTemplateFromJSON`/`OnInitEvent`/`SaveConfigurationToJSON` mới
- `Artyom Trishkin\TimeSeriesEngine_JSONConfig.mqh` — `LoadConfigurationFromJSON` tách thành `LoadSymbolTFFromJSON`+`LoadIndicatorTemplateFromJSON`; `SaveConfigurationToJSON` bỏ hardcode, match theo `Handle()`; xoá `GetLoadedSymbolTFSettings`/`GetLoadedTemplateSettings`
- `Artyom Trishkin\TimeSeriesEngine_Lifecycle.mqh` — `OnInitEvent` gọi 2 hàm Load mới đúng thứ tự, thread out-param
- `EA Using Combination Lib V8.mq5` — `OnInit()`: khai báo `loaded_entries[]`/`loaded_symbols_tf[]`, truyền qua `timeSeriesEngine.OnInitEvent`, gọi `mGUIPannel.SetLoadedIndicatorSettings(...)` trước `mGUIPannel.OnInitEvent`
- `Anatoli Kazharski\GUIPannel.mqh` — include `IndicatorConfigLoader.mqh`, field `m_indicator_template_setting[]`/`m_symbol_tf_Setting[]`, declare `SetLoadedIndicatorSettings`/`BuildTemplateBuySellSoundMessageArrays`
- `Anatoli Kazharski\GUIPannel_JSONConfig.mqh` — impl `SetLoadedIndicatorSettings`; `SaveGUIConfigToJSON` gọi `BuildTemplateBuySellSoundMessageArrays` + truyền đủ tham số mới vào `SaveConfigurationToJSON`
- `Anatoli Kazharski\GUIPannel_TabSettingIndicator.mqh` — `ApplyLoadedIndicatorBuySell` đổi nguồn đọc; thêm `BuildTemplateBuySellSoundMessageArrays`
- `Anatoli Kazharski\GUIPannel_TabSettingSymbolTF.mqh` — `ApplyLoadedSymbolTFSettings` đổi nguồn đọc
- `Artyom Trishkin\IndicatorConfigLoader.mqh` — KHÔNG sửa gì, chỉ tận dụng struct sẵn có
- `README.md` — mục 6, bảng sở hữu JSON section (dòng 93-107) — tham khảo, không sửa
