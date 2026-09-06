//+------------------------------------------------------------------+
//|                    GUIPannel_SettingWindows_TS_CandlePattern.mqh |
//| The library for the signal markers on chart                      |
//+------------------------------------------------------------------+
#ifndef CGUIPANNEL_SETTINGWINDOWS_TS_CANDLE_PATTERN_MQH
#define CGUIPANNEL_SETTINGWINDOWS_TS_CANDLE_PATTERN_MQH
 #define SETTING_BTN_SAVE_CANDLE_PATTERN_X_GAP 10
 #define SETTING_BTN_SAVE_CANDLE_PATTERN_Y_GAP 20
 #include "GUIPannel.mqh" 
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
 void CGUIPannel::LoadCandlePatternSetting_FromJSON(void)
  {
    if(m_BarPatterns_Control == NULL) return;
    string full_path = g_ea_folder + "/Config_Setting.json";
    string content = JSONConfig_ReadWholeFile(full_path);
    if(content == "") return;
    string pattern_alerts_section = JSONConfig_ExtractRawSection(content, "Pattern_Alerts_Setting");
    if(pattern_alerts_section == "") return;
    CArrayObj *controls = m_BarPatterns_Control.GetListControls();
    int pattern_count = (controls != NULL) ? controls.Total() : 0;
    for(int i = 0; i < pattern_count; i++)
     {
      CBarPatternControl *c = controls.At(i);
      if(c == NULL) continue;
      string pattern_name = PatternTypeDescription(c.TypePattern());
      int pos = StringFind(pattern_alerts_section, "\"" + pattern_name + "\"");
      if(pos < 0) continue;
      int brace = StringFind(pattern_alerts_section, "{", pos);
      if(brace < 0) continue;
      int close_brace = StringFind(pattern_alerts_section, "}", brace);
      if(close_brace < 0) continue;
      string pattern_obj = StringSubstr(pattern_alerts_section, brace, close_brace - brace + 1);
      bool v;
      if(::JSONConfig_CandlePattern_BoolValue(pattern_obj, "m_pattern_signal_buy",   v)) c.BuySignal(v);
      if(::JSONConfig_CandlePattern_BoolValue(pattern_obj, "m_pattern_signal_sell",  v)) c.SellSignal(v);
      if(::JSONConfig_CandlePattern_BoolValue(pattern_obj, "m_pattern_alert_sound",  v)) c.SoundAlert(v);
      if(::JSONConfig_CandlePattern_BoolValue(pattern_obj, "m_pattern_alert_message",v)) c.MessageAlert(v);
     }
  }
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

   CArrayObj *controls = (m_BarPatterns_Control != NULL) ? m_BarPatterns_Control.GetListControls() : NULL;
   int pattern_count = (controls != NULL) ? controls.Total() : 0;
   json += " \"Pattern_Alerts_Setting\": {\n";
   int written = 0;
   for(int i = 0; i < pattern_count; i++)
    {
     CBarPatternControl *c = controls.At(i);
     if(c == NULL) continue;
     if(written > 0) json += ",\n";
     json += "  \"" + PatternTypeDescription(c.TypePattern()) + "\": { \"m_pattern_signal_buy\": " + (c.BuySignal() ? "true" : "false") +
             ", \"m_pattern_signal_sell\": " + (c.SellSignal() ? "true" : "false") +
             ", \"m_pattern_alert_sound\": " + (c.SoundAlert() ? "true" : "false") +
             ", \"m_pattern_alert_message\": " + (c.MessageAlert() ? "true" : "false") + " }";
     written++;
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
   ::Print(__FUNCTION__, " > saved ", written, " pattern alert setting(s) to ", full_path);
  }
 CBarPatternControl *CGUIPannel::PatternControlAt(const int i) const
  {
   if(m_BarPatterns_Control == NULL) return NULL;
   CArrayObj *controls = m_BarPatterns_Control.GetListControls();
   return (controls != NULL) ? controls.At(i) : NULL;
  } 
 //+------------------------------------------------------------------+
 //| Create Save button + m_table_CandlePatternsSetting (Settings tab, |
 //+------------------------------------------------------------------+
 bool CGUIPannel::CreateTable_CandlePatternSetting(const int x, const int y)
  {
   // Step 1: Create Save Button ABOVE the table
    m_btn_save_pattern_config.MainPointer(m_tabs_setting_timeseries);
    m_tabs_setting_timeseries.AddToElementsArray(TAB_TAB_SETTING_TIMESERIES_CANDLE_PATTERN, m_btn_save_pattern_config);
    m_btn_save_pattern_config.AutoXResizeMode(false);
    m_btn_save_pattern_config.XSize(80);
    m_btn_save_pattern_config.YSize(M_CONTROL_HEIGHT);
    m_btn_save_pattern_config.IconFile(IMAGE_RESOURCE_BMP16_SAVE_PNG);
    if(!m_btn_save_pattern_config.CreateButton("Save", x+SETTING_BTN_SAVE_CANDLE_PATTERN_X_GAP, y+SETTING_BTN_SAVE_CANDLE_PATTERN_Y_GAP)) return false;
    CWndContainer::AddToElementsArray(WindowIdx(m_window_setting_timeseries), m_btn_save_pattern_config);

   // Step 2: Create Table BELOW button
    int table_y = y + SETTING_BTN_SAVE_CANDLE_PATTERN_Y_GAP + M_CONTROL_HEIGHT + SETTING_BTN_SAVE_CANDLE_PATTERN_Y_GAP;
    m_table_CandlePatternsSetting.MainPointer(m_tabs_setting_timeseries);
    m_tabs_setting_timeseries.AddToElementsArray(TAB_TAB_SETTING_TIMESERIES_CANDLE_PATTERN, m_table_CandlePatternsSetting);
    m_table_CandlePatternsSetting.AutoXResizeMode(true);
    m_table_CandlePatternsSetting.AutoXResizeRightOffset(3);
    m_table_CandlePatternsSetting.AutoYResizeMode(true);
    m_table_CandlePatternsSetting.AutoYResizeBottomOffset(3);
    m_table_CandlePatternsSetting.LightsHover(true);
    m_table_CandlePatternsSetting.ShowHeaders(true);
    m_table_CandlePatternsSetting.SelectableRow(true);
    m_table_CandlePatternsSetting.IsSortMode(true);
    CArrayObj *controls = (m_BarPatterns_Control != NULL) ? m_BarPatterns_Control.GetListControls() : NULL;
    m_table_CandlePatternsSetting.TableSize(8, (controls != NULL) ? controls.Total() : 0);
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
    CWndContainer::AddToElementsArray(WindowIdx(m_window_setting_timeseries), m_table_CandlePatternsSetting);
    return true;
  }
 void CGUIPannel::InitializeTable_CandlePatternSetting(void)
  {
   CArrayObj *controls = (m_BarPatterns_Control != NULL) ? m_BarPatterns_Control.GetListControls() : NULL;
   int n = (controls != NULL) ? controls.Total() : 0;
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
      CBarPatternControl *c = controls.At(i);
      ENUM_PATTERN_TYPE type = (c != NULL) ? c.TypePattern() : PATTERN_TYPE_NONE;
      m_table_CandlePatternsSetting.SetValue(0, i, PatternTypeDescription(type));
      m_table_CandlePatternsSetting.SetValue(1, i, (c != NULL) ? string(c.Candles()) : "");// "1", "2", "3"
      m_table_CandlePatternsSetting.CellType(2, i, CELL_CHECKBOX);
      m_table_CandlePatternsSetting.SetImages(2, i, chk);
      m_table_CandlePatternsSetting.ChangeImage(2, i, (c != NULL && c.BuySignal()) ? CHECKBOX_STATE_ON : CHECKBOX_STATE_OFF);

      m_table_CandlePatternsSetting.CellType(3, i, CELL_CHECKBOX);
      m_table_CandlePatternsSetting.SetImages(3, i, chk);
      m_table_CandlePatternsSetting.ChangeImage(3, i, (c != NULL && c.SellSignal()) ? CHECKBOX_STATE_ON : CHECKBOX_STATE_OFF);

      m_table_CandlePatternsSetting.CellType(4, i, CELL_BUTTON);
      m_table_CandlePatternsSetting.SetImages(4, i, arrow_up);   // ▲ static green

      m_table_CandlePatternsSetting.CellType(5, i, CELL_CHECKBOX);
      m_table_CandlePatternsSetting.SetImages(5, i, chk);
      m_table_CandlePatternsSetting.ChangeImage(5, i, (c != NULL && c.SoundAlert()) ? CHECKBOX_STATE_ON : CHECKBOX_STATE_OFF);

      m_table_CandlePatternsSetting.CellType(6, i, CELL_CHECKBOX);
      m_table_CandlePatternsSetting.SetImages(6, i, chk);
      m_table_CandlePatternsSetting.ChangeImage(6, i, (c != NULL && c.MessageAlert()) ? CHECKBOX_STATE_ON : CHECKBOX_STATE_OFF);

      m_table_CandlePatternsSetting.CellType(7, i, CELL_BUTTON);
      m_table_CandlePatternsSetting.SetImages(7, i, arrow_dn);
    }
  }
 //+------------------------------------------------------------------+
 //| Row -> Control index lookup by content (col 0 = Pattern display  |
 //| name, recomputed on the fly via PatternTypeDescription()) - same |
 //| reasoning as SymbolTF's FindTableRowBySymbolTF: IsSortMode(true)  |
 //| means row position drifts from array index after a header-click  |
 //| sort, so raw row can't be used as the array index directly.       |
 //+------------------------------------------------------------------+
 int CGUIPannel::FindPatternIndexByRow(const int row)
  {
   string name = m_table_CandlePatternsSetting.GetValue(0, row);
   CArrayObj *controls = (m_BarPatterns_Control != NULL) ? m_BarPatterns_Control.GetListControls() : NULL;
   int n = (controls != NULL) ? controls.Total() : 0;
   for(int i = 0; i < n; i++)
    {
     CBarPatternControl *c = controls.At(i);
     if(c != NULL && PatternTypeDescription(c.TypePattern()) == name) return i;
    }
   return -1;
  }
 //+------------------------------------------------------------------+
 //| Checkbox toggle handler for m_table_CandlePatternsSetting - col   |
 //| 2=Buy, 3=Sell, 5=Sound, 6=Message. Commits straight onto the row's |
 //| CBarPatternControl (Single Source of Truth), Table cell already   |
 //| shows the new state via CTable's own checkbox toggle.             |
 //+------------------------------------------------------------------+
 void CGUIPannel::OnCheckTableCandlePatternSetting(const int row, const int col)
  {
   int idx = FindPatternIndexByRow(row);
   ::Print("MY DEBUG CGUIPannel::OnCheckTableCandlePatternSetting: row=", row, " col=", col, " idx=", idx,
           " table_name_at_row=", m_table_CandlePatternsSetting.GetValue(0, row));
   if(idx < 0) return;
   CBarPatternControl *c = PatternControlAt(idx);
   ::Print("MY DEBUG CGUIPannel::OnCheckTableCandlePatternSetting: c=", (c != NULL ? "OK type=" + EnumToString(c.TypePattern()) : "NULL"));
   if(c == NULL) return;
   if(col == 2)
     // --- No manual event fire anymore (Anhnt, 2026-08-30) - the setter itself dirty-checks and
     // --- fires BARPATTERN_CONTROL_EVENT_BUYSELL_CHANGED now (BarPatternControl.mqh).
     c.BuySignal((int)m_table_CandlePatternsSetting.SelectedImageIndex(2, row) == CHECKBOX_STATE_ON);
   else if(col == 3)
     c.SellSignal((int)m_table_CandlePatternsSetting.SelectedImageIndex(3, row) == CHECKBOX_STATE_ON);
   else if(col == 5)
     c.SoundAlert((int)m_table_CandlePatternsSetting.SelectedImageIndex(5, row) == CHECKBOX_STATE_ON);
   else if(col == 6)
     c.MessageAlert((int)m_table_CandlePatternsSetting.SelectedImageIndex(6, row) == CHECKBOX_STATE_ON);
  }
 bool CGUIPannel::PatternSignalBuy(const ENUM_PATTERN_TYPE type) const
  {
   CArrayObj *controls = (m_BarPatterns_Control != NULL) ? m_BarPatterns_Control.GetListControls() : NULL;
   int n = (controls != NULL) ? controls.Total() : 0;
   for(int i = 0; i < n; i++)
    {
     CBarPatternControl *c = controls.At(i);
     if(c != NULL && c.TypePattern() == type) return c.BuySignal();
    }
   return false;
  }
 bool CGUIPannel::PatternSignalSell(const ENUM_PATTERN_TYPE type) const
  {
   CArrayObj *controls = (m_BarPatterns_Control != NULL) ? m_BarPatterns_Control.GetListControls() : NULL;
   int n = (controls != NULL) ? controls.Total() : 0;
   for(int i = 0; i < n; i++)
    {
     CBarPatternControl *c = controls.At(i);
     if(c != NULL && c.TypePattern() == type) return c.SellSignal();
    }
   return false;
  }
#endif  //CGUIPANNEL_SETTINGWINDOWS_TS_CANDLE_PATTERN_MQH