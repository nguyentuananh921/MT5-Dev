
//+------------------------------------------------------------------+
//|                                                   lwTDWStudy.mq5 |
//|          Copyright 2026, MetaQuotes Ltd. Developer is Chacha Ian |
//|Larry Williams Market Secrets                                     |
//|7. Day Trading with Larry Williams: The 20-Minute Day-Trading     |
//|                     https://www.mql5.com/en/articles/20941        |
//+------------------------------------------------------------------+

#property copyright "Copyright 2026, MetaQuotes Ltd. Developer is Chacha Ian"
#property link      "https://www.mql5.com/en/users/chachaian"
#property version   "1.00"


//+------------------------------------------------------------------+
//| Custom Enumerations                                              |
//+------------------------------------------------------------------+
enum ENUM_TDW_MODE
{
   TDW_ALL_DAYS,     
   TDW_SELECTED_DAYS
};


//+------------------------------------------------------------------+
//| Standard Libraries                                               |
//+------------------------------------------------------------------+
#include <Trade\Trade.mqh>


//+------------------------------------------------------------------+
//| User input variables                                             |
//+------------------------------------------------------------------+
input group "Information"
input ulong magicNumber          = 254700680002;                 
input ENUM_TIMEFRAMES timeframe  = PERIOD_CURRENT;

input group "TDW filters"
input ENUM_TDW_MODE tradeDayMode = TDW_SELECTED_DAYS;
input bool tradeSunday           = false;
input bool tradeMonday           = true;
input bool tradeTuesday          = false;
input bool tradeWednesday        = false;
input bool tradeThursday         = false;
input bool tradeFriday           = false;
input bool tradeSaturday         = false;

input group "Volatility Breakout Parameters"
input double inpBuyRangeMultiplier = 0.50;

input group "Trade and Risk Management"
input double positionSize = 0.1;


//+------------------------------------------------------------------+
//| Global Variables                                                 |
//+------------------------------------------------------------------+
//--- Create a CTrade object to handle trading operations
CTrade Trade;

//--- To hep track current market prices for Buying (Ask) and Selling (Bid)
double askPrice;
double bidPrice;

//--- To store current time
datetime currentTime;

//--- To help track new bar open
datetime lastBarOpenTime;


//--- Holds all price levels derived from Larry Williams' volatility breakout calculations
struct MqlLwVolatilityLevels
{
   double yesterdayRange;      
   double buyEntryPrice;       
};

MqlLwVolatilityLevels lwVolatilityLevels;

//--- To store minutes data
double closePriceMinutesData [];


//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit(){

   //---  Assign a unique magic number to identify trades opened by this EA
   Trade.SetExpertMagicNumber(magicNumber);
   
   //--- Initialize global variables
   lastBarOpenTime = 0;
   
   //--- Reset volatility levels 
   ZeroMemory(lwVolatilityLevels);
   
   //--- Treat the following arrays as timeseries (index 0 becomes the most recent bar)
   ArraySetAsSeries(closePriceMinutesData, true);
   
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
   askPrice    = SymbolInfoDouble (_Symbol, SYMBOL_ASK);
   bidPrice    = SymbolInfoDouble (_Symbol, SYMBOL_BID);
   currentTime = TimeCurrent();
   
   //--- Run this block only when a new bar is detected on the selected timeframe
   if(IsNewBar(_Symbol, timeframe, lastBarOpenTime)){
      lwVolatilityLevels.yesterdayRange = GetBarRange(_Symbol, timeframe, 1);
      lwVolatilityLevels.buyEntryPrice  = CalculateBuyEntryPrice (askPrice, lwVolatilityLevels.yesterdayRange, inpBuyRangeMultiplier );
      
      //--- Close any active long position
      if(IsThereAnActiveBuyPosition(magicNumber)){
         ClosePositionsByMagic(magicNumber);
      }
      
   }
   
   //--- Get some minutes data
   if(CopyClose(_Symbol, PERIOD_M1, 0, 5, closePriceMinutesData) == -1){
      Print("Error while copying minutes datas ", GetLastError());
      return;
   }
   
   
   if(tradeDayMode == TDW_ALL_DAYS){
      if(IsCrossOver(lwVolatilityLevels.buyEntryPrice, closePriceMinutesData )){
         OpenBuy(askPrice, positionSize);
      }
   }
   
   if(tradeDayMode == TDW_SELECTED_DAYS){
      if(IsTradingDayAllowed(currentTime)){
         if(IsCrossOver(lwVolatilityLevels.buyEntryPrice, closePriceMinutesData)){
            OpenBuy(askPrice, positionSize);
         }
      }
   }

}

//--- UTILITY FUNCTIONS

//+------------------------------------------------------------------+
//| Function to check if there's a new bar on a given chart timeframe|
//+------------------------------------------------------------------+
bool IsNewBar(string symbol, ENUM_TIMEFRAMES tf, datetime &lastTm){

   datetime currentTm = iTime(symbol, tf, 0);
   if(currentTm != lastTm){
      lastTm       = currentTm;
      return true;
   }  
   return false;
   
}


//+------------------------------------------------------------------+
//| Returns the price range (high - low) of a bar at the given index |
//+------------------------------------------------------------------+
double GetBarRange(const string symbol, ENUM_TIMEFRAMES tf, int index){

   double high = iHigh(symbol, tf, index);
   double low  = iLow (symbol, tf, index);

   if(high == 0.0 || low == 0.0){
      return 0.0;
   }

   return NormalizeDouble(high - low, Digits());
}


//+------------------------------------------------------------------+
//| Calculates the bullish breakout entry price using today's open and yesterday's range |
//+------------------------------------------------------------------+
double CalculateBuyEntryPrice(double todayOpen, double yesterdayRange, double buyMultiplier){

   return todayOpen + (yesterdayRange * buyMultiplier);
}


//+------------------------------------------------------------------+
//| To detect a crossover at a given price level                     |                               
//+------------------------------------------------------------------+
bool IsCrossOver(const double price, const double &closePriceMinsData[]){
   if(closePriceMinsData[1] <= price && closePriceMinsData[0] > price){
      return true;
   }
   return false;
}


//+------------------------------------------------------------------+
//| Returns the day of the week (0 = Sunday, 6 = Saturday) for the given datetime value|                               
//+------------------------------------------------------------------+
int TimeDayOfWeek(datetime time){
   MqlDateTime timeStruct = {};
   if(!TimeToStruct(time, timeStruct)){
      Print("TimeDayOfWeek: TimeToStruct failed");
      return -1;
   }      
   return timeStruct.day_of_week;
}


//+------------------------------------------------------------------+
//| Determines whether trading is permitted for the given datetime based on the selected trade-day mode |                               
//+------------------------------------------------------------------+
bool IsTradingDayAllowed(datetime time)
{
   // Baseline mode: no filtering
   if(tradeDayMode == TDW_ALL_DAYS){
      return true;
   }

   int day = TimeDayOfWeek(time);

   switch(day)
   {
      case 0: return tradeSunday;
      case 1: return tradeMonday;
      case 2: return tradeTuesday;
      case 3: return tradeWednesday;
      case 4: return tradeThursday;
      case 5: return tradeFriday;
      case 6: return tradeSaturday;
   }

   return false;
}


//+------------------------------------------------------------------+
//| To verify whether this EA currently has an active buy position.  |                                 |
//+------------------------------------------------------------------+
bool IsThereAnActiveBuyPosition(ulong magic){
   
   for(int i = PositionsTotal() - 1; i >= 0; i--){
      ulong ticket = PositionGetTicket(i);
      if(ticket == 0){
         Print("Error while fetching position ticket ", GetLastError());
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
