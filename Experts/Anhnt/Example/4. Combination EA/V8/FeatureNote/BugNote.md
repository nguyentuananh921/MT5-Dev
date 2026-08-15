# Combination EA V7 — BugNote: hồ sơ vụ án & luật rút ra

> Archive hồ sơ bug (root cause + bằng chứng log). Sổ chính/checklist: README.md.
> Quy ước chung: hội thoại tiếng Việt, comment trong code tiếng Anh.

## 0. Luật xương máu (tra nhanh)
- **Handle indicator = SLOT toàn chương trình, KHÔNG phải refcount.**
  *Một chủ — một release*: toàn chương trình chỉ `~CIndicatorDE` được gọi `IndicatorRelease`.
  Get thoải mái (Get lặp trả cùng slot, không phình); release nhầm là giết handle của chính
  mình + số bị cấp lại → indicator khác đọc nhầm buffer ÂM THẦM (chi tiết: mục 5e).
- **Line thêm tay trên Chart là instance RIÊNG của terminal** — handle khác với instance
  Layer 1 tự tạo dù type+params giống hệt (bằng chứng: line handle=17 vs owned=18).
  Join Layer 3 ↔ Layer 1: so handle trước (line do EA attach), miss thì so type+params
  qua `IndicatorParameters(line_handle)` — helper `LineRepresentsIndicator`/`OwnedInstanceOfLine`.
- **Định danh Template = type + params** (symbol/TF vô can). KHÔNG so sánh tên: tên line
  (`SAR(0.05,0.2)`) ≠ `ShortName` DE (`SAR(BTCUSDm,M1)`). So sánh theo params tập trung: `MqlParamsEqual`.
- **Xóa graphic object phải "đúng cửa"**: `ObjectsDeleteAll` thô làm sổ đăng ký của
  `CGraphElementsCollection` thành mồ côi → nó từ chối tạo lại cùng tên ("already exists").
  Dùng `PurgeSignalArrowObjects`: gỡ registry (qua `GetListGraphObj()`) rồi mới `ObjectDelete`.
- **Pointer sau `AddIndicatorToList` coi như CHẾT** (dedup path delete object trùng) —
  luôn re-acquire qua `GetIndicatorByHandle` trước khi dùng tiếp (chi tiết: mục 5d).---

## 1. Kiến trúc tổng quan

- **Tầng 1 (PureData)**: 
- **Tầng 2 (GUI)**: `CGUIPannel` (GUI Lib của Anatoli Kazharski) — chỉ **mượn** pointer các collection,không own gì thuộc PureData.
- **Vẽ lên chart**: `CGraphElementsCollection` (đã cắt gọn — xem mục 3) own các wrapper `CGStd*Obj`.
- Nguyên tắc dữ liệu: **các Collection phải thống nhất nhau** — symbol/TF luôn lấy từ `CBarSeriesDE`
  (nguồn tin cậy, không bao giờ drift), không tin `ind.Symbol()` khi tạo mới, không làm side-map/registry.

### Nguyên tắc đồng nhất 3 tầng (chốt 2026-07-09)
- **Layer 1 (PureData)** là nguồn sự thật: có Indicator / BarSeries / Signal nào thì
  **Layer 2 (GUI)** phải hiển thị đúng ngần ấy (bảng, treeview) — không hơn không kém.
- **Layer 2 → Layer 3**: việc SHOW hay KHÔNG SHOW trên chart do Layer 2 điều khiển
  (checkbox cột "Show" của `m_table_indicator` → `ChartIndicatorAdd/Delete`).
- **Layer 3 → Layer 2**: `CChartObjCollection` (OWNED bởi `CGUIPannel`) quan sát mọi chart/cửa sổ/
  indicator; `Refresh()` được poll trong `OnTimerEvent`, phát `CHART_OBJ_EVENT_CHART_WND_IND_ADD/
  DEL/CHANGE` (bắt cả thao tác TAY của user trên chart) → `OnEvent` gọi
  `RefreshIndicatorTableShowStates()` để cột "Show" luôn đúng sự thật.
