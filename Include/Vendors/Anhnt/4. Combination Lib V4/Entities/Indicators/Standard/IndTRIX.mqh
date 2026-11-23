//+------------------------------------------------------------------+
//|                                                      IndTRIX.mqh |
//|                        Copyright 2020, MetaQuotes Software Corp. |
//|                             https://mql5.com/en/users/artmedia70 |
//+------------------------------------------------------------------+
//--- Change from V1 Timeseries\Indicators\Standard\IndTRIX.mqh: the group and name come from the manager catalog; PrintParameters is CIndicatorDE's (by the schema)
#ifndef __INDTRIX_MQH__
#define __INDTRIX_MQH__
 #include "..\IndicatorDE.mqh"
#ifndef CINDTRIX_MQH_DECLARATION
#define CINDTRIX_MQH_DECLARATION
 //+------------------------------------------------------------------+
 //| Triple Exponential Moving Averages Oscillator standard indicator |
 //+------------------------------------------------------------------+
 class CIndTRIX : public CIndicatorDE
  {
   public:
                      CIndTRIX(const string symbol,const ENUM_TIMEFRAMES timeframe,MqlParam &mql_param[],CIndicatorTemplateManager *manager) :
                         CIndicatorDE(IND_TRIX,symbol,timeframe,INDICATOR_STATUS_STANDARD,manager,
                                      "",mql_param) { this.m_object_type=OBJECT_DE_TYPE_IND_TRIX; }
  };
#endif // CINDTRIX_MQH_DECLARATION
#endif // __INDTRIX_MQH__
