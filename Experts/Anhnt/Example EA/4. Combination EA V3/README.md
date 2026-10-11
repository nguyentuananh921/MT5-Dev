 - Hồ sơ bug (ảnh): thư mục Bug note.
 1. Working Rule:
 [] Trao đổi bằng tiếng Việt, Comment trong code bằng tiếng Anh. 
 [] KHÔNG sửa LOGIC code của tác giả khác (Francis Nyoike Thumbi, Stanley Kimathi Kibaara và bất kỳ ai sau này). Chỉ đọc để lấy concept, rồi áp dụng và sửa EA V3 và Lib V3 cho phù hợp. Lỗi trong logic của họ chỉ ghi chú vào README, không sửa. NGOẠI LỆ được sửa: phần comment link reference ở đầu file (do mình ghi để đọc đúng bài), vì không ảnh hưởng code.
 [] Cấu trúc file: MỖI CLASS MỘT FILE (.mqh), không viết kiểu một file chứa nhiều class, và không để logic của object nằm ở hàm global trong file .mq5 như code của Francis. Object tự xử lý hành vi của nó (vòng đời, OnChartEvent, vẽ lại) bằng method của chính class đó, như các class trong Lib V3.
 [] Print Debug: Để tiện cho việc xóa Print Debug đi thì
   - Print debug ra file lấy tên file là tên class kèm Debug_<which>   
   - ::Print("MY DEBUG    CClassName::MethodName .....=", ....);
   - Print Debug cần được căn lề để khi fold cho tiện theo format 
    //Print Debug
      ->Căn lề từ đây.
    Tức là khi Print Debug phải có class và Method để còn lựa mà xóa đi.
  -Khi EA lớn lên thì print debug thẳng ra file với tên file là tên class
 [] Log có sẵn trong workspace
 [] COde rule
   - Hạn chế dùng number thay vì đó dùng Enum ví dụ thay vì 1 hay 2 nữa mà thay vì thế trong code mình sẽ phải là PRICE_CLOSE và PRICE_OPEN.
    + Các Enum dùng chung sẽ được khai báo trong CommonDefines.mqh các Event dùng cho nhóm nào sẽ khai cụ thể trong nhóm riêng. 
     Ví dụ Enum ENUM_OBJECT_DE_TYPE dùng chung sẽ khai trong CommonDefines
   - Tên của các Properties sẽ dựa trên class thống nhất giữa các layer và class ví dụ.
    + CTimeSeriesEngine CBarTimeSeriesCollection  -> m_BarTimeSeriesCollection;
    + CGUIPannel        CWindow                   -> m_window_main;
    + CTradingEngine    CSymbolsCollection        -> m_symbol_collection;
    + Biến Pointer sẽ phải trùng tên và note rõ class nào hold nó ví dụ
  - CSymbolsCollection         *m_symbol_collection; //CTradingEngine owns
   = Tên của các method liên quan đến Table và TreeView, SymbolTFSetting,IndicatorTemplateSetting
    + Create: Create<Which>_<Which>
    + CreateTable_IndicatorTemplateSetting(),
    + CreateTable_SymbolTFSetting()
    + CreateTreeView_IndicatorTemplateSetting()
    + CreateTreeView_SymbolTFSetting()
    + Update lần đầu InitializeTabble>_<Which>,InitializeTable_IndicatorTemplateSetting()    
    + Modify số lượng nhỏ   AddRow_<Which>,DeleteRow_<Which>,HighLightRow_<Which>, UpdateRow_<Which>
    + Hành vi sửa hàng loạt:   SyncTable_<Which>,
  - Với Table SymbolTFSetting chỉ có 3 method
    + PopulateTable_SymbolTFSetting
    + CreateTable_SymbolTFSetting
    + SyncTable_SymbolTFSetting()  
  - Với TreeView không tách bạch được việc sửa 1 đơn vị nhỏ và sync hàng loạt nên chỉ có 3 method cần đặt theo thứ tự
    + PopulateTreeView chuẩn bị data
    + CreateTreeView
    + SyncTreeView dựa trên cờ cần sync hay không   
  - Tận dụng triệt đê method trong library tránh thêm các method không cần thiết
    + Ưu tiên method của Library thay vì Buildin.
    + Hạn chế viết method Inline, chỉ các method return ngắn gọn,mới dùng inline.
    + Hạn chế thêm Method thay vì sửa method cũ khiến cho việc dọn dẹp khó khăn.
    + Các method dùng chung giữa nhiều class sẽ thêm ở DebLib và khai báo trong CommonCommonDELib.mqh
    + Tránh trùng lặp giữa các method cùng function chỉ khác name. 
    + Cụ thể: Library đã có PrintParameters mà vẫn muốn thêm trong Deblib 
    + Thống nhất lại format của Comment ở mỗi đầu hàm theo format.
   //+-------------------------------------------------------------------------+  
   //|                                                                         |
   //+-------------------------------------------------------------------------+  
