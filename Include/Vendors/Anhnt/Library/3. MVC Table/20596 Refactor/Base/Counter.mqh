//+------------------------------------------------------------------+
//|                                                    Counter.mqh   |
//|                                  Copyright 2025, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//| MVC Paradigm in MQL5                                             |
//|                                                                  |
//|                           https://www.mql5.com/ru/articles/20596 |
//+------------------------------------------------------------------+
#property copyright "Copyright 2025, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
//+------------------------------------------------------------------+
// | Included Libraries |
//+------------------------------------------------------------------+
#include <Arrays\List.mqh>

#ifndef __COUNTER_MQH__
#define __COUNTER_MQH__
   //+------------------------------------------------------------------+
   // | Millisecond counter class |
   //+------------------------------------------------------------------+
   class CCounter : public CBaseObj
   {
      private:
         bool              m_launched;                               // Started countdown flag
      // --- Starts countdown
         void              Run(const uint delay)
                           {
                              // --- If the countdown has already started, we leave
                              if(this.m_launched)
                                 return;
                              // --- If a non-zero delay value is passed, set a new value
                              if(delay!=0)
                                 this.m_delay=delay;
                              // --- We remember the start time and set the flag that the countdown has already started
                              this.m_start=::GetTickCount64();
                              this.m_launched=true;
                           }
      protected:
         ulong             m_start;                                  // Start time
         uint              m_delay;                                  // Delay

      public:
      // --- (1) Sets delay, starts counting with (2) set, (3) specified delay
         void              SetDelay(const uint delay)                { this.m_delay=delay;            }
         void              Start(void)                               { this.Run(0);                   }
         void              Start(const uint delay)                   { this.Run(delay);               }
      // --- Returns the countdown end flag
         bool              IsDone(void)
                           {
                              // --- If the countdown is not started, return false
                              if(!this.m_launched)
                                 return false;
                              // --- If more milliseconds have passed than the timeout
                              if(::GetTickCount64()-this.m_start>this.m_delay)
                              {
                                 // --- reset the started countdown flag and return true
                                 this.m_launched=false;
                                 return true;
                              }
                              // --- The specified time has not yet passed
                              return false;
                           }
         
      // --- Virtual methods (1) save to file, (2) load from file, (3) object type
         virtual bool      Save(const int file_handle);
         virtual bool      Load(const int file_handle);
         virtual int       Type(void)                          const { return(ELEMENT_TYPE_COUNTER);  }
         
      // --- Constructor/destructor
                           CCounter(void) : m_start(0), m_delay(0), m_launched(false) {}
                        ~CCounter(void) {}
   };
   #ifndef CCOUNTER_IMPLEMENTATION
   #define CCOUNTER_IMPLEMENTATION
      //+------------------------------------------------------------------+
      // | CCounter::Saving to file |
      //+------------------------------------------------------------------+
      bool CCounter::Save(const int file_handle)
      {
         // --- Save the data of the parent object
            if(!CBaseObj::Save(file_handle))
               return false;
               
         // --- Save the delay value
            if(::FileWriteInteger(file_handle,this.m_delay,INT_VALUE)!=INT_VALUE)
               return false;
            
         // --- Everything is successful
            return true;
      }
      //+------------------------------------------------------------------+
      // | CCounter::Loading from file |
      //+------------------------------------------------------------------+
      bool CCounter::Load(const int file_handle)
      {
         // --- Loading the data of the parent object
            if(!CBaseObj::Load(file_handle))
               return false;
               
         // --- Loading the delay value
            this.m_delay=::FileReadInteger(file_handle,INT_VALUE);
            
         // --- Everything is successful
            return true;
      }
      //+------------------------------------------------------------------+
   #endif // DECLARATION_IMPLEMENTATION
#endif // __COUNTER_MQH__
