//+------------------------------------------------------------------+
//|                                             CommonDELib.mqh      |
//|                         Copyright 2020, MetaQuotes Software Corp.|
//| Lib https://www.mql5.com/en/articles/14710                       |
//+------------------------------------------------------------------+
//--- The functions that many classes use. They come from V3 one by one when a class asks for them
#ifndef __COMMON_DELIB_MQH__
#define __COMMON_DELIB_MQH__
 #include "..\..\Entities\Defines\CommonDefines.mqh"
 #include "..\Message\Message.mqh"
 //+------------------------------------------------------------------+
 //| Return time with milliseconds                                    |
 //+------------------------------------------------------------------+
 string TimeMSCtoString(const long time_msc, int flags=TIME_DATE|TIME_MINUTES|TIME_SECONDS)
  {
    return TimeToString(time_msc/1000,flags)+"."+IntegerToString(time_msc%1000,3,'0');
  }
 //+------------------------------------------------------------------+
 //| Return the comparison type description (V3)                      |
 //+------------------------------------------------------------------+
 string ComparisonTypeDescription(const ENUM_COMPARER_TYPE type)
  {
   switch((int)type)
     {
      case EQUAL         : return " == ";
      case MORE          : return " > ";
      case LESS          : return " < ";
      case EQUAL_OR_MORE : return " >= ";
      case EQUAL_OR_LESS : return " <= ";
      default            : return " != ";
     }
  }
 //+------------------------------------------------------------------+
 //| Return week day names (V3)                                       |
 //+------------------------------------------------------------------+
 string DayOfWeekDescription(const ENUM_DAY_OF_WEEK day_of_week)
  {
   return
     (
      day_of_week==SUNDAY    ? CMessage::Text(MSG_LIB_TEXT_SUNDAY)    :
      day_of_week==MONDAY    ? CMessage::Text(MSG_LIB_TEXT_MONDAY)    :
      day_of_week==TUESDAY   ? CMessage::Text(MSG_LIB_TEXT_TUESDAY)   :
      day_of_week==WEDNESDAY ? CMessage::Text(MSG_LIB_TEXT_WEDNESDAY) :
      day_of_week==THURSDAY  ? CMessage::Text(MSG_LIB_TEXT_THURSDAY)  :
      day_of_week==FRIDAY    ? CMessage::Text(MSG_LIB_TEXT_FRIDAY)    :
      day_of_week==SATURDAY  ? CMessage::Text(MSG_LIB_TEXT_SATURDAY)  :
      EnumToString(day_of_week)
     );
  }
 //+------------------------------------------------------------------+
 //| The sides (1 Buy, 2 Sell) of what was found on the bar `bar`: 0  |
 //| when nothing was found on it                                     |
 //+------------------------------------------------------------------+
 int NewSidesOfBar(const long &times[],const long &sides[],const datetime bar,const long buy_side)
  {
   int bits=0;
   for(int row=0;row<ArraySize(times);row++)
      if(times[row]==(long)bar)
         bits|=(sides[row]==buy_side ? 1 : 2);
   return bits;
  }
 //+------------------------------------------------------------------+
 //| The candles of `times` that are not in `found` yet go to it       |
 //+------------------------------------------------------------------+
 void AddFoundTimes(long &found[],const long &times[])
  {
   for(int row=0;row<ArraySize(times);row++)
     {
      bool there=false;
      for(int k=0;k<ArraySize(found) && !there;k++)
         there=(found[k]==times[row]);
      if(there)
         continue;
      ArrayResize(found,ArraySize(found)+1);
      found[ArraySize(found)-1]=times[row];
     }
  }
 //+------------------------------------------------------------------+
 //| What is new on a pair at its newest closed bar is told in ONE    |
 //| line in the Experts tab (message) and ONE sound of the direction |
 //| (the files of the old alerts: Buy, Sell; both sides play Sell).  |
 //| A sound that comes while the last one plays is not played: the   |
 //| new one would cut it (the pairs close their bar at the same time)|
 //| timeframe_name: the table timeframes (CSymbolTFManager)           |
 //+------------------------------------------------------------------+
 #define ALERT_SOUND_GAP_MS 2000
 void AlertNewOnPair(const string symbol,const string timeframe_name,const datetime bar,const string &names[],const int &sides[],const bool sound,const bool message)
  {
   string text="";
   bool only_buy=true;
   for(int i=0;i<ArraySize(names);i++)
     {
      text+=(text=="" ? "" : ", ")+names[i]+" "+(sides[i]==3 ? "BUY/SELL" : (sides[i]==1 ? "BUY" : "SELL"));
      if(sides[i]!=1)
         only_buy=false;
     }
   if(text=="")
      return;
   text=symbol+" "+timeframe_name+" "+TimeToString(bar,TIME_MINUTES)+": "+text;
   if(message)
      Print("Alert: ",text);
   static uint last_sound=0;
   if(sound && (last_sound==0 || GetTickCount()-last_sound>=ALERT_SOUND_GAP_MS))
     {
      PlaySound(only_buy ? "SIGNAL_BUY_EN.wav" : "SIGNAL_SELL_EN.wav");
      last_sound=GetTickCount();
     }
  }
#endif // __COMMON_DELIB_MQH__
