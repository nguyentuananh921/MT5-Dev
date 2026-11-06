//+------------------------------------------------------------------+
//|                                                 IndAlligator.mqh |
//|                        Copyright 2020, MetaQuotes Software Corp. |
//|                             https://mql5.com/en/users/artmedia70 |
//+------------------------------------------------------------------+
//--- Change from V1 Timeseries\Indicators\Standard\IndAlligator.mqh: the group and name come from the manager catalog; PrintParameters is CIndicatorDE's (by the schema)
#ifndef __INDALLIGATOR_MQH__
#define __INDALLIGATOR_MQH__
 #include "..\IndicatorDE.mqh"
#ifndef CINDALLIGATOR_MQH_DECLARATION
#define CINDALLIGATOR_MQH_DECLARATION
 //+------------------------------------------------------------------+
 //| Alligator standard indicator                                     |
 //+------------------------------------------------------------------+
 class CIndAlligator : public CIndicatorDE
  {
   public:
                      CIndAlligator(const string symbol,const ENUM_TIMEFRAMES timeframe,MqlParam &mql_param[],CIndicatorTemplateManager *manager) :
                         CIndicatorDE(IND_ALLIGATOR,symbol,timeframe,INDICATOR_STATUS_STANDARD,manager,
                                      "",mql_param) { this.m_object_type=OBJECT_DE_TYPE_IND_ALLIGATOR; }
  };
#endif // CINDALLIGATOR_MQH_DECLARATION
#endif // __INDALLIGATOR_MQH__
