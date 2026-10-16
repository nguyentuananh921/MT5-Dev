
//+------------------------------------------------------------------+
//|                                           lwPatternsToprofit.mq5 |
//|Larry Williams Market Secrets                                     |
//|9. Profitable Reversals: Advanced Pattern Trading Techniques      |
//|                     https://www.mql5.com/en/articles/21063       |
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

enum ENUM_LW_STRATEGY_MODE
{
   LW_STRATEGY_BASELINE_BUY_OPEN,
   LW_STRATEGY_CONSECUTIVE_BEARISH_BARS,
   LW_STRATEGY_UPTREND_WITH_PULLBACK,
   LW_STRATEGY_OUTSIDE_DAY_DOWN_CLOSE,
   LW_STRATEGY_THIRD_BULLISH_DAY_FADE
};


enum ENUM_TDW_MODE
{
   TDW_ALL_DAYS,     
   TDW_SELECTED_DAYS
};

enum ENUM_BAR_CLOSE_STATE
{
   BAR_CLOSE_UP, 
   BAR_CLOSE_DOWN
};

enum ENUM_STOP_LOSS_MODE
{
   SL_BY_RANGE_PERCENT,
   SL_AT_PREVIOUS_BAR
};


enum ENUM_TAKE_PROFIT_MODE
{
   TP_FIRST_PROFITABLE_OPEN,
   TP_AFTER_N_CANDLES,
   TP_BY_RISK_REWARD 
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

input group "Strategy Configuration"
input ENUM_LW_STRATEGY_MODE lwStrategyMode = LW_STRATEGY_BASELINE_BUY_OPEN;
input int requiredConsecutiveBearishBars   = 3;
input int requiredConsecutiveBullishBars   = 3;
input int uptrendLookbackBars              = 30;
input int pullbackLookbackBars             = 9;

input group "Volatility Breakout Parameters"
input double inpBuyRangeMultiplier   = 0.50;   
input double inpSellRangeMultiplier  = 0.50;   
input double inpStopRangeMultiplier  = 0.50;

input group "TDW filter"
input ENUM_TDW_MODE tradeDayMode = TDW_ALL_DAYS;
input bool tradeSunday           = false;
input bool tradeMonday           = true;
input bool tradeTuesday          = false;
input bool tradeWednesday        = false;
input bool tradeThursday         = false;
input bool tradeFriday           = false;
input bool tradeSaturday         = false;

input group "Trade and Risk Management"
input ENUM_STOP_LOSS_MODE stopLossMode      = SL_BY_RANGE_PERCENT;
input ENUM_TAKE_PROFIT_MODE takeProfitMode  = TP_BY_RISK_REWARD;
input double riskRewardRatio                = 3.0;
input int exitAfterCandles                  = 3;
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

//--- Holds all price levels derived from Larry Williams' volatility breakout calculations
struct MqlLwVolatilityLevels
{
   double yesterdayRange;      
   double buyEntryPrice;       
   double sellEntryPrice;   
   double bullishStopLoss;   
   double bearishStopLoss;    
   double bullishTakeProfit;
   double bearishTakeProfit;
   double bullishStopDistance;
   double bearishStopDistance;
};

MqlLwVolatilityLevels lwVolatilityLevels;

//--- To store minutes data
double closePriceMinutesData [];

//--- Tracks the number of completed bars elapsed since the current trade was opened
int barsSinceEntry;


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
   
   //--- Initialize bar counter for time-based trade exit tracking
   barsSinceEntry = 0;
   
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
   
