# Bug: Add Indicator (GUI) → handle=-1 → CSeriesDataInd::Refresh lỗi vô hạn — ✅ ĐÃ FIX (2026-08-17)

**Root cause thật sự**: `AddIndicatorInstance()` gọi lạc chỗ, bên TRONG vòng `for` xây `params[]` (`GUIPannel_TabSettingIndicator.mqh`, `OnClickAddIndicator`) → mỗi cú Add gọi `IndicatorCreate()` `total` lần với params CHƯA điền đủ (trừ lần cuối) → native MT5 fail "cannot load [4804]" → cộng với bug phụ `AddIndicatorToList` không check handle trước `SeriesCreate` → indicator fail bị kẹt vĩnh viễn trong `m_list` → spam `CSeriesDataInd::Refresh` mỗi tick mãi mãi. Fix: đưa `AddIndicatorInstance()` ra ngoài vòng `for`, gọi đúng 1 lần. Xem chi tiết chuỗi rà soát ở dưới.

## Triệu chứng (Anhnt, 2026-08-16)

Bấm **Add** trên tab Settings → Indicator (thêm mới "Moving Average", Period=14, Method=EMA, Applied Price=Close), thay vì thêm thành công, Journal spam liên tục vô hạn:

```
CSeriesDataInd::Refresh: Failed to get the current data of the indicator buffer BTCUSDm M1. Error : Wrong indicator handle(4807), handle=-1, buffer=0
CSeriesDataInd::Refresh: Failed to get the current data of the indicator buffer BTCUSDm M5. Error : Wrong indicator handle(4807), handle=-1, buffer=0
CSeriesDataInd::Refresh: Failed to get the current data of the indicator buffer BTCUSDm M15. Error : Wrong indicator handle(4807), handle=-1, buffer=0
```
(lặp lại mỗi tick, mãi mãi, cho tới khi EA restart)

## Root cause thật (đọc log gốc lúc bấm Add, 22:58:20.212)

```
indicator Moving Average cannot load [4804]
CSeriesDataInd::Create: Failed to get indicator data timeseries BTCUSDm M15. Error : Wrong indicator handle(4807), handle=-1, buffer=0
indicator Moving Average cannot load [4804]
CSeriesDataInd::Create: Failed to get indicator data timeseries BTCUSDm M1. Error : Wrong indicator handle(4807), handle=-1, buffer=0
indicator Moving Average cannot load [4804]
CSeriesDataInd::Create: Failed to get indicator data timeseries BTCUSDm M5. Error : Wrong indicator handle(4807), handle=-1, buffer=0
indicator Moving Average cannot load [4804]
```

`"indicator Moving Average cannot load [4804]"` là message GỐC của chính MT5 terminal (không phải code EA in ra) — `::IndicatorCreate()` thật sự KHÔNG tạo được indicator, cho liên tiếp 3-4 Series (M15/M1/M5/M15) của BTCUSDm cùng lúc, dù tham số (14, EMA, Close) đều hợp lệ.

## Giả thuyết ĐÃ LOẠI TRỪ

- **"Series chưa sync/mới tạo"** (giả thuyết dùng cho case handle=-1 đầu tiên tối nay, lúc XAUUSDm H1 mới attach) — **KHÔNG áp dụng được ở đây**: Anhnt xác nhận cả 9 Series (BTCUSDm M1/M5/M15/M30, XAUUSDm M1/M5/M15/M30/H1) đã chạy ổn định từ lâu (đang có CloseBar liên tục), không phải series mới tinh.

## Giả thuyết đang nghi (CHƯA xác nhận)

- **MT5 terminal chạm giới hạn số lượng indicator handle đang mở cùng lúc.** Phiên làm việc tối nay đã chạy rất nhiều giờ, qua rất nhiều lần Compile/Attach/Add (BBands + PSAR×2 + AMA + ATR × 9 Series ≈ 45 handle đã cấp phát, cộng dồn qua nhiều lần recompile có thể chưa release hết handle cũ).
- **Test đề xuất để xác nhận**: đóng hẳn MT5 (không chỉ detach EA) → mở lại → attach EA → thử Add lại đúng Moving Average đó. Nếu load được bình thường thì xác nhận đúng nguyên nhân là tích lũy handle qua phiên dài, không phải bug logic trong code EA/Library.

