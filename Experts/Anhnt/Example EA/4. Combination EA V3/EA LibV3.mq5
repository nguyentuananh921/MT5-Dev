//+------------------------------------------------------------------+
//|                                                     EA LibV3.mq5 |
//+------------------------------------------------------------------+
#property strict
#include "Configuration\EA Configuration.mqh"   // the EA is the parent: it owns its children and passes the chart events down to them
#include "EA LibV3_TimeEngine.mqh"   // the schedule: the timer of the children and the scan of the symbols for a new bar
//+------------------------------------------------------------------+
int OnInit()
  {
   g_ea_init_done=false;
   m_SymbolsCollection.OnInitEvent();
   m_SymbolTFManager.OnInitEvent();
   if(m_ChartObj!=NULL)
      delete m_ChartObj;
   m_ChartObj=new CChartObj(::ChartID());
   OnInitEvent_TimeEngine();
   m_IndicatorTemplateManager.SetMarkers(false,InpIndicatorBuyColor,InpIndicatorSellColor);   // the badges are off until the tab says so
   m_IndicatorTemplateManager.OnInitEvent(m_ChartObj);
   m_PatternManager.SetMarkers(false,InpPatternBuyColor,InpPatternSellColor);   // the badges are off until the tab says so
   m_PatternManager.OnInitEvent();
   m_RiskManagementManager.SetRisk(false,5.0);   // no risk % per new trade until the Setup tab says so
   m_RiskManagementManager.OnInitEvent();
   m_SmartMoneySettingManager.OnInitEvent(&m_SwingSetting,&m_StructureSetting,&m_FvgSetting,&m_MomentumCandleSetting,&m_SupplyDemandSetting,&m_TrendlineSetting,&m_SupportResistanceSetting,&m_MarketConditionSetting);
   m_TradingControl.SetSymbolsCollection(&m_SymbolsCollection);
   m_TradingControl.SetIndicatorsCollection(&m_IndicatorsCollection);
   m_TradingControl.SetRiskManagementManager(&m_RiskManagementManager);
   g_GraphElementsCollection.OnInit();
   //--- What Python calculates and what is drawn of it
   m_SmartMoneySync.OnInitEvent(&g_GraphElementsCollection,&m_SwingSetting,&m_StructureSetting,&m_IndicatorTemplateManager,&m_PatternManager,m_PythonBridge.Swings(),m_PythonBridge.Structures(),m_PythonBridge.Signals(),m_PythonBridge.Patterns());
   m_PythonBridge.OnInitEvent(&m_SymbolTFManager,&m_SwingSetting,&m_TrendlineSetting,&m_SupportResistanceSetting,&m_MarketConditionSetting,&m_IndicatorTemplateManager,&m_PatternManager,&m_SmartMoneySync,&m_IndicatorsCollection);
   m_LifecycleSync.OnInitEvent(&g_GraphElementsCollection,&m_LifecycleCollection);
   m_LifecycleSync.SetSettings(&m_TrendlineSetting,&m_SupportResistanceSetting,&m_SupplyDemandSetting,&m_FvgSetting,&m_MomentumCandleSetting);
   m_PythonBridge.SetLifecycle(&m_LifecycleCollection,&m_LifecycleSync);
   m_PythonBridge.SetMomentumCandleSetting(&m_MomentumCandleSetting);
   m_SmartMoneySync.SetMomentumCandleSetting(&m_MomentumCandleSetting);
   m_LifecycleSync.SetSmartMoney(&m_SmartMoneySync);
   m_PythonBridge.SetSymbolsCollection(&m_SymbolsCollection);
   m_SmartMoneySync.SetMovements(m_PythonBridge.Movements());
   m_SmartMoneySync.SetMarketConditionSetting(&m_MarketConditionSetting);
   m_CandleInfo.OnInitEvent(m_PythonBridge.Signals(),m_PythonBridge.Patterns(),m_PythonBridge.Swings(),m_PythonBridge.Structures(),m_PythonBridge.Movements(),m_PythonBridge.Conditions(),&m_LifecycleCollection,&m_PatternManager);
   m_LifecycleSync.ApplyView();
   m_PythonBridge.Start();
   m_GUIPannel.SetSymbolsCollection(&m_SymbolsCollection);
   m_GUIPannel.SetAccountsCollection(&m_AccountsCollection);
   m_GUIPannel.SetSymbolTFManager(&m_SymbolTFManager);
   m_GUIPannel.SetPatternManager(&m_PatternManager);
   m_GUIPannel.SetSwingSetting(&m_SwingSetting);
   m_GUIPannel.SetStructureSetting(&m_StructureSetting);
   m_GUIPannel.SetFvgSetting(&m_FvgSetting);
   m_GUIPannel.SetMomentumCandleSetting(&m_MomentumCandleSetting);
   m_GUIPannel.SetSupplyDemandSetting(&m_SupplyDemandSetting);
   m_GUIPannel.SetTrendlineSetting(&m_TrendlineSetting);
   m_GUIPannel.SetSupportResistanceSetting(&m_SupportResistanceSetting);
   m_GUIPannel.SetIndicatorsCollection(&m_IndicatorsCollection);
   m_GUIPannel.SetRiskManagementManager(&m_RiskManagementManager);
   m_GUIPannel.SetTradingControl(&m_TradingControl);
   m_GUIPannel.SetIndicatorTemplateManager(&m_IndicatorTemplateManager);
   m_GUIPannel.SetMarketStory(m_PythonBridge.Conditions(),m_PythonBridge.Movements(),&m_MarketConditionSetting);
   m_GUIPannel.SetGraphElementsCollection(&g_GraphElementsCollection);
   if(!m_GUIPannel.OnInit(_UninitReason))
      return(INIT_FAILED);
   EventSetMillisecondTimer(16);
   g_ea_init_done=true;
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   EventKillTimer();
   m_GUIPannel.OnDeinit(reason);
   if(m_ChartObj!=NULL)
     {
      delete m_ChartObj;
      m_ChartObj=NULL;
     }
   m_PythonBridge.Stop(reason==REASON_REMOVE);   // chart change / recompile: Python keeps running
   m_SmartMoneySync.DeleteMarkers();
   m_LifecycleSync.DeleteAll();
  }
