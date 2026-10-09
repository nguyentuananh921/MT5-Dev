//+------------------------------------------------------------------+
//|                                                   TestScroll.mq5 |
//| Arrows step by 1, dragging the slider changes the position       |
//+------------------------------------------------------------------+
#property version "1.00"

#include <Vendors\Anhnt\Library\4. Combination Lib V2\Entities\Controls\Scrolls\ScrollV.mqh>
#include <Vendors\Anhnt\Library\4. Combination Lib V2\Entities\Controls\Scrolls\ScrollH.mqh>

CScrollV m_scrollv;
CScrollH m_scrollh;

int OnInit(void)
  {
   const long chart_id=::ChartID();
   if(!m_scrollv.CreateScroll(chart_id,0,"TestScrollV",60,60,15,200,50,10))
      return INIT_FAILED;
   if(!m_scrollh.CreateScroll(chart_id,0,"TestScrollH",100,60,250,15,40,10))
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
   m_scrollv.OnChartEvent(id,lparam,dparam,sparam);
   m_scrollh.OnChartEvent(id,lparam,dparam,sparam);
   if(id==CHARTEVENT_CUSTOM+ON_SCROLL_CHANGE)
      ::Print("MY DEBUG TestScroll::OnChartEvent: scroll id=",lparam," pos=",(int)dparam,
              " (V id=",m_scrollv.ObjectID()," H id=",m_scrollh.ObjectID(),")");
  }
