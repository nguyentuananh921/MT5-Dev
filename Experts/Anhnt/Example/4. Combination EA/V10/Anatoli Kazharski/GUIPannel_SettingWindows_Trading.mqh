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
   //Handle m_buttonsGroup_SLMode - CButtonsGroup fires its own ON_CLICK_GROUP_BUTTON (not
   //ON_CLICK_BUTTON) with dparam already carrying the newly-selected button index
   //(ButtonsGroup.mqh CButtonsGroup::OnClickButton) - toggle which field set is visible.
     if(id == CHARTEVENT_CUSTOM + ON_CLICK_GROUP_BUTTON && lparam == m_buttonsGroup_SLMode.Id())
      {
       ToggleStopLostModeState();
       UpdateStopLostPreview();
       ::ChartRedraw();   // same "Hide()/Show() doesn't blit on its own" issue as ShowStopLostForm()
       return;
      }
   //Handle m_btn_save_StopLost_Setting - commit the form's fields into the per-Symbol cache
   //for m_string_StopLost_setting_current_symbol, then reflect the result in the table's SL
   //Value column for that row (Anhnt, 2026-09-01).
     if(id == CHARTEVENT_CUSTOM + ON_CLICK_BUTTON && lparam == m_btn_save_StopLost_Setting.Id())
      {
       string symbol = m_string_StopLost_setting_current_symbol;
       if(m_trading_setup_manager == NULL) return;
       CTradingSetupSetting *row_setting = m_trading_setup_manager.FindByIdentity(symbol);
       if(row_setting == NULL) row_setting = m_trading_setup_manager.Add_TradingSetupSetting(symbol);
       if(row_setting == NULL) return;
       ENUM_STOPLOST_TRAILING_MODE mode = (ENUM_STOPLOST_TRAILING_MODE)m_buttonsGroup_SLMode.SelectedButtonIndex();
       row_setting.StopLostActive(true);
       row_setting.StopLostMode(mode);
       if(mode == SL_MODE_FIXED)
        {
        //--- Fixed distance, measured from Mid (col1), must clear TWO stacked gaps (Anhnt,
        //--- 2026-09-02): the position itself already fills at Bid/Ask, i.e. Spread()/2 away
        //--- from Mid - then TradeStopLevel() is the broker's own minimum measured FROM that
        //--- fill price, not from Mid. So the floor from Mid is the SUM of both, not whichever is
        //--- larger: min = Spread()/2 + TradeStopLevel().
         int typed_pts = (int)StringToInteger(m_edit_StopLost_FixedPoint.GetValue());
         CSymbol *sym = m_symbol_collection.GetSymbolObjByName(symbol);
         int min_pts = (sym != NULL) ? (sym.Spread() / 2 + sym.TradeStopLevel()) : 0;
         row_setting.StopLostFixedPts(::MathMax(typed_pts, min_pts));
        }
       else
          row_setting.StopLostIndMultiplier(StringToDouble(m_edit_ATR_Multiplexer.GetValue()));
      //--- (tf, period) parsed straight off the combobox's own currently selected text ("ATR(14)
      //--- M1") - local only (Anhnt, 2026-09-03), same as UpdateStopLostPreview() - guarded because
      //--- Fixed-only Symbols (no ATR at all) leave the combobox with no items/no "(" to find.
       string sel_text = m_combobox_ATR_choice.GetValue();
       int    lp        = StringFind(sel_text, "(");
       int    rp        = StringFind(sel_text, ")");
       if(lp >= 0 && rp > lp)
        {
         int period = (int)StringToInteger(StringSubstr(sel_text, lp + 1, rp - lp - 1));
         row_setting.StopLostIndTF(TimestampByDescription(StringSubstr(sel_text, rp + 2)));
         row_setting.StopLostIndType(IND_ATR);
         MqlParam sl_ind_p[1];
         sl_ind_p[0].type          = TYPE_INT;
         sl_ind_p[0].integer_value = period;
         row_setting.SetStopLostIndParams(sl_ind_p);
        }
       m_trading_setup_manager.NotifySettingChanged(symbol);
       SyncTable_StopLostSetting(true);
       return;
      }
   // Handle m_table_stoplostsetting Symbol cell click - switch THIS chart's own Symbol
   // (keep the current TF), reusing the EXACT SAME event chain the SymbolTF TreeView navigation
   // above already uses (Anhnt, 2026-08-31): NotifySettingChanged() fires
   // SYMBOLTF_MANAGER_EVENT_SETTING_CHANGED, which the EA already listens for and reacts to via
   // SetActiveChartSymbolTF() - CGUIPannel never touches the Chart directly, per the established
   // split, so no new event/EA-side code needed here. ON_CLICK_LIST_ITEM (not ON_CLICK_BUTTON) is
   // CTable's own event for a plain SelectableRow click - see Table.mqh::OnClickTable().
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
        }
       // --- SL gear icon (Anhnt, 2026-09-01) - shows the SL Setting form scoped to this row's
       // --- own Symbol, same identity source (col0 text) as the col==0 branch above.
       else if(col == 3)
        {
         string clicked_sym = m_table_stoplostsetting.GetValue(0, row);
         if(clicked_sym != "") ShowStopLostForm(clicked_sym);
        }
       return;
      }
   //Handle tab switch on m_tabs_setting_trading - hide the SL Setting form when navigating
   //away from the StopLost sub-tab.
     if(id == CHARTEVENT_CUSTOM + ON_CLICK_TAB && lparam == m_tabs_setting_trading.Id())
      {
       HideStopLostForm();
       return;
      }
  }

#endif // CGUIPANNEL_SETTINGWINDOWS_TRADING_MQH_IMPLEMENTATION
