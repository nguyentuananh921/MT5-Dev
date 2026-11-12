//+------------------------------------------------------------------+
//|                                                 ChangedProps.mqh |
//|                                  Copyright 2021, MetaQuotes Ltd. |
//|                             https://mql5.com/en/users/artmedia70 |
//|Link                      https://www.mql5.com/en/articles/10237  |
//|Lib                       https://www.mql5.com/en/articles/14710  |
//+------------------------------------------------------------------+
#property copyright "Copyright 2021, MetaQuotes Ltd."
#property link      "https://mql5.com/en/users/artmedia70"
#property version   "1.00"
#property strict    // Necessary for mql4
//+------------------------------------------------------------------+
//| Include files                                                    |
//+------------------------------------------------------------------+
#include "..\..\..\Services\DELib\CommonDELib.mqh"
#include "DataPropObj.mqh"

#ifndef CCHANGEDPROPS_MQH
#define CCHANGEDPROPS_MQH

 #ifndef CCHANGEDPROPS_MQH_DECLARATION
 #define CCHANGEDPROPS_MQH_DECLARATION
//+------------------------------------------------------------------+
//| Object changed property snapshot class                           |
//+------------------------------------------------------------------+
class CChangedProps : public CDataPropObj
  {
private:
  long               m_time_change;                         // Property modification time
  string             m_symbol;                              // Chart window symbol
  int                m_digits;                              // Symbol's Digits

protected:

public:
//--- Constructor/destructor
                     CChangedProps(const int prop_total_integer,const int prop_total_double,const int prop_total_string,const long time_changed);
                    ~CChangedProps(void){;}

//--- Set the (1) change time value, (2) symbol and (3) symbol's Digits
   void              SetTimeChanged(const long time)        { this.m_time_change=time;                   }
   void              SetSymbol(const string symbol)         { this.m_symbol=symbol;                      }
   void              SetDigits(const int digits)            { this.m_digits=digits;                      }
//--- Return the (1) change time value, (2) change time, (3) symbol and (4) symbol's Digits
   long              TimeChanged(void)                const { return this.m_time_change;                 }
   string            TimeChangedToString(void)        const { return TimeMSCtoString(this.m_time_change);}
   string            Symbol(void)                     const { return this.m_symbol;                      }
   int               Digits(void)                     const { return this.m_digits;                      }
  };
 #endif // CCHANGEDPROPS_MQH_DECLARATION
 #ifndef CCHANGEDPROPS_MQH_IMPLEMENTATION
 #define CCHANGEDPROPS_MQH_IMPLEMENTATION
 //+------------------------------------------------------------------+
 //| CChangedProps Constructor                                        |
 //+------------------------------------------------------------------+
 CChangedProps::CChangedProps(const int prop_total_integer,const int prop_total_double,const int prop_total_string,const long time_changed) : 
   CDataPropObj(prop_total_integer,prop_total_double,prop_total_string)
  {
   this.m_time_change=time_changed;
  }
 #endif // CCHANGEDPROPS_MQH_IMPLEMENTATION

#endif // CCHANGEDPROPS_MQH
