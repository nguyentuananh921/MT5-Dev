# Sync Indicator-Template giữa các Layer — Plan tổng hợp

> Bản tổng hợp 2026-08-17 (Claude), sau nhiều vòng trao đổi với Anhnt. Đây là bản THAY THẾ các bản
> nháp trước — trình bày đúng kiến trúc CUỐI CÙNG đã chốt, không phải nhật ký từng bước tranh luận.
> CHƯA code gì — đây vẫn là Plan, chờ Anhnt duyệt trước khi bắt tay.

## 1. Concept (không đổi, đã chốt từ đầu)

- **Layer 1**: có MỘT Indicator-Template (identity = type + params). Symbol/TF không thuộc identity.
- **Layer 2**: có 1 Table đại diện đúng Indicator-Template đó, cộng thêm Setting cho Layer 3 (hiển
  thị Chart: Show/Buy-Sell marker) và Layer 4 (File).
- **Layer 4 (File)** có 2 thứ: JSON config (`Config_Setting.json`, section `"Indicator_Templates"`)
  và SignalBridge (`CSignalBridgeWriter`).
- Indicator phân biệt nhau bởi **type (name) + Parameter** — identity duy nhất, dùng xuyên suốt.

## 2. Kiến trúc CUỐI CÙNG đã chốt

```
Layer 1 (CTimeSeriesEngine)          Layer 2 (CGUIPannel)
┌─────────────────────────┐          ┌───────────────────────────────┐
│ m_indicator_template[]   │          │ m_indicator_template_setting[] │
│  = SIndicatorTemplate    │          │  = SJsonIndicatorEntry (có sẵn)│
│  {type, params_key}      │          │  {type, params[], buy, sell,   │
│  SỐNG suốt LifeCycle,    │◄────────►│   sound, message}               │
│  update mỗi khi Template │  match   │  SỐNG suốt LifeCycle, nguồn     │
│  tạo/xoá lúc runtime     │  key     │  sự thật DUY NHẤT cho Layer 2   │
└─────────────────────────┘          └───────────────────────────────┘
         │                                        │
         └──────────────┬─────────────────────────┘
                         ▼
              Save xuống JSON = combine 2 nguồn theo key
```

Cả 2 array đều **sống suốt LifeCycle** (không phải snapshot dùng 1 lần), và là **nguồn sự thật DUY
NHẤT** của Layer mình — mọi nơi khác cần identity/setting phải đọc từ đây, không tự tính/tự giữ riêng.

### Layer 1 — `m_indicator_template[]` phải nâng cấp thành sống (hiện tại CHƯA đúng)
**Vấn đề hiện tại**: chỉ ghi ĐÚNG 1 lần lúc JSON load (`TimeSeriesEngine_JSONConfig.mqh:93-94`,
trong `LoadIndicatorTemplateFromJSON`) — Template mới thêm lúc runtime (Add/Import Chart) KHÔNG
được cập nhật vào đây.

**Cần sửa**: update LIVE tại đúng entry point tạo/xoá Template:
- Tạo: `AddNewIndicatorToAllSeries()` (`TimeSeriesEngine_Indicator.mqh`) — entry point DUY NHẤT,
  dùng chung bởi nút Add (`AddIndicatorInstance`) LẪN Import từ Chart (`ImportForeignChartIndicators`)
  → sửa 1 chỗ, cover cả 2 nguồn.
- Xoá: chỗ tương ứng khi Template bị xoá (`OnClickRemoveIndicator` phía Layer 2, cần propagate xuống
  Layer 1).

### Layer 2 — `m_indicator_template_setting[]` đổi VAI TRÒ, không đổi tên/kiểu
Field đã tồn tại sẵn đúng kiểu cần (`SJsonIndicatorEntry`: `type`, `params[]`, `buy`, `sell`, `sound`,
`message` — `IndicatorConfigLoader.mqh:23-31`). Chỉ cần đổi từ "snapshot JSON dùng 1 lần" thành
"sống suốt LifeCycle":
- Seed từ JSON lúc `OnInitEvent` (như cũ).
- Checkbox toggle (Buy/Sell/Sound/Message) → cập nhật THẲNG vào field tương ứng của
  `m_indicator_template_setting[row]`, không chỉ đổi icon CTable.
- Lúc Save → đọc THẲNG từ đây, không cần đọc lại icon CTable tươi qua
  `BuildTemplateBuySellSoundMessageArrays()` nữa.

### Save xuống JSON = combine Layer 1 + Layer 2 theo key
Join `m_indicator_template[]` (identity) với `m_indicator_template_setting[]` (setting) theo
`type`+`params_key` → ra entry JSON hoàn chỉnh. Đúng nguyên tắc README (Layer 1 sở hữu identity
trong `"Indicator_Templates"`, Layer 2 sở hữu phần Setting).

## 2b. NGUYÊN TẮC Single Source Of Truth — ÁP DỤNG XUYÊN SUỐT, MỌI Method mới/sửa (Anhnt, 2026-08-18)

**Phát biểu**: Từ khi 2 Property mới (`m_indicator_template[]` ở Layer 1, `m_indicator_template_setting[]`
ở Layer 2) sống suốt LifeCycle, **MỌI method** cần identity (type+params) hoặc setting
(buy/sell/sound/message) của Indicator-Template **PHẢI đọc thẳng từ 2 Property này** — không được tự
suy ra/dedup lại bằng cách khác. Cụ thể CẤM 3 kiểu dưới đây (cả 3 đều đã từng là bug thật, tìm thấy
trong buổi 2026-08-18):

| Kiểu cấm | Ví dụ đã fix | Thay bằng |
|---|---|---|
| Scan `CIndicatorsCollection` lọc theo symbol/TF của chart HIỆN TẠI để suy ra "danh sách Template" | `SaveConfigurationToJSON` (dùng `::Symbol()`/`::Period()`) | Loop thẳng `m_indicator_template[]` |
| Lấy 1 instance "đại diện" (VD `all.At(0)`) rồi lọc lại theo symbol/TF của nó | `AddAllIndicatorsToNewSeries` | Loop thẳng `m_indicator_template[]` |
| Dùng `ArraySize(m_table_indicator_ptrs)`/property CŨ làm baseline đếm row | `AddIndicatorInstance`, `RemoveIndicatorInstance`, `RefreshTableIndicator`, `RefreshIndicatorTableShowColumn`, `OwnedInstanceOfLine` | `ArraySize(m_indicator_template_setting)` |

**Khi cần MqlParam[] thật** (JSON output, tạo instance mới...) — `m_indicator_template[]` chỉ giữ
string (`type_key`,`params_key`), không đủ — vẫn phải tìm 1 instance sống đại diện, nhưng tìm trong
**TOÀN BỘ** `m_IndicatorsCollection.GetList()` (mọi symbol/TF), KHÔNG giới hạn theo 1 symbol/TF cụ thể
nào (đó chính là nguồn gốc bug — giới hạn theo chart hiện tại làm kết quả phụ thuộc chart nào đang mở).

**Ngoại lệ HỢP LỆ** (không phải vi phạm nguyên tắc): những chỗ genuinely cần instance của
**CHART/SYMBOL/TF HIỆN TẠI** — không phải để suy ra "danh sách Template" mà để lấy pointer THẬT đang
hoạt động trên chart đó (hiển thị, check Signal, v.v.) — `RefreshTableIndicator`/`GetIndicatorForRow`
(build bảng Layer 2 cho chart hiện tại), `CheckIndicatorAlerts`/`SignalBridgeWriter` (check Signal
từng TF), `GUIPannel_CandleInfo`/`GUIPannel_TabMonitor` (hiển thị popup). Phân biệt: nguyên tắc cấm
**suy ra danh sách/số lượng Template** từ 1 chart cụ thể — không cấm việc tra cứu instance của chart
hiện tại khi mục đích THẬT SỰ là "chart hiện tại", không phải "toàn bộ Template".

**Còn lại cần tiếp tục áp dụng nguyên tắc này** (chưa làm, để dành):
- Đợt 3e — xoá hẳn `m_table_indicator_ptrs[]`/`m_table_indicator_names[]` (property cũ cuối cùng).
- Đợt 4 — `CSignalBridgeWriter.m_template_ptrs[]/buy[]/sell[]` (bản sao ArrayCopy riêng, tự đồng bộ
  tay) → đọc tham chiếu thẳng `m_indicator_template_setting[]`.
- Dọn Library — `CIndicatorsCollection::TemplateExists()` giờ dead code (0 call site trong EA), cần
  bàn riêng trước khi sửa (Library file).

## 3. Hệ quả — những gì bị loại bỏ vì đã có nguồn sự thật chung

| Cái bị bỏ | Vì sao thừa | Thay bằng |
|---|---|---|
| `m_table_indicator_ptrs[]` | Phải RE-SYNC toàn bộ mỗi khi đổi symbol/TF chart (CHARTCHANGE) qua vòng lặp match LABEL TEXT tốn kém (`GUIPannel_TabSettingIndicatorTable.mqh:85-108`) — không cần nếu chỉ giữ identity | Tra cứu `CIndicatorDE*` của symbol/TF hiện tại TẠI CHỖ khi cần, qua `GetListIndBySymbol()` + match type/params |
| `m_table_indicator_names[]` | Trùng dữ liệu cột 0 của chính CTable | `m_table_indicator_template.GetValue(0,row)` |
| `CIndicatorsCollection::TemplateExists()` + `IsEqualMqlParamArrays()` | Loop qua TOÀN BỘ instance (`m_list`, VD 2 symbol×4TF+3TF×5 indicator = 35 entry) để check trùng — lặp lại cùng 1 phép so sánh nhiều lần vì Template vốn symbol/TF-invariant | 1 method nhỏ trên `CTimeSeriesEngine` (VD `TemplateExists(type_key,params_key)`) — loop `m_indicator_template[]` (chỉ 5 entry trong VD trên), so string. Không còn là "dedup logic" riêng nữa, chỉ là tra-cứu-tồn-tại-key bình thường |
| `CheckIndicatorAlerts` tự build `tmpl_type_key[]/params_key[]` mỗi lần gọi (`GUIPannel_SoundAndMessageAlerts.mqh:51-58`) | Tính lại từ đầu, có thể mỗi tick | Đọc thẳng từ `m_indicator_template[]`/`m_indicator_template_setting[]` đã sống sẵn |
| `CSignalBridgeWriter.m_template_ptrs[]/m_template_buy[]/m_template_sell[]` | Bản sao riêng, đồng bộ tay qua `ArrayCopy()` mỗi khi `SyncIndicatorTemplateSettingToBridge()` chạy — quên gọi là lệch dữ liệu (đã từng là bug thật) | Đọc tham chiếu thẳng từ `m_indicator_template_setting[]` mỗi lần cần — **đợt sau**, đổi kiến trúc lớn hơn (Bridge vốn thiết kế độc lập), cân nhắc kỹ riêng |

