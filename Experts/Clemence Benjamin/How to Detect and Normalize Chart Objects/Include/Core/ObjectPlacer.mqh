//+------------------------------------------------------------------+
//|                                               ObjectPlacer.mqh  |
//|                                Copyright 2026, Clemence Benjamin |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2026, Clemence Benjamin"
#property link      "https://www.mql5.com"

#include "../Common/Structures.mqh"
#include "../Helpers/ObjectHelpers.mqh"
#include "SwingDetector.mqh"
#include "FibonacciNormalizer.mqh"

//+------------------------------------------------------------------+
//| Class: CObjectPlacer                                             |
//| Purpose: Automatically places Fibonacci objects on the chart    |
//| Enhanced for Part 5: Supports ALL 6 Fibonacci types             |
//+------------------------------------------------------------------+
class CObjectPlacer
{
private:
   long   m_chartId;
   string m_prefix;
   int    m_maxObjects;
   int    m_maxTotal;
   bool   m_debug;
   CFibonacciNormalizer* m_normalizer;
   
public:
   CObjectPlacer(long chartId, string prefix, int maxObjects, int maxTotal, bool debug);
   ~CObjectPlacer();
   
   void PlaceAll(int lookback, int minBars,
                 bool placeTrendlines, bool placeSR,
                 bool placeFibonacci, bool placeChannels,
                 bool placePitchforks);
   void Cleanup();
   
private:
   void PlaceFibonacciRetracement(SSwingPoint &swing1, SSwingPoint &swing2, int index);
   void PlaceFibonacciFan(SSwingPoint &swing1, SSwingPoint &swing2, int index);
   void PlaceFibonacciTimeZones(SSwingPoint &swing1, int index);
   void PlaceFibonacciArcs(SSwingPoint &swing1, SSwingPoint &swing2, int index);
   void PlaceFibonacciChannel(SSwingPoint &swing1, SSwingPoint &swing2, SSwingPoint &swing3, int index);
   void PlaceFibonacciExpansion(SSwingPoint &swing1, SSwingPoint &swing2, SSwingPoint &swing3, int index);
   bool IsManualObjectExists(double price1, double price2, datetime time1, datetime time2);
};

//+------------------------------------------------------------------+
//| Constructor                                                      |
//+------------------------------------------------------------------+
CObjectPlacer::CObjectPlacer(long chartId, string prefix, int maxObjects, int maxTotal, bool debug)
{
   m_chartId = chartId;
   m_prefix = prefix;
   m_maxObjects = maxObjects;
   m_maxTotal = maxTotal;
   m_debug = debug;
   m_normalizer = new CFibonacciNormalizer(chartId, prefix, debug);
}

//+------------------------------------------------------------------+
//| Destructor                                                       |
//+------------------------------------------------------------------+
CObjectPlacer::~CObjectPlacer()
{
   if(m_normalizer != NULL)
      delete m_normalizer;
}

//+------------------------------------------------------------------+
//| Clean up old objects                                             |
//+------------------------------------------------------------------+
void CObjectPlacer::Cleanup()
{
   CleanupObjectsWithPrefix(m_chartId, m_prefix);
}

//+------------------------------------------------------------------+
//| Check if a manual object already exists on this swing            |
//+------------------------------------------------------------------+
bool CObjectPlacer::IsManualObjectExists(double price1, double price2, datetime time1, datetime time2)
{
   string names[];
   int found = m_normalizer.FindFibonacciObjects(names, false);
   double threshold = 0.0005 * SymbolInfoDouble(_Symbol, SYMBOL_POINT);
   
   for(int i = 0; i < found; i++)
   {
      string name = names[i];
      if(StringFind(name, m_prefix) == 0)
         continue; // Skip EA-generated objects
      
      double p1 = ObjectGetDouble(m_chartId, name, OBJPROP_PRICE, 0);
      double p2 = ObjectGetDouble(m_chartId, name, OBJPROP_PRICE, 1);
      datetime t1 = (datetime)ObjectGetInteger(m_chartId, name, OBJPROP_TIME, 0);
      datetime t2 = (datetime)ObjectGetInteger(m_chartId, name, OBJPROP_TIME, 1);
      
      if(MathAbs(p1 - price1) < threshold && MathAbs(p2 - price2) < threshold &&
         t1 == time1 && t2 == time2)
      {
         return true;
      }
   }
   return false;
}

