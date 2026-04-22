//+------------------------------------------------------------------+
//|                                                StandardChart.mqh |
//|                        Copyright 2015, MetaQuotes Software Corp. |
//|                                              http://www.mql5.com |
//+------------------------------------------------------------------+
#include "..\Element.mqh"
#include "Pointer.mqh"
//+------------------------------------------------------------------+
// | Class for creating a standard graph |
//+------------------------------------------------------------------+
class CStandardChart : public CElement
  {
private:
   // --- Objects for creating an element
   CSubChart         m_sub_chart[];
   CPointer          m_x_scroll;
   // --- Chart properties:
   long              m_sub_chart_id[];
   string            m_sub_chart_symbol[];
   ENUM_TIMEFRAMES   m_sub_chart_tf[];
   // ---Horizontal scroll mode
   bool              m_x_scroll_mode;
   // --- Variables associated with horizontal scrolling of the chart
   int               m_prev_x;
   int               m_new_x_point;
   int               m_prev_new_x_point;
   // --- Mode for changing the height of the subwindow
   bool              m_drag_border_window_mode;
   //---
public:
                     CStandardChart(void);
                    ~CStandardChart(void);
   // ---Methods for creating a standard chart
   bool              CreateStandardChart(const int x_gap,const int y_gap);
   //---
private:
   bool              CreateSubCharts(void);
   bool              CreateXScrollPointer(void);
   //---
public:
   // --- (1) Returns a pointer to the mouse cursor, (2) returns the size of the graph array
   CPointer         *GetMousePointer(void)                        { return(::GetPointer(m_x_scroll)); }
   int               SubChartsTotal(void)                   const { return(::ArraySize(m_sub_chart)); }
   // --- Returns a pointer to a graph object at the specified index
   CSubChart        *GetSubChartPointer(const uint index);
   // ---Horizontal scroll mode
   void              XScrollMode(const bool mode) { m_x_scroll_mode=mode; }
   // --- Adds a graph with the specified properties before creation
   void              AddSubChart(const string symbol,const ENUM_TIMEFRAMES tf);
   // --- Go to the specified date
   void              SubChartNavigate(const datetime date);
   // --- Reset graphs
   void              ResetCharts(void);
   //---
public:
   // ---Graph event handler
   virtual void      OnEvent(const int id,const long &lparam,const double &dparam,const string &sparam);
   // ---Move element
   virtual void      Moving(const bool only_visible=true);
   // --- Management
   virtual void      Show(void);
   virtual void      Hide(void);
   virtual void      Delete(void);
   // --- (1) Installation, (2) reset priorities by pressing the left mouse button
   virtual void      SetZorders(void);
   virtual void      ResetZorders(void);
   //---
private:
   // --- Processing clicks on the chart
   bool              OnClickSubChart(const string clicked_object);

   // --- Character check
   bool              CheckSymbol(const string symbol);
   // ---Horizontal scrolling
   void              HorizontalScroll(void);
   // --- Resetting horizontal scroll variables
   void              ZeroHorizontalScrollVariables(void);

   // --- Checking the mode of resizing the chart subwindow
   bool              CheckDragBorderWindowMode(void);

   // --- Change the width along the right edge of the window
   virtual void      ChangeWidthByRightWindowSide(void);
   // --- Change the height along the bottom edge of the window
   virtual void      ChangeHeightByBottomWindowSide(void);
  };
//+------------------------------------------------------------------+
//| Constructor                                                      |
//+------------------------------------------------------------------+
CStandardChart::CStandardChart(void) : m_prev_x(0),
                                       m_new_x_point(0),
                                       m_prev_new_x_point(0),
                                       m_x_scroll_mode(false),
                                       m_drag_border_window_mode(false)
  {
// --- Save the element class name in the base class
   CElementBase::ClassName(CLASS_NAME);
  }
//+------------------------------------------------------------------+
//| Destructor                                                       |
//+------------------------------------------------------------------+
CStandardChart::~CStandardChart(void)
  {
  }
