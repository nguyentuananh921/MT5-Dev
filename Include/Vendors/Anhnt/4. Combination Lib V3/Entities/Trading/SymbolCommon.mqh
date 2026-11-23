#ifndef __SYMBOLCOMMON_MQH__
#define __SYMBOLCOMMON_MQH__
//+------------------------------------------------------------------+
//|                                                 SymbolCommon.mqh |
//|                        Copyright 2019, MetaQuotes Software Corp. |
//|                             https://mql5.com/en/users/artmedia70 |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//| Include files                                                    |
//+------------------------------------------------------------------+
#include "Symbol.mqh"
 #ifndef CSYMBOLCOMMON_MQH_DECLARATION
 #define CSYMBOLCOMMON_MQH_DECLARATION
//+------------------------------------------------------------------+
//| General group symbol                                             |
//+------------------------------------------------------------------+
class CSymbolCommon : public CSymbol
  {
public:
//--- Constructor
                     CSymbolCommon(const string name,const int index) : CSymbol(SYMBOL_STATUS_COMMON,name,index)
                        { this.m_type=OBJECT_DE_TYPE_SYMBOL_COMMON; }
//--- Supported integer properties of a symbol
   virtual bool      SupportProperty(ENUM_SYMBOL_PROP_INTEGER property);
//--- Supported real properties of a symbol
   virtual bool      SupportProperty(ENUM_SYMBOL_PROP_DOUBLE property);
//--- Supported string properties of a symbol
   virtual bool      SupportProperty(ENUM_SYMBOL_PROP_STRING property);
//--- Display a short symbol description in the journal
   virtual void      PrintShort(const bool dash=false,const bool symbol=false);
  };
 #endif // CSYMBOLCOMMON_MQH_DECLARATION
 #ifndef CSYMBOLCOMMON_MQH_IMPLEMENTATION
 #define CSYMBOLCOMMON_MQH_IMPLEMENTATION
//+------------------------------------------------------------------+
//| Return 'true' if a symbol supports a passed                      |
//| integer property, otherwise return 'false'                       |
//+------------------------------------------------------------------+
bool CSymbolCommon::SupportProperty(ENUM_SYMBOL_PROP_INTEGER property)
  {
   if(property==SYMBOL_PROP_EXIST
   #ifdef __MQL4__                                 ||
      property==SYMBOL_PROP_CUSTOM                 ||
      property==SYMBOL_PROP_SESSION_DEALS          ||
      property==SYMBOL_PROP_SESSION_BUY_ORDERS     ||
      property==SYMBOL_PROP_SESSION_SELL_ORDERS    ||
      property==SYMBOL_PROP_VOLUME                 ||
      property==SYMBOL_PROP_VOLUMEHIGH             ||
      property==SYMBOL_PROP_VOLUMELOW              ||
      property==SYMBOL_PROP_TICKS_BOOKDEPTH        ||
      property==SYMBOL_PROP_OPTION_MODE            ||
      property==SYMBOL_PROP_OPTION_RIGHT           ||
      property==SYMBOL_PROP_BACKGROUND_COLOR 
   #endif         
     ) return false;
   return true;
  }
