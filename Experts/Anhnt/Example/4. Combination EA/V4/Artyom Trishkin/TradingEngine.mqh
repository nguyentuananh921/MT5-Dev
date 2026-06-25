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
  #include <Vendors\Anhnt\Library\4. Combination Lib\Collections\AccountsCollection.mqh>
  #include <Vendors\Anhnt\Library\4. Combination Lib\Collections\SymbolsCollection.mqh>
  #include <Vendors\Anhnt\Library\4. Combination Lib\Services\InputData\TradingInpData.mqh>  
  #include <Vendors\Anhnt\Library\4. Combination Lib\Collections\MarketCollection.mqh>
  #include <Vendors\Anhnt\Library\4. Combination Lib\Collections\HistoryCollection.mqh>
  #include <Vendors\Anhnt\Library\4. Combination Lib\Collections\TradeEventsCollection.mqh>
  #include <Vendors\Anhnt\Library\4. Combination Lib\Trading\TradingControl.mqh>
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
        CAccountsCollection      m_accounts;       // Account collection
        CSymbolsCollection       m_symbols;        //For sybols information at tab Trade
        CMarketCollection        m_market;         // Collection of market orders and deals
        CHistoryCollection       m_history;        // Collection of historical orders and deals
        CTradeEventsCollection        m_events;         // Collection of events
        CTradingControl          m_trading_control;// Trading management object
        
        bool                     m_is_event;
        ENUM_ENGINE_EVENT        m_event_code;
        // int                      m_symbols_rebuild_count;

     public:
        CTradingEngine(void);
       ~CTradingEngine(void);

        bool              OnInitEvent(void);
        void              OnTickEvent(void);
        void              OnDeinitEvent(void) {}

        bool              IsEvent(void)      const { return m_is_event;   }
        ENUM_ENGINE_EVENT GetEventCode(void) const { return m_event_code; }
       //For Pointer
        CAccount            *GetCurrentAccount(void);
        CAccountsCollection *GetAccounts(void) { return &m_accounts;}
        CMarketCollection   *GetMarketCollection(void) { return &m_market; }       
        CSymbolsCollection  *GetSymbolsCollection(void) { return &m_symbols; }
        CTradingControl     *GetTradingControl(void) { return &m_trading_control; }
       //--- Return the list of market (1) positions, (2) pending orders and (3)
       // market orders
        CArrayObj           *GetListMarketPosition(void);
        CArrayObj           *GetListMarketPendings(void);
        CArrayObj           *GetListMarketOrders(void);
       //For Profit Calculation 
        // Floating profit (current price)
         double             SumFloatingProfit(CArrayObj *list);
         double             CalcProfit(void);
         double             CalcProfit(const string symbol);
         double             CalcProfit(ENUM_POSITION_TYPE dir);
         double             CalcProfit(const string symbol, ENUM_POSITION_TYPE dir);
        // Hypothetical profit (at target price)
         double             CalcProfitAt(const string symbol, double price);
         double             CalcProfitAt(const string symbol, ENUM_POSITION_TYPE dir, double target_price);
       //Note
        //bool RebuildSymbols(ENUM_SYMBOLS_MODE mode);
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
      //For m_accounts
      //Using in Account info at tab Trade, initialize account collection and set control thresholds to 0 to detect any change in account info, these values will be updated in GUI when there is an event
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
      //For trading
      //For Symbols Information at tab Trade, initialize symbols collection      
        // Symbols — init with current chart symbol
        m_market.Refresh();
        m_history.Refresh();
        if(!m_symbols.CreateSymbolsList(true)) // true = MarketWatch
            return false;        
        m_trading_control.OnInit(GetCurrentAccount(), &m_symbols, &m_market, &m_history, &m_events);
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
      //For Order and deal
       m_market.Refresh();
       if(m_market.IsTradeEvent())
        {
          m_is_event   = true;
          m_event_code = (ENUM_ENGINE_EVENT)(m_event_code | ENGINE_EVENT_ORDER);
        }
    }
