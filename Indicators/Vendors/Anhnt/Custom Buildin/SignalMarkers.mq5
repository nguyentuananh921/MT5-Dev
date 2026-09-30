//+------------------------------------------------------------------+
//|                                                SignalMarkers.mq5 |
//| Renders the EA's signal / pattern / swing markers from its bridge|
//+------------------------------------------------------------------+
// Bridge row = {long time; int tf; int dir; int source; int extra}, see SignalBridgeWriter.mqh
#property indicator_chart_window
#property indicator_buffers 20
#property indicator_plots   10

#property indicator_type1   DRAW_COLOR_ARROW
#property indicator_label1  "SingleBuy"
#property indicator_color1  clrGray,clrLime,clrRed

#property indicator_type2   DRAW_COLOR_ARROW
#property indicator_label2  "SingleSell"
#property indicator_color2  clrGray,clrLime,clrRed

#property indicator_type3   DRAW_COLOR_ARROW
#property indicator_label3  "MultiBuy"
#property indicator_color3  clrGray,clrLime,clrRed

#property indicator_type4   DRAW_COLOR_ARROW
#property indicator_label4  "MultiSell"
#property indicator_color4  clrGray,clrLime,clrRed

#property indicator_type5   DRAW_COLOR_ARROW
#property indicator_label5  "PatternBuy"
#property indicator_color5  clrGray,clrLime,clrRed

#property indicator_type6   DRAW_COLOR_ARROW
#property indicator_label6  "PatternSell"
#property indicator_color6  clrGray,clrLime,clrRed

#property indicator_type7   DRAW_COLOR_ARROW
#property indicator_label7  "ComboBuy"
#property indicator_color7  clrGray,clrLime,clrRed

#property indicator_type8   DRAW_COLOR_ARROW
#property indicator_label8  "ComboSell"
#property indicator_color8  clrGray,clrLime,clrRed

#property indicator_type9   DRAW_COLOR_ARROW
#property indicator_label9  "SwingLow"
#property indicator_color9  clrGray,clrLime,clrRed

#property indicator_type10  DRAW_COLOR_ARROW
#property indicator_label10 "SwingHigh"
#property indicator_color10 clrGray,clrLime,clrRed

// Input ORDER is the positional wire contract with the EA's iCustom()
input int   InpSingleBuyArrowCode  = 233;   // Single Indicator Buy shape (Wingdings)
input int   InpSingleSellArrowCode = 234;   // Single Indicator Sell shape (Wingdings)
input int   InpMultiBuyArrowCode   = 217;   // Multi Indicator Buy shape (Wingdings)
input int   InpMultiSellArrowCode  = 218;   // Multi Indicator Sell shape (Wingdings)
input int   InpPatternBuyArrowCode = 67;    // Pattern Buy shape (Wingdings)
input int   InpPatternSellArrowCode = 68;   // Pattern Sell shape (Wingdings)
input int   InpComboBuyArrowCode   = 225;   // Combo Buy shape (Wingdings)
input int   InpComboSellArrowCode  = 226;   // Combo Sell shape (Wingdings)
input int   InpSwingHighArrowCode  = 234;   // Swing High shape (Wingdings)
input int   InpSwingLowArrowCode   = 233;   // Swing Low shape (Wingdings)
input color InpBuyColor            = clrLime;  // Color when related to this chart's own TF - Buy
input color InpSellColor           = clrRed;   // Color when related to this chart's own TF - Sell
input color InpNonRelatedColor     = clrGray;  // Color when NOT related to this chart's own TF
input string InpBridgeFolderPath = "";  // Bridge file folder path (empty = root MQL5/Files)

// Must match SignalBridgeWriter.mqh (separately compiled, no shared enum)
#define SIGNAL_BRIDGE_MAGIC                20260919
#define SIGNAL_BRIDGE_WRITER_EVENT_UPDATED 50000   // file rewritten - reread
#define SIGNAL_BRIDGE_ROW_EVENT            50001   // one row carried in the event
#define SWING_LABEL_PREFIX  "SignalMarkers_SwingLbl_"   // OBJ_TEXT HH/LH/HL/LL labels

