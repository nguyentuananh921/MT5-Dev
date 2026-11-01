//+------------------------------------------------------------------+
//|                              GUIPannel_TabTrading_TradeManage.mqh |
//| The Trade Manage button of the Trading tab; its window is in     |
//| GUIPannel_TradeManagerWindow.mqh                                 |
//+------------------------------------------------------------------+
#ifndef CGUIPANNEL_TABTRADING_TRADEMANAGE_MQH
#define CGUIPANNEL_TABTRADING_TRADEMANAGE_MQH
#include "GUIPannel.mqh"
 //--- The button of the Trading tab, under the monitor
 bool CGUIPannel::CreateButton_TradeManage(const int x_gap,const int y_gap)
  {
   m_btn_tradeManage.SetText("Trade Manage");
   m_tabs_main.AddToElementsArray(TAB_TAB_MAIN_TRADING,m_btn_tradeManage);
   return m_btn_tradeManage.Create(this.m_chart_id,M_SUBWINDOW_MAIN,"BtnTradeManage",x_gap,y_gap,M_BUTTON_TRADEMANAGE_WIDTH,M_CONTROL_HEIGHT);
  }
#endif // CGUIPANNEL_TABTRADING_TRADEMANAGE_MQH
