//+------------------------------------------------------------------+
//|                                        RSIDivergenceDetector.mq5 |
//|                               Copyright 2025, Clemence Benjamin. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2025, Clemence Benjamin."
#property link      "https://www.mql5.com"
#property description "RSI Divergence Detector with Main Chart Arrows"
#property description "Shows divergence arrows on main chart, stores pivot values"

#property indicator_separate_window
#property indicator_buffers 7
#property indicator_plots   3
#property indicator_color1  clrDodgerBlue      // RSI line
#property indicator_color2  clrOrange          // RSI High Pivots
#property indicator_color3  clrDeepSkyBlue     // RSI Low Pivots
#property indicator_width1  2
#property indicator_width2  3
#property indicator_width3  3
#property indicator_label1  "RSI"
#property indicator_label2  "RSI High Pivot"
#property indicator_label3  "RSI Low Pivot"

//--- Input parameters
input int                InpRSIPeriod     = 14;            // RSI Period
input ENUM_APPLIED_PRICE InpRSIPrice      = PRICE_CLOSE;   // RSI Applied Price
input int                InpPivotStrength = 3;             // Pivot Strength (bars on each side)
input double             InpOverbought    = 70.0;          // Overbought Level
input double             InpOversold      = 30.0;          // Oversold Level
input bool               InpShowRegular   = true;          // Show Regular Divergences
input bool               InpShowHidden    = true;          // Show Hidden Divergences
input color              InpBullishColor  = clrLimeGreen;  // Bullish divergence arrow color
input color              InpBearishColor  = clrRed;        // Bearish divergence arrow color
input int                InpArrowSize     = 3;             // Arrow size on chart
input bool               InpAlertOnDivergence = true;      // Alert on divergence
input bool               InpSendNotification = false;      // Send notification
input bool               InpRequireRSIBreak = true;        // Require RSI to break pivot line
input double             InpMinDivergenceStrength = 2.0;   // Minimum RSI divergence strength
input int                InpMaxPivotDistance = 100;        // Max bars between pivots for divergence
input double             InpArrowOffsetPct = 0.3;          // Arrow offset percentage (0.3 = 30%)

//--- Indicator buffers
double BufferRSI[];
double BufferRSIHighPivot[];
double BufferRSILowPivot[];
double BufferRSIHigh[];
double BufferRSILow[];
double BufferPivotHigh[];
double BufferPivotLow[];

//--- Global variables
int rsiHandle;
datetime lastAlertTime;
string indicatorPrefix = "RSI_DIV_";

//--- Structures for storing pivot data
struct RSI_PIVOT
{
   int barIndex;
   double value;
   double price;
   datetime time;
   bool isHigh;
   int strength;
   bool isConfirmed;
   
   // Constructor to initialize values
   RSI_PIVOT() : barIndex(-1), value(0.0), price(0.0), time(0), 
                 isHigh(false), strength(0), isConfirmed(false) {}
};

