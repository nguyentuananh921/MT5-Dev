//+------------------------------------------------------------------+
//|                        GUIPannel_SettingWindows_TS_Indicator.mqh |
//| Indicator tab: type tree (left), Add form (top right) and the    |
//| CIndicatorTemplateManager table (below the form)                 |
//+------------------------------------------------------------------+
#ifndef CGUIPANNEL_SETTINGWINDOWS_TS_INDICATOR_MQH_IMPLEMENTATION
#define CGUIPANNEL_SETTINGWINDOWS_TS_INDICATOR_MQH_IMPLEMENTATION
 #include "GUIPannel.mqh"
 #define COLUMNS_INDICATOR_TEMPLATE_TOTAL 7
 bool CGUIPannel::CreateTreeView_IndicatorTemplateSetting(const int x_gap,const int y_gap)
  {
   m_treeview_indicator.LightsHover(true);
   m_tabs_setting_timeseries.AddToElementsArray(TAB_TAB_SETTING_TIMESERIES_INDICATOR,m_treeview_indicator);
   return m_treeview_indicator.CreateTreeView(m_chart_id,m_subwin,"TreeIndicatorTemplate",x_gap,y_gap,
                                              M_TREEVIEW_WIDTH,m_tabs_setting_timeseries.Height()-y_gap-3);
  }
 //--- Groups (ENUM_INDICATOR_GROUP) as roots, catalog types as leaves
 void CGUIPannel::PopulateTreeView_IndicatorTemplateSetting(void)
  {
   ENUM_INDICATOR_GROUP group_values[4]={INDICATOR_GROUP_TREND,INDICATOR_GROUP_OSCILLATOR,
                                         INDICATOR_GROUP_VOLUMES,INDICATOR_GROUP_ARROWS};
   SIndicatorCatalogItem catalog[];
   GetIndicatorCatalog(catalog);
   ::ArrayResize(m_type_node_id,0);
   ::ArrayResize(m_type_node_value,0);
   for(int g=0;g<4;g++)
     {
      long group_id=m_treeview_indicator.AddTreeItem(WRONG_VALUE,GetIndicatorGroupName(group_values[g]));
      if(group_id==WRONG_VALUE)
         continue;
      for(int i=0;i<::ArraySize(catalog);i++)
        {
         if(catalog[i].group!=group_values[g])
            continue;
         long type_id=m_treeview_indicator.AddTreeItem(group_id,catalog[i].name,IMAGE_RESOURCE_BMP16_ARROWRIGHT_BMP);
         if(type_id==WRONG_VALUE)
            continue;
         int sz=::ArraySize(m_type_node_id);
         ::ArrayResize(m_type_node_id,sz+1);
         ::ArrayResize(m_type_node_value,sz+1);
         m_type_node_id[sz]=type_id;
         m_type_node_value[sz]=catalog[i].ind_type;
        }
     }
  }
 //--- Blue arrow on every type (and its group) that has at least one template row
 void CGUIPannel::SyncTreeView_IndicatorTemplateSetting(void)
  {
   if(m_IndicatorTemplateManager==NULL)
      return;
   for(int i=0;i<::ArraySize(m_type_node_id);i++)
     {
      CTreeItem *type_item=m_treeview_indicator.ItemPointer(m_type_node_id[i]);
      CTreeItem *group_item=(type_item!=NULL) ? type_item.ParentItem() : NULL;
      if(group_item!=NULL)
         group_item.IsActive(false);
     }
   for(int i=0;i<::ArraySize(m_type_node_id);i++)
     {
      CTreeItem *type_item=m_treeview_indicator.ItemPointer(m_type_node_id[i]);
      if(type_item==NULL)
         continue;
      bool active=m_IndicatorTemplateManager.Exists(m_type_node_value[i]);
      type_item.IconFile(active ? IMAGE_RESOURCE_BMP16_ARROWRIGHT_BLUE_BMP : IMAGE_RESOURCE_BMP16_ARROWRIGHT_BMP);
      CTreeItem *group_item=type_item.ParentItem();
      if(active && group_item!=NULL)
         group_item.IsActive(true);
     }
   m_treeview_indicator.UpdateTreeList(true);
  }
 //--- 7 columns: Indicator (delete icon), Group, Buy, Sell, Show on chart, Sound, Message
 bool CGUIPannel::CreateTable_IndicatorTemplateSetting(const int x,const int y)
  {
   m_table_indicator_template.TableSize(COLUMNS_INDICATOR_TEMPLATE_TOTAL,0);
   m_table_indicator_template.View().ShowHeaders(true);
   m_table_indicator_template.View().SelectableRow(true);
   m_table_indicator_template.View().LightsHover(true);
   m_table_indicator_template.View().IsSortMode(false);   // row == CIndicatorTemplateManager index
   m_table_indicator_template.AutoXResizeMode(true);
   m_table_indicator_template.AutoXResizeRightOffset(3);
   m_table_indicator_template.AutoYResizeMode(true);
   m_table_indicator_template.AutoYResizeBottomOffset(3);
   m_tabs_setting_timeseries.AddToElementsArray(TAB_TAB_SETTING_TIMESERIES_INDICATOR,m_table_indicator_template);
   if(!m_table_indicator_template.CreateTable(m_chart_id,m_subwin,"TableIndicatorTemplate",x,y))
      return false;
   int widths[COLUMNS_INDICATOR_TEMPLATE_TOTAL]            ={M_INDICATOR_PARATEXT_WIDTH,70,M_ICON16_WIDTH,M_ICON16_WIDTH,M_ICON16_WIDTH,M_ICON16_WIDTH,M_ICON16_WIDTH};
   int image_x[COLUMNS_INDICATOR_TEMPLATE_TOTAL]           ={3,3,2,2,2,2,2};
   ENUM_ALIGN_MODE align[COLUMNS_INDICATOR_TEMPLATE_TOTAL] ={ALIGN_LEFT,ALIGN_LEFT,ALIGN_LEFT,ALIGN_LEFT,ALIGN_LEFT,ALIGN_LEFT,ALIGN_LEFT};
   CTableHeaderView *header=m_table_indicator_template.View().GetHeaderViewPointer();
   header.ColumnsWidth(widths);
   header.TextAlign(align);
   header.ImageXOffset(image_x);
   m_table_indicator_template.SetHeaderText(0,"Indicator");
   m_table_indicator_template.SetHeaderText(1,"Group");
   uint img_buy[]    ={IMAGE_RESOURCE_BMP16_SIGNAL_BUY_PNG};
   uint img_sell[]   ={IMAGE_RESOURCE_BMP16_SIGNAL_SELL_PNG};
   uint img_visible[]={IMAGE_RESOURCE_BMP16_VISIBLE_PNG};
   uint img_sound[]  ={IMAGE_RESOURCE_BMP16_BELL_PNG};
   uint img_message[]={IMAGE_RESOURCE_BMP16_MESSAGE_PNG};
   m_table_indicator_template.SetHeaderText(2,"");  m_table_indicator_template.SetHeaderImage(2,img_buy);
   m_table_indicator_template.SetHeaderText(3,"");  m_table_indicator_template.SetHeaderImage(3,img_sell);
   m_table_indicator_template.SetHeaderText(4,"");  m_table_indicator_template.SetHeaderImage(4,img_visible);
   m_table_indicator_template.SetHeaderText(5,"");  m_table_indicator_template.SetHeaderImage(5,img_sound);
   m_table_indicator_template.SetHeaderText(6,"");  m_table_indicator_template.SetHeaderImage(6,img_message);
   m_table_indicator_template.View().Rebuild(false);
   return true;
  }
 //--- Rows mirror CIndicatorTemplateManager 1:1, in its own order
 void CGUIPannel::InitializeTable_IndicatorTemplateSetting(void)
  {
   if(m_IndicatorTemplateManager==NULL)
      return;
   int count=m_IndicatorTemplateManager.Total();
   m_table_indicator_template.DeleteAllRows();
   for(int i=0;i<count;i++)
      m_table_indicator_template.AddRow();
   for(int row=0;row<count;row++)
      UpdateRow_IndicatorTemplateSetting(row);
   m_table_indicator_template.View().Rebuild(true);
  }
 void CGUIPannel::UpdateRow_IndicatorTemplateSetting(const int row)
  {
   CIndicatorSetting *entry=(m_IndicatorTemplateManager!=NULL) ? m_IndicatorTemplateManager.At(row) : NULL;
   if(entry==NULL)
      return;
   uint delete_icon[]={IMAGE_RESOURCE_BMP16_CLOSE_RED_PNG};
   m_table_indicator_template.CellView(0,row).CellType(CELL_BUTTON);
   m_table_indicator_template.CellView(0,row).SetImages(delete_icon);
   m_table_indicator_template.SetValue(0,row,entry.DisplayLabel());
   m_table_indicator_template.SetValue(1,row,GetIndicatorGroupName(GetIndicatorGroupForType(entry.TypeEnum())));
   bool flags[5];
   flags[0]=entry.BuySignal();
   flags[1]=entry.SellSignal();
   flags[2]=entry.ShowOnChart();
   flags[3]=entry.SoundAlert();
   flags[4]=entry.MessageAlert();
   for(int c=0;c<5;c++)
     {
      m_table_indicator_template.CellView(c+2,row).CellType(CELL_CHECKBOX);
      m_table_indicator_template.SetValue(c+2,row,(long)(flags[c] ? CANV_ELEMENT_CHEK_STATE_CHECKED : CANV_ELEMENT_CHEK_STATE_UNCHECKED));
     }
  }
 void CGUIPannel::OnClickRemoveIndicator(const int row)
  {
   CIndicatorSetting *entry=(m_IndicatorTemplateManager!=NULL) ? m_IndicatorTemplateManager.At(row) : NULL;
   if(entry==NULL)
      return;
   MqlParam params[];
   entry.GetRawParams(params);
   m_IndicatorTemplateManager.DeleteIndicatorFromIndicatorTemplateSetting(entry.TypeEnum(),params);
  }
 //--- 'on' is the new checkbox state sent with the event (dparam)
 void CGUIPannel::OnCheckTableIndicatorTemplateSetting(const int row,const int col,const bool on)
  {
   CIndicatorSetting *entry=(m_IndicatorTemplateManager!=NULL) ? m_IndicatorTemplateManager.At(row) : NULL;
   if(entry==NULL)
      return;
   if(col==2)
      entry.BuySignal(on,true,row);
   else if(col==3)
      entry.SellSignal(on,true,row);
   else if(col==4)
      m_IndicatorTemplateManager.UpdateRow_IndicatorTemplateSetting_ShowColumn(row,on);
   else if(col==5)
      entry.SoundAlert(on);
   else if(col==6)
      entry.MessageAlert(on);
  }
 //+------------------------------------------------------------------+
 //| What the user (or the manager) did that this tab shows           |
 //+------------------------------------------------------------------+
 void CGUIPannel::OnEvent_Tab_Indicator(const int id,const long &lparam,const double &dparam,const string &sparam)
  {
   //--- Tab switch / window expand: Show() cascaded to the hidden form slots again
   if((id==CHARTEVENT_CUSTOM+ON_CLICK_TAB && lparam==m_tabs_setting_timeseries.ObjectID()) ||
      (id==CHARTEVENT_CUSTOM+ON_WINDOW_EXPAND && lparam==m_window_setting_timeseries.ObjectID()))
     {
      m_frame_indicator_parameter.Hide();
      if(m_current_param_type!=IND_CUSTOM && m_tabs_setting_timeseries.SelectedTab()==TAB_TAB_SETTING_TIMESERIES_INDICATOR)
         ShowCFrame_IndicatorParameter(m_current_param_type);
      ::ChartRedraw(m_chart_id);
      return;
     }
   //--- Indicator tree: a group label folds it, a type leaf opens the Add form for that type
   if(id==CHARTEVENT_CUSTOM+ON_CHANGE_TREE_PATH && lparam==m_treeview_indicator.ObjectID())
     {
      long item_id=(long)dparam;
      CTreeItem *clicked=m_treeview_indicator.ItemPointer(item_id);
      if(clicked!=NULL && clicked.ChildrenTotal()>0)
        {
         m_treeview_indicator.ItemState(item_id,!clicked.ItemState(),true);
         return;
        }
      for(int i=0;i<::ArraySize(m_type_node_id);i++)
        {
         if(m_type_node_id[i]!=item_id)
            continue;
         ShowCFrame_IndicatorParameter(m_type_node_value[i]);
         ::ChartRedraw(m_chart_id);
         break;
        }
      return;
     }
   if(id==CHARTEVENT_CUSTOM+ON_CLICK_BUTTON && lparam==m_btn_add_indicator.ObjectID())
     {
      OnClickAddIndicatorBtnOnForm();
      return;
     }
   //--- CIndicatorTemplateManager changed for real: the table and the tree follow it
   if(id==CHARTEVENT_CUSTOM+INDICATOR_TEMPLATE_MANAGER_EVENT_ADDED || id==CHARTEVENT_CUSTOM+INDICATOR_TEMPLATE_MANAGER_EVENT_DELETE)
     {
      if(!m_gui_created)
         return;
      InitializeTable_IndicatorTemplateSetting();
      SyncTreeView_IndicatorTemplateSetting();
      ::ChartRedraw(m_chart_id);
      return;
     }
   //--- A row was attached to / detached from the chart (maybe from the chart side): its Show cell follows
   if(id==CHARTEVENT_CUSTOM+INDICATOR_TEMPLATE_MANAGER_EVENT_SHOW_CHANGED)
     {
      if(!m_gui_created)
         return;
      UpdateRow_IndicatorTemplateSetting((int)lparam);
      m_table_indicator_template.Update(true);
      return;
     }
   //--- m_table_indicator_template: col 0 = delete button
   if(id==CHARTEVENT_CUSTOM+ON_CLICK_BUTTON && lparam==m_table_indicator_template.ObjectID())
     {
      int col,row;
      if(!m_table_indicator_template.CellIndexes(sparam,col,row))
         return;
      if(col==0)
         OnClickRemoveIndicator(row);
      return;
     }
   //--- m_table_indicator_template: cols 2..6 = checkboxes, dparam = the new state
   if(id==CHARTEVENT_CUSTOM+ON_CLICK_CHECKBOX && lparam==m_table_indicator_template.ObjectID())
     {
      int col,row;
      if(!m_table_indicator_template.CellIndexes(sparam,col,row))
         return;
      if(col<2 || col>6 || row<0 || row>=(int)m_table_indicator_template.Model().RowsTotal())
         return;
      OnCheckTableIndicatorTemplateSetting(row,col,dparam!=0);
      return;
     }
  }
#endif // CGUIPANNEL_SETTINGWINDOWS_TS_INDICATOR_MQH_IMPLEMENTATION
