//+------------------------------------------------------------------+
//|                                    Confirmed Swing Points Helper |
//|                               Educational indicator for MQL5.com |
//|Link                          https://www.mql5.com/en/code/74206  |
//+------------------------------------------------------------------+
#property copyright "Talal N Z Aljarusha"
#property link      "https://forge.mql5.io"
#property version   "1.00"
#property indicator_chart_window
#property indicator_plots 0

input int      InpDepth             = 3;        // Bars on each side of the pivot
input double   InpMinDistancePoints = 0.0;      // Minimum distance from previous pivot, points
input bool     InpShowLabels        = true;     // Show HH/HL/LH/LL labels
input color    InpHighColor         = clrTomato;
input color    InpLowColor          = clrDeepSkyBlue;
input int      InpFontSize          = 8;
input string   InpObjectPrefix      = "CSPH_";

struct PivotPoint
{
   datetime time;
   double   price;
   int      type;     // 1 = high, -1 = low
   string   label;
};

PivotPoint g_lastHigh;
PivotPoint g_lastLow;
bool       g_hasHigh = false;
bool       g_hasLow  = false;

//+------------------------------------------------------------------+
int OnInit()
{
   IndicatorSetString(INDICATOR_SHORTNAME, "Confirmed Swing Points Helper");
   return(INIT_SUCCEEDED);
}

//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{
   DeleteObjects();
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
   if(InpDepth < 1 || rates_total < InpDepth * 2 + 1)
      return(rates_total);

   DeleteObjects();
   ResetState();

   for(int i = InpDepth; i < rates_total - InpDepth; i++)
   {
      if(IsSwingHigh(i, high))
         AddPivot(time[i], high[i], 1);

      if(IsSwingLow(i, low))
         AddPivot(time[i], low[i], -1);
   }

   ChartRedraw(0);
   return(rates_total);
}

//+------------------------------------------------------------------+
bool IsSwingHigh(const int i, const double &high[])
{
   for(int k = 1; k <= InpDepth; k++)
   {
      if(high[i] <= high[i - k]) return(false);
      if(high[i] <= high[i + k]) return(false);
   }
   return(true);
}

//+------------------------------------------------------------------+
bool IsSwingLow(const int i, const double &low[])
{
   for(int k = 1; k <= InpDepth; k++)
   {
      if(low[i] >= low[i - k]) return(false);
      if(low[i] >= low[i + k]) return(false);
   }
   return(true);
}

//+------------------------------------------------------------------+
void AddPivot(const datetime pivot_time, const double price, const int type)
{
   string label = "";

   if(type == 1)
   {
      if(!PassDistanceFilter(price, g_lastHigh.price, g_hasHigh))
         return;

      label = (!g_hasHigh || price > g_lastHigh.price) ? "HH" : "LH";
      g_lastHigh.time  = pivot_time;
      g_lastHigh.price = price;
      g_lastHigh.type  = type;
      g_lastHigh.label = label;
      g_hasHigh = true;
   }
   else
   {
      if(!PassDistanceFilter(price, g_lastLow.price, g_hasLow))
         return;

      label = (!g_hasLow || price > g_lastLow.price) ? "HL" : "LL";
      g_lastLow.time  = pivot_time;
      g_lastLow.price = price;
      g_lastLow.type  = type;
      g_lastLow.label = label;
      g_hasLow = true;
   }

   DrawPivot(pivot_time, price, type, label);
}

//+------------------------------------------------------------------+
bool PassDistanceFilter(const double price, const double previous_price, const bool has_previous)
{
   if(!has_previous || InpMinDistancePoints <= 0.0)
      return(true);

   return(MathAbs(price - previous_price) >= InpMinDistancePoints * _Point);
}

//+------------------------------------------------------------------+
void DrawPivot(const datetime pivot_time, const double price, const int type, const string label)
{
   string base_name = InpObjectPrefix + IntegerToString((long)pivot_time) + "_" + IntegerToString(type);
   color  clr       = (type == 1 ? InpHighColor : InpLowColor);

   ObjectCreate(0, base_name, OBJ_ARROW, 0, pivot_time, price);
   ObjectSetInteger(0, base_name, OBJPROP_COLOR, clr);
   ObjectSetInteger(0, base_name, OBJPROP_ARROWCODE, type == 1 ? 234 : 233);
   ObjectSetInteger(0, base_name, OBJPROP_WIDTH, 1);

   if(!InpShowLabels)
      return;

   string text_name = base_name + "_label";
   ObjectCreate(0, text_name, OBJ_TEXT, 0, pivot_time, price);
   ObjectSetString(0, text_name, OBJPROP_TEXT, label);
   ObjectSetInteger(0, text_name, OBJPROP_COLOR, clr);
   ObjectSetInteger(0, text_name, OBJPROP_FONTSIZE, InpFontSize);
   ObjectSetInteger(0, text_name, OBJPROP_ANCHOR, type == 1 ? ANCHOR_LOWER : ANCHOR_UPPER);
}

//+------------------------------------------------------------------+
void DeleteObjects()
{
   for(int i = ObjectsTotal(0, 0, -1) - 1; i >= 0; i--)
   {
      string name = ObjectName(0, i, 0, -1);
      if(StringFind(name, InpObjectPrefix) == 0)
         ObjectDelete(0, name);
   }
}

//+------------------------------------------------------------------+
void ResetState()
{
   g_hasHigh = false;
   g_hasLow  = false;
   ZeroMemory(g_lastHigh);
   ZeroMemory(g_lastLow);
}

