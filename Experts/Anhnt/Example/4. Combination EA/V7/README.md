> Hồ sơ bug chi tiết + luật xương máu: BugNote.md.
1. EA gồm có 
 [] Layer 1:PureData Sử dụng Library của Artyom Trishkin
   - Library link Lib https://www.mql5.com/en/articles/14710
   - Trong workspace là thư mục 
   []: CTimeSeriesEngine
   []: CTradingEngine   
   -Cả 2 vốn tách từ CEngine
 [] Graphic
   [] Layer 2: CGUIPannel dùng Libarary của Anatoli Kazharski
    - Library Link https://www.mql5.com/en/code/19703
    - Chỉ hold pointer các collection,không own gì thuộc PureData.
    - Layer 2 sẽ Control việc Show/Hide trên Layer 3
   [] Layer 3: Display On Chart, control by Layer 2 and base on Layer 1
2. Working Rule:
 [] Trao đổi bằng tiếng Việt, Comment trong code bằng tiếng Anh.
 [] Print Debug:   ::Print("MY DEBUG CGUIPannel::LineRepresentsIndicator .....=", ....);
    Tức là khi Print Debug phải có class và Method để còn lựa mà xóa đi.
 [] Hạn chế dùng number thay vì đó dùng Enum ví dụ thay vì 1 hay 2 nữa mà thay vì thế trong code mình sẽ phải là PRICE_CLOSE và PRICE_OPEN
 [] Log có sẵn trong workspace
 [] Tên của các Properties sẽ dựa trên class thống nhất giữa các layer và class ví dụ
  - CTimeSeriesEngine CBarTimeSeriesCollection  -> m_BarTimeSeriesCollection;
  - CGUIPannel        CWindow                   -> m_window_main;
  - CTradingEngine    CSymbolsCollection        -> m_symbol_collection;
 [] Biến Pointer sẽ phải trùng tên và note rõ class nào hold nó ví dụ
  - CSymbolsCollection         *m_symbol_collection; //CTradingEngine owns
 [] Tận dụng triệt để method của Library thay vì Buildin.
 [] Tránh thêm các Method không cần trong khi Library có sẵn. 
   - Cụ thể: Library đã có PrintParameters mà vẫn muốn thêm trong Deblib
 [] Sự thay đổi trong Library cần trao đổi thống nhất làm rõ. Và ko tự thay đổi.
 [] Hạn chế tối đa Flicker ở Layer 2.
 [] Hạn chế viết method Inline, chỉ các method return ngắn gọn,mới dùng inline.

3. Layer 1: 
 []: CTimeSeriesEngine
   [] m_BarTimeSeriesCollection -> m_IndicatorsCollection quan hệ 1-n : Một CBarSeriesDE sẽ có nhiều CIndicatorDE
   [] m_IndicatorsCollection    -> m_SignalsCollection    quan hệ 1-1 : Mỗi Indicator sẽ có một Signal, một Signal có thể có nhiều Buffer (BBand)
   [] Template ở Layer 1: Là số Indicator có ở một CBarTimeSeriesDE     
     [v] LoadIndicatorFromJSON
     [v] AddNewIndicatorToAllSeries
     [v] AddAllIndicatorsToNewSeries
     [v] CIndicatorsCollection::TemplateExists(type, params):Check xem Indicator trên chart (Layer 3)  đã có ở Layer 1 hay chưa
     [v] Save to JSON.
   [] Carefull check Indicator and Signal
     [v]BBand: Boillinger Band
     [v] AMA: Slope indicator
     [v] MACD:

   [] Hiện mới xử lý IND_SAR và IND_MA
4. Layer 2
  [v] CTreeView  m_treeview_SymbolTF;
     [v] Display Symbol + TF on Layer 1.
     [v] Highlight node base on Current Chart on Layer 3
     [v] Add CBarSeriesDE on Layer 1: OnEvent click on Node
  [v] CTreeView  m_treeview_indicator;
     [v] Display and Highlight Indicator, có thể có nhiều Indicator PSAR chẳng hạn khác nhua ở Parameter
  [] CTable     m_table_indicator; danh sách các Indicator có trong template ở Layer 1.
      nó có thể nhiều hơn ở Layer 3 vì đơn giản có checkbox để điều khiển việc show/hide
      - Việc Toggle các check box sẽ mirror từ layer 2 -> Layer 3.
     [v] CGUIPannel::LineRepresentsIndicator(line_handle, indicator) / OwnedInstanceOfLine nhận diện 1 line trên chart có phải instance của Layer 1 không
     [V] checkbox cột Show của m_table_indicator → ChartIndicatorAdd/Delete).
     [v] checkbox cột Buy của m_table_indicator -> Show Buy Signal của Indicator tương ứng on Chart (Layer 3)
     [v] checkbox cột Sell của m_table_indicator -> Show Sell Signal của Indicator tương ứng on Chart (Layer 3)
  [v] CTable     m_table_indicator_SymbolTFValue;
5. Layer 3: Display on Chart
   [v] Indicator sẽ display bằng Buildin MT5 được control bởi Layer 2.
   [x] Buy/Sell Signal sẽ được display bằng CGraphElementsCollection.
   [x] Quản lý Event bởi CChartObjCollection
   [v] Đồng bộ Indicator của Layer 3 với Layer 2 và Layer 1
     [v] Khi User Insert một indicator ở Layer 3 
         - Sẽ phải Map với Layer 1, nếu có rồi thì thôi, không có thì phải Add vào Layer 1
	 - ImportForeignChartIndicators()
     [v] Khi User Update một indicator ở Layer 3 (Update Paramete) thì sẽ phải Update Layer 2 và Layer 1.   
   [] CPatternRenderer: đang dừng lại do gây Lag.
   [v] m_window_infor khi ấn Ctr và di mouse vào candle đang chưa khôi phục lại
   [] CPatternRenderer để hiện các CandlePattern nhưng bị lag
   [] CTradingLevelBubble để hiện SL, TP đang triển khai đã test thử hơi khó di chuyển một tí.
     [v] Update lại sau khi có CChartObjCollection
     [v] Bị mất khi đổi TF
     [v] Chạy ngang

6. Bug note
  2027 0713 
   [] CTradingLevelBubble: 
     [] Rất khó di chuyển.
     [v] ChartChange là mất.
   [v] m_table_indicator bị duplicate BBand
  
7. Feature Note
