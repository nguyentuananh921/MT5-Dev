//+------------------------------------------------------------------+
//|                               MarketStructureFramework.mqh       |
//|                               Copyright 2026, MetaQuotes         |
//|                               https://www.mql5.com               |
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
#include "StructureManager.mqh"
#include "StateMachine.mqh"
#include "Persistence.mqh"

//+------------------------------------------------------------------+
//| Main framework class – aggregates all components, manages MTF    |
//| synchronization, and exposes the public query API                |
//+------------------------------------------------------------------+
class CMarketStructureFramework
  {
private:
   CSwingDetector        m_internalSwingDetector;                                                            // swing detection on the current timeframe
   CSwingDetector        m_externalSwingDetector;                                                            // swing detection on the higher timeframe
   CStructureManager     m_internalStructure;                                                                // internal structure analysis pipeline
   CStructureManager     m_externalStructure;                                                                // external structure analysis pipeline
   CMarketStateMachine   m_stateMachine;                                                                     // market state machine (consumes break events)
   CEventBus             m_eventBus;                                                                         // central event bus for all events
   CPersistence          m_persistence;                                                                      // CSV logging subsystem
   CEventIdCounter       m_eventIdCounter;                                                                   // monotonic event ID generator

   ENUM_TIMEFRAMES       m_externalTF;                                                                       // higher timeframe for external structure
   datetime              m_externalLastBarTime;                                                              // last bar time processed for the external TF
   double                m_externalHighBuffer[];                                                             // array of external TF high prices (series)
   double                m_externalLowBuffer[];                                                              // array of external TF low prices (series)
   double                m_externalCloseBuffer[];                                                            // array of external TF close prices (series)
   datetime              m_externalTimeBuffer[];                                                             // array of external TF bar times (series)
   int                   m_externalBarCount;                                                                 // number of bars currently stored in external buffers
   int                   m_extWindowSize;                                                                    // size of the external history window (bars)

   int                   m_atrHandle;                                                                        // handle for internal TF ATR indicator
   int                   m_atrHandleExt;                                                                     // handle for external TF ATR indicator
   double                m_atrValue;                                                                         // current ATR value for the internal TF
   double                m_atrValueExt;                                                                      // current ATR value for the external TF

   int                   m_internalStrength;                                                                 // swing detection strength for internal TF
   int                   m_externalStrength;                                                                 // swing detection strength for external TF
   int                   m_maxSwingHistory;                                                                  // maximum bars to scan for swing detection
   bool                  m_persistenceEnabled;                                                               // true if CSV logging is active
   int                   m_flushInterval;                                                                    // number of writes between forced file flushes
   ENUM_STRUCTURE_LEVEL  m_stateMachineSource;                                                               // which structure drives the market state machine

   datetime              m_lastPersistedEventTime;                                                           // time of the newest event already written to CSV
   datetime              m_lastStateEventTime;                                                               // time of the newest break event processed by the state machine

   ENUM_FRAMEWORK_STATUS m_status;                                                                           // current operational status of the framework
   bool                  m_extDataWaitingLogged;                                                             // flag to log "waiting for external data" only once
   bool                  m_atrDataWaitingLogged;                                                             // flag to log "waiting for ATR" only once

   void                UpdateExternalData();                                                                 // fetches new external TF bars if a new bar has appeared

public:
                     CMarketStructureFramework();
   bool                Init(int internalStrength, int externalStrength,
                            ENUM_TIMEFRAMES externalTF, bool persistenceEnabled,
                            string symbol, ENUM_TIMEFRAMES currentTF,
                            int extWindowSize, int maxSwingHistory,
                            ENUM_STRUCTURE_LEVEL stateSource,
                            int flushInterval=10);
   void                OnCalculate(const datetime &time[],
                                   const double &high[],
                                   const double &low[],
                                   const double &close[],
                                   int rates_total);
   void                OnDeinit();

   ENUM_MARKET_STATE   GetCurrentState();                                                                    // current market state
   int                 GetCurrentBias();                                                                     // 1=bullish, -1=bearish, 0=neutral/unknown
   bool                GetLastBOS(SStructureEvent &out, ENUM_STRUCTURE_LEVEL level=LEVEL_EXTERNAL);
   bool                GetLastCHoCH(SStructureEvent &out, ENUM_STRUCTURE_LEVEL level=LEVEL_EXTERNAL);
   int                 GetSwingCount(bool isHigh, ENUM_STRUCTURE_LEVEL level);
   bool                GetSwingPoint(bool isHigh, ENUM_STRUCTURE_LEVEL level, int index, SSwingPoint &out);
   int                 GetRecentEventsCount();                                                               // total events in the bus
   bool                GetRecentEvent(int index, SStructureEvent &out);                                      // retrieve event by index (0 = newest)

   long                GetLastEventId() const { return m_eventIdCounter.Current(); }
   bool                HasNewEvents(long &lastSeenId, long &fromId, long &toId);
   bool                GetEventById(long eventId, SStructureEvent &out);
   bool                GetCurrentStructureSnapshot(SStructureSnapshot &snap);
   bool                GetProtectedLevels(double &high, double &low);
   ENUM_FRAMEWORK_STATUS GetStatus() const { return m_status; }
  };

