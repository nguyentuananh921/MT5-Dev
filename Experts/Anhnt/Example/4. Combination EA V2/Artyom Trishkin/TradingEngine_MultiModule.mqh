//+------------------------------------------------------------------+
//|                                 TradingEngine_MultiModule.mqh    |
//| Implementation of function using in multi module Trading Engine  |
//+------------------------------------------------------------------+
#include "TradingEngine.mqh"
#ifndef CTRADINGENGINE_MULTIMODULE_MQH
#define CTRADINGENGINE_MULTIMODULE_MQH
 //+------------------------------------------------------------------+
 //| Check trading events                                             |
 //+------------------------------------------------------------------+
 void CTradingEngine::TradeEventsControl(void) 
  {
   //--- Initialize trading events' flags
    this.m_is_market_trade_event = false;
    this.m_is_history_trade_event = false;
    this.m_trade_event_collection .SetEventFlag(false);
    //--- Update the lists
     this.m_market_collection.Refresh();
     this.m_history_collection.Refresh();
    //--- First launch actions
    if (this.IsFirstStart())
       return;
    //--- Check the changes in the market status and account history
    this.m_is_market_trade_event = this.m_market_collection.IsTradeEvent();
    this.m_is_history_trade_event = this.m_history_collection.IsTradeEvent();

    //If there is any event, send the lists, the flags and the number of new orders and deals to the event collection, and update it
    int change_total = 0;
    CArrayObj *list_changes = this.m_market_collection.GetListChanges();
    if (list_changes != NULL)
      change_total = list_changes.Total();
    if (this.m_is_history_trade_event || this.m_is_market_trade_event ||
         change_total > 0) 
     {
      this.m_trade_event_collection.Refresh(
      this.m_history_collection.GetList(), this.m_market_collection.GetList(), list_changes,
      this.m_market_collection.GetListControl(), this.m_is_history_trade_event,
      this.m_is_market_trade_event, this.m_history_collection.NewOrders(),
      this.m_market_collection.NewPendingOrders(), this.m_market_collection.NewPositions(),
      this.m_history_collection.NewDeals(), this.m_market_collection.ChangedVolumeValue());
     }
  }
//+--------------------------------------------------------------------+
//| StopLost distance (points) of the Symbol's currently-configured    |
//| StopLost mode (Fixed = Spread*Multiplier, Indicator = ATR-style).  |
//+--------------------------------------------------------------------+
int CTradingEngine::GetCurrent_StopLostDistance_Point(const string symbol, const ENUM_STOPLOST_TRAILING_MODE mode_override = WRONG_VALUE)
 {
  if(m_trading_setup_manager == NULL) return -1;
  CTradingSetupSetting *row_setting = m_trading_setup_manager.FindByIdentity(symbol);
  if(row_setting == NULL) return -1;
  ENUM_STOPLOST_TRAILING_MODE mode = (mode_override == WRONG_VALUE) ? row_setting.StopLostMode() : mode_override;
  if(mode == SL_MODE_FIXED)
   {
    CSymbol *sym = m_symbol_collection.GetSymbolObjByName(symbol);
    int spread_pts = (sym != NULL) ? sym.Spread() : (int)::SymbolInfoInteger(symbol, SYMBOL_SPREAD);
    return (int)::MathRound(spread_pts * row_setting.StopLostFixedMultiplier());
   }
  MqlParam raw_params[];
  row_setting.GetStopLostIndParams(raw_params);
  return GetIndicator_StopLostDistance_Points(symbol, row_setting.StopLostIndTF(), row_setting.StopLostIndType(), raw_params, row_setting.StopLostIndMultiplier());
 } 
