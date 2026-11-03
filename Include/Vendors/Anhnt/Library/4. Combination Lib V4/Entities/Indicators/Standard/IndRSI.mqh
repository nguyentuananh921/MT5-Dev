//+------------------------------------------------------------------+
//|                                                       IndRSI.mqh |
//|                        Copyright 2020, MetaQuotes Software Corp. |
//|                             https://mql5.com/en/users/artmedia70 |
//+------------------------------------------------------------------+
//--- Change from V1 Timeseries\Indicators\Standard\IndRSI.mqh: the group and the name are the catalog's (IndicatorDELib.mqh), PrintParameters is CIndicatorDE's (by the schema)
#ifndef __INDRSI_MQH__
#define __INDRSI_MQH__
 #include "..\IndicatorDE.mqh"
#ifndef CINDRSI_MQH_DECLARATION
#define CINDRSI_MQH_DECLARATION
 //+------------------------------------------------------------------+
 //| Relative Strength Index standard indicator                       |
 //+------------------------------------------------------------------+
 class CIndRSI : public CIndicatorDE
  {
   public:
                      CIndRSI(const string symbol,const ENUM_TIMEFRAMES timeframe,MqlParam &mql_param[]) :
                         CIndicatorDE(IND_RSI,symbol,timeframe,INDICATOR_STATUS_STANDARD,GetIndicatorGroupForType(IND_RSI),GetIndicatorNameForType(IND_RSI),
                                      "",mql_param) { this.m_object_type=OBJECT_DE_TYPE_IND_RSI; }
  };
#endif // CINDRSI_MQH_DECLARATION
#endif // __INDRSI_MQH__
