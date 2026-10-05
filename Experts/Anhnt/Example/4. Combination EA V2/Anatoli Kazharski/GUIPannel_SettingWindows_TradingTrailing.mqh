//+------------------------------------------------------------------+
//|                     GUIPannel_SettingWindows_TradingTrailing.mqh |
//| Trailling tab: per-Symbol table, Indicator choice table + form   |
//+------------------------------------------------------------------+
#ifndef CGUIPANNEL_SETTINGWINDOWS_TRADINGTRAILING_MQH_IMPLEMENTATION
#define CGUIPANNEL_SETTINGWINDOWS_TRADINGTRAILING_MQH_IMPLEMENTATION
 #include "GUIPannel.mqh"
 //--- Same layout as the StopLost table, only col 3's icon differs
 bool CGUIPannel::CreateTable_TrailingSetting(const int x, const int y)
  {
   int columns_width_total = 0;
   for(int col = 0; col < COLUMNS_TRAIL_TOTAL; col++)
    {
      columns_width_total += TRAIL_WIDTH[col];
      m_table_trailingsetting.View().GetHeaderViewPointer().TextAlign(col, TRAIL_HEADER_ALIGN[col]);
    }
   int table_w = columns_width_total + 2 + 16; // border + vertical scrollbar
   table_w = ::MathMax(table_w, TRAIL_TOTAL_WIDTH);   // right edge in line with the Fixed Mode frame below
   m_table_trailingsetting.TableSize(COLUMNS_TRAIL_TOTAL, 0);
   m_table_trailingsetting.View().ShowHeaders(true);
   m_table_trailingsetting.View().SelectableRow(true);
   m_table_trailingsetting.View().LightsHover(true);
   m_table_trailingsetting.View().IsSortMode(false);   // row == CSymbolsCollection index
   m_tabs_setting_trading.AddToElementsArray(ENUM_TAB_SETTING_TRADING_TRAILLING, m_table_trailingsetting);
   if(!m_table_trailingsetting.CreateTable(m_chart_id, m_subwin, "TableTrailingSetting", x, y, table_w, SETTING_TRADING_TABLE_HEIGHT)) return false;
   CTableHeaderView *header = m_table_trailingsetting.View().GetHeaderViewPointer();
   header.ColumnsWidth(TRAIL_WIDTH);
   header.TextXOffset(TRAIL_TEXT_X_OFFSET);
   header.ImageXOffset(TRAIL_IMAGE_X_OFFSET);
   uint spread_img[]    = {IMAGE_RESOURCE_BMP16_SPREADRED_PNG};
   uint trailling_img[] = {IMAGE_RESOURCE_BMP16_TRAILLING_PNG};
   uint fixed_img[]     = {IMAGE_RESOURCE_BMP16_STOP_LOST_FIXED_PNG};
   uint ind_img[]       = {IMAGE_RESOURCE_BMP16_INDICATOR_BMP};
   m_table_trailingsetting.SetHeaderText(0, "Symbol");
   m_table_trailingsetting.SetHeaderText(1, "Price");
   m_table_trailingsetting.SetHeaderText(2, "");  m_table_trailingsetting.SetHeaderImage(2, spread_img);
   m_table_trailingsetting.SetHeaderText(3, "");  m_table_trailingsetting.SetHeaderImage(3, trailling_img);
   m_table_trailingsetting.SetHeaderText(4, "");  m_table_trailingsetting.SetHeaderImage(4, fixed_img);
   m_table_trailingsetting.SetHeaderText(5, "");  m_table_trailingsetting.SetHeaderImage(5, ind_img);
   m_table_trailingsetting.SetHeaderText(6, "");  m_table_trailingsetting.SetHeaderImage(6, fixed_img);
   m_table_trailingsetting.SetHeaderText(7, "");  m_table_trailingsetting.SetHeaderImage(7, ind_img);
   m_table_trailingsetting.View().Rebuild(false);
   SyncTable_TrailingSetting(true);
   return true;
  }
 //--- Symbol label + one Symbol's tracked single-buffer Trend indicators: TF | Indicator | Value | Trailing(checkbox)
 bool CGUIPannel::CreateTable_IndicatorsTrailingSetting(const int x, const int y)
  {
   m_label_TrailingSetting_Symbol.SetText("Symbol - -");
   m_tabs_setting_trading.AddToElementsArray(ENUM_TAB_SETTING_TRADING_TRAILLING, m_label_TrailingSetting_Symbol);
   if(!m_label_TrailingSetting_Symbol.Create(m_chart_id, m_subwin, "LabelTrailSymbol", x, y, 160, M_CONTROL_HEIGHT)) return false;
   int table_w = TRAIL_IND_TABLE_WIDTH;   // border + scrollbar + columns
   m_table_indicators_trailingsetting.TableSize(COLUMNS_IND_TRAIL_TOTAL, 0);
   m_table_indicators_trailingsetting.View().ShowHeaders(true);
   m_table_indicators_trailingsetting.View().SelectableRow(true);
   m_table_indicators_trailingsetting.View().LightsHover(true);
   m_table_indicators_trailingsetting.View().IsSortMode(false);
   m_table_indicators_trailingsetting.AutoYResizeMode(true);
   m_table_indicators_trailingsetting.AutoYResizeBottomOffset(3);
   m_tabs_setting_trading.AddToElementsArray(ENUM_TAB_SETTING_TRADING_TRAILLING, m_table_indicators_trailingsetting);
   if(!m_table_indicators_trailingsetting.CreateTable(m_chart_id, m_subwin, "TableIndTrailing", x, y + M_CONTROL_YDISTANCE, table_w)) return false;
   CTableHeaderView *header = m_table_indicators_trailingsetting.View().GetHeaderViewPointer();
   header.ColumnsWidth(IND_TRAIL_WIDTH);
   header.TextAlign(IND_TRAIL_HEADER_ALIGN);
   header.TextXOffset(IND_TRAIL_TEXT_X_OFFSET);
   header.ImageXOffset(IND_TRAIL_IMAGE_X_OFFSET);
   uint trailling_img[] = {IMAGE_RESOURCE_BMP16_TRAILLING_PNG};
   m_table_indicators_trailingsetting.SetHeaderText(0, "TF");
   m_table_indicators_trailingsetting.SetHeaderText(1, "Indicator");
   m_table_indicators_trailingsetting.SetHeaderText(2, "Value");
   m_table_indicators_trailingsetting.SetHeaderText(3, "");
   m_table_indicators_trailingsetting.SetHeaderImage(3, trailling_img);
   m_table_indicators_trailingsetting.View().Rebuild(false);
   return true;
  }
 //--- Rows mirror CSymbolsCollection in its order; each cell redraws only when its value really changed
 bool CGUIPannel::SyncTable_TrailingSetting(bool force = false)
  {
   if(m_symbol_collection == NULL || m_tradingEngine == NULL || m_market_collection == NULL) return false;
   CArrayObj *col_list = m_symbol_collection.GetList();
   int count = (col_list != NULL) ? col_list.Total() : 0;
   bool rebuild = force || ((int)m_table_trailingsetting.Model().RowsTotal() != count);
   for(int i = 0; i < count && !rebuild; i++)
    {
     CSymbol *sym = col_list.At(i);
     rebuild = (sym == NULL || m_table_trailingsetting.Cell(0, i).ValueS() != sym.Name());
    }
   if(rebuild)
    {
     uint sym_img[]       = {IMAGE_RESOURCE_BMP16_BAR_CHART_BMP, IMAGE_RESOURCE_BMP16_BAR_CHART_COLORLESS_BMP};
     uint trailling_img[] = {IMAGE_RESOURCE_BMP16_TRAILLING_PNG};
     int  dir_cols[4]     = {1, 2, 6, 7};
     m_table_trailingsetting.DeleteAllRows();
     for(int i = 0; i < count; i++)
        m_table_trailingsetting.AddRow();
     for(int row = 0; row < count; row++)
      {
       CSymbol *sym = col_list.At(row);
       m_table_trailingsetting.View().RowView(row).TextAlign(TRAIL_CONTENT_ALIGN);
       m_table_trailingsetting.CellView(0, row).SetImages(sym_img);
       m_table_trailingsetting.SetValue(0, row, (sym != NULL) ? sym.Name() : "");
       m_table_trailingsetting.CellView(3, row).SetImages(trailling_img);
       for(int k = 0; k < 4; k++)
          m_table_trailingsetting.CellView(dir_cols[k], row).DirectionColors(C'0,160,0', C'200,0,0', clrGray);
       m_table_trailingsetting.Cell(1, row).SetDigits(2);
       m_table_trailingsetting.Cell(6, row).SetDigits(2);
       m_table_trailingsetting.Cell(7, row).SetDigits(2);
      }
    }
   for(int row = 0; row < count; row++)
    {
     CSymbol *sym = col_list.At(row);
     if(sym == NULL) continue;
     string sym_name = sym.Name();
     m_table_trailingsetting.CellView(0, row).ChangeImage(sym_name == ::Symbol() ? 0 : 1);
     m_table_trailingsetting.SetValue(1, row, (sym.Bid() + sym.Ask()) / 2.0);
     m_table_trailingsetting.SetValue(2, row, (long)(sym.Spread() / 2));
     int    fixed_pts = m_tradingEngine.GetCurrent_TrailingDistance_Points(sym_name, SL_MODE_FIXED);
     int    ind_pts   = m_tradingEngine.GetCurrent_TrailingDistance_Points(sym_name, SL_MODE_INDICATOR);
     double fixed_val = m_market_collection.SumFloatingProfit(sym_name, fixed_pts);
     double ind_val   = m_market_collection.SumFloatingProfit(sym_name, ind_pts);
     //--- Point columns keep the " P" text: compare with the shown value, color, then format and set
     int pts_cols[2] = {4, 5};
     int pts_vals[2];
     pts_vals[0] = fixed_pts;
     pts_vals[1] = ind_pts;
     for(int k = 0; k < 2; k++)
      {
       string old_text = m_table_trailingsetting.Cell(pts_cols[k], row).ValueS();
       string new_text = (pts_vals[k] < 0) ? "-" : ::StringFormat("%d P", pts_vals[k]);
       if(new_text == old_text) continue;
       bool  had_number = (old_text != "" && old_text != "-");
       long  old_pts    = ::StringToInteger(old_text);   // "125 P" -> 125
       color clr = (!had_number || pts_vals[k] < 0 || pts_vals[k] == old_pts) ? clrGray : (pts_vals[k] > old_pts) ? C'0,160,0' : C'200,0,0';
       m_table_trailingsetting.CellView(pts_cols[k], row).TextColor(clr);
       m_table_trailingsetting.SetValue(pts_cols[k], row, new_text);
      }
     if(fixed_val == EMPTY_VALUE) m_table_trailingsetting.SetValue(6, row, "-"); else m_table_trailingsetting.SetValue(6, row, fixed_val);
     if(ind_val == EMPTY_VALUE)   m_table_trailingsetting.SetValue(7, row, "-"); else m_table_trailingsetting.SetValue(7, row, ind_val);
    }
   if(rebuild)
    {
     m_table_trailingsetting.View().Rebuild(true);
     return true;
    }
   return m_table_trailingsetting.Update(false);
  }
 //--- Instantiated single-buffer Trend templates per tracked TF of this Symbol - pure data, no Select
 int CGUIPannel::BuildTrailingIndicatorChoiceList(const string symbol, CIndicatorDE* &out_inds[], ENUM_TIMEFRAMES &out_tfs[])
  {
   int count = 0;
   ::ArrayResize(out_inds, 0);
   ::ArrayResize(out_tfs,  0);
   if(m_IndicatorsCollection == NULL || m_SymbolTFManager == NULL || m_indicator_template_manager == NULL) return 0;
   CArrayObj *ind_list = m_IndicatorsCollection.GetList();
   int ind_total   = (ind_list != NULL) ? ind_list.Total() : 0;
   int symtf_total = m_SymbolTFManager.Total();
   int tmpl_total  = m_indicator_template_manager.Total();
   for(int si = 0; si < symtf_total; si++)
    {
     CSymbolTFSetting *symtf = m_SymbolTFManager.At(si);
     if(symtf == NULL || symtf.Symbol() != symbol) continue;
     ENUM_TIMEFRAMES tf = symtf.TFEnum();
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
       for(int ii = 0; ii < ind_total && ind == NULL; ii++)
        {
         CIndicatorDE *cand = ind_list.At(ii);
         if(cand == NULL || cand.Symbol() != symbol || cand.Timeframe() != tf || cand.TypeIndicator() != ind_type) continue;
         MqlParam cand_params[];
         cand.GetMqlParams(cand_params);
         if(IsEqualMqlParamArrays(cand_params, raw_params)) ind = cand;
        }
       if(ind == NULL) continue;   // template not instantiated on this Symbol+TF yet
       ::ArrayResize(out_inds, count + 1);
       ::ArrayResize(out_tfs,  count + 1);
       out_inds[count] = ind;
       out_tfs[count]  = tf;
       count++;
      }
    }
   return count;
  }
 //--- Rebuilt when the scoped Symbol or the choice list changes; Value colored by slope (bar 0 vs bar 1)
 bool CGUIPannel::SyncTable_IndicatorsTrailingSetting(const string symbol, bool force = false)
  {
   static string        s_scoped_symbol = "";
   static CIndicatorDE *s_inds_old[];
   if(symbol != s_scoped_symbol) { s_scoped_symbol = symbol; force = true; }
   CIndicatorDE   *inds[];
   ENUM_TIMEFRAMES tfs[];
   int count = BuildTrailingIndicatorChoiceList(symbol, inds, tfs);
   bool rebuild = force || (count != ::ArraySize(s_inds_old));
   for(int i = 0; i < count && !rebuild; i++)
      rebuild = (inds[i] != s_inds_old[i]);
   if(rebuild)
    {
     ::ArrayResize(s_inds_old, count);
     uint tf_img[] = {IMAGE_RESOURCE_BMP16_BAR_CHART_BMP, IMAGE_RESOURCE_BMP16_BAR_CHART_COLORLESS_BMP};
     CTradingSetupSetting *row_setting = (m_trading_setup_manager != NULL) ? m_trading_setup_manager.FindByIdentity(symbol) : NULL;
     MqlParam saved_params[];
     if(row_setting != NULL) row_setting.GetTrailingIndParams(saved_params);
     m_table_indicators_trailingsetting.DeleteAllRows();
     for(int i = 0; i < count; i++)
        m_table_indicators_trailingsetting.AddRow();
     for(int row = 0; row < count; row++)
      {
       CIndicatorDE *ind = inds[row];
       s_inds_old[row] = ind;
       m_table_indicators_trailingsetting.View().RowView(row).TextAlign(IND_TRAIL_CONTENT_ALIGN);
       m_table_indicators_trailingsetting.CellView(0, row).SetImages(tf_img);
       m_table_indicators_trailingsetting.SetValue(0, row, TimeframeDescription(tfs[row]));
       MqlParam ind_params[];
       ind.GetMqlParams(ind_params);
       CIndicatorSetting ind_label_setting;
       ind_label_setting.TypeEnum(ind.TypeIndicator());
       ind_label_setting.SetRawParams(ind_params);
       m_table_indicators_trailingsetting.SetValue(1, row, ind_label_setting.DisplayLabel());
       m_table_indicators_trailingsetting.Cell(2, row).SetDigits(2);
       bool is_current = (row_setting != NULL && row_setting.TrailingMode() == SL_MODE_INDICATOR &&
                          row_setting.TrailingIndType() == ind.TypeIndicator() &&
                          row_setting.TrailingIndTF()   == tfs[row] &&
                          IsEqualMqlParamArrays(saved_params, ind_params));
       m_table_indicators_trailingsetting.CellView(3, row).CellType(CELL_CHECKBOX);
       m_table_indicators_trailingsetting.SetValue(3, row, (long)(is_current ? CANV_ELEMENT_CHEK_STATE_CHECKED : CANV_ELEMENT_CHEK_STATE_UNCHECKED));
      }
    }
   for(int row = 0; row < count; row++)
    {
     m_table_indicators_trailingsetting.CellView(0, row).ChangeImage(tfs[row] == (ENUM_TIMEFRAMES)::Period() ? 0 : 1);
     double v0 = inds[row].GetDataBuffer(0, 0);
     double v1 = inds[row].GetDataBuffer(0, 1);
     int    dir = 2;
     if(v0 != EMPTY_VALUE && v1 != EMPTY_VALUE) dir = (v0 > v1) ? 0 : (v0 < v1) ? 1 : 2;
     m_table_indicators_trailingsetting.CellView(2, row).TextColor((dir == 0) ? C'0,160,0' : (dir == 1) ? C'200,0,0' : clrGray);
     if(v0 == EMPTY_VALUE) m_table_indicators_trailingsetting.SetValue(2, row, "-"); else m_table_indicators_trailingsetting.SetValue(2, row, v0);
    }
   if(rebuild)
    {
     m_table_indicators_trailingsetting.View().Rebuild(true);
     return true;
    }
   return m_table_indicators_trailingsetting.Update(false);
  }
 //--- Radio-like: the clicked row becomes this Symbol's Trailing-by-Indicator source
 void CGUIPannel::OnCheckTable_IndicatorsTrailingSetting(const int row)
  {
   string label_text = m_label_TrailingSetting_Symbol.Text();
   int    sep        = ::StringFind(label_text, " - ");
   string symbol     = (sep >= 0) ? ::StringSubstr(label_text, sep + 3) : "";
   if(symbol == "" || m_trading_setup_manager == NULL) return;
   string want_tf_text  = m_table_indicators_trailingsetting.Cell(0, row).ValueS();
   string want_ind_text = m_table_indicators_trailingsetting.Cell(1, row).ValueS();
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
 //--- Offset/Start/Step (one shared field each, like Trishkin's CSimpleTrailing) + EA-wide M1 bar shift
 bool CGUIPannel::CreateTrailingForm(const int x_gap, const int y_gap)
  {
   const int field_w   = TRAIL_FORM_CAPTION_WIDTH + TRAIL_FORM_EDIT_WIDTH;   // caption + edit box
   const int in_row0_y = M_CONTROL_HEIGHT;                                                // below the frame caption cut into the top border
   const int frame_h   = in_row0_y + 3 * M_CONTROL_YDISTANCE + M_CONTROL_HEIGHT + M_CONTROL_BORDER_GAP;
   m_frame_trailling_setting_fixedmode.SetText("Fixed Mode");
   m_tabs_setting_trading.AddToElementsArray(ENUM_TAB_SETTING_TRADING_TRAILLING, m_frame_trailling_setting_fixedmode);
   if(!m_frame_trailling_setting_fixedmode.CreateFrame(m_chart_id, m_subwin, "FrameTrailFixed", x_gap, y_gap, TRAIL_FORM_FRAME_WIDTH, frame_h)) return false;
   CTextEdit *edits[4];
   edits[0] = GetPointer(m_edit_Trailing_Offset);
   edits[1] = GetPointer(m_edit_Trailing_Start);
   edits[2] = GetPointer(m_edit_Trailing_Step);
   edits[3] = GetPointer(m_edit_Trailing_DataRatesIndex);
   string captions[4] = {"Offset", "Start", "Step", "M1 Bar Shift"};
   string names[4]    = {"EditTrailOffset", "EditTrailStart", "EditTrailStep", "EditTrailDataRates"};
   for(int i = 0; i < 4; i++)
    {
     edits[i].SetText(captions[i]);
     m_frame_trailling_setting_fixedmode.AddChild(edits[i]);
     if(!edits[i].CreateTextEdit(m_chart_id, m_subwin, names[i], M_CONTROL_BORDER_GAP, in_row0_y + i * M_CONTROL_YDISTANCE, field_w, M_CONTROL_HEIGHT, TRAIL_FORM_EDIT_WIDTH)) return false;
    }
   //--- Save commits both Indicator mode (table pick) and Fixed mode: outside the frame
   m_btn_save_Trailing_Setting.SetText("Save");
   m_btn_save_Trailing_Setting.IconFile(IMAGE_RESOURCE_BMP16_SAVE_PNG);
   m_tabs_setting_trading.AddToElementsArray(ENUM_TAB_SETTING_TRADING_TRAILLING, m_btn_save_Trailing_Setting);
   if(!m_btn_save_Trailing_Setting.Create(m_chart_id, m_subwin, "BtnSaveTrailing", x_gap, y_gap + frame_h + M_CONTROL_BORDER_GAP, 80, M_CONTROL_HEIGHT)) return false;
   return true;
  }
 void CGUIPannel::ShowTrailingForm(const string symbol)
  {
   CTradingSetupSetting *row_setting = (m_trading_setup_manager != NULL) ? m_trading_setup_manager.FindByIdentity(symbol) : NULL;
   int offset_pts       = (row_setting != NULL) ? row_setting.TrailingOffsetPts() : 0;
   int start_pts        = (row_setting != NULL) ? row_setting.TrailingStartPts()  : 0;
   int step_pts         = (row_setting != NULL) ? row_setting.TrailingStepPts()   : 0;
   int data_rates_index = (m_trading_setup_manager != NULL) ? m_trading_setup_manager.TrailingDataRatesIndex() : 2;
   m_label_TrailingSetting_Symbol.Show();
   m_table_indicators_trailingsetting.Show();
   m_frame_trailling_setting_fixedmode.Show();
   m_edit_Trailing_Offset.SetValue((string)offset_pts);
   m_edit_Trailing_Start.SetValue((string)start_pts);
   m_edit_Trailing_Step.SetValue((string)step_pts);
   m_edit_Trailing_DataRatesIndex.SetValue((string)data_rates_index);
   m_btn_save_Trailing_Setting.Show();
  }
 void CGUIPannel::HideTrailingForm(void)
  {
   m_label_TrailingSetting_Symbol.Hide();
   m_table_indicators_trailingsetting.Hide();
   m_frame_trailling_setting_fixedmode.Hide();
   m_btn_save_Trailing_Setting.Hide();
  }
#endif // CGUIPANNEL_SETTINGWINDOWS_TRADINGTRAILING_MQH_IMPLEMENTATION
