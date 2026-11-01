//+------------------------------------------------------------------+
//|                                         TradeActivityAuditor.mqh |
//|                                  Copyright 2026, MetaQuotes Ltd. |
//|                          https://www.mql5.com/en/users/lynnchris |
//+------------------------------------------------------------------+
#property copyright "Copyright 2026, Christian Benjamin."
#property link      "https://www.mql5.com/en/users/lynnchris"
#property version   "1.00"

#ifndef TRADE_ACTIVITY_AUDITOR_MQH
#define TRADE_ACTIVITY_AUDITOR_MQH

#include <Trade Audit/TradeAuditJournal.mqh>

//+------------------------------------------------------------------+
//| Coordinates transaction capture and history recovery             |
//+------------------------------------------------------------------+
class CTradeActivityAuditor
  {
private:
   CTradeAuditJournal   m_journal;
   string               m_stateFile;
   string               m_allowedSymbols[];
   int                  m_recoveryDays;
   string               m_recentKeys[];
   string               m_status;
   long                 m_login;
   string               m_server;
   bool                 m_fault;
   bool                 LoadState();
   bool                 SaveState();
   bool                 IsDuplicate(string key) const;
   void                 Remember(string key);
   bool                 SameAccount() const;
   bool                 IsSymbolAllowed(string symbol) const;
   string               DealSource(long reason) const;
   string               OrderSource(long reason) const;
   bool                 CompleteDealRecord(ulong ticket, STradeAuditRecord &record) const;
   bool                 CompleteOrderRecord(ulong ticket, STradeAuditRecord &record) const;
   bool                 CompleteActiveOrder(ulong ticket, STradeAuditRecord &record) const;
   bool                 Save(STradeAuditRecord &record);
   void                 CheckPolicy(STradeAuditRecord &record);
public:
   bool                 Initialize(string journalFile, string stateFile, string allowedSymbols, int recoveryDays);
   void                 Capture(const MqlTradeTransaction &trans,
                                const MqlTradeRequest &request,
                                const MqlTradeResult &result);
   void                 Recover();
   CTradeAuditJournal   * Journal();
   string               Status() const;
  };

//+------------------------------------------------------------------+
//| Returns access to the persistent audit journal                   |
//+------------------------------------------------------------------+
CTradeAuditJournal * CTradeActivityAuditor::Journal()
  {
   return(&m_journal);
  }

//+------------------------------------------------------------------+
//| Returns the current auditor status                               |
//+------------------------------------------------------------------+
string CTradeActivityAuditor::Status() const
  {
   if(!SameAccount())
      return("Account changed - reattach");
   if(m_journal.Error() != "")
      return("Journal error");
   return(m_status);
  }

//+------------------------------------------------------------------+
//| Checks the current account and server identity                   |
//+------------------------------------------------------------------+
bool CTradeActivityAuditor::SameAccount() const
  {
   return(m_login == AccountInfoInteger(ACCOUNT_LOGIN) && m_server == AccountInfoString(ACCOUNT_SERVER));
  }

//+------------------------------------------------------------------+
//| Checks persisted account identity metadata                  |
//+------------------------------------------------------------------+
bool CTradeActivityAuditor::LoadState()
  {
   if(!FileIsExist(m_stateFile))
      return(true);
   int h = FileOpen(m_stateFile, FILE_READ | FILE_CSV | FILE_ANSI, ';', CP_UTF8);
   if(h == INVALID_HANDLE)
      return(false);
   string version = FileReadString(h);
   long login = StringToInteger(FileReadString(h));
   string server = AuditDecode(FileReadString(h));
   FileClose(h);
   return(version == "P9-2" && login == m_login && server == m_server);
  }

//+------------------------------------------------------------------+
//| Saves diagnostic account metadata                            |
//+------------------------------------------------------------------+
bool CTradeActivityAuditor::SaveState()
  {
//--- State is diagnostic metadata; recovery identity comes from the journal.
   string pending = m_stateFile + ".tmp";
   int h = FileOpen(pending, FILE_WRITE | FILE_CSV | FILE_ANSI, ';', CP_UTF8);
   if(h == INVALID_HANDLE)
      return(false);
   ResetLastError();
   uint written = FileWrite(h,
                            "P9-2",
                            m_login,
                            AuditEncode(m_server),
                            TimeToString(TimeCurrent(), TIME_DATE | TIME_SECONDS));
   FileFlush(h);
   bool ok = written > 0 && GetLastError() == 0;
   FileClose(h);
   if(!ok)
      return(false);
   return(FileMove(pending, 0, m_stateFile, FILE_REWRITE));
  }