### Layer 3 (Chart) ↔ Layer 1/2 — 3 UseCase đồng bộ, gom vào 1 điểm vào `SynIndicatorOnChart(id)`

**Bối cảnh** (Anhnt, 2026-08-18): Layer 1 giữ Indicator xác định bởi type+params trong
`m_indicator_template[]`. Layer 2 trỏ vào cùng Template đó + `m_indicator_template_setting[]` (có cột
On/Off hiển thị trên Chart). Khi User thao tác tay trên Chart (Insert/Remove/đổi Properties), có đúng
3 UseCase, và **cả 3 đều đã đúng trong code hiện tại** (xác nhận 2026-08-18, xem Action Log bên dưới)
— việc gộp vào `SynIndicatorOnChart(id)` là THUẦN tổ chức lại code, không đổi hành vi:

| # | UseCase | Việc phải làm | Cơ chế hiện tại |
|---|---|---|---|
| 1 | User OFF checkbox Show (ẩn khỏi Chart) rồi tay Insert LẠI đúng Indicator đó (đã có sẵn trong Template) | KHÔNG Add gì ở Layer 1 — chỉ bật lại checkbox Show ở Layer 2 | `ImportForeignChartIndicators()` chặn bằng 2 lớp (handle đã Layer1-owned, hoặc `TemplateExists()` true) → không Add trùng; `RefreshIndicatorTableShowColumn()` (chạy cuối `SynIndicatorOnChart`, mọi nhánh) tự re-truth checkbox Show LIVE — `IsIndicatorShownOnChart`/`LineRepresentsIndicator` fallback so type+params (không chỉ handle) nên đúng dù MT5 cấp handle mới cho lần Insert tay đó |
| 2 | User chỉ đổi mầu/style (không đổi Parameter) | KHÔNG làm gì cả 2 Layer | Event `IND_CHANGE` (Library `Chart/ChartWnd.mqh::IndicatorsChangeCheck`) chỉ bắn khi TÊN Indicator biến mất khỏi window tracking (= handle/param thật sự đổi) — đổi màu/style thuần không đổi tên/handle nên event này KHÔNG bắn, không cần code EA chủ động lọc |
| 3 | User nhìn thấy Indicator trên Chart và đổi Parameter thật | Delete Template cũ ở Layer 1, Tạo Template mới với Parameter mới | Nhánh `IND_CHANGE` trong `SynIndicatorOnChart` (thân cũ của `HandleChartIndicatorChange`) — `OnClickRemoveIndicator()` (Remove template cũ, mọi symbol/TF) + `AddIndicatorInstance()` (Add template mới, mọi symbol/TF) |

**Điểm vào duy nhất**: `SynIndicatorOnChart(const long id)` (`GUIPannel_TabSettingIndicator.mqh`), gọi
từ `OnChartEvent` (`GUIPannel_Lifecycle.mqh`) cho cả 3 event `CHART_WND_IND_ADD/DEL/CHANGE`. Nhánh
`ADD` → `ImportForeignChartIndicators()` (UseCase 1; hàm này còn 1 nơi gọi riêng lúc `OnInitEvent` -
quét toàn bộ Chart lúc khởi động, không có `id` cụ thể nên không gộp được). Nhánh `CHANGE` → thân cũ
`HandleChartIndicatorChange` inline (UseCase 3, hàm cũ đã xoá hẳn vì chỉ có 1 nơi gọi). `DEL` không
khớp nhánh nào — chỉ chạy `RefreshIndicatorTableShowColumn()` cuối hàm (chạy cho MỌI nhánh, kể cả
UseCase 2 không hề vào tới đây). `IsIndicatorShownOnChart()` (đọc-only, cột Show) không đổi — vẫn
đúng thiết kế live-mirror, không persist.

## 4. Đổi tên `SIndicatorCatalogItem.type` → `ind_type` (thống nhất tên Struct ↔ Class)

**Lý do**: `SIndicatorCatalogItem.type` (ENUM_INDICATOR) và tham số `ind_type` trong constructor
`CIndicatorDE` (`IndicatorDE.mqh:48`) cùng kiểu ENUM_INDICATOR thật, cùng 1 khái niệm — nên thống
nhất tên. (KHÔNG đụng `SJsonIndicatorEntry.type` — đó là string, khái niệm khác, giữ nguyên tên.)

**Phạm vi đã rà đủ, double-check 2 lượt grep khác pattern — 7 chỗ, không sót:**

Library (`Services/DELib/TimeseriesDELib.mqh`):
1. Dòng 16-20 — khai báo struct
2. Dòng 349 — `BuildIndicatorLabel()`
3. Dòng 391 — `BuildTemplateMatchKey()`

EA - Artyom Trishkin:
4. `TimeSeriesEngine_JSONConfig.mqh:107`
5. `TimeSeriesEngine_JSONConfig.mqh:286`

EA - Anatoli Kazharski:
6. `GUIPannel_TabSettingIndicator.mqh:689`
7. `GUIPannel_TabSettingIndicatorTreeView.mqh:84`

**Không đụng**: `GetIndicatorCatalog()` (positional literal, không gọi tên field), comment ở
`GUIPannel.mqh:237-238` (chỉ nhắc tên struct, không đụng field), và bản `SIndicatorCatalogItem` khác
ở `Library\...\Temp\IndicatorCatalog.mqh` — **archival cố ý** (xem memory
`project_temp_folder_convention`: Anhnt move vào `Temp/` có ý bỏ dần, chỉ giữ tra cứu, không active,
verify: 0 `#include` trỏ tới).

## 5. Dead code phát hiện trong lúc rà — `ShortNameToIndicatorType()`

`Services/DELib/TimeseriesDELib.mqh:469` — 0 call site (grep xác nhận cả EA lẫn toàn bộ Library, chỉ
ra đúng dòng khai báo). Bị thay thế bởi `IndicatorParameters(handle,type,params)` (native MQL5, trả
thẳng `ENUM_INDICATOR` chính xác) đang dùng thật ở `ImportForeignChartIndicators`/
`HandleChartIndicatorChange`. An toàn xoá.

Đã rà toàn bộ 13 hàm/struct top-level trong `TimeseriesDELib.mqh` — **chỉ 1 hàm mồ côi này**, không
có ứng viên nào khác.

## 6. Việc cần làm — thứ tự đề xuất

### Đợt 1 — chuẩn bị, ít rủi ro nhất — ✅ CODE XONG (2026-08-17), chờ Anhnt build/test
- [x] Đổi tên `SIndicatorCatalogItem.type` → `ind_type` (7 chỗ, mục 4) - verify lại bằng grep, không sót.
- [x] `ShortNameToIndicatorType()` (mục 5) — CHƯA xoá hẳn, đã comment out kèm note lý do (an toàn theo
      quy ước của Anhnt: comment trước, xoá thật sau khi build/test xác nhận ổn).
- [ ] **Anhnt: compile thử trong MetaEditor, chạy test EA xem có lỗi gì không trước khi đi tiếp Đợt 2.**

### Đợt 2 — nâng Layer 1 lên sống — ✅ CODE XONG (2026-08-17), chờ Anhnt compile/test
- [x] Liệt kê đủ TẤT CẢ nơi Template được tạo/xoá lúc runtime — chỉ đúng 2 entry point:
      **Tạo** = `AddNewIndicatorToAllSeries()` (dùng chung bởi GUI Add / Chart Import / JSON load);
      **Xoá** = `OnClickRemoveIndicator()` (dùng chung bởi click icon X / `HandleChartIndicatorChange`).
- [x] Thêm code update `m_indicator_template[]` vào 2 entry point đó.
- [x] Viết method tồn tại-key mới trên `CTimeSeriesEngine` (thay cho việc loop `m_list` cũ) — loop
      `m_indicator_template[]`, so string `type`/`params_key`.

### Đợt 3 — nâng Layer 2 lên sống, xoá `m_table_indicator_ptrs[]`/`m_table_indicator_names[]`

**Đã liệt kê đủ (2026-08-17), phân theo NHÓM CHỨC NĂNG (không phải theo file) — rộng hơn dự kiến ban đầu:**

- **Nhóm A — Vòng đời row (Add/Remove/Resize/Re-sync CHARTCHANGE)**: `GUIPannel_TabSettingIndicatorTable.mqh`
  (`RefreshIndicatorTable`, `SetIndicatorTableRow`, `OnClickRemoveIndicator`),
  `GUIPannel_TabSettingIndicator.mqh` (`AddIndicatorInstance`). Đây chính là chỗ tốn kém CHARTCHANGE
  đã rà ở mục 3 (bảng "Hệ quả").
- **Nhóm B — Tra cứu ptr theo row cho Show/Hide**: `RefreshIndicatorTableShowColumn`,
  `OnClickToggleShowIndicatorOnChart`.
