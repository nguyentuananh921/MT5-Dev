//+------------------------------------------------------------------+
//|                                           SRProbabilityZones.mq5 |
//|                               Copyright 2025, Clemence Benjamin. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2025, Clemence Benjamin."
#property link      "https://www.mql5.com"
#property version   "1.01"
#property indicator_chart_window
#property indicator_buffers 4
#property indicator_plots   4

//--- Input Parameters (Optimized for M5)
input int    LookBackPeriod   = 150;    // Bars to analyze
input int    SwingSensitivity = 5;      // Swing detection (3-10)
input int    ZonePadding      = 20;     // Zone padding in points
input color  SupportColor     = clrRoyalBlue;   // Support zone color
input color  ResistanceColor  = clrCrimson;     // Resistance zone color
input bool   ShowZoneLabels   = true;   // Show zone labels

//--- Buffers
double SupportHighBuffer[];
double SupportLowBuffer[];
double ResistanceHighBuffer[];
double ResistanceLowBuffer[];

//+------------------------------------------------------------------+
//| Simple swing high detection                                     |
//+------------------------------------------------------------------+
bool IsSwingHighSimple(int index, int period, const double& high[])
{
   if(index < period || index >= ArraySize(high)-period)
      return false;
   
   double currentHigh = high[index];
   
   for(int i=1; i<=period; i++)
   {
      if(currentHigh <= high[index-i] || currentHigh <= high[index+i])
         return false;
   }
   return true;
}

//+------------------------------------------------------------------+
//| Simple swing low detection                                      |
//+------------------------------------------------------------------+
bool IsSwingLowSimple(int index, int period, const double& low[])
{
   if(index < period || index >= ArraySize(low)-period)
      return false;
   
   double currentLow = low[index];
   
   for(int i=1; i<=period; i++)
   {
      if(currentLow >= low[index-i] || currentLow >= low[index+i])
         return false;
   }
   return true;
}

//+------------------------------------------------------------------+
//| Find support and resistance zones (CORRECTED)                   |
//+------------------------------------------------------------------+
void FindZones(const double& high[], const double& low[], 
               double& supportHigh, double& supportLow,
               double& resistanceHigh, double& resistanceLow)
{
   double supportLevels[], resistanceLevels[];
   ArrayResize(supportLevels, 0);
   ArrayResize(resistanceLevels, 0);
   
   int limit = MathMin(ArraySize(high), LookBackPeriod);
   
   // Find swing points
   for(int i=SwingSensitivity; i<limit-SwingSensitivity; i++)
   {
      if(IsSwingLowSimple(i, SwingSensitivity, low))
      {
         ArrayResize(supportLevels, ArraySize(supportLevels)+1);
         supportLevels[ArraySize(supportLevels)-1] = low[i];
      }
      
      if(IsSwingHighSimple(i, SwingSensitivity, high))
      {
         ArrayResize(resistanceLevels, ArraySize(resistanceLevels)+1);
         resistanceLevels[ArraySize(resistanceLevels)-1] = high[i];
      }
   }
   
   // Calculate support zone (CORRECTED)
   if(ArraySize(supportLevels) > 0)
   {
      // For SUPPORT zone: we want the HIGH boundary to be the HIGHEST support level
      // and the LOW boundary to be the LOWEST support level
      supportHigh = 0;
      supportLow = DBL_MAX;
      
      for(int i=0; i<ArraySize(supportLevels); i++)
      {
         if(supportLevels[i] > supportHigh) supportHigh = supportLevels[i];
         if(supportLevels[i] < supportLow) supportLow = supportLevels[i];
      }
      
      // Adjust for zone - SUPPORT is BELOW current price
      double zonePadding = ZonePadding * _Point;
      supportHigh += zonePadding;       // Add padding above (towards current price)
      supportLow -= zonePadding * 2;    // Add more padding below (away from price)
   }
   else
   {
      supportHigh = 0;
      supportLow = 0;
   }
   
   // Calculate resistance zone (CORRECTED)
   if(ArraySize(resistanceLevels) > 0)
   {
      // For RESISTANCE zone: we want the HIGH boundary to be the HIGHEST resistance level
      // and the LOW boundary to be the LOWEST resistance level
      resistanceHigh = 0;
      resistanceLow = DBL_MAX;
      
      for(int i=0; i<ArraySize(resistanceLevels); i++)
      {
         if(resistanceLevels[i] > resistanceHigh) resistanceHigh = resistanceLevels[i];
         if(resistanceLevels[i] < resistanceLow) resistanceLow = resistanceLevels[i];
      }
      
      // Adjust for zone - RESISTANCE is ABOVE current price
      double zonePadding = ZonePadding * _Point;
      resistanceHigh += zonePadding * 2;    // Add more padding above (away from price)
      resistanceLow -= zonePadding;         // Add padding below (towards current price)
   }
   else
   {
      resistanceHigh = 0;
      resistanceLow = 0;
   }
}

