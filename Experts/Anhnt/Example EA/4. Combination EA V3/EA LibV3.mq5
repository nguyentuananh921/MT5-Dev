//+------------------------------------------------------------------+
//|                                                     EA LibV3.mq5 |
//+------------------------------------------------------------------+
#property strict
#include "Configuration\EA Configuration.mqh"   // the EA is the parent: it owns its children and passes the chart events down to them
//+------------------------------------------------------------------+
//| What is drawn of the zones and the lines: the settings of the Smart Money tab, at the start and every time one changes
void ApplyLifecycleView(void)
  {
   m_LifecycleSync.SetView(LIFECYCLE_OBJECT_TRENDLINE,m_TrendlineSetting.ShowSupport(),m_TrendlineSetting.ShowResistance(),m_TrendlineSetting.ShowDead(),m_TrendlineSetting.MaxDead(),m_TrendlineSetting.Nearest());
   m_LifecycleSync.SetColors(LIFECYCLE_OBJECT_TRENDLINE,m_TrendlineSetting.SupportColor(),m_TrendlineSetting.ResistanceColor(),m_TrendlineSetting.DeadColor());
   m_LifecycleSync.SetView(LIFECYCLE_OBJECT_ZONE,m_SupportResistanceSetting.ShowSupport(),m_SupportResistanceSetting.ShowResistance(),m_SupportResistanceSetting.ShowDead(),m_SupportResistanceSetting.MaxDead());
   m_LifecycleSync.SetColors(LIFECYCLE_OBJECT_ZONE,m_SupportResistanceSetting.SupportColor(),m_SupportResistanceSetting.ResistanceColor(),m_SupportResistanceSetting.DeadColor());
   m_LifecycleSync.SetOpenNewest(LIFECYCLE_OBJECT_ZONE,m_SupportResistanceSetting.OpenNewestSupport(),m_SupportResistanceSetting.OpenNewestResistance());
   m_LifecycleSync.SetView(LIFECYCLE_OBJECT_SUPPLYDEMAND,m_SupplyDemandSetting.ShowDemand(),m_SupplyDemandSetting.ShowSupply(),m_SupplyDemandSetting.ShowDead(),m_SupplyDemandSetting.MaxDead());
   m_LifecycleSync.SetColors(LIFECYCLE_OBJECT_SUPPLYDEMAND,m_SupplyDemandSetting.DemandColor(),m_SupplyDemandSetting.SupplyColor(),m_SupplyDemandSetting.DeadColor());
   m_LifecycleSync.SetOpenNewest(LIFECYCLE_OBJECT_SUPPLYDEMAND,m_SupplyDemandSetting.OpenNewestDemand(),m_SupplyDemandSetting.OpenNewestSupply());
   m_LifecycleSync.SetView(LIFECYCLE_OBJECT_FVG,m_FvgSetting.ShowBullish(),m_FvgSetting.ShowBearish(),m_FvgSetting.ShowDead(),m_FvgSetting.MaxDead());
   m_LifecycleSync.SetColors(LIFECYCLE_OBJECT_FVG,m_FvgSetting.BullishColor(),m_FvgSetting.BearishColor(),m_FvgSetting.DeadColor());
   m_LifecycleSync.SetOpenNewest(LIFECYCLE_OBJECT_FVG,m_FvgSetting.OpenNewestBullish(),m_FvgSetting.OpenNewestBearish());
   m_LifecycleSync.SetView(LIFECYCLE_OBJECT_MOMENTUM,m_MomentumCandleSetting.Show(),m_MomentumCandleSetting.Show(),true,0);
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
//+------------------------------------------------------------------+
int OnInit()
  {
   g_ea_init_done=false;
   m_SymbolsCollection.OnInitEvent();
   m_SymbolTFManager.OnInitEvent();
   if(m_ChartObj!=NULL)
      delete m_ChartObj;
   m_ChartObj=new CChartObj(::ChartID());
   m_IndicatorTemplateManager.SetMarkers(InpIndicatorShow,InpIndicatorBuyColor,InpIndicatorSellColor);
   m_IndicatorTemplateManager.OnInitEvent(m_ChartObj);
   m_PatternManager.SetMarkers(InpPatternShow,InpPatternBuyColor,InpPatternSellColor);
   m_PatternManager.OnInitEvent();
   m_TradingSetupManager.SetRisk(InpUseRiskPerNewTrade,InpRiskPerNewTrade);
   m_TradingSetupManager.OnInitEvent();
   m_SmartMoneySettingManager.OnInitEvent(&m_SwingSetting,&m_StructureSetting,&m_FvgSetting,&m_MomentumCandleSetting,&m_SupplyDemandSetting,&m_TrendlineSetting,&m_SupportResistanceSetting);
   m_TradingEngine.SetSymbolsCollection(&m_SymbolsCollection);
   m_TradingEngine.SetIndicatorsCollection(&m_IndicatorsCollection);
   m_TradingEngine.SetTradingSetupManager(&m_TradingSetupManager);
   g_GraphElementsCollection.OnInit();
   //--- What Python calculates and what is drawn of it
   m_SmartMoneySync.OnInitEvent(&g_GraphElementsCollection,&m_SwingSetting,&m_StructureSetting,&m_IndicatorTemplateManager,&m_PatternManager,m_PythonBridge.Swings(),m_PythonBridge.Structures(),m_PythonBridge.Signals(),m_PythonBridge.Patterns());
   m_PythonBridge.OnInitEvent(&m_SymbolTFManager,&m_SwingSetting,&m_TrendlineSetting,&m_SupportResistanceSetting,&m_MarketConditionSetting,&m_IndicatorTemplateManager,&m_PatternManager,&m_SmartMoneySync,&m_IndicatorsCollection);
   m_LifecycleSync.OnInitEvent(&g_GraphElementsCollection,&m_LifecycleCollection);
   m_PythonBridge.SetLifecycle(&m_LifecycleCollection,&m_LifecycleSync);
   m_PythonBridge.SetMomentumCandleSetting(&m_MomentumCandleSetting);
   m_SmartMoneySync.SetMomentumCandleSetting(&m_MomentumCandleSetting);
   m_LifecycleSync.SetSmartMoney(&m_SmartMoneySync);
   m_PythonBridge.SetSymbolsCollection(&m_SymbolsCollection);
   m_SmartMoneySync.SetMovements(m_PythonBridge.Movements());
   m_SmartMoneySync.SetMarketConditionSetting(&m_MarketConditionSetting);
   m_CandleInfo.OnInitEvent(m_PythonBridge.Signals(),m_PythonBridge.Patterns(),m_PythonBridge.Swings(),m_PythonBridge.Structures(),m_PythonBridge.Movements(),m_PythonBridge.Conditions(),&m_LifecycleCollection,&m_PatternManager);
   ApplyLifecycleView();
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
   m_GUIPannel.SetTradingSetupManager(&m_TradingSetupManager);
   m_GUIPannel.SetTradingEngine(&m_TradingEngine);
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
void OnTimer()
  {
   if(!g_ea_init_done)
      return;
   m_SymbolsCollection.OnTimerEvent();
   static ulong chart_obj_refresh_ms=0;   // indicators come and go rarely: no need to poll every 16 ms
   if(m_ChartObj!=NULL && ::GetTickCount64()-chart_obj_refresh_ms>=250)
     {
      chart_obj_refresh_ms=::GetTickCount64();
      m_ChartObj.Refresh();
     }
   m_PythonBridge.Poll();
   m_GUIPannel.OnTimerEvent();   // the positions of the Trade Manage window after a trade
   g_GraphElementsCollection.OnTimerEvent();
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
         return;
        }
      bar_time=(m_ChartObj!=NULL) ? m_ChartObj.GetBarTimeFromXY(x,y) : 0;
      if(bar_time==0 || bar_time==s_last_bar)
         return;
      s_last_bar=bar_time;
     }
   else
      return;
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
      id==CHARTEVENT_CUSTOM+INDICATOR_TEMPLATE_MANAGER_EVENT_ADDED || id==CHARTEVENT_CUSTOM+INDICATOR_TEMPLATE_MANAGER_EVENT_DELETE)
      m_PythonBridge.Reconfigure();
   //--- The Buy / Sell flag of an indicator or a candle pattern changed: every marker is drawn again
   if((id==CHARTEVENT_CUSTOM+PATTERN_MANAGER_EVENT_BUYSELL_CHANGED || id==CHARTEVENT_CUSTOM+INDICATOR_TEMPLATE_MANAGER_EVENT_BUYSELL_CHANGED) && m_PythonBridge.WatchDone())
      m_SmartMoneySync.RefreshSignals();   // only the markers of the signals change
   //--- Save of the Smart Money tab: the settings go to the file, Python gets what it calculates again (nothing is sent when it is the same), then everything is drawn again
   if(id==CHARTEVENT_CUSTOM+ON_SMARTMONEY_SETTING_SAVE)
     {
      m_SmartMoneySettingManager.SaveToJSON();
      ApplyLifecycleView();
      m_PythonBridge.Reconfigure();
      RedrawSmartMoney();
     }
   ulong d4=::GetMicrosecondCount();   //Print Debug
   if(d4-d0>200000)   //Print Debug
      CMessage::ToFile(::MQLInfoString(MQL_PROGRAM_NAME),"EA","OnChartEvent","MY DEBUG slow event id="+(string)id+" lparam="+(string)lparam+" sparam="+sparam+": collection "+(string)((d1-d0)/1000)+" ms, lifecycle+arrange "+(string)((d2-d1)/1000)+" ms, candle info+panel "+(string)((d3-d2)/1000)+" ms, managers+rest "+(string)((d4-d3)/1000)+" ms, children of the collection "+(string)g_GraphElementsCollection.ChildrenTotal());   //Print Debug
  }
