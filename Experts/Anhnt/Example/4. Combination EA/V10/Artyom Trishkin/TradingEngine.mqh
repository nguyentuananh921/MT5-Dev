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
  #include <Vendors\Anhnt\Library\4. Combination Lib\Collections\IndicatorsCollection.mqh>
  #include <Vendors\Anhnt\Library\4. Combination Lib\Collections\BarTimeSeriesCollection.mqh>
  #include <Vendors\Anhnt\Library\4. Combination Lib\Services\DELib\TimeseriesDELib.mqh>
  #include <Vendors\Anhnt\Library\4. Combination Lib\Trading\TradingControl.mqh>
  #include "..\Services\TradingSetupSetting.mqh"
  #include "..\Services\TradingSetupSettingManager.mqh"
  #include "..\Services\SymbolTFManager.mqh"
  #include "..\Services\IndicatorTemplateManager.mqh"
  extern string g_ea_folder;  // From EA - StopLost/Trailing Apply engine's own debug logs
#ifndef CTRADING_ENGINE_MQH_DECLARATION
#define CTRADING_ENGINE_MQH_DECLARATION
  //+------------------------------------------------------------------+
  //| Lightweight coordinator for trading data collections            |
  //+------------------------------------------------------------------+
  class CTradingEngine
    {
     private:
       //CollCollection        
        CAccountsCollection           m_accounts_collection;        // Account collection
        CSymbolsCollection            m_symbol_collection;          //For sybols information at tab Trade        
        CMarketCollection             m_market_collection;          // Collection of market orders and deals
        CHistoryCollection            m_history_collection;         // Collection of historical orders and deals        
        CTradeEventsCollection        m_trade_event_collection;     // Collection of events     
        bool                          m_is_market_trade_event;      // Account trading event flag
        bool                          m_is_history_trade_event;     // Account history trading event flag
        bool                          m_is_tester;                  // Flag of working in the tester
        CTradingControl               m_trading_control;            // Trading management object
       //
        bool                          m_is_first_start;             // First launch flag
       // StopLost/Trailing Apply engine pure trading-domain logic
        CBarTimeSeriesCollection     *m_BarTimeSeriesCollection;     //borrowed from CTimeSeriesEngine
        CIndicatorsCollection        *m_indicators_collection;       //borrowed from CTimeSeriesEngine
        CTradingSetupSettingManager  *m_trading_setup_manager;       //borrowed from EA
      //Private Method
        bool                         IsFirstStart(void);              // Return the first launch flag
      //--- Handling events of (1) orders, deals and positions, (2) accounts, (3) symbols
        void                         TradeEventsControl(void);
      //For stoplost      
        double                       MinStopDistancePrice(CSymbol *sym) { return (sym == NULL) ? 0.0 : (sym.TradeStopLevel() == 0 ? sym.Spread()*2 : sym.TradeStopLevel()) * sym.Point(); }
        bool                         IsStopDistanceValid(CSymbol *sym, const ENUM_POSITION_TYPE type, const double price);
     public:
       //CTradingEngine Lifecycle ->Implementation in CTradingEngine_Lifecycle.mqh 
        CTradingEngine(void);
       ~CTradingEngine(void);
        bool                         OnInitEvent(void);
        void                         OnTickEvent(void);
        void                         OnDeinitEvent(void) {}
       //For Pointer
        CAccountsCollection          *GetAccountsCollection(void) { return &m_accounts_collection;}
        CMarketCollection            *GetMarketCollection(void) { return &m_market_collection; }
        CSymbolsCollection           *GetSymbolsCollection(void) { return &m_symbol_collection; }
        CTradingControl              *GetTradingControl(void) { return &m_trading_control; }
       //Borrowed pointers for the StopLost/Trailing Apply engine below
        void                         SetTradingSetupManager(CTradingSetupSettingManager *manager)   { m_trading_setup_manager = manager; }
        void                         SetIndicatorsCollection(CIndicatorsCollection *ind)             { m_indicators_collection = ind;     }
        void                         SetBarTimeSeriesCollection(CBarTimeSeriesCollection *bars)      { m_BarTimeSeriesCollection = bars; }
       //For Stoplost and Trailling
        //Calculate stoplost base on SL_MODE_FIXED or SL_MODE_INDICATOR (base On ATR) 
         int                         GetCurrent_StopLostDistance_Point(const string symbol, const ENUM_STOPLOST_TRAILING_MODE mode_override = WRONG_VALUE);
         double                      GetCurrent_StopLostDistance_MoneyForMinLot(const string symbol, const ENUM_STOPLOST_TRAILING_MODE mode_override = WRONG_VALUE);
         double                      CalcMaxLotByRisk(const string symbol, const ENUM_POSITION_TYPE type, const double risk_percent);
         int                         GetIndicator_StopLostDistance_Points(const string symbol, const ENUM_TIMEFRAMES tf, const ENUM_INDICATOR ind_type, MqlParam &raw_params[], const double mult);
         double                      Get_StopLost_TargetPrice(const string symbol, const ENUM_POSITION_TYPE type);
       //Trailling
         int                         GetCurrent_TrailingDistance_Points(const string symbol, const ENUM_STOPLOST_TRAILING_MODE mode_override = WRONG_VALUE);
         bool                        GetCurrent_TrailingIndicator_AnchorPrice(const string symbol, double &out_value);
         double                      GetTrailingMoneyValue(const string symbol, const ENUM_STOPLOST_TRAILING_MODE mode_override = WRONG_VALUE);        
         double                      Get_Trailing_TargetPrice(const string symbol, const ENUM_POSITION_TYPE type);
         
         int                         BuildSLCandidates(const string symbol, const ENUM_POSITION_TYPE type, const bool sl_active, const bool trail_active, double &out_price[], bool &out_is_trail[]);
         double                      GetPreviewSLTargetPrice(const string symbol, const ENUM_POSITION_TYPE type, bool &out_from_trail);
         double                      GetPreviewSLMoneyValue(const string symbol, const ENUM_POSITION_TYPE type, const double lot = -1.0);
         void                        ApplyStopLostAndTrailing(const bool has_trade_event);
         bool                        SendNewOrder(const string symbol, const ENUM_POSITION_TYPE dir, const double lot, const int order_type_idx, const double price);
         
    };
#endif // CTRADING_ENGINE_MQH_DECLARATION
#ifndef CTRADING_ENGINE_MQH_IMPLEMENTATION
#define CTRADING_ENGINE_MQH_IMPLEMENTATION
#include "TradingEngine_Lifecycle.mqh" 
#include "TradingEngine_MultiModule.mqh" 
 //+------------------------------------------------------------------+
 //| Return the first launch flag, reset the flag                     |
 //+------------------------------------------------------------------+
 bool CTradingEngine::IsFirstStart(void) 
  {
   if (this.m_is_first_start) 
    {
     this.m_is_first_start = false;
     return true;
    }
   return false;
  } 

#endif // CTRADING_ENGINE_MQH_IMPLEMENTATION
#endif // __TRADING_ENGINE_MQH__
