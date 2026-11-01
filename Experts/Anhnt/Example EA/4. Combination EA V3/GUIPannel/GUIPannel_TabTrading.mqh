//+------------------------------------------------------------------+
//|                                          GUIPannel_TabTrading.mqh |
//| The Trading tab of m_tabs_main: the monitor tabs at its top      |
//| (Indicator, Market Phase); the content of each is in its module  |
//+------------------------------------------------------------------+
#ifndef CGUIPANNEL_TABTRADING_MQH
#define CGUIPANNEL_TABTRADING_MQH
#include "GUIPannel.mqh"
 //+------------------------------------------------------------------+
 //| The tabs of the monitor, at the top of the Trading tab           |
 //+------------------------------------------------------------------+
 bool CGUIPannel::CreateTabs_Monitor(const int x_gap,const int y_gap)
  {
   string tabs_names[TAB_MONITOR_TOTAL]={"Indicator","Market Phase"};   // the order of ENUM_TAB_MONITOR
   //--- Properties: the header on top, the content fills what is left
   m_tabs_monitor.PositionMode(TABS_TOP);
   m_tabs_monitor.AutoXResizeMode(true);
   m_tabs_monitor.AutoYResizeMode(false);   // the height of the tables: what is under is for the other controls of the tab
   m_tabs_monitor.AutoXResizeRightOffset(0);    // flush with the body of the Trading tab: its header is right under the header of m_tabs_main
   m_tabs_monitor.AutoYResizeBottomOffset(0);
   for(int i=0;i<TAB_MONITOR_TOTAL;i++)
      m_tabs_monitor.AddTab(tabs_names[i],100);
   //--- A child of the Trading tab of m_tabs_main: it shows and hides with it
   m_tabs_main.AddToElementsArray(TAB_TAB_MAIN_TRADING,m_tabs_monitor);
   if(!m_tabs_monitor.CreateTabs(this.m_chart_id,M_SUBWINDOW_MAIN,"TabsMonitor",x_gap,y_gap,0,TRADING_FORM_HEIGHT))
      return(false);
   //--- The content of each tab (positions are in the body of the tabs): the tables are flush with it
   if(!CreateTable_PreTradeSymbolMonitor(0,0))
      return(false);
   if(!CreateTable_MarketStory(0,0))
      return(false);
   //--- Under the tables: the Trade Manage button, the other displays come here
   if(!CreateButton_TradeManage(0,y_gap+TRADING_FORM_HEIGHT+M_CONTROL_BORDER_GAP))
      return(false);
   return(true);
  }
 //+------------------------------------------------------------------+
 //| What Python (the Model) says: the Market Phase table shows it    |
 //+------------------------------------------------------------------+
 void CGUIPannel::OnEvent_Tab_Trading(const int id,const long &lparam,const double &dparam,const string &sparam)
  {
   //--- An indicator reported something new, the tab was opened, or the Stop Loss / Trailing setting was saved: the table of the indicators shows it
   if((id==CHARTEVENT_CUSTOM+INDICATOR_STATE_EVENT_CHANGED || id==CHARTEVENT_CUSTOM+ON_CLICK_TAB || id==CHARTEVENT_CUSTOM+RISK_MANAGEMENT_MANAGER_EVENT_CHANGED) && !m_first_start &&
      m_tabs_monitor.IsVisible() && m_tabs_monitor.SelectedTab()==TAB_MONITOR_INDICATOR)
     {
      if(this.SyncTable_PreTradeSymbolMonitor(::Symbol()))
         ::ChartRedraw(this.m_chart_id);
     }
   //--- The answer of a watch is complete, or a State / Phase / leg arrived
   if(id==CHARTEVENT_CUSTOM+MARKET_STORY_EVENT_CHANGED)
     {
      if(!m_first_start)
         this.SyncTable_MarketStory();
      return;
     }
  }
#endif // CGUIPANNEL_TABTRADING_MQH
