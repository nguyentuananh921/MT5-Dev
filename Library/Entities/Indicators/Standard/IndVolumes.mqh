//+------------------------------------------------------------------+
//|                                                   IndVolumes.mqh |
//|                        Copyright 2020, MetaQuotes Software Corp. |
//|                             https://mql5.com/en/users/artmedia70 |
//+------------------------------------------------------------------+
//--- Change from V1 Timeseries\Indicators\Standard\IndVolumes.mqh: the group and name come from the manager catalog; PrintParameters is CIndicatorDE's (by the schema)
//--- (by the schema). V4: the moving average of the volumes (params 1, 2 of the template) is a second handle of this object, buffer 1 of its values
//--- Change in V5: the moving average left (indicator on indicator: an MA on VOLUMES(TICK), CIndicatorDE::SetSource): Volumes is the standard one again, as V1
#ifndef __INDVOLUMES_MQH__
#define __INDVOLUMES_MQH__
 #include "..\IndicatorDE.mqh"
#ifndef CINDVOLUMES_MQH_DECLARATION
#define CINDVOLUMES_MQH_DECLARATION
 //+------------------------------------------------------------------+
 //| Volumes standard indicator                                       |
 //+------------------------------------------------------------------+
 class CIndVolumes : public CIndicatorDE
  {
   public:
                      CIndVolumes(const string symbol,const ENUM_TIMEFRAMES timeframe,MqlParam &mql_param[],CIndicatorTemplateManager *manager) :
                         CIndicatorDE(IND_VOLUMES,symbol,timeframe,INDICATOR_STATUS_STANDARD,manager,"",mql_param) { this.m_object_type=OBJECT_DE_TYPE_IND_VOLUMES; }
  };
#endif // CINDVOLUMES_MQH_DECLARATION
#endif // __INDVOLUMES_MQH__
