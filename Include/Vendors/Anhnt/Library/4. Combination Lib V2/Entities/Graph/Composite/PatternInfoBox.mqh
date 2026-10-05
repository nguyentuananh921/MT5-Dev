//+------------------------------------------------------------------+
//|                                               PatternInfoBox.mqh |
//+------------------------------------------------------------------+
#ifndef __PATTERNINFOBOX_MQH__
#define __PATTERNINFOBOX_MQH__
 #include "..\..\GBases\GBaseObj.mqh"
 #include "..\Standard\GStdRectangleLabelObj.mqh"
 #include "..\..\Controls\Tooltip.mqh"
 #include "..\..\Defines\TimeseriesDefines.mqh"
 #include "..\..\..\Services\Colors.mqh"
 #include "..\..\..\Collections\BarTimeSeriesCollection.mqh"
 #include "..\..\..\Collections\GraphElementsCollection.mqh"
#ifndef CPATTERNINFOBOX_MQH_DECLARATION
#define CPATTERNINFOBOX_MQH_DECLARATION
 //+------------------------------------------------------------------+
 //| Box over a candle pattern (native rectangle label behind the     |
 //| candles, half a candle wider on each side) plus the pattern name |
 //| above it. Shows itself while Shift is down and the cursor is on  |
 //| a candle that opens an opted-in pattern; the data sources are    |
 //| borrowed (SetSources), CSymbolTFManager is the EA's              |
 //+------------------------------------------------------------------+
 class CPatternInfoBox : public CGBaseObj
  {
   private:
     CGStdRectangleLabelObj m_rect;
     CTooltip          m_tooltip;
     datetime          m_time_oldest;     // open time of the oldest bar of the pattern
     double            m_price_high;      // pattern high
     double            m_price_low;       // pattern low
     int               m_bars;            // bars in the pattern
     int               m_x;               // pixel box of the rectangle
     int               m_y;
     int               m_w;
     int               m_h;
     CBarTimeSeriesCollection *m_BarTimeSeriesCollection;   // CTimeSeriesEngine owns
     CBarPatternsControl      *m_BarPatterns_Control;       // CTimeSeriesEngine owns - per-type Buy/Sell opt-in
     CSymbolTFManager         *m_SymbolTFManager;           // EA owns - per Symbol/TF Buy/Sell
     bool              m_covered;         // a panel window is under the cursor
     datetime          m_last_bar;        // bar already handled while Shift stays down
     color             FillColor(const ENUM_PATTERN_DIRECTION dir) const;
     color             NameColor(const ENUM_PATTERN_DIRECTION dir) const;
     void              Reposition(void);
     void              RepositionTooltip(void);
     void              OnMouseMove(const int x,const int y,const string &sparam);
   public:
     bool              Create(const long chart_id,const int subwin,const string name);
     void              SetSources(CBarTimeSeriesCollection *series,CBarPatternsControl *patterns_control,CSymbolTFManager *manager)
                         { this.m_BarTimeSeriesCollection=series; this.m_BarPatterns_Control=patterns_control; this.m_SymbolTFManager=manager; }
     virtual void      SetCovered(const bool covered)          { this.m_covered=covered;             }
     void              Show(const datetime time_oldest,const double price_high,const double price_low,
                            const ENUM_PATTERN_DIRECTION dir,const int bars_formation,const string pattern_name);
     void              Hide(void);
     void              ShowTooltip(void)                       { this.m_tooltip.ShowTooltip();       }
     void              FadeOutTooltip(void)                    { this.m_tooltip.FadeOutTooltip();    }
     CTooltip         *Tooltip(void)                           { return &this.m_tooltip;             }
     //--- Pixel box of the rectangle
     int               X(void)                           const { return this.m_x;                    }
     int               Y(void)                           const { return this.m_y;                    }
     int               RightEdge(void)                   const { return this.m_x+this.m_w;           }
     int               BottomEdge(void)                  const { return this.m_y+this.m_h;           }
     bool              CursorInsideElement(const int x,const int y);
     virtual void      OnChartEvent(const int id,const long &lparam,const double &dparam,const string &sparam);
     virtual void      OnTimerEvent(void);
                       CPatternInfoBox(void);
  };
