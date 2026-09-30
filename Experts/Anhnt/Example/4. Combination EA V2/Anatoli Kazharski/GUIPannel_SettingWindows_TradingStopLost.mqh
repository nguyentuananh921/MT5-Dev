//+------------------------------------------------------------------+
//|                     GUIPannel_SettingWindows_TradingStopLost.mqh |
//| StopLost tab: per-Symbol table + Fixed/Indicator SL form         |
//+------------------------------------------------------------------+
#ifndef CGUIPANNEL_SETTINGWINDOWS_TRADINGSTOPLOST_MQH_IMPLEMENTATION
#define CGUIPANNEL_SETTINGWINDOWS_TRADINGSTOPLOST_MQH_IMPLEMENTATION
 #include "GUIPannel.mqh"
 #define COLUMNS_STOPLOST_TOTAL 8
 //--- col: Symbol | Price | [Spread/2] | [gear] | [Fixed]Point | [Indicator]Point | [Fixed]Value | [Indicator]Value
 bool CGUIPannel::CreateTable_StopLostSetting(const int x, const int y)
  {
   int width[COLUMNS_STOPLOST_TOTAL]             = {M_SYMBOL_WIDTH, M_PRICE_WIDTH, 35, M_ICON16_WIDTH, 60, 60, 70, 70};
   ENUM_ALIGN_MODE align[COLUMNS_STOPLOST_TOTAL] = {ALIGN_LEFT, ALIGN_RIGHT, ALIGN_RIGHT, ALIGN_LEFT, ALIGN_RIGHT, ALIGN_RIGHT, ALIGN_RIGHT, ALIGN_RIGHT};
   int text_x_offset[COLUMNS_STOPLOST_TOTAL]     = {5, 2, 2, 5, 2, 2, 2, 2};   // right-aligned numbers: small edge gap, more room for the text
   int image_x_offset[COLUMNS_STOPLOST_TOTAL]    = {3, 3, (35 - 16) / 2, 2, (60 - 16) / 2, (60 - 16) / 2, (70 - 16) / 2, (70 - 16) / 2};   // header icons centered
   int table_w = 2 + 16;   // border + vertical scrollbar
   for(int c = 0; c < COLUMNS_STOPLOST_TOTAL; c++)
      table_w += width[c];
   table_w = ::MathMax(table_w, SL_TOTAL_WIDTH);   // right edge in line with the Fixed frame below
   m_table_stoplostsetting.TableSize(COLUMNS_STOPLOST_TOTAL, 0);
   m_table_stoplostsetting.View().ShowHeaders(true);
   m_table_stoplostsetting.View().SelectableRow(true);
   m_table_stoplostsetting.View().LightsHover(true);
   m_table_stoplostsetting.View().IsSortMode(false);   // row == CSymbolsCollection index
   m_tabs_setting_trading.AddToElementsArray(ENUM_TAB_SETTING_TRADING_STOPLOST, m_table_stoplostsetting);
   if(!m_table_stoplostsetting.CreateTable(m_chart_id, m_subwin, "TableStopLostSetting", x, y, table_w, SETTING_TRADING_TABLE_HEIGHT)) return false;
   CTableHeaderView *header = m_table_stoplostsetting.View().GetHeaderViewPointer();
   header.ColumnsWidth(width);
   header.TextAlign(align);
   header.TextXOffset(text_x_offset);
   header.ImageXOffset(image_x_offset);
   uint spread_img[] = {IMAGE_RESOURCE_BMP16_SPREADRED_PNG};
   uint gear_img[]   = {IMAGE_RESOURCE_BMP16_STOPLOSTRED_PNG};
   uint fixed_img[]  = {IMAGE_RESOURCE_BMP16_STOP_LOST_FIXED_PNG};
   uint ind_img[]    = {IMAGE_RESOURCE_BMP16_INDICATOR_BMP};
   m_table_stoplostsetting.SetHeaderText(0, "Symbol");
   m_table_stoplostsetting.SetHeaderText(1, "Price");
   m_table_stoplostsetting.SetHeaderText(2, "");  m_table_stoplostsetting.SetHeaderImage(2, spread_img);
   m_table_stoplostsetting.SetHeaderText(3, "");  m_table_stoplostsetting.SetHeaderImage(3, gear_img);
   m_table_stoplostsetting.SetHeaderText(4, "");  m_table_stoplostsetting.SetHeaderImage(4, fixed_img);
   m_table_stoplostsetting.SetHeaderText(5, "");  m_table_stoplostsetting.SetHeaderImage(5, ind_img);
   m_table_stoplostsetting.SetHeaderText(6, "");  m_table_stoplostsetting.SetHeaderImage(6, fixed_img);
   m_table_stoplostsetting.SetHeaderText(7, "");  m_table_stoplostsetting.SetHeaderImage(7, ind_img);
   m_table_stoplostsetting.View().Rebuild(false);
   SyncTable_StopLostSetting(true);
   return true;
  }
 //--- Rows mirror CSymbolsCollection in its order; each cell redraws only when its value really changed
 bool CGUIPannel::SyncTable_StopLostSetting(bool force = false)
  {
   if(m_symbol_collection == NULL || m_tradingEngine == NULL || m_market_collection == NULL) return false;
   CArrayObj *col_list = m_symbol_collection.GetList();
   int count = (col_list != NULL) ? col_list.Total() : 0;
   bool rebuild = force || ((int)m_table_stoplostsetting.Model().RowsTotal() != count);
   for(int i = 0; i < count && !rebuild; i++)
    {
     CSymbol *sym = col_list.At(i);
     rebuild = (sym == NULL || m_table_stoplostsetting.Cell(0, i).ValueS() != sym.Name());
    }
   if(rebuild)
    {
     uint sym_img[]  = {IMAGE_RESOURCE_BMP16_BAR_CHART_BMP, IMAGE_RESOURCE_BMP16_BAR_CHART_COLORLESS_BMP};
     uint gear_img[] = {IMAGE_RESOURCE_BMP16_SETTING_RED_PNG};
     int  dir_cols[4] = {1, 2, 6, 7};
     m_table_stoplostsetting.DeleteAllRows();
     for(int i = 0; i < count; i++)
        m_table_stoplostsetting.AddRow();
     for(int row = 0; row < count; row++)
      {
       CSymbol *sym = col_list.At(row);
       m_table_stoplostsetting.CellView(0, row).SetImages(sym_img);
       m_table_stoplostsetting.SetValue(0, row, (sym != NULL) ? sym.Name() : "");
       m_table_stoplostsetting.CellView(3, row).SetImages(gear_img);
       for(int k = 0; k < 4; k++)
          m_table_stoplostsetting.CellView(dir_cols[k], row).DirectionColors(C'0,160,0', C'200,0,0', clrGray);
       m_table_stoplostsetting.Cell(1, row).SetDigits(2);
       m_table_stoplostsetting.Cell(6, row).SetDigits(2);
       m_table_stoplostsetting.Cell(7, row).SetDigits(2);
      }
    }
   for(int row = 0; row < count; row++)
    {
     CSymbol *sym = col_list.At(row);
     if(sym == NULL) continue;
     string sym_name = sym.Name();
     m_table_stoplostsetting.CellView(0, row).ChangeImage(sym_name == ::Symbol() ? 0 : 1);
     m_table_stoplostsetting.SetValue(1, row, (sym.Bid() + sym.Ask()) / 2.0);
     m_table_stoplostsetting.SetValue(2, row, (long)(sym.Spread() / 2));
     int    fixed_pts = m_tradingEngine.GetCurrent_StopLostDistance_Point(sym_name, SL_MODE_FIXED);
     int    ind_pts   = m_tradingEngine.GetCurrent_StopLostDistance_Point(sym_name, SL_MODE_INDICATOR);
     double fixed_val = m_market_collection.SumFloatingProfit(sym_name, fixed_pts);
     double ind_val   = m_market_collection.SumFloatingProfit(sym_name, ind_pts);
     //--- Point columns keep the " P" text: compare with the shown value, color, then format and set
     int pts_cols[2] = {4, 5};
     int pts_vals[2];
     pts_vals[0] = fixed_pts;
     pts_vals[1] = ind_pts;
     for(int k = 0; k < 2; k++)
      {
       string old_text = m_table_stoplostsetting.Cell(pts_cols[k], row).ValueS();
       string new_text = (pts_vals[k] < 0) ? "-" : ::StringFormat("%d P", pts_vals[k]);
       if(new_text == old_text) continue;
       bool  had_number = (old_text != "" && old_text != "-");
       long  old_pts    = ::StringToInteger(old_text);   // "125 P" -> 125
       color clr = (!had_number || pts_vals[k] < 0 || pts_vals[k] == old_pts) ? clrGray : (pts_vals[k] > old_pts) ? C'0,160,0' : C'200,0,0';
       m_table_stoplostsetting.CellView(pts_cols[k], row).TextColor(clr);
       m_table_stoplostsetting.SetValue(pts_cols[k], row, new_text);
      }
     if(fixed_val == EMPTY_VALUE) m_table_stoplostsetting.SetValue(6, row, "-"); else m_table_stoplostsetting.SetValue(6, row, fixed_val);
     if(ind_val == EMPTY_VALUE)   m_table_stoplostsetting.SetValue(7, row, "-"); else m_table_stoplostsetting.SetValue(7, row, ind_val);
    }
   if(rebuild)
    {
     m_table_stoplostsetting.View().Rebuild(true);
     return true;
    }
   return m_table_stoplostsetting.Update(false);
  }
 //--- Symbol row, then 2 framed columns side by side: Indicator (ATR) | Fixed (Spread); captions are the controls' own
 bool CGUIPannel::CreateStopLostForm(const int x_gap, const int y_gap)
  {
   const int pad       = SL_FORM_PAD;
   const int caption_w = SL_FORM_CAPTION_WIDTH;
   const int field_w   = SL_FORM_FIELD_WIDTH;
   const int in_row0_y = 18;                                  // below the frame caption cut into the top border
   const int in_row1_y = in_row0_y + M_CONTROL_YDISTANCE;
   const int in_row2_y = in_row0_y + 2*M_CONTROL_YDISTANCE;
   const int frame_w   = SL_FORM_FRAME_WIDTH;
   const int frame_h   = in_row2_y + M_CONTROL_HEIGHT + pad;
   const int frame_y   = y_gap + M_CONTROL_YDISTANCE + M_CONTROL_BORDER_GAP;
   m_label_StopLostSetting_Symbol.SetText("Symbol - -");
   m_tabs_setting_trading.AddToElementsArray(ENUM_TAB_SETTING_TRADING_STOPLOST, m_label_StopLostSetting_Symbol);
   if(!m_label_StopLostSetting_Symbol.Create(m_chart_id, m_subwin, "LabelSLSymbol", x_gap, y_gap, frame_w, M_CONTROL_HEIGHT)) return false;
   m_label_StopLost_MinPts.SetText("Min Stop Lot - 0");
   m_tabs_setting_trading.AddToElementsArray(ENUM_TAB_SETTING_TRADING_STOPLOST, m_label_StopLost_MinPts);
   if(!m_label_StopLost_MinPts.Create(m_chart_id, m_subwin, "LabelSLMinPts", x_gap + frame_w + SL_FORM_GAP, y_gap, frame_w, M_CONTROL_HEIGHT)) return false;
   //--- Indicator mode: ATR choice (template x tracked TF), multiplier on ATR, live distance
   m_frame_stoplost_setting_indicatormode.SetText("Indicator");
   m_tabs_setting_trading.AddToElementsArray(ENUM_TAB_SETTING_TRADING_STOPLOST, m_frame_stoplost_setting_indicatormode);
   if(!m_frame_stoplost_setting_indicatormode.CreateFrame(m_chart_id, m_subwin, "FrameSLIndicator", x_gap, frame_y, frame_w, frame_h)) return false;
   m_combobox_ATR_choice.SetText("Selection");
   m_combobox_ATR_choice.ItemsTotal(7);
   m_frame_stoplost_setting_indicatormode.AddChild(&m_combobox_ATR_choice);
   if(!m_combobox_ATR_choice.CreateComboBox(m_chart_id, m_subwin, "ComboSLATRChoice", pad, in_row0_y, caption_w + field_w, M_CONTROL_HEIGHT, field_w, 140)) return false;
   m_edit_ATR_Multiplexer.SetText("Multiplexer");
   m_frame_stoplost_setting_indicatormode.AddChild(&m_edit_ATR_Multiplexer);
   if(!m_edit_ATR_Multiplexer.CreateTextEdit(m_chart_id, m_subwin, "EditSLATRMultiplexer", pad, in_row1_y, caption_w + field_w, M_CONTROL_HEIGHT, field_w)) return false;
   m_edit_ATR_Multiplexer.SetValue("1.5");
   m_label_StopLost_ValuePreview[1].SetText("Value in Point - -");
   m_label_StopLost_ValuePreview[1].LabelXGap(0);
   m_frame_stoplost_setting_indicatormode.AddChild(&m_label_StopLost_ValuePreview[1]);
   if(!m_label_StopLost_ValuePreview[1].Create(m_chart_id, m_subwin, "LabelSLPreviewInd", pad, in_row2_y, caption_w + field_w, M_CONTROL_HEIGHT)) return false;
   //--- Fixed mode: Spread x multiplier (Trishkin's spread*m_spread_mlt), live distance
   m_frame_stoplost_setting_fixedmode.SetText("Fixed");
   m_tabs_setting_trading.AddToElementsArray(ENUM_TAB_SETTING_TRADING_STOPLOST, m_frame_stoplost_setting_fixedmode);
   if(!m_frame_stoplost_setting_fixedmode.CreateFrame(m_chart_id, m_subwin, "FrameSLFixed", x_gap + frame_w + SL_FORM_GAP, frame_y, frame_w, frame_h)) return false;
   m_edit_StopLost_FixedSelection.SetText("Selection");
   m_frame_stoplost_setting_fixedmode.AddChild(&m_edit_StopLost_FixedSelection);
   if(!m_edit_StopLost_FixedSelection.CreateTextEdit(m_chart_id, m_subwin, "EditSLFixedSelection", pad, in_row0_y, caption_w + field_w, M_CONTROL_HEIGHT, field_w)) return false;
   m_edit_StopLost_FixedSelection.SetValue("Spread");
   m_edit_StopLost_FixedPoint.SetText("Multiplexer");
   m_frame_stoplost_setting_fixedmode.AddChild(&m_edit_StopLost_FixedPoint);
   if(!m_edit_StopLost_FixedPoint.CreateTextEdit(m_chart_id, m_subwin, "EditSLFixedPoint", pad, in_row1_y, caption_w + field_w, M_CONTROL_HEIGHT, field_w)) return false;
   m_edit_StopLost_FixedPoint.SetValue("2.0");
   m_label_StopLost_ValuePreview[0].SetText("Value in Point - -");
   m_label_StopLost_ValuePreview[0].LabelXGap(0);
   m_frame_stoplost_setting_fixedmode.AddChild(&m_label_StopLost_ValuePreview[0]);
   if(!m_label_StopLost_ValuePreview[0].Create(m_chart_id, m_subwin, "LabelSLPreviewFixed", pad, in_row2_y, caption_w + field_w, M_CONTROL_HEIGHT)) return false;
   m_btn_save_StopLost_Setting.SetText("Save");
   m_btn_save_StopLost_Setting.IconFile(IMAGE_RESOURCE_BMP16_SAVE_PNG);
   m_tabs_setting_trading.AddToElementsArray(ENUM_TAB_SETTING_TRADING_STOPLOST, m_btn_save_StopLost_Setting);
   if(!m_btn_save_StopLost_Setting.Create(m_chart_id, m_subwin, "BtnSaveStopLost", x_gap, frame_y + frame_h + M_CONTROL_BORDER_GAP, 80, M_CONTROL_HEIGHT)) return false;
   return true;
  }
 void CGUIPannel::ShowStopLostForm(const string symbol)
  {
   CSymbol *sym_for_info = (m_symbol_collection != NULL) ? m_symbol_collection.GetSymbolObjByName(symbol) : NULL;
   int min_pts = (sym_for_info != NULL) ? (sym_for_info.Spread() / 2 + sym_for_info.TradeStopLevel())
                                        : (int)::SymbolInfoInteger(symbol, SYMBOL_TRADE_STOPS_LEVEL);
   m_label_StopLostSetting_Symbol.SetText("Symbol - " + symbol);
   m_label_StopLostSetting_Symbol.Show();
   m_label_StopLostSetting_Symbol.Draw(false);
   m_label_StopLost_MinPts.SetText("Min Stop Lot - " + (string)min_pts);
   m_label_StopLost_MinPts.Show();
   m_label_StopLost_MinPts.Draw(false);
   CTradingSetupSetting *row_setting = (m_trading_setup_manager != NULL) ? m_trading_setup_manager.FindByIdentity(symbol) : NULL;
   double          fixed_mult = (row_setting != NULL) ? row_setting.StopLostFixedMultiplier() : 2.0;
   ENUM_TIMEFRAMES atr_tf     = (row_setting != NULL) ? row_setting.StopLostIndTF()           : PERIOD_CURRENT;
   double          atr_mult   = (row_setting != NULL) ? row_setting.StopLostIndMultiplier()   : 1.5;
   int             atr_period = 14;
   if(row_setting != NULL)
    {
     MqlParam sl_ind_p[];
     row_setting.GetStopLostIndParams(sl_ind_p);
     if(::ArraySize(sl_ind_p) > 0) atr_period = (int)sl_ind_p[0].integer_value;
    }
   //--- Frame Show cascades to its controls; SyncComboBox_ATRChoice then hides the ATR ones if there is no ATR
   m_frame_stoplost_setting_indicatormode.Show();
   m_frame_stoplost_setting_fixedmode.Show();
   m_edit_StopLost_FixedSelection.SetValue("Spread");
   m_edit_StopLost_FixedPoint.SetValue(::DoubleToString(fixed_mult, 2));
   m_edit_ATR_Multiplexer.SetValue(::DoubleToString(atr_mult, 2));
   SyncComboBox_ATRChoice(symbol, atr_tf, atr_period);
   UpdateStopLostPreview(symbol);
   m_btn_save_StopLost_Setting.Show();
   ::ChartRedraw(m_chart_id);
  }
 void CGUIPannel::HideStopLostForm(void)
  {
   m_label_StopLostSetting_Symbol.Hide();
   m_label_StopLost_MinPts.Hide();
   m_frame_stoplost_setting_indicatormode.Hide();
   m_frame_stoplost_setting_fixedmode.Hide();
   m_btn_save_StopLost_Setting.Hide();
  }
 //--- Candidate ATR(period) per tracked TF for this Symbol, sorted by TF (M1 first) - pure data
 int CGUIPannel::BuildATRChoiceList(const string symbol, ENUM_TIMEFRAMES &out_tf[], int &out_period[])
  {
   int n = 0;
   ::ArrayResize(out_tf,     0);
   ::ArrayResize(out_period, 0);
   if(m_indicator_template_manager == NULL || m_SymbolTFManager == NULL) return 0;
   int templates_total = m_indicator_template_manager.Total();
   for(int t = 0; t < templates_total; t++)
    {
     CIndicatorSetting *tpl = m_indicator_template_manager.At(t);
     if(tpl == NULL || tpl.TypeEnum() != IND_ATR) continue;
     MqlParam raw[];
     tpl.GetRawParams(raw);
     if(::ArraySize(raw) == 0) continue;
     int period = (int)raw[0].integer_value;
     int tf_total = m_SymbolTFManager.Total();
     for(int s = 0; s < tf_total; s++)
      {
       CSymbolTFSetting *row = m_SymbolTFManager.At(s);
       if(row == NULL || row.Symbol() != symbol) continue;
       ::ArrayResize(out_tf,     n + 1);
       ::ArrayResize(out_period, n + 1);
       out_tf[n]     = row.TFEnum();
       out_period[n] = period;
       n++;
      }
    }
   for(int a = 0; a < n - 1; a++)
      for(int b = a + 1; b < n; b++)
         if(IndexEnumTimeframe(out_tf[b]) < IndexEnumTimeframe(out_tf[a]))
          {
           ENUM_TIMEFRAMES tf_tmp = out_tf[a]; out_tf[a] = out_tf[b]; out_tf[b] = tf_tmp;
           int period_tmp = out_period[a]; out_period[a] = out_period[b]; out_period[b] = period_tmp;
          }
   return n;
  }
 //--- Refill the ATR combobox, re-select the saved (tf, period) or else the smallest TF
 bool CGUIPannel::SyncComboBox_ATRChoice(const string symbol, const ENUM_TIMEFRAMES saved_tf, const int saved_period)
  {
   ENUM_TIMEFRAMES local_tf[];
   int             local_period[];
   int n = BuildATRChoiceList(symbol, local_tf, local_period);
   //--- No ATR template on a tracked TF of this Symbol: one "N/A" item, never a real choice
   m_combobox_ATR_choice.GetListViewPointer().Rebuilding(::MathMax(n, 1));
   if(n == 0)
      m_combobox_ATR_choice.SetValue(0, "N/A");
   for(int i = 0; i < n; i++)
      m_combobox_ATR_choice.SetValue(i, "ATR(" + (string)local_period[i] + ") " + TimeframeDescription(local_tf[i]));
   int  select_index = 0;
   bool matched = false;
   for(int i = 0; i < n && !matched; i++)
      if(local_tf[i] == saved_tf && local_period[i] == saved_period) { select_index = i; matched = true; }
   if(!matched)
      for(int i = 1; i < n; i++)
         if((int)local_tf[i] < (int)local_tf[select_index]) select_index = i;
   m_combobox_ATR_choice.SelectItem(select_index);
   m_combobox_ATR_choice.GetListViewPointer().Draw(false);   // SetValue/SelectItem only store, repaint the list
   //--- Always shown in the Indicator frame; locked (grayed) while there is nothing to pick
   m_combobox_ATR_choice.IsLocked(n == 0);
   m_edit_ATR_Multiplexer.IsLocked(n == 0);
   return (n > 0);
  }
 //--- Selected INDEX back to real TF+period via BuildATRChoiceList, never parses the button text
 bool CGUIPannel::GetSelectedATRChoice(const string symbol, ENUM_TIMEFRAMES &out_tf, int &out_period)
  {
   ENUM_TIMEFRAMES local_tf[];
   int             local_period[];
   int n   = BuildATRChoiceList(symbol, local_tf, local_period);
   int idx = m_combobox_ATR_choice.GetListViewPointer().SelectedItemIndex();
   if(idx < 0 || idx >= n) return false;
   out_tf     = local_tf[idx];
   out_period = local_period[idx];
   return true;
  }
 //--- Fixed and Indicator distances (points) from the form's current, possibly unsaved, values
 void CGUIPannel::UpdateStopLostPreview(const string symbol)
  {
   double fixed_mult = ::StringToDouble(m_edit_StopLost_FixedPoint.GetValue());
   CSymbol *sym = (m_symbol_collection != NULL) ? m_symbol_collection.GetSymbolObjByName(symbol) : NULL;
   int spread_pts = (sym != NULL) ? sym.Spread() : (int)::SymbolInfoInteger(symbol, SYMBOL_SPREAD);
   string fixed_text = ::StringFormat("%d P", (int)::MathRound(spread_pts * fixed_mult));
   string ind_text = "-";
   double mult = ::StringToDouble(m_edit_ATR_Multiplexer.GetValue());
   ENUM_TIMEFRAMES tf;
   int             period;
   if(m_tradingEngine != NULL && GetSelectedATRChoice(symbol, tf, period))
    {
     MqlParam raw_params[1];
     raw_params[0].type          = TYPE_INT;
     raw_params[0].integer_value = period;
     int pts = m_tradingEngine.GetIndicator_StopLostDistance_Points(symbol, tf, IND_ATR, raw_params, mult);
     if(pts >= 0) ind_text = ::StringFormat("%d P", pts);
    }
   m_label_StopLost_ValuePreview[0].SetText("Value in Point - " + fixed_text);
   m_label_StopLost_ValuePreview[0].Draw(false);
   m_label_StopLost_ValuePreview[1].SetText("Value in Point - " + ind_text);
   m_label_StopLost_ValuePreview[1].Draw(false);
  }
#endif // CGUIPANNEL_SETTINGWINDOWS_TRADINGSTOPLOST_MQH_IMPLEMENTATION
