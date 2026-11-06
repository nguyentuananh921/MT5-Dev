2026 1102 Update Note
  - CSections (Lib V4, mới ở V4, không có trong History update) viết lại theo Parent Child Structure: CSections : CGBaseObj > CSection (header, toggles)
    > CSectionRow (control của một hàng, control vẫn do tab CTabs sở hữu). Mới RemoveRows(value); OnChartEvent thành virtual void; Arrange chỉ Show / Hide / Move khi đổi.
    Backup bản cũ: scratchpad Sections.mqh.bak.
    + Tab Indicator: ADDED thêm đúng một hàng cuối nhóm, DELETE RemoveRows(template id = dparam): hết dựng lại cả nhóm (header nháy). Add form BringToTop sau khi thêm hàng.
    + Tab Candle: OnChartEvent không trả bool nữa, click header của type bỏ qua trong BodyOf. Compile EA 0 / 0.
    [] Thử: thêm / xoá template (chart và form Add), mở / đóng nhóm và type ở tab Candle.
    + Hai hàng AMA giống hệt (DB chỉ có id 11): OnInit, CIndicatorTemplateManager thêm AMA của chart (ADDED) trước khi tab được dựng từ RAM, event ADDED đến sau
      thêm hàng lần nữa. Sửa: ADDED RemoveRows(id) trước AddRow (thêm mấy lần cũng một hàng).
  - Thêm template là việc lớn của Python: CPythonBridge::OnChartEvent (template / cặp ADDED, DELETE) tạo Python_Jobs.flag (PYTHON_JOBS_FILE, cạnh DB);
    main.py process cha thấy file mỗi nhịp (libdb.jobs_changed, JOBS_FLAG) thì xoá file, dừng Current đang chạy, chạy lại ngay (không chờ WORKER_CHECK_SECONDS).
    EA OnChartEvent chuyển event cho m_PythonBridge. Compile EA 0 / 0, ast OK. [] Thử: thêm template, Python_Parent.txt có "the jobs changed".
  - Python No Duplicate: data.py bỏ TIMEFRAMES chép tay, đọc bảng timeframes (libdb.timeframes(): tên -> tf_enum = TIMEFRAME_* của gói, 21 / 21 khớp).
    Python.md ghi cả hai.
  - Trade marker đè Pannel sau đổi TF: terminal vẽ lại "autotrade" lúc EA deinit/init, không có OBJECT_CREATE (log: 657/947 object trước và sau).
    Sửa: constructor CChartObj gửi CHART_OBJ_EVENT_OBJECTS_CHANGE, CGUIPannel BringToTop như khi có trade mới. Còn nháy ~0.5 s (thời gian OnInit). Đã thử OK, gỡ debug.
  - Python No Duplicate: EA ghi vào Setting_PythonBridge signal_buy/sell/none, object_python, collection_series/signals, swing_price_basis_wick,
    structure_lookback, file_current_*/file_history_done/file_jobs. Python bỏ SIGNAL_DIRECTION, OBJECT_DE_TYPE_PYTHON, COLLECTION_*_ID, SETTING_NAMES,
    MILESTONES, JOBS_FLAG, PRICE_BASIS_WICK, LOOKBACK; comment libdb ngắn lại. Còn chép tay: đường dẫn DB (bootstrap), tên table / param / type (khoá).
  - FRAMA: chart giữ 2 params (period, applied price, không Shift), schema 3 (parity iFrAMA khớp Python ~1e-10). EA gắn 3 params -> ChartIndicatorAdd 4114;
    đọc từ chart 2 params -> template 18 hỏng ('14, 1') -> Python "does not calculate". Sửa như Volumes: CChartObj::ChartParams bỏ Shift (so với chart), ChartIdentity chèn Shift 0.
    IndicatorCreate cần 3 params (2 -> 4002). 4114 trước đây: IsIndicatorShownOnChart so 3 với 2 params, không thấy FRAMA đã có, gắn trùng.
    Thử 08:14 XAUUSD M1: EA tự gắn FRAMA, hiện trên chart, không lỗi.
    AddToDB không ghi template sai số params của schema; ShowIndicatorOnChart báo lỗi (trước im lặng); main.py sửa câu thông báo. [] Thử: Show FRAMA hiện đường.

