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
   [] Layer 4: File có 
      - JSON Config 
      - SignalBride
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
 [] Mọi thay đổi trong Library cần trao đổi thống nhất làm rõ. Và ko tự thay đổi.
 [] Mọi sự thay đổi trong code cần trao đổi trước.
 [] Hạn chế tối đa Flicker ở Layer 2.
 [] Hạn chế viết method Inline, chỉ các method return ngắn gọn,mới dùng inline.
 [] Thống nhất lại format của Comment ở mỗi đầu hàm theo format
   //+-------------------------------------------------------------------------+  
   //|                                                                         |
   //+-------------------------------------------------------------------------+  

3. Layer 1: 
 []: CTimeSeriesEngine
   [] m_BarTimeSeriesCollection -> m_IndicatorsCollection quan hệ 1-n : Một CBarSeriesDE sẽ có nhiều CIndicatorDE
   [] m_IndicatorsCollection    -> m_SignalsCollection    quan hệ 1-1 : Mỗi Indicator sẽ có một Signal, một Signal có thể có nhiều Buffer (BBand)
   [] Template ở Layer 1: Là số Indicator có ở một CBarTimeSeriesDE khái niệm Indicator-Template này sẽ xuyên suốt giữa các Layer và được CGUIPannel (Layer 2) hold, nó sẽ phải update  
      SJsonIndicatorEntry         m_indicator_template_setting[];
      SJsonSymbolTF               m_symbol_tf_Setting[];  
     [v] Layer 1 KHÔNG parse JSON nữa (từ V9, SynIndicatorPlan.md) - CGUIPannel::LoadSymbolTFSettingFromJSON
         và CGUIPannel::LoadIndicatorTemplateSettingFromJSON (tách từ LoadGUIConfigFromJSON,
         2026-08-20 - mỗi hàm tự parse riêng file JSON, chỉ giữ đúng section mình cần) tự parse
         (dùng free function ParseIndicatorConfigFile của JSONConfig.mqh) rồi điền thẳng vào 2 mảng
         trên, gọi 1 lần duy nhất từ đầu CGUIPannel::OnInitEvent (EA's OnInit) - SymbolTF trước
         (tạo Series), Template sau (cần Series đã tạo để attach indicator vào).
     [v] CTimeSeriesEngine::ApplySymbolTFSetting: nhận mảng ĐÃ có sẵn (không tự parse) làm phần việc
         cơ học - tạo Series thật cho từng entry. ApplyIndicatorTemplateSetting đã XÓA (2026-08-19) -
         startup giờ coi là "mọi Series đều mới", LoadIndicatorTemplateSettingFromJSON gọi thẳng
         AddAllIndicatorsToNewSeries (mục dưới) 1 lần/Series thay vì có path "Apply" riêng.
     [v] AddNewIndicatorToAllSeries/RemoveIndicatorFromAllSeries: thuần cơ học, không nhận/không
         đụng m_indicator_template_setting[] nữa - CGUIPannel tự check tồn tại trước
         (IsIndicatorInTemplateSetting) rồi mới gọi Add/Remove.
     [v] AddAllIndicatorsToNewSeries (dùng chung cho CẢ startup lẫn CHARTCHANGE - series mới): nhận
         m_indicator_template_setting[] làm input ĐỌC, đọc thẳng .type_enum/.raw_params[] (đã điền
         sẵn bởi CGUIPannel) - không tự check tồn tại, không tự ghi mảng, không đụng gì tới text/
         catalog/schema (đúng nguyên tắc CTimeSeriesEngine không làm việc với JSON).
     
   [] Carefull check Indicator and Signal
     [v]BBand: Boillinger Band
     [v] AMA: Slope indicator
     [v] MACD:

   [] Hiện mới xử lý IND_SAR và IND_MA
4. Layer 2
  [v] Từ bản V8 thì Layer 2 được tách biệt việc implemenation ra các module khác nhau theo nguyên tắc chức năng của các GUI Control theo Tab
    - GUIPannel.mqh  => Declareation
    - GUIPannel_Define.mqh => Define enum in Class CGUIpanel only
    - GUIPannel_Lifecycle.mqh => Implementation all lifecycle method    
    - GUIPannel_MainWindows.mqh => Implementation all method create main window
    - GUIPannel_TabMonitor.mqh => Implementation all method create tab monitor
    - GUIPannel_TabPosition.mqh => Implementation all method create tab position 
    - GUIPannel_TabSettingIndicator.mqh => Implementation all method create tab setting indicator
    - GUIPannel_TabSettingSymbolTF.mqh => Implementation all method create tab setting symbol tf    
    - GUIPannel_TabSetting.mqh => Implementation all method create tab setting    
    - GUIPannel_TabSettingMarket.mqh => Implementation all method create tab setting market 
  [v] Từ bản V9 thì CGUIPannel trực tiếp làm việc với JSONConfig.
5. Feature    
 [v] CTreeView  m_treeview_SymbolTF;
    [v] Display Symbol + TF 
    [v] Highlight node base on Current Chart on Layer 3
    [v] Add CBarSeriesDE on Layer 1: OnEvent click on Node
 [v] CTreeView  m_treeview_indicator;
    [v] Display and Highlight Indicator, có thể có nhiều Indicator PSAR chẳng hạn khác nhua ở Parameter
 [v] CTable     m_table_indicator_template; danh sách các Indicator có trong template ở 
      nó có thể nhiều hơn ở Layer 3 vì đơn giản có checkbox để điều khiển việc show/hide
      - Việc Toggle các check box sẽ mirror từ layer 2 -> Layer 3.  
 [v] CTable     m_table_indicator_SymbolTFValue;
6. Layer 3: Display on Chart trên Chart lúc nào cũng có một Template để display các Indicator
   [v] Indicator sẽ display bằng Buildin MT5 được control bởi Layer 2.
   [v] Buy/Sell Signal sẽ được display bằng SignalMarker
   [v] Quản lý Event bởi CChartObjCollection
7. Sync Indicator-Template và SymbolTF giữa các Layer 3 (Chart), Layer 2 (Table), Layer 1 Pure Data, Layer 4 File (SignalBride)
 a. CGUIPannel sẽ hold 2 Live Array Data
  - SJsonSymbolTF               m_symbol_tf_Setting[] là Data
   - Xóa 1 dòng Symbol/TF (nút X) trong m_table_indicator_SymbolTFSeting sẽ KHÔNG ghi file ngay - chỉ xóa entry khỏi m_symbol_tf_Setting[] (mảng live), giống mọi setting khác; chỉ nút Save mới thực sự ghi xuống đĩa.   
  - SJsonIndicatorEntry         m_indicator_template_setting[]
   ->Cái struct này không có trường nào để lưu trạng thái Show/Hide  
    - m_bool_table_indicator_template_cache_show để bổ sung thêm cho CTable
    - m_indicator_template_setting là Center Point of Data, Single Source of Truth khi Live, còn m_table_indicator_template là view của nó, và vì thế chúng là Mirror của nhau dc thực hiện bởi 
      - RefreshTableIndicator
      - SetIndicatorTableRow
  -Layer 2:       
  b: Layer 2 vs Layer 1 CGUIPannel sẽ call Layer 1 sau khi check không có chiều ngược lại
    -CTimeSeriesEngine::AddAllIndicatorsToNewSeries (không có delete vì PureData không delete Series)
    -CTimeSeriesEngine::AddNewIndicatorToAllSeries
    -CTimeSeriesEngine::RemoveIndicatorFromAllSeries
  c: Layer 2 vs Layer 3: m_indicator_template_setting,m_table_indicator_template, và Indicator-Template ở Chart phải đồng bộ.
    -CGUIPannel::IsIndicatorInTemplateSetting ->Check xem một indicator có trong m_table_indicator_template hay không?
    - CGUIPannel::IsIndicatorShownOnChart->Check xem Indicator đó có trên Chart hay không
    - CGUIPannel::RemoveIndicatorFromTemplateSetting -> Remove một indicator trong     m_indicator_template_setting
    - CGUIPannel::AddIndicatorToTemplateSetting->Add một indicator vào m_indicator_template_setting

    - CTimeSeriesEngine::GetIndicatorHandle(symbol,tf,type,params) -> trả Handle (Layer 1 query, không trả live pointer)
    - CGUIPannel::GetIndicatorGroupForType(type) -> trả Group qua catalog[], không cần Layer 1
    - Table ở Layer 2 có một cột để chọn Show/Hide
    - Layer 3-> Layer 2: SCanIndicatorOnChart-> 
    - Layer 2-> Layer 3: 
      - OnClickToggleShowIndicatorOnChart
        Show -> Call Build in ChartIndicatorAdd
        Hide ->  RemoveIndicatorFromChart (RAW type+params match per chart line) -> ChartIndicatorDelete  
8. Layer 4 Working with file
 [] Config_Setting.json to save and load Configuration (1 file JSON duy nhất). 
  Từ V9 (SynIndicatorPlan.md, "Action" Step 2), TOÀN BỘ việc đọc/ghi file này thuộc về CGUIPannel (Layer 2) 
  - Layer 1 (CTimeSeriesEngine) không còn biết gì về JSON nữa, kể cả tên file. Lý do: mọi input hàm Save/Load cần đều đã nằm sẵn trong m_indicator_template_setting[]/m_symbol_tf_Setting[] - 2 mảng CGUIPannel tự hold và Layer 2 sẽ chủ động gọi các Method của Layer 1- nên không
     cần hỏi Layer 1 gì cả; free function parse (ParseIndicatorConfigFile) nằm ở JSONConfig.mqh,
     không phải code riêng của Layer 1.
   - Mỗi hàm Save chỉ được BUILD MỚI đúng (các) section mình sở hữu, còn lại phải đọc file cũ và
     PRESERVE nguyên văn (raw text) section không sở hữu trước khi ghi đè cả file - quy tắc này
     giờ áp dụng GIỮA CÁC HÀM SAVE con của chính CGUIPannel (không còn là giữa Layer 1/Layer 2 nữa).
   - Bảng sở hữu section (tên key chính thức, đều là method của CGUIPannel):
     - SaveGUIConfigToJSON / LoadSymbolTFSettingFromJSON / LoadIndicatorTemplateSettingFromJSON sở hữu:
       - "Symbols_TFs_List"
       - "Indicator_Templates"
     - SavePatternAlertConfigToJSON / LoadPatternAlertConfigFromJSON sở hữu:
       - "Pattern_Alerts_Setting"
     - SaveMarkerSettingsToJSON / LoadMarkerSettingsFromJSON sở hữu:
       - "Markers_Setting"
       - "Sound_Settings"
   - Quy tắc preserve: trước khi FileOpen(FILE_WRITE) ghi đè file, hàm Save phải 
   - IndicatorConfig_ReadWholeFile()
   - IndicatorConfig_ExtractRawSection() 
   cho TỪNG section mình không sở hữu, rồi nối lại vào JSON output. Thiếu bước này ở bất kỳ hàm Save nào sẽ làm mất section của hàm Save khác (đã từng xảy ra vì CTimeSeriesEngine::SaveConfigurationToJSON - nay đã xóa - không preserve markers/pattern_alerts/sound_settings).
   - 