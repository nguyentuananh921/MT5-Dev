2026 1026: Modification note.
* CAccount: ACCOUNT_PROP_NAME gộp với m_name của Class CBaseObj
2026 1027: Rà soát lại 
 - CBar. 
   + BAR_PROP_SPREAD là spead tương ứng với mỗi CBar và sẽ ảnh hướng tới Orders 
   + Thêm 2 Propeties mới: BAR_PROP_INFOR_TYPE,BAR_PROP_SIDE
 - CBar, CBarSeriesDE, CbarTimeSeriesDE, CbarTimeSeriesCollection.
 [] CBarTimeSeriesCollection::OnInitEvent
    └── CBarTimeSeriesDE            // một object cho mỗi symbol
        └── CBarSeriesDE            // một object cho mỗi timeframe 
 [] CBarMarkerSync: Đang đọc từ Database.   
- COrder:  
[] Problem note
 - Ở Library cũ khi mọi chuyện làm việc trên RAM nên các Event rất dễ xử lý.
 - Ở Library mới do có Database nên việc quyết định ghi cái Event nào lên Database là một vấn đề.
[] Sự kiện đổi tham số của CBarInformationManager chưa ai nghe, nên kết quả cũ không được tính lại.
[] Cần rà lại cùng nhau base class CBarTimeSeriesDE, tức CBaseObjExt, và chuỗi NewBar, SendEvent, EventAdd, SetEvents.
[] ENUM_PATTERN_DIRECTION không ai dùng và trùng ENUM_BAR_SIDE. 
  Sẽ phải thống nhất thành 1:
    ENUM_SIGNAL_DIRECTION
    {
     ENUM_SIGNAL_DIRECTION_BUY
     ENUM_SIGNAL_DIRECTION_SELL
     ENUM_SIGNAL_DIRECTION_NONE
    }
   - Đổi luôn tên field side trong table BarTimeSeriesCollection -> signal_direction
[] Python còn chép tay SIDE.
[] Các giá trị đổi theo tick của accounts như balance, equity chỉ được ghi trong OnInit.
[] Chưa quyết định Event nào được ghi xuống DB.
[] RiskManagement mới ở mức khai báo: RiskManagementDefine.mqh với ENUM_RISK_MODE, RiskManagementSetting.mqh đang là bản cũ, và RiskManagementSettingManager.mqh.
[] Ghi chú riêng phần Trading: magic number, khoá của TradeEvent, mảng m_activated_control của CPendRequest, và chọn phương án A hay B cho symbol_id.
    2026 1026 Update
 - Account: CAccount (Entities/Trading/Account.mqh) + ENUM_ACCOUNT_PROP_* (TradingDefines.mqh), bảng accounts có cột cho từng property.
 - Python đọc accounts để lấy account_key của account đang login (bỏ hàm tự tính account_key), chưa có dòng thì không sync.
 - Open: giá trị đổi theo tick của accounts (balance, equity...) mới được ghi trong OnInit, chưa có chỗ refresh.
 - Table in DB: accounts 
   - Class in Library: CAccount (một dòng) / CAccountsCollection (cả bảng)
 - Table in DB: symbols
   - Class in Library: CSymbol (một dòng) / CSymbolsCollection (cả bảng)
2026 1027 Update
 - Python chia 3 vai: Current (một lượt lúc OnInit rồi nghỉ), Live, History (số worker bằng số symbol). Thứ tự ghi: EA/Library > Live > History (Python.md).
 - Table Setting_Sync: 
     + from_time -> lost_from_time, 
     + to_time -> lost_to_time (đoạn còn thiếu cho History, 0,0 là không thiếu), 
     + updated_at -> last_update (bar mới nhất đã sync), 
     + sync_by giữ nguyên.
   - Class in Library: CSyncManager (bảng cũ tự chuyển sang bảng mới khi OnInit).
 - CBar: bỏ BAR_PROP_TYPE (TypeBody() tính từ Open/Close, CBaseObj::Type() là loại đối tượng).
 - CBarTimeSeriesCollection: về lại CBaseObjExt như Lib/Lib V2. Event gửi bằng EventChartCustom và ghi vào danh sách Event của đối tượng bằng EventAdd.
 - SERIES_EVENT_PATTERN (lấy từ SERIES_EVENTS_PATTERN của Lib V2): lparam là giờ nến có thứ mới (0: nhiều nến, vẽ lại cả chart), dparam là TF, sparam là symbol.
   - CBarMarkerSync nghe Event, đồng bộ đúng một nến (SyncMarkers_BarTimeSeriesCollection(time)); không còn hỏi bảng theo timer.
   - Library báo nhận lại một cặp từ Python bằng một Event có lparam 0; cặp chưa có dòng tiến độ của Python thì Library xét lại mỗi nhịp (trước đây chờ nến kế tiếp).
 - Bỏ: Python V2 thử nghiệm (main_v2.py, libdb_v2.py, v2_test.py).
 [] Làm tiếp: CBarTimeSeriesDE ở V4 kế thừa CBaseObjExt, còn Lib/Lib V2 là CBaseObjExt (V2: CBarTimeSeriesDE phát hiện NewBar, gọi CBarSeriesDE::SendEvent gửi ra chart và EventAdd vào danh sách Event của mình, CBarTimeSeriesCollection gom bằng SetEvents) - rà lại cùng nhau.
   CBarSeriesDE và CSignalsCollection kế thừa CBaseObj ở cả Lib, Lib V2 và V4 (không đổi).
 [v] Làm tiếp: ENUM_PATTERN_DIRECTION không ai dùng, trùng ENUM_BAR_SIDE; Python còn SIDE chép tay từ ENUM_BAR_SIDE (Sync Everywhere). Xong 2026 1029.
