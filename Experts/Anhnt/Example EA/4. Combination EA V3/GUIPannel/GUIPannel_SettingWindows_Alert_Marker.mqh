//+------------------------------------------------------------------+
//|                        GUIPannel_SettingWindows_Alert_Marker.mqh |
//| Marker tab: the colors of the CCandleMarker badges and which of  |
//| the 3 sources show a marker                                      |
//+------------------------------------------------------------------+
#ifndef CGUIPANNEL_SETTINGWINDOWS_ALERT_MARKER_MQH
#define CGUIPANNEL_SETTINGWINDOWS_ALERT_MARKER_MQH
 #include "GUIPannel.mqh"
 #define SETTING_MARKER_CAPTION_WIDTH        130   // combo caption
 #define SETTING_MARKER_COMBOBOX_WIDTH       150
 #define SETTING_MARKER_PREVIEW_WIDTH        32
 #define SETTING_MARKER_ROW_STEP             30
 #define SETTING_MARKER_LIST_ROWS            8     // visible rows of a dropdown list
 #define SETTING_MARKER_COLOR_COMBO_WIDTH    100
 #define SETTING_MARKER_COLOR_PREVIEW_WIDTH  40
 //--- "Color for Marker" frame: Buy | Sell; "Show Marker" frame under it; Save last
 bool CGUIPannel::CreateTab_SettingConfig_Marker(const int x,const int y)
  {
   if(m_MarkerSetting==NULL)
      return false;
   color mcolors[];
   string color_labels[];
   m_MarkerSetting.GetColorChoices(mcolors,color_labels);
   const int frame_w=M_CONTROL_BORDER_GAP+SETTING_MARKER_CAPTION_WIDTH+SETTING_MARKER_COMBOBOX_WIDTH+M_CONTROL_BORDER_GAP+SETTING_MARKER_PREVIEW_WIDTH+M_CONTROL_BORDER_GAP;
   const int frame1_x=x+M_CONTROL_BORDER_GAP;
   const int frame2_x=frame1_x+frame_w+M_CONTROL_BORDER_GAP;
   const int color_frame_w=frame2_x+frame_w-frame1_x;
   const int color_frame_h=M_CONTROL_HEIGHT+M_CONTROL_HEIGHT+M_CONTROL_BORDER_GAP;
   m_frame_color.SetText("Color for Marker");
   m_tabs_setting_markerAndSound.AddToElementsArray(ENUM_TAB_SETTING_MARKERANDSOUND_MARKER,m_frame_color);
   if(!m_frame_color.CreateFrame(m_chart_id,m_subwin,"FrameMarkerColor",frame1_x,y,color_frame_w,color_frame_h))
      return false;
   CComboBox *color_combos[2];
   color_combos[0]=::GetPointer(m_combo_color_buy);
   color_combos[1]=::GetPointer(m_combo_color_sell);
   string color_captions[2]={"Buy Color","Sell Color"};
   color  cur_colors[2]    ={m_MarkerSetting.BuyColor(),m_MarkerSetting.SellColor()};
   int    color_x[2]       ={M_CONTROL_BORDER_GAP,frame2_x-frame1_x+M_CONTROL_BORDER_GAP};
   for(int i=0;i<2;i++)
     {
      int sel=0;
      for(int k=0;k<::ArraySize(mcolors);k++)
         if(mcolors[k]==cur_colors[i])
            sel=k;
      m_frame_color.AddChild(color_combos[i]);
      m_frame_color.AddChild(::GetPointer(m_colorbutton[i]));
      color_combos[i].SetText(color_captions[i]);
      if(!CreateCombobox_MarkerSelection(color_combos[i],color_x[i],M_CONTROL_HEIGHT,SETTING_MARKER_COLOR_COMBO_WIDTH,color_labels,sel))
         return false;
      int swatch_x=color_x[i]+SETTING_MARKER_CAPTION_WIDTH+SETTING_MARKER_COLOR_COMBO_WIDTH+M_CONTROL_BORDER_GAP;
      if(!CreateColorButton_Preview(i,swatch_x,M_CONTROL_HEIGHT,cur_colors[i]))
         return false;
     }
   const int source_frame_y=y+color_frame_h+M_CONTROL_BORDER_GAP;
   const int source_frame_h=M_CONTROL_HEIGHT+SETTING_MARKER_ROW_STEP+M_CONTROL_HEIGHT+M_CONTROL_BORDER_GAP;
   if(!CreateFrame_MarkerSource(frame1_x,source_frame_y,color_frame_w,source_frame_h,frame2_x-frame1_x))
      return false;
   m_btn_save_marker_settings.SetText("Save");
   m_btn_save_marker_settings.IconFile(IMAGE_RESOURCE_BMP16_SAVE_PNG);
   m_tabs_setting_markerAndSound.AddToElementsArray(ENUM_TAB_SETTING_MARKERANDSOUND_MARKER,m_btn_save_marker_settings);
   if(!m_btn_save_marker_settings.Create(m_chart_id,m_subwin,"BtnSaveMarker",frame1_x,source_frame_y+source_frame_h+M_CONTROL_BORDER_GAP,80,M_CONTROL_HEIGHT))
      return false;
   return true;
  }
 //--- "Show Marker" frame: which of the 3 sources make a marker show, 2 + 1 check boxes;
 //--- column_x = x of the second column inside the frame, the first one is at the border gap
 bool CGUIPannel::CreateFrame_MarkerSource(const int x,const int y,const int w,const int h,const int column_x)
  {
   m_frame_marker_source.SetText("Show Marker");
   m_tabs_setting_markerAndSound.AddToElementsArray(ENUM_TAB_SETTING_MARKERANDSOUND_MARKER,m_frame_marker_source);
   if(!m_frame_marker_source.CreateFrame(m_chart_id,m_subwin,"FrameMarkerSource",x,y,w,h))
      return false;
   CCheckBox *source_boxes[3];
   source_boxes[0]=::GetPointer(m_checkbox_show_indicator_markers);
   source_boxes[1]=::GetPointer(m_checkbox_show_candle_markers);
   source_boxes[2]=::GetPointer(m_checkbox_show_smartMoney_markers);
   string source_captions[3]={"Indicator","Candle Pattern","Smart Money"};
   bool   source_states[3]  ={(m_IndicatorTemplateManager==NULL || m_IndicatorTemplateManager.AllBuySell()),
                              (m_PatternManager==NULL || m_PatternManager.AllBuySell()),
                              (m_SmartMoneySetting==NULL || m_SmartMoneySetting.AllShown())};
   int    source_x[3]       ={M_CONTROL_BORDER_GAP,column_x+M_CONTROL_BORDER_GAP,M_CONTROL_BORDER_GAP};
   int    source_y[3]       ={M_CONTROL_HEIGHT,M_CONTROL_HEIGHT,M_CONTROL_HEIGHT+SETTING_MARKER_ROW_STEP};
   for(int i=0;i<3;i++)
     {
      m_frame_marker_source.AddChild(source_boxes[i]);
      source_boxes[i].SetText(source_captions[i]);
      if(!CreateCheckBox_Setting(source_boxes[i],source_x[i],source_y[i],source_states[i],ENUM_TAB_SETTING_MARKERANDSOUND_MARKER,SETTING_MARKER_CAPTION_WIDTH))
         return false;
     }
   return true;
  }
 //--- Caption (the combo's own SetText, if any) + list of labels
 bool CGUIPannel::CreateCombobox_MarkerSelection(CComboBox &combo,const int x,const int y,const int combo_w,string &labels[],const int selected_index,const int tab_index)
  {
   int n=::ArraySize(labels);
   int caption_w=(combo.Text()!="") ? SETTING_MARKER_CAPTION_WIDTH : 0;
   int list_h=18*::MathMax(::MathMin(n,SETTING_MARKER_LIST_ROWS),1)+4;   // longer lists scroll
   combo.ItemsTotal(n);
   if(combo.Parent()==NULL)
      m_tabs_setting_markerAndSound.AddToElementsArray(tab_index,combo);
   if(!combo.CreateComboBox(m_chart_id,m_subwin,"ComboAlert"+(string)combo.ObjectID(),x,y,caption_w+combo_w,M_CONTROL_HEIGHT,combo_w,list_h))
      return false;
   combo.GetListViewPointer().Rebuilding(n);
   for(int i=0;i<n;i++)
      combo.SetValue(i,labels[i]);
   if(n>0)
      combo.SelectItem(selected_index);
   combo.GetListViewPointer().Draw(false);   // SetValue/SelectItem only store, the list canvas still shows the empty Rebuilding
   return true;
  }
 bool CGUIPannel::CreateCheckBox_Setting(CCheckBox &checkbox,const int x,const int y,const bool pressed,const int tab_index,const int width)
  {
   if(checkbox.Parent()==NULL)
      m_tabs_setting_markerAndSound.AddToElementsArray(tab_index,checkbox);
   if(!checkbox.Create(m_chart_id,m_subwin,"CheckSetting"+(string)checkbox.ObjectID(),x,y,(width>0 ? width : SETTING_MARKER_CAPTION_WIDTH),M_CONTROL_HEIGHT))
      return false;
   checkbox.SetState(pressed);
   return true;
  }
 //--- Color swatch: a plain CButton whose background is the color (no color picker in the Library)
 bool CGUIPannel::CreateColorButton_Preview(const int row,const int x,const int y,const color clr)
  {
   if(m_colorbutton[row].Parent()==NULL)
      m_tabs_setting_markerAndSound.AddToElementsArray(ENUM_TAB_SETTING_MARKERANDSOUND_MARKER,m_colorbutton[row]);
   if(!m_colorbutton[row].Create(m_chart_id,m_subwin,"BtnMarkerColor"+(string)row,x,y,SETTING_MARKER_COLOR_PREVIEW_WIDTH,M_CONTROL_HEIGHT))
      return false;
   UpdateColorPreview(row,clr);
   return true;
  }
 void CGUIPannel::UpdateColorPreview(const int row,const color clr)
  {
   m_colorbutton[row].GetBackColorControl().InitColors(clr,clr,clr,clr);
   m_colorbutton[row].ColorChange(COLOR_STATE_DEFAULT);
   m_colorbutton[row].Draw(true);
  }
 //--- The Smart Money check box shows or hides every Smart Money element at once (the Smart Money table keeps the fine control)
 void CGUIPannel::ApplyShowToAllSmartMoney(const bool on)
  {
   if(m_SmartMoneySetting==NULL)
      return;
   bool changed=false;
   changed|=m_SmartMoneySetting.SignalShow(SWING_TYPE_HIGH,on);
   changed|=m_SmartMoneySetting.SignalShow(SWING_TYPE_LOW,on);
   changed|=m_SmartMoneySetting.SignalShow(MARKET_STRUCTURE_BOS,on);
   changed|=m_SmartMoneySetting.SignalShow(MARKET_STRUCTURE_CHOCH,on);
   if(!changed)
      return;
   InitializeTable_SmartMoneySetting();
   ::EventChartCustom(::ChartID(),(ushort)GUIPANNEL_EVENT_SMARTMONEY_SETTING_CHANGED,0,0.0,"");
  }
 //--- The three check boxes are on only while every flag behind them is on (tables can change the flags one by one)
 void CGUIPannel::SyncMarkerSourceCheckBoxes(void)
  {
   if(m_IndicatorTemplateManager!=NULL)
      m_checkbox_show_indicator_markers.SetState(m_IndicatorTemplateManager.AllBuySell());
   if(m_PatternManager!=NULL)
      m_checkbox_show_candle_markers.SetState(m_PatternManager.AllBuySell());
   if(m_SmartMoneySetting!=NULL)
      m_checkbox_show_smartMoney_markers.SetState(m_SmartMoneySetting.AllShown());
  }
 //+------------------------------------------------------------------+
 //| What the user did in the Marker tab                              |
 //+------------------------------------------------------------------+
 void CGUIPannel::OnEvent_Tab_Marker(const int id,const long &lparam,const double &dparam,const string &sparam)
  {
   //--- The flags changed somewhere else (a table, Python's catalog): the check boxes follow them
   if(id==CHARTEVENT_CUSTOM+PATTERN_MANAGER_EVENT_BUYSELL_CHANGED || id==CHARTEVENT_CUSTOM+PATTERN_MANAGER_EVENT_CATALOG_CHANGED ||
      id==CHARTEVENT_CUSTOM+INDICATOR_TEMPLATE_MANAGER_EVENT_BUYSELL_CHANGED || id==CHARTEVENT_CUSTOM+INDICATOR_TEMPLATE_MANAGER_EVENT_ADDED ||
      id==CHARTEVENT_CUSTOM+INDICATOR_TEMPLATE_MANAGER_EVENT_DELETE || id==CHARTEVENT_CUSTOM+GUIPANNEL_EVENT_SMARTMONEY_SETTING_CHANGED)
     {
      if(m_gui_created)
         SyncMarkerSourceCheckBoxes();
      return;
     }
   //--- Indicator / Candle Pattern check boxes: the master switch of the Buy and Sell flag of every indicator / candle pattern
   if(id==CHARTEVENT_CUSTOM+ON_CLICK_CHECKBOX && lparam==m_checkbox_show_indicator_markers.ObjectID())
     {
      if(m_IndicatorTemplateManager!=NULL)
        {
         m_IndicatorTemplateManager.SetAllBuySell(dparam!=0);
         InitializeTable_IndicatorTemplateSetting();
        }
      return;
     }
   if(id==CHARTEVENT_CUSTOM+ON_CLICK_CHECKBOX && lparam==m_checkbox_show_candle_markers.ObjectID())
     {
      if(m_PatternManager!=NULL)
        {
         m_PatternManager.SetAllBuySell(dparam!=0);
         InitializeTable_CandlePatternSetting();
        }
      return;
     }
   //--- Smart Money check box: Show of every Smart Money element on or off
   if(id==CHARTEVENT_CUSTOM+ON_CLICK_CHECKBOX && lparam==m_checkbox_show_smartMoney_markers.ObjectID())
     {
      ApplyShowToAllSmartMoney(dparam!=0);
      return;
     }
   //--- Combo pick: the swatch updates right away, before Save (dparam = selected index)
   if(id==CHARTEVENT_CUSTOM+ON_CLICK_COMBOBOX_ITEM)
     {
      int sel=(int)dparam;
      color mcolors[];
      string color_labels[];
      if(m_MarkerSetting!=NULL)
         m_MarkerSetting.GetColorChoices(mcolors,color_labels);
      bool color_ok=(sel>=0 && sel<::ArraySize(mcolors));
      if(lparam==m_combo_color_buy.ObjectID() && color_ok)
         UpdateColorPreview(0,mcolors[sel]);
      else if(lparam==m_combo_color_sell.ObjectID() && color_ok)
         UpdateColorPreview(1,mcolors[sel]);
      return;
     }
   //--- Save: commit what the combos and the check boxes hold, then the model writes its own key and the EA draws again
   if(id==CHARTEVENT_CUSTOM+ON_CLICK_BUTTON && lparam==m_btn_save_marker_settings.ObjectID())
     {
      if(m_MarkerSetting==NULL)
         return;
      color mcolors[];
      string color_labels[];
      m_MarkerSetting.GetColorChoices(mcolors,color_labels);
      int n_colors=::ArraySize(mcolors);
      color buy_clr=m_MarkerSetting.BuyColor(),sell_clr=m_MarkerSetting.SellColor();
      int sel=m_combo_color_buy.GetListViewPointer().SelectedItemIndex();
      if(sel>=0 && sel<n_colors)
         buy_clr=mcolors[sel];
      sel=m_combo_color_sell.GetListViewPointer().SelectedItemIndex();
      if(sel>=0 && sel<n_colors)
         sell_clr=mcolors[sel];
      m_MarkerSetting.SetColors(buy_clr,sell_clr,m_MarkerSetting.NonRelatedColor());
      m_MarkerSetting.SetShowMarkers(m_checkbox_show_indicator_markers.State(),m_checkbox_show_candle_markers.State(),
                                     m_checkbox_show_smartMoney_markers.State());
      m_MarkerSetting.Save();
      //--- The flags the markers are drawn from belong to their own models: they write their own keys too
      if(m_IndicatorTemplateManager!=NULL)
         m_IndicatorTemplateManager.Save();
      if(m_PatternManager!=NULL)
         m_PatternManager.Save();
      if(m_SmartMoneySetting!=NULL)
         m_SmartMoneySetting.Save();
      ::EventChartCustom(::ChartID(),(ushort)GUIPANNEL_EVENT_MARKER_SETTING_CHANGED,0,0.0,"");
      return;
     }
  }
#endif //CGUIPANNEL_SETTINGWINDOWS_ALERT_MARKER_MQH
