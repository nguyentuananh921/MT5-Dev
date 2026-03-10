//+------------------------------------------------------------------+
//|                                               ScrollBarThumbH.mqh|
//+------------------------------------------------------------------+
#ifndef __SCROLLBAR_THUMB_H_MQH__
#define __SCROLLBAR_THUMB_H_MQH__
//+------------------------------------------------------------------+
//| Horizontal scrollbar thumb                                       |
//+------------------------------------------------------------------+
//|Include stadard library                                           |
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//|Include Custome library                                           |
//+------------------------------------------------------------------+
#include "Button.mqh"
#include "../Base/CommonManager.mqh"
#include "../Base/BaseDefines.mqh"

class CScrollBarThumbH : public CButton
  {
protected:
   bool              m_chart_redraw;                           // Chart redraw flag
public:
//--- (1) Sets, (2) returns the chart redraw flag
   void              SetChartRedrawFlag(const bool flag)       { this.m_chart_redraw=flag;               }
   bool              ChartRedrawFlag(void)               const { return this.m_chart_redraw;             }
   
//--- Virtual methods: (1) save to file, (2) load from file, (3) object type
   virtual bool      Save(const int file_handle);
   virtual bool      Load(const int file_handle);
   virtual int       Type(void)                          const { return(ELEMENT_TYPE_SCROLLBAR_THUMB_H); }
   
//--- Initialization: (1) class object, (2) default object colors
   void              Init(const string text);
   
//--- Event handlers: (1) cursor move, (2) mouse wheel scroll
   virtual void      OnMoveEvent(const int id, const long lparam, const double dparam, const string sparam);
   virtual void      OnWheelEvent(const int id, const long lparam, const double dparam, const string sparam);
   
//--- Constructors/destructor
                     CScrollBarThumbH(void);
                     CScrollBarThumbH(const string object_name, const string text, const long chart_id, const int wnd, const int x, const int y, const int w, const int h);
                    ~CScrollBarThumbH (void) {}
  };
//+------------------------------------------------------------------+
//| CScrollBarThumbH::Default constructor.                           |
//| Creates the element in the main window of the current chart      |
//| at coordinates 0,0 with default sizes                            |
//+------------------------------------------------------------------+
CScrollBarThumbH::CScrollBarThumbH(void) : CButton("SBThumb","",::ChartID(),0,0,0,DEF_PANEL_W,DEF_SCROLLBAR_TH)
  {
//--- Initialization
   this.Init("");
  }
//+------------------------------------------------------------------+
//| CScrollBarThumbH::Parametric constructor.                        |
//| Creates the element in the specified window of the specified chart|
//| with specified text, coordinates, and sizes                      |
//+------------------------------------------------------------------+
CScrollBarThumbH::CScrollBarThumbH(const string object_name,const string text,const long chart_id,const int wnd,const int x,const int y,const int w,const int h) :
   CButton(object_name,text,chart_id,wnd,x,y,w,h)
  {
//--- Initialization
   this.Init("");
  }
//+------------------------------------------------------------------+
//| CScrollBarThumbH::Initialization                                 |
//+------------------------------------------------------------------+
void CScrollBarThumbH::Init(const string text)
  {
//--- Parent class initialization
   CButton::Init("");
//--- Set movability and chart redraw flags
   this.SetMovable(true);
   this.SetChartRedrawFlag(false);
//--- Element is not clipped by container boundaries
   this.m_trim_flag=false;
  }
//+------------------------------------------------------------------+
//| CScrollBarThumbH::Cursor move event handler                      |
//+------------------------------------------------------------------+
void CScrollBarThumbH::OnMoveEvent(const int id,const long lparam,const double dparam,const string sparam)
  {
//--- Base object cursor move handler
   CCanvasBase::OnMoveEvent(id,lparam,dparam,sparam);
//--- Get pointer to the base object (Horizontal Scroll Bar control)
   CCanvasBase *base_obj=this.GetContainer();
//--- If movability flag is not set for the thumb, or base object pointer is not obtained - exit
   if(!this.IsMovable() || base_obj==NULL)
      return;
   
//--- Get base object width and calculate thumb movement boundaries
   int base_w=base_obj.Width();
   int base_left=base_obj.X()+base_obj.Height();
   int base_right=base_obj.Right()-base_obj.Height()+1;
   
//--- Calculate movement limits from cursor coordinates and thumb size
   int x=(int)lparam-this.m_cursor_delta_x;
   if(x<base_left)
      x=base_left;
   if(x+this.Width()>base_right)
      x=base_right-this.Width();
//--- Move the thumb to the calculated X coordinate
   if(!this.MoveX(x))
      return;
      
//--- Calculate thumb position
   int thumb_pos=this.X()-base_left;
   
//--- Send a custom event to the chart with thumb position in lparam and object name in sparam
   ::EventChartCustom(this.m_chart_id, (ushort)CHARTEVENT_MOUSE_MOVE, thumb_pos, dparam, this.NameFG());
//--- Redraw chart
   if(this.m_chart_redraw)
      ::ChartRedraw(this.m_chart_id);
  }