//+------------------------------------------------------------------+
//| Return 'true' if a symbol supports a passed                      |
//| real property, otherwise return 'false'                          |
//+------------------------------------------------------------------+
bool CSymbolCommon::SupportProperty(ENUM_SYMBOL_PROP_DOUBLE property)
  {
   if(
     #ifdef __MQL5__
      (this.ChartMode()==SYMBOL_CHART_MODE_BID     && 
        (
         property==SYMBOL_PROP_LAST                ||
         property==SYMBOL_PROP_LASTHIGH            ||
         property==SYMBOL_PROP_LASTLOW
        )
      )                                            ||
      (this.ChartMode()==SYMBOL_CHART_MODE_LAST    && 
        (
         property==SYMBOL_PROP_BID                 ||
         property==SYMBOL_PROP_BIDHIGH             ||
         property==SYMBOL_PROP_BIDLOW              ||
         property==SYMBOL_PROP_ASK                 ||
         property==SYMBOL_PROP_ASKHIGH             ||
         property==SYMBOL_PROP_ASKLOW
        )
      )
     //--- __MQL4__
     #else 
      property==SYMBOL_PROP_ASKHIGH                            ||
      property==SYMBOL_PROP_ASKLOW                             ||
      property==SYMBOL_PROP_TRADE_TICK_VALUE_PROFIT            ||
      property==SYMBOL_PROP_TRADE_TICK_VALUE_LOSS              ||
      property==SYMBOL_PROP_LAST                               ||
      property==SYMBOL_PROP_LASTHIGH                           ||
      property==SYMBOL_PROP_LASTLOW                            ||
      property==SYMBOL_PROP_VOLUME_LIMIT                       ||
      property==SYMBOL_PROP_MARGIN_LONG_INITIAL                ||
      property==SYMBOL_PROP_MARGIN_BUY_STOP_INITIAL            ||
      property==SYMBOL_PROP_MARGIN_BUY_LIMIT_INITIAL           ||
      property==SYMBOL_PROP_MARGIN_BUY_STOPLIMIT_INITIAL       ||
      property==SYMBOL_PROP_MARGIN_LONG_MAINTENANCE            ||
      property==SYMBOL_PROP_MARGIN_BUY_STOP_MAINTENANCE        ||
      property==SYMBOL_PROP_MARGIN_BUY_LIMIT_MAINTENANCE       ||
      property==SYMBOL_PROP_MARGIN_BUY_STOPLIMIT_MAINTENANCE   ||
      property==SYMBOL_PROP_MARGIN_SHORT_INITIAL               ||
      property==SYMBOL_PROP_MARGIN_SELL_STOP_INITIAL           ||
      property==SYMBOL_PROP_MARGIN_SELL_LIMIT_INITIAL          ||
      property==SYMBOL_PROP_MARGIN_SELL_STOPLIMIT_INITIAL      ||
      property==SYMBOL_PROP_MARGIN_SHORT_MAINTENANCE           ||
      property==SYMBOL_PROP_MARGIN_SELL_STOP_MAINTENANCE       ||
      property==SYMBOL_PROP_MARGIN_SELL_LIMIT_MAINTENANCE      ||
      property==SYMBOL_PROP_MARGIN_SELL_STOPLIMIT_MAINTENANCE  ||
      property==SYMBOL_PROP_SESSION_VOLUME                     ||
      property==SYMBOL_PROP_SESSION_TURNOVER                   ||
      property==SYMBOL_PROP_SESSION_INTEREST                   ||
      property==SYMBOL_PROP_SESSION_BUY_ORDERS_VOLUME          ||
      property==SYMBOL_PROP_SESSION_SELL_ORDERS_VOLUME         ||
      property==SYMBOL_PROP_SESSION_OPEN                       ||
      property==SYMBOL_PROP_SESSION_CLOSE                      ||
      property==SYMBOL_PROP_SESSION_AW                         ||
      property==SYMBOL_PROP_SESSION_PRICE_SETTLEMENT           ||
      property==SYMBOL_PROP_SESSION_PRICE_LIMIT_MIN            ||
      property==SYMBOL_PROP_SESSION_PRICE_LIMIT_MAX            ||
      property==SYMBOL_PROP_VOLUME_REAL                        ||
      property==SYMBOL_PROP_VOLUMEHIGH_REAL                    ||
      property==SYMBOL_PROP_VOLUMELOW_REAL                     ||
      property==SYMBOL_PROP_OPTION_STRIKE                      ||
      property==SYMBOL_PROP_TRADE_ACCRUED_INTEREST             ||
      property==SYMBOL_PROP_TRADE_FACE_VALUE                   ||
      property==SYMBOL_PROP_TRADE_LIQUIDITY_RATE
     #endif         
     ) return false;
   return true;
  }
//+------------------------------------------------------------------+
//| Return 'true' if a symbol supports a passed                      |
//| string property, otherwise return 'false'                        |
//+------------------------------------------------------------------+
bool CSymbolCommon::SupportProperty(ENUM_SYMBOL_PROP_STRING property)
  {
   if(
   #ifdef __MQL5__ 
      property==SYMBOL_PROP_FORMULA && !this.IsCustom()
   #else
      property==SYMBOL_PROP_BASIS                  || 
      property==SYMBOL_PROP_BANK                   ||
      property==SYMBOL_PROP_ISIN                   ||
      property==SYMBOL_PROP_FORMULA                ||
      property==SYMBOL_PROP_PAGE
   #endif         
     ) return false;
   return true;
  }
//+------------------------------------------------------------------+
//| Display a short symbol description in the journal                |
//+------------------------------------------------------------------+
void CSymbolCommon::PrintShort(const bool dash=false,const bool symbol=false)
  {
   ::Print(this.GetStatusDescription()+" "+this.Name());
  }
//+------------------------------------------------------------------+

 #endif // CSYMBOLCOMMON_MQH_IMPLEMENTATION
#endif // __SYMBOLCOMMON_MQH__