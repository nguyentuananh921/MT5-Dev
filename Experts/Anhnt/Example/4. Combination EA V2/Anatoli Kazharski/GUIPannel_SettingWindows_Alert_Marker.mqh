//+------------------------------------------------------------------+
//|                        GUIPannel_SettingWindows_Alert_Marker.mqh |
//| Marker tab: Wingdings shape + color of every marker family       |
//+------------------------------------------------------------------+
#ifndef CGUIPANNEL_SETTINGWINDOWS_ALERT_MARKER_MQH
#define CGUIPANNEL_SETTINGWINDOWS_ALERT_MARKER_MQH
#include "GUIPannel.mqh"
 #define SETTING_MARKER_BASE_X_GAP     10
 #define SETTING_MARKER_CAPTION_WIDTH  130   // combo caption, "Non-Related Color" is the longest
 #define SETTING_MARKER_COMBOBOX_WIDTH 150
 #define SETTING_MARKER_PREVIEW_WIDTH  32
 #define SETTING_MARKER_GAP            5
 #define SETTING_MARKER_COL_GAP        10
 #define SETTING_MARKER_ROW_STEP       30
 #define SETTING_MARKER_PAD            8
 #define SETTING_MARKER_LIST_ROWS      8    // visible rows of a dropdown list
 #define SETTING_MARKER_IN_ROW0_Y      18   // below the frame caption cut into the top border
 #define SETTING_MARKER_COLOR_COMBO_WIDTH   100
 #define SETTING_MARKER_COLOR_PREVIEW_WIDTH 40
 //--- Defaults first, so a missing or partial "Markers_Setting" still leaves a working state
 void CGUIPannel::LoadMarkerSettingsFromJSON(void)
  {
   //--- Wingdings codes, see https://www.mql5.com/en/docs/constants/objectconstants/wingdings
   m_marker_single_indicator_buy_code  = 217;   // Chevron Up
   m_marker_single_indicator_sell_code = 218;   // Chevron Down
   m_marker_multi_indicator_buy_code   = 67;    // Thumb Up
   m_marker_multi_indicator_sell_code  = 68;    // Thumb Down
   m_marker_pattern_buy_code           = 39;    // Candle
   m_marker_pattern_sell_code          = 39;
   m_marker_combo_buy_code             = 171;   // Star Filled
   m_marker_combo_sell_code            = 171;
   m_marker_swing_high_code            = 252;   // Check
   m_marker_swing_low_code             = 252;
   m_marker_buy_color                  = clrDodgerBlue;
   m_marker_sell_color                 = clrCrimson;
   m_marker_nonrelated_color           = clrGray;
   if(m_SymbolTFManager == NULL) return;
   string full_path = m_SymbolTFManager.GetFolderName() + "/Config_Setting.json";
   string content = JSONConfig_ReadWholeFile(full_path);
   if(content == "") return;
   //--- Stored as the combo labels ("83 Bomb", "Dodger Blue"), mapped back through the same catalogs
   string sv;
   if(::JSONConfig_StringValue(content, "single_indicator_buy_arrow_code",  sv)) m_marker_single_indicator_buy_code  = ArrowCodeForLabel(sv, m_marker_single_indicator_buy_code);
   if(::JSONConfig_StringValue(content, "single_indicator_sell_arrow_code", sv)) m_marker_single_indicator_sell_code = ArrowCodeForLabel(sv, m_marker_single_indicator_sell_code);
   if(::JSONConfig_StringValue(content, "multi_indicator_buy_arrow_code",   sv)) m_marker_multi_indicator_buy_code   = ArrowCodeForLabel(sv, m_marker_multi_indicator_buy_code);
   if(::JSONConfig_StringValue(content, "multi_indicator_sell_arrow_code",  sv)) m_marker_multi_indicator_sell_code  = ArrowCodeForLabel(sv, m_marker_multi_indicator_sell_code);
   if(::JSONConfig_StringValue(content, "pattern_buy_arrow_code",  sv)) m_marker_pattern_buy_code  = ArrowCodeForLabel(sv, m_marker_pattern_buy_code);
   if(::JSONConfig_StringValue(content, "pattern_sell_arrow_code", sv)) m_marker_pattern_sell_code = ArrowCodeForLabel(sv, m_marker_pattern_sell_code);
   if(::JSONConfig_StringValue(content, "combo_buy_arrow_code",    sv)) m_marker_combo_buy_code    = ArrowCodeForLabel(sv, m_marker_combo_buy_code);
   if(::JSONConfig_StringValue(content, "combo_sell_arrow_code",   sv)) m_marker_combo_sell_code   = ArrowCodeForLabel(sv, m_marker_combo_sell_code);
   if(::JSONConfig_StringValue(content, "swing_high_arrow_code",   sv)) m_marker_swing_high_code   = ArrowCodeForLabel(sv, m_marker_swing_high_code);
   if(::JSONConfig_StringValue(content, "swing_low_arrow_code",    sv)) m_marker_swing_low_code    = ArrowCodeForLabel(sv, m_marker_swing_low_code);
   if(::JSONConfig_StringValue(content, "buy_color",        sv)) m_marker_buy_color        = ColorForLabel(sv, m_marker_buy_color);
   if(::JSONConfig_StringValue(content, "sell_color",       sv)) m_marker_sell_color       = ColorForLabel(sv, m_marker_sell_color);
   if(::JSONConfig_StringValue(content, "nonrelated_color", sv)) m_marker_nonrelated_color = ColorForLabel(sv, m_marker_nonrelated_color);
  }
 //--- Read-only snapshot for the EA (SignalMarkers iCustom inputs)
 void CGUIPannel::GetMarkerSettings(int &single_buy, int &single_sell, int &multi_buy, int &multi_sell,
                                    int &pattern_buy, int &pattern_sell, int &combo_buy, int &combo_sell,
                                    int &swing_high, int &swing_low,
                                    color &buy_clr, color &sell_clr, color &nonrelated_clr) const
  {
   single_buy     = m_marker_single_indicator_buy_code;
   single_sell    = m_marker_single_indicator_sell_code;
   multi_buy      = m_marker_multi_indicator_buy_code;
   multi_sell     = m_marker_multi_indicator_sell_code;
   pattern_buy    = m_marker_pattern_buy_code;
   pattern_sell   = m_marker_pattern_sell_code;
   combo_buy      = m_marker_combo_buy_code;
   combo_sell     = m_marker_combo_sell_code;
   swing_high     = m_marker_swing_high_code;
   swing_low      = m_marker_swing_low_code;
   buy_clr        = m_marker_buy_color;
   sell_clr       = m_marker_sell_color;
   nonrelated_clr = m_marker_nonrelated_color;
  }
 //--- Value of the "Markers_Setting" key; SaveAllSettingsToJSON writes the file
 void CGUIPannel::BuildJsonSection_Markers(string &out_json)
  {
   out_json = "{\n" +
       "  \"single_indicator_buy_arrow_code\": \""  + ArrowLabelForCode(m_marker_single_indicator_buy_code) + "\",\n" +
       "  \"single_indicator_sell_arrow_code\": \"" + ArrowLabelForCode(m_marker_single_indicator_sell_code) + "\",\n" +
       "  \"multi_indicator_buy_arrow_code\": \""   + ArrowLabelForCode(m_marker_multi_indicator_buy_code) + "\",\n" +
       "  \"multi_indicator_sell_arrow_code\": \""  + ArrowLabelForCode(m_marker_multi_indicator_sell_code) + "\",\n" +
       "  \"pattern_buy_arrow_code\": \""  + ArrowLabelForCode(m_marker_pattern_buy_code) + "\",\n" +
       "  \"pattern_sell_arrow_code\": \"" + ArrowLabelForCode(m_marker_pattern_sell_code) + "\",\n" +
       "  \"combo_buy_arrow_code\": \""    + ArrowLabelForCode(m_marker_combo_buy_code) + "\",\n" +
       "  \"combo_sell_arrow_code\": \""   + ArrowLabelForCode(m_marker_combo_sell_code) + "\",\n" +
       "  \"swing_high_arrow_code\": \""   + ArrowLabelForCode(m_marker_swing_high_code) + "\",\n" +
       "  \"swing_low_arrow_code\": \""    + ArrowLabelForCode(m_marker_swing_low_code) + "\",\n" +
       "  \"buy_color\": \""        + ColorLabelForValue(m_marker_buy_color) + "\",\n" +
       "  \"sell_color\": \""       + ColorLabelForValue(m_marker_sell_color) + "\",\n" +
       "  \"nonrelated_color\": \"" + ColorLabelForValue(m_marker_nonrelated_color) + "\"\n" +
       " }";
  }
 //--- 2 framed columns (Buy Marker | Sell Marker): 5 shape rows + color row each; Non-Related Color and Save below
 bool CGUIPannel::CreateTab_SettingConfig_Marker(const int x, const int y)
  {
   LoadMarkerSettingsFromJSON();
   int codes[]; string shape_labels[];
   GetMarkerArrowCodeChoices(codes, shape_labels);
   color mcolors[]; string color_labels[];
   GetMarkerColorChoices(mcolors, color_labels);
   const int frame_w   = SETTING_MARKER_PAD + SETTING_MARKER_CAPTION_WIDTH + SETTING_MARKER_COMBOBOX_WIDTH + SETTING_MARKER_GAP + SETTING_MARKER_PREVIEW_WIDTH + SETTING_MARKER_PAD;
   const int frame_h   = SETTING_MARKER_IN_ROW0_Y + 4 * SETTING_MARKER_ROW_STEP + M_CONTROL_HEIGHT + SETTING_MARKER_PAD;
   const int frame1_x  = x + SETTING_MARKER_BASE_X_GAP;
   const int frame2_x  = frame1_x + frame_w + SETTING_MARKER_COL_GAP;
   const int preview_x = SETTING_MARKER_PAD + SETTING_MARKER_CAPTION_WIDTH + SETTING_MARKER_COMBOBOX_WIDTH + SETTING_MARKER_GAP;
   m_frame_buy_marker.SetText("Buy Marker");
   m_tabs_setting_markerAndSound.AddToElementsArray(ENUM_TAB_SETTING_MARKERANDSOUND_MARKER, m_frame_buy_marker);
   if(!m_frame_buy_marker.CreateFrame(m_chart_id, m_subwin, "FrameBuyMarker", frame1_x, y, frame_w, frame_h)) return false;
   m_frame_sell_marker.SetText("Sell Marker");
   m_tabs_setting_markerAndSound.AddToElementsArray(ENUM_TAB_SETTING_MARKERANDSOUND_MARKER, m_frame_sell_marker);
   if(!m_frame_sell_marker.CreateFrame(m_chart_id, m_subwin, "FrameSellMarker", frame2_x, y, frame_w, frame_h)) return false;
   //--- Shape rows, even index = Buy frame, odd index = Sell frame (frame-relative coordinates)
   CComboBox *combos[10];
   combos[0] = GetPointer(m_combo_shape_single_indicator_buy);  combos[1] = GetPointer(m_combo_shape_single_indicator_sell);
   combos[2] = GetPointer(m_combo_shape_multi_indicator_buy);   combos[3] = GetPointer(m_combo_shape_multi_indicator_sell);
   combos[4] = GetPointer(m_combo_shape_pattern_buy);           combos[5] = GetPointer(m_combo_shape_pattern_sell);
   combos[6] = GetPointer(m_combo_shape_combo_buy);             combos[7] = GetPointer(m_combo_shape_combo_sell);
   combos[8] = GetPointer(m_combo_shape_swing_low);             combos[9] = GetPointer(m_combo_shape_swing_high);
   string captions[10]  = {"Single Indicator", "Single Indicator", "Multi Indicator", "Multi Indicator",
                           "Pattern", "Pattern", "Combo", "Combo", "Swing Low", "Swing High"};
   int    cur_codes[10] = {m_marker_single_indicator_buy_code, m_marker_single_indicator_sell_code,
                           m_marker_multi_indicator_buy_code,  m_marker_multi_indicator_sell_code,
                           m_marker_pattern_buy_code,          m_marker_pattern_sell_code,
                           m_marker_combo_buy_code,            m_marker_combo_sell_code,
                           m_marker_swing_low_code,            m_marker_swing_high_code};
   int    preview_rows[10] = {SHAPE_PREVIEW_SINGLE_INDICATOR_BUY, SHAPE_PREVIEW_SINGLE_INDICATOR_SELL,
                              SHAPE_PREVIEW_MULTI_INDICATOR_BUY,  SHAPE_PREVIEW_MULTI_INDICATOR_SELL,
                              SHAPE_PREVIEW_PATTERN_BUY,          SHAPE_PREVIEW_PATTERN_SELL,
                              SHAPE_PREVIEW_COMBO_BUY,            SHAPE_PREVIEW_COMBO_SELL,
                              SHAPE_PREVIEW_SWING_LOW,            SHAPE_PREVIEW_SWING_HIGH};
   for(int i = 0; i < 10; i++)
    {
     int sel = 0;
     for(int k = 0; k < ::ArraySize(codes); k++)
        if(codes[k] == cur_codes[i]) sel = k;
     CFrame *frame = (i % 2 == 0) ? GetPointer(m_frame_buy_marker) : GetPointer(m_frame_sell_marker);
     int row_y = SETTING_MARKER_IN_ROW0_Y + (i / 2) * SETTING_MARKER_ROW_STEP;
     combos[i].SetText(captions[i]);
     frame.AddChild(combos[i]);
     if(!CreateCombobox_MarkerSelection(combos[i], SETTING_MARKER_PAD, row_y, SETTING_MARKER_COMBOBOX_WIDTH, shape_labels, sel)) return false;
     frame.AddChild(GetPointer(m_preview_shape[preview_rows[i]]));
     if(!CreateTextLabel_ShapePreview(preview_rows[i], preview_x, row_y, cur_codes[i])) return false;
    }
   //--- "Color for Marker" frame across both columns: Buy | Sell, then Non-Related, aligned with the frames above
   const int color_frame_y = y + frame_h + SETTING_MARKER_PAD;
   const int color_frame_w = frame2_x + frame_w - frame1_x;
   const int color_frame_h = SETTING_MARKER_IN_ROW0_Y + SETTING_MARKER_ROW_STEP + M_CONTROL_HEIGHT + SETTING_MARKER_PAD;
   m_frame_color.SetText("Color for Marker");
   m_tabs_setting_markerAndSound.AddToElementsArray(ENUM_TAB_SETTING_MARKERANDSOUND_MARKER, m_frame_color);
   if(!m_frame_color.CreateFrame(m_chart_id, m_subwin, "FrameMarkerColor", frame1_x, color_frame_y, color_frame_w, color_frame_h)) return false;
   CComboBox *color_combos[3];
   color_combos[0] = GetPointer(m_combo_color_buy);
   color_combos[1] = GetPointer(m_combo_color_sell);
   color_combos[2] = GetPointer(m_combo_color_nonrelated);
   string color_captions[3] = {"Buy Color", "Sell Color", "Non-Related Color"};
   color  cur_colors[3]     = {m_marker_buy_color, m_marker_sell_color, m_marker_nonrelated_color};
   int    color_x[3]        = {SETTING_MARKER_PAD, frame2_x - frame1_x + SETTING_MARKER_PAD, SETTING_MARKER_PAD};
   int    color_y[3]        = {SETTING_MARKER_IN_ROW0_Y, SETTING_MARKER_IN_ROW0_Y, SETTING_MARKER_IN_ROW0_Y + SETTING_MARKER_ROW_STEP};
   for(int i = 0; i < 3; i++)
    {
     int sel = 0;
     for(int k = 0; k < ::ArraySize(mcolors); k++)
        if(mcolors[k] == cur_colors[i]) sel = k;
     m_frame_color.AddChild(color_combos[i]);
     m_frame_color.AddChild(GetPointer(m_colorbutton[i]));
     color_combos[i].SetText(color_captions[i]);
     if(!CreateCombobox_MarkerSelection(color_combos[i], color_x[i], color_y[i], SETTING_MARKER_COLOR_COMBO_WIDTH, color_labels, sel)) return false;
     int swatch_x = color_x[i] + SETTING_MARKER_CAPTION_WIDTH + SETTING_MARKER_COLOR_COMBO_WIDTH + SETTING_MARKER_GAP;
     if(!CreateColorButton_Preview(i, swatch_x, color_y[i], cur_colors[i])) return false;
    }
   m_btn_save_marker_settings.SetText("Save");
   m_btn_save_marker_settings.IconFile(IMAGE_RESOURCE_BMP16_SAVE_PNG);
   m_tabs_setting_markerAndSound.AddToElementsArray(ENUM_TAB_SETTING_MARKERANDSOUND_MARKER, m_btn_save_marker_settings);
   if(!m_btn_save_marker_settings.Create(m_chart_id, m_subwin, "BtnSaveMarker", frame1_x, color_frame_y + color_frame_h + SETTING_MARKER_PAD, 80, M_CONTROL_HEIGHT)) return false;
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
 //--- The actual Wingdings glyph next to a shape combo
 bool CGUIPannel::CreateTextLabel_ShapePreview(const int row, const int x, const int y, const int arrow_code)
  {
   m_preview_shape[row].Font("Wingdings");
   m_preview_shape[row].FontSize(14);
   m_preview_shape[row].LabelXGap(0);
   m_preview_shape[row].SetText(::ShortToString((ushort)(0xF000 + arrow_code)));   // Wingdings glyphs live at U+F020..U+F0FF
   if(m_preview_shape[row].Parent() == NULL) m_tabs_setting_markerAndSound.AddToElementsArray(ENUM_TAB_SETTING_MARKERANDSOUND_MARKER, m_preview_shape[row]);
   return m_preview_shape[row].Create(m_chart_id, m_subwin, "LabelMarkerPreview" + (string)row, x, y, SETTING_MARKER_PREVIEW_WIDTH, M_CONTROL_HEIGHT);
  }
 //--- Color swatch: a plain CButton whose background is the color (no color picker in Lib V2)
 bool CGUIPannel::CreateColorButton_Preview(const int row, const int x, const int y, const color clr)
  {
   if(m_colorbutton[row].Parent() == NULL) m_tabs_setting_markerAndSound.AddToElementsArray(ENUM_TAB_SETTING_MARKERANDSOUND_MARKER, m_colorbutton[row]);
   if(!m_colorbutton[row].Create(m_chart_id, m_subwin, "BtnMarkerColor" + (string)row, x, y, SETTING_MARKER_COLOR_PREVIEW_WIDTH, M_CONTROL_HEIGHT)) return false;
   UpdateColorPreview(row, clr);
   return true;
  }
 void CGUIPannel::UpdateShapePreview(const int row, const int arrow_code)
  {
   m_preview_shape[row].SetText(::ShortToString((ushort)(0xF000 + arrow_code)));
   m_preview_shape[row].Draw(true);
  }
 void CGUIPannel::UpdateColorPreview(const int row, const color clr)
  {
   m_colorbutton[row].GetBackColorControl().InitColors(clr, clr, clr, clr);
   m_colorbutton[row].ColorChange(COLOR_STATE_DEFAULT);
   m_colorbutton[row].Draw(true);
  }
 //--- Fixed catalog of Wingdings codes offered in every shape combo
 void CGUIPannel::GetMarkerArrowCodeChoices(int &codes[], string &labels[])
  {
   int    c[] = {39, 67, 68, 83, 86, 108, 109, 159, 161, 162, 171, 217, 218, 233, 234, 252};
   string l[] = {"39 Candle", "67 Thumb Up", "68 Thumb Down", "83 Bomb", "86 Lightning", "108 Circle", "109 Circle Filled",
                 "159 Diamond", "161 Diamond Filled", "162 Star", "171 Star Filled", "217 Chevron Up", "218 Chevron Down",
                 "233 Arrow Up", "234 Arrow Down", "252 Check"};
   ::ArrayCopy(codes,  c);
   ::ArrayCopy(labels, l);
  }
 //--- Fixed palette offered in every color combo
 void CGUIPannel::GetMarkerColorChoices(color &colors[], string &labels[])
  {
   color  c[] = {clrLime, clrGreen, clrDodgerBlue, clrOrange, clrYellow, clrRed, clrCrimson, clrMagenta, clrGray, clrSilver, clrWhite, clrBlack};
   string l[] = {"Lime", "Green", "Dodger Blue", "Orange", "Yellow", "Red", "Crimson", "Magenta", "Gray", "Silver", "White", "Black"};
   ::ArrayCopy(colors, c);
   ::ArrayCopy(labels, l);
  }
 //--- JSON round trip through the same catalogs; unknown values fall back to the raw number / default
 string CGUIPannel::ArrowLabelForCode(const int code)
  {
   int codes[]; string labels[];
   GetMarkerArrowCodeChoices(codes, labels);
   for(int i = 0; i < ::ArraySize(codes); i++)
      if(codes[i] == code) return labels[i];
   return (string)code;
  }
 int CGUIPannel::ArrowCodeForLabel(const string label, const int default_code)
  {
   int codes[]; string labels[];
   GetMarkerArrowCodeChoices(codes, labels);
   for(int i = 0; i < ::ArraySize(labels); i++)
      if(labels[i] == label) return codes[i];
   return default_code;
  }
 string CGUIPannel::ColorLabelForValue(const color clr)
  {
   color colors[]; string labels[];
   GetMarkerColorChoices(colors, labels);
   for(int i = 0; i < ::ArraySize(colors); i++)
      if(colors[i] == clr) return labels[i];
   return (string)(int)clr;
  }
 color CGUIPannel::ColorForLabel(const string label, const color default_color)
  {
   color colors[]; string labels[];
   GetMarkerColorChoices(colors, labels);
   for(int i = 0; i < ::ArraySize(labels); i++)
      if(labels[i] == label) return colors[i];
   return default_color;
  }
#endif //CGUIPANNEL_SETTINGWINDOWS_ALERT_MARKER_MQH
