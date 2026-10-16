
//+------------------------------------------------------------------+
//|                                          lwOopsPatternExpert.mq5 |
//|                                  Copyright 2026, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//|Larry Williams Market Secrets                                     |
//|16. Detecting and Trading the Oops Gap Reversal Pattern           |
//|                     https://www.mql5.com/en/articles/21741       |
//+------------------------------------------------------------------+

#property copyright "Copyright 2026, MetaQuotes Ltd. Developer: Chacha Ian"
#property link      "https://www.mql5.com/en/users/chachaian"
#property version   "1.00"
#property description "Detects and trades Larry Williams' Oops gap reversal pattern."
#property description "The EA tracks qualifying gaps, confirms closed-bar reversals,"
#property description "and calculates the stop loss, take profit, and position size."

//+------------------------------------------------------------------+
//| Standard Libraries                                               |
//+------------------------------------------------------------------+
#include <Trade\Trade.mqh>

//+------------------------------------------------------------------+
//| Custom Enumerations                                              |
//+------------------------------------------------------------------+
enum ENUM_OOPS_TRADE_DIRECTION
  {
   OOPS_TRADE_LONG_ONLY,
   OOPS_TRADE_SHORT_ONLY,
   OOPS_TRADE_BOTH
  };

enum ENUM_LOT_SIZE_INPUT_MODE
  {
   MODE_MANUAL,
   MODE_AUTO
  };

//+------------------------------------------------------------------+
//| User Input Variables                                             |
//+------------------------------------------------------------------+
input group "Information"
input ulong magicNumber         = 254700680002;
input ENUM_TIMEFRAMES timeframe = PERIOD_CURRENT;

input group "Oops Pattern Configurations"
input double minimumGapSizePoints = 500;
input int maxGapValidityBars      = 3;

input group "Trade and Risk Management"
input ENUM_OOPS_TRADE_DIRECTION tradeDirection = OOPS_TRADE_BOTH;
input double riskRewardRatio                   = 2.5;
input ENUM_LOT_SIZE_INPUT_MODE lotSizeMode     = MODE_AUTO;
input double riskPerTradePercent               = 1.0;
input double positionSize                      = 0.1;

//+------------------------------------------------------------------+
//| Oops Pattern State                                               |
//+------------------------------------------------------------------+
//| Stores the detected gap, its lifecycle, and prepared trade data. |
//+------------------------------------------------------------------+
struct OopsPatternState
  {
   bool             gapDetected;
   bool             isGapUp;
   bool             isGapDown;
   datetime         gapBarTime;
   double           gapOpenPrice;
   double           gapBarHigh;
   double           gapBarLow;
   double           previousHigh;
   double           previousLow;
   int              barsSinceGap;
   int              maxBarsToFill;
   bool             gapFilled;
   bool             gapInvalidated;
   double           bullishTakeProfit;
   double           bearishTakeProfit;
   double           lotSize;
   ENUM_ORDER_TYPE  orderType;
   double           positionEntryPrice;
  };
  
//+------------------------------------------------------------------+
//| Shared Program State                                             |
//+------------------------------------------------------------------+
OopsPatternState oopsState;       // Active Oops setup tracked across bars
CTrade           Trade;           // Submits orders and exposes execution results
double           askPrice;        // Latest verified price used for buy execution
double           bidPrice;        // Latest verified price used for sell execution
datetime         currentTime;     // Latest terminal time received by the EA
datetime         lastBarOpenTime; // Opening time of the last processed bar

//+------------------------------------------------------------------+
//| Reads a double-valued symbol property safely                     |
//+------------------------------------------------------------------+
bool GetSymbolDoubleValue(string symbol,
                          ENUM_SYMBOL_INFO_DOUBLE property,
                          double &value,
                          string context)
  {
//--- Clear any earlier runtime error and initialize the output
   ResetLastError();
   value = 0.0;

//--- Request the selected symbol property
   if(!SymbolInfoDouble(symbol, property, value))
     {
      int errorCode = GetLastError();

      PrintFormat("%s: Failed to read symbol property %s for %s. Error %d.",
                  context,
                  EnumToString(property),
                  symbol,
                  errorCode);
      return false;
     }

   return true;
  }

//+------------------------------------------------------------------+
//| Reads the opening time of a selected bar safely                  |
//+------------------------------------------------------------------+
bool GetBarTime(string symbol,
                ENUM_TIMEFRAMES tf,
                int shift,
                datetime &value,
                string context)
  {
//--- Request the opening time of the selected bar
   ResetLastError();
   value = iTime(symbol, tf, shift);

//--- A zero value indicates that the bar data is unavailable
   if(value == 0)
     {
      int errorCode = GetLastError();

      PrintFormat("%s: Failed to read bar time for %s, timeframe %s, "
                  "shift %d. Error %d.",
                  context,
                  symbol,
                  EnumToString(tf),
                  shift,
                  errorCode);
      return false;
     }

   return true;
  }

