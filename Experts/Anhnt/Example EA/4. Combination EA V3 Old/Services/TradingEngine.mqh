//+------------------------------------------------------------------+
//|                                                TradingEngine.mqh |
//| V3 CTradingEngine, first slices: the StopLost / Trailing prices  |
//| and distances the panel shows, the lot by risk and the New Order |
//| sending. The Indicator mode reads the value Python reports into  |
//| CIndicatorsCollection.                                           |
//+------------------------------------------------------------------+
#ifndef __TRADING_ENGINE_MQH__
#define __TRADING_ENGINE_MQH__
 #include <Vendors\Anhnt\Library\4. Combination Lib V3\Collections\SymbolsCollection.mqh>
 #include <Vendors\Anhnt\Library\4. Combination Lib V3\Collections\IndicatorsCollection.mqh>
 #include <Vendors\Anhnt\Library\4. Combination Lib V3\Collections\MarketCollection.mqh>
 #include "..\Configuration\TradingSetupSettingManager.mqh"
 #ifndef CTRADING_ENGINE_MQH_DECLARATION
 #define CTRADING_ENGINE_MQH_DECLARATION
  class CTradingEngine
   {
     private:
       CSymbolsCollection            *m_symbols_collection;       //borrowed from EA
       CIndicatorsCollection         *m_indicators_collection;    //borrowed from EA
       CMarketCollection             *m_market_collection;        //borrowed from EA
       CTradingSetupSettingManager   *m_trading_setup_manager;    //borrowed from EA
     public:
                                      CTradingEngine(void) : m_symbols_collection(NULL), m_indicators_collection(NULL), m_market_collection(NULL), m_trading_setup_manager(NULL) {}
       void                           SetSymbolsCollection(CSymbolsCollection *collection)              { m_symbols_collection = collection; }
       void                           SetIndicatorsCollection(CIndicatorsCollection *collection)        { m_indicators_collection = collection; }
       void                           SetMarketCollection(CMarketCollection *collection)                { m_market_collection = collection; }
       void                           SetTradingSetupManager(CTradingSetupSettingManager *manager)      { m_trading_setup_manager = manager; }
      //--- Distance in points of the Symbol's configured mode, -1 when it cannot be served
       int                            GetCurrent_StopLostDistance_Point(const string symbol, const ENUM_STOPLOST_TRAILING_MODE mode_override = WRONG_VALUE);
       int                            GetIndicator_StopLostDistance_Points(const string symbol, const ENUM_TIMEFRAMES tf, const ENUM_INDICATOR ind_type, MqlParam &raw_params[], const double mult);
       int                            GetCurrent_TrailingDistance_Points(const string symbol, const ENUM_STOPLOST_TRAILING_MODE mode_override = WRONG_VALUE);
       bool                           GetCurrent_TrailingIndicator_AnchorPrice(const string symbol, double &out_value);
      //--- Target prices of the configured StopLost / Trailing, EMPTY_VALUE when they cannot be served
       double                         Get_StopLost_TargetPrice(const string symbol, const ENUM_POSITION_TYPE type);
       double                         Get_Trailing_TargetPrice(const string symbol, const ENUM_POSITION_TYPE type);
      //--- The SL of the open Positions, else the better valid target of StopLost / Trailing
       double                         GetPreviewSLTargetPrice(const string symbol, const ENUM_POSITION_TYPE type, bool &out_from_trail);
      //--- Biggest lot that risk_percent of the balance and the free margin allow, 0 when none
       double                         CalcMaxLotByRisk(const string symbol, const ENUM_POSITION_TYPE type, const double risk_percent);
       bool                           SendNewOrder(const string symbol, const ENUM_POSITION_TYPE dir, const double lot, const int order_type_idx, const double price);
     private:
       double                         MinStopDistancePrice(CSymbol *sym) { return (sym == NULL) ? 0.0 : (sym.TradeStopLevel() == 0 ? sym.Spread()*2 : sym.TradeStopLevel()) * sym.Point(); }
       bool                           IsStopDistanceValid(CSymbol *sym, const ENUM_POSITION_TYPE type, const double price);
   };
 #endif // CTRADING_ENGINE_MQH_DECLARATION
 #ifndef CTRADING_ENGINE_MQH_IMPLEMENTATION
 #define CTRADING_ENGINE_MQH_IMPLEMENTATION
 //+------------------------------------------------------------------+
 //| StopLost distance: Fixed = Spread x multiplier, Indicator = the  |
 //| saved indicator value x multiplier                               |
 //+------------------------------------------------------------------+
 int CTradingEngine::GetCurrent_StopLostDistance_Point(const string symbol, const ENUM_STOPLOST_TRAILING_MODE mode_override)
  {
   if(m_trading_setup_manager == NULL) return -1;
   CTradingSetupSetting *row_setting = m_trading_setup_manager.FindByIdentity(symbol);
   if(row_setting == NULL) return -1;
   ENUM_STOPLOST_TRAILING_MODE mode = (mode_override == WRONG_VALUE) ? row_setting.StopLostMode() : mode_override;
   if(mode == SL_MODE_FIXED)
     {
      CSymbol *sym = (m_symbols_collection != NULL) ? m_symbols_collection.GetSymbolObjByName(symbol) : NULL;
      int spread_pts = (sym != NULL) ? sym.Spread() : (int)::SymbolInfoInteger(symbol, SYMBOL_SPREAD);
      return (int)::MathRound(spread_pts * row_setting.StopLostFixedMultiplier());
     }
   MqlParam raw_params[];
   row_setting.GetStopLostIndParams(raw_params);
   return GetIndicator_StopLostDistance_Points(symbol, row_setting.StopLostIndTF(), row_setting.StopLostIndType(), raw_params, row_setting.StopLostIndMultiplier());
  }
 //+------------------------------------------------------------------+
 //| Indicator value (ATR) in points x multiplier                     |
 //+------------------------------------------------------------------+
 int CTradingEngine::GetIndicator_StopLostDistance_Points(const string symbol, const ENUM_TIMEFRAMES tf, const ENUM_INDICATOR ind_type, MqlParam &raw_params[], const double mult)
  {
   if(m_indicators_collection == NULL) return -1;
   CIndicatorDE *ind = m_indicators_collection.GetIndicator(ind_type, raw_params, symbol, tf);
   if(ind == NULL) return -1;   // Python reports the chart Symbol only
   double v0 = ind.Value();
   double point = ::SymbolInfoDouble(symbol, SYMBOL_POINT);
   if(v0 == EMPTY_VALUE || point <= 0) return -1;
   return (int)::MathRound(mult * (v0 / point));
  }
 //+------------------------------------------------------------------+
 //| Trailing distance: Fixed = the offset, Indicator = price to the  |
 //| indicator line + the offset                                      |
 //+------------------------------------------------------------------+
 int CTradingEngine::GetCurrent_TrailingDistance_Points(const string symbol, const ENUM_STOPLOST_TRAILING_MODE mode_override)
  {
   if(m_trading_setup_manager == NULL) return -1;
   CTradingSetupSetting *row_setting = m_trading_setup_manager.FindByIdentity(symbol);
   if(row_setting == NULL) return -1;
   ENUM_STOPLOST_TRAILING_MODE mode = (mode_override == WRONG_VALUE) ? row_setting.TrailingMode() : mode_override;
   int offset_pts = row_setting.TrailingOffsetPts();
   if(mode == SL_MODE_FIXED) return offset_pts;
   double ind_value;
   if(!GetCurrent_TrailingIndicator_AnchorPrice(symbol, ind_value)) return -1;
   CSymbol *sym = (m_symbols_collection != NULL) ? m_symbols_collection.GetSymbolObjByName(symbol) : NULL;
   double bid   = (sym != NULL) ? sym.Bid()   : ::SymbolInfoDouble(symbol, SYMBOL_BID);
   double ask   = (sym != NULL) ? sym.Ask()   : ::SymbolInfoDouble(symbol, SYMBOL_ASK);
   double point = (sym != NULL) ? sym.Point() : ::SymbolInfoDouble(symbol, SYMBOL_POINT);
   if(point <= 0) return -1;
   double mid = (bid + ask) / 2.0;
   return (int)::MathRound(::MathAbs(mid - ind_value) / point) + offset_pts;
  }
 //+------------------------------------------------------------------+
 //| Value of the Trailing-by-Indicator source the Symbol saved       |
 //+------------------------------------------------------------------+
 bool CTradingEngine::GetCurrent_TrailingIndicator_AnchorPrice(const string symbol, double &out_value)
  {
   out_value = EMPTY_VALUE;
   if(m_trading_setup_manager == NULL || m_indicators_collection == NULL) return false;
   CTradingSetupSetting *row_setting = m_trading_setup_manager.FindByIdentity(symbol);
   if(row_setting == NULL || row_setting.TrailingIndType() == WRONG_VALUE) return false;
   MqlParam saved_params[];
   row_setting.GetTrailingIndParams(saved_params);
   CIndicatorDE *ind = m_indicators_collection.GetIndicator(row_setting.TrailingIndType(), saved_params, symbol, row_setting.TrailingIndTF());
   if(ind == NULL) return false;
   double v0 = ind.Value();
   if(v0 == EMPTY_VALUE) return false;
   out_value = v0;
   return true;
  }

 //+------------------------------------------------------------------+
 //| StopLost price: the distance of the configured mode from Bid/Ask |
 //+------------------------------------------------------------------+
 double CTradingEngine::Get_StopLost_TargetPrice(const string symbol, const ENUM_POSITION_TYPE type)
  {
   int distance_pts = GetCurrent_StopLostDistance_Point(symbol);   // already respects StopLostMode() internally
   if(distance_pts < 0) return EMPTY_VALUE;
   CSymbol *sym = (m_symbols_collection != NULL) ? m_symbols_collection.GetSymbolObjByName(symbol) : NULL;
   double point = (sym != NULL) ? sym.Point() : ::SymbolInfoDouble(symbol, SYMBOL_POINT);
   if(point <= 0) return EMPTY_VALUE;
   double distance_price = distance_pts * point;
   double bid = (sym != NULL) ? sym.Bid() : ::SymbolInfoDouble(symbol, SYMBOL_BID);
   double ask = (sym != NULL) ? sym.Ask() : ::SymbolInfoDouble(symbol, SYMBOL_ASK);
   return (type == POSITION_TYPE_BUY) ? (bid - distance_price) : (ask + distance_price);
  }
 //+------------------------------------------------------------------+
 //| Trailing price: Fixed = low/high of the M1 bar at the shift minus |
 //| / plus the offset, Indicator = the indicator value + the offset   |
 //+------------------------------------------------------------------+
 double CTradingEngine::Get_Trailing_TargetPrice(const string symbol, const ENUM_POSITION_TYPE type)
  {
   if(m_trading_setup_manager == NULL) return EMPTY_VALUE;
   CTradingSetupSetting *row_setting = m_trading_setup_manager.FindByIdentity(symbol);
   if(row_setting == NULL) return EMPTY_VALUE;
   CSymbol *sym = (m_symbols_collection != NULL) ? m_symbols_collection.GetSymbolObjByName(symbol) : NULL;
   double point = (sym != NULL) ? sym.Point() : ::SymbolInfoDouble(symbol, SYMBOL_POINT);
   if(point <= 0) return EMPTY_VALUE;
   int offset_pts = row_setting.TrailingOffsetPts();
   double base_price;
   if(row_setting.TrailingMode() == SL_MODE_FIXED)
    {
     int shift = m_trading_setup_manager.TrailingDataRatesIndex();
     base_price = (type == POSITION_TYPE_BUY) ? ::iLow(symbol, PERIOD_M1, shift) : ::iHigh(symbol, PERIOD_M1, shift);
     if(base_price <= 0) return EMPTY_VALUE;   // the M1 history is not there yet
    }
   else
    {
     double ind_value;
     if(!GetCurrent_TrailingIndicator_AnchorPrice(symbol, ind_value)) return EMPTY_VALUE;
     base_price = ind_value;
    }
   return (type == POSITION_TYPE_BUY) ? (base_price - offset_pts*point) : (base_price + offset_pts*point);
  }
 bool CTradingEngine::IsStopDistanceValid(CSymbol *sym, const ENUM_POSITION_TYPE type, const double price)
  {
   if(sym == NULL) return false;
   double min_dist = this.MinStopDistancePrice(sym);
   return (type == POSITION_TYPE_BUY) ? (sym.Bid() - price >= min_dist) : (price - sym.Ask() >= min_dist);
  }
 double CTradingEngine::GetPreviewSLTargetPrice(const string symbol, const ENUM_POSITION_TYPE type, bool &out_from_trail)
  {
   out_from_trail = false;
   double current_sl = (m_market_collection != NULL) ? m_market_collection.GetSL(symbol, type) : 0.0;
   if(current_sl > 0.0) return current_sl;
   if(m_trading_setup_manager == NULL) return EMPTY_VALUE;
   CTradingSetupSetting *row_setting = m_trading_setup_manager.FindByIdentity(symbol);
   if(row_setting == NULL) return EMPTY_VALUE;
   bool sl_active    = row_setting.StopLostActive();
   bool trail_active = row_setting.TrailingActive();
   if(!sl_active && !trail_active) return EMPTY_VALUE;
   CSymbol *sym = (m_symbols_collection != NULL) ? m_symbols_collection.GetSymbolObjByName(symbol) : NULL;
   if(sym == NULL || sym.Point() <= 0) return EMPTY_VALUE;
   double sl_price = sl_active ? Get_StopLost_TargetPrice(symbol, type) : EMPTY_VALUE;
   if(sl_price != EMPTY_VALUE && this.IsStopDistanceValid(sym, type, sl_price))
    {
     out_from_trail = false;
     return sl_price;
    }
   double trail_price = trail_active ? Get_Trailing_TargetPrice(symbol, type) : EMPTY_VALUE;
   if(trail_price != EMPTY_VALUE && this.IsStopDistanceValid(sym, type, trail_price))
    {
     out_from_trail = true;
     return trail_price;
    }
   return EMPTY_VALUE;
  }
 double CTradingEngine::CalcMaxLotByRisk(const string symbol, const ENUM_POSITION_TYPE type, const double risk_percent)
  {
   if(risk_percent <= 0.0 || m_market_collection == NULL) return 0.0;
   CSymbol *sym = (m_symbols_collection != NULL) ? m_symbols_collection.GetSymbolObjByName(symbol) : NULL;
   if(sym == NULL) return 0.0;
   double sl_price = Get_StopLost_TargetPrice(symbol, type);
   if(sl_price == EMPTY_VALUE) return 0.0;
   double money_per_lot = ::MathAbs(m_market_collection.SumFloatingProfit(symbol, type, sl_price, 1.0));
   if(money_per_lot <= 0.0) return 0.0;
   double balance = ::AccountInfoDouble(ACCOUNT_BALANCE);
   double raw_max_lot = (balance * risk_percent / 100.0) / money_per_lot;
   double open_price = (type == POSITION_TYPE_BUY) ? sym.Ask() : sym.Bid();
   double margin_per_lot = 0.0;
   if(::OrderCalcMargin((ENUM_ORDER_TYPE)type, symbol, 1.0, open_price, margin_per_lot) && margin_per_lot > 0.0)
    {
     double free_margin = ::AccountInfoDouble(ACCOUNT_MARGIN_FREE);
     double margin_max_lot = free_margin / margin_per_lot;
     if(margin_max_lot < raw_max_lot) raw_max_lot = margin_max_lot;
    }
   double step = sym.LotsStep();
   double lots_max = sym.LotsMax();
   if(step <= 0.0) return 0.0;
   double stepped = ::MathFloor(raw_max_lot / step) * step;
   if(stepped > lots_max) stepped = ::MathFloor(lots_max / step) * step;
   return (stepped > 0.0) ? stepped : 0.0;
  }
 bool CTradingEngine::SendNewOrder(const string symbol, const ENUM_POSITION_TYPE dir, const double lot, const int order_type_idx, const double price)
  {
   if(lot <= 0.0) return false;
   if((order_type_idx == 1 || order_type_idx == 2) && price <= 0.0)
    {
     ::Print("CTradingEngine::SendNewOrder: ", symbol, " rejected - Limit/Stop price not set (still 0.0)");
     return false;
    }
   CSymbol *sym = (m_symbols_collection != NULL) ? m_symbols_collection.GetSymbolObjByName(symbol) : NULL;
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
      ::Print("CTradingEngine::SendNewOrder: ", symbol, " rejected - Stop Limit not supported yet");
      return false;
    }
   if(!ok) ::Print("CTradingEngine::SendNewOrder: ", symbol, " FAILED, order_type_idx=", order_type_idx,
                   " lot=", lot, " price=", price, " error=", ::GetLastError());
   return ok;
  }
 #endif // CTRADING_ENGINE_MQH_IMPLEMENTATION
#endif // __TRADING_ENGINE_MQH__
