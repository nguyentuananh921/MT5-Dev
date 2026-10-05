//+------------------------------------------------------------------+
//|                         GUIPannel_SettingWindows_Alert_Sound.mqh |
//| Sound tab: Buy / Sell / Trailing .wav + On/Off each              |
//+------------------------------------------------------------------+
#ifndef CGUIPANNEL_SETTINGWINDOWS_ALERT_SOUND_MQH
#define CGUIPANNEL_SETTINGWINDOWS_ALERT_SOUND_MQH
#include "GUIPannel.mqh"
 #define SETTING_SOUND_CAPTION_WIDTH 125   // checkbox caption "Trailing Sound"
 #define SETTING_SOUND_COMBO_WIDTH   350
 #define SETTING_SOUND_ROW_STEP      30
 void CGUIPannel::LoadSoundSettingsFromJSON(string &out_trailing_sound_file)
  {
   m_marker_buy_sound_file  = "SIGNAL_BUY_EN.wav";
   m_marker_sell_sound_file = "SIGNAL_SELL_EN.wav";
   out_trailing_sound_file  = "alert.wav";
   m_buy_sound_enabled      = true;
   m_sell_sound_enabled     = true;
   m_trailing_sound_enabled = true;
   if(m_SymbolTFManager == NULL) return;
   string full_path = m_SymbolTFManager.GetFolderName() + "/Config_Setting.json";
   string content = JSONConfig_ReadWholeFile(full_path);
   if(content == "") return;
   string sound_section = JSONConfig_ExtractRawSection(content, "Sound_Settings");
   if(sound_section == "") return;
   string sv;
   if(::JSONConfig_StringValue(sound_section, "buy_sound_file",      sv)) m_marker_buy_sound_file  = sv;
   if(::JSONConfig_StringValue(sound_section, "sell_sound_file",     sv)) m_marker_sell_sound_file = sv;
   if(::JSONConfig_StringValue(sound_section, "trailing_sound_file", sv)) out_trailing_sound_file = sv;
   ::JSONConfig_BoolValue(sound_section, "buy_sound_enabled",      m_buy_sound_enabled);
   ::JSONConfig_BoolValue(sound_section, "sell_sound_enabled",     m_sell_sound_enabled);
   ::JSONConfig_BoolValue(sound_section, "trailing_sound_enabled", m_trailing_sound_enabled);
  }
 //--- ::PlaySound only reads TERMINAL_PATH\Sounds, so that is the folder listed
 void CGUIPannel::ScanSoundFolder(string &files[])
  {
   ::ArrayResize(files, 0);
   string name;
   long h = ::FileFindFirst("Sounds\\*.wav", name);
   if(h == INVALID_HANDLE) return;
   do
    {
     if(::StringFind(name, "\\") < 0)   // a trailing backslash marks a folder
      {
       int n = ::ArraySize(files);
       ::ArrayResize(files, n + 1);
       files[n] = name;
      }
    }
   while(::FileFindNext(h, name));
   ::FileFindClose(h);
  }
 //--- Row 0: folder; rows 1-3: [x] caption checkbox + file combo; row 4: Save
 bool CGUIPannel::CreateTab_SettingConfig_Sound(const int x, const int y)
  {
   const int base_x  = x + M_CONTROL_BORDER_GAP;
   const int combo_x = base_x + SETTING_SOUND_CAPTION_WIDTH;
   string trailing_sound_default;
   LoadSoundSettingsFromJSON(trailing_sound_default);
   ApplyTrailingSoundToAllSymbols(trailing_sound_default, m_trailing_sound_enabled);   // live right away, not only after Save
   m_textLabel_sound_folder.SetText("Sound Folder: " + ::TerminalInfoString(TERMINAL_PATH) + "\\Sounds\\");
   m_tabs_setting_markerAndSound.AddToElementsArray(ENUM_TAB_SETTING_MARKERANDSOUND_SOUND, m_textLabel_sound_folder);
   if(!m_textLabel_sound_folder.Create(m_chart_id, m_subwin, "LabelSoundFolder", base_x, y, SETTING_SOUND_CAPTION_WIDTH + SETTING_SOUND_COMBO_WIDTH, M_CONTROL_HEIGHT)) return false;
   string files[];
   ScanSoundFolder(files);
   int n_files = ::ArraySize(files);
   int sel_buy = 0, sel_sell = 0, sel_trailing = 0;
   for(int i = 0; i < n_files; i++)
    {
     if(files[i] == m_marker_buy_sound_file)  sel_buy      = i;
     if(files[i] == m_marker_sell_sound_file) sel_sell     = i;
     if(files[i] == trailing_sound_default)   sel_trailing = i;
    }
   int row1_y = y + SETTING_SOUND_ROW_STEP;
   int row2_y = y + 2 * SETTING_SOUND_ROW_STEP;
   int row3_y = y + 3 * SETTING_SOUND_ROW_STEP;
   m_checkbox_buy_sound.SetText("Buy Sound");
   if(!CreateCheckBox_SoundEnable(m_checkbox_buy_sound, base_x, row1_y, m_buy_sound_enabled)) return false;
   if(!CreateCombobox_MarkerSelection(m_combo_buy_sound, combo_x, row1_y, SETTING_SOUND_COMBO_WIDTH, files, sel_buy, ENUM_TAB_SETTING_MARKERANDSOUND_SOUND)) return false;
   m_checkbox_sell_sound.SetText("Sell Sound");
   if(!CreateCheckBox_SoundEnable(m_checkbox_sell_sound, base_x, row2_y, m_sell_sound_enabled)) return false;
   if(!CreateCombobox_MarkerSelection(m_combo_sell_sound, combo_x, row2_y, SETTING_SOUND_COMBO_WIDTH, files, sel_sell, ENUM_TAB_SETTING_MARKERANDSOUND_SOUND)) return false;
   //--- Plays on every real SL modify of ApplyStopLostAndTrailing, through CTradeObj
   m_checkbox_trailing_sound.SetText("Trailing Sound");
   if(!CreateCheckBox_SoundEnable(m_checkbox_trailing_sound, base_x, row3_y, m_trailing_sound_enabled)) return false;
   if(!CreateCombobox_MarkerSelection(m_combo_trailling_sound, combo_x, row3_y, SETTING_SOUND_COMBO_WIDTH, files, sel_trailing, ENUM_TAB_SETTING_MARKERANDSOUND_SOUND)) return false;
   m_btn_save_sound_settings.SetText("Save");
   m_btn_save_sound_settings.IconFile(IMAGE_RESOURCE_BMP16_SAVE_PNG);
   m_tabs_setting_markerAndSound.AddToElementsArray(ENUM_TAB_SETTING_MARKERANDSOUND_SOUND, m_btn_save_sound_settings);
   if(!m_btn_save_sound_settings.Create(m_chart_id, m_subwin, "BtnSaveSound", base_x, y + 4 * SETTING_SOUND_ROW_STEP, 80, M_CONTROL_HEIGHT)) return false;
   return true;
  }
 //--- Value of the "Sound_Settings" key; SaveAllSettingsToJSON writes the file
 void CGUIPannel::BuildJsonSection_Sound(string &out_json)
  {
   m_buy_sound_enabled      = m_checkbox_buy_sound.State();
   m_sell_sound_enabled     = m_checkbox_sell_sound.State();
   m_trailing_sound_enabled = m_checkbox_trailing_sound.State();
   string buy_sound_esc      = m_marker_buy_sound_file;
   string sell_sound_esc     = m_marker_sell_sound_file;
   string trailing_sound_esc = m_combo_trailling_sound.GetValue();
   ::StringReplace(buy_sound_esc,      "\\", "\\\\");
   ::StringReplace(sell_sound_esc,     "\\", "\\\\");
   ::StringReplace(trailing_sound_esc, "\\", "\\\\");
   out_json = "{\n" +
       "  \"buy_sound_file\": \""      + buy_sound_esc      + "\",\n" +
       "  \"sell_sound_file\": \""     + sell_sound_esc     + "\",\n" +
       "  \"trailing_sound_file\": \"" + trailing_sound_esc + "\",\n" +
       "  \"buy_sound_enabled\": "      + (m_buy_sound_enabled      ? "true" : "false") + ",\n" +
       "  \"sell_sound_enabled\": "     + (m_sell_sound_enabled     ? "true" : "false") + ",\n" +
       "  \"trailing_sound_enabled\": " + (m_trailing_sound_enabled ? "true" : "false") + "\n" +
       " }";
  }
 //--- On/Off checkbox, its caption (SetText before calling) names the sound
 bool CGUIPannel::CreateCheckBox_SoundEnable(CCheckBox &checkbox, const int x, const int y, const bool pressed)
  {
   m_tabs_setting_markerAndSound.AddToElementsArray(ENUM_TAB_SETTING_MARKERANDSOUND_SOUND, checkbox);
   if(!checkbox.Create(m_chart_id, m_subwin, "CheckSound" + (string)checkbox.ObjectID(), x, y, SETTING_SOUND_CAPTION_WIDTH, M_CONTROL_HEIGHT)) return false;
   checkbox.SetState(pressed);
   return true;
  }
 //--- Trailing sound -> CTradeObj of every Symbol; `enabled` false keeps the file but mutes SL-modify
 void CGUIPannel::ApplyTrailingSoundToAllSymbols(const string trailing_sound, const bool enabled)
  {
   if(m_trading_control == NULL) return;
   if(trailing_sound != "")
    {
     m_trading_control.SetSound(MODE_SET_SOUND_MODIFY_SL, ORDER_TYPE_BUY,  trailing_sound);
     m_trading_control.SetSound(MODE_SET_SOUND_MODIFY_SL, ORDER_TYPE_SELL, trailing_sound);
    }
   m_trading_control.SetUseSounds(true);
   CArrayObj *col_list = (m_symbol_collection != NULL) ? m_symbol_collection.GetList() : NULL;
   int count = (col_list != NULL) ? col_list.Total() : 0;
   for(int i = 0; i < count; i++)
    {
     CSymbol *sym = col_list.At(i);
     if(sym == NULL) continue;
     CTradeObj *trade_obj = sym.GetTradeObj();
     if(trade_obj == NULL) continue;
     trade_obj.UseSoundModifySL(ORDER_TYPE_BUY,  enabled);
     trade_obj.UseSoundModifySL(ORDER_TYPE_SELL, enabled);
    }
  }
#endif // CGUIPANNEL_SETTINGWINDOWS_ALERT_SOUND_MQH