- **Layer 3 → Layer 1 (IMPORT, thêm 2026-07-10)**: user thêm TAY một indicator lên chart
  (vd BBands không có trong JSON) → event `IND_ADD` → `ImportForeignChartIndicators()`:
  `ChartIndicatorGet` lấy handle (nhớ `IndicatorRelease` sau khi dùng) → `IndicatorParameters()`
  dựng lại type+params → nếu type có trong catalog và `TemplateExists()` chưa có → đi qua ĐÚNG
  cửa `AddIndicatorInstance()` như nút Add: engine tạo trên MỌI series + Signal, append row
  `m_table_indicator`, `SyncIndicatorTreeViewIcons`, bảng Trade tự rebuild tick sau (count đổi).
  Idempotent: `ChartIndicatorAdd` của chính mình (checkbox Show) cũng bắn IND_ADD nhưng bị
  `TemplateExists` lọc im lặng. Chạy thêm 1 lần lúc init (reconcile indicator có sẵn trên chart).
- **Chống flicker `m_window_main` khi CHARTCHANGE (2026-07-10)**: `UpdateGUI` bỏ 2 cú
  `Update(true)` vô điều kiện lên `m_treeview_SymbolTF` + `m_table_indicator` — mọi refresh
  giờ đi qua dirty-check của từng bảng; tree chỉ được `PopulateSymbolTFTree` cập nhật khi
  symbol/TF thực sự đổi.
- **Màu mè (styling) Layer 3: ĐỂ SAU** — giới hạn API MT5: không có hàm đổi màu/style plot của
  indicator đã attach lên chart; màu chỉ quyết được lúc tạo handle (input params) hoặc qua template.

## 2. Hệ thống Signal (đã xong phần lõi)

### Thiết kế
- `CSignalBase` (`Timeseries/Signal/SignalBase.mqh`) là một **timeseries thực thụ**:
  - `m_current_val`: giá trị sống của bar 0 (đang hình thành) — refresh mỗi tick, không lưu.
  - `m_hist_time/val/low/high[]`: lịch sử vĩnh viễn, **chỉ ghi tại bar có đảo chiều** (sparse).
  - `ComputeAt(bar)`: hàm toán thuần (subclass override) — dùng chung cho live lẫn backfill.
  - `SyncHistory(n)`: backfill lịch sử flip khi Signal mới được tạo (cap 500 bar).
  - `CommitClosedBar()`: chốt bar vừa đóng, gọi đúng 1 lần theo event new-bar.
- `CSignalsCollection` (`Collections/SignalsCollection.mqh`): map 1-1 `CIndicatorDE*` → `CSignalBase*`.
  - **OWNED**: `m_signal_list[]` (tạo trong `GetOrCreateSignal`, xoá trong `DeleteSignal`/destructor).
  - **BORROWED**: `m_indicator_list[]` (CIndicatorsCollection own indicator).
  - **LUẬT**: ai xoá indicator khỏi `CIndicatorsCollection` PHẢI gọi `DeleteSignal(indicator)` TRƯỚC.
- Đã wire: `IND_SAR` (`CSignalSAR`), `IND_MA` (`CSignalMA` — theo độ dốc line). Các class khác
  (Oscillator/ZeroCross/MACD/ADX/Bands/Crossover) đã port sang API `ComputeAt` nhưng CHƯA vào switch
  của `GetOrCreateSignal` (chờ chốt ý tưởng từng loại).

### Wiring vòng đời (CTimeSeriesEngine)
- `OnTickEvent(symbol)`: `RefreshCurrentBar(symbol)` — chỉ symbol của chart, sống theo tick.
- `OnTimerEvent()`: `RefreshCurrentBar()` — mọi symbol còn lại.
- `ProcessNewBarSignalEvents()`: đọc `SERIES_EVENTS_NEW_BAR` từ event list của
  `CBarTimeSeriesCollection` (KHÔNG tự gọi `IsNewBar()` — hàm đó có side-effect, bar series own nó)
  → `FreezeClosedBar(symbol, tf)`.

### Hiển thị
- Bảng Trade (`m_table_indicator_SymbolTFValue`): Col1 = sig_img (Signal thật qua `GetCurrentSignal()`),
  Col2 = val_img (độ dốc giá trị) — 2 hệ icon ĐỘC LẬP, chỉ trùng khi loại indicator chưa có Signal.