//+------------------------------------------------------------------+
//| Initialize all framework members to safe starting values         |
//+------------------------------------------------------------------+
CMarketStructureFramework::CMarketStructureFramework()
  {
   m_externalTF=PERIOD_H4;
   m_externalLastBarTime=0;
   m_externalBarCount=0;
   m_extWindowSize=500;
   m_atrHandle=INVALID_HANDLE;
   m_atrHandleExt=INVALID_HANDLE;
   m_atrValue=0;
   m_atrValueExt=0;
   m_internalStrength=5;
   m_externalStrength=5;
   m_maxSwingHistory=1000;
   m_persistenceEnabled=false;
   m_flushInterval=10;
   m_stateMachineSource=LEVEL_EXTERNAL;
   m_lastPersistedEventTime=0;
   m_lastStateEventTime=0;
   m_status=FS_OK;
   m_extDataWaitingLogged=false;
   m_atrDataWaitingLogged=false;
  }

//+------------------------------------------------------------------+
//| Initialize the framework: validate parameters, create ATR        |
//| handles, initialize all components, and allocate external buffers|
//+------------------------------------------------------------------+
bool CMarketStructureFramework::Init(int internalStrength, int externalStrength,
                                     ENUM_TIMEFRAMES externalTF, bool persistenceEnabled,
                                     string symbol, ENUM_TIMEFRAMES currentTF,
                                     int extWindowSize, int maxSwingHistory,
                                     ENUM_STRUCTURE_LEVEL stateSource,
                                     int flushInterval=10)
  {
   m_status = FS_OK;
   m_extDataWaitingLogged = false;
   m_atrDataWaitingLogged = false;

   //--- ensure the external TF is not lower than the chart TF
   if(externalTF < currentTF)
     {
      Print("[MarketStructure] ERROR: external TF lower than chart TF.");
      m_status = FS_PARAMETER_ERROR;
      return false;
     }

   m_internalStrength = MathMax(1, internalStrength);
   m_externalStrength = MathMax(1, externalStrength);

   //--- compute minimum history required for the chosen strengths
   int maxStr = MathMax(m_internalStrength, m_externalStrength);
   int minHistory = 2 * maxStr + 1;
   if(maxSwingHistory < minHistory)
     {
      Print("[MarketStructure] WARNING: MaxSwingHistory increased to ", minHistory);
      maxSwingHistory = minHistory;
     }
   m_maxSwingHistory = maxSwingHistory;
   if(extWindowSize < m_maxSwingHistory)
     {
      Print("[MarketStructure] WARNING: ExternalHistoryBars increased to ", m_maxSwingHistory);
      extWindowSize = m_maxSwingHistory;
     }
   m_extWindowSize = extWindowSize;

   m_externalTF = externalTF;
   m_persistenceEnabled = persistenceEnabled;
   m_flushInterval = flushInterval;
   m_stateMachineSource = stateSource;

   m_eventIdCounter = CEventIdCounter();                                            // reset the ID counter

   //--- initialise the two swing detectors and the two structure managers
   m_internalSwingDetector.Init(m_internalStrength, m_maxSwingHistory);
   m_externalSwingDetector.Init(m_externalStrength, m_maxSwingHistory);

   m_internalStructure.Init(LEVEL_INTERNAL, &m_eventBus, &m_eventIdCounter, &m_internalSwingDetector);
   m_externalStructure.Init(LEVEL_EXTERNAL, &m_eventBus, &m_eventIdCounter, &m_externalSwingDetector);
   m_stateMachine.Init(&m_eventBus);

   m_persistence.Init(persistenceEnabled, symbol, currentTF, externalTF, m_flushInterval);

   //--- create ATR handles for both timeframes
   m_atrHandle = iATR(symbol, currentTF, 14);
   if(m_atrHandle == INVALID_HANDLE)
     {
      Print("[MarketStructure] ERROR: ATR handle internal TF");
      m_status = FS_ATR_ERROR;
      return false;
     }
   m_atrHandleExt = iATR(symbol, externalTF, 14);
   if(m_atrHandleExt == INVALID_HANDLE)
     {
      Print("[MarketStructure] ERROR: ATR handle external TF");
      m_status = FS_ATR_ERROR;
      return false;
     }

   //--- allocate external data buffers and set them as series
   m_externalLastBarTime = 0;
   m_externalBarCount = 0;
   ArrayResize(m_externalHighBuffer, m_extWindowSize);
   ArrayResize(m_externalLowBuffer, m_extWindowSize);
   ArrayResize(m_externalCloseBuffer, m_extWindowSize);
   ArrayResize(m_externalTimeBuffer, m_extWindowSize);
   ArraySetAsSeries(m_externalTimeBuffer, true);
   ArraySetAsSeries(m_externalHighBuffer, true);
   ArraySetAsSeries(m_externalLowBuffer, true);
   ArraySetAsSeries(m_externalCloseBuffer, true);

   return true;
  }

