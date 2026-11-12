//+------------------------------------------------------------------+
//|                                                   ZoneTagBox.mqh |
//+------------------------------------------------------------------+
#ifndef __ZONETAGBOX_COMPOSITE_MQH__
#define __ZONETAGBOX_COMPOSITE_MQH__
 #include "..\..\GBases\GLayerItem.mqh"
 #include "..\Standard\GStdRectangleObj.mqh"
 #include "..\..\Defines\CommonDefines.mqh"
 #include "..\..\Defines\GUIDefines.mqh"   // the unified sizes: M_CONTROL_HEIGHT, M_CONTROL_BORDER_GAP
 #include "..\..\Defines\MouseDefines.mqh"
 #include "..\Properties\Colors.mqh"
 #include "CandleMarker.mqh"   // the box that lights a candle
 #define ZONETAG_PAD          5     // space at the left and the right of the tag
 #define ZONETAG_CHECK        12    // the checkbox square
 #define ZONETAG_GAP          4     // space between the checkbox and the text
 #define ZONETAG_MAX_STACK    60    // a tag that finds no free place after this many steps stays where it is
#ifndef CZONETAGBOX_COMPOSITE_DECLARATION
#define CZONETAGBOX_COMPOSITE_DECLARATION
 //+------------------------------------------------------------------+
 //| A zone of the chart that is folded into a small tag: a box of 22 |
 //| px with the kind of the zone and a checkbox. The tag paints      |
 //| itself on the shared layer of the collection (no canvas of its   |
 //| own); the zone is a native rectangle that is hidden until the    |
 //| checkbox is checked. The tags are put at the left edge of their  |
 //| zone and pushed down by Arrange() when they would touch. The     |
 //| zones of ONE candle (the momentum candle: its demand / supply   |
 //| zone and its FVG) have the same group time: their tags are put   |
 //| side by side as one box with a checkbox for each zone, and the   |
 //| cursor on it lights that candle                                  |
 //+------------------------------------------------------------------+
 class CZoneTagBox : public CGLayerItem
  {
   private:
     CGStdRectangleObj m_rect;            // the zone, a native rectangle (child)
     string            m_kind;            // the words on the tag: "Demand", "Supply", "Bull FVG"...
     ENUM_SIGNAL_DIR   m_dir;
     string            m_info;
     color             m_colour;          // the colour of the zone, the tag takes it
     bool              m_open;            // the zone is shown (the checkbox is checked)
     bool              m_open_end;        // the zone reaches the right edge of the chart
     bool              m_on_chart;        // Arrange() found the zone on the screen: m_tag_x / m_tag_y are valid
     int               m_tag_x;           // the tag, in chart pixels, set by Arrange()
     int               m_tag_y;
     int               m_tag_w;           // the width of the tag: measured when it is painted, an estimate before
     bool              m_hover_check;     // the cursor is on the checkbox
     bool              m_prev_left;       // the left button was down at the last mouse event
     bool              m_covered;         // a window covers the cursor (set by the collection before each mouse move)
     datetime          m_dead_time;       // when it died, 0 while it lives
     datetime          m_group_time;      // the candle the zone comes from (0 = none): the tags of one candle make one box
     CGBaseObj        *m_holder;          // not owned: whoever holds the tags, given to Arrange(), needed to light the candle
     bool              m_hover_tag;       // the cursor is on the tag
     bool              m_user_set;        // the user clicked the checkbox: OpenAuto() leaves it as it is
     static CZoneTagBox *m_highlight_owner;   // the tag whose candle is lit now
     bool              Geometry(int &x_left,int &x_right,int &y_top,int &y_bottom);
     int               EstimatedWidth(void) const;
     bool              OnCheckbox(const int x,const int y) const;
     void              SetOpen(const bool open);
   public:
     bool              Create(const long chart_id,const int subwin,const string name);
   //--- time_end=0: open to the right
     void              SetZone(const double top,const double bottom,const datetime time_start,const datetime time_end,
                               const string kind,const ENUM_SIGNAL_DIR dir);
     void              SetZoneStyle(const color colour,const uchar alpha,const bool filled,const int width);
     void              SetInfo(const string info)               { this.m_info=info; this.m_rect.SetTooltip(info=="" ? "\n" : info); }   // the native tooltip, on the zone when it is shown
     void              SetDeadTime(const datetime time)         { this.m_dead_time=time; }
     void              SetGroupTime(const datetime time)        { this.m_group_time=time; }
     datetime          GroupTime(void)                    const { return this.m_group_time; }
     void              Open(const bool open)                    { this.SetOpen(open);    }
   //--- Open or fold by a rule of the EA (the newest zones): not when the user has set this one by hand
     void              OpenAuto(const bool open)                { if(!this.m_user_set) this.SetOpen(open); }
     bool              IsOpen(void)                       const { return this.m_open;    }
     datetime          DeadTime(void)                     const { return this.m_dead_time;}
     string            Kind(void)                         const { return this.m_kind;    }
     string            Info(void)                         const { return this.m_info;    }
     ENUM_SIGNAL_DIR   Direction(void)                    const { return this.m_dir;     }
     double            Top(void)                                { return this.m_rect.GetProperty(GRAPH_OBJ_PROP_PRICE,0); }
     double            Bottom(void)                             { return this.m_rect.GetProperty(GRAPH_OBJ_PROP_PRICE,1); }
     datetime          TimeStart(void)                          { return (datetime)this.m_rect.GetProperty(GRAPH_OBJ_PROP_TIME,0); }
     virtual void      SetCovered(const bool covered);
     virtual void      Paint(CCanvas *canvas);
     virtual bool      HitTest(const int x,const int y);
     virtual void      OnChartEvent(const int id,const long &lparam,const double &dparam,const string &sparam);
   //--- Put the tags: at the left edge of their zone (of the chart when the zone starts before it), the higher price first, pushed down when
   //--- they would touch an earlier one. Call after zones were added or changed and after a chart change (scroll, zoom, resize)
     static void       Arrange(CGBaseObj *parent);
                       CZoneTagBox(void);
                      ~CZoneTagBox(void);
  };
