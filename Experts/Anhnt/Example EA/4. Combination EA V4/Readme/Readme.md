- Các nguyên tắc chung được note detail trong CommonRule.md
- Communication Rule: Trao đổi bằng tiếng việt nhưng tránh Confuse mất công làm gì làm lại.
- Nguyên tắc xuyên suốt là:
  - CleanArchitecture
  - MVC (Model-View-Controller)     
  - No Duplicate Everywhere.
  - Sync Everywhere: 
  - Event Rule: Từ V4 trở đi, Chúng ta làm việc theo Event ->Automatic Trade
    + Việc tổ chức trong Event sẽ cần tối ưu để có thể gửi đủ các tham số tránh phải hỏi lại see CBaseObjExt::CheckEvents.
  - Live working in RAM, Save on DB for no more calculation
  - Database rule: 
    + Database đóng vai trò M trong mô hình MVC.
    + Chúng ta có 2 Database: Common và Accounts note detail
      - Common Database chứa các dữ liệu chung cho tất cả các tài khoản
      - Accounts Database chứa dữ liệu riêng cho từng tài khoản.
      - Cả EA và Libary cũng như Python sẽ phải tự Join các bảng khi cần thiết.
      - Việc join dựa trên m_account_key trong CDatabaseService
    + Database được dùng làm Single SingleSource of Truth ->Phân công nhiệm vụ tính toán giữa EA và Python theo Calculation Rule
    + Phía EA + LIbrary có được ưu tiên hơn khi ghi vào Database so với python.
    + Prepare để train cho các mô hình Pridict như XGBoot, Kronos.
    + Prepare để Back Test Strategy.
  - Calculation Rule.
    + Một số công việc mang tính nhỏ nhẹ thì EA và Library làm một mình.
    + Các công việc tính toán lớn Python làm.
    + Cả EA và Python cùng biết cách tính và cùng lưu vào Database.
    + Cùng một việc ma 2 bên thay phiên nhau làm theo sự phân công như tính toán dựa trên các Setting_xxxManager thì cả 2 bên cùng phải biết cách tính và thông báo cho nhau khi EA + Libary chuyển việc tính này sang Python.
  - Parent Child Structure: Mỗi cha có nhiều con, sẽ chủ động quản lý các con này, các con có thể tự nghe Event và tự giải quyết việc của mình, sau đó nếu cần sẽ send Custom Event, các anh chị em cùng cha có thể cùng nghe Event để xử lý không phải nhắc.
    + Ví dụ: EA -> m_GUIPannel (CGUIPannel) -> m_window_main (CWindow) -> m_status_bar (CStatusBar), m_menu_bar (CMenuBar).
      EA chỉ chuyển ChartEvent xuống m_GUIPannel, CGUIPannel::OnChartEvent chuyển tiếp cho từng con (this.Child(i).OnChartEvent), mỗi con tự xử lý phần của mình.
      Cha tạo con bằng AddChild(), con gửi Custom Event khi cần (ví dụ CLICK_EVENT_COMBOBOX_ITEM), cha và các anh chị em cùng nghe. 
