//+------------------------------------------------------------------+
//|                                                     Counter.mqh  |
//+------------------------------------------------------------------+
//|                   Tables in the MVC Paradigm in MQL5             |
//|                Customizable and sortable table columns           |
//|                           https://www.mql5.com/en/articles/19979 |
//+------------------------------------------------------------------+

#ifndef __COUNTER_MQH__
#define __COUNTER_MQH__
//+------------------------------------------------------------------+
//| Millisecond counter class                                        |
//+------------------------------------------------------------------+
//|Include stadard library                                           |
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//|Include Custome library                                           |
//+------------------------------------------------------------------+
#include "BaseEnums.mqh"
#include "BaseObj.mqh"


class CCounter : public CBaseObj
  {
private:
   bool m_launched; // Counter running flag

   void Run(const uint delay)
     {
      if(this.m_launched)
         return;

      if(delay!=0)
         this.m_delay=delay;

      this.m_start=::GetTickCount64();
      this.m_launched=true;
     }

protected:
   ulong m_start; // Start time
   uint m_delay;  // Delay

public:

//--- Set delay / start counter
   void SetDelay(const uint delay){ this.m_delay=delay; }
   void Start(void){ this.Run(0); }
   void Start(const uint delay){ this.Run(delay); }

//--- Check if finished
   bool IsDone(void)
     {
      if(!this.m_launched)
         return false;

      if(::GetTickCount64()-this.m_start>this.m_delay)
        {
         this.m_launched=false;
         return true;
        }

      return false;
     }

//--- Virtual methods
   virtual bool Save(const int file_handle);
   virtual bool Load(const int file_handle);
   virtual int Type(void) const { return(ELEMENT_TYPE_COUNTER); }

//--- Constructor
   CCounter(void):m_start(0),m_delay(0),m_launched(false){}
   ~CCounter(void){}
  };

#endif