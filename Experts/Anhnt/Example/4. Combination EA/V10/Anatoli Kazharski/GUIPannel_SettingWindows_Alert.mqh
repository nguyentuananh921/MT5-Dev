//+------------------------------------------------------------------+
//|                             GUIPannel_SettingWindows_Alert.mqh   |
//| Module for Setting Alert: Marker on Chart and Sound              |
//+------------------------------------------------------------------+
#ifndef CGUIPANNEL_SETTINGWINDOWS_ALERT_MQH
#define CGUIPANNEL_SETTINGWINDOWS_ALERT_MQH
#include "GUIPannel.mqh"
 bool CGUIPannel::CreateWindow_SettingMarkerAndSound(const string caption_text,const int x_gap, const int y_gap)
  {
   //--- Add a window pointer to the window array
    CWndContainer::AddWindow(m_window_setting_markerAndSound);
   //Setting Properties
    m_window_setting_markerAndSound.XSize(M_WINDOW_SETTING_WIDTH);
    m_window_setting_markerAndSound.YSize(M_WINDOW_SETTING_HEIGHT);
    m_window_setting_markerAndSound.FontSize(9);
    m_window_setting_markerAndSound.IsMovable(true);
    m_window_setting_markerAndSound.ResizeMode(true);
    m_window_setting_markerAndSound.CloseButtonIsUsed(true);
    m_window_setting_markerAndSound.CollapseButtonIsUsed(true);
    m_window_setting_markerAndSound.TooltipsButtonIsUsed(true);
    m_window_setting_markerAndSound.FullscreenButtonIsUsed(true);
    m_window_setting_markerAndSound.MinimumXSize(M_WINDOW_MIN_WIDTH);
    m_window_setting_markerAndSound.MinimumYSize(M_WINDOW_MIN_HEIGHT);
    m_window_setting_markerAndSound.WindowType(W_DIALOG);    
   //Show Window at 30,30
    if(!m_window_setting_markerAndSound.CreateWindow(m_chart_id, m_subwin, caption_text, x_gap, y_gap))
       return (false);
   //Set Icon after Create
    m_window_setting_markerAndSound.IconFile(IMAGE_RESOURCE_BMP16_ALERT_ON_PNG );
    m_window_setting_markerAndSound.IconFileLocked(IMAGE_RESOURCE_BMP16_ALERT_OFF_PNG);
    return (true);
  }
 void CGUIPannel::OpenWindow_SettingMarkerAndSound(void)
  {
    m_window_setting_markerAndSound.OpenWindow();
    //--- CWindow::Draw() paints whatever ChangeImage() last selected - IsLocked() alone never
    //--- flips it (only the caption background color reacts to that), so switch icons ourselves.
    m_window_setting_markerAndSound.ChangeImage(0, 0);   // IconFile - active
    
    HideWindow_CandleInfo();
    m_candle_info_shown_bar = 0;
    FormAvailableElementsArray();
  }
 void CGUIPannel::CloseWindow_SettingMarkerAndSound(void)
  {
    m_window_setting_markerAndSound.Hide();
    m_window_setting_markerAndSound.ChangeImage(0, 1);   // IconFileLocked - inactive
    m_active_window_index = WindowIdx(m_window_main);
    FormAvailableElementsArray();
  }
