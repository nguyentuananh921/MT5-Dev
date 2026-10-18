//+------------------------------------------------------------------+
//|             GUIPannel_TabQuickSetting_RiskManagement_Setup.mqh |
//| Setup tab of the Risk Management tab: the risk of a new trade   |
//| (RPN) and the Risk Reward Ratio (RRR) of its take profit. As the |
//| Smart Money tab: Save at the top right, the sections under it,   |
//| a section is a header (arrow, name, toggle) and its body         |
//+------------------------------------------------------------------+
#ifndef CGUIPANNEL_TABQUICKSETTING_RISKMANAGEMENT_SETUP_MQH
#define CGUIPANNEL_TABQUICKSETTING_RISKMANAGEMENT_SETUP_MQH
#include "GUIPannel.mqh"
 //--- The text of a ratio: "1 : 1.5"
 string CGUIPannel::RiskRewardRatioText(const ENUM_RISK_REWARD_RATIO ratio) const
  {
   double reward=RiskRewardRatioValue(ratio);
   return "1 : "+::DoubleToString(reward,(reward==(double)(int)reward ? 0 : 1));
  }
 //+------------------------------------------------------------------+
 //| Save, the section of the risk of a new trade (its toggle is "use  |
 //| it", its body the percent of the balance) and the section of the |
 //| Risk Reward Ratio (its body the ratio of the take profit)        |
 //+------------------------------------------------------------------+
 bool CGUIPannel::CreateSetupForm(const int x_gap,const int y_gap)
  {
   CTradingSetupSettingManager *manager=m_TradingSetupManager;
   const int box_w=SETUP_BOX_WIDTH;
   //--- Save: its place is the top right of the tab (ArrangeSections_Setup)
   m_btn_save_RiskSetup.SetText("Save");
   m_btn_save_RiskSetup.IconFile(IMAGE_RESOURCE_BMP16_SAVE_PNG);
   m_tabs_riskManagement.AddToElementsArray(TAB_RISK_MANAGEMENT_SETUP,m_btn_save_RiskSetup);
   if(!m_btn_save_RiskSetup.Create(this.m_chart_id,M_SUBWINDOW_MAIN,"BtnSaveRiskSetup",0,0,M_BUTTON_SAVE_WIDTH,M_CONTROL_HEIGHT))
      return false;
   //--- Risk per new trade
   if(!CreateSectionHeader(m_btn_setup_header[SETUP_SECTION_RISK],GetPointer(m_btn_setup_toggle[SETUP_SECTION_RISK]),"Risk per new trade",manager!=NULL && manager.UseRiskPerNewTrade(),true,
                           m_tabs_riskManagement,TAB_RISK_MANAGEMENT_SETUP,"Setup0"))
      return false;
   m_edit_risk_percent.SetText("Risk (% of balance)");
   m_edit_risk_percent.LabelXGap(M_SECTION_TEXT_X);
   m_tabs_riskManagement.AddToElementsArray(TAB_RISK_MANAGEMENT_SETUP,m_edit_risk_percent);
   if(!m_edit_risk_percent.CreateTextEdit(this.m_chart_id,M_SUBWINDOW_MAIN,"EditRiskPercent",0,0,box_w,M_CONTROL_HEIGHT,M_SECTION_EDIT_FIELD_WIDTH))
      return false;
   m_edit_risk_percent.SetValue(::DoubleToString((manager!=NULL) ? manager.RiskPerNewTrade() : 5.0,2));
   //--- Risk Reward Ratio: the take profit is at this multiple of the stop distance
   if(!CreateSectionHeader(m_btn_setup_header[SETUP_SECTION_RRR],GetPointer(m_btn_setup_toggle[SETUP_SECTION_RRR]),"Risk Reward Ratio",manager!=NULL && manager.UseRiskRewardRatio(),true,
                           m_tabs_riskManagement,TAB_RISK_MANAGEMENT_SETUP,"Setup1"))
      return false;
   CLabel *rrr_caption=GetPointer(m_combobox_rrr);   // the name is the label at the left, the button keeps the chosen ratio
   rrr_caption.SetText("Take profit");
   rrr_caption.LabelXGap(M_SECTION_TEXT_X);
   m_combobox_rrr.ItemsTotal(RISK_REWARD_RATIOS_TOTAL);
   m_tabs_riskManagement.AddToElementsArray(TAB_RISK_MANAGEMENT_SETUP,m_combobox_rrr);
   if(!m_combobox_rrr.CreateComboBox(this.m_chart_id,M_SUBWINDOW_MAIN,"ComboRrr",0,0,box_w,M_CONTROL_HEIGHT,M_SECTION_EDIT_FIELD_WIDTH+20,140))
      return false;
   for(int i=0;i<RISK_REWARD_RATIOS_TOTAL;i++)
      m_combobox_rrr.SetValue(i,RiskRewardRatioText((ENUM_RISK_REWARD_RATIO)i));
   m_combobox_rrr.SelectItem((manager!=NULL) ? (int)manager.RiskRewardRatio() : (int)ONE_TO_TWO);
   m_combobox_rrr.GetListViewPointer().Draw(false);   // SetValue/SelectItem only store, repaint the list
   return true;
  }
 //--- Save at the top right, the sections one under the other: a closed one takes its header only
 void CGUIPannel::ArrangeSections_Setup(void)
  {
   if(m_first_start || !m_tabs_riskManagement.IsVisible() || m_tabs_riskManagement.SelectedTab()!=TAB_RISK_MANAGEMENT_SETUP)
      return;
   const int x=m_tabs_riskManagement.X()+M_CONTROL_BORDER_GAP;
   int y=m_tabs_riskManagement.Y()+M_CONTROL_BORDER_GAP;
   m_btn_save_RiskSetup.Move(m_tabs_riskManagement.X()+m_tabs_riskManagement.Width()-M_BUTTON_SAVE_WIDTH-M_CONTROL_BORDER_GAP,y);
   m_btn_save_RiskSetup.Show();
   y+=M_CONTROL_HEIGHT+M_CONTROL_BORDER_GAP;
   //--- Risk per new trade
   m_btn_setup_header[SETUP_SECTION_RISK].Move(x,y);
   m_btn_setup_header[SETUP_SECTION_RISK].Show();
   m_btn_setup_toggle[SETUP_SECTION_RISK].Move(x+M_SECTION_HEADER_WIDTH+M_CONTROL_BORDER_GAP,y);
   m_btn_setup_toggle[SETUP_SECTION_RISK].Show();
   y+=M_CONTROL_HEIGHT+M_CONTROL_BORDER_GAP;
   if(m_btn_setup_header[SETUP_SECTION_RISK].State())
     {
      m_edit_risk_percent.Move(x+M_SECTION_BODY_INDENT,y);
      m_edit_risk_percent.Show();
      y+=M_CONTROL_YDISTANCE+M_CONTROL_BORDER_GAP;
     }
   else
      m_edit_risk_percent.Hide();
   //--- Risk Reward Ratio
   m_btn_setup_header[SETUP_SECTION_RRR].Move(x,y);
   m_btn_setup_header[SETUP_SECTION_RRR].Show();
   m_btn_setup_toggle[SETUP_SECTION_RRR].Move(x+M_SECTION_HEADER_WIDTH+M_CONTROL_BORDER_GAP,y);
   m_btn_setup_toggle[SETUP_SECTION_RRR].Show();
   y+=M_CONTROL_HEIGHT+M_CONTROL_BORDER_GAP;
   if(m_btn_setup_header[SETUP_SECTION_RRR].State())
     {
      m_combobox_rrr.Move(x+M_SECTION_BODY_INDENT,y);
      m_combobox_rrr.Show();
     }
   else
      m_combobox_rrr.Hide();
   ::ChartRedraw(this.m_chart_id);
  }
 //+------------------------------------------------------------------+
 //| What the user did in the Setup tab                               |
 //+------------------------------------------------------------------+
 void CGUIPannel::OnEvent_Tab_RiskSetup(const int id,const long &lparam,const double &dparam,const string &sparam)
  {
   //--- A tab was opened (it showed its children, the closed sections hide their bodies again), or the window changed its size
   if(id==CHARTEVENT_CUSTOM+ON_CLICK_TAB ||
      ((id==CHARTEVENT_CUSTOM+ON_WINDOW_CHANGE_XSIZE || id==CHARTEVENT_CUSTOM+ON_WINDOW_CHANGE_YSIZE) && lparam==m_window_main.ObjectID()))
     {
      this.ArrangeSections_Setup();
      return;
     }
   if(id!=CHARTEVENT_CUSTOM+ON_CLICK_BUTTON)
      return;
   //--- A header: its body opens or closes and the section under it moves
   for(int s=0;s<SETUP_SECTION_TOTAL;s++)
      if(lparam==m_btn_setup_header[s].ObjectID())
        {
         this.ArrangeSections_Setup();
         return;
        }
   //--- A toggle: ON = the risk of a new trade is used / the take profit is put by the ratio, dparam = the new state; Save keeps it
   for(int s=0;s<SETUP_SECTION_TOTAL;s++)
      if(lparam==m_btn_setup_toggle[s].ObjectID())
        {
         m_btn_setup_toggle[s].SetText(dparam!=0 ? "ON" : "OFF");
         m_btn_setup_toggle[s].Draw(true);
         return;
        }
   //--- Save commits the risk of a new trade and the Risk Reward Ratio: the same for every Symbol
   if(lparam==m_btn_save_RiskSetup.ObjectID())
     {
      if(m_TradingSetupManager==NULL)
         return;
      double percent=::StringToDouble(m_edit_risk_percent.GetValue());
      if(percent<=0.0)
         percent=0.01;
      if(percent>100.0)
         percent=100.0;
      m_edit_risk_percent.SetValue(::DoubleToString(percent,2));   // what is kept
      m_TradingSetupManager.SetRisk(m_btn_setup_toggle[SETUP_SECTION_RISK].State(),percent);
      m_TradingSetupManager.UseRiskRewardRatio(m_btn_setup_toggle[SETUP_SECTION_RRR].State());
      int index=m_combobox_rrr.GetListViewPointer().SelectedItemIndex();
      if(index>=0 && index<RISK_REWARD_RATIOS_TOTAL)
         m_TradingSetupManager.RiskRewardRatio((ENUM_RISK_REWARD_RATIO)index);
      m_TradingSetupManager.NotifySettingChanged();
      m_TradingSetupManager.SaveToJSON();
      ::ChartRedraw(this.m_chart_id);
     }
  }
#endif // CGUIPANNEL_TABQUICKSETTING_RISKMANAGEMENT_SETUP_MQH