//+------------------------------------------------------------------+
//| Update external timeframe price data – only when a new bar       |
//| is detected, copy the latest bars into the buffer                |
//+------------------------------------------------------------------+
void CMarketStructureFramework::UpdateExternalData()
  {
   //--- wait for the external ATR to be calculated
   int atrReady = BarsCalculated(m_atrHandleExt);
   if(atrReady < 2)
     {
      if(!m_atrDataWaitingLogged)
        {
         Print("[MarketStructure] Waiting for external ATR calculation...");
         m_atrDataWaitingLogged = true;
        }
      if(m_status != FS_WAITING_FOR_DATA)
         m_status = FS_WAITING_FOR_DATA;
      return;
     }
   m_atrDataWaitingLogged = false;

   //--- wait until enough external bars exist in the terminal
   int totalExternalBars = Bars(_Symbol, m_externalTF);
   if(totalExternalBars < m_extWindowSize)
     {
      if(m_status != FS_WAITING_FOR_DATA)
        {
         Print("[MarketStructure] Waiting for external TF data.");
         m_status = FS_WAITING_FOR_DATA;
        }
      return;
     }
   else
      if(m_status == FS_WAITING_FOR_DATA)
        {
         Print("[MarketStructure] External data now available.");
         m_status = FS_OK;
        }

   //--- detect if a new external bar has appeared
   datetime currentExternalTime=0;
   if(!SeriesInfoInteger(_Symbol, m_externalTF, SERIES_LASTBAR_DATE, currentExternalTime))
      return;
   if(currentExternalTime==m_externalLastBarTime)
      return;

   //--- copy time and price arrays for the external TF
   int copiedTime=CopyTime(_Symbol, m_externalTF, 0, m_extWindowSize, m_externalTimeBuffer);
   if(copiedTime<=0)
      return;
   int wantBars=copiedTime;
   int copiedHigh=CopyHigh(_Symbol, m_externalTF, 0, wantBars, m_externalHighBuffer);
   int copiedLow=CopyLow(_Symbol, m_externalTF, 0, wantBars, m_externalLowBuffer);
   int copiedClose=CopyClose(_Symbol, m_externalTF, 0, wantBars, m_externalCloseBuffer);
   if(copiedHigh!=wantBars || copiedLow!=wantBars || copiedClose!=wantBars)
     {
      if(m_status != FS_COPY_ERROR)
        {
         Print("[MarketStructure] WARNING: incomplete external data copy");
         m_status = FS_COPY_ERROR;
        }
      return;
     }
   else
      if(m_status == FS_COPY_ERROR)
         m_status = FS_OK;

   m_externalBarCount=wantBars;
   m_externalLastBarTime=currentExternalTime;
  }

