//+------------------------------------------------------------------+
//|                                      AutoObjectTradingSystem.mq5 |
//|                                Copyright 2026, Clemence Benjamin |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2026, Clemence Benjamin"
#property link      "https://www.mql5.com"
#property version   "5.00"
#property strict

//--- Include all modular files
#include <Trade/Trade.mqh>
#include <ChartObjectsAlgorithms-Part5/Common/Structures.mqh>
#include <ChartObjectsAlgorithms-Part5/Common/Globals.mqh>
#include <ChartObjectsAlgorithms-Part5/Helpers/MathHelpers.mqh>
#include <ChartObjectsAlgorithms-Part5/Helpers/ObjectHelpers.mqh>
#include <ChartObjectsAlgorithms-Part5/Core/SwingDetector.mqh>
#include <ChartObjectsAlgorithms-Part5/Core/ObjectPlacer.mqh>
#include <ChartObjectsAlgorithms-Part5/Core/MarketCache.mqh>
#include <ChartObjectsAlgorithms-Part5/Core/SignalEvaluator.mqh>
#include <ChartObjectsAlgorithms-Part5/Core/FibonacciNormalizer.mqh>
#include <ChartObjectsAlgorithms-Part5/Engine/TopologyManager.mqh>
#include <ChartObjectsAlgorithms-Part5/Execution/AdaptiveTrade.mqh>

//--- Input parameters
input group "--- Risk Management ---"
input double   InpLotSize           = 0.1;      // Lot size
input ulong    InpMagicNumber       = 888888;   // Magic number
input int      InpSlippage          = 10;       // Slippage in points

input group "--- Object Placement ---"
input int      InpScanInterval      = 10;       // Scan interval in seconds
input int      InpSwingLookback     = 50;       // Bars to scan for swings
input int      InpMinSwingBars      = 3;        // Bars on each side of swing
input bool     InpPlaceTrendlines   = true;     // Auto-place trendlines
input bool     InpPlaceSR           = true;     // Auto-place support/resistance
input bool     InpPlaceFibonacci    = true;     // Auto-place Fibonacci (ALL 6 types)
input bool     InpPlaceChannels     = true;     // Auto-place channels
input bool     InpPlacePitchforks   = true;     // Auto-place pitchforks
input int      InpMaxObjectsPerType = 2;        // Max objects per type
input int      InpMaxObjectsTotal   = 15;       // Maximum total objects on chart

input group "--- Fibonacci Normalization ---"
input bool     InpNormalizeUserFibos = false;   // Normalize user-drawn Fibonacci objects
input bool     InpEnableDebug        = false;   // Enable debug logging

input group "--- Trading Settings ---"
input bool     InpEnableTrading     = true;     // Enable auto trading
input double   InpTouchThreshold    = 15.0;     // Touch threshold in pips
input int      InpMinConfidence     = 50;       // Minimum confidence (0-100)

input group "--- Adaptive Stops ---"
input double   InpSLMultiplier      = 3.0;      // SL distance multiplier
input double   InpTPMultiplier      = 5.0;      // TP distance multiplier
input int      InpMinStopPoints     = 100;      // Minimum stop distance in points

input group "--- Performance Settings ---"
input int      InpPlacementInterval = 30;       // Place objects every N seconds
input int      InpTradeCooldown     = 5;        // Seconds between trades

//--- Global objects
CTrade                     m_trade;
CTopologyManager*          m_topologyManager = NULL;
TradeSignal                m_signals[];
datetime                   m_lastTradeTime = 0;

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- Initialize cached values
   g_point = SymbolInfoDouble(_Symbol, SYMBOL_POINT);
   g_digits = (int)SymbolInfoInteger(_Symbol, SYMBOL_DIGITS);
   m_trade.SetExpertMagicNumber(InpMagicNumber);
   m_trade.SetDeviationInPoints(InpSlippage);
   string prefix = "EA_FIBO_" + IntegerToString(InpMagicNumber) + "_";
   m_topologyManager = new CTopologyManager(
      ChartID(),
      InpScanInterval,
      InpPlacementInterval,
      InpTouchThreshold,
      InpSLMultiplier,
      InpTPMultiplier,
      InpMaxObjectsPerType,
      InpMaxObjectsTotal,
      InpEnableDebug,
      prefix
   );
   if(CheckPointer(m_topologyManager) == POINTER_INVALID)
     {
      Print("Failed to initialize topology manager");
      return(INIT_FAILED);
     }
