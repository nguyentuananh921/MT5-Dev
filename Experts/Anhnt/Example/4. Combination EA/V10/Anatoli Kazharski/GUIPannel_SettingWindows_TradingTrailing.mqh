//+------------------------------------------------------------------+
//|                       GUIPannel_SettingWindows_TradingTrailing.mqh |
//| Module for Setting Trailing                                        |
//+------------------------------------------------------------------+
#ifndef CGUIPANNEL_SETTINGWINDOWS_TRADINGTRAILING_MQH_IMPLEMENTATION
#define CGUIPANNEL_SETTINGWINDOWS_TRADINGTRAILING_MQH_IMPLEMENTATION
 #include "GUIPannel.mqh"
 //+------------------------------------------------------------------+
 //| Same layout as CreateTable_StopLostSetting (GUIPannel_SettingWindows_TradingStopLost.mqh) -
 //| col: Symbol | Price | [Spread] | [gear->Trailling icon] | [Fixed]Point | [Indicator]Point |
 //| [Fixed]Value | [Indicator]Value. Only difference from the StopLost table: col3's icon.
 //+------------------------------------------------------------------+
 bool CGUIPannel::CreateTable_TrailingSetting(const int x, const int y)
  {
    #define COLUMNS_TRAIL_TOTAL 8
    m_table_trailingsetting.MainPointer(m_tabs_setting_trading);
    m_tabs_setting_trading.AddToElementsArray(ENUM_TAB_SETTING_TRADING_TRAILLING,m_table_trailingsetting);
    int width[COLUMNS_TRAIL_TOTAL]           = {M_SYMBOL_WIDTH, 70, 35, 25, 60, 60, 70, 70};
    ENUM_ALIGN_MODE align[COLUMNS_TRAIL_TOTAL] = {ALIGN_LEFT, ALIGN_RIGHT, ALIGN_RIGHT, ALIGN_LEFT, ALIGN_RIGHT, ALIGN_RIGHT, ALIGN_RIGHT, ALIGN_RIGHT};
    int text_x_offset[COLUMNS_TRAIL_TOTAL]   = {22, 5, 5, 5, 5, 5, 5, 5}; // col0: clear the Symbol active-chart icon
    int image_x_offset[COLUMNS_TRAIL_TOTAL]  = { 3, 3, 3, 5, 3, 3, 3, 3};
    int image_y_offset[COLUMNS_TRAIL_TOTAL]  = { 3, 3, 3, 3, 3, 3, 3, 3};
     m_table_trailingsetting.YSize(POSITIONS_TABLE_Y - M_CONTROL_BORDER_GAP - 5);
   //--- XSize = sum of width[] + room for the vertical scrollbar
    int columns_width_total = 0;
    for(int c = 0; c < COLUMNS_TRAIL_TOTAL; c++)
       columns_width_total += width[c];
    m_table_trailingsetting.XSize(columns_width_total + 20); //20 For scroll
    m_table_trailingsetting.TableSize(COLUMNS_TRAIL_TOTAL, 20);
    m_table_trailingsetting.ColumnsWidth(width);
    m_table_trailingsetting.TextAlign(align);
    m_table_trailingsetting.TextXOffset(text_x_offset);
    m_table_trailingsetting.ImageXOffset(image_x_offset);
    m_table_trailingsetting.ImageYOffset(image_y_offset);
    m_table_trailingsetting.ShowHeaders(true);
    m_table_trailingsetting.SelectableRow(true);
    m_table_trailingsetting.LightsHover(true);
    m_table_trailingsetting.IsSortMode(true);
    if(!m_table_trailingsetting.CreateTable(x, y)) return false;
    m_table_trailingsetting.SetHeaderText(0, "Symbol");
    m_table_trailingsetting.SetHeaderText(1, "Price");
    uint spread_header_img[] = {IMAGE_RESOURCE_BMP16_SPREADRED_PNG};
    m_table_trailingsetting.SetHeaderText(2, "");
    m_table_trailingsetting.SetHeaderImage(2, spread_header_img);
    uint trailling_header_img[] = {IMAGE_RESOURCE_BMP16_TRAILLING_PNG};
    m_table_trailingsetting.SetHeaderText(3, "");
    m_table_trailingsetting.SetHeaderImage(3, trailling_header_img);
    uint fixed_img[] = {IMAGE_RESOURCE_BMP16_STOP_LOST_FIXED_PNG};
    uint ind_img[]   = {IMAGE_RESOURCE_BMP16_INDICATOR_BMP};
    m_table_trailingsetting.SetHeaderText(4, "");
    m_table_trailingsetting.SetHeaderImage(4, fixed_img);
    m_table_trailingsetting.SetHeaderText(5, "");
    m_table_trailingsetting.SetHeaderImage(5, ind_img);
    m_table_trailingsetting.SetHeaderText(6, "");
    m_table_trailingsetting.SetHeaderImage(6, fixed_img);
    m_table_trailingsetting.SetHeaderText(7, "");
    m_table_trailingsetting.SetHeaderImage(7, ind_img);
    CWndContainer::AddToElementsArray(WindowIdx(m_window_setting_trading),m_table_trailingsetting);
    return true;
  }
 //+------------------------------------------------------------------+
 //| Same idea as m_table_indicator_SymbolTFMonitor (GUIPannel_MainWindows_TabMonitor.mqh) but
 //| scoped to ONE Symbol (no Symbol column) and no Buy/Sell columns - just TF | Indicator | Value |
 //| Trailing(checkbox). Checking a row picks that Indicator as the Symbol's Trailing-by-Indicator
 //| source (see project_v10_stoplost_trailing_apply_design.md memory for the StopLost equivalent -
 //| Trailing's own Sync/checkbox-commit logic is still to be written).
 //+------------------------------------------------------------------+
 bool CGUIPannel::CreateTable_IndicatorsTrailingSetting(const int x, const int y)
  {
    #define COLUMNS_IND_TRAIL_TOTAL 4
   //--- Symbol label above the table - which Symbol's tracked Indicators are currently listed
   //--- (set on m_table_trailingsetting's own Symbol/Trailling-icon click, see
   //--- OnEvent_Window_SettingTrading in GUIPannel_SettingWindows_Trading.mqh).
    m_label_TrailingSetting_Symbol.MainPointer(m_tabs_setting_trading);
    m_tabs_setting_trading.AddToElementsArray(ENUM_TAB_SETTING_TRADING_TRAILLING,m_label_TrailingSetting_Symbol);
    m_label_TrailingSetting_Symbol.XSize(160);
    m_label_TrailingSetting_Symbol.YSize(M_CONTROL_HEIGHT);
    if(!m_label_TrailingSetting_Symbol.CreateTextLabel("Symbol - -", x, y)) return false;
    CWndContainer::AddToElementsArray(WindowIdx(m_window_setting_trading),m_label_TrailingSetting_Symbol);
    int table_y = y + M_CONTROL_YDISTANCE;

    m_table_indicators_trailingsetting.MainPointer(m_tabs_setting_trading);
    m_tabs_setting_trading.AddToElementsArray(ENUM_TAB_SETTING_TRADING_TRAILLING,m_table_indicators_trailingsetting);
    // col: [active-chart icon]TF | Indicator(no icon, plain text) | Value | Trailing(icon-only header, checkbox)
    int width[COLUMNS_IND_TRAIL_TOTAL]           = {M_TF_WIDTH, INDICATOR_PARATEXT_WIDTH - 17, INDICATOR_VALUE_WIDTH, 30};
    ENUM_ALIGN_MODE align[COLUMNS_IND_TRAIL_TOTAL] = {ALIGN_LEFT, ALIGN_LEFT, ALIGN_RIGHT, ALIGN_LEFT};
    int text_x_offset[COLUMNS_IND_TRAIL_TOTAL]   = {22, 5, 5, 5}; // col0: clear the active-chart-TF icon; col1: no icon drawn here, no reserved gap
    int image_x_offset[COLUMNS_IND_TRAIL_TOTAL]  = {3, 0, 0, 10};
    int image_y_offset[COLUMNS_IND_TRAIL_TOTAL]  = {3, 3, 0, 3};
    m_table_indicators_trailingsetting.YSize(POSITIONS_TABLE_Y - M_CONTROL_BORDER_GAP - 5 - M_CONTROL_YDISTANCE);
    int columns_width_total = 0;
    for(int c = 0; c < COLUMNS_IND_TRAIL_TOTAL; c++)
       columns_width_total += width[c];
    m_table_indicators_trailingsetting.XSize(columns_width_total + 20);
    m_table_indicators_trailingsetting.TableSize(COLUMNS_IND_TRAIL_TOTAL, 20);
    m_table_indicators_trailingsetting.ColumnsWidth(width);
    m_table_indicators_trailingsetting.TextAlign(align);
    m_table_indicators_trailingsetting.TextXOffset(text_x_offset);
    m_table_indicators_trailingsetting.ImageXOffset(image_x_offset);
    m_table_indicators_trailingsetting.ImageYOffset(image_y_offset);
    m_table_indicators_trailingsetting.ShowHeaders(true);
    m_table_indicators_trailingsetting.SelectableRow(true);
    m_table_indicators_trailingsetting.LightsHover(true);
    m_table_indicators_trailingsetting.IsSortMode(true);
    if(!m_table_indicators_trailingsetting.CreateTable(x, table_y)) return false;
    m_table_indicators_trailingsetting.SetHeaderText(0, "TF");
    m_table_indicators_trailingsetting.SetHeaderText(1, "Indicator");
    m_table_indicators_trailingsetting.SetHeaderText(2, "Value");
    //--- Icon-only header (no text) to save width, same convention as m_table_positions_
    //--- StoplostAndTrailling's own Trailling column (Anhnt/Claude, 2026-09-08).
     {
      uint trailling_col_img[] = {IMAGE_RESOURCE_BMP16_TRAILLING_PNG};
      m_table_indicators_trailingsetting.SetHeaderText(3, "");
      m_table_indicators_trailingsetting.SetHeaderImage(3, trailling_col_img);
     }
    CWndContainer::AddToElementsArray(WindowIdx(m_window_setting_trading),m_table_indicators_trailingsetting);
    return true;
  }
 //+------------------------------------------------------------------+
 //| Live refresh for m_table_trailingsetting - same structure as      |
 //| SyncTable_StopLostSetting (GUIPannel_SettingWindows_TradingStopLost.mqh), Col4-7 read the      |
 //| Trailing offset fields directly (they're already raw point counts - no Spread/ATR formula      |
 //| like StopLost's own Col4-7, nothing computes them yet since there's no numeric-entry form for   |
 //| Trailing here, only the Indicator-choice table below).                                          |
 //+------------------------------------------------------------------+
 bool CGUIPannel::SyncTable_TrailingSetting(bool force = false)
  {
   if(m_symbol_collection == NULL || m_trading_setup_manager == NULL) return false;
    CArrayObj *col_list = m_symbol_collection.GetList();
    int count = (col_list != NULL) ? col_list.Total() : 0;
    if(count == 0) return false;
    static int    table_row_count = 0;
    static double mid_price_old[];
    static int    spread_half_old[];
    static bool   active_old[];
    static int    fixed_pts_old[];
    static int    ind_pts_old[];
    static double fixed_val_old[];
    static double ind_val_old[];
   if(count != table_row_count)
    {
     uint sym_img[] = {IMAGE_RESOURCE_BMP16_BAR_CHART_BMP, IMAGE_RESOURCE_BMP16_BAR_CHART_COLORLESS_BMP};
     m_table_trailingsetting.DeleteAllRows();
     ::ArrayResize(mid_price_old,   count);
     ::ArrayResize(spread_half_old, count);
     ::ArrayResize(active_old,      count);
     ::ArrayResize(fixed_pts_old,   count);
     ::ArrayResize(ind_pts_old,     count);
     ::ArrayResize(fixed_val_old,   count);
     ::ArrayResize(ind_val_old,     count);
     ::ArrayInitialize(mid_price_old,   -1);
     ::ArrayInitialize(spread_half_old, -1);
     ::ArrayInitialize(active_old,      false);
     ::ArrayInitialize(fixed_pts_old,   -1);
     ::ArrayInitialize(ind_pts_old,     -1);
     ::ArrayInitialize(fixed_val_old,   EMPTY_VALUE);
     ::ArrayInitialize(ind_val_old,     EMPTY_VALUE);
     for(int i = 0; i < count - 1; i++)
        m_table_trailingsetting.AddRow(i, i == count - 2);
     for(int row = 0; row < count; row++)
      {
       CSymbol *sym = col_list.At(row);
       string sym_name = (sym != NULL) ? sym.Name() : "";
       bool active = (sym_name == ::Symbol());
       active_old[row] = active;
       m_table_trailingsetting.SetImages(0, row, sym_img);
       m_table_trailingsetting.ChangeImage(0, row, active ? 0 : 1);
       m_table_trailingsetting.SetValue(0, row, sym_name);

       double bid    = (sym != NULL) ? sym.Bid()   : ::SymbolInfoDouble(sym_name, SYMBOL_BID);
       double ask    = (sym != NULL) ? sym.Ask()    : ::SymbolInfoDouble(sym_name, SYMBOL_ASK);
       int    digits = (sym != NULL) ? sym.Digits() : (int)::SymbolInfoInteger(sym_name, SYMBOL_DIGITS);
       int    spread_half_pts = (sym != NULL) ? sym.Spread() / 2 : (int)::SymbolInfoInteger(sym_name, SYMBOL_SPREAD) / 2;
       double mid = (bid + ask) / 2.0;
       m_table_trailingsetting.SetValue(1, row, ::DoubleToString(mid, digits));
       mid_price_old[row] = mid;
       m_table_trailingsetting.SetValue(2, row, (string)spread_half_pts);
       spread_half_old[row] = spread_half_pts;

       uint trailling_gear_img[] = {IMAGE_RESOURCE_BMP16_TRAILLING_PNG};
       m_table_trailingsetting.SetImages(3, row, trailling_gear_img);
       m_table_trailingsetting.ChangeImage(3, row, 0);

       //--- Cols 4-7: Fixed (CTrailingByValue) and Indicator (CTrailingByInd) distances, via
       //--- GetCurrent_TrailingDistance_Points/GetTrailingMoneyValue (Anhnt/Claude, 2026-09-08 - same
       //--- Point/$ shape as StopLost's own cols 4-7, but Trishkin's Trailing formulas, not StopLost's).
       int    fixed_pts = m_tradingEngine.GetCurrent_TrailingDistance_Points(sym_name, SL_MODE_FIXED);
       int    ind_pts   = m_tradingEngine.GetCurrent_TrailingDistance_Points(sym_name, SL_MODE_INDICATOR);
       double fixed_val = m_tradingEngine.GetTrailingMoneyValue(sym_name, SL_MODE_FIXED);
       double ind_val   = m_tradingEngine.GetTrailingMoneyValue(sym_name, SL_MODE_INDICATOR);
       fixed_pts_old[row] = fixed_pts;
       ind_pts_old[row]   = ind_pts;
       fixed_val_old[row] = fixed_val;
       ind_val_old[row]   = ind_val;
       m_table_trailingsetting.SetValue(4, row, (fixed_pts < 0) ? "-" : (string)fixed_pts + " P");
       m_table_trailingsetting.SetValue(5, row, (ind_pts   < 0) ? "-" : (string)ind_pts + " P");
       m_table_trailingsetting.SetValue(6, row, (fixed_val == EMPTY_VALUE) ? "-" : "$" + ::DoubleToString(fixed_val, 2));
       m_table_trailingsetting.SetValue(7, row, (ind_val   == EMPTY_VALUE) ? "-" : "$" + ::DoubleToString(ind_val, 2));
      }
     table_row_count = count;
     m_table_trailingsetting.Update(true);
     return true;
    }
    bool any_changed = false;
    for(int i = 0; i < count; i++)
     {
      CSymbol *sym = col_list.At(i);
      string sym_name = (sym != NULL) ? sym.Name() : "";
      int row = -1;
      for(int r = 0; r < count; r++)
        if(m_table_trailingsetting.GetValue(0, r) == sym_name) { row = r; break; }
      if(row < 0) continue;
      bool active = (sym_name == ::Symbol());
      if(active != active_old[row])
       {
        active_old[row] = active;
        m_table_trailingsetting.ChangeImage(0, row, active ? 0 : 1, true);
        any_changed = true;
       }
      double bid    = (sym != NULL) ? sym.Bid()   : ::SymbolInfoDouble(sym_name, SYMBOL_BID);
      double ask    = (sym != NULL) ? sym.Ask()    : ::SymbolInfoDouble(sym_name, SYMBOL_ASK);
      int    digits = (sym != NULL) ? sym.Digits() : (int)::SymbolInfoInteger(sym_name, SYMBOL_DIGITS);
      int    spread_half_pts = (sym != NULL) ? sym.Spread() / 2 : (int)::SymbolInfoInteger(sym_name, SYMBOL_SPREAD) / 2;
      double mid = (bid + ask) / 2.0;
      double prev_mid = mid_price_old[row];
      if(force || mid != prev_mid)
       {
        int dir = (prev_mid < 0) ? 2 : (mid > prev_mid) ? 0 : (mid < prev_mid) ? 1 : 2;
        color txt_clr = (dir == 0) ? C'0,160,0' : (dir == 1) ? C'200,0,0' : clrGray;
        m_table_trailingsetting.SetValue(1, row, ::DoubleToString(mid, digits), 0, true);
        m_table_trailingsetting.TextColor(1, row, txt_clr, true);
        mid_price_old[row] = mid;
        any_changed = true;
       }
      int prev_spread = spread_half_old[row];
      if(force || spread_half_pts != prev_spread)
       {
        int dir = (prev_spread < 0) ? 2 : (spread_half_pts > prev_spread) ? 0 : (spread_half_pts < prev_spread) ? 1 : 2;
        color txt_clr = (dir == 0) ? C'0,160,0' : (dir == 1) ? C'200,0,0' : clrGray;
        m_table_trailingsetting.SetValue(2, row, (string)spread_half_pts, 0, true);
        m_table_trailingsetting.TextColor(2, row, txt_clr, true);
        spread_half_old[row] = spread_half_pts;
        any_changed = true;
       }
      int    fixed_pts = m_tradingEngine.GetCurrent_TrailingDistance_Points(sym_name, SL_MODE_FIXED);
      int    ind_pts   = m_tradingEngine.GetCurrent_TrailingDistance_Points(sym_name, SL_MODE_INDICATOR);
      double fixed_val = m_tradingEngine.GetTrailingMoneyValue(sym_name, SL_MODE_FIXED);
      double ind_val   = m_tradingEngine.GetTrailingMoneyValue(sym_name, SL_MODE_INDICATOR);
      if(force || fixed_pts != fixed_pts_old[row])
       {
        int dir = (fixed_pts_old[row] < 0 || fixed_pts < 0) ? 2 : (fixed_pts > fixed_pts_old[row]) ? 0 : (fixed_pts < fixed_pts_old[row]) ? 1 : 2;
        color clr = (dir == 0) ? C'0,160,0' : (dir == 1) ? C'200,0,0' : clrGray;
        fixed_pts_old[row] = fixed_pts;
        m_table_trailingsetting.SetValue(4, row, (fixed_pts < 0) ? "-" : (string)fixed_pts + " P", 0, true);
        m_table_trailingsetting.TextColor(4, row, clr, true);
        any_changed = true;
       }
      if(force || ind_pts != ind_pts_old[row])
       {
        int dir = (ind_pts_old[row] < 0 || ind_pts < 0) ? 2 : (ind_pts > ind_pts_old[row]) ? 0 : (ind_pts < ind_pts_old[row]) ? 1 : 2;
        color clr = (dir == 0) ? C'0,160,0' : (dir == 1) ? C'200,0,0' : clrGray;
        ind_pts_old[row] = ind_pts;
        m_table_trailingsetting.SetValue(5, row, (ind_pts < 0) ? "-" : (string)ind_pts + " P", 0, true);
        m_table_trailingsetting.TextColor(5, row, clr, true);
        any_changed = true;
       }
      if(force || fixed_val != fixed_val_old[row])
       {
        int dir = (fixed_val_old[row] == EMPTY_VALUE || fixed_val == EMPTY_VALUE) ? 2 : (fixed_val > fixed_val_old[row]) ? 0 : (fixed_val < fixed_val_old[row]) ? 1 : 2;
        color clr = (dir == 0) ? C'0,160,0' : (dir == 1) ? C'200,0,0' : clrGray;
        fixed_val_old[row] = fixed_val;
        m_table_trailingsetting.SetValue(6, row, (fixed_val == EMPTY_VALUE) ? "-" : "$" + ::DoubleToString(fixed_val, 2), 0, true);
        m_table_trailingsetting.TextColor(6, row, clr, true);
        any_changed = true;
       }
      if(force || ind_val != ind_val_old[row])
       {
        int dir = (ind_val_old[row] == EMPTY_VALUE || ind_val == EMPTY_VALUE) ? 2 : (ind_val > ind_val_old[row]) ? 0 : (ind_val < ind_val_old[row]) ? 1 : 2;
        color clr = (dir == 0) ? C'0,160,0' : (dir == 1) ? C'200,0,0' : clrGray;
        ind_val_old[row] = ind_val;
        m_table_trailingsetting.SetValue(7, row, (ind_val == EMPTY_VALUE) ? "-" : "$" + ::DoubleToString(ind_val, 2), 0, true);
        m_table_trailingsetting.TextColor(7, row, clr, true);
        any_changed = true;
       }
     }
   if(any_changed) m_table_trailingsetting.Update(false);
   return any_changed;
  }
 //+------------------------------------------------------------------+
 //| Candidate Trend/single-buffer indicators per tracked TF for this   |
 //| Symbol - pure data, no GUI control touched. GetCurrent_Trailing    |
 //| Indicator_AnchorPrice (CTradingEngine, real per-tick trailing      |
 //| lookup) no longer needs this - it looks up its ONE saved identity  |
 //| directly instead of scanning a whole choice list (Anhnt/Claude,    |
 //| 2026-09-15). So the only remaining consumers are the 2 GUI call    |
 //| sites below, which is why this lives on CGUIPannel now, using its  |
 //| own borrowed pointers, not CTradingEngine (see                     |
 //| [[project_v10_stoplost_trailing_engine_split]] for where it lived  |
 //| before).                                                            |
 //+------------------------------------------------------------------+
 int CGUIPannel::BuildTrailingIndicatorChoiceList(const string symbol, CIndicatorDE* &out_inds[], ENUM_TIMEFRAMES &out_tfs[])
  {
   int count = 0;
   ::ArrayResize(out_inds, 0);
   ::ArrayResize(out_tfs,  0);
   if(m_IndicatorsCollection == NULL || m_SymbolTFManager == NULL || m_indicator_template_manager == NULL) return 0;
   int symtf_total = m_SymbolTFManager.Total();
   int tmpl_total  = m_indicator_template_manager.Total();
   for(int si = 0; si < symtf_total; si++)
    {
     CSymbolTFSetting *symtf = m_SymbolTFManager.At(si);
     if(symtf == NULL || symtf.Symbol() != symbol) continue;
     ENUM_TIMEFRAMES tf = symtf.TFEnum();
     CArrayObj *ind_list = m_IndicatorsCollection.GetListIndBySymbol(symbol);
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
   //--- Sort ascending by TF (M1 first) - insertion order otherwise follows m_SymbolTFManager's own.
   for(int a = 0; a < count - 1; a++)
    for(int b = a + 1; b < count; b++)
     if(IndexEnumTimeframe(out_tfs[b]) < IndexEnumTimeframe(out_tfs[a]))
      {
       CIndicatorDE   *ind_tmp = out_inds[a]; out_inds[a] = out_inds[b]; out_inds[b] = ind_tmp;
       ENUM_TIMEFRAMES tf_tmp  = out_tfs[a];  out_tfs[a]  = out_tfs[b];  out_tfs[b]  = tf_tmp;
      }
   return count;
  } 
 //+------------------------------------------------------------------+
 //| Full rebuild when the scoped Symbol changes (icon click) or count  |
 //| changes, otherwise a per-tick dirty-check that only touches Col2's |
 //| Value text/color - same up/down/flat convention (green/red/gray)   |
 //| as SynTable_IndicatorSymbolTFMonitor's own Col4. Row identity is   |
 //| re-derived via the TF+Indicator-label composite key (post-sort     |
 //| safe), matching that same table's row_of[] pattern.                |
 //+------------------------------------------------------------------+
 bool CGUIPannel::SyncTable_IndicatorsTrailingSetting(const string symbol, bool force = false)
  {
   static string s_scoped_symbol = "";
   static int    s_row_count = 0;
   static double s_val_old[];
   static int    s_dir_old[];   // -1 unknown, 0 up(green) 1 down(red) 2 flat(gray)
   static bool   s_tf_active_old[];   // Col0 active-chart-TF icon state

   if(symbol != s_scoped_symbol) { s_scoped_symbol = symbol; force = true; }

   CIndicatorDE   *inds[];
   ENUM_TIMEFRAMES tfs[];
   int count = BuildTrailingIndicatorChoiceList(symbol, inds, tfs);

   if(force || count != s_row_count)
    {
     m_table_indicators_trailingsetting.DeleteAllRows();
     if(count == 0)
      {
       m_table_indicators_trailingsetting.AddRow(1);
       m_table_indicators_trailingsetting.DeleteRow(0, true);
       ::ArrayResize(s_val_old, 0);
       ::ArrayResize(s_dir_old, 0);
       ::ArrayResize(s_tf_active_old, 0);
       s_row_count = 0;
       m_table_indicators_trailingsetting.Update(true);
       return true;
      }
     ::ArrayResize(s_val_old, count);
     ::ArrayResize(s_dir_old, count);
     ::ArrayResize(s_tf_active_old, count);
     ::ArrayInitialize(s_val_old, EMPTY_VALUE);
     ::ArrayInitialize(s_dir_old, -1);
     ::ArrayInitialize(s_tf_active_old, false);
     uint tf_img[] = {IMAGE_RESOURCE_BMP16_BAR_CHART_BMP, IMAGE_RESOURCE_BMP16_BAR_CHART_COLORLESS_BMP};
     CTradingSetupSetting *row_setting = (m_trading_setup_manager != NULL) ? m_trading_setup_manager.FindByIdentity(symbol) : NULL;
     MqlParam saved_params[];
     if(row_setting != NULL) row_setting.GetTrailingIndParams(saved_params);
     uint chk[] = {IMAGE_RESOURCE_BMP16_CHECKBOX_ON_G_PNG, IMAGE_RESOURCE_BMP16_CHECKBOX_OFF_G_PNG};
     for(int i = 0; i < count - 1; i++)
        m_table_indicators_trailingsetting.AddRow(i, i == count - 2);
     for(int row = 0; row < count; row++)
      {
       CIndicatorDE *ind = inds[row];
       bool tf_active = (tfs[row] == (ENUM_TIMEFRAMES)::Period());
       s_tf_active_old[row] = tf_active;
       m_table_indicators_trailingsetting.SetImages(0, row, tf_img);
       m_table_indicators_trailingsetting.ChangeImage(0, row, tf_active ? 0 : 1);
       m_table_indicators_trailingsetting.SetValue(0, row, TimeframeDescription(tfs[row]));
       MqlParam ind_params[];
       ind.GetMqlParams(ind_params);
       CIndicatorSetting ind_label_setting;
       ind_label_setting.TypeEnum(ind.TypeIndicator());
       ind_label_setting.SetRawParams(ind_params);
       m_table_indicators_trailingsetting.SetValue(1, row, ind_label_setting.DisplayLabel());
       double v0 = ind.GetDataBuffer(0, 0);
       double v1 = ind.GetDataBuffer(0, 1);
       int    dir = 2;
       if(v0 != EMPTY_VALUE && v1 != EMPTY_VALUE) dir = (v0 > v1) ? 0 : (v0 < v1) ? 1 : 2;
       color txt_clr = (dir == 0) ? C'0,160,0' : (dir == 1) ? C'200,0,0' : clrGray;
       s_val_old[row] = v0;
       s_dir_old[row] = dir;
       m_table_indicators_trailingsetting.SetValue(2, row, (v0 == EMPTY_VALUE) ? "-" : ::DoubleToString(v0, 2));
       m_table_indicators_trailingsetting.TextColor(2, row, txt_clr);
       bool is_current = (row_setting != NULL && row_setting.TrailingMode() == SL_MODE_INDICATOR &&
                           row_setting.TrailingIndType() == ind.TypeIndicator() &&
                           row_setting.TrailingIndTF()   == tfs[row] &&
                           IsEqualMqlParamArrays(saved_params, ind_params));
       m_table_indicators_trailingsetting.CellType(3, row, CELL_CHECKBOX);
       m_table_indicators_trailingsetting.SetImages(3, row, chk);
       m_table_indicators_trailingsetting.ChangeImage(3, row, is_current ? 0 : 1);
      }
     s_row_count = count;
     m_table_indicators_trailingsetting.Update(true);
     return true;
    }
   //--- Per-tick: re-derive each Indicator's CURRENT visual row (sort can reorder), then dirty-check
   //--- Col2's Value text+color only.
    bool any_changed = false;
    for(int i = 0; i < count; i++)
     {
      MqlParam ind_params[];
      inds[i].GetMqlParams(ind_params);
      CIndicatorSetting ind_label_setting;
      ind_label_setting.TypeEnum(inds[i].TypeIndicator());
      ind_label_setting.SetRawParams(ind_params);
      string want_tf  = TimeframeDescription(tfs[i]);
      string want_ind = ind_label_setting.DisplayLabel();
      int row = -1;
      for(int r = 0; r < count; r++)
       if(m_table_indicators_trailingsetting.GetValue(0, r) == want_tf &&
          m_table_indicators_trailingsetting.GetValue(1, r) == want_ind) { row = r; break; }
      if(row < 0) continue; // identity not found this tick - next full rebuild will resync

      bool tf_active = (tfs[i] == (ENUM_TIMEFRAMES)::Period());
      if(tf_active != s_tf_active_old[row])
       {
        s_tf_active_old[row] = tf_active;
        m_table_indicators_trailingsetting.ChangeImage(0, row, tf_active ? 0 : 1, true);
        any_changed = true;
       }
      double v0 = inds[i].GetDataBuffer(0, 0);
      double v1 = inds[i].GetDataBuffer(0, 1);
      int    dir = 2;
      if(v0 != EMPTY_VALUE && v1 != EMPTY_VALUE) dir = (v0 > v1) ? 0 : (v0 < v1) ? 1 : 2;
      bool val_changed = (v0 != s_val_old[row]);
      bool dir_changed = (dir != s_dir_old[row]);
      if(val_changed || dir_changed)
       {
        s_val_old[row] = v0;
        s_dir_old[row] = dir;
        color txt_clr = (dir == 0) ? C'0,160,0' : (dir == 1) ? C'200,0,0' : clrGray;
        if(val_changed) m_table_indicators_trailingsetting.SetValue(2, row, (v0 == EMPTY_VALUE) ? "-" : ::DoubleToString(v0, 2), 0, true);
        m_table_indicators_trailingsetting.TextColor(2, row, txt_clr, true);
        any_changed = true;
       }
     }
   if(any_changed) m_table_indicators_trailingsetting.Update(false);
   return any_changed;
  }
 //+------------------------------------------------------------------+
 //| Checkbox click on m_table_indicators_trailingsetting - radio-like: |
 //| re-derive the clicked row's real (type, raw_params, tf) identity   |
 //| via the SAME TF-text+Indicator-label composite key already used to |
 //| re-derive post-sort identity elsewhere in this codebase (e.g.      |
 //| SynTable_IndicatorSymbolTFMonitor's own row_of[]), commit it as    |
 //| this Symbol's Trailing-by-Indicator choice, then rebuild so only   |
 //| this row's checkbox shows checked.                                 |
 //+------------------------------------------------------------------+
 void CGUIPannel::OnCheckTable_IndicatorsTrailingSetting(const int row)
  {
   string symbol_label = m_label_TrailingSetting_Symbol.LabelText();
   int    sep          = StringFind(symbol_label, " - ");
   string symbol        = (sep >= 0) ? StringSubstr(symbol_label, sep + 3) : "";
   if(symbol == "" || m_trading_setup_manager == NULL) return;
   string want_tf_text  = m_table_indicators_trailingsetting.GetValue(0, row);
   string want_ind_text = m_table_indicators_trailingsetting.GetValue(1, row);

   CIndicatorDE   *inds[];
   ENUM_TIMEFRAMES tfs[];
   int count = BuildTrailingIndicatorChoiceList(symbol, inds, tfs);
   for(int i = 0; i < count; i++)
    {
     MqlParam ind_params[];
     inds[i].GetMqlParams(ind_params);
     CIndicatorSetting ind_label_setting;
     ind_label_setting.TypeEnum(inds[i].TypeIndicator());
     ind_label_setting.SetRawParams(ind_params);
     if(TimeframeDescription(tfs[i]) != want_tf_text || ind_label_setting.DisplayLabel() != want_ind_text) continue;

     CTradingSetupSetting *row_setting = m_trading_setup_manager.FindByIdentity(symbol);
     if(row_setting == NULL) row_setting = m_trading_setup_manager.Add_TradingSetupSetting(symbol);
     if(row_setting == NULL) return;
     row_setting.TrailingMode(SL_MODE_INDICATOR);
     row_setting.TrailingIndTF(tfs[i]);
     row_setting.TrailingIndType(inds[i].TypeIndicator());
     row_setting.SetTrailingIndParams(ind_params);
     m_trading_setup_manager.NotifySettingChanged(symbol);
     SyncTable_IndicatorsTrailingSetting(symbol, true);
     return;
    }
  }
 //+------------------------------------------------------------------+
 //| Trailing form beside m_table_indicators_trailingsetting - Offset/ |
 //| Start/Step, ONE shared field each (Anhnt, 2026-09-08 - was split  |
 //| into Fixed/Indicator columns for Offset, but CSimpleTrailing in   |
 //| Trishkin's Trailings.mqh has a single m_offset used by both       |
 //| GetStopLossValue() overrides, not two - simplified to match). No  |
 //| Selection/Multiplier row either - Indicator is picked via         |
 //| m_table_indicators_trailingsetting's own checkbox.                |
 //+------------------------------------------------------------------+
 bool CGUIPannel::CreateTrailingForm(const int x_gap, const int y_gap)
  {
    int row0_y = y_gap;                          // Offset
    int row1_y = y_gap + M_CONTROL_YDISTANCE;    // Start
    int row2_y = y_gap + 2*M_CONTROL_YDISTANCE;  // Step
    int row3_y = y_gap + 3*M_CONTROL_YDISTANCE;  // DataRatesIndex (EA-wide, not per-Symbol)
    int row4_y = y_gap + 4*M_CONTROL_YDISTANCE;  // Save

    string caption_text[4] = {"Offset", "Start", "Step", "M1 Bar Shift"};
    int    caption_y[4]    = {row0_y, row1_y, row2_y, row3_y};
    for(int i = 0; i < 4; i++)
     {
      m_label_Trailing_GridCaption[i].MainPointer(m_tabs_setting_trading);
      m_tabs_setting_trading.AddToElementsArray(ENUM_TAB_SETTING_TRADING_TRAILLING,m_label_Trailing_GridCaption[i]);
      m_label_Trailing_GridCaption[i].XSize(90);
      m_label_Trailing_GridCaption[i].YSize(M_CONTROL_HEIGHT);
      if(!m_label_Trailing_GridCaption[i].CreateTextLabel(caption_text[i], x_gap, caption_y[i])) return false;
      CWndContainer::AddToElementsArray(WindowIdx(m_window_setting_trading),m_label_Trailing_GridCaption[i]);
     }

    m_edit_Trailing_Offset.MainPointer(m_tabs_setting_trading);
    m_tabs_setting_trading.AddToElementsArray(ENUM_TAB_SETTING_TRADING_TRAILLING,m_edit_Trailing_Offset);
    m_edit_Trailing_Offset.XSize(70);
    m_edit_Trailing_Offset.YSize(M_CONTROL_HEIGHT);
    m_edit_Trailing_Offset.GetTextBoxPointer().XGap(1);
    if(!m_edit_Trailing_Offset.CreateTextEdit("0", x_gap + 90, row0_y)) return false;
    CWndContainer::AddToElementsArray(WindowIdx(m_window_setting_trading),m_edit_Trailing_Offset);

    m_edit_Trailing_Start.MainPointer(m_tabs_setting_trading);
    m_tabs_setting_trading.AddToElementsArray(ENUM_TAB_SETTING_TRADING_TRAILLING,m_edit_Trailing_Start);
    m_edit_Trailing_Start.XSize(70);
    m_edit_Trailing_Start.YSize(M_CONTROL_HEIGHT);
    m_edit_Trailing_Start.GetTextBoxPointer().XGap(1);
    if(!m_edit_Trailing_Start.CreateTextEdit("0", x_gap + 90, row1_y)) return false;
    CWndContainer::AddToElementsArray(WindowIdx(m_window_setting_trading),m_edit_Trailing_Start);

    m_edit_Trailing_Step.MainPointer(m_tabs_setting_trading);
    m_tabs_setting_trading.AddToElementsArray(ENUM_TAB_SETTING_TRADING_TRAILLING,m_edit_Trailing_Step);
    m_edit_Trailing_Step.XSize(70);
    m_edit_Trailing_Step.YSize(M_CONTROL_HEIGHT);
    m_edit_Trailing_Step.GetTextBoxPointer().XGap(1);
    if(!m_edit_Trailing_Step.CreateTextEdit("0", x_gap + 90, row2_y)) return false;
    CWndContainer::AddToElementsArray(WindowIdx(m_window_setting_trading),m_edit_Trailing_Step);

    //--- EA-wide (not per-Symbol) - how many M1 bars back Trailing-by-Value reads its base
    //--- Low/High from (Anhnt, 2026-09-09, mirrors Trishkin's InpDataRatesIndex). Same value
    //--- regardless of which Symbol's Trailing form is open - populated/saved against
    //--- m_trading_setup_manager directly, not the per-Symbol row_setting the 3 fields above use.
     m_edit_Trailing_DataRatesIndex.MainPointer(m_tabs_setting_trading);
     m_tabs_setting_trading.AddToElementsArray(ENUM_TAB_SETTING_TRADING_TRAILLING,m_edit_Trailing_DataRatesIndex);
     m_edit_Trailing_DataRatesIndex.XSize(70);
     m_edit_Trailing_DataRatesIndex.YSize(M_CONTROL_HEIGHT);
     m_edit_Trailing_DataRatesIndex.GetTextBoxPointer().XGap(1);
     if(!m_edit_Trailing_DataRatesIndex.CreateTextEdit("2", x_gap + 90, row3_y)) return false;
     CWndContainer::AddToElementsArray(WindowIdx(m_window_setting_trading),m_edit_Trailing_DataRatesIndex);

    m_btn_save_Trailing_Setting.MainPointer(m_tabs_setting_trading);
    m_tabs_setting_trading.AddToElementsArray(ENUM_TAB_SETTING_TRADING_TRAILLING,m_btn_save_Trailing_Setting);
    m_btn_save_Trailing_Setting.XSize(80);
    m_btn_save_Trailing_Setting.YSize(M_CONTROL_HEIGHT);
    m_btn_save_Trailing_Setting.IconFile(IMAGE_RESOURCE_BMP16_SAVE_PNG);
    if(!m_btn_save_Trailing_Setting.CreateButton("Save", x_gap, row4_y)) return false;
    CWndContainer::AddToElementsArray(WindowIdx(m_window_setting_trading),m_btn_save_Trailing_Setting);
   //--- Hidden by default (Anhnt, 2026-09-08) - the whole Indicator-choice table + this form only
   //--- appear once the user actually clicks the Trailling icon on m_table_trailingsetting for a
   //--- Symbol (ShowTrailingForm), same "nothing shows until you ask for it" convention as
   //--- StopLost's own gear-icon-gated form.
    HideTrailingForm();
    return true;
  }
 //+------------------------------------------------------------------+
 //| Show + populate the Trailing form (and the Indicator-choice table |
 //| beside it) for one Symbol - called from the Symbol/Trailling-icon |
 //| click handler (GUIPannel_SettingWindows_Trading.mqh). Hidden again |
 //| by HideTrailingForm on tab switch-away.                            |
 //+------------------------------------------------------------------+
 void CGUIPannel::ShowTrailingForm(const string symbol)
  {
   m_label_TrailingSetting_Symbol.Show();
   m_label_TrailingSetting_Symbol.Moving();
   m_table_indicators_trailingsetting.Show();
   for(int i = 0; i < 4; i++)
    {
     m_label_Trailing_GridCaption[i].Show();
     m_label_Trailing_GridCaption[i].Moving();
    }
   m_edit_Trailing_Offset.Show();
   m_edit_Trailing_Offset.Moving();
   m_edit_Trailing_Start.Show();
   m_edit_Trailing_Start.Moving();
   m_edit_Trailing_Step.Show();
   m_edit_Trailing_Step.Moving();
   m_edit_Trailing_DataRatesIndex.Show();
   m_edit_Trailing_DataRatesIndex.Moving();
   m_btn_save_Trailing_Setting.Show();
   m_btn_save_Trailing_Setting.Moving();

   CTradingSetupSetting *row_setting = (m_trading_setup_manager != NULL) ? m_trading_setup_manager.FindByIdentity(symbol) : NULL;
   int offset_pts   = (row_setting != NULL) ? row_setting.TrailingOffsetPts()      : 0;
   int start_pts    = (row_setting != NULL) ? row_setting.TrailingStartPts()       : 0;
   int step_pts     = (row_setting != NULL) ? row_setting.TrailingStepPts()        : 0;
   int data_rates_index = (m_trading_setup_manager != NULL) ? m_trading_setup_manager.TrailingDataRatesIndex() : 2;
   m_edit_Trailing_Offset.SetValue((string)offset_pts, false);
   m_edit_Trailing_Offset.GetTextBoxPointer().Update(true);
   m_edit_Trailing_Offset.Update(true);
   m_edit_Trailing_Offset.Draw();
   m_edit_Trailing_Start.SetValue((string)start_pts, false);
   m_edit_Trailing_Start.GetTextBoxPointer().Update(true);
   m_edit_Trailing_Start.Update(true);
   m_edit_Trailing_Start.Draw();
   m_edit_Trailing_Step.SetValue((string)step_pts, false);
   m_edit_Trailing_Step.GetTextBoxPointer().Update(true);
   m_edit_Trailing_Step.Update(true);
   m_edit_Trailing_Step.Draw();
   //--- EA-wide value - same regardless of which Symbol this form is scoped to
   m_edit_Trailing_DataRatesIndex.SetValue((string)data_rates_index, false);
   m_edit_Trailing_DataRatesIndex.GetTextBoxPointer().Update(true);
   m_edit_Trailing_DataRatesIndex.Update(true);
   m_edit_Trailing_DataRatesIndex.Draw();
  }
 //+------------------------------------------------------------------+
 //| Hide the Indicator-choice table + Trailing form - called once     |
 //| right after CreateTrailingForm (default state) and again on       |
 //| m_tabs_setting_trading tab switch-away (GUIPannel_SettingWindows_Trading.mqh).|
 //+------------------------------------------------------------------+
 void CGUIPannel::HideTrailingForm(void)
  {
   m_label_TrailingSetting_Symbol.Hide();
   m_table_indicators_trailingsetting.Hide();
   for(int i = 0; i < 4; i++)
      m_label_Trailing_GridCaption[i].Hide();
   m_edit_Trailing_Offset.Hide();
   m_edit_Trailing_Start.Hide();
   m_edit_Trailing_Step.Hide();
   m_edit_Trailing_DataRatesIndex.Hide();
   m_btn_save_Trailing_Setting.Hide();
  }
#endif // CGUIPANNEL_SETTINGWINDOWS_TRADINGTRAILING_MQH_IMPLEMENTATION
