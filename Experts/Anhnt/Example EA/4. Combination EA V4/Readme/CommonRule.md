- Trao đổi bằng tiếng Việt tuy nhiên cần dùng thẳng các thuật ngữ tránh confuse
  - Ví dụ: Thay vì dịch cái hộp thì là dịch cái CZone, CGCGStdRectangleObj thậm chí có cả tên cụ thể m_Rectangle_TakeProfit.  
- Coding rule
  - Folding rule: code cần được căn lề chuẩn để fold dễ dàng.
  - Comment trong code bằng tiếng Anh. Hãy comment ngắn gọn, súc tích đúng trọng tâm.
    Thống nhất lại format của Comment ở mỗi đầu hàm theo format: Dài hơn thì bổ xung miễn là ngắn gọn. 
     //+-------------------------------------------------------------------------+  
     //|                                                                         |
     //+-------------------------------------------------------------------------+
  - Debug rule: Để tiện cho việc xóa Print Debug đi thì
    + Print debug trong code: ::Print("MY DEBUG    CClassName::MethodName .....=", ....);
    + Print Debug ra file thì phải có class và Method và location là thư mục Debug trong EA
    + Print debug ra file lấy tên file là tên class kèm Debug_<which> 
  - Log có sẵn trong workspace      
  - Cấu trúc file: 
    + MỖI CLASS MỘT FILE (.mqh) có include guard đầy đủ cả declaration và implementation.
    + Tránh viết inline method.