RSI_PIVOT rsiPivots[];
int pivotCount = 0;

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
{
   SetIndexBuffer(0, BufferRSI, INDICATOR_DATA);
   SetIndexBuffer(1, BufferRSIHighPivot, INDICATOR_DATA);
   SetIndexBuffer(2, BufferRSILowPivot, INDICATOR_DATA);
   SetIndexBuffer(3, BufferRSIHigh, INDICATOR_DATA);
   SetIndexBuffer(4, BufferRSILow, INDICATOR_DATA);
   SetIndexBuffer(5, BufferPivotHigh, INDICATOR_DATA);
   SetIndexBuffer(6, BufferPivotLow, INDICATOR_DATA);
   
   //--- Set plot properties
   PlotIndexSetInteger(0, PLOT_DRAW_TYPE, DRAW_LINE);
   PlotIndexSetInteger(1, PLOT_DRAW_TYPE, DRAW_ARROW);
   PlotIndexSetInteger(2, PLOT_DRAW_TYPE, DRAW_ARROW);
   
   //--- Set arrow codes for RSI pivot points
   PlotIndexSetInteger(1, PLOT_ARROW, 159);  // Square dot for high pivots
   PlotIndexSetInteger(2, PLOT_ARROW, 159);  // Square dot for low pivots
   
   //--- Set empty values for arrow buffers
   PlotIndexSetDouble(1, PLOT_EMPTY_VALUE, EMPTY_VALUE);
   PlotIndexSetDouble(2, PLOT_EMPTY_VALUE, EMPTY_VALUE);
   
   //--- Set indicator labels
   IndicatorSetString(INDICATOR_SHORTNAME, "RSI Divergence (" + string(InpRSIPeriod) + ")");
   IndicatorSetInteger(INDICATOR_DIGITS, 2);
   
   //--- Create RSI handle
   rsiHandle = iRSI(_Symbol, _Period, InpRSIPeriod, InpRSIPrice);
   if(rsiHandle == INVALID_HANDLE)
   {
      Print("Failed to create RSI handle");
      return(INIT_FAILED);
   }
   
   //--- Set overbought/oversold levels
   IndicatorSetDouble(INDICATOR_LEVELVALUE, 0, InpOversold);
   IndicatorSetDouble(INDICATOR_LEVELVALUE, 1, InpOverbought);
   IndicatorSetInteger(INDICATOR_LEVELCOLOR, 0, clrSilver);
   IndicatorSetInteger(INDICATOR_LEVELCOLOR, 1, clrSilver);
   IndicatorSetInteger(INDICATOR_LEVELSTYLE, 0, STYLE_DOT);
   IndicatorSetInteger(INDICATOR_LEVELSTYLE, 1, STYLE_DOT);
   
   lastAlertTime = 0;
   
   //--- Clean any existing objects from previous runs
   CleanChartObjects();
   
   return(INIT_SUCCEEDED);
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
   if(rates_total < InpRSIPeriod + 10) return(0);
   
   int start;
   if(prev_calculated == 0)
   {
      start = InpRSIPeriod + InpPivotStrength;
      ArrayResize(rsiPivots, rates_total);
      pivotCount = 0;
      CleanChartObjects();
   }
   else
   {
      start = prev_calculated - 1;
   }
   
   //--- Get RSI values
   if(CopyBuffer(rsiHandle, 0, 0, rates_total, BufferRSI) <= 0)
      return(0);
   
   //--- Find RSI pivots
   FindRSIPivots(rates_total, start, high, low, time);
   
   //--- Detect divergences and draw arrows on main chart
   DetectDivergences(rates_total, start, high, low, close, time);
   
   //--- Clean old pivot data
   CleanOldPivots(rates_total);
   
   return(rates_total);
}

//+------------------------------------------------------------------+
//| Find RSI pivots function                                         |
//+------------------------------------------------------------------+
void FindRSIPivots(int rates_total, int start, const double &high[], const double &low[], const datetime &time[])
{
   // Clear pivot buffers
   ArrayFill(BufferRSIHighPivot, start, rates_total - start, EMPTY_VALUE);
   ArrayFill(BufferRSILowPivot, start, rates_total - start, EMPTY_VALUE);
   
   for(int i = start; i < rates_total - InpPivotStrength; i++)
   {
      //--- Check for RSI high pivot
      if(IsHighPivot(i, BufferRSI, InpPivotStrength))
      {
         if(pivotCount < ArraySize(rsiPivots))
         {
            rsiPivots[pivotCount].barIndex = i;
            rsiPivots[pivotCount].value = BufferRSI[i];
            rsiPivots[pivotCount].price = high[i];
            rsiPivots[pivotCount].time = time[i];
            rsiPivots[pivotCount].isHigh = true;
            rsiPivots[pivotCount].strength = InpPivotStrength;
            rsiPivots[pivotCount].isConfirmed = false;
            pivotCount++;
            
            BufferRSIHighPivot[i] = BufferRSI[i];
         }
      }
      
      //--- Check for RSI low pivot
      if(IsLowPivot(i, BufferRSI, InpPivotStrength))
      {
         if(pivotCount < ArraySize(rsiPivots))
         {
            rsiPivots[pivotCount].barIndex = i;
            rsiPivots[pivotCount].value = BufferRSI[i];
            rsiPivots[pivotCount].price = low[i];
            rsiPivots[pivotCount].time = time[i];
            rsiPivots[pivotCount].isHigh = false;
            rsiPivots[pivotCount].strength = InpPivotStrength;
            rsiPivots[pivotCount].isConfirmed = false;
            pivotCount++;
            
            BufferRSILowPivot[i] = BufferRSI[i];
         }
      }
   }
}

