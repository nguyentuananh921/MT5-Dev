//+------------------------------------------------------------------+
//|                                                TrendlineLine.mqh |
//+------------------------------------------------------------------+
#ifndef __TRENDLINELINE_COMPOSITE_MQH__
#define __TRENDLINELINE_COMPOSITE_MQH__
 #include "..\..\GBases\GBaseObj.mqh"
 #include "..\Standard\GStdTrendObj.mqh"
#ifndef CTRENDLINELINE_COMPOSITE_DECLARATION
#define CTRENDLINELINE_COMPOSITE_DECLARATION
 //+------------------------------------------------------------------+
 //| A trendline on the chart: a native trend line between two        |
 //| time/price points, drawn behind the candles. It knows nothing    |
 //| about states: the caller says the colour, the style and whether  |
 //| the line goes on to the right (a living line) or stops (a dead   |
 //| one)                                                             |
 //+------------------------------------------------------------------+
 class CTrendlineLine : public CGBaseObj
  {
   private:
     CGStdTrendObj             m_line;            // the line itself
     datetime                  m_dead_time;       // when it died, 0 while it lives
   public:
     bool                      Create(const long chart_id,const int subwin,const string name);
     void                      SetLine(const datetime time_1,const double price_1,const datetime time_2,const double price_2,
                                       const color colour,const ENUM_LINE_STYLE style,const int width,const bool ray_right);
     void                      SetInfo(const string info)  { this.m_line.SetTooltip(info); }
     void                      SetDeadTime(const datetime time) { this.m_dead_time=time;  }
     datetime                  DeadTime(void) const        { return this.m_dead_time;   }
                               CTrendlineLine(void) : m_dead_time(0) {}
  };
#endif // CTRENDLINELINE_COMPOSITE_DECLARATION
#ifndef CTRENDLINELINE_COMPOSITE_IMPLEMENTATION
#define CTRENDLINELINE_COMPOSITE_IMPLEMENTATION
 bool CTrendlineLine::Create(const long chart_id,const int subwin,const string name)
  {
   if(!this.m_line.Create(chart_id,subwin,name+"L"))
      return false;
   this.SetName(name);
   this.SetChartID(this.m_line.ChartID());
   this.m_subwindow=this.m_line.SubWindow();
   this.m_line.SetFlagBack(true,false);
   this.m_line.SetFlagSelectable(false,false);
   this.AddChild(&this.m_line);
   return true;
  }
 void CTrendlineLine::SetLine(const datetime time_1,const double price_1,const datetime time_2,const double price_2,
                              const color colour,const ENUM_LINE_STYLE style,const int width,const bool ray_right)
  {
   this.m_line.SetTime(time_1,0);
   this.m_line.SetPrice(price_1,0);
   this.m_line.SetTime(time_2,1);
   this.m_line.SetPrice(price_2,1);
   this.m_line.SetColor(colour);
   this.m_line.SetStyle(style);
   this.m_line.SetWidth(width);
   this.m_line.SetFlagRayRight(ray_right);
  }
#endif // CTRENDLINELINE_COMPOSITE_IMPLEMENTATION
#endif // __TRENDLINELINE_COMPOSITE_MQH__
