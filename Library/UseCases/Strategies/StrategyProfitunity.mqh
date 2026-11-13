//+------------------------------------------------------------------+
//|                                          StrategyProfitunity.mqh |
//|                                     Copyright 2026, Anhnt        |
//| The rule of Profitunity on RAM, as its source EA (Allan Munene   |
//| Mutiiria\Automating Trading Strategies\01. 16365) and line by    |
//| line as Library\Python\Strategy\Profitunity.py (the same names): |
//| the bar that just closed (shift 1 of the source EA, the one      |
//| before it shift 2), the values of the CIndicatorDE of its slots  |
//| New in V5                                                         |
//+------------------------------------------------------------------+
#ifndef __STRATEGYPROFITUNITY_MQH__
#define __STRATEGYPROFITUNITY_MQH__
 #include "..\..\Entities\Indicators\IndicatorDE.mqh"
 #define PROFITUNITY_NAME           "Profitunity"   // Setting_Strategy.name (CSetting_Profitunity), Profitunity.NAME
 #define PROFITUNITY_FRACTAL_BACK   500             // the bars looked back for the newest fractal (Profitunity.CONTEXT)
#ifndef CSTRATEGYPROFITUNITY_MQH_DECLARATION
#define CSTRATEGYPROFITUNITY_MQH_DECLARATION
 class CStrategyProfitunity
  {
   private:
    static bool       Known(const double value)          { return (value!=EMPTY_VALUE && value!=0.0 && ::MathIsValidNumber(value)); }
   //--- lastFractal_direction at the bar: the newest fractal known 2 bars after its middle, a down one of the same bar wins (+1 down, -1 up, 0 none)
    static int        LastFractal(CIndicatorDE *fractals,const string symbol,const ENUM_TIMEFRAMES timeframe,const int shift);
   public:
   //--- The moves of the bar at the shift (1: the one that just closed): the roles ("entry" / "exit") and the sides (BUY / SELL: opened or closed).
   //--- buys / sells: the positions open before it (the EA opens one at each signal). Returns how many moves, WRONG_VALUE when a value is not on RAM yet
    static int        Calculate(CIndicatorDE *fractals,CIndicatorDE *alligator,CIndicatorDE *ao,CIndicatorDE *ac,const string symbol,const ENUM_TIMEFRAMES timeframe,
                                const int shift,const int buys,const int sells,string &roles[],ENUM_SIGNAL_DIRECTION &sides[]);
  };
#endif // CSTRATEGYPROFITUNITY_MQH_DECLARATION
#ifndef CSTRATEGYPROFITUNITY_MQH_IMPLEMENTATION
#define CSTRATEGYPROFITUNITY_MQH_IMPLEMENTATION
 int CStrategyProfitunity::LastFractal(CIndicatorDE *fractals,const string symbol,const ENUM_TIMEFRAMES timeframe,const int shift)
  {
   for(int middle=shift+2;middle<shift+2+PROFITUNITY_FRACTAL_BACK;middle++)
     {
      const datetime time=::iTime(symbol,timeframe,middle);
      if(time==0)
         return 0;
      if(Known(fractals.Value(1,time)))
         return 1;    // FRACTAL_DOWN
      if(Known(fractals.Value(0,time)))
         return -1;   // FRACTAL_UP
     }
   return 0;          // FRACTAL_NEUTRAL
  }
 int CStrategyProfitunity::Calculate(CIndicatorDE *fractals,CIndicatorDE *alligator,CIndicatorDE *ao,CIndicatorDE *ac,const string symbol,const ENUM_TIMEFRAMES timeframe,
                                     const int shift,const int buys,const int sells,string &roles[],ENUM_SIGNAL_DIRECTION &sides[])
  {
   ::ArrayResize(roles,0);
   ::ArrayResize(sides,0);
   if(fractals==NULL || alligator==NULL || ao==NULL || ac==NULL)
      return WRONG_VALUE;
   const datetime t1=::iTime(symbol,timeframe,shift),t2=::iTime(symbol,timeframe,shift+1);
   const double jaw1=alligator.Value(0,t1),jaw2=alligator.Value(0,t2);
   const double ao1=ao.Value(0,t1),ao2=ao.Value(0,t2);
   const double ac1=ac.Value(0,t1),ac2=ac.Value(0,t2);
   if(t1==0 || t2==0 || !Known(jaw1) || !Known(jaw2) || ao1==EMPTY_VALUE || ao2==EMPTY_VALUE || ac1==EMPTY_VALUE || ac2==EMPTY_VALUE)
      return WRONG_VALUE;   // RAM has not the values of the bars yet
   const double close1=::iClose(symbol,timeframe,shift),close2=::iClose(symbol,timeframe,shift+1);
   const int  last_fractal=LastFractal(fractals,symbol,timeframe,shift);
   const bool breakdown_buy=(jaw1<close1 && jaw2>close2);
   const bool breakdown_sell=(jaw1>close1 && jaw2<close2);
   const bool ac_up=(ac1>=ac2),ac_down=(ac1<ac2);
   const bool ao_up=(ao1>0 && ao2<0),ao_down=(ao1<0 && ao2>0);
   string role[4];
   ENUM_SIGNAL_DIRECTION side[4];
   int moves=0;
   if(last_fractal==1 && breakdown_buy && ac_up && ao_up)
     {
      role[moves]="entry";
      side[moves++]=SIGNAL_DIRECTION_BUY;
     }
   else if(last_fractal==-1 && breakdown_sell && ac_down && ao_down)
     {
      role[moves]="entry";
      side[moves++]=SIGNAL_DIRECTION_SELL;
     }
   const int open_buys=buys+(moves>0 && side[0]==SIGNAL_DIRECTION_BUY ? 1 : 0);
   const int open_sells=sells+(moves>0 && side[0]==SIGNAL_DIRECTION_SELL ? 1 : 0);
   if(ao_down && open_buys>0)
     {
      role[moves]="exit";
      side[moves++]=SIGNAL_DIRECTION_BUY;
     }
   else if(ao_up && open_sells>0)
     {
      role[moves]="exit";
      side[moves++]=SIGNAL_DIRECTION_SELL;
     }
   ::ArrayResize(roles,moves);
   ::ArrayResize(sides,moves);
   for(int i=0;i<moves;i++)
     {
      roles[i]=role[i];
      sides[i]=side[i];
     }
   return moves;
  }
#endif // CSTRATEGYPROFITUNITY_MQH_IMPLEMENTATION
#endif // __STRATEGYPROFITUNITY_MQH__
