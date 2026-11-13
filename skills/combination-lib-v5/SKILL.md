---
name: combination-lib-v5
description: Rules and conventions for writing MQL5 and Python code on Anhnt's Combination Lib V5 (D:\MT5-Dev\Library, MQL5\Include\Combination Lib V5) and EA V5 — RAM vs DB, events, collections vs managers, naming, comments, debug prints, GUI Lib traps. Use whenever editing or designing code in D:\MT5-Dev (Library, EA V5, GUIPannel, Library\Python), or any file that includes <Combination Lib V5\...>.
---

# Combination Lib V5

Luật gốc của Anhnt: `Experts\Anhnt\Example EA\4. Combination EA V5\Readme\Readme.md`
và `CommonRule.md`. Skill này gom các luật đó cùng những lỗi agent đã lặp lại.
Khi skill và Readme khác nhau, **Readme thắng**; báo lại để sửa skill.
Cách sửa repo (lệnh, quy trình, ranh giới): [`AGENTS.md`](../../AGENTS.md).

## Rules gate: chạy trước mọi đề xuất, ghi kết quả vào đề xuất

1. **No Duplicate**: cái này đã được tính hoặc có sẵn ở đâu chưa (Library, base class, MT5, Python)?
2. **MVC**: đây là Model (DB, Manager), Controller (EA, Manager OnInit) hay View (EA vẽ, TradeCanvas)? View chỉ nhận data và hiển thị, không tính, không lọc.
3. **Event Rule**: class nào đổi data thì class đó tự fire event; listener có cần đổi không?
4. **Sync Everywhere**: liệt kê mọi thứ phải đổi theo: MQL ↔ Python ↔ `Python.md` ↔ ghi chú; EA vẽ ↔ TradeCanvas vẽ.
5. **Conventions**: các luật đặt tên và cấu trúc bên dưới.

## Rules that avoid most bugs

1. **RAM object = nạp từ DB một lần + tự tính live + event.** Mọi object làm việc trên RAM (CSignal, CBarControl, CStrategyBase, CIndicatorDE…) nạp từ DB lần đầu, sau đó tự tính các bar mới trên RAM và fire event. Python tính y hệt và **là bên duy nhất ghi kết quả vào DB**. EA/Library không bao giờ ghi kết quả. Không bao giờ hỏi "bên nào tính".
2. **Setting khác result.** EA và các Manager CREATE mọi table (kể cả result table) và ghi `Setting_*`. Web (server.py → libdb) cũng được sửa `Setting_*`, rồi báo Python tính lại. Dữ liệu thô MT5 đã có (tick, bar) chỉ ở RAM, không đưa vào DB.
3. **Manager khác Collection.** Manager = bản RAM của một table `Setting_*` (`Read_RAM`, `ReadDataFromDB`, `UpdateDataToDB`). Collection = danh sách entity (`m_list`), **dùng** Manager; data nằm ở các con (CIndicatorDE → CIndicatorSeriesDE). Collection giữ tên trước commit ff8686f4 (`GetIndicator`, `AddSeries_…`, `CreateSeries`); kiểm tra bằng `git show` trước khi đổi tên. Bỏ phần tính toán thì chỉ xoá các dòng tính, không xoá container.
4. **Dữ liệu trên RAM là object trong `CArrayObj`.** Tên list: `m_list_Table_<Table>` (bản sao của table), `m_list_Pending_<Table>` (chỉ RAM, chưa ghi), `m_list_<Con>` (list con). Không dùng `struct S…Row` + `m_rows[]`.
5. **Kiểm tra cái kế thừa trước.** CBaseObj đã có `m_available`, `m_first_start`, `m_object_type`, `GetFolderName()`. CBaseObjExt đã có `EventAdd`, `m_list_events`, `m_is_event`, `m_event_code`, `CheckEvents`. Class đổi data thì kế thừa CBaseObjExt. Không override `CBaseObjExt::Refresh`; đặt tên `RefreshX` (RefreshSeries, RefreshAccount…).
6. **Sửa method cũ, đừng thêm method song song.** Grep class đó (và CSymbol, CMarketCollection, `CommonDELib.mqh`, `CommonDefines.mqh`) tìm method hoặc enum sẵn có trước khi viết. Member, tham số hay enum mới: báo và chờ đồng ý trước.
7. **"Không ai gọi" chưa chắc là dead code.** Tra lineage DoEasy → V1 → V2 → V3 → V4. Method public của bản gốc chưa được port thì giữ lại. Code Anhnt tự comment out là thay thế có chủ ý: không bật lại.
8. **Event params mang đủ thông tin** để listener không phải hỏi lại (đóng gói như `CBaseObjExt::CheckEvents`). Con fire event, cha quản lý con và relay, anh chị em cùng nghe. Gọi theo event, không poll bằng timer hay tick.
9. **Chart change (REASON_CHARTCHANGE/PARAMETERS) không ghi gì và không tạo lại gì.** Class dùng guard `m_first_start`. Đọc luôn `new`/`delete` trong OnInit/OnDeinit của EA cho object đó trong cùng lượt.
10. **Logic thuần thuộc về Engine/Manager, không thuộc CGUIPannel.** Method không đụng control GUI thì không đặt trong CGUIPannel. Data đổi trước, Layer 1 theo sau.
11. **Đổi tên class khi port:** một dòng dưới header box `//--- Change from V1 <path>: renamed COld -> CNew (reason)`. Class mới: `//--- New in V5 (...)`. Giữ nguyên tên member của vendor.
12. **Mỗi class một file**, có include guard. Chỉ getter/setter một biểu thức mới viết inline. Module: `<Class>_Define.mqh`, `<Class>.mqh`, `<Class>_Lifecycle.mqh`, `<Class>_Window_<Name>.mqh`.
13. **Comment tiếng Anh, tối đa một dòng**, chỉ cho điều không hiển nhiên. Không viết banner kể chuyện, không gắn tag tên/ngày. Header của method theo khung `//+---+` trong CommonRule.md. Python: docstring một dòng.
14. **Debug print:** `::Print("MY DEBUG CClass::Method: …")`. Dòng log nói rõ đơn vị và ngữ cảnh ("1311 rows on 709 of the 1000 bars"). Ghi file chỉ vào `MQL5\Files\<program>\` qua `GetFolderName()`.
15. **Dùng enum, không dùng số trần.** Ưu tiên enum của MT5. Enum dùng chung đặt trong `CommonDefines.mqh`, enum riêng đặt trong class. Mỗi `case` của `switch` có thân riêng, không fallthrough.
16. **Python theo cùng các luật trên:** đặt tên theo table/class, không chép tay hằng số (đọc từ DB). Python làm việc nặng; join, đăng ký symbol và các việc nhỏ thì Library làm. Quy tắc job (context/right): `Library\Python\Python.md`.

## References

- [references/gui-lib.md](references/gui-lib.md): các bẫy của GUI Lib (CElement Update, CTable, Show cascade, ComboBox).
- Readme V5: `Readme.md` (kiến trúc, DB, worker Python), `CommonRule.md` (coding rule, đặt tên), `Update\Update.md` (lịch sử phiên bản).
