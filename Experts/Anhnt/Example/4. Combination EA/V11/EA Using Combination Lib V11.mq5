//+------------------------------------------------------------------+
//|                                 EA Using Combination Lib V11.mq5 |
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
   CSignalBridgeWriter  m_signalBridgeWriter;     // Writes SignalBridge_<SYMBOL>.dat for SignalMarkers.mq5 to draw via PLOT_ARROW buffers
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
      //--- Fresh Trailing debug log every genuine EA Attach (Anhnt, 2026-09-10 - "PrintDebug ra file
      //--- để kiểm tra... Đừng ghi đè file cũ tạo mới luôn khi EA Attach") - NOT on a REASON_CHARTCHANGE
      //--- reinit, which fires on every native chart reload (e.g. SetActiveChartSymbolTF from Add TF)
      //--- and would wipe the log mid-session far more often than an actual Attach.
        if(_UninitReason != REASON_CHARTCHANGE)
         {
          string trailing_dbg_path = g_ea_folder + "/CTradingEngine_Debug_Trailing.log";
          if(::FileIsExist(trailing_dbg_path)) ::FileDelete(trailing_dbg_path);
          string bubble_dbg_path = g_ea_folder + "/CTradingLevelBubble_Debug.log";
          if(::FileIsExist(bubble_dbg_path)) ::FileDelete(bubble_dbg_path);
         }
        m_tradingEngine.OnInitEvent(); //For trading
        m_ChartObjCollection.CreateCollection();// For CChartObjCollection - MUST run before Manager's own OnInitEvent below (it scans this)
        m_IndicatorTemplateManager.OnInitEvent(&m_ChartObjCollection);//For Indicator Template Manager - loads JSON, then merges chart scan
        m_SymbolTFManager.OnInitEvent();//For Symbol+TF Manager
        m_TradingSetupManager.OnInitEvent();//For Trading Setup (StopLost/Trailing) Manager - loads "StopLost_Setting" from JSON
        m_timeSeriesEngine.SetSymbolsCollection(m_tradingEngine.GetSymbolsCollection());
        m_timeSeriesEngine.OnInitEvent(::Symbol(), (ENUM_TIMEFRAMES)::Period(), &m_SymbolTFManager, &m_IndicatorTemplateManager);
      //For CTradingEngine's own StopLost/Trailing Apply engine (moved from CGUIPannel, Anhnt/Claude, 2026-09-09)
        m_tradingEngine.SetTradingSetupManager(&m_TradingSetupManager);
        m_tradingEngine.SetIndicatorsCollection(m_timeSeriesEngine.GetIndicatorsCollection());
        m_tradingEngine.SetBarTimeSeriesCollection(m_timeSeriesEngine.GetTimeSeriesCollection());
      //For GUI. Set pointers before GUI init
        m_GUIPannel.SetIndicatorTemplateManager(&m_IndicatorTemplateManager);
        m_GUIPannel.SetSymbolTFManager(&m_SymbolTFManager);
        m_GUIPannel.SetTradingSetupManager(&m_TradingSetupManager);
        m_GUIPannel.SetSymbolsCollection(m_tradingEngine.GetSymbolsCollection());
        m_GUIPannel.SetTimeSeriesCollection(m_timeSeriesEngine.GetTimeSeriesCollection());
        m_GUIPannel.SetIndicatorsCollection(m_timeSeriesEngine.GetIndicatorsCollection());
        m_GUIPannel.SetSignalsCollection(m_timeSeriesEngine.GetSignalsCollection());
        m_GUIPannel.SetPatternsControl(m_timeSeriesEngine.GetPatternsControl());
        m_GUIPannel.SetSwingSetting(m_timeSeriesEngine.GetSwingSetting());
        //   //mGUIPannel.SetTickSeriesCollection(timeSeriesEngine.GetTickSeries());
        m_GUIPannel.SetMarketCollection(m_tradingEngine.GetMarketCollection());
        m_GUIPannel.SetTradingControl(m_tradingEngine.GetTradingControl());
        m_GUIPannel.SetChartObjCollection(&m_ChartObjCollection);
        m_GUIPannel.SetTradingEngine(&m_tradingEngine);   // display-only now - real StopLost/Trailing Apply logic lives in CTradingEngine itself
        m_GUIPannel.OnInitEvent(_UninitReason);  // GUIPannel tự xử lý CHARTCHANGE
        m_signalBridgeWriter.OnInitEvent(m_timeSeriesEngine.GetSignalsCollection(),
                                         m_timeSeriesEngine.GetIndicatorsCollection(),
                                         m_timeSeriesEngine.GetTimeSeriesCollection(),
                                         &m_IndicatorTemplateManager, &m_SymbolTFManager,
                                         m_timeSeriesEngine.GetPatternsControl(),
                                         m_timeSeriesEngine.GetSwingSetting());
        AttachMarkerIndicatorToChart();
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
       ::ChartIndicatorDelete(::ChartID(), 0, SIGNALMARKERS_NAME_TAG + "(" + ::Symbol() + ")");   // harmless if never attached
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
    if(any_new_bar)
       m_signalBridgeWriter.BuildAndWriteSignalBridge();   // push this chart's own new bar immediately - don't wait for the next OnTimer tick
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
    m_signalBridgeWriter.BuildAndWriteSignalBridge();   // incremental - writes only when something actually changed
    ulong t2 = GetMicrosecondCount();
    ulong t3 = GetMicrosecondCount();
  }
 //+------------------------------------------------------------------+
 //| Trade function                                                   |
 //+------------------------------------------------------------------+
 void OnTrade(void)
  {
    m_tradingEngine.OnTickEvent();
    m_GUIPannel.OnTradeEvent();
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
    m_signalBridgeWriter.OnChartEvent(id, lparam, dparam, sparam);
    if(id == CHARTEVENT_CUSTOM + INDICATOR_TEMPLATE_MANAGER_EVENT_ADDED)
     {
      // lparam is the row's TYPE (a value), not its list index - the Manager inserts sorted, so an
      // index could shift before this queued event is read. Walk every variant of that type and
      // attach whichever is flagged Show but not yet on the chart (already-shown ones are skipped).
      ENUM_INDICATOR type = (ENUM_INDICATOR)lparam;
      int tmpl_total = m_IndicatorTemplateManager.Total();
      for(int t = 0; t < tmpl_total; t++)
       {
        CIndicatorSetting *entry = m_IndicatorTemplateManager.At(t);
        if(entry == NULL || entry.TypeEnum() != type || !entry.ShowOnChart()) continue;
        MqlParam params[];
        entry.GetRawParams(params);
        if(!m_ChartObjCollection.IsIndicatorShownOnChart(::ChartID(), type, params))
           m_ChartObjCollection.ShowIndicatorOnChart(::ChartID(), type, params);
       }
      return;
     }
     if(id == CHARTEVENT_CUSTOM + INDICATOR_TEMPLATE_MANAGER_EVENT_SHOW_CHANGED)
      {
       CIndicatorSetting *entry = m_IndicatorTemplateManager.At((int)lparam);
       if(entry == NULL) return;
       ENUM_INDICATOR type = entry.TypeEnum();
       MqlParam params[];
       entry.GetRawParams(params);
       bool shown = m_ChartObjCollection.IsIndicatorShownOnChart(::ChartID(), type, params);
       if(entry.ShowOnChart() && !shown)
        {
         m_ChartObjCollection.ShowIndicatorOnChart(::ChartID(), type, params);
        }
       else if(!entry.ShowOnChart() && shown)
        {
         g_suppress_del_rescan = true;
         m_ChartObjCollection.RemoveIndicatorFromChart(::ChartID(), type, params);
        }
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
       // Identity travels in the event itself (sparam = symbol, lparam = tf) - no index lookup.
       if(sparam == "") return;
       m_ChartObjCollection.SetActiveChartSymbolTF(::ChartID(), sparam, (ENUM_TIMEFRAMES)lparam);
       return;
      }
     if(id == CHARTEVENT_CUSTOM + SYMBOLTF_MANAGER_EVENT_SETTING_CHANGED)
      {
       string parts[];
       int split_total = StringSplit(sparam, '|', parts);
       if(split_total != 2) return;
       ENUM_TIMEFRAMES new_tf = (ENUM_TIMEFRAMES)(int)(lparam >> 32);
       m_ChartObjCollection.SetActiveChartSymbolTF(::ChartID(), parts[1], new_tf);
       return;
      }
     if(id == CHARTEVENT_CUSTOM + GUIPANNEL_EVENT_MARKER_SETTING_CHANGED)
      {
       //--- Marker style (shape/color) was saved - re-attach SignalMarkers.mq5 with the new inputs
       //--- (iCustom's inputs are fixed at creation, so a style change means remove+recreate).
       ::ChartIndicatorDelete(::ChartID(), 0, SIGNALMARKERS_NAME_TAG + "(" + ::Symbol() + ")");
       AttachMarkerIndicatorToChart();
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
 void AttachMarkerIndicatorToChart(void)
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
    int swing_high, swing_low;
    color buy_clr, sell_clr, nonrelated_clr;
    m_GUIPannel.GetMarkerSettings(single_buy, single_sell, multi_buy, multi_sell,
                                  pattern_buy, pattern_sell, combo_buy, combo_sell,
                                  swing_high, swing_low,
                                  buy_clr, sell_clr, nonrelated_clr);

    // Positional - MUST match SignalMarkers.mq5's input declaration order exactly
    int h = ::iCustom(NULL, 0, SIGNALMARKERS_PROGRAM_PATH,
                      single_buy, single_sell, multi_buy, multi_sell,
                      pattern_buy, pattern_sell, combo_buy, combo_sell,
                      swing_high, swing_low,
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

   