double BufSingleBuyValue[],    BufSingleBuyColorIdx[];
double BufSingleSellValue[],   BufSingleSellColorIdx[];
double BufMultiBuyValue[],     BufMultiBuyColorIdx[];
double BufMultiSellValue[],    BufMultiSellColorIdx[];
double BufPatternBuyValue[],   BufPatternBuyColorIdx[];
double BufPatternSellValue[],  BufPatternSellColorIdx[];
double BufComboBuyValue[],     BufComboBuyColorIdx[];
double BufComboSellValue[],    BufComboSellColorIdx[];
double BufSwingLowValue[],     BufSwingLowColorIdx[];
double BufSwingHighValue[],    BufSwingHighColorIdx[];

datetime g_rows_time[];   // ascending
int      g_rows_tf[];
int      g_rows_dir[];    // +1 buy / -1 sell; swing: +1 low / -1 high
int      g_rows_source[]; // 0=Indicator, 1=Pattern, 2=Swing
int      g_rows_extra[];  // Swing: 1=HH 2=LH 3=HL 4=LL, else 0
int      g_row_count = 0;

datetime g_bridge_last_update = 0;    // file header watermark
bool     g_dirty              = true; // full recompute on next OnCalculate
datetime g_pending_from       = 0;    // time span of rows added by event since the last OnCalculate
datetime g_pending_to         = 0;

string   g_bridge_file = "";
//+------------------------------------------------------------------+
int OnInit(void)
  {
   SetIndexBuffer(0,  BufSingleBuyValue,    INDICATOR_DATA);
   SetIndexBuffer(1,  BufSingleBuyColorIdx, INDICATOR_COLOR_INDEX);
   SetIndexBuffer(2,  BufSingleSellValue,   INDICATOR_DATA);
   SetIndexBuffer(3,  BufSingleSellColorIdx, INDICATOR_COLOR_INDEX);
   SetIndexBuffer(4,  BufMultiBuyValue,     INDICATOR_DATA);
   SetIndexBuffer(5,  BufMultiBuyColorIdx,  INDICATOR_COLOR_INDEX);
   SetIndexBuffer(6,  BufMultiSellValue,    INDICATOR_DATA);
   SetIndexBuffer(7,  BufMultiSellColorIdx, INDICATOR_COLOR_INDEX);
   SetIndexBuffer(8,  BufPatternBuyValue,   INDICATOR_DATA);
   SetIndexBuffer(9,  BufPatternBuyColorIdx, INDICATOR_COLOR_INDEX);
   SetIndexBuffer(10, BufPatternSellValue,  INDICATOR_DATA);
   SetIndexBuffer(11, BufPatternSellColorIdx, INDICATOR_COLOR_INDEX);
   SetIndexBuffer(12, BufComboBuyValue,     INDICATOR_DATA);
   SetIndexBuffer(13, BufComboBuyColorIdx,  INDICATOR_COLOR_INDEX);
   SetIndexBuffer(14, BufComboSellValue,    INDICATOR_DATA);
   SetIndexBuffer(15, BufComboSellColorIdx, INDICATOR_COLOR_INDEX);
   SetIndexBuffer(16, BufSwingLowValue,     INDICATOR_DATA);
   SetIndexBuffer(17, BufSwingLowColorIdx,  INDICATOR_COLOR_INDEX);
   SetIndexBuffer(18, BufSwingHighValue,    INDICATOR_DATA);
   SetIndexBuffer(19, BufSwingHighColorIdx, INDICATOR_COLOR_INDEX);

   PlotIndexSetInteger(0, PLOT_ARROW, InpSingleBuyArrowCode);
   PlotIndexSetInteger(1, PLOT_ARROW, InpSingleSellArrowCode);
   PlotIndexSetInteger(2, PLOT_ARROW, InpMultiBuyArrowCode);
   PlotIndexSetInteger(3, PLOT_ARROW, InpMultiSellArrowCode);
   PlotIndexSetInteger(4, PLOT_ARROW, InpPatternBuyArrowCode);
   PlotIndexSetInteger(5, PLOT_ARROW, InpPatternSellArrowCode);
   PlotIndexSetInteger(6, PLOT_ARROW, InpComboBuyArrowCode);
   PlotIndexSetInteger(7, PLOT_ARROW, InpComboSellArrowCode);
   PlotIndexSetInteger(8, PLOT_ARROW, InpSwingLowArrowCode);
   PlotIndexSetInteger(9, PLOT_ARROW, InpSwingHighArrowCode);

   for(int plot = 0; plot < 10; plot++)
     {
      PlotIndexSetInteger(plot, PLOT_COLOR_INDEXES, 3);
      PlotIndexSetInteger(plot, PLOT_LINE_COLOR, 0, InpNonRelatedColor);
      PlotIndexSetInteger(plot, PLOT_LINE_COLOR, 1, InpBuyColor);
      PlotIndexSetInteger(plot, PLOT_LINE_COLOR, 2, InpSellColor);
      PlotIndexSetInteger(plot, PLOT_LINE_WIDTH, 2);
      PlotIndexSetDouble(plot, PLOT_EMPTY_VALUE, EMPTY_VALUE);
     }
   string base_name = "SignalBridge_" + ::Symbol() + ".dat";
   g_bridge_file = (InpBridgeFolderPath != "") ? (InpBridgeFolderPath + "/" + base_name) : base_name;
   IndicatorSetString(INDICATOR_SHORTNAME, "SignalMarkers(" + ::Symbol() + ")");
   ::ObjectsDeleteAll(0, SWING_LABEL_PREFIX, 0, OBJ_TEXT);
   ReadBridgeFile();
   ::EventSetMillisecondTimer(250);
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   ::EventKillTimer();
   ::ObjectsDeleteAll(0, SWING_LABEL_PREFIX, 0, OBJ_TEXT);
  }
