//+------------------------------------------------------------------+
//|                                                 MouseCombine.mqh |
//|               Combines CMouse (GUI Lib) + CMouseState (Services) |
//|  - Correct multi-button detection via bit-flags (CMouseState)    |
//|  - GapBetweenCalls, Time, Level at cursor (CMouse)               |
//|  - No automatic EventChartCustom side-effects                    |
//+------------------------------------------------------------------+
#ifndef __MOUSECOMBINE_MQH__
#define __MOUSECOMBINE_MQH__
#include "..\Defines\GUIDefines.mqh"
#include "..\GUI Lib\RectCanvas.mqh"
#include <Charts\Chart.mqh>
//+------------------------------------------------------------------+
#ifndef CMOUSECOMBINE_DECLARATION
#define CMOUSECOMBINE_DECLARATION
class CMouseCombine
  {
   private:
    CChart            m_chart;
    int               m_x;
    int               m_y;
    int               m_subwin;
    datetime          m_time;
    double            m_level;
    ushort            m_state_flags;     // bit0=left, bit1=right, bit2=shift, bit3=ctrl, bit4=middle
    int               m_delta_wheel;
    ulong             m_call_counter;    // GetTickCount at last MOUSE_MOVE

    void              SetButtonKeyFlags(const short flags);
    bool              m_left_button_state;    // --- State of the left mouse button (pressed/released)
    uint              m_pause_between_clicks; // --- Pause between left mouse clicks (to detect double click)
   public:
                     CMouseCombine(void);
                    ~CMouseCombine(void);

     void              OnEvent(const int id, const long &lparam,
                             const double &dparam, const string &sparam);

     int               X(void)               const { return m_x;                               }
     int               Y(void)               const { return m_y;                               }
     int               SubWin(void)          const { return m_subwin;                          }
     datetime          Time(void)            const { return m_time;                            }
     double            Level(void)           const { return m_level;                           }
     int               DeltaWheel(void)      const { return m_delta_wheel;                     }
     ulong             GapBetweenCalls(void) const { return ::GetTickCount() - m_call_counter; }

     bool              IsLeftBtn(void)       const { return (m_state_flags & 0x0001) != 0;    }
     bool              LeftButtonState(void) const { return m_left_button_state; }
     bool              IsPressedButtonLeft(void)  const { return m_state_flags == 1; }
     bool              CheckChangeLeftButtonState(const string mouse_state);
     bool              IsRightBtn(void)      const { return (m_state_flags & 0x0002) != 0;    }
     bool              IsShift(void)         const { return (m_state_flags & 0x0004) != 0;    }
     bool              IsCtrl(void)          const { return (m_state_flags & 0x0008) != 0;    }
     bool              IsMiddleBtn(void)     const { return (m_state_flags & 0x0010) != 0;    }
     bool              IsWheel(void)         const { return (m_state_flags & 0x0080) != 0;    }
     // --- Checking double-clicking the left mouse button
      void             CheckDoubleClick(void);
     ulong             CallCounter(void)     const { return m_call_counter;                     }

     int               RelativeX(CRectCanvas &obj);
     int               RelativeY(CRectCanvas &obj);

     // CMouseState compatibility
      ENUM_MOUSE_BUTT_KEY_STATE ButtonKeyState(const int id, const long &lparam,
                                             const double &dparam, const string &sparam);
      ushort            GetMouseFlags(void)        const { return m_state_flags;      }      
  };
#endif // CMOUSECOMBINE_DECLARATION

//+------------------------------------------------------------------+
#ifndef CMOUSECOMBINE_IMPLEMENTATION
#define CMOUSECOMBINE_IMPLEMENTATION
 CMouseCombine::CMouseCombine(void)
   : m_x(0), m_y(0), m_subwin(0), m_time(0), m_level(0.0),
     m_state_flags(0), m_delta_wheel(0),
     m_call_counter(0),
     m_left_button_state(false),
     m_pause_between_clicks(300)
  {
   m_call_counter = ::GetTickCount();
   m_chart.Attach();
  }
 CMouseCombine::~CMouseCombine(void)
  {
   m_chart.Detach();
  }
 void CMouseCombine::OnEvent(const int id, const long &lparam,
                            const double &dparam, const string &sparam)
  {
    if(id == CHARTEVENT_MOUSE_MOVE)
      {
      m_x                 = (int)lparam;
      m_y                 = (int)dparam;
      m_call_counter      = ::GetTickCount();
      SetButtonKeyFlags((short)StringToInteger(sparam));
      m_left_button_state = CheckChangeLeftButtonState(sparam);
      if(!::ChartXYToTimePrice(m_chart.ChartId(), m_x, m_y, m_subwin, m_time, m_level))
          return;
      if(m_subwin > 0)
          m_y -= m_chart.SubwindowY(m_subwin);
      return;
      }
    if(id == CHARTEVENT_MOUSE_WHEEL)
      {
      m_x           = (int)(short)lparam;
      m_y           = (int)(short)(lparam >> 16);
      m_delta_wheel = (int)dparam;
      SetButtonKeyFlags((short)(lparam >> 32));
      m_state_flags |= 0x0080;
      return;
      }
    if(id == CHARTEVENT_CLICK || id == CHARTEVENT_OBJECT_CLICK)
      {
      m_x           = (int)lparam;
      m_y           = (int)dparam;
      m_state_flags = 0x0001;
      if(id == CHARTEVENT_OBJECT_CLICK)
         CheckDoubleClick();
      return;
      }
  }
 int CMouseCombine::RelativeX(CRectCanvas &obj)
  {
   return (m_x - obj.X() + (int)ObjectGetInteger(0, obj.ChartObjectName(), OBJPROP_XOFFSET));
  }
 int CMouseCombine::RelativeY(CRectCanvas &obj)
  {
   return (m_y - obj.Y() + (int)ObjectGetInteger(0, obj.ChartObjectName(), OBJPROP_YOFFSET));
  }

  void CMouseCombine::SetButtonKeyFlags(const short flags)
  {
   m_state_flags = 0;
   if((flags & 0x0001) != 0) m_state_flags |= (1 << 0); // left button
   if((flags & 0x0002) != 0) m_state_flags |= (1 << 1); // right button
   if((flags & 0x0004) != 0) m_state_flags |= (1 << 2); // Shift
   if((flags & 0x0008) != 0) m_state_flags |= (1 << 3); // Ctrl
   if((flags & 0x0010) != 0) m_state_flags |= (1 << 4); // middle button
  }
 bool CMouseCombine::CheckChangeLeftButtonState(const string mouse_state)
  {
   bool left_button_state = (bool)int(mouse_state);
   if(m_left_button_state != left_button_state)
      ::EventChartCustom(m_chart.ChartId(), ON_CHANGE_MOUSE_LEFT_BUTTON, 0, 0.0, "");
   return(left_button_state);
  }
 void CMouseCombine::CheckDoubleClick(void)
  {
   static uint prev_depressed = 0;
   static uint curr_depressed = ::GetTickCount();
   prev_depressed = curr_depressed;
   curr_depressed = ::GetTickCount();
   uint counter   = curr_depressed - prev_depressed;
   if(counter < m_pause_between_clicks)
      ::EventChartCustom(m_chart.ChartId(), ON_DOUBLE_CLICK, counter, 0.0, "");
  }
#endif // CMOUSECOMBINE_IMPLEMENTATION
#endif // __MOUSECOMBINE_MQH__
