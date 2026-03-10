//+------------------------------------------------------------------+
//|                                                   ScrollBarV.mqh |
//+------------------------------------------------------------------+
//|                   Tables in the MVC Paradigm in MQL5             |
//|                Customizable and sortable table columns           |
//|                   https://www.mql5.com/en/articles/19979         |
//+------------------------------------------------------------------+

#ifndef __SCROLLBAR_V_MQH__
#define __SCROLLBAR_V_MQH__
//+------------------------------------------------------------------+
//| Vertical scrollbar class                                         |
//+------------------------------------------------------------------+
//|Include stadard library                                           |
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//|Include Custome library                                           |
//+------------------------------------------------------------------+
#include "Panel.mqh"
#include "ButtonArrowUp.mqh"
#include "ButtonArrowDown.mqh"
#include "ScrollBarThumbV.mqh"


class CScrollBarV : public CPanel
  {
protected:
   CButtonArrowUp   *m_butt_up;      // Up arrow button
   CButtonArrowDown *m_butt_down;    // Down arrow button
   CScrollBarThumbV *m_thumb;        // Scrollbar thumb

public:
//--- Return pointer to (1) up button, (2) down button, (3) thumb
   CButtonArrowUp   *GetButtonUp(void)                         { return this.m_butt_up;      }
   CButtonArrowDown *GetButtonDown(void)                       { return this.m_butt_down;    }
   CScrollBarThumbV *GetThumb(void)                            { return this.m_thumb;       }

//--- (1) Set, (2) return chart redraw flag
   void              SetChartRedrawFlag(const bool flag)       { if(this.m_thumb!=NULL) this.m_thumb.SetChartRedrawFlag(flag); }
   bool              ChartRedrawFlag(void)               const { return(this.m_thumb!=NULL ? this.m_thumb.ChartRedrawFlag() : false); }

//--- Return (1) track length, (2) track start, (3) thumb position
   int               TrackLength(void)    const;
   int               TrackBegin(void)     const;
   int               ThumbPosition(void)  const;

//--- Set thumb position
   bool              SetThumbPosition(const int pos)     const { return(this.m_thumb!=NULL ? this.m_thumb.MoveY(pos) : false); }
//--- Change thumb size
   bool              SetThumbSize(const uint size)       const { return(this.m_thumb!=NULL ? this.m_thumb.ResizeH(size) : false); }

//--- Change object height
   virtual bool      ResizeH(const int size);

//--- Set visibility flag inside container
   virtual void      SetVisibleInContainer(const bool flag);

//--- Set trimming flag by container bounds
   virtual void      SetTrimmered(const bool flag);

//--- Draw appearance
   virtual void      Draw(const bool chart_redraw);

//--- Object type
   virtual int       Type(void) const { return(ELEMENT_TYPE_SCROLLBAR_V); }

//--- Initialization (1) class object, (2) default colors
   void              Init(void);
   virtual void      InitColors(void);

//--- Mouse wheel handler
   virtual void      OnWheelEvent(const int id,const long lparam,const double dparam,const string sparam);

//--- Constructors / destructor
                     CScrollBarV(void);
                     CScrollBarV(const string object_name,const string text,const long chart_id,const int wnd,const int x,const int y,const int w,const int h);
                    ~CScrollBarV(void) {}
  };

//+------------------------------------------------------------------+
//| Default constructor                                              |
//| Builds element in main chart window                              |
//| at coordinates 0,0 with default size                             |
//+------------------------------------------------------------------+
CScrollBarV::CScrollBarV(void) :
CPanel("ScrollBarV","",::ChartID(),0,0,0,DEF_PANEL_W,DEF_PANEL_H),
m_butt_up(NULL),m_butt_down(NULL),m_thumb(NULL)
  {
   this.Init();
  }

//+------------------------------------------------------------------+
//| Parameterized constructor                                        |
//| Builds element in specified chart window with given parameters   |
//+------------------------------------------------------------------+
CScrollBarV::CScrollBarV(const string object_name,const string text,const long chart_id,const int wnd,const int x,const int y,const int w,const int h) :
CPanel(object_name,text,chart_id,wnd,x,y,w,h),
m_butt_up(NULL),m_butt_down(NULL),m_thumb(NULL)
  {
   this.Init();
  }

