//+------------------------------------------------------------------+
//|                                             CommonDELib.mqh      |
//|                         Copyright 2020, MetaQuotes Software Corp.|
//| Lib https://www.mql5.com/en/articles/14710                       |
//+------------------------------------------------------------------+
#ifndef __COMMON_DELIB_MQH__
#define __COMMON_DELIB_MQH__

#property copyright "Copyright 2020, MetaQuotes Software Corp."
#property link      "https://mql5.com/en/users/artmedia70"
  //+------------------------------------------------------------------+
  //| Include files                                                    |
  //+------------------------------------------------------------------+
  #include "..\..\Defines\Defines.mqh"
  #include "..\..\Notify\Message\Message.mqh"
  #include "..\InputData\CommonInpData.mqh"
//+------------------------------------------------------------------+
//| Return text in one of two languages                              |
//+------------------------------------------------------------------+
string TextByLanguage(const string text_country_lang, const string text_en)
  {
    return(TerminalInfoString(TERMINAL_LANGUAGE)==COUNTRY_LANG ? text_country_lang : text_en);
  }
//+------------------------------------------------------------------+
//| Return time with milliseconds                                    |
//+------------------------------------------------------------------+
string TimeMSCtoString(const long time_msc, int flags=TIME_DATE|TIME_MINUTES|TIME_SECONDS)
  {
    return TimeToString(time_msc/1000,flags)+"."+IntegerToString(time_msc%1000,3,'0');
  }
//+------------------------------------------------------------------+
//| Display all sorting enumeration constants in the journal         |
//+------------------------------------------------------------------+
void EnumNumbersTest()
  {
    string enm="ENUM_SORT_SYMBOLS_MODE";
    string t=StringSubstr(enm,5,5)+" "; // "BY";
    Print("Search of the values of the enumaration ",enm,":");
    ENUM_SORT_SYMBOLS_MODE type=0;
    while(StringFind(EnumToString(type),t)==0)
      {
        Print(enm,"[",type,"]=",EnumToString(type));
        if(type>500) break;
        type++;
      }
    Print("\nNumber of members of the ",enm,"=",type);
  }
//+------------------------------------------------------------------+
//| Prepare the passed string of parameters                          |
//+------------------------------------------------------------------+
int StringParamsPrepare(string defined_used, string separator, string &array[])
  {
    if(separator!=";" && StringFind(defined_used,";")>WRONG_VALUE)   StringReplace(defined_used,";",separator);
    if(separator!=":" && StringFind(defined_used,":")>WRONG_VALUE)   StringReplace(defined_used,":",separator);
    if(separator!="|" && StringFind(defined_used,"|")>WRONG_VALUE)   StringReplace(defined_used,"|",separator);
    if(separator!="/" && StringFind(defined_used,"/")>WRONG_VALUE)   StringReplace(defined_used,"/",separator);
    if(separator!="\\" && StringFind(defined_used,"\\")>WRONG_VALUE) StringReplace(defined_used,"\\",separator);
    if(separator!="'" && StringFind(defined_used,"'")>WRONG_VALUE)   StringReplace(defined_used,"'",separator);
    if(separator!="-" && StringFind(defined_used,"-")>WRONG_VALUE)   StringReplace(defined_used,"-",separator);
    if(separator!="`" && StringFind(defined_used,"`")>WRONG_VALUE)   StringReplace(defined_used,"`",separator);
    while(StringFind(defined_used," ")>WRONG_VALUE && !IsStopped())
          StringReplace(defined_used," ","");
    while(StringFind(defined_used,separator+separator)>WRONG_VALUE && !IsStopped())
          StringReplace(defined_used,separator+separator,separator);
    if(StringFind(defined_used,separator)==0)
          StringSetCharacter(defined_used,0,32);
    if(StringFind(defined_used,separator,StringLen(defined_used)-1)==StringLen(defined_used)-1)
          StringSetCharacter(defined_used,StringLen(defined_used)-1,32);
    #ifdef __MQL5__
          StringTrimLeft(defined_used);
          StringTrimRight(defined_used);
    #else
          defined_used=StringTrimLeft(defined_used);
          defined_used=StringTrimRight(defined_used);
    #endif
    ArrayResize(array,0);
    ResetLastError();
    return StringSplit(defined_used,StringGetCharacter(separator,0),array);
  }
//+------------------------------------------------------------------+
//| Return correct timeframe                                         |
//+------------------------------------------------------------------+
ENUM_TIMEFRAMES CorrectTimeframe(const ENUM_TIMEFRAMES timeframe)
  {
    return(timeframe==PERIOD_CURRENT ? ::Period() : timeframe);
  }
