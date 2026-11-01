//+------------------------------------------------------------------+
//|                                                     IndForce.mqh |
//|                        Copyright 2020, MetaQuotes Software Corp. |
//|                             https://mql5.com/en/users/artmedia70 |
//+------------------------------------------------------------------+
//--- Change from V1 Timeseries\Indicators\Standard\IndForce.mqh: the group and the name are the catalog's (IndicatorDELib.mqh), PrintParameters is CIndicatorDE's (by the schema)
#ifndef __INDFORCE_MQH__
#define __INDFORCE_MQH__
 #include "..\IndicatorDE.mqh"
#ifndef CINDFORCE_MQH_DECLARATION
#define CINDFORCE_MQH_DECLARATION
 //+------------------------------------------------------------------+
 //| Force Index standard indicator                                   |
 //+------------------------------------------------------------------+
 class CIndForce : public CIndicatorDE
  {
   public:
                      CIndForce(const string symbol,const ENUM_TIMEFRAMES timeframe,MqlParam &mql_param[]) :
                         CIndicatorDE(IND_FORCE,symbol,timeframe,INDICATOR_STATUS_STANDARD,GetIndicatorGroupForType(IND_FORCE),GetIndicatorNameForType(IND_FORCE),
                                      "",mql_param) { this.m_type=OBJECT_DE_TYPE_IND_FORCE; }
  };
#endif // CINDFORCE_MQH_DECLARATION
#endif // __INDFORCE_MQH__
