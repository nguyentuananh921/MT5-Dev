
//+------------------------------------------------------------------+
//|                        lwVolatilityStructureTimeFilterExpert.mq5 |
//|Larry Williams Market Secrets                                     |
//|8. Combining Volatility, Structure and Time Filters                 |
//|                     https://www.mql5.com/en/articles/21003       |
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
enum ENUM_TRADE_DIRECTION  
{ 
   ONLY_LONG, 
   ONLY_SHORT, 
   TRADE_BOTH 
};

enum ENUM_VOLATILITY_ENTRY_MODE
{
   VOL_SIMPLE_PREVIOUS_RANGE,
   VOL_SWING_BASED
};

enum ENUM_STOP_LOSS_MODE
{
   SL_BY_RANGE_PERCENT,
   SL_AT_SWING_EXTREME
};


enum ENUM_TAKE_PROFIT_MODE
{
   TP_FIRST_PROFITABLE_OPEN,
   TP_AFTER_N_CANDLES,
   TP_BY_RISK_REWARD 
};

enum ENUM_TDW_MODE
{
   TDW_ALL_DAYS,     
   TDW_SELECTED_DAYS
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
input ENUM_VOLATILITY_ENTRY_MODE volatilityEntryMode = VOL_SIMPLE_PREVIOUS_RANGE;
input double inpBuyRangeMultiplier                   = 0.50;   
input double inpSellRangeMultiplier                  = 0.50;   
input double inpStopRangeMultiplier                  = 0.50;

input group "TDW filter"
input ENUM_TDW_MODE tradeDayMode = TDW_SELECTED_DAYS;
input bool tradeSunday           = false;
input bool tradeMonday           = true;
input bool tradeTuesday          = false;
input bool tradeWednesday        = false;
input bool tradeThursday         = false;
input bool tradeFriday           = false;
input bool tradeSaturday         = false;

input group "Time of Day filter"
input bool useTimeFilter         = false; 
input double startTime           = 9.30; 
input double endTime             = 16.00;

input group "Trade & Risk Management"
input ENUM_TRADE_DIRECTION direction       = ONLY_LONG;
input ENUM_STOP_LOSS_MODE stopLossMode     = SL_BY_RANGE_PERCENT;
input ENUM_TAKE_PROFIT_MODE takeProfitMode = TP_BY_RISK_REWARD;
input double riskRewardRatio               = 3.0;
input int exitAfterCandles                 = 3;
input ENUM_LOT_SIZE_INPUT_MODE lotSizeMode = MODE_AUTO;
input double riskPerTradePercent           = 1.0;
input double positionSize                  = 0.1;


//+------------------------------------------------------------------+
//| Global Variables                                                 |
//+------------------------------------------------------------------+
//--- Create a CTrade object to handle trading operations
CTrade Trade;

//--- Bid and Ask
double   askPrice;
double   bidPrice;
datetime currentTime;

//--- To help track new bar open
datetime lastBarOpenTime;


//--- Holds all price levels derived from Larry Williams' volatility breakout calculations
struct MqlLwVolatilityLevels
{
   double range;      
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
int barsSinceEntry = 0;


//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit(){

   //---  Assign a unique magic number to identify trades opened by this EA
   Trade.SetExpertMagicNumber(magicNumber);
   
   //--- Initialize global variables
   lastBarOpenTime       = 0;
   
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
   askPrice      = SymbolInfoDouble (_Symbol, SYMBOL_ASK);
   bidPrice      = SymbolInfoDouble (_Symbol, SYMBOL_BID);
   currentTime   = TimeCurrent();
   
   //--- Get some minutes data
   if(CopyClose(_Symbol, PERIOD_M1, 0, 5, closePriceMinutesData) == -1){
      Print("Error while copying minutes datas ", GetLastError());
      return;
   }
   
   //--- Run this block only when a new bar is detected on the selected timeframe
   if(IsNewBar(_Symbol, timeframe, lastBarOpenTime)){
      
      //--- Recalculate volatility entry levels on new bar based on the selected entry and stop models
      UpdateVolatilityEntryLevels();     
      
      //--- Increment the number of completed bars since the position was opened
      if(barsSinceEntry > 0){
         barsSinceEntry = barsSinceEntry + 1;
      }
      
      //--- Handle exit conditions for the currently active position based on the configured take-profit mode
      if(takeProfitMode == TP_FIRST_PROFITABLE_OPEN){
         ManageOpenPositionExits();
      }
      
   }
   