//+------------------------------------------------------------------+
//| Bridge events; the 250 ms OnTimer poll is the fallback           |
//+------------------------------------------------------------------+
void OnChartEvent(const int id, const long &lparam, const double &dparam, const string &sparam)
  {
   if(id == CHARTEVENT_CUSTOM + SIGNAL_BRIDGE_WRITER_EVENT_UPDATED && sparam == ::Symbol())
     {
      ReadBridgeFile();
      return;
     }
   if(id == CHARTEVENT_CUSTOM + SIGNAL_BRIDGE_ROW_EVENT)
     {
      string parts[];
      if(::StringSplit(sparam, '|', parts) != 4)
         return;
      datetime row_time = (datetime)lparam;
      InsertRow(row_time, (int)::StringToInteger(parts[0]), (int)::StringToInteger(parts[1]),
                (int)::StringToInteger(parts[2]), (int)::StringToInteger(parts[3]));
      if(g_pending_from == 0 || row_time < g_pending_from) g_pending_from = row_time;
      if(row_time > g_pending_to) g_pending_to = row_time;
      return;
     }
  }
//+------------------------------------------------------------------+
//| Header-only check, full reread only when the watermark moved     |
//+------------------------------------------------------------------+
void OnTimer(void)
  {
   int fh = ::FileOpen(g_bridge_file, FILE_BIN|FILE_READ|FILE_SHARE_READ|FILE_SHARE_WRITE);
   if(fh == INVALID_HANDLE)
      return;
   int  magic  = (int)::FileReadInteger(fh, INT_VALUE);
   long update = ::FileReadLong(fh);
   ::FileClose(fh);
   if(magic != SIGNAL_BRIDGE_MAGIC)
      return; // mid-rewrite
   if((datetime)update == g_bridge_last_update)
      return;
   ReadBridgeFile();
  }
//+------------------------------------------------------------------+
//| Full reread of the bridge file                                   |
//+------------------------------------------------------------------+
void ReadBridgeFile(void)
  {
   int fh = ::FileOpen(g_bridge_file, FILE_BIN|FILE_READ|FILE_SHARE_READ|FILE_SHARE_WRITE);
   if(fh == INVALID_HANDLE)
      return;
   int  magic  = (int)::FileReadInteger(fh, INT_VALUE);
   long update = ::FileReadLong(fh);
   int  count  = (int)::FileReadInteger(fh, INT_VALUE);
   if(magic != SIGNAL_BRIDGE_MAGIC || count < 0)
     {
      ::FileClose(fh);
      return; // mid-rewrite - keep old data
     }
   ::ArrayResize(g_rows_time,   count);
   ::ArrayResize(g_rows_tf,     count);
   ::ArrayResize(g_rows_dir,    count);
   ::ArrayResize(g_rows_source, count);
   ::ArrayResize(g_rows_extra,  count);
   for(int i = 0; i < count; i++)
     {
      g_rows_time[i]   = (datetime)::FileReadLong(fh);
      g_rows_tf[i]     = (int)::FileReadInteger(fh, INT_VALUE);
      g_rows_dir[i]    = (int)::FileReadInteger(fh, INT_VALUE);
      g_rows_source[i] = (int)::FileReadInteger(fh, INT_VALUE);
      g_rows_extra[i]  = (int)::FileReadInteger(fh, INT_VALUE);
     }
   ::FileClose(fh);
   g_row_count          = count;
   g_bridge_last_update = (datetime)update;
   SortRows();
   g_dirty              = true;
  }