//+------------------------------------------------------------------+
//| Reads the opening price of a selected bar safely                 |
//+------------------------------------------------------------------+
bool GetBarOpen(string symbol,
                ENUM_TIMEFRAMES tf,
                int shift,
                double &value,
                string context)
  {
//--- Request the opening price of the selected bar
   ResetLastError();
   value = iOpen(symbol, tf, shift);

//--- Reject unavailable or invalid price data
   if(value == 0.0)
     {
      int errorCode = GetLastError();

      PrintFormat("%s: Failed to read bar open for %s, timeframe %s, "
                  "shift %d. Error %d.",
                  context,
                  symbol,
                  EnumToString(tf),
                  shift,
                  errorCode);
      return false;
     }

   return true;
  }

//+------------------------------------------------------------------+
//| Reads the highest price of a selected bar safely                 |
//+------------------------------------------------------------------+
bool GetBarHigh(string symbol,
                ENUM_TIMEFRAMES tf,
                int shift,
                double &value,
                string context)
  {
//--- Request the highest price of the selected bar
   ResetLastError();
   value = iHigh(symbol, tf, shift);

//--- Reject unavailable or invalid price data
   if(value == 0.0)
     {
      int errorCode = GetLastError();

      PrintFormat("%s: Failed to read bar high for %s, timeframe %s, "
                  "shift %d. Error %d.",
                  context,
                  symbol,
                  EnumToString(tf),
                  shift,
                  errorCode);
      return false;
     }

   return true;
  }

//+------------------------------------------------------------------+
//| Reads the lowest price of a selected bar safely                  |
//+------------------------------------------------------------------+
bool GetBarLow(string symbol,
               ENUM_TIMEFRAMES tf,
               int shift,
               double &value,
               string context)
  {
//--- Request the lowest price of the selected bar
   ResetLastError();
   value = iLow(symbol, tf, shift);

//--- Reject unavailable or invalid price data
   if(value == 0.0)
     {
      int errorCode = GetLastError();

      PrintFormat("%s: Failed to read bar low for %s, timeframe %s, "
                  "shift %d. Error %d.",
                  context,
                  symbol,
                  EnumToString(tf),
                  shift,
                  errorCode);
      return false;
     }

   return true;
  }

//+------------------------------------------------------------------+
//| Reads the closing price of a selected bar safely                 |
//+------------------------------------------------------------------+
bool GetBarClose(string symbol,
                 ENUM_TIMEFRAMES tf,
                 int shift,
                 double &value,
                 string context)
  {
//--- Request the closing price of the selected bar
   ResetLastError();
   value = iClose(symbol, tf, shift);

//--- Reject unavailable or invalid price data
   if(value == 0.0)
     {
      int errorCode = GetLastError();

      PrintFormat("%s: Failed to read bar close for %s, timeframe %s, "
                  "shift %d. Error %d.",
                  context,
                  symbol,
                  EnumToString(tf),
                  shift,
                  errorCode);
      return false;
     }

   return true;
  }
  
//+------------------------------------------------------------------+
//| Resets the stored Oops setup to a neutral state                  |
//+------------------------------------------------------------------+
void ResetOopsPatternState()
  {
//--- Clear the identity of the previous setup
   oopsState.gapDetected    = false;
   oopsState.isGapUp        = false;
   oopsState.isGapDown      = false;
   oopsState.gapBarTime     = 0;
   oopsState.gapOpenPrice   = 0.0;

//--- Clear the stored reference prices
   oopsState.gapBarHigh     = 0.0;
   oopsState.gapBarLow      = 0.0;
   oopsState.previousHigh   = 0.0;
   oopsState.previousLow    = 0.0;

//--- Restore the setup lifecycle defaults
   oopsState.barsSinceGap   = 0;
   oopsState.maxBarsToFill  = maxGapValidityBars;
   oopsState.gapFilled      = false;
   oopsState.gapInvalidated = false;

//--- Clear prepared trade values and restore input-based defaults
   oopsState.bullishTakeProfit  = 0.0;
   oopsState.bearishTakeProfit  = 0.0;
   oopsState.lotSize            = positionSize;
   oopsState.orderType          = ORDER_TYPE_BUY;
   oopsState.positionEntryPrice = 0.0;

//--- Initialize the stored entry with a verified market price
   if(!GetSymbolDoubleValue(_Symbol,
                            SYMBOL_ASK,
                            oopsState.positionEntryPrice,
                            "ResetOopsPatternState"))
     {
      //--- Keep a neutral value when the symbol price is unavailable
      oopsState.positionEntryPrice = 0.0;
     }
  }
  
