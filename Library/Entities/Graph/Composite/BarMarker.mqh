//+------------------------------------------------------------------+
//|                                                 BarMarker.mqh    |
//+------------------------------------------------------------------+
#ifndef __BARMARKER_COMPOSITE_MQH__
#define __BARMARKER_COMPOSITE_MQH__
 #include "..\..\GBases\GLayerItem.mqh"
 #include "..\Standard\GStdRectangleLabelObj.mqh"
 #include "..\..\Defines\GUIDefines.mqh"
 #include "..\..\Defines\MouseDefines.mqh"
 #include "..\..\Defines\ImageDataDefine.mqh"
 #include "..\Properties\Colors.mqh"
 #include "..\Properties\Image.mqh"
 #include "..\..\..\Collections\Settings\SymbolTFManager.mqh"
 #include "..\..\..\Collections\Settings\BarInformationManager.mqh"
 #include "..\..\..\Collections\Settings\IndicatorTemplateManager.mqh"
 #include "..\..\..\Collections\Settings\StrategyManager.mqh"
 #include "..\..\Chart\ChartObj.mqh"
 #define BAR_MARKER_GAP        4      // gap between the candles and the badge
 #define BAR_MARKER_BADGE_W    20     // badge width: the icon and a frame
 #define BAR_MARKER_BADGE_H    20     // badge height
 #define BAR_MARKER_LANE_GAP   2      // gap between stacked badges
 #define BAR_MARKER_MAX_LANES  3      // badges that would need a higher stack are not drawn
 #define BAR_MARKER_BOX_MARGIN 2      // box around the candle: pixels above the high and below the low
 #define BAR_MARKER_ICONS      5      // found by CSignalsCollection, by CBarTimeSeriesCollection, by both, the entry of a strategy, its exit (CStrategyCollection)
 #define BAR_MARKER_ARRANGE_MARGIN 3  // bars outside the visible ones that still take part in Arrange()
 #ifndef BAR_MARKER_BUY_COLOR
  #define BAR_MARKER_BUY_COLOR  (clrDodgerBlue)   // the EA may define it before the library (EA Configuration.mqh)
 #endif
 #ifndef BAR_MARKER_SELL_COLOR
  #define BAR_MARKER_SELL_COLOR (clrRed)
 #endif
