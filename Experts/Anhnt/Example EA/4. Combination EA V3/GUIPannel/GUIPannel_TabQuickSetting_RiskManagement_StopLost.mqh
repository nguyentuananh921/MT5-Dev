//+------------------------------------------------------------------+
//|            GUIPannel_TabQuickSetting_RiskManagement_StopLost.mqh |
//| Stop Loss tab of the Risk Management tab: the form of the chart  |
//| Symbol (Indicator mode | Fixed mode) and its Save button        |
//+------------------------------------------------------------------+
#ifndef CGUIPANNEL_TABQUICKSETTING_RISKMANAGEMENT_STOPLOST_MQH
#define CGUIPANNEL_TABQUICKSETTING_RISKMANAGEMENT_STOPLOST_MQH
#include "GUIPannel.mqh"
 //--- The Symbol is the one of the chart: the Min Stop label, then 2 framed columns one under the other: Indicator (ATR) and Fixed (Spread); the captions are the controls' own
 bool CGUIPannel::CreateStopLostForm(const int x_gap, const int y_gap)
  {
   const int pad       = M_CONTROL_BORDER_GAP;
   const int caption_w = SL_FORM_CAPTION_WIDTH;
   const int field_w   = SL_FORM_FIELD_WIDTH;
   const int in_row0_y = M_CONTROL_HEIGHT;                                  // below the frame caption cut into the top border
   const int in_row1_y = in_row0_y + M_CONTROL_YDISTANCE;
   const int in_row2_y = in_row0_y + 2*M_CONTROL_YDISTANCE;
   const int frame_w   = SL_FORM_FRAME_WIDTH;
   const int frame_h   = in_row2_y + M_CONTROL_HEIGHT + pad;
   const int frame_y   = y_gap + M_CONTROL_YDISTANCE + M_CONTROL_BORDER_GAP;
   m_label_StopLost_MinPts.SetText("Min Stop Lot - 0");
   m_tabs_riskManagement.AddToElementsArray(TAB_RISK_MANAGEMENT_STOP_LOST, m_label_StopLost_MinPts);
   if(!m_label_StopLost_MinPts.Create(this.m_chart_id, M_SUBWINDOW_MAIN, "LabelSLMinPts", x_gap, y_gap, frame_w, M_CONTROL_HEIGHT)) return false;
   //--- Indicator mode: ATR choice (template x tracked TF), multiplier on ATR, live distance
   m_frame_stoplost_setting_indicatormode.SetText("Indicator");
   m_tabs_riskManagement.AddToElementsArray(TAB_RISK_MANAGEMENT_STOP_LOST, m_frame_stoplost_setting_indicatormode);
   if(!m_frame_stoplost_setting_indicatormode.CreateFrame(this.m_chart_id, M_SUBWINDOW_MAIN, "FrameSLIndicator", x_gap, frame_y, frame_w, frame_h)) return false;
   CLabel *atr_caption = GetPointer(m_combobox_ATR_choice);   // the name is the label at the left, the button keeps the chosen ATR
   atr_caption.SetText("Selection");
   m_combobox_ATR_choice.ItemsTotal(7);
   m_frame_stoplost_setting_indicatormode.AddChild(&m_combobox_ATR_choice);
   if(!m_combobox_ATR_choice.CreateComboBox(this.m_chart_id, M_SUBWINDOW_MAIN, "ComboSLATRChoice", pad, in_row0_y, caption_w + field_w, M_CONTROL_HEIGHT, field_w, 140)) return false;
   m_edit_ATR_Multiplexer.SetText("Multiplexer");
   m_frame_stoplost_setting_indicatormode.AddChild(&m_edit_ATR_Multiplexer);
   if(!m_edit_ATR_Multiplexer.CreateTextEdit(this.m_chart_id, M_SUBWINDOW_MAIN, "EditSLATRMultiplexer", pad, in_row1_y, caption_w + field_w, M_CONTROL_HEIGHT, field_w)) return false;
   m_edit_ATR_Multiplexer.SetValue("1.5");
   m_label_StopLost_ValuePreview[1].SetText("Value in Point - -");
   m_label_StopLost_ValuePreview[1].LabelXGap(0);
   m_frame_stoplost_setting_indicatormode.AddChild(&m_label_StopLost_ValuePreview[1]);
   if(!m_label_StopLost_ValuePreview[1].Create(this.m_chart_id, M_SUBWINDOW_MAIN, "LabelSLPreviewInd", pad, in_row2_y, caption_w + field_w, M_CONTROL_HEIGHT)) return false;
   //--- Fixed mode: Spread x multiplier (Trishkin's spread*m_spread_mlt), live distance; under the Indicator frame
   m_frame_stoplost_setting_fixedmode.SetText("Fixed");
   m_tabs_riskManagement.AddToElementsArray(TAB_RISK_MANAGEMENT_STOP_LOST, m_frame_stoplost_setting_fixedmode);
   const int fixed_y = frame_y + frame_h + M_CONTROL_BORDER_GAP;
   if(!m_frame_stoplost_setting_fixedmode.CreateFrame(this.m_chart_id, M_SUBWINDOW_MAIN, "FrameSLFixed", x_gap, fixed_y, frame_w, frame_h)) return false;
   m_edit_StopLost_FixedSelection.SetText("Selection");
   m_frame_stoplost_setting_fixedmode.AddChild(&m_edit_StopLost_FixedSelection);
   if(!m_edit_StopLost_FixedSelection.CreateTextEdit(this.m_chart_id, M_SUBWINDOW_MAIN, "EditSLFixedSelection", pad, in_row0_y, caption_w + field_w, M_CONTROL_HEIGHT, field_w)) return false;
   m_edit_StopLost_FixedSelection.SetValue("Spread");
   m_edit_StopLost_FixedPoint.SetText("Multiplexer");
   m_frame_stoplost_setting_fixedmode.AddChild(&m_edit_StopLost_FixedPoint);
   if(!m_edit_StopLost_FixedPoint.CreateTextEdit(this.m_chart_id, M_SUBWINDOW_MAIN, "EditSLFixedPoint", pad, in_row1_y, caption_w + field_w, M_CONTROL_HEIGHT, field_w)) return false;
   m_edit_StopLost_FixedPoint.SetValue("2.0");
   m_label_StopLost_ValuePreview[0].SetText("Value in Point - -");
   m_label_StopLost_ValuePreview[0].LabelXGap(0);
   m_frame_stoplost_setting_fixedmode.AddChild(&m_label_StopLost_ValuePreview[0]);
   if(!m_label_StopLost_ValuePreview[0].Create(this.m_chart_id, M_SUBWINDOW_MAIN, "LabelSLPreviewFixed", pad, in_row2_y, caption_w + field_w, M_CONTROL_HEIGHT)) return false;
   m_btn_save_StopLost_Setting.SetText("Save");
   m_btn_save_StopLost_Setting.IconFile(IMAGE_RESOURCE_BMP16_SAVE_PNG);
   m_tabs_riskManagement.AddToElementsArray(TAB_RISK_MANAGEMENT_STOP_LOST, m_btn_save_StopLost_Setting);
   if(!m_btn_save_StopLost_Setting.Create(this.m_chart_id, M_SUBWINDOW_MAIN, "BtnSaveStopLost", x_gap, fixed_y + frame_h + M_CONTROL_BORDER_GAP, 80, M_CONTROL_HEIGHT)) return false;
   //--- What is saved: the setting is the same for every Symbol, so it is set once, here
   CTradingSetupSetting *setting = (m_TradingSetupManager != NULL) ? m_TradingSetupManager.Setting() : NULL;
   //--- Which mode the Stop Loss uses: the switch of each frame, one of them is ON
   bool indicator_mode = (setting != NULL && setting.StopLostMode() == SL_MODE_INDICATOR);
   if(!CreateSwitch(m_btn_stoplost_switch[0], indicator_mode, m_frame_stoplost_setting_indicatormode, "SwitchSLIndicator", frame_w - M_SECTION_TOGGLE_WIDTH - pad, 0)) return false;
   if(!CreateSwitch(m_btn_stoplost_switch[1], !indicator_mode, m_frame_stoplost_setting_fixedmode, "SwitchSLFixed", frame_w - M_SECTION_TOGGLE_WIDTH - pad, 0)) return false;
   double          fixed_mult = (setting != NULL) ? setting.StopLostFixedMultiplier() : 2.0;
   ENUM_TIMEFRAMES atr_tf     = (setting != NULL) ? setting.StopLostIndTF()           : PERIOD_CURRENT;
   double          atr_mult   = (setting != NULL) ? setting.StopLostIndMultiplier()   : 1.5;
   int             atr_period = 14;
   if(setting != NULL)
    {
     MqlParam sl_ind_p[];
     setting.GetStopLostIndParams(sl_ind_p);
     if(::ArraySize(sl_ind_p) > 0) atr_period = (int)sl_ind_p[0].integer_value;
    }
   m_edit_StopLost_FixedPoint.SetValue(::DoubleToString(fixed_mult, 2));
   m_edit_ATR_Multiplexer.SetValue(::DoubleToString(atr_mult, 2));
   SyncComboBox_ATRChoice(atr_tf, atr_period);
   UpdateStopLostPreview(::Symbol());
   return true;
  }
 //--- The full list: every ATR(period) of the ATR templates on every timeframe Python serves, M1 first
 int CGUIPannel::BuildATRChoiceList(ENUM_TIMEFRAMES &out_tf[], int &out_period[])
  {
   int n = 0;
   ::ArrayResize(out_tf,     0);
   ::ArrayResize(out_period, 0);
   if(m_SymbolTFManager == NULL || m_IndicatorTemplateManager == NULL) return 0;
   int periods[];
   int templates_total = m_IndicatorTemplateManager.Total();
   for(int t = 0; t < templates_total; t++)
    {
     CIndicatorSetting *tpl = m_IndicatorTemplateManager.At(t);
     if(tpl == NULL || tpl.TypeEnum() != IND_ATR) continue;
     MqlParam raw[];
     tpl.GetRawParams(raw);
     if(::ArraySize(raw) == 0) continue;
     ::ArrayResize(periods, ::ArraySize(periods) + 1);
     periods[::ArraySize(periods) - 1] = (int)raw[0].integer_value;
    }
   ENUM_TIMEFRAMES tfs[];
   int tf_total = m_SymbolTFManager.AvailableTimeframes(tfs);
   for(int f = 0; f < tf_total; f++)
      for(int p = 0; p < ::ArraySize(periods); p++)
       {
        ::ArrayResize(out_tf,     n + 1);
        ::ArrayResize(out_period, n + 1);
        out_tf[n]     = tfs[f];
        out_period[n] = periods[p];
        n++;
       }
   return n;
  }
 //--- Refill the ATR combobox, re-select the saved (tf, period) or else the smallest TF
 bool CGUIPannel::SyncComboBox_ATRChoice(const ENUM_TIMEFRAMES saved_tf, const int saved_period)
  {
   ENUM_TIMEFRAMES local_tf[];
   int             local_period[];
   int n = BuildATRChoiceList(local_tf, local_period);
   //--- No ATR template or no timeframe list from Python yet: one "N/A" item, never a real choice
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
 bool CGUIPannel::GetSelectedATRChoice(ENUM_TIMEFRAMES &out_tf, int &out_period)
  {
   ENUM_TIMEFRAMES local_tf[];
   int             local_period[];
   int n   = BuildATRChoiceList(local_tf, local_period);
   int idx = m_combobox_ATR_choice.GetListViewPointer().SelectedItemIndex();
   if(idx < 0 || idx >= n) return false;
   out_tf     = local_tf[idx];
   out_period = local_period[idx];
   return true;
  }
 //--- Fixed and Indicator distances (points) from the form's current, possibly unsaved, values
 bool CGUIPannel::UpdateStopLostPreview(const string symbol)
  {
   double fixed_mult = ::StringToDouble(m_edit_StopLost_FixedPoint.GetValue());
   CSymbol *sym = (m_SymbolsCollection != NULL) ? m_SymbolsCollection.GetSymbolObjByName(symbol) : NULL;
   int spread_pts = (sym != NULL) ? sym.Spread() : (int)::SymbolInfoInteger(symbol, SYMBOL_SPREAD);
   string fixed_text = ::StringFormat("%d P", (int)::MathRound(spread_pts * fixed_mult));
   string ind_text = "-";
   double mult = ::StringToDouble(m_edit_ATR_Multiplexer.GetValue());
   ENUM_TIMEFRAMES tf;
   int             period;
   if(m_TradingEngine != NULL && GetSelectedATRChoice(tf, period))
    {
     MqlParam raw_params[1];
     raw_params[0].type          = TYPE_INT;
     raw_params[0].integer_value = period;
     int pts = m_TradingEngine.GetIndicator_StopLostDistance_Points(symbol, tf, IND_ATR, raw_params, mult);
     if(pts >= 0) ind_text = ::StringFormat("%d P", pts);
    }
   bool changed = false;
   int min_pts = (sym != NULL) ? (sym.Spread() / 2 + sym.TradeStopLevel()) : (int)::SymbolInfoInteger(symbol, SYMBOL_TRADE_STOPS_LEVEL);
   string min_text = "Min Stop Lot - " + (string)min_pts;
   if(m_label_StopLost_MinPts.Text() != min_text)
    {
     m_label_StopLost_MinPts.SetText(min_text);
     m_label_StopLost_MinPts.Draw(false);
     changed = true;
    }
   string preview_text[2];
   preview_text[0] = "Value in Point - " + fixed_text;
   preview_text[1] = "Value in Point - " + ind_text;
   for(int k = 0; k < 2; k++)
      if(m_label_StopLost_ValuePreview[k].Text() != preview_text[k])
       {
        m_label_StopLost_ValuePreview[k].SetText(preview_text[k]);
        m_label_StopLost_ValuePreview[k].Draw(false);
        changed = true;
       }
   return changed;
  }
 //+------------------------------------------------------------------+
 //| What the user did in the Stop Loss tab                           |
 //+------------------------------------------------------------------+
 void CGUIPannel::OnEvent_Tab_StopLost(const int id,const long &lparam,const double &dparam,const string &sparam)
  {
   //--- The switch of a frame: the clicked one ON turns the other OFF, the clicked one OFF turns the other ON (dparam = the new state); Save keeps it
   for(int s = 0; s < 2; s++)
      if(id == CHARTEVENT_CUSTOM + ON_CLICK_BUTTON && lparam == m_btn_stoplost_switch[s].ObjectID())
        {
         bool on = (dparam != 0);
         m_btn_stoplost_switch[s].SetText(on ? "ON" : "OFF");
         m_btn_stoplost_switch[s].Draw(true);
         m_btn_stoplost_switch[1 - s].SetState(!on);
         m_btn_stoplost_switch[1 - s].SetText(!on ? "ON" : "OFF");
         m_btn_stoplost_switch[1 - s].Draw(true);
         return;
        }
   //--- The indicator templates or the timeframes of Python changed: the ATR list follows them, the pick stays when it is still there
   if(id == CHARTEVENT_CUSTOM + INDICATOR_TEMPLATE_MANAGER_EVENT_ADDED || id == CHARTEVENT_CUSTOM + INDICATOR_TEMPLATE_MANAGER_EVENT_DELETE ||
      id == CHARTEVENT_CUSTOM + SYMBOLTF_MANAGER_EVENT_TIMEFRAMES_CHANGED)
     {
      if(m_first_start || m_TradingSetupManager == NULL) return;
      CTradingSetupSetting *setting = m_TradingSetupManager.Setting();
      int atr_period = 14;
      MqlParam sl_ind_p[];
      setting.GetStopLostIndParams(sl_ind_p);
      if(::ArraySize(sl_ind_p) > 0) atr_period = (int)sl_ind_p[0].integer_value;
      SyncComboBox_ATRChoice(setting.StopLostIndTF(), atr_period);
      ::ChartRedraw(this.m_chart_id);
      return;
     }
   //--- Save commits BOTH Fixed and Indicator StopLost config at once, the same for every Symbol; the ATR of the chart Symbol is made if it is not there
   if(id == CHARTEVENT_CUSTOM + ON_CLICK_BUTTON && lparam == m_btn_save_StopLost_Setting.ObjectID())
     {
      string symbol = ::Symbol();
      if(m_TradingSetupManager == NULL) return;
      CTradingSetupSetting *row_setting = m_TradingSetupManager.Setting();
      row_setting.StopLostFixedMultiplier(::StringToDouble(m_edit_StopLost_FixedPoint.GetValue()));
      row_setting.StopLostIndMultiplier(::StringToDouble(m_edit_ATR_Multiplexer.GetValue()));
      row_setting.StopLostMode(m_btn_stoplost_switch[0].State() ? SL_MODE_INDICATOR : SL_MODE_FIXED);   // the frame that is ON
      ENUM_TIMEFRAMES tf;
      int             period;
      if(GetSelectedATRChoice(tf, period))
       {
        row_setting.StopLostIndTF(tf);
        row_setting.StopLostIndType(IND_ATR);
        MqlParam sl_ind_p[1];
        sl_ind_p[0].type          = TYPE_INT;
        sl_ind_p[0].integer_value = period;
        row_setting.SetStopLostIndParams(sl_ind_p);
        //--- Python calculates the tracked pairs only: the pair of the choice joins them (the events keep the panel and Python in step)
        if(m_SymbolTFManager != NULL && !m_SymbolTFManager.Exists(symbol, tf))
         {
          m_SymbolTFManager.Add_SymbolTFSetting(symbol, tf);
          m_SymbolTFManager.SaveToJSON();
         }
        if(m_IndicatorsCollection != NULL && m_IndicatorsCollection.GetIndicator(IND_ATR, sl_ind_p, symbol, tf) == NULL)
           m_IndicatorsCollection.CreateIndicator(IND_ATR, sl_ind_p, symbol, tf);
       }
      m_TradingSetupManager.NotifySettingChanged();
      m_TradingSetupManager.SaveToJSON();
      UpdateStopLostPreview(symbol);
      ::ChartRedraw(this.m_chart_id);
      return;
     }
   //--- ATR pick: only a draft, the preview follows; Save commits the Fixed and the Indicator mode together
   if(id == CHARTEVENT_CUSTOM + ON_CLICK_COMBOBOX_ITEM && lparam == m_combobox_ATR_choice.ObjectID())
     {
      if(UpdateStopLostPreview(::Symbol()))
         ::ChartRedraw(this.m_chart_id);
      return;
     }
  }
#endif // CGUIPANNEL_TABQUICKSETTING_RISKMANAGEMENT_STOPLOST_MQH
