
//+------------------------------------------------------------------+
//|                                     lwSmashDayReversalExpert.mq5 |
//|Larry Williams Market Secrets                                     |
//|10. Automating Smash Day Reversal Patterns                        |
//|                     https://www.mql5.com/en/articles/21127       |
//+------------------------------------------------------------------+

#property copyright "Copyright 2026, MetaQuotes Ltd. Developer is Chacha Ian"
#property link      "https://www.mql5.com/en/users/chachaian"
#property version   "1.00"


//+------------------------------------------------------------------+
//| Standard Libraries                                               |
//+------------------------------------------------------------------+
#include <Trade\Trade.mqh>


//+------------------------------------------------------------------+
//| Custom Enumerations                                              |
//+------------------------------------------------------------------+
enum ENUM_SMASH_ENTRY_MODE{
   ENTRY_ON_LEVEL_CROSS,
   ENTRY_ON_BAR_CLOSE
};

enum ENUM_SMASH_TRADE_MODE
{
   SMASH_TRADE_BUY_ONLY,
   SMASH_TRADE_SELL_ONLY,
   SMASH_TRADE_BOTH
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

input group "Smash Day Pattern Rules"
input int smashBuyLookbackBars  = 1;
input int smashSellLookbackBars = 1;

input group "Smash Day Entry Settings"
input ENUM_SMASH_ENTRY_MODE smashEntryMode = ENTRY_ON_LEVEL_CROSS;
input ENUM_SMASH_TRADE_MODE smashTradeMode = SMASH_TRADE_BOTH;

input group "Trade and Risk Management"
input ENUM_LOT_SIZE_INPUT_MODE lotSizeMode  = MODE_AUTO;
input double riskPerTradePercent            = 1.0;
input double positionSize                   = 0.1;
input double riskRewardRatio                = 3.0;


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

struct MqlSmashDayPatternState{

   //--- Pattern detection flags
   bool hasBuySmashSetup;
   bool hasSellSmashSetup;

   //--- Reference breakout levels from smash bar
   double buyBreakoutLevel;
   double sellBreakoutLevel;

   //--- Pattern bar reference data
   datetime smashBarTime;

   //--- Entry status tracking
   bool entryPending;
   
   //--- Stop-Loss levels
   double buyStopLoss;
   double sellStopLoss;
   
};

MqlSmashDayPatternState smashState;

//--- To store minutes data
double closePriceMinutesData [];

//--- To help track new bar open
datetime lastBarOpenTime;


//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit(){

   //---  Assign a unique magic number to identify trades opened by this EA
   Trade.SetExpertMagicNumber(magicNumber);
   
   //--- Reset
   ZeroMemory(smashState);
   
   //--- Treat the following arrays as timeseries (index 0 becomes the most recent bar)
   ArraySetAsSeries(closePriceMinutesData, true);
   
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
   askPrice    = SymbolInfoDouble (_Symbol, SYMBOL_ASK);
   bidPrice    = SymbolInfoDouble (_Symbol, SYMBOL_BID);
   currentTime = TimeCurrent();
   
   //--- Get some minutes data
   if(CopyClose(_Symbol, PERIOD_M1, 0, 7, closePriceMinutesData) == -1){
      Print("Error while copying minutes datas ", GetLastError());
      return;
   }
   
   //--- Execute this block on new bar formation
   if(IsNewBar(_Symbol, timeframe, lastBarOpenTime)){
      
      //---
      if(smashEntryMode == ENTRY_ON_BAR_CLOSE){
         
         //---
         if(smashState.hasBuySmashSetup && smashState.entryPending){
            if(!IsThereAnActiveBuyPosition(magicNumber) && !IsThereAnActiveSellPosition(magicNumber)){
               if(smashTradeMode == SMASH_TRADE_BUY_ONLY || smashTradeMode == SMASH_TRADE_BOTH){
                  OpenBuy(askPrice, smashState.buyStopLoss, GetBuyTakeProfit(askPrice, smashState.buyStopLoss), positionSize);
                  smashState.entryPending = false;
               }
            }
         }
         
         //---
         if(smashState.hasSellSmashSetup && smashState.entryPending){
            if(!IsThereAnActiveBuyPosition(magicNumber) && !IsThereAnActiveSellPosition(magicNumber)){
               if(smashTradeMode == SMASH_TRADE_SELL_ONLY || smashTradeMode == SMASH_TRADE_BOTH){
                  OpenSel(bidPrice, smashState.sellStopLoss, GetSellTakeProfit(bidPrice, smashState.sellStopLoss), positionSize);
                  smashState.entryPending = false;
               }
            }
         }
         
      }
      
      //---
      ResetSmashDaySetupState();
      
      //---
      if(IsSmashDayBuyReversal(_Symbol, timeframe, 1,  smashBuyLookbackBars)){
         smashState.hasBuySmashSetup = true;
         smashState.entryPending     = true;
         smashState.buyStopLoss      = iLow(_Symbol, timeframe, 1);
      }
      
      //---
      if(IsSmashDaySellReversal(_Symbol, timeframe, 1, smashSellLookbackBars)){
         smashState.hasSellSmashSetup = true;
         smashState.entryPending      = true;
         smashState.sellStopLoss      = iHigh(_Symbol, timeframe, 1);
      }
      
   }
   