//+------------------------------------------------------------------+
//| Rejects a repeated live transaction key                          |
//+------------------------------------------------------------------+
bool CTradeActivityAuditor::IsDuplicate(string key) const
  {
   for(int i = 0; i < ArraySize(m_recentKeys); i++)
      if(m_recentKeys[i] == key)
         return(true);
   return(false);
  }

//+------------------------------------------------------------------+
//| Caches a successfully persisted deal addition                    |
//+------------------------------------------------------------------+
void CTradeActivityAuditor::Remember(string key)
  {
   int n = ArraySize(m_recentKeys);
   if(n < 256)
     {
      if(ArrayResize(m_recentKeys, n + 1) != n + 1)
         return;
      m_recentKeys[n] = key;
     }
   else
     {
      for(int i = 1; i < n; i++)
         m_recentKeys[i - 1] = m_recentKeys[i];
      m_recentKeys[n - 1] = key;
     }
  }

//+------------------------------------------------------------------+
//| Checks the optional symbol policy                                |
//+------------------------------------------------------------------+
bool CTradeActivityAuditor::IsSymbolAllowed(string symbol) const
  {
//--- An empty policy list leaves the auditor in observation mode
   if(ArraySize(m_allowedSymbols) == 0)
      return(true);
   for(int i = 0; i < ArraySize(m_allowedSymbols); i++)
      if(m_allowedSymbols[i] == symbol)
         return(true);
   return(false);
  }

//+------------------------------------------------------------------+
//| Returns the source stored with a historical deal                 |
//+------------------------------------------------------------------+
string CTradeActivityAuditor::DealSource(long reason) const
  {
   switch((ENUM_DEAL_REASON) reason)
     {
      case DEAL_REASON_CLIENT:
         return("DESKTOP");
      case DEAL_REASON_MOBILE:
         return("MOBILE");
      case DEAL_REASON_WEB:
         return("WEB");
      case DEAL_REASON_EXPERT:
         return("EXPERT");
      case DEAL_REASON_SL:
         return("STOP_LOSS");
      case DEAL_REASON_TP:
         return("TAKE_PROFIT");
      case DEAL_REASON_SO:
         return("STOP_OUT");
     }
   return("ACCOUNT");
  }

//+------------------------------------------------------------------+
//| Returns the source stored with a historical order                |
//+------------------------------------------------------------------+
string CTradeActivityAuditor::OrderSource(long reason) const
  {
   switch((ENUM_ORDER_REASON) reason)
     {
      case ORDER_REASON_CLIENT:
         return("DESKTOP");
      case ORDER_REASON_MOBILE:
         return("MOBILE");
      case ORDER_REASON_WEB:
         return("WEB");
      case ORDER_REASON_EXPERT:
         return("EXPERT");
      case ORDER_REASON_SL:
         return("STOP_LOSS");
      case ORDER_REASON_TP:
         return("TAKE_PROFIT");
      case ORDER_REASON_SO:
         return("STOP_OUT");
     }
   return("ACCOUNT");
  }