//+------------------------------------------------------------------+
//| Rows ascending by time, so each bar finds its rows by range      |
//+------------------------------------------------------------------+
void SortRows(void)
  {
   bool sorted = true;
   for(int i = 1; i < g_row_count && sorted; i++)
      sorted = (g_rows_time[i - 1] <= g_rows_time[i]);
   if(sorted)
      return;
   long keys[][2];
   ::ArrayResize(keys, g_row_count);
   for(int i = 0; i < g_row_count; i++)
     {
      keys[i][0] = (long)g_rows_time[i];
      keys[i][1] = i;
     }
   ::ArraySort(keys);
   datetime t[];
   int      tf[], dir[], src[], ext[];
   ::ArrayResize(t,   g_row_count);
   ::ArrayResize(tf,  g_row_count);
   ::ArrayResize(dir, g_row_count);
   ::ArrayResize(src, g_row_count);
   ::ArrayResize(ext, g_row_count);
   for(int i = 0; i < g_row_count; i++)
     {
      int k = (int)keys[i][1];
      t[i] = g_rows_time[k]; tf[i] = g_rows_tf[k]; dir[i] = g_rows_dir[k]; src[i] = g_rows_source[k]; ext[i] = g_rows_extra[k];
     }
   ::ArrayCopy(g_rows_time, t);
   ::ArrayCopy(g_rows_tf, tf);
   ::ArrayCopy(g_rows_dir, dir);
   ::ArrayCopy(g_rows_source, src);
   ::ArrayCopy(g_rows_extra, ext);
  }
//+------------------------------------------------------------------+
//| First row with time >= t (g_row_count if none)                   |
//+------------------------------------------------------------------+
int RowLowerBound(const datetime t)
  {
   int lo = 0, hi = g_row_count;
   while(lo < hi)
     {
      int mid = (lo + hi) / 2;
      if(g_rows_time[mid] < t) lo = mid + 1;
      else                     hi = mid;
     }
   return(lo);
  }
//+------------------------------------------------------------------+
//| One row from the event, inserted at its sorted position          |
//+------------------------------------------------------------------+
void InsertRow(const datetime row_time, const int tf, const int dir, const int source, const int extra)
  {
   int n   = g_row_count;
   int pos = RowLowerBound(row_time + 1);   // after rows with the same time
   ::ArrayResize(g_rows_time,   n + 1);
   ::ArrayResize(g_rows_tf,     n + 1);
   ::ArrayResize(g_rows_dir,    n + 1);
   ::ArrayResize(g_rows_source, n + 1);
   ::ArrayResize(g_rows_extra,  n + 1);
   for(int j = n; j > pos; j--)
     {
      g_rows_time[j] = g_rows_time[j - 1]; g_rows_tf[j] = g_rows_tf[j - 1]; g_rows_dir[j] = g_rows_dir[j - 1];
      g_rows_source[j] = g_rows_source[j - 1]; g_rows_extra[j] = g_rows_extra[j - 1];
     }
   g_rows_time[pos] = row_time; g_rows_tf[pos] = tf; g_rows_dir[pos] = dir; g_rows_source[pos] = source; g_rows_extra[pos] = extra;
   g_row_count = n + 1;
  }
//+------------------------------------------------------------------+
//| Last bar with time[i] <= t (-1 if before the first bar)          |
//+------------------------------------------------------------------+
int BarIndexAt(const datetime &time[], const int rates_total, const datetime t)
  {
   int lo = 0, hi = rates_total;
   while(lo < hi)
     {
      int mid = (lo + hi) / 2;
      if(time[mid] <= t) lo = mid + 1;
      else               hi = mid;
     }
   return(lo - 1);
  }
