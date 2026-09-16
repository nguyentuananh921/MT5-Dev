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
double CTradingEngine::GetCurrent_StopLostDistance_MoneyForMinLot(const string symbol, const ENUM_STOPLOST_TRAILING_MODE mode_override = WRONG_VALUE)
 {
  int distance_pts = GetCurrent_StopLostDistance_Point(symbol, mode_override);
  if(distance_pts < 0) return EMPTY_VALUE;
  CSymbol *sym = m_symbol_collection.GetSymbolObjByName(symbol);
  if(sym == NULL) return EMPTY_VALUE;
  return distance_pts * sym.TradeTickValue() * sym.LotsMin();
 }
double CTradingEngine::CalcMaxLotByRisk(const string symbol, const ENUM_POSITION_TYPE type, const double risk_percent)
 {
  if(risk_percent <= 0.0) return 0.0;
  CSymbol *sym = m_symbol_collection.GetSymbolObjByName(symbol);
  if(sym == NULL) return 0.0;
  int distance_pts = GetCurrent_StopLostDistance_Point(symbol);
  if(distance_pts <= 0) return 0.0;
  double tick_value = sym.TradeTickValue();
  if(tick_value <= 0.0) return 0.0;
  double money_per_lot = distance_pts * tick_value;
  if(money_per_lot <= 0.0) return 0.0;
  CAccount *acc = m_accounts_collection.GetCurrentAccount();
  double balance = (acc != NULL) ? acc.Balance() : ::AccountInfoDouble(ACCOUNT_BALANCE);
  double raw_max_lot = (balance * risk_percent / 100.0) / money_per_lot;
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
  CArrayObj *ind_list = m_indicators_collection.GetListIndBySymbol(symbol);
  ind_list = CTimeseriesSelect::ByIndicatorProperty(ind_list, INDICATOR_PROP_TIMEFRAME, tf, EQUAL);
  int total = (ind_list != NULL) ? ind_list.Total() : 0;
  for(int i = 0; i < total; i++)
   {
    CIndicatorDE *cand = ind_list.At(i);
    if(cand == NULL || cand.TypeIndicator() != ind_type) continue;
    //--- RAW identity match (Anhnt, 2026-09-03) - project-wide convention for indicator
    //--- identity is TypeEnum()+IsEqualMqlParamArrays(), never a hand-picked param field.
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
//+------------------------------------------------------------------+
//| Live buffer value of the Symbol's currently-selected Trailing-by-  |
//| Indicator choice (TrailingIndTF/Type/Params on CTradingSetupSetting)|
//| - direct identity lookup on m_indicators_collection, same pattern   |
//| as GetIndicator_StopLostDistance_Points above (Anhnt/Claude,        |
//| 2026-09-15 - no longer builds the whole GUI choice list just to     |
//| filter down to the one already-saved identity; that choice-list     |
//| builder now lives on CGUIPannel, GUI-only consumer, see             |
//| [[project_v10_stoplost_trailing_engine_split]]). Reads shift=0      |
//| (Live), same convention as GetIndicator_StopLostDistance_Points -   |
//| no longer shares CTradingSetupSettingManager::TrailingDataRatesIndex|
//| with Fixed mode's own M1-bar shift, which is a separate concept in  |
//| Trishkin's own reference (CTrailingByValue takes no shift at all;   |
//| CTrailingByInd's own m_data_index defaults to 1, not shared) - Anhnt|
//| decided not to add a 3rd field just for this, plain Live is enough.|
//+------------------------------------------------------------------+
bool CTradingEngine::GetCurrent_TrailingIndicator_AnchorPrice(const string symbol, double &out_value)
 {
  out_value = EMPTY_VALUE;
  if(m_trading_setup_manager == NULL || m_indicators_collection == NULL) return false;
  CTradingSetupSetting *row_setting = m_trading_setup_manager.FindByIdentity(symbol);
  if(row_setting == NULL || row_setting.TrailingIndType() == WRONG_VALUE) return false;
  MqlParam saved_params[];
  row_setting.GetTrailingIndParams(saved_params);
  CArrayObj *ind_list = m_indicators_collection.GetListIndBySymbol(symbol);
  ind_list = CTimeseriesSelect::ByIndicatorProperty(ind_list, INDICATOR_PROP_TIMEFRAME, row_setting.TrailingIndTF(), EQUAL);
  int total = (ind_list != NULL) ? ind_list.Total() : 0;
  for(int i = 0; i < total; i++)
   {
    CIndicatorDE *cand = ind_list.At(i);
    if(cand == NULL || cand.TypeIndicator() != row_setting.TrailingIndType()) continue;
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
double CTradingEngine::GetTrailingMoneyValue(const string symbol, const ENUM_STOPLOST_TRAILING_MODE mode_override = WRONG_VALUE)
 {
  int distance_pts = GetCurrent_TrailingDistance_Points(symbol, mode_override);
  if(distance_pts < 0) return EMPTY_VALUE;
  CSymbol *sym = m_symbol_collection.GetSymbolObjByName(symbol);
  if(sym == NULL) return EMPTY_VALUE;
  return distance_pts * sym.TradeTickValue() * sym.LotsMin();
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
//+------------------------------------------------------------------+
//| Target Trailing price for one (Symbol,Direction) - Trishkin's own  |
//| CTrailingByValue/CTrailingByInd formulas:                          |
//|  Fixed:     ClosedM1Bar.Low/High(shift) ∓ Offset*Point             |
//|  Indicator: IndicatorValue ∓ Offset*Point                          |
//| Returns EMPTY_VALUE if the Symbol/Indicator data isn't available.  |
//+------------------------------------------------------------------+
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
int CTradingEngine::BuildSLCandidates(const string symbol, const ENUM_POSITION_TYPE type, const bool sl_active, 
  const bool trail_active, double &out_price[], bool &out_is_trail[])
 {
  ::ArrayResize(out_price, 0);
  ::ArrayResize(out_is_trail, 0);
  double sl_candidate    = sl_active    ? Get_StopLost_TargetPrice(symbol, type) : EMPTY_VALUE;
  double trail_candidate = trail_active ? Get_Trailing_TargetPrice(symbol, type) : EMPTY_VALUE;
  int n = 0;
  if(sl_candidate != EMPTY_VALUE)
   {
    ::ArrayResize(out_price, n+1); ::ArrayResize(out_is_trail, n+1);
    out_price[n] = sl_candidate; out_is_trail[n] = false; n++;
   }
  if(trail_candidate != EMPTY_VALUE)
   {
    bool trail_more_favorable = (n == 0) ||
       ((type == POSITION_TYPE_BUY) ? (trail_candidate > out_price[0]) : (trail_candidate < out_price[0]));
    ::ArrayResize(out_price, n+1); ::ArrayResize(out_is_trail, n+1);
    if(trail_more_favorable && n > 0)
     {
      out_price[n] = out_price[0]; out_is_trail[n] = out_is_trail[0];
      out_price[0] = trail_candidate; out_is_trail[0] = true;
     }
    else
     {
      out_price[n] = trail_candidate; out_is_trail[n] = true;
     }
    n++;
   }
  return n;
 }
//+------------------------------------------------------------------+
//| True if a candidate SL/TP price is far enough from the live market |
//| (Bid for a BUY exit, Ask for a SELL exit) per MinStopDistancePrice()|
//| above.                                                              |
//+------------------------------------------------------------------+
bool CTradingEngine::IsStopDistanceValid(CSymbol *sym, const ENUM_POSITION_TYPE type, const double price)
 {
  if(sym == NULL) return false;
  double min_dist = this.MinStopDistancePrice(sym);
  return (type == POSITION_TYPE_BUY) ? (sym.Bid() - price >= min_dist) : (price - sym.Ask() >= min_dist);
 }
//+------------------------------------------------------------------+
//| Preview target SL price for one (Symbol,Direction) - the best-of   |
//| StopLost/Trailing candidate, validated on the correct side of the  |
//| market (broker min-distance), matching what ApplyStopLostAndTrailing|
//| would actually target right now. Symbol+Direction-scoped, not a    |
//| specific position, so Trailing's own Start gate (needs one         |
//| position's own open price to compute profit) is NOT applied here - |
//| Trailing is always treated as ready to propose. Returns EMPTY_VALUE|
//| if neither Active or nothing valid.                                 |
//+------------------------------------------------------------------+
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

  double cand_price[]; bool cand_is_trail[];
  int cand_n = BuildSLCandidates(symbol, type, sl_active, trail_active, cand_price, cand_is_trail);  
  for(int c = 0; c < cand_n; c++)
   {
    double cprice = cand_price[c];
    if(!this.IsStopDistanceValid(sym, type, cprice)) continue;
    out_from_trail = cand_is_trail[c];
    return cprice;
   }
  return EMPTY_VALUE;
 }
//+------------------------------------------------------------------+
//| Money value of GetPreviewSLTargetPrice(). If a real Position exists |
//| for this Symbol+Direction, the distance is measured from its OWN     |
//| open price (POSITION_PRICE_OPEN) - a FIXED reference, so the result  |
//| only moves when the SL itself is actually modified, never with the   |
//| live market tick (Anhnt, 2026-09-10 - "cái cột StopLost Price đứng   |
//| thì cái cột bên cạnh cũng phải đứng... trừ phi trailling"). Falls     |
//| back to live Bid/Ask only for the no-Position-yet pretrade-preview   |
//| case, where there's no open price to anchor on. Default lot<=0 keeps |
//| the original LotsMin()-based convention; pass the actual picked Lot  |
//| for the real money-at-risk of THIS trade.                            |
//+------------------------------------------------------------------+
double CTradingEngine::GetPreviewSLMoneyValue(const string symbol, const ENUM_POSITION_TYPE type, const double lot = -1.0)
 {
  bool from_trail;
  double target = GetPreviewSLTargetPrice(symbol, type, from_trail);
  if(target == EMPTY_VALUE) return EMPTY_VALUE;
  CSymbol *sym = m_symbol_collection.GetSymbolObjByName(symbol);
  if(sym == NULL) return EMPTY_VALUE;
  double point = sym.Point();
  if(point <= 0) return EMPTY_VALUE;
  //--- First matching Position's own open price, read-only - reuses GetPositionList() instead of a
  //--- second hand-rolled ::PositionsTotal() loop (Anhnt/Claude, 2026-09-13).
   double cur_price = EMPTY_VALUE;
   CArrayObj *pos_list = this.m_market_collection.GetPositionList(symbol, type);
   if(pos_list != NULL && pos_list.Total() > 0)
    {
     CMarketPosition *pos = (CMarketPosition*)pos_list.At(0);
     if(pos != NULL) cur_price = pos.PriceOpen();
    }
  if(cur_price == EMPTY_VALUE) cur_price = (type == POSITION_TYPE_BUY) ? sym.Bid() : sym.Ask();
  double dist_pts = ::MathAbs(cur_price - target) / point;
  double use_lot = (lot > 0.0) ? lot : sym.LotsMin();
  return dist_pts * sym.TradeTickValue() * use_lot;
 }
//+------------------------------------------------------------------+
//| Sends a new trade using the New Order form's own picked params      |
//| (Anhnt, 2026-09-10). order_type_idx: 0=Market, 1=Limit, 2=Stop       |
//| (3=Stop Limit not supported yet - needs a 2nd price field, UI only   |
//| has one). SL is deliberately left at 0 - ApplyStopLostAndTrailing    |
//| bootstraps it the very next tick, the exact same path every other    |
//| Position already goes through (min-distance/ATR/Fixed logic already  |
//| proven there); computing it here first would risk a stale price by   |
//| the time the order actually fills. Magic number 20260910 is this     |
//| Panel's own (EA had none before).                                    |
//+------------------------------------------------------------------+
bool CTradingEngine::SendNewOrder(const string symbol, const ENUM_POSITION_TYPE dir, const double lot, const int order_type_idx, const double price)
 {
  if(lot <= 0.0) return false;
  //--- Limit/Stop need a real price - the UI's own placeholder default ("0.0") would otherwise
  //--- sail straight through to the broker and get rejected with no context (Anhnt, 2026-09-10).
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
      if(is_bootstrap)
         effective_trail_active = false;    
     double cand_price[]; bool cand_is_trail[];
     int cand_n = BuildSLCandidates(symbol, type, sl_active, effective_trail_active, cand_price, cand_is_trail);
     double sl_candidate    = (cand_n > 0 && !cand_is_trail[0]) ? cand_price[0] : ((cand_n > 1 && !cand_is_trail[1]) ? cand_price[1] : EMPTY_VALUE);
     double trail_candidate = (cand_n > 0 &&  cand_is_trail[0]) ? cand_price[0] : ((cand_n > 1 &&  cand_is_trail[1]) ? cand_price[1] : EMPTY_VALUE);
     double bid = sym.Bid(), ask = sym.Ask();   // kept for the debug log lines below, not for the distance check itself
     double best = EMPTY_VALUE, norm_best = EMPTY_VALUE;
     bool   best_from_trail = false, improves = false, valid_dist = false, did_modify = false;
     for(int c = 0; c < cand_n; c++)
      {
       double cprice = cand_price[c];
       bool   ctrail = cand_is_trail[c];       
       if(!ctrail && !is_bootstrap) continue;
       double c_improve_dist = (type == POSITION_TYPE_BUY) ? (cprice - current_sl) : (current_sl - cprice);
       double c_min_improve  = ctrail ? row_setting.TrailingStepPts()*point : 0.0;
       bool   c_improves = (current_sl == 0.0) || (c_improve_dist > c_min_improve);
       if(!c_improves) continue;
       bool c_valid_dist = this.IsStopDistanceValid(sym, type, cprice);
       if(!c_valid_dist) continue;
       double c_norm = ::NormalizeDouble(cprice, sym.Digits());
       if(c_norm == current_sl) continue; // rounding collapsed to no real change
       best = cprice; norm_best = c_norm; best_from_trail = ctrail; improves = true; valid_dist = true;
       CTradeObj *trade_obj = sym.GetTradeObj();
       if(trade_obj != NULL)
        {
         did_modify = trade_obj.ModifyPosition(ticket, c_norm);         
          {
           string dbg_fname = "CTradingEngine_Debug_Trailing.log";
           string dbg_path  = (g_ea_folder != "") ? (g_ea_folder + "/" + dbg_fname) : dbg_fname;
           int dbg_fh = ::FileOpen(dbg_path, FILE_READ|FILE_WRITE|FILE_TXT|FILE_ANSI);
           if(dbg_fh != INVALID_HANDLE)
            {
             if(::FileSize(dbg_fh) != 0) ::FileSeek(dbg_fh, 0, SEEK_END);
             string extra = "";
             if(ctrail)
              {
               int    offset_pts = row_setting.TrailingOffsetPts();
               //--- TrailingMode() printed directly (Anhnt/Claude, 2026-09-15) - the old "M1_base"
               //--- field re-derived base_price as c_norm∓offset_pts*point, which just reconstructs
               //--- target_price and says nothing about which mode (Fixed/Indicator) actually built
               //--- it, especially misleading when offset_pts=0 (base_price == target_price always).
               bool   is_fixed  = (row_setting.TrailingMode() == SL_MODE_FIXED);
               string mode_str  = is_fixed ? "Fixed" : "Indicator";
               //--- shift only means something for Fixed (M1 bar shift) - Indicator mode always
               //--- reads Live (shift=0), no shared field between the 2 modes (Anhnt, 2026-09-15).
               extra = " TrailingMode=" + mode_str + " offset_pts=" + (string)offset_pts +
                       " step_pts=" + (string)row_setting.TrailingStepPts() +
                       (is_fixed ? (" shift=" + (string)m_trading_setup_manager.TrailingDataRatesIndex()) : "");
              }
             ::FileWrite(dbg_fh, "MY DEBUG    CTradingEngine::ApplyStopLostAndTrailing ticket=", ticket, " sym=", symbol,
                         " type=", EnumToString(type), " source=", (ctrail ? "Trailing" : "StopLost"),
                         " current_SL_before=", current_sl, " target_price=", c_norm,
                         " Bid=", bid, " Ask=", ask, " did_modify=", did_modify, " last_err=", ::GetLastError(), extra);
             ::FileClose(dbg_fh);
            }
          }         
         if(did_modify && trade_obj.IsUseSound())
          {
           ENUM_ORDER_TYPE order_action = (type == POSITION_TYPE_BUY) ? ORDER_TYPE_BUY : ORDER_TYPE_SELL;
           //--- NOT trade_obj.PlaySoundSuccess() - it routes through CMessage::PlaySound() (Library,
           //--- Message.mqh), which unconditionally prepends "\Files\" to any non-built-in filename.
           //--- TERMINAL_PATH\Files\ doesn't exist (confirmed 2026-09-15), so that call always fails
           //--- even though the file is already correctly placed in TERMINAL_PATH\Sounds\ - a bare
           //--- filename passed straight to native ::PlaySound() resolves against Sounds\ correctly,
           //--- so call it directly here instead, bypassing the Library wrapper's broken prefix.
           if(trade_obj.UseSoundModifySL((int)order_action))
            {
             string trailing_sound_file = trade_obj.GetSoundModifySL(order_action);
             if(trailing_sound_file != "") ::PlaySound(trailing_sound_file);
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
              if(c_norm == sib_current_sl) continue; // rounding collapsed to no real change
              bool sib_did_modify = trade_obj.ModifyPosition(sib_ticket, c_norm);              
               {
                string sib_dbg_fname = "CTradingEngine_Debug_Trailing.log";
                string sib_dbg_path  = (g_ea_folder != "") ? (g_ea_folder + "/" + sib_dbg_fname) : sib_dbg_fname;
                int sib_dbg_fh = ::FileOpen(sib_dbg_path, FILE_READ|FILE_WRITE|FILE_TXT|FILE_ANSI);
                if(sib_dbg_fh != INVALID_HANDLE)
                 {
                  if(::FileSize(sib_dbg_fh) != 0) ::FileSeek(sib_dbg_fh, 0, SEEK_END);
                  ::FileWrite(sib_dbg_fh, "MY DEBUG    CTradingEngine::ApplyStopLostAndTrailing ticket=", sib_ticket, " sym=", symbol,
                              " type=", EnumToString(type), " source=StopLost-Sibling(from_ticket=", ticket, ")",
                              " current_SL_before=", sib_current_sl, " target_price=", c_norm,
                              " Bid=", bid, " Ask=", ask, " did_modify=", sib_did_modify, " last_err=", ::GetLastError());
                  ::FileClose(sib_dbg_fh);
                 }
               }
             }
           }
        }
       break; // first candidate that clears both gates wins - no need to try the other
      }
   }
 }
//+------------------------------------------------------------------+
//| Position count/volume/profit and distinct (Symbol,Direction) pairs |
//| moved to CMarketCollection (Anhnt/Claude, 2026-09-13) - see         |
//| GetPositionList()/SumVolume()/SumFloatingProfit()/                  |
//| GetDistinctSymbolsAndDirections() there; callers now go through     |
//| m_market_collection directly instead of this pass-through layer.   |
//+------------------------------------------------------------------+
#endif // CTRADINGENGINE_MULTIMODULE_MQH
