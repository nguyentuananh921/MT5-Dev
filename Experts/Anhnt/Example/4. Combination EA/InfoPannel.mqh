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
 #include <Vendors\Anhnt\Library\4. Combination Lib\Engines\BarEngine.mqh>
 //+------------------------------------------------------------------+
 //| Tab indices                                                      |
 //+------------------------------------------------------------------+
 enum ENUM_TAB_INFO
  {
   TAB_INFO_BAR = 0,
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
    private:
      bool              CreateInfoWindow(void);
      bool              CreateTabs(const int x_gap, const int y_gap);
      bool              CreateLabels(const int x_gap, const int y_gap);

    public:
                        CInfoPannel(void);
                        ~CInfoPannel(void);
      bool              OnInitEvent(void);
      void              OnDeinitEvent(const int reason);
      void              ShowAt(const int x, const int y, CBar *bar, const int digits);
      void              Hide(void);
      virtual void      OnEvent(const int id, const long &lparam,
                                const double &dparam, const string &sparam);
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
 //| Create the info window                                           |
 //+------------------------------------------------------------------+
  bool CInfoPannel::CreateInfoWindow(void)
   {
    CWndContainer::AddWindow(m_infoWindow);
    //--- Properties
      m_infoWindow.XSize(200);
      m_infoWindow.YSize(220);
      m_infoWindow.FontSize(9);
      m_infoWindow.IsMovable(true);
      m_infoWindow.CloseButtonIsUsed(false);
      m_infoWindow.CollapseButtonIsUsed(false);
      m_infoWindow.FullscreenButtonIsUsed(false);
      m_infoWindow.TooltipsButtonIsUsed(false);
    //--- Create at off-screen position, hidden initially
      if(!m_infoWindow.CreateWindow(m_chart_id, m_subwin, "Bar Info", 0, 0))
          return(false);
    //--- Create child controls inside this window
      if(!CreateTabs(3, 43))
        { Print(__FUNCTION__, " > Failed to create tabs!"); return(false); }
      if(!CreateLabels(6, 68))
        { Print(__FUNCTION__, " > Failed to create labels!"); return(false); }
      return(true);
  }
 //+------------------------------------------------------------------+
 //| Create tabs                                                      |
 //+------------------------------------------------------------------+
  bool CInfoPannel::CreateTabs(const int x_gap, const int y_gap)
   {
    #define INFO_TABS_TOTAL 1
    string tab_names[INFO_TABS_TOTAL] = {"Bar Info"};
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
      for(int i = 0; i < INFO_TABS_TOTAL; i++)
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
        labels[i].MainPointer(m_tabs);
        m_tabs.AddToElementsArray(TAB_INFO_BAR, *labels[i]);
        labels[i].FontSize(9);
        //--- Create
        if(!labels[i].CreateTextLabel(init_texts[i], x_gap, y_gap + i * row_h))
          return(false);
        CWndContainer::AddToElementsArray(0, *labels[i]);
      }
      return(true);
   }
 //+------------------------------------------------------------------+
 //| Show panel at chart position with bar data                       |
 //+------------------------------------------------------------------+
  void CInfoPannel::ShowAt(const int x, const int y, CBar *bar, const int digits)
   {
      if(bar == NULL)
        return;
      //--- Hide to reset IsVisible state so CWindow::Show() runs Moving()
      CWndEvents::Hide();
     //--- Update label text
      m_lbl_time.LabelText("T: " + TimeToString(bar.Time(), TIME_DATE | TIME_MINUTES));
      m_lbl_open.LabelText("O: " + DoubleToString(bar.Open(), digits));
      m_lbl_high.LabelText("H: " + DoubleToString(bar.High(), digits));
      m_lbl_low.LabelText("L: " + DoubleToString(bar.Low(), digits));
      m_lbl_close.LabelText("C: " + DoubleToString(bar.Close(), digits));
     //--- Redraw labels
      m_lbl_time.Draw();   m_lbl_time.Update(false);
      m_lbl_open.Draw();   m_lbl_open.Update(false);
      m_lbl_high.Draw();   m_lbl_high.Update(false);
      m_lbl_low.Draw();    m_lbl_low.Update(false);
      m_lbl_close.Draw();  m_lbl_close.Update(false);
      //--- Set logical position    
        m_infoWindow.X(x + 15);
        m_infoWindow.Y(y - 10);
      //--- Cascade movement to Tab and Labels
        m_active_window_index = 0;
        Moving();
      //--- Show: CWindow::Show() calls Moving(m_x,m_y) to update window canvas
        CWndEvents::Show(0);
        ShowTabElements(0);
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
 //+------------------------------------------------------------------+
 //| Route chart events to GUI framework                              |
 //+------------------------------------------------------------------+
  void CInfoPannel::OnEvent(const int id, const long &lparam,
                          const double &dparam, const string &sparam)
  {
    CWndEvents::OnEvent(id, lparam, dparam, sparam);
  }
#endif // CINFOPANNEL_MQH_IMPLEMENTATION
#endif // __INFOPANNEL_MQH__
