//+------------------------------------------------------------------+
//|                                                        Mouse.mqh |
//| Kazharski CMouse + DoEasy CMouseState in one class               |
//+------------------------------------------------------------------+
#ifndef __MOUSE_MQH__
#define __MOUSE_MQH__
#include "..\Entities\Defines\GUIDefines.mqh"
#include "..\Entities\Defines\MouseDefines.mqh"
#include <Charts\Chart.mqh>
#ifndef CMOUSE_DECLARATION
#define CMOUSE_DECLARATION
//+------------------------------------------------------------------+
//| Mouse position, buttons/keys flags, wheel                        |
//+------------------------------------------------------------------+
class CMouse
  {
   private:
    CChart            m_chart;
    int               m_x;
    int               m_y;
    int               m_subwin;
    datetime          m_time;
    double            m_level;
    ushort            m_state_flags;     // bit0=left, bit1=right, bit2=shift, bit3=ctrl, bit4=middle, bit7=wheel
    int               m_delta_wheel;
    ulong             m_call_counter;
    bool              m_left_button_state;
    uint              m_pause_between_clicks;

    void              SetButtonKeyFlags(const short flags);
   public:
                     CMouse(void);
                    ~CMouse(void);
    void              OnEvent(const int id,const long &lparam,const double &dparam,const string &sparam);
    ENUM_MOUSE_BUTT_KEY_STATE ButtonKeyState(const int id,const long &lparam,const double &dparam,const string &sparam);
    int               X(void)                    const { return m_x;                                }
    int               Y(void)                    const { return m_y;                                }
    int               SubWin(void)               const { return m_subwin;                           }
    datetime          Time(void)                 const { return m_time;                             }
    double            Level(void)                const { return m_level;                            }
    int               DeltaWheel(void)           const { return m_delta_wheel;                      }
    ulong             GapBetweenCalls(void)      const { return ::GetTickCount()-m_call_counter;    }
    ulong             CallCounter(void)          const { return m_call_counter;                     }
    ushort            GetMouseFlags(void)        const { return m_state_flags;                      }
    bool              IsLeftBtn(void)            const { return (m_state_flags & 0x0001)!=0;        }
    bool              IsRightBtn(void)           const { return (m_state_flags & 0x0002)!=0;        }
    bool              IsShift(void)              const { return (m_state_flags & 0x0004)!=0;        }
    bool              IsCtrl(void)               const { return (m_state_flags & 0x0008)!=0;        }
    bool              IsMiddleBtn(void)          const { return (m_state_flags & 0x0010)!=0;        }
    bool              IsWheel(void)              const { return (m_state_flags & 0x0080)!=0;        }
    bool              IsPressedButtonLeft(void)  const { return m_state_flags==1;                   }
    bool              LeftButtonState(void)      const { return m_left_button_state;                }
    bool              CheckChangeLeftButtonState(const string mouse_state);
    void              CheckDoubleClick(void);
  };
#endif // CMOUSE_DECLARATION
#ifndef CMOUSE_IMPLEMENTATION
#define CMOUSE_IMPLEMENTATION
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
CMouse::CMouse(void) : m_x(0),m_y(0),m_subwin(0),m_time(0),m_level(0.0),
                       m_state_flags(0),m_delta_wheel(0),m_call_counter(0),
                       m_left_button_state(false),m_pause_between_clicks(300)
  {
   m_call_counter=::GetTickCount();
   m_chart.Attach();
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
CMouse::~CMouse(void)
  {
   m_chart.Detach();
  }
//+------------------------------------------------------------------+
//| Y is relative to the subwindow under the cursor                  |
//+------------------------------------------------------------------+
void CMouse::OnEvent(const int id,const long &lparam,const double &dparam,const string &sparam)
  {
   if(id==CHARTEVENT_MOUSE_MOVE)
     {
      m_x            =(int)lparam;
      m_y            =(int)dparam;
      m_call_counter =::GetTickCount();
      SetButtonKeyFlags((short)::StringToInteger(sparam));
      m_left_button_state=CheckChangeLeftButtonState(sparam);
      if(!::ChartXYToTimePrice(m_chart.ChartId(),m_x,m_y,m_subwin,m_time,m_level))
         return;
      if(m_subwin>0)
         m_y-=m_chart.SubwindowY(m_subwin);
      return;
     }
   if(id==CHARTEVENT_MOUSE_WHEEL)
     {
      m_x          =(int)(short)lparam;
      m_y          =(int)(short)(lparam>>16);
      m_delta_wheel=(int)dparam;
      SetButtonKeyFlags((short)(lparam>>32));
      m_state_flags|=0x0080;
      return;
     }
   if(id==CHARTEVENT_CLICK || id==CHARTEVENT_OBJECT_CLICK)
     {
      m_x          =(int)lparam;
      m_y          =(int)dparam;
      m_state_flags=0x0001;
      if(id==CHARTEVENT_OBJECT_CLICK)
         CheckDoubleClick();
     }
  }
//+------------------------------------------------------------------+
//| DoEasy CMouseState::ButtonKeyState                               |
//+------------------------------------------------------------------+
ENUM_MOUSE_BUTT_KEY_STATE CMouse::ButtonKeyState(const int id,const long &lparam,const double &dparam,const string &sparam)
  {
   OnEvent(id,lparam,dparam,sparam);
   return (ENUM_MOUSE_BUTT_KEY_STATE)m_state_flags;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CMouse::SetButtonKeyFlags(const short flags)
  {
   m_state_flags=0;
   if((flags & 0x0001)!=0) m_state_flags|=(1<<0);
   if((flags & 0x0002)!=0) m_state_flags|=(1<<1);
   if((flags & 0x0004)!=0) m_state_flags|=(1<<2);
   if((flags & 0x0008)!=0) m_state_flags|=(1<<3);
   if((flags & 0x0010)!=0) m_state_flags|=(1<<4);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CMouse::CheckChangeLeftButtonState(const string mouse_state)
  {
   bool left_button_state=(bool)int(mouse_state);
   if(m_left_button_state!=left_button_state)
      ::EventChartCustom(m_chart.ChartId(),ON_CHANGE_MOUSE_LEFT_BUTTON,0,0.0,"");
   return(left_button_state);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CMouse::CheckDoubleClick(void)
  {
   static uint prev_depressed=0;
   static uint curr_depressed=::GetTickCount();
   prev_depressed=curr_depressed;
   curr_depressed=::GetTickCount();
   uint counter=curr_depressed-prev_depressed;
   if(counter<m_pause_between_clicks)
      ::EventChartCustom(m_chart.ChartId(),ON_DOUBLE_CLICK,counter,0.0,"");
  }
#endif // CMOUSE_IMPLEMENTATION
#endif // __MOUSE_MQH__