//+------------------------------------------------------------------+
//| Return the timeframe index in the ENUM_TIMEFRAMES enumeration    |
//+------------------------------------------------------------------+
char IndexEnumTimeframe(ENUM_TIMEFRAMES timeframe)
  {
    int statement=(timeframe==PERIOD_CURRENT ? Period() : timeframe);
    switch(statement)
      {
        case PERIOD_M1  : return 1;
        case PERIOD_M2  : return 2;
        case PERIOD_M3  : return 3;
        case PERIOD_M4  : return 4;
        case PERIOD_M5  : return 5;
        case PERIOD_M6  : return 6;
        case PERIOD_M10 : return 7;
        case PERIOD_M12 : return 8;
        case PERIOD_M15 : return 9;
        case PERIOD_M20 : return 10;
        case PERIOD_M30 : return 11;
        case PERIOD_H1  : return 12;
        case PERIOD_H2  : return 13;
        case PERIOD_H3  : return 14;
        case PERIOD_H4  : return 15;
        case PERIOD_H6  : return 16;
        case PERIOD_H8  : return 17;
        case PERIOD_H12 : return 18;
        case PERIOD_D1  : return 19;
        case PERIOD_W1  : return 20;
        case PERIOD_MN1 : return 21;
        default         : Print(DFUN,CMessage::Text(MSG_LIB_TEXT_TS_TEXT_UNKNOWN_TIMEFRAME)); return WRONG_VALUE;
      }
  }
//+------------------------------------------------------------------+
//| Return the timeframe by the ENUM_TIMEFRAMES enumeration index    |
//+------------------------------------------------------------------+
ENUM_TIMEFRAMES TimeframeByEnumIndex(const uchar index)
  {
    if(index==0) return(ENUM_TIMEFRAMES)Period();
    switch(index)
      {
        case 1  : return PERIOD_M1;
        case 2  : return PERIOD_M2;
        case 3  : return PERIOD_M3;
        case 4  : return PERIOD_M4;
        case 5  : return PERIOD_M5;
        case 6  : return PERIOD_M6;
        case 7  : return PERIOD_M10;
        case 8  : return PERIOD_M12;
        case 9  : return PERIOD_M15;
        case 10 : return PERIOD_M20;
        case 11 : return PERIOD_M30;
        case 12 : return PERIOD_H1;
        case 13 : return PERIOD_H2;
        case 14 : return PERIOD_H3;
        case 15 : return PERIOD_H4;
        case 16 : return PERIOD_H6;
        case 17 : return PERIOD_H8;
        case 18 : return PERIOD_H12;
        case 19 : return PERIOD_D1;
        case 20 : return PERIOD_W1;
        case 21 : return PERIOD_MN1;
        default : Print(DFUN,CMessage::Text(MSG_LIB_SYS_NOT_GET_DATAS),"... ",CMessage::Text(MSG_SYM_STATUS_INDEX),": ",(string)index); return WRONG_VALUE;
      }
  }
//+------------------------------------------------------------------+
//| Return the timeframe by its description                          |
//+------------------------------------------------------------------+
ENUM_TIMEFRAMES TimestampByDescription(const string timeframe)
  {
    return
        (
          timeframe=="M1"  ? PERIOD_M1  :
          timeframe=="M2"  ? PERIOD_M2  :
          timeframe=="M3"  ? PERIOD_M3  :
          timeframe=="M4"  ? PERIOD_M4  :
          timeframe=="M5"  ? PERIOD_M5  :
          timeframe=="M6"  ? PERIOD_M6  :
          timeframe=="M10" ? PERIOD_M10 :
          timeframe=="M12" ? PERIOD_M12 :
          timeframe=="M15" ? PERIOD_M15 :
          timeframe=="M20" ? PERIOD_M20 :
          timeframe=="M30" ? PERIOD_M30 :
          timeframe=="H1"  ? PERIOD_H1  :
          timeframe=="H2"  ? PERIOD_H2  :
          timeframe=="H3"  ? PERIOD_H3  :
          timeframe=="H4"  ? PERIOD_H4  :
          timeframe=="H6"  ? PERIOD_H6  :
          timeframe=="H8"  ? PERIOD_H8  :
          timeframe=="H12" ? PERIOD_H12 :
          timeframe=="D1"  ? PERIOD_D1  :
          timeframe=="W1"  ? PERIOD_W1  :
          timeframe=="MN1" ? PERIOD_MN1 :
          PERIOD_CURRENT
        );
  }
