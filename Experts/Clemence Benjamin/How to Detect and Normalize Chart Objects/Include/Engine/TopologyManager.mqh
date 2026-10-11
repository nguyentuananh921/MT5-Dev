//+------------------------------------------------------------------+
//|                                            TopologyManager.mqh  |
//|                                Copyright 2026, Clemence Benjamin |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2026, Clemence Benjamin"
#property link      "https://www.mql5.com"

#include "../Common/Structures.mqh"
#include "../Core/MarketCache.mqh"
#include "../Core/SwingDetector.mqh"
#include "../Core/ObjectPlacer.mqh"
#include "../Core/SignalEvaluator.mqh"
#include "../Core/FibonacciNormalizer.mqh"

//+------------------------------------------------------------------+
//| Class: CTopologyManager                                          |
//| Purpose: Orchestrates object detection, placement, and signals   |
//+------------------------------------------------------------------+
class CTopologyManager
  {
private:
   long                     m_chartId;
   CSignalEvaluator*        m_evaluators[];
   CMarketDataCache*        m_marketCache;
   CObjectPlacer*           m_objectPlacer;
   CFibonacciNormalizer*    m_fiboNormalizer;
   datetime                 m_lastScan;
   datetime                 m_lastPlacement;
   int                      m_scanInterval;
   int                      m_placementInterval;
   double                   m_touchThreshold;
   double                   m_slMultiplier;
   double                   m_tpMultiplier;
   bool                     m_debug;
   string                   m_prefix;
   int                      m_maxObjectsPerType;
   int                      m_maxTotalObjects;

public:
                     CTopologyManager(long chartId, int scanInterval, int placementInterval,
                    double threshold, double slMult, double tpMult,
                    int maxObjectsPerType, int maxTotalObjects,
                    bool debug, string prefix = "EA_FIBO_");
                    ~CTopologyManager();

   void              PlaceObjects(int lookback, int minBars,
                     bool placeTrendlines, bool placeSR,
                     bool placeFibonacci, bool placeChannels,
                     bool placePitchforks);
   void              RefreshObjects(bool normalizeUserObjects = false);
   int               ProcessSignals(TradeSignal &signals[], int maxSignals);
   void              PrintStatistics();
   bool              IsManualObjectExists(double price1, double price2, datetime time1, datetime time2);

private:
   void              ClearEvaluators();
   bool              IsAnalyticalObject(ENUM_OBJECT type);
  };

//+------------------------------------------------------------------+
//| Constructor                                                      |
//+------------------------------------------------------------------+
CTopologyManager::CTopologyManager(long chartId, int scanInterval, int placementInterval,
                                   double threshold, double slMult, double tpMult,
                                   int maxObjectsPerType, int maxTotalObjects,
                                   bool debug, string prefix)
  {
   m_chartId = chartId;
   m_scanInterval = scanInterval;
   m_placementInterval = placementInterval;
   m_touchThreshold = threshold;
   m_slMultiplier = slMult;
   m_tpMultiplier = tpMult;
   m_maxObjectsPerType = maxObjectsPerType;
   m_maxTotalObjects = maxTotalObjects;
   m_debug = debug;
   m_prefix = prefix;
   m_lastScan = 0;
   m_lastPlacement = 0;
   m_marketCache = new CMarketDataCache(1);
   m_objectPlacer = new CObjectPlacer(chartId, prefix, maxObjectsPerType, maxTotalObjects, debug);
   m_fiboNormalizer = new CFibonacciNormalizer(chartId, prefix, debug);
   ArrayResize(m_evaluators, 0);
  }

//+------------------------------------------------------------------+
//| Destructor                                                       |
//+------------------------------------------------------------------+
CTopologyManager::~CTopologyManager()
  {
   ClearEvaluators();
   if(m_marketCache != NULL)
      delete m_marketCache;
   if(m_objectPlacer != NULL)
      delete m_objectPlacer;
   if(m_fiboNormalizer != NULL)
      delete m_fiboNormalizer;
  }

//+------------------------------------------------------------------+
//| Clears all evaluators                                            |
//+------------------------------------------------------------------+
void CTopologyManager::ClearEvaluators()
  {
   for(int i = 0; i < ArraySize(m_evaluators); i++)
     {
      if(m_evaluators[i] != NULL)
         delete m_evaluators[i];
     }
   ArrayResize(m_evaluators, 0);
  }

//+------------------------------------------------------------------+
//| Checks if object type is analytical                              |
//+------------------------------------------------------------------+
bool CTopologyManager::IsAnalyticalObject(ENUM_OBJECT type)
  {
   return(type == OBJ_TREND || type == OBJ_HLINE || type == OBJ_VLINE ||
          type == OBJ_FIBO || type == OBJ_FIBOFAN || type == OBJ_FIBOTIMES ||
          type == OBJ_FIBOARC || type == OBJ_FIBOCHANNEL || type == OBJ_EXPANSION ||
          type == OBJ_PITCHFORK || type == OBJ_CHANNEL);
  }

