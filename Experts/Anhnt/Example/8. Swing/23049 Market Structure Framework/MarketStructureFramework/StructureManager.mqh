//+------------------------------------------------------------------+
//|                                StructureManager.mqh              |
//|                                Copyright 2026, MetaQuotes        |
//|                                https://www.mql5.com              |
//+------------------------------------------------------------------+
#property copyright "Copyright 2026, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
#property strict
#include "MarketStructureTypes.mqh"
#include "EventBus.mqh"
#include "SwingDetector.mqh"
#include "LevelTracker.mqh"
#include "BreakDetector.mqh"
#include "StructureClassifier.mqh"

//+------------------------------------------------------------------+
//| Orchestrate swing detection, break detection and event emission  |
//+------------------------------------------------------------------+
class CStructureManager
  {
   private:
    ENUM_STRUCTURE_LEVEL m_level;                                                                                     // which structure level this manager handles (internal or external)
    CEventBus           *m_eventBus;                                                                                  // pointer to the central event bus for publishing events
    CEventCache          m_eventCache;                                                                                // local deduplication cache (ring buffer) for events emitted by this manager
    CEventIdCounter     *m_pEventIdCounter;                                                                           // shared counter for generating unique event IDs
    CSwingDetector      *m_detector;                                                                                  // pointer to the swing detector (owned externally, same level as this manager)

    CLevelTracker        m_levelTracker;                                                                              // maintains protected levels and trend for this structure
    CBreakDetector       m_breakDetector;                                                                             // stateless checker for level breaks
    CStructureClassifier m_classifier;                                                                                // stateless classifier that converts breaks to BOS/CHoCH event types

    int                  m_lastRatesTotal;                                                                            // total number of bars seen in the previous call (used to detect full rebuilds)
    datetime             m_lastProcessedBarTime;                                                                      // timestamp of the most recent bar already processed (prevents reprocessing)

    SStructureEvent      m_cachedLastBOS;                                                                             // most recent BOS event (for fast access by consumers)
    SStructureEvent      m_cachedLastCHoCH;                                                                           // most recent CHoCH event (for fast access by consumers)
    bool                 m_hasCachedBOS;                                                                              // indicates that m_cachedLastBOS holds a valid event
    bool                 m_hasCachedCHoCH;                                                                            // indicates that m_cachedLastCHoCH holds a valid event

    void                EmitEvent(ENUM_EVENT_TYPE type, datetime time, double price,
                                 int direction, double confidence);                                                  // creates and publishes a deduplicated event

   public:
                     CStructureManager();
    void                Init(ENUM_STRUCTURE_LEVEL level, CEventBus *bus,
                            CEventIdCounter *idCounter, CSwingDetector *detector);                                   // initialise with dependencies
    void                ProcessBars(const datetime &time[], const double &high[],
                                   const double &low[], const double &close[],
                                   int rates_total, double atr);                                                     // main update: detect swings, breaks, emit events
    int                 GetTrend() const { return m_levelTracker.GetTrend(); }                                        // current trend direction
    bool                GetProtectedHigh(SProtectedLevel &out) const { return m_levelTracker.GetProtectedHigh(out); } // copy out the active protected high
    bool                GetProtectedLow(SProtectedLevel &out) const { return m_levelTracker.GetProtectedLow(out); }   // copy out the active protected low
    bool                GetLastBOS(SStructureEvent &out);                                                             // retrieve the most recent BOS event
    bool                GetLastCHoCH(SStructureEvent &out);                                                           // retrieve the most recent CHoCH event
  };

//+------------------------------------------------------------------+
//| Initialize all pointers and state variables to default values    |
//+------------------------------------------------------------------+
CStructureManager::CStructureManager()
  {
   m_level = LEVEL_INTERNAL;
   m_eventBus = NULL;
   m_pEventIdCounter = NULL;
   m_detector = NULL;
   m_hasCachedBOS = false;
   m_hasCachedCHoCH = false;
   m_lastRatesTotal = 0;
   m_lastProcessedBarTime = 0;
  }

