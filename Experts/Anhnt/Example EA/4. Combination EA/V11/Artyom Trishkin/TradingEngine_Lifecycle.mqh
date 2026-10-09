//+------------------------------------------------------------------+
//|                                   TradingEngine_Lifecycle.mqh    |
//+------------------------------------------------------------------+
#ifndef CTRADINGENGINE_LIFECYCLE_MQH
#define CTRADINGENGINE_LIFECYCLE_MQH
#include "TradingEngine.mqh"
 //+------------------------------------------------------------------+
 //| Constructor/Destructor                                           |
 //+------------------------------------------------------------------+
 CTradingEngine::CTradingEngine(void) : m_is_first_start (true),
                                        m_is_tester(::MQLInfoInteger(MQL_TESTER)),
                                        m_trading_setup_manager(NULL),
                                        m_indicators_collection(NULL),
                                        m_BarTimeSeriesCollection(NULL)
  {

  }
 CTradingEngine::~CTradingEngine(void)
  {

  }
 //+------------------------------------------------------------------+
 //| Initialize collections and setup control thresholds              |
 //+------------------------------------------------------------------+
 bool CTradingEngine::OnInitEvent(void)
  {    
    m_accounts_collection.RefreshAndEventsControl();
    int index = m_accounts_collection.IndexCurrentAccount();
                if(index == WRONG_VALUE) return false;    
    CAccount *acc = (CAccount*)m_accounts_collection.GetList().At(index);
        if(acc == NULL) return false;
    //Seting control thresholds to 0 to detect any change in account info, these values will be updated in GUI when there is an event
        acc.SetControlBalanceInc(0);
        acc.SetControlBalanceDec(0);
        acc.SetControlProfitInc(0);
        acc.SetControlProfitDec(0);
        acc.SetControlEquityInc(0);
        acc.SetControlEquityDec(0);
    //For trading    
     m_market_collection.Refresh();
     m_history_collection.Refresh();
     if(!m_symbol_collection.CreateSymbolsList(true)) // true = MarketWatch
        return false;        
     m_trading_control.OnInit(m_accounts_collection.GetCurrentAccount(), &m_symbol_collection, &m_market_collection, &m_history_collection, &m_trade_event_collection);
    return true;  
      
  }
 //+------------------------------------------------------------------+
 //| Refresh all collections and detect changes                       |
 //+------------------------------------------------------------------+
 void CTradingEngine::OnTickEvent(void)
  {
   //For Account info update dynamic info when there is an event in account, no need to update every tick
    m_accounts_collection.RefreshAndEventsControl();
   //For Symbols Information update symbols collection when there is an event in symbols, no need to update every tick
    m_symbol_collection.RefreshAndEventsControl();   
    if(!m_is_tester && m_symbol_collection.ModeSymbolsList() == SYMBOLS_MODE_MARKET_WATCH)
     m_symbol_collection.MarketWatchEventsControl();
   //For Order and deal
    this.TradeEventsControl();   
    this.ApplyStopLostAndTrailing(this.m_is_market_trade_event);
  }
#endif // CTRADINGENGINE_LIFECYCLE_MQH