//+------------------------------------------------------------------+
//| Main processing loop – updates ATR, processes internal and       |
//| external structure, updates the state machine, and persists new  |
//| events                                                           |
//+------------------------------------------------------------------+
void CMarketStructureFramework::OnCalculate(const datetime &time[],
      const double &high[],
      const double &low[],
      const double &close[],
      int rates_total)
  {
   //--- fetch the latest ATR values for both timeframes
   double atrArr[1];
   if(CopyBuffer(m_atrHandle, 0, 1, 1, atrArr)==1)
      m_atrValue=atrArr[0];
   if(CopyBuffer(m_atrHandleExt, 0, 1, 1, atrArr)==1)
      m_atrValueExt=atrArr[0];

   //--- process internal structure on the current chart's data
   m_internalStructure.ProcessBars(time, high, low, close, rates_total, m_atrValue);

   //--- fetch and process external structure if data is available
   UpdateExternalData();
   if(m_externalBarCount>0)
     {
      m_externalStructure.ProcessBars(m_externalTimeBuffer,
                                      m_externalHighBuffer,
                                      m_externalLowBuffer,
                                      m_externalCloseBuffer,
                                      m_externalBarCount, m_atrValueExt);
     }

   //--- select the source structure for the state machine
   CStructureManager *sourceStructure = (m_stateMachineSource == LEVEL_INTERNAL) ? &m_internalStructure : &m_externalStructure;
   int trend = sourceStructure.GetTrend();

   //--- collect new break events from the event bus that the state machine hasn't processed yet
   SStructureEvent newBreakEvents[];
   int newBreakCount = 0;
   datetime newestBreakTime = m_lastStateEventTime;

   for(int i = 0; i < m_eventBus.GetCount(); i++)
     {
      SStructureEvent ev;
      if(m_eventBus.GetEvent(i, ev))
        {
         //--- events are newest first; stop when we pass the last processed time
         if(ev.time <= m_lastStateEventTime)
            break;
         if(ev.level == m_stateMachineSource)
           {
            //--- only consider structural break/CHoCH events
            if(ev.type == EVENT_INTERNAL_BOS_BULLISH || ev.type == EVENT_INTERNAL_BOS_BEARISH ||
               ev.type == EVENT_EXTERNAL_BOS_BULLISH || ev.type == EVENT_EXTERNAL_BOS_BEARISH ||
               ev.type == EVENT_INTERNAL_CHOCH_BULLISH || ev.type == EVENT_INTERNAL_CHOCH_BEARISH ||
               ev.type == EVENT_EXTERNAL_CHOCH_BULLISH || ev.type == EVENT_EXTERNAL_CHOCH_BEARISH)
              {
               ArrayResize(newBreakEvents, newBreakCount + 1);
               newBreakEvents[newBreakCount] = ev;
               newBreakCount++;
               if(ev.time > newestBreakTime)
                  newestBreakTime = ev.time;
              }
           }
        }
     }

   //--- feed new break events to the state machine (oldest first)
   for(int i = newBreakCount - 1; i >= 0; i--)
      m_stateMachine.ProcessBreakEvent(newBreakEvents[i], trend);

   m_lastStateEventTime = newestBreakTime;

   //--- let the state machine also consider the current trend (useful when no breaks exist)
   m_stateMachine.UpdateTrend(trend);

   //--- persistence: write new events to CSV
   if(m_persistenceEnabled)
     {
      datetime newestPersistedTime=m_lastPersistedEventTime;
      for(int i=0; i<m_eventBus.GetCount(); i++)
        {
         SStructureEvent ev;
         if(m_eventBus.GetEvent(i, ev))
           {
            if(ev.time <= m_lastPersistedEventTime)
               break;                                                  // already persisted everything older
            m_persistence.WriteEvent(ev);
            if(ev.time > newestPersistedTime)
               newestPersistedTime=ev.time;
           }
        }
      m_lastPersistedEventTime=newestPersistedTime;
     }
  }

