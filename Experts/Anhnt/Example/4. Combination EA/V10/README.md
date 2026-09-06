 - Hồ sơ bug chi tiết + luật xương máu: BugNote.md.
 1. Working Rule:
 [] Trao đổi bằng tiếng Việt, Comment trong code bằng tiếng Anh. 
 [] Print Debug: Để tiện cho việc xóa Print Debug đi thì
   - Print debug ra file lấy tên file là tên class kèm Debug_<which>   
   - ::Print("MY DEBUG    CGUIPannel::LineRepresentsIndicator .....=", ....);
   - Print Debug cần được căn lề để khi fold cho tiện theo format 
    //Print Debug
      ->Căn lề từ đây.
    Tức là khi Print Debug phải có class và Method để còn lựa mà xóa đi.
  -Khi EA lớn lên thì print debug thẳng ra file với tên file là class và dong
 [] Hạn chế dùng number thay vì đó dùng Enum ví dụ thay vì 1 hay 2 nữa mà thay vì thế trong code mình sẽ phải là PRICE_CLOSE và PRICE_OPEN
 [] Log có sẵn trong workspace
 [] Tên của các Properties sẽ dựa trên class thống nhất giữa các layer và class ví dụ
  - CTimeSeriesEngine CBarTimeSeriesCollection  -> m_BarTimeSeriesCollection;
  - CGUIPannel        CWindow                   -> m_window_main;
  - CTradingEngine    CSymbolsCollection        -> m_symbol_collection;
 [] Tên của các method liên quan đến Table và TreeView, SymbolTFSetting,IndicatorTemplateSetting
  -Create: Create<Which>_<Which>
    CreateTable_IndicatorTemplateSetting(),
    CreateTable_SymbolTFSetting()
    CreateTreeView_IndicatorTemplateSetting()
    CreateTreeView_SymbolTFSetting()
  -Update lần đầu InitializeTabble>_<Which>,InitializeTable_IndicatorTemplateSetting()    
  - Modify số lượng nhỏ.
   AddRow_<Which>,DeleteRow_<Which>,HighLightRow_<Which>, UpdateRow_<Which>
  - Hành vi sửa hàng loạt:   SyncTable_<Which>,
 [] Với Table SymbolTFSetting chỉ có 3 method
  - PopulateTable_SymbolTFSetting
  - CreateTable_SymbolTFSetting
  - SyncTable_SymbolTFSetting()  
 [] Với TreeView không tách bạch được việc sửa 1 đơn vị nhỏ và sync hàng loạt nên chỉ có 3 method cần đặt theo thứ tự
   - PopulateTreeView chuẩn bị data
   - CreateTreeView
   - SyncTreeView dựa trên cờ cần sync hay không
   
 [] Biến Pointer sẽ phải trùng tên và note rõ class nào hold nó ví dụ
  - CSymbolsCollection         *m_symbol_collection; //CTradingEngine owns
 [] Tận dụng triệt đê method
   - Ưu tiên method của Library thay vì Buildin.
   - Tránh trùng lặp giữa các method cùng function chỉ khác name
 [] Tránh thêm các Method,Properties không cần trong khi Library có sẵn. 
   - Cụ thể: Library đã có PrintParameters mà vẫn muốn thêm trong Deblib
 [] Mọi thay đổi trong Library cần trao đổi thống nhất làm rõ. Và ko tự thay đổi.
 [] Mọi sự thay đổi trong code cần trao đổi trước.
 [] Hạn chế tối đa Flicker ở Layer 2.
 [] Hạn chế viết method Inline, chỉ các method return ngắn gọn,mới dùng inline.
 [] Hạn chế thêm Method thay vì sửa method cũ khiến cho việc dọn dẹp khó khăn.
  -Thay vì thêm thì sửa method cũ hoặc đổi tên Method cũ.
 [] Thống nhất lại format của Comment ở mỗi đầu hàm theo format
   //+-------------------------------------------------------------------------+  
   //|                                                                         |
   //+-------------------------------------------------------------------------+  
2. Version Update
 [v] Từ bản V8 thì Layer 2 được tách biệt việc implemenation ra các module khác nhau theo nguyên tắc chức năng của các GUI Control theo Tab
 [v] Từ bản V9 thì CGUIPannel trực tiếp làm việc với JSONConfig.
 [] V10 đang Update Struct thành Class và rất nhiều phần khác trong EA, CGUIPanel đang được tạm remove để rà soát trong lúc chỉ tập trung việc Synindicator giữa các Layer. 
