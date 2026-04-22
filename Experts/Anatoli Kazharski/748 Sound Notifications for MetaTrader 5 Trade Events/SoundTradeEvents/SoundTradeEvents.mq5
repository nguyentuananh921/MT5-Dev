//+------------------------------------------------------------------+
//|                                           SoundedTradeEvents.mq5 |
//|            Copyright 2013, https://login.mql5.com/en/users/tol64 |
//|                                  Site, http://tol64.blogspot.com |
//+------------------------------------------------------------------+
#property copyright   "Copyright 2013, http://tol64.blogspot.com"
#property link        "http://tol64.blogspot.com"
#property description "email: hello.tol64@gmail.com"
#property version     "1.0"
//--- Name of the Expert Advisor
#define EXPERT_NAME MQL5InfoString(MQL5_PROGRAM_NAME)
//--- Include a class of the Standard Library
#include <Trade/Trade.mqh>
//--- Include custom libraries
#include "Include/Errors.mqh"
#include "Include/Enums.mqh"
#include "Include/Resources.mqh"
#include "Include/TradeSignals.mqh"
#include "Include/TradeFunctions.mqh"
#include "Include/ToString.mqh"
#include "Include/Auxiliary.mqh"
//--- External parameters of the Expert Advisor
input  int        NumberOfBars =2;    // Number of one-direction bars
sinput double     Lot          =0.1;  // Lot
input  double     TakeProfit   =100;  // Take Profit
input  double     StopLoss     =50;   // Stop Loss
input  double     TrailingStop =10;   // Trailing Stop
input  bool       Reverse      =true; // Position reversal
sinput bool       UseSound     =true; // Sound notifications
//--- The latest data
MqlTick           last_tick;
//--- Load the class
CTrade            trade;
//--- To check the value of the NumberOfBars external parameter
int               AllowedNumberOfBars=0;
//---
double            close_price[]; // Close (closing price of the bar)
double            open_price[];  // Open (opening price of the bar)
double            high_price[];  // High (High price of the bar)
double            low_price[];   // Low (Low price of the bar)
//+------------------------------------------------------------------+
//| Initialization                                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- Initialize the new bar
   CheckNewBar();
//--- Initialize tickets of the last deals for the symbol
   SoundNotification();
//--- Initialization completed successfully
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Deinitialization                                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//--- Print the deinitialization reason to the journal
   Print(GetDeinitReasonText(reason));
//--- Display the amount of memory used (approximate value)
   Print("TERMINAL_MEMORY_USED: ",TerminalInfoInteger(TERMINAL_MEMORY_USED)," Mb");
  }
//+------------------------------------------------------------------+
//| Current symbol tick event                                        |
//+------------------------------------------------------------------+
void OnTick()
  {
//--- If the bar is not new, exit
   if(!CheckNewBar())
      return;
//--- If there is a new bar
   else
     {
      GetBarsData();        // Get bar data
      TradingBlock();       // Check the conditions and trade
      ModifyTrailingStop(); // Modify the Trailing Stop level
     }
  }
//+------------------------------------------------------------------+
//| Monitoring trade events                                          |
//+------------------------------------------------------------------+
void OnTrade()
  {
//--- Sound notification
   SoundNotification();
  }
//+------------------------------------------------------------------+
//| Sound notification                                               |
//+------------------------------------------------------------------+
void SoundNotification()
  {
//--- If it is the real-time mode and sounds are enabled
   if(IsRealtime() && UseSound)
     {
      ulong        ticket      =0; // Deal ticket
      int          total       =0; // Total deals
      static ulong last_ticket =0; // Last ticket prior to this check
      //--- Get the complete history
      if(!HistorySelect(0,TimeCurrent()+1000))
         return;
      //--- Get the number of deals in the obtained list
      total=HistoryDealsTotal();
      //--- In the obtained list, iterate over all deals from the last one to the first one
      for(int i=total-1; i>=0; i--)
        {
         //--- If the deal ticket by its position in the list has been obtained
         if((ticket=HistoryDealGetTicket(i))>0)
           {
            //--- get the symbol of the deal
            GetHistoryDealProperties(ticket,D_SYMBOL);
            //--- If the symbol of the deal and the current symbol are the same
            if(deal.symbol==_Symbol)
              {
               //--- get the direction of the deal
               GetHistoryDealProperties(ticket,D_ENTRY);
               //--- If it is position closing, volume decrease or reversal
               if(deal.entry==DEAL_ENTRY_OUT || deal.entry==DEAL_ENTRY_INOUT)
                 {
                  //--- If the ticket of the current deal from the list (the last deal for the symbol) is equal to the previous ticket
                  //    or this is the initialization of the ticket of the last deal
                  if(ticket==last_ticket || last_ticket==0)
                    {
                     //--- Save the ticket and exit
                     last_ticket=ticket;
                     return;
                    }
                  //--- Get the result of the deal
                  GetHistoryDealProperties(ticket,D_PROFIT);
                  //--- In case of profit
                  if(deal.profit>=0)
                    {
                     //--- Profit sound
                     PlaySoundByID(SOUND_CLOSE_WITH_PROFIT);
                     //--- Save the ticket number
                     last_ticket=ticket;
                     return;
                    }
                  //--- In case of loss
                  if(deal.profit<0)
                    {
                     //--- Loss sound
                     PlaySoundByID(SOUND_CLOSE_WITH_LOSS);
                     //--- Save the ticket number
                     last_ticket=ticket;
                     return;
                    }
                 }
              }
           }
        }
     }
  }
//+------------------------------------------------------------------+
//| Playing sounds                                                   |
//+------------------------------------------------------------------+
void PlaySoundByID(ENUM_SOUNDS id)
  {
//--- If it is the real-time mode and sounds are enabled
   if(IsRealtime() && UseSound)
     {
      //--- Play the sound based on the identifier passed
      switch(id)
        {
         case SOUND_ERROR              : PlaySound(SoundError);            break;
         case SOUND_OPEN_POSITION      : PlaySound(SoundOpenPosition);     break;
         case SOUND_ADJUST_ORDER       : PlaySound(SoundAdjustOrder);      break;
         case SOUND_CLOSE_WITH_PROFIT  : PlaySound(SoundCloseWithProfit);  break;
         case SOUND_CLOSE_WITH_LOSS    : PlaySound(SoundCloseWithLoss);    break;
        }
     }
  }
//+------------------------------------------------------------------+
