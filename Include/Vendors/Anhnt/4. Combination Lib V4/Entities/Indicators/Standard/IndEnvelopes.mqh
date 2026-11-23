//+------------------------------------------------------------------+
//|                                                 IndEnvelopes.mqh |
//|                        Copyright 2020, MetaQuotes Software Corp. |
//|                             https://mql5.com/en/users/artmedia70 |
//+------------------------------------------------------------------+
//--- Change from V1 Timeseries\Indicators\Standard\IndEnvelopes.mqh: the group and name come from the manager catalog; PrintParameters is CIndicatorDE's (by the schema)
#ifndef __INDENVELOPES_MQH__
#define __INDENVELOPES_MQH__
 #include "..\IndicatorDE.mqh"
#ifndef CINDENVELOPES_MQH_DECLARATION
#define CINDENVELOPES_MQH_DECLARATION
 //+------------------------------------------------------------------+
 //| Envelopes standard indicator                                     |
 //+------------------------------------------------------------------+
 class CIndEnvelopes : public CIndicatorDE
  {
   public:
                      CIndEnvelopes(const string symbol,const ENUM_TIMEFRAMES timeframe,MqlParam &mql_param[],CIndicatorTemplateManager *manager) :
                         CIndicatorDE(IND_ENVELOPES,symbol,timeframe,INDICATOR_STATUS_STANDARD,manager,
                                      "",mql_param) { this.m_object_type=OBJECT_DE_TYPE_IND_ENVELOPES; }
  };
#endif // CINDENVELOPES_MQH_DECLARATION
#endif // __INDENVELOPES_MQH__
