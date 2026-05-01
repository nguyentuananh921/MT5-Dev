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
        CAccount *GetCurrentAccount(void);
        CAccountsCollection *GetAccounts(void);
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
     return true;
    }
  //+------------------------------------------------------------------+
  //| Refresh all collections and detect changes                       |
  //+------------------------------------------------------------------+
  void CTradingEngine::OnTickEvent(void)
    {
     m_is_event   = false;
     m_event_code = ENGINE_EVENT_NONE;

     m_accounts.RefreshAndEventsControl();
     if(m_accounts.IsEvent())
       {
        m_is_event   = true;
        m_event_code = ENGINE_EVENT_ACCOUNT;
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
