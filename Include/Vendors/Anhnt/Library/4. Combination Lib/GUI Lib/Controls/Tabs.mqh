//+------------------------------------------------------------------+
//|                                                         Tabs.mqh |
//|                        Copyright 2015, MetaQuotes Software Corp. |
//|Library base on Link https://www.mql5.com/en/code/19703           |
//+------------------------------------------------------------------+
#ifndef __TABS_MQH__
#define __TABS_MQH__
#include "..\Element.mqh"
#include "ButtonsGroup.mqh"
//+------------------------------------------------------------------+
// | Class for creating tabs |
//+------------------------------------------------------------------+
class CTabs : public CElement
  {
   private:
     //Private properties:
      // --- Instances to create an element
         CButtonsGroup     m_tabs;
      // --- Structure of properties and arrays of elements assigned to each tab
      struct TElements
       {
         CElement         *elements[];
       };
      TElements         m_tab[];
      // --- Positioning tabs
         ENUM_TABS_POSITION m_position_mode;
      // --- Y Axis Tabs Size
         int               m_tab_y_size;
      // --- Index of the selected tab
         int               m_selected_tab;
     //Private methods:private:
         void              InitializeProperties(const int x_gap,const int y_gap);
         bool              CreateCanvas(void);
         bool              CreateButtons(void);         
       // --- Handling clicks on a tab
         bool              OnClickTab(const int id,const int index);
       // --- Width of all tabs
         int               SumWidthTabs(void);
       // --- Checking the index of the selected tab
         void              CheckTabIndex();
       // --- Change the width along the right edge of the window
         virtual void      ChangeWidthByRightWindowSide(void);
       // --- Change the height along the bottom edge of the window
         virtual void      ChangeHeightByBottomWindowSide(void);
       // --- Draws the background of the element area
         void              DrawMainArea(void);
       // --- Draws a tab label
         void              DrawPatch();      
   public:
                        CTabs(void);
                        ~CTabs(void);
      // --- Methods for creating tabs
         bool              CreateTabs(const int x_gap,const int y_gap);      
      // --- Returns a pointer to a group of buttons
         CButtonsGroup    *GetButtonsGroupPointer(void) { return(::GetPointer(m_tabs)); }
      // --- (1) returns the number of tabs,
      // (2) sets/gets the position of the tabs (top/bottom/left/right), (3) sets the size of the tabs along the Y axis
         int               TabsTotal(void)                           const { return(m_tabs.ButtonsTotal()); }
         void              PositionMode(const ENUM_TABS_POSITION mode)     { m_position_mode=mode;          }
         ENUM_TABS_POSITION PositionMode(void)                       const { return(m_position_mode);       }
         void              TabsYSize(const int y_size);
      // --- (1) Saves and (2) returns the index of the selected tab
         void              SelectedTab(const int index)                    { m_selected_tab=index;          }
         int               SelectedTab(void)                         const { return(m_selected_tab);        }
      // --- Sets the text at the specified index
         void              Text(const uint index,const string text);
      // --- Highlights the specified tab
         void              SelectTab(const int index);
      // --- Adds a tab
         void              AddTab(const string tab_text="",const int tab_width=50);
      // --- Adds an element to the tab array
         void              AddToElementsArray(const int tab_index,CElement &object);
      // --- Show items in the selected tab only
         void              ShowTabElements(void);      
      // ---Graph event handler
         virtual void      OnEvent(const int id,const long &lparam,const double &dparam,const string &sparam);
      // --- Management
         virtual void      Show(void);
         virtual void      Hide(void);
         virtual void      Delete(void);
      // --- Draws an element
         virtual void      Draw(void);
      // --- Updates the element to reflect the latest changes
         virtual void      Update(void);      
  };
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
   // | Creates a "Tabs" element |
   //+------------------------------------------------------------------+
   bool CTabs::CreateTabs(const int x_gap,const int y_gap)
     {
   // --- Quit if there is no pointer to the main element
      if(!CElement::CheckMainPointer())
         return(false);
   // --- If there are no tabs in the group, report it
      if(TabsTotal()<1)
        {
         ::Print(__FUNCTION__," > Вызов этого метода нужно осуществлять, "
                 "когда в группе есть хотя бы одна вкладка! Воспользуйтесь методом CTabs::AddTab()");
         return(false);
        }
   // --- Initializing properties
      InitializeProperties(x_gap,y_gap);
   // ---Creating an element
      if(!CreateButtons())
         return(false);
      if(!CreateCanvas())
         return(false);
   //--- 
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
         ::Print(__FUNCTION__," > Вызов этого метода нужно осуществлять, "
                 "когда в группе есть хотя бы одна вкладка! Воспользуйтесь методом CTabs::AddTabs()");
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
   // --- Quit if tabs are hidden
      if(!CElementBase::IsVisible())
         return;
   // --- Checking the index of the selected tab
      CheckTabIndex();
   //---
      uint tabs_total=TabsTotal();
      for(uint i=0; i<tabs_total; i++)
        {
         // --- Get the number of elements attached to the tab
         int tab_elements_total=::ArraySize(m_tab[i].elements);
         // --- If this tab is selected
         if(i==m_selected_tab)
           {
            // --- Show tab items
            for(int j=0; j<tab_elements_total; j++)
              {
               // --- Show items
               CElement *el=m_tab[i].elements[j];
               el.Reset();
               // --- If this element is 'Tabs', then show the elements open
               CTabs *tb=dynamic_cast<CTabs*>(el);
               if(tb!=NULL)
                  tb.ShowTabElements();
              }
           }
         // --- Hide elements of inactive tabs
         else
           {
            for(int j=0; j<tab_elements_total; j++)
               m_tab[i].elements[j].Hide();
           }
        }
   // --- Send a message about this
      ::EventChartCustom(m_chart_id,ON_CLICK_TAB,CElementBase::Id(),m_selected_tab,"");
     }
   //+------------------------------------------------------------------+
   // | Show |
   //+------------------------------------------------------------------+
   void CTabs::Show(void)
     {
   // --- Exit if element is already visible
      if(CElementBase::IsVisible())
         return;
   // --- Visibility state
      CElementBase::IsVisible(true);
   // --- Update object position
      Moving();
   // --- Show items
      int elements_total=ElementsTotal();
      for(int i=0; i<elements_total; i++)
        {
         if(!m_elements[i].IsDropdown())
            m_elements[i].Show();
        }
   // --- Show object (must be on top of button group)
      ::ObjectSetInteger(m_chart_id,m_canvas.ChartObjectName(),OBJPROP_TIMEFRAMES,OBJ_ALL_PERIODS);
     }
   //+------------------------------------------------------------------+
   // | Hide |
   //+------------------------------------------------------------------+
   void CTabs::Hide(void)
     {
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
   // --- Exit if snap to right side of window mode is enabled
      if(m_anchor_right_window_side)
         return;
   // --- Dimensions
      int x_size=0;
   // --- Calculate and set a new size for the element's background
      x_size=m_main.X2()-m_canvas.X()-m_auto_xresize_right_offset;
      
   // --- Do not resize if less than the specified limit
      if(x_size == m_x_size)
         return;
   //---
      CElementBase::XSize(x_size);
      m_canvas.XSize(x_size);
      m_canvas.Resize(x_size,m_y_size);
      
   // --- Redraw element
      Draw();
   // --- Update object position
      Moving();
     }
   //+------------------------------------------------------------------+
   // | Change the height along the bottom edge of the window |
   //+------------------------------------------------------------------+
   void CTabs::ChangeHeightByBottomWindowSide(void)
     {
   // --- Exit if snap to bottom of window mode is enabled
      if(m_anchor_bottom_window_side)
         return;
   // --- Dimensions
      int y_size=0;
   // --- Calculate and set a new size for the element's background
      y_size=m_main.Y2()-m_canvas.Y()-m_auto_yresize_bottom_offset;
   // --- Do not resize if less than the specified limit
      if(y_size==m_y_size)
         return;
   //---
      CElementBase::YSize(y_size);
      m_canvas.YSize(y_size);
      m_canvas.Resize(m_x_size,y_size);
   // --- Redraw element
      Draw();
   // --- Update object position
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
     }
   //+------------------------------------------------------------------+
 #endif // CTABS_MQH_IMPLEMENTATION
#endif // __TABS_MQH__