//+------------------------------------------------------------------+
//| Return timeframe description                                     |
//+------------------------------------------------------------------+
string TimeframeDescription(const ENUM_TIMEFRAMES timeframe)
  {
    return StringSubstr(EnumToString((timeframe>PERIOD_CURRENT ? timeframe : (ENUM_TIMEFRAMES)Period())),7);
  }
//+------------------------------------------------------------------+
//| Prepare the array of timeframes for the timeseries collection   |
//+------------------------------------------------------------------+
bool CreateUsedTimeframesArray(const ENUM_TIMEFRAMES_MODE mode_used_periods, string defined_used_periods, string &used_periods_array[])
  {
    if(mode_used_periods==TIMEFRAMES_MODE_CURRENT)
      {
        ArrayResize(used_periods_array,1,21);
        used_periods_array[0]=TimeframeDescription((ENUM_TIMEFRAMES)Period());
        return true;
      }
    else if(mode_used_periods==TIMEFRAMES_MODE_LIST)
      {
        string separator=INPUT_SEPARATOR;
        int n=StringParamsPrepare(defined_used_periods,separator,used_periods_array);
        if(n<1)
          {
            int err_code=GetLastError();
            string err=
                (n==0 ?
                  DFUN_ERR_LINE+CMessage::Text(MSG_LIB_SYS_ERROR_EMPTY_PERIODS_STRING)+TimeframeDescription((ENUM_TIMEFRAMES)Period()) :
                  DFUN_ERR_LINE+CMessage::Text(MSG_LIB_SYS_FAILED_PREPARING_PERIODS_ARRAY)+(string)err_code+": "+CMessage::Text(err_code)
                );
            Print(err);
            ArrayResize(used_periods_array,1,21);
            used_periods_array[0]=TimeframeDescription((ENUM_TIMEFRAMES)Period());
            return false;
          }
      }
    else
      {
        ArrayResize(used_periods_array,21,21);
        for(int i=0;i<21;i++)
              used_periods_array[i]=TimeframeDescription(TimeframeByEnumIndex(uchar(i+1)));
      }
    bool f=false;
    for(int i=0;i<ArraySize(used_periods_array);i++)
      {
        if(used_periods_array[i]==TimeframeDescription((ENUM_TIMEFRAMES)Period()))
          {
            f=true;
            break;
          }
      }
    if(!f)
      {
        ArrayResize(used_periods_array,ArraySize(used_periods_array)+1);
        used_periods_array[ArraySize(used_periods_array)-1]=TimeframeDescription((ENUM_TIMEFRAMES)Period());
      }
    return true;
  }
//+------------------------------------------------------------------+
//| Return week day names                                            |
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
//| Return month names                                               |
//+------------------------------------------------------------------+
string MonthDescription(const int month)
  {
    return
        (
          month==1  ? CMessage::Text(MSG_LIB_TEXT_JANUARY)   :
          month==2  ? CMessage::Text(MSG_LIB_TEXT_FEBRUARY)  :
          month==3  ? CMessage::Text(MSG_LIB_TEXT_MARCH)     :
          month==4  ? CMessage::Text(MSG_LIB_TEXT_APRIL)     :
          month==5  ? CMessage::Text(MSG_LIB_TEXT_MAY)       :
          month==6  ? CMessage::Text(MSG_LIB_TEXT_JUNE)      :
          month==7  ? CMessage::Text(MSG_LIB_TEXT_JULY)      :
          month==8  ? CMessage::Text(MSG_LIB_TEXT_AUGUST)    :
          month==9  ? CMessage::Text(MSG_LIB_TEXT_SEPTEMBER) :
          month==10 ? CMessage::Text(MSG_LIB_TEXT_OCTOBER)   :
          month==11 ? CMessage::Text(MSG_LIB_TEXT_NOVEMBER)  :
          month==12 ? CMessage::Text(MSG_LIB_TEXT_DECEMBER)  :
          (string)month
        );
  }
//+------------------------------------------------------------------+
//| Return volume description for calculation                        |
//+------------------------------------------------------------------+
string AppliedVolumeDescription(const ENUM_APPLIED_VOLUME volume)
  {
    return StringSubstr(EnumToString(volume),7);
  }
//+------------------------------------------------------------------+
//| Return indicator type description                                |
//+------------------------------------------------------------------+
string IndicatorTypeDescription(const ENUM_INDICATOR indicator)
  {
    return StringSubstr(EnumToString(indicator),4);
  }
