
//+------------------------------------------------------------------+
//|                                lwSmashDayTrendFilteredExpert.mq5 |
//|          Copyright 2026, MetaQuotes Ltd. Developer is Chacha Ian |
//|Larry Williams Market Secrets                                     |
//|12. Context-Based Trading of Smash Day Reversals with an Expert   |
//|                     https://www.mql5.com/en/articles/21228       |
//+------------------------------------------------------------------+

#property copyright "Copyright 2026, MetaQuotes Ltd. Developer is Chacha Ian"
#property link      "https://www.mql5.com/en/users/chachaian"
#property version   "1.00"
#resource "\\Indicators\\supertrend.ex5"


//+------------------------------------------------------------------+
//| Standard Libraries                                               |
//+------------------------------------------------------------------+
#include <Trade\Trade.mqh>


//+------------------------------------------------------------------+
//| Custom Enumerations                                              |
//+------------------------------------------------------------------+
enum ENUM_TDW_MODE
{
   TDW_ALL_DAYS,     
   TDW_SELECTED_DAYS
};

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
input int smashBuyLookbackBars   = 1;
input int smashSellLookbackBars  = 1;
input int smashSetupValidityBars = 3;

input group "Smash Day Entry Settings"
input ENUM_SMASH_ENTRY_MODE smashEntryMode = ENTRY_ON_LEVEL_CROSS;
input ENUM_SMASH_TRADE_MODE smashTradeMode = SMASH_TRADE_BOTH;

input group "Supertrend configuration parameters"
input bool useSupertrendFilter            = false;
input ENUM_TIMEFRAMES supertrendTimeframe = PERIOD_CURRENT;
input int32_t supertrendAtrPeriod         = 10;
input double  supertrendAtrMultiplier     = 1.5;

input group "TDW filters"
input ENUM_TDW_MODE tradeDayMode = TDW_SELECTED_DAYS;
input bool tradeSunday           = false;
input bool tradeMonday           = true;
input bool tradeTuesday          = false;
input bool tradeWednesday        = false;
input bool tradeThursday         = false;
input bool tradeFriday           = false;
input bool tradeSaturday         = false;

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

//--- Supertrend values 
int    supertrendIndicatorHandle;
double upperBandValues[];
double lowerBandValues[];

//--- To help track new bar open
datetime lastBarOpenTime;

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
   
   //--- Tracks the number of bars elapsed after the occurence of the smash bar
   int barsSinceSmash;
   
   //--- Stop-Loss levels
   double buyStopLoss;
   double sellStopLoss;
   
};

MqlSmashDayPatternState smashState;

//--- To store minutes data
double closePriceMinutesData [];


