//+------------------------------------------------------------------+
//|                                GUIPannel_TabQuickSetting_Risk.mqh |
//| Risk Management tab of Quick Setting: the keys of CRiskSetting    |
//| (Setting_Risk, the inputs of FixedMACrossover_Part7 as the author |
//| declared them), a section for each input group, a row for each    |
//| key in its order, the control by its type: bool a switch, ENUM_ a |
//| combobox of the texts of the author (RiskEnumItems), int / double |
//| a spin box, string not shown. Every key saved to DB is here, also |
//| RiskMode and the amount of each mode. Change in V5 (2026-11-25):  |
//| this tab saves to DB at once (SetValue save_now); the Trading tab |
//| works on RAM (written at OnDeinit). The View only tells           |
//| CRiskSetting (it fires RISK_SETTING_EVENT_CHANGED,                |
//| CTradingControl writes Setting_Risk); both tabs follow the event. |
//+------------------------------------------------------------------+
#ifndef CGUIPANNEL_TABQUICKSETTING_RISK_MQH
#define CGUIPANNEL_TABQUICKSETTING_RISK_MQH
#include "GUIPannel.mqh"
 //--- A property shown on this tab: not a string (the lists of V5 are the switches of the Trading tab)
 bool CGUIPannel::KeyShown_RiskSetting(CRiskSetting *risk,const int property)
  {
   return (!risk.IsString(property) && risk.PropertyGroup(property)!="V5");
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
   for(int k=0;k<risk.PropertiesTotal();k++)
     {
      const int p=risk.PropertyOfRow(k);
      if(!this.KeyShown_RiskSetting(risk,p))
         continue;
      const string group=risk.PropertyGroup(p);
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
   for(int k=0;k<risk.PropertiesTotal();k++)
     {
      const int p=risk.PropertyOfRow(k);
      if(!this.KeyShown_RiskSetting(risk,p))
         continue;
      int section=WRONG_VALUE;
      for(int s=0;s<sections && section<0;s++)
         if(m_risk_groups[s]==risk.PropertyGroup(p))
            section=s;
      if(section<0)
         continue;
      this.AddKeyRow_RiskSetting(m_tabs_quickSetting,TAB_QUICK_SETTING_RISK_MANAGEMENT,m_sections_risk,section,rows[section]++,p,M_RISK_LABEL_WIDTH,RISK_COLUMN_VALUE,"RiskKey");
     }
   this.SyncSections_RiskSetting();
   m_sections_risk.Arrange();
  }
 //--- A row of one property (value = the property, param = the name of its input): [name][control of its type] in the column given; key: the start
 //--- of the names of the objects (each tab its own). The Risk Management tab, and the Trading tab (the Manual Strategy on RAM)
 bool CGUIPannel::AddKeyRow_RiskSetting(CTabs &tabs,const int tab,CSections &sections,const int section,const int row,const int property,const int label_width,
                                        const int column,const string key)
  {
   CRiskSetting *risk=(m_TradingControl!=NULL ? m_TradingControl.RiskSetting() : NULL);
   if(risk==NULL || property<0 || property>=RISK_PROP_TOTAL)
      return false;
   const string name=risk.PropertyName(property);
   const string type=risk.PropertyType(property);
   if(type=="bool")
      return this.AddRow_TradingRisk(tabs,tab,sections,section,row,property,name,label_width,IMAGE_RESOURCE_BMP16_RISK_MANAGEMENT_ON_PNG,column,key+(string)property,TRADE_SLOT_KEY_SWITCH,name);
   if(!this.AddRow_TradingRisk(tabs,tab,sections,section,row,property,name,label_width,0,column,key+(string)property,TRADE_SLOT_LABEL))
      return false;
   string items[];
   if(::RiskEnumItems(type,items)>0)
      return this.AddEnum_TradingRisk(tabs,tab,sections,section,row,column,property,name,items,(int)risk.Value(property),key+"Enum"+(string)property);
   if(risk.IsString(property))
     {
      //--- a string property: typed, as the magic of Manual
      CTextEdit *edit=new CTextEdit();
      if(edit==NULL)
         return false;
      edit.Hide();
      tabs.AddToElementsArray(tab,edit);
      if(!edit.CreateTextEdit(this.m_chart_id,M_SUBWINDOW_MAIN,key+"Text"+(string)property,0,0,M_TRADE_MANUAL_ENTRY_WIDTH,M_CONTROL_HEIGHT,M_TRADE_MANUAL_ENTRY_WIDTH))
         return false;
      edit.SetText("");
      edit.SetValue(risk.Text(property));
      return sections.AddControl(section,edit,column,row,property,TRADE_SLOT_KEY_TEXT,name);
     }
   return this.AddValue_TradingRisk(tabs,tab,sections,section,row,column,property,name,risk.Value(property),key+"Value"+(string)property,
                                    (type=="int" ? 0 : 2),(type=="int" ? 1.0 : 0.1));
  }
 //--- The switches, the spin boxes and the comboboxes follow Setting_Risk on RAM (a key changed on the Trading tab shows here)
 void CGUIPannel::SyncSections_RiskSetting(void)
  {
   this.SyncValues_TradingRisk(m_sections_risk);
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
   //--- A key changed on RAM (this tab or the Trading tab): the controls follow it
   if(id==CHARTEVENT_CUSTOM+RISK_SETTING_EVENT_CHANGED)
     {
      this.SyncSections_RiskSetting();
      ::ChartRedraw(this.m_chart_id);
      return;
     }
   long row_id;
   int slot;
   string param;
   //--- What is set here is saved to DB at once (save_now)
   //--- A switch of a bool key: its value
   if(id==CHARTEVENT_CUSTOM+CLICK_EVENT_BUTTON && m_sections_risk.BodyOf(lparam,row_id,slot,param) && slot==TRADE_SLOT_KEY_SWITCH)
     {
      m_TradingControl.RiskSetting().SetValue(m_TradingControl.RiskSetting().Property(param),(dparam!=0 ? 1.0 : 0.0),true,true);
      this.SyncSections_RiskSetting();
      ::ChartRedraw(this.m_chart_id);
      return;
     }
   //--- The value of an int / double key: typed or stepped, dparam = the value
   if((id==CHARTEVENT_CUSTOM+CHANGE_EVENT_END_EDIT || id==CHARTEVENT_CUSTOM+CLICK_EVENT_INC || id==CHARTEVENT_CUSTOM+CLICK_EVENT_DEC) &&
      m_sections_risk.BodyOf(lparam,row_id,slot,param) && slot==TRADE_SLOT_KEY_VALUE)
     {
      m_TradingControl.RiskSetting().SetValue(m_TradingControl.RiskSetting().Property(param),dparam,true,true);
      return;
     }
   //--- An ENUM_ key: dparam = the index of the item = the value of the enum
   if(id==CHARTEVENT_CUSTOM+CLICK_EVENT_COMBOBOX_ITEM && m_sections_risk.BodyOf(lparam,row_id,slot,param) && slot==TRADE_SLOT_KEY_ENUM)
     {
      m_TradingControl.RiskSetting().SetValue(m_TradingControl.RiskSetting().Property(param),(double)(int)dparam,true,true);
      return;
     }
  }
#endif // CGUIPANNEL_TABQUICKSETTING_RISK_MQH