- Document Rule: Việc Refactor là không tránh khỏi tuy nhiên cần có document để nhắc nhau tránh lặp lại lỗi cũ đi lạc.    
- Update được note trong Update/Update.md
- Update & Implementation Rule: Mỗi lần Update và Implementation, chúng ta sẽ rà soát lại để đảm bảo các rule ở trên. 
  Điều này sẽ khiến quá trình Update và Implementation chậm hơn nhưng về lâu dài sẽ hiệu quả.  
  Cách làm là tạo dần các file trống rồi copy sang file mới. Tránh copy cả mớ gây duplicate code,enum, properties.
  Ngoài ra thì cần nhìn tổng thể trước khi update & implementation và chủ động modify các thứ khác: class, module, database cho phù hợp với nguyên tắc chung.- 
   Chúng ta sẽ có 2 DB
 * Oninit EA, và các class manager trong Library đóng vai trò Controller trong mô hình MVC sẽ Oninit, khởi tạo DB và các Setting_xxx tương ứng với giá trị mặc định.
   - Có một Current Python worker luôn tính ngay khẩn trương dữ liệu hiện tại theo thứ tự ưu tiên
    1. Dữ liệu trên tương ứng với Symbol + TF trên Chart. 
    2. Dữ liệu còn lại trong Setting_SymbolTF.
    3. Dữ liệu hiện tại trong các symbol + tf khác.
    4. Update Setting_Sync để đánh dáu các checkpoint.
 * Sau Oninit: 
    + Mỗi class trong Library đóng vai trò controller quản lý table riêng trong đó.
    + Library đọc dữ liệu đã có và nạp vào RAM để Marker, Candle Info và các View khác truy xuất nhanh.
    + Python đọc các bảng setting và ghi dữ liệu vào bảng tương ứng theo configuration từ phía EA    
    + Python và EA sẽ cùng Update Incremental vào Database, và mark lại việc update đến đâu vào table Setting_Sync này theo nguyên tắc:     
    + Phân giao nhiệm vụ giữa Python và EA dựa trên table Setting_SymbolTF.      
     - EA, Library update phần tiếp theo trong Setting_SymbolTF.
     - Có một Live Python worker tính dữ liệu từ thời điểm Current Python worker tính xong trở về sau.
     - Có nhiều History Python worker tính dữ liệu từ thời điểm Current Python worker tính xong trở về trước. Số lượng tùy theo symbol và History Python worker tính với từng symbol và từng TF. Tính xong thì nghỉ giải lao rồi sang hỗ trợ tay History Python worker khác tính tính tiếp với các cặp còn lại.
     - Khi Market watch thêm Symbol, setting thay đổi mô hình Current Python, History Python và Live Python worker khơi động lại.
    + Thứ tự ưu tiêu khi ghi vào database là
     1. EA và các class trong library.
     2. Live Python worker.
     3. History Python worker.
  * Vì cách phân chia nhiệm vụ giữa phía EA + Library và Python thì cả 2 phía đều phải biết cách tính mọi thứ như nhau, mặc định Python tính phần số liệu lớn EA + Library tính phần số liệu nhỏ.
    - Quy tắc ngữ cảnh (chi tiết trong Python.md): mỗi Job khai context (số nến cần phía trước) và right (số nến cần phía sau). Ai tính đoạn [từ .. tới] thì đọc [từ - context .. tới + right] nhưng chỉ ghi kết quả trong đoạn của mình. Không ai tính lại cả 20000 nến khi chỉ có vài nến mới.    
 * Common DB: Lưu dữ liệu chung cho tất cả các tài khoản.Setting_*, accounts, symbol_base, symbols, timeframes, indicators
  - Table in DB: indicators: catalog các indicator chuẩn MT5 (type_enum, type_name = ENUM_INDICATOR bỏ IND_, name, group_enum, buffers, params_total).
      - Class in Library: CIndicatorsCollection (OnInitEvent tạo bảng, SyncDataToDB ghi) ghi lại từ catalog của IndicatorDELib.mqh mỗi lần OnInit, các class khác cần thì đọc thẳng bảng này. Python chỉ đọc, nối với Setting_IndicatorTemplate qua type_enum.
  - Table in DB: Setting_IndicatorTemplate
      - Class in Library: CIndicatorTemplateManager đọc cả bảng mỗi dòng là một setting cho indicator tương ứng. 
  - Table in DB: timeframes: Liệt kê tất cả các TF có trong dữ liệu MT5, nó không tương ứng với Class nào trong Library.
      - Class in Library: CIndicatorTemplateManager phụ trách rà soát update bảng này trong OnInit.


    - Table in DB: Setting_PythonBridge đổi nghĩa: 
       + pid là tiến trình cha giữ chỗ, 0 là không ai. 
       + EA xoá khi đóng, Python chiếm lúc khởi động bằng cập nhật có điều kiện.
    - Table in DB: Setting_Sync dùng để mark lại database đã được sync đến đâu.
      - Trong Oninit Python sẽ update các table và mark lại DB đã sync từ đâu đến đâu.
      - Trong Live EA và các Class trong Library sẽ sẽ tiếp tục sync theo nhiệm vụ được phân định bởi CSymbolTFManager.
      - Python sẽ update phần còn lại không có trong CSymbolTFManager
      - Cả 2 bên sẽ chủ động update Setting_Sync đánh dấu đã sync đến đâu cho các dữ liệu: BarSeriesDE, BarTimeSeriesCollection,SignalsCollection
    - Table in DB: Setting_BarInformation / Setting_BarSetup
      - Class in Library: CBarInformationManager phụ trách update (cả hai bảng) như controller.
        - Setting_BarInformation: một dòng cho mỗi loại thông tin của bar (type_infor): có/hiện tín hiệu buy, sell.
        - Setting_BarSetup: một dòng cho mỗi tham số của một loại (type_infor, param).
        - Define in BarDefines.mqh
        Trong Oninit nếu chưa thấy thì sẽ tạo bảng với giá trị mặc định (cờ mặc định true) và parameter mặc định.
       
    
    - Table in DB: symbols / symbol_base: cùng là XAUUSD tuy nhiên các Account khác nhau lại có symbol là XAUUSD,XAUUSDm,XAUUSDc.
      - symbols: symbol của chính từng Account (account_key, name = XAUUSDm, symbol_id), cũng là bảng map sang symbol_base (không còn symbol_account).
      - symbol_base: các Symbol duy nhất (id, name = XAUUSD); symbol_id ở mọi bảng khác (Setting_SymbolTF, Setting_Sync, Account DB) là id của bảng này.
      - Class in Library: CSymbol (một dòng) / CSymbolsCollection (cả bảng symbols, và thêm tên bỏ hậu tố vào symbol_base khi chưa có).
        Chỉ map tay khi broker đặt tên khác hẳn (GOLD cho XAUUSD); dòng đã có trong symbols không bao giờ bị ghi đè.
    - Table in DB: Setting_SymbolTF
      - Class in Library: CSymbolTFManager (cả bảng, ghi thẳng DB, không có class một dòng)   
          
 * Account DB: Lưu dữ liệu riêng cho từng tài khoản.
    - Table in DB: BarSeriesDE (đang tạm bỏ), BarTimeSeriesCollection,SignalsCollection
      Class tương ứng trong DB: CBarSeriesDE, CBarTimeSeriesCollection, CSignalsCollection     
    - Table in DB: Orders
      - Class in Library: COrder,CMarketCollection,CHistoryCollection. 
      - Control in Library: COrderControl.
      [] Để tính fee thì có thể suy ra từ CBar BAR_PROP_SPREAD
    +Table in DB: TradeEvent(một dòng)/CTradeEventsCollection(cả bảng)
 * Giữa 2 Database không có khoá ngoại và không JOIN bằng SQL: EA (Controller) đọc cả 2 file rồi ghép.
 * RAM và DB (Sync Everywhere): 
  - RAM dùng để tính hiện tại. Cái gì chỉ ở RAM thì ghi rõ ở đây. 
    + Position, pending order đang mở: CMarketCollection (m_list_all_orders), không ghi xuống Orders.
    + CSymbol, CTradeObj: thuộc tính lấy từ terminal (CSymbolsCollection giữ list theo symbols).
    + Manager cũng là collection: m_list các object setting (CSymbolTFSetting, CIndicatorSetting, CBarInformationSetting) đọc DB một lần trong OnInit (SyncDataFromDB), sau đó chỉ đọc RAM;
      thay đổi (AddToDB / RemoveFromDB / cờ) thì sửa m_list, ghi DB ngay (Python đọc) rồi gửi event.
    + Pending request (CPendRequest*) của CTradingControl: hàng đợi gửi lại lệnh, không ghi DB.
    + Account: các giá trị đổi theo tick (balance, equity, margin...) chỉ ở RAM; bảng accounts chỉ giữ thuộc tính tĩnh.
    + Tick: không có tick series (DOM, treo EA), chỉ CNewTickObj báo PAUSE / RESUME.    
- Reference Rule: Các Reference link được note trong Reference/yyyymmđ Reference.md
- Planing task
 [] Integrating AI
    - articles/22526
 [] LiquLiquidity Sweep 22140
 [] Francis Nyoike Thumbi: Born -> Live -> Dead 
  - Stanley Kimathi Kibaara: 23049: Market Structure Framework 
 [] Working Task
   -       
 [] Riskmanagement 
    + RiskManagementDefine.mqh
        ENUM_RISK_MODE
    + RiskManagementSetting.mqh đang là bản cũ
    + RiskManagementSettingManager.mqh 
