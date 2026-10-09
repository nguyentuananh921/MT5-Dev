//+------------------------------------------------------------------+
//|                         GUIPannel_SettingWindows_Alert_Sound.mqh |
//+------------------------------------------------------------------+
//Bug Note: Sound in folder C:\Program Files\MetaTrader 5\Sounds
#ifndef CGUIPANNEL_SETTINGWINDOWS_ALERT_SOUND_MQH
#define CGUIPANNEL_SETTINGWINDOWS_ALERT_SOUND_MQH
#include "GUIPannel.mqh"
 //Tab Sound ENUM_TAB_SETTING_MARKERANDSOUND_SOUND of Tab m_tabs_setting_markerAndSound 
 //+----------------------------------------------------------------------------+
 void CGUIPannel::LoadSoundSettingsFromJSON(string &out_trailing_sound_file)
  {
    m_marker_buy_sound_file  = "SIGNAL_BUY_EN.wav";
    m_marker_sell_sound_file = "SIGNAL_SELL_EN.wav";
    out_trailing_sound_file  = "alert.wav";
    m_buy_sound_enabled      = true;
    m_sell_sound_enabled     = true;
    m_trailing_sound_enabled = true;
    string full_path = g_ea_folder + "/Config_Setting.json";
    string content = JSONConfig_ReadWholeFile(full_path);
    if(content == "") return;
    string sound_section = JSONConfig_ExtractRawSection(content, "Sound_Settings");
    if(sound_section == "") return;
    string sv;
    if(::JSONConfig_StringValue(sound_section, "buy_sound_file",  sv)) m_marker_buy_sound_file  = sv;
    if(::JSONConfig_StringValue(sound_section, "sell_sound_file", sv)) m_marker_sell_sound_file = sv;
    if(::JSONConfig_StringValue(sound_section, "trailing_sound_file", sv)) out_trailing_sound_file = sv;
    ::JSONConfig_BoolValue(sound_section, "buy_sound_enabled",      m_buy_sound_enabled);
    ::JSONConfig_BoolValue(sound_section, "sell_sound_enabled",     m_sell_sound_enabled);
    ::JSONConfig_BoolValue(sound_section, "trailing_sound_enabled", m_trailing_sound_enabled);
  }
 //Note: Must scan the default folder that can play the sound - ::TerminalInfoString(TERMINAL_PATH) + "\\Sounds\\"
 void CGUIPannel::ScanSoundFolder(string &files[])
  {
   ::ArrayResize(files, 0);
   string search_path = "Sounds\\*.wav";
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
 bool CGUIPannel::CreateTab_SettingConfig_Sound(const int x, const int y)
  {
   //Define for GUI Layout in tab Sound
    #define SETTING_SOUND_BASE_X_GAP 10
    #define SETTING_SOUND_CAPTION_WIDTH  125
    #define SETTING_SOUND_ROW_GAP        10
    #define SETTING_SOUND_ROW_HEIGHT     26
    #define SETTING_SOUND_WIDTH          350 //Combobox Sound file
    #define SETTING_SOUND_CHECK_WIDTH    26  //On/Off checkbox sitting between caption and combobox
    #define SETTING_SOUND_COMBO_X        (x + SETTING_SOUND_BASE_X_GAP + SETTING_SOUND_CAPTION_WIDTH + SETTING_SOUND_CHECK_WIDTH)
    #define SETTING_SOUND_CHECK_X        (x + SETTING_SOUND_BASE_X_GAP + SETTING_SOUND_CAPTION_WIDTH)

    string trailing_sound_default;
    LoadSoundSettingsFromJSON(trailing_sound_default); // seed m_marker_*_sound_file + trailing default from Config_Setting.json before building defaults
    ApplyTrailingSoundToAllSymbols(trailing_sound_default, m_trailing_sound_enabled); // wire it into CTradeObj right away too - don't wait for a Save click

   // Row 0: Sound folder static label (read-only, shows where to drop .wav files)
    if(!CreateTextLabel_OtherCaption(11, "Sound Folder", x + SETTING_SOUND_BASE_X_GAP, y, ENUM_TAB_SETTING_MARKERANDSOUND_SOUND)) return false;
    m_textLabel_sound_folder.MainPointer(m_tabs_setting_markerAndSound);
    m_tabs_setting_markerAndSound.AddToElementsArray(ENUM_TAB_SETTING_MARKERANDSOUND_SOUND, m_textLabel_sound_folder);
    m_textLabel_sound_folder.XSize(SETTING_SOUND_WIDTH);
    string lbl_text = ::TerminalInfoString(TERMINAL_PATH) + "\\Sounds\\";
    if(!m_textLabel_sound_folder.CreateTextLabel(lbl_text, x + SETTING_SOUND_BASE_X_GAP + SETTING_SOUND_CAPTION_WIDTH, y)) return false;
    CWndContainer::AddToElementsArray(WindowIdx(m_window_setting_markerAndSound), m_textLabel_sound_folder);

   // --- Sound files scan
    string files[];
    ScanSoundFolder(files);
    int n_files = ArraySize(files);
    int sel_buy_sound = 0, sel_sell_sound = 0, sel_trailing_sound = 0;
    for(int i = 0; i < n_files; i++)
     {
      if(files[i] == m_marker_buy_sound_file)   sel_buy_sound      = i;
      if(files[i] == m_marker_sell_sound_file)  sel_sell_sound     = i;
      if(files[i] == trailing_sound_default)    sel_trailing_sound = i;
     }

   // Row 1: Buy Sound - [caption] [On/Off] [file]
    int row1_y = y + SETTING_SOUND_ROW_HEIGHT   + SETTING_SOUND_ROW_GAP;
    int row2_y = y + SETTING_SOUND_ROW_HEIGHT*2 + SETTING_SOUND_ROW_GAP*2;
    int row3_y = y + SETTING_SOUND_ROW_HEIGHT*3 + SETTING_SOUND_ROW_GAP*3;
    if(!CreateTextLabel_OtherCaption(12, "Buy Sound", x + SETTING_SOUND_BASE_X_GAP, row1_y, ENUM_TAB_SETTING_MARKERANDSOUND_SOUND)) return false;
    if(!CreateCheckBox_SoundEnable(m_checkbox_buy_sound, SETTING_SOUND_CHECK_X, row1_y, m_buy_sound_enabled)) return false;
    if(!CreateCombobox_MarkerSelection(m_combo_buy_sound, SETTING_SOUND_COMBO_X, row1_y, SETTING_SOUND_WIDTH, files, sel_buy_sound, ENUM_TAB_SETTING_MARKERANDSOUND_SOUND)) return false;
   // Row 2: Sell Sound
    if(!CreateTextLabel_OtherCaption(13, "Sell Sound", x + SETTING_SOUND_BASE_X_GAP, row2_y, ENUM_TAB_SETTING_MARKERANDSOUND_SOUND)) return false;
    if(!CreateCheckBox_SoundEnable(m_checkbox_sell_sound, SETTING_SOUND_CHECK_X, row2_y, m_sell_sound_enabled)) return false;
    if(!CreateCombobox_MarkerSelection(m_combo_sell_sound, SETTING_SOUND_COMBO_X, row2_y, SETTING_SOUND_WIDTH, files, sel_sell_sound, ENUM_TAB_SETTING_MARKERANDSOUND_SOUND)) return false;
   // Row 3: Trailing Sound - plays on every real SL modify from ApplyStopLostAndTrailing (Anhnt/
   // Claude, 2026-09-08), wired via CTradeObj::SetSoundModifySL/UseSoundModifySL in
   // SaveSoundSettingsToJSON below, not a hand-rolled CMessage::PlaySound call.
    if(!CreateTextLabel_OtherCaption(14, "Trailing Sound", x + SETTING_SOUND_BASE_X_GAP, row3_y, ENUM_TAB_SETTING_MARKERANDSOUND_SOUND)) return false;
    if(!CreateCheckBox_SoundEnable(m_checkbox_trailing_sound, SETTING_SOUND_CHECK_X, row3_y, m_trailing_sound_enabled)) return false;
    if(!CreateCombobox_MarkerSelection(m_combo_trailling_sound, SETTING_SOUND_COMBO_X, row3_y, SETTING_SOUND_WIDTH, files, sel_trailing_sound, ENUM_TAB_SETTING_MARKERANDSOUND_SOUND)) return false;

   //For Button Save sound settings
    m_btn_save_sound_settings.MainPointer(m_tabs_setting_markerAndSound);
    m_tabs_setting_markerAndSound.AddToElementsArray(ENUM_TAB_SETTING_MARKERANDSOUND_SOUND, m_btn_save_sound_settings);
    m_btn_save_sound_settings.AutoXResizeMode(false);
    m_btn_save_sound_settings.XSize(80);
    m_btn_save_sound_settings.IconFile(IMAGE_RESOURCE_BMP16_SAVE_PNG);
    if(!m_btn_save_sound_settings.CreateButton("Save", x + SETTING_SOUND_BASE_X_GAP,
                               y + SETTING_SOUND_ROW_HEIGHT*4 + SETTING_SOUND_ROW_GAP*4)) return false;
    CWndContainer::AddToElementsArray(WindowIdx(m_window_setting_markerAndSound), m_btn_save_sound_settings);

    return true;
  } 
 //+------------------------------------------------------------------+
 //| Value of the "Sound_Settings" key - reads the 3 On/Off checkboxes |
 //| + trailing combo live (the Buy/Sell file names are committed on   |
 //| combo change already). File writing is SaveAllSettingsToJSON.     |
 //+------------------------------------------------------------------+
 void CGUIPannel::BuildJsonSection_Sound(string &out_json)
  {
   m_buy_sound_enabled      = m_checkbox_buy_sound.IsPressed();
   m_sell_sound_enabled     = m_checkbox_sell_sound.IsPressed();
   m_trailing_sound_enabled = m_checkbox_trailing_sound.IsPressed();
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
 //+------------------------------------------------------------------+
 //| Small square On/Off checkbox (no caption) - same _G_ icon fix as |
 //| the Trading tab's checkboxes.                                     |
 //+------------------------------------------------------------------+
 bool CGUIPannel::CreateCheckBox_SoundEnable(CCheckBox &checkbox, const int x, const int y, const bool pressed)
  {
   checkbox.MainPointer(m_tabs_setting_markerAndSound);
   m_tabs_setting_markerAndSound.AddToElementsArray(ENUM_TAB_SETTING_MARKERANDSOUND_SOUND, checkbox);
   checkbox.XSize(SETTING_SOUND_CHECK_WIDTH - 4);
   checkbox.YSize(SETTING_SOUND_ROW_HEIGHT);
   if(!checkbox.CreateCheckBox("", x, y)) return false;
   CWndContainer::AddToElementsArray(WindowIdx(m_window_setting_markerAndSound), checkbox);
   checkbox.IconFilePressed(IMAGE_RESOURCE_BMP16_CHECKBOX_ON_G_PNG);
   checkbox.IsPressed(pressed);
   return true;
  }
 //+------------------------------------------------------------------+
 //| Trailing sound -> CTradeObj of every Symbol. `enabled` false      |
 //| keeps the file but switches UseSoundModifySL off, so the SL-     |
 //| modify path stays silent.                                         |
 //+------------------------------------------------------------------+
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
