//+------------------------------------------------------------------+
//|                                                 ScrollBarH.mqh   |
//|                                  Copyright 2025, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//| MVC Paradigm in MQL5                                             |
//| First See in             https://www.mql5.com/en/articles/18221  |
//| Current                   https://www.mql5.com/ru/articles/20596 |
//+------------------------------------------------------------------+
#property copyright "Copyright 2025, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
//+------------------------------------------------------------------+
//| Horizontal Scrollbar Class |
//+------------------------------------------------------------------+
#ifndef __SCROLLBARH_MQH__
#define __SCROLLBARH_MQH__
   //+------------------------------------------------------------------+
   //| Included Standard Libraries                                      |
   //+------------------------------------------------------------------+
   //#include <Arrays\List.mqh>
   //+------------------------------------------------------------------+
   //| Included Custome Libraries                                       |
   //+------------------------------------------------------------------+	
   #include "Panel.mqh"
 class CScrollBarH : public CPanel
  {
   protected:
      CButtonArrowLeft *m_butt_left;                              // Left Arrow Button
      CButtonArrowRight*m_butt_right;                             // Right arrow button
      CScrollBarThumbH *m_thumb;                                  // Scrollbar slider

   public:
   // --- Returns a pointer to (1) left, (2) right button, (3) slider
      CButtonArrowLeft *GetButtonLeft(void)                       { return this.m_butt_left;                                              }
      CButtonArrowRight*GetButtonRight(void)                      { return this.m_butt_right;                                             }
      CScrollBarThumbH *GetThumb(void)                            { return this.m_thumb;                                                  }

   // --- (1) Sets, (2) returns the graph update flag
      void              SetChartRedrawFlag(const bool flag)       { if(this.m_thumb!=NULL) this.m_thumb.SetChartRedrawFlag(flag);         }
      bool              ChartRedrawFlag(void)               const { return(this.m_thumb!=NULL ? this.m_thumb.ChartRedrawFlag() : false);  }

   // --- Returns (1) the length (2) the start of the track, (3) the position of the slider
      int               TrackLength(void)    const;
      int               TrackBegin(void)     const;
      int               ThumbPosition(void)  const;
      
   // --- Sets the position of the slider
      bool              SetThumbPosition(const int pos)     const { return(this.m_thumb!=NULL ? this.m_thumb.MoveX(pos) : false);         }
   // --- Changes the size of the slider
      bool              SetThumbSize(const uint size)       const { return(this.m_thumb!=NULL ? this.m_thumb.ResizeW(size) : false);      }

   // --- Changes the width of an object
      virtual bool      ResizeW(const int size);
      
   // --- Sets the visibility flag in the container
      virtual void      SetVisibleInContainer(const bool flag);
      
   // --- Sets the clipping flag to the container's borders
      virtual void      SetTrimmered(const bool flag);

   // ---Draws the appearance
      virtual void      Draw(const bool chart_redraw);
      
   // ---Object type
      virtual int       Type(void)                          const { return(ELEMENT_TYPE_SCROLLBAR_H);                                     }
      
   // --- Initialize (1) class object, (2) default object colors
      void              Init(void);
      virtual void      InitColors(void);
      
   // --- Wheel scroll handler
      virtual void      OnWheelEvent(const int id, const long lparam, const double dparam, const string sparam);

   // --- Constructors/destructor
                        CScrollBarH(void);
                        CScrollBarH(const string object_name, const string text, const long chart_id, const int wnd, const int x, const int y, const int w, const int h);
                     ~CScrollBarH(void) {}
  };
  #ifndef CSCROLLBARH_IMPLEMENTATION
  #define CSCROLLBARH_IMPLEMENTATION
   //+------------------------------------------------------------------+
   // | CScrollBarH::Default constructor.                           |
   // | Plots an element in the main window of the current chart |
   // | at coordinates 0,0 with default dimensions |
   //+------------------------------------------------------------------+
   CScrollBarH::CScrollBarH(void) : CPanel("ScrollBarH","",::ChartID(),0,0,0,DEF_PANEL_W,DEF_PANEL_H),m_butt_left(NULL),m_butt_right(NULL),m_thumb(NULL)
    {
     // ---Initialization
      this.Init();
    }
   //+------------------------------------------------------------------+
   // | CScrollBarH::The constructor is parametric.                        |
   // | Plots an element in the specified window of the specified chart |
   // | with specified text, coordinates and dimensions |
   //+------------------------------------------------------------------+
   CScrollBarH::CScrollBarH(const string object_name,const string text,const long chart_id,const int wnd,const int x,const int y,const int w,const int h) :
      CPanel(object_name,text,chart_id,wnd,x,y,w,h),m_butt_left(NULL),m_butt_right(NULL),m_thumb(NULL)
    {
     // ---Initialization
      this.Init();
    }
   //+------------------------------------------------------------------+
   // | CScrollBarH::Initializing |
   //+------------------------------------------------------------------+
   void CScrollBarH::Init(void)
    {
     // ---Initializing the parent class
      CPanel::Init();
     // --- Background - opaque
      this.SetAlphaBG(255);
     // --- Frame width and text
      this.SetBorderWidth(0);
      this.SetText("");
      
     // ---Creating scroll buttons
      int w=this.Height();
      int h=this.Height();
      this.m_butt_left = this.InsertNewElement(ELEMENT_TYPE_BUTTON_ARROW_LEFT, "","ButtL",0,0,w,h);
      this.m_butt_right= this.InsertNewElement(ELEMENT_TYPE_BUTTON_ARROW_RIGHT,"","ButtR",this.Width()-w,0,w,h);
      if(this.m_butt_left==NULL || this.m_butt_right==NULL)
      {
         ::PrintFormat("%s: Init failed",__FUNCTION__);
         return;
      }
     // --- Customize the colors and appearance of the left arrow button
      this.m_butt_left.SetImageBound(1,1,w-2,h-4);
      this.m_butt_left.InitBackColors(this.m_butt_left.BackColorFocused());
      this.m_butt_left.ColorsToDefault();
      this.m_butt_left.InitBorderColors(this.BorderColor(),this.m_butt_left.BackColorFocused(),this.m_butt_left.BackColorPressed(),this.m_butt_left.BackColorBlocked());
      this.m_butt_left.ColorsToDefault();
      
     // --- Customize the colors and appearance of the right arrow button
      this.m_butt_right.SetImageBound(1,1,w-2,h-4);
      this.m_butt_right.InitBackColors(this.m_butt_right.BackColorFocused());
      this.m_butt_right.ColorsToDefault();
      this.m_butt_right.InitBorderColors(this.BorderColor(),this.m_butt_right.BackColorFocused(),this.m_butt_right.BackColorPressed(),this.m_butt_right.BackColorBlocked());
      this.m_butt_right.ColorsToDefault();
      
     // --- Create a slider
      int tsz=this.Width()-w*2;
      this.m_thumb=this.InsertNewElement(ELEMENT_TYPE_SCROLLBAR_THUMB_H,"","ThumbH",w,1,tsz-w*4,h-2);
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
     // --- We prohibit independent redrawing of the graph
      this.m_thumb.SetChartRedrawFlag(false);
      
     // --- Initially not displayed in the container and is not cut off along its borders
      this.SetVisibleInContainer(false);
      this.SetTrimmered(false);
    }
   //+------------------------------------------------------------------+
   // | CScrollBarH::Initializing default object colors |
   //+------------------------------------------------------------------+
   void CScrollBarH::InitColors(void)
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
   // | CScrollBarH::Sets the visibility flag in the container |
   //+------------------------------------------------------------------+
   void CScrollBarH::SetVisibleInContainer(const bool flag)
    {
      this.m_visible_in_container=flag;
      if(this.m_butt_left!=NULL)
         this.m_butt_left.SetVisibleInContainer(flag);
      if(this.m_butt_right!=NULL)
         this.m_butt_right.SetVisibleInContainer(flag);
      if(this.m_thumb!=NULL)
         this.m_thumb.SetVisibleInContainer(flag);
    }
   //+------------------------------------------------------------------+
   // | CScrollBarH::Sets the container's clipping flag |
   //+------------------------------------------------------------------+
   void CScrollBarH::SetTrimmered(const bool flag)
    {
      this.m_trim_flag=flag;
      if(this.m_butt_left!=NULL)
         this.m_butt_left.SetTrimmered(flag);
      if(this.m_butt_right!=NULL)
         this.m_butt_right.SetTrimmered(flag);
      if(this.m_thumb!=NULL)
         this.m_thumb.SetTrimmered(flag);
    }
   //+------------------------------------------------------------------+
   // | CScrollBarH::Draws appearance |
   //+------------------------------------------------------------------+
   void CScrollBarH::Draw(const bool chart_redraw)
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
   // | CScrollBarH::Returns track length |
   //+------------------------------------------------------------------+
   int CScrollBarH::TrackLength(void) const
    {
      if(this.m_butt_left==NULL || this.m_butt_right==NULL)
         return 0;
      return(this.m_butt_right.X()-this.m_butt_left.Right());
    }
   //+------------------------------------------------------------------+
   // | CScrollBarH::Returns the start of the track |
   //+------------------------------------------------------------------+
   int CScrollBarH::TrackBegin(void) const
    {
      return(this.m_butt_left!=NULL ? this.m_butt_left.Width() : 0);
    }
   //+------------------------------------------------------------------+
   // | CScrollBarH::Returns the position of the slider |
   //+------------------------------------------------------------------+
   int CScrollBarH::ThumbPosition(void) const
    {
      int pos=(this.m_thumb!=NULL ? this.m_thumb.X()-this.TrackBegin()-this.X() : 0);
      return(pos<0 ? 0 : pos);
    }
   //+------------------------------------------------------------------+
   // | CScrollBarH::Changes the width of an object |
   //+------------------------------------------------------------------+
   bool CScrollBarH::ResizeW(const int size)
    {
     // --- Getting pointers to the left and right buttons
      if(this.m_butt_left==NULL || this.m_butt_right==NULL)
         return false;
     // --- Changing the width of the object
      if(!CCanvasBase::ResizeW(size))
         return false;
     // --- Move the buttons to a new location relative to the left and right borders of the element that has changed size
      if(!this.m_butt_left.MoveX(this.X()))
         return false;
      return(this.m_butt_right.MoveX(this.Right()-this.m_butt_right.Width()+1));
    }
   //+------------------------------------------------------------------+
   // | CScrollBarH::Wheel scroll handler |
   //+------------------------------------------------------------------+
   void CScrollBarH::OnWheelEvent(const int id,const long lparam,const double dparam,const string sparam)
    {
     // --- Call the scroll handler for the slider
      if(this.m_thumb!=NULL)
         this.m_thumb.OnWheelEvent(id,this.ThumbPosition(),dparam,this.NameFG());
         
     // --- Send a custom event to the chart with the slider position in lparam and the object name in sparam
      ::EventChartCustom(this.m_chart_id,CHARTEVENT_MOUSE_WHEEL,this.ThumbPosition(),dparam,this.NameFG());
    }
    //+------------------------------------------------------------------+
  #endif // CSCROLLBARH_IMPLEMENTATION
#endif // __SCROLLBARH_MQH__