//+------------------------------------------------------------------+
// | Event Handling |
//+------------------------------------------------------------------+
void CStandardChart::OnEvent(const int id,const long &lparam,const double &dparam,const string &sparam)
  {
// --- Handling the cursor movement event
   if(id==CHARTEVENT_MOUSE_MOVE)
     {
      // --- Quit if in subwindow resize mode
      if(CheckDragBorderWindowMode())
         return;
      // --- If there is focus, check the horizontal scrolling of the graph
      if(CElementBase::MouseFocus())
         HorizontalScroll();
      // --- If there is no focus and the left mouse button is released
      else if(!m_mouse.LeftButtonState())
        {
         if(!m_x_scroll.IsVisible())
            return;
         //---
         m_prev_x=0;
         // --- Hide horizontal scroll pointer
         m_x_scroll.Hide();
         ::ChartRedraw();
         // --- Send a message to determine available elements
         ::EventChartCustom(m_chart_id,ON_SET_AVAILABLE,CElementBase::Id(),1,"");
         // --- Send a message about the change in the graphical interface
         ::EventChartCustom(m_chart_id,ON_CHANGE_GUI,CElementBase::Id(),0,"");
        }
      //---
      return;
     }
// --- Handling the event of pressing the left mouse button on an object
   if(id==CHARTEVENT_OBJECT_CLICK)
     {
      if(OnClickSubChart(sparam))
         return;
     }
  }
//+------------------------------------------------------------------+
// | Creates a "Standard Chart" element |
//+------------------------------------------------------------------+
bool CStandardChart::CreateStandardChart(const int x_gap,const int y_gap)
  {
// --- Quit if there is no pointer to the main element
   if(!CElement::CheckMainPointer())
      return(false);
// --- Initializing properties
   m_x        =CElement::CalculateX(x_gap);
   m_y        =CElement::CalculateY(y_gap);
   m_x_size   =(m_x_size<1 || m_auto_xresize_mode)? m_main.X2()-m_x-m_auto_xresize_right_offset : m_x_size;
   m_y_size   =(m_y_size<1 || m_auto_yresize_mode)? m_main.Y2()-m_y-m_auto_yresize_bottom_offset : m_y_size;
// --- Indents from the extreme point
   CElementBase::XGap(x_gap);
   CElementBase::YGap(y_gap);
// ---Priority is the same as the main element, since the element does not have its own clickable area
   CElement::Z_Order(m_main.Z_Order());
// --- Create a graph
   if(!CreateSubCharts())
      return(false);
   if(!CreateXScrollPointer())
      return(false);
//---
   return(true);
  }
//+------------------------------------------------------------------+
// | Creates graphs |
//+------------------------------------------------------------------+
bool CStandardChart::CreateSubCharts(void)
  {
// --- Get the number of graphs
   int sub_charts_total=SubChartsTotal();
// --- If there are no charts in the group, report it
   if(sub_charts_total<1)
     {
      ::Print(__FUNCTION__," > This method must be called when there is at least one graph in the group! "
              "Use the method CStandardChart::AddSubChart()");
      return(false);
     }
// --- Calculate coordinates and size
   int x=m_x;
   int x_size=(sub_charts_total>1)? m_x_size/sub_charts_total : m_x_size;
// --- Create the specified number of graphs
   for(int i=0; i<sub_charts_total; i++)
     {
      // --- Formation of object name
      string name=CElementBase::ProgramName()+"_sub_chart_"+(string)i+"__"+(string)CElementBase::Id();
      // --- X coordinate calculation
      x=(i>0)? x+x_size-1 : x;
      // ---Adjusting the width of the last chart
      if(i+1>=sub_charts_total)
         x_size=m_x_size-(x_size*(sub_charts_total-1)-(sub_charts_total-1));
      // --- Install the button
      if(!m_sub_chart[i].Create(m_chart_id,name,m_subwin,x,m_y,x_size,m_y_size))
         return(false);
      // --- Hide
      m_sub_chart[i].Timeframes(OBJ_NO_PERIODS);
      // --- Receive and save the identifier of the created chart
      m_sub_chart_id[i]=m_sub_chart[i].GetInteger(OBJPROP_CHART_ID);
      // --- Set properties
      m_sub_chart[i].Symbol(m_sub_chart_symbol[i]);
      m_sub_chart[i].Period(m_sub_chart_tf[i]);
      m_sub_chart[i].Z_Order(m_zorder+1);
      m_sub_chart[i].Tooltip("\n");
      // --- Fixed scale mode
      //::ChartSetInteger(m_sub_chart_id[i],CHART_SCALEFIX,true);
      // ---Maximum and minimum
      //::ChartSetDouble(m_sub_chart_id[i],CHART_FIXED_MAX,2.0);
      //::ChartSetDouble(m_sub_chart_id[i],CHART_FIXED_MIN,1.0);
      // --- Let's save the dimensions
      m_sub_chart[i].XSize(x_size);
      m_sub_chart[i].YSize(m_y_size);
      // --- Indents from the extreme point
      m_sub_chart[i].XGap(CElement::CalculateXGap(x));
      m_sub_chart[i].YGap(CElement::CalculateYGap(m_y));
     }
//---
   return(true);
  }
