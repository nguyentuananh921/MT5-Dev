 1. Working Rule:
 [] Trao đổi bằng tiếng Việt tuy nhiên cần dùng thẳng các thuật ngữ tránh confuse
   - Ví dụ: Thay vì dịch cái hộp thì là dịch cái CZone, CGCGStdRectangleObj thậm chí có cả tên cụ thể m_Rectangle_TakeProfit  
 [] Cấu trúc file: MỖI CLASS MỘT FILE (.mqh) có include guard đầy đủ cả declaration và implementation, không viết kiểu một file chứa nhiều class.
 [] Trao dổi về LOGIC code của tác giả khác (Francis Nyoike Thumbi, Stanley Kimathi Kibaara và bất kỳ ai sau này). 
  Chúng ta lấy concept, rồi áp dụng và sửa EA V3 và Lib V3 cho phù hợp. 
  - Các lỗi trong logic của họ chỉ ghi rõ trao đổi lại để khắc phục
  - Phần comment link reference ở đầu file để tránh đọc hiểu sai concept thì sửa lại còn các comment khác không ảnh hưởng đến code.  
 [] Log có sẵn trong workspace
 [] Code rule
   - Comment trong code bằng tiếng Anh.
     - Thống nhất lại format của Comment ở mỗi đầu hàm theo format.  
     //+-------------------------------------------------------------------------+  
     //|                                                                         |
     //+-------------------------------------------------------------------------+  
   - Print Debug: Để tiện cho việc xóa Print Debug đi thì
     + Print debug ra file lấy tên file là tên class kèm Debug_<which>   
     + ::Print("MY DEBUG    CClassName::MethodName .....=", ....);
     + Print Debug cần được căn lề để khi fold cho tiện theo format 
      //Print Debug
        ->Căn lề từ đây.
      Tức là khi Print Debug phải có class và Method để còn lựa mà xóa đi.
     + Khi EA lớn lên thì print debug thẳng ra file với tên file là tên class
   - Các phần code khác cũng căn lề để fold dễ dàng.   
   - Hạn chế dùng number thay vì đó dùng Enum ví dụ thay vì 1 hay 2 nữa mà thay vì thế trong code mình sẽ phải là PRICE_CLOSE và PRICE_OPEN.
   - No Duplicate Everywhere
      - Không Duplicate enum -> Enum ENUM_OBJECT_DE_TYPE dùng chung sẽ khai trong CommonDefines
      - Không duplicate Properties ->properties là pointer thì comment rõ ngay cạnh là class nào hold nó. 
      - Không dupliacte Method.
      - Không duplicate class
      - Trong DB không duplicate properties  
      - Table Trong DB        -Control trong Library            - Class in Library
        +symbol_account                                         - Không có do có thể có nhiều account thật và symbol 
                                                                  giữa các account là khác nhau
        + Orders                                                - COrder
                                                                - CMarketCollection
                                                                - CHistoryCollection 
        + Symbols                                               - CSymbol  (một dòng) / CSymbolsCollection (cả bảng)
        + Acounts                                               - CAccount (một dòng) / CAccountsCollection (cả bảng)        
        + TradeEvent                                            - CTradeEvent
                                                                - CTradeEventsCollection
        + BarCandleInfor                                        - CBarPattern
                                                                - CPatternSetting
           -Table field:                                        - enum ENUM_PATTERN_STATUS
            -type                                                 {
                                                                    PATTERN_STATUS_JC,  // Candles
                                                                    PATTERN_STATUS_PA,  // Price Action formations
                                                                  };
                                                                  
               
                 
    - Tên của các Properties sẽ dựa trên class thống nhất giữa các layer và class ví dụ.
     + CTimeSeriesEngine CBarTimeSeriesCollection  -> m_BarTimeSeriesCollection;
     + CGUIPannel        CWindow                   -> m_window_main;    
     + Biến Pointer sẽ phải trùng tên và note rõ class nào hold nó ví dụ
     + Property (biến thành viên) cũng giống với enum không thêm cái thừa, với các     
    - Tên của các method liên quan đến cái gì thì đặt tên cho dễ hiểu
     
     + Ưu tiên method của Library thay vì Buildin.
     + Hạn chế viết method Inline, chỉ các method return ngắn gọn,mới dùng inline.
     + Hạn chế thêm Method thay vì sửa method cũ khiến cho việc dọn dẹp khó khăn.
     + Các method dùng chung giữa nhiều class sẽ thêm ở DebLib và khai báo trong CommonCommonDELib.mqh
     + Tránh trùng lặp giữa các method cùng function chỉ khác name. 
     + Cụ thể: Library đã có PrintParameters mà vẫn muốn thêm trong Deblib 
   - Chương trình được module hóa theo nguyên tắc chung như class CGUIPannel
     + GUIPannel_Define.mqh    -> định nghĩa các Enum, Macro.
     + GUIPannel.mqh           -> chứa các declaration hạn chế viết inline (trừ method ngắn gọn return giá trị trực tiếp) 
     + GUIPannel_Lifecycle     -> chứa các method xử lý logic, OnInit, OnDeinit, OnTick, OnChartEvent, OnTimer
     + GUIPannel_MainWindows   -> chứa các method xử lý logic, của cửa sổ MainWindows
       * Tức là tên module sẽ gợi nhớ việc xử lý các control trong m_window_main
       * Method xử lý các Event sẽ được gom luôn trong module đó ->CGUIPannel::OnEvent_Window_AddIndicator   -  
        
