//+------------------------------------------------------------------+
//|                                                        IndMA.mqh |
//|                        Copyright 2020, MetaQuotes Software Corp. |
//|                             https://mql5.com/en/users/artmedia70 |
//+------------------------------------------------------------------+
//--- Change from V1 Timeseries\Indicators\Standard\IndMA.mqh: the group and the name are the catalog's (IndicatorDELib.mqh), PrintParameters is CIndicatorDE's (by the schema)
#ifndef __INDMA_MQH__
#define __INDMA_MQH__
 #include "..\IndicatorDE.mqh"
#ifndef CINDMA_MQH_DECLARATION
#define CINDMA_MQH_DECLARATION
 //+------------------------------------------------------------------+
 //| Moving Average standard indicator                                |
 //+------------------------------------------------------------------+
 class CIndMA : public CIndicatorDE
  {
   public:
                      CIndMA(const string symbol,const ENUM_TIMEFRAMES timeframe,MqlParam &mql_param[]) :
                         CIndicatorDE(IND_MA,symbol,timeframe,INDICATOR_STATUS_STANDARD,GetIndicatorGroupForType(IND_MA),GetIndicatorNameForType(IND_MA),
                                      "",mql_param) { this.m_type=OBJECT_DE_TYPE_IND_MA; }
  };
#endif // CINDMA_MQH_DECLARATION
#endif // __INDMA_MQH__
