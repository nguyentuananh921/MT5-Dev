//+------------------------------------------------------------------+
//|                                               PatternDefines.mqh |
//|Lib https://www.mql5.com/en/articles/14710                        |
//+------------------------------------------------------------------+
#ifndef __ENTITIES_PATTERNDEFINES_MQH__
#define __ENTITIES_PATTERNDEFINES_MQH__
 enum ENUM_PATTERN_TYPE
  {
   PATTERN_TYPE_NONE                 =  0x0,
  //--- Single candle
   PATTERN_TYPE_SHOOTING_STAR        =  0x80,
   PATTERN_TYPE_HAMMER               =  0x100,
   PATTERN_TYPE_INVERTED_HAMMER      =  0x200,
   PATTERN_TYPE_HANGING_MAN          =  0x400,
   PATTERN_TYPE_DOJI                 =  0x800,
   PATTERN_TYPE_DRAGONFLY_DOJI       =  0x1000,
   PATTERN_TYPE_GRAVESTONE_DOJI      =  0x2000,
   PATTERN_TYPE_SPINNING_TOP         =  0x10000000,
   PATTERN_TYPE_MARUBOZU             =  0x20000000,
  //--- Double candle
   PATTERN_TYPE_HARAMI               =  0x1,
   PATTERN_TYPE_HARAMI_CROSS         =  0x2,
   PATTERN_TYPE_TWEEZER              =  0x4,
   PATTERN_TYPE_PIERCING_LINE        =  0x8,
   PATTERN_TYPE_DARK_CLOUD_COVER     =  0x10,
   PATTERN_TYPE_ENGULFING            =  0x8000000,
  //--- Triple candle
   PATTERN_TYPE_THREE_WHITE_SOLDIERS =  0x20,
   PATTERN_TYPE_THREE_BLACK_CROWS    =  0x40,
   PATTERN_TYPE_MORNING_STAR         =  0x4000,
   PATTERN_TYPE_MORNING_DOJI_STAR    =  0x8000,
   PATTERN_TYPE_EVENING_STAR         =  0x10000,
   PATTERN_TYPE_EVENING_DOJI_STAR    =  0x20000,
   PATTERN_TYPE_THREE_STARS          =  0x40000,
   PATTERN_TYPE_ABANDONED_BABY       =  0x80000,
   PATTERN_TYPE_THREE_INSIDE_UP      =  0x2000000,
   PATTERN_TYPE_THREE_INSIDE_DOWN    =  0x4000000,
  //--- Price Action
   PATTERN_TYPE_PIN_BAR              =  0x800000,
   PATTERN_TYPE_OUTSIDE_BAR          =  0x200000,
   PATTERN_TYPE_INSIDE_BAR           =  0x400000,
   PATTERN_TYPE_RAILS                =  0x1000000,
   PATTERN_TYPE_PIVOT_POINT_REVERSAL =  0x100000
  };
 #define PATTERNS_TOTAL              (31)

 int ListPatternsInVar(const ulong var, ulong &array[])
  {
   int   size=0;
   ulong x=1;
   for(int i=1;i<PATTERNS_TOTAL;i++)
     {
      x=(i>1 ? x*2 : 1);
      ENUM_PATTERN_TYPE type=(ENUM_PATTERN_TYPE)x;
      if((var&type)==type)
        {
         size++;
         ::ArrayResize(array,size,PATTERNS_TOTAL-1);
         array[size-1]=type;
        }
     }
   return size;
  }
#endif // __ENTITIES_PATTERNDEFINES_MQH__
