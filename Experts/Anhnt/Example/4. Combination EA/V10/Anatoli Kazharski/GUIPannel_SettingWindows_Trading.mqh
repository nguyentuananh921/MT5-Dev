//+------------------------------------------------------------------+
//|                             GUIPannel_SettingWindows_Trading.mqh |
//| Module for Setting Trading                                       |
//+------------------------------------------------------------------+
#ifndef CGUIPANNEL_SETTINGWINDOWS_TRADING_MQH_IMPLEMENTATION
#define CGUIPANNEL_SETTINGWINDOWS_TRADING_MQH_IMPLEMENTATION
 #include "GUIPannel.mqh"
 bool CGUIPannel::CreateWindow_SettingTrading(const string caption_text,const int x_gap, const int y_gap)
  {
   //--- Add a window pointer to the window array
    CWndContainer::AddWindow(m_window_setting_trading);
   //Setting Properties
    m_window_setting_trading.XSize(M_WINDOW_SETTING_WIDTH);
    m_window_setting_trading.YSize(M_WINDOW_SETTING_HEIGHT);
    m_window_setting_trading.FontSize(9);
    m_window_setting_trading.IsMovable(true);
    m_window_setting_trading.ResizeMode(true);
    m_window_setting_trading.CloseButtonIsUsed(true);
    m_window_setting_trading.CollapseButtonIsUsed(true);
    m_window_setting_trading.TooltipsButtonIsUsed(true);
    m_window_setting_trading.FullscreenButtonIsUsed(true);
    m_window_setting_trading.MinimumXSize(M_WINDOW_MIN_WIDTH);
    m_window_setting_trading.MinimumYSize(M_WINDOW_MIN_HEIGHT);
    m_window_setting_trading.WindowType(W_DIALOG);    
   //Show Window at 30,30
    if(!m_window_setting_trading.CreateWindow(m_chart_id, m_subwin, caption_text, x_gap, y_gap))
       return (false);
   //Set Icon after Create
    m_window_setting_trading.IconFile(IMAGE_RESOURCE_BMP16_TRADE_ON_PNG );
    m_window_setting_trading.IconFileLocked(IMAGE_RESOURCE_BMP16_TRADING_OFF_PNG);
    return (true);
  }
 void CGUIPannel::OpenWindow_SettingTrading(void)
  {
    m_window_setting_trading.OpenWindow();
    //--- CWindow::Draw() paints whatever ChangeImage() last selected - IsLocked() alone never
    //--- flips it (only the caption background color reacts to that), so switch icons ourselves.
    m_window_setting_trading.ChangeImage(0, 0);   // IconFile - active
    
    HideWindow_CandleInfo();
    m_candle_info_shown_bar = 0;
    FormAvailableElementsArray();
  }
 void CGUIPannel::CloseWindow_SettingTrading(void)
  {
    m_window_setting_trading.Hide();
    m_window_setting_trading.ChangeImage(0, 1);   // IconFileLocked - inactive
    m_active_window_index = WindowIdx(m_window_main);
    FormAvailableElementsArray();
  }