double CTradingEngine::CalcMaxLotByRisk(const string symbol, const ENUM_POSITION_TYPE type, const double risk_percent)
 {
  if(risk_percent <= 0.0) return 0.0;
  CSymbol *sym = m_symbol_collection.GetSymbolObjByName(symbol);
  if(sym == NULL) return 0.0;
  double sl_price = Get_StopLost_TargetPrice(symbol, type);
  if(sl_price == EMPTY_VALUE) return 0.0;
  double money_per_lot = ::MathAbs(m_market_collection.SumFloatingProfit(symbol, type, sl_price, 1.0));
  if(money_per_lot <= 0.0) return 0.0;
  CAccount *acc = m_accounts_collection.GetCurrentAccount();
  double balance = (acc != NULL) ? acc.Balance() : ::AccountInfoDouble(ACCOUNT_BALANCE);
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
int CTradingEngine::GetIndicator_StopLostDistance_Points(const string symbol, const ENUM_TIMEFRAMES tf, const ENUM_INDICATOR ind_type, MqlParam &raw_params[], const double mult)
 {
  if(m_indicators_collection == NULL) return -1;
  CArrayObj *ind_list = m_indicators_collection.GetList();   // filtered inline below - no Select per tick
  int total = (ind_list != NULL) ? ind_list.Total() : 0;
  for(int i = 0; i < total; i++)
   {
    CIndicatorDE *cand = ind_list.At(i);
    if(cand == NULL || cand.Symbol() != symbol || cand.Timeframe() != tf || cand.TypeIndicator() != ind_type) continue;
    //--- RAW identity: type + full MqlParam array
    MqlParam cand_params[];
    cand.GetMqlParams(cand_params);
    if(!IsEqualMqlParamArrays(cand_params, raw_params)) continue;
    double v0    = cand.GetDataBuffer(0, 0);
    double point = ::SymbolInfoDouble(symbol, SYMBOL_POINT);
    if(v0 == EMPTY_VALUE || point <= 0) return -1;
    return (int)::MathRound(mult * (v0 / point));
   }
  return -1; // instance not synced yet
 }
int CTradingEngine::GetCurrent_TrailingDistance_Points(const string symbol, const ENUM_STOPLOST_TRAILING_MODE mode_override = WRONG_VALUE)
 {
  if(m_trading_setup_manager == NULL) return -1;
  CTradingSetupSetting *row_setting = m_trading_setup_manager.FindByIdentity(symbol);
  if(row_setting == NULL) return -1;
  ENUM_STOPLOST_TRAILING_MODE mode = (mode_override == WRONG_VALUE) ? row_setting.TrailingMode() : mode_override;
  int offset_pts = row_setting.TrailingOffsetPts();
  if(mode == SL_MODE_FIXED) return offset_pts;
  double ind_value;
  if(!GetCurrent_TrailingIndicator_AnchorPrice(symbol, ind_value)) return -1;
  CSymbol *sym = m_symbol_collection.GetSymbolObjByName(symbol);
  double bid   = (sym != NULL) ? sym.Bid()   : ::SymbolInfoDouble(symbol, SYMBOL_BID);
  double ask   = (sym != NULL) ? sym.Ask()   : ::SymbolInfoDouble(symbol, SYMBOL_ASK);
  double point = (sym != NULL) ? sym.Point() : ::SymbolInfoDouble(symbol, SYMBOL_POINT);
  if(point <= 0) return -1;
  double mid = (bid + ask) / 2.0;
  return (int)::MathRound(::MathAbs(mid - ind_value) / point) + offset_pts;
 }
bool CTradingEngine::GetCurrent_TrailingIndicator_AnchorPrice(const string symbol, double &out_value)
 {
  out_value = EMPTY_VALUE;
  if(m_trading_setup_manager == NULL || m_indicators_collection == NULL) return false;
  CTradingSetupSetting *row_setting = m_trading_setup_manager.FindByIdentity(symbol);
  if(row_setting == NULL || row_setting.TrailingIndType() == WRONG_VALUE) return false;
  MqlParam saved_params[];
  row_setting.GetTrailingIndParams(saved_params);
  CArrayObj *ind_list = m_indicators_collection.GetList();   // filtered inline below - no Select per tick
  int total = (ind_list != NULL) ? ind_list.Total() : 0;
  for(int i = 0; i < total; i++)
   {
    CIndicatorDE *cand = ind_list.At(i);
    if(cand == NULL || cand.Symbol() != symbol || cand.Timeframe() != row_setting.TrailingIndTF() ||
       cand.TypeIndicator() != row_setting.TrailingIndType()) continue;
    MqlParam cand_params[];
    cand.GetMqlParams(cand_params);
    if(!IsEqualMqlParamArrays(cand_params, saved_params)) continue;
    double v0 = cand.GetDataBuffer(0, 0);
    if(v0 == EMPTY_VALUE) return false;
    out_value = v0;
    return true;
   }
  return false;
 }
double CTradingEngine::Get_StopLost_TargetPrice(const string symbol, const ENUM_POSITION_TYPE type)
 {
  int distance_pts = GetCurrent_StopLostDistance_Point(symbol);   // already respects StopLostMode() internally
  if(distance_pts < 0) return EMPTY_VALUE;
  CSymbol *sym = m_symbol_collection.GetSymbolObjByName(symbol);
  double point = (sym != NULL) ? sym.Point() : ::SymbolInfoDouble(symbol, SYMBOL_POINT);
  if(point <= 0) return EMPTY_VALUE;
  double distance_price = distance_pts * point;
  double bid = (sym != NULL) ? sym.Bid() : ::SymbolInfoDouble(symbol, SYMBOL_BID);
  double ask = (sym != NULL) ? sym.Ask() : ::SymbolInfoDouble(symbol, SYMBOL_ASK);
  return (type == POSITION_TYPE_BUY) ? (bid - distance_price) : (ask + distance_price);
 }
double CTradingEngine::Get_Trailing_TargetPrice(const string symbol, const ENUM_POSITION_TYPE type)
 {
  if(m_trading_setup_manager == NULL) return EMPTY_VALUE;
  CTradingSetupSetting *row_setting = m_trading_setup_manager.FindByIdentity(symbol);
  if(row_setting == NULL) return EMPTY_VALUE;
  CSymbol *sym = m_symbol_collection.GetSymbolObjByName(symbol);
  double point = (sym != NULL) ? sym.Point() : ::SymbolInfoDouble(symbol, SYMBOL_POINT);
  if(point <= 0) return EMPTY_VALUE;
  int offset_pts = row_setting.TrailingOffsetPts();
  double base_price;
  if(row_setting.TrailingMode() == SL_MODE_FIXED)
   {    
    if(m_BarTimeSeriesCollection == NULL) return EMPTY_VALUE;
    if(!m_BarTimeSeriesCollection.IsAvailable(symbol, PERIOD_M1))
       m_BarTimeSeriesCollection.CreateSeries(symbol, PERIOD_M1);
    CBarSeriesDE *series = m_BarTimeSeriesCollection.GetSeries(symbol, PERIOD_M1);
    if(series == NULL) return EMPTY_VALUE;
    int shift = m_trading_setup_manager.TrailingDataRatesIndex();
    base_price = (type == POSITION_TYPE_BUY) ? series.Low(shift) : series.High(shift);
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
  double current_sl = m_market_collection.GetSL(symbol, type);
  if(current_sl > 0.0) return current_sl;
  if(m_trading_setup_manager == NULL) return EMPTY_VALUE;
  CTradingSetupSetting *row_setting = m_trading_setup_manager.FindByIdentity(symbol);
  if(row_setting == NULL) return EMPTY_VALUE;
  bool sl_active    = row_setting.StopLostActive();
  bool trail_active = row_setting.TrailingActive();
  if(!sl_active && !trail_active) return EMPTY_VALUE;
  CSymbol *sym = m_symbol_collection.GetSymbolObjByName(symbol);
  if(sym == NULL) return EMPTY_VALUE;
  if(sym.Point() <= 0) return EMPTY_VALUE;  
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
bool CTradingEngine::SendNewOrder(const string symbol, const ENUM_POSITION_TYPE dir, const double lot, const int order_type_idx, const double price)
 {
  if(lot <= 0.0) return false;  
  if((order_type_idx == 1 || order_type_idx == 2) && price <= 0.0)
   {
    ::Print("CTradingEngine::SendNewOrder: ", symbol, " rejected - Limit/Stop price not set (still 0.0)");
    return false;
   }
  CSymbol *sym = m_symbol_collection.GetSymbolObjByName(symbol);
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
void CTradingEngine::ApplyStopLostAndTrailing(const bool has_trade_event)
 {
  if(m_trading_setup_manager == NULL) return;  
  string sound_played_keys = "|";
  int total = ::PositionsTotal();
  for(int i = total - 1; i >= 0; i--)
   {
    ulong ticket = ::PositionGetTicket(i);
    if(ticket == 0 || !::PositionSelectByTicket(ticket)) continue;
    string symbol = ::PositionGetString(POSITION_SYMBOL);
    ENUM_POSITION_TYPE type = (ENUM_POSITION_TYPE)::PositionGetInteger(POSITION_TYPE);

    CTradingSetupSetting *row_setting = m_trading_setup_manager.FindByIdentity(symbol);
    if(row_setting == NULL) continue;
    bool sl_active    = row_setting.StopLostActive();    
    bool trail_active = row_setting.TrailingActive();
    if(!sl_active && !trail_active) continue;
    CSymbol *sym = m_symbol_collection.GetSymbolObjByName(symbol);
    if(sym == NULL) continue;
    double point = sym.Point();
    if(point <= 0) continue;    
     double current_sl  = ::PositionGetDouble(POSITION_SL);
     bool   is_bootstrap = (current_sl == 0.0);    
     bool effective_trail_active = trail_active;
     if(trail_active)
      {
       int start_pts = row_setting.TrailingStartPts();
       if(start_pts > 0)
        {
         double open_price = ::PositionGetDouble(POSITION_PRICE_OPEN);
         double cur_price  = (type == POSITION_TYPE_BUY) ? sym.Bid() : sym.Ask();
         double profit_pts = (type == POSITION_TYPE_BUY) ? (cur_price - open_price)/point : (open_price - cur_price)/point;
         effective_trail_active = (profit_pts > start_pts);
        }
      }     
     //--- Two independent switches
     //---  sl_active    - bootstrap only: StopLost target for a position that has no SL yet
     //---  trail_active - every tick, every position (SL or not): StopLost target AND Trailing
     //---                 target both compete, the better improvement wins
     //--- With trail_active off an existing SL is never touched (StopLost alone must not trail).
      double sl_price    = ((is_bootstrap && sl_active) || effective_trail_active) ? Get_StopLost_TargetPrice(symbol, type) : EMPTY_VALUE;
      double trail_price = effective_trail_active ? Get_Trailing_TargetPrice(symbol, type) : EMPTY_VALUE;
      double sl_improve = EMPTY_VALUE, sl_norm = EMPTY_VALUE;
      if(sl_price != EMPTY_VALUE)
       {
        double d = (type == POSITION_TYPE_BUY) ? (sl_price - current_sl) : (current_sl - sl_price);
        double n = ::NormalizeDouble(sl_price, sym.Digits());        
        if(((current_sl == 0.0) || (d > 0.0)) && ::MathAbs(n - current_sl) >= point/2 && this.IsStopDistanceValid(sym, type, sl_price))
         {
          sl_improve = d;
          sl_norm    = n;
         }
       }
      double trail_improve = EMPTY_VALUE, trail_norm = EMPTY_VALUE;
      if(trail_price != EMPTY_VALUE)
       {
        double d = (type == POSITION_TYPE_BUY) ? (trail_price - current_sl) : (current_sl - trail_price);
        double min_improve = row_setting.TrailingStepPts()*point;
        double n = ::NormalizeDouble(trail_price, sym.Digits());
        //--- Same point/2 tolerance as the StopLost candidate above, same reason.
        if(((current_sl == 0.0) || (d > min_improve)) && ::MathAbs(n - current_sl) >= point/2 && this.IsStopDistanceValid(sym, type, trail_price))
         {
          trail_improve = d;
          trail_norm    = n;
         }
       }
      //--- Pick whichever valid candidate improves MORE; if only one is valid, use it; if neither,nothing to do this tick
       bool   ctrail  = false;
       double c_norm  = EMPTY_VALUE;
       if(sl_improve != EMPTY_VALUE && trail_improve != EMPTY_VALUE)
        {
         ctrail = (trail_improve > sl_improve);
         c_norm = ctrail ? trail_norm : sl_norm;
        }
       else if(sl_improve != EMPTY_VALUE)
        {
         ctrail = false;
         c_norm = sl_norm;
        }
       else if(trail_improve != EMPTY_VALUE)
        {
         ctrail = true;
         c_norm = trail_norm;
        }
       else
        {
         continue; // neither candidate valid this tick
        }
       CTradeObj *trade_obj = sym.GetTradeObj();
       if(trade_obj != NULL)
        {
         bool did_modify = trade_obj.ModifyPosition(ticket, c_norm);
         if(did_modify && trade_obj.IsUseSound())
          {
           ENUM_ORDER_TYPE order_action = (type == POSITION_TYPE_BUY) ? ORDER_TYPE_BUY : ORDER_TYPE_SELL;
           if(trade_obj.UseSoundModifySL((int)order_action))
            {
             string trailing_sound_file = trade_obj.GetSoundModifySL(order_action);
             string sound_key = symbol + "_" + EnumToString(type);
             if(trailing_sound_file != "" && ::StringFind(sound_played_keys, "|" + sound_key + "|") < 0)
              {
               ::PlaySound(trailing_sound_file);
               sound_played_keys += sound_key + "|";
              }
            }
          }
          if(did_modify && has_trade_event && is_bootstrap && !ctrail)
           {
            int sib_total = ::PositionsTotal();
            for(int j = sib_total - 1; j >= 0; j--)
             {
              ulong sib_ticket = ::PositionGetTicket(j);
              if(sib_ticket == 0 || sib_ticket == ticket || !::PositionSelectByTicket(sib_ticket)) continue;
              if(::PositionGetString(POSITION_SYMBOL) != symbol) continue;
              if((ENUM_POSITION_TYPE)::PositionGetInteger(POSITION_TYPE) != type) continue;
              double sib_current_sl = ::PositionGetDouble(POSITION_SL);
              double sib_improve = (type == POSITION_TYPE_BUY) ? (c_norm - sib_current_sl) : (sib_current_sl - c_norm);
              bool   sib_improves = (sib_current_sl == 0.0) || (sib_improve > 0);
              if(!sib_improves) continue;
              bool sib_valid_dist = this.IsStopDistanceValid(sym, type, c_norm);
              if(!sib_valid_dist) continue;
              if(::MathAbs(c_norm - sib_current_sl) < point/2) continue; // rounding collapsed to no real change - same point/2 tolerance as the main candidate checks above
              trade_obj.ModifyPosition(sib_ticket, c_norm);
             }
           }
        }
   }
 }
#endif // CTRADINGENGINE_MULTIMODULE_MQH
