//+------------------------------------------------------------------+
//|                                                     TreeView.mqh |
//|                        Copyright 2015, MetaQuotes Software Corp. |
//|                                              http://www.mql5.com |
//| Topic link https://www.mql5.com/en/articles/2539                 |
//| Lib Link https://www.mql5.com/en/code/19703                      |
//| Add by Anhnt: int ItemPrevNode(int index)                        |
//+------------------------------------------------------------------+
//| Class for creating a tree list                                   |
//+------------------------------------------------------------------+
#ifndef __TREEVIEW_MQH__
#define __TREEVIEW_MQH__
 #include "..\Element.mqh"
 #include "Pointer.mqh"
 #include "Scrolls.mqh"
 #include "TreeItem.mqh"
#ifndef CTREEVIEW_MQH_DECLARATION
#define CTREEVIEW_MQH_DECLARATION
 class CTreeView : public CElement 
  {
   private:
    // --- Objects for creating an element
     CTreeItem                   m_items[];           //CTreeItem object + canvas
     CTreeItem                   m_content_items[];
     CScrollV                    m_scrollv;
     CScrollV                    m_content_scrollv;
     CPointer                    m_x_resize;
    // --- Structure of elements assigned to each tab item
     struct TVElements 
      {
        CElement *elements[];
        int list_index;
      };
     TVElements m_tab_items[];
    // --- Arrays for all tree list items (full list)
     int                        m_t_list_index[];           //list position
     int                        m_t_prev_node_list_index[]; //parent relationship
     string                     m_t_item_text[];            //label
     uint                       m_t_path_bmp[];
     int                        m_t_item_index[];
     int                        m_t_node_level[];           //depth
     int                        m_t_prev_node_item_index[];
     int                        m_t_items_total[];          //child count
     int                        m_t_folders_total[];
     bool                       m_t_item_state[];           //expanded/collapsed
     bool                       m_t_is_folder[];
    // --- Arrays for the list of displayed tree list items
     int                        m_td_list_index[];
    // --- Arrays for the list of Contents of items selected in the tree list (full list)
     int                        m_c_list_index[];
     int                        m_c_tree_list_index[];
     string                     m_c_item_text[];
    // --- Arrays for the list of displayed items in the content list
     int                        m_cd_list_index[];
     int                        m_cd_tree_list_index[];
     string                     m_cd_item_text[];
    // --- Total number of items and number in the visible part of the lists
     int                        m_items_total;
     int                        m_content_items_total;
     int                        m_visible_items_total;
    // --- Indexes of selected items in lists
     int                        m_selected_item_index;
     int                        m_selected_content_item_index;
    // --- Text of the selected item in the list.
    // Only for files when using the class to create a file navigator.
    // If a file is not selected in the list, then this field should contain the
    // empty string "".
     string                     m_selected_item_file_name;
    // --- Tree list area width
     int                        m_treeview_width;
    // --- Height of points
     int                        m_item_y_size;
    // --- File navigator mode
     ENUM_FILE_NAVIGATOR_MODE   m_file_navigator_mode;
    // ---Hover highlight mode
     bool                       m_lights_hover;
    // --- Mode for displaying item contents in the work area
     bool                       m_show_item_content;
    // --- Mode for changing list widths
     bool                       m_resize_list_mode;
    // --- Tab item mode
     bool                       m_tab_items_mode;
    // --- Timer counter for list rewind
     int                        m_timer_counter;
    // --- (1) Minimum and (2) maximum node level
     int                        m_min_node_level;
     int                        m_max_node_level;
    // --- Number of items in the root directory
     int                        m_root_items_total;        
   private:
    void                        InitializeProperties(const int x_gap, const int y_gap);
    bool                        CreateCanvas(void);
    bool                        CreateItems(void);
    bool                        CreateScrollV(void);
    bool                        CreateContentItems(void);
    bool                        CreateContentScrollV(void);
    bool                        CreateXResizePointer(void);
    // --- Handling clicks on the button for collapsing/expanding the item list
     bool                        OnClickItemArrow(const string clicked_object,
                                                const int id,
                                                const int index);
    // --- Handling a click on a tree list item
     bool                        OnClickTreeItem(const string clicked_object,
                                               const int id,
                                               const int index);
    // --- Handling a click on an item in the content list
     bool                        OnClickContentItem(const string clicked_object,
                                                  const int id,
                                                  const int index);
    // --- Forms an array of tab items
    void                        GenerateTabItemsArray(void);
    // --- Define and set (1) node boundaries and (2) root directory size
    void                        SetNodeLevelBoundaries(void);
    void                        SetRootItemsTotal(void);
    // --- List offset
    void                        ShiftTreeList(void);
    void                        ShiftContentList(void);

    void                        FastSwitching(void);   // --- Fast forward list    
    void                        ResizeListArea(void);  // --- Controls the width of lists     
    void                        CheckXResizePointer(const int x, const int y); // --- Readiness check for changing list widths    
    bool                        CheckOutOfArea(const int x, const int y);      // --- Checking for exceeding restrictions    
    void                        UpdateXSize(const int x); // ---Updating the width of list items    
    void                        AddDisplayedTreeItem(const int list_index); // --- Adds an item to the list in the content area    
    // --- Generates (1) a tree list and (2) a content list
     void                        FormTreeList(void);
     void                        FormContentList(void);   
    // --- Checking the index of the selected item to see if it is out of range
     void                        CheckSelectedItemIndex(void);
    // --- Draws a border between areas
     virtual void                DrawResizeBorder(void);
    // --- Change the width along the right edge of the window
     virtual void                ChangeWidthByRightWindowSide(void);
     virtual void                ChangeHeightByBottomWindowSide(void);
   public:
                                  CTreeView(void);
                                  ~CTreeView(void);
    // --- Methods for creating a tree list
    bool                        CreateTreeView(const int x_gap, const int y_gap);
    // ---List scroll bar indicators
    CScrollV                    *GetScrollVPointer(void) { return (::GetPointer(m_scrollv)); }
    CScrollV                    *GetContentScrollVPointer(void) {return (::GetPointer(m_content_scrollv));}
    CPointer                    *GetMousePointer(void) { return (::GetPointer(m_x_resize)); }
    // --- Returns (1) a tree list item pointer, (2) a content list item pointer,
     CTreeItem                   *ItemPointer(const uint index);
     CTreeItem                   *ContentItemPointer(const uint index);
    // --- (1) File navigator mode, (2) Backlight mode when hovering the mouse
    // cursor, (3) mode for changing the width of lists, (4) mode of tab items
     void                        NavigatorMode(const ENUM_FILE_NAVIGATOR_MODE mode) { m_file_navigator_mode = mode; }
     void                        LightsHover(const bool state) { m_lights_hover = state; }
     void                        ResizeListMode(const bool state) { m_resize_list_mode = state; }
     void                        TabItemsMode(const bool state) { m_tab_items_mode = state; }
     bool                        TabItemsMode(void) const { return (m_tab_items_mode); }
    // --- Display mode of item content,
     void                        ShowItemContent(const bool state) { m_show_item_content = state; }
     bool                        ShowItemContent(void) const { return (m_show_item_content); }
    // --- Number of items (1) in the tree list, (2) in the contents list and (3)
    // visible number of items
     int                         ItemsTotal(void) const { return (::ArraySize(m_items)); }
     int                         ContentItemsTotal(void) const { return (::ArraySize(m_content_items)); }
     void                        VisibleItemsTotal(const int total) { m_visible_items_total = total; }
    // --- (1) Height of item, (2) width of tree list and (3) content list
     void                        ItemYSize(const int y_size) { m_item_y_size = y_size; }
     void                        TreeViewWidth(const int x_size) { m_treeview_width = x_size; }
    // --- (1) Selects an item by index and (2) returns the index of the selected
    // item, (3) returns the file name
     void                        SelectedItemIndex(const int index) { m_selected_item_index = index; }
     int                         SelectedItemIndex(void) const { return (m_selected_item_index); }
     string                      SelectedItemFileName(void) const { return (m_selected_item_file_name); }
    // --- Adds an item to the tree list
     void                        AddItem(const int list_index, const int list_id, const string item_name,
                                     const uint path_bmp, const int item_index, const int node_number,
                                     const int item_number, const int items_total,
                                     const int folders_total, const bool item_state,
                                     const bool is_folder = true);
    //My adding method 
     void                        AddTreeItem(const int list_index, const int prev_node_list_index,
                                    const string item_text, const uint path_bmp,
                                    const int item_index, const int node_level,
                                    const int prev_node_item_index, const int items_total,
                                    const int folders_total, const bool item_state,
                                    const bool is_folder);
    // --- Adds an element to the tab item array
     void                        AddToElementsArray(const int item_index, CElement &object);
    // --- Show elements of only the selected tab item
     void                        ShowTabElements(void);
    // --- Returns the full path of the selected item
     string                      CurrentFullPath(void);
    // ---Graph event handler
     virtual void                OnEvent(const int id, const long &lparam, const double &dparam,
                                     const string &sparam);
    // --- Timer
     virtual void                OnEventTimer(void);
    // --- Item availability
     virtual void                IsAvailable(const bool state, const bool without_items = false);
    // --- Management
     virtual void                Show(void);
     virtual void                Hide(void);
     virtual void                Delete(void);
     virtual void                Moving(const bool only_visible = true);
    // --- Draws an element
     virtual void                Draw(void);
    // --- Redrawing lists
      void                        RedrawTreeList(void);
      void                        RedrawContentList(void);
    // --- Updates (1) the tree list and (2) the contents list
      void                        UpdateTreeList(const bool redraw = false);
      void                        UpdateContentList(void);
    // ---My Adding Method      
      int                         ItemPrevNode(int index) const;
        
  };
