//+------------------------------------------------------------------+
//|                                          Setting_Profitunity.mqh |
//|                                     Copyright 2026, Anhnt        |
//| The strategy Profitunity (Trading Chaos, Bill Williams): its tf, |
//| its slots with the params of their indicators and its            |
//| conditions, as its source EA                                     |
//| Allan Munene Mutiiria\Automating Trading Strategies\01. 16365    |
//| New in V5: CStrategyManager writes it to the tables              |
//+------------------------------------------------------------------+
#ifndef __SETTING_PROFITUNITY_MQH__
#define __SETTING_PROFITUNITY_MQH__
 #include "StrategySetting.mqh"
#ifndef CSETTING_PROFITUNITY_MQH_DECLARATION
#define CSETTING_PROFITUNITY_MQH_DECLARATION
 class CSetting_Profitunity : public CStrategySetting
  {
    public:
                                CSetting_Profitunity(void);
                               ~CSetting_Profitunity(void) {}
  };
#endif // CSETTING_PROFITUNITY_MQH_DECLARATION
#ifndef CSETTING_PROFITUNITY_MQH_IMPLEMENTATION
#define CSETTING_PROFITUNITY_MQH_IMPLEMENTATION
 CSetting_Profitunity::CSetting_Profitunity(void) : CStrategySetting(1, "Profitunity", "01. 16365 PROFITUNITY (TRADING CHAOS BY BILL WILLIAMS)", PERIOD_CURRENT)   // not set: the tf of the chart (_Period of the source EA)
  {
   //--- The slots: the indicators of OnInit of the source EA, on the tf of the strategy
   this.AddIndicator("Fractals",  COLLECTION_SIGNALS_ID, (long)IND_FRACTALS,  PERIOD_CURRENT, "");
   this.AddIndicator("Alligator", COLLECTION_SIGNALS_ID, (long)IND_ALLIGATOR, PERIOD_CURRENT, "13,8,8,5,5,3,SMMA,MEDIAN");   // iAlligator(_Symbol,_Period,13,8,8,5,5,3,MODE_SMMA,PRICE_MEDIAN)
   this.AddIndicator("AO",        COLLECTION_SIGNALS_ID, (long)IND_AO,        PERIOD_CURRENT, "");
   this.AddIndicator("AC",        COLLECTION_SIGNALS_ID, (long)IND_AC,        PERIOD_CURRENT, "");
   //--- The conditions of OnTick of the source EA
   this.AddCondition("entry", SIGNAL_DIRECTION_BUY,  "Fractals",  "last_fractal");      // lastFractal_direction
   this.AddCondition("entry", SIGNAL_DIRECTION_BUY,  "Alligator", "close_cross_jaw");   // isBreakdown_jaws_buy
   this.AddCondition("entry", SIGNAL_DIRECTION_BUY,  "AC",        "color");             // ac_color
   this.AddCondition("entry", SIGNAL_DIRECTION_BUY,  "AO",        "signal");
   this.AddCondition("entry", SIGNAL_DIRECTION_SELL, "Fractals",  "last_fractal");
   this.AddCondition("entry", SIGNAL_DIRECTION_SELL, "Alligator", "close_cross_jaw");
   this.AddCondition("entry", SIGNAL_DIRECTION_SELL, "AC",        "color");
   this.AddCondition("entry", SIGNAL_DIRECTION_SELL, "AO",        "signal");
   this.AddCondition("exit",  SIGNAL_DIRECTION_SELL, "AO",        "signal");   // an AO SELL closes a BUY
   this.AddCondition("exit",  SIGNAL_DIRECTION_BUY,  "AO",        "signal");   // an AO BUY closes a SELL
  }
#endif // CSETTING_PROFITUNITY_MQH_IMPLEMENTATION
#endif // __SETTING_PROFITUNITY_MQH__
