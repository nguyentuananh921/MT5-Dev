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
  //--- Layer 3 observer (Layer 3: Display On Chart, control by EA - README). Watches every open
  //--- chart's windows + their indicators and emits CHART_OBJ_EVENT_CHART_WND_IND_ADD/DEL/CHANGE.
  //--- EA owns/orchestrates it directly - CGUIPannel no longer controls Layer 3.
  #include <Vendors\Anhnt\Library\4. Combination Lib\Collections\ChartObjCollection.mqh>
   CChartObjCollection  m_ChartObjCollection;
  //--- Global folder path (centralized for all components)
   string g_ea_folder = "";
 //+------------------------------------------------------------------+
 //| Expert initialization function                                   |
 //+------------------------------------------------------------------+
 int OnInit(void)
   {      
      //--- Set the permissions to send cursor movement and mouse scroll events
        ChartSetInteger(ChartID(), CHART_EVENT_MOUSE_MOVE, true);
        ChartSetInteger(ChartID(), CHART_EVENT_MOUSE_WHEEL, true);
      //--- Initialize centralized folder path ONCE
        g_ea_folder = MQLInfoString(MQL_PROGRAM_NAME);
        Print(__FUNCTION__, "Debug EA::OnInit Folder initialized: ", g_ea_folder);      
        m_tradingEngine.OnInitEvent(); //For trading      
        m_IndicatorTemplateManager.OnInitEvent();//For Indicator Template Manager
        m_SymbolTFManager.OnInitEvent();//For Symbol+TF Manager      
        m_ChartObjCollection.CreateCollection();// For CChartObjCollection
        m_IndicatorTemplateManager.InitializeIndicatorTemplateManagerOnInit(&m_ChartObjCollection);
        m_timeSeriesEngine.SetSymbolsCollection(m_tradingEngine.GetSymbolsCollection());
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
      EventSetMillisecondTimer(16); 
      return (INIT_SUCCEEDED);
   }
 //+------------------------------------------------------------------+
 //| Expert deinitialization function                                 |
 //+------------------------------------------------------------------+
 void OnDeinit(const int reason)
  {
    m_GUIPannel.OnDeinitEvent(reason);
  }
 //+------------------------------------------------------------------+
 //| Expert tick function                                             |
 //+------------------------------------------------------------------+
 void OnTick(void)
  {
    m_tradingEngine.OnTickEvent();
    //For Bar
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
    m_ChartObjCollection.Refresh(); 
    ulong t0 = GetMicrosecondCount();
    
    m_GUIPannel.OnTimerEvent();
    
    ulong t1 = GetMicrosecondCount();
    
    m_timeSeriesEngine.OnTimerEvent();
    
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
    //Handle events from the Chart Window indicator objects (for manual changes)
     if(id == CHARTEVENT_CUSTOM + CHART_OBJ_EVENT_CHART_WND_IND_ADD)
      {       
       int handle = (int)lparam;
       ENUM_INDICATOR type; MqlParam params[];
       if(::IndicatorParameters(handle, type, params) < 0) return;               
       CIndicatorSetting *entry = m_IndicatorTemplateManager.FindByIdentity(type, params);
       if(entry != NULL)  //Add An Indicator exist in Indicator Template due to hide on Chart
        {
         // Go through the Manager's own setter (not a direct entry.ShowOnChart(true) mutation)
         // so it fires INDICATOR_TEMPLATE_MANAGER_EVENT_SETTING_CHANGED - CGUIPannel now
         // listens to that itself to refresh its Table icon, EA no longer calls it directly.
         if(!entry.ShowOnChart())
          {
           for(int row = 0; row < m_IndicatorTemplateManager.Total(); row++)
            {
             CIndicatorSetting *e = m_IndicatorTemplateManager.At(row);
             if(e == entry)
              {
               m_IndicatorTemplateManager.UpdateRow_IndicatorTemplateSetting_ShowColumn(row, true);
               break;
              }
            }
          }
         return;
        }
       // Manager.Add_IndicatorTemplateSetting() below fires INDICATOR_TEMPLATE_MANAGER_EVENT_ADDED
       // (+TYPE_ADDED if this is the first row of its type) - GUIPannel_Lifecycle.mqh already
       // reacts to those by calling InitializeTable_IndicatorTemplateSetting()/SyncTreeView_IndicatorTemplateSetting(), no need to call them here too.
       m_IndicatorTemplateManager.Add_IndicatorTemplateSetting(type, params);
       return;
      }
     if(id == CHARTEVENT_CUSTOM + CHART_OBJ_EVENT_CHART_WND_IND_CHANGE)
      {       
       int old_handle = (int)lparam;
       int win_num    = (int)dparam;
       int win_index  = (int)StringToInteger(sparam);

       ENUM_INDICATOR old_type; MqlParam old_params[];
       if(::IndicatorParameters(old_handle, old_type, old_params) < 0) return;   //Get Old value
       // Print Debug
         Print("MY DEBUG EA::OnChartEvent CHANGE: old handle=", old_handle, " win_num=", win_num, " index=", win_index);

       CWndInd *new_ind = m_ChartObjCollection.GetIndicator(::ChartID(), win_num, win_index);
       if(new_ind == NULL) return;
       // Print Debug
         Print("MY DEBUG EA::OnChartEvent CHANGE: new name=", new_ind.Name(), " handle=", new_ind.Handle());

       ENUM_INDICATOR new_type; MqlParam new_params[];
       if(!new_ind.GetIdentity(new_type, new_params)) return; //Get New value

       // --- Check TRUOC khi Remove: neu new_type/new_params da trung 1 identity KHAC
       // --- dang co san trong Template (vd user sua tham so indicator A trung het voi
       // --- indicator B da co), thi khong the Add duoc nua (Manager tu chan trung) -
       // --- neu cu Remove old truoc thi ket qua la MAT han A khoi Template ma khong co
       // --- gi thay the. Bail o day, giu nguyen old, khong dung gi ca.
       if(m_IndicatorTemplateManager.Exists(new_type, new_params))
        {
         Print("MY DEBUG EA::OnChartEvent CHANGE: new params trung 1 identity khac da co trong Template - bo qua, giu nguyen old");
         return;
        }

       // Both fire their own INDICATOR_TEMPLATE_MANAGER_EVENT_* below - GUIPannel_Lifecycle.mqh
       // already reacts by calling InitializeTable_IndicatorTemplateSetting()/SyncTreeView_IndicatorTemplateSetting(),
       // no need to call them here too (and TYPE_ADDED/TYPE_DELETE correctly stay silent
       // when old_type == new_type, unlike the old unconditional Sync call).
       m_IndicatorTemplateManager.Delete_IndicatorTemplateSetting(old_type, old_params); //Remove Old value
       m_IndicatorTemplateManager.Add_IndicatorTemplateSetting(new_type, new_params); //Add New value
       return;
      }
     if(id == CHARTEVENT_CUSTOM + CHART_OBJ_EVENT_CHART_WND_IND_DEL)
      {
        // Print Debug
          Print("MY DEBUG EA::OnChartEvent DEL: win_num=", (int)dparam);
        // Native DEL event doesn't say WHICH indicator was removed - live-scan every
        // row against real chart state and push the truth into Manager (EA owns
        // ChartObjCollection, CGUIPannel no longer can). SyncTable_IndicatorTemplateSetting()
        // below then just repaints from Manager's now-correct field.
        for(int row = 0; row < m_IndicatorTemplateManager.Total(); row++)
         {
          CIndicatorSetting *entry = m_IndicatorTemplateManager.At(row);
          if(entry == NULL) continue;
          MqlParam params[];
          entry.GetRawParams(params);
          bool shown = m_ChartObjCollection.IsIndicatorShownOnChart(::ChartID(), entry.TypeEnum(), params);
          if(shown != entry.ShowOnChart())
             m_IndicatorTemplateManager.UpdateRow_IndicatorTemplateSetting_ShowColumn(row, shown);
         }
        // No direct m_GUIPannel call here anymore - UpdateRow_IndicatorTemplateSetting_ShowColumn()
        // above fires INDICATOR_TEMPLATE_MANAGER_EVENT_SETTING_CHANGED per changed row, and
        // CGUIPannel now listens to that itself to refresh its Table icon.
        return;
      }
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
       if(!m_ChartObjCollection.IsIndicatorShownOnChart(::ChartID(), type, params))
          m_ChartObjCollection.ShowIndicatorOnChart(::ChartID(), type, params);
       return;
      }
    //User toggled the Table's Show-on-Chart icon for an existing row - Manager
    //already updated entry.ShowOnChart(), EA attaches/detaches to match.
     if(id == CHARTEVENT_CUSTOM + INDICATOR_TEMPLATE_MANAGER_EVENT_SETTING_CHANGED)
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
         m_ChartObjCollection.RemoveIndicatorFromChart(::ChartID(), type, params);
        }
       else
         Print("MY DEBUG EA::OnChartEvent SHOW_CHANGED: -> no-op (already matches)");
       ChartRedraw();
       return;
      }
    //A Template row was removed - the row is already gone from Manager by the time this
    //(async) event is processed, so read the snapshot GetLastRemoved() cached BEFORE the
    //delete instead of trying to look the row up.
     if(id == CHARTEVENT_CUSTOM + INDICATOR_TEMPLATE_MANAGER_EVENT_DELETE)
      {
       ENUM_INDICATOR type; MqlParam params[];
       m_IndicatorTemplateManager.GetLastRemoved(type, params);
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
   if(chart.Timeframe() != tf) chart.SetTimeframe(tf);
   if(chart.Symbol() != sym) chart.SetSymbol(sym);
  }
