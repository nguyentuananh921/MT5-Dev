//+------------------------------------------------------------------+
//|                                                   DynamicSR4.mq5 |
//|                                  Copyright 2026, Francis Nyoike. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2026, Francis Nyoike."
#property link      "https://www.mql5.com"
#property version   "1.2"

//--- Include Standard Libraries for Dynamic Tracking
#include <Arrays\ArrayObj.mqh>
#include <Arrays\ArrayString.mqh>
#include <Trade\Trade.mqh>
#include "Include\MasterLog2.mqh"
#include "Include\TradeManager.mqh"
#include "Include\ZoneStrategy.mqh"
CLogger logger;

//+------------------------------------------------------------------+
//| System Enumerations                                              |
//+------------------------------------------------------------------+
enum ENUM_ZONE_TYPE
  {
   ZONE_SUPPORT,
   ZONE_RESISTANCE,
   ZONE_NEUTRAL
  };

enum ENUM_ZONE_STATUS
  {
   ZONE_VIRGIN,
   ZONE_BROKEN,
   ZONE_INACTIVE
  };

enum ENUM_ZONE_SOURCE
  {
   ZS_USER,
   ZS_EA
  };

//+------------------------------------------------------------------+
//| Input Configuration Parameters                                   |
//+------------------------------------------------------------------+
input group "--- Core Engine Settings ---"
input int      ApproachPips        = 10;    // Proximity alert aura distance in pips
input int      LookbackBars        = 300;   // Historical structural scanning depth
input int      SwingBars           = 5;     // Symmetrical bars required for structural pivot
input double   MergeSensitivity    = 1.5;   // Proximity threshold multiplier for merging zones

input group "--- Breakout & Ghost State Settings ---"
input double   BreakBufferPct      = 0.10;  // Percentage of zone height required for breakout penetration
input int      BreakConfirmCloses  = 4;     // Number of consecutive candle closes required to confirm breakout
input int      GhostBarLimit       = 10;    // Lifetime limit in bars for broken hollow zones
input bool     AllowResurrection   = true;  // Re-activate ghost zones if price closes back inside range

input group "--- Part 3 Quantitative Scoring Matrix ---"
input int      MinZoneScore        = 50;      // Minimum mathematical score (0-100) required to track zone
input bool     EnableVolumeValidation = true; // Enable/disable tick-volume relationship checks
input int      VolumeWeight        = 30;      // Max points allocated to institutional volume (Default: 30)
input int      VelocityWeight      = 40;      // Max points allocated to escape velocity (Default: 40)
input int      StructureWeight     = 30;      // Max points allocated to geometric symmetry (Default: 30)
input int      VelocityLookaheadBars = 3;     // Bar count lookahead window for departure calculation

input group "--- Part 3 Live Zone Evolution Tracking ---"
input bool     EnableTemporalDecay = false;    // Enable score degradation over time
input double   DecayRatePerBar     = 0.05;     // Score reduction unit per bar age
input double   TouchScoreBonus     = 5.0;      // Score increase awarded for clean rejections
input double   PenetrationPenalty  = 5.0;      // Score reduction unit for deep structural test drillings

input group "--- Symmetrical Bounce Settings ---"
input int      BounceConfirmCloses = 7;       // Bars Away Required for Confirmation
input double   BounceATRDistance   = 0.5;     // ATR Multiplier Filter for Movement Away
input int      BounceTimeoutBars   = 5;       // Max Bars Allowed to Remain Pending

input group "--- Part IV Automation Framework Switches ---"
input bool     CheckTradingSignals   = true;        // Enable automated execution signals
input ulong    MagicNumber           = 123456;      // EA Magic Number
input double   LotSize               = 0.10;        // Lot size

input group "--- Risk & Spread Protection ---"
input int      MaxSpreadPoints       = 30;          // Maximum tolerated slippage / spread points
input double   RiskRewardRatio       = 2.0;         // Strategy mathematical target multiplier
input double   ATRBufferMultiplier   = 1.5;         // Structural volatility invalidation cushion

input group "--- Trailing Stop Settings ---"
input bool     UseTrailingStop       = true;        // Enable real-time profit preservation
input double   TrailingStartPips     = 15.0;        // Minimum pips gained to activate trailing layer
input double   TrailingStepPips      = 5.0;         // Trailing step distance adjustments

input group "--- HTF Trend Filter Parameters ---"
input bool            InpUseHTFFilter       = true;       // Enable Higher Timeframe Trend Filter
input ENUM_TIMEFRAMES InpHtfTimeframe       = PERIOD_H1;  // HTF Trend Timeframe
input int             InpHtfMaPeriod        = 50;         // HTF Trend EMA Period
input bool            InpUseHTFRsiFilter    = true;       // Enable HTF RSI Exhaustion Filter
input int             InpHtfRsiPeriod       = 14;         // HTF RSI Period
input double          InpHtfRsiOverbought   = 70.0;       // HTF RSI Overbought Threshold
input double          InpHtfRsiOversold     = 30.0;       // HTF RSI Oversold Threshold

input group "--- Approach Context Parameters"
input int             InpApproachBars     = 3;           // Bars Evaluated Before Touch (1-5)
input double          InpApproachThreshold = 1.5;        // Aggressive Sprint Threshold (ATR Mult)
//+------------------------------------------------------------------+
//| Global Tracking Containers                                       |
//+------------------------------------------------------------------+
CArrayObj      active_zones;                         // Active structural supply and demand tracking arrays
CArrayString   blacklist;                            // Blacklisted names of manually deleted automated zones
datetime       last_bar_time       = 0;              // Track bar time shifts to execute periodic functions
int            atr_handle          = INVALID_HANDLE; // Core handle for structural ATR calculation
double         g_cached_atr        = 0.0;            // Global structural volatility cache

//--- Global Execution Layer Objects
CTradeManager *g_trade             = NULL;           // Decoupled institutional transaction routing engine
CZoneStrategy *g_strategy          = NULL;           // Analytical price action validation strategy module

