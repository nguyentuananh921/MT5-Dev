//+------------------------------------------------------------------+
//|                                              Test_TradeSetupBox.mq5 |
//| Isolated test of CTradeSetupBox: a planned trade like the Long /  |
//| Short tool. The icon at the left of the strip turns a Buy into a  |
//| Sell; the red zone is the Stop, the green zone the Target. Drag   |
//| the Stop box (the price), or the grip icon at the start of the    |
//| strip (the whole box). The width follows the texts.               |
//| The lots come from a risk in percent of the balance (RPT), or are |
//| chosen. The button and the red icon send chart events only        |
//+------------------------------------------------------------------+
#property copyright "Anhnt"
#property version   "1.00"
#property strict

#include <Vendors\Anhnt\Library\4. Combination Lib V3\Collections\GraphElementsCollection.mqh>
#include <Vendors\Anhnt\Library\4. Combination Lib V3\Entities\Graph\Composite\TradeSetupBox.mqh>

input bool   InpBuy        = true;    // the box starts as a Buy (off: a Sell)
input int    InpStartShift = 25;      // the box starts at this bar (0 = the newest)
input int    InpBars       = 30;      // bars wide
input double InpStopAtr    = 1.5;     // Stop distance, in average candle ranges
input int    InpTpLevels   = 3;       // take profit levels (1 to 7): the first ones of ENUM_RISK_REWARD_RATIO, 1:1, 1:1.5, 1:2 ... of the Stop distance
input double InpRiskPercent= 1.0;     // risk in percent of the balance (0 = the fixed lots)
input double InpLots       = 0.10;    // the fixed lots, used when the risk is 0

CGraphElementsCollection g_graph;
CTradeSetupBox          *g_box=NULL;
//+------------------------------------------------------------------+
//| The average range of the last 14 candles                         |
//+------------------------------------------------------------------+
double AverageRange(const int from_shift)
  {
   double sum=0.0;
   int count=0;
   for(int i=from_shift;i<from_shift+14;i++)
     {
      double range=::iHigh(_Symbol,_Period,i)-::iLow(_Symbol,_Period,i);
      if(range>0.0)
        {
         sum+=range;
         count++;
        }
     }
   return (count>0 ? sum/count : _Point*100);
  }
//+------------------------------------------------------------------+
int OnInit()
  {
   g_graph.OnInit();
   if(g_box!=NULL)   // chart change: the box stays and follows by itself
     {
      ::EventSetMillisecondTimer(30);
      return INIT_SUCCEEDED;
     }
   g_box=new CTradeSetupBox();
   if(g_box==NULL || !g_box.Create(::ChartID(),0,"TSB_Test") || !g_graph.AddChild(g_box))
     {
      delete g_box;
      g_box=NULL;
      return INIT_FAILED;
     }
   int shift=InpStartShift;
   double entry=::iClose(_Symbol,_Period,shift);
   double range=AverageRange(shift+1);
   double stop=entry+(InpBuy ? -1.0 : 1.0)*InpStopAtr*range;
   g_box.SetLevels(InpTpLevels);
   g_box.Setup(::iTime(_Symbol,_Period,shift),InpBars,entry,stop);
   g_box.SetRiskPercent(InpRiskPercent);
   g_box.SetLots(InpLots);
   g_box.SetUseRisk(InpRiskPercent>0.0);
   ::Print(__FUNCTION__,": ",InpBuy ? "Buy" : "Sell"," entry ",entry," stop ",stop," target ",g_box.Target()," levels ",g_box.Levels()," lots ",g_box.Lots());
   ::EventSetMillisecondTimer(30);
   return INIT_SUCCEEDED;
  }
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   ::EventKillTimer();
   if(reason==REASON_CHARTCHANGE)
      return;
   if(g_box!=NULL)
     {
      g_graph.DeleteChild(g_box);
      delete g_box;
      g_box=NULL;
     }
   ::ChartRedraw();
  }
//+------------------------------------------------------------------+
void OnTick() {}
//+------------------------------------------------------------------+
void OnTimer()
  {
   g_graph.OnTimerEvent();
  }
//+------------------------------------------------------------------+
void OnChartEvent(const int id,const long &lparam,const double &dparam,const string &sparam)
  {
   g_graph.OnChartEvent(id,lparam,dparam,sparam);
  }
//+------------------------------------------------------------------+
