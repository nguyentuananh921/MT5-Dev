//+------------------------------------------------------------------+
//|                                                      IndTEMA.mqh |
//|                        Copyright 2020, MetaQuotes Software Corp. |
//|                             https://mql5.com/en/users/artmedia70 |
//+------------------------------------------------------------------+
//--- Change from V1 Timeseries\Indicators\Standard\IndTEMA.mqh: the group and the name are the catalog's (IndicatorDELib.mqh), PrintParameters is CIndicatorDE's (by the schema)
#ifndef __INDTEMA_MQH__
#define __INDTEMA_MQH__
 #include "..\IndicatorDE.mqh"
#ifndef CINDTEMA_MQH_DECLARATION
#define CINDTEMA_MQH_DECLARATION
 //+------------------------------------------------------------------+
 //| Triple Exponential Moving Average standard indicator             |
 //+------------------------------------------------------------------+
 class CIndTEMA : public CIndicatorDE
  {
   public:
                      CIndTEMA(const string symbol,const ENUM_TIMEFRAMES timeframe,MqlParam &mql_param[]) :
                         CIndicatorDE(IND_TEMA,symbol,timeframe,INDICATOR_STATUS_STANDARD,GetIndicatorGroupForType(IND_TEMA),GetIndicatorNameForType(IND_TEMA),
                                      "",mql_param) { this.m_type=OBJECT_DE_TYPE_IND_TEMA; }
  };
#endif // CINDTEMA_MQH_DECLARATION
#endif // __INDTEMA_MQH__