//+------------------------------------------------------------------+
//| Check if bar is a high pivot                                     |
//+------------------------------------------------------------------+
bool IsHighPivot(int index, double &buffer[], int strength)
{
   if(index < strength || index >= ArraySize(buffer) - strength)
      return false;
   
   double pivotValue = buffer[index];
   
   // Check left side
   for(int i = 1; i <= strength; i++)
   {
      if(buffer[index - i] > pivotValue)
         return false;
   }
   
   // Check right side
   for(int i = 1; i <= strength; i++)
   {
      if(buffer[index + i] > pivotValue)
         return false;
   }
   
   return true;
}

//+------------------------------------------------------------------+
//| Check if bar is a low pivot                                      |
//+------------------------------------------------------------------+
bool IsLowPivot(int index, double &buffer[], int strength)
{
   if(index < strength || index >= ArraySize(buffer) - strength)
      return false;
   
   double pivotValue = buffer[index];
   
   // Check left side
   for(int i = 1; i <= strength; i++)
   {
      if(buffer[index - i] < pivotValue)
         return false;
   }
   
   // Check right side
   for(int i = 1; i <= strength; i++)
   {
      if(buffer[index + i] < pivotValue)
         return false;
   }
   
   return true;
}

//+------------------------------------------------------------------+
//| Detect divergences between price and RSI                         |
//+------------------------------------------------------------------+
void DetectDivergences(int rates_total, int start, const double &high[], const double &low[], 
                      const double &close[], const datetime &time[])
{
   if(pivotCount < 4) return;
   
   // Check all pivot pairs for divergence
   for(int i = pivotCount - 1; i >= 0; i--)
   {
      for(int j = i - 1; j >= 0; j--)
      {
         // Skip if pivots are too far apart
         if(rsiPivots[i].barIndex - rsiPivots[j].barIndex > InpMaxPivotDistance)
            continue;
         
         // Check if both are high pivots
         if(rsiPivots[i].isHigh && rsiPivots[j].isHigh)
         {
            // Check for regular bearish divergence
            if(InpShowRegular && CheckBearishDivergence(rsiPivots[i], rsiPivots[j], rates_total))
            {
               // Check RSI break confirmation if required
               if(!InpRequireRSIBreak || CheckRSIBreak(rsiPivots[j], rsiPivots[i], rates_total, true))
               {
                  double arrowPrice = high[rsiPivots[i].barIndex];
                  double range = high[rsiPivots[i].barIndex] - low[rsiPivots[i].barIndex];
                  double offset = range * InpArrowOffsetPct;
                  
                  DrawChartArrow(rsiPivots[i].barIndex, time[rsiPivots[i].barIndex], 
                                arrowPrice + offset, false, "Bearish");
                  TriggerAlert("Regular Bearish Divergence detected!", time[rsiPivots[i].barIndex]);
                  // Mark as confirmed to avoid duplicate signals
                  rsiPivots[i].isConfirmed = true;
                  rsiPivots[j].isConfirmed = true;
               }
            }
            // Check for hidden bearish divergence
            else if(InpShowHidden && CheckHiddenBearishDivergence(rsiPivots[i], rsiPivots[j]))
            {
               if(!InpRequireRSIBreak || CheckRSIBreak(rsiPivots[j], rsiPivots[i], rates_total, true))
               {
                  double arrowPrice = high[rsiPivots[i].barIndex];
                  double range = high[rsiPivots[i].barIndex] - low[rsiPivots[i].barIndex];
                  double offset = range * InpArrowOffsetPct;
                  
                  DrawChartArrow(rsiPivots[i].barIndex, time[rsiPivots[i].barIndex], 
                                arrowPrice + offset, false, "Bearish(H)");
                  TriggerAlert("Hidden Bearish Divergence detected!", time[rsiPivots[i].barIndex]);
                  rsiPivots[i].isConfirmed = true;
                  rsiPivots[j].isConfirmed = true;
               }
            }
         }
         // Check if both are low pivots
         else if(!rsiPivots[i].isHigh && !rsiPivots[j].isHigh)
         {
            // Check for regular bullish divergence
            if(InpShowRegular && CheckBullishDivergence(rsiPivots[i], rsiPivots[j], rates_total))
            {
               // Check RSI break confirmation if required
               if(!InpRequireRSIBreak || CheckRSIBreak(rsiPivots[j], rsiPivots[i], rates_total, false))
               {
                  double arrowPrice = low[rsiPivots[i].barIndex];
                  double range = high[rsiPivots[i].barIndex] - low[rsiPivots[i].barIndex];
                  double offset = range * InpArrowOffsetPct;
                  
                  DrawChartArrow(rsiPivots[i].barIndex, time[rsiPivots[i].barIndex], 
                                arrowPrice - offset, true, "Bullish");
                  TriggerAlert("Regular Bullish Divergence detected!", time[rsiPivots[i].barIndex]);
                  rsiPivots[i].isConfirmed = true;
                  rsiPivots[j].isConfirmed = true;
               }
            }
            // Check for hidden bullish divergence
            else if(InpShowHidden && CheckHiddenBullishDivergence(rsiPivots[i], rsiPivots[j]))
            {
               if(!InpRequireRSIBreak || CheckRSIBreak(rsiPivots[j], rsiPivots[i], rates_total, false))
               {
                  double arrowPrice = low[rsiPivots[i].barIndex];
                  double range = high[rsiPivots[i].barIndex] - low[rsiPivots[i].barIndex];
                  double offset = range * InpArrowOffsetPct;
                  
                  DrawChartArrow(rsiPivots[i].barIndex, time[rsiPivots[i].barIndex], 
                                arrowPrice - offset, true, "Bullish(H)");
                  TriggerAlert("Hidden Bullish Divergence detected!", time[rsiPivots[i].barIndex]);
                  rsiPivots[i].isConfirmed = true;
                  rsiPivots[j].isConfirmed = true;
               }
            }
         }
      }
   }
}

