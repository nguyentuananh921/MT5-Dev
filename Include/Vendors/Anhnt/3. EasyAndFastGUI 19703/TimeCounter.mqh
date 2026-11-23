//+------------------------------------------------------------------+
//|                                                  TimeCounter.mqh |
//|                        Copyright 2016, MetaQuotes Software Corp. |
//|                                              http://www.mql5.com |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
// | Time counter |
//+------------------------------------------------------------------+
#ifndef __TIMECOUNTER_MQH__
#define __TIMECOUNTER_MQH__
 class CTimeCounter 
  {
   private:
    // --- Counter step
      uint              m_step;
    // --- Time interval
      uint              m_pause;
    // --- Time counter
      uint              m_time_counter;    
  public:
      CTimeCounter(void);
      ~CTimeCounter(void);
    // --- Setting step and time interval
      void              SetParameters(const uint step, const uint pause);
    // --- Checks the passage of the specified time interval
      bool              CheckTimeCounter(void);
    // --- Counter reset
      void              ZeroTimeCounter(void) {m_time_counter = 0;}
  };
 #ifndef CTIMECOUNTER_MQH_IMPLEMENTATION
 #define CTIMECOUNTER_MQH_IMPLEMENTATION
   //+------------------------------------------------------------------+
   //| Constructor                                                      |
   //+------------------------------------------------------------------+
   CTimeCounter::CTimeCounter(void) : m_step(16),
     m_pause(1000),
     m_time_counter(0)
   {
   }
   //+------------------------------------------------------------------+
   //| Destructor                                                       |
   //+------------------------------------------------------------------+
   CTimeCounter::~CTimeCounter(void) {
   }
   //+------------------------------------------------------------------+
   // | Setting step and time interval |
   //+------------------------------------------------------------------+
   void CTimeCounter::SetParameters(const uint step, const uint pause) 
    {
      m_step  = step;
      m_pause = pause;
    }
   //+------------------------------------------------------------------+
   // | Checks the passage of the specified time interval |
   //+------------------------------------------------------------------+
   bool CTimeCounter::CheckTimeCounter(void) 
    {
      // --- Increase the counter if the specified time interval has not passed
      if(m_time_counter < m_pause) 
        {
          m_time_counter += m_step;
          return(false);
        }
      // --- Reset counter
        m_time_counter = 0;
      return(true);
    }
   //+------------------------------------------------------------------+
 #endif // CTIMECOUNTER_MQH_IMPLEMENTATION
#endif // __TIMECOUNTER_MQH__
