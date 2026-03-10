//+------------------------------------------------------------------+
//|                                                   AutoRepeat.mqh |
//+------------------------------------------------------------------+
//|                   Tables in the MVC Paradigm in MQL5             |
//|                Customizable and sortable table columns           |
//|                           https://www.mql5.com/en/articles/19979 |
//+------------------------------------------------------------------+

#ifndef __AUTOREPEAT_MQH__
#define __AUTOREPEAT_MQH__
//+------------------------------------------------------------------+
//| Auto-repeat event class                                          |
//+------------------------------------------------------------------+
//|Include stadard library                                           |
//+------------------------------------------------------------------+


//+------------------------------------------------------------------+
//|Include Custome library                                           |
//+------------------------------------------------------------------+
#include "Counter.mqh"
#include "BaseObj.mqh"
#include "BaseDefines.mqh"
#include "BaseEnums.mqh"

class CAutoRepeat : public CBaseObj
  {
private:
   CCounter m_delay_counter;        // Counter for delay before auto-repeat
   CCounter m_repeat_counter;       // Counter for periodic event sending
   long     m_chart_id;             // Chart to send custom event to

   bool     m_button_pressed;       // Flag indicating the button is pressed
   bool     m_auto_repeat_started;  // Flag indicating auto-repeat started

   uint     m_delay_before_repeat;  // Delay before auto-repeat starts (ms)
   uint     m_repeat_interval;      // Event sending interval (ms)

   ushort   m_event_id;             // Custom event identifier
   long     m_event_lparam;         // long parameter of custom event
   double   m_event_dparam;         // double parameter of custom event
   string   m_event_sparam;         // string parameter of custom event

//--- Send custom event
   void SendEvent()
     {
      ::EventChartCustom(
         (this.m_chart_id<=0 ? ::ChartID() : this.m_chart_id),
         this.m_event_id,
         this.m_event_lparam,
         this.m_event_dparam,
         this.m_event_sparam
      );
     }

public:

//--- Object type
   virtual int Type(void) const { return(ELEMENT_TYPE_AUTOREPEAT_CONTROL); }

//--- Constructors
   CAutoRepeat(void) :
      m_button_pressed(false),
      m_auto_repeat_started(false),
      m_delay_before_repeat(350),
      m_repeat_interval(100),
      m_event_id(0),
      m_event_lparam(0),
      m_event_dparam(0),
      m_event_sparam(""),
      m_chart_id(::ChartID()) {}

   CAutoRepeat(long chart_id,
               int delay_before_repeat=350,
               int repeat_interval=100,
               ushort event_id=0,
               long event_lparam=0,
               double event_dparam=0,
               string event_sparam="") :

      m_button_pressed(false),
      m_auto_repeat_started(false),
      m_delay_before_repeat(delay_before_repeat),
      m_repeat_interval(repeat_interval),
      m_event_id(event_id),
      m_event_lparam(event_lparam),
      m_event_dparam(event_dparam),
      m_event_sparam(event_sparam),
      m_chart_id(chart_id) {}

//--- Set chart ID
   void SetChartID(const long chart_id) { this.m_chart_id=chart_id; }
   void SetDelay(const uint delay) { this.m_delay_before_repeat=delay; }
   void SetInterval(const uint interval) { this.m_repeat_interval=interval; }

//--- Set custom event parameters
   void SetEvent(ushort event_id,long event_lparam,double event_dparam,string event_sparam)
     {
      this.m_event_id=event_id;
      this.m_event_lparam=event_lparam;
      this.m_event_dparam=event_dparam;
      this.m_event_sparam=event_sparam;
     }

//--- Return flags
   bool ButtonPressedFlag(void) const { return this.m_button_pressed; }
   bool AutorepeatStartedFlag(void) const { return this.m_auto_repeat_started; }
   uint Delay(void) const { return this.m_delay_before_repeat; }
   uint Interval(void) const { return this.m_repeat_interval; }

//--- Button press handler (start auto-repeat)
   void OnButtonPress(void)
     {
      if(this.m_button_pressed)
         return;

      this.m_button_pressed=true;
      this.m_auto_repeat_started=false;

      // Start delay counter
      this.m_delay_counter.Start(this.m_delay_before_repeat);
     }

//--- Button release handler (stop auto-repeat)
   void OnButtonRelease(void)
     {
      this.m_button_pressed=false;
      this.m_auto_repeat_started=false;
     }

//--- Auto-repeat processing (called from timer)
   void Process(void)
     {
      // If button is held
      if(this.m_button_pressed)
        {
         // Check delay before auto-repeat
         if(!this.m_auto_repeat_started && this.m_delay_counter.IsDone())
           {
            this.m_auto_repeat_started=true;

            // Start repeat counter
            this.m_repeat_counter.Start(this.m_repeat_interval);
           }

         // If auto-repeat started, check repeat interval
         if(this.m_auto_repeat_started && this.m_repeat_counter.IsDone())
           {
            // Send event and restart counter
            this.SendEvent();
            this.m_repeat_counter.Start(this.m_repeat_interval);
           }
        }
     }
  };

#endif