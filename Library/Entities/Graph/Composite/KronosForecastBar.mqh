//+------------------------------------------------------------------+
//|                                            KronosForecastBar.mqh |
//+------------------------------------------------------------------+
#ifndef __KRONOSFORECASTBAR_COMPOSITE_MQH__
#define __KRONOSFORECASTBAR_COMPOSITE_MQH__
 #include "..\..\GBases\GBaseObj.mqh"
 #include "..\Standard\GStdRectangleObj.mqh"
 #include "..\Standard\GStdTrendObj.mqh"
 #ifndef KRONOS_FORECAST_UP_COLOR
  #define KRONOS_FORECAST_UP_COLOR    (C'160,214,209')   // the EA may define it before the library (EA Configuration.mqh): faint, as the web View draws it
 #endif
 #ifndef KRONOS_FORECAST_DOWN_COLOR
  #define KRONOS_FORECAST_DOWN_COLOR  (C'244,180,179')
 #endif
 #define KRONOS_FORECAST_BODY_PART    (0.35)   // the body spans this part of a bar on each side of its time
#ifndef CKRONOS_FORECAST_BAR_COMPOSITE_DECLARATION
#define CKRONOS_FORECAST_BAR_COMPOSITE_DECLARATION
 //+------------------------------------------------------------------+
 //| A bar Kronos foretells, after the newest bar of the chart: its   |
 //| body (open..close) and its wick (high..low), native objects bound |
 //| to time, in the background, as CStructureBreakLine               |
 //+------------------------------------------------------------------+
 class CKronosForecastBar : public CGBaseObj
  {
   private:
     CGStdRectangleObj         m_body;      // open..close, around the time of the bar
     CGStdTrendObj             m_wick;      // high..low at the time of the bar
     datetime                  m_time;      // the open time of the bar foretold
   public:
     bool                      Create(const long chart_id,const int subwin,const string name);
     void                      SetBar(const datetime time,const double open,const double high,const double low,const double close,const int seconds);
     datetime                  Time(void)                     const { return this.m_time; }
                               CKronosForecastBar(void) : m_time(0) {}
  };
#endif // CKRONOS_FORECAST_BAR_COMPOSITE_DECLARATION
#ifndef CKRONOS_FORECAST_BAR_COMPOSITE_IMPLEMENTATION
#define CKRONOS_FORECAST_BAR_COMPOSITE_IMPLEMENTATION
 bool CKronosForecastBar::Create(const long chart_id,const int subwin,const string name)
  {
   if(!this.m_body.Create(chart_id,subwin,name+"_body"))
      return false;
   if(!this.m_wick.Create(chart_id,subwin,name+"_wick"))
      return false;
   this.SetName(name);
   this.SetChartID(this.m_body.ChartID());
   this.m_subwindow=this.m_body.SubWindow();
   this.m_body.SetFlagBack(true,false);
   this.m_body.SetFlagSelectable(false,false);
   this.m_body.SetTooltip("\n");
   ::ObjectSetInteger(this.m_body.ChartID(),this.m_body.Name(),OBJPROP_FILL,true);
   this.m_wick.SetFlagBack(true,false);
   this.m_wick.SetFlagSelectable(false,false);
   this.m_wick.SetTooltip("\n");
   this.m_wick.SetWidth(1);
   this.AddChild(&this.m_body);
   this.AddChild(&this.m_wick);
   return true;
  }
 void CKronosForecastBar::SetBar(const datetime time,const double open,const double high,const double low,const double close,const int seconds)
  {
   const color colour=(close>=open ? KRONOS_FORECAST_UP_COLOR : KRONOS_FORECAST_DOWN_COLOR);
   const long  half=(long)(seconds*KRONOS_FORECAST_BODY_PART);
   this.m_time=time;
   this.m_body.SetTime((datetime)((long)time-half),0);
   this.m_body.SetPrice(open,0);
   this.m_body.SetTime((datetime)((long)time+half),1);
   this.m_body.SetPrice(close,1);
   this.m_body.SetColor(colour);
   this.m_wick.SetTime(time,0);
   this.m_wick.SetPrice(high,0);
   this.m_wick.SetTime(time,1);
   this.m_wick.SetPrice(low,1);
   this.m_wick.SetColor(colour);
  }
#endif // CKRONOS_FORECAST_BAR_COMPOSITE_IMPLEMENTATION
#endif // __KRONOSFORECASTBAR_COMPOSITE_MQH__
