//+------------------------------------------------------------------+
//|                                                       IndADX.mqh |
//|                        Copyright 2020, MetaQuotes Software Corp. |
//|                             https://mql5.com/en/users/artmedia70 |
//+------------------------------------------------------------------+
//--- Change from V1 Timeseries\Indicators\Standard\IndADX.mqh: the group and name come from the manager catalog; PrintParameters is CIndicatorDE's (by the schema)
#ifndef __INDADX_MQH__
#define __INDADX_MQH__
 #include "..\IndicatorDE.mqh"
#ifndef CINDADX_MQH_DECLARATION
#define CINDADX_MQH_DECLARATION
 //+------------------------------------------------------------------+
 //| Average Directional Index standard indicator                     |
 //+------------------------------------------------------------------+
 class CIndADX : public CIndicatorDE
  {
   public:
                      CIndADX(const string symbol,const ENUM_TIMEFRAMES timeframe,MqlParam &mql_param[],CIndicatorTemplateManager *manager) :
                         CIndicatorDE(IND_ADX,symbol,timeframe,INDICATOR_STATUS_STANDARD,manager,
                                      "",mql_param) { this.m_object_type=OBJECT_DE_TYPE_IND_ADX; }
  };
#endif // CINDADX_MQH_DECLARATION
#endif // __INDADX_MQH__
