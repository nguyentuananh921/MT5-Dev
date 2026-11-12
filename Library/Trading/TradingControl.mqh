#ifndef __TRADINGCONTROL_MQH__
#define __TRADINGCONTROL_MQH__
//+------------------------------------------------------------------+
//|                                               TradingControl.mqh |
//|                        Copyright 2019, MetaQuotes Software Corp. |
//|                             https://mql5.com/en/users/artmedia70 |
//+------------------------------------------------------------------+
//--- Ported from V3 Trading\TradingControl.mqh (2026 1031): RAM only (the pending requests); the StopLost / Trailing / lot by risk part is not ported (RiskManagement is made again)
#property copyright "Copyright 2019, MetaQuotes Software Corp."
#property link      "https://mql5.com/en/users/artmedia70"
#property version   "1.00"
#property strict    // Necessary for mql4
//+------------------------------------------------------------------+
//| Include files                                                    |
//+------------------------------------------------------------------+
#include "Trading.mqh"
 #ifndef CTRADINGCONTROL_MQH_DECLARATION
 #define CTRADINGCONTROL_MQH_DECLARATION
//+------------------------------------------------------------------+
//| Class for managing pending trading requests                      |
//+------------------------------------------------------------------+
class CTradingControl : public CTrading
  {
    private:
     //--- Set actual order/position data to a pending request object
      void                 SetOrderActualProperties(CPendRequest *req_obj,const COrder *order);
     //--- Handler of pending requests created (1) by error code, (2) by request
      void                 OnPReqByErrCodeHandler(CPendRequest *req_obj,const int index);
      void                 OnPReqByRequestHandler(CPendRequest *req_obj,const int index);
     //--- Check a pending request relevance (activated or not)
      bool                 CheckPReqRelevance(CPendRequest *req_obj,const MqlTradeRequest &request,const int index);
     //--- Update relevant values of controlled properties in pending request objects,
      void                 RefreshControlActualDatas(CPendRequest *req_obj,const CSymbol *symbol);
     //--- Return the relevant (1) account, (2) symbol, (3) event data to control activation
      double               GetActualDataAccount(const int property);
      double               GetActualDataSymbol(const int property,const CSymbol *symbol);
      double               GetActualDataEvent(const int property);
   
    public:
     //--- Return itself
      CTradingControl     *GetObject(void)            { return &this;   }
     //--- Timer
      virtual void         OnTimer(void);
     //--- Constructor
      CTradingControl();
     //--- (1) Create a pending request (1) to open a position, (2) to place a pending order
      template<typename SL,typename TP> 
      int                  CreatePReqPosition(const ENUM_POSITION_TYPE type,
                                          const double volume,
                                          const string symbol,
                                          const ulong magic=ULONG_MAX,
                                          const SL sl=0,
                                          const TP tp=0,
                                          const uchar group_id1=0,
                                          const uchar group_id2=0,
                                          const string comment=NULL,
                                          const ulong deviation=ULONG_MAX,
                                          const ENUM_ORDER_TYPE_FILLING type_filling=WRONG_VALUE);
      template<typename PS,typename PL,typename SL,typename TP>
      int                  CreatePReqOrder(const ENUM_ORDER_TYPE order_type,
                                          const double volume,
                                          const string symbol,
                                          const PS price_set,
                                          const PL price_limit=0,
                                          const SL sl=0,
                                          const TP tp=0,
                                          const ulong magic=ULONG_MAX,
                                          const uchar group_id1=0,
                                          const uchar group_id2=0,
                                          const string comment=NULL,
                                          const datetime expiration=0,
                                          const ENUM_ORDER_TYPE_TIME type_time=WRONG_VALUE,
                                          const ENUM_ORDER_TYPE_FILLING type_filling=WRONG_VALUE);
     //--- Create a pending request (1) for full and partial position closure, (2) for closing a position by an opposite one, (3) for removing an order
      int                  CreatePReqClose(const ulong ticket,const double volume=WRONG_VALUE,const string comment=NULL,const ulong deviation=ULONG_MAX);
      int                  CreatePReqCloseBy(const ulong ticket,const ulong ticket_by);
      int                  CreatePreqDelete(const ulong ticket);
     //--- Create a pending request to modify (1) position's stop orders, (2) an order
      template<typename SL,typename TP> 
      int                  CreatePReqModifyPosition(const ulong ticket,const SL sl=WRONG_VALUE,const TP tp=WRONG_VALUE);
      template<typename PS,typename PL,typename SL,typename TP>
      int                  CreatePReqModifyOrder(const ulong ticket,
                                                const PS price=WRONG_VALUE,
                                                const SL sl=WRONG_VALUE,
                                                const TP tp=WRONG_VALUE,
                                                const PL limit=WRONG_VALUE,
                                                datetime expiration=WRONG_VALUE,
                                                const ENUM_ORDER_TYPE_TIME type_time=WRONG_VALUE,
                                                const ENUM_ORDER_TYPE_FILLING type_filling=WRONG_VALUE);
      
     //--- Set pending request activation criteria
      bool                 SetNewActivationProperties(const uchar id,
                                                      const ENUM_PEND_REQ_ACTIVATION_SOURCE source,
                                                      const int property,
                                                      const double control_value,
                                                      const ENUM_COMPARER_TYPE comparer_type,
                                                      const double actual_value);
     //--- Close every open position on (symbol,dir) - queries the live broker state directly,
     //--- no CMarketCollection dependency needed.
       void                 ClosePositions(const string symbol, const ENUM_POSITION_TYPE dir);
     //--- Modify SL (or TP) to new_price on every open position on (symbol,dir), keeping each
     //--- position's own current TP (or SL) untouched.
       bool                 ModifyPositions(const string symbol, const ENUM_POSITION_TYPE dir, const bool modify_sl, const double new_price);
     //--- A new order from the panel: market, limit or stop (V3; the magic number is still fixed)
      bool                           SendNewOrder(const string symbol, const ENUM_POSITION_TYPE dir, const double lot, const int order_type_idx, const double price);
  };
 #endif // CTRADINGCONTROL_MQH_DECLARATION
 #ifndef CTRADINGCONTROL_MQH_IMPLEMENTATION
 #define CTRADINGCONTROL_MQH_IMPLEMENTATION
 //+------------------------------------------------------------------+
 //| Constructor                                                      |
 //+------------------------------------------------------------------+
 CTradingControl::CTradingControl()
  {
   this.m_list_request.Clear();
   this.m_list_request.Sort();
  }
 //+------------------------------------------------------------------+
 //| Timer                                                            |
 //+------------------------------------------------------------------+
 void CTradingControl::OnTimer(void)
  {
   //--- In a loop by the list of pending requests
   int total=this.m_list_request.Total();
   for(int i=total-1;i>WRONG_VALUE;i--)
     {
      //--- receive the next request object
      CPendRequest *req_obj=this.m_list_request.At(i);
      if(req_obj==NULL)
         continue;
      //--- If a request object is created by an error code, use the handler of objects created by the error code
      if(req_obj.TypeRequest()==PEND_REQ_TYPE_ERROR)
         this.OnPReqByErrCodeHandler(req_obj,i);
      //--- Otherwise, this is an object created by request - use the handler of objects created by request
      else
         this.OnPReqByRequestHandler(req_obj,i);
     }
  }
 //+------------------------------------------------------------------+
 //| The handler of pending requests created by error code            |
 //+------------------------------------------------------------------+
 void CTradingControl::OnPReqByErrCodeHandler(CPendRequest *req_obj,const int index)
  {
   //--- get the request structure and the symbol object a trading operation should be performed for
      MqlTradeRequest request=req_obj.MqlRequest();
      CSymbol *symbol_obj=this.m_symbol_collection.GetSymbolObjByName(request.symbol);
      if(symbol_obj==NULL || !symbol_obj.RefreshRates())
         return;
      
   //--- Set the flag disabling trading in the terminal by two properties simultaneously
   //--- (the AutoTrading button in the terminal and the Allow Automated Trading option in the EA settings)
   //--- If any of the two properties is 'false', the flag is 'false' as well
      bool terminal_trade_allowed=::TerminalInfoInteger(TERMINAL_TRADE_ALLOWED);
      terminal_trade_allowed &=::MQLInfoInteger(MQL_TRADE_ALLOWED);
   //--- if the error has been caused by trading disabled on the terminal side and has been eliminated
      if(req_obj.Retcode()==10027 && terminal_trade_allowed)
      {
         //--- if the current attempt has not exceeded the defined number of trading attempts yet
         if(req_obj.CurrentAttempt()<req_obj.TotalAttempts()+1)
         {
            //--- Set the request creation time equal to its creation time minus waiting time, i.e. send the request immediately
            //--- Also, decrease the number of a successful attempt since during the next attempt, its number is increased, and if this is the last attempt,
            //--- it is not executed. However, this is related to fixing the error cause by a user, which means we need to give more time for the last attempt
            req_obj.SetTimeCreate(req_obj.TimeCreate()-req_obj.WaitingMSC());
            req_obj.SetCurrentAttempt(uchar(req_obj.CurrentAttempt()>0 ? req_obj.CurrentAttempt()-1 : 0));
         }
      }
   //--- if the current attempt exceeds the defined number of trading attempts,
   //--- or the current time exceeds the waiting time of all attempts
   //--- remove the current request object and proceed to the next (leave the method for the external loop)
      if(req_obj.CurrentAttempt()>req_obj.TotalAttempts() || req_obj.CurrentAttempt()>=UCHAR_MAX || 
         (long)symbol_obj.Time()>long(req_obj.TimeCreate()+req_obj.WaitingMSC()*(req_obj.TotalAttempts()+1)))
      {
         if(this.m_log_level>LOG_LEVEL_NO)
            ::Print(req_obj.Header(),": ",CMessage::Text(MSG_LIB_TEXT_PEND_REQUEST_DELETED));
         this.m_list_request.Delete(index);
         return;
      }
   //--- Check the relevance of a pending request and exit to the external loop if the request is handled or an error occurs
      if(!this.CheckPReqRelevance(req_obj,request,index))
         return;
      
   //--- Set the request activation time in the request object
      req_obj.SetTimeActivate(req_obj.TimeCreate()+req_obj.WaitingMSC()*(req_obj.CurrentAttempt()+1));
      
   //--- If the current time is less than the request activation time,
   //--- this is not the request time - move on to the next request in the list (leave the method for the external loop)
      if((long)symbol_obj.Time()<(long)req_obj.TimeActivate())
         return;
      
   //--- Set the attempt number in the request object
      req_obj.SetCurrentAttempt(uchar(req_obj.CurrentAttempt()+1));
      
   //--- Display the number of a trading attempt in the journal
      if(this.m_log_level>LOG_LEVEL_NO)
      {
         ::Print(CMessage::Text(MSG_LIB_TEXT_RE_TRY_N)+(string)req_obj.CurrentAttempt()+":");
         req_obj.PrintShort();
      }
      
   //--- Depending on the type of action performed in the trading request 
      switch(request.action)
      {
         //--- Opening/closing a position
         case TRADE_ACTION_DEAL :
            //--- If no ticket is present in the request structure - this is opening a position
            if(request.position==0)
               this.OpenPosition((ENUM_POSITION_TYPE)request.type,request.volume,request.symbol,request.magic,request.sl,request.tp,request.comment,request.deviation,request.type_filling);
            //--- If the ticket is present in the request structure - this is a position closure
            else
               this.ClosePosition(request.position,request.volume,request.comment,request.deviation);
            break;
         //--- Modify StopLoss/TakeProfit position
         case TRADE_ACTION_SLTP :
            this.ModifyPosition(request.position,request.sl,request.tp);
            break;
         //--- Close by an opposite one
         case TRADE_ACTION_CLOSE_BY :
            this.ClosePositionBy(request.position,request.position_by);
            break;
         //---
         //--- Place a pending order
         case TRADE_ACTION_PENDING :
            this.PlaceOrder(request.type,request.volume,request.symbol,request.price,request.stoplimit,request.sl,request.tp,request.magic,request.comment,request.expiration,request.type_time,request.type_filling);
            break;
         //--- Modify a pending order
         case TRADE_ACTION_MODIFY :
            this.ModifyOrder(request.order,request.price,request.sl,request.tp,request.stoplimit,request.expiration,request.type_time,request.type_filling);
            break;
         //--- Remove a pending order
         case TRADE_ACTION_REMOVE :
            this.DeleteOrder(request.order);
            break;
         //---
         default:
            break;
      }  
  }
 //+------------------------------------------------------------------+
 //| The handler of pending requests created by request               |
 //+------------------------------------------------------------------+
 void CTradingControl::OnPReqByRequestHandler(CPendRequest *req_obj,const int index)
  {
   //--- get the request structure and the symbol object a trading operation should be performed for
      MqlTradeRequest request=req_obj.MqlRequest();
      CSymbol *symbol_obj=this.m_symbol_collection.GetSymbolObjByName(request.symbol);
      if(symbol_obj==NULL || !symbol_obj.RefreshRates())
         return;
   //--- Check the relevance of a pending request and exit to the external loop if the request is handled or an error occurs
      if(!this.CheckPReqRelevance(req_obj,request,index))
         return;

   //--- Update relevant data on request activation conditions
      this.RefreshControlActualDatas(req_obj,symbol_obj);
      
   //--- If all pending request activation conditions are met
      if(req_obj.IsAllComparisonCompleted())
      {
         //--- Set the attempt number in the request object
         req_obj.SetCurrentAttempt(uchar(req_obj.CurrentAttempt()+1));
         //--- Adjust prices for a pending order relative to the current price and get the request again
         if(request.action==TRADE_ACTION_PENDING)
         {
            req_obj.CorrectMqlPricesByCurrentPrice(PositionTypeByOrderType(request.type)==POSITION_TYPE_BUY ? symbol_obj.AskLast() : symbol_obj.BidLast());
            request=req_obj.MqlRequest();
         }
         //--- Display the request activation message in the journal
         if(this.m_log_level>LOG_LEVEL_NO)
         {
            ::Print(CMessage::Text(MSG_LIB_TEXT_REQUEST_ACTIVATED)+(string)req_obj.ID()+":");
            req_obj.PrintShort();
         }
         //--- Depending on the type of action performed in the trading request 
         switch(request.action)
         {
            //--- Opening/closing a position
            case TRADE_ACTION_DEAL :
               //--- If no ticket is present in the request structure - this is opening a position
               if(request.position==0)
                  this.OpenPosition((ENUM_POSITION_TYPE)request.type,request.volume,request.symbol,request.magic,request.sl,request.tp,request.comment,request.deviation,request.type_filling);
               //--- If the ticket is present in the request structure - this is a position closure
               else
                  this.ClosePosition(request.position,request.volume,request.comment,request.deviation);
               break;
            //--- Modify StopLoss/TakeProfit position
            case TRADE_ACTION_SLTP :
               this.ModifyPosition(request.position,request.sl,request.tp);
               break;
            //--- Close by an opposite one
            case TRADE_ACTION_CLOSE_BY :
               this.ClosePositionBy(request.position,request.position_by);
               break;
            //---
            //--- Place a pending order
            case TRADE_ACTION_PENDING :
               this.PlaceOrder(request.type,request.volume,request.symbol,request.price,request.stoplimit,request.sl,request.tp,request.magic,request.comment,request.expiration,request.type_time,request.type_filling);
               break;
            //--- Modify a pending order
            case TRADE_ACTION_MODIFY :
               this.ModifyOrder(request.order,request.price,request.sl,request.tp,request.stoplimit,request.expiration,request.type_time,request.type_filling);
               break;
            //--- Remove a pending order
            case TRADE_ACTION_REMOVE :
               this.DeleteOrder(request.order);
               break;
            //---
            default:
               break;
         }  
      }
  }
 //+------------------------------------------------------------------+
 //| Check the pending request relevance                              |
 //+------------------------------------------------------------------+
 bool CTradingControl::CheckPReqRelevance(CPendRequest *req_obj,const MqlTradeRequest &request,const int index)
  {
   //--- If this is a position opening or placing a pending order
      if((req_obj.Action()==TRADE_ACTION_DEAL && req_obj.Position()==0) || req_obj.Action()==TRADE_ACTION_PENDING)
      {
         //--- Get the pending request ID
         uchar id=this.GetPendReqID((uint)request.magic);
         //--- If the order/position is present, the request is handled: remove it and proceed to the next (leave the method for the external loop)
         if(this.IsPresentOrderByID(id))
         {
            if(this.m_log_level>LOG_LEVEL_NO)
               ::Print(req_obj.Header(),": ",CMessage::Text(MSG_LIB_TEXT_PEND_REQUEST_EXECUTED));
            this.m_list_request.Delete(index);
            return false;
         }
      }
   //--- Otherwise: full and partial position closure, removing an order, modifying order parameters and position stop orders
      else
      {
         CArrayObj *list=NULL;
         //--- if this is a position closure, including a closure by an opposite one
         if((req_obj.Action()==TRADE_ACTION_DEAL && req_obj.Position()>0) || req_obj.Action()==TRADE_ACTION_CLOSE_BY)
         {
            //--- Get a position with the necessary ticket from the list of open positions
            //--- If the market has no such position, the request is handled: remove it and proceed to the next (leave the method for the external loop)
            if(this.GetOrderObjByTicket(req_obj.Position())==NULL)
            {
               if(this.m_log_level>LOG_LEVEL_NO)
                  ::Print(req_obj.Header(),": ",CMessage::Text(MSG_LIB_TEXT_PEND_REQUEST_EXECUTED));
               this.m_list_request.Delete(index);
               return false;
            }
            //--- Otherwise, if the position still exists, this is a partial closure
            else
            {
               //--- If there is an event
               if(this.m_trade_event_collection.IsEvent())
               {
                  //--- Get the list of all account trading events
                  list=this.m_trade_event_collection.GetList();
                  if(list==NULL)
                     return false;
                  //--- In the loop from the end of the account trading event list
                  int events_total=list.Total();
                  for(int j=events_total-1; j>WRONG_VALUE; j--)
                  {
                     //--- get the next trading event
                     CTradeEvent *event=list.At(j);
                     if(event==NULL)
                        continue;
                     //--- If this event is a partial closure or there was a partial closure when closing by an opposite one
                     if(event.TypeEvent()==TRADE_EVENT_POSITION_CLOSED_PARTIAL || event.TypeEvent()==TRADE_EVENT_POSITION_CLOSED_PARTIAL_BY_POS)
                     {
                        //--- If a position ticket in a trading event coincides with the ticket in a pending trading request
                        if(event.TicketFirstOrderPosition()==req_obj.Position())
                        {
                           //--- Get a position object from the list of market positions
                           COrder *order=this.GetOrderObjByTicket(req_obj.Position());
                           if(order==NULL)
                              break;
                           //--- Set actual position data to the pending request object
                           this.SetOrderActualProperties(req_obj,order);
                           //--- If (executed request volume + unexecuted request volume) is equal to the requested volume in a pending request -
                           //--- the request is handled: remove it and break the loop by the list of account trading events
                           if(req_obj.GetProperty(PEND_REQ_PROP_MQL_REQ_VOLUME)==event.VolumeOrderExecuted()+event.VolumeOrderCurrent())
                           {
                              if(this.m_log_level>LOG_LEVEL_NO)
                                 ::Print(req_obj.Header(),": ",CMessage::Text(MSG_LIB_TEXT_PEND_REQUEST_EXECUTED));
                              this.m_list_request.Delete(index);
                              break;
                           }
                        }
                     }
                  }
                  //--- If a handled pending request object was removed by the trading event list in the loop, move on to the next one (leave the method for the external loop)
                  if(::CheckPointer(req_obj)==POINTER_INVALID)
                     return false;
               }
            }
         }
         //--- If this is a modification of position stop orders
         if(req_obj.Action()==TRADE_ACTION_SLTP)
         {
            //--- Get the list of all account trading events
            list=this.m_trade_event_collection.GetList();
            if(list==NULL)
               return false;
            //--- In the loop from the end of the account trading event list
            int events_total=list.Total();
            for(int j=events_total-1; j>WRONG_VALUE; j--)
            {
               //--- get the next trading event
               CTradeEvent *event=list.At(j);
               if(event==NULL)
                  continue;
               //--- If this is a change of the position's stop orders
               if(event.TypeEvent()>TRADE_EVENT_MODIFY_ORDER_TP)
               {
                  //--- If a position ticket in a trading event coincides with the ticket in a pending trading request
                  if(event.TicketFirstOrderPosition()==req_obj.Position())
                  {
                     //--- Get a position object from the list of market positions
                     COrder *order=this.GetOrderObjByTicket(req_obj.Position());
                     if(order==NULL)
                        break;
                     //--- Set actual position data to the pending request object
                     this.SetOrderActualProperties(req_obj,order);
                     //--- If all modifications have worked out -
                     //--- the request is handled: remove it and break the loop by the list of account trading events
                     if(req_obj.IsCompleted())
                     {
                        if(this.m_log_level>LOG_LEVEL_NO)
                           ::Print(req_obj.Header(),": ",CMessage::Text(MSG_LIB_TEXT_PEND_REQUEST_EXECUTED));
                        this.m_list_request.Delete(index);
                        break;
                     }
                  }
               }
            }
            //--- If a handled pending request object was removed by the trading event list in the loop, move on to the next one (leave the method for the external loop)
            if(::CheckPointer(req_obj)==POINTER_INVALID)
               return false;
         }
         //--- If this is a pending order removal
         if(req_obj.Action()==TRADE_ACTION_REMOVE)
         {
            //--- Look for the removed pending order with the necessary ticket in the historical list
            bool is_removed=false;
            CArrayObj *list_history=this.m_history_collection.GetList();
            for(int h=0;h<list_history.Total();h++)
              {
               COrder *removed=list_history.At(h);
               if(removed!=NULL && removed.Status()==ORDER_STATUS_HISTORY_PENDING && removed.Ticket()==req_obj.Order())
                 {
                  is_removed=true;
                  break;
                 }
              }
            //--- If the order is present, the request is handled: remove it and proceed to the next (leave the method for the external loop)
            if(is_removed)
            {
               if(this.m_log_level>LOG_LEVEL_NO)
                  ::Print(req_obj.Header(),": ",CMessage::Text(MSG_LIB_TEXT_PEND_REQUEST_EXECUTED));
               this.m_list_request.Delete(index);
               return false;
            }
         }
         //--- If this is a pending order modification
         if(req_obj.Action()==TRADE_ACTION_MODIFY)
         {
            //--- Get the list of all account trading events
            list=this.m_trade_event_collection.GetList();
            if(list==NULL)
               return false;
            //--- In the loop from the end of the account trading event list
            int events_total=list.Total();
            for(int j=events_total-1; j>WRONG_VALUE; j--)
            {
               //--- get the next trading event
               CTradeEvent *event=list.At(j);
               if(event==NULL)
                  continue;
               //--- If this event involves any change of modified pending order parameters
               if(event.TypeEvent()>TRADE_EVENT_TRIGGERED_STOP_LIMIT_ORDER && event.TypeEvent()<TRADE_EVENT_MODIFY_POSITION_SL_TP)
               {
                  //--- If an order ticket in a trading event coincides with the ticket in a pending trading request
                  if(event.TicketOrderEvent()==req_obj.Order())
                  {
                     //--- Get an order object from the list
                     COrder *order=this.GetOrderObjByTicket(req_obj.Order());
                     if(order==NULL)
                        break;
                     //--- Set actual order data to the pending request object
                     this.SetOrderActualProperties(req_obj,order);
                     //--- If all modifications have worked out -
                     //--- the request is handled: remove it and break the loop by the list of account trading events
                     if(req_obj.IsCompleted())
                     {
                        if(this.m_log_level>LOG_LEVEL_NO)
                           ::Print(req_obj.Header(),": ",CMessage::Text(MSG_LIB_TEXT_PEND_REQUEST_EXECUTED));
                        this.m_list_request.Delete(index);
                        break;
                     }
                  }
               }
            }
         }
      }
   //--- Exit if the pending request object has been removed after checking its operation (leave the method for the external loop)
      return(::CheckPointer(req_obj)==POINTER_INVALID ? false : true);
  }
 //+------------------------------------------------------------------+
 //| Return the relevant account data to control activation           |
 //+------------------------------------------------------------------+
 double CTradingControl::GetActualDataAccount(const int property)
  {
   switch(property)
    {
     case PEND_REQ_ACTIVATE_BY_ACCOUNT_LEVERAGE             : return (double)this.m_account.Leverage();
     case PEND_REQ_ACTIVATE_BY_ACCOUNT_LIMIT_ORDERS         : return (double)this.m_account.LimitOrders();
     case PEND_REQ_ACTIVATE_BY_ACCOUNT_TRADE_ALLOWED        : return (double)this.m_account.TradeAllowed();
     case PEND_REQ_ACTIVATE_BY_ACCOUNT_TRADE_EXPERT         : return (double)this.m_account.TradeExpert();
     case PEND_REQ_ACTIVATE_BY_ACCOUNT_BALANCE              : return this.m_account.Balance();
     case PEND_REQ_ACTIVATE_BY_ACCOUNT_CREDIT               : return this.m_account.Credit();
     case PEND_REQ_ACTIVATE_BY_ACCOUNT_PROFIT               : return this.m_account.Profit();
     case PEND_REQ_ACTIVATE_BY_ACCOUNT_EQUITY               : return this.m_account.Equity();
     case PEND_REQ_ACTIVATE_BY_ACCOUNT_MARGIN               : return this.m_account.Margin();
     case PEND_REQ_ACTIVATE_BY_ACCOUNT_MARGIN_FREE          : return this.m_account.MarginFree();
     case PEND_REQ_ACTIVATE_BY_ACCOUNT_MARGIN_LEVEL         : return this.m_account.MarginLevel();
     case PEND_REQ_ACTIVATE_BY_ACCOUNT_MARGIN_INITIAL       : return this.m_account.MarginInitial();
     case PEND_REQ_ACTIVATE_BY_ACCOUNT_MARGIN_MAINTENANCE   : return this.m_account.MarginMaintenance();
     case PEND_REQ_ACTIVATE_BY_ACCOUNT_ASSETS               : return this.m_account.Assets();
     case PEND_REQ_ACTIVATE_BY_ACCOUNT_LIABILITIES          : return this.m_account.Liabilities();
     case PEND_REQ_ACTIVATE_BY_ACCOUNT_COMMISSION_BLOCKED   : return this.m_account.ComissionBlocked();
     default: return EMPTY_VALUE;
    }
  }
 //+------------------------------------------------------------------+
 //| Return the relevant symbol data to control activation            |
 //+------------------------------------------------------------------+
 double CTradingControl::GetActualDataSymbol(const int property,const CSymbol *symbol)
  {
   switch(property)
    {
     case PEND_REQ_ACTIVATE_BY_SYMBOL_BID                         : return symbol.Bid();
     case PEND_REQ_ACTIVATE_BY_SYMBOL_ASK                         : return symbol.Ask();
     case PEND_REQ_ACTIVATE_BY_SYMBOL_LAST                        : return symbol.Last();
     case PEND_REQ_ACTIVATE_BY_SYMBOL_SESSION_DEALS               : return (double)symbol.SessionDeals();
     case PEND_REQ_ACTIVATE_BY_SYMBOL_SESSION_BUY_ORDERS          : return (double)symbol.SessionBuyOrders();
     case PEND_REQ_ACTIVATE_BY_SYMBOL_SESSION_SELL_ORDERS         : return (double)symbol.SessionSellOrders();
     case PEND_REQ_ACTIVATE_BY_SYMBOL_VOLUME                      : return (double)symbol.Volume();
     case PEND_REQ_ACTIVATE_BY_SYMBOL_VOLUMEHIGH                  : return (double)symbol.VolumeHigh();
     case PEND_REQ_ACTIVATE_BY_SYMBOL_VOLUMELOW                   : return (double)symbol.VolumeLow();
     case PEND_REQ_ACTIVATE_BY_SYMBOL_TIME                        : return (double)symbol.Time()/1000;
     case PEND_REQ_ACTIVATE_BY_SYMBOL_SPREAD                      : return symbol.Spread();
     case PEND_REQ_ACTIVATE_BY_SYMBOL_START_TIME                  : return (double)symbol.StartTime();
     case PEND_REQ_ACTIVATE_BY_SYMBOL_EXPIRATION_TIME             : return (double)symbol.ExpirationTime();
     case PEND_REQ_ACTIVATE_BY_SYMBOL_TRADE_STOPS_LEVEL           : return symbol.TradeStopLevel();
     case PEND_REQ_ACTIVATE_BY_SYMBOL_TRADE_FREEZE_LEVEL          : return symbol.TradeFreezeLevel();
     case PEND_REQ_ACTIVATE_BY_SYMBOL_BIDHIGH                     : return symbol.BidHigh();
     case PEND_REQ_ACTIVATE_BY_SYMBOL_BIDLOW                      : return symbol.BidLow();
     case PEND_REQ_ACTIVATE_BY_SYMBOL_ASKHIGH                     : return symbol.AskHigh();
     case PEND_REQ_ACTIVATE_BY_SYMBOL_ASKLOW                      : return symbol.AskLow();
     case PEND_REQ_ACTIVATE_BY_SYMBOL_LASTHIGH                    : return symbol.LastHigh();
     case PEND_REQ_ACTIVATE_BY_SYMBOL_LASTLOW                     : return symbol.LastLow();
     case PEND_REQ_ACTIVATE_BY_SYMBOL_VOLUME_REAL                 : return symbol.VolumeReal();
     case PEND_REQ_ACTIVATE_BY_SYMBOL_VOLUMEHIGH_REAL             : return symbol.VolumeHighReal();
     case PEND_REQ_ACTIVATE_BY_SYMBOL_VOLUMELOW_REAL              : return symbol.VolumeLowReal();
     case PEND_REQ_ACTIVATE_BY_SYMBOL_OPTION_STRIKE               : return symbol.OptionStrike();
     case PEND_REQ_ACTIVATE_BY_SYMBOL_TRADE_ACCRUED_INTEREST      : return symbol.TradeAccuredInterest();
     case PEND_REQ_ACTIVATE_BY_SYMBOL_TRADE_FACE_VALUE            : return symbol.TradeFaceValue();
     case PEND_REQ_ACTIVATE_BY_SYMBOL_TRADE_LIQUIDITY_RATE        : return symbol.TradeLiquidityRate();
     case PEND_REQ_ACTIVATE_BY_SYMBOL_SWAP_LONG                   : return symbol.SwapLong();
     case PEND_REQ_ACTIVATE_BY_SYMBOL_SWAP_SHORT                  : return symbol.SwapShort();
     case PEND_REQ_ACTIVATE_BY_SYMBOL_SESSION_VOLUME              : return symbol.SessionVolume();
     case PEND_REQ_ACTIVATE_BY_SYMBOL_SESSION_TURNOVER            : return symbol.SessionTurnover();
     case PEND_REQ_ACTIVATE_BY_SYMBOL_SESSION_INTEREST            : return symbol.SessionInterest();
     case PEND_REQ_ACTIVATE_BY_SYMBOL_SESSION_BUY_ORDERS_VOLUME   : return symbol.SessionBuyOrdersVolume();
     case PEND_REQ_ACTIVATE_BY_SYMBOL_SESSION_SELL_ORDERS_VOLUME  : return symbol.SessionSellOrdersVolume();
     case PEND_REQ_ACTIVATE_BY_SYMBOL_SESSION_OPEN                : return symbol.SessionOpen();
     case PEND_REQ_ACTIVATE_BY_SYMBOL_SESSION_CLOSE               : return symbol.SessionClose();
     case PEND_REQ_ACTIVATE_BY_SYMBOL_SESSION_AW                  : return symbol.SessionAW();
     case PEND_REQ_ACTIVATE_BY_SYMBOL_SESSION_PRICE_SETTLEMENT    : return symbol.SessionPriceSettlement();
     case PEND_REQ_ACTIVATE_BY_SYMBOL_SESSION_PRICE_LIMIT_MIN     : return symbol.SessionPriceLimitMin();
     case PEND_REQ_ACTIVATE_BY_SYMBOL_SESSION_PRICE_LIMIT_MAX     : return symbol.SessionPriceLimitMax();
     default: return EMPTY_VALUE;
    }
  }
 //+------------------------------------------------------------------+
 //| Return the relevant event data to control activation             |
 //+------------------------------------------------------------------+
 double CTradingControl::GetActualDataEvent(const int property)
  {
   if(this.m_trade_event_collection.IsEvent())
     {
      ENUM_TRADE_EVENT event=this.m_trade_event_collection.GetLastTradeEvent();
      switch(property)
       {
        case PEND_REQ_ACTIVATE_BY_EVENT_POSITION_OPENED                       : return event==TRADE_EVENT_POSITION_OPENED;
        case PEND_REQ_ACTIVATE_BY_EVENT_POSITION_CLOSED                       : return event==TRADE_EVENT_POSITION_CLOSED;
        case PEND_REQ_ACTIVATE_BY_EVENT_PENDING_ORDER_PLASED                  : return event==TRADE_EVENT_PENDING_ORDER_PLASED;
        case PEND_REQ_ACTIVATE_BY_EVENT_PENDING_ORDER_REMOVED                 : return event==TRADE_EVENT_PENDING_ORDER_REMOVED;
        case PEND_REQ_ACTIVATE_BY_EVENT_ACCOUNT_CREDIT                        : return event==TRADE_EVENT_ACCOUNT_CREDIT;
        case PEND_REQ_ACTIVATE_BY_EVENT_ACCOUNT_CHARGE                        : return event==TRADE_EVENT_ACCOUNT_CHARGE;
        case PEND_REQ_ACTIVATE_BY_EVENT_ACCOUNT_CORRECTION                    : return event==TRADE_EVENT_ACCOUNT_CORRECTION;
        case PEND_REQ_ACTIVATE_BY_EVENT_ACCOUNT_BONUS                         : return event==TRADE_EVENT_ACCOUNT_BONUS;
        case PEND_REQ_ACTIVATE_BY_EVENT_ACCOUNT_COMISSION                     : return event==TRADE_EVENT_ACCOUNT_COMISSION;
        case PEND_REQ_ACTIVATE_BY_EVENT_ACCOUNT_COMISSION_DAILY               : return event==TRADE_EVENT_ACCOUNT_COMISSION_DAILY;
        case PEND_REQ_ACTIVATE_BY_EVENT_ACCOUNT_COMISSION_MONTHLY             : return event==TRADE_EVENT_ACCOUNT_COMISSION_MONTHLY;
        case PEND_REQ_ACTIVATE_BY_EVENT_ACCOUNT_COMISSION_AGENT_DAILY         : return event==TRADE_EVENT_ACCOUNT_COMISSION_AGENT_DAILY;
        case PEND_REQ_ACTIVATE_BY_EVENT_ACCOUNT_COMISSION_AGENT_MONTHLY       : return event==TRADE_EVENT_ACCOUNT_COMISSION_AGENT_MONTHLY;
        case PEND_REQ_ACTIVATE_BY_EVENT_ACCOUNT_INTEREST                      : return event==TRADE_EVENT_ACCOUNT_INTEREST;
        case PEND_REQ_ACTIVATE_BY_EVENT_BUY_CANCELLED                         : return event==TRADE_EVENT_BUY_CANCELLED;
        case PEND_REQ_ACTIVATE_BY_EVENT_SELL_CANCELLED                        : return event==TRADE_EVENT_SELL_CANCELLED;
        case PEND_REQ_ACTIVATE_BY_EVENT_DIVIDENT                              : return event==TRADE_EVENT_DIVIDENT;
        case PEND_REQ_ACTIVATE_BY_EVENT_DIVIDENT_FRANKED                      : return event==TRADE_EVENT_DIVIDENT_FRANKED;
        case PEND_REQ_ACTIVATE_BY_EVENT_TAX                                   : return event==TRADE_EVENT_TAX;
        case PEND_REQ_ACTIVATE_BY_EVENT_ACCOUNT_BALANCE_REFILL                : return event==TRADE_EVENT_ACCOUNT_BALANCE_REFILL;
        case PEND_REQ_ACTIVATE_BY_EVENT_ACCOUNT_BALANCE_WITHDRAWAL            : return event==TRADE_EVENT_ACCOUNT_BALANCE_WITHDRAWAL;
        case PEND_REQ_ACTIVATE_BY_EVENT_PENDING_ORDER_ACTIVATED               : return event==TRADE_EVENT_PENDING_ORDER_ACTIVATED;
        case PEND_REQ_ACTIVATE_BY_EVENT_PENDING_ORDER_ACTIVATED_PARTIAL       : return event==TRADE_EVENT_PENDING_ORDER_ACTIVATED_PARTIAL;
        case PEND_REQ_ACTIVATE_BY_EVENT_POSITION_OPENED_PARTIAL               : return event==TRADE_EVENT_POSITION_OPENED_PARTIAL;
        case PEND_REQ_ACTIVATE_BY_EVENT_POSITION_CLOSED_PARTIAL               : return event==TRADE_EVENT_POSITION_CLOSED_PARTIAL;
        case PEND_REQ_ACTIVATE_BY_EVENT_POSITION_CLOSED_BY_POS                : return event==TRADE_EVENT_POSITION_CLOSED_BY_POS;
        case PEND_REQ_ACTIVATE_BY_EVENT_POSITION_CLOSED_PARTIAL_BY_POS        : return event==TRADE_EVENT_POSITION_CLOSED_PARTIAL_BY_POS;
        case PEND_REQ_ACTIVATE_BY_EVENT_POSITION_CLOSED_BY_SL                 : return event==TRADE_EVENT_POSITION_CLOSED_BY_SL;
        case PEND_REQ_ACTIVATE_BY_EVENT_POSITION_CLOSED_BY_TP                 : return event==TRADE_EVENT_POSITION_CLOSED_BY_TP;
        case PEND_REQ_ACTIVATE_BY_EVENT_POSITION_CLOSED_PARTIAL_BY_SL         : return event==TRADE_EVENT_POSITION_CLOSED_PARTIAL_BY_SL;
        case PEND_REQ_ACTIVATE_BY_EVENT_POSITION_CLOSED_PARTIAL_BY_TP         : return event==TRADE_EVENT_POSITION_CLOSED_PARTIAL_BY_TP;
        case PEND_REQ_ACTIVATE_BY_EVENT_POSITION_REVERSED_BY_MARKET           : return event==TRADE_EVENT_POSITION_REVERSED_BY_MARKET;
        case PEND_REQ_ACTIVATE_BY_EVENT_POSITION_REVERSED_BY_PENDING          : return event==TRADE_EVENT_POSITION_REVERSED_BY_PENDING;
        case PEND_REQ_ACTIVATE_BY_EVENT_POSITION_REVERSED_BY_MARKET_PARTIAL   : return event==TRADE_EVENT_POSITION_REVERSED_BY_MARKET_PARTIAL;
        case PEND_REQ_ACTIVATE_BY_EVENT_POSITION_VOLUME_ADD_BY_MARKET         : return event==TRADE_EVENT_POSITION_VOLUME_ADD_BY_MARKET;
        case PEND_REQ_ACTIVATE_BY_EVENT_POSITION_VOLUME_ADD_BY_PENDING        : return event==TRADE_EVENT_POSITION_VOLUME_ADD_BY_PENDING;
        case PEND_REQ_ACTIVATE_BY_EVENT_MODIFY_ORDER_PRICE                    : return event==TRADE_EVENT_MODIFY_ORDER_PRICE;
        case PEND_REQ_ACTIVATE_BY_EVENT_MODIFY_ORDER_PRICE_SL                 : return event==TRADE_EVENT_MODIFY_ORDER_PRICE_SL;
        case PEND_REQ_ACTIVATE_BY_EVENT_MODIFY_ORDER_PRICE_TP                 : return event==TRADE_EVENT_MODIFY_ORDER_PRICE_TP;
        case PEND_REQ_ACTIVATE_BY_EVENT_MODIFY_ORDER_PRICE_SL_TP              : return event==TRADE_EVENT_MODIFY_ORDER_PRICE_SL_TP;
        case PEND_REQ_ACTIVATE_BY_EVENT_MODIFY_ORDER_SL_TP                    : return event==TRADE_EVENT_MODIFY_ORDER_SL_TP;
        case PEND_REQ_ACTIVATE_BY_EVENT_MODIFY_ORDER_SL                       : return event==TRADE_EVENT_MODIFY_ORDER_SL;
        case PEND_REQ_ACTIVATE_BY_EVENT_MODIFY_ORDER_TP                       : return event==TRADE_EVENT_MODIFY_ORDER_TP;
        case PEND_REQ_ACTIVATE_BY_EVENT_MODIFY_POSITION_SL_TP                 : return event==TRADE_EVENT_MODIFY_POSITION_SL_TP;
        case PEND_REQ_ACTIVATE_BY_EVENT_MODIFY_POSITION_SL                    : return event==TRADE_EVENT_MODIFY_POSITION_SL;
        case PEND_REQ_ACTIVATE_BY_EVENT_MODIFY_POSITION_TP                    : return event==TRADE_EVENT_MODIFY_POSITION_TP;
        case PEND_REQ_ACTIVATE_BY_EVENT_POSITION_VOL_ADD_BY_MARKET_PARTIAL    : return event==TRADE_EVENT_POSITION_VOLUME_ADD_BY_MARKET_PARTIAL;
        case PEND_REQ_ACTIVATE_BY_EVENT_POSITION_VOL_ADD_BY_PENDING_PARTIAL   : return event==TRADE_EVENT_POSITION_VOLUME_ADD_BY_PENDING_PARTIAL;
        case PEND_REQ_ACTIVATE_BY_EVENT_TRIGGERED_STOP_LIMIT_ORDER            : return event==TRADE_EVENT_TRIGGERED_STOP_LIMIT_ORDER;
        case PEND_REQ_ACTIVATE_BY_EVENT_POSITION_REVERSED_BY_PENDING_PARTIAL  : return event==TRADE_EVENT_POSITION_REVERSED_BY_PENDING_PARTIAL;
        default: return EMPTY_VALUE;
       }
     }
   return EMPTY_VALUE;
  }
 //+------------------------------------------------------------------+
 //| Update relevant values of controlled properties                  |
 //| in pending request objects                                       |
 //+------------------------------------------------------------------+
 void CTradingControl::RefreshControlActualDatas(CPendRequest *req_obj,const CSymbol *symbol)
  {
   //--- Exit if a request object has a request type based on an error code
      if(req_obj.GetProperty(PEND_REQ_PROP_TYPE)==PEND_REQ_TYPE_ERROR)
         return;
      double res=EMPTY_VALUE;
   //--- In the loop by all request object activation conditions,
      uint total=req_obj.GetActivationCriterionTotal();
      for(uint i=0;i<total;i++)
      {
         //--- get the activation source
         ENUM_PEND_REQ_ACTIVATION_SOURCE source=req_obj.GetActivationSource(i);
         //--- receive the current value of a controlled property
         double value=req_obj.GetActivationActualValue(i),actual=EMPTY_VALUE;
         //--- Depending on the activation source,
         //--- write the current value of a controlled property to the activation conditions data array
         switch((int)source)
         {
            //--- Account
            case PEND_REQ_ACTIVATION_SOURCE_ACCOUNT   :  
               actual=this.GetActualDataAccount(req_obj.GetActivationProperty(i));
               req_obj.SetActivationActualValue(i,(actual!=EMPTY_VALUE ? actual : value));
            break;
            //--- Symbol
            case PEND_REQ_ACTIVATION_SOURCE_SYMBOL    :
               actual=this.GetActualDataSymbol(req_obj.GetActivationProperty(i),symbol);
               req_obj.SetActivationActualValue(i,(actual!=EMPTY_VALUE ? actual : value));
            break;
            //--- Event
            case PEND_REQ_ACTIVATION_SOURCE_EVENT     :
               actual=this.GetActualDataEvent(req_obj.GetActivationProperty(i));
               req_obj.SetActivationActualValue(i,(actual!=EMPTY_VALUE ? actual : value));
            break;
            //--- Default is EMPTY_VALUE
            default:
            break;
         }
      }
  }
 //+------------------------------------------------------------------+
 //| Set order/position data to a pending request object              |
 //+------------------------------------------------------------------+
 void CTradingControl::SetOrderActualProperties(CPendRequest *req_obj,const COrder *order)
  {
   req_obj.SetActualExpiration(order.TimeExpiration());
   req_obj.SetActualPrice(order.PriceOpen());
   req_obj.SetActualSL(order.StopLoss());
   req_obj.SetActualStopLimit(order.PriceStopLimit());
   req_obj.SetActualTP(order.TakeProfit());
   req_obj.SetActualTypeFilling(order.TypeFilling());
   req_obj.SetActualTypeTime(order.TypeTime());
   req_obj.SetActualVolume(order.Volume());
  }
 //+------------------------------------------------------------------+
 //| Create a pending request for opening a position                  |
 //+------------------------------------------------------------------+
 template<typename SL,typename TP> 
 int CTradingControl::CreatePReqPosition(const ENUM_POSITION_TYPE type,
                                        const double volume,
                                        const string symbol,
                                        const ulong magic=ULONG_MAX,
                                        const SL sl=0,
                                        const TP tp=0,
                                        const uchar group_id1=0,
                                        const uchar group_id2=0,
                                        const string comment=NULL,
                                        const ulong deviation=ULONG_MAX,
                                        const ENUM_ORDER_TYPE_FILLING type_filling=WRONG_VALUE)
  {
   //--- If the global trading ban flag is set, exit and return WRONG_VALUE
      if(this.IsTradingDisable())
      {
         if(this.m_log_level>LOG_LEVEL_NO)
            ::Print(DFUN,CMessage::Text(MSG_LIB_TEXT_TRADING_DISABLE));
         return WRONG_VALUE;
      }
   //--- Set the error flag as "no errors"
      this.m_error_reason_flags=TRADE_REQUEST_ERR_FLAG_NO_ERROR;
      ENUM_ORDER_TYPE order_type=(ENUM_ORDER_TYPE)type;
      ENUM_ACTION_TYPE action=(ENUM_ACTION_TYPE)order_type;
   //--- Get a symbol object by a symbol name.
      CSymbol *symbol_obj=this.m_symbol_collection.GetSymbolObjByName(symbol);
   //--- If failed to get - write the "internal error" flag, display the message in the journal and return WRONG_VALUE
      if(symbol_obj==NULL)
      {
         this.m_error_reason_flags=TRADE_REQUEST_ERR_FLAG_INTERNAL_ERR;
         if(this.m_log_level>LOG_LEVEL_NO)
            ::Print(DFUN,CMessage::Text(MSG_LIB_SYS_ERROR_FAILED_GET_SYM_OBJ));
         return WRONG_VALUE;
      }
   //--- get a trading object from a symbol object
      CTradeObj *trade_obj=symbol_obj.GetTradeObj();
   //--- If failed to get - write the "internal error" flag, display the message in the journal and return WRONG_VALUE
      if(trade_obj==NULL)
      {
         this.m_error_reason_flags=TRADE_REQUEST_ERR_FLAG_INTERNAL_ERR;
         if(this.m_log_level>LOG_LEVEL_NO)
            ::Print(DFUN,CMessage::Text(MSG_LIB_SYS_ERROR_FAILED_GET_TRADE_OBJ));
         return WRONG_VALUE;
      }
   //--- Set the prices
   //--- If failed to set - write the "internal error" flag, set the error code in the return structure,
   //--- display the message in the journal and return WRONG_VALUE
      if(!this.SetPrices(order_type,0,sl,tp,0,DFUN,symbol_obj))
      {
         this.m_error_reason_flags=TRADE_REQUEST_ERR_FLAG_INTERNAL_ERR;
         trade_obj.SetResultRetcode(10021);
         trade_obj.SetResultComment(CMessage::Text(trade_obj.GetResultRetcode()));
         if(this.m_log_level>LOG_LEVEL_NO)
            ::Print(DFUN,CMessage::Text(10021));   // No quotes to process the request
         return WRONG_VALUE;
      }
   //--- Look for the least of the possible IDs. If failed to find, return WRONG_VALUE
      int id=this.GetFreeID();
      if(id<1)
      {
         //--- No free IDs to create a pending request
         if(this.m_log_level>LOG_LEVEL_NO)
            ::Print(DFUN,CMessage::Text(MSG_LIB_TEXT_PEND_REQUEST_NO_FREE_IDS));
         return WRONG_VALUE;
      }

   //--- Write the volume, deviation, comment and filling type to the request structure
      this.m_request.volume=volume;
      this.m_request.deviation=(deviation==ULONG_MAX ? trade_obj.GetDeviation() : deviation);
      this.m_request.comment=(comment==NULL ? trade_obj.GetComment() : comment);
      this.m_request.type_filling=(type_filling>WRONG_VALUE ? type_filling : trade_obj.GetTypeFilling());
   //--- Write pending request object ID to the magic number, add group IDs to the magic number value
   //--- and fill in the remaining unfilled trading request structure fields
      uint mn=(magic==ULONG_MAX ? (uint)trade_obj.GetMagic() : (uint)magic);
      this.SetPendReqID((uchar)id,mn);
      if(group_id1>0)
         this.SetGroupID1(group_id1,mn);
      if(group_id2>0)
         this.SetGroupID2(group_id2,mn);
      this.m_request.magic=mn;
      this.m_request.action=TRADE_ACTION_DEAL;
      this.m_request.symbol=symbol_obj.Name();
      this.m_request.type=order_type;
   //--- As a result of creating a pending trading request, return either its ID or -1 if unsuccessful
      if(this.CreatePendingRequest(PEND_REQ_STATUS_OPEN,(uchar)id,1,ulong(END_TIME-(ulong)::TimeCurrent()),this.m_request,0,symbol_obj,NULL))
         return id;
      return WRONG_VALUE;
  }
 //+------------------------------------------------------------------+
 //| Create a pending request to place a pending order                |
 //+------------------------------------------------------------------+
  template<typename PS,typename PL,typename SL,typename TP>
 int CTradingControl::CreatePReqOrder(const ENUM_ORDER_TYPE order_type,
                                     const double volume,
                                     const string symbol,
                                     const PS price_set,
                                     const PL price_limit=0,
                                     const SL sl=0,
                                     const TP tp=0,
                                     const ulong magic=ULONG_MAX,
                                     const uchar group_id1=0,
                                     const uchar group_id2=0,
                                     const string comment=NULL,
                                     const datetime expiration=0,
                                     const ENUM_ORDER_TYPE_TIME type_time=WRONG_VALUE,
                                     const ENUM_ORDER_TYPE_FILLING type_filling=WRONG_VALUE)
  {
   //--- If the global trading ban flag is set, exit and return WRONG_VALUE
      if(this.IsTradingDisable())
      {
         if(this.m_log_level>LOG_LEVEL_NO)
            ::Print(DFUN,CMessage::Text(MSG_LIB_TEXT_TRADING_DISABLE));
         return WRONG_VALUE;
      }
   //--- Set the error flag as "no errors"
      this.m_error_reason_flags=TRADE_REQUEST_ERR_FLAG_NO_ERROR;
      ENUM_ACTION_TYPE action=(ENUM_ACTION_TYPE)order_type;
   //--- Get a symbol object by a symbol name
      CSymbol *symbol_obj=this.m_symbol_collection.GetSymbolObjByName(symbol);
      if(symbol_obj==NULL)
      {
         this.m_error_reason_flags=TRADE_REQUEST_ERR_FLAG_INTERNAL_ERR;
         if(this.m_log_level>LOG_LEVEL_NO)
            ::Print(DFUN,CMessage::Text(MSG_LIB_SYS_ERROR_FAILED_GET_SYM_OBJ));
         return WRONG_VALUE;
      }
   //--- Get a trading object from a symbol object
      CTradeObj *trade_obj=symbol_obj.GetTradeObj();
      if(trade_obj==NULL)
      {
         this.m_error_reason_flags=TRADE_REQUEST_ERR_FLAG_INTERNAL_ERR;
         if(this.m_log_level>LOG_LEVEL_NO)
            ::Print(DFUN,CMessage::Text(MSG_LIB_SYS_ERROR_FAILED_GET_TRADE_OBJ));
         return WRONG_VALUE; 
      }
   //--- Set the prices
   //--- If failed to set - write the "internal error" flag, set the error code in the return structure,
   //--- display the message in the journal and return WRONG_VALUE
      if(!this.SetPrices(order_type,price_set,sl,tp,price_limit,DFUN,symbol_obj))
      {
         this.m_error_reason_flags=TRADE_REQUEST_ERR_FLAG_INTERNAL_ERR;
         trade_obj.SetResultRetcode(10021);
         trade_obj.SetResultComment(CMessage::Text(trade_obj.GetResultRetcode()));
         if(this.m_log_level>LOG_LEVEL_NO)
            ::Print(DFUN,CMessage::Text(10021));   // No quotes to process the request
         return WRONG_VALUE;
      }
   //--- Look for the least of the possible IDs. If failed to find, return WRONG_VALUE
      int id=this.GetFreeID();
      if(id<1)
      {
         //--- No free IDs to create a pending request
         if(this.m_log_level>LOG_LEVEL_NO)
            ::Print(DFUN,CMessage::Text(MSG_LIB_TEXT_PEND_REQUEST_NO_FREE_IDS));
         return WRONG_VALUE;
      }

   //--- Write the volume, comment, as well as expiration and filling types to the request structure
      this.m_request.volume=volume;
      this.m_request.comment=(comment==NULL ? trade_obj.GetComment() : comment);
      this.m_request.type_time=(type_time>WRONG_VALUE ? type_time : trade_obj.GetTypeExpiration());
      this.m_request.type_filling=(type_filling>WRONG_VALUE ? type_filling : trade_obj.GetTypeFilling());
   //--- Write the request ID to the magic number, while a symbol name is set in the request structure,
   //--- trading operation and order types
      uint mn=(magic==ULONG_MAX ? (uint)trade_obj.GetMagic() : (uint)magic);
      this.SetPendReqID((uchar)id,mn);
      if(group_id1>0)
         this.SetGroupID1(group_id1,mn);
      if(group_id2>0)
         this.SetGroupID2(group_id2,mn);
      this.m_request.magic=mn;
      this.m_request.symbol=symbol_obj.Name();
      this.m_request.action=TRADE_ACTION_PENDING;
      this.m_request.type=order_type;
   //--- As a result of creating a pending trading request, return either its ID or -1 if unsuccessful
      if(this.CreatePendingRequest(PEND_REQ_STATUS_PLACE,(uchar)id,1,ulong(END_TIME-(ulong)::TimeCurrent()),this.m_request,0,symbol_obj,NULL))
         return id;
      return WRONG_VALUE;
  }
 //+------------------------------------------------------------------+
 //| Create a pending request for closing a position                  |
 //+------------------------------------------------------------------+
 int CTradingControl::CreatePReqClose(const ulong ticket,const double volume=WRONG_VALUE,const string comment=NULL,const ulong deviation=ULONG_MAX)
  {
   //--- If the global trading ban flag is set, exit and return WRONG_VALUE
      if(this.IsTradingDisable())
      {
         if(this.m_log_level>LOG_LEVEL_NO)
            ::Print(DFUN,CMessage::Text(MSG_LIB_TEXT_TRADING_DISABLE));
         return WRONG_VALUE;
      }
   //--- Set the error flag as "no errors"
      this.m_error_reason_flags=TRADE_REQUEST_ERR_FLAG_NO_ERROR;
      ENUM_ACTION_TYPE action=ACTION_TYPE_CLOSE;
   //--- Get an order object by ticket
      COrder *order=this.GetOrderObjByTicket(ticket);
      if(order==NULL)
      {
         this.m_error_reason_flags=TRADE_REQUEST_ERR_FLAG_INTERNAL_ERR;
         if(this.m_log_level>LOG_LEVEL_NO)
            ::Print(DFUN,CMessage::Text(MSG_LIB_SYS_ERROR_FAILED_GET_ORD_OBJ));
         return false;
      }
      ENUM_ORDER_TYPE order_type=(ENUM_ORDER_TYPE)order.TypeOrder();
   //--- Get a symbol object by a position ticket
      CSymbol *symbol_obj=this.GetSymbolObjByPosition(ticket,DFUN);
      //--- If failed to get the symbol object, display the message and return 'false'
      if(symbol_obj==NULL)
      {
         this.m_error_reason_flags=TRADE_REQUEST_ERR_FLAG_INTERNAL_ERR;
         if(this.m_log_level>LOG_LEVEL_NO)
            ::Print(DFUN,CMessage::Text(MSG_LIB_SYS_ERROR_FAILED_GET_SYM_OBJ));
         return false;
      }
   //--- get a trading object from a symbol object
      CTradeObj *trade_obj=symbol_obj.GetTradeObj();
      if(trade_obj==NULL)
      {
         this.m_error_reason_flags=TRADE_REQUEST_ERR_FLAG_INTERNAL_ERR;
         if(this.m_log_level>LOG_LEVEL_NO)
            ::Print(DFUN,CMessage::Text(MSG_LIB_SYS_ERROR_FAILED_GET_TRADE_OBJ));
         return false;
      }
   //--- Update symbol quotes
      if(!symbol_obj.RefreshRates())
      {
         trade_obj.SetResultRetcode(10021);
         trade_obj.SetResultComment(CMessage::Text(trade_obj.GetResultRetcode()));
         this.AddErrorCodeToList(10021);  // No quotes to handle the request
         if(this.m_log_level>LOG_LEVEL_NO)
            ::Print(DFUN,CMessage::Text(10021));
         return false;
      }
   //--- Look for the least of the possible IDs. If failed to find, return WRONG_VALUE
      int id=this.GetFreeID();
      if(id<1)
      {
         //--- No free IDs to create a pending request
         if(this.m_log_level>LOG_LEVEL_NO)
            ::Print(DFUN,CMessage::Text(MSG_LIB_TEXT_PEND_REQUEST_NO_FREE_IDS));
         return WRONG_VALUE;
      }

   //--- Write a volume, deviation and a comment to the request structure
      this.m_request.deviation=(deviation==ULONG_MAX ? trade_obj.GetDeviation() : deviation);
      this.m_request.comment=(comment==NULL ? trade_obj.GetComment() : comment);
      this.m_request.volume=(volume==WRONG_VALUE || volume>order.Volume() ? order.Volume() : symbol_obj.NormalizedLot(volume));
   //--- Write a magic number, a symbol name,
   //--- a trading operation type, as well as order type and ticket to the request structure
      this.m_request.magic=order.Magic();
      this.m_request.symbol=symbol_obj.Name();
      this.m_request.action=TRADE_ACTION_DEAL;
      this.m_request.type=order_type;
      this.m_request.position=ticket;
      this.m_request.position_by=0;
   //--- As a result of creating a pending trading request, return either its ID or -1 if unsuccessful
      if(this.CreatePendingRequest(PEND_REQ_STATUS_CLOSE,(uchar)id,1,ulong(END_TIME-(ulong)::TimeCurrent()),this.m_request,0,symbol_obj,order))
         return id;
      return WRONG_VALUE;
  }
 //+--------------------------------------------------------------------+
 //| Create a pending request for closing a position by an opposite one |
 //+--------------------------------------------------------------------+
 int CTradingControl::CreatePReqCloseBy(const ulong ticket,const ulong ticket_by)
  {
   //--- If the global trading ban flag is set, exit and return WRONG_VALUE
      if(this.IsTradingDisable())
      {
         if(this.m_log_level>LOG_LEVEL_NO)
            ::Print(DFUN,CMessage::Text(MSG_LIB_TEXT_TRADING_DISABLE));
         return WRONG_VALUE;
      }
   //--- Set the error flag as "no errors"
      this.m_error_reason_flags=TRADE_REQUEST_ERR_FLAG_NO_ERROR;
      ENUM_ACTION_TYPE action=ACTION_TYPE_CLOSE_BY;
   //--- Get an order object by ticket
      COrder *order=this.GetOrderObjByTicket(ticket);
      if(order==NULL)
      {
         this.m_error_reason_flags=TRADE_REQUEST_ERR_FLAG_INTERNAL_ERR;
         if(this.m_log_level>LOG_LEVEL_NO)
            ::Print(DFUN,CMessage::Text(MSG_LIB_SYS_ERROR_FAILED_GET_ORD_OBJ));
         return false;
      }
      ENUM_ORDER_TYPE order_type=(ENUM_ORDER_TYPE)order.TypeOrder();
   //--- Get a symbol object by a position ticket
      CSymbol *symbol_obj=this.GetSymbolObjByPosition(ticket,DFUN);
      if(symbol_obj==NULL)
      {
         this.m_error_reason_flags=TRADE_REQUEST_ERR_FLAG_INTERNAL_ERR;
         if(this.m_log_level>LOG_LEVEL_NO)
            ::Print(DFUN,CMessage::Text(MSG_LIB_SYS_ERROR_FAILED_GET_SYM_OBJ));
         return false;
      }
   //--- trading object of a closed position
      CTradeObj *trade_obj_pos=this.GetTradeObjByPosition(ticket,DFUN);
      if(trade_obj_pos==NULL)
      {
         this.m_error_reason_flags=TRADE_REQUEST_ERR_FLAG_INTERNAL_ERR;
         if(this.m_log_level>LOG_LEVEL_NO)
            ::Print(DFUN_ERR_LINE,CMessage::Text(MSG_LIB_SYS_ERROR_FAILED_GET_TRADE_OBJ));
         return false;
      }
      if(!this.m_account.IsHedge())
      {
         trade_obj_pos.SetResultRetcode(MSG_ACC_UNABLE_CLOSE_BY);
         trade_obj_pos.SetResultComment(CMessage::Text(trade_obj_pos.GetResultRetcode()));
         return false;
      }
   //--- check the presence of an opposite position
      if(!this.CheckPositionAvailablity(ticket_by,DFUN))
      {
         trade_obj_pos.SetResultRetcode(MSG_LIB_SYS_ERROR_POSITION_BY_ALREADY_CLOSED);
         trade_obj_pos.SetResultComment(CMessage::Text(trade_obj_pos.GetResultRetcode()));
         return false;
      }
   //--- trading object of an opposite position
      CTradeObj *trade_obj_pos_by=this.GetTradeObjByPosition(ticket_by,DFUN);
      if(trade_obj_pos_by==NULL)
      {
         trade_obj_pos.SetResultRetcode(MSG_LIB_SYS_ERROR_FAILED_GET_TRADE_OBJ);
         trade_obj_pos.SetResultComment(CMessage::Text(trade_obj_pos.GetResultRetcode()));
         this.m_error_reason_flags=TRADE_REQUEST_ERR_FLAG_INTERNAL_ERR;
         if(this.m_log_level>LOG_LEVEL_NO)
            ::Print(DFUN_ERR_LINE,CMessage::Text(MSG_LIB_SYS_ERROR_FAILED_GET_TRADE_OBJ));
         return false;
      }
   //--- If a symbol of a closed position is not equal to an opposite position's one, inform of that and exit
      if(symbol_obj.Name()!=trade_obj_pos_by.GetSymbol())
      {
         trade_obj_pos.SetResultRetcode(MSG_LIB_TEXT_CLOSE_BY_SYMBOLS_UNEQUAL);
         trade_obj_pos.SetResultComment(CMessage::Text(trade_obj_pos.GetResultRetcode()));
         this.m_error_reason_flags=TRADE_REQUEST_ERR_FLAG_INTERNAL_ERR;
         if(this.m_log_level>LOG_LEVEL_NO)
            ::Print(DFUN,CMessage::Text(MSG_LIB_TEXT_CLOSE_BY_SYMBOLS_UNEQUAL));
         return false;
      }
   //--- Update symbol quotes
      if(!symbol_obj.RefreshRates())
      {
         trade_obj_pos.SetResultRetcode(10021);
         trade_obj_pos.SetResultComment(CMessage::Text(trade_obj_pos.GetResultRetcode()));
         this.AddErrorCodeToList(10021);  // No quotes to handle the request
         if(this.m_log_level>LOG_LEVEL_NO)
            ::Print(DFUN,CMessage::Text(10021));
         return false;
      }
   //--- Look for the least of the possible IDs. If failed to find, return WRONG_VALUE
      int id=this.GetFreeID();
      if(id<1)
      {
         //--- No free IDs to create a pending request
         if(this.m_log_level>LOG_LEVEL_NO)
            ::Print(DFUN,CMessage::Text(MSG_LIB_TEXT_PEND_REQUEST_NO_FREE_IDS));
         return WRONG_VALUE;
      }

   //--- Write the trading operation type, symbol, tickets of two positions, type and volume of a closed position to the request structure
      this.m_request.action=TRADE_ACTION_CLOSE_BY;
      this.m_request.symbol=symbol_obj.Name();
      this.m_request.position=ticket;
      this.m_request.position_by=ticket_by;
      this.m_request.type=order_type;
      this.m_request.volume=order.Volume();
   //--- As a result of creating a pending trading request, return either its ID or -1 if unsuccessful
      if(this.CreatePendingRequest(PEND_REQ_STATUS_CLOSE,(uchar)id,1,ulong(END_TIME-(ulong)::TimeCurrent()),this.m_request,0,symbol_obj,order))
         return id;
      return WRONG_VALUE;
  }
 //+------------------------------------------------------------------+
 //| Create a pending request to remove a pending order               |
 //+------------------------------------------------------------------+
 int CTradingControl::CreatePreqDelete(const ulong ticket)
  {
   //--- If the global trading ban flag is set, exit and return WRONG_VALUE
      if(this.IsTradingDisable())
      {
         if(this.m_log_level>LOG_LEVEL_NO)
            ::Print(DFUN,CMessage::Text(MSG_LIB_TEXT_TRADING_DISABLE));
         return WRONG_VALUE;
      }
   //--- Set the error flag as "no errors"
      this.m_error_reason_flags=TRADE_REQUEST_ERR_FLAG_NO_ERROR;
      ENUM_ACTION_TYPE action=ACTION_TYPE_CLOSE;
   //--- Get an order object by ticket
      COrder *order=this.GetOrderObjByTicket(ticket);
      if(order==NULL)
      {
         this.m_error_reason_flags=TRADE_REQUEST_ERR_FLAG_INTERNAL_ERR;
         if(this.m_log_level>LOG_LEVEL_NO)
            ::Print(DFUN,CMessage::Text(MSG_LIB_SYS_ERROR_FAILED_GET_ORD_OBJ));
         return WRONG_VALUE;
      }
      ENUM_ORDER_TYPE order_type=(ENUM_ORDER_TYPE)order.TypeOrder();
   //--- Get a symbol object by an order ticket
      CSymbol *symbol_obj=this.GetSymbolObjByOrder(ticket,DFUN);
      if(symbol_obj==NULL)
      {
         this.m_error_reason_flags=TRADE_REQUEST_ERR_FLAG_INTERNAL_ERR;
         if(this.m_log_level>LOG_LEVEL_NO)
            ::Print(DFUN,CMessage::Text(MSG_LIB_SYS_ERROR_FAILED_GET_SYM_OBJ));
         return WRONG_VALUE;
      }
   //--- get a trading object from a symbol object
      CTradeObj *trade_obj=symbol_obj.GetTradeObj();
      if(trade_obj==NULL)
      {
         this.m_error_reason_flags=TRADE_REQUEST_ERR_FLAG_INTERNAL_ERR;
         if(this.m_log_level>LOG_LEVEL_NO)
            ::Print(DFUN,CMessage::Text(MSG_LIB_SYS_ERROR_FAILED_GET_TRADE_OBJ));
         return WRONG_VALUE;
      }
   //--- Update symbol quotes
      if(!symbol_obj.RefreshRates())
      {
         trade_obj.SetResultRetcode(10021);
         trade_obj.SetResultComment(CMessage::Text(trade_obj.GetResultRetcode()));
         this.AddErrorCodeToList(10021);  // No quotes to handle the request
         if(this.m_log_level>LOG_LEVEL_NO)
            ::Print(DFUN,CMessage::Text(10021));
         return WRONG_VALUE;
      }
      
   //--- Look for the least of the possible IDs. If failed to find, return WRONG_VALUE
      int id=this.GetFreeID();
      if(id<1)
      {
         //--- No free IDs to create a pending request
         if(this.m_log_level>LOG_LEVEL_NO)
            ::Print(DFUN,CMessage::Text(MSG_LIB_TEXT_PEND_REQUEST_NO_FREE_IDS));
         return WRONG_VALUE;
      }

      //--- Set the trading operation type, as well as deleted order's symbol and ticket in the request structure
      this.m_request.action=TRADE_ACTION_REMOVE;
      this.m_request.symbol=symbol_obj.Name();
      this.m_request.order=ticket;
      this.m_request.type=order_type;
      this.m_request.volume=order.Volume();
      this.m_request.price=order.PriceOpen();
   //--- As a result of creating a pending trading request, return either its ID or -1 if unsuccessful
      if(this.CreatePendingRequest(PEND_REQ_STATUS_REMOVE,(uchar)id,1,ulong(END_TIME-(ulong)::TimeCurrent()),this.m_request,0,symbol_obj,order))
         return id;
      return WRONG_VALUE;
  }
 //+------------------------------------------------------------------+
 //| Create a pending request to modify position's stop orders        |
 //+------------------------------------------------------------------+
 template<typename SL,typename TP> 
 int CTradingControl::CreatePReqModifyPosition(const ulong ticket,const SL sl=WRONG_VALUE,const TP tp=WRONG_VALUE)
  {
   //--- If the global trading ban flag is set, exit and return WRONG_VALUE
      if(this.IsTradingDisable())
      {
         if(this.m_log_level>LOG_LEVEL_NO)
            ::Print(DFUN,CMessage::Text(MSG_LIB_TEXT_TRADING_DISABLE));
         return WRONG_VALUE;
      }
   //--- Set the error flag as "no errors"
      this.m_error_reason_flags=TRADE_REQUEST_ERR_FLAG_NO_ERROR;
      ENUM_ACTION_TYPE action=ACTION_TYPE_MODIFY;
   //--- Get an order object by ticket
      COrder *order=this.GetOrderObjByTicket(ticket);
      if(order==NULL)
      {
         this.m_error_reason_flags=TRADE_REQUEST_ERR_FLAG_INTERNAL_ERR;
         if(this.m_log_level>LOG_LEVEL_NO)
            ::Print(DFUN,CMessage::Text(MSG_LIB_SYS_ERROR_FAILED_GET_ORD_OBJ));
         return WRONG_VALUE;
      }
      ENUM_ORDER_TYPE order_type=(ENUM_ORDER_TYPE)order.TypeOrder();
   //--- Get a symbol object by a position ticket
      CSymbol *symbol_obj=this.GetSymbolObjByPosition(ticket,DFUN);
      if(symbol_obj==NULL)
      {
         this.m_error_reason_flags=TRADE_REQUEST_ERR_FLAG_INTERNAL_ERR;
         if(this.m_log_level>LOG_LEVEL_NO)
            ::Print(DFUN,CMessage::Text(MSG_LIB_SYS_ERROR_FAILED_GET_SYM_OBJ));
         return WRONG_VALUE;
      }
   //--- Get a trading object from a symbol object
      CTradeObj *trade_obj=symbol_obj.GetTradeObj();
      if(trade_obj==NULL)
      {
         this.m_error_reason_flags=TRADE_REQUEST_ERR_FLAG_INTERNAL_ERR;
         if(this.m_log_level>LOG_LEVEL_NO)
            ::Print(DFUN,CMessage::Text(MSG_LIB_SYS_ERROR_FAILED_GET_TRADE_OBJ));
         return WRONG_VALUE;
      }
   //--- Set the prices
   //--- If failed to set - write the "internal error" flag, set the error code in the return structure,
   //--- display the message in the journal and return 'false'
      if(!this.SetPrices(order_type,0,(sl==WRONG_VALUE ? order.StopLoss() : sl),(tp==WRONG_VALUE ? order.TakeProfit() : tp),0,DFUN,symbol_obj))
      {
         this.m_error_reason_flags=TRADE_REQUEST_ERR_FLAG_INTERNAL_ERR;
         trade_obj.SetResultRetcode(10021);
         trade_obj.SetResultComment(CMessage::Text(trade_obj.GetResultRetcode()));
         if(this.m_log_level>LOG_LEVEL_NO)
            ::Print(DFUN,CMessage::Text(10021));   // No quotes to process the request
         return WRONG_VALUE;
      }
   //--- Look for the least of the possible IDs. If failed to find, return 'false'
      int id=this.GetFreeID();
      if(id<1)
         return WRONG_VALUE;
               
   //--- Write a type of a conducted operation, as well as a symbol and a ticket of a modified position to the request structure
      this.m_request.action=TRADE_ACTION_SLTP;
      this.m_request.symbol=symbol_obj.Name();
      this.m_request.position=ticket;
      this.m_request.type=order_type;
      this.m_request.volume=order.Volume();
   //--- As a result of creating a pending trading request, return either its ID or -1 if unsuccessful
      if(this.CreatePendingRequest(PEND_REQ_STATUS_SLTP,(uchar)id,1,ulong(END_TIME-(ulong)::TimeCurrent()),this.m_request,0,symbol_obj,order))
         return id;
      return WRONG_VALUE;
  }
 //+------------------------------------------------------------------+
 //| Create a pending request to modify a pending order               |
 //+------------------------------------------------------------------+
 template<typename PS,typename PL,typename SL,typename TP>
 int CTradingControl::CreatePReqModifyOrder(const ulong ticket,
                                           const PS price=WRONG_VALUE,
                                           const SL sl=WRONG_VALUE,
                                           const TP tp=WRONG_VALUE,
                                           const PL limit=WRONG_VALUE,
                                           datetime expiration=WRONG_VALUE,
                                           const ENUM_ORDER_TYPE_TIME type_time=WRONG_VALUE,
                                           const ENUM_ORDER_TYPE_FILLING type_filling=WRONG_VALUE)
  {
   //--- If the global trading ban flag is set, exit and return WRONG_VALUE
      if(this.IsTradingDisable())
      {
         if(this.m_log_level>LOG_LEVEL_NO)
            ::Print(DFUN,CMessage::Text(MSG_LIB_TEXT_TRADING_DISABLE));
         return WRONG_VALUE;
      }
   //--- Set the error flag as "no errors"
      this.m_error_reason_flags=TRADE_REQUEST_ERR_FLAG_NO_ERROR;
      ENUM_ACTION_TYPE action=ACTION_TYPE_MODIFY;
   //--- Get an order object by ticket
      COrder *order=this.GetOrderObjByTicket(ticket);
      if(order==NULL)
      {
         this.m_error_reason_flags=TRADE_REQUEST_ERR_FLAG_INTERNAL_ERR;
         if(this.m_log_level>LOG_LEVEL_NO)
            ::Print(DFUN,CMessage::Text(MSG_LIB_SYS_ERROR_FAILED_GET_ORD_OBJ));
         return false;
      }
      ENUM_ORDER_TYPE order_type=(ENUM_ORDER_TYPE)order.TypeOrder();
   //--- Get a symbol object by an order ticket
      CSymbol *symbol_obj=this.GetSymbolObjByOrder(ticket,DFUN);
      if(symbol_obj==NULL)
      {
         this.m_error_reason_flags=TRADE_REQUEST_ERR_FLAG_INTERNAL_ERR;
         if(this.m_log_level>LOG_LEVEL_NO)
            ::Print(DFUN,CMessage::Text(MSG_LIB_SYS_ERROR_FAILED_GET_SYM_OBJ));
         return false;
      }
   //--- get a trading object from a symbol object
      CTradeObj *trade_obj=symbol_obj.GetTradeObj();
      if(trade_obj==NULL)
      {
         this.m_error_reason_flags=TRADE_REQUEST_ERR_FLAG_INTERNAL_ERR;
         if(this.m_log_level>LOG_LEVEL_NO)
            ::Print(DFUN,CMessage::Text(MSG_LIB_SYS_ERROR_FAILED_GET_TRADE_OBJ));
         return false;
      }
   //--- Set the prices
   //--- If failed to set - write the "internal error" flag, set the error code in the return structure,
   //--- display the message in the journal and return 'false'
      if(!this.SetPrices(order_type,
                        (price>0 ? price : order.PriceOpen()),
                        (sl>0 ? sl : sl<0 ? order.StopLoss() : 0),
                        (tp>0 ? tp : tp<0 ? order.TakeProfit() : 0),
                        (limit>0 ? limit : order.PriceStopLimit()),
                        DFUN,symbol_obj))
      {
         this.m_error_reason_flags=TRADE_REQUEST_ERR_FLAG_INTERNAL_ERR;
         trade_obj.SetResultRetcode(10021);
         trade_obj.SetResultComment(CMessage::Text(trade_obj.GetResultRetcode()));
         if(this.m_log_level>LOG_LEVEL_NO)
            ::Print(DFUN,CMessage::Text(10021));   // No quotes to process the request
         return false;
      }
   //--- Look for the least of the possible IDs. If failed to find, return 'false'
      int id=this.GetFreeID();
      if(id<1)
         return WRONG_VALUE;
               
   //--- Write the magic number, volume, filling type, as well as expiration date and type to the request structure
      this.m_request.magic=order.GetMagicID((uint)order.Magic());
      this.m_request.volume=order.Volume();
      this.m_request.type_filling=(type_filling>WRONG_VALUE ? type_filling : order.TypeFilling());
      this.m_request.expiration=(expiration>WRONG_VALUE ? expiration : order.TimeExpiration());
      this.m_request.type_time=(type_time>WRONG_VALUE ? type_time : order.TypeTime());

      //--- Set the trading operation type, as well as modified order's symbol and ticket in the request structure
      this.m_request.action=TRADE_ACTION_MODIFY;
      this.m_request.symbol=symbol_obj.Name();
      this.m_request.order=ticket;
      this.m_request.type=order_type;
   //--- As a result of creating a pending trading request, return either its ID or -1 if unsuccessful
      if(this.CreatePendingRequest(PEND_REQ_STATUS_MODIFY,(uchar)id,1,ulong(END_TIME-(ulong)::TimeCurrent()),this.m_request,0,symbol_obj,order))
         return id;
      return WRONG_VALUE;
  }
 //+------------------------------------------------------------------+
 //| Set pending request activation criteria                          |
 //+------------------------------------------------------------------+
 bool CTradingControl::SetNewActivationProperties(const uchar id,
                                                const ENUM_PEND_REQ_ACTIVATION_SOURCE source,
                                                const int property,
                                                const double control_value,
                                                const ENUM_COMPARER_TYPE comparer_type,
                                                const double actual_value)
  {
   CPendRequest *req_obj=this.GetPendRequestByID(id);
   if(req_obj==NULL)
     {
      if(this.m_log_level>LOG_LEVEL_NO)
         ::Print(DFUN,CMessage::Text(MSG_LIB_TEXT_PEND_REQUEST_GETTING_FAILED));
      return false;
     }
   req_obj.SetNewActivationProperties(source,property,control_value,comparer_type,actual_value);
   return true;
  }
