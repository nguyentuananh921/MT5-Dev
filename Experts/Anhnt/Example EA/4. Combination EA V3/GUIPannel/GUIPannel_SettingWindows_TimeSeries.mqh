//+------------------------------------------------------------------+
//|                          GUIPannel_SettingWindows_TimeSeries.mqh |
//| Setting Time Series window: Indicator / Symbol TF / Candle       |
//| Pattern / Smart Money tabs; each tab handles its own events      |
//+------------------------------------------------------------------+
#ifndef CGUIPANNEL_SETTINGTIMESERIES_MQH
#define CGUIPANNEL_SETTINGTIMESERIES_MQH
 #include "GUIPannel.mqh"
 bool CGUIPannel::CreateWindow_SettingTimeSeries(const string caption_text,const int x_gap,const int y_gap)
  {
   m_window_setting_timeseries.FontSize(DEF_FONT_SIZE);
   m_window_setting_timeseries.IsMovable(true);
   m_window_setting_timeseries.ResizeMode(true);
   m_window_setting_timeseries.CloseButtonIsUsed(true);
   m_window_setting_timeseries.CollapseButtonIsUsed(true);
   m_window_setting_timeseries.MinimumXSize(M_WINDOW_MIN_WIDTH);
   m_window_setting_timeseries.MinimumYSize(M_WINDOW_MIN_HEIGHT);
   m_window_setting_timeseries.WindowType(W_DIALOG);
   if(!m_window_setting_timeseries.CreateWindow(m_chart_id,m_subwin,caption_text,x_gap,y_gap,M_WINDOW_SETTING_WIDTH,M_WINDOW_SETTING_HEIGHT))
      return false;
   m_window_setting_timeseries.IconFile(IMAGE_RESOURCE_BMP16_INDICATOR_ON_PNG);
   return true;
  }
 void CGUIPannel::OpenWindow_SettingTimeSeries(void)
  {
   m_window_setting_timeseries.OpenWindow();
   m_frame_indicator_parameter.Hide();   // shown again when a type is picked in the tree
   ::ChartRedraw(m_chart_id);
  }
 bool CGUIPannel::CreateTab_SettingTimeSeries(const int x_gap,const int y_gap)
  {
   string tabs_names[TAB_TAB_SETTING_TIMESERIES_TOTAL]={"Indicator","Symbol TF","Candle Pattern","Smart Money Concepts"};
   m_tabs_setting_timeseries.PositionMode(TABS_TOP);
   m_tabs_setting_timeseries.AutoXResizeMode(true);
   m_tabs_setting_timeseries.AutoYResizeMode(true);
   m_tabs_setting_timeseries.AutoXResizeRightOffset(3);
   m_tabs_setting_timeseries.AutoYResizeBottomOffset(3);
   for(int i=0;i<TAB_TAB_SETTING_TIMESERIES_TOTAL;i++)
      m_tabs_setting_timeseries.AddTab(tabs_names[i],100);
   m_window_setting_timeseries.AddChild(&m_tabs_setting_timeseries);
   return m_tabs_setting_timeseries.CreateTabs(m_chart_id,m_subwin,"TabsSettingTS",x_gap,y_gap);
  }
 //+------------------------------------------------------------------+
 //| What the user did in the Setting Time Series window              |
 //+------------------------------------------------------------------+
 void CGUIPannel::OnEvent_Window_SettingTimeSeries(const int id,const long &lparam,const double &dparam,const string &sparam)
  {
   //--- A Save button asks the model of its tab to write its own key of the configuration file
   if(id==CHARTEVENT_CUSTOM+ON_CLICK_BUTTON && lparam==m_btn_save_indicator.ObjectID())
     {
      if(m_IndicatorTemplateManager!=NULL)
         m_IndicatorTemplateManager.Save();
      return;
     }
   if(id==CHARTEVENT_CUSTOM+ON_CLICK_BUTTON && lparam==m_btn_save_pattern_config.ObjectID())
     {
      if(m_PatternManager!=NULL)
         m_PatternManager.Save();
      return;
     }
   if(id==CHARTEVENT_CUSTOM+ON_CLICK_BUTTON && lparam==m_btn_save_SymbolTF.ObjectID())
     {
      if(m_SymbolTFManager!=NULL)
         m_SymbolTFManager.Save();
      return;
     }
   if(id==CHARTEVENT_CUSTOM+ON_CLICK_BUTTON && lparam==m_btn_save_swing_config.ObjectID())
     {
      if(m_SmartMoneySetting!=NULL)
         m_SmartMoneySetting.Save();
      return;
     }
   this.OnEvent_Tab_Indicator(id,lparam,dparam,sparam);
   this.OnEvent_Tab_CandlePattern(id,lparam,dparam,sparam);
   this.OnEvent_Tab_SymbolTF(id,lparam,dparam,sparam);
   this.OnEvent_Tab_SmartMoney(id,lparam,dparam,sparam);
  }
#endif //CGUIPANNEL_SETTINGTIMESERIES_MQH