//+------------------------------------------------------------------+
//| Place all enabled object types                                   |
//+------------------------------------------------------------------+
void CObjectPlacer::PlaceAll(int lookback, int minBars,
                             bool placeTrendlines, bool placeSR,
                             bool placeFibonacci, bool placeChannels,
                             bool placePitchforks)
{
   Cleanup();
   
   SSwingPoint swings[];
   CSwingDetector::FindSwings(swings, lookback, minBars);
   
   if(ArraySize(swings) < 2)
   {
      if(m_debug)
         Print("Not enough swing points for placement");
      return;
   }
   
   int placed = 0;
   int maxToPlace = MathMin(m_maxObjects, ArraySize(swings) / 2);
   
   if(placeFibonacci)
   {
      // Place retracements between consecutive swing points
      for(int i = 0; i < ArraySize(swings) - 1 && placed < maxToPlace; i++)
      {
         if(IsManualObjectExists(swings[i].price, swings[i+1].price, 
                                 swings[i].time, swings[i+1].time))
         {
            if(m_debug)
               Print("Manual object exists on swing ", i, " - skipping automated placement");
            continue;
         }
         PlaceFibonacciRetracement(swings[i], swings[i+1], placed);
         placed++;
      }
      
      // Place fans between consecutive swing points
      for(int i = 0; i < ArraySize(swings) - 1 && placed < maxToPlace; i++)
      {
         if(IsManualObjectExists(swings[i].price, swings[i+1].price, 
                                 swings[i].time, swings[i+1].time))
            continue;
         PlaceFibonacciFan(swings[i], swings[i+1], placed);
         placed++;
      }
      
      // Place time zones from first swing point
      for(int i = 0; i < ArraySize(swings) - 1 && placed < maxToPlace; i++)
      {
         PlaceFibonacciTimeZones(swings[i], placed);
         placed++;
      }
      
      // Place arcs between consecutive swing points
      for(int i = 0; i < ArraySize(swings) - 1 && placed < maxToPlace; i++)
      {
         if(IsManualObjectExists(swings[i].price, swings[i+1].price, 
                                 swings[i].time, swings[i+1].time))
            continue;
         PlaceFibonacciArcs(swings[i], swings[i+1], placed);
         placed++;
      }
   }
   
   if(placeChannels && ArraySize(swings) >= 3)
   {
      // Place channels between three swing points
      for(int i = 0; i < ArraySize(swings) - 2 && placed < maxToPlace; i++)
      {
         if(IsManualObjectExists(swings[i].price, swings[i+2].price, 
                                 swings[i].time, swings[i+2].time))
            continue;
         PlaceFibonacciChannel(swings[i], swings[i+1], swings[i+2], placed);
         placed++;
      }
   }
   
   if(placePitchforks && ArraySize(swings) >= 3)
   {
      // Place expansions between three swing points
      for(int i = 0; i < ArraySize(swings) - 2 && placed < maxToPlace; i++)
      {
         if(IsManualObjectExists(swings[i].price, swings[i+2].price, 
                                 swings[i].time, swings[i+2].time))
            continue;
         PlaceFibonacciExpansion(swings[i], swings[i+1], swings[i+2], placed);
         placed++;
      }
   }
   
   if(m_debug)
      Print("Placed ", placed, " Fibonacci objects");
}

