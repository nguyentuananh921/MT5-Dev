//+------------------------------------------------------------------+
//|                      GUIPannel_TabQuickSetting_RiskManagement.mqh |
//| Risk Management tab of m_tabs_quickSetting                       |
//+------------------------------------------------------------------+
#ifndef CGUIPANNEL_TABQUICKSETTING_RISKMANAGEMENT_MQH
#define CGUIPANNEL_TABQUICKSETTING_RISKMANAGEMENT_MQH
#include "GUIPannel.mqh"
 //+------------------------------------------------------------------+
 //| The tabs of the Risk Management tab, at its top: Stop Loss and   |
 //| Trailing; the content of each comes in its own module            |
 //+------------------------------------------------------------------+
 bool CGUIPannel::CreateTabs_RiskManagement(const int x_gap,const int y_gap)
  {
   string tabs_names[TAB_RISK_MANAGEMENT_TOTAL]={"Stop Loss","Trailing","Setup"};   // the order of ENUM_TAB_RISK_MANAGEMENT
   //--- Properties: the header on top, the content fills what is left
   m_tabs_riskManagement.PositionMode(TABS_TOP);
   m_tabs_riskManagement.AutoXResizeMode(true);
   m_tabs_riskManagement.AutoYResizeMode(true);
   m_tabs_riskManagement.AutoXResizeRightOffset(0);    // flush with the body of the Risk Management tab
   m_tabs_riskManagement.AutoYResizeBottomOffset(0);
   for(int i=0;i<TAB_RISK_MANAGEMENT_TOTAL;i++)
      m_tabs_riskManagement.AddTab(tabs_names[i],100);
   //--- A child of the Risk Management tab of m_tabs_quickSetting: it shows and hides with it
   m_tabs_quickSetting.AddToElementsArray(TAB_QUICK_SETTING_RISK_MANAGEMENT,m_tabs_riskManagement);
   if(!m_tabs_riskManagement.CreateTabs(this.m_chart_id,M_SUBWINDOW_MAIN,"TabsRiskManagement",x_gap,y_gap))
      return(false);
   //--- The content of each tab (positions are in the body of the tabs)
   if(!CreateStopLostForm(0,0))
      return(false);
   if(!CreateTable_IndicatorsTrailingSetting(0,0))
      return(false);
   if(!CreateTrailingForm(0,m_tabs_riskManagement.Height()-TRAIL_FORM_FRAME_HEIGHT))   // at the bottom of the body, flush: the table takes the rest
      return(false);
   if(!CreateSetupForm(0,0))
      return(false);
   return(true);
  }
#endif // CGUIPANNEL_TABQUICKSETTING_RISKMANAGEMENT_MQH
