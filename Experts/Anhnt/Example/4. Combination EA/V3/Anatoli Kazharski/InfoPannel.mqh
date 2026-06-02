//+------------------------------------------------------------------+
//|                                                   InfoPannel.mqh |
//|                        Copyright 2025, Anhnt                     |
//+------------------------------------------------------------------+
//| Bar info panel class                                             |
//+------------------------------------------------------------------+
#ifndef __INFOPANNEL_MQH__
#define __INFOPANNEL_MQH__
 //--- GUI controls
 #include <Vendors\Anhnt\Library\4. Combination Lib\GUI Lib\WndEvents.mqh>
 //--- Bar data
 #include "..\Artyom Trishkin\TimeSeriesEngine.mqh"
 #include <Vendors\Anhnt\Library\4. Combination Lib\Timeseries\Bars\BarSeriesPatterns\BarPattern.mqh>
 //+------------------------------------------------------------------+
 //| Tab indices                                                      |
 //+------------------------------------------------------------------+
 enum ENUM_TAB_INFO
  {
    TAB_INFO_PATTERNS   = 0,   // Candle pattern confluence
    TAB_INFO_INDICATORS = 1,   // Indicator values (future)
    TAB_INFO_TOTAL
  };
#ifndef CINFOPANNEL_MQH_DECLARATION
#define CINFOPANNEL_MQH_DECLARATION
 class CInfoPannel : public CWndEvents
  {
    private:
     //--- Window
      CWindow           m_infoWindow;
      //--- Tabs
      CTabs             m_tabs;
      //--- Labels for bar data
      CTextLabel        m_lbl_time;
      CTextLabel        m_lbl_open;
      CTextLabel        m_lbl_high;
      CTextLabel        m_lbl_low;
      CTextLabel        m_lbl_close;
      CTable            m_pattern_table;  // TF | Pattern | Dir
    private:
      bool              CreateInfoWindow(void);
      bool              CreateTabs(const int x_gap, const int y_gap);
      bool              CreateLabels(const int x_gap, const int y_gap);
      bool              CreatePatternTable(void);  // new
      void              ScanPatterns(CArrayObj *plist,
                             const string symbol,
                             const ENUM_TIMEFRAMES tf_current,
                             const datetime T); 

    public:
                        CInfoPannel(void);
                        ~CInfoPannel(void);
     //Life cycle
      bool              OnInitEvent(void);
      void              OnDeinitEvent(const int reason);
      virtual void      OnEvent(const int id, const long &lparam,
                                const double &dparam, const string &sparam);

      void ShowAt(const int x, const int y,
                CBar *bar, const int digits,
                CArrayObj *plist,
                const string symbol,
                const ENUM_TIMEFRAMES tf_current);
      void              Hide(void);
      
  };
#endif // CINFOPANNEL_MQH_DECLARATION
 //+------------------------------------------------------------------+
 //| Implementation                                                   |
 //+------------------------------------------------------------------+