//+------------------------------------------------------------------+
//| Configures the chart for clear visual testing                    |
//+------------------------------------------------------------------+
bool ConfigureChartAppearance()
  {
//--- Apply a white background
   ResetLastError();

   if(!ChartSetInteger(0, CHART_COLOR_BACKGROUND, clrWhite))
     {
      Print("ConfigureChartAppearance: Failed to set chart background. Error ",
            GetLastError(), ".");
      return false;
     }

//--- Remove the grid to reduce visual clutter
   ResetLastError();

   if(!ChartSetInteger(0, CHART_SHOW_GRID, false))
     {
      Print("ConfigureChartAppearance: Failed to hide the chart grid. Error ",
            GetLastError(), ".");
      return false;
     }

//--- Display prices as candlesticks
   ResetLastError();

   if(!ChartSetInteger(0, CHART_MODE, CHART_CANDLES))
     {
      Print("ConfigureChartAppearance: Failed to set candle chart mode. Error ",
            GetLastError(), ".");
      return false;
     }

//--- Use black for chart labels and price-scale text
   ResetLastError();

   if(!ChartSetInteger(0, CHART_COLOR_FOREGROUND, clrBlack))
     {
      Print("ConfigureChartAppearance: Failed to set chart foreground. Error ",
            GetLastError(), ".");
      return false;
     }

//--- Keep both candle bodies white
   ResetLastError();

   if(!ChartSetInteger(0, CHART_COLOR_CANDLE_BULL, clrWhite))
     {
      Print("ConfigureChartAppearance: Failed to set the bullish candle color. Error ",
            GetLastError(), ".");
      return false;
     }

   ResetLastError();

   if(!ChartSetInteger(0, CHART_COLOR_CANDLE_BEAR, clrWhite))
     {
      Print("ConfigureChartAppearance: Failed to set the bearish candle color. Error ",
            GetLastError(), ".");
      return false;
     }

//--- Distinguish bullish and bearish candle outlines
   ResetLastError();

   if(!ChartSetInteger(0, CHART_COLOR_CHART_UP, clrSeaGreen))
     {
      Print("ConfigureChartAppearance: Failed to set the chart-up color. Error ",
            GetLastError(), ".");
      return false;
     }

   ResetLastError();

   if(!ChartSetInteger(0, CHART_COLOR_CHART_DOWN, clrBlack))
     {
      Print("ConfigureChartAppearance: Failed to set the chart-down color. Error ",
            GetLastError(), ".");
      return false;
     }

//--- Apply the queued chart-property changes
   ResetLastError();
   ChartRedraw(0);

   int redrawError = GetLastError();

   if(redrawError != 0)
     {
      Print("ConfigureChartAppearance: ChartRedraw reported error ",
            redrawError, ".");
      return false;
     }

   return true;
  }
  
//+------------------------------------------------------------------+
//| Returns true once when a new bar opens on the selected timeframe |
//+------------------------------------------------------------------+
bool IsNewBar(string symbol,
              ENUM_TIMEFRAMES tf,
              datetime &lastTm)
  {
   datetime currentTm = 0;

//--- Stop when the opening time of bar zero is unavailable
   if(!GetBarTime(symbol,
                  tf,
                  0,
                  currentTm,
                  "IsNewBar"))
     {
      return false;
     }

//--- Matching timestamps indicate that this bar was already processed
   if(currentTm == lastTm)
      return false;

//--- Store the verified timestamp before allowing strategy processing
   lastTm = currentTm;

   return true;
  }
  
//+------------------------------------------------------------------+
//| Returns true when the current bar opens far enough below the     |
//| previous bar's low to qualify as a gap-down setup                |
//+------------------------------------------------------------------+
bool IsGapDown()
  {
   double currentOpen = 0.0;
   double previousLow = 0.0;

//--- A gap cannot be evaluated without both reference prices
   if(!GetBarOpen(_Symbol,
                  timeframe,
                  0,
                  currentOpen,
                  "IsGapDown"))
     {
      return false;
     }

   if(!GetBarLow(_Symbol,
                 timeframe,
                 1,
                 previousLow,
                 "IsGapDown"))
     {
      return false;
     }

//--- Measure the distance from the current open to the previous low
   double gapSize = previousLow - currentOpen;

//--- Convert the configured point threshold into a price distance
   return(gapSize >= minimumGapSizePoints * _Point);
  }

//+------------------------------------------------------------------+
//| Returns true when the current bar opens far enough above the     |
//| previous bar's high to qualify as a gap-up setup                 |
//+------------------------------------------------------------------+
bool IsGapUp()
  {
   double currentOpen  = 0.0;
   double previousHigh = 0.0;

//--- A gap cannot be evaluated without both reference prices
   if(!GetBarOpen(_Symbol,
                  timeframe,
                  0,
                  currentOpen,
                  "IsGapUp"))
     {
      return false;
     }

   if(!GetBarHigh(_Symbol,
                  timeframe,
                  1,
                  previousHigh,
                  "IsGapUp"))
     {
      return false;
     }

//--- Measure the distance from the previous high to the current open
   double gapSize = currentOpen - previousHigh;

//--- Convert the configured point threshold into a price distance
   return(gapSize >= minimumGapSizePoints * _Point);
  }
  