2026 1105 Update Note
  - EA bị terminal gỡ khi tự đổi TF (m_btngroup_tf_switch, timer): OnDeinit reason=3 chạy xong, không có OnInit, journal "removed", không báo lỗi; Python còn chạy một lúc vì giữ pid khi REASON_CHARTCHANGE.
    Thử: toolbar 14 lần OK, EA test chỉ gọi ChartSetSymbolPeriod 60 lần OK, EA V4 tự gọi thì mất. Không phải do delete/new CDatabaseService. Cơ chế bên trong terminal chưa rõ.
    Sửa: CChartObj::SetSymbol gọi SetAvailable(false) sau ChartSetSymbolPeriod; OnTick, OnTimer, OnChartEvent thoát khi !m_ChartObj.IsAvailable(). m_ChartObj tạo lại ở OnInit nên cờ tự về true.
    Đã thử: timer 40 lần, nút 59 lần, không mất. Không có giới hạn thời gian: nếu terminal không đổi TF thì EA đứng đến khi attach lại.
  - invalid pointer access khi đóng EA: destructor CAccountsCollection gọi UpdateDataToDB sau khi OnDeinit đã delete m_DatabaseService. Sửa: gọi trong OnDeinit trước delete, destructor để trống. Log xác nhận hết lỗi.
  - m_DatabaseService giữ lại qua đổi TF: OnInit chỉ new khi NULL, OnDeinit không delete khi REASON_CHARTCHANGE, CDatabaseService::OnInitEvent thoát theo m_first_start.
  - Chạy song song DB cũ và NewSQLite, cũ ở trên, mới ở dưới, bỏ dần. CSymbolTFManager là center của Symbol + TF. CSymbolTFManager::OnInitEvent tạo trong NewSQLite:
    + symbol_base và seed 7 dòng, cùng id DB cũ.
    + symbols: khoá (account_key, name), symbol_base_id chỉ để map symbol giữa các account.
    + Setting_SymbolTF: khoá (account_key, name, tf_enum).
    symbols và Setting_SymbolTF còn rỗng. CIndicatorTemplateManager, CAccountsCollection đã đọc NewSQLite; còn lại và Python vẫn dùng DB cũ. libdb.py dòng 466, 476, 483, 490 phải đổi khi Python sang NewSQLite.
  - Để sau:
    [] CDatabaseService::Read nuốt lỗi: DatabaseReadBind lỗi vẫn return true. 16:59 đọc ra 0 template, 0 indicators, DB vẫn có 5 dòng; lần sau đọc đủ 5. Nên sửa trước khi chuyển thêm class sang NewSQLite.
    [] ChartIndicatorAdd 4114 mỗi lần OnInit (PSAR 2, BBands, MA), ChartObj.mqh: nghi IsIndicatorShownOnChart không nhận ra indicator đã có, handle lỗi không IndicatorRelease.
    [] CSymbolTFManager constructor chưa có m_CDatabaseService(NULL).
    [] CIndicatorTemplateManager::OnInitEvent chưa có cờ, chạy lại mỗi lần đổi TF.
    [] Xoá Test\Test_ChartSetSymbolPeriod.mq5.
    [] Tools > Options > Expert Advisors: "Disable algorithmic trading when the charts symbol or period has been changed" đang tích; bỏ tích khi làm Automatic Trade.
