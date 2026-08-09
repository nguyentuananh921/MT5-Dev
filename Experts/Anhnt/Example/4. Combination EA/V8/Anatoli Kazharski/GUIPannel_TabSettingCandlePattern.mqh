//+------------------------------------------------------------------+
//|                            GUIPannel_TabSettingCandlePattern.mqh |
//+------------------------------------------------------------------+

#ifndef CGUIPANNEL_TABSETTINGCANDLEPATTERN_MQH
#define CGUIPANNEL_TABSETTINGCANDLEPATTERN_MQH 
 #define SETTING_BTN_SAVE_CANDLE_PATTERN_X_GAP 10
 #define SETTING_BTN_SAVE_CANDLE_PATTERN_Y_GAP 20 
 void CGUIPannel::BuildCandlePatternListFromRegistry(void)
  {
    ArrayFree(m_pattern_types);
    ArrayFree(m_pattern_display_names);

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
    for(int i = 0; i < 28; i++)
     {
        m_pattern_types[i] = all_patterns[i];
        m_pattern_display_names[i] = EnumToString(all_patterns[i]);
     }

  }
 // Register all discovered patterns in m_BarPatterns_Control with proper default params
 void CGUIPannel::RegisterPatterns(void)
  {
   if(m_BarPatterns_Control == NULL) return;
   int n = ArraySize(m_pattern_types);
   if(n == 0) return;
   for(int i = 0; i < n; i++)
    {
     MqlParam param[];
     if(m_pattern_types[i] == PATTERN_TYPE_OUTSIDE_BAR)
      {
       ArrayResize(param, 3);
       param[0].type = TYPE_INT;
       param[0].integer_value = 0;                    // m_min_body_size
       param[1].type = TYPE_DOUBLE;
       param[1].double_value = 50.0;                  // m_ratio_candle_sizes
       param[2].type = TYPE_DOUBLE;
       param[2].double_value = 50.0;                  // m_ratio_body_to_candle_size
      }
     m_BarPatterns_Control.SetUsedPattern(m_pattern_types[i], param, true);
    }
  }
 void CGUIPannel::InitializeTableCandlePatternSetting(void)
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

      m_table_CandlePatternsSetting.CellType(2, i, CELL_BUTTON);
      m_table_CandlePatternsSetting.SetImages(2, i, arrow_up);   // ▲ static green

      m_table_CandlePatternsSetting.CellType(3, i, CELL_CHECKBOX);
      m_table_CandlePatternsSetting.SetImages(3, i, chk);
      m_table_CandlePatternsSetting.ChangeImage(3, i, 0);        //Sound: default enabled

      m_table_CandlePatternsSetting.CellType(4, i, CELL_CHECKBOX);
      m_table_CandlePatternsSetting.SetImages(4, i, chk);
      m_table_CandlePatternsSetting.ChangeImage(4, i, 0);        // Message: default enabled

      m_table_CandlePatternsSetting.CellType(5, i, CELL_BUTTON);
      m_table_CandlePatternsSetting.SetImages(5, i, arrow_dn);
    }
   // Load Pattern Alert settings (Sound/Message checkboxes) from Config_Setting.json
    LoadPatternAlertConfigFromJSON();
   // Seeding for Live Candle 
   // Get all TF
    CBarTimeSeriesDE *bts = m_BarTimeSeriesCollection.GetTimeseries(::Symbol());
    CArrayObj *series_list = (bts != NULL) ? bts.GetListSeries() : NULL;
    int tf_total = (series_list != NULL) ? series_list.Total() : 0;
    int pattern_count = ArraySize(m_pattern_types);
    int total_size = tf_total * pattern_count;
    ArrayResize(m_candle_pattern_last_seen, total_size);
    for(int ti = 0; ti < tf_total; ti++)
     for(int pi = 0; pi < pattern_count; pi++)
      m_candle_pattern_last_seen[ti * pattern_count + pi] = WRONG_VALUE;           
  }
 bool CGUIPannel::CreateTableCandlePatternSetting(const int x, const int y)
  { 
   // Step 1: Create Save Button ABOVE the table
    m_btn_save_pattern_config.MainPointer(m_tabs_main_setting_config);
    m_tabs_main_setting_config.AddToElementsArray(TAB_TAB_MAIN_SETTINGS_CONFIG_CANDLE_PATTERN, m_btn_save_pattern_config);
    m_btn_save_pattern_config.AutoXResizeMode(false);
    m_btn_save_pattern_config.XSize(80);
    m_btn_save_pattern_config.YSize(BTN_HEIGHT); //Define in GUIPannel_Define.mqh
    m_btn_save_pattern_config.IconFile(IMAGE_RESOURCE_BMP16_SAVE_PNG);
    if(!m_btn_save_pattern_config.CreateButton("Save", x+SETTING_BTN_SAVE_CANDLE_PATTERN_X_GAP, y+SETTING_BTN_SAVE_CANDLE_PATTERN_Y_GAP)) return false;
    CWndContainer::AddToElementsArray(WindowIdx(m_window_main), m_btn_save_pattern_config);
   
   // Step 2: Create Table BELOW button
    int table_y = y + SETTING_BTN_SAVE_CANDLE_PATTERN_Y_GAP + BTN_HEIGHT+SETTING_BTN_SAVE_CANDLE_PATTERN_Y_GAP;
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
    m_table_CandlePatternsSetting.TableSize(6, ArraySize(m_pattern_types));
    int widths[6]    = {135, 30, 20, 30, 30, 20};
    int img_x_off[6] = {0, 0, 7, 7, 7, 7};
    int img_y_off[6] = {0, 0, 3, 4, 4, 3};
    ENUM_ALIGN_MODE align[6] = {ALIGN_LEFT,ALIGN_CENTER,ALIGN_LEFT, ALIGN_LEFT,ALIGN_LEFT,ALIGN_LEFT};
    m_table_CandlePatternsSetting.ColumnsWidth(widths);
    m_table_CandlePatternsSetting.ImageXOffset(img_x_off);
    m_table_CandlePatternsSetting.ImageYOffset(img_y_off);
    m_table_CandlePatternsSetting.TextAlign(align);
   // ← Create BEFORE SetHeaderText
    if(!m_table_CandlePatternsSetting.CreateTable(x, table_y)) return false;
    m_table_CandlePatternsSetting.SetHeaderText(0, "Pattern");
    m_table_CandlePatternsSetting.SetHeaderText(1, "No");    
    m_table_CandlePatternsSetting.SetHeaderText(2, "");
    // Enable Sound Alert
     uint resource_indices_sound[] = {IMAGE_RESOURCE_BMP16_BELL_PNG};
     m_table_CandlePatternsSetting.SetHeaderText(3, "");     //Check box to enable sound alert
     m_table_CandlePatternsSetting.SetHeaderImage(3, resource_indices_sound);
    //Enable Message Alert
     uint resource_indices_message[] = {IMAGE_RESOURCE_BMP16_MESSAGE_PNG};
     m_table_CandlePatternsSetting.SetHeaderText(4, "");   //Check box to enable notification alert
     m_table_CandlePatternsSetting.SetHeaderImage(4, resource_indices_message);
     m_table_CandlePatternsSetting.SetHeaderText(5, "");
    //CWndContainer::AddToElementsArray(0, m_pattern_table);
    CWndContainer::AddToElementsArray(WindowIdx(m_window_main), m_table_CandlePatternsSetting);      
    return true;
  }
#endif // CGUIPANNEL_TABSETTINGCANDLEPATTERN_MQH