- **Nhóm C — `ApplyLoadedIndicatorBuySell()`** (`Table.mqh:260-280`) — đọc ptr từng row, build key, so
  với `m_indicator_template_setting[]`. Ứng viên **KHÔNG CẦN TỒN TẠI NỮA** một khi checkbox tự cập
  nhật thẳng vào `m_indicator_template_setting[]` (không cần "apply" gì nếu setting đã sống sẵn).
- **Nhóm D — `BuildTemplateBuySellSoundMessageArrays()`** (`Table.mqh:286-312`) — dùng cho Save, đọc
  ptr + icon CTable tươi. Ứng viên **bỏ hẳn** — Save đọc thẳng từ `m_indicator_template_setting[]`.
- **Nhóm E — `OwnedInstanceOfLine()`** (`Table.mqh:315-324`) — fallback tìm instance theo `line_handle`
  khi `GetIndicatorByHandle` (Layer 1) miss, dùng cho `HandleChartIndicatorChange`.
- **Nhóm F — `CheckIndicatorAlerts()`** (`GUIPannel_SoundAndMessageAlerts.mqh`) — đọc
  `m_table_indicator_ptrs[]` trực tiếp (thuộc Đợt 4 theo tính lại-mỗi-lần-gọi, nhưng cũng phải sửa
  vì ptr array biến mất).
- **Nhóm G — MỚI phát hiện: `SyncIndicatorTemplateSettingToBridge()`** (`GUIPannel_SignalMarkers.mqh:71-88`)
  — build `tmpl_ptrs[]` từ `m_table_indicator_ptrs[]` để đưa `CSignalBridgeWriter.SetTemplateBuySell()`.
  Đổi KIẾN TRÚC Bridge (giữ bản sao qua ArrayCopy) là Đợt 4, nhưng đổi NGUỒN LẤY PTR (vì
  `m_table_indicator_ptrs[]` biến mất) phải làm NGAY ở Đợt 3.

**Cách làm — chia nhỏ thành sub-step, build/test được từng bước:**
- [x] **3a** — Viết 1 hàm tra-cứu-ptr-tại-chỗ DÙNG CHUNG (`GetIndicatorForRow(row)`), thay thế mọi
      chỗ đang đọc `m_table_indicator_ptrs[row]` trực tiếp. Thuần ADDITIVE (không xoá gì).
      ✅ CODE XONG + Anhnt compile/test OK (2026-08-17).

**⚠ XUNG ĐỘT THIẾT KẾ phát hiện lúc chuẩn bị Nhóm A (2026-08-17), ĐÃ GỘP LẠI KẾ HOẠCH:**
`m_indicator_template_setting[]` hiện đóng 2 vai trò không tương thích nếu tách rời:
- **Vai trò CŨ** (đang chạy): snapshot JSON, đánh index theo THỨ TỰ TRONG FILE (`q`), dùng bởi
  `ApplyLoadedIndicatorBuySell()` để match ngược lại từng row qua vòng lặp so key.
- **Vai trò MỚI** (Nhóm A cần): array sống, đánh index theo ROW CỦA BẢNG - y hệt `m_table_indicator_ptrs[]`.

2 cách đánh index này KHÁC NHAU (JSON-order vs row-order, lệch nhau khi có Template thêm mới lúc
runtime hoặc bảng bị sort) — không thể vừa nửa vai trò cũ vừa nửa vai trò mới cùng lúc. **Nhóm A và
Đợt 3c (xoá `ApplyLoadedIndicatorBuySell`) phải làm CHUNG 1 bước, không tách rời được như dự tính ban đầu.**

- [ ] **3b (gộp Nhóm A + Nhóm B + Đợt 3c cũ thành 1 bước)** — làm `m_indicator_template_setting[]`
      sống theo ROW (không còn theo thứ tự JSON):
      - `SetIndicatorTableRow()`/`RefreshTableIndicator()`/`AddIndicatorInstance()`: ghi thêm vào
        `m_indicator_template_setting[row]` (type/params từ indicator, buy/sell/sound/message mặc
        định false - hoặc lấy từ JSON-loaded data nếu trùng key, thay cho việc
        `ApplyLoadedIndicatorBuySell` làm SAU đó như hiện tại).
      - `OnClickRemoveIndicator()`: xoá thêm khỏi `m_indicator_template_setting[]` theo row.
      - Checkbox toggle (Buy/Sell/Sound/Message) ghi thẳng vào `m_indicator_template_setting[row]`.
      - Nhóm B (`RefreshIndicatorTableShowColumn`/`OnClickToggleShowIndicatorOnChart`) đổi sang
        `GetIndicatorForRow(row)`.
      - Xoá `ApplyLoadedIndicatorBuySell()` (không còn cần "apply" gì nữa).
      - Sửa Save đọc thẳng từ `m_indicator_template_setting[]`, xoá
        `BuildTemplateBuySellSoundMessageArrays()`.
- [x] **3d** — Sửa Nhóm E/F/G sang dùng `GetIndicatorForRow()` + `m_indicator_template[]`/
      `m_indicator_template_setting[]`. Gộp luôn việc đổi `ImportForeignChartIndicators`/
      `HandleChartIndicatorChange` sang check với `m_indicator_template[]` mới (mục 3).
      ✅ CODE XONG (2026-08-18), chờ Anhnt compile/test — xem Action Log bên dưới. (Nhóm E thực ra
      đã xong từ Đợt 3b rồi — `OwnedInstanceOfLine()` đổi sang `GetIndicatorForRow()`; `HandleChartIndicatorChange`
      tự nó không gọi `TemplateExists()` nên không cần sửa thêm phần dedup, chỉ `AddIndicatorInstance`/
      `ImportForeignChartIndicators` có.)
- [ ] **3e** — Xoá hẳn `m_table_indicator_ptrs[]`/`m_table_indicator_names[]` (comment trước, xoá sau
      khi build/test ổn, đúng quy ước).

### Đợt 4 — dọn phần còn lại (có thể để sau, rủi ro/độ phức tạp cao hơn)
- [ ] `CheckIndicatorAlerts` — đổi sang đọc identity có sẵn thay vì tự build mỗi lần gọi.
- [ ] `CSignalBridgeWriter` — cân nhắc đổi từ "giữ bản sao qua ArrayCopy" sang đọc tham chiếu thẳng
      (đổi kiến trúc lớn hơn, Bridge vốn thiết kế độc lập — cần bàn riêng kỹ hơn trước khi làm).

Mỗi đợt build/test riêng trước khi qua đợt tiếp theo — refactor xuyên nhiều file, làm cẩn thận.

## Tracker Properties/Method trong `GUIPannel.mqh` (Declaration) — cập nhật liên tục, tránh rác

> Mục đích: mọi Property/Method liên quan Đợt 3 đều phải xuất hiện ở đây với trạng thái rõ ràng, để
> sau này không còn ai nhớ vì sao 1 method/property nằm trong Declaration mà không biết dùng để làm gì.

| Tên | Loại | Trạng thái | Ghi chú |
|---|---|---|---|
| `m_table_indicator_ptrs[]` | Property | 🟡 Đang dùng, SẼ XOÁ (Đợt 3e) | Thay bằng `GetIndicatorForRow(row)` tra cứu tại chỗ |
| `m_table_indicator_names[]` | Property | 🟡 Đang dùng, SẼ XOÁ (Đợt 3e) | Thay bằng `m_table_indicator_template.GetValue(0,row)` |
| `m_settings_cache_state[]` | Property | 🟢 GIỮ NGUYÊN | Không phải identity/setting, thuần dirty-check cache cột Show, không thuộc phạm vi dọn |
| `m_indicator_template_setting[]` | Property | ✅ ĐÃ NÂNG CẤP (Đợt 3b, 2026-08-17) | Từ "snapshot JSON 1 lần" → "sống suốt LifeCycle, nguồn sự thật Layer 2" |
| `GetIndicatorForRow(row)` | Method | ✅ MỚI THÊM (Đợt 3a, 2026-08-17) | `GUIPannel.mqh` decl + `GUIPannel_TabSettingIndicatorTable.mqh` impl - tra cứu ptr tại chỗ theo row, thay `m_table_indicator_ptrs[row]` |
| `ApplyLoadedIndicatorBuySell()` | Method | ✅ ĐÃ COMMENT OUT (Đợt 3b, 2026-08-17) | Logic gộp vào `SetIndicatorTableRow()`, không còn cần "apply" riêng |
| `BuildTemplateBuySellSoundMessageArrays()` | Method | ✅ ĐÃ COMMENT OUT (Đợt 3b, 2026-08-17) | Save đọc thẳng từ `m_indicator_template_setting[]` trong `SaveGUIConfigToJSON` |
| `OwnedInstanceOfLine()` | Method | ✅ ĐÃ SỬA (Đợt 3b) | Đổi sang `GetIndicatorForRow(row)` |
| `SyncIndicatorTemplateSettingToBridge()` | Method | ✅ ĐÃ SỬA (Đợt 3d, 2026-08-18) | ptr đổi sang `GetIndicatorForRow(row)`, buy/sell đọc thẳng `m_indicator_template_setting[row]` |
| `CheckIndicatorAlerts()` | Method | ✅ ĐÃ SỬA (Đợt 3d, 2026-08-18) | Đọc `tmpl_type_key/params_key`+sound/message thẳng từ `m_indicator_template_setting[row]`, không rebuild qua `BuildTemplateMatchKey`/đọc icon CTable mỗi lần gọi nữa. Bridge's own `ArrayCopy` copy (`m_template_ptrs[]` etc.) vẫn còn — đó là Đợt 4 |
| `AddIndicatorInstance()` dedup check | - | ✅ ĐÃ SỬA (Đợt 3d, 2026-08-18) | `m_IndicatorsCollection.TemplateExists(type,params)` → `m_time_series_engine.TemplateExists(type_key,params_key)` |
| `ImportForeignChartIndicators()` dedup check | - | ✅ ĐÃ SỬA (Đợt 3d, 2026-08-18) | Same swap as above |
| `RefreshTableIndicator()` | Method | ✅ ĐÃ SỬA (Đợt 3b) | Snapshot `old_setting[]` local + resize `m_indicator_template_setting[]` đồng bộ |
| `SetIndicatorTableRow()` | Method | ✅ ĐÃ SỬA (Đợt 3b) | Đổi signature (+`old_setting[]`), ghi đủ `m_indicator_template_setting[row]` |
| `OnClickRemoveIndicator()` | Method | ✅ ĐÃ SỬA (Đợt 3b) | Shift-xoá `m_indicator_template_setting[]` đồng bộ, dùng `GetIndicatorForRow` |
| `AddIndicatorInstance()` | Method | ✅ ĐÃ SỬA (Đợt 3b) | Resize + gọi `SetIndicatorTableRow` với `old_setting[]` rỗng |
| `RefreshIndicatorTableShowColumn()` | Method | ✅ ĐÃ SỬA (Đợt 3b) | Đổi sang `GetIndicatorForRow(row)` |
| `OnClickToggleShowIndicatorOnChart()` | Method | ✅ ĐÃ SỬA (Đợt 3b) | Đổi sang `GetIndicatorForRow(row)` |
| `OnClickToggleBuySignal()`/`SellSignal()` | Method | ✅ ĐÃ SỬA (Đợt 3b) | Ghi thêm vào `m_indicator_template_setting[row]` |
| `OnClickToggleSoundAlert()`/`MessageAlert()` | Method | ✅ MỚI THÊM (Đợt 3b) | Cột 5/6 trước đây chưa có handler riêng |
| `SaveConfigurationToJSON()` (Layer 1) | Method | ✅ ĐÃ SỬA (Đợt 3b) | Match Handle() → match (type_key,params_key) |
| `SaveGUIConfigToJSON()` | Method | ✅ ĐÃ SỬA (Đợt 3b) | Đọc thẳng `m_indicator_template_setting[]`, không gọi `BuildTemplateBuySellSoundMessageArrays` |