## Bug phụ đã xác nhận chắc chắn (độc lập với nguyên nhân gốc ở trên)

`CIndicatorsCollection::AddIndicatorToList()` (Library, `IndicatorsCollection.mqh`) **không hề check `indicator.Handle() != INVALID_HANDLE` trước khi gọi `SeriesCreate()`**:

```cpp
int CIndicatorsCollection::AddIndicatorToList(CIndicatorDE *indicator, const int id, const int buffers_total, const uint required=0)
 {
   ...
   indicator.SetBuffersTotal(buffers_total);
   this.SeriesCreate(indicator, required);   // <- chạy vô điều kiện, kể cả khi Handle() == -1
   return indicator.Handle();
 }
```

Nên dù `IndicatorCreate()` (bên trong `CIndicatorDE` constructor, `IndicatorDE.mqh:162`) fail thật sự (trả -1) vì BẤT KỲ lý do gì (limit handle, tham số sai, series chưa sync...), code vẫn cứ tiếp tục gọi `SeriesCreate()` → `CopyBuffer(-1, ...)` → lỗi 4807 lặp lại **mãi mãi mỗi tick**, không có cơ chế dừng/retry/dọn dẹp nào. Đây chính là cơ chế chung đứng sau CẢ 2 lần gặp handle=-1 tối nay (lần đầu lúc XAUUSDm H1 mới attach, lần này lúc Add Moving Average) — chỉ khác nhau ở lý do khiến `IndicatorCreate()` fail ban đầu.

## Hướng sửa đã bàn (CHƯA code, đang chờ quyết định)

1. **Sửa ở Library** (`AddIndicatorToList`): check `indicator.Handle() != INVALID_HANDLE` trước khi gọi `SeriesCreate()` — nếu fail thì bỏ qua/return sớm thay vì spam log vô hạn. Sửa tận gốc, áp dụng cho MỌI nơi gọi hàm này (JSON load, GUI Add, AddAllIndicatorsToNewSeries...).
2. **Sửa ở EA** (giãn timing tạo indicator hàng loạt, tránh gọi `IndicatorCreate()` dồn dập liên tiếp) — không đụng Library, nhưng chỉ giảm khả năng xảy ra, không chặn hẳn nếu nguyên nhân là do limit handle thật sự.
3. Có thể cần làm CẢ 2 nếu nguyên nhân gốc (giả thuyết "chạm limit handle") được xác nhận đúng — giãn timing giảm khả năng chạm limit, check handle chặn hậu quả nếu vẫn chạm.

## Trạng thái

- [x] Xác nhận root cause thật qua log gốc (`indicator Moving Average cannot load [4804]`)
- [x] Loại trừ giả thuyết "series chưa sync"
- [x] Xác nhận bug phụ trong `AddIndicatorToList` (không check handle) — chắc chắn, đọc code trực tiếp
- [ ] Test xác nhận giả thuyết "limit handle tích lũy qua phiên dài" (đóng mở lại MT5, thử Add lại)
- [ ] Chưa code fix nào — đang chờ Anhnt chọn hướng (1/2/3 ở trên) sau khi có kết quả test

## File liên quan

- `Vendors\Anhnt\Library\4. Combination Lib\Collections\IndicatorsCollection.mqh` (`AddIndicatorToList`, Library — cần bàn trước khi sửa)
- `Vendors\Anhnt\Library\4. Combination Lib\Timeseries\Indicators\IndicatorDE.mqh` (`IndicatorCreate()` gọi trong constructor, Library)
- `Vendors\Anhnt\Library\4. Combination Lib\Timeseries\Indicators\SeriesDataInd.mqh` (`CSeriesDataInd::Create`/`Refresh`, nơi log lỗi hiện ra)
- `Artyom Trishkin\TimeSeriesEngine_Indicator.mqh` (`AddNewIndicatorToAllSeries` — EA-local, nơi Add indicator gọi xuống Library)

