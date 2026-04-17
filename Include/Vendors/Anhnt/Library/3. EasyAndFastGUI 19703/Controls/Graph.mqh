//+------------------------------------------------------------------+
//|                                                        Graph.mqh |
//|                        Copyright 2017, MetaQuotes Software Corp. |
//|                                              http://www.mql5.com |
//+------------------------------------------------------------------+
#include "..\Element.mqh"
//+------------------------------------------------------------------+
// | Class for creating a graph |
//+------------------------------------------------------------------+
class CGraph : public CElement
  {
private:
   // --- Objects for creating an element
   CGraphic          m_graph;
   // ---Full screen mode
   bool              m_is_fullscreen_mode;
   // ---Previous sizes and position for "Full Screen" mode
   int               m_prev_x;
   int               m_prev_y;
   int               m_prev_width;
   int               m_prev_height;
   //---
public:
                     CGraph(void);
                    ~CGraph(void);
   // --- Methods for creating an element
   bool              CreateGraph(const int x_gap,const int y_gap);
   //---
private:
   void              InitializeProperties(const int x_gap,const int y_gap);
   bool              CreateGraphic(void);
   //---
public:
   // --- Returns a pointer to the chart
   CGraphic         *GetGraphicPointer(void) { return(::GetPointer(m_graph)); }
   // --- Resizing
   void              Resize(const int width,const int height);
   
   // ---Full screen mode
   void              IsFullScreenMode(const bool mode) { m_is_fullscreen_mode=mode; };
   void              FullScreenMode(const bool mode=true);
   //---
public:
   // ---Graph event handler
   virtual void      OnEvent(const int id,const long &lparam,const double &dparam,const string &sparam);
   // ---Move element
   virtual void      Moving(const bool only_visible=true);
   // --- Management
   virtual void      Show(void);
   virtual void      Hide(void);
   virtual void      Reset(void);
   virtual void      Delete(void);
   // ---Applying the latest changes
   virtual void      Update(const bool redraw=false);
   // --- (1) Installation, (2) reset priorities by pressing the left mouse button
   virtual void      SetZorders(void);
   virtual void      ResetZorders(void);
   //---
private:
   // --- Processing clicks on the chart
   bool              OnClickGraph(const string pressed_object);

   // --- Change the width along the right edge of the window
   virtual void      ChangeWidthByRightWindowSide(void);
   // --- Change the height along the bottom edge of the window
   virtual void      ChangeHeightByBottomWindowSide(void);
  };
//+------------------------------------------------------------------+
//| Constructor                                                      |
//+------------------------------------------------------------------+
CGraph::CGraph(void) : m_prev_x(0),
                       m_prev_y(0),
                       m_prev_width(0),
                       m_prev_height(0),
                       m_is_fullscreen_mode(true)
  {
// --- Save the element class name in the base class
   CElementBase::ClassName(CLASS_NAME);
  }
//+------------------------------------------------------------------+
//| Destructor                                                       |
//+------------------------------------------------------------------+
CGraph::~CGraph(void)
  {
  }
//+------------------------------------------------------------------+
// | Event Handler |
//+------------------------------------------------------------------+
void CGraph::OnEvent(const int id,const long &lparam,const double &dparam,const string &sparam)
  {
// --- Handling the cursor movement event
   if(id==CHARTEVENT_MOUSE_MOVE)
     {
      return;
     }
// --- Handling the event of pressing the left mouse button on an object
   if(id==CHARTEVENT_OBJECT_CLICK)
     {
      if(OnClickGraph(sparam))
         return;
      //---
      return;
     }
  }
//+------------------------------------------------------------------+
// | Creates a graph |
//+------------------------------------------------------------------+
bool CGraph::CreateGraph(const int x_gap,const int y_gap)
  {
// --- Quit if there is no pointer to the main element
   if(!CElement::CheckMainPointer())
      return(false);
// --- Initializing properties
   InitializeProperties(x_gap,y_gap);
// ---Creating an element
   if(!CreateGraphic())
      return(false);
//---
   return(true);
  }
//+------------------------------------------------------------------+
// | Initializing properties |
//+------------------------------------------------------------------+
void CGraph::InitializeProperties(const int x_gap,const int y_gap)
  {
   m_x  =CElement::CalculateX(x_gap);
   m_y  =CElement::CalculateY(y_gap);
// --- Let's calculate the dimensions
   m_x_size =(m_x_size<1 || m_auto_xresize_mode)? m_main.X2()-m_x-m_auto_xresize_right_offset : m_x_size;
   m_y_size =(m_y_size<1 || m_auto_yresize_mode)? m_main.Y2()-m_y-m_auto_yresize_bottom_offset : m_y_size;
   m_prev_width  =m_x_size;
   m_prev_height =m_y_size;
// --- Let's save the dimensions
   CElementBase::XSize(m_x_size);
   CElementBase::YSize(m_y_size);
// --- Indents from the extreme point
   CElementBase::XGap(x_gap);
   CElementBase::YGap(y_gap);
  }
