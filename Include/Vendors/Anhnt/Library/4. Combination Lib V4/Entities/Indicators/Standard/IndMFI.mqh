//+------------------------------------------------------------------+
//|                                                       IndMFI.mqh |
//|                        Copyright 2020, MetaQuotes Software Corp. |
//|                             https://mql5.com/en/users/artmedia70 |
//+------------------------------------------------------------------+
//--- Change from V1 Timeseries\Indicators\Standard\IndMFI.mqh: the group and name come from the manager catalog; PrintParameters is CIndicatorDE's (by the schema)
#ifndef __INDMFI_MQH__
#define __INDMFI_MQH__
 #include "..\IndicatorDE.mqh"
#ifndef CINDMFI_MQH_DECLARATION
#define CINDMFI_MQH_DECLARATION
 //+------------------------------------------------------------------+
 //| Money Flow Index standard indicator                              |
 //+------------------------------------------------------------------+
 class CIndMFI : public CIndicatorDE
  {
   public:
                      CIndMFI(const string symbol,const ENUM_TIMEFRAMES timeframe,MqlParam &mql_param[],CIndicatorTemplateManager *manager) :
                         CIndicatorDE(IND_MFI,symbol,timeframe,INDICATOR_STATUS_STANDARD,manager,
                                      "",mql_param) { this.m_object_type=OBJECT_DE_TYPE_IND_MFI; }
  };
#endif // CINDMFI_MQH_DECLARATION
#endif // __INDMFI_MQH__