- `DrawSignalArrows()` (GUIPannel): gom lịch sử flip của mọi indicator thuộc đúng symbol+TF chart
  hiện tại theo bucket bar-time → 1 signal = Arrow Buy/Sell, ≥2 = ThumbUp/Down. Watermark
  `m_signal_arrows_key/last_time[]` theo từng cặp (sym|TF) để không vẽ lại.

## 3. CGraphElementsCollection — cuộc phẫu thuật (đã xong, build OK)

File vendor (DoEasy/Trishkin) chưa từng compile trong project. Đã làm:
1. Tách 76 method inline khỏi class body → Declaration + Implementation (default param chỉ ở Declaration).
2. Bỏ hẳn hệ **WForms container** (`CreateElement/Form/GroupBox/Panel*` 16 hàm + include
   GroupBox/Panel/CheckedListBox/ButtonListBox) — đụng tên `CSplitContainer`, `CTabControl`... với GUI Lib.
3. Bỏ hệ **canvas-element interaction** (mouse routing: `SearchInteractObj`, `GetFormUnderCursor`,
   Tooltip*, ZOrder, `m_mouse`, các list canvas-elm; `OnTimer`/`OnDeinit` giờ rỗng) — code chết sau khi bỏ (2).
4. `GStdGraphObj.mqh`: bỏ include `Form.mqh` + `CGStdGraphObjExtToolkit.mqh` và toàn bộ machinery
   "extended object control-point" → dứt điểm đụng độ **CFrame (Trishkin Animations) vs CFrame (Kazharski)**.
   Phần dependent-object/pivot-point giữ nguyên.
5. Fix bug thật: dòng nối chuỗi bằng dấu phẩy (`CMessage::Text(...)  , obj.Symbol(), ...`) → `+`;
   `msg.Clear()` không tồn tại trên string; `GetSizeProperty` dùng nhầm `GetCanvElement` →
   `GetStdGraphObject` (khớp bản gốc DoEasy); khôi phục `ushort idx` bị xoá nhầm trong `OnChartEvent`.
6. **Lazy chart-control**: `CreateNewStdGraphObjectAndGetCtrlObj` tự tạo `CChartObjectsControl` khi
   chưa có (EA mình không gọi `CreateChartControlList()` lúc init như engine DoEasy gốc).
7. **Thứ tự include trong GUIPannel.mqh**: `GraphElementsCollection.mqh` phải include **SAU**
   GUI Lib (`WndEvents.mqh`...) — MQL5 biên dịch phẳng, sai thứ tự là lỗi lan sang `WndContainer.mqh`.

WForms của Trishkin không bị xoá khỏi ổ đĩa — chỉ không include. Khi nào cần thì tách/dùng riêng.

## 4. Xoá Indicator từ bảng Settings (m_table_indicator)

- Col 0 = icon `IMAGE_RESOURCE_BMP16_CLOSE_RED_PNG` (CELL_BUTTON), click = xoá cả template
  (mọi symbol/TF cùng type+params).
- Thứ tự xoá: `DeleteSignal(indicator)` → detach khỏi chart (`ChartIndicatorDelete`) →
  `list.Delete(i)` (FreeMode → `~CIndicatorDE` → `IndicatorRelease`).
- Click KHÔNG xoá ngay: ghi `m_pending_remove_row`, `OnTimerEvent` mới thực thi (tránh mutate bảng
  trong lúc CTable đang xử lý click của chính nó).

## 5. ⚠ VẤN ĐỀ ĐANG MỞ (trao đổi tiếp)

### 5a. Crash `array out of range in Table.mqh (2553,31)` khi xoá indicator — ✅ ĐÃ FIX (2026-07-09)
- **Root cause**: `CTable::DeleteAllRows` và `DeleteRow` **không reset**
  `m_item_index_focus` / `m_prev_item_index_focus` (private, không có API reset). Bảng co lại →
  lần rê chuột sau (LightsHover=true) `DrawRow` đọc `m_rows[index cũ]` → out of range.