//+------------------------------------------------------------------+
//| Check for regular bearish divergence                            |
//+------------------------------------------------------------------+
bool CheckBearishDivergence(RSI_PIVOT &pivot1, RSI_PIVOT &pivot2, int rates_total)
{
   // pivot1 is newer, pivot2 is older
   if(pivot1.barIndex <= pivot2.barIndex) return false;
   if(pivot1.barIndex >= rates_total - 1 || pivot2.barIndex >= rates_total - 1) return false;
   
   // Price makes higher high
   bool priceHigher = pivot1.price > pivot2.price;
   
   // RSI makes lower high
   bool rsiLower = pivot1.value < pivot2.value - InpMinDivergenceStrength;
   
   // Ensure there's enough divergence strength
   bool enoughStrength = MathAbs(pivot2.value - pivot1.value) >= InpMinDivergenceStrength;
   
   // Not already confirmed
   bool notConfirmed = !pivot1.isConfirmed && !pivot2.isConfirmed;
   
   return priceHigher && rsiLower && enoughStrength && notConfirmed;
}

//+------------------------------------------------------------------+
//| Check for regular bullish divergence                            |
//+------------------------------------------------------------------+
bool CheckBullishDivergence(RSI_PIVOT &pivot1, RSI_PIVOT &pivot2, int rates_total)
{
   // pivot1 is newer, pivot2 is older
   if(pivot1.barIndex <= pivot2.barIndex) return false;
   if(pivot1.barIndex >= rates_total - 1 || pivot2.barIndex >= rates_total - 1) return false;
   
   // Price makes lower low
   bool priceLower = pivot1.price < pivot2.price;
   
   // RSI makes higher low
   bool rsiHigher = pivot1.value > pivot2.value + InpMinDivergenceStrength;
   
   // Ensure there's enough divergence strength
   bool enoughStrength = MathAbs(pivot1.value - pivot2.value) >= InpMinDivergenceStrength;
   
   // Not already confirmed
   bool notConfirmed = !pivot1.isConfirmed && !pivot2.isConfirmed;
   
   return priceLower && rsiHigher && enoughStrength && notConfirmed;
}

