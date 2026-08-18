//+------------------------------------------------------------------+
//|                                              SignalMarkers.mq5   |
//| Draws Buy/Sell signal-flip markers fed by "EA Ussing Combination |
//| Lib V7" via a bridge file - this indicator never recomputes      |
//| signals itself, it only renders what the EA already decided.     |
//|                                                                    |
//| Shape and color are INDEPENDENT axes (Anhnt, 2026-07-17):         |
//| - Shape: how many flips (any tracked TF of this symbol) land in a |
//|   bar's time span, AND their net direction (count Buy >= count    |
//!   Sell -> "Buy" shape family, else "Sell") - 1 flip total = the   |
//!   Single Buy/Sell shape pair, 2+ = the Multi Buy/Sell shape pair. |
//!   4 shapes total, each its OWN plot (PLOT_ARROW is a per-PLOT     |
//!   fixed property in MT5, not per-bar, so 4 distinct shapes need   |
//!   4 distinct plots - no way around this).                        |
//| - Color: gray/Non-Related if none of those flips are from THIS    |
//!   chart's own TF; else Buy or Sell color (majority direction      |
//!   among ONLY this TF's own flips in the bucket) - independent of  |
//!   which shape got picked, so e.g. a "Multi Buy" shape can still   |
//!   legitimately render in Sell color if the bucket's overall       |
//!   majority is Buy but this chart's own-TF flip within it is Sell. |
//|                                                                    |
//| Bridge file format ("SignalBridge_<SYMBOL>.dat", FILE_BIN) -      |
//| v2 (Anhnt, 2026-08-08): added source field to identify pattern   |
//| vs indicator signals. MUST stay byte-identical to the writer in  |
//| SignalBridgeWriter.mqh:                                          |
//|   int      magic_version   (20260808 for this version)          |
//|   long     last_update       (datetime as long)                  |
//|   int      row_count                                             |
//|   row_count x { long time; int tf; int dir; int source; }        |
//|     where dir: +1 (BUY) / -1 (SELL), source: 0 (Indicator) / 1 (Pattern) |
//+------------------------------------------------------------------+
#property indicator_chart_window
#property indicator_buffers 16
#property indicator_plots   8

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

input int   InpSingleBuyArrowCode  = 233;   // Single Indicator Buy shape (Wingdings)
input int   InpSingleSellArrowCode = 234;   // Single Indicator Sell shape (Wingdings)
input int   InpMultiBuyArrowCode   = 217;   // Multi Indicator Buy shape (Wingdings)
input int   InpMultiSellArrowCode  = 218;   // Multi Indicator Sell shape (Wingdings)
input int   InpPatternBuyArrowCode = 67;    // Pattern Buy shape (Wingdings)
input int   InpPatternSellArrowCode = 68;   // Pattern Sell shape (Wingdings)
input int   InpComboBuyArrowCode   = 225;   // Combo Buy shape (Wingdings)
input int   InpComboSellArrowCode  = 226;   // Combo Sell shape (Wingdings)
input color InpBuyColor            = clrLime;  // Color when related to this chart's own TF - Buy
input color InpSellColor           = clrRed;   // Color when related to this chart's own TF - Sell
input color InpNonRelatedColor     = clrGray;  // Color when NOT related to this chart's own TF
input string InpBridgeFolderPath = "";  // Bridge file folder path (empty = root MQL5/Files)

#define SIGNAL_BRIDGE_MAGIC 20260808

double BufSingleBuyValue[],    BufSingleBuyColorIdx[];
double BufSingleSellValue[],   BufSingleSellColorIdx[];
double BufMultiBuyValue[],     BufMultiBuyColorIdx[];
double BufMultiSellValue[],    BufMultiSellColorIdx[];
double BufPatternBuyValue[],   BufPatternBuyColorIdx[];
double BufPatternSellValue[],  BufPatternSellColorIdx[];
double BufComboBuyValue[],     BufComboBuyColorIdx[];
double BufComboSellValue[],    BufComboSellColorIdx[];


datetime g_rows_time[];
int      g_rows_tf[];
int      g_rows_dir[];
int      g_rows_source[]; // 0=Indicator, 1=Pattern
int      g_row_count = 0;

datetime g_bridge_last_update = 0; // watermark compared against the file's own header
bool     g_dirty               = true; // force a full recompute on first OnCalculate

