//+------------------------------------------------------------------+
//|                                       SmartTrendlineManager2.mq5 |
//|                                   Copyright 2026, Francis Nyoike |
//|                                             https://www.mql5.com |
//|Trendline Management Framework                                    |
//|Part 1: Building a Stateful Trendline Management Framework        |
//|                           https://www.mql5.com/en/articles/23626 |
//|Automating Trendline Discovery and Lifecycle Management           |
//|Part 2                     https://www.mql5.com/en/articles/24253 |
//+------------------------------------------------------------------+
#property copyright "Copyright 2026, Francis Nyoike"
#property link      "https://www.mql5.com"
#property version   "1.2"
#property indicator_chart_window
#property indicator_buffers 0
#property indicator_plots   0

//--- Architectural Inclusion
#include "SmartTrendline2\TrendlineManager.mqh"

//+------------------------------------------------------------------+
//| Input Parameters                                                 |
//+------------------------------------------------------------------+
input string InpPrefix              = DEFAULT_TRENDLINE_PREFIX;    // Prefix filter for managed trendline objects
input double InpProximityPts        = DEFAULT_TOUCH_PROXIMITY_PTS; // Price distance used to detect trendline interaction

//--- Directional Trendline Colors (Part 2)
input color InpBullishTrendlineColor = clrLime;                    // Bullish trendline color (rising lines)
input color InpBearishTrendlineColor = clrBlue;                    // Bearish trendline color (falling lines)

input int    InpATRPeriod           = 14;                          // ATR calculation period for volatility measurement
input double InpBreakATRMult        = 1.0;                         // ATR distance required beyond trendline before break confirmation
input int    InpBreakConfirmCloses  = 2;                           // Number of consecutive closes required to confirm breakout
input double InpBounceATRMult       = 1.0;                         // ATR distance required away from trendline before bounce confirmation
input int    InpBounceConfirmCloses = 2;                           // Number of consecutive closes required to confirm rejection

//--- Automatic Trendline Generation (Part 2)
input bool   InpEnableAutoTrendlines  = true;                      // Master toggle for automatic trendline generation
input int    InpLookbackCandles       = 100;                       // Recent historical bars to scan for swings
input int    InpSwingDepth            = 5;                         // Bars on each side required for swing pivot
input int    InpMinTrendlineSwings    = 2;                         // Minimum qualifying swings to form trendline
input int    InpMinBarsBetweenSwings  = 5;                         // Minimum bars between qualifying swings
input int    InpSwingConfirmationBars = 3;                         // Minimum bars elapsed to confirm swing
input bool   InpAutoBullishTrendlines = true;                      // Enable automatic bullish trendlines (HL -> HL)
input bool   InpAutoBearishTrendlines = true;                      // Enable automatic bearish trendlines (LH -> LH)

//--- Broken Trendline Lifecycle (Part 2)
input bool   InpEnableResurrection    = true;                      // Enable resurrection on level reclaim
input int    InpResurrectionBars      = 10;                        // Max bars after break eligible for resurrection
input int    InpExpirationBars        = 20;                        // Max bars after break before line is purged

//--- Global Orchestrator Pointer & ATR Handle
CTrendlineManager *g_manager   = NULL;
int                g_atr_handle = INVALID_HANDLE;

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- Enable MT5 chart object deletion events
   ChartSetInteger(0, CHART_EVENT_OBJECT_DELETE, true);

//--- Instantiate Manager with User Inputs
   g_manager = new CTrendlineManager(InpPrefix,
                                     InpProximityPts,
                                     InpBreakATRMult,
                                     InpBreakConfirmCloses,
                                     InpBounceATRMult,
                                     InpBounceConfirmCloses,
                                     InpEnableAutoTrendlines,
                                     InpLookbackCandles,
                                     InpSwingDepth,
                                     InpMinTrendlineSwings,
                                     InpMinBarsBetweenSwings,
                                     InpSwingConfirmationBars,
                                     InpAutoBullishTrendlines,
                                     InpAutoBearishTrendlines,
                                     InpEnableResurrection,
                                     InpResurrectionBars,
                                     InpExpirationBars,
                                     InpBullishTrendlineColor,
                                     InpBearishTrendlineColor);
   if(g_manager == NULL)
     {
      Print("//--- [SmartTrendline] Critical Error: Failed to allocate CTrendlineManager.");
      return INIT_FAILED;
     }

