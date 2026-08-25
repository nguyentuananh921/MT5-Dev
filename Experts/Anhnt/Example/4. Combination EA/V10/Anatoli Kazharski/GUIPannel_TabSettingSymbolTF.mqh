//+------------------------------------------------------------------+
//|                              GUIPannel_TabSettingSymbolTF.mqh    |
//+------------------------------------------------------------------+
#ifndef CGUIPANNEL_TABSETTINGSYMBOLTF_MQH
#define CGUIPANNEL_TABSETTINGSYMBOLTF_MQH
 #include "GUIPannel.mqh"
 // =====================================================================
 // --- Symbol TF sub-tab: flat list of every Symbol+TF pair currently tracked by
 // --- m_SymbolTFManager (Single Source of Truth), each row with its own Buy/Sell
 // --- checkboxes and a red delete icon. Save button writes the current Buy/Sell
 // --- state to JSON.
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
    //Column 2 for Buy 
     uint resource_indices_buy[] = {IMAGE_RESOURCE_BMP16_BUY_PNG};   
     m_table_indicator_SymbolTFSeting.SetHeaderText(2, ""); 
     m_table_indicator_SymbolTFSeting.SetHeaderImage(2, resource_indices_buy); 
    //Column 3 for sell
     uint resource_indices_sell[] = {IMAGE_RESOURCE_BMP16_SELL_PNG}; 
     m_table_indicator_SymbolTFSeting.SetHeaderText(3, "");
     m_table_indicator_SymbolTFSeting.SetHeaderImage(3, resource_indices_sell);
   // --- Collapse the TableSize() padding down to a single blank baseline row -
   // --- RefreshTableSymbolTF() reuses that one row for its very first entry.
    m_table_indicator_SymbolTFSeting.DeleteAllRows();

    CWndContainer::AddToElementsArray(WindowIdx(m_window_main), m_table_indicator_SymbolTFSeting);
    return true;
  }
 // --- Incremental sync with m_SymbolTFManager (Single Source of Truth) - called every time
 // --- a real symbol/TF change happens, same as the treeview. Purely ADDITIVE: only appends
 // --- pairs not already present as a row - never DeleteAllRows()/rebuilds, so a user-deleted
 // --- row stays deleted (deletion has its own deferred-remove flow, DeleteRow at delete time).
 void CGUIPannel::RefreshTableSymbolTF(void)
  {
   if(m_SymbolTFManager == NULL) return;
   int total = m_SymbolTFManager.Total();
   for(int i = 0; i < total; i++)
    {
     CSymbolTFSetting *entry = m_SymbolTFManager.At(i);
     if(entry == NULL) continue;
     string sym_name = entry.Symbol();
     string tf_text  = entry.TFText();
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
   // Fix (2026-08-10): was Update(true) - forced a full-table rebuild (AutoResizeColumns/
   // ChangeMainSize/DrawTable/scrollbars) on every genuinely-new TF, on top of MT5's own
   // native chart-change redraw - that double-redraw was the m_window_main flicker. Update(false)
   // still flushes the just-added row's cells (m_canvas/m_table/m_headers.Update()) without
   // the full rebuild - see FeatureNote/FixMainWindowFlicker.md.
   m_table_indicator_SymbolTFSeting.Update(false);
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
 // --- Fill every cell of one Symbol+TF row. Buy/Sell read straight from m_SymbolTFManager
 // --- (Single Source of Truth) - matched by (sym,tf), same content-based lookup
 // --- HasTableSymbolTFSettingRow already uses (this table supports IsSortMode(true), so row
 // --- index never reliably maps to the Manager's own index). Falls back to true/true if
 // --- somehow not found yet - by the time this runs the pair should already be there.
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
      bool row_buy = true, row_sell = true;
      if(m_SymbolTFManager != NULL)
       {
        CSymbolTFSetting *entry = m_SymbolTFManager.FindByIdentity(sym, TimestampByDescription(tf_text));
        if(entry != NULL) { row_buy = entry.BuySignal(); row_sell = entry.SellSignal(); }
       }
      m_table_indicator_SymbolTFSeting.CellType(2, row, CELL_CHECKBOX);
      m_table_indicator_SymbolTFSeting.SetImages(2, row, chk);
      m_table_indicator_SymbolTFSeting.ChangeImage(2, row, row_buy ? 0 : 1);
      m_table_indicator_SymbolTFSeting.CellType(3, row, CELL_CHECKBOX);
      m_table_indicator_SymbolTFSeting.SetImages(3, row, chk);
      m_table_indicator_SymbolTFSeting.ChangeImage(3, row, row_sell ? 0 : 1);
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
 // --- True for the ONE row matching this chart's own symbol/TF - CTimeSeriesEngine::OnInitEvent
 // --- creates that series unconditionally and everything else (RefreshIndicatorTable,
 // --- BuildAndWriteSignalBridge...) assumes it always exists, so that row must never be deletable.
 bool CGUIPannel::IsCurrentChartSymbolTFRow(const string sym, const string tf_text)
  {
   return (sym == ::Symbol() && tf_text == TimeframeDescription((ENUM_TIMEFRAMES)::Period()));
  }
// --- Checkbox click (col 2 = Buy, col 3 = Sell) - the table already auto-toggled the icon
// --- before this event fires (see Table.mqh CheckPressedCheckBox), so no manual image flip
// --- needed here. Data only - writes straight into m_SymbolTFManager, matched by (sym,tf),
// --- same content-based lookup used everywhere else in this file (row index never reliably
// --- maps to the Manager's own index - IsSortMode(true)).
void CGUIPannel::OnCheckTableSymbolTFSetting(const string sym, const string tf_text, const int row, const int col)
 {
  if(m_SymbolTFManager == NULL) return;
  CSymbolTFSetting *entry = m_SymbolTFManager.FindByIdentity(sym, TimestampByDescription(tf_text));
  if(entry == NULL) return;
  if(col == 2)
     entry.BuySignal((int)m_table_indicator_SymbolTFSeting.SelectedImageIndex(2, row) == 0);
  else
     entry.SellSignal((int)m_table_indicator_SymbolTFSeting.SelectedImageIndex(3, row) == 0);
 }
  // For m_treeview_SymbolTF on the left of the Symbol TF sub-tab, m_tabs_main_setting_config -
  // same positioning pattern as CreateTreeView_Indicator (Settings window, not m_window_main).
    bool CGUIPannel::CreateTreeView_SymbolTF(const int x_gap, const int y_gap)
     {
       m_treeview_SymbolTF.MainPointer(m_tabs_main_setting_config);
       m_treeview_SymbolTF.AutoXResizeMode(false);  // fixed width
       m_treeview_SymbolTF.XSize(M_TREEVIEW_SYMBOLTF_WIDTH);
       m_treeview_SymbolTF.AutoYResizeMode(true);
       m_treeview_SymbolTF.VisibleItemsTotal(15);
       m_treeview_SymbolTF.LightsHover(true);
       m_treeview_SymbolTF.AutoYResizeBottomOffset(25);
       if(!m_treeview_SymbolTF.CreateTreeView(x_gap, y_gap)) return false;
       m_tabs_main_setting_config.AddToElementsArray(TAB_TAB_MAIN_SETTINGS_CONFIG_SYMBOL_TF, m_treeview_SymbolTF);
       CWndContainer::AddToElementsArray(WindowIdx(m_window_setting), m_treeview_SymbolTF);
       return true;
     }
    // --- Symbol-level (parent) nodes come from Market Watch, same as V9's original design -
    // --- a full picker of every tradeable symbol, not just ones already tracked. Only the
    // --- TF-level (child) nodes come from m_SymbolTFManager (Single Source of Truth) - same
    // --- principle CIndicatorTemplateManager established, just scoped to the child level only
    // --- (there is no such thing as "every possible TF pre-listed" the way Indicator's tree
    // --- pre-lists its whole catalog; a symbol's TF children only exist once tracked).
    void CGUIPannel::PopulateSymbolTFTree(void)
     {
      if(m_SymbolTFManager == NULL) return;
      int mw_total = ::SymbolsTotal(true);
        // --- SymbolName(i,true)'s own index order is Market Watch's internal/insertion order,
        // --- NOT the alphabetically-sorted order the Market Watch grid displays (Anhnt,
        // --- 2026-07-19) - a brand new symbol node only ever gets APPENDED (AddTreeItem always
        // --- uses ItemsTotal() as the new list_index, there's no "insert at position"), so the
        // --- only way to make first-time node creation come out sorted is to visit symbols in
        // --- sorted order here. Symbol nodes are found by scanning the tree's OWN items for a
        // --- LabelText match (Step 1 below) instead of a raw-index shadow array (2026-08-10).
        int order[];
        ArrayResize(order, mw_total);
        for(int i = 0; i < mw_total; i++) order[i] = i;
        for(int a = 0; a < mw_total - 1; a++)
           for(int b = a + 1; b < mw_total; b++)
              if(::SymbolName(order[b], true) < ::SymbolName(order[a], true))
                { int tmp = order[a]; order[a] = order[b]; order[b] = tmp; }
        // --- FormTreeList() silently drops any item whose item_index is not monotonically
        // --- increasing within its node_level, in the order items were created/appended
        // --- (Anhnt, 2026-07-19) - since we visit symbols in ALPHABETICAL order, raw index is
        // --- NOT monotonic across creation order any more. sym_item_seq tracks "how many sym
        // --- nodes exist so far" and is used as item_index instead, so it always increases by
        // --- exactly 1 per new node, regardless of which symbol that node happens to be.
         int sym_item_seq = 0;
         int sym_total0 = m_treeview_SymbolTF.ItemsTotal();
         for(int j = 0; j < sym_total0; j++)
           if(m_treeview_SymbolTF.ItemPrevNode(j) == -1) sym_item_seq++;
         int total = m_SymbolTFManager.Total();
         for(int oi = 0; oi < mw_total; oi++)
          {
            string sym_name = ::SymbolName(order[oi], true);
            // Step 1: Ensure sym node exists - matched by LABEL against existing top-level tree
            // items (ItemPrevNode == -1), not a raw index.
             int sym_li = -1;
             int sym_scan_total = m_treeview_SymbolTF.ItemsTotal();
             for(int j = 0; j < sym_scan_total; j++)
              {
               if(m_treeview_SymbolTF.ItemPrevNode(j) != -1) continue;
               CTreeItem *tj = m_treeview_SymbolTF.ItemPointer(j);
               if(tj != NULL && tj.LabelText() == sym_name) { sym_li = j; break; }
              }
             if(sym_li == -1)
              {
               sym_li = m_treeview_SymbolTF.ItemsTotal();
               // AddTreeItem() auto-increments parent count + sets state when TF children are added
                m_treeview_SymbolTF.AddTreeItem(sym_li,
                                            -1, //prev_node_list_index
                                            sym_name,
                                            IMAGE_RESOURCE_BMP16_ARROWRIGHT_BMP,
                                            sym_item_seq,
                                            0, //node_level symnode = 0 Node level must be >=0
                                            0,
                                            0, 0,
                                            false,    //item_state, m_t_item_state[]=true
                                            false      //is_folder m_t_is_folder[]=false
                                            );
               sym_item_seq++;
              }
            // Step 2: This symbol's TF entries from the Manager, sorted by TF rank
            // (IndexEnumTimeframe) so slot k below (positionally matched against existing
            // children[k]) ends up ascending M1..MN1, same reasoning as the symbol-level sort.
             int tf_indexes[];
             for(int i = 0; i < total; i++)
              {
               CSymbolTFSetting *entry = m_SymbolTFManager.At(i);
               if(entry != NULL && entry.Symbol() == sym_name)
                {
                 int sz = ArraySize(tf_indexes);
                 ArrayResize(tf_indexes, sz + 1);
                 tf_indexes[sz] = i;
                }
              }
             int tf_cnt = ArraySize(tf_indexes);
             if(tf_cnt == 0) continue;   //No TF found on sym_li
             for(int a = 0; a < tf_cnt - 1; a++)
                for(int b = a + 1; b < tf_cnt; b++)
                  {
                   CSymbolTFSetting *ea = m_SymbolTFManager.At(tf_indexes[a]);
                   CSymbolTFSetting *eb = m_SymbolTFManager.At(tf_indexes[b]);
                   if(ea == NULL || eb == NULL) continue;
                   if(IndexEnumTimeframe(eb.TFEnum()) < IndexEnumTimeframe(ea.TFEnum()))
                     { int tmp = tf_indexes[a]; tf_indexes[a] = tf_indexes[b]; tf_indexes[b] = tmp; }
                  }
            // Step 3: Collect existing TF children of sym_li node
             int children[];
             ArrayResize(children, 0);
             int total_now = m_treeview_SymbolTF.ItemsTotal();
             for(int j = 0; j < total_now; j++)
              if(m_treeview_SymbolTF.ItemPrevNode(j) == sym_li)
               {
                 int sz = ArraySize(children);
                 ArrayResize(children, sz + 1);
                 children[sz] = j;
               }
             int child_count = ArraySize(children);
            // Step 4: Match tf_indexes[k] against children[k]
             for(int k = 0; k < tf_cnt; k++)
              {
               CSymbolTFSetting *entry = m_SymbolTFManager.At(tf_indexes[k]);
               if(entry == NULL) continue;
               string actual = entry.TFText();
               if(k < child_count)
                {
                 // Slot exists — update label if period changed
                 CTreeItem *ti = m_treeview_SymbolTF.ItemPointer(children[k]);
                 if(ti != NULL && ti.LabelText() != actual)
                 { ti.LabelText(actual); ti.Update(true); }
                }
               else
                {
                 // New slot — add TF node
                  m_treeview_SymbolTF.AddTreeItem(m_treeview_SymbolTF.ItemsTotal(), sym_li,
                                            actual,
                                            IMAGE_RESOURCE_BMP16_BAR_CHART_COLORLESS_BMP,
                                            k, 1, oi, 0, 0,
                                            true,   //item_state, m_t_item_state[]=true;
                                            false   //is_folder m_t_is_folder[]=false
                                         );
                 //Register new CTreeItem
                  CTreeItem *new_item = m_treeview_SymbolTF.ItemPointer(m_treeview_SymbolTF.ItemsTotal() - 1);
                  if(new_item != NULL)
                    CWndContainer::AddToElementsArray(WindowIdx(m_window_setting), *new_item);
               }
              }
          }
     }
    // Synchronize icons of m_treeview_SymbolTF with the active symbol and timeframe
    void CGUIPannel::SynSymbolTFTreeViewIcons(void)
     {
       string chart_tf = TimeframeDescription(_Period);
       int    total    = m_treeview_SymbolTF.ItemsTotal();  // duyệt tất cả items
       for(int i = 0; i < total; i++)
         {
           CTreeItem *item = m_treeview_SymbolTF.ItemPointer(i);
           if(item == NULL) continue;
           int parent_pos = m_treeview_SymbolTF.ItemPrevNode(i);
           if(parent_pos == -1)  // sym node
            {
             bool active = (item.LabelText() == _Symbol);
             if(item.ItemType() == TI_HAS_ITEMS)
              {
                item.IsActive(active);
                item.Draw();
                item.CanvasPointer().Update(false);
              }
             else
              item.IconFile(active ? IMAGE_RESOURCE_BMP16_ARROWRIGHT_BLUE_BMP
                                   : IMAGE_RESOURCE_BMP16_ARROWRIGHT_BMP);
            }
           else  // TF node
            {
              CTreeItem *parent_item = m_treeview_SymbolTF.ItemPointer(parent_pos);
              bool parent_is_active  = (parent_item != NULL && parent_item.LabelText() == _Symbol);
              bool highlight = (parent_is_active && item.LabelText() == chart_tf);
              item.IconFile(highlight ? IMAGE_RESOURCE_BMP16_BAR_CHART_BMP
                                      : IMAGE_RESOURCE_BMP16_BAR_CHART_COLORLESS_BMP);
            }
         }
       m_treeview_SymbolTF.RedrawTreeList(); 
       m_treeview_SymbolTF.UpdateTreeList(true);
     } 
   
#endif // CGUIPANNEL_TABSETTINGSYMBOLTF_MQH
