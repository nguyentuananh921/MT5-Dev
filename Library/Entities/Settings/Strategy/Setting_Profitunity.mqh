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
 CSetting_Profitunity::CSetting_Profitunity(void) : CStrategySetting(1, "Profitunity", "01. 16365 PROFITUNITY (TRADING CHAOS BY BILL WILLIAMS)")   // the slots PERIOD_CURRENT: _Period of the source EA
  {
   //--- The slots: the indicators of OnInit of the source EA, on the tf of the strategy
   this.AddIndicator("Fractals",  COLLECTION_SIGNALS_ID, (long)IND_FRACTALS,  PERIOD_CURRENT, "");
   this.AddIndicator("Alligator", COLLECTION_SIGNALS_ID, (long)IND_ALLIGATOR, PERIOD_CURRENT, "13,8,8,5,5,3,SMMA,MEDIAN");   // iAlligator(_Symbol,_Period,13,8,8,5,5,3,MODE_SMMA,PRICE_MEDIAN)
   this.AddIndicator("AO",        COLLECTION_SIGNALS_ID, (long)IND_AO,        PERIOD_CURRENT, "");
   this.AddIndicator("AC",        COLLECTION_SIGNALS_ID, (long)IND_AC,        PERIOD_CURRENT, "");
   //--- The conditions of OnTick of the source EA. Rule "signal": the basic signal of the indicator (CSignalsCollection, its judge): the strategy reads
   //--- its CSignal (DirectionAt), never judges it again; Python (Strategy\engine.py) takes the flips of signals.directions of the same type. Any other rule is the strategy's own
   //--- (here last_fractal, close_cross_jaw and rising differ from CSignalFractals, CSignalTwoLineCross and CSignalZeroCross of their indicators)
   // lastFractal_direction from shift 3 on purpose: 
   // the source EA reads fractals_up[0] = shift 2, always EMPTY_VALUE 
   // (MT5 Fractals.mq5:70 sets shift >= 3: two closed bars on the right), 
   // so it never trades
    this.AddCondition("entry", SIGNAL_DIRECTION_BUY,  "Fractals",  "last_fractal");  
   this.AddCondition("entry", SIGNAL_DIRECTION_BUY,  "Alligator", "close_cross_jaw");   // isBreakdown_jaws_buy
   this.AddCondition("entry", SIGNAL_DIRECTION_BUY,  "AC",        "rising");            // ac_color: AC >= the bar before (the colour is only how MT5 draws it)
   this.AddCondition("entry", SIGNAL_DIRECTION_BUY,  "AO",        "signal");            // ao[1] > 0 && ao[2] < 0: CSignalZeroCross of AO (before <= 0: only an AO of exactly 0 differs)
   this.AddCondition("entry", SIGNAL_DIRECTION_SELL, "Fractals",  "last_fractal");
   this.AddCondition("entry", SIGNAL_DIRECTION_SELL, "Alligator", "close_cross_jaw");
   this.AddCondition("entry", SIGNAL_DIRECTION_SELL, "AC",        "rising");
   this.AddCondition("entry", SIGNAL_DIRECTION_SELL, "AO",        "signal");
   this.AddCondition("exit",  SIGNAL_DIRECTION_SELL, "AO",        "signal");   // an AO SELL closes a BUY
   this.AddCondition("exit",  SIGNAL_DIRECTION_BUY,  "AO",        "signal");   // an AO BUY closes a SELL
  }
#endif // CSETTING_PROFITUNITY_MQH_IMPLEMENTATION
#endif // __SETTING_PROFITUNITY_MQH__
