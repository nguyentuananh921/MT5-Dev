//+------------------------------------------------------------------+
//|                                         TrendlineManager.mqh     |
//|                                  Copyright 2026, Francis Nyoike. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2026, Francis Nyoike."
#property link      "https://www.mql5.com"
#include <Arrays/ArrayObj.mqh>
#include "Common.mqh"
#include "ManagedTrendline.mqh"

//+------------------------------------------------------------------+
//| Orchestration engine for discovering and managing trendlines.    |
//| Manages object lifecycle using a safe CArrayObj collection.      |
//+------------------------------------------------------------------+
class CTrendlineManager
  {
private:
   long              m_chart_id;            // Target chart context
   string            m_prefix;              // Prefix filter for manual objects
   CArrayObj         m_lines;               // Managed trendline collection array
   datetime          m_last_processed_bar;  // Timestamp of last processed closed bar

   //--- Configurable Threshold Settings
   double            m_proximity_pts;       // Touch Proximity Threshold (Points)
   double            m_break_atr_mult;      // Break ATR Multiplier
   int               m_break_confirm_closes;// Consecutive Closes for Break
   double            m_bounce_atr_mult;     // Bounce ATR Multiplier
   int               m_bounce_confirm_closes;// Consecutive Closes for Bounce

private:
   //--- Internal Collection Helpers
   int               FindIndexByName(const string name);
   bool              IsManaged(const string name);

public:
                     CTrendlineManager(const string prefix = DEFAULT_TRENDLINE_PREFIX,
                     double proximity_pts = DEFAULT_TOUCH_PROXIMITY_PTS,
                     double break_atr_mult = 1.0,
                     int break_confirm_closes = 2,
                     double bounce_atr_mult = 1.0,
                     int bounce_confirm_closes = 2,
                     long chart_id = 0);
                    ~CTrendlineManager();

   //--- Lifecycle & Event Methods
   bool              Init();
   void              Update(const double &open[], const double &high[], const double &low[], const double &close[], const datetime &time[], const double atr);
   void              HandleChartEvent(const int id, const long &lparam, const double &dparam, const string &sparam);

   //--- Discovery & Registration
   int               DiscoverTrendlines();
   bool              RegisterTrendline(const string name);
   bool              UnregisterTrendline(const string name);

   //--- Collection Accessors
   int               GetTotalManaged() const { return m_lines.Total(); }
   CManagedTrendline* GetLine(const int index);
  };
//+------------------------------------------------------------------+
//| Constructor                                                      |
//+------------------------------------------------------------------+
CTrendlineManager::CTrendlineManager(const string prefix,
                                     double proximity_pts,
                                     double break_atr_mult,
                                     int break_confirm_closes,
                                     double bounce_atr_mult,
                                     int bounce_confirm_closes,
                                     long chart_id)
   : m_prefix(prefix),
     m_proximity_pts(proximity_pts),
     m_break_atr_mult(break_atr_mult),
     m_break_confirm_closes(break_confirm_closes),
     m_bounce_atr_mult(bounce_atr_mult),
     m_bounce_confirm_closes(bounce_confirm_closes),
     m_chart_id(chart_id),
     m_last_processed_bar(0)
  {
//--- Enable automatic memory management for CArrayObj elements
   m_lines.FreeMode(true);
  }

//+------------------------------------------------------------------+
//| Destructor                                                       |
//+------------------------------------------------------------------+
CTrendlineManager::~CTrendlineManager()
  {
   PrintFormat("[SmartTrendline] Manager shutting down. Clearing %d managed lines.", m_lines.Total());
   m_lines.Clear();
  }

//+------------------------------------------------------------------+
//| Manager Initialization                                           |
//+------------------------------------------------------------------+
bool CTrendlineManager::Init()
  {
   PrintFormat("[SmartTrendline] Manager initialized with prefix filter: '%s'", m_prefix);
   DiscoverTrendlines();
   return true;
  }