//For Tab Group on m_window_setting_trading
 //+----------------------------------------------------------------------------------------------+
 //| Create a tab group m_tabs_setting_trading for m_window_setting_trading                        |
 //+----------------------------------------------------------------------------------------------+
 bool CGUIPannel::CreateTab_SettingTrading(const int x_gap, const int y_gap)
  {
    string tabs_names[ENUM_TAB_SETTING_TRADING_TOTAL] = {"StopLost","Trailling"};    
    m_tabs_setting_trading.MainPointer(m_window_setting_trading);
    //--- Properties
    m_tabs_setting_trading.IsCenterText(true);
    m_tabs_setting_trading.PositionMode(TABS_TOP);
    m_tabs_setting_trading.AutoXResizeMode(true);
    m_tabs_setting_trading.AutoYResizeMode(true);
    m_tabs_setting_trading.AutoXResizeRightOffset(3);
    m_tabs_setting_trading.AutoYResizeBottomOffset(3);
    //--- Add tabs with the specified properties
    for(int i = 0; i < ENUM_TAB_SETTING_TRADING_TOTAL; i++)
        m_tabs_setting_trading.AddTab(tabs_names[i], 100);
    //--- Create Tab before create other control element inside
     if(!m_tabs_setting_trading.CreateTabs(x_gap, y_gap))
        return (false);
    CWndContainer::AddToElementsArray(WindowIdx(m_window_setting_trading), m_tabs_setting_trading);    
    return (true);
  }
 void CGUIPannel::OnEvent_Window_SettingTrading(const int id,const long &lparam, const double &dparam, const string &sparam)
  {
   //--- Setting Trading Window's native Close (X) button
     if(id == CHARTEVENT_CUSTOM + ON_CLOSE_DIALOG_BOX && lparam == m_window_setting_trading.Id())
      {
       CloseWindow_SettingTrading();
       return;
      }
   //Handle m_btn_save_StopLost_Setting - commits BOTH Fixed and Indicator config at once 
     if(id == CHARTEVENT_CUSTOM + ON_CLICK_BUTTON && lparam == m_btn_save_StopLost_Setting.Id())
      {
       //--- No separate "current symbol" cache Property - read it straight back off the form's own
       //--- Symbol label ("Symbol - XAUUSDm"), which ShowStopLostForm already keeps up to date.
       string label_text = m_label_StopLostSetting_Symbol.LabelText();
       int    sep         = StringFind(label_text, " - ");
       string symbol      = (sep >= 0) ? StringSubstr(label_text, sep + 3) : "";
       if(symbol == "" || m_trading_setup_manager == NULL) return;
       CTradingSetupSetting *row_setting = m_trading_setup_manager.FindByIdentity(symbol);
       if(row_setting == NULL) row_setting = m_trading_setup_manager.Add_TradingSetupSetting(symbol);
       if(row_setting == NULL) return;

       row_setting.StopLostFixedMultiplier(StringToDouble(m_edit_StopLost_FixedPoint.GetValue()));

       row_setting.StopLostIndMultiplier(StringToDouble(m_edit_ATR_Multiplexer.GetValue()));
       ENUM_TIMEFRAMES tf;
       int             period;
       if(GetSelectedATRChoice(symbol, tf, period))
        {
         row_setting.StopLostIndTF(tf);
         row_setting.StopLostIndType(IND_ATR);
         MqlParam sl_ind_p[1];
         sl_ind_p[0].type          = TYPE_INT;
         sl_ind_p[0].integer_value = period;
         row_setting.SetStopLostIndParams(sl_ind_p);
        }
       m_trading_setup_manager.NotifySettingChanged(symbol);
       //--- StopLost-by-Indicator only works live if its ATR template + the Symbol/TF pair it runs
       //--- on already exist (that's exactly what the ATR combobox's own choices are scoped to -
       //--- see SyncComboBox_ATRChoice) - but "exist in memory" isn't "persisted to disk" until
       //--- their OWN Save buttons are clicked. Save them here too so StopLost_Setting never points
       //--- at an Indicator_Templates/Symbols_TFs_List entry that didn't actually get written.
       if(m_indicator_template_manager != NULL) m_indicator_template_manager.SaveIndicatorTemplateToJSON();
       if(m_SymbolTFManager != NULL) m_SymbolTFManager.SaveSymbolTFSettingToJSON();
       m_trading_setup_manager.SaveTradingSetupSettingToJSON();
       SyncTable_StopLostSetting(true);
       HideStopLostForm();
       return;
      }
   // Handle m_table_stoplostsetting Symbol cell click 
     if(id == CHARTEVENT_CUSTOM + ON_CLICK_LIST_ITEM && lparam == m_table_stoplostsetting.Id())
      {
       string parts[];
       if(StringSplit(sparam, '_', parts) != 2) return;
       int col = (int)StringToInteger(parts[0]);
       int row = (int)StringToInteger(parts[1]);
       if(col == 0)
        {
         string clicked_sym = m_table_stoplostsetting.GetValue(0, row);
         if(m_SymbolTFManager != NULL && clicked_sym != "")
            m_SymbolTFManager.NotifySettingChanged(clicked_sym, (ENUM_TIMEFRAMES)::Period());
         //--- Refresh the form to this Symbol too - not just when it's already visible from a
         //--- previous gear-icon click. Without this, clicking a different row's Symbol left the
         //--- form showing STALE data for whichever Symbol was last opened via the gear icon, so
         //--- an immediate Save right after a Symbol click silently wrote to the wrong row.
         if(clicked_sym != "") ShowStopLostForm(clicked_sym);
        }
       else if(col == 3)
        {
         string clicked_sym = m_table_stoplostsetting.GetValue(0, row);
         if(clicked_sym != "") ShowStopLostForm(clicked_sym);
        }
       return;
      }
   // Handle m_table_trailingsetting Symbol/Trailling-icon cell click - refreshes
   // m_table_indicators_trailingsetting below to this Symbol's tracked Indicators
   // (GUIPannel_SettingWindows_TradingTrailing.mqh).
     if(id == CHARTEVENT_CUSTOM + ON_CLICK_LIST_ITEM && lparam == m_table_trailingsetting.Id())
      {
       string parts[];
       if(StringSplit(sparam, '_', parts) != 2) return;
       int col = (int)StringToInteger(parts[0]);
       int row = (int)StringToInteger(parts[1]);
       if(col == 0 || col == 3)
        {
         //--- Both Symbol and Trailling-icon clicks do the same 2 things now: chart nav + refresh
         //--- the Indicator-choice table below (Anhnt, 2026-09-07).
         string clicked_sym = m_table_trailingsetting.GetValue(0, row);
         if(clicked_sym == "") return;
         if(m_SymbolTFManager != NULL)
            m_SymbolTFManager.NotifySettingChanged(clicked_sym, (ENUM_TIMEFRAMES)::Period());
         m_label_TrailingSetting_Symbol.LabelText("Symbol - " + clicked_sym);
         m_label_TrailingSetting_Symbol.Draw();
         m_label_TrailingSetting_Symbol.Update(true);
         SyncTable_IndicatorsTrailingSetting(clicked_sym, true);
         ShowTrailingForm(clicked_sym);
        }
       return;
      }
   //Handle m_table_indicators_trailingsetting checkbox click - implementation in
   //GUIPannel_SettingWindows_TradingTrailing.mqh. Same dual ON_CLICK_BUTTON/ON_CLICK_CHECKBOX
   //check every other checkbox-cell table in this codebase uses.
     if((id == CHARTEVENT_CUSTOM + ON_CLICK_BUTTON || id == CHARTEVENT_CUSTOM + ON_CLICK_CHECKBOX)
        && lparam == m_table_indicators_trailingsetting.Id())
      {
       string parts[];
       if(StringSplit(sparam, '_', parts) != 2) return;
       int col = (int)StringToInteger(parts[0]);
       int row = (int)StringToInteger(parts[1]);
       if(col == 3) OnCheckTable_IndicatorsTrailingSetting(row);
       return;
      }
   //Handle m_btn_save_Trailing_Setting - commits Offset(Fixed+Indicator)/Start/Step for whichever
   //Symbol m_table_indicators_trailingsetting is currently scoped to (read off the same label the
   //other Trailing handlers use, no separate "current symbol" cache Property).
     if(id == CHARTEVENT_CUSTOM + ON_CLICK_BUTTON && lparam == m_btn_save_Trailing_Setting.Id())
      {
       string label_text = m_label_TrailingSetting_Symbol.LabelText();
       int    sep         = StringFind(label_text, " - ");
       string symbol      = (sep >= 0) ? StringSubstr(label_text, sep + 3) : "";
       if(symbol == "" || m_trading_setup_manager == NULL) return;
       CTradingSetupSetting *row_setting = m_trading_setup_manager.FindByIdentity(symbol);
       if(row_setting == NULL) row_setting = m_trading_setup_manager.Add_TradingSetupSetting(symbol);
       if(row_setting == NULL) return;
       row_setting.TrailingOffsetPts((int)StringToInteger(m_edit_Trailing_Offset.GetValue()));
       row_setting.TrailingStartPts((int)StringToInteger(m_edit_Trailing_Start.GetValue()));
       row_setting.TrailingStepPts((int)StringToInteger(m_edit_Trailing_Step.GetValue()));
       m_trading_setup_manager.NotifySettingChanged(symbol);
       //--- Same "Indicator dependency" reasoning as the StopLost Save handler - the Indicator this
       //--- Symbol trails by (picked via m_table_indicators_trailingsetting's checkbox) must have its
       //--- own Template + Symbol/TF tracking actually persisted too, or a restart loses the live
       //--- CIndicatorDE instance StopLost_Setting's Fixed/Ind lookups depend on.
       if(m_indicator_template_manager != NULL) m_indicator_template_manager.SaveIndicatorTemplateToJSON();
       if(m_SymbolTFManager != NULL) m_SymbolTFManager.SaveSymbolTFSettingToJSON();
       m_trading_setup_manager.SaveTradingSetupSettingToJSON();
       SyncTable_TrailingSetting(true);
       HideTrailingForm();
       return;
      }
   //Handle tab switch on m_tabs_setting_trading - hide the SL Setting form when navigating, and
   //hide the Trailing Indicator-choice table + form too (Anhnt, 2026-09-08) - neither should be
   //visible at all until the user clicks the Trailling icon on m_table_trailingsetting, same
   //"nothing shows until asked for" convention as StopLost's own gear-icon-gated form.
     if(id == CHARTEVENT_CUSTOM + ON_CLICK_TAB && lparam == m_tabs_setting_trading.Id())
      {
       HideStopLostForm();
       HideTrailingForm();
       return;
      }
  }

#endif // CGUIPANNEL_SETTINGWINDOWS_TRADING_MQH_IMPLEMENTATION
