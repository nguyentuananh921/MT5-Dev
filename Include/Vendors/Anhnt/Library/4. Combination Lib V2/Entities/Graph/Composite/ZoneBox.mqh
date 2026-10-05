//+------------------------------------------------------------------+
//|                                                      ZoneBox.mqh |
//+------------------------------------------------------------------+
#ifndef __ZONEBOX_COMPOSITE_MQH__
#define __ZONEBOX_COMPOSITE_MQH__
 #include "..\..\GBases\GBaseObj.mqh"
 #include "..\Standard\GStdRectangleObj.mqh"
 #include "..\..\Controls\Tooltip.mqh"
 #include "..\..\Defines\TimeseriesDefines.mqh"
 #include "..\..\..\Services\Colors.mqh"
#ifndef CZONEBOX_COMPOSITE_MQH_DECLARATION
#define CZONEBOX_COMPOSITE_MQH_DECLARATION
 //+------------------------------------------------------------------+
 //| Price/time zone: a native rectangle behind the candles plus a    |
 //| tooltip, no canvas of its own. Kind and colors come from the     |
 //| creator (Supply, Demand, Resistance, ...). Mouse is handled here |
 //+------------------------------------------------------------------+
 class CZoneBox : public CGBaseObj
  {
   private:
     CGStdRectangleObj m_rect;
     CTooltip          m_tooltip;
     string            m_kind;
     ENUM_SIGNAL_DIR   m_dir;
     string            m_info;
     bool              m_open_end;        // the zone reaches the right edge of the chart
     bool              m_hover;           // the cursor is inside, the tooltip is up
     bool              m_tooltip_ready;   // the tooltip canvas exists
     bool              m_click_down;      // Shift + left state at the last mouse event
     bool              Geometry(int &x_left,int &x_right,int &y_top,int &y_bottom);
     bool              EnsureTooltip(void);
     void              PlaceTooltip(const int x,const int y);
     void              OnShiftClick(const int x,const int y);
   public:
     bool              Create(const long chart_id,const int subwin,const string name);
     void              SetZone(const double top,const double bottom,const datetime time_start,const datetime time_end,
                               const string kind,const ENUM_SIGNAL_DIR dir);
     void              SetZoneStyle(const color colour,const uchar alpha,const bool filled,const int width);
     void              SetInfo(const string info)               { this.m_info=info;                                   }
     string            Kind(void)                         const { return this.m_kind;                                 }
     ENUM_SIGNAL_DIR   Direction(void)                    const { return this.m_dir;                                  }
     double            Top(void)                                { return this.m_rect.GetProperty(GRAPH_OBJ_PROP_PRICE,0); }
     double            Bottom(void)                             { return this.m_rect.GetProperty(GRAPH_OBJ_PROP_PRICE,1); }
     datetime          TimeStart(void)                          { return (datetime)this.m_rect.GetProperty(GRAPH_OBJ_PROP_TIME,0); }
     bool              CursorInside(const int x,const int y);
     virtual void      OnChartEvent(const int id,const long &lparam,const double &dparam,const string &sparam);
     virtual void      OnTimerEvent(void);
                       CZoneBox(void);
  };