   //--- Run this block only when a new bar is detected on the selected timeframe
   if(IsNewBar(_Symbol, timeframe, lastBarOpenTime)){
   
      //--- Increment the number of completed bars since the position was opened
      if(barsSinceEntry > 0){
         barsSinceEntry = barsSinceEntry + 1;
      }
      
      //--- Handle exit conditions for the currently active position based on the configured take-profit mode
      if(takeProfitMode == TP_FIRST_PROFITABLE_OPEN){
         ManageOpenPositionExits();
      }
   
      lwVolatilityLevels.yesterdayRange    = GetBarRange(_Symbol, timeframe, 1);
      
      if(lwStrategyMode == LW_STRATEGY_BASELINE_BUY_OPEN){
         lwVolatilityLevels.buyEntryPrice  = askPrice;
         lwVolatilityLevels.sellEntryPrice = bidPrice;
      }else{
         lwVolatilityLevels.buyEntryPrice  = CalculateBuyEntryPrice (askPrice, lwVolatilityLevels.yesterdayRange, inpBuyRangeMultiplier );
         lwVolatilityLevels.sellEntryPrice = CalculateSellEntryPrice(bidPrice, lwVolatilityLevels.yesterdayRange, inpSellRangeMultiplier);
      }      
      if(stopLossMode == SL_BY_RANGE_PERCENT){
         lwVolatilityLevels.bullishStopLoss = CalculateBullishStopLoss(lwVolatilityLevels.buyEntryPrice, lwVolatilityLevels.yesterdayRange,  inpStopRangeMultiplier);
         lwVolatilityLevels.bearishStopLoss = CalculateBearishStopLoss(lwVolatilityLevels.sellEntryPrice, lwVolatilityLevels.yesterdayRange, inpStopRangeMultiplier);
      }
      if(stopLossMode == SL_AT_PREVIOUS_BAR){
         lwVolatilityLevels.bullishStopLoss = iLow (_Symbol, timeframe, 1);
         lwVolatilityLevels.bearishStopLoss = iHigh(_Symbol, timeframe, 1);
      }     
      if(takeProfitMode == TP_BY_RISK_REWARD){
         lwVolatilityLevels.bullishTakeProfit = CalculateBullishTakeProfit(lwVolatilityLevels.buyEntryPrice, lwVolatilityLevels.bullishStopLoss,  riskRewardRatio);
         lwVolatilityLevels.bearishTakeProfit = CalculateBearishTakeProfit(lwVolatilityLevels.sellEntryPrice, lwVolatilityLevels.bearishStopLoss, riskRewardRatio);
      }
      
      lwVolatilityLevels.bullishStopDistance = lwVolatilityLevels.buyEntryPrice   - lwVolatilityLevels.bullishStopLoss;
      lwVolatilityLevels.bearishStopDistance = lwVolatilityLevels.bearishStopLoss - lwVolatilityLevels.sellEntryPrice;
      
      //---
      if(lwStrategyMode == LW_STRATEGY_BASELINE_BUY_OPEN){
         if(IsThereAnActiveBuyPosition(magicNumber) || IsThereAnActiveSellPosition(magicNumber)){
            ClosePositionsByMagic(magicNumber);
            Sleep(50);
         }
         
         if(tradeDayMode == TDW_SELECTED_DAYS){
            if(IsTradingDayAllowed(currentTime)){
               if(!IsThereAnActiveBuyPosition(magicNumber) && !IsThereAnActiveSellPosition(magicNumber)){
                  OpenBuy(lwVolatilityLevels.bullishStopLoss, lwVolatilityLevels.bullishTakeProfit, positionSize);
               }
            }
         }else{
            if(!IsThereAnActiveBuyPosition(magicNumber) && !IsThereAnActiveSellPosition(magicNumber)){
               OpenBuy(lwVolatilityLevels.bullishStopLoss, lwVolatilityLevels.bullishTakeProfit, positionSize);
            }
         }
      }
      
   }
   
   //--- Handle exit conditions for the currently active position based on the configured take-profit mode
   if(takeProfitMode == TP_AFTER_N_CANDLES){
      ManageOpenPositionExits();
   }
   
   //---  
   if(lwStrategyMode == LW_STRATEGY_CONSECUTIVE_BEARISH_BARS){
      if(!IsThereAnActiveBuyPosition(magicNumber) && !IsThereAnActiveSellPosition(magicNumber)){
         if(IsConsecutiveBarCloseState(_Symbol, timeframe, requiredConsecutiveBearishBars, BAR_CLOSE_DOWN)){
            if(IsCrossOver(lwVolatilityLevels.buyEntryPrice, closePriceMinutesData)){
               if(tradeDayMode == TDW_SELECTED_DAYS){
                  if(IsTradingDayAllowed(currentTime)){
                     OpenBuy(lwVolatilityLevels.bullishStopLoss, lwVolatilityLevels.bullishTakeProfit, positionSize);
                  }
               }else{
                  OpenBuy(lwVolatilityLevels.bullishStopLoss, lwVolatilityLevels.bullishTakeProfit, positionSize);
               }
            }
         }
      }
   }
   