**Quy tắc cập nhật tracker**: mỗi khi 1 dòng đổi trạng thái (VD từ "CẦN SỬA" → "ĐÃ SỬA"), cập nhật NGAY
trong bảng này, không để tích tụ rồi quên.

## Action Log — Đợt 3b (2026-08-17, code xong, chờ Anhnt compile/test)

**Xác nhận thiết kế cuối (Anhnt)**: KHÔNG thêm field permanent thứ 2 (`m_json_loaded_snapshot[]`) -
dùng biến LOCAL copy `old_setting[]` lấy từ chính `m_indicator_template_setting[]` hiện tại ngay đầu
`RefreshTableIndicator()`, trước khi resize/ghi đè nó. Cách này còn tự sửa đúng 1 lỗi tiềm ẩn: field
permanent cố định sẽ làm mất mọi lần user tick checkbox sau lần rebuild đầu tiên; local copy từ
array HIỆN TẠI (đã sống) thì luôn đúng dù rebuild lần 1 hay lần N.

**File đã sửa (9 file):**
1. `Services/DELib/TimeseriesDELib.mqh` (Library) — thêm `BuildIndicatorParamsText()` (params[] dạng
   mảng text, tách từ logic `BuildTemplateMatchKey`); refactor `BuildTemplateMatchKey` (bản
   type+params) gọi xuống hàm mới, tránh trùng logic.
2. `Artyom Trishkin/TimeSeriesEngine.mqh` — đổi signature `SaveConfigurationToJSON`:
   `tmpl_handle[]` (int) → `tmpl_type_key[]`+`tmpl_params_key[]` (string).
3. `Artyom Trishkin/TimeSeriesEngine_JSONConfig.mqh` — implementation `SaveConfigurationToJSON` đổi
   match Handle() → match `(type_key,params_key)` qua `BuildTemplateMatchKey`.
4. `Anatoli Kazharski/GUIPannel.mqh` — thêm khai báo `OnClickToggleSoundAlert`/`MessageAlert` mới;
   đổi signature `SetIndicatorTableRow` (+ `SJsonIndicatorEntry &old_setting[]`); comment out khai báo
   `ApplyLoadedIndicatorBuySell`/`BuildTemplateBuySellSoundMessageArrays`.
5. `Anatoli Kazharski/GUIPannel_TabSettingIndicatorTable.mqh` (file trọng tâm):
   - `RefreshTableIndicator()`: snapshot `old_setting[]` LOCAL trước khi resize `m_indicator_template_setting[]`
     (structural rebuild path); resize thêm ở path count==0.
   - `SetIndicatorTableRow()`: gộp logic `ApplyLoadedIndicatorBuySell` vào (tra `old_setting[]` theo
     type_key/params_key), ghi checkbox theo giá trị tra được (không còn hardcode OFF), ghi
     `m_indicator_template_setting[row]` đầy đủ.
   - `RefreshIndicatorTableShowColumn()`, `OnClickToggleShowIndicatorOnChart()`, `OwnedInstanceOfLine()`:
     đổi sang `GetIndicatorForRow()` thay vì đọc `m_table_indicator_ptrs[row]` trực tiếp.
   - `OnClickToggleBuySignal()`/`SellSignal()`: ghi thêm vào `m_indicator_template_setting[row]`.
   - Thêm mới `OnClickToggleSoundAlert()`/`OnClickToggleMessageAlert()`.
   - `OnClickRemoveIndicator()`: build key từ `GetIndicatorForRow()`; shift-xoá thêm
     `m_indicator_template_setting[]` trong vòng lặp dồn row.
   - Comment out (không xoá) `ApplyLoadedIndicatorBuySell()` + `BuildTemplateBuySellSoundMessageArrays()`.
6. `Anatoli Kazharski/GUIPannel_TabSettingIndicator.mqh` (`AddIndicatorInstance`) — resize thêm
   `m_indicator_template_setting[]`, gọi `SetIndicatorTableRow` với `old_setting[]` RỖNG (row mới từ
   nút Add không có gì để carry-forward).
7. `Anatoli Kazharski/GUIPannel_Lifecycle.mqh` — comment out lời gọi `ApplyLoadedIndicatorBuySell()`
   (xác nhận: `UpdateGUI(true)` đã gọi `RefreshTableIndicator()` ngay trước đó, nên logic mới đã chạy
   rồi, không cần gọi thêm); thêm dispatch click cột 5/6 → `OnClickToggleSoundAlert`/`MessageAlert`.
8. `Anatoli Kazharski/GUIPannel_JSONConfig.mqh` (`SaveGUIConfigToJSON`) — đọc thẳng
   `m_indicator_template_setting[]` build `tmpl_type_key[]`/`tmpl_params_key[]`/`tmpl_buy/sell/sound/message[]`,
   không gọi `BuildTemplateBuySellSoundMessageArrays` nữa.

**Verify đã làm**: grep xác nhận không còn call site nào gọi `SetIndicatorTableRow` với signature cũ
(2 tham số), không còn nơi nào gọi `ApplyLoadedIndicatorBuySell()`/`BuildTemplateBuySellSoundMessageArrays()`
active (chỉ còn trong comment), không còn `tmpl_handle` sót trong code. `#ifndef`/`#endif` cân đối ở
cả 9 file (Library + 8 file EA).

**Chưa làm lúc đó** (Đợt 3d/3e): `CheckIndicatorAlerts()`, `SyncIndicatorTemplateSettingToBridge()`
(Nhóm F/G) vẫn đọc `m_table_indicator_ptrs[]` trực tiếp — chưa đổi. `ImportForeignChartIndicators`/
`AddIndicatorInstance` chưa đổi dedup check sang `m_indicator_template[]` mới. `m_table_indicator_ptrs[]`/
`m_table_indicator_names[]` CHƯA xoá (vẫn cần cho Nhóm F/G và vài chỗ đọc row count).

**Kết quả**: chờ Anhnt compile/test.

## Action Log — Đợt 3d (2026-08-18, code xong, chờ Anhnt compile/test)

**Phạm vi**: Nhóm F (`CheckIndicatorAlerts`), Nhóm G (`SyncIndicatorTemplateSettingToBridge`), và đổi
cơ chế dedup ở 2 cửa tạo Template (`AddIndicatorInstance`, `ImportForeignChartIndicators`) từ
`m_IndicatorsCollection.TemplateExists(type,params)` (loop toàn bộ instance symbol/TF trong Layer 1,
~35 entry cho ví dụ 2 symbol × 3.5 TF × 5 template) sang `m_time_series_engine.TemplateExists(type_key,params_key)`
(loop `m_indicator_template[]` identity-only, ~5 entry cùng ví dụ). Nhóm E (`OwnedInstanceOfLine`) hoá
ra đã xong từ Đợt 3b rồi, không cần sửa gì thêm ở đây. `HandleChartIndicatorChange` tự nó KHÔNG gọi
`TemplateExists()` (chỉ dùng `OwnedInstanceOfLine`/`GetIndicatorByHandle`, đã đúng cơ chế mới từ 3b),
nên không có gì để sửa thêm ở function đó riêng.

**File đã sửa (4 file):**
1. `Anatoli Kazharski/GUIPannel_TabSettingIndicator.mqh`:
   - `AddIndicatorInstance()`: build `dedup_type_key`/`dedup_params_key` qua `BuildTemplateMatchKey(type,params,...)`
     rồi check `m_time_series_engine.TemplateExists(...)` thay vì `m_IndicatorsCollection.TemplateExists(type,params)`.
   - `ImportForeignChartIndicators()`: cùng kiểu swap, build `import_type_key`/`import_params_key` rồi
     check qua `m_time_series_engine.TemplateExists(...)`.
