//+------------------------------------------------------------------+
//|                           GUIPannel_MainWindows_TabPositions.mqh |
//+------------------------------------------------------------------+
#ifndef CGUIPANNEL_MAINWINDOWS_TABPOSITION_MQH
#define CGUIPANNEL_MAINWINDOWS_TABPOSITION_MQH
 #include "GUIPannel.mqh"  
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
   int row0_y = y_gap;                          // Symbol
   int row1_y = y_gap + M_CONTROL_YDISTANCE;    // Lot
   int row2_y = y_gap + 2*M_CONTROL_YDISTANCE;  // Direction + Order Type
   int row3_y = y_gap + 3*M_CONTROL_YDISTANCE;  // Use SL Setting checkbox
   int row4_y = y_gap + 4*M_CONTROL_YDISTANCE;  // Send button
  //--- Symbol - same tracked-Symbol list as m_table_stoplostsetting's own rows (already built by
  //--- CreateTable_PreTradeSymbolInfo, called before this), read straight off the table instead
  //--- of re-deriving the Layer1-union-MarketWatch list a second time.
   m_combobox_symbol_toTrade.MainPointer(m_tabs_main);
   m_tabs_main.AddToElementsArray(TAB_TAB_MAIN_POSITIONS, m_combobox_symbol_toTrade);
   m_combobox_symbol_toTrade.XSize(150);
   m_combobox_symbol_toTrade.YSize(M_CONTROL_HEIGHT);
   m_combobox_symbol_toTrade.GetButtonPointer().XGap(1);
   m_combobox_symbol_toTrade.GetButtonPointer().XSize(150);
   if(!m_combobox_symbol_toTrade.CreateComboBox("", x_gap, row0_y)) return false;
   CWndContainer::AddToElementsArray(WindowIdx(m_window_main), m_combobox_symbol_toTrade);
    {
     int sym_total = (int)m_table_stoplostsetting.RowsTotal();
     m_combobox_symbol_toTrade.ItemsTotal(sym_total);
     int list_h = 18 * ::MathMax(sym_total, 1) + 4;
     if(list_h > 300) list_h = 300;
     m_combobox_symbol_toTrade.GetListViewPointer().YSize(list_h);
     m_combobox_symbol_toTrade.GetListViewPointer().Rebuilding(sym_total);
     for(int i = 0; i < sym_total; i++)
        m_combobox_symbol_toTrade.SetValue(i, m_table_stoplostsetting.GetValue(0, i));
     if(sym_total > 0) m_combobox_symbol_toTrade.SelectItem(0);
     m_combobox_symbol_toTrade.GetListViewPointer().Update(true);
     m_combobox_symbol_toTrade.GetListViewPointer().Hide();
     m_combobox_symbol_toTrade.GetButtonPointer().IsPressed(false);
    }

  //--- Lot - placeholder preset list (Anhnt, 2026-09-03) - not yet derived from SYMBOL_VOLUME_MIN/
  //--- STEP per Symbol or from the Risk%/Distance calc above; revisit once that's wired.
   m_combobox_lot_toTrade.MainPointer(m_tabs_main);
   m_tabs_main.AddToElementsArray(TAB_TAB_MAIN_POSITIONS, m_combobox_lot_toTrade);
   m_combobox_lot_toTrade.XSize(150);
   m_combobox_lot_toTrade.YSize(M_CONTROL_HEIGHT);
   m_combobox_lot_toTrade.GetButtonPointer().XGap(1);
   m_combobox_lot_toTrade.GetButtonPointer().XSize(150);
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

  //--- Direction (Buy/Sell) - drives m_btn_send_toTrade's color (Anhnt, 2026-09-03: "Nếu lệnh Buy
  //--- nó mầu xanh, lệnh Sell nó mầu đỏ").
   m_combobox_direction.MainPointer(m_tabs_main);
   m_tabs_main.AddToElementsArray(TAB_TAB_MAIN_POSITIONS, m_combobox_direction);
   m_combobox_direction.XSize(70);
   m_combobox_direction.YSize(M_CONTROL_HEIGHT);
   m_combobox_direction.GetButtonPointer().XGap(1);
   m_combobox_direction.GetButtonPointer().XSize(70);
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

  //--- Order Type (Market/Limit/Stop/Stop Limit) - drives m_btn_send_toTrade's text suffix (Anhnt,
  //--- 2026-09-03: "Market thì text Buy/Sell thông thường, khác đi thì Buy Limit, Sell Limit...").
   m_combobox_order_type.MainPointer(m_tabs_main);
   m_tabs_main.AddToElementsArray(TAB_TAB_MAIN_POSITIONS, m_combobox_order_type);
   m_combobox_order_type.XSize(80);
   m_combobox_order_type.YSize(M_CONTROL_HEIGHT);
   m_combobox_order_type.GetButtonPointer().XGap(1);
   m_combobox_order_type.GetButtonPointer().XSize(80);
   if(!m_combobox_order_type.CreateComboBox("", m_combobox_direction.X2() + M_CONTROL_YDISTANCE, row2_y)) return false;
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
   m_tabs_main.AddToElementsArray(TAB_TAB_MAIN_POSITIONS, m_checkbox_use_StopLostSetting);
  //--- CCheckBox defaults to YSize=14 (CheckBox.mqh:96), the one Library control that doesn't
  //--- match everything else's 20 - force M_CONTROL_HEIGHT so this row lines up with the rest.
   m_checkbox_use_StopLostSetting.YSize(M_CONTROL_HEIGHT);
   if(!m_checkbox_use_StopLostSetting.CreateCheckBox("Use SL Setting", x_gap, row3_y)) return false;
   CWndContainer::AddToElementsArray(WindowIdx(m_window_main), m_checkbox_use_StopLostSetting);
  //--- CreateCanvas() (CheckBox.mqh) unconditionally sets the ON icon to CHECKBOX_ON_BMP, which
  //--- doesn't match the OFF icon's own "_G_" style (CHECKBOX_OFF_G_PNG) - the mismatch made the
  //--- 2 states hard to tell apart (Anhnt, 2026-09-04: "khó nhận biết trạng thái"). Override with
  //--- the matching ON_G_PNG AFTER CreateCheckBox(), since CreateCanvas() sets its default
  //--- unconditionally (setting this before creation would just get overwritten).
   m_checkbox_use_StopLostSetting.IconFilePressed(IMAGE_RESOURCE_BMP16_CHECKBOX_ON_G_PNG);
   m_checkbox_use_StopLostSetting.IsPressed(true);

  //--- Send button - color/text adapt to Direction+Order Type. Actual OrderSend wiring not done
  //--- yet - first draft, controls only.
   m_btn_send_toTrade.MainPointer(m_tabs_main);
   m_tabs_main.AddToElementsArray(TAB_TAB_MAIN_POSITIONS, m_btn_send_toTrade);
   m_btn_send_toTrade.XSize(150);
   m_btn_send_toTrade.YSize(M_CONTROL_HEIGHT);
   if(!m_btn_send_toTrade.CreateButton("Buy", x_gap, row4_y)) return false;
   CWndContainer::AddToElementsArray(WindowIdx(m_window_main), m_btn_send_toTrade);
   UpdateSendButtonAppearance();
   return true;
 }
 //+------------------------------------------------------------------+
 //| Refreshes m_btn_send_toTrade's text/color from m_combobox_        |
 //| direction/m_combobox_order_type's CURRENT selection (Anhnt,       |
 //| 2026-09-03).                                                        |
 //+------------------------------------------------------------------+
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
 //| Create a position table                                          |
 //+------------------------------------------------------------------+
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
      //--- m_table_stoplostsetting's own YSize/XSize fix - AutoXResizeMode/
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

