//+------------------------------------------------------------------+
//|                                                StrategyTrade.mqh |
//|                                     Copyright 2026, Anhnt        |
//| A position of a strategy on the shared layer: a dashed line from |
//| the candle of its entry to the candle of its exit, where their   |
//| markers are (Sell: the high, Buy: the low), in the colour of its |
//| side: which position opened where and closed where. New in V5   |
//+------------------------------------------------------------------+
#ifndef __STRATEGYTRADE_MQH__
#define __STRATEGYTRADE_MQH__
 #include "..\..\GBases\GLayerItem.mqh"
 #include "..\..\Chart\ChartObj.mqh"
 #include "..\..\..\Collections\Settings\StrategyManager.mqh"
 #include "BarMarker.mqh"   // the colours of the sides (BAR_MARKER_BUY_COLOR, BAR_MARKER_SELL_COLOR)
#ifndef CSTRATEGYTRADE_DECLARATION
#define CSTRATEGYTRADE_DECLARATION
 class CStrategyTrade : public CGLayerItem
  {
   private:
     long                      m_strategy_id;
     datetime                  m_entry_time;      // the bars of the entry and of the exit (the tf of the strategy)
     datetime                  m_exit_time;
     bool                      m_is_buy;
     bool                      m_on_chart;        // Arrange() placed it: the points are valid
     int                       m_x1,m_y1,m_x2,m_y2;
   //--- Where a marker of the position is: the candle of the chart that holds the time, its high (Sell) or its low (Buy)
     bool                      Point(const string sym,const ENUM_TIMEFRAMES chart_tf,const datetime time,const int ref_shift,const int ref_x,const int ref_y,const int scale,
                                     const double pixels,const double price_max,int &x,int &y) const;
   public:
     bool                      Create(const long chart_id,const string name,const long strategy_id,const datetime entry_time,const datetime exit_time,const bool is_buy);
     long                      StrategyId(void)               const { return this.m_strategy_id; }
     virtual void              Paint(CCanvas *canvas);
   //--- Every position of the parent finds its points on the chart (as CBarMarker::Arrange: CChartObj, one chart query) and shows when its strategy shows (show_on_chart)
     static void               Arrange(CGBaseObj *parent,CChartObj *chart,CStrategyManager *strategies);
                               CStrategyTrade(void) : m_strategy_id(WRONG_VALUE),m_entry_time(0),m_exit_time(0),m_is_buy(true),m_on_chart(false),
                                                      m_x1(0),m_y1(0),m_x2(0),m_y2(0) { }
  };
#endif // CSTRATEGYTRADE_DECLARATION
#ifndef CSTRATEGYTRADE_IMPLEMENTATION
#define CSTRATEGYTRADE_IMPLEMENTATION
 bool CStrategyTrade::Create(const long chart_id,const string name,const long strategy_id,const datetime entry_time,const datetime exit_time,const bool is_buy)
  {
   this.SetName(name);
   this.SetChartID(chart_id==0 ? ::ChartID() : chart_id);
   this.m_strategy_id=strategy_id;
   this.m_entry_time=entry_time;
   this.m_exit_time=exit_time;
   this.m_is_buy=is_buy;
   this.m_visible=false;
   return true;
  }
 bool CStrategyTrade::Point(const string sym,const ENUM_TIMEFRAMES chart_tf,const datetime time,const int ref_shift,const int ref_x,const int ref_y,const int scale,
                            const double pixels,const double price_max,int &x,int &y) const
  {
   const int candle=::iBarShift(sym,chart_tf,time,false);
   if(candle<0)
      return false;
   const double price=(this.m_is_buy ? ::iLow(sym,chart_tf,candle) : ::iHigh(sym,chart_tf,candle));
   x=ref_x+(ref_shift-candle)*(1<<scale);
   y=ref_y+(int)::MathRound((price_max-price)*pixels);
   return (price>0);
  }
 void CStrategyTrade::Paint(CCanvas *canvas)
  {
   if(!this.m_visible || !this.m_on_chart)
      return;
   color side_colour=BAR_MARKER_SELL_COLOR;
   if(this.m_is_buy)
      side_colour=BAR_MARKER_BUY_COLOR;
   const uint colour=::ColorToARGB(side_colour);
   canvas.LineStyleSet(STYLE_DASH);
   canvas.LineAA(this.m_x1,this.m_y1,this.m_x2,this.m_y2,colour);
   canvas.LineStyleSet(STYLE_SOLID);
  }
 void CStrategyTrade::Arrange(CGBaseObj *parent,CChartObj *chart,CStrategyManager *strategies)
  {
   if(parent==NULL || chart==NULL || strategies==NULL)
      return;
   const string sym=chart.Symbol();
   const ENUM_TIMEFRAMES tf=chart.Timeframe();
   const int first_visible_bar=chart.FirstVisibleBars();
   const int scale=chart.Scale();
   const int height=chart.HeightInPixels();
   const double price_max=chart.PriceMax();
   const double price_min=chart.PriceMin();
   int ref_x=0,ref_y=0;
   const datetime ref_time=::iTime(sym,tf,first_visible_bar);
   if(height<=0 || price_max<=price_min || ref_time==0 || !::ChartTimePriceToXY(chart.ID(),0,ref_time,price_max,ref_x,ref_y))
      return;   // the chart has not this bar yet
   const double pixels=height/(price_max-price_min);
   int debug_total=0,debug_visible=0,debug_placed=0;
   for(int i=0;i<parent.ChildrenTotal();i++)
     {
      CStrategyTrade *trade=dynamic_cast<CStrategyTrade *>(parent.Child(i));
      if(trade==NULL)
         continue;
      CStrategySetting *strategy=strategies.Read_RAM(trade.m_strategy_id);
      trade.m_visible=(strategy!=NULL && strategy.ShowOnChart());
      trade.m_on_chart=(trade.m_visible &&
                        trade.Point(sym,tf,trade.m_entry_time,first_visible_bar,ref_x,ref_y,scale,pixels,price_max,trade.m_x1,trade.m_y1) &&
                        trade.Point(sym,tf,trade.m_exit_time,first_visible_bar,ref_x,ref_y,scale,pixels,price_max,trade.m_x2,trade.m_y2));
      debug_total++;
      debug_visible+=(int)trade.m_visible;
      debug_placed+=(int)trade.m_on_chart;
     }
   string debug_text="MY DEBUG CStrategyTrade::Arrange "+sym+" "+::EnumToString(tf)+": "+(string)debug_total+" position lines, "+(string)debug_visible+" of them shown (show_on_chart), "+
                     (string)debug_placed+" placed on the chart";
   ::Print(debug_text);
   CGLayerItem::Invalidate();
  }
#endif // CSTRATEGYTRADE_IMPLEMENTATION
#endif // __STRATEGYTRADE_MQH__
