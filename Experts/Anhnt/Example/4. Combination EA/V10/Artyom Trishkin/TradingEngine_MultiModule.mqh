//+------------------------------------------------------------------+
//|                                 TradingEngine_MultiModule.mqh    |
//| Implementation of function using in multi module Trading Engine  |
//+------------------------------------------------------------------+
#include "TradingEngine.mqh"
#ifndef CTRADINGENGINE_MULTIMODULE_MQH
#define CTRADINGENGINE_MULTIMODULE_MQH
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
   CArrayObj *list = m_market_collection.GetList();
   list = CTradingSelect::ByOrderProperty(list, ORDER_PROP_STATUS, ORDER_STATUS_MARKET_POSITION, EQUAL);
   return SumFloatingProfit(list);
  }
 //+------------------------------------------------------------------+
 double CTradingEngine::CalcProfit(const string symbol)
  {
   CArrayObj *list = m_market_collection.GetList();
   list = CTradingSelect::ByOrderProperty(list, ORDER_PROP_STATUS, ORDER_STATUS_MARKET_POSITION, EQUAL);
   list = CTradingSelect::ByOrderProperty(list, ORDER_PROP_SYMBOL, symbol, EQUAL);
   return SumFloatingProfit(list);
  }
 //+------------------------------------------------------------------+
 double CTradingEngine::CalcProfit(ENUM_POSITION_TYPE dir)
  {
   CArrayObj *list = m_market_collection.GetList();
   list = CTradingSelect::ByOrderProperty(list, ORDER_PROP_STATUS, ORDER_STATUS_MARKET_POSITION, EQUAL);
   list = CTradingSelect::ByOrderProperty(list, ORDER_PROP_TYPE, (long)dir, EQUAL);
   return SumFloatingProfit(list);
  }
 //+------------------------------------------------------------------+
 double CTradingEngine::CalcProfit(const string symbol, ENUM_POSITION_TYPE dir)
  {
   CArrayObj *list = m_market_collection.GetList();
   list = CTradingSelect::ByOrderProperty(list, ORDER_PROP_STATUS, ORDER_STATUS_MARKET_POSITION, EQUAL);
   list = CTradingSelect::ByOrderProperty(list, ORDER_PROP_SYMBOL, symbol, EQUAL);
   list = CTradingSelect::ByOrderProperty(list, ORDER_PROP_TYPE, (long)dir, EQUAL);
   return SumFloatingProfit(list);
  }
 //+------------------------------------------------------------------+
 double CTradingEngine::CalcProfitAt(const string symbol, ENUM_POSITION_TYPE dir,
                                        double target_price)
  {
   CArrayObj *list = m_market_collection.GetList();
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
//+------------------------------------------------------------------+
//| StopLost/Trailing Apply engine (moved from CGUIPannel_NewFeatures.mqh /
//| GUIPannel_SettingWindows_TradingStopLost.mqh / GUIPannel_SettingWindows_
//| TradingTrailing.mqh / GUIPannel_MainWindows_TabTrading.mqh, Anhnt/Claude,
//| 2026-09-09 - pure trading-domain logic, doesn't belong in the GUI layer.
//| CGUIPannel now only calls through m_tradingEngine to display the numbers.
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//| Shared core: ATR-style Indicator distance lookup, in points.      |
//| Used both by GetCurrentStopLostDistancePoints (saved config) and  |
//| CGUIPannel::UpdateStopLostPreview (live unsaved form fields).     |
//+------------------------------------------------------------------+
int CTradingEngine::GetIndicatorStopLostDistancePoints(const string symbol, const ENUM_TIMEFRAMES tf, const ENUM_INDICATOR ind_type, MqlParam &raw_params[], const double mult)
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
//+------------------------------------------------------------------+
//| StopLost distance (points) of the Symbol's currently-configured   |
//| StopLost mode (Fixed = Spread*Multiplier, Indicator = ATR-style). |
//+------------------------------------------------------------------+
int CTradingEngine::GetCurrentStopLostDistancePoints(const string symbol, const ENUM_STOPLOST_TRAILING_MODE mode_override = WRONG_VALUE)
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
  return GetIndicatorStopLostDistancePoints(symbol, row_setting.StopLostIndTF(), row_setting.StopLostIndType(), raw_params, row_setting.StopLostIndMultiplier());
 }
//+------------------------------------------------------------------+
//| StopLost distance (price units) of the Symbol's currently-        |
//| configured StopLost mode.                                        |
//+------------------------------------------------------------------+
double CTradingEngine::GetStopLostDistancePrice(const string symbol, const ENUM_STOPLOST_TRAILING_MODE mode_override = WRONG_VALUE)
 {
  int distance_pts = GetCurrentStopLostDistancePoints(symbol, mode_override);
  if(distance_pts < 0) return EMPTY_VALUE;
  CSymbol *sym = m_symbol_collection.GetSymbolObjByName(symbol);
  double point = (sym != NULL) ? sym.Point() : ::SymbolInfoDouble(symbol, SYMBOL_POINT);
  if(point <= 0) return EMPTY_VALUE;
  return distance_pts * point;
 }
