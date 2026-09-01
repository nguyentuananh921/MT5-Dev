//+------------------------------------------------------------------+
//|                           GUIPannel_MainWindows_TabPositions.mqh |
//+------------------------------------------------------------------+
#ifndef CGUIPANNEL_MAINWINDOWS_TABPOSITION_MQH
#define CGUIPANNEL_MAINWINDOWS_TABPOSITION_MQH
 #include "GUIPannel.mqh"
 //+------------------------------------------------------------------+
 //| Server-side info table (Anhnt 2026-08-31, renamed/repurposed from|
 //| the old Dir/Entry/SL/Distance/Lot/Risk plan table - Risk is OUR   |
 //| OWN calculation, not Server data, so it doesn't belong here; the  |
 //| plan/risk section moves to its own table later). 3 cols: Symbol  |
 //| (+active-chart icon, same convention as m_table_indicator_        |
 //| SymbolTFMonitor's col0 - clicking a Symbol cell switches this     |
 //| chart's own Symbol, see OnEvent's ON_CLICK_LIST_ITEM handling) |  |
 //| Mid (Bid+Ask)/2 - deliberately NOT raw Bid (Anhnt, 2026-08-31):   |
 //| Bid alone only serves the Buy side (Buy SL references Bid, Sell   |
 //| SL references Ask) - Mid ± Spread/2 gives BOTH Bid and Ask        |
 //| symmetrically, matching col2's Spread/2 | Spread/2 (icon-only     |
 //| header, IMAGE_RESOURCE_BMP16_SPREADRED_PNG, value in points).     |
 //| StopsLevel column dropped (Anhnt, 2026-08-31) - confirmed via     |
 //| debug Print to be a genuine 0 from this broker, not worth a       |
 //| dedicated column.                                                  |
 //+------------------------------------------------------------------+
 bool CGUIPannel::CreateTable_PreTradeServersideInfo(const int x, const int y)
  {
    #define COLUMNS3_TOTAL 5
    m_table_pre_Trade_serversideInfo.MainPointer(m_tabs_main);
    m_tabs_main.AddToElementsArray(TAB_TAB_MAIN_POSITIONS, m_table_pre_Trade_serversideInfo);
    // --- Col3 (SL) / Col4 (SL Value) added (Anhnt, 2026-09-01) - clicking the gear icon in
    // --- col3 opens m_window_StopLost_Setting scoped to that row's own Symbol (see OnEvent),
    // --- col4 shows the committed result after Save. Replaces the old standalone Symbol combo +
    // --- ButtonsGroup row entirely - this table's own row already carries the Symbol.
    int width[COLUMNS3_TOTAL]           = {90, 90, 70, 30, 80};
    ENUM_ALIGN_MODE align[COLUMNS3_TOTAL] = {ALIGN_LEFT, ALIGN_RIGHT, ALIGN_RIGHT, ALIGN_LEFT, ALIGN_RIGHT};
    int text_x_offset[COLUMNS3_TOTAL]   = {22, 5, 5, 5, 5}; // col0: clear the Symbol active-chart icon
    int image_x_offset[COLUMNS3_TOTAL]  = { 3, 3, 3, 5, 3};
    int image_y_offset[COLUMNS3_TOTAL]  = { 3, 3, 3, 3, 3};
     // --- Fixed viewport height (Anhnt, 2026-08-31) - without an explicit YSize(), CTable
     // --- auto-fills all the way down to the parent Tab's own bottom edge (InitializeProperties'
     // --- m_y_size<1 branch), regardless of actual row count - its mostly-empty canvas then sits
     // --- UNDER/behind m_table_positions (POSITIONS_TABLE_Y=175 below this), which is what looked
     // --- like the two tables overlapping. Row count here is DISTINCT SYMBOLS (grows with Market
     // --- Watch), unbounded in principle, so a fixed height + scrollbar (same as any other table
     // --- with more rows than fit) is the correct long-term shape, not a taller fixed value.
     m_table_pre_Trade_serversideInfo.YSize(POSITIONS_TABLE_Y - POSITIONS_PLAN_TABLE_Y - 5);
     // --- Fixed width too (Anhnt, 2026-08-31), same reasoning as YSize just above -
     // --- AutoXResizeMode(true) was filling the whole Tab's width instead of just the columns'
     // --- own sum (90+90+70+30+80=360) + room for the vertical scrollbar.
     m_table_pre_Trade_serversideInfo.XSize(360 + 20);
     m_table_pre_Trade_serversideInfo.TableSize(COLUMNS3_TOTAL, 20);
     m_table_pre_Trade_serversideInfo.ColumnsWidth(width);
     m_table_pre_Trade_serversideInfo.TextAlign(align);
     m_table_pre_Trade_serversideInfo.TextXOffset(text_x_offset);
     m_table_pre_Trade_serversideInfo.ImageXOffset(image_x_offset);
     m_table_pre_Trade_serversideInfo.ImageYOffset(image_y_offset);
     m_table_pre_Trade_serversideInfo.ShowHeaders(true);
     m_table_pre_Trade_serversideInfo.SelectableRow(true);
     m_table_pre_Trade_serversideInfo.LightsHover(true);
     m_table_pre_Trade_serversideInfo.IsSortMode(true);
     if(!m_table_pre_Trade_serversideInfo.CreateTable(x, y)) return false;
       m_table_pre_Trade_serversideInfo.SetHeaderText(0, "Symbol");
       m_table_pre_Trade_serversideInfo.SetHeaderText(1, "Mid");
       uint spread_header_img[] = {IMAGE_RESOURCE_BMP16_SPREADRED_PNG};
       m_table_pre_Trade_serversideInfo.SetHeaderText(2, "");
       m_table_pre_Trade_serversideInfo.SetHeaderImage(2, spread_header_img);
       uint sl_header_img[] = {IMAGE_RESOURCE_BMP16_STOPLOSTRED_PNG};
       m_table_pre_Trade_serversideInfo.SetHeaderText(3, "");
       m_table_pre_Trade_serversideInfo.SetHeaderImage(3, sl_header_img);
       m_table_pre_Trade_serversideInfo.SetHeaderText(4, "SL Value");
       CWndContainer::AddToElementsArray(WindowIdx(m_window_main), m_table_pre_Trade_serversideInfo);
       SyncTable_PreTradeServersideInfo(true);
       return true;
  }
 //+------------------------------------------------------------------+
 //| Live refresh for m_table_pre_Trade_serversideInfo (Anhnt 2026-08- |
 //| 31). One row per DISTINCT symbol from CSymbolsCollection (Layer 1,|
 //| m_symbol_collection) union the native Market Watch list - per the |
 //| "triệt để tận dụng method của Library" instruction, every value   |
 //| is read through CSymbol's own methods (Bid/Ask/Point/Digits) via  |
 //| GetSymbolObjByName(); ::SymbolInfoXxx() is only a fallback for a  |
 //| Market-Watch-only symbol that has no CSymbol object yet.          |
 //| Price/Spread2 each color green/red/gray on change, same up/down/  |
 //| flat convention as SetValuesToTable_IndicatorSymbolTFMonitor's    |
 //| Value column.                                                     |
 //+------------------------------------------------------------------+
 bool CGUIPannel::SyncTable_PreTradeServersideInfo(bool force = false)
  {
   if(m_symbol_collection == NULL) return false;
   // --- Distinct Symbol list: CSymbolsCollection (Layer 1) union native Market Watch, deduped,
   // --- sorted alphabetically.
    string all_syms[];
    int count = 0;
    int col_total = m_symbol_collection.GetSymbolsCollectionTotal();
    CArrayObj *col_list = m_symbol_collection.GetList();
    for(int i = 0; i < col_total; i++)
     {
      CSymbol *s = col_list.At(i);
      if(s == NULL) continue;
      string nm = s.Name();
      bool dup = false;
      for(int j = 0; j < count; j++) if(all_syms[j] == nm) { dup = true; break; }
      if(!dup) { ::ArrayResize(all_syms, count + 1); all_syms[count] = nm; count++; }
     }
    int mw_total = ::SymbolsTotal(true);
    for(int i = 0; i < mw_total; i++)
     {
      string nm = ::SymbolName(i, true);
      bool dup = false;
      for(int j = 0; j < count; j++) if(all_syms[j] == nm) { dup = true; break; }
      if(!dup) { ::ArrayResize(all_syms, count + 1); all_syms[count] = nm; count++; }
     }
    for(int a = 0; a < count - 1; a++)
     for(int b = a + 1; b < count; b++)
       if(all_syms[b] < all_syms[a]) { string t = all_syms[a]; all_syms[a] = all_syms[b]; all_syms[b] = t; }
    if(count == 0) return false;

   // --- Full rebuild when row count changes
   if(count != m_int_table_serversideInfo_table_row_count)
    {
     uint sym_img[] = {IMAGE_RESOURCE_BMP16_BAR_CHART_BMP, IMAGE_RESOURCE_BMP16_BAR_CHART_COLORLESS_BMP};
     m_table_pre_Trade_serversideInfo.DeleteAllRows();
     ::ArrayResize(m_string_serversideInfo_cache_symbol,       count);
     ::ArrayResize(m_double_serversideInfo_cache_price,        count);
     ::ArrayResize(m_int_serversideInfo_cache_price_dir,       count);
     ::ArrayResize(m_int_serversideInfo_cache_spread_half,     count);
     ::ArrayResize(m_int_serversideInfo_cache_spread_half_dir, count);
     ::ArrayResize(m_bool_serversideInfo_cache_active,         count);
     ::ArrayInitialize(m_double_serversideInfo_cache_price,        -1);
     ::ArrayInitialize(m_int_serversideInfo_cache_price_dir,        2);
     ::ArrayInitialize(m_int_serversideInfo_cache_spread_half,     -1);
     ::ArrayInitialize(m_int_serversideInfo_cache_spread_half_dir,  2);
     ::ArrayInitialize(m_bool_serversideInfo_cache_active,      false);
     for(int i = 0; i < count - 1; i++)
        m_table_pre_Trade_serversideInfo.AddRow(i, i == count - 2);
     for(int row = 0; row < count; row++)
      {
       string sym_name = all_syms[row];
       m_string_serversideInfo_cache_symbol[row] = sym_name;
       bool active = (sym_name == ::Symbol());
       m_bool_serversideInfo_cache_active[row] = active;
       m_table_pre_Trade_serversideInfo.SetImages(0, row, sym_img);
       m_table_pre_Trade_serversideInfo.ChangeImage(0, row, active ? 0 : 1);
       m_table_pre_Trade_serversideInfo.SetValue(0, row, sym_name);

       CSymbol *sym = m_symbol_collection.GetSymbolObjByName(sym_name);
       double bid    = (sym != NULL) ? sym.Bid()   : ::SymbolInfoDouble(sym_name, SYMBOL_BID);
       double ask    = (sym != NULL) ? sym.Ask()    : ::SymbolInfoDouble(sym_name, SYMBOL_ASK);
       double point  = (sym != NULL) ? sym.Point()  : ::SymbolInfoDouble(sym_name, SYMBOL_POINT);
       int    digits = (sym != NULL) ? sym.Digits() : (int)::SymbolInfoInteger(sym_name, SYMBOL_DIGITS);
       int    spread_half_pts = (point > 0) ? (int)::MathRound((ask - bid) / point / 2.0) : 0;
       double mid = (bid + ask) / 2.0;

       m_table_pre_Trade_serversideInfo.SetValue(1, row, ::DoubleToString(mid, digits));
       m_double_serversideInfo_cache_price[row] = mid;
       m_table_pre_Trade_serversideInfo.SetValue(2, row, (string)spread_half_pts);
       m_int_serversideInfo_cache_spread_half[row] = spread_half_pts;

       uint sl_gear_img[] = {IMAGE_RESOURCE_BMP16_SETTING_RED_PNG};
       m_table_pre_Trade_serversideInfo.SetImages(3, row, sl_gear_img);
       m_table_pre_Trade_serversideInfo.ChangeImage(3, row, 0);
       m_table_pre_Trade_serversideInfo.SetValue(4, row, FormatStopLostCacheValue(sym_name));
      }
     m_int_table_serversideInfo_table_row_count = count;
     m_table_pre_Trade_serversideInfo.Update(true);
     return true;
    }

   // --- Re-derive each symbol's current visual row (CTable's own sort can reorder rows) - Col0
   // --- (Symbol) text is never touched below, reliable post-sort identity key.
    int row_of[];
    ::ArrayResize(row_of, count);
    for(int i = 0; i < count; i++)
     {
      row_of[i] = -1;
      for(int row = 0; row < count; row++)
        if(m_table_pre_Trade_serversideInfo.GetValue(0, row) == all_syms[i]) { row_of[i] = row; break; }
     }

    bool any_changed = false;
    for(int i = 0; i < count; i++)
     {
      int row = row_of[i];
      if(row < 0) continue; // identity not found this tick - next full rebuild will resync
      string sym_name = all_syms[i];

      // --- Col0: active-chart icon
       bool active = (sym_name == ::Symbol());
       if(active != m_bool_serversideInfo_cache_active[row])
        {
         m_bool_serversideInfo_cache_active[row] = active;
         m_table_pre_Trade_serversideInfo.ChangeImage(0, row, active ? 0 : 1, true);
         any_changed = true;
        }

      CSymbol *sym = m_symbol_collection.GetSymbolObjByName(sym_name);
      double bid    = (sym != NULL) ? sym.Bid()   : ::SymbolInfoDouble(sym_name, SYMBOL_BID);
      double ask    = (sym != NULL) ? sym.Ask()    : ::SymbolInfoDouble(sym_name, SYMBOL_ASK);
      double point  = (sym != NULL) ? sym.Point()  : ::SymbolInfoDouble(sym_name, SYMBOL_POINT);
      int    digits = (sym != NULL) ? sym.Digits() : (int)::SymbolInfoInteger(sym_name, SYMBOL_DIGITS);
      int    spread_half_pts = (point > 0) ? (int)::MathRound((ask - bid) / point / 2.0) : 0;
      double mid = (bid + ask) / 2.0;

      // --- Col1 (Mid): green=up / red=down / gray=flat vs last written (Bid+Ask)/2
       double prev_mid = m_double_serversideInfo_cache_price[row];
       if(force || mid != prev_mid)
        {
         int dir = (prev_mid < 0) ? 2 : (mid > prev_mid) ? 0 : (mid < prev_mid) ? 1 : 2;
         color txt_clr = (dir == 0) ? C'0,160,0' : (dir == 1) ? C'200,0,0' : clrGray;
         m_table_pre_Trade_serversideInfo.SetValue(1, row, ::DoubleToString(mid, digits), 0, true);
         m_table_pre_Trade_serversideInfo.TextColor(1, row, txt_clr, true);
         m_double_serversideInfo_cache_price[row]  = mid;
         m_int_serversideInfo_cache_price_dir[row] = dir;
         any_changed = true;
        }

      // --- Col2 (Spread/2): same up/down/flat color convention
       int prev_spread = m_int_serversideInfo_cache_spread_half[row];
       if(force || spread_half_pts != prev_spread)
        {
         int dir = (prev_spread < 0) ? 2 : (spread_half_pts > prev_spread) ? 0 : (spread_half_pts < prev_spread) ? 1 : 2;
         color txt_clr = (dir == 0) ? C'0,160,0' : (dir == 1) ? C'200,0,0' : clrGray;
         m_table_pre_Trade_serversideInfo.SetValue(2, row, (string)spread_half_pts, 0, true);
         m_table_pre_Trade_serversideInfo.TextColor(2, row, txt_clr, true);
         m_int_serversideInfo_cache_spread_half[row]     = spread_half_pts;
         m_int_serversideInfo_cache_spread_half_dir[row] = dir;
         any_changed = true;
        }
     }
   if(any_changed) m_table_pre_Trade_serversideInfo.Update(false);
   return any_changed;
  }
 // ============================================================================
 // Positions Table (TAB_TAB_MAIN_POSITIONS) - ported VERBATIM from V1
 // (Anatoli Kazharski\GUIPannel.mqh), 2026-07-19, per user request: bring it over
 // as-is before any redesign against Layer 1 (CTradingEngine/CMarketCollection).
 // Deliberately still raw ::PositionsTotal()/::PositionGetX() loops, same as V1 -
 // NOT wired to CMarketCollection/CTradingSelect yet.
 // ============================================================================
 //+------------------------------------------------------------------+
 //| Create a position table                                          |
 //+------------------------------------------------------------------+
 //+------------------------------------------------------------------+
 //| Pre-trade-plan symbol picker - Market Watch symbols, alphabetical |
 //| (same sort convention as PopulateTreeView_SymbolTFSetting), default-selects   |
 //| the current chart symbol.                                        |
 //+------------------------------------------------------------------+
 bool CGUIPannel::CreateCombobox_PreTradeSymbolPlan(const int x, const int y)
  {
    m_combo_pre_Trade_plan_symbol.MainPointer(m_tabs_main);
    m_tabs_main.AddToElementsArray(TAB_TAB_MAIN_POSITIONS, m_combo_pre_Trade_plan_symbol);
    int mw_total = ::SymbolsTotal(true);
    string labels[];
    ::ArrayResize(labels, mw_total);
    for(int i = 0; i < mw_total; i++)
        labels[i] = ::SymbolName(i, true);
    for(int a = 0; a < mw_total - 1; a++)
        for(int b = a + 1; b < mw_total; b++)
          if(labels[b] < labels[a])
            { string tmp = labels[a]; labels[a] = labels[b]; labels[b] = tmp; }
    int selected = 0;
    for(int i = 0; i < mw_total; i++)
        if(labels[i] == _Symbol) { selected = i; break; }
    int combo_w = 150;
    m_combo_pre_Trade_plan_symbol.XSize(combo_w);
    m_combo_pre_Trade_plan_symbol.YSize(20);
    m_combo_pre_Trade_plan_symbol.ItemsTotal(mw_total);
    int list_h = 18 * mw_total + 4;
    if(list_h > 300) list_h = 300;
    m_combo_pre_Trade_plan_symbol.GetListViewPointer().YSize(list_h);
    m_combo_pre_Trade_plan_symbol.GetButtonPointer().XGap(1);
    m_combo_pre_Trade_plan_symbol.GetButtonPointer().XSize(combo_w);
    m_combo_pre_Trade_plan_symbol.GetButtonPointer().LabelYGap(4);
    m_combo_pre_Trade_plan_symbol.GetButtonPointer().IconYGap(3);
    if(!m_combo_pre_Trade_plan_symbol.CreateComboBox("", x, y)) return false;
    CWndContainer::AddToElementsArray(WindowIdx(m_window_main), m_combo_pre_Trade_plan_symbol);
    m_combo_pre_Trade_plan_symbol.GetListViewPointer().Rebuilding(mw_total);
    for(int i = 0; i < mw_total; i++)
        m_combo_pre_Trade_plan_symbol.SetValue(i, labels[i]);
    m_combo_pre_Trade_plan_symbol.SelectItem(selected);
    m_combo_pre_Trade_plan_symbol.GetListViewPointer().Update(true);
    return true;
  }
 //+------------------------------------------------------------------+
 //| SL Setting - Fixed/ATR mode toggle (Anhnt, 2026-09-01). See the  |
 //| m_buttonsGroup_SLMode declaration comment (GUIPannel.mqh) for    |
 //| the full rationale - a Symbol-scoped policy reused for both new  |
 //| orders and Applying SL to already-open Positions.                |
 //+------------------------------------------------------------------+
 bool CGUIPannel::CreateButtonsGroup_SLMode(const int x, const int y)
  {
    m_buttonsGroup_SLMode.MainPointer(m_tabs_main);
    m_tabs_main.AddToElementsArray(TAB_TAB_MAIN_POSITIONS, m_buttonsGroup_SLMode);
    m_buttonsGroup_SLMode.RadioButtonsMode(true);
   //--- x_gap is an ABSOLUTE per-button offset, NOT auto-accumulated (ButtonsGroup.mqh
   //--- CreateButtons(): x=m_buttons[i].XGap()) - passing (0,0) for every button stacks them
   //--- all on top of each other (confirmed bug, Anhnt 2026-09-01: "ATR" was drawn over
   //--- "Fixed", hiding it entirely). Must manually accumulate each button's own width.
    m_buttonsGroup_SLMode.AddButton(0, 0, "Fixed", 45);
    m_buttonsGroup_SLMode.AddButton(45, 0, "ATR", 45);
    if(!m_buttonsGroup_SLMode.CreateButtonsGroup(x, y)) return false;
    CWndContainer::AddToElementsArray(WindowIdx(m_window_main), m_buttonsGroup_SLMode);
   //--- CreateButtonsGroup() above already defaults m_selected_button_index to 0 ("Fixed") -
   //--- mirror that into our own state (Anhnt, 2026-09-01), same convention as m_current_sl_mode
   //--- being kept in sync by the ON_CLICK_GROUP_BUTTON handler in OnEvent from here on.
    m_current_sl_mode = SL_MODE_FIXED;
    return true;
  }
 //+------------------------------------------------------------------+
 //| Pre-trade-plan order-setup controls - Lot mode+value (Anhnt      |
 //| 2026-07-20). ORPHANED as of 2026-08-31 - nothing reads these     |
 //| controls now that m_table_pre_Trade_serversideInfo was           |
 //| repurposed to pure Server data, pending a separate Risk/Plan     |
 //| table (Anhnt, discussed 2026-08-31).                              |
 //+------------------------------------------------------------------+
 bool CGUIPannel::CreatePreTradePlanControls(const int x, const int y)
  {
   //--- "Lot" caption + By Distance(manual)/By Risk % toggle
    int lot_label_x = x;
    m_label_pre_trade_lot.MainPointer(m_tabs_main);
    m_tabs_main.AddToElementsArray(TAB_TAB_MAIN_POSITIONS, m_label_pre_trade_lot);
    m_label_pre_trade_lot.XSize(25);
    if(!m_label_pre_trade_lot.CreateTextLabel("Lot", lot_label_x, y + 4)) return false;
    CWndContainer::AddToElementsArray(WindowIdx(m_window_main), m_label_pre_trade_lot);

    int lot_group_x = lot_label_x + 25;
    m_group_pre_trade_lot_mode.MainPointer(m_tabs_main);
    m_tabs_main.AddToElementsArray(TAB_TAB_MAIN_POSITIONS, m_group_pre_trade_lot_mode);
    m_group_pre_trade_lot_mode.RadioButtonsMode(true);
   //--- x_gap is absolute, not accumulated - same bug/fix as m_buttonsGroup_SLMode above.
    m_group_pre_trade_lot_mode.AddButton(0, 0, "By Distance", 80);
    m_group_pre_trade_lot_mode.AddButton(80, 0, "By Risk %", 80);
    if(!m_group_pre_trade_lot_mode.CreateButtonsGroup(lot_group_x, y)) return false;
    CWndContainer::AddToElementsArray(WindowIdx(m_window_main), m_group_pre_trade_lot_mode);

   //--- Lot-or-Risk% value - same edit box, meaning switches with the toggle above
    int lot_edit_x = lot_group_x + 165;
    m_edit_pre_trade_lot_or_risk.MainPointer(m_tabs_main);
    m_tabs_main.AddToElementsArray(TAB_TAB_MAIN_POSITIONS, m_edit_pre_trade_lot_or_risk);
    m_edit_pre_trade_lot_or_risk.XSize(50);
    m_edit_pre_trade_lot_or_risk.GetTextBoxPointer().XGap(1);
    if(!m_edit_pre_trade_lot_or_risk.CreateTextEdit("0.01", lot_edit_x, y)) return false;
    CWndContainer::AddToElementsArray(WindowIdx(m_window_main), m_edit_pre_trade_lot_or_risk);
    return true;
  } 
 
 bool CGUIPannel::CreateTablePositions(const int x_gap, const int y_gap)
  {
      #define COLUMNS2_TOTAL 10
      #define ROWS2_TOTAL 1
      //--- Store the pointer to the parent tab and attach
       m_table_positions.MainPointer(m_tabs_main);
       m_tabs_main.AddToElementsArray(TAB_TAB_MAIN_POSITIONS, m_table_positions);
      //--- Array of column widths
       int width[COLUMNS2_TOTAL];
       ::ArrayInitialize(width, 75);
       width[0] = 90;
       width[1] = 63;
       width[2] = 60;
       width[5] = 60;
       width[8] = 90;
      //--- Array of text alignment in columns
       ENUM_ALIGN_MODE align[COLUMNS2_TOTAL];
       ::ArrayInitialize(align, ALIGN_CENTER);
       align[0] = ALIGN_LEFT;
      //--- Array of text offset along the X axis in the columns
       int text_x_offset[COLUMNS2_TOTAL];
       ::ArrayInitialize(text_x_offset, 21);
      //--- Array of column image offsets along the X axis
       int image_x_offset[COLUMNS2_TOTAL];
       ::ArrayInitialize(image_x_offset, 3);
      //--- Array of column image offsets along the Y axis
       int image_y_offset[COLUMNS2_TOTAL];
       ::ArrayInitialize(image_y_offset, 2);
      //--- Fixed viewport size (Anhnt, 2026-09-01), same reasoning as
      //--- m_table_pre_Trade_serversideInfo's own YSize/XSize fix - AutoXResizeMode/
      //--- AutoYResizeMode leave m_x_size/m_y_size unset, which InitializeProperties then
      //--- auto-fills to "rest of the parent Tab" rather than sizing to this table's own
      //--- content. The 10 columns above sum to 738px (wider than the ~550px panel itself),
      //--- so this table genuinely needs its own horizontal scrollbar regardless - explicit
      //--- XSize/YSize gives it a STABLE bounded viewport (with scrollbars for the overflow
      //--- in both directions) instead of a size CTable recalculates from the parent's own
      //--- edges, which is what let its header rendering land somewhere unpredictable
      //--- (the "CandleWindow smear" bug turned out to be this table's own squeezed header).
       int table_x_size = 520;
       int table_y_size = 150;
      //--- Properties
       m_table_positions.XSize(table_x_size);
       m_table_positions.YSize(table_y_size);
       m_table_positions.TableSize(COLUMNS2_TOTAL, ROWS2_TOTAL);
       m_table_positions.ColumnsWidth(width);
       m_table_positions.TextAlign(align);
       m_table_positions.TextXOffset(text_x_offset);
       m_table_positions.ImageXOffset(image_x_offset);
       m_table_positions.ImageYOffset(image_y_offset);
       m_table_positions.ShowHeaders(true);
       m_table_positions.IsSortMode(true);
       m_table_positions.SelectableRow(true);
       m_table_positions.ColumnResizeMode(true);
       m_table_positions.IsZebraFormatRows(clrWhiteSmoke);
      //--- Create a control element
       if(!m_table_positions.CreateTable(x_gap, y_gap))
          return(false);
      //--- Set the header titles
       string headers[COLUMNS2_TOTAL] = {"Symbol", "Positions", "Volume", "Buy Volume", "Sell Volume", "Profit", "Buy Profit", "Sell Profit", "Deposit Load", "Average Price"};
       for(int i = 0; i < COLUMNS2_TOTAL; i++)
          m_table_positions.SetHeaderText(i, headers[i]);
      //--- Add the object to the common array of object groups
       CWndContainer::AddToElementsArray(WindowIdx(m_window_main), m_table_positions);
       return(true);
  }
 //+------------------------------------------------------------------+
 //| Initialize the position table with current open positions        |
 //+------------------------------------------------------------------+
 void CGUIPannel::InitializePositionsTable(void)
  {
      //--- Get symbols of open positions
       string symbols_name[];
       int symbols_total = GetPositionsSymbols(symbols_name);
      //--- Delete all rows
       m_table_positions.DeleteAllRows();
      //--- Set the number of rows by the number of symbols
       for(int i = 0; i < symbols_total - 1; i++)
          m_table_positions.AddRow(i);
      //--- If there are positions
       if(symbols_total > 0)
         {
          //--- Array of images for buttons
           uint button_images[1] = {IMAGE_RESOURCE_BMP16_CLOSE_BLACK_BMP};
          //--- Set the type and images for each row
           for(uint row = 0; row < (uint)symbols_total; row++)
             {
              m_table_positions.CellType(0, row, CELL_BUTTON);
              m_table_positions.SetImages(0, row, button_images);
             }
          //--- Force fill all cells (bypass dirty-check after DeleteAllRows)
           SetValuesToPositionsTable(symbols_name, true);
         }
      //--- Update the table
       m_table_positions.Update(true);
  }
 //+------------------------------------------------------------------+
 //| Set the values in the position table                             |
 //+------------------------------------------------------------------+
 bool CGUIPannel::SetValuesToPositionsTable(string &symbols_name[], bool force = false)
  {
   uint symbols_total = ::ArraySize(symbols_name);
   uint rows_total = m_table_positions.RowsTotal();
   if(symbols_total < rows_total)
      return false;
   static uint s_prev_rows = 0;
   static string s_c0[], s_c1[], s_c2[], s_c3[], s_c4[];
   static string s_c5[], s_c6[], s_c7[], s_c8[], s_c9[];
   if(s_prev_rows != rows_total || force)
    {
      s_prev_rows = rows_total;
      ::ArrayResize(s_c0, rows_total);
      ::ArrayResize(s_c1, rows_total);
      ::ArrayResize(s_c2, rows_total);
      ::ArrayResize(s_c3, rows_total);
      ::ArrayResize(s_c4, rows_total);
      ::ArrayResize(s_c5, rows_total);
      ::ArrayResize(s_c6, rows_total);
      ::ArrayResize(s_c7, rows_total);
      ::ArrayResize(s_c8, rows_total);
      ::ArrayResize(s_c9, rows_total);
      for(uint i = 0; i < rows_total; i++)
         s_c0[i] = s_c1[i] = s_c2[i] = s_c3[i] = s_c4[i] =
         s_c5[i] = s_c6[i] = s_c7[i] = s_c8[i] = s_c9[i] = "";
    }
    bool any_changed = false;
    // Calculate values and set to table with dirty-check
     for(uint r = 0; r < rows_total; r++)
      {
       double pos_volume = PositionsVolumeTotal(symbols_name[r]);
       double buy_volume = PositionsVolumeTotal(symbols_name[r], POSITION_TYPE_BUY);
       double sell_volume = PositionsVolumeTotal(symbols_name[r], POSITION_TYPE_SELL);
       double pos_profit = PositionsFloatingProfitTotal(symbols_name[r]);
       double buy_profit = PositionsFloatingProfitTotal(symbols_name[r], POSITION_TYPE_BUY);
       double sell_profit = PositionsFloatingProfitTotal(symbols_name[r], POSITION_TYPE_SELL);
       double avg_price = PositionAveragePrice(symbols_name[r]);
       string v0 = symbols_name[r];
       string v1 = (string)PositionsTotal(symbols_name[r]);
       string v2 = ::DoubleToString(pos_volume, 2);
       string v3 = ::DoubleToString(buy_volume, 2);
       string v4 = ::DoubleToString(sell_volume, 2);
       string v5 = ::DoubleToString(pos_profit, 2);
       string v6 = ::DoubleToString(buy_profit, 2);
       string v7 = ::DoubleToString(sell_profit, 2);
       // --- DepositLoad() is gone (Anhnt, 2026-08-31 - see UpdateStatusBar's own switch, same
       // --- reasoning: trades may come from Mobile too, so this reads off the Library's own
       // --- CAccount via m_tradingEngine, not a hand-rolled AccountInfoDouble formula).
       // --- MarginForAction() -> native OrderCalcMargin(), correct for every instrument type,
       // --- not just the old formula's Forex-shaped math.
        CAccount *acc = (m_tradingEngine != NULL) ? m_tradingEngine.GetCurrentAccount() : NULL;
        double margin_val = (acc != NULL) ? acc.MarginForAction(ORDER_TYPE_BUY, symbols_name[r], pos_volume, avg_price) : 0.0;
        if(margin_val == EMPTY_VALUE) margin_val = 0.0;
        double margin_pct = (acc != NULL && acc.Balance() != 0.0) ? (margin_val / acc.Balance() * 100) : 0.0;
       string v8 = ::DoubleToString(margin_val, 2) + "/" + ::DoubleToString(margin_pct, 2) + "%";
       string v9 = ::DoubleToString(avg_price, (int)::SymbolInfoInteger(symbols_name[r], SYMBOL_DIGITS));
       if(v0 != s_c0[r])
        {
         s_c0[r] = v0;
         m_table_positions.SetValue(0, r, v0, 0, true);
         any_changed = true;
        }
       if(v1 != s_c1[r])
        {
         s_c1[r] = v1;
         m_table_positions.SetValue(1, r, v1, 0, true);
         any_changed = true;
        }
       if(v2 != s_c2[r])
        {
         s_c2[r] = v2;
         m_table_positions.SetValue(2, r, v2, 0, true);
         any_changed = true;
        }
       if(v3 != s_c3[r])
        {
         s_c3[r] = v3;
         m_table_positions.TextColor(3, r, (buy_volume > 0) ? clrBlack : clrLightGray);
         m_table_positions.SetValue(3, r, v3, 0, true);
         any_changed = true;
        }
       if(v4 != s_c4[r])
        {
         s_c4[r] = v4;
         m_table_positions.TextColor(4, r, (sell_volume > 0) ? clrBlack : clrLightGray);
         m_table_positions.SetValue(4, r, v4, 0, true);
         any_changed = true;
        }
       if(v5 != s_c5[r])
        {
         s_c5[r] = v5;
         m_table_positions.TextColor(5, r, (pos_profit != 0) ? (pos_profit > 0 ? clrGreen : clrRed) : clrLightGray);
         m_table_positions.SetValue(5, r, v5, 0, true);
         any_changed = true;
        }
       if(v6 != s_c6[r])
        {
         s_c6[r] = v6;
         m_table_positions.TextColor(6, r, (buy_profit != 0) ? (buy_profit > 0 ? clrGreen : clrRed) : clrLightGray);
         m_table_positions.SetValue(6, r, v6, 0, true);
         any_changed = true;
        }
       if(v7 != s_c7[r])
        {
         s_c7[r] = v7;
         m_table_positions.TextColor(7, r, (sell_profit != 0) ? (sell_profit > 0 ? clrGreen : clrRed) : clrLightGray);
         m_table_positions.SetValue(7, r, v7, 0, true);
         any_changed = true;
        }
       if(v8 != s_c8[r])
        {
         s_c8[r] = v8;
         m_table_positions.SetValue(8, r, v8, 0, true);
         any_changed = true;
        }
       if(v9 != s_c9[r])
        {
         s_c9[r] = v9;
         m_table_positions.SetValue(9, r, v9, 0, true);
         any_changed = true;
        }
      }
      if(any_changed)
         m_table_positions.Update(false);
      return any_changed;
  }
 //+------------------------------------------------------------------+
 //| Check a new trade on history                                     |
 //+------------------------------------------------------------------+
 bool CGUIPannel::IsLastDealTicket(void)
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
 //| Get symbols of open positions in the array                       |
 //+------------------------------------------------------------------+
 int CGUIPannel::GetPositionsSymbols(string &symbols_name[])
  {
    string symbols = "";
    //--- Go through the loop for the first time and get symbols of open positions
     int positions_total = ::PositionsTotal();
     for(int i = 0; i < positions_total; i++)
      {
       //--- Select a position and get its symbol
        string position_symbol = ::PositionGetSymbol(i);
       //--- If there is a symbol name
        if(position_symbol == "")
          continue;
       //--- If there is no such a string, add it
        if(::StringFind(symbols, position_symbol, 0) == WRONG_VALUE)
           ::StringAdd(symbols, (symbols == "") ? position_symbol : "," + position_symbol);
      }
    //--- Get string elements by separator
     ushort u_sep = ::StringGetCharacter(",", 0);
     int symbols_total = ::StringSplit(symbols, u_sep, symbols_name);
    //--- Return the number of symbols
     return(symbols_total);
  }
 //+------------------------------------------------------------------+
 //| Position average price                                           |
 //+------------------------------------------------------------------+
 double CGUIPannel::PositionAveragePrice(const string symbol)
  {
   //--- For calculating the average price
    double sum_mult = 0.0;
    double sum_volumes = 0.0;
   //--- Check if there is a position with specified properties
    int positions_total = ::PositionsTotal();
    for(int i = positions_total - 1; i >= 0; i--)
     {
      //--- If failed to select a position, go to the next one
       if(symbol != ::PositionGetSymbol(i))
          continue;
      //--- Get the price and position volume
       double pos_price = ::PositionGetDouble(POSITION_PRICE_OPEN);
       double pos_volume = ::PositionGetDouble(POSITION_VOLUME);
      //--- Sum up the intermediate indicators
       sum_mult += (pos_price * pos_volume);
       sum_volumes += pos_volume;
     }
    //--- Prevent division by zero
    if(sum_volumes <= 0)
       return(0.0);
    //--- Return the average price
    return(::NormalizeDouble(sum_mult / sum_volumes, (int)::SymbolInfoInteger(symbol, SYMBOL_DIGITS)));
  }
 //+------------------------------------------------------------------+
 //| Number of position trades with a specified symbol                |
 //+------------------------------------------------------------------+
 int CGUIPannel::PositionsTotal(const string symbol)
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
      //--- Increase the counter
       pos_counter++;
     }
    //--- Return the number of positions
    return(pos_counter);
  }
 //+------------------------------------------------------------------+
 //| Total volume of positions with the specified properties          |
 //+------------------------------------------------------------------+
 double CGUIPannel::PositionsVolumeTotal(const string symbol, const ENUM_POSITION_TYPE type = WRONG_VALUE)
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
 double CGUIPannel::PositionsFloatingProfitTotal(const string symbol, const ENUM_POSITION_TYPE type = WRONG_VALUE)
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
#endif // CGUIPANNEL_MAINWINDOWS_TABPOSITION_MQH

