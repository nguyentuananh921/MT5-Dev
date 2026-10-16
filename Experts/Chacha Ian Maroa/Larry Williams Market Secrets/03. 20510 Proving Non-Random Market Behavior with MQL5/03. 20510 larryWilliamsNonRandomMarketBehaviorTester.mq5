
//+------------------------------------------------------------------+
//|                   larryWilliamsNonRandomMarketBehaviorTester.mq5 |
//|Larry Williams Market Secrets                                     |
//|3. Proving Non-Random Market Behavior with MQL5                   |
//|                     https://www.mql5.com/en/articles/20510       |
//+------------------------------------------------------------------+

#property copyright   "Copyright 2025, MetaQuotes Ltd. Developer is Chacha Ian"
#property link        "https://www.mql5.com/en/users/chachaian"
#property version     "1.00"
#property description "This Expert Advisor is designed to run one statistical experiment at a time."
#property description "The test to be executed is selected through a dropdown input when attaching the EA to the chart."


//+------------------------------------------------------------------+
//| Standard Libraries                                               |
//+------------------------------------------------------------------+
#include <Trade\Trade.mqh>


//--- CUSTOM ENUMERATIONS
//+------------------------------------------------------------------+
//| Non-random market behavior test modes                            |
//+------------------------------------------------------------------+
enum ENUM_NON_RANDOM_TEST_MODE
{
   TEST_OPEN_TO_CLOSE_BIAS,  
   TEST_AFTER_ONE_DOWN_CLOSE,    
   TEST_AFTER_TWO_DOWN_CLOSES,    
   TEST_AFTER_THREE_DOWN_CLOSES, 
   TEST_AFTER_ONE_UP_CLOSE,          
   TEST_AFTER_TWO_UP_CLOSES,                 
   TEST_AFTER_THREE_UP_CLOSES,
   TEST_AFTER_SHORT_TERM_LOW 
};

//+------------------------------------------------------------------+
//| Direction of candle close relative to open                       |
//+------------------------------------------------------------------+
enum ENUM_BAR_CLOSE_STATE
{
   BAR_CLOSE_UP, 
   BAR_CLOSE_DOWN
};


//+------------------------------------------------------------------+
//| User input variables                                             |
//+------------------------------------------------------------------+
input group "Information"
input ulong           magicNumber                 = 254700680002;                 
input ENUM_TIMEFRAMES timeframe                   = PERIOD_CURRENT;

input group "Trade And Risk Management"
input ENUM_NON_RANDOM_TEST_MODE nonRandomTestMode = TEST_OPEN_TO_CLOSE_BIAS;
input double positionSize                         = 0.01;


//+------------------------------------------------------------------+
//| Global Variables                                                 |
//+------------------------------------------------------------------+
//--- Create a CTrade object to handle trading operations
CTrade Trade;

//--- Bid and Ask
double   askPrice;

//--- To help track new bar open
datetime lastBarOpenTime;


//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit(){

   //---  Assign a unique magic number to identify trades opened by this EA
   Trade.SetExpertMagicNumber(magicNumber);
   
   //--- Initialize global variables
   lastBarOpenTime = 0;
   
   //--- To configure the chart's appearance
   if(!ConfigureChartAppearance()){
      Print("Error while configuring chart appearance", GetLastError());
      return INIT_FAILED;
   }

   return(INIT_SUCCEEDED);
}


//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason){

   //--- Notify why the program stopped running
   Print("Program terminated! Reason code: ", reason);

}