//+------------------------------------------------------------------+
//| Target SL price for one (Symbol,Direction) - Mid -/+ the          |
//| currently-configured Distance (Fixed or ATR, whichever            |
//| CTradingSetupSetting.StopLostMode() says is active). Returns      |
//| EMPTY_VALUE if the distance/Symbol isn't available.                |
//+------------------------------------------------------------------+
double CTradingEngine::GetStopLostTargetPrice(const string symbol, const ENUM_POSITION_TYPE type)
 {
  double distance_price = GetStopLostDistancePrice(symbol);   // already respects StopLostMode() internally
  if(distance_price == EMPTY_VALUE) return EMPTY_VALUE;
  CSymbol *sym = m_symbol_collection.GetSymbolObjByName(symbol);
  double bid = (sym != NULL) ? sym.Bid() : ::SymbolInfoDouble(symbol, SYMBOL_BID);
  double ask = (sym != NULL) ? sym.Ask() : ::SymbolInfoDouble(symbol, SYMBOL_ASK);
  double mid = (bid + ask) / 2.0;
  return (type == POSITION_TYPE_BUY) ? (mid - distance_price) : (mid + distance_price);
 }
//+------------------------------------------------------------------+
//| Shared core: every live CIndicatorDE instance tracked for the      |
//| given Symbol (across every tracked TF). Restricted to              |
//| INDICATOR_GROUP_TREND, exactly 1 buffer, minus StdDev - only       |
//| single-price-level indicators are valid Trailing-by-Indicator      |
//| candidates (CTrailingByInd reads ONE value, no Upper/Lower          |
//| selection exists in Trishkin's reference).                         |
//+------------------------------------------------------------------+
int CTradingEngine::BuildTrailingIndicatorChoiceList(const string symbol, CIndicatorDE* &out_inds[], ENUM_TIMEFRAMES &out_tfs[])
 {
  int count = 0;
  ::ArrayResize(out_inds, 0);
  ::ArrayResize(out_tfs,  0);
  if(m_indicators_collection == NULL || m_symbol_tf_manager == NULL || m_indicator_template_manager == NULL) return 0;
  int symtf_total = m_symbol_tf_manager.Total();
  int tmpl_total  = m_indicator_template_manager.Total();
  for(int si = 0; si < symtf_total; si++)
   {
    CSymbolTFSetting *symtf = m_symbol_tf_manager.At(si);
    if(symtf == NULL || symtf.Symbol() != symbol) continue;
    ENUM_TIMEFRAMES tf = symtf.TFEnum();
    CArrayObj *ind_list = m_indicators_collection.GetListIndBySymbol(symbol);
    ind_list = CTimeseriesSelect::ByIndicatorProperty(ind_list, INDICATOR_PROP_TIMEFRAME, tf, EQUAL);
    int ind_total = (ind_list != NULL) ? ind_list.Total() : 0;
    if(ind_total == 0) continue;
    for(int ti = 0; ti < tmpl_total; ti++)
     {
      CIndicatorSetting *entry = m_indicator_template_manager.At(ti);
      if(entry == NULL) continue;
      ENUM_INDICATOR ind_type = entry.TypeEnum();
      if(GetIndicatorGroupForType(ind_type) != INDICATOR_GROUP_TREND) continue;
      if(GetIndicatorBuffersTotal(ind_type) != 1) continue;
      if(ind_type == IND_STDDEV) continue;
      MqlParam raw_params[];
      entry.GetRawParams(raw_params);
      if(::ArraySize(raw_params) == 0) continue;
      CIndicatorDE *ind = NULL;
      for(int ii = 0; ii < ind_total; ii++)
       {
        CIndicatorDE *cand = ind_list.At(ii);
        if(cand == NULL || cand.TypeIndicator() != entry.TypeEnum()) continue;
        MqlParam cand_params[];
        cand.GetMqlParams(cand_params);
        if(IsEqualMqlParamArrays(cand_params, raw_params)) { ind = cand; break; }
       }
      if(ind == NULL) continue; // template not instantiated on this Symbol+TF yet
      ::ArrayResize(out_inds, count + 1);
      ::ArrayResize(out_tfs,  count + 1);
      out_inds[count] = ind;
      out_tfs[count]  = tf;
      count++;
     }
   }
  return count;
 }
