//--- Connection with the main file of the Expert Advisor
#include "..\SoundTradeEvents.mq5"
//--- Include custom libraries
#include "Enums.mqh"
#include "Errors.mqh"
#include "TradeSignals.mqh"
#include "TradeFunctions.mqh"
//+------------------------------------------------------------------------+
//| Adjusting the value based on the number of digits in the price (int)   |
//+------------------------------------------------------------------------+
int CorrectValueBySymbolDigits(int value)
  {
   return(symb.digits==3 || symb.digits==5) ? value*=10 : value;
  }
//+------------------------------------------------------------------------+
//| Adjusting the value based on the number of digits in the price (double)|
//+------------------------------------------------------------------------+
double CorrectValueBySymbolDigits(double value)
  {
   return(symb.digits==3 || symb.digits==5) ? value*=10 : value;
  }
//+------------------------------------------------------------------------+
//| Returning the testing flag                                             |
//+------------------------------------------------------------------------+
bool IsTester()
  {
   return(MQL5InfoInteger(MQL5_TESTER));
  }
//+------------------------------------------------------------------------+
//| Returning the optimization flag                                        |
//+------------------------------------------------------------------------+
bool IsOptimization()
  {
   return(MQL5InfoInteger(MQL5_OPTIMIZATION));
  }
//+------------------------------------------------------------------------+
//| Returning the visual testing mode flag                                 |
//+------------------------------------------------------------------------+
bool IsVisualMode()
  {
   return(MQL5InfoInteger(MQL5_VISUAL_MODE));
  }
//+------------------------------------------------------------------------+
//| Returning the flag for real time mode outside the Strategy Tester      |
//| if all conditions are met                                              |
//+------------------------------------------------------------------------+
bool IsRealtime()
  {
   if(!IsTester() && !IsOptimization() && !IsVisualMode())
      return(true);
   else
      return(false);
  }
//+------------------------------------------------------------------------+
//| Checking if trading is allowed                                         |
//+------------------------------------------------------------------------+
bool CheckTradingPermission()
  {
//--- For real-time mode
   if(IsRealtime())
     {
      //--- Checking server connection
      if(!TerminalInfoInteger(TERMINAL_CONNECTED))
         return(1);
      //--- Permission to trade at the running program level
      if(!MQL5InfoInteger(MQL5_TRADE_ALLOWED))
         return(2);
      //--- Permission to trade at the terminal level
      if(!TerminalInfoInteger(TERMINAL_TRADE_ALLOWED))
         return(3);
      //--- Permission to trade for the current account
      if(!AccountInfoInteger(ACCOUNT_TRADE_ALLOWED))
         return(4);
      //--- Permission to trade automatically for the current account
      if(!AccountInfoInteger(ACCOUNT_TRADE_EXPERT))
         return(5);
     }
//---
   return(0);
  }
//+------------------------------------------------------------------------+