//+------------------------------------------------------------------+
// | Creates a horizontal scroll cursor pointer |
//+------------------------------------------------------------------+
bool CStandardChart::CreateXScrollPointer(void)
  {
// --- Quit if horizontal scrolling is not needed
   if(!m_x_scroll_mode)
      return(true);
// --- Setting properties
   m_x_scroll.XGap(0);
   m_x_scroll.YGap(-20);
   m_x_scroll.Id(CElementBase::Id());
   m_x_scroll.Type(MP_X_SCROLL);
// ---Creating an element
   if(!m_x_scroll.CreatePointer(m_chart_id,m_subwin))
      return(false);
//---
   return(true);
  }
//+------------------------------------------------------------------+
// | Returns a pointer to the chart at the specified index |
//+------------------------------------------------------------------+
CSubChart *CStandardChart::GetSubChartPointer(const uint index)
  {
   uint array_size=::ArraySize(m_sub_chart);
// --- If there is no schedule, report it
   if(array_size<1)
     {
      ::Print(__FUNCTION__," > This method must be called when there is at least one graph in the group!");
      return(NULL);
     }
// --- Adjustment in case of leaving the range
   uint i=(index>=array_size)? array_size-1 : index;
// --- Return pointer
   return(::GetPointer(m_sub_chart[i]));
  }
//+------------------------------------------------------------------+
// | Adds a graph |
//+------------------------------------------------------------------+
void CStandardChart::AddSubChart(const string symbol,const ENUM_TIMEFRAMES tf)
  {
// --- Let's check if such a symbol exists on the server
   if(!CheckSymbol(symbol))
     {
      ::Print(__FUNCTION__," > The symbol "+symbol+" is not on the server!");
      return;
     }
//---
   int reserve=10;
// --- Increase the size of the arrays by one element
   int array_size=::ArraySize(m_sub_chart);
   int new_size=array_size+1;
   ::ArrayResize(m_sub_chart,new_size,reserve);
   ::ArrayResize(m_sub_chart_id,new_size,reserve);
   ::ArrayResize(m_sub_chart_symbol,new_size,reserve);
   ::ArrayResize(m_sub_chart_tf,new_size,reserve);
// --- Save the values ​​of the passed parameters
   m_sub_chart_symbol[array_size] =symbol;
   m_sub_chart_tf[array_size]     =tf;
  }