- **Fix đã áp (2 phần, đều đã test OK)**:
  - Vá GUI Lib (do user tự thêm, có note `//Modify Library note Add here to fix`): reset 2 field
    về `WRONG_VALUE` trong `Table.mqh::DeleteRow` (trước `RecalculateAndResizeTable`) và
    `DeleteAllRows` (sau `TableSize`). Mouse-move kế tiếp tự vào nhánh `CheckRowFocus()` tính lại.
  - Thiết kế template-driven cho `m_table_indicator` (mục 5c) — hết rebuild định kỳ.
- **Bài học debug**: message lỗi generic, **số dòng là danh tính bug** — crash cũ vẫn báo (2553,31)
  sau khi vá = binary chưa chứa bản vá (line phải shift). So mtime file include vs `.ex5` để chắc.
- Ca phụ (xoá template CUỐI CÙNG): `DeleteRow` không cho bảng xuống dưới 1 hàng vật lý và
  `SetImages` từ chối mảng rỗng → hàng sống sót còn trơ icon. Fix: `AddRow(1)` (hàng trắng do
  `CellInitialize`) rồi `DeleteRow(0)` — hàng trắng dồn lên thay thế.

### 5d. Crash `invalid pointer access in SignalsCollection.mqh (78,12)` — ✅ ĐÃ FIX (2026-07-11)
- **Chuỗi nguyên nhân**: `ImportForeignChartIndicators()` chạy TRƯỚC khi bảng template build lúc
  init → `TemplateExists()` (đọc `m_table_indicator_ptrs`) thấy rỗng → re-import template JSON
  thành bản TRÙNG → `CIndicatorsCollection::AddIndicatorToList` **by design DELETE object trùng**
  (dòng ~543) và trả handle của bản gốc → engine vẫn dùng pointer cũ (đã chết) đưa vào
  `GetOrCreateSignal` → gọi `indicator.TypeIndicator()` trên dangling pointer.
- **Fix 1 (engine)**: thêm `CTimeSeriesEngine::GetIndicatorByHandle(handle)` — sau
  `AddIndicatorToList` KHÔNG BAO GIỜ đụng lại pointer đã truyền vào; re-acquire bản canonical
  theo handle rồi mới `GetOrCreateSignal`. Áp cho cả 2 call site
  (`AddNewIndicatorToAllSeries`, `AddAllIndicatorsToNewSeries`).
- **Fix 2 (GUIPannel)**: `ImportForeignChartIndicators()` chuyển xuống SAU `UpdateGUI(true)`
  trong `OnInitEvent` (bảng template phải có trước thì dup-guard mới hoạt động).
- **LUẬT mới**: pointer truyền vào `AddIndicatorToList` coi như CHẾT sau khi hàm trả về.
- Ghi chú câu hỏi "Collection list IDs" của Trishkin: `COLLECTION_*_ID` (CommonDefines) +
  `m_type`/`m_list.Type(ID)` trong constructor = **định danh runtime** của list (consumer nhận
  `CArrayObj*` check `list.Type()` biết nó thuộc collection nào; CSelect/debug dùng). KHÔNG
  liên quan crash này. `CSignalsCollection` đang dùng mảng thô nên chưa có chỗ gắn ID — muốn
  align chuẩn DoEasy thì refactor sang `CBaseObj` + `CListObj` (CSignalBase phải kế thừa
  CObject) + thêm `COLLECTION_SIGNALS_ID` — ✅ ĐÃ REFACTOR (2026-07-11), đủ CẢ HAI tầng
  theo đúng convention DoEasy (giống CIndicatorDE : CBaseObj):
  - Collection: `CSignalsCollection : CBaseObj` với `CListObj m_list` (OWNED, FreeMode tự
    delete), ctor set `m_type` + `m_list.Type(COLLECTION_SIGNALS_ID)` (0x778A, CommonDefines);
    public API giữ nguyên; thêm `GetList()`/`DataTotal()` theo chuẩn.
  - Item: `CSignalBase : CBaseObj` (không phải CObject trần); thêm 10 entry
    `OBJECT_DE_TYPE_SIGNAL_*` vào cuối enum object-type trong CommonDefines; MỖI subclass
    (SAR/MA/Bollinger/Envelopes/MACD LineCross/ZeroCross/Oscillator/ZeroCross/ADX/TwoLineCross)
    set `this.m_type=OBJECT_DE_TYPE_SIGNAL_<X>` trong constructor — nhận diện được qua `Type()`.

