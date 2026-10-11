//+------------------------------------------------------------------+
//|                                             EA_Trailing_Demo.mq5 |
//|                                  Copyright 2026, MetaQuotes Ltd. |
//|Link                      https://www.mql5.com/en/articles/23910  |
//+------------------------------------------------------------------+
#property copyright "Open Source"
#property version   "2.10"

#include <Trade\Trade.mqh>
#include <Trailing_Engine\Trailing_Engine.mqh>

//--- Input Parameters
input int    InpTRPeriod       = 14;        // Simple TR Calculation Period
input double InpTRMultiplier   = 2.0;       // Volatility Multiplier
input int    InpMinStepPoints  = 10;        // Minimum Modification Step (Points)
input ulong  InpMagicNumber    = 20260802;  // Expert Magic Number
input bool   InpOnlyInProfit   = true;      // Trail only after breakeven

CVolatilityTrailing *g_trailing;

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
   g_trailing = new CVolatilityTrailing(_Symbol, PERIOD_CURRENT, InpTRPeriod, InpTRMultiplier, InpMinStepPoints, InpMagicNumber, InpOnlyInProfit);
   if(g_trailing == NULL) return INIT_FAILED;

   return INIT_SUCCEEDED;
  }

//+------------------------------------------------------------------+
//| Expert deinitialization function with Telemetry Output           |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   if(CheckPointer(g_trailing) == POINTER_DYNAMIC)
     {
      TrailingTelemetry stats = g_trailing.GetTelemetry();
      Print("=== Trailing Engine Verification Telemetry ===");
      PrintFormat("Total Evaluations:        %d", stats.total_evaluations);
      PrintFormat("Modifications Confirmed:  %d", stats.modifications_sent);
      PrintFormat("Skipped (Min Step):       %d", stats.skipped_min_step);
      PrintFormat("Skipped (Open Price):     %d", stats.skipped_open_price);
      PrintFormat("Rejected (Stops Level):   %d", stats.rejected_stops_level);
      PrintFormat("Rejected (Freeze Level):  %d", stats.rejected_freeze_level);
      PrintFormat("Server / Execution Errors:%d", stats.server_errors);
      Print("==============================================");

      delete g_trailing;
     }
  }

//+------------------------------------------------------------------+
//| Counts active positions matching symbol and magic number         |
//+------------------------------------------------------------------+
int CountOpenPositions(string symbol, ulong magic)
  {
   int count = 0;
   for(int i = PositionsTotal() - 1; i >= 0; i--)
     {
      ulong ticket = PositionGetTicket(i);
      if(ticket > 0 && PositionSelectByTicket(ticket))
        {
         if(PositionGetString(POSITION_SYMBOL) == symbol && 
            PositionGetInteger(POSITION_MAGIC) == magic)
           {
            count++;
           }
        }
     }
   return count;
  }

//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
   static datetime last_bar_time = 0;
   datetime current_bar_time = iTime(_Symbol, PERIOD_CURRENT, 0);

   if(current_bar_time != last_bar_time)
     {
      last_bar_time = current_bar_time;

      if(CheckPointer(g_trailing) != POINTER_INVALID)
        {
         //--- Opens 1 test position for trailing demonstration in visual mode
         if(CountOpenPositions(_Symbol, InpMagicNumber) == 0)
           {
            CTrade trade;
            trade.SetExpertMagicNumber(InpMagicNumber);
            double ask = SymbolInfoDouble(_Symbol, SYMBOL_ASK);
            if(!trade.Buy(0.10, _Symbol, ask, 0.0, 0.0, "Demo Trailing"))
              {
               PrintFormat("Test order failed: %s (retcode: %u)", 
                           trade.ResultRetcodeDescription(), trade.ResultRetcode());
              }
           }

         //--- Execute trailing engine without parameter redundancy
         g_trailing.ProcessAllPositions();
        }
     }
  }