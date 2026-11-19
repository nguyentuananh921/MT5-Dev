//+------------------------------------------------------------------+
//|                                          Setting_MACrossover.mqh |
//|                                     Copyright 2026, Anhnt        |
//| The strategy MA Crossover: Entry only (SMA 10 crosses SMA 20 on  |
//| the bar that just closed), as its source EA                      |
//| Solomon Anietie Sunday\Risk Management\7. 24477                  |
//| FixedMACrossover_Part7.mq5 (ReadSignal). Its SL / TP (ATR x 1.5, |
//| x 2) are other strategies (Concept.md ## Strategy)               |
//| New in V5: CStrategyManager writes it to the tables              |
//+------------------------------------------------------------------+
#ifndef __SETTING_MACROSSOVER_MQH__
#define __SETTING_MACROSSOVER_MQH__
 #include "StrategySetting.mqh"
#ifndef CSETTING_MACROSSOVER_MQH_DECLARATION
#define CSETTING_MACROSSOVER_MQH_DECLARATION
 class CSetting_MACrossover : public CStrategySetting
  {
    public:
                                CSetting_MACrossover(void);
                               ~CSetting_MACrossover(void) {}
  };
#endif // CSETTING_MACROSSOVER_MQH_DECLARATION
#ifndef CSETTING_MACROSSOVER_MQH_IMPLEMENTATION
#define CSETTING_MACROSSOVER_MQH_IMPLEMENTATION
 CSetting_MACrossover::CSetting_MACrossover(void) : CStrategySetting(2, "MA Crossover", "24477 FixedMACrossover_Part7 (Solomon Anietie Sunday, Risk Management)", PERIOD_CURRENT)   // _Period of the source EA
  {
   //--- The slots: iMA(_Symbol,_Period,FastMA,0,MODE_SMA,PRICE_CLOSE) and the same with SlowMA (inputs 10, 20)
   this.AddIndicator("FastMA", COLLECTION_SIGNALS_ID, (long)IND_MA, PERIOD_CURRENT, "10,0,SMA,CLOSE");
   this.AddIndicator("SlowMA", COLLECTION_SIGNALS_ID, (long)IND_MA, PERIOD_CURRENT, "20,0,SMA,CLOSE");   // the slot rule ma_cross compares with
   //--- ReadSignal: fast[1] > slow[1] && fast[2] <= slow[2] = BUY, the other way = SELL; no exit (the SL / TP close)
   this.AddCondition("entry", SIGNAL_DIRECTION_BUY,  "FastMA", "ma_cross");
   this.AddCondition("entry", SIGNAL_DIRECTION_SELL, "FastMA", "ma_cross");
  }
#endif // CSETTING_MACROSSOVER_MQH_IMPLEMENTATION
#endif // __SETTING_MACROSSOVER_MQH__
