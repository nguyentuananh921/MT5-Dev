//+------------------------------------------------------------------+
//|                                        GUIPannel_TabPosition.mqh |
//+------------------------------------------------------------------+
#ifndef CGUIPANNEL_TABPOSITION_MQH
#define CGUIPANNEL_TABPOSITION_MQH
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
 //| (same sort convention as PopulateSymbolTFTree), default-selects   |
 //| the current chart symbol.                                        |
 //+------------------------------------------------------------------+
 bool CGUIPannel::CreatePreTradePlanSymbolCombo(const int x, const int y)
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
 //| Pre-trade-plan order-setup controls - Distance mode+value and    |
 //| Lot mode+value, laid out in ONE horizontal row (Anhnt 2026-07-20,|
 //| per user request "dàn hàng ngang" instead of the mockup's        |
 //| original stacked layout). ATR mode is a placeholder toggle only -|
 //| not wired to a real ATR series yet, falls back to the Distance   |
 //| edit's own value either way (see SetValuesToPreTradePlanTable).  |
 //+------------------------------------------------------------------+
 bool CGUIPannel::CreatePreTradePlanControls(const int x, const int y)
  {
   //--- "Dist" caption + Fixed/ATR toggle
    m_label_pre_trade_distance.MainPointer(m_tabs_main);
    m_tabs_main.AddToElementsArray(TAB_TAB_MAIN_POSITIONS, m_label_pre_trade_distance);
    m_label_pre_trade_distance.XSize(28);
    if(!m_label_pre_trade_distance.CreateTextLabel("Dist", x, y + 4)) return false;
    CWndContainer::AddToElementsArray(WindowIdx(m_window_main), m_label_pre_trade_distance);

    int dist_group_x = x + 28;
    m_group_pre_trade_distance_mode.MainPointer(m_tabs_main);
    m_tabs_main.AddToElementsArray(TAB_TAB_MAIN_POSITIONS, m_group_pre_trade_distance_mode);
    m_group_pre_trade_distance_mode.RadioButtonsMode(true);
    m_group_pre_trade_distance_mode.AddButton(0, 0, "Fixed", 45);
    m_group_pre_trade_distance_mode.AddButton(0, 0, "ATR", 45);
    if(!m_group_pre_trade_distance_mode.CreateButtonsGroup(dist_group_x, y)) return false;
    CWndContainer::AddToElementsArray(WindowIdx(m_window_main), m_group_pre_trade_distance_mode);

   //--- Distance value (points) - meaning is the same in both modes for now, ATR isn't
   //--- wired up to override it yet.
    int dist_edit_x = dist_group_x + 95;
    m_edit_pre_trade_distance_pts.MainPointer(m_tabs_main);
    m_tabs_main.AddToElementsArray(TAB_TAB_MAIN_POSITIONS, m_edit_pre_trade_distance_pts);
    m_edit_pre_trade_distance_pts.XSize(50);
    m_edit_pre_trade_distance_pts.GetTextBoxPointer().XGap(1);
    if(!m_edit_pre_trade_distance_pts.CreateTextEdit("100", dist_edit_x, y)) return false;
    CWndContainer::AddToElementsArray(WindowIdx(m_window_main), m_edit_pre_trade_distance_pts);

   //--- "Lot" caption + By Distance(manual)/By Risk % toggle
    int lot_label_x = dist_edit_x + 60;
    m_label_pre_trade_lot.MainPointer(m_tabs_main);
    m_tabs_main.AddToElementsArray(TAB_TAB_MAIN_POSITIONS, m_label_pre_trade_lot);
    m_label_pre_trade_lot.XSize(25);
    if(!m_label_pre_trade_lot.CreateTextLabel("Lot", lot_label_x, y + 4)) return false;
    CWndContainer::AddToElementsArray(WindowIdx(m_window_main), m_label_pre_trade_lot);

    int lot_group_x = lot_label_x + 25;
    m_group_pre_trade_lot_mode.MainPointer(m_tabs_main);
    m_tabs_main.AddToElementsArray(TAB_TAB_MAIN_POSITIONS, m_group_pre_trade_lot_mode);
    m_group_pre_trade_lot_mode.RadioButtonsMode(true);
    m_group_pre_trade_lot_mode.AddButton(0, 0, "By Distance", 80);
    m_group_pre_trade_lot_mode.AddButton(0, 0, "By Risk %", 80);
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
 //+------------------------------------------------------------------+
 //| Pre-trade-plan order-setup table - one row per direction (row 0  |
 //| = Buy, row 1 = Sell), matching the agreed mockup layout (Dir /   |
 //| Entry / SL / Distance / Lot / Risk $ / Risk %). Values come from |
 //| CreatePreTradePlanControls' Distance/Lot mode+value controls -   |
 //| see SetValuesToPreTradePlanTable. Dir cell is still NOT wired to |
 //| send real orders yet (Anhnt 2026-07-20).                          |
 //+------------------------------------------------------------------+
 bool CGUIPannel::CreateTablePreTradePlan(const int x, const int y)
  {
    #define COLUMNS3_TOTAL 7
    #define ROWS3_TOTAL 2
    m_table_pre_Trade_plan.MainPointer(m_tabs_main);
    m_tabs_main.AddToElementsArray(TAB_TAB_MAIN_POSITIONS, m_table_pre_Trade_plan);
    int width[COLUMNS3_TOTAL];
    ::ArrayInitialize(width, 70);
    width[0] = 55; // Dir
    width[4] = 55; // Lot
    //--- Icon columns (Dir) must be ALIGN_LEFT or RedrawCell silently skips DrawImage
     ENUM_ALIGN_MODE align[COLUMNS3_TOTAL];
     ::ArrayInitialize(align, ALIGN_RIGHT);
     align[0] = ALIGN_LEFT;
     int text_x_offset[COLUMNS3_TOTAL];
     ::ArrayInitialize(text_x_offset, 5);
     text_x_offset[0] = 22; // clear the Dir icon, same convention as m_table_indicator_SymbolTFValue
     int image_x_offset[COLUMNS3_TOTAL];
     ::ArrayInitialize(image_x_offset, 3);
     int image_y_offset[COLUMNS3_TOTAL];
     ::ArrayInitialize(image_y_offset, 2);
     m_table_pre_Trade_plan.TableSize(COLUMNS3_TOTAL, ROWS3_TOTAL);
     m_table_pre_Trade_plan.ColumnsWidth(width);
     m_table_pre_Trade_plan.TextAlign(align);
     m_table_pre_Trade_plan.TextXOffset(text_x_offset);
     m_table_pre_Trade_plan.ImageXOffset(image_x_offset);
     m_table_pre_Trade_plan.ImageYOffset(image_y_offset);
     m_table_pre_Trade_plan.ShowHeaders(true);
     m_table_pre_Trade_plan.SelectableRow(false);
     m_table_pre_Trade_plan.AutoXResizeMode(true);
     m_table_pre_Trade_plan.AutoXResizeRightOffset(2);
     if(!m_table_pre_Trade_plan.CreateTable(x, y)) return false;
       string headers[COLUMNS3_TOTAL] = {"Dir", "Entry", "SL", "Distance", "Lot", "Risk $", "Risk %"};
       for(int i = 0; i < COLUMNS3_TOTAL; i++)
          m_table_pre_Trade_plan.SetHeaderText(i, headers[i]);
       for(int r = 0; r < ROWS3_TOTAL; r++)
          m_table_pre_Trade_plan.AddRow(r, r == ROWS3_TOTAL - 1);
     //--- Dir icon: same val_img set as m_table_indicator_SymbolTFValue's col 2 - row 0/Buy is
     //--- always the up arrow, row 1/Sell is always the down arrow (gray/index 2 unused here,
     //--- direction is fixed per row, not data-driven).
       uint dir_img[] = {IMAGE_RESOURCE_BMP16_ICONS8_RIGHT_UP_PNG,
                        IMAGE_RESOURCE_BMP16_ICONS8_RIGHT_DOWN_PNG,
                        IMAGE_RESOURCE_BMP16_CIRCLE_GRAY_BMP};
       m_table_pre_Trade_plan.SetImages(0, 0, dir_img);
       m_table_pre_Trade_plan.ChangeImage(0, 0, 0);
       m_table_pre_Trade_plan.SetValue(0, 0, " Buy");
       m_table_pre_Trade_plan.SetImages(0, 1, dir_img);
       m_table_pre_Trade_plan.ChangeImage(0, 1, 1);
       m_table_pre_Trade_plan.SetValue(0, 1, " Sell");
       CWndContainer::AddToElementsArray(WindowIdx(m_window_main), m_table_pre_Trade_plan);
       SetValuesToPreTradePlanTable(true);
       return true;
  }
 //+------------------------------------------------------------------+
 //| Live refresh for the pre-trade-plan table - Entry/SL track real  |
 //| Bid/Ask of the combo's selected symbol every tick; Distance/Lot  |
 //| now come from the real Distance/Lot mode+value controls (Anhnt   |
 //| 2026-07-20). ATR mode isn't wired to a real ATR series yet - it  |
 //| still just uses the Distance edit's own value either way. Risk   |
 //| $/% use the same lot-sizing formula as EA2.mq5's CalcLots.       |
 //+------------------------------------------------------------------+
 bool CGUIPannel::SetValuesToPreTradePlanTable(bool force = false)
  {
      string symbol = m_combo_pre_Trade_plan_symbol.GetValue();
      if(symbol == "") symbol = _Symbol;
      double bid    = ::SymbolInfoDouble(symbol, SYMBOL_BID);
      double ask    = ::SymbolInfoDouble(symbol, SYMBOL_ASK);
      double point  = ::SymbolInfoDouble(symbol, SYMBOL_POINT);
      int    digits = (int)::SymbolInfoInteger(symbol, SYMBOL_DIGITS);
      int    stops_level  = (int)::SymbolInfoInteger(symbol, SYMBOL_TRADE_STOPS_LEVEL);
      double dist_input   = ::StringToDouble(m_edit_pre_trade_distance_pts.GetValue());
      // --- Distance mode toggle (Fixed/ATR) read but not yet acted on - ATR needs a real ATR
      // --- series wired to this table, not built yet. Both modes use the edit's own value.
      int    distance_pts = (dist_input > 0) ? (int)dist_input : ((stops_level > 0) ? stops_level : 100);
      double tick_value  = ::SymbolInfoDouble(symbol, SYMBOL_TRADE_TICK_VALUE);
      double balance     = ::AccountInfoDouble(ACCOUNT_BALANCE);
      double lot_or_risk_input = ::StringToDouble(m_edit_pre_trade_lot_or_risk.GetValue());
      double lot;
      if(m_group_pre_trade_lot_mode.SelectedButtonIndex() == 1) // By Risk %
        {
         double risk_pct_target = (lot_or_risk_input > 0) ? lot_or_risk_input : 1.0;
         double risk_usd_target = balance * risk_pct_target / 100.0;
         double money_per_lot   = distance_pts * tick_value;
         lot = (money_per_lot > 0) ? risk_usd_target / money_per_lot : 0.01;
         double lot_step = ::SymbolInfoDouble(symbol, SYMBOL_VOLUME_STEP);
         double lot_min  = ::SymbolInfoDouble(symbol, SYMBOL_VOLUME_MIN);
         double lot_max  = ::SymbolInfoDouble(symbol, SYMBOL_VOLUME_MAX);
         if(lot_step > 0) lot = ::MathFloor(lot / lot_step) * lot_step;
         if(lot < lot_min) lot = lot_min;
         if(lot > lot_max) lot = lot_max;
        }
      else // By Distance (manual pick)
         lot = (lot_or_risk_input > 0) ? lot_or_risk_input : 0.01;
      double risk_usd = lot * distance_pts * tick_value;
      double risk_pct = (balance > 0) ? risk_usd / balance * 100.0 : 0.0;
      double entry[2], sl[2];
      entry[0] = ask; sl[0] = ask - distance_pts * point; // Buy
      entry[1] = bid; sl[1] = bid + distance_pts * point; // Sell
      static string s_entry[2], s_sl[2], s_dist[2], s_lot[2], s_risk_usd[2], s_risk_pct[2];
      bool any_changed = false;
      for(int row = 0; row < 2; row++)
        {
         string c_entry    = ::DoubleToString(entry[row], digits);
         string c_sl       = ::DoubleToString(sl[row], digits);
         string c_dist     = (string)distance_pts + " pts";
         string c_lot      = ::DoubleToString(lot, 2);
         string c_risk_usd = ::DoubleToString(risk_usd, 2);
         string c_risk_pct = ::DoubleToString(risk_pct, 2) + "%";
         if(force || c_entry    != s_entry[row])    { m_table_pre_Trade_plan.SetValue(1, row, c_entry,    0, true); s_entry[row]    = c_entry;    any_changed = true; }
         if(force || c_sl       != s_sl[row])       { m_table_pre_Trade_plan.SetValue(2, row, c_sl,       0, true); s_sl[row]       = c_sl;       any_changed = true; }
         if(force || c_dist     != s_dist[row])     { m_table_pre_Trade_plan.SetValue(3, row, c_dist,     0, true); s_dist[row]     = c_dist;     any_changed = true; }
         if(force || c_lot      != s_lot[row])      { m_table_pre_Trade_plan.SetValue(4, row, c_lot,      0, true); s_lot[row]      = c_lot;      any_changed = true; }
         if(force || c_risk_usd != s_risk_usd[row]) { m_table_pre_Trade_plan.SetValue(5, row, c_risk_usd, 0, true); s_risk_usd[row] = c_risk_usd; any_changed = true; }
         if(force || c_risk_pct != s_risk_pct[row]) { m_table_pre_Trade_plan.SetValue(6, row, c_risk_pct, 0, true); s_risk_pct[row] = c_risk_pct; any_changed = true; }
        }
      // --- Update(false), NOT Update(true) - true runs the full DrawTable()/AutoResizeColumns
      // --- repaint path, which given Entry/SL change on nearly every tick caused a full-table
      // --- flicker (Anhnt, 2026-07-20, reported "nháy điên cuồng"). Per-cell RedrawCell (via
      // --- SetValue's redraw=true above) + a cheap Update(false) is the same no-flicker pattern
      // --- SetValuesToPositionsTable already uses.
      if(any_changed) m_table_pre_Trade_plan.Update(false);
      return any_changed;
  }
 bool CGUIPannel::CreatePositionsTable(const int x_gap, const int y_gap)
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
      //--- Properties
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
       m_table_positions.AutoXResizeMode(true);
       m_table_positions.AutoYResizeMode(true);
       m_table_positions.AutoXResizeRightOffset(2);
       m_table_positions.AutoYResizeBottomOffset(2);
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
       string v8 = ::DoubleToString(DepositLoad(false, avg_price, symbols_name[r], pos_volume), 2) + "/" +
                   ::DoubleToString(DepositLoad(true, avg_price, symbols_name[r], pos_volume), 2) + "%";
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
#endif // CGUIPANNEL_TABPOSITION_MQH

