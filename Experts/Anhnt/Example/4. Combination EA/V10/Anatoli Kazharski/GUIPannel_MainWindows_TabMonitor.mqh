//+------------------------------------------------------------------+
//|                             GUIPannel_MainWindows_TabMonitor.mqh |
//+------------------------------------------------------------------+

#ifndef CGUIPANNEL_MAINWINDOWS_TABMONITOR_MQH
#define CGUIPANNEL_MAINWINDOWS_TABMONITOR_MQH
#include "GUIPannel.mqh"
 //To Monitor Indicator value Per Symbol + Tf Value
 //+------------------------------------------------------------------+
 //| Create Trade tab table: Symbol / TF / Signal / Indicator / Value / Buy / Sell / Trailing
 //+------------------------------------------------------------------+
 bool CGUIPannel::CreateTable_IndicatorSymbolTFMonitor(const int x, const int y)
  {
    m_table_indicator_SymbolTFMonitor.MainPointer(m_tabs_main);
    m_tabs_main.AddToElementsArray(TAB_TAB_MAIN_MONITOR, m_table_indicator_SymbolTFMonitor);
    m_table_indicator_SymbolTFMonitor.AutoXResizeMode(true);
    m_table_indicator_SymbolTFMonitor.AutoXResizeRightOffset(3);
    m_table_indicator_SymbolTFMonitor.AutoYResizeMode(true);
    m_table_indicator_SymbolTFMonitor.AutoYResizeBottomOffset(3);
    m_table_indicator_SymbolTFMonitor.ShowHeaders(true);
    m_table_indicator_SymbolTFMonitor.SelectableRow(true);
    m_table_indicator_SymbolTFMonitor.LightsHover(true);
    m_table_indicator_SymbolTFMonitor.IsSortMode(true);
    // 8 cols: Symbol(+active-chart icon) | TF(+active-chart icon) | Signal(icon-only header) |
    // Indicator(+dir icon) | Value | Buy | Sell | Trailing
    // Col 0 (Symbol): active-chart icon = this row's symbol matches ::Symbol(); TextXOffset=22
    // Col 1 (TF): active-chart icon = this row's TF matches ::Period(); TextXOffset=22
    // Col 2 (Signal): icon-only column (no text) - the Signal system (Buy/Sell/neutral)
    // Col 3 (Indicator): dir icon = value slope (v0 vs v1); TextXOffset=22
    // Col 4 (Value): no icon, ALIGN_RIGHT, colored text only
    m_table_indicator_SymbolTFMonitor.TableSize(8, 20);
    int widths[8]    = {90,  60,  22, INDICATOR_PARATEXT_WIDTH, 90, 40, 40, 55};
    int img_x_off[8] = { 3,   3,  3,   3,  0, 10, 10, 10};
    int img_y_off[8] = { 3,   3,   3,   3,  0,  3,  3,  3};
    int txt_x_off[8] = {22,  22,   5,  22,  5,  5,  5,  5};
    ENUM_ALIGN_MODE al[8] = {ALIGN_LEFT, ALIGN_LEFT, ALIGN_LEFT, ALIGN_LEFT,
                            ALIGN_RIGHT, ALIGN_LEFT, ALIGN_LEFT, ALIGN_LEFT};
    m_table_indicator_SymbolTFMonitor.ColumnsWidth(widths);
    m_table_indicator_SymbolTFMonitor.ImageXOffset(img_x_off);
    m_table_indicator_SymbolTFMonitor.ImageYOffset(img_y_off);
    m_table_indicator_SymbolTFMonitor.TextXOffset(txt_x_off);
    m_table_indicator_SymbolTFMonitor.TextAlign(al);

    if(!m_table_indicator_SymbolTFMonitor.CreateTable(x, y)) return false;

    m_table_indicator_SymbolTFMonitor.SetHeaderText(0, "Symbol");
    m_table_indicator_SymbolTFMonitor.SetHeaderText(1, "TF");
    //Column 2 for Signal - icon-only header
     uint resource_indices_signal[] = {IMAGE_RESOURCE_BMP16_SIGNAL_PNG};
     m_table_indicator_SymbolTFMonitor.SetHeaderText(2, "");
     m_table_indicator_SymbolTFMonitor.SetHeaderImage(2, resource_indices_signal);
    m_table_indicator_SymbolTFMonitor.SetHeaderText(3, "Indicator");
    m_table_indicator_SymbolTFMonitor.SetHeaderText(4, "Value");
    m_table_indicator_SymbolTFMonitor.SetHeaderText(5, "Buy");
    m_table_indicator_SymbolTFMonitor.SetHeaderText(6, "Sell");
    m_table_indicator_SymbolTFMonitor.SetHeaderText(7, "Trailing");

    CWndContainer::AddToElementsArray(WindowIdx(m_window_main), m_table_indicator_SymbolTFMonitor);

    return true;
  }
 //+------------------------------------------------------------------+
 //| Populate / refresh the Trade tab table (no-flicker per-cell)     |
 //+------------------------------------------------------------------+
 void CGUIPannel::SetValuesToTable_IndicatorSymbolTFMonitor(void)
  {
   // Whole-row "this is the chart's current Symbol+TF" cache - drives Col 0/1's icon (both
   // together, not independently - a row only lights up when Symbol AND TF both match) and the
   // row's background highlight. Local static (function-scoped, not a class member) is enough;
   // no other method needs to see this, unlike the sig/dir/val caches above.
    static bool s_cache_row_active[];
   if(m_IndicatorsCollection == NULL || m_SymbolTFManager == NULL || m_indicator_template_manager == NULL)
       return;
   // --- Manager-first row build (Anhnt, 2026-08-30): m_SymbolTFManager (which Symbol+TF pairs are
   // --- configured) x m_indicator_template_manager (which indicator templates are configured) is
   // --- the Single Source of Truth - same convention as CheckIndicatorAlerts/CheckCandlePatternAlerts.
   // --- Layer 1 (m_IndicatorsCollection) is only consulted to find each combination's live
   // --- CIndicatorDE instance (by raw-param identity match); a combination with no Layer 1
   // --- instance yet (background sync still catching up) is simply skipped this pass.
    CIndicatorDE      *all_inds[];
    string             all_syms[];
    ENUM_TIMEFRAMES    all_tfs[];
    int                count = 0;

    int symtf_total = m_SymbolTFManager.Total();
    int tmpl_total  = m_indicator_template_manager.Total();
    for(int si = 0; si < symtf_total; si++)
     {
      CSymbolTFSetting *symtf = m_SymbolTFManager.At(si);
      if(symtf == NULL) continue;
      string sym = symtf.Symbol();
      ENUM_TIMEFRAMES tf = symtf.TFEnum();

      CArrayObj *ind_list = m_IndicatorsCollection.GetListIndBySymbol(sym);
      ind_list = CTimeseriesSelect::ByIndicatorProperty(ind_list, INDICATOR_PROP_TIMEFRAME, tf, EQUAL);
      int ind_total = (ind_list != NULL) ? ind_list.Total() : 0;
      if(ind_total == 0) continue;

      for(int ti = 0; ti < tmpl_total; ti++)
       {
        CIndicatorSetting *entry = m_indicator_template_manager.At(ti);
        if(entry == NULL) continue;
        MqlParam raw_params[];
        entry.GetRawParams(raw_params);
        if(ArraySize(raw_params) == 0) continue;

        // --- Find THIS Symbol+TF's own instance of the template row - RAW compare
        // --- (type_enum/raw_params), same identity convention as CheckIndicatorAlerts.
        CIndicatorDE *ind = NULL;
        for(int ii = 0; ii < ind_total; ii++)
         {
          CIndicatorDE *cand = ind_list.At(ii);
          if(cand == NULL || cand.TypeIndicator() != entry.TypeEnum()) continue;
          MqlParam cand_params[];
          cand.GetMqlParams(cand_params);
          if(IsEqualMqlParamArrays(cand_params, raw_params)) { ind = cand; break; }
         }
        if(ind == NULL) continue; // template not instantiated on this Symbol+TF yet

        ::ArrayResize(all_inds, count + 1);
        ::ArrayResize(all_syms, count + 1);
        ::ArrayResize(all_tfs,  count + 1);
        all_inds[count]    = ind;
        all_syms[count]    = sym;
        all_tfs[count]     = tf;
        count++;
       }
     }
   // --- All templates gone: purge the table down to ONE truly blank physical row.
   // --- DeleteAllRows only clears text - the surviving row would keep its icons
   // --- (SetImages rejects an empty array), so swap in a freshly CellInitialize'd
   // --- row via AddRow(1) + DeleteRow(0), same trick as m_table_indicator.
   if(count == 0)
    {
     if(m_int_table_indicator_SymbolTFMonitor_table_row_count != 0)
      {
       m_table_indicator_SymbolTFMonitor.DeleteAllRows();
       m_table_indicator_SymbolTFMonitor.AddRow(1);
       m_table_indicator_SymbolTFMonitor.DeleteRow(0, true);
       ::ArrayResize(m_string_table_indicator_SymbolTFMonitor_cache_val,      0);
       ::ArrayResize(m_int_table_indicator_SymbolTFMonitor_cache_sig_icon, 0);
       ::ArrayResize(m_int_table_indicator_SymbolTFMonitor_cache_dir_icon, 0);
       ::ArrayResize(s_cache_row_active, 0);
       m_int_table_indicator_SymbolTFMonitor_table_row_count = 0;
       m_table_indicator_SymbolTFMonitor.Update(true);
      }
     return;
    }
   // --- Full rebuild when row count changes
   if(count != m_int_table_indicator_SymbolTFMonitor_table_row_count)
    {
     uint chk[]     = {IMAGE_RESOURCE_BMP16_CHECKBOX_ON_G_PNG,
                        IMAGE_RESOURCE_BMP16_CHECKBOX_OFF_G_PNG};
     uint sig_img[] = {IMAGE_RESOURCE_BMP16_ARROW_UP_PNG,
                        IMAGE_RESOURCE_BMP16_ARROW_DOWN_PNG,
                        IMAGE_RESOURCE_BMP16_CIRCLE_GRAY_BMP};
     uint val_img[] = {IMAGE_RESOURCE_BMP16_ICONS8_RIGHT_UP_PNG,
                            IMAGE_RESOURCE_BMP16_ICONS8_RIGHT_DOWN_PNG,
                            IMAGE_RESOURCE_BMP16_CIRCLE_GRAY_BMP};
     uint sym_img[] = {IMAGE_RESOURCE_BMP16_BAR_CHART_BMP,
                            IMAGE_RESOURCE_BMP16_BAR_CHART_COLORLESS_BMP};

     m_table_indicator_SymbolTFMonitor.DeleteAllRows();
     ::ArrayResize(m_string_table_indicator_SymbolTFMonitor_cache_val,      count);
     ::ArrayResize(m_int_table_indicator_SymbolTFMonitor_cache_sig_icon, count);
     ::ArrayResize(m_int_table_indicator_SymbolTFMonitor_cache_dir_icon, count);
     ::ArrayResize(s_cache_row_active, count);
     ::ArrayInitialize(m_int_table_indicator_SymbolTFMonitor_cache_sig_icon, -1);
     ::ArrayInitialize(m_int_table_indicator_SymbolTFMonitor_cache_dir_icon, -1);
     ::ArrayInitialize(s_cache_row_active, false);
     for(int i = 0; i < count; i++) m_string_table_indicator_SymbolTFMonitor_cache_val[i] = "";
     // --- redraw=true on the LAST row only, same reasoning as RefreshIndicatorTable - see
     // --- README/BugNote 2026-07-14 black/smeared row-overflow bug.
     for(int i = 0; i < count - 1; i++)
      m_table_indicator_SymbolTFMonitor.AddRow(i, i == count - 2);
     for(int row = 0; row < count; row++)
     {
      CIndicatorDE *ind = all_inds[row];
      // Col 0: Symbol + active-chart icon (colored = this row's symbol is the currently displayed
      // chart symbol, colorless otherwise) — TextXOffset=22 clears 16px icon at x=3
       m_table_indicator_SymbolTFMonitor.SetImages(0, row, sym_img);
       m_table_indicator_SymbolTFMonitor.ChangeImage(0, row, 1);
       m_table_indicator_SymbolTFMonitor.SetValue(0, row, all_syms[row]);
      // Col 1: TF text + active-chart icon (colored = this row's TF matches the currently
      // displayed chart TF, colorless otherwise) — same sym_img set, different match key
       m_table_indicator_SymbolTFMonitor.SetImages(1, row, sym_img);
       m_table_indicator_SymbolTFMonitor.ChangeImage(1, row, 1);
       m_table_indicator_SymbolTFMonitor.SetValue(1, row, TimeframeDescription(ind.Timeframe()));
      // Col 2: Signal icon only (no text) - the Signal system (Buy/Sell/neutral)
       m_table_indicator_SymbolTFMonitor.SetImages(2, row, sig_img);
       m_table_indicator_SymbolTFMonitor.ChangeImage(2, row, 2);
      // Col 3: dir icon + Indicator name (full params) — TextXOffset=22 pushes name past 16px icon
       MqlParam ind_params[];
       ind.GetMqlParams(ind_params);
       CIndicatorSetting ind_label_setting;
       ind_label_setting.TypeEnum(ind.TypeIndicator());
       ind_label_setting.SetRawParams(ind_params);
       string ind_label = ind_label_setting.DisplayLabel();
       m_table_indicator_SymbolTFMonitor.SetImages(3, row, val_img);
       m_table_indicator_SymbolTFMonitor.ChangeImage(3, row, 2);
       m_table_indicator_SymbolTFMonitor.SetValue(3, row, ind_label);
      // Col 4: Value — ALIGN_RIGHT, no icon; direction shown by text color (red/green/gray)
       m_table_indicator_SymbolTFMonitor.SetValue(4, row, "--");
      // Cols 5-7: checkboxes
       m_table_indicator_SymbolTFMonitor.CellType(5, row, CELL_CHECKBOX);
       m_table_indicator_SymbolTFMonitor.SetImages(5, row, chk);
       m_table_indicator_SymbolTFMonitor.ChangeImage(5, row, 1);
       m_table_indicator_SymbolTFMonitor.CellType(6, row, CELL_CHECKBOX);
       m_table_indicator_SymbolTFMonitor.SetImages(6, row, chk);
       m_table_indicator_SymbolTFMonitor.ChangeImage(6, row, 1);
       m_table_indicator_SymbolTFMonitor.CellType(7, row, CELL_CHECKBOX);
       m_table_indicator_SymbolTFMonitor.SetImages(7, row, chk);
       m_table_indicator_SymbolTFMonitor.ChangeImage(7, row, 1);
     }
     m_int_table_indicator_SymbolTFMonitor_table_row_count = count;
     m_table_indicator_SymbolTFMonitor.Update(true);
     return;
    }
   // --- Re-derive each indicator's CURRENT visual row before writing anything. CTable's own
   // header-click sort reorders its rows internally (Col 0/1/3 identity text moves together with
   // the row), independent of all_inds[]'s construction order - so after a user sorts, row index
   // no longer says which indicator is which. Col 0/1/3 text is never touched below (only their
   // icons/colors are), so it stays a reliable post-sort identity key to match back against.
    int row_of[];
    ::ArrayResize(row_of, count);
    for(int i = 0; i < count; i++)
     {
      MqlParam want_params[];
      all_inds[i].GetMqlParams(want_params);
      CIndicatorSetting want_label_setting;
      want_label_setting.TypeEnum(all_inds[i].TypeIndicator());
      want_label_setting.SetRawParams(want_params);
      string want = all_syms[i] + "|" + TimeframeDescription(all_inds[i].Timeframe()) + "|" +
                    want_label_setting.DisplayLabel();
      row_of[i] = -1;
      for(int row = 0; row < count; row++)
      {
        string have = m_table_indicator_SymbolTFMonitor.GetValue(0, row) + "|" +
                       m_table_indicator_SymbolTFMonitor.GetValue(1, row) + "|" +
                       m_table_indicator_SymbolTFMonitor.GetValue(3, row);
         if(have == want) { row_of[i] = row; break; }
      }
     }
   // --- Per-cell dirty update: only Value text + icons change in real-time
    bool any_changed = false;
    for(int i = 0; i < count; i++)
     {
      int row = row_of[i];
      if(row < 0) continue; // identity not found this tick - next full rebuild will resync
      CIndicatorDE *ind = all_inds[i];
      // Col 0/1 (Symbol/TF) + whole-row background: all driven by ONE combined condition, not
      // two independent per-column matches - a row (and its Symbol/TF icons) only lights up when
      // BOTH this row's symbol AND TF match the currently displayed chart (::Symbol()/::Period()).
      // Otherwise a merely-same-TF-different-symbol row (e.g. BTCUSDm M15 while chart shows
      // DXYm M15) would light up its TF icon too, reading as "partially active" - not the goal.
       bool row_active = (all_syms[i] == ::Symbol() && all_tfs[i] == (ENUM_TIMEFRAMES)::Period());
       if(row_active != s_cache_row_active[row])
        {
         s_cache_row_active[row] = row_active;
         int icon_idx = row_active ? 0 : 1;
         // redraw=true on ChangeImage itself (RedrawCell) repaints using whatever background
         // BackColor last set for this cell - so painting icons first then background below
         // (or either order) can't stomp on each other.
         m_table_indicator_SymbolTFMonitor.ChangeImage(0, row, icon_idx, true);
         m_table_indicator_SymbolTFMonitor.ChangeImage(1, row, icon_idx, true);
         color row_clr = row_active ? C'235,247,255' : clrWhite;
         for(int c = 0; c < 8; c++)
            m_table_indicator_SymbolTFMonitor.BackColor(c, row, row_clr, true);
         any_changed = true;
        }
      double v0 = ind.GetDataBuffer(0, 0); // current bar (realtime via CopyBuffer)
      double v1 = ind.GetDataBuffer(0, 1); // previous bar (direction comparison)
      // Value direction: index 0=up 1=down 2=flat
       int dir_icon = 2;
       if(v0 != EMPTY_VALUE && v1 != EMPTY_VALUE)
          dir_icon = (v0 > v1) ? 0 : (v0 < v1) ? 1 : 2;
       color txt_clr = (dir_icon == 0) ? C'0,160,0' :    // rising  → green text
                       (dir_icon == 1) ? C'200,0,0' :    // falling → red text
                                         clrGray;         // flat    → gray text
      // Col 3 (Indicator): dir icon = value slope (v0 vs v1) - val_img, NOT the Signal system
       bool dir_changed = (dir_icon != m_int_table_indicator_SymbolTFMonitor_cache_dir_icon[row]);
       if(dir_changed)
        {
         m_int_table_indicator_SymbolTFMonitor_cache_dir_icon[row] = dir_icon;
         m_table_indicator_SymbolTFMonitor.ChangeImage(3, row, dir_icon, true);
         any_changed = true;
        }
      // Col 4 (Value): ALIGN_RIGHT, colored text only — redraw via TextColor(true)
       string val_str     = (v0 == EMPTY_VALUE) ? "--" : ::DoubleToString(v0, 5);
       bool   val_changed = (val_str != m_string_table_indicator_SymbolTFMonitor_cache_val[row]);
       if(val_changed || dir_changed)  // recolor on direction change too, even if the text itself didn't
        {
         if(val_changed)
          {
           m_string_table_indicator_SymbolTFMonitor_cache_val[row] = val_str;
           m_table_indicator_SymbolTFMonitor.SetValue(4, row, val_str);
          }
          m_table_indicator_SymbolTFMonitor.TextColor(4, row, txt_clr, true);
          any_changed = true;
        }
      // Col 2 (Signal): sig_img - the actual Signal system, NOT value slope. GetOrCreateSignal itself
      // returns NULL for indicator types with no CSignalXXX wired yet, so this falls back to
      // dir_icon automatically - that fallback is the only place dir_icon and sig_icon are
      // allowed to share a value.
      // --- Sticky last-known direction (Anhnt, 2026-07-17): GetCurrentSignal() only fires at the
      // --- exact tick a crossover happens (bar0 vs bar1) - EMPTY_VALUE/neutral the rest of the
      // --- time, since a cross is a rare event, not a continuous state. User wants this column to
      // --- read as "uptrend/downtrend since the last Buy/Sell signal" instead - green/red persists
      // --- until the NEXT opposite flip, not just the instant of the flip itself. Prefer a flip
      // --- happening RIGHT NOW (more responsive); otherwise fall back to the last COMMITTED
      // --- history entry's direction (m_hist_* - permanent, only written when a bar actually
      // --- closed with a real flip), which is exactly this "last known direction" state.
       int sig_icon = dir_icon;
       if(m_timeSeriesEngine != NULL)
        {
         // signal is BORROWED - CSignalsCollection owns it
          CSignalBase *signal = m_timeSeriesEngine.GetSignalsCollection().GetOrCreateSignal(ind);
          if(signal != NULL)
           {
            ENUM_SIGNAL_DIR dir = signal.GetCurrentSignal();
            if(dir == SIGNAL_NONE)
             {
              int last_idx = signal.HistoryTotal() - 1;
              if(last_idx >= 0) dir = signal.HistoryDir(last_idx);
             }
            sig_icon = (dir == SIGNAL_BUY) ? 0 : (dir == SIGNAL_SELL) ? 1 : 2;
           }
          if(sig_icon != m_int_table_indicator_SymbolTFMonitor_cache_sig_icon[row])
           {
            m_int_table_indicator_SymbolTFMonitor_cache_sig_icon[row] = sig_icon;
            m_table_indicator_SymbolTFMonitor.ChangeImage(2, row, sig_icon, true);
            any_changed = true;
           }
        }
       if(any_changed)
        m_table_indicator_SymbolTFMonitor.Update(false);
     }
  }
#endif // CGUIPANNEL_MAINWINDOWS_TABMONITOR_MQH
