//+------------------------------------------------------------------+
//|                                                 SmarterTrade.mq5 |
//|                                  Copyright 2026, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
// Include configuration
//--------------------------------------------------
#include <Anhnt/Configuration/EnumConfiguration.mqh>
#include <Anhnt/Configuration/IndicatorConfiguration.mqh>
#include <Anhnt/Configuration/ColorConfiguration.mqh>
#include <Anhnt/Configuration/NamingConfiguration.mqh>
//#include <Anhnt/State/ChartState.mqh>
#include <Anhnt/Utilities/timeframe.mqh>

//For UI
#include <Anhnt/DashBoard/UIHelper.mqh>

// Include Indicator
//--------------------------------------------------
#include <Anhnt/Indicators/EMA_Display.mqh>
#include <Anhnt/Indicators/HighLow3Candle.mqh>
#include <Anhnt/Indicators/iBand_Display.mqh>

CUIHelper   m_uihelper;
ENUM_TIMEFRAMES g_last_chart_tf = PERIOD_CURRENT;

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {   
   g_last_chart_tf = (ENUM_TIMEFRAMES)_Period;  
   Print("SmarterTrade INIT | Starting EA...");
   //For UI
   if(!m_uihelper.Init()) return(INIT_FAILED);  
   
  
   //--------------------------------------------------
   // INIT EMA (current chart timeframe only) force to draw at first
   //--------------------------------------------------
   if(!EMA_InitLogicHandles()) return INIT_FAILED;
   if(!EMA_InitVisualHandles())return INIT_FAILED; 
   if(!BB_InitLogicHandles()) return INIT_FAILED;  //BoillingerBand Logic Part  
   if(!BB_InitVisualHandle()) return INIT_FAILED;  //BoillingerBand Visual   
  
   //--------------------------------------------------
   // INIT HighLow3Candle system (multi-timeframe) force to draw at first
   //--------------------------------------------------
   UpdateHL3_System();   
   Print("SmarterTrade INIT | Completed successfully");
   //---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
  
   ReleaseHL3System();   
   EMA_Deinit();
   BB_Deinit(); 
   m_uihelper.Destroy();
   
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {  
   m_uihelper.Update();
   UpdateHL3_Visual();      //sync label with price   
   //EMA_UpdateVisual();     
  //---
   
  }
//+------------------------------------------------------------------+
//| Timer function                                                   |
//+------------------------------------------------------------------+
void OnTimer()
  {  
   EventKillTimer();

   
//---
   
  }
//+------------------------------------------------------------------+
//| Trade function                                                   |
//+------------------------------------------------------------------+
void OnTrade()
  {
//---
   
  }
//+------------------------------------------------------------------+
//| TradeTransaction function                                        |
//+------------------------------------------------------------------+
void OnTradeTransaction(const MqlTradeTransaction& trans,
                        const MqlTradeRequest& request,
                        const MqlTradeResult& result)
  {
//---
   
  }
//+------------------------------------------------------------------+
//| Tester function                                                  |
//+------------------------------------------------------------------+
double OnTester()
  {
//---
   double ret=0.0;
//---

//---
   return(ret);
  }
//+------------------------------------------------------------------+
//| TesterInit function                                              |
//+------------------------------------------------------------------+
void OnTesterInit()
  {
//---
   
  }
//+------------------------------------------------------------------+
//| TesterPass function                                              |
//+------------------------------------------------------------------+
void OnTesterPass()
  {
//---
   
  }
//+------------------------------------------------------------------+
//| TesterDeinit function                                            |
//+------------------------------------------------------------------+
void OnTesterDeinit()
  {
//---
   
  }
//+------------------------------------------------------------------+
//| ChartEvent function                                              |
//+------------------------------------------------------------------+
void OnChartEvent(const int32_t id,
                  const long &lparam,
                  const double &dparam,
                  const string &sparam)
  {
//---
   m_uihelper.OnEvent(id,lparam,dparam,sparam);
  }
//+------------------------------------------------------------------+
//| BookEvent function                                               |
//+------------------------------------------------------------------+
void OnBookEvent(const string &symbol)
  {
//---
   
  }
//+------------------------------------------------------------------+
