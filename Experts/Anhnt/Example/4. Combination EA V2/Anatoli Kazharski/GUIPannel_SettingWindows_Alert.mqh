//+------------------------------------------------------------------+
//|                               GUIPannel_SettingWindows_Alert.mqh |
//| Setting Alert window: Marker on Chart / Sound tabs, built on the |
//| Combination Lib V2 controls                                      |
//+------------------------------------------------------------------+
#ifndef CGUIPANNEL_SETTINGWINDOWS_ALERT_MQH
#define CGUIPANNEL_SETTINGWINDOWS_ALERT_MQH
#include "GUIPannel.mqh"
 bool CGUIPannel::CreateWindow_SettingMarkerAndSound(const string caption_text,const int x_gap, const int y_gap)
  {
   m_window_setting_markerAndSound.FontSize(DEF_FONT_SIZE);
   m_window_setting_markerAndSound.IsMovable(true);
   m_window_setting_markerAndSound.ResizeMode(true);
   m_window_setting_markerAndSound.CloseButtonIsUsed(true);
   m_window_setting_markerAndSound.MinimumXSize(M_WINDOW_MIN_WIDTH);
   m_window_setting_markerAndSound.MinimumYSize(M_WINDOW_MIN_HEIGHT);
   m_window_setting_markerAndSound.WindowType(W_DIALOG);
   if(!m_window_setting_markerAndSound.CreateWindow(m_chart_id, m_subwin, caption_text, x_gap, y_gap, M_WINDOW_SETTING_WIDTH, M_WINDOW_SETTING_HEIGHT))
      return false;
   m_window_setting_markerAndSound.IconFile(IMAGE_RESOURCE_BMP16_ALERT_ON_PNG);
   return true;
  }
 void CGUIPannel::OpenWindow_SettingMarkerAndSound(void)
  {
   m_window_setting_markerAndSound.OpenWindow();
   ::ChartRedraw(m_chart_id);
  }
 bool CGUIPannel::CreateTab_SettingMarkerAndSound(const int x_gap, const int y_gap)
  {
   string tabs_names[ENUM_TAB_SETTING_MARKERANDSOUND_TOTAL] = {"Marker", "Sound"};
   m_tabs_setting_markerAndSound.PositionMode(TABS_TOP);
   m_tabs_setting_markerAndSound.AutoXResizeMode(true);
   m_tabs_setting_markerAndSound.AutoYResizeMode(true);
   m_tabs_setting_markerAndSound.AutoXResizeRightOffset(3);
   m_tabs_setting_markerAndSound.AutoYResizeBottomOffset(3);
   for(int i = 0; i < ENUM_TAB_SETTING_MARKERANDSOUND_TOTAL; i++)
      m_tabs_setting_markerAndSound.AddTab(tabs_names[i], 100);
   m_window_setting_markerAndSound.AddChild(&m_tabs_setting_markerAndSound);
   return m_tabs_setting_markerAndSound.CreateTabs(m_chart_id, m_subwin, "TabsSettingAlert", x_gap, y_gap);
  }
 void CGUIPannel::OnEvent_Window_SettingMarkerAndSound(const int id,const long &lparam, const double &dparam, const string &sparam)
  {
   //--- Sound On/Off checkboxes apply live, Save only persists them
    if(id == CHARTEVENT_CUSTOM + ON_CLICK_CHECKBOX &&
       (lparam == m_checkbox_buy_sound.ObjectID() || lparam == m_checkbox_sell_sound.ObjectID() || lparam == m_checkbox_trailing_sound.ObjectID()))
     {
      bool on = (dparam != 0);   // the new state sent with the event
      if(lparam == m_checkbox_buy_sound.ObjectID())
         m_buy_sound_enabled = on;
      else if(lparam == m_checkbox_sell_sound.ObjectID())
         m_sell_sound_enabled = on;
      else
        {
         m_trailing_sound_enabled = on;
         ApplyTrailingSoundToAllSymbols(m_combo_trailling_sound.GetValue(), on);
        }
      return;
     }
   //--- Smart Money check box: Show of every Smart Money element on or off (the table keeps the fine control)
    if(id == CHARTEVENT_CUSTOM + ON_CLICK_CHECKBOX && lparam == m_checkbox_show_smartMoney_markers.ObjectID())
     {
      ApplyShowToAllSmartMoney(dparam != 0);
      return;
     }
   //--- Combo pick: the swatches update right away, before Save (dparam = selected index)
    if(id == CHARTEVENT_CUSTOM + ON_CLICK_COMBOBOX_ITEM)
     {
      int sel = (int)dparam;
      color mcolors[]; string color_labels[];
      if(m_marker_setting != NULL) m_marker_setting.GetColorChoices(mcolors, color_labels);
      bool color_ok = (sel >= 0 && sel < ::ArraySize(mcolors));
      if(lparam == m_combo_color_buy.ObjectID())                   { if(color_ok) UpdateColorPreview(0, mcolors[sel]); return; }
      if(lparam == m_combo_color_sell.ObjectID())                  { if(color_ok) UpdateColorPreview(1, mcolors[sel]); return; }
      if(lparam == m_combo_color_nonrelated.ObjectID())            { if(color_ok) UpdateColorPreview(2, mcolors[sel]); return; }
      if(lparam == m_combo_buy_sound.ObjectID())  { m_marker_buy_sound_file  = sparam;  return; }
      if(lparam == m_combo_sell_sound.ObjectID()) { m_marker_sell_sound_file = sparam; return; }
      return;
     }
   //--- Save marker style: commit every combo's current pick, then the full config write
    if(id == CHARTEVENT_CUSTOM + ON_CLICK_BUTTON && lparam == m_btn_save_marker_settings.ObjectID())
     {
      if(m_marker_setting == NULL) return;
      color mcolors[]; string color_labels[];
      m_marker_setting.GetColorChoices(mcolors, color_labels);
      int n_colors = ::ArraySize(mcolors);
      color buy_clr = m_marker_setting.BuyColor(), sell_clr = m_marker_setting.SellColor(), nonrelated_clr = m_marker_setting.NonRelatedColor();
      int sel;
      sel = m_combo_color_buy.GetListViewPointer().SelectedItemIndex();
      if(sel >= 0 && sel < n_colors) buy_clr = mcolors[sel];
      sel = m_combo_color_sell.GetListViewPointer().SelectedItemIndex();
      if(sel >= 0 && sel < n_colors) sell_clr = mcolors[sel];
      sel = m_combo_color_nonrelated.GetListViewPointer().SelectedItemIndex();
      if(sel >= 0 && sel < n_colors) nonrelated_clr = mcolors[sel];
      m_marker_setting.SetColors(buy_clr, sell_clr, nonrelated_clr);
      m_marker_setting.SetShowMarkers(m_checkbox_show_indicator_markers.State(), m_checkbox_show_candle_markers.State(),
                                      m_checkbox_show_smartMoney_markers.State());
      SaveAllSettingsToJSON();
      ::EventChartCustom(::ChartID(), (ushort)GUIPANNEL_EVENT_MARKER_SETTING_CHANGED, 0, 0.0, "");
      return;
     }
   //--- Save sound: apply the trailing sound choice, then the full config write
    if(id == CHARTEVENT_CUSTOM + ON_CLICK_BUTTON && lparam == m_btn_save_sound_settings.ObjectID())
     {
      ApplyTrailingSoundToAllSymbols(m_combo_trailling_sound.GetValue(), m_checkbox_trailing_sound.State());
      SaveAllSettingsToJSON();
      return;
     }
  }
#endif // CGUIPANNEL_SETTINGWINDOWS_ALERT_MQH
