//+------------------------------------------------------------------+
//|                                                       IndWPR.mqh |
//|                        Copyright 2020, MetaQuotes Software Corp. |
//|                             https://mql5.com/en/users/artmedia70 |
//+------------------------------------------------------------------+
//--- Change from V1 Timeseries\Indicators\Standard\IndWPR.mqh: the group and name come from the manager catalog; PrintParameters is CIndicatorDE's (by the schema)
#ifndef __INDWPR_MQH__
#define __INDWPR_MQH__
 #include "..\IndicatorDE.mqh"
#ifndef CINDWPR_MQH_DECLARATION
#define CINDWPR_MQH_DECLARATION
 //+------------------------------------------------------------------+
 //| Williams' Percent Range standard indicator                       |
 //+------------------------------------------------------------------+
 class CIndWPR : public CIndicatorDE
  {
   public:
                      CIndWPR(const string symbol,const ENUM_TIMEFRAMES timeframe,MqlParam &mql_param[],CIndicatorTemplateManager *manager) :
                         CIndicatorDE(IND_WPR,symbol,timeframe,INDICATOR_STATUS_STANDARD,manager,
                                      "",mql_param) { this.m_object_type=OBJECT_DE_TYPE_IND_WPR; }
  };
#endif // CINDWPR_MQH_DECLARATION
#endif // __INDWPR_MQH__