//+------------------------------------------------------------------+
//| Adds historical deal fields to an audit record                   |
//+------------------------------------------------------------------+
bool CTradeActivityAuditor::CompleteDealRecord(ulong ticket, STradeAuditRecord &record) const
  {
   if(!HistoryDealSelect(ticket))
      return(false);
   if(record.captureMode == "RECOVERED" || record.eventType == AUDIT_DEAL_ADDED)
      record.eventTime = (datetime) HistoryDealGetInteger(ticket, DEAL_TIME);
   record.symbol = HistoryDealGetString(ticket, DEAL_SYMBOL);
   record.source = DealSource(HistoryDealGetInteger(ticket, DEAL_REASON));
   record.action = EnumToString((ENUM_DEAL_TYPE) HistoryDealGetInteger(ticket, DEAL_TYPE));
   record.entryType = EnumToString((ENUM_DEAL_ENTRY) HistoryDealGetInteger(ticket, DEAL_ENTRY));
   record.volume = HistoryDealGetDouble(ticket, DEAL_VOLUME);
   record.price = HistoryDealGetDouble(ticket, DEAL_PRICE);
   record.stopLoss = HistoryDealGetDouble(ticket, DEAL_SL);
   record.takeProfit = HistoryDealGetDouble(ticket, DEAL_TP);
   record.magic = HistoryDealGetInteger(ticket, DEAL_MAGIC);
   record.orderTicket = (ulong) HistoryDealGetInteger(ticket, DEAL_ORDER);
   record.dealTicket = ticket;
   record.positionId = (ulong) HistoryDealGetInteger(ticket, DEAL_POSITION_ID);
   record.profit = HistoryDealGetDouble(ticket, DEAL_PROFIT);
   record.commission = HistoryDealGetDouble(ticket, DEAL_COMMISSION);
   record.swap = HistoryDealGetDouble(ticket, DEAL_SWAP);
   record.note += " history_object=1";
   return(true);
  }

//+------------------------------------------------------------------+
//| Adds historical order fields to an audit record                  |
//+------------------------------------------------------------------+
bool CTradeActivityAuditor::CompleteOrderRecord(ulong ticket, STradeAuditRecord &record) const
  {
   if(!HistoryOrderSelect(ticket))
      return(false);
   if(record.captureMode == "RECOVERED")
     {
      record.eventTime = (datetime) HistoryOrderGetInteger(ticket, ORDER_TIME_DONE);
      if(record.eventTime == 0)
         record.eventTime = (datetime) HistoryOrderGetInteger(ticket, ORDER_TIME_SETUP);
     }
   record.symbol = HistoryOrderGetString(ticket, ORDER_SYMBOL);
   record.source = OrderSource(HistoryOrderGetInteger(ticket, ORDER_REASON));
   record.action = EnumToString((ENUM_ORDER_TYPE) HistoryOrderGetInteger(ticket, ORDER_TYPE));
   record.volume = HistoryOrderGetDouble(ticket, ORDER_VOLUME_INITIAL);
   record.price = HistoryOrderGetDouble(ticket, ORDER_PRICE_OPEN);
   record.stopLoss = HistoryOrderGetDouble(ticket, ORDER_SL);
   record.takeProfit = HistoryOrderGetDouble(ticket, ORDER_TP);
   record.magic = HistoryOrderGetInteger(ticket, ORDER_MAGIC);
   record.orderTicket = ticket;
   record.positionId = (ulong) HistoryOrderGetInteger(ticket, ORDER_POSITION_ID);
   record.note += " history_object=1";
   return(true);
  }

//+------------------------------------------------------------------+
//| Adds fields from an order that is still active                   |
//+------------------------------------------------------------------+
bool CTradeActivityAuditor::CompleteActiveOrder(ulong ticket, STradeAuditRecord &record) const
  {
   if(!OrderSelect(ticket))
      return(false);
   record.symbol = OrderGetString(ORDER_SYMBOL);
   record.source = OrderSource(OrderGetInteger(ORDER_REASON));
   record.action = EnumToString((ENUM_ORDER_TYPE) OrderGetInteger(ORDER_TYPE));
   record.volume = OrderGetDouble(ORDER_VOLUME_CURRENT);
   record.price = OrderGetDouble(ORDER_PRICE_OPEN);
   record.stopLoss = OrderGetDouble(ORDER_SL);
   record.takeProfit = OrderGetDouble(ORDER_TP);
   record.magic = OrderGetInteger(ORDER_MAGIC);
   record.orderTicket = ticket;
   record.positionId = (ulong) OrderGetInteger(ORDER_POSITION_ID);
   return(true);
  }

//+------------------------------------------------------------------+
//| Adds account identity and writes one record                      |
//+------------------------------------------------------------------+
bool CTradeActivityAuditor::Save(STradeAuditRecord &record)
  {
   if(!SameAccount())
     {
      m_status = "Account changed - reattach";
      m_fault = true;
      return(false);
     }
   record.recordTime = TimeCurrent();
   record.accountLogin = m_login;
   record.server = m_server;
   if(!m_journal.Append(record))
     {
      m_status = "Journal error";
      m_fault = true;
      Print("[AUDIT] ", m_journal.Error(), "; reattach after resolving storage");
      return(false);
     }
   return(true);
  }

