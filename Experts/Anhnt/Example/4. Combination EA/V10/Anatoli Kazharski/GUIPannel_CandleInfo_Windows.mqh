//+------------------------------------------------------------------+
//|                                 GUIPannel_CandleInfo_Windows.mqh |
//| Implementation of function Candle Info                           |
//| Window m_window_candle_infomation                               |
//| CTooltip m_tooltip_candle_info
//+------------------------------------------------------------------+
#ifndef CGUIPANNEL_CANDLEINFO_WINDOWS_MQH
#define CGUIPANNEL_CANDLEINFO_WINDOWS_MQH
#include "GUIPannel.mqh"
//For m_window_candle_infomation
 //+------------------------------------------------------------------+
 //| True while (px,py) - default the cursor's own position - sits     |
 //| inside ANY of our own visible GUI windows (m_window_main,          |
 //| m_window_setting, m_window_candle_infomation, ...) - loops         |
 //| CWndContainer's own m_windows[] instead of hardcoding each window  |
 //| by name, so a window added later is covered automatically.        |
 //| ChartXYToTimePrice() (CalculateAtCandle()'s own underlying call)   |
 //| has no concept of "obstructed by a GUI panel" - it happily         |
 //| resolves a valid bar/price even when the point sits on top of one  |
 //| of our own windows, which used to let Alt-hover render a phantom   |
 //| pattern-bitmap/tooltip UNDER the panel, both when the CURSOR sat   |
 //| there and, separately, when a pattern's own PRICE-computed label   |
 //| position did (ChartTimePriceToXY, independent of the cursor) -     |
 //| explicit px/py covers that second case (Anhnt, 2026-08-31).        |
 //+------------------------------------------------------------------+
 bool CGUIPannel::MouseOverAnyGUIWindow(const int px, const int py)
  {
   int check_x = (px == INT_MIN) ? m_mouse.X() : px;
   int check_y = (py == INT_MIN) ? m_mouse.Y() : py;
   int windows_total = CWndContainer::WindowsTotal();
   for(int w = 0; w < windows_total; w++)
    {
     CWindow *win = m_windows[w];
     if(win == NULL || !win.IsVisible()) continue;
     int x = win.X();
     int y = win.Y();
     if(check_x >= x && check_x <= x + win.XSize() &&
        check_y >= y && check_y <= y + win.YSize())
        return true;
    }
   return false;
  }
 //+------------------------------------------------------------------+
 //| Resolves the bar under the cursor right now - 0 if the cursor    |
 //| isn't over any real candle (a real iTime() is never 0/epoch, so  |
 //| that's a safe sentinel). Also doubles as the "is the mouse over  |
 //| a candle at all" bool check via != 0 - MQL5 has no overload-by-  |
 //| return-type, so one datetime-returning method covers both uses  |
 //| instead of two same-named overloads (Anhnt, 2026-08-31).         |
 //+------------------------------------------------------------------+
 datetime CGUIPannel::CalculateAtCandle(void)
  {
   datetime t; double price; int sub_window;
   if(!::ChartXYToTimePrice(m_chart_id, m_mouse.X(), m_mouse.Y(), sub_window, t, price))
      return 0;
   int shift = ::iBarShift(::Symbol(), (ENUM_TIMEFRAMES)::Period(), t, false);
   if(shift < 0) return 0;
   return ::iTime(::Symbol(), (ENUM_TIMEFRAMES)::Period(), shift);
  }
 //+------------------------------------------------------------------+
 //| Creates the Ctrl+hover "Signal at this bar" popup - fixed at the |
 //| chart's top-right corner, content-only (no drag-to-follow-cursor;|
 //| CWindow has no simple move-to-XY API for that, only manual drag  |
 //| state gated behind IsMovable/mouse-button-held).                 |
 //+------------------------------------------------------------------+
 bool CGUIPannel::CreateWindow_CandleInfo(void)
  {
    CWndContainer::AddWindow(m_window_candle_infomation);
    int chart_w = (int)::ChartGetInteger(m_chart_id, CHART_WIDTH_IN_PIXELS);
    int x = chart_w - CANDLE_INFO_WINDOW_W - 10;
    int y = 10;
    m_window_candle_infomation.XSize(CANDLE_INFO_WINDOW_W);
    m_window_candle_infomation.YSize(CANDLE_INFO_WINDOW_H);
    m_window_candle_infomation.FontSize(9);
    m_window_candle_infomation.IsMovable(false);
    m_window_candle_infomation.ResizeMode(false);
    m_window_candle_infomation.CloseButtonIsUsed(false);
    m_window_candle_infomation.CollapseButtonIsUsed(false);
    m_window_candle_infomation.TooltipsButtonIsUsed(false);
    m_window_candle_infomation.FullscreenButtonIsUsed(false);
    if(!m_window_candle_infomation.CreateWindow(m_chart_id, m_subwin, "Signals at Bar", x, y))
       return (false);
    // --- 3 cols: Time | TF (+ source icon: Indicator/Pattern) | Information (+ BUY/SELL arrow).    
     m_table_candle_information_atBar.MainPointer(m_window_candle_infomation);
     m_table_candle_information_atBar.AutoXResizeMode(true);
     m_table_candle_information_atBar.AutoXResizeRightOffset(3);
     m_table_candle_information_atBar.AutoYResizeMode(true);
     m_table_candle_information_atBar.AutoYResizeBottomOffset(3);
     m_table_candle_information_atBar.ShowHeaders(true);
     m_table_candle_information_atBar.SelectableRow(true);
     m_table_candle_information_atBar.LightsHover(true);
     m_table_candle_information_atBar.TableSize(3, 10);
     int widths[3]    = {45, 55, 155};
     int img_x_off[3] = {0, 3, 3};
     int img_y_off[3] = {0, 3, 3};
     int txt_x_off[3] = {5, 22, 22};
     ENUM_ALIGN_MODE al[3] = {ALIGN_LEFT, ALIGN_LEFT, ALIGN_LEFT};
     m_table_candle_information_atBar.ColumnsWidth(widths);
     m_table_candle_information_atBar.ImageXOffset(img_x_off);
     m_table_candle_information_atBar.ImageYOffset(img_y_off);
     m_table_candle_information_atBar.TextXOffset(txt_x_off);
     m_table_candle_information_atBar.TextAlign(al);
     if(!m_table_candle_information_atBar.CreateTable(0, WINDOW_CAPTION_HEIGHT)) return (false);
     m_table_candle_information_atBar.SetHeaderText(0, "Time");
     m_table_candle_information_atBar.SetHeaderText(1, "TF");
     m_table_candle_information_atBar.SetHeaderText(2, "Information");
     m_table_candle_information_atBar.DeleteAllRows();
     CWndContainer::AddToElementsArray(WindowIdx(m_window_candle_infomation), m_table_candle_information_atBar);
     m_tooltip_candle_info.MainPointer(m_window_main);
     m_tooltip_candle_info.ElementPointer(m_window_main);
     m_tooltip_candle_info.XSize(160);
     m_tooltip_candle_info.YSize(20);
     if(!m_tooltip_candle_info.CreateTooltip()) return (false);
     m_tooltip_candle_info.Show();
     return (true);
  } 
 void CGUIPannel::RepositionWindow_CandleInfo(const int cursor_x, const int cursor_y)
  {
   int chart_w = (int)::ChartGetInteger(m_chart_id, CHART_WIDTH_IN_PIXELS);
   int chart_h = (int)::ChartGetInteger(m_chart_id, CHART_HEIGHT_IN_PIXELS);   
   int x = cursor_x - CANDLE_INFO_CURSOR_INSET;
   if(x + CANDLE_INFO_WINDOW_W > chart_w)
      x = cursor_x - CANDLE_INFO_WINDOW_W + CANDLE_INFO_CURSOR_INSET;
   if(x < 0) x = 0;   
   int y = cursor_y - CANDLE_INFO_CURSOR_INSET;
   if(y + CANDLE_INFO_WINDOW_H > chart_h)
      y = cursor_y - CANDLE_INFO_WINDOW_H + CANDLE_INFO_CURSOR_INSET;
   if(y < 0) y = 0;
   m_window_candle_infomation.X(x);
   m_window_candle_infomation.Y(y);
   m_window_candle_infomation.Moving(x, y);
   m_table_candle_information_atBar.Moving();
  } 
 void CGUIPannel::ShowWindow_CandleInfo(const int cursor_x, const int cursor_y)
  {
     RepositionWindow_CandleInfo(cursor_x, cursor_y);     
     if(m_active_window_index != WindowIdx(m_window_candle_infomation))
        m_active_window_index_before_candle_info = m_active_window_index;     
     if(m_active_window_index != WindowIdx(m_window_candle_infomation))
        m_active_window_index_before_candle_info = m_active_window_index;
     m_active_window_index = WindowIdx(m_window_candle_infomation);
     Show(m_active_window_index);
     FormAvailableElementsArray();
  }
 //+------------------------------------------------------------------+
 //| Hides the popup and hands native dispatch back to whichever       |
 //| window was actually active before the popup stole it.             |
 //+------------------------------------------------------------------+
 void CGUIPannel::HideWindow_CandleInfo(void)
  {
     m_window_candle_infomation.Hide();
     m_table_candle_information_atBar.Hide();
     m_active_window_index = m_active_window_index_before_candle_info;
     FormAvailableElementsArray();
  }  
 bool CGUIPannel::RefreshWindow_CandleInfo(const datetime bar_time)
  {
   if(m_IndicatorsCollection == NULL || m_timeSeriesEngine == NULL || m_BarTimeSeriesCollection == NULL ||
      m_indicator_template_manager == NULL || m_SymbolTFManager == NULL)
      return false;
   datetime next_bar_time = bar_time + ::PeriodSeconds();
   string sym = ::Symbol();
   CBarTimeSeriesDE *bts = m_BarTimeSeriesCollection.GetTimeseries(sym);
   CArrayObj *series_list = (bts != NULL) ? bts.GetListSeries() : NULL;
   int series_total = (series_list != NULL) ? series_list.Total() : 0;
   // --- Sort this symbol's TFs ascending by IndexEnumTimeframe() (CommonDELib.mqh - M1..MN1
   // --- natural rank), same convention as CTimeSeriesEngine::SaveConfigurationToJSON.
    int order[];
    ArrayResize(order, series_total);
    for(int ti = 0; ti < series_total; ti++)
      order[ti] = ti;
    for(int a = 0; a < series_total - 1; a++)
     for(int b = a + 1; b < series_total; b++)
      {
       CBarSeriesDE *sa = series_list.At(order[a]);
       CBarSeriesDE *sb = series_list.At(order[b]);
       if(sa == NULL || sb == NULL) continue;
       if(IndexEnumTimeframe(sb.Timeframe()) < IndexEnumTimeframe(sa.Timeframe()))
        { int tmp = order[a]; order[a] = order[b]; order[b] = tmp; }
      }
   // --- Collect (Indicator, TF text, Dir, Time, Source) rows - one per flip whose time falls
   // --- inside [bar_time, next_bar_time). A signal with no flip in that span contributes
   // --- nothing at all (not even its carried-over state). Source tracks whether signal is
   // --- from Indicator (0) or Candle Pattern (1) for source icon display.
   //CIndicatorDE   *row_ind[];
    string          row_label[]; //Update here for candle
    string          row_tf[];
    ENUM_SIGNAL_DIR row_dir[];
    datetime        row_time[];
    int             row_source[]; // 0 = Indicator, 1 = Pattern
    int count = 0;
    for(int ti = 0; ti < series_total; ti++)
     {
       CBarSeriesDE *s = series_list.At(order[ti]);
       if(s == NULL) continue;
       string tf_text = TimeframeDescription(s.Timeframe());
       // --- Symbol+TF-level Buy/Sell gate (same 2-layer gate CSignalBridgeWriter uses) -
       // --- computed once per TF, applied to every Indicator/Pattern row below (Anhnt, 2026-08-28).
        CSymbolTFSetting *symtf_entry = m_SymbolTFManager.FindByIdentity(sym, s.Timeframe());
        bool symtf_buy  = (symtf_entry != NULL) ? symtf_entry.BuySignal()  : false;
        bool symtf_sell = (symtf_entry != NULL) ? symtf_entry.SellSignal() : false;
       CArrayObj *ind_list = m_IndicatorsCollection.GetListIndBySymbol(sym);
       ind_list = CTimeseriesSelect::ByIndicatorProperty(ind_list, INDICATOR_PROP_TIMEFRAME, s.Timeframe(), EQUAL);
       int ind_total = (ind_list != NULL) ? ind_list.Total() : 0;
       for(int ii = 0; ii < ind_total; ii++)
        {
         CIndicatorDE *ind = ind_list.At(ii);
         if(ind == NULL) continue;
         ENUM_INDICATOR ind_type = ind.TypeIndicator();
         MqlParam ind_params[];
         ind.GetMqlParams(ind_params);
         CIndicatorSetting ind_label_setting;
         ind_label_setting.TypeEnum(ind_type);
         ind_label_setting.SetRawParams(ind_params);
         // --- Indicator-level Buy/Sell gate - combines with symtf_buy/sell above (Anhnt, 2026-08-28).
          CIndicatorSetting *ind_entry = m_indicator_template_manager.FindByIdentity(ind_type, ind_params);
          bool ind_buy  = (ind_entry != NULL) ? ind_entry.BuySignal()  : false;
          bool ind_sell = (ind_entry != NULL) ? ind_entry.SellSignal() : false;
         // signal is BORROWED - CSignalsCollection owns it
          CSignalBase *signal = m_timeSeriesEngine.GetSignalsCollection().GetOrCreateSignal(ind);
          if(signal == NULL) continue;
         // --- history is oldest->newest; walk backward and stop once we're before the span -
         // --- collect EVERY flip inside the span (usually 0 or 1, but never assume 1).
          for(int h = signal.HistoryTotal() - 1; h >= 0; h--)
           {
            datetime ht = signal.HistoryTime(h);
            if(ht >= next_bar_time) continue;
            if(ht < bar_time) break;

            ENUM_SIGNAL_DIR d = signal.HistoryDir(h);
            if(d == SIGNAL_BUY  && !(ind_buy  && symtf_buy))  continue;
            if(d == SIGNAL_SELL && !(ind_sell && symtf_sell)) continue;

            //ArrayResize(row_ind,  count + 1);
             ArrayResize(row_label,  count + 1);
             ArrayResize(row_tf,   count + 1);
             ArrayResize(row_dir,  count + 1);
             ArrayResize(row_time, count + 1);
             ArrayResize(row_source, count + 1);
            //row_ind[count]  = ind;
             row_label[count] = ind_label_setting.DisplayLabel();
             row_tf[count]   = tf_text;
             row_dir[count]  = d;
             row_time[count] = ht;
             row_source[count] = 0; // Indicator
             count++;
           }
         // --- BBands-only: also surface the Upper/Lower line-cross histories (Anhnt,
         // --- 2026-07-19) - same source BuildAndWriteSignalBridge now reads. Mid is
         // --- skipped here: it IS the primary signal now (CSignalBollinger::ComputeAt),
         // --- already collected by the generic signal.HistoryDir() loop just above -
         // --- including it here too would duplicate every Mid cross in this table.
         if(ind.TypeIndicator() == IND_BANDS)
          {
           CSignalBollinger *bb = (CSignalBollinger*)signal;
           for(int li = 0; li < 3; li++)
            {
             if(li == BBAND_LINE_MID) continue;
             for(int h = bb.LineHistoryTotal(li) - 1; h >= 0; h--)
              {
               datetime ht = bb.LineHistoryTime(li, h);
               if(ht >= next_bar_time) continue;
               if(ht < bar_time) break;

               ENUM_SIGNAL_DIR ld = bb.LineHistoryDir(li, h);
               if(ld == SIGNAL_BUY  && !(ind_buy  && symtf_buy))  continue;
               if(ld == SIGNAL_SELL && !(ind_sell && symtf_sell)) continue;

               //ArrayResize(row_ind,  count + 1);
                ArrayResize(row_label, count + 1);
                ArrayResize(row_tf,   count + 1);
                ArrayResize(row_dir,  count + 1);
                ArrayResize(row_time, count + 1);
                ArrayResize(row_source, count + 1);
               //row_ind[count]  = ind;
                row_label[count] = ind_label_setting.DisplayLabel() + ((li == BBAND_LINE_UPPER) ? " Upper" : " Lower");
                row_tf[count]   = tf_text;
                row_dir[count]  = ld;
                row_time[count] = ht;
                row_source[count] = 0; // Indicator
                count++;
              }
            }
          }
        }
     }
    // --- Collect Candle Patterns forming in [bar_time, next_bar_time) - runs ONCE (not per
    // --- TF/series iteration above) since it only depends on sym/bar_time/next_bar_time,
    // --- not on the per-series `s`; being inside the `for ti` loop duplicated every matching
    // --- pattern once per tracked series (Anhnt, 2026-08-10: 6 tracked TFs -> 6x duplicate rows).
     CArrayObj *all_patterns = m_BarTimeSeriesCollection.GetListAllPatterns();
     if(all_patterns != NULL)
      {
       int pat_total = all_patterns.Total();
       for(int p = 0; p < pat_total; p++)
        {
         CBarPattern *pat = all_patterns.At(p);
         if(pat == NULL || pat.Symbol() != sym) continue;
         datetime pt = pat.Time();
         if(pt < bar_time || pt >= next_bar_time) continue;
         ENUM_TIMEFRAMES ptf = pat.Timeframe();
         string tf_text = TimeframeDescription(ptf);
         ENUM_PATTERN_DIRECTION pdir = pat.Direction();
         ENUM_SIGNAL_DIR dir = (pdir == PATTERN_DIRECTION_BULLISH) ? SIGNAL_BUY :
                               (pdir == PATTERN_DIRECTION_BEARISH) ? SIGNAL_SELL : SIGNAL_NONE;
         if(dir == SIGNAL_NONE) continue;
         // --- Same 2-layer Buy/Sell gate as the Indicator loop above, but Pattern-scoped
         // --- (Anhnt, 2026-08-28): SymbolTF-level (re-looked-up here, pt's own TF may differ
         // --- from the outer `ti` loop's series) AND Pattern-level (PatternSignalBuy/Sell).
         CSymbolTFSetting *pat_symtf = m_SymbolTFManager.FindByIdentity(sym, ptf);
         bool pat_symtf_buy  = (pat_symtf != NULL) ? pat_symtf.BuySignal()  : false;
         bool pat_symtf_sell = (pat_symtf != NULL) ? pat_symtf.SellSignal() : false;
         bool pat_buy  = PatternSignalBuy(pat.TypePattern());
         bool pat_sell = PatternSignalSell(pat.TypePattern());
         if(dir == SIGNAL_BUY  && !(pat_buy  && pat_symtf_buy))  continue;
         if(dir == SIGNAL_SELL && !(pat_sell && pat_symtf_sell)) continue;
         // Format pattern label, e.g. "[2B] Bullish Engulfing"
         uint candles = pat.Candles();
         string candle_prefix = (candles > 0) ? "[" + IntegerToString(candles) + "B] " : "";
         string pat_name = pat.GetProperty(PATTERN_PROP_NAME);
         if(pat_name == "") pat_name = EnumToString(pat.TypePattern());
         ArrayResize(row_label, count + 1);
         ArrayResize(row_tf,    count + 1);
         ArrayResize(row_dir,   count + 1);
         ArrayResize(row_time,  count + 1);
         ArrayResize(row_source, count + 1);
         row_label[count] = candle_prefix + pat_name;
         row_tf[count]    = tf_text;
         row_dir[count]   = dir;
         row_time[count]  = pt;
         row_source[count] = 1; // Pattern
         count++;
        }
      }
     if(count == 0)
      {
       m_table_candle_information_atBar.DeleteAllRows();
       m_table_candle_information_atBar.Update(true);
       return false;
      }
    // --- Sort all collected rows ascending by time (stable-ish bubble sort - count is
    // --- small, same style as the TF order[] sort above).
     for(int a = 0; a < count - 1; a++)
      for(int b = a + 1; b < count; b++)
       if(row_time[b] < row_time[a])
        {
         //CIndicatorDE   *ti_ = row_ind[a];  row_ind[a]  = row_ind[b];  row_ind[b]  = ti_;
         string          lbl_ = row_label[a]; row_label[a] = row_label[b]; row_label[b] = lbl_;
         string          tf_ = row_tf[a];   row_tf[a]   = row_tf[b];   row_tf[b]   = tf_;
         ENUM_SIGNAL_DIR d_  = row_dir[a];  row_dir[a]  = row_dir[b];  row_dir[b]  = d_;
         datetime        tm_ = row_time[a]; row_time[a] = row_time[b]; row_time[b] = tm_;
         int             src_ = row_source[a]; row_source[a] = row_source[b]; row_source[b] = src_;
        }       
     uint source_img[] = {IMAGE_RESOURCE_BMP16_INDICATOR_BMP, IMAGE_RESOURCE_BMP16_CANDLE_PNG};
     uint dir_img[] = {IMAGE_RESOURCE_BMP16_ARROW_UP_PNG, IMAGE_RESOURCE_BMP16_ARROW_DOWN_PNG,
                        IMAGE_RESOURCE_BMP16_CIRCLE_GRAY_BMP};
     m_table_candle_information_atBar.DeleteAllRows();
    // --- redraw=true on the LAST row only - same black/smeared row-overflow reasoning as
    // --- RefreshIndicatorTable (README/BugNote 2026-07-14).
     for(int i = 0; i < count - 1; i++)
         m_table_candle_information_atBar.AddRow(i, i == count - 2);
      for(int row = 0; row < count; row++)
       {
        //CIndicatorDE *ind = row_ind[row];
         int src_idx = row_source[row]; // 0=Indicator(70), 1=Pattern(42)
         int dir_img_idx = (row_dir[row] == SIGNAL_BUY) ? 0 : 1; // row_dir is never SIGNAL_NONE here

         m_table_candle_information_atBar.SetImages(1, row, source_img);
         m_table_candle_information_atBar.ChangeImage(1, row, src_idx);
         m_table_candle_information_atBar.SetImages(2, row, dir_img);
         m_table_candle_information_atBar.ChangeImage(2, row, dir_img_idx);
         m_table_candle_information_atBar.SetValue(0, row, ::TimeToString(row_time[row], TIME_MINUTES));
         m_table_candle_information_atBar.SetValue(1, row, row_tf[row]);
         m_table_candle_information_atBar.SetValue(2, row, row_label[row]);
       }
     m_table_candle_information_atBar.Update(true);
     return true;
  }
 //+------------------------------------------------------------------+
 //| Alt + hover: shows the CGCnvPatternBitmap of the highest-priority |
 //| pattern (most candles, same tie-break as CPatternRenderer's pass  |
 //| 3->2->1) confirmed at the hovered bar's span [bar_time, bar_time+ |
 //| PeriodSeconds()). Only ONE bitmap is ever alive at a time - unlike|
 //| CPatternRenderer (disabled, too laggy rendering EVERY pattern on  |
 //| the chart at once), this stays cheap because it only ever draws  |
 //| the single pattern under the cursor.                              |
 //| The bitmap itself is created lazily and lives on the CBarPattern  |
 //| object (mirrors CPatternRenderer::CreatePatternBitmap) so re-     |
 //| hovering the same candle later just re-Shows() the cached one.    |
 //+------------------------------------------------------------------+
 void CGUIPannel::ShowPatternBitmapAtBar(const datetime bar_time)
  {
   if(m_BarTimeSeriesCollection == NULL) { HidePatternBitmapAtBar(); return; }
   datetime next_bar_time = bar_time + ::PeriodSeconds();
   string sym = ::Symbol();
   ENUM_TIMEFRAMES tf = (ENUM_TIMEFRAMES)::Period();

   CArrayObj *all_patterns = m_BarTimeSeriesCollection.GetListAllPatterns();
   if(all_patterns == NULL) { HidePatternBitmapAtBar(); return; }

   // --- Symbol+TF-level Buy/Sell gate, same 2-layer gate CSignalBridgeWriter/
   // --- RefreshCandleInfoWindow already use (Anhnt, 2026-08-29).
    CSymbolTFSetting *symtf_entry = (m_SymbolTFManager != NULL) ? m_SymbolTFManager.FindByIdentity(sym, tf) : NULL;
    bool symtf_buy  = (symtf_entry != NULL) ? symtf_entry.BuySignal()  : false;
    bool symtf_sell = (symtf_entry != NULL) ? symtf_entry.SellSignal() : false;

   CBarPattern *best = NULL;
   int best_candles = 0;
   int total = all_patterns.Total();
   for(int i = 0; i < total; i++)
    {
     CBarPattern *p = all_patterns.At(i);
     if(p == NULL || p.Symbol() != sym || p.Timeframe() != tf) continue;
     datetime pt = p.Time();
     if(pt < bar_time || pt >= next_bar_time) continue;
     // --- Pattern-level Buy/Sell gate, direction-aware - a pattern the user turned off (or
     // --- whose direction isn't opted into) never becomes a candidate to draw.
      ENUM_PATTERN_DIRECTION pdir = p.Direction();
      bool is_buy  = (pdir == PATTERN_DIRECTION_BULLISH);
      bool is_sell = (pdir == PATTERN_DIRECTION_BEARISH);
      if(is_buy  && !(PatternSignalBuy(p.TypePattern())  && symtf_buy))  continue;
      if(is_sell && !(PatternSignalSell(p.TypePattern()) && symtf_sell)) continue;
      if(!is_buy && !is_sell) continue; // neither BULLISH nor BEARISH - not a directional signal
     int n = (int)p.Candles();
     if(best == NULL || n > best_candles) { best = p; best_candles = n; }
    }
   if(best == NULL) { HidePatternBitmapAtBar(); return; }
   // --- Same "computed position, not cursor position" check ShowTooltip_CandlePatternInfo
   // --- already does for its own label (Anhnt, 2026-09-01, gap found in the show/hide audit
   // --- discussed with Anhnt) - the BOX has the identical risk of landing under a panel, since
   // --- its anchor comes from the pattern's own price/time, independent of where the cursor is.
    int box_x = 0, box_y = 0;
    ::ChartTimePriceToXY(m_chart_id, m_subwin, best.Time(), best.MotherBarHigh(), box_x, box_y);
    if(MouseOverAnyGUIWindow(box_x, box_y)) { HidePatternBitmapAtBar(); return; }

   int curr_scale = (int)::ChartGetInteger(m_chart_id, CHART_SCALE);
   if(best == m_pattern_bitmap_shown && best.HasBitmap() && curr_scale == m_pattern_bitmap_scale)
    {
     if(!best.GetBitmap().IsVisible()) { best.GetBitmap().Show(); ::ChartRedraw(m_chart_id); }
     return;
    }
   HidePatternBitmapAtBar();
   // --- Always rebuild from scratch (never reuse a cached bitmap across hovers) - its pixel
   // --- geometry is baked in at creation time from CHART_SCALE/CHART_HEIGHT_IN_PIXELS/price
   // --- range (CGCnvPatternBitmap::CalcWidth/CalcHeight), so reusing one across an intervening
   // --- zoom/pan renders it in the wrong place. Confirmed 2026-08-14: a fresh create always
   // --- matched the SignalMarkers marker exactly; a reused cached one didn't. Only ever 1
   // --- bitmap is alive at a time here, so the rebuild cost is negligible.
   best.ClearBitmap();
    {
     int      n        = best_candles;
     int      tf_ps     = (int)::PeriodSeconds(tf);
     datetime t_new     = best.Time();
     datetime t_old     = t_new - (datetime)((n - 1) * tf_ps);   // oldest bar's OPEN time
     // --- ChartTimePriceToXY(bar_open_time) lands on the bar's LEFT edge (confirmed via debug:
     // --- a single bar's own [open, open+period) span is exactly 1 slot wide in pixels), but
     // --- the DoEasy width/ANCHOR_CENTER formula below assumes the anchor time lands on the bar
     // --- SLOT CENTER (see CGCnvPatternBitmap header comment) - that mismatch shifted the whole
     // --- box half a bar too far left. Shifting the anchor by half a period (whole seconds,
     // --- every standard MQL5 timeframe is even) fixes it without touching the Library formula.
     datetime anchor_time = t_old + (datetime)(tf_ps / 2);
     int      chart_h   = (int)::ChartGetInteger(m_chart_id, CHART_HEIGHT_IN_PIXELS);
     double   price_max = ::ChartGetDouble(m_chart_id, CHART_PRICE_MAX);
     double   price_min = ::ChartGetDouble(m_chart_id, CHART_PRICE_MIN);
     string   name      = "PatternHover_" + (string)t_new + "_" + (string)best.ID();

     CGCnvPatternBitmap *bmp = new CGCnvPatternBitmap(m_chart_id, m_subwin, name, best.ID(),
                                                        anchor_time, best.MotherBarHigh(), best.MotherBarLow(),
                                                        best.Direction(), n,
                                                        curr_scale, chart_h, price_max, price_min);
     if(bmp == NULL) return;
     ::ObjectSetInteger(m_chart_id, bmp.Name(), OBJPROP_ANCHOR,  ANCHOR_CENTER);
     // --- "\n" suppresses MT5's default object tooltip (name + price) - we already draw our
     // --- own label via ShowCandlePatternInfo, don't want the native one leaking through too.
     ::ObjectSetString (m_chart_id, bmp.Name(), OBJPROP_TOOLTIP, "\n");
     ::ObjectSetInteger(m_chart_id, bmp.Name(), OBJPROP_BACK,    true);
     bmp.DrawView();
     best.AttachBitmap(bmp);
    }
   m_pattern_bitmap_scale = curr_scale;
   best.GetBitmap().Show();
   m_pattern_bitmap_shown = best;
   ShowTooltip_CandlePatternInfo(best);
   ::ChartRedraw(m_chart_id);
  }
 //+------------------------------------------------------------------+
 //| Draws the pattern's name directly on the chart (m_tooltip_candle_ |
 //| info, one CTooltip instance repositioned/retexted per hover via   |
 //| Moving(x,y) - Tooltip.mqh) - native OBJPROP_TOOLTIP hover-delay   |
 //| proved unreliable while the mouse keeps moving with Alt held      |
 //| (BugNote 2026-08-14: user never saw it appear), so the label is   |
 //| rendered proactively instead of relying on that.                  |
 //+------------------------------------------------------------------+
 void CGUIPannel::ShowTooltip_CandlePatternInfo(CBarPattern *pat)
  {
   if(pat == NULL) return;
   string pat_name = pat.GetProperty(PATTERN_PROP_NAME);
   if(pat_name == "") pat_name = ::EnumToString(pat.TypePattern());
   // --- Direction is already conveyed by color (blue=Bullish/red=Bearish, same convention
   // --- as the box itself), and candle count is already conveyed by the box's own width -
   // --- no "[nB]" prefix or direction word needed, just the name.
   color clr = (pat.Direction() == PATTERN_DIRECTION_BULLISH) ? clrRoyalBlue :
               (pat.Direction() == PATTERN_DIRECTION_BEARISH) ? clrCrimson : clrDimGray;
   // --- Pixel-based gap above the box (not a % of visible price range) - a % gap shrinks to
   // --- near-zero price on a zoomed-in chart, which is what let the label overlap the candles.
   int    chart_h    = (int)::ChartGetInteger(m_chart_id, CHART_HEIGHT_IN_PIXELS);
   double price_max  = ::ChartGetDouble(m_chart_id, CHART_PRICE_MAX);
   double price_min  = ::ChartGetDouble(m_chart_id, CHART_PRICE_MIN);
   double px_to_price = (chart_h > 0) ? (price_max - price_min) / chart_h : 0;
   double price = pat.MotherBarHigh() + px_to_price * 16;   // ~16px above the box

   int x = 0, y = 0;
   ::ChartTimePriceToXY(m_chart_id, m_subwin, pat.Time(), price, x, y);
   int tip_y = y - m_tooltip_candle_info.YSize();   // box sits ABOVE the anchor point

   // --- The anchor point comes from the PATTERN's own price/time, not from where the cursor
   // --- is - CalculateAtCandle()'s MouseOverAnyGUIWindow() gate (OnEvent) only stops a NEW
   // --- phantom show while the cursor itself sits over a panel; it says nothing about whether
   // --- THIS specific computed screen position happens to land under one (e.g. hovering a real,
   // --- open-chart candle whose pattern's own price projects to a spot the panel is covering) -
   // --- checked at both corners of the box, not just the anchor point (Anhnt, 2026-08-31,
   // --- "CandleWindow smear" recurrence #3).
   if(MouseOverAnyGUIWindow(x, tip_y) || MouseOverAnyGUIWindow(x + m_tooltip_candle_info.XSize(), y))
    {
     m_tooltip_candle_info.FadeOutTooltip();
     return;
    }
   m_tooltip_candle_info.ClearStrings();
   m_tooltip_candle_info.AddString(pat_name);
   m_tooltip_candle_info.HeaderColor(clr);
   m_tooltip_candle_info.Moving(x, tip_y);
   m_tooltip_candle_info.ShowTooltip();   // ClearStrings() above already reset alpha, so this repaints even if still fully visible from the PREVIOUS pattern
  }
 //+------------------------------------------------------------------+
 //| Hides the currently-shown Alt+hover pattern bitmap + label, if    |
 //| any. Hides rather than deletes - the CGCnvPatternBitmap object    |
 //| stays cached on its CBarPattern so re-hovering the same candle    |
 //| later doesn't need to recreate it.                                |
 //+------------------------------------------------------------------+
 void CGUIPannel::HidePatternBitmapAtBar(void)
  {
   m_tooltip_candle_info.FadeOutTooltip();
   if(m_pattern_bitmap_shown == NULL) return;
   if(m_pattern_bitmap_shown.HasBitmap() && m_pattern_bitmap_shown.GetBitmap().IsVisible())
    {
     m_pattern_bitmap_shown.GetBitmap().Hide();
     ::ChartRedraw(m_chart_id);
    }
   m_pattern_bitmap_shown = NULL;
  }
 void CGUIPannel::OnEvent_Window_CandleInfor(const int id,const long &lparam, const double &dparam, const string &sparam)
  {
    m_window_candle_infomation.CheckMouseFocus();
    if(m_active_window_index == WindowIdx(m_window_candle_infomation) && !m_window_candle_infomation.MouseFocus())
     {
      HideWindow_CandleInfo();//CreateWindow_CandleInfo();
      m_candle_info_shown_bar = 0;
     }
   //Handle on Mouse Move
     if(id == CHARTEVENT_MOUSE_MOVE)
      {
       //Handle on Candle Infor
        bool popup_shown = (m_candle_info_shown_bar != 0);
        m_window_candle_infomation.CheckMouseFocus();
        bool over_candle_info = m_window_candle_infomation.MouseFocus();   // computed once, reused below - was called twice
        if(popup_shown && over_candle_info)
         {
            // --- Stay open, don't touch bar_time - let the table's native dispatch (now
            // --- routed to it via m_active_window_index) handle the scrollbar/clicks. Checked
            // --- BEFORE the CalculateAtCandle() gate below on purpose (Anhnt, 2026-08-31): the
            // --- popup window sits wherever it was positioned on screen, not necessarily over
            // --- any candle - gating this on "over a candle" too would make it impossible to
            // --- reach into the popup's own scrollbar/table without it vanishing first.
         }
        else if(popup_shown && !over_candle_info)
         {
            // --- Mouse left the popup rect -> hide it, reset to m_window_main dispatch.
            HideWindow_CandleInfo();
            m_candle_info_shown_bar = 0;
         }
        else if(id == CHARTEVENT_MOUSE_MOVE && CalculateAtCandle() != 0 && !MouseOverAnyGUIWindow())
         {
          // --- Popup isn't up right now (both branches above exhaustively handle
          // --- popup_shown==true). Shift and Alt are mutually exclusive (Anhnt, 2026-08-31, per
          // --- user design) - each one hides the OTHER's display when pressed; neither one
          // --- hides itself just because its own key was released or the cursor moved off the
          // --- candle (deliberate - CandleInfo already handles its own "stay open" above, and
          // --- the PatternBitmap stays "pinned" until the user actively picks CandleInfo
          // --- instead). CalculateAtCandle() is called again per key below (not reused from the
          // --- gate above) - a deliberate trade-off so the Shift/Alt work only ever runs at all
          // --- when the gate confirms we're over a real candle, not on every single mouse move.
          // --- !MouseOverAnyGUIWindow() added (Anhnt, 2026-08-31): ChartXYToTimePrice() doesn't
          // --- know our own panels are covering the chart there, so without this, hovering the
          // --- Positions/Setting table while Alt is held rendered a phantom pattern-bitmap/tooltip
          // --- UNDER the panel (the "black smear" bug).
           if(m_keys.KeyShiftState())
            {
             HidePatternBitmapAtBar();
             datetime bar_time = CalculateAtCandle();
             bool has_signal = RefreshWindow_CandleInfo(bar_time);
             if(has_signal)
              {
               m_candle_info_shown_bar = bar_time;
               ShowWindow_CandleInfo(m_mouse.X(), m_mouse.Y());
              }
            }
           else if(m_keys.KeyAltState())
            {
             HideWindow_CandleInfo();
             datetime bar_time = CalculateAtCandle();
             string sym = ::Symbol();
             ENUM_TIMEFRAMES tf = (ENUM_TIMEFRAMES)::Period();
             int shift = ::iBarShift(sym, tf, bar_time, true);
           // --- MY DEBUG: dump OHLC + the exact 3 ratios CBarPatternControlHammer::FindPattern()
           // --- checks (body<=0.35, lower_shadow>=0.55, upper_shadow<=0.10, all as % of full
           // --- High-Low range) - verifies whether a hovered candle SHOULD actually qualify
           // --- as Hammer (Anhnt, 2026-08-29).
            {
              double o = ::iOpen(sym, tf, shift), h = ::iHigh(sym, tf, shift),
                     l = ::iLow(sym, tf, shift),  cl = ::iClose(sym, tf, shift);
              double full = h - l;
              if(full > 0)
              {
                double body  = ::MathAbs(cl - o);
                double lower = ::MathMin(o, cl) - l;
                double upper = h - ::MathMax(o, cl);
                ::Print("MY DEBUG GUIPannel::OnEvent MOUSE_MOVE: bar_time=", ::TimeToString(bar_time, TIME_DATE|TIME_MINUTES),
                     " O=", o, " H=", h, " L=", l, " C=", cl,
                     " body%=", ::DoubleToString(body/full*100, 1),
                     " lower_shadow%=", ::DoubleToString(lower/full*100, 1),
                     " upper_shadow%=", ::DoubleToString(upper/full*100, 1),
                     " Hammer_needs(body<=35, lower>=55, upper<=10)");
              }
             }
          // --- MY DEBUG: dump every REAL detected pattern instance at this exact bar (same
          // --- source CheckCandlePatternAlerts()'s CloseBar path and the CSV log read) - lets
          // --- us cross-check the ratio math above against what the real Alert pipeline
          // --- actually sees (Anhnt, 2026-08-29). Each line is now tagged table_enabled=YES/NO
          // --- (same PatternSignalBuy/Sell + Symbol-TF gate ShowPatternBitmapAtBar uses) and a
          // --- final "=> Chart shows" line reproduces its exact best-of pick, so with only one
          // --- row checked on the Setting table this collapses to a clean 1:1 against the Chart
          // --- bitmap/tooltip - the point being to verify each pattern's name+math in isolation
          // --- before ever turning several on at once for live use.
           {
            CArrayObj *all_pat_dbg = m_BarTimeSeriesCollection.GetListAllPatterns();
            int found_dbg = 0;
            CSymbolTFSetting *symtf_dbg = (m_SymbolTFManager != NULL) ? m_SymbolTFManager.FindByIdentity(sym, tf) : NULL;
            bool symtf_buy_dbg  = (symtf_dbg != NULL) ? symtf_dbg.BuySignal()  : false;
            bool symtf_sell_dbg = (symtf_dbg != NULL) ? symtf_dbg.SellSignal() : false;
            CBarPattern *best_dbg = NULL;
            int best_candles_dbg = 0;
            if(all_pat_dbg != NULL)
             {
              int total_dbg = all_pat_dbg.Total();
              for(int pi = 0; pi < total_dbg; pi++)
               {
                CBarPattern *p_dbg = all_pat_dbg.At(pi);
                if(p_dbg == NULL || p_dbg.Symbol() != sym || p_dbg.Timeframe() != tf || p_dbg.Time() != bar_time) continue;
                found_dbg++;
                ENUM_PATTERN_DIRECTION pdir_dbg = p_dbg.Direction();
                bool is_buy_dbg  = (pdir_dbg == PATTERN_DIRECTION_BULLISH);
                bool is_sell_dbg = (pdir_dbg == PATTERN_DIRECTION_BEARISH);
                bool enabled_dbg = (is_buy_dbg  && PatternSignalBuy(p_dbg.TypePattern())  && symtf_buy_dbg) ||
                                   (is_sell_dbg && PatternSignalSell(p_dbg.TypePattern()) && symtf_sell_dbg);
                ::Print("MY DEBUG GUIPannel::OnEvent MOUSE_MOVE real pattern #", found_dbg, ": type=", EnumToString(p_dbg.TypePattern()),
                        " name=", p_dbg.GetProperty(PATTERN_PROP_NAME),
                        " direction=", EnumToString(pdir_dbg),
                        " table_enabled=", (enabled_dbg ? "YES" : "no"));
                if(enabled_dbg)
                 {
                  int n_dbg = (int)p_dbg.Candles();
                  if(best_dbg == NULL || n_dbg > best_candles_dbg) { best_dbg = p_dbg; best_candles_dbg = n_dbg; }
                 }
               }
             }
            if(found_dbg == 0)
              ::Print("MY DEBUG GUIPannel::OnEvent MOUSE_MOVE: no real detected pattern at this closed bar (may be live bar-0, or genuinely no match)");
            ::Print("MY DEBUG GUIPannel::OnEvent MOUSE_MOVE => Chart shows: ",
                    (best_dbg != NULL) ? best_dbg.GetProperty(PATTERN_PROP_NAME) : "(none - no table-enabled pattern matches here)");
           }
           ShowPatternBitmapAtBar(bar_time);
          }
         }
      }
  }
#endif // CGUIPANNEL_CANDLEINFO_WINDOWS_MQH