//+------------------------------------------------------------------+
// | Go to the specified date |
//+------------------------------------------------------------------+
void CStandardChart::SubChartNavigate(const datetime date)
  {
// --- (1) Current date on the chart and (2) just selected on the calendar
   datetime current_date  =::StringToTime(::TimeToString(::TimeCurrent(),TIME_DATE));
   datetime selected_date =date;
// --- Disable autoscroll and shift from right edge
   ::ChartSetInteger(m_chart_id,CHART_AUTOSCROLL,false);
   ::ChartSetInteger(m_chart_id,CHART_SHIFT,false);
// --- If the date selected in the calendar is greater than the current one
   if(selected_date>=current_date)
     {
      // --- Go to the current date on all charts
      ::ChartNavigate(m_chart_id,CHART_END);
      ResetCharts();
      return;
     }
// --- Get the number of bars from the specified date
   int  bars_total    =::Bars(::Symbol(),::Period(),selected_date,current_date);
   int  visible_bars  =(int)::ChartGetInteger(m_chart_id,CHART_VISIBLE_BARS);
   long seconds_today =::TimeCurrent()-current_date;
   int  bars_today    =int(seconds_today/::PeriodSeconds())+2;
// --- Set the indent from the right edge of all graphs
   m_prev_new_x_point=m_new_x_point=-((bars_total-visible_bars)+bars_today);
   ::ChartNavigate(m_chart_id,CHART_END,m_new_x_point);
//---
   int sub_charts_total=SubChartsTotal();
   for(int i=0; i<sub_charts_total; i++)
     {
      // --- Disable autoscroll and shift from right edge
      ::ChartSetInteger(m_sub_chart_id[i],CHART_AUTOSCROLL,false);
      ::ChartSetInteger(m_sub_chart_id[i],CHART_SHIFT,false);
      // --- Get the number of bars from the specified date
      bars_total   =::Bars(m_sub_chart[i].Symbol(),(ENUM_TIMEFRAMES)m_sub_chart[i].Period(),selected_date,current_date);
      visible_bars =(int)::ChartGetInteger(m_sub_chart_id[i],CHART_VISIBLE_BARS);
      bars_today   =int(seconds_today/::PeriodSeconds((ENUM_TIMEFRAMES)m_sub_chart[i].Period()))+2;
      // --- Indent from the right edge of the chart
      m_prev_new_x_point=m_new_x_point=-((bars_total-visible_bars)+bars_today);
      ::ChartNavigate(m_sub_chart_id[i],CHART_END,m_new_x_point);
     }
  }
//+------------------------------------------------------------------+
// | Reset graphs |
//+------------------------------------------------------------------+
void CStandardChart::ResetCharts(void)
  {
   int sub_charts_total=SubChartsTotal();
   for(int i=0; i<sub_charts_total; i++)
      ::ChartNavigate(m_sub_chart_id[i],CHART_END);
// --- Reset auxiliary variables for horizontal scrolling of graphs to zero
   ZeroHorizontalScrollVariables();
  }
//+------------------------------------------------------------------+
// | Moving elements |
//+------------------------------------------------------------------+
void CStandardChart::Moving(const bool only_visible=true)
  {
// --- Exit if element is hidden
   if(only_visible)
      if(!CElementBase::IsVisible())
         return;
// --- Update position
   CElement::Moving();
//---
   int sub_charts_total=SubChartsTotal();
   for(int i=0; i<sub_charts_total; i++)
     {
      // --- If the anchor is on the right
      if(m_anchor_right_window_side)
        {
         // ---Saving coordinates in element fields
         CElementBase::X(m_main.X2()-XGap());
         // ---Saving coordinates in object fields
         m_sub_chart[i].X(m_main.X2()-m_sub_chart[i].XGap());
        }
      // --- If the anchor is on the left
      else
        {
         CElementBase::X(m_main.X()+XGap());
         m_sub_chart[i].X(m_main.X()+m_sub_chart[i].XGap());
        }
      // --- If the binding is below
      if(m_anchor_bottom_window_side)
        {
         CElementBase::Y(m_main.Y2()-YGap());
         m_sub_chart[i].Y(m_main.Y2()-m_sub_chart[i].YGap());
        }
      // --- If the binding is on top
      else
        {
         CElementBase::Y(m_main.Y()+YGap());
         m_sub_chart[i].Y(m_main.Y()+m_sub_chart[i].YGap());
        }
      // --- Updating the coordinates of graphic objects
      m_sub_chart[i].X_Distance(m_sub_chart[i].X());
      m_sub_chart[i].Y_Distance(m_sub_chart[i].Y());
     }
// --- Reset auxiliary variables for horizontal scrolling of graphs to zero
   ZeroHorizontalScrollVariables();
  }
