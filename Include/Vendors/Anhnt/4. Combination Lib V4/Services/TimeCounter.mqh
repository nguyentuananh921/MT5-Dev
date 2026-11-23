//+------------------------------------------------------------------+
//|                                                  TimeCounter.mqh |
//|        Combines CTimeCounter (GUI Lib, Kazharski) +              |
//|                  CTimerCounter (Services, Trishkin)              |
//|  - Plain step/pause throttle gate (Kazharski)                    |
//+------------------------------------------------------------------+
#ifndef __TIMECOUNTER_MQH__
#define __TIMECOUNTER_MQH__
#ifndef CTIMECOUNTER_MQH_DECLARATION
#define CTIMECOUNTER_MQH_DECLARATION
class CTimeCounter
  {
private:
   ulong             m_step;           // counter step
   ulong             m_pause;          // time interval
   ulong             m_time_counter;   // accumulated counter
public:
                     CTimeCounter(void);
   void              SetParameters(const ulong step, const ulong pause) { this.m_step = step; this.m_pause = pause; }
   bool              CheckTimeCounter(void);
   void              ZeroTimeCounter(void) { this.m_time_counter = 0; }
  };
#endif // CTIMECOUNTER_MQH_DECLARATION
#ifndef CTIMECOUNTER_MQH_IMPLEMENTATION
#define CTIMECOUNTER_MQH_IMPLEMENTATION
CTimeCounter::CTimeCounter(void) : m_step(16), m_pause(1000), m_time_counter(0)
  {
  }
bool CTimeCounter::CheckTimeCounter(void)
  {
   if(this.m_time_counter >= ULONG_MAX)
        this.m_time_counter = 0;
   if(this.m_time_counter < this.m_pause)
     {
      this.m_time_counter += this.m_step;
      return false;
     }
   this.m_time_counter = 0;
   return true;
  }
#endif // CTIMECOUNTER_MQH_IMPLEMENTATION
#endif // __TIMECOUNTER_MQH__