//+------------------------------------------------------------------+
//| Live buffer value of the Symbol's currently-selected Trailing-by-  |
//| Indicator choice (TrailingIndTF/Type/Params on CTradingSetupSetting)|
//| - same identity match BuildTrailingIndicatorChoiceList's own       |
//| candidates use. Returns false if nothing chosen yet or the          |
//| instance isn't synced.                                             |
//+------------------------------------------------------------------+
bool CTradingEngine::GetCurrentTrailingIndicatorValue(const string symbol, double &out_value)
 {
  out_value = EMPTY_VALUE;
  if(m_trading_setup_manager == NULL) return false;
  CTradingSetupSetting *row_setting = m_trading_setup_manager.FindByIdentity(symbol);
  if(row_setting == NULL || row_setting.TrailingIndType() == WRONG_VALUE) return false;
  MqlParam saved_params[];
  row_setting.GetTrailingIndParams(saved_params);
  CIndicatorDE   *inds[];
  ENUM_TIMEFRAMES tfs[];
  int count = BuildTrailingIndicatorChoiceList(symbol, inds, tfs);
  for(int i = 0; i < count; i++)
   {
    if(tfs[i] != row_setting.TrailingIndTF() || inds[i].TypeIndicator() != row_setting.TrailingIndType()) continue;
    MqlParam ind_params[];
    inds[i].GetMqlParams(ind_params);
    if(!IsEqualMqlParamArrays(ind_params, saved_params)) continue;
    double v0 = inds[i].GetDataBuffer(0, 0);
    if(v0 == EMPTY_VALUE) return false;
    out_value = v0;
    return true;
   }
  return false;
 }
//+------------------------------------------------------------------+
//| Target Trailing price for one (Symbol,Direction) - Trishkin's own  |
//| CTrailingByValue/CTrailingByInd formulas:                          |
//|  Fixed:     CurrentPrice(Bid/Ask) ∓ Offset*Point                   |
//|  Indicator: IndicatorValue ∓ Offset*Point                          |
//| Returns EMPTY_VALUE if the Symbol/Indicator data isn't available.  |
//+------------------------------------------------------------------+
double CTradingEngine::GetTrailingTargetPrice(const string symbol, const ENUM_POSITION_TYPE type)
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
    //--- CTrailingByValue anchors on the CURRENT tick price (Bid for Buy, Ask for Sell).
    double bid = (sym != NULL) ? sym.Bid() : ::SymbolInfoDouble(symbol, SYMBOL_BID);
    double ask = (sym != NULL) ? sym.Ask() : ::SymbolInfoDouble(symbol, SYMBOL_ASK);
    base_price = (type == POSITION_TYPE_BUY) ? bid : ask;
   }
  else
   {
    double ind_value;
    if(!GetCurrentTrailingIndicatorValue(symbol, ind_value)) return EMPTY_VALUE;
    base_price = ind_value;
   }
  return (type == POSITION_TYPE_BUY) ? (base_price - offset_pts*point) : (base_price + offset_pts*point);
 }
//+------------------------------------------------------------------+
//| Best-first ordered StopLost/Trailing candidate list for one        |
//| (Symbol,Direction) - shared by ApplyStopLostAndTrailing (which      |
//| layers its own per-POSITION never-worse/Step/min-distance gate      |
//| loop on top, with fallback to the next candidate) and the SL       |
//| Price/SL Profit preview columns. Deliberately does NOT validate     |
//| broker min-distance/side-of-market here - callers do that           |
//| themselves. Returns the candidate count (0-2); out_price[]/         |
//| out_is_trail[] sized to match.                                      |
//+------------------------------------------------------------------+
int CTradingEngine::BuildSLCandidates(const string symbol, const ENUM_POSITION_TYPE type, const bool sl_active, const bool trail_active, double &out_price[], bool &out_is_trail[])
 {
  ::ArrayResize(out_price, 0);
  ::ArrayResize(out_is_trail, 0);
  double sl_candidate    = sl_active    ? GetStopLostTargetPrice(symbol, type) : EMPTY_VALUE;
  double trail_candidate = trail_active ? GetTrailingTargetPrice(symbol, type) : EMPTY_VALUE;
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
  if(m_trading_setup_manager == NULL) return EMPTY_VALUE;
  CTradingSetupSetting *row_setting = m_trading_setup_manager.FindByIdentity(symbol);
  if(row_setting == NULL) return EMPTY_VALUE;
  bool sl_active    = row_setting.StopLostActive();
  bool trail_active = row_setting.TrailingActive();
  if(!sl_active && !trail_active) return EMPTY_VALUE;
  CSymbol *sym = m_symbol_collection.GetSymbolObjByName(symbol);
  if(sym == NULL) return EMPTY_VALUE;
  double point = sym.Point();
  if(point <= 0) return EMPTY_VALUE;

  double cand_price[]; bool cand_is_trail[];
  int cand_n = BuildSLCandidates(symbol, type, sl_active, trail_active, cand_price, cand_is_trail);
  double bid = sym.Bid(), ask = sym.Ask(), min_dist = sym.TradeStopLevel()*point;
  for(int c = 0; c < cand_n; c++)
   {
    double cprice = cand_price[c];
    bool valid_dist = (type == POSITION_TYPE_BUY) ? (bid - cprice >= min_dist) : (cprice - ask >= min_dist);
    if(!valid_dist) continue;
    out_from_trail = cand_is_trail[c];
    return cprice;
   }
  return EMPTY_VALUE;
 }
