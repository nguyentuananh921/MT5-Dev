//+------------------------------------------------------------------+
//|                                                     IndFRAMA.mqh |
//|                        Copyright 2020, MetaQuotes Software Corp. |
//|                             https://mql5.com/en/users/artmedia70 |
//+------------------------------------------------------------------+
//--- Change from V1 Timeseries\Indicators\Standard\IndFRAMA.mqh: 
// the group and the name are the catalog's (IndicatorDELib.mqh), 
// PrintParameters is CIndicatorDE's (by the schema)
// "Chart holds FRAMA without Shift (2 params), 
// IndicatorCreate needs 3: CChartObj::ChartParams 
// ChartIdentity map them."

#ifndef __INDFRAMA_MQH__
#define __INDFRAMA_MQH__
 #include "..\IndicatorDE.mqh"
#ifndef CINDFRAMA_MQH_DECLARATION
#define CINDFRAMA_MQH_DECLARATION
 //+------------------------------------------------------------------+
 //| Fractal Adaptive Moving Average standard indicator               |
 //+------------------------------------------------------------------+
 class CIndFRAMA : public CIndicatorDE
  {
   public:
                      CIndFRAMA(const string symbol,const ENUM_TIMEFRAMES timeframe,MqlParam &mql_param[]) :
                         CIndicatorDE(IND_FRAMA,symbol,timeframe,INDICATOR_STATUS_STANDARD,GetIndicatorGroupForType(IND_FRAMA),GetIndicatorNameForType(IND_FRAMA),
                                      "",mql_param) { this.m_object_type=OBJECT_DE_TYPE_IND_FRAMA; }
  };
#endif // CINDFRAMA_MQH_DECLARATION
#endif // __INDFRAMA_MQH__
