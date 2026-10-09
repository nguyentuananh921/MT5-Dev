//+------------------------------------------------------------------+
//|                                                 CandleMarker.mqh |
//+------------------------------------------------------------------+
#ifndef __CANDLEMARKER_COMPOSITE_MQH__
#define __CANDLEMARKER_COMPOSITE_MQH__
 #include "..\..\GBases\GLayerItem.mqh"
 #include "..\Standard\GStdRectangleLabelObj.mqh"
 #include "..\..\Defines\GUIDefines.mqh"
 #include "..\..\Defines\MouseDefines.mqh"
 #include "..\..\Defines\ImageDataDefine.mqh"
 #include "..\Properties\Colors.mqh"
 #include "..\Properties\Image.mqh"
 //+------------------------------------------------------------------+
 //| Where the marked fact comes from: bit flags, a candle can have   |
 //| more than one source (two or more show the combination icon)     |
 //+------------------------------------------------------------------+
 enum ENUM_CANDLE_MARKER_SOURCE
  {
   CANDLE_MARKER_SOURCE_INDICATOR = 1,   // Indicator signal
   CANDLE_MARKER_SOURCE_CANDLE    = 2,   // Candle pattern
   CANDLE_MARKER_SOURCE_SMC       = 4    // Smart Money: Swing, BOS, CHoCH
  };
 #define CANDLE_MARKER_GAP        4      // gap between the candles and the badge
 #define CANDLE_MARKER_BADGE_W    20     // badge width: the icon and a frame
 #define CANDLE_MARKER_BADGE_H    20     // badge height
 #define CANDLE_MARKER_LANE_GAP   2      // gap between stacked badges
 #define CANDLE_MARKER_MAX_LANES  3      // badges that would need a higher stack are not drawn
 #define CANDLE_MARKER_BOX_MARGIN 2      // box around the candle: pixels above the high and below the low
 #define CANDLE_MARKER_ICONS      4      // indicator, candle pattern, smart money, combination
 #define CANDLE_MARKER_ARRANGE_MARGIN 3  // bars outside the visible ones that still take part in Arrange()