#endif // CZONETAGBOX_COMPOSITE_DECLARATION
#ifndef CZONETAGBOX_COMPOSITE_IMPLEMENTATION
#define CZONETAGBOX_COMPOSITE_IMPLEMENTATION
 CZoneTagBox::CZoneTagBox(void) : m_kind(""),m_dir(SIGNAL_NONE),m_info(""),m_colour(clrGray),m_open(false),m_open_end(true),m_on_chart(false),
                                  m_tag_x(0),m_tag_y(0),m_tag_w(0),m_hover_check(false),m_prev_left(false),m_covered(false),m_dead_time(0),m_group_time(0),m_holder(NULL),
                                  m_hover_tag(false),m_user_set(false)
  {
  }
 CZoneTagBox *CZoneTagBox::m_highlight_owner=NULL;
 CZoneTagBox::~CZoneTagBox(void)
  {
   if(CZoneTagBox::m_highlight_owner==&this)
     {
      CZoneTagBox::m_highlight_owner=NULL;
      CCandleMarker::ClearHighlight();
     }
  }
 //--- Born folded: only the tag shows
 bool CZoneTagBox::Create(const long chart_id,const int subwin,const string name)
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
   this.m_rect.SetVisibleFlag(false,false);
   this.AddChild(&this.m_rect);
   this.m_visible=true;   // the tag itself is shown (the zone has its own flag)
   return true;
  }
 void CZoneTagBox::SetZone(const double top,const double bottom,const datetime time_start,const datetime time_end,
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
   CGLayerItem::Invalidate();
  }
 void CZoneTagBox::SetZoneStyle(const color colour,const uchar alpha,const bool filled,const int width)
  {
   color bg=(color)::ChartGetInteger(this.ChartID(),CHART_COLOR_BACKGROUND);
   this.m_colour=colour;
   this.m_rect.SetColor(filled ? CColors::MixColors(bg,colour,alpha/255.0) : colour);
   this.m_rect.SetFlagFill(filled);
   this.m_rect.SetWidth(width);
   CGLayerItem::Invalidate();
  }
 //--- The checkbox: shows or hides the zone
 void CZoneTagBox::SetOpen(const bool open)
  {
   if(open==this.m_open)
      return;
   this.m_open=open;
   this.m_rect.SetVisibleFlag(open,false);
   CGLayerItem::Invalidate();
   ::ChartRedraw(this.ChartID());
  }
 //+------------------------------------------------------------------+
 //| Visible pixel box of the zone, clipped to the chart; false when  |
 //| nothing of it is on screen                                       |
 //+------------------------------------------------------------------+
 bool CZoneTagBox::Geometry(int &x_left,int &x_right,int &y_top,int &y_bottom)
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
   return true;
  }
 int CZoneTagBox::EstimatedWidth(void) const
  {
   return ZONETAG_PAD+ZONETAG_CHECK+ZONETAG_GAP+7*::StringLen(this.m_kind)+ZONETAG_PAD;
  }
 void CZoneTagBox::SetCovered(const bool covered)
  {
   this.m_covered=covered;
   if(covered && this.m_hover_tag)
     {
      this.m_hover_tag=false;
      if(CZoneTagBox::m_highlight_owner==&this)
        {
         CZoneTagBox::m_highlight_owner=NULL;
         CCandleMarker::ClearHighlight();
        }
     }
  }
 bool CZoneTagBox::OnCheckbox(const int x,const int y) const
  {
   int cx=this.m_tag_x+ZONETAG_PAD,cy=this.m_tag_y+(M_CONTROL_HEIGHT-ZONETAG_CHECK)/2;
   return (this.m_on_chart && x>=cx-2 && x<=cx+ZONETAG_CHECK+2 && y>=cy-2 && y<=cy+ZONETAG_CHECK+2);
  }
 //+------------------------------------------------------------------+
 //| The tag on the shared layer: the colour of the zone, the         |
 //| checkbox and the kind of the zone                                |
 //+------------------------------------------------------------------+
 void CZoneTagBox::Paint(CCanvas *canvas)
  {
   if(!this.m_visible || !this.m_on_chart)
      return;
   canvas.FontSet(DEF_FONT,-DEF_FONT_SIZE*10);   // the font of the library (CommonDefines.mqh)
   int text_w=0,text_h=0;
   canvas.TextSize(this.m_kind,text_w,text_h);
   int w=ZONETAG_PAD+ZONETAG_CHECK+ZONETAG_GAP+text_w+ZONETAG_PAD;
   this.m_tag_w=w;
   int x=this.m_tag_x,y=this.m_tag_y;
   if(x<0 || y<0 || x+w>canvas.Width() || y+M_CONTROL_HEIGHT>canvas.Height())
      return;
   color bg=(color)::ChartGetInteger(this.ChartID(),CHART_COLOR_BACKGROUND);
   color fill=CColors::MixColors(bg,this.m_colour,(this.m_open ? 110 : 60)/255.0);   // a folded tag is paler
   canvas.FillRectangle(x,y,x+w-1,y+M_CONTROL_HEIGHT-1,::ColorToARGB(fill));
   canvas.Rectangle(x,y,x+w-1,y+M_CONTROL_HEIGHT-1,::ColorToARGB(this.m_colour));
   //--- the checkbox
   int cx=x+ZONETAG_PAD,cy=y+(M_CONTROL_HEIGHT-ZONETAG_CHECK)/2;
   canvas.FillRectangle(cx,cy,cx+ZONETAG_CHECK-1,cy+ZONETAG_CHECK-1,::ColorToARGB(this.m_hover_check ? clrWhiteSmoke : clrWhite));
   canvas.Rectangle(cx,cy,cx+ZONETAG_CHECK-1,cy+ZONETAG_CHECK-1,::ColorToARGB(this.m_hover_check ? this.m_colour : clrDimGray));
   if(this.m_open)   // the tick
     {
      canvas.LineAA(cx+2,cy+6,cx+5,cy+9,::ColorToARGB(this.m_colour));
      canvas.LineAA(cx+5,cy+9,cx+10,cy+3,::ColorToARGB(this.m_colour));
      canvas.LineAA(cx+2,cy+7,cx+5,cy+10,::ColorToARGB(this.m_colour));
      canvas.LineAA(cx+5,cy+10,cx+10,cy+4,::ColorToARGB(this.m_colour));
     }
   canvas.TextOut(cx+ZONETAG_CHECK+ZONETAG_GAP,y+(M_CONTROL_HEIGHT-text_h)/2,this.m_kind,::ColorToARGB(clrBlack),TA_LEFT|TA_TOP);
  }
 bool CZoneTagBox::HitTest(const int x,const int y)
  {
   int w=(this.m_tag_w>0 ? this.m_tag_w : this.EstimatedWidth());
   return (this.m_visible && this.m_on_chart && x>=this.m_tag_x && x<this.m_tag_x+w && y>=this.m_tag_y && y<this.m_tag_y+M_CONTROL_HEIGHT);
  }
 //+------------------------------------------------------------------+
 //| A click on the checkbox (the left button goes down on it) shows  |
 //| or hides the zone; the cursor on it lights it                    |
 //+------------------------------------------------------------------+
 void CZoneTagBox::OnChartEvent(const int id,const long &lparam,const double &dparam,const string &sparam)
  {
   if(id!=CHARTEVENT_MOUSE_MOVE || !this.m_visible)
      return;
   int x=(int)lparam,y=(int)dparam;
   bool left=((((int)::StringToInteger(sparam))&MOUSE_BUTT_KEY_STATE_LEFT)!=0);
   //--- the cursor on the tag lights the candle the zone comes from; the owner is remembered so that moving from one tag of the box to the next
   //--- (one leaves, the other enters, in any order) does not put the light out
   bool in_tag=(!this.m_covered && this.HitTest(x,y));
   if(in_tag!=this.m_hover_tag)
     {
      this.m_hover_tag=in_tag;
      if(in_tag && this.m_group_time>0)
        {
         CZoneTagBox::m_highlight_owner=&this;
         CCandleMarker::HighlightCandle(this.m_holder,this.m_group_time);
        }
      else if(!in_tag && CZoneTagBox::m_highlight_owner==&this)
        {
         CZoneTagBox::m_highlight_owner=NULL;
         CCandleMarker::ClearHighlight();
        }
      ::ChartRedraw(this.ChartID());
     }
   bool on=(!this.m_covered && this.OnCheckbox(x,y));
   if(on!=this.m_hover_check)
     {
      this.m_hover_check=on;
      CGLayerItem::Invalidate();
     }
   if(on && left && !this.m_prev_left)
     {
      this.m_user_set=true;   // from now on it is the user's
      this.SetOpen(!this.m_open);
     }
   this.m_prev_left=left;
  }
 //+------------------------------------------------------------------+
 //| The higher price first; each tag (or each box of tags of one     |
 //| candle) at the left edge of its first zone, the lowest y at which|
 //| it does not touch a box already put; the tags of a group follow  |
 //| the first one on its right                                       |
 //+------------------------------------------------------------------+
 void CZoneTagBox::Arrange(CGBaseObj *parent)
  {
   if(parent==NULL)
      return;
   CZoneTagBox *list[];
   double       tops[];
   int          n=0;
   for(int i=0; i<parent.ChildrenTotal(); i++)
     {
      CZoneTagBox *tag=dynamic_cast<CZoneTagBox *>(parent.Child(i));
      if(tag==NULL)
         continue;
      tag.m_holder=parent;
      tag.m_on_chart=false;
      int xl=0,xr=0,yt=0,yb=0;
      if(!tag.m_visible || !tag.Geometry(xl,xr,yt,yb))
         continue;
      tag.m_tag_x=(xl<2 ? 2 : xl);
      tag.m_tag_y=(yt+yb)/2-M_CONTROL_HEIGHT/2;
      double top=tag.Top();
      ::ArrayResize(list,n+1);
      ::ArrayResize(tops,n+1);
      int k=n;
      while(k>0 && tops[k-1]<top)   // the higher price first
        {
         list[k]=list[k-1];
         tops[k]=tops[k-1];
         k--;
        }
      list[k]=tag;
      tops[k]=top;
      n++;
     }
   //--- the head of each tag: the first of its group in the list (itself when it has no group)
   int head[];
   ::ArrayResize(head,n);
   for(int i=0; i<n; i++)
     {
      head[i]=i;
      if(list[i].m_group_time>0)
         for(int j=0; j<i; j++)
            if(head[j]==j && list[j].m_group_time==list[i].m_group_time)
              {
               head[i]=j;
               break;
              }
     }
   int placed_w[];   // the width of the whole box of a head
   ::ArrayResize(placed_w,n);
   for(int i=0; i<n; i++)
     {
      placed_w[i]=0;
      if(head[i]!=i)
         continue;
      for(int j=i; j<n; j++)
         if(head[j]==i)
            placed_w[i]+=(list[j].m_tag_w>0 ? list[j].m_tag_w : list[j].EstimatedWidth());
      CZoneTagBox *tag=list[i];
      for(int guard=0; guard<ZONETAG_MAX_STACK; guard++)
        {
         bool hit=false;
         for(int j=0; j<i && !hit; j++)
           {
            if(head[j]!=j)
               continue;
            CZoneTagBox *other=list[j];
            if(tag.m_tag_x<other.m_tag_x+placed_w[j]+M_CONTROL_BORDER_GAP && tag.m_tag_x+placed_w[i]+M_CONTROL_BORDER_GAP>other.m_tag_x &&
               tag.m_tag_y<other.m_tag_y+M_CONTROL_HEIGHT+M_CONTROL_BORDER_GAP && tag.m_tag_y+M_CONTROL_HEIGHT+M_CONTROL_BORDER_GAP>other.m_tag_y)
               hit=true;
           }
         if(!hit)
            break;
         tag.m_tag_y+=M_CONTROL_HEIGHT+M_CONTROL_BORDER_GAP;
        }
      //--- the others of the group, side by side
      int next_x=tag.m_tag_x+(tag.m_tag_w>0 ? tag.m_tag_w : tag.EstimatedWidth());
      for(int j=i+1; j<n; j++)
         if(head[j]==i)
           {
            list[j].m_tag_x=next_x;
            list[j].m_tag_y=tag.m_tag_y;
            next_x+=(list[j].m_tag_w>0 ? list[j].m_tag_w : list[j].EstimatedWidth());
           }
     }
   for(int i=0; i<n; i++)
      list[i].m_on_chart=true;
   CGLayerItem::Invalidate();
  }
#endif // CZONETAGBOX_COMPOSITE_IMPLEMENTATION
#endif // __ZONETAGBOX_COMPOSITE_MQH__
