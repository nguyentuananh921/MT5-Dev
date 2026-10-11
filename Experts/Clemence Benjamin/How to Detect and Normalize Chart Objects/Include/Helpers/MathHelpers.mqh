//+------------------------------------------------------------------+
//|                                                MathHelpers.mqh  |
//|                                Copyright 2026, Clemence Benjamin |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2026, Clemence Benjamin"
#property link      "https://www.mql5.com"

#include "../Common/Globals.mqh"

//+------------------------------------------------------------------+
//| Refresh price cache for swing detection                          |
//+------------------------------------------------------------------+
void RefreshPriceCache(int lookback = 100)
{
   // Ensure globals are initialized
   if (g_point == 0)
      g_point = SymbolInfoDouble(_Symbol, SYMBOL_POINT);
   
   int bars = Bars(_Symbol, _Period);
   if (bars <= 0) return;
   
   int size = MathMin(lookback, bars);
   if (size <= g_cacheSize) return;
   
   ArrayResize(g_highCache, size);
   ArrayResize(g_lowCache, size);
   ArrayResize(g_closeCache, size);
   ArrayResize(g_openCache, size);
   ArrayResize(g_timeCache, size);
   
   for (int i = 0; i < size; i++)
   {
      g_highCache[i] = iHigh(_Symbol, _Period, i);
      g_lowCache[i] = iLow(_Symbol, _Period, i);
      g_closeCache[i] = iClose(_Symbol, _Period, i);
      g_openCache[i] = iOpen(_Symbol, _Period, i);
      g_timeCache[i] = iTime(_Symbol, _Period, i);
   }
   g_cacheSize = size;
}

//+------------------------------------------------------------------+
//| Get EMA value - using CopyBuffer for reliability                 |
//+------------------------------------------------------------------+
double GetEMA(int period)
{
   // Use a handle for EMA calculation
   int handle = iMA(_Symbol, _Period, period, 0, MODE_EMA, PRICE_CLOSE);
   if(handle == INVALID_HANDLE)
      return 0;
   
   double emaArray[];
   ArraySetAsSeries(emaArray, true);
   
   if(CopyBuffer(handle, 0, 0, 1, emaArray) < 1)
      return 0;
   
   return emaArray[0];
}

//+------------------------------------------------------------------+
//| Get line value at a given time (using chart object)              |
//+------------------------------------------------------------------+
double GetLineValueAtTime(long chartId, string name, datetime time)
{
   datetime t1 = (datetime)ObjectGetInteger(chartId, name, OBJPROP_TIME, 0);
   datetime t2 = (datetime)ObjectGetInteger(chartId, name, OBJPROP_TIME, 1);
   double p1 = ObjectGetDouble(chartId, name, OBJPROP_PRICE, 0);
   double p2 = ObjectGetDouble(chartId, name, OBJPROP_PRICE, 1);
   if (t1 == t2) return p1;
   if (t2 == t1) return p1;
   double slope = (p2 - p1) / (double)(t2 - t1);
   return p1 + slope * (double)(time - t1);
}

//+------------------------------------------------------------------+
//| Get line value at a given time (overloaded with parameters)      |
//+------------------------------------------------------------------+
double GetLineValueAtTime(datetime time, datetime t1, double p1, datetime t2, double p2)
{
   if (t1 == t2) return p1;
   double slope = (p2 - p1) / (double)(t2 - t1);
   return p1 + slope * (double)(time - t1);
}

//+------------------------------------------------------------------+
//| Convert ENUM_OBJECT to string for logging                        |
//+------------------------------------------------------------------+
string ObjectTypeToString(ENUM_OBJECT type)
{
   switch(type)
   {
      case OBJ_FIBO: return "OBJ_FIBO";
      case OBJ_FIBOFAN: return "OBJ_FIBOFAN";
      case OBJ_FIBOTIMES: return "OBJ_FIBOTIMES";
      case OBJ_FIBOARC: return "OBJ_FIBOARC";
      case OBJ_FIBOCHANNEL: return "OBJ_FIBOCHANNEL";
      case OBJ_EXPANSION: return "OBJ_EXPANSION";
      case OBJ_TREND: return "OBJ_TREND";
      case OBJ_HLINE: return "OBJ_HLINE";
      case OBJ_CHANNEL: return "OBJ_CHANNEL";
      case OBJ_PITCHFORK: return "OBJ_PITCHFORK";
      default: return "UNKNOWN";
   }
}