2. Version Update
 - History Upate
   + PureData dựa trên serries của: Artyom Trishkin
     - Last Series: Tables in the MVC Paradigm in MQL5  Last Topic https://www.mql5.com/en/articles/19288
     - Các class nằm trong: 4. Combination Lib V3\Entities\Bases
     - Graphic:             4. Combination Lib V3\Entities\GBases

   + 

 - Từ bản V3: LibLibrary là "4. Combination Lib V3, EA là "4. Combination EA V3";
  + Các tính toán được chuyển sang dùng Python, python đóng vai trò M trong mô hình MVC.
    - Oninit Python sẽ tính toán các thứ cần thiết và nạp dữ liệu vào SQLLite DB. tránh phải tính lại.
    - Khi có Event EA sẽ update SQLLite DB và yêu cầu Python tính lại.    
  + EA, GUI, ChartObj hoạt động như View + Control trong mô hình MVC.
  + Python tính hết Symbol của CSymbolsCollection trên mọi TF (nạp nền), EA hiển thị theo CSymbolTFManager. Python không nạp theo yêu cầu.
  + Python chỉ làm việc khi có EA kết nối: không có EA thì chỉ nghe cổng (không cập nhật nến, không nạp nền, không ghi cache). 
    Chỉ tắt khi EA cuối cùng gửi quit (gỡ EA), đổi TF hay gắn lại EA thì Python vẫn sống.
  + Cache đĩa: MQL5\Files\EA LibV3\Python Cache (xóa thư mục để reset). Tự bỏ khi đổi tham số tính toán hoặc sửa swing/structure/indicators/signals/patterns.py.
3. EA gồm có 
 - Configuration: Live config thay đổi runtime được trong Configuration
   + Input của EA chỉ còn màu sắc và tham số Market State/Phase (EA Configuration.mqh). Show/hide, cách tính, rủi ro đặt ở tab Quick Setting, lưu Config_Setting.json, đọc lúc khởi động, đổi là chạy ngay không Init lại. Danh sách Symbol lưu riêng theo Account.
   + JSONConfig : save cấu hình giờ thì chỉ lưu
     - IndicatorSetting.mqh tương ứng với IndicatorTemplateManager.mqh
     - SymbolTFSetting.mqh tương ứng với SymbolTFManager.mqh
     - CPatternSetting.mqh tương ứng với CPatternManager.mqh
   + RiskManagementSetting.mqh tương ứng với RiskManagementSettingManager.mqh    
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

  [] Working Task
   -Riskmanagement
    + Rà soát lại Library và tổ chức lại ghi ra SQLLite DB thay vì cache từ Python.
    + CBarCTimeSeriesCollection;
    + Reference Series
     Series 1: Building Your Personal Expert Advisor                             
        1. From Fragile Script to Working EA                              
                                  https://www.mql5.com/en/articles/23429 
        2. Risk Management and Dynamic Lot Sizing                         
                                  https://www.mql5.com/en/articles/23638 
        3. Margin and Allowable Risk                                      
                                  https://www.mql5.com/en/articles/23897 
        4. Risk Models and Order Execution                                
                                  https://www.mql5.com/en/articles/21231 
        5. Basket Risk and Strategy-Specific Sizing                       
                                  https://www.mql5.com/en/articles/24331 
        6. Portfolio and Correlated Risk                                  
                                  https://www.mql5.com/en/articles/24392 
        7. Consolidating the Risk Framework                               
                                  https://www.mql5.com/en/articles/24477 
     Series 2: Risk Management      
      Risk Management                                                   
        1. Fundamentals for Building a Risk Management Class              
                                  https://www.mql5.com/en/articles/16820 
        2. Implementing Lot Calculation in a Graphical Interface          
                                  https://www.mql5.com/en/articles/16985 
        3. Building the Main Class for Risk Management                    
                                  https://www.mql5.com/en/articles/17249 
        4. Completing the Key Class Methods                               
                                  https://www.mql5.com/en/articles/17508 
        5. Integrating the Risk Management System into EA                 
                                  https://www.mql5.com/en/articles/17640 
     Series 3:    
       1. Developing a Multi-Timeframe Indicator                         
         https://www.mql5.com/en/articles/21330  
       2. Automating the Strategy with an Expert Advisor                 
         https://www.mql5.com/en/articles/21135  
       3. Defining Structural Validity Beyond Simple Highs/Lows          
         https://www.mql5.com/en/articles/21888  
       4. Dynamic Pullback Depth Using Volatility Models                 
         https://www.mql5.com/en/articles/22807  
        5. Filtering Weak Swings Using Candle Imbalance                   
        https://www.mql5.com/en/articles/23613  
    [] Declare 
      + RiskManagementDefine.mqh
        ENUM_RISK_MODE
      + RiskManagementSetting.mqh đang là bản cũ
      + RiskManagementSettingManager.mqh 
    