//+------------------------------------------------------------------+
// | Creates an object |
//+------------------------------------------------------------------+
bool CGraph::CreateGraphic(void)
  {
// --- Size adjustment
   m_x_size =(m_x_size<1)? 50 : m_x_size;
   m_y_size =(m_y_size<1)? 20 : m_y_size;
// --- Formation of object name
   string name=CElementBase::ElementName("graph");
// --- Coordinates
   int x2=m_x+m_x_size;
   int y2=m_y+m_y_size;
// ---Delete the object if it exists
   if(::ObjectFind(m_chart_id,name)>=0)
     {
      ::ObjectDelete(m_chart_id,name);
     }
// ---Create an object
   if(!m_graph.Create(m_chart_id,name,m_subwin,m_x,m_y,x2,y2))
      return(false);
// --- Properties
   ::ObjectSetString(m_chart_id,m_graph.ChartObjectName(),OBJPROP_TOOLTIP,"\n");
// --- All elements except the form have a higher priority than the main element
   Z_Order(m_main.Z_Order()+1);
   ::ObjectSetInteger(m_chart_id,m_graph.ChartObjectName(),OBJPROP_ZORDER,m_zorder);
   return(true);
  }
//+------------------------------------------------------------------+
// | Move |
//+------------------------------------------------------------------+
void CGraph::Moving(const bool only_visible=true)
  {
// --- Exit if element is hidden
   if(only_visible)
      if(!CElementBase::IsVisible())
         return;
// --- If the anchor is on the right
   if(m_anchor_right_window_side)
     {
      // ---Saving coordinates in element fields
      CElementBase::X(m_main.X2()-XGap());
     }
   else
     {
      CElementBase::X(m_main.X()+XGap());
     }
// --- If the binding is below
   if(m_anchor_bottom_window_side)
     {
      CElementBase::Y(m_main.Y2()-YGap());
     }
   else
     {
      CElementBase::Y(m_main.Y()+YGap());
     }
// --- Updating the coordinates of graphic objects
   ::ObjectSetInteger(m_chart_id,m_graph.ChartObjectName(),OBJPROP_XDISTANCE,X());
   ::ObjectSetInteger(m_chart_id,m_graph.ChartObjectName(),OBJPROP_YDISTANCE,Y());
  }
//+------------------------------------------------------------------+
// | Shows menu item |
//+------------------------------------------------------------------+
void CGraph::Show(void)
  {
// --- Exit if element is already visible
   if(CElementBase::IsVisible())
      return;
// --- Make all objects visible
   ::ObjectSetInteger(m_chart_id,m_graph.ChartObjectName(),OBJPROP_TIMEFRAMES,OBJ_ALL_PERIODS);
// --- Visibility state
   CElementBase::IsVisible(true);
// --- Update object position
   Moving();
  }
//+------------------------------------------------------------------+
// | Hides menu item |
//+------------------------------------------------------------------+
void CGraph::Hide(void)
  {
// --- Exit if element is hidden
   if(!CElementBase::IsVisible())
      return;
// --- Hide all objects
   ::ObjectSetInteger(m_chart_id,m_graph.ChartObjectName(),OBJPROP_TIMEFRAMES,OBJ_NO_PERIODS);
// --- Visibility state
   CElementBase::IsVisible(false);
  }
//+------------------------------------------------------------------+
// | Redraw |
//+------------------------------------------------------------------+
void CGraph::Reset(void)
  {
// --- Exit if the element is drop-down
   if(CElementBase::IsDropdown())
      return;
// --- Hide and show
   Hide();
   Show();
  }
//+------------------------------------------------------------------+
// | Removal |
//+------------------------------------------------------------------+
void CGraph::Delete(void)
  {
// --- Delete series objects
   int total=m_graph.CurvesTotal();
   for(int i=total-1; i>=0; i--)
      m_graph.CurveRemoveByIndex(i);
// --- Delete chart object
   m_graph.Destroy();
// --- Initializing variables to default values
   CElementBase::IsVisible(true);
  }
//+------------------------------------------------------------------+
// | Item Update |
//+------------------------------------------------------------------+
void CGraph::Update(const bool redraw=false)
  {
// --- Apply
   m_graph.Update();
  }
