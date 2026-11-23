//+------------------------------------------------------------------+
//|                                                    WndEvents.mqh |
//|                        Copyright 2015, MetaQuotes Software Corp. |
//|Lib Link https://www.mql5.com/en/code/19703                       |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//| Event handling class                                             |
//+------------------------------------------------------------------+
#ifndef __WNDEVENTS_MQH__
#define __WNDEVENTS_MQH__
  #include "Defines.mqh"
  #include "WndContainer.mqh"
 class CWndEvents : public CWndContainer 
   {
    protected:
      // --- An instance of the class for managing the graph
        CChart            m_chart;
      // --- Chart window ID and number
        long              m_chart_id;
        int               m_subwin;
      // --- Program name
        string            m_program_name;
      // --- Short name of the indicator
        string            m_indicator_shortname;
      // --- Active window index
        int               m_active_window_index;
      // --- Expert subwindow handle
        int               m_subwindow_handle;
      // --- Expert subwindow name
        string            m_subwindow_shortname;
      // --- Number of subwindows on the chart after installing the Expert Advisor subwindow
        int               m_subwindows_total;
      //---
    private:
      // ---Event settings
        int               m_id;
        long              m_lparam;
        double            m_dparam;
        string            m_sparam;
      //---
    public:
        CWndEvents(void);
        ~CWndEvents(void);
      // --- Virtual graph event handler
        virtual void      OnEvent(const int id, const long &lparam, const double &dparam, const string &sparam) {}
      // --- Timer
        void              OnTimerEvent(void);
      //---
    public:
      // ---Graph event handlers
        void              ChartEvent(const int id, const long &lparam, const double &dparam, const string &sparam);
      //---
    public:
      // --- Returns the index of the activated window
      int               GetActiveWindowIndex(void) {return(m_active_window_index); }
      //---
        private:
        void              ChartEventCustom(void);
        void              ChartEventClick(void);
        void              ChartEventMouseMove(void);
        void              ChartEventObjectClick(void);
        void              ChartEventEndEdit(void);
        void              ChartEventChartChange(void);
      // --- Checking events in controls
        void              CheckElementsEvents(void);
      // --- Determining the subwindow number
        void              DetermineSubwindow(void);
      // --- Delete Expert Advisor subwindow
        void              DeleteExpertSubwindow(void);
      // --- Checking and updating the expert window number
        void              CheckExpertSubwindowNumber(void);
      // --- Checking and updating the indicator window number
        void              CheckSubwindowNumber(void);
      // --- Resizing a locked main form
        void              ResizeLockedWindow(void);
      // --- Initializing event parameters
        void              InitChartEventsParams(const int id, const long lparam, const double dparam, const string sparam);
      // --- Moving the window
        void              MovingWindow(const bool moving_mode = false);
      // --- Checking events of all elements using a timer
        void              CheckElementsEventsTimer(void);
      // --- Setting the chart state
        void              SetChartState(void);
      //---
    protected:
        // --- Removing an interface
         void              Destroy(void);
        // --- Redrawing the window
         void              ResetWindow(void);
        //---
    public:
        // --- Kernel initialization
         void              InitializeCore(void);
        // --- Completing GUI creation
         void              CompletedGUI(void);
        // ---Updating the position of elements
         void              Moving(void);
        //---
    protected:
        // --- Hiding all elements
         void              Hide(void);
        // --- Show elements of the specified window
         void              Show(const uint window_index);
        // --- Restoring left-click priorities
         void              SetZorders(void);
        // --- Redrawing elements
         void              Update(const bool redraw = false);
        // --- Moves tooltips to the top layer
         void              ResetTooltips(void);
        // --- Shows items in selected tabs only
         void              ShowTabElements(const uint window_index);
        // --- Sets the accessibility status of elements
         void              SetAvailable(const uint window_index, const bool state);

        // --- Forms an array of elements with a timer
         void              FormTimerElementsArray(void);
        // --- Forms an array of available elements
         void              FormAvailableElementsArray(void);
        // --- Forms an array of elements with auto-resize (X)
         void              FormAutoXResizeElementsArray(void);
        // --- Forms an array of elements with auto-resize (Y)
         void              FormAutoYResizeElementsArray(void);
        //---
    private:
      // --- Form drag and drop completed
      bool              OnWindowEndDrag(void);
      // --- Collapse/expand form
      bool              OnWindowCollapse(void);
      bool              OnWindowExpand(void);
      // --- Handling window resizing
      bool              OnWindowChangeXSize(void);
      bool              OnWindowChangeYSize(void);
      // --- Enable/disable tooltips
      bool              OnWindowTooltips(void);
      // --- Hiding all context menus from the initiator item
      bool              OnHideBackContextMenus(void);
      // --- Hiding all context menus
      bool              OnHideContextMenus(void);
      // --- Opening a dialog box
      bool              OnOpenDialogBox(void);
      // ---Close the dialog box
      bool              OnCloseDialogBox(void);
      // --- Determine available elements
      bool              OnSetAvailable(void);
      // --- Defining blocked elements
      bool              OnSetLocked(void);
      // --- Changes in GUI
      bool              OnChangeGUI(void);
      //---
    private:
      // --- Returns the index of the activated window
      int               ActivatedWindowIndex(void);
      // --- Returns the index of the activated main menu
      int               ActivatedMenuBarIndex(void);
      // --- Returns the index of the activated menu item
      int               ActivatedMenuItemIndex(void);
      // --- Returns the index of the activated double button
      int               ActivatedSplitButtonIndex(void);
      // --- Returns the index of the activated combo box
      int               ActivatedComboBoxIndex(void);
      // --- Returns the index of the activated dropdown calendar
      int               ActivatedDropCalendarIndex(void);
      // --- Returns the index of the activated scrollbar
      int               ActivatedScrollIndex(void);
      // --- Returns the index of the activated table
      int               ActivatedTableIndex(void);
      // --- Returns the index of the activated slider
      int               ActivatedSliderIndex(void);
      // --- Returns the index of the activated tree list
      int               ActivatedTreeViewIndex(void);
      // --- Returns the index of the activated standard chart
      int               ActivatedSubChartIndex(void);
      // --- Checks and makes the context menu available
      void              CheckContextMenu(CMenuItem &object);
   };
 #ifndef CWNDEVENTS_MQH_IMPLEMENTATION
 #define CWNDEVENTS_MQH_IMPLEMENTATION
  //+------------------------------------------------------------------+
  //| Constructor                                                      |
  //+------------------------------------------------------------------+
  CWndEvents::CWndEvents(void) : m_chart_id(::ChartID()),
    m_subwin(0),
    m_active_window_index(0),
    m_indicator_shortname(""),
    m_program_name(PROGRAM_NAME),
    m_subwindow_handle(INVALID_HANDLE),
    m_subwindow_shortname(""),
    m_subwindows_total(1) 
  {
    // --- Quit if this is not real time
      if(::MQLInfoInteger(MQL_TESTER) || ::MQLInfoInteger(MQL_FRAME_MODE))
        return;
    // --- Kernel initialization
      InitializeCore();
  }
  //+------------------------------------------------------------------+
  //| Destructor                                                       |
  //+------------------------------------------------------------------+
  CWndEvents::~CWndEvents(void) 
  {
    // --- Quit if this is not real time
      if(::MQLInfoInteger(MQL_TESTER))
        return;
    // --- Delete timer
      ::EventKillTimer();
    // --- Let's turn on the control
      m_chart.MouseScroll(true);
      m_chart.SetInteger(CHART_DRAG_TRADE_LEVELS, true);
    // --- Disable tracking of mouse events
      m_chart.EventMouseMove(false);
    // --- Enable the command line call for the Space and Enter keys
      m_chart.SetInteger(CHART_QUICK_NAVIGATION, true);
    // ---Disconnect from schedule
      m_chart.Detach();
    // --- Remove the indicator subwindow
      DeleteExpertSubwindow();
    // --- Erase comment
      ::Comment("");
  }
  //+------------------------------------------------------------------+
  // | Kernel initialization |
  //+------------------------------------------------------------------+
  void CWndEvents::InitializeCore(void) 
   {
    // --- Turn on the timer if outside the tester
      if(!::MQLInfoInteger(MQL_TESTER)) {
        ::ResetLastError();
        bool is_timer =::EventSetMillisecondTimer(TIMER_STEP_MSC);
      }
    // --- Get the ID of the current chart
      m_chart.Attach();
    // --- Enable tracking of mouse events
      m_chart.EventMouseMove(true);
    // --- Disable the command line call for the Space and Enter keys
      m_chart.SetInteger(CHART_QUICK_NAVIGATION, false);
    // --- Determining the subwindow number
      DetermineSubwindow();
   }
  //+------------------------------------------------------------------+
  //| Initializing event variables                                     |
  //+------------------------------------------------------------------+
  void CWndEvents::InitChartEventsParams(const int id, const long lparam, const double dparam, const string sparam) 
   {
    m_id     = id;
    m_lparam = lparam;
    m_dparam = dparam;
    m_sparam = sparam;
    // --- Get mouse parameters
     m_mouse.OnEvent(id, lparam, dparam, sparam);
   }
  //+------------------------------------------------------------------+
  // | Processing program events |
  //+------------------------------------------------------------------+
  void CWndEvents::ChartEvent(const int id, const long &lparam, const double &dparam, const string &sparam) 
   {
    // --- If the array is empty, exit
      if(CWndContainer::WindowsTotal() < 1) {
        // --- Send event to application file
        OnEvent(id, lparam, dparam, sparam);
        return;
      }
    // --- Initializing event parameter fields
      InitChartEventsParams(id, lparam, dparam, sparam);
    // --- Custom Events
      ChartEventCustom();
    // --- Checking interface element events
      CheckElementsEvents();
    // ---Mouse move event
      ChartEventMouseMove();
    // ---Chart properties change event
      ChartEventChartChange();
   }
  //+------------------------------------------------------------------+
  //| Checking control events                                          |
  //+------------------------------------------------------------------+
  void CWndEvents::CheckElementsEvents(void) 
   {
    // --- Handling the mouse cursor movement event
      if(m_id == CHARTEVENT_MOUSE_MOVE) {
        // --- Exit if the form is in another chart subwindow
        if(!m_windows[m_active_window_index].CheckSubwindowNumber())
          return;
        // --- We check only available elements
        int available_elements_total = CWndContainer::AvailableElementsTotal(m_active_window_index);
        for(int e = 0; e < available_elements_total; e++) {
          CElement *el = m_wnd[m_active_window_index].m_available_elements[e];
          // --- Checking focus on elements
          el.CheckMouseFocus();
          // --- Event processing
          el.OnEvent(m_id, m_lparam, m_dparam, m_sparam);
        }
      }
    // --- All events except mouse cursor movement
      else {
        int elements_total = CWndContainer::ElementsTotal(m_active_window_index);
        for(int e = 0; e < elements_total; e++) {
          // --- We check only available elements
          CElement *el = m_wnd[m_active_window_index].m_elements[e];
          if(!el.IsVisible() || !el.CElementBase::IsAvailable() || el.CElementBase::IsLocked())
            continue;
          // --- Handling the event in the element handler
          el.OnEvent(m_id, m_lparam, m_dparam, m_sparam);
        }
      }
    // --- Direct event to application file
      OnEvent(m_id, m_lparam, m_dparam, m_sparam);
   }
  //+------------------------------------------------------------------+
  // | Checking custom events (CHARTEVENT_CUSTOM) |
  //+------------------------------------------------------------------+
  void CWndEvents::ChartEventCustom(void) 
   {
    // --- If the signal is to determine the available elements
      if(OnSetAvailable())
        return;
    // --- If the change signal in the GUI
      if(OnChangeGUI())
        return;
    // --- If the signal is to detect blocked elements
      if(OnSetLocked())
        return;
    // --- If the signal indicates the end of dragging the form
      if(OnWindowEndDrag())
        return;
    // ---If the signal is to collapse the form
      if(OnWindowCollapse())
        return;
    // ---If the signal is to expand the form
      if(OnWindowExpand())
        return;
    // ---If the signal is to change the size of the elements along the X axis
      if(OnWindowChangeXSize())
        return;
    // ---If the signal is to change the size of elements along the Y axis
      if(OnWindowChangeYSize())
        return;
    // --- If the signal is enabled/disabled, tooltips
      if(OnWindowTooltips())
        return;
    // --- If the signal is to hide context menus from the initiator item
      if(OnHideBackContextMenus())
        return;
    // --- If the signal is to hide all context menus
      if(OnHideContextMenus())
        return;
    // --- If the signal to open the dialog box
      if(OnOpenDialogBox())
        return;
    // --- If the signal to close the dialog box
      if(OnCloseDialogBox())
        return;
   }
  //+------------------------------------------------------------------+
  //| Event CHARTEVENT CLICK                                           |
  //+------------------------------------------------------------------+
  void CWndEvents::ChartEventClick(void) 
   {
   }
  //+------------------------------------------------------------------+
  //| Event CHARTEVENT MOUSE MOVE                                      |
  //+------------------------------------------------------------------+
  void CWndEvents::ChartEventMouseMove(void) 
   {
    // --- Exit if this is not a cursor move event
      if(m_id != CHARTEVENT_MOUSE_MOVE)
        return;
    // --- Moving the window
      MovingWindow();
    // --- Setting the chart state
      SetChartState();
   }
  //+------------------------------------------------------------------+
  // | CHARTEVENT OBJECT CLICK event |
  //+------------------------------------------------------------------+
  void CWndEvents::ChartEventObjectClick(void) 
   {
   }
  //+------------------------------------------------------------------+
  // | Event CHARTEVENT OBJECT ENDEDIT |
  //+------------------------------------------------------------------+
  void CWndEvents::ChartEventEndEdit(void) 
   {
   }
  //+------------------------------------------------------------------+
  //| Event CHARTEVENT CHART CHANGE                                    |
  //+------------------------------------------------------------------+
  void CWndEvents::ChartEventChartChange(void) 
   {
    // --- Chart properties change event
      if(m_id != CHARTEVENT_CHART_CHANGE)
        return;
    // --- Checking and updating the expert window number
      CheckExpertSubwindowNumber();
    // --- Checking and updating the indicator window number
      CheckSubwindowNumber();
    // --- Moving the window
      MovingWindow(true);
    // --- Resizing a locked main window
      ResizeLockedWindow();
    // --- Let's redraw the graph
      m_chart.Redraw();
   }
  //+------------------------------------------------------------------+
  // | Timer |
  //+------------------------------------------------------------------+
  void CWndEvents::OnTimerEvent(void) 
   {
    // --- Exit if the mouse cursor is at rest (difference between calls > 300 ms) and the left mouse button is released
      if(m_mouse.GapBetweenCalls() > 300 && !m_mouse.LeftButtonState()) {
        int text_boxes_total = CWndContainer::ElementsTotal(m_active_window_index, E_TEXT_BOX);
        for(int e = 0; e < text_boxes_total; e++)
          m_wnd[m_active_window_index].m_text_boxes[e].OnEventTimer();
        //---
        return;
      }
    // --- If the array is empty, exit
      if(CWndContainer::WindowsTotal() < 1)
        return;
    // --- Checking events of all elements using a timer
      CheckElementsEventsTimer();
    // --- Redraw the graph if the window is in moving mode
      if(m_windows[m_active_window_index].ClampingAreaMouse() == PRESSED_INSIDE_HEADER)
        m_chart.Redraw();
   }
  //+------------------------------------------------------------------+
  // | Form drag completion event |
  //+------------------------------------------------------------------+
  bool CWndEvents::OnWindowEndDrag(void) 
   {
    // ---If the signal is to collapse the form
      if(m_id != CHARTEVENT_CUSTOM + ON_WINDOW_DRAG_END)
        return(false);
    // --- If the window ID and subwindow number are the same
      if(m_lparam == m_windows[0].Id() && (int)m_dparam == m_subwin) {
        // ---Set display mode in all main elements
        int main_total = MainElementsTotal(m_active_window_index);
        for(int e = 0; e < main_total; e++) {
          CElement *el = m_wnd[m_active_window_index].m_main_elements[e];
          el.Moving(false);
        }
      }
    // --- Update the location of all elements
      m_chart.Redraw();
      return(true);
   }
  //+------------------------------------------------------------------+
  //| Form collapse event                                              |
  //+------------------------------------------------------------------+
  bool CWndEvents::OnWindowCollapse(void) 
   {
    // ---If the signal is to collapse the form
      if(m_id != CHARTEVENT_CUSTOM + ON_WINDOW_COLLAPSE)
        return(false);
    // --- If the window ID and subwindow number are the same
      if(m_lparam == m_windows[0].Id() && (int)m_dparam == m_subwin) {
        int elements_total = CWndContainer::ElementsTotal(0);
        for(int e = 0; e < elements_total; e++) {
          CElement *el = m_wnd[0].m_elements[e];
          // --- Hide all elements except the form
          if(el.Id() > 0)
            el.Hide();
        }
        // --- Reset form colors
        m_windows[0].ResetColors();
      }
    // --- Update the location of all elements
      m_chart.Redraw();
      return(true);
   }
  //+------------------------------------------------------------------+
  //| Form expansion event                                             |
  //+------------------------------------------------------------------+
  bool CWndEvents::OnWindowExpand(void) 
   {
    // --- If the signal is "Expand form"
      if(m_id != CHARTEVENT_CUSTOM + ON_WINDOW_EXPAND)
        return(false);
    // --- Active window index
      int awi = m_active_window_index;
    // --- If the window ID and subwindow number are the same
      if(m_lparam != m_windows[awi].Id() || (int)m_dparam != m_subwin)
        return(true);
    // --- Change the height of the window if the mode is enabled
      if(m_windows[awi].AutoYResizeMode())
        m_windows[awi].ChangeWindowHeight(m_chart.HeightInPixels(m_subwin) - 3);
    //---
      int y_resize_total = CWndContainer::AutoYResizeElementsTotal(awi);
      for(int e = 0; e < y_resize_total; e++) 
      {
        CElement *el = m_wnd[awi].m_auto_y_resize_elements[e];
        // --- If the mode is on, then adjust the height
        if(el.AutoYResizeMode()) {
          el.ChangeHeightByBottomWindowSide();
          el.Update();
        }
      }
    // --- Show items
      Show(awi);
    // --- Show items in selected tabs only
      ShowTabElements(awi);
    // --- Refresh to show all changes
      int elements_total = CWndContainer::ElementsTotal(awi);
      for(int e = 0; e < elements_total; e++) 
      {
        CElement *el = m_wnd[awi].m_elements[e];
        if(el.IsVisible())
          el.Update();
      }
    // --- Update the location of all elements
      m_chart.Redraw();
      return(true);
   }
  //+------------------------------------------------------------------+
  // | Event of resizing elements along the X axis |
  //+------------------------------------------------------------------+
  bool CWndEvents::OnWindowChangeXSize(void) 
   {
    // --- If the signal is "Resize elements"
      if(m_id != CHARTEVENT_CUSTOM + ON_WINDOW_CHANGE_XSIZE)
        return(false);
    // --- Exit if window IDs do not match
      if(m_lparam != m_windows[m_active_window_index].Id())
        return(true);
    // --- Update element position
      Moving();
    // --- Refresh window
      m_windows[m_active_window_index].Update();
    // --- Change width
      int x_resize_total = CWndContainer::AutoXResizeElementsTotal(m_active_window_index);
      for(int e = 0; e < x_resize_total; e++) 
      {
        CElement *el = m_wnd[m_active_window_index].m_auto_x_resize_elements[e];
        el.ChangeWidthByRightWindowSide();
        //el.Update();
      }
    // --- Update element position
      Moving();
    //---
      for(int e = 0; e < x_resize_total; e++) 
      {
        CElement *el = m_wnd[m_active_window_index].m_auto_x_resize_elements[e];
        el.Moving(false);
      }
      m_chart.Redraw();
      for(int e = 0; e < x_resize_total; e++) 
      {
        CElement *el = m_wnd[m_active_window_index].m_auto_x_resize_elements[e];
        el.Update();
      }
    // --- Refresh to show all changes in tree lists
      int treeviews_total = ElementsTotal(m_active_window_index, E_TREE_VIEW);
      for(int t = 0; t < treeviews_total; t++) {
        CTreeView *tv = m_wnd[m_active_window_index].m_treeview_lists[t];
        tv.RedrawContentList();
        tv.UpdateContentList();
      }
    // --- Show cursor pointer if in manual width mode
      if(m_windows[m_active_window_index].ResizeState())
        m_windows[m_active_window_index].GetResizePointer().Reset();
    // --- Update the location of all elements
      m_chart.Redraw();
      return(true);
   }
  //+------------------------------------------------------------------+
  //| Event of resizing elements along the Y axis                      |
  //+------------------------------------------------------------------+
  bool CWndEvents::OnWindowChangeYSize(void) 
   {
    // --- If the signal is "Resize elements"
    if(m_id != CHARTEVENT_CUSTOM + ON_WINDOW_CHANGE_YSIZE)
      return(false);
    // --- Exit if window IDs do not match
    if(m_lparam != m_windows[m_active_window_index].Id())
      return(true);
    // --- Update element position
    Moving();
    // --- Refresh window
    m_windows[m_active_window_index].Update();
    // ---Change height
    int y_resize_total = CWndContainer::AutoYResizeElementsTotal(m_active_window_index);
    for(int e = 0; e < y_resize_total; e++) 
    {
      CElement *el = m_wnd[m_active_window_index].m_auto_y_resize_elements[e];
      el.ChangeHeightByBottomWindowSide();
      //el.Update();
    }
    // --- Update element position
    Moving();
    //---
    for(int e = 0; e < y_resize_total; e++) 
    {
      CElement *el = m_wnd[m_active_window_index].m_auto_y_resize_elements[e];
      el.Moving(false);
    }
    m_chart.Redraw();
    for(int e = 0; e < y_resize_total; e++) 
    {
      CElement *el = m_wnd[m_active_window_index].m_auto_y_resize_elements[e];
      el.Update();
    }
    // --- Show cursor pointer if in manual altitude mode
    if(m_windows[m_active_window_index].ResizeState())
      m_windows[m_active_window_index].GetResizePointer().Reset();
    // --- Update the location of all elements
    m_chart.Redraw();
    return(true);
   }
  //+------------------------------------------------------------------+
  //| Event to enable/disable tooltips                                 |
  //+------------------------------------------------------------------+
  bool CWndEvents::OnWindowTooltips(void) 
   {
    // --- If the signal is "Enable/disable tooltips"
    if(m_id != CHARTEVENT_CUSTOM + ON_WINDOW_TOOLTIPS)
      return(false);
    // --- Vytyy if the window IDs do not match
    if(m_lparam != m_windows[0].Id())
      return(true);
    // --- Synchronize tooltips mode between all windows
    int windows_total = WindowsTotal();
    for(int w = 0; w < windows_total; w++) 
    {
      bool state = m_windows[0].TooltipButtonState();
      m_windows[w].IsTooltip(state);
      // --- Show tooltips in window buttons
      int window_elements_total = m_windows[w].ElementsTotal();
      for(int e = 0; e < window_elements_total; e++) {
        CElement *el = m_windows[w].Element(e);
        el.ShowTooltip(state);
      }
      // --- Set display mode in all elements
      int elements_total = ElementsTotal(w);
      for(int e = 0; e < elements_total; e++) {
        CElement *el = m_wnd[w].m_elements[e];
        el.ShowTooltip(state);
      }
    }
    // ---Move tooltips to top layer
    ResetTooltips();
    return(true);
   }
  //+------------------------------------------------------------------+
  // | Event of hiding context menus from the initiator item |
  //+------------------------------------------------------------------+
  bool CWndEvents::OnHideBackContextMenus(void) 
   {
    // --- If the signal is to hide context menus from the initiator item
    if(m_id != CHARTEVENT_CUSTOM + ON_HIDE_BACK_CONTEXTMENUS)
      return(false);
    // --- Let's go through all the menus from the last one called
    int awi = m_active_window_index;
    int context_menus_total = CWndContainer::ElementsTotal(awi, E_CONTEXT_MENU);
    for(int i = context_menus_total - 1; i >= 0; i--) 
    {
      // --- Pointers to the context menu and its previous node
      CContextMenu *cm = m_wnd[awi].m_context_menus[i];
      CMenuItem    *mi = cm.PrevNodePointer();
      // --- If there is nothing further beyond this point, then...
      if(::CheckPointer(mi) == POINTER_INVALID)
        continue;
      // --- If you reach the signal initiator point, then...
      if(mi.Id() == m_lparam) 
      {
        // --- ...in case its context menu is without focus, hide it
        if(!cm.MouseFocus()) {
          cm.Hide();
          mi.IsPressed(false);
          mi.Update(true);
        }
        // --- Let's complete the cycle
        break;
      } else 
      {
        cm.Hide();
        mi.IsPressed(false);
        mi.Update(true);
      }
    }
    return(true);
   }
  //+------------------------------------------------------------------+
  // | Event for hiding all context menus |
  //+------------------------------------------------------------------+
  bool CWndEvents::OnHideContextMenus(void) 
   {
    // --- If the signal is to hide all context menus
    if(m_id != CHARTEVENT_CUSTOM + ON_HIDE_CONTEXTMENUS)
      return(false);
    // --- Hide all context menus
    int awi = m_active_window_index;
    int cm_total = CWndContainer::ElementsTotal(awi, E_CONTEXT_MENU);
    for(int i = 0; i < cm_total; i++) 
    {
      m_wnd[awi].m_context_menus[i].Hide();
      //---
      if(CheckPointer(m_wnd[awi].m_context_menus[i].PrevNodePointer()) != POINTER_INVALID) {
        CMenuItem *mi = m_wnd[awi].m_context_menus[i].PrevNodePointer();
        mi.IsPressed(false);
        mi.Update(true);
      }
    }
    // ---Disable main menus
    int menu_bars_total = CWndContainer::ElementsTotal(awi, E_MENU_BAR);
    for(int i = 0; i < menu_bars_total; i++)
      m_wnd[awi].m_menu_bars[i].State(false);
    //---
    return(true);
   }
  //+------------------------------------------------------------------+
  //| Dialog box open event |
  //+------------------------------------------------------------------+
  bool CWndEvents::OnOpenDialogBox(void) 
   {
    // --- If the signal to open the dialog box
      if(m_id != CHARTEVENT_CUSTOM + ON_OPEN_DIALOG_BOX)
        return(false);
    // --- Exit if the message is from another program
      if(m_sparam != m_program_name)
        return(true);
    // --- Let's go through the array of windows
      int window_total = CWndContainer::WindowsTotal();
      for(int w = 0; w < window_total; w++) 
      {
        // --- If the ID of the open window
        if(m_windows[w].Id() == m_lparam) {
          // --- Let's remember in this form the index of the window from which it was called
          m_windows[w].PrevActiveWindowIndex(m_active_window_index);
          // --- Activate the form
          m_windows[w].State(true);
          // --- Let's restore the priorities of the form objects when clicking the left mouse button
          m_windows[w].SetZorders();
          // --- Remember the index of the activated window
          m_active_window_index = w;
          // --- Show window
          Show(m_active_window_index);
        }
        // --- Other forms will be blocked until the activated window is closed
        else {
          // --- Lock the form
          m_windows[w].State(false);
          // --- Reset the priorities of form elements when clicking the left mouse button
          int elements_total = CWndContainer::ElementsTotal(w);
          for(int e = 0; e < elements_total; e++)
            m_wnd[w].m_elements[e].ResetZorders();
        }
      }
    // --- Hiding tooltips in the previous window
      int prev_window_index = m_windows[m_active_window_index].PrevActiveWindowIndex();
      int tooltips_total = CWndContainer::ElementsTotal(prev_window_index, E_TOOLTIP);
      for(int t = 0; t < tooltips_total; t++)
        m_wnd[prev_window_index].m_tooltips[t].FadeOutTooltip();
    // --- Show items in selected tabs only
      ShowTabElements(m_active_window_index);
    // --- Let's create an array of visible and accessible elements
      FormAvailableElementsArray();
    // --- Restoring priorities for left-clicking on an activated window
      SetZorders();
    // ---Move tooltips to top layer
      ResetTooltips();
      return(true);
   }
  //+------------------------------------------------------------------+
  // | Dialog box close event |
  //+------------------------------------------------------------------+
  bool CWndEvents::OnCloseDialogBox(void) 
   {
    // --- If the signal to close the dialog box
      if(m_id != CHARTEVENT_CUSTOM + ON_CLOSE_DIALOG_BOX)
        return(false);
    // --- Let's walk through the array of windows
      int window_total = CWndContainer::WindowsTotal();
      for(int w = 0; w < window_total; w++) {
        // --- If the ID of the open window
        if(m_windows[w].Id() == m_lparam) {
          // --- Lock the form
          m_windows[w].State(false);
          // --- Hide the form
          int elements_total = CWndContainer::ElementsTotal(w);
          for(int e = 0; e < elements_total; e++)
            m_wnd[w].m_elements[e].Hide();
          // --- Activate the previous form
          m_windows[int(m_dparam)].State(true);
          // --- Redrawing the graph
          m_chart.Redraw();
          break;
        }
      }
    // --- Setting the index of the previous window
      m_active_window_index = int(m_dparam);
    // --- Restoring priorities for left-clicking on an activated window
      SetZorders();
      return(true);
   }
  //+------------------------------------------------------------------+
  // | Event to determine available controls |
  //+------------------------------------------------------------------+
  bool CWndEvents::OnSetAvailable(void) 
   {
    // --- If the signal indicates a change in the availability of elements
      if(m_id != CHARTEVENT_CUSTOM + ON_SET_AVAILABLE)
        return(false);
    // --- Signal to install/restore
      bool is_restore = (bool)m_dparam;
    // --- Define active elements
      int ww_index = ActivatedWindowIndex();
      int mb_index = ActivatedMenuBarIndex();
      int mi_index = ActivatedMenuItemIndex();
      int sb_index = ActivatedSplitButtonIndex();
      int cb_index = ActivatedComboBoxIndex();
      int dc_index = ActivatedDropCalendarIndex();
      int sc_index = ActivatedScrollIndex();
      int tl_index = ActivatedTableIndex();
      int sd_index = ActivatedSliderIndex();
      int tv_index = ActivatedTreeViewIndex();
      int ch_index = ActivatedSubChartIndex();
    // --- If the signal is to determine available elements, first disable access
      if(!is_restore)
        SetAvailable(m_active_window_index, false);
    // --- We restore only if there are no activated elements
      else {
        if(ww_index == WRONG_VALUE && mb_index == WRONG_VALUE && mi_index == WRONG_VALUE &&
            sb_index == WRONG_VALUE && dc_index == WRONG_VALUE && cb_index == WRONG_VALUE &&
            sc_index == WRONG_VALUE && tl_index == WRONG_VALUE && sd_index == WRONG_VALUE &&
            tv_index == WRONG_VALUE && ch_index == WRONG_VALUE) {
          SetAvailable(m_active_window_index, true);
          return(true);
        }
      }
    // --- If (1) a signal to determine available items or (2) to restore for a drop-down calendar
      if(!is_restore || (is_restore && dc_index != WRONG_VALUE)) {
        CElement *el = NULL;
        // --- Window
        if(ww_index != WRONG_VALUE) {
          el = m_windows[m_active_window_index];
        }
        // --- Main menu
        else if(mb_index != WRONG_VALUE) {
          el = m_wnd[m_active_window_index].m_menu_bars[mb_index];
        }
        // --- Menu item
        else if(mi_index != WRONG_VALUE) {
          el = m_wnd[m_active_window_index].m_menu_items[mi_index];
        }
        // --- Double button
        else if(sb_index != WRONG_VALUE) {
          el = m_wnd[m_active_window_index].m_split_buttons[sb_index];
        }
        // --- Dropdown calendar without dropdown list
        else if(dc_index != WRONG_VALUE && cb_index == WRONG_VALUE) {
          el = m_wnd[m_active_window_index].m_drop_calendars[dc_index];
        }
        // --- Dropdown list
        else if(cb_index != WRONG_VALUE) {
          el = m_wnd[m_active_window_index].m_combo_boxes[cb_index];
        }
        // --- Scroll bar
        else if(sc_index != WRONG_VALUE) {
          el = m_wnd[m_active_window_index].m_scrolls[sc_index];
        }
        // --- Table
        else if(tl_index != WRONG_VALUE) {
          el = m_wnd[m_active_window_index].m_tables[tl_index];
        }
        // --- Slider
        else if(sd_index != WRONG_VALUE) {
          el = m_wnd[m_active_window_index].m_sliders[sd_index];
        }
        // --- Tree list
        else if(tv_index != WRONG_VALUE) {
          el = m_wnd[m_active_window_index].m_treeview_lists[tv_index];
        }
        // --- Standard schedule
        else if(ch_index != WRONG_VALUE) {
          el = m_wnd[m_active_window_index].m_sub_charts[ch_index];
        }
        // --- Exit if element pointer not obtained
        if(::CheckPointer(el) == POINTER_INVALID) 
        {
          return(true);
        }
        // --- Block for the main menu
        if(mb_index != WRONG_VALUE) 
        {
          // --- Make the main menu and its visible context menus available
          el.IsAvailable(true);
          //---
          CMenuBar *mb = dynamic_cast<CMenuBar*>(el);
          int items_total = mb.ItemsTotal();
          for(int i = 0; i < items_total; i++) {
            CMenuItem *mi = mb.GetItemPointer(i);
            mi.IsAvailable(true);
            // --- Checks and makes the context menu available
            CheckContextMenu(mi);
          }
        }
        // --- Block for menu item
        if(mi_index != WRONG_VALUE) 
        {
          CMenuItem *mi = dynamic_cast<CMenuItem*>(el);
          mi.IsAvailable(true);
          // --- Checks and makes the context menu available
          CheckContextMenu(mi);
        }
        // --- Block for scroll bars
        else if(sc_index != WRONG_VALUE) 
        {
          // ---Make accessible starting from the main node
          el.MainPointer().IsAvailable(true);
        }
        // --- Block for tree list
        else if(tv_index != WRONG_VALUE) 
        {
          // --- Lock all elements except the main one
          CTreeView *tv = dynamic_cast<CTreeView*>(el);
          tv.IsAvailable(true, true);
          int total = tv.ElementsTotal();
          for(int i = 0; i < total; i++)
            tv.Element(i).IsAvailable(false);
        } else 
        {
          // --- Make element available
          el.IsAvailable(true);
        }
      }
    //---
      return(true);
   }
  //+------------------------------------------------------------------+
  // | Event ON_SET_LOCKED |
  //+------------------------------------------------------------------+
  bool CWndEvents::OnSetLocked(void) 
   {
    // --- If the signal indicates blocking of elements
      if(m_id != CHARTEVENT_CUSTOM + ON_SET_LOCKED)
        return(false);
    //---
      bool find_flag = false;
    //---
    int elements_total = CWndContainer::MainElementsTotal(m_active_window_index);
    for(int e = 0; e < elements_total; e++) 
    {
      CElement *el = m_wnd[m_active_window_index].m_main_elements[e];
      //---
      if(m_lparam != el.Id()) {
        if(find_flag)
          break;
        //---
        continue;
      }
      //---
      find_flag = true;
      //---
      int total = el.ElementsTotal();
      for(int i = 0; i < total; i++)
        el.Element(i).Update(true);
      //---
      el.Update(true);
    }
    return(true);
   }
  //+------------------------------------------------------------------+
  //| GUI Change Event                                                 |
  //+------------------------------------------------------------------+
  bool CWndEvents::OnChangeGUI(void) 
   {
    // --- If the change signal in the GUI
      if(m_id != CHARTEVENT_CUSTOM + ON_CHANGE_GUI)
        return(false);
    // --- Let's create an array of visible and accessible elements
      FormAvailableElementsArray();
    // ---Move tooltips to top layer
      ResetTooltips();
    // --- Redraw the graph
      m_chart.Redraw();
      return(true);
   }
  //+------------------------------------------------------------------+
  //| Returns the index of the activated window                        |
  //+------------------------------------------------------------------+
  int CWndEvents::ActivatedWindowIndex(void) 
   {
    int index = WRONG_VALUE;
    //---
    int total = WindowsTotal();
    for(int i = 0; i < total; i++) {
      if(m_windows[i].ResizeState()) {
        index = i;
        break;
      }
    }
    return(index);
   }
  //+------------------------------------------------------------------+
  //| Returns the index of the activated main menu                     |
  //+------------------------------------------------------------------+
  int CWndEvents::ActivatedMenuBarIndex(void) 
   {
      int index = WRONG_VALUE;
    //---
      int total = ElementsTotal(m_active_window_index, E_MENU_BAR);
      for(int i = 0; i < total; i++) {
        CMenuBar *el = m_wnd[m_active_window_index].m_menu_bars[i];
        if(el.State()) {
          index = i;
          break;
        }
      }
      return(index);
   }
  //+------------------------------------------------------------------+
  //| Returns the index of the activated menu item                     |
  //+------------------------------------------------------------------+
  int CWndEvents::ActivatedMenuItemIndex(void) 
   {
    int index = WRONG_VALUE;
    //---
    int total = ElementsTotal(m_active_window_index, E_MENU_ITEM);
    for(int i = 0; i < total; i++) {
      CMenuItem *el = m_wnd[m_active_window_index].m_menu_items[i];
      if(el.GetContextMenuPointer().IsVisible()) {
        index = i;
        break;
      }
    }
    return(index);
   }
  //+------------------------------------------------------------------+
  // | Returns the index of the activated double button |
  //+------------------------------------------------------------------+
  int CWndEvents::ActivatedSplitButtonIndex(void) 
   {
    int index = WRONG_VALUE;
    //---
    int total = ElementsTotal(m_active_window_index, E_SPLIT_BUTTON);
    for(int i = 0; i < total; i++) {
      CSplitButton *el = m_wnd[m_active_window_index].m_split_buttons[i];
      if(el.GetContextMenuPointer().IsVisible()) {
        index = i;
        break;
      }
    }
    return(index);
   }
  //+------------------------------------------------------------------+
  //| Returns the index of the activated combo box                     |
  //+------------------------------------------------------------------+
  int CWndEvents::ActivatedComboBoxIndex(void) 
   {
    int index = WRONG_VALUE;
    //---
    int total = ElementsTotal(m_active_window_index, E_COMBO_BOX);
    for(int i = 0; i < total; i++) {
      CComboBox *el = m_wnd[m_active_window_index].m_combo_boxes[i];
      if(el.GetListViewPointer().IsVisible()) {
        index = i;
        break;
      }
    }
    return(index);
   }
  //+------------------------------------------------------------------+
  // | Returns the index of the activated dropdown calendar |
  //+------------------------------------------------------------------+
  int CWndEvents::ActivatedDropCalendarIndex(void) 
   {
      int index = WRONG_VALUE;
    //---
      int total = ElementsTotal(m_active_window_index, E_DROP_CALENDAR);
      for(int i = 0; i < total; i++) {
        CDropCalendar *el = m_wnd[m_active_window_index].m_drop_calendars[i];
        if(el.GetCalendarPointer().IsVisible()) {
          index = i;
          break;
        }
      }
      return(index);
   }
  //+------------------------------------------------------------------+
  // | Returns the index of the activated scrollbar |
  //+------------------------------------------------------------------+
  int CWndEvents::ActivatedScrollIndex(void) 
   {
    int index = WRONG_VALUE;
    //---
    int total = ElementsTotal(m_active_window_index, E_SCROLL);
    for(int i = 0; i < total; i++) {
      CScroll *el = m_wnd[m_active_window_index].m_scrolls[i];
      if(el.State()) {
        index = i;
        break;
      }
    }
    return(index);
   }
  //+------------------------------------------------------------------+
  // | Returns the index of the activated table |
  //+------------------------------------------------------------------+
  int CWndEvents::ActivatedTableIndex(void) 
   {
    int index = WRONG_VALUE;
    //---
    int total = ElementsTotal(m_active_window_index, E_TABLE);
    for(int i = 0; i < total; i++) {
      CTable *el = m_wnd[m_active_window_index].m_tables[i];
      if(el.ColumnResizeControl()) {
        index = i;
        break;
      }
    }
    return(index);
   }
  //+------------------------------------------------------------------+
  // | Returns the index of the activated slider |
  //+------------------------------------------------------------------+
  int CWndEvents::ActivatedSliderIndex(void) 
   {
    int index = WRONG_VALUE;
    //---
    int total = ElementsTotal(m_active_window_index, E_SLIDER);
    for(int i = 0; i < total; i++) {
      CSlider *el = m_wnd[m_active_window_index].m_sliders[i];
      if(el.State()) {
        index = i;
        break;
      }
    }
    return(index);
   }
  //+------------------------------------------------------------------+
  //| Returns the index of the activated tree list |
  //+------------------------------------------------------------------+
  int CWndEvents::ActivatedTreeViewIndex(void) 
   {
      int index = WRONG_VALUE;
    //---
      int total = ElementsTotal(m_active_window_index, E_TREE_VIEW);
      for(int i = 0; i < total; i++) {
        CTreeView *el = m_wnd[m_active_window_index].m_treeview_lists[i];
        // ---Go to next if tab mode is enabled
        if(el.TabItemsMode())
          continue;
        // --- If the process of changing the width of lists
        if(el.GetMousePointer().State()) {
          index = i;
          break;
        }
      }
      return(index);
   }
  //+------------------------------------------------------------------+
  // | Returns the index of the activated standard chart |
  //+------------------------------------------------------------------+
  int CWndEvents::ActivatedSubChartIndex(void) 
   {
    int index = WRONG_VALUE;
    //---
      int total = ElementsTotal(m_active_window_index, E_SUB_CHART);
      for(int i = 0; i < total; i++) {
        CStandardChart *el = m_wnd[m_active_window_index].m_sub_charts[i];
        if(el.GetMousePointer().IsVisible()) {
          index = i;
          break;
        }
      }
    return(index);
   }
  //+------------------------------------------------------------------+
  //| Recursively checks and makes context menus available             |
  //+------------------------------------------------------------------+
  void CWndEvents::CheckContextMenu(CMenuItem &object) 
   {
    // --- Get the context menu pointer
      CContextMenu *cm = object.GetContextMenuPointer();
    // --- Exit if there is no context menu in the item
      if(::CheckPointer(cm) == POINTER_INVALID)
        return;
    // --- Quit if the context menu is there but hidden
      if(!cm.IsVisible())
        return;
    // --- Set the attributes of an accessible element
      cm.IsAvailable(true);
    //---
    int items_total = cm.ItemsTotal();
    for(int i = 0; i < items_total; i++) 
    {
      // --- Set the attributes of an accessible element
      CMenuItem *mi = cm.GetItemPointer(i);
      mi.IsAvailable(true);
      // --- Let's check if this item has a context menu
      CheckContextMenu(mi);
    }
   }
  //+------------------------------------------------------------------+
  //| Moving a window                                                  |
  //+------------------------------------------------------------------+
  void CWndEvents::MovingWindow(const bool moving_mode = false) 
   {
    // --- If control is transferred to the window, determine its position
    if(!moving_mode)
      if(m_windows[m_active_window_index].ClampingAreaMouse() != PRESSED_INSIDE_HEADER)
        return;
    // --- Moving the window
      int x = m_windows[m_active_window_index].X();
      int y = m_windows[m_active_window_index].Y();
      m_windows[m_active_window_index].Moving(x, y);
    // ---Moving controls
    int main_total = MainElementsTotal(m_active_window_index);
    for(int e = 0; e < main_total; e++) 
    {
      CElement *el = m_wnd[m_active_window_index].m_main_elements[e];
      el.Moving();
    }
   }
  //+------------------------------------------------------------------+
  // | Checking events of all elements using a timer |
  //+------------------------------------------------------------------+
  void CWndEvents::CheckElementsEventsTimer(void) 
   {
    int awi = m_active_window_index;
    int timer_elements_total = CWndContainer::TimerElementsTotal(awi);
    for(int e = 0; e < timer_elements_total; e++) {
      CElement *el = m_wnd[awi].m_timer_elements[e];
      if(el.IsVisible())
        el.OnEventTimer();
    }
   }
  //+------------------------------------------------------------------+
  //| Determining the subwindow number                                 |
  //+------------------------------------------------------------------+
  void CWndEvents::DetermineSubwindow(void) 
   {
    // --- Exit if the program type is "Script"
    if(PROGRAM_TYPE == PROGRAM_SCRIPT)
      return;
    // --- Reset last error
    ::ResetLastError();
    // --- If the program type is expert
    if(PROGRAM_TYPE == PROGRAM_EXPERT) 
    {
      // --- Exit if the expert graphical interface is needed in the main window
      if(!EXPERT_IN_SUBWINDOW)
        return;
      // --- Get the handle of the dummy indicator (empty window)
      m_subwindow_handle = iCustom(::Symbol(), ::Period(), "::Indicators\\SubWindow.ex5");
      // --- If there is no such indicator, report the error to the log
      if(m_subwindow_handle == INVALID_HANDLE)
        ::Print(__FUNCTION__, " > Ошибка при получении хэндла индикатора в директории ::Indicators\\SubWindow.ex5 !");
      // --- If the handle is received, then the indicator exists and is connected to the application as a resource,
      // which means that the application's graphical interface needs to be placed in a subwindow
      else 
      {
        // --- Get the number of subwindows on the chart
        int subwindows_total = (int)::ChartGetInteger(m_chart_id, CHART_WINDOWS_TOTAL);
        // --- Install a subwindow for the expert's graphical interface
        if(::ChartIndicatorAdd(m_chart_id, subwindows_total, m_subwindow_handle)) {
          // --- Save the subwindow number and the current number of subwindows on the chart
          m_subwin           = subwindows_total;
          m_subwindows_total = subwindows_total + 1;
          // --- Get and save the short name of the expert subwindow
          m_subwindow_shortname =::ChartIndicatorName(m_chart_id, m_subwin, 0);
        }
        // --- If the subwindow is not installed
        else
          ::Print(__FUNCTION__, " > Ошибка при установке подокна эксперта! Номер ошибки: ", ::GetLastError());
      }
      //---
      return;
    }
    // --- Determining the indicator window number
     m_subwin =::ChartWindowFind();
    // --- If we couldn’t determine the number, we’ll leave
    if(m_subwin < 0) 
    {
      ::Print(__FUNCTION__, " > Ошибка при определении номера подокна: ", ::GetLastError());
      return;
    }
    // --- If this is not the main chart window
    if(m_subwin > 0) 
    {
      // --- Get the total number of indicators in the specified subwindow
      int total =::ChartIndicatorsTotal(m_chart_id, m_subwin);
      // --- Get the short name of the last indicator in the list
      string indicator_name =::ChartIndicatorName(m_chart_id, m_subwin, total - 1);
      // --- If there is already an indicator in the subwindow, then remove the program from the chart
      if(total != 1) {
        ::Print(__FUNCTION__, " > В этом подокне уже есть индикатор.");
        ::ChartIndicatorDelete(m_chart_id, m_subwin, indicator_name);
        return;
      }
    }
   }
  //+------------------------------------------------------------------+
  // | Removes the Expert Advisor subwindow |
  //+------------------------------------------------------------------+
  void CWndEvents::DeleteExpertSubwindow(void) 
   {
    // --- Quit if this is not an expert
      if(PROGRAM_TYPE != PROGRAM_EXPERT)
        return;
    // --- Exit if handle is invalid
      if(m_subwindow_handle == INVALID_HANDLE)
        return;
    // --- Get the number of windows on the chart
      int windows_total = (int)::ChartGetInteger(m_chart_id, CHART_WINDOWS_TOTAL);
    // --- Let's find the expert subwindow
    for(int w = 0; w < windows_total; w++) 
    {
      // --- Get the short name of the Expert Advisor subwindow (indicator SubWindow.ex5)
      string indicator_name =::ChartIndicatorName(m_chart_id, w, 0);
      // ---Go to next if this is not an Expert Advisor subwindow
      if(indicator_name != m_subwindow_shortname || w != m_subwin)
        continue;
      // --- Delete Expert Advisor subwindow
      if(!::ChartIndicatorDelete(m_chart_id, m_subwin, indicator_name))
        ::Print(__FUNCTION__, " > Ошибка при удалении подокна эксперта! Номер ошибки: ", ::GetLastError());
    }
   }
  //+------------------------------------------------------------------+
  //| Checking and updating the expert window number                   |
  //+------------------------------------------------------------------+
  void CWndEvents::CheckExpertSubwindowNumber(void) 
   {
    // --- Exit if (1) it is not an Expert Advisor or (2) the Expert Advisor GUI is in the main window
      if(PROGRAM_TYPE != PROGRAM_EXPERT || !EXPERT_IN_SUBWINDOW)
        return;
    // --- Get the number of subwindows on the chart
      int subwindows_total = (int)::ChartGetInteger(m_chart_id, CHART_WINDOWS_TOTAL);
    // --- Exit if the number of subwindows and the number of indicators have not changed
      if(subwindows_total == m_subwindows_total)
        return;
    // --- Save the current number of sills
      m_subwindows_total = subwindows_total;
    // --- To check the presence of the Expert Advisor subwindow
      bool is_subwindow = false;
    // --- Let's find the expert subwindow
    for(int sw = 0; sw < subwindows_total; sw++) 
    {
      // --- Stop the cycle if there is an Expert Advisor subwindow
      if(is_subwindow)
        break;
      // --- How many indicators are in this window/subwindow
      int indicators_total =::ChartIndicatorsTotal(m_chart_id, sw);
      // --- Let's go through all the indicators in the window
      for(int i = 0; i < indicators_total; i++) 
      {
        // --- Get the short name of the indicator
        string indicator_name =::ChartIndicatorName(m_chart_id, sw, i);
        // --- If this is not an Expert Advisor subwindow, go to the next one
        if(indicator_name != m_subwindow_shortname)
          continue;
        // --- Note that there is an Expert Advisor subwindow
        is_subwindow = true;
        // --- If the subwindow number has changed, then
        // you need to save the new number in all elements of the main form
        if(sw != m_subwin) {
          // --- Save the subwindow number
          m_subwin = sw;
          // --- Let's also save it in all elements of the main interface form
          int elements_total = CWndContainer::ElementsTotal(0);
          for(int e = 0; e < elements_total; e++)
            m_wnd[0].m_elements[e].SubwindowNumber(m_subwin);
        }
        //---
        break;
      }
    }
    // --- If the expert subwindow is not found, delete the expert
    if(!is_subwindow) 
    {
      ::Print(__FUNCTION__, " > Удаление подокна эксперта приводит к удалению эксперта!");
      // --- Removing an expert from the chart
      ::ExpertRemove();
    }
   }
  //+------------------------------------------------------------------+
  //| Checking and updating the program window number                  |
  //+------------------------------------------------------------------+
  void CWndEvents::CheckSubwindowNumber(void) 
   {
    // --- Quit if this is not an indicator
    if(PROGRAM_TYPE != PROGRAM_INDICATOR)
      return;
    // --- If the program in the subwindow and the numbers do not match
    if(m_subwin != 0 && m_subwin !=::ChartWindowFind()) {
      // --- Define subwindow number
      DetermineSubwindow();
      // --- Save in all elements
      int windows_total = CWndContainer::WindowsTotal();
      for(int w = 0; w < windows_total; w++) {
        int elements_total = CWndContainer::ElementsTotal(w);
        for(int e = 0; e < elements_total; e++)
          m_wnd[w].m_elements[e].SubwindowNumber(m_subwin);
      }
    }
   }
  //+------------------------------------------------------------------+
  //| Resizing a locked main window                                    |
  //+------------------------------------------------------------------+
  void CWndEvents::ResizeLockedWindow(void) 
   {
    // --- Save in all elements
     int windows_total = CWndContainer::WindowsTotal();
    // --- Quit if the interface is not created
     if(windows_total < 1)
       return;
    // --- Resize all locked form elements if one of the modes is enabled
    if(m_windows[0].CElementBase::IsLocked() && (m_windows[0].AutoXResizeMode() || m_windows[0].AutoXResizeMode())) 
    {
      int elements_total = CWndContainer::ElementsTotal(0);
      for(int e = 0; e < elements_total; e++) 
      {
        CElement *el = m_wnd[0].m_elements[e];
        // ---If this is a form
        if(dynamic_cast<CWindow*>(el) != NULL) {
          el.OnEvent(m_id, m_lparam, m_dparam, m_sparam);
          continue;
        }
        // --- Change the width of elements where this mode is enabled
        if(el.AutoXResizeMode())
          el.ChangeWidthByRightWindowSide();
        // --- Change the width of elements where this mode is enabled
        if(el.AutoYResizeMode())
          el.ChangeHeightByBottomWindowSide();
        // --- Update object position
        el.Moving();
      }
      // --- Update (save) the chart properties of other forms
      for(int w = 1; w < windows_total; w++)
        m_windows[w].SetWindowProperties();
      // ---Redraw the activated window
      ResetWindow();
      // --- Update
      Update();
    }
   }
  //+------------------------------------------------------------------+
  //| Redrawing the window                                             |
  //+------------------------------------------------------------------+
  void CWndEvents::ResetWindow(void) 
   {
    // --- Exit if there are no windows yet
      if(CWndContainer::WindowsTotal() < 1)
        return;
    // --- Redrawing the window and its elements
      Hide();
      Show(m_active_window_index);
   }
  //+------------------------------------------------------------------+
  // | Removing all objects |
  //+------------------------------------------------------------------+
  void CWndEvents::Destroy(void) 
   {
    // --- Set the index of the main window
    m_active_window_index = 0;
    // --- Get the number of windows
    int window_total = CWndContainer::WindowsTotal();
    // --- Let's walk through the array of windows
    for(int w = 0; w < window_total; w++) 
    {
      // --- Activate the main window
      if(m_windows[w].WindowType() == W_MAIN)
        m_windows[w].State(true);
      // --- Lock dialog boxes
      else
        m_windows[w].State(false);
    }
    // --- Free the arrays of elements
    for(int w = 0; w < window_total; w++) 
    {
      int elements_total = CWndContainer::ElementsTotal(w);
      for(int e = 0; e < elements_total; e++) {
        // --- If the pointer is invalid, go to the next one
        if(::CheckPointer(m_wnd[w].m_elements[e]) == POINTER_INVALID)
          continue;
        // --- Delete element objects
        m_wnd[w].m_elements[e].Delete();
        m_wnd[w].m_elements[e].Id(WRONG_VALUE);
      }
      // --- Free element arrays
      ::ArrayFree(m_wnd[w].m_elements);
      ::ArrayFree(m_wnd[w].m_main_elements);
      ::ArrayFree(m_wnd[w].m_timer_elements);
      ::ArrayFree(m_wnd[w].m_auto_x_resize_elements);
      ::ArrayFree(m_wnd[w].m_auto_y_resize_elements);
      ::ArrayFree(m_wnd[w].m_available_elements);
      ::ArrayFree(m_wnd[w].m_menu_bars);
      ::ArrayFree(m_wnd[w].m_menu_items);
      ::ArrayFree(m_wnd[w].m_context_menus);
      ::ArrayFree(m_wnd[w].m_combo_boxes);
      ::ArrayFree(m_wnd[w].m_split_buttons);
      ::ArrayFree(m_wnd[w].m_drop_lists);
      ::ArrayFree(m_wnd[w].m_scrolls);
      ::ArrayFree(m_wnd[w].m_tables);
      ::ArrayFree(m_wnd[w].m_tabs);
      ::ArrayFree(m_wnd[w].m_calendars);
      ::ArrayFree(m_wnd[w].m_drop_calendars);
      ::ArrayFree(m_wnd[w].m_sub_charts);
      ::ArrayFree(m_wnd[w].m_pictures_slider);
      ::ArrayFree(m_wnd[w].m_time_edits);
      ::ArrayFree(m_wnd[w].m_text_boxes);
      ::ArrayFree(m_wnd[w].m_tooltips);
      ::ArrayFree(m_wnd[w].m_treeview_lists);
      ::ArrayFree(m_wnd[w].m_file_navigators);
      ::ArrayFree(m_wnd[w].m_frames);
    }
    // --- Free up form arrays
      ::ArrayFree(m_wnd);
      ::ArrayFree(m_windows);
   }
  //+------------------------------------------------------------------+
  //| Completing the GUI creation                                      |
  //+------------------------------------------------------------------+
  void CWndEvents::CompletedGUI(void) 
   {
    // --- Exit if there are no windows yet
      int windows_total = CWndContainer::WindowsTotal();
      if(windows_total < 1) {
        return;
      }
    // --- Show a comment informing the user
      ::Comment("Update. Please wait...");
    // --- Hide elements
      Hide();
    // --- Draw elements
      Update(true);
    // --- Show elements of the activated window
      Show(m_active_window_index);
    // --- Let's create an array of elements with a timer
      FormTimerElementsArray();
    // --- Let's create an array of visible and accessible elements
      FormAvailableElementsArray();
    // --- Let's create arrays of elements with auto-resize
      FormAutoXResizeElementsArray();
      FormAutoYResizeElementsArray();
    // --- Redraw the graph
      m_chart.Redraw();
    // --- Clear comment
      ::Comment("");
    // --- Send the GUI creation completion event
      ::EventChartCustom(m_chart_id, ON_END_CREATE_GUI, 0, 0.0, "");
      
      //CWndEvents::PrintContainer();
   }
  //+------------------------------------------------------------------+
  //| Moving elements                                                  |
  //+------------------------------------------------------------------+
  void CWndEvents::Moving(void) 
   {
    // --- Update element position
    int main_total = MainElementsTotal(m_active_window_index);
    for(int e = 0; e < main_total; e++) {
      CElement *el = m_wnd[m_active_window_index].m_main_elements[e];
      el.Moving(false);
    }
   }
  //+------------------------------------------------------------------+
  //| Hiding elements                                                  |
  //+------------------------------------------------------------------+
  void CWndEvents::Hide(void) 
   {
    int windows_total = CWndContainer::WindowsTotal();
    for(int w = 0; w < windows_total; w++) {
      m_windows[w].Hide();
      int main_total = MainElementsTotal(w);
      for(int e = 0; e < main_total; e++) {
        CElement *el = m_wnd[w].m_main_elements[e];
        el.Hide();
      }
    }
   }
  //+------------------------------------------------------------------+
  //| Show elements of the specified window                            |
  //+------------------------------------------------------------------+
  void CWndEvents::Show(const uint window_index) 
   {
    // --- Show elements of the specified window
    m_windows[window_index].Show();
    // --- If the window is not minimized
    if(!m_windows[window_index].IsMinimized()) {
      int main_total = MainElementsTotal(window_index);
      for(int e = 0; e < main_total; e++) {
        CElement *el = m_wnd[window_index].m_main_elements[e];
        // --- Show an element if it is (1) not a dropdown and (2) its main element is not a tab
        if(!el.IsDropdown() && dynamic_cast<CTabs*>(el.MainPointer()) == NULL)
          el.Show();
      }
      // --- Show items in selected tabs only
      ShowTabElements(window_index);
    }
   }
  //+------------------------------------------------------------------+
  // | Restoring left-click priorities |
  // | at the active window |
  //+------------------------------------------------------------------+
  void CWndEvents::SetZorders(void) 
   {
    int elements_total = CWndContainer::ElementsTotal(m_active_window_index);
    for(int e = 0; e < elements_total; e++) {
      CElement *el = m_wnd[m_active_window_index].m_elements[e];
      //---
      if(el.ClassName() != "CGraph")
        el.SetZorders();
      else {
        CGraph *graph = dynamic_cast<CGraph*>(el);
        graph.SetZorders();
      }
    }
   }
  //+------------------------------------------------------------------+
  // | Redrawing elements |
  //+------------------------------------------------------------------+
  void CWndEvents::Update(const bool redraw = false) 
   {
    int windows_total = CWndContainer::WindowsTotal();
    for(int w = 0; w < windows_total; w++) {
      // --- Redrawing elements
      int elements_total = CWndContainer::ElementsTotal(w);
      for(int e = 0; e < elements_total; e++) {
        CElement *el = m_wnd[w].m_elements[e];
        el.Update(redraw);
      }
    }
   }
  //+------------------------------------------------------------------+
  //| Moves tooltips to the top layer                                  |
  //+------------------------------------------------------------------+
  void CWndEvents::ResetTooltips(void) 
   {
    // ---Move tooltips to top layer
    int window_total = CWndContainer::WindowsTotal();
    for(int w = 0; w < window_total; w++) {
      int tooltips_total = CWndContainer::ElementsTotal(w, E_TOOLTIP);
      for(int t = 0; t < tooltips_total; t++)
        m_wnd[w].m_tooltips[t].Reset();
    }
   }
  //+------------------------------------------------------------------+
  //| Sets the availability state of elements                          |
  //+------------------------------------------------------------------+
  void CWndEvents::SetAvailable(const uint window_index, const bool state) 
   {
    // --- Get the number of main elements
      int main_total = MainElementsTotal(window_index);
    // --- If you need to make elements inaccessible
    if(!state) 
    {
      m_windows[window_index].IsAvailable(state);
      for(int e = 0; e < main_total; e++) {
        CElement *el = m_wnd[window_index].m_main_elements[e];
        el.IsAvailable(state);
      }
    } 
    else 
    {
      m_windows[window_index].IsAvailable(state);
      for(int e = 0; e < main_total; e++) 
       {
        CElement *el = m_wnd[window_index].m_main_elements[e];
        // --- If it is a tree list
        if(dynamic_cast<CTreeView*>(el) != NULL) {
          CTreeView *tv = dynamic_cast<CTreeView*>(el);
          tv.IsAvailable(true);
          continue;
        }
        // --- If this is a file navigator
        if(dynamic_cast<CFileNavigator*>(el) != NULL) {
          CFileNavigator *fn = dynamic_cast<CFileNavigator*>(el);
          CTreeView      *tv = fn.GetTreeViewPointer();
          fn.IsAvailable(state);
          tv.IsAvailable(state);
          continue;
        }
        // --- Make element available
        el.IsAvailable(state);
       }
    }
   }
  //+------------------------------------------------------------------+
  //| Shows items in selected tabs only                                |
  //+------------------------------------------------------------------+
  void CWndEvents::ShowTabElements(const uint window_index) 
   {
    // --- Simple Tabs
      int tabs_total = CWndContainer::ElementsTotal(window_index, E_TABS);
      for(int t = 0; t < tabs_total; t++) {
        CTabs *el = m_wnd[window_index].m_tabs[t];
        if(el.IsVisible())
          el.ShowTabElements();
      }
    // --- Tree List Tabs
    int treeview_total = CWndContainer::ElementsTotal(window_index, E_TREE_VIEW);
    for(int tv = 0; tv < treeview_total; tv++)
      m_wnd[window_index].m_treeview_lists[tv].ShowTabElements();
   }
  //+------------------------------------------------------------------+
  // | Forms an array of elements with a timer |
  //+------------------------------------------------------------------+
  void CWndEvents::FormTimerElementsArray(void) 
   {
    int windows_total = CWndContainer::WindowsTotal();
    for(int w = 0; w < windows_total; w++) {
      int elements_total = CWndContainer::ElementsTotal(w);
      for(int e = 0; e < elements_total; e++) {
        CElement *el = m_wnd[w].m_elements[e];
        //---
        if(dynamic_cast<CCalendar    *>(el) != NULL ||
            dynamic_cast<CColorPicker *>(el) != NULL ||
            dynamic_cast<CListView    *>(el) != NULL ||
            dynamic_cast<CTable       *>(el) != NULL ||
            dynamic_cast<CTextBox     *>(el) != NULL ||
            dynamic_cast<CTextEdit    *>(el) != NULL ||
            dynamic_cast<CTreeView    *>(el) != NULL) {
          CWndContainer::AddTimerElement(w, el);
        }
      }
    }
   }
  //+------------------------------------------------------------------+
  //| Forms an array of available elements                             |
  //+------------------------------------------------------------------+
  void CWndEvents::FormAvailableElementsArray(void) 
   {
    // --- Window index
      int awi = m_active_window_index;
    // --- Total number of elements
      int elements_total = CWndContainer::ElementsTotal(awi);
    // --- Clear the array
      ::ArrayFree(m_wnd[awi].m_available_elements);
    //---
    for(int e = 0; e < elements_total; e++) 
     {
      CElement *el = m_wnd[awi].m_elements[e];
      // --- Add only elements that are visible and accessible for processing
      if(!el.IsVisible() || !el.CElementBase::IsAvailable() || el.CElementBase::IsLocked())
        continue;
      // --- Exclude elements that do not require processing on mouse over
      if(dynamic_cast<CButtonsGroup   *>(el) == NULL &&
          dynamic_cast<CFileNavigator  *>(el) == NULL &&
          dynamic_cast<CPicture        *>(el) == NULL &&
          dynamic_cast<CPicturesSlider *>(el) == NULL &&
          dynamic_cast<CProgressBar    *>(el) == NULL &&
          dynamic_cast<CSeparateLine   *>(el) == NULL &&
          dynamic_cast<CStatusBar      *>(el) == NULL &&
          dynamic_cast<CTabs           *>(el) == NULL &&
          dynamic_cast<CTextLabel      *>(el) == NULL) {
        AddAvailableElement(awi, el);
        //Print(__FUNCTION__," > class: ",el.ClassName(),"; id: ",el.Id());
      }
     }
   }
  //+------------------------------------------------------------------+
  // | Forms an array of elements with auto-resize (X) |
  //+------------------------------------------------------------------+
  void CWndEvents::FormAutoXResizeElementsArray(void) 
   {
    int windows_total = CWndContainer::WindowsTotal();
    for(int w = 0; w < windows_total; w++) {
      int elements_total = CWndContainer::ElementsTotal(w);
      for(int e = 0; e < elements_total; e++) {
        CElement *el = m_wnd[w].m_elements[e];
        // --- We add only those that have auto-resize mode enabled
        if(!el.AutoXResizeMode())
          continue;
        //---
        if(dynamic_cast<CButton        *>(el) != NULL ||
            dynamic_cast<CFileNavigator *>(el) != NULL ||
            dynamic_cast<CGraph         *>(el) != NULL ||
            dynamic_cast<CListView      *>(el) != NULL ||
            dynamic_cast<CMenuBar       *>(el) != NULL ||
            dynamic_cast<CProgressBar   *>(el) != NULL ||
            dynamic_cast<CStandardChart *>(el) != NULL ||
            dynamic_cast<CStatusBar     *>(el) != NULL ||
            dynamic_cast<CTable         *>(el) != NULL ||
            dynamic_cast<CTabs          *>(el) != NULL ||
            dynamic_cast<CTextBox       *>(el) != NULL ||
            dynamic_cast<CTextEdit      *>(el) != NULL ||
            dynamic_cast<CTreeView      *>(el) != NULL ||
            dynamic_cast<CFrame         *>(el) != NULL) {
          CWndContainer::AddAutoXResizeElement(w, el);
        }
      }
    }
   }
  //+------------------------------------------------------------------+
  // | Forms an array of elements with auto-resize (Y) |
  //+------------------------------------------------------------------+
  void CWndEvents::FormAutoYResizeElementsArray(void) 
   {
    int windows_total = CWndContainer::WindowsTotal();
    for(int w = 0; w < windows_total; w++) {
      int elements_total = CWndContainer::ElementsTotal(w);
      for(int e = 0; e < elements_total; e++) {
        CElement *el = m_wnd[w].m_elements[e];
        // --- We add only those that have auto-resize mode enabled
        if(!el.AutoYResizeMode())
          continue;
        //---
        if (dynamic_cast<CGraph         *>(el) != NULL ||
            dynamic_cast<CListView      *>(el) != NULL ||
            dynamic_cast<CStandardChart *>(el) != NULL ||
            dynamic_cast<CTable         *>(el) != NULL ||
            dynamic_cast<CTabs          *>(el) != NULL ||
            dynamic_cast<CTextBox       *>(el) != NULL ||
            dynamic_cast<CFrame         *>(el) != NULL) {
          CWndContainer::AddAutoYResizeElement(w, el);
        }
      }
    }
   }
  //+------------------------------------------------------------------+
  // | Sets the chart state |
  //+------------------------------------------------------------------+
  void CWndEvents::SetChartState(void) 
   {
      int awi = m_active_window_index;
    // --- To determine the event when control should be disabled
      bool condition = false;
    // --- Let's check the windows
      int windows_total = CWndContainer::WindowsTotal();
      for(int i = 0; i < windows_total; i++) {
        // ---Go to next if this form is hidden
        if(!m_windows[i].IsVisible())
          continue;
        // --- Check conditions in internal form handler
        m_windows[i].OnEvent(m_id, m_lparam, m_dparam, m_sparam);
        // --- If there is a focus, note it
        if(m_windows[i].MouseFocus())
          condition = true;
      }
      
    // --- Let's check the focus of the drop-down lists
      if(!condition) {
        // --- Get the total number of drop-down lists
        int drop_lists_total = CWndContainer::ElementsTotal(awi, E_DROP_LIST);
        for(int i = 0; i < drop_lists_total; i++) {
          // --- Get a pointer to the drop-down list
          CListView *lv = m_wnd[awi].m_drop_lists[i];
          // --- If the list is activated (open)
          if(lv.IsVisible()) {
            // --- Let's check the focus of the list and the state of its scrollbar
            if(m_wnd[awi].m_drop_lists[i].MouseFocus() || lv.ScrollState()) {
              condition = true;
              break;
            }
          }
        }
      }
    // --- Let's check the focus of the drop-down calendars
      if(!condition) {
        int drop_calendars_total = CWndContainer::ElementsTotal(awi, E_DROP_CALENDAR);
        for(int i = 0; i < drop_calendars_total; i++) {
          if(m_wnd[awi].m_drop_calendars[i].GetCalendarPointer().MouseFocus()) {
            condition = true;
            break;
          }
        }
      }
    // --- Let's check the focus of the context menus
      if(!condition) {
        // --- Get the total number of drop-down context menus
        int context_menus_total = CWndContainer::ElementsTotal(awi, E_CONTEXT_MENU);
        for(int i = 0; i < context_menus_total; i++) {
          // --- If focus is on the context menu
          if(m_wnd[awi].m_context_menus[i].MouseFocus()) {
            condition = true;
            break;
          }
        }
      }
    // --- Check the status of the scroll bars
      if(!condition) {
        int scrolls_total = CWndContainer::ElementsTotal(awi, E_SCROLL);
        for(int i = 0; i < scrolls_total; i++) {
          if(((CScroll*)m_wnd[awi].m_scrolls[i]).State()) {
            condition = true;
            break;
          }
        }
      }
      
    // --- Set the chart state in all forms
      for(int i = 0; i < windows_total; i++)
        m_windows[i].CustomEventChartState(condition);
   }
  //+------------------------------------------------------------------+
 #endif // CWNDEVENTS_MQH_IMPLEMENTATION
#endif // __WNDEVENTS_MQH__