2. Version Update
 - Từ bản V3: LibLibrary là "4. Combination Lib V3, EA là "4. Combination EA V3";
  + Mọi tính toán được chuyển sang dùng Python.
  + EA, GUI, ChartObj hoạt động như View + Control trong mô hình MVC.
3. EA gồm có 
 - Configuration: Live config thay đổi runtime được luwut rong Configuration
   + JSONConfig : save cấu hình
   + IndicatorSetting.mqh tương ứng với IndicatorTemplateManager.mqh
   + SymbolTFSetting.mqh tương ứng với SymbolTFManager.mqh
   + TradingSetupSetting.mqh tương ứng với TradingSetupSettingManager.mqh
   + CPatternSetting.mqh tương ứng với CPatternManager.mqh
   + MarkerSetting.mqh
   + SmartMoneySetting.mqh   
  
  //-Temporaty stop here note below for me
  Concept
  - 3 Main Market Condition: Uptrend, Downtrend,Rangbound  (Sideway)
  - 2 Important Movement: Impulsive move -> move follow the trend, Retracement move -> Pull Back
  = 4 recurring market cycles: accumulation, markup, distribution
  []
  - Francis Nyoike Thumbi: Born -> Live -> Dead 
  - Stanley Kimathi Kibaara: 23049: Market Structure Framework  
  [] Integrating AI
    - articles/22526
  [] LiquLiquidity Sweep 22140