//+------------------------------------------------------------------+
//| Zone Wrapper Class Architecture                                  |
//+------------------------------------------------------------------+
class CZone : public CObject
  {
public:
   string              name;                        // Unique chart object identifier
   double              price_level;                 // Median reference price of the structure
   double              top;                         // Upper boundary ceiling price
   double              bottom;                      // Lower boundary floor price
   double              height;                      // Absolute distance within the zone range

   //--- Ghost Tracking Variables
   bool                is_broken;                   // Flag indicating the zone has been penetrated
   datetime            broken_time;                 // Exact timestamp when breakout confirmation occurred
   int                 consecutive_closes_outside;  // Counter for closing candles beyond boundaries

   //--- New State-Aware Engine Locks (Integrated Here)
   bool              is_pending;                     // True if an interaction is underway but unresolved
   int               consecutive_rejection_closes;
   bool              was_recently_moved;

   ENUM_ZONE_TYPE     type;                          // Structural classification (Support/Resistance)
   ENUM_ZONE_STATUS  status;                         // Operational state tracking (Virgin/Broken/Inactive)
   bool              is_user_zone;                   // Identifies if manually drawn or auto-generated
   bool              was_drawn;                      // Confirmed visual presence on active chart
   datetime          created;                        // Original generation timestamp
   datetime          last_touch_time;                // Last recorded price test interaction

   bool              buy_triggered;                  // Internal signal flag for support interaction
   bool              sell_triggered;                 // Internal signal flag for resistance interaction
   double            strength;                       // Structural weight ranking score

   //--- Part 3 Structural Metrics Memory Space
   int                zone_score;                    // Final calculated evaluation score (0 - 100)
   double             Current_zone_score;            // Current active score used by the engine
   string             zone_tier;                     // Categorized tier ("HIGH", "MODERATE", "LOW")
   double             initial_volume_ratio;          // Calculated capital backing coefficient
   double             departure_velocity;            // Volatility-normalized momentum velocity

   //--- Part 3 Live Interaction & Performance Trackers
   int                touch_count;                   // Cumulative price test contacts
   int                bounce_count;                  // Successful rejections away from zone
   int                failure_count;                 // Minor penetrations / invalidations
   double             max_reaction_pips;             // Peak departure distance achieved before death
   int                resurrection_count;            // Total level reactivations logged
   string             breakout_quality;              // Classified breakout force ("WEAK", "MODERATE", "STRONG")

   //--- Default Constructor
                     CZone()
     {
      name = "";
      price_level = 0.0;
      top = 0.0;
      bottom = 0.0;
      height = 0.0;
      is_broken = false;
      broken_time = 0;
      consecutive_closes_outside = 0;
      type = ZONE_NEUTRAL;
      status = ZONE_VIRGIN;
      is_user_zone = true; // Defaulting an empty declaration as user-driven until specified
      was_drawn = false;
      created = TimeCurrent();
      last_touch_time = 0;
      buy_triggered = false;
      sell_triggered = false;
      strength = 1.0;
      was_recently_moved = false;

      //--- Explicit Part 3 Baseline Initializations for User Drawings
      Current_zone_score   =0.0;
      zone_score           = 0;
      zone_tier            = "NONE";
      initial_volume_ratio = 1.0;
      departure_velocity   = 0.0;
      touch_count          = 0;
      bounce_count         = 0;
      failure_count        = 0;
      max_reaction_pips    = 0.0;
      resurrection_count   = 0;
      breakout_quality     = "NONE";

      //--- State-Aware Initializations
      is_pending                 = false;
      consecutive_rejection_closes = 0;

     }

   //--- Primary Algorithmic Constructor (Optimized)
                     CZone(double p, ENUM_ZONE_TYPE t, datetime ct, double current_atr)
     {
      price_level = p;
      type = t;
      status = ZONE_VIRGIN;
      is_user_zone = false;
      was_drawn = false;
      is_broken = false;
      broken_time = 0;

      //--- Dynamic Volatility Sizing via Cached Environment Param
      double zone_height = 0.0;
      if(current_atr > 0.0)
        {
         zone_height = current_atr * 0.5;    // Zone size scales directly with volatility
        }
      else
        {
         zone_height = 20.0 * _Point * 10.0; // Fail-safe default size if data is empty
        }

      //--- Geometric Coordinate Calculations
      top = (type == ZONE_RESISTANCE) ? p : p + zone_height;
      bottom = (type == ZONE_RESISTANCE) ? p - zone_height : p;
      height = top - bottom;

      created = ct;
      last_touch_time = ct;
      consecutive_closes_outside = 0;
      buy_triggered = false;
      sell_triggered = false;
      strength = 1.0;

      //--- Explicit Part 3 Baseline Initializations to Prevent Telemetry Crashes
      zone_score           = 0;
      Current_zone_score   =0.0;
      zone_tier            = "NONE";
      initial_volume_ratio = 1.0;
      departure_velocity   = 0.0;
      touch_count          = 0;
      bounce_count         = 0;
      failure_count        = 0;
      max_reaction_pips    = 0.0;
      resurrection_count   = 0;
      breakout_quality     = "NONE";

      //--- State-Aware Initializations
      is_pending                 = false;
      consecutive_rejection_closes = 0;
      was_recently_moved = false;


      //--- Unique System Name Generation
      name = (type == ZONE_SUPPORT ? "S_" : "R_") + EnumToString(_Period) + "_" +
             DoubleToString(p, _Digits) + "_" + IntegerToString((long)ct);
     }

   //--- Proximity Border Validation Method
   bool              IsPriceNearZone(double price)
     {
      double pipMultiplier = (_Digits == 3 || _Digits == 5) ? 10.0 : 1.0;
      double proximityBuffer = ApproachPips * _Point * pipMultiplier;

      bool isInside = (price >= (bottom - proximityBuffer) && price <= (top + proximityBuffer));
      return isInside;
     }

   //--- State-Based Color Mapping Method
   color             GetColor(void)
     {
      if(is_broken)
        {
         return clrWhite; // Ghost states render as a hollow white border
        }
      if(status == ZONE_INACTIVE)
        {
         return clrGray;  // Deactivated states render in neutral gray
        }
      if(type == ZONE_SUPPORT)
        {
         return (status == ZONE_VIRGIN ? clrLimeGreen : clrGreen);
        }

      return (status == ZONE_VIRGIN ? clrRed : clrOrangeRed);
     }
  };
//+------------------------------------------------------------------+
//| Forward Declarations of New Engine Functions for part III        |
//+------------------------------------------------------------------+
bool   RegisterUserZone(string obj_name);      // renamed from RegisterHybridZone for part(III) compliance
void ResolvePendingInteractions(double atr);
void MonitorZoneLifecycle(CLogger &log_instance, CArrayObj &zones, double atr, double multiplier);
int    AnalyzeZoneCandidate(double p, ENUM_ZONE_TYPE t, double &out_vol_ratio, double &out_velocity, string &out_tier);

//+------------------------------------------------------------------+
//| Foward Declaration  of existing Functions                        |
//+------------------------------------------------------------------+
CZone* GetZoneByName(string obj_name);
void UpdateZoneCoordinates(string obj_name);
void RemoveZoneByName(string obj_name);
void NukeIrrelevantZones(void);
void MergeZones(double atr);
void DetectDynamicZones(double atr);
void TryCreateAutoZone(double p, ENUM_ZONE_TYPE t, datetime dt, double atr, int score, string tier, double vol_ratio, double velo_pips);
void UpdateZoneVisuals(bool force_time_extension);
//+------------------------------------------------------------------+
//| High-Performance Volatility Pipeline Extraction Helper           |
//+------------------------------------------------------------------+
bool UpdateGlobalVolatilityCache(void)
  {
   if(atr_handle == INVALID_HANDLE)
     {
      g_cached_atr = 0.0;
      return false;
     }

   static double atr_buffer[1]; // Static single-element buffer avoids per-tick array re-allocation

   if(CopyBuffer(atr_handle, 0, 0, 1, atr_buffer) > 0)
     {
      g_cached_atr = atr_buffer[0];
      return true;
     }

   return false;
  }

