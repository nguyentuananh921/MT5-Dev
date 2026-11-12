- Các nguyên tắc chung được note detail trong CommonRule.md
- Communication Rule: Trao đổi bằng tiếng việt nhưng tránh Confuse mất công làm gì làm lại tuy nhiên cần dùng thẳng các thuật ngữ tránh confuse
  + Ví dụ: 
     * Thay cái hộp thì là CZone, CGCGStdRectangleObj thậm chí có cả tên cụ thể m_Rectangle_TakeProfit. 
     * Thay vì vị thế thì là Position
- Nguyên tắc xuyên suốt là:
  + CleanArchitecture
  + MVC (Model-View-Controller)     
  + No Duplicate Everywhere.
  + Sync Everywhere: Khi thay đổi ở một chỗ có thể kéo theo phải thay đổi ở chỗ khác.
    * Ví dụ: Cách tính ở EA + Library thay đổi thì Python thay đổi theo.
  + Event Rule: Từ V4 trở đi, Chúng ta làm việc theo Event ->Automatic Trade
     * Việc tổ chức trong Event sẽ cần tối ưu để có thể gửi đủ các tham số tránh phải hỏi lại see CBaseObjExt::CheckEvents.
     * Cùng là 1 Event nhưng khi SendEvent thì các class tuân thủ Parent Child Structure rule phía dưới.
  + Live working in RAM, Load on demand, Save Calculation on DB là việc của Python. 
  + Calculation Rule. EA + Library side chỉ tính y hệt Python for Live Working on RAM. Việc Save Setting là của EA + Library, Python chỉ đọc Setting và tính lại khi cần
- Database rule: 
  + Database đóng vai trò M trong mô hình MVC.
  + Việc Create các table này đa phần do các class Manager và được note rõ ở đầu mỗi file.
  + Save Setting là của phía EA + Library
  + Chúng ta có 2 Database: Common và Accounts note detail
    * Common Database chứa các dữ liệu chung cho tất cả các tài khoản.Setting_*, accounts, symbol_base, symbols, timeframes, indicators
    * Accounts Database chứa dữ liệu riêng cho từng tài khoản vì Cùng là XAUUSD tuy nhiên các Account khác nhau lại có symbol là XAUUSD,XAUUSDm,XAUUSDc, cái này được lưu ở symbols
    * 2 Database không có khoá ngoại nên cả EA và Libary cũng như Python sẽ phải tự Join các bảng khi cần thiết.Việc join dựa trên m_account_key trong CDatabaseService.       
  + Oninit EA, và các class manager trong Library đóng vai trò Controller trong mô hình MVC sẽ Oninit, khởi tạo DB và các Setting_xxx tương ứng với giá trị mặc định. Có một Current Python worker luôn Calculate theo Priority
    1. Dữ liệu trên tương ứng với Symbol + TF trên Chart. 
    2. Dữ liệu còn lại trong Setting_SymbolTF.
    3. Dữ liệu hiện tại trong các symbol + tf khác.
    4. Update Setting_Sync để đánh dáu các checkpoint.
  + Sau Oninit: 
    * Mỗi class trong Library đóng vai trò controller quản lý table riêng trong đó.
    * Library đọc dữ liệu đã có và nạp vào RAM để Marker, Candle Info và các View khác truy xuất nhanh.
    * Live Python tính toán dữ liệu từ Current Python worker trở đi. 
    * History Python sẽ update DB tính dữ liệu từ thời điểm Current Python worker tính xong trở về trước. 
    * Số lượng tùy theo symbol và History Python worker tính với từng symbol và từng TF. Tính xong thì nghỉ giải lao rồi sang hỗ trợ tay History Python worker khác tính tính tiếp với các cặp còn lại.
    * Khi có thay đổi setting phía EA python sẽ tính lại
     ví dụ: 
      - Market watch thêm Symbol
      - setting thay đổi mô hình Current Python, History Python và Live Python worker khơi động lại.
  + Thứ tự ưu tiêu khi ghi vào database là     
    1. Live Python worker.
    2. Current Python Worker khi Setting change.
    3. History Python worker.
- Prepare để train cho các mô hình Pridict như XGBoot, Kronos.
- Prepare để Back Test Strategy. 
- Parent Child Structure rule: Mỗi cha có nhiều con, sẽ chủ động quản lý các con    này, các con có thể tự nghe Event và tự giải quyết việc của mình, sau đó nếu cần sẽ send Custom Event, các anh chị em cùng cha có thể cùng nghe Event để xử lý không phải nhắc.
  + Ví dụ: EA -> m_GUIPannel (CGUIPannel) -> m_window_main (CWindow) -> m_status_bar (CStatusBar), m_menu_bar (CMenuBar).
  EA chỉ chuyển ChartEvent xuống m_GUIPannel, CGUIPannel::OnChartEvent chuyển tiếp cho từng con (this.Child(i).OnChartEvent), mỗi con tự xử lý phần của mình.
  Cha tạo con bằng AddChild(), con gửi Custom Event khi cần (ví dụ CLICK_EVENT_COMBOBOX_ITEM), cha và các anh chị em cùng nghe. 
- Document Rule: Việc Refactor là không tránh khỏi tuy nhiên cần có document để nhắc nhau tránh lặp lại lỗi cũ đi lạc.
  + Python note được ghi trong Python.md: mỗi Job khai context (số nến cần phía trước) và right (số nến cần phía sau). Ai tính đoạn [từ .. tới] thì đọc [từ - context .. tới + right] nhưng chỉ ghi kết quả trong đoạn của mình. Không ai tính lại cả 20000 nến khi chỉ có vài nến mới.    
- Update được note trong Update/Update.md
- Update & Implementation Rule: 
  + Mỗi lần Update và Implementation, chúng ta sẽ rà soát lại để đảm bảo các rule ở trên. 
  + Điều này sẽ khiến quá trình Update và Implementation chậm hơn nhưng về lâu dài sẽ hiệu quả.  
  + Cách update là tạo dần các file trống rồi copy sang file mới. Tránh copy cả mớ gây duplicate code,enum, properties.
  + Cách rà soát: Là comment out cái method hiện tại và để compiler phát hiện các call site.
  + Ngoài ra thì cần nhìn tổng thể trước khi update & implementation và chủ động modify các thứ khác: class, module, database cho phù hợp với nguyên tắc chung.  
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
