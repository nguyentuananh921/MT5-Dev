//+------------------------------------------------------------------+
//|                                                 AutoRepeat.mqh   |
//|                                  Copyright 2025, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//| MVC Paradigm in MQL5                                             |
//| First See in             https://www.mql5.com/en/articles/18658  |
//| Current                   https://www.mql5.com/ru/articles/20596 |
//+------------------------------------------------------------------+
#property copyright "Copyright 2025, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
//+------------------------------------------------------------------+
//| Auto-repeat event class |
//+------------------------------------------------------------------+
#ifndef __AUTOREPEAT_MQH__
#define __AUTOREPEAT_MQH__
    //#include <Arrays\List.mqh>
    //+------------------------------------------------------------------+
    // | Included Libraries |
    //+------------------------------------------------------------------+
    #include "Counter.mqh"
  class CAutoRepeat : public CBaseObj
   {
    private:
        CCounter          m_delay_counter;                          // Counter for delay before auto-repeat
        CCounter          m_repeat_counter;                         // Counter for sending events periodically
        long              m_chart_id;                               // Schedule for sending a custom event
        bool              m_button_pressed;                         // Flag indicating whether the button is pressed
        bool              m_auto_repeat_started;                    // Flag indicating whether autoreplay has started
        uint              m_delay_before_repeat;                    // Delay before auto-repeat starts (ms)
        uint              m_repeat_interval;                        // Frequency of sending events (ms)
        ushort            m_event_id;                               // Custom Event ID
        long              m_event_lparam;                           // long parameter of the user event
        double            m_event_dparam;                           // double parameter of the user event
        string            m_event_sparam;                           // string parameter of the custom event

     // --- Sending a custom event
        void              SendEvent() { ::EventChartCustom((this.m_chart_id<=0 ? ::ChartID() : this.m_chart_id), this.m_event_id, this.m_event_lparam, this.m_event_dparam, this.m_event_sparam); }
    public:
     // ---Object type
        virtual int       Type(void)                          const { return(ELEMENT_TYPE_AUTOREPEAT_CONTROL);   }
                            
     // --- Constructors
                            CAutoRepeat(void) : 
                            m_button_pressed(false), m_auto_repeat_started(false), m_delay_before_repeat(350), m_repeat_interval(100),
                            m_event_id(0), m_event_lparam(0), m_event_dparam(0), m_event_sparam(""), m_chart_id(::ChartID()) {}
                            
                            CAutoRepeat(long chart_id, int delay_before_repeat=350, int repeat_interval=100, ushort event_id=0, long event_lparam=0, double event_dparam=0, string event_sparam="") :
                            m_button_pressed(false), m_auto_repeat_started(false), m_delay_before_repeat(delay_before_repeat), m_repeat_interval(repeat_interval),
                            m_event_id(event_id), m_event_lparam(event_lparam), m_event_dparam(event_dparam), m_event_sparam(event_sparam), m_chart_id(chart_id) {}

     // --- Setting the chart ID
        void              SetChartID(const long chart_id)              { this.m_chart_id=chart_id;         }
        void              SetDelay(const uint delay)                   { this.m_delay_before_repeat=delay; }
        void              SetInterval(const uint interval)             { this.m_repeat_interval=interval;  }

     // --- Setting the custom event ID and parameters
        void              SetEvent(ushort event_id, long event_lparam, double event_dparam, string event_sparam)
                            {
                            this.m_event_id=event_id;
                            this.m_event_lparam=event_lparam;
                            this.m_event_dparam=event_dparam;
                            this.m_event_sparam=event_sparam;
                            }

     // --- Return flags
        bool              ButtonPressedFlag(void)                const { return this.m_button_pressed;     }
        bool              AutorepeatStartedFlag(void)            const { return this.m_auto_repeat_started;}
        uint              Delay(void)                            const { return this.m_delay_before_repeat;}
        uint              Interval(void)                         const { return this.m_repeat_interval;    }

     // --- Processing a button click (starting auto-repeat)
        void              OnButtonPress(void)
                            {
                            if(this.m_button_pressed)
                                return;
                            this.m_button_pressed=true;
                            this.m_auto_repeat_started=false;
                            this.m_delay_counter.Start(this.m_delay_before_repeat);  // Start the wait counter
                            }

     // --- Button release processing (stop auto-repeat)
        void              OnButtonRelease(void)
                            {
                            this.m_button_pressed=false;
                            this.m_auto_repeat_started=false;
                            }

     // --- Auto-repeat method (runs in a timer)
        void              Process(void)
                            {
                            // ---If the button is held down
                            if(this.m_button_pressed)
                            {
                                // --- Check if the delay has expired before auto-repeat starts
                                if(!this.m_auto_repeat_started && this.m_delay_counter.IsDone())
                                {
                                    this.m_auto_repeat_started=true;
                                    this.m_repeat_counter.Start(this.m_repeat_interval); // Starting the auto-repeat counter
                                }
                                // --- If auto-repeat has started, check the frequency of sending events
                                if(this.m_auto_repeat_started && this.m_repeat_counter.IsDone())
                                {
                                    // --- Send an event and restart the counter
                                    this.SendEvent();
                                    this.m_repeat_counter.Start(this.m_repeat_interval);
                                }
                            }
                            }
   };
    //+------------------------------------------------------------------+
#endif // __AUTOREPEAT_MQH__
