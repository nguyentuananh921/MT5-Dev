//+------------------------------------------------------------------+
//|                                            ScrollBarThumbV.mqh   |
//|                                  Copyright 2025, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//| MVC Paradigm in MQL5                                             |
//|                                                                  |
//|                           https://www.mql5.com/ru/articles/20596 |
//+------------------------------------------------------------------+
#property copyright "Copyright 2025, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
//+------------------------------------------------------------------+
// | Included Libraries |
//+------------------------------------------------------------------+
#include <Arrays\List.mqh>

#ifndef __SCROLLBARTHUMBV_MQH__
#define __SCROLLBARTHUMBV_MQH__
       //+------------------------------------------------------------------+
   //| Vertical Scroll Slider Class |
   //+------------------------------------------------------------------+
   class CScrollBarThumbV : public CButton
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
         virtual int       Type(void)                          const { return(ELEMENT_TYPE_SCROLLBAR_THUMB_V); }
         
      // --- Initialize (1) class object, (2) default object colors
         void              Init(const string text);
         
      // --- Event handlers for (1) cursor movement, (2) wheel scrolling
         virtual void      OnMoveEvent(const int id, const long lparam, const double dparam, const string sparam);
         virtual void      OnWheelEvent(const int id, const long lparam, const double dparam, const string sparam);
         
      // --- Constructors/destructor
                           CScrollBarThumbV(void);
                           CScrollBarThumbV(const string object_name, const string text, const long chart_id, const int wnd, const int x, const int y, const int w, const int h);
                        ~CScrollBarThumbV (void) {}
   };
   #ifndef CSCROLLBARTHUMBV_IMPLEMENTATION
   #define CSCROLLBARTHUMBV_IMPLEMENTATION
      //+------------------------------------------------------------------+
      // | CScrollBarThumbV::Default constructor.                      |
      // | Plots an element in the main window of the current chart |
      // | at coordinates 0,0 with default dimensions |
      //+------------------------------------------------------------------+
      CScrollBarThumbV::CScrollBarThumbV(void) : CButton("SBThumb","",::ChartID(),0,0,0,DEF_SCROLLBAR_TH,DEF_PANEL_W)
      {
      // ---Initialization
         this.Init("");
      }
      //+------------------------------------------------------------------+
      // | CScrollBarThumbV::Parametric constructor.                   |
      // | Plots an element in the specified window of the specified chart |
      // | with specified text, coordinates and dimensions |
      //+------------------------------------------------------------------+
      CScrollBarThumbV::CScrollBarThumbV(const string object_name,const string text,const long chart_id,const int wnd,const int x,const int y,const int w,const int h) :
         CButton(object_name,text,chart_id,wnd,x,y,w,h)
      {
      // ---Initialization
         this.Init("");
      }
      //+------------------------------------------------------------------+
      // | CScrollBarThumbV::Initializing |
      //+------------------------------------------------------------------+
      void CScrollBarThumbV::Init(const string text)
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
      // | CScrollBarThumbV::Cursor move handler |
      //+------------------------------------------------------------------+
      void CScrollBarThumbV::OnMoveEvent(const int id,const long lparam,const double dparam,const string sparam)
      {
      // --- Base object cursor movement handler
         CCanvasBase::OnMoveEvent(id,lparam,dparam,sparam);
      // --- Get a pointer to the base object (vertical scroll bar control)
         CCanvasBase *base_obj=this.GetContainer();
      // --- If the movability flag is not set for the slider, or the pointer to the base object is not received, we leave
         if(!this.IsMovable() || base_obj==NULL)
            return;
         
      // --- Get the height of the base object and calculate the boundaries of the space for the slider
         int base_h=base_obj.Height();
         int base_top=base_obj.Y()+base_obj.Width();
         int base_bottom=base_obj.Bottom()-base_obj.Width()+1;
         
      // --- From the coordinates of the cursor and the size of the slider, we calculate the restrictions for movement
         int y=(int)dparam-this.m_cursor_delta_y;
         if(y<base_top)
            y=base_top;
         if(y+this.Height()>base_bottom)
            y=base_bottom-this.Height();
      // --- Move the slider to the calculated Y coordinate
         if(!this.MoveY(y))
            return;
         
      // --- Calculate the position of the slider
         int thumb_pos=this.Y()-base_top;
         
      // --- Send a custom event to the chart with the slider position in lparam and the object name in sparam
         ::EventChartCustom(this.m_chart_id, (ushort)CHARTEVENT_MOUSE_MOVE, thumb_pos, dparam, this.NameFG());
      // --- Redraw the graph
         if(this.m_chart_redraw)
            ::ChartRedraw(this.m_chart_id);
      }
      //+------------------------------------------------------------------+
      // | CScrollBarThumbV::Wheel scroll handler |
      //+------------------------------------------------------------------+
      void CScrollBarThumbV::OnWheelEvent(const int id,const long lparam,const double dparam,const string sparam)
      {
      // --- Get a pointer to the base object (vertical scroll bar control)
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
         
      // --- Get the height of the base object and calculate the boundaries of the space for the slider
         int base_h=base_obj.Height();
         int base_top=base_obj.Y()+base_obj.Width();
         int base_bottom=base_obj.Bottom()-base_obj.Width()+1;
         
      // --- Set the direction of displacement depending on the direction of rotation of the mouse wheel
         int dy=(dparam<0 ? 2 : dparam>0 ? -2 : 0);
         if(dy==0)
            dy=(int)lparam;

      // --- If, when shifted, the slider goes beyond the top edge of its area, set it to the top edge
         if(dy<0 && this.Y()+dy<=base_top)
            this.MoveY(base_top);
      // --- otherwise, if, when shifted, the slider goes beyond the bottom edge of its area, position it along the bottom edge
         else if(dy>0 && this.Bottom()+dy>=base_bottom)
            this.MoveY(base_bottom-this.Height());
      // --- Otherwise, if the slider is within its area, move it by the offset amount
         else
         {
            this.ShiftY(dy);
         }

      // --- Calculate the position of the slider
         int thumb_pos=this.Y()-base_top;
         
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
      // | CScrollBarThumbV::Saving to file |
      //+------------------------------------------------------------------+
      bool CScrollBarThumbV::Save(const int file_handle)
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
      // | CScrollBarThumbV::Loading from file |
      //+------------------------------------------------------------------+
      bool CScrollBarThumbV::Load(const int file_handle)
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
   #endif // CSCROLLBARTHUMBV_IMPLEMENTATION
#endif // __SCROLLBARTHUMBV_MQH__


