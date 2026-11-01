//+------------------------------------------------------------------+
//|                                          1. Kumo Breakout EA.mq5 |
//|                                  Copyright 2024, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2024, MetaQuotes Ltd." //--- Define copyright information
#property link      "https://www.mql5.com"           //--- Provide a link to the MetaQuotes website
#property version   "1.00"                           //--- Define the version of the expert advisor

#include <Trade/Trade.mqh>                            //--- Include the Trade library for trading functions
CTrade obj_Trade;                                    //--- Create an instance of the CTrade class for managing trades

int handle_Kumo = INVALID_HANDLE;                   //--- Initialize the Kumo indicator handle to an invalid state
int handle_AO = INVALID_HANDLE;                     //--- Initialize the Awesome Oscillator handle to an invalid state

double senkouSpan_A[];                              //--- Array to store Senkou Span A values
double senkouSpan_B[];                              //--- Array to store Senkou Span B values

double awesome_Oscillator[];                        //--- Array to store Awesome Oscillator values

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
 {
   //--- Initialize the Ichimoku Kumo indicator
   handle_Kumo = iIchimoku(_Symbol,_Period,8,29,34);
   
   if (handle_Kumo == INVALID_HANDLE) //--- Check if Kumo indicator initialization failed
    {              
      Print("ERROR: UNABLE TO INITIALIZE THE KUMO INDICATOR HANDLE. REVERTING NOW!"); //--- Log error
      return (INIT_FAILED);                         //--- Return initialization failure
    }      
   handle_AO = iAO(_Symbol,_Period);  //--- Initialize the Awesome Oscillator
   if (handle_AO == INVALID_HANDLE)   //--- Check if AO indicator initialization failed
    {              
      Print("ERROR: UNABLE TO INITIALIZE THE AO INDICATOR HANDLE. REVERTING NOW!"); //--- Log error
      return (INIT_FAILED);                         //--- Return initialization failure
    }

   ArraySetAsSeries(senkouSpan_A,true);             //--- Set Senkou Span A array as a time series
   ArraySetAsSeries(senkouSpan_B,true);             //--- Set Senkou Span B array as a time series
   
   ArraySetAsSeries(awesome_Oscillator,true);       //--- Set Awesome Oscillator array as a time series
   
   Print("SUCCESS. ",__FILE__," HAS BEEN INITIALIZED."); //--- Log successful initialization
   
   //---
   return(INIT_SUCCEEDED);                          //--- Return successful initialization
 }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
 {
   //--- Free memory allocated for Senkou Span A and B arrays
   ArrayFree(senkouSpan_A);
   ArrayFree(senkouSpan_B);
   
   //--- Free memory allocated for the Awesome Oscillator array
   ArrayFree(awesome_Oscillator);
 }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
 {
   //--- Copy data for Senkou Span A from the Kumo indicator
   if (CopyBuffer(handle_Kumo,SENKOUSPANA_LINE,0,2,senkouSpan_A) < 2)
    {
      Print("ERROR: UNABLE TO COPY REQUESTED DATA FROM SENKOUSPAN A LINE. REVERTING NOW!"); //--- Log error
      return;                                        //--- Exit if data copy fails
    }
   //--- Copy data for Senkou Span B from the Kumo indicator
   if (CopyBuffer(handle_Kumo,SENKOUSPANB_LINE,0,2,senkouSpan_B) < 2)
    {
      Print("ERROR: UNABLE TO COPY REQUESTED DATA FROM SENKOUSPAN B LINE. REVERTING NOW!"); //--- Log error
      return;                                        //--- Exit if data copy fails
    }   
   //--- Copy data from the Awesome Oscillator
   if (CopyBuffer(handle_AO,0,0,3,awesome_Oscillator) < 3)
    {
      Print("ERROR: UNABLE TO COPY REQUESTED DATA FROM AWESOME OSCILLATOR. REVERTING NOW!"); //--- Log error
      return;                                        //--- Exit if data copy fails
    }
   //--- Check if a new bar has formed
   if (isNewBar())
    {
      //--- Determine if the AO has crossed above or below zero
      bool isAO_Above = awesome_Oscillator[1] > 0 && awesome_Oscillator[2] < 0;
      bool isAO_Below = awesome_Oscillator[1] < 0 && awesome_Oscillator[2] > 0;
      
      //--- Determine if the Kumo is bullish or bearish
      bool isKumo_Above = senkouSpan_A[1] > senkouSpan_B[1];
      bool isKumo_Below = senkouSpan_A[1] < senkouSpan_B[1];
            
      //--- Determine buy and sell signals based on conditions
      bool isBuy_Signal = isAO_Above && isKumo_Below && getClosePrice(1) > senkouSpan_A[1] && getClosePrice(1) > senkouSpan_B[1];
      bool isSell_Signal = isAO_Below && isKumo_Above && getClosePrice(1) < senkouSpan_A[1] && getClosePrice(1) < senkouSpan_B[1];
      
      if (isBuy_Signal) //--- If buy signal is generated
       {                            
         Print("BUY SIGNAL GENERATED @ ",iTime(_Symbol,_Period,1),", PRICE: ",getAsk()); //--- Log buy signal
         obj_Trade.Buy(0.01,_Symbol,getAsk());      //--- Execute a buy trade
       }
      else if (isSell_Signal) //--- If sell signal is generated
       {                      
         Print("SELL SIGNAL GENERATED @ ",iTime(_Symbol,_Period,1),", PRICE: ",getBid()); //--- Log sell signal
         obj_Trade.Sell(0.01,_Symbol,getBid());     //--- Execute a sell trade
       }
      
      if (isAO_Above || isAO_Below) //--- If AO crossover occurs
       {                 
         if (PositionsTotal() > 0) //--- If there are open positions
          {                 
            for (int i=PositionsTotal()-1; i>=0; i--) //--- Loop through open positions
             {               
               ulong posTicket = PositionGetTicket(i); //--- Get the position ticket
               if (posTicket > 0) //--- If ticket is valid
                {                  
                  if (PositionSelectByTicket(posTicket)) //--- Select position by ticket
                   {
                     ENUM_POSITION_TYPE posType = (ENUM_POSITION_TYPE)PositionGetInteger(POSITION_TYPE); //--- Get position type
                     if (posType == POSITION_TYPE_BUY) //--- If position is a buy
                      { 
                        if (isAO_Below) //--- If AO indicates bearish crossover
                        {
                           Print("CLOSING THE BUY POSITION WITH #",posTicket); //--- Log position closure
                           obj_Trade.PositionClose(posTicket); //--- Close the buy position
                        }
                      }
                     else if (posType == POSITION_TYPE_SELL) //--- If position is a sell
                      { 
                        if (isAO_Above) //--- If AO indicates bullish crossover
                        { 
                           Print("CLOSING THE SELL POSITION WITH #",posTicket); //--- Log position closure
                           obj_Trade.PositionClose(posTicket); //--- Close the sell position
                        }
                      }
                   }
               }
             }
          }
       }
   }
   
   if (PositionsTotal() > 0) //--- If there are open positions
    {                       
      applyTrailingSTOP(3000*_Point,obj_Trade,0);  //--- Apply a trailing stop
    }
 }
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//|   IS NEW BAR FUNCTION                                            |
//+------------------------------------------------------------------+
bool isNewBar()
 { 
   static int prevBars = 0;                         //--- Store previous bar count
   int currBars = iBars(_Symbol,_Period);           //--- Get current bar count for the symbol and period
   if (prevBars == currBars) return (false);        //--- If bars haven't changed, return false
   prevBars = currBars;                             //--- Update previous bar count
   return (true);                                   //--- Return true if new bar is detected
 }