#ifndef CINFOPANNEL_MQH_IMPLEMENTATION
#define CINFOPANNEL_MQH_IMPLEMENTATION
 //+------------------------------------------------------------------+
 //| Constructor                                                      |
 //+------------------------------------------------------------------+
 CInfoPannel::CInfoPannel(void) {}
 //+------------------------------------------------------------------+
 //| Destructor                                                       |
 //+------------------------------------------------------------------+
 CInfoPannel::~CInfoPannel(void) {}
 //+------------------------------------------------------------------+
 //| Init: create all controls                                        |
 //+------------------------------------------------------------------+
 bool CInfoPannel::OnInitEvent(void)
   {
     if(!CreateInfoWindow())
      {
        Print(__FUNCTION__, " > Failed to create info window!");
        return(false);
      }
     CWndEvents::CompletedGUI();
   //--- Hide everything after GUI is built
     Hide();
     return(true);
  }
 //+------------------------------------------------------------------+
 //| Deinit                                                           |
 //+------------------------------------------------------------------+
 void CInfoPannel::OnDeinitEvent(const int reason)
  {
   CWndEvents::Destroy();
  }
 //+------------------------------------------------------------------+
 //| Route chart events to GUI framework                              |
 //+------------------------------------------------------------------+
 void CInfoPannel::OnEvent(const int id, const long &lparam,
                          const double &dparam, const string &sparam)
  {
    CWndEvents::OnEvent(id, lparam, dparam, sparam);
  }
 //+------------------------------------------------------------------+
 //| Create the info window                                           |
 //+------------------------------------------------------------------+
 bool CInfoPannel::CreateInfoWindow(void)
   {
    CWndContainer::AddWindow(m_infoWindow);
    //--- Properties
      m_infoWindow.XSize(250);
      m_infoWindow.YSize(300);
      m_infoWindow.FontSize(9);
      m_infoWindow.IsMovable(true);
      m_infoWindow.CloseButtonIsUsed(false);
      m_infoWindow.CollapseButtonIsUsed(false);
      m_infoWindow.FullscreenButtonIsUsed(false);
      m_infoWindow.TooltipsButtonIsUsed(false);
    //--- Create at off-screen position, hidden initially
      if(!m_infoWindow.CreateWindow(m_chart_id, m_subwin, "Bar Info", 0, 0)) return(false);
    //--- Create child controls inside this window
      if(!CreateLabels(6, 25))   return false; 
      if(!CreateTabs(3, 120))    return false;
      if(!CreatePatternTable())  return false;      
      return(true);
   }
 //+------------------------------------------------------------------+
 //| Create tabs                                                      |
 //+------------------------------------------------------------------+
 bool CInfoPannel::CreateTabs(const int x_gap, const int y_gap)
   {    
    string tab_names[TAB_INFO_TOTAL] = {"Patterns", "Indicators"};
    //--- Attach to window
      m_tabs.MainPointer(m_infoWindow);
    //--- Properties
      m_tabs.IsCenterText(true);
      m_tabs.PositionMode(TABS_TOP);
      m_tabs.AutoXResizeMode(true);
      m_tabs.AutoYResizeMode(true);
      m_tabs.AutoXResizeRightOffset(3);
      m_tabs.AutoYResizeBottomOffset(3);
    //--- Add tab
      for(int i = 0; i < TAB_INFO_TOTAL; i++)
         m_tabs.AddTab(tab_names[i], 100);
    //--- Create
      if(!m_tabs.CreateTabs(x_gap, y_gap))
        return(false);
      CWndContainer::AddToElementsArray(0, m_tabs);
        return(true);
   }
 //+------------------------------------------------------------------+
 //| Create text labels for OHLC inside the tab                      |
 //+------------------------------------------------------------------+
 bool CInfoPannel::CreateLabels(const int x_gap, const int y_gap)
   {
      int       row_h    = 20;
      string    init_texts[] = {"T: -", "O: -", "H: -", "L: -", "C: -"};
      CTextLabel *labels[]   = {&m_lbl_time, &m_lbl_open, &m_lbl_high, &m_lbl_low, &m_lbl_close};
      for(int i = 0; i < 5; i++)
      {
        //--- Attach to tabs, inside TAB_INFO_BAR
        labels[i].MainPointer(m_infoWindow);
        CWndContainer::AddToElementsArray(0, *labels[i]);        
        labels[i].FontSize(9);
        //--- Create
        if(!labels[i].CreateTextLabel(init_texts[i], x_gap, y_gap + i * row_h))
          return(false);
        CWndContainer::AddToElementsArray(0, *labels[i]);
      }
      return(true);
   } 
 bool CInfoPannel::CreatePatternTable(void)
  {
      m_pattern_table.MainPointer(m_tabs);
      m_tabs.AddToElementsArray(TAB_INFO_PATTERNS, m_pattern_table);
      m_pattern_table.AutoXResizeMode(true);
      m_pattern_table.AutoXResizeRightOffset(3);
      m_pattern_table.AutoYResizeMode(true);
      m_pattern_table.AutoYResizeBottomOffset(3);
      m_pattern_table.ShowHeaders(true);
      m_pattern_table.SelectableRow(true);
      m_pattern_table.TableSize(4, 1);
      int widths[4]    = {38, 120, 16, 22};
      int img_x_off[4] = {0, 0, 0, 3};
      int img_y_off[4] = {0, 0, 0, 3};
      ENUM_ALIGN_MODE align[4] = {ALIGN_CENTER, ALIGN_LEFT, ALIGN_CENTER, ALIGN_LEFT};
      m_pattern_table.ColumnsWidth(widths);
      m_pattern_table.ImageXOffset(img_x_off);   
      m_pattern_table.ImageYOffset(img_y_off);   
      m_pattern_table.TextAlign(align);  
      if(!m_pattern_table.CreateTable(3, 3)) return false;

      //Set header 
        m_pattern_table.SetHeaderText(0, "TF");
        m_pattern_table.SetHeaderText(1, "Pattern");
        m_pattern_table.SetHeaderText(2, "#");
        m_pattern_table.SetHeaderText(3, "Dir");
      
      CWndContainer::AddToElementsArray(0, m_pattern_table);
      return true;
  }
 void CInfoPannel::ScanPatterns(CArrayObj *plist, const string symbol,
                                  const ENUM_TIMEFRAMES tf_current, const datetime T)
  {
    //Setting Icon
     uint arrow_up[] = {IMAGE_RESOURCE_ICONS_BMP16_ARROW_UP_BMP};
     uint arrow_dn[] = {IMAGE_RESOURCE_ICONS_BMP16_ARROW_DOWN_BMP};
    m_pattern_table.DeleteAllRows();
    if(plist == NULL) { m_pattern_table.Update(true); return; }

    int row = 0;
     for(int i = 0; i < plist.Total(); i++)
      {
          CBarPattern *p = plist.At(i);
          if(p == NULL) continue;
          if(p.GetProperty(PATTERN_PROP_SYMBOL) != symbol) continue;
          ENUM_TIMEFRAMES p_tf = (ENUM_TIMEFRAMES)p.GetProperty(PATTERN_PROP_PERIOD);
          if((int)p_tf < (int)tf_current) continue;
          datetime p_time = (datetime)p.GetProperty(PATTERN_PROP_TIME);
          if(p_time > T || T >= p_time + PeriodSeconds(p_tf)) continue;

          if(row > 0) m_pattern_table.AddRow(row);


          string tf_str = StringSubstr(EnumToString(p_tf), 7); // "PERIOD_M1"→"M1"
          string name   = p.GetProperty(PATTERN_PROP_NAME);
          int    candles = (int)p.GetProperty(PATTERN_PROP_CANDLES);
          long   dir    = p.GetProperty(PATTERN_PROP_DIRECTION);
          //Update here
            m_pattern_table.SetValue(0, row, tf_str);
            m_pattern_table.SetValue(1, row, name);
            m_pattern_table.SetValue(2, row, string(candles));
            // Col 3: icon
             m_pattern_table.CellType(3, row, CELL_BUTTON);
             if(dir == PATTERN_DIRECTION_BULLISH)
                m_pattern_table.SetImages(3, row, arrow_up);
             else if(dir == PATTERN_DIRECTION_BEARISH)
                m_pattern_table.SetImages(3, row, arrow_dn);
             else // BOTH
              {
                m_pattern_table.CellType(3, row, CELL_SIMPLE);
                m_pattern_table.SetValue(3, row, "±");
              }            
          row++;
      }
      if(row == 0)
          m_pattern_table.SetValue(1, 0, "No patterns");
      m_pattern_table.Update(true);
  }
 //+------------------------------------------------------------------+
 //| Show panel at chart position with bar data                       |
 //+------------------------------------------------------------------+
 void CInfoPannel::ShowAt(const int x, const int y, CBar *bar, const int digits,
                          CArrayObj *plist, const string symbol,
                          const ENUM_TIMEFRAMES tf_current)
  {
      if(bar == NULL) return;
      CWndEvents::Hide();
     // Update OHLC 
      m_lbl_time.LabelText("T: " + TimeToString(bar.Time(), TIME_DATE|TIME_MINUTES));
     // Update ALL OHLC labels
      m_lbl_time.LabelText("T: " + TimeToString(bar.Time(), TIME_DATE|TIME_MINUTES));
      m_lbl_open.LabelText("O: " + DoubleToString(bar.Open(), digits));
      m_lbl_high.LabelText("H: " + DoubleToString(bar.High(), digits));
      m_lbl_low.LabelText("L: " + DoubleToString(bar.Low(), digits));
      m_lbl_close.LabelText("C: " + DoubleToString(bar.Close(), digits));
    // Redraw
      m_lbl_time.Draw();   m_lbl_time.Update(false);
      m_lbl_open.Draw();   m_lbl_open.Update(false);
      m_lbl_high.Draw();   m_lbl_high.Update(false);
      m_lbl_low.Draw();    m_lbl_low.Update(false);
      m_lbl_close.Draw();  m_lbl_close.Update(false);

      // Scan patterns
      ScanPatterns(plist, symbol, tf_current, bar.Time());

      // Position với overflow flip
      long chart_w, chart_h;
      ChartGetInteger(0, CHART_WIDTH_IN_PIXELS,  0, chart_w);
      ChartGetInteger(0, CHART_HEIGHT_IN_PIXELS, 0, chart_h);
      int px = x + 15;
      int py = y - 10;
      if(px + 250 > (int)chart_w) px = x - 255;
      if(py + 300 > (int)chart_h) py = y - 300;

      m_infoWindow.X(px);
      m_infoWindow.Y(py);
      m_active_window_index = 0;
      Moving();
      CWndEvents::Show(0);
      ShowTabElements(0);
      // Show window-level labels (not in any tab)
        m_lbl_time.Show();   
        m_lbl_open.Show();
        m_lbl_high.Show();   
        m_lbl_low.Show();
        m_lbl_close.Show();
      m_chart.Redraw();
  }

 //+------------------------------------------------------------------+
 //| Hide the panel                                                   |
 //+------------------------------------------------------------------+
 void CInfoPannel::Hide(void)
  {
   CWndEvents::Hide();   // cascade hide all element
   m_infoWindow.Hide();
   m_chart.Redraw();
  }
 
#endif // CINFOPANNEL_MQH_IMPLEMENTATION
#endif // __INFOPANNEL_MQH__