//+------------------------------------------------------------------+
//| Initialize Structure Manager with dependencies and reset state   |
//+------------------------------------------------------------------+
void CStructureManager::Init(ENUM_STRUCTURE_LEVEL level, CEventBus *bus,
                             CEventIdCounter *idCounter, CSwingDetector *detector)
  {
   m_level = level;                                                                 // internal or external
   m_eventBus = bus;                                                                // central event bus
   m_pEventIdCounter = idCounter;                                                   // shared ID counter
   m_detector = detector;                                                           // corresponding swing detector
   m_levelTracker.Init();                                                           // reset the level tracker
   m_hasCachedBOS = false;
   m_hasCachedCHoCH = false;
   m_eventCache.Clear();                                                            // start with an empty dedup cache
   m_lastRatesTotal = 0;
   m_lastProcessedBarTime = 0;
   if(m_detector)
      m_detector.Clear();                                                           // also reset the swing detector
  }

//+------------------------------------------------------------------+
//| Emit a structure event after deduplication and update caches     |
//+------------------------------------------------------------------+
void CStructureManager::EmitEvent(ENUM_EVENT_TYPE type, datetime time, double price,
                                  int direction, double confidence)
  {
   //--- build a signature for deduplication
   EventSignature sig;
   sig.type = type;
   sig.time = time;
   sig.price = price;
   sig.level = m_level;
   if(m_eventCache.Contains(sig))                                                    // duplicate? then skip
      return;
   m_eventCache.Add(sig);                                                            // store signature to prevent re-emission

   //--- construct the actual event
   SStructureEvent ev;
   ev.eventId = (m_pEventIdCounter != NULL) ? m_pEventIdCounter.Next() : 0;          // assign a unique ID
   ev.type = type;
   ev.time = time;
   ev.price = price;
   ev.level = m_level;
   ev.direction = direction;
   ev.state = STATE_UNKNOWN;                                                         // state will be set by the state machine later
   ev.confidence = confidence;
   if(m_eventBus)
      m_eventBus.Publish(ev);                                                        // push to the central bus

   //--- keep a quick reference for the latest BOS/CHoCH
   if(type == EVENT_INTERNAL_BOS_BULLISH || type == EVENT_INTERNAL_BOS_BEARISH ||
      type == EVENT_EXTERNAL_BOS_BULLISH || type == EVENT_EXTERNAL_BOS_BEARISH)
     { m_cachedLastBOS = ev; m_hasCachedBOS = true; }
   else
      if(type == EVENT_INTERNAL_CHOCH_BULLISH || type == EVENT_INTERNAL_CHOCH_BEARISH ||
         type == EVENT_EXTERNAL_CHOCH_BULLISH || type == EVENT_EXTERNAL_CHOCH_BEARISH)
        { m_cachedLastCHoCH = ev; m_hasCachedCHoCH = true; }
  }

