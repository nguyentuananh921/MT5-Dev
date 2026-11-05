//+------------------------------------------------------------------+
//|                                                   IndVolumes.mqh |
//|                        Copyright 2020, MetaQuotes Software Corp. |
//|                             https://mql5.com/en/users/artmedia70 |
//+------------------------------------------------------------------+
//--- Change from V1 Timeseries\Indicators\Standard\IndVolumes.mqh: the group and name come from the manager catalog; PrintParameters is CIndicatorDE's (by the schema)
//--- (by the schema). V4: the moving average of the volumes (params 1, 2 of the template) is a second handle of this object, buffer 1 of its values
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
   private:
    int               m_handle_average;               // The moving average on the volumes: only this object releases it
   public:
    int               HandleAverage(void)       const { return this.m_handle_average; }
                      CIndVolumes(const string symbol,const ENUM_TIMEFRAMES timeframe,MqlParam &mql_param[],CIndicatorTemplateManager *manager);
                     ~CIndVolumes(void);
  };
#endif // CINDVOLUMES_MQH_DECLARATION
#ifndef CINDVOLUMES_MQH_IMPLEMENTATION
#define CINDVOLUMES_MQH_IMPLEMENTATION
 CIndVolumes::CIndVolumes(const string symbol,const ENUM_TIMEFRAMES timeframe,MqlParam &mql_param[],CIndicatorTemplateManager *manager) :
    CIndicatorDE(IND_VOLUMES,symbol,timeframe,INDICATOR_STATUS_STANDARD,manager.StandardIndicatorGroup(IND_VOLUMES),manager.StandardIndicatorName(IND_VOLUMES),
                 "",mql_param),m_handle_average(INVALID_HANDLE)
  {
   this.m_object_type=OBJECT_DE_TYPE_IND_VOLUMES;
   if(this.Handle()!=INVALID_HANDLE && ::ArraySize(mql_param)>2)
      this.m_handle_average=::iMA(this.Symbol(),timeframe,(int)mql_param[1].integer_value,0,(ENUM_MA_METHOD)mql_param[2].integer_value,this.Handle());
   this.m_series_data.SetIndicator(this.Symbol(),timeframe,IND_VOLUMES,this.Handle(),this.m_handle_average,this.BuffersTotal());
  }
 CIndVolumes::~CIndVolumes(void)
  {
   if(this.m_handle_average!=INVALID_HANDLE)
      ::IndicatorRelease(this.m_handle_average);
  }
#endif // CINDVOLUMES_MQH_IMPLEMENTATION
#endif // __INDVOLUMES_MQH__
