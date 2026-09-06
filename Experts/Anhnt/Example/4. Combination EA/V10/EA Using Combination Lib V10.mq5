//+------------------------------------------------------------------+
//|                                 EA Using Combination Lib V10.mq5 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|EA Code Base on https://www.mql5.com/en/articles/4727             |
//|Library base on Link https://www.mql5.com/en/code/19703           |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link "http://www.mql5.com"
#property version "1.00"
//--- Include application class
 //For GUI
  #include "Anatoli Kazharski\GUIPannel.mqh"
  CGUIPannel m_GUIPannel;
  #include "Artyom Trishkin\TradingEngine.mqh"
  CTradingEngine m_tradingEngine;
  #include "Artyom Trishkin\TimeSeriesEngine.mqh"
    CTimeSeriesEngine m_timeSeriesEngine;
  #include "Services\IndicatorTemplateManager.mqh"
   CIndicatorTemplateManager  m_IndicatorTemplateManager;
  #include "Services\SymbolTFManager.mqh"
   CSymbolTFManager  m_SymbolTFManager;
  #include "Services\TradingSetupSettingManager.mqh"
   CTradingSetupSettingManager  m_TradingSetupManager;
  #include "Services\SignalBridgeWriter.mqh"
   CSignalBridgeWriter  m_signal_bridge_writer;  
  #include <Vendors\Anhnt\Library\4. Combination Lib\Collections\ChartObjCollection.mqh>
   CChartObjCollection  m_ChartObjCollection;
  //--- Global folder path (centralized for all components)
   string g_ea_folder = "";  
   bool g_ea_init_done = false;  
   bool g_suppress_del_rescan = false;
 //+------------------------------------------------------------------+
 //| Expert initialization function                                   |
 //+------------------------------------------------------------------+
 int OnInit(void)
   {
      g_ea_init_done = false;   // reset every OnInit() call, including REASON_CHARTCHANGE reinit
      g_suppress_del_rescan = false;
      //--- Set the permissions to send cursor movement and mouse scroll events
        ChartSetInteger(ChartID(), CHART_EVENT_MOUSE_MOVE, true);
        ChartSetInteger(ChartID(), CHART_EVENT_MOUSE_WHEEL, true);
      //--- Initialize centralized folder path ONCE
        g_ea_folder = MQLInfoString(MQL_PROGRAM_NAME);
        Print(__FUNCTION__, "Debug EA::OnInit Folder initialized: ", g_ea_folder);      
        m_tradingEngine.OnInitEvent(); //For trading
        m_ChartObjCollection.CreateCollection();// For CChartObjCollection - MUST run before Manager's own OnInitEvent below (it scans this)
        m_IndicatorTemplateManager.OnInitEvent(&m_ChartObjCollection);//For Indicator Template Manager - loads JSON, then merges chart scan
        m_SymbolTFManager.OnInitEvent();//For Symbol+TF Manager
        m_timeSeriesEngine.SetSymbolsCollection(m_tradingEngine.GetSymbolsCollection());      
        m_timeSeriesEngine.OnInitEvent(::Symbol(), (ENUM_TIMEFRAMES)::Period(), &m_SymbolTFManager, &m_IndicatorTemplateManager);      
        m_signal_bridge_writer.OnInitEvent(m_timeSeriesEngine.GetSignalsCollection(),
                                           m_timeSeriesEngine.GetIndicatorsCollection(),
                                           m_timeSeriesEngine.GetTimeSeriesCollection(),
                                           &m_IndicatorTemplateManager, &m_SymbolTFManager,
                                           m_timeSeriesEngine.GetPatternsControl());
      //For GUI. Set pointers before GUI init - SetTimeSeriesEngine MUST run before
        m_GUIPannel.SetIndicatorTemplateManager(&m_IndicatorTemplateManager);
        m_GUIPannel.SetSymbolTFManager(&m_SymbolTFManager);
        m_GUIPannel.SetTradingSetupManager(&m_TradingSetupManager);
        m_GUIPannel.SetSymbolsCollection(m_tradingEngine.GetSymbolsCollection());
        m_GUIPannel.SetTimeSeriesCollection(m_timeSeriesEngine.GetTimeSeriesCollection());
        m_GUIPannel.SetIndicatorsCollection(m_timeSeriesEngine.GetIndicatorsCollection());
        m_GUIPannel.SetTimeSeriesEngine(&m_timeSeriesEngine);   // Tang 2 forwards "Add" clicks to Tang 1
        m_GUIPannel.SetPatternsControl(m_timeSeriesEngine.GetPatternsControl());        
        //   //mGUIPannel.SetTickSeriesCollection(timeSeriesEngine.GetTickSeries());
        //   mGUIPannel.SetMarketCollection(tradingEngine.GetMarketCollection());
        m_GUIPannel.SetTradingControl(m_tradingEngine.GetTradingControl());        
        m_GUIPannel.OnInitEvent(_UninitReason);  // GUIPannel tự xử lý CHARTCHANGE      
        m_signal_bridge_writer.BuildAndWriteSignalBridge();
        EnsureMarkerIndicatorAttached();
      EventSetMillisecondTimer(16);
      g_ea_init_done = true;   // every module wired - safe for Managers/Layer 3 to fire events now
      return (INIT_SUCCEEDED);
   }
 //+------------------------------------------------------------------+
 //| Expert deinitialization function                                 |
 //+------------------------------------------------------------------+
 void OnDeinit(const int reason)
  {
    m_GUIPannel.OnDeinitEvent(reason);
    if(reason != REASON_CHARTCHANGE)
       RemoveMarkerIndicator();
  }
 //+------------------------------------------------------------------+
 //| Expert tick function                                             |
 //+------------------------------------------------------------------+
 void OnTick(void)
  {
    m_tradingEngine.OnTickEvent();    
    //  Refresh pattern renderer on new bar
      SDataCalculate data_calc;
      MqlRates rates[1];
      if(::CopyRates(Symbol(), PERIOD_CURRENT, 0, 1, rates) == 1)
      {
          data_calc.rates         = rates[0];
          data_calc.rates_total   = ::Bars(Symbol(), PERIOD_CURRENT);
      }    
    bool any_new_bar = m_timeSeriesEngine.OnTickEvent(Symbol(), data_calc);    
    m_GUIPannel.OnTickEvent();
  }

 //+------------------------------------------------------------------+
 //| Timer function                                                   |
 //+------------------------------------------------------------------+
 void OnTimer(void)
  {
    if(!g_ea_init_done) return;   // native chart state can still be settling right after attach/reinit
    m_ChartObjCollection.Refresh();
    ulong t0 = GetMicrosecondCount();
    
    m_GUIPannel.OnTimerEvent();
    
    ulong t1 = GetMicrosecondCount();
    
    m_timeSeriesEngine.OnTimerEvent();    
    m_signal_bridge_writer.BuildAndWriteSignalBridge();
    ulong t2 = GetMicrosecondCount();
    ulong t3 = GetMicrosecondCount();
  }
 //+------------------------------------------------------------------+
 //| Trade function                                                   |
 //+------------------------------------------------------------------+
 void OnTrade(void)
  {
    m_tradingEngine.OnTickEvent();
    m_GUIPannel.OnTradeEvent();   // lazy-init/redraw trigger for CTradingLevelBubble
  }
 //+------------------------------------------------------------------+
 //| ChartEvent function                                              |
 //+------------------------------------------------------------------+
 void OnChartEvent(const int id, const long &lparam, const double &dparam,
                  const string &sparam)
  {
    if(MQLInfoInteger(MQL_TESTER)) return;
    m_GUIPannel.ChartEvent(id, lparam, dparam, sparam);    
    m_timeSeriesEngine.OnChartEvent(id, lparam, dparam, sparam, &m_SymbolTFManager, &m_IndicatorTemplateManager);    
    m_IndicatorTemplateManager.OnChartEvent(id, lparam, dparam, sparam, &m_ChartObjCollection);    
    m_signal_bridge_writer.OnChartEvent(id, lparam, dparam, sparam);    
    if(id == CHARTEVENT_CUSTOM + INDICATOR_TEMPLATE_MANAGER_EVENT_ADDED)
     {
      CIndicatorSetting *entry = m_IndicatorTemplateManager.At((int)lparam);
      if(entry == NULL) return;
      ENUM_INDICATOR type = entry.TypeEnum();
      MqlParam params[];
      entry.GetRawParams(params);      
      if(!m_ChartObjCollection.IsIndicatorShownOnChart(::ChartID(), type, params))
      m_ChartObjCollection.ShowIndicatorOnChart(::ChartID(), type, params);
      return;
     }   
     if(id == CHARTEVENT_CUSTOM + INDICATOR_TEMPLATE_MANAGER_EVENT_SHOW_CHANGED)
      {
       CIndicatorSetting *entry = m_IndicatorTemplateManager.At((int)lparam);
       Print("MY DEBUG EA::OnChartEvent SHOW_CHANGED: lparam(index)=", lparam, " entry=", (entry == NULL ? "NULL" : entry.DisplayLabel()));
       if(entry == NULL) return;
       ENUM_INDICATOR type = entry.TypeEnum();
       MqlParam params[];
       entry.GetRawParams(params);
       bool shown = m_ChartObjCollection.IsIndicatorShownOnChart(::ChartID(), type, params);
       Print("MY DEBUG EA::OnChartEvent SHOW_CHANGED: type=", EnumToString(type), " ShowOnChart()=", entry.ShowOnChart(), " live-shown=", shown);
       if(entry.ShowOnChart() && !shown)
        {
         Print("MY DEBUG EA::OnChartEvent SHOW_CHANGED: -> ShowIndicatorOnChart");
         m_ChartObjCollection.ShowIndicatorOnChart(::ChartID(), type, params);
        }
       else if(!entry.ShowOnChart() && shown)
        {
         Print("MY DEBUG EA::OnChartEvent SHOW_CHANGED: -> RemoveIndicatorFromChart");
         g_suppress_del_rescan = true;
         m_ChartObjCollection.RemoveIndicatorFromChart(::ChartID(), type, params);
        }
       else
         Print("MY DEBUG EA::OnChartEvent SHOW_CHANGED: -> no-op (already matches)");
       ChartRedraw();
       return;
      }    
     if(id == CHARTEVENT_CUSTOM + INDICATOR_TEMPLATE_MANAGER_EVENT_DELETE)
      {
       ENUM_INDICATOR type; MqlParam params[];
       m_IndicatorTemplateManager.GetLastRemoved(type, params);
       g_suppress_del_rescan = true;
       m_ChartObjCollection.RemoveIndicatorFromChart(::ChartID(), type, params);
       ChartRedraw();
       return;
      }    
     if(id == CHARTEVENT_CUSTOM + SYMBOLTF_MANAGER_EVENT_ADDED)
      {
       CSymbolTFSetting *entry = m_SymbolTFManager.At((int)lparam);
       if(entry == NULL) return;       
       SetActiveChartSymbolTF(entry.Symbol(), entry.TFEnum());
       return;
      }    
     if(id == CHARTEVENT_CUSTOM + SYMBOLTF_MANAGER_EVENT_SETTING_CHANGED)
      {
       string parts[];
       int split_total = StringSplit(sparam, '|', parts);
       Print("MY DEBUG EA::OnChartEvent SYMBOLTF_MANAGER_EVENT_SETTING_CHANGED: sparam=", sparam,
             " lparam=", lparam, " split_total=", split_total);
       if(split_total != 2) return;
       ENUM_TIMEFRAMES new_tf = (ENUM_TIMEFRAMES)(int)(lparam >> 32);
       Print("MY DEBUG EA::OnChartEvent SYMBOLTF_MANAGER_EVENT_SETTING_CHANGED: new_sym=", parts[1],
             " new_tf=", EnumToString(new_tf));
       SetActiveChartSymbolTF(parts[1], new_tf);
       return;
      }
     if(id == CHARTEVENT_CUSTOM + GUIPANNEL_EVENT_MARKER_SETTING_CHANGED)
      {       
       RemoveMarkerIndicator();
       EnsureMarkerIndicatorAttached();
       return;
      }
  }
 //+------------------------------------------------------------------+
 //| Tester function                                                  |
 //+------------------------------------------------------------------+
 double OnTester(void) 
  {  
    return true;
  }
 void OnTradeTransaction(const MqlTradeTransaction& trans,
                        const MqlTradeRequest& request,
                        const MqlTradeResult& result)
  {    
  }
 //+------------------------------------------------------------------+
 //| Sets this EA's own active chart to (sym,tf) via m_ChartObjCollection -   |
 //| shared by both the Manager-ADDED and GUIPannel-navigate listeners above. |
 //+------------------------------------------------------------------+
 void SetActiveChartSymbolTF(const string sym, const ENUM_TIMEFRAMES tf)
  {
   CChartObj *chart = m_ChartObjCollection.GetChart(::ChartID());
   if(chart == NULL) return;
   if(chart.Timeframe() == tf && chart.Symbol() == sym) return;
   // Single native call - chart.SetTimeframe()+chart.SetSymbol() each issue their own
   // ChartSetSymbolPeriod(), so calling both back-to-back fires it TWICE on the same chart;
   // a symbol/period switch is a full chart reinit, and the terminal rejects the second call
   // with 4102 "Chart does not respond" while the first one is still in flight - reproduced by
   // clicking a Symbol-level TreeView node with no TF child yet (Anhnt, 2026-08-26).
   ::ResetLastError();
   if(!::ChartSetSymbolPeriod(chart.ID(), sym, tf))
    {
     Print("MY DEBUG SetActiveChartSymbolTF: ChartSetSymbolPeriod failed, error=", ::GetLastError());
     return;
    }
   chart.SetProperty(CHART_PROP_SYMBOL, sym);
   chart.SetProperty(CHART_PROP_TIMEFRAME, tf);
  }
 //For Signal Marker  
  void EnsureMarkerIndicatorAttached(void)
   {
    CChartWnd *wnd = m_ChartObjCollection.GetChartWindow(::ChartID(), 0);
    if(wnd != NULL)
     {
        int total = wnd.IndicatorsTotal();
        for(int i = 0; i < total; i++)
         {
          CWndInd *ind = wnd.GetIndicatorByIndex(i);
          if(ind != NULL && ::StringFind(ind.Name(), SIGNALMARKERS_NAME_TAG) == 0)
            return; // already attached
         }
     }
    int single_buy, single_sell, multi_buy, multi_sell, pattern_buy, pattern_sell, combo_buy, combo_sell;
    color buy_clr, sell_clr, nonrelated_clr;
    m_GUIPannel.GetMarkerSettings(single_buy, single_sell, multi_buy, multi_sell,
                                  pattern_buy, pattern_sell, combo_buy, combo_sell,
                                  buy_clr, sell_clr, nonrelated_clr);

    int h = ::iCustom(NULL, 0, SIGNALMARKERS_PROGRAM_PATH,
                      single_buy, single_sell, multi_buy, multi_sell,
                      pattern_buy, pattern_sell, combo_buy, combo_sell,
                      buy_clr, sell_clr, nonrelated_clr,
                      g_ea_folder);
    if(h == INVALID_HANDLE)
     {
      ::Print(__FUNCTION__, " > iCustom(SignalMarkers) failed, error ", ::GetLastError());
      return;
     }
    if(!::ChartIndicatorAdd(::ChartID(), 0, h))
      ::Print(__FUNCTION__, " > ChartIndicatorAdd(SignalMarkers) failed, error ", ::GetLastError());
   }  
  void RemoveMarkerIndicator(void)
   {
    ::ChartIndicatorDelete(::ChartID(), 0, SIGNALMARKERS_NAME_TAG + "(" + ::Symbol() + ")");
   }  
 
   