//+------------------------------------------------------------------+
//| Check for hidden bearish divergence                             |
//+------------------------------------------------------------------+
bool CheckHiddenBearishDivergence(RSI_PIVOT &pivot1, RSI_PIVOT &pivot2)
{
   // Price makes lower high
   bool priceLower = pivot1.price < pivot2.price;
   
   // RSI makes higher high
   bool rsiHigher = pivot1.value > pivot2.value + InpMinDivergenceStrength;
   
   // Not already confirmed
   bool notConfirmed = !pivot1.isConfirmed && !pivot2.isConfirmed;
   
   return priceLower && rsiHigher && notConfirmed;
}

//+------------------------------------------------------------------+
//| Check for hidden bullish divergence                             |
//+------------------------------------------------------------------+
bool CheckHiddenBullishDivergence(RSI_PIVOT &pivot1, RSI_PIVOT &pivot2)
{
   // Price makes higher low
   bool priceHigher = pivot1.price > pivot2.price;
   
   // RSI makes lower low
   bool rsiLower = pivot1.value < pivot2.value - InpMinDivergenceStrength;
   
   // Not already confirmed
   bool notConfirmed = !pivot1.isConfirmed && !pivot2.isConfirmed;
   
   return priceHigher && rsiLower && notConfirmed;
}

//+------------------------------------------------------------------+
//| Check if RSI has broken the previous pivot level                |
//+------------------------------------------------------------------+
bool CheckRSIBreak(RSI_PIVOT &olderPivot, RSI_PIVOT &newerPivot, int rates_total, bool isBearish)
{
   // For bearish: Check if RSI has broken below the older pivot's value
   // For bullish: Check if RSI has broken above the older pivot's value
   
   if(newerPivot.barIndex >= rates_total - 1) return false;
   
   // Look for break in recent bars after newer pivot
   int lookbackBars = 10;
   int startBar = newerPivot.barIndex + 1;
   int endBar = MathMin(rates_total - 1, newerPivot.barIndex + lookbackBars);
   
   for(int i = startBar; i <= endBar; i++)
   {
      if(isBearish)
      {
         // Bearish: RSI should break below older pivot value
         if(BufferRSI[i] < olderPivot.value)
            return true;
      }
      else
      {
         // Bullish: RSI should break above older pivot value
         if(BufferRSI[i] > olderPivot.value)
            return true;
      }
   }
   
   return false;
}