   //---
   if(lwStrategyMode == LW_STRATEGY_UPTREND_WITH_PULLBACK){
      if(!IsThereAnActiveBuyPosition(magicNumber) && !IsThereAnActiveSellPosition(magicNumber)){
         if(IsUptrendWithPullback(_Symbol, timeframe, 1, uptrendLookbackBars, pullbackLookbackBars)){
            if(IsCrossOver(lwVolatilityLevels.buyEntryPrice, closePriceMinutesData)){
               if(tradeDayMode == TDW_SELECTED_DAYS){
                  if(IsTradingDayAllowed(currentTime)){
                     OpenBuy(lwVolatilityLevels.bullishStopLoss, lwVolatilityLevels.bullishTakeProfit, positionSize);
                  }
               }else{
                  OpenBuy(lwVolatilityLevels.bullishStopLoss, lwVolatilityLevels.bullishTakeProfit, positionSize);
               }
            }
         }
      }
   }
   
   //---
   if(lwStrategyMode == LW_STRATEGY_OUTSIDE_DAY_DOWN_CLOSE){
      if(!IsThereAnActiveBuyPosition(magicNumber) && !IsThereAnActiveSellPosition(magicNumber)){
         if(IsOutsideBarWithDownClose(_Symbol, timeframe, 1)){
            if(IsCrossOver(lwVolatilityLevels.buyEntryPrice, closePriceMinutesData)){
               if(tradeDayMode == TDW_SELECTED_DAYS){
                  if(IsTradingDayAllowed(currentTime)){
                     OpenBuy(lwVolatilityLevels.bullishStopLoss, lwVolatilityLevels.bullishTakeProfit, positionSize);
                  }
               }else{
                  OpenBuy(lwVolatilityLevels.bullishStopLoss, lwVolatilityLevels.bullishTakeProfit, positionSize);
               }
            }
         }
      }
   }
   