//+------------------------------------------------------------------+
//| Detects a qualifying gap and stores one complete Oops setup      |
//+------------------------------------------------------------------+
void DetectAndInitializeOopsGap()
  {
//--- Preserve the current setup until it confirms or expires
   if(oopsState.gapDetected)
      return;

//--- A gap up prepares a possible bearish reversal
   if(IsGapUp())
     {
      datetime gapBarTime   = 0;
      double   gapOpenPrice = 0.0;
      double   previousHigh = 0.0;
      double   previousLow  = 0.0;

//--- Collect every required value before changing shared state
      if(!GetBarTime(_Symbol,
                     timeframe,
                     0,
                     gapBarTime,
                     "DetectAndInitializeOopsGap"))
        {
         return;
        }

      if(!GetBarOpen(_Symbol,
                     timeframe,
                     0,
                     gapOpenPrice,
                     "DetectAndInitializeOopsGap"))
        {
         return;
        }

      if(!GetBarHigh(_Symbol,
                     timeframe,
                     1,
                     previousHigh,
                     "DetectAndInitializeOopsGap"))
        {
         return;
        }

      if(!GetBarLow(_Symbol,
                    timeframe,
                    1,
                    previousLow,
                    "DetectAndInitializeOopsGap"))
        {
         return;
        }

//--- Commit the bearish setup only after every data read succeeds
      oopsState.gapDetected    = true;
      oopsState.isGapUp        = true;
      oopsState.isGapDown      = false;
      oopsState.gapBarTime     = gapBarTime;
      oopsState.gapOpenPrice   = gapOpenPrice;
      oopsState.previousHigh   = previousHigh;
      oopsState.previousLow    = previousLow;
      oopsState.barsSinceGap   = 0;
      oopsState.maxBarsToFill  = maxGapValidityBars;
      oopsState.gapFilled      = false;
      oopsState.gapInvalidated = false;
      oopsState.orderType      = ORDER_TYPE_SELL;

      return;
     }

//--- A gap down prepares a possible bullish reversal
   if(IsGapDown())
     {
      datetime gapBarTime   = 0;
      double   gapOpenPrice = 0.0;
      double   previousHigh = 0.0;
      double   previousLow  = 0.0;

//--- Collect every required value before changing shared state
      if(!GetBarTime(_Symbol,
                     timeframe,
                     0,
                     gapBarTime,
                     "DetectAndInitializeOopsGap"))
        {
         return;
        }

      if(!GetBarOpen(_Symbol,
                     timeframe,
                     0,
                     gapOpenPrice,
                     "DetectAndInitializeOopsGap"))
        {
         return;
        }

      if(!GetBarHigh(_Symbol,
                     timeframe,
                     1,
                     previousHigh,
                     "DetectAndInitializeOopsGap"))
        {
         return;
        }

      if(!GetBarLow(_Symbol,
                    timeframe,
                    1,
                    previousLow,
                    "DetectAndInitializeOopsGap"))
        {
         return;
        }

//--- Commit the bullish setup only after every data read succeeds
      oopsState.gapDetected    = true;
      oopsState.isGapUp        = false;
      oopsState.isGapDown      = true;
      oopsState.gapBarTime     = gapBarTime;
      oopsState.gapOpenPrice   = gapOpenPrice;
      oopsState.previousHigh   = previousHigh;
      oopsState.previousLow    = previousLow;
      oopsState.barsSinceGap   = 0;
      oopsState.maxBarsToFill  = maxGapValidityBars;
      oopsState.gapFilled      = false;
      oopsState.gapInvalidated = false;
      oopsState.orderType      = ORDER_TYPE_BUY;
     }
  }
  
//+------------------------------------------------------------------+
//| Updates the age of the active Oops setup and removes it after    |
//| the configured confirmation window expires                       |
//+------------------------------------------------------------------+
void UpdateOopsGapState()
  {
//--- There is no lifecycle to update without an active setup
   if(!oopsState.gapDetected)
      return;

   datetime currentBarTime = 0;

//--- Preserve the current state when bar timing cannot be verified
   if(!GetBarTime(_Symbol,
                  timeframe,
                  0,
                  currentBarTime,
                  "UpdateOopsGapState"))
     {
      return;
     }

//--- The gap bar starts the setup but is not an elapsed fill bar
   if(currentBarTime == oopsState.gapBarTime)
      return;

//--- Count the newly opened bar once within the new-bar workflow
   oopsState.barsSinceGap++;

//--- Remove the setup after its allowed validity window is exceeded
   if(oopsState.barsSinceGap > oopsState.maxBarsToFill)
     {
      oopsState.gapInvalidated = true;
      ResetOopsPatternState();
     }
  }
  
