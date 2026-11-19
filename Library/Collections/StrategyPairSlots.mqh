//+------------------------------------------------------------------+
//|                                            StrategyPairSlots.mqh |
//|                                     Copyright 2026, Anhnt        |
//| The slots of a strategy on a pair (the port CStrategySlots of     |
//| UseCases): its indicator and its basic signal by the name of the |
//| slot, through the collections. New in V5 (was SlotIndicator /     |
//| SlotSignal of CStrategyCollection)                               |
//+------------------------------------------------------------------+
#ifndef __STRATEGYPAIRSLOTS_MQH__
#define __STRATEGYPAIRSLOTS_MQH__
 #include "..\UseCases\Strategies\StrategySlots.mqh"
 #include "Settings\StrategyManager.mqh"
 #include "IndicatorsCollection.mqh"
 #include "SignalsCollection.mqh"
#ifndef CSTRATEGYPAIRSLOTS_MQH_DECLARATION
#define CSTRATEGYPAIRSLOTS_MQH_DECLARATION
 class CStrategyPairSlots : public CStrategySlots
  {
   private:
    CIndicatorsCollection *m_IndicatorsCollection;   // the EA holds them
    CSignalsCollection    *m_SignalsCollection;
    CStrategyManager      *m_StrategyManager;
    CStrategySetting      *m_strategy;               // the strategy and the pair asked now
    string                 m_symbol;
    ENUM_TIMEFRAMES        m_timeframe;
   public:
                           CStrategyPairSlots(void) : m_IndicatorsCollection(NULL),m_SignalsCollection(NULL),m_StrategyManager(NULL),m_strategy(NULL),m_timeframe(PERIOD_CURRENT) {}
    void                   SetCollections(CIndicatorsCollection *indicators,CSignalsCollection *signals,CStrategyManager *manager)
                              { this.m_IndicatorsCollection=indicators; this.m_SignalsCollection=signals; this.m_StrategyManager=manager; }
    void                   SetPair(CStrategySetting *strategy,const string symbol,const ENUM_TIMEFRAMES timeframe)
                              { this.m_strategy=strategy; this.m_symbol=symbol; this.m_timeframe=timeframe; }
    virtual CIndicatorDE  *Indicator(const string slot);
    virtual CSignal       *Signal(const string slot);
  };
#endif // CSTRATEGYPAIRSLOTS_MQH_DECLARATION
#ifndef CSTRATEGYPAIRSLOTS_MQH_IMPLEMENTATION
#define CSTRATEGYPAIRSLOTS_MQH_IMPLEMENTATION
 CIndicatorDE *CStrategyPairSlots::Indicator(const string slot)
  {
   CStrategyIndicatorSetting *row=(this.m_strategy!=NULL ? this.m_strategy.Indicator(slot) : NULL);
   string params_text;
   if(row==NULL || this.m_IndicatorsCollection==NULL || this.m_StrategyManager==NULL || !this.m_StrategyManager.Read_RAM(row,params_text))
      return NULL;
   return this.m_IndicatorsCollection.GetIndicator((ENUM_INDICATOR)row.SourceId(),params_text,this.m_symbol,this.m_timeframe);
  }
 CSignal *CStrategyPairSlots::Signal(const string slot)
  {
   CStrategyIndicatorSetting *row=(this.m_strategy!=NULL ? this.m_strategy.Indicator(slot) : NULL);
   string params_text;
   if(row==NULL || this.m_SignalsCollection==NULL || this.m_StrategyManager==NULL || !this.m_StrategyManager.Read_RAM(row,params_text))
      return NULL;
   return this.m_SignalsCollection.GetSeries((ENUM_INDICATOR)row.SourceId(),params_text,this.m_symbol,this.m_timeframe);
  }
#endif // CSTRATEGYPAIRSLOTS_MQH_IMPLEMENTATION
#endif // __STRATEGYPAIRSLOTS_MQH__
