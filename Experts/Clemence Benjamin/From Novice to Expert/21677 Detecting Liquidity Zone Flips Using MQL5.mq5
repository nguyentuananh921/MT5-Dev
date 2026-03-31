//+------------------------------------------------------------------+
//|                                     Liquidity Zone Flip Indicator|
//|                                Copyright © 2025 Clemence Benjamin|
//|             https://www.mql5.com/en/users/billionaire2024/seller |
//+------------------------------------------------------------------+
#property copyright "Clemence Benjamin"
#property link      "https://www.mql5.com/en/users/billionaire2024/seller"
#property version   "4.00"
#property indicator_chart_window
#property indicator_buffers 2
#property indicator_plots   2

//--- Inputs for zone detection (higher timeframe)
input ENUM_TIMEFRAMES ZoneTimeframe   = PERIOD_H1;      // Timeframe for zone detection
input int             LookbackBars    = 1000;           // Number of bars on higher TF to look back
input double          RatioMultiplier = 3.0;            // Ratio Multiplier for zone formation
input int             ExtendBars      = 50;             // Bars to extend rectangle right (on higher TF)
input bool            FillRectangles  = true;           // Fill or just border?
input color           DemandZoneColor = clrLimeGreen;   // Demand zone rectangle color
input color           SupplyZoneColor = clrTomato;      // Supply zone rectangle color
input uchar           ZoneOpacity     = 40;             // 0-255 transparency

//--- Inputs for reaction signals (current timeframe)
input color           DemandArrowColor = clrLimeGreen;  // Buy arrow color
input color           SupplyArrowColor = clrRed;        // Sell arrow color
input int             ArrowSize        = 1;             // Arrow width

//--- Inputs for zone flipping (new intelligence)
input bool            EnableZoneFlipping = true;        // Enable flipping zones after impulsive violation
input double          ViolationMultiplier = 1.5;        // Multiplier for impulsive violation (zone height)

//--- Arrow buffers
double BuyArrow[];
double SellArrow[];

//--- Current timeframe data arrays (for reversal patterns)
double Open[], Close[], High[], Low[];
datetime TimeArray[];

//--- Global variables
double   myPoint;
int      htfPeriodSeconds;          // period seconds of the higher timeframe
int      currentPeriodSeconds;      // period seconds of current chart
datetime lastHtfUpdateTime = 0;     // last time zones were updated
datetime lastAlertTime = 0;         // for alert throttling

//+------------------------------------------------------------------+
//| Zone structure                                                   |
//+------------------------------------------------------------------+
struct LiquidityZone
  {
   double            high;          // zone top price
   double            low;           // zone bottom price
   datetime          start_time;    // bar time where zone was formed (or flipped)
   datetime          expiry_time;   // time when zone expires (start + ExtendBars * htfPeriod)
   bool              demand;        // true = demand, false = supply
   bool              triggered;     // true if a signal already fired in this zone
  };

LiquidityZone zones[];      // dynamic array of currently active zones

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
   myPoint = Point();
   if(_Digits == 5 || _Digits == 3)
      myPoint *= 10;

//--- Set arrow buffers
   SetIndexBuffer(0, BuyArrow, INDICATOR_DATA);
   SetIndexBuffer(1, SellArrow, INDICATOR_DATA);

   ArraySetAsSeries(BuyArrow, true);
   ArraySetAsSeries(SellArrow, true);

   PlotIndexSetInteger(0, PLOT_DRAW_TYPE, DRAW_ARROW);
   PlotIndexSetInteger(0, PLOT_ARROW, 233);                 // up arrow
   PlotIndexSetString(0, PLOT_LABEL, "Buy");
   PlotIndexSetInteger(0, PLOT_LINE_COLOR, DemandArrowColor);
   PlotIndexSetInteger(0, PLOT_LINE_WIDTH, ArrowSize);

   PlotIndexSetInteger(1, PLOT_DRAW_TYPE, DRAW_ARROW);
   PlotIndexSetInteger(1, PLOT_ARROW, 234);                 // down arrow
   PlotIndexSetString(1, PLOT_LABEL, "Sell");
   PlotIndexSetInteger(1, PLOT_LINE_COLOR, SupplyArrowColor);
   PlotIndexSetInteger(1, PLOT_LINE_WIDTH, ArrowSize);

   ArrayInitialize(BuyArrow, EMPTY_VALUE);
   ArrayInitialize(SellArrow, EMPTY_VALUE);

//--- Period seconds for time calculations
   currentPeriodSeconds = PeriodSeconds();
   htfPeriodSeconds = PeriodSeconds(ZoneTimeframe);
   if(htfPeriodSeconds <= 0)
      htfPeriodSeconds = 3600;      // fallback to 1 hour

