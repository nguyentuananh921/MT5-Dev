//+------------------------------------------------------------------+
//|                                  MACD-RSI LAYERING STRATEGY.mq5  |
//|      Copyright 2025, ALLAN MUNENE MUTIIRIA. #@Forex Algo-Trader. |
//|                           https://youtube.com/@ForexAlgo-Trader? |
//+------------------------------------------------------------------+
#property copyright "Copyright 2025, ALLAN MUNENE MUTIIRIA. #@Forex Algo-Trader"
#property link      "https://youtube.com/@ForexAlgo-Trader?"
#property description "MACD-RSI-based layering strategy with adjustable Risk:Reward and visual levels"
#property version   "1.0"

#include <Trade\Trade.mqh>//---- Includes the Trade.mqh library for trading operations
CTrade obj_Trade;//---- Declares a CTrade object for executing trade operations

int rsiHandle = INVALID_HANDLE;//---- Initializes RSI indicator handle as invalid
double rsiValues[];//---- Declares an array to store RSI values

int handleMACD = INVALID_HANDLE;//---- Initializes MACD indicator handle as invalid
double macdMAIN[];//---- Declares an array to store MACD main line values
double macdSIGNAL[];//---- Declares an array to store MACD signal line values

double takeProfitLevel = 0;//---- Initializes the take profit level variable
double stopLossLevel = 0;//---- Initializes the stop loss level variable
bool buySequenceActive = false;//---- Flag to track if a buy sequence is active
bool sellSequenceActive = false;//---- Flag to track if a sell sequence is active

// Inputs with clear names
input int stopLossPoints = 300;        // Initial Stop Loss (points)
input double tradeVolume = 0.01;       // Trade Volume (lots)
input int minStopLossPoints = 100;     // Minimum SL for cascading orders (points)
input int rsiLookbackPeriod = 14;      // RSI Lookback Period
input double rsiOverboughtLevel = 70.0; // RSI Overbought Threshold
input double rsiOversoldLevel = 30.0;   // RSI Oversold Threshold
input bool useStatisticalFilter = true; // Enable Statistical Filter
input int statAnalysisPeriod = 20;      // Statistical Analysis Period (bars)
input double statDeviationFactor = 1.0; // Statistical Deviation Factor
input double riskRewardRatio = 1.0;     // Risk:Reward Ratio

// Object names for visualization
string takeProfitLineName = "TakeProfitLine";//---- Name of the take profit line object for chart visualization
string takeProfitTextName = "TakeProfitText";//---- Name of the take profit text object for chart visualization

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit(){//---- Expert advisor initialization function
   rsiHandle = iRSI(_Symbol, _Period, rsiLookbackPeriod, PRICE_CLOSE);//---- Creates RSI indicator handle with specified parameters
   handleMACD = iMACD(_Symbol,_Period,12,26,9,PRICE_CLOSE);//---- Creates MACD indicator handle with standard 12,26,9 settings
   
   if(rsiHandle == INVALID_HANDLE){//---- Checks if RSI handle creation failed
      Print("UNABLE TO LOAD RSI, REVERTING NOW");//---- Prints error message if RSI failed to load
      return(INIT_FAILED);//---- Returns initialization failure code
   }
   if(handleMACD == INVALID_HANDLE){//---- Checks if MACD handle creation failed
      Print("UNABLE TO LOAD MACD, REVERTING NOW");//---- Prints error message if MACD failed to load
      return(INIT_FAILED);//---- Returns initialization failure code
   }
   
   ArraySetAsSeries(rsiValues, true);//---- Sets RSI values array as a time series (latest data at index 0)
   
   ArraySetAsSeries(macdMAIN,true);//---- Sets MACD main line array as a time series
   ArraySetAsSeries(macdSIGNAL,true);//---- Sets MACD signal line array as a time series

   return(INIT_SUCCEEDED);//---- Returns successful initialization code
}

//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason){//---- Expert advisor deinitialization function
   DeleteTradeLevelObjects();//---- Removes trade level visualization objects from chart
}

