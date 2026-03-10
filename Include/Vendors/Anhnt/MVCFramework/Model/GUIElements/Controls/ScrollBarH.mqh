//+------------------------------------------------------------------+
//|                                                   ScrollBarH.mqh |
//+------------------------------------------------------------------+
//|                   Tables in the MVC Paradigm in MQL5             |
//|                Customizable and sortable table columns           |
//|                   https://www.mql5.com/en/articles/19979         |
//+------------------------------------------------------------------+

#ifndef __SCROLLBAR_H_MQH__
#define __SCROLLBAR_H_MQH__
//+------------------------------------------------------------------+
//| Horizontal scrollbar class                                       |
//+------------------------------------------------------------------+
//|Include stadard library                                           |
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//|Include Custome library                                           |
//+------------------------------------------------------------------+
#include "Panel.mqh"
#include "ButtonArrowLeft.mqh"
#include "ButtonArrowRight.mqh"
#include "ScrollBarThumbH.mqh"
// CScrollBarH
//  → CPanel
//  → CLabel
//  → CElementBase
//  → CCanvasBase
//  → CBoundedObj
//  → CBaseObj
//  → CObject

class CScrollBarH : public CPanel
  {
protected:
   CButtonArrowLeft *m_butt_left;    // Left arrow button
   CButtonArrowRight*m_butt_right;   // Right arrow button
   CScrollBarThumbH *m_thumb;        // Scrollbar thumb

public:

//--- Return pointer to (1) left button, (2) right button, (3) thumb
   CButtonArrowLeft *GetButtonLeft(void)  { return this.m_butt_left;  }
   CButtonArrowRight*GetButtonRight(void) { return this.m_butt_right; }
   CScrollBarThumbH *GetThumb(void)       { return this.m_thumb;      }

//--- (1) set, (2) get chart redraw flag
   void SetChartRedrawFlag(const bool flag)
      { if(this.m_thumb!=NULL) this.m_thumb.SetChartRedrawFlag(flag); }

   bool ChartRedrawFlag(void) const
      { return(this.m_thumb!=NULL ? this.m_thumb.ChartRedrawFlag() : false); }

//--- Return (1) track length, (2) track begin, (3) thumb position
   int TrackLength(void) const;
   int TrackBegin(void) const;
   int ThumbPosition(void) const;

//--- Set thumb position
   bool SetThumbPosition(const int pos) const
      { return(this.m_thumb!=NULL ? this.m_thumb.MoveX(pos) : false); }

//--- Change thumb size
   bool SetThumbSize(const uint size) const
      { return(this.m_thumb!=NULL ? this.m_thumb.ResizeW(size) : false); }

//--- Resize object width
   virtual bool ResizeW(const int size);

//--- Set visibility flag inside container
   virtual void SetVisibleInContainer(const bool flag);

//--- Set trimming flag by container bounds
   virtual void SetTrimmered(const bool flag);

//--- Draw appearance
   virtual void Draw(const bool chart_redraw);

//--- Object type
   virtual int Type(void) const { return(ELEMENT_TYPE_SCROLLBAR_H); }

//--- Initialization (1) class object, (2) default colors
   void Init(void);
   virtual void InitColors(void);

//--- Mouse wheel handler
   virtual void OnWheelEvent(const int id,const long lparam,const double dparam,const string sparam);

//--- Constructors / destructor
   CScrollBarH(void);
   CScrollBarH(const string object_name,const string text,const long chart_id,const int wnd,const int x,const int y,const int w,const int h);
   ~CScrollBarH(void){}
  };

//+------------------------------------------------------------------+
//| Default constructor                                              |
//| Builds element in the main chart window                          |
//| at coordinates 0,0 with default size                             |
//+------------------------------------------------------------------+
CScrollBarH::CScrollBarH(void) :
CPanel("ScrollBarH","",::ChartID(),0,0,0,DEF_PANEL_W,DEF_PANEL_H),
m_butt_left(NULL),m_butt_right(NULL),m_thumb(NULL)
  {
   this.Init();
  }

//+------------------------------------------------------------------+
//| Parameterized constructor                                        |
//| Builds element in specified chart window with given parameters   |
//+------------------------------------------------------------------+
CScrollBarH::CScrollBarH(const string object_name,const string text,const long chart_id,const int wnd,const int x,const int y,const int w,const int h) :
CPanel(object_name,text,chart_id,wnd,x,y,w,h),
m_butt_left(NULL),m_butt_right(NULL),m_thumb(NULL)
  {
   this.Init();
  }