### 5e. Spam `Wrong indicator handle (4807)` — ✅ FIX + VERIFY XONG (2026-07-11, log 19:38/19:40)
> Verify bằng log thật: init sạch (không trùng handle giữa 2 object khác loại, không spam);
> ADD line tay → import ✅; MODIFY params trên chart → replace template + row đổi ruột ✅;
> modify thành params TRÙNG template có sẵn → gỡ row cũ + `rejected: already exists` ✅;
> checkbox Show của line thêm tay tự tick (params-fallback) ✅.
> Debug đã dọn: call `PrintIndicatorsInventory` comment lại (method giữ làm đồ nghề);
> dtor log `~CIndicatorDE releasing` comment lại trong IndicatorDE.mqh (mở lại khi cần săn
> handle); GIỮ audit log: các ngả thoát của `HandleChartIndicatorChange`, entry
> `OnClickRemoveIndicator`, và `handle=/buffer=` trong SeriesDataInd.
- Chẩn đoán 3 tầng: (i) in `handle=/buffer=` vào print lỗi CopyBuffer (`SeriesDataInd.mqh` — GIỮ
  LẠI lâu dài); (ii) `PrintIndicatorsInventory()` in map object↔handle sau init; (iii) log
  `~CIndicatorDE releasing handle=...` bắt mọi release qua destructor.
- **Bằng chứng quyết định (log 07:35)**: JSON có PSAR(0.02)+PSAR(0.04) → handle 10,11. Import
  `SAR(0.05)`/`AMA` nhận LẠI đúng số 10,11 trong khi 2 PSAR JSON còn sống, và KHÔNG có dòng
  `~CIndicatorDE releasing` nào giữa chừng → slot bị giết không qua destructor.
- **LUẬT HANDLE MQL5 (bài học đắt)**: handle là **SLOT toàn chương trình, KHÔNG refcount**.
  `ChartIndicatorGet` trên line của instance mình đang own trả về ĐÚNG SỐ mình đang giữ;
  MỘT phát `IndicatorRelease` giết slot cho cả chương trình. ⇒ pattern "Get xong Release ngay
  để làm observer" (fix trước) chính là hung khí: mỗi lần scan là giết handle của chính mình.
  Hệ quả phụ: slot chết được terminal CẤP LẠI số → indicator khác đọc nhầm buffer ÂM THẦM
  (PSAR đọc data AMA không báo lỗi) — nguy hiểm hơn cả spam.
