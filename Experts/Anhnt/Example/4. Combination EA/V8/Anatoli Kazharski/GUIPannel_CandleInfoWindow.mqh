//+------------------------------------------------------------------+
//|                                   GUIPannel_CandleInfoWindow.mqh |
//| Implementation of function Candle Info Window m_window_candle_infomation|
//+------------------------------------------------------------------+
#ifndef CGUIPANNEL_CANDLEINFO_WINDOW_MQH
#define CGUIPANNEL_CANDLEINFO_WINDOW_MQH
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
 void CGUIPannel::RepositionCandleInfoWindow(const int cursor_x, const int cursor_y)
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
 void CGUIPannel::ShowCandleInfoPopup(const int cursor_x, const int cursor_y)
  {
     RepositionCandleInfoWindow(cursor_x, cursor_y);
     m_active_window_index = WindowIdx(m_window_candle_infomation);
     Show(m_active_window_index);
     FormAvailableElementsArray();
  }
 //+------------------------------------------------------------------+
 //| Hides the popup and hands native dispatch back to m_window_main.  |
 //+------------------------------------------------------------------+
 void CGUIPannel::HideCandleInfoPopup(void)
  {
     m_window_candle_infomation.Hide();
     m_table_candle_information_atBar.Hide();
     m_active_window_index = WindowIdx(m_window_main);
     FormAvailableElementsArray();
  }
 //+------------------------------------------------------------------+
 //| Creates the Ctrl+hover "Signal at this bar" popup - fixed at the |
 //| chart's top-right corner, content-only (no drag-to-follow-cursor;|
 //| CWindow has no simple move-to-XY API for that, only manual drag  |
 //| state gated behind IsMovable/mouse-button-held).                 |
 //+------------------------------------------------------------------+
 bool CGUIPannel::CreateWindowCandleInfo(void)
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
    // --- other table placed directly on a CWindow, e.g. CreateTableSymbolTFSetting(0,22));
    // --- y=0 here made the table paint straight over the "Signals at Bar" title.
     if(!m_table_candle_information_atBar.CreateTable(0, WINDOW_CAPTION_HEIGHT)) return (false);
     m_table_candle_information_atBar.SetHeaderText(0, "Time");
     m_table_candle_information_atBar.SetHeaderText(1, "TF");
     m_table_candle_information_atBar.SetHeaderText(2, "Information");
    // --- Collapse the TableSize() padding down to a single blank baseline row, same
    // --- convention as CreateTableSymbolTFSetting.
     m_table_candle_information_atBar.DeleteAllRows();
     CWndContainer::AddToElementsArray(WindowIdx(m_window_candle_infomation), m_table_candle_information_atBar);
     return (true);
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
 bool CGUIPannel::RefreshCandleInfoWindow(const datetime bar_time)
  {
   if(m_IndicatorsCollection == NULL || m_time_series_engine == NULL || m_BarTimeSeriesCollection == NULL)
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
       CArrayObj *ind_list = m_IndicatorsCollection.GetListIndBySymbol(sym);
       ind_list = CTimeseriesSelect::ByIndicatorProperty(ind_list, INDICATOR_PROP_TIMEFRAME, s.Timeframe(), EQUAL);
       int ind_total = (ind_list != NULL) ? ind_list.Total() : 0;
       for(int ii = 0; ii < ind_total; ii++)
        {
         CIndicatorDE *ind = ind_list.At(ii);
         if(ind == NULL) continue;
         // signal is BORROWED - CSignalsCollection owns it
          CSignalBase *signal = m_time_series_engine.GetSignalsCollection().GetOrCreateSignal(ind);
          if(signal == NULL) continue;
         // --- history is oldest->newest; walk backward and stop once we're before the span -
         // --- collect EVERY flip inside the span (usually 0 or 1, but never assume 1).
          for(int h = signal.HistoryTotal() - 1; h >= 0; h--)
           {
            datetime ht = signal.HistoryTime(h);
            if(ht >= next_bar_time) continue;
            if(ht < bar_time) break;

            //ArrayResize(row_ind,  count + 1);
             ArrayResize(row_label,  count + 1);
             ArrayResize(row_tf,   count + 1);
             ArrayResize(row_dir,  count + 1);
             ArrayResize(row_time, count + 1);
             ArrayResize(row_source, count + 1);
            //row_ind[count]  = ind;
             row_label[count] = BuildIndicatorLabel(ind, catalog);
             row_tf[count]   = tf_text;
             row_dir[count]  = signal.HistoryDir(h);
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

               //ArrayResize(row_ind,  count + 1);
                ArrayResize(row_label, count + 1);
                ArrayResize(row_tf,   count + 1);
                ArrayResize(row_dir,  count + 1);
                ArrayResize(row_time, count + 1);
                ArrayResize(row_source, count + 1);
               //row_ind[count]  = ind;
                row_label[count] = BuildIndicatorLabel(ind, catalog)+ ((li == BBAND_LINE_UPPER) ? " Upper" : " Lower");
                row_tf[count]   = tf_text;
                row_dir[count]  = bb.LineHistoryDir(li, h);
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

#endif // CGUIPANNEL_CANDLEINFO_WINDOW_MQH
