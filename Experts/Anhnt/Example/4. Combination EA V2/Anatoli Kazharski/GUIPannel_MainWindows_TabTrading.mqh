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
   //  index:  0      1    2    3       4        5         6         7
   //  col:  SYMBOL  DIR  LOT SLTYPE  SLPRICE  SLPROFIT  TRAILTYPE  RISK
    int width[COLUMNS_PRETRADE_VIEW_TOTAL] = {M_SYMBOL_WIDTH, M_ICON16_WIDTH, M_LOT_WIDTH, M_ICON16_WIDTH, M_PRICE_WIDTH, 50, M_ICON16_WIDTH, 70};
    ENUM_ALIGN_MODE align[COLUMNS_PRETRADE_VIEW_TOTAL] =
     {
      ALIGN_LEFT, ALIGN_LEFT, ALIGN_RIGHT, ALIGN_LEFT, ALIGN_RIGHT, ALIGN_RIGHT, ALIGN_LEFT, ALIGN_RIGHT
     };
   int text_x_offset[COLUMNS_PRETRADE_VIEW_TOTAL];
   ::ArrayInitialize(text_x_offset, 5);
   int image_x_offset[COLUMNS_PRETRADE_VIEW_TOTAL];
   ::ArrayInitialize(image_x_offset, 3);
   int table_w = 2;
   for(int c = 0; c < COLUMNS_PRETRADE_VIEW_TOTAL; c++)
      table_w += width[c];
   m_table_position_pretrade_view.TableSize(COLUMNS_PRETRADE_VIEW_TOTAL, 1);
   m_table_position_pretrade_view.View().ShowHeaders(true);
   m_table_position_pretrade_view.View().SelectableRow(false);
   m_table_position_pretrade_view.View().IsSortMode(false);
   m_table_position_pretrade_view.View().ColumnResizeMode(true);
   m_tabs_main.AddToElementsArray(TAB_TAB_MAIN_TRADING, m_table_position_pretrade_view);
   if(!m_table_position_pretrade_view.CreateTable(m_chart_id, m_subwin, "TablePretradeView", x, y, table_w, PRETRADE_VIEW_TABLE_HEIGHT + 2)) return false;
   CTableHeaderView *header = m_table_position_pretrade_view.View().GetHeaderViewPointer();
   header.ColumnsWidth(width);
   header.TextAlign(align);
   header.TextXOffset(text_x_offset);
   header.ImageXOffset(image_x_offset);
   //--- Symbol picked via an embedded combobox cell, choices = the Symbols CTradingEngine tracks,
   //--- default = the current chart Symbol
    // CArrayObj *sym_objs = (m_symbol_collection != NULL) ? m_symbol_collection.GetList() : NULL;
    // int sym_total = (sym_objs != NULL) ? sym_objs.Total() : 0;
    //  if(sym_total > 0)
    //   {
    //    string sym_list[];
    //    ::ArrayResize(sym_list, sym_total);
    //    int chart_sym_idx = 0;
    //    for(int i = 0; i < sym_total; i++)
    //     {
    //      CSymbol *sym_obj = sym_objs.At(i);
    //      sym_list[i] = (sym_obj != NULL) ? sym_obj.Name() : "";
    //      if(sym_list[i] == ::Symbol()) chart_sym_idx = i;
    //     }
    //    m_table_position_pretrade_view.CellView(COL_PTV_SYMBOL, 0).CellType(CELL_COMBOBOX);
    //    m_table_position_pretrade_view.CellView(COL_PTV_SYMBOL, 0).SetValueList(sym_list);
    //    m_table_position_pretrade_view.SetValue(COL_PTV_SYMBOL, 0, sym_list[chart_sym_idx]);
    //   }
     m_table_position_pretrade_view.CellView(COL_PTV_SYMBOL, 0).CellType(CELL_COMBOBOX);
     SyncComboBox_NewOrderSymbol();
     string lot_list[1] = {"0.01"};
     m_table_position_pretrade_view.CellView(COL_PTV_LOT, 0).CellType(CELL_COMBOBOX);
     m_table_position_pretrade_view.CellView(COL_PTV_LOT, 0).SetValueList(lot_list);
     m_table_position_pretrade_view.SetValue(COL_PTV_LOT, 0, lot_list[0]);
   m_table_position_pretrade_view.SetHeaderText(COL_PTV_SYMBOL, "Symbol");
    {
     uint dir_header_img[] = {IMAGE_RESOURCE_BMP16_ORDER_DIR_PNG};
     m_table_position_pretrade_view.SetHeaderText(COL_PTV_DIR, "");
     m_table_position_pretrade_view.SetHeaderImage(COL_PTV_DIR, dir_header_img);
     //--- Click-to-toggle Buy/Sell: the checkbox value (0 = Buy, 1 = Sell) picks the picture
     m_table_position_pretrade_view.CellView(COL_PTV_DIR, 0).CellType(CELL_CHECKBOX);
    }
   m_table_position_pretrade_view.SetHeaderText(COL_PTV_LOT, "Lot");
    {
     uint sltype_header_img[] = {IMAGE_RESOURCE_BMP16_STOPLOSTRED_PNG};
     m_table_position_pretrade_view.SetHeaderText(COL_PTV_SLTYPE, "");
     m_table_position_pretrade_view.SetHeaderImage(COL_PTV_SLTYPE, sltype_header_img);
     m_table_position_pretrade_view.CellView(COL_PTV_SLTYPE, 0).CellType(CELL_CHECKBOX);
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
     m_table_position_pretrade_view.CellView(COL_PTV_TRAILTYPE, 0).CellType(CELL_CHECKBOX);
    }
   // Real money at risk for the ACTUAL Lot picked in COL_PTV_LOT
   m_table_position_pretrade_view.SetHeaderText(COL_PTV_RISK, "Risk $");
   m_table_position_pretrade_view.CellView(COL_PTV_SLPRICE, 0).DirectionColors(C'0,160,0', C'200,0,0', clrGray);
   m_table_position_pretrade_view.CellView(COL_PTV_SLPROFIT, 0).DirectionColors(C'200,0,0', C'0,160,0', clrGray);
   m_table_position_pretrade_view.CellView(COL_PTV_RISK, 0).DirectionColors(C'200,0,0', C'0,160,0', clrGray);
   m_table_position_pretrade_view.Cell(COL_PTV_SLPROFIT, 0).SetDigits(2);
   m_table_position_pretrade_view.Cell(COL_PTV_RISK, 0).SetDigits(2);
   m_table_position_pretrade_view.View().Rebuild(true);
   return true;
  }
 //+--------------------------------------------------------------------+
 //| Refresh the single row of m_table_position_pretrade_view            |
 //+------------------------------------------------------------------+
 //+------------------------------------------------------------------+
 //| New Order Symbol choices = CSymbolsCollection; a Symbol no longer |
 //| listed falls back to the chart Symbol                             |
 //| Returns true when the selected Symbol changed                     |
 //+------------------------------------------------------------------+
 bool CGUIPannel::SyncComboBox_NewOrderSymbol(void)
  {
   string sym_list[];
   int count = 0;
   CArrayObj *sym_objs = (m_symbol_collection != NULL) ? m_symbol_collection.GetList() : NULL;
   int total = (sym_objs != NULL) ? sym_objs.Total() : 0;
   for(int i = 0; i < total; i++)
    {
     CSymbol *sym_obj = sym_objs.At(i);
     if(sym_obj == NULL) continue;
     ::ArrayResize(sym_list, count + 1);
     sym_list[count++] = sym_obj.Name();
    }
   if(count == 0)
    {
     ::ArrayResize(sym_list, 1);
     sym_list[count++] = ::Symbol();
    }
   string selected = GetNewOrderSymbol();
   bool still_listed = false;
   for(int k = 0; k < count && !still_listed; k++)
      still_listed = (sym_list[k] == selected);
   string new_selected = still_listed ? selected : ::Symbol();
   m_table_position_pretrade_view.CellView(COL_PTV_SYMBOL, 0).SetValueList(sym_list);
   m_table_position_pretrade_view.SetValue(COL_PTV_SYMBOL, 0, new_selected);
   return (new_selected != selected);
  }
 bool CGUIPannel::SyncTable_PositionPretradeView(bool force = false)
  {
   //--- Inputs that decide when the Lot choice list is rebuilt (not display caches)
   static string s_scoped_symbol = "";
   static int    s_scoped_dir    = -1;
   static bool   s_use_risk_old  = false;
   static double s_risk_pct_old  = EMPTY_VALUE;
   static double s_free_margin_old = EMPTY_VALUE; // Lot list also depends on Free Margin (CalcMaxLotByRisk margin cap)

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
   if(identity_changed)
    {
     uint sl_type_img[]    = {IMAGE_RESOURCE_BMP16_STOPLOSTGREY_PNG, IMAGE_RESOURCE_BMP16_INDICATOR_BMP};
     uint trail_type_img[] = {IMAGE_RESOURCE_BMP16_TRAILLING_PNG, IMAGE_RESOURCE_BMP16_INDICATOR_BMP};
     uint sym_img[]        = {IMAGE_RESOURCE_BMP16_BAR_CHART_BMP, IMAGE_RESOURCE_BMP16_BAR_CHART_COLORLESS_BMP};
     uint dir_img[]        = {IMAGE_RESOURCE_BMP16_ORDER_BUY_PNG, IMAGE_RESOURCE_BMP16_ORDER_SELL_PNG};
     m_table_position_pretrade_view.CellView(COL_PTV_SLTYPE, 0).SetImages(sl_type_img);
     m_table_position_pretrade_view.CellView(COL_PTV_TRAILTYPE, 0).SetImages(trail_type_img);
     m_table_position_pretrade_view.CellView(COL_PTV_SYMBOL, 0).SetImages(sym_img);
     m_table_position_pretrade_view.CellView(COL_PTV_DIR, 0).SetImages(dir_img);
     m_table_position_pretrade_view.Cell(COL_PTV_SLPRICE, 0).SetDigits((int)::SymbolInfoInteger(sym, SYMBOL_DIGITS));
    }
   //--- Icon/checkbox cells: set every call, a cell redraws only when its value really changed
   m_table_position_pretrade_view.SetValue(COL_PTV_SLTYPE, 0, (long)(sl_fixed ? CANV_ELEMENT_CHEK_STATE_UNCHECKED : CANV_ELEMENT_CHEK_STATE_CHECKED));
   m_table_position_pretrade_view.SetValue(COL_PTV_TRAILTYPE, 0, (long)(trail_fixed ? CANV_ELEMENT_CHEK_STATE_UNCHECKED : CANV_ELEMENT_CHEK_STATE_CHECKED));
   m_table_position_pretrade_view.CellView(COL_PTV_SYMBOL, 0).ChangeImage(sym == ::Symbol() ? 0 : 1);
   m_table_position_pretrade_view.SetValue(COL_PTV_DIR, 0, (long)((type == POSITION_TYPE_BUY) ? CANV_ELEMENT_CHEK_STATE_UNCHECKED : CANV_ELEMENT_CHEK_STATE_CHECKED));

   //--- Lot choice list: LotsMin..MaxLot stepped by LotsStep, disabled ("N/A") if unaffordable.
   bool use_risk = m_checkbox_use_RiskPerNewTrade.State();
   //--- Reassert visibility every tick - a tab/window reshow shows every element again
   if(use_risk) m_edit_RiskPerNewTrade.Show(); else m_edit_RiskPerNewTrade.Hide();
   int order_type_idx = m_combobox_order_type.GetListViewPointer().SelectedItemIndex();
   if(order_type_idx > 0) m_edit_order_type_value.Show(); else m_edit_order_type_value.Hide();
   //--- Unchecked = reuse CalcMaxLotByRisk with risk_percent=100 ("mức tối đa của Balance").
   double risk_pct = use_risk ? ::StringToDouble(m_edit_RiskPerNewTrade.GetValue()) : 100.0;
   //--- Rounded - Free Margin drifts with floating P&L, the list only needs rebuilding on real margin changes
   double free_margin_rounded = ::MathRound(::AccountInfoDouble(ACCOUNT_MARGIN_FREE));
   if(identity_changed || dir_changed || use_risk != s_use_risk_old || risk_pct != s_risk_pct_old ||
      free_margin_rounded != s_free_margin_old)
    {
     s_use_risk_old = use_risk;
     s_risk_pct_old = risk_pct;
     s_free_margin_old = free_margin_rounded;
     CSymbol *lot_sym = (m_symbol_collection != NULL) ? m_symbol_collection.GetSymbolObjByName(sym) : NULL;
     double min_lot  = (lot_sym != NULL) ? lot_sym.LotsMin()  : 0.0;
     double step_lot = (lot_sym != NULL) ? lot_sym.LotsStep() : 0.0;
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
       // Default MinLot, or the Lot the user already picked this session
       int default_idx = 0;
       if(m_new_order_lot_last > 0.0)
        {
         int nearest_idx = (int)::MathRound((m_new_order_lot_last - min_lot) / step_lot);
         if(nearest_idx >= 0 && nearest_idx < count) default_idx = nearest_idx;
        }
       m_table_position_pretrade_view.CellView(COL_PTV_LOT, 0).CellType(CELL_COMBOBOX);
       m_table_position_pretrade_view.CellView(COL_PTV_LOT, 0).SetValueList(lot_list);
       m_table_position_pretrade_view.SetValue(COL_PTV_LOT, 0, lot_list[default_idx]);
      }
     else
      {
       m_table_position_pretrade_view.CellView(COL_PTV_LOT, 0).CellType(CELL_SIMPLE);
       m_table_position_pretrade_view.SetValue(COL_PTV_LOT, 0, "N/A");
      }
    }

   //--- Numbers go in raw: the cell's CBaseObjExt tracking decides the up/down colors
   bool sl_price_from_trail;
   double sl_price  = (m_tradingEngine != NULL) ? m_tradingEngine.GetPreviewSLTargetPrice(sym, type, sl_price_from_trail) : EMPTY_VALUE;
   CSymbol *sym_obj_for_lot = (m_symbol_collection != NULL) ? m_symbol_collection.GetSymbolObjByName(sym) : NULL;
   double default_lot = (sym_obj_for_lot != NULL) ? sym_obj_for_lot.LotsMin() : 0.0;
   double sl_profit = (m_market_collection != NULL && sl_price != EMPTY_VALUE && default_lot > 0.0) ? m_market_collection.SumFloatingProfit(sym, type, sl_price, default_lot) : EMPTY_VALUE;
   double actual_lot = GetNewOrderLot();
   double risk = (m_market_collection != NULL && sl_price != EMPTY_VALUE && actual_lot > 0.0) ? m_market_collection.SumFloatingProfit(sym, type, sl_price, actual_lot) : EMPTY_VALUE;
   //--- "N/A" usually means Mode=Indicator with no Indicator configured yet for this Symbol
   if(sl_price == EMPTY_VALUE)  m_table_position_pretrade_view.SetValue(COL_PTV_SLPRICE, 0, "N/A");  else m_table_position_pretrade_view.SetValue(COL_PTV_SLPRICE, 0, sl_price);
   if(sl_profit == EMPTY_VALUE) m_table_position_pretrade_view.SetValue(COL_PTV_SLPROFIT, 0, "N/A"); else m_table_position_pretrade_view.SetValue(COL_PTV_SLPROFIT, 0, sl_profit);
   if(risk == EMPTY_VALUE)      m_table_position_pretrade_view.SetValue(COL_PTV_RISK, 0, "N/A");     else m_table_position_pretrade_view.SetValue(COL_PTV_RISK, 0, risk);
   return m_table_position_pretrade_view.Update(false);
  }
 //+------------------------------------------------------------------+
 //| Create m_table_positions_StoplostAndTrailling (TAB_TAB_MAIN_TRADING)|
 //+------------------------------------------------------------------+
 bool CGUIPannel::CreateTable_PositionsStoplostAndTrailling(const int x, const int y)
  {
   //  index:  0    1    2    3    4    5    6    7    8    9    10
   //  col:  SYMBOL DIR VOLUME NO SLTYPE SLPRICE SLPROFIT RUN_SL TRAILTYPE RUN_TRAIL PROFIT
    int width[COLUMNS_POS_SL_TRAIL_TOTAL]        = {M_SYMBOL_WIDTH, M_ICON16_WIDTH, M_LOT_WIDTH, 30, M_ICON16_WIDTH, M_PRICE_WIDTH, 50, M_ICON16_WIDTH, M_ICON16_WIDTH, M_ICON16_WIDTH, 45};
    ENUM_ALIGN_MODE align[COLUMNS_POS_SL_TRAIL_TOTAL] =
     {
      ALIGN_LEFT, ALIGN_LEFT, ALIGN_RIGHT, ALIGN_RIGHT,
      ALIGN_LEFT, ALIGN_RIGHT, ALIGN_RIGHT, ALIGN_LEFT,
      ALIGN_LEFT, ALIGN_LEFT, ALIGN_RIGHT
     };
   int text_x_offset[COLUMNS_POS_SL_TRAIL_TOTAL];
   ::ArrayInitialize(text_x_offset, 5);
   int image_x_offset[COLUMNS_POS_SL_TRAIL_TOTAL];
   ::ArrayInitialize(image_x_offset, 3);
   int table_w = 2 + 16;   // border + vertical scrollbar
   for(int c = 0; c < COLUMNS_POS_SL_TRAIL_TOTAL; c++)
      table_w += width[c];
   m_table_positions_StoplostAndTrailling.TableSize(COLUMNS_POS_SL_TRAIL_TOTAL, 0);
   m_table_positions_StoplostAndTrailling.View().ShowHeaders(true);
   m_table_positions_StoplostAndTrailling.View().SelectableRow(true);
   m_table_positions_StoplostAndTrailling.View().LightsHover(true);
   m_table_positions_StoplostAndTrailling.View().IsSortMode(false);
   m_table_positions_StoplostAndTrailling.View().ColumnResizeMode(true);
   //--- Fills the tab down to its bottom edge, follows it on window resize
   m_table_positions_StoplostAndTrailling.AutoYResizeMode(true);
   m_table_positions_StoplostAndTrailling.AutoYResizeBottomOffset(M_CONTROL_BORDER_GAP);
   m_tabs_main.AddToElementsArray(TAB_TAB_MAIN_TRADING, m_table_positions_StoplostAndTrailling);
   if(!m_table_positions_StoplostAndTrailling.CreateTable(m_chart_id, m_subwin, "TablePositionsSLTrail", x, y, table_w)) return false;
   CTableHeaderView *header = m_table_positions_StoplostAndTrailling.View().GetHeaderViewPointer();
   header.ColumnsWidth(width);
   header.TextAlign(align);
   header.TextXOffset(text_x_offset);
   header.ImageXOffset(image_x_offset);
   m_table_positions_StoplostAndTrailling.SetHeaderText(COL_PST_SYMBOL,    "Symbol");
    {
     uint dir_header_img[] = {IMAGE_RESOURCE_BMP16_ORDER_DIR_PNG};
     m_table_positions_StoplostAndTrailling.SetHeaderText(COL_PST_DIR, "");
     m_table_positions_StoplostAndTrailling.SetHeaderImage(COL_PST_DIR, dir_header_img);
    }
   m_table_positions_StoplostAndTrailling.SetHeaderText(COL_PST_VOLUME,    "Vol");
   m_table_positions_StoplostAndTrailling.SetHeaderText(COL_PST_NO,        "No");
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
   m_table_positions_StoplostAndTrailling.View().Rebuild(true);
   return true;
  }
 bool CGUIPannel::SyncTable_PositionsStoplostAndTrailling(bool force = false)
  {
   string symbols[]; ENUM_POSITION_TYPE dirs[];
   int count = (m_market_collection != NULL) ? m_market_collection.GetDistinctSymbolsAndDirections(symbols, dirs) : 0;
   static string s_prev_keys[];   // row structure (Symbol_Dir per row), not a value cache
    string keys[];
    ::ArrayResize(keys, count);
    for(int i = 0; i < count; i++)
       keys[i] = symbols[i] + "_" + (string)dirs[i];
   bool identity_changed = (force || ::ArraySize(s_prev_keys) != count);
   if(!identity_changed)
     for(int i = 0; i < count; i++)
       if(s_prev_keys[i] != keys[i]) { identity_changed = true; break; }
   if(count == 0)
    {
     if(::ArraySize(s_prev_keys) != 0)
      {
       m_table_positions_StoplostAndTrailling.DeleteAllRows(true);
       ::ArrayResize(s_prev_keys, 0);
       return true;
      }
     return false;
    }
   if(identity_changed)
    {
     uint sym_img[] = {IMAGE_RESOURCE_BMP16_BAR_CHART_BMP, IMAGE_RESOURCE_BMP16_BAR_CHART_COLORLESS_BMP};
     uint dir_img[] = {IMAGE_RESOURCE_BMP16_ORDER_BUY_PNG, IMAGE_RESOURCE_BMP16_ORDER_SELL_PNG};
     //--- Run SL/Run Trail read-only status icon - index 0 = running (colored), 1 = not running (gray).
     uint run_status_img[] = {IMAGE_RESOURCE_BMP16_START_BMP, IMAGE_RESOURCE_BMP16_START_GRAY_BMP};
     uint sl_type_img[]    = {IMAGE_RESOURCE_BMP16_STOPLOSTGREY_PNG, IMAGE_RESOURCE_BMP16_INDICATOR_BMP};
     uint trail_type_img[] = {IMAGE_RESOURCE_BMP16_TRAILLING_PNG, IMAGE_RESOURCE_BMP16_INDICATOR_BMP};
     m_table_positions_StoplostAndTrailling.DeleteAllRows();
     for(int i = 0; i < count; i++)
        m_table_positions_StoplostAndTrailling.AddRow();
     ::ArrayResize(s_prev_keys, count);
     for(int row = 0; row < count; row++)
      {
       s_prev_keys[row] = keys[row];
       m_table_positions_StoplostAndTrailling.CellView(COL_PST_SYMBOL, row).SetImages(sym_img);
       m_table_positions_StoplostAndTrailling.SetValue(COL_PST_SYMBOL, row, symbols[row]);
       //--- Icon only, no text - the Buy/Sell icon alone already conveys Direction.
       m_table_positions_StoplostAndTrailling.CellView(COL_PST_DIR, row).SetImages(dir_img);
       m_table_positions_StoplostAndTrailling.CellView(COL_PST_DIR, row).ChangeImage((dirs[row] == POSITION_TYPE_BUY) ? 0 : 1);
       m_table_positions_StoplostAndTrailling.Cell(COL_PST_VOLUME, row).SetDigits(2);
       //--- Click-to-toggle Fixed/Indicator (checkbox value 0 = Fixed, 1 = Indicator)
       m_table_positions_StoplostAndTrailling.CellView(COL_PST_SLTYPE, row).CellType(CELL_CHECKBOX);
       m_table_positions_StoplostAndTrailling.CellView(COL_PST_SLTYPE, row).SetImages(sl_type_img);
       m_table_positions_StoplostAndTrailling.CellView(COL_PST_RUN_SL, row).CellType(CELL_BUTTON);
       m_table_positions_StoplostAndTrailling.CellView(COL_PST_RUN_SL, row).SetImages(run_status_img);
       m_table_positions_StoplostAndTrailling.CellView(COL_PST_TRAILTYPE, row).CellType(CELL_CHECKBOX);
       m_table_positions_StoplostAndTrailling.CellView(COL_PST_TRAILTYPE, row).SetImages(trail_type_img);
       m_table_positions_StoplostAndTrailling.CellView(COL_PST_RUN_TRAIL, row).CellType(CELL_BUTTON);
       m_table_positions_StoplostAndTrailling.CellView(COL_PST_RUN_TRAIL, row).SetImages(run_status_img);
       //--- SL Price/SL Profit/Profit - green=up / red=down / gray=flat from the cell's own tracking
       m_table_positions_StoplostAndTrailling.Cell(COL_PST_SLPRICE, row).SetDigits((int)::SymbolInfoInteger(symbols[row], SYMBOL_DIGITS));
       m_table_positions_StoplostAndTrailling.Cell(COL_PST_SLPROFIT, row).SetDigits(2);
       m_table_positions_StoplostAndTrailling.Cell(COL_PST_PROFIT, row).SetDigits(2);
       m_table_positions_StoplostAndTrailling.CellView(COL_PST_SLPRICE, row).DirectionColors(C'0,160,0', C'200,0,0', clrGray);
       m_table_positions_StoplostAndTrailling.CellView(COL_PST_SLPROFIT, row).DirectionColors(C'0,160,0', C'200,0,0', clrGray);
       m_table_positions_StoplostAndTrailling.CellView(COL_PST_PROFIT, row).DirectionColors(C'0,160,0', C'200,0,0', clrGray);
      }
    }
   //--- Values every call - a cell redraws only when its value really changed
    for(int row = 0; row < count; row++)
     {
      string sym = symbols[row];
      ENUM_POSITION_TYPE type = dirs[row];
      m_table_positions_StoplostAndTrailling.CellView(COL_PST_SYMBOL, row).ChangeImage(sym == ::Symbol() ? 0 : 1);
      CArrayObj *pos_list = (m_market_collection != NULL) ? m_market_collection.GetPositionList(sym, type) : NULL;
      m_table_positions_StoplostAndTrailling.SetValue(COL_PST_VOLUME, row, (m_market_collection != NULL) ? m_market_collection.SumVolume(pos_list) : 0.0);
      m_table_positions_StoplostAndTrailling.SetValue(COL_PST_NO, row, (long)((pos_list != NULL) ? pos_list.Total() : 0));
      //--- SL Type/Run/Trailling/Run - Single Source of Truth is CTradingSetupSetting
      CTradingSetupSetting *row_setting = (m_trading_setup_manager != NULL) ? m_trading_setup_manager.FindByIdentity(sym) : NULL;
      if(row_setting == NULL && m_trading_setup_manager != NULL)
         row_setting = m_trading_setup_manager.Add_TradingSetupSetting(sym);   // lazy-create, same as the StopLost Save handler
      bool sl_fixed    = (row_setting == NULL) || (row_setting.StopLostMode() == SL_MODE_FIXED);
      bool sl_active   = (row_setting != NULL) && row_setting.StopLostActive();
      bool trail_fixed = (row_setting == NULL) || (row_setting.TrailingMode() == SL_MODE_FIXED);
      bool trail_active= (row_setting != NULL) && row_setting.TrailingActive();
      m_table_positions_StoplostAndTrailling.SetValue(COL_PST_SLTYPE, row, (long)(sl_fixed ? CANV_ELEMENT_CHEK_STATE_UNCHECKED : CANV_ELEMENT_CHEK_STATE_CHECKED));
      m_table_positions_StoplostAndTrailling.CellView(COL_PST_RUN_SL, row).ChangeImage(sl_active ? 0 : 1);
      m_table_positions_StoplostAndTrailling.SetValue(COL_PST_TRAILTYPE, row, (long)(trail_fixed ? CANV_ELEMENT_CHEK_STATE_UNCHECKED : CANV_ELEMENT_CHEK_STATE_CHECKED));
      m_table_positions_StoplostAndTrailling.CellView(COL_PST_RUN_TRAIL, row).ChangeImage(trail_active ? 0 : 1);
      //--- Real Positions exist here: the ACTUAL current SL, money on the REAL Volume; SL Profit = Profit
      bool   sl_price_from_trail;
      double sl_price  = m_tradingEngine.GetPreviewSLTargetPrice(sym, type, sl_price_from_trail);
      double sl_profit = (sl_price != EMPTY_VALUE && m_market_collection != NULL) ? m_market_collection.SumFloatingProfit(sym, type, sl_price) : EMPTY_VALUE;
      if(sl_price == EMPTY_VALUE)
         m_table_positions_StoplostAndTrailling.SetValue(COL_PST_SLPRICE, row, "N/A");
      else
         m_table_positions_StoplostAndTrailling.SetValue(COL_PST_SLPRICE, row, sl_price);
      if(sl_profit == EMPTY_VALUE)
        {
         m_table_positions_StoplostAndTrailling.SetValue(COL_PST_SLPROFIT, row, "N/A");
         m_table_positions_StoplostAndTrailling.SetValue(COL_PST_PROFIT, row, "N/A");
        }
      else
        {
         m_table_positions_StoplostAndTrailling.SetValue(COL_PST_SLPROFIT, row, sl_profit);
         m_table_positions_StoplostAndTrailling.SetValue(COL_PST_PROFIT, row, sl_profit);
        }
     }
   return m_table_positions_StoplostAndTrailling.Update(false);
  }
 //+------------------------------------------------------------------+
 //| StopLost type icon click (COL_PST_SLTYPE): the table already      |
 //| flipped the cell value, the setting follows it                   |
 //+------------------------------------------------------------------+
 void CGUIPannel::OnClickTogglePositionSLType(const int row)
  {
   if(m_trading_setup_manager == NULL) return;
   string sym = m_table_positions_StoplostAndTrailling.Cell(COL_PST_SYMBOL, row).Value();
   if(sym == "") return;
   CTradingSetupSetting *row_setting = m_trading_setup_manager.FindByIdentity(sym);
   if(row_setting == NULL) row_setting = m_trading_setup_manager.Add_TradingSetupSetting(sym);
   if(row_setting == NULL) return;
   bool fixed = (m_table_positions_StoplostAndTrailling.Cell(COL_PST_SLTYPE, row).ValueL() == CANV_ELEMENT_CHEK_STATE_UNCHECKED);
   row_setting.StopLostMode(fixed ? SL_MODE_FIXED : SL_MODE_INDICATOR);
   m_trading_setup_manager.NotifySettingChanged(sym);
   SyncTable_PositionsStoplostAndTrailling(true);
  }
 //+------------------------------------------------------------------+
 //| Trailing type icon click (COL_PST_TRAILTYPE) - same as above      |
 //+------------------------------------------------------------------+
 void CGUIPannel::OnClickTogglePositionTrailType(const int row)
  {
   if(m_trading_setup_manager == NULL) return;
   string sym = m_table_positions_StoplostAndTrailling.Cell(COL_PST_SYMBOL, row).Value();
   if(sym == "") return;
   CTradingSetupSetting *row_setting = m_trading_setup_manager.FindByIdentity(sym);
   if(row_setting == NULL) row_setting = m_trading_setup_manager.Add_TradingSetupSetting(sym);
   if(row_setting == NULL) return;
   bool fixed = (m_table_positions_StoplostAndTrailling.Cell(COL_PST_TRAILTYPE, row).ValueL() == CANV_ELEMENT_CHEK_STATE_UNCHECKED);
   row_setting.TrailingMode(fixed ? SL_MODE_FIXED : SL_MODE_INDICATOR);
   m_trading_setup_manager.NotifySettingChanged(sym);
   SyncTable_PositionsStoplostAndTrailling(true);
  }
 //+------------------------------------------------------------------+
 //| "All" (only with 2+ TFs) + the Symbol's TFs, sorted by the Manager|
 //+------------------------------------------------------------------+
 void CGUIPannel::SyncTFSwitchButtons(void)
  {
   string sym = ::Symbol();
   string tf_texts[];
   int count = 0;
   int total = (m_SymbolTFManager != NULL) ? m_SymbolTFManager.Total() : 0;
   for(int i = 0; i < total; i++)
    {
     CSymbolTFSetting *row = m_SymbolTFManager.At(i);
     if(row == NULL || row.Symbol() != sym) continue;
     ::ArrayResize(tf_texts, count + 1);
     tf_texts[count] = TimeframeDescription(row.TFEnum());
     count++;
    }
   //--- A single TF has nothing to filter: no "All"
   int first = (count > 1) ? 1 : 0;
   //--- Unchanged set: keep the buttons (and the pressed one)
   bool same = (m_btngroup_tf_switch.ButtonsTotal() == count + first);
   if(same && first == 1)
      same = (m_btngroup_tf_switch.GetButtonPointer(0).Text() == "All");
   for(int i = 0; i < count && same; i++)
      same = (m_btngroup_tf_switch.GetButtonPointer(i + first).Text() == tf_texts[i]);
   if(same) return;
   string selected = m_btngroup_tf_switch.SelectedButtonText();
   m_btngroup_tf_switch.DeleteButtons();
   if(first == 1)
      m_btngroup_tf_switch.AddButton(0, 0, "All", TF_SWITCH_BUTTON_WIDTH);
   int select_index = 0;
   for(int i = 0; i < count; i++)
    {
     m_btngroup_tf_switch.AddButton((i + first) * (TF_SWITCH_BUTTON_WIDTH + TF_SWITCH_BUTTON_GAP), 0, tf_texts[i], TF_SWITCH_BUTTON_WIDTH);
     if(tf_texts[i] == selected) select_index = i + first;
    }
   if(m_btngroup_tf_switch.ButtonsTotal() > 0)
      m_btngroup_tf_switch.SelectButton(select_index);
   SyncTable_PreTradeSymbolMonitor(::Symbol(), true);
  }
 //+------------------------------------------------------------------+
 //| Group with "All" only; SyncTFSwitchButtons() adds the TFs         |
 //+------------------------------------------------------------------+
 bool CGUIPannel::CreateTFSwitchButtons(const int x_gap, const int y_gap)
  {
   m_btngroup_tf_switch.RadioButtonsMode(true);
   m_btngroup_tf_switch.ButtonYSize(M_CONTROL_HEIGHT);
   m_btngroup_tf_switch.AddButton(0, 0, "All", TF_SWITCH_BUTTON_WIDTH);
   m_tabs_main.AddToElementsArray(TAB_TAB_MAIN_TRADING, m_btngroup_tf_switch);
   return m_btngroup_tf_switch.CreateButtonsGroup(m_chart_id, m_subwin, "TFSwitch", x_gap, y_gap);
  }
 //+------------------------------------------------------------------+
 //| Filter the Monitor table; a TF button also moves the chart there  |
 //+------------------------------------------------------------------+
 void CGUIPannel::OnClickTFSwitchButton(void)
  {
   string symbol = ::Symbol();
   SyncTable_PreTradeSymbolMonitor(symbol, true);
   ENUM_TIMEFRAMES tf = TimestampByDescription(m_btngroup_tf_switch.SelectedButtonText());
   if(tf == PERIOD_CURRENT || symbol == "" || m_chart_obj_collection == NULL) return;
   m_chart_obj_collection.SetActiveChartSymbolTF(::ChartID(), symbol, tf);
  }
 bool CGUIPannel::CreateTradingForm(const int x_gap, const int y_gap)
  {
    int row0_y = y_gap;                                           // Use Risk % Per Trade checkbox
    int row1_y = y_gap + M_CONTROL_YDISTANCE;                     // Risk % edit
    int row2_y = y_gap + 2*M_CONTROL_YDISTANCE + M_CONTROL_BORDER_GAP;    // Order Type combobox
    int row3_y = y_gap + 3*M_CONTROL_YDISTANCE + M_CONTROL_BORDER_GAP;    // Order Type Value edit (Limit/Stop/Stop Limit price)
    int row4_y = y_gap + 4*M_CONTROL_YDISTANCE + M_CONTROL_BORDER_GAP;    // Send button
    int check_w = M_SYMBOL_WIDTH + 10;
   //--- No frame any more: every control sits directly on the Trading tab
   // m_frame_trading_setting.SetText(::Symbol());
   // m_tabs_main.AddToElementsArray(TAB_TAB_MAIN_TRADING, m_frame_trading_setting);
   // if(!m_frame_trading_setting.CreateFrame(m_chart_id, m_subwin, "FrameTradingSetting", x_gap, row0_y, frame_w, frame_h)) return false;
   // Lot/Direction are embedded in m_table_position_pretrade_view now
    m_new_order_is_buy = true;
   //--- Run SL / Run Trailing moved to m_contextmenu_trading, the settings open from the Monitor's colored cells
   // m_checkbox_use_StopLostSetting.SetText("Use StopLost");
   // m_frame_trading_setting.AddChild(&m_checkbox_use_StopLostSetting);
   // if(!m_checkbox_use_StopLostSetting.Create(m_chart_id, m_subwin, "CheckUseStopLost", frame_pad, in_row0_y, check_w, M_CONTROL_HEIGHT)) return false;
   // m_checkbox_use_StopLostSetting.SetState(true);
   // m_btn_open_StopLostSetting.IconFile(IMAGE_RESOURCE_BMP16_STOPLOSTRED_PNG);
   // m_frame_trading_setting.AddChild(&m_btn_open_StopLostSetting);
   // if(!m_btn_open_StopLostSetting.Create(m_chart_id, m_subwin, "BtnOpenStopLost", btn_x, in_row0_y, M_CONTROL_HEIGHT, M_CONTROL_HEIGHT)) return false;
   // m_checkbox_use_TrailingSetting.SetText("Use Trailing");
   // m_frame_trading_setting.AddChild(&m_checkbox_use_TrailingSetting);
   // if(!m_checkbox_use_TrailingSetting.Create(m_chart_id, m_subwin, "CheckUseTrailing", frame_pad, in_row1_y, check_w, M_CONTROL_HEIGHT)) return false;
   // m_checkbox_use_TrailingSetting.SetState(true);
   // m_btn_open_TrailingSetting.IconFile(IMAGE_RESOURCE_BMP16_TRAILLING_PNG);
   // m_frame_trading_setting.AddChild(&m_btn_open_TrailingSetting);
   // if(!m_btn_open_TrailingSetting.Create(m_chart_id, m_subwin, "BtnOpenTrailing", btn_x, in_row1_y, M_CONTROL_HEIGHT, M_CONTROL_HEIGHT)) return false;
   //--- Use Risk % Per Trade checkbox + its edit box directly below - no separate caption label.
    m_checkbox_use_RiskPerNewTrade.SetText("Use RPT %");
    m_tabs_main.AddToElementsArray(TAB_TAB_MAIN_TRADING, m_checkbox_use_RiskPerNewTrade);
    if(!m_checkbox_use_RiskPerNewTrade.Create(m_chart_id, m_subwin, "CheckUseRiskPerTrade", x_gap, row0_y, check_w, M_CONTROL_HEIGHT)) return false;
    m_checkbox_use_RiskPerNewTrade.SetState(false);
   // PerTrade Edit Control - directly below the checkbox, the box fills the whole row (no label)
    m_tabs_main.AddToElementsArray(TAB_TAB_MAIN_TRADING, m_edit_RiskPerNewTrade);
    if(!m_edit_RiskPerNewTrade.CreateTextEdit(m_chart_id, m_subwin, "EditRiskPerTrade", x_gap, row1_y, M_SYMBOL_WIDTH, M_CONTROL_HEIGHT, M_SYMBOL_WIDTH - 1)) return false;
    m_edit_RiskPerNewTrade.SetValue((string)RISK_PERCENTAGE_PERPOSITION);
   //--- Starts hidden - only shown while "Use RPT %" is checked (OnClickUseRiskPerNewTradeCheckbox).
    m_edit_RiskPerNewTrade.Hide();
   //--- Order Type (Market/Limit/Stop/Stop Limit) - drives m_btn_send_toTrade + m_edit_order_type_value.
    m_combobox_order_type.ItemsTotal(4);
    m_combobox_order_type.SetValue(0, "Market");
    m_combobox_order_type.SetValue(1, "Limit");
    m_combobox_order_type.SetValue(2, "Stop");
    m_combobox_order_type.SetValue(3, "Stop Limit");
    m_tabs_main.AddToElementsArray(TAB_TAB_MAIN_TRADING, m_combobox_order_type);
    if(!m_combobox_order_type.CreateComboBox(m_chart_id, m_subwin, "ComboOrderType", x_gap, row2_y, M_SYMBOL_WIDTH, M_CONTROL_HEIGHT, M_SYMBOL_WIDTH - 1)) return false;
    m_combobox_order_type.SelectItem(0);
   //--- Order Type Value (Limit/Stop price) - Show()/Hide() driven by UpdateSendButtonAppearance.
    m_tabs_main.AddToElementsArray(TAB_TAB_MAIN_TRADING, m_edit_order_type_value);
    if(!m_edit_order_type_value.CreateTextEdit(m_chart_id, m_subwin, "EditOrderTypeValue", x_gap, row3_y, M_SYMBOL_WIDTH, M_CONTROL_HEIGHT, M_SYMBOL_WIDTH - 1)) return false;
    m_edit_order_type_value.SetValue("0.0");
    m_edit_order_type_value.Hide();            // Market is the default selection - starts hidden
   //--- Send button - color/text adapt to Direction+Order Type.
    m_btn_send_toTrade.SetText("Buy");
    m_tabs_main.AddToElementsArray(TAB_TAB_MAIN_TRADING, m_btn_send_toTrade);
    if(!m_btn_send_toTrade.Create(m_chart_id, m_subwin, "BtnSendToTrade", x_gap, row4_y, M_SYMBOL_WIDTH, M_CONTROL_HEIGHT)) return false;
    UpdateSendButtonAppearance();
   return true;
  }
 void CGUIPannel::UpdateSendButtonAppearance(void)
  {
   int type_idx = m_combobox_order_type.GetListViewPointer().SelectedItemIndex();
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
   color back = is_buy ? C'0,160,0' : C'200,0,0'; // same green/red convention as the up/down colors
   m_btn_send_toTrade.SetText(dir_text + type_suffix);
   m_btn_send_toTrade.GetBackColorControl().InitColors(back, back, back, clrLightGray);
   m_btn_send_toTrade.GetForeColorControl().InitColors(clrWhite, clrWhite, clrWhite, clrGray);
   m_btn_send_toTrade.ColorChange(COLOR_STATE_DEFAULT);
   m_btn_send_toTrade.Draw(true);
   //--- Order Type Value only makes sense for a pending order, not Market
   if(type_idx > 0)
      m_edit_order_type_value.Show();
   else
      m_edit_order_type_value.Hide();
  }
 //+------------------------------------------------------------------+
 //| m_table_indicator_PreTradeSymbolMonitor - every indicator tracked |
 //| for the New Order Symbol (TF|Signal|Indicator|Value|SL|Trailing)  |
 //+------------------------------------------------------------------+
 bool CGUIPannel::CreateTable_PreTradeSymbolMonitor(const int x, const int y)
  {
   #define COLUMNS_PRETRADEMON_TOTAL 6
   int width[COLUMNS_PRETRADEMON_TOTAL]           = {M_TF_WIDTH, M_ICON16_WIDTH, M_INDICATOR_PARATEXT_WIDTH, M_PRICE_WIDTH, M_ICON16_WIDTH, M_ICON16_WIDTH};
   ENUM_ALIGN_MODE align_header [COLUMNS_PRETRADEMON_TOTAL]={ALIGN_CENTER, ALIGN_CENTER, ALIGN_CENTER, ALIGN_RIGHT, ALIGN_CENTER, ALIGN_CENTER};
   ENUM_ALIGN_MODE align_content[COLUMNS_PRETRADEMON_TOTAL] = {ALIGN_LEFT, ALIGN_LEFT, ALIGN_LEFT, ALIGN_RIGHT, ALIGN_LEFT, ALIGN_LEFT};
   int text_x_offset[COLUMNS_PRETRADEMON_TOTAL]   = {5, 5, 5, 5, 5, 5};
   int image_x_offset[COLUMNS_PRETRADEMON_TOTAL]  = {3, 3, 3, 0, 2, 2};
   int columns_width_total = 0;
   for(int columns = 0; columns < COLUMNS_PRETRADEMON_TOTAL; columns++)
    {
      columns_width_total += width[columns];
      m_table_indicator_PreTradeSymbolMonitor.View()
           .GetHeaderViewPointer()
           .TextAlign(columns, align_header[columns]);
           .
    }      
   m_table_indicator_PreTradeSymbolMonitor.TableSize(COLUMNS_PRETRADEMON_TOTAL, 0);
   m_table_indicator_PreTradeSymbolMonitor.View().ShowHeaders(true);
   m_table_indicator_PreTradeSymbolMonitor.View().SelectableRow(true);
   m_table_indicator_PreTradeSymbolMonitor.View().LightsHover(true);
   // Sort disabled - row order fully controlled by our own rebuild (row==i invariant)
   m_table_indicator_PreTradeSymbolMonitor.View().IsSortMode(false);
   m_tabs_main.AddToElementsArray(TAB_TAB_MAIN_TRADING, m_table_indicator_PreTradeSymbolMonitor);
   if(!m_table_indicator_PreTradeSymbolMonitor.CreateTable(m_chart_id, m_subwin, "TablePreTradeMonitor", x, y, columns_width_total + 20, TRADING_FORM_HEIGHT)) return false;
   CTableHeaderView *header = m_table_indicator_PreTradeSymbolMonitor.View().GetHeaderViewPointer();
   header.ColumnsWidth(width);
   header.TextAlign(align);
   header.TextXOffset(text_x_offset);
   header.ImageXOffset(image_x_offset);
   m_table_indicator_PreTradeSymbolMonitor.SetHeaderText(0, "TF");
   m_table_indicator_PreTradeSymbolMonitor.View().GetHeaderViewPointer().TextAlign(0, ALIGN_CENTER);
   m_table_indicator_PreTradeSymbolMonitor.View().GetHeaderViewPointer().TextAlign(1, ALIGN_CENTER);
    {
     uint signal_col_img[] = {IMAGE_RESOURCE_BMP16_SIGNAL_PNG};
     m_table_indicator_PreTradeSymbolMonitor.SetHeaderText(1, "");
     m_table_indicator_PreTradeSymbolMonitor.SetHeaderImage(1, signal_col_img);
    }
   m_table_indicator_PreTradeSymbolMonitor.SetHeaderText(2, "Indicator");
   m_table_indicator_PreTradeSymbolMonitor.View().GetHeaderViewPointer().TextAlign(2, ALIGN_CENTER);

   m_table_indicator_PreTradeSymbolMonitor.SetHeaderText(3, "Value");
   m_table_indicator_PreTradeSymbolMonitor.View().GetHeaderViewPointer().TextAlign(3, ALIGN_CENTER);
    {
     uint sl_col_img[] = {IMAGE_RESOURCE_BMP16_STOPLOSTRED_PNG};
     m_table_indicator_PreTradeSymbolMonitor.SetHeaderText(4, "");
     m_table_indicator_PreTradeSymbolMonitor.SetHeaderImage(4, sl_col_img);
     m_table_indicator_PreTradeSymbolMonitor.View().GetHeaderViewPointer().TextAlign(4, ALIGN_CENTER);
    }
    {
     uint trailling_col_img[] = {IMAGE_RESOURCE_BMP16_TRAILLING_PNG};
     m_table_indicator_PreTradeSymbolMonitor.SetHeaderText(5, "");
     m_table_indicator_PreTradeSymbolMonitor.SetHeaderImage(5, trailling_col_img);
    }
   m_table_indicator_PreTradeSymbolMonitor.View().Rebuild(true);
   return true;
  }
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
     CArrayObj *ind_list = m_IndicatorsCollection.GetList();   // filtered inline below - no Select per tick
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
         if(cand == NULL || cand.Symbol() != symbol || cand.Timeframe() != tf || cand.TypeIndicator() != entry.TypeEnum()) continue;
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
 //void CGUIPannel::OnClickNavigateToTF(const int row)
 // {
 //  if(m_chart_obj_collection == NULL) return;
 //  string symbol = GetNewOrderSymbol();
 //  if(symbol == "") return;
 //  string tf_text = m_table_indicator_PreTradeSymbolMonitor.Cell(0, row).Value();
 //  CIndicatorDE   *inds[];
 //  ENUM_TIMEFRAMES tfs[];
 //  int count = BuildSymbolIndicatorMonitorList(symbol, inds, tfs);
 //  for(int i = 0; i < count; i++)
 //   {
 //    if(TimeframeDescription(tfs[i]) != tf_text) continue;
 //    m_chart_obj_collection.SetActiveChartSymbolTF(::ChartID(), symbol, tfs[i]);
 //    return;
 //   }
 // }
 bool CGUIPannel::SyncTable_PreTradeSymbolMonitor(const string symbol, bool force = false)
  {
   //--- Row structure only (which indicator sits on which row), not value caches
   static string s_scoped_symbol = "";
   static CIndicatorDE *s_inds_old[];
   if(symbol != s_scoped_symbol) { s_scoped_symbol = symbol; force = true; }
   CIndicatorDE   *inds[];
   ENUM_TIMEFRAMES tfs[];
   int count = BuildSymbolIndicatorMonitorList(symbol, inds, tfs);
   ENUM_TIMEFRAMES tf_filter = TimestampByDescription(m_btngroup_tf_switch.SelectedButtonText());   // "All" = PERIOD_CURRENT
   if(tf_filter != PERIOD_CURRENT)
    {
     int kept = 0;
     for(int i = 0; i < count; i++)
       if(tfs[i] == tf_filter) { inds[kept] = inds[i]; tfs[kept] = tfs[i]; kept++; }
     count = kept;
    }
   bool rebuild = force || (count != ::ArraySize(s_inds_old));
   for(int i = 0; i < count && !rebuild; i++)
      if(inds[i] != s_inds_old[i]) rebuild = true;
   if(rebuild)
    {
     m_table_indicator_PreTradeSymbolMonitor.DeleteAllRows(count == 0);
     ::ArrayResize(s_inds_old, count);
     if(count == 0)
        return true;
     for(int i = 0; i < count; i++)
        m_table_indicator_PreTradeSymbolMonitor.AddRow();
     uint tf_img[]  = {IMAGE_RESOURCE_BMP16_BAR_CHART_BMP, IMAGE_RESOURCE_BMP16_BAR_CHART_COLORLESS_BMP};
     uint sig_img[] = {IMAGE_RESOURCE_BMP16_ARROW_UP_PNG, IMAGE_RESOURCE_BMP16_ARROW_DOWN_PNG, IMAGE_RESOURCE_BMP16_CIRCLE_GRAY_BMP};
     uint val_img[] = {IMAGE_RESOURCE_BMP16_ICONS8_RIGHT_UP_PNG, IMAGE_RESOURCE_BMP16_ICONS8_RIGHT_DOWN_PNG, IMAGE_RESOURCE_BMP16_CIRCLE_GRAY_BMP};
     uint sl_marker_img[]    = {IMAGE_RESOURCE_BMP16_STOPLOSTRED_PNG, IMAGE_RESOURCE_BMP16_STOP_GRAY_BMP};
     uint trail_marker_img[] = {IMAGE_RESOURCE_BMP16_TRAILLING_PNG,   IMAGE_RESOURCE_BMP16_STOP_GRAY_BMP};
     for(int row = 0; row < count; row++)
      {
       CIndicatorDE *ind = inds[row];
       s_inds_old[row] = ind;
       //m_table_indicator_PreTradeSymbolMonitor.CellView(0, row).CellType(CELL_BUTTON);
       m_table_indicator_PreTradeSymbolMonitor.CellView(0, row).SetImages(tf_img);
       m_table_indicator_PreTradeSymbolMonitor.SetValue(0, row, TimeframeDescription(tfs[row]));
       m_table_indicator_PreTradeSymbolMonitor.CellView(1, row).SetImages(sig_img);
      //--- Col2: value-slope icon (from Col3's own tracking) prefixing the Indicator label
       MqlParam ind_params[];
       ind.GetMqlParams(ind_params);
       CIndicatorSetting ind_label_setting;
       ind_label_setting.TypeEnum(ind.TypeIndicator());
       ind_label_setting.SetRawParams(ind_params);
       m_table_indicator_PreTradeSymbolMonitor.CellView(2, row).SetImages(val_img);
       m_table_indicator_PreTradeSymbolMonitor.SetValue(2, row, ind_label_setting.DisplayLabel());
      //--- Col3: seeded with the previous bar so the first slope is bar-to-bar, then tick-to-tick
       m_table_indicator_PreTradeSymbolMonitor.Cell(3, row).SetDigits(2);
       m_table_indicator_PreTradeSymbolMonitor.CellView(3, row).DirectionColors(C'0,160,0', C'200,0,0', clrGray);
       double v1 = ind.GetDataBuffer(0, 1);
       if(v1 != EMPTY_VALUE)
          m_table_indicator_PreTradeSymbolMonitor.SetValue(3, row, v1);
       m_table_indicator_PreTradeSymbolMonitor.CellView(4, row).SetImages(sl_marker_img);
       m_table_indicator_PreTradeSymbolMonitor.CellView(5, row).SetImages(trail_marker_img);
      }
    }
   CTradingSetupSetting *row_setting = (m_trading_setup_manager != NULL) ? m_trading_setup_manager.FindByIdentity(symbol) : NULL;
   MqlParam saved_trail_params[];
   MqlParam saved_sl_params[];
   if(row_setting != NULL)
    {
     row_setting.GetTrailingIndParams(saved_trail_params);
     row_setting.GetStopLostIndParams(saved_sl_params);
    }
   //--- Values every call - a cell redraws only when its value really changed
   for(int row = 0; row < count; row++)
    {
     MqlParam ind_params[];
     inds[row].GetMqlParams(ind_params);
     bool tf_active = (symbol == ::Symbol() && tfs[row] == (ENUM_TIMEFRAMES)::Period());
     m_table_indicator_PreTradeSymbolMonitor.CellView(0, row).ChangeImage(tf_active ? 0 : 1);
     double v0 = inds[row].GetDataBuffer(0, 0);
     if(v0 == EMPTY_VALUE)
        m_table_indicator_PreTradeSymbolMonitor.SetValue(3, row, "-");
     else
        m_table_indicator_PreTradeSymbolMonitor.SetValue(3, row, v0);
     CTableCell *value_cell = m_table_indicator_PreTradeSymbolMonitor.Cell(3, row);
     int dir = (value_cell.Datatype() != TYPE_DOUBLE) ? 2 : value_cell.IsIncreased() ? 0 : value_cell.IsDecreased() ? 1 : 2;
     m_table_indicator_PreTradeSymbolMonitor.CellView(2, row).ChangeImage(dir);
     int sig = dir;
     if(m_SignalsCollection != NULL)
      {
       CSignalBase *signal = m_SignalsCollection.GetOrCreateSignal(inds[row]);
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
     m_table_indicator_PreTradeSymbolMonitor.CellView(1, row).ChangeImage(sig);
     //--- Read-only markers: feature icon on the row each one follows, grey dot elsewhere
     bool sl_is_current = (row_setting != NULL && row_setting.StopLostMode() == SL_MODE_INDICATOR &&
                            inds[row].TypeIndicator() == IND_ATR &&
                            row_setting.StopLostIndTF() == tfs[row] &&
                            IsEqualMqlParamArrays(saved_sl_params, ind_params));
     m_table_indicator_PreTradeSymbolMonitor.CellView(4, row).ChangeImage(sl_is_current ? 0 : 1);
     bool trail_is_current = (row_setting != NULL && row_setting.TrailingMode() == SL_MODE_INDICATOR &&
                               row_setting.TrailingIndType() == inds[row].TypeIndicator() &&
                               row_setting.TrailingIndTF()   == tfs[row] &&
                               IsEqualMqlParamArrays(saved_trail_params, ind_params));
     m_table_indicator_PreTradeSymbolMonitor.CellView(5, row).ChangeImage(trail_is_current ? 0 : 1);
    }
   return m_table_indicator_PreTradeSymbolMonitor.Update(false);
  }
 void CGUIPannel::OnSymbolToTradeChanged(const bool move_chart = true)
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
      SyncTable_PositionPretradeView();
      return;
    }
   //m_textlabel_symbol_toTrade.SetText(symbol);
   //m_textlabel_symbol_toTrade.Draw(true);
   //m_frame_trading_setting.SetText(symbol);
   //m_frame_trading_setting.Draw(true);
   if(move_chart && m_SymbolTFManager != NULL)
      m_SymbolTFManager.NotifySettingChanged(symbol, (ENUM_TIMEFRAMES)::Period());
   //SyncTable_PreTradeSymbolMonitor(symbol, true);   // the Monitor follows the chart Symbol, not the Symbol to trade
   SyncTable_PositionPretradeView(true);
   //--- The Trading menu icons follow the Symbol through SyncRunSLTrailingButtonIcons (every tick)
   // CTradingSetupSetting *row_setting = (m_trading_setup_manager != NULL) ? m_trading_setup_manager.FindByIdentity(symbol) : NULL;
   // m_checkbox_use_StopLostSetting.SetState((row_setting != NULL) && row_setting.StopLostActive());
   // m_checkbox_use_TrailingSetting.SetState((row_setting != NULL) && row_setting.TrailingActive());
  }
 //--- "Trading" menu: flips StopLostActive / TrailingActive of the New Order Symbol
 void CGUIPannel::OnClickToggleSLOrTrailing(const bool is_sl)
  {
   if(m_trading_setup_manager == NULL) return;
   string symbol = GetNewOrderSymbol();
   if(symbol == "") return;
   CTradingSetupSetting *row_setting = m_trading_setup_manager.FindByIdentity(symbol);
   if(row_setting == NULL) row_setting = m_trading_setup_manager.Add_TradingSetupSetting(symbol);
   if(row_setting == NULL) return;
   if(is_sl)
      row_setting.StopLostActive(!row_setting.StopLostActive());
   else
      row_setting.TrailingActive(!row_setting.TrailingActive());
   m_trading_setup_manager.NotifySettingChanged(symbol);
   SyncRunSLTrailingButtonIcons(row_setting.StopLostActive(), row_setting.TrailingActive());
   SyncTable_PositionsStoplostAndTrailling(true);
   SyncTable_PositionPretradeView(true);
  }
 void CGUIPannel::SyncRunSLTrailingButtonIcons(const bool sl_active, const bool trail_active)
  {
   static int s_sl_state = -1, s_trail_state = -1;   // -1 = never painted
   if((int)sl_active != s_sl_state)
    {
     s_sl_state = (int)sl_active;
     //m_btn_open_StopLostSetting.IconFile(sl_active ? IMAGE_RESOURCE_BMP16_STOPLOSTRED_PNG : IMAGE_RESOURCE_BMP16_START_GRAY_BMP);
     //m_btn_open_StopLostSetting.Draw(true);
     CMenuItem *sl_item = m_contextmenu_trading.GetItemPointer(MENU_ITEM_TRADING_STOPLOST);
     if(sl_item != NULL)
      {
       sl_item.IconFile(sl_active ? IMAGE_RESOURCE_BMP16_STOPLOSTRED_PNG : IMAGE_RESOURCE_BMP16_START_GRAY_BMP);
       sl_item.Draw(true);
      }
    }
   if((int)trail_active != s_trail_state)
    {
     s_trail_state = (int)trail_active;
     //m_btn_open_TrailingSetting.IconFile(trail_active ? IMAGE_RESOURCE_BMP16_TRAILLING_PNG : IMAGE_RESOURCE_BMP16_START_GRAY_BMP);
     //m_btn_open_TrailingSetting.Draw(true);
     CMenuItem *trail_item = m_contextmenu_trading.GetItemPointer(MENU_ITEM_TRADING_TRAILLING);
     if(trail_item != NULL)
      {
       trail_item.IconFile(trail_active ? IMAGE_RESOURCE_BMP16_TRAILLING_PNG : IMAGE_RESOURCE_BMP16_START_GRAY_BMP);
       trail_item.Draw(true);
      }
    }
  }
 void CGUIPannel::OnClickUseRiskPerNewTradeCheckbox(void)
  {
   if(m_checkbox_use_RiskPerNewTrade.State())
      m_edit_RiskPerNewTrade.Show();
   else
      m_edit_RiskPerNewTrade.Hide();
   //--- Force the Lot list rebuild right now instead of waiting for the next tick
   SyncTable_PositionPretradeView(true);
  }
 //+------------------------------------------------------------------+
 //| Colored SL/Trailling cell of the Monitor clicked - opens          |
 //| m_window_setting_trading on the matching tab                      |
 //+------------------------------------------------------------------+
 void CGUIPannel::OnClickOpenTradingSettingTab(const ENUM_TAB_SETTING_TRADING tab)
  {
   OpenWindow_SettingTrading();
   m_tabs_setting_trading.SelectTab(tab);
   HideStopLostForm();
   HideTrailingForm();
   ::ChartRedraw(m_chart_id);
  }
 void CGUIPannel::OnClickTogglePretradeDirection(void)
  {
   m_new_order_is_buy = (m_table_position_pretrade_view.Cell(COL_PTV_DIR, 0).ValueL() == CANV_ELEMENT_CHEK_STATE_UNCHECKED);
   UpdateSendButtonAppearance();
   SyncTable_PositionPretradeView();
  }
 //+------------------------------------------------------------------+
 //| StopLost type icon click (COL_PTV_SLTYPE) - toggles Fixed/        |
 //| Indicator for the NEW trade about to be sent                     |
 //+------------------------------------------------------------------+
 void CGUIPannel::OnClickTogglePretradeSLType(void)
  {
   if(m_trading_setup_manager == NULL) return;
   string symbol = GetNewOrderSymbol();
   if(symbol == "") return;
   CTradingSetupSetting *row_setting = m_trading_setup_manager.FindByIdentity(symbol);
   if(row_setting == NULL) row_setting = m_trading_setup_manager.Add_TradingSetupSetting(symbol);
   if(row_setting == NULL) return;
   bool fixed = (m_table_position_pretrade_view.Cell(COL_PTV_SLTYPE, 0).ValueL() == CANV_ELEMENT_CHEK_STATE_UNCHECKED);
   row_setting.StopLostMode(fixed ? SL_MODE_FIXED : SL_MODE_INDICATOR);
   m_trading_setup_manager.NotifySettingChanged(symbol);
   SyncTable_PositionPretradeView(true);
  }
 //+------------------------------------------------------------------+
 //| Trailing type icon click (COL_PTV_TRAILTYPE) - same as above      |
 //+------------------------------------------------------------------+
 void CGUIPannel::OnClickTogglePretradeTrailType(void)
  {
   if(m_trading_setup_manager == NULL) return;
   string symbol = GetNewOrderSymbol();
   if(symbol == "") return;
   CTradingSetupSetting *row_setting = m_trading_setup_manager.FindByIdentity(symbol);
   if(row_setting == NULL) row_setting = m_trading_setup_manager.Add_TradingSetupSetting(symbol);
   if(row_setting == NULL) return;
   bool fixed = (m_table_position_pretrade_view.Cell(COL_PTV_TRAILTYPE, 0).ValueL() == CANV_ELEMENT_CHEK_STATE_UNCHECKED);
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
   int order_type_idx = m_combobox_order_type.GetListViewPointer().SelectedItemIndex();
   if(order_type_idx == 3) return;   // Stop Limit not supported yet
   double price = ::StringToDouble(m_edit_order_type_value.GetValue());
   m_tradingEngine.SendNewOrder(symbol, dir, lot, order_type_idx, price);
  }
#endif // CGUIPANNEL_MAINWINDOWS_TABTRADING_MQH
