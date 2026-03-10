//+------------------------------------------------------------------+
//|                                               ScrollBarThumbV.mqh|
//+------------------------------------------------------------------+

#ifndef __SCROLLBAR_THUMB_V_MQH__
#define __SCROLLBAR_THUMB_V_MQH__
//+------------------------------------------------------------------+
//| Vertical scrollbar thumb                                         |
//+------------------------------------------------------------------+
//|Include stadard library                                           |
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//|Include Custome library                                           |
//+------------------------------------------------------------------+
#include "Button.mqh"

class CScrollBarThumbV : public CButton
  {
protected:
   bool m_chart_redraw; // chart redraw flag

public:

//--- (1) set, (2) get chart redraw flag
   void SetChartRedrawFlag(const bool flag){ this.m_chart_redraw=flag; }
   bool ChartRedrawFlag(void) const { return this.m_chart_redraw; }

//--- Virtual methods
   virtual bool Save(const int file_handle);
   virtual bool Load(const int file_handle);
   virtual int  Type(void) const { return(ELEMENT_TYPE_SCROLLBAR_THUMB_V); }

//--- Initialization
   void Init(const string text);

//--- Event handlers
   virtual void OnMoveEvent(const int id,const long lparam,const double dparam,const string sparam);
   virtual void OnWheelEvent(const int id,const long lparam,const double dparam,const string sparam);

//--- Constructors
   CScrollBarThumbV(void);
   CScrollBarThumbV(const string object_name,const string text,const long chart_id,const int wnd,const int x,const int y,const int w,const int h);
   ~CScrollBarThumbV(void){}
  };
  //+------------------------------------------------------------------+
//| CScrollBarThumbV::Default constructor.                           |
//| Builds the element in the main window of the current chart       |
//| at coordinates 0,0 with default dimensions.                      |
//+------------------------------------------------------------------+
CScrollBarThumbV::CScrollBarThumbV(void) : CButton("SBThumb","",::ChartID(),0,0,0,DEF_SCROLLBAR_TH,DEF_PANEL_W)
  {
//--- Initialization
   this.Init("");
  }
//+------------------------------------------------------------------+
//| CScrollBarThumbV::Parametric constructor.                        |
//| Builds the element in the specified window of the specified chart|
//| with the given text, coordinates, and dimensions.                |
//+------------------------------------------------------------------+
CScrollBarThumbV::CScrollBarThumbV(const string object_name,const string text,const long chart_id,const int wnd,const int x,const int y,const int w,const int h) :
   CButton(object_name,text,chart_id,wnd,x,y,w,h)
  {
//--- Initialization
   this.Init("");
  }
//+------------------------------------------------------------------+
//| CScrollBarThumbV::Initialization                                 |
//+------------------------------------------------------------------+
void CScrollBarThumbV::Init(const string text)
  {
//--- Initialize parent class
   CButton::Init("");
//--- Set moveability and chart redraw flags
   this.SetMovable(true);
   this.SetChartRedrawFlag(false);
//--- This element is NOT trimmed by container boundaries
   this.m_trim_flag=false;
  }
//+------------------------------------------------------------------+
//| CScrollBarThumbV::Handler for cursor movement (Dragging)        |
//+------------------------------------------------------------------+
void CScrollBarThumbV::OnMoveEvent(const int id,const long lparam,const double dparam,const string sparam)
  {
//--- Call base class move handler
   CCanvasBase::OnMoveEvent(id,lparam,dparam,sparam);
//--- Get pointer to the parent scrollbar control
   CCanvasBase *base_obj=this.GetContainer();
//--- If not movable or parent is missing, exit
   if(!this.IsMovable() || base_obj==NULL)
      return;
   
//--- Calculate the boundaries of the scroll track
   int base_top=base_obj.Y()+base_obj.Width();
   int base_bottom=base_obj.Bottom()-base_obj.Width()+1;
   
//--- Calculate new Y position based on cursor and initial offset
   int y=(int)dparam-this.m_cursor_delta_y;
   
//--- Constrain the thumb within the track
   if(y<base_top)
      y=base_top;
   if(y+this.Height()>base_bottom)
      y=base_bottom-this.Height();

//--- Move the thumb to the calculated Y coordinate
   if(!this.MoveY(y))
      return;
   
//--- Calculate relative thumb position
   int thumb_pos=this.Y()-base_top;
   
//--- Send a custom event to the chart with the new position
   ::EventChartCustom(this.m_chart_id, (ushort)CHARTEVENT_MOUSE_MOVE, thumb_pos, dparam, this.NameFG());
//--- Redraw chart if flagged
   if(this.m_chart_redraw)
      ::ChartRedraw(this.m_chart_id);
  }
//+------------------------------------------------------------------+
//| CScrollBarThumbV::Handler for mouse wheel events                 |
//+------------------------------------------------------------------+
void CScrollBarThumbV::OnWheelEvent(const int id,const long lparam,const double dparam,const string sparam)
  {
   CCanvasBase *base_obj=this.GetContainer();
   
//--- Verify if this event belongs to our object hierarchy
   string array_names[];
   string name_main=(GetElementNames(sparam,"_",array_names)>0 ? array_names[0] : "");
   if(::StringFind(this.NameFG(),name_main)!=0)
      return;
      
   if(!this.IsMovable() || base_obj==NULL)
      return;
   
//--- Track boundaries
   int base_top=base_obj.Y()+base_obj.Width();
   int base_bottom=base_obj.Bottom()-base_obj.Width()+1;
   
//--- Determine displacement direction from wheel rotation
   int dy=(dparam<0 ? 2 : dparam>0 ? -2 : 0);
   if(dy==0)
      dy=(int)lparam;

//--- Constrain movement within bounds
   if(dy<0 && this.Y()+dy<=base_top)
      this.MoveY(base_top);
   else if(dy>0 && this.Bottom()+dy>=base_bottom)
      this.MoveY(base_bottom-this.Height());
   else
      this.ShiftY(dy);

//--- Relative position for event reporting
   int thumb_pos=this.Y()-base_top;
   
//--- Handle visual focus states during scrolling
   int x=CCommonManager::GetInstance().CursorX();
   int y=CCommonManager::GetInstance().CursorY();
   
   if(this.Contains(x,y))
      this.OnFocusEvent(id,lparam,dparam,sparam);
   else
      this.OnReleaseEvent(id,lparam,dparam,sparam);
      
//--- Notify chart of position change via custom event
   ::EventChartCustom(this.m_chart_id, (ushort)CHARTEVENT_MOUSE_WHEEL, thumb_pos, dparam, this.NameFG());
   if(this.m_chart_redraw)
      ::ChartRedraw(this.m_chart_id);
  }
//+------------------------------------------------------------------+
//| CScrollBarThumbV::File I/O methods                               |
//+------------------------------------------------------------------+
bool CScrollBarThumbV::Save(const int file_handle)
  {
   if(!CButton::Save(file_handle))
      return false;
   if(::FileWriteInteger(file_handle,this.m_chart_redraw,INT_VALUE)!=INT_VALUE)
      return false;
   return true;
  }

bool CScrollBarThumbV::Load(const int file_handle)
  {
   if(!CButton::Load(file_handle))
      return false;
   this.m_chart_redraw=::FileReadInteger(file_handle,INT_VALUE);
   return true;
  }

#endif