#endif // CTREEVIEW_MQH_DECLARATION
#ifndef CTREEVIEW_MQH_IMPLEMENTATION
#define CTREEVIEW_MQH_IMPLEMENTATION
 //+------------------------------------------------------------------+
 //| Constructor                                                      |
 //+------------------------------------------------------------------+
 CTreeView::CTreeView(void)
    : m_treeview_width(150), m_item_y_size(20), m_visible_items_total(12),
      m_tab_items_mode(false), m_lights_hover(false),
      m_show_item_content(false), m_resize_list_mode(false),
      m_timer_counter(SPIN_DELAY_MSC), m_selected_item_index(WRONG_VALUE),
      m_selected_content_item_index(WRONG_VALUE) 
  { 
     // --- Save the element class name in the base class
     CElementBase::ClassName(CLASS_NAME);
  }
 //+------------------------------------------------------------------+
 //| Destructor                                                       |
 //+------------------------------------------------------------------+
 CTreeView::~CTreeView(void) {}
 //+------------------------------------------------------------------+
 // | Event Handler |
 //+------------------------------------------------------------------+
 void CTreeView::OnEvent(const int id,const long &lparam,const double &dparam,const string &sparam)
  {
   // --- Handling the cursor movement event
    if(id==CHARTEVENT_MOUSE_MOVE)
     {
      // --- Shift the tree list if the scroll bar control is in action
       if(m_scrollv.ScrollBarControl())
        {
         ShiftTreeList();
         m_scrollv.Update(true);
         return;
        }
      // --- We only come in if there is a list
       if(m_t_items_total[m_selected_item_index]>0)
        {
         // --- Shift the content list if the scroll bar control is in action
         if(m_content_scrollv.ScrollBarControl())
           {
            ShiftContentList();
            m_content_scrollv.Update(true);
            return;
           }
        }
      // --- Control the width of the content area
      ResizeListArea();
      return;
     }
   // --- Handling click events on scrollbar buttons
   if(id==CHARTEVENT_CUSTOM+ON_CLICK_BUTTON)
    {
      // --- Quit if in resizing mode of the content list area
       if(m_x_resize.IsVisible() || m_x_resize.State())
         return;
      // --- Handling clicks on the item arrow
       if(OnClickItemArrow(sparam,(int)lparam,(int)dparam))
         return;
      // --- Handling a click on a tree list item
       if(OnClickTreeItem(sparam,(int)lparam,(int)dparam))
         return;
      // --- Handling a click on an item in the content list
       if(OnClickContentItem(sparam,(int)lparam,(int)dparam))
         return;
      // --- If there was a click on the list scroll bar buttons
       if(m_scrollv.OnClickScrollInc((uint)lparam,(uint)dparam) ||
         m_scrollv.OnClickScrollDec((uint)lparam,(uint)dparam))
        {
         ShiftTreeList();
         m_scrollv.Update(true);
         return;
        }
      // --- If there was a click on the list scroll bar buttons
       if(m_content_scrollv.OnClickScrollInc((uint)lparam,(uint)dparam) ||
          m_content_scrollv.OnClickScrollDec((uint)lparam,(uint)dparam))
        {
         ShiftContentList();
         m_content_scrollv.Update(true);
         return;
        }
      return;
    }
  }
 //+------------------------------------------------------------------+
 // | Timer |
 //+------------------------------------------------------------------+
 void CTreeView::OnEventTimer(void) 
  {
    // --- Fast forward values
    FastSwitching();
  }
 //+------------------------------------------------------------------+
 // | Creates an element |
 //+------------------------------------------------------------------+
 bool CTreeView::CreateTreeView(const int x_gap, const int y_gap) 
  {
    // --- Quit if there is no pointer to the main element
     if (!CElement::CheckMainPointer())
      return (false);
    // --- Initializing properties
      InitializeProperties(x_gap, y_gap);
    // ---Creating an element
      if (!CreateCanvas())      return (false);
      if (!CreateItems())      return (false);
      if (!CreateScrollV())      return (false);
      if (!CreateContentItems())      return (false);
      if (!CreateContentScrollV())      return (false);
      if (!CreateXResizePointer())      return (false);
    // --- Let's create an array of tab items
      GenerateTabItemsArray();
    // --- Define and set (1) node boundaries and (2) root directory size
      SetNodeLevelBoundaries();
      SetRootItemsTotal();
    // --- Update lists
      FormTreeList();
      FormContentList();
    return (true);
  }
 //+------------------------------------------------------------------+
 // | Initializing properties |
 //+------------------------------------------------------------------+
 void CTreeView::InitializeProperties(const int x_gap, const int y_gap) 
  {
    m_x = CElement::CalculateX(x_gap);
    m_y = CElement::CalculateY(y_gap);
    //Size of tree view
      m_x_size = (m_x_size < 1 || m_auto_xresize_mode)
                  ? m_main.X2() - CElementBase::X() - m_auto_xresize_right_offset
                  : m_x_size;
      // --- Fix m_auto_yresize_mode: fill remaining height instead of fixed VisibleItemsTotal rows
      if(m_auto_yresize_mode)
       {
        m_y_size = m_main.Y2() - CElementBase::Y() - m_auto_yresize_bottom_offset;
        m_visible_items_total = (m_y_size - 2) / m_item_y_size;   // derive rows from height, not the reverse
       }
      else
        m_y_size = m_item_y_size * m_visible_items_total + 2;        
    // ---List width
    if (!m_show_item_content)
      m_treeview_width = m_x_size;
    else
      m_treeview_width =
        (m_treeview_width >= m_x_size) ? m_x_size >> 1 : m_treeview_width;
    // ---Default colors
    m_back_color = (m_back_color != clrNONE) ? m_back_color : clrWhite;
    m_border_color =
        (m_border_color != clrNONE) ? m_border_color : C'150,170,180';
    // --- Checking the index of the selected item to see if it is out of range
    CheckSelectedItemIndex();
    // --- Indents from the extreme point
    CElementBase::XGap(x_gap);
    CElementBase::YGap(y_gap);
  }
 //+------------------------------------------------------------------+
 // | Creates an object to draw |
 //+------------------------------------------------------------------+
 bool CTreeView::CreateCanvas(void) 
  {
    // --- Formation of object name
    string name = CElementBase::ElementName("tree_view");
    // ---Create an object
    if (!CElement::CreateCanvas(name, m_x, m_y, m_x_size, m_y_size))
      return (false);
    //---
    return (true);
  }
 //+------------------------------------------------------------------+
 // | Creates a tree list |
 //+------------------------------------------------------------------+
 bool CTreeView::CreateItems(void) 
  {
   // --- Coordinates
    int x=1,y=1;
    int items_total=::ArraySize(m_items);
    for(int i=0; i<items_total; i++)
     {
       // --- Y coordinate calculation
        y=(i>0)? y+m_item_y_size : y;
       // --- Save the parent pointer
         m_items[i].MainPointer(this);
         //Fix here
          m_items[i].Id(CElementBase::Id());
       // --- Properties
        m_items[i].NamePart("tree_item");
        m_items[i].Index(m_t_list_index[i]);
        m_items[i].XSize(m_treeview_width);
        m_items[i].YSize(m_item_y_size);
       //Fix Icon Gap on Symbol node
          //Old version
           //m_items[i].IconXGap(m_items[i].ArrowXGap(m_t_node_level[i])+17);
           //m_items[i].IconXGap(m_items[i].ArrowXGap(m_t_node_level[i]) + (no_icon ? 0 : 17));
          //New version
           bool no_icon = (m_t_path_bmp[i] == (uint)INT_MAX);
           int icon_gap = m_items[i].ArrowXGap(m_t_node_level[i]);
            //if (!no_icon) icon_gap += 17;
           m_items[i].IconXGap(icon_gap); 
        m_items[i].IconYGap(2);
        m_items[i].IconFile(m_t_path_bmp[i]);
        m_items[i].IsHighlighted(m_lights_hover);
       // --- Determine the item type
        ENUM_TYPE_TREE_ITEM type=TI_SIMPLE;
        if(m_file_navigator_mode==FN_ALL)
          {
          type=(m_t_items_total[i]>0)? TI_HAS_ITEMS : TI_SIMPLE;
          }
        else // FN_ONLY_FOLDERS
          {
          type=(m_t_folders_total[i]>0)? TI_HAS_ITEMS : TI_SIMPLE;
          }
       // ---Adjusting the initial state of the item
        m_t_item_state[i]=(type==TI_HAS_ITEMS)? m_t_item_state[i]: false;
       // ---Creating an element
        if(!m_items[i].CreateTreeItem(x,y,type,m_t_list_index[i],m_t_node_level[i],m_t_item_text[i],m_t_item_state[i]))
         return(false);
       // --- Add element to array
        CElement::AddToArray(m_items[i]);
     }
    // --- Set the color of the selected item
     if(!m_tab_items_mode && m_selected_item_index>=0)
      m_items[m_selected_item_index].IsPressed(true);   
    return(true);
  }
 //+------------------------------------------------------------------+
 // | Creates a vertical scroll |
 //+------------------------------------------------------------------+
 bool CTreeView::CreateScrollV(void) 
  {
   // --- Save form pointer
    m_scrollv.MainPointer(this);
   // --- Coordinates
    int x = m_treeview_width - ((m_show_item_content) ? 15 : 16);
    int y = 1;
   // --- Set properties
    m_scrollv.Index(0);
    m_scrollv.XSize(m_scrollv.ScrollWidth());
    m_scrollv.YSize(CElementBase::YSize() - 2);
    // --- Creating a scrollbar
    if (!m_scrollv.CreateScroll(x, y, m_items_total, m_visible_items_total))
      return (false);
    // Add Here to Fix Force initial paint only if the scrollbar actually decides it's needed;
    // otherwise explicitly hide it (CreateCanvas() defaults to natively visible, nothing else hides an unneeded scrollbar)
    if (m_scrollv.IsScroll())
     {
       m_scrollv.Draw();
       m_scrollv.CElement::Update(true);
     }
    else
     {
       m_scrollv.Hide();
     }
    // --- Add element to array
    CElement::AddToArray(m_scrollv);
    //---
    return (true);
  }
 //+------------------------------------------------------------------+
 // | Creates a list of contents of the selected item |
 //+------------------------------------------------------------------+
 bool CTreeView::CreateContentItems(void) 
  {
    // --- Exit if (1) item contents do not need to be shown or (2) tabbed mode is enabled
     if(!m_show_item_content || m_tab_items_mode)
      return(true);
    // ---Array reserve size
     int reserve_size=10000;
    // --- Coordinates and width
     int x=m_treeview_width,y=1;
     int w=m_x_size-m_treeview_width-2;
    // --- Point counter
     int c=0;
   //--- 
    int items_total=::ArraySize(m_items);
    for(int i=0; i<items_total; i++)
     {
      // --- This list should not include items from the root directory,
      // so if the node level is less than 1, move on to the next one
       if(m_t_node_level[i]<1)
         continue;
      // --- Increase array sizes by one element
       int new_size=c+1;
       ::ArrayResize(m_content_items,new_size,reserve_size);
       ::ArrayResize(m_c_item_text,new_size,reserve_size);
       ::ArrayResize(m_c_tree_list_index,new_size,reserve_size);
       ::ArrayResize(m_c_list_index,new_size,reserve_size);
      // --- Y coordinate calculation
       y=(c>0)? y+m_item_y_size : y;
      // --- Pass the panel object
       m_content_items[c].MainPointer(this);
      // --- Set the properties before creating
       m_content_items[c].NamePart("content_item");
       m_content_items[c].Index(m_t_list_index[i]);
       m_content_items[c].XSize(w);
       m_content_items[c].YSize(m_item_y_size);
       m_content_items[c].IconXGap(7);
       m_content_items[c].IconYGap(2);
       m_content_items[c].IconFile(m_t_path_bmp[i]);
       m_content_items[c].IsHighlighted(m_lights_hover);
      // ---Create an object
       if(!m_content_items[c].CreateTreeItem(x,y,TI_SIMPLE,c,0,m_t_item_text[i],false))
         return(false);
      // --- Add element to array
       CElement::AddToArray(m_content_items[c]);
      // --- Save (1) general content list index, (2) tree list index, and (3) item text
       m_c_list_index[c]      =c;
       m_c_tree_list_index[c] =m_t_list_index[i];
       m_c_item_text[c]       =m_t_item_text[i];
      //---
      c++;
     }
   // ---Save list size
     m_content_items_total=::ArraySize(m_content_items);
   return(true);
  }
 //+------------------------------------------------------------------+
 // | Creates a vertical scroll for the workspace |
 //+------------------------------------------------------------------+
 bool CTreeView::CreateContentScrollV(void) 
  {
   // --- Save form pointer
    m_content_scrollv.MainPointer(this);
   // --- Exit if the content of the item does not need to be shown
    if (!m_show_item_content) return (true);
   // --- Coordinates
    int x = 16, y = 1;
   // --- Properties
    m_content_scrollv.Index(1);
    m_content_scrollv.XSize(m_content_scrollv.ScrollWidth());
    m_content_scrollv.YSize(CElementBase::YSize() - 2);
    m_content_scrollv.AnchorRightWindowSide(true);
   // --- Creating a scrollbar
    if (!m_content_scrollv.CreateScroll(x, y, m_content_items_total,
                                      m_visible_items_total))
    return (false);
   // --- Add element to array
    CElement::AddToArray(m_content_scrollv);
   return (true);
  }
 //+------------------------------------------------------------------+
 // | Creates a width change cursor pointer |
 //+------------------------------------------------------------------+
 bool CTreeView::CreateXResizePointer(void) 
  {
   // --- Exit if the width of the content area does not need to be changed or
   // tabbed item mode is enabled
    if (!m_resize_list_mode || m_tab_items_mode) 
     {
      m_x_resize.State(false);
      m_x_resize.IsVisible(false);
      return (true);
     }
   // --- Properties
    m_x_resize.XGap(12);
    m_x_resize.YGap(9);
    m_x_resize.XSize(25);
    m_x_resize.Type(MP_X_RESIZE);
    m_x_resize.Id(CElementBase::Id());
   // ---Creating an element
    if (!m_x_resize.CreatePointer(m_chart_id, m_subwin)) return (false);
   //---
   return (true);
  }
 //+------------------------------------------------------------------+
 // | Returns a pointer to a tree list item by index |
 //+------------------------------------------------------------------+
 CTreeItem *CTreeView::ItemPointer(const uint index) 
  {
   uint array_size = ::ArraySize(m_items);
   // --- If there is not a single item in the context menu, report it
   if (array_size < 1) 
    {      
      ::Print(__FUNCTION__, " > You should call this method when there is at least one item in the context menu!");
    }
   // --- Adjustment in case of leaving the range
    uint i = (index >= array_size) ? array_size - 1 : index;
   // --- Return pointer
    return (::GetPointer(m_items[i]));
  }
 //+------------------------------------------------------------------+
 // | Returns a pointer to a content area item by index |
 //+------------------------------------------------------------------+
 CTreeItem *CTreeView::ContentItemPointer(const uint index) 
  {
   uint array_size = ::ArraySize(m_content_items);
   // --- If there is not a single item in the context menu, report it
   if (array_size < 1) 
    {     
     ::Print(__FUNCTION__, " > You should call this method when there is at least one item in the context menu!");
    }
   // --- Adjustment in case of leaving the range
    uint i = (index >= array_size) ? array_size - 1 : index;
   // --- Return pointer
   return (::GetPointer(m_content_items[i]));
  }
 //+------------------------------------------------------------------+
 // | Adds an item to the general array of the tree list |
 //+------------------------------------------------------------------+
 void CTreeView::AddItem(const int list_index, const int prev_node_list_index,
                        const string item_text, const uint path_bmp,
                        const int item_index, const int node_level,
                        const int prev_node_item_index, const int items_total,
                        const int folders_total, const bool item_state,
                        const bool is_folder) 
   {
    // ---Array reserve size
     int reserve_size = 10000;
    // --- Increase the size of the arrays by one element
     int array_size = ::ArraySize(m_items);
     m_items_total = array_size + 1;
     ::ArrayResize(m_items, m_items_total, reserve_size);
     ::ArrayResize(m_t_list_index, m_items_total, reserve_size);
     ::ArrayResize(m_t_prev_node_list_index, m_items_total, reserve_size);
     ::ArrayResize(m_t_item_text, m_items_total, reserve_size);
     ::ArrayResize(m_t_path_bmp, m_items_total, reserve_size);
     ::ArrayResize(m_t_item_index, m_items_total, reserve_size);
     ::ArrayResize(m_t_node_level, m_items_total, reserve_size);
     ::ArrayResize(m_t_prev_node_item_index, m_items_total, reserve_size);
     ::ArrayResize(m_t_items_total, m_items_total, reserve_size);
     ::ArrayResize(m_t_folders_total, m_items_total, reserve_size);
     ::ArrayResize(m_t_item_state, m_items_total, reserve_size);
     ::ArrayResize(m_t_is_folder, m_items_total, reserve_size);
    // --- Save the values of the passed parameters
     m_t_list_index[array_size] = list_index;
     m_t_prev_node_list_index[array_size] = prev_node_list_index;
     m_t_item_text[array_size] = item_text;
     m_t_path_bmp[array_size] = path_bmp;
     m_t_item_index[array_size] = item_index;
     m_t_node_level[array_size] = node_level;
     m_t_prev_node_item_index[array_size] = prev_node_item_index;
     m_t_items_total[array_size] = items_total;
     m_t_folders_total[array_size] = folders_total;
     m_t_item_state[array_size] = item_state;
     m_t_is_folder[array_size] = is_folder;
    // Auto-update parent node's child count and expanded state
     if(prev_node_list_index >= 0 && prev_node_list_index < array_size)
      {
        m_t_items_total[prev_node_list_index]++;
        if(m_t_items_total[prev_node_list_index] == 1)
            m_t_item_state[prev_node_list_index] = true;
      }
   }
 //New method to Add a TreeItem to TreeView
 void CTreeView::AddTreeItem(const int list_index, const int prev_node_list_index,
                            const string item_text, const uint path_bmp,
                            const int item_index, const int node_level,
                            const int prev_node_item_index, const int items_total,
                            const int folders_total, const bool item_state,
                            const bool is_folder)
  {
      // Step 1: fill data arrays (reuse existing logic)
       AddItem(list_index, prev_node_list_index, item_text, path_bmp,
              item_index, node_level, prev_node_item_index, items_total,
              folders_total, item_state, is_folder);

      // Step 2: if treeview already live, create graphic immediately
        if(m_chart_id == 0) return;
        int newitemIndex = ::ArraySize(m_items) - 1;
        int y = (newitemIndex > 0) ? 1 + newitemIndex * m_item_y_size : 1;

        m_items[newitemIndex].MainPointer(this);      
        m_items[newitemIndex].NamePart("tree_item");
        m_items[newitemIndex].Index(m_t_list_index[newitemIndex]);
        m_items[newitemIndex].XSize(m_treeview_width);
        m_items[newitemIndex].YSize(m_item_y_size);
        bool no_icon = (m_t_path_bmp[newitemIndex] == (uint)INT_MAX);
        //m_items[newitemIndex].IconXGap(m_items[newitemIndex].ArrowXGap(m_t_node_level[newitemIndex]) + (no_icon ? 0 : 17));
        m_items[newitemIndex].IconXGap(m_items[newitemIndex].ArrowXGap(m_t_node_level[newitemIndex]));
        m_items[newitemIndex].IconYGap(2);
        m_items[newitemIndex].IconFile(m_t_path_bmp[newitemIndex]);
        m_items[newitemIndex].IsHighlighted(m_lights_hover);

        ENUM_TYPE_TREE_ITEM type = (m_t_items_total[newitemIndex] > 0) ? TI_HAS_ITEMS : TI_SIMPLE;
        m_t_item_state[newitemIndex] = (type == TI_HAS_ITEMS) ? m_t_item_state[newitemIndex] : false;

        m_items[newitemIndex].CreateTreeItem(1, y, type, m_t_list_index[newitemIndex],
                                  m_t_node_level[newitemIndex], m_t_item_text[newitemIndex], m_t_item_state[newitemIndex]);
        m_items[newitemIndex].Id(CElementBase::Id());
        CElement::AddToArray(m_items[newitemIndex]);
      //Step 3 Update Parrent node
       if(prev_node_list_index >= 0 && prev_node_list_index < ArraySize(m_items) && m_t_items_total[prev_node_list_index] == 1)
        {
          CTreeItem *parent = GetPointer(m_items[prev_node_list_index]);
          if(parent.ItemType() != TI_HAS_ITEMS)
           {
            parent.ItemType(TI_HAS_ITEMS);
            parent.LabelXGap(parent.ArrowXGap(m_t_node_level[prev_node_list_index]) + 22);
            parent.AddImagesGroup(parent.ArrowXGap(m_t_node_level[prev_node_list_index]), 2);
            parent.AddImage(1, IMAGE_RESOURCE_BMP16_ARROWDOWN_BMP);
            parent.AddImage(1, IMAGE_RESOURCE_BMP16_ARROWRIGHT_BMP);
            parent.AddImage(1, IMAGE_RESOURCE_BMP16_ARROWDOWN_BLUE_BMP);   // 2
            parent.AddImage(1, IMAGE_RESOURCE_BMP16_ARROWRIGHT_BLUE_BMP);  // 3
            parent.ChangeImage(1, 0);   // collapsed by default
            parent.ItemState(false);
            parent.Draw();
            parent.CanvasPointer().Update(false);
           }
        }  
      FormTreeList();   // rebuild m_td_list_index 
  }
 //+------------------------------------------------------------------+
 // | Adds an element to the array of the specified tab |
 //+------------------------------------------------------------------+
 void CTreeView::AddToElementsArray(const int tab_index, CElement &object) 
  {
   // --- Exit if tab item mode is disabled
    if (!m_tab_items_mode)    return;
   // --- Check for out of range
    int array_size = ::ArraySize(m_tab_items);
    if (array_size < 1 || tab_index < 0 || tab_index >= array_size)
      return;
   // --- Add the pointer of the passed element to the array of the specified tab
    int size = ::ArraySize(m_tab_items[tab_index].elements);
    ::ArrayResize(m_tab_items[tab_index].elements, size + 1);
    m_tab_items[tab_index].elements[size] = ::GetPointer(object);
  }
 //+------------------------------------------------------------------+
 // | Shows elements of only the selected tab item |
 //+------------------------------------------------------------------+
 void CTreeView::ShowTabElements(void) 
  {
   // --- Quit if (1) the item is hidden or (2) tab item mode is disabled
    if (!CElementBase::IsVisible() || !m_tab_items_mode)
      return;
   // --- Index of the selected tab
    int tab_index = WRONG_VALUE;
   // --- Determine the index of the selected tab
    int tab_items_total = ::ArraySize(m_tab_items);
    for (int i = 0; i < tab_items_total; i++) 
     {
       if (m_tab_items[i].list_index == m_selected_item_index) 
        {
         tab_index = i;
         break;
        }
     }
   // --- Show elements of only the selected tab
     for (int i = 0; i < tab_items_total; i++) 
      {
       // --- Get the number of elements attached to the tab
        int tab_elements_total = ::ArraySize(m_tab_items[i].elements);
       // --- If this tab item is selected
        if (i == tab_index) 
         {
         // --- Show items
          for (int j = 0; j < tab_elements_total; j++)
           m_tab_items[i].elements[j].Reset();
         } 
        else 
         {
           // --- Hide elements
            for (int j = 0; j < tab_elements_total; j++)
              m_tab_items[i].elements[j].Hide();
         }
      }
  }
 //+------------------------------------------------------------------+
 // | Returns the full current path |
 //+------------------------------------------------------------------+
 string CTreeView::CurrentFullPath(void) 
  {
   // --- To create a directory for the selected item
    string path = "";
   // --- Index of the selected item
    int li = m_selected_item_index;
   // --- Array for forming a directory
    string path_parts[];
   // --- Get a description (text) of the selected item in the tree list,
   // but only if it's a folder
   if (m_t_is_folder[li])
    {
     ::ArrayResize(path_parts, 1);
     path_parts[0] = m_t_item_text[li];
    }
   // --- Let's go through the entire list
    int total = ::ArraySize(m_t_list_index);
    for (int i = 0; i < total; i++)
    {
      // --- We consider only folders.
      // If it is a file, go to the next point.
       if (!m_t_is_folder[i])
        continue;
      // --- If (1) the index of the shared list is the same as the index of the
      // shared list of the previous node and (2) the index of the local list item
      // is the same as the index of the previous node and (3) the sequence of
      // node levels is observed
      if (m_t_list_index[i] == m_t_prev_node_list_index[li] &&
          m_t_item_index[i] == m_t_prev_node_item_index[li] &&
          m_t_node_level[i] == m_t_node_level[li] - 1) 
          {
           // --- Increase the array by one element and save the item description
            int sz = ::ArraySize(path_parts);
            ::ArrayResize(path_parts, sz + 1);
            path_parts[sz] = m_t_item_text[i];
           // --- Remember the index for the next check
            li = i;
           // --- If we have reached the zero level of the node, we exit the loop
            if (m_t_node_level[i] == 0 || i <= 0)
              break;
           // --- Reset cycle counter
            i = -1;
          }
    }
   // --- Generate a string - full path to the selected item in the tree list
    total = ::ArraySize(path_parts);
    for (int i = total - 1; i >= 0; i--)
      ::StringAdd(path, path_parts[i] + "\\");
   // --- If the selected item in the tree list is a folder
    if (m_t_is_folder[m_selected_item_index]) 
     {
      m_selected_item_file_name = "";
      // --- If an item in the content area is highlighted
      if (m_selected_content_item_index > 0) 
      {
       // --- If the selected item is a file, save its name
       if (!m_t_is_folder[m_c_tree_list_index[m_selected_content_item_index]])
         m_selected_item_file_name = m_c_item_text[m_selected_content_item_index];
      }
     }
    // --- If the selected item in the tree list is a file
    else
    // --- Let's save its name
      m_selected_item_file_name = m_t_item_text[m_selected_item_index];
    // --- Return directory
    return (path);
  }
 //+------------------------------------------------------------------+
 // | Item Availability |
 //+------------------------------------------------------------------+
 void CTreeView::IsAvailable(const bool state,
                            const bool without_items = false) 
  {
   // ---If without items
   if (without_items) 
    {
     m_is_available = state;
     return;
    }
   // ---If with points
   else
    {
     m_is_available = state;
     int elements_total = CElement::ElementsTotal();
     for (int i = 0; i < elements_total; i++)
       m_elements[i].IsAvailable(state);
     //---
     if (state)
       SetZorders();
     else
       ResetZorders();
    }
  }
 //+------------------------------------------------------------------+
 // | Shows element |
 //+------------------------------------------------------------------+
 void CTreeView::Show(void) 
 {
  // //Debug
  //  Print("My Debug CTreeView::Show CALLED obj=", m_canvas.ChartObjectName(), " IsVisible_before=", CElementBase::IsVisible());
  // --- Exit if element is already visible
   if (CElementBase::IsVisible())    return;  
  // Fix for ScrollV
   m_scrollv.Reinit(m_items_total, m_visible_items_total);
   m_scrollv.ChangeYSize(m_y_size - 2);
  // --- Show element move after Fix for ScrollV block
   CElement::Show();
  // --- Update list coordinates and sizes
   ShiftTreeList();
   ShiftContentList();
 }
 void CTreeView::Moving(const bool only_visible)
  {
   CElement::Moving(only_visible);
   // --- Re-layout visible items + scrollbar to match the freshly recalculated height
    ShiftTreeList();
    ShiftContentList();
   //Debug
    // Print("My Debug CTreeView::Moving obj=", m_canvas.ChartObjectName(),
    //       " IsVisible=", CElementBase::IsVisible(),
    //       " ItemsTotal=", ItemsTotal(),
    //       " VisibleItemsTotal=", m_visible_items_total,
    //       " XSize=", CElementBase::XSize(), " YSize=", CElementBase::YSize());
    // if(ItemsTotal() > 0)
    //  {
    //   string item_obj = m_items[0].CanvasPointer().ChartObjectName();
    //   Print("My Debug CTreeView::Moving item0 NATIVE obj=", item_obj,
    //   " exists=", ObjectFind(0, item_obj),
    //   " TIMEFRAMES=", ObjectGetInteger(0, item_obj, OBJPROP_TIMEFRAMES),
    //   " X=", ObjectGetInteger(0, item_obj, OBJPROP_XDISTANCE),
    //   " Y=", ObjectGetInteger(0, item_obj, OBJPROP_YDISTANCE),
    //   " BACK=", ObjectGetInteger(0, item_obj, OBJPROP_BACK),
    //   " ZORDER=", ObjectGetInteger(0, item_obj, OBJPROP_ZORDER),
    //   " item0.IsVisible=", m_items[0].IsVisible());
    //  }
  }
 //+------------------------------------------------------------------+
 // | Hides the element |
 //+------------------------------------------------------------------+
 void CTreeView::Hide(void) 
  {
   // --- Exit if element is already hidden
   if (!CElementBase::IsVisible()) return;
   //Print("My Debug CTreeView::Hide CALLED obj=", m_canvas.ChartObjectName());
   // --- Hide element
    CElement::Hide();
   // --- Hide tree list items
   int total = ::ArraySize(m_items);
   for (int i = 0; i < total; i++)
     m_items[i].Hide();
   // --- Hide content list items
   total = ::ArraySize(m_content_items);
   for (int i = 0; i < total; i++)
     m_content_items[i].Hide();
   // --- Hide scrollbars
    m_scrollv.Hide();
    m_content_scrollv.Hide();
   // --- Adjust the size of the scroll bar
    m_scrollv.ChangeThumbSize(m_items_total, m_visible_items_total);
  }
 //+------------------------------------------------------------------+
 //| Removal |
 //+------------------------------------------------------------------+
 void CTreeView::Delete(void) 
  {
   CElement::Delete();
   m_x_resize.Delete();
   // --- Freeing element arrays
    ::ArrayFree(m_items);
    ::ArrayFree(m_content_items);   
    int total = ::ArraySize(m_tab_items);
    for (int i = 0; i < total; i++)
      ::ArrayFree(m_tab_items[i].elements);
    //---
      ::ArrayFree(m_tab_items);
      ::ArrayFree(m_t_prev_node_list_index);
      ::ArrayFree(m_t_list_index);
      ::ArrayFree(m_t_item_text);
      ::ArrayFree(m_t_path_bmp);
      ::ArrayFree(m_t_item_index);
      ::ArrayFree(m_t_node_level);
      ::ArrayFree(m_t_prev_node_item_index);
      ::ArrayFree(m_t_items_total);
      ::ArrayFree(m_t_folders_total);
      ::ArrayFree(m_t_item_state);
      ::ArrayFree(m_t_is_folder);
    //---
      ::ArrayFree(m_td_list_index);
    //---
      ::ArrayFree(m_c_list_index);
      ::ArrayFree(m_c_item_text);
    //---
      ::ArrayFree(m_cd_item_text);
      ::ArrayFree(m_cd_list_index);
      ::ArrayFree(m_cd_tree_list_index);
    // --- Initializing variables to default values
      m_selected_item_index = WRONG_VALUE;
      m_selected_content_item_index = WRONG_VALUE;
  }
 //+------------------------------------------------------------------+
 // | Draws an element |
 //+------------------------------------------------------------------+
 void CTreeView::Draw(void) 
  {    
      DrawBackground();  // --- Draw background    
      DrawBorder();      // --- Draw a frame    
      DrawResizeBorder();// --- Draw the border of the areas
  }
 //+------------------------------------------------------------------+
 //| Clicking the button to collapse/expand the item list |
 //+------------------------------------------------------------------+
 bool CTreeView::OnClickItemArrow(const string clicked_object, const int id,
                                 const int index) 
  {
   // --- Exit if the object name is foreign
   if (::StringFind(clicked_object, CElementBase::ProgramName() + "_tree_item_",
                   0) < 0)
     return (false);
   // --- Exit if IDs do not match
    if (id != CElementBase::Id()) return (false);
   // --- Get the index of the item in the general list
    int list_index = CElementBase::IndexFromObjectName(clicked_object);
   // --- Exit if this item is without a drop-down list
    if (m_items[list_index].ItemType() != TI_HAS_ITEMS) return (false);
   // --- Get relative coordinates under the mouse cursor
    int x = m_mouse.RelativeX(m_canvas);
   // --- Exit if the click was not on the arrow
    if (x < m_items[list_index].ArrowXGap() ||x > m_items[list_index].ArrowXGap() + 16)
     return (false);
   // --- Get the state of the point arrow and set the opposite
    m_t_item_state[list_index] = !m_t_item_state[list_index];
   // --- Highlight selected item
    m_items[list_index].ItemState(m_t_item_state[list_index]);
    m_items[list_index].IsPressed((list_index == m_selected_item_index) ? true
                                                                      : false);    
    m_items[list_index].Draw();
    m_items[list_index].CanvasPointer().Update(false);
   // --- Generate a tree list
    FormTreeList();
   // --- Update
    UpdateTreeList();      //No ChartRedraw(m_chart_id) in UpdateTreeList     
   // --- Calculate scrollbar slider position
    m_scrollv.MovingThumb(m_scrollv.CurrentPos());
   // --- Show elements of the selected tab item
    ShowTabElements();
   // --- Send a message about the change in the graphical interface
    ::EventChartCustom(m_chart_id, ON_CHANGE_GUI, CElementBase::Id(), 0, "");
    return (true);
  }
 //+------------------------------------------------------------------+
 // | Clicking on an item in the tree list |
 //+------------------------------------------------------------------+
 bool CTreeView::OnClickTreeItem(const string clicked_object, const int id,
                                const int index) 
  {
    // --- Exit if the scrollbar is in active mode
     if (m_scrollv.State() || m_content_scrollv.State()) return (false);
    // --- Exit if the object name is foreign
     if (::StringFind(clicked_object, CElementBase::ProgramName() + "_tree_item_",
                   0) < 0)
      return (false);
    // --- Exit if IDs do not match
     if (id != CElementBase::Id()) return (false);
    // --- Get the current position of the scroll bar slider
     int v = m_scrollv.CurrentPos();
    // --- Let's go through the list
     for (int r = 0; r < m_visible_items_total; r++) 
      {
       // --- Check to prevent out of range
        if (v >= 0 && v < m_items_total) 
         {
          // --- Get the general index of the item
           int li = m_td_list_index[v];
          // --- If this item is selected in the list
           if (m_items[li].CanvasPointer().ChartObjectName() == clicked_object) 
            {
             // --- Exit if this item is already selected
             if (li == m_selected_item_index) 
              {
                m_items[li].IsPressed(true);
                //m_items[li].Update(true);
                m_items[li].Draw();
                m_items[li].CanvasPointer().Update(false);
                return (false);
              }
             // --- If tab item mode is enabled and content display mode is disabled,
             // we will not highlight items without a list
              if (m_tab_items_mode && !m_show_item_content) 
               {
                // --- If the current item does not contain a list, stop the loop
                 if (m_t_items_total[li] > 0) 
                  {
                   m_items[li].IsPressed(false);
                   //m_items[li].Update(true);
                    m_items[li].Draw();
                    m_items[li].CanvasPointer().Update(false);
                    break;
                  }
               }
             // --- Set the color to the previous selected item
              m_items[m_selected_item_index].IsPressed(false);
             //m_items[m_selected_item_index].Update(true);
              m_items[m_selected_item_index].Draw();
              m_items[m_selected_item_index].CanvasPointer().Update(false);
             // --- Remember the index for the current one and change its color
              m_selected_item_index = li;
              m_items[li].IsPressed(true);
              //m_items[li].Update(true);
              m_items[li].Draw();
              m_items[li].CanvasPointer().Update(false);
              break;
            }
          v++;
         }
      }
    // --- Reset content area colors
     if (m_selected_content_item_index >= 0) 
      {
       m_content_items[m_selected_content_item_index].IsPressed(false);
       //m_content_items[m_selected_content_item_index].Update();
       m_content_items[m_selected_content_item_index].Draw();
       m_content_items[m_selected_content_item_index].CanvasPointer().Update(false);
      }
    // --- Reset selected item
      m_selected_content_item_index = WRONG_VALUE;
    // --- Update content list
    FormContentList();
    UpdateContentList();
    // --- Calculate scrollbar slider position
      m_content_scrollv.MovingThumb(m_content_scrollv.CurrentPos());
    // --- Show elements of the selected tab item
      ShowTabElements();
    // --- Send a message about selecting a new directory in the tree list
      ::EventChartCustom(m_chart_id, ON_CHANGE_TREE_PATH, 0, 0, "");
    // --- Send a message about the change in the graphical interface
      ::EventChartCustom(m_chart_id, ON_CHANGE_GUI, CElementBase::Id(), 0, "");
      return (true);
  }
 //+------------------------------------------------------------------+
 // | Clicking on an item in the contents list |
 //+------------------------------------------------------------------+
 bool CTreeView::OnClickContentItem(const string clicked_object, const int id,
                                   const int index) 
  {
   // --- Quit if content area is disabled
    if (!m_show_item_content) return (false);
   // --- Exit if the scrollbar is in active mode
    if (m_scrollv.State() || m_content_scrollv.State()) return (false);
   // --- Exit if the object name is foreign
    if (::StringFind(clicked_object,
                   CElementBase::ProgramName() + "_content_item_", 0) < 0)
      return (false);
   // --- Exit if IDs do not match
    if (id != CElementBase::Id()) return (false);
   // --- Get the number of items in the content list 
    int content_items_total = ::ArraySize(m_cd_list_index);
   // --- Get the current position of the scroll bar slider
    int v = m_content_scrollv.CurrentPos();
   // --- Let's go through the list
    for (int r = 0; r < m_visible_items_total; r++) 
     {
      // --- Check to prevent out of range
       if (v >= 0 && v < content_items_total) 
        {
         // --- Get the general index of the list
          int li = m_cd_list_index[v];
         // --- If this item is selected in the list
          if (m_content_items[li].CanvasPointer().ChartObjectName() ==
           clicked_object) 
           {
           // --- Set color to previous selected item
             if (m_selected_content_item_index >= 0) 
             {
              m_content_items[m_selected_content_item_index].IsPressed(false);
              m_content_items[m_selected_content_item_index].Update(true);
             }
           // --- Remember the index for the current one and change the color
             m_selected_content_item_index = li;
             m_content_items[li].IsPressed(true);
             m_content_items[li].Update(true);
           }
          v++;
        }
     }
   // --- Send a message about selecting a new directory in the tree list
     ::EventChartCustom(m_chart_id, ON_CHANGE_TREE_PATH, 0, 0, "");
   return (true);
  }
 //+------------------------------------------------------------------+
 // | Forms an array of tab items |
 //+------------------------------------------------------------------+
 void CTreeView::GenerateTabItemsArray(void)
  {
   // --- Exit if tab item mode is disabled
    if (!m_tab_items_mode)
      return;
   // --- Add only empty items to the array of tab items
    int items_total = ::ArraySize(m_items);
    for (int i = 0; i < items_total; i++)
     {
      // --- If there are other points at this point, move on to the next one
      if (m_t_items_total[i] > 0)
        continue;
      // --- Increase the size of the array of tab items by one element
      int array_size = ::ArraySize(m_tab_items);
      ::ArrayResize(m_tab_items, array_size + 1);
      // --- Save the general index of the item
      m_tab_items[array_size].list_index = i;
     }
    // --- If display of item contents is disabled
    if (!m_show_item_content) 
     {
      // --- Get the size of the array of tab items
      int tab_items_total = ::ArraySize(m_tab_items);
      // --- We will adjust the index if it is out of range
      if (m_selected_item_index >= tab_items_total)
        m_selected_item_index = tab_items_total - 1;
      // --- Index of the selected tab
      int tab_index = m_tab_items[m_selected_item_index].list_index;
      m_selected_item_index = tab_index;
      m_items[tab_index].IsPressed(true);      
      //m_items[tab_index].Update();
      m_items[tab_index].Draw();
      m_items[tab_index].CanvasPointer().Update(false);
     }
  }
 //+------------------------------------------------------------------+
 // | Defining and setting node boundaries |
 //+------------------------------------------------------------------+
 void CTreeView::SetNodeLevelBoundaries(void) 
  {
    // --- Let's determine the minimum and maximum level of nodes
    m_min_node_level = m_t_node_level[::ArrayMinimum(m_t_node_level)];
    m_max_node_level = m_t_node_level[::ArrayMaximum(m_t_node_level)];
  }
 //+------------------------------------------------------------------+
 // | Determining and setting the size of the root directory |
 //+------------------------------------------------------------------+
 void CTreeView::SetRootItemsTotal(void) 
  {
    // --- Determine the number of items in the root directory
    int items_total = ::ArraySize(m_items);
    for (int i = 0; i < items_total; i++) 
     {
      // --- If this is the minimum level, increase the counter
      if (m_t_node_level[i] == m_min_node_level)
        m_root_items_total++;
     }
  }
 //+------------------------------------------------------------------+
 // | Shifts the tree list relative to the scrollbar |
 //+------------------------------------------------------------------+
 void CTreeView::ShiftTreeList(void) 
  {
   // --- Exit if element is hidden
    if (!CElementBase::IsVisible())
      return;
   // --- Hide all items in the tree list
    int items_total = ItemsTotal();   
    for (int i = 0; i < items_total; i++)
      m_items[i].Hide();
   // --- Get the number of displayed items in the list
    int total = ::ArraySize(m_td_list_index);
   // --- Calculation of the width of list items
    int w = (m_scrollv.IsScroll())
                ? CElementBase::XSize() - m_scrollv.ScrollWidth() - 2
                : CElementBase::XSize()-2; //Modify here from CElementBase::XSize() to fix width
   // --- Determining the scroll position
    int v = (m_scrollv.IsScroll()) ? m_scrollv.CurrentPos() : 0;
    m_scrollv.CurrentPos(v);
   // --- Coordinates
    int x = 1, y = 1;
   //--- 
    for (int r = 0; r < m_visible_items_total; r++) 
     {
      // --- Check to prevent out of range
      if (v >= 0 && v < total) 
       {
        // --- Calculate the Y coordinate
        y = (r > 0) ? y + m_item_y_size : y;
        // --- Get the general index of the tree list item
        int li = m_td_list_index[v];
        // --- Set coordinates and width
         m_items[li].UpdateX(x);
         m_items[li].UpdateY(y);
        //Add here to fix
         m_items[li].UpdateWidth(w); 
         m_items[li].Draw();
         m_items[li].CanvasPointer().Update(false);
        // --- Show item
        m_items[li].Show();        
        v++;
      }
    }
   // ---Redraw scrollbar
    if (m_scrollv.IsScroll())
      m_scrollv.Show();
  }
 //+------------------------------------------------------------------+
 // | Shifts the list of contents relative to the scroll bar |
 //+------------------------------------------------------------------+
 void CTreeView::ShiftContentList(void) 
  {
   // --- Exit if (1) the content of the item does not need to be shown or (2)
   // the item is hidden
    if (!m_show_item_content || !CElementBase::IsVisible()) return;
   // --- Hide all items in the content list
     m_content_items_total = ContentItemsTotal();
    for (int i = 0; i < m_content_items_total; i++)
      m_content_items[i].Hide();
   // --- Get the number of displayed items in the content list
    int total = ::ArraySize(m_cd_list_index);
   // --- If you need a scroll bar
    bool is_scroll = total > m_visible_items_total;
   // --- Calculation of the width of list items
    int w = (is_scroll) ? m_x_size - m_treeview_width -
                            m_content_scrollv.ScrollWidth() - 2
                      : m_x_size - m_treeview_width - 2;
   // --- Determining the scroll position
    int v = (is_scroll) ? m_content_scrollv.CurrentPos() : 0;
    m_content_scrollv.CurrentPos(v);
   // --- X coordinate
    int x = m_treeview_width + 1;
   // --- Y coordinate of the first item in the tree list
    int y = 1;
   //---
    for (int r = 0; r < m_visible_items_total; r++) 
    {
      // --- Check to prevent out of range
      if (v >= 0 && v < total) {
        // --- Calculate the Y coordinate
        y = (r > 0) ? y + m_item_y_size : y;
        // --- Get the general index of the tree list item
        int li = m_cd_list_index[v];
        // --- Set coordinates and width
        m_content_items[li].UpdateX(x);
        m_content_items[li].UpdateY(y);
        // --- Show item
        m_content_items[li].Show();
        v++;
      }
    }
   // ---Redraw scrollbar
    if (is_scroll) m_content_scrollv.Show();
  }
 //+------------------------------------------------------------------+
 // | Fast forward lists |
 //+------------------------------------------------------------------+
 void CTreeView::FastSwitching(void) 
  {
   // --- Determining focus on one of the scrollbar buttons
    bool spin_buttons_focus =
      m_scrollv.GetIncButtonPointer().MouseFocus() ||
      m_scrollv.GetDecButtonPointer().MouseFocus() ||
      m_content_scrollv.GetIncButtonPointer().MouseFocus() ||
      m_content_scrollv.GetDecButtonPointer().MouseFocus();
   // --- Exit if (1) outside the element area or (2) content area width change
   // mode is activated
    if ((!CElementBase::MouseFocus() && !spin_buttons_focus) ||
      m_x_resize.State()) 
    {
      // --- Send a message about the change in the graphical interface
      if (m_timer_counter != SPIN_DELAY_MSC)
        ::EventChartCustom(m_chart_id, ON_CHANGE_GUI, CElementBase::Id(), 0, "");
      // --- Let's return the counter to its original value
      m_timer_counter = SPIN_DELAY_MSC;
      return;
    }
   // ---If the mouse button is released
    if (!m_mouse.IsLeftBtn()) 
      {
        // --- Send a message about the change in the graphical interface
        if (m_timer_counter != SPIN_DELAY_MSC)
          ::EventChartCustom(m_chart_id, ON_CHANGE_GUI, CElementBase::Id(), 0, "");
        // --- Let's return the counter to its original value
        m_timer_counter = SPIN_DELAY_MSC;
      }
   // --- If the mouse button is pressed
    else 
    {
      // --- Exit if no button is pressed
      if (!spin_buttons_focus) return;
      // --- Increase the counter by the set interval
      m_timer_counter += TIMER_STEP_MSC;
      // --- Exit if less than zero
      if (m_timer_counter < 0) return;
      // --- Rewind flag
      bool scroll_v = false;
      // ---If scroll up
      if (m_scrollv.GetIncButtonPointer().MouseFocus()) 
        {
          m_scrollv.OnClickScrollInc((uint)Id(), 0);
          scroll_v = true;
        }
      // --- If scroll down
      else if (m_scrollv.GetDecButtonPointer().MouseFocus())
        {
          m_scrollv.OnClickScrollDec((uint)Id(), 1);
          scroll_v = true;
        }
      // ---If the button is pressed
      if (scroll_v) 
        {
          // --- Update list
          ShiftTreeList();
          m_scrollv.Update(true);
          return;
        }
      // --- Quit if content area is disabled
      if (!m_show_item_content) return;
      // ---If scroll up
      if (m_content_scrollv.GetIncButtonPointer().MouseFocus())
        {
          m_content_scrollv.OnClickScrollInc((uint)Id(), 2);
          scroll_v = true;
        }
      // --- If scroll down
      else if (m_content_scrollv.GetDecButtonPointer().MouseFocus())
        {
          m_content_scrollv.OnClickScrollDec((uint)Id(), 3);
          scroll_v = true;
        }
      // ---If the button is pressed
      if (scroll_v) 
      {
        // --- Update list
        ShiftContentList();
        m_content_scrollv.Update(true);
      }
    }
  }
 //+------------------------------------------------------------------+
 // | Controls the width of lists |
 //+------------------------------------------------------------------+
 void CTreeView::ResizeListArea(void) 
  {
   // --- Exit, (1) if the width of the content area does not need to be changed
   // or (2) tab item mode is enabled or (3) the scroll bar is active
    if (!m_resize_list_mode || !m_show_item_content || m_tab_items_mode ||
        m_scrollv.State())
      return;
   // --- Coordinates
    int x = m_mouse.RelativeX(m_canvas);
    int y = m_mouse.RelativeY(m_canvas);
   // --- Readiness check for changing list widths
    CheckXResizePointer(x, y);
   // --- Quit if cursor is disabled
    if (!m_x_resize.State())
      return;
   // --- Check for exceeding established limits
    if (!CheckOutOfArea(x, y))
      return;
   // --- Set the X-coordinate of the object to the center of the mouse cursor
    m_x_resize.UpdateX(m_mouse.X());
   // --- We set the Y-coordinate only if we do not go beyond the element area
    if (y > 0 && y < m_y_size)
      m_x_resize.UpdateY(m_mouse.Y());
   // ---Updating the width of list items
    UpdateXSize(x);
   // --- Redraw the pointer
    m_x_resize.Reset();
  }
 //+------------------------------------------------------------------+
 // | Checking readiness for changing list widths |
 //+------------------------------------------------------------------+
 void CTreeView::CheckXResizePointer(const int x, const int y) 
  {
   // --- If the pointer is not activated, but the mouse cursor is in its area
    if (!m_x_resize.State() && y > 0 && y < m_y_size && x > m_treeview_width &&
      x < m_treeview_width + 3) 
     {
       // --- Update pointer coordinates and make it visible
        m_x_resize.Moving(m_mouse.X(), m_mouse.Y());
        m_x_resize.Reset();
       // --- If the left mouse button is pressed, activate the pointer
        if (m_mouse.IsLeftBtn()) 
        {
          m_x_resize.State(true);
          m_x_resize.Update(true);
          // --- Send a message to determine available elements
          ::EventChartCustom(m_chart_id, ON_SET_AVAILABLE, CElementBase::Id(), 0,
                             "");
          // --- Send a message about the change in the graphical interface
          ::EventChartCustom(m_chart_id, ON_CHANGE_GUI, CElementBase::Id(), 0, "");
        }
     } 
    else 
     {
       // --- If the left mouse button is released
       if (!m_mouse.IsLeftBtn()) 
        {
         // --- Quit if the cursor is already hidden
         if (!m_x_resize.IsVisible()) return;
         // --- If the cursor pointer is active
         if (m_x_resize.State()) 
          {
           // --- Deactivate pointer
            m_x_resize.State(false);
           // --- Correction of the width of list items
            RedrawTreeList();
            RedrawContentList();
            UpdateTreeList();
            UpdateContentList();
            ChartRedraw(m_chart_id);
           // --- Send a message to determine available elements
            ::EventChartCustom(m_chart_id, ON_SET_AVAILABLE, CElementBase::Id(), 1,
                              "");
           // --- Send a message about the change in the graphical interface
            ::EventChartCustom(m_chart_id, ON_CHANGE_GUI, CElementBase::Id(), 0,
                           "");
          }
          // --- Hide pointer
            m_x_resize.Hide();
        }
     }
  }
 //+------------------------------------------------------------------+
 // | Checking for exceeding restrictions |
 //+------------------------------------------------------------------+
 bool CTreeView::CheckOutOfArea(const int x, const int y) 
  {
    // --- Limitation
    int area_limit = 80;
    // --- If we go beyond the boundaries of the element horizontally...
    if (x < area_limit || x > m_x_size - area_limit) {
      // ... move the pointer only vertically, without going beyond the boundaries
      if (y > 0 && y < m_y_size)
        m_x_resize.UpdateY(m_mouse.Y());
      // --- Do not change the width of the lists
      return (false);
    }
    // --- Change the width of lists
    return (true);
  }
 //+------------------------------------------------------------------+
 // | Update tree width |
 //+------------------------------------------------------------------+
 void CTreeView::UpdateXSize(const int x) 
  {
    // --- Coordinates
    int y1 = 1, y2 = m_y_size - 2;
    // --- Erase border
    m_canvas.LineVertical(m_treeview_width, y1, y2, ::ColorToARGB(m_back_color));
    // --- Calculate and set the width of the tree list area
    m_treeview_width = x - 3;
    // --- Calculate and set the width for items in the tree list, taking into
    // account the scroll bar
    int w = (m_scrollv.IsScroll())
                ? m_treeview_width - m_scrollv.ScrollWidth() - 2
                : m_treeview_width - 1;
    // --- Determining the scroll position
    int v = (m_scrollv.IsScroll()) ? m_scrollv.CurrentPos() : 0;
    m_scrollv.CurrentPos(v);
    // --- Get the number of displayed items in the list
    int total = ::ArraySize(m_td_list_index);
    for (int r = 0; r < m_visible_items_total; r++) {
      // --- Check to prevent out of range
      if (v >= 0 && v < total) {
        // --- Get the general index of the tree list item
        int li = m_td_list_index[v];
        // --- Set coordinates and width
        m_items[li].UpdateWidth(w);
        //m_items[li].Update(true);
        m_items[li].Draw();
        m_items[li].CanvasPointer().Update(false);
        v++;
      }
    }
    // --- Calculate the width for items in the list
    w = (m_content_scrollv.IsScroll())
            ? m_x_size - m_treeview_width - m_content_scrollv.ScrollWidth() - 3
            : m_x_size - m_treeview_width - 2;
    // --- Determining the scroll position
    v = (m_content_scrollv.IsScroll()) ? m_content_scrollv.CurrentPos() : 0;
    m_content_scrollv.CurrentPos(v);
    // --- Get the number of displayed items in the content list
    total = ::ArraySize(m_cd_list_index);
    for (int r = 0; r < m_visible_items_total; r++) {
      // --- Check to prevent out of range
      if (v >= 0 && v < total) {
        // --- Get the general index of the tree list item
        int li = m_cd_list_index[v];
        // --- Set coordinates and width
        m_content_items[li].MouseFocus(false);
        m_content_items[li].UpdateWidth(w);
        m_content_items[li].UpdateX(m_treeview_width + 1);
        m_content_items[li].Moving();
        m_content_items[li].Update(true);
        v++;
      }
    }
    // ---Draw border
     m_canvas.LineVertical(m_treeview_width, y1, y2,
                          ::ColorToARGB(m_border_color));
    // --- Calculate and set the coordinates for the scroll bar of the tree list
     m_scrollv.XDistance(m_treeview_width - 15);
    // --- Update element
     m_canvas.Update();
  }
 //+------------------------------------------------------------------+
 // | Adds an item to the array of displayed items |
 // | in tree list |
 //+------------------------------------------------------------------+
 void CTreeView::AddDisplayedTreeItem(const int list_index)
  {
    // --- Increase the size of the arrays by one element
     int array_size = ::ArraySize(m_td_list_index);
     ::ArrayResize(m_td_list_index, array_size + 1);
    // --- Save the values ​​of the passed parameters
     m_td_list_index[array_size] = list_index;
  }
 //+------------------------------------------------------------------+
 // | Generates a tree list |
 //+------------------------------------------------------------------+
 void CTreeView::FormTreeList(void) 
  {
    // --- Arrays to control the sequence of items:
      int l_prev_node_list_index[]; // general list index of the previous node
      int l_item_index[];           // local item index
      int l_items_total[];          // number of points in a node
      int l_folders_total[];        // number of folders in a node
    // --- Set the initial size of the arrays
      int begin_size = m_max_node_level + 2;
      ::ArrayResize(l_prev_node_list_index, begin_size);
      ::ArrayResize(l_item_index, begin_size);
      ::ArrayResize(l_items_total, begin_size);
      ::ArrayResize(l_folders_total, begin_size);
    // --- Initializing arrays
      ::ArrayInitialize(l_prev_node_list_index, -1);
      ::ArrayInitialize(l_item_index, -1);
      ::ArrayInitialize(l_items_total, -1);
      ::ArrayInitialize(l_folders_total, -1);
    // --- Free the array of displayed tree list items
      ::ArrayFree(m_td_list_index);
    // --- Counter of local indexes of points
      int ii = 0;
    // --- To set the flag of the last item in the root directory
      bool end_list = false;
    // --- We collect the displayed items into an array. The loop will run until:
    // 1: node counter is not greater than the maximum;
    // 2: did not reach the last item (after checking all the items included in it); 
    // 3: The user did not uninstall the program.
      int items_total = ::ArraySize(m_items);
      for (int nl = m_min_node_level; nl <= m_max_node_level && !end_list; nl++) 
       {
        for (int i = 0; i < items_total && !::IsStopped(); i++) 
         {
          // --- If the "Show folders only" mode is enabled
           if (m_file_navigator_mode == FN_ONLY_FOLDERS) 
            {
             // --- If it is a file, go to the next step
             if (!m_t_is_folder[i])
               continue;
            }
          // --- If (1) this is not our node or (2) the sequence of local item
          // indices is not respected, let's move on to the next one
          // --- NOTE (Anhnt, 2026-07-20 - "XAUUSDm missing from m_treeview_SymbolTF" bug):
          // --- this silently DROPS item i from the displayed list whenever its item_index
          // --- isn't strictly greater than the max already seen at this node_level so far -
          // --- no error, no log, just missing from the tree. Caller code (AddTreeItem's
          // --- item_index argument) MUST assign item_index in the exact same order items are
          // --- added (list_index order) within a given node_level - it CANNOT be based on any
          // --- external sort/id (e.g. a raw source-array index) if the caller's own visiting/
          // --- insertion order doesn't match that external ordering. Worked around on the
          // --- GUIPannel.mqh call site (CGUIPannel::PopulateSymbolTFTree) instead of fixing
          // --- here - revisit if this bites another caller.
           if (nl != m_t_node_level[i] || m_t_item_index[i] <= l_item_index[nl])
            continue;
          // --- Let's move on to the next point if (1) is not currently in the root
          // directory and (2) the total index of the list of the previous node is
          // not equal to the same one in memory
           if (nl > m_min_node_level &&
             m_t_prev_node_list_index[i] != l_prev_node_list_index[nl])
             continue;
          // --- Remember the local index of the item if the next one is not less
          // than the size of the local list
           if (m_t_item_index[i] + 1 >= l_items_total[nl])
             ii = m_t_item_index[i];
          // --- If the list of the current item is expanded
           if (m_t_item_state[i]) 
            {
             // --- Add an item to the array of displayed items in the tree list
              AddDisplayedTreeItem(i);
             // --- Let's remember the current values ​​and move on to the next node
              int n = nl + 1;
              l_prev_node_list_index[n] = m_t_list_index[i];
              l_item_index[nl] = m_t_item_index[i];
              l_items_total[n] = m_t_items_total[i];
              l_folders_total[n] = m_t_folders_total[i];
             // --- Reset the counter of local item indexes
              ii = 0;
             // --- Let's move on to the next node
              break;
            }
          // --- Add an item to the array of displayed items in the tree list
            AddDisplayedTreeItem(i);
          // --- Increase the counter of local item indexes
            ii++;
          // --- If you have reached the last item in the root directory
            if (nl == m_min_node_level && ii >= m_root_items_total) 
             {
             // --- Set the flag and end the current loop
               end_list = true;
               break;
             }
          // --- If you have not yet reached the last item in the root directory
            else if (nl > m_min_node_level) 
             {
              // --- Get the number of points in the current node
              int total = (m_file_navigator_mode == FN_ONLY_FOLDERS)
                          ? l_folders_total[nl]
                          : l_items_total[nl];
            // --- If this is not the last local index of the item, move on to the next one
            if (ii < total)
              continue;
            // --- If you have reached the last local index, then
            // you need to return to the previous node and continue from the point where you stopped
            while (true) 
            {
             // --- Reset the values of the current node in the arrays listed below
              l_prev_node_list_index[nl] = -1;
              l_item_index[nl] = -1;
              l_items_total[nl] = -1;
             // --- Decrease the node counter until equality in the number of items
             // in local lists is maintained or did not reach the root directory
              if (l_item_index[nl - 1] + 1 >= l_items_total[nl - 1]) {
                if (nl - 1 == m_min_node_level)
                  break;
                //---
                nl--;
                continue;
              }
             //---
              break;
            }
          // --- Let's go to the previous node
           nl = nl - 2;
          // --- Reset the counter of local indexes of points and move on to the next node
            ii = 0;
            break;
            }
         }
       }
    // --- List redrawing
    RedrawTreeList();
  }
 //+------------------------------------------------------------------+
 // | Generates a list of contents |
 //+------------------------------------------------------------------+
 void CTreeView::FormContentList(void)
  {
    if(!m_show_item_content) return;
    // --- Index of the selected item
     int li = m_selected_item_index;
    // --- Free the content list arrays
      ::ArrayFree(m_cd_item_text);
      ::ArrayFree(m_cd_list_index);
      ::ArrayFree(m_cd_tree_list_index);
    // --- Let's create a list of contents
     int items_total = ::ArraySize(m_items);
     for (int i = 0; i < items_total; i++) 
      {
       // --- If (1) node levels and (2) local item indices match, as well as
       // (3) index of the previous node with the index of the selected item
        if (m_t_node_level[i] == m_t_node_level[li] + 1 &&
          m_t_prev_node_item_index[i] == m_t_item_index[li] &&
          m_t_prev_node_list_index[i] == li) 
         {
          // --- Increase the arrays of displayed content list items
           int size = ::ArraySize(m_cd_list_index);
           int new_size = size + 1;
           ::ArrayResize(m_cd_item_text, new_size);
           ::ArrayResize(m_cd_list_index, new_size);
           ::ArrayResize(m_cd_tree_list_index, new_size);
          // --- Let's save the text of the item and the general index of the tree
          // list in arrays
           m_cd_item_text[size] = m_t_item_text[i];
           m_cd_tree_list_index[size] = m_t_list_index[i];
          }
      }
    // --- If in the end the list is not empty, fill the array of general indexes of the content list
     int cd_items_total = ::ArraySize(m_cd_list_index);
     if (cd_items_total > 0) 
      {
       // --- Point counter
        int c = 0;
       // --- Let's go through the list
        int c_items_total = ::ArraySize(m_c_list_index);
        for (int i = 0; i < c_items_total; i++) 
         {
          // --- If the description and general indexes of the tree list items match
           if (m_c_item_text[i] == m_cd_item_text[c] &&
            m_c_tree_list_index[i] == m_cd_tree_list_index[c]) 
            {
             // --- Let's save the general index of the content list and move on to
             // the next one
              m_cd_list_index[c] = m_c_list_index[i];
              c++;
             // --- Exit the loop if the end of the displayed list is reached
              if (c >= cd_items_total)
                break;
            }
         }
      }
    // --- List redrawing
    RedrawContentList();
  }
 //+------------------------------------------------------------------+
 // | List redraw |
 //+------------------------------------------------------------------+
 void CTreeView::RedrawTreeList(void) 
  {
    // --- Exit if element is hidden
     if (!CElementBase::IsVisible())
       return;
    // --- Hide list items
     int items_total = ::ArraySize(m_items);
     for (int i = 0; i < items_total; i++)
       m_items[i].Hide();
    // --- Hide scrollbar
      m_scrollv.Hide();
    // --- Y coordinate of the first item in the tree list
     int y = 1;
    // --- Get the number of points
     m_items_total = ::ArraySize(m_td_list_index);
    // --- Adjust scrollbar sizes
     m_scrollv.Reinit(m_items_total, m_visible_items_total);
     m_scrollv.ChangeYSize(m_y_size - 2);
     m_scrollv.Update(true);
    // --- Calculation of the width of tree list items
     int w = 0;
     if (m_show_item_content)
      w = (m_scrollv.IsScroll()) ? m_treeview_width - m_scrollv.ScrollWidth() - 2
                                : m_treeview_width - 1;
     else
      w = (m_scrollv.IsScroll()) ? m_treeview_width - m_scrollv.ScrollWidth() - 3
                                : m_treeview_width - 2;
    // --- Set new values
    for (int i = 0; i < m_items_total; i++) 
     {
      // --- Calculate the Y coordinate for each point
       y = (i > 0) ? y + m_item_y_size : y;
      // --- Get the general index of the item in the list
       int li = m_td_list_index[i];
      // --- Update coordinates and size
        m_items[li].UpdateY(y);
        m_items[li].UpdateWidth(w);
     }
    //Fixing Hide. Add here
     // --- Redraw and push each item's bitmap (UpdateWidth() above blanked it via Resize())
       //UpdateTreeList();
    // --- Show list items
     for (int i = 0; i < items_total; i++)
      m_items[i].Show();
    // --- Update coordinates and list size
     ShiftTreeList();
  }
 //+------------------------------------------------------------------+
 // | Redrawing the contents list |
 //+------------------------------------------------------------------+
 void CTreeView::RedrawContentList(void) 
  {
    // --- Exit if (1) item contents do not need to be shown or (2) tabbed mode is
    // enabled
    if (!m_show_item_content || m_tab_items_mode)
      return;
    // --- Number of list items
     int content_items_total = ::ArraySize(m_content_items);
    // --- If the element is not hidden, hide the list items
     if (CElementBase::IsVisible()) 
      {
       for (int i = 0; i < content_items_total; i++)
         m_content_items[i].Hide();
       // --- Hide scrollbar
        m_content_scrollv.Hide();
      }
    // --- Y coordinate of the first item in the tree list
    int y = 1;
    // --- Get the number of points
    int items_total = ::ArraySize(m_cd_list_index);
    // --- Adjust scrollbar sizes
     m_content_scrollv.Reinit(items_total, m_visible_items_total);
     m_content_scrollv.ChangeYSize(m_y_size - 2);
     m_content_scrollv.Update(true);
    // --- Calculation of the width of tree list items
     int w = (m_content_scrollv.IsScroll())
                ? m_x_size - m_treeview_width - m_scrollv.ScrollWidth() - 3
                : m_x_size - m_treeview_width - 2;
    // --- Set new values
     for (int i = 0; i < items_total; i++) 
      {
       // --- Calculate the Y coordinate for each point
        y = (i > 0) ? y + m_item_y_size : y;
       // --- Get the general index of the item in the list
        int li = m_cd_list_index[i];
       // --- Update coordinates and size
        m_content_items[li].UpdateY(y);
        m_content_items[li].UpdateWidth(w);
      }
    // --- If the element is not hidden, show list items
    if (CElementBase::IsVisible())
     {
      for (int i = 0; i < content_items_total; i++)
        m_content_items[i].Show();
     }
    // --- Update coordinates and list size
     ShiftContentList();
  }
 //+------------------------------------------------------------------+
 // | Updates the list |
 //+------------------------------------------------------------------+
 void CTreeView::UpdateTreeList(const bool redraw = false)
  {
    int items_total = ArraySize(m_td_list_index);
    for(int i = 0; i < items_total; i++) {
        int li = m_td_list_index[i];
        if(redraw)
            m_items[li].Update(true);
        else
        {
            m_items[li].Draw();
            m_items[li].CanvasPointer().Update(false);
        }
    }
  }
 //+------------------------------------------------------------------+
 // | Updates the content list |
 //+------------------------------------------------------------------+
 void CTreeView::UpdateContentList(void)
  {
    if(!m_show_item_content) return;
    int items_total = ::ArraySize(m_cd_list_index);
    int content_size = ::ArraySize(m_content_items);
    for (int i = 0; i < items_total; i++) 
     {
      int li = m_cd_list_index[i];
      if(li < 0 || li >= content_size) continue;
      m_content_items[li].Update(true);
     }
  }
 //+------------------------------------------------------------------+
 //| Checking the index of the selected item to see if it is out of range |
 //+------------------------------------------------------------------+
 void CTreeView::CheckSelectedItemIndex(void) 
  {
    // --- If the index is not defined
    if (m_selected_item_index == WRONG_VALUE) {
      // --- The first item in the list will be highlighted
      m_selected_item_index = 0;
      return;
    }
    // --- Check for out of range
    int array_size = ::ArraySize(m_items);
    if (array_size < 1 || m_selected_item_index < 0 ||
        m_selected_item_index >= array_size) 
        {
          // --- The first item in the list will be highlighted
           m_selected_item_index = 0;
           return;
        }
  }
 //+------------------------------------------------------------------+
 //| Draws a border between areas                                     |
 //+------------------------------------------------------------------+
 void CTreeView::DrawResizeBorder(void) 
  {
    // --- Exit if mode is disabled
     if (!m_show_item_content)
       return;
    // --- Coordinates
     int x = m_treeview_width;
     int y1 = 0, y2 = m_y_size;
    // --- Draw a line
     m_canvas.LineVertical(x, y1, y2, ::ColorToARGB(m_border_color));
  }
 //+------------------------------------------------------------------+
 // | Change the width along the right edge of the form |
 //+------------------------------------------------------------------+
 void CTreeView::ChangeWidthByRightWindowSide(void) 
  {
    // --- Exit if the mode of fixing to the right edge of the form is enabled
     if (m_anchor_right_window_side)
      return;
    // --- Coordinates and width
     int x = 0, w = 0;
    // --- Dimensions
     int x_size = m_main.X2() - CElementBase::X() - m_auto_xresize_right_offset;
     int y_size = (m_auto_yresize_mode) ? m_main.Y2() - CElementBase::Y() -
                                            m_auto_yresize_bottom_offset
                                      : m_y_size;
    // --- Set new size
     CElementBase::XSize(x_size);
     m_canvas.XSize(x_size);
     m_canvas.Resize(x_size, y_size);
    // ---If without content list
     if (!m_show_item_content) 
     {
       // --- Calculate and set the width for items in the list
        w = (m_scrollv.IsScroll())
              ? CElementBase::XSize() - m_scrollv.ScrollWidth() - 3
              : CElementBase::XSize() - 2;
       //---
        int v = (m_scrollv.IsScroll()) ? m_scrollv.CurrentPos() : 0;
       // --- Get the number of displayed items in the content list
        int total = ::ArraySize(m_td_list_index);
        for (int r = 0; r < m_visible_items_total; r++) 
        {
          // --- Check to prevent out of range
          if (v >= 0 && v < total) 
         {
          // --- Get the general index of the tree list item
          int li = m_td_list_index[v];
          // --- Set coordinates and width
          m_items[li].UpdateWidth(w);
          m_items[li].Draw();
          v++;
         }
        }
      }
    // ---If there is a content list
    else 
     {
      w = (m_content_scrollv.IsScroll())
              ? m_x_size - m_treeview_width - m_content_scrollv.ScrollWidth() - 2
              : m_x_size - m_treeview_width - 2;
      //---
       int v = (m_content_scrollv.IsScroll()) ? m_content_scrollv.CurrentPos() : 0;
      // --- Get the number of displayed items in the content list
       int total = ::ArraySize(m_cd_list_index);
       for (int r = 0; r < m_visible_items_total; r++) 
        {
         // --- Check to prevent out of range
         if (v >= 0 && v < total) 
          {
           // --- Get the general index of the tree list item
            int li = m_cd_list_index[v];
           // --- Set coordinates and width
            m_content_items[li].UpdateWidth(w);
            m_content_items[li].Draw();
            v++;
          }
        }
     }
    // --- Redraw element
    Draw();
    //Add here to fix 
       m_canvas.Update(true); 
  } 
 void CTreeView::ChangeHeightByBottomWindowSide(void)
  {
   if(m_anchor_bottom_window_side) return;
   int y_size = m_main.Y2() - CElementBase::Y() - m_auto_yresize_bottom_offset;
   if(y_size == m_y_size) return;     
   CElementBase::YSize(y_size);
   m_canvas.YSize(y_size);
   m_canvas.Resize(m_x_size, y_size);
   // Recompute visible rows for the new height, same formula as InitializeProperties
    m_visible_items_total = (y_size - 2) / m_item_y_size;
    m_scrollv.Reinit(m_items_total, m_visible_items_total);
    m_scrollv.ChangeYSize(y_size - 2);   // --- let the scrollbar resize itself properly
    if(m_show_item_content)
      {
       m_content_scrollv.Reinit(::ArraySize(m_content_items), m_visible_items_total);
       m_content_scrollv.ChangeYSize(y_size - 2);
      }   
     Draw();          
     Moving();          
  }
 int CTreeView::ItemPrevNode(int index) const
  { 
    if(index < 0 || index >= ArraySize(m_t_prev_node_list_index)) return -1;
    return m_t_prev_node_list_index[index]; 
  }
//+------------------------------------------------------------------+
#endif // CTREEVIEW_MQH_IMPLEMENTATION
#endif // __TREEVIEW_MQH__
