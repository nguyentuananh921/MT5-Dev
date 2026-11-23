//+------------------------------------------------------------------+
//|                                                       IndATR.mqh |
//|                        Copyright 2020, MetaQuotes Software Corp. |
//|                             https://mql5.com/en/users/artmedia70 |
//+------------------------------------------------------------------+
//--- Change from V1 Timeseries\Indicators\Standard\IndATR.mqh: the group and name come from the manager catalog; PrintParameters is CIndicatorDE's (by the schema)
#ifndef __INDATR_MQH__
#define __INDATR_MQH__
 #include "..\IndicatorDE.mqh"
#ifndef CINDATR_MQH_DECLARATION
#define CINDATR_MQH_DECLARATION
 //+------------------------------------------------------------------+
 //| Average True Range standard indicator                            |
 //+------------------------------------------------------------------+
 class CIndATR : public CIndicatorDE
  {
   public:
                      CIndATR(const string symbol,const ENUM_TIMEFRAMES timeframe,MqlParam &mql_param[],CIndicatorTemplateManager *manager) :
                         CIndicatorDE(IND_ATR,symbol,timeframe,INDICATOR_STATUS_STANDARD,manager,
                                      "",mql_param) { this.m_object_type=OBJECT_DE_TYPE_IND_ATR; }
  };
#endif // CINDATR_MQH_DECLARATION
#endif // __INDATR_MQH__
