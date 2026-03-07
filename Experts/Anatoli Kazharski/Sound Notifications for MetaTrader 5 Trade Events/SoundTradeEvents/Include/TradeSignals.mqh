//--- Connection with the main file of the Expert Advisor
#include "..\SoundTradeEvents.mq5"
//--- Include custom libraries
#include "Enums.mqh"
#include "Errors.mqh"
#include "TradeFunctions.mqh"
#include "ToString.mqh"
#include "Auxiliary.mqh"
//+------------------------------------------------------------------+
//| Getting bar values                                               |
//+------------------------------------------------------------------+
void GetBarsData()
  {
//--- Adjust the number of bars for the position opening condition
   if(NumberOfBars<=1)
      AllowedNumberOfBars=2;              // At least two bars are required
   if(NumberOfBars>=5)
      AllowedNumberOfBars=5;              // but no more than 5
   else
      AllowedNumberOfBars=NumberOfBars+1; // and always more by one
//--- Reverse the indexing order (... 3 2 1 0)
   ArraySetAsSeries(close_price,true);
   ArraySetAsSeries(open_price,true);
   ArraySetAsSeries(high_price,true);
   ArraySetAsSeries(low_price,true);
//--- Get the closing price of the bar
//    If the number of the obtained values is less than requested, print the relevant message
   if(CopyClose(_Symbol,Period(),0,AllowedNumberOfBars,close_price)<AllowedNumberOfBars)
     {
      Print("Failed to copy the values ("
            +_Symbol+", "+TimeframeToString(Period())+") to the Close price array! "
            "Error "+IntegerToString(GetLastError())+": "+ErrorDescription(GetLastError()));
     }
//--- Get the opening price of the bar
//    If the number of the obtained values is less than requested, print the relevant message
   if(CopyOpen(_Symbol,Period(),0,AllowedNumberOfBars,open_price)<AllowedNumberOfBars)
     {
      Print("Failed to copy the values ("
            +_Symbol+", "+TimeframeToString(Period())+") to the Open price array! "
            "Error "+IntegerToString(GetLastError())+": "+ErrorDescription(GetLastError()));
     }
//--- Get the bar's high
//    If the number of the obtained values is less than requested, print the relevant message
   if(CopyHigh(_Symbol,Period(),0,AllowedNumberOfBars,high_price)<AllowedNumberOfBars)
     {
      Print("Failed to copy the values ("
            +_Symbol+", "+TimeframeToString(Period())+") to the High price array! "
            "Error "+IntegerToString(GetLastError())+": "+ErrorDescription(GetLastError()));
     }
//--- Get the bar's high
//    If the number of the obtained values is less than requested, print the relevant message
   if(CopyLow(_Symbol,Period(),0,AllowedNumberOfBars,low_price)<AllowedNumberOfBars)
     {
      Print("Failed to copy the values ("
            +_Symbol+", "+TimeframeToString(Period())+") to the Low price array! "
            "Error "+IntegerToString(GetLastError())+": "+ErrorDescription(GetLastError()));
     }
  }
//+------------------------------------------------------------------+
//| Determining trading signals                                      |
//+------------------------------------------------------------------+
ENUM_ORDER_TYPE GetTradingSignal()
  {
   GetSymbolProperties(S_ALL);
//--- If there is no position
   if(!pos.exists)
     {
      //--- A Sell signal
      if(GetSignal()==ORDER_TYPE_SELL)
         return(ORDER_TYPE_SELL);
      //--- A Buy signal
      if(GetSignal()==ORDER_TYPE_BUY)
         return(ORDER_TYPE_BUY);
     }
//--- If there is a position
   if(pos.exists)
     {
      //--- Get the position type
      GetPositionProperties(P_TYPE);
      //--- For the position reversal
      if(Reverse)
        {
         //--- A Sell signal
         if(pos.type==POSITION_TYPE_BUY &&
            GetSignal()==ORDER_TYPE_SELL)
            return(ORDER_TYPE_SELL);
         //--- A Buy signal
         if(pos.type==POSITION_TYPE_SELL &&
            GetSignal()==ORDER_TYPE_BUY)
            return(ORDER_TYPE_BUY);
        }
     }
//--- No signal
   return(WRONG_VALUE);
  }
//+------------------------------------------------------------------+
//| Determining trading signals                                      |
//+------------------------------------------------------------------+
ENUM_ORDER_TYPE GetSignal()
  {
//--- A Buy signal (ORDER_TYPE_BUY) :
   if(AllowedNumberOfBars==2 && 
      close_price[1]>open_price[1])
      return(ORDER_TYPE_BUY);
   if(AllowedNumberOfBars==3 && 
      close_price[1]>open_price[1] && 
      close_price[2]>open_price[2])
      return(ORDER_TYPE_BUY);
   if(AllowedNumberOfBars==4 && 
      close_price[1]>open_price[1] && 
      close_price[2]>open_price[2] && 
      close_price[3]>open_price[3])
      return(ORDER_TYPE_BUY);
   if(AllowedNumberOfBars==5 && 
      close_price[1]>open_price[1] && 
      close_price[2]>open_price[2] && 
      close_price[3]>open_price[3] && 
      close_price[4]>open_price[4])
      return(ORDER_TYPE_BUY);
   if(AllowedNumberOfBars>=6 && 
      close_price[1]>open_price[1] && 
      close_price[2]>open_price[2] && 
      close_price[3]>open_price[3] && 
      close_price[4]>open_price[4] && 
      close_price[5]>open_price[5])
      return(ORDER_TYPE_BUY);
//--- A Sell signal (ORDER_TYPE_SELL) :
   if(AllowedNumberOfBars==2 && 
      close_price[1]<open_price[1])
      return(ORDER_TYPE_SELL);
   if(AllowedNumberOfBars==3 && 
      close_price[1]<open_price[1] && 
      close_price[2]<open_price[2])
      return(ORDER_TYPE_SELL);
   if(AllowedNumberOfBars==4 && 
      close_price[1]<open_price[1] && 
      close_price[2]<open_price[2] && 
      close_price[3]<open_price[3])
      return(ORDER_TYPE_SELL);
   if(AllowedNumberOfBars==5 && 
      close_price[1]<open_price[1] && 
      close_price[2]<open_price[2] && 
      close_price[3]<open_price[3] && 
      close_price[4]<open_price[4])
      return(ORDER_TYPE_SELL);
   if(AllowedNumberOfBars>=6 && 
      close_price[1]<open_price[1] && 
      close_price[2]<open_price[2] && 
      close_price[3]<open_price[3] && 
      close_price[4]<open_price[4] && 
      close_price[5]<open_price[5])
      return(ORDER_TYPE_SELL);
//--- No signal (WRONG_VALUE):
   return(WRONG_VALUE);
  }
//+------------------------------------------------------------------+