#ifndef CBARMARKER_COMPOSITE_DECLARATION
#define CBARMARKER_COMPOSITE_DECLARATION 
 class CBarMarker : public CGLayerItem
  {
   private:
     static CGStdRectangleLabelObj *m_rectangle_label_candle_box;   //CBarMarker owns: the one box on the candle, shared by all markers, created on first use, deleted by ReleaseBox
     static CBarMarker             *m_bar_marker_box_owner;         //Not owned: the CBarMarker the box is on now (cursor on its badge, or Highlighted by the panel)
     static datetime               m_box_time;                      // open time of the candle the box is on while NO marker owns it (a candle without a visible marker), 0 = none
     datetime                      m_time;                          // open time of the marked candle
     double                        m_high;
     double                        m_low;
     long                          m_types[];                 // the sources of the badge: the types of information (CBarTimeSeriesCollection) found on the candle and side
     long                          m_ind_types[];             // and the indicator templates (CSignalsCollection): type and params
     string                        m_ind_params[];
     long                          m_strategies[];            // and the strategies that enter on the candle and side (CStrategyCollection): strategy_id
     long                          m_strategy_exits[];        // and the ones that exit there: the side is the one they close
     bool                         m_is_buy;                 // Buy: blue badge below the candles, Sell: red badge above them
     int                          m_offset;                  // pixels further out, set by Arrange() to clear the other badges
     bool                         m_layout_hidden;           // Arrange() found no room within the allowed stack
     bool                         m_on_chart;                // Arrange() found the candle on the chart: m_badge_x/y are valid
     int                          m_badge_x;                 // badge position in chart pixels, set by Arrange()
     int                          m_badge_y;
     bool                         m_hover;                   // the cursor is on the badge (Shift down)
     bool                         m_highlight;               // the panel asked for the box (Shift + hover on the candle), the cursor is not on the badge
     bool                         m_covered;
     int                          m_icon;                    // Arrange() found it: the index in g_bar_marker_icon of the sources shown (0 signals, 1 series, 2 both, 3 a strategy enters, 4 it exits)
    //Private method                // a panel window is under the cursor
     bool                      Geometry(int &x_center,int &y_high,int &y_low);
     bool                      BaseGeometry(int &badge_x,int &edge_y,const string sym,const ENUM_TIMEFRAMES tf,const int ref_shift,const int ref_x,const int ref_y,const int scale,const int width,const int height,const double price_max,const double price_min);
     int                       BadgeY(const int edge_y,const int offset,const int height) const;
     int                       IconIndex(void);
   //--- What the badge shows: the side of the chart pair is shown (side_shown) and a source of the badge shows its side, asked to its manager
   //--- (signals: the template in CIndicatorTemplateManager, series: the type in CBarInformationManager, strategy: its show_on_chart in CStrategyManager)
     bool                      Shown(const bool side_shown,CBarInformationManager *information,CIndicatorTemplateManager *templates,CStrategyManager *strategies,
                                     bool &signals,bool &series,bool &strategy,bool &strategy_exit);
     void                      PlaceBox(void);
     void                      SetHover(const bool on);
     void                      PaintCandleBox(void);
     bool                      ShowBox(void);
     static bool               EnsureBox(const long chart_id,const int subwin);
     static void               PlaceBoxOnCandle(const datetime time);
     void                      HideBox(void);
   public:
     bool                      Create(const long chart_id,const int subwin,const string name);
   //--- One marker = one candle and one side, its sources: the types of information, the indicator templates and the strategies that found it (CBarMarkerCollection gives them)
     void                      SetMarker(const datetime time,const double high,const double low,const bool is_buy,const long &types[],const long &ind_types[],const string &ind_params[],
                                         const long &strategies[],const long &strategy_exits[]);
     void                      Show(void);
     void                      Hide(void);
     color                     Colour(void)                   const { return (this.m_is_buy ? BAR_MARKER_BUY_COLOR : BAR_MARKER_SELL_COLOR); }   // the side says the colour
     virtual void              SetCovered(const bool covered)       { this.m_covered=covered;  }
     virtual void              OnChartEvent(const int id,const long &lparam,const double &dparam,const string &sparam);
     virtual void              Paint(CCanvas *canvas);
     virtual bool              HitTest(const int x,const int y);
   //--- Each marker decides what it shows (Shown), then the badges that would overlap are stacked, oldest candle first: call after markers were added or changed,
   //--- after a chart change and after a switch of what is shown changed. from_time: an event told the candles from it, the badges before it stay where they are
   //--- What the chart shows: CChartObj (the bars, the scale, the size and the prices of the main window). What is shown: the managers (the side of the pair
   //--- once a pass, the type and the template of each source by Shown)
     static void               Arrange(CGBaseObj *parent,CChartObj *chart,CSymbolTFManager *pairs,CBarInformationManager *information,CIndicatorTemplateManager *templates,
                                       CStrategyManager *strategies,const datetime from_time=0);
   //--- The box on a candle without the cursor on its badge (Shift + hover on the candle): the marker of that candle takes it
     static void               HighlightCandle(CGBaseObj *parent,const datetime time);
     static void               ClearHighlight(void);
   //--- Delete the shared box (the markers are being deleted, or the EA is leaving)
     static void               ReleaseBox(void);
                               CBarMarker(void);
                              ~CBarMarker(void);
  };
