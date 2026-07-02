//+------------------------------------------------------------------+
//|                                            TestComboBox.mq5      |
//| Minimal EA to test CComboBox click/open behavior in isolation,   |
//| at the same CWindow>CTabs>CSplitContainer>CTabs nesting depth    |
//| as the real V6 GUIPannel - Tang 2 (GUI) only.                    |
//+------------------------------------------------------------------+
#property copyright "Test"
#property version   "1.00"

#include "TestComboBoxGUI.mqh"
CTestComboBoxGUI testGUI;

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