//+------------------------------------------------------------------+
//| Draw support and resistance zones                               |
//+------------------------------------------------------------------+
void DrawZones(double supHigh, double supLow, double resHigh, double resLow)
{
   string name;
   datetime startTime = iTime(_Symbol, _Period, LookBackPeriod);
   datetime endTime = TimeCurrent();
   
   // Delete old objects first
   ObjectsDeleteAll(0, "SZone");
   ObjectsDeleteAll(0, "RZone");
   ObjectsDeleteAll(0, "Sup");
   ObjectsDeleteAll(0, "Res");
   
   // Only draw if we have valid values
   if(supHigh > 0 && supLow > 0 && supHigh > supLow)
   {
      // Draw support zone (filled rectangle)
      name = "SZone_Rect";
      ObjectCreate(0, name, OBJ_RECTANGLE, 0, startTime, supHigh, endTime, supLow);
      ObjectSetInteger(0, name, OBJPROP_COLOR, SupportColor);
      ObjectSetInteger(0, name, OBJPROP_BGCOLOR, SupportColor);
      ObjectSetInteger(0, name, OBJPROP_FILL, true);
      ObjectSetInteger(0, name, OBJPROP_BACK, true);
      ObjectSetInteger(0, name, OBJPROP_WIDTH, 0);
      
      // Draw support average line (middle of zone)
      name = "SZone_Avg";
      ObjectCreate(0, name, OBJ_HLINE, 0, 0, (supHigh + supLow) / 2);
      ObjectSetInteger(0, name, OBJPROP_COLOR, clrWhite);
      ObjectSetInteger(0, name, OBJPROP_STYLE, STYLE_SOLID);
      ObjectSetInteger(0, name, OBJPROP_WIDTH, 2);
      
      // Draw support boundaries
      name = "SZone_High";
      ObjectCreate(0, name, OBJ_HLINE, 0, 0, supHigh);
      ObjectSetInteger(0, name, OBJPROP_COLOR, SupportColor);
      ObjectSetInteger(0, name, OBJPROP_STYLE, STYLE_DASH);
      ObjectSetInteger(0, name, OBJPROP_WIDTH, 1);
      
      name = "SZone_Low";
      ObjectCreate(0, name, OBJ_HLINE, 0, 0, supLow);
      ObjectSetInteger(0, name, OBJPROP_COLOR, SupportColor);
      ObjectSetInteger(0, name, OBJPROP_STYLE, STYLE_DASH);
      ObjectSetInteger(0, name, OBJPROP_WIDTH, 1);
      
      if(ShowZoneLabels)
      {
         name = "RZone_Label";
         ObjectCreate(0, name, OBJ_TEXT, 0, endTime, supHigh);
         ObjectSetString(0, name, OBJPROP_TEXT, "Resistance Zone");
         ObjectSetInteger(0, name, OBJPROP_COLOR, clrWhite);
         ObjectSetInteger(0, name, OBJPROP_FONTSIZE, 8);
      }
   }
   
   if(resHigh > 0 && resLow > 0 && resHigh > resLow)
   {
      // Draw resistance zone (filled rectangle)
      name = "RZone_Rect";
      ObjectCreate(0, name, OBJ_RECTANGLE, 0, startTime, resHigh, endTime, resLow);
      ObjectSetInteger(0, name, OBJPROP_COLOR, ResistanceColor);
      ObjectSetInteger(0, name, OBJPROP_BGCOLOR, ResistanceColor);
      ObjectSetInteger(0, name, OBJPROP_FILL, true);
      ObjectSetInteger(0, name, OBJPROP_BACK, true);
      ObjectSetInteger(0, name, OBJPROP_WIDTH, 0);
      
      // Draw resistance average line (middle of zone)
      name = "RZone_Avg";
      ObjectCreate(0, name, OBJ_HLINE, 0, 0, (resHigh + resLow) / 2);
      ObjectSetInteger(0, name, OBJPROP_COLOR, clrWhite);
      ObjectSetInteger(0, name, OBJPROP_STYLE, STYLE_SOLID);
      ObjectSetInteger(0, name, OBJPROP_WIDTH, 2);
      
      // Draw resistance boundaries
      name = "RZone_High";
      ObjectCreate(0, name, OBJ_HLINE, 0, 0, resHigh);
      ObjectSetInteger(0, name, OBJPROP_COLOR, ResistanceColor);
      ObjectSetInteger(0, name, OBJPROP_STYLE, STYLE_DASH);
      ObjectSetInteger(0, name, OBJPROP_WIDTH, 1);
      
      name = "RZone_Low";
      ObjectCreate(0, name, OBJ_HLINE, 0, 0, resLow);
      ObjectSetInteger(0, name, OBJPROP_COLOR, ResistanceColor);
      ObjectSetInteger(0, name, OBJPROP_STYLE, STYLE_DASH);
      ObjectSetInteger(0, name, OBJPROP_WIDTH, 1);
      
      if(ShowZoneLabels)
      {
         name = "SZone_Label";
         ObjectCreate(0, name, OBJ_TEXT, 0, endTime, resLow);
         ObjectSetString(0, name, OBJPROP_TEXT, "Support Zone");
         ObjectSetInteger(0, name, OBJPROP_COLOR, clrWhite);
         ObjectSetInteger(0, name, OBJPROP_FONTSIZE, 8);
      }
   }
   
   // Add info label
   if(supHigh > 0 && resHigh > 0)
   {
      name = "ZoneInfo";
      ObjectCreate(0, name, OBJ_LABEL, 0, 0, 0);
      ObjectSetInteger(0, name, OBJPROP_CORNER, CORNER_LEFT_UPPER);
      ObjectSetInteger(0, name, OBJPROP_XDISTANCE, 10);
      ObjectSetInteger(0, name, OBJPROP_YDISTANCE, 20);
      ObjectSetString(0, name, OBJPROP_TEXT, "Dynamic S/R Zones Active");
      ObjectSetInteger(0, name, OBJPROP_COLOR, clrYellow);
      ObjectSetInteger(0, name, OBJPROP_FONTSIZE, 10);
   }
}

