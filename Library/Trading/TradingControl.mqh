#ifndef __TRADINGCONTROL_MQH__
#define __TRADINGCONTROL_MQH__
//+------------------------------------------------------------------+
//|                                               TradingControl.mqh |
//|                        Copyright 2019, MetaQuotes Software Corp. |
//|                             https://mql5.com/en/users/artmedia70 |
//+------------------------------------------------------------------+
//--- Ported from V3 Trading\TradingControl.mqh (2026 1031): RAM only (the pending requests)
#property copyright "Copyright 2019, MetaQuotes Software Corp."
#property link      "https://mql5.com/en/users/artmedia70"
#property version   "1.00"
#property strict    // Necessary for mql4
//+------------------------------------------------------------------+
//| Include files                                                    |
//+------------------------------------------------------------------+
#include "Trading.mqh"
#include "..\Entities\Defines\EventDefines.mqh"
#include "..\Services\DELib\DatabaseService.mqh"
#include "..\Entities\Settings\Risk\RiskSetting.mqh"
#include "..\Entities\Defines\RiskManagementDefines.mqh"
#include "..\Collections\Settings\StrategyManager.mqh"
#include "..\Collections\IndicatorsCollection.mqh"
 #ifndef CTRADINGCONTROL_MQH_DECLARATION
 #define CTRADINGCONTROL_MQH_DECLARATION
 //--- A row of Setting_Risk as CDatabaseService::Read binds it (the order of the SELECT)
 struct SRiskSettingRow
  {
   string                name;
   double                value;                            // 0 for a text key
   string                text;                             // "" for a number key
  };
 //--- Rows of TradingOrderDetail as CDatabaseService::Read binds them (the order of the SELECT): local variables only
 struct STradingOrderDetailBidAsk
  {
   long                  ticket;
   double                bid;
   double                ask;
  };
 struct STradingOrderDetailChange
  {
   long                  ticket;      // 0: a change of the SL / TP, else a deal
   long                  time_msc;
   long                  event;
   double                sl;
   double                tp;
   long                  basket_id;
  };
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
     // New in V5: the lifecycle of a position, only what MT5 does not keep 
     // TradingOrderDetail table , file of the account; Python does not touch it)
      CDatabaseService    *m_CDatabaseService;   // The EA holds it
      bool                 IsDeal(const COrder *order) const;
      bool                 IsPositionEvent(const ENUM_TRADE_EVENT event) const;
      bool                 IsCloseEvent(const ENUM_TRADE_EVENT event) const;
      bool                 IsModifyEvent(const ENUM_TRADE_EVENT event) const;
      string               OrderDetailValues(const long position_id,const long time_msc,const long ticket,const int event,const double sl,const double tp,const double bid,const double ask,const string source,const long basket_id) const;
     //--- New in V5: the basket of a position (Concepts.md, Phạm vi: symbol + side) = the position_id of the first position of the basket;
     //--- on RAM for the positions of this run, kept in TradingOrderDetail.basket_id (the open ones read back at OnInitEvent by ReadDataFromDB). 0: not known
      long                 m_basket_position[];
      long                 m_basket_of_position[];
      long                 BasketId(const long position_id);
      bool                 UpdateDataToDB(const string values);
     //--- The Bid / Ask of the deals of a position on RAM (COrder), from the ticks of the terminal
      void                 DealsBidAsk(const long position_id);
     //--- An action on a position: its deals (Bid / Ask) and the changes of its SL / TP of this run written, with their source
      bool                 UpdateDataToDB(const long position_id);
     //--- New in V5: the source of an action (MT5 keeps only SL / TP / Expert / Client): which part of the EA asked it. Set on RAM by the
     //--- ticket of the position before the request (Trailing, Exit, Basket, Portfolio, Manual), written with the row of its event, then removed ("")
      ulong                m_source_ticket[];
      string               m_source_text[];
      void                 SetSource(const ulong ticket,const string source);
      string               Source(const ulong ticket) const;
      string               DealSource(const COrder *deal) const;
     //--- New in V5: Setting_Risk (file of the account) made with the defaults of Part 7 (a value set by the user is kept), read to RAM
      CRiskSetting         m_risk_setting;
      bool                 ReadRiskSettingFromDB(void);
     //--- New in V5: the three tiers of the risk, module TradingControl_Risk.mqh. Reference (concept only): D:\MT5-Dev\Experts\Solomon Anietie Sunday\
     //--- Risk Management\7. 24477 Consolidating the Risk Framework\Include\TradeRisk.mqh, BasketRisk.mqh, PortfolioRisk.mqh. The decisions are here,
     //--- the data in its owners (CSymbol::ValuePerLot / StopLevelMin, CAccount::DrawdownPercent, CMarketCollection::BasketState)
      bool                 m_risk_silent;        // a preview (ManualPlan at each tick) prints nothing
     //--- The trade tier (CTradeRisk): the lot of one Entry, its stop / target, the margin cap
      double               RiskDrawdownFactor(void);
      double               RiskAmount(void);
      double               VolumeForMoneyAndDistance(const CSymbol *symbol,const double money,const double price_distance);
      double               CalculateLotSize(const CSymbol *symbol,const double stop_distance,const double risk_amount);
      double               MarginUsageCap(void);
      double               CapLotToMargin(const CSymbol *symbol,const ENUM_ORDER_TYPE order_type,const double lot,const double price);
      bool                 BuildPlan(CSymbol *symbol,const long strategy_id,const ENUM_ORDER_TYPE type,const double stop_loss,STradePlan &plan);
      bool                 ValidatePlan(const CSymbol *symbol,STradePlan &plan);
      bool                 CheckTradeRisk(CSymbol *symbol,const long strategy_id,const datetime bar_time,const ENUM_ORDER_TYPE type,const double stop_loss,const double lots,STradePlan &plan);
     //--- The basket tier (CBasketRisk): the positions dealt on one symbol of one side (ORDER_TYPE_BUY / ORDER_TYPE_SELL), every magic; its excursion
     //--- statistics, RAM only (a restart resets them)
      string               m_basket_symbols[];
      ENUM_ORDER_TYPE      m_basket_types[];
      double               m_basket_max_adverse[];
      double               m_basket_max_favourable[];
      int                  m_basket_peak_count[];
      ulong                m_basket_cut_ms[];      // New in V5: when the basket was cut: its positions stay on RAM until OnTrade, not closed twice (RISK_CUT_WAIT_MS)
      int                  BasketIndexOf(const string symbol,const ENUM_ORDER_TYPE type);
      void                 BasketUpdateExcursion(const string symbol,const SBasketState &basket_state);
      void                 BasketResetTracking(const string symbol,const ENUM_ORDER_TYPE type);
      void                 BasketManage(const string symbol,const long magic_id,const ENUM_TIMEFRAMES timeframe);
      void                 BasketManageSide(const string symbol,const ENUM_ORDER_TYPE type,const long magic_id,const ENUM_TIMEFRAMES timeframe);
      bool                 BasketAcceptsNewTrade(const STradePlan &plan,const long magic_id);
      bool                 CheckBasketRisk(const STradePlan &plan,const long magic_id,const datetime bar_time);
     //--- The portfolio tier (CPortfolioRisk): the account, or the EA and the ExtraPortfolioMagics
      bool                 PortfolioIsTracked(const COrder *order);
      int                  CurrencyIndex(const SCurrencyExposure &list[],const string currency) const;
      void                 AccumulateCurrency(SCurrencyExposure &list[],const string currency,const double signed_lots,const bool count_position);
      void                 SymbolCurrencies(const string symbol,string &base,string &quote);
      bool                 PortfolioScan(SPortfolioState &state);
      int                  PortfolioCurrencyExposure(SCurrencyExposure &exposure[]);
      void                 PortfolioPrintSnapshot(void);
      bool                 PortfolioCanOpenPosition(const string symbol,const ENUM_ORDER_TYPE order_type,const double volume,const double price,string &reason);
      bool                 CheckPortfolioRisk(const STradePlan &plan,const datetime bar_time);
     //--- New in V5: Exit x Portfolio (Concepts.md): the floating loss of the portfolio past MaxPortfolioLossPercent closes its positions
      ulong                m_portfolio_cut_ms;     // when the portfolio was cut (RISK_CUT_WAIT_MS)
      void                 PortfolioManage(void);
     //--- The strategies (which one trades: Setting_Risk.EntryStrategies)
      CStrategyManager    *m_strategy_manager;   // The EA holds it
     //--- The bases that give the stop (Setting_Risk.StopLossTemplates): their templates, their indicators on the pair (The EA holds them)
      CIndicatorTemplateManager *m_indicator_template_manager;
      CIndicatorsCollection *m_indicators_collection;
      //--- The stop of the bases ON in a role (key: StopLossTemplates at the Entry, TrailingTemplates for an open position), their value at the shift
      //--- (1: the last closed bar for the Entry; 0: the bar now, for the trailing); each indicator refreshed before it is read. silent: prints nothing
      double               StopLossPrice(CSymbol *symbol_obj,const ENUM_ORDER_TYPE type,const bool silent=false,const string key="StopLossTemplates",const int shift=1);
      //--- A tick of the symbol (TICK_EVENT_NEW): the SL of each position of the EA on it moves to the value of the bases ON in Trailing when better
      void                 TrailPositions(const string symbol);
      //--- Close the positions: symbol "" all, strategy_id > 0 one strategy, type WRONG_VALUE both sides; every_magic: not only the EA's
      int                  ClosePositions(const string symbol,const long strategy_id,const ENUM_ORDER_TYPE type,const string source,const bool every_magic=false);
     //--- Close the tickets, each with its source (TradingOrderDetail.source); how many closed
      int                  CloseTickets(const ulong &tickets[],const string source);
      //--- New in V5: STRATEGY_EVENT_EXIT of a strategy in EntryStrategies: its positions of the side it closes, on the symbol
      void                 OnStrategyExit(const long lparam,const string symbol);
     //--- The keys of Setting_Risk changed on RAM (RISK_SETTING_EVENT_CHANGED), written at OnDeinitEvent
      string               m_risk_changed[];
      bool                 RiskKeyChanged(const string key) const;
      bool                 UpdateRiskSettingToDB(const string key);
     //--- STRATEGY_EVENT_ENTRY of a strategy in EntryStrategies: TradeEntry with its strategy_id
      void                 OnStrategyEntry(const long lparam,const string symbol);
     //--- An Entry through trade, basket, portfolio; strategy_id 0 = by hand, magic_chosen ULONG_MAX = the EA's
      void                 TradeEntry(const string symbol,const long strategy_id,const datetime bar_time,const ENUM_ORDER_TYPE type,const double lots=0.0,const ulong magic_chosen=ULONG_MAX);
     //--- SERIES_EVENTS_NEW_BAR of the chart TF: the basket of the symbol is managed; the portfolio logged (LogPortfolioSnapshot)
      void                 OnRiskNewBar(const string symbol,const ENUM_TIMEFRAMES timeframe);

    public:
      CRiskSetting        *RiskSetting(void)          { return &this.m_risk_setting; }
     //--- The MagicID of the EA (the magic of the trade objects)
      long                 MagicIdEA(const string symbol);
     //--- What a Manual Entry (strategy 0) would be now: the stop of the bases ON, the lot of the risk capped by the margin (MaxLot); nothing is told
      bool                 ManualPlan(const string symbol,const ENUM_ORDER_TYPE type,STradePlan &plan);
     //--- The keys of Setting_Risk changed on RAM go to the table (not at a chart change)
      void                 OnDeinitEvent(const int reason);
      void                 SetStrategyManager(CStrategyManager *manager) { this.m_strategy_manager=manager; }
      void                 SetIndicatorTemplateManager(CIndicatorTemplateManager *manager) { this.m_indicator_template_manager=manager; }
      void                 SetIndicatorsCollection(CIndicatorsCollection *collection)      { this.m_indicators_collection=collection; }     //--- Return itself
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
     //--- Working with Event: Trade listens; STRATEGY_EVENT_ENTRY (a new Entry of a strategy in EntryStrategies): traded through the three tiers of the risk;
     //--- STRATEGY_EVENT_EXIT (a new Exit of a strategy in EntryStrategies): its positions of the side it closes (OnStrategyExit);
     //--- TICK_EVENT_NEW of a symbol with positions: the baskets, the portfolio, the trailing; SERIES_EVENTS_NEW_BAR of the chart TF: the baskets;
     //--- RISK_SETTING_EVENT_CHANGED: the key is kept for OnDeinitEvent;
     //--- TRADE_SETUP_EVENT_CLOSE_ALL (the panel, emergency) closes every position of the account; lparam > 0: only the ones of that strategy_id;
     //--- sparam = a symbol: only the positions of the EA (MagicID) on it;
     //--- a trading event of a position (lparam = its id): the Bid / Ask of its deals, written when it is closed
       void                 OnChartEvent(const int id,const long &lparam,const double &dparam,const string &sparam);
     //--- New in V5: lifecycle as the other managers: makes TradingOrderDetail, puts the Bid / Ask of the deals on RAM (the ones missing: from the ticks, written)
       void                 SetDatabaseService(CDatabaseService *databaseService) { this.m_CDatabaseService=databaseService; }
       bool                 OnInitEvent(void);
     //--- What the table keeps of a position (load on demand): the changes of its SL / TP, oldest first (none written: the events of this run), and its basket
     //--- (0: not known). Returns how many changes
       int                  ReadDataFromDB(const long position_id,long &times[],long &events[],double &sls[],double &tps[],long &basket_id);
  };
 #endif // CTRADINGCONTROL_MQH_DECLARATION
 #ifndef CTRADINGCONTROL_MQH_IMPLEMENTATION
 #define CTRADINGCONTROL_MQH_IMPLEMENTATION
 //+------------------------------------------------------------------+
 //| Constructor                                                      |
 //+------------------------------------------------------------------+
 CTradingControl::CTradingControl() : m_CDatabaseService(NULL),m_risk_silent(false),m_portfolio_cut_ms(0),m_strategy_manager(NULL),m_indicator_template_manager(NULL),m_indicators_collection(NULL)
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
         uchar id=this.GetPendReqID(request.magic);
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
      ulong mn=(magic==ULONG_MAX ? trade_obj.GetMagic() : magic);   // V5: ulong keeps the StrategyID bits
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
      ulong mn=(magic==ULONG_MAX ? trade_obj.GetMagic() : magic);   // V5: ulong keeps the StrategyID bits
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

 void CTradingControl::OnChartEvent(const int id,const long &lparam,const double &dparam,const string &sparam)
  {
   if(id>CHARTEVENT_CUSTOM+TRADE_EVENT_NO_EVENT && id<CHARTEVENT_CUSTOM+TRADE_EVENTS_NEXT_CODE)
     {
      const ENUM_TRADE_EVENT event=(ENUM_TRADE_EVENT)(id-CHARTEVENT_CUSTOM);
      //--- The lifecycle of a position is written at each action on it (Save to DB Rule: MT5 does not keep the changes of the SL / TP):
      //--- a deal (open, close) or a change of the SL / TP (lparam = the ticket of the position); a row already there is kept
      if(this.IsPositionEvent(event))
         this.DealsBidAsk(lparam);
      if(this.IsPositionEvent(event) || this.IsModifyEvent(event))
         this.UpdateDataToDB(lparam);
      if(this.IsModifyEvent(event) || this.IsCloseEvent(event))
         this.SetSource((ulong)lparam,"");   // its row has the source now
      return;
     }
   if(id==CHARTEVENT_CUSTOM+STRATEGY_EVENT_ENTRY)
     {
      this.OnStrategyEntry(lparam,sparam);
      return;
     }
   if(id==CHARTEVENT_CUSTOM+RISK_SETTING_EVENT_CHANGED)
     {
      if(this.m_risk_setting.Index(sparam)>=0 && !this.RiskKeyChanged(sparam))
        {
         const int n=::ArraySize(this.m_risk_changed);
         ::ArrayResize(this.m_risk_changed,n+1);
         this.m_risk_changed[n]=sparam;   // working on RAM: written at OnDeinitEvent
        }
      return;
     }
   if(id==CHARTEVENT_CUSTOM+TRADE_SETUP_EVENT_SEND)
     {
      string parts[];   // sparam "symbol;magic" (panel) or "symbol" (the EA's magic)
      const int count=::StringSplit(sparam,';',parts);
      if(count<1)
         return;
      const ulong magic=(count>1 && parts[1]!="" ? (ulong)::StringToInteger(parts[1]) : ULONG_MAX);
      this.TradeEntry(parts[0],0,::TimeCurrent(),((ENUM_SIGNAL_DIRECTION)lparam==SIGNAL_DIRECTION_BUY ? ORDER_TYPE_BUY : ORDER_TYPE_SELL),dparam,magic);
      return;
     }
   if(id==CHARTEVENT_CUSTOM+SERIES_EVENTS_NEW_BAR)
     {
      this.OnRiskNewBar(sparam,(ENUM_TIMEFRAMES)(int)dparam);
      return;
     }
   //--- A tick of a symbol with positions: their money on RAM, the baskets, the portfolio, the trailing
   if(id==CHARTEVENT_CUSTOM+TICK_EVENT_NEW)
     {
      if(this.m_market.RefreshMoney(sparam)==0)
         return;
      this.BasketManage(sparam,0,::Period());
      this.PortfolioManage();
      if(this.m_risk_setting.Text("TrailingTemplates")!="")
         this.TrailPositions(sparam);
      return;
     }
   //--- New in V5: the Exit of a strategy that takes part in trading (EntryStrategies): its positions of the side it closes, on the symbol
   if(id==CHARTEVENT_CUSTOM+STRATEGY_EVENT_EXIT)
     {
      this.OnStrategyExit(lparam,sparam);
      return;
     }
   if(id!=CHARTEVENT_CUSTOM+TRADE_SETUP_EVENT_CLOSE_ALL)
      return;
   const int total=::PositionsTotal();
   const int closed=this.ClosePositions(sparam,lparam,(ENUM_ORDER_TYPE)WRONG_VALUE,"Manual");   // the Exit of Manual (StrategyID 0): the user closes
   ::Print(__FUNCTION__," > close all positions",(lparam>0 ? " of the strategy "+(string)lparam : ""),(sparam!="" ? " of the EA on "+sparam : ""),": ",
           closed," of ",total," positions of the account closed");
  }
 //+------------------------------------------------------------------+
 //| Close the positions: symbol "" every symbol (else the positions  |
 //| of the EA on it, its MagicID), strategy_id > 0 only that strategy,|
 //| type ORDER_TYPE_BUY / ORDER_TYPE_SELL, WRONG_VALUE both. Returns  |
 //| how many closed                                                  |
 //+------------------------------------------------------------------+
 int CTradingControl::ClosePositions(const string symbol,const long strategy_id,const ENUM_ORDER_TYPE type,const string source,const bool every_magic=false)
  {
   //--- The positions on RAM (CMarketCollection::HasPosition filters them: the symbol, the side, the MagicID of the EA, the StrategyID); their tickets
   //--- first, a close changes the list
   const long magic_id=(symbol!="" && !every_magic ? this.MagicIdEA(symbol) : 0);
   ulong tickets[];
   CArrayObj *list=this.m_market.GetList();
   for(int i=0;list!=NULL && i<list.Total();i++)
     {
      COrder *order=list.At(i);
      if(!this.m_market.HasPosition(order,symbol,(ENUM_POSITION_TYPE)type,magic_id,(strategy_id>0 ? strategy_id : 0)))
         continue;
      const int n=::ArraySize(tickets);
      ::ArrayResize(tickets,n+1);
      tickets[n]=order.Ticket();
     }
   return this.CloseTickets(tickets,source);
  }
 //+------------------------------------------------------------------+
 //| Close the tickets, each with its source; how many closed         |
 //+------------------------------------------------------------------+
 int CTradingControl::CloseTickets(const ulong &tickets[],const string source)
  {
   int closed=0;
   for(int i=0;i<::ArraySize(tickets);i++)
     {
      const ulong ticket=tickets[i];
      this.SetSource(ticket,source);
      if(this.ClosePosition(ticket))
         closed++;
      else
         this.SetSource(ticket,"");
     }
   return closed;
  }
 //+------------------------------------------------------------------+
 //| New in V5: STRATEGY_EVENT_EXIT (CStrategyBase::StoreRow: the side |
 //| is the one it closes). A new row of a strategy in EntryStrategies:|
 //| its positions of that side on the symbol are closed (the others,  |
 //| by hand or of another strategy, stay)                            |
 //+------------------------------------------------------------------+
 void CTradingControl::OnStrategyExit(const long lparam,const string symbol)
  {
   datetime bar_time;
   long strategy_id;
   ENUM_SIGNAL_DIRECTION side;
   bool is_new;
   this.EventUnpack(lparam,bar_time,strategy_id,side,is_new);
   if(!is_new || strategy_id<=0 || !this.m_risk_setting.IsIdOn("EntryStrategies",strategy_id) || (side!=SIGNAL_DIRECTION_BUY && side!=SIGNAL_DIRECTION_SELL))
      return;   // a row of the past (the markers only), a strategy not in trading
   const int closed=this.ClosePositions(symbol,strategy_id,(side==SIGNAL_DIRECTION_BUY ? ORDER_TYPE_BUY : ORDER_TYPE_SELL),"Exit S"+(string)strategy_id);
   if(closed>0)
      ::PrintFormat("%s > %s strategy %I64d Exit: %d %s position(s) closed",__FUNCTION__,symbol,strategy_id,closed,(side==SIGNAL_DIRECTION_BUY ? "BUY" : "SELL"));
  }
 //+------------------------------------------------------------------+
 //| The MagicID of the EA: the magic of the trade object of a symbol |
 //| (SetMagic gives the same one to every symbol)                    |
 //+------------------------------------------------------------------+
 long CTradingControl::MagicIdEA(const string symbol)
  {
   CSymbol *symbol_obj=(this.m_symbol_collection!=NULL ? this.m_symbol_collection.GetSymbolObjByName(symbol) : NULL);
   CTradeObj *trade_obj=(symbol_obj!=NULL ? symbol_obj.GetTradeObj() : NULL);
   return (trade_obj!=NULL ? (long)this.GetMagicID(trade_obj.GetMagic()) : 0);
  }
 //+------------------------------------------------------------------+
 //| A new bar of the chart TF: the basket of its symbol; the         |
 //| portfolio logged once per bar of the chart symbol                |
 //+------------------------------------------------------------------+
 void CTradingControl::OnRiskNewBar(const string symbol,const ENUM_TIMEFRAMES timeframe)
  {
   if(timeframe!=::Period())
      return;
   this.BasketManage(symbol,0,timeframe);   // magic 0: every position
   if(symbol==::Symbol() && this.m_risk_setting.PortfolioEnabled() && this.m_risk_setting.PortfolioLogSnapshot())
      this.PortfolioPrintSnapshot();
  }
 //+------------------------------------------------------------------+
 //| The stop of the bases chosen by the user in a role (key:         |
 //| StopLossTemplates, TrailingTemplates) on the symbol, at the bar  |
 //| of the shift of the chart TF: PSAR its price, ATR the price      |
 //| -/+ ATR x ATRMultiplier. Many ON: the nearest valid stop wins    |
 //| (the best protection, the best trailing). 0: none                |
 //+------------------------------------------------------------------+
 double CTradingControl::StopLossPrice(CSymbol *symbol_obj,const ENUM_ORDER_TYPE type,const bool silent=false,const string key="StopLossTemplates",const int shift=1)
  {
   if(this.m_risk_setting.Text(key)=="" || symbol_obj==NULL || this.m_indicator_template_manager==NULL || this.m_indicators_collection==NULL || !symbol_obj.RefreshRates())
      return 0.0;
   const int direction=(type==ORDER_TYPE_BUY ? 1 : -1);   // the sign of the price arithmetic of the side
   const double entry=(direction==1 ? symbol_obj.Ask() : symbol_obj.Bid());
   const double close_price=(direction==1 ? symbol_obj.Bid() : symbol_obj.Ask());   // the price the SL closes at: a stop past it is hit at once
   const datetime bar=::iTime(symbol_obj.Name(),::Period(),shift);
   ENUM_INDICATOR types[];
   string params[];
   bool buy[],sell[];
   const int total=this.m_indicator_template_manager.Read_RAM(types,params,buy,sell);
   double best=0.0;
   for(int i=0;i<total;i++)
     {
      CIndicatorSetting *setting=this.m_indicator_template_manager.Read_RAM(types[i],params[i]);
      if(setting==NULL || !this.m_risk_setting.IsIdOn(key,setting.ID()))
         continue;
      CIndicatorDE *indicator=this.m_indicators_collection.GetIndicator(types[i],params[i],symbol_obj.Name(),::Period());
      if(indicator!=NULL)
         indicator.Refresh();   // the value of an indicator is not an Event (Event.md): read when it is needed
      const double value=(indicator!=NULL ? indicator.Value(0,bar) : EMPTY_VALUE);
      if(value==EMPTY_VALUE || value<=0)
        {
         if(!silent)
            ::PrintFormat("%s > %s: no value of the stop template %I64d on the last closed bar",__FUNCTION__,symbol_obj.Name(),setting.ID());
         continue;
        }
      //--- A price of the symbol (digits): the SL of a position is compared with it (Trailing), a raw value never equal to it sends "no changes"
      double stop=0.0;
      if(types[i]==IND_ATR)
         stop=::NormalizeDouble(entry-direction*value*this.m_risk_setting.StopATRMultiplier(),symbol_obj.Digits());
      else if(types[i]==IND_SAR)
         stop=::NormalizeDouble(value,symbol_obj.Digits());
      if(stop<=0 || (direction==1 && stop>=close_price) || (direction==-1 && stop<=close_price))
        {
         if(!silent)
            ::PrintFormat("%s > %s: the stop %.*f of the template %I64d is not on the %s side: skipped",__FUNCTION__,symbol_obj.Name(),symbol_obj.Digits(),stop,setting.ID(),(direction==1 ? "BUY" : "SELL"));
         continue;
        }
      if(best==0.0 || (direction==1 && stop>best) || (direction==-1 && stop<best))
         best=stop;
     }
   return best;
  }
 //+------------------------------------------------------------------+
 //| A key of Setting_Risk changed on RAM: written to the table       |
 //+------------------------------------------------------------------+
 bool CTradingControl::UpdateRiskSettingToDB(const string key)
  {
   const int i=this.m_risk_setting.Index(key);
   if(this.m_CDatabaseService==NULL || i<0)
      return false;
   const string value=(this.m_risk_setting.KeyIsText(i) ? "'"+this.m_CDatabaseService.QuoteSQLText(this.m_risk_setting.KeyText(i))+"'" : ::DoubleToString(this.m_risk_setting.KeyValue(i),8));
   if(!this.m_CDatabaseService.Create("Account","UPDATE Setting_Risk SET value = "+value+" WHERE name = '"+key+"'"))
     {
      ::Print(__FUNCTION__," > Setting_Risk ",key," is not written");
      return false;
     }
   ::Print("Complete ",__FUNCTION__," > Setting_Risk ",key," = ",value);
   return true;
  }
 //+------------------------------------------------------------------+
 //| Is the key in the keys changed on RAM?                           |
 //+------------------------------------------------------------------+
 bool CTradingControl::RiskKeyChanged(const string key) const
  {
   for(int i=0;i<::ArraySize(this.m_risk_changed);i++)
      if(this.m_risk_changed[i]==key)
         return true;
   return false;
  }
 //+------------------------------------------------------------------+
 //| The EA closes: the keys changed on RAM go to Setting_Risk         |
 //+------------------------------------------------------------------+
 void CTradingControl::OnDeinitEvent(const int reason)
  {
   if(reason==REASON_CHARTCHANGE)
      return;
   for(int i=0;i<::ArraySize(this.m_risk_changed);i++)
      this.UpdateRiskSettingToDB(this.m_risk_changed[i]);
   ::ArrayResize(this.m_risk_changed,0);
  }
 //+------------------------------------------------------------------+
 //| A new Entry of a strategy ON in trading goes to TradeEntry       |
 //+------------------------------------------------------------------+
 void CTradingControl::OnStrategyEntry(const long lparam,const string symbol)
  {
   datetime bar_time;
   long strategy_id;
   ENUM_SIGNAL_DIRECTION side;
   bool is_new;
   this.EventUnpack(lparam,bar_time,strategy_id,side,is_new);
   if(!is_new || this.m_strategy_manager==NULL)
      return;   // a row of the past (the markers only), or no strategies
   //--- Change in V5: traded when the strategy takes part in trading (the Trading tab, Auto: Setting_Risk.EntryStrategies);
   //--- trading_enabled of Setting_Strategy only makes the templates of its slots (the Strategy tab)
   CStrategySetting *setting=this.m_strategy_manager.Read_RAM(strategy_id);
   if(setting==NULL || !this.m_risk_setting.IsIdOn("EntryStrategies",strategy_id))
      return;
   this.TradeEntry(symbol,strategy_id,bar_time,(side==SIGNAL_DIRECTION_BUY ? ORDER_TYPE_BUY : ORDER_TYPE_SELL));   // the side of the signal -> the type of the request
  }
 //+------------------------------------------------------------------+
 //| An Entry of a strategy or by hand (CButton, StrategyID 0): the    |
 //| three tiers of the risk (Part 7 OnTick, in widening order), then  |
 //| sent now with the magic of the EA + the StrategyID                |
 //+------------------------------------------------------------------+
 void CTradingControl::TradeEntry(const string symbol,const long strategy_id,const datetime bar_time,const ENUM_ORDER_TYPE type,const double lots=0.0,const ulong magic_chosen=ULONG_MAX)
  {
   CSymbol *symbol_obj=this.m_symbol_collection.GetSymbolObjByName(symbol);
   CTradeObj *trade_obj=(symbol_obj!=NULL ? symbol_obj.GetTradeObj() : NULL);
   if(trade_obj==NULL)
      return;
   ulong magic=trade_obj.GetMagic();
   this.SetStrategyID((uint)strategy_id,magic);
   if(strategy_id==0 && magic_chosen!=ULONG_MAX)
      magic=magic_chosen;   // the magic typed in the panel (0: none, as the terminal)
   STradePlan plan;
   //--- The tier that refuses tells RISK_EVENT_ENTRY_BLOCKED; the basket: the positions on the symbol of the side of the plan
   if(!this.CheckTradeRisk(symbol_obj,strategy_id,bar_time,type,this.StopLossPrice(symbol_obj,type,strategy_id==0),lots,plan))
      return;
   if(!this.CheckBasketRisk(plan,0,bar_time) || !this.CheckPortfolioRisk(plan,bar_time))
      return;
   const bool opened=this.OpenPosition((ENUM_POSITION_TYPE)plan.orderType,plan.lotSize,plan.symbol,magic,plan.stopLoss,plan.takeProfit,(strategy_id==0 ? "Manual" : NULL));   // the comment tells DealSource a Manual of any magic
   ::PrintFormat("%s > %s strategy %I64d %s: %s, lot %.2f, SL %.*f, TP %.*f, risk %.2f",__FUNCTION__,symbol,strategy_id,::EnumToString(plan.orderType),(opened ? "sent" : "not opened"),
                 plan.lotSize,symbol_obj.Digits(),plan.stopLoss,symbol_obj.Digits(),plan.takeProfit,plan.riskAmount);
  }
 //+------------------------------------------------------------------+
 //| What a Manual Entry (strategy 0) would be now: the stop of the    |
 //| bases ON, the lot of the risk capped by the margin (MaxLot).      |
 //| Nothing is told (no RISK_EVENT_ENTRY_BLOCKED): the View shows it; |
 //| false: the risk cannot make it, the lot chosen goes alone         |
 //+------------------------------------------------------------------+
 bool CTradingControl::ManualPlan(const string symbol,const ENUM_ORDER_TYPE type,STradePlan &plan)
  {
   CSymbol *symbol_obj=this.m_symbol_collection.GetSymbolObjByName(symbol);
   if(symbol_obj==NULL)
      return false;
   if(this.m_risk_setting.RiskMode()!=RISK_FIXED_LOT && this.m_risk_setting.Text("StopLossTemplates")=="")
      return false;   // a lot by the risk needs a stop: no base ON, nothing to calculate
   this.m_risk_silent=true;   // a preview: the reasons are printed when a trade of a strategy is asked
   const bool ok=(this.BuildPlan(symbol_obj,0,type,this.StopLossPrice(symbol_obj,type,true),plan) && this.ValidatePlan(symbol_obj,plan));
   this.m_risk_silent=false;
   return ok;
  }
 //+------------------------------------------------------------------+
 //| New in V5: Trailing = the role SL again while the position runs  |
 //| (Concepts.md): the value of the bases ON in Trailing at the bar  |
 //| now (StopLossPrice, shift 0); the SL of each position of the EA  |
 //| on the symbol (its MagicID, every strategy and by hand) moves to |
 //| it when better: BUY higher, SELL lower (no SL yet: set). The TP  |
 //| stays. CTrading::ModifyPosition checks the stop / freeze levels  |
 //+------------------------------------------------------------------+
 void CTradingControl::TrailPositions(const string symbol)
  {
   const long magic_id=this.MagicIdEA(symbol);
   CSymbol *symbol_obj=(this.m_symbol_collection!=NULL ? this.m_symbol_collection.GetSymbolObjByName(symbol) : NULL);
   if(magic_id==0 || symbol_obj==NULL)
      return;
   double stop[2]={WRONG_VALUE,WRONG_VALUE};   // BUY, SELL: read once, for the first position of the side
   //--- The positions of the EA on the symbol from RAM (CMarketCollection::HasPosition); the SL / TP read live: the list is read again by the timer,
   //--- a modify just sent is not in it yet (an old SL would send the same modify again)
   CArrayObj *list=this.m_market.GetList();
   for(int i=0;list!=NULL && i<list.Total();i++)
     {
      COrder *order=list.At(i);
      if(!this.m_market.HasPosition(order,symbol,WRONG_VALUE,magic_id))
         continue;
      const ulong ticket=order.Ticket();
      if(!::PositionSelectByTicket(ticket))
         continue;   // closed since the list was read
      const ENUM_ORDER_TYPE type=(ENUM_ORDER_TYPE)order.TypeOrder();   // a position: POSITION_TYPE_BUY / SELL = ORDER_TYPE_BUY / SELL
      const int side=(type==ORDER_TYPE_BUY ? 0 : 1);
      if(stop[side]==WRONG_VALUE)
         stop[side]=this.StopLossPrice(symbol_obj,type,true,"TrailingTemplates",0);
      const double sl=::PositionGetDouble(POSITION_SL);
      const double tp=::PositionGetDouble(POSITION_TP);
      if(stop[side]<=0 || (sl>0 && (type==ORDER_TYPE_BUY ? stop[side]<=sl : stop[side]>=sl)))
         continue;   // no value on the right side, or not better than the SL now
      this.SetSource(ticket,"Trailing");
      if(!this.ModifyPosition(ticket,stop[side],tp))
         this.SetSource(ticket,"");
      else
         ::PrintFormat("%s > %s #%I64u %s: SL %.*f -> %.*f",__FUNCTION__,symbol,ticket,::EnumToString(type),
                       symbol_obj.Digits(),sl,symbol_obj.Digits(),stop[side]);
     }
  }

 //+------------------------------------------------------------------+
 //| A deal of a position (the balance operations are not)            |
 //+------------------------------------------------------------------+
 bool CTradingControl::IsDeal(const COrder *order) const
  {
   return(order!=NULL && order.Status()==ORDER_STATUS_DEAL && order.TypeOrder()<=ORDER_TYPE_SELL);
  }
 //+------------------------------------------------------------------+
 //| A trading event whose lparam is the id of a position             |
 //| (CTradeEventPositionOpen / CTradeEventPositionClose::SendEvent)  |
 //+------------------------------------------------------------------+
 bool CTradingControl::IsPositionEvent(const ENUM_TRADE_EVENT event) const
  {
   return(event>=TRADE_EVENT_PENDING_ORDER_ACTIVATED && event<=TRADE_EVENT_TRIGGERED_STOP_LIMIT_ORDER);
  }
 //+------------------------------------------------------------------+
 //| The position closed (whole or a part): its lifecycle is written  |
 //+------------------------------------------------------------------+
 bool CTradingControl::IsCloseEvent(const ENUM_TRADE_EVENT event) const
  {
   return(event==TRADE_EVENT_POSITION_CLOSED || event==TRADE_EVENT_POSITION_CLOSED_BY_POS || event==TRADE_EVENT_POSITION_CLOSED_BY_SL ||
          event==TRADE_EVENT_POSITION_CLOSED_BY_TP || event==TRADE_EVENT_POSITION_CLOSED_PARTIAL || event==TRADE_EVENT_POSITION_CLOSED_PARTIAL_BY_POS ||
          event==TRADE_EVENT_POSITION_CLOSED_PARTIAL_BY_SL || event==TRADE_EVENT_POSITION_CLOSED_PARTIAL_BY_TP);
  }
 //+------------------------------------------------------------------+
 //| A change of the SL / TP of a position                            |
 //+------------------------------------------------------------------+
 bool CTradingControl::IsModifyEvent(const ENUM_TRADE_EVENT event) const
  {
   return(event==TRADE_EVENT_MODIFY_POSITION_SL_TP || event==TRADE_EVENT_MODIFY_POSITION_SL || event==TRADE_EVENT_MODIFY_POSITION_TP);
  }
 //+------------------------------------------------------------------+
 //| One row of the VALUES of an INSERT into TradingOrderDetail       |
 //+------------------------------------------------------------------+
 string CTradingControl::OrderDetailValues(const long position_id,const long time_msc,const long ticket,const int event,const double sl,const double tp,const double bid,const double ask,const string source,const long basket_id) const
  {
   return "("+(string)position_id+", "+(string)time_msc+", "+(string)ticket+", "+(string)event+", "+::DoubleToString(sl,8)+", "+::DoubleToString(tp,8)+", "+
          ::DoubleToString(bid,8)+", "+::DoubleToString(ask,8)+", '"+this.m_CDatabaseService.QuoteSQLText(source)+"', "+(string)basket_id+")";
  }
 //+------------------------------------------------------------------+
 //| New in V5: the basket of a position: the one on RAM; an open      |
 //| position new to RAM joins the basket of an open position of its   |
 //| symbol and side, or starts one (its own position_id). 0: closed   |
 //| and not known                                                     |
 //+------------------------------------------------------------------+
 long CTradingControl::BasketId(const long position_id)
  {
   for(int i=0;i<::ArraySize(this.m_basket_position);i++)
      if(this.m_basket_position[i]==position_id)
         return this.m_basket_of_position[i];
   CArrayObj *list=this.m_market.GetList();
   COrder *position=NULL;
   for(int i=0;list!=NULL && i<list.Total() && position==NULL;i++)
     {
      COrder *order=list.At(i);
      if(this.m_market.HasPosition(order) && order.PositionID()==position_id)
         position=order;
     }
   if(position==NULL)
      return 0;
   long basket_id=position_id;
   for(int i=0;i<::ArraySize(this.m_basket_position) && basket_id==position_id;i++)
      for(int j=0;j<list.Total();j++)
        {
         COrder *order=list.At(j);
         if(order.PositionID()==this.m_basket_position[i] && this.m_market.HasPosition(order,position.Symbol(),(ENUM_POSITION_TYPE)position.TypeOrder()))
           {
            basket_id=this.m_basket_of_position[i];
            break;
           }
        }
   const int n=::ArraySize(this.m_basket_position);
   ::ArrayResize(this.m_basket_position,n+1);
   ::ArrayResize(this.m_basket_of_position,n+1);
   this.m_basket_position[n]=position_id;
   this.m_basket_of_position[n]=basket_id;
   return basket_id;
  }
 //+------------------------------------------------------------------+
 //| New in V5: the source of the next action on a position ("": none)|
 //+------------------------------------------------------------------+
 void CTradingControl::SetSource(const ulong ticket,const string source)
  {
   const int total=::ArraySize(this.m_source_ticket);
   for(int i=0;i<total;i++)
      if(this.m_source_ticket[i]==ticket)
        {
         if(source!="")
            this.m_source_text[i]=source;
         else
           {
            this.m_source_ticket[i]=this.m_source_ticket[total-1];
            this.m_source_text[i]=this.m_source_text[total-1];
            ::ArrayResize(this.m_source_ticket,total-1);
            ::ArrayResize(this.m_source_text,total-1);
           }
         return;
        }
   if(source=="")
      return;
   ::ArrayResize(this.m_source_ticket,total+1);
   ::ArrayResize(this.m_source_text,total+1);
   this.m_source_ticket[total]=ticket;
   this.m_source_text[total]=source;
  }
 string CTradingControl::Source(const ulong ticket) const
  {
   for(int i=0;i<::ArraySize(this.m_source_ticket);i++)
      if(this.m_source_ticket[i]==ticket)
         return this.m_source_text[i];
   return "";
  }
 //+------------------------------------------------------------------+
 //| New in V5: the source of a deal: the reason MT5 keeps; an Entry by|
 //| its StrategyID (0: Manual); a close of the EA by what asked it    |
 //+------------------------------------------------------------------+
 string CTradingControl::DealSource(const COrder *deal) const
  {
   const long reason=deal.Reason();
   if(reason==DEAL_REASON_SL)
      return "SL";
   if(reason==DEAL_REASON_TP)
      return "TP";
   if(reason==DEAL_REASON_SO)
      return "StopOut";
   if(reason!=DEAL_REASON_EXPERT)
      return "Terminal";   // by hand in the terminal (desktop, mobile, web)
   if(deal.DealEntry()==DEAL_ENTRY_IN)
     {
      if(deal.Comment()=="Manual")
         return "Manual";   // the magic chosen in the panel can carry the StrategyID of a strategy
      const long strategy_id=(long)this.GetStrategyID((ulong)deal.Magic());
      return (strategy_id>0 ? "Entry S"+(string)strategy_id : "Manual");
     }
   const string source=this.Source((ulong)deal.PositionID());
   return (source!="" ? source : "EA");
  }
 //+------------------------------------------------------------------+
 //| Rows written (a row already there is kept)                       |
 //+------------------------------------------------------------------+
 bool CTradingControl::UpdateDataToDB(const string values)
  {
   if(values=="" || this.m_CDatabaseService==NULL)
      return true;
   if(!this.m_CDatabaseService.Create("Account","INSERT OR IGNORE INTO TradingOrderDetail (position_id, time_msc, ticket, event, sl, tp, bid, ask, source, basket_id) VALUES "+values))
     {
      ::Print(__FUNCTION__," > TradingOrderDetail not written");
      return false;
     }
   return true;
  }
 //+------------------------------------------------------------------+
 //| The Bid / Ask of the deals of a position on RAM: the last tick   |
 //| at or before each deal (COrder::BidAskFromTicks)                 |
 //+------------------------------------------------------------------+
 void CTradingControl::DealsBidAsk(const long position_id)
  {
   CArrayObj *list=(this.m_history_collection!=NULL ? this.m_history_collection.GetList() : NULL);
   if(list==NULL)
      return;
   for(int i=0;i<list.Total();i++)
     {
      COrder *deal=list.At(i);
      if(this.IsDeal(deal) && deal.PositionID()==position_id && deal.Bid()==0)
         deal.BidAskFromTicks();
     }
  }
 //+------------------------------------------------------------------+
 //| An action on a position: the Bid / Ask of its deals and the      |
 //| changes of its SL / TP of this run (CTradeEventsCollection)      |
 //+------------------------------------------------------------------+
 bool CTradingControl::UpdateDataToDB(const long position_id)
  {
   string values="";
   const long basket_id=this.BasketId(position_id);
   CArrayObj *list=(this.m_history_collection!=NULL ? this.m_history_collection.GetList() : NULL);
   for(int i=0;list!=NULL && i<list.Total();i++)
     {
      COrder *deal=list.At(i);
      if(!this.IsDeal(deal) || deal.PositionID()!=position_id)
         continue;
      values+=(values=="" ? "" : ", ")+this.OrderDetailValues(position_id,deal.GetProperty(ORDER_PROP_TIME_OPEN),deal.Ticket(),TRADE_EVENT_NO_EVENT,0,0,deal.Bid(),deal.Ask(),this.DealSource(deal),basket_id);
     }
   //--- A change of the SL / TP not asked by the EA (no source set): by hand in the terminal. The rows written before are kept with theirs
   const string source=this.Source((ulong)position_id);
   CArrayObj *events=(this.m_trade_event_collection!=NULL ? this.m_trade_event_collection.GetList() : NULL);
   for(int i=0;events!=NULL && i<events.Total();i++)
     {
      CTradeEvent *event=events.At(i);
      if(event==NULL || event.PositionID()!=position_id || !this.IsModifyEvent(event.TypeEvent()))
         continue;
      values+=(values=="" ? "" : ", ")+this.OrderDetailValues(position_id,event.TimeEvent(),0,event.TypeEvent(),event.PriceStopLoss(),event.PriceTakeProfit(),0,0,
                                                               (source!="" ? source : "Terminal"),basket_id);
     }
   return this.UpdateDataToDB(values);
  }
 //+------------------------------------------------------------------+
 //| Setting_Risk: a row for each input of the author (ord, grp, type,|
 //| name, value, comment: CRiskSetting). The defaults are written    |
 //| once (a value already there is kept; ord, grp, type, comment     |
 //| follow CRiskSetting), a row no longer in CRiskSetting is deleted,|
 //| then every row is read to m_risk_setting                         |
 //+------------------------------------------------------------------+
 bool CTradingControl::ReadRiskSettingFromDB(void)
  {
   string values="",names="";
   for(int i=0;i<this.m_risk_setting.KeysTotal();i++)
     {
      values+=(i>0 ? ", " : "")+"("+(string)i+", '"+this.m_CDatabaseService.QuoteSQLText(this.m_risk_setting.KeyGroup(i))+"', '"+this.m_risk_setting.KeyType(i)+"', '"+this.m_risk_setting.KeyName(i)+"', "+
              (this.m_risk_setting.KeyIsText(i) ? "'"+this.m_CDatabaseService.QuoteSQLText(this.m_risk_setting.KeyText(i))+"'" : ::DoubleToString(this.m_risk_setting.KeyValue(i),8))+", '"+
              this.m_CDatabaseService.QuoteSQLText(this.m_risk_setting.KeyComment(i))+"')";
      names+=(i>0 ? ", " : "")+"'"+this.m_risk_setting.KeyName(i)+"'";
     }
   //--- ord is the key: the rows are stored in the order of the inputs. The ords in the table move aside (negative) first, so a key put
   //--- between the inputs takes its ord without a conflict; a value already there is kept (the row is matched by its name)
   if(!this.m_CDatabaseService.Create("Account","CREATE TABLE IF NOT EXISTS Setting_Risk (ord INTEGER PRIMARY KEY, grp TEXT NOT NULL, type TEXT NOT NULL, name TEXT NOT NULL UNIQUE, value NOT NULL, comment TEXT NOT NULL DEFAULT '')") ||
      !this.m_CDatabaseService.Create("Account","UPDATE Setting_Risk SET ord = -ord - 1") ||
      !this.m_CDatabaseService.Create("Account","INSERT INTO Setting_Risk (ord, grp, type, name, value, comment) VALUES "+values+
                                                " ON CONFLICT(name) DO UPDATE SET ord = excluded.ord, grp = excluded.grp, type = excluded.type, comment = excluded.comment") ||
      !this.m_CDatabaseService.Create("Account","DELETE FROM Setting_Risk WHERE name NOT IN ("+names+")"))
     {
      ::Print(__FUNCTION__," > DatabaseService can't create table Setting_Risk");
      return false;
     }
   SRiskSettingRow rows[];
   //--- value has no type: a text key is split off so both columns bind
   if(!this.m_CDatabaseService.Read("Account","SELECT name, CASE WHEN typeof(value)='text' THEN 0 ELSE value END, CASE WHEN typeof(value)='text' THEN value ELSE '' END FROM Setting_Risk ORDER BY ord",rows))
      return false;
   for(int i=0;i<::ArraySize(rows);i++)
     {
      if(!this.m_risk_setting.SetValue(rows[i].name,rows[i].value,false))
         this.m_risk_setting.SetText(rows[i].name,rows[i].text,false);
     }
   ::Print("Complete ",__FUNCTION__," > ",::ArraySize(rows)," rows of Setting_Risk read");
   return true;
  }
 //+------------------------------------------------------------------+
 //| Makes TradingOrderDetail; the Bid / Ask of every deal of the     |
 //| history on RAM: from the table, the ones missing from the ticks  |
 //| (the first start: all; then the positions closed while the EA    |
 //| was off), written. A chart change keeps them (m_first_start)    |
 //+------------------------------------------------------------------+
 bool CTradingControl::OnInitEvent(void)
  {
   if(!this.m_first_start)
      return true;
   if(this.m_CDatabaseService==NULL || this.m_history_collection==NULL)
      return false;
   if(!this.ReadRiskSettingFromDB())
      return false;
   if(!this.m_CDatabaseService.Create("Account","CREATE TABLE IF NOT EXISTS TradingOrderDetail (position_id INTEGER NOT NULL, time_msc INTEGER NOT NULL, ticket INTEGER NOT NULL, "
                                      "event INTEGER NOT NULL, sl REAL, tp REAL, bid REAL, ask REAL, source TEXT NOT NULL DEFAULT '', PRIMARY KEY (position_id, time_msc, ticket, event))") ||
      !this.m_CDatabaseService.AddColumn("Account","TradingOrderDetail","source","TEXT NOT NULL DEFAULT ''") ||
      !this.m_CDatabaseService.AddColumn("Account","TradingOrderDetail","basket_id","INTEGER NOT NULL DEFAULT 0"))
     {
      ::Print(__FUNCTION__," > DatabaseService can't create table TradingOrderDetail");
      return false;
     }
   //--- The baskets of the open positions back to RAM from the table, then the open positions without one (oldest first) join or start one
   CArrayObj *open=this.m_market.GetList();
   long change_times[],change_events[];
   double change_sls[],change_tps[];
   for(int i=0;open!=NULL && i<open.Total();i++)
     {
      COrder *order=open.At(i);
      long basket_id=0;
      if(!this.m_market.HasPosition(order))
         continue;
      this.ReadDataFromDB(order.PositionID(),change_times,change_events,change_sls,change_tps,basket_id);
      if(basket_id==0)
         continue;
      const int n=::ArraySize(this.m_basket_position);
      ::ArrayResize(this.m_basket_position,n+1);
      ::ArrayResize(this.m_basket_of_position,n+1);
      this.m_basket_position[n]=order.PositionID();
      this.m_basket_of_position[n]=basket_id;
     }
   for(int i=0;open!=NULL && i<open.Total();i++)   // the list is sorted by the open time; the rows written without it get it
     {
      COrder *order=open.At(i);
      if(this.m_market.HasPosition(order))
         this.m_CDatabaseService.Create("Account","UPDATE TradingOrderDetail SET basket_id = "+(string)this.BasketId(order.PositionID())+" WHERE position_id = "+(string)order.PositionID()+" AND basket_id = 0");
     }
   const ulong start=::GetTickCount64();
   STradingOrderDetailBidAsk rows[];
   if(!this.m_CDatabaseService.Read("Account","SELECT ticket, COALESCE(bid, 0), COALESCE(ask, 0) FROM TradingOrderDetail WHERE ticket <> 0 ORDER BY ticket",rows))
      return false;
   const int total=::ArraySize(rows);
   long tickets[];
   ::ArrayResize(tickets,total);
   for(int i=0;i<total;i++)
      tickets[i]=rows[i].ticket;
   CArrayObj *list=this.m_history_collection.GetList();
   string values="";
   int read=0,filled=0,batch=0;
   for(int i=0;list!=NULL && i<list.Total();i++)
     {
      COrder *deal=list.At(i);
      if(!this.IsDeal(deal))
         continue;
      const int k=(total>0 ? ::ArrayBsearch(tickets,deal.Ticket()) : -1);
      if(k>=0 && tickets[k]==deal.Ticket())
        {
         deal.SetBidAsk(rows[k].bid,rows[k].ask);
         read++;
         continue;
        }
      deal.BidAskFromTicks();   // no tick any more: 0, written too so that it is not asked again
      values+=(values=="" ? "" : ", ")+this.OrderDetailValues(deal.PositionID(),deal.GetProperty(ORDER_PROP_TIME_OPEN),deal.Ticket(),TRADE_EVENT_NO_EVENT,0,0,deal.Bid(),deal.Ask(),this.DealSource(deal),
                                                            this.BasketId(deal.PositionID()));
      filled++;
      if(++batch>=500)
        {
         this.UpdateDataToDB(values);
         values="";
         batch=0;
        }
     }
   this.UpdateDataToDB(values);
   ::Print("Complete ",__FUNCTION__," > Bid / Ask of ",read," deals read from TradingOrderDetail, ",filled," deals from the ticks written, ",::GetTickCount64()-start," ms");
   this.m_first_start=false;
   return true;
  }
 //+------------------------------------------------------------------+
 //| The changes of the SL / TP of a position, oldest first           |
 //+------------------------------------------------------------------+
 int CTradingControl::ReadDataFromDB(const long position_id,long &times[],long &events[],double &sls[],double &tps[],long &basket_id)
  {
   ::ArrayResize(times,0);
   ::ArrayResize(events,0);
   ::ArrayResize(sls,0);
   ::ArrayResize(tps,0);
   basket_id=0;
   int n=0;
   STradingOrderDetailChange rows[];
   //--- Every row of the position: its deals (ticket) and the changes of its SL / TP (ticket 0); the basket is on each of them
   if(this.m_CDatabaseService!=NULL &&
      this.m_CDatabaseService.Read("Account","SELECT ticket, time_msc, event, COALESCE(sl, 0), COALESCE(tp, 0), basket_id FROM TradingOrderDetail WHERE position_id = "+(string)position_id+
                                   " ORDER BY time_msc",rows))
     {
      for(int i=0;i<::ArraySize(rows);i++)
        {
         if(rows[i].basket_id>basket_id)
            basket_id=rows[i].basket_id;
         if(rows[i].ticket!=0)
            continue;
         ::ArrayResize(times,n+1);
         ::ArrayResize(events,n+1);
         ::ArrayResize(sls,n+1);
         ::ArrayResize(tps,n+1);
         times[n]=rows[i].time_msc;
         events[n]=rows[i].event;
         sls[n]=rows[i].sl;
         tps[n]=rows[i].tp;
         n++;
        }
      if(n>0)
         return n;
     }
   //--- Not written (the write failed): the events of this run
   CArrayObj *list=(this.m_trade_event_collection!=NULL ? this.m_trade_event_collection.GetList() : NULL);
   for(int i=0;list!=NULL && i<list.Total();i++)
     {
      CTradeEvent *event=list.At(i);
      if(event==NULL || event.PositionID()!=position_id || !this.IsModifyEvent(event.TypeEvent()))
         continue;
      ::ArrayResize(times,n+1);
      ::ArrayResize(events,n+1);
      ::ArrayResize(sls,n+1);
      ::ArrayResize(tps,n+1);
      times[n]=event.TimeEvent();
      events[n]=event.TypeEvent();
      sls[n]=event.PriceStopLoss();
      tps[n]=event.PriceTakeProfit();
      n++;
     }
   return n;
  }
 #include "TradingControl_Risk.mqh"   // New in V5: the three tiers of the risk (a module of this class)
 #endif // CTRADINGCONTROL_MQH_IMPLEMENTATION
#endif // __TRADINGCONTROL_MQH__
