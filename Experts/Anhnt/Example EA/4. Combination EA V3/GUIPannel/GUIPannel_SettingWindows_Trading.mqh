//+------------------------------------------------------------------+
//|                             GUIPannel_SettingWindows_Trading.mqh |
//| Setting Trading window: StopLost / Trailling tabs                |
//+------------------------------------------------------------------+
#ifndef CGUIPANNEL_SETTINGWINDOWS_TRADING_MQH_IMPLEMENTATION
#define CGUIPANNEL_SETTINGWINDOWS_TRADING_MQH_IMPLEMENTATION
 #include "GUIPannel.mqh"
 bool CGUIPannel::CreateWindow_SettingTrading(const string caption_text,const int x_gap, const int y_gap)
  {
   m_window_setting_trading.FontSize(DEF_FONT_SIZE);
   m_window_setting_trading.IsMovable(true);
   m_window_setting_trading.ResizeMode(true);
   m_window_setting_trading.CloseButtonIsUsed(true);
   m_window_setting_trading.MinimumXSize(M_WINDOW_MIN_WIDTH);
   m_window_setting_trading.MinimumYSize(M_WINDOW_MIN_HEIGHT);
   m_window_setting_trading.WindowType(W_DIALOG);
   if(!m_window_setting_trading.CreateWindow(m_ChartObj.GetChartID(), M_SUBWINDOW_MAIN, caption_text, x_gap, y_gap,
                                           M_WINDOW_TRADING_SETTING_WIDTH, M_WINDOW_TRADING_SETTING_HEIGHT))
      return false;
   m_window_setting_trading.IconFile(IMAGE_RESOURCE_BMP16_TRADE_ON_PNG);
   return true;
  }
 void CGUIPannel::OpenWindow_SettingTrading(void)
  {
   m_window_setting_trading.OpenWindow();
   //--- OpenWindow() shows the whole subtree: the forms only appear on a Symbol click
   HideStopLostForm();
   HideTrailingForm();
   SyncTable_StopLostSetting();
   SyncTable_TrailingSetting();
   ::ChartRedraw(m_ChartObj.GetChartID());
  }
 bool CGUIPannel::CreateTab_SettingTrading(const int x_gap, const int y_gap)
  {
   string tabs_names[ENUM_TAB_SETTING_TRADING_TOTAL] = {"StopLost", "Trailling"};
   m_tabs_setting_trading.PositionMode(TABS_TOP);
   m_tabs_setting_trading.AutoXResizeMode(true);
   m_tabs_setting_trading.AutoYResizeMode(true);
   m_tabs_setting_trading.AutoXResizeRightOffset(3);
   m_tabs_setting_trading.AutoYResizeBottomOffset(3);
   for(int i = 0; i < ENUM_TAB_SETTING_TRADING_TOTAL; i++)
      m_tabs_setting_trading.AddTab(tabs_names[i], 100);
   m_window_setting_trading.AddChild(&m_tabs_setting_trading);
   return m_tabs_setting_trading.CreateTabs(m_ChartObj.GetChartID(), M_SUBWINDOW_MAIN, "TabsSettingTrading", x_gap, y_gap);
  }
 void CGUIPannel::OnEvent_Window_SettingTrading(const int id,const long &lparam, const double &dparam, const string &sparam)
  {
   //--- Tab switch / window expand: Show() cascaded to the hidden forms again
    if((id == CHARTEVENT_CUSTOM + ON_CLICK_TAB && lparam == m_tabs_setting_trading.ObjectID()) ||
       (id == CHARTEVENT_CUSTOM + ON_WINDOW_EXPAND && lparam == m_window_setting_trading.ObjectID()))
     {
      HideStopLostForm();
      HideTrailingForm();
      ::ChartRedraw(m_ChartObj.GetChartID());
      return;
     }
   //--- Save commits BOTH Fixed and Indicator StopLost config at once
    if(id == CHARTEVENT_CUSTOM + ON_CLICK_BUTTON && lparam == m_btn_save_StopLost_Setting.ObjectID())
     {
      string label_text = m_label_StopLostSetting_Symbol.Text();
      int    sep        = ::StringFind(label_text, " - ");
      string symbol     = (sep >= 0) ? ::StringSubstr(label_text, sep + 3) : "";
      if(symbol == "" || m_TradingSetupManager == NULL) return;
      CTradingSetupSetting *row_setting = m_TradingSetupManager.FindByIdentity(symbol);
      if(row_setting == NULL) row_setting = m_TradingSetupManager.Add_TradingSetupSetting(symbol);
      if(row_setting == NULL) return;
      row_setting.StopLostFixedMultiplier(::StringToDouble(m_edit_StopLost_FixedPoint.GetValue()));
      row_setting.StopLostIndMultiplier(::StringToDouble(m_edit_ATR_Multiplexer.GetValue()));
      ENUM_TIMEFRAMES tf;
      int             period;
      if(GetSelectedATRChoice(tf, period))
       {
        row_setting.StopLostIndTF(tf);
        row_setting.StopLostIndType(IND_ATR);
        MqlParam sl_ind_p[1];
        sl_ind_p[0].type          = TYPE_INT;
        sl_ind_p[0].integer_value = period;
        row_setting.SetStopLostIndParams(sl_ind_p);
        //--- Python calculates the tracked pairs only: the pair of the choice joins them (the events keep the panel and Python in step)
        if(m_SymbolTFManager != NULL && !m_SymbolTFManager.Exists(symbol, tf))
         {
          m_SymbolTFManager.Add_SymbolTFSetting(symbol, tf);
          m_SymbolTFManager.Save();
         }
        if(m_IndicatorsCollection != NULL && m_IndicatorsCollection.GetIndicator(IND_ATR, sl_ind_p, symbol, tf) == NULL)
           m_IndicatorsCollection.CreateIndicator(IND_ATR, sl_ind_p, symbol, tf);
       }
      m_TradingSetupManager.NotifySettingChanged(symbol);
      m_TradingSetupManager.Save();
      SyncTable_StopLostSetting();
      HideStopLostForm();
      ::ChartRedraw(m_ChartObj.GetChartID());
      return;
     }
   //--- ATR pick: only a draft, the preview follows; Save commits the Fixed and the Indicator mode together
    if(id == CHARTEVENT_CUSTOM + ON_CLICK_COMBOBOX_ITEM && lparam == m_combobox_ATR_choice.ObjectID())
     {
      string label_text = m_label_StopLostSetting_Symbol.Text();
      int    sep        = ::StringFind(label_text, " - ");
      string symbol     = (sep >= 0) ? ::StringSubstr(label_text, sep + 3) : "";
      if(symbol != "" && symbol != "-" && UpdateStopLostPreview(symbol))
         ::ChartRedraw(m_ChartObj.GetChartID());
      return;
     }
   //--- m_table_stoplostsetting: Symbol (col 0) navigates + opens the form, gear (col 3) opens the form
    if(id == CHARTEVENT_CUSTOM + ON_CLICK_LIST_ITEM && lparam == m_table_stoplostsetting.ObjectID())
     {
      int col, row;
      if(!m_table_stoplostsetting.CellIndexes(sparam, col, row)) return;
      if(col != 0 && col != 3) return;
      string clicked_sym = m_table_stoplostsetting.Cell(0, row).ValueS();
      if(clicked_sym == "") return;
      if(col == 0 && m_SymbolTFManager != NULL)
         m_SymbolTFManager.NotifySettingChanged(clicked_sym, (ENUM_TIMEFRAMES)::Period());
      ShowStopLostForm(clicked_sym);
      return;
     }
   //--- m_table_trailingsetting: Symbol / Trailling icon scopes the Indicator table + form to that Symbol
    if(id == CHARTEVENT_CUSTOM + ON_CLICK_LIST_ITEM && lparam == m_table_trailingsetting.ObjectID())
     {
      int col, row;
      if(!m_table_trailingsetting.CellIndexes(sparam, col, row)) return;
      if(col != 0 && col != 3) return;
      string clicked_sym = m_table_trailingsetting.Cell(0, row).ValueS();
      if(clicked_sym == "") return;
      if(m_SymbolTFManager != NULL)
         m_SymbolTFManager.NotifySettingChanged(clicked_sym, (ENUM_TIMEFRAMES)::Period());
      m_label_TrailingSetting_Symbol.SetText("Symbol - " + clicked_sym);
      m_label_TrailingSetting_Symbol.Draw(false);
      SyncTable_IndicatorsTrailingSetting(clicked_sym, true);
      ShowTrailingForm(clicked_sym);
      ::ChartRedraw(m_ChartObj.GetChartID());
      return;
     }
   //--- m_table_indicators_trailingsetting: col 3 picks the Trailing-by-Indicator source
    if(id == CHARTEVENT_CUSTOM + ON_CLICK_CHECKBOX && lparam == m_table_indicators_trailingsetting.ObjectID())
     {
      int col, row;
      if(!m_table_indicators_trailingsetting.CellIndexes(sparam, col, row)) return;
      if(col == 3) OnCheckTable_IndicatorsTrailingSetting(row);
      return;
     }
   //--- Save commits Offset/Start/Step for the scoped Symbol + the EA-wide M1 bar shift
    if(id == CHARTEVENT_CUSTOM + ON_CLICK_BUTTON && lparam == m_btn_save_Trailing_Setting.ObjectID())
     {
      string label_text = m_label_TrailingSetting_Symbol.Text();
      int    sep        = ::StringFind(label_text, " - ");
      string symbol     = (sep >= 0) ? ::StringSubstr(label_text, sep + 3) : "";
      if(symbol == "" || m_TradingSetupManager == NULL) return;
      CTradingSetupSetting *row_setting = m_TradingSetupManager.FindByIdentity(symbol);
      if(row_setting == NULL) row_setting = m_TradingSetupManager.Add_TradingSetupSetting(symbol);
      if(row_setting == NULL) return;
      //--- the Indicator picked in the table is a draft too: it goes in with Offset/Start/Step
      for(int r = 0; r < (int)m_table_indicators_trailingsetting.Model().RowsTotal(); r++)
         if(m_table_indicators_trailingsetting.Cell(3, r).ValueL() == CANV_ELEMENT_CHEK_STATE_CHECKED)
          {
           OnCheckTable_IndicatorsTrailingSetting(r, true);
           break;
          }
      row_setting.TrailingOffsetPts((int)::StringToInteger(m_edit_Trailing_Offset.GetValue()));
      row_setting.TrailingStartPts((int)::StringToInteger(m_edit_Trailing_Start.GetValue()));
      row_setting.TrailingStepPts((int)::StringToInteger(m_edit_Trailing_Step.GetValue()));
      m_TradingSetupManager.TrailingDataRatesIndex((int)::StringToInteger(m_edit_Trailing_DataRatesIndex.GetValue()));
      m_TradingSetupManager.NotifySettingChanged(symbol);
      m_TradingSetupManager.Save();
      SyncTable_TrailingSetting();
      HideTrailingForm();
      ::ChartRedraw(m_ChartObj.GetChartID());
      return;
     }
  }
#endif // CGUIPANNEL_SETTINGWINDOWS_TRADING_MQH_IMPLEMENTATION