#ifndef CCANDLE_MARKER_COMPOSITE_DECLARATION
#define CCANDLE_MARKER_COMPOSITE_DECLARATION
 //+------------------------------------------------------------------+
 //| Badge (source icon on a colored square) put above a Sell candle  |
 //| or below a Buy candle, clear of every candle under its width.    |
 //| It has no canvas: CGraphElementsCollection owns one layer over   |
 //| the chart and every marker paints itself on it (Paint).          |
 //| Badges of the same side that would overlap are stacked outward by|
 //| Arrange(). Shift + the cursor on the badge draws a box on the    |
 //| marked candle and tells the panel to show the candle's           |
 //| information window (ON_CANDLE_MARKER_ENTER / _LEAVE)             |
 //+------------------------------------------------------------------+
 class CCandleMarker : public CGLayerItem
  {
   private:
     static CGStdRectangleLabelObj *m_rectangle_label_candle_box;   //CCandleMarker owns: the one box on the candle, shared by all markers, created on first use, deleted by ReleaseBox
     static CCandleMarker      *m_candle_marker_box_owner;          //Not owned: the CCandleMarker the box is on now (cursor on its badge, or Highlighted by the panel)
     static datetime           m_box_time;                          // open time of the candle the box is on while NO marker owns it (a candle without a visible marker), 0 = none
     datetime                  m_time;                    // open time of the marked candle
     double                    m_high;
     double                    m_low;
     bool                      m_is_buy;                  // Buy: blue badge below the candles, Sell: red badge above them
     color                     m_colour;
     int                       m_sources;                 // ENUM_CANDLE_MARKER_SOURCE flags the badge shows
     int                       m_offset;                  // pixels further out, set by Arrange() to clear the other badges
     bool                      m_layout_hidden;           // Arrange() found no room within the allowed stack
     bool                      m_on_chart;                // Arrange() found the candle on the chart: m_badge_x/y are valid
     int                       m_badge_x;                 // badge position in chart pixels, set by Arrange()
     int                       m_badge_y;
     bool                      m_hover;                   // the cursor is on the badge (Shift down)
     bool                      m_highlight;               // the panel asked for the box (Shift + hover on the candle), the cursor is not on the badge
     bool                      m_covered; 
    //Private method                // a panel window is under the cursor
     bool                      Geometry(int &x_center,int &y_high,int &y_low);
     bool                      BaseGeometry(int &badge_x,int &edge_y);
     int                       BadgeY(const int edge_y,const int offset) const;
     int                       IconIndex(void) const;
     void                      PlaceBox(void);
     void                      SetHover(const bool on);
     void                      PaintCandleBox(void);
     bool                      ShowBox(void);
     static bool               EnsureBox(const long chart_id,const int subwin);
     static void               PlaceBoxOnCandle(const datetime time);
     void                      HideBox(void);
   public:
     bool                      Create(const long chart_id,const int subwin,const string name);
     void                      SetMarker(const datetime time,const double high,const double low,const bool is_buy,
                                         const color colour,const int sources);
     void                      Show(void);
     void                      Hide(void);
     int                       Sources(void)                  const { return this.m_sources;   }
     virtual void              SetCovered(const bool covered)       { this.m_covered=covered;  }
     virtual void              OnChartEvent(const int id,const long &lparam,const double &dparam,const string &sparam);
     virtual void              Paint(CCanvas *canvas);
     virtual bool              HitTest(const int x,const int y);
   //--- Stack the badges that would overlap, oldest candle first: call after markers were added or changed and after a chart change
     static void               Arrange(CGBaseObj *parent);
   //--- The box on a candle without the cursor on its badge (Shift + hover on the candle): the marker of that candle takes it
     static void               HighlightCandle(CGBaseObj *parent,const datetime time);
     static void               ClearHighlight(void);
   //--- Delete the shared box (the markers are being deleted, or the EA is leaving)
     static void               ReleaseBox(void);
                               CCandleMarker(void);
                              ~CCandleMarker(void);
  };