   //---
   if(lwStrategyMode == LW_STRATEGY_THIRD_BULLISH_DAY_FADE){
      if(!IsThereAnActiveBuyPosition(magicNumber) && !IsThereAnActiveSellPosition(magicNumber)){
         if(IsConsecutiveBarCloseState(_Symbol, timeframe, requiredConsecutiveBullishBars, BAR_CLOSE_UP)){
            if(IsCrossUnder(lwVolatilityLevels.sellEntryPrice, closePriceMinutesData)){
               if(tradeDayMode == TDW_SELECTED_DAYS){
                  if(IsTradingDayAllowed(currentTime)){
                     OpenSel(lwVolatilityLevels.bearishStopLoss, lwVolatilityLevels.bearishTakeProfit, positionSize);
                  }
               }else{
                  OpenSel(lwVolatilityLevels.bearishStopLoss, lwVolatilityLevels.bearishTakeProfit, positionSize);
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
//| Detects an uptrend with a small pullback based on Larry Williams'|
//| logic using historical reference bars                            |
//+------------------------------------------------------------------+
bool IsUptrendWithPullback(string symbol,
                           ENUM_TIMEFRAMES tf,
                           int index,
                           int trendLookback,
                           int pullbackLookback)
{
   //--- Today's open
   double todayOpen = iOpen(symbol, tf, index);

   //--- Reference closes
   double closeTrendBar    = iClose(symbol, tf, index + trendLookback);
   double closePullbackBar = iClose(symbol, tf, index + pullbackLookback);

   //--- Validate data
   if(todayOpen == 0.0 || closeTrendBar == 0.0 || closePullbackBar == 0.0)
      return false;

   //--- Condition 1: Uptrend confirmation
   bool isInUptrend = (todayOpen > closeTrendBar);

   if(!isInUptrend)
      return false;

   //--- Condition 2: Pullback confirmation
   bool isPullback = (todayOpen < closePullbackBar);

   if(!isPullback)
      return false;

   return true;
}


//+------------------------------------------------------------------+
//| Detects an outside bar with a bearish close relative to the prior bar |
//+------------------------------------------------------------------+
bool IsOutsideBarWithDownClose(string symbol, ENUM_TIMEFRAMES tf, int index){
   
   //--- Current bar data
   double open0  = iOpen (symbol, tf, index);
   double high0  = iHigh (symbol, tf, index);
   double low0   = iLow  (symbol, tf, index);
   double close0 = iClose(symbol, tf, index);

   //--- Previous bar data
   double high1 = iHigh(symbol, tf, index + 1);
   double low1  = iLow (symbol, tf, index + 1);

   //--- Condition 1: Outside bar range
   bool isOutsideBar =
      (high0 > high1) &&
      (low0  < low1);

   if(!isOutsideBar)
      return false;

   //--- Condition 2: Bearish close below previous low
   bool isDownClose = (close0 < low1);

   if(!isDownClose)
      return false;
      
   //--- Condition 3: Bearish bar
   bool isBearishBar = (open0 > close0);
   
   if(!isBearishBar)
      return false;

   return true;
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
//| Calculates the bearish breakout entry price using today's open and yesterday's range |
//+------------------------------------------------------------------+
double CalculateSellEntryPrice(double todayOpen, double yesterdayRange, double sellMultiplier){

   return todayOpen - (yesterdayRange * sellMultiplier);
}


//+------------------------------------------------------------------+
//| Calculates the stop-loss price for a bullish position based on entry price and yesterday's range |
//+------------------------------------------------------------------+
double CalculateBullishStopLoss(double entryPrice, double yesterdayRange, double stopMultiplier){

   return entryPrice - (yesterdayRange * stopMultiplier);
}

 
//+------------------------------------------------------------------+
//| Calculates the stop-loss price for a bearish position based on entry price and yesterday's range |
//+------------------------------------------------------------------+
double CalculateBearishStopLoss(double entryPrice, double yesterdayRange, double stopMultiplier){

   return entryPrice + (yesterdayRange * stopMultiplier);
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
bool OpenBuy(double stopLoss, double takeProfit, double lotSize){
   
   if(lotSizeMode == MODE_AUTO){
      lotSize = CalculatePositionSizeByRisk(lwVolatilityLevels.bullishStopDistance);
   }
   
   if(!Trade.Buy(lotSize, _Symbol, askPrice, lwVolatilityLevels.bullishStopLoss, lwVolatilityLevels.bullishTakeProfit)){
      Print("Error while executing a market buy order: ", GetLastError());
      Print(Trade.ResultRetcode());
      Print(Trade.ResultComment());
      return false;
   }
   
   if(takeProfitMode  == TP_AFTER_N_CANDLES){
      barsSinceEntry = 1;
   }
   
   return true;
}


//+------------------------------------------------------------------+
//| Function to open a market sell position                          |
//+------------------------------------------------------------------+
bool OpenSel(double stopLoss, double takeProfit, double lotSize){
   
   if(lotSizeMode == MODE_AUTO){
      lotSize = CalculatePositionSizeByRisk(lwVolatilityLevels.bearishStopDistance);
   }
   
   if(!Trade.Sell(lotSize, _Symbol, bidPrice, lwVolatilityLevels.bearishStopLoss, lwVolatilityLevels.bearishTakeProfit)){
      Print("Error while executing a market buy order: ", GetLastError());
      Print(Trade.ResultRetcode());
      Print(Trade.ResultComment());
      return false;
   }
   
   if(takeProfitMode  == TP_AFTER_N_CANDLES){
      barsSinceEntry = 1;
   }
   
   return true;
}


//+------------------------------------------------------------------+
//| Manages exit logic for the currently open position based on the selected take-profit mode |
//+------------------------------------------------------------------+
void ManageOpenPositionExits(){

   if(takeProfitMode == TP_FIRST_PROFITABLE_OPEN){
      for(int i = PositionsTotal() - 1; i >= 0; i--){
         ulong ticket = PositionGetTicket(i);
         if(ticket == 0){
            Print("Error while fetching position ticket ", GetLastError());
            continue;
         }else{
            if(PositionGetDouble(POSITION_PROFIT) > 0 ){
               ClosePositionsByMagic(magicNumber);
            }
         }
      }
   }
   
   if(takeProfitMode == TP_AFTER_N_CANDLES){
      if(barsSinceEntry > exitAfterCandles){
         ClosePositionsByMagic(magicNumber);
         barsSinceEntry = 0;
      }
   }
   
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