#endif // CPATTERNINFOBOX_MQH_DECLARATION
#ifndef CPATTERNINFOBOX_MQH_IMPLEMENTATION
#define CPATTERNINFOBOX_MQH_IMPLEMENTATION
 CPatternInfoBox::CPatternInfoBox(void) : m_time_oldest(0),m_price_high(0),m_price_low(0),m_bars(1),m_x(0),m_y(0),m_w(0),m_h(0),
                                         m_BarTimeSeriesCollection(NULL),m_BarPatterns_Control(NULL),m_SymbolTFManager(NULL),m_covered(false),m_last_bar(0)
  {
  }
 //--- Born hidden; the tooltip shows only the colored name, no box
 bool CPatternInfoBox::Create(const long chart_id,const int subwin,const string name)
  {
   if(!this.m_rect.Create(chart_id,subwin,name))
      return false;
   this.SetName(name);
   this.SetChartID(this.m_rect.ChartID());
   this.m_subwindow=this.m_rect.SubWindow();
   this.m_rect.SetFlagBack(true,false);
   this.m_rect.SetFlagSelectable(false,false);
   this.m_rect.SetTooltip("\n");
   this.m_rect.SetBorderType(BORDER_FLAT);
   this.m_rect.SetVisibleFlag(false,false);
   this.m_visible=false;
   this.m_tooltip.Hide();
   if(!this.m_tooltip.CreateTooltip(this.ChartID(),this.SubWindow(),name+"_tip",160,20))
      return false;
   this.m_tooltip.GetBackColorControl().InitColors(clrNONE,clrNONE,clrNONE,clrNONE);
   this.m_tooltip.GetBackColorControl().SetCurrentAs(COLOR_STATE_DEFAULT);
   this.m_tooltip.GetBorderColorControl().InitColors(clrNONE,clrNONE,clrNONE,clrNONE);
   this.m_tooltip.GetBorderColorControl().SetCurrentAs(COLOR_STATE_DEFAULT);
   this.AddChild(&this.m_rect);
   this.AddChild(&this.m_tooltip);
   return true;
  }
 color CPatternInfoBox::FillColor(const ENUM_PATTERN_DIRECTION dir) const
  {
   switch(dir)
     {
      case PATTERN_DIRECTION_BULLISH : return clrCornflowerBlue;
      case PATTERN_DIRECTION_BEARISH : return clrLightSalmon;
      default                        : return clrSilver;
     }
  }
 color CPatternInfoBox::NameColor(const ENUM_PATTERN_DIRECTION dir) const
  {
   switch(dir)
     {
      case PATTERN_DIRECTION_BULLISH : return clrRoyalBlue;
      case PATTERN_DIRECTION_BEARISH : return clrCrimson;
      default                        : return clrDimGray;
     }
  }
 //+------------------------------------------------------------------+
 //| Pixel box: half a bar slot beyond the oldest and the newest bar, |
 //| pattern high to low plus 4px, at least 12px tall                 |
 //+------------------------------------------------------------------+
 void CPatternInfoBox::Reposition(void)
  {
   int xc=0,y_top=0,y_bottom=0;
   if(!::ChartTimePriceToXY(this.ChartID(),this.SubWindow(),this.m_time_oldest,this.m_price_high,xc,y_top) ||
      !::ChartTimePriceToXY(this.ChartID(),this.SubWindow(),this.m_time_oldest,this.m_price_low,xc,y_bottom))
      return;
   int slot=(int)(1<<(int)::ChartGetInteger(this.ChartID(),CHART_SCALE));
   this.m_x=xc-slot/2;
   this.m_y=y_top-4;
   this.m_w=this.m_bars*slot+1;
   this.m_h=y_bottom-y_top+8;
   if(this.m_h<12)
      this.m_h=12;
   this.m_rect.SetXDistance(this.m_x);
   this.m_rect.SetYDistance(this.m_y);
   this.m_rect.SetXSize(this.m_w);
   this.m_rect.SetYSize(this.m_h);
  }
 void CPatternInfoBox::Show(const datetime time_oldest,const double price_high,const double price_low,
                            const ENUM_PATTERN_DIRECTION dir,const int bars_formation,const string pattern_name)
  {
   this.m_time_oldest=time_oldest;
   this.m_price_high =price_high;
   this.m_price_low  =price_low;
   this.m_bars       =(bars_formation<1 ? 1 : bars_formation);
   this.Reposition();
   color bg=(color)::ChartGetInteger(this.ChartID(),CHART_COLOR_BACKGROUND);
   this.m_rect.SetBGColor(CColors::MixColors(bg,this.FillColor(dir),100/255.0));
   this.m_rect.SetColor(this.NameColor(dir));
   this.m_rect.SetVisibleFlag(true,false);
   this.m_visible=true;
   this.m_tooltip.ClearStrings();
   this.m_tooltip.HeaderText(pattern_name);
   this.m_tooltip.HeaderColor(this.NameColor(dir));
   this.RepositionTooltip();
  }
 void CPatternInfoBox::Hide(void)
  {
   this.m_tooltip.FadeOutTooltip();
   if(!this.m_visible)
      return;
   this.m_rect.SetVisibleFlag(false,false);
   this.m_visible=false;
  }
 bool CPatternInfoBox::CursorInsideElement(const int x,const int y)
  {
   if(!this.m_visible)
      return false;
   return (x>=this.X() && x<=this.RightEdge() && y>=this.Y() && y<=this.BottomEdge());
  }
 //+------------------------------------------------------------------+
 //| Name clear of every candle under its width: above their highest  |
 //| high, below their lowest low when there is no room above         |
 //+------------------------------------------------------------------+
 void CPatternInfoBox::RepositionTooltip(void)
  {
   const int gap=16;   // room for the SignalMarkers arrows above/below the bars
   string sym=::ChartSymbol(this.ChartID());
   ENUM_TIMEFRAMES tf=(ENUM_TIMEFRAMES)::ChartPeriod(this.ChartID());
   int x     =this.X();
   int tip_h =this.m_tooltip.Height();
   int top   =this.Y();
   int bottom=this.BottomEdge();
   datetime t_left=0,t_right=0;
   double price=0.0;
   int sub=this.SubWindow();
   if(::ChartXYToTimePrice(this.ChartID(),x,top,sub,t_left,price) &&
      ::ChartXYToTimePrice(this.ChartID(),x+this.m_tooltip.Width(),top,sub,t_right,price))
     {
      int shift_left =::iBarShift(sym,tf,t_left,false);
      int shift_right=::iBarShift(sym,tf,t_right,false);
      if(shift_left>=0 && shift_right>=0 && shift_left>=shift_right)
        {
         int count=shift_left-shift_right+1;
         int i_hi=::iHighest(sym,tf,MODE_HIGH,count,shift_right);
         int i_lo=::iLowest(sym,tf,MODE_LOW,count,shift_right);
         int px=0,py=0;
         if(i_hi>=0 && ::ChartTimePriceToXY(this.ChartID(),this.SubWindow(),::iTime(sym,tf,i_hi),::iHigh(sym,tf,i_hi),px,py) && py<top)
            top=py;
         if(i_lo>=0 && ::ChartTimePriceToXY(this.ChartID(),this.SubWindow(),::iTime(sym,tf,i_lo),::iLow(sym,tf,i_lo),px,py) && py>bottom)
            bottom=py;
        }
     }
   int y=top-gap-tip_h;
   if(y<0)
      y=bottom+gap;
   this.m_tooltip.Moving(x,y);
  }
 //--- Scroll/zoom/new bar: the label is placed in pixels, so it is moved with the candles here
 void CPatternInfoBox::OnChartEvent(const int id,const long &lparam,const double &dparam,const string &sparam)
  {
   for(int i=0; i<this.ChildrenTotal(); i++)
      this.Child(i).OnChartEvent(id,lparam,dparam,sparam);
   if(id==CHARTEVENT_MOUSE_MOVE)
     {
      this.OnMouseMove((int)lparam,(int)dparam,sparam);
      return;
     }
   if(id!=CHARTEVENT_CHART_CHANGE || !this.m_visible)
      return;
   this.Reposition();
   if(this.m_tooltip.IsVisible())
      this.RepositionTooltip();
  }
 //+------------------------------------------------------------------+
 //| Shift down + cursor on a candle: box over the widest opted-in    |
 //| pattern that opens there. Shift up: hidden. A window under the   |
 //| cursor or the cursor on the box leaves it as it is               |
 //+------------------------------------------------------------------+
 void CPatternInfoBox::OnMouseMove(const int x,const int y,const string &sparam)
  {
   if(this.m_BarTimeSeriesCollection==NULL || this.m_covered)
      return;
   bool shift=((((int)::StringToInteger(sparam))&MOUSE_BUTT_KEY_STATE_SHIFT)!=0);
   if(!shift)
     {
      this.m_last_bar=0;
      if(this.m_visible)
        {
         this.Hide();
         ::ChartRedraw(this.ChartID());
        }
      return;
     }
   if(this.m_visible && this.CursorInsideElement(x,y))
      return;
   datetime t=0;
   double price=0.0;
   int sub=0;
   if(!::ChartXYToTimePrice(this.ChartID(),x,y,sub,t,price) || sub!=this.SubWindow())
      return;
   string sym=::ChartSymbol(this.ChartID());
   ENUM_TIMEFRAMES tf=(ENUM_TIMEFRAMES)::ChartPeriod(this.ChartID());
   int bar_shift=::iBarShift(sym,tf,t,false);
   if(bar_shift<0)
      return;
   datetime bar_time=::iTime(sym,tf,bar_shift);
   if(bar_time==this.m_last_bar)
      return;
   this.m_last_bar=bar_time;
   CSymbolTFSetting *entry=(this.m_SymbolTFManager!=NULL ? this.m_SymbolTFManager.FindByIdentity(sym,tf) : NULL);
   bool allow_buy =(entry!=NULL ? entry.BuySignal()  : false);
   bool allow_sell=(entry!=NULL ? entry.SellSignal() : false);
   CBarPattern *best=this.m_BarTimeSeriesCollection.GetPatternAtBar(sym,tf,bar_time,this.m_BarPatterns_Control,allow_buy,allow_sell);
   if(best==NULL)
     {
      if(this.m_visible)
        {
         this.Hide();
         ::ChartRedraw(this.ChartID());
        }
      return;
     }
   int n=((int)best.Candles()<1 ? 1 : (int)best.Candles());
   datetime t_oldest=best.Time()-(datetime)((n-1)*::PeriodSeconds(tf));
   string name=best.GetProperty(PATTERN_PROP_NAME);
   if(name=="")
      name=::EnumToString(best.TypePattern());
   this.Show(t_oldest,best.MotherBarHigh(),best.MotherBarLow(),best.Direction(),n,name);
   //--- The name is not shown under a panel window
   CGraphElementsCollection *root=dynamic_cast<CGraphElementsCollection *>(this.Parent());
   int tx=this.m_tooltip.X();
   int ty=this.m_tooltip.Y();
   if(root!=NULL && (root.IsCoveredAt(this.ChartID(),tx,ty) || root.IsCoveredAt(this.ChartID(),tx+this.m_tooltip.Width(),ty)))
      this.m_tooltip.FadeOutTooltip();
   else
      this.m_tooltip.ShowTooltip();
   ::ChartRedraw(this.ChartID());
  }
 void CPatternInfoBox::OnTimerEvent(void)
  {
   for(int i=0; i<this.ChildrenTotal(); i++)
      this.Child(i).OnTimerEvent();
  }
#endif // CPATTERNINFOBOX_MQH_IMPLEMENTATION
#endif // __PATTERNINFOBOX_MQH__