//+------------------------------------------------------------------+
//| Expert Initialization Function                                   |
//+------------------------------------------------------------------+
int OnInit(void)
  {
//--- Purge visual space to prevent coordinate overlays
   ObjectsDeleteAll(0, -1, OBJ_RECTANGLE);

   active_zones.FreeMode(true);
   active_zones.Clear();
   blacklist.Clear();

//--- Force MetaTrader core to stream visual object events
   ChartSetInteger(0, CHART_EVENT_OBJECT_CREATE, true);
   ChartSetInteger(0, CHART_EVENT_OBJECT_DELETE, true);

   atr_handle = iATR(_Symbol, _Period, 14);
   if(atr_handle == INVALID_HANDLE)
     {
      Print("[BOOT ERROR] Failed to instantiate core ATR indicator handle.");
      return(INIT_FAILED);
     }

//--- Initial local data copy for startup procedures
   UpdateGlobalVolatilityCache(); // Sets g_cached_atr safely
   logger.Initialize();

//--- Sync and find dynamic zones
   DetectDynamicZones(g_cached_atr, true); // Pass true to perform deep historical boot scan on startup
   NukeIrrelevantZones();

//--- INITIALIZE THE TRADING ENGINE INFRASTRUCTURE COMPONENTS
   if(CheckTradingSignals)
     {
      g_trade = new CTradeManager(MagicNumber,
                                  LotSize,
                                  MaxSpreadPoints,
                                  UseTrailingStop,
                                  (int)TrailingStartPips,
                                  (int)TrailingStepPips);

      g_strategy = new CZoneStrategy(MinZoneScore,
                                     BounceConfirmCloses,
                                     RiskRewardRatio,
                                     ATRBufferMultiplier,
                                     InpUseHTFFilter,
                                     InpHtfTimeframe,
                                     InpHtfMaPeriod,
                                     InpUseHTFRsiFilter,     // Enable HTF RSI Exhaustion Filter
                                     InpHtfRsiPeriod,        // HTF RSI Period
                                     InpHtfRsiOverbought,    // HTF RSI Overbought Threshold
                                     InpHtfRsiOversold,      // HTF RSI Oversold Threshold
                                     InpApproachBars,
                                     InpApproachThreshold);
     }

   Print(">>> successfully initialized");
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert Tick Function                                             |
//+------------------------------------------------------------------+
void OnTick(void)
  {
   datetime current_candle_time = iTime(_Symbol, _Period, 0);
   bool is_new_bar = (current_candle_time != last_bar_time);

   if(is_new_bar)
     {
      last_bar_time = current_candle_time;

      //--- Single point of entry update for data pipeline
      UpdateGlobalVolatilityCache();

      //--- Downstream distribution using pristine global state context
      ResolvePendingInteractions(g_cached_atr);
      DetectDynamicZones(g_cached_atr, false); // Pass false to scan ONLY the single newly matured bar open
      MergeZones(g_cached_atr);

      //--- State Machine Lifecycle Evaluation Pipeline (Using 1.5 multiplier based on your input preference)
      MonitorZoneLifecycle(logger, active_zones, g_cached_atr, MergeSensitivity);

      UpdateZoneVisuals(true);
      ChartRedraw(0);
     }
   else
     {
      //--- State Machine Lifecycle Evaluation Pipeline (Run on every tick to capture immediate manual adjustments)
      MonitorZoneLifecycle(logger, active_zones, g_cached_atr, MergeSensitivity);

      UpdateZoneVisuals(false);
     }

//--- Tick-by-tick risk management and dynamic trailing updates
   if(CheckTradingSignals && CheckPointer(g_trade) != POINTER_INVALID)
     {
      g_trade.UpdateTrailingStop(_Symbol);
     }
  }
//+------------------------------------------------------------------+
//| Expert Deinitialization Function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   ObjectsDeleteAll(0, -1, OBJ_RECTANGLE);

   active_zones.Clear();
   blacklist.Clear();

   if(atr_handle != INVALID_HANDLE)
     {
      IndicatorRelease(atr_handle);
      atr_handle = INVALID_HANDLE;
     }

//--- DEALLOCATE STRATEGY AND EXECUTION LAYER POINTERS SAFELY FROM MEMORY
   if(CheckPointer(g_trade) == POINTER_DYNAMIC)
     {
      delete g_trade;
      g_trade = NULL;
     }
   if(CheckPointer(g_strategy) == POINTER_DYNAMIC)
     {
      delete g_strategy;
      g_strategy = NULL;
     }

   PrintFormat(">>> Deinitialization Engine detached smoothly. Reason Code: %d", reason);
   ChartRedraw();
  }
//+------------------------------------------------------------------+
//| Internal Helper: Look up Object Pointer Mapping by Reference Name|
//+------------------------------------------------------------------+
CZone* GetZoneByName(string obj_name)
  {
   for(int i = 0; i < active_zones.Total(); i++)
     {
      CZone *z = (CZone*)active_zones.At(i);
      if(z != NULL && z.name == obj_name)
         return z;
     }
   return NULL;
  }

//+------------------------------------------------------------------+
//| Asynchronous Event Processing Engine                             |
//+------------------------------------------------------------------+
void OnChartEvent(const int id, const long &lparam, const double &dparam, const string &sparam)
  {
//--- Capturing User-Created Zones
   if(id == CHARTEVENT_OBJECT_CREATE)
     {
      //--- Filter immediately using system automated structural prefixes to prevent double registration
      if(StringSubstr(sparam, 0, 2) == "S_" || StringSubstr(sparam, 0, 2) == "R_")
         return;

      if(ObjectGetInteger(0, sparam, OBJPROP_TYPE) == OBJ_RECTANGLE)
        {
         if(RegisterUserZone(sparam))
           {
            //--- Explicitly declared as pointer to resolve structural conversion error
            CZone *z = GetZoneByName(sparam);
            double z_top = (z != NULL) ? z.top : ObjectGetDouble(0, sparam, OBJPROP_PRICE, 0);
            double z_bottom = (z != NULL) ? z.bottom : ObjectGetDouble(0, sparam, OBJPROP_PRICE, 1);
            string z_type = (z != NULL) ? EnumToString(z.type) : "ZONE_SUPPORT";

            //--- Detailed Logging Structure Implementation
            string details = StringFormat(">>> Registered user zone: %s | Bounds: %.5f - %.5f", sparam, z_top, z_bottom);
            logger.LogZone("USER", ZE_CREATED, sparam, z_type, z_top, z_bottom, "Strength:1.0", details);
           }
        }
     }

//--- Capturing Zone Modifications (Drag Adjustments or Point Re-sizing)
   else
      if(id == CHARTEVENT_OBJECT_DRAG || id == CHARTEVENT_OBJECT_ENDEDIT)
        {
         if(ObjectGetInteger(0, sparam, OBJPROP_TYPE) == OBJ_RECTANGLE)
           {
            UpdateZoneCoordinates(sparam);

            //--- Explicitly declared as pointer to resolve structural conversion error
            CZone *z = GetZoneByName(sparam);
            if(z != NULL)
              {
               string details = StringFormat(">>> ZONE MANIPULATION Resized object: %s | New Bounds: %.5f - %.5f", sparam, z.top, z.bottom);
               logger.LogZone("USER", ZE_MODIFIED, sparam, EnumToString(z.type), z.top, z.bottom, "Strength:1.0", details);
              }
            ChartRedraw(0);
           }
        }

      //--- Capturing Deletions (Object Extracted From Chart)
      else
         if(id == CHARTEVENT_OBJECT_DELETE)
           {
            //--- Explicitly declared as pointer to resolve structural conversion error
            CZone *z = GetZoneByName(sparam);
            if(z != NULL)
              {
               string details = ">>> Deletion Detected user extraction of: " + sparam;
               logger.LogZone(z.is_user_zone ? "USER" : "AUTO", ZE_DELETED, sparam, EnumToString(z.type), z.top, z.bottom, "Strength:0.0", details);
              }

            //--- Memory state cleanup
            RemoveZoneByName(sparam);
            ChartRedraw(0);
           }
  }
//+------------------------------------------------------------------+
//| Registers a Raw Manual User Box into a Tracked Engine Object     |
//+------------------------------------------------------------------+
bool RegisterUserZone(string obj_name)
  {
   if(ObjectFind(0, obj_name) < 0)
      return false;

   double boundary_p1 = ObjectGetDouble(0, obj_name, OBJPROP_PRICE, 0);
   double boundary_p2 = ObjectGetDouble(0, obj_name, OBJPROP_PRICE, 1);
   double bid = SymbolInfoDouble(_Symbol, SYMBOL_BID);

//--- Get current volatility context safely from structural global state
   double passed_atr = g_cached_atr;

   ENUM_ZONE_TYPE derived_type = ((boundary_p1 + boundary_p2) / 2.0 > bid) ? ZONE_RESISTANCE : ZONE_SUPPORT;
   CZone* new_zone = new CZone((boundary_p1 + boundary_p2) / 2.0, derived_type, TimeCurrent(), passed_atr);

   new_zone.name = obj_name;
   new_zone.is_user_zone = true;
   new_zone.was_recently_moved = true;
   new_zone.top = MathMax(boundary_p1, boundary_p2);
   new_zone.bottom = MathMin(boundary_p1, boundary_p2);
   new_zone.height = new_zone.top - new_zone.bottom;
   new_zone.price_level = (new_zone.top + new_zone.bottom) / 2.0;
   new_zone.was_drawn = true;

   ObjectSetInteger(0, obj_name, OBJPROP_TIME, 1, TimeCurrent());
   ObjectSetString(0, obj_name, OBJPROP_TEXT, "USER");
   ObjectSetInteger(0, obj_name, OBJPROP_RAY_RIGHT, true);
   ObjectSetInteger(0, obj_name, OBJPROP_BACK, true);
   ObjectSetInteger(0, obj_name, OBJPROP_FILL, true);
   ObjectSetInteger(0, obj_name, OBJPROP_COLOR, new_zone.GetColor());

   active_zones.Add(new_zone);
   return true;
  }