//+------------------------------------------------------------------+
//| Initialization                                                   |
//+------------------------------------------------------------------+
void CScrollBarV::Init(void)
  {
//--- Initialize parent class
   CPanel::Init();

//--- Background is opaque
   this.SetAlphaBG(255);

//--- Border width and text
   this.SetBorderWidth(0);
   this.SetText("");

//--- Create scroll buttons
   int w=this.Width();
   int h=this.Width();

   this.m_butt_up   = this.InsertNewElement(ELEMENT_TYPE_BUTTON_ARROW_UP,"","ButtU",0,0,w,h);
   this.m_butt_down = this.InsertNewElement(ELEMENT_TYPE_BUTTON_ARROW_DOWN,"","ButtD",0,this.Height()-w,w,h);

   if(this.m_butt_up==NULL || this.m_butt_down==NULL)
     {
      ::PrintFormat("%s: Init failed",__FUNCTION__);
      return;
     }

//--- Configure up arrow button
   this.m_butt_up.SetImageBound(1,0,w-4,h-2);
   this.m_butt_up.InitBackColors(this.m_butt_up.BackColorFocused());
   this.m_butt_up.ColorsToDefault();
   this.m_butt_up.InitBorderColors(this.BorderColor(),
                                   this.m_butt_up.BackColorFocused(),
                                   this.m_butt_up.BackColorPressed(),
                                   this.m_butt_up.BackColorBlocked());
   this.m_butt_up.ColorsToDefault();

//--- Configure down arrow button
   this.m_butt_down.SetImageBound(1,0,w-4,h-2);
   this.m_butt_down.InitBackColors(this.m_butt_down.BackColorFocused());
   this.m_butt_down.ColorsToDefault();
   this.m_butt_down.InitBorderColors(this.BorderColor(),
                                     this.m_butt_down.BackColorFocused(),
                                     this.m_butt_down.BackColorPressed(),
                                     this.m_butt_down.BackColorBlocked());

//--- Create scrollbar thumb
   int tsz=this.Height()-w*2;

   this.m_thumb=this.InsertNewElement(ELEMENT_TYPE_SCROLLBAR_THUMB_V,"","ThumbV",1,w,w-2,tsz/2);

   if(this.m_thumb==NULL)
     {
      ::PrintFormat("%s: Init failed",__FUNCTION__);
      return;
     }

//--- Configure thumb colors and movable flag
   this.m_thumb.InitBackColors(this.m_thumb.BackColorFocused());
   this.m_thumb.ColorsToDefault();
   this.m_thumb.InitBorderColors(this.m_thumb.BackColor(),
                                 this.m_thumb.BackColorFocused(),
                                 this.m_thumb.BackColorPressed(),
                                 this.m_thumb.BackColorBlocked());
   this.m_thumb.ColorsToDefault();
   this.m_thumb.SetMovable(true);

//--- Disable independent chart redraw
   this.m_thumb.SetChartRedrawFlag(false);

//--- Initially hidden in container and not trimmed by bounds
   this.SetVisibleInContainer(false);
   this.SetTrimmered(false);
  }

//+------------------------------------------------------------------+
//| Initialize default colors                                        |
//+------------------------------------------------------------------+
void CScrollBarV::InitColors(void)
  {
   this.InitBackColors(clrWhiteSmoke,clrWhiteSmoke,clrWhiteSmoke,clrWhiteSmoke);
   this.InitBackColorsAct(clrWhiteSmoke,clrWhiteSmoke,clrWhiteSmoke,clrWhiteSmoke);
   this.BackColorToDefault();

   this.InitForeColors(clrBlack,clrBlack,clrBlack,clrSilver);
   this.InitForeColorsAct(clrBlack,clrBlack,clrBlack,clrSilver);
   this.ForeColorToDefault();

   this.InitBorderColors(clrLightGray,clrLightGray,clrLightGray,clrSilver);
   this.InitBorderColorsAct(clrLightGray,clrLightGray,clrLightGray,clrSilver);
   this.BorderColorToDefault();

   this.InitBorderColorBlocked(clrSilver);
   this.InitForeColorBlocked(clrSilver);
  }

//+------------------------------------------------------------------+
//| Set visibility flag inside container                             |
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
//| Set trimming flag by container bounds                            |
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
//| Draw appearance                                                  |
//+------------------------------------------------------------------+
void CScrollBarV::Draw(const bool chart_redraw)
  {
   this.Fill(this.BackColor(),false);

   this.m_background.Rectangle(
      this.AdjX(0),
      this.AdjY(0),
      this.AdjX(this.Width()-1),
      this.AdjY(this.Height()-1),
      ::ColorToARGB(this.BorderColor(),this.AlphaBG())
   );

   this.m_background.Update(false);

//--- draw child elements
   for(int i=0;i<this.m_list_elm.Total();i++)
     {
      CElementBase *elm=this.GetAttachedElementAt(i);
      if(elm!=NULL)
         elm.Draw(false);
     }

   if(chart_redraw)
      ::ChartRedraw(this.m_chart_id);
  }

//+------------------------------------------------------------------+
//| Return track length                                              |
//+------------------------------------------------------------------+
int CScrollBarV::TrackLength(void) const
  {
   if(this.m_butt_up==NULL || this.m_butt_down==NULL)
      return 0;

   return(this.m_butt_down.Y()-this.m_butt_up.Bottom());
  }

//+------------------------------------------------------------------+
//| Return track start                                               |
//+------------------------------------------------------------------+
int CScrollBarV::TrackBegin(void) const
  {
   return(this.m_butt_up!=NULL ? this.m_butt_up.Height() : 0);
  }

//+------------------------------------------------------------------+
//| Return thumb position                                            |
//+------------------------------------------------------------------+
int CScrollBarV::ThumbPosition(void) const
  {
   int pos=(this.m_thumb!=NULL ? this.m_thumb.Y()-this.TrackBegin()-this.Y() : 0);
   return(pos<0 ? 0 : pos);
  }

//+------------------------------------------------------------------+
//| Resize object height                                             |
//+------------------------------------------------------------------+
bool CScrollBarV::ResizeH(const int size)
  {
   if(this.m_butt_up==NULL || this.m_butt_down==NULL)
      return false;

   if(!CCanvasBase::ResizeH(size))
      return false;

   if(!this.m_butt_up.MoveY(this.Y()))
      return false;

   return(this.m_butt_down.MoveY(this.Bottom()-this.m_butt_down.Height()+1));
  }

//+------------------------------------------------------------------+
//| Mouse wheel handler                                              |
//+------------------------------------------------------------------+
void CScrollBarV::OnWheelEvent(const int id,const long lparam,const double dparam,const string sparam)
  {
   if(this.m_thumb!=NULL)
      this.m_thumb.OnWheelEvent(id,this.ThumbPosition(),dparam,this.NameFG());

   ::EventChartCustom(this.m_chart_id,CHARTEVENT_MOUSE_WHEEL,this.ThumbPosition(),dparam,this.NameFG());
  }

#endif