   //--- Check for valid entry signals and place trades if all rules are met
   EvaluateAndExecuteEntrySignals();
   
   //--- Handle exit conditions for the currently active position based on the configured take-profit mode
   if(takeProfitMode == TP_AFTER_N_CANDLES){
      ManageOpenPositionExits();
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
//| Detects a Larry Williams short-term high on the last three bars  |
//| Bar index 2 must be a swing high with lower highs on both sides  |
//| Bar 2 must NOT be an outside bar                                 |
//| Bar 1 must NOT be an inside bar                                  |
//+------------------------------------------------------------------+
bool IsLarryWilliamsShortTermHigh(string symbol, ENUM_TIMEFRAMES tf){

   //--- Price data for the three bars
   double high1 = iHigh(symbol, tf, 1);
   double low1  = iLow (symbol, tf, 1);

   double high2 = iHigh(symbol, tf, 2);
   double low2  = iLow (symbol, tf, 2);

   double high3 = iHigh(symbol, tf, 3);
   double low3  = iLow (symbol, tf, 3);

   //--- Condition 1: Bar 2 must be a swing high
   bool isSwingHigh =
      (high2 > high1) &&
      (high2 > high3);

   if(!isSwingHigh){
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

   return true;
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
//| Calculates the bullish breakout entry price using today's open and swing range |
//+------------------------------------------------------------------+
double CalculateBuyEntryPrice(double todayOpen, double range, double buyMultiplier){

   return todayOpen + (range * buyMultiplier);
}


//+------------------------------------------------------------------+
//| Calculates the bearish breakout entry price using today's open and swing range |
//+------------------------------------------------------------------+
double CalculateSellEntryPrice(double todayOpen, double range, double sellMultiplier){

   return todayOpen - (range * sellMultiplier);
}


//+------------------------------------------------------------------+
//| Calculates the stop-loss price for a bullish position based on entry price and yesterday's range |
//+------------------------------------------------------------------+
double CalculateBullishStopLoss(double entryPrice, double range, double stopMultiplier){

   return entryPrice - (range * stopMultiplier);
}

 
//+------------------------------------------------------------------+
//| Calculates the stop-loss price for a bearish position based on entry price and yesterday's range |
//+------------------------------------------------------------------+
double CalculateBearishStopLoss(double entryPrice, double range, double stopMultiplier){

   return entryPrice + (range * stopMultiplier);
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
//| Calculates and updates all volatility-based entry, stop, and take-profit levels based on the selected models |                             
//+------------------------------------------------------------------+
void UpdateVolatilityEntryLevels(){

   if(volatilityEntryMode == VOL_SWING_BASED){
      lwVolatilityLevels.range              = CalculateLwSwingVolatilityRange(_Symbol, timeframe);
      lwVolatilityLevels.buyEntryPrice      = CalculateBuyEntryPrice (askPrice, lwVolatilityLevels.range, inpBuyRangeMultiplier );
      lwVolatilityLevels.sellEntryPrice     = CalculateSellEntryPrice(bidPrice, lwVolatilityLevels.range, inpSellRangeMultiplier);
      if(stopLossMode == SL_BY_RANGE_PERCENT){
         lwVolatilityLevels.bullishStopLoss = CalculateBullishStopLoss(lwVolatilityLevels.buyEntryPrice, lwVolatilityLevels.range,  inpStopRangeMultiplier);
         lwVolatilityLevels.bearishStopLoss = CalculateBearishStopLoss(lwVolatilityLevels.sellEntryPrice, lwVolatilityLevels.range, inpStopRangeMultiplier);                   
      }
      if(stopLossMode == SL_AT_SWING_EXTREME){
         lwVolatilityLevels.bullishStopLoss = iLow(_Symbol,  timeframe, 2);
         lwVolatilityLevels.bearishStopLoss = iHigh(_Symbol, timeframe, 2);                  
      }
      lwVolatilityLevels.bullishTakeProfit   = CalculateBullishTakeProfit(lwVolatilityLevels.buyEntryPrice, lwVolatilityLevels.bullishStopLoss,  riskRewardRatio);
      lwVolatilityLevels.bearishTakeProfit   = CalculateBearishTakeProfit(lwVolatilityLevels.sellEntryPrice, lwVolatilityLevels.bearishStopLoss, riskRewardRatio);
      lwVolatilityLevels.bullishStopDistance = lwVolatilityLevels.buyEntryPrice - lwVolatilityLevels.bullishStopLoss;
      lwVolatilityLevels.bearishStopDistance = lwVolatilityLevels.bearishStopLoss - lwVolatilityLevels.sellEntryPrice;
   }
   
   if(volatilityEntryMode == VOL_SIMPLE_PREVIOUS_RANGE){
      lwVolatilityLevels.range              = GetBarRange(_Symbol, timeframe, 1);
      lwVolatilityLevels.buyEntryPrice      = CalculateBuyEntryPrice (askPrice, lwVolatilityLevels.range, inpBuyRangeMultiplier );
      lwVolatilityLevels.sellEntryPrice     = CalculateSellEntryPrice(bidPrice, lwVolatilityLevels.range, inpSellRangeMultiplier);
      if(stopLossMode == SL_BY_RANGE_PERCENT){
         lwVolatilityLevels.bullishStopLoss = CalculateBullishStopLoss(lwVolatilityLevels.buyEntryPrice, lwVolatilityLevels.range,  inpStopRangeMultiplier);
         lwVolatilityLevels.bearishStopLoss = CalculateBearishStopLoss(lwVolatilityLevels.sellEntryPrice, lwVolatilityLevels.range, inpStopRangeMultiplier);                   
      }
      if(stopLossMode == SL_AT_SWING_EXTREME){
         lwVolatilityLevels.bullishStopLoss = iLow(_Symbol,  timeframe, 2);
         lwVolatilityLevels.bearishStopLoss = iHigh(_Symbol, timeframe, 2);                  
      }
      lwVolatilityLevels.bullishTakeProfit   = CalculateBullishTakeProfit(lwVolatilityLevels.buyEntryPrice, lwVolatilityLevels.bullishStopLoss,  riskRewardRatio);
      lwVolatilityLevels.bearishTakeProfit   = CalculateBearishTakeProfit(lwVolatilityLevels.sellEntryPrice, lwVolatilityLevels.bearishStopLoss, riskRewardRatio);
      lwVolatilityLevels.bullishStopDistance = lwVolatilityLevels.buyEntryPrice - lwVolatilityLevels.bullishStopLoss;
      lwVolatilityLevels.bearishStopDistance = lwVolatilityLevels.bearishStopLoss - lwVolatilityLevels.sellEntryPrice;
   }

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
//| To parse time                                                    |                               
//+------------------------------------------------------------------+
bool ParseTime(double hhmm, int &hours, int &minutes){
    
    // Validate input range (0.00 to 23.59)
    if(hhmm < 0.0 || hhmm >= 24.00){
      return false;
    }
    
    hours = (int)hhmm;
    double fractional = hhmm - hours;
    
    // Handle floating-point precision by rounding
    minutes = (int)MathRound(fractional * 100);
    
    // Validate minutes (0-59)
    if(minutes < 0 || minutes > 59){
      return false;
    } 
        
    // Handle cases like 12.60 becoming 13:00
    if(minutes >= 60){
        hours += minutes / 60;
        minutes %= 60;
    }
    
    // Final validation (hours might have incremented)
    if(hours < 0 || hours > 23){
      return false;
    }
    
    return true;
}


//+------------------------------------------------------------------+
//| Returns true if current time is within allowed trading hours     |                               
//+------------------------------------------------------------------+
bool IsTimeWithinTradingHours(){

   datetime currentTm = currentTime;
   MqlDateTime currentTimeStruct;
   if(!TimeToStruct(currentTm, currentTimeStruct)){
      Print("Error while converting datetime to MqlDateTime struct: ", GetLastError());
      return false;
   }
   
   int startHour;
   int startMins;
   ParseTime(startTime, startHour, startMins);
   int endHour;
   int endMins;
   ParseTime(endTime, endHour, endMins);
   
   MqlDateTime startTimeStruct = currentTimeStruct;
   startTimeStruct.hour        = startHour;
   startTimeStruct.min         = startMins;
   startTimeStruct.sec         = 0;
   MqlDateTime endTimeStruct   = currentTimeStruct;
   endTimeStruct.hour          = endHour;
   endTimeStruct.min           = endMins;
   endTimeStruct.sec           = 0;
   
   datetime startTm          = StructToTime(startTimeStruct);
   datetime endTm            = StructToTime(endTimeStruct);    

   if(currentTm >= startTm && currentTm <= endTm){
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
   
   if(takeProfitMode == TP_BY_RISK_REWARD){
      if(!Trade.Buy(lotSize, _Symbol, askPrice, lwVolatilityLevels.bullishStopLoss, lwVolatilityLevels.bullishTakeProfit)){
         Print("Error while executing a market buy order: ", GetLastError());
         Print(Trade.ResultRetcode());
         Print(Trade.ResultComment());
         return false;
      }
      return true;
   }
   
   if(!Trade.Buy(lotSize, _Symbol, askPrice, lwVolatilityLevels.bullishStopLoss)){
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
bool OpenSel(double stopLoss, double takeProfit, double lotSize){
   
   if(lotSizeMode == MODE_AUTO){
      lotSize = CalculatePositionSizeByRisk(lwVolatilityLevels.bearishStopDistance);
   }
   
   if(takeProfitMode == TP_BY_RISK_REWARD){
      if(!Trade.Sell(lotSize, _Symbol, bidPrice, lwVolatilityLevels.bearishStopLoss, lwVolatilityLevels.bearishTakeProfit)){
         Print("Error while executing a market buy order: ", GetLastError());
         Print(Trade.ResultRetcode());
         Print(Trade.ResultComment());
         return false;
      }
      return true;
   }
   
   if(!Trade.Sell(lotSize, _Symbol, bidPrice, lwVolatilityLevels.bearishStopLoss)){
      Print("Error while executing a market buy order: ", GetLastError());
      Print(Trade.ResultRetcode());
      Print(Trade.ResultComment());
      return false;
   }
   
   return true;
}


//+------------------------------------------------------------------+
//| Evaluates swing-based entry signals, applies filters, and executes trades when conditions are satisfied |
//+------------------------------------------------------------------+
void EvaluateAndExecuteEntrySignals(){

   bool timeAllowed = true;
   
   if(useTimeFilter){
      timeAllowed = IsTimeWithinTradingHours();
   }

   //--- Handle bullish entry signals
   if(IsLarryWilliamsShortTermLow(_Symbol, timeframe)){
      if(IsCrossOver(lwVolatilityLevels.buyEntryPrice,   closePriceMinutesData)){
         if(timeAllowed){
            if(tradeDayMode == TDW_SELECTED_DAYS){
               if(IsTradingDayAllowed(currentTime)){
                  if(!IsThereAnActiveBuyPosition(magicNumber) && !IsThereAnActiveSellPosition(magicNumber)){
                     if(direction == TRADE_BOTH || direction == ONLY_LONG){
                        OpenBuy(lwVolatilityLevels.bullishStopLoss, lwVolatilityLevels.bullishTakeProfit, positionSize);
                        if(takeProfitMode  == TP_AFTER_N_CANDLES){
                           barsSinceEntry = 1;
                        }
                     }
                  }
               }
            }else{
               if(!IsThereAnActiveBuyPosition(magicNumber) && !IsThereAnActiveSellPosition(magicNumber)){
                  if(direction == TRADE_BOTH || direction == ONLY_LONG){
                     OpenBuy(lwVolatilityLevels.bullishStopLoss, lwVolatilityLevels.bullishTakeProfit, positionSize);
                     if(takeProfitMode  == TP_AFTER_N_CANDLES){
                        barsSinceEntry = 1;
                     }
                  }
               }
            }
         }
      }
   }
   
   //--- Handle bearish entry signals
   if(IsLarryWilliamsShortTermHigh(_Symbol, timeframe)){
      if(IsCrossUnder(lwVolatilityLevels.sellEntryPrice, closePriceMinutesData)){
         if(timeAllowed){
            if(tradeDayMode == TDW_SELECTED_DAYS){
               if(IsTradingDayAllowed(currentTime)){
                  if(!IsThereAnActiveBuyPosition(magicNumber) && !IsThereAnActiveSellPosition(magicNumber)){
                     if(direction == TRADE_BOTH || direction == ONLY_SHORT){
                        OpenSel(lwVolatilityLevels.bearishStopLoss, lwVolatilityLevels.bearishTakeProfit, positionSize);
                        if(takeProfitMode  == TP_AFTER_N_CANDLES){
                           barsSinceEntry = 1;
                        }
                     }
                  }
               }
            }else{
               if(!IsThereAnActiveBuyPosition(magicNumber) && !IsThereAnActiveSellPosition(magicNumber)){
                  if(direction == TRADE_BOTH || direction == ONLY_SHORT){
                     OpenSel(lwVolatilityLevels.bearishStopLoss, lwVolatilityLevels.bearishTakeProfit, positionSize);
                     if(takeProfitMode  == TP_AFTER_N_CANDLES){
                        barsSinceEntry = 1;
                     }
                  }
               }
            }
         }
      }
   }

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