//+------------------------------------------------------------------+
// | Shows button |
//+------------------------------------------------------------------+
void CStandardChart::Show(void)
  {
// --- Exit if element is already visible
   if(CElementBase::IsVisible())
      return;
// --- Visibility state
   CElementBase::IsVisible(true);
// --- Update object position
   Moving();
// --- Make all objects visible
   int sub_charts_total=SubChartsTotal();
   for(int i=0; i<sub_charts_total; i++)
      m_sub_chart[i].Timeframes(OBJ_ALL_PERIODS);
  }
//+------------------------------------------------------------------+
// | Hides the button |
//+------------------------------------------------------------------+
void CStandardChart::Hide(void)
  {
// --- Exit if element is hidden
   if(!CElementBase::IsVisible())
      return;
// --- Hide horizontal scroll pointer
   m_x_scroll.Hide();
// --- Hide all objects
   int sub_charts_total=SubChartsTotal();
   for(int i=0; i<sub_charts_total; i++)
      m_sub_chart[i].Timeframes(OBJ_NO_PERIODS);
// --- Visibility state
   CElementBase::IsVisible(false);
  }
//+------------------------------------------------------------------+
// | Removal |
//+------------------------------------------------------------------+
void CStandardChart::Delete(void)
  {
   m_x_scroll.Delete();
// --- Deleting objects
   int sub_charts_total=SubChartsTotal();
   for(int i=0; i<sub_charts_total; i++)
      m_sub_chart[i].Delete();
// --- Freeing element arrays
   ::ArrayFree(m_sub_chart);
// --- Initializing variables to default values
   CElementBase::MouseFocus(false);
   CElementBase::IsVisible(true);
  }
//+------------------------------------------------------------------+
// | Setting Priorities |
//+------------------------------------------------------------------+
void CStandardChart::SetZorders(void)
  {
   int sub_charts_total=SubChartsTotal();
   for(int i=0; i<sub_charts_total; i++)
      m_sub_chart[i].Z_Order(m_zorder);
  }
//+------------------------------------------------------------------+
// | Reset priorities |
//+------------------------------------------------------------------+
void CStandardChart::ResetZorders(void)
  {
   int sub_charts_total=SubChartsTotal();
   for(int i=0; i<sub_charts_total; i++)
      m_sub_chart[i].Z_Order(WRONG_VALUE);
  }
//+------------------------------------------------------------------+
// | Processing a button click |
//+------------------------------------------------------------------+
bool CStandardChart::OnClickSubChart(const string clicked_object)
  {
// --- Exit if the click was not on a menu item
   if(::StringFind(clicked_object,CElementBase::ProgramName()+"_sub_chart_",0)<0)
      return(false);
// --- Get the identifier and index from the object name
   int id=CElementBase::IdFromObjectName(clicked_object);
// --- Exit if ID does not match
   if(id!=CElementBase::Id())
      return(false);
// --- Get the index
   int group_index=CElementBase::IndexFromObjectName(clicked_object);
// --- Send a signal about this
   ::EventChartCustom(m_chart_id,ON_CLICK_SUB_CHART,CElementBase::Id(),group_index,m_sub_chart_symbol[group_index]);
   return(true);
  }
