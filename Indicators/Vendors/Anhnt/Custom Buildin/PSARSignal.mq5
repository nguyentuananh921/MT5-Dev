//+------------------------------------------------------------------+
//|                                                  PSARSignal.mq5  |
//|         Wraps standard SAR handle, adds Buy/Sell signal buffers  |
//+------------------------------------------------------------------+
#property indicator_chart_window
#property indicator_buffers 3
#property indicator_plots   3

#property indicator_type1   DRAW_ARROW
#property indicator_label1  "PSAR"

#property indicator_type2   DRAW_ARROW
#property indicator_label2  "Buy"

#property indicator_type3   DRAW_ARROW
#property indicator_label3  "Sell"

input double InpSARStep      = 0.02;        // Step
input double InpSARMaximum   = 0.2;         // Maximum

input color  InpPSARColor    = clrDodgerBlue;  // PSAR dot color
input int    InpPSARArrowCode= 159;            // PSAR dot Wingdings code
input int    InpPSARWidth    = 1;              // PSAR dot size

input color  InpBuyColor     = clrLime;        // Buy arrow color
input int    InpBuyArrowCode = 233;            // Buy arrow Wingdings code
input int    InpBuyWidth     = 2;              // Buy arrow size

input color  InpSellColor    = clrRed;         // Sell arrow color
input int    InpSellArrowCode= 234;            // Sell arrow Wingdings code
input int    InpSellWidth    = 2;              // Sell arrow size


input bool InpShowPSAR = true;   // Show PSAR dot
input bool InpShowBuy  = true;   // Show Buy arrow
input bool InpShowSell = true;   // Show Sell arrow

double ExtSARBuffer[];
double ExtBuyBuffer[];
double ExtSellBuffer[];

int    ExtHandle = INVALID_HANDLE;

//+------------------------------------------------------------------+
int OnInit()
  {
   SetIndexBuffer(0, ExtSARBuffer,  INDICATOR_DATA);
   SetIndexBuffer(1, ExtBuyBuffer,  INDICATOR_DATA);
   SetIndexBuffer(2, ExtSellBuffer, INDICATOR_DATA);

   //--- styling, set trước khi tạo handle standard indicator
   PlotIndexSetInteger(0, PLOT_ARROW,      InpPSARArrowCode);
   PlotIndexSetInteger(0, PLOT_LINE_COLOR, InpPSARColor);
   PlotIndexSetInteger(0, PLOT_LINE_WIDTH, InpPSARWidth);

   PlotIndexSetInteger(1, PLOT_ARROW,      InpBuyArrowCode);
   PlotIndexSetInteger(1, PLOT_LINE_COLOR, InpBuyColor);
   PlotIndexSetInteger(1, PLOT_LINE_WIDTH, InpBuyWidth);

   PlotIndexSetInteger(2, PLOT_ARROW,      InpSellArrowCode);
   PlotIndexSetInteger(2, PLOT_LINE_COLOR, InpSellColor);
   PlotIndexSetInteger(2, PLOT_LINE_WIDTH, InpSellWidth);

   PlotIndexSetDouble(0, PLOT_EMPTY_VALUE, EMPTY_VALUE);
   PlotIndexSetDouble(1, PLOT_EMPTY_VALUE, EMPTY_VALUE);
   PlotIndexSetDouble(2, PLOT_EMPTY_VALUE, EMPTY_VALUE);

  //Show/Hide Plot
   PlotIndexSetInteger(0, PLOT_DRAW_TYPE, InpShowPSAR ? DRAW_ARROW : DRAW_NONE);
   PlotIndexSetInteger(1, PLOT_DRAW_TYPE, InpShowBuy  ? DRAW_ARROW : DRAW_NONE);
   PlotIndexSetInteger(2, PLOT_DRAW_TYPE, InpShowSell ? DRAW_ARROW : DRAW_NONE);

   //--- handle standard indicator
   ExtHandle = iSAR(NULL, 0, InpSARStep, InpSARMaximum);
   if(ExtHandle == INVALID_HANDLE)
     {
      Print("PSARSignal: failed to create SAR handle, error ", GetLastError());
      return(INIT_FAILED);
     }

   IndicatorSetString(INDICATOR_SHORTNAME, StringFormat("PSARSignal(%.2f,%.2f)", InpSARStep, InpSARMaximum));
   IndicatorSetInteger(INDICATOR_DIGITS, _Digits);

   return(INIT_SUCCEEDED);
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
   if(BarsCalculated(ExtHandle) < rates_total)
      return(0);

   if(CopyBuffer(ExtHandle, 0, 0, rates_total, ExtSARBuffer) <= 0)
      return(0);

   int start = (prev_calculated > 1) ? prev_calculated - 2 : 1;

   for(int i = start; i < rates_total; i++)
     {
      ExtBuyBuffer[i]  = EMPTY_VALUE;
      ExtSellBuffer[i] = EMPTY_VALUE;

      bool prev_above = close[i-1] > ExtSARBuffer[i-1];
      bool curr_above = close[i]   > ExtSARBuffer[i];

      double gap = (high[i] - low[i]) * 0.3;

      if(!prev_above && curr_above)
         ExtBuyBuffer[i]  = low[i]  - gap;
      else if(prev_above && !curr_above)
         ExtSellBuffer[i] = high[i] + gap;
     }

   return(rates_total);
  }
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   if(ExtHandle != INVALID_HANDLE)
      IndicatorRelease(ExtHandle);
  }
//+------------------------------------------------------------------+