//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick(){//---- Function called on each price tick
   double askPrice = NormalizeDouble(SymbolInfoDouble(_Symbol, SYMBOL_ASK), _Digits);//---- Gets and normalizes current ask price
   double bidPrice = NormalizeDouble(SymbolInfoDouble(_Symbol, SYMBOL_BID), _Digits);//---- Gets and normalizes current bid price
   
   if(CopyBuffer(rsiHandle, 0, 1, 3, rsiValues) < 3){//---- Copies 3 RSI values into array, checks if successful
      Print("INSUFFICIENT RSI DATA FOR ANALYSIS, SKIPPING TICK");//---- Prints error if insufficient RSI data
      return;//---- Exits function if data copy fails
   }
   
   if (!CopyBuffer(handleMACD,MAIN_LINE,0,3,macdMAIN))return;//---- Copies 3 MACD main line values, exits if fails
   if (!CopyBuffer(handleMACD,SIGNAL_LINE,0,3,macdSIGNAL))return;//---- Copies 3 MACD signal line values, exits if fails
   
   
   // Calculate statistical measures if enabled
   double rsiAverage = useStatisticalFilter ? CalculateRSIAverage(statAnalysisPeriod) : 0;//---- Calculates RSI average if filter enabled
   double rsiStdDeviation = useStatisticalFilter ? CalculateRSIStandardDeviation(statAnalysisPeriod) : 0;//---- Calculates RSI std dev if filter enabled
   
   if(PositionsTotal() == 0){//---- Checks if there are no open positions
      buySequenceActive = false;//---- Resets buy sequence flag
      sellSequenceActive = false;//---- Resets sell sequence flag
      DeleteTradeLevelObjects();//---- Removes trade level objects from chart
   }
   
   if(PositionsTotal() == 0 && IsNewBar()){//---- Checks for no positions and new bar
      // Buy Signal
      bool buyCondition = rsiValues[1] <= rsiOversoldLevel && rsiValues[0] > rsiOversoldLevel;//---- Checks RSI crossing above oversold
      if(useStatisticalFilter){//---- Applies statistical filter if enabled
         buyCondition = buyCondition && (rsiValues[0] < (rsiAverage - statDeviationFactor * rsiStdDeviation));//---- Adds statistical condition
      }
      
      buyCondition = macdMAIN[0] < 0 && macdSIGNAL[0] < 0;//---- Confirms MACD below zero for buy signal
      
      if(buyCondition){//---- Executes if buy conditions are met
         Print("BUY SIGNAL - RSI: ", rsiValues[0],//---- Prints buy signal details
               useStatisticalFilter ? " Avg: " + DoubleToString(rsiAverage, 2) + " StdDev: " + DoubleToString(rsiStdDeviation, 2) : "");
         stopLossLevel = askPrice - stopLossPoints * _Point;//---- Calculates stop loss level for buy
         takeProfitLevel = askPrice + (stopLossPoints * riskRewardRatio) * _Point;//---- Calculates take profit level for buy
         obj_Trade.Buy(tradeVolume, _Symbol, askPrice, stopLossLevel, 0,"Signal Position");//---- Places buy order
         buySequenceActive = true;//---- Activates buy sequence flag
         DrawTradeLevelLine(takeProfitLevel, true);//---- Draws take profit line for buy
      }
      // Sell Signal
      bool sellCondition = rsiValues[1] >= rsiOverboughtLevel && rsiValues[0] < rsiOverboughtLevel;//---- Checks RSI crossing below overbought
      if(useStatisticalFilter){//---- Applies statistical filter if enabled
         sellCondition = sellCondition && (rsiValues[0] > (rsiAverage + statDeviationFactor * rsiStdDeviation));//---- Adds statistical condition
      }
      
      sellCondition = macdMAIN[0] > 0 && macdSIGNAL[0] > 0;//---- Confirms MACD above zero for sell signal
      
      if(sellCondition){//---- Executes if sell conditions are met
         Print("SELL SIGNAL - RSI: ", rsiValues[0],//---- Prints sell signal details
               useStatisticalFilter ? " Avg: " + DoubleToString(rsiAverage, 2) + " StdDev: " + DoubleToString(rsiStdDeviation, 2) : "");
         stopLossLevel = bidPrice + stopLossPoints * _Point;//---- Calculates stop loss level for sell
         takeProfitLevel = bidPrice - (stopLossPoints * riskRewardRatio) * _Point;//---- Calculates take profit level for sell
         obj_Trade.Sell(tradeVolume, _Symbol, bidPrice, stopLossLevel, 0,"Signal Position");//---- Places sell order
         sellSequenceActive = true;//---- Activates sell sequence flag
         DrawTradeLevelLine(takeProfitLevel, false);//---- Draws take profit line for sell
      }
   }
   else {//---- Handles cascading logic when positions exist
      // Cascading Buy Logic
      if(buySequenceActive && askPrice >= takeProfitLevel){//---- Checks if buy sequence active and price hit take profit
         double previousTakeProfit = takeProfitLevel;//---- Stores previous take profit level
         takeProfitLevel = previousTakeProfit + (stopLossPoints * riskRewardRatio) * _Point;//---- Sets new take profit level
         stopLossLevel = askPrice - minStopLossPoints * _Point;//---- Sets new stop loss level
         obj_Trade.Buy(tradeVolume, _Symbol, askPrice, stopLossLevel, 0,"Cascade Position");//---- Places new buy order
         ModifyTrades(POSITION_TYPE_BUY, stopLossLevel);//---- Modifies existing buy trades with new stop loss
         Print("CASCADING BUY - New TP: ", takeProfitLevel, " New SL: ", stopLossLevel);//---- Prints cascading buy details
         DrawTradeLevelLine(takeProfitLevel, true);//---- Updates take profit line for buy
      }
      // Cascading Sell Logic
      else if(sellSequenceActive && bidPrice <= takeProfitLevel){//---- Checks if sell sequence active and price hit take profit
         double previousTakeProfit = takeProfitLevel;//---- Stores previous take profit level
         takeProfitLevel = previousTakeProfit - (stopLossPoints * riskRewardRatio) * _Point;//---- Sets new take profit level
         stopLossLevel = bidPrice + minStopLossPoints * _Point;//---- Sets new stop loss level
         obj_Trade.Sell(tradeVolume, _Symbol, bidPrice, stopLossLevel, 0,"Cascade Position");//---- Places new sell order
         ModifyTrades(POSITION_TYPE_SELL, stopLossLevel);//---- Modifies existing sell trades with new stop loss
         Print("CASCADING SELL - New TP: ", takeProfitLevel, " New SL: ", stopLossLevel);//---- Prints cascading sell details
         DrawTradeLevelLine(takeProfitLevel, false);//---- Updates take profit line for sell
      }
   }
}