//+------------------------------------------------------------------+
//| Updates Memory Trackers Exclusively for a Modified Object Name   |
//+------------------------------------------------------------------+
void UpdateZoneCoordinates(string obj_name)
  {
   CZone* existing_zone = NULL;

   for(int z = 0; z < active_zones.Total(); z++)
     {
      CZone* zone_ptr = (CZone*)active_zones.At(z);
      if(zone_ptr != NULL && zone_ptr.name == obj_name)
        {
         existing_zone = zone_ptr;
         break;
        }
     }

   if(existing_zone == NULL)
     {
      //--- Guard mechanism logic utilizing fast matching prefixes
      if(StringSubstr(obj_name, 0, 2) != "S_" && StringSubstr(obj_name, 0, 2) != "R_")
         RegisterUserZone(obj_name);
      return;
     }

   double boundary_p1 = ObjectGetDouble(0, obj_name, OBJPROP_PRICE, 0);
   double boundary_p2 = ObjectGetDouble(0, obj_name, OBJPROP_PRICE, 1);

   existing_zone.top = MathMax(boundary_p1, boundary_p2);
   existing_zone.bottom = MathMin(boundary_p1, boundary_p2);
   existing_zone.height = existing_zone.top - existing_zone.bottom;
   existing_zone.price_level = (existing_zone.top + existing_zone.bottom) / 2.0;
   existing_zone.was_recently_moved = true;

//--- Legacy Safeguard Gate: Convert an automated zone to user zone if manually dragged
   if(!existing_zone.is_user_zone)
     {
      existing_zone.is_user_zone = true;
      ObjectSetString(0, existing_zone.name, OBJPROP_TEXT, "USER");

      //--- Dynamic initialization type routing only happens when transforming an automated zone to user control
      double bid = SymbolInfoDouble(_Symbol, SYMBOL_BID);
      existing_zone.type = (existing_zone.price_level > bid) ? ZONE_RESISTANCE : ZONE_SUPPORT;
     }

//--- Refresh visual properties immediately
   ObjectSetInteger(0, obj_name, OBJPROP_TIME, 1, TimeCurrent()); // Force Time 2 forward again
   ObjectSetInteger(0, obj_name, OBJPROP_RAY_RIGHT, true);
   ObjectSetInteger(0, obj_name, OBJPROP_COLOR, existing_zone.GetColor());
  }
//+------------------------------------------------------------------+
//| Cleans Up Internal Memory Pointers Mapping to Deleted Name       |
//+------------------------------------------------------------------+
void RemoveZoneByName(string obj_name)
  {
   for(int i = active_zones.Total() - 1; i >= 0; i--)
     {
      CZone* z = (CZone*)active_zones.At(i);
      if(z == NULL)
         continue;

      if(z.name == obj_name)
        {
         if(!z.is_user_zone)
           {
            //--- Explicitly stringify the double
            blacklist.Add(DoubleToString(z.price_level, _Digits));
           }

         //--- Mark state as visually dead before clearing the reference class holder
         z.was_drawn = false;

         //--- Extract memory state info before object deletion for precise logging
         string z_source = z.is_user_zone ? "USER" : "AUTO";
         string z_type = EnumToString(z.type);
         double z_top = z.top;
         double z_bottom = z.bottom;

         //--- Detailed automated internal cleanup notification
         string details = ">>> Memory cleared for internal object tracking array handle: " + obj_name;

         //--- Log zone statistics completely BEFORE releasing heap allocations to ensure absolute thread safety
         logger.LogZone(z_source,
                        ZE_DELETED,
                        obj_name,
                        z_type,
                        z_top,
                        z_bottom,
                        "State:CLEANUP",
                        details);

         active_zones.Delete(i);
        }
     }
  }
//+------------------------------------------------------------------+
//| Cleans Up Irrelevant Untradeable Structural Layers on Startup    |
//+------------------------------------------------------------------+
void NukeIrrelevantZones(void)
  {
   double bid = SymbolInfoDouble(_Symbol, SYMBOL_BID);
   double ask = SymbolInfoDouble(_Symbol, SYMBOL_ASK);
   int purged = 0;

   for(int i = active_zones.Total() - 1; i >= 0; i--)
     {
      CZone *z = (CZone*)active_zones.At(i);
      if(z == NULL)
         continue;

      bool is_dead = false;

      if(z.type == ZONE_SUPPORT && bid < z.bottom)
         is_dead = true;

      if(z.type == ZONE_RESISTANCE && ask > z.top)
         is_dead = true;

      if(is_dead)
        {
         ObjectDelete(0, z.name);
         active_zones.Delete(i);
         purged++;
        }
     }

   if(purged > 0)
      PrintFormat(">>> [INITIAL PURGE] DELETED %d irrelevant zones from memory and chart.", purged);

   ChartRedraw(0);
  }

//+------------------------------------------------------------------+
//| Pure Interaction Engine - Counts Touches & Rejections Only       |
//+------------------------------------------------------------------+
void MonitorZoneLifecycle(CLogger &log_instance, CArrayObj &zones, double atr, double multiplier)
  {
   static datetime last_bar = 0;
   datetime bar_time = iTime(_Symbol, _Period, 1);
   bool is_new_bar = (bar_time != last_bar);

//--- If it's not a new bar, we ONLY want to scan if there are manually moved user zones needing an immediate check
   if(!is_new_bar)
     {
      bool work_to_do = false;
      for(int i = 0; i < zones.Total(); i++)
        {
         CZone *z = (CZone*)zones.At(i);
         if(z != NULL)
           {
            if(z.is_user_zone && z.was_recently_moved)
              {
               work_to_do = true;
               break;
              }
           }
        }
      if(!work_to_do)
        {
         return;
        }
     }
   else
     {
      last_bar = bar_time; // Lock in the new bar completion stamp
     }

   double tolerance = atr * multiplier;

//--- Read historical closed candle data for regular processing
   double high  = iHigh(_Symbol, _Period, 1);
   double low   = iLow(_Symbol, _Period, 1);
   double close = iClose(_Symbol, _Period, 1);

//--- Read immediate real-time quotes for live drag interactions
   double live_bid = SymbolInfoDouble(_Symbol, SYMBOL_BID);

   for(int i = zones.Total() - 1; i >= 0; i--)
     {
      CZone *z = (CZone*)zones.At(i);
      if(z == NULL || z.is_broken) // Only track live active structures
         continue;

      //--- Establish whether this specific item is processed via historical bar logic or live drag override
      bool evaluation_triggered = false;
      bool touched = false;

      //--- BRANCH A: Live User-Drag Immediate Evaluation
      if(z.is_user_zone && z.was_recently_moved)
        {
         evaluation_triggered = true;
         z.was_recently_moved = false; // Immediately lower the flag so it only evaluates on-tick once!

         double upper_limit = z.top + tolerance;
         double lower_limit = z.bottom - tolerance;
         touched = (live_bid <= upper_limit && live_bid >= lower_limit);
        }
      //--- BRANCH B: Standard Completed-Bar Engine
      else
         if(is_new_bar)
           {
            evaluation_triggered = true;

            //--- Apply Temporal Decay to all live zones once per completed bar
            if(EnableTemporalDecay)
              {
               z.Current_zone_score = MathMax(0.0, z.Current_zone_score - DecayRatePerBar);
              }

            touched = (low <= z.top + tolerance && high >= z.bottom - tolerance);
           }

      //--- If neither condition triggered evaluation for this zone on this tick, skip it
      if(!evaluation_triggered)
         continue;

      //--- STATE-AWARE ENGINE GATE: Skip evaluation if an interaction is already pending resolution
      if(z.is_pending || !touched)
         continue;

      //--- Establish Interaction Lock: One interaction = exactly one touch increment
      z.is_pending = true;
      z.touch_count++;
      z.last_touch_time = iTime(_Symbol, _Period, 1);
      z.consecutive_rejection_closes = 0; // Reset rejection validation counter

      //--- Calculate current live age of the structure in bars
      int current_age = iBarShift(_Symbol, _Period, z.created);

      //--- Construct a standardized, clean context string matching  Part III data matrix
      string context = StringFormat("Score:%d|CurrentScore:%.2f|Birth Tier:%s|VolRatio:%.2f|VeloPips:%.1f|Touches:%d|Bounces:%d|Failures:%d|Resurrections:%d|MaxReaction:%.1f|AgeBars:%d|Status:PENDING_TEST",
                                    z.zone_score, z.Current_zone_score, z.zone_tier, z.initial_volume_ratio, z.departure_velocity,
                                    z.touch_count, z.bounce_count, z.failure_count, z.resurrection_count, z.max_reaction_pips, current_age);

      string details = StringFormat(">>> LIVE ZONE PENDING %s | T:%d B:%d F:%d Status:%s",
                                    z.name, z.touch_count, z.bounce_count, z.failure_count, EnumToString(z.status));

      string dynamic_source = z.is_user_zone ? "USER" : "AUTO";

      log_instance.LogZone(dynamic_source,
                           ZE_UPDATED,
                           z.name,
                           EnumToString(z.type),
                           z.top,
                           z.bottom,
                           context,
                           details);
     }
  }