//+------------------------------------------------------------------+
//| Checks if a manual object already exists on a swing              |
//+------------------------------------------------------------------+
bool CTopologyManager::IsManualObjectExists(double price1, double price2, datetime time1, datetime time2)
  {
   string names[];
   int found = m_fiboNormalizer.FindFibonacciObjects(names, false);
   double threshold = 0.0005 * SymbolInfoDouble(_Symbol, SYMBOL_POINT);
   for(int i = 0; i < found; i++)
     {
      string name = names[i];
      // Skip EA-generated objects
      if(StringFind(name, m_prefix) == 0)
         continue;
      double p1 = ObjectGetDouble(m_chartId, name, OBJPROP_PRICE, 0);
      double p2 = ObjectGetDouble(m_chartId, name, OBJPROP_PRICE, 1);
      datetime t1 = (datetime)ObjectGetInteger(m_chartId, name, OBJPROP_TIME, 0);
      datetime t2 = (datetime)ObjectGetInteger(m_chartId, name, OBJPROP_TIME, 1);
      if(MathAbs(p1 - price1) < threshold && MathAbs(p2 - price2) < threshold &&
         t1 == time1 && t2 == time2)
        {
         return(true);
        }
     }
   return(false);
  }

//+------------------------------------------------------------------+
//| Places objects based on swing detection                          |
//+------------------------------------------------------------------+
void CTopologyManager::PlaceObjects(int lookback, int minBars,
                                    bool placeTrendlines, bool placeSR,
                                    bool placeFibonacci, bool placeChannels,
                                    bool placePitchforks)
  {
   datetime now = TimeCurrent();
   if(now - m_lastPlacement < m_placementInterval)
      return;
   if(m_objectPlacer != NULL)
     {
      m_objectPlacer.PlaceAll(lookback, minBars, placeTrendlines, placeSR,
                              placeFibonacci, placeChannels, placePitchforks);
     }
   m_lastPlacement = now;
  }

//+------------------------------------------------------------------+
//| Refreshes object list and creates evaluators                     |
//+------------------------------------------------------------------+
void CTopologyManager::RefreshObjects(bool normalizeUserObjects)
  {
   datetime now = TimeCurrent();
   if(now - m_lastScan < m_scanInterval)
      return;
//--- Normalize all Fibonacci objects first
   string fiboNames[];
   int fiboCount = m_fiboNormalizer.FindFibonacciObjects(fiboNames, false);
   if(fiboCount > 0)
      m_fiboNormalizer.NormalizeAll(fiboNames, normalizeUserObjects);
//--- Clear old evaluators and create new ones
   ClearEvaluators();
   int total = ObjectsTotal(m_chartId);
   int count = 0;
   for(int i = 0; i < total; i++)
     {
      string name = ObjectName(m_chartId, i);
      ENUM_OBJECT type = (ENUM_OBJECT)ObjectGetInteger(m_chartId, name, OBJPROP_TYPE);
      if(IsAnalyticalObject(type))
        {
         int index = ArraySize(m_evaluators);
         ArrayResize(m_evaluators, index + 1);
         m_evaluators[index] = new CSignalEvaluator(
            m_chartId,
            name,
            type,
            m_touchThreshold,
            m_slMultiplier,
            m_tpMultiplier
         );
         count++;
        }
     }
   m_lastScan = now;
   if(m_debug)
      Print("Refreshed objects. Found ", count, " analytical objects, ", fiboCount, " Fibonacci objects normalized.");
  }

//+------------------------------------------------------------------+
//| Processes signals from all evaluators                            |
//+------------------------------------------------------------------+
int CTopologyManager::ProcessSignals(TradeSignal &signals[], int maxSignals)
  {
   ArrayResize(signals, 0);
   if(m_marketCache == NULL)
      return(0);
//--- Refresh the cache first
   m_marketCache.Refresh();
//--- Get the snapshot
   MarketSnapshot snapshot = m_marketCache.GetSnapshot();
   int count = 0;
   for(int i = 0; i < ArraySize(m_evaluators) && count < maxSignals; i++)
     {
      if(m_evaluators[i] == NULL)
         continue;
      TradeSignal signal;
      if(m_evaluators[i].AnalyzeSignal(snapshot, signal))
        {
         if(signal.isValid)
           {
            ArrayResize(signals, count + 1);
            signals[count] = signal;
            count++;
           }
        }
     }
   return(count);
  }

//+------------------------------------------------------------------+
//| Prints statistics about the current topology                     |
//+------------------------------------------------------------------+
void CTopologyManager::PrintStatistics()
  {
   Print("=== Topology Manager Statistics ===");
   Print("Chart ID: ", m_chartId);
   Print("Scan interval: ", m_scanInterval, " seconds");
   Print("Placement interval: ", m_placementInterval, " seconds");
   Print("Touch threshold: ", m_touchThreshold, " pips");
   Print("Evaluators: ", ArraySize(m_evaluators));
   Print("===================================");
  }
//+------------------------------------------------------------------+