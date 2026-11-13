//+------------------------------------------------------------------+
//|                                     StrategyIndicatorSetting.mqh |
//|                                     Copyright 2026, Anhnt        |
//| 1 instance = 1 row of Setting_StrategyIndicator (a slot of a     |
//| strategy: the source it reads, on which tf, with which params)   |
//| New in V5                                                        |
//+------------------------------------------------------------------+
#ifndef __STRATEGYINDICATORSETTING_MQH__
#define __STRATEGYINDICATORSETTING_MQH__
 #include "..\..\Bases\BaseObj.mqh"
 #include "..\..\Defines\CommonDefines.mqh"
#ifndef CSTRATEGYINDICATORSETTING_MQH_DECLARATION
#define CSTRATEGYINDICATORSETTING_MQH_DECLARATION
 class CStrategyIndicatorSetting : public CBaseObj
  {
    private:
     ENUM_OBJECT_DE_TYPE        m_collection;      // COLLECTION_SIGNALS_ID: source_id = indicators.type_enum, COLLECTION_SERIES_ID: Setting_BarInformation.type_infor
     long                       m_source_id;
     ENUM_TIMEFRAMES            m_tf;              // PERIOD_CURRENT (NULL in the table, Default): the tf of the strategy
     string                     m_params;          // "" (NULL in the table): the params of indicators
    public:
                                CStrategyIndicatorSetting(const string slot,const ENUM_OBJECT_DE_TYPE collection,const long source_id,const ENUM_TIMEFRAMES tf,const string params);
                               ~CStrategyIndicatorSetting(void) {}
     string                     Slot(void)            const { return m_name;          }   // the name the conditions use for this source
     ENUM_OBJECT_DE_TYPE        Collection(void)      const { return m_collection;    }
     long                       SourceId(void)        const { return m_source_id;     }
     ENUM_TIMEFRAMES            Timeframe(void)       const { return m_tf;            }
     string                     Params(void)          const { return m_params;        }
   //--- The params and the tf the user set (CStrategyManager writes them to the table first)
     void                       Params(const string params,const ENUM_TIMEFRAMES tf) { m_params=params; m_tf=tf; }
  };
#endif // CSTRATEGYINDICATORSETTING_MQH_DECLARATION
#ifndef CSTRATEGYINDICATORSETTING_MQH_IMPLEMENTATION
#define CSTRATEGYINDICATORSETTING_MQH_IMPLEMENTATION
 CStrategyIndicatorSetting::CStrategyIndicatorSetting(const string slot,const ENUM_OBJECT_DE_TYPE collection,const long source_id,const ENUM_TIMEFRAMES tf,const string params) :
                                                      m_collection(collection),m_source_id(source_id),m_tf(tf),m_params(params)
  {
   this.m_object_type=OBJECT_DE_TYPE_STRATEGY_INDICATOR_SETTING;
   this.m_name=slot;
  }
#endif // CSTRATEGYINDICATORSETTING_MQH_IMPLEMENTATION
#endif // __STRATEGYINDICATORSETTING_MQH__