//+------------------------------------------------------------------+
//| Place Fibonacci retracement                                      |
//+------------------------------------------------------------------+
void CObjectPlacer::PlaceFibonacciRetracement(SSwingPoint &swing1, SSwingPoint &swing2, int index)
{
   string name = m_prefix + "Fibo_" + IntegerToString(TimeCurrent()) + "_" + IntegerToString(index);
   
   if(ObjectCreate(m_chartId, name, OBJ_FIBO, 0, swing1.time, swing1.price, swing2.time, swing2.price))
   {
      ObjectSetInteger(m_chartId, name, OBJPROP_COLOR, clrDodgerBlue);
      ObjectSetInteger(m_chartId, name, OBJPROP_WIDTH, 2);
      ObjectSetInteger(m_chartId, name, OBJPROP_SELECTABLE, false);
      ObjectSetInteger(m_chartId, name, OBJPROP_BACK, true);
      
      double levels[] = {0.0, 0.236, 0.382, 0.5, 0.618, 0.764, 1.0};
      int levelCount = ArraySize(levels);
      ObjectSetInteger(m_chartId, name, OBJPROP_LEVELS, levelCount);
      for(int i = 0; i < levelCount; i++)
         ObjectSetDouble(m_chartId, name, OBJPROP_LEVELVALUE, i, levels[i]);
   }
}

//+------------------------------------------------------------------+
//| Place Fibonacci fan                                              |
//+------------------------------------------------------------------+
void CObjectPlacer::PlaceFibonacciFan(SSwingPoint &swing1, SSwingPoint &swing2, int index)
{
   string name = m_prefix + "Fan_" + IntegerToString(TimeCurrent()) + "_" + IntegerToString(index);
   
   if(ObjectCreate(m_chartId, name, OBJ_FIBOFAN, 0, swing1.time, swing1.price, swing2.time, swing2.price))
   {
      ObjectSetInteger(m_chartId, name, OBJPROP_COLOR, clrRed);
      ObjectSetInteger(m_chartId, name, OBJPROP_WIDTH, 1);
      ObjectSetInteger(m_chartId, name, OBJPROP_SELECTABLE, false);
      
      double levels[] = {0.382, 0.5, 0.618, 1.0};
      int levelCount = ArraySize(levels);
      ObjectSetInteger(m_chartId, name, OBJPROP_LEVELS, levelCount);
      for(int i = 0; i < levelCount; i++)
         ObjectSetDouble(m_chartId, name, OBJPROP_LEVELVALUE, i, levels[i]);
   }
}

//+------------------------------------------------------------------+
//| Place Fibonacci time zones                                       |
//+------------------------------------------------------------------+
void CObjectPlacer::PlaceFibonacciTimeZones(SSwingPoint &swing1, int index)
{
   string name = m_prefix + "TimeZone_" + IntegerToString(TimeCurrent()) + "_" + IntegerToString(index);
   datetime time2 = swing1.time + 60 * 60 * 24 * 30;
   
   if(ObjectCreate(m_chartId, name, OBJ_FIBOTIMES, 0, swing1.time, swing1.price, time2, swing1.price))
   {
      ObjectSetInteger(m_chartId, name, OBJPROP_COLOR, clrGreen);
      ObjectSetInteger(m_chartId, name, OBJPROP_WIDTH, 1);
      ObjectSetInteger(m_chartId, name, OBJPROP_STYLE, STYLE_DASH);
      ObjectSetInteger(m_chartId, name, OBJPROP_SELECTABLE, false);
      
      int barOffsets[] = {1, 2, 3, 5, 8, 13, 21};
      int levelCount = ArraySize(barOffsets);
      ObjectSetInteger(m_chartId, name, OBJPROP_LEVELS, levelCount);
      for(int i = 0; i < levelCount; i++)
      {
         double offsetSeconds = barOffsets[i] * (double)PeriodSeconds();
         ObjectSetDouble(m_chartId, name, OBJPROP_LEVELVALUE, i, offsetSeconds);
      }
   }
}

