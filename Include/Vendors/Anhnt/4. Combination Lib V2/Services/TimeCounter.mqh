//+------------------------------------------------------------------+
//|                                                  TimeCounter.mqh |
//|        Combines CTimeCounter (GUI Lib, Kazharski) +              |
//|                  CTimerCounter (Services, Trishkin)              |
//|  - Plain step/pause throttle gate (Kazharski)                    |
//|  - Optional id + CObject Compare/Type for collection storage     |
//|    (Trishkin)                                                    |
//+------------------------------------------------------------------+
#ifndef __TIMECOUNTER_MQH__
#define __TIMECOUNTER_MQH__
#include <Object.mqh>
#ifndef CTIMECOUNTER_MQH_DECLARATION
#define CTIMECOUNTER_MQH_DECLARATION
class CTimeCounter : public CObject
  {
private:
   int               m_id;             // optional id, for storage in a CArrayObj collection
   ulong             m_step;           // counter step
   ulong             m_pause;          // time interval
   ulong             m_time_counter;   // accumulated counter
public:
                     CTimeCounter(const int id = -1);
   void              SetParameters(const ulong step, const ulong pause) { this.m_step = step; this.m_pause = pause; }
   bool              CheckTimeCounter(void);
   void              ZeroTimeCounter(void) { this.m_time_counter = 0; }
   virtual int       Type(void)       const { return this.m_id; }
   virtual int       Compare(const CObject *node, const int mode = 0) const;
  };
#endif // CTIMECOUNTER_MQH_DECLARATION
#ifndef CTIMECOUNTER_MQH_IMPLEMENTATION
#define CTIMECOUNTER_MQH_IMPLEMENTATION
CTimeCounter::CTimeCounter(const int id = -1) : m_id(id), m_step(16), m_pause(1000), m_time_counter(0)
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
int CTimeCounter::Compare(const CObject *node, const int mode = 0) const
  {
   const CTimeCounter *compared = node;
   int a = this.Type(), b = compared.Type();
   return(a > b ? 1 : a < b ? -1 : 0);
  }
#endif // CTIMECOUNTER_MQH_IMPLEMENTATION
#endif // __TIMECOUNTER_MQH__
