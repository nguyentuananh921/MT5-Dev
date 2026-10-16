
//+------------------------------------------------------------------+
//|                                       lwHiddenSmashDayExpert.mq5 |
//|          Copyright 2026, MetaQuotes Ltd. Developer is Chacha Ian |
//|Larry Williams Market Secrets                                     |
//|13. Automating Hidden Smash Day Reversal Patterns                 |
//|                     https://www.mql5.com/en/articles/21391        |
//+------------------------------------------------------------------+

#property copyright "Copyright 2026, MetaQuotes Ltd. Developer is Chacha Ian"
#property link      "https://www.mql5.com/en/users/chachaian"
#property version   "1.00"


//+------------------------------------------------------------------+
//| Standard Libraries                                               |
//+------------------------------------------------------------------+
#include <Trade\Trade.mqh>


//+------------------------------------------------------------------+
//| Defines how stop loss levels are determined for smash day trades |
//+------------------------------------------------------------------+
enum ENUM_STOP_LOSS_MODE
{
   SL_ATR_BASED,            
   SL_SMASH_BAR_STRUCTURE
};


//+------------------------------------------------------------------+
//| Defines the trade direction                                      |
//+------------------------------------------------------------------+
enum ENUM_TRADE_DIRECTION
{
   TRADE_LONG,
   TRADE_SHORT,
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
input ulong magicNumber          = 254700680002;                 
input ENUM_TIMEFRAMES timeframe  = PERIOD_CURRENT;

input group "ATR configuration parameters"
input int32_t atrPeriod          = 14;
input double  atrMultiplier      = 2.0;

input group "Trade and Risk Management"
input ENUM_STOP_LOSS_MODE smashStopLossMode = SL_SMASH_BAR_STRUCTURE;
input double rewardRiskRatio                = 3.0;
input ENUM_TRADE_DIRECTION direction        = TRADE_LONG;
input ENUM_LOT_SIZE_INPUT_MODE lotSizeMode  = MODE_AUTO;
input double riskPerTradePercent            = 1.0;
input double positionSize                   = 0.1;


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

//--- ATR Values
int atrHandle;
double atrValues [];

//--- Protective stops
double stopLossLevel;
double takeProfitLevel;


//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit(){

   //---  Assign a unique magic number to identify trades opened by this EA
   Trade.SetExpertMagicNumber(magicNumber);
   
   //--- Initialize global variables
   lastBarOpenTime = 0;
   
   //--- Initialize the ATR indicator
   atrHandle = iATR(_Symbol, timeframe, atrPeriod);
   if(atrHandle == INVALID_HANDLE){
      Print("Error while initializing the ATR indicator ", GetLastError());
      return(INIT_FAILED);
   }
   
   //--- Treat the following arrays as timeseries (index 0 becomes the most recent bar)
   ArraySetAsSeries(atrValues, true);
   
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
   
   //--- Release ATR
   if(atrHandle != INVALID_HANDLE){
      if(IndicatorRelease(atrHandle)){
         Print("The computer memory tracking ATR has been freed.");
      }
   }

}


//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick(){

   //--- Retrieve current market prices for trade execution
   askPrice    = SymbolInfoDouble (_Symbol, SYMBOL_ASK);
   bidPrice    = SymbolInfoDouble (_Symbol, SYMBOL_BID);
   currentTime = TimeCurrent();
   
   //--- Execute on new bar open
   if(IsNewBar(_Symbol, timeframe, lastBarOpenTime)){
   
      //--- Update ATR Values
      UpdateATRValues();
      
      if(IsHiddenSmashDayBuySignal(1)) {
         
         Print("New Bar!!!");
         stopLossLevel   = ComputeStopLossLevel(TRADE_LONG, smashStopLossMode, 2);
         takeProfitLevel = ComputeTakeProfitLevel(TRADE_LONG, stopLossLevel);
         
         if(!IsThereAnActiveBuyPosition(magicNumber) && !IsThereAnActiveSellPosition(magicNumber)){
            if(direction == TRADE_LONG || direction == TRADE_BOTH){
               OpenBuy(askPrice, stopLossLevel, takeProfitLevel, positionSize);
            }
         }      
      }
      
      if(IsHiddenSmashDaySellSignal(1)){
         
         Print("New Bar!!!");
         stopLossLevel   = ComputeStopLossLevel(TRADE_SHORT, smashStopLossMode, 2);
         takeProfitLevel = ComputeTakeProfitLevel(TRADE_SHORT, stopLossLevel);
         
         if(!IsThereAnActiveBuyPosition(magicNumber) && !IsThereAnActiveSellPosition(magicNumber)){
            if(direction == TRADE_SHORT || direction == TRADE_BOTH){
               OpenSell(bidPrice, stopLossLevel, takeProfitLevel, positionSize);
            }
         } 
      }
   }

}


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
//| To update ATR values                                             |
//+------------------------------------------------------------------+
void UpdateATRValues(){
   
   //--- Get some ATR Values
   int numberOfCopiedATRValues = CopyBuffer(atrHandle, 0, 0, 5, atrValues);
   if(numberOfCopiedATRValues == -1){
      Print("Error while copying ATR values: ", GetLastError());
   }

}


