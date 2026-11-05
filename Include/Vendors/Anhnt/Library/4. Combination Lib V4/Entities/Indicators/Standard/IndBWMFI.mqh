//+------------------------------------------------------------------+
//|                                                     IndBWMFI.mqh |
//|                        Copyright 2020, MetaQuotes Software Corp. |
//|                             https://mql5.com/en/users/artmedia70 |
//+------------------------------------------------------------------+
//--- Change from V1 Timeseries\Indicators\Standard\IndBWMFI.mqh: the group and name come from the manager catalog; PrintParameters is CIndicatorDE's (by the schema)
#ifndef __INDBWMFI_MQH__
#define __INDBWMFI_MQH__
 #include "..\IndicatorDE.mqh"
#ifndef CINDBWMFI_MQH_DECLARATION
#define CINDBWMFI_MQH_DECLARATION
 //+------------------------------------------------------------------+
 //| Market Facilitation Index standard indicator                     |
 //+------------------------------------------------------------------+
 class CIndBWMFI : public CIndicatorDE
  {
   public:
                      CIndBWMFI(const string symbol,const ENUM_TIMEFRAMES timeframe,MqlParam &mql_param[],CIndicatorTemplateManager *manager) :
                         CIndicatorDE(IND_BWMFI,symbol,timeframe,INDICATOR_STATUS_STANDARD,manager.StandardIndicatorGroup(IND_BWMFI),manager.StandardIndicatorName(IND_BWMFI),
                                      "",mql_param) { this.m_object_type=OBJECT_DE_TYPE_IND_BWMFI; }
  };
#endif // CINDBWMFI_MQH_DECLARATION
#endif // __INDBWMFI_MQH__
