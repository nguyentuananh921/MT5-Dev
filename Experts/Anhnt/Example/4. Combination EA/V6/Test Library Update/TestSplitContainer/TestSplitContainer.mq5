//+------------------------------------------------------------------+
//|                                       TestSplitContainer.mq5     |
//| Minimal EA to test CSplitContainer separator drag in isolation,  |
//| without the full V6 EA's complexity.                             |
//+------------------------------------------------------------------+
#property copyright "Test"
#property version   "1.00"

#include "TestSplitGUI.mqh"
CTestSplitGUI testGUI;

int OnInit(void)
  {
   ChartSetInteger(ChartID(), CHART_EVENT_MOUSE_MOVE, true);
   ChartSetInteger(ChartID(), CHART_EVENT_MOUSE_WHEEL, true);
   if(!testGUI.OnInitEvent(_UninitReason))
      return INIT_FAILED;
   EventSetMillisecondTimer(16);
   return INIT_SUCCEEDED;
  }

void OnDeinit(const int reason)
  {
   testGUI.OnDeinitEvent(reason);
  }

void OnTick(void)
  {
  }

void OnTimer(void)
  {
   testGUI.OnTimerEvent();
  }

void OnChartEvent(const int id, const long &lparam, const double &dparam, const string &sparam)
  {
   if(MQLInfoInteger(MQL_TESTER))
      return;
   testGUI.ChartEvent(id, lparam, dparam, sparam);
  }
