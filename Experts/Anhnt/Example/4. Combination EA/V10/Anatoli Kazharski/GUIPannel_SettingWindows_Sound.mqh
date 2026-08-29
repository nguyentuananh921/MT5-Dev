//+------------------------------------------------------------------+
//|                               GUIPannel_SettingWindows_Sound.mqh |
//+------------------------------------------------------------------+
//Bug Note: Sound in folder C:\Program Files\MetaTrader 5\Sounds
#ifndef CGUIPANNEL_SETTINGWINDOWS_SOUND_MQH
#define CGUIPANNEL_SETTINGWINDOWS_SOUND_MQH
#include "GUIPannel.mqh"
 //Tab Sound TAB_TAB_MAIN_SETTINGS_CONFIG_SOUND of Tab m_tabs_main_setting_config
 // --- Split away from the Marker tab (Anhnt, 2026-08-26) - Buy/Sell alert sound file pickers
 // --- are an independent concern from marker shape/color, own tab.
 //+----------------------------------------------------------------------------+
 //| Seeds m_marker_buy_sound_file/m_marker_sell_sound_file from Config_Setting. |
 //| json's "Sound_Settings" section - always sets sane defaults FIRST so a     |
 //| missing/partial file still leaves the combo on a valid selection.          |
 //+----------------------------------------------------------------------------+
 void CGUIPannel::LoadSoundSettingsFromJSON(void)
  {
    m_marker_buy_sound_file  = "SIGNAL_BUY_EN.wav";
    m_marker_sell_sound_file = "SIGNAL_SELL_EN.wav";
    string full_path = g_ea_folder + "/Config_Setting.json";
    string content = JSONConfig_ReadWholeFile(full_path);
    if(content == "") return;
    string sound_section = JSONConfig_ExtractRawSection(content, "Sound_Settings");
    if(sound_section == "") return;
    string sv;
    if(::JSONConfig_StringValue(sound_section, "buy_sound_file",  sv)) m_marker_buy_sound_file  = sv;
    if(::JSONConfig_StringValue(sound_section, "sell_sound_file", sv)) m_marker_sell_sound_file = sv;
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
 bool CGUIPannel::CreateTabSettingConfig_Sound(const int x, const int y)
  {
   //Define for GUI Layout in tab Sound
    #define SETTING_SOUND_BASE_X_GAP 10
    #define SETTING_SOUND_CAPTION_WIDTH  125
    #define SETTING_SOUND_ROW_GAP        10
    #define SETTING_SOUND_ROW_HEIGHT     26
    #define SETTING_SOUND_WIDTH          350 //Combobox Sound file

    LoadSoundSettingsFromJSON(); // seed m_marker_*_sound_file from Config_Setting.json before building defaults

   // Row 0: Sound folder static label (read-only, shows where to drop .wav files)
    if(!CreateMarkerTabCaption(11, "Sound Folder", x + SETTING_SOUND_BASE_X_GAP, y, TAB_TAB_MAIN_SETTINGS_CONFIG_SOUND)) return false;
    m_textLabel_sound_folder.MainPointer(m_tabs_main_setting_config);
    m_tabs_main_setting_config.AddToElementsArray(TAB_TAB_MAIN_SETTINGS_CONFIG_SOUND, m_textLabel_sound_folder);
    m_textLabel_sound_folder.XSize(SETTING_SOUND_WIDTH);
    string lbl_text = ::TerminalInfoString(TERMINAL_PATH) + "\\Sounds\\";
    if(!m_textLabel_sound_folder.CreateTextLabel(lbl_text, x + SETTING_SOUND_BASE_X_GAP + SETTING_SOUND_CAPTION_WIDTH, y)) return false;
    CWndContainer::AddToElementsArray(WindowIdx(m_window_setting), m_textLabel_sound_folder);

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

   // Row 1: Buy Sound
    if(!CreateMarkerTabCaption(12, "Buy Sound", x + SETTING_SOUND_BASE_X_GAP,
                                y + SETTING_SOUND_ROW_HEIGHT + SETTING_SOUND_ROW_GAP, TAB_TAB_MAIN_SETTINGS_CONFIG_SOUND)) return false;
    if(!CreateMarkerTabComboBox(m_combo_buy_sound, x + SETTING_SOUND_BASE_X_GAP + SETTING_SOUND_CAPTION_WIDTH,
                                y + SETTING_SOUND_ROW_HEIGHT + SETTING_SOUND_ROW_GAP, SETTING_SOUND_WIDTH, files, sel_buy_sound, TAB_TAB_MAIN_SETTINGS_CONFIG_SOUND)) return false;
   // Row 2: Sell Sound
    if(!CreateMarkerTabCaption(13, "Sell Sound", x + SETTING_SOUND_BASE_X_GAP,
                                y + SETTING_SOUND_ROW_HEIGHT*2 + SETTING_SOUND_ROW_GAP*2, TAB_TAB_MAIN_SETTINGS_CONFIG_SOUND)) return false;
    if(!CreateMarkerTabComboBox(m_combo_sell_sound, x + SETTING_SOUND_BASE_X_GAP + SETTING_SOUND_CAPTION_WIDTH,
                                y + SETTING_SOUND_ROW_HEIGHT*2 + SETTING_SOUND_ROW_GAP*2, SETTING_SOUND_WIDTH, files, sel_sell_sound, TAB_TAB_MAIN_SETTINGS_CONFIG_SOUND)) return false;

   //For Button Save sound settings
    m_btn_save_sound_settings.MainPointer(m_tabs_main_setting_config);
    m_tabs_main_setting_config.AddToElementsArray(TAB_TAB_MAIN_SETTINGS_CONFIG_SOUND, m_btn_save_sound_settings);
    m_btn_save_sound_settings.AutoXResizeMode(false);
    m_btn_save_sound_settings.XSize(80);
    m_btn_save_sound_settings.IconFile(IMAGE_RESOURCE_BMP16_SAVE_PNG);
    if(!m_btn_save_sound_settings.CreateButton("Save", x + SETTING_SOUND_BASE_X_GAP,
                               y + SETTING_SOUND_ROW_HEIGHT*3 + SETTING_SOUND_ROW_GAP*3)) return false;
    CWndContainer::AddToElementsArray(WindowIdx(m_window_setting), m_btn_save_sound_settings);

    return true;
  }
 //+----------------------------------------------------------------------------+
 //| Writes the "Sound_Settings" section of Config_Setting.json straight from   |
 //| m_marker_buy_sound_file/m_marker_sell_sound_file (already committed live   |
 //| by the combo's own ON_CLICK_COMBOBOX_ITEM handler) - preserves the 4       |
 //| sections owned elsewhere.                                                  |
 //+----------------------------------------------------------------------------+
 void CGUIPannel::SaveSoundSettingsToJSON(void)
  {
   string full_path = g_ea_folder + "/Config_Setting.json";
   string existing        = JSONConfig_ReadWholeFile(full_path);
   string symbols_tf      = JSONConfig_ExtractRawSection(existing, "Symbols_TFs_List");
   string templates       = JSONConfig_ExtractRawSection(existing, "Indicator_Templates");
   string markers         = JSONConfig_ExtractRawSection(existing, "Markers_Setting");
   string pattern_alerts  = JSONConfig_ExtractRawSection(existing, "Pattern_Alerts_Setting");

   string json = "{\n";
   if(symbols_tf     != "") json += " \"Symbols_TFs_List\": "     + symbols_tf     + ",\n";
   if(templates      != "") json += " \"Indicator_Templates\": "  + templates      + ",\n";
   if(markers        != "") json += " \"Markers_Setting\": "      + markers        + ",\n";
   if(pattern_alerts != "") json += " \"Pattern_Alerts_Setting\": " + pattern_alerts + ",\n";

   string buy_sound_esc  = m_marker_buy_sound_file;
   string sell_sound_esc = m_marker_sell_sound_file;
   ::StringReplace(buy_sound_esc,  "\\", "\\\\");
   ::StringReplace(sell_sound_esc, "\\", "\\\\");
   json += " \"Sound_Settings\": {\n" +
       "  \"buy_sound_file\": \""  + buy_sound_esc  + "\",\n" +
       "  \"sell_sound_file\": \"" + sell_sound_esc + "\"\n" +
       " }\n}";

   int fh = ::FileOpen(full_path, FILE_TXT | FILE_WRITE | FILE_ANSI);
   if(fh == INVALID_HANDLE)
    {
     ::Print(__FUNCTION__, " > cannot open ", full_path, " for writing, err=", ::GetLastError());
     return;
    }
   ::FileWriteString(fh, json);
   ::FileClose(fh);
   ::Print(__FUNCTION__, " > saved sound settings to ", full_path);
  }
#endif // CGUIPANNEL_SETTINGWINDOWS_SOUND_MQH