   //---
   if(smashEntryMode == ENTRY_ON_LEVEL_CROSS){
      
      //---
      if(smashState.hasBuySmashSetup && smashState.entryPending){
         // ---
         if(IsCrossOver(smashState.buyBreakoutLevel, closePriceMinutesData)){
            if(!IsThereAnActiveBuyPosition(magicNumber) && !IsThereAnActiveSellPosition(magicNumber)){
               if(smashTradeMode == SMASH_TRADE_BUY_ONLY || smashTradeMode == SMASH_TRADE_BOTH){
                  OpenBuy(askPrice, smashState.buyStopLoss, GetBuyTakeProfit(askPrice, smashState.buyStopLoss), positionSize);       
               }
               smashState.hasBuySmashSetup = false;
               smashState.entryPending     = false;
            }
         }
      }
      
      //---
      if(smashState.hasSellSmashSetup && smashState.entryPending){
         // ---
         if(IsCrossUnder(smashState.sellBreakoutLevel, closePriceMinutesData)){
            if(!IsThereAnActiveBuyPosition(magicNumber) && !IsThereAnActiveSellPosition(magicNumber)){
               if(smashTradeMode == SMASH_TRADE_SELL_ONLY || smashTradeMode == SMASH_TRADE_BOTH){
                  OpenSel(bidPrice, smashState.sellStopLoss, GetSellTakeProfit(bidPrice, smashState.sellStopLoss), positionSize);
               }
               smashState.hasSellSmashSetup = false;
               smashState.entryPending      = false;
            }
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
//| Checks whether the bar at the given index fully engulfs the prior bar range |
//+------------------------------------------------------------------+
bool IsOutsideBar(string symbol, ENUM_TIMEFRAMES tf, int index){

   double high0 = iHigh(symbol, tf, index);
   double low0  = iLow (symbol, tf, index);

   double high1 = iHigh(symbol, tf, index + 1);
   double low1  = iLow (symbol, tf, index + 1);

   return (high0 > high1 && low0 < low1);
}


//+------------------------------------------------------------------+
//| Detects a Smash Day Buy Reversal where the close breaks below multiple prior lows |
//+------------------------------------------------------------------+
bool IsSmashDayBuyReversal(string symbol,
                           ENUM_TIMEFRAMES tf,
                           int index,
                           int lookbackBars)
{
   // Bar must not be an outside bar
   if(IsOutsideBar(symbol, tf, index))
      return false;

   double close1 = iClose(symbol, tf, index);

   // Validate close breaks below N prior lows
   for(int i = 2; i <= lookbackBars + 1; i++)
   {
      double priorLow = iLow(symbol, tf, i);

      if(close1 >= priorLow)
         return false;
   }

   return true;
}


//+------------------------------------------------------------------+
//| Detects a Smash Day Sell Reversal where the close breaks above multiple prior highs |
//+------------------------------------------------------------------+
bool IsSmashDaySellReversal(string symbol,
                            ENUM_TIMEFRAMES tf,
                            int index,
                            int lookbackBars)
{
   // Bar must not be an outside bar
   if(IsOutsideBar(symbol, tf, index))
      return false;

   double close1 = iClose(symbol, tf, index);

   // Validate close breaks above N prior highs
   for(int i = 2; i <= lookbackBars + 1; i++)
   {
      double priorHigh = iHigh(symbol, tf, i);

      if(close1 <= priorHigh)
         return false;
   }

   return true;
}


//+------------------------------------------------------------------+
//| Resets all Smash Day detection flags and breakout reference levels |
//+------------------------------------------------------------------+
void ResetSmashDaySetupState(){

   smashState.hasBuySmashSetup  = false;
   smashState.hasSellSmashSetup = false;

   smashState.buyBreakoutLevel  = iHigh(_Symbol, timeframe, 1);
   smashState.sellBreakoutLevel = iLow(_Symbol, timeframe, 1);

   smashState.smashBarTime      = iTime(_Symbol, timeframe, 1);
   
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
//| Computes the bullish take profit level based on entry price, stop loss, and risk to reward ratio |
//+------------------------------------------------------------------+
double GetBuyTakeProfit(double entryPrice, double stopLoss){
   double riskDistance = entryPrice - stopLoss;
   double rewardDistance = riskDistance * riskRewardRatio;
   rewardDistance = MathAbs(rewardDistance);
   return NormalizeDouble((entryPrice + rewardDistance), Digits());
}


//+------------------------------------------------------------------+
//| Computes the bearish take profit level based on entry price, stop loss, and risk to reward ratio |
//+------------------------------------------------------------------+
double GetSellTakeProfit(double entryPrice, double stopLoss){
   double riskDistance = stopLoss - entryPrice;
   double rewardDistance = riskDistance * riskRewardRatio;
   rewardDistance = MathAbs(rewardDistance);
   return NormalizeDouble((entryPrice - rewardDistance), Digits());
}


//+------------------------------------------------------------------+
//| Function to open a market buy position                           |
//+------------------------------------------------------------------+
bool OpenBuy(double entryPrice, double stopLoss, double takeProfit, double lotSize){
   
   if(lotSizeMode == MODE_AUTO){
      lotSize = CalculatePositionSizeByRisk(entryPrice - stopLoss);
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
      lotSize = CalculatePositionSizeByRisk(stopLoss - entryPrice);
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