//+------------------------------------------------------------------+
//| HH/LH/HL/LL text beside a Swing marker (PLOT_ARROW has no text)  |
//+------------------------------------------------------------------+
void DrawSwingLabel(const datetime bar_time, const double price, const bool is_high, const int structure, const color clr)
  {
   string text = (structure == 1) ? "HH" : (structure == 2) ? "LH" : (structure == 3) ? "HL" : (structure == 4) ? "LL" : "";
   string name = SWING_LABEL_PREFIX + (string)(long)bar_time + (is_high ? "_H" : "_L");
   if(text == "") { ::ObjectDelete(0, name); return; }
   if(::ObjectFind(0, name) < 0)
     {
      if(!::ObjectCreate(0, name, OBJ_TEXT, 0, bar_time, price)) return;
      ::ObjectSetInteger(0, name, OBJPROP_SELECTABLE, false);
      ::ObjectSetInteger(0, name, OBJPROP_HIDDEN,     true);
      ::ObjectSetInteger(0, name, OBJPROP_BACK,       true);
      ::ObjectSetString (0, name, OBJPROP_FONT,       "Arial");
      ::ObjectSetInteger(0, name, OBJPROP_FONTSIZE,   8);
      ::ObjectSetString (0, name, OBJPROP_TOOLTIP,    "\n");
     }
   ::ObjectSetInteger(0, name, OBJPROP_TIME,   bar_time);
   ::ObjectSetDouble (0, name, OBJPROP_PRICE,  price);
   ::ObjectSetInteger(0, name, OBJPROP_ANCHOR, is_high ? ANCHOR_LOWER : ANCHOR_UPPER);
   ::ObjectSetInteger(0, name, OBJPROP_COLOR,  clr);
   ::ObjectSetString (0, name, OBJPROP_TEXT,   text);
  }