4. Rà soát trước khi implement Market Structure Framework + Francis Nyoike Thumbi (chưa sửa code)
 - Nguồn reference (link nằm ở đầu file):
   + Stanley Kimathi Kibaara/Market Structure Framework: bài 23049 (MarketStructureIndicator.mq5). 10 file mqh: SwingDetector, LevelTracker, BreakDetector, StructureClassifier, StateMachine, EventBus, Persistence, StructureManager, MarketStructureFramework, MarketStructureTypes.
   + Francis Nyoike Thumbi: 1.Stateful Trendline (không có link), 2.Trendline Discovery (23626, 242533 <- nghi gõ nhầm 24253), 4.Supply/Demand Zones DynamicSR4 (75178; 24068, 24253, 23346, 23547), MarketBehaviorAnalyzer (23852). Không có thư mục 3.
   + Concept Born -> Live -> Dead của Francis áp dụng cho Trend và Zone (ManagedTrendline, TrendlineManager). CHƯA đọc, cần đối chiếu với Lib V3.
 - Event trong Lib V3 (Entities\Bases):
   + CBaseEvent (reason, id, value) = LOẠI event, ví dụ "chuột vào vùng". Không có time là đúng.
   + CEventBaseObj (time, id, lparam, dparam, sparam) = BẢN GHI lần xảy ra, ví dụ "10h20 chuột vào vùng". CBaseObjExt::CheckEvents đổi CBaseEvent thành CEventBaseObj và thêm time + tên object.
   + Cả hai là data thuần, chỉ có Compare.
   + Mỗi object tự giữ m_list_events (BaseObjExt, GBaseObj), Collection duyệt từng object để đọc (polling phân tán). Chưa có nơi chung.
   + V3 chưa có EventBus là đúng vì chưa implement. Phần dưới là KHOẢNG CÁCH so với khái niệm EventBus (ai cũng Publish vào một chỗ, ai cũng đọc được), không phải lỗi.
   + Khoảng cách V3 so với EventBus:
     (1) Time: m_time của CEventBaseObj không được gán, Time() trả rác. Time thật chỉ là phần ms nhét trong lparam qua MSCfromTime(TickTime()) ở CBaseObjExt::CheckEvents. Cần gán m_time để event trên bus biết "lúc nào".
     (2) Một cửa Publish: hiện có 2 đường tạo event, CBaseObjExt::EventAdd (có Sort+Search dedupe) và GBaseObj::CreateAndAddNewEvent/AddEvent (không dedupe). Cần gom về một đường.
     (3) Id duy nhất: ID() là loại event, không phải id của từng lần xảy ra. Cần quyết có cần id lần xảy ra (để tra kiểu FindEventById) hay không.
     (4) Quyền sở hữu: event nằm trong list của từng object và bị ResetChangesParams xoá. Cần quyết bus giữ event hay chỉ tham chiếu.
     (5) Nơi đọc chung: Collection đang duyệt từng object. Đây là chỗ bus thay vào.
     (6) Payload Market Structure (price, level, type) chưa có chỗ chứa.
   + Compare của CEventBaseObj bỏ qua Time. Nếu đưa Time vào Compare thì hành vi dedupe đổi.
 - CEventBus của Stanley:
   + Ring buffer chứa SStructureEvent: Publish, GetEvent(0 = mới nhất), FindEventById. CEventCache là ring buffer dedupe theo (type,time,price,level), mỗi CStructureManager giữ 1 cache riêng.
   + Nhiều bên Publish vào 1 bus (StructureManager, StateMachine), bus do CMarketStructureFramework sở hữu.
   + KHÔNG có Subscribe/callback. Bên tiêu thụ phải tự hỏi bus (polling). Chưa phải publish/subscribe thật.
 - Hai việc của mỗi object ở V3:
   + Việc 1: xử lý nội bộ (ví dụ checkbox check/uncheck thì tự vẽ lại hộp). Không đi qua bus.
   + Việc 2: SendEvent ra ngoài ("tao vừa bị check/uncheck"). Các bên khác căn cứ event đó để làm việc tương ứng. Việc này là vai trò của bus.
 - Hướng đề xuất (chờ chốt):
   + Lib V3 có 1 EventBus dùng chung, event dùng kiểu CEventBaseObj sẵn có, không thêm class event mới.
   + Cần chốt: bus chỉ là kho chung kiểu Stanley, hay có Subscribe/callback. Bus nằm ở Lib, việc đăng ký nghe nằm ở EA.
   + Cần chốt: price/level/type của Market Structure đặt ở đâu (mở rộng CEventBaseObj hay để SStructureEvent làm payload riêng cho nhóm Market Structure).
 - Việc cần làm tiếp:
   [] Đọc code GUI V3 (checkbox, CWindow) xem hiện đang gửi event ra bằng cách nào (OnChartEvent / EventChartCustom / m_list_events).
   [] Đọc ManagedTrendline, TrendlineManager, zone trong DynamicSR4 để đối chiếu Born -> Live -> Dead.
   [] Chốt hướng cho các khoảng cách (1) đến (6), rồi mới sửa. Kiểm tra các EA và indicator include BaseObjExt, GBaseObj, EventBaseObj trước khi sửa.
 
