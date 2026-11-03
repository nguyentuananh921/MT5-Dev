//+------------------------------------------------------------------+
//|                                                     IndStoch.mqh |
//|                        Copyright 2020, MetaQuotes Software Corp. |
//|                             https://mql5.com/en/users/artmedia70 |
//+------------------------------------------------------------------+
//--- Change from V1 Timeseries\Indicators\Standard\IndStoch.mqh: the group and the name are the catalog's (IndicatorDELib.mqh), PrintParameters is CIndicatorDE's (by the schema)
#ifndef __INDSTOCH_MQH__
#define __INDSTOCH_MQH__
 #include "..\IndicatorDE.mqh"
#ifndef CINDSTOCH_MQH_DECLARATION
#define CINDSTOCH_MQH_DECLARATION
 //+------------------------------------------------------------------+
 //| Stochastic Oscillator standard indicator                         |
 //+------------------------------------------------------------------+
 class CIndStoch : public CIndicatorDE
  {
   public:
                      CIndStoch(const string symbol,const ENUM_TIMEFRAMES timeframe,MqlParam &mql_param[]) :
                         CIndicatorDE(IND_STOCHASTIC,symbol,timeframe,INDICATOR_STATUS_STANDARD,GetIndicatorGroupForType(IND_STOCHASTIC),GetIndicatorNameForType(IND_STOCHASTIC),
                                      "",mql_param) { this.m_object_type=OBJECT_DE_TYPE_IND_STOCH; }
  };
#endif // CINDSTOCH_MQH_DECLARATION
#endif // __INDSTOCH_MQH__