//--- Initialize Manager and Perform Discovery Scan
   if(!g_manager.Init())
     {
      Print("//--- [SmartTrendline] Critical Error: Failed to initialize CTrendlineManager.");
      delete g_manager;
      g_manager = NULL;
      return INIT_FAILED;
     }

//--- Initialize ATR Handle
   g_atr_handle = iATR(_Symbol, _Period, InpATRPeriod);
   if(g_atr_handle == INVALID_HANDLE)
     {
      Print("//--- [SmartTrendline] Critical Error: Failed to create ATR handle.");
      delete g_manager;
      g_manager = NULL;
      return INIT_FAILED;
     }

   PrintFormat("//--- [SmartTrendline] Initialized | Prefix: '%s' | AutoGen: %s (MinSwings: %d) | Resurrect: %s (%d bars) | Expire: %d bars | ATR: %d",
               InpPrefix, (InpEnableAutoTrendlines ? "ON" : "OFF"), InpMinTrendlineSwings,
               (InpEnableResurrection ? "ON" : "OFF"), InpResurrectionBars, InpExpirationBars, InpATRPeriod);

   return INIT_SUCCEEDED;
  }

//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//--- Release ATR Handle
   if(g_atr_handle != INVALID_HANDLE)
     {
      IndicatorRelease(g_atr_handle);
      g_atr_handle = INVALID_HANDLE;
     }

//--- Timeframe / Parameter Switch Hygiene: purge auto-generated lines so
//--- M5/M15 structure never leaks onto H1/D1 when the chart changes.
   if(reason == REASON_CHARTCHANGE || reason == REASON_PARAMETERS)
     {
      if(g_manager != NULL)
        {
         //--- Auto lines are always wiped; manual prefix-scoped lines are kept
         //--- so the user's hand-drawn structure survives (wipe_manual = false).
         g_manager.ReleaseAllManaged(false);
        }
      ChartRedraw(0);
     }

//--- Clean Up Global Allocation
   if(g_manager != NULL)
     {
      delete g_manager;
      g_manager = NULL;
      PrintFormat("//--- [SmartTrendline] Indicator Unloaded. Reason Code: %d", reason);
     }
  }

//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
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
//--- Minimum Bar Safety Check
   if(rates_total < 3)
      return 0;

//--- Enforce Series Indexing (Bar 0 = Current Bar, Bar 1 = Last Closed Bar)
   ArraySetAsSeries(time, true);
   ArraySetAsSeries(open, true);
   ArraySetAsSeries(high, true);
   ArraySetAsSeries(low, true);
   ArraySetAsSeries(close, true);

//--- Fetch Latest ATR Value
   double atr_buffer[1];
   if(CopyBuffer(g_atr_handle, 0, 0, 1, atr_buffer) <= 0)
     {
      return prev_calculated;
     }
   double current_atr = atr_buffer[0];

//--- Pass Bar Arrays, Rates Total, and ATR to Manager Lifecycle Routine
   if(g_manager != NULL)
     {
      g_manager.Update(open, high, low, close, time, current_atr, rates_total);
     }

   return rates_total;
  }

//+------------------------------------------------------------------+
//| Chart Event Handler                                              |
//+------------------------------------------------------------------+
void OnChartEvent(const int id,
                  const long &lparam,
                  const double &dparam,
                  const string &sparam)
  {
//--- Forward All Chart Events Directly to Orchestrator
   if(g_manager != NULL)
     {
      g_manager.HandleChartEvent(id, lparam, dparam, sparam);

      //--- Unblock instant visual feedback on drag/edit events
      if(id == CHARTEVENT_OBJECT_DRAG || id == CHARTEVENT_OBJECT_ENDEDIT || id == CHARTEVENT_OBJECT_CREATE)
        {
         ChartRedraw(0);
        }
     }
  }
//+------------------------------------------------------------------+