//+------------------------------------------------------------------+
//| Searches collection for managed line by name. Returns index.     |
//+------------------------------------------------------------------+
int CTrendlineManager::FindIndexByName(const string name)
  {
   int total = m_lines.Total();
   for(int i = 0; i < total; i++)
     {
      CManagedTrendline *line = (CManagedTrendline*)m_lines.At(i);
      if(line != NULL && line.GetName() == name)
         return i;
     }
   return -1;
  }

//+------------------------------------------------------------------+
//| Checks if an object name is already managed in collection.       |
//+------------------------------------------------------------------+
bool CTrendlineManager::IsManaged(const string name)
  {
   return (FindIndexByName(name) >= 0);
  }

//+------------------------------------------------------------------+
//| Scans chart for objects matching prefix and registers them.      |
//+------------------------------------------------------------------+
int CTrendlineManager::DiscoverTrendlines()
  {
   int registered_count = 0;
   int total_objects = ObjectsTotal(m_chart_id, -1, OBJ_TREND);

   for(int i = total_objects - 1; i >= 0; i--)
     {
      string name = ObjectName(m_chart_id, i, -1, OBJ_TREND);

      // Check prefix filter match
      if(StringFind(name, m_prefix) == 0)
        {
         if(!IsManaged(name))
           {
            if(RegisterTrendline(name))
               registered_count++;
           }
        }
     }

   if(registered_count > 0)
     {
      PrintFormat("[SmartTrendline] Discovery complete: %d new trendlines registered.", registered_count);
     }

   return registered_count;
  }

//+------------------------------------------------------------------+
//| Registers a new trendline object into the collection.            |
//+------------------------------------------------------------------+
bool CTrendlineManager::RegisterTrendline(const string name)
  {
   if(IsManaged(name))
      return false;

   CManagedTrendline *new_line = new CManagedTrendline(name, m_chart_id, m_proximity_pts, m_break_atr_mult, m_break_confirm_closes, m_bounce_atr_mult, m_bounce_confirm_closes);
   if(new_line == NULL)
      return false;

   if(m_lines.Add(new_line))
     {
      //--- Overwrite visual properties directly on user object
      ObjectSetInteger(m_chart_id, name, OBJPROP_RAY_RIGHT, true);
      ObjectSetInteger(m_chart_id, name, OBJPROP_BACK, true);
      ObjectSetInteger(m_chart_id, name, OBJPROP_WIDTH, TrendlineDefaults::DefaultWidth);
      ObjectSetInteger(m_chart_id, name, OBJPROP_COLOR, TrendlineDefaults::ActiveColor);

      PrintFormat("//--- [SmartTrendline] Registered user trendline: '%s'", name);
      return true;
     }

   delete new_line;
   return false;
  }

//+------------------------------------------------------------------+
//| Removes a trendline from the collection and frees its memory.    |
//+------------------------------------------------------------------+
bool CTrendlineManager::UnregisterTrendline(const string name)
  {
   int index = FindIndexByName(name);
   if(index < 0)
      return false;

//--- m_lines has FreeMode(true), so Delete(index) calls destructor & frees heap memory
   if(m_lines.Delete(index))
     {
      PrintFormat("//--- [SmartTrendline] Memory cleared for object tracking array handle: %s", name);
      return true;
     }

   return false;
  }

//+------------------------------------------------------------------+
//| Safe getter for managed objects by index.                        |
//+------------------------------------------------------------------+
CManagedTrendline* CTrendlineManager::GetLine(const int index)
  {
   if(index < 0 || index >= m_lines.Total())
      return NULL;

   return (CManagedTrendline*)m_lines.At(index);
  }