//+------------------------------------------------------------------+
void OnTick()
  {
   m_PythonBridge.RequestPreTradeSymbolMonitor();   // the values of the indicators (the ATR of the Stop Loss tab) follow the forming bar
   m_GUIPannel.OnTickEvent();
  }
//+------------------------------------------------------------------+
void OnTrade()
  {
   m_AccountsCollection.Refresh();
   m_GUIPannel.OnTradeEvent();
  }
//+------------------------------------------------------------------+
void OnTradeTransaction(const MqlTradeTransaction &trans,const MqlTradeRequest &request,const MqlTradeResult &result)
  {
   m_GUIPannel.OnTradeTransaction(trans);
  }
//--- The candle the window waits for: Python is asked, the window shows when its answer is complete
datetime g_candle_info_time=0;
int      g_candle_info_x=0;
int      g_candle_info_y=0;
bool     g_candle_info_by_marker=false;
//+------------------------------------------------------------------+
void OnTimer()
  {
   if(!g_ea_init_done)
      return;
   OnTimerEvent_TimeEngine();   // the Market Watch, the chart objects, the new bars, what Python sent
   datetime answered=0;
   if(m_PythonBridge.CandleInfoDone(answered) && answered==g_candle_info_time)
      ShowCandleInfo(g_candle_info_time,g_candle_info_x,g_candle_info_y,g_candle_info_by_marker);
   g_GraphElementsCollection.OnTimerEvent();
  }
