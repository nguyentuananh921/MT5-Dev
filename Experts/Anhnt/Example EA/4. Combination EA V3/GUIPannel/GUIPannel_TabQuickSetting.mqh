//+------------------------------------------------------------------+
//|                                    GUIPannel_TabQuickSetting.mqh |
//|      Implementation of the Quick Setting tab of m_tabs_main      |
//+------------------------------------------------------------------+
#ifndef CGUIPANNEL_TABQUICKSETTING_MQH
#define CGUIPANNEL_TABQUICKSETTING_MQH
#include "GUIPannel.mqh"
 //+------------------------------------------------------------------+
 //| A column of icon tabs at the left of the Quick Setting tab       |
 //+------------------------------------------------------------------+
 bool CGUIPannel::CreateTab_QuickSetting(const int x_gap,const int y_gap)
  {
   //--- Properties: the tabs are in a column at the left, the content fills what is left
   m_tabs_quickSetting.PositionMode(TABS_LEFT);
   m_tabs_quickSetting.TabsYSize(M_TAB_QUICK_SETTING_WIDTH);
   m_tabs_quickSetting.AutoXResizeMode(true);
   m_tabs_quickSetting.AutoYResizeMode(true);
   m_tabs_quickSetting.AutoXResizeRightOffset(0);
   m_tabs_quickSetting.AutoYResizeBottomOffset(0);
   //--- Add tabs with the specified properties: an icon each, no text
   for(int i=0;i<TAB_QUICK_SETTING_TOTAL;i++)
      m_tabs_quickSetting.AddTab("",M_TAB_QUICK_SETTING_WIDTH);
   //--- A child of the Quick Setting tab of m_tabs_main: it shows and hides with it
   m_tabs_main.AddToElementsArray(TAB_TAB_MAIN_QUICK_SETTING,m_tabs_quickSetting);
   if(!m_tabs_quickSetting.CreateTabs(this.m_chart_id,M_SUBWINDOW_MAIN,"TabsQuickSetting",x_gap,y_gap))
      return(false);
   //--- The icon of each tab, in the order of ENUM_TAB_QUICK_SETTING
   uint tab_icons[TAB_QUICK_SETTING_TOTAL]={IMAGE_RESOURCE_BMP32_INDICATOR_PNG,IMAGE_RESOURCE_BMP32_SYMBOL_PNG,IMAGE_RESOURCE_BMP32_CANDLE_MARKER_CANDLE_PNG,IMAGE_RESOURCE_BMP32_RISK_MANAGEMENT_PNG,IMAGE_RESOURCE_BMP32_SMARTMONEY_PNG};
   for(int i=0;i<TAB_QUICK_SETTING_TOTAL;i++)
     {
      CButtonTriggered *button=m_tabs_quickSetting.GetButtonsGroupPointer().GetButtonPointer(i);
      button.IconFile(tab_icons[i]);
      button.IconFileLocked(tab_icons[i]);
      button.IconFilePressed(tab_icons[i]);
      button.IconFilePressedLocked(tab_icons[i]);
      button.Draw(false);
     }
   //--- The content of each tab
   if(!CreateTable_IndicatorTemplateSetting(0,0))
      return(false);
   InitializeTable_IndicatorTemplateSetting();
   if(!CreateTreeView_SymbolTFSetting(M_CONTROL_BORDER_GAP,M_CONTROL_BORDER_GAP))
      return(false);
   PopulateTreeView_SymbolTFSetting();
   SyncTreeView_SymbolTFSetting();
   if(!CreateTable_SymbolTFSetting(M_CONTROL_BORDER_GAP+M_TREEVIEW_WIDTH+M_CONTROL_BORDER_GAP,0))
      return(false);
   PopulateTable_SymbolTFSetting();
   if(!CreateTable_CandlePatternSetting(0,0))
      return(false);
   InitializeTable_CandlePatternSetting();
   if(!CreateSections_SmartMoney(M_CONTROL_BORDER_GAP,M_CONTROL_BORDER_GAP))
      return(false);
   if(!CreateTabs_RiskManagement(0,M_CONTROL_HEIGHT))
      return(false);
   return(true);
  }
#endif // CGUIPANNEL_TABQUICKSETTING_MQH
