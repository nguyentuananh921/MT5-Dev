//+------------------------------------------------------------------+
//|                                   SMC_Liquidity_Detector.mq5     |
//|                                     Copyright 2026, Amanda V     |
//| https://www.mql5.com/en/code/71025                               |
//+------------------------------------------------------------------+
#property copyright "Amanda V"
#property version   "1.01"
#property indicator_chart_window
#property indicator_buffers 0
#property indicator_plots   0

input int    InpSwingLookback = 30;           // Swing Lookback Period
input double InpMinWickPct    = 30.0;         // Min Rejection Wick %
input color  InpBullColor     = clrAqua;      // Bullish Sweep Color
input color  InpBearColor     = clrMagenta;   // Bearish Sweep Color

string prefix = "SMC_LIQ_";

int OnInit() { 
   Print("SMC Liquidity Detector Optimized."); 
   return(INIT_SUCCEEDED); 
}

void OnDeinit(const int reason) { 
   ObjectsDeleteAll(0, prefix); 
}

int OnCalculate(const int rates_total, const int prev_calculated, const datetime &time[],
                const double &open[], const double &high[], const double &low[],
                const double &close[], const long &tick_volume[], const long &volume[],
                const int &spread[])
{
   if(rates_total < InpSwingLookback + 5) return(0);
   
   // OPTIMIZATION: Calculate only the new closed bars to prevent CPU freezing
   int limit = prev_calculated - 1;
   if(prev_calculated == 0) limit = InpSwingLookback;

   for(int i = limit; i < rates_total - 1; i++) {
      int max_idx = ArrayMaximum(high, i - InpSwingLookback, InpSwingLookback);
      int min_idx = ArrayMinimum(low, i - InpSwingLookback, InpSwingLookback);
      
      if(max_idx < 0 || min_idx < 0) continue;
      
      double prev_high = high[max_idx];
      double prev_low  = low[min_idx];
      
      double total_size = high[i] - low[i];
      if(total_size <= 0) continue;

      // Bullish Sweep (Price went below prev low and closed above it)
      if(low[i] < prev_low && close[i] > prev_low) {
         double lower_wick = MathMin(open[i], close[i]) - low[i];
         if((lower_wick / total_size) * 100.0 >= InpMinWickPct) {
            DrawSweep(time[i], low[i], true);
         }
      }

      // Bearish Sweep (Price went above prev high and closed below it)
      if(high[i] > prev_high && close[i] < prev_high) {
         double upper_wick = high[i] - MathMax(open[i], close[i]);
         if((upper_wick / total_size) * 100.0 >= InpMinWickPct) {
            DrawSweep(time[i], high[i], false);
         }
      }
   }
   return(rates_total);
}

void DrawSweep(datetime t, double p, bool bull) {
   string name = prefix + (bull ? "B_" : "S_") + TimeToString(t);
   if(ObjectFind(0, name) < 0) {
      ObjectCreate(0, name, OBJ_ARROW, 0, t, p);
      ObjectSetInteger(0, name, OBJPROP_ARROWCODE, bull ? 241 : 242);
      ObjectSetInteger(0, name, OBJPROP_COLOR, bull ? InpBullColor : InpBearColor);
      ObjectSetInteger(0, name, OBJPROP_WIDTH, 2);
      // Anchor added for better visibility
      ObjectSetInteger(0, name, OBJPROP_ANCHOR, bull ? ANCHOR_TOP : ANCHOR_BOTTOM);
   }
}
//+------------------------------------------------------------------+