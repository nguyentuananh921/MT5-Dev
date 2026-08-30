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
  //--- Writes SignalBridge_<SYMBOL>.dat so SignalMarkers.mq5 can paint markers on chart per the
  //--- GUI's Buy/Sell settings. EA-owned (moved from CGUIPannel, Anhnt 2026-08-26) - reads
  //--- m_IndicatorTemplateManager/m_SymbolTFManager/Pattern registry LIVE via SetManagers(), no copy needed.
  #include "Services\SignalBridgeWriter.mqh"
   CSignalBridgeWriter  m_signal_bridge_writer;
  //--- Layer 3 observer (Layer 3: Display On Chart, control by EA - README). Watches every open
  //--- chart's windows + their indicators and emits CHART_OBJ_EVENT_CHART_WND_IND_ADD/DEL/CHANGE.
  //--- EA owns/orchestrates it directly - CGUIPannel no longer controls Layer 3.
  #include <Vendors\Anhnt\Library\4. Combination Lib\Collections\ChartObjCollection.mqh>
   CChartObjCollection  m_ChartObjCollection;
  //--- Global folder path (centralized for all components)
   string g_ea_folder = "";
  //--- SIGNALMARKERS_PROGRAM_PATH/SIGNALMARKERS_NAME_TAG moved to IndicatorTemplateManager.mqh
  //--- (Anhnt, 2026-08-30) - that Manager now owns filtering it out of its own OnChartEvent();
  //--- still visible here too (EnsureMarkerIndicatorAttached/RemoveMarkerIndicator use it) since
  //--- that header is #included above, before this point.
  //--- true once OnInit() has fully finished wiring every module - false while EA is still
  //--- initializing (including every REASON_CHARTCHANGE reinit, MT5 calls OnInit again on
  //--- every Symbol/TF change). Every Manager checks this before firing its own EventChartCustom -
  //--- native chart state (indicators on the chart) can still be settling right after attach/reinit,
  //--- and Layer 3's own baseline-vs-live diff (m_ChartObjCollection.Refresh()) can misfire a
  //--- spurious ADD/DELETE/CHANGE during that window if nothing holds it back (Anhnt, 2026-08-28).
   bool g_ea_init_done = false;
  //--- true right after EA itself calls RemoveIndicatorFromChart (reacting to ITS OWN Data
  //--- change, e.g. Show-toggle/row delete) - the resulting native ChartIndicatorDelete() fires
  //--- the SAME CHART_OBJ_EVENT_CHART_WND_IND_DEL a genuinely MANUAL chart-side removal would,
  //--- but EA already knows exactly what changed here, no need for that handler's defensive
  //--- full-table rescan. Without this, an immediate IsIndicatorShownOnChart() re-check for
  //--- OTHER untouched rows (right after this native delete) can misread them as also gone
  //--- (BugNote 2026-08-28: "Setting Window treo cứng" - removing 1 row cascaded into removing
  //--- every other shown row, one per native DEL round-trip, ~1s apart).
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
      // --- Layer 1 Oninit: cho ca doi EA - tao Series cho tung Symbol+TF da co trong
      // --- m_SymbolTFManager, roi apply toan bo Indicator Template len tung Series do
      // --- (Single Source of Truth, hai Manager da OnInitEvent xong o tren) - background
      // --- computation cho ca cac symbol khac ngoai chart dang active (Anhnt, 2026-08-28).
        m_timeSeriesEngine.OnInitEvent(::Symbol(), (ENUM_TIMEFRAMES)::Period(), &m_SymbolTFManager, &m_IndicatorTemplateManager);

      // --- SignalBridgeWriter: wire AFTER Layer 1 is ready (needs live Signals/Indicators/
      // --- BarTimeSeries collections) - reads the 2 Managers + the Pattern registry LIVE from
      // --- here on, no copy/snapshot needed (Anhnt, 2026-08-29).
        CSignalBridgeWriter::SetFolder(g_ea_folder);
        m_signal_bridge_writer.Initialize(m_timeSeriesEngine.GetSignalsCollection(),
                                           m_timeSeriesEngine.GetIndicatorsCollection(),
                                           m_timeSeriesEngine.GetTimeSeriesCollection());
        m_signal_bridge_writer.SetManagers(&m_IndicatorTemplateManager, &m_SymbolTFManager, m_timeSeriesEngine.GetPatternsControl());

      //For GUI. Set pointers before GUI init - SetTimeSeriesEngine MUST run before
        m_GUIPannel.SetIndicatorTemplateManager(&m_IndicatorTemplateManager);
        m_GUIPannel.SetSymbolTFManager(&m_SymbolTFManager);        
        m_GUIPannel.SetSymbolsCollection(m_tradingEngine.GetSymbolsCollection());
        m_GUIPannel.SetTimeSeriesCollection(m_timeSeriesEngine.GetTimeSeriesCollection());
        m_GUIPannel.SetIndicatorsCollection(m_timeSeriesEngine.GetIndicatorsCollection());
        m_GUIPannel.SetTimeSeriesEngine(&m_timeSeriesEngine);   // Tang 2 forwards "Add" clicks to Tang 1
        m_GUIPannel.SetPatternsControl(m_timeSeriesEngine.GetPatternsControl());        
        //   //mGUIPannel.SetTickSeriesCollection(timeSeriesEngine.GetTickSeries());
        //   mGUIPannel.SetMarketCollection(tradingEngine.GetMarketCollection());
        m_GUIPannel.SetTradingControl(m_tradingEngine.GetTradingControl());        
        m_GUIPannel.OnInitEvent(_UninitReason);  // GUIPannel tự xử lý CHARTCHANGE
      // --- Seed the bridge file for the very first time this session - m_signal_bridge_writer
      // --- now reads Pattern Buy/Sell straight off m_patterns_control (live), no snapshot push
      // --- needed first (Anhnt, 2026-08-29).
        m_signal_bridge_writer.ResetSignalBridge();
      // --- Idempotent (checks m_ChartObjCollection's own cached window/indicator list first) -
      // --- safe to call unconditionally on both a fresh attach and a REASON_CHARTCHANGE reinit,
      // --- SignalMarkers.mq5 survives a reinit on its own so this is just a defensive re-check
      // --- (Anhnt, 2026-08-28).
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
    // SignalMarkers.mq5 survives a REASON_CHARTCHANGE reinit on its own (independent chart
    // program) - only detach on a real removal, matching EnsureMarkerIndicatorAttached()'s
    // own idempotent re-check on the OnInit() side (Anhnt, 2026-08-28).
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

    // Self-guarded via watermark (newest_seen <= m_signal_bridge_last_time -> early return) -
    // cheap to call unconditionally every tick, picks up naturally-arriving new bars/patterns
    // without needing its own dirty flag (Anhnt, 2026-08-28).
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
    // --- Broadcast to CTimeSeriesEngine (Anhnt, 2026-08-30): "tay nao lo viec tay ay" - EA just
    // --- forwards the raw event, CTimeSeriesEngine::OnChartEvent() filters for CHARTEVENT_CHART_CHANGE
    // --- internally and owns its own reaction (create the new Series if this Symbol/TF hasn't been
    // --- seen yet). Was previously dead code - nothing called it, so a native chart Symbol/TF switch
    // --- (as opposed to adding a row via the GUI's own Symbol-TF tab, or the initial OnInit load)
    // --- never created its Series. IsAvailable()-gated internally, safe to call unconditionally
    // --- even during a REASON_CHARTCHANGE reinit alongside OnInitEvent()'s own CreateSeries pass.
     m_timeSeriesEngine.OnChartEvent(id, lparam, dparam, sparam, &m_SymbolTFManager, &m_IndicatorTemplateManager);
    // --- Broadcast to CIndicatorTemplateManager (Anhnt, 2026-08-30): same "tay nao lo viec tay ay"
    // --- pattern - CIndicatorTemplateManager::OnChartEvent() filters for
    // --- CHART_OBJ_EVENT_CHART_WND_IND_ADD/CHANGE/DEL internally and owns the whole reaction
    // --- (resolve handle->type/params, skip its own SignalMarkers infrastructure indicator,
    // --- otherwise mark an existing row Shown / add a brand new one / swap old identity for new /
    // --- rescan Show state after a native delete). chart_obj is passed through for CHANGE's own
    // --- GetIndicator() lookup and DEL's rescan. Moved out of this function, which used to do all
    // --- of this inline.
     m_IndicatorTemplateManager.OnChartEvent(id, lparam, dparam, sparam, &m_ChartObjCollection);
    //Manager's own Data-changed notification - EA owns ChartObjCollection, so EA (not
    //CGUIPannel) is the one that attaches a newly-Added template row onto the chart.
    //IsIndicatorShownOnChart guards the case where this Add() came FROM a manual
    //chart-side add (CHART_OBJ_EVENT_CHART_WND_IND_ADD above already put it on chart) -
    //without it that path would re-add and duplicate the indicator.
     if(id == CHARTEVENT_CUSTOM + INDICATOR_TEMPLATE_MANAGER_EVENT_ADDED)
      {
       CIndicatorSetting *entry = m_IndicatorTemplateManager.At((int)lparam);
       if(entry == NULL) return;
       ENUM_INDICATOR type = entry.TypeEnum();
       MqlParam params[];
       entry.GetRawParams(params);
      // Layer 1 backfill (AddNewIndicatorToAllSeries) moved to CTimeSeriesEngine::OnChartEvent()
      // (Anhnt, 2026-08-30) - reached via this same broadcast event, no separate call needed here.
       if(!m_ChartObjCollection.IsIndicatorShownOnChart(::ChartID(), type, params))
          m_ChartObjCollection.ShowIndicatorOnChart(::ChartID(), type, params);
       return;
      }
    //User toggled the Table's Show-on-Chart icon for an existing row - Manager
    //already updated entry.ShowOnChart(), EA attaches/detaches to match.
    // --- Own dedicated event now (Anhnt, 2026-08-30), split out of the old generic
    // --- SETTING_CHANGED - "tay nao lo viec tay ay": this handler only cares about Show, so it
    // --- no longer wakes up (and no-ops through) on every unrelated Buy/Sell toggle, and no
    // --- longer force-rebuilds SignalBridge for a Show-only change that never touched Buy/Sell.
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
    //User toggled Buy or Sell on the Table for an existing row - only SignalBridge needs to
    //react (Anhnt, 2026-08-30, split out of the old generic SETTING_CHANGED).
     if(id == CHARTEVENT_CUSTOM + INDICATOR_TEMPLATE_MANAGER_EVENT_BUYSELL_CHANGED)
      {
       m_signal_bridge_writer.ResetSignalBridge();
       return;
      }
    //A Template row was removed - the row is already gone from Manager by the time this
    //(async) event is processed, so read the snapshot GetLastRemoved() cached BEFORE the
    //delete instead of trying to look the row up.
     if(id == CHARTEVENT_CUSTOM + INDICATOR_TEMPLATE_MANAGER_EVENT_DELETE)
      {
       ENUM_INDICATOR type; MqlParam params[];
       m_IndicatorTemplateManager.GetLastRemoved(type, params);
       g_suppress_del_rescan = true;
       m_ChartObjCollection.RemoveIndicatorFromChart(::ChartID(), type, params);
       ChartRedraw();
       return;
      }
    //A Symbol+TF row was added to the Manager - same behavior V9 had (CGUIPannel there called
    //ChartSetSymbolPeriod(0,...) directly), just moved to EA per V10's "CGUIPannel never
    //touches Chart" split, and going through m_ChartObjCollection's own wrappers instead of
    //a raw native call. Sets THIS EA's own active chart to (sym,tf) - no separate chart
    //window opened (multi-chart-per-symbol idea parked, see Implementaion Plan\MultiSymbolChart.md).
     if(id == CHARTEVENT_CUSTOM + SYMBOLTF_MANAGER_EVENT_ADDED)
      {
       CSymbolTFSetting *entry = m_SymbolTFManager.At((int)lparam);
       if(entry == NULL) return;
       // --- Manual Series-creation block removed (Anhnt, 2026-08-30) - SetActiveChartSymbolTF()
       // --- below calls ::ChartSetSymbolPeriod(), which is itself a full chart reinit that fires
       // --- native CHARTEVENT_CHART_CHANGE; CTimeSeriesEngine::OnChartEvent() already reacts to
       // --- that by creating the Series (+ patterns + indicator template) if not yet available,
       // --- so doing it here too was pure duplication of that same logic.
       SetActiveChartSymbolTF(entry.Symbol(), entry.TFEnum());
       return;
      }
    //User clicked an already-tracked TF node in CGUIPannel's TreeView - pure navigation
    //intent, no row Add/Delete involved, so m_SymbolTFManager.NotifySettingChanged() fired this
    //(no Data mutation) instead of a real Add/Delete call. Same single event chain as everything
    //else Symbol+TF related - EA never needs to listen to a separate CGUIPannel-owned event.
    //Payload is packed (see NotifySettingChanged): sparam="old_sym|new_sym", lparam=old_tf in the
    //low 32 bits, new_tf in the high 32 bits - old half unused here, reserved for future
    //consumers (CSignalBridgeWriter/CSignalLogger) that need to know what was just left too.
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
    //A Symbol+TF row's Buy/Sell setting was toggled - fired directly by CGUIPannel (no
    //Manager method, no payload - see SymbolTFManager.mqh's enum comment). Force an
    //immediate bridge rewrite; ResetSignalBridge() re-reads the Manager live, no row lookup needed.
     if(id == CHARTEVENT_CUSTOM + SYMBOLTF_MANAGER_EVENT_BUYSELL_CHANGED)
      {
       m_signal_bridge_writer.ResetSignalBridge();
       return;
      }
    //Candle Pattern Buy/Sell was toggled - CBarPatternControl now fires this itself (Anhnt,
    //2026-08-30, own event chain in BarPatternControl.mqh - no longer via CGUIPannel). It IS the
    //same registry SignalBridgeWriter reads live (SetManagers()'s 3rd pointer), same as the 2
    //Manager-backed sources above - just force an immediate rewrite (Anhnt, 2026-08-29).
     if(id == CHARTEVENT_CUSTOM + BARPATTERN_CONTROL_EVENT_BUYSELL_CHANGED)
      {
       m_signal_bridge_writer.ResetSignalBridge();
       return;
      }
    //Marker style (shape/color) was saved - detach + re-attach SignalMarkers.mq5 with the
    //new inputs (no live-input-update API for a running custom indicator).
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
  //+------------------------------------------------------------------+
  //| Attaches SignalMarkers.mq5 to this chart if not already running   |
  //| (checked by short name via m_ChartObjCollection's own cached      |
  //| window/indicator list) - idempotent, safe to call defensively.    |
  //| Moved here from CGUIPannel (Anhnt, 2026-08-28) - this is chart-    |
  //| level Layer 3 work, same reasoning as ShowIndicatorOnChart/        |
  //| RemoveIndicatorFromChart already living in EA, not CGUIPannel.     |
  //+------------------------------------------------------------------+
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
  //+------------------------------------------------------------------+
  //| Detaches SignalMarkers.mq5 - ChartIndicatorAdd() made it an       |
  //| independent chart program, survives EA removal unless detached.   |
  //| Deletes by deterministic name directly, NOT via m_ChartObjCollection|
  //| - BugNote 2026-07-18: during OnDeinit, while this chart's own      |
  //| program is mid-removal, BOTH the native ChartIndicatorsTotal() scan|
  //| AND m_ChartObjCollection's own cache can read stale/empty, so no   |
  //| enumeration-based lookup is trustworthy here.                      |
  //+------------------------------------------------------------------+
  void RemoveMarkerIndicator(void)
   {
    ::ChartIndicatorDelete(::ChartID(), 0, SIGNALMARKERS_NAME_TAG + "(" + ::Symbol() + ")");
   }  
 
   

