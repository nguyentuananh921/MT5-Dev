//+------------------------------------------------------------------+
//|                                              TradingDELib.mqh    |
//|                         Copyright 2020, MetaQuotes Software Corp.|
//|  Extracted from Artyom Trishkin's DoEasy DELib.mqh            |
//|Topic link: https://www.mql5.com/en/articles/5654                 |
//|Lib https://www.mql5.com/en/articles/14710                        |
//+------------------------------------------------------------------+
#property copyright "Copyright 2020, MetaQuotes Software Corp."
#property link      "https://mql5.com/en/users/artmedia70"
#ifndef __TRADING_DELIB_MQH__
#define __TRADING_DELIB_MQH__
#include "..\Message\Message.mqh"
// Symbol 
 //+------------------------------------------------------------------+
 //| Returns the number of decimal places in a symbol lot             |
 //+------------------------------------------------------------------+
 uint DigitsLots(const string symbol_name)
  {
    return (int)ceil(fabs(log10(SymbolInfoDouble(symbol_name,SYMBOL_VOLUME_STEP))));
  }
// Order 
 //+------------------------------------------------------------------+
 //| Return the order name                                            |
 //+------------------------------------------------------------------+
 string OrderTypeDescription(const ENUM_ORDER_TYPE type, bool as_order=true, bool prefix_for_market_order=true, bool descr=true)
  {
    string pref=
        (
          !prefix_for_market_order ? "" :
          #ifdef __MQL5__   CMessage::Text(MSG_ORD_MARKET)
          #else /*(MQL4)*/ (as_order ? CMessage::Text(MSG_ORD_MARKET) : CMessage::Text(MSG_ORD_POSITION)) 
          #endif
        );
    return
        (
           type==ORDER_TYPE_BUY_LIMIT               ? (descr ? CMessage::Text(MSG_ORD_PENDING) : "")+"  Buy Limit"               :
           type==ORDER_TYPE_BUY_STOP                ? (descr ? CMessage::Text(MSG_ORD_PENDING) : "")+"  Buy Stop"                 :
           type==ORDER_TYPE_SELL_LIMIT              ? (descr ? CMessage::Text(MSG_ORD_PENDING) : "")+"  Sell Limit"               :
           type==ORDER_TYPE_SELL_STOP               ? (descr ? CMessage::Text(MSG_ORD_PENDING) : "")+"  Sell Stop"                :
          #ifdef __MQL5__
           type==ORDER_TYPE_BUY_STOP_LIMIT          ? (descr ? CMessage::Text(MSG_ORD_PENDING) : "")+"  Buy Stop Limit"           :
           type==ORDER_TYPE_SELL_STOP_LIMIT         ? (descr ? CMessage::Text(MSG_ORD_PENDING) : "")+"  Sell Stop Limit"          :
           type==ORDER_TYPE_CLOSE_BY               ? CMessage::Text(MSG_ORD_CLOSE_BY)                                             :
          #else
           type==ORDER_TYPE_BALANCE               ? CMessage::Text(MSG_LIB_PROP_BALANCE)                                          :
           type==ORDER_TYPE_CREDIT                ? CMessage::Text(MSG_LIB_PROP_CREDIT)                                           :
          #endif
           type==ORDER_TYPE_BUY                   ? pref+"  Buy"                                                                  :
           type==ORDER_TYPE_SELL                  ? pref+"  Sell"                                                                 :
           CMessage::Text(MSG_ORD_UNKNOWN_TYPE)
        );
  }
 //+------------------------------------------------------------------+
 //| Return the order filling mode description                        |
 //+------------------------------------------------------------------+
 string OrderTypeFillingDescription(const ENUM_ORDER_TYPE_FILLING type)
  {
    return
        (
          type==ORDER_FILLING_FOK     ? CMessage::Text(MSG_LIB_TEXT_REQUEST_ORDER_FILLING_FOK)    :
          type==ORDER_FILLING_IOC     ? CMessage::Text(MSG_LIB_TEXT_REQUEST_ORDER_FILLING_IOK)    :
          type==ORDER_FILLING_BOC     ? CMessage::Text(MSG_LIB_TEXT_REQUEST_ORDER_FILLING_BOK)    :
          type==ORDER_FILLING_RETURN  ? CMessage::Text(MSG_LIB_TEXT_REQUEST_ORDER_FILLING_RETURN) :
          type==WRONG_VALUE           ? "WRONG_VALUE"  : EnumToString(type)
        );
  }
 //+------------------------------------------------------------------+
 //| Return the order expiration type description                     |
 //+------------------------------------------------------------------+
 string OrderTypeTimeDescription(const ENUM_ORDER_TYPE_TIME type)
  {
    return
        (
          type==ORDER_TIME_GTC             ? CMessage::Text(MSG_LIB_TEXT_REQUEST_ORDER_TIME_GTC)           :
          type==ORDER_TIME_DAY             ? CMessage::Text(MSG_LIB_TEXT_REQUEST_ORDER_TIME_DAY)           :
          type==ORDER_TIME_SPECIFIED       ? CMessage::Text(MSG_LIB_TEXT_REQUEST_ORDER_TIME_SPECIFIED)     :
          type==ORDER_TIME_SPECIFIED_DAY   ? CMessage::Text(MSG_LIB_TEXT_REQUEST_ORDER_TIME_SPECIFIED_DAY) :
          type==WRONG_VALUE                ? "WRONG_VALUE" : EnumToString(type)
        );
  }
 //+------------------------------------------------------------------+
 //| Return a reverse order type by a position type                   |
 //+------------------------------------------------------------------+
 ENUM_ORDER_TYPE OrderTypeOppositeByPositionType(ENUM_POSITION_TYPE type_position)
  {
    return(type_position==POSITION_TYPE_BUY ? ORDER_TYPE_SELL : ORDER_TYPE_BUY);
  }
 //+------------------------------------------------------------------+
 //| Return the deal name                                             |
 //+------------------------------------------------------------------+
 string DealTypeDescription(const ENUM_DEAL_TYPE type)
  {
    return
        (
          type==DEAL_TYPE_BUY                          ? CMessage::Text(MSG_DEAL_TO_BUY)                              :
          type==DEAL_TYPE_SELL                         ? CMessage::Text(MSG_DEAL_TO_SELL)                             :
          type==DEAL_TYPE_BALANCE                      ? CMessage::Text(MSG_LIB_PROP_BALANCE)                         :
          type==DEAL_TYPE_CREDIT                       ? CMessage::Text(MSG_EVN_ACCOUNT_CREDIT)                       :
          type==DEAL_TYPE_CHARGE                       ? CMessage::Text(MSG_EVN_ACCOUNT_CHARGE)                       :
          type==DEAL_TYPE_CORRECTION                   ? CMessage::Text(MSG_EVN_ACCOUNT_CORRECTION)                   :
          type==DEAL_TYPE_BONUS                        ? CMessage::Text(MSG_EVN_ACCOUNT_BONUS)                        :
          type==DEAL_TYPE_COMMISSION                   ? CMessage::Text(MSG_EVN_ACCOUNT_COMISSION)                    :
          type==DEAL_TYPE_COMMISSION_DAILY             ? CMessage::Text(MSG_EVN_ACCOUNT_COMISSION_DAILY)              :
          type==DEAL_TYPE_COMMISSION_MONTHLY           ? CMessage::Text(MSG_EVN_ACCOUNT_COMISSION_MONTHLY)            :
          type==DEAL_TYPE_COMMISSION_AGENT_DAILY       ? CMessage::Text(MSG_EVN_ACCOUNT_COMISSION_AGENT_DAILY)        :
          type==DEAL_TYPE_COMMISSION_AGENT_MONTHLY     ? CMessage::Text(MSG_EVN_ACCOUNT_COMISSION_AGENT_MONTHLY)      :
          type==DEAL_TYPE_INTEREST                     ? CMessage::Text(MSG_EVN_ACCOUNT_INTEREST)                     :
          type==DEAL_TYPE_BUY_CANCELED                ? CMessage::Text(MSG_EVN_BUY_CANCELLED)                        :
          type==DEAL_TYPE_SELL_CANCELED               ? CMessage::Text(MSG_EVN_SELL_CANCELLED)                        :
          type==DEAL_DIVIDEND                          ? CMessage::Text(MSG_EVN_DIVIDENT)                             :
          type==DEAL_DIVIDEND_FRANKED                  ? CMessage::Text(MSG_EVN_DIVIDENT_FRANKED)                     :
          type==DEAL_TAX                               ? CMessage::Text(MSG_EVN_TAX)                                  :
          CMessage::Text(MSG_POS_UNKNOWN_DEAL)
        );
  }