//+------------------------------------------------------------------+
//| Returns true when an active gap-down setup confirms a bullish    |
//| reversal through the close of a later completed bar              |
//+------------------------------------------------------------------+
bool IsBullishSignal()
  {
//--- Accept only an active, unprocessed gap-down setup
   if(!oopsState.gapDetected ||
      !oopsState.isGapDown ||
      oopsState.gapFilled ||
      oopsState.gapInvalidated)
     {
      return false;
     }

//--- Require at least one completed bar after the original gap bar
   if(oopsState.barsSinceGap < 1)
      return false;

   double closePrice = 0.0;

//--- Bar one is the most recently completed candle
   if(!GetBarClose(_Symbol,
                   timeframe,
                   1,
                   closePrice,
                   "IsBullishSignal"))
     {
      return false;
     }

//--- Confirm only after price closes back at or above the previous low
   if(closePrice < oopsState.previousLow)
      return false;

//--- Mark the setup as filled before returning the signal
   oopsState.gapFilled = true;

   return true;
  }

//+------------------------------------------------------------------+
//| Returns true when an active gap-up setup confirms a bearish      |
//| reversal through the close of a later completed bar              |
//+------------------------------------------------------------------+
bool IsBearishSignal()
  {
//--- Accept only an active, unprocessed gap-up setup
   if(!oopsState.gapDetected ||
      !oopsState.isGapUp ||
      oopsState.gapFilled ||
      oopsState.gapInvalidated)
     {
      return false;
     }

//--- Require at least one completed bar after the original gap bar
   if(oopsState.barsSinceGap < 1)
      return false;

   double closePrice = 0.0;

//--- Bar one is the most recently completed candle
   if(!GetBarClose(_Symbol,
                   timeframe,
                   1,
                   closePrice,
                   "IsBearishSignal"))
     {
      return false;
     }

//--- Confirm only after price closes back at or below the previous high
   if(closePrice > oopsState.previousHigh)
      return false;

//--- Mark the setup as filled before returning the signal
   oopsState.gapFilled = true;

   return true;
  }
  
//+------------------------------------------------------------------+
//| Stores the gap-bar low as the stop reference for a buy setup     |
//+------------------------------------------------------------------+
void UpdateBullishGapBarStopLevel()
  {
//--- Locate the original gap bar using its stored opening time
   ResetLastError();

   int gapIndex = iBarShift(_Symbol,
                            timeframe,
                            oopsState.gapBarTime);

   if(gapIndex == -1)
     {
      Print("UpdateBullishGapBarStopLevel: Failed to locate the gap bar. Error ",
            GetLastError(), ".");
      return;
     }

   double gapBarLow = 0.0;

//--- Read the low of the recovered gap bar
   if(!GetBarLow(_Symbol,
                 timeframe,
                 gapIndex,
                 gapBarLow,
                 "UpdateBullishGapBarStopLevel"))
     {
      return;
     }

//--- Store the structural stop reference for the bullish setup
   oopsState.gapBarLow = gapBarLow;
  }

//+------------------------------------------------------------------+
//| Stores the gap-bar high as the stop reference for a sell setup   |
//+------------------------------------------------------------------+
void UpdateBearishGapBarStopLevel()
  {
//--- Locate the original gap bar using its stored opening time
   ResetLastError();

   int gapIndex = iBarShift(_Symbol,
                            timeframe,
                            oopsState.gapBarTime);

   if(gapIndex == -1)
     {
      Print("UpdateBearishGapBarStopLevel: Failed to locate the gap bar. Error ",
            GetLastError(), ".");
      return;
     }

   double gapBarHigh = 0.0;

//--- Read the high of the recovered gap bar
   if(!GetBarHigh(_Symbol,
                  timeframe,
                  gapIndex,
                  gapBarHigh,
                  "UpdateBearishGapBarStopLevel"))
     {
      return;
     }

//--- Store the structural stop reference for the bearish setup
   oopsState.gapBarHigh = gapBarHigh;
  }
  
//+------------------------------------------------------------------+
//| Calculates the take-profit level for a confirmed buy setup       |
//+------------------------------------------------------------------+
void UpdateBullishTakeProfit(double entryPrice)
  {
   double stopLoss     = oopsState.gapBarLow;
   double riskDistance = entryPrice - stopLoss;

//--- Reject a stop placed at or above the intended buy entry
   if(riskDistance <= 0.0)
     {
      PrintFormat("UpdateBullishTakeProfit: Invalid prices. Entry %.*f, "
                  "stop loss %.*f.",
                  _Digits,
                  entryPrice,
                  _Digits,
                  stopLoss);
      return;
     }

//--- Project the target above the entry by the configured risk multiple
   double projectedTP = entryPrice +
                        (riskDistance * riskRewardRatio);

//--- Store a price normalized to the symbol's number of digits
   oopsState.bullishTakeProfit = NormalizeDouble(projectedTP,
                                                _Digits);
  }

//+------------------------------------------------------------------+
//| Calculates the take-profit level for a confirmed sell setup      |
//+------------------------------------------------------------------+
void UpdateBearishTakeProfit(double entryPrice)
  {
   double stopLoss     = oopsState.gapBarHigh;
   double riskDistance = stopLoss - entryPrice;

//--- Reject a stop placed at or below the intended sell entry
   if(riskDistance <= 0.0)
     {
      PrintFormat("UpdateBearishTakeProfit: Invalid prices. Entry %.*f, "
                  "stop loss %.*f.",
                  _Digits,
                  entryPrice,
                  _Digits,
                  stopLoss);
      return;
     }

//--- Project the target below the entry by the configured risk multiple
   double projectedTP = entryPrice -
                        (riskDistance * riskRewardRatio);

//--- Store a price normalized to the symbol's number of digits
   oopsState.bearishTakeProfit = NormalizeDouble(projectedTP,
                                                _Digits);
  }
  