//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick(){

   //--- Retrieve current market prices for trade execution
   askPrice      = SymbolInfoDouble (_Symbol, SYMBOL_ASK);
   
   //--- Run this block only when a new bar is detected on the selected timeframe
   if(IsNewBar(_Symbol, timeframe, lastBarOpenTime)){
      
      //--- Close any existing buy positions for this EA before opening a new one
      if(IsThereAnActiveBuyPosition(magicNumber)){
         ClosePositionsByMagic(magicNumber);
         Sleep(100);
      }
      
      //--- Execute a buy trade when the Open-to-Close bias test mode is selected
      if(nonRandomTestMode == TEST_OPEN_TO_CLOSE_BIAS    ){
         OpenBuy(askPrice, positionSize);
      }
      
      //--- Enter a buy position to test bullish bias following a single down close
      if(nonRandomTestMode == TEST_AFTER_ONE_DOWN_CLOSE   ){
         if(IsConsecutiveBarCloseState(_Symbol, timeframe, 1, BAR_CLOSE_DOWN)){
            OpenBuy(askPrice, positionSize);
         }
      }
      
      //--- Enter a buy position to test bullish bias following two consecutive down closes
      if(nonRandomTestMode == TEST_AFTER_TWO_DOWN_CLOSES  ){
         if(IsConsecutiveBarCloseState(_Symbol, timeframe, 2, BAR_CLOSE_DOWN)){
            OpenBuy(askPrice, positionSize);
         }
      }
      
      //--- Enter a buy position to test bullish bias following three consecutive down closes
      if(nonRandomTestMode == TEST_AFTER_THREE_DOWN_CLOSES){
         if(IsConsecutiveBarCloseState(_Symbol, timeframe, 3, BAR_CLOSE_DOWN)){
            OpenBuy(askPrice, positionSize);
         }
      }
      
      //--- Enter a buy position to test bullish bias following a single up close
      if(nonRandomTestMode == TEST_AFTER_ONE_UP_CLOSE     ){
         if(IsConsecutiveBarCloseState(_Symbol, timeframe, 1, BAR_CLOSE_UP)){
            OpenBuy(askPrice, positionSize);
         }
      }
      
      //--- Enter a buy position to test bullish bias following two consecutive up closes
      if(nonRandomTestMode == TEST_AFTER_TWO_UP_CLOSES    ){
         if(IsConsecutiveBarCloseState(_Symbol, timeframe, 2, BAR_CLOSE_UP)){
            OpenBuy(askPrice, positionSize);
         }
      }
      
      //--- Enter a buy position to test bullish bias following three consecutive up closes
      if(nonRandomTestMode == TEST_AFTER_THREE_UP_CLOSES  ){
         if(IsConsecutiveBarCloseState(_Symbol, timeframe, 3, BAR_CLOSE_UP)){
            OpenBuy(askPrice, positionSize);
         }
      }
      
      //---  Enter a buy position when a Larry Williams-defined short-term low pattern is detected
      if(nonRandomTestMode == TEST_AFTER_SHORT_TERM_LOW   ){
         if(IsLarryWilliamsShortTermLow(_Symbol, timeframe)){
            OpenBuy(askPrice, positionSize);
         }
      }
      
   }

}


//+------------------------------------------------------------------+
//| TradeTransaction function                                        |
//+------------------------------------------------------------------+
void OnTradeTransaction(const MqlTradeTransaction& trans,
                        const MqlTradeRequest& request,
                        const MqlTradeResult& result)
{

   //--- To handle trade transaction events

}


//--- UTILITY FUNCTIONS
//+------------------------------------------------------------------+
//| Function to check if there's a new bar on a given chart timeframe|
//+------------------------------------------------------------------+
bool IsNewBar(string symbol, ENUM_TIMEFRAMES tf, datetime &lastTm)
{

   datetime currentTm = iTime(symbol, tf, 0);
   if(currentTm != lastTm){
      lastTm       = currentTm;
      return true;
   }  
   return false;
   
}


//+------------------------------------------------------------------+
//| Checks whether the last N completed bars all closed              |
//| either up or down relative to their open                         |
//+------------------------------------------------------------------+
bool IsConsecutiveBarCloseState(string symbol, ENUM_TIMEFRAMES tf, int barsToCheck, ENUM_BAR_CLOSE_STATE closeState)
{
   // Start from bar index 1 (last fully closed bar)
   for(int i = 1; i <= barsToCheck; i++){
   
      double openPrice  = iOpen (symbol, timeframe, i);
      double closePrice = iClose(symbol, timeframe, i);

      // Safety check (in case of missing data)
      if(openPrice == 0.0 || closePrice == 0.0){
         return false;
      }

      // Validate close direction
      if(closeState == BAR_CLOSE_UP && closePrice <= openPrice){
         return false;
      }
         

      if(closeState == BAR_CLOSE_DOWN && closePrice >= openPrice){
         return false;
      }   
   
   }

   return true;
}

