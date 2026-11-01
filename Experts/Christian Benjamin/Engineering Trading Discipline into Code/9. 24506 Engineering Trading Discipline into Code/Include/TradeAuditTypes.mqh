//+------------------------------------------------------------------+
//|                                              TradeAuditTypes.mqh |
//|                                  Copyright 2026, MetaQuotes Ltd. |
//|                          https://www.mql5.com/en/users/lynnchris |
//+------------------------------------------------------------------+
#property copyright "Copyright 2026, Christian Benjamin."
#property link      "https://www.mql5.com/en/users/lynnchris"
#property version   "1.00"
#ifndef TRADE_AUDIT_TYPES_MQH
#define TRADE_AUDIT_TYPES_MQH

//+------------------------------------------------------------------+
//| Defines the activity types recorded by the auditor               |
//+------------------------------------------------------------------+
enum ENUM_AUDIT_ACTIVITY
  {
   AUDIT_REQUEST = 0,
   AUDIT_ORDER_ADDED,
   AUDIT_ORDER_UPDATED,
   AUDIT_ORDER_REMOVED,
   AUDIT_DEAL_ADDED,
   AUDIT_POSITION_CHANGED,
   AUDIT_HISTORY_ORDER_ADDED,
   AUDIT_HISTORY_ORDER_UPDATED,
   AUDIT_HISTORY_ORDER_REMOVED,
   AUDIT_DEAL_RECOVERED,
   AUDIT_ORDER_RECOVERED,
   AUDIT_DEAL_UPDATED,
   AUDIT_DEAL_REMOVED,
   AUDIT_POSTTRADE_VIOLATION
  };

//+------------------------------------------------------------------+
//| Stores the complete data associated with one audit event         |
//+------------------------------------------------------------------+
struct STradeAuditRecord
  {
   datetime             recordTime;
   datetime             eventTime;
   ENUM_AUDIT_ACTIVITY  eventType;
   string               captureMode;
   long                 accountLogin;
   string               server;
   string               symbol;
   string               source;
   string               action;
   string               entryType;
   double               volume;
   double               price;
   double               stopLoss;
   double               takeProfit;
   long                 magic;
   ulong                orderTicket;
   ulong                dealTicket;
   ulong                positionId;
   long                 resultCode;
   string               resultMessage;
   double               profit;
   double               commission;
   double               swap;
   string               note;
   string               requestAction;
   ulong                requestId;
   ulong                positionTicket;
   ulong                requestOrder;
   double               requestedVolume;
   double               requestedPrice;
   double               requestedSL;
   double               requestedTP;
  };

//+------------------------------------------------------------------+
//| Returns the journal name assigned to one activity event          |
//+------------------------------------------------------------------+
string AuditActivityText(const ENUM_AUDIT_ACTIVITY eventType)
  {
   switch(eventType)
     {
      case AUDIT_REQUEST:
         return("TRADE_REQUEST");
      case AUDIT_ORDER_ADDED:
         return("ORDER_ADDED");
      case AUDIT_ORDER_UPDATED:
         return("ORDER_UPDATED");
      case AUDIT_ORDER_REMOVED:
         return("ORDER_REMOVED");
      case AUDIT_DEAL_ADDED:
         return("DEAL_ADDED");
      case AUDIT_POSITION_CHANGED:
         return("POSITION_CHANGED");
      case AUDIT_HISTORY_ORDER_ADDED:
         return("HISTORY_ORDER_ADDED");
      case AUDIT_HISTORY_ORDER_UPDATED:
         return("HISTORY_ORDER_UPDATED");
      case AUDIT_HISTORY_ORDER_REMOVED:
         return("HISTORY_ORDER_REMOVED");
      case AUDIT_DEAL_RECOVERED:
         return("DEAL_RECOVERED");
      case AUDIT_ORDER_RECOVERED:
         return("ORDER_RECOVERED");
      case AUDIT_DEAL_UPDATED:
         return("DEAL_UPDATED");
      case AUDIT_DEAL_REMOVED:
         return("DEAL_REMOVED");
      case AUDIT_POSTTRADE_VIOLATION:
         return("POSTTRADE_VIOLATION");
     }
   return("UNKNOWN");
  }

#endif
//+------------------------------------------------------------------+