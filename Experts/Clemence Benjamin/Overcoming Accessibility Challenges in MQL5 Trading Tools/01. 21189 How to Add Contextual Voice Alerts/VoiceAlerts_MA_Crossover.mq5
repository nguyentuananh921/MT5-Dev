//+------------------------------------------------------------------+
//|                     VoiceAlerts_MA_Crossover.mq5                 |
//|          Accessibility-aware MA crossover indicator               |
//|                                                                  |
//|         Copyright 2025, Clemence Benjamin                         |
//|         https://www.mql5.com                                      |
//+------------------------------------------------------------------+
#property copyright "Copyright 2025, Clemence Benjamin"
#property link      "https://www.mql5.com"
#property version   "1.02"
#property indicator_chart_window
#property indicator_buffers 3
#property indicator_plots   2

//--- plots
#property indicator_label1  "Fast MA"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrDodgerBlue
#property indicator_width1  2

#property indicator_label2  "Slow MA"
#property indicator_type2   DRAW_LINE
#property indicator_color2  clrOrangeRed
#property indicator_width2  2

//--- sound resources
#resource "\\Sounds\\welcome.wav"
#resource "\\Sounds\\buy.wav"
#resource "\\Sounds\\sell.wav"

//--- inputs
input int               FastMAPeriod       = 9;
input int               SlowMAPeriod       = 21;
input int               ATRPeriod          = 14;
input ENUM_MA_METHOD    MaMethod           = MODE_EMA;
input ENUM_APPLIED_PRICE PriceType         = PRICE_CLOSE;

input bool              EnableSoundAlerts  = true;
input bool              EnableVisualArrows = true;
input bool              EnableWelcomeSound = true;

//--- buffers
double FastMABuffer[];
double SlowMABuffer[];
double ATRBuffer[];

//--- indicator handles
int FastMAHandle = INVALID_HANDLE;
int SlowMAHandle = INVALID_HANDLE;
int ATRHandle    = INVALID_HANDLE;

//--- state control
datetime LastBarTime      = 0;
datetime PendingSignalBar = 0;
string   PendingDirection;

//+------------------------------------------------------------------+
//| Initialization                                                   |
//+------------------------------------------------------------------+
int OnInit()
{
   SetIndexBuffer(0, FastMABuffer, INDICATOR_DATA);
   SetIndexBuffer(1, SlowMABuffer, INDICATOR_DATA);
   SetIndexBuffer(2, ATRBuffer,    INDICATOR_DATA);

   ArraySetAsSeries(FastMABuffer, true);
   ArraySetAsSeries(SlowMABuffer, true);
   ArraySetAsSeries(ATRBuffer,    true);

   FastMAHandle = iMA(_Symbol, _Period, FastMAPeriod, 0, MaMethod, PriceType);
   SlowMAHandle = iMA(_Symbol, _Period, SlowMAPeriod, 0, MaMethod, PriceType);
   ATRHandle    = iATR(_Symbol, _Period, ATRPeriod);

   if(FastMAHandle == INVALID_HANDLE ||
      SlowMAHandle == INVALID_HANDLE ||
      ATRHandle    == INVALID_HANDLE)
   {
      Print("Failed to create indicator handles");
      return INIT_FAILED;
   }

   if(EnableWelcomeSound)
      PlaySound("::Sounds\\welcome.wav");

   return INIT_SUCCEEDED;
}

//+------------------------------------------------------------------+
//| Deinitialization                                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{
   if(FastMAHandle != INVALID_HANDLE) IndicatorRelease(FastMAHandle);
   if(SlowMAHandle != INVALID_HANDLE) IndicatorRelease(SlowMAHandle);
   if(ATRHandle    != INVALID_HANDLE) IndicatorRelease(ATRHandle);
}

//+------------------------------------------------------------------+
//| Calculation                                                      |
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
   if(rates_total < SlowMAPeriod + 5)
      return 0;

   CopyBuffer(FastMAHandle, 0, 0, rates_total, FastMABuffer);
   CopyBuffer(SlowMAHandle, 0, 0, rates_total, SlowMABuffer);
   CopyBuffer(ATRHandle,    0, 0, rates_total, ATRBuffer);

   //--- new bar detection
   if(time[0] != LastBarTime)
   {
      LastBarTime = time[0];

      //--- fire pending alert on bar open
      if(PendingSignalBar != 0)
      {
         FireSignal(PendingDirection, PendingSignalBar, high, low);
         PendingSignalBar = 0;
      }

      //--- detect crossover on closed bar
      DetectCrossover(time);
   }

   return rates_total;
}

//+------------------------------------------------------------------+
//| Detect crossover                                                 |
//+------------------------------------------------------------------+
void DetectCrossover(const datetime &time[])
{
   int i = 1;

   double fast_prev = FastMABuffer[i + 1];
   double slow_prev = SlowMABuffer[i + 1];
   double fast_curr = FastMABuffer[i];
   double slow_curr = SlowMABuffer[i];

   if(fast_prev < slow_prev && fast_curr > slow_curr)
   {
      PendingSignalBar = time[i];
      PendingDirection = "BUY";
   }
   else if(fast_prev > slow_prev && fast_curr < slow_curr)
   {
      PendingSignalBar = time[i];
      PendingDirection = "SELL";
   }
}

//+------------------------------------------------------------------+
//| Fire signal                                                      |
//+------------------------------------------------------------------+
void FireSignal(string direction,
                datetime signal_time,
                const double &high[],
                const double &low[])
{
   if(EnableSoundAlerts)
   {
      if(direction == "BUY")
         PlaySound("::Sounds\\buy.wav");
      else
         PlaySound("::Sounds\\sell.wav");
   }

   DrawArrow(direction, signal_time, high, low);
}

//+------------------------------------------------------------------+
//| Draw Wingdings arrow                                             |
//+------------------------------------------------------------------+
void DrawArrow(string direction,
               datetime signal_time,
               const double &high[],
               const double &low[])
{
   if(!EnableVisualArrows)
      return;

   string name = "VA_ARROW_" + direction + "_" + (string)signal_time;
   if(ObjectFind(0, name) >= 0)
      return;

   int bar = iBarShift(_Symbol, _Period, signal_time);
   if(bar < 0) return;

   double atr   = ATRBuffer[bar];
   double price =
      direction == "BUY"
      ? low[bar]  - atr * 0.6
      : high[bar] + atr * 0.6;

   ObjectCreate(0, name, OBJ_ARROW, 0, signal_time, price);
   ObjectSetInteger(0, name, OBJPROP_ARROWCODE, direction == "BUY" ? 233 : 234);
   ObjectSetInteger(0, name, OBJPROP_COLOR, direction == "BUY" ? clrLime : clrRed);
   ObjectSetInteger(0, name, OBJPROP_WIDTH, 2);
}
//+------------------------------------------------------------------+