//+------------------------------------------------------------------+
//| Indicator initialization function                               |
//+------------------------------------------------------------------+
int OnInit()
{
   // Set buffer properties
   SetIndexBuffer(0, SupportHighBuffer, INDICATOR_DATA);
   SetIndexBuffer(1, SupportLowBuffer, INDICATOR_DATA);
   SetIndexBuffer(2, ResistanceHighBuffer, INDICATOR_DATA);
   SetIndexBuffer(3, ResistanceLowBuffer, INDICATOR_DATA);
   
   // Set plotting properties
   PlotIndexSetInteger(0, PLOT_DRAW_TYPE, DRAW_LINE);
   PlotIndexSetInteger(1, PLOT_DRAW_TYPE, DRAW_LINE);
   PlotIndexSetInteger(2, PLOT_DRAW_TYPE, DRAW_LINE);
   PlotIndexSetInteger(3, PLOT_DRAW_TYPE, DRAW_LINE);
   
   // Set line styles
   PlotIndexSetInteger(0, PLOT_LINE_STYLE, STYLE_DASH);
   PlotIndexSetInteger(1, PLOT_LINE_STYLE, STYLE_DASH);
   PlotIndexSetInteger(2, PLOT_LINE_STYLE, STYLE_DASH);
   PlotIndexSetInteger(3, PLOT_LINE_STYLE, STYLE_DASH);
   
   // Set colors
   PlotIndexSetInteger(0, PLOT_LINE_COLOR, SupportColor);
   PlotIndexSetInteger(1, PLOT_LINE_COLOR, SupportColor);
   PlotIndexSetInteger(2, PLOT_LINE_COLOR, ResistanceColor);
   PlotIndexSetInteger(3, PLOT_LINE_COLOR, ResistanceColor);
   
   // Set labels
   PlotIndexSetString(0, PLOT_LABEL, "Support High");
   PlotIndexSetString(1, PLOT_LABEL, "Support Low");
   PlotIndexSetString(2, PLOT_LABEL, "Resistance High");
   PlotIndexSetString(3, PLOT_LABEL, "Resistance Low");
   
   IndicatorSetString(INDICATOR_SHORTNAME, "Dynamic S/R Zones");
   IndicatorSetInteger(INDICATOR_DIGITS, _Digits);
   
   return(INIT_SUCCEEDED);
}

