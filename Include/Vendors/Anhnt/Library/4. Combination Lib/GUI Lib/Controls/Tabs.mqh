//+------------------------------------------------------------------+
//|                                                         Tabs.mqh |
//|                        Copyright 2015, MetaQuotes Software Corp. |
//|Library base on Link https://www.mql5.com/en/code/19703           |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//| Class for creating tabs                                          |
//+------------------------------------------------------------------+

#ifndef CTABS_MQH
#define CTABS_MQH
 #include "..\Element.mqh"
 #include "ButtonsGroup.mqh" 
 
 #ifndef CTABS_MQH_DECLARATION
 #define CTABS_MQH_DECLARATION
 class CTabs : public CElement
  {
   private:
     //Private properties:
         CButtonsGroup     m_tabs; // --- Instances to create an element
         CButton           m_btn_scroll_left;
         CButton           m_btn_scroll_right;
         int               m_scroll_first_visible;
      // --- Structure of properties and arrays of elements assigned to each tab
      struct TElements
       {
         CElement         *elements[];
       };
      TElements          m_tab[];
      ENUM_TABS_POSITION m_position_mode; // --- Positioning tabs
      int                m_tab_y_size;    // --- Y Axis Tabs Size
      int                m_selected_tab;  // --- Index of the selected tab
     //Private methods:private:
         void              InitializeProperties(const int x_gap,const int y_gap);
         bool              CreateCanvas(void);
         bool              CreateButtons(void);         
         bool              OnClickTab(const int id,const int index); // --- Handling clicks on a tab
         int               SumWidthTabs(void);                       // --- Width of all tabs
         void              CheckTabIndex();                          // --- Checking the index of the selected tab
         virtual void      ChangeWidthByRightWindowSide(void);       // --- Change the width along the right edge of the window
         virtual void      ChangeHeightByBottomWindowSide(void);     // --- Change the height along the bottom edge of the window
         void              DrawMainArea(void);                       // --- Draws the background of the element area
         void              DrawPatch();                              // --- Draws a tab label
        //New method here
          void  ShiftTabsHeader(void);
          bool  CreateScrollButtons(void);
          bool  IsTabsOverflow(void);
          void  UpdateScrollButtonsVisibility(void);
          bool  OnClickScrollLeft(const uint id,const uint idx);
          bool  OnClickScrollRight(const uint id,const uint idx);
   public:
                        CTabs(void);
                        ~CTabs(void);
         bool              CreateTabs(const int x_gap,const int y_gap); // --- Methods for creating tabs
         CButtonsGroup    *GetButtonsGroupPointer(void) { return(::GetPointer(m_tabs)); } // --- Returns a pointer to a group of buttons
      // --- (1) returns the number of tabs,
      // (2) sets/gets the position of the tabs (top/bottom/left/right), (3) sets the size of the tabs along the Y axis
         int               TabsTotal(void)                           const { return(m_tabs.ButtonsTotal()); }
         void              PositionMode(const ENUM_TABS_POSITION mode)     { m_position_mode=mode;          }
         ENUM_TABS_POSITION PositionMode(void)                       const { return(m_position_mode);       }
         void              TabsYSize(const int y_size);                    // (3) sets the size of the tabs along the Y axis
         void              SelectedTab(const int index)                    { m_selected_tab=index;          } // (1) Saves  
         int               SelectedTab(void)                         const { return(m_selected_tab);        } // (2) returns the index of the selected tab
         void              Text(const uint index,const string text);        // --- Sets the text at the specified index
         void              SelectTab(const int index);                      // --- Highlights the specified tab
         void              AddTab(const string tab_text="",const int tab_width=50); // --- Adds a tab
         void              AddToElementsArray(const int tab_index,CElement &object); // --- Adds an element to the tab array
         void              ShowTabElements(void); // --- Show items in the selected tab only                               
         virtual void      OnEvent(const int id,const long &lparam,const double &dparam,const string &sparam); // ---Graph event handler
      // --- Management
         virtual void      Show(void);
         virtual void      Hide(void);
         virtual void      Moving(const bool only_visible = true);
         virtual void      Delete(void);
      
         virtual void      Draw(void);            // --- Draws an element
         virtual void      Update(void);          // --- Updates the element to reflect the latest changes
  };
 #endif // CTABS_MQH_DECLARATION
 #ifndef CTABS_MQH_IMPLEMENTATION
 #define CTABS_MQH_IMPLEMENTATION
   //+------------------------------------------------------------------+
   //| Constructor                                                      |
   //+------------------------------------------------------------------+
   CTabs::CTabs(void) : m_tab_y_size(22),
                        m_position_mode(TABS_TOP),
                        m_selected_tab(WRONG_VALUE)
     {
      // --- Save the element class name in the base class
        CElementBase::ClassName(CLASS_NAME);
      // ---Tab height
        m_tabs.ButtonYSize(m_tab_y_size);
     }
   //+------------------------------------------------------------------+
   //| Destructor                                                       |
   //+------------------------------------------------------------------+
   CTabs::~CTabs(void)
     {
     }
   //+------------------------------------------------------------------+
   // | Graphics event handler |
   //+------------------------------------------------------------------+
   void CTabs::OnEvent(const int id,const long &lparam,const double &dparam,const string &sparam)
    {
      // --- Forward raw click so each individual button (tabs + 2 scroll arrows)
      // can recognize its own canvas name and fire its own ON_CLICK_BUTTON event.
       if(id==CHARTEVENT_OBJECT_CLICK)
        {
          int tabs_total=TabsTotal();
          for(int i=0;i<tabs_total;i++)
            m_tabs.GetButtonPointer(i).OnEvent(id,lparam,dparam,sparam);
            m_btn_scroll_left.OnEvent(id,lparam,dparam,sparam);
            m_btn_scroll_right.OnEvent(id,lparam,dparam,sparam);
          return;
        }
       if(id==CHARTEVENT_CUSTOM+ON_CLICK_BUTTON)
        {
          if(OnClickScrollLeft((uint)lparam,(uint)dparam) ||
            OnClickScrollRight((uint)lparam,(uint)dparam))
            {
             Update();
             return;
            }
          // --- Not a scroll-button click: let the tab-buttons group process it (regular tab switch)
          m_tabs.OnEvent(id,lparam,dparam,sparam);
          return;
        }
      // --- Handling the event of pressing the left mouse button on an object
       if(id==CHARTEVENT_CUSTOM+ON_CLICK_GROUP_BUTTON)
        {
         // --- Click on tab
          if(OnClickTab((int)lparam,(int)dparam))
            return;
         //---
          return;
        }
    }
   //+------------------------------------------------------------------+
   //| Create scroll buttons                                            |
   //+------------------------------------------------------------------+
   bool CTabs::CreateScrollButtons(void)
    {
     if(m_position_mode!=TABS_TOP && m_position_mode!=TABS_BOTTOM)
      return(true);
     //--- Use the same row as the tab header itself
     int y=(m_position_mode==TABS_TOP)? -m_tab_y_size+1 : 1;
     //--- Left (previous) nav button, pinned to the top-right corner of the header row
      m_btn_scroll_left.MainPointer(this);
      m_btn_scroll_left.NamePart("tabs_scroll_left");
      m_btn_scroll_left.Index(900);
      m_btn_scroll_left.XSize(15);
      m_btn_scroll_left.YSize(m_tab_y_size);
     //Set Color
      m_btn_scroll_left.Alpha(m_alpha);
      m_btn_scroll_left.BackColor(m_back_color);
      m_btn_scroll_left.BackColorHover(m_back_color_hover);
      m_btn_scroll_left.BackColorPressed(m_back_color_pressed);
      m_btn_scroll_left.BorderColor(m_border_color);
      m_btn_scroll_left.BorderColorHover(m_border_color);
      m_btn_scroll_left.BorderColorPressed(m_border_color);
      m_btn_scroll_left.IconXGap(0);
      m_btn_scroll_left.IconYGap(0);
     //Set Icons
      m_btn_scroll_left.IconFile((uint)IMAGE_RESOURCE_BMP16_SCROLL_LEFT_BLACK_BMP);
      m_btn_scroll_left.IconFileLocked((uint)IMAGE_RESOURCE_BMP16_SCROLL_LEFT_BLACK_BMP);   // <-- thêm dòng này
      m_btn_scroll_left.CElement::IconFilePressed((uint)IMAGE_RESOURCE_BMP16_SCROLL_LEFT_WHITE_BMP);
      
      if(m_position_mode==TABS_BOTTOM)
         m_btn_scroll_left.AnchorBottomWindowSide(true);
      if(!m_btn_scroll_left.CreateButton("",m_x_size-30,y))
         return(false);
      CElement::AddToArray(m_btn_scroll_left);
     //--- Right (next) nav button
      m_btn_scroll_right.MainPointer(this);
      m_btn_scroll_right.NamePart("tabs_scroll_right");
      m_btn_scroll_right.Index(901);
      m_btn_scroll_right.XSize(15);
      m_btn_scroll_right.YSize(m_tab_y_size);
     //Set color
      m_btn_scroll_right.Alpha(m_alpha);
      m_btn_scroll_right.BackColor(m_back_color);
      m_btn_scroll_right.BackColorHover(m_back_color_hover);
      m_btn_scroll_right.BackColorPressed(m_back_color_pressed);
      m_btn_scroll_right.BorderColor(m_border_color);
      m_btn_scroll_right.BorderColorHover(m_border_color);
      m_btn_scroll_right.BorderColorPressed(m_border_color);
     //Set Icons
      m_btn_scroll_right.IconXGap(0);
      m_btn_scroll_right.IconYGap(0);
      m_btn_scroll_right.IconFile((uint)IMAGE_RESOURCE_BMP16_SCROLL_RIGHT_BLACK_BMP);
      m_btn_scroll_right.IconFileLocked((uint)IMAGE_RESOURCE_BMP16_SCROLL_RIGHT_BLACK_BMP);
      m_btn_scroll_right.CElement::IconFilePressed((uint)IMAGE_RESOURCE_BMP16_SCROLL_RIGHT_WHITE_BMP);
      if(m_position_mode==TABS_BOTTOM)
         m_btn_scroll_right.AnchorBottomWindowSide(true);
      if(!m_btn_scroll_right.CreateButton("",m_x_size-15,y))
         return(false);
      CElement::AddToArray(m_btn_scroll_right);
      m_scroll_first_visible=0;
      UpdateScrollButtonsVisibility();
      ShiftTabsHeader();
      // --- Force initial draw: CreateCanvas() never paints pixels by itself,
      // and nothing else is guaranteed to call Update(true) on these 2 buttons.
       m_btn_scroll_left.Update(true);
       m_btn_scroll_right.Update(true);
      //Debug
        // Print("My Debug CTabs::UpdateScrollButtonsVisibility m_x_size=",m_x_size," IsTabsOverflow=",IsTabsOverflow(),
        // " left.X=",m_btn_scroll_left.X()," left.IsVisible=",m_btn_scroll_left.IsVisible(),
        // " right.X=",m_btn_scroll_right.X()," right.IsVisible=",m_btn_scroll_right.IsVisible(),
        // " panel.X=",CElementBase::X()," panel.X2=",CElementBase::X2(),
        // " canvas.X=",m_canvas.X()," canvas.XSize=",m_canvas.XSize());


      return(true);
    }
   bool CTabs::IsTabsOverflow(void)
    {
     return(SumWidthTabs()>m_x_size);
    }
   void CTabs::UpdateScrollButtonsVisibility(void)
    {
     if(IsTabsOverflow())
      {
       int left_x_gap=m_x_size-30;
       m_btn_scroll_left.XGap(left_x_gap);
       m_btn_scroll_left.CanvasPointer().XGap(left_x_gap); // sync canvas gap, fix vi tri dung yen
       m_btn_scroll_left.Moving();

       int right_x_gap=m_x_size-15;
       m_btn_scroll_right.XGap(right_x_gap);
       m_btn_scroll_right.CanvasPointer().XGap(right_x_gap); // sync canvas gap, fix vi tri dung yen
       m_btn_scroll_right.Moving();

       m_btn_scroll_left.Show();
       m_btn_scroll_right.Show();
      }
     else
      {
        m_btn_scroll_left.Hide();
        m_btn_scroll_right.Hide();
        m_scroll_first_visible=0;
      }
    //  //Debug
    //   Print("My Debug CTabs::UpdateScrollButtonsVisibility m_x_size=",m_x_size," IsTabsOverflow=",IsTabsOverflow(),
    //   " left.X=",m_btn_scroll_left.X()," left.IsVisible=",m_btn_scroll_left.IsVisible(),
    //   " right.X=",m_btn_scroll_right.X()," right.IsVisible=",m_btn_scroll_right.IsVisible(),
    //   " panel.X=",CElementBase::X()," panel.X2=",CElementBase::X2(),
    //   " canvas.X=",m_canvas.X()," canvas.XSize=",m_canvas.XSize());
    }
   void CTabs::ShiftTabsHeader(void)
    {
     if(!IsTabsOverflow())
      {
       int x=0;
       for(int i=0;i<TabsTotal();i++)
        {
         CButton *btn=m_tabs.GetButtonPointer(i);
         btn.XGap(x);
         btn.CanvasPointer().XGap(x);   // sync canvas gap, fix Content khong di theo
         btn.Show();
         btn.Moving();
         x+=btn.XSize()-1;
        }
       return;
      }
      int offset=0;
      for(int i=0;i<m_scroll_first_visible;i++)
      offset+=m_tabs.GetButtonPointer(i).XSize()-1;
      int x=0;
      for(int i=0;i<TabsTotal();i++)
       {
        CButton *btn=m_tabs.GetButtonPointer(i);
        int new_x=x-offset;
        btn.XGap(new_x);
        btn.CanvasPointer().XGap(new_x);   // sync canvas gap, fix Content khong di theo
        btn.Moving();
        //--- Leave room on the right for the 2 nav buttons (30px)
         bool in_view=(new_x>=0 && new_x+btn.XSize()<=m_x_size-30);
         if(in_view) btn.Show(); else btn.Hide();
         x+=btn.XSize()-1;
       }
    }

   bool CTabs::OnClickScrollLeft(const uint id,const uint idx)
    {
     if(id!=m_btn_scroll_left.Id() || idx!=m_btn_scroll_left.Index())
       return(false);
     if(m_scroll_first_visible>0)
       m_scroll_first_visible--;
     m_btn_scroll_left.IsPressed(false);
     ShiftTabsHeader();
     return(true);
    }
   bool CTabs::OnClickScrollRight(const uint id,const uint idx)
    {
     if(id!=m_btn_scroll_right.Id() || idx!=m_btn_scroll_right.Index())
       return(false);
     int offset=0;
     for(int i=0;i<m_scroll_first_visible;i++)
       offset+=m_tabs.GetButtonPointer(i).XSize()-1;
     if(SumWidthTabs()-offset>m_x_size-30)
       m_scroll_first_visible++;
     m_btn_scroll_right.IsPressed(false);
     ShiftTabsHeader();
     return(true);
    }
   //+------------------------------------------------------------------+
   //| Creates a "Tabs" element |
   //+------------------------------------------------------------------+
   bool CTabs::CreateTabs(const int x_gap,const int y_gap)
    {
     // --- Quit if there is no pointer to the main element
     if(!CElement::CheckMainPointer())
       return(false);
     // --- If there are no tabs in the group, report it
     if(TabsTotal()<1)
      {
       ::Print(__FUNCTION__," > The call to this method should be made "
                "when there is at least one tab in the group! Use the CTabs::AddTab() method");
       return(false);
      }
      // --- Initializing properties
       InitializeProperties(x_gap,y_gap);
      // ---Creating an element
       if(!CreateButtons())
         return(false);
       if(!CreateCanvas())
         return(false); 
       if(!CreateScrollButtons())
          return(false);     
       return(true);
    }
   //+------------------------------------------------------------------+
   // | Initializing properties |
   //+------------------------------------------------------------------+
   void CTabs::InitializeProperties(const int x_gap,const int y_gap)
     {
        m_x        =CElement::CalculateX(x_gap);
        m_y        =CElement::CalculateY(y_gap);
        m_x_size   =(m_x_size<1 || m_auto_xresize_mode)? m_main.X2()-m_x-m_auto_xresize_right_offset : m_x_size;
        m_y_size   =(m_y_size<1 || m_auto_yresize_mode)? m_main.Y2()-m_y-m_auto_yresize_bottom_offset : m_y_size;
      // ---Default background color
        m_back_color         =(m_back_color!=clrNONE)? m_back_color : clrWhiteSmoke;
        m_back_color_hover   =(m_back_color_hover!=clrNONE)? m_back_color_hover : C'229,241,251';
        m_back_color_pressed =(m_back_color_pressed!=clrNONE)? m_back_color_pressed : clrWhite;
      // ---Default frame color
        m_border_color         =(m_border_color!=clrNONE)? m_border_color : C'217,217,217';
        m_border_color_hover   =(m_border_color_hover!=clrNONE)? m_border_color_hover : m_border_color;
        m_border_color_pressed =(m_border_color_pressed!=clrNONE)? m_border_color_pressed : m_border_color;
      // --- Indentation and color of text label
        m_label_color =(m_label_color!=clrNONE)? m_label_color : clrBlack;
        m_label_x_gap =(m_label_x_gap!=WRONG_VALUE)? m_label_x_gap : 0;
        m_label_y_gap =(m_label_y_gap!=WRONG_VALUE)? m_label_y_gap : 0;
      // --- Indents from the extreme point
        CElementBase::XGap(x_gap);
        CElementBase::YGap(y_gap);
      // ---Priority like parent
        CElement::Z_Order(m_main.Z_Order());
     }
   //+------------------------------------------------------------------+
   // | Creates an object to draw |
   //+------------------------------------------------------------------+
   bool CTabs::CreateCanvas(void)
    {
      // --- Formation of object name
        string name=CElementBase::ElementName("tabs");
      // ---Create an object
        if(!CElement::CreateCanvas(name,m_x,m_y,m_x_size,m_y_size))
           return(false);
      //---
      return(true);
    }
   //+------------------------------------------------------------------+
   // | Creates a group of buttons |
   //+------------------------------------------------------------------+
   bool CTabs::CreateButtons(void)
    {
        int x=0,y=0;
      // --- Get the number of tabs
        int tabs_total=TabsTotal();
      // --- If there are no tabs in the group, report it and exit
        if(tabs_total<1)
         {
          ::Print(__FUNCTION__," > The call to this method should be made "
                  "when there is at least one tab in the group! Use the CTabs::AddTabs() method");
          return(false);
         }
      // --- Save the pointer to the main element
        m_tabs.MainPointer(this);
      // --- Calculation of coordinates relative to tab positioning
        if(m_position_mode==TABS_TOP)
         {
          y=-m_tab_y_size+1;
         }
        else if(m_position_mode==TABS_BOTTOM)
         {
          y=1;
          m_tabs.AnchorBottomWindowSide(true);
         }
        else if(m_position_mode==TABS_RIGHT)
         {
          x=1;
          m_tabs.AnchorRightWindowSide(true);
         }
        else if(m_position_mode==TABS_LEFT)
         {
          x=-SumWidthTabs()+1;
         }
      // --- Checking the index of the selected tab
        CheckTabIndex();
      // --- Properties
        m_tabs.NamePart("tab");
        m_tabs.RadioButtonsMode(true);
        m_tabs.IsCenterText(CElement::IsCenterText());
      // --- Create a button group
        if(!m_tabs.CreateButtonsGroup(x,y))
           return(false);
      // --- Add element to array
        CElement::AddToArray(m_tabs);
      //---
        for(int i=0; i<tabs_total; i++)
         {
          m_tabs.GetButtonPointer(i).LabelYGap(2);
          m_tabs.GetButtonPointer(i).BackColor(m_back_color);
          m_tabs.GetButtonPointer(i).BackColorHover(m_back_color_hover);
          m_tabs.GetButtonPointer(i).BackColorPressed(m_back_color_pressed);
          m_tabs.GetButtonPointer(i).BorderColor(m_border_color);
          m_tabs.GetButtonPointer(i).BorderColorHover(m_border_color);
          m_tabs.GetButtonPointer(i).BorderColorPressed(m_border_color);
          m_tabs.GetButtonPointer(i).BorderColorLocked(m_border_color);
         }
      //---
       m_back_color=m_back_color_pressed;
      // --- Select button
       m_tabs.SelectButton(m_selected_tab);
      return(true);
    }
   //+------------------------------------------------------------------+
   // | Sets the height of the tabs |
   //+------------------------------------------------------------------+
   void CTabs::TabsYSize(const int y_size)
    {
      m_tab_y_size=y_size;
      m_tabs.ButtonYSize(y_size);
    }
   //+------------------------------------------------------------------+
   // | Sets the tab text |
   //+------------------------------------------------------------------+
   void CTabs::Text(const uint index,const string text)
    {
      // --- Get the number of tabs
       uint tabs_total=TabsTotal();
      // --- Quit if there are no tabs in the group
        if(tabs_total<1)
           return;
      // --- Adjust index value if out of range
        uint correct_index=(index>=tabs_total)? tabs_total-1 : index;
      // --- Set text
        m_tabs.GetButtonPointer(correct_index).LabelText(text);
    }
   //+------------------------------------------------------------------+
   // | Highlights tab |
   //+------------------------------------------------------------------+
   void CTabs::SelectTab(const int index)
    {
      // --- Get the number of tabs
       uint tabs_total=TabsTotal();
      for(uint i=0; i<tabs_total; i++)
        {
         // --- If this tab is selected
         if(index==i)
           {
            // --- Save the index of the selected tab
            SelectedTab(index);
            //---
            m_tabs.SelectButton(index);
           }
        }
      // --- Show items in the selected tab only
       ShowTabElements();
    }
   //+------------------------------------------------------------------+
   // | Adds a tab |
   //+------------------------------------------------------------------+
   void CTabs::AddTab(const string tab_text,const int tab_width)
    {
      // --- Reserve quantity
       int reserve=10;
      // --- Set size of tab arrays
       int array_size=::ArraySize(m_tab);
       ::ArrayResize(m_tab,array_size+1,reserve);
      // ---Coordinates
      int x=0,y=0;
      if(array_size>0)
        {
         if(m_position_mode==TABS_TOP || m_position_mode==TABS_BOTTOM)
           {
            x=SumWidthTabs()-1;
           }
         else
            y=((array_size*m_tab_y_size)+m_tab_y_size)-m_tab_y_size-array_size;
        }
      // --- Add a button to a group
       m_tabs.AddButton(x,y,tab_text,tab_width,m_back_color,m_back_color_hover,m_back_color_pressed);
    }
   //+------------------------------------------------------------------+
   // | Adds an element to the array of the specified tab |
   //+------------------------------------------------------------------+
   void CTabs::AddToElementsArray(const int tab_index,CElement &object)
    {
      // --- Check for out of range
      int array_size=::ArraySize(m_tab);
      if(array_size<1 || tab_index<0 || tab_index>=array_size)
         return;
      // --- Add the pointer of the passed element to the array of the specified tab
      int size=::ArraySize(m_tab[tab_index].elements);
      ::ArrayResize(m_tab[tab_index].elements,size+1);
      m_tab[tab_index].elements[size]=::GetPointer(object);
    }
   //+------------------------------------------------------------------+
   // | Shows items in the selected tab only |
   //+------------------------------------------------------------------+
   void CTabs::ShowTabElements(void)
    {
     if(!CElementBase::IsVisible())
        return;
     CheckTabIndex();
     uint tabs_total=TabsTotal();
     for(uint i=0; i<tabs_total; i++)
      {
        int tab_elements_total=::ArraySize(m_tab[i].elements);
       // For active tab all child element witll be Visible
        if(i==m_selected_tab)
          {
          for(int j=0; j<tab_elements_total; j++)
            {
              CElement *el=m_tab[i].elements[j];
              // Print("My Debug ShowTabElements RESET obj=", m_canvas.ChartObjectName(),
              //       " i=", i, " target=", el.CanvasPointer().ChartObjectName());
              el.Reset();
              CTabs *tb=dynamic_cast<CTabs*>(el);
              if(tb!=NULL)
                tb.ShowTabElements();
            }
          }
       //For Deactive tab all child element witll be IsVisible
        else
         {
          for(int j=0; j<tab_elements_total; j++)
            {
              // Print("My Debug ShowTabElements HIDE obj=", m_canvas.ChartObjectName(),
              //       " i=", i, " target=", m_tab[i].elements[j].CanvasPointer().ChartObjectName());
              m_tab[i].elements[j].CElementBase::IsVisible(true);
              m_tab[i].elements[j].Hide();
            }
         }
      }
     ::EventChartCustom(m_chart_id,ON_CLICK_TAB,CElementBase::Id(),m_selected_tab,"");
    }
   //+------------------------------------------------------------------+
   // | Show |
   //+------------------------------------------------------------------+
   void CTabs::Show(void)
     {
      //Debug        
        // Print("My Debug CTabs::Show CALLED obj=", m_canvas.ChartObjectName(),
        //  " IsVisible_before=", CElementBase::IsVisible(), " selected_tab=", m_selected_tab);
      // --- Run the canvas-level show only on the real hidden->visible transition
      if(!CElementBase::IsVisible())
        {
         // --- Visibility state
         CElementBase::IsVisible(true);
         // --- Update object position
         Moving();
         // --- Show items
         int elements_total = ElementsTotal();
         for(int i = 0; i < elements_total; i++)
           {
            if(!m_elements[i].IsDropdown())
               m_elements[i].Show();
           }
         // re-apply overflow cropping so any tab that doesn't fit gets hidden again.
         if(m_position_mode == TABS_TOP || m_position_mode == TABS_BOTTOM)
            ShiftTabsHeader();
         // --- Show object (must be on top of button group)
         ::ObjectSetInteger(m_chart_id, m_canvas.ChartObjectName(), OBJPROP_TIMEFRAMES, OBJ_ALL_PERIODS);
        }
      // --- Always re-assert the currently selected sub-tab's own elements,
      // since a parent's generic recursive Show() cascade doesn't know about sub-tab selection
      ShowTabElements();
     }
   void CTabs::Moving(const bool only_visible)
    {
    if(only_visible && !CElementBase::IsVisible())
        return;
    CElement::Moving(only_visible);
    // --- Header layout/tab content only matter while THIS CTabs is actually visible right now —
    // skip them when only repositioning a hidden element for later (only_visible=false bypass)
    if(!CElementBase::IsVisible())
        return;
    if(m_position_mode == TABS_TOP || m_position_mode == TABS_BOTTOM)
        ShiftTabsHeader();
    uint tabs_total = TabsTotal();
    for(uint i = 0; i < tabs_total; i++)
      {
        int tab_elements_total = ::ArraySize(m_tab[i].elements);
        for(int j = 0; j < tab_elements_total; j++)
         {
          //Debug
          //  Print("My Debug CTabs::Moving BEFORE tab elem Moving i=", i, " j=", j,
          //   " obj=", m_tab[i].elements[j].CanvasPointer().ChartObjectName());
          m_tab[i].elements[j].Moving(true);   // --- always respect each child's own visibility  
         }
          
      }
    }
   //+------------------------------------------------------------------+
   // | Hide |
   //+------------------------------------------------------------------+
   void CTabs::Hide(void)
     {
      //Debug 
      //  Print("My Debug CTabs::Hide CALLED obj=", m_canvas.ChartObjectName(), " IsVisible_before=", CElementBase::IsVisible());
      // --- Exit if element is already hidden
      if(!CElementBase::IsVisible())
         return;
      // --- Hide object
       ::ObjectSetInteger(m_chart_id,m_canvas.ChartObjectName(),OBJPROP_TIMEFRAMES,OBJ_NO_PERIODS);
      // --- Visibility state
       CElementBase::IsVisible(false);
       CElementBase::MouseFocus(false);
      // --- Hide elements
       int elements_total=ElementsTotal();
      for(int i=0; i<elements_total; i++)
         m_elements[i].Hide();
      // --- Hide tab items
       int tabs_total=TabsTotal();
       for(int i=0; i<tabs_total; i++)
         {
          int tab_elements_total=::ArraySize(m_tab[i].elements);
          for(int t=0; t<tab_elements_total; t++)
            m_tab[i].elements[t].Hide();
        }
     }
   //+------------------------------------------------------------------+
   // | Removal |
   //+------------------------------------------------------------------+
   void CTabs::Delete(void)
     {
      CElement::Delete();
      // --- Freeing element arrays
       uint tabs_total=TabsTotal();
       for(uint i=0; i<tabs_total; i++)
         ::ArrayFree(m_tab[i].elements);
       //--- 
        ::ArrayFree(m_tab);
        m_back_color=clrNONE;
     }
   //+------------------------------------------------------------------+
   // | Clicking on a tab in a group |
   //+------------------------------------------------------------------+
   bool CTabs::OnClickTab(const int id,const int index)
    {
      // --- Exit if (1) IDs do not match or (2) element is locked
       if(id!=CElementBase::Id() || CElementBase::IsLocked())
         return(false);
      // --- Exit if index does not match
       if(index!=m_tabs.SelectedButtonIndex())
         return(true);
      // --- Save the index of the selected tab
      SelectedTab(index);
      // --- Redraw element
       ::ObjectSetInteger(m_chart_id,m_canvas.ChartObjectName(),OBJPROP_TIMEFRAMES,OBJ_NO_PERIODS);
       CElement::Update(true);
       ::ObjectSetInteger(m_chart_id,m_canvas.ChartObjectName(),OBJPROP_TIMEFRAMES,OBJ_ALL_PERIODS);
      // --- Show items in the selected tab only
       ShowTabElements();
      // --- Send a message about the change in the graphical interface
       ::EventChartCustom(m_chart_id,ON_CHANGE_GUI,CElementBase::Id(),0.0,"");
       return(true);
    }
   //+------------------------------------------------------------------+
   // | Total width of all tabs |
   //+------------------------------------------------------------------+
   int CTabs::SumWidthTabs(void)
    {
      int width=0;
      // --- If tab positioning is on the right or left, return the width of the first tab
       if(m_position_mode==TABS_LEFT || m_position_mode==TABS_RIGHT)
         return(m_tabs.GetButtonPointer(0).XSize());
      // --- Sum up the width of all tabs
       int tabs_total=m_tabs.ButtonsTotal();
       for(int i=0; i<tabs_total; i++)
         {
          width=width+m_tabs.GetButtonPointer(i).XSize();
         }
      // --- Taking into account layering per pixel
       width=width-(tabs_total-1);
      return(width);
    }
   //+------------------------------------------------------------------+
   // | Checking the index of the selected tab |
   //+------------------------------------------------------------------+
   void CTabs::CheckTabIndex(void)
    {
      // --- Check for out of range
       int array_size=::ArraySize(m_tab);
       if(m_selected_tab<0)
         m_selected_tab=0;
       if(m_selected_tab>=array_size)
         m_selected_tab=array_size-1;
    }
   //+------------------------------------------------------------------+
   // | Change the width along the right edge of the form |
   //+------------------------------------------------------------------+
   void CTabs::ChangeWidthByRightWindowSide(void)
    {
      if(m_anchor_right_window_side)
        return;
      int x_size=m_main.X2()-m_canvas.X()-m_auto_xresize_right_offset;
      if(x_size==m_x_size)
        return;
      CElementBase::XSize(x_size);
      m_canvas.XSize(x_size);
      m_canvas.Resize(x_size,m_y_size);
      // --- Header layout / scroll buttons only matter while this CTabs is actually visible right now
      if(CElementBase::IsVisible())
      {
        if(m_position_mode==TABS_TOP || m_position_mode==TABS_BOTTOM)
        {
          UpdateScrollButtonsVisibility();
          ShiftTabsHeader();
        }
      }
      Draw();
      Moving();
    }
   //+------------------------------------------------------------------+
   // | Change the height along the bottom edge of the window |
   //+------------------------------------------------------------------+
   void CTabs::ChangeHeightByBottomWindowSide(void)
    {
     if(m_anchor_bottom_window_side)
        return;
     int y_size=0;
     y_size=m_main.Y2()-m_canvas.Y()-m_auto_yresize_bottom_offset;
     if(y_size==m_y_size)
        return;
     CElementBase::YSize(y_size);
     m_canvas.YSize(y_size);
     m_canvas.Resize(m_x_size,y_size);
     Draw();
     Moving();
    }
   //+------------------------------------------------------------------+
   // | Draws an element |
   //+------------------------------------------------------------------+
   void CTabs::Draw(void)
     {
      // --- Draw background
       CElement::DrawBackground();
      // --- Draw a frame
       CElement::DrawBorder();
      // --- Draw a label for the selected tab
       DrawPatch();
     }
   //+------------------------------------------------------------------+
   // | Draws a tab label |
   //+------------------------------------------------------------------+
   void CTabs::DrawPatch(void)
    {
      // --- Coordinates
       int x1 =0,x2 =0;
       int y1 =0,y2 =0;
      //---
       if(m_position_mode==TABS_TOP)
         {
          x1 =m_tabs.GetButtonPointer(m_selected_tab).XGap()+1;
          x2 =x1+m_tabs.GetButtonPointer(m_selected_tab).XSize()-3;
         }
       else if(m_position_mode==TABS_BOTTOM)
         {
          x1 =m_tabs.GetButtonPointer(m_selected_tab).XGap()+1;
          x2 =x1+m_tabs.GetButtonPointer(m_selected_tab).XSize()-3;
          y1 =YSize()-1;
          y2 =y1;
         }
      else if(m_position_mode==TABS_LEFT)
        {
         y1 =m_tabs.GetButtonPointer(m_selected_tab).YGap()+1;
         y2 =y1+m_tabs.GetButtonPointer(m_selected_tab).YSize()-3;
        }
      else if(m_position_mode==TABS_RIGHT)
        {
         x1 =XSize()-1;
         x2 =x1;
         y1 =m_tabs.GetButtonPointer(m_selected_tab).YGap()+1;
         y2 =y1+m_tabs.GetButtonPointer(m_selected_tab).YSize()-3;
        }
      // --- Define the color for the line
       color clr=m_back_color;
       if(m_tabs.GetButtonPointer(m_selected_tab).CElementBase::IsLocked())
         clr=m_tabs.GetButtonPointer(m_selected_tab).BackColorLocked();
      // --- Draw a line
       m_canvas.Line(x1,y1,x2,y2,::ColorToARGB(clr,m_alpha));
    }
   //+------------------------------------------------------------------+
   // | Item Update |
   //+------------------------------------------------------------------+
   void CTabs::Update(void)
    {
      // --- Draw background
       CElement::Update(true);
      // --- Draw buttons
       int tabs_total=TabsTotal();
       for(int i=0; i<tabs_total; i++)
         m_tabs.GetButtonPointer(i).Update(true);
      // --- New Add Draw scroll nav buttons (never auto-drawn otherwise)
       if(m_position_mode==TABS_TOP || m_position_mode==TABS_BOTTOM)
        {
         m_btn_scroll_left.Update(true);
         m_btn_scroll_right.Update(true);
        }
    }
 #endif // CTABS_MQH_IMPLEMENTATION
#endif // CTABS_MQH