//--- Initial update of zones (will be done in OnCalculate)
   lastHtfUpdateTime = 0;

   return(INIT_SUCCEEDED);
  }

//+------------------------------------------------------------------+
//| Deinitialization                                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   DeleteAllZones();
  }

//+------------------------------------------------------------------+
//| Delete all drawn zone rectangles                                 |
//+------------------------------------------------------------------+
void DeleteAllZones()
  {
   for(int i = ObjectsTotal(0, 0, -1) - 1; i >= 0; i--)
     {
      string name = ObjectName(0, i);
      if(StringFind(name, "LiqZone_") == 0)
         ObjectDelete(0, name);
     }
   ChartRedraw();
  }

//+------------------------------------------------------------------+
//| Draw a single zone rectangle                                     |
//+------------------------------------------------------------------+
void DrawZone(datetime start_time, datetime expiry_time,
              double price_top, double price_bottom, bool isDemand)
  {
   string obj_name = "LiqZone_" + IntegerToString(start_time) + "_" + IntegerToString(expiry_time);
   if(ObjectFind(0, obj_name) >= 0)
      ObjectDelete(0, obj_name);

   color zone_color = isDemand ? DemandZoneColor : SupplyZoneColor;

   if(ObjectCreate(0, obj_name, OBJ_RECTANGLE, 0,
                   start_time, price_top, expiry_time, price_bottom))
     {
      ObjectSetInteger(0, obj_name, OBJPROP_COLOR, zone_color);
      ObjectSetInteger(0, obj_name, OBJPROP_STYLE, STYLE_SOLID);
      ObjectSetInteger(0, obj_name, OBJPROP_WIDTH, 1);
      ObjectSetInteger(0, obj_name, OBJPROP_FILL, FillRectangles);
      ObjectSetInteger(0, obj_name, OBJPROP_BACK, true);          // behind price
      ObjectSetInteger(0, obj_name, OBJPROP_SELECTABLE, false);

      if(FillRectangles)
        {
         color fill_clr = (color)ColorToARGB(zone_color, ZoneOpacity);
         ObjectSetInteger(0, obj_name, OBJPROP_BGCOLOR, fill_clr);
        }
     }
  }

//+------------------------------------------------------------------+
//| Update zones from higher timeframe data (add new, never delete) |
//+------------------------------------------------------------------+
void UpdateZones()
  {
//--- Copy higher timeframe data
   double htf_open[], htf_close[], htf_high[], htf_low[];
   datetime htf_time[];
   int htf_bars = CopyOpen(Symbol(), ZoneTimeframe, 0, LookbackBars, htf_open);
   if(htf_bars <= 0)
      return;
   CopyClose(Symbol(), ZoneTimeframe, 0, LookbackBars, htf_close);
   CopyHigh(Symbol(), ZoneTimeframe, 0, LookbackBars, htf_high);
   CopyLow(Symbol(), ZoneTimeframe, 0, LookbackBars, htf_low);
   CopyTime(Symbol(), ZoneTimeframe, 0, LookbackBars, htf_time);

//--- Work with series (index 0 = most recent)
   ArraySetAsSeries(htf_open,  true);
   ArraySetAsSeries(htf_close, true);
   ArraySetAsSeries(htf_high,  true);
   ArraySetAsSeries(htf_low,   true);
   ArraySetAsSeries(htf_time,  true);

//--- Scan higher timeframe bars for zones
   for(int i = htf_bars - 5; i >= 2; i--)
     {
      int base_idx    = i + 2;
      int impulse_idx = i + 1;

      if(base_idx >= htf_bars)
         continue;

      double base_range    = htf_high[base_idx] - htf_low[base_idx];
      double impulse_range = htf_high[impulse_idx] - htf_low[impulse_idx];

      if(base_range <= 0)
         continue;

      //--- Demand zone condition (both bars bullish, impulse expands)
      if(htf_open[base_idx] < htf_close[base_idx] &&
         htf_open[impulse_idx] < htf_close[impulse_idx] &&
         impulse_range >= base_range * RatioMultiplier)
        {
         //--- Check if zone with this start_time already exists (to avoid duplicates)
         bool exists = false;
         for(int j = 0; j < ArraySize(zones); j++)
           {
            if(zones[j].start_time == htf_time[base_idx])
              {
               exists = true;
               break;
              }
           }
         if(!exists)
           {
            LiquidityZone z;
            z.high        = htf_high[base_idx];
            z.low         = htf_low[base_idx];
            z.start_time  = htf_time[base_idx];
            z.expiry_time = z.start_time + ExtendBars * htfPeriodSeconds;
            z.demand      = true;
            z.triggered   = false;

            int size = ArraySize(zones);
            ArrayResize(zones, size + 1);
            zones[size] = z;

            DrawZone(z.start_time, z.expiry_time, z.high, z.low, true);
           }
        }

      //--- Supply zone condition (both bars bearish, impulse expands)
      if(htf_open[base_idx] > htf_close[base_idx] &&
         htf_open[impulse_idx] > htf_close[impulse_idx] &&
         impulse_range >= base_range * RatioMultiplier)
        {
         bool exists = false;
         for(int j = 0; j < ArraySize(zones); j++)
           {
            if(zones[j].start_time == htf_time[base_idx])
              {
               exists = true;
               break;
              }
           }
         if(!exists)
           {
            LiquidityZone z;
            z.high        = htf_high[base_idx];
            z.low         = htf_low[base_idx];
            z.start_time  = htf_time[base_idx];
            z.expiry_time = z.start_time + ExtendBars * htfPeriodSeconds;
            z.demand      = false;
            z.triggered   = false;

            int size = ArraySize(zones);
            ArrayResize(zones, size + 1);
            zones[size] = z;

            DrawZone(z.start_time, z.expiry_time, z.high, z.low, false);
           }
        }
     }
  }

