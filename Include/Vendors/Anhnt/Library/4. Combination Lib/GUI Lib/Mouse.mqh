//+------------------------------------------------------------------+
//|                                                        Mouse.mqh |
//|                        Copyright 2016, MetaQuotes Software Corp. |
//|Lib Link https://www.mql5.com/en/code/19703                       |
//+------------------------------------------------------------------+
#ifndef __MOUSE_MQH__
#define __MOUSE_MQH__
#include "Defines.mqh"
//#include "Objects.mqh"
#include "RectCanvas.mqh"
#include <Charts\Chart.mqh>

//+------------------------------------------------------------------+
// | Class for getting mouse parameters |
//+------------------------------------------------------------------+
class CMouse
  {
private:
   // --- An instance of the class for managing the graph
   CChart            m_chart;
   // ---Coordinates
   int               m_x;
   int               m_y;
   // --- Number of the window in which the cursor is located
   int               m_subwin;
   // --- Time corresponding to the X coordinate
   datetime          m_time;
   // --- Level (price) corresponding to the Y coordinate
   double            m_level;
   // --- State of the left mouse button (pressed/released)
   bool              m_left_button_state;
   // --- Call counter
   ulong             m_call_counter;
   // --- Pause between left mouse clicks (to detect double click)
   uint              m_pause_between_clicks;
   //---
public:
                     CMouse(void);
                    ~CMouse(void);
   // --- Event handler
   void              OnEvent(const int id,const long &lparam,const double &dparam,const string &sparam);

   // --- Returns the absolute coordinates of the mouse cursor
   int               X(void)               const { return(m_x);                             }
   int               Y(void)               const { return(m_y);                             }
   // --- (1) Returns the number of the window in which the cursor is located, (2) the time corresponding to the X coordinate,
   // (3) level (price) corresponding to the Y coordinate
   int               SubWindowNumber(void) const { return(m_subwin);                        }
   datetime          Time(void)            const { return(m_time);                          }
   double            Level(void)           const { return(m_level);                         }
   // --- Returns the state of the left mouse button (pressed/released)
   bool              LeftButtonState(void) const { return(m_left_button_state);             }

   // --- Returns (1) the counter value saved during the last call (ms) and
   // (2) the difference (ms) between calls to the mouse cursor event handler
   ulong             CallCounter(void)     const { return(m_call_counter);                  }
   ulong             GapBetweenCalls(void) const { return(::GetTickCount()-m_call_counter); }

   // --- Returns the relative coordinates of the mouse cursor from the passed canvas object for drawing
   int               RelativeX(CRectCanvas &object);
   int               RelativeY(CRectCanvas &object);
   //---
private:
   // --- Checking the state change of the left mouse button
   bool              CheckChangeLeftButtonState(const string mouse_state);
   // --- Checking double-clicking the left mouse button
   void              CheckDoubleClick(void);
  };
 #ifndef CMOUSE_MQH_IMPLEMENTATION
 #define CMOUSE_MQH_IMPLEMENTATION
   //+------------------------------------------------------------------+
   //| Constructor                                                      |
   //+------------------------------------------------------------------+
   CMouse::CMouse(void) : m_x(0),
                          m_y(0),
                          m_subwin(WRONG_VALUE),
                          m_time(NULL),
                          m_level(0.0),
                          m_left_button_state(false),
                          m_call_counter(::GetTickCount()),
                          m_pause_between_clicks(300)
     {
   // --- Get the ID of the current chart
      m_chart.Attach();
     }
   //+------------------------------------------------------------------+
   //| Destructor                                                       |
   //+------------------------------------------------------------------+
   CMouse::~CMouse(void)
     {
   // ---Disconnect from schedule
      m_chart.Detach();
     }
   //+------------------------------------------------------------------+
   // | Handling mouse events |
   //+------------------------------------------------------------------+
   void CMouse::OnEvent(const int id,const long &lparam,const double &dparam,const string &sparam)
     {
   // --- Handling the cursor movement event
      if(id==CHARTEVENT_MOUSE_MOVE)
        {
         // --- Coordinates and state of the left mouse button
         m_x                 =(int)lparam;
         m_y                 =(int)dparam;
         m_left_button_state =CheckChangeLeftButtonState(sparam);
         // --- Save the call counter value
         m_call_counter=::GetTickCount();
         // --- Get the cursor location
         if(!::ChartXYToTimePrice(m_chart.ChartId(),m_x,m_y,m_subwin,m_time,m_level))
            return;
         // --- Get the relative Y coordinate
         if(m_subwin>0)
            m_y=m_y-m_chart.SubwindowY(m_subwin);
         return;
        }
   // --- Processing the click event on the chart
      if(id==CHARTEVENT_CLICK)
        {
         // --- Let's check double-clicking the left mouse button
         CheckDoubleClick();
         return;
        }
     }
   //+------------------------------------------------------------------+
   // | Returns the relative X-coordinate of the mouse cursor |
   // | from the passed canvas object for drawing |
   //+------------------------------------------------------------------+
   int CMouse::RelativeX(CRectCanvas &object)
     {
      return(m_x-object.X()+(int)ObjectGetInteger(0,object.ChartObjectName(),OBJPROP_XOFFSET));
     }
   //+------------------------------------------------------------------+
   // | Returns the relative Y-coordinate of the mouse cursor |
   // | from the passed canvas object for drawing |
   //+------------------------------------------------------------------+
   int CMouse::RelativeY(CRectCanvas &object)
     {
      return(m_y-object.Y()+(int)ObjectGetInteger(0,object.ChartObjectName(),OBJPROP_YOFFSET));
     }
   //+------------------------------------------------------------------+
   // | Checking the state change of the left mouse button |
   //+------------------------------------------------------------------+
   bool CMouse::CheckChangeLeftButtonState(const string mouse_state)
     {
      bool left_button_state=(bool)int(mouse_state);
   // --- Send a message about the change in the state of the left mouse button
      if(m_left_button_state!=left_button_state)
         ::EventChartCustom(m_chart.ChartId(),ON_CHANGE_MOUSE_LEFT_BUTTON,0,0.0,"");
   // --- Reset the current state of the left mouse button
      return(left_button_state);
     }
   //+------------------------------------------------------------------+
   // | Checking double-clicking the left mouse button |
   //+------------------------------------------------------------------+
   void CMouse::CheckDoubleClick(void)
     {
      static uint prev_depressed =0;
      static uint curr_depressed =::GetTickCount();
   // --- Update the values
      prev_depressed =curr_depressed;
      curr_depressed =::GetTickCount();
   // --- Determine the time between presses
      uint counter = curr_depressed - prev_depressed;
   // --- If less time has passed between clicks than specified, we will send a message about the double click
      if(counter < m_pause_between_clicks)
        {
         ::EventChartCustom(m_chart.ChartId(),ON_DOUBLE_CLICK,counter,0.0,"");
        }
     }
   //+------------------------------------------------------------------+
 #endif // CMOUSE_MQH_IMPLEMENTATION
#endif // __MOUSE_MQH__
