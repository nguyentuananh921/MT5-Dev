//+------------------------------------------------------------------+
//|                                                       IndOBV.mqh |
//|                        Copyright 2020, MetaQuotes Software Corp. |
//|                             https://mql5.com/en/users/artmedia70 |
//+------------------------------------------------------------------+
//--- Change from V1 Timeseries\Indicators\Standard\IndOBV.mqh: the group and name come from the manager catalog; PrintParameters is CIndicatorDE's (by the schema)
#ifndef __INDOBV_MQH__
#define __INDOBV_MQH__
 #include "..\IndicatorDE.mqh"
#ifndef CINDOBV_MQH_DECLARATION
#define CINDOBV_MQH_DECLARATION
 //+------------------------------------------------------------------+
 //| On Balance Volume standard indicator                             |
 //+------------------------------------------------------------------+
 class CIndOBV : public CIndicatorDE
  {
   public:
                      CIndOBV(const string symbol,const ENUM_TIMEFRAMES timeframe,MqlParam &mql_param[],CIndicatorTemplateManager *manager) :
                         CIndicatorDE(IND_OBV,symbol,timeframe,INDICATOR_STATUS_STANDARD,manager.StandardIndicatorGroup(IND_OBV),manager.StandardIndicatorName(IND_OBV),
                                      "",mql_param) { this.m_object_type=OBJECT_DE_TYPE_IND_OBV; }
  };
#endif // CINDOBV_MQH_DECLARATION
#endif // __INDOBV_MQH__