#endif // CZONEBOX_COMPOSITE_MQH_DECLARATION
#ifndef CZONEBOX_COMPOSITE_MQH_IMPLEMENTATION
#define CZONEBOX_COMPOSITE_MQH_IMPLEMENTATION
 CZoneBox::CZoneBox(void) : m_kind(""),m_dir(SIGNAL_NONE),m_info(""),m_open_end(true),m_hover(false),m_tooltip_ready(false),m_click_down(false)
  {
  }
 //--- The native tooltip is off, the CTooltip child replaces it
 bool CZoneBox::Create(const long chart_id,const int subwin,const string name)
  {
   if(!this.m_rect.Create(chart_id,subwin,name))
      return false;
   this.SetName(name);
   this.SetChartID(this.m_rect.ChartID());
   this.m_subwindow=this.m_rect.SubWindow();
   ::ChartSetInteger(this.ChartID(),CHART_EVENT_MOUSE_MOVE,true);
   this.m_rect.SetFlagBack(true,false);
   this.m_rect.SetFlagSelectable(false,false);
   this.m_rect.SetTooltip("\n");
   this.AddChild(&this.m_rect);
   this.AddChild(&this.m_tooltip);
   return true;
  }
 //--- time_end=0: open to the right, the second corner is far in the future (a rectangle has no ray)
 void CZoneBox::SetZone(const double top,const double bottom,const datetime time_start,const datetime time_end,
                        const string kind,const ENUM_SIGNAL_DIR dir)
  {
   double hi=(top>=bottom ? top : bottom);
   double lo=(top>=bottom ? bottom : top);
   ENUM_TIMEFRAMES tf=(ENUM_TIMEFRAMES)::ChartPeriod(this.ChartID());
   datetime t_end=(time_end>0 ? time_end : ::iTime(::ChartSymbol(this.ChartID()),tf,0)+(datetime)(::PeriodSeconds(tf)*10000));
   this.m_rect.SetTime(time_start,0);
   this.m_rect.SetPrice(hi,0);
   this.m_rect.SetTime(t_end,1);
   this.m_rect.SetPrice(lo,1);
   this.m_open_end=(time_end==0);
   this.m_kind=kind;
   this.m_dir=dir;
  }
 void CZoneBox::SetZoneStyle(const color colour,const uchar alpha,const bool filled,const int width)
  {
   color bg=(color)::ChartGetInteger(this.ChartID(),CHART_COLOR_BACKGROUND);
   this.m_rect.SetColor(filled ? CColors::MixColors(bg,colour,alpha/255.0) : colour);
   this.m_rect.SetFlagFill(filled);
   this.m_rect.SetWidth(width);
  }
 //+------------------------------------------------------------------+
 //| Visible pixel box of the zone, clipped to the chart; false when  |
 //| nothing of it is on screen                                       |
 //+------------------------------------------------------------------+
 bool CZoneBox::Geometry(int &x_left,int &x_right,int &y_top,int &y_bottom)
  {
   datetime time_start=this.TimeStart();
   if(time_start==0)
      return false;
   int chart_w=(int)::ChartGetInteger(this.ChartID(),CHART_WIDTH_IN_PIXELS);
   int chart_h=(int)::ChartGetInteger(this.ChartID(),CHART_HEIGHT_IN_PIXELS,this.SubWindow());
   datetime t_first=::iTime(::ChartSymbol(this.ChartID()),(ENUM_TIMEFRAMES)::ChartPeriod(this.ChartID()),
                            (int)::ChartGetInteger(this.ChartID(),CHART_FIRST_VISIBLE_BAR));
   datetime time_end=(datetime)this.m_rect.GetProperty(GRAPH_OBJ_PROP_TIME,1);
   if(t_first==0 || (!this.m_open_end && time_end<t_first))
      return false;
   int dummy=0,y1=0,y2=0;
   if(!::ChartTimePriceToXY(this.ChartID(),this.SubWindow(),t_first,this.Top(),dummy,y1) ||
      !::ChartTimePriceToXY(this.ChartID(),this.SubWindow(),t_first,this.Bottom(),dummy,y2))
      return false;
   x_left=0;
   x_right=chart_w;
   if(time_start>t_first && !::ChartTimePriceToXY(this.ChartID(),this.SubWindow(),time_start,this.Top(),x_left,dummy))
      return false;
   if(!this.m_open_end)
     {
      int ex=0;
      if(::ChartTimePriceToXY(this.ChartID(),this.SubWindow(),time_end,this.Top(),ex,dummy) && ex<x_right)
         x_right=ex;
     }
   y_top   =(y1<y2 ? y1 : y2);
   y_bottom=(y1<y2 ? y2 : y1);
   if(y_bottom<0 || y_top>chart_h || x_right<=x_left)
      return false;
   x_left   =(x_left<0 ? 0 : x_left);
   y_top    =(y_top<0 ? 0 : y_top);
   y_bottom =(y_bottom>chart_h ? chart_h : y_bottom);
   return true;
  }
 bool CZoneBox::CursorInside(const int x,const int y)
  {
   int xl=0,xr=0,yt=0,yb=0;
   if(!this.Geometry(xl,xr,yt,yb))
      return false;
   return (x>=xl && x<=xr && y>=yt && y<=yb);
  }
 //--- Lazy: a zone nobody hovers never owns a canvas
 bool CZoneBox::EnsureTooltip(void)
  {
   if(this.m_tooltip_ready)
      return true;
   this.m_tooltip.Hide();
   if(!this.m_tooltip.CreateTooltip(this.ChartID(),this.SubWindow(),this.Name()+"_tip",200,40))
      return false;
   this.m_tooltip_ready=true;
   return true;
  }
 //--- Near the cursor, flipped to the other side at the chart edges
 void CZoneBox::PlaceTooltip(const int x,const int y)
  {
   int chart_w=(int)::ChartGetInteger(this.ChartID(),CHART_WIDTH_IN_PIXELS);
   int chart_h=(int)::ChartGetInteger(this.ChartID(),CHART_HEIGHT_IN_PIXELS,this.SubWindow());
   int tx=x+14;
   int ty=y+14;
   if(tx+this.m_tooltip.Width()>chart_w)
      tx=x-14-this.m_tooltip.Width();
   if(ty+this.m_tooltip.Height()>chart_h)
      ty=y-14-this.m_tooltip.Height();
   this.m_tooltip.Moving((tx<0 ? 0 : tx),(ty<0 ? 0 : ty));
  }
 void CZoneBox::OnShiftClick(const int x,const int y)
  {
   datetime t=0;
   double price=0.0;
   int sub=this.SubWindow();
   ::ChartXYToTimePrice(this.ChartID(),x,y,sub,t,price);
   ::Print("MY DEBUG CZoneBox::OnShiftClick: ",this.Name()," kind=",this.m_kind," dir=",(int)this.m_dir,
           " top=",this.Top()," bottom=",this.Bottom()," price at cursor=",price," time=",::TimeToString(t));
  }
 void CZoneBox::OnTimerEvent(void)
  {
   for(int i=0; i<this.ChildrenTotal(); i++)
      this.Child(i).OnTimerEvent();
  }
 //--- Mouse inside the box: header = kind, one line = info; outside: fade out
 void CZoneBox::OnChartEvent(const int id,const long &lparam,const double &dparam,const string &sparam)
  {
   for(int i=0; i<this.ChildrenTotal(); i++)
      this.Child(i).OnChartEvent(id,lparam,dparam,sparam);
   if(id!=CHARTEVENT_MOUSE_MOVE)
      return;
   int x=(int)lparam;
   int y=(int)dparam;
   bool click=(((int)::StringToInteger(sparam)&MOUSE_BUTT_KEY_STATE_LEFT_SHIFT)==MOUSE_BUTT_KEY_STATE_LEFT_SHIFT);   // left button + Shift
   if(click && !this.m_click_down && this.CursorInside(x,y))
      this.OnShiftClick(x,y);
   this.m_click_down=click;
   if(this.CursorInside(x,y) && this.m_info!="")
     {
      if(!this.EnsureTooltip())
         return;
      if(!this.m_hover)
        {
         this.m_hover=true;
         this.m_tooltip.ClearStrings();
         this.m_tooltip.HeaderText(this.m_kind);
         this.m_tooltip.AddString(this.m_info);
         int len=::MathMax(::StringLen(this.m_kind),::StringLen(this.m_info));
         this.m_tooltip.Resize(::MathMax(120,len*7+30),50);
         this.PlaceTooltip(x,y);
         this.m_tooltip.ShowTooltip();
         return;
        }
      this.PlaceTooltip(x,y);
      return;
     }
   if(this.m_hover)
     {
      this.m_hover=false;
      this.m_tooltip.FadeOutTooltip();
     }
  }
#endif // CZONEBOX_COMPOSITE_MQH_IMPLEMENTATION
#endif // __ZONEBOX_COMPOSITE_MQH__