//+-------------------------------------------------------------------+
//| Cleanup – close persistence file and release ATR indicator handles|
//+-------------------------------------------------------------------+
void CMarketStructureFramework::OnDeinit(void)
  {
   m_persistence.Close();
   if(m_atrHandle!=INVALID_HANDLE)
     {
      IndicatorRelease(m_atrHandle);
      m_atrHandle=INVALID_HANDLE;
     }
   if(m_atrHandleExt!=INVALID_HANDLE)
     {
      IndicatorRelease(m_atrHandleExt);
      m_atrHandleExt=INVALID_HANDLE;
     }
  }

//+------------------------------------------------------------------+
//| GetCurrentState – returns the current market state               |
//| GetCurrentBias – converts the state into a directional integer   |
//| (1 = bullish, -1 = bearish, 0 = neutral/unknown/range)           |
//+------------------------------------------------------------------+
ENUM_MARKET_STATE CMarketStructureFramework::GetCurrentState(void) { return m_stateMachine.GetState(); }
int CMarketStructureFramework::GetCurrentBias(void)
  {
   ENUM_MARKET_STATE state=m_stateMachine.GetState();
   if(state==STATE_BULLISH)
      return 1;
   if(state==STATE_BEARISH)
      return -1;
   return 0;
  }
//+------------------------------------------------------------------+
//| GetLastBOS – retrieve the most recent break-of-structure event   |
//| for the specified structural level                               |
//+------------------------------------------------------------------+
bool CMarketStructureFramework::GetLastBOS(SStructureEvent &out, ENUM_STRUCTURE_LEVEL level)
  {
   if(level==LEVEL_INTERNAL)
      return m_internalStructure.GetLastBOS(out);
   else
      return m_externalStructure.GetLastBOS(out);
  }
//+------------------------------------------------------------------+
//| GetLastCHoCH – retrieve the most recent change-of-character      |
//| event for the specified structural level                         |
//+------------------------------------------------------------------+
bool CMarketStructureFramework::GetLastCHoCH(SStructureEvent &out, ENUM_STRUCTURE_LEVEL level)
  {
   if(level==LEVEL_INTERNAL)
      return m_internalStructure.GetLastCHoCH(out);
   else
      return m_externalStructure.GetLastCHoCH(out);
  }
//+------------------------------------------------------------------+
//| GetSwingCount – return the number of detected swing highs or     |
//| lows for the specified structural level                          |
//+------------------------------------------------------------------+
int CMarketStructureFramework::GetSwingCount(bool isHigh, ENUM_STRUCTURE_LEVEL level)
  {
   CSwingDetector *detector = (level==LEVEL_INTERNAL) ? &m_internalSwingDetector : &m_externalSwingDetector;
   if(isHigh)
      return detector.GetSwingHighCount();
   else
      return detector.GetSwingLowCount();
  }
//+------------------------------------------------------------------+
//| GetSwingPoint – retrieve a specific swing high or low by index   |
//| for the chosen structural level                                  |
//+------------------------------------------------------------------+
bool CMarketStructureFramework::GetSwingPoint(bool isHigh, ENUM_STRUCTURE_LEVEL level, int index, SSwingPoint &out)
  {
   CSwingDetector *detector = (level==LEVEL_INTERNAL) ? &m_internalSwingDetector : &m_externalSwingDetector;
   if(isHigh)
      return detector.GetSwingHigh(index, out);
   else
      return detector.GetSwingLow(index, out);
  }
