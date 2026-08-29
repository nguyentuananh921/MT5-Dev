//+------------------------------------------------------------------+
//|                              GUIPannel_SettingWindows_Marker.mqh |
//+------------------------------------------------------------------+
//Bug Note: Sound in folder C:\Program Files\MetaTrader 5\Sounds
#ifndef CGUIPANNEL_SETTINGWINDOWS_MARKER_MQH
#define CGUIPANNEL_SETTINGWINDOWS_MARKER_MQH
#include "GUIPannel.mqh" 
 //+----------------------------------------------------------------------------+
 //| Loads the "Markers_Setting"/"Sound_Settings" sections of                   |
 //| Config_Setting.json. Always sets sane defaults first so a                  |
 //| missing/partial file (or one with no "Markers_Setting" key yet)            |
 //| still leaves the EA in a working state.                                    |
 //+----------------------------------------------------------------------------+
 void CGUIPannel::LoadMarkerSettingsFromJSON(void)
  {
   //For default value reference at https://www.mql5.com/en/docs/constants/objectconstants/wingdings
   //Marker for indicator
    m_marker_single_indicator_buy_code  = 217;
    m_marker_single_indicator_sell_code = 218;
    m_marker_multi_indicator_buy_code   = 67;   // Thumb Up
    m_marker_multi_indicator_sell_code  = 68;   // Thumb Down
   //Marker for Pattern
    m_marker_pattern_buy_code  = 39;   //Candle
    m_marker_pattern_sell_code = 39;   //Candle
   //Marker for Combo
    m_marker_combo_buy_code    = 83;  // Bomb
    m_marker_combo_sell_code   = 83;  // Bomb
   //For default color
    m_marker_buy_color        = clrLime;
    m_marker_sell_color       = clrRed;
    m_marker_nonrelated_color = clrGray;
   //For Config_Setting.json    
    string full_path = g_ea_folder + "/Config_Setting.json";
    string content = JSONConfig_ReadWholeFile(full_path);
    if(content == "") return;
    // --- Read back the human-readable labels SaveMarkerSettingsToJSON now writes ("83 Bomb",
    // --- "Dodger Blue") - reverse-lookup via ArrowCodeForLabel/ColorForLabel against the SAME
    // --- GetMarker*Choices catalogs, falling back to the default already set above if the
    // --- label is missing/unrecognized (e.g. older JSON, or a hand-edited typo).
    string sv;
    if(::JSONConfig_StringValue(content, "single_indicator_buy_arrow_code",  sv)) m_marker_single_indicator_buy_code  = ArrowCodeForLabel(sv, m_marker_single_indicator_buy_code);
    if(::JSONConfig_StringValue(content, "single_indicator_sell_arrow_code", sv)) m_marker_single_indicator_sell_code = ArrowCodeForLabel(sv, m_marker_single_indicator_sell_code);
    if(::JSONConfig_StringValue(content, "multi_indicator_buy_arrow_code",   sv)) m_marker_multi_indicator_buy_code   = ArrowCodeForLabel(sv, m_marker_multi_indicator_buy_code);
    if(::JSONConfig_StringValue(content, "multi_indicator_sell_arrow_code",  sv)) m_marker_multi_indicator_sell_code  = ArrowCodeForLabel(sv, m_marker_multi_indicator_sell_code);
    if(::JSONConfig_StringValue(content, "pattern_buy_arrow_code",  sv)) m_marker_pattern_buy_code  = ArrowCodeForLabel(sv, m_marker_pattern_buy_code);
    if(::JSONConfig_StringValue(content, "pattern_sell_arrow_code", sv)) m_marker_pattern_sell_code = ArrowCodeForLabel(sv, m_marker_pattern_sell_code);
    if(::JSONConfig_StringValue(content, "combo_buy_arrow_code",    sv)) m_marker_combo_buy_code    = ArrowCodeForLabel(sv, m_marker_combo_buy_code);
    if(::JSONConfig_StringValue(content, "combo_sell_arrow_code",   sv)) m_marker_combo_sell_code   = ArrowCodeForLabel(sv, m_marker_combo_sell_code);
    if(::JSONConfig_StringValue(content, "buy_color",        sv)) m_marker_buy_color        = ColorForLabel(sv, m_marker_buy_color);
    if(::JSONConfig_StringValue(content, "sell_color",       sv)) m_marker_sell_color       = ColorForLabel(sv, m_marker_sell_color);
    if(::JSONConfig_StringValue(content, "nonrelated_color", sv)) m_marker_nonrelated_color = ColorForLabel(sv, m_marker_nonrelated_color);
  }
 //+----------------------------------------------------------------------------+
 //| Read-only snapshot for EA - see declaration comment in GUIPannel.mqh.       |
 //+----------------------------------------------------------------------------+
 void CGUIPannel::GetMarkerSettings(int &single_buy, int &single_sell, int &multi_buy, int &multi_sell,
                                     int &pattern_buy, int &pattern_sell, int &combo_buy, int &combo_sell,
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
   buy_clr        = m_marker_buy_color;
   sell_clr       = m_marker_sell_color;
   nonrelated_clr = m_marker_nonrelated_color;
  }  
  // ScanSoundFolder() moved to GUIPannel_SettingWindows_Sound.mqh - own tab now.
 //+----------------------------------------------------------------------------+
 //| Writes the "Markers_Setting" section of Config_Setting.json straight from  |
 //| m_marker_*_code/m_marker_*_color (already committed by the Save button's   |
 //| own combo-read block) - preserves the 4 sections owned elsewhere.          |
 //+----------------------------------------------------------------------------+
 void CGUIPannel::SaveMarkerSettingsToJSON(void)
  {
   string full_path = g_ea_folder + "/Config_Setting.json";
   string existing        = JSONConfig_ReadWholeFile(full_path);
   string symbols_tf      = JSONConfig_ExtractRawSection(existing, "Symbols_TFs_List");
   string templates       = JSONConfig_ExtractRawSection(existing, "Indicator_Templates");
   string pattern_alerts  = JSONConfig_ExtractRawSection(existing, "Pattern_Alerts_Setting");
   string sound_settings  = JSONConfig_ExtractRawSection(existing, "Sound_Settings");

   string json = "{\n";
   if(symbols_tf     != "") json += " \"Symbols_TFs_List\": "     + symbols_tf     + ",\n";
   if(templates      != "") json += " \"Indicator_Templates\": "  + templates      + ",\n";
   if(pattern_alerts != "") json += " \"Pattern_Alerts_Setting\": " + pattern_alerts + ",\n";
   if(sound_settings != "") json += " \"Sound_Settings\": "       + sound_settings + ",\n";
   // --- Human-readable labels (Anhnt, 2026-08-15), not raw Wingdings codes/color ints - e.g.
   // --- "83 Bomb" / "Dodger Blue" instead of "83" / "65280" - matches exactly what the combo
   // --- shows (ArrowLabelForCode/ColorLabelForValue look up the SAME GetMarker*Choices catalogs).
   json += " \"Markers_Setting\": {\n" +
       "  \"single_indicator_buy_arrow_code\": \""  + ArrowLabelForCode(m_marker_single_indicator_buy_code) + "\",\n" +
       "  \"single_indicator_sell_arrow_code\": \"" + ArrowLabelForCode(m_marker_single_indicator_sell_code) + "\",\n" +
       "  \"multi_indicator_buy_arrow_code\": \""   + ArrowLabelForCode(m_marker_multi_indicator_buy_code) + "\",\n" +
       "  \"multi_indicator_sell_arrow_code\": \""  + ArrowLabelForCode(m_marker_multi_indicator_sell_code) + "\",\n" +
       "  \"pattern_buy_arrow_code\": \""  + ArrowLabelForCode(m_marker_pattern_buy_code) + "\",\n" +
       "  \"pattern_sell_arrow_code\": \"" + ArrowLabelForCode(m_marker_pattern_sell_code) + "\",\n" +
       "  \"combo_buy_arrow_code\": \""    + ArrowLabelForCode(m_marker_combo_buy_code) + "\",\n" +
       "  \"combo_sell_arrow_code\": \""   + ArrowLabelForCode(m_marker_combo_sell_code) + "\",\n" +
       "  \"buy_color\": \""        + ColorLabelForValue(m_marker_buy_color) + "\",\n" +
       "  \"sell_color\": \""       + ColorLabelForValue(m_marker_sell_color) + "\",\n" +
       "  \"nonrelated_color\": \"" + ColorLabelForValue(m_marker_nonrelated_color) + "\"\n" +
       " }\n}";

   int fh = ::FileOpen(full_path, FILE_TXT | FILE_WRITE | FILE_ANSI);
   if(fh == INVALID_HANDLE)
    {
     ::Print(__FUNCTION__, " > cannot open ", full_path, " for writing, err=", ::GetLastError());
     return;
    }
   ::FileWriteString(fh, json);
   ::FileClose(fh);
   ::Print(__FUNCTION__, " > saved marker settings to ", full_path);
  }
 bool CGUIPannel::CreateTabSettingConfig_Marker(const int x, const int y)
  {
   //Define for GUI Layout in tab Marker
    #define SETTING_MARKER_BASE_X_GAP 10
    #define SETTING_MARKER_CAPTION_WIDTH  125 //For Non-Related Color, it needs 105px width to display the text 
    #define SETTING_MARKER_COMBOBOX_WIDTH 125 //Combobox share    
    #define SETTING_MARKER_PREVIEW_WIDTH  26  //Icon preview
    #define SETTING_MARKER_GAP            5   //Gap between combobox and Preview 
    #define SETTING_MARKER_COL_GAP        10  //Gap between col 1 and col 2
    #define SETTING_MARKER_ROW_GAP        10  //Gap between rows    
    #define SETTING_MARKER_ROW_HEIGHT     26
   //Calculation for Position for first 4 row
    #define SETTING_MARKER_COL1_BASE_X      x + SETTING_MARKER_BASE_X_GAP
    #define SETTING_MARKER_COL1_COMBO_X     SETTING_MARKER_COL1_BASE_X + SETTING_MARKER_CAPTION_WIDTH
    #define SETTING_MARKER_COL1_PREVIEW_X   SETTING_MARKER_COL1_BASE_X + SETTING_MARKER_CAPTION_WIDTH + SETTING_MARKER_COMBOBOX_WIDTH + SETTING_MARKER_GAP
    #define SETTING_MARKER_COL2_BASE_X      SETTING_MARKER_COL1_PREVIEW_X + SETTING_MARKER_PREVIEW_WIDTH + SETTING_MARKER_COL_GAP
    #define SETTING_MARKER_COL2_COMBO_X     SETTING_MARKER_COL2_BASE_X    + SETTING_MARKER_CAPTION_WIDTH + SETTING_MARKER_GAP
    #define SETTING_MARKER_COL2_PREVIEW_X   SETTING_MARKER_COL2_COMBO_X   + SETTING_MARKER_COMBOBOX_WIDTH +SETTING_MARKER_GAP  
   //Calculation position for Color row 5 & 6
    #define SETTING_MARKER_COLOR_COMBO_WIDTH     70  //For Color combo box
    #define SETTING_MARKER_COLOR_PREVIEW_WIDTH   70  //Color Preview Width    
    #define SETTING_MARKER_COL1_COLOR_PREVIEW_X  SETTING_MARKER_COL1_COMBO_X + SETTING_MARKER_COLOR_COMBO_WIDTH + SETTING_MARKER_GAP
    #define SETTING_MARKER_COL2_COLOR_PREVIEW_X  SETTING_MARKER_COL2_COMBO_X + SETTING_MARKER_COLOR_COMBO_WIDTH + SETTING_MARKER_GAP  
   //For sound row 7,8,9
    #define SETTING_MARKER_SOUND_WIDTH 350 //Combobox Sound file    
    
    LoadMarkerSettingsFromJSON(); // seed m_marker_* from Config_Setting.json's "markers" section before building defaults
    int codes[]; string shape_labels[];
    GetMarkerArrowCodeChoices(codes, shape_labels);
    color mcolors[]; string color_labels[];
    GetMarkerColorChoices(mcolors, color_labels);      
    
    //For shape of Marker
    int n_shapes = ArraySize(codes);
    int sel_single_buy = 0, sel_single_sell = 0, 
        sel_multi_buy = 0, sel_multi_sell = 0;
    int sel_pattern_buy = 0, sel_pattern_sell = 0, 
        sel_combo_buy = 0, sel_combo_sell = 0;
    for(int i = 0; i < n_shapes; i++)
     {
      if(codes[i] == m_marker_single_indicator_buy_code)  sel_single_buy  = i;
      if(codes[i] == m_marker_single_indicator_sell_code) sel_single_sell = i;
      if(codes[i] == m_marker_multi_indicator_buy_code)   sel_multi_buy   = i;
      if(codes[i] == m_marker_multi_indicator_sell_code)  sel_multi_sell  = i;
      if(codes[i] == m_marker_pattern_buy_code)           sel_pattern_buy = i;
      if(codes[i] == m_marker_pattern_sell_code)          sel_pattern_sell = i;
      if(codes[i] == m_marker_combo_buy_code)             sel_combo_buy   = i;
      if(codes[i] == m_marker_combo_sell_code)            sel_combo_sell  = i;
     }
    // For shape of Marker in Row 1: Single Buy Column 1, Single Sell Column 2
     //Column 1: Single Buy
      if(!CreateMarkerTabCaption(0, "Single Indicator Buy", SETTING_MARKER_COL1_BASE_X, y)) return false;
      if(!CreateMarkerTabComboBox(m_combo_shape_single_indicator_buy, SETTING_MARKER_COL1_COMBO_X, y, SETTING_MARKER_COMBOBOX_WIDTH, shape_labels, sel_single_buy)) return false;
      if(!CreateShapePreview(0, SETTING_MARKER_COL1_PREVIEW_X, y, m_marker_single_indicator_buy_code)) return false;
     //Column 2: Single Sell
      if(!CreateMarkerTabCaption(1, "Single Indicator Sell", SETTING_MARKER_COL2_BASE_X, y)) return false;
      if(!CreateMarkerTabComboBox(m_combo_shape_single_indicator_sell, SETTING_MARKER_COL2_COMBO_X, y, SETTING_MARKER_COMBOBOX_WIDTH, shape_labels, sel_single_sell)) return false;
      if(!CreateShapePreview(1, SETTING_MARKER_COL2_PREVIEW_X, y, m_marker_single_indicator_sell_code)) return false;
    // For shape of Marker in Row 2: Multi Buy Column 1, Multi Sell Column 2
     //Column 1: Multi Buy
       if(!CreateMarkerTabCaption(2, "Multi Indicator Buy", SETTING_MARKER_COL1_BASE_X, 
                                 y + SETTING_MARKER_ROW_HEIGHT+SETTING_MARKER_ROW_GAP)) return false;
       if(!CreateMarkerTabComboBox(m_combo_shape_multi_indicator_buy, SETTING_MARKER_COL1_COMBO_X, 
                                  y + SETTING_MARKER_ROW_HEIGHT+SETTING_MARKER_ROW_GAP, 
                                  SETTING_MARKER_COMBOBOX_WIDTH, shape_labels, sel_multi_buy)) return false;
       if(!CreateShapePreview(2, SETTING_MARKER_COL1_PREVIEW_X, 
                                  y + SETTING_MARKER_ROW_HEIGHT+SETTING_MARKER_ROW_GAP, 
                                  m_marker_multi_indicator_buy_code)) return false;
     //Column 2: Multi Sell 
       if(!CreateMarkerTabCaption(3, "Multi Indicator Sell", SETTING_MARKER_COL2_BASE_X, 
                                  y + SETTING_MARKER_ROW_HEIGHT+SETTING_MARKER_ROW_GAP)) return false;
       if(!CreateMarkerTabComboBox(m_combo_shape_multi_indicator_sell, SETTING_MARKER_COL2_COMBO_X, 
                                  y + SETTING_MARKER_ROW_HEIGHT+SETTING_MARKER_ROW_GAP, 
                                  SETTING_MARKER_COMBOBOX_WIDTH, shape_labels, sel_multi_sell)) return false;
       if(!CreateShapePreview(3, SETTING_MARKER_COL2_PREVIEW_X, 
                                  y + SETTING_MARKER_ROW_HEIGHT+SETTING_MARKER_ROW_GAP, 
                                  m_marker_multi_indicator_sell_code)) return false;
    // For shape of Marker in Row 3: Pattern Buy Column 1, Pattern Sell Column 2
     //Column 1: Pattern Buy
      if(!CreateMarkerTabCaption(4, "Pattern Buy", SETTING_MARKER_COL1_BASE_X, 
                                 y + SETTING_MARKER_ROW_HEIGHT * 2 +SETTING_MARKER_ROW_GAP*2)) return false;
      if(!CreateMarkerTabComboBox(m_combo_shape_pattern_buy, SETTING_MARKER_COL1_COMBO_X, 
                                 y + SETTING_MARKER_ROW_HEIGHT * 2+SETTING_MARKER_ROW_GAP*2, SETTING_MARKER_COMBOBOX_WIDTH, shape_labels, sel_pattern_buy)) return false;
      if(!CreateShapePreview(4, SETTING_MARKER_COL1_PREVIEW_X, 
                                 y + SETTING_MARKER_ROW_HEIGHT * 2+SETTING_MARKER_ROW_GAP*2, m_marker_pattern_buy_code)) return false;
     //Column 2: Pattern Sell 
      if(!CreateMarkerTabCaption(5, "Pattern Sell", SETTING_MARKER_COL2_BASE_X, 
                                  y + SETTING_MARKER_ROW_HEIGHT * 2+SETTING_MARKER_ROW_GAP*2)) return false;
      if(!CreateMarkerTabComboBox(m_combo_shape_pattern_sell, SETTING_MARKER_COL2_COMBO_X, 
                                  y + SETTING_MARKER_ROW_HEIGHT * 2+SETTING_MARKER_ROW_GAP*2, SETTING_MARKER_COMBOBOX_WIDTH, shape_labels, sel_pattern_sell)) return false;
      if(!CreateShapePreview(5, SETTING_MARKER_COL2_PREVIEW_X, 
                              y + SETTING_MARKER_ROW_HEIGHT * 2+SETTING_MARKER_ROW_GAP*2, m_marker_pattern_sell_code)) return false;
    //For shape of Marker in Row 4: Combo Buy Column 1, Combo Sell Column 2
     //Column 1: Combo Buy
      if(!CreateMarkerTabCaption(6, "Combo Buy", SETTING_MARKER_COL1_BASE_X, 
                                                 y + SETTING_MARKER_ROW_HEIGHT * 3+SETTING_MARKER_ROW_GAP*3)) return false;
      if(!CreateMarkerTabComboBox(m_combo_shape_combo_buy, SETTING_MARKER_COL1_COMBO_X, 
                                  y + SETTING_MARKER_ROW_HEIGHT * 3+SETTING_MARKER_ROW_GAP*3, SETTING_MARKER_COMBOBOX_WIDTH, shape_labels, sel_combo_buy)) return false;
      if(!CreateShapePreview(6, SETTING_MARKER_COL1_PREVIEW_X, 
                                y + SETTING_MARKER_ROW_HEIGHT*3+SETTING_MARKER_ROW_GAP*3, m_marker_combo_buy_code)) return false;
     //Column 2: Combo Sell 
      if(!CreateMarkerTabCaption(7, "Combo Sell", SETTING_MARKER_COL2_BASE_X, 
                                 y + SETTING_MARKER_ROW_HEIGHT*3 + SETTING_MARKER_ROW_GAP*3)) return false;
      if(!CreateMarkerTabComboBox(m_combo_shape_combo_sell, SETTING_MARKER_COL2_COMBO_X, 
                                 y + SETTING_MARKER_ROW_HEIGHT*3 + SETTING_MARKER_ROW_GAP*3, SETTING_MARKER_COMBOBOX_WIDTH, shape_labels, sel_combo_sell)) return false;
      if(!CreateShapePreview(7, SETTING_MARKER_COL2_PREVIEW_X, y + SETTING_MARKER_ROW_HEIGHT*3 + SETTING_MARKER_ROW_GAP*3, m_marker_combo_sell_code)) return false;
    //For Color       
      int n_colors = ArraySize(mcolors);
      int sel_buy = 0, sel_sell = 0, sel_nonrelated = 0;
      for(int i = 0; i < n_colors; i++)
      {
        if(mcolors[i] == m_marker_buy_color)        sel_buy        = i;
        if(mcolors[i] == m_marker_sell_color)       sel_sell       = i;
        if(mcolors[i] == m_marker_nonrelated_color) sel_nonrelated = i;
      } 
    //For color row 5 Buy Color on Left and Sell Color on Right
      int color_row0 = SETTING_MARKER_ROW_HEIGHT * 4 + SETTING_MARKER_ROW_GAP*4;  
     //Column 1: Buy Color
      if(!CreateMarkerTabCaption(8, "Buy Color", SETTING_MARKER_COL1_BASE_X, 
                                   y + SETTING_MARKER_ROW_HEIGHT * 4 + SETTING_MARKER_ROW_GAP*4)) return false;
      if(!CreateMarkerTabComboBox(m_combo_color_buy, SETTING_MARKER_COL1_COMBO_X, 
                                  y + SETTING_MARKER_ROW_HEIGHT * 4 + SETTING_MARKER_ROW_GAP*4, 
                                  SETTING_MARKER_COLOR_COMBO_WIDTH, color_labels, sel_buy)) return false;
      if(!CreateColorPreview(0, SETTING_MARKER_COL1_COLOR_PREVIEW_X, 
                            y + SETTING_MARKER_ROW_HEIGHT * 4 + SETTING_MARKER_ROW_GAP*4, m_marker_buy_color)) return false;          
     //Col 2: Sell Color
      if(!CreateMarkerTabCaption(9, "Sell Color", SETTING_MARKER_COL2_BASE_X, 
                                y +   SETTING_MARKER_ROW_HEIGHT * 4 + SETTING_MARKER_ROW_GAP*4)) return false;
      if(!CreateMarkerTabComboBox(m_combo_color_sell, SETTING_MARKER_COL2_COMBO_X, 
                                  y + SETTING_MARKER_ROW_HEIGHT * 4 + SETTING_MARKER_ROW_GAP*4, SETTING_MARKER_COLOR_COMBO_WIDTH, color_labels, sel_sell)) return false;
      if(!CreateColorPreview(1, SETTING_MARKER_COL2_COLOR_PREVIEW_X,
                              y + SETTING_MARKER_ROW_HEIGHT * 4 + SETTING_MARKER_ROW_GAP*4, m_marker_sell_color)) return false;
    //For color of row 6: Non Related Color on Left and ... on Right
      if(!CreateMarkerTabCaption(10, "Non-Related Color", SETTING_MARKER_COL1_BASE_X, 
                                    y + SETTING_MARKER_ROW_HEIGHT * 5 + SETTING_MARKER_ROW_GAP*5)) return false;
      if(!CreateMarkerTabComboBox(m_combo_color_nonrelated,SETTING_MARKER_COL1_COMBO_X, 
                                    y + SETTING_MARKER_ROW_HEIGHT * 5 + SETTING_MARKER_ROW_GAP*5, SETTING_MARKER_COLOR_COMBO_WIDTH, color_labels, sel_nonrelated)) return false;
      if(!CreateColorPreview(2, SETTING_MARKER_COL1_COLOR_PREVIEW_X, 
                                  y + SETTING_MARKER_ROW_HEIGHT * 5 + SETTING_MARKER_ROW_GAP*5, m_marker_nonrelated_color)) return false;
    // Sound Folder/Buy Sound/Sell Sound moved to CreateTabSettingConfig_Sound()
    // (GUIPannel_SettingWindows_Sound.mqh) - own tab now, split away from Marker.
    //For Button Save marker settings
      m_btn_save_marker_settings.MainPointer(m_tabs_main_setting_config);
      m_tabs_main_setting_config.AddToElementsArray(TAB_TAB_MAIN_SETTINGS_CONFIG_MARKER, m_btn_save_marker_settings);
      m_btn_save_marker_settings.AutoXResizeMode(false);
      m_btn_save_marker_settings.XSize(80);
      m_btn_save_marker_settings.IconFile(IMAGE_RESOURCE_BMP16_SAVE_PNG);
      if(!m_btn_save_marker_settings.CreateButton("Save", x + SETTING_MARKER_BASE_X_GAP, 
                                 y + SETTING_MARKER_ROW_HEIGHT * 9 + SETTING_MARKER_ROW_GAP*9)) return false;
    CWndContainer::AddToElementsArray(WindowIdx(m_window_setting), m_btn_save_marker_settings);

    return true;
  }
 // --- Shared recipe for every combobox on the Other tab (4 shape + 3 color) - same
 // --- creation/population steps as m_param_combo[]'s own recipe, just factored out since
 // --- 7 combos would otherwise repeat it verbatim.
 bool CGUIPannel::CreateMarkerTabComboBox(CComboBox &combo, const int x, const int y, const int combo_w, string &labels[], const int selected_index, const int tab_index)
  {
    combo.MainPointer(m_tabs_main_setting_config);
    m_tabs_main_setting_config.AddToElementsArray(tab_index, combo);
    int n = ArraySize(labels);
    combo.XSize(combo_w);
    combo.YSize(SETTING_MARKER_ROW_HEIGHT);
    combo.ItemsTotal(n);    
    int list_h = 18 * n + 4;
    if(list_h > 300) list_h = 300;
    combo.GetListViewPointer().YSize(list_h);
    combo.GetButtonPointer().XGap(1);
    combo.GetButtonPointer().XSize(combo_w);
    combo.GetButtonPointer().LabelYGap(4);
    combo.GetButtonPointer().IconYGap(3);
    if(!combo.CreateComboBox("", x, y)) return false;
    CWndContainer::AddToElementsArray(WindowIdx(m_window_setting), combo);

    combo.GetListViewPointer().Rebuilding(n);
    for(int i = 0; i < n; i++)
      combo.SetValue(i, labels[i]);
      combo.SelectItem(selected_index);
      combo.GetListViewPointer().Update(true);
    return true;
  }
 // --- Caption to the LEFT of a combo, e.g. "Single Buy:" - m_label_other_caption[row].
 bool CGUIPannel::CreateMarkerTabCaption(const int row, const string text, const int x, const int y, const int tab_index)
  {
    m_label_other_caption[row].MainPointer(m_tabs_main_setting_config);
    m_tabs_main_setting_config.AddToElementsArray(tab_index, m_label_other_caption[row]);
    m_label_other_caption[row].XSize(SETTING_MARKER_CAPTION_WIDTH);
    if(!m_label_other_caption[row].CreateTextLabel(text, x, y)) return false;
    CWndContainer::AddToElementsArray(WindowIdx(m_window_setting), m_label_other_caption[row]);
    return true;
  }
 // --- Preview to the RIGHT of a shape combo - renders the ACTUAL Wingdings glyph (not just
 // --- its numeric code) so the user can see what the shape looks like before saving.
 bool CGUIPannel::CreateShapePreview(const int row, const int x, const int y, const int arrow_code)
  {
    m_preview_shape[row].MainPointer(m_tabs_main_setting_config);
    m_tabs_main_setting_config.AddToElementsArray(TAB_TAB_MAIN_SETTINGS_CONFIG_MARKER, m_preview_shape[row]);
    m_preview_shape[row].Font("Wingdings");
    m_preview_shape[row].FontSize(16);
    if(!m_preview_shape[row].CreateTextLabel(::ShortToString((ushort)arrow_code), x, y)) return false;
    CWndContainer::AddToElementsArray(WindowIdx(m_window_setting), m_preview_shape[row]);
    return true;
  } 
 bool CGUIPannel::CreateColorPreview(const int row, const int x, const int y, const color clr)
  {
   //CColorButton         m_preview_color[3];
    m_preview_color[row].MainPointer(m_tabs_main_setting_config);
    m_tabs_main_setting_config.AddToElementsArray(TAB_TAB_MAIN_SETTINGS_CONFIG_MARKER, m_preview_color[row]);
    m_preview_color[row].CurrentColor(clr);
   //Setting size by Using CElementBase method
    m_preview_color[row].XSize(SETTING_MARKER_PREVIEW_WIDTH);
    m_preview_color[row].YSize(SETTING_MARKER_ROW_HEIGHT);
    m_preview_color[row].GetButtonPointer().XSize(SETTING_MARKER_COLOR_PREVIEW_WIDTH - 2);
    m_preview_color[row].GetButtonPointer().XGap(1);
    m_preview_color[row].GetButtonPointer().YSize(SETTING_MARKER_ROW_HEIGHT);
    if(!m_preview_color[row].CreateColorButton("", x, y)) return false;
    CWndContainer::AddToElementsArray(WindowIdx(m_window_setting), m_preview_color[row]);
    return true;
  }
 // --- Live-updates a shape preview as the user browses the combo, BEFORE clicking Save -
 // --- called from OnEvent's ON_CLICK_COMBOBOX_ITEM handling, not from OnClickSaveMarkerSettings
 // --- (which commits the choice to m_marker_* instead).
 void CGUIPannel::UpdateShapePreview(const int row, const int arrow_code)
  {
    m_preview_shape[row].LabelText(::ShortToString((ushort)arrow_code));
    m_preview_shape[row].Update(true);
  }
 void CGUIPannel::UpdateColorPreview(const int row, const color clr)
  {
    m_preview_color[row].CurrentColor(clr);
    m_preview_color[row].Update(true);
    m_preview_color[row].GetButtonPointer().Update(true);
  } 
 // --- Fixed catalog of common Wingdings arrow codes offered in all 4 marker-shape combos. 
 void CGUIPannel::GetMarkerArrowCodeChoices(int &codes[], string &labels[])
  {
   //See https://www.mql5.com/en/docs/constants/objectconstants/wingdings for reference
   int    c[] = {39,67, 68, 83, 86, 108, 109, 159, 161, 162, 217, 218, 233, 234};
   string l[] = {"39 Candle",
                 "67 Thumb Up", 
                 "68 Thumb Down",
                 "83 Bomb",
                 "86 Lightning",
                 "108 Circle", 
                 "109 Circle Filled",
                 "159 Diamond", 
                 "161 Diamond Filled", 
                 "162 Star", 
                 "217 Chevron Up", 
                 "218 Chevron Down",
                 "233 Arrow Up", 
                 "234 Arrow Down"};
    ArrayCopy(codes,  c);
    ArrayCopy(labels, l);
  } 
 // --- Fixed color palette offered in all 3 marker-color combos - CColorPicker is a hard-
 // --- coded 348x266 full HSL/RGB/Lab dialog (ColorPicker.mqh:234-235, no compact variant),
 // --- not worth it for what's really just picking from a short list of common colors.
 void CGUIPannel::GetMarkerColorChoices(color &colors[], string &labels[])
  {
    color  c[] = {clrLime, clrGreen, clrDodgerBlue, clrOrange, clrYellow,
                  clrRed, clrCrimson, clrMagenta,
                  clrGray, clrSilver, clrWhite, clrBlack};
    string l[] = {"Lime", "Green", "Dodger Blue", "Orange", "Yellow",
                  "Red", "Crimson", "Magenta",
                "Gray", "Silver", "White", "Black"};
    ArrayCopy(colors, c);
    ArrayCopy(labels, l);
  }
 // --- Round-trip helpers for Config_Setting.json (Anhnt, 2026-08-15): look up against the
 // --- SAME catalogs above so save/load always matches what the combo actually shows.
 // --- Falls back to the raw number/int if the code/color isn't in the fixed catalog (e.g. an
 // --- older JSON saved a value outside the current choice list).
 string CGUIPannel::ArrowLabelForCode(const int code)
  {
   int codes[]; string labels[];
   GetMarkerArrowCodeChoices(codes, labels);
   for(int i = 0; i < ArraySize(codes); i++)
      if(codes[i] == code) return labels[i];
   return (string)code;
  }
 int CGUIPannel::ArrowCodeForLabel(const string label, const int default_code)
  {
   int codes[]; string labels[];
   GetMarkerArrowCodeChoices(codes, labels);
   for(int i = 0; i < ArraySize(labels); i++)
      if(labels[i] == label) return codes[i];
   return default_code;
  }
 string CGUIPannel::ColorLabelForValue(const color clr)
  {
   color colors[]; string labels[];
   GetMarkerColorChoices(colors, labels);
   for(int i = 0; i < ArraySize(colors); i++)
      if(colors[i] == clr) return labels[i];
   return (string)(int)clr;
  }
 color CGUIPannel::ColorForLabel(const string label, const color default_color)
  {
   color colors[]; string labels[];
   GetMarkerColorChoices(colors, labels);
   for(int i = 0; i < ArraySize(labels); i++)
      if(labels[i] == label) return colors[i];
   return default_color;
  } 
 void CGUIPannel::PurgeSignalArrowObjects(const string sym, const string tf_string)
  {
   string prefix = ::MQLInfoString(MQL_PROGRAM_NAME) + "_sig_" + sym + "_" + tf_string + "_";
   for(int i = ::ObjectsTotal(m_chart_id) - 1; i >= 0; i--)
    {
     string obj_name = ::ObjectName(m_chart_id, i);
     if(::StringFind(obj_name, prefix) == 0)
        ::ObjectDelete(m_chart_id, obj_name);
    }
 }
#endif//CGUIPANNEL_SETTINGWINDOWS_MARKER_MQH