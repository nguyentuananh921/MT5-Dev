//+------------------------------------------------------------------+
//|                                 GUIPannel_CandleInfo_Windows.mqh |
//| Shift+hover on a bar: signals popup, pattern box and its tooltip  |
//+------------------------------------------------------------------+
#ifndef CGUIPANNEL_CANDLEINFO_WINDOWS_MQH
#define CGUIPANNEL_CANDLEINFO_WINDOWS_MQH
#include "GUIPannel.mqh"
 bool CGUIPannel::MouseOverAnyGUIWindow(const int px, const int py)
  {
   CWindow *windows[5];
   windows[0] = GetPointer(m_window_main);
   windows[1] = GetPointer(m_window_setting_timeseries);
   windows[2] = GetPointer(m_window_setting_trading);
   windows[3] = GetPointer(m_window_setting_markerAndSound);
   windows[4] = GetPointer(m_window_candle_infomation);
   for(int w = 0; w < ::ArraySize(windows); w++)
      if(windows[w].IsVisible() && windows[w].CursorInsideElement(px, py))
         return true;
   return false;
  }
 datetime CGUIPannel::CalculateAtCandle(const int x, const int y)
  {
   datetime t; double price; int sub_window;
   if(!::ChartXYToTimePrice(m_chart_id, x, y, sub_window, t, price) || sub_window != m_subwin)
      return 0;
   int shift = ::iBarShift(::Symbol(), (ENUM_TIMEFRAMES)::Period(), t, false);
   if(shift < 0) return 0;
   return ::iTime(::Symbol(), (ENUM_TIMEFRAMES)::Period(), shift);
  }
 //+------------------------------------------------------------------+
 //| Popup: 3 cols Time | TF (+ source icon) | Information (+ arrow)  |
 //+------------------------------------------------------------------+
 bool CGUIPannel::CreateWindow_CandleInfo(void)
  {
   m_window_candle_infomation.FontSize(DEF_FONT_SIZE);
   m_window_candle_infomation.IsMovable(false);
   m_window_candle_infomation.ResizeMode(false);
   m_window_candle_infomation.CloseButtonIsUsed(false);
   m_window_candle_infomation.CollapseButtonIsUsed(false);
   m_window_candle_infomation.TooltipsButtonIsUsed(false);
   m_window_candle_infomation.FullscreenButtonIsUsed(false);
   if(!m_window_candle_infomation.CreateWindow(m_chart_id, m_subwin, "Signals at Bar", 0, 0, CANDLE_INFO_WINDOW_W, CANDLE_INFO_WINDOW_H))
      return false;
   m_table_candle_information_atBar.TableSize(COLUMNS_CANDLEINFO_TOTAL, 0);
   m_table_candle_information_atBar.View().ShowHeaders(true);
   m_table_candle_information_atBar.View().SelectableRow(true);
   m_table_candle_information_atBar.View().LightsHover(true);
   m_table_candle_information_atBar.View().IsSortMode(false);
   m_window_candle_infomation.AddChild(&m_table_candle_information_atBar);
   if(!m_table_candle_information_atBar.CreateTable(m_chart_id, m_subwin, "TableCandleInfo", 1, WINDOW_CAPTION_HEIGHT,
                                                    CANDLE_INFO_WINDOW_W - 2, CANDLE_INFO_WINDOW_H - WINDOW_CAPTION_HEIGHT - 1))
      return false;
   CTableHeaderView *header = m_table_candle_information_atBar.View().GetHeaderViewPointer();
   header.ColumnsWidth(CANDLEINFO_WIDTH);
   header.TextAlign(CANDLEINFO_HEADER_ALIGN);
   header.TextXOffset(CANDLEINFO_TEXT_X_OFFSET);
   header.ImageXOffset(CANDLEINFO_IMAGE_X_OFFSET);
   m_table_candle_information_atBar.View().IsFilterMode(COL_CI_SOURCE, true);
   m_table_candle_information_atBar.SetHeaderText(COL_CI_TIME, "Time");
   m_table_candle_information_atBar.SetHeaderText(COL_CI_SOURCE, "");
   m_table_candle_information_atBar.SetHeaderText(COL_CI_TF, "TF");
   m_table_candle_information_atBar.SetHeaderText(COL_CI_INFO, "Information");
   m_table_candle_information_atBar.View().Rebuild(true);
   return true;
  }
 //+------------------------------------------------------------------+
 //| Popup right next to the bar column under the cursor, flipped to  |
 //| the left side when it would leave the chart                       |
 //+------------------------------------------------------------------+
 void CGUIPannel::RepositionWindow_CandleInfo(const int cursor_x, const int cursor_y)
  {
   int chart_w = (int)::ChartGetInteger(m_chart_id, CHART_WIDTH_IN_PIXELS);
   int chart_h = (int)::ChartGetInteger(m_chart_id, CHART_HEIGHT_IN_PIXELS);
    int window_w = m_window_candle_infomation.Width();
    int window_h = m_window_candle_infomation.Height();
   int slot_w  = (int)(1 << (int)::ChartGetInteger(m_chart_id, CHART_SCALE));
   int left = cursor_x, right = cursor_x, top = cursor_y - CANDLE_INFO_CURSOR_INSET;
   int bar_x = 0, bar_y = 0;
   if(::ChartTimePriceToXY(m_chart_id, m_subwin, m_candle_info_shown_bar, 0, bar_x, bar_y))
    {
     left  = bar_x - slot_w / 2;
     right = bar_x + slot_w / 2;
    }
   int x = right + 1;
   if(x + window_w > chart_w)
      x = left - window_w;
   if(x < 0) x = 0;
   int max_x = chart_w - window_w;
   if(max_x < 0) max_x = 0;
   if(x > max_x) x = max_x;
   int y = top;
   if(y + window_h > chart_h)
      y = chart_h - window_h;
   if(y < 0) y = 0;
   int max_y = chart_h - window_h;
   if(max_y < 0) max_y = 0;
   if(y > max_y) y = max_y;
   m_window_candle_infomation.Move(x, y);
  }
 void CGUIPannel::ShowWindow_CandleInfo(const int cursor_x, const int cursor_y)
  {
   RepositionWindow_CandleInfo(cursor_x, cursor_y);
   m_window_candle_infomation.Show();
   ::ChartRedraw(m_chart_id);
  }
 void CGUIPannel::HideWindow_CandleInfo(void)
  {
   m_candle_info_shown_bar = 0;
   if(!m_window_candle_infomation.IsVisible()) return;
   m_window_candle_infomation.Hide();
   ::ChartRedraw(m_chart_id);
  }
 //+------------------------------------------------------------------+
 //| Indicator flips, Patterns and Swings inside [bar_time, next bar), |
 //| gated by the same Buy/Sell settings as the markers                |
 //+------------------------------------------------------------------+
 bool CGUIPannel::RefreshWindow_CandleInfo(const datetime bar_time)
  {
   if(m_IndicatorsCollection == NULL || m_SignalsCollection == NULL || m_BarTimeSeriesCollection == NULL ||
      m_indicator_template_manager == NULL || m_SymbolTFManager == NULL)
      return false;
   datetime next_bar_time = bar_time + ::PeriodSeconds();
   string sym = ::Symbol();
   CBarTimeSeriesDE *bts = m_BarTimeSeriesCollection.GetTimeseries(sym);
   CArrayObj *series_list = (bts != NULL) ? bts.GetListSeries() : NULL;
   int series_total = (series_list != NULL) ? series_list.Total() : 0;
   //--- TFs ascending M1..MN1
    int order[];
    ::ArrayResize(order, series_total);
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
   string          row_label[];
   string          row_tf[];
   ENUM_SIGNAL_DIR row_dir[];
   datetime        row_time[];
   int             row_source[];   // 0 = Indicator, 1 = Pattern, 2 = Swing
   int count = 0;
   CArrayObj *ind_list = m_IndicatorsCollection.GetList();   // filtered inline below - no Select per mouse move
   int ind_total = (ind_list != NULL) ? ind_list.Total() : 0;
   for(int ti = 0; ti < series_total; ti++)
    {
     CBarSeriesDE *s = series_list.At(order[ti]);
     if(s == NULL) continue;
     ENUM_TIMEFRAMES tf = s.Timeframe();
     string tf_text = TimeframeDescription(tf);
     CSymbolTFSetting *symtf_entry = m_SymbolTFManager.FindByIdentity(sym, tf);
     bool symtf_buy  = (symtf_entry != NULL) ? symtf_entry.BuySignal()  : false;
     bool symtf_sell = (symtf_entry != NULL) ? symtf_entry.SellSignal() : false;
     for(int ii = 0; ii < ind_total; ii++)
      {
       CIndicatorDE *ind = ind_list.At(ii);
       if(ind == NULL || ind.Symbol() != sym || ind.Timeframe() != tf) continue;
       ENUM_INDICATOR ind_type = ind.TypeIndicator();
       MqlParam ind_params[];
       ind.GetMqlParams(ind_params);
       CIndicatorSetting ind_label_setting;
       ind_label_setting.TypeEnum(ind_type);
       ind_label_setting.SetRawParams(ind_params);
       CIndicatorSetting *ind_entry = m_indicator_template_manager.FindByIdentity(ind_type, ind_params);
       bool ind_buy  = (ind_entry != NULL) ? ind_entry.BuySignal()  : false;
       bool ind_sell = (ind_entry != NULL) ? ind_entry.SellSignal() : false;
       CSignalBase *signal = m_SignalsCollection.GetOrCreateSignal(ind);
       if(signal == NULL) continue;
       //--- BBands rows carry the line right after the indicator name: -MB / -UB / -LB
       string row_ind_label = ind_label_setting.DisplayLabel();
       string label_upper = "", label_lower = "";
       if(ind_type == IND_BANDS)
        {
         int cut = ::StringFind(row_ind_label, "  (");
         if(cut < 0) cut = ::StringLen(row_ind_label);
         string head = ::StringSubstr(row_ind_label, 0, cut);
         string tail = ::StringSubstr(row_ind_label, cut);
         label_upper   = head + "-UB" + tail;
         label_lower   = head + "-LB" + tail;
         row_ind_label = head + "-MB" + tail;
        }
       //--- History is oldest->newest: walk back, collect every flip inside the span
       for(int h = signal.HistoryTotal() - 1; h >= 0; h--)
        {
         datetime ht = signal.HistoryTime(h);
         if(ht >= next_bar_time) continue;
         if(ht < bar_time) break;
         ENUM_SIGNAL_DIR d = signal.HistoryDir(h);
         if(d == SIGNAL_BUY  && !(ind_buy  && symtf_buy))  continue;
         if(d == SIGNAL_SELL && !(ind_sell && symtf_sell)) continue;
         ::ArrayResize(row_label,  count + 1);
         ::ArrayResize(row_tf,     count + 1);
         ::ArrayResize(row_dir,    count + 1);
         ::ArrayResize(row_time,   count + 1);
         ::ArrayResize(row_source, count + 1);
         row_label[count]  = row_ind_label;
         row_tf[count]     = tf_text;
         row_dir[count]    = d;
         row_time[count]   = ht;
         row_source[count] = 0;
         count++;
        }
       //--- BBands: Upper/Lower line crosses too; Mid is the primary signal, already collected above
       if(ind_type == IND_BANDS)
        {
         CSignalBollinger *bb = (CSignalBollinger*)signal;
         for(int li = 0; li < 2; li++)
          {
           for(int h = bb.LineHistoryTotal(li) - 1; h >= 0; h--)
            {
             datetime ht = bb.LineHistoryTime(li, h);
             if(ht >= next_bar_time) continue;
             if(ht < bar_time) break;
             ENUM_SIGNAL_DIR ld = bb.LineHistoryDir(li, h);
             if(ld == SIGNAL_BUY  && !(ind_buy  && symtf_buy))  continue;
             if(ld == SIGNAL_SELL && !(ind_sell && symtf_sell)) continue;
             ::ArrayResize(row_label,  count + 1);
             ::ArrayResize(row_tf,     count + 1);
             ::ArrayResize(row_dir,    count + 1);
             ::ArrayResize(row_time,   count + 1);
             ::ArrayResize(row_source, count + 1);
             row_label[count]  = (li == BBAND_LINE_UPPER) ? label_upper : label_lower;
             row_tf[count]     = tf_text;
             row_dir[count]    = ld;
             row_time[count]   = ht;
             row_source[count] = 0;
             count++;
            }
          }
        }
      }
    }
   //--- Candle Patterns
    CArrayObj *all_patterns = m_BarTimeSeriesCollection.GetListAllPatterns();
    int pat_total = (all_patterns != NULL) ? all_patterns.Total() : 0;
    for(int p = 0; p < pat_total; p++)
     {
      CBarPattern *pat = all_patterns.At(p);
      if(pat == NULL || pat.Symbol() != sym) continue;
      datetime pt = pat.Time();
      if(pt < bar_time || pt >= next_bar_time) continue;
      ENUM_TIMEFRAMES ptf = pat.Timeframe();
      ENUM_PATTERN_DIRECTION pdir = pat.Direction();
      ENUM_SIGNAL_DIR dir = (pdir == PATTERN_DIRECTION_BULLISH) ? SIGNAL_BUY :
                           (pdir == PATTERN_DIRECTION_BEARISH) ? SIGNAL_SELL : SIGNAL_NONE;
      if(dir == SIGNAL_NONE) continue;
      CSymbolTFSetting *pat_symtf = m_SymbolTFManager.FindByIdentity(sym, ptf);
      bool pat_symtf_buy  = (pat_symtf != NULL) ? pat_symtf.BuySignal()  : false;
      bool pat_symtf_sell = (pat_symtf != NULL) ? pat_symtf.SellSignal() : false;
      if(dir == SIGNAL_BUY  && !(PatternSignalBuy(pat.TypePattern())  && pat_symtf_buy))  continue;
      if(dir == SIGNAL_SELL && !(PatternSignalSell(pat.TypePattern()) && pat_symtf_sell)) continue;
      uint candles = pat.Candles();
      string pat_name = pat.GetProperty(PATTERN_PROP_NAME);
      if(pat_name == "") pat_name = ::EnumToString(pat.TypePattern());
      ::ArrayResize(row_label,  count + 1);
      ::ArrayResize(row_tf,     count + 1);
      ::ArrayResize(row_dir,    count + 1);
      ::ArrayResize(row_time,   count + 1);
      ::ArrayResize(row_source, count + 1);
      row_label[count]  = ((candles > 0) ? "[" + ::IntegerToString(candles) + "B] " : "") + pat_name;
      row_tf[count]     = TimeframeDescription(ptf);
      row_dir[count]    = dir;
      row_time[count]   = pt;
      row_source[count] = 1;
      count++;
     }
   //--- Swings whose pivot bar is in the span
    CArrayObj *all_swings = m_BarTimeSeriesCollection.GetListAllSwings();
    int sw_total = (all_swings != NULL && m_SwingSetting != NULL) ? all_swings.Total() : 0;
    for(int w = 0; w < sw_total; w++)
     {
      CBarSwing *sw = all_swings.At(w);
      if(sw == NULL || sw.Symbol() != sym) continue;
      datetime st = sw.Time();
      if(st < bar_time || st >= next_bar_time) continue;
      if(!m_SwingSetting.SignalShow(sw.TypeSwing())) continue;
      ::ArrayResize(row_label,  count + 1);
      ::ArrayResize(row_tf,     count + 1);
      ::ArrayResize(row_dir,    count + 1);
      ::ArrayResize(row_time,   count + 1);
      ::ArrayResize(row_source, count + 1);
      int digits = (int)SymbolInfoInteger(sym, SYMBOL_DIGITS);
      row_label[count]  = SwingTypeDescription(sw.TypeSwing()) + " (" + SwingStructureDescription(sw.Structure()) + ") " + DoubleToString(sw.Price(), digits);
      row_tf[count]     = TimeframeDescription(sw.Timeframe());
      row_dir[count]    = (sw.TypeSwing() == SWING_TYPE_LOW) ? SIGNAL_BUY : SIGNAL_SELL;
      row_time[count]   = st;
      row_source[count] = 2;
      count++;
     }
   //--- Pattern-only bar: the box + tooltip already tell it, no popup
    bool has_non_pattern = false;
    for(int i = 0; i < count && !has_non_pattern; i++)
      if(row_source[i] != 1) has_non_pattern = true;
    if(!has_non_pattern)
     {
      m_table_candle_information_atBar.DeleteAllRows(false);
      return false;
    }
   //--- Time ascending, then TF ascending
   for(int a = 0; a < count - 1; a++)
      for(int b = a + 1; b < count; b++)
       {
        bool need_swap = (row_time[b] < row_time[a]) ||
                         (row_time[b] == row_time[a] &&
                          IndexEnumTimeframe(TimestampByDescription(row_tf[b])) < IndexEnumTimeframe(TimestampByDescription(row_tf[a])));
        if(!need_swap) continue;
        string          lbl_ = row_label[a];  row_label[a]  = row_label[b];  row_label[b]  = lbl_;
        string          tf_  = row_tf[a];     row_tf[a]     = row_tf[b];     row_tf[b]     = tf_;
        ENUM_SIGNAL_DIR d_   = row_dir[a];    row_dir[a]    = row_dir[b];    row_dir[b]    = d_;
        datetime        tm_  = row_time[a];   row_time[a]   = row_time[b];   row_time[b]   = tm_;
        int             src_ = row_source[a]; row_source[a] = row_source[b]; row_source[b] = src_;
       }
   uint source_img[] = {IMAGE_RESOURCE_BMP16_INDICATOR_BMP, IMAGE_RESOURCE_BMP16_CANDLE_PNG, IMAGE_RESOURCE_BMP16_SIGNAL_PNG};
   uint dir_img[]    = {IMAGE_RESOURCE_BMP16_ARROW_UP_PNG, IMAGE_RESOURCE_BMP16_ARROW_DOWN_PNG};
   string source_name[] = {"Indicator", "Candle Pattern", "Swing"};
   m_table_candle_information_atBar.DeleteAllRows(false);
   for(int i = 0; i < count; i++)
      m_table_candle_information_atBar.AddRow();
   for(int row = 0; row < count; row++)
    {
     m_table_candle_information_atBar.View().RowView(row).TextAlign(CANDLEINFO_CONTENT_ALIGN);
     m_table_candle_information_atBar.CellView(COL_CI_SOURCE, row).SetImages(source_img);
     m_table_candle_information_atBar.CellView(COL_CI_SOURCE, row).ChangeImage(row_source[row]);
     m_table_candle_information_atBar.CellView(COL_CI_INFO, row).SetImages(dir_img);
     m_table_candle_information_atBar.CellView(COL_CI_INFO, row).ChangeImage(row_dir[row] == SIGNAL_BUY ? 0 : 1);
     m_table_candle_information_atBar.Cell(COL_CI_TIME, row).SetDatetimeFlags(TIME_MINUTES);
     m_table_candle_information_atBar.SetValue(COL_CI_TIME, row, row_time[row]);
     m_table_candle_information_atBar.SetValue(COL_CI_SOURCE, row, source_name[row_source[row]]);
     m_table_candle_information_atBar.SetValue(COL_CI_TF, row, row_tf[row]);
     m_table_candle_information_atBar.SetValue(COL_CI_INFO, row, row_label[row]);
    }
   m_table_candle_information_atBar.Update(false);
   return true;
  }
 //+------------------------------------------------------------------+
 //| Shift+hover: box + popup for the bar under the cursor; the popup  |
 //| closes once the cursor is neither on it nor on its bar            |
 //+------------------------------------------------------------------+
 void CGUIPannel::OnEvent_Window_CandleInfor(const int id,const long &lparam, const double &dparam, const string &sparam)
  {
   //--- Scroll/zoom/new bar: the box and its name follow the candles by themselves
   if(id == CHARTEVENT_CHART_CHANGE)
    {
     if(m_candle_info_shown_bar != 0)
      {
       RepositionWindow_CandleInfo(m_window_candle_infomation.X(), m_window_candle_infomation.Y() + CANDLE_INFO_CURSOR_INSET);
       ::ChartRedraw(m_chart_id);
      }
     return;
    }
   if(id != CHARTEVENT_MOUSE_MOVE) return;
   int x = (int)lparam;
   int y = (int)dparam;
   static datetime s_last_bar = 0;   // bar already handled while Shift stays down
   //--- Open popup: stays while the cursor is on it or still on its bar
   if(m_candle_info_shown_bar != 0)
    {
     if(m_window_candle_infomation.CursorInsideElement(x, y)) return;
      bool over_gui = MouseOverAnyGUIWindow(x, y);
      if(!over_gui && CalculateAtCandle(x, y) == m_candle_info_shown_bar) return;
      if(!over_gui && m_keys.KeyShiftState()) return;
     HideWindow_CandleInfo();
     return;
    }
   if(!m_keys.KeyShiftState() || MouseOverAnyGUIWindow(x, y))
    {
     s_last_bar = 0;
     return;
    }
   datetime bar_time = CalculateAtCandle(x, y);
   if(bar_time == 0 || bar_time == s_last_bar) return;
   s_last_bar = bar_time;
   if(RefreshWindow_CandleInfo(bar_time))
    {
     m_candle_info_shown_bar = bar_time;
     ShowWindow_CandleInfo(x, y);
    }
  }
#endif // CGUIPANNEL_CANDLEINFO_WINDOWS_MQH
