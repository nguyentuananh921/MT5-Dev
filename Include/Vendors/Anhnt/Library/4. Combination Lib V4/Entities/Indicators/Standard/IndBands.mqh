//+------------------------------------------------------------------+
//|                                                     IndBands.mqh |
//|                        Copyright 2020, MetaQuotes Software Corp. |
//|                             https://mql5.com/en/users/artmedia70 |
//+------------------------------------------------------------------+
//--- Change from V1 Timeseries\Indicators\Standard\IndBands.mqh: the group and the name are the catalog's (IndicatorDELib.mqh), PrintParameters is CIndicatorDE's (by the schema)
#ifndef __INDBANDS_MQH__
#define __INDBANDS_MQH__
 #include "..\IndicatorDE.mqh"
#ifndef CINDBANDS_MQH_DECLARATION
#define CINDBANDS_MQH_DECLARATION
 //+------------------------------------------------------------------+
 //| Bollinger Bands® standard indicator                              |
 //+------------------------------------------------------------------+
 class CIndBands : public CIndicatorDE
  {
   public:
                      CIndBands(const string symbol,const ENUM_TIMEFRAMES timeframe,MqlParam &mql_param[]) :
                         CIndicatorDE(IND_BANDS,symbol,timeframe,INDICATOR_STATUS_STANDARD,GetIndicatorGroupForType(IND_BANDS),GetIndicatorNameForType(IND_BANDS),
                                      "",mql_param) { this.m_object_type=OBJECT_DE_TYPE_IND_BANDS; }
  };
#endif // CINDBANDS_MQH_DECLARATION
#endif // __INDBANDS_MQH__