## Rà soát bổ sung (Claude, 2026-08-17) — đọc trực tiếp code hiện tại, không đoán

Xác nhận lại 2 claim cũ trong BugNote vẫn đúng với code hiện tại (chưa bị sửa/lệch so với lúc note):
- `IndicatorDE.mqh:162` — constructor lưu `handle` vào `m_long_prop[INDICATOR_PROP_HANDLE]` vô điều kiện, không check `IndicatorCreate()` trả về gì (kể cả `-1`).
- `IndicatorsCollection.mqh:534` (`AddIndicatorToList`) — vẫn gọi `SeriesCreate()` vô điều kiện, không check `indicator.Handle() != INVALID_HANDLE` trước.

Lần thêm được: cơ chế chính xác khiến lỗi lặp **mỗi tick, mãi mãi** (chứ không chỉ tại thời điểm bấm Add) — đọc từng bước trong code, chưa test runtime để xác nhận cuối:

1. `AddIndicatorToList` add indicator (handle=-1) vào `m_list` thành công (con trỏ hợp lệ, chỉ handle *bên trong* nó invalid) → gọi `SeriesCreate()` → `Create()` (`SeriesDataInd.mqh:187`) gọi `CopyBuffer(-1,...)` fail, in log lỗi lần đầu (khớp log gốc "cannot load [4804]"), return sớm.
2. `AddNewIndicatorToAllSeries` (`TimeSeriesEngine_Indicator.mqh:79`): thấy `handle==INVALID_HANDLE` thì chỉ `continue` (bỏ tạo Signal) — **không remove indicator khỏi `m_list`**. Đối tượng "zombie" handle=-1 ở lại vĩnh viễn trong collection.
3. `CSeriesDataInd::m_available` mặc định `= true` (`BaseObj.mqh:69`), không nơi nào set `false` khi `Create()` fail → check chặn sớm ở đầu `Refresh()` (`SeriesDataInd.mqh:282`) không bao giờ kích hoạt cho object này.
4. Trong `Refresh()`: nhánh "bar mới" (dòng 300) gọi `CopyBuffer` cho buffer 0, fail → `return` ngay dòng 312-313, **trước khi** `SaveNewBarTime()` (dòng 329) kịp chạy → `IsNewBarManual()` do đó cứ trả `true` mãi mãi ở lần gọi kế tiếp → vòng lặp fail-return-fail-return diễn ra mỗi tick, in đúng message `"CSeriesDataInd::Refresh: Failed to get the current data..."` — khớp 100% log spam.
5. Hàm gọi `Refresh()` mỗi tick là `SeriesRefreshBySymbol()` (`IndicatorsCollection.mqh:2660`, gọi từ `TimeSeriesEngine_Lifecycle.mqh:98`) duyệt **toàn bộ `m_list`** không check handle — đây là vòng lặp khiến log lặp mỗi tick tới khi restart EA.

**Suy luận (chưa test runtime để xác nhận cuối):** bug phụ trong `AddIndicatorToList` không phải bug độc lập — nó là nguyên nhân khiến indicator lỗi bị kẹt vĩnh viễn trong collection và lặp mỗi tick, bất kể lý do gốc khiến `IndicatorCreate()` fail là gì (limit handle hay lý do khác). Giả thuyết "chạm limit handle" ở trên vẫn CHƯA xác nhận được bằng code — cần Anhnt tự test đóng/mở MT5 như đã đề ra.

**Điểm Anhnt thấy "vô lý" (đã làm rõ):** tại sao `SeriesCreate()` chỉ fail đúng 1 lần lúc Add, trong khi nhánh OnInit gọi `SeriesCreate` "cả mớ" (load JSON template lúc khởi động) không sao?