3. Feature
 [x] Candle Pattern ->Chỉ tính hình dạng nến chưa tính đến Trend
   -PATTERN_TYPE_THREE_STARS
   -PATTERN_TYPE_ABANDONED_BABY 
 [v] CTreeView  m_treeview_SymbolTF;
    [v] Display Symbol + TF 
    [v] Highlight node base on Current Chart on Layer 3
    [v] Add CBarSeriesDE on Layer 1: OnEvent click on Node
 [v] CTreeView  m_treeview_indicator;
    [v] Display and Highlight Indicator, có thể có nhiều Indicator PSAR chẳng hạn khác nhua ở Parameter
 [v] CTable Indicator-Template-Table
    m_table_indicator_template; danh sách các Indicator có trong template nó có thể nhiều hơn ở Layer 3 vì đơn giản có checkbox để điều khiển việc show/hide
      - Việc Toggle các check box sẽ mirror từ layer 2 -> Layer 3.  
 [v] CTable     m_table_indicator_SymbolTFValue;
 [] SynIndicator-Template giữa các layer
  - Layer 1: Hoàn toàn không tự thay đổi gì.
    CTimeSeriesEngine hold CBarTimeSeriesCollection và sẽ phải tạo các CBarTimeSeriesDE tương ứng với Symbol + TF
    CTimeSeriesEngine hold CIndicatorsCollection m_IndicatorsCollection và m_IndicatorsCollection sẽ phải đồng bộ với Indicator template để với mỗi 
  - Layer 2: CGUIPannel.
     AddIndicatorOnForm.
     DelteIndicatorFromTable
  - Layer3: CChartObjCollection
   - Scan Indicator on Chart on Init
   - Add Indicator ->User Manual Add Indicator
   - Modify Indicator on Chart ->Có thê thay đổi Parameter còn thay đổi Style các Layer không phải làm gì. 
  [] Trading
   Buy -> Khi khớp khớp với Bid tính Profit với Bid
   Sell -> Khi khớp khốp với Ask tính Profit với Ask
    Symbol
    SYMBOL_BID (ở dưới) /SYMBOL_ASK (ở trên)
    SYMBOL_POINT -> Đơn vị thống nhất giữa các Symbol vàng là 130 point
    SYMBOL_DIGITS
    SYMBOL_TRADE_STOPS_LEVEL ->KHoảng cách tối thiểu với giá toàn bằng 0
    SYMBOL_TRADE_TICK_VALUE-> Bước nhẩy nhỏ nhất của giá.  
    SYMBOL_VOLUME_MIN/MAX/STEP
    SYMBOL_TRADE_MODE
    SYMBOL_FILLING_MODE
    SYMBOL_TRADE_FREEZE_LEVEL
   Setting SL: Việc setting SL sẽ phải theo Symbol. Và Setting cái StopLost Distance so với giá theo đơn vị point.
    Có 2 cách set SL được thực hiện bởi CButtonsGroup
    Fixed/ATR (Distance-based): chọn Distance (point) trước → SL = giá_tham_chiếu ∓ Distance × Point.
   Trailling: MA/PSAR (Level-based, offset nhỏ): lấy indicator_value làm gốc → SL = indicator_value ∓ Offset × Point.
    

4. EA gồm có 
 [] Layer 1:PureData Sử dụng Library của Artyom Trishkin
   - Library link Lib https://www.mql5.com/en/articles/14710
   - Trong workspace là thư mục 
   []: CTimeSeriesEngine
   []: CTradingEngine   
   -Cả 2 vốn tách từ CEngine
   PureData Có 2 thứ để Config Indicator và Symbol-Tf  
  = IndicatorSetting.mqh
  - IndicatorTemplateManager.mqh
  - SymbolTFSetting.mqh
  - SymbolTFManager.mqh
   [] CIndicatorSetting: dùng để Seting cho mỗi indicator có trong CIndicatorTemplateManager
   [] CIndicatorTemplateManager: dùng để Setting cho một template. Khái niệm template có trên Chart, có trên Table, Indicator TreeView của CGUIPannel, và List các Indicator có trong một symbol + tf
   [] CIndicatorTemplateManager sẽ bắn Event để các component khác tự bắt Event và xử lý.   
  [] Layer 2: CGUIPannel dùng Libarary của Anatoli Kazharski
    - Library Link https://www.mql5.com/en/code/19703
    - Chỉ hold pointer các collection,không own gì thuộc PureData.    
  [] Layer 3: Display On Chart bằng việc dùng ChartObjCollection.mqh, control by EA
    [v] Indicator sẽ display bằng Buildin MT5 dc control bởi EA.
    [v] Buy/Sell Signal sẽ được display bằng SignalMarker
    [v] Quản lý Event bởi CChartObjCollection
    [v] Đã rà soát CSubChart trong GUI LIb (không dùng được)
  [] Layer 4: Working with file 
   -JSONConfig.mqh: Chứa các Method dùng ở nhiều Module riêng lẻ khác nhau.
    -Các method dùng riêng trong module nào thì khai đặc thù trong module đó.
     -Cụ thể dùng trong 
      + CIndicatorTemplateManager thì move sang IndicatorTemplateManager.mqh
      + CSymbolTFManager thì move sang SymbolTFManager.mqh
      + Setting Marker->
      + Setting Sound ->
  