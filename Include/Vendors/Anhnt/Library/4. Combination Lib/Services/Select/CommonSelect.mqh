//+------------------------------------------------------------------+
//|                                              CommonSelect.mqh     |
//|                         Copyright 2020, MetaQuotes Software Corp.|
//| Lib https://www.mql5.com/en/articles/14710                       |
//+------------------------------------------------------------------+
#ifndef __COMMON_SELECT_MQH__
#define __COMMON_SELECT_MQH__

#property copyright "Copyright 2020, MetaQuotes Software Corp."
#property link      "https://mql5.com/en/users/artmedia70"
  //+------------------------------------------------------------------+
  //| Include files                                                    |
  //+------------------------------------------------------------------+
  #include <Arrays\ArrayObj.mqh>
  #include "..\..\Defines\CommonDefines.mqh"

  #ifndef CCOMMON_SELECT_MQH_DECLARATION
  #define CCOMMON_SELECT_MQH_DECLARATION
    //+------------------------------------------------------------------+
    //| Storage list (shared across all Select modules)                  |
    //+------------------------------------------------------------------+
    CArrayObj     CommonListStorage; // Storage object for storing sorted collection lists
    //+------------------------------------------------------------------+
    //| Base class providing the CompareValues method                    |
    //| to all derived Select classes                                    |
    //+------------------------------------------------------------------+
  class CCommonSelect
    {
     protected:
       //--- Method for comparing two values
         template<typename T>
         static bool              CompareValues(T value1, T value2, ENUM_COMPARER_TYPE mode);
    };
    //+------------------------------------------------------------------+
  #endif // CCOMMON_SELECT_MQH_DECLARATION

  #ifndef CCOMMON_SELECT_MQH_IMPLEMENTATION
  #define CCOMMON_SELECT_MQH_IMPLEMENTATION
    //+------------------------------------------------------------------+
    //| Two values comparison method                                     |
    //+------------------------------------------------------------------+
    template<typename T>
    bool CCommonSelect::CompareValues(T value1, T value2, ENUM_COMPARER_TYPE mode)
      {
        switch(mode)
          {
            case EQUAL         : return(value1==value2  ? true : false);
            case NO_EQUAL      : return(value1!=value2  ? true : false);
            case MORE          : return(value1>value2   ? true : false);
            case LESS          : return(value1<value2   ? true : false);
            case EQUAL_OR_MORE : return(value1>=value2  ? true : false);
            case EQUAL_OR_LESS : return(value1<=value2  ? true : false);
            default            : return false;
          }
      }
    //+------------------------------------------------------------------+
  #endif // CCOMMON_SELECT_MQH_IMPLEMENTATION

#endif // __COMMON_SELECT_MQH__