2. `Anatoli Kazharski/GUIPannel_SoundAndMessageAlerts.mqh` (`CheckIndicatorAlerts`, Nhóm F):
   - `rows` đổi nguồn: `ArraySize(m_table_indicator_ptrs)` → `ArraySize(m_indicator_template_setting)`.
   - Precompute `tmpl_type_key[]/params_key[]`: đọc thẳng `m_indicator_template_setting[row].type`
     + join `params[]` bằng dấu phẩy, thay vì gọi `BuildTemplateMatchKey(tmpl_ptr,...)` mỗi lần.
   - `sound_on`/`message_on`: đọc thẳng `m_indicator_template_setting[row].sound/.message` thay vì
     `m_table_indicator_template.SelectedImageIndex(5/6,row)`.
3. `Anatoli Kazharski/GUIPannel_SignalMarkers.mqh` (`SyncIndicatorTemplateSettingToBridge`, Nhóm G):
   - `tmpl_total` đổi nguồn sang `ArraySize(m_indicator_template_setting)`.
   - `tmpl_ptrs[row]`: `m_table_indicator_ptrs[row]` → `GetIndicatorForRow(row)`.
   - `tmpl_buy[row]`/`tmpl_sell[row]`: đọc thẳng `m_indicator_template_setting[row].buy/.sell` thay vì
     `SelectedImageIndex(2/3,row)`. (Bridge's own `ArrayCopy` copy trong `CSignalBridgeWriter` không đụng -
     đổi kiến trúc đó vẫn là Đợt 4.)
4. `Anatoli Kazharski/GUIPannel_Lifecycle.mqh` — sửa lại comment ở chỗ gọi `ImportForeignChartIndicators()`
   (mô tả cũ nhắc `m_IndicatorsCollection.TemplateExists()`, giờ trỏ đúng cơ chế mới).

**Hệ quả phụ phát hiện**: `CIndicatorsCollection::TemplateExists(type,params)` (Library,
`IndicatorsCollection.mqh:587`) giờ KHÔNG còn call site nào trong EA nữa (grep xác nhận) — thành dead
code phía Library. Chưa đụng vào (Library cần bàn riêng trước khi sửa) — để dành, note lại đây cho
Đợt sau hoặc lúc dọn Library.

**Verify đã làm**: grep `m_IndicatorsCollection.TemplateExists` xác nhận 0 call site còn active trong
toàn bộ EA (chỉ còn 1 dòng comment đã sửa lại). Đọc lại nguyên khối code sau mỗi chỗ sửa để xác nhận
brace cân đối, đúng field name (`SIndicatorIdentity.type`/`.params_key` ở Layer 1 vs
`SJsonIndicatorEntry.type`/`.params[]` ở Layer 2 - không lẫn 2 kiểu key).

**Chưa làm** (Đợt 3e, để sau): xoá hẳn `m_table_indicator_ptrs[]`/`m_table_indicator_names[]` (comment
trước, xoá sau khi build/test ổn). `CSignalBridgeWriter`'s ArrayCopy copy + kiến trúc Bridge độc lập
vẫn là Đợt 4, chưa đụng.

**Kết quả**: chờ Anhnt compile/test.

## Action Log — gộp `ImportForeignChartIndicators`/`HandleChartIndicatorChange` thành `SynIndicatorOnChart` (2026-08-18, code xong, chờ Anhnt compile/test)

**Bối cảnh**: Anhnt mô tả 3 UseCase cho việc Layer 3 (Chart) đồng bộ ngược Layer 1/2:
1. User Insert lại 1 Indicator ĐÃ có sẵn trong Template (có thể đang ẩn) → KHÔNG Add gì ở Layer 1,
   chỉ cần bật lại checkbox Show ở Layer 2.
2. User chỉ đổi mầu/style → không cần làm gì cả 2 Layer.
3. User đổi Parameter thật trên Chart → Xoá Template cũ ở Layer 1, Tạo Template mới với Parameter mới.

Rà lại code hiện tại (trước khi sửa) xác nhận **cả 3 UseCase ĐÃ chạy đúng** rồi, chỉ là logic rải ra 2
hàm riêng (`ImportForeignChartIndicators`/`HandleChartIndicatorChange`) + 1 lệnh gọi
`RefreshIndicatorTableShowColumn()` tách rời trong `OnChartEvent` dispatch - không sai chức năng,
chỉ tổ chức code chưa gọn:
- UseCase 1: `ImportForeignChartIndicators()` đã có 2 lớp chặn (handle đã Layer1-owned, hoặc
  `TemplateExists()` true) nên không Add trùng; `RefreshIndicatorTableShowColumn()` (chạy sau, không
  phân biệt loại event) tự re-truth checkbox Show LIVE - `IsIndicatorShownOnChart`/`LineRepresentsIndicator`
  có fallback so type+params (không chỉ handle) nên vẫn đúng dù MT5 cấp handle mới cho lần Insert tay đó.
- UseCase 2: xác nhận ở tận Library (`Chart/ChartWnd.mqh::IndicatorsChangeCheck`) - event `IND_CHANGE`
  chỉ bắn khi tên Indicator biến mất khỏi window tracking (tức handle/param thật sự đổi); đổi màu/style
  thuần không đổi tên/handle nên event này KHÔNG bắn - không phải code EA chủ động bỏ qua, mà Library
  đã lọc từ gốc.
- UseCase 3: `HandleChartIndicatorChange()` (cũ) đã Remove template cũ + Add template mới đúng.

**Việc đã làm**: THUẦN reorg/rename, không đổi logic chức năng, theo yêu cầu Anhnt "Tất cả việc này chỉ
làm trong 1 Method SynIndicatorOnChart mà thôi":
1. `Anatoli Kazharski/GUIPannel.mqh` — xoá khai báo `HandleChartIndicatorChange(void)`, thêm khai báo
   `SynIndicatorOnChart(const long id)`.
2. `Anatoli Kazharski/GUIPannel_TabSettingIndicator.mqh` — xoá hẳn hàm `HandleChartIndicatorChange()`
   (không comment, gộp thẳng THEO YÊU CẦU vì nó chỉ có đúng 1 nơi gọi); thêm hàm mới
   `SynIndicatorOnChart(const long id)`: nhánh `IND_ADD` gọi `ImportForeignChartIndicators()` (giữ
   nguyên hàm này - còn 1 nơi gọi riêng lúc `OnInitEvent`, không có `id` cụ thể để dispatch nên không
   gộp được); nhánh `IND_CHANGE` chứa nguyên body cũ của `HandleChartIndicatorChange` (bọc trong
   `do{...}while(false)` - `break` đóng vai trò các early-return/guard-clause cũ, giữ đúng 100% logic/
   thứ tự check); cuối hàm luôn gọi `RefreshIndicatorTableShowColumn()` (bất kể nhánh nào, kể cả
   `IND_DEL` không match nhánh nào cả - giống hệt hành vi cũ).
3. `Anatoli Kazharski/GUIPannel_Lifecycle.mqh` (`OnChartEvent` dispatch) — 3 dòng if rải rác +
   `RefreshIndicatorTableShowColumn()` tách rời → 1 dòng gọi `SynIndicatorOnChart(id)` duy nhất.
4. `Anatoli Kazharski/GUIPannel_TabSettingIndicatorTable.mqh` — sửa lại 1 comment cũ nhắc tên
   `HandleChartIndicatorChange` (ở `OnClickRemoveIndicator`) trỏ đúng sang `SynIndicatorOnChart`.

**Verify đã làm**: grep `HandleChartIndicatorChange` xác nhận 0 call site/declaration còn active (chỉ
còn trong doc comment giải thích lịch sử + `FeatureNote/BugNote.md`/plan doc cũ - không đụng, đó là
archive lịch sử). Đếm `{`/`}` + `#ifndef`/`#endif` cân đối ở cả 3 file code đã sửa.

**Kết quả**: chờ Anhnt compile/test.

## Action Log

### Đợt 1 — ✅ HOÀN THÀNH, compile sạch (Anhnt xác nhận 2026-08-17, không lỗi)

**Method đã comment out (KHÔNG xoá hẳn, an toàn theo quy ước của Anhnt):**
- `ShortNameToIndicatorType()` — `Services/DELib/TimeseriesDELib.mqh` (~dòng 470-495), bọc trong
  `/* ... */`, kèm comment giải thích lý do (0 call site, bị thay thế bởi `IndicatorParameters()`).
  Đây là method DUY NHẤT bị comment trong Đợt 1.

**Properties đổi tên** (`SIndicatorCatalogItem.type` → `ind_type`, 7 chỗ) — đã có comment inline
ngay tại chỗ khai báo field (`TimeseriesDELib.mqh`, struct declaration), không cần liệt kê riêng ở
đây — xem chi tiết đủ 7 vị trí ở mục 4 phía trên.

**Sự cố ngoài lề (không do Đợt 1 gây ra, phát hiện lúc build thử):**
`GUIPannel_Define.mqh:12` include `PatternRenderer.mqh` bị lỗi "file not found" — do Anhnt tự move
file đó sang `Temp/` (chuẩn bị xoá, class `CPatternRenderer` đã ngưng dùng từ lâu vì lag, xác nhận
0 usage thật trong code, chỉ còn sót trong comment) nhưng chưa comment dòng include tương ứng. Anhnt
đã tự comment dòng include đó, không cần sửa gì thêm.

**Kết quả**: build EA thành công, không lỗi. Sẵn sàng chuyển sang Đợt 2 khi Anhnt muốn.

### Rà soát sau Đợt 1 — phát hiện thêm 1 chỗ thừa (Anhnt, 2026-08-17)

