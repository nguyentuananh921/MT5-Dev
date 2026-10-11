//+------------------------------------------------------------------+
//|                                         ATS_Confirmed_Swings.mq5 |
//|                                          Andy Trading Solutions  |
//|Link                          https://www.mql5.com/en/code/77698  |
//+------------------------------------------------------------------+
#property copyright "Andy Trading Solutions"
#property version   "1.00"
#property description "Swing highs/lows that never repaint: a swing is drawn only after N closed bars confirm it."
#property indicator_chart_window
#property indicator_buffers 2
#property indicator_plots   2

#property indicator_label1  "Swing High"
#property indicator_type1   DRAW_ARROW
#property indicator_color1  clrTomato
#property indicator_width1  2

#property indicator_label2  "Swing Low"
#property indicator_type2   DRAW_ARROW
#property indicator_color2  clrDodgerBlue
#property indicator_width2  2

//--- input parameters
input int    InpStrength   = 5;      // Confirmation bars on each side
input int    InpMaxBars    = 2000;   // Bars to scan on the chart (0 = all)
input bool   InpAlert      = false;  // Popup alert when a new swing is confirmed
input bool   InpPush       = false;  // Push notification when a new swing is confirmed

//--- indicator buffers
double BufHigh[];
double BufLow[];
//--- time of the last bar that raised an alert
datetime g_lastAlertBar = 0;

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
   if(InpStrength < 1)
     {
      Print("InpStrength must be >= 1");
      return INIT_PARAMETERS_INCORRECT;
     }
   SetIndexBuffer(0, BufHigh, INDICATOR_DATA);
   SetIndexBuffer(1, BufLow,  INDICATOR_DATA);
   PlotIndexSetInteger(0, PLOT_ARROW, 234);          // down arrow above the high
   PlotIndexSetInteger(1, PLOT_ARROW, 233);          // up arrow below the low
   PlotIndexSetInteger(0, PLOT_ARROW_SHIFT, -10);
   PlotIndexSetInteger(1, PLOT_ARROW_SHIFT, 10);
   PlotIndexSetDouble(0, PLOT_EMPTY_VALUE, EMPTY_VALUE);
   PlotIndexSetDouble(1, PLOT_EMPTY_VALUE, EMPTY_VALUE);
   PlotIndexSetInteger(0, PLOT_DRAW_BEGIN, InpStrength);
   PlotIndexSetInteger(1, PLOT_DRAW_BEGIN, InpStrength);
   ArraySetAsSeries(BufHigh, false);
   ArraySetAsSeries(BufLow,  false);
   IndicatorSetString(INDICATOR_SHORTNAME, "ATS Confirmed Swings (" + IntegerToString(InpStrength) + ")");
   return INIT_SUCCEEDED;
  }

//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total, const int prev_calculated,
                const datetime &time[], const double &open[],
                const double &high[], const double &low[],
                const double &close[], const long &tick_volume[],
                const long &volume[], const int &spread[])
  {
   const int S = InpStrength;
   if(rates_total < 2 * S + 3)
      return 0;

//--- bar rates_total-1 is still forming; the last bar that can be confirmed
//--- needs S CLOSED bars to its right: i + S <= rates_total - 2
   const int lastConfirmable = rates_total - 2 - S;

   int start;
   if(prev_calculated == 0)
     {
      start = S;
      if(InpMaxBars > 0)
         start = MathMax(S, rates_total - InpMaxBars);
      ArrayInitialize(BufHigh, EMPTY_VALUE);
      ArrayInitialize(BufLow,  EMPTY_VALUE);
     }
   else
      start = MathMax(S, prev_calculated - 1 - S - 1);

   for(int i = start; i <= lastConfirmable; i++)
     {
      bool isHigh = true, isLow = true;
      for(int k = 1; k <= S; k++)
        {
         if(high[i] <= high[i - k] || high[i] < high[i + k]) isHigh = false;
         if(low[i]  >= low[i - k]  || low[i]  > low[i + k])  isLow  = false;
         if(!isHigh && !isLow) break;
        }
      BufHigh[i] = isHigh ? high[i] : EMPTY_VALUE;
      BufLow[i]  = isLow  ? low[i]  : EMPTY_VALUE;
     }

//--- the not-yet-confirmable tail must stay empty so nothing is ever drawn early
   for(int j = MathMax(0, lastConfirmable + 1); j < rates_total; j++)
     {
      BufHigh[j] = EMPTY_VALUE;
      BufLow[j]  = EMPTY_VALUE;
     }

//--- alert once per newly confirmed swing
   if((InpAlert || InpPush) && prev_calculated > 0 && lastConfirmable >= 0)
     {
      datetime barTime = time[lastConfirmable];
      if(barTime != g_lastAlertBar)
        {
         string msg = "";
         if(BufHigh[lastConfirmable] != EMPTY_VALUE)
            msg = _Symbol + " " + EnumToString(_Period) + ": swing HIGH confirmed at " +
                  DoubleToString(high[lastConfirmable], _Digits);
         else if(BufLow[lastConfirmable] != EMPTY_VALUE)
            msg = _Symbol + " " + EnumToString(_Period) + ": swing LOW confirmed at " +
                  DoubleToString(low[lastConfirmable], _Digits);
         g_lastAlertBar = barTime;
         if(msg != "")
           {
            if(InpAlert) Alert(msg);
            if(InpPush)  SendNotification(msg);
           }
        }
     }
   return rates_total;
  }
//+------------------------------------------------------------------+
