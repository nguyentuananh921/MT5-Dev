//+------------------------------------------------------------------+
//|             GUIPannel_TabQuickSetting_RiskManagement_Trailing.mqh |
//| Trailing tab of the Risk Management tab: the indicators of the   |
//| chart Symbol to trail by (table) and the Fixed mode form         |
//+------------------------------------------------------------------+
#ifndef CGUIPANNEL_TABQUICKSETTING_RISKMANAGEMENT_TRAILING_MQH
#define CGUIPANNEL_TABQUICKSETTING_RISKMANAGEMENT_TRAILING_MQH
#include "GUIPannel.mqh"
 //--- The tracked single-buffer Trend indicators of the chart Symbol: TF | Indicator | Value | Trailing(checkbox)
 bool CGUIPannel::CreateTable_IndicatorsTrailingSetting(const int x, const int y)
  {
   int table_w = TRAIL_IND_TABLE_WIDTH;   // border + scrollbar + columns
   m_table_indicators_trailingsetting.TableSize(COLUMNS_IND_TRAIL_TOTAL, 0);
   m_table_indicators_trailingsetting.View().ShowHeaders(true);
   m_table_indicators_trailingsetting.View().SelectableRow(true);
   m_table_indicators_trailingsetting.View().LightsHover(true);
   m_table_indicators_trailingsetting.View().IsSortMode(false);
   //--- The table takes the body down to the form under it
   const int below_h = TRAIL_FORM_FRAME_HEIGHT + M_CONTROL_BORDER_GAP;   // the form and the gap between the table and the form
   m_table_indicators_trailingsetting.AutoYResizeMode(true);
   m_table_indicators_trailingsetting.AutoYResizeBottomOffset(below_h);
   m_tabs_riskManagement.AddToElementsArray(TAB_RISK_MANAGEMENT_STOP_TRAILLING, m_table_indicators_trailingsetting);
   if(!m_table_indicators_trailingsetting.CreateTable(this.m_chart_id, M_SUBWINDOW_MAIN, "TableIndTrailing", x, y, table_w, ::MathMax(m_tabs_riskManagement.Height() - y - below_h, 3 * M_CONTROL_HEIGHT))) return false;
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
 //--- Instantiated single-buffer Trend templates per tracked TF of this Symbol - pure data, no Select
 int CGUIPannel::BuildTrailingIndicatorChoiceList(const string symbol, CIndicatorDE* &out_inds[], ENUM_TIMEFRAMES &out_tfs[])
  {
   int count = 0;
   ::ArrayResize(out_inds, 0);
   ::ArrayResize(out_tfs,  0);
   if(m_IndicatorsCollection == NULL || m_SymbolTFManager == NULL || m_IndicatorTemplateManager == NULL) return 0;
   CArrayObj *ind_list = m_IndicatorsCollection.GetList();
   int ind_total   = (ind_list != NULL) ? ind_list.Total() : 0;
   ENUM_TIMEFRAMES symbol_tfs[];
   int symtf_total = m_SymbolTFManager.TimeframesOf(symbol, symbol_tfs);
   int tmpl_total  = m_IndicatorTemplateManager.Total();
   for(int si = 0; si < symtf_total; si++)
    {
     ENUM_TIMEFRAMES tf = symbol_tfs[si];
     for(int ti = 0; ti < tmpl_total; ti++)
      {
       CIndicatorSetting *entry = m_IndicatorTemplateManager.At(ti);
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
     CRiskManagementSetting *row_setting = (m_RiskManagementManager != NULL) ? m_RiskManagementManager.Setting() : NULL;
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
       m_table_indicators_trailingsetting.SetValue(3, row, (long)(is_current ? CANV_ELEMENT_CHECK_STATE_CHECKED : CANV_ELEMENT_CHECK_STATE_UNCHECKED));
      }
    }
   for(int row = 0; row < count; row++)
    {
     m_table_indicators_trailingsetting.CellView(0, row).ChangeImage(tfs[row] == (ENUM_TIMEFRAMES)::Period() ? 0 : 1);
     double v0 = inds[row].Value();
     double v1 = inds[row].Previous();
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
 //--- Radio-like: a click moves the check to the row (draft); commit = true (Save) makes the row this Symbol's Trailing-by-Indicator source
 void CGUIPannel::OnCheckTable_IndicatorsTrailingSetting(const int row, const bool commit)
  {
   if(!commit)
    {
     for(int r = 0; r < (int)m_table_indicators_trailingsetting.Model().RowsTotal(); r++)
        m_table_indicators_trailingsetting.SetValue(3, r, (long)(r == row ? CANV_ELEMENT_CHECK_STATE_CHECKED : CANV_ELEMENT_CHECK_STATE_UNCHECKED));
     m_table_indicators_trailingsetting.Update(false);
     ::ChartRedraw(this.m_chart_id);
     return;
    }
   string symbol = ::Symbol();
   if(symbol == "" || m_RiskManagementManager == NULL) return;
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
     CRiskManagementSetting *row_setting = m_RiskManagementManager.Setting();
     row_setting.TrailingMode(SL_MODE_INDICATOR);
     row_setting.TrailingIndTF(tfs[i]);
     row_setting.TrailingIndType(inds[i].TypeIndicator());
     row_setting.SetTrailingIndParams(ind_params);
     m_RiskManagementManager.NotifySettingChanged();
     SyncTable_IndicatorsTrailingSetting(symbol, true);
     return;
    }
  }
 //--- Offset/Start/Step (one shared field each, like Trishkin's CSimpleTrailing) + EA-wide M1 bar shift: two fields in a row, Save at the right of the frame; at the bottom of the body
 bool CGUIPannel::CreateTrailingForm(const int x_gap, const int y_gap)
  {
   const int field_w   = TRAIL_FORM_CAPTION_WIDTH + TRAIL_FORM_EDIT_WIDTH;   // caption + edit box
   const int in_row0_y = M_CONTROL_HEIGHT;                                                // below the frame caption cut into the top border
   const int frame_h   = TRAIL_FORM_FRAME_HEIGHT;
   m_frame_trailling_setting_fixedmode.SetText("Fixed Mode");
   m_tabs_riskManagement.AddToElementsArray(TAB_RISK_MANAGEMENT_STOP_TRAILLING, m_frame_trailling_setting_fixedmode);
   if(!m_frame_trailling_setting_fixedmode.CreateFrame(this.m_chart_id, M_SUBWINDOW_MAIN, "FrameTrailFixed", x_gap, y_gap, TRAIL_FORM_FRAME_WIDTH, frame_h)) return false;
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
     if(!edits[i].CreateTextEdit(this.m_chart_id, M_SUBWINDOW_MAIN, names[i], M_CONTROL_BORDER_GAP + (i % 2) * (field_w + M_CONTROL_BORDER_GAP), in_row0_y + (i / 2) * M_CONTROL_HEIGHT, field_w, M_CONTROL_HEIGHT, TRAIL_FORM_EDIT_WIDTH)) return false;
    }
   //--- Save commits both Indicator mode (table pick) and Fixed mode: outside the frame, at its right, on its last row
   m_btn_save_Trailing_Setting.SetText("Save");
   m_btn_save_Trailing_Setting.IconFile(IMAGE_RESOURCE_BMP16_SAVE_PNG);
   m_tabs_riskManagement.AddToElementsArray(TAB_RISK_MANAGEMENT_STOP_TRAILLING, m_btn_save_Trailing_Setting);
   if(!m_btn_save_Trailing_Setting.Create(this.m_chart_id, M_SUBWINDOW_MAIN, "BtnSaveTrailing", x_gap + TRAIL_FORM_FRAME_WIDTH + M_CONTROL_BORDER_GAP, y_gap + frame_h - M_CONTROL_HEIGHT, M_BUTTON_SAVE_WIDTH, M_CONTROL_HEIGHT)) return false;
   //--- What is saved: the setting is the same for every Symbol, so it is set once, here
   CRiskManagementSetting *setting = (m_RiskManagementManager != NULL) ? m_RiskManagementManager.Setting() : NULL;
   m_edit_Trailing_Offset.SetValue((string)((setting != NULL) ? setting.TrailingOffsetPts() : 0));
   m_edit_Trailing_Start.SetValue((string)((setting != NULL) ? setting.TrailingStartPts() : 0));
   m_edit_Trailing_Step.SetValue((string)((setting != NULL) ? setting.TrailingStepPts() : 0));
   m_edit_Trailing_DataRatesIndex.SetValue((string)((m_RiskManagementManager != NULL) ? m_RiskManagementManager.TrailingDataRatesIndex() : 2));
   return true;
  }
 //--- The form stays at the bottom of the body when the window changes its size
 void CGUIPannel::ArrangeTrailingForm(void)
  {
   int x = m_tabs_riskManagement.X();
   int y = m_tabs_riskManagement.Y() + m_tabs_riskManagement.Height() - TRAIL_FORM_FRAME_HEIGHT;
   m_frame_trailling_setting_fixedmode.Move(x, y);
   m_btn_save_Trailing_Setting.Move(x + TRAIL_FORM_FRAME_WIDTH + M_CONTROL_BORDER_GAP, y + TRAIL_FORM_FRAME_HEIGHT - M_CONTROL_HEIGHT);
  }
 //+------------------------------------------------------------------+
 //| What the user did in the Trailing tab                            |
 //+------------------------------------------------------------------+
 void CGUIPannel::OnEvent_Tab_Trailing(const int id,const long &lparam,const double &dparam,const string &sparam)
  {
   //--- An indicator reported something new, or the tab was opened: the table of the indicators shows it
   if((id == CHARTEVENT_CUSTOM + INDICATOR_STATE_EVENT_CHANGED || id == CHARTEVENT_CUSTOM + ON_CLICK_TAB) && !m_first_start &&
      m_tabs_riskManagement.IsVisible() && m_tabs_riskManagement.SelectedTab() == TAB_RISK_MANAGEMENT_STOP_TRAILLING)
     {
      if(this.SyncTable_IndicatorsTrailingSetting(::Symbol()))
         ::ChartRedraw(this.m_chart_id);
     }
   //--- The window changed its size: the tabs followed it, the form follows the tabs
   if((id == CHARTEVENT_CUSTOM + ON_WINDOW_CHANGE_XSIZE || id == CHARTEVENT_CUSTOM + ON_WINDOW_CHANGE_YSIZE) && lparam == m_window_main.ObjectID())
     {
      this.ArrangeTrailingForm();
      return;
     }
   //--- m_table_indicators_trailingsetting: col 3 picks the Trailing-by-Indicator source
   if(id == CHARTEVENT_CUSTOM + ON_CLICK_CHECKBOX && lparam == m_table_indicators_trailingsetting.ObjectID())
     {
      int col, row;
      if(!m_table_indicators_trailingsetting.CellIndexes(sparam, col, row)) return;
      if(col == 3) OnCheckTable_IndicatorsTrailingSetting(row);
      return;
     }
   //--- Save commits Offset/Start/Step for the Symbol of the chart + the EA-wide M1 bar shift
   if(id == CHARTEVENT_CUSTOM + ON_CLICK_BUTTON && lparam == m_btn_save_Trailing_Setting.ObjectID())
     {
      string symbol = ::Symbol();
      if(m_RiskManagementManager == NULL) return;
      CRiskManagementSetting *row_setting = m_RiskManagementManager.Setting();
      //--- the Indicator picked in the table is a draft too: it goes in with Offset/Start/Step
      for(int r = 0; r < (int)m_table_indicators_trailingsetting.Model().RowsTotal(); r++)
         if(m_table_indicators_trailingsetting.Cell(3, r).ValueL() == CANV_ELEMENT_CHECK_STATE_CHECKED)
          {
           OnCheckTable_IndicatorsTrailingSetting(r, true);
           break;
          }
      row_setting.TrailingOffsetPts((int)::StringToInteger(m_edit_Trailing_Offset.GetValue()));
      row_setting.TrailingStartPts((int)::StringToInteger(m_edit_Trailing_Start.GetValue()));
      row_setting.TrailingStepPts((int)::StringToInteger(m_edit_Trailing_Step.GetValue()));
      m_RiskManagementManager.TrailingDataRatesIndex((int)::StringToInteger(m_edit_Trailing_DataRatesIndex.GetValue()));
      m_RiskManagementManager.NotifySettingChanged();
      m_RiskManagementManager.SaveToJSON();
      ::ChartRedraw(this.m_chart_id);
      return;
     }
  }
#endif // CGUIPANNEL_TABQUICKSETTING_RISKMANAGEMENT_TRAILING_MQH