→ Verify: `TimeSeriesEngine_JSONConfig.mqh:159` (`LoadIndicatorTemplateFromJSON`, chạy lúc OnInit) gọi thẳng `AddNewIndicatorToAllSeries(type, params)` — **chính xác cùng một hàm** mà nút Add trên GUI gọi lúc runtime. Không có nhánh code riêng nào cho OnInit cả. `SeriesCreate()` (`IndicatorsCollection.mqh:2606`) chỉ mù quáng lấy `indicator.Handle()` hiện có rồi gọi `buffers_data.Create()` — không hề phân biệt "OnInit" hay "runtime Add".

→ Kết luận: `SeriesCreate()` không phải là chỗ khác nhau. Chỗ khác nhau thật sự nằm ở bước TRƯỚC nó — `::IndicatorCreate()` (native MT5, gọi trong `CIndicatorDE` constructor, `IndicatorDE.mqh:162`) — hàm này thành công cho cả ~45 lần lúc OnInit (EA vừa attach) nhưng fail đúng 1 lần lúc Add (sau nhiều giờ chạy, nhiều lần Compile/Attach/Add). Đây chính là giả thuyết "chạm limit handle tích lũy qua phiên dài" đã nêu ở trên — code đọc tới đây là hết, không suy ra thêm được gì nữa, phải test runtime thật (đóng hẳn MT5, mở lại, Add lại) mới xác nhận được.

**Đề xuất fix (chưa code, đang chờ quyết định)**: trong `AddIndicatorToList`, sau khi add vào `m_list`, check `indicator.Handle()==INVALID_HANDLE` — nếu đúng thì `this.m_list.Delete(index)` (gỡ khỏi list) và `return INVALID_HANDLE` sớm, không gọi `SetBuffersTotal`/`SeriesCreate`. Đây là sửa Library, cần bàn trước khi đụng theo Working Rule.

## Rà soát dedup Layer 1 ↔ Layer 3 (Claude, 2026-08-17) — theo yêu cầu Anhnt kiểm tra lại

Anhnt nghi ngờ: có thể việc KHÔNG dedup đúng giữa Template ở Layer 1 và Indicator cắm tay trên Chart (Layer 3) là nguồn góp phần làm cạn handle. Đọc code xác nhận cơ chế dedup **đã tồn tại và đúng**, không thấy lỗ hổng:

- Định danh Template = type + params (symbol/TF không tính), so bằng `IsEqualMqlParamArrays()` (`TimeseriesDELib.mqh:452`) — so từng field, double có `NormalizeDouble` tránh lỗi làm tròn.
- `TemplateExists(type, params)` (`IndicatorsCollection.mqh:587`) được gọi ở CẢ 2 cửa: nút Add GUI (`AddIndicatorInstance`, `GUIPannel_TabSettingIndicator.mqh:809`) và import indicator cắm tay trên Chart (`ImportForeignChartIndicators`, cùng file dòng 1200).
- `ImportForeignChartIndicators()` còn có lớp chặn trước cả `TemplateExists`: nếu handle trên Chart đã thuộc Layer 1 rồi (`GetIndicatorByHandle(handle)!=NULL`, dòng 1189-1192) thì bỏ qua ngay — tránh hiểu nhầm checkbox Show/Hide của chính mình (`ChartIndicatorAdd`) là indicator lạ.
- Cơ chế này ĐÃ từng có bug thật (đã fix 2026-07-11, xem `FeatureNote/BugNote.md` mục 5d): `ImportForeignChartIndicators()` chạy trước khi bảng template dựng xong lúc init → `TemplateExists()` đọc nhầm bảng rỗng → import trùng → crash dangling pointer. Fix: chuyển chạy xuống sau `UpdateGUI(true)`.

**Kết luận:** dedup logic đọc code hiện tại không có lỗ hổng, không phải nguyên nhân trực tiếp gây handle=-1 tối nay. Nhưng có 1 điểm by-design đáng lưu ý: 1 Template mới = tạo indicator trên MỌI symbol/TF đang track (`AddNewIndicatorToAllSeries` lặp hết MarketWatch × TF) → khớp với ước tính cũ "BBands+PSAR×2+AMA+ATR × 9 Series ≈ 45 handle" — mỗi Template mới nhân với số Series, có thể là phần lớn lý do handle cộng dồn nhanh qua phiên dài, dù dedup hoạt động đúng (không phải bug, chỉ là số lượng lớn theo thiết kế).