**`#include "..\Artyom Trishkin\IndicatorConfigLoader.mqh"` ở `GUIPannel.mqh:16` bị THỪA** — đã bị
include lại LẦN 2, trong khi đã được kéo vào từ trước qua chuỗi:
```
GUIPannel.mqh:9  → GUIPannel_Define.mqh:22 → TimeSeriesEngine.mqh:23 → IndicatorConfigLoader.mqh
GUIPannel.mqh:16 → IndicatorConfigLoader.mqh   (THỪA - include lại y hệt)
```
Nhờ include-guard (`#ifndef`) nên không gây lỗi build, chỉ là code thừa/gây hiểu lầm. Xác nhận:
việc Load JSON hoàn toàn thuộc về Layer 1 (`CTimeSeriesEngine`) — `CGUIPannel` chỉ cần TYPE struct
(`SJsonIndicatorEntry`/`SJsonSymbolTF`), và type đó ĐÃ có sẵn qua chuỗi include tự nhiên phía trên,
không cần include tay thêm lần nữa. Comment cũ ở `GUIPannel.mqh:10-15` giải thích lý do "include
thẳng cho an toàn" cũng lạc hậu theo (viết lúc chưa để ý đã được kéo vào từ trước).

- [x] Comment out dòng 16 (Anhnt tự làm) — verify đúng, không xoá hẳn.
- [x] Build/test lại — compile sạch, không lỗi (xem Action Log Đợt 1).

## Action Log — Đợt 2 (2026-08-17, code xong, chờ Anhnt compile/test)

**File đã sửa:**
1. `Services/DELib/TimeseriesDELib.mqh` (Library) — thêm overload
   `BuildTemplateMatchKey(const ENUM_INDICATOR type, MqlParam &params[], SIndicatorCatalogItem &catalog[], string &type_key, string &params_key)`
   dùng được khi CHƯA có `CIndicatorDE*` (đúng lúc `AddNewIndicatorToAllSeries` cần, trước khi tạo
   instance nào). Bản cũ (nhận `CIndicatorDE*`) refactor lại chỉ trích `type`+`params` rồi delegate
   xuống bản mới — tránh trùng logic xây key giữa 2 overload.
2. `Artyom Trishkin/TimeSeriesEngine.mqh` — khai báo 2 method public mới: `TemplateExists(type_key,
   params_key)`, `RemoveIndicatorTemplate(type_key, params_key)`.
3. `Artyom Trishkin/TimeSeriesEngine_Indicator.mqh` — `AddNewIndicatorToAllSeries()` giờ tự ghi vào
   `m_indicator_template[]` ở đầu hàm (guard bằng `TemplateExists()` tránh trùng entry) trước khi
   loop tạo instance theo symbol/TF. Thêm implementation `TemplateExists()`/`RemoveIndicatorTemplate()`
   (loop `m_indicator_template[]`, so string, xoá thì shift-down + `ArrayResize`).
4. `Artyom Trishkin/TimeSeriesEngine_JSONConfig.mqh` (`LoadIndicatorTemplateFromJSON`) — **XOÁ HẲN**
   (không bọc `/* */` — nằm giữa 1 vòng for vẫn cần giữ phần khác `out_entries[e]=entries[e]`, bọc
   comment nửa vời sẽ rối hơn) đoạn ghi trực tiếp cũ vào `m_indicator_template[e]` — thay bằng comment
   giải thích rõ lý do + trỏ tới nơi logic mới nằm (`AddNewIndicatorToAllSeries`). Side benefit: entry
   JSON bị skip (unknown type) không còn tạo slot rỗng trong `m_indicator_template[]` như code cũ.
5. `Anatoli Kazharski/GUIPannel_TabSettingIndicatorTable.mqh` (`OnClickRemoveIndicator`) — thêm gọi
   `m_time_series_engine.RemoveIndicatorTemplate(type_key, params_key)` (build key từ `ref_type`/
   `ref_params` đã capture sẵn) TRƯỚC vòng lặp xoá instance thật — đây là entry point Xoá duy nhất.