//+------------------------------------------------------------------+
//| Money value of GetPreviewSLTargetPrice() - distance from the       |
//| CURRENT Bid/Ask to the previewed target, same LotsMin-based         |
//| convention as GetStopLostMoneyValue/GetTrailingMoneyValue.          |
//+------------------------------------------------------------------+
double CTradingEngine::GetPreviewSLMoneyValue(const string symbol, const ENUM_POSITION_TYPE type)
 {
  bool from_trail;
  double target = GetPreviewSLTargetPrice(symbol, type, from_trail);
  if(target == EMPTY_VALUE) return EMPTY_VALUE;
  CSymbol *sym = m_symbol_collection.GetSymbolObjByName(symbol);
  if(sym == NULL) return EMPTY_VALUE;
  double point = sym.Point();
  if(point <= 0) return EMPTY_VALUE;
  double cur_price = (type == POSITION_TYPE_BUY) ? sym.Bid() : sym.Ask();
  double dist_pts = ::MathAbs(cur_price - target) / point;
  return dist_pts * sym.TradeTickValue() * sym.LotsMin();
 }
//+------------------------------------------------------------------+
//| Apply engine - runs every tick (CTradingEngine::OnTickEvent,       |
//| unconditional). Per open position: builds StopLost/Trailing         |
//| candidates from whichever is Active, picks the more favorable one   |
//| (best-of), gates on "never worse than current SL" (+Trailing's own  |
//| Step when Trailing's candidate wins - Start gates whether Trailing  |
//| proposes a candidate at all), then a broker min-distance check,     |
//| then really modifies the position via CSymbol's own CTradeObj       |
//| (Trading\TradeObj.mqh). A Position with no SL yet always bootstraps |
//| from StopLost, never Trailing (Anhnt, 2026-09-09 - "việc đầu tiên   |
//| phải modify SL của Position chưa có gì thành StopLost theo ATR,     |
//| sau đó mới Trailing" - Trailing's job is to IMPROVE an existing     |
//| stop, not plant the first one).                                     |
//| Deliberately NOT CTradingControl::ModifyPosition - that higher-     |
//| level call resolves the ticket through CTrading::GetSymbolObjByPosition,|
//| which looks the position up in the Library's OWN internal m_market  |
//| collection (Trading.mqh ~1750), not a live PositionSelectByTicket() |
//| - a position opened OUTSIDE this EA (e.g. Mobile app) isn't          |
//| guaranteed to be in that internal collection, so it silently         |
//| no-op'd for exactly that case. CTradeObj::ModifyPosition(ticket,...)|
//| reads the position live via the ticket directly, so it works        |
//| regardless of where the position was opened. Sound is played        |
//| manually here via PlaySoundSuccess (public API - PlaySoundModifySL  |
//| itself is private).                                                  |
//+------------------------------------------------------------------+
void CTradingEngine::ApplyStopLostAndTrailing(void)
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

    //--- Bootstrap rule - Trailing's job is to IMPROVE an existing stop, not to plant the very
    //--- first one - a position with no SL yet must get its baseline protection from StopLost
    //--- first, even on the rare tick where a Trailing candidate happens to already be valid and
    //--- would otherwise win the best-of compare below. Once current_sl is non-zero (this
    //--- bootstrap has happened), Trailing is free to compete normally next tick.
     double current_sl  = ::PositionGetDouble(POSITION_SL);
     bool   is_bootstrap = (current_sl == 0.0);

    //--- Start gate (Trishkin's CheckCriterion) - Trailing only proposes a candidate once profit
    //--- exceeds TrailingStartPts; 0 = no threshold (always propose). Position-specific (needs
    //--- THIS ticket's own open price), so resolved here before calling the shared candidate
    //--- builder below - not inside it, which is also used by the Symbol+Direction-level preview
    //--- that has no single position to anchor on.
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
     //--- Bootstrap + StopLost Active overrides Trailing eligibility for this tick only.
      if(is_bootstrap && sl_active)
         effective_trail_active = false;

    //--- Build both candidates (StopLost/Trailing) when Active, best-first order - shared with the
    //--- SL Price/SL Profit preview columns.
     double cand_price[]; bool cand_is_trail[];
     int cand_n = BuildSLCandidates(symbol, type, sl_active, effective_trail_active, cand_price, cand_is_trail);
     double sl_candidate    = (cand_n > 0 && !cand_is_trail[0]) ? cand_price[0] : ((cand_n > 1 && !cand_is_trail[1]) ? cand_price[1] : EMPTY_VALUE);
     double trail_candidate = (cand_n > 0 &&  cand_is_trail[0]) ? cand_price[0] : ((cand_n > 1 &&  cand_is_trail[1]) ? cand_price[1] : EMPTY_VALUE);

    //--- Never-worse-than-current gate, +Trailing's own Step (minimum improvement) when the
    //--- candidate under test is Trailing's - WITH FALLBACK to the next candidate if the more
    //--- favorable one fails validation (e.g. a wrong-side Trailing candidate - PSAR still on the
    //--- Buy side while this position is a Sell, per Trishkin's own documented flip edge case).
    //--- Broker min-distance check reuses CSymbol's own Bid/Ask/TradeStopLevel/Point, same
    //--- convention as ShowStopLostForm's own "Min Stop Lot" calc.
     double bid = sym.Bid(), ask = sym.Ask(), min_dist = sym.TradeStopLevel()*point;
     double best = EMPTY_VALUE, norm_best = EMPTY_VALUE;
     bool   best_from_trail = false, improves = false, valid_dist = false, did_modify = false;
     for(int c = 0; c < cand_n; c++)
      {
       double cprice = cand_price[c];
       bool   ctrail = cand_is_trail[c];
       double c_improve_dist = (type == POSITION_TYPE_BUY) ? (cprice - current_sl) : (current_sl - cprice);
       double c_min_improve  = ctrail ? row_setting.TrailingStepPts()*point : 0.0;
       bool   c_improves = (current_sl == 0.0) || (c_improve_dist > c_min_improve);
       if(!c_improves) continue;
       bool c_valid_dist = (type == POSITION_TYPE_BUY) ? (bid - cprice >= min_dist) : (cprice - ask >= min_dist);
       if(!c_valid_dist) continue;
       double c_norm = ::NormalizeDouble(cprice, sym.Digits());
       if(c_norm == current_sl) continue; // rounding collapsed to no real change
       best = cprice; norm_best = c_norm; best_from_trail = ctrail; improves = true; valid_dist = true;
       CTradeObj *trade_obj = sym.GetTradeObj();
       if(trade_obj != NULL)
        {
         //Print Debug - current SL right before this candidate gets applied, tagged by whether the
         //winning candidate came from Trailing or StopLost. Separate small file so it's easy to
         //grep independently of the big per-tick dump below.
          {
           string dbg2_fname = "CTradingEngine_Debug_ApplyStopLostAndTrailing_PreApplySL.log";
           string dbg2_path  = (g_ea_folder != "") ? (g_ea_folder + "/" + dbg2_fname) : dbg2_fname;
           int dbg2_fh = ::FileOpen(dbg2_path, FILE_READ|FILE_WRITE|FILE_TXT|FILE_ANSI);
           if(dbg2_fh != INVALID_HANDLE)
            {
             if(::FileSize(dbg2_fh) != 0) ::FileSeek(dbg2_fh, 0, SEEK_END);
             ::FileWrite(dbg2_fh, "MY DEBUG    CTradingEngine::ApplyStopLostAndTrailing ticket=", ticket, " sym=", symbol,
                         " source=", (ctrail ? "Trailing" : "StopLost"), " current_SL_before_apply=", current_sl,
                         " target_price=", c_norm);
             ::FileClose(dbg2_fh);
            }
          }
         did_modify = trade_obj.ModifyPosition(ticket, c_norm);
         //--- ModifyPosition only SENDS the request - it never plays a sound itself. PlaySoundModifySL
         //--- itself is PRIVATE - PlaySoundSuccess(ACTION_TYPE_MODIFY,...) is the public entry point
         //--- that dispatches to it (same convention CTrading's own ModifyPosition uses, Trading.mqh
         //--- :2889); reads SetSoundModifySL/UseSoundModifySL's own per-ORDER_TYPE settings + the
         //--- global SetUseSound flag (ApplyTrailingSoundToAllSymbols, GUIPannel_SettingWindows_
         //--- Alert_Sound.mqh - sets both).
         if(did_modify && trade_obj.IsUseSound())
          {
           ENUM_ORDER_TYPE order_action = (type == POSITION_TYPE_BUY) ? ORDER_TYPE_BUY : ORDER_TYPE_SELL;
           trade_obj.PlaySoundSuccess(ACTION_TYPE_MODIFY, (int)order_action, true, false, false);
          }
        }
       break; // first candidate that clears both gates wins - no need to try the other
      }

    //Print Debug - temporary, delete once Apply engine confirmed working
     {
      string dbg_fname = "CTradingEngine_Debug_ApplyStopLostAndTrailing.log";
      string dbg_path  = (g_ea_folder != "") ? (g_ea_folder + "/" + dbg_fname) : dbg_fname;
      int dbg_fh = ::FileOpen(dbg_path, FILE_READ|FILE_WRITE|FILE_TXT|FILE_ANSI);
      if(dbg_fh != INVALID_HANDLE)
       {
        if(::FileSize(dbg_fh) != 0) ::FileSeek(dbg_fh, 0, SEEK_END);
        ::FileWrite(dbg_fh, "MY DEBUG    CTradingEngine::ApplyStopLostAndTrailing ticket=", ticket, " sym=", symbol,
                    " type=", EnumToString(type), " sl_active=", sl_active, " trail_active=", trail_active,
                    " is_bootstrap=", is_bootstrap, " effective_trail_active=", effective_trail_active,
                    " sl_cand=", sl_candidate, " trail_cand=", trail_candidate, " cand_n=", cand_n,
                    " best=", best, " best_from_trail=", best_from_trail, " current_sl=", current_sl,
                    " improves=", improves, " valid_dist=", valid_dist, " norm_best=", norm_best,
                    " did_modify=", did_modify, " last_err=", ::GetLastError());
        ::FileClose(dbg_fh);
       }
     }
   }
 }
