//+------------------------------------------------------------------+
//|                       GUIPannel_SettingWindows_CandlePattern.mqh |
//| The Module for CandlePattern Setting                             |
//+------------------------------------------------------------------+
#ifndef CGUIPANNEL_SETTINGWINDOWS_CANDLE_PATTERN_MQH
#define CGUIPANNEL_SETTINGWINDOWS_CANDLE_PATTERN_MQH
 #define SETTING_BTN_SAVE_CANDLE_PATTERN_X_GAP 10
 #define SETTING_BTN_SAVE_CANDLE_PATTERN_Y_GAP 20 
 #include "GUIPannel.mqh"
 //--- Extract bool value (true/false literal) from JSON key - only this file needs it
 //--- (Pattern_Alerts_Setting's per-pattern buy/sell/sound/message flags), so it lives
 //--- here rather than in the shared JSONConfig.mqh.
 bool JSONConfig_CandlePattern_BoolValue(const string content, const string key, bool &value)
  {
   int pos = StringFind(content, "\"" + key + "\"");
   if(pos < 0) return false;
    int colon = StringFind(content, ":", pos);
    if(colon < 0) return false;
    int len = StringLen(content);
    int i = colon + 1;
    while(i < len && StringGetCharacter(content, i) == ' ') i++;
    if(StringSubstr(content, i, 4) == "true")
     {
      value = true;
      return true;
     }
    if(StringSubstr(content, i, 5) == "false")
     {
      value = false;
      return true;
     }
    return false;
  }
 //+----------------------------------------------------------------------------+
 //| Loads the "Pattern_Alerts_Setting" section of Config_Setting.json into    |
 //| m_pattern_signal_buy/sell/alert_sound/message[] - data-only, does NOT     |
 //| touch the Table. Must run AFTER BuildCandlePatternListFromRegistry() (so  |
 //| the arrays are sized) and BEFORE InitializeTable_CandlePatternSetting()   |
 //| (which paints the Table from these same arrays).                         |
 //+----------------------------------------------------------------------------+
 void CGUIPannel::LoadCandlePatternSetting_FromJSON(void)
  {
    string full_path = g_ea_folder + "/Config_Setting.json";
    string content = JSONConfig_ReadWholeFile(full_path);
    if(content == "") return;
    string pattern_alerts_section = JSONConfig_ExtractRawSection(content, "Pattern_Alerts_Setting");
    if(pattern_alerts_section == "") return;
    int pattern_count = ArraySize(m_pattern_types);
    for(int i = 0; i < pattern_count; i++)
     {
      string pattern_name = m_pattern_display_names[i];
      int pos = StringFind(pattern_alerts_section, "\"" + pattern_name + "\"");
      if(pos < 0) continue;
      int brace = StringFind(pattern_alerts_section, "{", pos);
      if(brace < 0) continue;
      int close_brace = StringFind(pattern_alerts_section, "}", brace);
      if(close_brace < 0) continue;
      string pattern_obj = StringSubstr(pattern_alerts_section, brace, close_brace - brace + 1);
      bool v;
      if(::JSONConfig_CandlePattern_BoolValue(pattern_obj, "m_pattern_signal_buy",   v)) m_pattern_signal_buy[i]    = v;
      if(::JSONConfig_CandlePattern_BoolValue(pattern_obj, "m_pattern_signal_sell",  v)) m_pattern_signal_sell[i]   = v;
      if(::JSONConfig_CandlePattern_BoolValue(pattern_obj, "m_pattern_alert_sound",  v)) m_pattern_alert_sound[i]   = v;
      if(::JSONConfig_CandlePattern_BoolValue(pattern_obj, "m_pattern_alert_message",v)) m_pattern_alert_message[i] = v;
     }
  } 
  //+------------------------------------------------------------------+
 //| Writes the "Pattern_Alerts_Setting" section of Config_Setting.    |
 //| json straight from m_pattern_*[] (Single Source of Truth) -       |
 //| preserves the 4 sections owned elsewhere (Symbols_TFs_List,       |
 //| Indicator_Templates, Markers_Setting, Sound_Settings).            |
 //+------------------------------------------------------------------+
 void CGUIPannel::SaveCandlePatternSettingToJSON(void)
  {
   string full_path = g_ea_folder + "/Config_Setting.json";
   string existing       = JSONConfig_ReadWholeFile(full_path);
   string symbols_tf     = JSONConfig_ExtractRawSection(existing, "Symbols_TFs_List");
   string templates      = JSONConfig_ExtractRawSection(existing, "Indicator_Templates");
   string markers        = JSONConfig_ExtractRawSection(existing, "Markers_Setting");
   string sound_settings = JSONConfig_ExtractRawSection(existing, "Sound_Settings");

   string json = "{\n";
   if(symbols_tf     != "") json += " \"Symbols_TFs_List\": "  + symbols_tf     + ",\n";
   if(templates      != "") json += " \"Indicator_Templates\": " + templates    + ",\n";
   if(markers        != "") json += " \"Markers_Setting\": "   + markers        + ",\n";
   if(sound_settings != "") json += " \"Sound_Settings\": "    + sound_settings + ",\n";

   int pattern_count = ArraySize(m_pattern_types);
   json += " \"Pattern_Alerts_Setting\": {\n";
   for(int i = 0; i < pattern_count; i++)
    {
     if(i > 0) json += ",\n";
     json += "  \"" + m_pattern_display_names[i] + "\": { \"m_pattern_signal_buy\": " + (m_pattern_signal_buy[i] ? "true" : "false") +
             ", \"m_pattern_signal_sell\": " + (m_pattern_signal_sell[i] ? "true" : "false") +
             ", \"m_pattern_alert_sound\": " + (m_pattern_alert_sound[i] ? "true" : "false") +
             ", \"m_pattern_alert_message\": " + (m_pattern_alert_message[i] ? "true" : "false") + " }";
    }
   json += "\n }\n}";

   int fh = ::FileOpen(full_path, FILE_TXT | FILE_WRITE | FILE_ANSI);
   if(fh == INVALID_HANDLE)
    {
     ::Print(__FUNCTION__, " > cannot open ", full_path, " for writing, err=", ::GetLastError());
     return;
    }
   ::FileWriteString(fh, json);
   ::FileClose(fh);
   ::Print(__FUNCTION__, " > saved ", pattern_count, " pattern alert setting(s) to ", full_path);
  }
 void CGUIPannel::BuildCandlePatternListFromRegistry(void)
  {
    ArrayFree(m_pattern_types);
    ArrayFree(m_pattern_display_names);
    ArrayFree(m_pattern_signal_buy);
    ArrayFree(m_pattern_signal_sell);
    ArrayFree(m_pattern_alert_sound);
    ArrayFree(m_pattern_alert_message);
    // Hardcode all 28 patterns from Layer 1 RegisterAllCandlePatterns
    ENUM_PATTERN_TYPE all_patterns[28] = {
      PATTERN_TYPE_HAMMER, PATTERN_TYPE_HANGING_MAN, PATTERN_TYPE_INVERTED_HAMMER, PATTERN_TYPE_SHOOTING_STAR,
      PATTERN_TYPE_DOJI, PATTERN_TYPE_DRAGONFLY_DOJI, PATTERN_TYPE_GRAVESTONE_DOJI, PATTERN_TYPE_HARAMI,
      PATTERN_TYPE_HARAMI_CROSS, PATTERN_TYPE_ENGULFING, PATTERN_TYPE_TWEEZER, PATTERN_TYPE_PIERCING_LINE,
      PATTERN_TYPE_DARK_CLOUD_COVER, PATTERN_TYPE_RAILS, PATTERN_TYPE_MORNING_STAR, PATTERN_TYPE_MORNING_DOJI_STAR,
      PATTERN_TYPE_EVENING_STAR, PATTERN_TYPE_EVENING_DOJI_STAR, PATTERN_TYPE_THREE_WHITE_SOLDIERS, PATTERN_TYPE_THREE_BLACK_CROWS,
      PATTERN_TYPE_THREE_STARS, PATTERN_TYPE_THREE_INSIDE_UP, PATTERN_TYPE_THREE_INSIDE_DOWN, PATTERN_TYPE_ABANDONED_BABY,
      PATTERN_TYPE_PIVOT_POINT_REVERSAL, PATTERN_TYPE_OUTSIDE_BAR, PATTERN_TYPE_INSIDE_BAR, PATTERN_TYPE_PIN_BAR
    };
    ArrayResize(m_pattern_types, 28);
    ArrayResize(m_pattern_display_names, 28);
    ArrayResize(m_pattern_signal_buy, 28);
    ArrayResize(m_pattern_signal_sell, 28);
    ArrayResize(m_pattern_alert_sound, 28);
    ArrayResize(m_pattern_alert_message, 28);
    for(int i = 0; i < 28; i++)
     {
        m_pattern_types[i] = all_patterns[i];
        m_pattern_display_names[i] = EnumToString(all_patterns[i]);
        m_pattern_signal_buy[i]    = true;   // opt-in mặc định, giống CSymbolTFSetting
        m_pattern_signal_sell[i]   = true;
        m_pattern_alert_sound[i]   = true;
        m_pattern_alert_message[i] = true;
     }
  }
 //+------------------------------------------------------------------+
 //| Create Save button + m_table_CandlePatternsSetting (Settings tab, | 
 //+------------------------------------------------------------------+
 bool CGUIPannel::CreateTable_CandlePatternSetting(const int x, const int y)
  {
   // Step 1: Create Save Button ABOVE the table
    m_btn_save_pattern_config.MainPointer(m_tabs_main_setting_config);
    m_tabs_main_setting_config.AddToElementsArray(TAB_TAB_MAIN_SETTINGS_CONFIG_CANDLE_PATTERN, m_btn_save_pattern_config);
    m_btn_save_pattern_config.AutoXResizeMode(false);
    m_btn_save_pattern_config.XSize(80);
    m_btn_save_pattern_config.YSize(BTN_HEIGHT);
    m_btn_save_pattern_config.IconFile(IMAGE_RESOURCE_BMP16_SAVE_PNG);
    if(!m_btn_save_pattern_config.CreateButton("Save", x+SETTING_BTN_SAVE_CANDLE_PATTERN_X_GAP, y+SETTING_BTN_SAVE_CANDLE_PATTERN_Y_GAP)) return false;
    CWndContainer::AddToElementsArray(WindowIdx(m_window_setting), m_btn_save_pattern_config);

   // Step 2: Create Table BELOW button
    int table_y = y + SETTING_BTN_SAVE_CANDLE_PATTERN_Y_GAP + BTN_HEIGHT + SETTING_BTN_SAVE_CANDLE_PATTERN_Y_GAP;
    m_table_CandlePatternsSetting.MainPointer(m_tabs_main_setting_config);
    m_tabs_main_setting_config.AddToElementsArray(TAB_TAB_MAIN_SETTINGS_CONFIG_CANDLE_PATTERN, m_table_CandlePatternsSetting);
    m_table_CandlePatternsSetting.AutoXResizeMode(true);
    m_table_CandlePatternsSetting.AutoXResizeRightOffset(3);
    m_table_CandlePatternsSetting.AutoYResizeMode(true);
    m_table_CandlePatternsSetting.AutoYResizeBottomOffset(3);
    m_table_CandlePatternsSetting.LightsHover(true);
    m_table_CandlePatternsSetting.ShowHeaders(true);
    m_table_CandlePatternsSetting.SelectableRow(true);
    m_table_CandlePatternsSetting.IsSortMode(true);
    m_table_CandlePatternsSetting.TableSize(8, ArraySize(m_pattern_types));
    int widths[8]    = {155, 30, 30, 30, 20, 30, 30, 20};
    int img_x_off[8] = {0, 0, 10, 10, 7, 7, 7, 7};
    int img_y_off[8] = {0, 0, 3, 3, 3, 4, 4, 3};
    ENUM_ALIGN_MODE align[8] = {ALIGN_LEFT,ALIGN_CENTER,ALIGN_LEFT,ALIGN_LEFT,ALIGN_LEFT,ALIGN_LEFT,ALIGN_LEFT,ALIGN_LEFT};
    m_table_CandlePatternsSetting.ColumnsWidth(widths);
    m_table_CandlePatternsSetting.ImageXOffset(img_x_off);
    m_table_CandlePatternsSetting.ImageYOffset(img_y_off);
    m_table_CandlePatternsSetting.TextAlign(align);
   // ← Create BEFORE SetHeaderText
    if(!m_table_CandlePatternsSetting.CreateTable(x, table_y)) return false;
    m_table_CandlePatternsSetting.SetHeaderText(0, "Pattern");
    m_table_CandlePatternsSetting.SetHeaderText(1, "No");
    // Buy signal
     uint resource_indices_buy[] = {IMAGE_RESOURCE_BMP16_BUY_PNG};
     m_table_CandlePatternsSetting.SetHeaderText(2, "");
     m_table_CandlePatternsSetting.SetHeaderImage(2, resource_indices_buy);
    // Sell signal
     uint resource_indices_sell[] = {IMAGE_RESOURCE_BMP16_SELL_PNG};
     m_table_CandlePatternsSetting.SetHeaderText(3, "");
     m_table_CandlePatternsSetting.SetHeaderImage(3, resource_indices_sell);
    // ▲ static direction legend (no header image)
     m_table_CandlePatternsSetting.SetHeaderText(4, "");
    // Sound
     uint resource_indices_sound[] = {IMAGE_RESOURCE_BMP16_BELL_PNG};
     m_table_CandlePatternsSetting.SetHeaderText(5, "");
     m_table_CandlePatternsSetting.SetHeaderImage(5, resource_indices_sound);
    // Message
     uint resource_indices_message[] = {IMAGE_RESOURCE_BMP16_MESSAGE_PNG};
     m_table_CandlePatternsSetting.SetHeaderText(6, "");
     m_table_CandlePatternsSetting.SetHeaderImage(6, resource_indices_message);
     m_table_CandlePatternsSetting.SetHeaderText(7, "");   // ▼ static direction legend
    CWndContainer::AddToElementsArray(WindowIdx(m_window_setting), m_table_CandlePatternsSetting);
    return true;
  }
 //+------------------------------------------------------------------+
 //| Data-only paint pass - grows/repaints every row from m_pattern_*[] |
 //+------------------------------------------------------------------+
 void CGUIPannel::InitializeTable_CandlePatternSetting(void)
  {
   int n = ArraySize(m_pattern_types);
   if(n == 0) return;
   m_table_CandlePatternsSetting.DeleteAllRows();
   for(int i = 0; i < n - 1; i++)
     m_table_CandlePatternsSetting.AddRow(i);

   uint arrow_up[]  = {IMAGE_RESOURCE_BMP16_ARROW_UP_PNG};
   uint arrow_dn[]  = {IMAGE_RESOURCE_BMP16_ARROW_DOWN_PNG};
   uint chk[]       = {IMAGE_RESOURCE_BMP16_CHECKBOX_ON_G_PNG,
                    IMAGE_RESOURCE_BMP16_CHECKBOX_OFF_BMP};
   for(int i = 0; i < n; i++)
    {
      m_table_CandlePatternsSetting.SetValue(0, i, m_pattern_display_names[i]);
      m_table_CandlePatternsSetting.SetValue(1, i, string(CandlesForPatternType(m_pattern_types[i])));// "1", "2", "3"

      m_table_CandlePatternsSetting.CellType(2, i, CELL_CHECKBOX);
      m_table_CandlePatternsSetting.SetImages(2, i, chk);
      m_table_CandlePatternsSetting.ChangeImage(2, i, m_pattern_signal_buy[i] ? CHECKBOX_STATE_ON : CHECKBOX_STATE_OFF);

      m_table_CandlePatternsSetting.CellType(3, i, CELL_CHECKBOX);
      m_table_CandlePatternsSetting.SetImages(3, i, chk);
      m_table_CandlePatternsSetting.ChangeImage(3, i, m_pattern_signal_sell[i] ? CHECKBOX_STATE_ON : CHECKBOX_STATE_OFF);

      m_table_CandlePatternsSetting.CellType(4, i, CELL_BUTTON);
      m_table_CandlePatternsSetting.SetImages(4, i, arrow_up);   // ▲ static green

      m_table_CandlePatternsSetting.CellType(5, i, CELL_CHECKBOX);
      m_table_CandlePatternsSetting.SetImages(5, i, chk);
      m_table_CandlePatternsSetting.ChangeImage(5, i, m_pattern_alert_sound[i] ? CHECKBOX_STATE_ON : CHECKBOX_STATE_OFF);

      m_table_CandlePatternsSetting.CellType(6, i, CELL_CHECKBOX);
      m_table_CandlePatternsSetting.SetImages(6, i, chk);
      m_table_CandlePatternsSetting.ChangeImage(6, i, m_pattern_alert_message[i] ? CHECKBOX_STATE_ON : CHECKBOX_STATE_OFF);

      m_table_CandlePatternsSetting.CellType(7, i, CELL_BUTTON);
      m_table_CandlePatternsSetting.SetImages(7, i, arrow_dn);
    }
   // NOTE: live-tracking seed (m_candle_pattern_last_seen) deliberately omitted here -
   // that field is still commented out in GUIPannel.mqh (Sound/Message alert live-wiring
   // not done yet, see GUIPannel_SoundAndMessageAlerts.mqh) - revisit together when that's wired.
  }
 //+------------------------------------------------------------------+
 //| Row -> array index lookup by content (col 0 = Pattern display    |
 //| name) - same reasoning as SymbolTF's FindTableRowBySymbolTF:      |
 //| IsSortMode(true) means row position drifts from array index      |
 //| after a header-click sort, so raw row can't be used as the array |
 //| index directly.                                                   |
 //+------------------------------------------------------------------+
 int CGUIPannel::FindPatternIndexByRow(const int row)
  {
   string name = m_table_CandlePatternsSetting.GetValue(0, row);
   int n = ArraySize(m_pattern_display_names);
   for(int i = 0; i < n; i++)
     if(m_pattern_display_names[i] == name) return i;
   return -1;
  }
 //+------------------------------------------------------------------+
 //| Checkbox toggle handler for m_table_CandlePatternsSetting - col   |
 //| 2=Buy, 3=Sell, 5=Sound, 6=Message. Commits straight into the      |
 //| backing arrays (Single Source of Truth), Table cell already      |
 //| shows the new state via CTable's own checkbox toggle.             |
 //+------------------------------------------------------------------+
 void CGUIPannel::OnCheckTableCandlePatternSetting(const int row, const int col)
  {
   int idx = FindPatternIndexByRow(row);
   if(idx < 0) return;
   if(col == 2)
    {
     m_pattern_signal_buy[idx] = ((int)m_table_CandlePatternsSetting.SelectedImageIndex(2, row) == CHECKBOX_STATE_ON);
     // --- No Manager owns Candle Pattern Buy/Sell (fixed 28-pattern catalog, plain arrays here) -
     // --- CGUIPannel fires this itself so EA can push a fresh snapshot into CSignalBridgeWriter
     // --- (EA-owned) right away, same "push on real change" convention every Manager already
     // --- follows for its own data (Anhnt, 2026-08-26).
     ::EventChartCustom(::ChartID(), (ushort)GUIPANNEL_EVENT_PATTERN_SIGNAL_CHANGED, 0, 0.0, "");
    }
   else if(col == 3)
    {
     m_pattern_signal_sell[idx] = ((int)m_table_CandlePatternsSetting.SelectedImageIndex(3, row) == CHECKBOX_STATE_ON);
     ::EventChartCustom(::ChartID(), (ushort)GUIPANNEL_EVENT_PATTERN_SIGNAL_CHANGED, 0, 0.0, "");
    }
   else if(col == 5)
     m_pattern_alert_sound[idx]   = ((int)m_table_CandlePatternsSetting.SelectedImageIndex(5, row) == CHECKBOX_STATE_ON);
   else if(col == 6)
     m_pattern_alert_message[idx] = ((int)m_table_CandlePatternsSetting.SelectedImageIndex(6, row) == CHECKBOX_STATE_ON);
  }
 
 bool CGUIPannel::PatternSignalBuy(const ENUM_PATTERN_TYPE type) const
  {
   int n = ArraySize(m_pattern_types);
   for(int i = 0; i < n; i++)
    if(m_pattern_types[i] == type) return m_pattern_signal_buy[i];
   return false;
  }
 bool CGUIPannel::PatternSignalSell(const ENUM_PATTERN_TYPE type) const
  {
   int n = ArraySize(m_pattern_types);
   for(int i = 0; i < n; i++)
    if(m_pattern_types[i] == type) return m_pattern_signal_sell[i];
   return false;
  }
 void CGUIPannel::GetPatternSignalArrays(ENUM_PATTERN_TYPE &types[], bool &buy[], bool &sell[]) const
  {
   ArrayCopy(types, m_pattern_types);
   ArrayCopy(buy,   m_pattern_signal_buy);
   ArrayCopy(sell,  m_pattern_signal_sell);
  }
#endif // CGUIPANNEL_SETTINGWINDOWS_CANDLE_PATTERN_MQH