//+------------------------------------------------------------------+
//| Calculates a broker-compatible volume from the configured risk   |
//+------------------------------------------------------------------+
double CalculatePositionSizeByRisk(ENUM_ORDER_TYPE orderType,
                                   double entryPrice,
                                   double stopLossPrice)
  {
//--- Use the account balance as the base for percentage risk
   ResetLastError();

   double accountBalance = AccountInfoDouble(ACCOUNT_BALANCE);

   if(accountBalance <= 0.0)
     {
      Print("CalculatePositionSizeByRisk: Invalid account balance. Error ",
            GetLastError(), ".");
      return 0.0;
     }

//--- Convert the selected percentage into a monetary risk amount
   double amountAtRisk = (riskPerTradePercent / 100.0) *
                         accountBalance;

   if(amountAtRisk <= 0.0)
     {
      Print("CalculatePositionSizeByRisk: The calculated risk amount is invalid.");
      return 0.0;
     }

//--- Estimate the loss produced by one lot at the selected stop
   double lossPerLot = 0.0;

   ResetLastError();

   if(!OrderCalcProfit(orderType,
                       _Symbol,
                       1.0,
                       entryPrice,
                       stopLossPrice,
                       lossPerLot))
     {
      Print("CalculatePositionSizeByRisk: OrderCalcProfit failed. Error ",
            GetLastError(), ".");
      return 0.0;
     }

   lossPerLot = MathAbs(lossPerLot);

   if(lossPerLot <= 0.0)
     {
      Print("CalculatePositionSizeByRisk: Loss per lot is invalid.");
      return 0.0;
     }

//--- Divide the permitted loss by the estimated one-lot loss
   double volume = amountAtRisk / lossPerLot;

//--- Read the broker's volume constraints for the current symbol
   double minLot  = 0.0;
   double maxLot  = 0.0;
   double lotStep = 0.0;

   if(!GetSymbolDoubleValue(_Symbol,
                            SYMBOL_VOLUME_MIN,
                            minLot,
                            "CalculatePositionSizeByRisk"))
     {
      return 0.0;
     }

   if(!GetSymbolDoubleValue(_Symbol,
                            SYMBOL_VOLUME_MAX,
                            maxLot,
                            "CalculatePositionSizeByRisk"))
     {
      return 0.0;
     }

   if(!GetSymbolDoubleValue(_Symbol,
                            SYMBOL_VOLUME_STEP,
                            lotStep,
                            "CalculatePositionSizeByRisk"))
     {
      return 0.0;
     }

//--- Reject inconsistent broker volume specifications
   if(minLot <= 0.0 ||
      maxLot <= 0.0 ||
      lotStep <= 0.0 ||
      minLot > maxLot)
     {
      Print("CalculatePositionSizeByRisk: Invalid broker volume constraints.");
      return 0.0;
     }

//--- Round down so normalization does not increase the intended risk
   volume = MathFloor(volume / lotStep) * lotStep;

//--- Clamp the result to the broker's permitted range
   if(volume < minLot)
      volume = minLot;

   if(volume > maxLot)
      volume = maxLot;

   return NormalizeDouble(volume, 2);
  }
  
//+------------------------------------------------------------------+
//| Updates the volume prepared for the current Oops setup            |
//+------------------------------------------------------------------+
void UpdateOopsPositionSize()
  {
//--- Manual mode uses the fixed volume selected in the inputs
   if(lotSizeMode == MODE_MANUAL)
     {
      oopsState.lotSize = positionSize;
      return;
     }

//--- Select the structural stop associated with the setup direction
   double stopLossPrice = 0.0;

   if(oopsState.orderType == ORDER_TYPE_BUY)
      stopLossPrice = oopsState.gapBarLow;
   else
      if(oopsState.orderType == ORDER_TYPE_SELL)
         stopLossPrice = oopsState.gapBarHigh;

//--- Calculate the volume from the prepared entry and stop prices
   double calculatedLot = CalculatePositionSizeByRisk(
                             oopsState.orderType,
                             oopsState.positionEntryPrice,
                             stopLossPrice
                          );

//--- Fall back to the manual value when automatic sizing fails
   if(calculatedLot <= 0.0)
     {
      Print("UpdateOopsPositionSize: Falling back to manual lot size.");
      oopsState.lotSize = positionSize;
      return;
     }

   oopsState.lotSize = calculatedLot;
  }
  
