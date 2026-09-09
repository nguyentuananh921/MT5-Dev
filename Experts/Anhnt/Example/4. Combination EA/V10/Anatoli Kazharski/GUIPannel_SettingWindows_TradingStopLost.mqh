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
    // col: Symbol | Price | [Spread] | [gear] | [Fixed]Point | [Indicator]Point | [Fixed]Value | [Indicator]Value
    m_table_stoplostsetting.MainPointer(m_tabs_setting_trading);
    m_tabs_setting_trading.AddToElementsArray(ENUM_TAB_SETTING_TRADING_STOPLOST,m_table_stoplostsetting);
    int width[COLUMNS3_TOTAL]           = {M_SYMBOL_WIDTH, 70, 35, 25, 60, 60, 70, 70};
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
    m_table_stoplostsetting.SetHeaderText(1, "Price");
    uint spread_header_img[] = {IMAGE_RESOURCE_BMP16_SPREADRED_PNG};
    m_table_stoplostsetting.SetHeaderText(2, "");
    m_table_stoplostsetting.SetHeaderImage(2, spread_header_img);
    uint gear_header_img[] = {IMAGE_RESOURCE_BMP16_STOPLOSTRED_PNG};
    m_table_stoplostsetting.SetHeaderText(3, "");
    m_table_stoplostsetting.SetHeaderImage(3, gear_header_img);
    // Gear icon (col3) opens the SL Setting form. Col4-7 show Fixed+Indicator distances in parallel
    // (see project_v10_stoplost_trailing_apply_design.md) - active mode only matters for Apply.
    uint fixed_img[] = {IMAGE_RESOURCE_BMP16_STOP_LOST_FIXED_PNG};
    uint ind_img[]   = {IMAGE_RESOURCE_BMP16_INDICATOR_BMP};
    // CTable::DrawHeadersText() always centers the header IMAGE in the column regardless of
    // align[], while header TEXT follows the column's own align (ALIGN_RIGHT here) - combining
    // both in these narrow columns makes them overlap. Icon-only header (Anhnt, 2026-09-07), body
    // cells already disambiguate Point (raw int) vs Value ("$X.XX").
    m_table_stoplostsetting.SetHeaderText(4, "");
    m_table_stoplostsetting.SetHeaderImage(4, fixed_img);
    m_table_stoplostsetting.SetHeaderText(5, "");
    m_table_stoplostsetting.SetHeaderImage(5, ind_img);
    m_table_stoplostsetting.SetHeaderText(6, "");
    m_table_stoplostsetting.SetHeaderImage(6, fixed_img);
    m_table_stoplostsetting.SetHeaderText(7, "");
    m_table_stoplostsetting.SetHeaderImage(7, ind_img);
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
    CArrayObj *col_list = m_symbol_collection.GetList();
    int count = (col_list != NULL) ? col_list.Total() : 0;
    if(count == 0) return false;
   //--- Dirty-check state, scoped as `static` locals instead of CGUIPannel members. Col4-7 = Fixed
   //--- and Indicator distances shown in parallel (not per-Direction Buy/Sell anymore).
    static int    table_row_count = 0;
    static double mid_price_old[];
    static int    spread_half_old[];
    static bool   active_old[];
    static int    fixed_pts_old[];   // Col4
    static int    ind_pts_old[];     // Col5
    static double fixed_val_old[];   // Col6
    static double ind_val_old[];     // Col7
   // --- Full rebuild when row count changes
   if(count != table_row_count)
    {
     uint sym_img[] = {IMAGE_RESOURCE_BMP16_BAR_CHART_BMP, IMAGE_RESOURCE_BMP16_BAR_CHART_COLORLESS_BMP};
     m_table_stoplostsetting.DeleteAllRows();
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

       int    fixed_pts = m_tradingEngine.GetCurrentStopLostDistancePoints(sym_name, SL_MODE_FIXED);
       int    ind_pts   = m_tradingEngine.GetCurrentStopLostDistancePoints(sym_name, SL_MODE_INDICATOR);
       double fixed_val = m_tradingEngine.GetStopLostMoneyValue(sym_name, SL_MODE_FIXED);
       double ind_val    = m_tradingEngine.GetStopLostMoneyValue(sym_name, SL_MODE_INDICATOR);
       fixed_pts_old[row] = fixed_pts;
       ind_pts_old[row]   = ind_pts;
       fixed_val_old[row] = fixed_val;
       ind_val_old[row]   = ind_val;
       m_table_stoplostsetting.SetValue(4, row, (fixed_pts < 0) ? "-" : (string)fixed_pts + " P");
       m_table_stoplostsetting.SetValue(5, row, (ind_pts   < 0) ? "-" : (string)ind_pts + " P");
       m_table_stoplostsetting.SetValue(6, row, (fixed_val == EMPTY_VALUE) ? "-" : "$" + ::DoubleToString(fixed_val, 2));
       m_table_stoplostsetting.SetValue(7, row, (ind_val   == EMPTY_VALUE) ? "-" : "$" + ::DoubleToString(ind_val, 2));
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

      // --- Col4-7: Fixed and Indicator distances, both always recomputed regardless of active mode.
       int    fixed_pts = m_tradingEngine.GetCurrentStopLostDistancePoints(sym_name, SL_MODE_FIXED);
       int    ind_pts   = m_tradingEngine.GetCurrentStopLostDistancePoints(sym_name, SL_MODE_INDICATOR);
       double fixed_val = m_tradingEngine.GetStopLostMoneyValue(sym_name, SL_MODE_FIXED);
       double ind_val   = m_tradingEngine.GetStopLostMoneyValue(sym_name, SL_MODE_INDICATOR);
       if(force || fixed_pts != fixed_pts_old[row])
        {
         int dir = (fixed_pts_old[row] < 0 || fixed_pts < 0) ? 2 : (fixed_pts > fixed_pts_old[row]) ? 0 : (fixed_pts < fixed_pts_old[row]) ? 1 : 2;
         color clr = (dir == 0) ? C'0,160,0' : (dir == 1) ? C'200,0,0' : clrGray;
         fixed_pts_old[row] = fixed_pts;
         m_table_stoplostsetting.SetValue(4, row, (fixed_pts < 0) ? "-" : (string)fixed_pts + " P", 0, true);
         m_table_stoplostsetting.TextColor(4, row, clr, true);
         any_changed = true;
        }
       if(force || ind_pts != ind_pts_old[row])
        {
         int dir = (ind_pts_old[row] < 0 || ind_pts < 0) ? 2 : (ind_pts > ind_pts_old[row]) ? 0 : (ind_pts < ind_pts_old[row]) ? 1 : 2;
         color clr = (dir == 0) ? C'0,160,0' : (dir == 1) ? C'200,0,0' : clrGray;
         ind_pts_old[row] = ind_pts;
         m_table_stoplostsetting.SetValue(5, row, (ind_pts < 0) ? "-" : (string)ind_pts + " P", 0, true);
         m_table_stoplostsetting.TextColor(5, row, clr, true);
         any_changed = true;
        }
       if(force || fixed_val != fixed_val_old[row])
        {
         int dir = (fixed_val_old[row] == EMPTY_VALUE || fixed_val == EMPTY_VALUE) ? 2 : (fixed_val > fixed_val_old[row]) ? 0 : (fixed_val < fixed_val_old[row]) ? 1 : 2;
         color clr = (dir == 0) ? C'0,160,0' : (dir == 1) ? C'200,0,0' : clrGray;
         fixed_val_old[row] = fixed_val;
         m_table_stoplostsetting.SetValue(6, row, (fixed_val == EMPTY_VALUE) ? "-" : "$" + ::DoubleToString(fixed_val, 2), 0, true);
         m_table_stoplostsetting.TextColor(6, row, clr, true);
         any_changed = true;
        }
       if(force || ind_val != ind_val_old[row])
        {
         int dir = (ind_val_old[row] == EMPTY_VALUE || ind_val == EMPTY_VALUE) ? 2 : (ind_val > ind_val_old[row]) ? 0 : (ind_val < ind_val_old[row]) ? 1 : 2;
         color clr = (dir == 0) ? C'0,160,0' : (dir == 1) ? C'200,0,0' : clrGray;
         ind_val_old[row] = ind_val;
         m_table_stoplostsetting.SetValue(7, row, (ind_val == EMPTY_VALUE) ? "-" : "$" + ::DoubleToString(ind_val, 2), 0, true);
         m_table_stoplostsetting.TextColor(7, row, clr, true);
         any_changed = true;
        }
     }
   if(any_changed) m_table_stoplostsetting.Update(false);
   return any_changed;
  }  
 bool CGUIPannel::CreateStopLostForm(const int x_gap, const int y_gap)
  {
    //--- Indicator on the LEFT, Fixed on the RIGHT (Anhnt, 2026-09-07) - matches the Trailing
    //--- Setting table's own left-to-right convention (Indicator-related columns first).
    #define COL_FIXED_X 280
    #define COL_IND_X   100
    int row0_y   = y_gap;                          // Symbol + Min Stop Lot, side by side
    int row1_y   = y_gap + M_CONTROL_YDISTANCE;    // Column headers: [blank] | Fixed | Indicator
    int row2_y   = y_gap + 2*M_CONTROL_YDISTANCE;  // Selection: [blank] | "Spread" | ATR combobox
    int row3_y   = y_gap + 3*M_CONTROL_YDISTANCE;  // Multiplexer: [blank] | Fixed edit | ATR edit
    int row4_y   = y_gap + 4*M_CONTROL_YDISTANCE;  // Value in Point: [blank] | Fixed preview | ATR preview
    int row5_y   = y_gap + 5*M_CONTROL_YDISTANCE;  // Save
   //--- Top-down info block: Symbol / Point / Trade-Stop-Level, Symbol-scoped, always visible
   //--- regardless of mode. Values are set per-Symbol in ShowStopLostForm(), not here.
    m_label_StopLostSetting_Symbol.MainPointer(m_tabs_setting_trading);
    m_tabs_setting_trading.AddToElementsArray(ENUM_TAB_SETTING_TRADING_STOPLOST,m_label_StopLostSetting_Symbol);
    m_label_StopLostSetting_Symbol.XSize(110);
    m_label_StopLostSetting_Symbol.YSize(M_CONTROL_HEIGHT);
    if(!m_label_StopLostSetting_Symbol.CreateTextLabel("Symbol - -", x_gap, row0_y)) return false;
    CWndContainer::AddToElementsArray(WindowIdx(m_window_setting_trading),m_label_StopLostSetting_Symbol);

   //--- Beside Symbol now, same row - gap = M_CONTROL_YDISTANCE (Anhnt, 2026-09-03), same constant
   //--- used for every other control-to-control gap on this form.
    m_label_StopLost_MinPts.MainPointer(m_tabs_setting_trading);
    m_tabs_setting_trading.AddToElementsArray(ENUM_TAB_SETTING_TRADING_STOPLOST,m_label_StopLost_MinPts);
    m_label_StopLost_MinPts.XSize(140);
    m_label_StopLost_MinPts.YSize(M_CONTROL_HEIGHT);
    if(!m_label_StopLost_MinPts.CreateTextLabel("Min Stop Lot - 0", m_label_StopLostSetting_Symbol.X2() + M_CONTROL_YDISTANCE, row0_y)) return false;
    CWndContainer::AddToElementsArray(WindowIdx(m_window_setting_trading),m_label_StopLost_MinPts);

   //--- 3-column grid (Anhnt, 2026-09-07): row-label column | Fixed | Indicator. Rows below are
   //--- Selection / Multiplexer / Value in Point. Fixed and Indicator are always both shown/editable
   //--- together (no more radio toggle). Static captions grouped into m_label_StopLost_GridCaption[]
   //--- (0=ColHeader Fixed, 1=ColHeader Ind, 2=RowLabel Selection, 3=RowLabel Multiplexer,
   //--- 4=RowLabel Value) instead of one named Property each - they're all shown/hidden together.
    string caption_text[5] = {"Fixed", "Indicator", "Selection", "Multiplexer", "Value in Point"};
    int    caption_x[5]    = {x_gap + COL_FIXED_X, x_gap + COL_IND_X, x_gap, x_gap, x_gap};
    int    caption_y[5]    = {row1_y, row1_y, row2_y, row3_y, row4_y};
    for(int i = 0; i < 5; i++)
     {
      m_label_StopLost_GridCaption[i].MainPointer(m_tabs_setting_trading);
      m_tabs_setting_trading.AddToElementsArray(ENUM_TAB_SETTING_TRADING_STOPLOST,m_label_StopLost_GridCaption[i]);
      m_label_StopLost_GridCaption[i].XSize(100);
      m_label_StopLost_GridCaption[i].YSize(M_CONTROL_HEIGHT);
      if(!m_label_StopLost_GridCaption[i].CreateTextLabel(caption_text[i], caption_x[i], caption_y[i])) return false;
      CWndContainer::AddToElementsArray(WindowIdx(m_window_setting_trading),m_label_StopLost_GridCaption[i]);
     }

   //--- Fixed's Selection cell - CTextEdit defaulted to "Spread" (Anhnt, 2026-09-07), mirrors the
   //--- Indicator column's ComboBox being its own Selection control.
    m_edit_StopLost_FixedSelection.MainPointer(m_tabs_setting_trading);
    m_tabs_setting_trading.AddToElementsArray(ENUM_TAB_SETTING_TRADING_STOPLOST,m_edit_StopLost_FixedSelection);
    m_edit_StopLost_FixedSelection.XSize(90);
    m_edit_StopLost_FixedSelection.YSize(M_CONTROL_HEIGHT);
    m_edit_StopLost_FixedSelection.GetTextBoxPointer().XGap(1);
    if(!m_edit_StopLost_FixedSelection.CreateTextEdit("Spread", x_gap + COL_FIXED_X, row2_y)) return false;
    CWndContainer::AddToElementsArray(WindowIdx(m_window_setting_trading),m_edit_StopLost_FixedSelection);

    m_combobox_ATR_choice.MainPointer(m_tabs_setting_trading);
    m_tabs_setting_trading.AddToElementsArray(ENUM_TAB_SETTING_TRADING_STOPLOST,m_combobox_ATR_choice);
    m_combobox_ATR_choice.XSize(80);
    m_combobox_ATR_choice.YSize(M_CONTROL_HEIGHT);
    m_combobox_ATR_choice.GetButtonPointer().XGap(1);
    m_combobox_ATR_choice.GetButtonPointer().XSize(150);
    m_combobox_ATR_choice.GetButtonPointer().LabelYGap(4);
    m_combobox_ATR_choice.GetButtonPointer().IconYGap(3);
    if(!m_combobox_ATR_choice.CreateComboBox("", x_gap + COL_IND_X, row2_y)) return false;
    CWndContainer::AddToElementsArray(WindowIdx(m_window_setting_trading),m_combobox_ATR_choice);

   //--- Fixed's Multiplexer cell - multiplier on Spread (Trishkin's StopLevel() = spread*m_spread_mlt
   //--- pattern), no longer a raw typed point count.
    m_edit_StopLost_FixedPoint.MainPointer(m_tabs_setting_trading);
    m_tabs_setting_trading.AddToElementsArray(ENUM_TAB_SETTING_TRADING_STOPLOST,m_edit_StopLost_FixedPoint);
    m_edit_StopLost_FixedPoint.XSize(70);
    m_edit_StopLost_FixedPoint.YSize(M_CONTROL_HEIGHT);
    m_edit_StopLost_FixedPoint.GetTextBoxPointer().XGap(1);
    if(!m_edit_StopLost_FixedPoint.CreateTextEdit("2.0", x_gap + COL_FIXED_X, row3_y)) return false;
    CWndContainer::AddToElementsArray(WindowIdx(m_window_setting_trading),m_edit_StopLost_FixedPoint);

    m_edit_ATR_Multiplexer.MainPointer(m_tabs_setting_trading);
    m_tabs_setting_trading.AddToElementsArray(ENUM_TAB_SETTING_TRADING_STOPLOST,m_edit_ATR_Multiplexer);
    m_edit_ATR_Multiplexer.XSize(60);
    m_edit_ATR_Multiplexer.YSize(M_CONTROL_HEIGHT);
    m_edit_ATR_Multiplexer.GetTextBoxPointer().XGap(1);
    if(!m_edit_ATR_Multiplexer.CreateTextEdit("1.5", x_gap + COL_IND_X, row3_y)) return false;
    CWndContainer::AddToElementsArray(WindowIdx(m_window_setting_trading),m_edit_ATR_Multiplexer);

   //--- Live-computed previews (Anhnt/Claude, 2026-09-02, split into 2 cells 2026-09-07), see
   //--- UpdateStopLostPreview(). 0=Fixed, 1=Indicator.
    int preview_x[2] = {x_gap + COL_FIXED_X, x_gap + COL_IND_X};
    for(int i = 0; i < 2; i++)
     {
      m_label_StopLost_ValuePreview[i].MainPointer(m_tabs_setting_trading);
      m_tabs_setting_trading.AddToElementsArray(ENUM_TAB_SETTING_TRADING_STOPLOST,m_label_StopLost_ValuePreview[i]);
      m_label_StopLost_ValuePreview[i].XSize(90);
      m_label_StopLost_ValuePreview[i].YSize(M_CONTROL_HEIGHT);
      if(!m_label_StopLost_ValuePreview[i].CreateTextLabel("-", preview_x[i], row4_y)) return false;
      CWndContainer::AddToElementsArray(WindowIdx(m_window_setting_trading),m_label_StopLost_ValuePreview[i]);
     }

    m_btn_save_StopLost_Setting.MainPointer(m_tabs_setting_trading);
    m_tabs_setting_trading.AddToElementsArray(ENUM_TAB_SETTING_TRADING_STOPLOST,m_btn_save_StopLost_Setting);
    m_btn_save_StopLost_Setting.XSize(80);
    m_btn_save_StopLost_Setting.YSize(M_CONTROL_HEIGHT);
    m_btn_save_StopLost_Setting.IconFile(IMAGE_RESOURCE_BMP16_SAVE_PNG);
    if(!m_btn_save_StopLost_Setting.CreateButton("Save", x_gap, row5_y)) return false;
    CWndContainer::AddToElementsArray(WindowIdx(m_window_setting_trading),m_btn_save_StopLost_Setting);
    return true;
  }
 void CGUIPannel::ShowStopLostForm(const string symbol)
  {
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
    double          fixed_mult   = (row_setting != NULL) ? row_setting.StopLostFixedMultiplier() : 2.0;
    ENUM_TIMEFRAMES atr_tf       = (row_setting != NULL) ? row_setting.StopLostIndTF()    : PERIOD_CURRENT;
    double          atr_mult     = (row_setting != NULL) ? row_setting.StopLostIndMultiplier() : 1.5;
    int             atr_period   = 14;
    if(row_setting != NULL)
     {
      MqlParam sl_ind_p[];
      row_setting.GetStopLostIndParams(sl_ind_p);
      if(::ArraySize(sl_ind_p) > 0) atr_period = (int)sl_ind_p[0].integer_value;
     }
    SyncComboBox_ATRChoice(symbol, atr_tf, atr_period);   // hides the ATR fields itself if this Symbol has none
    for(int i = 0; i < 5; i++)
     {
      m_label_StopLost_GridCaption[i].Show();
      m_label_StopLost_GridCaption[i].Moving();
     }
    m_edit_StopLost_FixedSelection.Show();
    m_edit_StopLost_FixedSelection.Moving();
    m_edit_StopLost_FixedSelection.SetValue("Spread", false);
    m_edit_StopLost_FixedSelection.GetTextBoxPointer().Update(true);
    m_edit_StopLost_FixedSelection.Update(true);
    m_edit_StopLost_FixedSelection.Draw();
    m_edit_StopLost_FixedPoint.Show();
    m_edit_StopLost_FixedPoint.Moving();
    m_edit_StopLost_FixedPoint.SetValue(::DoubleToString(fixed_mult, 2), false);
    m_edit_StopLost_FixedPoint.GetTextBoxPointer().Update(true);
    m_edit_StopLost_FixedPoint.Update(true);
    m_edit_StopLost_FixedPoint.Draw();
    m_edit_ATR_Multiplexer.SetValue(::DoubleToString(atr_mult, 2), false);
    m_edit_ATR_Multiplexer.GetTextBoxPointer().Update(true);
    m_edit_ATR_Multiplexer.Update(true);
    m_edit_ATR_Multiplexer.Draw();
    UpdateStopLostPreview(symbol);
    for(int i = 0; i < 2; i++)
     {
      m_label_StopLost_ValuePreview[i].Show();
      m_label_StopLost_ValuePreview[i].Moving();
     }
    m_btn_save_StopLost_Setting.Show();
    m_btn_save_StopLost_Setting.Moving();
    ::ChartRedraw();
  }
 void CGUIPannel::HideStopLostForm(void)
  {
    m_label_StopLostSetting_Symbol.Hide();
    m_label_StopLost_MinPts.Hide();
    for(int i = 0; i < 5; i++)
       m_label_StopLost_GridCaption[i].Hide();
    m_edit_StopLost_FixedSelection.Hide();
    m_edit_StopLost_FixedPoint.Hide();
    m_combobox_ATR_choice.Hide();
    m_edit_ATR_Multiplexer.Hide();
    for(int i = 0; i < 2; i++)
       m_label_StopLost_ValuePreview[i].Hide();
    m_btn_save_StopLost_Setting.Hide();
  } 
 //+------------------------------------------------------------------+
 //| BuildATRChoiceList moved to CTradingEngine (Anhnt/Claude,          |
 //| 2026-09-09 - pure data, no GUI control touched). Calls below go    |
 //| through m_tradingEngine.                                           |
 //+------------------------------------------------------------------+
 bool CGUIPannel::SyncComboBox_ATRChoice(const string symbol, const ENUM_TIMEFRAMES saved_tf, const int saved_period)
   {
    ENUM_TIMEFRAMES local_tf[];
    int             local_period[];
    int n = (m_tradingEngine != NULL) ? m_tradingEngine.BuildATRChoiceList(symbol, local_tf, local_period) : 0;
    m_combobox_ATR_choice.ItemsTotal(n);
    int list_h = 18 * ::MathMax(n, 1) + 4;
    if(list_h > 300) list_h = 300;
    m_combobox_ATR_choice.GetListViewPointer().YSize(list_h);
    m_combobox_ATR_choice.GetListViewPointer().Rebuilding(n);
    for(int i = 0; i < n; i++)
       m_combobox_ATR_choice.SetValue(i, "ATR(" + (string)local_period[i] + ") " + TimeframeDescription(local_tf[i]));
    //--- Re-select whichever item matches the caller's saved (tf, period), if any still matches
    //--- after the rebuild above; otherwise fall back to the SMALLEST tracked TF (Anhnt, 2026-09-07)
    //--- - array order from BuildATRChoiceList isn't TF-sorted, so "item 0" was an arbitrary pick,
    //--- not necessarily the smallest TF.
     int select_index = 0;
     bool matched = false;
     for(int i = 0; i < n; i++)
       if(local_tf[i] == saved_tf && local_period[i] == saved_period) { select_index = i; matched = true; break; }
     if(!matched)
       for(int i = 1; i < n; i++)
         if((int)local_tf[i] < (int)local_tf[select_index]) select_index = i;
     if(n > 0) m_combobox_ATR_choice.SelectItem(select_index);
    //--- SelectItem() only updates m_button's internal LabelText - it never repaints the button's
    //--- own canvas, so on a re-Sync (Symbol switch, form reopen) the button visually keeps
    //--- whatever text it last painted (blank, on the very first ShowStopLostForm ever) even though
    //--- the Multiplexer/Preview fields below already reflect the new selection correctly.
     m_combobox_ATR_choice.GetButtonPointer().Draw();
     m_combobox_ATR_choice.GetButtonPointer().Update(true);
     m_combobox_ATR_choice.GetListViewPointer().Update(true);
    //--- Force the dropdown CLOSED after every rebuild (Anhnt/Claude, 2026-09-02) - CComboBox::
    //--- Hide() never explicitly hides m_listview itself (only unpresses the button), so if the
    //--- list was ever left open from an earlier click, switching Symbol/mode could otherwise
    //--- keep showing it as a big blank expanded box instead of the closed "ATR(14) M1" button.
     m_combobox_ATR_choice.GetListViewPointer().Hide();
     m_combobox_ATR_choice.GetButtonPointer().IsPressed(false);
    //--- No ATR available for this Symbol - hide its own fields directly (no more radio button to
    //--- hide instead).
     bool has_choice = (n > 0);
     if(has_choice)
      {
       m_combobox_ATR_choice.Show();
       m_combobox_ATR_choice.Moving();
       m_edit_ATR_Multiplexer.Show();
       m_edit_ATR_Multiplexer.Moving();
      }
     else
      {
       m_combobox_ATR_choice.Hide();
       m_edit_ATR_Multiplexer.Hide();
      }
    return has_choice;
   }
 //+------------------------------------------------------------------+
 //| Resolve the combobox's currently SELECTED INDEX back to real       |
 //| TF+period via BuildATRChoiceList - never parses the button's own   |
 //| display text.                                                      |
 //+------------------------------------------------------------------+
 bool CGUIPannel::GetSelectedATRChoice(const string symbol, ENUM_TIMEFRAMES &out_tf, int &out_period)
  {
   ENUM_TIMEFRAMES local_tf[];
   int             local_period[];
   int n   = (m_tradingEngine != NULL) ? m_tradingEngine.BuildATRChoiceList(symbol, local_tf, local_period) : 0;
   int idx = m_combobox_ATR_choice.GetListViewPointer().SelectedItemIndex();
   if(idx < 0 || idx >= n) return false;
   out_tf     = local_tf[idx];
   out_period = local_period[idx];
   return true;
  }
  //+------------------------------------------------------------------+
  //| Live preview of Fixed and Indicator distances (in points), one    |
  //| cell each, from the form's current (possibly unsaved) field       |
  //| values.                                                            |
  //+------------------------------------------------------------------+
  void CGUIPannel::UpdateStopLostPreview(const string symbol)
   {
    double fixed_mult = ::StringToDouble(m_edit_StopLost_FixedPoint.GetValue());
    CSymbol *sym = (m_symbol_collection != NULL) ? m_symbol_collection.GetSymbolObjByName(symbol) : NULL;
    int spread_pts = (sym != NULL) ? sym.Spread() : (int)::SymbolInfoInteger(symbol, SYMBOL_SPREAD);
    string fixed_text = (string)(int)::MathRound(spread_pts * fixed_mult);

    string ind_text = "-";
    double mult = ::StringToDouble(m_edit_ATR_Multiplexer.GetValue());
    ENUM_TIMEFRAMES tf;
    int             period;
    if(GetSelectedATRChoice(symbol, tf, period))
     {
      MqlParam raw_params[1];
      raw_params[0].type          = TYPE_INT;
      raw_params[0].integer_value = period;
      int pts = m_tradingEngine.GetIndicatorStopLostDistancePoints(symbol, tf, IND_ATR, raw_params, mult);
      if(pts >= 0) ind_text = (string)pts;
     }
    m_label_StopLost_ValuePreview[0].LabelText(fixed_text);
    m_label_StopLost_ValuePreview[0].Draw();
    m_label_StopLost_ValuePreview[0].Update(true);
    m_label_StopLost_ValuePreview[1].LabelText(ind_text);
    m_label_StopLost_ValuePreview[1].Draw();
    m_label_StopLost_ValuePreview[1].Update(true);
   }
  //+------------------------------------------------------------------+
  //| GetIndicatorStopLostDistancePoints/GetCurrentStopLostDistancePoints/|
  //| GetStopLostDistancePrice/FormatStopLostCacheValue/GetStopLostMoneyValue|
  //| all moved to CTradingEngine (Anhnt/Claude, 2026-09-09 - pure       |
  //| trading-domain logic, no GUI control touched). Calls below go      |
  //| through m_tradingEngine. NOTE: FormatStopLostCacheValue had zero   |
  //| real call sites before the move either - looks unused, left as-is |
  //| since removal wasn't asked for.                                    |
  //+------------------------------------------------------------------+
#endif // CGUIPANNEL_SETTINGWINDOWS_TRADINGSTOPLOST_MQH_IMPLEMENTATION