//+------------------------------------------------------------------+
//| GetRecentEventsCount – return the number of events in the bus    |
//| GetRecentEvent – retrieve an event by index (0 = newest)         |
//+------------------------------------------------------------------+
int CMarketStructureFramework::GetRecentEventsCount(void) { return m_eventBus.GetCount(); }
bool CMarketStructureFramework::GetRecentEvent(int index, SStructureEvent &out) { return m_eventBus.GetEvent(index, out); }

//+------------------------------------------------------------------+
//| HasNewEvents – check for new events since lastSeenId, return     |
//| the ID range (fromId to toId) if any                             |
//+------------------------------------------------------------------+
bool CMarketStructureFramework::HasNewEvents(long &lastSeenId, long &fromId, long &toId)
  {
   long lastEmitted = GetLastEventId();
   if(lastSeenId < lastEmitted)
     {
      fromId = lastSeenId + 1;
      toId   = lastEmitted;
      lastSeenId = lastEmitted;                                       // update the caller's last seen ID
      return true;
     }
   return false;
  }

//+------------------------------------------------------------------+
//| GetEventById – retrieve a specific event from the bus using its  |
//| unique event identifier                                          |
//+------------------------------------------------------------------+
bool CMarketStructureFramework::GetEventById(long eventId, SStructureEvent &out)
  {
   return m_eventBus.FindEventById(eventId, out);
  }

//+------------------------------------------------------------------+
//| GetCurrentStructureSnapshot – build a complete structural view   |
//| containing trend, protected levels, and the three most recent    |
//| swing highs and lows from the configured source timeframe        |
//+------------------------------------------------------------------+
bool CMarketStructureFramework::GetCurrentStructureSnapshot(SStructureSnapshot &snap)
  {
   CStructureManager *structure = (m_stateMachineSource == LEVEL_INTERNAL) ? &m_internalStructure : &m_externalStructure;
   CSwingDetector    *detector  = (m_stateMachineSource == LEVEL_INTERNAL) ? &m_internalSwingDetector : &m_externalSwingDetector;

   snap.trend = structure.GetTrend();

   SProtectedLevel protHigh, protLow;
   snap.highValid = structure.GetProtectedHigh(protHigh);
   snap.lowValid  = structure.GetProtectedLow(protLow);
   if(snap.highValid)
     {
      snap.protectedHigh = protHigh.price;
      snap.highTime = protHigh.time;
     }
   if(snap.lowValid)
     {
      snap.protectedLow  = protLow.price;
      snap.lowTime  = protLow.time;
     }

   //--- populate up to 3 most recent swing highs
   int highCount = detector.GetSwingHighCount();
   snap.highCount = MathMin(3, highCount);
   for(int i=0; i<snap.highCount; i++)
      detector.GetSwingHigh(highCount - 1 - i, snap.recentHighs[i]);

   //--- populate up to 3 most recent swing lows
   int lowCount = detector.GetSwingLowCount();
   snap.lowCount = MathMin(3, lowCount);
   for(int i=0; i<snap.lowCount; i++)
      detector.GetSwingLow(lowCount - 1 - i, snap.recentLows[i]);

   return true;
  }

//+------------------------------------------------------------------+
//| GetProtectedLevels – retrieve the current protected high and low |
//| prices from the configured source structure                      |
//+------------------------------------------------------------------+
bool CMarketStructureFramework::GetProtectedLevels(double &high, double &low)
  {
   CStructureManager *structure = (m_stateMachineSource == LEVEL_INTERNAL) ? &m_internalStructure : &m_externalStructure;
   SProtectedLevel protHigh, protLow;
   bool h = structure.GetProtectedHigh(protHigh);
   bool l = structure.GetProtectedLow(protLow);
   if(h)
      high = protHigh.price;
   if(l)
      low  = protLow.price;
   return (h || l);
  }
//+------------------------------------------------------------------+