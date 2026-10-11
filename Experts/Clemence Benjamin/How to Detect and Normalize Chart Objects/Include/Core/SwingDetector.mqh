//+------------------------------------------------------------------+
//|                                              SwingDetector.mqh  |
//|                                Copyright 2026, Clemence Benjamin |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2026, Clemence Benjamin"
#property link      "https://www.mql5.com"

#include "../Common/Structures.mqh"
#include "../Helpers/MathHelpers.mqh"

//+------------------------------------------------------------------+
//| Class: CSwingDetector                                            |
//| Purpose: Detects swing highs and lows on the chart              |
//+------------------------------------------------------------------+
class CSwingDetector
{
public:
   static bool IsSwingHigh(int bar, int minBars = 3);
   static bool IsSwingLow(int bar, int minBars = 3);
   static void FindSwings(SSwingPoint &swings[], int lookback, int minBars = 3);
};

//+------------------------------------------------------------------+
//| Checks if bar forms a swing high                                 |
//+------------------------------------------------------------------+
bool CSwingDetector::IsSwingHigh(int bar, int minBars)
{
   RefreshPriceCache(bar + minBars + 1);
   if (bar >= ArraySize(g_highCache))
      return false;
   
   for (int j = 1; j <= minBars; j++)
   {
      if (bar + j >= ArraySize(g_highCache) || bar - j < 0)
         return false;
      if (g_highCache[bar] <= g_highCache[bar + j])
         return false;
      if (g_highCache[bar] <= g_highCache[bar - j])
         return false;
   }
   return true;
}

//+------------------------------------------------------------------+
//| Checks if bar forms a swing low                                  |
//+------------------------------------------------------------------+
bool CSwingDetector::IsSwingLow(int bar, int minBars)
{
   RefreshPriceCache(bar + minBars + 1);
   if (bar >= ArraySize(g_lowCache))
      return false;
   
   for (int j = 1; j <= minBars; j++)
   {
      if (bar + j >= ArraySize(g_lowCache) || bar - j < 0)
         return false;
      if (g_lowCache[bar] >= g_lowCache[bar + j])
         return false;
      if (g_lowCache[bar] >= g_lowCache[bar - j])
         return false;
   }
   return true;
}

//+------------------------------------------------------------------+
//| Finds all swing points within a lookback range                   |
//+------------------------------------------------------------------+
void CSwingDetector::FindSwings(SSwingPoint &swings[], int lookback, int minBars)
{
   ArrayResize(swings, 0);
   RefreshPriceCache(lookback + minBars);
   
   for (int i = lookback - 1; i >= minBars; i--)
   {
      bool isHigh = IsSwingHigh(i, minBars);
      bool isLow = IsSwingLow(i, minBars);
      
      if (isHigh || isLow)
      {
         int index = ArraySize(swings);
         ArrayResize(swings, index + 1);
         swings[index].bar = i;
         swings[index].time = g_timeCache[i];
         swings[index].price = isHigh ? g_highCache[i] : g_lowCache[i];
         swings[index].isHigh = isHigh;
      }
   }
}