string   g_bridge_file = "";
//extern string g_ea_folder;  // From EA
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

   PlotIndexSetInteger(0, PLOT_ARROW, InpSingleBuyArrowCode);
   PlotIndexSetInteger(1, PLOT_ARROW, InpSingleSellArrowCode);
   PlotIndexSetInteger(2, PLOT_ARROW, InpMultiBuyArrowCode);
   PlotIndexSetInteger(3, PLOT_ARROW, InpMultiSellArrowCode);
   PlotIndexSetInteger(4, PLOT_ARROW, InpPatternBuyArrowCode);
   PlotIndexSetInteger(5, PLOT_ARROW, InpPatternSellArrowCode);
   PlotIndexSetInteger(6, PLOT_ARROW, InpComboBuyArrowCode);
   PlotIndexSetInteger(7, PLOT_ARROW, InpComboSellArrowCode);

   for(int plot = 0; plot < 8; plot++)
     {
      PlotIndexSetInteger(plot, PLOT_COLOR_INDEXES, 3);
      PlotIndexSetInteger(plot, PLOT_LINE_COLOR, 0, InpNonRelatedColor);
      PlotIndexSetInteger(plot, PLOT_LINE_COLOR, 1, InpBuyColor);
      PlotIndexSetInteger(plot, PLOT_LINE_COLOR, 2, InpSellColor);
      PlotIndexSetInteger(plot, PLOT_LINE_WIDTH, 2); //Set Marker size (1-5 default 1)
      PlotIndexSetDouble(plot, PLOT_EMPTY_VALUE, EMPTY_VALUE);
     }
   string base_name = "SignalBridge_" + ::Symbol() + ".dat";
   g_bridge_file = (InpBridgeFolderPath != "") ? (InpBridgeFolderPath + "/" + base_name) : base_name;
   IndicatorSetString(INDICATOR_SHORTNAME, "SignalMarkers(" + ::Symbol() + ")");
   ReadBridgeFile(); // seed once at init, don't wait for the first timer tick
   ::EventSetMillisecondTimer(250);
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   ::EventKillTimer();
  }
//+------------------------------------------------------------------+
//| Low-frequency poll: cheap header-only check, full reread only    |
//| when the file's own watermark actually moved.                    |
//+------------------------------------------------------------------+
void OnTimer(void)
  {
   int fh = ::FileOpen(g_bridge_file, FILE_BIN|FILE_READ|FILE_SHARE_READ|FILE_SHARE_WRITE);
   if(fh == INVALID_HANDLE)
      return;

   int      magic = (int)::FileReadInteger(fh, INT_VALUE);
   long     update = ::FileReadLong(fh);
   ::FileClose(fh);

   if(magic != SIGNAL_BRIDGE_MAGIC)
      return; // stale/partial write from a mid-rewrite moment - retry next tick
   if((datetime)update == g_bridge_last_update)
      return; // nothing new

   ReadBridgeFile();
  }
//+------------------------------------------------------------------+
//| Full reread of the bridge file into the flat row arrays.         |
//+------------------------------------------------------------------+
void ReadBridgeFile(void)
  {    
   int fh = ::FileOpen(g_bridge_file, FILE_BIN|FILE_READ|FILE_SHARE_READ|FILE_SHARE_WRITE);
   if(fh == INVALID_HANDLE)
      return;

   int  magic = (int)::FileReadInteger(fh, INT_VALUE);
   long update = ::FileReadLong(fh);
   int  count  = (int)::FileReadInteger(fh, INT_VALUE);
   if(magic != SIGNAL_BRIDGE_MAGIC || count < 0)
     {
      ::FileClose(fh);
      return; // partial/mid-rewrite - keep old data, retry next timer tick
     }
   ::ArrayResize(g_rows_time,   count);
   ::ArrayResize(g_rows_tf,     count);
   ::ArrayResize(g_rows_dir,    count);
   ::ArrayResize(g_rows_source, count);
   for(int i = 0; i < count; i++)
     {
      g_rows_time[i]   = (datetime)::FileReadLong(fh);
      g_rows_tf[i]     = (int)::FileReadInteger(fh, INT_VALUE);
      g_rows_dir[i]    = (int)::FileReadInteger(fh, INT_VALUE);
      g_rows_source[i] = (int)::FileReadInteger(fh, INT_VALUE);
     }
   ::FileClose(fh);
   g_row_count          = count;
   g_bridge_last_update = (datetime)update;
   g_dirty              = true;
  }