//+------------------------------------------------------------------+
//| Classifies a live entry against the optional symbol list         |
//+------------------------------------------------------------------+
void CTradeActivityAuditor::CheckPolicy(STradeAuditRecord &record)
  {
   if(record.eventType != AUDIT_DEAL_ADDED || IsSymbolAllowed(record.symbol))
      return;
   if(record.entryType != "DEAL_ENTRY_IN" && record.entryType != "DEAL_ENTRY_INOUT")
      return;
   STradeAuditRecord violation = record;
   violation.eventType = AUDIT_POSTTRADE_VIOLATION;
   violation.note = "Symbol is outside the auditor's optional allowed list";
   Save(violation);
  }

//+------------------------------------------------------------------+
//| Initializes storage, recovery, and optional policy settings      |
//+------------------------------------------------------------------+
bool CTradeActivityAuditor::Initialize(string journalFile,
                                       string stateFile,
                                       string allowedSymbols,
                                       int recoveryDays)
  {
   m_login = AccountInfoInteger(ACCOUNT_LOGIN);
   m_server = AccountInfoString(ACCOUNT_SERVER);
   m_fault = false;
   m_status = "Starting";
   if(recoveryDays < 1)
     {
      m_status = "Invalid recovery days";
      return(false);
     }
   m_recoveryDays = recoveryDays;
   string safeServer = m_server;
   string bad = "\\/:*?\"<>|";
   for(int i = 0; i < StringLen(bad); i++)
      StringReplace(safeServer, StringSubstr(bad, i, 1), "_");
   string identity = "_" + (string) m_login + "_" + safeServer;
   journalFile += identity + ".csv";
   m_stateFile = stateFile + identity + ".state";
   ArrayResize(m_recentKeys, 0);
   string values[];
   int count = StringSplit(allowedSymbols, ',', values);
   if(allowedSymbols == "")
      count = 0;
   if(ArrayResize(m_allowedSymbols, count) != count)
      return(false);
   for(int i = 0; i < count; i++)
     {
      StringTrimLeft(values[i]);
      StringTrimRight(values[i]);
      if(values[i] == "")
         return(false);
      m_allowedSymbols[i] = values[i];
     }
   if(!m_journal.Initialize(journalFile))
     {
      m_status = "Journal error";
      Print("[AUDIT] ", m_journal.Error());
      return(false);
     }
   if(!LoadState() || !SaveState())
     {
      m_status = "State error";
      m_fault = true;
      return(false);
     }
   return(true);
  }

