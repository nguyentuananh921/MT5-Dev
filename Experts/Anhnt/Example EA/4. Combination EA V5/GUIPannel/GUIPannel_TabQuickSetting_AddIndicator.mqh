//+------------------------------------------------------------------+
//|                       GUIPannel_TabQuickSetting_AddIndicator.mqh |
//| The Add button of the Indicator tab opens a dialog window: the   |
//| tree of the indicator types (left) and the form of the           |
//| parameters of the type picked (right). Add gives CIndicator-     |
//| TemplateManager a new row; the table of the tab follows its      |
//| ADDED event                                                      |
//+------------------------------------------------------------------+
#ifndef CGUIPANNEL_TABQUICKSETTING_ADDINDICATOR_MQH
#define CGUIPANNEL_TABQUICKSETTING_ADDINDICATOR_MQH
#include "GUIPannel.mqh"
 //+------------------------------------------------------------------+
 //| The dialog window: born hidden, opened by the Add button of the tab |
 //+------------------------------------------------------------------+
 bool CGUIPannel::CreateWindow_AddIndicator(const string caption_text,const int x_gap,const int y_gap)
  {
   m_window_addIndicator.FontSize(DEF_FONT_SIZE);
   m_window_addIndicator.IsMovable(true);
   m_window_addIndicator.CloseButtonIsUsed(true);
   m_window_addIndicator.SetObjectType(OBJECT_DE_TYPE_GUICONTROL_WINDOW_DIALOG);
   if(!m_window_addIndicator.CreateWindow(this.m_chart_id,M_SUBWINDOW_MAIN,caption_text,x_gap,y_gap,M_WINDOW_ADDINDICATOR_WIDTH,M_WINDOW_ADDINDICATOR_HEIGHT))
      return false;
   m_window_addIndicator.IconFile(IMAGE_RESOURCE_BMP16_INDICATOR_ON_PNG);
   return true;
  }
 void CGUIPannel::OpenWindow_AddIndicator(void)
  {
   m_window_addIndicator.OpenWindow();
   this.Mode_AddIndicator(WRONG_VALUE,"");   // the Add button of the tab: the form adds a template
   m_frame_indicator_parameter.Hide();   // shown again when a type is picked in the tree
   ::ChartRedraw(this.m_chart_id);
  }
 //--- What the form does: adds a template (strategy_id WRONG_VALUE), or updates the slot of a strategy (slot "": its tf); the caption and the button say it
 void CGUIPannel::Mode_AddIndicator(const long strategy_id,const string slot)
  {
   m_edit_strategy_id=strategy_id;
   m_edit_strategy_slot=slot;
   string caption="Add Indicator";
   string button="Add";
   CStrategySetting *strategy=(strategy_id!=WRONG_VALUE && m_StrategyManager!=NULL ? m_StrategyManager.Read_RAM(strategy_id) : NULL);
   if(strategy!=NULL)
     {
      caption="Edit "+strategy.Name()+" > "+slot;
      if(slot=="")
         caption="Edit "+strategy.Name()+" > Timeframe";
      button="Update";
     }
   m_window_addIndicator.Caption(caption);
   m_btn_add_indicator_form.SetText(button);
   m_btn_add_indicator_form.Draw(true);
  }
 bool CGUIPannel::CreateTreeView_IndicatorTemplateSetting(const int x_gap,const int y_gap)
  {
   m_treeview_indicator.LightsHover(true);
   m_window_addIndicator.AddChild(&m_treeview_indicator);
   return m_treeview_indicator.CreateTreeView(this.m_chart_id,M_SUBWINDOW_MAIN,"TreeIndicatorTemplate",x_gap,y_gap,
                                              M_TREEVIEW_ADDINDICATOR_WIDTH,m_window_addIndicator.Height()-y_gap-3);
  }
 //--- Groups (ENUM_INDICATOR_GROUP) as roots, catalog types as leaves: a leaf stands for its ENUM_INDICATOR (the Value of the item), the text is only its look
 void CGUIPannel::PopulateTreeView_IndicatorTemplateSetting(void)
  {
   if(m_IndicatorTemplateManager==NULL)
     {
      ::Print(__FUNCTION__," > IndicatorTemplateManager is not set");
      return;
     }
   ENUM_INDICATOR_GROUP group_values[4]={INDICATOR_GROUP_TREND,INDICATOR_GROUP_OSCILLATOR,
                                         INDICATOR_GROUP_VOLUMES,INDICATOR_GROUP_ARROWS};
   ENUM_INDICATOR types[];
   ENUM_INDICATOR_GROUP groups[];
   string names[];
   int total=m_IndicatorTemplateManager.Read_RAM(types,groups,names);
   for(int g=0;g<4;g++)
     {
      long group_id=m_treeview_indicator.AddTreeItem(WRONG_VALUE,m_IndicatorTemplateManager.Read_RAM((ENUM_INDICATOR_GROUP)group_values[g]));
      if(group_id==WRONG_VALUE)
         continue;
      for(int i=0;i<total;i++)
        {
         if(groups[i]!=group_values[g])
            continue;
         m_treeview_indicator.AddTreeItem(group_id,names[i],IMAGE_RESOURCE_BMP16_ARROWRIGHT_BMP,false,(long)types[i]);
        }
     }
  }
 //--- Blue arrow on every type (and its group) that has at least one template row
 void CGUIPannel::SyncTreeView_IndicatorTemplateSetting(void)
  {
   if(m_IndicatorTemplateManager==NULL)
      return;
   CTreeItem *top=m_treeview_indicator.FindItem(WRONG_VALUE,m_IndicatorTemplateManager.Read_RAM(INDICATOR_GROUP_TREND));
   CTreeItem *root=(top!=NULL) ? top.ParentItem() : NULL;
   int groups=(root!=NULL) ? root.ChildrenTotal() : 0;
   for(int g=0;g<groups;g++)
     {
      CTreeItem *group_item=root.ChildItem(g);
      if(group_item==NULL)
         continue;
      bool group_active=false;
      for(int k=0;k<group_item.ChildrenTotal();k++)
        {
         CTreeItem *type_item=group_item.ChildItem(k);
         if(type_item==NULL)
            continue;
         bool active=m_IndicatorTemplateManager.Read_RAM((ENUM_INDICATOR)type_item.Value());
         type_item.IconFile(active ? IMAGE_RESOURCE_BMP16_ARROWRIGHT_BLUE_BMP : IMAGE_RESOURCE_BMP16_ARROWRIGHT_BMP);
         group_active|=active;
        }
      group_item.IsActive(group_active);
     }
   m_treeview_indicator.UpdateTreeList(true);
  }
 //--- Each slot owns a CTextEdit and a CComboBox at the same spot; the caption is the control's own label
 bool CGUIPannel::CreateCFrame_IndicatorParameter(const int x_gap,const int y_gap)
  {
   const int slot_w=INDICATOR_PARAM_LABEL_W+INDICATOR_PARAM_FIELD_W;
   m_frame_indicator_parameter.SetText("Indicator Parameter");
   m_window_addIndicator.AddChild(&m_frame_indicator_parameter);
   if(!m_frame_indicator_parameter.CreateFrame(this.m_chart_id,M_SUBWINDOW_MAIN,"FrameIndicatorParam",x_gap,y_gap,INDICATOR_FRAME_W,INDICATOR_FRAME_H))
      return false;
   for(int i=0;i<INDICATOR_PARAM_SLOTS_MAX;i++)
     {
      m_frame_indicator_parameter.AddChild(&m_param_edits[i]);
      if(!m_param_edits[i].CreateTextEdit(this.m_chart_id,M_SUBWINDOW_MAIN,"ParamEdit"+(string)i,M_CONTROL_BORDER_GAP,M_CONTROL_HEIGHT,
                                          slot_w,M_CONTROL_HEIGHT,INDICATOR_PARAM_FIELD_W))
         return false;
      m_param_combo[i].ItemsTotal(7);   // room for the largest choice list (PRICE_CHOICES); the sources of an Applied Price are added when shown (Rebuilding)
      m_frame_indicator_parameter.AddChild(&m_param_combo[i]);
      if(!m_param_combo[i].CreateComboBox(this.m_chart_id,M_SUBWINDOW_MAIN,"ParamCombo"+(string)i,M_CONTROL_BORDER_GAP,M_CONTROL_HEIGHT,
                                          slot_w,M_CONTROL_HEIGHT,INDICATOR_PARAM_FIELD_W,200))   // Change in V5 (was 140): the 7 prices and the first sources without a scroll
         return false;
     }
   //--- The tf of a strategy slot: shown only while the form edits one
   m_combo_param_tf.ItemsTotal(M_STRATEGY_TF_TOTAL);
   m_frame_indicator_parameter.AddChild(&m_combo_param_tf);
   if(!m_combo_param_tf.CreateComboBox(this.m_chart_id,M_SUBWINDOW_MAIN,"ParamComboTF",M_CONTROL_BORDER_GAP,M_CONTROL_HEIGHT,slot_w,M_CONTROL_HEIGHT,INDICATOR_PARAM_FIELD_W,140))
      return false;
   for(int i=0;i<M_STRATEGY_TF_TOTAL;i++)
     {
      string tf_text="Default";   // no tf chosen: no Period set, the Period it is judged / drawn / traded on
      if(STRATEGY_TFS[i]!=PERIOD_CURRENT)
         tf_text=::StringSubstr(::EnumToString(STRATEGY_TFS[i]),7);   // PERIOD_M15 -> M15
      m_combo_param_tf.SetValue(i,tf_text);
     }
   CLabel *tf_caption=::GetPointer(m_combo_param_tf);
   tf_caption.SetText("Timeframe");
   m_btn_add_indicator_form.SetText("Add");
   m_btn_add_indicator_form.IconFile(IMAGE_RESOURCE_BMP16_ADD_GREEN_PNG);
   m_frame_indicator_parameter.AddChild(&m_btn_add_indicator_form);
   //--- moved under the last parameter when a type is picked
   return m_btn_add_indicator_form.Create(this.m_chart_id,M_SUBWINDOW_MAIN,"BtnAddIndicatorForm",M_CONTROL_BORDER_GAP,M_CONTROL_HEIGHT,M_BUTTON_ADD_WIDTH,M_CONTROL_HEIGHT);
  }
 //--- Indicator tree leaf clicked: the parameters of this type, one under the other from the top, the Add button under the last one.
 //--- params_text (the Edit of a strategy slot): the values of the form are these, not the defaults; the tf of the slot under the last parameter
 void CGUIPannel::ShowCFrame_IndicatorParameter(const ENUM_INDICATOR type,const string params_text="")
  {
   string values[];
   if(m_IndicatorTemplateManager==NULL)
     {
      ::Print(__FUNCTION__," > IndicatorTemplateManager is not set");
      return;
     }
   int given=m_IndicatorTemplateManager.SplitParams(params_text,values);   // Change in V5: a source keeps its commas, "9,0,SMA,RSI(14,CLOSE)"
   m_current_param_type=type;
   SIndicatorParam schema[];
   int total=m_IndicatorTemplateManager.Read_RAM(type,schema);
   m_frame_indicator_parameter.Show();   // cascades to every slot and the Add button: unused slots are hidden again below
   for(int i=0;i<INDICATOR_PARAM_SLOTS_MAX;i++)
     {
      m_param_edits[i].Hide();
      m_param_combo[i].Hide();
      if(i>=total)
         continue;
      int x=m_frame_indicator_parameter.X()+M_CONTROL_BORDER_GAP;
      int y=m_frame_indicator_parameter.Y()+M_CONTROL_HEIGHT+i*PARAM_ROW_H;
      if(schema[i].choices!="")
        {
         string parts[];
         int n=::StringSplit(schema[i].choices,'|',parts);
         //--- New in V5: the Applied Price of an MA also lists the templates drawn in a subwindow (as MT5 drops an MA on an indicator): TYPE(params)
         if(schema[i].choices==PRICE_CHOICES && m_IndicatorTemplateManager.TakesSource(type))
           {
            ENUM_INDICATOR types[];
            string texts[];
            bool buy[],sell[];
            int templates=m_IndicatorTemplateManager.Read_RAM(types,texts,buy,sell);
            for(int t=0;t<templates;t++)
              {
               ENUM_INDICATOR source_type;
               string source_params;
               int applied;
               if(m_IndicatorTemplateManager.IsOverlay(types[t]) || m_IndicatorTemplateManager.SourceOf(types[t],texts[t],source_type,source_params,applied))
                  continue;   // a source is in a subwindow and has no source itself
               ::ArrayResize(parts,n+1);
               parts[n++]=m_IndicatorTemplateManager.SourceText(types[t],texts[t]);
              }
           }
         m_param_combo[i].GetListViewPointer().Rebuilding(n);
         for(int p=0;p<n;p++)
            m_param_combo[i].SetValue(p,parts[p]);
         int def_idx=(int)::StringToInteger(schema[i].default_value);
         for(int p=0;p<n && i<given;p++)
           {
            string choice=parts[p];
            string value=values[i];
            ::StringToUpper(choice);
            ::StringToUpper(value);
            if(choice==value)
               def_idx=p;   // the value of the slot (SMMA, MEDIAN), the case aside
           }
         if(def_idx>=0 && def_idx<n)
            m_param_combo[i].SelectItem(def_idx);
         m_param_combo[i].GetListViewPointer().Draw(false);   // SetValue/SelectItem only store, repaint the list
         CLabel *caption=::GetPointer(m_param_combo[i]);      // the name of the parameter is the label at the left, the button keeps the chosen value
         caption.SetText(schema[i].name);
         m_param_combo[i].Move(x,y);
         m_param_combo[i].Show();
         m_param_combo[i].Draw(false);
        }
      else
        {
         m_param_edits[i].SetText(schema[i].name);
         if(i<given)
            m_param_edits[i].SetValue(values[i]);
         else
            m_param_edits[i].SetValue(schema[i].default_value);
         m_param_edits[i].Move(x,y);
         m_param_edits[i].Show();
         m_param_edits[i].Draw(false);
        }
     }
   //--- The tf of a strategy slot under the last parameter (Edit), hidden for a template (Add)
   int rows=total;
   m_combo_param_tf.Hide();
   if(m_edit_strategy_id!=WRONG_VALUE)
     {
      m_combo_param_tf.Move(m_frame_indicator_parameter.X()+M_CONTROL_BORDER_GAP,m_frame_indicator_parameter.Y()+M_CONTROL_HEIGHT+total*PARAM_ROW_H);
      m_combo_param_tf.Show();
      m_combo_param_tf.Draw(false);
      rows++;
     }
   m_btn_add_indicator_form.Move(m_frame_indicator_parameter.X()+M_CONTROL_BORDER_GAP,m_frame_indicator_parameter.Y()+M_CONTROL_HEIGHT+rows*PARAM_ROW_H);
  }
 //--- The values of the form as the params of the type it shows (false: no manager)
 bool CGUIPannel::ReadCFrame_IndicatorParameter(MqlParam &params[])
  {
   if(m_IndicatorTemplateManager==NULL)
     {
      ::Print(__FUNCTION__," > IndicatorTemplateManager is not set");
      return false;
     }
   SIndicatorParam schema[];
   int total=m_IndicatorTemplateManager.Read_RAM(m_current_param_type,schema);
   ::ArrayResize(params,total);
   for(int i=0;i<total;i++)
     {
      params[i].type=schema[i].data_type;
      if(schema[i].choices!="")
        {
         string sel_text=m_param_combo[i].GetValue();
         params[i].string_value="";
         if(schema[i].choices==PRICE_CHOICES && ::StringFind(sel_text,"(")>0)
           {
            params[i].string_value=sel_text;   // New in V5: a source, TYPE(params): its handle is put by who makes it
            params[i].integer_value=0;
           }
         else if(schema[i].choices==PRICE_CHOICES)
            params[i].integer_value=m_IndicatorTemplateManager.ParamValueByDescription(sel_text,schema[i].choices);
         else if(schema[i].choices==CALCULATION_METHOD_CHOICES)
            params[i].integer_value=m_IndicatorTemplateManager.ParamValueByDescription(sel_text,schema[i].choices);
         else if(schema[i].choices==VOLUME_CHOICES)
            params[i].integer_value=m_IndicatorTemplateManager.ParamValueByDescription(sel_text,schema[i].choices);
         else if(schema[i].choices==STOCH_PRICE_CHOICES)
            params[i].integer_value=m_IndicatorTemplateManager.ParamValueByDescription(sel_text,schema[i].choices);
        }
      else if(schema[i].data_type==TYPE_DOUBLE)
         params[i].double_value=::StringToDouble(m_param_edits[i].GetValue());
      else
         params[i].integer_value=(long)::StringToInteger(m_param_edits[i].GetValue());
     }
   return true;
  }
 //--- Slot values -> MqlParam[] -> CIndicatorTemplateManager (data only, the table follows its ADDED event)
 void CGUIPannel::OnClickAddIndicatorBtnOnForm(void)
  {
   MqlParam params[];
   if(!this.ReadCFrame_IndicatorParameter(params))
      return;
   if(!m_IndicatorTemplateManager.Update_IndicatorTemplate_Setting(m_current_param_type, params))
   ::Print(__FUNCTION__," > rejected: this template already exists");
  }
 //+------------------------------------------------------------------+
 //| What the user did in the Add Indicator window (and the Add button |
 //| of the tab that opens it)                                         |
 //+------------------------------------------------------------------+
 void CGUIPannel::OnEvent_Window_AddIndicator(const int id,const long &lparam,const double &dparam,const string &sparam)
  {
   //--- The Add button of the tab: the window opens
   if(id==CHARTEVENT_CUSTOM+CLICK_EVENT_BUTTON && lparam==m_btn_add_indicator.ObjectID())
     {
      this.OpenWindow_AddIndicator();
      return;
     }
   //--- Esc closes it
   if(id==CHARTEVENT_KEYDOWN && lparam==27 && m_window_addIndicator.IsVisible())
     {
      m_window_addIndicator.CloseWindow();
      return;
     }
   //--- A dialog window locks the main window while it is open
   if(id==CHARTEVENT_CUSTOM+WINDOW_EVENT_OPEN_DIALOG_BOX && (int)dparam==OBJECT_DE_TYPE_GUICONTROL_WINDOW_DIALOG)
     {
      const ulong debug_t0=::GetMicrosecondCount();   // MY DEBUG: IsLocked of the main window (4.0-4.8 s before CGElement::IsLocked drew only the shown controls)
      m_window_main.IsLocked(true);
      ::ChartRedraw(this.m_chart_id);
      ::Print("MY DEBUG CGUIPannel::OnEvent_Window_AddIndicator: m_window_main.IsLocked(true) for ",sparam," took ",(::GetMicrosecondCount()-debug_t0)/1000," ms");
      return;
     }
   if(id==CHARTEVENT_CUSTOM+WINDOW_EVENT_CLOSE_DIALOG_BOX && (int)dparam==OBJECT_DE_TYPE_GUICONTROL_WINDOW_DIALOG)
     {
      const ulong debug_t0=::GetMicrosecondCount();   // MY DEBUG: as above
      m_window_main.IsLocked(false);
      ::ChartRedraw(this.m_chart_id);
      ::Print("MY DEBUG CGUIPannel::OnEvent_Window_AddIndicator: m_window_main.IsLocked(false) for ",sparam," took ",(::GetMicrosecondCount()-debug_t0)/1000," ms");
      return;
     }
   //--- Window expanded again: Show() cascaded to the hidden form slots
   if(id==CHARTEVENT_CUSTOM+WINDOW_EVENT_EXPAND && lparam==m_window_addIndicator.ObjectID())
     {
      m_frame_indicator_parameter.Hide();
      if(m_edit_strategy_id!=WRONG_VALUE && m_StrategyManager!=NULL)
        {
         CStrategySetting *strategy=m_StrategyManager.Read_RAM(m_edit_strategy_id);
         CStrategyIndicatorSetting *slot=(strategy!=NULL ? strategy.Indicator(m_edit_strategy_slot) : NULL);
         if(slot!=NULL)
            ShowCFrame_IndicatorParameter(m_current_param_type,m_StrategyManager.Read_RAM(slot));
        }
      else if(m_current_param_type!=IND_CUSTOM)
         ShowCFrame_IndicatorParameter(m_current_param_type);
      ::ChartRedraw(this.m_chart_id);
      return;
     }
   //--- Indicator tree: a group label folds it, a type leaf opens the form for that type
   if(id==CHARTEVENT_CUSTOM+CHANGE_EVENT_TREE_PATH && lparam==m_treeview_indicator.ObjectID())
     {
      long item_id=(long)dparam;
      CTreeItem *clicked=m_treeview_indicator.ItemPointer(item_id);
      if(clicked==NULL)
         return;
      if(clicked.ChildrenTotal()>0)
        {
         m_treeview_indicator.ItemState(item_id,!clicked.ItemState(),true);
         return;
        }
      if(m_edit_strategy_id!=WRONG_VALUE)
         this.Mode_AddIndicator(WRONG_VALUE,"");   // another type picked: the form adds a template again
      ShowCFrame_IndicatorParameter((ENUM_INDICATOR)clicked.Value());
      ::ChartRedraw(this.m_chart_id);
      return;
     }
   //--- The button of the form: Add a template, or Save the slot of a strategy
   if(id==CHARTEVENT_CUSTOM+CLICK_EVENT_BUTTON && lparam==m_btn_add_indicator_form.ObjectID())
     {
      if(m_edit_strategy_id!=WRONG_VALUE)
         this.SaveSlot_Strategy();
      else
         OnClickAddIndicatorBtnOnForm();
      return;
     }
  }
#endif // CGUIPANNEL_TABQUICKSETTING_ADDINDICATOR_MQH