//+------------------------------------------------------------------+
//| Initialization                                                   |
//+------------------------------------------------------------------+
void CScrollBarH::Init(void)
  {
//--- Initialize parent class
   CPanel::Init();

//--- Background is opaque
   this.SetAlphaBG(255);

//--- Border width and text
   this.SetBorderWidth(0);
   this.SetText("");

//--- Create scroll buttons
   int w=this.Height();
   int h=this.Height();

   this.m_butt_left  = this.InsertNewElement(ELEMENT_TYPE_BUTTON_ARROW_LEFT ,"","ButtL",0,0,w,h);
   this.m_butt_right = this.InsertNewElement(ELEMENT_TYPE_BUTTON_ARROW_RIGHT,"","ButtR",this.Width()-w,0,w,h);

   if(this.m_butt_left==NULL || this.m_butt_right==NULL)
     {
      ::PrintFormat("%s: Init failed",__FUNCTION__);
      return;
     }

//--- Configure left arrow button
   this.m_butt_left.SetImageBound(1,1,w-2,h-4);
   this.m_butt_left.InitBackColors(this.m_butt_left.BackColorFocused());
   this.m_butt_left.ColorsToDefault();

   this.m_butt_left.InitBorderColors(this.BorderColor(),
                                     this.m_butt_left.BackColorFocused(),
                                     this.m_butt_left.BackColorPressed(),
                                     this.m_butt_left.BackColorBlocked());

   this.m_butt_left.ColorsToDefault();

//--- Configure right arrow button
   this.m_butt_right.SetImageBound(1,1,w-2,h-4);
   this.m_butt_right.InitBackColors(this.m_butt_right.BackColorFocused());
   this.m_butt_right.ColorsToDefault();

   this.m_butt_right.InitBorderColors(this.BorderColor(),
                                      this.m_butt_right.BackColorFocused(),
                                      this.m_butt_right.BackColorPressed(),
                                      this.m_butt_right.BackColorBlocked());

   this.m_butt_right.ColorsToDefault();

//--- Create scrollbar thumb
   int tsz=this.Width()-w*2;

   this.m_thumb=this.InsertNewElement(ELEMENT_TYPE_SCROLLBAR_THUMB_H,"","ThumbH",w,1,tsz-w*4,h-2);

   if(this.m_thumb==NULL)
     {
      ::PrintFormat("%s: Init failed",__FUNCTION__);
      return;
     }

//--- Configure thumb colors and set movable flag
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

//--- Initially hidden inside container and not trimmed by bounds
   this.SetVisibleInContainer(false);
   this.SetTrimmered(false);
  }

//+------------------------------------------------------------------+
//| Initialize default colors                                        |
//+------------------------------------------------------------------+
void CScrollBarH::InitColors(void)
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
//| Set trimming flag by container bounds                            |
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
//| Draw appearance                                                  |
//+------------------------------------------------------------------+
void CScrollBarH::Draw(const bool chart_redraw)
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
int CScrollBarH::TrackLength(void) const
  {
   if(this.m_butt_left==NULL || this.m_butt_right==NULL)
      return 0;

   return(this.m_butt_right.X()-this.m_butt_left.Right());
  }

//+------------------------------------------------------------------+
//| Return track begin                                               |
//+------------------------------------------------------------------+
int CScrollBarH::TrackBegin(void) const
  {
   return(this.m_butt_left!=NULL ? this.m_butt_left.Width() : 0);
  }

//+------------------------------------------------------------------+
//| Return thumb position                                            |
//+------------------------------------------------------------------+
int CScrollBarH::ThumbPosition(void) const
  {
   int pos=(this.m_thumb!=NULL ? this.m_thumb.X()-this.TrackBegin()-this.X() : 0);
   return(pos<0 ? 0 : pos);
  }

//+------------------------------------------------------------------+
//| Resize object width                                              |
//+------------------------------------------------------------------+
bool CScrollBarH::ResizeW(const int size)
  {
   if(this.m_butt_left==NULL || this.m_butt_right==NULL)
      return false;

   if(!CCanvasBase::ResizeW(size))
      return false;

   if(!this.m_butt_left.MoveX(this.X()))
      return false;

   return(this.m_butt_right.MoveX(this.Right()-this.m_butt_right.Width()+1));
  }

//+------------------------------------------------------------------+
//| Mouse wheel handler                                              |
//+------------------------------------------------------------------+
void CScrollBarH::OnWheelEvent(const int id,const long lparam,const double dparam,const string sparam)
  {
   if(this.m_thumb!=NULL)
      this.m_thumb.OnWheelEvent(id,this.ThumbPosition(),dparam,this.NameFG());

   ::EventChartCustom(this.m_chart_id,CHARTEVENT_MOUSE_WHEEL,this.ThumbPosition(),dparam,this.NameFG());
  }

#endif