//+------------------------------------------------------------------+
// | Checking for the presence of a symbol |
//+------------------------------------------------------------------+
bool CStandardChart::CheckSymbol(const string symbol)
  {
   bool flag=false;
// --- Let's check the symbol in the "Market Watch" window
   int symbols_total=::SymbolsTotal(true);
   for(int i=0; i<symbols_total; i++)
     {
      // --- If there is such a symbol, stop the loop
      if(::SymbolName(i,true)==symbol)
        {
         flag=true;
         break;
        }
     }
// --- If the symbol is not in the "Market Watch" window, then...
   if(!flag)
     {
      // --- ... let's try to find it in the general list
      symbols_total=::SymbolsTotal(false);
      for(int i=0; i<symbols_total; i++)
        {
         // --- If such a symbol exists, then...
         if(::SymbolName(i,false)==symbol)
           {
            // --- ... place it in the "Market Watch" window and stop the cycle
            ::SymbolSelect(symbol,true);
            flag=true;
            break;
           }
        }
     }
// --- Return search result
   return(flag);
  }
//+------------------------------------------------------------------+
// | Horizontal scrolling of graphics |
//+------------------------------------------------------------------+
void CStandardChart::HorizontalScroll(void)
  {
// --- Exit if horizontal scrolling of graphs is disabled
   if(!m_x_scroll_mode)
      return;
// ---If the mouse button is pressed
   if(m_mouse.LeftButtonState())
     {
      // --- Remember the current X coordinates of the cursor
      if(m_prev_x==0)
        {
         m_prev_x      =m_mouse.X()+m_prev_new_x_point;
         m_new_x_point =m_prev_new_x_point;
         // --- Update pointer coordinates and make it visible
         m_x_scroll.Moving(m_mouse.X(),m_mouse.Y());
         m_x_scroll.Reset();
         // --- Send a message to determine available elements
         ::EventChartCustom(m_chart_id,ON_SET_AVAILABLE,CElementBase::Id(),0,"");
         // --- Send a message about the change in the graphical interface
         ::EventChartCustom(m_chart_id,ON_CHANGE_GUI,CElementBase::Id(),0,"");
        }
      else
         m_new_x_point=m_prev_x-m_mouse.X();
      // --- Update pointer coordinates
      m_x_scroll.Moving(m_mouse.X(),m_mouse.Y());
     }
   else
     {
      if(m_prev_x==0)
         return;
      //---
      m_prev_x=0;
      // --- Hide pointer
      m_x_scroll.Hide();
      m_chart.Redraw();
      // --- Send a message to determine available elements
      ::EventChartCustom(m_chart_id,ON_SET_AVAILABLE,CElementBase::Id(),1,"");
      // --- Send a message about the change in the graphical interface
      ::EventChartCustom(m_chart_id,ON_CHANGE_GUI,CElementBase::Id(),0,"");
      return;
     }
// --- Exit if positive
   if(m_new_x_point>0)
      return;
// --- Remember current position
   m_prev_new_x_point=m_new_x_point;
// --- Apply to all charts
   int symbols_total=SubChartsTotal();
// --- Disable autoscroll and shift from right edge
   for(int i=0; i<symbols_total; i++)
     {
      if(::ChartGetInteger(m_sub_chart_id[i],CHART_AUTOSCROLL))
         ::ChartSetInteger(m_sub_chart_id[i],CHART_AUTOSCROLL,false);
      if(::ChartGetInteger(m_sub_chart_id[i],CHART_SHIFT))
         ::ChartSetInteger(m_sub_chart_id[i],CHART_SHIFT,false);
     }
// --- Reset last error
   ResetLastError();
// --- Let's shift the graphs
   for(int i=0; i<symbols_total; i++)
      if(!::ChartNavigate(m_sub_chart_id[i],CHART_END,m_new_x_point))
         ::Print(__FUNCTION__," > error: ",::GetLastError());
// --- Refresh chart
   ::ChartRedraw();
  }
//+------------------------------------------------------------------+
// | Resetting horizontal scroll variables to zero |
//+------------------------------------------------------------------+
void CStandardChart::ZeroHorizontalScrollVariables(void)
  {
   m_prev_x           =0;
   m_new_x_point      =0;
   m_prev_new_x_point =0;
  }