//+------------------------------------------------------------------+
//| Converts one live transaction callback into an audit record      |
//+------------------------------------------------------------------+
void CTradeActivityAuditor::Capture(const MqlTradeTransaction &trans,
                                    const MqlTradeRequest &request,
                                    const MqlTradeResult &result)
  {
   if(!SameAccount())
     {
      m_fault = true;
      m_status = "Account changed - reattach";
      return;
     }
   if(m_fault)
      return;
   STradeAuditRecord r;
   ZeroMemory(r);
   r.eventTime = TimeCurrent();
   r.captureMode = "LIVE";
   r.source = "UNRESOLVED";
   r.note = "build=P9-2";
   string key = "";
   if(trans.type == TRADE_TRANSACTION_REQUEST)
     {
      r.eventType = AUDIT_REQUEST;
      r.requestAction = EnumToString(request.action);
      r.requestId = result.request_id;
      r.requestOrder = request.order;
      r.positionTicket = request.position;
      r.requestedVolume = request.volume;
      r.requestedPrice = request.price;
      r.requestedSL = request.sl;
      r.requestedTP = request.tp;
      r.symbol = request.symbol;
      r.volume = request.volume;
      r.price = request.price;
      r.stopLoss = request.sl;
      r.takeProfit = request.tp;
      r.magic = (long) request.magic;
      r.orderTicket = result.order > 0 ? result.order : request.order;
      r.dealTicket = result.deal;
      r.resultCode = result.retcode;
      r.resultMessage = result.comment;
      if(result.deal > 0)
         CompleteDealRecord(result.deal, r);
      else
         if(result.order > 0)
           {
            if(!CompleteActiveOrder(result.order, r))
               CompleteOrderRecord(result.order, r);
           }
      r.action = (request.action == TRADE_ACTION_DEAL ||
                  request.action == TRADE_ACTION_PENDING) ? EnumToString(request.type) : r.requestAction;
      if(request.position > 0 && PositionSelectByTicket(request.position))
         r.positionId = (ulong) PositionGetInteger(POSITION_IDENTIFIER);
      //--- Request observations are retained; similar requests can be deliberate.
     }
   else
     {
      r.symbol = trans.symbol;
      if(trans.type == TRADE_TRANSACTION_ORDER_ADD ||
         trans.type == TRADE_TRANSACTION_ORDER_UPDATE ||
         trans.type == TRADE_TRANSACTION_ORDER_DELETE ||
         trans.type == TRADE_TRANSACTION_HISTORY_ADD ||
         trans.type == TRADE_TRANSACTION_HISTORY_UPDATE ||
         trans.type == TRADE_TRANSACTION_HISTORY_DELETE)
        {
         r.orderTicket = trans.order;
         r.volume = trans.volume;
         r.price = trans.price;
         r.stopLoss = trans.price_sl;
         r.takeProfit = trans.price_tp;
         r.note += "; state=" + EnumToString(trans.order_state) + "; expiration=" + TimeToString(trans.time_expiration,
                   TIME_DATE | TIME_SECONDS);
        }
      else
         if(trans.type == TRADE_TRANSACTION_DEAL_ADD ||
            trans.type == TRADE_TRANSACTION_DEAL_UPDATE ||
            trans.type == TRADE_TRANSACTION_DEAL_DELETE)
           {
            r.orderTicket = trans.order;
            r.dealTicket = trans.deal;
            r.positionTicket = trans.position;
            r.volume = trans.volume;
            r.price = trans.price;
            r.stopLoss = trans.price_sl;
            r.takeProfit = trans.price_tp;
           }
         else
            if(trans.type == TRADE_TRANSACTION_POSITION)
              {
               r.positionTicket = trans.position;
               r.volume = trans.volume;
               r.price = trans.price;
               r.stopLoss = trans.price_sl;
               r.takeProfit = trans.price_tp;
              }
      if(r.positionTicket > 0 && PositionSelectByTicket(r.positionTicket))
         r.positionId = (ulong) PositionGetInteger(POSITION_IDENTIFIER);
      switch(trans.type)
        {
         case TRADE_TRANSACTION_ORDER_ADD:
            r.eventType = AUDIT_ORDER_ADDED;
            r.action = EnumToString(trans.order_type);
            CompleteActiveOrder(trans.order, r);
            break;
         case TRADE_TRANSACTION_ORDER_UPDATE:
            r.eventType = AUDIT_ORDER_UPDATED;
            r.action = EnumToString(trans.order_type);
            CompleteActiveOrder(trans.order, r);
            break;
         case TRADE_TRANSACTION_ORDER_DELETE:
            r.eventType = AUDIT_ORDER_REMOVED;
            r.action = EnumToString(trans.order_type);
            CompleteOrderRecord(trans.order, r);
            break;
         case TRADE_TRANSACTION_DEAL_ADD:
            r.eventType = AUDIT_DEAL_ADDED;
            r.action = EnumToString(trans.deal_type);
            CompleteDealRecord(trans.deal, r);
            break;
         case TRADE_TRANSACTION_DEAL_UPDATE:
            r.eventType = AUDIT_DEAL_UPDATED;
            r.action = EnumToString(trans.deal_type);
            CompleteDealRecord(trans.deal, r);
            break;
         case TRADE_TRANSACTION_DEAL_DELETE:
            r.eventType = AUDIT_DEAL_REMOVED;
            r.action = "DEAL_DELETED";
            break;
         case TRADE_TRANSACTION_POSITION:
            r.eventType = AUDIT_POSITION_CHANGED;
            r.action = "POSITION_UPDATE";
            break;
         case TRADE_TRANSACTION_HISTORY_ADD:
            r.eventType = AUDIT_HISTORY_ORDER_ADDED;
            CompleteOrderRecord(trans.order, r);
            break;
         case TRADE_TRANSACTION_HISTORY_UPDATE:
            r.eventType = AUDIT_HISTORY_ORDER_UPDATED;
            CompleteOrderRecord(trans.order, r);
            break;
         case TRADE_TRANSACTION_HISTORY_DELETE:
            r.eventType = AUDIT_HISTORY_ORDER_REMOVED;
            r.action = "HISTORY_ORDER_DELETED";
            break;
         default:
            return;
        }
      //--- Cache only durable object additions. Repeated updates remain observable.
      if(trans.type == TRADE_TRANSACTION_DEAL_ADD && trans.deal > 0)
         key = "DEAL_ADD|" + (string) trans.deal;
      if(key != "" && IsDuplicate(key))
         return;
     }
   if(!Save(r))
      return;
   if(key != "")
      Remember(key);
   CheckPolicy(r);
   if(!m_fault)
      m_status = "Live";
  }

