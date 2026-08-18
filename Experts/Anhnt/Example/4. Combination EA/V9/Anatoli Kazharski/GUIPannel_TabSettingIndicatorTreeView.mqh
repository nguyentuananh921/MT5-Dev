//+------------------------------------------------------------------+
//|                        GUIPannel_TabSettingIndicatorTreeView.mqh |
//+------------------------------------------------------------------+
#ifndef CGUIPANNEL_TABSETTINGINDICATORTREEVIEW_MQH
#define CGUIPANNEL_TABSETTINGINDICATORTREEVIEW_MQH
#include "GUIPannel.mqh"
//For control at TAB_TAB_MAIN_SETTINGS_CONFIG_TOTAL of m_tabs_main
 //+------------------------------------------------------------------+
 //| Create a nested tab group m_tabs_main_setting_config for Settings tab config sections       |
 //+------------------------------------------------------------------+
 bool CGUIPannel::CreateTabSettingConfig(const int x_gap, const int y_gap)
  {
    string tabs_names[TAB_TAB_MAIN_SETTINGS_CONFIG_TOTAL] = {"Indicator", "Symbol TF","Candle Pattern", "Marker"};
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
    //Seting Root Node for m_treeview_indicator base on ENUM_INDICATOR_GROUP in TimeseriesDefines.mqh
    ENUM_INDICATOR_GROUP group_values[4] = {INDICATOR_GROUP_TREND, 
      INDICATOR_GROUP_OSCILLATOR, 
      INDICATOR_GROUP_VOLUMES, 
      INDICATOR_GROUP_ARROWS}; 

    SIndicatorCatalogItem catalog[];
    GetIndicatorCatalog(catalog);    
    for(int g = 0; g < 4; g++)
     {
      int root_li = m_treeview_indicator.ItemsTotal();
      //m_group_tree_pos[g] = root_li;
      m_treeview_indicator.AddTreeItem(root_li,
                                    -1,                          // prev_node_list_index = -1 (root)
                                    GetIndicatorGroupName(group_values[g]),//Node Name IndicatorGroupName in TimeseriesDELib.mqh
                                    IMAGE_RESOURCE_BMP16_ARROWRIGHT_BMP,     //Inactive Icon
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
        m_type_node_value[sz] = catalog[i].ind_type;
        k++;
       }
     }
  }
 //Syn and Highlight active Indicator in Template 
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
#endif // CGUIPANNEL_TABSETTINGINDICATORTREEVIEW_MQH