//+------------------------------------------------------------------+
//| Returns true if the bar at index forms a Hidden Smash Day Buy Bar |
//| Logic aligned with indicator implementation                      |
//+------------------------------------------------------------------+
bool IsHiddenSmashDayBuyBar(string symbol, ENUM_TIMEFRAMES tf, int index, double closePercentThreshold = 25.0, bool allowBullishClose = true, bool allowBearishClose = true){

   //--- We need at least one previous bar
   if(index < 1){
      return false;
   }

   double high  = iHigh(symbol, tf, index);
   double low   = iLow(symbol, tf, index);
   double open  = iOpen(symbol, tf, index);
   double close = iClose(symbol, tf, index);

   double prevClose = iClose(symbol, tf, index + 1);

   double range = high - low;
   if(range <= 0.0)
      return false;

   //--- 1. Must close higher than previous bar
   if(close <= prevClose)
      return false;

   //--- 2. Close must be in lower portion of its own range
   double closePositionPercent = ((close - low) / range) * 100.0;
   if(closePositionPercent > closePercentThreshold)
      return false;

   //--- 3. Optional candle direction filter
   if(close > open && !allowBullishClose)
      return false;

   if(close < open && !allowBearishClose)
      return false;

   return true;
}


//+------------------------------------------------------------------+
//| Returns true if the bar at index forms a Hidden Smash Day Sell Bar |
//| Logic aligned with indicator implementation                      |
//+------------------------------------------------------------------+
bool IsHiddenSmashDaySellBar(string symbol, ENUM_TIMEFRAMES tf, int index, double closePercentThreshold = 25.0, bool allowBullishClose = true, bool allowBearishClose = true){

   //--- We need at least one previous bar
   if(index < 1){
      return false;
   }

   double high  = iHigh(symbol, tf, index);
   double low   = iLow(symbol, tf, index);
   double open  = iOpen(symbol, tf, index);
   double close = iClose(symbol, tf, index);

   double prevClose = iClose(symbol, tf, index + 1);

   double range = high - low;
   if(range <= 0.0)
      return false;

   //--- 1. Must close lower than previous bar
   if(close >= prevClose)
      return false;

   //--- 2. Close must be in upper portion of its own range
   double closePositionPercent = ((high - close) / range) * 100.0;
   if(closePositionPercent > closePercentThreshold)
      return false;

   //--- 3. Optional candle direction filter
   if(close > open && !allowBullishClose)
      return false;

   if(close < open && !allowBearishClose)
      return false;

   return true;
}


//+------------------------------------------------------------------+
//| Confirms a Hidden Smash Day Buy signal using a confirming bar    |
//+------------------------------------------------------------------+
bool IsHiddenSmashDayBuySignal(int confirmingBarIndex){

   int smashBarIndex = confirmingBarIndex + 1;

   //--- Verify smash bar exists and is valid
   if(!IsHiddenSmashDayBuyBar(_Symbol, timeframe, smashBarIndex))
      return false;

   //--- Confirmation requires a close above the smash bar high
   if(iClose(_Symbol, timeframe, confirmingBarIndex) >
      iHigh (_Symbol, timeframe, smashBarIndex)){
      return true;
   }

   return false;
}