//+------------------------------------------------------------------+
//| Is New Bar                                                       |
//+------------------------------------------------------------------+
bool IsNewBar(){//---- Function to detect a new bar
   static int previousBarCount = 0;//---- Stores the previous bar count
   int currentBarCount = iBars(_Symbol, _Period);//---- Gets current number of bars
   if(previousBarCount == currentBarCount) return false;//---- Returns false if no new bar
   previousBarCount = currentBarCount;//---- Updates previous bar count
   return true;//---- Returns true if new bar detected
}

//+------------------------------------------------------------------+
//| Modify Trades                                                    |
//+------------------------------------------------------------------+
void ModifyTrades(ENUM_POSITION_TYPE positionType, double newStopLoss){//---- Function to modify open trades
   for(int i = 0; i < PositionsTotal(); i++){//---- Loops through all open positions
      ulong ticket = PositionGetTicket(i);//---- Gets ticket number of position
      if(ticket > 0 && PositionSelectByTicket(ticket)){//---- Checks if ticket is valid and selectable
         ENUM_POSITION_TYPE type = (ENUM_POSITION_TYPE)PositionGetInteger(POSITION_TYPE);//---- Gets position type
         if(type == positionType){//---- Checks if position matches specified type
            obj_Trade.PositionModify(ticket, newStopLoss, PositionGetDouble(POSITION_TP));//---- Modifies position with new stop loss
         }
      }
   }
}

