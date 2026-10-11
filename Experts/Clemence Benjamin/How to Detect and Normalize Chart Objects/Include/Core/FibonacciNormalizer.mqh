//+------------------------------------------------------------------+
//|                                          FibonacciNormalizer.mqh|
//|                                Copyright 2026, Clemence Benjamin |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2026, Clemence Benjamin"
#property link      "https://www.mql5.com"

#include "../Common/Structures.mqh"
#include "../Helpers/MathHelpers.mqh"

//+------------------------------------------------------------------+
//| Class: CFibonacciNormalizer                                      |
//| Purpose: Detects and normalizes Fibonacci objects               |
//+------------------------------------------------------------------+
class CFibonacciNormalizer
{
private:
   long   m_chartId;
   string m_prefix;
   bool   m_debug;
   
public:
   CFibonacciNormalizer(long chartId, string prefix, bool debug = false);
   ~CFibonacciNormalizer();
   
   int  FindFibonacciObjects(string &names[], bool filterByPrefix = true);
   void NormalizeAll(string &names[], bool normalizeUserObjects = false);
   void NormalizeObject(string name);
   bool IsFibonacciType(ENUM_OBJECT type);
   bool IsValidFibonacciObject(string name);
};

//+------------------------------------------------------------------+
//| Constructor                                                      |
//+------------------------------------------------------------------+
CFibonacciNormalizer::CFibonacciNormalizer(long chartId, string prefix, bool debug)
{
   m_chartId = chartId;
   m_prefix = prefix;
   m_debug = debug;
}

//+------------------------------------------------------------------+
//| Destructor                                                       |
//+------------------------------------------------------------------+
CFibonacciNormalizer::~CFibonacciNormalizer()
{
}

//+------------------------------------------------------------------+
//| Check if object type is Fibonacci-related                        |
//+------------------------------------------------------------------+
bool CFibonacciNormalizer::IsFibonacciType(ENUM_OBJECT type)
{
   return (type == OBJ_FIBO || type == OBJ_FIBOFAN || type == OBJ_FIBOTIMES ||
           type == OBJ_FIBOARC || type == OBJ_FIBOCHANNEL || type == OBJ_EXPANSION);
}

//+------------------------------------------------------------------+
//| Check if Fibonacci object has valid anchor points                |
//+------------------------------------------------------------------+
bool CFibonacciNormalizer::IsValidFibonacciObject(string name)
{
   // OBJPROP_PRICE with index 0 for first anchor, index 1 for second anchor
   double p1 = ObjectGetDouble(m_chartId, name, OBJPROP_PRICE, 0);
   double p2 = ObjectGetDouble(m_chartId, name, OBJPROP_PRICE, 1);
   datetime t1 = (datetime)ObjectGetInteger(m_chartId, name, OBJPROP_TIME, 0);
   datetime t2 = (datetime)ObjectGetInteger(m_chartId, name, OBJPROP_TIME, 1);
   return (p1 != p2 && t1 != t2);
}

//+------------------------------------------------------------------+
//| Find all Fibonacci objects on the chart                          |
//+------------------------------------------------------------------+
int CFibonacciNormalizer::FindFibonacciObjects(string &names[], bool filterByPrefix)
{
   ArrayResize(names, 0);
   int total = ObjectsTotal(m_chartId);
   int found = 0;
   
   for (int i = 0; i < total; i++)
   {
      string name = ObjectName(m_chartId, i);
      
      if (filterByPrefix && m_prefix != "" && StringFind(name, m_prefix) != 0)
         continue;
      
      ENUM_OBJECT type = (ENUM_OBJECT)ObjectGetInteger(m_chartId, name, OBJPROP_TYPE);
      if (IsFibonacciType(type))
      {
         if (IsValidFibonacciObject(name))
         {
            ArrayResize(names, found + 1);
            names[found] = name;
            found++;
         }
      }
   }
   return found;
}

