//+------------------------------------------------------------------+
//|                                            TestPatternInfoBox.mq5 |
//| Hold Shift and move over a candle: CPatternInfoBox covers the     |
//| 3 bars ending at it, the name floats above. Check: box colors,    |
//| half a candle margin on each side, follows scroll/zoom, hides     |
//| on Shift up                                                       |
//+------------------------------------------------------------------+
#property version "2.00"

#include <Vendors\Anhnt\Library\4. Combination Lib V2\Collections\GraphElementsCollection.mqh>
#include <Vendors\Anhnt\Library\4. Combination Lib V2\Entities\Graph\Composite\PatternInfoBox.mqh>

CGraphElementsCollection g_graph;          // owns the box
CPatternInfoBox         *g_box=NULL;       // used here, owned by g_graph
datetime                 g_last_bar=0;

int OnInit(void)
  {
   g_box=new CPatternInfoBox();
   if(g_box==NULL || !g_box.Create(::ChartID(),0,"TestPatternInfoBox") || !g_graph.AddChild(g_box))
     {
      ::Print("MY DEBUG TestPatternInfoBox::OnInit: create or add to collection failed, error ",::GetLastError());
      delete g_box;
      g_box=NULL;
      return INIT_FAILED;
     }
   ::EventSetMillisecondTimer(TIMER_STEP_MSC);
   return INIT_SUCCEEDED;
  }

void OnDeinit(const int reason)
  {
   ::EventKillTimer();
  }

void OnTimer(void)
  {
   g_graph.OnTimerEvent();
  }

void OnChartEvent(const int id,const long &lparam,const double &dparam,const string &sparam)
  {
   g_graph.OnChartEvent(id,lparam,dparam,sparam);
   if(id!=CHARTEVENT_MOUSE_MOVE)
      return;
   if((((int)::StringToInteger(sparam))&4)==0)
     {
      if(g_last_bar!=0)
        {
         g_last_bar=0;
         g_box.Hide();
         ::ChartRedraw();
        }
      return;
     }
   datetime t=0;
   double price=0.0;
   int sub=0;
   if(!::ChartXYToTimePrice(::ChartID(),(int)lparam,(int)dparam,sub,t,price))
      return;
   int shift=::iBarShift(_Symbol,_Period,t,false);
   if(shift<0 || shift+2>=::Bars(_Symbol,_Period))
      return;
   datetime bar_time=::iTime(_Symbol,_Period,shift);
   if(bar_time==g_last_bar)
      return;
   g_last_bar=bar_time;
   int hi_i=::iHighest(_Symbol,_Period,MODE_HIGH,3,shift);
   int lo_i=::iLowest(_Symbol,_Period,MODE_LOW,3,shift);
   ENUM_PATTERN_DIRECTION dir=(::iClose(_Symbol,_Period,shift)>=::iOpen(_Symbol,_Period,shift+2) ? PATTERN_DIRECTION_BULLISH : PATTERN_DIRECTION_BEARISH);
   g_box.Show(::iTime(_Symbol,_Period,shift+2),::iHigh(_Symbol,_Period,hi_i),::iLow(_Symbol,_Period,lo_i),dir,3,"Test Pattern (3 bars)");
   g_box.ShowTooltip();
   ::ChartRedraw();
  }

void OnTick(void)
  {
  }