//+------------------------------------------------------------------+
void OnChartEvent(const int id,const long &lparam,const double &dparam,const string &sparam)
  {
   ulong d0=::GetMicrosecondCount();   //Print Debug
   g_GraphElementsCollection.OnChartEvent(id,lparam,dparam,sparam);
   ulong d1=::GetMicrosecondCount();   //Print Debug
   m_LifecycleSync.OnChartEvent(id,lparam,dparam,sparam);
   if(id==CHARTEVENT_CHART_CHANGE)
     {
      CCandleMarker::Arrange(&g_GraphElementsCollection);
      CZoneTagBox::Arrange(&g_GraphElementsCollection);   // scroll, zoom, resize: the tags follow their zones
     }
   ulong d2=::GetMicrosecondCount();   //Print Debug
   OpenCandleInfo(id,lparam,dparam,sparam);
   m_GUIPannel.OnChartEvent(id,lparam,dparam,sparam);
   ulong d3=::GetMicrosecondCount();   //Print Debug
   //--- The indicator templates and the chart follow each other: the manager does it itself, the EA only passes the event on
   m_IndicatorTemplateManager.OnChartEvent(id,lparam,dparam,sparam,m_ChartObj);
   //--- A pair picked in the panel: the manager moves the chart itself
   m_SymbolTFManager.OnChartEvent(id,lparam,dparam,sparam,m_ChartObj);
   //--- What Python calculates depends on the tracked pairs and the indicator templates: tell it again
   if(id==CHARTEVENT_CUSTOM+SYMBOLTF_MANAGER_EVENT_ADDED || id==CHARTEVENT_CUSTOM+SYMBOLTF_MANAGER_EVENT_DELETE ||
      id==CHARTEVENT_CUSTOM+INDICATOR_TEMPLATE_MANAGER_EVENT_ADDED || id==CHARTEVENT_CUSTOM+INDICATOR_TEMPLATE_MANAGER_EVENT_DELETE ||
      id==CHARTEVENT_CUSTOM+MARKET_WATCH_EVENT_SYMBOL_ADD || id==CHARTEVENT_CUSTOM+MARKET_WATCH_EVENT_SYMBOL_DEL)   // a symbol came to or left the Market Watch: Python gets the symbols again
      m_PythonBridge.Reconfigure();
   //--- The Buy / Sell flag of an indicator or a candle pattern changed: every marker is drawn again
   if((id==CHARTEVENT_CUSTOM+PATTERN_MANAGER_EVENT_BUYSELL_CHANGED || id==CHARTEVENT_CUSTOM+INDICATOR_TEMPLATE_MANAGER_EVENT_BUYSELL_CHANGED) && m_PythonBridge.WatchDone())
      m_SmartMoneySync.RefreshSignals();   // only the markers of the signals change
   //--- Save of the Smart Money tab: the settings go to the file, Python gets what it calculates again (nothing is sent when it is the same), then everything is drawn again
   if(id==CHARTEVENT_CUSTOM+ON_SMARTMONEY_SETTING_SAVE)
     {
      m_SmartMoneySettingManager.SaveToJSON();
      m_LifecycleSync.ApplyView();
      m_PythonBridge.Reconfigure();
      RedrawSmartMoney();
     }
   ulong d4=::GetMicrosecondCount();   //Print Debug
   if(d4-d0>200000)   //Print Debug
      CMessage::ToFile(::MQLInfoString(MQL_PROGRAM_NAME),"EA","OnChartEvent","MY DEBUG slow event id="+(string)id+" lparam="+(string)lparam+" sparam="+sparam+": collection "+(string)((d1-d0)/1000)+" ms, lifecycle+arrange "+(string)((d2-d1)/1000)+" ms, candle info+panel "+(string)((d3-d2)/1000)+" ms, managers+rest "+(string)((d4-d3)/1000)+" ms, children of the collection "+(string)g_GraphElementsCollection.ChildrenTotal());   //Print Debug
  }
  //+------------------------------------------------------------------+
