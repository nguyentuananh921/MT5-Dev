//+------------------------------------------------------------------+
//|                                                 CandleMarker.mqh |
//+------------------------------------------------------------------+
#ifndef __CANDLEMARKER_COMPOSITE_MQH__
#define __CANDLEMARKER_COMPOSITE_MQH__
 #include "..\..\GBases\GBaseObj.mqh"
 #include "..\..\GBases\GElement.mqh"
 #include "..\..\Controls\Button.mqh"
 #include "..\Standard\GStdRectangleLabelObj.mqh"
 #include "..\..\Defines\ImageDataDefine.mqh"
 #include "..\..\..\Services\Colors.mqh"
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
#ifndef CCANDLE_MARKER_COMPOSITE_DECLARATION
#define CCANDLE_MARKER_COMPOSITE_DECLARATION
 //+------------------------------------------------------------------+
 //| Badge (source icon on a colored square) put above a Sell candle  |
 //| or below a Buy candle, clear of every candle under its width.    |
 //| Badges of the same side that would overlap are stacked outward by|
 //| Arrange(). Shift + the cursor on the badge draws a box on the    |
 //| marked candle and tells the panel to show the candle's           |
 //| information window (ON_CANDLE_MARKER_ENTER / _LEAVE)             |
 //+------------------------------------------------------------------+
 class CCandleMarker : public CGBaseObj
  {
   private:
     CGStdRectangleLabelObj    m_rectanglelabel_candle;   // the box on the candle, only while the cursor is on the badge
     CButton                   m_button_badge;           // icon on a colored square, no text, never pressed
     datetime                  m_time;                    // open time of the marked candle
     double                    m_high;
     double                    m_low;
     bool                      m_is_buy;                  // Buy: blue badge below the candles, Sell: red badge above them
     color                     m_colour;
     int                       m_sources;                 // ENUM_CANDLE_MARKER_SOURCE flags the badge shows
     int                       m_offset;                  // pixels further out, set by Arrange() to clear the other badges
     bool                      m_layout_hidden;           // Arrange() found no room within the allowed stack
     bool                      m_hover;
     bool                      m_covered;                 // a panel window is under the cursor
     static bool               s_raise_pending;           // a badge was shown since the panel windows were last raised
     bool                      Geometry(int &x_center,int &y_high,int &y_low);
     bool                      BaseGeometry(int &badge_x,int &edge_y);
     int                       BadgeY(const int edge_y,const int offset) const;
     void                      Reposition(void);
     void                      SetHover(const bool on);
     void                      PaintCandleBox(void);
   public:
     bool                      Create(const long chart_id,const int subwin,const string name);
     void                      SetMarker(const datetime time,const double high,const double low,const bool is_buy,
                                         const color colour,const int sources);
     void                      Show(void);
     void                      Hide(void);
     int                       Sources(void)                  const { return this.m_sources;   }
     virtual void              SetCovered(const bool covered)       { this.m_covered=covered;  }
     virtual void              OnChartEvent(const int id,const long &lparam,const double &dparam,const string &sparam);
   //--- A badge shown again lands on top of the panel windows: true once, the caller raises the windows (no event queue in between)
     static bool               ConsumeRaiseRequest(void);
   //--- Stack the badges that would overlap, oldest candle first: call after markers were added or changed and after a chart change
     static void               Arrange(CGBaseObj *parent);
                               CCandleMarker(void);
  };