#endif // CBARMARKER_COMPOSITE_DECLARATION
#ifndef CBARMARKER_COMPOSITE_IMPLEMENTATION
#define CBARMARKER_COMPOSITE_IMPLEMENTATION
 CGStdRectangleLabelObj *CBarMarker::m_rectangle_label_candle_box=NULL;
 CBarMarker *CBarMarker::m_bar_marker_box_owner=NULL;
 datetime CBarMarker::m_box_time=0;
 //--- The badge icons, read once
 CImage g_bar_marker_icon[BAR_MARKER_ICONS];
 bool   g_bar_marker_icon_loaded=false;
 //CBarMarker::CBarMarker(void) : m_time(0),m_high(0),m_low(0),m_is_buy(true),m_from_signals(false),m_from_series(false),m_offset(0),
 CBarMarker::CBarMarker(void) : m_time(0),m_high(0),m_low(0),m_is_buy(true),m_offset(0),m_icon(1),
                                      m_layout_hidden(false),m_on_chart(false),m_badge_x(0),m_badge_y(0),m_hover(false),m_highlight(false),m_covered(false)
  {
  }
 //--- Born hidden; the candle box is native and shared (ShowBox)
 bool CBarMarker::Create(const long chart_id,const int subwin,const string name)
  {
   this.SetName(name);
   this.SetChartID(chart_id==0 ? ::ChartID() : chart_id);
   this.m_subwindow=subwin;
   this.m_visible=false;
   return true;
  }
 //--- The pale box on the candle: one for all markers, created when the cursor first comes onto any badge
 bool CBarMarker::EnsureBox(const long chart_id,const int subwin)
  {
   if(m_rectangle_label_candle_box!=NULL)
      return true;
   CGStdRectangleLabelObj *box=new CGStdRectangleLabelObj();
   if(box==NULL || !box.Create(chart_id,subwin,"BarMarker_Box"))
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
 bool CBarMarker::ShowBox(void)
  {
   if(!CBarMarker::EnsureBox(this.ChartID(),this.SubWindow()))
      return false;
   m_box_time=0;
   m_bar_marker_box_owner=::GetPointer(this);
   this.PaintCandleBox();
   return true;
  }
 void CBarMarker::HideBox(void)
  {
   if(m_rectangle_label_candle_box==NULL || m_bar_marker_box_owner!=::GetPointer(this))
      return;
   m_rectangle_label_candle_box.SetVisibleFlag(false,false);
   m_bar_marker_box_owner=NULL;
  }
 void CBarMarker::ReleaseBox(void)
  {
   delete m_rectangle_label_candle_box;
   m_rectangle_label_candle_box=NULL;
   m_bar_marker_box_owner=NULL;
   m_box_time=0;
  }
 //--- The box on a candle that has no visible marker: the same box, in a neutral color
 void CBarMarker::PlaceBoxOnCandle(const datetime time)
  {
   long chart_id=::ChartID();
   string sym=::ChartSymbol(chart_id);
   ENUM_TIMEFRAMES tf=(ENUM_TIMEFRAMES)::ChartPeriod(chart_id);
   int shift=::iBarShift(sym,tf,time,true);
   int xc=0,x_low=0,y_top=0,y_bottom=0;
   if(shift<0 || !CBarMarker::EnsureBox(chart_id,0))
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
   int h=y_bottom-y_top+2*BAR_MARKER_BOX_MARGIN;
   color bg=(color)::ChartGetInteger(chart_id,CHART_COLOR_BACKGROUND);
   m_rectangle_label_candle_box.SetBGColor(CColors::MixColors(bg,clrGray,100/255.0));
   m_rectangle_label_candle_box.SetColor(clrGray);
   m_rectangle_label_candle_box.SetXDistance(xc-w/2);
   m_rectangle_label_candle_box.SetYDistance(y_top-BAR_MARKER_BOX_MARGIN);
   m_rectangle_label_candle_box.SetXSize(w);
   m_rectangle_label_candle_box.SetYSize(h<8 ? 8 : h);
   m_rectangle_label_candle_box.SetVisibleFlag(true,false);
  }
 //--- The box goes to the marker of the candle, if the candle has one
 void CBarMarker::HighlightCandle(CGBaseObj *parent,const datetime time)
  {
   CBarMarker::ClearHighlight();
   if(parent==NULL)
      return;
   for(int i=0;i<parent.ChildrenTotal();i++)
     {
      CBarMarker *marker=dynamic_cast<CBarMarker *>(parent.Child(i));
      if(marker!=NULL && marker.m_time==time && marker.m_visible)
        {
         marker.m_highlight=true;
         marker.ShowBox();
         marker.PlaceBox();
         return;
        }
     }
   CBarMarker::PlaceBoxOnCandle(time);   // the candle has no visible marker: the box is still shown
  }
 void CBarMarker::ClearHighlight(void)
  {
   if(m_box_time!=0 && m_rectangle_label_candle_box!=NULL)
     {
      m_rectangle_label_candle_box.SetVisibleFlag(false,false);
      m_box_time=0;
     }
   if(m_bar_marker_box_owner==NULL)
      return;
   m_bar_marker_box_owner.m_highlight=false;
   if(!m_bar_marker_box_owner.m_hover)
      m_bar_marker_box_owner.HideBox();
   else
      m_bar_marker_box_owner.PlaceBox();
  }
 CBarMarker::~CBarMarker(void)
  {
   this.HideBox();
   CGLayerItem::Invalidate();
  }
 //--- Candle x center and the pixel y of its high and low; false when the candle is not on the chart
 bool CBarMarker::Geometry(int &x_center,int &y_high,int &y_low)
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
 //--- Badge x, and the pixel edge it must stay clear of: the highest high (Sell) or the lowest low (Buy) of every candle under the badge's width.
 //--- No chart query: x from the reference bar (a bar is 1 << scale pixels), y from the reference price (the price scale is linear)
 bool CBarMarker::BaseGeometry(int &badge_x,int &edge_y,const string sym,const ENUM_TIMEFRAMES tf,const int ref_shift,const int ref_x,const int ref_y,const int scale,const int width,const int height,const double price_max,const double price_min)
  {
   if(this.m_time==0 || height<=0 || price_max<=price_min)
      return false;
   const int shift=::iBarShift(sym,tf,this.m_time,false);
   if(shift<0)
      return false;
   const int xc=ref_x+(ref_shift-shift)*(1<<scale);
   if(xc<0 || xc>width)
      return false;
   const double pixels=height/(price_max-price_min);   // pixels of a price unit
   const int y_high=ref_y+(int)::MathRound((price_max-this.m_high)*pixels);
   badge_x=xc-BAR_MARKER_BADGE_W/2;
   edge_y=(this.m_is_buy ? y_high+(int)::MathRound((this.m_high-this.m_low)*pixels) : y_high);
   const int half=BAR_MARKER_BADGE_W/(2*(1<<scale))+1;   // the bars under half of the badge (a bar is 1 << scale pixels)
   const int right=(shift>half ? shift-half : 0);
   const int count=shift+half-right+1;
   if(this.m_is_buy)
     {
      int i_lo=::iLowest(sym,tf,MODE_LOW,count,right);
      int py=(i_lo>=0 ? y_high+(int)::MathRound((this.m_high-::iLow(sym,tf,i_lo))*pixels) : edge_y);
      if(py>edge_y)
         edge_y=py;
     }
   else
     {
      int i_hi=::iHighest(sym,tf,MODE_HIGH,count,right);
      int py=(i_hi>=0 ? y_high+(int)::MathRound((this.m_high-::iHigh(sym,tf,i_hi))*pixels) : edge_y);
      if(py<edge_y)
         edge_y=py;
     }
   return true;
  }
 int CBarMarker::BadgeY(const int edge_y,const int offset,const int height) const
  {
   //--- A candle close to the edge of the chart: the badge stays inside, over the candle (Paint does not draw outside)
   if(this.m_is_buy)
     {
      int last=height-BAR_MARKER_BADGE_H;
      int below=edge_y+BAR_MARKER_GAP+offset;
      return (below>last && edge_y<=last+BAR_MARKER_BADGE_H ? last-offset : below);
     }
   int above=edge_y-BAR_MARKER_GAP-BAR_MARKER_BADGE_H-offset;
   return (above<0 && edge_y>=0 ? offset : above);
  }
 //--- The box follows the candle in pixels while the cursor is on the badge of its owner
 void CBarMarker::PlaceBox(void)
  {
   if(m_rectangle_label_candle_box==NULL || m_bar_marker_box_owner!=::GetPointer(this))
      return;
   int xc=0,y_top=0,y_bottom=0;
   if(!this.Geometry(xc,y_top,y_bottom))
     {
      m_rectangle_label_candle_box.SetVisibleFlag(false,false);
      return;
     }
   int slot=(int)(1<<(int)::ChartGetInteger(this.ChartID(),CHART_SCALE));
   int w=(slot>4 ? slot-2 : slot);
   int h=y_bottom-y_top+2*BAR_MARKER_BOX_MARGIN;
   m_rectangle_label_candle_box.SetXDistance(xc-w/2);
   m_rectangle_label_candle_box.SetYDistance(y_top-BAR_MARKER_BOX_MARGIN);
   m_rectangle_label_candle_box.SetXSize(w);
   m_rectangle_label_candle_box.SetYSize(h<8 ? 8 : h);
   m_rectangle_label_candle_box.SetVisibleFlag(this.m_visible && (this.m_hover || this.m_highlight),false);
  }
 //--- Pale box in the marker color, shown only while the cursor is on the badge
 void CBarMarker::PaintCandleBox(void)
  {
   if(m_rectangle_label_candle_box==NULL || m_bar_marker_box_owner!=::GetPointer(this))
      return;
   color bg=(color)::ChartGetInteger(this.ChartID(),CHART_COLOR_BACKGROUND);
   m_rectangle_label_candle_box.SetBGColor(CColors::MixColors(bg,this.Colour(),100/255.0));
   m_rectangle_label_candle_box.SetColor(this.Colour());
  }
 void CBarMarker::SetHover(const bool on)
  {
   this.m_hover=on;
   if(on)
      this.ShowBox();
   else if(!this.m_highlight)
      this.HideBox();
   this.PlaceBox();
  }
 //--- One marker = one marked candle and one side: the colour says the side, the icon the collection(s) that found it
 void CBarMarker::SetMarker(const datetime time,const double high,const double low,const bool is_buy,const long &types[],const long &ind_types[],const string &ind_params[],
                            const long &strategies[],const long &strategy_exits[])
  {
   this.m_time  =time;
   this.m_high  =high;
   this.m_low   =low;
   this.m_is_buy=is_buy;
   ::ArrayCopy(this.m_types,types);
   ::ArrayCopy(this.m_ind_types,ind_types);
   ::ArrayCopy(this.m_ind_params,ind_params);
   ::ArrayCopy(this.m_strategies,strategies);
   ::ArrayCopy(this.m_strategy_exits,strategy_exits);
   ::ArrayResize(this.m_types,::ArraySize(types));   // ArrayCopy keeps the size of a longer array
   ::ArrayResize(this.m_ind_types,::ArraySize(ind_types));
   ::ArrayResize(this.m_ind_params,::ArraySize(ind_params));
   ::ArrayResize(this.m_strategies,::ArraySize(strategies));
   ::ArrayResize(this.m_strategy_exits,::ArraySize(strategy_exits));
   this.m_offset=0;
   this.m_layout_hidden=false;
   this.m_on_chart=false;
   CGLayerItem::Invalidate();
  }
 void CBarMarker::Show(void)
  {
   this.m_visible=true;
   CGLayerItem::Invalidate();
  }
 void CBarMarker::Hide(void)
  {
   this.m_visible=false;
   this.m_hover=false;
   this.m_highlight=false;
   this.HideBox();
   CGLayerItem::Invalidate();
  }
 //--- Index in g_bar_marker_icon of the icon of the marker: 0 the signals of the indicators, 1 the bar time series, 2 both
 int CBarMarker::IconIndex(void)
  {
   return this.m_icon;   // set by Arrange: Paint asks no manager
  }
 //--- The managers say it: the side of the chart pair (Setting_SymbolTF), the type (Setting_BarInformation) or the template (Setting_IndicatorTemplate) shows the side
 bool CBarMarker::Shown(const bool side_shown,CBarInformationManager *information,CIndicatorTemplateManager *templates,CStrategyManager *strategies,
                        bool &signals,bool &series,bool &strategy,bool &strategy_exit)
  {
   signals=false;
   series=false;
   strategy=false;
   strategy_exit=false;
   if(!side_shown)
      return false;
   for(int i=0;i<::ArraySize(this.m_strategies) && !strategy && strategies!=NULL;i++)
     {
      CStrategySetting *setting=strategies.Read_RAM(this.m_strategies[i]);
      strategy=(setting!=NULL && setting.ShowOnChart());
     }
   for(int i=0;i<::ArraySize(this.m_strategy_exits) && !strategy_exit && strategies!=NULL;i++)
     {
      CStrategySetting *setting=strategies.Read_RAM(this.m_strategy_exits[i]);
      strategy_exit=(setting!=NULL && setting.ShowOnChart());
     }
   for(int i=0;i<::ArraySize(this.m_types) && !series;i++)
     {
      CBarInformationSetting *type=information.Read_RAM((ENUM_BAR_INFOR_TYPE)this.m_types[i]);
      if(type==NULL)
         continue;
      if(this.m_is_buy)
         series=(type.HasBuy() && type.ShowBuy());
      else
         series=(type.HasSell() && type.ShowSell());
     }
   for(int i=0;i<::ArraySize(this.m_ind_types) && !signals;i++)
     {
      CIndicatorSetting *setting=templates.Read_RAM((ENUM_INDICATOR)this.m_ind_types[i],this.m_ind_params[i]);
      if(setting==NULL)
         continue;
      if(this.m_is_buy)
         signals=setting.BuySignal();
      else
         signals=setting.SellSignal();
     }
   return (signals || series || strategy || strategy_exit);
  }
 //+------------------------------------------------------------------+
 //| The badge on the shared layer: colored square, frame, the icon   |
 //+------------------------------------------------------------------+
 void CBarMarker::Paint(CCanvas *canvas)
  {
   if(!this.m_visible || !this.m_on_chart || this.m_layout_hidden)
      return;
   int x=this.m_badge_x,y=this.m_badge_y;
   if(x<0 || y<0 || x+BAR_MARKER_BADGE_W>canvas.Width() || y+BAR_MARKER_BADGE_H>canvas.Height())
      return;
   if(!g_bar_marker_icon_loaded)
     {
      g_bar_marker_icon[0].ReadImageData(IMAGE_RESOURCE_BMP16_INDICATOR_BMP);
      g_bar_marker_icon[1].ReadImageData(IMAGE_RESOURCE_BMP16_CANDLE_MARKER_CANDLE_PNG);
      g_bar_marker_icon[2].ReadImageData(IMAGE_RESOURCE_BMP16_CANDLE_MARKER_COMBINATION_PNG);
      g_bar_marker_icon[3].ReadImageData(IMAGE_RESOURCE_BMP16_TRADE_ON_PNG);
      g_bar_marker_icon[4].ReadImageData(IMAGE_RESOURCE_BMP16_TRADING_OFF_PNG);
      g_bar_marker_icon_loaded=true;
     }
   canvas.FillRectangle(x,y,x+BAR_MARKER_BADGE_W-1,y+BAR_MARKER_BADGE_H-1,::ColorToARGB(this.Colour(),120));   // the layer is ARGB: the chart shows through
   canvas.Rectangle(x,y,x+BAR_MARKER_BADGE_W-1,y+BAR_MARKER_BADGE_H-1,::ColorToARGB(this.Colour()));
   int icon=this.IconIndex();
   int ix=x+(BAR_MARKER_BADGE_W-(int)g_bar_marker_icon[icon].Width())/2;
   int iy=y+(BAR_MARKER_BADGE_H-(int)g_bar_marker_icon[icon].Height())/2;
   for(uint ly=0,p=0; ly<g_bar_marker_icon[icon].Height(); ly++)
      for(uint lx=0; lx<g_bar_marker_icon[icon].Width(); lx++,p++)
        {
         uint pixel=g_bar_marker_icon[icon].Data(p);
         if((pixel>>24)==0)
            continue;
         uint background=::ColorToARGB(canvas.PixelGet(ix+lx,iy+ly));
         canvas.PixelSet(ix+lx,iy+ly,::ColorToARGB(CColors::BlendColors(background,pixel)));
        }
  }
 bool CBarMarker::HitTest(const int x,const int y)
  {
   return (this.m_visible && this.m_on_chart && !this.m_layout_hidden &&
           x>=this.m_badge_x && x<this.m_badge_x+BAR_MARKER_BADGE_W &&
           y>=this.m_badge_y && y<this.m_badge_y+BAR_MARKER_BADGE_H);
  }
 //+------------------------------------------------------------------+
 //| Oldest candle first, every badge takes the lowest offset (0, one |
 //| badge height, two, ...) at which it does not touch an earlier    |
 //| badge of the same side; no room within BAR_MARKER_MAX_LANES   |
 //| and the badge is not drawn. Only the candles on the chart count  |
 //+------------------------------------------------------------------+
 void CBarMarker::Arrange(CGBaseObj *parent,CChartObj *chart,CSymbolTFManager *pairs,CBarInformationManager *information,CIndicatorTemplateManager *templates,
                          CStrategyManager *strategies,const datetime from_time=0)
  {
   if(parent==NULL || chart==NULL || pairs==NULL || information==NULL || templates==NULL)
      return;
   const ulong debug_t0=::GetMicrosecondCount();
   const long chart_id=chart.ID();
   const string sym=chart.Symbol();
   const ENUM_TIMEFRAMES tf=chart.Timeframe();
   const int first_visible_bar=chart.FirstVisibleBars();
   const int visible_bars=chart.VisibleBars();
   const int scale=chart.Scale();
   const int width=chart.WidthInPixels();
   const int height=chart.HeightInPixels();
   const double price_max=chart.PriceMax();
   const double price_min=chart.PriceMin();
   const int newest=first_visible_bar-visible_bars+1-BAR_MARKER_ARRANGE_MARGIN;
   datetime t_older=::iTime(sym,tf,first_visible_bar+BAR_MARKER_ARRANGE_MARGIN);
   datetime t_newer=::iTime(sym,tf,newest>0 ? newest : 0);
   const ulong debug_t1=::GetMicrosecondCount();
   //--- One chart query a pass: the first visible bar at the top price, every badge is placed from it
   int ref_x=0,ref_y=0;
   const datetime ref_time=::iTime(sym,tf,first_visible_bar);
   if(ref_time==0 || !::ChartTimePriceToXY(chart_id,0,ref_time,price_max,ref_x,ref_y))
      return;   // the chart has not this bar yet
   const ulong debug_t2=::GetMicrosecondCount();
   int debug_shown=0,debug_hidden=0;
   CBarMarker *list[];
   int n=0;
   int  px[],py[];
   bool pbuy[];
   int  placed=0;
   //--- The sides of the chart pair, read once a pass: the sources of each marker are asked to their managers by Shown
   const bool pair_buy=pairs.Read_RAM(sym,tf,"buy_signal");
   const bool pair_sell=pairs.Read_RAM(sym,tf,"sell_signal");
   long order[];   // the markers to place, by the time of the candle: time * the children + the index in list
   const long children=parent.ChildrenTotal()+1;
   for(int i=0; i<parent.ChildrenTotal(); i++)
     {
      CBarMarker *m=dynamic_cast<CBarMarker *>(parent.Child(i));
      if(m==NULL)
         continue;
      //--- Before the candles an event told: the badge stays where it is, the new ones keep clear of it
      if(from_time>0 && m.m_time<from_time)
        {
         if(m.m_visible && m.m_on_chart && !m.m_layout_hidden)
           {
            ::ArrayResize(px,placed+1,64);
            ::ArrayResize(py,placed+1,64);
            ::ArrayResize(pbuy,placed+1,64);
            px[placed]=m.m_badge_x;
            py[placed]=m.m_badge_y;
            pbuy[placed]=m.m_is_buy;
            placed++;
           }
         continue;
        }
      m.m_on_chart=false;
      bool signals=false,series=false,strategy=false,strategy_exit=false;
      bool shown=false;   // the view decides: a switch of what is shown changes only this
      if(m.m_is_buy)
         shown=m.Shown(pair_buy,information,templates,strategies,signals,series,strategy,strategy_exit);
      else
         shown=m.Shown(pair_sell,information,templates,strategies,signals,series,strategy,strategy_exit);
      m.m_icon=1;
      if(strategy)
         m.m_icon=3;   // the entry of a strategy first: it is what trades
      else if(strategy_exit)
         m.m_icon=4;
      else if(signals && series)
         m.m_icon=2;
      else if(signals)
         m.m_icon=0;
      if(shown && !m.m_visible)
        {
         m.Show();
         debug_shown++;
        }
      else if(!shown && m.m_visible)
        {
         m.Hide();
         debug_hidden++;
        }
      if(!m.m_visible || m.m_time<t_older || m.m_time>t_newer)
         continue;
      ::ArrayResize(list,n+1,256);
      ::ArrayResize(order,n+1,256);
      list[n]=m;
      order[n]=(long)m.m_time*children+n;
      n++;
     }
   ::ArraySort(order);
   const ulong debug_t3=::GetMicrosecondCount();
   CBarMarker *sorted[];   // oldest candle first: the badges are placed from the left
   ::ArrayResize(sorted,n);
   for(int i=0; i<n; i++)
      sorted[i]=list[(int)(order[i]%children)];
   const int fixed=placed;   // the badges before from_time: not in the order of x
   const int lane=BAR_MARKER_BADGE_H+BAR_MARKER_LANE_GAP;
   for(int i=0; i<n; i++)
     {
      CBarMarker *m=sorted[i];
      int bx=0,edge=0;
      m.m_layout_hidden=false;
      if(!m.BaseGeometry(bx,edge,sym,tf,first_visible_bar,ref_x,ref_y,scale,width,height,price_max,price_min))
        {
         m.m_offset=0;
         continue;
        }
      m.m_on_chart=true;
      int offset=0;
      for(int guard=0; guard<BAR_MARKER_MAX_LANES; guard++)   // past the lanes it may take the badge is not drawn: no more tries
        {
         int by=m.BadgeY(edge,offset,height);
         bool hit=false;
         //--- The badges placed in this pass go from the left: only the last ones can reach this x
         for(int j=placed-1; j>=fixed && !hit; j--)
           {
            if(px[j]+BAR_MARKER_BADGE_W<=bx)
               break;
            if(pbuy[j]==m.m_is_buy && bx+BAR_MARKER_BADGE_W>px[j] && by<py[j]+lane && by+lane>py[j])
               hit=true;
           }
         for(int j=0; j<fixed && !hit; j++)
           {
            if(pbuy[j]!=m.m_is_buy)
               continue;
            if(bx<px[j]+BAR_MARKER_BADGE_W && bx+BAR_MARKER_BADGE_W>px[j] && by<py[j]+lane && by+lane>py[j])
               hit=true;
           }
         if(!hit)
            break;
         offset+=lane;
        }
      m.m_offset=offset;
      if(offset>(BAR_MARKER_MAX_LANES-1)*lane)
        {
         m.m_layout_hidden=true;   // too many badges here: zoom in to see this one
         continue;
        }
      m.m_badge_x=bx;
      m.m_badge_y=m.BadgeY(edge,offset,height);
      ::ArrayResize(px,placed+1,256);
      ::ArrayResize(py,placed+1,256);
      ::ArrayResize(pbuy,placed+1,256);
      px[placed]=m.m_badge_x;
      py[placed]=m.m_badge_y;
      pbuy[placed]=m.m_is_buy;
      placed++;
     }
   const ulong debug_t4=::GetMicrosecondCount();
   if(m_bar_marker_box_owner!=NULL)
      m_bar_marker_box_owner.PlaceBox();
   else if(m_box_time!=0)
      CBarMarker::PlaceBoxOnCandle(m_box_time);
   CGLayerItem::Invalidate();
   const ulong debug_t5=::GetMicrosecondCount();
   string debug_from="every candle";
   if(from_time>0)
      debug_from="from "+::TimeToString(from_time);
   string debug_text="MY DEBUG CBarMarker::Arrange "+sym+" "+::EnumToString(tf)+" "+debug_from+": "+(string)(parent.ChildrenTotal())+" children, "+(string)fixed+
                     " kept before, "+(string)n+" placed of the view ("+(string)debug_shown+" shown, "+(string)debug_hidden+" hidden). chart getters "+
                     (string)((debug_t1-debug_t0)/1000)+" ms, ChartTimePriceToXY "+(string)((debug_t2-debug_t1)/1000)+" ms, sources "+(string)((debug_t3-debug_t2)/1000)+
                     " ms, place "+(string)((debug_t4-debug_t3)/1000)+" ms, box "+(string)((debug_t5-debug_t4)/1000)+" ms";
   ::Print(debug_text);
  }
 //+------------------------------------------------------------------+
 //| Shift + the cursor on the badge: the box on the candle and the   |
 //| panel's information window; leaving takes both away              |
 //+------------------------------------------------------------------+
 void CBarMarker::OnChartEvent(const int id,const long &lparam,const double &dparam,const string &sparam)
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
      ::EventChartCustom(this.ChartID(),BAR_MARKER_EVENT_ENTER,(long)this.m_time,(double)this.m_badge_y,"");
   else
      ::EventChartCustom(this.ChartID(),BAR_MARKER_EVENT_LEAVE,(long)this.m_time,0,"");
   ::ChartRedraw(this.ChartID());
  }
#endif // CBARMARKER_COMPOSITE_IMPLEMENTATION
#endif // __BARMARKER_COMPOSITE_MQH__
