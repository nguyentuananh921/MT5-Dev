 1. Working Rule:
 [] Trao đổi bằng tiếng Việt tuy nhiên cần dùng thẳng các thuật ngữ tránh confuse
   - Ví dụ: Thay vì dịch cái hộp thì là dịch cái CZone, CGCGStdRectangleObj thậm chí có cả tên cụ thể m_Rectangle_TakeProfit  
 [] Cấu trúc file: MỖI CLASS MỘT FILE (.mqh) có include guard đầy đủ cả declaration và implementation, không viết kiểu một file chứa nhiều class.
 [] Trao dổi về LOGIC code của tác giả khác (Francis Nyoike Thumbi, Stanley Kimathi Kibaara và bất kỳ ai sau này). Chúng ta lấy concept, rồi áp dụng và sửa EA V3 và Lib V3 cho phù hợp. 
  - Các lỗi trong logic của họ chỉ ghi rõ trao đổi lại để khắc phục
  - Phần comment link reference ở đầu file để tránh đọc hiểu sai concept thì sửa lại còn các comment khác không ảnh hưởng đến code.
 [] Comment trong code bằng tiếng Anh.
 [] Print Debug: Để tiện cho việc xóa Print Debug đi thì
   - Print debug ra file lấy tên file là tên class kèm Debug_<which>   
   - ::Print("MY DEBUG    CClassName::MethodName .....=", ....);
   - Print Debug cần được căn lề để khi fold cho tiện theo format 
    //Print Debug
      ->Căn lề từ đây.
    Tức là khi Print Debug phải có class và Method để còn lựa mà xóa đi.
   - Các phần code khác cũng căn lề để fold dễ dàng.
  -Khi EA lớn lên thì print debug thẳng ra file với tên file là tên class
 [] Log có sẵn trong workspace
 [] Code rule
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
  - Property (biến thành viên) cũng thế, không thêm cái thừa
    + Dữ liệu đã có nguồn thì hỏi nguồn đó, không giữ bản sao. Ví dụ: Symbol() của chart, CSymbolTFManager (danh sách TF), table.Model().RowsTotal() và Cell().ValueS() (bảng đang hiện gì).
    + View (GUI, table) không tự dò Model rồi nhớ lại, cũng không đọc theo timer: Controller (EA, PythonBridge) báo bằng Event, View chỉ hiển thị và cập nhật bằng SetValue.
    + Trước khi thêm Property hay Method mới: đọc README, tìm cái đã có, và nói được vì sao cái có sẵn không dùng được.
   //+-------------------------------------------------------------------------+  
   //|                                                                         |
   //+-------------------------------------------------------------------------+  
2. Version Update
 - Từ bản V3: LibLibrary là "4. Combination Lib V3, EA là "4. Combination EA V3";
  + Mọi tính toán được chuyển sang dùng Python, python đóng vai trò M trong mô hình MVC.
  + EA, GUI, ChartObj hoạt động như View + Control trong mô hình MVC.
  + Python tính hết Symbol của CSymbolsCollection trên mọi TF (nạp nền), EA hiển thị theo CSymbolTFManager. Python không nạp theo yêu cầu.
  + Python chỉ làm việc khi có EA kết nối: không có EA thì chỉ nghe cổng (không cập nhật nến, không nạp nền, không ghi cache). 
    Chỉ tắt khi EA cuối cùng gửi quit (gỡ EA), đổi TF hay gắn lại EA thì Python vẫn sống.
  + Cache đĩa: MQL5\Files\EA LibV3\Python Cache (xóa thư mục để reset). Tự bỏ khi đổi tham số tính toán hoặc sửa swing/structure/indicators/signals/patterns.py.
3. EA gồm có 
 - Configuration: Live config thay đổi runtime được trong Configuration
   + Từ V3 thì Configuration đã đổi sang làm Input trong EA để tránh phải vẽ GUI.
   + JSONConfig : save cấu hình giờ thì chỉ lưu
     - IndicatorSetting.mqh tương ứng với IndicatorTemplateManager.mqh
     - SymbolTFSetting.mqh tương ứng với SymbolTFManager.mqh
     - CPatternSetting.mqh tương ứng với CPatternManager.mqh
   + TradingSetupSetting.mqh tương ứng với TradingSetupSettingManager.mqh    
   + SwingSetting.mqh (Swing), StructureSetting.mqh (BOS, CHoCH)
  //-Temporaty stop here note below for me
  Confuse
   - Nhiêu collection inherit từ CObject như: Indicators, History, Market
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