//+------------------------------------------------------------------+
//| Collapses Adjacent Overlapping Ranges Using Volatility Buffers   |
//+------------------------------------------------------------------+
void MergeZones(double atr)
  {
   if(atr <= 0.0)
      return;
   double merge_threshold = atr * MergeSensitivity;

   for(int i = active_zones.Total() - 1; i >= 1; i--)
     {
      CZone* z1 = (CZone*)active_zones.At(i);
      if(z1 == NULL)
         continue;

      for(int j = i - 1; j >= 0; j--)
        {
         CZone* z2 = (CZone*)active_zones.At(j);
         if(z2 == NULL)
            continue;

         if(z1.type != z2.type)
            continue;

         //--- Phase 2 Analytical Guard Gate: USER zones never participate in statistical merging
         if(z1.is_user_zone || z2.is_user_zone)
            continue;

         double space_distance = MathAbs(z1.price_level - z2.price_level);
         if(space_distance > merge_threshold)
            continue;

         //--- Cache z2's details for our deep telemetry log before it is destroyed from memory
         string z2_dead_name = z2.name;

         //--- Part III Preservation: Retain peak velocity and maximum volume presence
         z1.zone_score           = MathMax(z1.zone_score, z2.zone_score);
         z1.initial_volume_ratio = MathMax(z1.initial_volume_ratio, z2.initial_volume_ratio);
         z1.departure_velocity   = MathMax(z1.departure_velocity, z2.departure_velocity);

         //--- Expand Zone Classification Hierarchy (Introduce Elite Tier)
         if(z1.zone_score >= 95)
            z1.zone_tier = "ELITE";
         else
            if(z1.zone_score >= 80)
               z1.zone_tier = "HIGH";
            else
               if(z1.zone_score >= 50)
                  z1.zone_tier = "MODERATE";
               else
                  z1.zone_tier = "LOW";

         //--- Consolidate Cumulative Interaction Telemetry Records
         z1.touch_count        += z2.touch_count;
         z1.bounce_count       += z2.bounce_count;
         z1.failure_count      += z2.failure_count;
         z1.resurrection_count += z2.resurrection_count;
         z1.max_reaction_pips   = MathMax(z1.max_reaction_pips, z2.max_reaction_pips);

         //--- State-Aware Engine Integration: Inherit interaction lock states cleanly
         if(z2.is_pending)
           {
            z1.is_pending = true;
            if(z1.last_touch_time == 0)
               z1.last_touch_time = z2.last_touch_time;
           }

         //--- Preserving Structural Metadata
         z1.strength += z2.strength;                     // Accumulate structural scoring contextual weight
         z1.created   = MathMin(z1.created, z2.created); // Retain original timeline generation timestamp

         //--- Recalculate physical coordinates
         z1.top         = MathMax(z1.top,    z2.top);
         z1.bottom      = MathMin(z1.bottom, z2.bottom);
         z1.height      = z1.top - z1.bottom;
         z1.price_level = (z1.top + z1.bottom) / 2.0;

         //--- Compute current live age of the consolidated structure in bars
         int consolidated_age = iBarShift(_Symbol, _Period, z1.created);

         //--- Standardized analytical telemetry string containing every single captured live tracker metric
         string context_info = StringFormat("Score:%d|Tier:%s|VolRatio:%.2f|VeloPips:%.1f|Touches:%d|Bounces:%d|Failures:%d|Resurrections:%d|MaxReaction:%.1f|AgeBars:%d|Absorbed:%s|Status:MERGED",
                                            z1.zone_score,
                                            z1.zone_tier,
                                            z1.initial_volume_ratio,
                                            z1.departure_velocity,
                                            z1.touch_count,
                                            z1.bounce_count,
                                            z1.failure_count,
                                            z1.resurrection_count,
                                            z1.max_reaction_pips,
                                            consolidated_age,
                                            z2_dead_name);

         //--- Deep, high-fidelity log detail (Terminal Output Match)
         string details = StringFormat(">>> [ZONE MERGED] Combined overlapping structures into: %s (Absorbed: %s) | Total Touches: %d | New Bounds: %.5f - %.5f",
                                       z1.name, z2_dead_name, z1.touch_count, z1.top, z1.bottom);

         //--- Simultaneous write and print execution to purely analytical dataset
         logger.LogZone("AUTO",
                        ZE_MODIFIED,
                        z1.name,
                        EnumToString(z1.type),
                        z1.top,
                        z1.bottom,
                        context_info,
                        details);

         //--- Clean up chart clutter and purge the absorbed class instance from the tracking array
         ObjectDelete(0, z2_dead_name);
         active_zones.Delete(j);
         break;
        }
     }
  }
