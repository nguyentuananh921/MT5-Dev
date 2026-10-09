//+------------------------------------------------------------------+
//|                                   EventBus.mqh                   |
//|                                   Copyright 2026, MetaQuotes     |
//|                                   https://www.mql5.com           |
//+------------------------------------------------------------------+
#property copyright "Copyright 2026, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
#property strict
#include "MarketStructureTypes.mqh"

//+------------------------------------------------------------------+
//| Event cache (ring buffer) for deduplication                      |
//+------------------------------------------------------------------+
class CEventCache
  {
private:
   EventSignature       m_buffer[];                                  // ring buffer storing recent event signatures
   int                  m_maxSize;                                   // maximum number of cached signatures
   int                  m_head;                                      // insertion point (next write position)
   int                  m_count;                                     // current number of valid entries

public:
                     CEventCache(int size=50);                       // constructor, size defines cache capacity
   bool                Contains(const EventSignature &sig) const;    // true if signature already cached
   void                Add(const EventSignature &sig);               // insert a new signature
   void                Clear();                                      // reset the cache
  };

//+------------------------------------------------------------------+
//| Initialize the ring buffer with a maximum size                   |
//+------------------------------------------------------------------+
CEventCache::CEventCache(int size)
  {
   m_maxSize = MathMax(1, size);                                     // at least 1 entry
   ArrayResize(m_buffer, m_maxSize);                                 // allocate storage
   m_head = 0;
   m_count = 0;
  }

//+------------------------------------------------------------------+
//| Check if an event signature exists in the deduplication cache    |
//| The search goes from newest to oldest (using modular arithmetic) |
//+------------------------------------------------------------------+
bool CEventCache::Contains(const EventSignature &sig) const
  {
   for(int i=0; i<m_count; i++)
     {
      //--- compute physical index, walking backwards from the newest entry
      int idx = (m_head - 1 - i + m_maxSize) % m_maxSize;
      if(m_buffer[idx].type == sig.type &&
         m_buffer[idx].time == sig.time &&
         m_buffer[idx].price == sig.price &&
         m_buffer[idx].level == sig.level)
         return true;
     }
   return false;
  }

//+------------------------------------------------------------------+
//| Add an event signature to the deduplication cache                |
//| Overwrites the oldest entry when the buffer is full              |
//+------------------------------------------------------------------+
void CEventCache::Add(const EventSignature &sig)
  {
   m_buffer[m_head] = sig;                                           // write at current head
   m_head = (m_head + 1) % m_maxSize;                                // advance head circularly
   if(m_count < m_maxSize)
      m_count++;                                                     // count grows until capacity is reached
  }

//+------------------------------------------------------------------+
//| Clear the deduplication cache                                    |
//+------------------------------------------------------------------+
void CEventCache::Clear()
  {
   m_head = 0;
   m_count = 0;
  }

//+------------------------------------------------------------------+
//| Circular buffer for events (searchable by eventId)               |
//+------------------------------------------------------------------+
class CEventBus
  {
private:
   SStructureEvent      m_events[];                                             // circular buffer storing the actual events
   int                  m_maxSize;                                              // maximum capacity
   int                  m_head;                                                 // write index (next published event goes here)
   int                  m_count;                                                // current number of stored events

public:
                     CEventBus(int maxSize=1000);                               // constructor, defines buffer size
   void                Publish(const SStructureEvent &event);                   // push a new event into the buffer
   int                 GetCount() const { return m_count; }                     // total events currently stored
   bool                GetEvent(int index, SStructureEvent &out) const;         // retrieve event (0 = newest)
   bool                FindEventById(long eventId, SStructureEvent &out) const; // locate event by its unique ID
   void                Clear();                                                 // empty the buffer
  };

//+------------------------------------------------------------------+
//| Initialize the circular buffer with a given maximum capacity     |
//+------------------------------------------------------------------+
CEventBus::CEventBus(int maxSize)
  {
   m_maxSize = MathMax(1, maxSize);                                              // ensure at least 1 slot
   ArrayResize(m_events, m_maxSize);                                             // allocate array
   m_head = 0;
   m_count = 0;
  }

//+------------------------------------------------------------------+
//| Publish an event to the bus (overwrites oldest if full)          |
//+------------------------------------------------------------------+
void CEventBus::Publish(const SStructureEvent &event)
  {
   if(m_maxSize<=0)
      return;
   m_events[m_head] = event;                                                      // store event at current head
   m_head = (m_head + 1) % m_maxSize;                                             // advance head (oldest will be overwritten next time)
   if(m_count < m_maxSize)
      m_count++;                                                                  // increment count until buffer is full
  }

//+------------------------------------------------------------------+
//| Retrieve an event by logical index (0 = newest)                  |
//| The mapping from logical to physical index uses modular math     |
//+------------------------------------------------------------------+
bool CEventBus::GetEvent(int index, SStructureEvent &out) const
  {
   if(index < 0 || index >= m_count)
      return false;                                                                // index out of valid range
   int realIndex = (m_head - 1 - index + m_maxSize) % m_maxSize;                   // physical position of the requested event
   out = m_events[realIndex];
   return true;
  }

//+------------------------------------------------------------------+
//| Search for an event by its unique ID                             |
//| Scans from newest to oldest; stops at the first match            |
//+------------------------------------------------------------------+
bool CEventBus::FindEventById(long eventId, SStructureEvent &out) const
  {
   for(int i=0; i<m_count; i++)
     {
      int idx = (m_head - 1 - i + m_maxSize) % m_maxSize;                          // walk backwards through the buffer
      if(m_events[idx].eventId == eventId)
        {
         out = m_events[idx];
         return true;
        }
     }
   return false;
  }

//+------------------------------------------------------------------+
//| Clear all events from the bus                                    |
//+------------------------------------------------------------------+
void CEventBus::Clear(void)
  {
   m_head = 0;
   m_count = 0;                                                                      // simply reset counters; array contents are overwritten later
  }
//+------------------------------------------------------------------+