
//+------------------------------------------------------------------+
//|                              lwVolatilitySwingBreakoutExpert.mq5 |
//|Larry Williams Market Secrets                                     |
//|6. Measuring Volatility Breakouts Using Market Swings             |
//|                     https://www.mql5.com/en/articles/20862        |
//+------------------------------------------------------------------+

#property copyright "Copyright 2026, MetaQuotes Ltd. Developer is Chacha Ian"
#property link      "https://www.mql5.com/en/users/chachaian"
#property version   "1.00"


//+------------------------------------------------------------------+
//| Standard Libraries                                               |
//+------------------------------------------------------------------+
#include <Trade\Trade.mqh>


//--- CUSTOM ENUMERATIONS
enum ENUM_TRADE_DIRECTION  
{ 
   ONLY_LONG, 
   ONLY_SHORT, 
   TRADE_BOTH 
};

enum ENUM_LOT_SIZE_INPUT_MODE 
{ 
   MODE_MANUAL, 
   MODE_AUTO 
};


//+------------------------------------------------------------------+
//| User input variables                                             |
//+------------------------------------------------------------------+
input group "Information"
input ulong magicNumber         = 254700680002;                 
input ENUM_TIMEFRAMES timeframe = PERIOD_CURRENT;

input group "Volatility Breakout Parameters"
input double inpBuyRangeMultiplier   = 0.50;   
input double inpSellRangeMultiplier  = 0.50;   
input double inpStopRangeMultiplier  = 0.50;
input double inpRewardValue          = 4.0;

input group "Trade and Risk Management"
input ENUM_TRADE_DIRECTION direction        = ONLY_LONG;
input ENUM_LOT_SIZE_INPUT_MODE lotSizeMode  = MODE_AUTO;
input double riskPerTradePercent            = 1.0;
input double positionSize                   = 0.1;


//+------------------------------------------------------------------+
//| Global Variables                                                 |
//+------------------------------------------------------------------+
//--- Create a CTrade object to handle trading operations
CTrade Trade;

//--- Bid and Ask
double   askPrice;
double   bidPrice;

//--- To help track new bar open
datetime lastBarOpenTime;


//--- Holds all price levels derived from Larry Williams' volatility breakout calculations
struct MqlLwVolatilityLevels
{
   double dominantSwingRange;      
   double buyEntryPrice;       
   double sellEntryPrice;   
   double bullishStopLoss;   
   double bearishStopLoss;    
   double bullishTakeProfit;
   double bearishTakeProfit;
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
   
   //--- Reset Larry Williams' volatility levels 
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
   askPrice      = SymbolInfoDouble (_Symbol, SYMBOL_ASK);
   bidPrice      = SymbolInfoDouble (_Symbol, SYMBOL_BID);   

   
   //--- Run this block only when a new bar is detected on the selected timeframe
   if(IsNewBar(_Symbol, timeframe, lastBarOpenTime)){
      lwVolatilityLevels.dominantSwingRange = CalculateLwSwingVolatilityRange(_Symbol, timeframe);
      lwVolatilityLevels.buyEntryPrice      = CalculateBuyEntryPrice (askPrice, lwVolatilityLevels.dominantSwingRange, inpBuyRangeMultiplier );
      lwVolatilityLevels.sellEntryPrice     = CalculateSellEntryPrice(bidPrice, lwVolatilityLevels.dominantSwingRange, inpSellRangeMultiplier);
      lwVolatilityLevels.bullishStopLoss    = CalculateBullishStopLoss(lwVolatilityLevels.buyEntryPrice, lwVolatilityLevels.dominantSwingRange,  inpStopRangeMultiplier);
      lwVolatilityLevels.bearishStopLoss    = CalculateBearishStopLoss(lwVolatilityLevels.sellEntryPrice, lwVolatilityLevels.dominantSwingRange, inpStopRangeMultiplier);
      lwVolatilityLevels.bullishTakeProfit  = CalculateBullishTakeProfit(lwVolatilityLevels.buyEntryPrice, lwVolatilityLevels.bullishStopLoss,  inpRewardValue);
      lwVolatilityLevels.bearishTakeProfit  = CalculateBearishTakeProfit(lwVolatilityLevels.sellEntryPrice, lwVolatilityLevels.bearishStopLoss, inpRewardValue);
   }

   
   //--- Get some minutes data
   if(CopyClose(_Symbol, PERIOD_M1, 0, 7, closePriceMinutesData) == -1){
      Print("Error while copying minutes datas ", GetLastError());
      return;
   }

   
   //--- Long position logic
   if(direction == TRADE_BOTH || direction == ONLY_LONG){
      if(IsCrossOver(lwVolatilityLevels.buyEntryPrice, closePriceMinutesData)){
         if(!IsThereAnActiveBuyPosition(magicNumber) && !IsThereAnActiveSellPosition(magicNumber)){
            OpenBuy(askPrice, lwVolatilityLevels.bullishStopLoss, lwVolatilityLevels.bullishTakeProfit, positionSize);
         }
      }
   }
   