//+------------------------------------------------------------------+
//| CScrollBarThumbH::Mouse wheel scroll event handler               |
//+------------------------------------------------------------------+
void CScrollBarThumbH::OnWheelEvent(const int id,const long lparam,const double dparam,const string sparam)
  {
//--- Get pointer to the base object (Horizontal Scroll Bar control)
   CCanvasBase *base_obj=this.GetContainer();
   
//--- Get name of the main object in the hierarchy by the value in sparam
   string array_names[];
   string name_main=(GetElementNames(sparam,"_",array_names)>0 ? array_names[0] : "");
   
//--- If the main object in the hierarchy is not ours - exit
   if(::StringFind(this.NameFG(),name_main)!=0)
      return;
      
//--- If movability flag is not set for the thumb, or base object pointer is not obtained - exit
   if(!this.IsMovable() || base_obj==NULL)
      return;
   
//--- Get base object width and calculate thumb movement boundaries
   int base_w=base_obj.Width();
   int base_left=base_obj.X()+base_obj.Height();
   int base_right=base_obj.Right()-base_obj.Height()+1;
   
//--- Set offset direction depending on the mouse wheel rotation direction
   int dx=(dparam<0 ? 2 : dparam>0 ? -2 : 0);
   if(dx==0)
      dx=(int)lparam;

//--- If the thumb goes beyond the left edge of its area when shifting - set it to the left edge
   if(dx<0 && this.X()+dx<=base_left)
      this.MoveX(base_left);
//--- otherwise, if the thumb goes beyond the right edge of its area - position it by the right edge
   else if(dx>0 && this.Right()+dx>=base_right)
      this.MoveX(base_right-this.Width());
//--- Otherwise, if the thumb is within its area - shift it by the offset amount
   else
     {
      this.ShiftX(dx);
     }

//--- Calculate thumb position
   int thumb_pos=this.X()-base_left;
   
//--- Get cursor coordinates
   int x=CCommonManager::GetInstance().CursorX();
   int y=CCommonManager::GetInstance().CursorY();
   
//--- If cursor is over the thumb - change color to "Focused",
   if(this.Contains(x,y))
      this.OnFocusEvent(id,lparam,dparam,sparam);
//--- otherwise - return color to "Default"
   else
      this.OnReleaseEvent(id,lparam,dparam,sparam);
      
//--- Send a custom event to the chart with thumb position in lparam and object name in sparam
   ::EventChartCustom(this.m_chart_id, (ushort)CHARTEVENT_MOUSE_WHEEL, thumb_pos, dparam, this.NameFG());
//--- Redraw chart
   if(this.m_chart_redraw)
      ::ChartRedraw(this.m_chart_id);
  }
//+------------------------------------------------------------------+
//| CScrollBarThumbH::Saving to file                                 |
//+------------------------------------------------------------------+
bool CScrollBarThumbH::Save(const int file_handle)
  {
//--- Save parent object data
   if(!CButton::Save(file_handle))
      return false;
  
//--- Save chart redraw flag
   if(::FileWriteInteger(file_handle,this.m_chart_redraw,INT_VALUE)!=INT_VALUE)
      return false;
   
//--- Everything successful
   return true;
  }
//+------------------------------------------------------------------+
//| CScrollBarThumbH::Loading from file                              |
//+------------------------------------------------------------------+
bool CScrollBarThumbH::Load(const int file_handle)
  {
//--- Load parent object data
   if(!CButton::Load(file_handle))
      return false;
      
//--- Load chart redraw flag
   this.m_chart_redraw=::FileReadInteger(file_handle,INT_VALUE);
   
//--- Everything successful
   return true;
  }

#endif