2026 1029 Update
 [v] ENUM_SIGNAL_DIRECTION (CommonDefines.mqh): SIGNAL_DIRECTION_BUY, SIGNAL_DIRECTION_SELL, SIGNAL_DIRECTION_NONE (0, 1, 2 như cũ).
   + Thay ENUM_BAR_SIDE (BarDefines.mqh), ENUM_PATTERN_DIRECTION (bỏ) và ENUM_SIGNAL_DIR của Lib V2 (ZoneTagBox, TradeSetupBox).
   + BAR_PROP_SIDE -> BAR_PROP_SIGNAL_DIRECTION, BAR_SIDE_NO_PATTERN -> SIGNAL_DIRECTION_NO_PATTERN.
 [v]Table BarTimeSeriesCollection, SignalsCollection: cột side -> signal_direction (bảng cũ tự đổi tên cột khi OnInit, dữ liệu giữ nguyên).
 [] Python: SIDE -> SIGNAL_DIRECTION (libdb.py), vẫn chép tay cho tới khi có cách đọc Enum từ DB.
 - CPythonBridge báo "Current Python start" / "Current Python complete" (file cờ Python_CurrentStart.flag, Python_CurrentDone.flag do worker Current tạo).
 [] TẠM DỪNG: Python cha chỉ mở worker Current, worker History và Live đang comment trong run_parent (main.py). Nhớ mở lại.
 - CPythonBridge: 4 mốc của Current (Start, Chart, SymbolTF, Done); Python_OnInitDone.flag đổi thành Python_CurrentSymbolTF.flag.
 - Python Current/Live: hỏi đúng số nến cần (bars_needed = nến mới + context + right) thay vì luôn 20000 / 5000. Indicator: context = max(1000, 10 x chu kỳ dài nhất) (indicators.context), bỏ INDICATOR_WARMUP.
 [] Library (CBarControl) chưa theo quy tắc ngữ cảnh: rà khi làm phần Event của EA.
 - Bước 1 RAM/DB (Readme: RAM và DB): CBarTimeSeriesCollection::SyncDataFromDB (2 bản), SyncDataToDB, NewRow_BarTimeSeriesCollection, m_list_Pending_BarTimeSeriesCollection.
   + AddRows_BarTimeSeriesCollection: thêm tham số symbol, chỉ ghi RAM (không ghi DB nữa).
   + CSyncManager: m_marks[] (SSyncMark), Advance_SyncManager(..., defer=false), SyncDataToDB(sync_object), Ranges_SyncManager tính cả mốc chờ ghi.
   + CBarSeriesDE: JudgedTo/SetJudgedTo, BarsInTable/SetBarsInTable (bỏ m_pair_key, m_pair_done, m_pair_bars của collection).
   + EA OnDeinit gọi m_BarTimeSeriesCollection.SyncDataToDB().
 - Gộp SignalsCollection vào BarTimeSeriesCollection: đã thử rồi REVERT (dung lượng +13..22%, số đo trong Readme). Giữ 2 table.
   + Giữ lại: BAR_INFORMATION_SIGNAL (cuối ENUM_BAR_INFORMATION_GROUP, thay CANDLE_INFO_SOURCE_SIGNAL), BAR_PROP_INFOR_GROUP (RAM, BAR_PROP_INTEGER_TOTAL 15),
     CBarInformationManager::Group, NewRow_BarTimeSeriesCollection nhận group.
 [] No Duplicate CSignalsCollection / CBarTimeSeriesCollection: hàm dùng chung nhận tên table (UpdateTable_, Reset_, Alert_, Read_, ReadCandle_).
 - Rà soát CBarTimeSeriesCollection (Update & Implementation Rule), so với DoEasy 14710, Lib V1, Lib V2:
   + GIỮ vì CHƯA PORT function sang (không phải thừa): GetObject (DoEasy: CEngine đưa cho buffers), GetBar x2 + IsNewBar (DoEasy: CEngine dùng >20 chỗ),
     SetAvailable x4, SetRequiredUsedData x4 (DoEasy: CEngine bọc), IsAvailable x4 (EA V1/V2: TimeSeriesEngine_Lifecycle, TimeSeriesEngine_Indicator). SyncData x4 giữ (đồng bộ server).
   + IndexTimeSeries: GetTimeseries gọi nó như DoEasy (trước đó GetTimeseries tự viết lại vòng lặp: trùng).
   + Refresh, RefreshAll, RefreshAllSeries -> RefreshSeries (thêm nến MT5 lên RAM, bắn SERIES_EVENTS_NEW_BAR lên chart + EventAdd).
   + UpdateTable_BarTimeSeriesCollection -> Calculate_BarTimeSeriesCollection (tên tạm): (1) một cặp, khi OnChartEvent nghe SERIES_EVENTS_NEW_BAR; (2) các cặp chưa tính tới nến đóng mới nhất (timer).
   + Ghi nến xuống BarSeriesDE chuyển vào SyncDataToDB (nơi duy nhất RAM -> DB: nến, dòng, mốc).
   + OnTimerEvent (mới): Reset_ (đổi tham số), Calculate_ cho cặp còn dở, SyncDataToDB khi còn dòng chờ ghi. EA OnTimer gọi RefreshSeries + OnTimerEvent (bỏ comment cũ).
   [] Test chuỗi Event (chưa chạy thật). [] CSignalsCollection vẫn UpdateTable_ theo timer và ghi thẳng DB: làm theo cùng khuôn.
 - Việc tính và dữ liệu kết quả chuyển xuống CBarSeriesDE (như V2 m_patterns_control). Readme: RAM và DB.
   + CBarSeriesDE: m_list_rows, m_list_pending, m_BarControl, SetDatabase, SyncDataFromDB, SyncDataToDB, Calculate_BarSeriesDE, NewRow_, DeleteRows_, ReadNewestBar_, AddBars_.
   + CBarTimeSeriesDE: SyncDataFromDB (1 TF, mọi TF), SyncDataToDB: chuyển xuống series.
   + CBarTimeSeriesCollection: bỏ m_list_Table_, m_list_Pending_, m_BarControl, AddRows_, NewRow_, DeleteRows_, ReadNewestBar_, AddBars_; thêm SetIndicatorTemplateManager;
     Calculate_(series) gọi series rồi bắn Event + Alert; CreateCollection không Clear nữa (giữ series khi đổi chart: handle của CBarControl không bị release).
   + CSignalsCollection: bỏ m_BarControl, dùng series.GetBarControl(). CSyncManager::SyncDataToDB thêm lọc theo cặp.
 - Event Rule: method đổi dữ liệu tự báo Event (như Refresh -> RefreshSeries).
   + CBarSeriesDE::RefreshSeries tự tính (Calculate_BarSeriesDE) và tự ghi (SyncDataToDB); SyncDataToDB báo SERIES_EVENTS_PATTERN sau khi ghi; SyncDataFromDB báo PATTERN_ALL;
     DeleteRows_BarSeriesDE(type) (đổi tham số) báo PATTERN_ALL; RowsOfBar_BarSeriesDE cho Alert.
   + CBarTimeSeriesDE::RelayEvents (1 series, mọi series): RefreshSeries, SyncDataFromDB, SyncDataToDB dùng chung.
   + CBarTimeSeriesCollection: bỏ Calculate_BarTimeSeriesCollection (2 bản); SendEvents_ chuyển Event lên chart + Alert; OnTimerEvent chỉ còn Reset_ (xoá table mọi cặp).
   + Bước 2 cũ (ghép RAM vào ReadTypes_ / ReadCandle_) bỏ: Event đến sau khi ghi DB.
 - Bỏ cặp khỏi Setting_SymbolTF thì Library thôi tính: collection nghe SYMBOLTF_MANAGER_EVENT_ADDED / DELETE (AddSeries_, DeleteSeries_), CBarTimeSeriesDE::DeleteSeries.
   Python Live tự nhận cặp đó (đọc Setting_SymbolTF mỗi lượt). [] Live đang TẠM DỪNG: trong lúc này cặp bị bỏ không ai tính.
   [] Thêm cặp mới khi History / Live đang dừng: nếu last_update cũ hơn cửa sổ của series, Library đợi Python lấp (không tính).
 - SyncDataFromDB theo vòng đời DoEasy (SyncData -> Create -> Refresh): gọi một lần trong CBarTimeSeriesDE::CreateSeries sau Create, và khi nghe
   PYTHON_BRIDGE_EVENT_SYMBOLTF_DONE (EventDefines: ENUM_PYTHON_BRIDGE_EVENT mới; CPythonBridge::TellMilestone trả bool). Giữ dòng chờ ghi khi nạp lại.
   Bỏ nhánh "nhận lại cặp" (take_over, JudgedTo == 0) trong Calculate_BarSeriesDE: nguồn của lỗi nạp thiếu UKOIL và nạp lặp BTCUSD M15.
 - SyncDataToDB chỉ khi bàn giao cặp (Event DELETE) và OnDeinit; View đọc DB UNION RAM (PendingRows_BarSeriesDE, GetSeries theo symbol_id);
   Event trước khi ghi (Calculate_BarSeriesDE báo SERIES_EVENTS_PATTERN, SyncDataToDB không báo).
 - ReadTypes_ -> CBarSeriesDE::ReadTypes_BarSeriesDE (một cặp), ReadCandle_ -> CBarTimeSeriesDE::ReadCandle_BarTimeSeriesDE (một symbol, mọi TF), DB UNION RAM.
   Cha bỏ ReadTypes_, ReadCandle_, GetSeries(symbol_id); BAR_CANDLE_ROWS_MAX về BarTimeSeriesDE.mqh. CBarMarkerSync, Candle Info gọi tầng con.
 - Đặt tên list theo table (CommonRule): CBarSeriesDE m_list_series -> m_list_Table_BarSeriesDE, m_list_rows -> m_list_Table_BarTimeSeriesCollection,
   m_list_pending -> m_list_Pending_BarTimeSeriesCollection; bỏ GetListRows (không ai gọi).
 - Tài liệu: Python.md cập nhật theo cách làm mới (Event bàn giao, View UNION, tạm dừng History / Live, đổi tham số làm dở) và thêm mục "Quy tắc chung";
   CommonRule: Python tuân thủ cùng các rule. [] Rà tên phía Python cho khớp table / class (danh sách trong Python.md).
 - RefreshSeries khôi phục đủ 4 bản như DoEasy CTimeSeriesCollection::Refresh: (1) symbol + TF, (2) symbol, (3) mọi symbol, (4) RefreshSeriesAllExceptCurrent.
   EA như CEngine: OnTick gọi (2) cho symbol của chart, OnTimer gọi (4) (symbol khác không có tick trên chart này); tester: OnTick gọi (3), OnTimer không gọi
   (như các EA mẫu DoEasy gọi engine.OnTimer từ OnTick). Mỗi symbol chỉ refresh ở một nơi. (1) khôi phục theo cấu trúc gốc, chưa ai gọi.
 [] SeriesSync trước Refresh trong OnTick (DoEasy CEngine::OnTick) chưa port: SyncData x4 đang giữ.
 - 2026-10-30 Tách vai CBarSeriesDE / CBarControl theo V2 (Series = nến MT5, Control = tính + kết quả + ghi DB); entity kết quả giữ tên V2 nhưng kế thừa CBar:
   + CBarPattern : CBar (Entities\Bar\BarPattern.mqh): FindHammer .. FindThreeStars (30 candle pattern) + FindMomentum, bộ chọn Find(type,index) (V2 CBarPatternControl<Name>::FindPattern).
   + CBarSwing : CBar (Entities\Bar\BarSwing.mqh, V2 CBarSwingSeries; bỏ "Series": chỉ là một Bar có Swing): FindSwingHigh / FindSwingLow, bộ chọn Find(type,index), Shift() (swing_strength).
      + 2026 1030 đổi tên theo Rule đặt tên method trong Library (CommonRule.md R2/R3): bỏ hậu tố _BarPattern / _BarSwing (FindHammer_BarPattern -> FindHammer,
        FindPattern_BarPattern -> Find, SetJudge_ / IsFound_ / Param_ / Shift_ -> SetJudge / IsFound / Param / Shift). CBarControl cũng bỏ hậu tố _BarControl (Calculate, Find, FindSignal, DeleteRows, RowsOfBar, ReadTypes, PendingRows, Direction*...).
   + Mỗi object là một dòng kết quả (nến + INFOR_TYPE / INFOR_GROUP / SIGNAL_DIRECTION). CBar::SetBar (protected) chép nến. Type chỉ Python tìm thì dòng vẫn là CBar.
   + CBarControl (kế thừa CBaseObjExt như V2 CBarPatternControl): giữ m_pattern_instance / m_swing_instance làm judge, m_list_series (con trỏ nến của series, như V2),
     m_list_Table_ / m_list_Pending_BarTimeSeriesCollection, m_judged_to, SyncDataFromDB, SyncDataToDB (dòng + tiến độ), Calculate_, DeleteRows_ (2 bản), PendingRows_, ReadTypes_, RowsOfBar_.
   + CBarSeriesDE: chỉ nến (m_list_Table_BarSeriesDE, bảng BarSeriesDE); SyncDataFromDB / SyncDataToDB chuyển xuống control; RelayEvents đưa Event của control lên (control xoá list sau khi đưa).
   + Nơi gọi đổi sang series.GetBarControl(): CBarTimeSeriesDE (PendingRows_), CBarTimeSeriesCollection (RowsOfBar_, DeleteRows_(type) + series.RelayEvents), CBarMarkerSync (ReadTypes_).
   + ENUM_OBJECT_DE_TYPE thêm OBJECT_DE_TYPE_SERIES_PATTERN, OBJECT_DE_TYPE_SERIES_SWING sau ACCOUNT (số lưu ở Setting_Sync không đổi). SIGNAL_DIRECTION_NO_PATTERN về BarDefines.mqh.
   + Python không đổi code: luật đã tách sẵn patterns.py / momentum.py / swing.py.
 [] Đổi tham số: cờ "đang tính lại" trong Setting_BarInformation (manager giữ), collection xoá table của mình, CSyncManager xoá mốc.
 [] Bước 2: ghép RAM vào ReadTypes_ / ReadCandle_. Bước 3: chuỗi Event nến mới (OnTimer còn comment RefreshAll, UpdateTable). Bước 4: kênh lệnh CPythonBridge.
  - Theo cách tổ chức của DoEasy / V2 (V2: m_patterns_control nằm trong CBarSeriesDE, tính trong Refresh). Khác V2: Python tính sẵn lịch sử, Library chỉ tính nến mới và ghi thêm xuống DB.
  - CBarTimeSeriesCollection (cha) chỉ quản lý, không tính: mở file account, tạo table, chuyển lời gọi xuống (RefreshSeries, SyncDataFromDB, SyncDataToDB như SyncData),chuyển Event của con lên chart (SendEvents_), Alert khi nghe SERIES_EVENTS_PATTERN của nến đóng mới nhất (dữ liệu lấy từ con: CBarControl::RowsOfBar).
  - Đổi tham số (SETUP_CHANGED): CBarControl của mỗi CBarSeriesDE bỏ dòng của type trên RAM (DeleteRows(type), tự báo PATTERN_ALL, series chuyển lên); dòng trong table của MỌI cặp (cả cặp ngoài Setting_SymbolTF, không có CBarSeriesDE) do cha xoá dần theo timer (Reset_, CSyncManager::ResetStep_SyncManager).
    + Setting_SymbolTF đổi (anh em cùng cha: nghe SYMBOLTF_MANAGER_EVENT_ADDED / DELETE của CSymbolTFManager): thêm cặp -> AddSeries_ (Library tính); bỏ cặp -> DeleteSeries_ (ghi nốt phần chờ, xoá series, Library thôi tính). Không cần lệnh riêng cho Python: Live đọc Setting_SymbolTF mỗi lượt (rnd.library) và tính tiếp cặp đó từ last_update. CreateCollection (OnInit) cũng bỏ series của cặp không còn trong Setting_SymbolTF.
    + CBarTimeSeriesDE: chuyển lời gọi xuống các CBarSeriesDE, chuyển Event của con lên (RelayEvents), DeleteSeries.
      m_list_timeseries: CBarTimeSeriesDE > CBarSeriesDE > CBar. CreateCollection giữ series đã có (đổi chart không tạo lại), chỉ thêm cặp mới.
    - CBarSeriesDE (con): giữ nến MT5, ghi nến của mình; kết quả là của m_BarControl (2026-10-30).
      + m_list_Table_BarSeriesDE: nến MT5, SetRequiredUsedData (m_required, mặc định 1000) giới hạn. DB: BarSeriesDE (chỉ phần nến mới).
      + CBarControl::m_list_Table_BarTimeSeriesCollection: mỗi dòng của table BarTimeSeriesCollection của cặp là một CBarPattern / CBarSwing (CBar nếu type chỉ Python tìm): nến MT5 cùng giờ + BAR_PROP_INFOR_TYPE, BAR_PROP_SIGNAL_DIRECTION. Cùng cửa sổ với m_list_Table_BarSeriesDE: RefreshSeries cắt dòng cũ hơn nến đầu (DeleteRows).
      + CBarControl::m_list_Pending_BarTimeSeriesCollection: CHỈ RAM, dòng đã tính chưa ghi (FreeMode false, m_list_Table_BarTimeSeriesCollection giữ object).
      + m_BarControl: một CBarControl cho mỗi cặp, dùng chung cho type và tín hiệu template (một bộ handle). CBarTimeSeriesCollection, CSignalsCollection không còn CBarControl riêng.
      + RefreshSeries (Event Rule: method đổi dữ liệu tự báo Event): thêm nến (SERIES_EVENTS_NEW_BAR), CBarControl::Calculate khi có nến mới hoặc chưa tính tới nến đóng mới nhất (RelayEvents đưa Event lên),
        rồi SyncDataToDB. Như V2 Refresh gọi UpdateAll của m_patterns_control.
      + Indicator (2026-10-30, khôi phục V1 Collections\IndicatorsCollection + Timeseries\Indicators\IndicatorDE, bước 1):
        CIndicatorsCollection (CBaseObj, COLLECTION_INDICATORS_ID 0x7782 như V1): một CIndicatorDE cho mỗi template của Setting_IndicatorTemplate trên mỗi cặp
        của Setting_SymbolTF. Nghe SYMBOLTF_MANAGER_EVENT_ADDED / _DELETE, INDICATOR_TEMPLATE_MANAGER_EVENT_ADDED / _DELETE, không phát event (chỉ Signal phát).
        CIndicatorDE (CBaseObj) giữ handle DUY NHẤT (Volumes: thêm handle MA trên volumes), chỉ nó IndicatorRelease.
        38 class chuẩn port từ V1 (Entities\Indicators\Standard\Ind<Name>.mqh: CIndAC .. CIndWPR, CIndCHO cho Chaikin, cùng OBJECT_DE_TYPE_IND_*),
        CIndicatorsCollection::CreateIndicator tạo đúng class theo type (V1 Create<Name>). Group, name lấy từ catalog IndicatorDELib.mqh (không khai hai lần),
        bỏ PrintParameters (V4 không có CMessage), không Buffer* (MT5 vẽ), không IndCustom (chỉ indicator chuẩn).
        CBarControl::Handle hỏi CIndicatorsCollection::GetIndicator, bỏ m_handle_key / m_handle / IndicatorCreate / IndicatorRelease của nó.
        Chuỗi SetDatabase: CIndicatorTemplateManager *templates -> CIndicatorsCollection *indicators (CBarTimeSeriesCollection::SetIndicatorsCollection).
        Mọi indicator chuẩn xác định bằng type + params (+ symbol, TF), không tin số handle MT5 trả về (MT5 dùng lại slot). Chart là việc của CChartObj (giữ nguyên);
        CWndInd bỏ IndicatorRelease sau ChartIndicatorGet (quy tắc V7: một chủ một lần release, chỉ ~CIndicatorDE).
        CIndicatorsCollection như CBarTimeSeriesCollection nhưng chỉ RAM, không ghi DB (dùng ngay, dùng nhanh): CIndicatorDE -> CSeriesDataInd -> CDataInd.
        Còn lại: CSeriesDataInd / CDataInd (RAM); CSignalBase + CSignal*, CSignalsCollection (table SignalsCollection); bỏ phần indicator khỏi CBarControl.
      + Mỗi class tự tính (2026-10-30, Parent Child Structure): CBar có Calculate(type, list, since) (vòng quét nến sau since, một chỗ) và các virtual
        Find(type,index), Shift(), Event(), NewRow(...). CBarPattern, CBarSwing, CBarBOS, CBarCHoCH override phần của mình (Find; CBarSwing: Shift, Event SWING;
        CBarBOS / CBarCHoCH: Event BOS / CHOCH; mỗi class NewRow ra dòng của chính nó). CBarControl chỉ còn: Judge(type) chọn class, đưa tham số (SetJudge),
        gọi judge.Calculate, giữ dòng + ghi DB (BarTimeSeriesCollection), báo event theo judge.Event(). Thêm loại mới: một class : CBar + một dòng trong Judge().
      + BOS / CHoCH (2026-10-30, luật V2 CMarketStructureControl): CBarBOS : CBar, CBarCHoCH : CBar (Entities\Bar\), mỗi class một type.
        Cả hai dùng CBarSwing::FindBrokenHigh / FindBrokenLow: nến đóng cửa vượt swing mới nhất chưa bị phá; nhãn so với swing cùng loại trước đó
        (High: HH -> BOS Buy, LH -> CHoCH Buy; Low: LL -> BOS Sell, HL -> CHoCH Sell). Swing trước phải xác nhận trong STRUCTURE_LOOKBACK (300) nến.
        Không có tham số riêng: CBarControl::Find đưa tham số của Swing High / Swing Low vào m_swing_instance, m_swing_low_instance rồi SetJudge cho m_bos_instance, m_choch_instance.
        Dòng nằm trên nến break. Event riêng (Event Rule): SERIES_EVENTS_BOS, SERIES_EVENTS_CHOCH (lparam = giờ nến break), như SERIES_EVENTS_SWING.
        CBarControl::EventOf(type) cho biết event của mỗi type: Calculate báo theo nó, RowsOfBar(bar, event_id) lọc theo nó (Alert của BOS chỉ gồm BOS);
        Alert BOS / CHoCH chỉ cho nến đóng mới nhất như PATTERN. CBarMarkerSync nghe cả 4 event. Python structure.py tính cùng luật (đã so khớp 12 bộ dữ liệu ngẫu nhiên).
      + SERIES_EVENTS_MISSING_BARS (khôi phục từ DoEasy / V2, 2026-10-30): RefreshSeries thêm hơn 1 nến trong một nhịp thì báo, lparam = số nến đã thêm. Đếm trên nến MT5 có thật, không chia thời gian
        như IsNewBar() của DoEasy, nên cuối tuần / nghỉ phiên / phút không tick không báo; chỉ báo khi EA lỡ nến (mất kết nối, máy ngủ, EA không chạy) và vừa lấp lại.
      + SERIES_EVENTS_SWING (mới, V2 không có, 2026-10-30): Calculate báo swing riêng (lparam = giờ nến pivot, 0 khi nhiều hơn SERIES_EVENTS_PATTERN_MAX), mẫu nến vẫn báo SERIES_EVENTS_PATTERN.
        CBarMarkerSync nghe cả hai. SyncDataFromDB / DeleteRows vẫn báo PATTERN_ALL (vẽ lại cả chart, gồm swing).
        Alert: SendEvents_ báo Alert cho SWING (không phải ALL) trên nến pivot, chỉ các type swing (RowsOfBar(bar, swings, ...) lọc swing / phần còn lại); PATTERN vẫn chỉ nến đóng mới nhất, không gồm swing.
      + Vòng đời như DoEasy / Lib V1 với MT5: SyncData (đợi server) -> Create (lấy nến một lần) -> Refresh (từng nến mới). Với DB: SyncDataFromDB lấy dòng một lần
        ngay sau Create (CBarTimeSeriesDE::CreateSeries), rồi lấy lại khi Python báo đã ghi (PYTHON_BRIDGE_EVENT_SYMBOLTF_DONE, CPythonBridge bắn khi thấy file cờ);
        dòng đang chờ ghi được giữ. Không còn "đoán nhận lại cặp" trong Calculate.
      + Calculate: chỉ tính các nến sau last_update của từng type.
      + SyncDataToDB chỉ khi bàn giao: (1) cặp bị bỏ khỏi Setting_SymbolTF (DeleteSeries: "từ nay tao không tính, Live tính tiếp"), (2) OnDeinit.
        Trong phiên, dòng mới nằm trên RAM (m_list_Pending_BarTimeSeriesCollection), View đọc DB UNION RAM. EA chết đột ngột (không OnDeinit) thì phần của phiên mất, Current tính lại.
      + Event trước khi ghi: Calculate báo SERIES_EVENTS_PATTERN khi RAM có dòng mới; SyncDataToDB không báo (View thấy như cũ).
      + SyncDataToDB luôn theo thứ tự: nến mới -> dòng -> tiến độ của đúng cặp (CSyncManager::SyncDataToDB(object, symbol_id, tf)), RỒI tự báo SERIES_EVENTS_PATTERN
        cho từng nến vừa ghi. Vì báo sau khi ghi nên View đọc DB là thấy dòng mới: KHÔNG cần ghép RAM vào ReadTypes_ / ReadCandle_ (bước 2 cũ bỏ).
      + m_judged_to, m_bars_in_table: CHỈ RAM.
    - CSyncManager: Setting_Sync ở DB. m_marks[]: CHỈ RAM, các mốc chờ ghi (Advance_SyncManager với defer). Ranges_SyncManager coi mốc chờ ghi như đã ghi.
    - View (CBarMarkerSync, Candle Info): load on demand, nghe SERIES_EVENTS_PATTERN, đọc DB UNION RAM ở tầng con (cha không đọc):
      + Marker: CBarControl::ReadTypes (series.GetBarControl()) của cặp trên chart (cặp trên chart luôn là cặp của Setting_SymbolTF).
      + Candle Info: CBarTimeSeriesDE::ReadCandle_BarTimeSeriesDE của symbol: đọc DB mọi TF ngắn hơn hoặc bằng (cả TF không có series: phần của Python),
        UNION RAM của các series nó có. CBarTimeSeriesDE giữ m_db, m_symbol_id (SetDatabase lúc tạo).
    - [] CSignalsCollection dùng CBarControl của series nhưng vẫn còn m_pair_key / m_pair_done, UpdateTable_ theo timer và ghi thẳng DB: chuyển việc tính xuống CBarControl như các type.
    - Đổi tham số một Job = đi lại con đường OnInit: xoá ở DB và RAM, Current Python tính lại, History lấp phần trước, rồi SyncDataFromDB. [] Cần kênh lệnh CPythonBridge để mở lại Current.
      + Show/hide không đụng tới dữ liệu (RAM, DB). Chỉ thay đổi tham số mới phải tính lại.
      + Chia việc: mỗi tay làm phần của table mình, nghe Event của nhau.
        * CBarInformationManager (CIndicatorTemplateManager cho template): biết thay đổi, giữ cờ "đang tính lại" trong Setting_BarInformation (m_reset_types chuyển về đây, là bản RAM của cờ), bắn SETUP_CHANGED, tắt cờ khi collection báo xong.
        * CBarTimeSeriesCollection: xoá dòng của Job trong table của nó (RAM ngay, DB từng bước), xong thì bắn Event báo xong. OnInit hỏi manager các cờ còn bật để xoá tiếp phần dở.
        * CSyncManager: xoá mốc trong Setting_Sync (ResetStep_SyncManager).
      + [] Cờ trong Setting_BarInformation cũng có thể là lệnh cho Python tính lại đúng Job đó (Python đọc Setting_BarInformation mỗi lượt): bàn khi làm bước 4.
    - KHÔNG gộp table SignalsCollection vào BarTimeSeriesCollection (2026 1029, đã thử rồi revert). Khi cần xem chung thì JOIN / UNION lúc đọc.
      + Lý do: dung lượng. Đo trên 1 triệu dòng thật: 2 table như hiện nay 15.6 MB; gộp + group_infor + template_id 19.1 MB (+22%);
        gộp + template_id 17.6 MB (+13%); gộp, id template ghi vào type_infor + group_infor 17.1 MB (+10%, nhưng một cột 2 nghĩa, Reset theo type xoá nhầm template cùng số).
        Hiện ~13.7 triệu dòng chỉ là chunk đầu, đủ lịch sử sẽ gấp nhiều lần.
      + Mỗi cột thêm vào table kết quả đều phải đo trước: table có hàng chục triệu dòng.
      + No Duplicate của 2 collection (CSignalsCollection gần như bản sao CBarTimeSeriesCollection) xử lý ở code: hàm dùng chung nhận tên table, không gộp table.
      + Giữ lại (không phụ thuộc việc gộp): BAR_INFORMATION_SIGNAL đứng cuối ENUM_BAR_INFORMATION_GROUP (thay CANDLE_INFO_SOURCE_SIGNAL), BAR_INFORMATION_GROUP_TOTAL vẫn 3.
        BAR_PROP_INFOR_GROUP của CBar: CHỈ RAM, suy ra từ type qua CBarInformationManager::Group (nguồn: Setting_BarInformation.group_infor), không phải cột của table.
    - RAM chỉ giữ tối thiểu để tính, View load on demand.
      + [] SyncDataFromDB đang nạp quá nhiều (mọi dòng trong khoảng nến series giữ): chỉ cần nạp các type mà Job phụ thuộc, trong khoảng context của chúng.
      + [] Job khai báo phụ thuộc (đọc kết quả của type nào, ví dụ BOS đọc Swing): EA + Library khai, đưa sang Python qua DB (cột trong Setting_BarInformation). Chưa làm được thì ghi Update note là đang chép tay. Hiện chưa Job nào phụ thuộc.
      + [] Dọn RAM (việc riêng của EA + Library, tiến độ đã ở Setting_Sync): bỏ CBar đã ghi và cũ hơn context lớn nhất của các Job (m_list_Table_ hiện chỉ tăng).
    - Bỏ 7 type khỏi Setting_BarInformation (2026 1031): Support/Resistance, Supply/Demand, FVG, Trendline, Impulse Leg, Pullback Leg, Range Leg (306-312, ở cuối dãy SMC nên không mã nào dịch).
      + Lý do: không phải phép tính riêng. View dựng chúng trên RAM từ các dòng đã có. FVG, Supply/Demand: dòng Momentum Candle (một dòng cho cả ba, chung group time như CZoneTagBox của V3).
        Support/Resistance, Trendline, Leg: dòng Swing / BOS / CHoCH. Lưu thêm là chép lại (No Duplicate), sống/chết đổi theo từng nến là ghi đè (tính lại).
      + Bỏ luôn param + hằng mặc định của chúng (BAR_PARAM_SHOW_DEAD ... SWINGS_TRIED, ZONE_DEF_*, FVG_DEF_*, SR_DEF_*, TREND_DEF_*): đều là param của View. Khi port View thì chép từ V3 từng cái.
      + Sync Everywhere: CBarInformationManager::MakeInformation / MakeSetup xoá dòng trong DB mà catalog không còn. Python không đổi (đọc type theo tên, chỉ tính tên nó biết).
    - Tầng dữ liệu của Indicator, chỉ RAM (2026 1031), đặt tên theo pattern của CBar:
      + CIndicatorData (V1 CDataInd): 1 giá trị của 1 buffer tại 1 nến. CIndicatorSeriesDE (V1 CSeriesDataInd): list của 1 template trên 1 cặp, CIndicatorDE giữ (m_series_data, như V1).
      + Không lưu DB (MT5 cho lại bất cứ lúc nào). CIndicatorsCollection nghe SERIES_EVENTS_NEW_BAR của cặp -> Refresh(): ghi lại nến vừa đóng (giá trị cuối) + nến đang chạy.
      + CBarControl::Buffers chuyển thành CIndicatorDE::BuffersTotal (No Duplicate). CBarControl::LoadBuffers vẫn CopyBuffer thẳng: chuyển sang đọc CIndicatorSeriesDE khi tách CSignal* khỏi CBarControl.
      + Tên đổi: CSignalBase -> CSignal, thêm CSignalSeriesDE (dòng signal của 1 template trên 1 cặp) khi làm lại CSignalsCollection.
    - Signal tách khỏi CBarControl (2026 1031), tên theo pattern của CBar:
      + CSignal (V2 CSignalBase): 1 dòng (flip của 1 template tại 1 nến) và là base của judge. Judge = class con giữ tên V2: CSignalSAR, CSignalMA, CSignalOscillator, CSignalZeroCross,
        CSignalTwoLineCross (SignalCrossover.mqh; MACD 0/1, ADX 1/2 nên không port CSignalMACD*/CSignalADX), CSignalBollinger + CSignalEnvelopes (SignalBands.mqh), CSignalFractals, CSignalVolumes (mới).
        Luật chuyển nguyên từ CBarControl::Direction* (khớp signals.py). ATR: CSignal, không có hướng.
      + CSignalSeriesDE (mới): dòng của 1 template trên 1 cặp (RAM), judge giữ (m_series).
      + CSignal::Calculate đọc buffer từ CIndicatorSeriesDE theo bar time (Refresh() trước: lấp từ nến mới nhất trong RAM tới nến đang chạy), không CopyBuffer thẳng.
        Bắn SERIES_EVENTS_SIGNAL (mới, ID của CSignal) cho từng flip; CSignalsCollection relay SAU khi ghi DB thành công. BarMarkerSync nghe thêm SERIES_EVENTS_SIGNAL.
      + CSignalsCollection giữ judge (m_list_signals, V2 GetOrCreateSignal), lấy CIndicatorDE từ CIndicatorsCollection theo type + params mỗi lần tính (không giữ con trỏ: indicator có thể bị xoá).
        Xoá judge khi xoá template / cặp.
      + Bỏ khỏi CBarControl: Handle, LoadBuffers, Directions, Direction*, Previous, FindSignal, m_buffer, m_direction, m_IndicatorsCollection; bỏ tham số indicators của SetDatabase (CBarSeriesDE, CBarControl),
        CBarTimeSeriesCollection::SetIndicatorsCollection. EA: m_SignalsCollection.SetIndicatorsCollection.
      + [] Còn lại: CSignalsCollection vẫn chạy theo timer và ghi thẳng DB (chưa Live on RAM + SyncDataToDB như CBarControl), m_pair_key / m_pair_done.
    - CIndicatorDE, CIndicatorData về lại khuôn DoEasy / V1 (2026 1031): 3 mảng property (m_long_prop / m_double_prop / m_string_prop), SetProperty / GetProperty, Compare(mode),
      IsEqual / IsEqualMqlParamArrays, accessor tên V1. Thêm property = khai trong IndicatorDefines.mqh (enum chép từ V1 TimeseriesDefines.mqh).
      + Bỏ INDICATOR_PROP_HANDLE và IND_DATA_PROP_IND_HANDLE: handle là của riêng CIndicatorDE (m_handle, chỉ CopyBuffer + IndicatorRelease). Handle trên chart (MT5) và handle của Library
        không bao giờ đồng bộ được (đổi MA14 -> MA24: Library xoá rồi tạo lại, handle mới), nên indicator chỉ nhận diện bằng type + params (IsOf / IsEqual, như IsEqual của V1 bỏ qua HANDLE).
      + Không còn params_text trong CIndicatorDE: CIndicatorsCollection::GetIndicator / DeleteTemplate đổi text của template ra MqlParam (ParamsFromText) rồi IsOf.
      + Constructor về như V1: CInd<Name>(symbol, timeframe, mql_param), group + name lấy từ catalog (IndicatorDELib), shortname như V1 "MA(symbol,TF)"; ID gán sau (SetID).
      + Volumes: handle đường trung bình là member của CIndVolumes (V1 không có). Số buffer: GetIndicatorBuffersForType (IndicatorDELib). TimeframeDescription chép từ V1 CommonDELib.
      + Chưa port: Print / GetPropertyDescription (V4 chưa có các message của chúng).
    - Port Print / PrintShort / GetPropertyDescription (+ Get*Description) của CIndicatorDE, CIndicatorData từ V1 (2026 1031); 20 message chép từ V1 MessageData (sửa chữ "Solid lineOscillator").
      + Không duplicate trong DELib: bỏ TimeframeDescription vừa chép (tên TF đọc table timeframes: CIndicatorTemplateManager::TimeframeName, chủ của table). CIndicatorsCollection gán
        SetTimeframeDescription + SetShortName ("MA(EURUSD,H1)", name của catalog) khi tạo; CInd<Name> truyền shortname rỗng.
      + Số buffer là cột buffers của catalog (SIndicatorCatalogItem), GetIndicatorBuffersForType đọc catalog như GetIndicatorGroupForType (bỏ switch riêng).
      + PrintShort của V1 nằm ở từng CInd<Name>: gom một lần ở CIndicatorDE (không handle). Chưa port PrintParameters / GetMqlParamDescription (message của từng tham số).
      + [] Còn: AlertNewOnPair (CommonDELib) tự tính tên TF bằng StringSubstr(EnumToString), trùng table timeframes.
    - Fix: CBarInformationManager::MakeInformation xoá Setting_BarSetup của type ngoài catalog TRƯỚC Setting_BarInformation (FOREIGN KEY, error 5619 ở log 2026 1031).
    - CSignalsCollection Live on RAM, Save on DB (2026 1031), như CBarControl:
      + CSignalSeriesDE: m_list_Pending_SignalsCollection (FreeMode false), AddRow cho dòng mới vào cả hai list. CSignal: SyncDataToDB(db, symbol_id), PendingRows(from, to);
        Calculate bỏ dòng cũ hơn nến đầu của series (dòng chờ ghi giữ lại).
      + Hàm tính (nay là RefreshSeries) không ghi DB nữa: Advance_SyncManager(..., defer=true), bắn SERIES_EVENTS_SIGNAL + Alert ngay khi RAM đổi.
      + CSignalsCollection::SyncDataToDB() / SyncDataToDB(symbol, tf): dòng của mọi judge của cặp rồi mốc của cặp. Gọi khi bàn giao cặp (SYMBOLTF_MANAGER_EVENT_DELETE) và EA OnDeinit.
      + Read_SignalsCollection, ReadCandle_SignalsCollection: table UNION RAM (ReadCandle giữ thứ tự TF dài trước, rồi thời gian).
      + [] Còn: chưa có SyncDataFromDB (RAM chỉ giữ dòng Library tìm từ lúc chạy).
    - AlertNewOnPair(symbol, timeframe_name, ...): tên TF do người gọi đọc table timeframes (CSymbolTFManager::TimeframeName).
      + Bỏ CIndicatorTemplateManager::TimeframeName (trùng CSymbolTFManager::TimeframeName có sẵn); CIndicatorsCollection dùng của CSymbolTFManager.
    - PrintParameters / GetMqlParamDescription (2026 1031): một lần ở CIndicatorDE theo schema của type (tên tham số như form Add), không chép 38 bản của V1. Message MSG_LIB_TEXT_IND_TEXT_IND_PARAMETERS.
      + MqlParameterDescription(param, choices, decimals) vào IndicatorDELib: CIndicatorTemplateManager::ParamTexts dùng chung (không duplicate).
      + Bỏ CIndicatorDE::IsEqualMqlParams / IsEqualMqlParamArrays (trùng hàm của IndicatorDELib, đổi sang const ref).
    - CSignalsCollection: UpdateTable_SignalsCollection -> RefreshSeries(void) / RefreshSeries(symbol) / RefreshSeriesAllExceptCurrent() + OnTimerEvent() (2026 1031), cùng tên và nhịp với CBarTimeSeriesCollection:
      + OnTick: RefreshSeries(::Symbol()) ngay sau Bar (tester: RefreshSeries()). OnTimer: RefreshSeriesAllExceptCurrent() + OnTimerEvent() (Reset_SignalsCollection: xoá dòng của template đã xoá).
      + Cặp lấy từ series của CBarTimeSeriesCollection trên RAM (GetList về public như DoEasy), không query Setting_SymbolTF mỗi tick. TemplateIds chỉ hỏi DB khi có cặp có nến mới cần tính (1 lần / lần gọi).
      + m_pair_key bỏ số template; INDICATOR_TEMPLATE_MANAGER_EVENT_ADDED đặt m_pair_done = 0 cho mọi cặp (tính lại từ mốc tiến độ).
    - 8 file judge CSignal<Rule> (SignalSAR, MA, Oscillator, ZeroCross, Crossover, Bands, Fractals, Volumes) chuyển vào Entities\Signals\Standard (như Entities\Indicators\Standard): include "..\Signal.mqh", CSignalsCollection include Standard\.
    - Không hỏi DB trên tick (2026 1031): Library nạp một lần (SyncDataFromDB) rồi làm việc trên RAM, ghi bằng SyncDataToDB.
      + CSyncManager: m_rows[] = bản RAM của Setting_Sync của account. SyncDataFromDB() ở OnInitEvent, OnChartEvent(PYTHON_BRIDGE_EVENT_SYMBOLTF_DONE), sau Import_. Ranges_SyncManager chỉ đọc RAM
        (+ mốc chờ ghi m_marks). Advance (ghi thật), ResetObject, DropMark cập nhật RAM theo. EA gọi m_SyncManager.OnChartEvent đầu tiên. Bar (CBarControl::Calculate) hết query theo.
      + CSignalsCollection::SyncDataFromDB() / (symbol, tf): TemplateIds hỏi DB ở đây (OnInit, Python DONE, thêm template, thêm cặp), tạo judge cho mọi template x cặp,
        CSignal::SyncDataFromDB đọc dòng SignalsCollection trong khoảng nến của series lên RAM (dòng chờ ghi giữ lại; CSignalSeriesDE::AddRow(row, pending)). Bắn SERIES_EVENTS_SIGNAL ALL của cặp.
      + RefreshSeries chỉ duyệt judge trên RAM (không TemplateIds), symbol_id lấy từ CBarSeriesDE::SymbolID. Bỏ event 'takeover' trong Refresh (SyncDataFromDB đã bắn).
    - Mọi tay của Library init sau Python Current (2026 1031): log 11:54 thấy EA và Current cùng tính BTCUSD M1 nến 04:53 (8 mốc signal chờ ghi của EA trước DONE).
      + CSyncManager: m_python_done / IsPythonDone(). Mở ở PYTHON_BRIDGE_EVENT_SYMBOLTF_DONE (sau SyncDataFromDB), đóng ở PYTHON_BRIDGE_EVENT_CURRENT_START (mới). OnInitEvent không nạp Setting_Sync nữa.
      + CBarControl::SyncDataFromDB / Calculate, CSignalsCollection::SyncDataFromDB / RefreshTimeseries_ đứng chờ cổng. CSignalsCollection::OnInitEvent không SyncDataFromDB nữa.
      + CPythonBridge: Python_CurrentSymbolTF.flag không xoá sau khi báo (m_symboltf_told báo 1 lần / EA) để EA nạp lại khi Python còn chạy vẫn mở cổng; thấy Python_CurrentStart.flag thì bắn CURRENT_START.
      + Python: run_current xoá Python_CurrentSymbolTF.flag của lượt trước trước khi đặt Start (libdb.milestone_clear). Python.md ghi theo.
    - Signal theo khuôn CBar (2026 1031): series tự tính, event đi từ dưới lên, chỉ ghi DB dòng đã bắn event. MT5 tính indicator, Library chỉ đọc buffer vào RAM (CIndicatorSeriesDE).
      + CSignal: chỉ còn 1 dòng (m_time, m_signal_direction) + luật của judge: Calculate(indicator, list, since, row_time[], row_side[]) như CBar::Calculate; bỏ template, m_series, events, SyncData*, PendingRows.
      + CSignalSeriesDE (1 template / 1 cặp) như CBarControl: giữ judge của type (CreateSignal, chuyển từ collection), m_list_Table_SignalsCollection, m_list_Pending_SignalsCollection, m_judged_to;
        SetSeries, SetDatabase, Calculate(indicator, list), SyncDataFromDB(list), SyncDataToDB (dòng; mốc của cặp do collection ghi sau), DeleteRows(list), PendingRows, RowsOfBar; tự bắn SERIES_EVENTS_SIGNAL.
        Calculate không đánh dấu đã tính khi indicator chưa có (NULL) - trước đây mốc vẫn đi tiếp.
      + CSignalsCollection: m_list_series (CSignalSeriesDE), GetSeries / CreateSeries / DeleteSeries x2 (thay GetOrCreateSignal / DeleteSignals), SendEvents_ relay event của series + Alert từ RowsOfBar.
        Bỏ m_pair_key / m_pair_done (thay bằng JudgedTo của series). Thêm MY DEBUG CSignalsCollection::RefreshSeries (1 dòng / cặp / nến, như CBarControl::Calculate).
    - Bật lại Python Live (2026 1031), History vẫn tạm dừng: run_parent mở ("current", "live").
      + run_live chờ Current xong (CURRENT_ID trong history_done_ids) mới tính: trước đó parent mở Live cùng lúc với Current, hai worker cùng tính khoảng trống của các cặp ngoài Setting_SymbolTF.
      + run_live bỏ qua cặp của Setting_SymbolTF ngay đầu vòng (trước đây vẫn hỏi terminal last_closed và state của mọi job rồi calculate_new mới trả 0).
    - CSignalSeriesDE::Progress (private, Ranges_SyncManager trong RAM) dùng chung cho Calculate và SyncDataFromDB; SyncDataFromDB đặt m_judged_to = mốc tiến độ (trước: 0), nên MY DEBUG của Signal báo 'judged before' như CBarControl.
    - CSignalsCollection::RefreshTimeseries_SignalsCollection: khi hết BAR_UPDATE_BUDGET_MS thì break (trước: return false ngay), nên Alert của các template đã judge trong lượt đó vẫn phát và MY DEBUG in 'not finished: the budget...'. MY DEBUG in cả khi mọi template 'judged before' (như CBarControl).
    - Thị trường đóng cửa (2026 1031): port CNewTickObj từ V2 (Entities\Ticks\NewTickObj.mqh, + OBJECT_DE_TYPE_NEW_TICK sau OBJECT_DE_TYPE_SIGNAL_VOLUMES). CBarTimeSeriesDE có m_new_tick + IsNewTick() như DoEasy CTimeSeriesDE.
      + CBarTimeSeriesCollection::RefreshSeriesAllExceptCurrent bỏ qua symbol không có tick mới (DoEasy RefreshAllExceptCurrent). CSignalsCollection không gọi IsNewTick lần nữa (lần gọi thứ hai luôn false), giữ check JudgedTo.
      + Event Rule cho CNewTickObj: base CBaseObjExt (dùng m_tick của base). IsNewTick báo TICK_EVENT_PAUSE (không có tick TICK_PAUSE_SECONDS = 60 s theo TimeTradeServer, báo 1 lần) và TICK_EVENT_RESUME (tick đầu tiên sau khi nghỉ); lparam time_msc, dparam Bid, sparam symbol. Không Alert, chỉ MY DEBUG.
        CBarTimeSeriesDE::IsNewTick chuyển Event lên (RelayEvents nhận CBaseObjExt: series hoặc m_new_tick). CBarTimeSeriesCollection::RefreshSeriesAllExceptCurrent gửi Event lên chart rồi mới bỏ qua symbol không có tick.
        CSignalsCollection nghe PAUSE / RESUME (m_paused_symbols), RefreshSeriesAllExceptCurrent bỏ qua symbol đang nghỉ.
      + Python đồng bộ (Sync Everywhere): class NewTick trong main.py (luật CNewTickObj, TICK_PAUSE_SECONDS = 60), data.fetch_last_tick. run_live bỏ qua symbol không có tick mới; không tick thì không hỏi DB (Round, build_jobs); db.pairs() theo nhịp WORKER_CHECK_SECONDS. Ghi trong Python.md.
    - Tick (2026 1031, RAM only theo Readme 'Live on RAM, Save on DB for no more calculation', không table): port từ DoEasy / V2, đổi tên theo khuôn V4.
      + CDataTick -> CTick (Entities\Ticks\Tick.mqh), CTickSeries -> CTickSeriesDE (Entities\Ticks\TickSeriesDE.mqh), CTickSeriesCollection giữ tên (Collections\TickSeriesCollection.mqh, COLLECTION_TICKSERIES_ID 0x7784 như DoEasy). TickDefines.mqh: TICK_PROP_*, TICKSERIES_DEFAULT_DAYS_COUNT 1, TICKSERIES_MAX_DATA_TOTAL 200000, TICK_PAUSE_SECONDS.
      + Refresh / RefreshExpectCurrent -> RefreshSeries / RefreshSeriesAllExceptCurrent (như Bar, Signal). Tick của ngày được copy ở lần RefreshSeries đầu tiên (không ở OnInit: CopyTicksRange có thể chờ server). Cắt list giữ tick mới nhất (DoEasy Delete(j) xoá cách một).
      + CNewTickObj thuộc CTickSeriesDE (như DoEasy), bỏ khỏi CBarTimeSeriesDE (RelayEvents trả lại CBarSeriesDE*). CTickSeriesCollection giữ trạng thái nghỉ (IsPaused) và gửi TICK_EVENT_PAUSE / RESUME lên chart; Bar và Signal hỏi IsPaused (như CSyncManager::IsPythonDone), bỏ m_paused_symbols của Signal.
      + EA: OnTick RefreshSeries(Symbol()) trước Bar; OnTimer RefreshSeriesAllExceptCurrent trước Bar; OnChartEvent nghe SYMBOLTF ADDED / DELETE (symbol hết cặp thì tick series đi). Python không đổi (tick không vào DB), NewTick giữ cùng luật nghỉ.
      + Bỏ trùng việc lấy tick (History update: COrder::BidAskFromTicks có từ V3, khi V3 bỏ Tick): BidAskFromTicks(CTickSeriesDE *tickseries=NULL) lấy Bid / Ask của deal mới từ tick trên RAM khi tick series của symbol phủ đủ [giờ deal - 3 s .. giờ deal]; không phủ (symbol không có tick series, tick chưa refresh tới giờ deal) thì CopyTicksRange như cũ, cùng luật. CHistoryCollection có m_TickSeriesCollection (SetTickSeriesCollection, EA OnInit). Python tradesync.py còn rỗng: khi port phần lấp Bid / Ask thì theo cùng luật.
    - Một spread (2026 1031): bỏ TICK_PROP_SPREAD (DoEasy), CTick::Spread() = Ask - Bid. Spread của symbol lúc này chỉ là của tick mới nhất (CTickSeriesDE); CSymbol khi port không giữ spread riêng. BAR_PROP_SPREAD là spread của một nến, khác đại lượng.
    - Status bar: port UpdateStatusBar_SymbolSpread / UpdateStatusBar_Balance từ V3. Spread từ tick mới nhất trên RAM ((Ask - Bid) / SYMBOL_POINT), Balance từ CAccount trên RAM. Gọi như V3: sau CreateComboBox_SymbolTF, khi đổi chart (Spread), OnTickEvent (Spread), OnTradeEvent (Balance). CGUIPannel có m_AccountsCollection, m_TickSeriesCollection (EA set trước OnInit).
    - CAccountsCollection theo khuôn CBarTimeSeriesCollection (Live on RAM, Save on DB for no more calculation): m_db giữ mở, SyncDataToDB (thay UpdateRow_), SendEvents_AccountsCollection; bỏ Columns_ / Value_ / SAccountColumn. Chỉ EA + Library tạo và ghi bảng accounts; Python chỉ đọc account_key (login + server) một lần.
      + Bảng accounts chỉ giữ cái không đổi: account_key, login, server, name, company, currency, currency_digits, trade_mode, margin_mode, margin_so_mode, margin_so_call, margin_so_so, leverage, limit_orders, fifo_close, hedge_allowed, server_type, first_seen, last_seen.
      + Bỏ (DROP COLUMN trên bảng cũ): balance, credit, profit, equity, margin, margin_free, margin_level, margin_initial, margin_maintenance, assets, liabilities, commission_blocked, trade_allowed, trade_expert: chỉ trên RAM (CAccount đọc mỗi tick như cũ).
      + Sửa lại theo History update (V1 = V2 = V3): CAccountsCollection trở về khung cũ, m_list_accounts (CListObj), m_index_current, AddToList, IsPresent, Index, GetList, GetCurrentAccount, Refresh, RefreshAndEventsControl như V3 (bỏ SendEvents_AccountsCollection mới viết). SaveObjects -> SyncDataToDB (mọi account của list, chỉ account hiện tại được update + last_seen, account khác ON CONFLICT DO NOTHING), LoadObjects -> SyncDataFromDB (dòng của bảng accounts -> CAccount, phần thay đổi liên tục = 0). Gọi ở OnInitEvent (FromDB rồi ToDB: Python thấy account_key ngay) và destructor (như V3). CAccount::IsEqual port từ V3 (company + login + name).
      + Rà theo History update: bỏ CreateTable_AccountsCollection (không có ở DoEasy / V1 / V2 / V3, collection khác của V4 tạo table ngay trong OnInitEvent): CREATE TABLE + DROP COLUMN một lần (như RENAME COLUMN side của CBarTimeSeriesCollection) nằm trong OnInitEvent; bỏ vòng ADD COLUMN (DB hiện tại đã đủ cột). Không port GetList theo property (Select), GetEventID, SetSymbol / GetSymbol (chưa ai dùng). CAccount::Read_Account / Fill_Account (V4) giữ: V3 viết trùng phần đọc terminal ở constructor và Refresh.
    - Tick series TẠM KHÔNG DÙNG (2026 1031, vết xe đổ cũ): DoEasy làm tick series cho DOM, V1 / V2 không dùng; port sang V4 làm treo EA 70 s (XAUUSD 649604 tick thành object, 2.6 GB). Tick.mqh, TickSeriesDE.mqh, TickSeriesCollection.mqh ghi TEMPORARY UNUSED ở đầu, không ai include.
      + COrder::BidAskFromTicks / CHistoryCollection trở lại CopyTicksRange 3 s trước giờ deal (không m_TickSeriesCollection).
      + CNewTickObj trở lại CBarTimeSeriesDE (như DoEasy CTimeSeriesDE::m_new_tick): IsNewTick chuyển TICK_EVENT_PAUSE / RESUME lên (RelayEvents nhận CBaseObjExt), IsPaused. CBarTimeSeriesCollection::RefreshSeriesAllExceptCurrent: IsNewTick, gửi Event, chỉ refresh khi có tick mới. CSignalsCollection hỏi timeseries.IsPaused().
      + Status bar: spread = Ask - Bid của SymbolInfoTick (đến khi port CSymbol). EA bỏ m_TickSeriesCollection.
    - CAccount / CAccountsCollection theo rule V4 (2026 1031): Parent Child (CAccount tự tạo Event, collection chuyển lên chart, anh em tự nghe), Event Rule, Live on RAM.
      + CAccount: Refresh (override CBaseObjExt) -> RefreshAccount (như RefreshSeries); bỏ Read_Account / Fill_Account; dùng SetProperty. Constructor đọc 1 lần cái không đổi (login, trade_mode, margin_so_mode, margin_mode, currency_digits, server_type, fifo_close, hedge_allowed, name, server, currency, company) rồi gọi RefreshAccount; RefreshAccount đọc cái thay đổi (trade_allowed, trade_expert, leverage, limit_orders, margin_so_call, margin_so_so, tiền và margin) -> CBaseObjExt::Refresh -> CheckEvents.
      + CAccountsCollection: Refresh + RefreshAndEventsControl (trùng code) -> RefreshAccount (OnTick như các collection khác): Event lên chart (id = property, lparam: ms | reason<<16 | type<<32, dparam: thay đổi); leverage / limit_orders / margin_so_call / margin_so_so đổi thì SyncDataToDB. OnInitEvent đặt ngưỡng 0 (Inc / Dec) cho balance, credit, trade_allowed, trade_expert, leverage, limit_orders, margin_so_call, margin_so_so; không đặt cho equity / profit / margin (đổi mỗi tick, ngưỡng sau này từ Configuration cho Automatic Trade). Trước đó không ai đặt ngưỡng: Event không bao giờ bắn, mũi tên Balance luôn xám.
      + Status bar: Balance nghe CHARTEVENT_CUSTOM + ACCOUNT_PROP_BALANCE, mũi tên theo reason (INC / DEC); bỏ cập nhật trong OnTradeEvent.
    - Trading theo rule V4 (2026 1031), bước 1 + 2 (bước 3 TradeEvents đọc history từ RAM, 4 dọn COrderControl, 5 GUI: còn lại):
      + CMarketCollection: base CObject -> CBaseObjExt (bỏ m_type / Type riêng), m_list_all_orders (CListObj, V3) + GetList; Refresh -> RefreshMarket; position / pending chỉ trên RAM: bỏ Save_ / DeleteGone_ xuống table Orders, bỏ m_OrderControl, m_write_failed, m_delete_pending.
      + CTradeEventsCollection: m_MarketCollection (SetMarketCollection); GetListMarketPendings, GetPositionByID đọc list RAM của Market (không query DB).
      + CHistoryCollection: base CBaseObjExt, chủ table Orders (m_db, OnInitEvent tạo table, dời từ COrderControl; xoá một lần dòng status 0/1/2 cũ), m_list_all_orders (V3) dựng lại từ terminal, Refresh -> RefreshHistory (budget + rescan như cũ); SyncDataFromDB đọc key (status, ticket) + bid / ask: order đã có dòng không ghi lại, deal lấy lại Bid / Ask; SyncDataToDB ghi m_list_pending (dòng chưa có) trong một transaction, RefreshHistory tự gọi; OnDeinit gọi.
      + COrderControl: bỏ SOrderColumn, Columns_, SqlValue_, Save_, Exists_, DeleteGone_, Begin_ / End_, m_SyncManager, m_in_transaction (dời sang CHistoryCollection hoặc hết dùng); OnInitEvent chỉ mở file cho Select_ / SumVolume_ / Read_ (TradeEvents, GUI) đến bước 3 / 5.
      + EA: sửa dòng m_MarketCollection.SetSymbolsCollection bị dồn vào comment (lỗi lượt trước); History SetSyncManager + OnInitEvent trước m_OrderControl.OnInitEvent.
      + Parent Child / Event Rule cho Market, History: RefreshMarket có thay đổi thì EventAdd + EventChartCustom MARKET_EVENT_CHANGED (lparam: số thứ tự event, dparam: thay đổi volume); RefreshHistory ghi xong (SyncDataToDB) thì HISTORY_EVENT_NEW (lparam: số thứ tự, dparam: số order + deal mới). EventDefines: ENUM_HISTORY_EVENT, ENUM_MARKET_EVENT sau TICK.
        EA không gọi hộ nữa: bỏ m_GUIPannel.RefreshTables_TradeManage và m_TradeEventsCollection.Refresh trong OnTimer. GUIPannel nghe HISTORY_EVENT_NEW -> RefreshTables_TradeManage. CTradeEventsCollection::OnChartEvent (khuôn OnChartEvent của mọi collection) nghe cả hai, đọc event của 2 collection bằng IsEvent / GetEvent (CBaseObjExt), lparam khác lần trước mới làm -> Refresh(...) như cũ một lần cho cả nhịp; SetHistoryCollection.
        Sửa method cũ thay vì thêm: bỏ EventsTotal (dùng GetEvent), IndexSaved_ (dùng CArrayLong::Search), AddToList (gộp vào CreateNewOrder của V3, thêm tham số deal).
    - Trading theo rule V4 (2026 1031), bước 3 - 5: về khung V3 + Event Rule + Live on RAM. Compile 0 / 0.
      + CTradeEventsCollection: dựng lại từ V3: Refresh(list_history, list_market, list_changes, list_control, ...) và các helper nhận list, tìm trên RAM; m_list_trade_events + IsPresentEventInList (RAM). Bỏ SelectOrders, m_OrderControl, SetOrderControl, các helper (count, ...) query DB, IsPresentEventInTable, Keep_, Retry_.
        Table TradeEvent chỉ để lưu: event mới vào m_list_pending (sau 12 chỗ InsertSort), SyncDataToDB ghi lần lượt, bị từ chối thì chờ lần sau (thay Retry_). Cuối Refresh: các event (m_list_events) lên chart (EventChartCustom) rồi SyncDataToDB. OnChartEvent gọi Refresh V3 với GetList() của History / Market.
      + Trùng id event trên chart: trade event (ENUM_TRADE_EVENT từ 0) và account event (id = property 0..29). Theo DoEasy: phân biệt bằng source (ushort thứ 3 của lparam = m_type); GUIPannel chỉ nhận ACCOUNT_PROP_BALANCE khi source = OBJECT_DE_TYPE_ACCOUNT (trade event có lparam = ticket).
      + COrderControl: về đúng V3 (giống từng dòng): bỏ m_db, constructor mặc định, destructor, OnInitEvent, Make_, Select_, SumVolume_, Read_, include Orders\* / LibDatabase.
      + CHistoryCollection: RefreshHistory về V3 (OrderSearch tìm order "lost", deal không kiểm tra trùng như V3); bỏ budget, rescan, m_is_restored / IsRestored. Lần gọi đầu (m_first_start) dựng lại quá khứ, không bắn event, xoá m_saved_key; deal mới (không phải lần đầu) lấy BidAskFromTicks.
        Gộp SqlValue_ và Save_ vào SyncDataToDB. Giữ Columns_ (OnInitEvent và SyncDataToDB cùng dùng: gộp vào cả hai thì danh sách cột thành 2 bản, trái No Duplicate).
        IsPresentOrderInList(ticket, type) như V3, thêm điều kiện bỏ qua deal (deal giờ cùng list, type 0 / 1 và ticket có thể trùng order).
        Read_OrderControl dời sang thành Read_HistoryCollection (table Orders là của History): GUI Trade Manage đọc khi có HISTORY_EVENT_NEW.
      + CMarketCollection: trả lại khai báo DeleteOrderFromListControl của V3 (DoEasy / V3 cũng chỉ khai báo, không có thân, không ai gọi).
      + GUIPannel: m_OrderControl / SetOrderControl -> m_HistoryCollection / SetHistoryCollection; GUIPannel_Define include HistoryCollection thay OrderControl.
      + EA: bỏ m_OrderControl; g_market_started -> g_trade_started (History + Market lần đầu, sau đó chỉ sau trade); RefreshHistory() không budget; Retry_TradeEventsCollection -> SyncDataToDB; OnDeinit thêm m_TradeEventsCollection.SyncDataToDB.
      + Sửa các dòng code bị dồn vào comment (lỗi các lượt trước): EA Breadcrumb SignalsCollection.OnInitEvent, Breadcrumb SetSymbolTFManager, m_BarTimeSeriesCollection.OnChartEvent (trước đó không được gọi); GUIPannel_Define include SymbolsCollection; GUIPannel.mqh 2 comment.
      + Python: không đổi (schema Orders / TradeEvent giữ nguyên).
      + Sửa: bỏ vòng EventChartCustom m_list_events cuối CTradeEventsCollection::Refresh (tớ thêm, V3 không có): mỗi trade event đã tự lên chart bằng CTradeEvent::SendEvent (V1 / V3, 12 chỗ) -> trước đó gửi trùng 2 lần.
    - Trading về đúng V1 (2026 1031): bỏ HISTORY_EVENT_NEW / MARKET_EVENT_CHANGED (tớ thêm, không có trong lineage). Compile 0 / 0.
      + EventDefines: bỏ ENUM_HISTORY_EVENT, ENUM_MARKET_EVENT; thêm lại TRADE_EVENTS_NEXT_CODE của V1 (EventDefines.mqh:102).
      + CHistoryCollection / CMarketCollection: không tự tạo event nữa, chỉ đặt cờ IsTradeEvent như V1 / V3 (bỏ m_events_total, EventAdd, EventChartCustom).
      + CTradeEventsCollection: bỏ OnChartEvent, SetMarketCollection / SetHistoryCollection, m_*_events_done, include Market / History. Event của nó lên chart bằng CTradeEvent::SendEvent (V1).
      + EA (vai CEngine): port TradeEventsControl của V1 CTradingEngine (EA V11 TradingEngine_MultiModule.mqh:11): RefreshMarket, RefreshHistory, lần đầu (g_trade_started = m_is_first_start) thì return, rồi hỏi IsTradeEvent / GetListChanges -> m_TradeEventsCollection.Refresh(...). OnTimer gọi TradeEventsControl.
      + GUIPannel: RefreshTables_TradeManage khi có trade event (TRADE_EVENT_NO_EVENT < id < TRADE_EVENTS_NEXT_CODE, source khác OBJECT_DE_TYPE_ACCOUNT) thay cho HISTORY_EVENT_NEW.
      + Python: không dùng các mã này, không đổi.
    - Port phần Trading từ V3 (2026 1031), mang dần nguyên file, rà RAM / DB. EA compile 0 / 0; Trading\Trading.mqh compile riêng chỉ còn lỗi của LibDatabase (thiếu define của EA khi compile một .mqh).
      + Messages: thêm 550 message V3 mà các file Trading dùng (cuối ENUM_MESSAGES_LIB và messages_library, đúng thứ tự V3; 834 / 834 khớp). CMessage: PlaySound, StopPlaySound, GetError, m_global_error, Retcode public (V3); MessageDefines: SND_* (V3).
      + Defines: TradingDefines thêm phần V3 433-960 (Symbol, trading class, pending request) + 1021-1051 (risk : reward), không mang phần DOM; include MessageData (giá trị tiêu chí kích hoạt là id message). CommonDefines: TOTAL_TRADE_TRY, CLR_MW_DEFAULT, PENDING_REQUEST_ID_TYPE_ERR / REQ, ENUM_COMPARER_TYPE.
        ENUM_OBJECT_DE_TYPE: OBJECT_DE_TYPE_SYMBOL_COMMON, _TRADE, _PENDING_REQUEST* thêm ngay trước khối GSTD (số các type trước giữ nguyên).
      + DELib: CommonDELib thêm ComparisonTypeDescription, DayOfWeekDescription (+ include CommonDefines, Message; sửa dòng "} //+---" bị dồn); TradingDELib thêm các Request*Description (V3).
      + Entities\Trading: Symbol.mqh (thay stub), SymbolCommon.mqh, TradeObj.mqh, PendRequest.mqh + PendRequest\* (6 lớp) copy nguyên V3. RAM only: thuộc tính lấy từ terminal, pending request là hàng đợi trên RAM (không phải kết quả tính) -> không bảng mới.
      + Services\Pause.mqh (V3); BaseObjExt include Pause như V3.
      + Trading\Trading.mqh (CTrading) copy V3; sửa m_account.Refresh -> RefreshAccount.
      + CMarketCollection: thêm các truy vấn V3 trên list RAM (SumFloatingProfit x4, SumVolume, PositionsCount, HasPosition x2, GetSL, GetTP, GetDistinctSymbolsAndDirections).
      + CAccount: MarginForAction (V3); sửa "}#endif" bị dồn.
      + CSymbolsCollection: GetSymbolObjByName, GetIndexObjByName (V3); list tạo CSymbolCommon(name, index) thay stub CSymbol(name).
      + Không port: V3 CTradeDatabase (Read / SaveDeal kèm Bid / Ask đã là việc của CHistoryCollection: Read_HistoryCollection, SyncDataToDB), Book (DOM), MarketBookOrd.
      + Trading\TradingControl.mqh (CTradingControl): từ V3 (UTF-16 -> UTF-8), giữ phần DoEasy (hàng đợi pending request, CreatePReq*, SetNewActivationProperties) + ClosePositions, ModifyPositions, SendNewOrder (magic vẫn cố định 20260910).
        Không port phần StopLost / Trailing / lot theo risk (m_indicators_collection, m_risk_management_manager, Get*_StopLost*, *Trailing*, GetPreviewSLTargetPrice, CalcMaxLotByRisk, preview stop distance): RiskManagement làm lại ([] Prepare implementation RiskManagement trong Update.md).
        Bỏ SetSymbolsCollection của V3: trùng CTrading::OnInit (V1 / DoEasy đưa symbols qua OnInit).
      + EA (vai CEngine): m_TradingControl; OnInit gọi m_TradingControl.OnInit(account, symbols, market, history, events) (DoEasy CEngine::CollectionOnInit); OnTimer khối trade gọi m_TradingControl.OnTimer (hàng đợi pending request, DoEasy CEngine::OnTimer).
    - symbol_account (2026 1031): Rule "Python tính cái lớn, EA + Library tính cái nhỏ" -> đăng ký symbol là việc của Library. Compile 0 / 0.
      + CSymbolsCollection::OnInitEvent: RegisterSymbol cho symbol của chart rồi mọi symbol đang chọn trong Market Watch, tên không hậu tố trước (như sort của Python).
      + Python: bỏ register_market_watch, register_symbols, find_symbol, canonical (libdb.py) và vòng MARKET_WATCH_SECONDS (main.py); Python.md cập nhật.
      + Map tay một lần 84 dòng symbol_id NULL (Real20 14, Trial14 70): thêm 83 tên gốc vào symbols. Library vẫn không tự thêm vào symbols (map tay như V3).
      + Quét Market Watch là việc của Library (Python chỉ tính theo điều khiển của EA): CSymbolsCollection base CBaseObj -> CBaseObjExt (V3), port MarketWatchEventsControl, OnTimerEvent (mỗi 1 s), NewSymbols,
        CopySymbolsNames, IsPresentSymbolInMW, IsPresentSymbolInControlList, SymbolsTotalVisible (V3). Symbol mới vào Market Watch: RegisterSymbol (dòng symbol_account) + CSymbolCommon vào list + MARKET_WATCH_EVENT_SYMBOL_ADD;
        rời Market Watch: _DEL (list giữ, symbol_account là tên của account); đổi thứ tự: _SORT. Change from V3: list = symbol_account (không phải Market Watch), so tên thay vì số lượng.
        EventDefines: ENUM_MW_EVENT (V3) sau TICK. EA OnTimer gọi m_SymbolsCollection.OnTimerEvent. GUI (như V3): cây Symbol TF nghe ADD / DEL / SORT, combobox nghe ADD.
    - Đọc lại Readme / CommonRule / Update.md, sửa cho khớp rule (2026 1031). Compile 0 / 0.
      + CommonRule R2 (method không hậu tố tên class, class động tới thì đổi): CHistoryCollection Columns_HistoryCollection -> Columns, Read_HistoryCollection -> Read (GUIPannel_Window_TradeManager theo);
        CTradeEventsCollection Columns_ / SqlValue_ / SaveEvent_TradeEventsCollection -> Columns / SqlValue / SaveEvent.
      + Readme dòng 80 (cái gì chỉ ở RAM thì ghi rõ): thêm danh sách RAM only (position / pending, CSymbol / CTradeObj, pending request, giá trị tick của account, tick, list History / TradeEvent).
      + Readme dòng 39 (Market Watch thêm Symbol -> Python worker chạy lại): đã đúng sẵn, Python đọc db.symbols() mỗi 5 s (main.py:539), không cần EA báo.
    - Caption m_window_main: số Position + Profit (2026 1031). Compile 0 / 0.
      + History: V1 / V2 status bar = Deposit load, Profit (MarketCollection.SumFloatingProfit), Server time, gọi mỗi tick (V2 GUIPannel_MainWindows.mqh:62); V1 CTradingEngine::OnInitEvent đặt ngưỡng 0 cho Balance, Profit, Equity. V3 / V4 chỉ còn Spread + Balance.
      + CAccountsCollection::OnInitEvent: thêm ngưỡng 0 Profit, Equity (như V1) -> CAccount phát ACCOUNT_PROP_PROFIT / _EQUITY mỗi khi đổi (RAM only).
      + GUI: m_label_PositionBuy (số Buy, xanh), m_label_PositionSell (số Sell, đỏ), m_label_Profit (xanh / đỏ theo dấu) là con của caption, bên trái m_combobox_SymbolTF; hướng không có position thì ẩn; Collapse: chỉ số Position, Expand: thêm Profit.
        CreateLabel_Caption, UpdateCaption_Position (vẽ lại chỉ khi chữ / vị trí đổi); gọi khi ACCOUNT_PROP_PROFIT, trade event, WINDOW_EVENT_COLLAPSE / EXPAND, đổi bề rộng. Số Position đếm trên RAM: m_MarketCollection.PositionsCount (SetMarketCollection mới).
      + Balance giữ ở status bar (event ACCOUNT_PROP_BALANCE).
      + CLabel (Lib V4 Entities\Controls\Label.mqh, cậu duyệt): m_font_weight (mặc định FW_NORMAL) + FontWeight(), DrawContent FontSet(..., m_font_weight) như CTooltip. Label caption: FW_BOLD.
      + Status bar: chữ Balance màu theo hướng event (xanh tăng, đỏ giảm, đen lần đầu) như mũi tên.
      + Status bar: Balance -> Equity (cái "nhảy múa" là Equity = Balance + Profit; Balance chỉ đổi khi đóng lệnh / commission / swap / nạp rút). Sửa method cũ: UpdateStatusBar_Balance -> UpdateStatusBar_Equity,
        STATUS_BAR_BALANCE -> STATUS_BAR_EQUITY, M_STATUS_BALANCE_WIDTH -> M_STATUS_EQUITY_WIDTH; nghe ACCOUNT_PROP_EQUITY (ngưỡng 0, như V1); chữ và mũi tên xanh / đỏ theo hướng.
      + Caption: label nền trắng (M_COLOR_CAPTION_LABEL_BACK), chữ M_COLOR_PROFIT / M_COLOR_LOSS (bỏ M_COLOR_CAPTION_BUY / SELL, M_CAPTION_POSITION_WIDTH, M_CAPTION_PROFIT_WIDTH); mở: "Buy 2", "Sell 5", "Profit 12.30",
        thu gọn: chỉ số (Profit vẫn hiện, màu theo dấu); bề rộng label theo chữ (TextGetSize, font bold) + M_CAPTION_LABEL_PADDING.
      + m_combobox_SymbolTF: nền trắng như label caption (M_COLOR_CAPTION_LABEL_BACK), chữ đen, mũi tên DOWN / UP_THIN_BLACK, xám nhạt khi hover / press. Label caption rộng thêm M_CAPTION_LABEL_SLACK (8 px): số cuối của Profit không bị cắt.
      + Status bar Equity: xám / chữ đen khi Equity = Balance (không còn lời lỗ thả nổi); trước đó giữ màu của lần đổi cuối (lúc đóng lệnh) mãi. Nghe thêm ACCOUNT_PROP_BALANCE để xét lại (đóng lệnh có thể không đổi Equity).
    - No Duplicate (2026 1101): ENUM_LOG_LEVEL của DoEasy trùng nghĩa và giá trị với ENUM_LOG_LEVELS của MT5 (Trade\Trade.mqh, CTrade::LogLevel). Cậu comment bản DoEasy trong CommonDefines; CommonDefines include <Trade\Trade.mqh>;
      đổi ENUM_LOG_LEVEL -> ENUM_LOG_LEVELS, LOG_LEVEL_NO_MSG / _ERROR_MSG / _ALL_MSG -> LOG_LEVEL_NO / _ERRORS / _ALL (BaseObj 4, PendRequest 10, Symbol 1, TradeObj 16, Trading 81, TradingControl 50). Compile 0 / 0.