//| Candle information popup: opens on Shift + hover on a candle or on the cursor entering a CCandleMarker badge; the panel closes it
void OpenCandleInfo(const int id,const long &lparam,const double &dparam,const string &sparam)
  {
   static datetime s_last_bar=0;   // candle already handled while Shift stays down
   datetime bar_time=0;
   int x=0,y=0;
   bool by_marker=(id==CHARTEVENT_CUSTOM+ON_CANDLE_MARKER_ENTER);
   if(by_marker)
     {
      bar_time=(datetime)lparam;
      y=(int)dparam;
     }
   else if(id==CHARTEVENT_MOUSE_MOVE)
     {
      x=(int)lparam;
      y=(int)dparam;
      if(m_GUIPannel.IsWindow_CandleInfoVisible())
         return;
      bool shift=((((int)::StringToInteger(sparam))&MOUSE_BUTT_KEY_STATE_SHIFT)!=0);
      if(!shift || m_GUIPannel.MouseOverAnyGUIWindow(x,y))
        {
         s_last_bar=0;
         if(!g_candle_info_by_marker)
            g_candle_info_time=0;   // Shift released or the cursor left: the candle awaited is not wanted any more, nothing opens when Python answers
         return;
        }
      bar_time=(m_ChartObj!=NULL) ? m_ChartObj.GetBarTimeFromXY(x,y) : 0;
      if(bar_time==0)
        {
         if(!g_candle_info_by_marker)
            g_candle_info_time=0;
         return;
        }
      if(bar_time==s_last_bar)
         return;
      s_last_bar=bar_time;
     }
   else if(id==CHARTEVENT_CUSTOM+ON_CANDLE_MARKER_LEAVE)
     {
      if(g_candle_info_by_marker)
         g_candle_info_time=0;   // the cursor left the marker before Python answered
      return;
     }
   else
      return;
   //--- Python has every TF of the candle: it is asked, the window is shown when the answer is complete (by OnTimer)
   if(m_PythonBridge.RequestCandleInfo(bar_time))
     {
      g_candle_info_time=bar_time;
      g_candle_info_x=x;
      g_candle_info_y=y;
      g_candle_info_by_marker=by_marker;
      return;
     }
   ShowCandleInfo(bar_time,x,y,by_marker);   // Python cannot be asked now: the window shows what is held
  }
//+------------------------------------------------------------------+
//| The rows of one candle are read from what is held, the window shows them
void ShowCandleInfo(const datetime bar_time,const int x,const int y,const bool by_marker)
  {
   string          row_label[],row_tf[];
   ENUM_SIGNAL_DIR row_dir[];
   datetime        row_time[];
   int             row_source[];
   int count=m_CandleInfo.GetRows(bar_time,row_label,row_tf,row_dir,row_time,row_source);
   if(m_GUIPannel.RefreshWindow_CandleInfo(count,row_label,row_tf,row_dir,row_time,row_source))
     {
      m_GUIPannel.ShowWindow_CandleInfo(x,y,bar_time,by_marker);
      if(!by_marker)
         CCandleMarker::HighlightCandle(&g_GraphElementsCollection,bar_time);   // the marker route has its box already
     }
  }
//+------------------------------------------------------------------+
//| Every marker, line and zone is drawn again from what Python sent: the objects that are not wanted any more go
void RedrawSmartMoney(void)
  {
   if(!m_PythonBridge.WatchDone())
      return;   // the answer of Python is still arriving: its end draws them, once
   ulong d0=::GetMicrosecondCount();   //Print Debug
   m_SmartMoneySync.DeleteMarkers();
   ulong d1=::GetMicrosecondCount();   //Print Debug
   m_SmartMoneySync.Sync();
   ulong d2=::GetMicrosecondCount();   //Print Debug
   m_LifecycleSync.Sync();
   CMessage::ToFile(::MQLInfoString(MQL_PROGRAM_NAME),"EA","RedrawSmartMoney","MY DEBUG DeleteMarkers "+(string)((d1-d0)/1000)+" ms, SmartMoneySync.Sync "+(string)((d2-d1)/1000)+" ms, LifecycleSync.Sync "+(string)((::GetMicrosecondCount()-d2)/1000)+" ms, children "+(string)g_GraphElementsCollection.ChildrenTotal());   //Print Debug
  }