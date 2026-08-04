//+------------------------------------------------------------------+
//|                                        GUIPannel_MainWindows.mqh |
//+------------------------------------------------------------------+
#ifndef CGUIPANNEL_MAINWINDOWS_MQH
#define CGUIPANNEL_MAINWINDOWS_MQH
 //+------------------------------------------------------------------+
 //| Create Main Window                                               |
 //+------------------------------------------------------------------+
 bool CGUIPannel::CreateMainWindow(const string caption_text)
  {
    //--- Add a window pointer to the window array
      CWndContainer::AddWindow(m_window_main);
    //--- Properties
      m_window_main.XSize(M_WINDOW_MAIN_WIDTH);
      m_window_main.YSize(M_WINDOW_MAIN_HEIGHT);
      m_window_main.FontSize(9);
      m_window_main.IsMovable(true);
      m_window_main.ResizeMode(true);
      m_window_main.CloseButtonIsUsed(true);
      m_window_main.CollapseButtonIsUsed(true);
      m_window_main.TooltipsButtonIsUsed(true);
      m_window_main.FullscreenButtonIsUsed(true);
      // Allow shrinking horizontally down to 300px and vertically down to 200px
      m_window_main.MinimumXSize(M_WINDOW_MAIN_MIN_WIDTH); 
      m_window_main.MinimumYSize(M_WINDOW_MAIN_MIN_HEIGHT); 
    //--- Set the tooltips
      m_window_main.GetCloseButtonPointer().Tooltip("Close");
      m_window_main.GetTooltipButtonPointer().Tooltip("Tooltips");
      m_window_main.GetFullscreenButtonPointer().Tooltip("Fullscreen");
      m_window_main.GetCollapseButtonPointer().Tooltip("Collapse/Expand");
    //--- Create the form default ENUM_WINDOW_TYPE W_MAIN
      if (!m_window_main.CreateWindow(m_chart_id, m_subwin, caption_text, 1, 1))
         return (false);
   return (true);
  }
 //For control inside Main Window m_window_main
 //For m_treeview_SymbolTF on the left pannel m_window_main
  bool CGUIPannel::CreateTreeView_SymbolTF(const int x_gap, const int y_gap)
   {       
     m_treeview_SymbolTF.MainPointer(m_window_main);
     m_treeview_SymbolTF.AutoXResizeMode(false);  // fixed width
     m_treeview_SymbolTF.XSize(M_TREEVIEW_SYMBOLTF_WIDTH);
     m_treeview_SymbolTF.AutoYResizeMode(true);
     m_treeview_SymbolTF.VisibleItemsTotal(15);
     m_treeview_SymbolTF.LightsHover(true);
     m_treeview_SymbolTF.AutoYResizeBottomOffset(25);
     if(!m_treeview_SymbolTF.CreateTreeView(x_gap, y_gap)) return false;      
     CWndContainer::AddToElementsArray(WindowIdx(m_window_main), m_treeview_SymbolTF);      
     return true;
   }  
  void CGUIPannel::PopulateSymbolTFTree(void)
   {
    if(m_BarTimeSeriesCollection == NULL) return;
    int mw_total = ::SymbolsTotal(true);
      // Grow registry if MarketWatch expanded
       if(ArraySize(m_sym_tree_pos) < mw_total)
        {
         int old = ArraySize(m_sym_tree_pos);
         ArrayResize(m_sym_tree_pos, mw_total);
         ArrayFill  (m_sym_tree_pos, old, mw_total - old, -1);
        }
      // --- SymbolName(i,true)'s own index order is Market Watch's internal/insertion order,
      // --- NOT the alphabetically-sorted order the Market Watch grid displays (Anhnt,
      // --- 2026-07-19) - a brand new symbol node only ever gets APPENDED (AddTreeItem always
      // --- uses ItemsTotal() as the new list_index, there's no "insert at position"), so the
      // --- only way to make first-time node creation come out sorted is to visit symbols in
      // --- sorted order here. m_sym_tree_pos[] stays keyed by the RAW Market Watch index i -
      // --- only the iteration order changes, already-created nodes are unaffected.
      int order[];
      ArrayResize(order, mw_total);
      for(int i = 0; i < mw_total; i++) order[i] = i;
      for(int a = 0; a < mw_total - 1; a++)
         for(int b = a + 1; b < mw_total; b++)
            if(::SymbolName(order[b], true) < ::SymbolName(order[a], true))
              { int tmp = order[a]; order[a] = order[b]; order[b] = tmp; }
      // --- FormTreeList() silently drops any item whose item_index is not monotonically
      // --- increasing within its node_level, in the order items were created/appended
      // --- (Anhnt, 2026-07-19) - since we now visit symbols in ALPHABETICAL order (not raw
      // --- Market Watch index order), raw i is NOT monotonic across creation order any more.
      // --- sym_item_seq tracks "how many sym nodes exist so far" and is used as item_index
      // --- instead of i, so it always increases by exactly 1 per new node, regardless of
      // --- which raw index i that node happens to be.
       int sym_item_seq = 0;
       for(int c = 0; c < ArraySize(m_sym_tree_pos); c++)
         if(m_sym_tree_pos[c] != -1) sym_item_seq++;
       for(int oi = 0; oi < mw_total; oi++)
        {
          int               i        = order[oi];
          string            sym_name = ::SymbolName(i, true);
          CBarTimeSeriesDE *bts      = m_BarTimeSeriesCollection.GetTimeseries(sym_name);
          CArrayObj        *list     = (bts != NULL) ? bts.GetListSeries() : NULL;
          int               tf_cnt   = (list != NULL) ? list.Total() : 0;
          // Step 1: Ensure sym node exists
           if(m_sym_tree_pos[i] == -1)
            {
             int sym_li = m_treeview_SymbolTF.ItemsTotal();
             m_sym_tree_pos[i] = sym_li;
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
           int sym_li = m_sym_tree_pos[i];
           if(tf_cnt == 0) continue;   //No TF found on sym_li
          // Step 2: Collect existing TF children of sym_li node
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
          // --- GetSeriesByIndex()'s own order is creation order, not TF rank (Anhnt,
          // --- 2026-07-19) - sort the LOOKUP order by IndexEnumTimeframe() so slot k below
          // --- (positionally matched against existing children[k]) ends up ascending M1..MN1,
          // --- same reasoning as the symbol-level sort above.
           int tf_order[];
           ArrayResize(tf_order, tf_cnt);
           for(int k = 0; k < tf_cnt; k++) tf_order[k] = k;
           for(int a = 0; a < tf_cnt - 1; a++)
              for(int b = a + 1; b < tf_cnt; b++)
                {
                 CBarSeriesDE *sa = bts.GetSeriesByIndex((uchar)tf_order[a]);
                 CBarSeriesDE *sb = bts.GetSeriesByIndex((uchar)tf_order[b]);
                 if(sa == NULL || sb == NULL) continue;
                 if(IndexEnumTimeframe(sb.Timeframe()) < IndexEnumTimeframe(sa.Timeframe()))
                   { int tmp = tf_order[a]; tf_order[a] = tf_order[b]; tf_order[b] = tmp; }
                }
          // Step 3: Match bts[k] against children[k]
           int actual_sym_li = -1;
           for(int k = 0; k < tf_cnt; k++)
            {
             CBarSeriesDE *s = bts.GetSeriesByIndex((uchar)tf_order[k]);
             if(s == NULL) continue;
             string actual = TimeframeDescription(s.Timeframe());
             if(k < child_count)
              {
               // Slot exists — Bug B: update label if period changed
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
                                          k, 1, i, 0, 0, 
                                          true,   //item_state, m_t_item_state[]=true;
                                          false   //is_folder m_t_is_folder[]=false
                                       );
               //Register new CTreeItem  
                CTreeItem *new_item = m_treeview_SymbolTF.ItemPointer(m_treeview_SymbolTF.ItemsTotal() - 1);
                if(new_item != NULL)
                  CWndContainer::AddToElementsArray(WindowIdx(m_window_main), *new_item);
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
 //For Main Tabs m_tabs_main on the right of Main Window m_window_main  
  bool CGUIPannel::CreateTab_Main(const int x_gap, const int y_gap)
   {      
    string tabs_names[TAB_TAB_MAIN_TOTAL] = {"Account infor", "Symbol Info", "Monitor", "Positions", "History", "Settings","Bar Events"};
    string texts[TAB_TAB_MAIN_TOTAL] = 
     {
      "[ Account Info Tab ]",
      "[ Symbol Info Tab ]",
      "[ Monitor Tab ]",
      "[ Positions Tab ]",
      "[ History Tab ]",
      "[ Settings Tab ]",
      "[ Bar Events Tab ]"
     };
    //--- Store the pointer to the main control
     m_tabs_main.MainPointer(m_window_main);
    //--- Properties
     m_tabs_main.IsCenterText(true);
     m_tabs_main.PositionMode(TABS_TOP);
     m_tabs_main.AutoXResizeMode(true);
     m_tabs_main.AutoYResizeMode(true);
     m_tabs_main.AutoXResizeRightOffset(3);
     m_tabs_main.AutoYResizeBottomOffset(25);
    //--- Add tabs with the specified properties
     for (int i = 0; i < TAB_TAB_MAIN_TOTAL; i++)
      {
       m_tabs_main.AddTab(tabs_names[i], 100);            
      }
    //--- Create Tab before create other control element inside
     if (!m_tabs_main.CreateTabs(x_gap, y_gap))
      return (false);
    CWndContainer::AddToElementsArray(WindowIdx(m_window_main), m_tabs_main);
    return (true);
   }
 // For Status Bar at bottom of m_window_main
  //+------------------------------------------------------------------+
  //| Creates the status bar                                           |
  //+------------------------------------------------------------------+
  bool CGUIPannel::CreateStatusBar(const int x_gap, const int y_gap)
    {
     //--- Store the window pointer
      m_status_bar.MainPointer(m_window_main);
     //--- Properties
      m_status_bar.AutoXResizeMode(true);
      m_status_bar.AutoXResizeRightOffset(1);
      m_status_bar.AnchorBottomWindowSide(true);
     //--- Specify the number of parts and set their properties
      int width[STATUS_LABELS_TOTAL] = {0, 200, 160, 120};
      for (int i = 0; i < STATUS_LABELS_TOTAL; i++)
        m_status_bar.AddItem("", width[i]);
     //--- Create a control element
      if (!m_status_bar.CreateStatusBar(x_gap, y_gap))
        return (false);
     //--- Set text to the items of the status bar
      m_status_bar.SetValue(STATUS_BAR_HELP, "For Help, press F1");
     //--- Setup icons for Deposit Load item (arrow up=high load, gray=medium, arrow down=low)
      //--- Same icon set as m_table_indicator_SymbolTFValue's own val_img (Anhnt, 2026-07-19 -
      //--- unify look across the panel instead of the plain ARROW_UP/DOWN pair used before).
      CTextLabel *deposit_item = m_status_bar.GetItemPointer(STATUS_BAR_DEPOSIT_LOAD);
      deposit_item.AddImagesGroup(2, 6); // x_gap=2, y_gap=6
      deposit_item.AddImage(0, IMAGE_RESOURCE_BMP16_ICONS8_RIGHT_UP_PNG);
      deposit_item.AddImage(0, IMAGE_RESOURCE_BMP16_ICONS8_RIGHT_DOWN_PNG);
      deposit_item.AddImage(0, IMAGE_RESOURCE_BMP16_CIRCLE_GRAY_BMP);
      deposit_item.ChangeImage(0, 2); // default: gray
      deposit_item.LabelXGap(22);     // shift text right for icon (16px ICONS8 icon at x=2, same 22px clearance as m_table_indicator_SymbolTFValue's val_img)
     //--- Setup icons for Profit item (arrow up=profit, arrow down=loss, gray=zero)
      CTextLabel *profit_item = m_status_bar.GetItemPointer(STATUS_BAR_PROFIT);
      profit_item.AddImagesGroup(2, 6); // x_gap=2, y_gap=6
      profit_item.AddImage(0, IMAGE_RESOURCE_BMP16_ICONS8_RIGHT_UP_PNG);
      profit_item.AddImage(0, IMAGE_RESOURCE_BMP16_ICONS8_RIGHT_DOWN_PNG);
      profit_item.AddImage(0, IMAGE_RESOURCE_BMP16_CIRCLE_GRAY_BMP);
      profit_item.ChangeImage(0, 2); // default: gray
      profit_item.LabelXGap(22);     // shift text right for icon (16px ICONS8 icon at x=2, same 22px clearance as m_table_indicator_SymbolTFValue's val_img)
     //--- Add the object to the common array of object groups      
     CWndContainer::AddToElementsArray(WindowIdx(m_window_main), m_status_bar);
     return (true);
    }  
  // Update Status Bar - ported from V1 (Anatoli Kazharski\GUIPannel.mqh); V7 kept the item
  // creation/icons above but dropped both this function AND its OnTickEvent call site along
  // the way - restored here, same call site as V1 (see OnTickEvent below).
  bool CGUIPannel::UpdateStatusBar(void)
   {
    static string s_deposit = "";
    static string s_time = "";
    static string s_profit = "";
    static double s_deposit_val = 0;
    static double s_profit_val = 0;

    double deposit_val = DepositLoad(false);
    double profit_val = AccountInfoDouble(ACCOUNT_PROFIT);
    string new_deposit = "Deposit load: " + ::DoubleToString(deposit_val, 2) + "/" +
                         ::DoubleToString(DepositLoad(true), 2) + "%";
    string new_time = ::TimeToString(::TimeTradeServer(), TIME_DATE | TIME_SECONDS);
    string new_profit = "Profit: " + ::DoubleToString(profit_val, 2);
    // Check if values changed, if changed, update the status bar item and redraw it. Only update when value changes to reduce CPU usage.
     bool any_changed = false;
     if (new_deposit != s_deposit)
      {
       int img = (s_deposit == "") ? 2 : (deposit_val > s_deposit_val) ? 0
                                     : (deposit_val < s_deposit_val)   ? 1
                                                                    : 2;
       s_deposit_val = deposit_val;
       s_deposit = new_deposit;
       CTextLabel *item = m_status_bar.GetItemPointer(STATUS_BAR_DEPOSIT_LOAD);
       item.ChangeImage(0, img);
       m_status_bar.SetValue(STATUS_BAR_DEPOSIT_LOAD, new_deposit);
       item.Draw();
       item.Update(false);
       any_changed = true;
      }
     if (new_profit != s_profit)
      {
       int img = (s_profit == "") ? 2 : (profit_val > s_profit_val) ? 0
                                     : (profit_val < s_profit_val)   ? 1
                                                                    : 2;
       color clr = (profit_val > 0) ? clrGreen : (profit_val < 0) ? clrRed
                                                                  : clrBlack;
       s_profit_val = profit_val;
       s_profit = new_profit;
       CTextLabel *item = m_status_bar.GetItemPointer(STATUS_BAR_PROFIT);
       item.ChangeImage(0, img);
       item.LabelColor(clr);
       m_status_bar.SetValue(STATUS_BAR_PROFIT, new_profit);
       item.Draw();
       item.Update(false);
       any_changed = true;
      }
     if (new_time != s_time)
      {
       s_time = new_time;
       m_status_bar.SetValue(STATUS_BAR_SERVER_TIME, new_time);
       m_status_bar.GetItemPointer(STATUS_BAR_SERVER_TIME).Draw();
       m_status_bar.GetItemPointer(STATUS_BAR_SERVER_TIME).Update(false);
      }
     return any_changed;
   }
  // Deposit load - ported verbatim from V1 (Anatoli Kazharski\        |
  // GUIPannel.mqh): plain built-in AccountInfoDouble/SymbolInfoDouble |
  // calls, no Library CAccount wrapper needed. percent_mode==true     |
  // returns margin as % of EQUITY (not Balance).                      |
  // Used in: UpdateStatusBar (Deposit Load status bar item).          |
  //+------------------------------------------------------------------+
  double CGUIPannel::DepositLoad(const bool percent_mode, const double price = 0.0, const string symbol = "", const double volume = 0.0)
   {
    //--- Calculate the current value of the deposit load
     double margin = 0.0;
    //--- Total account load
     if (symbol == "" || volume == 0.0)
     margin = ::AccountInfoDouble(ACCOUNT_MARGIN);
    //--- Load on a specified symbol
     else
      {
       //--- Get margin calculation data
        double leverage = ((double)::AccountInfoInteger(ACCOUNT_LEVERAGE) == 0)
                            ? 1
                            : (double)::AccountInfoInteger(ACCOUNT_LEVERAGE);
        double contract_size = ::SymbolInfoDouble(symbol, SYMBOL_TRADE_CONTRACT_SIZE);
        string account_currency = ::AccountInfoString(ACCOUNT_CURRENCY);
        string base_currency = ::SymbolInfoString(symbol, SYMBOL_CURRENCY_BASE);
        //--- If trading account currency is the same as the symbol base currency
        if (account_currency == base_currency)
          margin = (volume * contract_size) / leverage;
        else
          margin = (volume * contract_size) / leverage * price;
      }
    //--- Get the current funds
     double equity = (::AccountInfoDouble(ACCOUNT_EQUITY) == 0)
                    ? 1
                    : ::AccountInfoDouble(ACCOUNT_EQUITY);
    //--- Return the current deposit load
    return ((!percent_mode) ? margin : (margin / equity) * 100);
   }
#endif // CGUIPANNEL_MAINWINDOWS_MQH
