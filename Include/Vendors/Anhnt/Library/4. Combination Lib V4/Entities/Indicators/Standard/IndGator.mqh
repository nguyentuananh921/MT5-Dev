//+------------------------------------------------------------------+
//|                                                     IndGator.mqh |
//|                        Copyright 2020, MetaQuotes Software Corp. |
//|                             https://mql5.com/en/users/artmedia70 |
//+------------------------------------------------------------------+
//--- Change from V1 Timeseries\Indicators\Standard\IndGator.mqh: the group and name come from the manager catalog; PrintParameters is CIndicatorDE's (by the schema)
#ifndef __INDGATOR_MQH__
#define __INDGATOR_MQH__
 #include "..\IndicatorDE.mqh"
#ifndef CINDGATOR_MQH_DECLARATION
#define CINDGATOR_MQH_DECLARATION
 //+------------------------------------------------------------------+
 //| Gator Oscillator standard indicator                              |
 //+------------------------------------------------------------------+
 class CIndGator : public CIndicatorDE
  {
   public:
                      CIndGator(const string symbol,const ENUM_TIMEFRAMES timeframe,MqlParam &mql_param[],CIndicatorTemplateManager *manager) :
                         CIndicatorDE(IND_GATOR,symbol,timeframe,INDICATOR_STATUS_STANDARD,manager.StandardIndicatorGroup(IND_GATOR),manager.StandardIndicatorName(IND_GATOR),
                                      "",mql_param) { this.m_object_type=OBJECT_DE_TYPE_IND_GATOR; }
  };
#endif // CINDGATOR_MQH_DECLARATION
#endif // __INDGATOR_MQH__