//For Pointer
  CAccount * CTradingEngine::GetCurrentAccount(void)
    {
        int index = m_accounts.IndexCurrentAccount();
        if(index == WRONG_VALUE) return NULL;
        return (CAccount*)m_accounts.GetList().At(index);
    }
 //For market Order
  //+------------------------------------------------------------------+
  //| Return the list of market positions                              |
  //+------------------------------------------------------------------+
  CArrayObj *CTradingEngine::GetListMarketPosition(void) 
   {
    CArrayObj *list = this.m_market.GetList();
    list = CTradingSelect::ByOrderProperty(list, ORDER_PROP_STATUS,
                                    ORDER_STATUS_MARKET_POSITION, EQUAL);
    return list;
   }
  //+------------------------------------------------------------------+
  //| Return the list of market pending orders                         |
  //+------------------------------------------------------------------+
  CArrayObj *CTradingEngine::GetListMarketPendings(void) 
   {
    CArrayObj *list = this.m_market.GetList();
    list = CTradingSelect::ByOrderProperty(list, ORDER_PROP_STATUS,
                                    ORDER_STATUS_MARKET_PENDING, EQUAL);
    return list;
   }
  //+------------------------------------------------------------------+
  //| Return the list of market orders                                 |
  //+------------------------------------------------------------------+
  CArrayObj *CTradingEngine::GetListMarketOrders(void) 
   {
    CArrayObj *list = this.m_market.GetList();
    list = CTradingSelect::ByOrderProperty(list, ORDER_PROP_STATUS,
                                    ORDER_STATUS_MARKET_ORDER, EQUAL);
    return list;
   }
   //For profit calculation
   double CTradingEngine::SumFloatingProfit(CArrayObj *list)
    {
        if(list == NULL) return 0;
        double total = 0;
        for(int i = 0; i < list.Total(); i++)
        {
            CMarketPosition *pos = (CMarketPosition*)list.At(i);
            if(pos != NULL) total += pos.Profit();
        }
        return total;
    }
   //+------------------------------------------------------------------+
   double CTradingEngine::CalcProfit(void)
    {
        CArrayObj *list = m_market.GetList();
        list = CTradingSelect::ByOrderProperty(list, ORDER_PROP_STATUS, ORDER_STATUS_MARKET_POSITION, EQUAL);
        return SumFloatingProfit(list);
    }
   //+------------------------------------------------------------------+
   double CTradingEngine::CalcProfit(const string symbol)
    {
        CArrayObj *list = m_market.GetList();
        list = CTradingSelect::ByOrderProperty(list, ORDER_PROP_STATUS, ORDER_STATUS_MARKET_POSITION, EQUAL);
        list = CTradingSelect::ByOrderProperty(list, ORDER_PROP_SYMBOL, symbol, EQUAL);
        return SumFloatingProfit(list);
    }
   //+------------------------------------------------------------------+
   double CTradingEngine::CalcProfit(ENUM_POSITION_TYPE dir)
    {
        CArrayObj *list = m_market.GetList();
        list = CTradingSelect::ByOrderProperty(list, ORDER_PROP_STATUS, ORDER_STATUS_MARKET_POSITION, EQUAL);
        list = CTradingSelect::ByOrderProperty(list, ORDER_PROP_TYPE, (long)dir, EQUAL);
        return SumFloatingProfit(list);
    }
   //+------------------------------------------------------------------+
   double CTradingEngine::CalcProfit(const string symbol, ENUM_POSITION_TYPE dir)
    {
        CArrayObj *list = m_market.GetList();
        list = CTradingSelect::ByOrderProperty(list, ORDER_PROP_STATUS, ORDER_STATUS_MARKET_POSITION, EQUAL);
        list = CTradingSelect::ByOrderProperty(list, ORDER_PROP_SYMBOL, symbol, EQUAL);
        list = CTradingSelect::ByOrderProperty(list, ORDER_PROP_TYPE, (long)dir, EQUAL);
        return SumFloatingProfit(list);
    }
   //+------------------------------------------------------------------+
   double CTradingEngine::CalcProfitAt(const string symbol, ENUM_POSITION_TYPE dir,
                                        double target_price)
    {
        CArrayObj *list = m_market.GetList();
        list = CTradingSelect::ByOrderProperty(list, ORDER_PROP_STATUS, ORDER_STATUS_MARKET_POSITION, EQUAL);
        list = CTradingSelect::ByOrderProperty(list, ORDER_PROP_SYMBOL, symbol, EQUAL);
        list = CTradingSelect::ByOrderProperty(list, ORDER_PROP_TYPE, (long)dir, EQUAL);
        if(list == NULL) return 0;
        double total = 0;
        for(int i = 0; i < list.Total(); i++)
        {
            CMarketPosition *pos = (CMarketPosition*)list.At(i);
            if(pos == NULL) continue;
            double p = 0;
            if(OrderCalcProfit((ENUM_ORDER_TYPE)dir, symbol,
                            pos.Volume(), pos.PriceOpen(), target_price, p))
            total += p;
        }
        return total;
    }
   //+------------------------------------------------------------------+
   double CTradingEngine::CalcProfitAt(const string symbol, double price)
    {
        return CalcProfitAt(symbol, POSITION_TYPE_BUY,  price)
            + CalcProfitAt(symbol, POSITION_TYPE_SELL, price);
    }
  //Rebuild symbols collection for Symbols Information at tab Trade according to 
  // the selected mode in the GUI and return true if it is successful, otherwise false
  // bool CTradingEngine::RebuildSymbols(ENUM_SYMBOLS_MODE mode)
  // {
  //   if(mode == SYMBOLS_MODE_CURRENT)
  //     {
  //       string syms[1] = { ::Symbol() };
  //       m_symbols_rebuild_count = 1;
  //       return m_symbols.SetUsedSymbols(syms);
  //     }
  //   if(mode == SYMBOLS_MODE_DEFINES)
  //     {
  //       string syms[];
  //       string buf = "";
  //       int total = ::PositionsTotal();
  //       for(int i = 0; i < total; i++)
  //         {
  //           string sym = ::PositionGetSymbol(i);
  //           if(sym == "") continue;
  //           if(::StringFind(buf, sym, 0) == WRONG_VALUE)
  //               ::StringAdd(buf, (buf == "") ? sym : "," + sym);
  //         }
  //       ushort sep = ::StringGetCharacter(",", 0);
  //       ::StringSplit(buf, sep, syms);
  //       m_symbols_rebuild_count = ::ArraySize(syms);
  //       if(m_symbols_rebuild_count == 0)
  //           return true;  // no positions, skip rebuild
  //       return m_symbols.SetUsedSymbols(syms);
  //     }
  //   if(mode == SYMBOLS_MODE_MARKET_WATCH)
  //     {
  //       string clear[1] = { ::Symbol() };
  //       m_symbols.SetUsedSymbols(clear);  // force clear collection
  //       bool res = m_symbols.CreateSymbolsList(true);
  //       m_symbols_rebuild_count = m_symbols.GetSymbolsCollectionTotal();
  //       return res;
  //     }
  //   // SYMBOLS_MODE_ALL
  //     string clear[1] = { ::Symbol() };
  //     m_symbols.SetUsedSymbols(clear);  // force clear collection
  //     bool res = m_symbols.CreateSymbolsList(false);
  //     m_symbols_rebuild_count = m_symbols.GetSymbolsCollectionTotal();
  //   return res;
  // }

#endif // CTRADING_ENGINE_MQH_IMPLEMENTATION
#endif // __TRADING_ENGINE_MQH__
