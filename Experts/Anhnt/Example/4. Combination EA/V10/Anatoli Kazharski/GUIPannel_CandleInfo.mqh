//+------------------------------------------------------------------+
//|                                         GUIPannel_CandleInfo.mqh |
//| Implementation of function Candle Info                           |
//| Window m_window_candle_infomation                               |
//| CTooltip m_tooltip_candle_info
//+------------------------------------------------------------------+
#ifndef CGUIPANNEL_CANDLEINFO_MQH
#define CGUIPANNEL_CANDLEINFO_MQH
#include "GUIPannel.mqh"
//For m_window_candle_infomation
 //+------------------------------------------------------------------+
 //| True while the current mouse position is inside the candle info  |
 //| popup's own screen rect - used to suspend the Shift + hover bar  |
 //| re-derivation (see OnEvent) so scrolling/clicking the popup's own|
 //| table doesn't fight with it.                                     |
 //+------------------------------------------------------------------+
 bool CGUIPannel::MouseOverCandleInfoWindow(void)
  {
   int x = m_window_candle_infomation.X();
   int y = m_window_candle_infomation.Y();
   return(m_mouse.X() >= x && m_mouse.X() <= x + m_window_candle_infomation.XSize() &&
          m_mouse.Y() >= y && m_mouse.Y() <= y + m_window_candle_infomation.YSize());
  }
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
    // --- No Symbol column - this popup is always scoped to the CURRENT chart's own symbol.
    // --- Time is needed because this popup spans EVERY tracked TF of the symbol, not just the
    // --- hovered bar's own TF - a lower-TF indicator can flip at a time inside the hovered
    // --- bar's span without landing exactly on its open time (see RefreshCandleInfoWindow).
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
    // --- y=WINDOW_CAPTION_HEIGHT, not 0 - CWindow's child coordinate space starts at the
    // --- window's absolute top-left, INCLUDING the caption bar (same convention as every
    // --- other table placed directly on a CWindow, e.g. CreateTable_SymbolTFSetting(0,22));
    // --- y=0 here made the table paint straight over the "Signals at Bar" title.
     if(!m_table_candle_information_atBar.CreateTable(0, WINDOW_CAPTION_HEIGHT)) return (false);
     m_table_candle_information_atBar.SetHeaderText(0, "Time");
     m_table_candle_information_atBar.SetHeaderText(1, "TF");
     m_table_candle_information_atBar.SetHeaderText(2, "Information");
    // --- Collapse the TableSize() padding down to a single blank baseline row, same
    // --- convention as CreateTable_SymbolTFSetting.
     m_table_candle_information_atBar.DeleteAllRows();
     CWndContainer::AddToElementsArray(WindowIdx(m_window_candle_infomation), m_table_candle_information_atBar);
    // --- Alt+hover pattern-name tooltip (ShowCandlePatternInfo) - MainPointer/ElementPointer
    // --- only satisfy CTooltip::CreateTooltip()'s requirements; actual position is always
    // --- overridden via Moving(x,y) before each show (arbitrary chart point per hover, not
    // --- "below an anchor element" like a normal Library tooltip). NOT added to any
    // --- elements array on purpose - stays outside native OnEvent auto show/hide dispatch,
    // --- fully driven by our own Alt+hover logic below.
     m_tooltip_candle_info.MainPointer(m_window_main);
     m_tooltip_candle_info.ElementPointer(m_window_main);
     m_tooltip_candle_info.XSize(160);
     m_tooltip_candle_info.YSize(20);
     if(!m_tooltip_candle_info.CreateTooltip()) return (false);
     m_tooltip_candle_info.Show();   // attach once (OBJ_ALL_PERIODS); ShowTooltip()/FadeOutTooltip() drive visible content from here on
     return (true);
  }
 //+------------------------------------------------------------------+
 //| Snaps the popup so the cursor is ALREADY inside it the instant it |
 //| appears (CANDLE_INFO_CURSOR_INSET, not a gap) - BugNote            |
 //| 2026-07-16: first tried placing the popup NEAR the cursor with a  |
 //| small gap, but on a zoomed-out TF that gap still covers OTHER      |
 //| candles - crossing it to reach the popup flipped bar_time (and    |
 //| re-triggered this same reposition) along the way, so the popup    |
 //| kept jumping just out of reach. Zero distance to cross means      |
 //| MouseOverCandleInfoWindow() is already true before any movement.  |
 //| CWindow has no "MainPointer" parent, so its own Moving(x,y)       |
 //| overload takes absolute coords directly - but it only updates    |
 //| m_canvas, not the base m_x/m_y CElementBase stores (confirmed by  |
 //| reading Window.mqh), so those must be set explicitly here or      |
 //| MouseOverCandleInfoWindow()/future calls would read stale coords. |
 //| The table needs NO manual repositioning: it was created via       |
 //| MainPointer(m_window_candle_infomation), so CElement::Moving()    |
 //| (its own, argument-less overload) re-derives its position from    |
 //| m_main.X()/Y() - i.e. the window's now-updated position - on its  |
 //| own.                                                              |
 //+------------------------------------------------------------------+
 void CGUIPannel::RepositionWindow_CandleInfo(const int cursor_x, const int cursor_y)
  {
   int chart_w = (int)::ChartGetInteger(m_chart_id, CHART_WIDTH_IN_PIXELS);
   int chart_h = (int)::ChartGetInteger(m_chart_id, CHART_HEIGHT_IN_PIXELS);
   // --- Cursor sits INSET pixels inside the popup's LEFT edge (popup extends mostly to the
   // --- right of the cursor) - flip so cursor sits INSET pixels inside the RIGHT edge
   // --- instead if that would run off the chart's right edge (popup extends to the left).
   // --- Either way the cursor is ALREADY inside the rect - see CANDLE_INFO_CURSOR_INSET.
   int x = cursor_x - CANDLE_INFO_CURSOR_INSET;
   if(x + CANDLE_INFO_WINDOW_W > chart_w)
      x = cursor_x - CANDLE_INFO_WINDOW_W + CANDLE_INFO_CURSOR_INSET;
   if(x < 0) x = 0;
   // --- Same idea vertically - cursor INSET pixels inside the top edge, flipping to sit
   // --- inside the bottom edge if that would run off the chart's bottom.
   int y = cursor_y - CANDLE_INFO_CURSOR_INSET;
   if(y + CANDLE_INFO_WINDOW_H > chart_h)
      y = cursor_y - CANDLE_INFO_WINDOW_H + CANDLE_INFO_CURSOR_INSET;
   if(y < 0) y = 0;
   m_window_candle_infomation.X(x);
   m_window_candle_infomation.Y(y);
   m_window_candle_infomation.Moving(x, y);
   m_table_candle_information_atBar.Moving();
  }
 // For candle info popup (BugNote 7.2)
 //+------------------------------------------------------------------+
 //| Shows the popup AND hands it native mouse/keyboard dispatch by    |
 //| making it the active window (BugNote 2026-07-16). CWndEvents::    |
 //| CheckElementsEvents() (WndEvents.mqh, protected - accessible from |
 //| this subclass, no Library edit needed) only ever routes           |
 //| CheckMouseFocus()/OnEvent() to m_active_window_index's elements,  |
 //| so without this the popup's table (its scrollbar included) never |
 //| receives a native event no matter how it's shown. m_window_main   |
 //| going quiet while this is active is not a real trade-off here:    |
 //| the ONLY thing that keeps this popup active is the cursor         |
 //| physically sitting inside it (see MouseOverCandleInfoWindow), so   |
 //| m_window_main can't be receiving meaningful mouse input at the    |
 //| same moment anyway. CWndEvents::Show(window_index) (also          |
 //| protected) cascades to m_main_elements - i.e. the table - on its   |
 //| own, so no manual table.Show() call is needed here either.        |
 //+------------------------------------------------------------------+
 void CGUIPannel::ShowWindow_CandleInfo(const int cursor_x, const int cursor_y)
  {
     RepositionWindow_CandleInfo(cursor_x, cursor_y);
     // --- Remember whoever was active before the popup steals dispatch, so Hide can hand it
     // --- back correctly - hardcoding m_window_main here was wrong whenever e.g. the Setting
     // --- Window was the real owner: a hover-then-leave while Setting was open used to strand
     // --- active dispatch on m_window_main forever, leaving Setting's checkboxes dead until it
     // --- was manually reopened (Anhnt, 2026-08-29). Guarded so a re-show while already shown
     // --- (moving to a different bar without leaving the popup) doesn't overwrite the saved
     // --- value with CandleInfo itself.
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
 //+------------------------------------------------------------------+
 //| Fills the popup with every (Indicator, TF, Time) flip that lands |
 //| inside the hovered CURRENT-CHART bar's time SPAN [bar_time,      |
 //| bar_time + PeriodSeconds()) - not just flips on the hovered bar's |
 //| own TF. This popup spans EVERY TF tracked for the symbol, and a  |
 //| lower-TF indicator can flip at a time that falls inside the      |
 //| hovered bar's span without landing exactly on its open time, so  |
 //| each qualifying flip becomes its OWN row (same indicator can     |
 //| appear more than once if it flipped twice within the span).      |
 //| Unlike BuildAndWriteSignalBridge/m_table_indicator_SymbolTFValue  |
 //| show the PERSISTED state carried forward from the last flip),    |
 //| this popup answers "what flipped DURING this bar" - anything     |
 //| outside the span is left out entirely.                           |
 //|                                                                    |
 //| Returns true if the bar has at least one flip (i.e. the popup has |
 //| something to show) - false means "nothing happened at this bar",  |
 //| telling the caller NOT to show the popup for it at all.           |
 //+------------------------------------------------------------------+
 bool CGUIPannel::RefreshWindow_CandleInfo(const datetime bar_time)
  {
   if(m_IndicatorsCollection == NULL || m_timeSeriesEngine == NULL || m_BarTimeSeriesCollection == NULL ||
      m_indicator_template_manager == NULL || m_SymbolTFManager == NULL)
      return false;
   datetime next_bar_time = bar_time + ::PeriodSeconds();
   string sym = ::Symbol();
   SIndicatorCatalogItem catalog[];
   GetIndicatorCatalog(catalog);
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
             row_label[count] = BuildIndicatorTextLabel(ind_type, ind_params, catalog);
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
                row_label[count] = BuildIndicatorTextLabel(ind_type, ind_params, catalog)+ ((li == BBAND_LINE_UPPER) ? " Upper" : " Lower");
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

#endif // CGUIPANNEL_CANDLEINFO_MQH