## ROOT CAUSE THẬT SỰ tìm ra (Claude, 2026-08-17) — `AddIndicatorInstance()` gọi SAI VỊ TRÍ, bên trong vòng for xây params

Anhnt nghi vấn: lúc bấm Add, nếu không lấy đủ Parameter trên Form thì `IndicatorCreate()` sẽ fail. Đọc `CGUIPannel::OnClickAddIndicator()` (`GUIPannel_TabSettingIndicator.mqh:686-724`) xác nhận ĐÚNG, và lộ ra bug cụ thể:

```cpp
for(int i = 0; i < total; i++)
 {
  params[i].type = schema[i].data_type;
  ... // gán params[i] theo Form (Combo hoặc TextEdit)
  AddIndicatorInstance(m_current_param_type_li, m_current_param_type, params);  // <- dòng 722, NẰM TRONG VÒNG FOR
 }
```

`AddIndicatorInstance()` (nơi thực sự gọi xuống `AddNewIndicatorToAllSeries` → `IndicatorCreate`) bị gọi **`total` lần** (MA có `total=4`: Period, Shift, Method, Applied Price — schema `IndicatorPara.mqh:17` + `TimeseriesDELib.mqh:178-181`) thay vì đúng 1 lần sau khi `params[]` đã điền xong hết. Mỗi vòng lặp `i`, `params[]` (khai báo 1 lần ngoài vòng for, KHÔNG reset mỗi vòng) chỉ mới điền đúng tới index `i` — các slot `i+1..total-1` vẫn rỗng (`MqlParam` mặc định 0/"").

Với MA(14, 0, EMA, Close):
- i=0: chỉ `Period` đúng, `Shift/Method/Applied Price` rỗng → `IndicatorCreate()` THIẾU tham số hợp lệ → fail → **"indicator Moving Average cannot load [4804]"** — khớp 100% log gốc.
- i=1: `Period+Shift` đúng, `Method/Applied Price` rỗng → fail.
- i=2: `Period+Shift+Method` đúng, `Applied Price` rỗng → fail.
- i=3: cả 4 đúng đủ — lần NÀY mới hợp lệ thật sự.

Mỗi lần fail lại chạy `AddNewIndicatorToAllSeries` trên toàn bộ 9 Series (và bị kẹt vĩnh viễn trong `m_list` do bug ở `AddIndicatorToList` đã ghi ở trên) → **1 cú bấm Add tạo ra 3×9=27 lần `IndicatorCreate()` fail-và-kẹt**, trước khi tới lần thứ 4 (tham số đúng) mới có cơ hội chạy đúng. Rất có khả năng chính 27 lần xin/fail dồn dập này tự đốt quỹ handle của MT5 ngay trong 1 cú bấm, khiến cả lần thứ 4 (dù tham số đủ, đúng) cũng bị vạ lây fail theo — nối liền với giả thuyết "tích lũy handle" (không cần đợi nhiều giờ, chỉ 1 lần bấm Add cũng đủ).

**Fix đã áp (Anhnt tự sửa, Claude double-check 2026-08-17)**: đưa `AddIndicatorInstance(m_current_param_type_li, m_current_param_type, params);` ra NGOÀI vòng `for` trong `OnClickAddIndicator()` — giờ nằm sau dấu `}` đóng vòng lặp, gọi đúng 1 lần khi `params[]` đã điền đủ cả `total` phần tử. Đã soát lại ngoặc/thụt lề, khớp đúng ý đồ fix, không lệch cú pháp.

- [ ] Chờ Anhnt build + test lại: Add Moving Average (14, 0, EMA, Close) trên chart, xác nhận hết spam `handle=-1` và indicator load được bình thường.
