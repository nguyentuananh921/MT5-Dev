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
   m_window_setting_markerAndSound.FontSize(9);
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
 void CGUIPannel::CloseWindow_SettingMarkerAndSound(void)
  {
   if(m_window_setting_markerAndSound.IsVisible())
      m_window_setting_markerAndSound.CloseWindow();
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
      m_buy_sound_enabled      = m_checkbox_buy_sound.State();
      m_sell_sound_enabled     = m_checkbox_sell_sound.State();
      m_trailing_sound_enabled = m_checkbox_trailing_sound.State();
      if(lparam == m_checkbox_trailing_sound.ObjectID())
         ApplyTrailingSoundToAllSymbols(m_combo_trailling_sound.GetValue(), m_trailing_sound_enabled);
      return;
     }
   //--- Combo pick: previews update right away, before Save (dparam = selected index)
    if(id == CHARTEVENT_CUSTOM + ON_CLICK_COMBOBOX_ITEM)
     {
      int sel = (int)dparam;
      int codes[]; string shape_labels[];
      GetMarkerArrowCodeChoices(codes, shape_labels);
      bool shape_ok = (sel >= 0 && sel < ::ArraySize(codes));
      color mcolors[]; string color_labels[];
      GetMarkerColorChoices(mcolors, color_labels);
      bool color_ok = (sel >= 0 && sel < ::ArraySize(mcolors));
      if(lparam == m_combo_shape_single_indicator_buy.ObjectID())  { if(shape_ok) UpdateShapePreview(SHAPE_PREVIEW_SINGLE_INDICATOR_BUY,  codes[sel]); return; }
      if(lparam == m_combo_shape_single_indicator_sell.ObjectID()) { if(shape_ok) UpdateShapePreview(SHAPE_PREVIEW_SINGLE_INDICATOR_SELL, codes[sel]); return; }
      if(lparam == m_combo_shape_multi_indicator_buy.ObjectID())   { if(shape_ok) UpdateShapePreview(SHAPE_PREVIEW_MULTI_INDICATOR_BUY,   codes[sel]); return; }
      if(lparam == m_combo_shape_multi_indicator_sell.ObjectID())  { if(shape_ok) UpdateShapePreview(SHAPE_PREVIEW_MULTI_INDICATOR_SELL,  codes[sel]); return; }
      if(lparam == m_combo_shape_pattern_buy.ObjectID())           { if(shape_ok) UpdateShapePreview(SHAPE_PREVIEW_PATTERN_BUY,           codes[sel]); return; }
      if(lparam == m_combo_shape_pattern_sell.ObjectID())          { if(shape_ok) UpdateShapePreview(SHAPE_PREVIEW_PATTERN_SELL,          codes[sel]); return; }
      if(lparam == m_combo_shape_combo_buy.ObjectID())             { if(shape_ok) UpdateShapePreview(SHAPE_PREVIEW_COMBO_BUY,             codes[sel]); return; }
      if(lparam == m_combo_shape_combo_sell.ObjectID())            { if(shape_ok) UpdateShapePreview(SHAPE_PREVIEW_COMBO_SELL,            codes[sel]); return; }
      if(lparam == m_combo_shape_swing_high.ObjectID())            { if(shape_ok) UpdateShapePreview(SHAPE_PREVIEW_SWING_HIGH,            codes[sel]); return; }
      if(lparam == m_combo_shape_swing_low.ObjectID())             { if(shape_ok) UpdateShapePreview(SHAPE_PREVIEW_SWING_LOW,             codes[sel]); return; }
      if(lparam == m_combo_color_buy.ObjectID())                   { if(color_ok) UpdateColorPreview(0, mcolors[sel]); return; }
      if(lparam == m_combo_color_sell.ObjectID())                  { if(color_ok) UpdateColorPreview(1, mcolors[sel]); return; }
      if(lparam == m_combo_color_nonrelated.ObjectID())            { if(color_ok) UpdateColorPreview(2, mcolors[sel]); return; }
      if(lparam == m_combo_buy_sound.ObjectID())  { m_marker_buy_sound_file  = m_combo_buy_sound.GetValue();  return; }
      if(lparam == m_combo_sell_sound.ObjectID()) { m_marker_sell_sound_file = m_combo_sell_sound.GetValue(); return; }
      return;
     }
   //--- Save marker style: commit every combo's current pick, then the full config write
    if(id == CHARTEVENT_CUSTOM + ON_CLICK_BUTTON && lparam == m_btn_save_marker_settings.ObjectID())
     {
      int codes[]; string shape_labels[];
      GetMarkerArrowCodeChoices(codes, shape_labels);
      int n_shapes = ::ArraySize(codes);
      color mcolors[]; string color_labels[];
      GetMarkerColorChoices(mcolors, color_labels);
      int n_colors = ::ArraySize(mcolors);
      int sel;
      sel = m_combo_shape_single_indicator_buy.GetListViewPointer().SelectedItemIndex();
      if(sel >= 0 && sel < n_shapes) m_marker_single_indicator_buy_code  = codes[sel];
      sel = m_combo_shape_single_indicator_sell.GetListViewPointer().SelectedItemIndex();
      if(sel >= 0 && sel < n_shapes) m_marker_single_indicator_sell_code = codes[sel];
      sel = m_combo_shape_multi_indicator_buy.GetListViewPointer().SelectedItemIndex();
      if(sel >= 0 && sel < n_shapes) m_marker_multi_indicator_buy_code   = codes[sel];
      sel = m_combo_shape_multi_indicator_sell.GetListViewPointer().SelectedItemIndex();
      if(sel >= 0 && sel < n_shapes) m_marker_multi_indicator_sell_code  = codes[sel];
      sel = m_combo_shape_pattern_buy.GetListViewPointer().SelectedItemIndex();
      if(sel >= 0 && sel < n_shapes) m_marker_pattern_buy_code  = codes[sel];
      sel = m_combo_shape_pattern_sell.GetListViewPointer().SelectedItemIndex();
      if(sel >= 0 && sel < n_shapes) m_marker_pattern_sell_code = codes[sel];
      sel = m_combo_shape_combo_buy.GetListViewPointer().SelectedItemIndex();
      if(sel >= 0 && sel < n_shapes) m_marker_combo_buy_code  = codes[sel];
      sel = m_combo_shape_combo_sell.GetListViewPointer().SelectedItemIndex();
      if(sel >= 0 && sel < n_shapes) m_marker_combo_sell_code = codes[sel];
      sel = m_combo_shape_swing_high.GetListViewPointer().SelectedItemIndex();
      if(sel >= 0 && sel < n_shapes) m_marker_swing_high_code = codes[sel];
      sel = m_combo_shape_swing_low.GetListViewPointer().SelectedItemIndex();
      if(sel >= 0 && sel < n_shapes) m_marker_swing_low_code = codes[sel];
      sel = m_combo_color_buy.GetListViewPointer().SelectedItemIndex();
      if(sel >= 0 && sel < n_colors) m_marker_buy_color = mcolors[sel];
      sel = m_combo_color_sell.GetListViewPointer().SelectedItemIndex();
      if(sel >= 0 && sel < n_colors) m_marker_sell_color = mcolors[sel];
      sel = m_combo_color_nonrelated.GetListViewPointer().SelectedItemIndex();
      if(sel >= 0 && sel < n_colors) m_marker_nonrelated_color = mcolors[sel];
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