//+------------------------------------------------------------------+
//| Orchestrates lifecycle updates across all managed trendlines.    |
//+------------------------------------------------------------------+
void CTrendlineManager::Update(const double &open[], const double &high[], const double &low[], const double &close[], const datetime &time[], const double atr)
  {
   if(ArraySize(time) < 3)
      return;

//--- Enforce time series indexing (Index 0 = current live bar, Index 1 = last closed bar)
   ArraySetAsSeries(open, true);
   ArraySetAsSeries(high, true);
   ArraySetAsSeries(low, true);
   ArraySetAsSeries(close, true);
   ArraySetAsSeries(time, true);

//--- 1. Live Drag Branch: Process immediate touch evaluation if user moved lines
   bool has_moved_lines = false;
   int total = m_lines.Total();

   for(int i = 0; i < total; i++)
     {
      CManagedTrendline *line = (CManagedTrendline*)m_lines.At(i);
      if(line != NULL && line.WasRecentlyMoved())
        {
         has_moved_lines = true;
         line.EvaluateLiveDrag();
        }
     }

//--- 2. Closed-Bar Gate: Skip closed-bar evaluation unless a new bar has completed
//--- Bar 1 is now guaranteed to be the most recent completed/closed candle
   bool is_new_bar = (time[1] != m_last_processed_bar);
   if(!is_new_bar && !has_moved_lines)
      return;

   if(is_new_bar)
     {
      m_last_processed_bar = time[1];

      //--- Standard closed-bar state machine processing
      for(int i = 0; i < total; i++)
        {
         CManagedTrendline *line = (CManagedTrendline*)m_lines.At(i);
         if(line != NULL)
           {
            // --- DIAGNOSTIC PRINT ---
            double debug_expected = line.GetPriceAtBarIndex(1, time);
            PrintFormat("//--- [DEBUG] Line: %s | Bar Time[1]: %s | Close[1]: %.5f | ExpectedLinePrice: %.5f | Diff: %.5f",
                        line.GetName(), TimeToString(time[1]), close[1], debug_expected, (close[1] - debug_expected));

            line.Update(open, high, low, close, time, atr);
           }
        }
     }
  }
//+------------------------------------------------------------------+
//|Handles MT5 chart events and dispatches object lifecycle actions. |
//+------------------------------------------------------------------+
void CTrendlineManager::HandleChartEvent(const int id, const long &lparam, const double &dparam, const string &sparam)
  {
//--- 1. Creation Event: Intercept any user-drawn trendline instantly
   if(id == CHARTEVENT_OBJECT_CREATE)
     {
      if(ObjectGetInteger(m_chart_id, sparam, OBJPROP_TYPE) == OBJ_TREND)
        {
         // Skip system-generated lines
         if(StringSubstr(sparam, 0, 3) == "SYS")
            return;

         RegisterTrendline(sparam);
        }
     }

//--- 2. Drag / End Edit / Interaction Events: Catch modifications & missed registrations
   else
      if(id == CHARTEVENT_OBJECT_DRAG || id == CHARTEVENT_OBJECT_ENDEDIT || id == CHARTEVENT_OBJECT_CHANGE)
        {
         int index = FindIndexByName(sparam);
         if(index >= 0)
           {
            CManagedTrendline *line = (CManagedTrendline*)m_lines.At(index);
            if(line != NULL)
              {
               line.RefreshProperties();
               PrintFormat("//--- [SmartTrendline] Line modified by user: %s", sparam);
              }
           }
         else
           {
            //--- Replicate creation check on edit if missed during rapid drawing
            if(ObjectGetInteger(m_chart_id, sparam, OBJPROP_TYPE) == OBJ_TREND)
              {
               if(StringSubstr(sparam, 0, 3) != "SYS")
                  RegisterTrendline(sparam);
              }
           }
         ChartRedraw(m_chart_id);
        }

      //--- 3. Deletion Event: Replicates RemoveZoneByName memory lookup
      else
         if(id == CHARTEVENT_OBJECT_DELETE)
           {
            //--- Fast internal memory lookup via sparam string match
            if(IsManaged(sparam))
              {
               UnregisterTrendline(sparam);
               ChartRedraw(m_chart_id);
              }
           }
  }
//+------------------------------------------------------------------+