//+------------------------------------------------------------------+
//| Fills the 8 shape buffers + color indexes for bar index i from   |
//| g_rows[] - bucket = [time[i], time[i]+PeriodSeconds()). Shape is |
//| picked from combination of indicator/pattern counts + direction;  |
//| color is picked from ONLY this chart's own-TF rows (gray/         |
//| Non-Related if there are none) - the two are independent (Anhnt,  |
//| 2026-08-08): Single/Multi from indicators, Pattern from patterns, |
//| Combo from both.                                                  |
//+------------------------------------------------------------------+
void ComputeBar(const int i, const datetime &time[], const double &high[], const double &low[])
  {
   datetime bucket_start = time[i];
   datetime bucket_end   = bucket_start + ::PeriodSeconds();
   int      own_tf       = (int)::Period();
   BufSingleBuyValue[i]   = EMPTY_VALUE; BufSingleBuyColorIdx[i]   = 0;
   BufSingleSellValue[i]  = EMPTY_VALUE; BufSingleSellColorIdx[i]  = 0;
   BufMultiBuyValue[i]    = EMPTY_VALUE; BufMultiBuyColorIdx[i]    = 0;
   BufMultiSellValue[i]   = EMPTY_VALUE; BufMultiSellColorIdx[i]   = 0;
   BufPatternBuyValue[i]  = EMPTY_VALUE; BufPatternBuyColorIdx[i]  = 0;
   BufPatternSellValue[i] = EMPTY_VALUE; BufPatternSellColorIdx[i] = 0;
   BufComboBuyValue[i]    = EMPTY_VALUE; BufComboBuyColorIdx[i]    = 0;
   BufComboSellValue[i]   = EMPTY_VALUE; BufComboSellColorIdx[i]   = 0;

   int ind_buy = 0, ind_sell = 0, pat_buy = 0, pat_sell = 0, own_buy = 0, own_sell = 0;
   for(int r = 0; r < g_row_count; r++)
     {
      if(g_rows_time[r] < bucket_start || g_rows_time[r] >= bucket_end)
         continue;

      if(g_rows_source[r] == 0)
        { // Indicator signal
         if(g_rows_dir[r] > 0) ind_buy++;
         else                  ind_sell++;
        }
      else
        { // Pattern signal
         if(g_rows_dir[r] > 0) pat_buy++;
         else                  pat_sell++;
        }

      if(g_rows_tf[r] == own_tf)
        {
         if(g_rows_dir[r] > 0) own_buy++;
         else                  own_sell++;
        }
     }

   int total_ind = ind_buy + ind_sell;
   int total_pat = pat_buy + pat_sell;
   if(total_ind + total_pat == 0)
      return;

   int color_idx = (own_buy + own_sell > 0) ? ((own_buy >= own_sell) ? 1 : 2) : 0; // 0=Non-Related, 1=Buy, 2=Sell
    //  // MY DEBUG SignalMarkers::ComputeBar: bar has signal(s) - dump counts/branch before buffers are set
    //  string dbg_branch = (total_ind > 0 && total_pat == 0) ? (total_ind == 1 ? "Single" : "Multi") :
    //                      (total_ind == 0 && total_pat > 0) ? "Pattern" : "Combo";
    //  ::Print("MY DEBUG SignalMarkers::ComputeBar: i=", i, " time=", ::TimeToString(time[i], TIME_DATE|TIME_MINUTES),
    //          " total_ind=", total_ind, " total_pat=", total_pat, " own_buy=", own_buy, " own_sell=", own_sell,
    //          " color_idx=", color_idx, " branch=", dbg_branch);
   // --- Gap scales with THIS bar's own High-Low range, not a fixed price distance - keeps
   // --- markers proportionally clear of the candle across symbols/TFs with very different
   // --- volatility. 0.3 sat markers almost on the wick on low-range bars (e.g. M1); raised
   // --- to push them further off
    double gap   = (high[i] - low[i]) * 0.5;

   // Determine marker type and direction
    bool ind_is_buy  = (ind_buy >= ind_sell); //Marker_Buy 
    bool pat_is_buy  = (pat_buy >= pat_sell);
    double value_buy  = low[i] - gap;
    double value_sell = high[i] + gap;

   if(total_ind > 0 && total_pat == 0)
     { // Only indicators: Single or Multi
      if(total_ind == 1)
        { // Single
         if(ind_is_buy) { BufSingleBuyValue[i]  = value_buy;  BufSingleBuyColorIdx[i]  = color_idx; }
         else           { BufSingleSellValue[i] = value_sell; BufSingleSellColorIdx[i] = color_idx; }
        }
      else
        { // Multi
         if(ind_is_buy) { BufMultiBuyValue[i]  = value_buy;  BufMultiBuyColorIdx[i]  = color_idx; }
         else           { BufMultiSellValue[i] = value_sell; BufMultiSellColorIdx[i] = color_idx; }
        }
     }
   else if(total_ind == 0 && total_pat > 0)
     { // Only patterns: Pattern
      if(pat_is_buy) { BufPatternBuyValue[i]  = value_buy;  BufPatternBuyColorIdx[i]  = color_idx; }
      else           { BufPatternSellValue[i] = value_sell; BufPatternSellColorIdx[i] = color_idx; }
     }
   else
     { // Both indicators and patterns: Combo
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

   if(g_dirty)
     {
      // Bridge data changed (new flip, backfill, or a toggled Buy/Sell filter) - a full
      // rewrite can touch any bar, but the row set stays small (sparse flip history), so a
      // full bar sweep here is cheap and only runs when the file actually changed.
      for(int i = 0; i < rates_total; i++)
         ComputeBar(i, time, high, low);
      g_dirty = false;
      // // MY DEBUG SignalMarkers::OnCalculate: confirms full recompute actually ran + its range
      // ::Print("MY DEBUG SignalMarkers::OnCalculate: full recompute done, rates_total=", rates_total,
      //         " g_row_count=", g_row_count, " first_time=", ::TimeToString(time[0], TIME_DATE|TIME_MINUTES),
      //         " last_time=", ::TimeToString(time[rates_total-1], TIME_DATE|TIME_MINUTES));
     }
   else
     {
      // Normal tick-driven path: only the newest bar(s) can be new.
      int start = (prev_calculated > 1) ? prev_calculated - 1 : 0;
      for(int i = start; i < rates_total; i++)
         ComputeBar(i, time, high, low);
     }

   return(rates_total);
  }
//+------------------------------------------------------------------+