//+------------------------------------------------------------------+
//| Bar i from rows [r_from, r_to): shape from all, color from own TF|
//+------------------------------------------------------------------+
void ComputeBar(const int i, const int r_from, const int r_to, const datetime &time[], const double &high[], const double &low[])
  {
   int own_tf = (int)::Period();
   BufSingleBuyValue[i]   = EMPTY_VALUE; BufSingleBuyColorIdx[i]   = 0;
   BufSingleSellValue[i]  = EMPTY_VALUE; BufSingleSellColorIdx[i]  = 0;
   BufMultiBuyValue[i]    = EMPTY_VALUE; BufMultiBuyColorIdx[i]    = 0;
   BufMultiSellValue[i]   = EMPTY_VALUE; BufMultiSellColorIdx[i]   = 0;
   BufPatternBuyValue[i]  = EMPTY_VALUE; BufPatternBuyColorIdx[i]  = 0;
   BufPatternSellValue[i] = EMPTY_VALUE; BufPatternSellColorIdx[i] = 0;
   BufComboBuyValue[i]    = EMPTY_VALUE; BufComboBuyColorIdx[i]    = 0;
   BufComboSellValue[i]   = EMPTY_VALUE; BufComboSellColorIdx[i]   = 0;
   BufSwingLowValue[i]    = EMPTY_VALUE; BufSwingLowColorIdx[i]    = 0;
   BufSwingHighValue[i]   = EMPTY_VALUE; BufSwingHighColorIdx[i]   = 0;

   int ind_buy = 0, ind_sell = 0, pat_buy = 0, pat_sell = 0, own_buy = 0, own_sell = 0;
   //--- Swings never feed the signal shape/color
   int swing_low = 0, swing_high = 0, own_swing_low = 0, own_swing_high = 0;
   int swing_low_struct = 0, swing_high_struct = 0;
   for(int r = r_from; r < r_to; r++)
     {
      if(g_rows_source[r] == 2)
        {
         bool own = (g_rows_tf[r] == own_tf);
         if(g_rows_dir[r] > 0)
           { swing_low++;  if(own) own_swing_low++;  if(own || swing_low_struct  == 0) swing_low_struct  = g_rows_extra[r]; }
         else
           { swing_high++; if(own) own_swing_high++; if(own || swing_high_struct == 0) swing_high_struct = g_rows_extra[r]; }
         continue;
        }
      if(g_rows_source[r] == 0)
        {
         if(g_rows_dir[r] > 0) ind_buy++;
         else                  ind_sell++;
        }
      else
        {
         if(g_rows_dir[r] > 0) pat_buy++;
         else                  pat_sell++;
        }
      if(g_rows_tf[r] == own_tf)
        {
         if(g_rows_dir[r] > 0) own_buy++;
         else                  own_sell++;
        }
     }
   //--- Swing marker 2x further out than a signal marker, colored only when this TF confirmed it
   if(swing_low + swing_high > 0)
     {
      double swing_gap = (high[i] - low[i]) * 1.0;
      double label_gap = swing_gap * 0.8;
      if(swing_low > 0)
        {
         BufSwingLowValue[i] = low[i] - swing_gap; BufSwingLowColorIdx[i] = (own_swing_low > 0) ? 1 : 0;
         DrawSwingLabel(time[i], BufSwingLowValue[i] - label_gap, false, swing_low_struct, (own_swing_low > 0) ? InpBuyColor : InpNonRelatedColor);
        }
      if(swing_high > 0)
        {
         BufSwingHighValue[i] = high[i] + swing_gap; BufSwingHighColorIdx[i] = (own_swing_high > 0) ? 2 : 0;
         DrawSwingLabel(time[i], BufSwingHighValue[i] + label_gap, true, swing_high_struct, (own_swing_high > 0) ? InpSellColor : InpNonRelatedColor);
        }
     }
   int total_ind = ind_buy + ind_sell;
   int total_pat = pat_buy + pat_sell;
   if(total_ind + total_pat == 0)
      return;
   int    color_idx  = (own_buy + own_sell > 0) ? ((own_buy >= own_sell) ? 1 : 2) : 0; // 0=Non-Related, 1=Buy, 2=Sell
   double gap        = (high[i] - low[i]) * 0.5;
   bool   ind_is_buy = (ind_buy >= ind_sell);
   bool   pat_is_buy = (pat_buy >= pat_sell);
   double value_buy  = low[i] - gap;
   double value_sell = high[i] + gap;
   if(total_ind > 0 && total_pat == 0)
     { // Single / Multi
      if(total_ind == 1)
        {
         if(ind_is_buy) { BufSingleBuyValue[i]  = value_buy;  BufSingleBuyColorIdx[i]  = color_idx; }
         else           { BufSingleSellValue[i] = value_sell; BufSingleSellColorIdx[i] = color_idx; }
        }
      else
        {
         if(ind_is_buy) { BufMultiBuyValue[i]  = value_buy;  BufMultiBuyColorIdx[i]  = color_idx; }
         else           { BufMultiSellValue[i] = value_sell; BufMultiSellColorIdx[i] = color_idx; }
        }
     }
   else if(total_ind == 0 && total_pat > 0)
     { // Pattern
      if(pat_is_buy) { BufPatternBuyValue[i]  = value_buy;  BufPatternBuyColorIdx[i]  = color_idx; }
      else           { BufPatternSellValue[i] = value_sell; BufPatternSellColorIdx[i] = color_idx; }
     }
   else
     { // Combo
      bool combo_is_buy = (ind_buy + pat_buy >= ind_sell + pat_sell);
      if(combo_is_buy) { BufComboBuyValue[i]  = value_buy;  BufComboBuyColorIdx[i]  = color_idx; }
      else             { BufComboSellValue[i] = value_sell; BufComboSellColorIdx[i] = color_idx; }
     }
  }
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
  {
   if(rates_total <= 0)
      return(0);
   int period = ::PeriodSeconds();
   if(g_dirty)
     {
      //--- One merge pass: bars and rows both ascending
      ::ObjectsDeleteAll(0, SWING_LABEL_PREFIX, 0, OBJ_TEXT);
      int r = 0;
      for(int i = 0; i < rates_total; i++)
        {
         while(r < g_row_count && g_rows_time[r] < time[i])
            r++;
         int r_from = r;
         while(r < g_row_count && g_rows_time[r] < time[i] + period)
            r++;
         ComputeBar(i, r_from, r, time, high, low);
        }
      g_dirty        = false;
      g_pending_from = 0;
      g_pending_to   = 0;
      return(rates_total);
     }
   //--- Rows added by event: only their bars
   if(g_pending_from > 0)
     {
      int i_from = ::MathMax(BarIndexAt(time, rates_total, g_pending_from), 0);
      int i_to   = BarIndexAt(time, rates_total, g_pending_to);
      for(int i = i_from; i <= i_to; i++)
         ComputeBar(i, RowLowerBound(time[i]), RowLowerBound(time[i] + period), time, high, low);
      g_pending_from = 0;
      g_pending_to   = 0;
     }
   //--- Tick path: only the newest bar(s)
   int start = (prev_calculated > 1) ? prev_calculated - 1 : 0;
   for(int i = start; i < rates_total; i++)
      ComputeBar(i, RowLowerBound(time[i]), RowLowerBound(time[i] + period), time, high, low);
   return(rates_total);
  }
//+------------------------------------------------------------------+
