//+------------------------------------------------------------------+
//|                                                     IndStDev.mqh |
//|                        Copyright 2020, MetaQuotes Software Corp. |
//|                             https://mql5.com/en/users/artmedia70 |
//+------------------------------------------------------------------+
//--- Change from V1 Timeseries\Indicators\Standard\IndStDev.mqh: the group and the name are the catalog's (IndicatorDELib.mqh), PrintParameters is CIndicatorDE's (by the schema)
#ifndef __INDSTDEV_MQH__
#define __INDSTDEV_MQH__
 #include "..\IndicatorDE.mqh"
#ifndef CINDSTDEV_MQH_DECLARATION
#define CINDSTDEV_MQH_DECLARATION
 //+------------------------------------------------------------------+
 //| Standard Deviation standard indicator                            |
 //+------------------------------------------------------------------+
 class CIndStDev : public CIndicatorDE
  {
   public:
                      CIndStDev(const string symbol,const ENUM_TIMEFRAMES timeframe,MqlParam &mql_param[]) :
                         CIndicatorDE(IND_STDDEV,symbol,timeframe,INDICATOR_STATUS_STANDARD,GetIndicatorGroupForType(IND_STDDEV),GetIndicatorNameForType(IND_STDDEV),
                                      "",mql_param) { this.m_object_type=OBJECT_DE_TYPE_IND_STDEV; }
  };
#endif // CINDSTDEV_MQH_DECLARATION
#endif // __INDSTDEV_MQH__