//+------------------------------------------------------------------+
//| Normalize a single Fibonacci object                              |
//+------------------------------------------------------------------+
void CFibonacciNormalizer::NormalizeObject(string name)
{
   ENUM_OBJECT type = (ENUM_OBJECT)ObjectGetInteger(m_chartId, name, OBJPROP_TYPE);
   
   switch(type)
   {
      case OBJ_FIBO:          NormalizeFiboRetracement(m_chartId, name); break;
      case OBJ_FIBOFAN:       NormalizeFiboFan(m_chartId, name); break;
      case OBJ_FIBOTIMES:     NormalizeFiboTimeZones(m_chartId, name, true); break;
      case OBJ_FIBOARC:       NormalizeFiboArcs(m_chartId, name); break;
      case OBJ_FIBOCHANNEL:   NormalizeFiboChannel(m_chartId, name); break;
      case OBJ_EXPANSION:     NormalizeFiboExpansion(m_chartId, name); break;
      default: return;
   }
   
   if (m_debug)
      Print("Normalized Fibonacci object: ", name, " (", ObjectTypeToString(type), ")");
}

//+------------------------------------------------------------------+
//| Normalize all Fibonacci objects in the array                     |
//+------------------------------------------------------------------+
void CFibonacciNormalizer::NormalizeAll(string &names[], bool normalizeUserObjects)
{
   for (int i = 0; i < ArraySize(names); i++)
   {
      string name = names[i];
      bool isUserObject = (StringFind(name, m_prefix) != 0);
      
      if (!normalizeUserObjects && isUserObject)
         continue;
      
      NormalizeObject(name);
   }
}

//+------------------------------------------------------------------+
//| Normalize Fibonacci retracement (OBJ_FIBO)                       |
//+------------------------------------------------------------------+
void NormalizeFiboRetracement(long chartId, string objName)
{
   double standardLevels[] = {0.0, 0.236, 0.382, 0.5, 0.618, 0.764, 1.0};
   int levelCount = ArraySize(standardLevels);
   
   if (!ObjectSetInteger(chartId, objName, OBJPROP_LEVELS, levelCount))
   {
      Print("Failed to set level count for ", objName, ". Error: ", GetLastError());
      return;
   }
   
   for (int i = 0; i < levelCount; i++)
   {
      if (!ObjectSetDouble(chartId, objName, OBJPROP_LEVELVALUE, i, standardLevels[i]))
         Print("Failed to set level ", i, " for ", objName);
   }
   
   ObjectSetInteger(chartId, objName, OBJPROP_COLOR, clrDodgerBlue);
   ObjectSetInteger(chartId, objName, OBJPROP_WIDTH, 2);
   ObjectSetInteger(chartId, objName, OBJPROP_STYLE, STYLE_SOLID);
   ObjectSetInteger(chartId, objName, OBJPROP_RAY_RIGHT, false);
   ObjectSetInteger(chartId, objName, OBJPROP_SELECTABLE, false);
   ObjectSetInteger(chartId, objName, OBJPROP_BACK, true);
}

//+------------------------------------------------------------------+
//| Normalize Fibonacci fan (OBJ_FIBOFAN)                            |
//+------------------------------------------------------------------+
void NormalizeFiboFan(long chartId, string objName)
{
   double standardFans[] = {0.382, 0.5, 0.618, 1.0};
   int count = ArraySize(standardFans);
   
   if (!ObjectSetInteger(chartId, objName, OBJPROP_LEVELS, count))
   {
      Print("Failed to set fan levels for ", objName);
      return;
   }
   
   for (int i = 0; i < count; i++)
      ObjectSetDouble(chartId, objName, OBJPROP_LEVELVALUE, i, standardFans[i]);
   
   ObjectSetInteger(chartId, objName, OBJPROP_COLOR, clrRed);
   ObjectSetInteger(chartId, objName, OBJPROP_WIDTH, 1);
   ObjectSetInteger(chartId, objName, OBJPROP_SELECTABLE, false);
}

//+------------------------------------------------------------------+
//| Normalize Fibonacci time zones (OBJ_FIBOTIMES)                   |
//+------------------------------------------------------------------+
void NormalizeFiboTimeZones(long chartId, string objName, bool adjustToChartTF = true)
{
   int barOffsets[] = {1, 2, 3, 5, 8, 13, 21};
   int count = ArraySize(barOffsets);
   
   if (!ObjectSetInteger(chartId, objName, OBJPROP_LEVELS, count))
   {
      Print("Failed to set time zone levels for ", objName);
      return;
   }
   
   for (int i = 0; i < count; i++)
   {
      double offsetSeconds;
      if (adjustToChartTF)
         offsetSeconds = barOffsets[i] * (double)PeriodSeconds();
      else
         offsetSeconds = barOffsets[i] * 60.0;
      ObjectSetDouble(chartId, objName, OBJPROP_LEVELVALUE, i, offsetSeconds);
   }
   
   ObjectSetInteger(chartId, objName, OBJPROP_COLOR, clrGreen);
   ObjectSetInteger(chartId, objName, OBJPROP_WIDTH, 1);
   ObjectSetInteger(chartId, objName, OBJPROP_STYLE, STYLE_DASH);
   ObjectSetInteger(chartId, objName, OBJPROP_SELECTABLE, false);
}

