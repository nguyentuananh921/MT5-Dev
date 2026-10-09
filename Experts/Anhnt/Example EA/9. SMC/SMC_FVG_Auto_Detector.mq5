//+------------------------------------------------------------------+
//|                                        SMC_FVG_Auto_Detector.mq5 |
//|                                         Copyright 2026, Amanda V |
//|                                            https://forge.mql5.io |
//| https://www.mql5.com/en/code/70854                               |
//+------------------------------------------------------------------+
#property copyright "Amanda V"
#property link      "https://forge.mql5.io"
#property version   "3.00"
#property indicator_chart_window
#property indicator_buffers 0
#property indicator_plots   0

//--- Input parameters
input int    InpHistoryBars   = 500;             // History Bars to Scan
input color  InpColorBull     = clrLightGreen;   // Bullish FVG Color
input color  InpColorBear     = clrLightCoral;   // Bearish FVG Color

string prefix = "SMC_FVG_";

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
   Print("SMC FVG Auto-Detector Initialized.");
   return(INIT_SUCCEEDED);
  }

//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   ObjectsDeleteAll(0, prefix);
  }

//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
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
   if(rates_total < 3) return(0);

   int start = prev_calculated == 0 ? MathMax(0, rates_total - InpHistoryBars) : prev_calculated - 1;

   for(int i = start; i < rates_total - 1; i++)
     {
      if(i < 2) continue;

      double high_past = high[i-2];
      double low_past  = low[i-2];
      double high_curr = high[i];
      double low_curr  = low[i];
      
      datetime t_past  = time[i-2];
      datetime t_curr  = time[i];

      // Bullish FVG
      if(high_past < low_curr)
        {
         string name = prefix + "Bull_" + TimeToString(t_past);
         if(ObjectFind(0, name) < 0)
           {
            ObjectCreate(0, name, OBJ_RECTANGLE, 0, t_past, high_past, t_curr, low_curr);
            ObjectSetInteger(0, name, OBJPROP_COLOR, InpColorBull);
            ObjectSetInteger(0, name, OBJPROP_FILL, true);
            ObjectSetInteger(0, name, OBJPROP_BACK, true);
            ObjectSetInteger(0, name, OBJPROP_HIDDEN, true);
           }
        }

      // Bearish FVG
      if(low_past > high_curr)
        {
         string name = prefix + "Bear_" + TimeToString(t_past);
         if(ObjectFind(0, name) < 0)
           {
            ObjectCreate(0, name, OBJ_RECTANGLE, 0, t_past, low_past, t_curr, high_curr);
            ObjectSetInteger(0, name, OBJPROP_COLOR, InpColorBear);
            ObjectSetInteger(0, name, OBJPROP_FILL, true);
            ObjectSetInteger(0, name, OBJPROP_BACK, true);
            ObjectSetInteger(0, name, OBJPROP_HIDDEN, true);
           }
        }
     }
   return(rates_total);
  }
//+------------------------------------------------------------------+