   //--- Short position logic
   if(direction == TRADE_BOTH || direction == ONLY_SHORT){
      if(IsCrossUnder(lwVolatilityLevels.sellEntryPrice, closePriceMinutesData)){
         if(!IsThereAnActiveBuyPosition(magicNumber) && !IsThereAnActiveSellPosition(magicNumber)){
            OpenSel(bidPrice, lwVolatilityLevels.bearishStopLoss, lwVolatilityLevels.bearishTakeProfit, positionSize);
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
//| Calculates Larry Williams swing-based volatility range           |
//+------------------------------------------------------------------+
double CalculateLwSwingVolatilityRange(const string symbol, ENUM_TIMEFRAMES tf){
   
   //--- Retrieve required highs and lows
   double high_3_days_ago = iHigh(symbol, tf, 4);
   double low_yesterday   = iLow (symbol, tf, 1);

   double high_1_day_ago  = iHigh(symbol, tf, 2);
   double low_3_days_ago  = iLow (symbol, tf, 4);

   //--- Validate data
   if(high_3_days_ago == 0.0 || low_yesterday == 0.0 ||
      high_1_day_ago  == 0.0 || low_3_days_ago == 0.0)
   {
      return 0.0;
   }

   //--- Calculate swing distances using absolute values
   double swingRangeA = MathAbs(high_3_days_ago - low_yesterday);
   double swingRangeB = MathAbs(high_1_day_ago  - low_3_days_ago);

   //--- Select the dominant swing
   double usableRange = MathMax(swingRangeA, swingRangeB);

   //--- Normalize for symbol precision
   return NormalizeDouble(usableRange, (int)SymbolInfoInteger(symbol, SYMBOL_DIGITS));
}


//+------------------------------------------------------------------+
//| Calculates the bullish breakout entry price using today's open and swing range |
//+------------------------------------------------------------------+
double CalculateBuyEntryPrice(double todayOpen, double swingRange, double buyMultiplier){

   return todayOpen + (swingRange * buyMultiplier);
}


//+------------------------------------------------------------------+
//| Calculates the bearish breakout entry price using today's open and swing range |
//+------------------------------------------------------------------+
double CalculateSellEntryPrice(double todayOpen, double swingRange, double sellMultiplier){

   return todayOpen - (swingRange * sellMultiplier);
}


//+------------------------------------------------------------------+
//| Calculates the stop-loss price for a bullish position based on entry price and swing range |
//+------------------------------------------------------------------+
double CalculateBullishStopLoss(double entryPrice, double swingRange, double stopMultiplier){

   return entryPrice - (swingRange * stopMultiplier);
}

 
//+------------------------------------------------------------------+
//| Calculates the stop-loss price for a bearish position based on entry price and swing range |
//+------------------------------------------------------------------+
double CalculateBearishStopLoss(double entryPrice, double swingRange, double stopMultiplier){

   return entryPrice + (swingRange * stopMultiplier);
}


//+------------------------------------------------------------------+
//| Calculates take-profit level for a bullish trade using risk-reward logic |                               
//+------------------------------------------------------------------+
double CalculateBullishTakeProfit(double entryPrice, double stopLossPrice, double rewardValue){

   double stopDistance   = entryPrice - stopLossPrice;
   double rewardDistance = stopDistance * rewardValue;
   return NormalizeDouble(entryPrice + rewardDistance, Digits());
}


//+------------------------------------------------------------------+
//| Calculates take-profit level for a bearish trade using risk-reward logic |                               
//+------------------------------------------------------------------+
double CalculateBearishTakeProfit(double entryPrice, double stopLossPrice, double rewardValue){

   double stopDistance   = stopLossPrice - entryPrice;
   double rewardDistance = stopDistance * rewardValue;
   return NormalizeDouble(entryPrice - rewardDistance, Digits());
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
//| To detect a crossunder at a given price level                    |                               
//+------------------------------------------------------------------+
bool IsCrossUnder(const double price, const double &closePriceMinsData[]){
   if(closePriceMinsData[1] >= price && closePriceMinsData[0] < price){
      return true;
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
//| To verify whether this EA currently has an active sell position. |                                 |
//+------------------------------------------------------------------+
bool IsThereAnActiveSellPosition(ulong magic){
   
   for(int i = PositionsTotal() - 1; i >= 0; i--){
      ulong ticket = PositionGetTicket(i);
      if(ticket == 0){
         Print("Error while fetching position ticket ", _LastError);
         continue;
      }else{
         if(PositionGetInteger(POSITION_MAGIC) == magic && PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_SELL){
            return true;
         }
      }
   }
   
   return false;
}


//+------------------------------------------------------------------+
//| Calculates position size based on a fixed percentage risk of the account balance |
//+------------------------------------------------------------------+
double CalculatePositionSizeByRisk(double stopDistance){
   double amountAtRisk = (riskPerTradePercent / 100.0) * AccountInfoDouble(ACCOUNT_BALANCE);
   double contractSize = SymbolInfoDouble(_Symbol, SYMBOL_TRADE_CONTRACT_SIZE);
   double volume       = amountAtRisk / (contractSize * stopDistance);
   return NormalizeDouble(volume, 2);
}


//+------------------------------------------------------------------+
//| Function to open a market buy position                           |
//+------------------------------------------------------------------+
bool OpenBuy(double entryPrice, double stopLoss, double takeProfit, double lotSize){
   
   if(lotSizeMode == MODE_AUTO){
      lotSize = CalculatePositionSizeByRisk(lwVolatilityLevels.buyEntryPrice - lwVolatilityLevels.bullishStopLoss);
   }
   
   if(!Trade.Buy(lotSize, _Symbol, entryPrice, stopLoss, takeProfit)){
      Print("Error while executing a market buy order: ", GetLastError());
      Print(Trade.ResultRetcode());
      Print(Trade.ResultComment());
      return false;
   }
   return true;
}


//+------------------------------------------------------------------+
//| Function to open a market sell position                          |
//+------------------------------------------------------------------+
bool OpenSel(double entryPrice, double stopLoss, double takeProfit, double lotSize){
   
   if(lotSizeMode == MODE_AUTO){
      lotSize = CalculatePositionSizeByRisk(lwVolatilityLevels.bearishStopLoss - lwVolatilityLevels.sellEntryPrice);
   }
   
   if(!Trade.Sell(lotSize, _Symbol, entryPrice, stopLoss, takeProfit)){
      Print("Error while executing a market sell order: ", GetLastError());
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