//+------------------------------------------------------------------+
// | Checking the graph subwindow resizing mode |
//+------------------------------------------------------------------+
bool CStandardChart::CheckDragBorderWindowMode(void)
  {
// --- Get the height of the main chart
   int chart_y_size=(int)ChartGetInteger(0,CHART_HEIGHT_IN_PIXELS);
// ---If the left mouse button is pressed
   if(m_mouse.LeftButtonState())
     {
      // --- If the mode is disabled
      if(!m_drag_border_window_mode)
        {
         // --- Remember the state if the mouse cursor is in the border capture zone to change the height of the subwindow
         if((m_mouse.SubWindowNumber()==m_subwin && m_mouse.Y()<2) ||
            (m_mouse.SubWindowNumber()==m_subwin && m_mouse.Y()==chart_y_size+1) ||
            (m_mouse.SubWindowNumber()==m_subwin-1 && m_mouse.Y()>=chart_y_size-2))
           {
            m_drag_border_window_mode=true;
            return(false);
           }
        }
     }
// --- Reset the disabled mode state
   else
      m_drag_border_window_mode=false;
// --- Return the result of the enabled mode
   if(m_drag_border_window_mode)
      return(true);
//---
   return(false);
  }
//+------------------------------------------------------------------+
// | Change the width along the right edge of the form |
//+------------------------------------------------------------------+
void CStandardChart::ChangeWidthByRightWindowSide(void)
  {
// --- Coordinates
   int x=0;
// --- Dimensions
   int x_size=0;
// ---Calculate new size
   x_size=m_main.X2()-m_sub_chart[0].X()-m_auto_xresize_right_offset;
// --- Do not resize if less than the specified limit
   if(x_size<80)
      return;
// ---Set new overall size
   CElementBase::XSize(x_size);
// --- Get the number of charts in the group
   int sub_charts_total=SubChartsTotal();
// --- Calculation of coordinates and size
   x=m_x;
   x_size=(sub_charts_total>1)? x_size/sub_charts_total : x_size;
// --- If more than one chart
   if(sub_charts_total>1)
     {
      for(int i=0; i<sub_charts_total; i++)
        {
         // --- X coordinate calculation
         x=(i>0)? x+x_size-1 : x;
         // ---Adjusting the width of the last chart
         if(i+1>=sub_charts_total)
            x_size=m_x_size-(x_size*(sub_charts_total-1)-(sub_charts_total-1));
         //---
         m_sub_chart[i].X(x);
         m_sub_chart[i].X_Distance(x);
         //---
         m_sub_chart[i].XSize(x_size);
         m_sub_chart[i].X_Size(x_size);
         // --- Indents from the extreme point
         m_sub_chart[i].XGap(CElement::CalculateXGap(x));
        }
     }
   else
     {
      // --- Set new size
      CElementBase::XSize(x_size);
      m_sub_chart[0].XSize(x_size);
      m_sub_chart[0].X_Size(x_size);
     }
// --- Update object position
   Moving();
  }
//+------------------------------------------------------------------+
// | Change the height along the bottom edge of the window |
//+------------------------------------------------------------------+
void CStandardChart::ChangeHeightByBottomWindowSide(void)
  {
// --- Coordinates
   int y=0;
// --- Dimensions
   int y_size=0;
// ---Calculate new size
   y_size=m_main.Y2()-m_y-m_auto_yresize_bottom_offset;
// --- Do not resize if less than the specified limit
   if(y_size<50)
      return;
// --- Get the number of charts in the group
   int sub_charts_total=SubChartsTotal();
// --- If more than one chart
   if(sub_charts_total>1)
     {
      // --- Set new size
      CElementBase::YSize(y_size);
      for(int i=0; i<sub_charts_total; i++)
        {
         m_sub_chart[i].YSize(y_size);
         m_sub_chart[i].Y_Size(y_size);
        }
     }
   else
     {
      // --- Set new size
      CElementBase::YSize(y_size);
      m_sub_chart[0].YSize(y_size);
      m_sub_chart[0].Y_Size(y_size);
     }
// --- Update object position
   Moving();
  }
//+------------------------------------------------------------------+