//+------------------------------------------------------------------+
//| Distinct (Symbol,Direction) pairs currently holding at least one  |
//| open Position - row identity source for m_table_positions_        |
//| StoplostAndTrailling. Order is whatever PositionsTotal() iteration |
//| order happens to be; the table itself has IsSortMode(false) so     |
//| this order is what displays.                                       |
//+------------------------------------------------------------------+
int CTradingEngine::GetPositionsSymbolsAndDirections(string &symbols[], ENUM_POSITION_TYPE &dirs[])
 {
  ::ArrayResize(symbols, 0);
  ::ArrayResize(dirs, 0);
  int total = ::PositionsTotal();
  for(int i = 0; i < total; i++)
   {
    string sym = ::PositionGetSymbol(i);
    if(sym == "") continue;
    ENUM_POSITION_TYPE type = (ENUM_POSITION_TYPE)::PositionGetInteger(POSITION_TYPE);
    bool already = false;
    for(int j = 0; j < ::ArraySize(symbols); j++)
      if(symbols[j] == sym && dirs[j] == type) { already = true; break; }
    if(already) continue;
    int n = ::ArraySize(symbols);
    ::ArrayResize(symbols, n + 1);
    ::ArrayResize(dirs, n + 1);
    symbols[n] = sym;
    dirs[n]    = type;
   }
  return ::ArraySize(symbols);
 }
