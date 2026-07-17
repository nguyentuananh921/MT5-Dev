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
//| MUST stay byte-identical to the writer in GUIPannel.mqh           |
//| (CGUIPannel::BuildAndWriteSignalBridge):                         |
//|   int      magic_version                                         |
//|   long     last_update       (datetime as long)                  |
//|   int      row_count                                             |
//|   row_count x { long flip_time; int tf; int dir; }  (dir: +1/-1) |
//+------------------------------------------------------------------+
#property indicator_chart_window
#property indicator_buffers 8
#property indicator_plots   4

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

input int   InpSingleBuyArrowCode  = 233;   // Single Buy shape (Wingdings code)
input int   InpSingleSellArrowCode = 234;   // Single Sell shape (Wingdings code)
input int   InpMultiBuyArrowCode   = 217;   // Multi Buy shape (Wingdings code)
input int   InpMultiSellArrowCode  = 218;   // Multi Sell shape (Wingdings code)
input color InpBuyColor            = clrLime;  // Color when related to this chart's own TF - Buy
input color InpSellColor           = clrRed;   // Color when related to this chart's own TF - Sell
input color InpNonRelatedColor     = clrGray;  // Color when NOT related to this chart's own TF

#define SIGNAL_BRIDGE_MAGIC 20260716

double BufSingleBuyValue[],  BufSingleBuyColorIdx[];
double BufSingleSellValue[], BufSingleSellColorIdx[];
double BufMultiBuyValue[],   BufMultiBuyColorIdx[];
double BufMultiSellValue[],  BufMultiSellColorIdx[];

datetime g_rows_time[];
int      g_rows_tf[];
int      g_rows_dir[];
int      g_row_count = 0;

datetime g_bridge_last_update = 0; // watermark compared against the file's own header
bool     g_dirty               = true; // force a full recompute on first OnCalculate

string   g_bridge_file = "";

//+------------------------------------------------------------------+
int OnInit(void)
  {
   SetIndexBuffer(0, BufSingleBuyValue,    INDICATOR_DATA);
   SetIndexBuffer(1, BufSingleBuyColorIdx, INDICATOR_COLOR_INDEX);
   SetIndexBuffer(2, BufSingleSellValue,    INDICATOR_DATA);
   SetIndexBuffer(3, BufSingleSellColorIdx, INDICATOR_COLOR_INDEX);
   SetIndexBuffer(4, BufMultiBuyValue,    INDICATOR_DATA);
   SetIndexBuffer(5, BufMultiBuyColorIdx, INDICATOR_COLOR_INDEX);
   SetIndexBuffer(6, BufMultiSellValue,    INDICATOR_DATA);
   SetIndexBuffer(7, BufMultiSellColorIdx, INDICATOR_COLOR_INDEX);

   PlotIndexSetInteger(0, PLOT_ARROW, InpSingleBuyArrowCode);
   PlotIndexSetInteger(1, PLOT_ARROW, InpSingleSellArrowCode);
   PlotIndexSetInteger(2, PLOT_ARROW, InpMultiBuyArrowCode);
   PlotIndexSetInteger(3, PLOT_ARROW, InpMultiSellArrowCode);

   for(int plot = 0; plot < 4; plot++)
     {
      PlotIndexSetInteger(plot, PLOT_COLOR_INDEXES, 3);
      PlotIndexSetInteger(plot, PLOT_LINE_COLOR, 0, InpNonRelatedColor);
      PlotIndexSetInteger(plot, PLOT_LINE_COLOR, 1, InpBuyColor);
      PlotIndexSetInteger(plot, PLOT_LINE_COLOR, 2, InpSellColor);
      PlotIndexSetDouble(plot, PLOT_EMPTY_VALUE, EMPTY_VALUE);
     }

   g_bridge_file = "SignalBridge_" + ::Symbol() + ".dat";
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

   ::ArrayResize(g_rows_time, count);
   ::ArrayResize(g_rows_tf,   count);
   ::ArrayResize(g_rows_dir,  count);
   for(int i = 0; i < count; i++)
     {
      g_rows_time[i] = (datetime)::FileReadLong(fh);
      g_rows_tf[i]   = (int)::FileReadInteger(fh, INT_VALUE);
      g_rows_dir[i]  = (int)::FileReadInteger(fh, INT_VALUE);
     }
   ::FileClose(fh);

   g_row_count          = count;
   g_bridge_last_update = (datetime)update;
   g_dirty              = true;
  }
//+------------------------------------------------------------------+
//| Fills the 4 shape buffers + color indexes for bar index i from   |
//| g_rows[] - bucket = [time[i], time[i]+PeriodSeconds()). Shape is |
//| picked from total count + NET direction across ALL rows in the   |
//| bucket; color is picked from ONLY this chart's own-TF rows       |
//| (gray/Non-Related if there are none) - the two are independent.  |
//+------------------------------------------------------------------+
void ComputeBar(const int i, const datetime &time[], const double &high[], const double &low[])
  {
   datetime bucket_start = time[i];
   datetime bucket_end   = bucket_start + ::PeriodSeconds();
   int      own_tf       = (int)::Period();

   BufSingleBuyValue[i]  = EMPTY_VALUE; BufSingleBuyColorIdx[i]  = 0;
   BufSingleSellValue[i] = EMPTY_VALUE; BufSingleSellColorIdx[i] = 0;
   BufMultiBuyValue[i]   = EMPTY_VALUE; BufMultiBuyColorIdx[i]   = 0;
   BufMultiSellValue[i]  = EMPTY_VALUE; BufMultiSellColorIdx[i]  = 0;

   int total = 0, net_buy = 0, net_sell = 0, own_buy = 0, own_sell = 0;
   for(int r = 0; r < g_row_count; r++)
     {
      if(g_rows_time[r] < bucket_start || g_rows_time[r] >= bucket_end)
         continue;
      total++;
      if(g_rows_dir[r] > 0) net_buy++;
      else                  net_sell++;
      if(g_rows_tf[r] == own_tf)
        {
         if(g_rows_dir[r] > 0) own_buy++;
         else                  own_sell++;
        }
     }
   if(total == 0)
      return;

   int color_idx = (own_buy + own_sell > 0) ? ((own_buy >= own_sell) ? 1 : 2) : 0; // 0=Non-Related
   bool is_buy   = (net_buy >= net_sell);

   double gap   = (high[i] - low[i]) * 0.3;
   double value = is_buy ? (low[i] - gap) : (high[i] + gap);

   if(total == 1)
     {
      if(is_buy) { BufSingleBuyValue[i]  = value; BufSingleBuyColorIdx[i]  = color_idx; }
      else       { BufSingleSellValue[i] = value; BufSingleSellColorIdx[i] = color_idx; }
     }
   else
     {
      if(is_buy) { BufMultiBuyValue[i]  = value; BufMultiBuyColorIdx[i]  = color_idx; }
      else       { BufMultiSellValue[i] = value; BufMultiSellColorIdx[i] = color_idx; }
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
