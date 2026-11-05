//+------------------------------------------------------------------+
//|                                                      IndOsMA.mqh |
//|                        Copyright 2020, MetaQuotes Software Corp. |
//|                             https://mql5.com/en/users/artmedia70 |
//+------------------------------------------------------------------+
//--- Change from V1 Timeseries\Indicators\Standard\IndOsMA.mqh: the group and name come from the manager catalog; PrintParameters is CIndicatorDE's (by the schema)
#ifndef __INDOSMA_MQH__
#define __INDOSMA_MQH__
 #include "..\IndicatorDE.mqh"
#ifndef CINDOSMA_MQH_DECLARATION
#define CINDOSMA_MQH_DECLARATION
 //+------------------------------------------------------------------+
 //| Moving Average of Oscillator standard indicator                  |
 //+------------------------------------------------------------------+
 class CIndOsMA : public CIndicatorDE
  {
   public:
                      CIndOsMA(const string symbol,const ENUM_TIMEFRAMES timeframe,MqlParam &mql_param[],CIndicatorTemplateManager *manager) :
                         CIndicatorDE(IND_OSMA,symbol,timeframe,INDICATOR_STATUS_STANDARD,manager.StandardIndicatorGroup(IND_OSMA),manager.StandardIndicatorName(IND_OSMA),
                                      "",mql_param) { this.m_object_type=OBJECT_DE_TYPE_IND_OSMA; }
  };
#endif // CINDOSMA_MQH_DECLARATION
#endif // __INDOSMA_MQH__
