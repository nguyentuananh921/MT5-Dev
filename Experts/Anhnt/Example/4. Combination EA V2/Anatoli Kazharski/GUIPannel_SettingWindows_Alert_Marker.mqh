//+------------------------------------------------------------------+
//|                        GUIPannel_SettingWindows_Alert_Marker.mqh |
//| Marker tab: the colors of the CCandleMarker badges               |
//+------------------------------------------------------------------+
#ifndef CGUIPANNEL_SETTINGWINDOWS_ALERT_MARKER_MQH
#define CGUIPANNEL_SETTINGWINDOWS_ALERT_MARKER_MQH
#include "GUIPannel.mqh"
 #define SETTING_MARKER_CAPTION_WIDTH  130   // combo caption, "Non-Related Color" is the longest
 #define SETTING_MARKER_COMBOBOX_WIDTH 150
 #define SETTING_MARKER_PREVIEW_WIDTH  32
 #define SETTING_MARKER_ROW_STEP       30
 #define SETTING_MARKER_LIST_ROWS      8    // visible rows of a dropdown list
 #define SETTING_MARKER_COLOR_COMBO_WIDTH   100
 #define SETTING_MARKER_COLOR_PREVIEW_WIDTH 40
 //--- "Color for Marker" frame: Buy | Sell, then Non-Related below; "Show Marker" frame under it; Save last
 bool CGUIPannel::CreateTab_SettingConfig_Marker(const int x, const int y)
  {
   if(m_marker_setting == NULL) return false;
   color mcolors[]; string color_labels[];
   m_marker_setting.GetColorChoices(mcolors, color_labels);
   const int frame_w   = M_CONTROL_BORDER_GAP + SETTING_MARKER_CAPTION_WIDTH + SETTING_MARKER_COMBOBOX_WIDTH + M_CONTROL_BORDER_GAP + SETTING_MARKER_PREVIEW_WIDTH + M_CONTROL_BORDER_GAP;
   const int frame1_x  = x + M_CONTROL_BORDER_GAP;
   const int frame2_x  = frame1_x + frame_w + M_CONTROL_BORDER_GAP;
   const int color_frame_w = frame2_x + frame_w - frame1_x;
   const int color_frame_h = M_CONTROL_HEIGHT + SETTING_MARKER_ROW_STEP + M_CONTROL_HEIGHT + M_CONTROL_BORDER_GAP;
   m_frame_color.SetText("Color for Marker");
   m_tabs_setting_markerAndSound.AddToElementsArray(ENUM_TAB_SETTING_MARKERANDSOUND_MARKER, m_frame_color);
   if(!m_frame_color.CreateFrame(m_chart_id, m_subwin, "FrameMarkerColor", frame1_x, y, color_frame_w, color_frame_h)) return false;
   CComboBox *color_combos[3];
   color_combos[0] = GetPointer(m_combo_color_buy);
   color_combos[1] = GetPointer(m_combo_color_sell);
   color_combos[2] = GetPointer(m_combo_color_nonrelated);
   string color_captions[3] = {"Buy Color", "Sell Color", "Non-Related Color"};
   color  cur_colors[3]     = {m_marker_setting.BuyColor(), m_marker_setting.SellColor(), m_marker_setting.NonRelatedColor()};
   int    color_x[3]        = {M_CONTROL_BORDER_GAP, frame2_x - frame1_x + M_CONTROL_BORDER_GAP, M_CONTROL_BORDER_GAP};
   int    color_y[3]        = {M_CONTROL_HEIGHT, M_CONTROL_HEIGHT, M_CONTROL_HEIGHT + SETTING_MARKER_ROW_STEP};
   for(int i = 0; i < 3; i++)
    {
     int sel = 0;
     for(int k = 0; k < ::ArraySize(mcolors); k++)
        if(mcolors[k] == cur_colors[i]) sel = k;
     m_frame_color.AddChild(color_combos[i]);
     m_frame_color.AddChild(GetPointer(m_colorbutton[i]));
     color_combos[i].SetText(color_captions[i]);
     if(!CreateCombobox_MarkerSelection(color_combos[i], color_x[i], color_y[i], SETTING_MARKER_COLOR_COMBO_WIDTH, color_labels, sel)) return false;
     int swatch_x = color_x[i] + SETTING_MARKER_CAPTION_WIDTH + SETTING_MARKER_COLOR_COMBO_WIDTH + M_CONTROL_BORDER_GAP;
     if(!CreateColorButton_Preview(i, swatch_x, color_y[i], cur_colors[i])) return false;
    }
   const int source_frame_y = y + color_frame_h + M_CONTROL_BORDER_GAP;
   const int source_frame_h = M_CONTROL_HEIGHT + SETTING_MARKER_ROW_STEP + M_CONTROL_HEIGHT + M_CONTROL_BORDER_GAP;
   if(!CreateFrame_MarkerSource(frame1_x, source_frame_y, color_frame_w, source_frame_h, frame2_x - frame1_x)) return false;
   m_btn_save_marker_settings.SetText("Save");
   m_btn_save_marker_settings.IconFile(IMAGE_RESOURCE_BMP16_SAVE_PNG);
   m_tabs_setting_markerAndSound.AddToElementsArray(ENUM_TAB_SETTING_MARKERANDSOUND_MARKER, m_btn_save_marker_settings);
   if(!m_btn_save_marker_settings.Create(m_chart_id, m_subwin, "BtnSaveMarker", frame1_x, source_frame_y + source_frame_h + M_CONTROL_BORDER_GAP, 80, M_CONTROL_HEIGHT)) return false;
   return true;
  }
 //--- "Show Marker" frame: which of the 3 sources make a marker show, 2 + 1 check boxes;
 //--- column_x = x of the second column inside the frame, the first one is at the border gap
 bool CGUIPannel::CreateFrame_MarkerSource(const int x, const int y, const int w, const int h, const int column_x)
  {
   m_frame_marker_source.SetText("Show Marker");
   m_tabs_setting_markerAndSound.AddToElementsArray(ENUM_TAB_SETTING_MARKERANDSOUND_MARKER, m_frame_marker_source);
   if(!m_frame_marker_source.CreateFrame(m_chart_id, m_subwin, "FrameMarkerSource", x, y, w, h)) return false;
   CCheckBox *source_boxes[3];
   source_boxes[0] = GetPointer(m_checkbox_show_indicator_markers);
   source_boxes[1] = GetPointer(m_checkbox_show_candle_markers);
   source_boxes[2] = GetPointer(m_checkbox_show_smartMoney_markers);
   string source_captions[3] = {"Indicator", "Candle Pattern", "Smart Money"};
   bool   source_states[3]   = {m_marker_setting.ShowIndicator(), m_marker_setting.ShowCandle(), m_marker_setting.ShowSmartMoney()};
   int    source_x[3]        = {M_CONTROL_BORDER_GAP, column_x + M_CONTROL_BORDER_GAP, M_CONTROL_BORDER_GAP};
   int    source_y[3]        = {M_CONTROL_HEIGHT, M_CONTROL_HEIGHT, M_CONTROL_HEIGHT + SETTING_MARKER_ROW_STEP};
   for(int i = 0; i < 3; i++)
    {
     m_frame_marker_source.AddChild(source_boxes[i]);
     source_boxes[i].SetText(source_captions[i]);
     if(!CreateCheckBox_Setting(source_boxes[i], source_x[i], source_y[i], source_states[i], ENUM_TAB_SETTING_MARKERANDSOUND_MARKER, SETTING_MARKER_CAPTION_WIDTH)) return false;
    }
   return true;
  }
 //--- Every combo of the Alert window: caption (combo's own SetText, if any) + list of labels
 bool CGUIPannel::CreateCombobox_MarkerSelection(CComboBox &combo, const int x, const int y, const int combo_w, string &labels[], const int selected_index, const int tab_index)
  {
   int n         = ::ArraySize(labels);
   int caption_w = (combo.Text() != "") ? SETTING_MARKER_CAPTION_WIDTH : 0;
   int list_h    = 18 * ::MathMax(::MathMin(n, SETTING_MARKER_LIST_ROWS), 1) + 4;   // longer lists scroll
   combo.ItemsTotal(n);
   if(combo.Parent() == NULL) m_tabs_setting_markerAndSound.AddToElementsArray(tab_index, combo);
   if(!combo.CreateComboBox(m_chart_id, m_subwin, "ComboAlert" + (string)combo.ObjectID(), x, y, caption_w + combo_w, M_CONTROL_HEIGHT, combo_w, list_h)) return false;
   combo.GetListViewPointer().Rebuilding(n);
   for(int i = 0; i < n; i++)
      combo.SetValue(i, labels[i]);
   if(n > 0)
      combo.SelectItem(selected_index);
   combo.GetListViewPointer().Draw(false);   // SetValue/SelectItem only store, the list canvas still shows the empty Rebuilding
   return true;
  }
 //--- Color swatch: a plain CButton whose background is the color (no color picker in Lib V2)
 bool CGUIPannel::CreateColorButton_Preview(const int row, const int x, const int y, const color clr)
  {
   if(m_colorbutton[row].Parent() == NULL) m_tabs_setting_markerAndSound.AddToElementsArray(ENUM_TAB_SETTING_MARKERANDSOUND_MARKER, m_colorbutton[row]);
   if(!m_colorbutton[row].Create(m_chart_id, m_subwin, "BtnMarkerColor" + (string)row, x, y, SETTING_MARKER_COLOR_PREVIEW_WIDTH, M_CONTROL_HEIGHT)) return false;
   UpdateColorPreview(row, clr);
   return true;
  }
 void CGUIPannel::UpdateColorPreview(const int row, const color clr)
  {
   m_colorbutton[row].GetBackColorControl().InitColors(clr, clr, clr, clr);
   m_colorbutton[row].ColorChange(COLOR_STATE_DEFAULT);
   m_colorbutton[row].Draw(true);
  }
#endif //CGUIPANNEL_SETTINGWINDOWS_ALERT_MARKER_MQH