//+------------------------------------------------------------------+
//| Remove expired zones from array and chart                        |
//+------------------------------------------------------------------+
void RemoveExpiredZones()
  {
   datetime current_time = TimeCurrent();
   for(int i = ArraySize(zones) - 1; i >= 0; i--)
     {
      if(current_time > zones[i].expiry_time)
        {
         // Delete rectangle
         string obj_name = "LiqZone_" + IntegerToString(zones[i].start_time) + "_" + IntegerToString(zones[i].expiry_time);
         ObjectDelete(0, obj_name);

         // Remove from array
         for(int j = i; j < ArraySize(zones) - 1; j++)
            zones[j] = zones[j + 1];
         ArrayResize(zones, ArraySize(zones) - 1);
        }
     }
  }

//+------------------------------------------------------------------+
//| Flip a zone (change its role) after impulsive violation         |
//+------------------------------------------------------------------+
void FlipZone(int zoneIndex, bool newDemand, datetime violation_time)
  {
   if(zoneIndex < 0 || zoneIndex >= ArraySize(zones))
      return;

// Delete old rectangle
   string obj_name = "LiqZone_" + IntegerToString(zones[zoneIndex].start_time) + "_" + IntegerToString(zones[zoneIndex].expiry_time);
   ObjectDelete(0, obj_name);

// Update zone properties (keep same start_time to avoid HTF re-creation)
   zones[zoneIndex].demand      = newDemand;
   zones[zoneIndex].expiry_time = violation_time + ExtendBars * htfPeriodSeconds;
   zones[zoneIndex].triggered   = false;   // reset reaction trigger

// Draw new rectangle with updated role and expiry
   DrawZone(zones[zoneIndex].start_time, zones[zoneIndex].expiry_time,
            zones[zoneIndex].high, zones[zoneIndex].low, newDemand);
  }

