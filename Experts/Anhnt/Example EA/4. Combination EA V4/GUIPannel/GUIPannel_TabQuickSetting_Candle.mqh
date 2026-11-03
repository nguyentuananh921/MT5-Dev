//+------------------------------------------------------------------+
//|                              GUIPannel_TabQuickSetting_Candle.mqh |
//| Candle tab: a section for each group of the information of a bar |
//| (ENUM_BAR_INFORMATION_GROUP). The two toggles of a section stand |
//| over the columns they rule: the first the show_buy_signal and    |
//| show_sell_signal of every type of the group (what the chart      |
//| shows), the second their sound_alert and message_alert;          |
//| its body, opened by the blue arrow, has a block for each type:   |
//| the arrow and the name, the four switches (show_buy_signal,      |
//| show_sell_signal, sound_alert, message_alert) and (opened) the edits |
//| of its parameters. Every change is written to                     |
//| Setting_BarInformation / Setting_BarSetup at once                |
//+------------------------------------------------------------------+
#ifndef CGUIPANNEL_TABQUICKSETTING_CANDLE_MQH
#define CGUIPANNEL_TABQUICKSETTING_CANDLE_MQH
#include "GUIPannel.mqh"
 //--- One section for each group (its index is the group), closed at the start: its body is made when it is first opened (CreateBody_BarInformation)
 bool CGUIPannel::CreateSections_BarInformation(void)
  {
   if(!m_sections_candle.Create(this.m_chart_id,M_SUBWINDOW_MAIN,&m_tabs_quickSetting,TAB_QUICK_SETTING_CANDLE,"SectionsCandle"))
      return false;
   int columns[CANDLE_COLUMN_TOTAL]={0,M_CANDLE_COLUMN_CANDLES,M_CANDLE_COLUMN_SHOW_BUY,M_CANDLE_COLUMN_SHOW_SELL,M_CANDLE_COLUMN_SOUND_ALERT,M_CANDLE_COLUMN_MESSAGE_ALERT,M_CANDLE_PARAM_INDENT,M_CANDLE_COLUMN_PARAM_VALUE};   // the x of the columns, in the order of ENUM_CANDLE_COLUMN
   m_sections_candle.SetColumns(columns);
   const int toggle_x[2]={M_CANDLE_TOGGLE_SHOW_X,M_CANDLE_TOGGLE_ALERT_X};   // the toggles of a header stand over the two columns each of them rules
   m_sections_candle.SetToggleColumns(toggle_x);
   for(int g=0;g<BAR_INFORMATION_GROUP_TOTAL;g++)
     {
      ENUM_BAR_INFORMATION_GROUP group=(ENUM_BAR_INFORMATION_GROUP)g;
      bool on=(m_BarInformationManager!=NULL && m_BarInformationManager.AnyShow(group));
      bool alert=(m_BarInformationManager!=NULL && m_BarInformationManager.AnyAlert(group));
      const uint icons[2]={IMAGE_RESOURCE_BMP16_SIGNAL_BUY_PNG,IMAGE_RESOURCE_BMP16_BELL_PNG};
      const bool states[2]={on,alert};
      if(m_sections_candle.AddSection((m_BarInformationManager!=NULL ? m_BarInformationManager.GroupDescription(group) : ""),icons,states,false)==WRONG_VALUE)
         return false;
     }
   return true;
  }
 //--- The body of a section: a type of its group is a block, only the types with a side or a parameter (the states from the manager now)
 bool CGUIPannel::CreateBody_BarInformation(const int section)
  {
   if(m_BarInformationManager==NULL)
      return true;
   ENUM_BAR_INFOR_TYPE types[];
   string names[];
   ENUM_BAR_INFORMATION_GROUP groups[];
   int candles[];
   bool have_buy[],have_sell[],sound[],message[],show_buy[],show_sell[];
   int total=m_BarInformationManager.Informations(types,names,groups,candles,have_buy,have_sell,sound,message,show_buy,show_sell);
   int row=0;
   for(int i=0;i<total;i++)
     {
      if((int)groups[i]!=section)
         continue;
      string params[],displays[];
      double values[];
      if(!have_buy[i] && !have_sell[i] && m_BarInformationManager.Params(types[i],params,displays,values)==0)
         continue;
      if(!this.CreateBlock_BarInformation(section,row,types[i],names[i],candles[i],have_buy[i],have_sell[i],show_buy[i],show_sell[i],sound[i],message[i]))
         return false;
     }
   return true;
  }
 //--- The block of a type from the row: [arrow + name][candles][show_buy_signal][show_sell_signal][sound_alert][message_alert], each switch with the icon of its flag (the
 //--- switch of a side the type has not stays out), then (while opened) the edits of its parameters, one in a row
 bool CGUIPannel::CreateBlock_BarInformation(const int section,int &row,const ENUM_BAR_INFOR_TYPE type,const string name,const int candles,const bool have_buy,const bool have_sell,const bool show_buy,const bool show_sell,const bool sound,const bool message)
  {
   const long value=(long)type;
   const string key="Candle"+(string)(int)type;
   CButtonTriggered *header=new CButtonTriggered();
   if(header==NULL)
      return false;
   header.SetText(name);
   header.IconFile(IMAGE_RESOURCE_BMP16_ARROWRIGHT_BLUE_BMP);
   header.IconFileLocked(IMAGE_RESOURCE_BMP16_ARROWRIGHT_BLUE_BMP);
   header.IconFilePressed(IMAGE_RESOURCE_BMP16_ARROWDOWN_BLUE_BMP);
   header.IconFilePressedLocked(IMAGE_RESOURCE_BMP16_ARROWDOWN_BLUE_BMP);
   header.SetState(false);
   header.Hide();   // every control of the block is born hidden (no chart redraw at 0,0): Arrange shows it in its place
   m_tabs_quickSetting.AddToElementsArray(TAB_QUICK_SETTING_CANDLE,header);
   if(!header.Create(this.m_chart_id,M_SUBWINDOW_MAIN,key+"_Header",0,0,M_CANDLE_NAME_WIDTH,M_CONTROL_HEIGHT))
      return false;
   m_sections_candle.StyleSwitch(header);
   if(!m_sections_candle.AddControl(section,header,CANDLE_COLUMN_NAME,row,value,CANDLE_SLOT_HEADER,"",true,false))
      return false;
   //--- How many candles make the type
   CLabel *count=new CLabel();
   if(count==NULL)
      return false;
   count.SetText((string)candles);
   count.Hide();
   m_tabs_quickSetting.AddToElementsArray(TAB_QUICK_SETTING_CANDLE,count);
   if(!count.Create(this.m_chart_id,M_SUBWINDOW_MAIN,key+"_Candles",0,0,M_CANDLE_CANDLES_WIDTH,M_CONTROL_HEIGHT))
      return false;
   if(!m_sections_candle.AddControl(section,count,CANDLE_COLUMN_CANDLES,row,value,CANDLE_SLOT_CANDLES))
      return false;
   //--- A switch for each flag the type has: the icon of the flag, then the switch. Sound and message need a side: the type has Buy, Sell or both
   const bool exists[4]={have_buy,have_sell,(have_buy || have_sell),(have_buy || have_sell)};
   const bool states[4]={show_buy,show_sell,sound,message};
   const uint icons[4]={IMAGE_RESOURCE_BMP16_SIGNAL_BUY_PNG,IMAGE_RESOURCE_BMP16_SIGNAL_SELL_PNG,IMAGE_RESOURCE_BMP16_BELL_PNG,IMAGE_RESOURCE_BMP16_MESSAGE_PNG};
   const string names_of_flag[4]={"_ShowBuy","_ShowSell","_SoundAlert","_MessageAlert"};
   const int columns[4]={CANDLE_COLUMN_SHOW_BUY,CANDLE_COLUMN_SHOW_SELL,CANDLE_COLUMN_SOUND_ALERT,CANDLE_COLUMN_MESSAGE_ALERT};
   const int slots[4]={CANDLE_SLOT_SHOW_BUY,CANDLE_SLOT_SHOW_SELL,CANDLE_SLOT_SOUND_ALERT,CANDLE_SLOT_MESSAGE_ALERT};
   for(int flag=0;flag<4;flag++)
     {
      if(!exists[flag])
         continue;
      CButtonTriggered *toggle=new CButtonTriggered();
      if(toggle==NULL)
         return false;
      m_sections_candle.FlagSwitch(toggle,icons[flag]);
      toggle.SetState(states[flag]);
      toggle.Hide();
      m_tabs_quickSetting.AddToElementsArray(TAB_QUICK_SETTING_CANDLE,toggle);
      if(!toggle.Create(this.m_chart_id,M_SUBWINDOW_MAIN,key+names_of_flag[flag],0,0,M_FLAG_SWITCH_WIDTH,M_CONTROL_HEIGHT))
         return false;
      m_sections_candle.StyleSwitch(toggle);
      if(!m_sections_candle.AddControl(section,toggle,columns[flag],row,value,slots[flag]))
         return false;
     }
   row++;
   string params[],displays[];
   double values[];
   int total=m_BarInformationManager.Params(type,params,displays,values);
   for(int k=0;k<total;k++)
     {
      //--- A choice of two (the price basis): the name at the left and, where the box of the other parameters is, a switch (OFF = Wick, ON = Body)
      if(params[k]==BAR_PARAM_PRICE_BASIS)
        {
         CLabel *name_label=new CLabel();
         CButtonTriggered *choice=new CButtonTriggered();
         if(name_label==NULL || choice==NULL)
            return false;
         name_label.SetText(displays[k]!="" ? displays[k] : params[k]);
         name_label.LabelXGap(0);
         name_label.Hide();
         m_tabs_quickSetting.AddToElementsArray(TAB_QUICK_SETTING_CANDLE,name_label);
         if(!name_label.Create(this.m_chart_id,M_SUBWINDOW_MAIN,key+"_ParamName"+(string)k,0,0,M_CANDLE_PARAM_WIDTH-M_CANDLE_PARAM_EDIT_WIDTH,M_CONTROL_HEIGHT))
            return false;
         if(!m_sections_candle.AddControl(section,name_label,CANDLE_COLUMN_PARAM,row+k,value,CANDLE_SLOT_PARAM_LABEL,"",false,true))
            return false;
         choice.SetText(params[k]==BAR_PARAM_PRICE_BASIS ? "Body" : "");
         choice.IconFile(IMAGE_RESOURCE_BMP16_SWITCH_OFF_RED_PNG);
         choice.IconFileLocked(IMAGE_RESOURCE_BMP16_SWITCH_OFF_RED_PNG);
         choice.IconFilePressed(IMAGE_RESOURCE_BMP16_SWITCH_ON_GREEN_PNG);
         choice.IconFilePressedLocked(IMAGE_RESOURCE_BMP16_SWITCH_ON_GREEN_PNG);
         choice.SetState(params[k]==BAR_PARAM_PRICE_BASIS ? values[k]==(double)SWING_PRICE_BASIS_BODY : values[k]!=0);
         choice.Hide();
         m_tabs_quickSetting.AddToElementsArray(TAB_QUICK_SETTING_CANDLE,choice);
         if(!choice.Create(this.m_chart_id,M_SUBWINDOW_MAIN,key+"_Param"+(string)k,0,0,M_CANDLE_PARAM_EDIT_WIDTH,M_CONTROL_HEIGHT))
            return false;
         m_sections_candle.StyleSwitch(choice);
         if(!m_sections_candle.AddControl(section,choice,CANDLE_COLUMN_PARAM_VALUE,row+k,value,CANDLE_SLOT_PARAM_SWITCH,params[k],false,true))
            return false;
         continue;
        }
      CTextEdit *edit=new CTextEdit();
      if(edit==NULL)
         return false;
      bool decimal=(params[k]==BAR_PARAM_BODY_MULTIPLIER);
      edit.SpinEditMode(true);
      edit.Digits(decimal ? M_CANDLE_PARAM_DECIMALS : 0);
      edit.StepValue(decimal ? M_CANDLE_PARAM_DECIMAL_STEP : 1);
      edit.MinValue(0);
      edit.MaxValue(params[k]==BAR_PARAM_TOLERANCE_POINTS ? M_CANDLE_PARAM_POINTS_MAX : M_CANDLE_PARAM_MAX);
      edit.Hide();
      m_tabs_quickSetting.AddToElementsArray(TAB_QUICK_SETTING_CANDLE,edit);
      if(!edit.CreateTextEdit(this.m_chart_id,M_SUBWINDOW_MAIN,key+"_Param"+(string)k,0,0,M_CANDLE_PARAM_WIDTH,M_CONTROL_HEIGHT,M_CANDLE_PARAM_EDIT_WIDTH))
         return false;
      edit.SetText(displays[k]!="" ? displays[k] : params[k]);
      edit.SetValue(::DoubleToString(values[k],decimal ? M_CANDLE_PARAM_DECIMALS : 0));
      if(!m_sections_candle.AddControl(section,edit,CANDLE_COLUMN_PARAM,row+k,value,CANDLE_SLOT_PARAM,params[k],false,true))
         return false;
     }
   row+=total;
   return true;
  }
 //--- The toggles and the boxes take their state from the database; a toggle is ON when the markers of any type of its group are shown
 void CGUIPannel::SyncSections_BarInformation(void)
  {
   if(m_BarInformationManager==NULL)
      return;
   for(int g=0;g<BAR_INFORMATION_GROUP_TOTAL;g++)
     {
      m_sections_candle.SetToggle(g,CANDLE_TOGGLE_SHOW,m_BarInformationManager.AnyShow((ENUM_BAR_INFORMATION_GROUP)g));
      m_sections_candle.SetToggle(g,CANDLE_TOGGLE_ALERT,m_BarInformationManager.AnyAlert((ENUM_BAR_INFORMATION_GROUP)g));
     }
   ENUM_BAR_INFOR_TYPE types[];
   string names[];
   ENUM_BAR_INFORMATION_GROUP groups[];
   int candles[];
   bool have_buy[],have_sell[],sound[],message[],show_buy[],show_sell[];
   int total=m_BarInformationManager.Informations(types,names,groups,candles,have_buy,have_sell,sound,message,show_buy,show_sell);
   for(int i=0;i<total;i++)
     {
      if(have_buy[i])
         m_sections_candle.SetBodyState((long)types[i],CANDLE_SLOT_SHOW_BUY,show_buy[i]);
      if(have_sell[i])
         m_sections_candle.SetBodyState((long)types[i],CANDLE_SLOT_SHOW_SELL,show_sell[i]);
      if(have_buy[i] || have_sell[i])
        {
         m_sections_candle.SetBodyState((long)types[i],CANDLE_SLOT_SOUND_ALERT,sound[i]);
         m_sections_candle.SetBodyState((long)types[i],CANDLE_SLOT_MESSAGE_ALERT,message[i]);
        }
     }
  }
 //+------------------------------------------------------------------+
 //| What the user (or the manager) did that the Candle tab shows     |
 //+------------------------------------------------------------------+
 void CGUIPannel::OnEvent_Tab_Candle(const int id,const long &lparam,const double &dparam,const string &sparam)
  {
   //--- A section opened for the first time: its body is made before the sections are arranged
   if(id==CHARTEVENT_CUSTOM+CLICK_EVENT_BUTTON)
     {
      int section=m_sections_candle.SectionOfHeader(lparam);
      if(section!=WRONG_VALUE && m_sections_candle.RowsTotal(section)==0)
        {
         Breadcrumb("OnEvent_Tab_Candle: CreateBody_BarInformation "+(string)section);   // MY DEBUG: the next step tells how long it took
         this.CreateBody_BarInformation(section);
        }
     }
   //--- The tab was opened, the scroll moved, a window changed its size, a header was clicked: the sections are arranged again (the section hears it itself)
   m_sections_candle.OnChartEvent(id,lparam,dparam,sparam);
   if(id==CHARTEVENT_CUSTOM+CLICK_EVENT_BUTTON && m_sections_candle.SectionOfHeader(lparam)!=WRONG_VALUE)
      return;
   //--- A toggle of a group, or a switch of a type: written to the database at once (the chart follows the event of the manager); dparam = the new state
   if(id==CHARTEVENT_CUSTOM+CLICK_EVENT_BUTTON)
     {
      if(m_BarInformationManager==NULL)
         return;
      int which;
      int section=m_sections_candle.SectionOfToggle(lparam,which);
      if(section!=WRONG_VALUE)
        {
         if(which==CANDLE_TOGGLE_SHOW)
            m_BarInformationManager.ShowGroup((ENUM_BAR_INFORMATION_GROUP)section,dparam!=0);
         else
            m_BarInformationManager.AlertGroup((ENUM_BAR_INFORMATION_GROUP)section,dparam!=0);
         this.SyncSections_BarInformation();   // the switches of the two columns follow the toggle, a group with none of them on stays OFF
         return;
        }
      long type;
      int slot;
      string param;
      if(!m_sections_candle.BodyOf(lparam,type,slot,param) || slot==CANDLE_SLOT_HEADER)
         return;   // the header of a type opens and closes its parameters (the sections arranged them)
      if(slot==CANDLE_SLOT_PARAM_SWITCH)
        {
         //--- A choice of two: the value is written (price basis: ON = Body)
         m_BarInformationManager.Param((ENUM_BAR_INFOR_TYPE)type,param,param==BAR_PARAM_PRICE_BASIS ? (dparam!=0 ? (double)SWING_PRICE_BASIS_BODY : (double)SWING_PRICE_BASIS_WICK) : (dparam!=0 ? 1.0 : 0.0));
         return;
        }
      if(slot==CANDLE_SLOT_SHOW_BUY)
         m_BarInformationManager.ShowBuySignal((ENUM_BAR_INFOR_TYPE)type,dparam!=0);
      else if(slot==CANDLE_SLOT_SHOW_SELL)
         m_BarInformationManager.ShowSellSignal((ENUM_BAR_INFOR_TYPE)type,dparam!=0);
      else if(slot==CANDLE_SLOT_SOUND_ALERT)
         m_BarInformationManager.SoundAlert((ENUM_BAR_INFOR_TYPE)type,dparam!=0);
      else if(slot==CANDLE_SLOT_MESSAGE_ALERT)
         m_BarInformationManager.MessageAlert((ENUM_BAR_INFOR_TYPE)type,dparam!=0);
      this.SyncSections_BarInformation();
      return;
     }
   //--- An edit of a parameter: typed or stepped, the new value is written; dparam = the value
   if(id==CHARTEVENT_CUSTOM+CHANGE_EVENT_END_EDIT || id==CHARTEVENT_CUSTOM+CLICK_EVENT_INC || id==CHARTEVENT_CUSTOM+CLICK_EVENT_DEC)
     {
      long type;
      int slot;
      string param;
      if(m_BarInformationManager==NULL || !m_sections_candle.BodyOf(lparam,type,slot,param) || slot!=CANDLE_SLOT_PARAM)
         return;
      m_BarInformationManager.Param((ENUM_BAR_INFOR_TYPE)type,param,dparam);
      return;
     }
   //--- The manager changed for real: the toggles and the boxes follow it
   if(id==CHARTEVENT_CUSTOM+BAR_INFORMATION_MANAGER_EVENT_SHOW_CHANGED)
     {
      this.SyncSections_BarInformation();
      ::ChartRedraw(this.m_chart_id);
     }
  }
#endif // CGUIPANNEL_TABQUICKSETTING_CANDLE_MQH