//+------------------------------------------------------------------+
//| Returns true when an open buy position uses the supplied magic   |
//+------------------------------------------------------------------+
bool IsThereAnActiveBuyPosition(ulong magic)
  {
   int totalPositions = PositionsTotal();

//--- Inspect every open position
   for(int i = totalPositions - 1; i >= 0; i--)
     {
      ResetLastError();

//--- PositionGetTicket() also selects the position for property access
      ulong ticket = PositionGetTicket(i);

      if(ticket == 0)
        {
         Print("IsThereAnActiveBuyPosition: Failed to select position ",
               i, ". Error ", GetLastError(), ".");
         continue;
        }

      long positionMagic = 0;
      long positionType  = -1;

//--- Read the identifier assigned by the opening Expert Advisor
      ResetLastError();

      if(!PositionGetInteger(POSITION_MAGIC, positionMagic))
        {
         Print("IsThereAnActiveBuyPosition: Failed to read POSITION_MAGIC "
               "for ticket ", ticket, ". Error ", GetLastError(), ".");
         continue;
        }

//--- Read the direction of the selected position
      ResetLastError();

      if(!PositionGetInteger(POSITION_TYPE, positionType))
        {
         Print("IsThereAnActiveBuyPosition: Failed to read POSITION_TYPE "
               "for ticket ", ticket, ". Error ", GetLastError(), ".");
         continue;
        }

//--- Stop after finding a buy position managed by this EA
      if((ulong)positionMagic == magic &&
         (ENUM_POSITION_TYPE)positionType == POSITION_TYPE_BUY)
        {
         return true;
        }
     }

   return false;
  }

//+------------------------------------------------------------------+
//| Returns true when an open sell position uses the supplied magic  |
//+------------------------------------------------------------------+
bool IsThereAnActiveSellPosition(ulong magic)
  {
   int totalPositions = PositionsTotal();

//--- Inspect every open position
   for(int i = totalPositions - 1; i >= 0; i--)
     {
      ResetLastError();

//--- Select the position and obtain its ticket
      ulong ticket = PositionGetTicket(i);

      if(ticket == 0)
        {
         Print("IsThereAnActiveSellPosition: Failed to select position ",
               i, ". Error ", GetLastError(), ".");
         continue;
        }

      long positionMagic = 0;
      long positionType  = -1;

//--- Read the identifier assigned by the opening Expert Advisor
      ResetLastError();

      if(!PositionGetInteger(POSITION_MAGIC, positionMagic))
        {
         Print("IsThereAnActiveSellPosition: Failed to read POSITION_MAGIC "
               "for ticket ", ticket, ". Error ", GetLastError(), ".");
         continue;
        }

//--- Read the direction of the selected position
      ResetLastError();

      if(!PositionGetInteger(POSITION_TYPE, positionType))
        {
         Print("IsThereAnActiveSellPosition: Failed to read POSITION_TYPE "
               "for ticket ", ticket, ". Error ", GetLastError(), ".");
         continue;
        }

//--- Stop after finding a sell position managed by this EA
      if((ulong)positionMagic == magic &&
         (ENUM_POSITION_TYPE)positionType == POSITION_TYPE_SELL)
        {
         return true;
        }
     }

   return false;
  }
  
//+------------------------------------------------------------------+
//| Checks whether the trade server accepted the submitted request   |
//+------------------------------------------------------------------+
bool IsTradeRequestSuccessful(string context)
  {
//--- Read the result code returned by the trade server
   uint retcode = Trade.ResultRetcode();

//--- Accept completed, partially completed, or placed requests
   if(retcode == TRADE_RETCODE_DONE ||
      retcode == TRADE_RETCODE_DONE_PARTIAL ||
      retcode == TRADE_RETCODE_PLACED)
     {
      PrintFormat("%s: Trade request accepted. Retcode %u (%s).",
                  context,
                  retcode,
                  Trade.ResultRetcodeDescription());
      return true;
     }

//--- Report the complete server response when the request is rejected
   PrintFormat("%s: Trade request rejected. Retcode %u (%s). Comment: %s.",
               context,
               retcode,
               Trade.ResultRetcodeDescription(),
               Trade.ResultComment());

   return false;
  }
  
//+------------------------------------------------------------------+
//| Sends a market buy request and verifies the server response      |
//+------------------------------------------------------------------+
bool OpenBuy(double entryPrice,
             double stopLoss,
             double takeProfit,
             double lotSize)
  {
   ResetLastError();

//--- Submit the market buy request with the prepared trade values
   if(!Trade.Buy(lotSize,
                 _Symbol,
                 entryPrice,
                 stopLoss,
                 takeProfit))
     {
      PrintFormat("OpenBuy: Trade.Buy failed. Error %d. Retcode %u (%s). "
                  "Comment: %s.",
                  GetLastError(),
                  Trade.ResultRetcode(),
                  Trade.ResultRetcodeDescription(),
                  Trade.ResultComment());
      return false;
     }

//--- Confirm that the trade server accepted the submitted request
   if(!IsTradeRequestSuccessful("OpenBuy"))
      return false;

   return true;
  }

