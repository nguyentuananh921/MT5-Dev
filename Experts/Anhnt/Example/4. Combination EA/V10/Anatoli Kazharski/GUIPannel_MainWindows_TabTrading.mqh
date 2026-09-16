//+------------------------------------------------------------------+
//|                           GUIPannel_MainWindows_TabTrading.mqh |
//+------------------------------------------------------------------+
#ifndef CGUIPANNEL_MAINWINDOWS_TABTRADING_MQH
#define CGUIPANNEL_MAINWINDOWS_TABTRADING_MQH
 #include "GUIPannel.mqh"
 //+------------------------------------------------------------------+
 //| Create m_table_position_pretrade_view (TAB_TAB_MAIN_TRADING) -    | 
 //+------------------------------------------------------------------+
 bool CGUIPannel::CreateTable_PositionPretradeView(const int x, const int y)
  {
   m_table_position_pretrade_view.MainPointer(m_tabs_main);
   m_tabs_main.AddToElementsArray(TAB_TAB_MAIN_TRADING, m_table_position_pretrade_view);

   //  index:  0      1    2    3       4        5         6         7
   //  col:  SYMBOL  DIR  LOT SLTYPE  SLPRICE  SLPROFIT  TRAILTYPE  RISK
   //--- SLTYPE/TRAILTYPE narrowed to 20 (Anhnt, 2026-09-10) - pure 16px icon now, same width as DIR.
   //--- RISK widened to 70 - "-$1234.56"-sized values were getting clipped at 55. Moved to the very
   //--- last column, after TRAILTYPE (Anhnt, 2026-09-11).
    int width[COLUMNS_PRETRADE_VIEW_TOTAL] = {M_SYMBOL_WIDTH, 20, 55, 20, 65, 50, 20, 70};
    ENUM_ALIGN_MODE align[COLUMNS_PRETRADE_VIEW_TOTAL] =
     {
      ALIGN_LEFT, ALIGN_LEFT, ALIGN_RIGHT, ALIGN_LEFT, ALIGN_RIGHT, ALIGN_RIGHT, ALIGN_LEFT, ALIGN_RIGHT
     };
   int text_x_offset[COLUMNS_PRETRADE_VIEW_TOTAL];
   ::ArrayInitialize(text_x_offset, 5);
   text_x_offset[COL_PTV_SYMBOL]    = 22;   // clear the active-chart icon
   int image_x_offset[COLUMNS_PRETRADE_VIEW_TOTAL];
   ::ArrayInitialize(image_x_offset, 3);
   int image_y_offset[COLUMNS_PRETRADE_VIEW_TOTAL];
   ::ArrayInitialize(image_y_offset, 3);
   //--- TableSize(cols, 1) alone fully initializes this single fixed row (Table.mqh's own
   //--- TableSize() resizes+CellInitialize()s every cell) - no separate AddRow() needed, unlike
   //--- m_table_positions_StoplostAndTrailling's variable row count.
   m_table_position_pretrade_view.TableSize(COLUMNS_PRETRADE_VIEW_TOTAL, 1);
   m_table_position_pretrade_view.ColumnsWidth(width);
   m_table_position_pretrade_view.TextAlign(align);
   m_table_position_pretrade_view.TextXOffset(text_x_offset);
   m_table_position_pretrade_view.ImageXOffset(image_x_offset);
   m_table_position_pretrade_view.ImageYOffset(image_y_offset);
   m_table_position_pretrade_view.ShowHeaders(true);
   m_table_position_pretrade_view.SelectableRow(false);
   m_table_position_pretrade_view.IsSortMode(false);
   //--- AutoCorrectColumnsWidthMode turned back OFF (Anhnt/Claude, 2026-09-15) - it re-measures
   //--- every column's width on EVERY Update() call, even Update(false); SL Price/SL Profit/Risk$
   //--- change on nearly every tick (live Indicator values), so this table's Update(false) was
   //--- firing constantly, repositioning the Lot cell (CELL_COMBOBOX) mid-interaction and making
   //--- its dropdown hard to click/double-click. ColumnResizeMode(true) instead - lets the user
   //--- drag column borders by hand when they actually want to resize, without re-running on
   //--- every live-value tick. Also short-circuits AutoCorrectWidthColumns() on its own
   //--- (Table.mqh:1841 checks `|| m_column_resize_mode`), so this alone would have been enough.
   m_table_position_pretrade_view.ColumnResizeMode(true);
   //--- Symbol picked via an embedded combobox cell (Anhnt, 2026-09-10 - "cái combobox ấy chuyển
   //--- vào cột đầu tiên của Table") instead of the old standalone m_combobox_symbol_toTrade.
   //--- CellType(...,CELL_COMBOBOX) MUST be set BEFORE CreateTable() - the Library's shared
   //--- m_combobox widget is only constructed inside CreateTable() itself, gated on this flag
   //--- already being set (Table.mqh CreateCombobox/m_combobox_state) - setting it after CreateTable()
   //--- would flip the cell's type but leave no live widget to actually open on double-click.
   //--- Choice list sourced the same way the old combobox was (m_table_stoplostsetting's own rows),
   //--- default-selecting the current chart Symbol - same one-time-at-creation limitation the old
   //--- combobox had (never resynced if the tracked-Symbol set changes later).
    {
     int sym_total = (int)m_table_stoplostsetting.RowsTotal();
     if(sym_total > 0)
      {
       string sym_list[];
       ::ArrayResize(sym_list, sym_total);
       int chart_sym_idx = 0;
       for(int i = 0; i < sym_total; i++)
        {
         sym_list[i] = m_table_stoplostsetting.GetValue(0, i);
         if(sym_list[i] == ::Symbol()) chart_sym_idx = i;
        }
       m_table_position_pretrade_view.CellType(COL_PTV_SYMBOL, 0, CELL_COMBOBOX);
       m_table_position_pretrade_view.AddValueList(COL_PTV_SYMBOL, 0, sym_list, chart_sym_idx);
      }
    }
   //--- Lot - same CELL_COMBOBOX-before-CreateTable() requirement as Symbol above (Anhnt, 2026-09-10 -
   //--- "chúng ta làm tương tự với m_combobox_lot_toTrade... ngay sau cột Dir"). Real choice list
   //--- (Min..Max stepped by the Symbol's own LotsStep, or Min..risk-based-max when "Use Risk % Per
   //--- Trade" is checked) gets built in SyncTable_PositionPretradeView once Symbol/risk state is
   //--- known - this is just a placeholder single-entry list so the cell has SOMETHING valid to show
   //--- before the first real Sync pass runs.
    {
     string lot_list[1] = {"0.01"};
     m_table_position_pretrade_view.CellType(COL_PTV_LOT, 0, CELL_COMBOBOX);
     m_table_position_pretrade_view.AddValueList(COL_PTV_LOT, 0, lot_list, 0);
    }
   if(!m_table_position_pretrade_view.CreateTable(x, y)) return false;
   m_table_position_pretrade_view.SetHeaderText(COL_PTV_SYMBOL, "Symbol");
    {
     uint dir_header_img[] = {IMAGE_RESOURCE_BMP16_ORDER_DIR_PNG};
     m_table_position_pretrade_view.SetHeaderText(COL_PTV_DIR, "");
     m_table_position_pretrade_view.SetHeaderImage(COL_PTV_DIR, dir_header_img);
     //--- Click-to-toggle Buy/Sell (Anhnt, 2026-09-10) - CELL_CHECKBOX auto-cycles the image index
     //--- for us on click (Table.mqh CheckPressedCheckBox), same convention as COL_PST_SLTYPE/
     //--- COL_PST_TRAILTYPE's Fix/Ind toggle - single fixed row, safe to set once here rather than
     //--- every SyncTable_PositionPretradeView rebuild.
     m_table_position_pretrade_view.CellType(COL_PTV_DIR, 0, CELL_CHECKBOX);
    }
   m_table_position_pretrade_view.SetHeaderText(COL_PTV_LOT, "Lot");
    {
     uint sltype_header_img[] = {IMAGE_RESOURCE_BMP16_STOPLOSTRED_PNG};
     m_table_position_pretrade_view.SetHeaderText(COL_PTV_SLTYPE, "");
     m_table_position_pretrade_view.SetHeaderImage(COL_PTV_SLTYPE, sltype_header_img);
     //--- Click-to-toggle Fixed/Indicator (Anhnt, 2026-09-10 - "chỉ có 2 cái Icon như cột 2
     //--- Direction ấy") - pure icon toggle, no text, same CELL_CHECKBOX auto-cycle convention
     //--- as COL_PTV_DIR right above.
     m_table_position_pretrade_view.CellType(COL_PTV_SLTYPE, 0, CELL_CHECKBOX);
    }
   m_table_position_pretrade_view.SetHeaderText(COL_PTV_SLPRICE, "SL Price");
    {
     uint slprofit_header_img[] = {IMAGE_RESOURCE_BMP16_PROFIT_RED_PNG};
     m_table_position_pretrade_view.SetHeaderText(COL_PTV_SLPROFIT, "");
     m_table_position_pretrade_view.SetHeaderImage(COL_PTV_SLPROFIT, slprofit_header_img);
    }
    {
     uint trailtype_header_img[] = {IMAGE_RESOURCE_BMP16_TRAILLING_PNG};
     m_table_position_pretrade_view.SetHeaderText(COL_PTV_TRAILTYPE, "");
     m_table_position_pretrade_view.SetHeaderImage(COL_PTV_TRAILTYPE, trailtype_header_img);
     //--- Click-to-toggle Fixed/Indicator (Anhnt, 2026-09-10) - same pure icon toggle as
     //--- COL_PTV_SLTYPE right above.
     m_table_position_pretrade_view.CellType(COL_PTV_TRAILTYPE, 0, CELL_CHECKBOX);
    }
   //--- Real money at risk for the ACTUAL Lot picked in COL_PTV_LOT (Anhnt, 2026-09-10 - "với cái
   //--- giá như thế, với cái Lot như thế, với cái Lệnh Buy như thế thì chúng ta sẽ phải chấp nhận
   //--- một mức độ Lost như nào") - COL_PTV_SLPROFIT above stays the LotsMin()-based reference value.
   //--- Last column now (Anhnt, 2026-09-11 - "dịch cột Risk sang bên phải sau cột trailling").
   m_table_position_pretrade_view.SetHeaderText(COL_PTV_RISK, "Risk $");
   CWndContainer::AddToElementsArray(WindowIdx(m_window_main), m_table_position_pretrade_view);
   return true;
  }
 //+--------------------------------------------------------------------+
 //| Refresh the single row of m_table_position_pretrade_view - reads   |
 //| Symbol/Direction straight off the New Order form's own controls    |
 //| (same "read back off the control" convention as                    |
 //| SyncTable_PreTradeSymbolMonitor). No identity/row-count bookkeeping |
 //| needed since this table always has exactly one row.                 |
 //+------------------------------------------------------------------+
 bool CGUIPannel::SyncTable_PositionPretradeView(bool force = false)
  {
   static string s_scoped_symbol = "";
   static int    s_scoped_dir    = -1;
   static double s_sl_price_old  = EMPTY_VALUE;
   static double s_sl_profit_old = EMPTY_VALUE;
   static double s_risk_money_old = EMPTY_VALUE;
   static bool   s_sltype_old    = true;
   static bool   s_trailtype_old = true;
   static bool   s_use_risk_old  = false;
   static double s_risk_pct_old  = EMPTY_VALUE;

   string sym = GetNewOrderSymbol();
   ENUM_POSITION_TYPE type = m_new_order_is_buy ? POSITION_TYPE_BUY : POSITION_TYPE_SELL;
   if(sym == "")
      return false;   
   bool identity_changed = (force || sym != s_scoped_symbol);
   bool dir_changed      = ((int)type != s_scoped_dir);
   s_scoped_symbol = sym;
   s_scoped_dir    = (int)type;

   CTradingSetupSetting *row_setting = (m_trading_setup_manager != NULL) ? m_trading_setup_manager.FindByIdentity(sym) : NULL;
   bool sl_fixed    = (row_setting == NULL) || (row_setting.StopLostMode() == SL_MODE_FIXED);
   bool trail_fixed = (row_setting == NULL) || (row_setting.TrailingMode() == SL_MODE_FIXED);

   bool any_changed = false;
   if(identity_changed || sl_fixed != s_sltype_old)
    {
     s_sltype_old = sl_fixed;
     //--- Pure icon toggle now, no text (Anhnt, 2026-09-10) - grey=Fixed, indicator-icon=Indicator.
     uint sl_type_img[] = {IMAGE_RESOURCE_BMP16_STOPLOSTGREY_PNG, IMAGE_RESOURCE_BMP16_INDICATOR_BMP};
     m_table_position_pretrade_view.SetImages(COL_PTV_SLTYPE, 0, sl_type_img);
     m_table_position_pretrade_view.ChangeImage(COL_PTV_SLTYPE, 0, sl_fixed ? 0 : 1, true);
     any_changed = true;
    }
   if(identity_changed || trail_fixed != s_trailtype_old)
    {
     s_trailtype_old = trail_fixed;
     //--- Pure icon toggle now, no text (Anhnt, 2026-09-10) - Trailling-icon=Fixed, indicator-icon=Indicator.
     uint trail_type_img[] = {IMAGE_RESOURCE_BMP16_TRAILLING_PNG, IMAGE_RESOURCE_BMP16_INDICATOR_BMP};
     m_table_position_pretrade_view.SetImages(COL_PTV_TRAILTYPE, 0, trail_type_img);
     m_table_position_pretrade_view.ChangeImage(COL_PTV_TRAILTYPE, 0, trail_fixed ? 0 : 1, true);
     any_changed = true;
    }
   if(identity_changed)
    {
     bool active = (sym == ::Symbol());
     uint sym_img[] = {IMAGE_RESOURCE_BMP16_BAR_CHART_BMP, IMAGE_RESOURCE_BMP16_BAR_CHART_COLORLESS_BMP};
     m_table_position_pretrade_view.SetImages(COL_PTV_SYMBOL, 0, sym_img);
     m_table_position_pretrade_view.ChangeImage(COL_PTV_SYMBOL, 0, active ? 0 : 1, true);
     any_changed = true;
    }
   if(identity_changed || dir_changed)
    {
     //--- Redundant with CELL_CHECKBOX's own auto-cycle when this fires from a genuine click
     //--- (OnClickTogglePretradeDirection) - kept anyway so a Direction change from ANY other path
     //--- (e.g. a future Symbol-switch that also flips m_new_order_is_buy) stays correctly painted.
     uint dir_img[] = {IMAGE_RESOURCE_BMP16_ORDER_BUY_PNG, IMAGE_RESOURCE_BMP16_ORDER_SELL_PNG};
     m_table_position_pretrade_view.SetImages(COL_PTV_DIR, 0, dir_img);
     m_table_position_pretrade_view.ChangeImage(COL_PTV_DIR, 0, (type == POSITION_TYPE_BUY) ? 0 : 1, true);
     any_changed = true;
    }

   //--- Lot choice list: LotsMin..MaxLot stepped by LotsStep, disabled ("N/A") if unaffordable.
   //--- Rebuilt only when Symbol/Direction/risk inputs change (per-tick dirty-check).
   bool use_risk = m_checkbox_use_RiskPerNewTrade.IsPressed();
   //--- Reassert visibility every tick - CWndEvents' blanket Show() force-shows every registered
   //--- element on a window/tab reshow, silently undoing a one-time Hide(). Both early-return when
   //--- already in that state, so this is cheap to call unconditionally.
   if(use_risk) m_edit_RiskPerNewTrade.Show(); else m_edit_RiskPerNewTrade.Hide();
   int order_type_idx = (int)m_combobox_order_type.GetListViewPointer().SelectedItemIndex();
   if(order_type_idx != 0) m_edit_order_type_value.Show(); else m_edit_order_type_value.Hide();
   //--- Unchecked = reuse CalcMaxLotByRisk with risk_percent=100 ("mức tối đa của Balance").
   double risk_pct = use_risk ? ::StringToDouble(m_edit_RiskPerNewTrade.GetValue()) : 100.0;
   if(identity_changed || dir_changed || use_risk != s_use_risk_old || risk_pct != s_risk_pct_old)
    {
     s_use_risk_old = use_risk;
     s_risk_pct_old = risk_pct;
     CSymbol *lot_sym = (m_symbol_collection != NULL) ? m_symbol_collection.GetSymbolObjByName(sym) : NULL;
     double min_lot  = (lot_sym != NULL) ? lot_sym.LotsMin()  : 0.0;
     double step_lot = (lot_sym != NULL) ? lot_sym.LotsStep() : 0.0;
     //--- Use the same StopLost-only distance CalcMaxLotByRisk itself uses - Trailing may not even
     //--- be Active pre-trade, so the Trailing-aware preview distance would be the wrong basis here.
     double max_lot = (m_tradingEngine != NULL) ? m_tradingEngine.CalcMaxLotByRisk(sym, type, risk_pct) : 0.0;
     bool lot_enabled = (lot_sym != NULL) && step_lot > 0.0 && min_lot > 0.0 && max_lot >= min_lot;
     if(lot_enabled)
      {
       int lot_digits = (int)::MathMax(0.0, ::MathCeil(-::MathLog10(step_lot) - 0.0000001));
       int count = (int)::MathRound((max_lot - min_lot) / step_lot) + 1;
       if(count < 1)   count = 1;
       if(count > 200) count = 200;   // defensive cap - LotsMin..LotsMax can be a huge range on some symbols
       string lot_list[];
       ::ArrayResize(lot_list, count);
       for(int i = 0; i < count; i++)
        {
         double v = min_lot + i * step_lot;
         if(v > max_lot) v = max_lot;
         lot_list[i] = ::DoubleToString(v, lot_digits);
        }
       //--- Default index 0 = MinLot (Anhnt, 2026-09-11 - "để MaxLot thế này nguy hiểm quá"). If the
       //--- user already picked a Lot this session, restore its index instead so a Symbol/Direction/
       //--- Risk-checkbox change doesn't silently reset their choice back to MinLot every time.
       int default_idx = 0;
       if(m_new_order_lot_last > 0.0)
        {
         int nearest_idx = (int)::MathRound((m_new_order_lot_last - min_lot) / step_lot);
         if(nearest_idx >= 0 && nearest_idx < count) default_idx = nearest_idx;
        }
       //--- Explicit safety clamp (Anhnt/Claude, 2026-09-15) - CTable::AddValueList() silently
       //--- clamps an out-of-range selected_item UP to the LAST item (MaxLot), not down to the
       //--- first, if this ever went out of bounds (Table.mqh:1706). default_idx should already be
       //--- in range from the guard above, but never rely on that alone for something this
       //--- dangerous - clamp here explicitly too, and clamp DOWN toward MinLot on failure, never up.
       if(default_idx < 0 || default_idx >= count) default_idx = 0;
       m_table_position_pretrade_view.CellType(COL_PTV_LOT, 0, CELL_COMBOBOX);
       m_table_position_pretrade_view.AddValueList(COL_PTV_LOT, 0, lot_list, default_idx);
      }
     else
      {
       m_table_position_pretrade_view.CellType(COL_PTV_LOT, 0, CELL_SIMPLE);
       m_table_position_pretrade_view.SetValue(COL_PTV_LOT, 0, "N/A", 0, true);
      }
     any_changed = true;
    }

   int digits = (int)::SymbolInfoInteger(sym, SYMBOL_DIGITS);
   bool sl_price_from_trail;
   double sl_price  = (m_tradingEngine != NULL) ? m_tradingEngine.GetPreviewSLTargetPrice(sym, type, sl_price_from_trail) : EMPTY_VALUE;
   double sl_profit = (m_tradingEngine != NULL) ? m_tradingEngine.GetPreviewSLMoneyValue(sym, type) : EMPTY_VALUE;
   if(force || identity_changed || sl_price != s_sl_price_old)
    {
     int dir = (s_sl_price_old == EMPTY_VALUE || sl_price == EMPTY_VALUE) ? 2 : (sl_price > s_sl_price_old) ? 0 : (sl_price < s_sl_price_old) ? 1 : 2;
     color clr = identity_changed ? clrGray : (dir == 0) ? C'0,160,0' : (dir == 1) ? C'200,0,0' : clrGray;
     s_sl_price_old = sl_price;
     //--- "N/A" (not "-") when unavailable (Anhnt, 2026-09-10) - usually means Mode=Indicator with
     //--- no Indicator actually configured yet for this Symbol; "-" read as ambiguous ("no data yet").
     m_table_position_pretrade_view.SetValue(COL_PTV_SLPRICE, 0, (sl_price == EMPTY_VALUE) ? "N/A" : ::DoubleToString(sl_price, digits), 0, true);
     m_table_position_pretrade_view.TextColor(COL_PTV_SLPRICE, 0, clr, true);
     any_changed = true;
    }
   if(force || identity_changed || sl_profit != s_sl_profit_old)
    {
     int dir = (s_sl_profit_old == EMPTY_VALUE || sl_profit == EMPTY_VALUE) ? 2 : (sl_profit > s_sl_profit_old) ? 1 : (sl_profit < s_sl_profit_old) ? 0 : 2;
     color clr = identity_changed ? clrGray : (dir == 0) ? C'0,160,0' : (dir == 1) ? C'200,0,0' : clrGray;
     s_sl_profit_old = sl_profit;
     m_table_position_pretrade_view.SetValue(COL_PTV_SLPROFIT, 0, (sl_profit == EMPTY_VALUE) ? "N/A" : "-$" + ::DoubleToString(sl_profit, 2), 0, true);
     m_table_position_pretrade_view.TextColor(COL_PTV_SLPROFIT, 0, clr, true);
     any_changed = true;
    }
   //--- Real money at risk for the ACTUAL picked Lot (Anhnt, 2026-09-10) - "-" when the Lot combobox
   //--- itself is disabled ("N/A", GetNewOrderLot() reads back 0.0 from that text).
    {
     double actual_lot = GetNewOrderLot();
     double risk = (m_tradingEngine != NULL && actual_lot > 0.0) ? m_tradingEngine.GetPreviewSLMoneyValue(sym, type, actual_lot) : EMPTY_VALUE;
     if(force || identity_changed || risk != s_risk_money_old)
      {
       int dir = (s_risk_money_old == EMPTY_VALUE || risk == EMPTY_VALUE) ? 2 : (risk > s_risk_money_old) ? 1 : (risk < s_risk_money_old) ? 0 : 2;
       color clr = identity_changed ? clrGray : (dir == 0) ? C'0,160,0' : (dir == 1) ? C'200,0,0' : clrGray;
       s_risk_money_old = risk;
       m_table_position_pretrade_view.SetValue(COL_PTV_RISK, 0, (risk == EMPTY_VALUE) ? "N/A" : "-$" + ::DoubleToString(risk, 2), 0, true);
       m_table_position_pretrade_view.TextColor(COL_PTV_RISK, 0, clr, true);
       any_changed = true;
      }
    }
   //--- identity_changed uses Update(true) (full redraw) not Update(false) (Anhnt/Claude, 2026-09-09) -
   //--- CTable::ChangeImage() silently no-ops (never calls RedrawCell) whenever the requested image
   //--- index already equals the cell's default m_selected_image (0) - e.g. the Symbol cell's "active
   //--- chart" icon going active=true (index 0) right after SetImages() itself just reset
   //--- m_selected_image to 0. Update(false) only repaints cells RedrawCell already marked dirty, so
   //--- that transition would be silently skipped without the full Update(true).
   if(any_changed) m_table_position_pretrade_view.Update(identity_changed);
   return any_changed;
  }
 //+------------------------------------------------------------------+
 //| Create m_table_positions_StoplostAndTrailling (TAB_TAB_MAIN_TRADING)|
 //+------------------------------------------------------------------+
 bool CGUIPannel::CreateTable_PositionsStoplostAndTrailling(const int x, const int y)
  {
   m_table_positions_StoplostAndTrailling.MainPointer(m_tabs_main);
   m_tabs_main.AddToElementsArray(TAB_TAB_MAIN_TRADING, m_table_positions_StoplostAndTrailling);

   //  index:  0    1    2    3    4    5    6    7    8    9    10
   //  col:  SYMBOL DIR VOLUME NO SLTYPE SLPRICE SLPROFIT RUN_SL TRAILTYPE RUN_TRAIL PROFIT
   //--- SLTYPE/TRAILTYPE narrowed to 20 (Anhnt, 2026-09-10) - pure 16px icon now, same width as DIR.
    int width[COLUMNS_POS_SL_TRAIL_TOTAL]        = {M_SYMBOL_WIDTH, 20, 35, 30, 20, 65, 50, 20, 20, 20, 45};
   //--- Dir is ALIGN_LEFT (not CENTER) - icons only ever draw for ALIGN_LEFT columns
    ENUM_ALIGN_MODE align[COLUMNS_POS_SL_TRAIL_TOTAL] =
     {
      ALIGN_LEFT, ALIGN_LEFT, ALIGN_RIGHT, ALIGN_RIGHT,
      ALIGN_LEFT, ALIGN_RIGHT, ALIGN_RIGHT, ALIGN_LEFT,
      ALIGN_LEFT, ALIGN_LEFT, ALIGN_RIGHT
     };
   int text_x_offset[COLUMNS_POS_SL_TRAIL_TOTAL];
   ::ArrayInitialize(text_x_offset, 5);
   text_x_offset[COL_PST_SYMBOL]    = 22;   // clear the active-chart icon
   //--- COL_PST_DIR/COL_PST_SLTYPE/COL_PST_TRAILTYPE need no text offset override - icon-only columns now.
   int image_x_offset[COLUMNS_POS_SL_TRAIL_TOTAL];
   ::ArrayInitialize(image_x_offset, 3);
   int image_y_offset[COLUMNS_POS_SL_TRAIL_TOTAL];
   ::ArrayInitialize(image_y_offset, 3);
   m_table_positions_StoplostAndTrailling.TableSize(COLUMNS_POS_SL_TRAIL_TOTAL, 1);
   m_table_positions_StoplostAndTrailling.ColumnsWidth(width);
   m_table_positions_StoplostAndTrailling.TextAlign(align);
   m_table_positions_StoplostAndTrailling.TextXOffset(text_x_offset);
   m_table_positions_StoplostAndTrailling.ImageXOffset(image_x_offset);
   m_table_positions_StoplostAndTrailling.ImageYOffset(image_y_offset);
   m_table_positions_StoplostAndTrailling.ShowHeaders(true);
   m_table_positions_StoplostAndTrailling.SelectableRow(true);
   m_table_positions_StoplostAndTrailling.LightsHover(true);
   m_table_positions_StoplostAndTrailling.IsSortMode(false);
   //--- AutoCorrectColumnsWidthMode turned back OFF, same reasoning + fix as m_table_position_
   //--- pretrade_view (Anhnt/Claude, 2026-09-15) - this table has 5 narrow packed icon columns
   //--- (DIR/SLTYPE/RUN_SL/TRAILTYPE/RUN_TRAIL, 20px each) and SL Price/SL Profit/Profit change on
   //--- nearly every tick, so Update(false) was re-running AutoCorrectWidthColumns() constantly,
   //--- shifting those narrow columns' boundaries mid-click - a click aimed at SLTYPE (StopLost
   //--- mode) could land on the just-shifted TRAILTYPE (Trailing mode) instead, or vice versa.
   //--- ColumnResizeMode(true) instead - lets the user drag column borders by hand, and also
   //--- short-circuits AutoCorrectWidthColumns() on its own (Table.mqh:1841).
   m_table_positions_StoplostAndTrailling.ColumnResizeMode(true);
   if(!m_table_positions_StoplostAndTrailling.CreateTable(x, y)) return false;
   m_table_positions_StoplostAndTrailling.SetHeaderText(COL_PST_SYMBOL,    "Symbol");
    {
     uint dir_header_img[] = {IMAGE_RESOURCE_BMP16_ORDER_DIR_PNG};
     m_table_positions_StoplostAndTrailling.SetHeaderText(COL_PST_DIR, "");
     m_table_positions_StoplostAndTrailling.SetHeaderImage(COL_PST_DIR, dir_header_img);
    }
   m_table_positions_StoplostAndTrailling.SetHeaderText(COL_PST_VOLUME,    "Vol");
   m_table_positions_StoplostAndTrailling.SetHeaderText(COL_PST_NO,        "No");
   //--- Icon-only header (no text) to save width - body cells still show the checkbox + "Fix"/"Ind"   
    {
     uint sltype_header_img[] = {IMAGE_RESOURCE_BMP16_STOPLOSTRED_PNG};
     m_table_positions_StoplostAndTrailling.SetHeaderText(COL_PST_SLTYPE, "");
     m_table_positions_StoplostAndTrailling.SetHeaderImage(COL_PST_SLTYPE, sltype_header_img);
    }
   m_table_positions_StoplostAndTrailling.SetHeaderText(COL_PST_SLPRICE,   "SL Price");
    {
     uint slprofit_header_img[] = {IMAGE_RESOURCE_BMP16_PROFIT_RED_PNG};
     m_table_positions_StoplostAndTrailling.SetHeaderText(COL_PST_SLPROFIT, "");
     m_table_positions_StoplostAndTrailling.SetHeaderImage(COL_PST_SLPROFIT, slprofit_header_img);
    }
    {
     uint run_img[] = {IMAGE_RESOURCE_BMP16_RUN_PNG};
     m_table_positions_StoplostAndTrailling.SetHeaderText(COL_PST_RUN_SL, "");
     m_table_positions_StoplostAndTrailling.SetHeaderImage(COL_PST_RUN_SL, run_img);
    }
    {
     uint trailtype_header_img[] = {IMAGE_RESOURCE_BMP16_TRAILLING_PNG};
     m_table_positions_StoplostAndTrailling.SetHeaderText(COL_PST_TRAILTYPE, "");
     m_table_positions_StoplostAndTrailling.SetHeaderImage(COL_PST_TRAILTYPE, trailtype_header_img);
    }
    {
     uint run_img2[] = {IMAGE_RESOURCE_BMP16_RUN_PNG};
     m_table_positions_StoplostAndTrailling.SetHeaderText(COL_PST_RUN_TRAIL, "");
     m_table_positions_StoplostAndTrailling.SetHeaderImage(COL_PST_RUN_TRAIL, run_img2);
    }
    {
     uint profit_header_img[] = {IMAGE_RESOURCE_BMP16_PROFIT_GREY_PNG};
     m_table_positions_StoplostAndTrailling.SetHeaderText(COL_PST_PROFIT, "");
     m_table_positions_StoplostAndTrailling.SetHeaderImage(COL_PST_PROFIT, profit_header_img);
    }
   CWndContainer::AddToElementsArray(WindowIdx(m_window_main), m_table_positions_StoplostAndTrailling);
   return true;
  }
 bool CGUIPannel::SyncTable_PositionsStoplostAndTrailling(bool force = false)
  {
   string symbols[]; ENUM_POSITION_TYPE dirs[];
   int count = (m_market_collection != NULL) ? m_market_collection.GetDistinctSymbolsAndDirections(symbols, dirs) : 0;
   static string s_prev_keys[];
   static bool   s_active_old[];
   static double s_sl_price_old[];
   static double s_sl_profit_old[];
   static double s_profit_old[];
   static bool   s_sltype_old[];
   static bool   s_run_sl_old[];
   static bool   s_trailtype_old[];
   static bool   s_run_trail_old[];
   //--- Build this tick's key list up front - used both for the rebuild-or-not decision and,
   //--- on a full rebuild, as the row content itself.
    string keys[];
    ::ArrayResize(keys, count);
    for(int i = 0; i < count; i++)
       keys[i] = symbols[i] + "_" + (string)dirs[i];
   bool identity_changed = (::ArraySize(s_prev_keys) != count);
   if(!identity_changed)
     for(int i = 0; i < count; i++)
       if(s_prev_keys[i] != keys[i]) { identity_changed = true; break; }
   if(count == 0)
    {
     if(::ArraySize(s_prev_keys) != 0)
      {
       //--- DeleteAllRows() defaults to redraw=false - it resizes the canvas down to 1 row but never
       //--- repaints it, so the object showed blank instead of the header (Anhnt, 2026-09-10 - "cái
       //--- table nó cứ biến mất khi ko có position nào"). Every other branch in this function already
       //--- ends with Update(true)/Update(false); this was the one that didn't.
       m_table_positions_StoplostAndTrailling.DeleteAllRows();
       m_table_positions_StoplostAndTrailling.Update(true);
       ::ArrayResize(s_prev_keys, 0);
      }
     return false;
    }
   if(identity_changed || force)
    {
     uint sym_img[] = {IMAGE_RESOURCE_BMP16_BAR_CHART_BMP, IMAGE_RESOURCE_BMP16_BAR_CHART_COLORLESS_BMP};
     //--- Raw 0/1 index comparison below (NOT the CHECKBOX_STATE_ON/OFF named constants) - same
     //--- proven convention as CreateTable_IndicatorTemplateSetting/OnClickToggleBuySignal
     //--- (Anhnt, 2026-09-07: "chúng ta đã sửa được... giờ chỉ bắt chước thôi"). Index 0 = checked/true.
     uint dir_img[] = {IMAGE_RESOURCE_BMP16_ORDER_BUY_PNG, IMAGE_RESOURCE_BMP16_ORDER_SELL_PNG};
     //--- Run SL/Run Trail read-only status icon (Anhnt, 2026-09-10 - "Run" is now toggled ONLY via
     //--- m_checkbox_use_StopLostSetting/m_checkbox_use_TrailingSetting on the New Order form, not
     //--- clickable here anymore) - index 0 = running (colored), 1 = not running (gray).
     uint run_status_img[] = {IMAGE_RESOURCE_BMP16_START_BMP, IMAGE_RESOURCE_BMP16_START_GRAY_BMP};
     m_table_positions_StoplostAndTrailling.DeleteAllRows();
     ::ArrayResize(s_prev_keys,      count);
     ::ArrayResize(s_active_old,     count);
     ::ArrayResize(s_sl_price_old,   count);
     ::ArrayResize(s_sl_profit_old,  count);
     ::ArrayResize(s_profit_old,     count);
     ::ArrayResize(s_sltype_old,     count);
     ::ArrayResize(s_run_sl_old,     count);
     ::ArrayResize(s_trailtype_old,  count);
     ::ArrayResize(s_run_trail_old,  count);
     for(int i = 0; i < count - 1; i++)
        m_table_positions_StoplostAndTrailling.AddRow(i, i == count - 2);
     for(int row = 0; row < count; row++)
      {
       string sym  = symbols[row];
       ENUM_POSITION_TYPE type = dirs[row];
       s_prev_keys[row] = keys[row];
       bool active = (sym == ::Symbol());
       s_active_old[row] = active;
       m_table_positions_StoplostAndTrailling.SetImages(COL_PST_SYMBOL, row, sym_img);
       m_table_positions_StoplostAndTrailling.ChangeImage(COL_PST_SYMBOL, row, active ? 0 : 1);
       m_table_positions_StoplostAndTrailling.SetValue(COL_PST_SYMBOL, row, sym);
       //--- Icon only, no text (Anhnt, 2026-09-07: "thu gọn... không cần chữ ở cột này") - the
       //--- Buy/Sell icon alone already conveys Direction.
       m_table_positions_StoplostAndTrailling.SetImages(COL_PST_DIR, row, dir_img);
       m_table_positions_StoplostAndTrailling.ChangeImage(COL_PST_DIR, row, (type == POSITION_TYPE_BUY) ? 0 : 1);
       CArrayObj *pos_list_row = (m_market_collection != NULL) ? m_market_collection.GetPositionList(sym, type) : NULL;
       m_table_positions_StoplostAndTrailling.SetValue(COL_PST_VOLUME, row, ::DoubleToString((m_market_collection != NULL) ? m_market_collection.SumVolume(pos_list_row) : 0.0, 2));
       m_table_positions_StoplostAndTrailling.SetValue(COL_PST_NO, row, (string)((pos_list_row != NULL) ? pos_list_row.Total() : 0));

       CTradingSetupSetting *row_setting = (m_trading_setup_manager != NULL) ? m_trading_setup_manager.FindByIdentity(sym) : NULL;
       if(row_setting == NULL && m_trading_setup_manager != NULL)
          row_setting = m_trading_setup_manager.Add_TradingSetupSetting(sym);   // lazy-create, same as the StopLost Save handler
       bool sl_fixed    = (row_setting == NULL) || (row_setting.StopLostMode() == SL_MODE_FIXED);
       bool sl_active   = (row_setting != NULL) && row_setting.StopLostActive();
       bool trail_fixed = (row_setting == NULL) || (row_setting.TrailingMode() == SL_MODE_FIXED);
       bool trail_active= (row_setting != NULL) && row_setting.TrailingActive();
       s_sltype_old[row]    = sl_fixed;
       s_run_sl_old[row]    = sl_active;
       s_trailtype_old[row] = trail_fixed;
       s_run_trail_old[row] = trail_active;

       //--- Click-to-toggle Fixed/Indicator again (Anhnt, 2026-09-10 - "cứ Toggle giống hệt cái
       //--- cột" of m_table_position_pretrade_view's own SLTYPE) - pure icon, no text.
       uint sl_type_img[] = {IMAGE_RESOURCE_BMP16_STOPLOSTGREY_PNG, IMAGE_RESOURCE_BMP16_INDICATOR_BMP};
       m_table_positions_StoplostAndTrailling.CellType(COL_PST_SLTYPE, row, CELL_CHECKBOX);
       m_table_positions_StoplostAndTrailling.SetImages(COL_PST_SLTYPE, row, sl_type_img);
       m_table_positions_StoplostAndTrailling.ChangeImage(COL_PST_SLTYPE, row, sl_fixed ? 0 : 1);

       m_table_positions_StoplostAndTrailling.CellType(COL_PST_RUN_SL, row, CELL_BUTTON);
       m_table_positions_StoplostAndTrailling.SetImages(COL_PST_RUN_SL, row, run_status_img);
       m_table_positions_StoplostAndTrailling.ChangeImage(COL_PST_RUN_SL, row, sl_active ? 0 : 1);

       //--- Click-to-toggle again too (Anhnt, 2026-09-10) - same pure icon toggle as SLTYPE above.
       uint trail_type_img[] = {IMAGE_RESOURCE_BMP16_TRAILLING_PNG, IMAGE_RESOURCE_BMP16_INDICATOR_BMP};
       m_table_positions_StoplostAndTrailling.CellType(COL_PST_TRAILTYPE, row, CELL_CHECKBOX);
       m_table_positions_StoplostAndTrailling.SetImages(COL_PST_TRAILTYPE, row, trail_type_img);
       m_table_positions_StoplostAndTrailling.ChangeImage(COL_PST_TRAILTYPE, row, trail_fixed ? 0 : 1);

       m_table_positions_StoplostAndTrailling.CellType(COL_PST_RUN_TRAIL, row, CELL_BUTTON);
       m_table_positions_StoplostAndTrailling.SetImages(COL_PST_RUN_TRAIL, row, run_status_img);
       m_table_positions_StoplostAndTrailling.ChangeImage(COL_PST_RUN_TRAIL, row, trail_active ? 0 : 1);

       int digits = (int)::SymbolInfoInteger(sym, SYMBOL_DIGITS);
      //--- Real Positions exist here, so GetPreviewSLTargetPrice now returns the ACTUAL current SL
      //--- (not a recomputed target - see its own updated doc comment), and the money value uses the
      //--- REAL Volume, not LotsMin() (Anhnt, 2026-09-10 - "cột tương ứng cần hiển thị rằng với cái
      //--- giá đó nếu bị StopLost thì sẽ mất bao tiền").
       bool sl_price_from_trail;
       double sl_price   = m_tradingEngine.GetPreviewSLTargetPrice(sym, type, sl_price_from_trail);
      //--- Both SL Profit and Profit are now the SAME signed money-if-closed-at-sl_price value via
      //--- CMarketCollection::SumFloatingProfit(symbol,dir,price) overload (Anhnt/Claude, 2026-09-15 -
      //--- "Cái số ở đây phải khớp với nhau" - SL Profit used to call GetPreviewSLMoneyValue(), which
      //--- only reads Position #0's PriceOpen() while multiplying by the GROUP's total Volume, giving
      //--- a different/wrong number than Profit's own correct per-Position calc on the exact same row;
      //--- unified with the CArrayObj-list overload under one name, 2026-09-15).
       double sl_profit  = (sl_price != EMPTY_VALUE && m_market_collection != NULL) ? m_market_collection.SumFloatingProfit(sym, type, sl_price) : EMPTY_VALUE;
       double profit     = sl_profit;
       s_sl_price_old[row]  = sl_price;
       s_sl_profit_old[row] = sl_profit;
       s_profit_old[row]    = profit;
      //--- "N/A" (not "-") when unavailable (Anhnt, 2026-09-10) - usually Mode=Indicator with no
      //--- Indicator actually configured yet for this Symbol.
       m_table_positions_StoplostAndTrailling.SetValue(COL_PST_SLPRICE, row, (sl_price == EMPTY_VALUE) ? "N/A" : ::DoubleToString(sl_price, digits));
      //--- Signed - can be positive when Trailing already locked in profit, not
      //--- always a loss (Anhnt/Claude, 2026-09-15 - no more hardcoded "-$" prefix).
       m_table_positions_StoplostAndTrailling.SetValue(COL_PST_SLPROFIT, row, (sl_profit == EMPTY_VALUE) ? "N/A" : ::DoubleToString(sl_profit, 2));
       m_table_positions_StoplostAndTrailling.SetValue(COL_PST_PROFIT, row, (profit == EMPTY_VALUE) ? "N/A" : ::DoubleToString(profit, 2));
      }
     m_table_positions_StoplostAndTrailling.Update(true);
     return true;
    }
   //--- Steady state (same identity as last tick) - per-row dirty-check refresh only. Row index is
   //--- stable here (IsSortMode(false), and any identity change already took the rebuild branch above).
    bool any_changed = false;
    for(int row = 0; row < count; row++)
     {
      string sym = symbols[row];
      ENUM_POSITION_TYPE type = dirs[row];
      int digits = (int)::SymbolInfoInteger(sym, SYMBOL_DIGITS);
      //--- Col0 (Symbol) active-chart icon - re-checked every tick since switching the CHART's
      //--- Symbol (not the Position list) is what invalidates this, and that never touches
      //--- identity_changed above (Anhnt/Claude, 2026-09-08 - was missing entirely, icon went stale).
       bool active = (sym == ::Symbol());
       if(force || active != s_active_old[row])
        {
         s_active_old[row] = active;
         m_table_positions_StoplostAndTrailling.ChangeImage(COL_PST_SYMBOL, row, active ? 0 : 1, true);
         any_changed = true;
        }
      //--- Volume/No - cheap enough to just re-check every tick like Mid does elsewhere
       CArrayObj *pos_list_dirty = (m_market_collection != NULL) ? m_market_collection.GetPositionList(sym, type) : NULL;
       string v_vol = ::DoubleToString((m_market_collection != NULL) ? m_market_collection.SumVolume(pos_list_dirty) : 0.0, 2);
       if(force || v_vol != m_table_positions_StoplostAndTrailling.GetValue(COL_PST_VOLUME, row))
        {
         m_table_positions_StoplostAndTrailling.SetValue(COL_PST_VOLUME, row, v_vol, 0, true);
         any_changed = true;
        }
       string v_no = (string)((pos_list_dirty != NULL) ? pos_list_dirty.Total() : 0);
       if(force || v_no != m_table_positions_StoplostAndTrailling.GetValue(COL_PST_NO, row))
        {
         m_table_positions_StoplostAndTrailling.SetValue(COL_PST_NO, row, v_no, 0, true);
         any_changed = true;
        }
      //--- SL Type/Run/Trailling/Run - re-read from data in case the OTHER Setting Trading window
      //--- changed them while this tab is also visible (Single Source of Truth is CTradingSetupSetting,
      //--- not this table).
       CTradingSetupSetting *row_setting = (m_trading_setup_manager != NULL) ? m_trading_setup_manager.FindByIdentity(sym) : NULL;
       bool sl_fixed    = (row_setting == NULL) || (row_setting.StopLostMode() == SL_MODE_FIXED);
       bool sl_active   = (row_setting != NULL) && row_setting.StopLostActive();
       bool trail_fixed = (row_setting == NULL) || (row_setting.TrailingMode() == SL_MODE_FIXED);
       bool trail_active= (row_setting != NULL) && row_setting.TrailingActive();
       if(force || sl_fixed != s_sltype_old[row])
        {
         s_sltype_old[row] = sl_fixed;
         m_table_positions_StoplostAndTrailling.ChangeImage(COL_PST_SLTYPE, row, sl_fixed ? 0 : 1, true);
         any_changed = true;
        }
       if(force || sl_active != s_run_sl_old[row])
        {
         s_run_sl_old[row] = sl_active;
         m_table_positions_StoplostAndTrailling.ChangeImage(COL_PST_RUN_SL, row, sl_active ? 0 : 1, true);
         any_changed = true;
        }
       if(force || trail_fixed != s_trailtype_old[row])
        {
         s_trailtype_old[row] = trail_fixed;
         m_table_positions_StoplostAndTrailling.ChangeImage(COL_PST_TRAILTYPE, row, trail_fixed ? 0 : 1, true);
         any_changed = true;
        }
       if(force || trail_active != s_run_trail_old[row])
        {
         s_run_trail_old[row] = trail_active;
         m_table_positions_StoplostAndTrailling.ChangeImage(COL_PST_RUN_TRAIL, row, trail_active ? 0 : 1, true);
         any_changed = true;
        }
      //--- SL Price/SL Profit/Profit - green=up / red=down / gray=flat, same convention as
      //--- SyncTable_StopLostSetting's own Mid/Buy/Sell/SL Value columns. Best-of StopLost/Trailing
      //--- target (Anhnt/Claude, 2026-09-08), same as the full-rebuild branch above.
       double prev_sl_price = s_sl_price_old[row];
       bool   sl_price_from_trail;
       double sl_price = m_tradingEngine.GetPreviewSLTargetPrice(sym, type, sl_price_from_trail);
       if(force || sl_price != prev_sl_price)
        {
         int dir = (prev_sl_price == EMPTY_VALUE || sl_price == EMPTY_VALUE) ? 2 : (sl_price > prev_sl_price) ? 0 : (sl_price < prev_sl_price) ? 1 : 2;
         color clr = (dir == 0) ? C'0,160,0' : (dir == 1) ? C'200,0,0' : clrGray;
         s_sl_price_old[row] = sl_price;
         m_table_positions_StoplostAndTrailling.SetValue(COL_PST_SLPRICE, row, (sl_price == EMPTY_VALUE) ? "N/A" : ::DoubleToString(sl_price, digits), 0, true);
         m_table_positions_StoplostAndTrailling.TextColor(COL_PST_SLPRICE, row, clr, true);
         any_changed = true;
        }
      //--- SL Profit and Profit are the SAME signed value now (Anhnt/Claude, 2026-09-15 - "Cái số ở
      //--- đây phải khớp với nhau") - compute once, reuse for both columns' own dirty-checks below.
       double prev_sl_profit = s_sl_profit_old[row];
       double sl_profit = (sl_price != EMPTY_VALUE && m_market_collection != NULL) ? m_market_collection.SumFloatingProfit(sym, type, sl_price) : EMPTY_VALUE;
       if(force || sl_profit != prev_sl_profit)
        {
         int dir = (prev_sl_profit == EMPTY_VALUE || sl_profit == EMPTY_VALUE) ? 2 : (sl_profit > prev_sl_profit) ? 0 : (sl_profit < prev_sl_profit) ? 1 : 2;
         color clr = (dir == 0) ? C'0,160,0' : (dir == 1) ? C'200,0,0' : clrGray;
         s_sl_profit_old[row] = sl_profit;
         m_table_positions_StoplostAndTrailling.SetValue(COL_PST_SLPROFIT, row, (sl_profit == EMPTY_VALUE) ? "N/A" : ::DoubleToString(sl_profit, 2), 0, true);
         m_table_positions_StoplostAndTrailling.TextColor(COL_PST_SLPROFIT, row, clr, true);
         any_changed = true;
        }
       double prev_profit = s_profit_old[row];
       double profit = sl_profit;
       if(force || profit != prev_profit)
        {
         //--- No "first tick" sentinel needed here (unlike Mid's -1 init) - the full-rebuild branch
         //--- above always seeds s_profit_old[] with a real value before this per-tick branch ever runs.
         int dir = (profit > prev_profit) ? 0 : (profit < prev_profit) ? 1 : 2;
         color clr = (dir == 0) ? C'0,160,0' : (dir == 1) ? C'200,0,0' : clrGray;
         s_profit_old[row] = profit;
         m_table_positions_StoplostAndTrailling.SetValue(COL_PST_PROFIT, row, (profit == EMPTY_VALUE) ? "N/A" : ::DoubleToString(profit, 2), 0, true);
         m_table_positions_StoplostAndTrailling.TextColor(COL_PST_PROFIT, row, clr, true);
         any_changed = true;
        }
     }
   if(any_changed) m_table_positions_StoplostAndTrailling.Update(false);
   return any_changed;
  }
 //+------------------------------------------------------------------+
 //| StopLost type icon click (m_table_positions_StoplostAndTrailling, COL_PST_SLTYPE) - same pure  |
 //| icon toggle as m_table_position_pretrade_view's own OnClickTogglePretradeSLType (Anhnt,          |
 //| 2026-09-10 - "cứ Toggle giống hệt cái cột"), just scoped to this row's own Symbol instead of the  |
 //| New Order form's.                                                                                  |
 //+------------------------------------------------------------------+
 void CGUIPannel::OnClickTogglePositionSLType(const int row)
  {
   if(m_trading_setup_manager == NULL) return;
   string sym = m_table_positions_StoplostAndTrailling.GetValue(COL_PST_SYMBOL, row);
   if(sym == "") return;
   CTradingSetupSetting *row_setting = m_trading_setup_manager.FindByIdentity(sym);
   if(row_setting == NULL) row_setting = m_trading_setup_manager.Add_TradingSetupSetting(sym);
   if(row_setting == NULL) return;
   bool fixed = ((int)m_table_positions_StoplostAndTrailling.SelectedImageIndex(COL_PST_SLTYPE, row) == 0);
   row_setting.StopLostMode(fixed ? SL_MODE_FIXED : SL_MODE_INDICATOR);
   m_trading_setup_manager.NotifySettingChanged(sym);
   SyncTable_PositionsStoplostAndTrailling(true);
  }
 //+------------------------------------------------------------------+
 //| Trailing type icon click (m_table_positions_StoplostAndTrailling, COL_PST_TRAILTYPE) - same     |
 //| pure icon toggle as OnClickTogglePositionSLType right above.                                      |
 //+------------------------------------------------------------------+
 void CGUIPannel::OnClickTogglePositionTrailType(const int row)
  {
   if(m_trading_setup_manager == NULL) return;
   string sym = m_table_positions_StoplostAndTrailling.GetValue(COL_PST_SYMBOL, row);
   if(sym == "") return;
   CTradingSetupSetting *row_setting = m_trading_setup_manager.FindByIdentity(sym);
   if(row_setting == NULL) row_setting = m_trading_setup_manager.Add_TradingSetupSetting(sym);
   if(row_setting == NULL) return;
   bool fixed = ((int)m_table_positions_StoplostAndTrailling.SelectedImageIndex(COL_PST_TRAILTYPE, row) == 0);
   row_setting.TrailingMode(fixed ? SL_MODE_FIXED : SL_MODE_INDICATOR);
   m_trading_setup_manager.NotifySettingChanged(sym);
   SyncTable_PositionsStoplostAndTrailling(true);
  }
 bool CGUIPannel::CreateTradingForm(const int x_gap, const int y_gap)
  {   
    int row0_y = y_gap;                          // Symbol
    int row1_y = y_gap + M_CONTROL_YDISTANCE;    // Use SL Setting checkbox
    int row2_y = y_gap + 2*M_CONTROL_YDISTANCE;  // Use Trailing Setting checkbox
    int row3_y = y_gap + 3*M_CONTROL_YDISTANCE;  // Use Risk % Per Trade checkbox
    int row4_y = y_gap + 4*M_CONTROL_YDISTANCE;  // Risk % edit
    int row5_y = y_gap + 5*M_CONTROL_YDISTANCE;  // Order Type combobox
    int row6_y = y_gap + 6*M_CONTROL_YDISTANCE;  // Order Type Value edit (Limit/Stop/Stop Limit price)
    int row7_y = y_gap + 7*M_CONTROL_YDISTANCE;  // Send button
   // Symbol - read-only display now OnSymbolToTradeChanged whenever that cell's pick actually changes.
    m_textlabel_symbol_toTrade.MainPointer(m_tabs_main);
    m_tabs_main.AddToElementsArray(TAB_TAB_MAIN_TRADING, m_textlabel_symbol_toTrade);
    m_textlabel_symbol_toTrade.XSize(M_SYMBOL_WIDTH);
    m_textlabel_symbol_toTrade.YSize(M_CONTROL_HEIGHT);
    if(!m_textlabel_symbol_toTrade.CreateTextLabel(::Symbol(), x_gap, row0_y)) return false;
    CWndContainer::AddToElementsArray(WindowIdx(m_window_main), m_textlabel_symbol_toTrade);
   // Lot/Direction are embedded in m_table_position_pretrade_view now 
    m_new_order_is_buy = true;
   //--- Run SL - authoritative toggle for CTradingSetupSetting.StopLostActive() on whichever Symbol
   //--- is currently selected in m_combobox_symbol_toTrade (Anhnt, 2026-09-10 - "Mặc kệ ông trade ở
   //--- đâu... check vào cái checkbox ấy thì nó sẽ run hay không Run... áp luôn SL và Trailling với
   //--- cái Symbol có ở Combobox ở trên") - wired in OnClickRunSLOrTrailingCheckbox, not gated by an
   //--- existing Position (m_table_positions_StoplostAndTrailling's own Run columns are read-only now).
    m_checkbox_use_StopLostSetting.MainPointer(m_tabs_main);
    m_tabs_main.AddToElementsArray(TAB_TAB_MAIN_TRADING, m_checkbox_use_StopLostSetting);
   //--- CCheckBox defaults to YSize=14 (CheckBox.mqh:96), the one Library control that doesn't
   //--- match everything else's 20 - force M_CONTROL_HEIGHT so this row lines up with the rest.
    m_checkbox_use_StopLostSetting.YSize(M_CONTROL_HEIGHT);
   //--- CCheckBox also defaults to a narrow XSize that doesn't grow with caption length - the
   //--- longer captions below ("Use Trailing Setting"/"Use Risk % Per Trade") got clipped without
   //--- this (Anhnt, 2026-09-09).
    m_checkbox_use_StopLostSetting.XSize(M_SYMBOL_WIDTH);
    if(!m_checkbox_use_StopLostSetting.CreateCheckBox("Use StopLost", x_gap, row1_y)) return false;
    CWndContainer::AddToElementsArray(WindowIdx(m_window_main), m_checkbox_use_StopLostSetting);
   //--- CreateCanvas() (CheckBox.mqh) unconditionally sets the ON icon to CHECKBOX_ON_BMP, which
   //--- doesn't match the OFF icon's own "_G_" style (CHECKBOX_OFF_G_PNG) - the mismatch made the
   //--- 2 states hard to tell apart (Anhnt, 2026-09-04: "khó nhận biết trạng thái"). Override with
   //--- the matching ON_G_PNG AFTER CreateCheckBox(), since CreateCanvas() sets its default
   //--- unconditionally (setting this before creation would just get overwritten).
    m_checkbox_use_StopLostSetting.IconFilePressed(IMAGE_RESOURCE_BMP16_CHECKBOX_ON_G_PNG);
    m_checkbox_use_StopLostSetting.IsPressed(true);
   //--- Opens m_window_setting_trading on the StopLost tab - flush against the checkbox's own right edge.
    m_btn_open_StopLostSetting.MainPointer(m_tabs_main);
    m_tabs_main.AddToElementsArray(TAB_TAB_MAIN_TRADING, m_btn_open_StopLostSetting);
    m_btn_open_StopLostSetting.XSize(M_CONTROL_HEIGHT);
    m_btn_open_StopLostSetting.YSize(M_CONTROL_HEIGHT);
    if(!m_btn_open_StopLostSetting.CreateButton("", x_gap + M_SYMBOL_WIDTH + 13, row1_y)) return false;
    CWndContainer::AddToElementsArray(WindowIdx(m_window_main), m_btn_open_StopLostSetting);
    m_btn_open_StopLostSetting.IconFile(IMAGE_RESOURCE_BMP16_STOPLOSTRED_PNG);
   //--- Run Trailing - same convention as Run SL above, toggles TrailingActive().
    m_checkbox_use_TrailingSetting.MainPointer(m_tabs_main);
    m_tabs_main.AddToElementsArray(TAB_TAB_MAIN_TRADING, m_checkbox_use_TrailingSetting);
    m_checkbox_use_TrailingSetting.YSize(M_CONTROL_HEIGHT);
    m_checkbox_use_TrailingSetting.XSize(M_SYMBOL_WIDTH);
    if(!m_checkbox_use_TrailingSetting.CreateCheckBox("Use Trailing", x_gap, row2_y)) return false;
    CWndContainer::AddToElementsArray(WindowIdx(m_window_main), m_checkbox_use_TrailingSetting);
    m_checkbox_use_TrailingSetting.IconFilePressed(IMAGE_RESOURCE_BMP16_CHECKBOX_ON_G_PNG);
    m_checkbox_use_TrailingSetting.IsPressed(true);
   //--- Opens m_window_setting_trading on the Trailling tab.
    m_btn_open_TrailingSetting.MainPointer(m_tabs_main);
    m_tabs_main.AddToElementsArray(TAB_TAB_MAIN_TRADING, m_btn_open_TrailingSetting);
    m_btn_open_TrailingSetting.XSize(M_CONTROL_HEIGHT);
    m_btn_open_TrailingSetting.YSize(M_CONTROL_HEIGHT);
    if(!m_btn_open_TrailingSetting.CreateButton("", x_gap + M_SYMBOL_WIDTH + 13, row2_y)) return false;
    CWndContainer::AddToElementsArray(WindowIdx(m_window_main), m_btn_open_TrailingSetting);
    m_btn_open_TrailingSetting.IconFile(IMAGE_RESOURCE_BMP16_TRAILLING_PNG);
   //--- Use Risk % Per Trade checkbox + its edit box directly below - no separate caption label.
    m_checkbox_use_RiskPerNewTrade.MainPointer(m_tabs_main);
    m_tabs_main.AddToElementsArray(TAB_TAB_MAIN_TRADING, m_checkbox_use_RiskPerNewTrade);
    m_checkbox_use_RiskPerNewTrade.YSize(M_CONTROL_HEIGHT);
    m_checkbox_use_RiskPerNewTrade.XSize(M_SYMBOL_WIDTH);
    if(!m_checkbox_use_RiskPerNewTrade.CreateCheckBox("Use RPT %", x_gap, row3_y)) return false;
    CWndContainer::AddToElementsArray(WindowIdx(m_window_main), m_checkbox_use_RiskPerNewTrade);
    m_checkbox_use_RiskPerNewTrade.IconFilePressed(IMAGE_RESOURCE_BMP16_CHECKBOX_ON_G_PNG);
    m_checkbox_use_RiskPerNewTrade.IsPressed(false);
   // PerTrade Edit Control - directly below the checkbox, full M_SYMBOL_WIDTH now (no label sharing the row)
    m_edit_RiskPerNewTrade.MainPointer(m_tabs_main);
    m_tabs_main.AddToElementsArray(TAB_TAB_MAIN_TRADING, m_edit_RiskPerNewTrade);
    m_edit_RiskPerNewTrade.XSize(M_SYMBOL_WIDTH);
    m_edit_RiskPerNewTrade.YSize(M_CONTROL_HEIGHT);
    m_edit_RiskPerNewTrade.GetTextBoxPointer().XGap(1);
    if(!m_edit_RiskPerNewTrade.CreateTextEdit((string)RISK_PERCENTAGE_PERPOSITION, x_gap, row4_y)) return false;
    CWndContainer::AddToElementsArray(WindowIdx(m_window_main), m_edit_RiskPerNewTrade);
   //--- CreateTextEdit()'s text param doesn't populate the box - needs an explicit SetValue().
    m_edit_RiskPerNewTrade.SetValue((string)RISK_PERCENTAGE_PERPOSITION);
   //--- Starts hidden - only shown while "Use RPT %" is checked (OnClickUseRiskPerNewTradeCheckbox).
    m_edit_RiskPerNewTrade.Hide();
   //--- Order Type (Market/Limit/Stop/Stop Limit) - drives m_btn_send_toTrade + m_edit_order_type_value.
    m_combobox_order_type.MainPointer(m_tabs_main);
    m_tabs_main.AddToElementsArray(TAB_TAB_MAIN_TRADING, m_combobox_order_type);
    m_combobox_order_type.XSize(M_SYMBOL_WIDTH);
    m_combobox_order_type.YSize(M_CONTROL_HEIGHT);
    m_combobox_order_type.GetButtonPointer().XGap(1);
    m_combobox_order_type.GetButtonPointer().XSize(M_SYMBOL_WIDTH);
    if(!m_combobox_order_type.CreateComboBox("", x_gap, row5_y)) return false;
    CWndContainer::AddToElementsArray(WindowIdx(m_window_main), m_combobox_order_type);
    m_combobox_order_type.ItemsTotal(4);
    m_combobox_order_type.GetListViewPointer().Rebuilding(4);
    m_combobox_order_type.SetValue(0, "Market");
    m_combobox_order_type.SetValue(1, "Limit");
    m_combobox_order_type.SetValue(2, "Stop");
    m_combobox_order_type.SetValue(3, "Stop Limit");
    m_combobox_order_type.SelectItem(0);
    m_combobox_order_type.GetListViewPointer().Update(true);
    m_combobox_order_type.GetListViewPointer().Hide();
    m_combobox_order_type.GetButtonPointer().IsPressed(false);
   //--- Order Type Value (Limit/Stop price) - Show()/Hide() driven by UpdateSendButtonAppearance.
    m_edit_order_type_value.MainPointer(m_tabs_main);
    m_tabs_main.AddToElementsArray(TAB_TAB_MAIN_TRADING, m_edit_order_type_value);
    m_edit_order_type_value.XSize(M_SYMBOL_WIDTH);
    m_edit_order_type_value.YSize(M_CONTROL_HEIGHT);
    m_edit_order_type_value.GetTextBoxPointer().XGap(1);
    if(!m_edit_order_type_value.CreateTextEdit("0.0", x_gap, row6_y)) return false;
    CWndContainer::AddToElementsArray(WindowIdx(m_window_main), m_edit_order_type_value);
    m_edit_order_type_value.SetValue("0.0");   // CreateTextEdit()'s own text param doesn't populate it - see note above
    m_edit_order_type_value.Hide();            // Market is the default selection - starts hidden
   //--- Send button - color/text adapt to Direction+Order Type. Actual OrderSend wiring not done
   //--- yet - first draft, controls only.
    m_btn_send_toTrade.MainPointer(m_tabs_main);
    m_tabs_main.AddToElementsArray(TAB_TAB_MAIN_TRADING, m_btn_send_toTrade);
    m_btn_send_toTrade.XSize(M_SYMBOL_WIDTH);
    m_btn_send_toTrade.YSize(M_CONTROL_HEIGHT);
    if(!m_btn_send_toTrade.CreateButton("Buy", x_gap, row7_y)) return false;
    CWndContainer::AddToElementsArray(WindowIdx(m_window_main), m_btn_send_toTrade);
    UpdateSendButtonAppearance();
   return true;
  }
 void CGUIPannel::UpdateSendButtonAppearance(void)
  {
   int type_idx = (int)m_combobox_order_type.GetListViewPointer().SelectedItemIndex();
   bool is_buy = m_new_order_is_buy;
   string dir_text = is_buy ? "Buy" : "Sell";
   string type_suffix = "";
   switch(type_idx)
    {
     case 1: type_suffix = " Limit";      break;
     case 2: type_suffix = " Stop";       break;
     case 3: type_suffix = " Stop Limit"; break;
     default: break; // Market - no suffix
    }
   m_btn_send_toTrade.LabelText(dir_text + type_suffix);
   m_btn_send_toTrade.BackColor(is_buy ? C'0,160,0' : C'200,0,0'); // same green/red convention as
                                                                     // the Mid/Spread up-down colors
   m_btn_send_toTrade.Draw();
   m_btn_send_toTrade.Update(true);
   //--- Order Type Value only makes sense for a pending order, not Market (Anhnt, 2026-09-10 -
   //--- "chỉ xuất hiện khi chọn trên Combobox m_combobox_order_type không phải là Market").
   if(type_idx != 0)
      m_edit_order_type_value.Show();
   else
      m_edit_order_type_value.Hide();
  }
 //+------------------------------------------------------------------+
 //| m_table_indicator_PreTradeSymbolMonitor - same TF|Indicator|Value|Trailing shape as             |
 //| m_table_indicators_trailingsetting (Setting Trading window's Trailing tab), scoped to            |
 //| m_combobox_symbol_toTrade's current selection instead of a "Symbol - X" label (Anhnt/Claude,      |
 //| 2026-09-08). Lists EVERY indicator tracked for the Symbol via BuildSymbolIndicatorMonitorList     |
 //| (Anhnt/Claude, 2026-09-09 - NOT the Trailing-eligible-only subset, so ATR etc. still shows here   |
 //| for monitoring even though it can't be picked as a Trailing target).                              |
 //+------------------------------------------------------------------+
 bool CGUIPannel::CreateTable_PreTradeSymbolMonitor(const int x, const int y)
  {
   #define COLUMNS_PRETRADEMON_TOTAL 6
   m_table_indicator_PreTradeSymbolMonitor.MainPointer(m_tabs_main);
   m_tabs_main.AddToElementsArray(TAB_TAB_MAIN_TRADING, m_table_indicator_PreTradeSymbolMonitor);
   // Symbol|TF|Signal|Indicator|Value|StopLost|Trailing layout
   //--- StopLost/Trailing narrowed to 20 (Anhnt, 2026-09-11) - pure 16px icon, no text; offset 2
   //--- centers it ((20-16)/2), same width DIR-style icon-only columns use elsewhere.
   int width[COLUMNS_PRETRADEMON_TOTAL]           = {M_TF_WIDTH, 22, INDICATOR_PARATEXT_WIDTH, INDICATOR_VALUE_WIDTH, 20, 20};
   ENUM_ALIGN_MODE align[COLUMNS_PRETRADEMON_TOTAL] = {ALIGN_LEFT, ALIGN_LEFT, ALIGN_LEFT, ALIGN_RIGHT, ALIGN_LEFT, ALIGN_LEFT};
   int text_x_offset[COLUMNS_PRETRADEMON_TOTAL]   = {22, 5, 22, 5, 5, 5}; // col0/col2: clear their own icon
   int image_x_offset[COLUMNS_PRETRADEMON_TOTAL]  = {3, 3, 3, 0, 2, 2};
   int image_y_offset[COLUMNS_PRETRADEMON_TOTAL]  = {3, 3, 3, 0, 3, 3};
   m_table_indicator_PreTradeSymbolMonitor.YSize(TRADING_FORM_HEIGHT);
   int columns_width_total = 0;
   for(int c = 0; c < COLUMNS_PRETRADEMON_TOTAL; c++)
      columns_width_total += width[c];
   m_table_indicator_PreTradeSymbolMonitor.XSize(columns_width_total + 20);
   m_table_indicator_PreTradeSymbolMonitor.TableSize(COLUMNS_PRETRADEMON_TOTAL, 20);
   m_table_indicator_PreTradeSymbolMonitor.ColumnsWidth(width);
   m_table_indicator_PreTradeSymbolMonitor.TextAlign(align);
   m_table_indicator_PreTradeSymbolMonitor.TextXOffset(text_x_offset);
   m_table_indicator_PreTradeSymbolMonitor.ImageXOffset(image_x_offset);
   m_table_indicator_PreTradeSymbolMonitor.ImageYOffset(image_y_offset);
   m_table_indicator_PreTradeSymbolMonitor.ShowHeaders(true);
   m_table_indicator_PreTradeSymbolMonitor.SelectableRow(true);
   m_table_indicator_PreTradeSymbolMonitor.LightsHover(true);
   m_table_indicator_PreTradeSymbolMonitor.IsSortMode(true);
   if(!m_table_indicator_PreTradeSymbolMonitor.CreateTable(x, y)) return false;
   m_table_indicator_PreTradeSymbolMonitor.SetHeaderText(0, "TF");
   //--- Icon-only header, same SIGNAL_PNG icon as m_table_indicator_SymbolTFMonitor's own Col2.
    {
     uint signal_col_img[] = {IMAGE_RESOURCE_BMP16_SIGNAL_PNG};
     m_table_indicator_PreTradeSymbolMonitor.SetHeaderText(1, "");
     m_table_indicator_PreTradeSymbolMonitor.SetHeaderImage(1, signal_col_img);
    }
   m_table_indicator_PreTradeSymbolMonitor.SetHeaderText(2, "Indicator");
   m_table_indicator_PreTradeSymbolMonitor.SetHeaderText(3, "Value");   
    {
     uint sl_col_img[] = {IMAGE_RESOURCE_BMP16_STOPLOSTRED_PNG};
     m_table_indicator_PreTradeSymbolMonitor.SetHeaderText(4, "");
     m_table_indicator_PreTradeSymbolMonitor.SetHeaderImage(4, sl_col_img);
    }
    {
     uint trailling_col_img[] = {IMAGE_RESOURCE_BMP16_TRAILLING_PNG};
     m_table_indicator_PreTradeSymbolMonitor.SetHeaderText(5, "");
     m_table_indicator_PreTradeSymbolMonitor.SetHeaderImage(5, trailling_col_img);
    }
   CWndContainer::AddToElementsArray(WindowIdx(m_window_main), m_table_indicator_PreTradeSymbolMonitor);
   return true;
  }
 //+------------------------------------------------------------------+
 //| Every live CIndicatorDE instance tracked for the given Symbol      |
 //| (across every tracked TF) - NO Trend/1-buffer/StdDev filter, this  |
 //| is for general monitoring display (m_table_indicator_             |
 //| PreTradeSymbolMonitor), not Trailing-by-Indicator eligibility.     |
 //| Pure data, no GUI control touched - only ever consumed here (GUI), |
 //| so it lives directly on CGUIPannel using its own borrowed pointers,|
 //| not CTradingEngine (Anhnt/Claude, 2026-09-15 - moved back out of   |
 //| CTradingEngine, see [[project_v10_stoplost_trailing_engine_split]] |
 //| for where it lived before).                                       |
 //+------------------------------------------------------------------+
 int CGUIPannel::BuildSymbolIndicatorMonitorList(const string symbol, CIndicatorDE* &out_inds[], ENUM_TIMEFRAMES &out_tfs[])
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
   //--- Sort ascending by TF (M1 first) - same reasoning as BuildTrailingIndicatorChoiceList.
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
 //| TF cell click (m_table_indicator_PreTradeSymbolMonitor, col 0) -   |
 //| switches the active chart to this row's own (Symbol,TF) via        |
 //| CChartObjCollection::SetActiveChartSymbolTF() (Anhnt/Claude,        |
 //| 2026-09-15). Re-derives the row's real ENUM_TIMEFRAMES from the     |
 //| cell's own displayed text (IsSortMode(true) on this table means     |
 //| row index alone isn't a stable identity after a header-click sort - |
 //| same reasoning as OnCheckTable_IndicatorsTrailingSetting's own      |
 //| composite-key re-derivation elsewhere in this codebase) instead of  |
 //| trusting a stale per-row array.                                     |
 //+------------------------------------------------------------------+
 void CGUIPannel::OnClickNavigateToTF(const int row)
  {
   if(m_chart_obj_collection == NULL) return;
   string symbol = GetNewOrderSymbol();
   if(symbol == "") return;
   string tf_text = m_table_indicator_PreTradeSymbolMonitor.GetValue(0, row);
   CIndicatorDE   *inds[];
   ENUM_TIMEFRAMES tfs[];
   int count = BuildSymbolIndicatorMonitorList(symbol, inds, tfs);
   for(int i = 0; i < count; i++)
    {
     if(TimeframeDescription(tfs[i]) != tf_text) continue;
     m_chart_obj_collection.SetActiveChartSymbolTF(::ChartID(), symbol, tfs[i]);
     return;
    }
  }
 //+------------------------------------------------------------------+
 //| Full rebuild when the scoped Symbol changes or count changes, otherwise a per-tick dirty-check    |
 //| that touches Col0 (active-chart-TF icon), Col1 (Signal system, sticky last-known direction - same |
 //| GetOrCreateSignal()/HistoryDir() fallback as SynTable_IndicatorSymbolTFMonitor's own Col2), Col2   |
 //| (dir icon = raw value slope, prefixing the Indicator label) and Col3 (Value).                       |
 //+------------------------------------------------------------------+
 bool CGUIPannel::SyncTable_PreTradeSymbolMonitor(const string symbol, bool force = false)
  {
   static string s_scoped_symbol = "";
   static int    s_row_count = 0;
   static double s_val_old[];
   static int    s_dir_old[];
   static int    s_sig_old[];
   static bool   s_tf_active_old[];
   static bool   s_sl_marker_old[];
   static bool   s_trail_marker_old[];
   if(symbol != s_scoped_symbol) { s_scoped_symbol = symbol; force = true; }
   CIndicatorDE   *inds[];
   ENUM_TIMEFRAMES tfs[];
   //--- General monitor list (ALL indicators tracked for this Symbol), not the Trailing-eligible-only
   //--- subset - ATR etc. still needs to show here even though it can't be picked as a Trailing target
   //--- (Anhnt/Claude, 2026-09-09).
   int count = BuildSymbolIndicatorMonitorList(symbol, inds, tfs);

   if(force || count != s_row_count)
    {
     m_table_indicator_PreTradeSymbolMonitor.DeleteAllRows();
     if(count == 0)
      {
       m_table_indicator_PreTradeSymbolMonitor.AddRow(1);
       m_table_indicator_PreTradeSymbolMonitor.DeleteRow(0, true);
       ::ArrayResize(s_val_old, 0);
       ::ArrayResize(s_dir_old, 0);
       ::ArrayResize(s_sig_old, 0);
       ::ArrayResize(s_tf_active_old, 0);
       ::ArrayResize(s_sl_marker_old, 0);
       ::ArrayResize(s_trail_marker_old, 0);
       s_row_count = 0;
       m_table_indicator_PreTradeSymbolMonitor.Update(true);
       return true;
      }
     ::ArrayResize(s_val_old, count);
     ::ArrayResize(s_dir_old, count);
     ::ArrayResize(s_sig_old, count);
     ::ArrayResize(s_tf_active_old, count);
     ::ArrayResize(s_sl_marker_old, count);
     ::ArrayResize(s_trail_marker_old, count);
     ::ArrayInitialize(s_val_old, EMPTY_VALUE);
     ::ArrayInitialize(s_dir_old, -1);
     ::ArrayInitialize(s_sig_old, -1);
     ::ArrayInitialize(s_tf_active_old, false);
     uint tf_img[]  = {IMAGE_RESOURCE_BMP16_BAR_CHART_BMP, IMAGE_RESOURCE_BMP16_BAR_CHART_COLORLESS_BMP};
     uint sig_img[] = {IMAGE_RESOURCE_BMP16_ARROW_UP_PNG, IMAGE_RESOURCE_BMP16_ARROW_DOWN_PNG, IMAGE_RESOURCE_BMP16_CIRCLE_GRAY_BMP};
     uint val_img[] = {IMAGE_RESOURCE_BMP16_ICONS8_RIGHT_UP_PNG, IMAGE_RESOURCE_BMP16_ICONS8_RIGHT_DOWN_PNG, IMAGE_RESOURCE_BMP16_CIRCLE_GRAY_BMP};
     CTradingSetupSetting *row_setting = (m_trading_setup_manager != NULL) ? m_trading_setup_manager.FindByIdentity(symbol) : NULL;
     MqlParam saved_trail_params[];
     MqlParam saved_sl_params[];
     if(row_setting != NULL)
      {
       row_setting.GetTrailingIndParams(saved_trail_params);
       row_setting.GetStopLostIndParams(saved_sl_params);
      }
     uint sl_marker_img[]    = {IMAGE_RESOURCE_BMP16_STOPLOSTRED_PNG, IMAGE_RESOURCE_BMP16_STOP_GRAY_BMP};
     uint trail_marker_img[] = {IMAGE_RESOURCE_BMP16_TRAILLING_PNG,   IMAGE_RESOURCE_BMP16_STOP_GRAY_BMP};
     for(int i = 0; i < count - 1; i++)
        m_table_indicator_PreTradeSymbolMonitor.AddRow(i, i == count - 2);
     for(int row = 0; row < count; row++)
      {
       CIndicatorDE *ind = inds[row];
       //--- Active-chart highlight requires BOTH Symbol and TF to match (Anhnt, 2026-09-10 - "đổi
       //--- Symbol trên Combobox... chart đổi rồi nhưng table không highlight") - was TF-only, the
       //--- one identity check in this codebase that forgot the Symbol half (every other one, e.g.
       //--- m_table_SymbolTFSeting's is_current, checks both).
       bool tf_active = (symbol == ::Symbol() && tfs[row] == (ENUM_TIMEFRAMES)::Period());
       s_tf_active_old[row] = tf_active;
       //--- Clickable now (Anhnt/Claude, 2026-09-15) - click switches the active chart to this row's
       //--- own (Symbol,TF), via CChartObjCollection::SetActiveChartSymbolTF().
       m_table_indicator_PreTradeSymbolMonitor.CellType(0, row, CELL_BUTTON);
       m_table_indicator_PreTradeSymbolMonitor.SetImages(0, row, tf_img);
       m_table_indicator_PreTradeSymbolMonitor.ChangeImage(0, row, tf_active ? 0 : 1);
       m_table_indicator_PreTradeSymbolMonitor.SetValue(0, row, TimeframeDescription(tfs[row]));

       double v0 = ind.GetDataBuffer(0, 0);
       double v1 = ind.GetDataBuffer(0, 1);
       int    dir = 2;
       if(v0 != EMPTY_VALUE && v1 != EMPTY_VALUE) dir = (v0 > v1) ? 0 : (v0 < v1) ? 1 : 2;
       color txt_clr = (dir == 0) ? C'0,160,0' : (dir == 1) ? C'200,0,0' : clrGray;
       s_val_old[row] = v0;
       s_dir_old[row] = dir;

      //--- Col1: Signal system (sticky last-known Buy/Sell direction), same fallback chain as
      //--- SynTable_IndicatorSymbolTFMonitor's own Col2 - a live flip wins, else the last COMMITTED
      //--- history entry, else fall back to the raw value-slope dir computed above.
       int sig = dir;
       if(m_SignalsCollection != NULL)
        {
         CSignalBase *signal = m_SignalsCollection.GetOrCreateSignal(ind);
         if(signal != NULL)
          {
           ENUM_SIGNAL_DIR sdir = signal.GetCurrentSignal();
           if(sdir == SIGNAL_NONE)
            {
             int last_idx = signal.HistoryTotal() - 1;
             if(last_idx >= 0) sdir = signal.HistoryDir(last_idx);
            }
           sig = (sdir == SIGNAL_BUY) ? 0 : (sdir == SIGNAL_SELL) ? 1 : 2;
          }
        }
       s_sig_old[row] = sig;
       m_table_indicator_PreTradeSymbolMonitor.SetImages(1, row, sig_img);
       m_table_indicator_PreTradeSymbolMonitor.ChangeImage(1, row, sig);

      //--- Col2: dir icon (value slope, val_img) prefixing the Indicator label - NOT the Signal system.
       MqlParam ind_params[];
       ind.GetMqlParams(ind_params);
       CIndicatorSetting ind_label_setting;
       ind_label_setting.TypeEnum(ind.TypeIndicator());
       ind_label_setting.SetRawParams(ind_params);
       m_table_indicator_PreTradeSymbolMonitor.SetImages(2, row, val_img);
       m_table_indicator_PreTradeSymbolMonitor.ChangeImage(2, row, dir);
       m_table_indicator_PreTradeSymbolMonitor.SetValue(2, row, ind_label_setting.DisplayLabel());

       m_table_indicator_PreTradeSymbolMonitor.SetValue(3, row, (v0 == EMPTY_VALUE) ? "-" : ::DoubleToString(v0, 2));
       m_table_indicator_PreTradeSymbolMonitor.TextColor(3, row, txt_clr);
       //--- Read-only markers - which row each is currently following. Real feature icon (not a
       //--- checkbox - Anhnt, 2026-09-11: "bỏ hẳn checkbox đi vì nó gây nhầm lẫn") on the matching
       //--- row, neutral grey dot (same CIRCLE_GRAY already used for Col1/Col2's own neutral state)
       //--- everywhere else - the Library has no true "no image" state to fall back to.
       //--- StopLost-by-Indicator is ATR-only (BuildATRChoiceList has no other-indicator equivalent).
       bool sl_is_current = (row_setting != NULL && row_setting.StopLostMode() == SL_MODE_INDICATOR &&
                              ind.TypeIndicator() == IND_ATR &&
                              row_setting.StopLostIndTF() == tfs[row] &&
                              IsEqualMqlParamArrays(saved_sl_params, ind_params));
       s_sl_marker_old[row] = sl_is_current;
       m_table_indicator_PreTradeSymbolMonitor.CellType(4, row, CELL_SIMPLE);
       m_table_indicator_PreTradeSymbolMonitor.SetImages(4, row, sl_marker_img);
       m_table_indicator_PreTradeSymbolMonitor.ChangeImage(4, row, sl_is_current ? 0 : 1);

       bool trail_is_current = (row_setting != NULL && row_setting.TrailingMode() == SL_MODE_INDICATOR &&
                                 row_setting.TrailingIndType() == ind.TypeIndicator() &&
                                 row_setting.TrailingIndTF()   == tfs[row] &&
                                 IsEqualMqlParamArrays(saved_trail_params, ind_params));
       s_trail_marker_old[row] = trail_is_current;
       m_table_indicator_PreTradeSymbolMonitor.CellType(5, row, CELL_SIMPLE);
       m_table_indicator_PreTradeSymbolMonitor.SetImages(5, row, trail_marker_img);
       m_table_indicator_PreTradeSymbolMonitor.ChangeImage(5, row, trail_is_current ? 0 : 1);
      }
     s_row_count = count;
     m_table_indicator_PreTradeSymbolMonitor.Update(true);
     return true;
    }
   //--- Per-tick: re-derive each Indicator's CURRENT visual row (sort can reorder), then dirty-check.
   //--- StopLost/Trailing markers are re-checked here too (not just on a full rebuild) - changing
   //--- Fixed/Indicator or the underlying Indicator/TF via the Setting popup no longer force-syncs
   //--- this table directly, so it has to self-heal within a tick like everything else here.
    CTradingSetupSetting *row_setting = (m_trading_setup_manager != NULL) ? m_trading_setup_manager.FindByIdentity(symbol) : NULL;
    MqlParam saved_trail_params[];
    MqlParam saved_sl_params[];
    if(row_setting != NULL)
     {
      row_setting.GetTrailingIndParams(saved_trail_params);
      row_setting.GetStopLostIndParams(saved_sl_params);
     }
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
       if(m_table_indicator_PreTradeSymbolMonitor.GetValue(0, r) == want_tf &&
          m_table_indicator_PreTradeSymbolMonitor.GetValue(2, r) == want_ind) { row = r; break; }
      if(row < 0) continue; // identity not found this tick - next full rebuild will resync

      bool tf_active = (symbol == ::Symbol() && tfs[i] == (ENUM_TIMEFRAMES)::Period());
      if(tf_active != s_tf_active_old[row])
       {
        s_tf_active_old[row] = tf_active;
        m_table_indicator_PreTradeSymbolMonitor.ChangeImage(0, row, tf_active ? 0 : 1, true);
        any_changed = true;
       }

      bool sl_is_current = (row_setting != NULL && row_setting.StopLostMode() == SL_MODE_INDICATOR &&
                             inds[i].TypeIndicator() == IND_ATR &&
                             row_setting.StopLostIndTF() == tfs[i] &&
                             IsEqualMqlParamArrays(saved_sl_params, ind_params));
      if(sl_is_current != s_sl_marker_old[row])
       {
        s_sl_marker_old[row] = sl_is_current;
        m_table_indicator_PreTradeSymbolMonitor.ChangeImage(4, row, sl_is_current ? 0 : 1, true);
        any_changed = true;
       }

      bool trail_is_current = (row_setting != NULL && row_setting.TrailingMode() == SL_MODE_INDICATOR &&
                                row_setting.TrailingIndType() == inds[i].TypeIndicator() &&
                                row_setting.TrailingIndTF()   == tfs[i] &&
                                IsEqualMqlParamArrays(saved_trail_params, ind_params));
      if(trail_is_current != s_trail_marker_old[row])
       {
        s_trail_marker_old[row] = trail_is_current;
        m_table_indicator_PreTradeSymbolMonitor.ChangeImage(5, row, trail_is_current ? 0 : 1, true);
        any_changed = true;
       }
      double v0      = inds[i].GetDataBuffer(0, 0);
      double prev_v0 = s_val_old[row];
      //--- Direction vs the PREVIOUS TICK's own value (Anhnt/Claude, 2026-09-08 - was v0 vs v1
      //--- "previous CLOSED bar", which only flips when the whole bar's overall level crosses that
      //--- fixed reference - could show green while the live number was actually ticking DOWN within
      //--- the bar, confirmed via debug log: value fell 92.13169->92.13102 while dir stayed "up"
      //--- because both were still above the stale v1 reference).
      int    dir = 2;
      if(v0 != EMPTY_VALUE && prev_v0 != EMPTY_VALUE) dir = (v0 > prev_v0) ? 0 : (v0 < prev_v0) ? 1 : 2;
      bool val_changed = (v0 != prev_v0);
      bool dir_changed = (dir != s_dir_old[row]);
      if(dir_changed)
       {
        s_dir_old[row] = dir;
        m_table_indicator_PreTradeSymbolMonitor.ChangeImage(2, row, dir, true);
        any_changed = true;
       }
      if(val_changed || dir_changed)
       {
        s_val_old[row] = v0;
        color txt_clr = (dir == 0) ? C'0,160,0' : (dir == 1) ? C'200,0,0' : clrGray;
        if(val_changed) m_table_indicator_PreTradeSymbolMonitor.SetValue(3, row, (v0 == EMPTY_VALUE) ? "-" : ::DoubleToString(v0, 2), 0, true);
        m_table_indicator_PreTradeSymbolMonitor.TextColor(3, row, txt_clr, true);
        any_changed = true;
       }
      int sig = dir;
      if(m_SignalsCollection != NULL)
       {
        CSignalBase *signal = m_SignalsCollection.GetOrCreateSignal(inds[i]);
        if(signal != NULL)
         {
          ENUM_SIGNAL_DIR sdir = signal.GetCurrentSignal();
          if(sdir == SIGNAL_NONE)
           {
            int last_idx = signal.HistoryTotal() - 1;
            if(last_idx >= 0) sdir = signal.HistoryDir(last_idx);
           }
          sig = (sdir == SIGNAL_BUY) ? 0 : (sdir == SIGNAL_SELL) ? 1 : 2;
         }
        if(sig != s_sig_old[row])
         {
          s_sig_old[row] = sig;
          m_table_indicator_PreTradeSymbolMonitor.ChangeImage(1, row, sig, true);
          any_changed = true;
         }
       }
     }
   if(any_changed) m_table_indicator_PreTradeSymbolMonitor.Update(false);
   return any_changed;
  }  
 void CGUIPannel::OnSymbolToTradeChanged(void)
  {
   static bool   s_initialized = false;
   static string s_last_symbol = "";
   string symbol = GetNewOrderSymbol();
   if(symbol == "") return;
   bool symbol_changed = !s_initialized || (symbol != s_last_symbol);
   s_initialized = true;
   s_last_symbol = symbol;
   if(!symbol_changed)
    {
      double picked_lot = GetNewOrderLot();
      if(picked_lot > 0.0) m_new_order_lot_last = picked_lot;
      return;
    }
   m_textlabel_symbol_toTrade.LabelText(symbol);
   m_textlabel_symbol_toTrade.Draw();
   m_textlabel_symbol_toTrade.Update(true);
   if(m_SymbolTFManager != NULL)
      m_SymbolTFManager.NotifySettingChanged(symbol, (ENUM_TIMEFRAMES)::Period());
   SyncTable_PreTradeSymbolMonitor(symbol, true);
   SyncTable_PositionPretradeView(true);   
    CTradingSetupSetting *row_setting = (m_trading_setup_manager != NULL) ? m_trading_setup_manager.FindByIdentity(symbol) : NULL;
    m_checkbox_use_StopLostSetting.IsPressed((row_setting != NULL) && row_setting.StopLostActive());
    m_checkbox_use_TrailingSetting.IsPressed((row_setting != NULL) && row_setting.TrailingActive());
  } 
 void CGUIPannel::OnClickRunSLOrTrailingCheckbox(const long checkbox_id)
  {
   if(m_trading_setup_manager == NULL) return;
   string symbol = GetNewOrderSymbol();
   if(symbol == "") return;
   CTradingSetupSetting *row_setting = m_trading_setup_manager.FindByIdentity(symbol);
   if(row_setting == NULL) row_setting = m_trading_setup_manager.Add_TradingSetupSetting(symbol);
   if(row_setting == NULL) return;
   //--- CCheckBox::OnClickCheckbox already flips IsPressed() BEFORE firing the event that reaches
   //--- here (CheckBox.mqh:151), so IsPressed() below already reflects the NEW post-click state.
   if(checkbox_id == m_checkbox_use_StopLostSetting.Id())
      row_setting.StopLostActive(m_checkbox_use_StopLostSetting.IsPressed());
   else if(checkbox_id == m_checkbox_use_TrailingSetting.Id())
      row_setting.TrailingActive(m_checkbox_use_TrailingSetting.IsPressed());
   else
      return;
   m_trading_setup_manager.NotifySettingChanged(symbol);
   SyncTable_PositionsStoplostAndTrailling(true);
   SyncTable_PositionPretradeView(true);
  } 
 void CGUIPannel::OnClickUseRiskPerNewTradeCheckbox(void)
  {
   if(m_checkbox_use_RiskPerNewTrade.IsPressed())
      m_edit_RiskPerNewTrade.Show();
   else
      m_edit_RiskPerNewTrade.Hide();
   //--- Force the Lot list rebuild right now - SyncTable_PositionPretradeView otherwise only runs
   //--- on the next price tick (OnTickEvent), which visibly lagged the checkbox click.
   SyncTable_PositionPretradeView(true);
  }
 //+------------------------------------------------------------------+
 //| m_btn_open_StopLostSetting/m_btn_open_TrailingSetting click - opens m_window_setting_trading on |
 //| the matching tab.                                                                                 |
 //+------------------------------------------------------------------+
 void CGUIPannel::OnClickOpenTradingSettingTab(const ENUM_TAB_SETTING_TRADING tab)
  {
   OpenWindow_SettingTrading();
   m_tabs_setting_trading.SelectTab(tab);
  } 
 void CGUIPannel::OnClickTogglePretradeDirection(void)
  {
   m_new_order_is_buy = ((int)m_table_position_pretrade_view.SelectedImageIndex(COL_PTV_DIR, 0) == 0);
   UpdateSendButtonAppearance();
   SyncTable_PositionPretradeView();
  }
 //+------------------------------------------------------------------+
 //| StopLost type icon click (m_table_position_pretrade_view, COL_PTV_SLTYPE) - toggles Fixed/     |
 //| Indicator for the NEW trade about to be sent (Anhnt, 2026-09-10 - unlike the existing-position |
 //| tables, this preview row is about to become a real trade, so toggling it right here is a quick |
 //| convenience, not a "reconfigure a live setting" action). Same post-flip SelectedImageIndex()    |
 //| convention as OnClickTogglePretradeDirection.                                                    |
 //+------------------------------------------------------------------+
 void CGUIPannel::OnClickTogglePretradeSLType(void)
  {
   if(m_trading_setup_manager == NULL) return;
   string symbol = GetNewOrderSymbol();
   if(symbol == "") return;
   CTradingSetupSetting *row_setting = m_trading_setup_manager.FindByIdentity(symbol);
   if(row_setting == NULL) row_setting = m_trading_setup_manager.Add_TradingSetupSetting(symbol);
   if(row_setting == NULL) return;
   bool fixed = ((int)m_table_position_pretrade_view.SelectedImageIndex(COL_PTV_SLTYPE, 0) == 0);
   row_setting.StopLostMode(fixed ? SL_MODE_FIXED : SL_MODE_INDICATOR);
   m_trading_setup_manager.NotifySettingChanged(symbol);
   SyncTable_PositionPretradeView(true);
  }
 //+------------------------------------------------------------------+
 //| Trailing type icon click (m_table_position_pretrade_view, COL_PTV_TRAILTYPE) - same pure icon   |
 //| toggle as OnClickTogglePretradeSLType right above.                                                |
 //+------------------------------------------------------------------+
 void CGUIPannel::OnClickTogglePretradeTrailType(void)
  {
   if(m_trading_setup_manager == NULL) return;
   string symbol = GetNewOrderSymbol();
   if(symbol == "") return;
   CTradingSetupSetting *row_setting = m_trading_setup_manager.FindByIdentity(symbol);
   if(row_setting == NULL) row_setting = m_trading_setup_manager.Add_TradingSetupSetting(symbol);
   if(row_setting == NULL) return;
   bool fixed = ((int)m_table_position_pretrade_view.SelectedImageIndex(COL_PTV_TRAILTYPE, 0) == 0);
   row_setting.TrailingMode(fixed ? SL_MODE_FIXED : SL_MODE_INDICATOR);
   m_trading_setup_manager.NotifySettingChanged(symbol);
   SyncTable_PositionPretradeView(true);
  } 
 void CGUIPannel::OnClickSendNewOrder(void)
  {
   if(m_tradingEngine == NULL) return;
   string symbol = GetNewOrderSymbol();
   if(symbol == "") return;
   double lot = GetNewOrderLot();
   if(lot <= 0.0) return;   // Lot combobox disabled ("N/A") - nothing valid to send
   ENUM_POSITION_TYPE dir = m_new_order_is_buy ? POSITION_TYPE_BUY : POSITION_TYPE_SELL;
   int order_type_idx = (int)m_combobox_order_type.GetListViewPointer().SelectedItemIndex();
   if(order_type_idx == 3) return;   // Stop Limit not supported yet
   double price = ::StringToDouble(m_edit_order_type_value.GetValue());
   m_tradingEngine.SendNewOrder(symbol, dir, lot, order_type_idx, price);
  }
#endif // CGUIPANNEL_MAINWINDOWS_TABTRADING_MQH