- No Duplicate Everywhere detail
  - Enum và Define: 
    - Hạn chế dùng number thay vì đó dùng Enum ví dụ thay vì 1 hay 2 nữa mà thay vì thế trong code mình sẽ phải là PRICE_CLOSE và PRICE_OPEN.
    - Ưu tiên Enum của MT5. 
    - Các Enum hoặc define dùng nhiều nơi sẽ được khai báo tại CommonDefines.   
    - Các Enum và define dùng riêng cho class nào thì khai báo trong class đó
  - Properties 
    - Properties trong class: Tên của các Properties sẽ dựa trên class thống nhất giữa các layer
      + CTimeSeriesEngine CBarTimeSeriesCollection  -> m_BarTimeSeriesCollection;
      + CGUIPannel        CWindow                   -> m_window_main;
      + Nếu Properties là pointer thì comment rõ ngay cạnh là class nào hold nó.
    - Properties trong table cũng cần lấy cho đồng bộ với properties trong class hoặc gợi nhớ tới nhau.
      + List là bản sao trên RAM của một table thì mang tên table đó (Sync Everywhere: nhìn tên biết maintain table nào):
        m_list_Table_<Table> (bản sao), m_list_Pending_<Table> (CHỈ RAM, phần chưa ghi). Ví dụ CBarSeriesDE: m_list_Table_BarSeriesDE; CBarControl: m_list_Table_BarTimeSeriesCollection,
        m_list_Pending_BarTimeSeriesCollection.
      + List chỉ chứa đối tượng con (không phải bản sao table) thì mang tên theo con: m_list_timeseries (CBarTimeSeriesDE), m_list_series (CBarSeriesDE).
    - Các Properties trong declaration sẽ được declared theo nguyên tắc cha con tuân thủ folding rule trong Coding Rule.
  - Python (Lib V4\Python) tuân thủ CÙNG các rule này (No Duplicate, Sync Everywhere, đặt tên theo table / class, Update & Implementation Rule): đổi ở phía MQL thì rà
    phía Python cùng lúc và ngược lại. Chi tiết và danh sách tên cần rà: Python.md, mục "Quy tắc chung".
  - Method: Các method modify dữ liệu (Model) cần thống nhất giữa Controler ở đây là EA và Python.
    - Tận dụng triệt đê method trong library tránh thêm các method không cần thiết.
     + Các method dùng chung được khai trong Services\DebLib theo các tên khác nhau tùy phạm vi sử dụng.
     + Các method riêng cho từng class thì khai trong class đó.   
    - Các method và được đặt tên theo nguyên tắc <Action><Which>_<Which>
     + Create: Create<Which>_<Which> 
       - CreateTable_IndicatorTemplateSetting()       
       - CreateTable_SymbolTFSetting()    
     + Update lần đầu InitializeTabble>_<Which>,
       - PopulateTable_IndicatorTemplateSetting()  
       - UpdateWindowCaption_MainWindow(), UpdateStatusBar_SymbolSpread()  
     + Modify số lượng nhỏ   AddRow_<Which>,DeleteRow_<Which>,HighLightRow_<Which>, UpdateRow_<Which>
     + Hành vi sửa hàng loạt:   SyncTable_<Which>,
    - Đặt tên method trong Library (chốt 2026 1030; <Which>_<Which> ở trên là cho EA module):
     + R1. Method có sẵn ở DoEasy / V1 / V2 giữ tên gốc: RefreshSeries, SyncDataFromDB, SetProperty, Time().
     + R2. Method của class: <Action><Which>, KHÔNG có hậu tố tên class (biến gọi đã cho biết class: CBar *bar=...; bar.TopBody()).
       _<Which> chỉ dùng khi một class có nhiều phần cùng làm một Action, như CGUIPannel: OnEvent_Tab_Candle.
     + R3. Họ method theo type (một method cho mỗi BAR_INFOR_TYPE_*): Find<Type> (FindHammer, FindSwingHigh), bộ chọn theo type: Find(type,index).
     + R4. Hàm global (ngoài class) giữ tiền tố vì không có biến nào cho biết nó thuộc đâu: LibDatabase_InList, các hàm trong Services\DELib.
     + R5. Cùng tên ở cha và con (kế thừa hay chứa nhau) là cùng một việc, cha làm phần mình rồi chuyển xuống con:
       CBarTimeSeriesCollection::SyncDataFromDB -> CBarTimeSeriesDE::SyncDataFromDB -> CBarSeriesDE::SyncDataFromDB -> CBarControl::SyncDataFromDB.
     + R6. Python đối chiếu: module tương ứng class (patterns.py ~ CBarPattern, swing.py ~ CBarSwing), hàm tương ứng Which (hammer, find_swings).
     + Áp dụng dần: class nào động tới thì đổi tên theo R2 / R3 (tên cũ *_BarControl, *_BarSeriesDE... đổi khi sửa file đó).
  - Module rule:Chương trình được module hóa theo nguyên tắc chung như class CGUIPannel   
     + GUIPannel_Define.mqh    -> định nghĩa các Enum, Macro.
     + GUIPannel.mqh           -> chứa các declaration hạn chế viết inline (trừ method ngắn gọn return giá trị trực tiếp) 
     + GUIPannel_Lifecycle     -> chứa các method xử lý logic, OnInit, OnDeinit, OnTick, OnChartEvent, OnTimer
     + GUIPannel_MainWindows   -> chứa các method xử lý logic, của cửa sổ MainWindows và các control bên trong nó
       * Tức là tên module sẽ gợi nhớ việc xử lý các control trong m_window_main
       * Method xử lý các Event sẽ được gom luôn trong module đó ->CGUIPannel::OnEvent_Window_AddIndicator   
- Reference Rule detail: 
  - Chúng ta sẽ Implemenation các concept, feature, library của nhiều tác giả vào EA.
  - Chúng ta không sửa code của reference EA, chúng ta chỉ trao đổi để implement concept vào EA hoặc refactor code của EA để tận dụng được logic trong Reference EA.
  - Để tránh đọc nhầm hiểu nhầm thì các file reference sẽ được lưu tại thư mục Reference và các reference EA, Lib cũng tuân thủ nguyên tắc này.
  - Các Reference sẽ được đặt tên theo cách: Series,Name,Author
  - Khi implementation một reference mới vào EA: 
    + Reference code sẽ được add vào workspace.
    + Reference file trong folder sẽ được tạo.
    + Concept nào mới sẽ được note ngắn gọn về việc reference.
    + Concept cũ kể từ V4 cần thì sẽ phải rà lại và các reference khi rà soát sẽ được note lại trong thư mục Reference.
  
     