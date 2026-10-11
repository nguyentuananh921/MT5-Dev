//+------------------------------------------------------------------+
//|                                              ObjectHelpers.mqh  |
//|                                Copyright 2026, Clemence Benjamin |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2026, Clemence Benjamin"
#property link      "https://www.mql5.com"

//+------------------------------------------------------------------+
//| Create horizontal line object                                    |
//+------------------------------------------------------------------+
bool CreateHorizontalLineObject(long chartId, string name, double price, color clr)
{
   if (ObjectFind(chartId, name) >= 0)
      return true;
      
   datetime time = TimeCurrent();
   datetime time2 = time + 60 * 60 * 24 * 30; // 30 days forward
   
   if (!ObjectCreate(chartId, name, OBJ_HLINE, 0, time, price, time2, price))
      return false;
   
   ObjectSetInteger(chartId, name, OBJPROP_COLOR, clr);
   ObjectSetInteger(chartId, name, OBJPROP_WIDTH, 1);
   ObjectSetInteger(chartId, name, OBJPROP_STYLE, STYLE_SOLID);
   ObjectSetInteger(chartId, name, OBJPROP_BACK, true);
   ObjectSetInteger(chartId, name, OBJPROP_SELECTABLE, false);
   
   return true;
}

//+------------------------------------------------------------------+
//| Clean up objects with a given prefix                             |
//+------------------------------------------------------------------+
void CleanupObjectsWithPrefix(long chartId, string prefix)
{
   int total = ObjectsTotal(chartId);
   for (int i = total - 1; i >= 0; i--)
   {
      string name = ObjectName(chartId, i);
      if (StringFind(name, prefix) == 0)
         ObjectDelete(chartId, name);
   }
}

//+------------------------------------------------------------------+
//| Object is analytical (not a label or button)                     |
//+------------------------------------------------------------------+
bool IsAnalyticalObject(long chartId, string name)
{
   ENUM_OBJECT type = (ENUM_OBJECT)ObjectGetInteger(chartId, name, OBJPROP_TYPE);
   return (type == OBJ_TREND || type == OBJ_HLINE || type == OBJ_VLINE ||
           type == OBJ_FIBO || type == OBJ_FIBOFAN || type == OBJ_FIBOTIMES ||
           type == OBJ_FIBOARC || type == OBJ_FIBOCHANNEL || type == OBJ_EXPANSION ||
           type == OBJ_PITCHFORK || type == OBJ_CHANNEL);
}