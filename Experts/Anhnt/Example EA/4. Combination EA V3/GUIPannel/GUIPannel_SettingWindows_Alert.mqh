//+------------------------------------------------------------------+
//|                               GUIPannel_SettingWindows_Alert.mqh |
//| Setting Marker and Sound window: Marker / Sound tabs; each tab   |
//| handles its own events                                           |
//+------------------------------------------------------------------+
#ifndef CGUIPANNEL_SETTINGWINDOWS_ALERT_MQH
#define CGUIPANNEL_SETTINGWINDOWS_ALERT_MQH
 #include "GUIPannel.mqh"
 bool CGUIPannel::CreateWindow_SettingMarkerAndSound(const string caption_text,const int x_gap,const int y_gap)
  {
   m_window_setting_markerAndSound.FontSize(DEF_FONT_SIZE);
   m_window_setting_markerAndSound.IsMovable(true);
   m_window_setting_markerAndSound.ResizeMode(true);
   m_window_setting_markerAndSound.CloseButtonIsUsed(true);
   m_window_setting_markerAndSound.MinimumXSize(M_WINDOW_MIN_WIDTH);
   m_window_setting_markerAndSound.MinimumYSize(M_WINDOW_MIN_HEIGHT);
   m_window_setting_markerAndSound.WindowType(W_DIALOG);
   if(!m_window_setting_markerAndSound.CreateWindow(m_chart_id,m_subwin,caption_text,x_gap,y_gap,M_WINDOW_SETTING_WIDTH,M_WINDOW_SETTING_HEIGHT))
      return false;
   m_window_setting_markerAndSound.IconFile(IMAGE_RESOURCE_BMP16_ALERT_ON_PNG);
   return true;
  }
 void CGUIPannel::OpenWindow_SettingMarkerAndSound(void)
  {
   m_window_setting_markerAndSound.OpenWindow();
   ::ChartRedraw(m_chart_id);
  }
 bool CGUIPannel::CreateTab_SettingMarkerAndSound(const int x_gap,const int y_gap)
  {
   string tabs_names[ENUM_TAB_SETTING_MARKERANDSOUND_TOTAL]={"Marker","Sound"};
   m_tabs_setting_markerAndSound.PositionMode(TABS_TOP);
   m_tabs_setting_markerAndSound.AutoXResizeMode(true);
   m_tabs_setting_markerAndSound.AutoYResizeMode(true);
   m_tabs_setting_markerAndSound.AutoXResizeRightOffset(3);
   m_tabs_setting_markerAndSound.AutoYResizeBottomOffset(3);
   for(int i=0;i<ENUM_TAB_SETTING_MARKERANDSOUND_TOTAL;i++)
      m_tabs_setting_markerAndSound.AddTab(tabs_names[i],100);
   m_window_setting_markerAndSound.AddChild(&m_tabs_setting_markerAndSound);
   return m_tabs_setting_markerAndSound.CreateTabs(m_chart_id,m_subwin,"TabsSettingAlert",x_gap,y_gap);
  }
 //+------------------------------------------------------------------+
 //| What the user did in the Setting Marker and Sound window         |
 //+------------------------------------------------------------------+
 void CGUIPannel::OnEvent_Window_SettingMarkerAndSound(const int id,const long &lparam,const double &dparam,const string &sparam)
  {
   this.OnEvent_Tab_Marker(id,lparam,dparam,sparam);
  }
#endif // CGUIPANNEL_SETTINGWINDOWS_ALERT_MQH
