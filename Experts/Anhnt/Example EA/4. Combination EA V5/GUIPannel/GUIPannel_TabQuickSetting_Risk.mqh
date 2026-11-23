//+------------------------------------------------------------------+
//|                                GUIPannel_TabQuickSetting_Risk.mqh |
//| Risk Management tab of Quick Setting: the keys of CRiskSetting    |
//| (Setting_Risk, the inputs of FixedMACrossover_Part7 as the author |
//| declared them), a section for each input group, a row for each    |
//| key in its order, the control by its type: bool a switch, ENUM_ a |
//| combobox of the texts of the author (RiskEnumItems), int / double |
//| a spin box, string not shown. RiskMode and the amount of each     |
//| mode are on the Trading tab (what the Automation uses for an      |
//| Entry). The View only tells CRiskSetting (it fires                |
//| RISK_SETTING_EVENT_CHANGED, CTradingControl writes Setting_Risk)  |
//+------------------------------------------------------------------+
#ifndef CGUIPANNEL_TABQUICKSETTING_RISK_MQH
#define CGUIPANNEL_TABQUICKSETTING_RISK_MQH
#include "GUIPannel.mqh"
 //--- A key shown on this tab: not a string, not of the group V5, not RiskMode nor the amount of a mode (those are on the Trading tab)
 bool CGUIPannel::KeyShown_RiskSetting(CRiskSetting *risk,const int index)
  {
   const string name=risk.KeyName(index);
   if(risk.KeyIsText(index) || risk.KeyGroup(index)=="V5" || name=="RiskMode")
      return false;
   for(int m=0;m<RISK_MODES_TOTAL;m++)
      if(name==::RiskModeValueKey((ENUM_RISK_MODE)m))
         return false;
   return true;
  }
 //--- One section for each input group with a key shown, in the order of the inputs, closed at the start (a list of numbers to look at when needed)
 bool CGUIPannel::CreateSections_RiskSetting(void)
  {
   if(!m_sections_risk.Create(this.m_chart_id,M_SUBWINDOW_MAIN,&m_tabs_quickSetting,TAB_QUICK_SETTING_RISK_MANAGEMENT,"SectionsRisk"))
      return false;
   int columns[RISK_COLUMN_TOTAL]={0,M_RISK_COLUMN_VALUE};
   m_sections_risk.SetColumns(columns);
   int no_toggle[];
   m_sections_risk.SetToggleColumns(no_toggle);
   ::ArrayResize(m_risk_groups,0);
   CRiskSetting *risk=(m_TradingControl!=NULL ? m_TradingControl.RiskSetting() : NULL);
   if(risk==NULL)
      return true;
   uint icons[];
   bool states[];
   for(int k=0;k<risk.KeysTotal();k++)
     {
      if(!this.KeyShown_RiskSetting(risk,k))
         continue;
      const string group=risk.KeyGroup(k);
      const int total=::ArraySize(m_risk_groups);
      if(total>0 && m_risk_groups[total-1]==group)
         continue;
      if(m_sections_risk.AddSection(group,icons,states,false)==WRONG_VALUE)
         return false;
      ::ArrayResize(m_risk_groups,total+1);
      m_risk_groups[total]=group;
     }
   this.PopulateSections_RiskSetting();
   return true;
  }
 //--- A row for each key shown: its name (the name of the input), the control of its type
 void CGUIPannel::PopulateSections_RiskSetting(void)
  {
   CRiskSetting *risk=(m_TradingControl!=NULL ? m_TradingControl.RiskSetting() : NULL);
   if(risk==NULL)
      return;
   const int sections=::ArraySize(m_risk_groups);
   for(int s=0;s<sections;s++)
      m_sections_risk.ClearBody(s);
   int rows[];
   ::ArrayResize(rows,sections);
   ::ArrayInitialize(rows,0);
   for(int k=0;k<risk.KeysTotal();k++)
     {
      if(!this.KeyShown_RiskSetting(risk,k))
         continue;
      int section=WRONG_VALUE;
      for(int s=0;s<sections && section<0;s++)
         if(m_risk_groups[s]==risk.KeyGroup(k))
            section=s;
      if(section<0)
         continue;
      const int row=rows[section]++;
      const string name=risk.KeyName(k);
      const string type=risk.KeyType(k);
      string items[];
      if(type=="bool")
        {
         this.AddRow_TradingRisk(m_tabs_quickSetting,TAB_QUICK_SETTING_RISK_MANAGEMENT,m_sections_risk,section,row,k,name,M_RISK_LABEL_WIDTH,
                                 IMAGE_RESOURCE_BMP16_RISK_MANAGEMENT_ON_PNG,RISK_COLUMN_VALUE,"RiskKey"+(string)k,TRADE_SLOT_KEY_SWITCH,name);
         continue;
        }
      this.AddRow_TradingRisk(m_tabs_quickSetting,TAB_QUICK_SETTING_RISK_MANAGEMENT,m_sections_risk,section,row,k,name,M_RISK_LABEL_WIDTH,
                              0,RISK_COLUMN_VALUE,"RiskKey"+(string)k,TRADE_SLOT_LABEL);
      if(::RiskEnumItems(type,items)>0)
         this.AddEnum_TradingRisk(m_tabs_quickSetting,TAB_QUICK_SETTING_RISK_MANAGEMENT,m_sections_risk,section,row,RISK_COLUMN_VALUE,k,name,items,(int)risk.KeyValue(k),"RiskKeyEnum"+(string)k);
      else
         this.AddValue_TradingRisk(m_tabs_quickSetting,TAB_QUICK_SETTING_RISK_MANAGEMENT,m_sections_risk,section,row,RISK_COLUMN_VALUE,k,name,risk.KeyValue(k),"RiskKeyValue"+(string)k,
                                   (type=="int" ? 0 : 2),(type=="int" ? 1.0 : 0.1));
     }
   this.SyncSections_RiskSetting();
   m_sections_risk.Arrange();
  }
 //--- The switches follow Setting_Risk on RAM (the spin boxes and the comboboxes are what the user chose)
 void CGUIPannel::SyncSections_RiskSetting(void)
  {
   CRiskSetting *risk=(m_TradingControl!=NULL ? m_TradingControl.RiskSetting() : NULL);
   if(risk==NULL)
      return;
   for(int k=0;k<risk.KeysTotal();k++)
      if(risk.KeyType(k)=="bool")
         m_sections_risk.SetBodyState(k,TRADE_SLOT_KEY_SWITCH,risk.KeyValue(k)!=0);
  }
 //+------------------------------------------------------------------+
 //| What the user did in the Risk Management tab (param = the name)  |
 //+------------------------------------------------------------------+
 void CGUIPannel::OnEvent_Tab_Risk(const int id,const long &lparam,const double &dparam,const string &sparam)
  {
   //--- The sections: arranged again when the tab opens, scrolls, the window changes its size
   m_sections_risk.OnChartEvent(id,lparam,dparam,sparam);
   if(m_TradingControl==NULL)
      return;
   long row_id;
   int slot;
   string param;
   //--- A switch of a bool key: its value
   if(id==CHARTEVENT_CUSTOM+CLICK_EVENT_BUTTON && m_sections_risk.BodyOf(lparam,row_id,slot,param) && slot==TRADE_SLOT_KEY_SWITCH)
     {
      m_TradingControl.RiskSetting().SetValue(param,(dparam!=0 ? 1.0 : 0.0));
      this.SyncSections_RiskSetting();
      ::ChartRedraw(this.m_chart_id);
      return;
     }
   //--- The value of an int / double key: typed or stepped, dparam = the value
   if((id==CHARTEVENT_CUSTOM+CHANGE_EVENT_END_EDIT || id==CHARTEVENT_CUSTOM+CLICK_EVENT_INC || id==CHARTEVENT_CUSTOM+CLICK_EVENT_DEC) &&
      m_sections_risk.BodyOf(lparam,row_id,slot,param) && slot==TRADE_SLOT_KEY_VALUE)
     {
      m_TradingControl.RiskSetting().SetValue(param,dparam);
      return;
     }
   //--- An ENUM_ key: dparam = the index of the item = the value of the enum
   if(id==CHARTEVENT_CUSTOM+CLICK_EVENT_COMBOBOX_ITEM && m_sections_risk.BodyOf(lparam,row_id,slot,param) && slot==TRADE_SLOT_KEY_ENUM)
     {
      m_TradingControl.RiskSetting().SetValue(param,(double)(int)dparam);
      return;
     }
  }
#endif // CGUIPANNEL_TABQUICKSETTING_RISK_MQH