//+------------------------------------------------------------------+
//| Draw TrendLine                                                   |
//+------------------------------------------------------------------+
void DrawTradeLevelLine(double price, bool isBuy){//---- Function to draw take profit line on chart
   // Delete existing objects first
   DeleteTradeLevelObjects();//---- Removes existing trade level objects
   
   // Create horizontal line
   ObjectCreate(0, takeProfitLineName, OBJ_HLINE, 0, 0, price);//---- Creates a horizontal line at specified price
   ObjectSetInteger(0, takeProfitLineName, OBJPROP_COLOR, clrBlue);//---- Sets line color to blue
   ObjectSetInteger(0, takeProfitLineName, OBJPROP_WIDTH, 2);//---- Sets line width to 2
   ObjectSetInteger(0, takeProfitLineName, OBJPROP_STYLE, STYLE_SOLID);//---- Sets line style to solid
   
   // Create text, above for buy, below for sell with increased spacing
   datetime currentTime = TimeCurrent();//---- Gets current time
   double textOffset = 30.0 * _Point;//---- Sets text offset distance from line
   double textPrice = isBuy ? price + textOffset : price - textOffset;//---- Calculates text position based on buy/sell
   
   ObjectCreate(0, takeProfitTextName, OBJ_TEXT, 0, currentTime + PeriodSeconds(_Period) * 5, textPrice);//---- Creates text object
   ObjectSetString(0, takeProfitTextName, OBJPROP_TEXT, DoubleToString(price, _Digits));//---- Sets text to price value
   ObjectSetInteger(0, takeProfitTextName, OBJPROP_COLOR, clrBlue);//---- Sets text color to blue
   ObjectSetInteger(0, takeProfitTextName, OBJPROP_FONTSIZE, 10);//---- Sets text font size to 10
   ObjectSetInteger(0, takeProfitTextName, OBJPROP_ANCHOR, isBuy ? ANCHOR_BOTTOM : ANCHOR_TOP);//---- Sets text anchor based on buy/sell
}

//+------------------------------------------------------------------+
//| Delete Level Objects                                             |
//+------------------------------------------------------------------+
void DeleteTradeLevelObjects(){//---- Function to delete trade level objects
   ObjectDelete(0, takeProfitLineName);//---- Deletes take profit line object
   ObjectDelete(0, takeProfitTextName);//---- Deletes take profit text object
}

//+------------------------------------------------------------------+
//| Calculate RSI Average                                            |
//+------------------------------------------------------------------+
double CalculateRSIAverage(int bars){//---- Function to calculate RSI average
   double sum = 0;//---- Initializes sum variable
   double buffer[];//---- Declares buffer array for RSI values
   ArraySetAsSeries(buffer, true);//---- Sets buffer as time series
   if(CopyBuffer(rsiHandle, 0, 0, bars, buffer) < bars) return 0;//---- Copies RSI values, returns 0 if fails
   
   for(int i = 0; i < bars; i++){//---- Loops through specified number of bars
      sum += buffer[i];//---- Adds each RSI value to sum
   }
   return sum / bars;//---- Returns average RSI value
}

//+------------------------------------------------------------------+
//| Calculate RSI STDDev                                             |
//+------------------------------------------------------------------+
double CalculateRSIStandardDeviation(int bars){//---- Function to calculate RSI standard deviation
   double average = CalculateRSIAverage(bars);//---- Calculates RSI average
   double sumSquaredDiff = 0;//---- Initializes sum of squared differences
   double buffer[];//---- Declares buffer array for RSI values
   ArraySetAsSeries(buffer, true);//---- Sets buffer as time series
   if(CopyBuffer(rsiHandle, 0, 0, bars, buffer) < bars) return 0;//---- Copies RSI values, returns 0 if fails
   
   for(int i = 0; i < bars; i++){//---- Loops through specified number of bars
      double diff = buffer[i] - average;//---- Calculates difference from average
      sumSquaredDiff += diff * diff;//---- Adds squared difference to sum
   }
   return MathSqrt(sumSquaredDiff / bars);//---- Returns standard deviation
}