//+------------------------------------------------------------------+
//| Check a new trade on history                                     |
//+------------------------------------------------------------------+
bool CTradingEngine::IsLastDealTicket(void)
 {
  //--- Exit if the history is not received
   if(!::HistorySelect(m_last_deal_time, UINT_MAX))
     return(false);
  //--- Get the number of deals in the obtained list
   int total_deals = ::HistoryDealsTotal();
  //--- Loop through the total number of deals in the obtained list from the
  // last deal to the first one
   for(int i = total_deals - 1; i >= 0; i--)
    {
     //--- Get the deal ticket
      ulong deal_ticket = ::HistoryDealGetTicket(i);
     //--- Exit if the tickets are equal
      if(deal_ticket == m_last_deal_ticket)
        return(false);
     //--- If the tickets are not equal, report it
      else
       {
        datetime deal_time = (datetime)::HistoryDealGetInteger(deal_ticket, DEAL_TIME);
        //--- Save the last deal time and ticket
         m_last_deal_time = deal_time;
         m_last_deal_ticket = deal_ticket;
         return(true);
       }
    }
  return(false);
 }
//+------------------------------------------------------------------+
//| Number of position trades with a specified symbol                |
//+------------------------------------------------------------------+
int CTradingEngine::PositionsTotal(const string symbol, const ENUM_POSITION_TYPE type = WRONG_VALUE)
 {
  //--- Position counter
   int pos_counter = 0;
  //--- Check if there is a position with specified properties
   int positions_total = ::PositionsTotal();
   for(int i = positions_total - 1; i >= 0; i--)
    {
     //--- If failed to select a position, go to the next one
      if(symbol != ::PositionGetSymbol(i))
         continue;
     //--- If the type should be selected
      if(type != WRONG_VALUE)
       {
        if(type != (ENUM_POSITION_TYPE)::PositionGetInteger(POSITION_TYPE))
           continue;
       }
     //--- Increase the counter
      pos_counter++;
    }
   //--- Return the number of positions
   return(pos_counter);
 }
//+------------------------------------------------------------------+
//| Total volume of positions with the specified properties          |
//+------------------------------------------------------------------+
double CTradingEngine::PositionsVolumeTotal(const string symbol, const ENUM_POSITION_TYPE type = WRONG_VALUE)
 {
  //--- Volume counter
   double volume_counter = 0;
  //--- Check if there is a position with specified properties
   int positions_total = ::PositionsTotal();
   for(int i = positions_total - 1; i >= 0; i--)
    {
     //--- If failed to select a position, go to the next one
      if(symbol != ::PositionGetSymbol(i))
         continue;
     //--- If the type should be selected
      if(type != WRONG_VALUE)
       {
        //--- If the type does not match, go to the next position
         if(type != (ENUM_POSITION_TYPE)::PositionGetInteger(POSITION_TYPE))
            continue;
       }
     //--- Sum up the volume
     volume_counter += ::PositionGetDouble(POSITION_VOLUME);
    }
   //--- Return the volume
   return(volume_counter);
 }
