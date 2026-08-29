//+------------------------------------------------------------------+
//|                                TimeSeriesEngine_CandlePattern.mqh|
//+------------------------------------------------------------------+
#ifndef CTIMESERIESENGINE_CANDLEPATTERN_MQH
#define CTIMESERIESENGINE_CANDLEPATTERN_MQH
#include "TimeSeriesEngine.mqh"
//  Push engine-level registry to each series-level ctrl, then trigger full scan.
//  Populates m_list_all_patterns with CBarPattern objects for all bars.
 bool CTimeSeriesEngine::SeriesApplyPatternRegistry(const string symbol, const ENUM_TIMEFRAMES timeframe)
  {   
    CBarTimeSeriesDE *bartimeseries  = this.m_BarTimeSeriesCollection.GetTimeseries(symbol);
    CBarSeriesDE     *barseries = NULL;
    if(bartimeseries != NULL)
     {
       CArrayObj *barserieslist = bartimeseries.GetListSeries();
       for(int i = 0; i < barserieslist.Total(); i++)
        {
          CBarSeriesDE *s = barserieslist.At(i);
          if(s != NULL && s.Timeframe() == timeframe)
          { barseries = s; break; }
        }
     }
    CBarPatternsControl *ctrl = (barseries  != NULL ? barseries.GetPatternsCtrlObj(): NULL);
    if(ctrl == NULL) return false;
    CArrayObj *reg = m_BarPatterns_Control.GetListControls();    
    for(int i = 0; i < reg.Total(); i++)
     {
        CBarPatternControl *c = reg.At(i);
        if(c != NULL)
          ctrl.SetUsedPattern(c.TypePattern(), c.PatternParams, true);
     }  
    return true;
  }
#endif // CTIMESERIESENGINE_CANDLEPATTERN_MQH