- **LUẬT VÀNG (Anhnt chốt, đã áp toàn bộ)**: *một chủ — một release*. Toàn chương trình chỉ có
  ĐÚNG MỘT chỗ gọi `IndicatorRelease` là `~CIndicatorDE`. Get thì thoải mái ("hỏi số phòng
  khách sạn" — Get lặp trên cùng instance trả cùng slot, không phình tài nguyên); release là
  "trả phòng" — lễ tân không quan tâm ai hỏi, phòng bị dọn dù chủ thật vẫn đang ở.
- **Handle = JOIN KEY giữa 3 tầng — nhưng CHỈ cho line do EA attach**: line gắn bằng
  `ChartIndicatorAdd(handle của mình)` → chart host đúng instance của mình → Get trả đúng số.
  **Line THÊM TAY là instance RIÊNG của terminal** (bằng chứng log 18:58: line handle=17 vs
  owned=18 cho cùng `SAR(0.05,0.20)`) — terminal KHÔNG share instance chart-hosted với
  instance program-created dù type+params giống hệt.
- **Join 2 tầng chuẩn (đã áp)**: `LineRepresentsIndicator(line_handle, indicator)` — fast path
  so handle (line mình attach); miss thì fallback **type+params** qua
  `IndicatorParameters(line_handle)` (slot của line còn sống mãi vì không ai release, kể cả
  sau khi user đổi params — đọc được params CŨ). `OwnedInstanceOfLine` = phiên bản trả về
  instance. KHÔNG so tên (tên line `SAR(0.05,0.2)` ≠ `ShortName` DE `SAR(BTCUSDm,M1)`).
  Dùng tại: `IsIndicatorShownOnChart`, detach trong `OnClickShowLine`/`OnClickRemoveIndicator`,
  `HandleChartIndicatorChange`. So params tập trung ở `MqlParamsEqual` (cả TYPE_STRING/FLOAT).
- **Hiện thực**: `ChartWnd.mqh` giữ nguyên Get của Trishkin, 0 release (kể cả destructor);
  `GUIPannel.mqh` 0 Get + 0 release — Import/Hide/Remove/shown-check đều đọc gương
  (`GetChart → GetWindowByNum → GetIndicatorByIndex`).
- **Đồng bộ Layer 3 → Layer 1+2 (event, Anhnt chốt 3 case)**:
  - User cắm tay indicator TRÙNG template đang ẩn → Layer 1 không đụng, chỉ tick checkbox
    (import thấy `GetIndicatorByHandle` có chủ → skip).
  - User MODIFY params trên chart → `HandleChartIndicatorChange` (event `IND_CHANGE`):
    handle CŨ từ `GetLastChangedIndicator` → tra ra template Layer 1; handle MỚI từ gương cùng
    index → `IndicatorParameters` → replace = remove template cũ (mọi series) + add template
    mới (mọi series); bảng giữ nguyên số dòng.
  - User XÓA line → visibility-only: Layer 1 giữ template, chỉ bỏ tick checkbox.
- Import 3 indicator thêm tay hoạt động đúng (log: Bands(14), MA(14), SAR(0.05,0.20)) —
  2 hàng MA là ĐÚNG THIẾT KẾ (MA JSON = EMA, MA thêm tay = SMA params khác).

### 5c. Thiết kế lại m_table_indicator: TEMPLATE-DRIVEN, bỏ scan + dedup (ĐÃ CODE - chờ build/test)
> Hiện thực: `SetValuesToIndicatorTable` (build 1 lần + re-point BORROWED ptrs + refresh col4),
> helper `SetIndicatorTemplateRowCells` / `IsIndicatorShownOnChart` / `RefreshIndicatorTableShowStates`,
> `AddIndicatorInstance` (chặn trùng ở nguồn + AddRow thẳng), `OnClickRemoveIndicator` (DeleteRow,
> hết DeleteAllRows). Cache mới: `m_settings_cache_state[]`.
- **Bất biến Layer 1 (đã xác nhận)**: chỉ có MỘT bộ template. Flow:
  1. EA `OnInit` → `CTimeSeriesEngine::OnInitEvent` → `LoadIndicatorFromJSON("indicators_config.json")`
     → nạp template, tạo indicator cho các series hiện có.
  2. Series mới → `AddAllIndicatorsToNewSeries(symbol, period)` → nhân bản đúng bộ template.
  3. ⇒ Series nào cũng có đúng ngần ấy indicator; `m_table_indicator` hiển thị đúng bộ template đó.
- **Hệ quả**: KHÔNG cần "scan instance của symbol hiện tại rồi dedup bằng IsEqual" để suy ngược ra
  template — cách đó là đường vòng. Bộ template chỉ thay đổi tại đúng 3 điểm, và tại cả 3 điểm
  mình ĐÃ CÓ SẴN đầy đủ type+params:
  - Sau `LoadIndicatorFromJSON`: build bảng 1 lần từ danh sách vừa nạp.
  - `OnClickAddIndicator`: có type+params ngay từ form → `AddRow` thẳng vào bảng (không rescan).
  - `OnClickRemoveIndicator`: xoá đúng hàng đó.
- **Refresh thường (CHARTCHANGE/timer)**: không đụng cấu trúc hàng; chỉ dirty-check cột 4 "Show"
  (`ChartIndicatorName` theo chart hiện tại) — và sau này trạng thái Buy/Sell cột 2/3.
- Dedup `IsEqual` hiện tại thực chất chỉ đang che ca "add trùng template 2 lần" — nếu cần chống
  trùng thì chặn ở NGUỒN (`OnClickAddIndicator` từ chối template đã tồn tại), không phải ở display.
- Câu hỏi mở kèm theo: bảng template ngắn → có cần `IsSortMode(true)` nữa không? (đề xuất: tắt,
  khỏi cần row-identity remap như bảng Trade).

### 5b. Arrow/Thumb không thấy trên chart — ✅ FIX ĐÃ ÁP (2026-07-11, chờ test)
- **Root cause**: lúc EA vừa khởi động, dữ liệu bar cũ chưa sync → `iBarShift`/`CopyLow/High`
  fail → `lo[0]=0` → arrow vẽ ở giá ≈ 0 (ngoài viewport). Watermark vẫn tiến → không vẽ lại.
  Các lần restart sau, check `ObjectFind` thấy "đã có" → giữ nguyên arrow hỏng vĩnh viễn.
- **Fix đã áp trong `DrawSignalArrows`**: (i) chỉ tạo object khi shift ≥ 0 + `CopyLow/High`
  trả 1 + `lo[0] > 0`; fail thì ghi `failed_oldest` và watermark KHÔNG vượt qua nó (tick sau
  thử lại, arrow đã vẽ được ObjectFind bỏ qua rẻ tiền); (ii) watermark = 0 (fresh start /
  sau toggle) → `ObjectsDeleteAll(chart, "<prog>_sig_<sym>_<tf>_")` dọn sạch rồi vẽ lại.
- Flood "Such a graphic object already exists" đã chặn bằng check `ObjectFind` trước khi tạo.

### 5f. Checkbox Buy/Sell (col 2/3) — ✅ WIRED (2026-07-11, chờ test)
- Ý nghĩa: **bộ lọc opt-in theo template** cho arrow trên chart hiện tại — tick Buy = vẽ arrow
  BUY của template đó, tick Sell = vẽ SELL; cả hai off (mặc định) = template đó không tạo
  Signal, không vẽ gì.
- Cơ chế: `DrawSignalArrows` đọc trực tiếp trạng thái checkbox (image 0 = tick) qua
  `SelectedImageIndex(2/3, row)`, map row bằng pointer instance (ptrs giữ đúng instance
  sym/tf hiện tại). Toggle handler chỉ gọi `ResetSignalArrows()` = watermark về 0 + xóa
  object prefix → tick kế tiếp vẽ lại toàn bộ theo filter mới.
- Signal đã wired trong `GetOrCreateSignal` (bản nháp đầu "vẽ ra xem đã", Anhnt duyệt
  2026-07-11, tinh chỉnh rule từng loại sau):
  | Indicator | Signal class | Rule nháp |
  |---|---|---|
  | SAR | `CSignalSAR` | giá đổi phía so với chấm SAR |
  | MA, AMA | `CSignalMA` | hướng dốc buffer 0 |
  | RSI | `CSignalOscillator(70,30)` | vượt ngưỡng quá mua/quá bán |
  | MACD | `CSignalTwoLineCross(0,1)` | main cắt signal line |
  | BBands | `CSignalBollinger` | close vượt band trên/dưới |
  - ATR: không có hướng — không wire. Còn lại chưa nối: ADX/ADXW (`CSignalADX`),
    Envelopes (`CSignalEnvelopes`), Stochastic/RVI/Alligator (`CSignalTwoLineCross` +
    SetBuffers/SetGate), họ MA khác (DEMA/TEMA/FRAMA/VIDYA → `CSignalMA`) — nối 1 dòng
    case khi cần.

### 5g. CWindow resize-Y quá nhỏ làm nội dung tab tràn ra ngoài (Marker tab) — ⚠ CHƯA FIX (phát hiện 2026-08-13)
- **Triệu chứng**: kéo cạnh dưới `m_window_main` (CWindow, GUI Lib Anatoli Kazharski) thu hẹp
  theo Y — nội dung tab Marker (combobox, label, nút Save) không co/ẩn theo mà đứng nguyên ở
  toạ độ tuyệt đối cũ, tràn hẳn ra ngoài khung cửa sổ đã bị co, đè lên status bar và chart.
  Biểu hiện dễ thấy nhất: 4 ô chữ nhật trắng (preview icon cột "Sell" hàng 0-3: Single/Multi/
  Pattern/Combo) lộ ra ngoài panel — chỉ là phần dễ nhìn thấy của hiện tượng tràn, không phải
  bug riêng của ListView/ComboBox.
- **Root cause (xác nhận qua đọc code, KHÔNG phải Library bug)**:
  `GUIPannel_Define.mqh:40-42` — `M_WINDOW_MAIN_HEIGHT=480` (đúng, đủ cho tab Marker: tự tính
  9 hàng × (ROW_HEIGHT 26 + ROW_GAP 10) + caption/tab-header ≈ 480), nhưng
  `M_WINDOW_MAIN_MIN_HEIGHT=200` — quá nhỏ so với nhu cầu thật. `MinimumYSize()`
  (`GUIPannel_MainWindows.mqh:26`) dùng đúng constant này làm giới hạn kéo-resize của Library —
  Library tự nó không có gì sai, chỉ là bị truyền giới hạn sai từ EA-local code.
- **Hướng fix (chưa áp, EA-local, KHÔNG cần đụng Library)**: tăng `M_WINDOW_MAIN_MIN_HEIGHT`
  lên gần/bằng `M_WINDOW_MAIN_HEIGHT` (480), hoặc tính theo chiều cao thật cần của tab cao nhất,
  để Library tự chặn user kéo hẹp quá mức — không cần sửa `Window.mqh`/`ComboBox.mqh`/`ListView.mqh`.
- Điều tra phụ (không phải nguyên nhân, nhưng đã lần qua khi tìm bug): chuỗi resize-Y của Library
  — `CWindow::ChangeWindowHeight` → event `ON_WINDOW_CHANGE_YSIZE` →
  `CWndEvents::OnWindowChangeYSize` (`Moving()` + chỉ touch `m_auto_y_resize_elements`) —
  `CListView::Hide()/Show()/Moving()` (`ListView.mqh` dòng 780-849) — logic Hide/Show dùng
  `OBJPROP_TIMEFRAMES=OBJ_NO_PERIODS`, đọc code thấy đúng, không phải nguồn bug.

## 6. Quy ước code đã thống nhất

- Pointer: `CIndicatorDE*` đặt tên `indicator`, `CSignalBase*` đặt tên `signal`; member khai báo
  kèm comment **OWNED** (ai tạo/ai xoá) hoặc **BORROWED** (ai own thật).
- Update/Refresh: theo convention `Refresh*` của `CIndicatorsCollection` (không dùng `Update`).
- Declaration/Implementation tách bạch; inline chỉ cho getter/setter 1-expression thật sự.
- Mỗi class một file (GStdGraphObj còn chứa 3 class PivotPoint* — chấp nhận, helper nhỏ, để sau).
- Include guard KHÔNG trùng tên enum/type (vụ `ENUM_SIGNAL_DIR` → guard `_DEFINED`).
- Không switch-fallthrough gom case; mỗi case thân riêng.

## 7. Việc xếp hàng chờ

1. Chốt & sửa 5a (Table crash) + 5b (arrow invisible).
2. Bar Info window (hover + giữ Ctrl trên bar → `CWindow` nổi kiểu `ShowIndicatorParameterForm`,
   list các signal tại bar đó; V3 có `CInfoPannel` làm mẫu, V7 sẽ là control trong CGUIPannel).
3. Wire các Signal còn lại (RSI/MACD/ADX/Bands/Crossover) vào `GetOrCreateSignal` sau khi chốt
   ý tưởng từng loại; Bollinger cần nhiều cặp signal (3 line × Buy/Sell).
4. Persist việc xoá indicator vào JSON (hiện xoá xong restart là template quay lại).
5. Buy/Sell checkbox (col 2/3 bảng Settings) đang là stub TODO.
6. Sort bảng Trade: đã fix theo row-identity (đọc lại Col0/1/2 mỗi tick) — theo dõi thêm.
7. Sửa 5g (`M_WINDOW_MAIN_MIN_HEIGHT` quá nhỏ, `GUIPannel_Define.mqh:42`) — tăng lên gần/bằng
   `M_WINDOW_MAIN_HEIGHT` (480) để chặn resize-Y tràn nội dung tab Marker.