5. Concept: EventBus quản lý vòng đời Born -> Live -> Dead của Zone và Trendline (đã đọc code Francis, chưa sửa code)
 - Kiểm tra link reference (đã mở mql5.com):
   + ĐÚNG: 23626 (Smart Chart Objects P1), 24253 (Smart Chart Objects P2, Trendline), 23346 (Zone Manager P3), 23547 (Zone Manager P4), 23852 (Market Behavior Analyzer), 23049 (Stanley, Hierarchical Market Structure Framework).
   + SAI trong DynamicSR4.mq5 (ĐÃ SỬA comment link ở đầu file): Part 1 ghi 24068 (thực ra là Session Analysis Tool), phải là 22666. Part 2 ghi 24253 (là bài Trendline), phải là 23079 (Zone Manager P2: Event-Driven Architecture and Persistent Lifecycle Logging).
   + Chuỗi Trendline tên thật là "Developing Smart Chart Objects in MQL5". Chuỗi Zone là "Interactive Supply and Demand Zone Manager in MQL5".
 - Francis KHÔNG có event bus. "Event" của ông ấy là:
   + Event chart MT5 (OnChartEvent: tạo, kéo, xoá object) do CTrendlineManager::HandleChartEvent xử lý.
   + ENUM_ZONE_EVENT trong MasterLog2.mqh (ZE_CREATED, ZE_MODIFIED, ZE_UPDATED, ZE_DELETED, ZE_GHOSTED, ZE_RESURRECTED) chỉ dùng để GHI LOG CSV qua CLogger.
   + Trendline chỉ PrintFormat, chưa có enum event.
   => Chuyển trạng thái và ghi log nằm lẫn trong code xử lý. Cần tách: chuyển trạng thái -> Publish event -> bên khác (log, vẽ, EA) lắng nghe.
 - Vòng đời thật trong code:
   + BORN: Trendline UNKNOWN -> ACTIVE (lần Update đầu). Zone ZONE_VIRGIN lúc khởi tạo, log ZE_CREATED (user vẽ hoặc auto detect).
   + LIVE: Trendline ACTIVE -> TOUCH_PENDING -> BOUNCED (bounce_count++, về ACTIVE) hoặc BROKEN. Zone touch/bounce/failure ghi ZE_UPDATED. Kéo/đổi biên, merge ghi ZE_MODIFIED.
   + GHOST/BROKEN: Trendline BROKEN (có m_bars_since_break). Zone ZONE_BROKEN, ZE_GHOSTED. Cần BreakConfirmCloses nến đóng liên tiếp.
   + RESURRECT: BROKEN -> ACTIVE khi giá quay lại trong cửa sổ resurrection_bars, resurrection_count++. Zone ZE_RESURRECTED (cần AllowResurrection).
   + DEAD: Trendline BROKEN quá expiration_bars -> EXPIRED + ObjectDelete. Zone ghost quá hạn bị xoá (ZE_DELETED, "ZONE EXTINCTION"), user xoá (ZE_DELETED), bị merge hấp thụ vào zone khác (zone sống ghi ZE_MODIFIED, zone bị hấp thụ bị purge).
 - Khác biệt hai bên: Trendline có TOUCH_PENDING, RETESTED, EXPIRED (enum ENUM_TRENDLINE_STATE 7 trạng thái). Zone chỉ có VIRGIN, BROKEN, INACTIVE, phần còn lại nằm ở bộ đếm và ZE_*. Chưa có enum vòng đời chung.
 - Lưu ý với V3: ENUM_BASE_EVENT_REASON (CommonDefines.mqh) hiện là kiểu "thay đổi giá trị property" (INC, DEC, MORE_THEN, LESS_THEN, EQUALS). Event vòng đời (Born, Touch, Bounce, Break, Resurrect, Dead) KHÔNG khớp reason này. Cần một enum event vòng đời chung (khai trong CommonDefines.mqh theo Working Rule) dùng làm event_id (ushort) của CEventBaseObj, hoặc mở rộng reason.
 - Việc cần quyết khi implement vào Lib V3 / EA V3:
   [] Enum vòng đời chung cho Trendline và Zone, và event id tương ứng (xem mapping ở trên).
   [] Bus giữ event hay chỉ tham chiếu (xem mục 4, điểm 4).
   [] Subscribe/callback hay polling.
   [] Zone và Trendline chuyển sang kế thừa/dùng chung lớp "Managed object có vòng đời" trong Lib, bus nằm ở Lib, EA đăng ký lắng nghe.
 - Cấu trúc code Francis KHÔNG theo kiểu của V3 (chỉ ghi chú, không sửa): CZone (DynamicSR4.mq5 dòng 126-300) chỉ là data class. Logic vòng đời nằm ở hàm global trong file .mq5: MonitorZoneLifecycle, ResolvePendingInteractions, MergeZones, DetectDynamicZones, TryCreateAutoZone, UpdateZoneVisuals, OnChartEvent. CZone không có OnChartEvent/Update/Draw riêng. Trendline thì tách tốt hơn: CManagedTrendline có state + Update, CTrendlineManager có HandleChartEvent.
   + Khi đưa vào V3: tách theo mẫu V3, mỗi class một file, hành vi vòng đời (Update, kiểm tra Born/Touch/Break/Dead, phát event) là method của chính Zone/Trendline/ProtectedLevel. Chưa có ZoneManager ở đâu cả (cả Francis lẫn V3), cần quyết có tạo hay không.
 - Ghi chú nhỏ trong code Francis (chỉ ghi chú, không sửa): ManagedTrendline.mqh (SmartTrendline2) dòng ~407-410 gán m_bars_since_break = 0 rồi mới PrintFormat nó, nên log "RESURRECTED after %d bars" luôn in 0.