//+------------------------------------------------------------------+
//| Confirms a Hidden Smash Day Sell signal using a confirming bar   |
//+------------------------------------------------------------------+
bool IsHiddenSmashDaySellSignal(int confirmingBarIndex){

   int smashBarIndex = confirmingBarIndex + 1;

   //--- Verify smash bar exists and is valid
   if(!IsHiddenSmashDaySellBar(_Symbol, timeframe, smashBarIndex))
      return false;

   //--- Confirmation requires a close below the smash bar low
   if(iClose(_Symbol, timeframe, confirmingBarIndex) <
      iLow  (_Symbol, timeframe, smashBarIndex)){
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
//| Computes the stop loss level based on direction and SL mode      |
//+------------------------------------------------------------------+
double ComputeStopLossLevel(ENUM_TRADE_DIRECTION tDirection,
                            ENUM_STOP_LOSS_MODE  slMode,
                            int smashBarIndex)
{
   double slLevel = 0.0;

   //--- ATR based stop loss
   if(slMode == SL_ATR_BASED)
   {
      double atrValue = atrValues[0] * atrMultiplier;

      if(tDirection == TRADE_LONG)
         slLevel = askPrice - atrValue;
      else
         slLevel = bidPrice + atrValue;
   }
   //--- Smash bar structure based stop loss
   else if(slMode == SL_SMASH_BAR_STRUCTURE)
   {
      if(tDirection == TRADE_LONG)
         slLevel = iLow(_Symbol, timeframe, smashBarIndex);
      else
         slLevel = iHigh(_Symbol, timeframe, smashBarIndex);
   }

   return NormalizeDouble(slLevel, Digits());
}


//+------------------------------------------------------------------+
//| Computes the take profit level using risk reward ratio           |
//+------------------------------------------------------------------+
double ComputeTakeProfitLevel(ENUM_TRADE_DIRECTION tDirection,
                              double stopLoss)
{
   double entryPrice;
   double riskDistance;
   double takeProfit;

   if(tDirection == TRADE_LONG)
   {
      entryPrice   = askPrice;
      riskDistance = entryPrice - stopLossLevel;
      takeProfit   = entryPrice + (riskDistance * rewardRiskRatio);
   }
   else
   {
      entryPrice   = bidPrice;
      riskDistance = stopLossLevel - entryPrice;
      takeProfit   = entryPrice - (riskDistance * rewardRiskRatio);
   }

   return NormalizeDouble(takeProfit, Digits());
}


//+------------------------------------------------------------------+
//| Calculates position size using OrderCalcProfit for accuracy      |
//+------------------------------------------------------------------+
double CalculatePositionSizeByRisk(
   ENUM_ORDER_TYPE orderType,
   double entryPrice,
   double stopLossPrice
)
{
   //--- Amount willing to risk
   double amountAtRisk = (riskPerTradePercent / 100.0) *
                         AccountInfoDouble(ACCOUNT_BALANCE);

   //--- Calculate loss for 1 lot
   double lossPerLot = 0.0;

   if(!OrderCalcProfit(orderType,
                       _Symbol,
                       1.0,              // 1 lot
                       entryPrice,
                       stopLossPrice,
                       lossPerLot))
   {
      Print("OrderCalcProfit failed: ", GetLastError());
      return 0.0;
   }

   // Loss will be negative for losing scenario
   lossPerLot = MathAbs(lossPerLot);

   if(lossPerLot <= 0.0)
      return 0.0;

   //--- Raw volume
   double volume = amountAtRisk / lossPerLot;

   //--- Apply broker constraints
   double minLot   = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MIN);
   double maxLot   = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MAX);
   double lotStep  = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_STEP);

   // Normalize to step
   volume = MathFloor(volume / lotStep) * lotStep;

   if(volume < minLot)
      volume = minLot;

   if(volume > maxLot)
      volume = maxLot;

   return NormalizeDouble(volume, 2);
}


//+------------------------------------------------------------------+
//| Function to open a market buy position                           |
//+------------------------------------------------------------------+
bool OpenBuy(double entryPrice, double stopLoss, double takeProfit, double lotSize){
   
   if(lotSizeMode == MODE_AUTO){
      lotSize = CalculatePositionSizeByRisk(ORDER_TYPE_BUY, entryPrice, stopLoss);
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
bool OpenSell(double entryPrice, double stopLoss, double takeProfit, double lotSize){
   
   if(lotSizeMode == MODE_AUTO){
      lotSize = CalculatePositionSizeByRisk(ORDER_TYPE_SELL, entryPrice, stopLoss);
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
