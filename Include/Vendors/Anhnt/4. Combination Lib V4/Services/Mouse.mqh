//+------------------------------------------------------------------+
//|                                                        Mouse.mqh |
//| Kazharski CMouse + DoEasy CMouseState in one class               |
//+------------------------------------------------------------------+
#ifndef __MOUSE_MQH__
#define __MOUSE_MQH__
#include "..\Entities\Defines\GUIDefines.mqh"
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
    int               m_windows_total;   // the windows of the chart, read when the chart changes: the mouse does not ask the chart each time
    ushort          m_state_flags;     // bit0=left, bit1=right, bit2=shift, bit3=ctrl, bit4=middle, bit7=wheel
    int               m_delta_wheel;
    bool              m_left_button_state;
    uint              m_pause_between_clicks;

    void              SetButtonKeyFlags(const short flags);
   public:
                     CMouse(void);
                    ~CMouse(void);
    void              OnEvent(const int id,const long &lparam,const double &dparam,const string &sparam);
    int               X(void)                    const { return m_x;                                }
    int               Y(void)                    const { return m_y;                                }
    int               SubWin(void)               const { return m_subwin;                           }
    int               DeltaWheel(void)           const { return m_delta_wheel;                      }
    ushort            GetMouseFlags(void)        const { return m_state_flags;                      }
    bool              IsLeftBtn(void)            const { return (m_state_flags & 0x0001)!=0;        }
    bool              IsCtrl(void)               const { return (m_state_flags & 0x0008)!=0;        }
    bool              CheckChangeLeftButtonState(const string mouse_state);
    void              CheckDoubleClick(void);
  };
#endif // CMOUSE_DECLARATION
#ifndef CMOUSE_IMPLEMENTATION
#define CMOUSE_IMPLEMENTATION
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
CMouse::CMouse(void) : m_x(0),m_y(0),m_subwin(0),m_windows_total(1),
                       m_state_flags(0),m_delta_wheel(0),
                       m_left_button_state(false),m_pause_between_clicks(300)
  {
   m_chart.Attach();
   m_windows_total=(int)::ChartGetInteger(m_chart.ChartId(),CHART_WINDOWS_TOTAL);
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
   if(id==CHARTEVENT_CHART_CHANGE)
     {
      m_windows_total=(int)::ChartGetInteger(m_chart.ChartId(),CHART_WINDOWS_TOTAL);
      return;
     }
   if(id==CHARTEVENT_MOUSE_MOVE)
     {
      m_x            =(int)lparam;
      m_y            =(int)dparam;
      SetButtonKeyFlags((short)::StringToInteger(sparam));
      m_left_button_state=CheckChangeLeftButtonState(sparam);
      //--- The subwindow under the cursor from where each one starts: ChartXYToTimePrice waits for the chart to be drawn (3-18 ms) and the time and the price are not used
      long chart_id=m_chart.ChartId();
      m_subwin=0;
      for(int win=m_windows_total-1;win>0;win--)
         if(m_y>=(int)::ChartGetInteger(chart_id,CHART_WINDOW_YDISTANCE,win))
           {
            m_subwin=win;
            break;
           }
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
      ::EventChartCustom(m_chart.ChartId(),CHANGE_EVENT_MOUSE_LEFT_BUTTON,0,0.0,"");
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
      ::EventChartCustom(m_chart.ChartId(),CLICK_EVENT_DOUBLE,counter,0.0,"");
  }
#endif // CMOUSE_IMPLEMENTATION
#endif // __MOUSE_MQH__