//+------------------------------------------------------------------+
//| Place Fibonacci arcs                                             |
//+------------------------------------------------------------------+
void CObjectPlacer::PlaceFibonacciArcs(SSwingPoint &swing1, SSwingPoint &swing2, int index)
{
   string name = m_prefix + "Arc_" + IntegerToString(TimeCurrent()) + "_" + IntegerToString(index);
   
   if(ObjectCreate(m_chartId, name, OBJ_FIBOARC, 0, swing1.time, swing1.price, swing2.time, swing2.price))
   {
      ObjectSetInteger(m_chartId, name, OBJPROP_COLOR, clrBlue);
      ObjectSetInteger(m_chartId, name, OBJPROP_WIDTH, 1);
      ObjectSetInteger(m_chartId, name, OBJPROP_SELECTABLE, false);
      
      double levels[] = {0.382, 0.5, 0.618, 1.0};
      int levelCount = ArraySize(levels);
      ObjectSetInteger(m_chartId, name, OBJPROP_LEVELS, levelCount);
      for(int i = 0; i < levelCount; i++)
         ObjectSetDouble(m_chartId, name, OBJPROP_LEVELVALUE, i, levels[i]);
      
      // Calculate scale based on price range
      double point = SymbolInfoDouble(_Symbol, SYMBOL_POINT);
      if(point <= 0) point = 0.00001;
      double priceRange = MathAbs(swing2.price - swing1.price) / point;
      double scale = priceRange * 0.2;
      if(scale < 10) scale = 10;
      if(scale > 1000) scale = 1000;
      ObjectSetDouble(m_chartId, name, OBJPROP_SCALE, scale);
   }
}

//+------------------------------------------------------------------+
//| Place Fibonacci channel                                          |
//+------------------------------------------------------------------+
void CObjectPlacer::PlaceFibonacciChannel(SSwingPoint &swing1, SSwingPoint &swing2, SSwingPoint &swing3, int index)
{
   string name = m_prefix + "Channel_" + IntegerToString(TimeCurrent()) + "_" + IntegerToString(index);
   
   if(ObjectCreate(m_chartId, name, OBJ_FIBOCHANNEL, 0, 
                   swing1.time, swing1.price, 
                   swing2.time, swing2.price,
                   swing3.time, swing3.price))
   {
      ObjectSetInteger(m_chartId, name, OBJPROP_COLOR, clrOrange);
      ObjectSetInteger(m_chartId, name, OBJPROP_WIDTH, 2);
      ObjectSetInteger(m_chartId, name, OBJPROP_RAY_RIGHT, true);
      ObjectSetInteger(m_chartId, name, OBJPROP_SELECTABLE, false);
      
      double levels[] = {0.0, 0.382, 0.5, 0.618, 1.0};
      int levelCount = ArraySize(levels);
      ObjectSetInteger(m_chartId, name, OBJPROP_LEVELS, levelCount);
      for(int i = 0; i < levelCount; i++)
         ObjectSetDouble(m_chartId, name, OBJPROP_LEVELVALUE, i, levels[i]);
   }
}

//+------------------------------------------------------------------+
//| Place Fibonacci expansion                                        |
//+------------------------------------------------------------------+
void CObjectPlacer::PlaceFibonacciExpansion(SSwingPoint &swing1, SSwingPoint &swing2, SSwingPoint &swing3, int index)
{
   string name = m_prefix + "Expansion_" + IntegerToString(TimeCurrent()) + "_" + IntegerToString(index);
   
   if(ObjectCreate(m_chartId, name, OBJ_EXPANSION, 0,
                   swing1.time, swing1.price,
                   swing2.time, swing2.price,
                   swing3.time, swing3.price))
   {
      ObjectSetInteger(m_chartId, name, OBJPROP_COLOR, clrPurple);
      ObjectSetInteger(m_chartId, name, OBJPROP_WIDTH, 1);
      ObjectSetInteger(m_chartId, name, OBJPROP_RAY_RIGHT, true);
      ObjectSetInteger(m_chartId, name, OBJPROP_SELECTABLE, false);
      
      double levels[] = {0.0, 0.618, 1.0, 1.618, 2.618};
      int levelCount = ArraySize(levels);
      ObjectSetInteger(m_chartId, name, OBJPROP_LEVELS, levelCount);
      for(int i = 0; i < levelCount; i++)
         ObjectSetDouble(m_chartId, name, OBJPROP_LEVELVALUE, i, levels[i]);
   }
}