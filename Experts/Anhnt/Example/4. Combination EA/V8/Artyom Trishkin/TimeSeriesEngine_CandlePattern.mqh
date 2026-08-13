//+------------------------------------------------------------------+
//|                                TimeSeriesEngine_CandlePattern.mqh|
//+------------------------------------------------------------------+
#ifndef CTIMESERIESENGINE_CANDLEPATTERN_MQH
#define CTIMESERIESENGINE_CANDLEPATTERN_MQH
#include "TimeSeriesEngine.mqh"
 //For candle Pattern in Layer 1
 void CTimeSeriesEngine::RegisterAllCandlePatterns(void)
  {
   MqlParam p[];
   // 25 patterns with default parameters (empty array)
   // Parameter define in PatternControl.mqh
    this.m_BarPatterns_Control.SetUsedPattern(PATTERN_TYPE_HAMMER,               p, true);
    this.m_BarPatterns_Control.SetUsedPattern(PATTERN_TYPE_HANGING_MAN,          p, true);
    this.m_BarPatterns_Control.SetUsedPattern(PATTERN_TYPE_INVERTED_HAMMER,      p, true);
    this.m_BarPatterns_Control.SetUsedPattern(PATTERN_TYPE_SHOOTING_STAR,        p, true);
    this.m_BarPatterns_Control.SetUsedPattern(PATTERN_TYPE_DOJI,                 p, true);
    this.m_BarPatterns_Control.SetUsedPattern(PATTERN_TYPE_DRAGONFLY_DOJI,       p, true);
    this.m_BarPatterns_Control.SetUsedPattern(PATTERN_TYPE_GRAVESTONE_DOJI,      p, true);
    this.m_BarPatterns_Control.SetUsedPattern(PATTERN_TYPE_HARAMI,               p, true);
    this.m_BarPatterns_Control.SetUsedPattern(PATTERN_TYPE_HARAMI_CROSS,         p, true);
    this.m_BarPatterns_Control.SetUsedPattern(PATTERN_TYPE_ENGULFING,            p, true);
    this.m_BarPatterns_Control.SetUsedPattern(PATTERN_TYPE_TWEEZER,              p, true);
    this.m_BarPatterns_Control.SetUsedPattern(PATTERN_TYPE_PIERCING_LINE,        p, true);
    this.m_BarPatterns_Control.SetUsedPattern(PATTERN_TYPE_DARK_CLOUD_COVER,     p, true);
    this.m_BarPatterns_Control.SetUsedPattern(PATTERN_TYPE_RAILS,                p, true);
    this.m_BarPatterns_Control.SetUsedPattern(PATTERN_TYPE_MORNING_STAR,         p, true);
    this.m_BarPatterns_Control.SetUsedPattern(PATTERN_TYPE_MORNING_DOJI_STAR,    p, true);
    this.m_BarPatterns_Control.SetUsedPattern(PATTERN_TYPE_EVENING_STAR,         p, true);
    this.m_BarPatterns_Control.SetUsedPattern(PATTERN_TYPE_EVENING_DOJI_STAR,    p, true);
    this.m_BarPatterns_Control.SetUsedPattern(PATTERN_TYPE_THREE_WHITE_SOLDIERS, p, true);
    this.m_BarPatterns_Control.SetUsedPattern(PATTERN_TYPE_THREE_BLACK_CROWS,    p, true);
    this.m_BarPatterns_Control.SetUsedPattern(PATTERN_TYPE_THREE_STARS,          p, true);
    this.m_BarPatterns_Control.SetUsedPattern(PATTERN_TYPE_THREE_INSIDE_UP,      p, true);
    this.m_BarPatterns_Control.SetUsedPattern(PATTERN_TYPE_THREE_INSIDE_DOWN,    p, true);
    this.m_BarPatterns_Control.SetUsedPattern(PATTERN_TYPE_ABANDONED_BABY,       p, true);
    this.m_BarPatterns_Control.SetUsedPattern(PATTERN_TYPE_PIVOT_POINT_REVERSAL, p, true);

   // OutsideBar: requires 3 parameters from BarPatternControl constants
    MqlParam outside_bar_params[];
    ArrayResize(outside_bar_params, 3);
    outside_bar_params[0].type = TYPE_INT;
    outside_bar_params[0].integer_value = PATTERN_DEF_OUTSIDE_BAR_MIN_BODY_SIZE;
    outside_bar_params[1].type = TYPE_DOUBLE;
    outside_bar_params[1].double_value = PATTERN_DEF_OUTSIDE_BAR_RATIO_CANDLES;
    outside_bar_params[2].type = TYPE_DOUBLE;
    outside_bar_params[2].double_value = PATTERN_DEF_OUTSIDE_BAR_RATIO_BODY;
    this.m_BarPatterns_Control.SetUsedPattern(PATTERN_TYPE_OUTSIDE_BAR, outside_bar_params, true);    
   // InsideBar: requires 1 parameters from BarPatternControl constants
    MqlParam inside_bar_params[];
    ArrayResize(inside_bar_params, 1);
    inside_bar_params[0].type = TYPE_INT;
    inside_bar_params[0].integer_value = PATTERN_DEF_INSIDE_BAR_MIN_BODY_SIZE;
    this.m_BarPatterns_Control.SetUsedPattern(PATTERN_TYPE_INSIDE_BAR, inside_bar_params, true);    
   // PinBar: requires 4 parameters from BarPatternControl constants
    MqlParam pinbar_params[];
    ArrayResize(pinbar_params, 4);
    pinbar_params[0].type = TYPE_INT;
    pinbar_params[0].integer_value = PATTERN_DEF_PINBAR_MIN_BODY_SIZE;      // param[0]
    pinbar_params[1].type = TYPE_DOUBLE;
    pinbar_params[1].double_value = PATTERN_DEF_PINBAR_RATIO_BODY;          // param[1]
    pinbar_params[2].type = TYPE_DOUBLE;
    pinbar_params[2].double_value = PATTERN_DEF_PINBAR_LARGER_SHADOW;       // param[2]
    pinbar_params[3].type = TYPE_DOUBLE;
    pinbar_params[3].double_value = PATTERN_DEF_PINBAR_SMALLER_SHADOW;      // param[3]
    this.m_BarPatterns_Control.SetUsedPattern(PATTERN_TYPE_PIN_BAR, pinbar_params, true);
  }
 // Push engine-level registry to each series-level ctrl, then trigger full scan.
 // Populates m_list_all_patterns with CBarPattern objects for all bars.
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
