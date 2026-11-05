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
   m_frame_indicator_parameter.Hide();   // shown again when a type is picked in the tree
   ::ChartRedraw(this.m_chart_id);
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
   int total=m_IndicatorTemplateManager.StandardIndicatorCatalog(types,groups,names);
   for(int g=0;g<4;g++)
     {
      long group_id=m_treeview_indicator.AddTreeItem(WRONG_VALUE,m_IndicatorTemplateManager.StandardIndicatorGroupName(group_values[g]));
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
   CTreeItem *top=m_treeview_indicator.FindItem(WRONG_VALUE,m_IndicatorTemplateManager.StandardIndicatorGroupName(INDICATOR_GROUP_TREND));
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
         bool active=m_IndicatorTemplateManager.Exists((ENUM_INDICATOR)type_item.Value());
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
      m_param_combo[i].ItemsTotal(7);   // room for the largest choice list (PRICE_CHOICES)
      m_frame_indicator_parameter.AddChild(&m_param_combo[i]);
      if(!m_param_combo[i].CreateComboBox(this.m_chart_id,M_SUBWINDOW_MAIN,"ParamCombo"+(string)i,M_CONTROL_BORDER_GAP,M_CONTROL_HEIGHT,
                                          slot_w,M_CONTROL_HEIGHT,INDICATOR_PARAM_FIELD_W,140))
         return false;
     }
   m_btn_add_indicator_form.SetText("Add");
   m_btn_add_indicator_form.IconFile(IMAGE_RESOURCE_BMP16_ADD_GREEN_PNG);
   m_frame_indicator_parameter.AddChild(&m_btn_add_indicator_form);
   //--- moved under the last parameter when a type is picked
   return m_btn_add_indicator_form.Create(this.m_chart_id,M_SUBWINDOW_MAIN,"BtnAddIndicatorForm",M_CONTROL_BORDER_GAP,M_CONTROL_HEIGHT,M_BUTTON_ADD_WIDTH,M_CONTROL_HEIGHT);
  }
 //--- Indicator tree leaf clicked: the parameters of this type, one under the other from the top, the Add button under the last one
 void CGUIPannel::ShowCFrame_IndicatorParameter(const ENUM_INDICATOR type)
  {
   if(m_IndicatorTemplateManager==NULL)
     {
      ::Print(__FUNCTION__," > IndicatorTemplateManager is not set");
      return;
     }
   m_current_param_type=type;
   SIndicatorParam schema[];
   int total=m_IndicatorTemplateManager.GetStandardIndicatorParamSchema(type,schema);
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
         m_param_combo[i].GetListViewPointer().Rebuilding(n);
         for(int p=0;p<n;p++)
            m_param_combo[i].SetValue(p,parts[p]);
         int def_idx=(int)::StringToInteger(schema[i].default_value);
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
         m_param_edits[i].SetValue(schema[i].default_value);
         m_param_edits[i].Move(x,y);
         m_param_edits[i].Show();
         m_param_edits[i].Draw(false);
        }
     }
   m_btn_add_indicator_form.Move(m_frame_indicator_parameter.X()+M_CONTROL_BORDER_GAP,m_frame_indicator_parameter.Y()+M_CONTROL_HEIGHT+total*PARAM_ROW_H);
  }
 //--- Slot values -> MqlParam[] -> CIndicatorTemplateManager (data only, the table follows its ADDED event)
 void CGUIPannel::OnClickAddIndicatorBtnOnForm(void)
  {
   if(m_IndicatorTemplateManager==NULL)
     {
      ::Print(__FUNCTION__," > IndicatorTemplateManager is not set");
      return;
     }
   SIndicatorParam schema[];
   int total=m_IndicatorTemplateManager.GetStandardIndicatorParamSchema(m_current_param_type,schema);
   MqlParam params[];
   ::ArrayResize(params,total);
   for(int i=0;i<total;i++)
     {
      params[i].type=schema[i].data_type;
      if(schema[i].choices!="")
        {
         string sel_text=m_param_combo[i].GetValue();
         if(schema[i].choices==PRICE_CHOICES)
            params[i].integer_value=m_IndicatorTemplateManager.StandardIndicatorParamValue(sel_text,schema[i].choices);
         else if(schema[i].choices==CALCULATION_METHOD_CHOICES)
            params[i].integer_value=m_IndicatorTemplateManager.StandardIndicatorParamValue(sel_text,schema[i].choices);
         else if(schema[i].choices==VOLUME_CHOICES)
            params[i].integer_value=m_IndicatorTemplateManager.StandardIndicatorParamValue(sel_text,schema[i].choices);
         else if(schema[i].choices==STOCH_PRICE_CHOICES)
            params[i].integer_value=m_IndicatorTemplateManager.StandardIndicatorParamValue(sel_text,schema[i].choices);
        }
      else if(schema[i].data_type==TYPE_DOUBLE)
         params[i].double_value=::StringToDouble(m_param_edits[i].GetValue());
      else
         params[i].integer_value=(long)::StringToInteger(m_param_edits[i].GetValue());
     }
   // if(!m_IndicatorTemplateManager.AddToDB(m_current_param_type,params))
   //    ::Print(__FUNCTION__," > rejected: this template already exists");
   if(!m_IndicatorTemplateManager.UpdateTemplate(m_current_param_type, params))
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
      m_window_main.IsLocked(true);
      ::ChartRedraw(this.m_chart_id);
      return;
     }
   if(id==CHARTEVENT_CUSTOM+WINDOW_EVENT_CLOSE_DIALOG_BOX && (int)dparam==OBJECT_DE_TYPE_GUICONTROL_WINDOW_DIALOG)
     {
      m_window_main.IsLocked(false);
      ::ChartRedraw(this.m_chart_id);
      return;
     }
   //--- Window expanded again: Show() cascaded to the hidden form slots
   if(id==CHARTEVENT_CUSTOM+WINDOW_EVENT_EXPAND && lparam==m_window_addIndicator.ObjectID())
     {
      m_frame_indicator_parameter.Hide();
      if(m_current_param_type!=IND_CUSTOM)
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
      ShowCFrame_IndicatorParameter((ENUM_INDICATOR)clicked.Value());
      ::ChartRedraw(this.m_chart_id);
      return;
     }
   //--- The Add button of the form
   if(id==CHARTEVENT_CUSTOM+CLICK_EVENT_BUTTON && lparam==m_btn_add_indicator_form.ObjectID())
     {
      OnClickAddIndicatorBtnOnForm();
      return;
     }
  }
#endif // CGUIPANNEL_TABQUICKSETTING_ADDINDICATOR_MQH