//+------------------------------------------------------------------+
//| Normalize Fibonacci arcs (OBJ_FIBOARC)                           |
//+------------------------------------------------------------------+
void NormalizeFiboArcs(long chartId, string objName)
{
   double standardArcs[] = {0.382, 0.5, 0.618, 1.0};
   int count = ArraySize(standardArcs);
   
   if (!ObjectSetInteger(chartId, objName, OBJPROP_LEVELS, count))
   {
      Print("Failed to set arc levels for ", objName);
      return;
   }
   
   for (int i = 0; i < count; i++)
      ObjectSetDouble(chartId, objName, OBJPROP_LEVELVALUE, i, standardArcs[i]);
   
   // Calculate scale based on anchor points using price range
   double p1 = ObjectGetDouble(chartId, objName, OBJPROP_PRICE, 0);
   double p2 = ObjectGetDouble(chartId, objName, OBJPROP_PRICE, 1);
   
   // Get point value for the symbol
   double point = SymbolInfoDouble(_Symbol, SYMBOL_POINT);
   if(point <= 0) point = 0.00001;
   
   // Calculate price range in points
   double priceRange = MathAbs(p2 - p1) / point;
   
   // Scale is proportional to price range (20% of range works well for most instruments)
   double scale = priceRange * 0.2;
   
   // Ensure reasonable bounds
   if(scale < 10) scale = 10;
   if(scale > 1000) scale = 1000;
   
   ObjectSetDouble(chartId, objName, OBJPROP_SCALE, scale);
   
   ObjectSetInteger(chartId, objName, OBJPROP_COLOR, clrBlue);
   ObjectSetInteger(chartId, objName, OBJPROP_WIDTH, 1);
   ObjectSetInteger(chartId, objName, OBJPROP_SELECTABLE, false);
}

//+------------------------------------------------------------------+
//| Normalize Fibonacci channel (OBJ_FIBOCHANNEL)                    |
//+------------------------------------------------------------------+
void NormalizeFiboChannel(long chartId, string objName)
{
   double standardChannelLevels[] = {0.0, 0.382, 0.5, 0.618, 1.0};
   int count = ArraySize(standardChannelLevels);
   
   if (!ObjectSetInteger(chartId, objName, OBJPROP_LEVELS, count))
   {
      Print("Failed to set channel levels for ", objName);
      return;
   }
   
   for (int i = 0; i < count; i++)
      ObjectSetDouble(chartId, objName, OBJPROP_LEVELVALUE, i, standardChannelLevels[i]);
   
   ObjectSetInteger(chartId, objName, OBJPROP_COLOR, clrOrange);
   ObjectSetInteger(chartId, objName, OBJPROP_WIDTH, 2);
   ObjectSetInteger(chartId, objName, OBJPROP_RAY_RIGHT, true);
   ObjectSetInteger(chartId, objName, OBJPROP_SELECTABLE, false);
}

//+------------------------------------------------------------------+
//| Normalize Fibonacci expansion (OBJ_EXPANSION)                    |
//+------------------------------------------------------------------+
void NormalizeFiboExpansion(long chartId, string objName)
{
   double standardExpansions[] = {0.0, 0.618, 1.0, 1.618, 2.618};
   int count = ArraySize(standardExpansions);
   
   if (!ObjectSetInteger(chartId, objName, OBJPROP_LEVELS, count))
   {
      Print("Failed to set expansion levels for ", objName);
      return;
   }
   
   for (int i = 0; i < count; i++)
      ObjectSetDouble(chartId, objName, OBJPROP_LEVELVALUE, i, standardExpansions[i]);
   
   ObjectSetInteger(chartId, objName, OBJPROP_COLOR, clrPurple);
   ObjectSetInteger(chartId, objName, OBJPROP_WIDTH, 1);
   ObjectSetInteger(chartId, objName, OBJPROP_RAY_RIGHT, true);
   ObjectSetInteger(chartId, objName, OBJPROP_SELECTABLE, false);
}