//+------------------------------------------------------------------+
//|                                                 WndContainer.mqh |
//|                        Copyright 2015, MetaQuotes Software Corp. |
//|Lib Link https://www.mql5.com/en/code/19703                       |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//| Class for storing all interface objects |
//+------------------------------------------------------------------+
#ifndef __WNDCONTAINER_MQH__
#define __WNDCONTAINER_MQH__
#property strict
 //Include all control
   #include "Controls\Button.mqh"
   #include "Controls\ButtonsGroup.mqh"
   #include "Controls\Calendar.mqh"
   #include "Controls\CheckBox.mqh"
   #include "Controls\ColorButton.mqh"
   #include "Controls\ColorPicker.mqh"
   #include "Controls\ComboBox.mqh"
   #include "Controls\ContextMenu.mqh"
   #include "Controls\DropCalendar.mqh"
   #include "Controls\FileNavigator.mqh"
   #include "Controls\Frame.mqh"
   #include "Controls\Graph.mqh"
   #include "Controls\ListView.mqh"
   #include "Controls\MenuBar.mqh"
   #include "Controls\MenuItem.mqh"
   #include "Controls\Picture.mqh"
   #include "Controls\PicturesSlider.mqh"
   #include "Controls\ProgressBar.mqh"
   #include "Controls\SeparateLine.mqh"
   #include "Controls\Slider.mqh"
   #include "Controls\SplitButton.mqh"
   #include "Controls\StandardChart.mqh"
   #include "Controls\StatusBar.mqh"
   #include "Controls\Table.mqh"
   #include "Controls\Tabs.mqh"
   #include "Controls\TextBox.mqh"
   #include "Controls\TextEdit.mqh"
   #include "Controls\TextLabel.mqh"
   #include "Controls\TimeEdit.mqh"
   #include "Controls\Tooltip.mqh"
   #include "Controls\TreeItem.mqh"
   #include "Controls\TreeView.mqh"
   #include "Controls\Window.mqh"
   #include "Controls\SplitContainer.mqh"
 // --- Reserve size of arrays
 #define RESERVE_SIZE_ARRAY 1000
 class CWndContainer
  {
   private:
      // --- Element counter
      int               m_counter_element_id;
      //---
   protected:
      // --- An instance of a class for obtaining mouse parameters
      //CMouse            m_mouse;
       CMouseCombine m_mouse;
      // ---Window Array
      CWindow          *m_windows[];
      // --- Structure of arrays of elements
       struct WindowElements
        {            
         CElement         *m_elements[];              // --- General array of all elements
         CElement         *m_main_elements[];         // ---Array of main elements
         CElement         *m_timer_elements[];        // --- Elements with timer
         CElement         *m_available_elements[];    // --- Visible and currently available elements
         CElement         *m_auto_x_resize_elements[];// --- Elements with auto-resizing along the X axis
         CElement         *m_auto_y_resize_elements[];// --- Elements with auto-resizing along the Y axis
         // --- Personal arrays of elements:
            CContextMenu     *m_context_menus[];    // Context menus
            CComboBox        *m_combo_boxes[];      // Combo boxes
            CSplitButton     *m_split_buttons[];    // Double buttons
            CMenuBar         *m_menu_bars[];        // Main menus
            CMenuItem        *m_menu_items[];       // Menu items
            CElementBase     *m_drop_lists[];       // Dropdown lists
            CElementBase     *m_scrolls[];          // Scroll bars
            CElementBase     *m_tables[];           // Tables
            CTabs            *m_tabs[];             // Tabs
            CSlider          *m_sliders[];          // Sliders
            CCalendar        *m_calendars[];        // Calendars
            CDropCalendar    *m_drop_calendars[];   // Drop-down calendars
            CStandardChart   *m_sub_charts[];       // Standard graphs
            CTimeEdit        *m_time_edits[];       // Elements "Time"
            CTextBox         *m_text_boxes[];       // Multiline input fields
            CTreeView        *m_treeview_lists[];   // Tree lists
            CFileNavigator   *m_file_navigators[];  // File navigators
            CTooltip         *m_tooltips[];         // Tooltips
            CPicturesSlider  *m_pictures_slider[];  // Picture sliders
            CFrame           *m_frames[];           // Regions
        };
      // --- Array of arrays of elements for each window
      WindowElements    m_wnd[];   
         //  void PrintContainer(void) {
         //    string out = 
         //      " > m_elements (" + (string)ArraySize(m_wnd[0].m_elements) + ")\n" +
         //      " > m_main_elements (" + (string)ArraySize(m_wnd[0].m_main_elements) + ")\n" +
         //      
         //      " > m_menu_bars (" + (string)ArraySize(m_wnd[0].m_menu_bars) + ")\n" +
         //      " > m_menu_items (" + (string)ArraySize(m_wnd[0].m_menu_items) + ")\n" +
         //      " > m_context_menus (" + (string)ArraySize(m_wnd[0].m_context_menus) + ")\n";
         //      
         //    Print(__FUNCTION__, ":");
         //    Print(out);
         //  }   
   public:
                     CWndContainer(void);
                    ~CWndContainer(void);   
   public:
    // --- Number of windows in the interface
      int               WindowsTotal(void) { return(::ArraySize(m_windows)); }
    // --- Number of all elements
      int               ElementsTotal(const int window_index);
    // --- Number of main elements
      int               MainElementsTotal(const int window_index);
    // --- Number of elements with timers
      int               TimerElementsTotal(const int window_index);
    // --- Number of elements with auto-resize along the X axis
      int               AutoXResizeElementsTotal(const int window_index);
    // --- Number of elements with auto-resize along the Y axis
      int               AutoYResizeElementsTotal(const int window_index);
    // --- Number of items currently available
      int               AvailableElementsTotal(const int window_index);
    // --- Number of elements of the specified type
      int               ElementsTotal(const int window_index,const ENUM_ELEMENT_TYPE type);      
   protected:
    // --- Adds a window pointer to the interface element database
      void              AddWindow(CWindow &object);
    // --- Adds a pointer to an array of elements
      void              AddToElementsArray(const int window_index,CElementBase &object);
    // --- Adds a pointer to the array of elements with timers
      void              AddTimerElement(const int window_index,CElement &object);
    // --- Adds a pointer to an array of elements with auto-resizing along the X axis
      void              AddAutoXResizeElement(const int window_index,CElement &object);
    // --- Adds a pointer to an array of elements with auto-resizing along the Y axis
      void              AddAutoYResizeElement(const int window_index,CElement &object);
    // --- Adds a pointer to the array of currently available elements
      void              AddAvailableElement(const int window_index,CElement &object);   
   private:
    // --- Increments the array by one element and returns the last index
      template<typename T>
      int               ResizeArray(T &array[]);
    // --- Template method for adding pointers to an array passed by reference
      template<typename T1,typename T2>
      void              AddToPersonalArray(T1 &object,T2 &array[]);      
   private:
    // --- Checking out of range
      int               CheckOutOfRange(const int window_index);
    // --- Stores pointers to window objects
      bool              AddWindowElements(const int window_index,CElementBase &object);
    // --- Saves pointers to context menu items
      bool              AddContextMenuElements(const int window_index,CElementBase &object);
    // --- Saves pointers to main menu items
      bool              AddMenuBarElements(const int window_index,CElementBase &object);
    // --- Stores pointers to menu item items
      bool              AddMenuItemElements(const int window_index,CElementBase &object);
    // --- Stores pointers to elements of the status line
      bool              AddStatusBarElements(const int window_index,CElementBase &object);
    // --- Saves pointers to double button elements
      bool              AddSplitButtonElements(const int window_index,CElementBase &object);
    // --- Saves pointers to tab group items
      bool              AddButtonsGroupElements(const int window_index,CElementBase &object);
    // --- Stores pointers to list objects
      bool              AddListViewElements(const int window_index,CElementBase &object);
    // --- Saves pointers to scrollbar objects to the database
      bool              AddScrollElements(const int window_index,CElementBase &object);
    // --- Saves pointers to drop-down list elements (combo box)
      bool              AddComboBoxElements(const int window_index,CElementBase &object);
    // --- Saves pointers to button elements for calling the color palette
      bool              AddColorButtonElements(const int window_index,CElementBase &object);
    // --- Stores pointers to table elements
      bool              AddTableElements(const int window_index,CElementBase &object);
    // --- Saves pointers to tabs in a personal array
      bool              AddTabsElements(const int window_index,CElementBase &object);
    // --- Stores pointers to calendar items
      bool              AddCalendarElements(const int window_index,CElementBase &object);
    // --- Saves pointers to drop-down calendar items
      bool              AddDropCalendarElements(const int window_index,CElementBase &object);
    // --- Stores pointers to color palette elements
      bool              AddColorPickersElements(const int window_index,CElementBase &object);
    // --- Saves pointers to elements of graphic objects
      bool              AddSubChartsElements(const int window_index,CElementBase &object);
    // --- Saves pointers to image slider elements
      bool              AddPicturesSliderElements(const int window_index,CElementBase &object);
    // --- Stores pointers to Time elements
      bool              AddTimeEditsElements(const int window_index,CElementBase &object);
    // --- Stores pointers to multiline input field objects
      bool              AddTextBoxElements(const int window_index,CElementBase &object);
    // --- Stores pointers to text input field objects
      bool              AddTextEditElements(const int window_index,CElementBase &object);
    // --- Saves pointers to slider objects
      bool              AddSliderElements(const int window_index,CElementBase &object);
    // --- Stores pointers to elements of tree lists
      bool              AddTreeViewListsElements(const int window_index,CElementBase &object);
    // --- Saves pointers to navigator elements
      bool              AddFileNavigatorElements(const int window_index,CElementBase &object);
    // --- Stores pointers to tooltip elements
      bool              AddTooltipElements(const int window_index,CElementBase &object);
    // --- Stores pointers to area elements
      bool              AddFrameElements(const int window_index,CElementBase &object);
  };
 #ifndef CWNDCONTAINER_MQH_IMPLEMENTATION
 #define CWNDCONTAINER_MQH_IMPLEMENTATION
  //+------------------------------------------------------------------+
  //| Constructor                                                      |
  //+------------------------------------------------------------------+
  CWndContainer::CWndContainer(void) : m_counter_element_id(0)
   {
   }
  //+------------------------------------------------------------------+
  //| Destructor                                                       |
  //+------------------------------------------------------------------+
  CWndContainer::~CWndContainer(void)
   {
   }
  //+------------------------------------------------------------------+
  // | Number of elements at the specified window index |
  //+------------------------------------------------------------------+
  int CWndContainer::ElementsTotal(const int window_index)
   {
      int index=CheckOutOfRange(window_index);
      return((index!=WRONG_VALUE)? ::ArraySize(m_wnd[index].m_elements) : WRONG_VALUE);
   }
  //+------------------------------------------------------------------+
  // | Number of main elements at the specified window index |
  //+------------------------------------------------------------------+
  int CWndContainer::MainElementsTotal(const int window_index)
   {
      int index=CheckOutOfRange(window_index);
      return((index!=WRONG_VALUE)? ::ArraySize(m_wnd[index].m_main_elements) : WRONG_VALUE);
   }
  //+------------------------------------------------------------------+
  // | Number of elements with timers at the specified window index |
  //+------------------------------------------------------------------+
  int CWndContainer::TimerElementsTotal(const int window_index)
   {
      int index=CheckOutOfRange(window_index);
      return((index!=WRONG_VALUE)? ::ArraySize(m_wnd[index].m_timer_elements) : WRONG_VALUE);
   }
  //+------------------------------------------------------------------+
  // | Number of currently available items |
  //+------------------------------------------------------------------+
  int CWndContainer::AvailableElementsTotal(const int window_index)
   {
      int index=CheckOutOfRange(window_index);
      return((index!=WRONG_VALUE)? ::ArraySize(m_wnd[index].m_available_elements) : WRONG_VALUE);
   }
  //+------------------------------------------------------------------+
  // | Number of elements with auto-resize (X) at the specified window index |
  //+------------------------------------------------------------------+
  int CWndContainer::AutoXResizeElementsTotal(const int window_index)
   {
      int index=CheckOutOfRange(window_index);
      return((index!=WRONG_VALUE)? ::ArraySize(m_wnd[index].m_auto_x_resize_elements) : WRONG_VALUE);
   }
  //+------------------------------------------------------------------+
  // | Number of elements with auto-resize (Y) at the specified window index |
  //+------------------------------------------------------------------+
  int CWndContainer::AutoYResizeElementsTotal(const int window_index)
   {
      int index=CheckOutOfRange(window_index);
      return((index!=WRONG_VALUE)? ::ArraySize(m_wnd[index].m_auto_y_resize_elements) : WRONG_VALUE);
   }
  //+------------------------------------------------------------------+
  // | Number of elements at the specified window index of the specified type |
  //+------------------------------------------------------------------+
  int CWndContainer::ElementsTotal(const int window_index,const ENUM_ELEMENT_TYPE type)
   {
    // --- Check for out of range
      int index=CheckOutOfRange(window_index);
      if(index==WRONG_VALUE)
         return(WRONG_VALUE);
    //---
      int elements_total=0;
    //---
      switch(type)
      {
         case E_CONTEXT_MENU    : elements_total=::ArraySize(m_wnd[index].m_context_menus);   break;
         case E_COMBO_BOX       : elements_total=::ArraySize(m_wnd[index].m_combo_boxes);     break;
         case E_SPLIT_BUTTON    : elements_total=::ArraySize(m_wnd[index].m_split_buttons);   break;
         case E_MENU_BAR        : elements_total=::ArraySize(m_wnd[index].m_menu_bars);       break;
         case E_MENU_ITEM       : elements_total=::ArraySize(m_wnd[index].m_menu_items);      break;
         case E_DROP_LIST       : elements_total=::ArraySize(m_wnd[index].m_drop_lists);      break;
         case E_SCROLL          : elements_total=::ArraySize(m_wnd[index].m_scrolls);         break;
         case E_TABLE           : elements_total=::ArraySize(m_wnd[index].m_tables);          break;
         case E_TABS            : elements_total=::ArraySize(m_wnd[index].m_tabs);            break;
         case E_SLIDER          : elements_total=::ArraySize(m_wnd[index].m_sliders);         break;
         case E_CALENDAR        : elements_total=::ArraySize(m_wnd[index].m_calendars);       break;
         case E_DROP_CALENDAR   : elements_total=::ArraySize(m_wnd[index].m_drop_calendars);  break;
         case E_SUB_CHART       : elements_total=::ArraySize(m_wnd[index].m_sub_charts);      break;
         case E_PICTURES_SLIDER : elements_total=::ArraySize(m_wnd[index].m_pictures_slider); break;
         case E_TIME_EDIT       : elements_total=::ArraySize(m_wnd[index].m_time_edits);      break;
         case E_TEXT_BOX        : elements_total=::ArraySize(m_wnd[index].m_text_boxes);      break;
         case E_TREE_VIEW       : elements_total=::ArraySize(m_wnd[index].m_treeview_lists);  break;
         case E_FILE_NAVIGATOR  : elements_total=::ArraySize(m_wnd[index].m_file_navigators); break;
         case E_TOOLTIP         : elements_total=::ArraySize(m_wnd[index].m_tooltips);        break;
         case E_FRAME           : elements_total=::ArraySize(m_wnd[index].m_frames);          break;
      }
    // --- Return the number of elements of the specified type
      return(elements_total);
   }
  //+------------------------------------------------------------------+
  // | Adds a window pointer to the interface element database |
  //+------------------------------------------------------------------+
  void CWndContainer::AddWindow(CWindow &object)
   {
      int windows_total=::ArraySize(m_windows);
   // --- If there are no windows yet, reset the element counter
      if(windows_total<1)
      {
         m_counter_element_id=0;
         ::Comment("Loading. Please wait...");
      }
   // --- Add a pointer to the window array
      int new_size=windows_total+1;
      ::ArrayResize(m_wnd,new_size);
      ::ArrayResize(m_windows,new_size);
      m_windows[windows_total]=::GetPointer(object);
   // --- Add a pointer to the common array of elements
      int last_index=ResizeArray(m_wnd[windows_total].m_elements);
      m_wnd[windows_total].m_elements[last_index]=::GetPointer(object);
   // --- Add window button pointers to the database
      AddWindowElements(windows_total,object);
   // --- Set the identifier and remember the id of the last element
      m_windows[windows_total].Id(m_counter_element_id);
      m_windows[windows_total].LastId(m_counter_element_id);
   // --- Increase the counter of element identifiers
      m_counter_element_id++;
   }
  //+------------------------------------------------------------------+
  // | Adds a pointer to an array of elements |
  //+------------------------------------------------------------------+
  void CWndContainer::AddToElementsArray(const int window_index,CElementBase &object)
   {
      int windows_total=::ArraySize(m_windows);
    // --- If there are no forms for controls in the database
      if(windows_total<1)
      {
         ::Print(__FUNCTION__," > Перед созданием элемента управления нужно создать форму "
               "и добавить её в базу с помощью метода CWndContainer::AddWindow(CWindow &object).");
         return;
      }
    // --- If the request is for a non-existent form
      if(window_index>=windows_total)
      {
         ::Print(PREVENTING_OUT_OF_RANGE," window_index: ",window_index,"; windows total: ",windows_total);
         return;
      }
    // --- Add to the general array of elements
      int last_index=ResizeArray(m_wnd[window_index].m_elements);
      m_wnd[window_index].m_elements[last_index]=::GetPointer(object);
    // --- Add to the array of main elements
      last_index=ResizeArray(m_wnd[window_index].m_main_elements);
      m_wnd[window_index].m_main_elements[last_index]=::GetPointer(object);
      
    // --- Remember in all forms the id of the last element
      for(int w=0; w<windows_total; w++)
         m_windows[w].LastId(m_counter_element_id);
    // --- Increase the counter of element identifiers
      m_counter_element_id++;
      
    // --- Stores pointers to context menu objects
      if(AddContextMenuElements(window_index,object))
         return;
    // --- Saves pointers to main menu objects
      if(AddMenuBarElements(window_index,object))
         return;
    // --- Saves a pointer to a menu item
      if(AddMenuItemElements(window_index,object))
         return;
    // --- Stores pointers to item objects
      if(AddStatusBarElements(window_index,object))
         return;
    // --- Saves pointers to double button objects
      if(AddSplitButtonElements(window_index,object))
         return;
    // --- Saves pointers to button group objects
      if(AddButtonsGroupElements(window_index,object))
         return;
    // --- Saves pointers to list objects to the database
      if(AddListViewElements(window_index,object))
         return;
    // --- Stores pointers to combo box element objects
      if(AddComboBoxElements(window_index,object))
         return;
    // --- Stores pointers to button element objects for calling the color palette
      if(AddColorButtonElements(window_index,object))
         return;
    // --- Stores pointers to table elements
      if(AddTableElements(window_index,object))
         return;
    // --- Saves pointers to tab elements
      if(AddTabsElements(window_index,object))
         return;
    // --- Stores pointers to calendar items
      if(AddCalendarElements(window_index,object))
         return;
    // --- Saves pointers to drop-down calendar items
      if(AddDropCalendarElements(window_index,object))
         return;
    // --- Stores pointers to color palette elements
      if(AddColorPickersElements(window_index,object))
         return;
    // --- Saves pointers to elements of standard graphs
      if(AddSubChartsElements(window_index,object))
         return;
    // --- Saves pointers to image slider elements
      if(AddPicturesSliderElements(window_index,object))
         return;
    // --- Stores pointers to Time elements
      if(AddTimeEditsElements(window_index,object))
         return;
    // --- Stores pointers to elements of a multiline input field
      if(AddTextBoxElements(window_index,object))
         return;
    // --- Stores pointers to text input field elements
      if(AddTextEditElements(window_index,object))
         return;
    // --- Saves pointers to slider elements
      if(AddSliderElements(window_index,object))
         return;
    // --- Stores pointers to elements of tree lists
      if(AddTreeViewListsElements(window_index,object))
         return;
    // --- Saves pointers to file navigator elements
      if(AddFileNavigatorElements(window_index,object))
         return;
    // --- Stores pointers to tooltip objects
      if(AddTooltipElements(window_index,object))
         return;
    // --- Stores pointers to area elements
      if(AddFrameElements(window_index,object))
         return;
   }
  //+------------------------------------------------------------------+
  // | Adds a pointer to an array of elements with timers |
  //+------------------------------------------------------------------+
  void CWndContainer::AddTimerElement(const int window_index,CElement &object)
   {
      int last_index=ResizeArray(m_wnd[window_index].m_timer_elements);
      m_wnd[window_index].m_timer_elements[last_index]=::GetPointer(object);
   }
  //+------------------------------------------------------------------+
  // | Adds a pointer to an array of elements with auto-resize (X) |
  //+------------------------------------------------------------------+
  void CWndContainer::AddAutoXResizeElement(const int window_index,CElement &object)
   {
      int last_index=ResizeArray(m_wnd[window_index].m_auto_x_resize_elements);
      m_wnd[window_index].m_auto_x_resize_elements[last_index]=::GetPointer(object);
   }
  //+------------------------------------------------------------------+
  // | Adds a pointer to an array of elements with auto-resize (Y) |
  //+------------------------------------------------------------------+
  void CWndContainer::AddAutoYResizeElement(const int window_index,CElement &object)
   {
      int last_index=ResizeArray(m_wnd[window_index].m_auto_y_resize_elements);
      m_wnd[window_index].m_auto_y_resize_elements[last_index]=::GetPointer(object);
   }
  //+------------------------------------------------------------------+
  // | Adds a pointer to the array of available elements |
  //+------------------------------------------------------------------+
  void CWndContainer::AddAvailableElement(const int window_index,CElement &object)
   {
      int last_index=ResizeArray(m_wnd[window_index].m_available_elements);
      m_wnd[window_index].m_available_elements[last_index]=::GetPointer(object);
   }
  //+------------------------------------------------------------------+
  // | Adjusting the window index in case of out of range |
  //+------------------------------------------------------------------+
  int CWndContainer::CheckOutOfRange(const int window_index)
   {
      int array_size=::ArraySize(m_wnd);
      if(array_size<1)
      {
         ::Print(PREVENTING_OUT_OF_RANGE);
         return(WRONG_VALUE);
      }
    // --- Adjustment in case of leaving the range
      int index=(window_index>=array_size)? array_size-1 : window_index;
    // --- Return window index
      return(index);
   }
  //+------------------------------------------------------------------+
  // | Stores pointers to window objects |
  //+------------------------------------------------------------------+
  bool CWndContainer::AddWindowElements(const int window_index,CElementBase &object)
   {
    // --- Exit if this is not a text input field
      if(dynamic_cast<CWindow *>(&object)==NULL)
         return(false);
    // --- Get a pointer to the element
      CWindow *wnd=::GetPointer(object);
    // --- Save the mouse pointer
      object.MousePointer(m_mouse);
    //---
      for(int i=0; i<4; i++)
      {
         CButton *ib=NULL;
         //---
         if(i==0)
            ib=wnd.GetCloseButtonPointer();
         else if(i==1)
            ib=wnd.GetFullscreenButtonPointer();
         else if(i==2)
            ib=wnd.GetCollapseButtonPointer();
         else if(i==3)
            ib=wnd.GetTooltipButtonPointer();
         // --- Increasing the array of elements
         int last_index=ResizeArray(m_wnd[window_index].m_elements);
         // --- Add a close button to the database
         m_wnd[window_index].m_elements[last_index]=ib;
         // --- Save the mouse pointer
         ib.MousePointer(m_mouse);
      }
      return(true);
   }
  //+------------------------------------------------------------------+
  // | Saves pointers to context menu objects |
  //+------------------------------------------------------------------+
  bool CWndContainer::AddContextMenuElements(const int window_index,CElementBase &object)
   {
    // --- Exit if this is not a context menu
      if(dynamic_cast<CContextMenu *>(&object)==NULL)
         return(false);
    // --- Get a pointer to the context menu
      CContextMenu *cm=::GetPointer(object);
    // --- Let's save pointers to its objects in the database
      int items_total=cm.ItemsTotal();
      for(int i=0; i<items_total; i++)
      {
         // --- Save the pointer to an array
         int last_index=ResizeArray(m_wnd[window_index].m_elements);
         m_wnd[window_index].m_elements[last_index]=cm.GetItemPointer(i);
      }
    // --- Save pointers to dividing lines
      int lines_total=cm.SeparateLinesTotal();
      for(int i=0; i<lines_total; i++)
      {
         // --- Save the pointer to an array
         int last_index=ResizeArray(m_wnd[window_index].m_elements);
         m_wnd[window_index].m_elements[last_index]=cm.GetSeparateLinePointer(i);
      }
    // --- Add a pointer to the personal array
      AddToPersonalArray(cm,m_wnd[window_index].m_context_menus);
      return(true);
   }
  //+------------------------------------------------------------------+
  // | Saves pointers to main menu objects |
  //+------------------------------------------------------------------+
  bool CWndContainer::AddMenuBarElements(const int window_index,CElementBase &object)
   {
    // --- Exit if this is not the main menu
      if(dynamic_cast<CMenuBar *>(&object)==NULL)
         return(false);
    // --- Get a pointer to the main menu
      CMenuBar *mb=::GetPointer(object);
    // --- Let's save pointers to its objects in the database
      int items_total=mb.ItemsTotal();
      for(int i=0; i<items_total; i++)
      {
         // --- Save the pointer to an array
         int last_index=ResizeArray(m_wnd[window_index].m_elements);
         m_wnd[window_index].m_elements[last_index]=mb.GetItemPointer(i);
      }
    // --- Add a pointer to the personal array
      AddToPersonalArray(mb,m_wnd[window_index].m_menu_bars);
      return(true);
   }
  //+------------------------------------------------------------------+
  // | Saves pointers to menu items |
  //+------------------------------------------------------------------+
  bool CWndContainer::AddMenuItemElements(const int window_index,CElementBase &object)
   {
    // --- Exit if this is not a menu item
      if(dynamic_cast<CMenuItem *>(&object)==NULL)
         return(false);
    // --- Get a pointer to the menu item
      CMenuItem *mi=::GetPointer(object);
    // --- Add a pointer to the personal array
      AddToPersonalArray(mi,m_wnd[window_index].m_menu_items);
      return(true);
   }
  //+------------------------------------------------------------------+
  // | Saves pointers to double button objects |
  //+------------------------------------------------------------------+
  bool CWndContainer::AddSplitButtonElements(const int window_index,CElementBase &object)
   {
    // --- Let's exit if this is not a double button
      if(dynamic_cast<CSplitButton *>(&object)==NULL)
         return(false);
    // --- Get a pointer to a double button
      CSplitButton *sb=::GetPointer(object);
    //--- 
      for(int i=0; i<3; i++)
      {
         // --- Increasing the array of elements
         int last_index=ResizeArray(m_wnd[window_index].m_elements);
         // --- Save the pointer to an array
         if(i==0)
         {
            m_wnd[window_index].m_elements[last_index]=sb.GetButtonPointer();
         }
         else if(i==1)
         {
            m_wnd[window_index].m_elements[last_index]=sb.GetDropButtonPointer();
         }
         else if(i==2)
         {
            CContextMenu *cm=sb.GetContextMenuPointer();
            m_wnd[window_index].m_elements[last_index]=cm;
            // --- Add context menu elements
            AddContextMenuElements(window_index,cm);
         }
      }
    // --- Add a pointer to the personal array
      AddToPersonalArray(sb,m_wnd[window_index].m_split_buttons);
      return(true);
   }
  //+------------------------------------------------------------------+
  // | Stores pointers to elements of the status line |
  //+------------------------------------------------------------------+
  bool CWndContainer::AddStatusBarElements(const int window_index,CElementBase &object)
   {
    // --- Let's leave if this is not the point
      if(dynamic_cast<CStatusBar *>(&object)==NULL)
         return(false);
    // --- Get a pointer to the item
      CStatusBar *sb=::GetPointer(object);
    // --- Add items to the database
      int items_total=sb.ItemsTotal();
      for(int i=0; i<items_total; i++)
      {
         // --- Save the pointer to an array
         int last_index=ResizeArray(m_wnd[window_index].m_elements);
         m_wnd[window_index].m_elements[last_index]=sb.GetItemPointer(i);
      }
    // --- Save pointers to dividing lines
      int lines_total=sb.SeparateLinesTotal();
      for(int i=0; i<lines_total; i++)
      {
         int last_index=ResizeArray(m_wnd[window_index].m_elements);
         m_wnd[window_index].m_elements[last_index]=sb.GetSeparateLinePointer(i);
      }
      return(true);
   }
  //+------------------------------------------------------------------+
  // | Saves pointers to button group objects |
  //+------------------------------------------------------------------+
  bool CWndContainer::AddButtonsGroupElements(const int window_index,CElementBase &object)
   {
    // --- Let's leave if this is not a list
      if(dynamic_cast<CButtonsGroup *>(&object)==NULL)
         return(false);
    // --- Get a pointer to the list
      CButtonsGroup *bg=::GetPointer(object);
    // --- Add buttons to the database
      int buttons_total=bg.ButtonsTotal();
      for(int i=0; i<buttons_total; i++)
      {
         // --- Save the pointer to an array
         int last_index=ResizeArray(m_wnd[window_index].m_elements);
         m_wnd[window_index].m_elements[last_index]=bg.GetButtonPointer(i);
      }
      return(true);
   }
  //+------------------------------------------------------------------+
  // | Stores pointers to list objects |
  //+------------------------------------------------------------------+
  bool CWndContainer::AddListViewElements(const int window_index,CElementBase &object)
   {
    // --- Let's leave if this is not a list
      if(dynamic_cast<CListView *>(&object)==NULL)
         return(false);
    // --- Get a pointer to the list
      CListView *lv=::GetPointer(object);
    // --- Save pointers to scrollbar objects
      CScrollV *sv=lv.GetScrollVPointer();
      AddScrollElements(window_index,sv);
      return(true);
   }
  //+------------------------------------------------------------------+
  // | Saves pointers to scrollbar objects |
  //+------------------------------------------------------------------+
  bool CWndContainer::AddScrollElements(const int window_index,CElementBase &object)
   {
    // --- Let's leave if this is not a list
      if(dynamic_cast<CScroll *>(&object)==NULL)
         return(false);
    // --- Get a pointer to the scroll bar
      CScroll *sc=::GetPointer(object);
    // --- Save the pointer to an array
      int last_index=ResizeArray(m_wnd[window_index].m_elements);
      m_wnd[window_index].m_elements[last_index]=sc;
    //---
      for(int i=0; i<2; i++)
      {
         // --- Get the scrollbar button pointer
         CButton *ib=(i<1)? sc.GetIncButtonPointer() : sc.GetDecButtonPointer();
         // --- Save the pointer to an array
         last_index=ResizeArray(m_wnd[window_index].m_elements);
         m_wnd[window_index].m_elements[last_index]=ib;
      }
    // --- Add a pointer to the personal array
      AddToPersonalArray(sc,m_wnd[window_index].m_scrolls);
      return(true);
   }
  //+------------------------------------------------------------------+
  // | Saves a pointer to a drop-down list in a personal array |
  //+------------------------------------------------------------------+
  bool CWndContainer::AddComboBoxElements(const int window_index,CElementBase &object)
   {
    // --- Let's exit if this is not a combobox
      if(dynamic_cast<CComboBox *>(&object)==NULL)
         return(false);
    // --- Get a pointer to the combo box
      CComboBox *cb=::GetPointer(object);
    //---
      for(int i=0; i<2; i++)
      {
         // --- Increasing the array of elements
         int last_index=ResizeArray(m_wnd[window_index].m_elements);
         // --- Add a button to the database
         if(i==0)
         {
            m_wnd[window_index].m_elements[last_index]=cb.GetButtonPointer();
         }
         // --- Add the list to the database
         else if(i==1)
         {
            CListView *lv=cb.GetListViewPointer();
            m_wnd[window_index].m_elements[last_index]=lv;
            // --- Save pointers to list objects
            AddListViewElements(window_index,lv);
            // --- Add a pointer to the personal array
            AddToPersonalArray(lv,m_wnd[window_index].m_drop_lists);
         }
      }
    // --- Add a pointer to the personal array
      AddToPersonalArray(cb,m_wnd[window_index].m_combo_boxes);
      return(true);
   }
  //+------------------------------------------------------------------+
  // | Saves a pointer to color button elements |
  //+------------------------------------------------------------------+
  bool CWndContainer::AddColorButtonElements(const int window_index,CElementBase &object)
   {
    // --- Let's exit if this is not a combobox
      if(dynamic_cast<CColorButton *>(&object)==NULL)
         return(false);
    // --- Get a pointer to the button
      CColorButton *cb=::GetPointer(object);
    // --- Save the pointer to an array
      int last_index=ResizeArray(m_wnd[window_index].m_elements);
      m_wnd[window_index].m_elements[last_index]=cb.GetButtonPointer();
      return(true);
   }
  //+------------------------------------------------------------------+
  // | Stores pointers to table elements |
  //+------------------------------------------------------------------+
  bool CWndContainer::AddTableElements(const int window_index,CElementBase &object)
   {
    // --- Let's exit if this is not a drawn table
      if(dynamic_cast<CTable *>(&object)==NULL)
         return(false);
    // --- Get a pointer to the drawn table
      CTable *tbl=::GetPointer(object);
    //---
      for(int i=0; i<2; i++)
      {
         int last_index=ResizeArray(m_wnd[window_index].m_elements);
         //---
         if(i==0)
         {
            // --- Save the pointer to an array
            CScrollV *sv=tbl.GetScrollVPointer();
            m_wnd[window_index].m_elements[last_index]=sv;
            // --- Save pointers to scrollbar objects
            AddScrollElements(window_index,sv);
            // --- Add a pointer to the personal array
            AddToPersonalArray(sv,m_wnd[window_index].m_scrolls);
         }
         else if(i==1)
         {
            // --- Save the pointer to an array
            CScrollH *sh=tbl.GetScrollHPointer();
            m_wnd[window_index].m_elements[last_index]=sh;
            // --- Save pointers to scrollbar objects
            AddScrollElements(window_index,sh);
            // --- Add a pointer to the personal array
            AddToPersonalArray(sh,m_wnd[window_index].m_scrolls);
         }
      }
    // --- If there is an input field
      if(tbl.HasEditElements())
      {
         int last_index=ResizeArray(m_wnd[window_index].m_elements);
         // --- Save the pointer to an array
         CTextEdit *te=tbl.GetTextEditPointer();
         m_wnd[window_index].m_elements[last_index]=te;
         // --- Let's save pointers to objects
         AddTextEditElements(window_index,te);
      }
    // --- If there is a combo box
      if(tbl.HasComboboxElements())
      {
         int last_index=ResizeArray(m_wnd[window_index].m_elements);
         // --- Save the pointer to an array
         CComboBox *cb=tbl.GetComboboxPointer();
         m_wnd[window_index].m_elements[last_index]=cb;
         // --- Let's save pointers to objects
         AddComboBoxElements(window_index,cb);
      }
    // --- Add a pointer to the personal array
      AddToPersonalArray(tbl,m_wnd[window_index].m_tables);
      return(true);
   }
  //+------------------------------------------------------------------+
  // | Saves pointers to tabs in a personal array |
  //+------------------------------------------------------------------+
  bool CWndContainer::AddTabsElements(const int window_index,CElementBase &object)
   {
   // --- Exit if these are not tabs
      if(dynamic_cast<CTabs *>(&object)==NULL)
         return(false);
   // --- Get a pointer to the "Tabs" element
      CTabs *tabs=::GetPointer(object);
   // --- Save the pointer to an array
      int last_index=ResizeArray(m_wnd[window_index].m_elements);
      CButtonsGroup *bg=tabs.GetButtonsGroupPointer();
      m_wnd[window_index].m_elements[last_index]=bg;
   // --- Save pointers to group buttons
      AddButtonsGroupElements(window_index,bg);
   // --- Add a pointer to the personal array
      AddToPersonalArray(tabs,m_wnd[window_index].m_tabs);
      return(true);
   }
  //+------------------------------------------------------------------+
  // | Stores pointers to calendar objects |
  //+------------------------------------------------------------------+
  bool CWndContainer::AddCalendarElements(const int window_index,CElementBase &object)
   {
    // --- Let's go out if this is not a calendar
      if(dynamic_cast<CCalendar *>(&object)==NULL)
         return(false);
    // --- Get a pointer to the "Calendar" element
      CCalendar *cal=::GetPointer(object);
    //---
      for(int i=0; i<6; i++)
      {
         int last_index=ResizeArray(m_wnd[window_index].m_elements);
         //---
         switch(i)
         {
            case 0 :
            {
               m_wnd[window_index].m_elements[last_index]=cal.GetMonthDecPointer();
               break;
            }
            case 1 :
            {
               m_wnd[window_index].m_elements[last_index]=cal.GetMonthIncPointer();
               break;
            }
            case 2 :
            {
               CComboBox *cb=cal.GetComboBoxPointer();
               m_wnd[window_index].m_elements[last_index]=cb;
               // --- Add combo box elements
               AddComboBoxElements(window_index,cb);
               break;
            }
            case 3 :
            {
               CTextEdit *te=cal.GetSpinEditPointer();
               m_wnd[window_index].m_elements[last_index]=te;
               // --- Add input field elements
               AddTextEditElements(window_index,te);
               break;
            }
            case 4 :
            {
               CButtonsGroup *bg=cal.GetDayButtonsPointer();
               m_wnd[window_index].m_elements[last_index]=bg;
               // --- Save pointers to group buttons
               AddButtonsGroupElements(window_index,bg);
               break;
            }
            case 5 :
            {
               m_wnd[window_index].m_elements[last_index]=cal.GetTodayButtonPointer();
               break;
            }
         }
      }
    // --- Add a pointer to the personal array
      AddToPersonalArray(cal,m_wnd[window_index].m_calendars);
      return(true);
   }
  //+------------------------------------------------------------------+
  // | Saves pointers to dropdown calendar objects |
  //+------------------------------------------------------------------+
  bool CWndContainer::AddDropCalendarElements(const int window_index,CElementBase &object)
   {
    // --- We'll exit if this is not a drop-down calendar
      if(dynamic_cast<CDropCalendar *>(&object)==NULL)
         return(false);
    // --- Get a pointer to the "Drop-down calendar" element
      CDropCalendar *dc=::GetPointer(object);
    //---
      for(int i=0; i<3; i++)
      {
         // --- Increasing the array of elements
         int last_index=ResizeArray(m_wnd[window_index].m_elements);
         //---
         if(i==0)
         {
            // --- Save the pointer to an array
            CTextEdit *te=dc.GetTextEditPointer();
            m_wnd[window_index].m_elements[last_index]=te;
            // ---Add calendar items
            AddTextEditElements(window_index,te);
         }
         else if(i==1)
         {
            m_wnd[window_index].m_elements[last_index]=dc.GetDropButtonPointer();
         }
         else if(i==2)
         {
            // --- Save the pointer to an array
            CCalendar *cal=dc.GetCalendarPointer();
            m_wnd[window_index].m_elements[last_index]=cal;
            // ---Add calendar items
            AddCalendarElements(window_index,cal);
         }
      }
   // --- Add a pointer to the personal array
      AddToPersonalArray(dc,m_wnd[window_index].m_drop_calendars);
      return(true);
   }
  //+------------------------------------------------------------------+
  // | Saves pointers to color palette elements |
  //+------------------------------------------------------------------+
  bool CWndContainer::AddColorPickersElements(const int window_index,CElementBase &object)
   {
    // --- Let's leave if this is not the color palette
      if(dynamic_cast<CColorPicker *>(&object)==NULL)
         return(false);
    // --- Get a pointer to the element
      CColorPicker *cp=::GetPointer(object);
    //---
      for(int i=0; i<12; i++)
      {
         int last_index=ResizeArray(m_wnd[window_index].m_elements);
         //---
         if(i<1)
         {
            // --- Save the pointer to an array
            CButtonsGroup *bg=cp.GetRadioButtonsPointer();
            m_wnd[window_index].m_elements[last_index]=bg;
            // ---Add group buttons
            AddButtonsGroupElements(window_index,bg);
         }
         else if(i>0 && i<10)
         {
            // --- Save the pointer to an array
            CTextEdit *se=cp.GetSpinEditPointer(i-1);
            m_wnd[window_index].m_elements[last_index]=se;
            // --- Add input field elements
            AddTextEditElements(window_index,se);
         }
         else if(i>9)
         {
            CButton *ib=cp.GetButtonPointer(i-10);
            m_wnd[window_index].m_elements[last_index]=ib;
         }
      }
    //---
      return(true);
   }
  //+------------------------------------------------------------------+
  // | Saves a pointer to standard charts in a personal array |
  //+------------------------------------------------------------------+
  bool CWndContainer::AddSubChartsElements(const int window_index,CElementBase &object)
   {
    // --- We'll leave if this is not a standard schedule
      if(dynamic_cast<CStandardChart *>(&object)==NULL)
         return(false);
    // --- Get a pointer to the standard chart
      CStandardChart *sc=::GetPointer(object);
    // --- Add a pointer to the personal array
      AddToPersonalArray(sc,m_wnd[window_index].m_sub_charts);
      return(true);
   }
  //+------------------------------------------------------------------+
  // | Saves the pointer to image sliders to a personal array |
  //+------------------------------------------------------------------+
  bool CWndContainer::AddPicturesSliderElements(const int window_index,CElementBase &object)
   {
   // --- Let's exit if this is not an image slider
      if(dynamic_cast<CPicturesSlider *>(&object)==NULL)
         return(false);
   // --- Get a pointer to the image slider
      CPicturesSlider *ps=::GetPointer(object);
   // --- Add buttons to the database
      int picturs_total=ps.PicturesTotal();
      for(int i=0; i<picturs_total; i++)
      {
         // --- Save the pointer to an array
         int last_index=ResizeArray(m_wnd[window_index].m_elements);
         m_wnd[window_index].m_elements[last_index]=ps.GetPicturePointer(i);
      }
   //---
      for(int i=0; i<3; i++)
      {
         int last_index=ResizeArray(m_wnd[window_index].m_elements);
         //---
         if(i==0)
         {
            // --- Save the pointer to an array
            CButtonsGroup *bg=ps.GetRadioButtonsPointer();
            m_wnd[window_index].m_elements[last_index]=bg;
            // ---Add group buttons
            AddButtonsGroupElements(window_index,bg);
         }
         else
         {
            // --- Save the pointer to an array
            CButton *ib=(i<2)? ps.GetLeftArrowPointer() : ps.GetRightArrowPointer();
            m_wnd[window_index].m_elements[last_index]=ib;
         }
      }
   // --- Add a pointer to the personal array
      AddToPersonalArray(ps,m_wnd[window_index].m_pictures_slider);
      return(true);
   }
  //+------------------------------------------------------------------+
  // | Saves a pointer to the Time elements in a personal array |
  //+------------------------------------------------------------------+
  bool CWndContainer::AddTimeEditsElements(const int window_index,CElementBase &object)
   {
   // --- Let's exit if this is not the "Time" element
      if(dynamic_cast<CTimeEdit *>(&object)==NULL)
         return(false);
   // --- Get a pointer to the "Time" element
      CTimeEdit *te=::GetPointer(object);
      for(int i=0; i<2; i++)
      {
         int last_index=ResizeArray(m_wnd[window_index].m_elements);
         //---
         if(i==0)
         {
            // --- Save the pointer to an array
            CTextEdit *se=te.GetMinutesEditPointer();
            m_wnd[window_index].m_elements[last_index]=se;
            // --- Save pointers to text input field objects
            AddTextEditElements(window_index,se);
         }
         else
         {
            // --- Save the pointer to an array
            CTextEdit *se=te.GetHoursEditPointer();
            m_wnd[window_index].m_elements[last_index]=se;
            // --- Save pointers to text input field objects
            AddTextEditElements(window_index,se);
         }
      }
   // --- Add a pointer to the personal array
      AddToPersonalArray(te,m_wnd[window_index].m_time_edits);
      return(true);
   }
  //+------------------------------------------------------------------+
  // | Stores pointers to multiline input field objects |
  //+------------------------------------------------------------------+
  bool CWndContainer::AddTextBoxElements(const int window_index,CElementBase &object)
   {
   // --- Exit if this is not a multi-line input field
      if(dynamic_cast<CTextBox *>(&object)==NULL)
         return(false);
   // --- Get a pointer to the element
      CTextBox *tb=::GetPointer(object);
   // --- Add a pointer to the personal array
      AddToPersonalArray(tb,m_wnd[window_index].m_text_boxes);
   //---
      if(!tb.MultiLineMode())
         return(true);
   //---
      for(int i=0; i<2; i++)
      {
         int last_index=ResizeArray(m_wnd[window_index].m_elements);
         //---
         if(i==0)
         {
            // --- Get the scrollbar pointer
            CScrollV *sv=tb.GetScrollVPointer();
            m_wnd[window_index].m_elements[last_index]=sv;
            // --- Save pointers to scrollbar objects
            AddScrollElements(window_index,sv);
            // --- Add a pointer to the personal array
            AddToPersonalArray(sv,m_wnd[window_index].m_scrolls);
         }
         else if(i==1)
         {
            CScrollH *sh=tb.GetScrollHPointer();
            m_wnd[window_index].m_elements[last_index]=sh;
            // --- Save pointers to scrollbar objects
            AddScrollElements(window_index,sh);
            // --- Add a pointer to the personal array
            AddToPersonalArray(sh,m_wnd[window_index].m_scrolls);
         }
      }
      return(true);
   }
  //+------------------------------------------------------------------+
  // | Stores pointers to text input field objects |
  //+------------------------------------------------------------------+
  bool CWndContainer::AddTextEditElements(const int window_index,CElementBase &object)
   {
    // --- Exit if this is not a text input field
      if(dynamic_cast<CTextEdit *>(&object)==NULL)
         return(false);
    // --- Get a pointer to the element
      CTextEdit *te=::GetPointer(object);
    // --- Increasing the array of elements
      int last_index=ResizeArray(m_wnd[window_index].m_elements);
    // --- Get the input field pointer
      CTextBox *tb=te.GetTextBoxPointer();
      m_wnd[window_index].m_elements[last_index]=tb;
    // --- Add a pointer to the personal array
      AddToPersonalArray(tb,m_wnd[window_index].m_text_boxes);
    // --- Quit if buttons are disabled
      if(!te.SpinEditMode())
         return(true);
    //---
      for(int i=0; i<2; i++)
      {
         // --- Increasing the array of elements
         last_index=ResizeArray(m_wnd[window_index].m_elements);
         // --- Add a button to the database
         if(i==0)
            m_wnd[window_index].m_elements[last_index]=te.GetIncButtonPointer();
         else if(i==1)
            m_wnd[window_index].m_elements[last_index]=te.GetDecButtonPointer();
      }
    //---
      return(true);
   }
  //+------------------------------------------------------------------+
  // | Saves pointers to slider elements |
  //+------------------------------------------------------------------+
  bool CWndContainer::AddSliderElements(const int window_index,CElementBase &object)
   {
    // --- We'll quit if it's not a slider
      if(dynamic_cast<CSlider *>(&object)==NULL)
         return(false);
    // --- Get a pointer to the element
      CSlider *ns=::GetPointer(object);
    // --- Increasing the array of elements
      int last_index=ResizeArray(m_wnd[window_index].m_elements);
    // --- Get the input field pointer
      CTextEdit *te=ns.GetRightEditPointer();
      m_wnd[window_index].m_elements[last_index]=te;
    // --- Save pointers to input field elements
      AddTextEditElements(window_index,te);
    //---
      if(ns.DualSliderMode())
      {
         // --- Increasing the array of elements
         last_index=ResizeArray(m_wnd[window_index].m_elements);
         // --- Get the input field pointer
         te=ns.GetLeftEditPointer();
         m_wnd[window_index].m_elements[last_index]=te;
         // --- Save pointers to input field elements
         AddTextEditElements(window_index,te);
      }
   // --- Add a pointer to the personal array
      AddToPersonalArray(ns,m_wnd[window_index].m_sliders);
      return(true);
   }
  //+------------------------------------------------------------------+
  // | Saves a pointer to a hint to a personal array |
  //+------------------------------------------------------------------+
  bool CWndContainer::AddTooltipElements(const int window_index,CElementBase &object)
   {
   // --- Exit if this is not a tooltip
      if(dynamic_cast<CTooltip *>(&object)==NULL)
         return(false);
   // --- Get a pointer to the tooltip
      CTooltip *t=::GetPointer(object);
   // --- Add a pointer to the personal array
      AddToPersonalArray(t,m_wnd[window_index].m_tooltips);
      return(true);
   }
  //+------------------------------------------------------------------+
  // | Stores pointers to elements of a tree list |
  //+------------------------------------------------------------------+
  bool CWndContainer::AddTreeViewListsElements(const int window_index,CElementBase &object)
   {
    // --- Exit if this is not a tree list
      if(dynamic_cast<CTreeView *>(&object)==NULL)
         return(false);
    // --- Get a pointer to the "Tree list" element
      CTreeView *tv=::GetPointer(object);
    // --- Add a pointer to the personal array
      AddToPersonalArray(tv,m_wnd[window_index].m_treeview_lists);
    // --- Last index
      int last_index=0;
    //---
      for(int i=0; i<4; i++)
      {
         if(i==3 && !tv.ShowItemContent())
            break;
         //---
         if(i>1)
         {
            last_index=ResizeArray(m_wnd[window_index].m_elements);
         }
         //---
         switch(i)
         {
            case 0 :
            {
               for(int j=0; j<tv.ItemsTotal(); j++)
               {
                  last_index=ResizeArray(m_wnd[window_index].m_elements);
                  m_wnd[window_index].m_elements[last_index]=tv.ItemPointer(j);
               }
               break;
            }
            case 1 :
            {
               for(int j=0; j<tv.ContentItemsTotal(); j++)
               {
                  last_index=ResizeArray(m_wnd[window_index].m_elements);
                  m_wnd[window_index].m_elements[last_index]=tv.ContentItemPointer(j);
               }
               break;
            }
            case 2 :
            {
               // --- Add a pointer to the personal array
               CScrollV *sv=tv.GetScrollVPointer();
               m_wnd[window_index].m_elements[last_index]=sv;
               AddToPersonalArray(sv,m_wnd[window_index].m_scrolls);
               // --- Save pointers to scrollbar objects
               AddScrollElements(window_index,sv);
               break;
            }
            case 3 :
            {
               // --- Add a pointer to the personal array
               CScrollV *csv=tv.GetContentScrollVPointer();
               m_wnd[window_index].m_elements[last_index]=csv;
               AddToPersonalArray(csv,m_wnd[window_index].m_scrolls);
               // --- Save pointers to scrollbar objects
               AddScrollElements(window_index,csv);
               break;
            }
         }
      }
      return(true);
   }
  //+------------------------------------------------------------------+
  // | Saves pointers to file navigator elements |
  //+------------------------------------------------------------------+
  bool CWndContainer::AddFileNavigatorElements(const int window_index,CElementBase &object)
   {
    // --- Exit if this is not a file navigator
      if(dynamic_cast<CFileNavigator *>(&object)==NULL)
         return(false);
    // --- Get the file navigator pointer
      CFileNavigator *fn=::GetPointer(object);
    // --- Add a pointer to the personal array
      AddToPersonalArray(fn,m_wnd[window_index].m_file_navigators);
    // --- Save a pointer to the tree list
      int last_index=ResizeArray(m_wnd[window_index].m_elements);
      m_wnd[window_index].m_elements[last_index]=fn.GetTreeViewPointer();
    // --- Add tree list items
      AddTreeViewListsElements(window_index,fn.GetTreeViewPointer());
      return(true);
   }
  //+------------------------------------------------------------------+
  // | Saves pointers to tabs in a personal array |
  //+------------------------------------------------------------------+
  bool CWndContainer::AddFrameElements(const int window_index,CElementBase &object)
   {
    // --- Let's go out if this is not the area
      if(dynamic_cast<CFrame *>(&object)==NULL)
         return(false);
    // --- Get a pointer to the "Area" element
      CFrame *frame=::GetPointer(object);
    // --- Add a pointer to the personal array
      AddToPersonalArray(frame,m_wnd[window_index].m_frames);
    // --- Save the pointer to an array
      int last_index=ResizeArray(m_wnd[window_index].m_elements);
      m_wnd[window_index].m_elements[last_index]=frame.GetTextLabelPointer();
      return(true);
   }
  //+------------------------------------------------------------------+
  // | Increments the array by one element and returns the last index |
  //+------------------------------------------------------------------+
  template<typename T>
  int CWndContainer::ResizeArray(T &array[])
   {
      int size=::ArraySize(array);
      ::ArrayResize(array,size+1,RESERVE_SIZE_ARRAY);
      return(size);
   }
  //+------------------------------------------------------------------+
  // | Saves a pointer (T1) to an array passed by reference (T2) |
  //+------------------------------------------------------------------+
  template<typename T1,typename T2>
  void CWndContainer::AddToPersonalArray(T1 &object,T2 &array[])
   {
      int last_index=ResizeArray(array);
      array[last_index]=object;
   }
 //+------------------------------------------------------------------+
 #endif // CWNDCONTAINER_MQH_IMPLEMENTATION
#endif // __WNDCONTAINER_MQH__