//--- Initial placement
   m_topologyManager.PlaceObjects(InpSwingLookback, InpMinSwingBars,
                                  InpPlaceTrendlines, InpPlaceSR,
                                  InpPlaceFibonacci, InpPlaceChannels,
                                  InpPlacePitchforks);
   m_topologyManager.RefreshObjects(InpNormalizeUserFibos);
   m_topologyManager.PrintStatistics();
   Print("=== Auto Object Trading System v5.00 (FIBONACCI FOCUS) ===");
   PrintFormat("Symbol: %s", _Symbol);
   PrintFormat("Point: %.5f, Digits: %d", g_point, g_digits);
   PrintFormat("Lot size: %.2f", InpLotSize);
   PrintFormat("Touch threshold: %.1f pips", InpTouchThreshold);
   PrintFormat("Min stop points: %d", InpMinStopPoints);
   PrintFormat("Normalize user Fibonacci objects: %s", InpNormalizeUserFibos ? "YES" : "NO");
   Print("Fibonacci types supported: OBJ_FIBO, OBJ_FIBOFAN, OBJ_FIBOTIMES,");
   Print("                         OBJ_FIBOARC, OBJ_FIBOCHANNEL, OBJ_EXPANSION");
   Print("===================================================");
   return(INIT_SUCCEEDED);
  }

//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   if(CheckPointer(m_topologyManager) == POINTER_DYNAMIC)
     {
      m_topologyManager.PrintStatistics();
      delete m_topologyManager;
     }
   Print("Auto Object Trading System deinitialized");
  }

//+------------------------------------------------------------------+
//| Chart event handler                                              |
//+------------------------------------------------------------------+
void OnChartEvent(const int id, const long &lparam, const double &dparam, const string &sparam)
  {
   if(id == CHARTEVENT_OBJECT_CREATE ||
      id == CHARTEVENT_OBJECT_DELETE ||
      id == CHARTEVENT_OBJECT_CHANGE)
     {
      if(CheckPointer(m_topologyManager) != POINTER_INVALID)
        {
         m_topologyManager.RefreshObjects(InpNormalizeUserFibos);
        }
     }
  }

//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
   if(CheckPointer(m_topologyManager) == POINTER_INVALID)
      return;
   m_topologyManager.PlaceObjects(InpSwingLookback, InpMinSwingBars,
                                  InpPlaceTrendlines, InpPlaceSR,
                                  InpPlaceFibonacci, InpPlaceChannels,
                                  InpPlacePitchforks);
   m_topologyManager.RefreshObjects(InpNormalizeUserFibos);
   if(PositionsTotal() > 0)
      return;
   if(TimeCurrent() - m_lastTradeTime < InpTradeCooldown)
      return;
   TradeSignal signals[];
   int signalCount = m_topologyManager.ProcessSignals(signals, 5);
   if(signalCount > 0 && InpEnableTrading)
     {
      //--- Sort by confidence
      int sortCount = MathMin(signalCount, 3);
      for(int i = 0; i < sortCount - 1; i++)
        {
         for(int j = i + 1; j < sortCount; j++)
           {
            if(signals[i].confidence < signals[j].confidence)
              {
               TradeSignal temp = signals[i];
               signals[i] = signals[j];
               signals[j] = temp;
              }
           }
        }
      TradeSignal signal = signals[0];
      if(signal.isValid && signal.confidence >= (double)InpMinConfidence / 100.0)
        {
         if(InpEnableDebug)
           {
            Print("=== SIGNAL GENERATED ===");
            PrintFormat("Object: %s | Type: %s", signal.objectName, ObjectTypeToString(signal.objectType));
            PrintFormat("Order: %s | Conf: %.0f%%",
                        (signal.orderType == ORDER_TYPE_BUY) ? "BUY" : "SELL",
                        signal.confidence * 100);
            PrintFormat("Entry: %.5f", signal.entryPrice);
            PrintFormat("Reason: %s", signal.reason);
            Print("=========================");
           }
         ExecuteAdaptiveTrade(signal, InpLotSize, InpMinStopPoints,
                              InpSLMultiplier, InpTPMultiplier,
                              m_trade, m_lastTradeTime, InpTradeCooldown,
                              InpEnableDebug);
        }
     }
  }
//+------------------------------------------------------------------+