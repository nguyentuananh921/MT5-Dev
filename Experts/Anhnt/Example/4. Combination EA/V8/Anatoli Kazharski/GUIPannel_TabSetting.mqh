//+------------------------------------------------------------------+
//|                                         GUIPannel_TabSetting.mqh |
//+------------------------------------------------------------------+
#ifndef CGUIPANNEL_TABSETTING_MQH
#define CGUIPANNEL_TABSETTING_MQH
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
 //For control at TAB_TAB_MAIN_SETTINGS_CONFIG_TOTAL of m_tabs_main
  //+------------------------------------------------------------------+
  //| Create a nested tab group for Settings tab config sections       |
  //+------------------------------------------------------------------+
  bool CGUIPannel::CreateTabSettingConfig(const int x_gap, const int y_gap)
   {
      string tabs_names[TAB_TAB_MAIN_SETTINGS_CONFIG_TOTAL] = {"Indicator", "Symbol TF", "Marker"};
      //--- Store the pointer to the parent control - nested inside m_tabs_main's Settings tab
        m_tabs_main_setting_config.MainPointer(m_tabs_main);
      //--- Properties
        m_tabs_main_setting_config.IsCenterText(true);
        m_tabs_main_setting_config.PositionMode(TABS_TOP);
        m_tabs_main_setting_config.AutoXResizeMode(true);
        m_tabs_main_setting_config.AutoYResizeMode(true);
        m_tabs_main_setting_config.AutoXResizeRightOffset(3);
        m_tabs_main_setting_config.AutoYResizeBottomOffset(3);
      //--- Add tabs with the specified properties
        for(int i = 0; i < TAB_TAB_MAIN_SETTINGS_CONFIG_TOTAL; i++)
          m_tabs_main_setting_config.AddTab(tabs_names[i], 100);
      //--- Create Tab before create other control element inside
        if(!m_tabs_main_setting_config.CreateTabs(x_gap, y_gap))
          return (false);
        m_tabs_main.AddToElementsArray(TAB_TAB_MAIN_SETTINGS, m_tabs_main_setting_config);
        CWndContainer::AddToElementsArray(WindowIdx(m_window_main), m_tabs_main_setting_config);
        return (true);
   }
  //For control at each tab m_tabs_main_setting_config
   //Tab Indicator TAB_TAB_MAIN_SETTINGS_CONFIG_INDICATOR
    // For TreeView Indicator m_treeview_indicator on the left TAB_TAB_MAIN_SETTINGS_CONFIG_INDICATOR m_tabs_main_setting_config
    bool CGUIPannel::CreateTreeView_Indicator(const int x_gap, const int y_gap)
     {
        m_treeview_indicator.MainPointer(m_tabs_main_setting_config);
        m_treeview_indicator.AutoXResizeMode(false);
        m_treeview_indicator.XSize(150);
        m_treeview_indicator.AutoYResizeMode(true);
        m_treeview_indicator.VisibleItemsTotal(15);
        m_treeview_indicator.LightsHover(true);
       //Create treeview
        if(!m_treeview_indicator.CreateTreeView(x_gap, y_gap)) return false;
       m_tabs_main_setting_config.AddToElementsArray(TAB_TAB_MAIN_SETTINGS_CONFIG_INDICATOR, m_treeview_indicator);
       CWndContainer::AddToElementsArray(WindowIdx(m_window_main), m_treeview_indicator);       
       return true;
     }
    void CGUIPannel::PopulateIndicatorTree(void)
      {
          string group_names[4] = {"Trend", "Oscillator", "Volumes", "Arrows"};
          ENUM_INDICATOR_GROUP group_values[4] = {INDICATOR_GROUP_TREND, INDICATOR_GROUP_OSCILLATOR, INDICATOR_GROUP_VOLUMES, INDICATOR_GROUP_ARROWS};

          SIndicatorCatalogItem catalog[];
          GetIndicatorCatalog(catalog);
          ArrayResize(m_group_tree_pos, 4); 
          for(int g = 0; g < 4; g++)
          {
            int root_li = m_treeview_indicator.ItemsTotal();
            m_group_tree_pos[g] = root_li;
            m_treeview_indicator.AddTreeItem(root_li,
                                            -1,                          // prev_node_list_index = -1 (root)
                                            group_names[g],
                                            IMAGE_RESOURCE_BMP16_ARROWRIGHT_BMP,
                                            g, 0,                        // item_index, node_level = 0
                                            0, 0, 0,
                                            true, true);                 // item_state, is_folder
            int k = 0;
            for(int i = 0; i < ArraySize(catalog); i++)
              {
                if(catalog[i].group != group_values[g]) continue;
                int child_li = m_treeview_indicator.ItemsTotal();
                m_treeview_indicator.AddTreeItem(child_li, root_li, catalog[i].name,
                                              IMAGE_RESOURCE_BMP16_ARROWRIGHT_BMP,
                                              k, 1, g, 0, 0, true, true);
                // --- KHÔNG còn gọi leaf.Index(...) nữa — lưu mapping riêng
                int sz = ArraySize(m_type_node_li);
                ArrayResize(m_type_node_li, sz + 1);
                ArrayResize(m_type_node_value, sz + 1);
                m_type_node_li[sz]    = child_li;
                m_type_node_value[sz] = catalog[i].type;
                k++;
              }
          }
      } 
    void CGUIPannel::SyncIndicatorTreeViewIcons(void)
      {
        if(m_IndicatorsCollection == NULL) return;
        CArrayObj *all = m_IndicatorsCollection.GetList();
        if(all == NULL) return;
        ENUM_INDICATOR applied[];
        int applied_count = 0;
        for(int i = 0; i < all.Total(); i++)
          {
          CIndicatorDE *ind = all.At(i);
          if(ind == NULL) continue;
          ENUM_INDICATOR t = ind.TypeIndicator();
          bool found = false;
          for(int j = 0; j < applied_count; j++)
              if(applied[j] == t) { found = true; break; }
          if(!found)
            {
              ArrayResize(applied, applied_count + 1);
              applied[applied_count++] = t;
            }
          }
        for(int i = 0; i < ArraySize(m_type_node_li); i++)
          {
          bool active = false;
          for(int j = 0; j < applied_count; j++)
              if(applied[j] == m_type_node_value[i]) { active = true; break; }
          CTreeItem *type_item = m_treeview_indicator.ItemPointer(m_type_node_li[i]);
          if(type_item != NULL)
              type_item.IconFile(active ? IMAGE_RESOURCE_BMP16_ARROWRIGHT_BLUE_BMP : IMAGE_RESOURCE_BMP16_ARROWRIGHT_BMP);
          if(active)
            {
              int group_li = m_treeview_indicator.ItemPrevNode(m_type_node_li[i]);
              CTreeItem *group_item = m_treeview_indicator.ItemPointer(group_li);
              if(group_item != NULL)
                group_item.IconFile(IMAGE_RESOURCE_BMP16_ARROWRIGHT_BLUE_BMP);
            }
          }
        m_treeview_indicator.Update(true);
      }
    //To Add Indicator
     // Builds the per-param layout for `type`. element_type is always carried
     // straight from Tang 1's schema (choices!="" -> E_COMBO_BOX) - Tang 2 does
     // not re-decide that fact, only how/where to render it. row/col/field_width
     // are explicitly curated per type below (this is the per-indicator layout
     // the user asked to control directly, not a blanket formula).
     int CGUIPannel::GetIndicatorGuiLayout(const ENUM_INDICATOR type, SIndicatorLayout &out[])
      {
        SIndicatorParam schema[];
        int total = GetIndicatorParamSchema(type, schema);
        ArrayResize(out, total);
        for(int i = 0; i < total; i++)
          {
            // --- Fallback default (used for any type not explicitly curated below):
            // --- 2-per-row pairing, matches the catalog's Period/Shift-style ordering.
            out[i].row          = i / 2;
            out[i].col          = i % 2;
            out[i].total_width  = INDICATOR_PARAM_LABEL_W + INDICATOR_PARAM_FIELD_W;
            out[i].field_width  = INDICATOR_PARAM_FIELD_W;
            out[i].element_type = (schema[i].choices != "") ? E_COMBO_BOX : E_TEXT_BOX;
          }
        switch(type)
          {
          //Format 
            //1. Indicator Parameter.
            //2. Row number.
            //3. Column Number.
            //4. Total Width.
            //5. Input Value for Parameter width
          case IND_MA:
            SetLayoutSlot(out,MA_PERIOD,         0, 0, INDICATOR_PARAM_LABEL_W + INDICATOR_PARAM_FIELD_W, INDICATOR_PARAM_FIELD_W);
            SetLayoutSlot(out,MA_SHIFT,          0, 1, INDICATOR_PARAM_LABEL_W + INDICATOR_PARAM_FIELD_W, INDICATOR_PARAM_FIELD_W);
            SetLayoutSlot(out,MA_METHOD,         1, 0, INDICATOR_PARAM_LABEL_W + INDICATOR_PARAM_FIELD_W, INDICATOR_PARAM_FIELD_W);  // combo - wider so the option text isn't clipped
            SetLayoutSlot(out,MA_APPLIED_PRICE,  1, 1, INDICATOR_PARAM_LABEL_W + INDICATOR_PARAM_FIELD_W, INDICATOR_PARAM_FIELD_W);  // combo - longest label drives the 180 total
            break;
          case IND_STDDEV:
            // Same shape as MA (Period/Shift/Method/Applied Price) - kept as its
            // own case (not a fallthrough) so each indicator stays independently
            // editable without touching any other type.
              SetLayoutSlot(out,MA_PERIOD,         0, 0, INDICATOR_PARAM_LABEL_W + INDICATOR_PARAM_FIELD_W, INDICATOR_PARAM_FIELD_W);
              SetLayoutSlot(out,MA_SHIFT,          0, 1, INDICATOR_PARAM_LABEL_W + INDICATOR_PARAM_FIELD_W, INDICATOR_PARAM_FIELD_W);
              SetLayoutSlot(out,MA_METHOD,         1, 0, INDICATOR_PARAM_LABEL_W + INDICATOR_PARAM_FIELD_W, INDICATOR_PARAM_FIELD_W);  // combo
              SetLayoutSlot(out,MA_APPLIED_PRICE,  1, 1, INDICATOR_PARAM_LABEL_W + INDICATOR_PARAM_FIELD_W, INDICATOR_PARAM_FIELD_W);  // combo
              break;
          case IND_ICHIMOKU:
            // Tenkan-sen / Kijun-sen / Senkou Span B - 3 unrelated periods,
            // one per row reads cleaner than pairing the 3rd alone on its own row.
            SetLayoutSlot(out,ICHIMOKU_TENKAN,    0, 0, INDICATOR_PARAM_LABEL_W + INDICATOR_PARAM_FIELD_W, INDICATOR_PARAM_FIELD_W);
            SetLayoutSlot(out,ICHIMOKU_KIJUN,     1, 0, INDICATOR_PARAM_LABEL_W + INDICATOR_PARAM_FIELD_W, INDICATOR_PARAM_FIELD_W);
            SetLayoutSlot(out,ICHIMOKU_SENKOU_B,  2, 0, INDICATOR_PARAM_LABEL_W + INDICATOR_PARAM_FIELD_W, INDICATOR_PARAM_FIELD_W);
            break;
          case IND_SAR:
            // Step / Maximum - not a Period+Shift pair, one per row reads cleaner.
              SetLayoutSlot(out,SAR_STEP,    0, 0, INDICATOR_PARAM_LABEL_W + INDICATOR_PARAM_FIELD_W, INDICATOR_PARAM_FIELD_W);
              SetLayoutSlot(out,SAR_MAXIMUM, 0, 1, INDICATOR_PARAM_LABEL_W + INDICATOR_PARAM_FIELD_W, INDICATOR_PARAM_FIELD_W);
              break;
          case IND_BANDS:
            SetLayoutSlot(out,BANDS_PERIOD,         0, 0, INDICATOR_PARAM_LABEL_W + INDICATOR_PARAM_FIELD_W, INDICATOR_PARAM_FIELD_W);
            SetLayoutSlot(out,BANDS_SHIFT,          0, 1, INDICATOR_PARAM_LABEL_W + INDICATOR_PARAM_FIELD_W, INDICATOR_PARAM_FIELD_W);
            SetLayoutSlot(out,BANDS_DEVIATION,      1, 0, INDICATOR_PARAM_LABEL_W + INDICATOR_PARAM_FIELD_W, INDICATOR_PARAM_FIELD_W);
            SetLayoutSlot(out,BANDS_APPLIED_PRICE,  1, 1, INDICATOR_PARAM_LABEL_W + INDICATOR_PARAM_FIELD_W, INDICATOR_PARAM_FIELD_W);  // combo
            break;
          case IND_ALLIGATOR:
            // 8 params would push a single column past the Add button (fixed at
            // 4-row height) - pair them 2-per-row like the catalog's natural
            // Jaw/Teeth/Lips period+shift grouping, same i/2,i%2 the fallback uses.
              SetLayoutSlot(out,JTL_JAW_PERIOD,     0, 0, INDICATOR_PARAM_LABEL_W + INDICATOR_PARAM_FIELD_W, INDICATOR_PARAM_FIELD_W);
              SetLayoutSlot(out,JTL_JAW_SHIFT,      0, 1, INDICATOR_PARAM_LABEL_W + INDICATOR_PARAM_FIELD_W, INDICATOR_PARAM_FIELD_W);
              SetLayoutSlot(out,JTL_TEETH_PERIOD,   1, 0, INDICATOR_PARAM_LABEL_W + INDICATOR_PARAM_FIELD_W, INDICATOR_PARAM_FIELD_W);
              SetLayoutSlot(out,JTL_TEETH_SHIFT,    1, 1, INDICATOR_PARAM_LABEL_W + INDICATOR_PARAM_FIELD_W, INDICATOR_PARAM_FIELD_W);
              SetLayoutSlot(out,JTL_LIPS_PERIOD,    2, 0, INDICATOR_PARAM_LABEL_W + INDICATOR_PARAM_FIELD_W, INDICATOR_PARAM_FIELD_W);
              SetLayoutSlot(out,JTL_LIPS_SHIFT,     2, 1, INDICATOR_PARAM_LABEL_W + INDICATOR_PARAM_FIELD_W, INDICATOR_PARAM_FIELD_W);
              SetLayoutSlot(out,JTL_METHOD,         3, 0, INDICATOR_PARAM_LABEL_W + INDICATOR_PARAM_FIELD_W, INDICATOR_PARAM_FIELD_W);  // combo
              SetLayoutSlot(out,JTL_APPLIED_PRICE,  3, 1, INDICATOR_PARAM_LABEL_W + INDICATOR_PARAM_FIELD_W, INDICATOR_PARAM_FIELD_W);  // combo
              break;
          case IND_GATOR:
            // Same 8-param shape as Alligator (Jaw/Teeth/Lips period+shift, Method,
            // Applied Price) - own case so it stays independently editable.
              SetLayoutSlot(out,JTL_JAW_PERIOD,     0, 0, INDICATOR_PARAM_LABEL_W + INDICATOR_PARAM_FIELD_W, INDICATOR_PARAM_FIELD_W);
              SetLayoutSlot(out,JTL_JAW_SHIFT,      0, 1, INDICATOR_PARAM_LABEL_W + INDICATOR_PARAM_FIELD_W, INDICATOR_PARAM_FIELD_W);
              SetLayoutSlot(out,JTL_TEETH_PERIOD,   1, 0, INDICATOR_PARAM_LABEL_W + INDICATOR_PARAM_FIELD_W, INDICATOR_PARAM_FIELD_W);
              SetLayoutSlot(out,JTL_TEETH_SHIFT,    1, 1, INDICATOR_PARAM_LABEL_W + INDICATOR_PARAM_FIELD_W, INDICATOR_PARAM_FIELD_W);
              SetLayoutSlot(out,JTL_LIPS_PERIOD,    2, 0, INDICATOR_PARAM_LABEL_W + INDICATOR_PARAM_FIELD_W, INDICATOR_PARAM_FIELD_W);
              SetLayoutSlot(out,JTL_LIPS_SHIFT,     2, 1, INDICATOR_PARAM_LABEL_W + INDICATOR_PARAM_FIELD_W, INDICATOR_PARAM_FIELD_W);
              SetLayoutSlot(out,JTL_METHOD,         3, 0, INDICATOR_PARAM_LABEL_W + INDICATOR_PARAM_FIELD_W, INDICATOR_PARAM_FIELD_W);  // combo
              SetLayoutSlot(out,JTL_APPLIED_PRICE,  3, 1, INDICATOR_PARAM_LABEL_W + INDICATOR_PARAM_FIELD_W, INDICATOR_PARAM_FIELD_W);  // combo
              break;
          case IND_ENVELOPES:
            // 5 params - 2-per-row keeps the form within the 4-row Add-button budget.
              SetLayoutSlot(out,ENVELOPES_PERIOD,         0, 0, INDICATOR_PARAM_LABEL_W + INDICATOR_PARAM_FIELD_W, INDICATOR_PARAM_FIELD_W);
              SetLayoutSlot(out,ENVELOPES_SHIFT,          0, 1, INDICATOR_PARAM_LABEL_W + INDICATOR_PARAM_FIELD_W, INDICATOR_PARAM_FIELD_W);
              SetLayoutSlot(out,ENVELOPES_METHOD,         2, 0, INDICATOR_PARAM_LABEL_W + INDICATOR_PARAM_FIELD_W, INDICATOR_PARAM_FIELD_W);  // combo
              SetLayoutSlot(out,ENVELOPES_APPLIED_PRICE,  2, 1, INDICATOR_PARAM_LABEL_W + INDICATOR_PARAM_FIELD_W, INDICATOR_PARAM_FIELD_W);  // combo
              SetLayoutSlot(out,ENVELOPES_DEVIATION_PCT,  1, 0, INDICATOR_PARAM_LABEL_W + INDICATOR_PARAM_FIELD_W, INDICATOR_PARAM_FIELD_W);  
              break;
          case IND_FRAMA:
            SetLayoutSlot(out,PSP_PERIOD,         0, 0, INDICATOR_PARAM_LABEL_W + INDICATOR_PARAM_FIELD_W, INDICATOR_PARAM_FIELD_W);
            SetLayoutSlot(out,PSP_SHIFT,          0, 1, INDICATOR_PARAM_LABEL_W + INDICATOR_PARAM_FIELD_W, INDICATOR_PARAM_FIELD_W);
            SetLayoutSlot(out,PSP_APPLIED_PRICE,  1, 0, INDICATOR_PARAM_LABEL_W + INDICATOR_PARAM_FIELD_W, INDICATOR_PARAM_FIELD_W);  // combo
            break;
          case IND_DEMA:
            // Same shape as FRAMA/TEMA (Period/Shift/Applied Price) - own case.
              SetLayoutSlot(out,PSP_PERIOD,         0, 0, INDICATOR_PARAM_LABEL_W + INDICATOR_PARAM_FIELD_W, INDICATOR_PARAM_FIELD_W);
              SetLayoutSlot(out,PSP_SHIFT,          0, 1, INDICATOR_PARAM_LABEL_W + INDICATOR_PARAM_FIELD_W, INDICATOR_PARAM_FIELD_W);
              SetLayoutSlot(out,PSP_APPLIED_PRICE,  1, 0, INDICATOR_PARAM_LABEL_W + INDICATOR_PARAM_FIELD_W, INDICATOR_PARAM_FIELD_W);  // combo
              break;
          case IND_TEMA:
            // Same shape as FRAMA/DEMA (Period/Shift/Applied Price) - own case.
              SetLayoutSlot(out,PSP_PERIOD,         0, 0, INDICATOR_PARAM_LABEL_W + INDICATOR_PARAM_FIELD_W, INDICATOR_PARAM_FIELD_W);
              SetLayoutSlot(out,PSP_SHIFT,          0, 1, INDICATOR_PARAM_LABEL_W + INDICATOR_PARAM_FIELD_W, INDICATOR_PARAM_FIELD_W);
              SetLayoutSlot(out,PSP_APPLIED_PRICE,  1, 0, INDICATOR_PARAM_LABEL_W + INDICATOR_PARAM_FIELD_W, INDICATOR_PARAM_FIELD_W);  // combo
              break;
          case IND_AMA:
            // 5 params - 2-per-row keeps the form within the 4-row Add-button budget.
              SetLayoutSlot(out,AMA_PERIOD,            0, 1, INDICATOR_PARAM_LABEL_W + INDICATOR_PARAM_FIELD_W, INDICATOR_PARAM_FIELD_W);
              SetLayoutSlot(out,AMA_FAST_EMA_PERIOD,   0, 0, INDICATOR_PARAM_LABEL_W + INDICATOR_PARAM_FIELD_W, INDICATOR_PARAM_FIELD_W);
              SetLayoutSlot(out,AMA_SLOW_EMA_PERIOD,   1, 0, INDICATOR_PARAM_LABEL_W + INDICATOR_PARAM_FIELD_W, INDICATOR_PARAM_FIELD_W);  // longest label ("Slow EMA Period") drives the 220 total
              SetLayoutSlot(out,AMA_SHIFT,             1, 1, INDICATOR_PARAM_LABEL_W + INDICATOR_PARAM_FIELD_W, INDICATOR_PARAM_FIELD_W);
              SetLayoutSlot(out,AMA_APPLIED_PRICE,     2, 0, INDICATOR_PARAM_LABEL_W + INDICATOR_PARAM_FIELD_W, INDICATOR_PARAM_FIELD_W);  // combo
              break;
          case IND_VIDYA:
            SetLayoutSlot(out,VIDYA_CMO_PERIOD,     0, 0, INDICATOR_PARAM_LABEL_W + INDICATOR_PARAM_FIELD_W, INDICATOR_PARAM_FIELD_W);
            SetLayoutSlot(out,VIDYA_EMA_PERIOD,     0, 1, INDICATOR_PARAM_LABEL_W + INDICATOR_PARAM_FIELD_W, INDICATOR_PARAM_FIELD_W);
            SetLayoutSlot(out,VIDYA_SHIFT,          1, 0, INDICATOR_PARAM_LABEL_W + INDICATOR_PARAM_FIELD_W, INDICATOR_PARAM_FIELD_W);
            SetLayoutSlot(out,VIDYA_APPLIED_PRICE,  1, 1, INDICATOR_PARAM_LABEL_W + INDICATOR_PARAM_FIELD_W, INDICATOR_PARAM_FIELD_W);  // combo
            break;
          // --- Single plain "Period" numeric field - same 1-param shape across all
          // --- of these, each kept as its own case (not grouped) so any one of
          // --- them can be retuned without touching the others. idx is always 0,
          // --- no named enum needed for a single unambiguous field.
          case IND_ADX:
            SetLayoutSlot(out,0, 0, 0, INDICATOR_PARAM_LABEL_W + INDICATOR_PARAM_FIELD_W, INDICATOR_PARAM_FIELD_W);
            break;
          case IND_ADXW:
            SetLayoutSlot(out,0, 0, 0, INDICATOR_PARAM_LABEL_W + INDICATOR_PARAM_FIELD_W, INDICATOR_PARAM_FIELD_W);
            break;
          case IND_DEMARKER:
            SetLayoutSlot(out,0, 0, 0, INDICATOR_PARAM_LABEL_W + INDICATOR_PARAM_FIELD_W, INDICATOR_PARAM_FIELD_W);
            break;
          case IND_RVI:
            SetLayoutSlot(out,0, 0, 0, INDICATOR_PARAM_LABEL_W + INDICATOR_PARAM_FIELD_W, INDICATOR_PARAM_FIELD_W);
            break;
          case IND_WPR:
            SetLayoutSlot(out,0, 0, 0, INDICATOR_PARAM_LABEL_W + INDICATOR_PARAM_FIELD_W, INDICATOR_PARAM_FIELD_W);
            break;
          case IND_TRIX:
            SetLayoutSlot(out,0, 0, 0, INDICATOR_PARAM_LABEL_W + INDICATOR_PARAM_FIELD_W, INDICATOR_PARAM_FIELD_W);
            break;
          case IND_ATR:
            SetLayoutSlot(out,0, 0, 0, INDICATOR_PARAM_LABEL_W + INDICATOR_PARAM_FIELD_W, INDICATOR_PARAM_FIELD_W);
            break;
          case IND_BEARS:
            SetLayoutSlot(out,0, 0, 0, INDICATOR_PARAM_LABEL_W + INDICATOR_PARAM_FIELD_W, INDICATOR_PARAM_FIELD_W);
            break;
          case IND_BULLS:
            SetLayoutSlot(out,0, 0, 0, INDICATOR_PARAM_LABEL_W + INDICATOR_PARAM_FIELD_W, INDICATOR_PARAM_FIELD_W);
            break;
          case IND_MFI:
            SetLayoutSlot(out,0, 0, 0, INDICATOR_PARAM_LABEL_W + INDICATOR_PARAM_FIELD_W, INDICATOR_PARAM_FIELD_W);
            break;
          case IND_MOMENTUM:
            SetLayoutSlot(out,PP_PERIOD,         0, 0, INDICATOR_PARAM_LABEL_W + INDICATOR_PARAM_FIELD_W, INDICATOR_PARAM_FIELD_W);
            SetLayoutSlot(out,PP_APPLIED_PRICE,  1, 0, INDICATOR_PARAM_LABEL_W + INDICATOR_PARAM_FIELD_W, INDICATOR_PARAM_FIELD_W);  // combo
            break;
          case IND_CCI:
            // Same shape as RSI/Momentum (Period + Applied Price) - own case.
              SetLayoutSlot(out,PP_PERIOD,         0, 0, INDICATOR_PARAM_LABEL_W + INDICATOR_PARAM_FIELD_W, INDICATOR_PARAM_FIELD_W);
              SetLayoutSlot(out,PP_APPLIED_PRICE,  1, 0, INDICATOR_PARAM_LABEL_W + INDICATOR_PARAM_FIELD_W, INDICATOR_PARAM_FIELD_W);  // combo
              break;
          case IND_RSI:
            // Same shape as CCI/Momentum (Period + Applied Price) - own case.
              SetLayoutSlot(out,PP_PERIOD,         0, 0, INDICATOR_PARAM_LABEL_W + INDICATOR_PARAM_FIELD_W, INDICATOR_PARAM_FIELD_W);
              SetLayoutSlot(out,PP_APPLIED_PRICE,  1, 0, INDICATOR_PARAM_LABEL_W + INDICATOR_PARAM_FIELD_W, INDICATOR_PARAM_FIELD_W);  // combo
              break;
          case IND_MACD:
            SetLayoutSlot(out,ESP_FAST_EMA,       0, 0, INDICATOR_PARAM_LABEL_W + INDICATOR_PARAM_FIELD_W, INDICATOR_PARAM_FIELD_W);
            SetLayoutSlot(out,ESP_SLOW_EMA,       1, 0, INDICATOR_PARAM_LABEL_W + INDICATOR_PARAM_FIELD_W, INDICATOR_PARAM_FIELD_W);
            SetLayoutSlot(out,ESP_SIGNAL,         0, 1, INDICATOR_PARAM_LABEL_W + INDICATOR_PARAM_FIELD_W, INDICATOR_PARAM_FIELD_W);
            SetLayoutSlot(out,ESP_APPLIED_PRICE,  1, 1, INDICATOR_PARAM_LABEL_W + INDICATOR_PARAM_FIELD_W, INDICATOR_PARAM_FIELD_W);  // combo
            break;
          case IND_OSMA:
            // Same shape as MACD (Fast/Slow EMA Period, Signal Period, Applied
            // Price) - own case.
              SetLayoutSlot(out,ESP_FAST_EMA,       0, 0, INDICATOR_PARAM_LABEL_W + INDICATOR_PARAM_FIELD_W, INDICATOR_PARAM_FIELD_W);
              SetLayoutSlot(out,ESP_SLOW_EMA,       1, 0, INDICATOR_PARAM_LABEL_W + INDICATOR_PARAM_FIELD_W, INDICATOR_PARAM_FIELD_W);
              SetLayoutSlot(out,ESP_SIGNAL,         0, 1, INDICATOR_PARAM_LABEL_W + INDICATOR_PARAM_FIELD_W, INDICATOR_PARAM_FIELD_W);
              SetLayoutSlot(out,ESP_APPLIED_PRICE,  2, 0, INDICATOR_PARAM_LABEL_W + INDICATOR_PARAM_FIELD_W, INDICATOR_PARAM_FIELD_W);  // combo
              break;
          case IND_STOCHASTIC:
            // 5 params - 2-per-row keeps the form within the 4-row Add-button budget.
              SetLayoutSlot(out,STOCH_K_PERIOD,     0, 0, INDICATOR_PARAM_LABEL_W + INDICATOR_PARAM_FIELD_W, INDICATOR_PARAM_FIELD_W);
              SetLayoutSlot(out,STOCH_D_PERIOD,     1, 0, INDICATOR_PARAM_LABEL_W + INDICATOR_PARAM_FIELD_W, INDICATOR_PARAM_FIELD_W);
              SetLayoutSlot(out,STOCH_SLOWING,      2, 0, INDICATOR_PARAM_LABEL_W + INDICATOR_PARAM_FIELD_W, INDICATOR_PARAM_FIELD_W);
              SetLayoutSlot(out,STOCH_METHOD,       0, 1, INDICATOR_PARAM_LABEL_W + INDICATOR_PARAM_FIELD_W, INDICATOR_PARAM_FIELD_W);  // combo
              SetLayoutSlot(out,STOCH_PRICE_FIELD,  1, 1, INDICATOR_PARAM_LABEL_W + INDICATOR_PARAM_FIELD_W, INDICATOR_PARAM_FIELD_W);  // combo
            break;
          case IND_FORCE:
            SetLayoutSlot(out,FORCE_PERIOD,           0, 0, INDICATOR_PARAM_LABEL_W + INDICATOR_PARAM_FIELD_W, INDICATOR_PARAM_FIELD_W);
            SetLayoutSlot(out,FORCE_METHOD,           1, 0, INDICATOR_PARAM_LABEL_W + INDICATOR_PARAM_FIELD_W, INDICATOR_PARAM_FIELD_W);  // combo
            SetLayoutSlot(out,FORCE_APPLIED_VOLUME,   1, 1, INDICATOR_PARAM_LABEL_W + INDICATOR_PARAM_FIELD_W, INDICATOR_PARAM_FIELD_W);  // combo - "Applied Volume" drives the 210 total
            break;
          case IND_CHAIKIN:
            SetLayoutSlot(out,CHAIKIN_FAST_MA_PERIOD,  0, 0, INDICATOR_PARAM_LABEL_W + INDICATOR_PARAM_FIELD_W, INDICATOR_PARAM_FIELD_W);
            SetLayoutSlot(out,CHAIKIN_SLOW_MA_PERIOD,  1, 0, INDICATOR_PARAM_LABEL_W + INDICATOR_PARAM_FIELD_W, INDICATOR_PARAM_FIELD_W);
            SetLayoutSlot(out,CHAIKIN_METHOD,          2, 0, INDICATOR_PARAM_LABEL_W + INDICATOR_PARAM_FIELD_W, INDICATOR_PARAM_FIELD_W);  // combo
            SetLayoutSlot(out,CHAIKIN_APPLIED_VOLUME,  3, 0, INDICATOR_PARAM_LABEL_W + INDICATOR_PARAM_FIELD_W, INDICATOR_PARAM_FIELD_W);  // combo
            break;
          // --- Single combo "Applied Volume" field - same 1-param shape across all
          // --- of these, each kept as its own case (not grouped). idx is always 0,
          // --- no named enum needed for a single unambiguous field.
          case IND_OBV:
            SetLayoutSlot(out,0, 0, 0, INDICATOR_PARAM_LABEL_W + INDICATOR_PARAM_FIELD_W, INDICATOR_PARAM_FIELD_W);
            break;
          case IND_AD:
            SetLayoutSlot(out,0, 0, 0, INDICATOR_PARAM_LABEL_W + INDICATOR_PARAM_FIELD_W, INDICATOR_PARAM_FIELD_W);
            break;
          case IND_VOLUMES:
            SetLayoutSlot(out,0, 0, 0, INDICATOR_PARAM_LABEL_W + INDICATOR_PARAM_FIELD_W, INDICATOR_PARAM_FIELD_W);
            break;
          // --- IND_AO, IND_AC, IND_BWMFI, IND_FRACTALS have 0 params (total=0,
          // --- the loop in ShowIndicatorParameterForm never executes) - no case needed.
          default:
            break; // default pairing is fine
          }
        return total;
      }
     // =====================================================================
     // --- Params tab: up to INDICATOR_PARAM_SLOTS_MAX (8) label+field pairs,
     // --- laid out as 2 columns x 4 rows. Each slot has BOTH a CTextEdit (plain
     // --- numeric params) and a CComboBox (enum-like params) at the same spot -
     // --- ShowIndicatorParameterForm() shows exactly one of the two per slot,
     // --- based on whether that param has choices in the schema.
     // =====================================================================  
     bool CGUIPannel::CreateAddIndicatorParaInfor(const int x_gap, const int y_gap)
      {
        const int default_x = x_gap;
        const int default_y = y_gap;
       for(int i = 0; i < INDICATOR_PARAM_SLOTS_MAX; i++)
        {
          m_param_labels[i].MainPointer(m_tabs_main_setting_config);
          m_tabs_main_setting_config.AddToElementsArray(TAB_TAB_MAIN_SETTINGS_CONFIG_INDICATOR, m_param_labels[i]);
          if(!m_param_labels[i].CreateTextLabel("", default_x, default_y)) return false;
          CWndContainer::AddToElementsArray(WindowIdx(m_window_main), m_param_labels[i]);

          m_param_edits[i].MainPointer(m_tabs_main_setting_config);
          m_tabs_main_setting_config.AddToElementsArray(TAB_TAB_MAIN_SETTINGS_CONFIG_INDICATOR, m_param_edits[i]);
          m_param_edits[i].XSize(INDICATOR_PARAM_FIELD_W);
          // --- Inner CTextBox defaults its LOCAL x-offset to the outer box's x_size at
          // --- creation time unless told otherwise BEFORE CreateTextEdit() - confirmed via
          // --- debug log (inner canvas sitting ~90px right of the outer frame after resize).
           m_param_edits[i].GetTextBoxPointer().XGap(1);
           if(!m_param_edits[i].CreateTextEdit("", default_x + INDICATOR_PARAM_LABEL_W, default_y)) return false;
           CWndContainer::AddToElementsArray(WindowIdx(m_window_main), m_param_edits[i]);

           m_param_combo[i].MainPointer(m_tabs_main_setting_config);
           m_tabs_main_setting_config.AddToElementsArray(TAB_TAB_MAIN_SETTINGS_CONFIG_INDICATOR, m_param_combo[i]);
           m_param_combo[i].XSize(INDICATOR_PARAM_FIELD_W);
           m_param_combo[i].YSize(20);
           m_param_combo[i].ItemsTotal(7);          // room for the largest choice list (PRICE_CHOICES)
          // --- CButton inside CComboBox defaults to XSize=80 at XGap=80 unless explicitly
          // --- told otherwise BEFORE CreateComboBox() - mirrors how CTable's own combo usage
          // --- configures it. Without this the button/listview end up outside the narrow canvas.
           m_param_combo[i].GetButtonPointer().XGap(1);
           m_param_combo[i].GetButtonPointer().XSize(INDICATOR_PARAM_FIELD_W);
           m_param_combo[i].GetButtonPointer().LabelYGap(4);
           m_param_combo[i].GetButtonPointer().IconYGap(3);
           if(!m_param_combo[i].CreateComboBox("", default_x + INDICATOR_PARAM_LABEL_W, default_y)) return false;
           CWndContainer::AddToElementsArray(WindowIdx(m_window_main), m_param_combo[i]);
          // --- Do NOT call Hide() here - CompletedGUI() (called after this function)
          // --- runs FormAvailableElementsArray() which only includes VISIBLE elements
          // --- in m_available_elements[]. Hiding early means MOUSE_MOVE events never
          // --- reach the combo button later (even after Show()), so the dropdown arrow
          // --- click silently does nothing. ShowIndicatorParameterForm() manages
          // --- show/hide correctly AFTER CompletedGUI has already registered everything.
        }
       //For Button Add
        m_btn_add_indicator.MainPointer(m_tabs_main_setting_config);
        m_tabs_main_setting_config.AddToElementsArray(TAB_TAB_MAIN_SETTINGS_CONFIG_INDICATOR, m_btn_add_indicator);
        m_btn_add_indicator.AutoXResizeMode(false);
        m_btn_add_indicator.XSize(80);
        m_btn_add_indicator.IconFile(IMAGE_RESOURCE_BMP16_ADD_GREEN_PNG);            
        bool created = m_btn_add_indicator.CreateButton("Add", x_gap, y_gap + INDICATOR_PARAM_ROWS * 30 + 10);
        if(!created) return false;
        CWndContainer::AddToElementsArray(WindowIdx(m_window_main), m_btn_add_indicator);
       //For Button Save
        m_btn_save_indicator.MainPointer(m_tabs_main_setting_config);
        m_tabs_main_setting_config.AddToElementsArray(TAB_TAB_MAIN_SETTINGS_CONFIG_INDICATOR, m_btn_save_indicator);
        m_btn_save_indicator.AutoXResizeMode(false);
        m_btn_save_indicator.XSize(80);
        m_btn_save_indicator.IconFile(IMAGE_RESOURCE_BMP16_SAVE_PNG);          
        bool created_save = m_btn_save_indicator.CreateButton("Save", x_gap + 85, y_gap + INDICATOR_PARAM_ROWS * 30 + 10);
        if(!created_save) return false;
        CWndContainer::AddToElementsArray(WindowIdx(m_window_main), m_btn_save_indicator);
        for(int i = 0; i < INDICATOR_PARAM_SLOTS_MAX; i++)
         {
          m_param_labels[i].Update(true);
          m_param_edits[i].Update(true);
         }
        m_btn_add_indicator.Update(true);
        m_btn_save_indicator.Update(true);
       return true;
      }
     // =====================================================================
     // --- Called from OnEvent when a Type-level tree node is clicked
     // =====================================================================
     void CGUIPannel::ShowIndicatorParameterForm(const ENUM_INDICATOR type, const int type_li)
      {
       m_current_param_type    = type;
       m_current_param_type_li = type_li;

       SIndicatorParam schema[];
       int total = GetIndicatorParamSchema(type, schema);
       // --- Layer 2 layout - decided BEFORE we touch a single control, separate
       // --- from Layer 1's data schema. Drives both position AND which control renders.
        SIndicatorLayout layout[];
        GetIndicatorGuiLayout(type, layout);
       // --- x_gap offsets right of the 150px indicator tree; y_gap from the tab's top.
        const int x_gap = PARAM_FORM_X, y_gap = PARAM_FORM_Y;
        for(int i = 0; i < INDICATOR_PARAM_SLOTS_MAX; i++)
         {
          if(i < total)
           {
            int x = x_gap + layout[i].col * INDICATOR_PARAM_COL_WIDTH;
            int y = y_gap + layout[i].row * 30;
            // --- Reposition label/edit/combo to this type's layout slot. Moving()
            // --- reads the CANVAS's own XGap/YGap (not just the element's), and
            // --- skips repositioning hidden elements by default - see CElement::Moving().
             m_param_labels[i].XGap(x); m_param_labels[i].CanvasPointer().XGap(x);
             m_param_labels[i].YGap(y); m_param_labels[i].CanvasPointer().YGap(y);
             m_param_labels[i].LabelText(schema[i].name);
             m_param_labels[i].Show();
             m_param_labels[i].Moving();
            // --- Field starts after (total_width - field_width) px of label room.
            // --- Keeping total_width equal across a type's rows is what makes the
            // --- field line up at the same right edge regardless of label length.
             int fx = x + (layout[i].total_width - layout[i].field_width);
             if(layout[i].element_type == E_COMBO_BOX)
              {
                string parts[];
                int n = StringSplit(schema[i].choices, '|', parts);
                m_param_combo[i].GetListViewPointer().Rebuilding(n);
                for(int p = 0; p < n; p++)
                  m_param_combo[i].SetValue(p, parts[p]);
                int def_idx = (int)StringToInteger(schema[i].default_value);
                if(def_idx >= 0 && def_idx < n) m_param_combo[i].SelectItem(def_idx);
                // --- SetValue()/Rebuilding() default redraw=false - they only store
                // --- the data, they never paint it. Same trap as CSplitContainer's
                // --- separator: must force an element-level Update(true) (-> Draw())
                // --- or the dropdown list stays visually blank even though it has items.
                 m_param_combo[i].GetListViewPointer().Update(true);
                // --- XSize() alone never touches the canvas bitmap (logical field
                // --- only) - same trap as CSplitContainer's panel1. Must also resize
                // --- the canvas + the internal button to actually change width on screen.
                 int cw = layout[i].field_width;
                 m_param_combo[i].XSize(cw);
                 m_param_combo[i].CanvasPointer().XSize(cw);
                 m_param_combo[i].CanvasPointer().Resize(cw, m_param_combo[i].CanvasPointer().YSize());
                // --- Use built-in ChangeSize to properly resize the button and its image group gap (dropdown arrow position)
                 m_param_combo[i].GetButtonPointer().ChangeSize(cw, m_param_combo[i].GetButtonPointer().YSize());
                // --- ComboBox.mqh's CreateButton() computes IconXGap ONCE at creation
                // --- time as (x_size-18), using whatever x_size the button had THEN
                // --- (90, from INDICATOR_PARAM_FIELD_W) - it never re-tracks later
                // --- resizes. Left stale, the dropdown arrow icon stays pinned at the
                // --- OLD x=72 regardless of how narrow/wide the button becomes now,
                // --- which is what made the box look like it had no closed right edge.
                // --- Recompute it here using the Library's own formula every resize.
                 m_param_combo[i].GetButtonPointer().IconXGap(cw - 18);
                // --- Also resize the dropdown list view to match the combo width
                 m_param_combo[i].GetListViewPointer().ChangeSize(cw, m_param_combo[i].GetListViewPointer().YSize());
                 m_param_combo[i].XGap(fx); m_param_combo[i].CanvasPointer().XGap(fx);
                 m_param_combo[i].YGap(y);  m_param_combo[i].CanvasPointer().YGap(y);
                 m_param_combo[i].Draw();
                 m_param_combo[i].Show();
                 m_param_combo[i].Moving();
                 m_param_edits[i].Hide();
              }
             else
              {
                // --- is_size_adjustment=false: SetValue() defaults to TRUE, which
                // --- calls CorrectSize() and shrinks the box to fit the value text
                // --- (a 1-digit default like "8" collapses the box to almost
                // --- nothing, looking like a stray checkbox icon). Keep our explicit
                // --- per-layout field_width instead.
                 m_param_edits[i].SetValue(schema[i].default_value, false);
                 int ew = layout[i].field_width;
                 m_param_edits[i].XSize(ew);
                 m_param_edits[i].CanvasPointer().XSize(ew);
                 m_param_edits[i].CanvasPointer().Resize(ew, m_param_edits[i].CanvasPointer().YSize());
                // --- Use built-in ChangeSize to properly resize the inner CTextBox canvas, area width, and visible width
                 m_param_edits[i].GetTextBoxPointer().ChangeSize(ew, m_param_edits[i].GetTextBoxPointer().YSize());
                 m_param_edits[i].XGap(fx); m_param_edits[i].CanvasPointer().XGap(fx);
                 m_param_edits[i].YGap(y);  m_param_edits[i].CanvasPointer().YGap(y);
                 m_param_edits[i].Draw();
                // --- The visible VALUE text is painted by the inner CTextBox
                // --- (m_edit), which has its own separate canvas - NOT by the outer
                // --- CTextEdit's Draw()/Update(). Normally SetValue()'s default
                // --- CorrectSize() path repaints it as a side effect of resizing;
                // --- since we pass is_size_adjustment=false (to stop the auto-shrink
                // --- bug), we must explicitly force that inner repaint ourselves,
                // --- or the box keeps showing whatever value the PREVIOUSLY selected
                // --- indicator left behind (confirmed: stale "0.02"/"0.2" from PSAR
                // --- still showing after switching to MA).
                 m_param_edits[i].GetTextBoxPointer().Update(true);
                 m_param_edits[i].Update(true);
                 m_param_edits[i].Show();
                 m_param_edits[i].Moving();
                 m_param_combo[i].Hide();
              }
           }
          else
           {
            m_param_labels[i].Hide();
            m_param_edits[i].Hide();
            m_param_combo[i].Hide();
           }
          m_param_labels[i].Update(true);
          m_param_edits[i].Update(true);
          m_param_combo[i].GetButtonPointer().Update(true);
         }   
      }

    //Helper to set layout slot
     void CGUIPannel::SetLayoutSlot(SIndicatorLayout &out[], int idx, int r, int c, int tw, int fw)
      {
        out[idx].row         = r;
        out[idx].col         = c;
        out[idx].total_width = tw;
        out[idx].field_width = fw;
      } 
     // Hides all param-form slots. Called after any ShowTabElements() that overrides our Hide().
     void CGUIPannel::HideParamSlots(void)
      {
        for(int i = 0; i < INDICATOR_PARAM_SLOTS_MAX; i++)
        {
          m_param_labels[i].Hide();
          m_param_edits[i].Hide();
          m_param_combo[i].Hide();
        }     
      } 
    // =====================================================================
    // --- "Add" button click handler — converts text fields to MqlParam[]
    // =====================================================================
    void CGUIPannel::OnClickAddIndicator(void)
     {      
      SIndicatorParam schema[];
      int total = GetIndicatorParamSchema(m_current_param_type, schema);      
      if(total == 0) return;

      MqlParam params[];
      ArrayResize(params, total);
      for(int i = 0; i < total; i++)
       {
         params[i].type = schema[i].data_type;
         if(schema[i].choices != "")
           {
            // --- Enum param: read back the SELECTED TEXT, then let the Library's own
            // --- Xxx-ByDescription() (CommonDELib.mqh) resolve it to the real MQL5
            // --- enum value - no combo-row/native-value arithmetic anywhere.
             string parts[];
             int n = ::StringSplit(schema[i].choices, '|', parts);
             int sel = (int)m_param_combo[i].GetListViewPointer().SelectedItemIndex();
             string sel_text = (sel >= 0 && sel < n) ? parts[sel] : "";
             if(schema[i].choices == PRICE_CHOICES)
                params[i].integer_value = (long)AppliedPriceByDescription(sel_text);
             else if(schema[i].choices == CALCULATION_METHOD_CHOICES)
                params[i].integer_value = (long)AveragingMethodByDescription(sel_text);
             else if(schema[i].choices == VOLUME_CHOICES)
                params[i].integer_value = (long)AppliedVolumeByDescription(sel_text);
             else if(schema[i].choices == STOCH_PRICE_CHOICES)
                params[i].integer_value = (long)StochPriceByDescription(sel_text);
            }
         else if(schema[i].data_type == TYPE_DOUBLE)
           {
            params[i].double_value = StringToDouble(m_param_edits[i].GetValue());
           }
         else
           {
            params[i].integer_value = (long)StringToInteger(m_param_edits[i].GetValue());
           }
       }
      AddIndicatorInstance(m_current_param_type_li, m_current_param_type, params);
     }
    // --- GUI "Add" button: indicator creation itself now lives in CTimeSeriesEngine
    // --- (Tang 1, PureData) - GUIPannel only forwards the call, then updates its own
    // --- display state (TreeView icon + m_table_indicator), which is its Tang 2 job.
    void CGUIPannel::AddIndicatorInstance(const int type_li, const ENUM_INDICATOR type, MqlParam &params[])
     {
        if(m_time_series_engine == NULL || m_IndicatorsCollection == NULL) return;
        // --- Source-side duplicate guard (README 5c): the template set stays unique HERE,
        // --- at the only place templates enter Layer 1 - not hidden later by a display dedup.
        if(m_IndicatorsCollection.TemplateExists(type, params))
          {
          ::Print(__FUNCTION__, " > rejected: this template already exists");
          return;
          }
        if(!m_time_series_engine.AddNewIndicatorToAllSeries(type, params)) return;
        SyncIndicatorTreeViewIcons();   // full sweep + Update(true)

        // --- Append exactly ONE row for the new template (README 5c - no rescan, no rebuild).
        // --- The engine appends to the collection, so the new instance for the current chart
        // --- is the LAST one in the (symbol,TF)-filtered list.
        string sym = ::Symbol();
        ENUM_TIMEFRAMES tf = (ENUM_TIMEFRAMES)::ChartPeriod(0);
        CArrayObj *list = m_IndicatorsCollection.GetListIndBySymbol(sym);
        list = CTimeseriesSelect::ByIndicatorProperty(list, INDICATOR_PROP_TIMEFRAME, tf, EQUAL);
        if(list == NULL || list.Total() == 0) return;
        CIndicatorDE *indicator = list.At(list.Total() - 1);
        int row = ArraySize(m_table_indicator_ptrs);
        if(row > 0)                      // an empty table already owns one physical row - reuse it for row 0
          m_table_indicator.AddRow(row, true);   // redraw=true - recalculate visible-area size, see
                                                    // README/BugNote 2026-07-14 black/smeared overflow bug
        ArrayResize(m_table_indicator_names, row + 1);
        ArrayResize(m_table_indicator_ptrs,  row + 1);
        ArrayResize(m_settings_cache_state,  row + 1);
        SetIndicatorTableRow(row, indicator);
        m_table_indicator.Update(true);
     }
    //For m_table_indicator in TAB_TAB_MAIN_SETTINGS_CONFIG_INDICATOR m_tabs_main_setting_config
     //List all indicator in template
     bool CGUIPannel::CreateTabbleIndicator(const int x, const int y)
      {
       m_table_indicator.MainPointer(m_tabs_main_setting_config);
       m_tabs_main_setting_config.AddToElementsArray(TAB_TAB_MAIN_SETTINGS_CONFIG_INDICATOR, m_table_indicator);
       //Resize Properties
        m_table_indicator.AutoXResizeMode(true);
        m_table_indicator.AutoXResizeRightOffset(3);
        m_table_indicator.AutoYResizeMode(true);
        m_table_indicator.AutoYResizeBottomOffset(3);
       //Table Properties
        m_table_indicator.ShowHeaders(true);
        m_table_indicator.SelectableRow(true);
        m_table_indicator.LightsHover(true);
        m_table_indicator.IsSortMode(true);
       // --- 7 columns: col 0 merges the old icon-only "show on T3" column with the
       // --- "Indicator" text column (CTCell renders image+text independently, click
       // --- detection is scoped to the image's own pixel width - see Table.mqh
       // --- CheckPressedCheckBox/CheckPressedButton). Buy/Sell/Show/Sound/Message shift
       // --- down by 1. Sound/Message added 2026-07-17: per-template opt-in for a sound
       // --- alert + Journal message when that template gets a new Signal - wiring TBD,
       // --- this only adds the checkbox UI columns for now.
        m_table_indicator.TableSize(7, 20);
        int widths[7]    = {180, 70, 40, 40, 40, 40, 40};
        int img_x_off[7] = {3,   0,  10, 10, 10, 10, 10};
        int img_y_off[7] = {3,   0,  3,  3,  3,  3,  3};
        ENUM_ALIGN_MODE align[7] = {ALIGN_LEFT, ALIGN_LEFT, ALIGN_LEFT, ALIGN_LEFT, ALIGN_LEFT, ALIGN_LEFT, ALIGN_LEFT};
        m_table_indicator.ColumnsWidth(widths);
        m_table_indicator.ImageXOffset(img_x_off);
        m_table_indicator.ImageYOffset(img_y_off);
        m_table_indicator.TextAlign(align);

        if(!m_table_indicator.CreateTable(x, y)) return false;
        //Set Header text
          m_table_indicator.SetHeaderText(0, "Indicator");
          m_table_indicator.SetHeaderText(1, "Group");
        //Checkbox to show or hide on Layer 3 (Chart)
          m_table_indicator.SetHeaderText(2, "Buy");
          m_table_indicator.SetHeaderText(3, "Sell");
          m_table_indicator.SetHeaderText(4, "Show");
          m_table_indicator.SetHeaderText(5, "Sound");
          m_table_indicator.SetHeaderText(6, "Message");

       CWndContainer::AddToElementsArray(WindowIdx(m_window_main), m_table_indicator);
       return true;
      } 
     // --- Template view of Layer 1 (see README 5c): one row per template. The row set changes
     // --- ONLY via LoadConfigurationFromJSON (initial build here), AddIndicatorInstance (appends its
     // --- own row) and OnClickRemoveIndicator (DeleteRow) - so no dedup and no periodic rebuild.
     // --- By the Layer-1 invariant every series carries the same template set, hence the current
     // --- chart's (symbol,TF) instance list IS the template list, one instance per template.
     void CGUIPannel::RefreshTableIndicator(void)
      {
       if(m_IndicatorsCollection == NULL) return;
       string sym = ::Symbol();
       ENUM_TIMEFRAMES tf = (ENUM_TIMEFRAMES)::ChartPeriod(0);

       CArrayObj *list = m_IndicatorsCollection.GetListIndBySymbol(sym);
       list = CTimeseriesSelect::ByIndicatorProperty(list, INDICATOR_PROP_TIMEFRAME, tf, EQUAL);
       int count = (list == NULL) ? 0 : list.Total();
       // --- Row set already matches the template count: re-point the BORROWED per-row
       // --- pointers at the CURRENT chart's instances (they change on CHARTCHANGE) and
       // --- dirty-refresh the per-chart "Show" column only - no structural change, no flicker.
       if(count == ArraySize(m_table_indicator_ptrs) && count > 0)
         {
          SIndicatorCatalogItem catalog[];
          GetIndicatorCatalog(catalog);
          for(int i = 0; i < count; i++)
           {
            CIndicatorDE *indicator = list.At(i);
            if(indicator == NULL) continue;
            // --- Table may be sorted (IsSortMode) - Col 0's label text travels WITH its row
            // --- through a sort, so match against it to find the CURRENT physical row
            // --- instead of trusting collection order == row index.
            string label = "        " + BuildIndicatorLabel(indicator, catalog);
            int row = -1;
            for(int r = 0; r < count; r++)
              if(m_table_indicator.GetValue(0, r) == label) { row = r; break; }
            if(row < 0) continue;
            m_table_indicator_ptrs[row]  = indicator;
            m_table_indicator_names[row] = indicator.ShortName();
           }
          RefreshIndicatorTableShowColumn();
          return;
         }
       // --- Structural (re)build - initial fill after LoadConfigurationFromJSON, or safety on mismatch
       if(count == 0)
         {
          if(ArraySize(m_table_indicator_ptrs) == 0) return; // already showing the empty state - leave the table alone
          m_table_indicator.DeleteAllRows();
          m_table_indicator.AddRow(0);   // safety row: Library bug - DeleteAllRows does not reset m_item_index_focus
          ArrayResize(m_table_indicator_names, 0);
          ArrayResize(m_table_indicator_ptrs, 0);
          ArrayResize(m_settings_cache_state, 0);
          m_table_indicator.Update(true);
          return;
         }
        m_table_indicator.DeleteAllRows();
       // --- redraw=true on the LAST row only: AddRow() only recalculates the table's visible-area
       // --- size (CTable::RecalculateAndResizeTable) when told to - skipping it on every row and
       // --- doing it once at the end avoids the black/smeared row-overflow bug (README/BugNote
       // --- 2026-07-14) without paying the recalculation cost on every single row.
        for(int i = 0; i < count - 1; i++)   // DeleteAllRows leaves one physical row behind
         m_table_indicator.AddRow(i, i == count - 2);
        ArrayResize(m_table_indicator_names, count);
        ArrayResize(m_table_indicator_ptrs, count);
        ArrayResize(m_settings_cache_state, count);
        for(int row = 0; row < count; row++)
           SetIndicatorTableRow(row, list.At(row));
        m_table_indicator.Update(true);
      }
     // --- Fill every cell of one template row + the parallel arrays (names/ptrs/state cache)
     void CGUIPannel::SetIndicatorTableRow(const int row, CIndicatorDE *indicator)
      {
        if(indicator == NULL) return;
        uint delete_icon[]   = {IMAGE_RESOURCE_BMP16_CLOSE_RED_PNG};
        uint chk[]           = {IMAGE_RESOURCE_BMP16_CHECKBOX_ON_G_PNG, IMAGE_RESOURCE_BMP16_CHECKBOX_OFF_G_PNG};
        uint show_on_chart[] = {IMAGE_RESOURCE_BMP16_CHECKBOX_ON_G_PNG, IMAGE_RESOURCE_BMP16_CHECKBOX_OFF_G_PNG};
        string group_names[] = {"Trend", "Oscillator", "Volumes", "Arrows"};

        SIndicatorCatalogItem catalog[];
        GetIndicatorCatalog(catalog);
        string label = BuildIndicatorLabel(indicator, catalog);
        // --- Col 0: red Close (delete) icon + label - click detection covers the icon only
        // --- (Table.mqh CheckPressedButton scopes it to the image pixel width)
        m_table_indicator.CellType(0, row, CELL_BUTTON);
        m_table_indicator.SetImages(0, row, delete_icon);
        m_table_indicator.ChangeImage(0, row, 0);
        m_table_indicator.SetValue(0, row, "        " + label);   // leading spaces clear the icon
        // --- Col 1: group name
        int group = (int)indicator.Group();
        string gname = (group >= 0 && group < 4) ? group_names[group] : "Other";
        m_table_indicator.SetValue(1, row, "  " + gname);
        // --- Col 2/3: Buy / Sell signal filters (default OFF - markers are opt-in per template;
        // --- TemplateBuySellFor reads these checkboxes live, toggles rewrite the bridge file)
        m_table_indicator.CellType(2, row, CELL_CHECKBOX);
        m_table_indicator.SetImages(2, row, chk);
        m_table_indicator.ChangeImage(2, row, 1);
        m_table_indicator.CellType(3, row, CELL_CHECKBOX);
        m_table_indicator.SetImages(3, row, chk);
        m_table_indicator.ChangeImage(3, row, 1);
        // --- Col 4: "shown on the CURRENT chart" checkbox
        int state = IsIndicatorShownOnChart(indicator) ? INDICATOR_SHOW_ON_CHART : INDICATOR_HIDE_ON_CHART;
        m_table_indicator.CellType(4, row, CELL_CHECKBOX);
        m_table_indicator.SetImages(4, row, show_on_chart);
        m_table_indicator.ChangeImage(4, row, state);
        // --- Col 5/6: Sound / Message opt-in per template (default OFF, same pattern as
        // --- Buy/Sell) - checkbox UI only for now, wiring to actually play/print on a new
        // --- Signal is still TBD (2026-07-17).
        m_table_indicator.CellType(5, row, CELL_CHECKBOX);
        m_table_indicator.SetImages(5, row, chk);
        m_table_indicator.ChangeImage(5, row, 1);
        m_table_indicator.CellType(6, row, CELL_CHECKBOX);
        m_table_indicator.SetImages(6, row, chk);
        m_table_indicator.ChangeImage(6, row, 1);

        m_table_indicator_names[row] = indicator.ShortName();
        m_table_indicator_ptrs[row]  = indicator;   // BORROWED - CIndicatorsCollection owns it
        m_settings_cache_state[row]  = state;
      }
     // --- Per-chart part of the Settings table (col 4 "Show") - dirty-check, no structural change
     void CGUIPannel::RefreshIndicatorTableShowColumn(void)
      {
       bool any_changed = false;
       for(int row = 0; row < ArraySize(m_table_indicator_ptrs); row++)
         {
          int state = IsIndicatorShownOnChart(m_table_indicator_ptrs[row]) ? INDICATOR_SHOW_ON_CHART : INDICATOR_HIDE_ON_CHART;
          if(state == m_settings_cache_state[row]) continue;
          m_settings_cache_state[row] = state;
          m_table_indicator.ChangeImage(4, row, state);
          m_table_indicator.BackColor(4, row, clrWhite, true);   // force this one cell to repaint
          any_changed = true;
         }
       if(any_changed)
         m_table_indicator.Update(false);
      }
     // =====================================================================
     // --- Col 4 checkbox: Tang 2 controls Tang 3 only - never touches PureData.
     // --- The table already auto-toggled the icon before sending this event, so
     // --- SelectedImageIndex(4,row) tells us the state to APPLY (0=show, 1=hide).
     // --- Matched by ind.Handle(), not by name - two instances of the same type
     // --- with different params can share the same native chart-assigned name.
     // --- Detaches every chart line currently representing this indicator (Layer 3 mirror,
     // --- handle = join key). Shared by the per-row Hide toggle, per-row Remove, and
     // --- OnDeinitEvent's full sweep (BugNote 2026-07-18: Layer 1 indicators left shown
     // --- on chart - BBands/PSAR/AMA/hand-added MAs - were never detached on final EA
     // --- removal, only the SignalMarkers overlay was; this closes that gap for every row).
     void CGUIPannel::DetachIndicatorFromChart(CIndicatorDE *indicator)
      {
       if(indicator == NULL) return;
       CChartObj *chart = m_chart_obj_collection.GetChart(::ChartID());
       if(chart == NULL) return;
       for(int win = chart.WindowsTotal() - 1; win >= 0; win--)
        {
         CChartWnd *wnd = chart.GetWindowByNum(win);
         if(wnd == NULL) continue;
         for(int i = wnd.IndicatorsTotal() - 1; i >= 0; i--)
           {
            CWndInd *wnd_ind = wnd.GetIndicatorByIndex(i);
            if(wnd_ind != NULL && LineRepresentsIndicator(wnd_ind.Handle(), indicator))
               ChartIndicatorDelete(0, win, wnd_ind.Name());
           }
        }
      }
     // --- Does this Layer 3 line represent this Layer 1 instance?
     // --- Fast path: shared slot - only lines WE attached (ChartIndicatorAdd with our own
     // --- handle). A HAND-ADDED line is a SEPARATE terminal instance with its own slot
     // --- (proven 18:58 log: line handle=17 vs owned=18 for identical SAR(0.05,0.20)),
     // --- so fall back to the template identity: type+params via IndicatorParameters.
     // --- The line's slot stays readable forever because nobody ever releases it.
     bool CGUIPannel::LineRepresentsIndicator(const int line_handle, CIndicatorDE *indicator)
      {
       if(line_handle == INVALID_HANDLE || indicator == NULL) return false;
       if(line_handle == indicator.Handle())
         {
          // --- DEBUG LineRepresentsIndicator FAST-MATCH - removed 2026-07-14, fired every row every tick
          //::Print("DEBUG CGUIPannel::LineRepresentsIndicator FAST-MATCH line_handle=", line_handle,
          //        " own_handle=", indicator.Handle());
          return true;
         }
       ENUM_INDICATOR type;
       MqlParam params[];
       if(IndicatorParameters(line_handle, type, params) < 0) return false;
       if(type != indicator.TypeIndicator()) return false;
       MqlParam own_params[];
       indicator.GetMqlParams(own_params);
       bool eq = IsEqualMqlParamArrays(own_params, params);
       return eq;
      }
     // --- True when the CURRENT chart displays this indicator instance. The Layer 3 mirror
     // --- (CChartObjCollection -> CWndInd) stores the real slot handle, and MQL5 slots are
     // --- program-wide: the line of an instance Layer 1 owns carries Layer 1's own handle
     // --- number - the handle is the exact join key (names have different formats:
     // --- chart line "SAR(0.05,0.2)" vs CIndicatorDE::ShortName "SAR(BTCUSDm,M1)").
     bool CGUIPannel::IsIndicatorShownOnChart(CIndicatorDE *indicator)
      {
       if(indicator == NULL) return false;
       CChartObj *chart = m_chart_obj_collection.GetChart(::ChartID());
       if(chart == NULL) return false;
       for(int win = 0; win < chart.WindowsTotal(); win++)
        {
          CChartWnd *wnd = chart.GetWindowByNum(win);
          if(wnd == NULL) continue;
          for(int k = wnd.IndicatorsTotal() - 1; k >= 0; k--)
            {
            CWndInd *wnd_ind = wnd.GetIndicatorByIndex(k);
            if(wnd_ind != NULL && LineRepresentsIndicator(wnd_ind.Handle(), indicator))
              {
                // --- DEBUG IsIndicatorShownOnChart - removed 2026-07-14, fired every row every tick
                //::Print("DEBUG IsIndicatorShownOnChart indicator_handle=", indicator.Handle(),
                //        " -> MATCHED line '", wnd_ind.Name(), "' handle=", wnd_ind.Handle());
                return true;
              }
            }
        }
       return false;
      }
     void CGUIPannel::OnClickToggleShowIndicatorOnChart(const string sname, const int row)
      {
        if(row < 0 || row >= ArraySize(m_table_indicator_ptrs)) return;
        CIndicatorDE *ind = m_table_indicator_ptrs[row];
        if(ind == NULL) return;

        int new_state = (int)m_table_indicator.SelectedImageIndex(4, row);
        int subwindows = (int)ChartGetInteger(0, CHART_WINDOWS_TOTAL);
        if(new_state == INDICATOR_HIDE_ON_CHART)   // Hide: remove from chart, PureData/handle stay intact
          DetachIndicatorFromChart(ind);
        else // Show: re-attach using the stored handle
          {
          int sub_window = (ind.Group() == INDICATOR_GROUP_TREND) ? 0 : subwindows;
          ChartIndicatorAdd(0, sub_window, ind.Handle());
          }
        ChartRedraw();
      }
     // --- Col 2/3 checkboxes: per-template Buy/Sell signal filters. The table already
     // --- flipped the checkbox image before this handler fires; BuildAndWriteSignalBridge
     // --- reads the checkbox states live via TemplateBuySellFor, so a toggle just needs the
     // --- watermark rewound so the very next write is a full, immediate rewrite.
     void CGUIPannel::OnClickToggleBuySignal(const string sname, const int row)
      {
       m_bridge_writer.ResetSignalBridge();
      }
     void CGUIPannel::OnClickToggleSellSignal(const string sname, const int row)
      {
       m_bridge_writer.ResetSignalBridge();
      }
     void CGUIPannel::OnClickSaveIndicators(void)
      {
        SaveGUIConfigToJSON();
      } 
    //+------------------------------------------------------------------+
    //| Called ONCE right after the initial RefreshIndicatorTable() (see |
    //| OnInitEvent) - pulls the Buy/Sell state CTimeSeriesEngine::       |
    //| LoadConfigurationFromJSON() cached while loading indicators_config|
    //| .json and applies it to the matching m_table_indicator rows, so a |
    //| saved Buy/Sell setting survives an EA restart instead of          |
    //| resetting to OFF.                                                 |
    //+------------------------------------------------------------------+
    // --- Also applies Sound/Message (col 5/6) despite the name - kept the original name to avoid
    // --- touching its one call site's context; extended in place 2026-07-17.
    void CGUIPannel::ApplyLoadedIndicatorBuySell(void)
     {
      if(m_time_series_engine == NULL) return;
      string types[], param_keys[];
      bool buys[], sells[], sounds[], messages[];
      m_time_series_engine.GetLoadedTemplateSettings(types, param_keys, buys, sells, sounds, messages);
      if(ArraySize(types) == 0) return;

      SIndicatorCatalogItem catalog[];
      GetIndicatorCatalog(catalog);

      int rows = ArraySize(m_table_indicator_ptrs);
      bool any_changed = false;
      for(int row = 0; row < rows; row++)
        {
          CIndicatorDE *ind = m_table_indicator_ptrs[row];
          if(ind == NULL) continue;
          string type_key, params_key;
          BuildTemplateMatchKey(ind, catalog, type_key, params_key);
          for(int q = 0; q < ArraySize(types); q++)
            {
            if(types[q] != type_key || param_keys[q] != params_key) continue;
            m_table_indicator.ChangeImage(2, row, buys[q]     ? 0 : 1);
            m_table_indicator.ChangeImage(3, row, sells[q]    ? 0 : 1);
            m_table_indicator.ChangeImage(5, row, sounds[q]   ? 0 : 1);
            m_table_indicator.ChangeImage(6, row, messages[q] ? 0 : 1);
            any_changed = true;
            break;
            }
        }
      if(any_changed) m_table_indicator.Update(true);
     }
    //+------------------------------------------------------------------+
    //| Build the Col2 display label ("ShortName  (params)") for an      |
    //| indicator - shared by the row-rebuild path and the row-identity  |
    //| key used to keep per-tick updates aligned after a user sort.     |
    //+------------------------------------------------------------------+
    string CGUIPannel::BuildIndicatorLabel(CIndicatorDE *ind, SIndicatorCatalogItem &catalog[])
     {
      string short_name = "";
      for(int c = 0; c < ::ArraySize(catalog); c++)
          if(catalog[c].type == ind.TypeIndicator()) { short_name = catalog[c].name; break; }
      if(short_name == "") short_name = ind.GetTypeDescription();

      // --- Same schema the Add form uses (README: Tang 1 metadata). schema[i].choices
      // marks an enum-like param (Method, Applied Price, ...) - stored integer_value is
      // always the REAL MQL5 enum value (never a bare combo index), so decode it back to
      // text via the matching CommonDELib.mqh XxxDescription() - dispatched by comparing
      // choices against the 4 known constants, no separate "kind" needed.
      SIndicatorParam schema[];
      GetIndicatorParamSchema(ind.TypeIndicator(), schema);

      MqlParam mql_params[];
      ind.GetMqlParams(mql_params);
      string pvalues = "";
      for(int i = 0; i < ::ArraySize(mql_params); i++)
        {
          if(i > 0) pvalues += ", ";
          string choices = (i < ::ArraySize(schema)) ? schema[i].choices : "";
          if(choices == PRICE_CHOICES)
            pvalues += AppliedPriceDescription((ENUM_APPLIED_PRICE)mql_params[i].integer_value);
          else if(choices == CALCULATION_METHOD_CHOICES)
            pvalues += AveragingMethodDescription((ENUM_MA_METHOD)mql_params[i].integer_value);
          else if(choices == VOLUME_CHOICES)
            pvalues += AppliedVolumeDescription((ENUM_APPLIED_VOLUME)mql_params[i].integer_value);
          else if(choices == STOCH_PRICE_CHOICES)
            pvalues += StochPriceDescription((ENUM_STO_PRICE)mql_params[i].integer_value);
          else if(mql_params[i].type == TYPE_DOUBLE)
            pvalues += ::DoubleToString(mql_params[i].double_value, 2);
          else
            pvalues += ::IntegerToString((int)mql_params[i].integer_value);
        }
      return short_name + (pvalues != "" ? "  (" + pvalues + ")" : "");
     }
    //+------------------------------------------------------------------+
    //| Builds the SAME (type, params-as-text) key CTimeSeriesEngine::   |
    //| SaveConfigurationToJSON writes/LoadConfigurationFromJSON parses -|
    //| NOT BuildIndicatorLabel's pvalues (that rounds doubles to 2      |
    //| decimals for display; the saved file uses 8, so matching against|
    //| it would silently fail for any non-integer param).               |
    //+------------------------------------------------------------------+
    void CGUIPannel::BuildTemplateMatchKey(CIndicatorDE *ind, SIndicatorCatalogItem &catalog[], string &type_key, string &params_key)
     {
      type_key = "";
      for(int c = 0; c < ArraySize(catalog); c++)
          if(catalog[c].type == ind.TypeIndicator()) { type_key = catalog[c].name; break; }

      SIndicatorParam schema[];
      GetIndicatorParamSchema(ind.TypeIndicator(), schema);
      MqlParam params[];
      ind.GetMqlParams(params);

      params_key = "";
      for(int p = 0; p < ArraySize(params); p++)
        {
          if(p > 0) params_key += ",";
          string choices = (p < ArraySize(schema)) ? schema[p].choices : "";
          if(choices == PRICE_CHOICES)
            params_key += AppliedPriceDescription((ENUM_APPLIED_PRICE)params[p].integer_value);
          else if(choices == CALCULATION_METHOD_CHOICES)
            params_key += AveragingMethodDescription((ENUM_MA_METHOD)params[p].integer_value);
          else if(choices == VOLUME_CHOICES)
            params_key += AppliedVolumeDescription((ENUM_APPLIED_VOLUME)params[p].integer_value);
          else if(choices == STOCH_PRICE_CHOICES)
            params_key += StochPriceDescription((ENUM_STO_PRICE)params[p].integer_value);
          else if(params[p].type == TYPE_DOUBLE)
            params_key += ::DoubleToString(params[p].double_value, 8);
          else
            params_key += ::IntegerToString((int)params[p].integer_value);
        }
     }
    // --- Resolve a Layer 3 line to the Layer 1 instance (current symbol/TF) it represents,
    // --- or NULL when the line is foreign. Same fast/slow paths as LineRepresentsIndicator.
    CIndicatorDE *CGUIPannel::OwnedInstanceOfLine(const int line_handle)
     {
      if(line_handle == INVALID_HANDLE || m_time_series_engine == NULL) return NULL;
      CIndicatorDE *owned = m_time_series_engine.GetIndicatorByHandle(line_handle);
      if(owned != NULL) return owned;
      for(int row = 0; row < ArraySize(m_table_indicator_ptrs); row++)
         if(LineRepresentsIndicator(line_handle, m_table_indicator_ptrs[row]))
            return m_table_indicator_ptrs[row];
      return NULL;
     }
    // --- Col 0 button: Tang 1 control - removes this whole template (same type+params,
    // --- regardless of symbol/timeframe) from PureData. Does NOT touch the JSON file
    // --- yet (that part - persisting the removal so it doesn't come back on next
    // --- EA restart - is still open, deferred from the earlier discussion).
    void CGUIPannel::OnClickRemoveIndicator(const string sname, const int row)
     {
      if(row < 0 || row >= ArraySize(m_table_indicator_ptrs)) return;
      // ref_indicator is BORROWED (CIndicatorsCollection owns it) - it lives inside the
      // same list the loop below deletes from, so it may dangle partway through.
       CIndicatorDE *ref_indicator = m_table_indicator_ptrs[row];
       if(ref_indicator == NULL || m_IndicatorsCollection == NULL || m_time_series_engine == NULL) return;
      //--- Audit line: template removals are destructive and reachable from several paths
      //--- (X icon, HandleChartIndicatorChange) - always log who goes and from which row
       ::Print(__FUNCTION__, " > row=", row, " '", m_table_indicator_names[row],
              "' ref handle=", ref_indicator.Handle());

       CArrayObj *list = m_IndicatorsCollection.GetList();
       if(list == NULL) return;
      // --- Capture ref_indicator's type/params into plain local values NOW, before the
      // --- loop deletes it (it matches its own template) - never dereference it after.
       ENUM_INDICATOR ref_type = ref_indicator.TypeIndicator();
       MqlParam ref_params[];
       ref_indicator.GetMqlParams(ref_params);
       for(int i = list.Total() - 1; i >= 0; i--)
        {
         // indicator is BORROWED (CIndicatorsCollection owns it via 'list' FreeMode)
         CIndicatorDE *indicator = list.At(i);
         if(indicator == NULL || indicator.TypeIndicator() != ref_type) continue;

         // --- Same template = same type + same params, regardless of symbol/TF
         MqlParam params[];
         indicator.GetMqlParams(params);
         if(!IsEqualMqlParamArrays(params, ref_params)) continue;

         // --- Release the Signal FIRST: CSignalsCollection borrows this indicator's
         // --- pointer (m_indicator_list[] + the signal's own m_indicator), so deleting
         // --- the indicator before its signal would leave both dangling.
         m_time_series_engine.GetSignalsCollection().DeleteSignal(indicator);

         // --- Detach from chart if currently shown (Layer 3 mirror, handle = join key).
         // --- The slot itself dies exactly once, in ~CIndicatorDE via list.Delete below.
         DetachIndicatorFromChart(indicator);
         list.Delete(i);   // CArrayObj FreeMode -> ~CIndicatorDE -> IndicatorRelease(handle)
        }
      // --- Drop exactly this row (Library CTable::DeleteRow shifts the rest up) and keep
      // --- the parallel arrays aligned. No DeleteAllRows here (README 5a/5c).
       int rows_after = ArraySize(m_table_indicator_ptrs) - 1;
       for(int r = row; r < rows_after; r++)
        {
         m_table_indicator_names[r] = m_table_indicator_names[r + 1];
         m_table_indicator_ptrs[r]  = m_table_indicator_ptrs[r + 1];
         m_settings_cache_state[r]  = m_settings_cache_state[r + 1];
        }
      ArrayResize(m_table_indicator_names, rows_after);
      ArrayResize(m_table_indicator_ptrs,  rows_after);
      ArrayResize(m_settings_cache_state,  rows_after);
      if(rows_after == 0)
        {
         // CTable::DeleteRow never shrinks below one physical row, and SetImages rejects an
         // empty array (no API to strip a cell's icons) - so add a freshly CellInitialize'd
         // blank row first, then delete the old row 0 that still carries the delete/checkbox
         // icons. The blank row shifts up and becomes the single empty survivor.
         m_table_indicator.AddRow(1);
         m_table_indicator.DeleteRow(0, true);
         m_table_indicator.Update(true);
        }
      else
         m_table_indicator.DeleteRow(row, true);

      SetValuesToTableIndicatorSymbolTFValue();
      SyncIndicatorTreeViewIcons();
      ChartRedraw();
     } 
   //Tab Symbol TF TAB_TAB_MAIN_SETTINGS_CONFIG_SYMBOL_TF
    // --- Re-evaluates col 0's icon (delete vs start) for every row - called after a real
    // --- symbol/TF chart change, since which row counts as "current" just moved.
    void CGUIPannel::SyncTableSymbolTFSettingCurrentChartIcon(void)  
     {
       uint delete_icon[] = {IMAGE_RESOURCE_BMP16_CLOSE_RED_PNG};
       uint start_icon[]  = {IMAGE_RESOURCE_BMP16_START_BMP};
       int rows = (int)m_table_indicator_SymbolTFSeting.RowsTotal();
       for(int row = 0; row < rows; row++)
         {
          string sym = m_table_indicator_SymbolTFSeting.GetValue(0, row);
         StringTrimLeft(sym);
         if(sym == "") continue;
         string tf = m_table_indicator_SymbolTFSeting.GetValue(1, row);
         StringTrimLeft(tf);
         if(IsCurrentChartSymbolTFRow(sym, tf))
            m_table_indicator_SymbolTFSeting.SetImages(0, row, start_icon);
         else
            m_table_indicator_SymbolTFSeting.SetImages(0, row, delete_icon);
         m_table_indicator_SymbolTFSeting.ChangeImage(0, row, 0);
        }
       m_table_indicator_SymbolTFSeting.Update(true);
     }
     // --- Fill every cell of one Symbol+TF row - Buy/Sell default OFF (opt-in, same convention
     // --- as m_table_indicator's col 2/3)
     void CGUIPannel::SetTableSymbolTFSettingRow(const int row, const string sym, const string tf_text)
      {
       uint delete_icon[] = {IMAGE_RESOURCE_BMP16_CLOSE_RED_PNG};
       uint start_icon[]  = {IMAGE_RESOURCE_BMP16_START_BMP};
       uint chk[]         = {IMAGE_RESOURCE_BMP16_CHECKBOX_ON_G_PNG, IMAGE_RESOURCE_BMP16_CHECKBOX_OFF_G_PNG};

       // --- Col 0: Symbol label + icon - red Close (delete), EXCEPT the row matching the current
       // --- chart's own symbol/TF, which gets the "start" icon and is not deletable (this EA
       // --- instance depends on that series existing - see IsCurrentChartSymbolTFRow).
        bool is_current = IsCurrentChartSymbolTFRow(sym, tf_text);
        m_table_indicator_SymbolTFSeting.CellType(0, row, CELL_BUTTON);
        if(is_current)
          m_table_indicator_SymbolTFSeting.SetImages(0, row, start_icon);
        else
          m_table_indicator_SymbolTFSeting.SetImages(0, row, delete_icon);
        m_table_indicator_SymbolTFSeting.ChangeImage(0, row, 0);
        m_table_indicator_SymbolTFSeting.SetValue(0, row, "        " + sym);
       // --- Col 1: TF
        m_table_indicator_SymbolTFSeting.SetValue(1, row, "  " + tf_text);
       // --- Col 2/3: Buy / Sell
        m_table_indicator_SymbolTFSeting.CellType(2, row, CELL_CHECKBOX);
        m_table_indicator_SymbolTFSeting.SetImages(2, row, chk);
        m_table_indicator_SymbolTFSeting.ChangeImage(2, row, 1);
        m_table_indicator_SymbolTFSeting.CellType(3, row, CELL_CHECKBOX);
        m_table_indicator_SymbolTFSeting.SetImages(3, row, chk);
        m_table_indicator_SymbolTFSeting.ChangeImage(3, row, 1);
      }
     // --- Save button click - both m_btn_save_indicator and m_btn_save_SymbolTF write the SAME
     // --- indicators_config.json (single source of truth, no separate Buy/Sell file) - see
     // --- SaveGUIConfigToJSON().
     void CGUIPannel::OnClickSaveSymbolTF(void)
      {
       SaveGUIConfigToJSON();
      }
    // =====================================================================
    // --- Symbol TF sub-tab: flat list of every Symbol+TF pair currently tracked by
    // --- m_BarTimeSeriesCollection (same source as m_treeview_SymbolTF), each row with
    // --- its own Buy/Sell checkboxes and a red delete icon. Save button writes the
    // --- current Buy/Sell state to JSON.
    bool CGUIPannel::CreateTableSymbolTFSetting(const int x, const int y)
     {
      //--- Note (own row, on top): Delete/Buy/Sell edits here only take effect in
      //--- indicators_config.json - the running EA keeps today's live series/indicators
      //--- until it's restarted. Colored to stand out from the Save button below it.
        m_label_symboltf_note.MainPointer(m_tabs_main_setting_config);
        m_tabs_main_setting_config.AddToElementsArray(TAB_TAB_MAIN_SETTINGS_CONFIG_SYMBOL_TF, m_label_symboltf_note);
      // --- CTextLabel::InitializeProperties defaults XSize to 100px when unset - too narrow for
      // --- this sentence (and CTextLabel never checks AutoXResizeMode, unlike CTable/CTreeView),
      // --- so XSize must be set explicitly, wide enough to clear the tab's own right edge.
        m_label_symboltf_note.XSize(M_TABS_MAIN_WIDTH - x - 5);
        m_label_symboltf_note.Font("Calibri Bold");   // CElement::DrawText hardcodes FW_NORMAL - request a bold face by name instead
        if(!m_label_symboltf_note.CreateTextLabel("Delete Symbol+TF here apply after the EA is restarted", x, y)) return false;
        m_label_symboltf_note.LabelColor(clrDodgerBlue);
        m_label_symboltf_note.Draw();
      CWndContainer::AddToElementsArray(WindowIdx(m_window_main), m_label_symboltf_note);

      //--- Save button, same convention as m_btn_save_indicator
        m_btn_save_SymbolTF.MainPointer(m_tabs_main_setting_config);
        m_tabs_main_setting_config.AddToElementsArray(TAB_TAB_MAIN_SETTINGS_CONFIG_SYMBOL_TF, m_btn_save_SymbolTF);
        m_btn_save_SymbolTF.AutoXResizeMode(false);
        m_btn_save_SymbolTF.XSize(80);
        m_btn_save_SymbolTF.IconFile(IMAGE_RESOURCE_BMP16_SAVE_PNG);
        if(!m_btn_save_SymbolTF.CreateButton("Save", x, y + SYMBOLTF_BTN_Y)) return false;
        CWndContainer::AddToElementsArray(WindowIdx(m_window_main), m_btn_save_SymbolTF);
      //--- Table: col 0 merges the red delete icon with the Symbol label (same CTable
      //--- click-detection trick as m_table_indicator col 0 - see Table.mqh CheckPressedButton).
        m_table_indicator_SymbolTFSeting.MainPointer(m_tabs_main_setting_config);
        m_tabs_main_setting_config.AddToElementsArray(TAB_TAB_MAIN_SETTINGS_CONFIG_SYMBOL_TF, m_table_indicator_SymbolTFSeting);
        m_table_indicator_SymbolTFSeting.AutoXResizeMode(true);
        m_table_indicator_SymbolTFSeting.AutoXResizeRightOffset(3);
        m_table_indicator_SymbolTFSeting.AutoYResizeMode(true);
        m_table_indicator_SymbolTFSeting.AutoYResizeBottomOffset(3);
        m_table_indicator_SymbolTFSeting.ShowHeaders(true);
        m_table_indicator_SymbolTFSeting.SelectableRow(true);
        m_table_indicator_SymbolTFSeting.LightsHover(true);
        m_table_indicator_SymbolTFSeting.IsSortMode(true);
        m_table_indicator_SymbolTFSeting.TableSize(4, 10);
        int widths[4]    = {150, 70, 40, 40};
        int img_x_off[4] = {3,   0,  10, 10};
        int img_y_off[4] = {3,   0,  3,  3};
        ENUM_ALIGN_MODE align[4] = {ALIGN_LEFT, ALIGN_LEFT, ALIGN_LEFT, ALIGN_LEFT};
        m_table_indicator_SymbolTFSeting.ColumnsWidth(widths);
        m_table_indicator_SymbolTFSeting.ImageXOffset(img_x_off);
        m_table_indicator_SymbolTFSeting.ImageYOffset(img_y_off);
        m_table_indicator_SymbolTFSeting.TextAlign(align);

        if(!m_table_indicator_SymbolTFSeting.CreateTable(x, y + SYMBOLTF_TABLE_Y)) return false;
        m_table_indicator_SymbolTFSeting.SetHeaderText(0, "Symbol");
        m_table_indicator_SymbolTFSeting.SetHeaderText(1, "TF");
        m_table_indicator_SymbolTFSeting.SetHeaderText(2, "Buy");   
        m_table_indicator_SymbolTFSeting.SetHeaderText(3, "Sell");
      // --- Collapse the TableSize() padding down to a single blank baseline row -
      // --- PopulateTableSymbolTFSetting() reuses that one row for its very first entry.
      m_table_indicator_SymbolTFSeting.DeleteAllRows();

      CWndContainer::AddToElementsArray(WindowIdx(m_window_main), m_table_indicator_SymbolTFSeting);
      return true;
     }
    // --- Checkbox click stub (col 2 = Buy, col 3 = Sell) - the table already auto-toggled the
    // --- icon before this event fires (see Table.mqh CheckPressedCheckBox), so no manual image
    // --- flip needed here. Intentionally empty for now - no Tang 1 trading data model exists
    // --- yet to apply this to (see PopulateTableSymbolTFSetting note); wire real behavior here
    // --- once that's decided.
    void CGUIPannel::OnCheckTableSymbolTFSetting(const string sym, const string tf_text, const int row, const int col)
     {
      
     }
    // --- Incremental sync with m_treeview_SymbolTF's own data source (m_BarTimeSeriesCollection) -
    // --- called every time PopulateSymbolTFTree() runs (init + real symbol/TF change), same as the
    // --- treeview. Purely ADDITIVE: only appends pairs not already present as a row - never
    // --- DeleteAllRows()/rebuilds, so a user-deleted row stays deleted. Real "stop tracking" on
    // --- delete is follow-up work once the Library gets a RemoveSeries()-style API (BugNote/2026-07-15).
    void CGUIPannel::PopulateTableSymbolTFSetting(void)
     {
      if(m_BarTimeSeriesCollection == NULL) return;

      int mw_total = ::SymbolsTotal(true);
      for(int i = 0; i < mw_total; i++)
       {
        string sym_name = ::SymbolName(i, true);
        CBarTimeSeriesDE *bts = m_BarTimeSeriesCollection.GetTimeseries(sym_name);
        CArrayObj *list = (bts != NULL) ? bts.GetListSeries() : NULL;
        int tf_cnt = (list != NULL) ? list.Total() : 0;
        for(int k = 0; k < tf_cnt; k++)
         {
          CBarSeriesDE *s = bts.GetSeriesByIndex((uchar)k);
          if(s == NULL) continue;
          string tf_text = TimeframeDescription(s.Timeframe());
          if(HasTableSymbolTFSettingRow(sym_name, tf_text)) continue;

          int row = (int)m_table_indicator_SymbolTFSeting.RowsTotal();
          string first_col0 = m_table_indicator_SymbolTFSeting.GetValue(0, 0);
          StringTrimLeft(first_col0);
          bool placeholder_only = (row == 1 && first_col0 == "");
          if(placeholder_only)
             row = 0;   // reuse the blank baseline row left by DeleteAllRows()
          else
             m_table_indicator_SymbolTFSeting.AddRow(row, false);
          SetTableSymbolTFSettingRow(row, sym_name, tf_text);
         }
       }
      m_table_indicator_SymbolTFSeting.Update(true);
     }
    // --- True when (sym, tf_text) already has a row (trimmed match against col0/col1 text)
    bool CGUIPannel::HasTableSymbolTFSettingRow(const string sym, const string tf_text)
     {
      int rows = (int)m_table_indicator_SymbolTFSeting.RowsTotal();
      for(int row = 0; row < rows; row++)
        {
        string s = m_table_indicator_SymbolTFSeting.GetValue(0, row);
        StringTrimLeft(s);
        if(s != sym) continue;
        string t = m_table_indicator_SymbolTFSeting.GetValue(1, row);
        StringTrimLeft(t);
        if(t == tf_text) return true;
        }
      return false;
     }
    // --- Called ONCE right after the initial PopulateTableSymbolTFSetting() (see CreateGUIPannel) -
    // --- pulls the Buy/Sell state CTimeSeriesEngine::LoadConfigurationFromJSON() cached while
    // --- loading indicators_config.json and applies it to the matching rows, so a saved Buy/Sell
    // --- setting survives an EA restart instead of resetting to OFF.
    void CGUIPannel::ApplyLoadedSymbolTFSettings(void)
     {
      if(m_time_series_engine == NULL) return;
      string symbols[], tfs[];
      bool buys[], sells[];
      m_time_series_engine.GetLoadedSymbolTFSettings(symbols, tfs, buys, sells);
      int rows = (int)m_table_indicator_SymbolTFSeting.RowsTotal();
      for(int i = 0; i < ArraySize(symbols); i++)
       {
        for(int row = 0; row < rows; row++)
          {
          string sym = m_table_indicator_SymbolTFSeting.GetValue(0, row);
          StringTrimLeft(sym);
          if(sym != symbols[i]) continue;
          string tf = m_table_indicator_SymbolTFSeting.GetValue(1, row);
          StringTrimLeft(tf);
          if(tf != tfs[i]) continue;
          m_table_indicator_SymbolTFSeting.ChangeImage(2, row, buys[i]  ? 0 : 1);
          m_table_indicator_SymbolTFSeting.ChangeImage(3, row, sells[i] ? 0 : 1);
          break;
          }
       }
      m_table_indicator_SymbolTFSeting.Update(true);
     }
    // --- Buy/Sell lookup arrays for SaveGUIConfigToJSON, read off m_table_indicator_SymbolTFSeting's
    // --- current checkbox state (col 2/3).
    void CGUIPannel::BuildSymbolTFBuySellArrays(string &symbols[], string &tfs[], bool &buys[], bool &sells[])
     {
      ArrayResize(symbols, 0);
      ArrayResize(tfs, 0);
      ArrayResize(buys, 0);
      ArrayResize(sells, 0);
      int rows = (int)m_table_indicator_SymbolTFSeting.RowsTotal();
      int total = 0;
      for(int row = 0; row < rows; row++)
        {
         string sym = m_table_indicator_SymbolTFSeting.GetValue(0, row);
         StringTrimLeft(sym);
         if(sym == "") continue;
         string tf = m_table_indicator_SymbolTFSeting.GetValue(1, row);
         StringTrimLeft(tf);
         ArrayResize(symbols, total + 1);
         ArrayResize(tfs, total + 1);
         ArrayResize(buys, total + 1);
         ArrayResize(sells, total + 1);
         symbols[total] = sym;
         tfs[total]     = tf;
         buys[total]    = (m_table_indicator_SymbolTFSeting.SelectedImageIndex(2, row) == 0);
         sells[total]   = (m_table_indicator_SymbolTFSeting.SelectedImageIndex(3, row) == 0);
         total++;
        }
     }
    // --- True for the ONE row matching this chart's own symbol/TF - CTimeSeriesEngine::OnInitEvent
    // --- creates that series unconditionally and everything else (RefreshIndicatorTable,
    // --- BuildAndWriteSignalBridge...) assumes it always exists, so that row must never be deletable.
    bool CGUIPannel::IsCurrentChartSymbolTFRow(const string sym, const string tf_text)
     {
      return (sym == ::Symbol() && tf_text == TimeframeDescription((ENUM_TIMEFRAMES)::Period()));
     }


   //Tab Marker TAB_TAB_MAIN_SETTINGS_CONFIG_MARKER
    // --- Loads the "markers" section of Config_Setting.json - the SAME single file
    // --- CTimeSeriesEngine::SaveConfigurationToJSON/LoadConfigurationFromJSON already use for
    // --- "symbols_tf"/"templates" (Anhnt, 2026-07-17: one file for everything, not scattered
    // --- across separate files). Always sets sane defaults first so a missing/partial file
    // --- (or a file that simply has no "markers" key yet) still leaves the EA in a working state.
    void CGUIPannel::LoadMarkerSettings(void)
     {

      //https://www.mql5.com/en/docs/constants/objectconstants/wingdings
      m_marker_single_indicator_buy_code  = 217; 
      m_marker_single_indicator_sell_code = 218;
      m_marker_multi_indicator_buy_code   = 67; // Thumb Up
      m_marker_multi_indicator_sell_code  = 68; // Thumb Down

      m_marker_pattern_buy_code  = 83;   
      m_marker_pattern_sell_code = 83;   
      m_marker_combo_buy_code    = 77;  
      m_marker_combo_sell_code   = 77;  

      m_marker_buy_color        = clrLime;
      m_marker_sell_color       = clrRed;
      m_marker_nonrelated_color = clrGray;
      m_marker_buy_sound_file   = "";
      m_marker_sell_sound_file  = "";
      m_marker_sound_folder     = "Sounds";
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
    // --- Rewrites Config_Setting.json with a fresh "markers" section, carrying "symbols_tf"/
    // --- "templates" through UNCHANGED (raw text, not re-parsed/re-built) via
    // --- IndicatorConfig_ExtractRawSection - this function only owns "markers", so it must
    // --- never destroy the OTHER sections CTimeSeriesEngine owns, symmetric with how that
    // --- engine's own writers now preserve "markers" when THEY rewrite this same file.
    void CGUIPannel::SaveMarkerSettingsToJSON(void)
     {
      string existing   = IndicatorConfig_ReadWholeFile("Config_Setting.json");
      string symbols_tf = IndicatorConfig_ExtractRawSection(existing, "symbols_tf");
      string templates   = IndicatorConfig_ExtractRawSection(existing, "templates");

      string json = "{\n";
      if(symbols_tf != "") json += " \"symbols_tf\": " + symbols_tf + ",\n";
      if(templates  != "") json += " \"templates\": "  + templates  + ",\n";
      string buy_sound_esc  = m_marker_buy_sound_file;
      string sell_sound_esc = m_marker_sell_sound_file;
      string sound_folder_esc = m_marker_sound_folder;
      ::StringReplace(buy_sound_esc,  "\\", "\\\\");
      ::StringReplace(sell_sound_esc, "\\", "\\\\");
      ::StringReplace(sound_folder_esc, "\\", "\\\\");
      json += " \"markers\": { \"single_indicator_buy_arrow_code\": "  + (string)m_marker_single_indicator_buy_code +
              ", \"single_indicator_sell_arrow_code\": " + (string)m_marker_single_indicator_sell_code +
              ", \"multi_indicator_buy_arrow_code\": "   + (string)m_marker_multi_indicator_buy_code +
              ", \"multi_indicator_sell_arrow_code\": "  + (string)m_marker_multi_indicator_sell_code +
              ", \"pattern_buy_arrow_code\": "  + (string)m_marker_pattern_buy_code +     
              ", \"pattern_sell_arrow_code\": " + (string)m_marker_pattern_sell_code  +    
              ", \"combo_buy_arrow_code\": "    + (string)m_marker_combo_buy_code +       
              ", \"combo_sell_arrow_code\": "   + (string)m_marker_combo_sell_code +      
              ", \"buy_color\": "        + (string)(int)m_marker_buy_color +
              ", \"sell_color\": "       + (string)(int)m_marker_sell_color +
              ", \"nonrelated_color\": " + (string)(int)m_marker_nonrelated_color +
              ", \"buy_sound_file\": \""  + buy_sound_esc  + "\"" +
              ", \"sell_sound_file\": \"" + sell_sound_esc + "\"" +
              ", \"sound_folder\": \""    + sound_folder_esc + "\"" + " }\n}";

      int fh = ::FileOpen("Config_Setting.json", FILE_TXT|FILE_WRITE|FILE_ANSI);
      if(fh == INVALID_HANDLE) return;
      ::FileWriteString(fh, json);
      ::FileClose(fh);
     }   
    // --- Minimal "find an int value after a JSON key" scan - Config_Setting.json's "markers" section is only ever
    // --- machine-written by SaveMarkerSettings() above, so a full JSON parser is unwarranted.
    bool CGUIPannel::JsonIntValue(const string content, const string key, int &value)
     {
      int pos = ::StringFind(content, "\"" + key + "\"");
      if(pos < 0) return false;
      int colon = ::StringFind(content, ":", pos);
      if(colon < 0) return false;
      int len = ::StringLen(content);
      int i = colon + 1;
      while(i < len && ::StringGetCharacter(content, i) == ' ') i++;
      int start = i;
      while(i < len)
        {
         ushort ch = ::StringGetCharacter(content, i);
         if((ch < '0' || ch > '9') && ch != '-') break;
         i++;
        }
      string num = ::StringSubstr(content, start, i - start);
      if(num == "") return false;
      value = (int)::StringToInteger(num);
      return true;
     }
    // --- Same idea as JsonIntValue but for a quoted string value - backslashes in Windows
    // --- paths are escaped ("\\") on write (SaveMarkerSettings) and un-escaped here on read.
    bool CGUIPannel::JsonStringValue(const string content, const string key, string &value)
     {
      int pos = ::StringFind(content, "\"" + key + "\"");
      if(pos < 0) return false;
      int colon = ::StringFind(content, ":", pos);
      if(colon < 0) return false;
      int q1 = ::StringFind(content, "\"", colon + 1);
      if(q1 < 0) return false;
      int q2 = ::StringFind(content, "\"", q1 + 1);
      if(q2 < 0) return false;
      value = ::StringSubstr(content, q1 + 1, q2 - q1 - 1);
      ::StringReplace(value, "\\\\", "\\");
      return true;
     }
    // --- Attaches SignalMarkers.mq5 to this chart if not already running (checked by short
    // --- name, set via IndicatorSetString(INDICATOR_SHORTNAME,...) in the indicator's own
    // --- OnInit) - idempotent, safe to call defensively on every OnInitEvent branch, same
    // --- style as CTradingLevelBubble::EnsureCreated() being polled unconditionally.
    void CGUIPannel::EnsureMarkerIndicatorAttached(void)
     {
      int total = ::ChartIndicatorsTotal(m_chart_id, 0);
      for(int i = 0; i < total; i++)
         if(::StringFind(::ChartIndicatorName(m_chart_id, 0, i), "SignalMarkers") == 0)
            return; // already attached

      int h = ::iCustom(NULL, 0, "Vendors\\Anhnt\\Custom Buildin\\SignalMarkers",
                         m_marker_single_indicator_buy_code, m_marker_single_indicator_sell_code,
                         m_marker_multi_indicator_buy_code, m_marker_multi_indicator_sell_code,
                         m_marker_pattern_buy_code, m_marker_pattern_sell_code,
                         m_marker_buy_color, m_marker_sell_color, m_marker_nonrelated_color);
      if(h == INVALID_HANDLE)
        {
         ::Print(__FUNCTION__, " > iCustom(SignalMarkers) failed, error ", ::GetLastError());
         return;
        }
      if(!::ChartIndicatorAdd(m_chart_id, 0, h))
         ::Print(__FUNCTION__, " > ChartIndicatorAdd(SignalMarkers) failed, error ", ::GetLastError());
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
      //  //Debug
      //   PrintFormat("DEBUG CGUIPannel::CreateColorPreview row=%d preview=(%d,%d,%d,%d) button=(%d,%d,%d,%d) buttonGap=%d",
      //   row,
      //   m_preview_color[row].X(), m_preview_color[row].Y(),
      //   m_preview_color[row].XSize(), m_preview_color[row].YSize(),
      //   m_preview_color[row].GetButtonPointer().X(),
      //   m_preview_color[row].GetButtonPointer().Y(),
      //   m_preview_color[row].GetButtonPointer().XSize(),
      //   m_preview_color[row].GetButtonPointer().YSize(),
      //   m_preview_color[row].GetButtonPointer().XGap());
        
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
          if(codes[i] == m_marker_combo_buy_code)            sel_combo_buy   = i;
          if(codes[i] == m_marker_combo_sell_code)           sel_combo_sell  = i;
         }
        // string shape_captions[4] = {"Single Buy", "Single Sell", "Multi Buy", "Multi Sell"};
        // int    shape_codes[4]    = {m_marker_single_indicator_buy_code, m_marker_single_indicator_sell_code, m_marker_multi_indicator_buy_code, m_marker_multi_indicator_sell_code};

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
    // --- Reads all 7 combos, persists to Config_Setting.json's "markers" section, and hot-swaps the running
    // --- SignalMarkers.mq5 instance so the new look applies immediately.
    void CGUIPannel::OnClickSaveMarkerSettings(void)
     {
      int codes[]; string shape_labels[];
      GetMarkerArrowCodeChoices(codes, shape_labels);
      int n_shapes = ArraySize(codes);

      int sel;
      sel = (int)m_combo_shape_single_indicator_buy.GetListViewPointer().SelectedItemIndex();
      if(sel >= 0 && sel < n_shapes) m_marker_single_indicator_buy_code = codes[sel];
      sel = (int)m_combo_shape_single_indicator_sell.GetListViewPointer().SelectedItemIndex();
      if(sel >= 0 && sel < n_shapes) m_marker_single_indicator_sell_code = codes[sel];
      sel = (int)m_combo_shape_multi_indicator_buy.GetListViewPointer().SelectedItemIndex();
      if(sel >= 0 && sel < n_shapes) m_marker_multi_indicator_buy_code = codes[sel];
      sel = (int)m_combo_shape_multi_indicator_sell.GetListViewPointer().SelectedItemIndex();
      if(sel >= 0 && sel < n_shapes) m_marker_multi_indicator_sell_code = codes[sel];

      color mcolors[]; string color_labels[];
      GetMarkerColorChoices(mcolors, color_labels);
      int n_colors = ArraySize(mcolors);

      sel = (int)m_combo_color_buy.GetListViewPointer().SelectedItemIndex();
      if(sel >= 0 && sel < n_colors) m_marker_buy_color = mcolors[sel];
      sel = (int)m_combo_color_sell.GetListViewPointer().SelectedItemIndex();
      if(sel >= 0 && sel < n_colors) m_marker_sell_color = mcolors[sel];
      sel = (int)m_combo_color_nonrelated.GetListViewPointer().SelectedItemIndex();
      if(sel >= 0 && sel < n_colors) m_marker_nonrelated_color = mcolors[sel];

      //m_marker_sound_folder = m_edit_sound_folder.GetValue();
      string sound_val = m_combo_buy_sound.GetValue();
      if(sound_val != "") m_marker_buy_sound_file = sound_val;
      sound_val = m_combo_sell_sound.GetValue();
      if(sound_val != "") m_marker_sell_sound_file = sound_val;

      SaveMarkerSettingsToJSON();
      ReattachSignalMarkersIndicator();
     } 
    // --- Lists every FILE (not subfolder) directly inside MQL5\Files\<m_marker_sound_folder>\ -
    // --- plain FileFindFirst/FileFindNext, no tree/splitter/popup to freeze (2026-07-17,
    // --- replaces the CFileNavigator attempt after its splitter-drag state got stuck).
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
    // --- "Refresh" button next to the sound-folder path: read the CURRENT text box value (the
    // --- user may have just typed a new folder), re-scan it, and rebuild both combos in place.
    void CGUIPannel::OnClickChangeSoundFolder(void)
     {
      //m_marker_sound_folder = m_edit_sound_folder.GetValue();

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
    // --- Detaches SignalMarkers.mq5 if attached - ChartIndicatorAdd() makes it an independent
    // --- chart program, so removing THIS EA does NOT auto-detach it. Called from
    // --- ReattachSignalMarkersIndicator() (style change) AND from OnDeinitEvent on final removal.
    // --- BugNote 2026-07-18: "SignalMarkers survives Remove EA" - the old scan-by-
    // --- ChartIndicatorsTotal()/ChartIndicatorName() approach reads 0/garbage when called from
    // --- OnDeinit() while THIS chart's own program is mid-removal (confirmed empirically: the
    // --- native Indicators List dialog showed SignalMarkers very much still attached at the
    // --- exact moment our own scan reported total=0). SignalMarkers.mq5 sets its own short name
    // --- deterministically ("SignalMarkers(" + Symbol() + ")", see SignalMarkers.mq5 line ~102) -
    // --- delete by that known name directly instead of trusting the unreliable enumeration.
    // --- ChartIndicatorDelete() itself also reports a false/error return here (confirmed
    // --- error 4022) even though the deletion genuinely takes effect - another OnDeinit-timing
    // --- artifact, not a real failure, so the return value is intentionally not checked.
    void CGUIPannel::RemoveMarkerIndicator(void)
     {
      ::ChartIndicatorDelete(m_chart_id, 0, "SignalMarkers(" + ::Symbol() + ")");
     }
    // --- Detach + re-attach with the CURRENT m_marker_* values - MT5 has no live-input-update
    // --- API for a running indicator, so a style change means recreate it.
    void CGUIPannel::ReattachSignalMarkersIndicator(void)
     {
      RemoveMarkerIndicator();
      EnsureMarkerIndicatorAttached();
     }
    // --- BBands-only (Anhnt, 2026-07-17): processes ONE line's REAL persisted history from
    // --- CSignalBollinger (Layer 1) - Closed-bar catch-up mirrors the primary signal's own loop
    // --- exactly (log-only, watermark keyed by params_key+"|"+line_name so it never collides
    // --- with the primary signal's own watermark entry), then a Live-bar check (transient
    // --- last_seen[] vs LineCurrentSignal()) fires Message+CSV (deliberately no Sound, matching
    // --- the earlier scoped-down decision) on every real change.
    void CGUIPannel::ProcessBandLine(const int row, CSignalBollinger *bb, const int line_idx, const string line_name, ENUM_SIGNAL_DIR &last_seen[], const bool seeding, const string type_key, const string params_key, const string label, const string tf_text, const int digits)
     {
      CIndicatorDE *ind = bb.GetIndicator();
      if(ind == NULL) return;
      string line_params_key = params_key + "|" + line_name;

      datetime wm = m_signal_logger.GetSignalLogWatermark(type_key, line_params_key);
      int total = bb.LineHistoryTotal(line_idx);
      datetime newest_committed = wm;
      for(int idx = 0; idx < total; idx++)
        {
         datetime t = bb.LineHistoryTime(line_idx, idx);
         if(t <= wm) continue;
         ENUM_SIGNAL_DIR hdir = bb.LineHistoryDir(line_idx, idx);
         string dir_text   = (hdir == SIGNAL_BUY) ? "Buy" : "Sell";
         string cross_text = (hdir == SIGNAL_BUY) ? ("Cross Up " + line_name + "Band") : ("Cross Down " + line_name + "Band");
         string time_text  = ::TimeToString(t, TIME_DATE|TIME_MINUTES);
         int shift = ::iBarShift(ind.Symbol(), ind.Timeframe(), t, false);
         double price = (shift >= 0) ? ::iClose(ind.Symbol(), ind.Timeframe(), shift) : 0.0;
         string price_text = ::DoubleToString(price, digits);
         m_signal_logger.WriteSignalLogRow(time_text, ::Symbol(), tf_text, label, dir_text, price_text, "Closed", cross_text);
         if(t > newest_committed) newest_committed = t;
        }
      if(newest_committed > wm)
         m_signal_logger.SetSignalLogWatermark(type_key, line_params_key, newest_committed);

      ENUM_SIGNAL_DIR live_dir = bb.LineCurrentSignal(line_idx);
      if(seeding)
        {
         last_seen[row] = live_dir; // baseline only, never fires on first sight
         return;
        }
      if(live_dir == last_seen[row]) return; // no change
      last_seen[row] = live_dir;
      if(live_dir == SIGNAL_NONE) return; // dropped to exactly-on-the-line - not report-worthy itself

      // --- Same Time;Live;TF;Indicator;Signal shape as the primary message, plus a 6th
      // --- ";"-delimited field naming which line/direction triggered it (Anhnt, 2026-07-17:
      // --- "viết ra Journal như nào thì cũng viết ra Signal_Log.csv y như thế").
      string dir_text   = (live_dir == SIGNAL_BUY) ? "Buy" : "Sell";
      string cross_text = (live_dir == SIGNAL_BUY) ? ("Cross Up " + line_name + "Band") : ("Cross Down " + line_name + "Band");
      string time_text  = ::TimeToString(::TimeCurrent(), TIME_DATE|TIME_MINUTES);
      double price = ::iClose(ind.Symbol(), ind.Timeframe(), 0);
      string price_text = ::DoubleToString(price, digits);
      CMessage::Out(time_text + ";Live;" + tf_text + ";" + label + ";" + dir_text + ";" + cross_text);
      m_signal_logger.WriteSignalLogRow(time_text, ::Symbol(), tf_text, label, dir_text, price_text, "Live", cross_text);
     }

#endif // CGUIPANNEL_TABSETTING_MQH