//+------------------------------------------------------------------+
//| Total floating profit of positions with the specified properties |
//+------------------------------------------------------------------+
double CTradingEngine::PositionsFloatingProfitTotal(const string symbol, const ENUM_POSITION_TYPE type = WRONG_VALUE)
 {
  //--- Current profit counter
   double profit_counter = 0.0;
  //--- Check if there is a position with specified properties
   int positions_total = ::PositionsTotal();
   for(int i = positions_total - 1; i >= 0; i--)
    {
     //--- If failed to select a position, go to the next one
      if(symbol != "" && symbol != ::PositionGetSymbol(i))
         continue;
     //--- If the type should be selected
      if(type != WRONG_VALUE)
       {
       //--- If the type does not match, go to the next position
        if(type != (ENUM_POSITION_TYPE)::PositionGetInteger(POSITION_TYPE))
           continue;
       }
     //--- Sum up the current profit + accumulated swap
     profit_counter += ::PositionGetDouble(POSITION_PROFIT) + ::PositionGetDouble(POSITION_SWAP);
    }
   //--- Return the result
     return(profit_counter);
 }
//+------------------------------------------------------------------+
//| Every (TF, ATR period) combination currently tracked for the      |
//| given Symbol - one entry per (Symbol,TF) row in m_symbol_tf_manager|
//| whose configured Indicator Template includes an ATR instance.     |
//| Moved from CGUIPannel (Anhnt/Claude, 2026-09-09 - pure data, no    |
//| GUI control touched); SyncComboBox_ATRChoice/GetSelectedATRChoice  |
//| (GUIPannel_SettingWindows_TradingStopLost.mqh) call through        |
//| m_tradingEngine now.                                               |
//+------------------------------------------------------------------+
int CTradingEngine::BuildATRChoiceList(const string symbol, ENUM_TIMEFRAMES &out_tf[], int &out_period[])
 {
  int n = 0;
  ::ArrayResize(out_tf,     0);
  ::ArrayResize(out_period, 0);
  if(m_indicator_template_manager == NULL || m_symbol_tf_manager == NULL) return 0;
  int templates_total = m_indicator_template_manager.Total();
  for(int t = 0; t < templates_total; t++)
   {
    CIndicatorSetting *tpl = m_indicator_template_manager.At(t);
    if(tpl == NULL || tpl.TypeEnum() != IND_ATR) continue;
    MqlParam raw[];
    tpl.GetRawParams(raw);
    int period = (int)raw[0].integer_value;
    int tf_total = m_symbol_tf_manager.Total();
    for(int s = 0; s < tf_total; s++)
     {
      CSymbolTFSetting *row = m_symbol_tf_manager.At(s);
      if(row == NULL || row.Symbol() != symbol) continue;
      ::ArrayResize(out_tf,     n + 1);
      ::ArrayResize(out_period, n + 1);
      out_tf[n]     = row.TFEnum();
      out_period[n] = period;
      n++;
     }
   }
  return n;
 }
//+------------------------------------------------------------------+
//| Pushes the Trailing sound into every tracked Symbol's own CTradeObj|
//| (Trading\TradeObj.mqh) via SetSoundModifySL/UseSoundModifySL, so   |
//| real ModifyPosition calls (ApplyStopLostAndTrailing above) actually|
//| play it. Moved from CGUIPannel (Anhnt/Claude, 2026-09-09 - pure    |
//| trading-domain logic, no GUI control touched); called from BOTH    |
//| GUIPannel_SettingWindows_Alert_Sound.mqh's SaveSoundSettingsToJSON |
//| (after a Save click) AND CreateTab_SettingConfig_Sound (right      |
//| after loading the saved default) through m_tradingEngine now.      |
//+------------------------------------------------------------------+
void CTradingEngine::ApplyTrailingSoundToAllSymbols(const string trailing_sound)
 {
  if(trailing_sound == "") return;
  CArrayObj *col_list = m_symbol_collection.GetList();
  int count = (col_list != NULL) ? col_list.Total() : 0;
  for(int i = 0; i < count; i++)
   {
    CSymbol *sym = col_list.At(i);
    if(sym == NULL) continue;
    CTradeObj *trade_obj = sym.GetTradeObj();
    if(trade_obj == NULL) continue;
    //--- PlaySoundSuccess (called from ApplyStopLostAndTrailing above) bails out immediately unless
    //--- this GLOBAL flag is set too - the per-action UseSoundModifySL flags alone aren't enough
    //--- (Anhnt/Claude, 2026-09-08 - confirmed by reading TradeObj.mqh/BaseObj.mqh).
     trade_obj.SetUseSound(true);
    trade_obj.SetSoundModifySL(ORDER_TYPE_BUY,  trailing_sound);
    trade_obj.SetSoundModifySL(ORDER_TYPE_SELL, trailing_sound);
    trade_obj.UseSoundModifySL(ORDER_TYPE_BUY,  true);
    trade_obj.UseSoundModifySL(ORDER_TYPE_SELL, true);
   }
 }