//+------------------------------------------------------------------+
//| Sends a market sell request and verifies the server response     |
//+------------------------------------------------------------------+
bool OpenSell(double entryPrice,
              double stopLoss,
              double takeProfit,
              double lotSize)
  {
   ResetLastError();

//--- Submit the market sell request with the prepared trade values
   if(!Trade.Sell(lotSize,
                  _Symbol,
                  entryPrice,
                  stopLoss,
                  takeProfit))
     {
      PrintFormat("OpenSell: Trade.Sell failed. Error %d. Retcode %u (%s). "
                  "Comment: %s.",
                  GetLastError(),
                  Trade.ResultRetcode(),
                  Trade.ResultRetcodeDescription(),
                  Trade.ResultComment());
      return false;
     }

//--- Confirm that the trade server accepted the submitted request
   if(!IsTradeRequestSuccessful("OpenSell"))
      return false;

   return true;
  }

//+------------------------------------------------------------------+
//| Expert initialization function                                  |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- Stop initialization if the testing chart cannot be configured
   if(!ConfigureChartAppearance())
     {
      Print("OnInit: Failed to configure the chart appearance.");
      return INIT_FAILED;
     }

//--- Assign the identifier used to distinguish this EA's positions
   Trade.SetExpertMagicNumber(magicNumber);

//--- Allow the first verified bar time to initialize bar tracking
   lastBarOpenTime = 0;

//--- Start without an active or partially initialized setup
   ResetOopsPatternState();

   return INIT_SUCCEEDED;
  }

//+------------------------------------------------------------------+
//| Expert deinitialization function                                |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//--- Record the reason supplied by MetaTrader 5 when the EA stops
   Print("Program terminated! Reason code: ", reason);
  }
  
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
//--- Stop the current processing cycle when the Ask price is unavailable
   if(!GetSymbolDoubleValue(_Symbol,
                            SYMBOL_ASK,
                            askPrice,
                            "OnTick"))
     {
      return;
     }

//--- Stop the current processing cycle when the Bid price is unavailable
   if(!GetSymbolDoubleValue(_Symbol,
                            SYMBOL_BID,
                            bidPrice,
                            "OnTick"))
     {
      return;
     }

//--- Store the latest terminal time for the current event cycle
   currentTime = TimeCurrent();

//--- Evaluate the strategy only once when a new candle opens
   if(!IsNewBar(_Symbol,
                timeframe,
                lastBarOpenTime))
     {
      return;
     }

//--- Create a new setup only when no earlier gap is active
   DetectAndInitializeOopsGap();

//--- Increase the setup age or remove it after expiration
   UpdateOopsGapState();

//--- Prepare and process a confirmed bullish reversal
   if(IsBullishSignal())
     {
      Print("Bullish Signal Detected!!");

//--- Use the current Ask price as the intended buy entry
      oopsState.positionEntryPrice = askPrice;

//--- Prepare the stop loss, take profit, and position size
      UpdateBullishGapBarStopLevel();
      UpdateBullishTakeProfit(oopsState.positionEntryPrice);
      UpdateOopsPositionSize();

//--- Continue only when bullish trading is permitted
      if(tradeDirection == OOPS_TRADE_BOTH ||
         tradeDirection == OOPS_TRADE_LONG_ONLY)
        {
//--- Block the order when another EA-managed position is active
         if(!IsThereAnActiveBuyPosition(magicNumber) &&
            !IsThereAnActiveSellPosition(magicNumber))
           {
            if(!OpenBuy(oopsState.positionEntryPrice,
                        oopsState.gapBarLow,
                        oopsState.bullishTakeProfit,
                        oopsState.lotSize))
              {
               Print("OnTick: The bullish Oops trade was not opened.");
              }
           }
        }

//--- Complete the setup lifecycle regardless of execution outcome
      ResetOopsPatternState();
     }

//--- Prepare and process a confirmed bearish reversal
   if(IsBearishSignal())
     {
      Print("Bearish Signal Detected!!");

//--- Use the current Bid price as the intended sell entry
      oopsState.positionEntryPrice = bidPrice;

//--- Prepare the stop loss, take profit, and position size
      UpdateBearishGapBarStopLevel();
      UpdateBearishTakeProfit(oopsState.positionEntryPrice);
      UpdateOopsPositionSize();

//--- Continue only when bearish trading is permitted
      if(tradeDirection == OOPS_TRADE_BOTH ||
         tradeDirection == OOPS_TRADE_SHORT_ONLY)
        {
//--- Block the order when another EA-managed position is active
         if(!IsThereAnActiveBuyPosition(magicNumber) &&
            !IsThereAnActiveSellPosition(magicNumber))
           {
            if(!OpenSell(oopsState.positionEntryPrice,
                         oopsState.gapBarHigh,
                         oopsState.bearishTakeProfit,
                         oopsState.lotSize))
              {
               Print("OnTick: The bearish Oops trade was not opened.");
              }
           }
        }

//--- Clear the completed setup before tracking another gap
      ResetOopsPatternState();
     }
  }
  
//+------------------------------------------------------------------+