//+------------------------------------------------------------------+
//| Process new bars – detect swings, check breaks, emit events      |
//+------------------------------------------------------------------+
void CStructureManager::ProcessBars(const datetime &time[], const double &high[],
                                    const double &low[], const double &close[],
                                    int rates_total, double atr)
  {
   if(!m_detector)
      return;
   int strength = m_detector.GetStrength();                                           // number of bars required on each side for a swing

   //--- detect a full rebuild (first run or history changed significantly)
   bool fullRebuild = (m_lastRatesTotal == 0 || rates_total > m_lastRatesTotal + 1);

   if(fullRebuild)
     {
      m_detector.Clear();                                                             // reset swing arrays
      m_levelTracker.Init();                                                          // reset protected levels and trend
      m_eventCache.Clear();                                                           // clear dedup cache to allow fresh event emission
      m_lastProcessedBarTime = 0;                                                     // reprocess all bars
     }
   m_lastRatesTotal = rates_total;

   m_levelTracker.SetATR(atr);                                                        // supply the current ATR for trend slope threshold

   //--- iterate from the oldest unprocessed bar to the newest
   for(int i = rates_total - 1; i >= 1; i--)
     {
      if(time[i] <= m_lastProcessedBarTime)
         continue;                                                                    // already processed this bar

      //--- swing detection (needs enough bars to the left and right)
      if(i >= strength && i <= rates_total - 1 - strength)
        {
         if(m_detector.IsSwingHigh(i, high))
           {
            m_detector.AddSwingHigh(time[i], high[i]);                                // store the new swing high
            SSwingPoint sw;
            sw.time = time[i];
            sw.price = high[i];
            sw.isHigh = true;
            sw.confidence = m_detector.CalcSwingConfidence(sw, atr);                  // compute quality score
            EmitEvent(EVENT_SWING_HIGH_CREATED, sw.time, sw.price, 1, sw.confidence);
            m_levelTracker.ProcessSwingHigh(sw);                                      // update trend and protected levels
           }
         if(m_detector.IsSwingLow(i, low))
           {
            m_detector.AddSwingLow(time[i], low[i]);
            SSwingPoint sw;
            sw.time = time[i];
            sw.price = low[i];
            sw.isHigh = false;
            sw.confidence = m_detector.CalcSwingConfidence(sw, atr);
            EmitEvent(EVENT_SWING_LOW_CREATED, sw.time, sw.price, -1, sw.confidence);
            m_levelTracker.ProcessSwingLow(sw);
           }
        }

      //--- break detection using current protected levels
      SProtectedLevel protHigh, protLow;
      bool hasHigh = m_levelTracker.GetProtectedHigh(protHigh);
      bool hasLow  = m_levelTracker.GetProtectedLow(protLow);
      if(hasHigh || hasLow)
        {
         SBreakEvent breakEv;
         if(m_breakDetector.CheckBar(time[i], high[i], low[i], close[i],
                                     protHigh, protLow, atr, breakEv))
           {
            //--- classify the break
            ENUM_EVENT_TYPE eventType = m_classifier.Classify(breakEv, m_levelTracker.GetTrend(), m_level);
            int dir = (eventType == EVENT_INTERNAL_BOS_BULLISH || eventType == EVENT_EXTERNAL_BOS_BULLISH ||
                       eventType == EVENT_INTERNAL_CHOCH_BULLISH || eventType == EVENT_EXTERNAL_CHOCH_BULLISH) ? 1 : -1;

            //--- dynamic confidence based on break distance and close
            double breakConf = 50.0 + MathMin(50.0, breakEv.distanceATR * 20.0);
            if(breakEv.isCloseBeyond)
               breakConf += 15.0;
            breakConf = MathMin(100.0, breakConf);

            EmitEvent(eventType, breakEv.time, breakEv.price, dir, breakConf);

            //--- invalidate the broken level so it won't re-trigger
            if(breakEv.isHighBreak)
               m_levelTracker.InvalidateHigh();
            else
               m_levelTracker.InvalidateLow();
           }
        }

      //--- advance the last processed time
      if(time[i] > m_lastProcessedBarTime)
         m_lastProcessedBarTime = time[i];
     }
  }

//+------------------------------------------------------------------+
//| Retrieve the most recent Break of Structure event from the cache |
//+------------------------------------------------------------------+
bool CStructureManager::GetLastBOS(SStructureEvent &out)
  {
   if(m_hasCachedBOS)
     {
      out = m_cachedLastBOS;
      return true;
     }
   return false;
  }

//+------------------------------------------------------------------+
//| Retrieve the most recent Change of Character event from the cache|
//+------------------------------------------------------------------+
bool CStructureManager::GetLastCHoCH(SStructureEvent &out)
  {
   if(m_hasCachedCHoCH)
     {
      out = m_cachedLastCHoCH;
      return true;
     }
   return false;
  }
//+------------------------------------------------------------------+