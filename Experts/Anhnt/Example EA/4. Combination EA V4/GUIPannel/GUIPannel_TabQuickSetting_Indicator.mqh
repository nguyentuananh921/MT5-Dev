//+------------------------------------------------------------------+
//|                           GUIPannel_TabQuickSetting_Indicator.mqh |
//| Indicator tab: a section for each group of the indicators        |
//| (ENUM_INDICATOR_GROUP), a row for each template of               |
//| CIndicatorTemplateManager: the delete button, the name, and the  |
//| switches of its flags (show_on_chart, buy_signal, sell_signal,   |
//| sound_alert, message_alert), each with the icon of its flag. The |
//| three toggles of a section stand over the columns they rule: the |
//| first show_on_chart, the second buy_signal and sell_signal, the  |
//| third sound_alert and message_alert, of every template of the    |
//| group. What is shown on  |
//| the chart is the signal of the template. Every change is written |
//| to Setting_IndicatorTemplate at once                             |
//+------------------------------------------------------------------+
#ifndef CGUIPANNEL_TABQUICKSETTING_INDICATOR_MQH
#define CGUIPANNEL_TABQUICKSETTING_INDICATOR_MQH
#include "GUIPannel.mqh"
 //--- The sections, one for each group, and the Add button above them
 bool CGUIPannel::CreateSections_IndicatorTemplateSetting(const int y)
  {
   //--- Every change is written to the database at once: the tab has no Save button. The Add button is at the right, the sections under it
   m_btn_add_indicator.SetText("Add");
   m_btn_add_indicator.IconFile(IMAGE_RESOURCE_BMP16_ADD_GREEN_PNG);
   m_tabs_quickSetting.AddToElementsArray(TAB_QUICK_SETTING_INDICATOR,m_btn_add_indicator);
   if(!m_btn_add_indicator.Create(this.m_chart_id,M_SUBWINDOW_MAIN,"BtnAddIndicator",m_tabs_quickSetting.Width()-M_BUTTON_ADD_WIDTH-M_CONTROL_BORDER_GAP,y+M_CONTROL_BORDER_GAP,M_BUTTON_ADD_WIDTH,M_CONTROL_HEIGHT))
      return false;
   if(!m_sections_indicator.Create(this.m_chart_id,M_SUBWINDOW_MAIN,&m_tabs_quickSetting,TAB_QUICK_SETTING_INDICATOR,"SectionsIndicator"))
      return false;
   m_sections_indicator.SetTopOffset(M_CONTROL_BORDER_GAP+M_CONTROL_HEIGHT+M_CONTROL_BORDER_GAP);   // under the Add button
   int columns[INDICATOR_COLUMN_TOTAL]={0,M_INDICATOR_COLUMN_LABEL,M_INDICATOR_COLUMN_SHOW,M_INDICATOR_COLUMN_BUY_SIGNAL,M_INDICATOR_COLUMN_SELL_SIGNAL,M_INDICATOR_COLUMN_SOUND_ALERT,M_INDICATOR_COLUMN_MESSAGE_ALERT};
   m_sections_indicator.SetColumns(columns);
   const int toggle_x[3]={M_INDICATOR_TOGGLE_SHOW_X,M_INDICATOR_TOGGLE_SIGNAL_X,M_INDICATOR_TOGGLE_ALERT_X};
   m_sections_indicator.SetToggleColumns(toggle_x);
   const uint icons[3]={IMAGE_RESOURCE_BMP16_VISIBLE_PNG,IMAGE_RESOURCE_BMP16_SIGNAL_BUY_PNG,IMAGE_RESOURCE_BMP16_BELL_PNG};
   const bool states[3]={false,false,false};
   for(int g=0;g<INDICATOR_SECTIONS_TOTAL;g++)
      if(m_sections_indicator.AddSection(GetIndicatorGroupName(INDICATOR_SECTION_GROUPS[g]),icons,states,true)==WRONG_VALUE)
         return false;
   return true;
  }
 //--- The row of a template: [delete][name][show][buy_signal][sell_signal][sound_alert][message_alert]. The value of every control is the id of its template
 bool CGUIPannel::AddRow_IndicatorTemplateSetting(const int section,const int row,const long id,const string display,const bool show,const bool buy,const bool sell,const bool sound,const bool message)
  {
   const string key="Ind"+(string)id;
   CButton *remove=new CButton();
   CLabel *name=new CLabel();
   if(remove==NULL || name==NULL)
      return false;
   remove.IconFile(IMAGE_RESOURCE_BMP16_CLOSE_RED_PNG);
   m_tabs_quickSetting.AddToElementsArray(TAB_QUICK_SETTING_INDICATOR,remove);
   if(!remove.Create(this.m_chart_id,M_SUBWINDOW_MAIN,key+"_Delete",0,0,M_CONTROL_HEIGHT,M_CONTROL_HEIGHT))
      return false;
   m_sections_indicator.StyleSwitch(remove);
   if(!m_sections_indicator.AddControl(section,remove,INDICATOR_COLUMN_DELETE,row,id,INDICATOR_SLOT_DELETE))
      return false;
   name.SetText(display);
   name.LabelXGap(0);
   m_tabs_quickSetting.AddToElementsArray(TAB_QUICK_SETTING_INDICATOR,name);
   if(!name.Create(this.m_chart_id,M_SUBWINDOW_MAIN,key+"_Name",0,0,M_INDICATOR_LABEL_WIDTH,M_CONTROL_HEIGHT))
      return false;
   if(!m_sections_indicator.AddControl(section,name,INDICATOR_COLUMN_LABEL,row,id,INDICATOR_SLOT_LABEL))
      return false;
   const bool states[5]={show,buy,sell,sound,message};
   const uint icons[5]={IMAGE_RESOURCE_BMP16_VISIBLE_PNG,IMAGE_RESOURCE_BMP16_SIGNAL_BUY_PNG,IMAGE_RESOURCE_BMP16_SIGNAL_SELL_PNG,IMAGE_RESOURCE_BMP16_BELL_PNG,IMAGE_RESOURCE_BMP16_MESSAGE_PNG};
   const string names[5]={"_Show","_BuySignal","_SellSignal","_SoundAlert","_MessageAlert"};
   const int columns[5]={INDICATOR_COLUMN_SHOW,INDICATOR_COLUMN_BUY_SIGNAL,INDICATOR_COLUMN_SELL_SIGNAL,INDICATOR_COLUMN_SOUND_ALERT,INDICATOR_COLUMN_MESSAGE_ALERT};
   const int slots[5]={INDICATOR_SLOT_SHOW_ON_CHART,INDICATOR_SLOT_BUY_SIGNAL,INDICATOR_SLOT_SELL_SIGNAL,INDICATOR_SLOT_SOUND_ALERT,INDICATOR_SLOT_MESSAGE_ALERT};
   for(int flag=0;flag<5;flag++)
     {
      CButtonTriggered *toggle=new CButtonTriggered();
      if(toggle==NULL)
         return false;
      m_sections_indicator.FlagSwitch(toggle,icons[flag]);
      toggle.SetState(states[flag]);
      m_tabs_quickSetting.AddToElementsArray(TAB_QUICK_SETTING_INDICATOR,toggle);
      if(!toggle.Create(this.m_chart_id,M_SUBWINDOW_MAIN,key+names[flag],0,0,M_FLAG_SWITCH_WIDTH,M_CONTROL_HEIGHT))
         return false;
      m_sections_indicator.StyleSwitch(toggle);
      if(!m_sections_indicator.AddControl(section,toggle,columns[flag],row,id,slots[flag]))
         return false;
     }
   return true;
  }
 //--- The rows are made again from the templates: one came or went. The sections keep their toggles
 void CGUIPannel::PopulateSections_IndicatorTemplateSetting(void)
  {
   if(m_IndicatorTemplateManager==NULL)
      return;
   long ids[];
   ENUM_INDICATOR types[];
   string params[],display[];
   bool buy[],sell[],sound[],message[],show[];
   int total=m_IndicatorTemplateManager.Templates(ids,types,params,display,buy,sell,sound,message,show);
   for(int g=0;g<INDICATOR_SECTIONS_TOTAL;g++)
     {
      m_sections_indicator.ClearBody(g);
      int row=0;
      for(int i=0;i<total;i++)
         if(GetIndicatorGroupForType(types[i])==INDICATOR_SECTION_GROUPS[g])
            this.AddRow_IndicatorTemplateSetting(g,row++,ids[i],display[i],show[i],buy[i],sell[i],sound[i],message[i]);
     }
   this.SyncSections_IndicatorTemplateSetting();
   m_sections_indicator.Arrange();
  }
 //--- The switches take their state from the database, the toggle of a section is ON while any switch of its two columns is
 void CGUIPannel::SyncSections_IndicatorTemplateSetting(void)
  {
   if(m_IndicatorTemplateManager==NULL)
      return;
   long ids[];
   ENUM_INDICATOR types[];
   string params[],display[];
   bool buy[],sell[],sound[],message[],show[];
   int total=m_IndicatorTemplateManager.Templates(ids,types,params,display,buy,sell,sound,message,show);
   bool any_show[INDICATOR_SECTIONS_TOTAL],any_signal[INDICATOR_SECTIONS_TOTAL],any_alert[INDICATOR_SECTIONS_TOTAL];
   ::ArrayInitialize(any_show,false);
   ::ArrayInitialize(any_signal,false);
   ::ArrayInitialize(any_alert,false);
   for(int i=0;i<total;i++)
     {
      m_sections_indicator.SetBodyState(ids[i],INDICATOR_SLOT_SHOW_ON_CHART,show[i]);
      m_sections_indicator.SetBodyState(ids[i],INDICATOR_SLOT_BUY_SIGNAL,buy[i]);
      m_sections_indicator.SetBodyState(ids[i],INDICATOR_SLOT_SELL_SIGNAL,sell[i]);
      m_sections_indicator.SetBodyState(ids[i],INDICATOR_SLOT_SOUND_ALERT,sound[i]);
      m_sections_indicator.SetBodyState(ids[i],INDICATOR_SLOT_MESSAGE_ALERT,message[i]);
      for(int g=0;g<INDICATOR_SECTIONS_TOTAL;g++)
         if(GetIndicatorGroupForType(types[i])==INDICATOR_SECTION_GROUPS[g])
           {
            any_show[g]=(any_show[g] || show[i]);
            any_signal[g]=(any_signal[g] || buy[i] || sell[i]);
            any_alert[g]=(any_alert[g] || sound[i] || message[i]);
           }
     }
   for(int g=0;g<INDICATOR_SECTIONS_TOTAL;g++)
     {
      m_sections_indicator.SetToggle(g,INDICATOR_TOGGLE_SHOW,any_show[g]);
      m_sections_indicator.SetToggle(g,INDICATOR_TOGGLE_SIGNAL,any_signal[g]);
      m_sections_indicator.SetToggle(g,INDICATOR_TOGGLE_ALERT,any_alert[g]);
     }
  }
 //--- The template of an id: the key the manager knows it by
 bool CGUIPannel::TemplateOfId_IndicatorTemplateSetting(const long id,ENUM_INDICATOR &type,string &params_text)
  {
   if(m_IndicatorTemplateManager==NULL)
      return false;
   long ids[];
   ENUM_INDICATOR types[];
   string params[];
   bool buy[],sell[];
   int total=m_IndicatorTemplateManager.TemplateIds(ids,types,params,buy,sell);
   for(int i=0;i<total;i++)
      if(ids[i]==id)
        {
         type=types[i];
         params_text=params[i];
         return true;
        }
   return false;
  }
 //+------------------------------------------------------------------+
 //| What the user (or the manager) did that the Indicator tab shows  |
 //+------------------------------------------------------------------+
 void CGUIPannel::OnEvent_Tab_Indicator(const int id,const long &lparam,const double &dparam,const string &sparam)
  {
   //--- The tab was opened, the scroll moved, a window changed its size, a header was clicked: the sections are arranged again
   m_sections_indicator.OnChartEvent(id,lparam,dparam,sparam);
   //--- The window changed its width: the Add button stays at the right of the tab
   if(id==CHARTEVENT_CUSTOM+WINDOW_EVENT_CHANGE_XSIZE && lparam==m_window_main.ObjectID())
     {
      m_btn_add_indicator.Move(m_tabs_quickSetting.X()+m_tabs_quickSetting.Width()-M_BUTTON_ADD_WIDTH-M_CONTROL_BORDER_GAP,m_btn_add_indicator.Y());
      return;
     }
   //--- A template came or went: the rows are made again
   if(id==CHARTEVENT_CUSTOM+INDICATOR_TEMPLATE_MANAGER_EVENT_ADDED || id==CHARTEVENT_CUSTOM+INDICATOR_TEMPLATE_MANAGER_EVENT_DELETE)
     {
      this.PopulateSections_IndicatorTemplateSetting();
      this.SyncTreeView_IndicatorTemplateSetting();   // the blue arrow of a type that has a template
      ::ChartRedraw(this.m_chart_id);
      return;
     }
   //--- A flag changed for real (maybe from the chart side): the switches follow it
   if(id==CHARTEVENT_CUSTOM+INDICATOR_TEMPLATE_MANAGER_EVENT_BUYSELL_CHANGED || id==CHARTEVENT_CUSTOM+INDICATOR_TEMPLATE_MANAGER_EVENT_SHOW_CHANGED)
     {
      this.SyncSections_IndicatorTemplateSetting();
      ::ChartRedraw(this.m_chart_id);
      return;
     }
   if(id!=CHARTEVENT_CUSTOM+CLICK_EVENT_BUTTON || m_IndicatorTemplateManager==NULL)
      return;
   //--- A toggle of a group: its column or its two columns go on or off, dparam = the new state
   int which;
   int section=m_sections_indicator.SectionOfToggle(lparam,which);
   if(section!=WRONG_VALUE)
     {
      const ENUM_INDICATOR_GROUP group=INDICATOR_SECTION_GROUPS[section];
      if(which==INDICATOR_TOGGLE_SHOW)
         m_IndicatorTemplateManager.ShowGroup(group,dparam!=0);
      else if(which==INDICATOR_TOGGLE_SIGNAL)
         m_IndicatorTemplateManager.SignalGroup(group,dparam!=0);
      else
         m_IndicatorTemplateManager.AlertGroup(group,dparam!=0);
      this.SyncSections_IndicatorTemplateSetting();
      return;
     }
   //--- A control of a row: the delete button, or the switch of a flag
   long template_id;
   int slot;
   string param;
   ENUM_INDICATOR type;
   string params_text;
   if(!m_sections_indicator.BodyOf(lparam,template_id,slot,param) || !this.TemplateOfId_IndicatorTemplateSetting(template_id,type,params_text))
      return;
   if(slot==INDICATOR_SLOT_DELETE)
      m_IndicatorTemplateManager.Delete_IndicatorTemplateSetting(type,params_text);
   else if(slot==INDICATOR_SLOT_SHOW_ON_CHART)
      m_IndicatorTemplateManager.ShowOnChart(type,params_text,dparam!=0);
   else if(slot==INDICATOR_SLOT_BUY_SIGNAL)
      m_IndicatorTemplateManager.BuySignal(type,params_text,dparam!=0);
   else if(slot==INDICATOR_SLOT_SELL_SIGNAL)
      m_IndicatorTemplateManager.SellSignal(type,params_text,dparam!=0);
   else if(slot==INDICATOR_SLOT_SOUND_ALERT)
      m_IndicatorTemplateManager.SoundAlert(type,params_text,dparam!=0);
   else if(slot==INDICATOR_SLOT_MESSAGE_ALERT)
      m_IndicatorTemplateManager.MessageAlert(type,params_text,dparam!=0);
   this.SyncSections_IndicatorTemplateSetting();
  }
#endif // CGUIPANNEL_TABQUICKSETTING_INDICATOR_MQH
