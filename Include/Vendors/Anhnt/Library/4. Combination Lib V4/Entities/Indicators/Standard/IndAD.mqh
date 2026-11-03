//+------------------------------------------------------------------+
//|                                                        IndAD.mqh |
//|                        Copyright 2020, MetaQuotes Software Corp. |
//|                             https://mql5.com/en/users/artmedia70 |
//+------------------------------------------------------------------+
//--- Change from V1 Timeseries\Indicators\Standard\IndAD.mqh: the group and the name are the catalog's (IndicatorDELib.mqh), PrintParameters is CIndicatorDE's (by the schema)
#ifndef __INDAD_MQH__
#define __INDAD_MQH__
 #include "..\IndicatorDE.mqh"
#ifndef CINDAD_MQH_DECLARATION
#define CINDAD_MQH_DECLARATION
 //+------------------------------------------------------------------+
 //| Accumulation/Distribution standard indicator                     |
 //+------------------------------------------------------------------+
 class CIndAD : public CIndicatorDE
  {
   public:
                      CIndAD(const string symbol,const ENUM_TIMEFRAMES timeframe,MqlParam &mql_param[]) :
                         CIndicatorDE(IND_AD,symbol,timeframe,INDICATOR_STATUS_STANDARD,GetIndicatorGroupForType(IND_AD),GetIndicatorNameForType(IND_AD),
                                      "",mql_param) { this.m_object_type=OBJECT_DE_TYPE_IND_AD; }
  };
#endif // CINDAD_MQH_DECLARATION
#endif // __INDAD_MQH__