#endif // CCANDLE_MARKER_COMPOSITE_DECLARATION
#ifndef CCANDLE_MARKER_COMPOSITE_IMPLEMENTATION
#define CCANDLE_MARKER_COMPOSITE_IMPLEMENTATION
 CGStdRectangleLabelObj *CCandleMarker::m_rectangle_label_candle_box=NULL;
 CCandleMarker *CCandleMarker::m_candle_marker_box_owner=NULL;
 datetime CCandleMarker::m_box_time=0;
 //--- The badge icons, read once
 CImage g_candle_marker_icon[CANDLE_MARKER_ICONS];
 bool   g_candle_marker_icon_loaded=false;
 CCandleMarker::CCandleMarker(void) : m_time(0),m_high(0),m_low(0),m_is_buy(true),m_colour(clrDodgerBlue),m_sources(0),m_offset(0),
                                      m_layout_hidden(false),m_on_chart(false),m_badge_x(0),m_badge_y(0),m_hover(false),m_highlight(false),m_covered(false)
  {
  }
 //--- Born hidden; the candle box is native and shared (ShowBox)
 bool CCandleMarker::Create(const long chart_id,const int subwin,const string name)
  {
   this.SetName(name);
   this.SetChartID(chart_id==0 ? ::ChartID() : chart_id);
   this.m_subwindow=subwin;
   this.m_visible=false;
   return true;
  }
 //--- The pale box on the candle: one for all markers, created when the cursor first comes onto any badge
 bool CCandleMarker::EnsureBox(const long chart_id,const int subwin)
  {
   if(m_rectangle_label_candle_box!=NULL)
      return true;
   CGStdRectangleLabelObj *box=new CGStdRectangleLabelObj();
   if(box==NULL || !box.Create(chart_id,subwin,"CandleMarker_Box"))
     {
      delete box;
      return false;
     }
   box.SetFlagBack(true,false);
   box.SetFlagSelectable(false,false);
   box.SetTooltip("\n");
   box.SetBorderType(BORDER_FLAT);
   box.SetVisibleFlag(false,false);
   m_rectangle_label_candle_box=box;
   return true;
  }
 bool CCandleMarker::ShowBox(void)
  {
   if(!CCandleMarker::EnsureBox(this.ChartID(),this.SubWindow()))
      return false;
   m_box_time=0;
   m_candle_marker_box_owner=::GetPointer(this);
   this.PaintCandleBox();
   return true;
  }
 void CCandleMarker::HideBox(void)
  {
   if(m_rectangle_label_candle_box==NULL || m_candle_marker_box_owner!=::GetPointer(this))
      return;
   m_rectangle_label_candle_box.SetVisibleFlag(false,false);
   m_candle_marker_box_owner=NULL;
  }
 void CCandleMarker::ReleaseBox(void)
  {
   delete m_rectangle_label_candle_box;
   m_rectangle_label_candle_box=NULL;
   m_candle_marker_box_owner=NULL;
   m_box_time=0;
  }
 //--- The box on a candle that has no visible marker: the same box, in a neutral color
 void CCandleMarker::PlaceBoxOnCandle(const datetime time)
  {
   long chart_id=::ChartID();
   string sym=::ChartSymbol(chart_id);
   ENUM_TIMEFRAMES tf=(ENUM_TIMEFRAMES)::ChartPeriod(chart_id);
   int shift=::iBarShift(sym,tf,time,true);
   int xc=0,x_low=0,y_top=0,y_bottom=0;
   if(shift<0 || !CCandleMarker::EnsureBox(chart_id,0))
      return;
   if(!::ChartTimePriceToXY(chart_id,0,time,::iHigh(sym,tf,shift),xc,y_top) ||
      !::ChartTimePriceToXY(chart_id,0,time,::iLow(sym,tf,shift),x_low,y_bottom))
     {
      m_rectangle_label_candle_box.SetVisibleFlag(false,false);
      return;
     }
   m_box_time=time;
   int slot=(int)(1<<(int)::ChartGetInteger(chart_id,CHART_SCALE));
   int w=(slot>4 ? slot-2 : slot);
   int h=y_bottom-y_top+2*CANDLE_MARKER_BOX_MARGIN;
   color bg=(color)::ChartGetInteger(chart_id,CHART_COLOR_BACKGROUND);
   m_rectangle_label_candle_box.SetBGColor(CColors::MixColors(bg,clrGray,100/255.0));
   m_rectangle_label_candle_box.SetColor(clrGray);
   m_rectangle_label_candle_box.SetXDistance(xc-w/2);
   m_rectangle_label_candle_box.SetYDistance(y_top-CANDLE_MARKER_BOX_MARGIN);
   m_rectangle_label_candle_box.SetXSize(w);
   m_rectangle_label_candle_box.SetYSize(h<8 ? 8 : h);
   m_rectangle_label_candle_box.SetVisibleFlag(true,false);
  }
 //--- The box goes to the marker of the candle, if the candle has one
 void CCandleMarker::HighlightCandle(CGBaseObj *parent,const datetime time)
  {
   CCandleMarker::ClearHighlight();
   if(parent==NULL)
      return;
   for(int i=0;i<parent.ChildrenTotal();i++)
     {
      CCandleMarker *marker=dynamic_cast<CCandleMarker *>(parent.Child(i));
      if(marker!=NULL && marker.m_time==time && marker.m_visible)
        {
         marker.m_highlight=true;
         marker.ShowBox();
         marker.PlaceBox();
         return;
        }
     }
   CCandleMarker::PlaceBoxOnCandle(time);   // the candle has no visible marker: the box is still shown
  }
 void CCandleMarker::ClearHighlight(void)
  {
   if(m_box_time!=0 && m_rectangle_label_candle_box!=NULL)
     {
      m_rectangle_label_candle_box.SetVisibleFlag(false,false);
      m_box_time=0;
     }
   if(m_candle_marker_box_owner==NULL)
      return;
   m_candle_marker_box_owner.m_highlight=false;
   if(!m_candle_marker_box_owner.m_hover)
      m_candle_marker_box_owner.HideBox();
   else
      m_candle_marker_box_owner.PlaceBox();
  }
 CCandleMarker::~CCandleMarker(void)
  {
   this.HideBox();
   CGLayerItem::Invalidate();
  }
 //--- Candle x center and the pixel y of its high and low; false when the candle is not on the chart
 bool CCandleMarker::Geometry(int &x_center,int &y_high,int &y_low)
  {
   if(this.m_time==0)
      return false;
   int x_low=0;
   if(!::ChartTimePriceToXY(this.ChartID(),this.SubWindow(),this.m_time,this.m_high,x_center,y_high) ||
      !::ChartTimePriceToXY(this.ChartID(),this.SubWindow(),this.m_time,this.m_low,x_low,y_low))
      return false;
   int chart_w=(int)::ChartGetInteger(this.ChartID(),CHART_WIDTH_IN_PIXELS);
   return (x_center>=0 && x_center<=chart_w);
  }
 //--- Badge x, and the pixel edge it must stay clear of: the highest high (Sell) or the lowest low (Buy)
 //--- of every candle under the badge's width
 bool CCandleMarker::BaseGeometry(int &badge_x,int &edge_y)
  {
   int xc=0,y_high=0,y_low=0;
   if(!this.Geometry(xc,y_high,y_low))
      return false;
   badge_x=xc-CANDLE_MARKER_BADGE_W/2;
   edge_y =(this.m_is_buy ? y_low : y_high);
   string sym=::ChartSymbol(this.ChartID());
   ENUM_TIMEFRAMES tf=(ENUM_TIMEFRAMES)::ChartPeriod(this.ChartID());
   datetime t_left=0,t_right=0;
   double price=0.0;
   int sub=0;
   if(!::ChartXYToTimePrice(this.ChartID(),badge_x,y_high,sub,t_left,price) ||
      !::ChartXYToTimePrice(this.ChartID(),badge_x+CANDLE_MARKER_BADGE_W,y_high,sub,t_right,price))
      return true;
   int shift_left =::iBarShift(sym,tf,t_left,false);
   int shift_right=::iBarShift(sym,tf,t_right,false);
   if(shift_left<0 || shift_right<0 || shift_left<shift_right)
      return true;
   int count=shift_left-shift_right+1;
   int px=0,py=0;
   if(this.m_is_buy)
     {
      int i_lo=::iLowest(sym,tf,MODE_LOW,count,shift_right);
      if(i_lo>=0 && ::ChartTimePriceToXY(this.ChartID(),this.SubWindow(),::iTime(sym,tf,i_lo),::iLow(sym,tf,i_lo),px,py) && py>edge_y)
         edge_y=py;
     }
   else
     {
      int i_hi=::iHighest(sym,tf,MODE_HIGH,count,shift_right);
      if(i_hi>=0 && ::ChartTimePriceToXY(this.ChartID(),this.SubWindow(),::iTime(sym,tf,i_hi),::iHigh(sym,tf,i_hi),px,py) && py<edge_y)
         edge_y=py;
     }
   return true;
  }
 int CCandleMarker::BadgeY(const int edge_y,const int offset) const
  {
   return (this.m_is_buy ? edge_y+CANDLE_MARKER_GAP+offset : edge_y-CANDLE_MARKER_GAP-CANDLE_MARKER_BADGE_H-offset);
  }
 //--- The box follows the candle in pixels while the cursor is on the badge of its owner
 void CCandleMarker::PlaceBox(void)
  {
   if(m_rectangle_label_candle_box==NULL || m_candle_marker_box_owner!=::GetPointer(this))
      return;
   int xc=0,y_top=0,y_bottom=0;
   if(!this.Geometry(xc,y_top,y_bottom))
     {
      m_rectangle_label_candle_box.SetVisibleFlag(false,false);
      return;
     }
   int slot=(int)(1<<(int)::ChartGetInteger(this.ChartID(),CHART_SCALE));
   int w=(slot>4 ? slot-2 : slot);
   int h=y_bottom-y_top+2*CANDLE_MARKER_BOX_MARGIN;
   m_rectangle_label_candle_box.SetXDistance(xc-w/2);
   m_rectangle_label_candle_box.SetYDistance(y_top-CANDLE_MARKER_BOX_MARGIN);
   m_rectangle_label_candle_box.SetXSize(w);
   m_rectangle_label_candle_box.SetYSize(h<8 ? 8 : h);
   m_rectangle_label_candle_box.SetVisibleFlag(this.m_visible && (this.m_hover || this.m_highlight),false);
  }
 //--- Pale box in the marker color, shown only while the cursor is on the badge
 void CCandleMarker::PaintCandleBox(void)
  {
   if(m_rectangle_label_candle_box==NULL || m_candle_marker_box_owner!=::GetPointer(this))
      return;
   color bg=(color)::ChartGetInteger(this.ChartID(),CHART_COLOR_BACKGROUND);
   m_rectangle_label_candle_box.SetBGColor(CColors::MixColors(bg,this.m_colour,100/255.0));
   m_rectangle_label_candle_box.SetColor(this.m_colour);
  }
 void CCandleMarker::SetHover(const bool on)
  {
   this.m_hover=on;
   if(on)
      this.ShowBox();
   else if(!this.m_highlight)
      this.HideBox();
   this.PlaceBox();
  }
 //--- One marker = one marked candle, drawn as the icon of its source(s)
 void CCandleMarker::SetMarker(const datetime time,const double high,const double low,const bool is_buy,
                               const color colour,const int sources)
  {
   this.m_time  =time;
   this.m_high  =high;
   this.m_low   =low;
   this.m_is_buy=is_buy;
   this.m_colour=colour;
   this.m_sources=sources;
   this.m_offset=0;
   this.m_layout_hidden=false;
   this.m_on_chart=false;
   CGLayerItem::Invalidate();
  }
 void CCandleMarker::Show(void)
  {
   this.m_visible=true;
   CGLayerItem::Invalidate();
  }
 void CCandleMarker::Hide(void)
  {
   this.m_visible=false;
   this.m_hover=false;
   this.m_highlight=false;
   this.HideBox();
   CGLayerItem::Invalidate();
  }
 //--- Index in g_candle_marker_icon of the icon of the marker's source(s)
 int CCandleMarker::IconIndex(void) const
  {
   int kinds=((this.m_sources&CANDLE_MARKER_SOURCE_INDICATOR)!=0 ? 1 : 0)+((this.m_sources&CANDLE_MARKER_SOURCE_CANDLE)!=0 ? 1 : 0)+((this.m_sources&CANDLE_MARKER_SOURCE_SMC)!=0 ? 1 : 0);
   return (kinds>1                                    ? 3 :
           (this.m_sources&CANDLE_MARKER_SOURCE_INDICATOR)!=0 ? 0 :
           (this.m_sources&CANDLE_MARKER_SOURCE_CANDLE)!=0    ? 1 : 2);
  }
 //+------------------------------------------------------------------+
 //| The badge on the shared layer: colored square, frame, the icon   |
 //+------------------------------------------------------------------+
 void CCandleMarker::Paint(CCanvas *canvas)
  {
   if(!this.m_visible || !this.m_on_chart || this.m_layout_hidden)
      return;
   int x=this.m_badge_x,y=this.m_badge_y;
   if(x<0 || y<0 || x+CANDLE_MARKER_BADGE_W>canvas.Width() || y+CANDLE_MARKER_BADGE_H>canvas.Height())
      return;
   if(!g_candle_marker_icon_loaded)
     {
      g_candle_marker_icon[0].ReadImageData(IMAGE_RESOURCE_BMP16_INDICATOR_BMP);
      g_candle_marker_icon[1].ReadImageData(IMAGE_RESOURCE_BMP16_CANDLE_MARKER_CANDLE_PNG);
      g_candle_marker_icon[2].ReadImageData(IMAGE_RESOURCE_BMP16_CANDLE_MARKER_MONEY_PNG);
      g_candle_marker_icon[3].ReadImageData(IMAGE_RESOURCE_BMP16_CANDLE_MARKER_COMBINATION_PNG);
      g_candle_marker_icon_loaded=true;
     }
   color bg=(color)::ChartGetInteger(this.ChartID(),CHART_COLOR_BACKGROUND);
   color fill=CColors::MixColors(bg,this.m_colour,120/255.0);
   canvas.FillRectangle(x,y,x+CANDLE_MARKER_BADGE_W-1,y+CANDLE_MARKER_BADGE_H-1,::ColorToARGB(fill));
   canvas.Rectangle(x,y,x+CANDLE_MARKER_BADGE_W-1,y+CANDLE_MARKER_BADGE_H-1,::ColorToARGB(this.m_colour));
   int icon=this.IconIndex();
   int ix=x+(CANDLE_MARKER_BADGE_W-(int)g_candle_marker_icon[icon].Width())/2;
   int iy=y+(CANDLE_MARKER_BADGE_H-(int)g_candle_marker_icon[icon].Height())/2;
   for(uint ly=0,p=0; ly<g_candle_marker_icon[icon].Height(); ly++)
      for(uint lx=0; lx<g_candle_marker_icon[icon].Width(); lx++,p++)
        {
         uint pixel=g_candle_marker_icon[icon].Data(p);
         if((pixel>>24)==0)
            continue;
         uint background=::ColorToARGB(canvas.PixelGet(ix+lx,iy+ly));
         canvas.PixelSet(ix+lx,iy+ly,::ColorToARGB(CColors::BlendColors(background,pixel)));
        }
  }
 bool CCandleMarker::HitTest(const int x,const int y)
  {
   return (this.m_visible && this.m_on_chart && !this.m_layout_hidden &&
           x>=this.m_badge_x && x<this.m_badge_x+CANDLE_MARKER_BADGE_W &&
           y>=this.m_badge_y && y<this.m_badge_y+CANDLE_MARKER_BADGE_H);
  }
 //+------------------------------------------------------------------+
 //| Oldest candle first, every badge takes the lowest offset (0, one |
 //| badge height, two, ...) at which it does not touch an earlier    |
 //| badge of the same side; no room within CANDLE_MARKER_MAX_LANES   |
 //| and the badge is not drawn. Only the candles on the chart count  |
 //+------------------------------------------------------------------+
 void CCandleMarker::Arrange(CGBaseObj *parent)
  {
   if(parent==NULL)
      return;
   long chart=::ChartID();
   string sym=::ChartSymbol(chart);
   ENUM_TIMEFRAMES tf=(ENUM_TIMEFRAMES)::ChartPeriod(chart);
   int first=(int)::ChartGetInteger(chart,CHART_FIRST_VISIBLE_BAR);
   int visible=(int)::ChartGetInteger(chart,CHART_VISIBLE_BARS);
   datetime t_older=::iTime(sym,tf,first+CANDLE_MARKER_ARRANGE_MARGIN);
   datetime t_newer=::iTime(sym,tf,(first-visible+1-CANDLE_MARKER_ARRANGE_MARGIN)>0 ? first-visible+1-CANDLE_MARKER_ARRANGE_MARGIN : 0);
   CCandleMarker *list[];
   int n=0;
   for(int i=0; i<parent.ChildrenTotal(); i++)
     {
      CCandleMarker *m=dynamic_cast<CCandleMarker *>(parent.Child(i));
      if(m==NULL)
         continue;
      m.m_on_chart=false;
      if(!m.m_visible || m.m_time<t_older || m.m_time>t_newer)
         continue;
      ::ArrayResize(list,n+1);
      int k=n;
      while(k>0 && list[k-1].m_time>m.m_time)
        {
         list[k]=list[k-1];
         k--;
        }
      list[k]=m;
      n++;
     }
   int  px[],py[];
   bool pbuy[];
   int  placed=0;
   const int lane=CANDLE_MARKER_BADGE_H+CANDLE_MARKER_LANE_GAP;
   for(int i=0; i<n; i++)
     {
      CCandleMarker *m=list[i];
      int bx=0,edge=0;
      m.m_layout_hidden=false;
      if(!m.BaseGeometry(bx,edge))
        {
         m.m_offset=0;
         continue;
        }
      m.m_on_chart=true;
      int offset=0;
      for(int guard=0; guard<50; guard++)
        {
         int by=m.BadgeY(edge,offset);
         bool hit=false;
         for(int j=0; j<placed && !hit; j++)
           {
            if(pbuy[j]!=m.m_is_buy)
               continue;
            if(bx<px[j]+CANDLE_MARKER_BADGE_W && bx+CANDLE_MARKER_BADGE_W>px[j] && by<py[j]+lane && by+lane>py[j])
               hit=true;
           }
         if(!hit)
            break;
         offset+=lane;
        }
      m.m_offset=offset;
      if(offset>(CANDLE_MARKER_MAX_LANES-1)*lane)
        {
         m.m_layout_hidden=true;   // too many badges here: zoom in to see this one
         continue;
        }
      m.m_badge_x=bx;
      m.m_badge_y=m.BadgeY(edge,offset);
      ::ArrayResize(px,placed+1);
      ::ArrayResize(py,placed+1);
      ::ArrayResize(pbuy,placed+1);
      px[placed]=m.m_badge_x;
      py[placed]=m.m_badge_y;
      pbuy[placed]=m.m_is_buy;
      placed++;
     }
   if(m_candle_marker_box_owner!=NULL)
      m_candle_marker_box_owner.PlaceBox();
   else if(m_box_time!=0)
      CCandleMarker::PlaceBoxOnCandle(m_box_time);
   CGLayerItem::Invalidate();
  }
 //+------------------------------------------------------------------+
 //| Shift + the cursor on the badge: the box on the candle and the   |
 //| panel's information window; leaving takes both away              |
 //+------------------------------------------------------------------+
 void CCandleMarker::OnChartEvent(const int id,const long &lparam,const double &dparam,const string &sparam)
  {
   if(id!=CHARTEVENT_MOUSE_MOVE || !this.m_visible)
      return;
   //--- Only with Shift down, so passing the mouse over the badges does not pop windows up all day
   bool shift=((((int)::StringToInteger(sparam))&MOUSE_BUTT_KEY_STATE_SHIFT)!=0);
   bool inside=(shift && !this.m_covered && this.HitTest((int)lparam,(int)dparam));
   if(inside==this.m_hover)
      return;
   this.SetHover(inside);
   if(inside)
      ::EventChartCustom(this.ChartID(),ON_CANDLE_MARKER_ENTER,(long)this.m_time,(double)this.m_badge_y,"");
   else
      ::EventChartCustom(this.ChartID(),ON_CANDLE_MARKER_LEAVE,(long)this.m_time,0,"");
   ::ChartRedraw(this.ChartID());
  }
#endif // CCANDLE_MARKER_COMPOSITE_IMPLEMENTATION
#endif // __CANDLEMARKER_COMPOSITE_MQH__
