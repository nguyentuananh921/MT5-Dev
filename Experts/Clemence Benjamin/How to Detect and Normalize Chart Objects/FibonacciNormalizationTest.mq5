//+------------------------------------------------------------------+
//|                                     FibonacciNormalizationTest.mq5|
//|                                Copyright 2026, Clemence Benjamin |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2026, Clemence Benjamin"
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict

//--- Include the normalization module
#include <ChartObjectsAlgorithms-Part5/Core/FibonacciNormalizer.mqh>
#include <ChartObjectsAlgorithms-Part5/Helpers/MathHelpers.mqh>

//--- Input parameters
input bool     InpNormalize = true;      // Enable normalization
input bool     InpNormalizeUser = false; // Normalize user objects too
input bool     InpDebug = true;          // Enable debug logging
input int      InpLogInterval = 5;       // Log interval in seconds
input string   InpPrefix = "EA_FIBO_";   // Object prefix for EA-created objects

//--- Global variables
CFibonacciNormalizer* g_normalizer = NULL;
datetime g_lastLog = 0;

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
   g_normalizer = new CFibonacciNormalizer(ChartID(), InpPrefix, InpDebug);
   if(CheckPointer(g_normalizer) == POINTER_INVALID)
     {
      Print("Failed to initialize Fibonacci normalizer");
      return(INIT_FAILED);
     }
   Print("=== Fibonacci Normalization Test v1.00 ===");
   PrintFormat("Symbol: %s, Period: %s", _Symbol, EnumToString(_Period));
   PrintFormat("Normalization: %s", InpNormalize ? "ENABLED" : "DISABLED");
   PrintFormat("Normalize user objects: %s", InpNormalizeUser ? "YES" : "NO");
   PrintFormat("Prefix: %s", InpPrefix);
   Print("==========================================");
   return(INIT_SUCCEEDED);
  }

//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   if(g_normalizer != NULL)
     {
      delete g_normalizer;
      g_normalizer = NULL;
     }
   Print("Test EA deinitialized");
  }

//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
   if(g_normalizer == NULL)
      return;
   datetime now = TimeCurrent();
   if(now - g_lastLog < InpLogInterval)
      return;
   g_lastLog = now;
   string names[];
   int found = g_normalizer.FindFibonacciObjects(names, false);
   Print("--- Scan at ", TimeToString(now), " ---");
   Print("Found ", found, " Fibonacci objects on the chart");
   if(found == 0)
     {
      Print("No Fibonacci objects found. Draw some on the chart and try again.");
      return;
     }
//--- Log each object's properties
   for(int i = 0; i < found; i++)
     {
      string name = names[i];
      ENUM_OBJECT type = (ENUM_OBJECT)ObjectGetInteger(ChartID(), name, OBJPROP_TYPE);
      int levels = (int)ObjectGetInteger(ChartID(), name, OBJPROP_LEVELS);
      color clr = (color)ObjectGetInteger(ChartID(), name, OBJPROP_COLOR);
      Print("Object: ", name);
      Print("  Type: ", ObjectTypeToString(type));
      Print("  Levels: ", levels);
      Print("  Color: ", clr);
      string levelStr = "";
      for(int j = 0; j < MathMin(levels, 10); j++)
        {
         double val = ObjectGetDouble(ChartID(), name, OBJPROP_LEVELVALUE, j);
         if(j > 0)
            levelStr += ", ";
         levelStr += DoubleToString(val, 3);
        }
      if(levels > 10)
         levelStr += ", ...";
      Print("  Level values: ", levelStr);
      bool isEA = (StringFind(name, InpPrefix) == 0);
      Print("  EA-generated: ", isEA ? "YES" : "NO");
     }
//--- Normalize if enabled
   if(InpNormalize)
     {
      Print("--- Normalization ---");
      g_normalizer.NormalizeAll(names, InpNormalizeUser);
      //--- Log results after normalization
      for(int i = 0; i < found; i++)
        {
         string name = names[i];
         int levels = (int)ObjectGetInteger(ChartID(), name, OBJPROP_LEVELS);
         color clr = (color)ObjectGetInteger(ChartID(), name, OBJPROP_COLOR);
         string levelStr = "";
         for(int j = 0; j < MathMin(levels, 10); j++)
           {
            double val = ObjectGetDouble(ChartID(), name, OBJPROP_LEVELVALUE, j);
            if(j > 0)
               levelStr += ", ";
            levelStr += DoubleToString(val, 3);
           }
         if(levels > 10)
            levelStr += ", ...";
         Print("After normalization: ", name);
         Print("  Levels: ", levels, " - ", levelStr);
         Print("  Color: ", clr);
        }
      Print("Normalization complete.");
     }
   Print("--- End of scan ---");
  }
//+------------------------------------------------------------------+