//+------------------------------------------------------------------+
//| Detects a Larry Williams short-term low on the last three bars   |
//| Bar index 2 must be a swing low with higher lows on both sides   |
//| Bar 2 must NOT be an outside bar                                 |
//| Bar 1 must NOT be an inside bar                                  |
//+------------------------------------------------------------------+
bool IsLarryWilliamsShortTermLow(string symbol, ENUM_TIMEFRAMES tf){

   //--- Price data for the three bars
   double high1 = iHigh(symbol, tf, 1);
   double low1  = iLow (symbol, tf, 1);

   double high2 = iHigh(symbol, tf, 2);
   double low2  = iLow (symbol, tf, 2);

   double high3 = iHigh(symbol, tf, 3);
   double low3  = iLow (symbol, tf, 3);

   //--- Condition 1: Bar 2 must be a swing low
   bool isSwingLow =
      (low2 < low1) &&
      (low2 < low3);

   if(!isSwingLow){
      return false;
   }
      

   //--- Condition 2: Bar 2 must NOT be an outside bar relative to bar 3
   bool isOutsideBar =
      (high2 > high3) &&
      (low2  < low3);

   if(isOutsideBar){
      return false;
   }

   //--- Condition 3: Bar 1 must NOT be an inside bar relative to bar 2
   bool isInsideBar =
      (high1 < high2) &&
      (low1  > low2);

   if(isInsideBar){
      return false;
   }

   //--- All conditions satisfied
   return true;
}


//+------------------------------------------------------------------+
//| To verify whether this EA currently has an active buy position.  |                                 |
//+------------------------------------------------------------------+
bool IsThereAnActiveBuyPosition(ulong magic){
   
   for(int i = PositionsTotal() - 1; i >= 0; i--){
      ulong ticket = PositionGetTicket(i);
      if(ticket == 0){
         Print("Error while fetching position ticket ", _LastError);
         continue;
      }else{
         if(PositionGetInteger(POSITION_MAGIC) == magic && PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_BUY){
            return true;
         }
      }
   }
   
   return false;
}


//+------------------------------------------------------------------+
//| To close all position with a specified magic number              |   
//+------------------------------------------------------------------+
void ClosePositionsByMagic(ulong magic) {
    
    for (int i = PositionsTotal() - 1; i >= 0; i--) {
        ulong ticket = PositionGetTicket(i);
        if (PositionSelectByTicket(ticket)) {
            if (PositionGetInteger(POSITION_MAGIC) == magic) {
                ulong positionType = PositionGetInteger(POSITION_TYPE);
                double volume = PositionGetDouble(POSITION_VOLUME);
                if (positionType == POSITION_TYPE_BUY) {
                    Trade.PositionClose(ticket);
                } else if (positionType == POSITION_TYPE_SELL) {
                    Trade.PositionClose(ticket);
                }
            }
        }
    }
    
}


//+------------------------------------------------------------------+
//| Function to open a market buy position                           |
//+------------------------------------------------------------------+
bool OpenBuy(double entryPrice, double lotSize){
   if(!Trade.Buy(NormalizeDouble(lotSize, 2), _Symbol, entryPrice)){
      Print("Error while executing a market buy order: ", GetLastError());
      Print(Trade.ResultRetcode());
      Print(Trade.ResultComment());
      return false;
   }
   return true;
}


//+------------------------------------------------------------------+
//| This function configures the chart's appearance.                 |
//+------------------------------------------------------------------+
bool ConfigureChartAppearance()
{
   if(!ChartSetInteger(0, CHART_COLOR_BACKGROUND, clrWhite)){
      Print("Error while setting chart background, ", GetLastError());
      return false;
   }
   
   if(!ChartSetInteger(0, CHART_SHOW_GRID, false)){
      Print("Error while setting chart grid, ", GetLastError());
      return false;
   }
   
   if(!ChartSetInteger(0, CHART_MODE, CHART_CANDLES)){
      Print("Error while setting chart mode, ", GetLastError());
      return false;
   }

   if(!ChartSetInteger(0, CHART_COLOR_FOREGROUND, clrBlack)){
      Print("Error while setting chart foreground, ", GetLastError());
      return false;
   }

   if(!ChartSetInteger(0, CHART_COLOR_CANDLE_BULL, clrSeaGreen)){
      Print("Error while setting bullish candles color, ", GetLastError());
      return false;
   }
      
   if(!ChartSetInteger(0, CHART_COLOR_CANDLE_BEAR, clrBlack)){
      Print("Error while setting bearish candles color, ", GetLastError());
      return false;
   }
   
   if(!ChartSetInteger(0, CHART_COLOR_CHART_UP, clrSeaGreen)){
      Print("Error while setting bearish candles color, ", GetLastError());
      return false;
   }
   
   if(!ChartSetInteger(0, CHART_COLOR_CHART_DOWN, clrBlack)){
      Print("Error while setting bearish candles color, ", GetLastError());
      return false;
   }
   
   return true;
}
  
//+------------------------------------------------------------------+