**Lưu ý riêng cho Anhnt**: mục 4 ở trên là xoá hẳn thay vì comment-out (khác quy ước "comment trước,
xoá sau" đã thống nhất) — vì đoạn code cũ nằm LỒNG giữa 1 vòng `for` vẫn cần giữ nguyên phần khác,
không tách comment gọn được. Đã viết comment giải thích đầy đủ thay thế. Nếu muốn giữ nguyên văn bản
cũ dưới dạng comment cho chắc, báo lại để sửa.

**Chưa làm trong Đợt 2** (để dành, không thuộc phạm vi): chưa rewire `ImportForeignChartIndicators`/
`CIndicatorsCollection::TemplateExists()` sang dùng `CTimeSeriesEngine::TemplateExists()` mới — 2 cơ
chế dedup cũ và mới hiện SONG SONG tồn tại (cũ vẫn hoạt động đúng, mới đã sẵn sàng nhưng chưa được
gọi từ đâu ngoài `AddNewIndicatorToAllSeries`). Việc rewire sang dùng bản mới là Đợt 3.

**Kết quả**: chờ Anhnt compile/test.

## Đổi tên struct `SIndicatorTemplate` → `SIndicatorIdentity` (Anhnt, 2026-08-17) — ✅ CODE XONG, chờ compile/test

**Lý do**: struct `SIndicatorTemplate {string type; string params_key;}` chỉ đại diện đúng **1
indicator** (identity: type+params) — không phải "cả 1 Template". Cái thật sự LÀ Template (bộ
indicator áp dụng đồng loạt cho mọi symbol/TF) chính là cái ARRAY `m_indicator_template[]` — tên
struct hiện tại (số ít nhưng mang tên số nhiều) dễ gây hiểu lầm struct = cả bộ. Tên mới đề xuất:
`SIndicatorIdentity` (khớp đúng bản chất 2 field).

**Phạm vi đổi** (đã rà, chỉ 2 chỗ trong code thật, `TimeSeriesEngine.mqh`):
1. Dòng 31 — khai báo struct
2. Dòng 55 — `SIndicatorTemplate m_indicator_template[];`

(Field `m_indicator_template[]` GIỮ NGUYÊN tên — nó đúng là "cái Template", không đổi.)

Lúc code thật: thêm comment inline ngay cạnh chỗ khai báo, dạng `// renamed from SIndicatorTemplate
(SynIndicatorPlan.md)` — theo đúng convention đã dùng cho vụ đổi `SIndicatorCatalogItem.type` →
`ind_type` ở Đợt 1.

- [x] Anhnt xác nhận tên `SIndicatorIdentity` — đã đổi cả 2 chỗ (dòng 31, 55 `TimeSeriesEngine.mqh`),
      kèm comment inline giải thích. Verify grep sạch, không còn `SIndicatorTemplate` sót trong code.

## "3 Layer Task breakdown" — bàn kỹ chống Duplicate code (Anhnt, 2026-08-18)

**Bối cảnh**: sau khi gộp `SynIndicatorOnChart`, Anhnt thấy vẫn còn "hơi Duplicate và chưa clear" —
bàn kỹ lại theo đúng khung Task của Anhnt trước khi code tiếp.

**Task breakdown đã chốt** (Anhnt xác nhận "Đúng rồi, chúng ta càng làm tách bạch thì càng không
Duplicate code"):

| Layer | Task | Việc | API |
|---|---|---|---|
| L1 (`CTimeSeriesEngine`) | Task1 Delete | Xoá mirror + mọi instance symbol/TF + Signal | `RemoveIndicatorFromAllSeries(type,params)` **MỚI** |
| L1 | Task2 Add | (không đổi) | `AddNewIndicatorToAllSeries(type,params)` |
| L2 (`CGUIPannel`) | Task1 Show/Hide | `ChartIndicatorDelete/Add` | `DetachIndicatorFromChart`/`ChartIndicatorAdd` (không đổi) |
| L2 | Task2 Add | Gọi L1.Task2 + tự thêm row/Setting | `AddIndicatorInstance(type,params)` (không đổi, đã identity-based sẵn) |
| L2 | Task Delete | Gọi L1.Task1 + tự xoá row/Setting | `RemoveIndicatorInstance(type,params)` **MỚI** |
| L3 (Chart, trong `SynIndicatorOnChart`) | Task1+2 | Scan Chart, so `TemplateExists()`, lạ thì gọi L2.Task2 | `ImportForeignChartIndicators()` (không đổi) |
| L3 | Task3 | Correlate 1 dòng đổi (Handle cũ) → gọi L2.Delete(old) rồi L2.Add(new) | nhánh `CHANGE` trong `SynIndicatorOnChart` (không đổi lần này) |

**Nguyên tắc chốt**: `m_IndicatorsCollection` ở Layer 2 chỉ dùng để ĐỌC (query/lookup); mọi thao tác
GHI (tạo/xoá instance thật) phải đi qua Layer 1. Modify Parameter KHÔNG phải Task riêng ở Layer 1 —
luôn luôn = Delete(old identity) + Add(new identity) ghép lại, vì `CIndicatorDE` không đổi Parameter
tại chỗ được (Handle gắn chết với instance).

**Việc đã làm (2 bước, đúng nhịp Anhnt yêu cầu — Layer 1 trước, Layer 2 sau):**

*Bước 1 — L1.Task1:*
1. `Artyom Trishkin/TimeSeriesEngine.mqh` — khai báo `RemoveIndicatorFromAllSeries(type,params)`.
2. `Artyom Trishkin/TimeSeriesEngine_Indicator.mqh` — implementation: gọi `RemoveIndicatorTemplate`
   (mirror) nội bộ ở đầu hàm (giống cách `AddNewIndicatorToAllSeries` tự gọi `TemplateExists`), rồi
   loop `m_IndicatorsCollection.GetList()` xoá đúng instance cùng type+params (mọi symbol/TF) —
   `DeleteSignal` trước, `list.Delete(i)` sau. KHÔNG đụng Chart (đối xứng với Add cũng không đụng Chart).

*Bước 2 — L2 Add/Delete đối xứng, đi qua Layer 1:*
3. `Anatoli Kazharski/GUIPannel.mqh` — thêm khai báo `GetRowForIdentity(type_key,params_key)` (reverse
   của `GetIndicatorForRow`) + `RemoveIndicatorInstance(type,params)`.
4. `Anatoli Kazharski/GUIPannel_TabSettingIndicatorTable.mqh`:
   - `GetRowForIdentity()` mới — scan `m_indicator_template_setting[]` tìm row khớp identity.
   - `RemoveIndicatorInstance(type,params)` mới — hàm lõi identity-based: build key, tìm row qua
     `GetRowForIdentity`, detach Chart cho mọi instance khớp (đọc-only loop `m_IndicatorsCollection`,
     KHÔNG xoá gì ở đây), gọi `m_time_series_engine.RemoveIndicatorFromAllSeries()` (L1.Task1), rồi
     tự làm phần Layer 2 (shift row/`m_indicator_template_setting[]`, `DeleteRow` trên CTable).
   - `OnClickRemoveIndicator(sname,row)` — giờ CHỈ còn thin wrapper: `GetIndicatorForRow(row)` → lấy
     type/params → gọi `RemoveIndicatorInstance`. Không còn tự loop `m_IndicatorsCollection`/`list.Delete`
     nữa — Layer 2 không còn thao tác GHI trực tiếp lên collection của Layer 1.

**Verify đã làm**: grep `RemoveIndicatorTemplate\(`/`list.Delete(i)` xác nhận cả 2 chỉ còn xuất hiện
trong `TimeSeriesEngine_Indicator.mqh` (Layer 1), không còn ở bất kỳ file Kazharski nào. Brace/
`#ifndef`-`#endif` cân đối ở cả 4 file đã sửa.

**Chưa làm** (bước sau, chưa động tới lần này): nhánh `CHANGE` trong `SynIndicatorOnChart` vẫn đang tự
loop `m_table_indicator_ptrs[]` tìm row rồi gọi `OnClickRemoveIndicator(name,row)` — giờ có thể đơn
giản hoá thành gọi thẳng `RemoveIndicatorInstance(old_type,old_params)` (identity lấy trực tiếp từ
`owned` - `OwnedInstanceOfLine` trả về), bỏ hẳn vòng loop tìm row đó. Để dành làm riêng, xác nhận với
Anhnt trước.

**Fix nhỏ phát hiện ngay sau đó (Anhnt bắt ra, 2026-08-18)**: `AddIndicatorInstance()` tính `row` mới
bằng `ArraySize(m_table_indicator_ptrs)` — Property CŨ (đang chờ xoá ở Đợt 3e), không phải
`m_indicator_template_setting[]` (Property MỚI, nguồn sự thật Layer 2). `RemoveIndicatorInstance()`
mới viết cũng mắc y hệt lỗi này (`rows_after` tính từ `m_table_indicator_ptrs`). Cả 2 chỗ đã sửa lại
dùng `ArraySize(m_indicator_template_setting)` — 2 mảng vẫn đang được giữ đồng bộ song song (đến khi
Đợt 3e xoá hẳn `m_table_indicator_ptrs[]`) nên về mặt SỐ LƯỢNG không khác nhau, nhưng đúng nguyên tắc
"Property mới là nguồn sự thật" cần bám vào `m_indicator_template_setting[]`, không phải property cũ.

**Kết quả**: chờ Anhnt compile/test.
- [ ] Anhnt compile/test.

## `OnClickAddIndicator` bỏ qua `AddIndicatorInstance`, gọi thẳng Layer 1 (Anhnt, 2026-08-18)

**Lý do (Anhnt)**: `OnClickAddIndicator` đã có sẵn đủ type+params trước khi gọi `AddIndicatorInstance`
rồi; Layer 1 đã có sẵn `TemplateExists()` + `AddNewIndicatorToAllSeries()` rồi — "rách việc" gọi qua
`AddIndicatorInstance` làm gì khi đang có sẵn cơ chế Sync (`RefreshTableIndicator()` — CÙNG hàm
CHARTCHANGE/Init đang dùng để đồng bộ bảng Layer 2 với Layer 1) tự nhặt được row mới, không cần logic
append-1-row viết tay riêng của `AddIndicatorInstance`.

**Đã sửa**: `Anatoli Kazharski/GUIPannel_TabSettingIndicator.mqh::OnClickAddIndicator()` — bỏ dòng gọi
`AddIndicatorInstance(...)`, thay bằng gọi thẳng: build `type_key`/`params_key` qua
`BuildTemplateMatchKey`, check `m_time_series_engine.TemplateExists()` (reject nếu đã có, giống hệt
logic cũ bên trong `AddIndicatorInstance`), gọi `m_time_series_engine.AddNewIndicatorToAllSeries()`,
`SyncIndicatorTreeViewIcons()`, rồi `RefreshTableIndicator()` (thay cho đoạn append-1-row cũ).

**Chưa đụng**: `AddIndicatorInstance()` VẪN CÒN — 2 nơi gọi khác (`ImportForeignChartIndicators()`,
nhánh `CHANGE` trong `SynIndicatorOnChart`) chưa đổi, vẫn dùng nó như cũ. Chỉ riêng đường Form-Add đổi
sang gọi thẳng Layer 1 lần này. Cân nhắc đợt sau: 2 nơi kia có nên đổi tương tự không (dùng
`RefreshTableIndicator()` thay vì append-1-row) — để dành, chưa quyết.

**Verify đã làm**: Brace/`#ifndef`-`#endif` cân đối. Grep xác nhận `AddIndicatorInstance` còn đúng 2 call
site (`ImportForeignChartIndicators`, `SynIndicatorOnChart`), không còn ở `OnClickAddIndicator`.

**Kết quả**: chờ Anhnt compile/test.

## `ImportForeignChartIndicators`/nhánh `CHANGE` cũng đổi tương tự — `AddIndicatorInstance` thành DEAD (Anhnt, 2026-08-18)

**Quyết định (Anhnt)**: "Chả đổi tương tự thì sao" — đổi luôn 2 nơi còn lại giống hệt `OnClickAddIndicator`.

**Đã sửa** (`GUIPannel_TabSettingIndicator.mqh`):
1. `ImportForeignChartIndicators()` — bỏ `AddIndicatorInstance(-1,type,params)`, gọi thẳng
   `m_time_series_engine.AddNewIndicatorToAllSeries(type,params)`. `SyncIndicatorTreeViewIcons()` +
   `RefreshTableIndicator()` chuyển ra NGOÀI vòng loop (chỉ chạy 1 lần, nếu có `imported_any` -
   nhanh hơn bản cũ: trước đây mỗi indicator mới tìm được tự chạy riêng 1 lần `SyncIndicatorTreeViewIcons`
   full-sweep bên trong `AddIndicatorInstance`, giờ dồn lại 1 lần cho cả đợt quét dù tìm thấy bao nhiêu).
2. Nhánh `CHANGE` trong `SynIndicatorOnChart` — bỏ hẳn vòng loop dò `row` từ `m_table_indicator_ptrs[]`
   + bỏ gọi `OnClickRemoveIndicator(name,row)`/`AddIndicatorInstance(-1,type,params)`. Đổi sang:
   capture `old_type`/`old_params` từ `owned` (identity, TRƯỚC khi nó bị xoá) → gọi thẳng
   `RemoveIndicatorInstance(old_type,old_params)` (identity-based, tự tìm row nội bộ qua
   `GetRowForIdentity`) → check `TemplateExists` cho identity MỚI (giữ lại y hệt hành vi cũ của
   `AddIndicatorInstance`: nếu Parameter mới đổi tới TRÙNG 1 Template đã có sẵn khác, thì merge -
   không Add lại, chỉ xoá cái cũ, không lỗi) → gọi thẳng `AddNewIndicatorToAllSeries` +
   `SyncIndicatorTreeViewIcons` + `RefreshTableIndicator`.

**Hệ quả**: `AddIndicatorInstance()` giờ 0 call site — DEAD CODE THẬT. Đã comment out (không xoá hẳn,
đúng quy ước Anhnt) cả khai báo (`GUIPannel.mqh:333`) lẫn implementation
(`GUIPannel_TabSettingIndicator.mqh`), kèm note lý do.

**Verify đã làm**: grep `AddIndicatorInstance\(` xác nhận 0 call site active (chỉ còn trong comment/code
đã comment out). Brace + `/* */` cân đối ở cả 2 file sửa.

**Kết quả**: chờ Anhnt compile/test.

## BUG THẬT: `SaveConfigurationToJSON` đọc property CŨ → Buy/Sell/Sound/Message luôn `false` trong JSON (Anhnt bắt ra, 2026-08-18)

**Triệu chứng**: Anhnt tick ON Buy/Sell/Sound/Message trên GUI cho 5 Indicator (BBands/PSAR×2/AMA/MA),
bấm Save — `Config_Setting.json` ra đúng 5 Template (tên/params đúng) nhưng **buy/sell/sound/message
đều `false` hết**, dù GUI hiện checkbox đang ON.

**Root cause**: `CTimeSeriesEngine::SaveConfigurationToJSON` (`TimeSeriesEngine_JSONConfig.mqh`) là chỗ
DUY NHẤT còn sót lại kiểu CŨ — tự dựng danh sách Template bằng cách quét
`m_IndicatorsCollection.GetListIndBySymbol(::Symbol())` lọc theo TF của chart HIỆN TẠI (`::Period()`),
thay vì đọc thẳng `m_indicator_template[]` (mirror sống, chart-independent, Layer 1's nguồn sự thật -
đã dùng ở MỌI chỗ khác từ Đợt 2). Layer 2 (`SaveGUIConfigToJSON`) đã ĐÚNG từ trước — đọc thẳng
`m_indicator_template_setting[]` (nguồn DUY NHẤT ở Layer 2, Anhnt xác nhận lại) — bug nằm hoàn toàn ở
phía Layer 1.

**Đã sửa** (`Artyom Trishkin/TimeSeriesEngine_JSONConfig.mqh::SaveConfigurationToJSON`): `tmpl_total`
đổi nguồn từ `templates.Total()` (scan theo chart hiện tại) sang `ArraySize(m_indicator_template)`
(mirror sống). Loop theo `m_indicator_template[i].type`/`.params_key` (identity chuẩn) thay vì
`BuildTemplateMatchKey(templates.At(i),...)`. Vì `m_indicator_template[]` chỉ giữ string
(type_key,params_key) chứ không giữ `MqlParam[]` có kiểu thật (JSON cần), với mỗi identity vẫn phải
tìm 1 instance sống đại diện để đọc `GetMqlParams()` — nhưng giờ tìm trong TOÀN BỘ
`m_IndicatorsCollection.GetList()` (mọi symbol/TF), không giới hạn theo chart hiện tại nữa.

**Verify đã làm**: Brace/`#ifndef`-`#endif` cân đối. Đọc lại đoạn build JSON phía sau xác nhận
`tmpl_ptrs[i]`/`resolved_buy[i]` vẫn đúng index, `if(ind==NULL) continue` vẫn chặn an toàn nếu 1 identity
không tìm được instance đại diện (trường hợp hiếm, không nên xảy ra do bất biến "mọi series đều có đủ
Template").

**Kết quả**: chờ Anhnt compile/build lại + tick checkbox + Save + xác nhận JSON ra đúng `true`.

## BUG THẬT thứ 2, cùng loại: `AddAllIndicatorsToNewSeries` cũng đọc property CŨ (Anhnt bắt ra, 2026-08-18)

**Phát hiện**: sau khi sửa `SaveConfigurationToJSON`, Anhnt hỏi thẳng có còn chỗ nào khác cũng dùng
kiểu cũ không — grep `all.At(0)`/`ref_entry`/`GetListIndBySymbol(ref_sym)` ra đúng 1 chỗ nữa:
`CTimeSeriesEngine::AddAllIndicatorsToNewSeries` (`TimeSeriesEngine_Indicator.mqh`) — hàm chạy khi 1
(symbol,TF) MỚI được tạo, copy TOÀN BỘ Template hiện có sang series mới. Đang lấy `all.At(0)` (phần tử
ĐẦU TIÊN trong TOÀN BỘ `m_IndicatorsCollection`, symbol/TF bất kỳ) làm "reference", rồi lọc lại theo
chính symbol/TF của reference đó ra "danh sách Template" — cùng bug class với `SaveConfigurationToJSON`
(dựa vào 1 instance đại diện thay vì đọc thẳng `m_indicator_template[]`), và cách chọn "phần tử đầu
tiên" này còn phụ thuộc thứ tự không đảm bảo của `CArrayObj`.

**Đã sửa**: `tmpl_total` đổi nguồn sang `ArraySize(m_indicator_template)`; loop theo
`m_indicator_template[i].type`/`.params_key`, mỗi identity tìm 1 instance đại diện trong TOÀN BỘ
`m_IndicatorsCollection.GetList()` (không giới hạn theo 1 symbol/TF nào) để lấy `MqlParam[]` thật cho
`CreateIndicator()`. Cùng pattern fix hệt `SaveConfigurationToJSON`.

**Cũng sửa**: comment doc phía trên `SaveConfigurationToJSON` (còn nhắc "cùng reference trick như
AddAllIndicatorsToNewSeries... all.At(0) is the source") — cập nhật lại mô tả đúng hành vi mới, tránh
gây hiểu lầm cho người đọc sau này.

**Verify đã làm**: grep lại `all.At(0)`/`ref_entry`/`GetListIndBySymbol(ref_sym)` xác nhận 0 chỗ nào
còn sót trong toàn bộ EA (chỉ còn trong comment giải thích lịch sử). Brace/`#ifndef`-`#endif` cân đối.

**Kết quả**: chờ Anhnt compile/build lại + test tạo 1 symbol/TF mới (VD đổi sang symbol chưa từng mở)
xem Template có copy đủ sang không.

## `SaveConfigurationToJSON` gọn signature: 6 mảng song song → 1 `SJsonIndicatorEntry[]` (Anhnt, 2026-08-18)

**Đề xuất (Anhnt)**: `CTimeSeriesEngine::SaveConfigurationToJSON` chỉ cần nhận `filename` +
`m_indicator_template_setting[]` (kiểu `SJsonIndicatorEntry`) từ `CGUIPannel` thẳng, không cần tách
thành 6 mảng song song (`tmpl_type_key[]`/`tmpl_params_key[]`/`tmpl_buy[]`/`tmpl_sell[]`/
`tmpl_sound[]`/`tmpl_message[]`) rồi ghép lại — struct đã có sẵn đủ field (`type`, `params[]`, `buy`,
`sell`, `sound`, `message`), tách ra rồi ghép lại chỉ tổ dư code.

**Đã sửa** (3 file):
1. `Artyom Trishkin/TimeSeriesEngine.mqh` — signature đổi: bỏ 6 tham số cũ, thay bằng 1 tham số
   `SJsonIndicatorEntry &tmpl_setting[]` (kiểu đã sẵn có, include qua `IndicatorConfigLoader.mqh`).
2. `Artyom Trishkin/TimeSeriesEngine_JSONConfig.mqh` — implementation: vòng match đổi từ so
   `tmpl_type_key[h]`/`tmpl_params_key[h]` sang so `tmpl_setting[h].type` + join `tmpl_setting[h].params[]`
   bằng dấu phẩy tại chỗ (cùng round-trip `GetIndicatorForRow`/`GetRowForIdentity` đang dùng), rồi đọc
   thẳng `tmpl_setting[match].buy/.sell/.sound/.message`.
3. `Anatoli Kazharski/GUIPannel_JSONConfig.mqh::SaveGUIConfigToJSON` — xoá hẳn đoạn build 6 mảng song
   song (resize + loop tách field), truyền thẳng `m_indicator_template_setting` vào lời gọi.

**Verify đã làm**: grep `SaveConfigurationToJSON\(` xác nhận đúng 1 call site (`GUIPannel_JSONConfig.mqh`),
đã khớp signature mới. Brace/`#ifndef`-`#endif` cân đối cả 3 file.

**Kết quả**: chờ Anhnt compile/test.

## Rà soát toàn diện ("Trời ơi... rà soát lại giúp tớ", Anhnt, 2026-08-18)

**Lý do**: sau 2 bug thật liên tiếp (`SaveConfigurationToJSON`, `AddAllIndicatorsToNewSeries` đều đọc
property cũ), Anhnt yêu cầu rà soát chủ động toàn bộ thay vì chờ tìm tiếp từng cái 1.

**Quét theo 3 pattern lỗi đã biết:**
1. `GetListIndBySymbol(...)` toàn EA — TẤT CẢ chỗ còn lại đều là tra cứu HỢP LỆ "instance của
   chart/TF hiện tại" (`RefreshTableIndicator`, `GetIndicatorForRow`, `CheckIndicatorAlerts`,
   `SignalBridgeWriter`, `GUIPannel_CandleInfo`, `GUIPannel_TabMonitor`) — không phải kiểu bug "suy
   ra cả danh sách Template từ 1 scan". `SignalBridgeWriter.mqh` (2 chỗ) đọc riêng, thuộc phạm vi
   Đợt 4 (Bridge ArrayCopy architecture), không đụng.
2. `all.At(0)`/`ref_entry` (reference-instance trick) — 0 chỗ còn sót, đã fix hết ở bug thứ 2.
3. `ArraySize(m_table_indicator_ptrs)` dùng làm baseline đếm row — tìm thêm **4 chỗ active** ngoài 2
   chỗ đã sửa trước đó (`AddIndicatorInstance`/`RemoveIndicatorInstance`):
   - `RefreshTableIndicator()` — điều kiện fast-path (`count == ...`)
   - `RefreshTableIndicator()` — guard bảng rỗng
   - `RefreshIndicatorTableShowColumn()` — vòng lặp cột Show
   - `OwnedInstanceOfLine()` — vòng lặp fallback theo `line_handle`

   Tất cả đã đổi sang `ArraySize(m_indicator_template_setting)`. Còn đúng 2 chỗ khác nằm trong khối
   `/* ... */` đã comment-out (`ApplyLoadedIndicatorBuySell`/`BuildTemplateBuySellSoundMessageArrays`)
   — không active, không cần sửa.

**Đã kiểm tra chéo, xác nhận KHÔNG phải bug:**
- Signature khai báo (`GUIPannel.mqh`/`TimeSeriesEngine.mqh`) khớp đúng implementation cho mọi
  hàm mới/sửa trong buổi: `SynIndicatorOnChart`, `RemoveIndicatorInstance`, `GetRowForIdentity`,
  `RemoveIndicatorFromAllSeries`, `SaveConfigurationToJSON`.
- Convention join `params[]` bằng dấu phẩy nhất quán ở MỌI nơi đọc/ghi.
- `LoadIndicatorTemplateFromJSON` (đối xứng Load/Save) — không dính bug tương tự, nó là NGUỒN ghi
  `m_indicator_template[]`, không suy ra từ scan.
- Đọc lại end-to-end 5 hàm trọng tâm (`SynIndicatorOnChart`, `ImportForeignChartIndicators`,
  `OnClickAddIndicator`, `RemoveIndicatorInstance`, `GetRowForIdentity`) — logic đúng, không lỗi cú pháp.

**Verify đã làm**: đếm `{`/`}` + `#ifndef`/`#endif` lại TOÀN BỘ 10 file đã đụng tới trong buổi hôm nay
(1 lượt duy nhất, không sót file nào) — tất cả cân đối.

**Kết quả**: chờ Anhnt compile/test toàn bộ.