6. Swing và Protected Level (đã đọc Stanley: Types, LevelTracker, EventBus)
 - Swing KHÔNG có vòng đời. Swing đã xác nhận thì bất biến (SSwingPoint không có cờ trạng thái). Chỉ có việc cập nhật swing gần nhất khi đủ nến bên phải để xác nhận. Swing chỉ bắn event "swing mới được xác nhận" (EVENT_SWING_HIGH_CREATED / EVENT_SWING_LOW_CREATED), không cần máy trạng thái.
   + Định nghĩa Swing (đã chốt, cả 3 bên đều giống nhau): N nến mỗi bên, N mặc định = 5, tức 5 nến trước + 5 nến sau + nến swing = 11 nến.
     Swing high = nến có high LỚN HƠN HẲN high của 10 nến còn lại. Swing low = nến có low NHỎ HƠN HẲN low của 10 nến còn lại. Hòa thì KHÔNG phải swing.
   + Xác nhận trễ N nến: chỉ chốt swing sau khi đủ N nến bên phải (confirmed time = pivot time + N periods). Swing gần nhất luôn "chưa chốt" trong N nến đó.
   + So sánh 3 nơi:
     - Mình: swing.py (find_swings) và CSmartMoneySetting (m_strength = 5, cấu hình JSON m_swing_strength). Một N duy nhất.
     - Stanley: SwingDetector.mqh, InpInternalSwingStrength = 5 (khung hiện tại), InpExternalSwingStrength = 8 (khung lớn hơn), N tối thiểu 2.
     - Francis: DynamicSR4.mq5 input SwingBars = 5, vòng j = 1..SwingBars kiểm tra i-j và i+j.
   + V3 mới có một N. Nếu cần cấu trúc Internal/External như Stanley thì phải thêm tham số N thứ hai.
 - Protected High/Low (CLevelTracker, SProtectedLevel) CÓ vòng đời:
   + Born: UpdateProtectedLevels() chọn từ lịch sử 3 swing gần nhất (bearish chọn lower high, bullish chọn higher low), isValid = true.
   + Live: level đang hiệu lực, dùng để BreakDetector so sánh.
   + Dead: InvalidateHigh()/InvalidateLow() sau khi bị phá (isValid = false). Không có Resurrect, không có expire theo thời gian.
   + Đây là "vai trò" (slot) đặt lên swing bất biến bên dưới. Swing không đổi, level được gán rồi bị phá.
 - Ghi chú về code Stanley (chỉ ghi chú, không sửa): UpdateProtectedLevels() luôn đặt isValid = true nếu còn swing trong lịch sử. Mà ProcessSwingHigh() và ProcessSwingLow() đều gọi nó cho CẢ HAI phía. Suy ra: protected high vừa bị Invalidate có thể được bật lại isValid = true (cùng giá cũ) ngay khi có swing low mới. Chưa chạy thử xác nhận, cần kiểm tra lại trước khi dựa vào hành vi này.
 - Event của Stanley (ENUM_EVENT_TYPE): SWING_HIGH/LOW_CREATED, INTERNAL/EXTERNAL x BOS/CHOCH x BULLISH/BEARISH, STATE_CHANGED. ENUM_MARKET_STATE (UNKNOWN, BULLISH, BEARISH, TRANSITION, RANGE) là trạng thái thị trường của máy trạng thái, KHÔNG phải vòng đời object.
 - SStructureEvent: eventId (duy nhất, do CEventIdCounter cấp), type, time, price, level (internal/external), direction, state, confidence. So với CEventBaseObj của V3: V3 chưa có eventId duy nhất cho từng lần xảy ra, chưa có level/direction/confidence.
 - Phân loại object (để chốt vòng đời chung):
   + Có vòng đời Born -> Live -> Dead: Trendline, Zone, Protected Level.
   + Không có vòng đời (bất biến, chỉ bắn event tạo): Swing.
   + Là trạng thái chứ không phải object: Market State (ENUM_MARKET_STATE).
 - Reference link: đã bổ sung link bài 23626 (Part 1) vào đầu SmartTrendlineManager.mq5 (thư mục 1).

