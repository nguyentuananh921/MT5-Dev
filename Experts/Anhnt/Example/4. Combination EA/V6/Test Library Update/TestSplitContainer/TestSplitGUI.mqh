//+------------------------------------------------------------------+
//|                                              TestSplitGUI.mqh    |
//| Minimal GUI: 1 CWindow + 1 CSplitContainer + 2 bold-colored       |
//| panels. Now that the separator itself is confirmed working, this |
//| tests whether Panel1/Panel2 resize correctly alongside it.       |
//+------------------------------------------------------------------+
#ifndef __TESTSPLITGUI_MQH__
#define __TESTSPLITGUI_MQH__
#include <Vendors\Anhnt\Library\4. Combination Lib\GUI Lib\WndEvents.mqh>
#include <Vendors\Anhnt\Library\4. Combination Lib\GUI Lib\Controls\SplitContainer.mqh>

class CTestSplitGUI : public CWndEvents
  {
   private:
      CWindow         m_window;
      CSplitContainer m_split;
      CButton         m_btn_left;
      CButton         m_btn_right;
      bool            m_gui_created;

      int  WindowIdx(CWindow &wnd);
      bool CreateMainWindow(const string caption_text);
      bool CreateGUI(void);

   public:
                     CTestSplitGUI(void) { m_gui_created = false; }
                    ~CTestSplitGUI(void) {}
      bool           OnInitEvent(const int uninit_reason = REASON_PROGRAM);
      void           OnDeinitEvent(const int reason);
      void           OnTimerEvent(void);
      virtual void   OnEvent(const int id, const long &lparam, const double &dparam, const string &sparam) {}
  };

//+------------------------------------------------------------------+
int CTestSplitGUI::WindowIdx(CWindow &wnd)
  {
   for(int i = 0; i < WindowsTotal(); i++)
      if(m_windows[i] == GetPointer(wnd))
         return i;
   return 0;
  }
//+------------------------------------------------------------------+
bool CTestSplitGUI::CreateMainWindow(const string caption_text)
  {
   CWndContainer::AddWindow(m_window);
   m_window.XSize(600);
   m_window.YSize(400);
   m_window.FontSize(9);
   m_window.IsMovable(true);
   m_window.ResizeMode(true);
   m_window.CloseButtonIsUsed(true);
   m_window.MinimumXSize(200);
   m_window.MinimumYSize(150);
   if(!m_window.CreateWindow(m_chart_id, m_subwin, caption_text, 1, 1))
      return false;
   return true;
  }
//+------------------------------------------------------------------+
bool CTestSplitGUI::CreateGUI(void)
  {
   if(!CreateMainWindow("Test SplitContainer"))
     {
      Print(__FUNCTION__, " > Failed to create window!");
      return false;
     }

   // --- SplitContainer keeps an 80px left/top margin (x_gap/y_gap) so its own
   // --- bounds stay visually distinct from the window, but AutoX/YResizeMode
   // --- ON lets its right/bottom edge track the window edge - so resizing the
   // --- window itself exercises ChangeWidthByRightWindowSide/ChangeHeightByBottomWindowSide.
   m_split.MainPointer(m_window);
   m_split.AutoXResizeMode(true);
   m_split.AutoXResizeRightOffset(80);
   m_split.AutoYResizeMode(true);
   m_split.AutoYResizeBottomOffset(80);
   if(!m_split.CreateSplitContainer(80, 80))
     {
      Print(__FUNCTION__, " > Failed to create SplitContainer!");
      return false;
     }
   CWndContainer::AddToElementsArray(WindowIdx(m_window), m_split);

   // --- Panel1 (left): bold red, fixed width = m_split_x
   m_btn_left.MainPointer(m_split);
   m_btn_left.AutoXResizeMode(false);
   m_btn_left.AutoYResizeMode(true);
   m_btn_left.BackColor(clrRed);
   m_btn_left.BackColorHover(clrRed);
   m_btn_left.BackColorPressed(clrRed);
   m_btn_left.BorderColor(clrDarkRed);
   m_btn_left.LabelColor(clrWhite);
   if(!m_btn_left.CreateButton("Panel 1 (left)", 0, 0))
     {
      Print(__FUNCTION__, " > Failed to create left panel!");
      return false;
     }
   CWndContainer::AddToElementsArray(WindowIdx(m_window), m_btn_left);
   m_split.SetPanel1(m_btn_left);

   // --- Panel2 (right): bold blue, fills whatever is left of the splitter
   m_btn_right.MainPointer(m_split);
   m_btn_right.AutoXResizeMode(true);
   m_btn_right.AutoYResizeMode(true);
   m_btn_right.BackColor(clrBlue);
   m_btn_right.BackColorHover(clrBlue);
   m_btn_right.BackColorPressed(clrBlue);
   m_btn_right.BorderColor(clrNavy);
   m_btn_right.LabelColor(clrWhite);
   if(!m_btn_right.CreateButton("Panel 2 (right)", m_split.SplitX() + 4, 0))
     {
      Print(__FUNCTION__, " > Failed to create right panel!");
      return false;
     }
   CWndContainer::AddToElementsArray(WindowIdx(m_window), m_btn_right);
   m_split.SetPanel2(m_btn_right);

   CWndEvents::CompletedGUI();
   return true;
  }
//+------------------------------------------------------------------+
bool CTestSplitGUI::OnInitEvent(const int uninit_reason = REASON_PROGRAM)
  {
   if(!m_gui_created)
     {
      if(!CreateGUI()) return false;
      m_gui_created = true;
     }
   return true;
  }
//+------------------------------------------------------------------+
void CTestSplitGUI::OnDeinitEvent(const int reason)
  {
   if(reason != REASON_CHARTCHANGE)
      CWndEvents::Destroy();
  }
//+------------------------------------------------------------------+
void CTestSplitGUI::OnTimerEvent(void)
  {
   if(::MQLInfoInteger(MQL_TESTER) || ::MQLInfoInteger(MQL_FRAME_MODE))
      return;
   CWndEvents::OnTimerEvent();
  }
#endif // __TESTSPLITGUI_MQH__