//+------------------------------------------------------------------+
//| Scans Historical Market Data to Identify Valid Symmetrical Pivots|
//+------------------------------------------------------------------+
void DetectDynamicZones(double atr, bool is_initial_scan = false)
  {
   if(atr <= 0.0)
      return;

   MqlRates rates[];
   ArraySetAsSeries(rates, true);

//--- Dynamic lookahead spacing to capture macro structures and velocity windows fluidly
   int bars_to_copy = LookbackBars + (SwingBars * 2) + VelocityLookaheadBars;

   if(CopyRates(_Symbol, _Period, 0, bars_to_copy, rates) < bars_to_copy)
      return;

//--- Determine loop bounds: full scan for startup, or single mature index check for live streaming ticks
   int start_index = SwingBars + VelocityLookaheadBars;
   int end_index   = is_initial_scan ? LookbackBars : (start_index + 1);

//--- Start search buffer outside lookahead scope to guarantee evaluation integrity
   for(int i = start_index; i < end_index; i++)
     {
      bool is_high_confirmed = true;
      bool is_low_confirmed  = true;

      for(int j = 1; j <= SwingBars; j++)
        {
         if(rates[i].high <= rates[i-j].high || rates[i].high <= rates[i+j].high)
            is_high_confirmed = false;

         if(rates[i].low >= rates[i-j].low || rates[i].low >= rates[i+j].low)
            is_low_confirmed = false;

         if(!is_high_confirmed && !is_low_confirmed)
            break;
        }

      int calculated_score   = 0;
      string calculated_tier = "";
      double vol_ratio       = 0.0;
      double velo_pips       = 0.0;

      if(is_high_confirmed)
        {
         calculated_score = AnalyzeZoneCandidate(i, ZONE_RESISTANCE,
                                                 rates[i].high,
                                                 atr,
                                                 vol_ratio,
                                                 velo_pips,
                                                 calculated_tier);

         if(calculated_score >= MinZoneScore)
           {
            TryCreateAutoZone(rates[i].high,
                              ZONE_RESISTANCE,
                              rates[i].time,
                              atr,
                              calculated_score,
                              calculated_tier,
                              vol_ratio,
                              velo_pips);
           }
        }

      if(is_low_confirmed)
        {
         calculated_score = AnalyzeZoneCandidate(i, ZONE_SUPPORT,
                                                 rates[i].low,
                                                 atr,
                                                 vol_ratio,
                                                 velo_pips,
                                                 calculated_tier);

         if(calculated_score >= MinZoneScore)
           {
            TryCreateAutoZone(rates[i].low,
                              ZONE_SUPPORT,
                              rates[i].time,
                              atr,
                              calculated_score,
                              calculated_tier,
                              vol_ratio,
                              velo_pips);
           }
        }
     }
  }
//+------------------------------------------------------------------+
//| Filters Structural Creation via Blacklists and Proximity Checks  |
//+------------------------------------------------------------------+
void TryCreateAutoZone(double p,
                       ENUM_ZONE_TYPE t,
                       datetime dt,
                       double atr,
                       int score,
                       string tier,
                       double vol_ratio,
                       double velo_pips)
  {
   double bid = SymbolInfoDouble(_Symbol, SYMBOL_BID);
   double ask = SymbolInfoDouble(_Symbol, SYMBOL_ASK);

//--- Immediate validity barrier checks
   if(t == ZONE_SUPPORT && p > bid)
      return;

   if(t == ZONE_RESISTANCE && p < ask)
      return;

//--- Prevent historical duplication errors
   for(int i = 0; i < active_zones.Total(); i++)
     {
      CZone *z = (CZone*)active_zones.At(i);
      if(z == NULL)
         continue;

      if(z.created == dt && z.type == t)
         return;
     }

   double merge_threshold = atr * MergeSensitivity;

//--- Proximity-based blacklist restriction check
   for(int i = 0; i < blacklist.Total(); i++)
     {
      double blacklisted_price = StringToDouble(blacklist.At(i));
      if(MathAbs(blacklisted_price - p) < merge_threshold)
         return;
     }

//--- Cluster prevention
   for(int i = 0; i < active_zones.Total(); i++)
     {
      CZone *z = (CZone*)active_zones.At(i);
      if(z == NULL)
         continue;

      if(MathAbs(z.price_level - p) < merge_threshold)
         return;
     }

//--- Create zone (FULLY INITIALIZED FIRST)
   CZone *nz = new CZone(p, t, dt, atr);

//--- Ensure deterministic ID (no unstable EnumToString(_Period))
   string tf = IntegerToString(_Period);

   nz.name = (t == ZONE_SUPPORT ? "S_" : "R_") + tf + "_" +
             DoubleToString(p, _Digits) + "_" +
             IntegerToString((long)dt);

   nz.is_user_zone = false;

//--- Assign scoring BEFORE logging
   nz.zone_score         = score;
   nz.Current_zone_score = score;
   nz.zone_tier          = tier;
   nz.initial_volume_ratio = vol_ratio;
   nz.departure_velocity   = velo_pips;

//--- Ensure metrics baseline
   nz.touch_count        = 0;
   nz.bounce_count       = 0;
   nz.failure_count      = 0;
   nz.resurrection_count = 0;
   nz.max_reaction_pips  = 0.0;
   nz.breakout_quality   = "NONE";

//--- CRITICAL: register BEFORE logging
   active_zones.Add(nz);

//--- Ensure bounds are valid BEFORE logging
   if(nz.top <= 0.0 || nz.bottom <= 0.0)
     {
      nz.top    = (t == ZONE_RESISTANCE) ? p : p + atr * 0.5;
      nz.bottom = (t == ZONE_SUPPORT) ? p : p - atr * 0.5;
     }

//--- Context string (unchanged)
   string context_info = StringFormat(
                            "Score:%d|Tier:%s|VolRatio:%.2f|VeloPips:%.1f|Touches:%d|Bounces:%d|Failures:%d|Resurrections:%d|MaxReaction:%.1f|AgeBars:0|Absorbed:NONE|Status:CREATED",
                            nz.zone_score,
                            nz.zone_tier,
                            nz.initial_volume_ratio,
                            nz.departure_velocity,
                            nz.touch_count,
                            nz.bounce_count,
                            nz.failure_count,
                            nz.resurrection_count,
                            nz.max_reaction_pips
                         );

   string explicit_type = (t == ZONE_SUPPORT) ? "SUPPORT" : "RESISTANCE";

   string details = StringFormat(
                       ">>> Quantitative automated %s zone registered successfully.",
                       explicit_type
                    );

//--- FINAL LOG (safe + deterministic)
   logger.LogZone("AUTO",
                  ZE_CREATED,
                  nz.name,
                  "ZONE_" + explicit_type,
                  nz.top,
                  nz.bottom,
                  context_info,
                  details);
  }