7. Quyết định: cách truyền event vòng đời (đã chốt khi trao đổi)
 - Không dùng EventBus/Subscribe/callback kiểu Stanley. Dùng EventChartCustom + chuỗi mã trong EventDefines.mqh như hiện tại.
 - Lý do:
   + Mọi tính toán ở Python (mục 2). Máy trạng thái vòng đời Born -> Live -> Dead nằm ở Python, KHÔNG viết thành class MQL5 như Francis.
   + CPythonBridge là socket: EA Send(), kết quả về bất đồng bộ qua Poll() trong OnTimer. Không có chuyện "xử lý ngay trong cùng tick".
   + Mẫu đã có sẵn: PythonBridge.mqh (Poll) gọi EventChartCustom(PATTERN_MANAGER_EVENT_CATALOG_CHANGED) khi Python trả dữ liệu thay đổi.
   + Chưa có kế hoạch indicator riêng nhận event từ EA.
 - Luồng: Python tính vòng đời -> trả về EA -> CPythonBridge::Poll() cập nhật -> EventChartCustom(mã vòng đời, lparam, dparam, sparam) -> GUI / Manager / SmartMoneySync nhận ở OnChartEvent.
 - Việc cần làm:
   [] Thêm nhóm mã vòng đời vào EventDefines.mqh, nối sau MOUSE_EVENT_NEXT_CODE (id kiểu ushort, phải < 65536). Chốt 1 nhóm chung hay mỗi loại object 1 nhóm.
   [] Chốt quy ước payload: lparam (loại object + lý do Dead đóng gói), dparam (giá), sparam (tên object).
   [] Viết module Python cho vòng đời (Trendline, Zone, Protected Level) theo concept Francis/Stanley, cùng kiểu swing.py, structure.py.
   [] Thêm message vào giao thức socket Python <-> EA cho event vòng đời.
 - Các khoảng cách ở mục 4 giờ phần lớn thuộc về Python: id duy nhất của từng lần xảy ra, dedupe, lịch sử (giống Persistence của Stanley). EA không cần ring buffer. Mục (1) m_time chưa gán và (2) hai đường tạo event của GBaseObj chỉ còn liên quan nếu tiếp tục dùng CEventBaseObj cho event theo property.
 - Việc chưa đọc: server.py, structure.py, signals.py (giao thức và cách Python giữ trạng thái), SmartMoneySync (cách Python kết quả thành marker trên chart).