//+------------------------------------------------------------------+
//|        FUNCTION TO GET CLOSE PRICES                              |
//+------------------------------------------------------------------+
double getClosePrice(int bar_index)
 {
   return (iClose(_Symbol, _Period, bar_index));    //--- Retrieve the close price of the specified bar
 }

//+------------------------------------------------------------------+
//|        FUNCTION TO GET ASK PRICES                                |
//+------------------------------------------------------------------+
double getAsk()
 {
   return (NormalizeDouble(SymbolInfoDouble(_Symbol, SYMBOL_ASK), _Digits)); //--- Get and normalize the Ask price
 }

//+------------------------------------------------------------------+
//|        FUNCTION TO GET BID PRICES                                |
//+------------------------------------------------------------------+
double getBid()
 {
   return (NormalizeDouble(SymbolInfoDouble(_Symbol, SYMBOL_BID), _Digits)); //--- Get and normalize the Bid price
 }

//+------------------------------------------------------------------+
//|        FUNCTION TO APPLY TRAILING STOP                           |
//+------------------------------------------------------------------+
void applyTrailingSTOP(double slPoints, CTrade &trade_object,int magicNo=0)
 {
   double buySL = NormalizeDouble(SymbolInfoDouble(_Symbol,SYMBOL_BID)-slPoints,_Digits); //--- Calculate SL for buy positions
   double sellSL = NormalizeDouble(SymbolInfoDouble(_Symbol,SYMBOL_ASK)+slPoints,_Digits); //--- Calculate SL for sell positions

   for (int i = PositionsTotal() - 1; i >= 0; i--) //--- Iterate through all open positions
    {
      ulong ticket = PositionGetTicket(i);          //--- Get position ticket
      if (ticket > 0){                              //--- If ticket is valid
         if (PositionGetString(POSITION_SYMBOL) == _Symbol &&
            (magicNo == 0 || PositionGetInteger(POSITION_MAGIC) == magicNo)){ //--- Check symbol and magic number
            if (PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_BUY &&
               buySL > PositionGetDouble(POSITION_PRICE_OPEN) &&
               (buySL > PositionGetDouble(POSITION_SL) ||
               PositionGetDouble(POSITION_SL) == 0)){ //--- Modify SL for buy position if conditions are met
               trade_object.PositionModify(ticket,buySL,PositionGetDouble(POSITION_TP));
            }
            else if (PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_SELL &&
               sellSL < PositionGetDouble(POSITION_PRICE_OPEN) &&
               (sellSL < PositionGetDouble(POSITION_SL) ||
               PositionGetDouble(POSITION_SL) == 0)){ //--- Modify SL for sell position if conditions are met
               trade_object.PositionModify(ticket,sellSL,PositionGetDouble(POSITION_TP));
            }
         }
      }
   }
 }