//+------------------------------------------------------------------+
//| Draw arrow on main chart                                         |
//+------------------------------------------------------------------+
void DrawChartArrow(int barIndex, datetime time, double price, bool isBullish, string labelText)
{
   string arrowName = indicatorPrefix + "Arrow_" + IntegerToString(time);
   string labelName = indicatorPrefix + "Label_" + IntegerToString(time);
   
   // Remove existing objects with same name
   ObjectDelete(0, arrowName);
   ObjectDelete(0, labelName);
   
   if(isBullish)
   {
      // Draw bullish arrow (up arrow)
      if(!ObjectCreate(0, arrowName, OBJ_ARROW_BUY, 0, time, price))
      {
         Print("Failed to create arrow object: ", GetLastError());
         return;
      }
      
      ObjectSetInteger(0, arrowName, OBJPROP_COLOR, InpBullishColor);
      ObjectSetInteger(0, arrowName, OBJPROP_WIDTH, InpArrowSize);
      ObjectSetInteger(0, arrowName, OBJPROP_BACK, false);
      
      // Draw label
      if(!ObjectCreate(0, labelName, OBJ_TEXT, 0, time, price))
         return;
      
      ObjectSetString(0, labelName, OBJPROP_TEXT, labelText);
      ObjectSetInteger(0, labelName, OBJPROP_COLOR, InpBullishColor);
      ObjectSetInteger(0, labelName, OBJPROP_FONTSIZE, 8);
   }
   else
   {
      // Draw bearish arrow (down arrow)
      if(!ObjectCreate(0, arrowName, OBJ_ARROW_SELL, 0, time, price))
      {
         Print("Failed to create arrow object: ", GetLastError());
         return;
      }
      
      ObjectSetInteger(0, arrowName, OBJPROP_COLOR, InpBearishColor);
      ObjectSetInteger(0, arrowName, OBJPROP_WIDTH, InpArrowSize);
      ObjectSetInteger(0, arrowName, OBJPROP_BACK, false);
      
      // Draw label
      if(!ObjectCreate(0, labelName, OBJ_TEXT, 0, time, price))
         return;
      
      ObjectSetString(0, labelName, OBJPROP_TEXT, labelText);
      ObjectSetInteger(0, labelName, OBJPROP_COLOR, InpBearishColor);
      ObjectSetInteger(0, labelName, OBJPROP_FONTSIZE, 8);
   }
   
   ObjectSetInteger(0, labelName, OBJPROP_ANCHOR, ANCHOR_CENTER);
   ObjectSetInteger(0, labelName, OBJPROP_BACK, false);
}

//+------------------------------------------------------------------+
//| Clean chart objects                                              |
//+------------------------------------------------------------------+
void CleanChartObjects()
{
   int total = ObjectsTotal(0, 0, -1);
   for(int i = total - 1; i >= 0; i--)
   {
      string name = ObjectName(0, i, 0, -1);
      if(StringFind(name, indicatorPrefix, 0) != -1)
      {
         ObjectDelete(0, name);
      }
   }
}

//+------------------------------------------------------------------+
//| Clean old pivot data                                             |
//+------------------------------------------------------------------+
void CleanOldPivots(int rates_total)
{
   if(pivotCount > 500)  // Keep last 500 pivots maximum
   {
      int newCount = 250;
      for(int i = 0; i < newCount; i++)
      {
         rsiPivots[i] = rsiPivots[pivotCount - newCount + i];
      }
      pivotCount = newCount;
   }
}

//+------------------------------------------------------------------+
//| Trigger alert function                                           |
//+------------------------------------------------------------------+
void TriggerAlert(string message, datetime time)
{
   if(!InpAlertOnDivergence) return;
   
   // Avoid repeated alerts for same bar
   if(time <= lastAlertTime) return;
   
   lastAlertTime = time;
   
   // Play sound
   Alert(message + " at ", TimeToString(time, TIME_DATE|TIME_MINUTES));
   
   // Send notification if enabled
   if(InpSendNotification)
      SendNotification("RSI Divergence: " + Symbol() + " " + 
                       StringSubstr(EnumToString(_Period), 7) + 
                       " - " + message + " at " + TimeToString(time));
}

//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{
   // Delete RSI handle
   if(rsiHandle != INVALID_HANDLE)
      IndicatorRelease(rsiHandle);
   
   // Clean up chart objects
   CleanChartObjects();
}

//+------------------------------------------------------------------+