//+------------------------------------------------------------------+

 //+------------------------------------------------------------------+
 //| Close every open position on (symbol,dir)                        |
 //+------------------------------------------------------------------+
 void CTradingControl::ClosePositions(const string symbol, const ENUM_POSITION_TYPE dir)
  {
   for(int i = ::PositionsTotal() - 1; i >= 0; i--)
     {
      ulong ticket = ::PositionGetTicket(i);
      if(ticket == 0 || !::PositionSelectByTicket(ticket)) continue;
      if(::PositionGetString(POSITION_SYMBOL) != symbol) continue;
      if((ENUM_POSITION_TYPE)::PositionGetInteger(POSITION_TYPE) != dir) continue;
      this.ClosePosition(ticket);
     }
  }
 //+------------------------------------------------------------------+
 //| Modify SL (or TP) to new_price on every open position on (symbol,dir) |
 //+------------------------------------------------------------------+
 bool CTradingControl::ModifyPositions(const string symbol, const ENUM_POSITION_TYPE dir, const bool modify_sl, const double new_price)
  {
   bool res = true;   // false when any position was not modified
   for(int i = ::PositionsTotal() - 1; i >= 0; i--)
     {
      ulong ticket = ::PositionGetTicket(i);
      if(ticket == 0 || !::PositionSelectByTicket(ticket)) continue;
      if(::PositionGetString(POSITION_SYMBOL) != symbol) continue;
      if((ENUM_POSITION_TYPE)::PositionGetInteger(POSITION_TYPE) != dir) continue;
      double sl = modify_sl ? new_price : ::PositionGetDouble(POSITION_SL);
      double tp = modify_sl ? ::PositionGetDouble(POSITION_TP) : new_price;
      if(!this.ModifyPosition(ticket, sl, tp))
         res = false;
     }
   return res;
  }

 bool CTradingControl::SendNewOrder(const string symbol, const ENUM_POSITION_TYPE dir, const double lot, const int order_type_idx, const double price)
  {
   if(lot <= 0.0) return false;
   if((order_type_idx == 1 || order_type_idx == 2) && price <= 0.0)
    {
     ::Print("CTradingControl::SendNewOrder: ", symbol, " rejected - Limit/Stop price not set (still 0.0)");
     return false;
    }
   CSymbol *sym = (m_symbol_collection != NULL) ? m_symbol_collection.GetSymbolObjByName(symbol) : NULL;
   if(sym == NULL) return false;
   CTradeObj *trade_obj = sym.GetTradeObj();
   if(trade_obj == NULL) return false;
   const ulong magic = 20260910;
   bool ok = false;
   switch(order_type_idx)
    {
     case 0:   // Market
      ok = trade_obj.OpenPosition(dir, lot, 0, 0, magic);
      break;
     case 1:   // Limit
      ok = trade_obj.SetOrder(dir == POSITION_TYPE_BUY ? ORDER_TYPE_BUY_LIMIT : ORDER_TYPE_SELL_LIMIT, lot, price, 0, 0, 0, magic);
      break;
     case 2:   // Stop
      ok = trade_obj.SetOrder(dir == POSITION_TYPE_BUY ? ORDER_TYPE_BUY_STOP : ORDER_TYPE_SELL_STOP, lot, price, 0, 0, 0, magic);
      break;
     default:  // Stop Limit - not wired yet
      ::Print("CTradingControl::SendNewOrder: ", symbol, " rejected - Stop Limit not supported yet");
      return false;
    }
   if(!ok) ::Print("CTradingControl::SendNewOrder: ", symbol, " FAILED, order_type_idx=", order_type_idx,
                   " lot=", lot, " price=", price, " error=", ::GetLastError());
   return ok;
  }
 #endif // CTRADINGCONTROL_MQH_IMPLEMENTATION
#endif // __TRADINGCONTROL_MQH__