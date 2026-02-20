//+------------------------------------------------------------------+
//|                      SmarterTrade.mq5                           |
//|                      Main Expert Advisor                         |
//+------------------------------------------------------------------+
#property strict

//--------------------------------------------------
// GLOBAL PREFIX FOR ALL OBJECTS CREATED BY EA
//--------------------------------------------------
#define EMA_OBJ_PREFIX "SMARTER_"

//--------------------------------------------------
// Include configuration
//--------------------------------------------------
#include <Anhnt/Configuration/EnumConfiguration.mqh>
#include <Anhnt/Configuration/IndicatorConfiguration.mqh>
#include <Anhnt/Configuration/ColorConfiguration.mqh>

//--------------------------------------------------
// Include indicator helpers
//--------------------------------------------------
#include <Anhnt/Utilities/EMA_Anhnt_Display.mqh>
#include <Anhnt/Utilities/HighLow3Candle.mqh>

//+------------------------------------------------------------------+
//| Expert initialization                                           |
//+------------------------------------------------------------------+
int OnInit()
{
   Print("SmarterTrade INIT | Starting EA...");

   //--------------------------------------------------
   // INIT EMA (current chart timeframe only)
   //--------------------------------------------------
   AttachEMA_Anhnt_Display();
   
   //--------------------------------------------------
   // INIT HighLow3Candle system (multi-timeframe)
   //--------------------------------------------------
   InitHL3System();

   Print("SmarterTrade INIT | Completed successfully");
   return INIT_SUCCEEDED;
}

//+------------------------------------------------------------------+
//| Expert tick function                                            |
//+------------------------------------------------------------------+
void OnTick()
{
   

   //--------------------------------------------------
   // EMA has no OnTick logic here
   // Indicator updates itself
   //--------------------------------------------------
}

//+------------------------------------------------------------------+
//| Expert deinitialization                                         |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{
   Print("SmarterTrade DEINIT | Reason = ", reason);

   //--------------------------------------------------
   // Release EMA
   //--------------------------------------------------
   DetachEMA_Anhnt_Display();

   //--------------------------------------------------
   // Release HighLow3Candle
   //--------------------------------------------------
   ReleaseHL3System();

   //--------------------------------------------------
   // ChatGPT add here:
   // Delete all chart objects created by this EA
   //--------------------------------------------------
   int total = ObjectsTotal(0, 0, -1);
   for(int i = total - 1; i >= 0; i--)
   {
      string obj_name = ObjectName(0, i, 0, -1);
      if(StringFind(obj_name, EMA_OBJ_PREFIX) == 0)
      {
         ObjectDelete(0, obj_name);
      }
   }

   Print("SmarterTrade DEINIT | Cleanup completed");
}
