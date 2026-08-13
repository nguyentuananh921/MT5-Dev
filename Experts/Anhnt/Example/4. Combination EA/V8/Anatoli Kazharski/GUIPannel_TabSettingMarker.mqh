//+------------------------------------------------------------------+
//|                                   GUIPannel_TabSettingMarker.mqh |
//+------------------------------------------------------------------+

//Bug Note: Sound in folder C:\Program Files\MetaTrader 5\Sounds
#ifndef CGUIPANNEL_TABSETTINGMARKER_MQH
#define CGUIPANNEL_TABSETTINGMARKER_MQH 
 #include "GUIPannel.mqh" 
 //Tab Marker TAB_TAB_MAIN_SETTINGS_CONFIG_MARKER of Tab m_tabs_main_setting_config
 // --- "Marker" sub-tab (TAB_TAB_MAIN_SETTINGS_CONFIG_MARKER): 8 independent shape choices
 // --- (Single Buy/Sell, Multi Buy/Sell - each needs its OWN plot/shape, see
 // --- SignalMarkers.mq5's header comment) and 3 independent color choices (Buy/Sell when a
 // --- marker relates to this chart's own Symbol+TF, Non-Related otherwise) - shape and
 // --- color are orthogonal axes (Anhnt, 2026-07-17).
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
    #define SETTING_MARKER_SOUND_WIDTH 250 //Combobox Sound file    
    
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
    // For Sound folder at Row 7      
      if(!CreateMarkerTabCaption(11, "Sound Folder", x + SETTING_MARKER_BASE_X_GAP, 
                                 y + SETTING_MARKER_ROW_HEIGHT * 6 + SETTING_MARKER_ROW_GAP*6)) return false;
     // Sound folder static label (read-only, shows where to drop .wav files)
      m_textLabel_sound_folder.MainPointer(m_tabs_main_setting_config);
      m_tabs_main_setting_config.AddToElementsArray(TAB_TAB_MAIN_SETTINGS_CONFIG_MARKER, m_textLabel_sound_folder);      
      m_textLabel_sound_folder.XSize(SETTING_MARKER_COMBOBOX_WIDTH);   // leave room for Refresh button
      //string lbl_text = "MQL5\\Files\\" + m_marker_sound_folder + "\\";
      string lbl_text = ::TerminalInfoString(TERMINAL_PATH) + "\\Sounds\\";      
      if(!m_textLabel_sound_folder.CreateTextLabel(lbl_text, x + SETTING_MARKER_BASE_X_GAP+SETTING_MARKER_CAPTION_WIDTH, 
                                y + SETTING_MARKER_ROW_HEIGHT * 6 + SETTING_MARKER_ROW_GAP*6)) return false;
      CWndContainer::AddToElementsArray(WindowIdx(m_window_main), m_textLabel_sound_folder);
     //For Button Refresh sound folder
      m_btn_refresh_sound_folder.MainPointer(m_tabs_main_setting_config);
      m_tabs_main_setting_config.AddToElementsArray(TAB_TAB_MAIN_SETTINGS_CONFIG_MARKER, m_btn_refresh_sound_folder);
      m_btn_refresh_sound_folder.AutoXResizeMode(false);
      m_btn_refresh_sound_folder.XSize(80);
      if(!m_btn_refresh_sound_folder.CreateButton("Refresh", x + SETTING_MARKER_BASE_X_GAP + SETTING_MARKER_SOUND_WIDTH + SETTING_MARKER_GAP, 
                                                  y + SETTING_MARKER_ROW_HEIGHT * 6 + SETTING_MARKER_ROW_GAP*6)) return false;
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
    //Sound Row 8 + 9
      if(!CreateMarkerTabCaption(12, "Buy Sound", x + SETTING_MARKER_BASE_X_GAP, 
                                  y + SETTING_MARKER_ROW_HEIGHT * 7 + SETTING_MARKER_ROW_GAP*7)) return false;
      if(!CreateMarkerTabComboBox(m_combo_buy_sound, x + SETTING_MARKER_BASE_X_GAP + SETTING_MARKER_CAPTION_WIDTH, 
                                  y + SETTING_MARKER_ROW_HEIGHT * 7 + SETTING_MARKER_ROW_GAP*7, SETTING_MARKER_SOUND_WIDTH, files, sel_buy_sound)) return false;
      if(!CreateMarkerTabCaption(13, "Sell Sound", x + SETTING_MARKER_BASE_X_GAP, 
                                  y + SETTING_MARKER_ROW_HEIGHT * 8 + SETTING_MARKER_ROW_GAP*8)) return false;
      if(!CreateMarkerTabComboBox(m_combo_sell_sound, x + SETTING_MARKER_BASE_X_GAP + SETTING_MARKER_CAPTION_WIDTH, 
                                  y + SETTING_MARKER_ROW_HEIGHT * 8 + SETTING_MARKER_ROW_GAP*8, SETTING_MARKER_SOUND_WIDTH, files, sel_sell_sound)) return false;
    //For Button Save marker settings
      m_btn_save_marker_settings.MainPointer(m_tabs_main_setting_config);
      m_tabs_main_setting_config.AddToElementsArray(TAB_TAB_MAIN_SETTINGS_CONFIG_MARKER, m_btn_save_marker_settings);
      m_btn_save_marker_settings.AutoXResizeMode(false);
      m_btn_save_marker_settings.XSize(80);
      m_btn_save_marker_settings.IconFile(IMAGE_RESOURCE_BMP16_SAVE_PNG);
      if(!m_btn_save_marker_settings.CreateButton("Save", x + SETTING_MARKER_BASE_X_GAP, 
                                 y + SETTING_MARKER_ROW_HEIGHT * 9 + SETTING_MARKER_ROW_GAP*9)) return false;
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
 //Note: Must Scand the Default folder that can play the sound
 void CGUIPannel::ScanSoundFolder(string &files[])
  {
   ::ArrayResize(files, 0);
  //  string folder = m_marker_sound_folder;
  //  if(folder == "") folder = "Sounds";
   //string search_path = folder + "\\*.*";
   string search_path = ::TerminalInfoString(TERMINAL_PATH) + "\\Sounds\\";
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
 // --- "Refresh" button next to the sound-folder path: read the CURRENT text box value (the
 // --- user may have just typed a new folder), re-scan it, and rebuild both combos in place.
 void CGUIPannel::OnClickChangeSoundFolder(void)
  {
    string files[];
    ScanSoundFolder(files);
    int n_files = ArraySize(files);

    // --- Rebuilding() only replaces the ITEM CONTENT - it does NOT resize the dropdown's own
    // --- viewport (that's a one-time YSize() read at CreateComboBox() time, same trap as
    // --- CreateMarkerTabComboBox's own comment) - without redoing it here, a folder that grows
    // --- from a handful of files to 61 keeps the OLD tiny viewport, squeezing the scrollbar
    // --- thumb down to almost nothing (Anhnt, 2026-07-17: exactly this happened on Refresh).
    int list_h = 18 * n_files + 4;
    if(list_h > 300) list_h = 300;
    m_combo_buy_sound.GetListViewPointer().YSize(list_h);
    m_combo_sell_sound.GetListViewPointer().YSize(list_h);

    m_combo_buy_sound.GetListViewPointer().Rebuilding(n_files);
    m_combo_sell_sound.GetListViewPointer().Rebuilding(n_files);
    for(int i = 0; i < n_files; i++)
      {
        m_combo_buy_sound.SetValue(i, files[i]);
        m_combo_sell_sound.SetValue(i, files[i]);
      }
    m_combo_buy_sound.SelectItem(0);
    m_combo_sell_sound.SelectItem(0);
    m_combo_buy_sound.GetListViewPointer().Update(true);
    m_combo_sell_sound.GetListViewPointer().Update(true);
  }
#endif // CGUIPANNEL_TABSETTINGMARKER_MQH