//+------------------------------------------------------------------+
//| Money value of GetCurrentStopLostDistancePoints() - same LotsMin- |
//| based preview convention as GetTrailingMoneyValue. Moved from      |
//| CGUIPannel (Anhnt/Claude, 2026-09-09 - pure math, no GUI control    |
//| touched).                                                           |
//+------------------------------------------------------------------+
double CTradingEngine::GetStopLostMoneyValue(const string symbol, const ENUM_STOPLOST_TRAILING_MODE mode_override = WRONG_VALUE)
 {
  int distance_pts = GetCurrentStopLostDistancePoints(symbol, mode_override);
  if(distance_pts < 0) return EMPTY_VALUE;
  CSymbol *sym = m_symbol_collection.GetSymbolObjByName(symbol);
  if(sym == NULL) return EMPTY_VALUE;
  return distance_pts * sym.TradeTickValue() * sym.LotsMin();
 }
//+------------------------------------------------------------------+
//| Formats GetCurrentStopLostDistancePoints() as "<n> pts" (or "-").  |
//| Moved from CGUIPannel (Anhnt/Claude, 2026-09-09 - pure string      |
//| format, no GUI control touched). Currently has no real caller      |
//| anywhere in the EA - kept as-is, not deleted.                      |
//+------------------------------------------------------------------+
string CTradingEngine::FormatStopLostCacheValue(const string symbol)
 {
  int distance_pts = GetCurrentStopLostDistancePoints(symbol);
  if(distance_pts < 0) return "-";
  return (string)distance_pts + " pts";
 }
//+------------------------------------------------------------------+
//| Distance (points) from current Mid to the Trailing target price - |
//| mirrors GetCurrentStopLostDistancePoints's own signature, but uses |
//| Trishkin's Trailing formulas instead of StopLost's Fixed-multiplier|
//| /ATR ones:                                                          |
//|  Fixed (CTrailingByValue::GetStopLossValue = CurrentPrice ∓ Offset)|
//|   -> distance IS the Offset itself.                                |
//|  Indicator (CTrailingByInd::GetStopLossValue = IndValue ∓ Offset)  |
//|   -> distance = |Mid - IndValue|/Point() + Offset. Moved from       |
//|   CGUIPannel (Anhnt/Claude, 2026-09-09 - pure math, no GUI control  |
//|   touched).                                                         |
//+------------------------------------------------------------------+
int CTradingEngine::GetCurrentTrailingDistancePoints(const string symbol, const ENUM_STOPLOST_TRAILING_MODE mode_override = WRONG_VALUE)
 {
  if(m_trading_setup_manager == NULL) return -1;
  CTradingSetupSetting *row_setting = m_trading_setup_manager.FindByIdentity(symbol);
  if(row_setting == NULL) return -1;
  ENUM_STOPLOST_TRAILING_MODE mode = (mode_override == WRONG_VALUE) ? row_setting.TrailingMode() : mode_override;
  int offset_pts = row_setting.TrailingOffsetPts();
  if(mode == SL_MODE_FIXED) return offset_pts;
  double ind_value;
  if(!GetCurrentTrailingIndicatorValue(symbol, ind_value)) return -1;
  CSymbol *sym = m_symbol_collection.GetSymbolObjByName(symbol);
  double bid   = (sym != NULL) ? sym.Bid()   : ::SymbolInfoDouble(symbol, SYMBOL_BID);
  double ask   = (sym != NULL) ? sym.Ask()   : ::SymbolInfoDouble(symbol, SYMBOL_ASK);
  double point = (sym != NULL) ? sym.Point() : ::SymbolInfoDouble(symbol, SYMBOL_POINT);
  if(point <= 0) return -1;
  double mid = (bid + ask) / 2.0;
  return (int)::MathRound(::MathAbs(mid - ind_value) / point) + offset_pts;
 }
//+------------------------------------------------------------------+
//| Money value of GetCurrentTrailingDistancePoints() - same LotsMin- |
//| based preview convention as GetStopLostMoneyValue. Moved from      |
//| CGUIPannel (Anhnt/Claude, 2026-09-09 - pure math, no GUI control    |
//| touched).                                                           |
//+------------------------------------------------------------------+
double CTradingEngine::GetTrailingMoneyValue(const string symbol, const ENUM_STOPLOST_TRAILING_MODE mode_override = WRONG_VALUE)
 {
  int distance_pts = GetCurrentTrailingDistancePoints(symbol, mode_override);
  if(distance_pts < 0) return EMPTY_VALUE;
  CSymbol *sym = m_symbol_collection.GetSymbolObjByName(symbol);
  if(sym == NULL) return EMPTY_VALUE;
  return distance_pts * sym.TradeTickValue() * sym.LotsMin();
 }
#endif // CTRADINGENGINE_MULTIMODULE_MQH
