//+------------------------------------------------------------------+
//|                                                           EA.mq5 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|EA Code Base on https://www.mql5.com/en/articles/4727             |
//|Library base on Link https://www.mql5.com/en/code/19703           |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link "http://www.mql5.com"
#property version "1.00"
//--- Include application class
// #include "MainProgram.mqh"
// CMainProgram mainProgram;

 //For GUI
  #include "\Anatoli Kazharski\GUIPannel.mqh"
  CGUIPannel mGUIPannel;
  #include <..\Artyom Trishkin\TradingEngine.mqh>
  CTradingEngine tradingEngine;
//For CBar Use InfoPannel Instead
  #include <..\Artyom Trishkin\TimeSeriesEngine.mqh>
    CTimeSeriesEngine timeSeriesEngine;
//For Candle Pattern Render
  #include <Vendors\Anhnt\Library\4. Combination Lib\Graph\Timeseries\PatternRenderer.mqh>
    CPatternRenderer patternRenderer;
    static bool s_need_tree_refresh = false;
 //+------------------------------------------------------------------+
 //| Expert initialization function                                   |
 //+------------------------------------------------------------------+
 int OnInit(void)
   {      
      // For debug.
        //Print(__FUNCTION__, " My Debug EA:OnInit _UninitReason=", _UninitReason);
      //--- Set the permissions to send cursor movement and mouse scroll events
              ChartSetInteger(ChartID(), CHART_EVENT_MOUSE_MOVE, true);
              ChartSetInteger(ChartID(), CHART_EVENT_MOUSE_WHEEL, true);
      if(_UninitReason == REASON_CHARTCHANGE) 
        s_need_tree_refresh = true;
      //For Trading
          tradingEngine.OnInitEvent();
      // Init timeseries engine first
      //  First attach only: set symbols, init engine, scan, fill table, init renderer
          timeSeriesEngine.SetSymbolsCollection(tradingEngine.GetSymbolsCollection());
          timeSeriesEngine.OnInitEvent(Symbol(), Period());
      //For GUI.Now set both pointers before GUI init              
        mGUIPannel.SetSymbolsCollection(tradingEngine.GetSymbolsCollection());
        mGUIPannel.SetTimeSeriesCollection(timeSeriesEngine.GetTimeSeriesCollection());
        mGUIPannel.SetIndicatorsCollection(timeSeriesEngine.GetIndicatorsCollection());
        mGUIPannel.SetMarketCollection(tradingEngine.GetMarketCollection());
        mGUIPannel.SetTradingControl(tradingEngine.GetTradingControl()); 
        // GUI init: m_symbols và m_timeseries đều đã có
          mGUIPannel.OnInitEvent(_UninitReason);        
      //For patternRenderer
        patternRenderer.OnInitEvent(ChartID(), 0, Symbol(), Period(), _UninitReason);
        mGUIPannel.SetPatternRenderer(&patternRenderer);        
        CArrayObj *plist = timeSeriesEngine.GetTimeSeriesCollection().GetListAllPatterns();
        if(plist != NULL) patternRenderer.Refresh(plist,true,true);
      EventSetMillisecondTimer(16);    
    return (INIT_SUCCEEDED);
   }

 //+------------------------------------------------------------------+
 //| Expert deinitialization function                                 |
 //+------------------------------------------------------------------+
 void OnDeinit(const int reason)
  {
    //  mainProgram.OnDeinitEvent(reason);
    //For Debug
      Print(__FUNCTION__, "My Debug EA::OnDeinit reason=", reason,
          " CHARTCHANGE=", REASON_CHARTCHANGE,
          " RECOMPILE=", REASON_RECOMPILE);
    //For GUIPannel And CPatternRenderer Skip destroy when TF Change
    if(reason != REASON_CHARTCHANGE)
    {
        mGUIPannel.OnDeinitEvent(reason);          
        CArrayObj *plist = timeSeriesEngine.GetTimeSeriesCollection().GetListAllPatterns();
        patternRenderer.OnDeinitEvent(plist);
    }     
  }
 //+------------------------------------------------------------------+
 //| Expert tick function                                             |
 //+------------------------------------------------------------------+
 void OnTick(void)
  {
    tradingEngine.OnTickEvent();
    //For Bar
    //  Refresh pattern renderer on new bar
      SDataCalculate data_calc;
      MqlRates rates[1];
      if(::CopyRates(Symbol(), PERIOD_CURRENT, 0, 1, rates) == 1)
      {
          data_calc.rates         = rates[0];
          data_calc.rates_total   = ::Bars(Symbol(), PERIOD_CURRENT);
      }
    //--- sync ALL TFs + race condition fix (returns true if new scan happened)
      bool any_new_bar = timeSeriesEngine.OnTickEvent(Symbol(), data_calc);
      if(any_new_bar&& s_need_tree_refresh)
        {
          mGUIPannel.RefreshGUI();
          s_need_tree_refresh = false;
        }         
      if(any_new_bar)
        {
            CArrayObj *plist = timeSeriesEngine.GetTimeSeriesCollection().GetListAllPatterns();
            if(plist != NULL) patternRenderer.UpdateNew(plist, true, false);
        }         
     //::ChartRedraw(ChartID());
  }

 //+------------------------------------------------------------------+
 //| Timer function                                                   |
 //+------------------------------------------------------------------+
 void OnTimer(void) 
  {
    mGUIPannel.OnTimerEvent();
  }
 //+------------------------------------------------------------------+
 //| Trade function                                                   |
 //+------------------------------------------------------------------+
 void OnTrade(void) 
  {
    
  }
 //+------------------------------------------------------------------+
 //| ChartEvent function                                              |
 //+------------------------------------------------------------------+
 void OnChartEvent(const int id, const long &lparam, const double &dparam,
                  const string &sparam)
  {
    //--- If working in the tester, exit
        if(MQLInfoInteger(MQL_TESTER))
            return;
    //For TimeSeriesEngine must before mGUIPannel ChartEvent to UpdateTreeNodeStates and before patternRenderer ChartEvent to UpdateNewPatterns
      timeSeriesEngine.OnChartEvent(id, lparam, dparam, sparam);    
    //For GUI     
     mGUIPannel.ChartEvent(id, lparam, dparam, sparam); 
    // For PatternRender
      // 2. Renderer after: plist already has new patterns if any were added
      CArrayObj *plist = timeSeriesEngine.GetTimeSeriesCollection().GetListAllPatterns();
      patternRenderer.OnChartEvent(id, plist);        
  }
 //+------------------------------------------------------------------+
 //| Tester function                                                  |
 //+------------------------------------------------------------------+
 double OnTester(void) 
  {
  // return (mainProgram.OnTesterEvent());
  return true;
  }
 void OnTradeTransaction(const MqlTradeTransaction& trans,
                        const MqlTradeRequest& request,
                        const MqlTradeResult& result)
  {
    //mGUIPannel.UpdateTableAccountInfoDynamic();
  }
