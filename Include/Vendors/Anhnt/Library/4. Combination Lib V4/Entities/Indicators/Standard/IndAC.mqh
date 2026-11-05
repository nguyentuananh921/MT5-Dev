//+------------------------------------------------------------------+
//|                                                        IndAC.mqh |
//|                        Copyright 2020, MetaQuotes Software Corp. |
//|                             https://mql5.com/en/users/artmedia70 |
//+------------------------------------------------------------------+
//--- Change from V1 Timeseries\Indicators\Standard\IndAC.mqh: the group and name come from the manager catalog; PrintParameters is CIndicatorDE's (by the schema)
#ifndef __INDAC_MQH__
#define __INDAC_MQH__
 #include "..\IndicatorDE.mqh"
#ifndef CINDAC_MQH_DECLARATION
#define CINDAC_MQH_DECLARATION
 //+------------------------------------------------------------------+
 //| Accelerator Oscillator standard indicator                        |
 //+------------------------------------------------------------------+
 class CIndAC : public CIndicatorDE
  {
   public:
                      CIndAC(const string symbol,const ENUM_TIMEFRAMES timeframe,MqlParam &mql_param[],CIndicatorTemplateManager *manager) :
                         CIndicatorDE(IND_AC,symbol,timeframe,INDICATOR_STATUS_STANDARD,manager.StandardIndicatorGroup(IND_AC),manager.StandardIndicatorName(IND_AC),
                                      "",mql_param) { this.m_object_type=OBJECT_DE_TYPE_IND_AC; }
  };
#endif // CINDAC_MQH_DECLARATION
#endif // __INDAC_MQH__