//+------------------------------------------------------------------+
//| Reversal pattern functions (use current timeframe data)         |
//+------------------------------------------------------------------+
bool BullishEngulfing(int i)
  {
   if(Close[i] > Open[i] &&
      Close[i+1] < Open[i+1] &&
      Close[i] > Open[i+1] &&
      Open[i] < Close[i+1])
      return true;
   return false;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool BearishEngulfing(int i)
  {
   if(Close[i] < Open[i] &&
      Close[i+1] > Open[i+1] &&
      Open[i] > Close[i+1] &&
      Close[i] < Open[i+1])
      return true;
   return false;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool BullishPinBar(int i)
  {
   double body = MathAbs(Close[i] - Open[i]);
   double lower = MathMin(Open[i], Close[i]) - Low[i];
   if(lower > body * 2)
      return true;
   return false;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool BearishPinBar(int i)
  {
   double body = MathAbs(Close[i] - Open[i]);
   double upper = High[i] - MathMax(Open[i], Close[i]);
   if(upper > body * 2)
      return true;
   return false;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool BullishInsideBreak(int i)
  {
   if(High[i] < High[i+1] && Low[i] > Low[i+1])
      if(Close[i] > High[i+1])
         return true;
   return false;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool BearishInsideBreak(int i)
  {
   if(High[i] < High[i+1] && Low[i] > Low[i+1])
      if(Close[i] < Low[i+1])
         return true;
   return false;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool DemandReversal(int i)
  {
   if(BullishEngulfing(i))
      return true;
   if(BullishPinBar(i))
      return true;
   if(BullishInsideBreak(i))
      return true;
   return false;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool SupplyReversal(int i)
  {
   if(BearishEngulfing(i))
      return true;
   if(BearishPinBar(i))
      return true;
   if(BearishInsideBreak(i))
      return true;
   return false;
  }

//+------------------------------------------------------------------+
//| Check if a bar is inside a zone                                  |
//+------------------------------------------------------------------+
bool PriceInsideZone(int bar, const LiquidityZone &z,
                     const double &high[], const double &low[])
  {
   if(high[bar] >= z.low && low[bar] <= z.high)
      return true;
   return false;
  }

//+------------------------------------------------------------------+
//| OnCalculate                                                      |
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
   if(rates_total < 5)
      return 0;

//--- Copy current timeframe data into our global arrays (as series)
   int barsNeeded = MathMin(rates_total, 5000);  // safe upper limit
   CopyOpen(Symbol(), PERIOD_CURRENT, 0, barsNeeded, Open);
   CopyClose(Symbol(), PERIOD_CURRENT, 0, barsNeeded, Close);
   CopyHigh(Symbol(), PERIOD_CURRENT, 0, barsNeeded, High);
   CopyLow(Symbol(), PERIOD_CURRENT, 0, barsNeeded, Low);
   CopyTime(Symbol(), PERIOD_CURRENT, 0, barsNeeded, TimeArray);

   ArraySetAsSeries(Open,      true);
   ArraySetAsSeries(Close,     true);
   ArraySetAsSeries(High,      true);
   ArraySetAsSeries(Low,       true);
   ArraySetAsSeries(TimeArray, true);

//--- Update zones when a new higher timeframe bar appears
   datetime latestHtfTime = iTime(Symbol(), ZoneTimeframe, 0);
   if(latestHtfTime != lastHtfUpdateTime)
     {
      UpdateZones();      // adds new HTF zones without deleting existing ones
      lastHtfUpdateTime = latestHtfTime;
     }

//--- Remove expired zones
   RemoveExpiredZones();

//--- Reaction monitoring on the most recent closed bar (index 1)
   int signal_bar = 1;   // closed bar
   if(signal_bar >= rates_total)
      return rates_total;

//--- First, check for reversal signals (original logic)
   for(int z = 0; z < ArraySize(zones); z++)
     {
      if(TimeCurrent() > zones[z].expiry_time)   // already expired (should have been removed, but just in case)
         continue;
      if(zones[z].triggered)
         continue;

      if(PriceInsideZone(signal_bar, zones[z], High, Low))
        {
         if(zones[z].demand)
           {
            if(DemandReversal(signal_bar))
              {
               BuyArrow[signal_bar] = Low[signal_bar] - 5 * myPoint;
               zones[z].triggered = true;

               if(TimeArray[signal_bar] != lastAlertTime)
                 {
                  Alert("Demand Zone BUY Reaction ", Symbol(), " ", EnumToString(_Period));
                  lastAlertTime = TimeArray[signal_bar];
                 }
              }
           }
         else // supply zone
           {
            if(SupplyReversal(signal_bar))
              {
               SellArrow[signal_bar] = High[signal_bar] + 5 * myPoint;
               zones[z].triggered = true;

               if(TimeArray[signal_bar] != lastAlertTime)
                 {
                  Alert("Supply Zone SELL Reaction ", Symbol(), " ", EnumToString(_Period));
                  lastAlertTime = TimeArray[signal_bar];
                 }
              }
           }
        }
     }

//--- Second, check for impulsive violations (zone flipping)
   if(EnableZoneFlipping)
     {
      for(int z = 0; z < ArraySize(zones); z++)
        {
         if(TimeCurrent() > zones[z].expiry_time)
            continue;

         double zoneHeight = zones[z].high - zones[z].low;
         double barRange = High[signal_bar] - Low[signal_bar];

         // Supply zone (resistance) violated to the upside -> becomes demand
         if(!zones[z].demand)   // supply
           {
            if(Close[signal_bar] > zones[z].high &&          // close above zone
               Close[signal_bar] > Open[signal_bar] &&       // bullish bar
               barRange >= zoneHeight * ViolationMultiplier) // impulsive move
              {
               FlipZone(z, true, TimeArray[signal_bar]);     // flip to demand
               // Break to avoid re-processing same zone (array might shift, but we continue safely)
              }
           }
         // Demand zone (support) violated to the downside -> becomes supply
         else  // demand
           {
            if(Close[signal_bar] < zones[z].low &&           // close below zone
               Close[signal_bar] < Open[signal_bar] &&       // bearish bar
               barRange >= zoneHeight * ViolationMultiplier) // impulsive move
              {
               FlipZone(z, false, TimeArray[signal_bar]);    // flip to supply
              }
           }
        }
     }

   return(rates_total);
  }
//+------------------------------------------------------------------+