//+------------------------------------------------------------------+
// | Setting Priorities |
//+------------------------------------------------------------------+
void CGraph::SetZorders(void)
  {
   ::ObjectSetInteger(m_chart_id,m_graph.ChartObjectName(),OBJPROP_ZORDER,m_zorder);
  }
//+------------------------------------------------------------------+
// | Reset priorities |
//+------------------------------------------------------------------+
void CGraph::ResetZorders(void)
  {
   ::ObjectSetInteger(m_chart_id,m_graph.ChartObjectName(),OBJPROP_ZORDER,WRONG_VALUE);
  }
//+------------------------------------------------------------------+
// | Resizing |
//+------------------------------------------------------------------+
void CGraph::Resize(const int width,const int height)
  {
   m_x_size=width;
   m_y_size=height;
// --- Delete object
   ::ObjectDelete(m_chart_id,m_graph.ChartObjectName());
// --- Create chart
   CreateGraphic();
// --- Hide all objects
   if(!CElementBase::IsVisible())
      ::ObjectSetInteger(m_chart_id,m_graph.ChartObjectName(),OBJPROP_TIMEFRAMES,OBJ_NO_PERIODS);
  }
//+------------------------------------------------------------------+
// | Managing full-screen chart mode |
//+------------------------------------------------------------------+
void CGraph::FullScreenMode(const bool mode)
  {
// --- Change dimensions
   int chart_width  =m_chart.WidthInPixels();
   int chart_height =m_chart.HeightInPixels(0);
//---
   if(chart_width-1==m_x_size && chart_height-1==m_y_size)
     {
      Resize(m_prev_width,m_prev_height);
      ::ObjectSetInteger(m_chart_id,m_graph.ChartObjectName(),OBJPROP_XDISTANCE,m_prev_x);
      ::ObjectSetInteger(m_chart_id,m_graph.ChartObjectName(),OBJPROP_YDISTANCE,m_prev_y);
     }
   else
     {
      m_prev_x      =m_x;
      m_prev_y      =m_y;
      m_prev_width  =m_x_size;
      m_prev_height =m_y_size;
      Resize(chart_width-1,chart_height-1);
      ::ObjectSetInteger(m_chart_id,m_graph.ChartObjectName(),OBJPROP_XDISTANCE,1);
      ::ObjectSetInteger(m_chart_id,m_graph.ChartObjectName(),OBJPROP_YDISTANCE,1);
     }
//---
   m_graph.Redraw(true);
   m_graph.Update();
   m_chart.Redraw();
  }
//+------------------------------------------------------------------+
// | Clicking on the chart |
//+------------------------------------------------------------------+
bool CGraph::OnClickGraph(const string pressed_object)
  {
// --- Exit if (1) the object name is foreign or (2) full screen mode is turned off
   if(m_graph.ChartObjectName()!=pressed_object || !m_is_fullscreen_mode)
      return(false);
// --- Change dimensions
   FullScreenMode();
   return(true);
  }
//+------------------------------------------------------------------+
// | Change the width along the right edge of the form |
//+------------------------------------------------------------------+
void CGraph::ChangeWidthByRightWindowSide(void)
  {
// --- Exit if the mode of fixing to the right edge of the form is enabled
   if(m_anchor_right_window_side)
      return;
// --- Dimensions
   int x_size=0;
// ---Calculate size
   x_size=m_main.X2()-X()-m_auto_xresize_right_offset;
// --- Do not resize if less than the specified limit
   if(x_size<200 || x_size==m_x_size)
      return;
//---
   m_prev_width=x_size;
// --- Set new size
   CElementBase::XSize(x_size);
   Resize(x_size,m_graph.Height());
// --- Refresh data on chart
   m_graph.Redraw(true);
  }
//+------------------------------------------------------------------+
// | Change the height along the bottom edge of the window |
//+------------------------------------------------------------------+
void CGraph::ChangeHeightByBottomWindowSide(void)
  {
// --- Exit if the mode of fixing to the bottom edge of the form is enabled
   if(m_anchor_bottom_window_side)
      return;
// --- Dimensions
   int y_size=0;
// ---Calculate size
   y_size=m_main.Y2()-Y()-m_auto_yresize_bottom_offset;
// --- Do not resize if less than the specified limit
   if(y_size<200 || y_size==m_y_size)
      return;
//---
   m_prev_height=y_size;
// --- Set new size
   CElementBase::YSize(y_size);
   Resize(m_graph.Width(),y_size);
// --- Refresh data on chart
   m_graph.Redraw(true);
  }
//+------------------------------------------------------------------+
