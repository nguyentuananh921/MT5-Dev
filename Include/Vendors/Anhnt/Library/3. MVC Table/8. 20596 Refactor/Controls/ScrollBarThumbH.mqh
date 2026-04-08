//+------------------------------------------------------------------+
//|                                            ScrollBarThumbH.mqh   |
//|                                  Copyright 2025, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//| MVC Paradigm in MQL5                                             |
//| First See in             https://www.mql5.com/en/articles/18221  |
//| Current                   https://www.mql5.com/ru/articles/20596 |
//+------------------------------------------------------------------+
#property copyright "Copyright 2025, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
//+------------------------------------------------------------------+
//| Horizontal Scroll Slider Class |
//+------------------------------------------------------------------+
#ifndef __SCROLLBARTHUMBH_MQH__
#define __SCROLLBARTHUMBH_MQH__ 
   //+------------------------------------------------------------------+
   //| Included Standard Libraries                                      |
   //+------------------------------------------------------------------+
   //#include <Arrays\List.mqh>
   //+------------------------------------------------------------------+
   //| Included Custome Libraries                                       |
   //+------------------------------------------------------------------+
   #include "Button.mqh"  
  class CScrollBarThumbH : public CButton
   {
      protected:
         bool              m_chart_redraw;                           // Graph update flag
      public:
      // --- (1) Sets, (2) returns the graph update flag
         void              SetChartRedrawFlag(const bool flag)       { this.m_chart_redraw=flag;               }
         bool              ChartRedrawFlag(void)               const { return this.m_chart_redraw;             }
         
      // --- Virtual methods (1) save to file, (2) load from file, (3) object type
         virtual bool      Save(const int file_handle);
         virtual bool      Load(const int file_handle);
         virtual int       Type(void)                          const { return(ELEMENT_TYPE_SCROLLBAR_THUMB_H); }
         
      // --- Initialize (1) class object, (2) default object colors
         void              Init(const string text);
         
      // --- Event handlers for (1) cursor movement, (2) wheel scrolling
         virtual void      OnMoveEvent(const int id, const long lparam, const double dparam, const string sparam);
         virtual void      OnWheelEvent(const int id, const long lparam, const double dparam, const string sparam);
         
      // --- Constructors/destructor
                           CScrollBarThumbH(void);
                           CScrollBarThumbH(const string object_name, const string text, const long chart_id, const int wnd, const int x, const int y, const int w, const int h);
                        ~CScrollBarThumbH (void) {}
   };
  #ifndef CSCROLLBARTHUMBH_IMPLEMENTATION
  #define CSCROLLBARTHUMBH_IMPLEMENTATION
   //+------------------------------------------------------------------+
   // | CScrollBarThumbH::Default constructor.                      |
   // | Plots an element in the main window of the current chart |
   // | at coordinates 0,0 with default dimensions |
   //+------------------------------------------------------------------+
   CScrollBarThumbH::CScrollBarThumbH(void) : CButton("SBThumb","",::ChartID(),0,0,0,DEF_PANEL_W,DEF_SCROLLBAR_TH)
    {
     // ---Initialization
      this.Init("");
    }
   //+------------------------------------------------------------------+
   // | CScrollBarThumbH::The constructor is parametric.                   |
   // | Plots an element in the specified window of the specified chart |
   // | with specified text, coordinates and dimensions |
   //+------------------------------------------------------------------+
   CScrollBarThumbH::CScrollBarThumbH(const string object_name,const string text,const long chart_id,const int wnd,const int x,const int y,const int w,const int h) :
      CButton(object_name,text,chart_id,wnd,x,y,w,h)
    {
     // ---Initialization
      this.Init("");
    }
   //+------------------------------------------------------------------+
   // | CScrollBarThumbH::Initializing |
   //+------------------------------------------------------------------+
   void CScrollBarThumbH::Init(const string text)
    {
     // ---Initializing the parent class
      CButton::Init("");
     // --- Set the relocatability and schedule update flags
      this.SetMovable(true);
      this.SetChartRedrawFlag(false);
     // --- Element is not clipped to container boundaries
      this.m_trim_flag=false;
    }
   //+------------------------------------------------------------------+
   // | CScrollBarThumbH::Cursor move handler |
   //+------------------------------------------------------------------+
   void CScrollBarThumbH::OnMoveEvent(const int id,const long lparam,const double dparam,const string sparam)
    {
     // --- Base object cursor movement handler
      CCanvasBase::OnMoveEvent(id,lparam,dparam,sparam);
     // --- Get a pointer to the base object (horizontal scrollbar control)
      CCanvasBase *base_obj=this.GetContainer();
     // --- If the movability flag is not set for the slider, or the pointer to the base object is not received, we leave
      if(!this.IsMovable() || base_obj==NULL)
         return;
      
     // --- Get the width of the base object and calculate the boundaries of the space for the slider
      int base_w=base_obj.Width();
      int base_left=base_obj.X()+base_obj.Height();
      int base_right=base_obj.Right()-base_obj.Height()+1;
      
     // --- From the coordinates of the cursor and the size of the slider, we calculate the restrictions for movement
      int x=(int)lparam-this.m_cursor_delta_x;
      if(x<base_left)
         x=base_left;
      if(x+this.Width()>base_right)
         x=base_right-this.Width();
     // --- Move the slider to the calculated X coordinate
      if(!this.MoveX(x))
         return;
         
     // --- Calculate the position of the slider
      int thumb_pos=this.X()-base_left;
      
     // --- Send a custom event to the chart with the slider position in lparam and the object name in sparam
      ::EventChartCustom(this.m_chart_id, (ushort)CHARTEVENT_MOUSE_MOVE, thumb_pos, dparam, this.NameFG());
     // --- Redraw the graph
      if(this.m_chart_redraw)
         ::ChartRedraw(this.m_chart_id);
    }
   //+------------------------------------------------------------------+
   // | CScrollBarThumbH::Wheel scroll handler |
   //+------------------------------------------------------------------+
   void CScrollBarThumbH::OnWheelEvent(const int id,const long lparam,const double dparam,const string sparam)
    {
     // --- Get a pointer to the base object (horizontal scroll bar control)
      CCanvasBase *base_obj=this.GetContainer();
      
     // --- Get the name of the main object in the hierarchy by value in sparam
      string array_names[];
      string name_main=(GetElementNames(sparam,"_",array_names)>0 ? array_names[0] : "");
      
     // --- If the main object in the hierarchy is not ours, we leave
      if(::StringFind(this.NameFG(),name_main)!=0)
         return;
         
     // --- If the movability flag is not set for the slider, or the pointer to the base object is not received, we leave
      if(!this.IsMovable() || base_obj==NULL)
         return;
      
     // --- Get the width of the base object and calculate the boundaries of the space for the slider
      int base_w=base_obj.Width();
      int base_left=base_obj.X()+base_obj.Height();
      int base_right=base_obj.Right()-base_obj.Height()+1;
      
     // --- Set the direction of displacement depending on the direction of rotation of the mouse wheel
      int dx=(dparam<0 ? 2 : dparam>0 ? -2 : 0);
      if(dx==0)
         dx=(int)lparam;

     // --- If, when shifted, the slider goes beyond the left edge of its area, set it to the left edge
      if(dx<0 && this.X()+dx<=base_left)
         this.MoveX(base_left);
     // --- otherwise, if, when shifted, the slider goes beyond the right edge of its area, position it along the right edge
      else if(dx>0 && this.Right()+dx>=base_right)
         this.MoveX(base_right-this.Width());
     // --- Otherwise, if the slider is within its area, move it by the offset amount
      else
      {
         this.ShiftX(dx);
      }

     // --- Calculate the position of the slider
      int thumb_pos=this.X()-base_left;
      
     // --- Getting the cursor coordinates
      int x=CCommonManager::GetInstance().CursorX();
      int y=CCommonManager::GetInstance().CursorY();
      
     // --- If the cursor hits the slider, change the color to “In Focus”,
      if(this.Contains(x,y))
         this.OnFocusEvent(id,lparam,dparam,sparam);
     // --- otherwise - return the color to "Default"
      else
         this.OnReleaseEvent(id,lparam,dparam,sparam);
         
     // --- Send a custom event to the chart with the slider position in lparam and the object name in sparam
      ::EventChartCustom(this.m_chart_id, (ushort)CHARTEVENT_MOUSE_WHEEL, thumb_pos, dparam, this.NameFG());
     // --- Redraw the graph
      if(this.m_chart_redraw)
         ::ChartRedraw(this.m_chart_id);
    }
   //+------------------------------------------------------------------+
   // | CScrollBarThumbH::Saving to file |
   //+------------------------------------------------------------------+
   bool CScrollBarThumbH::Save(const int file_handle)
    {
     // --- Save the data of the parent object
      if(!CButton::Save(file_handle))
         return false;

     // --- Save the graph update flag
      if(::FileWriteInteger(file_handle,this.m_chart_redraw,INT_VALUE)!=INT_VALUE)
         return false;
      
     // --- Everything is successful
      return true;
    }
   //+------------------------------------------------------------------+
   // | CScrollBarThumbH::Loading from file |
   //+------------------------------------------------------------------+
   bool CScrollBarThumbH::Load(const int file_handle)
    {
     // --- Loading the data of the parent object
      if(!CButton::Load(file_handle))
         return false;
         
     // --- Loading the graph update flag
      this.m_chart_redraw=::FileReadInteger(file_handle,INT_VALUE);
      
     // --- Everything is successful
      return true;
    }
   //+------------------------------------------------------------------+
  #endif // CSCROLLBARTHUMBH_IMPLEMENTATION
#endif // __SCROLLBARTHUMBH_MQH__