//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit(){

   //---  Assign a unique magic number to identify trades opened by this EA
   Trade.SetExpertMagicNumber(magicNumber);
   
   // Initialize the Supertrend Indicator
   supertrendIndicatorHandle = iCustom(_Symbol, supertrendTimeframe, "::Indicators\\supertrend.ex5", supertrendAtrPeriod, supertrendAtrMultiplier);
   if(supertrendIndicatorHandle == INVALID_HANDLE){
      Print("Error while initializing the Supertrend indicator", GetLastError());
      return(INIT_FAILED);
   }
   
   //--- Treat the following arrays as timeseries (index 0 becomes the most recent bar)
   ArraySetAsSeries(closePriceMinutesData, true);
   ArraySetAsSeries(upperBandValues, true);
   ArraySetAsSeries(lowerBandValues, true);
   
   //--- Initialize global variables
   lastBarOpenTime = 0;
   
   //--- Reset
   ZeroMemory(smashState);
   
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

   //--- Release Supertrend
   if(supertrendIndicatorHandle != INVALID_HANDLE){
      IndicatorRelease(supertrendIndicatorHandle);
   }

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
   
   //--- Update Supertrend
   UpdateSupertrendBandValues();
   
   //--- Execute this block on new bar formation
   if(IsNewBar(_Symbol, timeframe, lastBarOpenTime)){
      
      //---
      if(!smashState.hasBuySmashSetup && !smashState.hasSellSmashSetup){
         if(IsSmashDayBuyReversal(_Symbol, timeframe, 1, smashBuyLookbackBars)){
            smashState.hasBuySmashSetup = true;
            smashState.buyBreakoutLevel = iHigh(_Symbol, timeframe, 1);
            smashState.smashBarTime     = iTime(_Symbol, timeframe, 1);
            smashState.entryPending     = true;
            smashState.buyStopLoss      = iLow(_Symbol, timeframe, 1);
         }
               
         //---
         if(IsSmashDaySellReversal(_Symbol, timeframe, 1, smashSellLookbackBars)){
            smashState.hasSellSmashSetup = true;
            smashState.sellBreakoutLevel = iLow(_Symbol, timeframe, 1);
            smashState.smashBarTime      = iTime(_Symbol, timeframe, 1);
            smashState.entryPending      = true;
            smashState.sellStopLoss      = iHigh(_Symbol, timeframe, 1);
         }
      }else{
      
         smashState.barsSinceSmash = smashState.barsSinceSmash + 1;
      
         if(smashState.barsSinceSmash > smashSetupValidityBars){
            ZeroMemory(smashState);
         }
      
      }
      
      //---
      if(smashState.hasBuySmashSetup && smashState.entryPending){
         if(!IsThereAnActiveBuyPosition(magicNumber) && !IsThereAnActiveSellPosition(magicNumber)){
            if(smashTradeMode == SMASH_TRADE_BUY_ONLY || smashTradeMode == SMASH_TRADE_BOTH){
               if(askPrice > smashState.buyBreakoutLevel){
                  if(useSupertrendFilter){
                     if(IsSupertrendCurrentlyBullish()){
                        if(tradeDayMode == TDW_SELECTED_DAYS){
                           if(IsTradingDayAllowed(currentTime)){
                              OpenBuy(askPrice, smashState.buyStopLoss, GetBuyTakeProfit(askPrice, smashState.buyStopLoss), positionSize);
                              ZeroMemory(smashState);
                           }
                        }else{
                           OpenBuy(askPrice, smashState.buyStopLoss, GetBuyTakeProfit(askPrice, smashState.buyStopLoss), positionSize);
                           ZeroMemory(smashState);
                        }
                     }
                  }else{
                     if(tradeDayMode == TDW_SELECTED_DAYS){
                        if(IsTradingDayAllowed(currentTime)){
                           OpenBuy(askPrice, smashState.buyStopLoss, GetBuyTakeProfit(askPrice, smashState.buyStopLoss), positionSize);
                           ZeroMemory(smashState);
                        }
                     }else{
                        OpenBuy(askPrice, smashState.buyStopLoss, GetBuyTakeProfit(askPrice, smashState.buyStopLoss), positionSize);
                        ZeroMemory(smashState);
                     }
                  }
               }
            }
         }
      }
      
      //---
      if(smashState.hasSellSmashSetup && smashState.entryPending){
         if(!IsThereAnActiveBuyPosition(magicNumber) && !IsThereAnActiveSellPosition(magicNumber)){
            if(smashTradeMode == SMASH_TRADE_SELL_ONLY || smashTradeMode == SMASH_TRADE_BOTH){
               if(bidPrice < smashState.sellBreakoutLevel){
                  if(useSupertrendFilter){
                     if(IsSupertrendCurrentlyBearish()){
                        if(tradeDayMode == TDW_SELECTED_DAYS){
                           if(IsTradingDayAllowed(currentTime)){
                              OpenSel(bidPrice, smashState.sellStopLoss, GetSellTakeProfit(bidPrice, smashState.sellStopLoss), positionSize);
                              ZeroMemory(smashState);
                           }
                        }else{
                              OpenSel(bidPrice, smashState.sellStopLoss, GetSellTakeProfit(bidPrice, smashState.sellStopLoss), positionSize);
                              ZeroMemory(smashState);
                        }
                     }
                  }else{
                     if(tradeDayMode == TDW_SELECTED_DAYS){
                        if(IsTradingDayAllowed(currentTime)){
                           OpenSel(bidPrice, smashState.sellStopLoss, GetSellTakeProfit(bidPrice, smashState.sellStopLoss), positionSize);
                           ZeroMemory(smashState);
                        }
                     }else{
                        OpenSel(bidPrice, smashState.sellStopLoss, GetSellTakeProfit(bidPrice, smashState.sellStopLoss), positionSize);
                        ZeroMemory(smashState);
                     }
                  }
               }
            }
         }
      }
      
   }
   
   //---
   if(smashEntryMode == ENTRY_ON_LEVEL_CROSS){
   
      //---
      if(smashState.hasBuySmashSetup && smashState.entryPending){
         // ---
         if(IsCrossOver(smashState.buyBreakoutLevel, closePriceMinutesData)){
            if(!IsThereAnActiveBuyPosition(magicNumber) && !IsThereAnActiveSellPosition(magicNumber)){
               if(smashTradeMode == SMASH_TRADE_BUY_ONLY  || smashTradeMode == SMASH_TRADE_BOTH){
                  if(useSupertrendFilter){
                     if(IsSupertrendCurrentlyBullish()){
                        if(tradeDayMode == TDW_SELECTED_DAYS){
                           if(IsTradingDayAllowed(currentTime)){
                              OpenBuy(askPrice, smashState.buyStopLoss, GetBuyTakeProfit(askPrice, smashState.buyStopLoss), positionSize);
                              ZeroMemory(smashState);
                           }
                        }else{
                           OpenBuy(askPrice, smashState.buyStopLoss, GetBuyTakeProfit(askPrice, smashState.buyStopLoss), positionSize);
                           ZeroMemory(smashState);
                        }
                     }
                  }else{
                     if(tradeDayMode == TDW_SELECTED_DAYS){
                        if(IsTradingDayAllowed(currentTime)){
                           OpenBuy(askPrice, smashState.buyStopLoss, GetBuyTakeProfit(askPrice, smashState.buyStopLoss), positionSize);
                           ZeroMemory(smashState);
                        }
                     }else{
                        OpenBuy(askPrice, smashState.buyStopLoss, GetBuyTakeProfit(askPrice, smashState.buyStopLoss), positionSize);
                        ZeroMemory(smashState);
                     }
                  }
               }
            }
         }
      }
      
      //---
      if(smashState.hasSellSmashSetup && smashState.entryPending){
         // ---
         if(IsCrossUnder(smashState.sellBreakoutLevel, closePriceMinutesData)){
            if(!IsThereAnActiveBuyPosition(magicNumber) && !IsThereAnActiveSellPosition(magicNumber)){
               if(smashTradeMode == SMASH_TRADE_SELL_ONLY || smashTradeMode == SMASH_TRADE_BOTH){
                  if(useSupertrendFilter){
                     if(IsSupertrendCurrentlyBearish()){
                        if(tradeDayMode == TDW_SELECTED_DAYS){
                           if(IsTradingDayAllowed(currentTime)){
                              OpenSel(bidPrice, smashState.sellStopLoss, GetSellTakeProfit(bidPrice, smashState.sellStopLoss), positionSize);
                              ZeroMemory(smashState);
                           }
                        }else{
                           OpenSel(bidPrice, smashState.sellStopLoss, GetSellTakeProfit(bidPrice, smashState.sellStopLoss), positionSize);
                           ZeroMemory(smashState);
                        }
                     }
                  }else{
                     if(tradeDayMode == TDW_SELECTED_DAYS){
                        if(IsTradingDayAllowed(currentTime)){
                           OpenSel(bidPrice, smashState.sellStopLoss, GetSellTakeProfit(bidPrice, smashState.sellStopLoss), positionSize);
                           ZeroMemory(smashState);
                        }
                     }else{
                        OpenSel(bidPrice, smashState.sellStopLoss, GetSellTakeProfit(bidPrice, smashState.sellStopLoss), positionSize);
                        ZeroMemory(smashState);
                     }
                  }
               }
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
//| Fetches recent Supertrend upper and lower band values            |
//+------------------------------------------------------------------+
void UpdateSupertrendBandValues(){

   //--- Get a few Supertrend upper band values
   int copiedUpper = CopyBuffer(supertrendIndicatorHandle, 5, 0, 5, upperBandValues);
   if(copiedUpper == -1)
   {
      Print("Error while copying Supertrend upper band values: ", GetLastError());
      return;
   }

   //--- Get a few Supertrend lower band values
   int copiedLower = CopyBuffer(supertrendIndicatorHandle, 6, 0, 5, lowerBandValues);
   if(copiedLower == -1)
   {
      Print("Error while copying Supertrend lower band values: ", GetLastError());
      return;
   }
   
   if(copiedUpper < 5 || copiedLower < 5){
      Print("Insufficient Supertrend indicator data!");
      return;
   }
   
}


//+------------------------------------------------------------------+
//| Returns true if Supertrend is currently in a bullish trend state |
//+------------------------------------------------------------------+
bool IsSupertrendCurrentlyBullish(){

   if(lowerBandValues[1] != EMPTY_VALUE){
      return true;
   }

   return false;
}


//+------------------------------------------------------------------+
//| Returns true if Supertrend is currently in a bearish trend state |
//+------------------------------------------------------------------+
bool IsSupertrendCurrentlyBearish(){

   if(upperBandValues[1] != EMPTY_VALUE){
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