#endif // CCANDLE_MARKER_COMPOSITE_DECLARATION
#ifndef CCANDLE_MARKER_COMPOSITE_IMPLEMENTATION
#define CCANDLE_MARKER_COMPOSITE_IMPLEMENTATION
 bool CCandleMarker::s_raise_pending=false;
 CCandleMarker::CCandleMarker(void) : m_time(0),m_high(0),m_low(0),m_is_buy(true),m_colour(clrDodgerBlue),m_sources(0),m_offset(0),
                                      m_layout_hidden(false),m_hover(false),m_covered(false)
  {
  }
 //--- Born hidden; the badge is a control, the candle box is native
 bool CCandleMarker::Create(const long chart_id,const int subwin,const string name)
  {
   if(!this.m_rectanglelabel_candle.Create(chart_id,subwin,name+"_box"))
      return false;
   this.SetName(name);
   this.SetChartID(this.m_rectanglelabel_candle.ChartID());
   this.m_subwindow=this.m_rectanglelabel_candle.SubWindow();
   this.m_visible=false;
   this.m_rectanglelabel_candle.SetFlagBack(true,false);
   this.m_rectanglelabel_candle.SetFlagSelectable(false,false);
   this.m_rectanglelabel_candle.SetTooltip("\n");
   this.m_rectanglelabel_candle.SetBorderType(BORDER_FLAT);
   this.m_rectanglelabel_candle.SetVisibleFlag(false,false);
   if(!this.m_button_badge.Create(this.ChartID(),this.SubWindow(),name+"_badge",0,0,CANDLE_MARKER_BADGE_W,CANDLE_MARKER_BADGE_H))
      return false;
   this.m_button_badge.Hide();   // after Create: a created canvas is visible, Show() of the marker shows it
   this.m_button_badge.IsAvailable(false);
   this.AddChild(&this.m_rectanglelabel_candle);
   this.AddChild(&this.m_button_badge);
   return true;
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
 //--- Badge and (when hovered) the candle box follow the candle in pixels
 void CCandleMarker::Reposition(void)
  {
   int bx=0,edge=0;
   if(!this.BaseGeometry(bx,edge) || this.m_layout_hidden)
     {
      this.m_button_badge.Hide();
      this.m_rectanglelabel_candle.SetVisibleFlag(false,false);
      this.m_hover=false;
      return;
     }
   if(this.m_visible && !this.m_button_badge.IsVisible())
     {
      this.m_button_badge.Show();
      s_raise_pending=true;   // a shown badge lands on top of the panel windows: the EA raises them (ConsumeRaiseRequest)
     }
   this.m_button_badge.Move(bx,this.BadgeY(edge,this.m_offset));
   int xc=0,y_top=0,y_bottom=0;
   if(!this.Geometry(xc,y_top,y_bottom))
      return;
   int slot=(int)(1<<(int)::ChartGetInteger(this.ChartID(),CHART_SCALE));
   int w=(slot>4 ? slot-2 : slot);
   int h=y_bottom-y_top+2*CANDLE_MARKER_BOX_MARGIN;
   this.m_rectanglelabel_candle.SetXDistance(xc-w/2);
   this.m_rectanglelabel_candle.SetYDistance(y_top-CANDLE_MARKER_BOX_MARGIN);
   this.m_rectanglelabel_candle.SetXSize(w);
   this.m_rectanglelabel_candle.SetYSize(h<8 ? 8 : h);
   this.m_rectanglelabel_candle.SetVisibleFlag(this.m_visible && this.m_hover,false);
  }
 //--- Pale box in the marker color, shown only while the cursor is on the badge
 void CCandleMarker::PaintCandleBox(void)
  {
   color bg=(color)::ChartGetInteger(this.ChartID(),CHART_COLOR_BACKGROUND);
   this.m_rectanglelabel_candle.SetBGColor(CColors::MixColors(bg,this.m_colour,100/255.0));
   this.m_rectanglelabel_candle.SetColor(this.m_colour);
  }
 void CCandleMarker::SetHover(const bool on)
  {
   this.m_hover=on;
   this.PaintCandleBox();
   this.Reposition();
   this.m_rectanglelabel_candle.SetVisibleFlag(on,false);
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
   color bg=(color)::ChartGetInteger(this.ChartID(),CHART_COLOR_BACKGROUND);
   color fill=CColors::MixColors(bg,colour,120/255.0);
   this.m_button_badge.GetBackColorControl().InitColors(fill);
   this.m_button_badge.GetBackColorControl().SetCurrentAs(COLOR_STATE_DEFAULT);
   this.m_button_badge.GetBorderColorControl().InitColors(colour);
   this.m_button_badge.GetBorderColorControl().SetCurrentAs(COLOR_STATE_DEFAULT);
   int kinds=((sources&CANDLE_MARKER_SOURCE_INDICATOR)!=0 ? 1 : 0)+((sources&CANDLE_MARKER_SOURCE_CANDLE)!=0 ? 1 : 0)+((sources&CANDLE_MARKER_SOURCE_SMC)!=0 ? 1 : 0);
   this.m_button_badge.IconFile(kinds>1                                      ? IMAGE_RESOURCE_BMP16_CANDLE_MARKER_COMBINATION_PNG :
                                 (sources&CANDLE_MARKER_SOURCE_INDICATOR)!=0   ? IMAGE_RESOURCE_BMP16_INDICATOR_BMP                 :
                                 (sources&CANDLE_MARKER_SOURCE_CANDLE)!=0      ? IMAGE_RESOURCE_BMP16_CANDLE_MARKER_CANDLE_PNG      :
                                                                                 IMAGE_RESOURCE_BMP16_CANDLE_MARKER_MONEY_PNG);
   this.m_button_badge.Draw(false);
   this.PaintCandleBox();
   this.Reposition();
  }
 void CCandleMarker::Show(void)
  {
   this.m_visible=true;
   this.m_button_badge.Show();
   this.Reposition();
  }
 void CCandleMarker::Hide(void)
  {
   this.m_visible=false;
   this.m_hover=false;
   this.m_rectanglelabel_candle.SetVisibleFlag(false,false);
   this.m_button_badge.Hide();
  }
 //+------------------------------------------------------------------+
 //| Oldest candle first, every badge takes the lowest offset (0, one |
 //| badge height, two, ...) at which it does not touch an earlier    |
 //| badge of the same side; no room within CANDLE_MARKER_MAX_LANES   |
 //| and the badge is not drawn                                       |
 //+------------------------------------------------------------------+
 void CCandleMarker::Arrange(CGBaseObj *parent)
  {
   if(parent==NULL)
      return;
   CCandleMarker *list[];
   int n=0;
   for(int i=0; i<parent.ChildrenTotal(); i++)
     {
      CCandleMarker *m=dynamic_cast<CCandleMarker *>(parent.Child(i));
      if(m==NULL || !m.m_visible)
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
         m.Reposition();
         continue;
        }
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
         m.Reposition();
         continue;
        }
      ::ArrayResize(px,placed+1);
      ::ArrayResize(py,placed+1);
      ::ArrayResize(pbuy,placed+1);
      px[placed]=bx;
      py[placed]=m.BadgeY(edge,offset);
      pbuy[placed]=m.m_is_buy;
      placed++;
      m.Reposition();
     }
  }
 //--- Shift + the cursor on the badge shows the box and asks for the window. The badge and the box need no event of their own
 //--- (the badge is locked, the hit test uses the event coordinates) and a chart change is handled by Arrange()
 void CCandleMarker::OnChartEvent(const int id,const long &lparam,const double &dparam,const string &sparam)
  {
   if(id!=CHARTEVENT_MOUSE_MOVE || !this.m_visible)
      return;
   //--- Only with Shift down, so passing the mouse over the badges does not pop windows up all day
   bool shift=((((int)::StringToInteger(sparam))&MOUSE_BUTT_KEY_STATE_SHIFT)!=0);
   bool inside=(shift && this.m_button_badge.IsVisible() && !this.m_covered && this.m_button_badge.CursorInsideElement((int)lparam,(int)dparam));
   if(inside==this.m_hover)
      return;
   this.SetHover(inside);
   if(inside)
      ::EventChartCustom(this.ChartID(),ON_CANDLE_MARKER_ENTER,(long)this.m_time,(double)this.m_button_badge.Y(),"");
   else
      ::EventChartCustom(this.ChartID(),ON_CANDLE_MARKER_LEAVE,(long)this.m_time,0,"");
   ::ChartRedraw(this.ChartID());
  }
 //--- True once after a badge was shown: the caller puts the panel windows back on top
 bool CCandleMarker::ConsumeRaiseRequest(void)
  {
   bool pending=s_raise_pending;
   s_raise_pending=false;
   return pending;
  }
#endif // CCANDLE_MARKER_COMPOSITE_IMPLEMENTATION
#endif // __CANDLEMARKER_COMPOSITE_MQH__
