//+------------------------------------------------------------------+
//|                            GUIPannel_TabQuickSetting_Strategy.mqh |
//| Strategy tab: a section for each strategy of CStrategyManager    |
//| (its name). The toggles of its header: show on the chart (not    |
//| wired yet), trade (ON: the templates of its indicators are made  |
//| in CIndicatorTemplateManager) and available (every slot has its  |
//| source: a template of these params, a type of                    |
//| CBarInformationManager). Its body has a row for each slot: edit  |
//| (not wired yet) and the name with the params                     |
//+------------------------------------------------------------------+
#ifndef CGUIPANNEL_TABQUICKSETTING_STRATEGY_MQH
#define CGUIPANNEL_TABQUICKSETTING_STRATEGY_MQH
#include "GUIPannel.mqh"
 //--- One section for each strategy, in the order of Setting_Strategy (its index is the place of the strategy in Read_RAM(ids)), opened
 bool CGUIPannel::CreateSections_Strategy(void)
  {
   if(!m_sections_strategy.Create(this.m_chart_id,M_SUBWINDOW_MAIN,&m_tabs_quickSetting,TAB_QUICK_SETTING_STRATEGY,"SectionsStrategy"))
      return false;
   int columns[STRATEGY_COLUMN_TOTAL]={0,M_INDICATOR_COLUMN_LABEL};
   m_sections_strategy.SetColumns(columns);
   const int toggle_x[3]={M_STRATEGY_TOGGLE_SHOW_X,M_STRATEGY_TOGGLE_TRADE_X,M_STRATEGY_TOGGLE_AVAILABLE_X};
   m_sections_strategy.SetToggleColumns(toggle_x);
   if(m_StrategyManager==NULL)
      return true;
   long ids[];
   int total=m_StrategyManager.Read_RAM(ids);
   const uint icons[3]={IMAGE_RESOURCE_BMP16_VISIBLE_PNG,IMAGE_RESOURCE_BMP16_TRADE_ON_PNG,IMAGE_RESOURCE_BMP16_CHECK_MARK_GEEN_PNG};
   const bool states[3]={false,false,false};
   for(int s=0;s<total;s++)
     {
      CStrategySetting *strategy=m_StrategyManager.Read_RAM(ids[s]);
      if(strategy==NULL)
         continue;
      int section=m_sections_strategy.AddSection(strategy.Name(),icons,states,true);
      if(section==WRONG_VALUE || !this.AddRow_Strategy(section,strategy))
         return false;
     }
   this.SyncSections_Strategy();
   return true;
  }
 //--- The rows of a section, each [edit][text]: the tf of the strategy first, then a row for each slot (name (params)).
 //--- The value of every control is section * M_STRATEGY_SLOTS_MAX + the slot (M_STRATEGY_ROW_TF: the tf)
 bool CGUIPannel::AddRow_Strategy(const int section,CStrategySetting *strategy)
  {
   for(int row=0;row<=strategy.IndicatorsTotal();row++)
     {
      long value=(long)section*M_STRATEGY_SLOTS_MAX+M_STRATEGY_ROW_TF;
      string text="Timeframe  (Default: the chart)";
      if(strategy.Timeframe()!=PERIOD_CURRENT)
         text="Timeframe  ("+::StringSubstr(::EnumToString(strategy.Timeframe()),7)+")";   // PERIOD_M15 -> M15
      if(row>0)
        {
         value=(long)section*M_STRATEGY_SLOTS_MAX+row-1;
         text=this.SlotText_Strategy(strategy.Indicator(row-1));
        }
      const string key="Strategy"+(string)value;
      CButton *edit=new CButton();
      CLabel *name=new CLabel();
      if(edit==NULL || name==NULL)
         return false;
      edit.IconFile(IMAGE_RESOURCE_BMP16_EDIT_PNG);
      m_tabs_quickSetting.AddToElementsArray(TAB_QUICK_SETTING_STRATEGY,edit);
      if(!edit.Create(this.m_chart_id,M_SUBWINDOW_MAIN,key+"_Edit",0,0,M_CONTROL_HEIGHT,M_CONTROL_HEIGHT))
         return false;
      edit.Hide();   // made at 0,0: Arrange shows it at its place
      m_sections_strategy.StyleSwitch(edit);
      if(!m_sections_strategy.AddControl(section,edit,STRATEGY_COLUMN_EDIT,row,value,STRATEGY_SLOT_EDIT))
         return false;
      name.SetText(text);
      name.LabelXGap(0);
      m_tabs_quickSetting.AddToElementsArray(TAB_QUICK_SETTING_STRATEGY,name);
      if(!name.Create(this.m_chart_id,M_SUBWINDOW_MAIN,key+"_Name",0,0,M_INDICATOR_LABEL_WIDTH,M_CONTROL_HEIGHT))
         return false;
      name.Hide();
      if(!m_sections_strategy.AddControl(section,name,STRATEGY_COLUMN_LABEL,row,value,STRATEGY_SLOT_LABEL))
         return false;
     }
   return true;
  }
 //--- What the row shows: the slot, then the params it reads (CStrategyManager) as the templates show them ("Alligator  (13, 8, 8, 5, 5, 3, SMMA, MEDIAN)")
 string CGUIPannel::SlotText_Strategy(CStrategyIndicatorSetting *slot)
  {
   string params=m_StrategyManager.Read_RAM(slot);
   if(slot.Collection()!=COLLECTION_SIGNALS_ID || params=="")
      return slot.Slot();
   ::StringReplace(params,",",", ");
   return slot.Slot()+"  ("+params+")";
  }
 //--- Edit of a row (value = section * M_STRATEGY_SLOTS_MAX + slot): the form of the Add Indicator window shows the params of the slot and its tf, Save writes them.
 //--- The row of the tf (M_STRATEGY_ROW_TF): the form shows only the tf of the strategy
 void CGUIPannel::OpenWindow_EditSlot_Strategy(const long value)
  {
   long ids[];
   const int section=(int)(value/M_STRATEGY_SLOTS_MAX);
   if(m_StrategyManager==NULL || section>=m_StrategyManager.Read_RAM(ids))
      return;
   CStrategySetting *strategy=m_StrategyManager.Read_RAM(ids[section]);
   if(strategy!=NULL && value%M_STRATEGY_SLOTS_MAX==M_STRATEGY_ROW_TF)
     {
      m_window_addIndicator.OpenWindow();
      this.Mode_AddIndicator(strategy.StrategyId(),"");
      m_frame_indicator_parameter.Show();   // cascades to every control of the form: only the tf and the button stay
      for(int i=0;i<INDICATOR_PARAM_SLOTS_MAX;i++)
        {
         m_param_edits[i].Hide();
         m_param_combo[i].Hide();
        }
      for(int i=0;i<M_STRATEGY_TF_TOTAL;i++)
         if(STRATEGY_TFS[i]==strategy.Timeframe())
            m_combo_param_tf.SelectItem(i);
      m_combo_param_tf.GetListViewPointer().Draw(false);
      m_combo_param_tf.Move(m_frame_indicator_parameter.X()+M_CONTROL_BORDER_GAP,m_frame_indicator_parameter.Y()+M_CONTROL_HEIGHT);
      m_combo_param_tf.Draw(false);
      m_btn_add_indicator_form.Move(m_frame_indicator_parameter.X()+M_CONTROL_BORDER_GAP,m_frame_indicator_parameter.Y()+M_CONTROL_HEIGHT+PARAM_ROW_H);
      ::ChartRedraw(this.m_chart_id);
      return;
     }
   CStrategyIndicatorSetting *slot=(strategy!=NULL ? strategy.Indicator((int)(value%M_STRATEGY_SLOTS_MAX)) : NULL);
   if(slot==NULL || slot.Collection()!=COLLECTION_SIGNALS_ID)
      return;   // a bar information has no params of an indicator
   m_window_addIndicator.OpenWindow();
   this.Mode_AddIndicator(strategy.StrategyId(),slot.Slot());
   for(int i=0;i<M_STRATEGY_TF_TOTAL;i++)
      if(STRATEGY_TFS[i]==slot.Timeframe())
         m_combo_param_tf.SelectItem(i);
   m_combo_param_tf.GetListViewPointer().Draw(false);
   this.ShowCFrame_IndicatorParameter((ENUM_INDICATOR)slot.SourceId(),m_StrategyManager.Read_RAM(slot));
   ::ChartRedraw(this.m_chart_id);
  }
 //--- Save of the form: the params as the one text of the templates and the tf go to CStrategyManager (the tab follows its SLOT_CHANGED event);
 //--- the tf of the strategy (slot ""): its TF_CHANGED event
 void CGUIPannel::SaveSlot_Strategy(void)
  {
   MqlParam params[];
   if(m_StrategyManager==NULL)
      return;
   ENUM_TIMEFRAMES tf=PERIOD_CURRENT;
   for(int i=0;i<M_STRATEGY_TF_TOTAL;i++)
      if(m_combo_param_tf.GetListViewPointer().SelectedItemIndex()==i)
         tf=STRATEGY_TFS[i];
   if(m_edit_strategy_slot=="")
     {
      if(m_StrategyManager.Update_Strategy_Setting(m_edit_strategy_id,"tf_enum",tf))
         m_window_addIndicator.CloseWindow();
      return;
     }
   if(!this.ReadCFrame_IndicatorParameter(params))
      return;
   if(m_StrategyManager.Update_StrategyIndicator_Setting(m_edit_strategy_id,m_edit_strategy_slot,m_IndicatorTemplateManager.ParamsText(m_current_param_type,params),tf))
      m_window_addIndicator.CloseWindow();
  }
 //--- The toggle Available follows CStrategyManager: ON when every slot of the strategy has its source
 void CGUIPannel::SyncSections_Strategy(void)
  {
   if(m_StrategyManager==NULL)
      return;
   long ids[];
   int total=m_StrategyManager.Read_RAM(ids);
   for(int s=0;s<total && s<m_sections_strategy.SectionsTotal();s++)
     {
      CStrategySetting *strategy=m_StrategyManager.Read_RAM(ids[s]);
      m_sections_strategy.SetToggle(s,STRATEGY_TOGGLE_SHOW,strategy!=NULL && strategy.ShowOnChart());
      m_sections_strategy.SetToggle(s,STRATEGY_TOGGLE_AVAILABLE,m_StrategyManager.Read_RAM(ids[s],"available"));
     }
  }
 //+------------------------------------------------------------------+
 //| What the user (or a manager) did that the Strategy tab shows     |
 //+------------------------------------------------------------------+
 void CGUIPannel::OnEvent_Tab_Strategy(const int id,const long &lparam,const double &dparam,const string &sparam)
  {
   //--- The tab was opened, the scroll moved, a window changed its size, a header was clicked: the sections are arranged again
   m_sections_strategy.OnChartEvent(id,lparam,dparam,sparam);
   //--- A template came or went: Available follows; show_on_chart of a strategy changed: its toggle follows
   if(id==CHARTEVENT_CUSTOM+INDICATOR_TEMPLATE_MANAGER_EVENT_ADDED || id==CHARTEVENT_CUSTOM+INDICATOR_TEMPLATE_MANAGER_EVENT_DELETE ||
      id==CHARTEVENT_CUSTOM+STRATEGY_MANAGER_EVENT_SHOW_CHANGED)
     {
      this.SyncSections_Strategy();
      ::ChartRedraw(this.m_chart_id);
      return;
     }
   //--- A slot or the tf of a strategy changed (lparam = its strategy_id): the rows of its section are made again (their text), Available follows
   if((id==CHARTEVENT_CUSTOM+STRATEGY_MANAGER_EVENT_SLOT_CHANGED || id==CHARTEVENT_CUSTOM+STRATEGY_MANAGER_EVENT_TF_CHANGED) && m_StrategyManager!=NULL)
     {
      long ids[];
      int total=m_StrategyManager.Read_RAM(ids);
      for(int s=0;s<total && s<m_sections_strategy.SectionsTotal();s++)
        {
         if(ids[s]!=lparam)
            continue;
         CStrategySetting *strategy=m_StrategyManager.Read_RAM(ids[s]);
         m_sections_strategy.ClearBody(s);
         if(strategy!=NULL)
            this.AddRow_Strategy(s,strategy);
        }
      this.SyncSections_Strategy();
      m_sections_strategy.Arrange();
      ::ChartRedraw(this.m_chart_id);
      return;
     }
   if(id!=CHARTEVENT_CUSTOM+CLICK_EVENT_BUTTON)
      return;
   //--- Edit of a row: the form of the slot
   long value;
   int slot;
   string param;
   if(m_sections_strategy.BodyOf(lparam,value,slot,param))
     {
      if(slot==STRATEGY_SLOT_EDIT)
         this.OpenWindow_EditSlot_Strategy(value);
      return;
     }
   int which;
   int section=m_sections_strategy.SectionOfToggle(lparam,which);
   if(section==WRONG_VALUE)
      return;
   long ids[];
   if(m_StrategyManager==NULL || section>=m_StrategyManager.Read_RAM(ids))
      return;
   //--- Show: CStrategyManager writes show_on_chart, the strategy tells it (the markers and this toggle follow); dparam = the new state
   if(which==STRATEGY_TOGGLE_SHOW)
      m_StrategyManager.Update_Strategy_Setting(ids[section],"show_on_chart",dparam!=0);
   //--- Trade ON: CStrategyManager makes the templates of its indicators (Available follows their events)
   if(which==STRATEGY_TOGGLE_TRADE && dparam!=0)
      m_StrategyManager.Create_IndicatorTemplate(ids[section]);
   //--- Available is what the managers hold, not a click: it goes back to it
   if(which==STRATEGY_TOGGLE_AVAILABLE)
      this.SyncSections_Strategy();
  }
#endif // CGUIPANNEL_TABQUICKSETTING_STRATEGY_MQH