// Position
 //+------------------------------------------------------------------+
 //| Return the position name                                         |
 //+------------------------------------------------------------------+
 string PositionTypeDescription(const ENUM_POSITION_TYPE type)
  {
    return
        (
          type==POSITION_TYPE_BUY   ? "Buy"   :
          type==POSITION_TYPE_SELL  ? "Sell"  :
          CMessage::Text(MSG_POS_UNKNOWN_TYPE)
        );
  }
 //+------------------------------------------------------------------+
 //| Return position type by order type                               |
 //+------------------------------------------------------------------+
 ENUM_POSITION_TYPE PositionTypeByOrderType(ENUM_ORDER_TYPE type_order)
  {
    if(type_order==ORDER_TYPE_CLOSE_BY)
          return WRONG_VALUE;
    return ENUM_POSITION_TYPE(type_order%2);
  }
//Request
 //+------------------------------------------------------------------+
 //| Return the executed action type description                      |
 //+------------------------------------------------------------------+
 string RequestActionDescription(const MqlTradeRequest &request)
  {
    int code_descr=
        (
          request.action==TRADE_ACTION_DEAL     ? MSG_LIB_TEXT_REQUEST_ACTION_DEAL      :
          request.action==TRADE_ACTION_PENDING  ? MSG_LIB_TEXT_REQUEST_ACTION_PENDING   :
          request.action==TRADE_ACTION_SLTP     ? MSG_LIB_TEXT_REQUEST_ACTION_SLTP      :
          request.action==TRADE_ACTION_MODIFY   ? MSG_LIB_TEXT_REQUEST_ACTION_MODIFY    :
          request.action==TRADE_ACTION_REMOVE   ? MSG_LIB_TEXT_REQUEST_ACTION_REMOVE    :
          request.action==TRADE_ACTION_CLOSE_BY ? MSG_LIB_TEXT_REQUEST_ACTION_CLOSE_BY  :
          MSG_LIB_TEXT_REQUEST_ACTION_UNCNOWN
        );
    return CMessage::Text(MSG_LIB_TEXT_REQUEST_ACTION)+": "+CMessage::Text(code_descr);
  }
 //+------------------------------------------------------------------+
 //| Return the magic number value description                        |
 //+------------------------------------------------------------------+
 string RequestMagicDescription(const MqlTradeRequest &request)
  {
    return CMessage::Text(MSG_ORD_MAGIC)+": "+(string)request.magic;
  }
 //+------------------------------------------------------------------+
 //| Return the order ticket value description                        |
 //+------------------------------------------------------------------+
 string RequestOrderDescription(const MqlTradeRequest &request)
  {
    return CMessage::Text(MSG_LIB_TEXT_REQUEST_ORDER)+": "+(request.order>0 ? (string)request.order : CMessage::Text(MSG_LIB_PROP_NOT_SET));
  }
 //+------------------------------------------------------------------+
 //| Return the trading instrument name description                   |
 //+------------------------------------------------------------------+
 string RequestSymbolDescription(const MqlTradeRequest &request)
  {
    return CMessage::Text(MSG_LIB_TEXT_REQUEST_SYMBOL)+": "+request.symbol;
  }
 //+------------------------------------------------------------------+
 //| Return the request volume description                            |
 //+------------------------------------------------------------------+
 string RequestVolumeDescription(const MqlTradeRequest &request)
  {
    int dg =(int)DigitsLots(request.symbol);
    int dgl=(dg==0 ? 1 : dg);
    return CMessage::Text(MSG_LIB_TEXT_REQUEST_VOLUME)+": "+(request.volume>0 ? DoubleToString(request.volume,dgl) : CMessage::Text(MSG_LIB_PROP_NOT_SET));
  }
 //+------------------------------------------------------------------+
 //| Return the request price value description                       |
 //+------------------------------------------------------------------+
 string RequestPriceDescription(const MqlTradeRequest &request)
  {
    return CMessage::Text(MSG_LIB_TEXT_REQUEST_PRICE)+": "+(request.price>0 ? DoubleToString(request.price,(int)SymbolInfoInteger(request.symbol,SYMBOL_DIGITS)) : CMessage::Text(MSG_LIB_PROP_NOT_SET));
  }
 //+------------------------------------------------------------------+
 //| Return the request StopLimit order price description             |
 //+------------------------------------------------------------------+
 string RequestStopLimitDescription(const MqlTradeRequest &request)
  {
    return CMessage::Text(MSG_LIB_TEXT_REQUEST_STOPLIMIT)+": "+(request.stoplimit>0 ? DoubleToString(request.stoplimit,(int)SymbolInfoInteger(request.symbol,SYMBOL_DIGITS)) : CMessage::Text(MSG_LIB_PROP_NOT_SET));
  }
 //+------------------------------------------------------------------+
 //| Return the request StopLoss order price description              |
 //+------------------------------------------------------------------+
 string RequestStopLossDescription(const MqlTradeRequest &request)
  {
    return CMessage::Text(MSG_LIB_TEXT_REQUEST_SL)+": "+(request.sl>0 ? DoubleToString(request.sl,(int)SymbolInfoInteger(request.symbol,SYMBOL_DIGITS)) : CMessage::Text(MSG_LIB_PROP_NOT_SET));
  }
 //+------------------------------------------------------------------+
 //| Return the request TakeProfit order price description            |
 //+------------------------------------------------------------------+
 string RequestTakeProfitDescription(const MqlTradeRequest &request)
  {
    return CMessage::Text(MSG_LIB_TEXT_REQUEST_TP)+": "+(request.tp>0 ? DoubleToString(request.tp,(int)SymbolInfoInteger(request.symbol,SYMBOL_DIGITS)) : CMessage::Text(MSG_LIB_PROP_NOT_SET));
  }
 //+------------------------------------------------------------------+
 //| Return the request deviation size description                    |
 //+------------------------------------------------------------------+
 string RequestDeviationDescription(const MqlTradeRequest &request)
  {
    return CMessage::Text(MSG_LIB_TEXT_REQUEST_DEVIATION)+": "+(string)request.deviation;
  }
 //+------------------------------------------------------------------+
 //| Return the request order type description                        |
 //+------------------------------------------------------------------+
 string RequestTypeDescription(const MqlTradeRequest &request)
  {
    return CMessage::Text(MSG_LIB_TEXT_REQUEST_TYPE)+": "+OrderTypeDescription(request.type);
  }
 //+------------------------------------------------------------------+
 //| Return the request order filling mode description                |
 //+------------------------------------------------------------------+
 string RequestTypeFillingDescription(const MqlTradeRequest &request)
  {
    return CMessage::Text(MSG_LIB_TEXT_REQUEST_TYPE_FILLING)+": "+OrderTypeFillingDescription(request.type_filling);
  }
 //+------------------------------------------------------------------+
 //| Return the request order lifetime type description               |
 //+------------------------------------------------------------------+
 string RequestTypeTimeDescription(const MqlTradeRequest &request)
  {
    return CMessage::Text(MSG_LIB_TEXT_REQUEST_TYPE_TIME)+": "+OrderTypeTimeDescription(request.type_time);
  }
 //+------------------------------------------------------------------+
 //| Return the request order expiration time description             |
 //+------------------------------------------------------------------+
 string RequestExpirationDescription(const MqlTradeRequest &request)
  {
    return CMessage::Text(MSG_LIB_TEXT_REQUEST_EXPIRATION)+": "+(request.expiration>0 ? TimeToString(request.expiration) : CMessage::Text(MSG_LIB_PROP_NOT_SET));
  }
 //+------------------------------------------------------------------+
 //| Return the request order comment description                     |
 //+------------------------------------------------------------------+
 string RequestCommentDescription(const MqlTradeRequest &request)
  {
    return CMessage::Text(MSG_LIB_TEXT_REQUEST_COMMENT)+": "+(request.comment!="" && request.comment!=NULL ? "\""+request.comment+"\"" : CMessage::Text(MSG_LIB_PROP_NOT_SET));
  }
 //+------------------------------------------------------------------+
 //| Return the request position ticket description                   |
 //+------------------------------------------------------------------+
 string RequestPositionDescription(const MqlTradeRequest &request)
  {
    return CMessage::Text(MSG_LIB_TEXT_REQUEST_POSITION)+": "+(request.position>0 ? (string)request.position : CMessage::Text(MSG_LIB_PROP_NOT_SET));
  }
 //+------------------------------------------------------------------+
 //| Return the request opposite position ticket description          |
 //+------------------------------------------------------------------+
 string RequestPositionByDescription(const MqlTradeRequest &request)
  {
    return CMessage::Text(MSG_LIB_TEXT_REQUEST_POSITION_BY)+": "+(request.position_by>0 ? (string)request.position_by : CMessage::Text(MSG_LIB_PROP_NOT_SET));
  }
#endif // __TRADING_DELIB_MQH__