//+------------------------------------------------------------------+
//|                                   GUIPannel_TabSettingMarker.mqh |
//+------------------------------------------------------------------+
#ifndef CGUIPANNEL_TABSETTINGMARKER_MQH
#define CGUIPANNEL_TABSETTINGMARKER_MQH
 //Define for GUI Layout in tab Marker
  #define SETTING_MARKER_BASE_X_GAP 10

  #define SETTING_MARKER_CAPTION_WIDTH  125 //For Non-Related Color, it needs 105px width to display the text 
  #define SETTING_MARKER_COMBOBOX_WIDTH 125 //Combobox share & Sound file
  #define SETTING_MARKER_PREVIEW_WIDTH  26  //Icon preview
  #define SETTING_MARKER_GAP            5   //Gap between combobox and Preview 
  #define SETTING_MARKER_COL_GAP        10  //Gap between col 1 and col 2 

  #define SETTING_MARKER_COLOR_COMBO_WIDTH     70  //For Color combo box
  #define SETTING_MARKER_COLOR_PREVIEW_WIDTH   70  //Color Preview Width
  #define SETTING_MARKER_COLOR_PREVIEW_GAP     5  // Gap between Color Combo and Preview  
  //For sound
   #define SETTING_MARKER_LABEL_WIDTH_SOUND     120 //Label Width for Sound Folder         
   #define SETTING_MARKER_ROW_HEIGHT 26 
 //Tab Marker TAB_TAB_MAIN_SETTINGS_CONFIG_MARKER of Tab m_tabs_main_setting_config
 // --- "Marker" sub-tab (TAB_TAB_MAIN_SETTINGS_CONFIG_MARKER): 8 independent shape choices
 // --- (Single Buy/Sell, Multi Buy/Sell - each needs its OWN plot/shape, see
 // --- SignalMarkers.mq5's header comment) and 3 independent color choices (Buy/Sell when a
 // --- marker relates to this chart's own Symbol+TF, Non-Related otherwise) - shape and
 // --- color are orthogonal axes (Anhnt, 2026-07-17).
 bool CGUIPannel::CreateTabSettingConfig_Marker(const int x, const int y)
  {
    LoadMarkerSettings(); // seed m_marker_* from Config_Setting.json's "markers" section before building defaults
    int codes[]; string shape_labels[];
    GetMarkerArrowCodeChoices(codes, shape_labels);
    color mcolors[]; string color_labels[];
    GetMarkerColorChoices(mcolors, color_labels);       
    //Calculation for GUI Layout Column 1 Buy
    int base_x1    = x + SETTING_MARKER_BASE_X_GAP;
    int combo_x1   = base_x1 + SETTING_MARKER_CAPTION_WIDTH;
    int preview_x1 = combo_x1 + SETTING_MARKER_COMBOBOX_WIDTH + SETTING_MARKER_GAP;

    //Calculation for GUI Layout Column 2 (Sell)
    int base_x2    = preview_x1 + SETTING_MARKER_PREVIEW_WIDTH + SETTING_MARKER_COL_GAP; 
    int combo_x2   = base_x2 + SETTING_MARKER_CAPTION_WIDTH;
    int preview_x2 = combo_x2 + SETTING_MARKER_COMBOBOX_WIDTH + SETTING_MARKER_GAP;
    //int color_combo_x2   = base_x2 + SETTING_MARKER_COLOR_COMBO_WIDTH;
    
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
    // For shape of Marker in Row 0: Single Buy Column 1, Single Sell Column 2
      if(!CreateMarkerTabCaption(0, "Single Indicator Buy", base_x1, y)) return false;
      if(!CreateMarkerTabComboBox(m_combo_shape_single_indicator_buy, combo_x1, y, SETTING_MARKER_COMBOBOX_WIDTH, shape_labels, sel_single_buy)) return false;
      if(!CreateShapePreview(0, preview_x1, y, m_marker_single_indicator_buy_code)) return false;

      if(!CreateMarkerTabCaption(1, "Single Indicator Sell", base_x2, y)) return false;
      if(!CreateMarkerTabComboBox(m_combo_shape_single_indicator_sell, combo_x2, y, SETTING_MARKER_COMBOBOX_WIDTH, shape_labels, sel_single_sell)) return false;
      if(!CreateShapePreview(1, preview_x2, y, m_marker_single_indicator_sell_code)) return false;
    // For shape of Marker in Row 1
      if(!CreateMarkerTabCaption(2, "Multi Indicator Buy", base_x1, y + SETTING_MARKER_ROW_HEIGHT)) return false;
      if(!CreateMarkerTabComboBox(m_combo_shape_multi_indicator_buy, combo_x1, y + SETTING_MARKER_ROW_HEIGHT, SETTING_MARKER_COMBOBOX_WIDTH, shape_labels, sel_multi_buy)) return false;
      if(!CreateShapePreview(2, preview_x1, y + SETTING_MARKER_ROW_HEIGHT, m_marker_multi_indicator_buy_code)) return false;
      if(!CreateMarkerTabCaption(3, "Multi Indicator Sell", base_x2, y + SETTING_MARKER_ROW_HEIGHT)) return false;
      if(!CreateMarkerTabComboBox(m_combo_shape_multi_indicator_sell, combo_x2, y + SETTING_MARKER_ROW_HEIGHT, SETTING_MARKER_COMBOBOX_WIDTH, shape_labels, sel_multi_sell)) return false;
      if(!CreateShapePreview(3, preview_x2, y + SETTING_MARKER_ROW_HEIGHT, m_marker_multi_indicator_sell_code)) return false;
    // For shape of Marker in Row 2
      if(!CreateMarkerTabCaption(4, "Pattern Buy", base_x1, y + SETTING_MARKER_ROW_HEIGHT * 2)) return false;
      if(!CreateMarkerTabComboBox(m_combo_shape_pattern_buy, combo_x1, y + SETTING_MARKER_ROW_HEIGHT * 2, SETTING_MARKER_COMBOBOX_WIDTH, shape_labels, sel_pattern_buy)) return false;
      if(!CreateShapePreview(4, preview_x1, y + SETTING_MARKER_ROW_HEIGHT * 2, m_marker_pattern_buy_code)) return false;
      
      if(!CreateMarkerTabCaption(5, "Pattern Sell", base_x2, y + SETTING_MARKER_ROW_HEIGHT * 2)) return false;
      if(!CreateMarkerTabComboBox(m_combo_shape_pattern_sell, combo_x2, y + SETTING_MARKER_ROW_HEIGHT * 2, SETTING_MARKER_COMBOBOX_WIDTH, shape_labels, sel_pattern_sell)) return false;
      if(!CreateShapePreview(5, preview_x2, y + SETTING_MARKER_ROW_HEIGHT * 2, m_marker_pattern_sell_code)) return false;
    // For shape of Marker in Row 3
      if(!CreateMarkerTabCaption(6, "Combo Buy", base_x1, y + SETTING_MARKER_ROW_HEIGHT * 3)) return false;
      if(!CreateMarkerTabComboBox(m_combo_shape_combo_buy, combo_x1, y + SETTING_MARKER_ROW_HEIGHT * 3, SETTING_MARKER_COMBOBOX_WIDTH, shape_labels, sel_combo_buy)) return false;
      if(!CreateShapePreview(6, preview_x1, y + SETTING_MARKER_ROW_HEIGHT * 3, m_marker_combo_buy_code)) return false;
      
      if(!CreateMarkerTabCaption(7, "Combo Sell", base_x2, y + SETTING_MARKER_ROW_HEIGHT * 3)) return false;
      if(!CreateMarkerTabComboBox(m_combo_shape_combo_sell, combo_x2, y + SETTING_MARKER_ROW_HEIGHT * 3, SETTING_MARKER_COMBOBOX_WIDTH, shape_labels, sel_combo_sell)) return false;
      if(!CreateShapePreview(7, preview_x2, y + SETTING_MARKER_ROW_HEIGHT * 3, m_marker_combo_sell_code)) return false;
    //For color
      int n_colors = ArraySize(mcolors);
      int sel_buy = 0, sel_sell = 0, sel_nonrelated = 0;
      for(int i = 0; i < n_colors; i++)
      {
        if(mcolors[i] == m_marker_buy_color)        sel_buy        = i;
        if(mcolors[i] == m_marker_sell_color)       sel_sell       = i;
        if(mcolors[i] == m_marker_nonrelated_color) sel_nonrelated = i;
      }
    //Position Y
      int color_row0 = SETTING_MARKER_ROW_HEIGHT * 4 + 15;
      //int color_preview_x1 = combo_x1 + SETTING_MARKER_COLOR_COMBO_WIDTH + SETTING_MARKER_COLOR_PREVIEW_GAP;
      //int color_preview_x2 = combo_x2 + SETTING_MARKER_COLOR_COMBO_WIDTH + SETTING_MARKER_COLOR_PREVIEW_GAP;
    //Row 0 of Color: Buy Color Column 1, Sell Color column 2
      if(!CreateMarkerTabCaption(8, "Buy Color", base_x1, y + color_row0)) return false;
      if(!CreateMarkerTabComboBox(m_combo_color_buy, combo_x1, y + color_row0, SETTING_MARKER_COLOR_COMBO_WIDTH, color_labels, sel_buy)) return false;
      //Debug
      //  PrintFormat("Debug CGUIPannel::CreateTabSettingConfig_Marker combo_x1=%d, COLOR_COMBO_WIDTH=%d, GAP=%d, color_preview_x1=%d",
      //   combo_x1, SETTING_MARKER_COLOR_COMBO_WIDTH, SETTING_MARKER_GAP, color_preview_x1);
      
      int color_preview_x1 = combo_x1 + m_combo_color_buy.XSize() + SETTING_MARKER_COLOR_PREVIEW_GAP;
      if(!CreateColorPreview(0, color_preview_x1, y + color_row0, m_marker_buy_color)) return false;          
      //Col 2
      if(!CreateMarkerTabCaption(9, "Sell Color", base_x2, y + color_row0)) return false;
      //if(!CreateMarkerTabComboBox(m_combo_color_sell, color_combo_x2, y + color_row0, SETTING_MARKER_COLOR_COMBO_WIDTH, color_labels, sel_sell)) return false;
      if(!CreateMarkerTabComboBox(m_combo_color_sell, combo_x2, y + color_row0, SETTING_MARKER_COLOR_COMBO_WIDTH, color_labels, sel_sell)) return false;
      //Debug
      //  PrintFormat("Debug CGUIPannel::CreateTabSettingConfig_Marker color combo buy: x=%d, XSize=%d, canvasX=%d", combo_x1, m_combo_color_buy.XSize(), m_combo_color_buy.CanvasPointer().XSize());
      //  PrintFormat("Debug CGUIPannel::CreateTabSettingConfig_Marker color combo sell: x=%d, XSize=%d, canvasX=%d", combo_x2, m_combo_color_sell.XSize(), m_combo_color_sell.CanvasPointer().XSize());
      //  //PrintFormat("Debug CGUIPannel::CreateTabSettingConfig_Marker combo_x2=%d, COLOR_COMBO_WIDTH=%d, GAP=%d, color_preview_x2=%d",
        //combo_x2, SETTING_MARKER_COLOR_COMBO_WIDTH, SETTING_MARKER_GAP, color_preview_x2);
      int color_preview_x2 = combo_x2 + m_combo_color_sell.XSize() + SETTING_MARKER_COLOR_PREVIEW_GAP;
      if(!CreateColorPreview(1, color_preview_x2, y + color_row0, m_marker_sell_color)) return false;

      // Non-Related Color (Cột 1)
      if(!CreateMarkerTabCaption(10, "Non-Related Color", base_x1, y + color_row0 + SETTING_MARKER_ROW_HEIGHT)) return false;
      if(!CreateMarkerTabComboBox(m_combo_color_nonrelated, combo_x1, y + color_row0 + SETTING_MARKER_ROW_HEIGHT, SETTING_MARKER_COLOR_COMBO_WIDTH, color_labels, sel_nonrelated)) return false;
      // //Debug
      //  PrintFormat("Debug CGUIPannel::CreateTabSettingConfig_Marker combo_x2=%d, COLOR_COMBO_WIDTH=%d, GAP=%d, color_preview_x2=%d",
      //   combo_x2, SETTING_MARKER_COLOR_COMBO_WIDTH, SETTING_MARKER_GAP, color_preview_x2);
      if(!CreateColorPreview(2, color_preview_x1, y + color_row0 + SETTING_MARKER_ROW_HEIGHT, m_marker_nonrelated_color)) return false;
    //Sound folder
      int sound_row0 = color_row0 + SETTING_MARKER_ROW_HEIGHT * 2 + 10;
      //int sound_combo_w = preview_x2 + SETTING_MARKER_PREVIEW_WIDTH - combo_x1;
      if(!CreateMarkerTabCaption(11, "Sound Folder", base_x1, y + sound_row0)) return false;
    // Sound folder text edit
      //  m_edit_sound_folder.MainPointer(m_tabs_main_setting_config);
      //  m_tabs_main_setting_config.AddToElementsArray(TAB_TAB_MAIN_SETTINGS_CONFIG_MARKER, m_edit_sound_folder);
      //  m_edit_sound_folder.XSize(sound_combo_w);
      //  m_edit_sound_folder.GetTextBoxPointer().XGap(1);
      //  if(!m_edit_sound_folder.CreateTextEdit(m_marker_sound_folder, combo_x1, y + sound_row0)) return false;
    
    // Sound folder static label (read-only, shows where to drop .wav files)
      m_textLabel_sound_folder.MainPointer(m_tabs_main_setting_config);
      m_tabs_main_setting_config.AddToElementsArray(TAB_TAB_MAIN_SETTINGS_CONFIG_MARKER, m_textLabel_sound_folder);
      
      m_textLabel_sound_folder.XSize(SETTING_MARKER_LABEL_WIDTH_SOUND);   // leave room for Refresh button
      string lbl_text = "MQL5\\Files\\" + m_marker_sound_folder + "\\";
      
      if(!m_textLabel_sound_folder.CreateTextLabel(lbl_text, combo_x1, y + sound_row0)) return false;
      CWndContainer::AddToElementsArray(WindowIdx(m_window_main), m_textLabel_sound_folder);
    //For Button Refresh sound folder
      m_btn_refresh_sound_folder.MainPointer(m_tabs_main_setting_config);
      m_tabs_main_setting_config.AddToElementsArray(TAB_TAB_MAIN_SETTINGS_CONFIG_MARKER, m_btn_refresh_sound_folder);
      m_btn_refresh_sound_folder.AutoXResizeMode(false);
      m_btn_refresh_sound_folder.XSize(80);
      if(!m_btn_refresh_sound_folder.CreateButton("Refresh", combo_x1 + SETTING_MARKER_LABEL_WIDTH_SOUND + SETTING_MARKER_BASE_X_GAP, y + sound_row0)) return false;
      CWndContainer::AddToElementsArray(WindowIdx(m_window_main), m_btn_refresh_sound_folder);
    // --- Sound files scan
      string files[];
      ScanSoundFolder(files);
      int n_files = ArraySize(files);
      int sel_buy_sound = 0, sel_sell_sound = 0;
      for(int i = 0; i < n_files; i++)
      {
        if(files[i] == m_marker_buy_sound_file)  sel_buy_sound  = i;
        if(files[i] == m_marker_sell_sound_file) sel_sell_sound = i;
      }
    //Buy Sound column 1, Sell Sound Column 2
      if(!CreateMarkerTabCaption(12, "Buy Sound", base_x1, y + sound_row0 + SETTING_MARKER_ROW_HEIGHT)) return false;
      if(!CreateMarkerTabComboBox(m_combo_buy_sound, combo_x1, y + sound_row0 + SETTING_MARKER_ROW_HEIGHT, SETTING_MARKER_COMBOBOX_WIDTH, files, sel_buy_sound)) return false;
      if(!CreateMarkerTabCaption(13, "Sell Sound", base_x2, y + sound_row0 + SETTING_MARKER_ROW_HEIGHT)) return false;
      if(!CreateMarkerTabComboBox(m_combo_sell_sound, combo_x2, y + sound_row0 + SETTING_MARKER_ROW_HEIGHT, SETTING_MARKER_COMBOBOX_WIDTH, files, sel_sell_sound)) return false;

    //For Button Save marker settings
      m_btn_save_marker_settings.MainPointer(m_tabs_main_setting_config);
      m_tabs_main_setting_config.AddToElementsArray(TAB_TAB_MAIN_SETTINGS_CONFIG_MARKER, m_btn_save_marker_settings);
      m_btn_save_marker_settings.AutoXResizeMode(false);
      m_btn_save_marker_settings.XSize(80);
      m_btn_save_marker_settings.IconFile(IMAGE_RESOURCE_BMP16_SAVE_PNG);
      if(!m_btn_save_marker_settings.CreateButton("Save", base_x1, y + sound_row0 + SETTING_MARKER_ROW_HEIGHT * 3 + 10)) return false;
    CWndContainer::AddToElementsArray(WindowIdx(m_window_main), m_btn_save_marker_settings);

    return true;
  }
 // --- Shared recipe for every combobox on the Other tab (4 shape + 3 color) - same
 // --- creation/population steps as m_param_combo[]'s own recipe, just factored out since
 // --- 7 combos would otherwise repeat it verbatim.
 bool CGUIPannel::CreateMarkerTabComboBox(CComboBox &combo, const int x, const int y, const int combo_w, string &labels[], const int selected_index)
  {
    combo.MainPointer(m_tabs_main_setting_config);
    m_tabs_main_setting_config.AddToElementsArray(TAB_TAB_MAIN_SETTINGS_CONFIG_MARKER, combo);
    int n = ArraySize(labels);
    combo.XSize(combo_w);
    combo.YSize(SETTING_MARKER_ROW_HEIGHT);
    combo.ItemsTotal(n);
    // --- Default dropdown viewport is only 93px (~5 rows) - with 11-12 choices that forces
    // --- a cramped scrollbar drag to reach the rest (Anhnt, 2026-07-17: "scrollbar khó kéo,
    // --- chọn không được"). Size the list to show every item at once so no scrolling is
    // --- ever needed - must be set BEFORE CreateComboBox() (CreateList() reads it once).
    // --- Capped at 300px (Anhnt, 2026-07-17: a real Sounds folder can have 30-40+ files -
    // --- letting the list grow to 18*n+4 uncapped ran the dropdown off the bottom of the
    // --- screen, making everything past the visible part unreachable). Small catalogs
    // --- (shape/color, 11-12 items = up to ~220px) still fit under the cap with no scrolling.
    int list_h = 18 * n + 4;
    if(list_h > 300) list_h = 300;
    combo.GetListViewPointer().YSize(list_h);
    combo.GetButtonPointer().XGap(1);
    combo.GetButtonPointer().XSize(combo_w);
    combo.GetButtonPointer().LabelYGap(4);
    combo.GetButtonPointer().IconYGap(3);
    if(!combo.CreateComboBox("", x, y)) return false;
    CWndContainer::AddToElementsArray(WindowIdx(m_window_main), combo);

    combo.GetListViewPointer().Rebuilding(n);
    for(int i = 0; i < n; i++)
      combo.SetValue(i, labels[i]);
      combo.SelectItem(selected_index);
      combo.GetListViewPointer().Update(true);
    return true;
  }
 // --- Caption to the LEFT of a combo, e.g. "Single Buy:" - m_label_other_caption[row].
 bool CGUIPannel::CreateMarkerTabCaption(const int row, const string text, const int x, const int y)
  {
    m_label_other_caption[row].MainPointer(m_tabs_main_setting_config);
    m_tabs_main_setting_config.AddToElementsArray(TAB_TAB_MAIN_SETTINGS_CONFIG_MARKER, m_label_other_caption[row]);
    m_label_other_caption[row].XSize(SETTING_MARKER_CAPTION_WIDTH);
    if(!m_label_other_caption[row].CreateTextLabel(text, x, y)) return false;
    CWndContainer::AddToElementsArray(WindowIdx(m_window_main), m_label_other_caption[row]);
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
    CWndContainer::AddToElementsArray(WindowIdx(m_window_main), m_preview_shape[row]);
    return true;
  }
 // --- Preview to the RIGHT of a color combo - reuses CColorButton's own swatch rendering
 // --- (CurrentColor() builds a small bordered color icon) purely for DISPLAY - never wired
 // --- to a click handler, so clicking it does nothing (no picker to open, see BugNote
 // --- 2026-07-17: CColorPicker dropped in favor of these fixed-palette combos).
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
    CWndContainer::AddToElementsArray(WindowIdx(m_window_main), m_preview_color[row]);
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
 // --- Loads the "markers" section of Config_Setting.json - the SAME single file
 // --- CTimeSeriesEngine::SaveConfigurationToJSON/LoadConfigurationFromJSON already use for
 // --- "symbols_tf"/"templates" (Anhnt, 2026-07-17: one file for everything, not scattered
 // --- across separate files). Always sets sane defaults first so a missing/partial file
 // --- (or a file that simply has no "markers" key yet) still leaves the EA in a working state.
 void CGUIPannel::LoadMarkerSettings(void)
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
   //For sound
    m_marker_buy_sound_file   = "";
    m_marker_sell_sound_file  = "";
    m_marker_sound_folder     = "Sounds";
   //For Config_Setting.json
    string content = IndicatorConfig_ReadWholeFile("Config_Setting.json");
    if(content == "") return;
    int v;
    if(JsonIntValue(content, "single_indicator_buy_arrow_code",  v)) m_marker_single_indicator_buy_code  = v;
    if(JsonIntValue(content, "single_indicator_sell_arrow_code", v)) m_marker_single_indicator_sell_code = v;
    if(JsonIntValue(content, "multi_indicator_buy_arrow_code",   v)) m_marker_multi_indicator_buy_code   = v;
    if(JsonIntValue(content, "multi_indicator_sell_arrow_code",  v)) m_marker_multi_indicator_sell_code  = v;
    if(JsonIntValue(content, "pattern_buy_arrow_code",  v)) m_marker_pattern_buy_code   = v;
    if(JsonIntValue(content, "pattern_sell_arrow_code", v)) m_marker_pattern_sell_code  = v;
    if(JsonIntValue(content, "combo_buy_arrow_code",    v)) m_marker_combo_buy_code    = v;
    if(JsonIntValue(content, "combo_sell_arrow_code",   v)) m_marker_combo_sell_code   = v;
    if(JsonIntValue(content, "buy_color",        v)) m_marker_buy_color        = (color)v;
    if(JsonIntValue(content, "sell_color",       v)) m_marker_sell_color       = (color)v;
    if(JsonIntValue(content, "nonrelated_color", v)) m_marker_nonrelated_color = (color)v;
    string sv;
    if(JsonStringValue(content, "buy_sound_file",  sv)) m_marker_buy_sound_file  = sv;
    if(JsonStringValue(content, "sell_sound_file", sv)) m_marker_sell_sound_file = sv;
    if(JsonStringValue(content, "sound_folder",    sv)) m_marker_sound_folder    = sv;
  }
 // --- Fixed catalog of common Wingdings arrow codes offered in all 4 marker-shape combos.
 // --- 67/68 (Thumb Up/Down) restore the original OBJ_ARROW_THUMB_UP/DOWN look this popup
 // --- used before the DRAW_COLOR_ARROW redesign (Anhnt, 2026-07-17) - those were native
 // --- chart OBJECT types back then; now they're just Wingdings glyph codes like any other
 // --- shape choice here, rendered via the indicator's PLOT_ARROW, not a chart object.
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
 void CGUIPannel::ScanSoundFolder(string &files[])
  {
   ::ArrayResize(files, 0);
   string folder = m_marker_sound_folder;
   if(folder == "") folder = "Sounds";
   string search_path = folder + "\\*.*";
   string name;
   long h = ::FileFindFirst(search_path, name);
   if(h == INVALID_HANDLE) return;
   do
    {
      // --- MQL5's FileFindFirst/Next marks folders with a TRAILING BACKSLASH in the
      // --- returned name (same convention CFileNavigator::IsFolder relies on) - skip those,
      // --- keep only actual files.
      if(::StringFind(name, "\\") < 0)
       {
        int n = ::ArraySize(files);
        ::ArrayResize(files, n + 1);
        files[n] = name;
       }
    }
    while(::FileFindNext(h, name));
    ::FileFindClose(h);
  }
#endif // CGUIPANNEL_TABSETTINGMARKER_MQH