8. Kết quả đọc phía Python + bài gốc + đề xuất danh sách event vòng đời (bản nháp, chờ chốt)
 8.1 Phía Python (Lib V3\Python: server.py, model.py, swing.py, structure.py)
 - Giao thức socket theo dòng, EA <-> Python (127.0.0.1:9090). Lệnh EA gửi: init, watch, pre_trade_symbol_monitor, quit (JSON). Dữ liệu Python gửi về là dòng text ngăn bằng |: swing|sym|tf|time|confirmed_time|type|price|structure, structure|sym|tf|break_time|swing_time|type|dir|level, signal|..., pattern|..., pre_trade_symbol_monitor|... Điều khiển trả JSON (pair, done, watch, error).
 - State của Model khoá theo (symbol, tf_text), KHÔNG theo socket (self.bars, self.swings, self.structures...). Client chỉ giữ watching = (symbol, tf) và các cờ watch_*. Đổi chart / đóng socket không làm mất state. Python tự restart khi source đổi (source_stamp) thì mất state, EA kết nối lại và gửi lại cấu hình + watch.
 - Model KHÔNG phải máy trạng thái tăng dần. Mỗi nến đóng mới (check_new_bars) Python lấy lại toàn bộ bars, tính lại find_swings/find_structures như HÀM THUẦN, rồi so với kết quả cũ theo khoá (type,time) hoặc (type,dir,break_time,swing_time) để chỉ gửi phần MỚI (và chỉ lấy dòng có time/confirmed_time > old_last). Dedupe nằm sẵn ở đây, không cần id tăng dần.
 - structure.py hiện tại: tham chiếu là swing xác nhận gần nhất của mỗi phía, cờ "used" để chỉ báo một lần. BOS nếu phá HH/LL, CHOCH nếu phá LH/HL (dựa nhãn structure của swing, không dùng hồi quy xu hướng như Stanley). Chỉ có 1 khung (không Internal/External).
 - Chưa có: lưu object do người dùng vẽ (Trendline, Zone), chưa có lệnh thêm/sửa/xoá object, chưa có logic vòng đời.
 8.2 Phía EA nhận dữ liệu
 - CPythonBridge::Poll() (OnTimer) đọc dòng, StoreSwing/StoreStructure tạo CBarSwingSeries / CMarketStructureSeries. Sau burst đầu (m_watch_done) mỗi dòng mới được dedupe bằng Search theo CODE (SWING_PROP_CODE = time+type+period+symbol là khoá chính), rồi GỌI THẲNG m_SmartMoneySync.Add(...). Đây là gọi trực tiếp, không qua EventChartCustom.
 - EventChartCustom hiện chỉ dùng cho thay đổi danh mục pattern (PATTERN_MANAGER_EVENT_CATALOG_CHANGED) và cho GUI/Manager.
 - V3 đã có khoá duy nhất dạng "code" ghép (SWING_PROP_CODE, MARKET_STRUCTURE code) nên không cần eventId tăng dần như Stanley.
 8.3 Bài gốc (đã mở mql5.com, tóm tắt bằng công cụ, đã đối chiếu với code)
 - Zone Part I (22666): Born = engine phát hiện pivot (AUTO) hoặc user vẽ (USER). ZONE_VIRGIN -> ZONE_BROKEN (ghost) sau BreakConfirmCloses nến đóng liên tiếp -> hồi sinh nếu AllowResurrection -> bị xoá sau GhostBarLimit nến (extinction). ZONE_INACTIVE được định nghĩa nhưng không bao giờ gán. NukeIrrelevantZones xoá zone giá đã đi qua lúc khởi động. AUTO zone user xoá thì vào blacklist; AUTO zone user kéo thì thành USER. MergeZones gộp zone cùng loại cách nhau < ATR x 1.5, giữ USER nếu một trong hai là USER.
 - Zone Part II (23079): chuyển user action sang OnChartEvent (OBJECT_CREATE / DRAG / ENDEDIT / DELETE), 5 event ZE_CREATED, ZE_MODIFIED, ZE_DELETED, ZE_GHOSTED, ZE_RESURRECTED (ZE_UPDATED xuất hiện trong code Part III/IV). Log CSV 9 cột: Time, Source (USER/AUTO/SYSTEM), Event, Zone_ID, Type, Top, Bottom, Context, Message. Lỗi của tác giả: xoá object bị log ZE_DELETED hai lần (handler + RemoveZoneByName).
 - Trendline Part 2 (24253): hai đường vào (user vẽ, hoặc CTrendlineBuilder sinh từ swing) cùng hội tụ vào CManagedTrendline. ACTIVE -> TOUCH_PENDING -> BROKEN (break-side closes >= m_break_confirm_closes) hoặc BOUNCED (-> ACTIVE, bounce_count++). BROKEN: resurrection trong m_resurrection_bars, hoặc EXPIRED sau m_expiration_bars + xoá object. RETESTED có trong enum và màu nhưng không có chỗ nào gán trạng thái này. Bài phân biệt "quan hệ thị trường" (break) với "tuổi thọ object" (expire).
 - Stanley (23049): bus KHÔNG bất đồng bộ, bên dùng phải polling (đúng như đã đọc). Protected level bị invalidate khi bị phá "để không báo cùng một lần phá hai lần". Internal (khung hiện tại) + External (khung cao hơn, mặc định H4). Máy trạng thái 5 trạng thái, mỗi lần chuyển phát EVENT_STATE_CHANGED. Dedupe bằng CEventCache cục bộ. Tác giả tự nhận là prototype, logic BOS/CHoCH đơn giản, chưa có unit test.
 8.4 Đề xuất danh sách event vòng đời (Trendline, Zone, Protected Level)
 - Event (nối tiếp chuỗi EventDefines.mqh, id ushort):
   + BORN: object được tạo. Kèm nguồn AUTO hoặc USER.  (ZE_CREATED, Trendline đăng ký)
   + MODIFIED: biên / neo thay đổi (user kéo, hoặc zone sống sót sau merge). (ZE_MODIFIED)
   + TOUCHED: giá vào vùng chạm, chờ phân xử (TOUCH_PENDING). (ZE_UPDATED chạm)
   + BOUNCED: xác nhận bật ra, bounce_count++. (ZE_UPDATED bật / BOUNCED)
   + BROKEN: xác nhận phá (ghost). (ZE_GHOSTED / TRENDLINE_STATE_BROKEN)
   + RESURRECTED: hồi sinh từ ghost. (ZE_RESURRECTED)
   + DEAD: kết thúc, kèm LÝ DO.  (ZE_DELETED / EXPIRED)
 - Lý do DEAD (enum riêng): EXPIRED (ghost quá hạn), USER_DELETED, MERGED (bị hấp thụ), OBSOLETE (giá đã đi qua lúc khởi động, kiểu NukeIrrelevantZones). Với Protected Level: DEAD vì bị phá (consumed) - cần chốt có thêm lý do này không.
 - Không đưa vào: RETESTED (Francis không bao giờ gán), INACTIVE (không bao giờ gán), Swing (bất biến, chỉ là dòng dữ liệu swing| sẵn có), BOS/CHoCH (đã là dòng structure| sẵn có), STATE_CHANGED của Stanley (trạng thái thị trường, không phải vòng đời object).
 - Cách tính ở Python: viết vòng đời như HÀM THUẦN theo đúng kiểu find_swings/find_structures: lifecycle(bars, anchors của object) -> các dòng chuyển trạng thái (object_id, event, time, price, reason). Mỗi nến đóng tính lại và so với kết quả cũ theo khoá (object_id, event, time) để chỉ gửi phần mới. Cách này tự dedupe, không mất state khi reconnect, và kết quả tái lập được khi backtest.
 - Dòng gửi EA đề xuất: lifecycle|sym|tf|kind|object_id|event|time|price|reason. EA Poll() lưu rồi phát EventChartCustom(mã event, lparam, dparam, sparam) cho GUI/Manager (quyết định ở mục 7).
 - Người dùng vẽ / kéo / xoá Zone, Trendline: chart là nguồn sự thật của neo (anchor). EA bắt sự kiện chart rồi gửi lệnh mới sang Python (cần thêm cmd, ví dụ object_add / object_update / object_delete). Python restart thì EA gửi lại toàn bộ neo từ chart.
 - Cần chốt tiếp:
   [] Danh sách event và lý do DEAD ở trên (thêm / bớt).
   [] Một nhóm mã chung hay mỗi loại object một nhóm. Đóng gói lparam / dparam / sparam.
   [] Protected Level có đưa vào Python theo kiểu Stanley (chọn theo xu hướng) hay giữ kiểu structure.py hiện tại (swing gần nhất).
   [] Auto-detect Zone/Trendline có làm ở Python ngay không, hay giai đoạn đầu chỉ xử lý object user vẽ.