//+------------------------------------------------------------------+
//| Evaluates Penetration Bounds, Handles Ghosts, and Resurrections  |
//+------------------------------------------------------------------+
void ResolvePendingInteractions(double atr)
  {
   double last_close  = iClose(_Symbol, _Period, 1);
   double last_high   = iHigh(_Symbol, _Period, 1);
   double last_low    = iLow(_Symbol, _Period, 1);

   double pip_divider = ((_Digits == 3 || _Digits == 5) ? 10.0 : 1.0) * _Point;

   for(int i = active_zones.Total() - 1; i >= 0; i--)
     {
      CZone *z = (CZone*)active_zones.At(i);

      if(z == NULL || z.type == ZONE_NEUTRAL)
         continue;

      int current_age = iBarShift(_Symbol, _Period, z.created);

      //--- LIVE REACTION ENGINE: Tracks maximum dynamic price movement away from zone boundaries
      if(!z.is_broken)
        {
         double current_reaction = 0.0;
         if(z.type == ZONE_SUPPORT && last_high > z.top)
           {
            current_reaction = (last_high - z.top) / pip_divider;
            if(current_reaction > z.max_reaction_pips)
               z.max_reaction_pips = current_reaction;
           }
         else
            if(z.type == ZONE_RESISTANCE && last_low < z.bottom)
              {
               current_reaction = (z.bottom - last_low) / pip_divider;
               if(current_reaction > z.max_reaction_pips)
                  z.max_reaction_pips = current_reaction;
              }
        }

      //--- LAYER 1: GHOST LIFECYCLE MANAGEMENT
      if(z.is_broken)
        {
         int bars_since_break = iBarShift(_Symbol, _Period, z.broken_time);

         if(bars_since_break > GhostBarLimit)
           {
            string dead_name     = z.name;
            string z_source      = z.is_user_zone ? "USER" : "AUTO";
            string z_type        = EnumToString(z.type);
            double z_top         = z.top;
            double z_bottom      = z.bottom;

            string context_info = StringFormat("Score:%d|CurrentScore:%.2f|Birth Tier:%s|VolRatio:%.2f|VeloPips:%.1f|Touches:%d|Bounces:%d|Failures:%d|Resurrections:%d|MaxReaction:%.1f|AgeBars:%d|Absorbed:NONE|Status:%s",
                                               z.zone_score, z.Current_zone_score, z.zone_tier, z.initial_volume_ratio, z.departure_velocity,
                                               z.touch_count, z.bounce_count, z.failure_count, z.resurrection_count, z.max_reaction_pips, current_age,
                                               "EXTINCT");

            string details = ">>> [ZONE EXTINCTION] Aged ghost zone removed from memory: " + dead_name;

            logger.LogZone(z_source, ZE_DELETED, dead_name, z_type, z_top, z_bottom, context_info, details);

            ObjectDelete(0, z.name);
            active_zones.Delete(i);
            continue;
           }

         if(AllowResurrection && last_close > z.bottom && last_close < z.top)
           {
            z.is_broken = false;
            z.status = ZONE_VIRGIN;
            z.consecutive_closes_outside = 0;
            z.buy_triggered = false;
            z.sell_triggered = false;
            z.resurrection_count++;
            z.max_reaction_pips = 0.0; // Reset reaction tracking metrics on structural rebirth

            ObjectSetInteger(0, z.name, OBJPROP_COLOR, z.GetColor());
            ObjectSetInteger(0, z.name, OBJPROP_FILL, true);

            string context_info = StringFormat("Score:%d|CurrentScore:%.2f|Birth Tier:%s|VolRatio:%.2f|VeloPips:%.1f|Touches:%d|Bounces:%d|Failures:%d|Resurrections:%d|MaxReaction:%.1f|AgeBars:%d|Absorbed:NONE|Status:%s",
                                               z.zone_score, z.Current_zone_score, z.zone_tier, z.initial_volume_ratio, z.departure_velocity,
                                               z.touch_count, z.bounce_count, z.failure_count, z.resurrection_count, z.max_reaction_pips, current_age,
                                               "RESURRECTED");

            string details = StringFormat(">>> [ZONE RESURRECTION] Price reclaimed level. Restored: %s at Bar: %d", z.name, bars_since_break);

            logger.LogZone(z.is_user_zone ? "USER" : "AUTO", ZE_RESURRECTED, z.name, EnumToString(z.type), z.top, z.bottom, context_info, details);
           }

         continue;
        }

      // --- LAYER 2: STATE-AWARE INTERACTION RESOLUTION
      if(!z.is_pending)
         continue;


      //--- The interaction lock never expires due to time/stagnation.
      //--- It remains locked until a structural Breakout or a confirmed Bounce occurs.

      //--- BRIDGE ROUTINE DIAGNOSTICS: Intercept pending live zones to extract candlestick signals
      if(CheckTradingSignals && g_strategy != NULL && g_trade != NULL)
        {
         if(g_strategy.EvaluateSingleZoneSignal(g_trade, g_cached_atr, z.name, z.type, z.top, z.bottom,
                                                z.is_broken, z.is_pending, z.Current_zone_score,
                                                z.buy_triggered, z.sell_triggered))
           {
            //--- Signal successfully completed execution routing
           }
        }

      double buffer = MathMax(z.height * BreakBufferPct, atr);
      double bounce_buffer = BounceATRDistance * atr;

      bool is_clear_breakout =
         (z.type == ZONE_SUPPORT && last_close < (z.bottom - buffer)) ||
         (z.type == ZONE_RESISTANCE && last_close > (z.top + buffer));

      bool is_clear_rejection =
         (z.type == ZONE_SUPPORT && last_close >= (z.top + bounce_buffer)) ||
         (z.type == ZONE_RESISTANCE && last_close <= (z.bottom - bounce_buffer));

      //--- Path A: Evaluate Breakout/Failure Momentum
      if(is_clear_breakout)
        {
         z.consecutive_rejection_closes = 0;
         z.consecutive_closes_outside++;

         if(z.consecutive_closes_outside >= BreakConfirmCloses)
           {
            z.is_broken = true;
            z.is_pending = false;
            z.status = ZONE_BROKEN;
            z.failure_count++;
            z.broken_time = TimeCurrent();

            //--- Apply Normalized Structural Penetration Penalty
            z.Current_zone_score = MathMax(0.0, z.Current_zone_score - PenetrationPenalty);

            MqlRates break_rates[];
            if(CopyRates(_Symbol, _Period, 1, 1, break_rates) == 1)
              {
               double sample_vol = 0;
               int sample_size = 14;
               MqlRates vol_samples[];

               if(CopyRates(_Symbol, _Period, 2, sample_size, vol_samples) == sample_size)
                 {
                  for(int v=0; v<sample_size; v++)
                     sample_vol += (double)vol_samples[v].tick_volume;

                  double avg_vol = sample_vol / sample_size;
                  double break_vol = (double)break_rates[0].tick_volume;

                  double break_vol_ratio = (avg_vol > 0) ? (break_vol / avg_vol) : 1.0;
                  double break_range_pips = (MathAbs(break_rates[0].close - break_rates[0].open) / _Point) /
                                            ((_Digits == 3 || _Digits == 5) ? 10.0 : 1.0);

                  if(break_vol_ratio >= 1.8 && break_range_pips >= (atr / _Point) * 0.8)
                     z.breakout_quality = "STRONG";
                  else
                     if(break_vol_ratio >= 1.0)
                        z.breakout_quality = "MODERATE";
                     else
                        z.breakout_quality = "WEAK";
                 }
              }

            ObjectSetInteger(0, z.name, OBJPROP_COLOR, clrWhite);
            ObjectSetInteger(0, z.name, OBJPROP_FILL, false);

            string context_info = StringFormat("Score:%d|CurrentScore:%.2f|Birth Tier:%s|VolRatio:%.2f|VeloPips:%.1f|Touches:%d|Bounces:%d|Failures:%d|Resurrections:%d|MaxReaction:%.1f|AgeBars:%d|Outcome:QUALIFIED_FLIP|BreakForce:%s|Status:%s",
                                               z.zone_score, z.Current_zone_score, z.zone_tier, z.initial_volume_ratio, z.departure_velocity,
                                               z.touch_count, z.bounce_count, z.failure_count, z.resurrection_count,
                                               z.max_reaction_pips, current_age, z.breakout_quality,
                                               "GHOSTED");

            string details = StringFormat(">>> [ZONE GHOSTED] Level breached via %s force momentum. Ghost mode activated for: %s", z.breakout_quality, z.name);

            logger.LogZone(z.is_user_zone ? "USER" : "AUTO", ZE_GHOSTED, z.name, EnumToString(z.type), z.top, z.bottom, context_info, details);
           }
        }

      //--- Path B: Evaluate Rejection/Bounce Confirmation
      else
         if(is_clear_rejection)
           {
            z.consecutive_closes_outside = 0;
            z.consecutive_rejection_closes++;

            if(z.consecutive_rejection_closes >= BounceConfirmCloses)
              {
               z.is_pending = false;
               z.bounce_count++;

               //--- Apply Normalized Confirmed Bounce Reward Bonus
               z.Current_zone_score = MathMin(100.0, z.Current_zone_score + TouchScoreBonus);

               string context_info = StringFormat("Score:%d|CurrentScore:%.2f|Birth Tier:%s|VolRatio:%.2f|VeloPips:%.1f|Touches:%d|Bounces:%d|Failures:%d|Resurrections:%d|MaxReaction:%.1f|AgeBars:%d|Outcome:BOUNCE_CONFIRMED|BreakForce:NONE|Status:%s",
                                                  z.zone_score, z.Current_zone_score, z.zone_tier, z.initial_volume_ratio, z.departure_velocity,
                                                  z.touch_count, z.bounce_count, z.failure_count, z.resurrection_count,
                                                  z.max_reaction_pips, current_age,
                                                  EnumToString(z.status));

               string details = StringFormat(">>> [BOUNCE CONFIRMED] Price rejected level cleanly. Restored: %s | Total Bounces: %d", z.name, z.bounce_count);

               logger.LogZone(z.is_user_zone ? "USER" : "AUTO", ZE_UPDATED, z.name, EnumToString(z.type), z.top, z.bottom, context_info, details);
              }
           }
         else
           {
            // Price churning limits inside buffers; maintain interaction window hooks indefinitely
           }
     }
  }
