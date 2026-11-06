//+------------------------------------------------------------------+
//|                                     Test_ChartSetSymbolPeriod.mq5 |
//| Does ChartSetSymbolPeriod alone make the terminal remove an EA?   |
//+------------------------------------------------------------------+
#property strict
int g_changes=0;   // survives a chart change re-init
//+------------------------------------------------------------------+
//| A chart change comes back here with the timer set again          |
//+------------------------------------------------------------------+
int OnInit()
  {
   ::Print("MY DEBUG    OnInit start reason=",::UninitializeReason(),", timeframe=",::EnumToString((ENUM_TIMEFRAMES)::Period()),", changes=",g_changes);
   ::EventSetTimer(3);
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   ::EventKillTimer();
   ::Print("MY DEBUG    OnDeinit reason=",reason);
  }
//+------------------------------------------------------------------+
//| The next TF, 60 changes at most                                  |
//+------------------------------------------------------------------+
void OnTimer()
  {
   if(g_changes>=60)
      return;
   const ENUM_TIMEFRAMES tfs[4]={PERIOD_M1,PERIOD_M5,PERIOD_M15,PERIOD_M30};
   g_changes++;
   ::ChartSetSymbolPeriod(0,::Symbol(),tfs[g_changes%4]);
  }
