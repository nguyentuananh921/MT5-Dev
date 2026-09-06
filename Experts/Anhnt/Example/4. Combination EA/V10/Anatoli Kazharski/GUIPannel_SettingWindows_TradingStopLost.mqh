//+------------------------------------------------------------------+
//|                     GUIPannel_SettingWindows_TradingStopLost.mqh |
//| The library for the signal markers on chart                      |
//+------------------------------------------------------------------+
#ifndef CGUIPANNEL_SETTINGWINDOWS_TRADINGSTOPLOST_MQH_IMPLEMENTATION
#define CGUIPANNEL_SETTINGWINDOWS_TRADINGSTOPLOST_MQH_IMPLEMENTATION
 #include "GUIPannel.mqh" 
 bool CGUIPannel::CreateTable_StopLostSetting(const int x, const int y)
  {
    #define COLUMNS3_TOTAL 8
    m_table_stoplostsetting.MainPointer(m_tabs_setting_trading);
    m_tabs_setting_trading.AddToElementsArray(ENUM_TAB_SETTING_TRADING_STOPLOST,m_table_stoplostsetting);   
    int width[COLUMNS3_TOTAL]           = {120, 70, 35, 25, 70, 90, 90, 90};
    ENUM_ALIGN_MODE align[COLUMNS3_TOTAL] = {ALIGN_LEFT, ALIGN_RIGHT, ALIGN_RIGHT, ALIGN_LEFT, ALIGN_RIGHT, ALIGN_RIGHT, ALIGN_RIGHT, ALIGN_RIGHT};
    int text_x_offset[COLUMNS3_TOTAL]   = {22, 5, 5, 5, 5, 5, 5, 5}; // col0: clear the Symbol active-chart icon
    int image_x_offset[COLUMNS3_TOTAL]  = { 3, 3, 3, 5, 3, 3, 3, 3};
    int image_y_offset[COLUMNS3_TOTAL]  = { 3, 3, 3, 3, 3, 3, 3, 3};
     m_table_stoplostsetting.YSize(POSITIONS_TABLE_Y - M_CONTROL_BORDER_GAP - 5);
   //--- XSize = sum of width[] + room for the vertical scrollbar 
    int columns_width_total = 0;
    for(int c = 0; c < COLUMNS3_TOTAL; c++)
       columns_width_total += width[c];
    m_table_stoplostsetting.XSize(columns_width_total + 20); //20 For scroll
    m_table_stoplostsetting.TableSize(COLUMNS3_TOTAL, 20);
    m_table_stoplostsetting.ColumnsWidth(width);
    m_table_stoplostsetting.TextAlign(align);
    m_table_stoplostsetting.TextXOffset(text_x_offset);
    m_table_stoplostsetting.ImageXOffset(image_x_offset);
    m_table_stoplostsetting.ImageYOffset(image_y_offset);
    m_table_stoplostsetting.ShowHeaders(true);
    m_table_stoplostsetting.SelectableRow(true);
    m_table_stoplostsetting.LightsHover(true);
    m_table_stoplostsetting.IsSortMode(true);
    if(!m_table_stoplostsetting.CreateTable(x, y)) return false;
    m_table_stoplostsetting.SetHeaderText(0, "Symbol");
    m_table_stoplostsetting.SetHeaderText(1, "Mid");
    uint spread_header_img[] = {IMAGE_RESOURCE_BMP16_SPREADRED_PNG};
    m_table_stoplostsetting.SetHeaderText(2, "");
    m_table_stoplostsetting.SetHeaderImage(2, spread_header_img);
    uint sl_header_img[] = {IMAGE_RESOURCE_BMP16_STOPLOSTRED_PNG};
    m_table_stoplostsetting.SetHeaderText(3, "");
    m_table_stoplostsetting.SetHeaderImage(3, sl_header_img);
    // Clicking the gear icon in col3 shows the SL Setting form scoped to that row's own Symbol (see OnEvent),
    // Col4 shows the committed result after Save. 
    uint sl_value_img[] = {IMAGE_RESOURCE_BMP16_STOPLOSTRED_PNG};
    m_table_stoplostsetting.SetHeaderText(4, "SL");
    m_table_stoplostsetting.SetHeaderImage(4,sl_value_img);
    m_table_stoplostsetting.SetHeaderText(5, "Buy");
    m_table_stoplostsetting.SetHeaderImage(5,sl_value_img);
    m_table_stoplostsetting.SetHeaderText(6, "Sell");
    m_table_stoplostsetting.SetHeaderImage(6,sl_value_img);
    m_table_stoplostsetting.SetHeaderText(7, "SL Value");
    CWndContainer::AddToElementsArray(WindowIdx(m_window_setting_trading),m_table_stoplostsetting);
    SyncTable_StopLostSetting(true);
    return true;
  }
 //+------------------------------------------------------------------+
 //| Live refresh for m_table_stoplostsetting                          | 
 //+------------------------------------------------------------------+
 bool CGUIPannel::SyncTable_StopLostSetting(bool force = false)
  {
   if(m_symbol_collection == NULL) return false;
   // Symbol list: read straight off m_symbol_collection's own list it
   // already mirrors Market Watch itself (CSymbolsCollection::MarketWatchEventsControl(),
   // refreshed every tick via CTradingEngine::OnTickEvent()), so no separate array/copy/sort is
   // needed here at all - row order at build time is just whatever order Market Watch itself is
   // in; m_table_stoplostsetting.IsSortMode(true) already lets the user click the Symbol header to
   // sort A-Z whenever they want, same as any other column.
    CArrayObj *col_list = m_symbol_collection.GetList();
    int count = (col_list != NULL) ? col_list.Total() : 0;
    if(count == 0) return false;
   //--- Dirty-check state for this method's own tick-to-tick comparisons - scoped here as `static`
   //--- locals (persist across calls, but nothing outside this one function needs them) instead of
   //--- CGUIPannel members.
    static int    table_row_count = 0;
    static double mid_price_old[];
    static int    spread_half_old[];
    static bool   active_old[];
    static string sl_cache_old[];
    static double sl_distance_price_old[];
    static double sl_value_old[];
   // --- Full rebuild when row count changes
   if(count != table_row_count)
    {
     uint sym_img[] = {IMAGE_RESOURCE_BMP16_BAR_CHART_BMP, IMAGE_RESOURCE_BMP16_BAR_CHART_COLORLESS_BMP};
     m_table_stoplostsetting.DeleteAllRows();
     ::ArrayResize(mid_price_old,          count);
     ::ArrayResize(spread_half_old,        count);
     ::ArrayResize(active_old,             count);
     ::ArrayResize(sl_cache_old,           count);
     ::ArrayResize(sl_distance_price_old,  count);
     ::ArrayResize(sl_value_old,           count);
     ::ArrayInitialize(mid_price_old,         -1);
     ::ArrayInitialize(spread_half_old,       -1);
     ::ArrayInitialize(active_old,            false);
     ::ArrayInitialize(sl_distance_price_old, EMPTY_VALUE);
     ::ArrayInitialize(sl_value_old,          EMPTY_VALUE);
     for(int i = 0; i < count - 1; i++)
        m_table_stoplostsetting.AddRow(i, i == count - 2);
     for(int row = 0; row < count; row++)
      {
       CSymbol *sym = col_list.At(row);
       string sym_name = (sym != NULL) ? sym.Name() : "";
       bool active = (sym_name == ::Symbol());
       active_old[row] = active;
       m_table_stoplostsetting.SetImages(0, row, sym_img);
       m_table_stoplostsetting.ChangeImage(0, row, active ? 0 : 1);
       m_table_stoplostsetting.SetValue(0, row, sym_name);

       double bid    = (sym != NULL) ? sym.Bid()   : ::SymbolInfoDouble(sym_name, SYMBOL_BID);
       double ask    = (sym != NULL) ? sym.Ask()    : ::SymbolInfoDouble(sym_name, SYMBOL_ASK);
       int    digits = (sym != NULL) ? sym.Digits() : (int)::SymbolInfoInteger(sym_name, SYMBOL_DIGITS);
       //--- Spread/2 CSymbol::Spread() SYMBOL_PROP_SPREAD,no need to re-derive from Bid/Ask/Point.
        int    spread_half_pts = (sym != NULL) ? sym.Spread() / 2 : (int)::SymbolInfoInteger(sym_name, SYMBOL_SPREAD) / 2;
        double mid = (bid + ask) / 2.0;
       m_table_stoplostsetting.SetValue(1, row, ::DoubleToString(mid, digits));
       mid_price_old[row] = mid;
       m_table_stoplostsetting.SetValue(2, row, (string)spread_half_pts);
       spread_half_old[row] = spread_half_pts;

       uint sl_gear_img[] = {IMAGE_RESOURCE_BMP16_SETTING_RED_PNG};
       m_table_stoplostsetting.SetImages(3, row, sl_gear_img);
       m_table_stoplostsetting.ChangeImage(3, row, 0);
       string sl_val = FormatStopLostCacheValue(sym_name);
       m_table_stoplostsetting.SetValue(4, row, sl_val);
       sl_cache_old[row] = sl_val;

       //--- Col5 (SL Buy Price) / Col6 (SL Sell Price) / Col7 (SL Value) - Anhnt, 2026-09-03: "quy hết ra price,
       //--- tận dụng triệt để method của Symbol.mqh". Format to string only here, at the point of display -
       //--- the cached values themselves stay double.
        double distance_price = GetStopLostDistancePrice(sym_name);
        double sl_money       = GetStopLostMoneyValue(sym_name);
        sl_distance_price_old[row] = distance_price;
        sl_value_old[row]          = sl_money;
       if(distance_price == EMPTY_VALUE)
         {
          m_table_stoplostsetting.SetValue(5, row, "-");
          m_table_stoplostsetting.SetValue(6, row, "-");
         }
       else
        {
          m_table_stoplostsetting.SetValue(5, row, ::DoubleToString(mid - distance_price, digits));
          m_table_stoplostsetting.SetValue(6, row, ::DoubleToString(mid + distance_price, digits));
        }
       m_table_stoplostsetting.SetValue(7, row, (sl_money == EMPTY_VALUE) ? "-" :
                                                ::DoubleToString(sl_money, 2) + " " + ::AccountInfoString(ACCOUNT_CURRENCY));
      }
     table_row_count = count;
     m_table_stoplostsetting.Update(true);
     return true;
    }
    bool any_changed = false;
    for(int i = 0; i < count; i++)
     {
      CSymbol *sym = col_list.At(i);
      string sym_name = (sym != NULL) ? sym.Name() : "";
      // --- Re-derive this symbol's CURRENT visual row (CTable's own header-click sort can reorder
      // --- rows) - Col0 (Symbol) text is never touched below, so it's a reliable post-sort identity
      // --- key. Looked up right here, per Symbol, instead of a separate row_of[] pre-pass array.
       int row = -1;
       for(int r = 0; r < count; r++)
        if(m_table_stoplostsetting.GetValue(0, r) == sym_name) { row = r; break; }
       if(row < 0) continue; // identity not found this tick - next full rebuild will resync
      // --- Col0: active-chart icon
       bool active = (sym_name == ::Symbol());
       if(active != active_old[row])
        {
         active_old[row] = active;
         m_table_stoplostsetting.ChangeImage(0, row, active ? 0 : 1, true);
         any_changed = true;
        }
       double bid    = (sym != NULL) ? sym.Bid()   : ::SymbolInfoDouble(sym_name, SYMBOL_BID);
       double ask    = (sym != NULL) ? sym.Ask()    : ::SymbolInfoDouble(sym_name, SYMBOL_ASK);
       int    digits = (sym != NULL) ? sym.Digits() : (int)::SymbolInfoInteger(sym_name, SYMBOL_DIGITS);
       int    spread_half_pts = (sym != NULL) ? sym.Spread() / 2 : (int)::SymbolInfoInteger(sym_name, SYMBOL_SPREAD) / 2;
       double mid = (bid + ask) / 2.0;
      // --- Col1 (Mid): green=up / red=down / gray=flat vs last written (Bid+Ask)/2
       double prev_mid = mid_price_old[row];
       if(force || mid != prev_mid)
        {
         int dir = (prev_mid < 0) ? 2 : (mid > prev_mid) ? 0 : (mid < prev_mid) ? 1 : 2;
         color txt_clr = (dir == 0) ? C'0,160,0' : (dir == 1) ? C'200,0,0' : clrGray;
         m_table_stoplostsetting.SetValue(1, row, ::DoubleToString(mid, digits), 0, true);
         m_table_stoplostsetting.TextColor(1, row, txt_clr, true);
         mid_price_old[row] = mid;
         any_changed = true;
        }
      // --- Col5 (SL Buy Price) / Col6 (SL Sell Price) - re-derived here (Anhnt, 2026-09-03) because
      // --- they depend on Mid, which just changed above (Fixed-mode Distance is static, but Mid
      // --- moves every tick, so the absolute Buy/Sell levels shown here still need refreshing every tick).
       {
        double distance_price = GetStopLostDistancePrice(sym_name);
        if(force || distance_price != sl_distance_price_old[row] || mid != prev_mid)
         {
          sl_distance_price_old[row] = distance_price;
          if(distance_price == EMPTY_VALUE)
           {
            m_table_stoplostsetting.SetValue(5, row, "-", 0, true);
            m_table_stoplostsetting.SetValue(6, row, "-", 0, true);
           }
          else
           {
            m_table_stoplostsetting.SetValue(5, row, ::DoubleToString(mid - distance_price, digits), 0, true);
            m_table_stoplostsetting.SetValue(6, row, ::DoubleToString(mid + distance_price, digits), 0, true);
           }
          any_changed = true;
         }
       }
      // --- Col2 (Spread/2): same up/down/flat color convention (Anhnt, 2026-09-02) - distinct
      // --- from the SL Setting popup's own "Min Stop Lot" (TradeStopLevel()).
       int prev_spread = spread_half_old[row];
       if(force || spread_half_pts != prev_spread)
        {
         int dir = (prev_spread < 0) ? 2 : (spread_half_pts > prev_spread) ? 0 : (spread_half_pts < prev_spread) ? 1 : 2;
         color txt_clr = (dir == 0) ? C'0,160,0' : (dir == 1) ? C'200,0,0' : clrGray;
         m_table_stoplostsetting.SetValue(2, row, (string)spread_half_pts, 0, true);
         m_table_stoplostsetting.TextColor(2, row, txt_clr, true);
         spread_half_old[row] = spread_half_pts;
         any_changed = true;
        }

      // --- Col4 (SL Value): ATR mode only - its underlying ATR value moves every tick, so it
      // --- needs re-reading here. Fixed mode is a static number the user typed; it never changes
      // --- outside Save, so it is deliberately skipped in this per-tick loop (no wasted work).
       CTradingSetupSetting *sl_row = (m_trading_setup_manager != NULL) ? m_trading_setup_manager.FindByIdentity(sym_name) : NULL;
       if(sl_row != NULL && sl_row.StopLostMode() == SL_MODE_INDICATOR)
        {
         string sl_val = FormatStopLostCacheValue(sym_name);
         if(force || sl_val != sl_cache_old[row])
          {
           sl_cache_old[row] = sl_val;
           m_table_stoplostsetting.SetValue(4, row, sl_val, 0, true);
           any_changed = true;
          }
        //--- Col7 (SL Value) - ATR mode's underlying distance moves every tick same as col4's own
        //--- points value above, so it needs the same live re-check (Anhnt, 2026-09-03). Fixed
        //--- mode is deliberately NOT checked here (matches col4's own reasoning) - it only ever
        //--- changes on Save, handled by that handler's own immediate SetValue instead.
         double sl_money = GetStopLostMoneyValue(sym_name);
         if(force || sl_money != sl_value_old[row])
          {
           sl_value_old[row] = sl_money;
           m_table_stoplostsetting.SetValue(7, row, (sl_money == EMPTY_VALUE) ? "-" :
                                                    ::DoubleToString(sl_money, 2) + " " + ::AccountInfoString(ACCOUNT_CURRENCY), 0, true);
           any_changed = true;
          }
        }
     }
   if(any_changed) m_table_stoplostsetting.Update(false);
   return any_changed;
  }  
 bool CGUIPannel::CreateStopLostForm(const int x_gap, const int y_gap)
  {
   //--- Uniform vertical rhythm (Anhnt, 2026-09-03: "Các control bên phải cách nhau theo chiều Y
   //--- một khoảng M_CONTROL_YDISTANCE") - every row on this (right-side) form is exactly
   //--- M_CONTROL_YDISTANCE apart, row index * M_CONTROL_YDISTANCE. Symbol/Min Stop Lot share row0
   //--- side by side. Fixed/ATR radios now ALSO side by side (Anhnt, 2026-09-03: "cho
   //--- m_buttonsGroup_SLMode gồm 2 lựa chọn nằm ngang ra rồi dịch lên trên") - now that this form
   //--- moved into m_window_setting's own tab, there's 700px of room, not the ~250px it was
   //--- squeezed into beside the table in TAB_TAB_MAIN_POSITIONS. 2 columns: Fixed's own
   //--- radio+field+unit at COLUMN_A_X, ATR's own radio+combobox at COLUMN_B_X, same row (row1) -
   //--- only the Multiplier (doesn't fit beside ATR's combobox too) needs its own row (row2),
   //--- saving a full row vs the old 3-rows-stacked layout, which is what shifts Preview/Risk%/
   //--- Save up.
    #define COLUMN_A_X 0
    #define COLUMN_B_X 280
    int row0_y = y_gap;                          // Symbol + Min Stop Lot, side by side
    int row1_y = y_gap + M_CONTROL_YDISTANCE;    // Fixed radio+field+unit (COLUMN_A) | ATR radio+combobox (COLUMN_B)
    int row2_y = y_gap + 2*M_CONTROL_YDISTANCE;  // ATR Multiplier+unit (COLUMN_B only - Fixed has nothing here)
    int row3_y = y_gap + 3*M_CONTROL_YDISTANCE;  // Preview
    int row4_y = y_gap + 4*M_CONTROL_YDISTANCE;  // Risk % per Position
    int row5_y = y_gap + 5*M_CONTROL_YDISTANCE;  // Save

   //--- Top-down info block: Symbol / Point / Trade-Stop-Level, Symbol-scoped, always visible
   //--- regardless of mode. Values are set per-Symbol in ShowStopLostForm(), not here.
    m_label_StopLostSetting_Symbol.MainPointer(m_tabs_setting_trading);
    m_tabs_setting_trading.AddToElementsArray(ENUM_TAB_SETTING_TRADING_STOPLOST,m_label_StopLostSetting_Symbol);
    m_label_StopLostSetting_Symbol.XSize(110);
    m_label_StopLostSetting_Symbol.YSize(M_CONTROL_HEIGHT);
    if(!m_label_StopLostSetting_Symbol.CreateTextLabel("Symbol - -", x_gap, row0_y)) return false;
    CWndContainer::AddToElementsArray(WindowIdx(m_window_setting_trading),m_label_StopLostSetting_Symbol);

   //--- Beside Symbol now, same row - gap = M_CONTROL_YDISTANCE (Anhnt, 2026-09-03), same constant
   //--- used for every other control-to-control gap on this form (see Point/x ATR labels below) -
   //--- M_CONTROL_BORDER_GAP (3px) proved too tight, text looked glued to the control before it.
    m_label_StopLost_MinPts.MainPointer(m_tabs_setting_trading);
    m_tabs_setting_trading.AddToElementsArray(ENUM_TAB_SETTING_TRADING_STOPLOST,m_label_StopLost_MinPts);
    m_label_StopLost_MinPts.XSize(140);
    m_label_StopLost_MinPts.YSize(M_CONTROL_HEIGHT);
    if(!m_label_StopLost_MinPts.CreateTextLabel("Min Stop Lot - 0", m_label_StopLostSetting_Symbol.X2() + M_CONTROL_YDISTANCE, row0_y)) return false;
    CWndContainer::AddToElementsArray(WindowIdx(m_window_setting_trading),m_label_StopLost_MinPts);

    if(!CreateButtonsGroup_SLMode(x_gap, row1_y)) return false;
   //--- Fixed's own field/unit sit at COLUMN_A_X, beside its own radio (Anhnt, 2026-09-02: "khi
   //--- chọn Fixed thì có thể đẻ cái CTextEdit ngay cạnh") - the CFrame group-box experiment is
   //--- gone (fewer moving parts).
    m_edit_StopLost_FixedPoint.MainPointer(m_tabs_setting_trading);
    m_tabs_setting_trading.AddToElementsArray(ENUM_TAB_SETTING_TRADING_STOPLOST,m_edit_StopLost_FixedPoint);
    m_edit_StopLost_FixedPoint.XSize(70);
    m_edit_StopLost_FixedPoint.YSize(M_CONTROL_HEIGHT);
    m_edit_StopLost_FixedPoint.GetTextBoxPointer().XGap(1);
    if(!m_edit_StopLost_FixedPoint.CreateTextEdit("100", x_gap + COLUMN_A_X + 90, row1_y)) return false;
    CWndContainer::AddToElementsArray(WindowIdx(m_window_setting_trading),m_edit_StopLost_FixedPoint);

   //--- x = the field's own right edge + M_CONTROL_YDISTANCE (Anhnt, 2026-09-03: "cách cái control
   //--- phía trước" - was M_CONTROL_BORDER_GAP, looked glued to the field) - stays correct if the
   //--- field's XSize ever changes. "pts" -> "Point" (Anhnt, 2026-09-03).
    m_label_StopLost_FixedUnit.MainPointer(m_tabs_setting_trading);
    m_tabs_setting_trading.AddToElementsArray(ENUM_TAB_SETTING_TRADING_STOPLOST,m_label_StopLost_FixedUnit);
    m_label_StopLost_FixedUnit.XSize(60);
    m_label_StopLost_FixedUnit.YSize(M_CONTROL_HEIGHT);
    if(!m_label_StopLost_FixedUnit.CreateTextLabel("Point", m_edit_StopLost_FixedPoint.X2() + M_CONTROL_YDISTANCE, row1_y + 3)) return false;
    CWndContainer::AddToElementsArray(WindowIdx(m_window_setting_trading),m_label_StopLost_FixedUnit);

   //--- ATR's own combobox sits at COLUMN_B_X, beside ITS OWN radio, same row (row1) as Fixed's
   //--- field (Anhnt, 2026-09-03: horizontal radios + 2 columns) - was stacked on its own row below
   //--- Fixed's entirely; now the 2 modes sit side by side instead.
    m_combobox_ATR_choice.MainPointer(m_tabs_setting_trading);
    m_tabs_setting_trading.AddToElementsArray(ENUM_TAB_SETTING_TRADING_STOPLOST,m_combobox_ATR_choice);
    m_combobox_ATR_choice.XSize(80);
    m_combobox_ATR_choice.YSize(M_CONTROL_HEIGHT);
    m_combobox_ATR_choice.GetButtonPointer().XGap(1);
    m_combobox_ATR_choice.GetButtonPointer().XSize(150);
    m_combobox_ATR_choice.GetButtonPointer().LabelYGap(4);
    m_combobox_ATR_choice.GetButtonPointer().IconYGap(3);
    if(!m_combobox_ATR_choice.CreateComboBox("", x_gap + COLUMN_B_X + 90, row1_y)) return false;
    CWndContainer::AddToElementsArray(WindowIdx(m_window_setting_trading),m_combobox_ATR_choice);

   //--- Multiplier doesn't fit beside the combobox too, so it drops to row2 - still COLUMN_B_X,
   //--- staying visually under ATR's own combobox (Fixed's column has nothing on this row).
    m_edit_ATR_Multiplexer.MainPointer(m_tabs_setting_trading);
    m_tabs_setting_trading.AddToElementsArray(ENUM_TAB_SETTING_TRADING_STOPLOST,m_edit_ATR_Multiplexer);
    m_edit_ATR_Multiplexer.XSize(60);
    m_edit_ATR_Multiplexer.YSize(M_CONTROL_HEIGHT);
    m_edit_ATR_Multiplexer.GetTextBoxPointer().XGap(1);
    if(!m_edit_ATR_Multiplexer.CreateTextEdit("1.5", x_gap + COLUMN_B_X + 90, row2_y)) return false;
    CWndContainer::AddToElementsArray(WindowIdx(m_window_setting_trading),m_edit_ATR_Multiplexer);

   //--- Same X2()+M_CONTROL_YDISTANCE spacing as the Fixed unit label above (Anhnt, 2026-09-03).
    m_label_StopLost_ATRUnit.MainPointer(m_tabs_setting_trading);
    m_tabs_setting_trading.AddToElementsArray(ENUM_TAB_SETTING_TRADING_STOPLOST,m_label_StopLost_ATRUnit);
    m_label_StopLost_ATRUnit.XSize(80);
    m_label_StopLost_ATRUnit.YSize(M_CONTROL_HEIGHT);
    if(!m_label_StopLost_ATRUnit.CreateTextLabel("x ATR", m_edit_ATR_Multiplexer.X2() + M_CONTROL_YDISTANCE, row2_y + 3)) return false;
    CWndContainer::AddToElementsArray(WindowIdx(m_window_setting_trading),m_label_StopLost_ATRUnit);

   //--- Live-computed preview (Anhnt/Claude, 2026-09-02) - "Preview SL - X pts", see
   //--- UpdateStopLostPreview(). Moved up (Anhnt, 2026-09-03) along with everything below, since
   //--- the Fixed/ATR block above now uses one fewer row (2 rows instead of 3).
    m_label_StopLost_Preview.MainPointer(m_tabs_setting_trading);
    m_tabs_setting_trading.AddToElementsArray(ENUM_TAB_SETTING_TRADING_STOPLOST,m_label_StopLost_Preview);
    m_label_StopLost_Preview.XSize(200);
    m_label_StopLost_Preview.YSize(M_CONTROL_HEIGHT);
    if(!m_label_StopLost_Preview.CreateTextLabel("Preview SL - -", x_gap, row3_y)) return false;
    CWndContainer::AddToElementsArray(WindowIdx(m_window_setting_trading),m_label_StopLost_Preview);

   //--- Risk % per Position (Anhnt, 2026-09-03) - basis for a later Lot-size calc from this
   //--- Symbol's Stop Distance above + this Risk% (same shape as "Risk Management EA Based on
   //--- ATR Volatility.mq5": Lot = RiskMoney / (Distance_points * TickValue)) - not wired yet,
   //--- this is just the input row.
    m_label_RiskPercentagePerPosition.MainPointer(m_tabs_setting_trading);
    m_tabs_setting_trading.AddToElementsArray(ENUM_TAB_SETTING_TRADING_STOPLOST,m_label_RiskPercentagePerPosition);
    m_label_RiskPercentagePerPosition.XSize(90);
    m_label_RiskPercentagePerPosition.YSize(M_CONTROL_HEIGHT);
    if(!m_label_RiskPercentagePerPosition.CreateTextLabel("Risk % Per Pos", x_gap, row4_y)) return false;
    CWndContainer::AddToElementsArray(WindowIdx(m_window_setting_trading),m_label_RiskPercentagePerPosition);

    m_edit_RiskPercentagePerPosition.MainPointer(m_tabs_setting_trading);
    m_tabs_setting_trading.AddToElementsArray(ENUM_TAB_SETTING_TRADING_STOPLOST,m_edit_RiskPercentagePerPosition);
    m_edit_RiskPercentagePerPosition.XSize(60);
    m_edit_RiskPercentagePerPosition.YSize(M_CONTROL_HEIGHT);
    m_edit_RiskPercentagePerPosition.GetTextBoxPointer().XGap(1);
   //--- Default = RISK_PERCENTAGE_PERPOSITION (Anhnt, 2026-09-03) - same 5% for every Symbol
   //--- until the user changes it; no per-Symbol override/cache for this yet.
    if(!m_edit_RiskPercentagePerPosition.CreateTextEdit((string)RISK_PERCENTAGE_PERPOSITION, x_gap + 90, row4_y)) return false;
    CWndContainer::AddToElementsArray(WindowIdx(m_window_setting_trading),m_edit_RiskPercentagePerPosition);
   //--- CreateTextEdit()'s own "text" param never actually paints (CTextEdit::CreateEdit() just
   //--- creates an EMPTY inner CTextBox, never calls AddText/SetValue with it - confirmed by
   //--- reading TextEdit.mqh) - same quirk already hit with m_edit_StopLost_FixedPoint, fixed the
   //--- same way: SetValue() + the inner CTextBox's own Update() (Anhnt, 2026-09-03).
    m_edit_RiskPercentagePerPosition.SetValue((string)RISK_PERCENTAGE_PERPOSITION, false);
    m_edit_RiskPercentagePerPosition.GetTextBoxPointer().Update(true);
    m_edit_RiskPercentagePerPosition.Update(true);
    m_edit_RiskPercentagePerPosition.Draw();

   //--- Save button - own dedicated button, can't share m_btn_save_indicator (a single CButton
   //--- can't belong to 2 different forms/purposes at once).
    m_btn_save_StopLost_Setting.MainPointer(m_tabs_setting_trading);
    m_tabs_setting_trading.AddToElementsArray(ENUM_TAB_SETTING_TRADING_STOPLOST,m_btn_save_StopLost_Setting);
    m_btn_save_StopLost_Setting.XSize(80);
    m_btn_save_StopLost_Setting.YSize(M_CONTROL_HEIGHT);
    m_btn_save_StopLost_Setting.IconFile(IMAGE_RESOURCE_BMP16_SAVE_PNG);
    if(!m_btn_save_StopLost_Setting.CreateButton("Save", x_gap, row5_y)) return false;
    CWndContainer::AddToElementsArray(WindowIdx(m_window_setting_trading),m_btn_save_StopLost_Setting);
   //--- Do NOT Hide() anything here (Anhnt/Claude, 2026-09-02, per GUIPannel_SettingWindows_
   //--- AddIndicatorForm.mqh's own established rule) - CompletedGUI() (called after this
   //--- function, from CreateGUIPannel()) runs FormAvailableElementsArray(), which only includes
   //--- VISIBLE elements in m_available_elements[]. Hiding before that means MOUSE_MOVE events
   //--- never reach these controls later even after a subsequent Show(). HideStopLostForm() is
   //--- called explicitly ONCE right after CompletedGUI() instead (see CreateGUIPannel()).
    return true;
  } 
 void CGUIPannel::ShowStopLostForm(const string symbol)
  {
    m_string_StopLost_setting_current_symbol = symbol;
   //--- Top-down info block: Symbol / Trade-Stop-Level - Symbol-scoped, shown regardless of mode
   //--- (per user: "đằng nào chúng ta cũng phải setting persymbol mà").
   //--- Same floor formula as the Save handler's own MathMax(typed_pts, min_pts) (Anhnt,
   //--- 2026-09-03: "Distance khi chọn Fixed ... không cho phép chọn giá trị nhỏ hơn") - Spread()/2
   //--- + TradeStopLevel(), never 0 (spread is always > 0), so it also doubles as a meaningful
   //--- per-Symbol default below instead of a flat hardcoded number.
    CSymbol *sym_for_info = m_symbol_collection.GetSymbolObjByName(symbol);
    int min_pts_for_info = (sym_for_info != NULL) ? (sym_for_info.Spread()/2 + sym_for_info.TradeStopLevel())
                                                   : (int)::SymbolInfoInteger(symbol, SYMBOL_TRADE_STOPS_LEVEL);
    m_label_StopLostSetting_Symbol.LabelText("Symbol - " + symbol);
    m_label_StopLostSetting_Symbol.Draw();
    m_label_StopLostSetting_Symbol.Update(true);
    m_label_StopLostSetting_Symbol.Show();
    m_label_StopLostSetting_Symbol.Moving();
    m_label_StopLost_MinPts.LabelText("Min Stop Lot - " + (string)min_pts_for_info);
    m_label_StopLost_MinPts.Draw();
    m_label_StopLost_MinPts.Update(true);
    m_label_StopLost_MinPts.Show();
    m_label_StopLost_MinPts.Moving();

    CTradingSetupSetting *row_setting = (m_trading_setup_manager != NULL) ? m_trading_setup_manager.FindByIdentity(symbol) : NULL;
    ENUM_STOPLOST_TRAILING_MODE mode = (row_setting != NULL) ? row_setting.StopLostMode() : SL_MODE_FIXED;
   //--- Never-configured Symbol (row_setting==NULL): default Distance = the same Min Stop Lot
   //--- floor above, not a flat hardcoded number (Anhnt, 2026-09-03) - it's per-Symbol, always > 0,
   //--- and never rejected on Save since it already equals the enforced minimum.
    int             distance_pts = (row_setting != NULL) ? row_setting.StopLostFixedPts() : min_pts_for_info;
    ENUM_TIMEFRAMES atr_tf       = (row_setting != NULL) ? row_setting.StopLostIndTF()    : PERIOD_CURRENT;
    double          atr_mult     = (row_setting != NULL) ? row_setting.StopLostIndMultiplier() : 1.5;
    int             atr_period   = 14;
    if(row_setting != NULL)
     {
      MqlParam sl_ind_p[];
      row_setting.GetStopLostIndParams(sl_ind_p);
      if(::ArraySize(sl_ind_p) > 0) atr_period = (int)sl_ind_p[0].integer_value;
     }
   //--- Rebuild the combobox for THIS Symbol (choices depend on Symbol) - re-selecting whichever
   //--- item matches the saved (atr_tf, atr_period) is now SyncComboBox_ATRChoice()'s own job.
    bool has_atr_choice = SyncComboBox_ATRChoice(symbol, atr_tf, atr_period);
   //--- Fixed always usable; ATR mode forced back to Fixed if this Symbol has no ATR at all.
    if(!has_atr_choice) mode = SL_MODE_FIXED;
    m_buttonsGroup_SLMode.SelectButton((uint)mode);
    m_buttonsGroup_SLMode.Show();
    m_buttonsGroup_SLMode.Moving();

   //--- SetValue() alone never repaints the visible text - it's painted by the inner CTextBox
   //--- (m_edit), which has its own separate canvas, not by the outer CTextEdit's own Draw()/
   //--- Update(). Fixed mode field.
    m_edit_StopLost_FixedPoint.SetValue((string)distance_pts, false);
    m_edit_StopLost_FixedPoint.GetTextBoxPointer().Update(true);
    m_edit_StopLost_FixedPoint.Update(true);
    m_edit_StopLost_FixedPoint.Draw();
   //--- ATR mode field - Multiplier.
    m_edit_ATR_Multiplexer.SetValue(::DoubleToString(atr_mult, 2), false);
    m_edit_ATR_Multiplexer.GetTextBoxPointer().Update(true);
    m_edit_ATR_Multiplexer.Update(true);
    m_edit_ATR_Multiplexer.Draw();
   //--- NOT calling m_combobox_ATR_choice.Draw() here - crashed ("invalid pointer access",
   //--- Element.mqh:614, CElement::Moving() -> m_main.X()) when the combobox has 0 items
   //--- (has_atr_choice==false) - unlike AddIndicatorForm.mqh's m_param_combo[i].Draw()
   //--- precedent, which only ever runs in the branch that just populated it with >=1 real
   //--- item. Painting is already handled by SyncComboBox_ATRChoice()'s own
   //--- GetListViewPointer().Update(true).
    ToggleStopLostModeState();
    UpdateStopLostPreview();
    m_label_StopLost_Preview.Show();
    m_label_StopLost_Preview.Moving();
   //--- Risk %/Position - shown regardless of mode, same as Symbol/Min Stop Lot/Preview above.
   //--- No cache read here yet (Anhnt, 2026-09-03) - Lot-size calc from this + Distance isn't
   //--- wired yet, this is only the input row for now.
    m_label_RiskPercentagePerPosition.Show();
    m_label_RiskPercentagePerPosition.Moving();
    m_edit_RiskPercentagePerPosition.Show();
    m_edit_RiskPercentagePerPosition.Moving();
   //--- Was missing entirely (Anhnt, 2026-09-03: "chả thấy nút Save đâu cả") - HideStopLostForm()
   //--- hides this once at startup and nothing here ever re-showed it, so it stayed hidden forever.
    m_btn_save_StopLost_Setting.Show();
    m_btn_save_StopLost_Setting.Moving();
    ::ChartRedraw();
  }
 //+------------------------------------------------------------------+
 //| Hide the SL Setting form - no window/dialog-box lifecycle to      |
 //| worry about anymore, just Hide() every control directly (Anhnt/   |
 //| Claude, 2026-09-02).                                               |
 //+------------------------------------------------------------------+
 void CGUIPannel::HideStopLostForm(void)
  {
    m_label_StopLostSetting_Symbol.Hide();
    m_label_StopLost_MinPts.Hide();
    m_buttonsGroup_SLMode.Hide();
    m_edit_StopLost_FixedPoint.Hide();
    m_label_StopLost_FixedUnit.Hide();
    m_combobox_ATR_choice.Hide();
    m_edit_ATR_Multiplexer.Hide();
    m_label_StopLost_ATRUnit.Hide();
    m_label_StopLost_Preview.Hide();
    m_label_RiskPercentagePerPosition.Hide();
    m_edit_RiskPercentagePerPosition.Hide();
    m_btn_save_StopLost_Setting.Hide();
  } 
 //For control in StopLost Form
  bool CGUIPannel::CreateButtonsGroup_SLMode(const int x, const int y)
   {
    m_buttonsGroup_SLMode.MainPointer(m_tabs_setting_trading);
    m_tabs_setting_trading.AddToElementsArray(ENUM_TAB_SETTING_TRADING_STOPLOST,m_buttonsGroup_SLMode);
    m_buttonsGroup_SLMode.RadioButtonsMode(true);   
    m_buttonsGroup_SLMode.RadioButtonsStyle(true);
    m_buttonsGroup_SLMode.AddButton(COLUMN_A_X, 0, "Fixed", 80);
    m_buttonsGroup_SLMode.AddButton(COLUMN_B_X, 0, "ATR", 80);
    if(!m_buttonsGroup_SLMode.CreateButtonsGroup(x, y)) return false;
    CWndContainer::AddToElementsArray(WindowIdx(m_window_setting_trading),m_buttonsGroup_SLMode);
    return true;
   }
  
  bool CGUIPannel::SyncComboBox_ATRChoice(const string symbol, const ENUM_TIMEFRAMES saved_tf, const int saved_period)
   {    
    ENUM_TIMEFRAMES local_tf[];
    int             local_period[];
    int n = 0;
    if(m_indicator_template_manager != NULL && m_SymbolTFManager != NULL)
     {
      int templates_total = m_indicator_template_manager.Total();
      for(int t = 0; t < templates_total; t++)
       {
        CIndicatorSetting *tpl = m_indicator_template_manager.At(t);
        if(tpl == NULL || tpl.TypeEnum() != IND_ATR) continue;
        MqlParam raw[];
        tpl.GetRawParams(raw);
        int period = (int)raw[0].integer_value;
        int tf_total = m_SymbolTFManager.Total();
        for(int s = 0; s < tf_total; s++)
         {
          CSymbolTFSetting *row = m_SymbolTFManager.At(s);
          if(row == NULL || row.Symbol() != symbol) continue;
          ::ArrayResize(local_tf,     n + 1);
          ::ArrayResize(local_period, n + 1);
          local_tf[n]     = row.TFEnum();
          local_period[n] = period;
          n++;
         }
       }
     }
    //--- MY DEBUG (temp, Anhnt 2026-09-03) - dump the cross-product + whether each candidate
    //--- actually has a live instance in m_IndicatorsCollection right now, to settle whether
    //--- "not selectable" is a missing-data problem or a GUI-lock problem.
      CMessage::ToFile(g_ea_folder, "CGUIPannel", "SyncComboBox_ATRChoice",
          "MY DEBUG symbol=" + symbol + " n=" + (string)n +
          " saved_tf=" + EnumToString(saved_tf) + " saved_period=" + (string)saved_period);
      for(int dbg = 0; dbg < n; dbg++)
      {
        bool live_found = false;
        if(m_IndicatorsCollection != NULL)
        {
          CArrayObj *dbg_list = m_IndicatorsCollection.GetListIndBySymbol(symbol);
          dbg_list = CTimeseriesSelect::ByIndicatorProperty(dbg_list, INDICATOR_PROP_TIMEFRAME, local_tf[dbg], EQUAL);
          int dbg_total = (dbg_list != NULL) ? dbg_list.Total() : 0;
          for(int di = 0; di < dbg_total; di++)
          {
            CIndicatorDE *dbg_cand = dbg_list.At(di);
            if(dbg_cand == NULL || dbg_cand.TypeIndicator() != IND_ATR) continue;
            MqlParam dbg_raw[1];
            dbg_raw[0].type          = TYPE_INT;
            dbg_raw[0].integer_value = local_period[dbg];
            MqlParam dbg_cand_params[];
            dbg_cand.GetMqlParams(dbg_cand_params);
            if(IsEqualMqlParamArrays(dbg_cand_params, dbg_raw)) { live_found = true; break; }
          }
        }
        CMessage::ToFile(g_ea_folder, "CGUIPannel", "SyncComboBox_ATRChoice",
            "MY DEBUG   [" + (string)dbg + "] tf=" + EnumToString(local_tf[dbg]) +
            " period=" + (string)local_period[dbg] + " live_found=" + (string)live_found);
      }
    m_combobox_ATR_choice.ItemsTotal(n);
    int list_h = 18 * ::MathMax(n, 1) + 4;
    if(list_h > 300) list_h = 300;
    m_combobox_ATR_choice.GetListViewPointer().YSize(list_h);
    m_combobox_ATR_choice.GetListViewPointer().Rebuilding(n);
    for(int i = 0; i < n; i++)
       m_combobox_ATR_choice.SetValue(i, "ATR(" + (string)local_period[i] + ") " + TimeframeDescription(local_tf[i]));
    //--- Re-select whichever item matches the caller's saved (tf, period), if any still matches
    //--- after the rebuild above; otherwise fall back to item 0 (was done by the caller before,
    //--- moved in here since local_tf[]/local_period[] no longer exist outside this function).
     int select_index = 0;
     for(int i = 0; i < n; i++)
       if(local_tf[i] == saved_tf && local_period[i] == saved_period) { select_index = i; break; }
     if(n > 0) m_combobox_ATR_choice.SelectItem(select_index);
     m_combobox_ATR_choice.GetListViewPointer().Update(true);
    //--- Force the dropdown CLOSED after every rebuild (Anhnt/Claude, 2026-09-02) - CComboBox::
    //--- Hide() never explicitly hides m_listview itself (only unpresses the button), so if the
    //--- list was ever left open from an earlier click, switching Symbol/mode could otherwise
    //--- keep showing it as a big blank expanded box instead of the closed "ATR(14) M1" button.
     m_combobox_ATR_choice.GetListViewPointer().Hide();
     m_combobox_ATR_choice.GetButtonPointer().IsPressed(false);
    //--- No ATR available for this Symbol disable it.
     bool has_choice = (n > 0);
     if(has_choice)
      {
       m_buttonsGroup_SLMode.GetButtonPointer(1).Show();
       m_buttonsGroup_SLMode.GetButtonPointer(1).Moving();
      }
     else
      {
       m_buttonsGroup_SLMode.GetButtonPointer(1).Hide();
       m_combobox_ATR_choice.Hide();
       m_edit_ATR_Multiplexer.Hide();
      }
    return has_choice;
   }  
  void CGUIPannel::ToggleStopLostModeState(void)
   {
    bool is_fixed = ((ENUM_STOPLOST_TRAILING_MODE)m_buttonsGroup_SLMode.SelectedButtonIndex() == SL_MODE_FIXED);
    m_edit_StopLost_FixedPoint.Show();
    m_edit_StopLost_FixedPoint.Moving();
    m_edit_StopLost_FixedPoint.IsLocked(!is_fixed);
    m_label_StopLost_FixedUnit.Show();
    m_label_StopLost_FixedUnit.Moving();

    bool has_atr_choice = m_buttonsGroup_SLMode.GetButtonPointer(1).IsVisible();
    if(has_atr_choice)
     {
      m_combobox_ATR_choice.Show();
      m_combobox_ATR_choice.Moving();
      m_combobox_ATR_choice.IsLocked(is_fixed);
      m_edit_ATR_Multiplexer.Show();
      m_edit_ATR_Multiplexer.Moving();
      m_edit_ATR_Multiplexer.IsLocked(is_fixed);
      m_label_StopLost_ATRUnit.Show();
      m_label_StopLost_ATRUnit.Moving();
     }
    else
     {
      m_combobox_ATR_choice.Hide();
      m_edit_ATR_Multiplexer.Hide();
      m_label_StopLost_ATRUnit.Hide();
     }
   }  
  void CGUIPannel::UpdateStopLostPreview(void)
   {
    string symbol = m_string_StopLost_setting_current_symbol;
    string preview_text = "-";
    if((ENUM_STOPLOST_TRAILING_MODE)m_buttonsGroup_SLMode.SelectedButtonIndex() == SL_MODE_FIXED)
     {
      preview_text = m_edit_StopLost_FixedPoint.GetValue() + " pts";
     }
    else
     {
      double mult = ::StringToDouble(m_edit_ATR_Multiplexer.GetValue());
     //--- Local only (Anhnt, 2026-09-03) - parse straight off the combobox's own currently
     //--- selected text ("ATR(14) M1") instead of a parallel tf[]/period[] lookup array; the
     //--- combobox already IS the single source of truth for what's currently selected.
      string sel_text = m_combobox_ATR_choice.GetValue();
      int    lp        = ::StringFind(sel_text, "(");
      int    rp        = ::StringFind(sel_text, ")");
      if(lp >= 0 && rp > lp && m_IndicatorsCollection != NULL)
       {
        int             period = (int)::StringToInteger(::StringSubstr(sel_text, lp + 1, rp - lp - 1));
        ENUM_TIMEFRAMES tf     = TimestampByDescription(::StringSubstr(sel_text, rp + 2));
        CArrayObj *ind_list = m_IndicatorsCollection.GetListIndBySymbol(symbol);
        ind_list = CTimeseriesSelect::ByIndicatorProperty(ind_list, INDICATOR_PROP_TIMEFRAME, tf, EQUAL);
        int total = (ind_list != NULL) ? ind_list.Total() : 0;
        for(int i = 0; i < total; i++)
         {
          CIndicatorDE *cand = ind_list.At(i);
          if(cand == NULL || cand.TypeIndicator() != IND_ATR) continue;
         //--- RAW identity match (Anhnt, 2026-09-03) - project-wide convention for indicator
         //--- identity is TypeEnum()+IsEqualMqlParamArrays(), never a hand-picked param field.
          MqlParam raw_params[1];
          raw_params[0].type          = TYPE_INT;
          raw_params[0].integer_value = period;
          MqlParam cand_params[];
          cand.GetMqlParams(cand_params);
          if(!IsEqualMqlParamArrays(cand_params, raw_params)) continue;
          double v0    = cand.GetDataBuffer(0, 0);
          double point = ::SymbolInfoDouble(symbol, SYMBOL_POINT);
          if(v0 != EMPTY_VALUE && point > 0)
             preview_text = (string)(int)::MathRound(mult * (v0 / point)) + " Point";
          break;
         }
       }
     }
    m_label_StopLost_Preview.LabelText("Preview SL - " + preview_text);
    m_label_StopLost_Preview.Draw();
    m_label_StopLost_Preview.Update(true);
   }   
  int CGUIPannel::GetCurrentStopLostDistancePoints(const string symbol)
   {
    if(m_trading_setup_manager == NULL) return -1;
    CTradingSetupSetting *row_setting = m_trading_setup_manager.FindByIdentity(symbol);
    if(row_setting == NULL) return -1;
    if(row_setting.StopLostMode() == SL_MODE_FIXED)
       return row_setting.StopLostFixedPts();
    if(m_IndicatorsCollection == NULL) return -1;
    ENUM_TIMEFRAMES tf   = row_setting.StopLostIndTF();
    double          mult = row_setting.StopLostIndMultiplier();
    MqlParam raw_params[];
    row_setting.GetStopLostIndParams(raw_params);
    CArrayObj *ind_list = m_IndicatorsCollection.GetListIndBySymbol(symbol);
    ind_list = CTimeseriesSelect::ByIndicatorProperty(ind_list, INDICATOR_PROP_TIMEFRAME, tf, EQUAL);
    int total = (ind_list != NULL) ? ind_list.Total() : 0;
    for(int i = 0; i < total; i++)
     {
      CIndicatorDE *cand = ind_list.At(i);
      if(cand == NULL || cand.TypeIndicator() != row_setting.StopLostIndType()) continue;
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
  //| Formats the per-Symbol SL cache value for the table's SL (points) |
  //| column (Anhnt, 2026-09-01).                                        |
  //+------------------------------------------------------------------+
  string CGUIPannel::FormatStopLostCacheValue(const string symbol)
   {
    int distance_pts = GetCurrentStopLostDistancePoints(symbol);
    if(distance_pts < 0) return "-";
    return (string)distance_pts + " pts";
   }  
  double CGUIPannel::GetStopLostDistancePrice(const string symbol)
   {
    int distance_pts = GetCurrentStopLostDistancePoints(symbol);
    if(distance_pts < 0) return EMPTY_VALUE;
    CSymbol *sym = (m_symbol_collection != NULL) ? m_symbol_collection.GetSymbolObjByName(symbol) : NULL;
    double point = (sym != NULL) ? sym.Point() : ::SymbolInfoDouble(symbol, SYMBOL_POINT);
    if(point <= 0) return EMPTY_VALUE;
    return distance_pts * point;
   }  
  double CGUIPannel::GetStopLostMoneyValue(const string symbol)
   {
    int distance_pts = GetCurrentStopLostDistancePoints(symbol);
    if(distance_pts < 0) return EMPTY_VALUE;
    CSymbol *sym = (m_symbol_collection != NULL) ? m_symbol_collection.GetSymbolObjByName(symbol) : NULL;
    if(sym == NULL) return EMPTY_VALUE;
    return distance_pts * sym.TradeTickValue() * sym.LotsMin();
   }
#endif // CGUIPANNEL_SETTINGWINDOWS_TRADINGSTOPLOST_MQH_IMPLEMENTATION

