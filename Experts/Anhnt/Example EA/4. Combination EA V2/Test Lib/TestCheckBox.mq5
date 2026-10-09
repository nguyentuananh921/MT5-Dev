//+------------------------------------------------------------------+
//|                                                 TestCheckBox.mq5 |
//| Click toggles check boxes and the triggered button               |
//+------------------------------------------------------------------+
#property version "1.00"

#include <Vendors\Anhnt\Library\4. Combination Lib V2\Entities\Controls\CheckBox.mqh>

CGElement        m_panel;
CCheckBox        m_check_1;
CCheckBox        m_check_2;
CButtonTriggered m_toggle;

int OnInit(void)
  {
   const long chart_id=::ChartID();
   if(!m_panel.Create(chart_id,0,"TestCheckPanel",50,50,200,110))
      return INIT_FAILED;
   m_panel.AddChild(&m_check_1);
   m_panel.AddChild(&m_check_2);
   m_panel.AddChild(&m_toggle);
   m_check_1.SetText("Show markers");
   m_check_2.SetText("Play sound");
   m_toggle.SetText("Toggle");
   if(!m_check_1.Create(chart_id,0,"TestCheck1",10,10,180,20))
      return INIT_FAILED;
   if(!m_check_2.Create(chart_id,0,"TestCheck2",10,35,180,20))
      return INIT_FAILED;
   if(!m_toggle.Create(chart_id,0,"TestToggle",10,70,90,20))
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
   m_panel.OnChartEvent(id,lparam,dparam,sparam);
   if(id==CHARTEVENT_CUSTOM+ON_CLICK_CHECKBOX || id==CHARTEVENT_CUSTOM+ON_CLICK_BUTTON)
      ::Print("MY DEBUG TestCheckBox::OnChartEvent: ",(id==CHARTEVENT_CUSTOM+ON_CLICK_CHECKBOX ? "CHECKBOX" : "BUTTON"),
              " id=",lparam," state=",(int)dparam," text=",sparam);
  }
