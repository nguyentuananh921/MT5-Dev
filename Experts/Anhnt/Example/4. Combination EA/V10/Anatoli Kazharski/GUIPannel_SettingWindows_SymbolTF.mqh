//+------------------------------------------------------------------+
//|                            GUIPannel_SettingWindows_SymbolTF.mqh |
//+------------------------------------------------------------------+
#ifndef CGUIPANNEL_SETTINGWINDOWS_SYMBOLTF_MQH
#define CGUIPANNEL_SETTINGWINDOWS_SYMBOLTF_MQH
#include "GUIPannel.mqh"
 bool CGUIPannel::CreateTable_SymbolTFSetting(const int x, const int y)
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
    CWndContainer::AddToElementsArray(WindowIdx(m_window_setting), m_label_symboltf_note);
   //--- Save button, same convention as m_btn_save_indicator
    m_btn_save_SymbolTF.MainPointer(m_tabs_main_setting_config);
    m_tabs_main_setting_config.AddToElementsArray(TAB_TAB_MAIN_SETTINGS_CONFIG_SYMBOL_TF, m_btn_save_SymbolTF);
    m_btn_save_SymbolTF.AutoXResizeMode(false);
    m_btn_save_SymbolTF.XSize(80);
    m_btn_save_SymbolTF.IconFile(IMAGE_RESOURCE_BMP16_SAVE_PNG);
    if(!m_btn_save_SymbolTF.CreateButton("Save", x, y + SYMBOLTF_BTN_Y)) return false;
    CWndContainer::AddToElementsArray(WindowIdx(m_window_setting), m_btn_save_SymbolTF);
   //--- Table: col 0 merges the red delete icon with the Symbol label (same CTable
   //--- click-detection trick as m_table_indicator col 0 - see Table.mqh CheckPressedButton).
    m_table_SymbolTFSeting.MainPointer(m_tabs_main_setting_config);
    m_tabs_main_setting_config.AddToElementsArray(TAB_TAB_MAIN_SETTINGS_CONFIG_SYMBOL_TF, m_table_SymbolTFSeting);
    m_table_SymbolTFSeting.AutoXResizeMode(true);
    m_table_SymbolTFSeting.AutoXResizeRightOffset(3);
    m_table_SymbolTFSeting.AutoYResizeMode(true);
    m_table_SymbolTFSeting.AutoYResizeBottomOffset(3);
    m_table_SymbolTFSeting.ShowHeaders(true);
    m_table_SymbolTFSeting.SelectableRow(true);
    m_table_SymbolTFSeting.LightsHover(true);
    m_table_SymbolTFSeting.IsSortMode(true);
    // --- 6 columns (Symbol/TF/Buy/Sell/Sound/Message) - no hidden index column here (unlike
    // --- m_table_indicator_template's col 7): every click handler on this table already reads
    // --- (sym,tf) fresh off the row's own col0/col1 content at the time it acts, never a cached
    // --- row position, so it's already immune to sort-driven reordering without needing a
    // --- Manager-index cell to recover.
    m_table_SymbolTFSeting.TableSize(6, 10);
    int widths[6]    = {150, 70, 40, 40, 40, 40};
    int img_x_off[6] = {3,   0,  10, 10, 10, 10};
    int img_y_off[6] = {3,   0,  3,  3,  3,  3};
    ENUM_ALIGN_MODE align[6] = {ALIGN_LEFT, ALIGN_LEFT, ALIGN_LEFT, ALIGN_LEFT, ALIGN_LEFT, ALIGN_LEFT};
    m_table_SymbolTFSeting.ColumnsWidth(widths);
    m_table_SymbolTFSeting.ImageXOffset(img_x_off);
    m_table_SymbolTFSeting.ImageYOffset(img_y_off);
    m_table_SymbolTFSeting.TextAlign(align);

    if(!m_table_SymbolTFSeting.CreateTable(x, y + SYMBOLTF_TABLE_Y)) return false;
    m_table_SymbolTFSeting.SetHeaderText(0, "Symbol");
    m_table_SymbolTFSeting.SetHeaderText(1, "TF");
    //Column 2 for Buy
     uint resource_indices_buy[] = {IMAGE_RESOURCE_BMP16_BUY_PNG};
     m_table_SymbolTFSeting.SetHeaderText(2, "");
     m_table_SymbolTFSeting.SetHeaderImage(2, resource_indices_buy);
    //Column 3 for sell
     uint resource_indices_sell[] = {IMAGE_RESOURCE_BMP16_SELL_PNG};
     m_table_SymbolTFSeting.SetHeaderText(3, "");
     m_table_SymbolTFSeting.SetHeaderImage(3, resource_indices_sell);
    //Column 4 for sound alert - future SignalBridge wiring, see CSymbolTFSetting::SoundAlert()
     uint resource_indices_sound[] = {IMAGE_RESOURCE_BMP16_BELL_PNG};
     m_table_SymbolTFSeting.SetHeaderText(4, "");
     m_table_SymbolTFSeting.SetHeaderImage(4, resource_indices_sound);
    //Column 5 for message alert - future SignalBridge wiring, see CSymbolTFSetting::MessageAlert()
     uint resource_indices_message[] = {IMAGE_RESOURCE_BMP16_MESSAGE_PNG};
     m_table_SymbolTFSeting.SetHeaderText(5, "");
     m_table_SymbolTFSeting.SetHeaderImage(5, resource_indices_message);
   // --- Collapse the TableSize() padding down to a single blank baseline row -
   // --- PopulateTable_SymbolTFSetting() reuses that one row for its very first entry.
    m_table_SymbolTFSeting.DeleteAllRows();

    CWndContainer::AddToElementsArray(WindowIdx(m_window_setting), m_table_SymbolTFSeting);
    return true;
  }
 // --- Data-only pass: ensure every Manager entry has a row (grow + write identity into
 // --- col0/col1). No painting here - SyncTable_SymbolTFSetting (run right after, same as
 // --- PopulateTreeView/SyncTreeView's split) paints the actual icon/checkboxes.
 void CGUIPannel::PopulateTable_SymbolTFSetting(void)
  {
   if(m_SymbolTFManager == NULL) return;
   int total = m_SymbolTFManager.Total();
   for(int i = 0; i < total; i++)
    {
     CSymbolTFSetting *entry = m_SymbolTFManager.At(i);
     if(entry == NULL) continue;
     string sym_name = entry.Symbol();
     string tf_text  = entry.TFText();
     int existing_row = FindTableRowBySymbolTF(sym_name, tf_text);
     Print("MY DEBUG CGUIPannel::PopulateTable_SymbolTFSetting: sym=", sym_name, " tf=", tf_text,
           " existing_row=", existing_row, " RowsTotal=", m_table_SymbolTFSeting.RowsTotal(),
           " ManagerTotal=", total);
     if(existing_row != -1) continue;   // already has a row
     int row = (int)m_table_SymbolTFSeting.RowsTotal();
     string first_col0 = m_table_SymbolTFSeting.GetValue(0, 0);
     StringTrimLeft(first_col0);
     bool placeholder_only = (row == 1 && first_col0 == "");
     if(placeholder_only)
       row = 0;   // reuse the blank baseline row left by DeleteAllRows()
     else
       m_table_SymbolTFSeting.AddRow(row, false);
     // AddRow(row,false) only grows the row arrays - CTable::AddRow only calls
     // RecalculateAndResizeTable() (the thing that actually resizes the canvas and draws the
     // row) when redraw=true, so this Update(true) is what makes a genuinely-new row visible.
     m_table_SymbolTFSeting.SetValue(0, row, "        " + sym_name);
     m_table_SymbolTFSeting.SetValue(1, row, "  " + tf_text);
     m_table_SymbolTFSeting.Update(true);
    }
  }
 // --- Full rescan, recomputing every cell for every row fresh - same self-healing philosophy
 // --- as SyncTreeView_SymbolTFSetting(): the old "only touch the 2 known rows (via native
 // --- event's sparam/dparam)" approach depended entirely on that native
 // --- CHART_OBJ_EVENT_CHART_..._CHANGE firing correctly, which it silently doesn't for any
 // --- chart switch WE ourselves trigger (SetActiveChartSymbolTF -> CreateCollection() resets
 // --- the diff baseline on the resulting reinit, un-guarded Library gap) - leaving stale
 // --- "current" icons stuck on rows that were actually left behind (Anhnt, 2026-08-26).
 void CGUIPannel::SyncTable_SymbolTFSetting(void)
  {
   if(m_SymbolTFManager == NULL) return;
   uint delete_icon[] = {IMAGE_RESOURCE_BMP16_CLOSE_RED_PNG};
   uint start_icon[]  = {IMAGE_RESOURCE_BMP16_START_BMP};
   uint chk[]         = {IMAGE_RESOURCE_BMP16_CHECKBOX_ON_G_PNG, IMAGE_RESOURCE_BMP16_CHECKBOX_OFF_G_PNG};
   int total = m_SymbolTFManager.Total();
   for(int i = 0; i < total; i++)
    {
     CSymbolTFSetting *entry = m_SymbolTFManager.At(i);
     if(entry == NULL) continue;
     string sym = entry.Symbol();
     string tf_text = entry.TFText();
     int row = FindTableRowBySymbolTF(sym, tf_text);
     if(row == -1) continue;
     // --- Col 0: Symbol label + icon - red Close (delete), EXCEPT the row matching the current
     // --- chart's own symbol/TF, which gets the "start" icon and is not deletable (this EA
     // --- instance depends on that series existing - see IsCurrentChartSymbolTFRow).
      bool is_current = IsCurrentChartSymbolTFRow(sym, tf_text);
      m_table_SymbolTFSeting.CellType(0, row, CELL_BUTTON);
      if(is_current)
       m_table_SymbolTFSeting.SetImages(0, row, start_icon);
      else
       m_table_SymbolTFSeting.SetImages(0, row, delete_icon);
      // --- ChangeImage(0,row,0) here would be a no-op: SetImages() above always resets
      // --- m_selected_image to 0 itself, so ChangeImage's own early-return
      // --- (image_index==m_selected_image, Table.mqh:1536) would fire every time - RedrawCell()
      // --- would never run, so the icon would never actually repaint despite the data being
      // --- correct. SetValue's own redraw=true has no such trap - use it to force the repaint.
       m_table_SymbolTFSeting.SetValue(0, row, "        " + sym, 0, true);
       // --- Col 1: TF
        m_table_SymbolTFSeting.SetValue(1, row, "  " + tf_text);
       // --- Col 2/3: Buy / Sell - same ChangeImage-is-a-no-op trap as col0 above (SetImages
       // --- just reset m_selected_image to 0, so ChangeImage(...,0,...) never redraws) - a row
       // --- painted for the very first time here (freshly added by PopulateTable_SymbolTFSetting,
       // --- which only resizes/repaints col0/col1) stayed blank in col2/3 until SOME other event
       // --- happened to touch that row later. Force it the same way col0 does.
        m_table_SymbolTFSeting.CellType(2, row, CELL_CHECKBOX);
        m_table_SymbolTFSeting.SetImages(2, row, chk);
        m_table_SymbolTFSeting.ChangeImage(2, row, entry.BuySignal() ? CHECKBOX_STATE_ON : CHECKBOX_STATE_OFF);
        m_table_SymbolTFSeting.SetValue(2, row, "", 0, true);
        m_table_SymbolTFSeting.CellType(3, row, CELL_CHECKBOX);
        m_table_SymbolTFSeting.SetImages(3, row, chk);
        m_table_SymbolTFSeting.ChangeImage(3, row, entry.SellSignal() ? CHECKBOX_STATE_ON : CHECKBOX_STATE_OFF);
        m_table_SymbolTFSeting.SetValue(3, row, "", 0, true);
       // --- Col 4/5: Sound / Message - same pattern as col 2/3.
        m_table_SymbolTFSeting.CellType(4, row, CELL_CHECKBOX);
        m_table_SymbolTFSeting.SetImages(4, row, chk);
        m_table_SymbolTFSeting.ChangeImage(4, row, entry.SoundAlert() ? CHECKBOX_STATE_ON : CHECKBOX_STATE_OFF);
        m_table_SymbolTFSeting.SetValue(4, row, "", 0, true);
        m_table_SymbolTFSeting.CellType(5, row, CELL_CHECKBOX);
        m_table_SymbolTFSeting.SetImages(5, row, chk);
        m_table_SymbolTFSeting.ChangeImage(5, row, entry.MessageAlert() ? CHECKBOX_STATE_ON : CHECKBOX_STATE_OFF);
        m_table_SymbolTFSeting.SetValue(5, row, "", 0, true);
    }
   m_table_SymbolTFSeting.Update(false);
  }
 void CGUIPannel::DeleteRow_SymbolTFSetting(const string sym, const string tf_text)
  {
   // GUI only - Data mutation already happened in m_SymbolTFManager before this fired (see
   // SYMBOLTF_MANAGER_EVENT_DELETE listener, GUIPannel_Lifecycle.mqh).
   int row = FindTableRowBySymbolTF(sym, tf_text);
   if(row == -1) return;
   m_table_SymbolTFSeting.DeleteRow(row, true);
  }
 // --- Row index currently holding (sym, tf_text), -1 if none - the one place every by-content
 // --- lookup in this file goes through (trimmed match against col0/col1 text).
 int CGUIPannel::FindTableRowBySymbolTF(const string &sym, const string &tf_text)
  {
   int rows = (int)m_table_SymbolTFSeting.RowsTotal();
   for(int row = 0; row < rows; row++)
    {
     string s = m_table_SymbolTFSeting.GetValue(0, row);
     StringTrimLeft(s);
     if(s != sym) continue;
     string t = m_table_SymbolTFSeting.GetValue(1, row);
     StringTrimLeft(t);
     if(t == tf_text) return row;
    }
   return -1;
  }
 bool CGUIPannel::IsCurrentChartSymbolTFRow(const string sym, const string tf_text)
  {
   return (sym == ::Symbol() && tf_text == TimeframeDescription((ENUM_TIMEFRAMES)::Period()));
  }
 void CGUIPannel::OnCheckTableSymbolTFSetting(const string sym, const string tf_text, const int row, const int col)
  {
   if(m_SymbolTFManager == NULL) return;
   CSymbolTFSetting *entry = m_SymbolTFManager.FindByIdentity(sym, TimestampByDescription(tf_text));
   if(entry == NULL) return;
   if(col == 2)
     entry.BuySignal((int)m_table_SymbolTFSeting.SelectedImageIndex(2, row) == CHECKBOX_STATE_ON);
   else if(col == 3)
     entry.SellSignal((int)m_table_SymbolTFSeting.SelectedImageIndex(3, row) == CHECKBOX_STATE_ON);
   else if(col == 4)
     entry.SoundAlert((int)m_table_SymbolTFSeting.SelectedImageIndex(4, row) == CHECKBOX_STATE_ON);
   else if(col == 5)
     entry.MessageAlert((int)m_table_SymbolTFSeting.SelectedImageIndex(5, row) == CHECKBOX_STATE_ON);
  }
 // For m_treeview_SymbolTF on the left of the Symbol TF sub-tab, m_tabs_main_setting_config -
 // same positioning pattern as CreateTreeView_IndicatorTemplateSetting (Settings window, not m_window_main).
 bool CGUIPannel::CreateTreeView_SymbolTFSetting(const int x_gap, const int y_gap)
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
 void CGUIPannel::PopulateTreeView_SymbolTFSetting(void)
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
      // Step 1b: this symbol's own item_index (its creation-rank among sym nodes) - needed
      // below for children to correctly reference their parent. NOT `oi` (Market Watch loop
      // index over ALL symbols, unrelated) - the Library exposes no getter for a node's own
      // stored item_index, so recompute it by counting sym nodes with a smaller li (= creation
      // order, since AddTreeItem always appends at ItemsTotal()). Passing `oi` here was the
      // actual bug: FormTreeList()'s parent-match check (m_t_prev_node_item_index[child] ==
      // m_t_item_index[parent]) failed for dynamically-added children, so they rendered but
      // silently dropped out of click detection (Anhnt, 2026-08-26).
      int sym_own_item_index = 0;
      for(int j = 0; j < sym_li; j++)
        if(m_treeview_SymbolTF.ItemPrevNode(j) == -1) sym_own_item_index++;
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
      if(tf_cnt != child_count)
       {
        string tf_dump = "", ch_dump = "";
        for(int p = 0; p < tf_cnt; p++)
         {
          CSymbolTFSetting *pe = m_SymbolTFManager.At(tf_indexes[p]);
          tf_dump += (pe != NULL ? pe.TFText() : "NULL") + " ";
         }
        for(int p = 0; p < child_count; p++)
         {
          CTreeItem *pt = m_treeview_SymbolTF.ItemPointer(children[p]);
          ch_dump += (pt != NULL ? pt.LabelText() : "NULL") + "(li=" + IntegerToString(children[p]) + ") ";
         }
        Print("MY DEBUG CGUIPannel::PopulateTreeView_SymbolTFSetting: sym=", sym_name,
              " sym_li=", sym_li, " tf_cnt=", tf_cnt, " tf_indexes=[", tf_dump,
              "] child_count=", child_count, " children=[", ch_dump, "]");
       }
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
          Print("MY DEBUG CGUIPannel::PopulateTreeView_SymbolTFSetting: sym=", sym_name, " k=", k,
                " matching existing child li=", children[k],
                " current_label=", (ti != NULL ? ti.LabelText() : "NULL"), " target=", actual);
          if(ti != NULL && ti.LabelText() != actual)
            { ti.LabelText(actual); ti.Update(true); }
         }
        else
         {
          // New slot — add TF node
          Print("MY DEBUG CGUIPannel::PopulateTreeView_SymbolTFSetting: sym=", sym_name, " k=", k,
                " creating NEW child, li=", m_treeview_SymbolTF.ItemsTotal(),
                " sym_li=", sym_li, " label=", actual, " item_index=", k);
           m_treeview_SymbolTF.AddTreeItem(m_treeview_SymbolTF.ItemsTotal(), sym_li,
                                            actual,
                                            IMAGE_RESOURCE_BMP16_BAR_CHART_COLORLESS_BMP,
                                            k, 1, sym_own_item_index, 0, 0,
                                            true,   //item_state, m_t_item_state[]=true;
                                            false   //is_folder m_t_is_folder[]=false
                                         );
          // Register new CTreeItem - REQUIRED for items added dynamically (tree already live,
          // m_chart_id != 0) - unlike Indicator's tree (all items created once, in bulk, before
          // CreateTreeView() ever runs), a SymbolTF node created reactively like this one needs
          // this registration to actually receive click events. V9's PopulateSymbolTFTree() (its
          // proven-working equivalent) keeps this exact call - V10 had dropped it believing it
          // redundant (matched no other sub-item registration pattern in the codebase), which
          // was correct for every OTHER case but wrong for this one (Anhnt, 2026-08-26).
           CTreeItem *new_item = m_treeview_SymbolTF.ItemPointer(m_treeview_SymbolTF.ItemsTotal() - 1);
           if(new_item != NULL)
             CWndContainer::AddToElementsArray(WindowIdx(m_window_setting), *new_item);
         }
       }      
     } 
       
  }
 void CGUIPannel::SyncTreeView_SymbolTFSetting(void)
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
       Print("MY DEBUG CGUIPannel::SyncTreeView_SymbolTFSetting: i=", i, " parent_pos=", parent_pos,
             " parent_label=", (parent_item != NULL ? parent_item.LabelText() : "NULL"),
             " _Symbol=", _Symbol, " item_label=", item.LabelText(), " chart_tf=", chart_tf,
             " parent_is_active=", parent_is_active, " highlight=", highlight);
       item.IconFile(highlight ? IMAGE_RESOURCE_BMP16_BAR_CHART_BMP
                                      : IMAGE_RESOURCE_BMP16_BAR_CHART_COLORLESS_BMP);
      }
    }
   m_treeview_SymbolTF.RedrawTreeList();
   m_treeview_SymbolTF.UpdateTreeList(true);
  }
#endif // CGUIPANNEL_SETTINGWINDOWS_SYMBOLTF_MQH
