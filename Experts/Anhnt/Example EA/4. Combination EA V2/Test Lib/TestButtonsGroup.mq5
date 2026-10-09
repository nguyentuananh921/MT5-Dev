//+------------------------------------------------------------------+
//|                                             TestButtonsGroup.mq5 |
//| Pressing one button of a group releases the others               |
//+------------------------------------------------------------------+
#property version "1.00"

#include <Vendors\Anhnt\Library\4. Combination Lib V2\Entities\Controls\Window.mqh>
#include <Vendors\Anhnt\Library\4. Combination Lib V2\Entities\Controls\ButtonsGroup.mqh>

CWindow       m_window_main;
CButtonsGroup m_group_tf;
CButtonsGroup m_group_radio;

int OnInit(void)
  {
   const long chart_id=::ChartID();
   m_window_main.IsMovable(true);
   m_window_main.ResizeMode(true);
   m_window_main.CloseButtonIsUsed(true);
   if(!m_window_main.CreateWindow(chart_id,0,"BUTTONS GROUP",60,40,300,170))
      return INIT_FAILED;

   string tf[]={"M1","M5","M15","H1","D1"};
   for(int i=0; i<ArraySize(tf); i++)
      m_group_tf.AddButton(i*49,0,tf[i],50);
   m_group_tf.RadioButtonsMode(true);
   m_window_main.AddChild(&m_group_tf);
   if(!m_group_tf.CreateButtonsGroup(chart_id,0,"TestGroupTF",10,35))
      return INIT_FAILED;

   m_group_radio.RadioButtonsStyle(true);
   m_group_radio.RadioButtonsMode(true);
   string modes[]={"Fixed","ATR","Indicator"};
   for(int i=0; i<ArraySize(modes); i++)
      m_group_radio.AddButton(0,i*22,modes[i],120);
   m_window_main.AddChild(&m_group_radio);
   if(!m_group_radio.CreateButtonsGroup(chart_id,0,"TestGroupRadio",10,70))
      return INIT_FAILED;
   ::ChartRedraw(chart_id);
   return INIT_SUCCEEDED;
  }

void OnDeinit(const int reason)
  {
  }

void OnTick(void)
  {
  }

void OnChartEvent(const int id,const long &lparam,const double &dparam,const string &sparam)
  {
   m_window_main.OnChartEvent(id,lparam,dparam,sparam);
   if(id==CHARTEVENT_CUSTOM+ON_CLICK_GROUP_BUTTON)
      ::Print("MY DEBUG TestButtonsGroup::OnChartEvent: group id=",lparam," selected=",(int)dparam," text=",sparam,
              " (tf id=",m_group_tf.ObjectID()," radio id=",m_group_radio.ObjectID(),")");
  }
