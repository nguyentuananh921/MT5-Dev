//+------------------------------------------------------------------+
//|                                   TradingEngine_Lifecycle.mqh    |
//+------------------------------------------------------------------+
#ifndef CTRADINGENGINE_LIFECYCLE_MQH
#define CTRADINGENGINE_LIFECYCLE_MQH
#include "TradingEngine.mqh"
 //+------------------------------------------------------------------+
 //| Initialize collections and setup control thresholds             |
 //+------------------------------------------------------------------+
 bool CTradingEngine::OnInitEvent(void)
  {
    //For m_accounts
    //Using in Account info at tab Trade, initialize account collection and set control thresholds to 0 to detect any change in account info, these values will be updated in GUI when there is an event
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
    //For Symbols Information at tab Trade, initialize symbols collection      
    // Symbols — init with current chart symbol
    m_market_collection.Refresh();
    m_history_collection.Refresh();
    if(!m_symbol_collection.CreateSymbolsList(true)) // true = MarketWatch
        return false;        
    m_trading_control.OnInit(GetCurrentAccount(), &m_symbol_collection, &m_market_collection, &m_history_collection, &m_trade_event_collection);
    return true;  
      
  }
  //+------------------------------------------------------------------+
  //| Refresh all collections and detect changes                       |
  //+------------------------------------------------------------------+
  void CTradingEngine::OnTickEvent(void)
    {      
      //For Account info at tab Trade, only update dynamic info when there is an event in account, no need to update every tick
        m_is_event   = false;
        m_event_code = ENGINE_EVENT_NONE;

        m_accounts_collection.RefreshAndEventsControl();
        if(m_accounts_collection.IsEvent())
          {
            m_is_event   = true;
            m_event_code = ENGINE_EVENT_ACCOUNT;
          }
      //For Symbols Information at tab Trade, only update symbols collection when there is an event in symbols, no need to update every tick
        m_symbol_collection.RefreshAndEventsControl();
        if(m_symbol_collection.IsEvent())
          {
            m_is_event   = true;
            m_event_code = (ENUM_ENGINE_EVENT)(m_event_code | ENGINE_EVENT_SYMBOL);
          }
        if(m_symbol_collection.ModeSymbolsList() == SYMBOLS_MODE_MARKET_WATCH)
            this.MarketWatchEventsControl();
      //For Order and deal
       this.TradeEventsControl();
       if(this.m_is_market_trade_event || this.m_is_history_trade_event)
        {
            m_is_event   = true;
            m_event_code = (ENUM_ENGINE_EVENT)(m_event_code | ENGINE_EVENT_ORDER);
        }
    }
#endif // CTRADINGENGINE_LIFECYCLE_MQH