//+------------------------------------------------------------------+
//| Indicator iteration function                                    |
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
   // Check if we have enough data
   if(rates_total < LookBackPeriod + SwingSensitivity * 2)
      return(0);
   
   // Set arrays as series
   ArraySetAsSeries(high, true);
   ArraySetAsSeries(low, true);
   ArraySetAsSeries(close, true);
   
   // Find zones
   double supHigh, supLow, resHigh, resLow;
   FindZones(high, low, supHigh, supLow, resHigh, resLow);
   
   // Fill buffers
   int limit = MathMin(rates_total, LookBackPeriod);
   for(int i=0; i<limit; i++)
   {
      SupportHighBuffer[i] = supHigh;
      SupportLowBuffer[i] = supLow;
      ResistanceHighBuffer[i] = resHigh;
      ResistanceLowBuffer[i] = resLow;
   }
   
   // Draw zones on chart
   DrawZones(supHigh, supLow, resHigh, resLow);
   
   // Also publish to global variables for EA access
   if(supHigh > 0 && supLow > 0 && resHigh > 0 && resLow > 0)
   {
      GlobalVariableSet("GLOBAL_SUPPORT_HIGH", supHigh);
      GlobalVariableSet("GLOBAL_SUPPORT_LOW", supLow);
      GlobalVariableSet("GLOBAL_RESISTANCE_HIGH", resHigh);
      GlobalVariableSet("GLOBAL_RESISTANCE_LOW", resLow);
      GlobalVariableSet("GLOBAL_ZONES_TIME", TimeCurrent());
   }
   
   return(rates_total);
}

//+------------------------------------------------------------------+
//| Indicator deinitialization function                             |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{
   // Clean up all objects
   ObjectsDeleteAll(0, "SZone");
   ObjectsDeleteAll(0, "RZone");
   ObjectsDeleteAll(0, "Sup");
   ObjectsDeleteAll(0, "Res");
   ObjectsDeleteAll(0, "ZoneInfo");
   
   // Clean up global variables
   GlobalVariableDel("GLOBAL_SUPPORT_HIGH");
   GlobalVariableDel("GLOBAL_SUPPORT_LOW");
   GlobalVariableDel("GLOBAL_RESISTANCE_HIGH");
   GlobalVariableDel("GLOBAL_RESISTANCE_LOW");
   GlobalVariableDel("GLOBAL_ZONES_TIME");
}
//+------------------------------------------------------------------+