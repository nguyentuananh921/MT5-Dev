//+------------------------------------------------------------------+
//|                                                TradingEngine.mqh |
//|                         Copyright 2020, MetaQuotes Software Corp.|
//| Lib https://www.mql5.com/en/articles/14710                       |
//+------------------------------------------------------------------+
#ifndef __TRADING_ENGINE_MQH__
#define __TRADING_ENGINE_MQH__
  //+------------------------------------------------------------------+
  //| Include files                                                    |
  //+------------------------------------------------------------------+
  #include "Collections\AccountsCollection.mqh"
  #include "Collections\SymbolsCollection.mqh"
  #include "..\Services\InputData\TradingInpData.mqh"

  //+------------------------------------------------------------------+
  //| Event codes                                                      |
  //+------------------------------------------------------------------+
  enum ENUM_ENGINE_EVENT
    {
     ENGINE_EVENT_NONE    = 0x00,
     ENGINE_EVENT_ACCOUNT = 0x01,
     ENGINE_EVENT_ORDER   = 0x02,
     ENGINE_EVENT_SYMBOL  = 0x04,
    };

#ifndef CTRADING_ENGINE_MQH_DECLARATION
#define CTRADING_ENGINE_MQH_DECLARATION
  //+------------------------------------------------------------------+
  //| Lightweight coordinator for trading data collections            |
  //+------------------------------------------------------------------+
  class CTradingEngine
    {
     private:
        CAccountsCollection      m_accounts;
        CSymbolsCollection       m_symbols;    //For sybols information at tab Trade
        bool                     m_is_event;
        ENUM_ENGINE_EVENT        m_event_code;

     public:
        CTradingEngine(void);
       ~CTradingEngine(void);

        bool              OnInitEvent(void);
        void              OnTickEvent(void);
        void              OnDeinitEvent(void) {}

        bool              IsEvent(void)      const { return m_is_event;   }
        ENUM_ENGINE_EVENT GetEventCode(void) const { return m_event_code; }
       //For Account info at tab Trade
        CAccount *GetCurrentAccount(void);
        CAccountsCollection *GetAccounts(void);
       //For Symbols Information at tab Trade
        CSymbolsCollection *GetSymbolsCollection(void) { return &m_symbols; };
    };
#endif // CTRADING_ENGINE_MQH_DECLARATION

#ifndef CTRADING_ENGINE_MQH_IMPLEMENTATION
#define CTRADING_ENGINE_MQH_IMPLEMENTATION
  //+------------------------------------------------------------------+
  //| Constructor                                                      |
  //+------------------------------------------------------------------+
  CTradingEngine::CTradingEngine(void) : m_is_event(false),
                                         m_event_code(ENGINE_EVENT_NONE)
    {
    }
  //+------------------------------------------------------------------+
  //| Destructor                                                       |
  //+------------------------------------------------------------------+
  CTradingEngine::~CTradingEngine(void)
    {
    }
  //+------------------------------------------------------------------+
  //| Initialize collections and setup control thresholds             |
  //+------------------------------------------------------------------+
  bool CTradingEngine::OnInitEvent(void)
    {
      //For Account info at tab Trade, initialize account collection and set control thresholds to 0 to detect any change in account info, these values will be updated in GUI when there is an event
        m_accounts.RefreshAndEventsControl();
        int index = m_accounts.IndexCurrentAccount();
                  if(index == WRONG_VALUE) return false;    
        CAccount *acc = (CAccount*)m_accounts.GetList().At(index);
          if(acc == NULL) return false;
        //Seting control thresholds to 0 to detect any change in account info, these values will be updated in GUI when there is an event
          acc.SetControlBalanceInc(0);
          acc.SetControlBalanceDec(0);
          acc.SetControlProfitInc(0);
          acc.SetControlProfitDec(0);
          acc.SetControlEquityInc(0);
          acc.SetControlEquityDec(0);
      //For Symbols Information at tab Trade, initialize symbols collection
        m_symbols.RefreshAndEventsControl();
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

        m_accounts.RefreshAndEventsControl();
        if(m_accounts.IsEvent())
          {
            m_is_event   = true;
            m_event_code = ENGINE_EVENT_ACCOUNT;
          }
      //For Symbols Information at tab Trade, only update symbols collection when there is an event in symbols, no need to update every tick
      m_symbols.RefreshAndEventsControl();
      if(m_symbols.IsEvent())
        {
          m_is_event   = true;
          m_event_code = (ENUM_ENGINE_EVENT)(m_event_code | ENGINE_EVENT_SYMBOL);
        }
    }
  CAccount * CTradingEngine::GetCurrentAccount(void)
    {
        int index = m_accounts.IndexCurrentAccount();
        if(index == WRONG_VALUE) return NULL;
        return (CAccount*)m_accounts.GetList().At(index);
    }
#endif // CTRADING_ENGINE_MQH_IMPLEMENTATION
#endif // __TRADING_ENGINE_MQH__
