//+------------------------------------------------------------------+
//|                                                Test_ZoneTagBox.mq5 |
//| Isolated test of CZoneTagBox: a zone folded into a 22 px tag with |
//| the kind of the zone and a checkbox. The zones are made from the  |
//| bars of the chart (no Python, no lifecycle). Every "momentum      |
//| candle" has a Demand or Supply zone and, two times of three, a    |
//| FVG next to it: the tags of one candle are one box with a        |
//| checkbox for each zone, and the cursor on it lights the candle.   |
//| Click a checkbox: the zone shows, click again: it hides. A dead  |
//| zone is grey and its tag too, and when it is checked its zone is |
//| drawn, filled grey, from its birth to where it died              |
//+------------------------------------------------------------------+
#property copyright "Anhnt"
#property version   "1.00"
#property strict

#include <Vendors\Anhnt\Library\4. Combination Lib V3\Collections\GraphElementsCollection.mqh>
#include <Vendors\Anhnt\Library\4. Combination Lib V3\Entities\Graph\Composite\CandleMarker.mqh>
#include <Vendors\Anhnt\Library\4. Combination Lib V3\Entities\Graph\Composite\ZoneTagBox.mqh>

input int    InpCandles     = 12;      // momentum candles made from the bars of the chart
input int    InpStepBars    = 14;      // bars between two of them
input int    InpSamePrice   = 3;       // more candles on the prices of the first one (the boxes must not touch)
input bool   InpStartOpen   = false;   // the zones are shown from the start (the checkboxes are checked)
input int    InpDeadEvery   = 4;       // every n-th candle is dead (0 = none): its zones are filled grey, end where they died, and so are their tags
input int    InpLifeBars    = 30;      // bars a dead zone lives before it dies (to see the big grey zone)
input color  InpDemandColor = clrLimeGreen;
input color  InpSupplyColor = clrTomato;
input color  InpBullFvg     = clrTeal;
input color  InpBearFvg     = clrMediumVioletRed;
input color  InpDeadColor   = clrGray;

CGraphElementsCollection g_graph;
int                      g_arranged = 0;   // Arrange() is called again until the chart answers and the tags are measured
int                      g_number   = 0;   // names of the zones
//+------------------------------------------------------------------+
//| One zone: kind 0 Demand, 1 Supply, 2 Bull FVG, 3 Bear FVG        |
//+------------------------------------------------------------------+
bool MakeZone(const int kind,const double top,const double bottom,const datetime start,const datetime group,const datetime died)
  {
   CZoneTagBox *zone=new CZoneTagBox();
   if(zone==NULL)
      return false;
   if(!zone.Create(::ChartID(),0,"ZT_"+(string)(g_number++)) || !g_graph.AddChild(zone))
     {
      delete zone;
      return false;
     }
   string labels[]={"Demand","Supply","Bull FVG","Bear FVG"};
   bool buy=(kind==0 || kind==2);
   zone.SetZone(top,bottom,start,died,labels[kind],buy ? SIGNAL_BUY : SIGNAL_SELL);
   zone.SetGroupTime(group);
   if(died>0)   // dead: filled with the grey of the setup, from its birth to where it died (to look at it)
     {
      zone.SetZoneStyle(InpDeadColor,70,true,1);
      zone.SetDeadTime(died);
     }
   else if(kind==0)
      zone.SetZoneStyle(InpDemandColor,70,true,1);
   else if(kind==1)
      zone.SetZoneStyle(InpSupplyColor,70,true,1);
   else
      zone.SetZoneStyle(kind==2 ? InpBullFvg : InpBearFvg,70,true,1);   // filled too: only the zones that are checked show, so their colours do not pile up
   zone.SetInfo(labels[kind]);
   zone.Open(InpStartOpen);
   return true;
  }
//+------------------------------------------------------------------+
//| A momentum candle at this shift: the zone of the candle before it |
//| (Demand when it is up, Supply when it is down) and, when has_fvg, |
//| the gap next to that zone                                         |
//+------------------------------------------------------------------+
int MakeCandle(const int number,const int shift,const double base_top,const double base_bottom,const bool has_fvg,const bool dead)
  {
   datetime time=::iTime(_Symbol,_Period,shift);
   datetime died=(dead && shift>=InpLifeBars+1 ? ::iTime(_Symbol,_Period,shift-InpLifeBars) : 0);
   bool up=(number%2==0);
   double range=base_top-base_bottom;
   int made=0;
   if(MakeZone(up ? 0 : 1,base_top,base_bottom,time,time,died))
      made++;
   if(has_fvg)   // the gap touches the zone: above it for an up candle, below it for a down one
     {
      double top=(up ? base_top+0.6*range : base_bottom);
      double bottom=(up ? base_top : base_bottom-0.6*range);
      if(MakeZone(up ? 2 : 3,top,bottom,time,time,died))
         made++;
     }
   return made;
  }
//+------------------------------------------------------------------+
int OnInit()
  {
   g_graph.OnInit();
   int bars=::Bars(_Symbol,_Period);
   int made=0;
   for(int k=0;k<InpCandles;k++)
     {
      int shift=8+k*InpStepBars;
      if(shift>=bars-2)
         break;
      bool dead=(InpDeadEvery>0 && k%InpDeadEvery==InpDeadEvery-1);
      made+=MakeCandle(k,shift,::iHigh(_Symbol,_Period,shift+1),::iLow(_Symbol,_Period,shift+1),(k%3!=2),dead);
     }
   //--- more candles whose zones lie on the prices of the first one, started at other bars: their boxes would be on top of each other
   double top=::iHigh(_Symbol,_Period,9),bottom=::iLow(_Symbol,_Period,9);
   for(int k=0;k<InpSamePrice;k++)
     {
      int shift=8+(k+1)*3;
      if(shift<bars-2)
         made+=MakeCandle(InpCandles+k,shift,top,bottom,true,false);
     }
   ::Print(__FUNCTION__,": ",made," zone(s) made");
   CZoneTagBox::Arrange(&g_graph);
   ::EventSetMillisecondTimer(50);
   return INIT_SUCCEEDED;
  }
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   ::EventKillTimer();
   CCandleMarker::ClearHighlight();
   for(int i=g_graph.ChildrenTotal()-1;i>=0;i--)
     {
      CGBaseObj *child=g_graph.Child(i);
      if(dynamic_cast<CZoneTagBox *>(child)==NULL)
         continue;
      g_graph.DeleteChild(child);
      delete child;
     }
   CCandleMarker::ReleaseBox();
   ::ChartRedraw();
  }
//+------------------------------------------------------------------+
void OnTick() {}
//+------------------------------------------------------------------+
void OnTimer()
  {
   if(g_arranged<20)   // the first calls: the chart may not have answered yet, and the tags are not measured before they are painted
     {
      CZoneTagBox::Arrange(&g_graph);
      g_arranged++;
     }
   g_graph.OnTimerEvent();
  }
//+------------------------------------------------------------------+
void OnChartEvent(const int id,const long &lparam,const double &dparam,const string &sparam)
  {
   g_graph.OnChartEvent(id,lparam,dparam,sparam);
   if(id==CHARTEVENT_CHART_CHANGE)   // scroll, zoom, resize: the tags follow their zones
      CZoneTagBox::Arrange(&g_graph);
  }
//+------------------------------------------------------------------+