9. Quyết định đã trao đổi (sau mục 8)
 - Danh sách event và lý do DEAD ở mục 8.4 là bản nháp: bắt tay làm rồi sửa dần.
 - Một concept vòng đời CHUNG cho mọi loại object: một nhóm mã event duy nhất trong chuỗi EventDefines.mqh. Loại object (Trendline, Zone, Protected Level) trong lparam, tên object trong sparam.
 - Object DEAD không bỏ hẳn: vẽ xám để xem lại lịch sử. Đề xuất:
   + Vẽ từ lúc BORN đến lúc DEAD (không kéo tia vô hạn), thấy được tuổi thọ.
   + Chỉ vẽ xám lý do EXPIRED (và OBSOLETE nếu muốn). Không vẽ USER_DELETED và MERGED.
   + Có cờ "Show dead" và giới hạn N object chết gần nhất, đặt trong Setting của EA.
   + Francis đã có ý: ZONE_INACTIVE map màu xám trong GetColor() nhưng không bao giờ được gán; Trendline có BrokenStyle = STYLE_DOT.
 - Tự động phát hiện Zone/Trendline làm TRƯỚC, người vẽ làm SAU.
   + Bài gốc: Zone có ZS_EA (AUTO) và ZS_USER, Trendline "two ways" cùng hội tụ vào CManagedTrendline. Người vẽ là phần ghi đè / bổ sung, không phải đường chính.
   + Tự động là hàm thuần của bars: không cần kho lưu neo, không cần lệnh object_add/update/delete, không cần đồng bộ khi Python restart.
   + Điều kiện: id object tự động phải xác định (ghép loại + thời gian + giá neo) để cơ chế so kết quả cũ/mới hoạt động.
   + Phần khó thật là luật phát hiện và chấm điểm (Part I của Francis mới có strength = 1.0, chưa có mô hình chấm điểm). Chỗ này sẽ trao đổi để cải tiến.
 - Chưa chốt: Protected Level chọn theo xu hướng (Stanley) hay swing gần nhất (structure.py hiện tại).
 - Bước đầu đề xuất: khai nhóm mã event + enum lý do DEAD + enum loại object (EventDefines.mqh / CommonDefines.mqh), rồi viết thử hàm vòng đời Zone ở Python.
