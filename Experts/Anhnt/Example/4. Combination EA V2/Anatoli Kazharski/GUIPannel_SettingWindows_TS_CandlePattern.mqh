//+------------------------------------------------------------------+
//|                    GUIPannel_SettingWindows_TS_CandlePattern.mqh |
//| Candle Pattern tab: Buy/Sell/Sound/Message per CBarPatternControl|
//+------------------------------------------------------------------+
#ifndef CGUIPANNEL_SETTINGWINDOWS_TS_CANDLE_PATTERN_MQH
#define CGUIPANNEL_SETTINGWINDOWS_TS_CANDLE_PATTERN_MQH
 #define SETTING_BTN_SAVE_CANDLE_PATTERN_X_GAP 10
 #define SETTING_BTN_SAVE_CANDLE_PATTERN_Y_GAP 20
 #define COLUMNS_CANDLE_PATTERN_TOTAL          8
 #include "GUIPannel.mqh"
 bool JSONConfig_CandlePattern_BoolValue(const string content, const string key, bool &value)
  {
   int pos = ::StringFind(content, "\"" + key + "\"");
   if(pos < 0) return false;
   int colon = ::StringFind(content, ":", pos);
   if(colon < 0) return false;
   int len = ::StringLen(content);
   int i = colon + 1;
   while(i < len && ::StringGetCharacter(content, i) == ' ') i++;
   if(::StringSubstr(content, i, 4) == "true")  { value = true;  return true; }
   if(::StringSubstr(content, i, 5) == "false") { value = false; return true; }
   return false;
  }
 void CGUIPannel::LoadCandlePatternSetting_FromJSON(void)
  {
   if(m_BarPatterns_Control == NULL || m_SymbolTFManager == NULL) return;
   string full_path = m_SymbolTFManager.GetFolderName() + "/Config_Setting.json";
   string content = JSONConfig_ReadWholeFile(full_path);
   if(content == "") return;
   string section = JSONConfig_ExtractRawSection(content, "Pattern_Alerts_Setting");
   if(section == "") return;
   CArrayObj *controls = m_BarPatterns_Control.GetListControls();
   int pattern_count = (controls != NULL) ? controls.Total() : 0;
   for(int i = 0; i < pattern_count; i++)
    {
     CBarPatternControl *c = controls.At(i);
     if(c == NULL) continue;
     int pos = ::StringFind(section, "\"" + PatternTypeDescription(c.TypePattern()) + "\"");
     if(pos < 0) continue;
     int brace = ::StringFind(section, "{", pos);
     if(brace < 0) continue;
     int close_brace = ::StringFind(section, "}", brace);
     if(close_brace < 0) continue;
     string pattern_obj = ::StringSubstr(section, brace, close_brace - brace + 1);
     bool v;
     if(::JSONConfig_CandlePattern_BoolValue(pattern_obj, "m_pattern_signal_buy",    v)) c.BuySignal(v);
     if(::JSONConfig_CandlePattern_BoolValue(pattern_obj, "m_pattern_signal_sell",   v)) c.SellSignal(v);
     if(::JSONConfig_CandlePattern_BoolValue(pattern_obj, "m_pattern_alert_sound",   v)) c.SoundAlert(v);
     if(::JSONConfig_CandlePattern_BoolValue(pattern_obj, "m_pattern_alert_message", v)) c.MessageAlert(v);
    }
  }
 //--- Value of the "Pattern_Alerts_Setting" key; SaveAllSettingsToJSON writes the file
 void CGUIPannel::BuildJsonSection_PatternAlerts(string &out_json) const
  {
   CArrayObj *controls = (m_BarPatterns_Control != NULL) ? m_BarPatterns_Control.GetListControls() : NULL;
   int pattern_count = (controls != NULL) ? controls.Total() : 0;
   out_json = "{\n";
   int written = 0;
   for(int i = 0; i < pattern_count; i++)
    {
     CBarPatternControl *c = controls.At(i);
     if(c == NULL) continue;
     if(written > 0) out_json += ",\n";
     out_json += "  \"" + PatternTypeDescription(c.TypePattern()) + "\": { \"m_pattern_signal_buy\": " + (c.BuySignal() ? "true" : "false") +
                 ", \"m_pattern_signal_sell\": " + (c.SellSignal() ? "true" : "false") +
                 ", \"m_pattern_alert_sound\": " + (c.SoundAlert() ? "true" : "false") +
                 ", \"m_pattern_alert_message\": " + (c.MessageAlert() ? "true" : "false") + " }";
     written++;
    }
   out_json += "\n }";
  }
 CBarPatternControl *CGUIPannel::PatternControlAt(const int i) const
  {
   if(m_BarPatterns_Control == NULL) return NULL;
   CArrayObj *controls = m_BarPatterns_Control.GetListControls();
   return (controls != NULL) ? controls.At(i) : NULL;
  }
 //--- 8 columns: Pattern, No, Buy, Sell, up-arrow legend, Sound, Message, down-arrow legend
 bool CGUIPannel::CreateTable_CandlePatternSetting(const int x, const int y)
  {
   m_btn_save_pattern_config.SetText("Save");
   m_btn_save_pattern_config.IconFile(IMAGE_RESOURCE_BMP16_SAVE_PNG);
   m_tabs_setting_timeseries.AddToElementsArray(TAB_TAB_SETTING_TIMESERIES_CANDLE_PATTERN, m_btn_save_pattern_config);
   if(!m_btn_save_pattern_config.Create(m_chart_id, m_subwin, "BtnSavePattern", x + SETTING_BTN_SAVE_CANDLE_PATTERN_X_GAP,
                                        y + SETTING_BTN_SAVE_CANDLE_PATTERN_Y_GAP, 80, M_CONTROL_HEIGHT)) return false;
   int table_y = y + SETTING_BTN_SAVE_CANDLE_PATTERN_Y_GAP + M_CONTROL_HEIGHT + SETTING_BTN_SAVE_CANDLE_PATTERN_Y_GAP;
   m_table_CandlePatternsSetting.TableSize(COLUMNS_CANDLE_PATTERN_TOTAL, 0);
   m_table_CandlePatternsSetting.View().ShowHeaders(true);
   m_table_CandlePatternsSetting.View().SelectableRow(true);
   m_table_CandlePatternsSetting.View().LightsHover(true);
   m_table_CandlePatternsSetting.View().IsSortMode(true);
   m_table_CandlePatternsSetting.AutoXResizeMode(true);
   m_table_CandlePatternsSetting.AutoXResizeRightOffset(3);
   m_table_CandlePatternsSetting.AutoYResizeMode(true);
   m_table_CandlePatternsSetting.AutoYResizeBottomOffset(3);
   m_tabs_setting_timeseries.AddToElementsArray(TAB_TAB_SETTING_TIMESERIES_CANDLE_PATTERN, m_table_CandlePatternsSetting);
   if(!m_table_CandlePatternsSetting.CreateTable(m_chart_id, m_subwin, "TableCandlePattern", x, table_y)) return false;
   int widths[COLUMNS_CANDLE_PATTERN_TOTAL]            = {155, 30, M_ICON16_WIDTH, M_ICON16_WIDTH, M_ICON16_WIDTH, M_ICON16_WIDTH, M_ICON16_WIDTH, M_ICON16_WIDTH};
   int image_x[COLUMNS_CANDLE_PATTERN_TOTAL]           = {0, 0, 2, 2, 2, 2, 2, 2};
   ENUM_ALIGN_MODE align[COLUMNS_CANDLE_PATTERN_TOTAL] = {ALIGN_LEFT, ALIGN_CENTER, ALIGN_LEFT, ALIGN_LEFT, ALIGN_LEFT, ALIGN_LEFT, ALIGN_LEFT, ALIGN_LEFT};
   CTableHeaderView *header = m_table_CandlePatternsSetting.View().GetHeaderViewPointer();
   header.ColumnsWidth(widths);
   header.TextAlign(align);
   header.ImageXOffset(image_x);
   m_table_CandlePatternsSetting.SetHeaderText(0, "Pattern");
   m_table_CandlePatternsSetting.SetHeaderText(1, "No");
   uint img_buy[]     = {IMAGE_RESOURCE_BMP16_SIGNAL_BUY_PNG};
   uint img_sell[]    = {IMAGE_RESOURCE_BMP16_SIGNAL_SELL_PNG};
   uint img_sound[]   = {IMAGE_RESOURCE_BMP16_BELL_PNG};
   uint img_message[] = {IMAGE_RESOURCE_BMP16_MESSAGE_PNG};
   m_table_CandlePatternsSetting.SetHeaderText(2, "");  m_table_CandlePatternsSetting.SetHeaderImage(2, img_buy);
   m_table_CandlePatternsSetting.SetHeaderText(3, "");  m_table_CandlePatternsSetting.SetHeaderImage(3, img_sell);
   m_table_CandlePatternsSetting.SetHeaderText(4, "");
   m_table_CandlePatternsSetting.SetHeaderText(5, "");  m_table_CandlePatternsSetting.SetHeaderImage(5, img_sound);
   m_table_CandlePatternsSetting.SetHeaderText(6, "");  m_table_CandlePatternsSetting.SetHeaderImage(6, img_message);
   m_table_CandlePatternsSetting.SetHeaderText(7, "");
   m_table_CandlePatternsSetting.View().Rebuild(false);
   return true;
  }
 void CGUIPannel::InitializeTable_CandlePatternSetting(void)
  {
   CArrayObj *controls = (m_BarPatterns_Control != NULL) ? m_BarPatterns_Control.GetListControls() : NULL;
   int n = (controls != NULL) ? controls.Total() : 0;
   m_table_CandlePatternsSetting.DeleteAllRows();
   for(int i = 0; i < n; i++)
      m_table_CandlePatternsSetting.AddRow();
   uint arrow_up[] = {IMAGE_RESOURCE_BMP16_ARROW_UP_PNG};
   uint arrow_dn[] = {IMAGE_RESOURCE_BMP16_ARROW_DOWN_PNG};
   for(int i = 0; i < n; i++)
    {
     CBarPatternControl *c = controls.At(i);
     if(c == NULL) continue;
     m_table_CandlePatternsSetting.SetValue(0, i, PatternTypeDescription(c.TypePattern()));
     m_table_CandlePatternsSetting.SetValue(1, i, (string)c.Candles());
     bool flags[4];
     flags[0] = c.BuySignal();
     flags[1] = c.SellSignal();
     flags[2] = c.SoundAlert();
     flags[3] = c.MessageAlert();
     int check_cols[4] = {2, 3, 5, 6};
     for(int k = 0; k < 4; k++)
      {
       m_table_CandlePatternsSetting.CellView(check_cols[k], i).CellType(CELL_CHECKBOX);
       m_table_CandlePatternsSetting.SetValue(check_cols[k], i, (long)(flags[k] ? CANV_ELEMENT_CHEK_STATE_CHECKED : CANV_ELEMENT_CHEK_STATE_UNCHECKED));
      }
     m_table_CandlePatternsSetting.CellView(4, i).SetImages(arrow_up);
     m_table_CandlePatternsSetting.CellView(7, i).SetImages(arrow_dn);
    }
   m_table_CandlePatternsSetting.View().Rebuild(true);
  }
 //--- Header sort moves rows, so a row is matched to its control by pattern name
 int CGUIPannel::FindPatternIndexByRow(const int row)
  {
   CTableCell *cell = m_table_CandlePatternsSetting.Cell(0, row);
   if(cell == NULL) return -1;
   string name = cell.ValueS();
   CArrayObj *controls = (m_BarPatterns_Control != NULL) ? m_BarPatterns_Control.GetListControls() : NULL;
   int n = (controls != NULL) ? controls.Total() : 0;
   for(int i = 0; i < n; i++)
    {
     CBarPatternControl *c = controls.At(i);
     if(c != NULL && PatternTypeDescription(c.TypePattern()) == name) return i;
    }
   return -1;
  }
 //--- CTable already flipped the checkbox cell, its value is the new state
 void CGUIPannel::OnCheckTableCandlePatternSetting(const int row, const int col)
  {
   CBarPatternControl *c = PatternControlAt(FindPatternIndexByRow(row));
   if(c == NULL) return;
   bool on = (m_table_CandlePatternsSetting.Cell(col, row).ValueL() == CANV_ELEMENT_CHEK_STATE_CHECKED);
   if(col == 2)      c.BuySignal(on);
   else if(col == 3) c.SellSignal(on);
   else if(col == 5) c.SoundAlert(on);
   else if(col == 6) c.MessageAlert(on);
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
