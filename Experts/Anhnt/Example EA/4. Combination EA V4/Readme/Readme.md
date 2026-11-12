- Các nguyên tắc chung được note detail trong CommonRule.md
- Communication Rule: Trao đổi bằng tiếng việt nhưng tránh Confuse mất công làm gì làm lại.
- Nguyên tắc xuyên suốt là:
  - CleanArchitecture
  - MVC (Model-View-Controller)     
  - No Duplicate Everywhere.
  - Sync Everywhere: 
  - Event Rule: Từ V4 trở đi, Chúng ta làm việc theo Event ->Automatic Trade
     + Việc tổ chức trong Event sẽ cần tối ưu để có thể gửi đủ các tham số tránh phải hỏi lại see CBaseObjExt::CheckEvents.
     + Cùng là 1 Event nhưng khi SendEvent thì các class tuân thủ Parent Child Structure rule phía dưới.
  - Live working in RAM, Load on demand Save on DB for no more calculation
  - Calculation Rule.
    + Một số công việc mang tính nhỏ nhẹ thì EA và Library làm một mình.
    + Các công việc tính toán lớn Python làm.
    + Cả EA và Python cùng biết cách tính như nhau và cùng lưu vào Database.    
    + Cùng một việc ma 2 bên thay phiên nhau làm theo sự phân công như tính toán dựa trên các Setting_xxxManager thì cả 2 bên cùng phải biết cách tính và thông báo cho nhau khi EA + Libary chuyển việc tính này sang Python.
  - Database rule: 
    + Database đóng vai trò M trong mô hình MVC.
    + Việc CRUD các table này đa phần do các class Manager và được note rõ ở đầu mỗi file.
    + Chúng ta có 2 Database: Common và Accounts note detail
      - Common Database chứa các dữ liệu chung cho tất cả các tài khoản.Setting_*, accounts, symbol_base, symbols, timeframes, indicators
      - Accounts Database chứa dữ liệu riêng cho từng tài khoản vì Cùng là XAUUSD tuy nhiên các Account khác nhau lại có symbol là XAUUSD,XAUUSDm,XAUUSDc, cái này được lưu ở symbols
      - 2 Database không có khoá ngoại nên cả EA và Libary cũng như Python sẽ phải tự Join các bảng khi cần thiết.Việc join dựa trên m_account_key trong CDatabaseService.       
    + Oninit EA, và các class manager trong Library đóng vai trò Controller trong mô hình MVC sẽ Oninit, khởi tạo DB và các Setting_xxx tương ứng với giá trị mặc định.
     - Có một Current Python worker luôn tính ngay khẩn trương dữ liệu hiện tại theo thứ tự ưu tiên
      1. Dữ liệu trên tương ứng với Symbol + TF trên Chart. 
      2. Dữ liệu còn lại trong Setting_SymbolTF.
      3. Dữ liệu hiện tại trong các symbol + tf khác.
      4. Update Setting_Sync để đánh dáu các checkpoint.
    + Sau Oninit: 
      1. Mỗi class trong Library đóng vai trò controller quản lý table riêng trong đó.
      2. Library đọc dữ liệu đã có và nạp vào RAM để Marker, Candle Info và các View khác truy xuất nhanh.
      3 Python đọc các bảng setting và ghi dữ liệu vào bảng tương ứng theo configuration từ phía EA    
      4. Python và EA sẽ cùng Update Incremental vào Database, và mark lại việc update đến đâu vào table Setting_Sync này theo nguyên tắc:     
      5. Phân giao nhiệm vụ giữa Python và EA dựa trên Calculation Rule và table Setting_SymbolTF.      
       - EA, Library update phần tiếp theo trong Setting_SymbolTF.
       - Có một Live Python worker tính dữ liệu từ thời điểm Current Python worker tính xong trở về sau.
       - Có nhiều History Python worker tính dữ liệu từ thời điểm Current Python worker tính xong trở về trước. Số lượng tùy theo symbol và History Python worker tính với từng symbol và từng TF. Tính xong thì nghỉ giải lao rồi sang hỗ trợ tay History Python worker khác tính tính tiếp với các cặp còn lại.
      - Khi Market watch thêm Symbol, setting thay đổi mô hình Current Python, History Python và Live Python worker khơi động lại.
    + Thứ tự ưu tiêu khi ghi vào database là
     1. EA và các class trong library.
     2. Live Python worker.
     3. Current Python Worker khi Setting change.
     4. History Python worker.
    + Prepare để train cho các mô hình Pridict như XGBoot, Kronos.
    + Prepare để Back Test Strategy.  
  - Python note được ghi trong Python.md: mỗi Job khai context (số nến cần phía trước) và right (số nến cần phía sau). Ai tính đoạn [từ .. tới] thì đọc [từ - context .. tới + right] nhưng chỉ ghi kết quả trong đoạn của mình. Không ai tính lại cả 20000 nến khi chỉ có vài nến mới.
  - Parent Child Structure rule: Mỗi cha có nhiều con, sẽ chủ động quản lý các con này, các con có thể tự nghe Event và tự giải quyết việc của mình, sau đó nếu cần sẽ send Custom Event, các anh chị em cùng cha có thể cùng nghe Event để xử lý không phải nhắc.
    + Ví dụ: EA -> m_GUIPannel (CGUIPannel) -> m_window_main (CWindow) -> m_status_bar (CStatusBar), m_menu_bar (CMenuBar).
      EA chỉ chuyển ChartEvent xuống m_GUIPannel, CGUIPannel::OnChartEvent chuyển tiếp cho từng con (this.Child(i).OnChartEvent), mỗi con tự xử lý phần của mình.
      Cha tạo con bằng AddChild(), con gửi Custom Event khi cần (ví dụ CLICK_EVENT_COMBOBOX_ITEM), cha và các anh chị em cùng nghe. 
- Document Rule: Việc Refactor là không tránh khỏi tuy nhiên cần có document để nhắc nhau tránh lặp lại lỗi cũ đi lạc.    
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
