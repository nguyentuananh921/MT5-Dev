//+------------------------------------------------------------------+
//|                                                  IndFractals.mqh |
//|                        Copyright 2020, MetaQuotes Software Corp. |
//|                             https://mql5.com/en/users/artmedia70 |
//+------------------------------------------------------------------+
//--- Change from V1 Timeseries\Indicators\Standard\IndFractals.mqh: the group and the name are the catalog's (IndicatorDELib.mqh), PrintParameters is CIndicatorDE's (by the schema)
#ifndef __INDFRACTALS_MQH__
#define __INDFRACTALS_MQH__
 #include "..\IndicatorDE.mqh"
#ifndef CINDFRACTALS_MQH_DECLARATION
#define CINDFRACTALS_MQH_DECLARATION
 //+------------------------------------------------------------------+
 //| Fractals standard indicator                                      |
 //+------------------------------------------------------------------+
 class CIndFractals : public CIndicatorDE
  {
   public:
                      CIndFractals(const string symbol,const ENUM_TIMEFRAMES timeframe,MqlParam &mql_param[]) :
                         CIndicatorDE(IND_FRACTALS,symbol,timeframe,INDICATOR_STATUS_STANDARD,GetIndicatorGroupForType(IND_FRACTALS),GetIndicatorNameForType(IND_FRACTALS),
                                      "",mql_param) { this.m_type=OBJECT_DE_TYPE_IND_FRACTALS; }
  };
#endif // CINDFRACTALS_MQH_DECLARATION
#endif // __INDFRACTALS_MQH__
