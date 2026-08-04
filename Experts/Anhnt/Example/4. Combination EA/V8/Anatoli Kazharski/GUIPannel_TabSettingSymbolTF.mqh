//+------------------------------------------------------------------+
//|                              GUIPannel_TabSettingSymbolTF.mqh    |
//+------------------------------------------------------------------+
#ifndef CGUIPANNEL_TABSETTINGSYMBOLTF_MQH
#define CGUIPANNEL_TABSETTINGSYMBOLTF_MQH
 // =====================================================================
 // --- Symbol TF sub-tab: flat list of every Symbol+TF pair currently tracked by
 // --- m_BarTimeSeriesCollection (same source as m_treeview_SymbolTF), each row with
 // --- its own Buy/Sell checkboxes and a red delete icon. Save button writes the
 // --- current Buy/Sell state to JSON.
 bool CGUIPannel::CreateTableSymbolTFSetting(const int x, const int y)
  {
   //--- Note (own row, on top): Delete/Buy/Sell edits here only take effect in
   //--- indicators_config.json - the running EA keeps today's live series/indicators
   //--- until it's restarted. Colored to stand out from the Save button below it.
    m_label_symboltf_note.MainPointer(m_tabs_main_setting_config);
    m_tabs_main_setting_config.AddToElementsArray(TAB_TAB_MAIN_SETTINGS_CONFIG_SYMBOL_TF, m_label_symboltf_note);
   // --- CTextLabel::InitializeProperties defaults XSize to 100px when unset - too narrow for
   // --- this sentence (and CTextLabel never checks AutoXResizeMode, unlike CTable/CTreeView),
   // --- so XSize must be set explicitly, wide enough to clear the tab's own right edge.
    m_label_symboltf_note.XSize(M_TABS_MAIN_WIDTH - x - 5);
    m_label_symboltf_note.Font("Calibri Bold");   // CElement::DrawText hardcodes FW_NORMAL - request a bold face by name instead
    if(!m_label_symboltf_note.CreateTextLabel("Delete Symbol+TF here apply after the EA is restarted", x, y)) return false;
    m_label_symboltf_note.LabelColor(clrDodgerBlue);
    m_label_symboltf_note.Draw();
    CWndContainer::AddToElementsArray(WindowIdx(m_window_main), m_label_symboltf_note);
   //--- Save button, same convention as m_btn_save_indicator
    m_btn_save_SymbolTF.MainPointer(m_tabs_main_setting_config);
    m_tabs_main_setting_config.AddToElementsArray(TAB_TAB_MAIN_SETTINGS_CONFIG_SYMBOL_TF, m_btn_save_SymbolTF);
    m_btn_save_SymbolTF.AutoXResizeMode(false);
    m_btn_save_SymbolTF.XSize(80);
    m_btn_save_SymbolTF.IconFile(IMAGE_RESOURCE_BMP16_SAVE_PNG);
    if(!m_btn_save_SymbolTF.CreateButton("Save", x, y + SYMBOLTF_BTN_Y)) return false;
    CWndContainer::AddToElementsArray(WindowIdx(m_window_main), m_btn_save_SymbolTF);
   //--- Table: col 0 merges the red delete icon with the Symbol label (same CTable
   //--- click-detection trick as m_table_indicator col 0 - see Table.mqh CheckPressedButton).
    m_table_indicator_SymbolTFSeting.MainPointer(m_tabs_main_setting_config);
    m_tabs_main_setting_config.AddToElementsArray(TAB_TAB_MAIN_SETTINGS_CONFIG_SYMBOL_TF, m_table_indicator_SymbolTFSeting);
    m_table_indicator_SymbolTFSeting.AutoXResizeMode(true);
    m_table_indicator_SymbolTFSeting.AutoXResizeRightOffset(3);
    m_table_indicator_SymbolTFSeting.AutoYResizeMode(true);
    m_table_indicator_SymbolTFSeting.AutoYResizeBottomOffset(3);
    m_table_indicator_SymbolTFSeting.ShowHeaders(true);
    m_table_indicator_SymbolTFSeting.SelectableRow(true);
    m_table_indicator_SymbolTFSeting.LightsHover(true);
    m_table_indicator_SymbolTFSeting.IsSortMode(true);
    m_table_indicator_SymbolTFSeting.TableSize(4, 10);
    int widths[4]    = {150, 70, 40, 40};
    int img_x_off[4] = {3,   0,  10, 10};
    int img_y_off[4] = {3,   0,  3,  3};
    ENUM_ALIGN_MODE align[4] = {ALIGN_LEFT, ALIGN_LEFT, ALIGN_LEFT, ALIGN_LEFT};
    m_table_indicator_SymbolTFSeting.ColumnsWidth(widths);
    m_table_indicator_SymbolTFSeting.ImageXOffset(img_x_off);
    m_table_indicator_SymbolTFSeting.ImageYOffset(img_y_off);
    m_table_indicator_SymbolTFSeting.TextAlign(align);

    if(!m_table_indicator_SymbolTFSeting.CreateTable(x, y + SYMBOLTF_TABLE_Y)) return false;
    m_table_indicator_SymbolTFSeting.SetHeaderText(0, "Symbol");
    m_table_indicator_SymbolTFSeting.SetHeaderText(1, "TF");
    m_table_indicator_SymbolTFSeting.SetHeaderText(2, "Buy");   
    m_table_indicator_SymbolTFSeting.SetHeaderText(3, "Sell");
   // --- Collapse the TableSize() padding down to a single blank baseline row -
   // --- PopulateTableSymbolTFSetting() reuses that one row for its very first entry.
    m_table_indicator_SymbolTFSeting.DeleteAllRows();

    CWndContainer::AddToElementsArray(WindowIdx(m_window_main), m_table_indicator_SymbolTFSeting);
    return true;
  }
 // --- Incremental sync with m_treeview_SymbolTF's own data source (m_BarTimeSeriesCollection) -
 // --- called every time PopulateSymbolTFTree() runs (init + real symbol/TF change), same as the
 // --- treeview. Purely ADDITIVE: only appends pairs not already present as a row - never
 // --- DeleteAllRows()/rebuilds, so a user-deleted row stays deleted. Real "stop tracking" on
 // --- delete is follow-up work once the Library gets a RemoveSeries()-style API (BugNote/2026-07-15).
 void CGUIPannel::PopulateTableSymbolTFSetting(void)
  {
   if(m_BarTimeSeriesCollection == NULL) return;
   int mw_total = ::SymbolsTotal(true);
   for(int i = 0; i < mw_total; i++)
    {
     string sym_name = ::SymbolName(i, true);
     CBarTimeSeriesDE *bts = m_BarTimeSeriesCollection.GetTimeseries(sym_name);
     CArrayObj *list = (bts != NULL) ? bts.GetListSeries() : NULL;
     int tf_cnt = (list != NULL) ? list.Total() : 0;
     for(int k = 0; k < tf_cnt; k++)
      {
       CBarSeriesDE *s = bts.GetSeriesByIndex((uchar)k);
       if(s == NULL) continue;
       string tf_text = TimeframeDescription(s.Timeframe());
       if(HasTableSymbolTFSettingRow(sym_name, tf_text)) continue;
       int row = (int)m_table_indicator_SymbolTFSeting.RowsTotal();
       string first_col0 = m_table_indicator_SymbolTFSeting.GetValue(0, 0);
       StringTrimLeft(first_col0);
       bool placeholder_only = (row == 1 && first_col0 == "");
       if(placeholder_only)
         row = 0;   // reuse the blank baseline row left by DeleteAllRows()
       else
         m_table_indicator_SymbolTFSeting.AddRow(row, false);
       SetTableSymbolTFSettingRow(row, sym_name, tf_text);
      }
    }
   m_table_indicator_SymbolTFSeting.Update(true);
  }
 //Tab Symbol TF TAB_TAB_MAIN_SETTINGS_CONFIG_SYMBOL_TF at m_tabs_main_setting_config
 // --- Re-evaluates col 0's icon (delete vs start) for every row - called after a real
 // --- symbol/TF chart change, since which row counts as "current" just moved.
 void CGUIPannel::SyncTableSymbolTFSettingCurrentChartIcon(void)  
  {
   uint delete_icon[] = {IMAGE_RESOURCE_BMP16_CLOSE_RED_PNG};
   uint start_icon[]  = {IMAGE_RESOURCE_BMP16_START_BMP};
   int rows = (int)m_table_indicator_SymbolTFSeting.RowsTotal();
   for(int row = 0; row < rows; row++)
    {
     string sym = m_table_indicator_SymbolTFSeting.GetValue(0, row);
     StringTrimLeft(sym);
     if(sym == "") continue;
     string tf = m_table_indicator_SymbolTFSeting.GetValue(1, row);
     StringTrimLeft(tf);
     if(IsCurrentChartSymbolTFRow(sym, tf))
      m_table_indicator_SymbolTFSeting.SetImages(0, row, start_icon);
     else
      m_table_indicator_SymbolTFSeting.SetImages(0, row, delete_icon);
      m_table_indicator_SymbolTFSeting.ChangeImage(0, row, 0);
    }
    m_table_indicator_SymbolTFSeting.Update(true);
  }
 // --- Fill every cell of one Symbol+TF row - Buy/Sell default OFF (opt-in, same convention
 // --- as m_table_indicator's col 2/3)
 void CGUIPannel::SetTableSymbolTFSettingRow(const int row, const string sym, const string tf_text)
  {
   uint delete_icon[] = {IMAGE_RESOURCE_BMP16_CLOSE_RED_PNG};
   uint start_icon[]  = {IMAGE_RESOURCE_BMP16_START_BMP};
   uint chk[]         = {IMAGE_RESOURCE_BMP16_CHECKBOX_ON_G_PNG, IMAGE_RESOURCE_BMP16_CHECKBOX_OFF_G_PNG};
   // --- Col 0: Symbol label + icon - red Close (delete), EXCEPT the row matching the current
   // --- chart's own symbol/TF, which gets the "start" icon and is not deletable (this EA
   // --- instance depends on that series existing - see IsCurrentChartSymbolTFRow).
    bool is_current = IsCurrentChartSymbolTFRow(sym, tf_text);
    m_table_indicator_SymbolTFSeting.CellType(0, row, CELL_BUTTON);
    if(is_current)
     m_table_indicator_SymbolTFSeting.SetImages(0, row, start_icon);
    else
     m_table_indicator_SymbolTFSeting.SetImages(0, row, delete_icon);
     m_table_indicator_SymbolTFSeting.ChangeImage(0, row, 0);
     m_table_indicator_SymbolTFSeting.SetValue(0, row, "        " + sym);
     // --- Col 1: TF
      m_table_indicator_SymbolTFSeting.SetValue(1, row, "  " + tf_text);
     // --- Col 2/3: Buy / Sell
      m_table_indicator_SymbolTFSeting.CellType(2, row, CELL_CHECKBOX);
      m_table_indicator_SymbolTFSeting.SetImages(2, row, chk);
      m_table_indicator_SymbolTFSeting.ChangeImage(2, row, 1);
      m_table_indicator_SymbolTFSeting.CellType(3, row, CELL_CHECKBOX);
      m_table_indicator_SymbolTFSeting.SetImages(3, row, chk);
      m_table_indicator_SymbolTFSeting.ChangeImage(3, row, 1);
  }
 // --- True when (sym, tf_text) already has a row (trimmed match against col0/col1 text)
 bool CGUIPannel::HasTableSymbolTFSettingRow(const string sym, const string tf_text)
  {
   int rows = (int)m_table_indicator_SymbolTFSeting.RowsTotal();
   for(int row = 0; row < rows; row++)
    {
     string s = m_table_indicator_SymbolTFSeting.GetValue(0, row);
     StringTrimLeft(s);
     if(s != sym) continue;
     string t = m_table_indicator_SymbolTFSeting.GetValue(1, row);
     StringTrimLeft(t);
     if(t == tf_text) return true;
    }
   return false;
  }
 // --- Called ONCE right after the initial PopulateTableSymbolTFSetting() (see CreateGUIPannel) -
 // --- pulls the Buy/Sell state CTimeSeriesEngine::LoadConfigurationFromJSON() cached while
 // --- loading indicators_config.json and applies it to the matching rows, so a saved Buy/Sell
 // --- setting survives an EA restart instead of resetting to OFF.
 void CGUIPannel::ApplyLoadedSymbolTFSettings(void)
  {
   if(m_time_series_engine == NULL) return;
   string symbols[], tfs[];
   bool buys[], sells[];
   m_time_series_engine.GetLoadedSymbolTFSettings(symbols, tfs, buys, sells);
   int rows = (int)m_table_indicator_SymbolTFSeting.RowsTotal();
   for(int i = 0; i < ArraySize(symbols); i++)
    {
     for(int row = 0; row < rows; row++)
      {
       string sym = m_table_indicator_SymbolTFSeting.GetValue(0, row);
       StringTrimLeft(sym);
       if(sym != symbols[i]) continue;
       string tf = m_table_indicator_SymbolTFSeting.GetValue(1, row);
       StringTrimLeft(tf);
       if(tf != tfs[i]) continue;
       m_table_indicator_SymbolTFSeting.ChangeImage(2, row, buys[i]  ? 0 : 1);
       m_table_indicator_SymbolTFSeting.ChangeImage(3, row, sells[i] ? 0 : 1);
       break;
      }
    }
   m_table_indicator_SymbolTFSeting.Update(true);
  }
 // --- Buy/Sell lookup arrays for SaveGUIConfigToJSON, read off m_table_indicator_SymbolTFSeting's
 // --- current checkbox state (col 2/3).
 void CGUIPannel::BuildSymbolTFBuySellArrays(string &symbols[], string &tfs[], bool &buys[], bool &sells[])
  {
   ArrayResize(symbols, 0);
   ArrayResize(tfs, 0);
   ArrayResize(buys, 0);
   ArrayResize(sells, 0);
   int rows = (int)m_table_indicator_SymbolTFSeting.RowsTotal();
   int total = 0;
   for(int row = 0; row < rows; row++)
    {
     string sym = m_table_indicator_SymbolTFSeting.GetValue(0, row);
     StringTrimLeft(sym);
     if(sym == "") continue;
     string tf = m_table_indicator_SymbolTFSeting.GetValue(1, row);
     StringTrimLeft(tf);
     ArrayResize(symbols, total + 1);
     ArrayResize(tfs, total + 1);
     ArrayResize(buys, total + 1);
     ArrayResize(sells, total + 1);
     symbols[total] = sym;
     tfs[total]     = tf;
     buys[total]    = (m_table_indicator_SymbolTFSeting.SelectedImageIndex(2, row) == 0);
     sells[total]   = (m_table_indicator_SymbolTFSeting.SelectedImageIndex(3, row) == 0);
     total++;
    }
  }
 // --- True for the ONE row matching this chart's own symbol/TF - CTimeSeriesEngine::OnInitEvent
 // --- creates that series unconditionally and everything else (RefreshIndicatorTable,
 // --- BuildAndWriteSignalBridge...) assumes it always exists, so that row must never be deletable.
 bool CGUIPannel::IsCurrentChartSymbolTFRow(const string sym, const string tf_text)
  {
   return (sym == ::Symbol() && tf_text == TimeframeDescription((ENUM_TIMEFRAMES)::Period()));
  }
 // --- Save button click - both m_btn_save_indicator and m_btn_save_SymbolTF write the SAME
 // --- indicators_config.json (single source of truth, no separate Buy/Sell file) - see
 // --- SaveGUIConfigToJSON().
 void CGUIPannel::OnClickSaveSymbolTF(void)
  {
   SaveGUIConfigToJSON();
  }    
// --- Checkbox click stub (col 2 = Buy, col 3 = Sell) - the table already auto-toggled the
// --- icon before this event fires (see Table.mqh CheckPressedCheckBox), so no manual image
// --- flip needed here. Intentionally empty for now - no Tang 1 trading data model exists
// --- yet to apply this to (see PopulateTableSymbolTFSetting note); wire real behavior here
// --- once that's decided.
void CGUIPannel::OnCheckTableSymbolTFSetting(const string sym, const string tf_text, const int row, const int col)
 {
    
 }
#endif // CGUIPANNEL_TABSETTINGSYMBOLTF_MQH
