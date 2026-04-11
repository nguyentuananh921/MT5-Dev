//+------------------------------------------------------------------+
//|                                                 ScrollBarV.mqh   |
//|                                  Copyright 2025, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//| MVC Paradigm in MQL5                                             |
//| First See in: Containers                                         |
//|                           https://www.mql5.com/en/articles/18658 |
//| Update in: Resizable elements                                    |
//|                           https://www.mql5.com/en/articles/18941 |
//| Update in   :                                                    |
//|   Integrating the Model Component into the View Component        |
//|                           https://www.mql5.com/en/articles/19288 |
//| Current                   https://www.mql5.com/ru/articles/20596 |
//+------------------------------------------------------------------+
#property copyright "Copyright 2025, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
//+------------------------------------------------------------------+
// | Vertical scrollbar class |
//+------------------------------------------------------------------+

#ifndef __SCROLLBARV_MQH__
#define __SCROLLBARV_MQH__ 
   //+------------------------------------------------------------------+
   //| Included Standard Libraries                                      |
   //+------------------------------------------------------------------+
   //#include <Arrays\List.mqh>
   //+------------------------------------------------------------------+
   //| Included Custome Libraries                                       |
   //+------------------------------------------------------------------+
   #include "..\Defines\ControlsEnums.mqh"
   #include "ButtonArrowDown.mqh"
   #include "ButtonArrowLeft.mqh"
   #include "ButtonArrowRight.mqh"
   #include "ButtonArrowUp.mqh"
   #include "ScrollBarThumbV.mqh"
   #include "Panel.mqh"  
        
  class CScrollBarV : public CPanel
   {
      protected:
         CButtonArrowUp   *m_butt_up;                                // Up arrow button
         CButtonArrowDown *m_butt_down;                              // Down arrow button
         CScrollBarThumbV *m_thumb;                                  // Scrollbar slider

      public:
      // --- Returns a pointer to (1) left, (2) right button, (3) slider
         CButtonArrowUp   *GetButtonUp(void)                         { return this.m_butt_up;      }
         CButtonArrowDown *GetButtonDown(void)                       { return this.m_butt_down;    }
         CScrollBarThumbV *GetThumb(void)                            { return this.m_thumb;        }

      // --- (1) Sets, (2) returns the graph update flag
         void              SetChartRedrawFlag(const bool flag)       { if(this.m_thumb!=NULL) this.m_thumb.SetChartRedrawFlag(flag);         }
         bool              ChartRedrawFlag(void)               const { return(this.m_thumb!=NULL ? this.m_thumb.ChartRedrawFlag() : false);  }

      // --- Returns (1) the length (2) the start of the track, (3) the position of the slider
         int               TrackLength(void)    const;
         int               TrackBegin(void)     const;
         int               ThumbPosition(void)  const;
         
      // --- Sets the position of the slider
         bool              SetThumbPosition(const int pos)     const { return(this.m_thumb!=NULL ? this.m_thumb.MoveY(pos) : false);         }
      // --- Changes the size of the slider
         bool              SetThumbSize(const uint size)       const { return(this.m_thumb!=NULL ? this.m_thumb.ResizeH(size) : false);      }
         
      // --- Changes the height of an object
         virtual bool      ResizeH(const int size);
         
      // --- Sets the visibility flag in the container
         virtual void      SetVisibleInContainer(const bool flag);
         
      // --- Sets the clipping flag to the container's borders
         virtual void      SetTrimmered(const bool flag);

      // ---Draws the appearance
         virtual void      Draw(const bool chart_redraw);
         
      // ---Object type
         virtual int       Type(void)                          const { return(ELEMENT_TYPE_SCROLLBAR_V);                                     }
         
      // --- Initialize (1) class object, (2) default object colors
         void              Init(void);
         virtual void      InitColors(void);
         
      // --- Wheel scroll handler
         virtual void      OnWheelEvent(const int id, const long lparam, const double dparam, const string sparam);
         
      // --- Constructors/destructor
                           CScrollBarV(void);
                           CScrollBarV(const string object_name, const string text, const long chart_id, const int wnd, const int x, const int y, const int w, const int h);
                           ~CScrollBarV(void) {}
   };
  #ifndef CSCROLLBARV_IMPLEMENTATION
  #define CSCROLLBARV_IMPLEMENTATION
   //+------------------------------------------------------------------+
   // | CScrollBarV::Default constructor.                           |
   // | Plots an element in the main window of the current chart |
   // | at coordinates 0,0 with default dimensions |
   //+------------------------------------------------------------------+
   CScrollBarV::CScrollBarV(void) : CPanel("ScrollBarV","",::ChartID(),0,0,0,DEF_PANEL_W,DEF_PANEL_H),m_butt_up(NULL),m_butt_down(NULL),m_thumb(NULL)
    {
     // ---Initialization
      this.Init();
    }
   //+------------------------------------------------------------------+
   // | CScrollBarV::Parametric constructor.                        |
   // | Plots an element in the specified window of the specified chart |
   // | with specified text, coordinates and dimensions |
   //+------------------------------------------------------------------+
   CScrollBarV::CScrollBarV(const string object_name,const string text,const long chart_id,const int wnd,const int x,const int y,const int w,const int h) :
      CPanel(object_name,text,chart_id,wnd,x,y,w,h),m_butt_up(NULL),m_butt_down(NULL),m_thumb(NULL)
    {
     // ---Initialization
      this.Init();
    }
   //+------------------------------------------------------------------+
   // | CScrollBarV::Initializing |
   //+------------------------------------------------------------------+
   void CScrollBarV::Init(void)
    {
     // ---Initializing the parent class
      CPanel::Init();
     // --- Background - opaque
      this.SetAlphaBG(255);
     // --- Frame width and text
      this.SetBorderWidth(0);
      this.SetText("");      
     // ---Creating scroll buttons
      int w=this.Width();
      int h=this.Width();
      this.m_butt_up = (CButtonArrowUp*) this.InsertNewElement(ELEMENT_TYPE_BUTTON_ARROW_UP, "","ButtU",0,0,w,h);
      this.m_butt_down= (CButtonArrowDown*) this.InsertNewElement(ELEMENT_TYPE_BUTTON_ARROW_DOWN,"","ButtD",0,this.Height()-w,w,h);
      if(this.m_butt_up==NULL || this.m_butt_down==NULL)
      {
         ::PrintFormat("%s: Init failed",__FUNCTION__);
         return;
      }
     // --- Customize the colors and appearance of the up arrow button
      this.m_butt_up.SetImageBound(1,0,w-4,h-2);
      this.m_butt_up.InitBackColors(this.m_butt_up.BackColorFocused());
      this.m_butt_up.ColorsToDefault();
      this.m_butt_up.InitBorderColors(this.BorderColor(),this.m_butt_up.BackColorFocused(),this.m_butt_up.BackColorPressed(),this.m_butt_up.BackColorBlocked());
      this.m_butt_up.ColorsToDefault();
      
     // --- Customize the colors and appearance of the down arrow button
      this.m_butt_down.SetImageBound(1,0,w-4,h-2);
      this.m_butt_down.InitBackColors(this.m_butt_down.BackColorFocused());
      this.m_butt_down.ColorsToDefault();
      this.m_butt_down.InitBorderColors(this.BorderColor(),this.m_butt_down.BackColorFocused(),this.m_butt_down.BackColorPressed(),this.m_butt_down.BackColorBlocked());
      
     // --- Create a slider
      int tsz=this.Height()-w*2;
      this.m_thumb=(CScrollBarThumbV*) this.InsertNewElement(ELEMENT_TYPE_SCROLLBAR_THUMB_V,"","ThumbV",1,w,w-2,tsz/2);
      if(this.m_thumb==NULL)
      {
         ::PrintFormat("%s: Init failed",__FUNCTION__);
         return;
      }
     // --- Customize the colors of the slider and set the movability flag for it
      this.m_thumb.InitBackColors(this.m_thumb.BackColorFocused());
      this.m_thumb.ColorsToDefault();
      this.m_thumb.InitBorderColors(this.m_thumb.BackColor(),this.m_thumb.BackColorFocused(),this.m_thumb.BackColorPressed(),this.m_thumb.BackColorBlocked());
      this.m_thumb.ColorsToDefault();
      this.m_thumb.SetMovable(true);
     // --- we prohibit independent redrawing of the graph
      this.m_thumb.SetChartRedrawFlag(false);
      
     // --- Initially not displayed in the container and is not cut off along its borders
      this.SetVisibleInContainer(false);
      this.SetTrimmered(false);
    }
   //+------------------------------------------------------------------+
   // | CScrollBarV::Initializing default object colors |
   //+------------------------------------------------------------------+
   void CScrollBarV::InitColors(void)
    {
     // --- Initialize the background colors for normal and activated states and make it the current background color
      this.InitBackColors(clrWhiteSmoke,clrWhiteSmoke,clrWhiteSmoke,clrWhiteSmoke);
      this.InitBackColorsAct(clrWhiteSmoke,clrWhiteSmoke,clrWhiteSmoke,clrWhiteSmoke);
      this.BackColorToDefault();
      
     // --- Initialize the foreground colors for normal and activated states and make it the current text color
      this.InitForeColors(clrBlack,clrBlack,clrBlack,clrSilver);
      this.InitForeColorsAct(clrBlack,clrBlack,clrBlack,clrSilver);
      this.ForeColorToDefault();
      
     // --- Initialize the border colors for the normal and activated states and make it the current border color
      this.InitBorderColors(clrLightGray,clrLightGray,clrLightGray,clrSilver);
      this.InitBorderColorsAct(clrLightGray,clrLightGray,clrLightGray,clrSilver);
      this.BorderColorToDefault();
      
     // --- Initialize the border color and foreground color for the locked element
      this.InitBorderColorBlocked(clrSilver);
      this.InitForeColorBlocked(clrSilver);
    }
   //+------------------------------------------------------------------+
   // | CScrollBarV::Sets the visibility flag in the container |
   //+------------------------------------------------------------------+
   void CScrollBarV::SetVisibleInContainer(const bool flag)
    {
      this.m_visible_in_container=flag;
      if(this.m_butt_up!=NULL)
         this.m_butt_up.SetVisibleInContainer(flag);
      if(this.m_butt_down!=NULL)
         this.m_butt_down.SetVisibleInContainer(flag);
      if(this.m_thumb!=NULL)
         this.m_thumb.SetVisibleInContainer(flag);
    }
   //+------------------------------------------------------------------+
   // | CScrollBarV::Set the container's clipping flag |
   //+------------------------------------------------------------------+
   void CScrollBarV::SetTrimmered(const bool flag)
    {
      this.m_trim_flag=flag;
      if(this.m_butt_up!=NULL)
         this.m_butt_up.SetTrimmered(flag);
      if(this.m_butt_down!=NULL)
         this.m_butt_down.SetTrimmered(flag);
      if(this.m_thumb!=NULL)
         this.m_thumb.SetTrimmered(flag);
    }
   //+------------------------------------------------------------------+
   // | CScrollBarV::Draws appearance |
   //+------------------------------------------------------------------+
   void CScrollBarV::Draw(const bool chart_redraw)
    {
     // --- Fill the button with the background color, draw a frame and update the background canvas
      this.Fill(this.BackColor(),false);
      this.m_background.Rectangle(this.AdjX(0),this.AdjY(0),this.AdjX(this.Width()-1),this.AdjY(this.Height()-1),::ColorToARGB(this.BorderColor(),this.AlphaBG()));
      this.m_background.Update(false);
     // --- Updating the background canvas without redrawing the graph
      this.m_background.Update(false);
      
     // --- Drawing list elements without redrawing the graph
      for(int i=0;i<this.m_list_elm.Total();i++)
      {
         CElementBase *elm=this.GetAttachedElementAt(i);
         if(elm!=NULL)
            elm.Draw(false);
      }
     // --- If indicated, update the schedule
      if(chart_redraw)
         ::ChartRedraw(this.m_chart_id);
    }
   //+------------------------------------------------------------------+
   // | CScrollBarV::Returns track length |
   //+------------------------------------------------------------------+
   int CScrollBarV::TrackLength(void) const
    {
      if(this.m_butt_up==NULL || this.m_butt_down==NULL)
         return 0;
      return(this.m_butt_down.Y()-this.m_butt_up.Bottom());
    }
   //+------------------------------------------------------------------+
   // | CScrollBarV::Returns the start of the slider |
   //+------------------------------------------------------------------+
   int CScrollBarV::TrackBegin(void) const
    {
      return(this.m_butt_up!=NULL ? this.m_butt_up.Height() : 0);
    }
   //+------------------------------------------------------------------+
   // | CScrollBarV::Returns the position of the slider |
   //+------------------------------------------------------------------+
   int CScrollBarV::ThumbPosition(void) const
    {
      int pos=(this.m_thumb!=NULL ? this.m_thumb.Y()-this.TrackBegin()-this.Y() : 0);
      return(pos<0 ? 0 : pos);
    }
   //+------------------------------------------------------------------+
   // | CScrollBarV::Changes the height of an object |
   //+------------------------------------------------------------------+
   bool CScrollBarV::ResizeH(const int size)
    {
     // --- Getting pointers to the top and bottom buttons
      if(this.m_butt_up==NULL || this.m_butt_down==NULL)
         return false;
     // --- Changing the height of the object
      if(!CCanvasBase::ResizeH(size))
         return false;
     // --- Move the buttons to a new location relative to the top and bottom borders of the element that changed the size
      if(!this.m_butt_up.MoveY(this.Y()))
         return false;
      return(this.m_butt_down.MoveY(this.Bottom()-this.m_butt_down.Height()+1));
    }
   //+------------------------------------------------------------------+
   // | CScrollBarV::Wheel scroll handler |
   //+------------------------------------------------------------------+
   void CScrollBarV::OnWheelEvent(const int id,const long lparam,const double dparam,const string sparam)
    {
     // --- Call the scroll handler for the slider
      if(this.m_thumb!=NULL)
         this.m_thumb.OnWheelEvent(id,this.ThumbPosition(),dparam,this.NameFG());
         
     // --- Send a custom event to the chart with the slider position in lparam and the object name in sparam
      ::EventChartCustom(this.m_chart_id,CHARTEVENT_MOUSE_WHEEL,this.ThumbPosition(),dparam,this.NameFG());
    }
   //+------------------------------------------------------------------+
  #endif // CSCROLLBARV_IMPLEMENTATION
#endif // __SCROLLBARV_MQH__



