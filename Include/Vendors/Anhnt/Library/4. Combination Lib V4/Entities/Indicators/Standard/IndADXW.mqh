//+------------------------------------------------------------------+
//|                                                      IndADXW.mqh |
//|                        Copyright 2020, MetaQuotes Software Corp. |
//|                             https://mql5.com/en/users/artmedia70 |
//+------------------------------------------------------------------+
//--- Change from V1 Timeseries\Indicators\Standard\IndADXW.mqh: the group and the name are the catalog's (IndicatorDELib.mqh), PrintParameters is CIndicatorDE's (by the schema)
#ifndef __INDADXW_MQH__
#define __INDADXW_MQH__
 #include "..\IndicatorDE.mqh"
#ifndef CINDADXW_MQH_DECLARATION
#define CINDADXW_MQH_DECLARATION
 //+------------------------------------------------------------------+
 //| ADX by Welles Wilder standard indicator                          |
 //+------------------------------------------------------------------+
 class CIndADXW : public CIndicatorDE
  {
   public:
                      CIndADXW(const string symbol,const ENUM_TIMEFRAMES timeframe,MqlParam &mql_param[]) :
                         CIndicatorDE(IND_ADXW,symbol,timeframe,INDICATOR_STATUS_STANDARD,GetIndicatorGroupForType(IND_ADXW),GetIndicatorNameForType(IND_ADXW),
                                      "",mql_param) { this.m_object_type=OBJECT_DE_TYPE_IND_ADXW; }
  };
#endif // CINDADXW_MQH_DECLARATION
#endif // __INDADXW_MQH__