//+------------------------------------------------------------------+
//| Generates Graphic Objects and Projects Visual Boundaries Forward |
//+------------------------------------------------------------------+
void UpdateZoneVisuals(bool force_time_extension)
  {
   int total_zones = active_zones.Total();
   if(total_zones == 0)
      return;

   for(int i = 0; i < total_zones; i++)
     {
      CZone *z = (CZone*)active_zones.At(i);
      if(z == NULL)
         continue;

      //--- State Validation: Bypass expensive ObjectFind lookup loops entirely
      if(!z.was_drawn)
        {
         if(!ObjectCreate(0, z.name, OBJ_RECTANGLE, 0, z.created, z.top, TimeCurrent(), z.bottom))
            continue;

         ObjectSetInteger(0, z.name, OBJPROP_BACK, true);
         ObjectSetInteger(0, z.name, OBJPROP_RAY_RIGHT, true); // Enforce native raycasting projection
         ObjectSetInteger(0, z.name, OBJPROP_SELECTABLE, true);
         ObjectSetString(0, z.name, OBJPROP_TEXT, z.is_user_zone ? "USER" : "AUTO");

         //--- Lock inside local object memory space
         z.was_drawn = true;
        }

      //--- Only synchronize geometric bounds when explicitly forced (New Bar / Conversions)
      if(force_time_extension)
        {
         //--- MODIFIED: Isolate horizontal time coordinates to prevent user zones from shrinking
         if(!z.is_user_zone)
           {
            ObjectSetInteger(0, z.name, OBJPROP_TIME, 1, TimeCurrent()); // Move edge to live bar
            ObjectSetInteger(0, z.name, OBJPROP_TIME, 0, z.created);    // Keep anchored to origin
           }

         ObjectSetDouble(0, z.name, OBJPROP_PRICE, 0, z.top);
         ObjectSetDouble(0, z.name, OBJPROP_PRICE, 1, z.bottom);
        }

      //--- Continuous state synchronization (handles colors and fill transformations flawlessly)
      ObjectSetInteger(0, z.name, OBJPROP_COLOR, z.GetColor());
      ObjectSetInteger(0, z.name, OBJPROP_FILL, z.is_broken ? false : true);
     }
  }
//+------------------------------------------------------------------+
//| Quantitative Analyzer: Computes Structural Validity Score (0-100)|
//+------------------------------------------------------------------+
int AnalyzeZoneCandidate(int pivot_idx, ENUM_ZONE_TYPE type, double p, double atr, double &vol_ratio, double &velocity_pips, string &tier)
  {
   MqlRates rates[];
   ArraySetAsSeries(rates, true);

//--- Dynamically size the lookback allocation based on actual input settings
   int macro_window = SwingBars * 2;
   int sample_period = 14;

//--- Max historical offset needed is the pivot index + whichever requirement is larger
   int max_historical_offset = (macro_window > sample_period) ? macro_window : sample_period;
   int check_bars = pivot_idx + max_historical_offset + VelocityLookaheadBars + 5; // dynamic padding margin

   if(CopyRates(_Symbol, _Period, 0, check_bars, rates) < check_bars)
     {
      vol_ratio = 1.0;
      velocity_pips = 0.0;
      tier = "LOW";
      return 0;
     }

//--- 1. HIGH VOLUME RATIO EVALUATION (Strict Zero Floor Floor)
   int vol_score = 0;
   vol_ratio = 1.0;

   if(EnableVolumeValidation && (pivot_idx + sample_period) < check_bars)
     {
      double total_vol = 0;

      for(int v = 1; v <= sample_period; v++)
        {
         total_vol += (double)rates[pivot_idx + v].tick_volume;
        }

      double avg_vol = total_vol / sample_period;
      double pivot_vol = (double)rates[pivot_idx].tick_volume;

      if(avg_vol > 0)
         vol_ratio = pivot_vol / avg_vol;

      //--- Strict floor applied: No pity points below or equal to 0.5 ratio
      if(vol_ratio >= 2.0)
         vol_score = VolumeWeight;
      else
         if(vol_ratio <= 0.5)
            vol_score = 0;
         else
           {
            //--- Linear interpolation mapped to maximum user-defined weight allocation
            vol_score = (int)(((vol_ratio - 0.5) / 1.5) * VolumeWeight);
           }
     }
   else
     {
      vol_score = VolumeWeight / 2; // Midpoint baseline assignment if volume processing is disabled
     }

//--- 2. ESCAPE VELOCITY EVALUATION (Dynamic Lookahead Optimization Window)
   int velocity_score = 0;
   velocity_pips = 0.0;

   if(pivot_idx >= 1)
     {
      double price_departure = 0.0;
      //--- Secure lookahead pointer: check real-time edge proximity to prevent frozen past readings
      int forward_target_idx = (pivot_idx >= VelocityLookaheadBars) ? (pivot_idx - VelocityLookaheadBars) : 1;

      if(type == ZONE_RESISTANCE)
         price_departure = p - rates[forward_target_idx].close;
      else
         price_departure = rates[forward_target_idx].close - p;

      double pip_multiplier = (_Digits == 3 || _Digits == 5) ? 10.0 : 1.0;
      velocity_pips = (price_departure / _Point) / pip_multiplier;

      double displacement_ratio = (atr > 0) ? (price_departure / atr) : 1.0;

      if(displacement_ratio >= 2.5)
         velocity_score = VelocityWeight;
      else
         if(displacement_ratio <= 0.5)
            velocity_score = 0;
         else
           {
            //--- Linear interpolation mapped to maximum user-defined weight allocation
            velocity_score = (int)(((displacement_ratio - 0.5) / 2.0) * VelocityWeight);
           }
     }

//--- 3. SAFE GEOMETRIC SYMMETRIC EXTENSION CHECK
   int symmetry_score = StructureWeight / 2; // Midpoint default if symmetry fails micro filters
   bool extra_high = true;
   bool extra_low = true;

   for(int m = 1; m <= macro_window; m++)
     {
      int lookforward_idx = pivot_idx - m;
      int lookbackward_idx = pivot_idx + m;

      if(lookforward_idx >= 0 && lookbackward_idx < check_bars)
        {
         if(rates[pivot_idx].high <= rates[lookforward_idx].high || rates[pivot_idx].high <= rates[lookbackward_idx].high)
            extra_high = false;

         if(rates[pivot_idx].low >= rates[lookforward_idx].low || rates[pivot_idx].low >= rates[lookbackward_idx].low)
            extra_low = false;
        }
      else
        {
         extra_high = false;
         extra_low = false;
         break;
        }
     }

   if((type == ZONE_RESISTANCE && extra_high) || (type == ZONE_SUPPORT && extra_low))
     {
      symmetry_score = StructureWeight;
     }

//--- COMBINE ACCUMULATED SCORE METRICS MATRIX (Normalize to Max 100 Cap)
   int total_calculated_score = vol_score + velocity_score + symmetry_score;
   if(total_calculated_score > 100)
      total_calculated_score = 100;
   if(total_calculated_score < 0)
      total_calculated_score = 0;

//--- ASSIGN OBJECTIVE NOMENCLATURE STRINGS WITH ELITE CLASS UPGRADE
   if(total_calculated_score >= 95)
      tier = "ELITE";
   else
      if(total_calculated_score >= 80)
         tier = "HIGH";
      else
         if(total_calculated_score >= 50)
            tier = "MODERATE";
         else
            tier = "LOW";

   return total_calculated_score;
  }
//+------------------------------------------------------------------+