//+------------------------------------------------------------------+
//| Reconciles historical objects against persisted identities       |
//+------------------------------------------------------------------+
void CTradeActivityAuditor::Recover()
  {
   if(!SameAccount())
     {
      m_fault = true;
      m_status = "Account changed - reattach";
      return;
     }
   if(m_fault || m_journal.Error() != "")
      return;
   m_status = "Recovering";
   ulong knownOrders[], knownDeals[];
   if(!m_journal.RecordedObjects(knownOrders, knownDeals))
     {
      m_status = "Journal error";
      m_fault = true;
      return;
     }
   datetime from = TimeCurrent() - m_recoveryDays * 86400;
   if(!HistorySelect(from, TimeCurrent()))
     {
      m_status = "History error";
      return;
     }
   int no = HistoryOrdersTotal(), nd = HistoryDealsTotal();
   ulong orders[], deals[];
   if(ArrayResize(orders, no) != no || ArrayResize(deals, nd) != nd)
     {
      m_status = "Allocation error";
      return;
     }
//--- Snapshot both lists before either completion helper changes selection.
   for(int i = 0; i < no; i++)
     {
      orders[i] = HistoryOrderGetTicket(i);
      if(orders[i] == 0)
        {
         m_status = "History error";
         return;
        }
     }
   for(int i = 0; i < nd; i++)
     {
      deals[i] = HistoryDealGetTicket(i);
      if(deals[i] == 0)
        {
         m_status = "History error";
         return;
        }
     }
   bool incomplete = false;
   for(int i = 0; i < no; i++)
     {
      int k = ArraySize(knownOrders) > 0 ? ArrayBsearch(knownOrders, orders[i]) : -1;
      if(k >= 0 && k < ArraySize(knownOrders) && knownOrders[k] == orders[i])
         continue;
      STradeAuditRecord r;
      ZeroMemory(r);
      r.eventType = AUDIT_ORDER_RECOVERED;
      r.captureMode = "RECOVERED";
      r.note = "build=P9-2; historical object discovered by scan";
      if(!CompleteOrderRecord(orders[i], r))
        {
         incomplete = true;
         continue;
        }
      if(!Save(r))
         return;
     }
   for(int i = 0; i < nd; i++)
     {
      int k = ArraySize(knownDeals) > 0 ? ArrayBsearch(knownDeals, deals[i]) : -1;
      if(k >= 0 && k < ArraySize(knownDeals) && knownDeals[k] == deals[i])
         continue;
      STradeAuditRecord r;
      ZeroMemory(r);
      r.eventType = AUDIT_DEAL_RECOVERED;
      r.captureMode = "RECOVERED";
      r.note = "build=P9-2; original request context unavailable";
      if(!CompleteDealRecord(deals[i], r))
        {
         incomplete = true;
         continue;
        }
      if(!Save(r))
         return;
     }
   if(!SaveState())
     {
      m_status = "State error";
      m_fault = true;
      return;
     }
   m_status = incomplete ? "History error" : "Up to date";
  }

#endif
//+------------------------------------------------------------------+