//+------------------------------------------------------------------+
//|                                          EA LibV3_TimeEngine.mqh |
//| The EA owns the time. Python calculates, so what is left here is |
//| the schedule: the timer of the children and the scan of every    |
//| Market Watch symbol for a new bar. A new bar is told to Python   |
//| by an event (cmd new_bar): Python calculates the pairs that got  |
//| one and sends the new lines                                      |
//+------------------------------------------------------------------+
#ifndef __EA_LIBV3_TIMEENGINE_MQH__
#define __EA_LIBV3_TIMEENGINE_MQH__
 #define TIME_ENGINE_SCAN_MS          (100)    // the symbols are looked at for a new bar this often at most
 #define TIME_ENGINE_CHART_REFRESH_MS (250)    // indicators come and go rarely: the chart objects are not read at every timer
 //--- What the last scan saw (the globals survive a chart-change re-init: OnInitEvent_TimeEngine forgets it)
 ulong    g_time_engine_scan_ms=0;
 ulong    g_time_engine_chart_refresh_ms=0;
 string   g_time_engine_symbol[];     // the symbols of the last scan, in the order of the collection
 datetime g_time_engine_m1_time[];    // [symbol] = the M1 bar that was open at the last scan, 0 = not seen yet
 datetime g_time_engine_bar_time[];   // [symbol * TFs + TF] = the bar that was open at the last scan, 0 = not seen yet
//+------------------------------------------------------------------+
//| The first scan only remembers the bars, it tells nothing         |
//+------------------------------------------------------------------+
void OnInitEvent_TimeEngine(void)
  {
   ::ArrayResize(g_time_engine_symbol,0);
   ::ArrayResize(g_time_engine_m1_time,0);
   ::ArrayResize(g_time_engine_bar_time,0);
  }
//+------------------------------------------------------------------+
//| Every new bar of every TF starts with a new M1 bar: only the M1  |
//| bar of each symbol is looked at, the other TFs when it changed   |
//+------------------------------------------------------------------+
void ScanNewBars_TimeEngine(void)
  {
   ulong now=::GetTickCount64();
   if(now-g_time_engine_scan_ms<TIME_ENGINE_SCAN_MS)
      return;
   g_time_engine_scan_ms=now;
   ENUM_TIMEFRAMES tfs[];
   int tf_total=m_SymbolTFManager.AvailableTimeframes(tfs);
   if(tf_total==0)
      return;   // Python has not told which TFs it serves yet
   CArrayObj *list=m_SymbolsCollection.GetList();
   int total=list.Total();
   if(::ArraySize(g_time_engine_symbol)!=total || ::ArraySize(g_time_engine_bar_time)!=total*tf_total)
     {
      ::ArrayResize(g_time_engine_symbol,total);   // a symbol came or went, or the TFs changed: what was seen is forgotten
      ::ArrayResize(g_time_engine_m1_time,total);
      ::ArrayResize(g_time_engine_bar_time,total*tf_total);
      ::ArrayInitialize(g_time_engine_m1_time,0);
      ::ArrayInitialize(g_time_engine_bar_time,0);
      for(int i=0;i<total;i++)
         g_time_engine_symbol[i]="";
     }
   for(int i=0;i<total;i++)
     {
      CSymbol *symbol=list.At(i);
      if(symbol==NULL)
         continue;
      string name=symbol.Name();
      if(g_time_engine_symbol[i]!=name)
        {
         g_time_engine_symbol[i]=name;
         g_time_engine_m1_time[i]=0;
         for(int k=0;k<tf_total;k++)
            g_time_engine_bar_time[i*tf_total+k]=0;
        }
      datetime m1=::iTime(name,PERIOD_M1,0);
      if(m1==0 || m1==g_time_engine_m1_time[i])
         continue;
      bool first=(g_time_engine_m1_time[i]==0);
      g_time_engine_m1_time[i]=m1;
      ENUM_TIMEFRAMES changed[];
      for(int k=0;k<tf_total;k++)
        {
         datetime bar=::iTime(name,tfs[k],0);
         if(bar==0)
            continue;
         int at=i*tf_total+k;
         if(!first && g_time_engine_bar_time[at]!=0 && bar!=g_time_engine_bar_time[at])
           {
            int n=::ArraySize(changed);
            ::ArrayResize(changed,n+1);
            changed[n]=tfs[k];
           }
         g_time_engine_bar_time[at]=bar;
        }
      if(::ArraySize(changed)>0)
         m_PythonBridge.SendNewBar(name,changed);
     }
  }
//+------------------------------------------------------------------+
//| Call on every timer: the Market Watch, the chart objects, the    |
//| new bars, what Python sent                                       |
//+------------------------------------------------------------------+
void OnTimerEvent_TimeEngine(void)
  {
   m_SymbolsCollection.OnTimerEvent();
   if(m_ChartObj!=NULL && ::GetTickCount64()-g_time_engine_chart_refresh_ms>=TIME_ENGINE_CHART_REFRESH_MS)
     {
      g_time_engine_chart_refresh_ms=::GetTickCount64();
      m_ChartObj.Refresh();
     }
   ScanNewBars_TimeEngine();
   m_PythonBridge.Poll();
  }
#endif // __EA_LIBV3_TIMEENGINE_MQH__
