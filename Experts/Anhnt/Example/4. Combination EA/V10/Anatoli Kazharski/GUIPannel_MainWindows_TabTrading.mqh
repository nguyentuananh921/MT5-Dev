//+------------------------------------------------------------------+
//|                           GUIPannel_MainWindows_TabTrading.mqh |
//+------------------------------------------------------------------+
#ifndef CGUIPANNEL_MAINWINDOWS_TABTRADING_MQH
#define CGUIPANNEL_MAINWINDOWS_TABTRADING_MQH
 #include "GUIPannel.mqh"  
 //+------------------------------------------------------------------+
 //| Create m_table_positions_StoplostAndTrailling (TAB_TAB_MAIN_TRADING)|
 //+------------------------------------------------------------------+
 bool CGUIPannel::CreateTable_PositionsStoplostAndTrailling(const int x, const int y)
  {
   m_table_positions_StoplostAndTrailling.MainPointer(m_tabs_main);
   m_tabs_main.AddToElementsArray(TAB_TAB_MAIN_TRADING, m_table_positions_StoplostAndTrailling);

   //  index:  0    1    2    3    4    5    6    7    8    9    10
   //  col:  SYMBOL DIR VOLUME NO SLTYPE SLPRICE SLPROFIT RUN_SL TRAILTYPE RUN_TRAIL PROFIT
    int width[COLUMNS_POS_SL_TRAIL_TOTAL]        = {M_SYMBOL_WIDTH, 20, 35, 30, 55, 65, 50, 20, 55, 20, 45};
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
   //--- COL_PST_DIR needs no text offset override - icon-only column, no text drawn there at all.
   text_x_offset[COL_PST_SLTYPE]    = 22;   // clear the checkbox icon, room for "Fix"/"Ind" text
   text_x_offset[COL_PST_TRAILTYPE] = 22;
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
   int count = m_tradingEngine.GetPositionsSymbolsAndDirections(symbols, dirs);
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
       m_table_positions_StoplostAndTrailling.DeleteAllRows();
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
     uint chk[]     = {IMAGE_RESOURCE_BMP16_CHECKBOX_ON_G_PNG, IMAGE_RESOURCE_BMP16_CHECKBOX_OFF_G_PNG};
     uint dir_img[] = {IMAGE_RESOURCE_BMP16_ORDER_BUY_PNG, IMAGE_RESOURCE_BMP16_ORDER_SELL_PNG};
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
       m_table_positions_StoplostAndTrailling.SetValue(COL_PST_VOLUME, row, ::DoubleToString(m_tradingEngine.PositionsVolumeTotal(sym, type), 2));
       m_table_positions_StoplostAndTrailling.SetValue(COL_PST_NO, row, (string)m_tradingEngine.PositionsTotal(sym, type));

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

       m_table_positions_StoplostAndTrailling.CellType(COL_PST_SLTYPE, row, CELL_CHECKBOX);
       m_table_positions_StoplostAndTrailling.SetImages(COL_PST_SLTYPE, row, chk);
       m_table_positions_StoplostAndTrailling.ChangeImage(COL_PST_SLTYPE, row, sl_fixed ? 0 : 1);
       m_table_positions_StoplostAndTrailling.SetValue(COL_PST_SLTYPE, row, sl_fixed ? "Fix" : "Ind");

       m_table_positions_StoplostAndTrailling.CellType(COL_PST_RUN_SL, row, CELL_CHECKBOX);
       m_table_positions_StoplostAndTrailling.SetImages(COL_PST_RUN_SL, row, chk);
       m_table_positions_StoplostAndTrailling.ChangeImage(COL_PST_RUN_SL, row, sl_active ? 0 : 1);

       m_table_positions_StoplostAndTrailling.CellType(COL_PST_TRAILTYPE, row, CELL_CHECKBOX);
       m_table_positions_StoplostAndTrailling.SetImages(COL_PST_TRAILTYPE, row, chk);
       m_table_positions_StoplostAndTrailling.ChangeImage(COL_PST_TRAILTYPE, row, trail_fixed ? 0 : 1);
       m_table_positions_StoplostAndTrailling.SetValue(COL_PST_TRAILTYPE, row, trail_fixed ? "Fix" : "Ind");

       m_table_positions_StoplostAndTrailling.CellType(COL_PST_RUN_TRAIL, row, CELL_CHECKBOX);
       m_table_positions_StoplostAndTrailling.SetImages(COL_PST_RUN_TRAIL, row, chk);
       m_table_positions_StoplostAndTrailling.ChangeImage(COL_PST_RUN_TRAIL, row, trail_active ? 0 : 1);

       int digits = (int)::SymbolInfoInteger(sym, SYMBOL_DIGITS);
      //--- Best-of StopLost/Trailing target (Anhnt/Claude, 2026-09-08) - what ApplyStopLostAndTrailing
      //--- would actually target right now, not StopLost's own formula in isolation.
       bool sl_price_from_trail;
       double sl_price   = m_tradingEngine.GetPreviewSLTargetPrice(sym, type, sl_price_from_trail);
       double sl_profit  = m_tradingEngine.GetPreviewSLMoneyValue(sym, type);
       double profit     = m_tradingEngine.PositionsFloatingProfitTotal(sym, type);
       s_sl_price_old[row]  = sl_price;
       s_sl_profit_old[row] = sl_profit;
       s_profit_old[row]    = profit;
       m_table_positions_StoplostAndTrailling.SetValue(COL_PST_SLPRICE, row, (sl_price == EMPTY_VALUE) ? "-" : ::DoubleToString(sl_price, digits));
      //--- SL Profit = the money LOST if the previewed SL is hit, so shown negative -
      //--- GetPreviewSLMoneyValue() itself returns a plain magnitude, so the "-" is only added here.
       m_table_positions_StoplostAndTrailling.SetValue(COL_PST_SLPROFIT, row, (sl_profit == EMPTY_VALUE) ? "-" : "-$" + ::DoubleToString(sl_profit, 2));
       m_table_positions_StoplostAndTrailling.SetValue(COL_PST_PROFIT, row, ::DoubleToString(profit, 2));
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
       string v_vol = ::DoubleToString(m_tradingEngine.PositionsVolumeTotal(sym, type), 2);
       if(force || v_vol != m_table_positions_StoplostAndTrailling.GetValue(COL_PST_VOLUME, row))
        {
         m_table_positions_StoplostAndTrailling.SetValue(COL_PST_VOLUME, row, v_vol, 0, true);
         any_changed = true;
        }
       string v_no = (string)m_tradingEngine.PositionsTotal(sym, type);
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
         m_table_positions_StoplostAndTrailling.SetValue(COL_PST_SLTYPE, row, sl_fixed ? "Fix" : "Ind", 0, true);
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
         m_table_positions_StoplostAndTrailling.SetValue(COL_PST_TRAILTYPE, row, trail_fixed ? "Fix" : "Ind", 0, true);
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
         m_table_positions_StoplostAndTrailling.SetValue(COL_PST_SLPRICE, row, (sl_price == EMPTY_VALUE) ? "-" : ::DoubleToString(sl_price, digits), 0, true);
         m_table_positions_StoplostAndTrailling.TextColor(COL_PST_SLPRICE, row, clr, true);
         any_changed = true;
        }
       double prev_sl_profit = s_sl_profit_old[row];
       double sl_profit = m_tradingEngine.GetPreviewSLMoneyValue(sym, type);
       if(force || sl_profit != prev_sl_profit)
        {
      //--- Polarity flipped vs SL Price's own dir check above: sl_profit is a magnitude, but shown
      //--- negative (money LOST if SL hit) - a growing magnitude means a WORSE (bigger) loss, so
      //--- that's red, not green.
         int dir = (prev_sl_profit == EMPTY_VALUE || sl_profit == EMPTY_VALUE) ? 2 : (sl_profit > prev_sl_profit) ? 1 : (sl_profit < prev_sl_profit) ? 0 : 2;
         color clr = (dir == 0) ? C'0,160,0' : (dir == 1) ? C'200,0,0' : clrGray;
         s_sl_profit_old[row] = sl_profit;
         m_table_positions_StoplostAndTrailling.SetValue(COL_PST_SLPROFIT, row, (sl_profit == EMPTY_VALUE) ? "-" : "-$" + ::DoubleToString(sl_profit, 2), 0, true);
         m_table_positions_StoplostAndTrailling.TextColor(COL_PST_SLPROFIT, row, clr, true);
         any_changed = true;
        }
       double prev_profit = s_profit_old[row];
       double profit = m_tradingEngine.PositionsFloatingProfitTotal(sym, type);
       if(force || profit != prev_profit)
        {
         //--- No "first tick" sentinel needed here (unlike Mid's -1 init) - the full-rebuild branch
         //--- above always seeds s_profit_old[] with a real value before this per-tick branch ever runs.
         int dir = (profit > prev_profit) ? 0 : (profit < prev_profit) ? 1 : 2;
         color clr = (dir == 0) ? C'0,160,0' : (dir == 1) ? C'200,0,0' : clrGray;
         s_profit_old[row] = profit;
         m_table_positions_StoplostAndTrailling.SetValue(COL_PST_PROFIT, row, ::DoubleToString(profit, 2), 0, true);
         m_table_positions_StoplostAndTrailling.TextColor(COL_PST_PROFIT, row, clr, true);
         any_changed = true;
        }
     }
   if(any_changed) m_table_positions_StoplostAndTrailling.Update(false);
   return any_changed;
  }
 void CGUIPannel::OnCheckTable_PositionsStoplostAndTrailling(const int row, const int col)
  {
   if(m_trading_setup_manager == NULL) return;
   string sym = m_table_positions_StoplostAndTrailling.GetValue(COL_PST_SYMBOL, row);
   if(sym == "") return;
   CTradingSetupSetting *row_setting = m_trading_setup_manager.FindByIdentity(sym);
   if(row_setting == NULL) row_setting = m_trading_setup_manager.Add_TradingSetupSetting(sym);
   if(row_setting == NULL) return;
   //--- Raw index 0 == checked/true, matching OnClickToggleBuySignal's own convention - see the
   //--- ChangeImage(...,cond?0:1) calls above, not the CHECKBOX_STATE_ON/OFF named constants.
   if(col == COL_PST_SLTYPE)
    {
     bool checked = ((int)m_table_positions_StoplostAndTrailling.SelectedImageIndex(COL_PST_SLTYPE, row) == 0);
     row_setting.StopLostMode(checked ? SL_MODE_FIXED : SL_MODE_INDICATOR);
     m_table_positions_StoplostAndTrailling.SetValue(COL_PST_SLTYPE, row, checked ? "Fix" : "Ind", 0, true);
    }
   else if(col == COL_PST_RUN_SL)
    {
     bool checked = ((int)m_table_positions_StoplostAndTrailling.SelectedImageIndex(COL_PST_RUN_SL, row) == 0);
     row_setting.StopLostActive(checked);
    }
   else if(col == COL_PST_TRAILTYPE)
    {
     bool checked = ((int)m_table_positions_StoplostAndTrailling.SelectedImageIndex(COL_PST_TRAILTYPE, row) == 0);
     row_setting.TrailingMode(checked ? SL_MODE_FIXED : SL_MODE_INDICATOR);
     m_table_positions_StoplostAndTrailling.SetValue(COL_PST_TRAILTYPE, row, checked ? "Fix" : "Ind", 0, true);
    }
   else if(col == COL_PST_RUN_TRAIL)
    {
     bool checked = ((int)m_table_positions_StoplostAndTrailling.SelectedImageIndex(COL_PST_RUN_TRAIL, row) == 0);
     row_setting.TrailingActive(checked);
    }
   else
     return;
   m_trading_setup_manager.NotifySettingChanged(sym);
   //--- Force-refresh right away (Anhnt/Claude, 2026-09-08) - SL Price/SL Profit (and everything
   //--- else) read StopLostMode()/TrailingMode() live already, but the per-tick Sync in OnTickEvent
   //--- would otherwise only pick the change up on the NEXT market tick, which can visibly lag a
   //--- checkbox click during quiet periods. "tớ muốn Update cái cột SL Price và cột bên cạnh mỗi
   //--- Tick ấy" - update immediately on the click itself, not wait for a price tick.
   SyncTable_PositionsStoplostAndTrailling(true);
  }

 //+------------------------------------------------------------------+
 //| New Order form (Anhnt/Claude, 2026-09-03) - Symbol/Lot/Direction/  |
 //| Order Type + Send button, below the SL Setting form. First draft   |
 //| per user request ("lựa create... rồi mình điều chỉnh") - always    |
 //| visible (no Hide()/Show() gating like the SL form has). Actual     |
 //| OrderSend wiring not done yet - controls + Send button's adaptive  |
 //| text/color only.                                                    |
 //+------------------------------------------------------------------+
 bool CGUIPannel::CreateTradingForm(const int x_gap, const int y_gap)
  {
   //--- Every control here unified to M_SYMBOL_WIDTH, single column stacked top-to-bottom
    int row0_y = y_gap;                          // Symbol
    int row1_y = y_gap + M_CONTROL_YDISTANCE;    // Lot
    int row2_y = y_gap + 2*M_CONTROL_YDISTANCE;  // Direction
    int row3_y = y_gap + 3*M_CONTROL_YDISTANCE;  // Order Type
    int row4_y = y_gap + 4*M_CONTROL_YDISTANCE;  // Use SL Setting checkbox
    int row5_y = y_gap + 5*M_CONTROL_YDISTANCE;  // Use Trailing Setting checkbox
    int row6_y = y_gap + 6*M_CONTROL_YDISTANCE;  // Use Risk % Per Trade checkbox
    int row7_y = y_gap + 7*M_CONTROL_YDISTANCE;  // Risk % caption + edit
    int row8_y = y_gap + 8*M_CONTROL_YDISTANCE;  // Send button
   //--- Symbol - same tracked-Symbol list as m_table_stoplostsetting's own rows (already built by
   //--- CreateTable_PreTradeSymbolInfo, called before this), read straight off the table instead
   //--- of re-deriving the Layer1-union-MarketWatch list a second time.
    m_combobox_symbol_toTrade.MainPointer(m_tabs_main);
    m_tabs_main.AddToElementsArray(TAB_TAB_MAIN_TRADING, m_combobox_symbol_toTrade);
    m_combobox_symbol_toTrade.XSize(M_SYMBOL_WIDTH);
    m_combobox_symbol_toTrade.YSize(M_CONTROL_HEIGHT);
    m_combobox_symbol_toTrade.GetButtonPointer().XGap(1);
    m_combobox_symbol_toTrade.GetButtonPointer().XSize(M_SYMBOL_WIDTH);
    if(!m_combobox_symbol_toTrade.CreateComboBox("", x_gap, row0_y)) return false;
   CWndContainer::AddToElementsArray(WindowIdx(m_window_main), m_combobox_symbol_toTrade);
    {
     int sym_total = (int)m_table_stoplostsetting.RowsTotal();
     m_combobox_symbol_toTrade.ItemsTotal(sym_total);
     int list_h = 18 * ::MathMax(sym_total, 1) + 4;
     if(list_h > 300) list_h = 300;
     m_combobox_symbol_toTrade.GetListViewPointer().YSize(list_h);
     m_combobox_symbol_toTrade.GetListViewPointer().Rebuilding(sym_total);
     //--- Default-select the CURRENT chart Symbol (Anhnt/Claude, 2026-09-08), not always index 0.
      int chart_sym_idx = -1;
      for(int i = 0; i < sym_total; i++)
       {
        string sym_text = m_table_stoplostsetting.GetValue(0, i);
        m_combobox_symbol_toTrade.SetValue(i, sym_text);
        if(sym_text == ::Symbol()) chart_sym_idx = i;
       }
     if(sym_total > 0) m_combobox_symbol_toTrade.SelectItem((chart_sym_idx >= 0) ? chart_sym_idx : 0);
     m_combobox_symbol_toTrade.GetListViewPointer().Update(true);
     m_combobox_symbol_toTrade.GetListViewPointer().Hide();
     m_combobox_symbol_toTrade.GetButtonPointer().IsPressed(false);
    }
   //--- Lot - placeholder preset list (Anhnt, 2026-09-03) - not yet derived from SYMBOL_VOLUME_MIN/
   //--- STEP per Symbol or from the Risk%/Distance calc above; revisit once that's wired.
    m_combobox_lot_toTrade.MainPointer(m_tabs_main);
    m_tabs_main.AddToElementsArray(TAB_TAB_MAIN_TRADING, m_combobox_lot_toTrade);
    m_combobox_lot_toTrade.XSize(M_SYMBOL_WIDTH);
    m_combobox_lot_toTrade.YSize(M_CONTROL_HEIGHT);
    m_combobox_lot_toTrade.GetButtonPointer().XGap(1);
    m_combobox_lot_toTrade.GetButtonPointer().XSize(M_SYMBOL_WIDTH);
    if(!m_combobox_lot_toTrade.CreateComboBox("", x_gap, row1_y)) return false;
   CWndContainer::AddToElementsArray(WindowIdx(m_window_main), m_combobox_lot_toTrade);
    {
     string lot_presets[] = {"0.01", "0.05", "0.1", "0.5", "1.0"};
     int lot_total = ::ArraySize(lot_presets);
     m_combobox_lot_toTrade.ItemsTotal(lot_total);
     m_combobox_lot_toTrade.GetListViewPointer().Rebuilding(lot_total);
     for(int i = 0; i < lot_total; i++)
        m_combobox_lot_toTrade.SetValue(i, lot_presets[i]);
     m_combobox_lot_toTrade.SelectItem(0);
     m_combobox_lot_toTrade.GetListViewPointer().Update(true);
     m_combobox_lot_toTrade.GetListViewPointer().Hide();
     m_combobox_lot_toTrade.GetButtonPointer().IsPressed(false);
    }
   //--- Direction (Buy/Sell) - drives m_btn_send_toTrade's color 
    m_combobox_direction.MainPointer(m_tabs_main);
    m_tabs_main.AddToElementsArray(TAB_TAB_MAIN_TRADING, m_combobox_direction);
    m_combobox_direction.XSize(M_SYMBOL_WIDTH);
    m_combobox_direction.YSize(M_CONTROL_HEIGHT);
    m_combobox_direction.GetButtonPointer().XGap(1);
    m_combobox_direction.GetButtonPointer().XSize(M_SYMBOL_WIDTH);
    if(!m_combobox_direction.CreateComboBox("", x_gap, row2_y)) return false;
    CWndContainer::AddToElementsArray(WindowIdx(m_window_main), m_combobox_direction);
    m_combobox_direction.ItemsTotal(2);
    m_combobox_direction.GetListViewPointer().Rebuilding(2);
    m_combobox_direction.SetValue(0, "Buy");
    m_combobox_direction.SetValue(1, "Sell");
    m_combobox_direction.SelectItem(0);
    m_combobox_direction.GetListViewPointer().Update(true);
    m_combobox_direction.GetListViewPointer().Hide();
    m_combobox_direction.GetButtonPointer().IsPressed(false);
   //--- Order Type (Market/Limit/Stop/Stop Limit) - drives m_btn_send_toTrade's  
    m_combobox_order_type.MainPointer(m_tabs_main);
    m_tabs_main.AddToElementsArray(TAB_TAB_MAIN_TRADING, m_combobox_order_type);
    m_combobox_order_type.XSize(M_SYMBOL_WIDTH);
    m_combobox_order_type.YSize(M_CONTROL_HEIGHT);
    m_combobox_order_type.GetButtonPointer().XGap(1);
    m_combobox_order_type.GetButtonPointer().XSize(M_SYMBOL_WIDTH);
    if(!m_combobox_order_type.CreateComboBox("", x_gap, row3_y)) return false;
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
   //--- Use SL Setting - whether to apply the per-Symbol Distance from the form above to this order.
    m_checkbox_use_StopLostSetting.MainPointer(m_tabs_main);
    m_tabs_main.AddToElementsArray(TAB_TAB_MAIN_TRADING, m_checkbox_use_StopLostSetting);
   //--- CCheckBox defaults to YSize=14 (CheckBox.mqh:96), the one Library control that doesn't
   //--- match everything else's 20 - force M_CONTROL_HEIGHT so this row lines up with the rest.
    m_checkbox_use_StopLostSetting.YSize(M_CONTROL_HEIGHT);
    if(!m_checkbox_use_StopLostSetting.CreateCheckBox("Use SL Setting", x_gap, row4_y)) return false;
    CWndContainer::AddToElementsArray(WindowIdx(m_window_main), m_checkbox_use_StopLostSetting);
   //--- CreateCanvas() (CheckBox.mqh) unconditionally sets the ON icon to CHECKBOX_ON_BMP, which
   //--- doesn't match the OFF icon's own "_G_" style (CHECKBOX_OFF_G_PNG) - the mismatch made the
   //--- 2 states hard to tell apart (Anhnt, 2026-09-04: "khó nhận biết trạng thái"). Override with
   //--- the matching ON_G_PNG AFTER CreateCheckBox(), since CreateCanvas() sets its default
   //--- unconditionally (setting this before creation would just get overwritten).
    m_checkbox_use_StopLostSetting.IconFilePressed(IMAGE_RESOURCE_BMP16_CHECKBOX_ON_G_PNG);
    m_checkbox_use_StopLostSetting.IsPressed(true);
   //--- Use Trailing Setting controls + layout only, no wiring yet.
    m_checkbox_use_TrailingSetting.MainPointer(m_tabs_main);
    m_tabs_main.AddToElementsArray(TAB_TAB_MAIN_TRADING, m_checkbox_use_TrailingSetting);
    m_checkbox_use_TrailingSetting.YSize(M_CONTROL_HEIGHT);
    if(!m_checkbox_use_TrailingSetting.CreateCheckBox("Use Trailing Setting", x_gap, row5_y)) return false;
    CWndContainer::AddToElementsArray(WindowIdx(m_window_main), m_checkbox_use_TrailingSetting);
    m_checkbox_use_TrailingSetting.IconFilePressed(IMAGE_RESOURCE_BMP16_CHECKBOX_ON_G_PNG);
    m_checkbox_use_TrailingSetting.IsPressed(true);
   //--- Use Risk % Per Trade checkbox + caption/edit row below it.
   //--- Controls + layout only for now - not wired to m_combobox_lot_toTrade yet
    m_checkbox_use_RiskPerNewTrade.MainPointer(m_tabs_main);
    m_tabs_main.AddToElementsArray(TAB_TAB_MAIN_TRADING, m_checkbox_use_RiskPerNewTrade);
    m_checkbox_use_RiskPerNewTrade.YSize(M_CONTROL_HEIGHT);
    if(!m_checkbox_use_RiskPerNewTrade.CreateCheckBox("Use Risk % Per Trade", x_gap, row6_y)) return false;
    CWndContainer::AddToElementsArray(WindowIdx(m_window_main), m_checkbox_use_RiskPerNewTrade);
    m_checkbox_use_RiskPerNewTrade.IconFilePressed(IMAGE_RESOURCE_BMP16_CHECKBOX_ON_G_PNG);
    m_checkbox_use_RiskPerNewTrade.IsPressed(false);
   // Risk Pertrade
    m_textLabel_use_RiskPerNewTrade.MainPointer(m_tabs_main);
    m_tabs_main.AddToElementsArray(TAB_TAB_MAIN_TRADING, m_textLabel_use_RiskPerNewTrade);
    m_textLabel_use_RiskPerNewTrade.XSize(50);
    m_textLabel_use_RiskPerNewTrade.YSize(M_CONTROL_HEIGHT);
    if(!m_textLabel_use_RiskPerNewTrade.CreateTextLabel("Risk %", x_gap, row7_y)) return false;
    CWndContainer::AddToElementsArray(WindowIdx(m_window_main), m_textLabel_use_RiskPerNewTrade);
   // PerTrade Edit Control
    m_edit_RiskPerNewTrade.MainPointer(m_tabs_main);
    m_tabs_main.AddToElementsArray(TAB_TAB_MAIN_TRADING, m_edit_RiskPerNewTrade);
    m_edit_RiskPerNewTrade.XSize(M_SYMBOL_WIDTH - 50);
    m_edit_RiskPerNewTrade.YSize(M_CONTROL_HEIGHT);
    m_edit_RiskPerNewTrade.GetTextBoxPointer().XGap(1);
    if(!m_edit_RiskPerNewTrade.CreateTextEdit("5", x_gap + 50, row7_y)) return false;
    CWndContainer::AddToElementsArray(WindowIdx(m_window_main), m_edit_RiskPerNewTrade);
   //--- Send button - color/text adapt to Direction+Order Type. Actual OrderSend wiring not done
   //--- yet - first draft, controls only.
    m_btn_send_toTrade.MainPointer(m_tabs_main);
    m_tabs_main.AddToElementsArray(TAB_TAB_MAIN_TRADING, m_btn_send_toTrade);
    m_btn_send_toTrade.XSize(M_SYMBOL_WIDTH);
    m_btn_send_toTrade.YSize(M_CONTROL_HEIGHT);
    if(!m_btn_send_toTrade.CreateButton("Buy", x_gap, row8_y)) return false;
    CWndContainer::AddToElementsArray(WindowIdx(m_window_main), m_btn_send_toTrade);
    UpdateSendButtonAppearance();
   return true;
  } 
 void CGUIPannel::UpdateSendButtonAppearance(void)
  {
   int dir_idx  = (int)m_combobox_direction.GetListViewPointer().SelectedItemIndex();
   int type_idx = (int)m_combobox_order_type.GetListViewPointer().SelectedItemIndex();
   bool is_buy = (dir_idx != 1); // default to Buy if nothing selected yet (dir_idx<0)
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
  }
 //+------------------------------------------------------------------+
 //| m_table_indicator_PreTradeSymbolMonitor - same TF|Indicator|Value|Trailing shape as             |
 //| m_table_indicators_trailingsetting (Setting Trading window's Trailing tab), scoped to            |
 //| m_combobox_symbol_toTrade's current selection instead of a "Symbol - X" label (Anhnt/Claude,      |
 //| 2026-09-08 - shares BuildTrailingIndicatorChoiceList's Trend-group/1-buffer filtered core).       |
 //+------------------------------------------------------------------+
 bool CGUIPannel::CreateTable_PreTradeSymbolMonitor(const int x, const int y)
  {
   #define COLUMNS_PRETRADEMON_TOTAL 5
   m_table_indicator_PreTradeSymbolMonitor.MainPointer(m_tabs_main);
   m_tabs_main.AddToElementsArray(TAB_TAB_MAIN_TRADING, m_table_indicator_PreTradeSymbolMonitor);   
   // Symbol|TF|Signal|Indicator|Value|... layout 
   int width[COLUMNS_PRETRADEMON_TOTAL]           = {M_TF_WIDTH, 22, INDICATOR_PARATEXT_WIDTH, INDICATOR_VALUE_WIDTH, 30};
   ENUM_ALIGN_MODE align[COLUMNS_PRETRADEMON_TOTAL] = {ALIGN_LEFT, ALIGN_LEFT, ALIGN_LEFT, ALIGN_RIGHT, ALIGN_LEFT};
   int text_x_offset[COLUMNS_PRETRADEMON_TOTAL]   = {22, 5, 22, 5, 5}; // col0/col2: clear their own icon
   int image_x_offset[COLUMNS_PRETRADEMON_TOTAL]  = {3, 3, 3, 0, 10};
   int image_y_offset[COLUMNS_PRETRADEMON_TOTAL]  = {3, 3, 3, 0, 3};
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
   //--- Icon-only header (no text) to save width, same convention as m_table_positions_
   //--- StoplostAndTrailling's own Trailling column below (Anhnt/Claude, 2026-09-08).
    {
     uint trailling_col_img[] = {IMAGE_RESOURCE_BMP16_TRAILLING_PNG};
     m_table_indicator_PreTradeSymbolMonitor.SetHeaderText(4, "");
     m_table_indicator_PreTradeSymbolMonitor.SetHeaderImage(4, trailling_col_img);
    }
   CWndContainer::AddToElementsArray(WindowIdx(m_window_main), m_table_indicator_PreTradeSymbolMonitor);
   return true;
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
   if(symbol != s_scoped_symbol) { s_scoped_symbol = symbol; force = true; }
   CIndicatorDE   *inds[];
   ENUM_TIMEFRAMES tfs[];
   int count = m_tradingEngine.BuildTrailingIndicatorChoiceList(symbol, inds, tfs);

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
       s_row_count = 0;
       m_table_indicator_PreTradeSymbolMonitor.Update(true);
       return true;
      }
     ::ArrayResize(s_val_old, count);
     ::ArrayResize(s_dir_old, count);
     ::ArrayResize(s_sig_old, count);
     ::ArrayResize(s_tf_active_old, count);
     ::ArrayInitialize(s_val_old, EMPTY_VALUE);
     ::ArrayInitialize(s_dir_old, -1);
     ::ArrayInitialize(s_sig_old, -1);
     ::ArrayInitialize(s_tf_active_old, false);
     uint tf_img[]  = {IMAGE_RESOURCE_BMP16_BAR_CHART_BMP, IMAGE_RESOURCE_BMP16_BAR_CHART_COLORLESS_BMP};
     uint sig_img[] = {IMAGE_RESOURCE_BMP16_ARROW_UP_PNG, IMAGE_RESOURCE_BMP16_ARROW_DOWN_PNG, IMAGE_RESOURCE_BMP16_CIRCLE_GRAY_BMP};
     uint val_img[] = {IMAGE_RESOURCE_BMP16_ICONS8_RIGHT_UP_PNG, IMAGE_RESOURCE_BMP16_ICONS8_RIGHT_DOWN_PNG, IMAGE_RESOURCE_BMP16_CIRCLE_GRAY_BMP};
     CTradingSetupSetting *row_setting = (m_trading_setup_manager != NULL) ? m_trading_setup_manager.FindByIdentity(symbol) : NULL;
     MqlParam saved_params[];
     if(row_setting != NULL) row_setting.GetTrailingIndParams(saved_params);
     uint chk[] = {IMAGE_RESOURCE_BMP16_CHECKBOX_ON_G_PNG, IMAGE_RESOURCE_BMP16_CHECKBOX_OFF_G_PNG};
     for(int i = 0; i < count - 1; i++)
        m_table_indicator_PreTradeSymbolMonitor.AddRow(i, i == count - 2);
     for(int row = 0; row < count; row++)
      {
       CIndicatorDE *ind = inds[row];
       bool tf_active = (tfs[row] == (ENUM_TIMEFRAMES)::Period());
       s_tf_active_old[row] = tf_active;
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
       if(m_timeSeriesEngine != NULL)
        {
         CSignalBase *signal = m_timeSeriesEngine.GetSignalsCollection().GetOrCreateSignal(ind);
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
       bool is_current = (row_setting != NULL && row_setting.TrailingMode() == SL_MODE_INDICATOR &&
                           row_setting.TrailingIndType() == ind.TypeIndicator() &&
                           row_setting.TrailingIndTF()   == tfs[row] &&
                           IsEqualMqlParamArrays(saved_params, ind_params));
       m_table_indicator_PreTradeSymbolMonitor.CellType(4, row, CELL_CHECKBOX);
       m_table_indicator_PreTradeSymbolMonitor.SetImages(4, row, chk);
       m_table_indicator_PreTradeSymbolMonitor.ChangeImage(4, row, is_current ? 0 : 1);
      }
     s_row_count = count;
     m_table_indicator_PreTradeSymbolMonitor.Update(true);
     return true;
    }
   //--- Per-tick: re-derive each Indicator's CURRENT visual row (sort can reorder), then dirty-check.
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

      bool tf_active = (tfs[i] == (ENUM_TIMEFRAMES)::Period());
      if(tf_active != s_tf_active_old[row])
       {
        s_tf_active_old[row] = tf_active;
        m_table_indicator_PreTradeSymbolMonitor.ChangeImage(0, row, tf_active ? 0 : 1, true);
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
      if(m_timeSeriesEngine != NULL)
       {
        CSignalBase *signal = m_timeSeriesEngine.GetSignalsCollection().GetOrCreateSignal(inds[i]);
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
 //+------------------------------------------------------------------+
 //| Checkbox click on m_table_indicator_PreTradeSymbolMonitor - same radio-like commit as             |
 //| OnCheckTable_IndicatorsTrailingSetting, sourced from m_combobox_symbol_toTrade instead of a         |
 //| "Symbol - X" label.                                                                                 |
 //+------------------------------------------------------------------+
 void CGUIPannel::OnCheckTable_PreTradeSymbolMonitor(const int row)
  {
   string symbol = m_combobox_symbol_toTrade.GetValue();
   if(symbol == "" || m_trading_setup_manager == NULL) return;
   string want_tf_text  = m_table_indicator_PreTradeSymbolMonitor.GetValue(0, row);
   string want_ind_text = m_table_indicator_PreTradeSymbolMonitor.GetValue(2, row);

   CIndicatorDE   *inds[];
   ENUM_TIMEFRAMES tfs[];
   int count = m_tradingEngine.BuildTrailingIndicatorChoiceList(symbol, inds, tfs);
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
     SyncTable_PreTradeSymbolMonitor(symbol, true);
     return;
    }
  }
 //+------------------------------------------------------------------+
 //| m_combobox_symbol_toTrade selection changed (ON_CHANGE_GUI) - set the chart to the newly picked   |
 //| Symbol (same SymbolTFManager::NotifySettingChanged -> EA.mq5's ChartSetSymbolPeriod path every     |
 //| other Symbol-click handler already uses) and force-resync the Monitor table to it.                 |
 //+------------------------------------------------------------------+
 void CGUIPannel::OnSymbolToTradeChanged(void)
  {
   string symbol = m_combobox_symbol_toTrade.GetValue();
   if(symbol == "") return;
   if(m_SymbolTFManager != NULL)
      m_SymbolTFManager.NotifySettingChanged(symbol, (ENUM_TIMEFRAMES)::Period());
   SyncTable_PreTradeSymbolMonitor(symbol, true);
  }
#endif // CGUIPANNEL_MAINWINDOWS_TABTRADING_MQH

