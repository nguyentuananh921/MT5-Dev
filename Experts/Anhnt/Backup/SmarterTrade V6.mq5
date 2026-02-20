//+------------------------------------------------------------------+
//|                                                 SmarterTrade.mq5 |
//|                                  Copyright 2026, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+

//This is EA SmarterTrade.mq5
#include <Anhnt/Configuration/EnumConfiguration.mqh>
#include <Anhnt/Configuration/ColorConfiguration.mqh>
#include <Anhnt/Configuration/IndicatorConfiguration.mqh>


#include <Anhnt/Utilities/BarUtilities.mqh>
#include <Anhnt/Utilities/HighLow3Candle.mqh>
#include <Anhnt/Utilities/PriceUtilities.mqh>
#include <Anhnt/Utilities/EMA.mqh> 

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
   ObjectsDeleteAll(0, "HL3_");
   // initialize last bar times for each supported timeframe   
   InitHL3System();

   // FirtTime Drawing
   for(int i = 0; i < g_num_supported_timeframes; i++)
   {
      DrawHL3Lines(i);
   }
   InitEMAAllTimeFrames();    
   //--- create timer
   EventSetTimer(10);
   
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//--- destroy timer
   EventKillTimer();
   
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  { 
  
    for(int i = 0; i < g_num_supported_timeframes; i++)
    {
        // Only draw if new bar appears on this timeframe
      if(IsNewBar(g_supported_timeframes[i], i))
      {
        // Draw High/Low lines for all configured timeframes with user-defined color, width, and style
        DrawHL3Lines(i);
      };
    }
    
    if(IsNewBar(_Period, 0))
      {
         DrawEMA_CurrentTimeFrame();
      }
     
  
   
//---
   
  }
//+------------------------------------------------------------------+
//| Timer function                                                   |
//+------------------------------------------------------------------+
void OnTimer()
  {
   // --- EMA: Only Draw EMA for Current TimeFrame
   int idx = GetCurrentTimeFrameIndex();
   if(idx < 0) return;
   
   if(inp_EMA_Update_OnClosedBar)
   {
      if(IsNewBar(g_supported_timeframes[idx], idx))
         DrawEMA_CurrentTimeFrame();
   }
   else
   {
      DrawEMA_CurrentTimeFrame(); // live EMA
   }   
   
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
   ReleaseHL3Handles();
   ReleaseEMAAllTimeFrames();
   
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
   
  }
//+------------------------------------------------------------------+
//| BookEvent function                                               |
//+------------------------------------------------------------------+
void OnBookEvent(const string &symbol)
  {
//---
   
  }
//+------------------------------------------------------------------+
