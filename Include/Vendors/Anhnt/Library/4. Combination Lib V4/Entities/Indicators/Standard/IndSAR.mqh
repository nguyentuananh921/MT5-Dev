//+------------------------------------------------------------------+
//|                                                       IndSAR.mqh |
//|                        Copyright 2020, MetaQuotes Software Corp. |
//|                             https://mql5.com/en/users/artmedia70 |
//+------------------------------------------------------------------+
//--- Change from V1 Timeseries\Indicators\Standard\IndSAR.mqh: the group and name come from the manager catalog; PrintParameters is CIndicatorDE's (by the schema)
#ifndef __INDSAR_MQH__
#define __INDSAR_MQH__
 #include "..\IndicatorDE.mqh"
#ifndef CINDSAR_MQH_DECLARATION
#define CINDSAR_MQH_DECLARATION
 //+------------------------------------------------------------------+
 //| Parabolic SAR standard indicator                                 |
 //+------------------------------------------------------------------+
 class CIndSAR : public CIndicatorDE
  {
   public:
                      CIndSAR(const string symbol,const ENUM_TIMEFRAMES timeframe,MqlParam &mql_param[],CIndicatorTemplateManager *manager) :
                         CIndicatorDE(IND_SAR,symbol,timeframe,INDICATOR_STATUS_STANDARD,manager.StandardIndicatorGroup(IND_SAR),manager.StandardIndicatorName(IND_SAR),
                                      "",mql_param) { this.m_object_type=OBJECT_DE_TYPE_IND_SAR; }
  };
#endif // CINDSAR_MQH_DECLARATION
#endif // __INDSAR_MQH__
