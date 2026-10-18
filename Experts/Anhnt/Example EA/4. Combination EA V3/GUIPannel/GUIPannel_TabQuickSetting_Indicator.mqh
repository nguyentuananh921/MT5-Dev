//+------------------------------------------------------------------+
//|                           GUIPannel_TabQuickSetting_Indicator.mqh |
//| Indicator marker tab: the table of the indicator templates       |
//+------------------------------------------------------------------+
#ifndef CGUIPANNEL_TABQUICKSETTING_INDICATOR_MQH
#define CGUIPANNEL_TABQUICKSETTING_INDICATOR_MQH
#include "GUIPannel.mqh"
 //--- Indicator marker tab: the CIndicatorTemplateManager table; 7 columns: Indicator (delete icon), Group, Buy, Sell, Show on chart, Sound, Message
 bool CGUIPannel::CreateTable_IndicatorTemplateSetting(const int x,const int y)
  {
   //--- Show the badges at the left, Add and Save at the right, the table below
   m_check_indicator_show.SetText("Show markers");
   m_check_indicator_show.SetState(m_IndicatorTemplateManager!=NULL && m_IndicatorTemplateManager.ShowMarkers());
   m_tabs_quickSetting.AddToElementsArray(TAB_QUICK_SETTING_INDICATOR,m_check_indicator_show);
   if(!m_check_indicator_show.Create(this.m_chart_id,M_SUBWINDOW_MAIN,"CheckIndicatorShow",x+M_CONTROL_BORDER_GAP,y+M_CONTROL_BORDER_GAP,M_CHECKBOX_SHOW_WIDTH,M_CONTROL_HEIGHT))
      return false;
   m_btn_save_indicator.SetText("Save");
   m_btn_save_indicator.IconFile(IMAGE_RESOURCE_BMP16_SAVE_PNG);
   m_tabs_quickSetting.AddToElementsArray(TAB_QUICK_SETTING_INDICATOR,m_btn_save_indicator);
   if(!m_btn_save_indicator.Create(this.m_chart_id,M_SUBWINDOW_MAIN,"BtnSaveIndicator",m_tabs_quickSetting.Width()-M_BUTTON_SAVE_WIDTH-M_CONTROL_BORDER_GAP,y+M_CONTROL_BORDER_GAP,M_BUTTON_SAVE_WIDTH,M_CONTROL_HEIGHT))
      return false;
   //--- The Add button, left of Save: it opens the window of the indicator types
   m_btn_add_indicator.SetText("Add");
   m_btn_add_indicator.IconFile(IMAGE_RESOURCE_BMP16_ADD_GREEN_PNG);
   m_tabs_quickSetting.AddToElementsArray(TAB_QUICK_SETTING_INDICATOR,m_btn_add_indicator);
   if(!m_btn_add_indicator.Create(this.m_chart_id,M_SUBWINDOW_MAIN,"BtnAddIndicator",m_tabs_quickSetting.Width()-2*M_BUTTON_SAVE_WIDTH-2*M_CONTROL_BORDER_GAP,y+M_CONTROL_BORDER_GAP,M_BUTTON_SAVE_WIDTH,M_CONTROL_HEIGHT))
      return false;
   m_table_indicator_template.TableSize(COLUMNS_INDICATOR_TEMPLATE_TOTAL,0);
   m_table_indicator_template.View().ShowHeaders(true);
   m_table_indicator_template.View().SelectableRow(true);
   m_table_indicator_template.View().LightsHover(true);
   m_table_indicator_template.View().IsSortMode(false);   // row == CIndicatorTemplateManager index
   m_table_indicator_template.AutoXResizeMode(true);
   m_table_indicator_template.AutoXResizeRightOffset(3);
   m_table_indicator_template.AutoYResizeMode(true);
   m_table_indicator_template.AutoYResizeBottomOffset(3);
   m_tabs_quickSetting.AddToElementsArray(TAB_QUICK_SETTING_INDICATOR,m_table_indicator_template);
   if(!m_table_indicator_template.CreateTable(this.m_chart_id,M_SUBWINDOW_MAIN,"TableIndicatorTemplate",x,y+M_CONTROL_BORDER_GAP+M_CONTROL_HEIGHT+M_CONTROL_BORDER_GAP))
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
      m_table_indicator_template.SetValue(c+2,row,(long)(flags[c] ? CANV_ELEMENT_CHECK_STATE_CHECKED : CANV_ELEMENT_CHECK_STATE_UNCHECKED));
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
 //| What the user (or the manager) did that the Indicator tab shows  |
 //+------------------------------------------------------------------+
 void CGUIPannel::OnEvent_Tab_Indicator(const int id,const long &lparam,const double &dparam,const string &sparam)
  {
   //--- The Show check box: the badges of the indicator signals show or hide
   if(id==CHARTEVENT_CUSTOM+ON_CLICK_CHECKBOX && lparam==m_check_indicator_show.ObjectID())
     {
      if(m_IndicatorTemplateManager!=NULL)
         m_IndicatorTemplateManager.ShowMarkers(dparam!=0);
      return;
     }
   //--- The Save button
   if(id==CHARTEVENT_CUSTOM+ON_CLICK_BUTTON && lparam==m_btn_save_indicator.ObjectID())
     {
      if(m_IndicatorTemplateManager!=NULL)
         m_IndicatorTemplateManager.SaveToJSON();
      return;
     }
   //--- The window changed its width: the Save button stays at the right of the tab
   if(id==CHARTEVENT_CUSTOM+ON_WINDOW_CHANGE_XSIZE && lparam==m_window_main.ObjectID())
     {
      m_btn_save_indicator.Move(m_tabs_quickSetting.X()+m_tabs_quickSetting.Width()-M_BUTTON_SAVE_WIDTH-M_CONTROL_BORDER_GAP,m_btn_save_indicator.Y());
      m_btn_add_indicator.Move(m_tabs_quickSetting.X()+m_tabs_quickSetting.Width()-2*M_BUTTON_SAVE_WIDTH-2*M_CONTROL_BORDER_GAP,m_btn_add_indicator.Y());
     }
   //--- CIndicatorTemplateManager changed for real: the table follows it
   if(id==CHARTEVENT_CUSTOM+INDICATOR_TEMPLATE_MANAGER_EVENT_ADDED || id==CHARTEVENT_CUSTOM+INDICATOR_TEMPLATE_MANAGER_EVENT_DELETE)
     {
      if(m_first_start)
         return;
      InitializeTable_IndicatorTemplateSetting();
      SyncTreeView_IndicatorTemplateSetting();   // the blue arrow of a type that has a template
      ::ChartRedraw(this.m_chart_id);
      return;
     }
   //--- A row was attached to / detached from the chart (maybe from the chart side): its Show cell follows
   if(id==CHARTEVENT_CUSTOM+INDICATOR_TEMPLATE_MANAGER_EVENT_SHOW_CHANGED)
     {
      if(m_first_start)
         return;
      //--- Only the Show cell (column 4) changed: set its value, the rest of the row stays as it is
      CIndicatorSetting *entry=(m_IndicatorTemplateManager!=NULL) ? m_IndicatorTemplateManager.At((int)lparam) : NULL;
      if(entry==NULL)
         return;
      m_table_indicator_template.SetValue(4,(int)lparam,(long)(entry.ShowOnChart() ? CANV_ELEMENT_CHECK_STATE_CHECKED : CANV_ELEMENT_CHECK_STATE_UNCHECKED));
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
#endif // CGUIPANNEL_TABQUICKSETTING_INDICATOR_MQH