//For Tab Group on m_window_setting_markerAndSound
 //+----------------------------------------------------------------------------------------------+
 //| Create a tab group m_tabs_setting_markerAndSound for m_window_setting_markerAndSound          |
 //+----------------------------------------------------------------------------------------------+
 bool CGUIPannel::CreateTab_SettingMarkerAndSound(const int x_gap, const int y_gap)
  {
    string tabs_names[ENUM_TAB_SETTING_MARKERANDSOUND_TOTAL] = {"Marker", "Sound"};    
    m_tabs_setting_markerAndSound.MainPointer(m_window_setting_markerAndSound);
    //--- Properties
    m_tabs_setting_markerAndSound.IsCenterText(true);
    m_tabs_setting_markerAndSound.PositionMode(TABS_TOP);
    m_tabs_setting_markerAndSound.AutoXResizeMode(true);
    m_tabs_setting_markerAndSound.AutoYResizeMode(true);
    m_tabs_setting_markerAndSound.AutoXResizeRightOffset(3);
    m_tabs_setting_markerAndSound.AutoYResizeBottomOffset(3);
    //--- Add tabs with the specified properties
    for(int i = 0; i < ENUM_TAB_SETTING_MARKERANDSOUND_TOTAL; i++)
        m_tabs_setting_markerAndSound.AddTab(tabs_names[i], 100);
    //--- Create Tab before create other control element inside
     if(!m_tabs_setting_markerAndSound.CreateTabs(x_gap, y_gap))
        return (false);
    CWndContainer::AddToElementsArray(WindowIdx(m_window_setting_markerAndSound), m_tabs_setting_markerAndSound);    
    return (true);
  }
 void CGUIPannel::OnEvent_Window_SettingMarkerAndSound(const int id,const long &lparam, const double &dparam, const string &sparam)
  {
   //--- Setting Marker and Sound Window's native Close (X) button
     if(id == CHARTEVENT_CUSTOM + ON_CLOSE_DIALOG_BOX && lparam == m_window_setting_markerAndSound.Id())
      {
       CloseWindow_SettingMarkerAndSound();
       return;
      }
   //Handle combo selection - live-updates the preview immediately (BEFORE Save)
    if(id == CHARTEVENT_CUSTOM + ON_CLICK_COMBOBOX_ITEM)
     {
      int codes[]; string shape_labels[];
      GetMarkerArrowCodeChoices(codes, shape_labels);
      int n_shapes = ArraySize(codes);
      color mcolors[]; string color_labels[];
      GetMarkerColorChoices(mcolors, color_labels);
      int n_colors = ArraySize(mcolors);
      if(lparam == m_combo_shape_single_indicator_buy.Id())
       {
        int sel = (int)m_combo_shape_single_indicator_buy.GetListViewPointer().SelectedItemIndex();
        if(sel >= 0 && sel < n_shapes) UpdateShapePreview(SHAPE_PREVIEW_SINGLE_INDICATOR_BUY, codes[sel]);
        return;
       }
      if(lparam == m_combo_shape_single_indicator_sell.Id())
       {
        int sel = (int)m_combo_shape_single_indicator_sell.GetListViewPointer().SelectedItemIndex();
        if(sel >= 0 && sel < n_shapes) UpdateShapePreview(SHAPE_PREVIEW_SINGLE_INDICATOR_SELL, codes[sel]);
        return;
       }
      if(lparam == m_combo_shape_multi_indicator_buy.Id())
       {
        int sel = (int)m_combo_shape_multi_indicator_buy.GetListViewPointer().SelectedItemIndex();
        if(sel >= 0 && sel < n_shapes) UpdateShapePreview(SHAPE_PREVIEW_MULTI_INDICATOR_BUY, codes[sel]);
        return;
       }
      if(lparam == m_combo_shape_multi_indicator_sell.Id())
       {
        int sel = (int)m_combo_shape_multi_indicator_sell.GetListViewPointer().SelectedItemIndex();
        if(sel >= 0 && sel < n_shapes) UpdateShapePreview(SHAPE_PREVIEW_MULTI_INDICATOR_SELL, codes[sel]);
        return;
       }
      if(lparam == m_combo_shape_pattern_buy.Id())
       {
        int sel = (int)m_combo_shape_pattern_buy.GetListViewPointer().SelectedItemIndex();
        if(sel >= 0 && sel < n_shapes) UpdateShapePreview(SHAPE_PREVIEW_PATTERN_BUY, codes[sel]);
        return;
       }
      if(lparam == m_combo_shape_pattern_sell.Id())
       {
        int sel = (int)m_combo_shape_pattern_sell.GetListViewPointer().SelectedItemIndex();
        if(sel >= 0 && sel < n_shapes) UpdateShapePreview(SHAPE_PREVIEW_PATTERN_SELL, codes[sel]);
        return;
       }
      if(lparam == m_combo_shape_combo_buy.Id())
       {
        int sel = (int)m_combo_shape_combo_buy.GetListViewPointer().SelectedItemIndex();
        if(sel >= 0 && sel < n_shapes) UpdateShapePreview(SHAPE_PREVIEW_COMBO_BUY, codes[sel]);
        return;
       }
      if(lparam == m_combo_shape_combo_sell.Id())
       {
        int sel = (int)m_combo_shape_combo_sell.GetListViewPointer().SelectedItemIndex();
        if(sel >= 0 && sel < n_shapes) UpdateShapePreview(SHAPE_PREVIEW_COMBO_SELL, codes[sel]);
        return;
       }
      if(lparam == m_combo_color_buy.Id())
       {
        int sel = (int)m_combo_color_buy.GetListViewPointer().SelectedItemIndex();
        if(sel >= 0 && sel < n_colors) UpdateColorPreview(0, mcolors[sel]);
        return;
       }
      if(lparam == m_combo_color_sell.Id())
       {
        int sel = (int)m_combo_color_sell.GetListViewPointer().SelectedItemIndex();
        if(sel >= 0 && sel < n_colors) UpdateColorPreview(1, mcolors[sel]);
        return;
       }
      if(lparam == m_combo_color_nonrelated.Id())
       {
        int sel = (int)m_combo_color_nonrelated.GetListViewPointer().SelectedItemIndex();
        if(sel >= 0 && sel < n_colors) UpdateColorPreview(2, mcolors[sel]);
        return;
       }
      if(lparam == m_combo_buy_sound.Id())
       {
        int sel = (int)m_combo_buy_sound.GetListViewPointer().SelectedItemIndex();
        string files[];
        ScanSoundFolder(files);
        if(sel >= 0 && sel < ArraySize(files))
           m_marker_buy_sound_file = files[sel];
        return;
       }
      if(lparam == m_combo_sell_sound.Id())
       {
        int sel = (int)m_combo_sell_sound.GetListViewPointer().SelectedItemIndex();
        string files[];
        ScanSoundFolder(files);
        if(sel >= 0 && sel < ArraySize(files))
           m_marker_sell_sound_file = files[sel];
        return;
       }
     }
   // Handle Save Marker style/color settings - commits the currently-selected combo items
   if(id == CHARTEVENT_CUSTOM + ON_CLICK_BUTTON && lparam == m_btn_save_marker_settings.Id())
    {
     int codes[]; string shape_labels[];
     GetMarkerArrowCodeChoices(codes, shape_labels);
     int n_shapes = ArraySize(codes);
     color mcolors[]; string color_labels[];
     GetMarkerColorChoices(mcolors, color_labels);
     int n_colors = ArraySize(mcolors);
     int sel;
     sel = (int)m_combo_shape_single_indicator_buy.GetListViewPointer().SelectedItemIndex();
     if(sel >= 0 && sel < n_shapes) m_marker_single_indicator_buy_code  = codes[sel];
     sel = (int)m_combo_shape_single_indicator_sell.GetListViewPointer().SelectedItemIndex();
     if(sel >= 0 && sel < n_shapes) m_marker_single_indicator_sell_code = codes[sel];
     sel = (int)m_combo_shape_multi_indicator_buy.GetListViewPointer().SelectedItemIndex();
     if(sel >= 0 && sel < n_shapes) m_marker_multi_indicator_buy_code   = codes[sel];
     sel = (int)m_combo_shape_multi_indicator_sell.GetListViewPointer().SelectedItemIndex();
     if(sel >= 0 && sel < n_shapes) m_marker_multi_indicator_sell_code  = codes[sel];
     sel = (int)m_combo_shape_pattern_buy.GetListViewPointer().SelectedItemIndex();
       if(sel >= 0 && sel < n_shapes) m_marker_pattern_buy_code  = codes[sel];
       sel = (int)m_combo_shape_pattern_sell.GetListViewPointer().SelectedItemIndex();
       if(sel >= 0 && sel < n_shapes) m_marker_pattern_sell_code = codes[sel];
       sel = (int)m_combo_shape_combo_buy.GetListViewPointer().SelectedItemIndex();
       if(sel >= 0 && sel < n_shapes) m_marker_combo_buy_code  = codes[sel];
       sel = (int)m_combo_shape_combo_sell.GetListViewPointer().SelectedItemIndex();
       if(sel >= 0 && sel < n_shapes) m_marker_combo_sell_code = codes[sel];
       sel = (int)m_combo_color_buy.GetListViewPointer().SelectedItemIndex();
       if(sel >= 0 && sel < n_colors) m_marker_buy_color = mcolors[sel];
       sel = (int)m_combo_color_sell.GetListViewPointer().SelectedItemIndex();
       if(sel >= 0 && sel < n_colors) m_marker_sell_color = mcolors[sel];
       sel = (int)m_combo_color_nonrelated.GetListViewPointer().SelectedItemIndex();
       if(sel >= 0 && sel < n_colors) m_marker_nonrelated_color = mcolors[sel];
       SaveMarkerSettingsToJSON();
       // EA has no Manager for Marker style (fixed GUI-only fields) - fire so it can
       // re-attach SignalMarkers.mq5 with the new shape/color inputs (Anhnt, 2026-08-28).
       ::EventChartCustom(::ChartID(), (ushort)GUIPANNEL_EVENT_MARKER_SETTING_CHANGED, 0, 0.0, "");
        return;
      }
   // Handle Save Sound settings
      if(id == CHARTEVENT_CUSTOM + ON_CLICK_BUTTON && lparam == m_btn_save_sound_settings.Id())
       {
         SaveSoundSettingsToJSON();
         return;
       }
  }

#endif // CGUIPANNEL_SETTINGWINDOWS_ALERT_MQH