//+------------------------------------------------------------------+
//| Return averaging method description                              |
//+------------------------------------------------------------------+
string AveragingMethodDescription(const ENUM_MA_METHOD method)
  {
    return StringSubstr(EnumToString(method),5);
  }
//+------------------------------------------------------------------+
//| Return applied price description                                 |
//+------------------------------------------------------------------+
string AppliedPriceDescription(const ENUM_APPLIED_PRICE price)
  {
    return StringSubstr(EnumToString(price),6);
  }
//+------------------------------------------------------------------+
//| Return stochastic price calculation description                  |
//+------------------------------------------------------------------+
string StochPriceDescription(const ENUM_STO_PRICE price)
  {
    return StringSubstr(EnumToString(price),4);
  }
//+------------------------------------------------------------------+
//| Return the description of parameter MqlParam array              |
//+------------------------------------------------------------------+
string MqlParameterDescription(const MqlParam &mql_param)
  {
    int    type=mql_param.type;
    string res=CMessage::Text(MSG_ORD_TYPE)+"  "+typename(type)+":  ";
    if(type==TYPE_STRING)
          res+=mql_param.string_value;
    else if(type==TYPE_DATETIME)
          res+=TimeToString(mql_param.integer_value,TIME_DATE|TIME_MINUTES|TIME_SECONDS);
    else if(type==TYPE_COLOR)
          res+=ColorToString((color)mql_param.integer_value,true);
    else if(type==TYPE_BOOL)
          res+=(string)(bool)mql_param.integer_value;
    else if(type>TYPE_BOOL && type<TYPE_FLOAT)
          res+=(string)mql_param.integer_value;
    else
          res+=DoubleToString(mql_param.double_value,8);
    return res;
  }
//+------------------------------------------------------------------+
//| Return pattern type description                                  |
//+------------------------------------------------------------------+
string PatternTypeDescription(const ENUM_PATTERN_TYPE type)
  {
    switch(type)
      {
        case PATTERN_TYPE_HARAMI               : return CMessage::Text(MSG_LIB_TEXT_PATTERN_TYPE_HARAMI);
        case PATTERN_TYPE_HARAMI_CROSS         : return CMessage::Text(MSG_LIB_TEXT_PATTERN_TYPE_HARAMI_CROSS);
        case PATTERN_TYPE_TWEEZER              : return CMessage::Text(MSG_LIB_TEXT_PATTERN_TYPE_TWEEZER);
        case PATTERN_TYPE_PIERCING_LINE        : return CMessage::Text(MSG_LIB_TEXT_PATTERN_TYPE_PIERCING_LINE);
        case PATTERN_TYPE_DARK_CLOUD_COVER     : return CMessage::Text(MSG_LIB_TEXT_PATTERN_TYPE_DARK_CLOUD_COVER);
        case PATTERN_TYPE_THREE_WHITE_SOLDIERS : return CMessage::Text(MSG_LIB_TEXT_PATTERN_TYPE_THREE_WHITE_SOLDIERS);
        case PATTERN_TYPE_THREE_BLACK_CROWS    : return CMessage::Text(MSG_LIB_TEXT_PATTERN_TYPE_THREE_BLACK_CROWS);
        case PATTERN_TYPE_SHOOTING_STAR        : return CMessage::Text(MSG_LIB_TEXT_PATTERN_TYPE_SHOOTING_STAR);
        case PATTERN_TYPE_HAMMER               : return CMessage::Text(MSG_LIB_TEXT_PATTERN_TYPE_HAMMER);
        case PATTERN_TYPE_INVERTED_HAMMER      : return CMessage::Text(MSG_LIB_TEXT_PATTERN_TYPE_INVERTED_HAMMER);
        case PATTERN_TYPE_HANGING_MAN          : return CMessage::Text(MSG_LIB_TEXT_PATTERN_TYPE_HANGING_MAN);
        case PATTERN_TYPE_DOJI                 : return CMessage::Text(MSG_LIB_TEXT_PATTERN_TYPE_DOJI);
        case PATTERN_TYPE_DRAGONFLY_DOJI       : return CMessage::Text(MSG_LIB_TEXT_PATTERN_TYPE_DRAGONFLY_DOJI);
        case PATTERN_TYPE_GRAVESTONE_DOJI      : return CMessage::Text(MSG_LIB_TEXT_PATTERN_TYPE_GRAVESTONE_DOJI);
        case PATTERN_TYPE_MORNING_STAR         : return CMessage::Text(MSG_LIB_TEXT_PATTERN_TYPE_MORNING_STAR);
        case PATTERN_TYPE_MORNING_DOJI_STAR    : return CMessage::Text(MSG_LIB_TEXT_PATTERN_TYPE_MORNING_DOJI_STAR);
        case PATTERN_TYPE_EVENING_STAR         : return CMessage::Text(MSG_LIB_TEXT_PATTERN_TYPE_EVENING_STAR);
        case PATTERN_TYPE_EVENING_DOJI_STAR    : return CMessage::Text(MSG_LIB_TEXT_PATTERN_TYPE_EVENING_DOJI_STAR);
        case PATTERN_TYPE_THREE_STARS          : return CMessage::Text(MSG_LIB_TEXT_PATTERN_TYPE_THREE_STARS);
        case PATTERN_TYPE_ABANDONED_BABY       : return CMessage::Text(MSG_LIB_TEXT_PATTERN_TYPE_ABANDONED_BABY);
        case PATTERN_TYPE_PIVOT_POINT_REVERSAL : return CMessage::Text(MSG_LIB_TEXT_PATTERN_TYPE_PIVOT_POINT_REVERSAL);
        case PATTERN_TYPE_OUTSIDE_BAR          : return CMessage::Text(MSG_LIB_TEXT_PATTERN_TYPE_OUTSIDE_BAR);
        case PATTERN_TYPE_INSIDE_BAR           : return CMessage::Text(MSG_LIB_TEXT_PATTERN_TYPE_INSIDE_BAR);
        case PATTERN_TYPE_PIN_BAR              : return CMessage::Text(MSG_LIB_TEXT_PATTERN_TYPE_PIN_BAR);
        case PATTERN_TYPE_RAILS                : return CMessage::Text(MSG_LIB_TEXT_PATTERN_TYPE_RAILS);
        default                                : return CMessage::Text(MSG_LIB_TEXT_FRAME_STYLE_NONE);
      }
  }