2026 1106 Update Note
  - CBarInformationSetting: overload ghi của ParamValue đổi tên thành SetParamValue. Lời gọi đọc rơi vào overload ghi, UpdateDataToDB đặt RAM về 0 lúc attach, phát SETUP_CHANGED và làm xoá rows của 32 type ở DB cũ.
  - Đổi tham số: xoá xong type cuối thì CBarTimeSeriesCollection gửi BAR_INFORMATION_MANAGER_EVENT_RESET_DONE, CPythonBridge tạo Python_Jobs.flag, Current Python worker chạy lại.
    [] History Python worker đang tạm dừng: phần bar cũ của type đổi tham số chờ History bật lại.
  - TẠM TẮT Python (2 chỗ this.Launch trong CPythonBridge) trong lúc chuyển việc DB từ Collection về Manager. Khi tắt không có SYMBOLTF_DONE nên Library không đọc rows lên RAM và không judge.
    [] Bật lại Python, rà soát khi Cut Over.
  - CBarInformationManager::OnInitEvent tạo BarTimeSeriesCollection, BarSeriesDE trong DB Account mới qua CDatabaseService (cùng schema). Nhánh cũ trong CBarTimeSeriesCollection giữ nguyên.
  - CBarInformationManager, CSyncManager: bỏ m_db, đọc ghi hoàn toàn qua CDatabaseService (code cũ để trong comment). SyncDataFromDB -> ReadDataFromDB, SyncDataToDB -> UpdateDataToDB; ResetStep bỏ tham số account_db; Import_SyncManager comment out.
  - Chuyển đọc ghi DB về Manager (code cũ để trong comment): BarTimeSeriesCollection + BarSeriesDE về CBarInformationManager; SignalsCollection về CIndicatorTemplateManager. CBarTimeSeriesCollection, CSignalsCollection và các class con không còn m_db. Thêm CDatabaseService::InList.
    [] Còn m_db: CHistoryCollection, CTradeEventsCollection (chưa có manager), CSymbolTFManager, CPythonBridge.
  - CPythonBridge: bỏ m_db, Setting_PythonBridge và các file milestone qua CDatabaseService (thư mục NewSQLite). CHistoryCollection, CTradeEventsCollection để nguyên ở DB cũ, không ảnh hưởng tính toán.
  - CSymbolTFManager: bỏ m_db, đọc ghi qua CDatabaseService theo (account_key, name). CSymbolTFSetting bỏ m_symbol_id. Thêm cặp không còn yêu cầu symbol phải map symbol_base.
  - symbol_id -> name: Setting_Sync (account_key, name, ...), BarTimeSeriesCollection, BarSeriesDE, SignalsCollection (name, ...) trong DB mới; CSyncManager, các class con và GUI theo. Bốn bảng rỗng trong NewSQLite đã DROP để EA tạo lại theo schema mới.
    [] Python: libdb.py và các query đổi symbol_id -> name khi Cut Over. Orders, TradeEvent vẫn symbol_id ở DB cũ.
  - Tạm thời không ghi Orders, TradeEvent (chưa thống nhất cách ghi, ưu tiên chuẩn bị RiskManagement): CHistoryCollection, CTradeEventsCollection bỏ m_db, chỉ giữ RAM lấy từ terminal. GUI OrderDetail và tab History đọc m_HistoryCollection.GetList().
    [] OrderDetail không còn dòng event (PLACED, MODIFY...). Tab History: cột Fee trống với deal không có Bid, Ask trong phiên.
    [] Chốt cách ghi TradeEvent. RefreshMarket, RefreshHistory, Refresh đang gọi thẳng trong OnTrade, chưa chuyển sang OnTradeTransaction.
  - CSignalsCollection làm theo mẫu CIndicatorsCollection: tạo series trong OnInitEvent từ CSymbolTFManager.Pairs và CIndicatorTemplateManager.TemplateIds, đọc rows một query cho cả cặp rồi chia theo template. Tên RAM: Create_RAM, Read_RAM, Update_RAM, Delete_RAM (CSignalsCollection, CIndicatorsCollection); tên DB: ReadDataFromDB, UpdateDataToDB.
    [] CBarTimeSeriesCollection, CBarSeriesDE, CBarControl chưa làm theo mẫu này. Rows chỉ test được khi bật Python.
  - Bỏ hậu tố tên class ở method (CommonRule R2): SendEvents, RefreshTimeseries, Reset, AlertOnPair, DeleteMarkers, SyncMarkers, AddBars, ReadNewestBar, ReadCandle, Advance, ResetStep, ResetObject, NextPair, DropMark, Ranges, CreateTable, Row. CBarTimeSeriesCollection: AddSeries_, DeleteSeries_ thành Create_RAM, Delete_RAM.
  - Bỏ include DatabaseDELib.mqh trên toàn EA và Library V4 (file còn đó, không ai dùng). write_flag, write_queue chuyển sang DatabaseService.mqh.
    [] Python: write_queue là mutex giữa các worker, vẫn dùng; libdb.py vẫn trỏ thư mục SQLite, đổi lúc rà Python.
  - Python sang NewSQLite, symbol_id -> name trong libdb.py, main.py. EA truyền --database khi launch, account_key và file_account đọc từ Setting_PythonBridge; bỏ các hằng thư mục cứng. Bật lại Launch trong CPythonBridge. History vẫn tạm dừng.
    [] Pair là (symbol, tf_enum, TF name). Python tính mọi symbol trong symbols, kể cả symbol chưa map symbol_base.
  - Chuẩn hóa tên: UpdateTemplate, ShowGroup -> Update_IndicatorTemplate_Setting; Param, ShowGroup, AlertGroup, SoundAlert, MessageAlert, ShowBuySignal, ShowSellSignal -> Update_BarInformation_Setting; setter BuySignal, SellSignal, SoundAlert, MessageAlert -> Update_SymbolTF_Setting; Advance -> Update_Sync_Setting; Ranges -> Read_RAM. Getter giữ tên.
    [] Refresh sort deal theo ticket: đã kiểm chứng đóng 4-5 lệnh cùng mili-giây. Lỗi Opened 0.00 chưa lặp lại.
  - Catalog đọc từ RAM: Read_RAM_Name, Read_RAM_Group, Read_RAM_GroupName, Read_RAM_Buffers, Read_RAM_ParamSchema, Read_RAM_ParamDescription. Một danh sách timeframe: timeframe_list trong CommonDefines.mqh, bỏ LIB_TIMEFRAMES và m_tf_enums, m_tf_names. CIndicatorTemplateManager bỏ Where, xoá template theo id.
  - Một tên Read_RAM + overload cho mọi bản đọc của 3 Manager: Templates, TemplateIds, AlertTemplates, ShownTemplates, GetSetting, Exists, Read_RAM_Name, Read_RAM_Group, Read_RAM_GroupName, Read_RAM_Buffers, Read_RAM_ParamSchema, Read_RAM_ParamDescription (CIndicatorTemplateManager); GetSetting, Group, GroupDescription, Informations, AlertTypes, ShownTypes, Params, ParamValue, AnyShow, AnyAlert (CBarInformationManager); GetSetting, Exists, Pairs, TimeframesOf, Symbols, TimeframeName, BuySignal, SellSignal, SoundAlert, MessageAlert (CSymbolTFManager). IndexSetting thành private. CIndicatorDE nhận manager, tự đọc group và name.
    [] Tên, nhóm, buffers của type đọc qua Read_RAM(type, SIndicatorsRow &row). Giữ SymbolID, AccountSymbol cho nhóm Order.
  - Xoá DatabaseDELib.mqh. Dọn code cũ đã comment trong EA và Library V4: các khối Old Plan, dòng // của code cũ, comment mô tả đi kèm (khoảng 2400 dòng). Phần ghi Orders, TradeEvent cũ cũng bỏ, còn trong git.
    [] Python.md dòng 73 còn nhắc DatabaseDELib.mqh và các macro LIB_DATABASE_*.
