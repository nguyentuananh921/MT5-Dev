//+------------------------------------------------------------------+
//|                                         GUIPannel_TabMonitor.mqh |
//+------------------------------------------------------------------+
#ifndef CGUIPANNEL_TABMONITOR_MQH
#define CGUIPANNEL_TABMONITOR_MQH
#include "GUIPannel.mqh"
 //To Monitor Indicator value Per Symbol + Tf Value
 //+------------------------------------------------------------------+
 //| Create Trade tab table: Symbol / TF / Indicator / Value / Buy / Sell / Trailing
 //+------------------------------------------------------------------+
 bool CGUIPannel::CreateTableIndicatorSymbolTFValue(const int x, const int y)
  {
    m_table_indicator_SymbolTFValue.MainPointer(m_tabs_main);
    m_tabs_main.AddToElementsArray(TAB_TAB_MAIN_MONITOR, m_table_indicator_SymbolTFValue);
    m_table_indicator_SymbolTFValue.AutoXResizeMode(true);
    m_table_indicator_SymbolTFValue.AutoXResizeRightOffset(3);
    m_table_indicator_SymbolTFValue.AutoYResizeMode(true);
    m_table_indicator_SymbolTFValue.AutoYResizeBottomOffset(3);
    m_table_indicator_SymbolTFValue.ShowHeaders(true);
    m_table_indicator_SymbolTFValue.SelectableRow(true);
    m_table_indicator_SymbolTFValue.LightsHover(true);
    m_table_indicator_SymbolTFValue.IsSortMode(true);
    // 7 cols: Symbol | TF(+signal icon) | Indicator(+dir icon) | Value | Buy | Sell | Trailing
    // Col 1 (TF): signal icon = trend direction; TextXOffset=22 clears 16px icon at x=3
    // Col 2 (Indicator): dir icon = value slope (v0 vs v1); same TextXOffset=22
    // Col 3 (Value): no icon, ALIGN_RIGHT, colored text only
    m_table_indicator_SymbolTFValue.TableSize(7, 20);
    int widths[7]    = {90,  60, INDICATOR_PARATEXT_WIDTH, 90, 40, 40, 55};
    int img_x_off[7] = { 3,   3,   3,  0, 10, 10, 10};
    int img_y_off[7] = { 0,   3,   3,  0,  3,  3,  3};
    int txt_x_off[7] = { 5,  22,  22,  5,  5,  5,  5};
    ENUM_ALIGN_MODE al[7] = {ALIGN_LEFT, ALIGN_LEFT, ALIGN_LEFT,
                            ALIGN_RIGHT, ALIGN_LEFT, ALIGN_LEFT, ALIGN_LEFT};
    m_table_indicator_SymbolTFValue.ColumnsWidth(widths);
    m_table_indicator_SymbolTFValue.ImageXOffset(img_x_off);
    m_table_indicator_SymbolTFValue.ImageYOffset(img_y_off);
    m_table_indicator_SymbolTFValue.TextXOffset(txt_x_off);
    m_table_indicator_SymbolTFValue.TextAlign(al);

    if(!m_table_indicator_SymbolTFValue.CreateTable(x, y)) return false;

    m_table_indicator_SymbolTFValue.SetHeaderText(0, "Symbol");
    m_table_indicator_SymbolTFValue.SetHeaderText(1, "TF");
    m_table_indicator_SymbolTFValue.SetHeaderText(2, "Indicator");
    m_table_indicator_SymbolTFValue.SetHeaderText(3, "Value");
    m_table_indicator_SymbolTFValue.SetHeaderText(4, "Buy");
    m_table_indicator_SymbolTFValue.SetHeaderText(5, "Sell");
    m_table_indicator_SymbolTFValue.SetHeaderText(6, "Trailing");

    CWndContainer::AddToElementsArray(WindowIdx(m_window_main), m_table_indicator_SymbolTFValue);
    return true;
  }
 //+------------------------------------------------------------------+
 //| Populate / refresh the Trade tab table (no-flicker per-cell)     |
 //+------------------------------------------------------------------+
 void CGUIPannel::SetValuesToTableIndicatorSymbolTFValue(void)
  {
   if(m_IndicatorsCollection == NULL || m_BarTimeSeriesCollection == NULL) 
       return;
   // --- Collect every indicator by walking m_BarTimeSeriesCollection (reliable: symbol -> TF series
   // structure, never observed to drift), then pulling each series' own indicator set from
   // m_IndicatorsCollection. All_syms[] is taken from the CBarSeriesDE object itself, not from
   // ind.Symbol() - keeps the two collections' data consistent with each other rather than
   // trusting the indicator's own copy of a value that (elsewhere, before a fix) was seen to drift.
    CIndicatorDE *all_inds[];
    string        all_syms[];
    int           count = 0;

    CArrayObj *sym_containers = m_BarTimeSeriesCollection.GetList();
    int sym_total = (sym_containers != NULL) ? sym_containers.Total() : 0;
    for(int si = 0; si < sym_total; si++)
     {
      CBarTimeSeriesDE *bts = sym_containers.At(si);
      if(bts == NULL) continue;
      CArrayObj *series_list = bts.GetListSeries();
      int series_total = (series_list != NULL) ? series_list.Total() : 0;
      for(int ti = 0; ti < series_total; ti++)
       {
        CBarSeriesDE *bs = series_list.At(ti);
        if(bs == NULL) continue;
        CArrayObj *ind_list = m_IndicatorsCollection.GetListIndBySymbol(bs.Symbol());
        ind_list = CTimeseriesSelect::ByIndicatorProperty(ind_list, INDICATOR_PROP_TIMEFRAME, bs.Timeframe(), EQUAL);
        int ind_total = (ind_list != NULL) ? ind_list.Total() : 0;
        for(int ii = 0; ii < ind_total; ii++)
         {
          CIndicatorDE *ind = ind_list.At(ii);
          if(ind == NULL) continue;
          ::ArrayResize(all_inds, count + 1);
          ::ArrayResize(all_syms, count + 1);
          all_inds[count] = ind;
          all_syms[count] = bs.Symbol();
          count++;
         }
       }
     }
    SIndicatorCatalogItem catalog[];
    GetIndicatorCatalog(catalog);
   // --- All templates gone: purge the table down to ONE truly blank physical row.
   // --- DeleteAllRows only clears text - the surviving row would keep its icons
   // --- (SetImages rejects an empty array), so swap in a freshly CellInitialize'd
   // --- row via AddRow(1) + DeleteRow(0), same trick as m_table_indicator.
   if(count == 0)
    {
     if(m_int_table_indicator_SymbolTFValue_table_row_count != 0)
      {
       m_table_indicator_SymbolTFValue.DeleteAllRows();
       m_table_indicator_SymbolTFValue.AddRow(1);
       m_table_indicator_SymbolTFValue.DeleteRow(0, true);
       ::ArrayResize(m_string_table_indicator_SymbolTFValue_cache_val,      0);
       ::ArrayResize(m_int_table_indicator_SymbolTFValue_cache_sig_icon, 0);
       ::ArrayResize(m_int_table_indicator_SymbolTFValue_cache_dir_icon, 0);
       m_int_table_indicator_SymbolTFValue_table_row_count = 0;
       m_table_indicator_SymbolTFValue.Update(true);
      }
     return;
    }
   // --- Full rebuild when row count changes
   if(count != m_int_table_indicator_SymbolTFValue_table_row_count)
    {
     uint chk[]     = {IMAGE_RESOURCE_BMP16_CHECKBOX_ON_G_PNG,
                        IMAGE_RESOURCE_BMP16_CHECKBOX_OFF_G_PNG};
     uint sig_img[] = {IMAGE_RESOURCE_BMP16_ARROW_UP_PNG,
                        IMAGE_RESOURCE_BMP16_ARROW_DOWN_PNG,
                        IMAGE_RESOURCE_BMP16_CIRCLE_GRAY_BMP};
     uint val_img[] = {IMAGE_RESOURCE_BMP16_ICONS8_RIGHT_UP_PNG,
                            IMAGE_RESOURCE_BMP16_ICONS8_RIGHT_DOWN_PNG,
                            IMAGE_RESOURCE_BMP16_CIRCLE_GRAY_BMP};

     m_table_indicator_SymbolTFValue.DeleteAllRows();
     ::ArrayResize(m_string_table_indicator_SymbolTFValue_cache_val,      count);
     ::ArrayResize(m_int_table_indicator_SymbolTFValue_cache_sig_icon, count);
     ::ArrayResize(m_int_table_indicator_SymbolTFValue_cache_dir_icon, count);
     ::ArrayInitialize(m_int_table_indicator_SymbolTFValue_cache_sig_icon, -1);
     ::ArrayInitialize(m_int_table_indicator_SymbolTFValue_cache_dir_icon, -1);
     for(int i = 0; i < count; i++) m_string_table_indicator_SymbolTFValue_cache_val[i] = "";
     // --- redraw=true on the LAST row only, same reasoning as RefreshIndicatorTable - see
     // --- README/BugNote 2026-07-14 black/smeared row-overflow bug.
     for(int i = 0; i < count - 1; i++)
      m_table_indicator_SymbolTFValue.AddRow(i, i == count - 2);
     for(int row = 0; row < count; row++)
     {
      CIndicatorDE *ind = all_inds[row];
      // Col 0: Symbol
       m_table_indicator_SymbolTFValue.SetValue(0, row, all_syms[row]);
      // Col 1: signal icon (trend) + TF text — TextXOffset=22 clears icon
       m_table_indicator_SymbolTFValue.SetImages(1, row, sig_img);
       m_table_indicator_SymbolTFValue.ChangeImage(1, row, 2);
       m_table_indicator_SymbolTFValue.SetValue(1, row, TimeframeDescription(ind.Timeframe()));
      // Col 2: signal icon + Indicator name — TextXOffset=22 pushes name past 16px icon
       MqlParam ind_params[];
       ind.GetMqlParams(ind_params);
       string ind_label = BuildIndicatorTextLabel(ind.TypeIndicator(), ind_params, catalog);
       m_table_indicator_SymbolTFValue.SetImages(2, row, val_img);
       m_table_indicator_SymbolTFValue.ChangeImage(2, row, 2);
       m_table_indicator_SymbolTFValue.SetValue(2, row, ind_label);
      // Col 3: Value — ALIGN_RIGHT, no icon; direction shown by text color (red/green/gray)
       m_table_indicator_SymbolTFValue.SetValue(3, row, "--");
      // Cols 4-6: checkboxes
       m_table_indicator_SymbolTFValue.CellType(4, row, CELL_CHECKBOX);
       m_table_indicator_SymbolTFValue.SetImages(4, row, chk);
       m_table_indicator_SymbolTFValue.ChangeImage(4, row, 1);
       m_table_indicator_SymbolTFValue.CellType(5, row, CELL_CHECKBOX);
       m_table_indicator_SymbolTFValue.SetImages(5, row, chk);
       m_table_indicator_SymbolTFValue.ChangeImage(5, row, 1);
       m_table_indicator_SymbolTFValue.CellType(6, row, CELL_CHECKBOX);
       m_table_indicator_SymbolTFValue.SetImages(6, row, chk);
       m_table_indicator_SymbolTFValue.ChangeImage(6, row, 1);
     }
     m_int_table_indicator_SymbolTFValue_table_row_count = count;
     m_table_indicator_SymbolTFValue.Update(true);
     return;
    }
   // --- Re-derive each indicator's CURRENT visual row before writing anything. CTable's own
   // header-click sort reorders its rows internally (Col 0/1/2 identity text moves together with
   // the row), independent of all_inds[]'s construction order - so after a user sorts, row index
   // no longer says which indicator is which. Col 0/1/2 text is never touched below (only their
   // icons/colors are), so it stays a reliable post-sort identity key to match back against.
    int row_of[];
    ::ArrayResize(row_of, count);
    for(int i = 0; i < count; i++)
     {
      MqlParam want_params[];
      all_inds[i].GetMqlParams(want_params);
      string want = all_syms[i] + "|" + TimeframeDescription(all_inds[i].Timeframe()) + "|" +
                    BuildIndicatorTextLabel(all_inds[i].TypeIndicator(), want_params, catalog);
      row_of[i] = -1;
      for(int row = 0; row < count; row++)
      {
        string have = m_table_indicator_SymbolTFValue.GetValue(0, row) + "|" +
                       m_table_indicator_SymbolTFValue.GetValue(1, row) + "|" +
                       m_table_indicator_SymbolTFValue.GetValue(2, row);
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
      double v0 = ind.GetDataBuffer(0, 0); // current bar (realtime via CopyBuffer)
      double v1 = ind.GetDataBuffer(0, 1); // previous bar (direction comparison)
      // Value direction: index 0=up 1=down 2=flat
       int dir_icon = 2;
       if(v0 != EMPTY_VALUE && v1 != EMPTY_VALUE)
          dir_icon = (v0 > v1) ? 0 : (v0 < v1) ? 1 : 2;
       color txt_clr = (dir_icon == 0) ? C'0,160,0' :    // rising  → green text
                       (dir_icon == 1) ? C'200,0,0' :    // falling → red text
                                         clrGray;         // flat    → gray text
      // Col 2 (Indicator): dir icon = value slope (v0 vs v1) - val_img, NOT the Signal system
       bool dir_changed = (dir_icon != m_int_table_indicator_SymbolTFValue_cache_dir_icon[row]);
       if(dir_changed)
        {
         m_int_table_indicator_SymbolTFValue_cache_dir_icon[row] = dir_icon;
         m_table_indicator_SymbolTFValue.ChangeImage(2, row, dir_icon);
         m_table_indicator_SymbolTFValue.BackColor(2, row, clrWhite, true);
         any_changed = true;
        }
      // Col 3 (Value): ALIGN_RIGHT, colored text only — redraw via TextColor(true)
       string val_str     = (v0 == EMPTY_VALUE) ? "--" : ::DoubleToString(v0, 5);
       bool   val_changed = (val_str != m_string_table_indicator_SymbolTFValue_cache_val[row]);
       if(val_changed || dir_changed)  // recolor on direction change too, even if the text itself didn't
        {
         if(val_changed)
          {
           m_string_table_indicator_SymbolTFValue_cache_val[row] = val_str;
           m_table_indicator_SymbolTFValue.SetValue(3, row, val_str);
          }
          m_table_indicator_SymbolTFValue.TextColor(3, row, txt_clr, true);
          any_changed = true;
        }
      // Col 1 (TF): sig_img - the actual Signal system, NOT value slope. GetOrCreateSignal itself
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
       if(m_time_series_engine != NULL)
        {
         // signal is BORROWED - CSignalsCollection owns it
          CSignalBase *signal = m_time_series_engine.GetSignalsCollection().GetOrCreateSignal(ind);
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
          if(sig_icon != m_int_table_indicator_SymbolTFValue_cache_sig_icon[row])
           {
            m_int_table_indicator_SymbolTFValue_cache_sig_icon[row] = sig_icon;
            m_table_indicator_SymbolTFValue.ChangeImage(1, row, sig_icon);
            m_table_indicator_SymbolTFValue.BackColor(1, row, clrWhite, true);
            any_changed = true;
           }
        }
       if(any_changed)
        m_table_indicator_SymbolTFValue.Update(false);
     }
  }
#endif // CGUIPANNEL_TABMONITOR_MQH