//+------------------------------------------------------------------+
//| Return the number and list of patterns in the ulong variable     |
//+------------------------------------------------------------------+
int ListPatternsInVar(const ulong var, ulong &array[])
  {
    int  size=0;
    ulong x=1;
    for(int i=1;i<PATTERNS_TOTAL;i++)
      {
        x=(i>1 ? x*2 : 1);
        ENUM_PATTERN_TYPE type=(ENUM_PATTERN_TYPE)x;
        bool res=(var&type)==type;
        if(res)
          {
            size++;
            ArrayResize(array,size,PATTERNS_TOTAL-1);
            array[size-1]=type;
          }
      }
    return size;
  }
//+------------------------------------------------------------------+
//| Send a description of pattern types in a ulong variable          |
//| to the journal                                                   |
//+------------------------------------------------------------------+
void PatternsInVarDescriptionPrint(const ulong var, const bool dash=false)
  {
    ulong array[];
    int total=ListPatternsInVar(var,array);
    for(int i=0;i<total;i++)
          Print((dash ? "  -  " : ""),PatternTypeDescription((ENUM_PATTERN_TYPE)array[i]));
  }
//+------------------------------------------------------------------+
//| Return a description of pattern types in a ulong variable        |
//+------------------------------------------------------------------+
string PatternsInVarDescription(const ulong var, const bool dash=false)
  {
    ulong  array[];
    int    total=ListPatternsInVar(var,array);
    string txt="";
    for(int i=0;i<total;i++)
          txt+=((dash ? "  -  " : "")+PatternTypeDescription((ENUM_PATTERN_TYPE)array[i]))+(i<total-1 ? "\n" : "");
    return txt;
  }
//+------------------------------------------------------------------+
//| Return the flag of a prefixed object presence                    |
//+------------------------------------------------------------------+
bool IsPresentObectByPrefix(const string object_prefix)
  {
    for(int i=ObjectsTotal(0,0)-1;i>=0;i--)
          if(StringFind(ObjectName(0,i,0),object_prefix)>WRONG_VALUE)
                return true;
    return false;
  }
//+------------------------------------------------------------------+
//| Return the description of the method of displaying a price chart |
//| Using in                                                         |
//| ChartObj.mqh + Symbol.mqh
//+------------------------------------------------------------------+
string ChartModeDescription(ENUM_CHART_MODE mode)
  {
   return
     (
      mode==CHART_BARS     ? CMessage::Text(MSG_CHART_OBJ_CHART_BARS)      :
      mode==CHART_CANDLES  ? CMessage::Text(MSG_CHART_OBJ_CHART_CANDLES)   :
      CMessage::Text(MSG_CHART_OBJ_CHART_LINE)
     );
  }
#endif // __COMMON_DELIB_MQH__