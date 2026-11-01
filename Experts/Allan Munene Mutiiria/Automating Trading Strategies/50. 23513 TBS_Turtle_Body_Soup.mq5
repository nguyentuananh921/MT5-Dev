//+------------------------------------------------------------------+
//|                                         TBS Turtle Body Soup.mq5 |
//|                           Copyright 2026, Allan Munene Mutiiria. |
//|                                   https://t.me/Forex_Algo_Trader |
//+------------------------------------------------------------------+
#property copyright "Copyright 2026, Allan Munene Mutiiria."
#property link      "https://t.me/Forex_Algo_Trader"
#property version   "1.00"
#property strict

#include <Trade\Trade.mqh>

//+------------------------------------------------------------------+
//| Enums                                                            |
//+------------------------------------------------------------------+
enum ENUM_SLTP_METHOD
  {
   SLTP_Dynamic = 0, // Dynamic (SL beyond sweep extreme)
   SLTP_Static  = 1  // Static (fixed points)
  };

enum ENUM_TRAILING_TYPE
  {
   Trail_None   = 0, // None
   Trail_Points = 1  // By Points
  };

enum ENUM_TP_MODE
  {
   TP_RiskReward    = 0, // Fixed Risk:Reward multiple
   TP_OppositeRange = 1  // Opposite side of the lookback range
  };

//+------------------------------------------------------------------+
//| Inputs                                                           |
//+------------------------------------------------------------------+
input group "Setup Detection"
input ENUM_TIMEFRAMES InpSignalTimeframe       = PERIOD_CURRENT; // Signal Timeframe
input int    InpLookbackBars                   = 20;             // Lookback Bars for N-Bar High/Low (Turtle = 20)
input int    InpMinExtremeAgeBars              = 4;              // Min Bars Between Prior Extreme and Sweep
input int    InpSweepWindowBars                = 1;              // Bars Allowed to Contain the Sweep (1 = Classic)
input int    InpConfirmCloseBars               = 1;              // Consecutive Closes Back Inside to Confirm
input bool   InpRequireBearBullBody            = true;           // Require Reversal Candle Body in Trade Direction

input group "Sweep Depth Filter"
input bool   InpUseSweepDepthFilter            = true;           // Enable Sweep Depth Filter
input double InpMinSweepDepthPoints            = 30.0;           // Min Sweep Beyond Level (Points)
input double InpMinSweepDepthPctRange          = 2.0;            // Min Sweep as % of Lookback Range

input group "Risk / Orders"
input double InpLotSize                        = 0.01;           // Trade Volume (Lots)
input ENUM_SLTP_METHOD InpSLTPMethod           = SLTP_Dynamic;   // SL Calculation Method
input ENUM_TP_MODE     InpTPMode               = TP_RiskReward;  // Take-Profit Mode
input double InpRiskRewardRatio                = 1.0;            // Risk:Reward Ratio (RR Target Mode)
input int    InpStaticSLPoints                 = 5000;            // SL Points (Static Method)
input double InpSLBufferPoints                 = 3000.0;           // Extra SL Buffer in Points (Both Methods)
input int    InpMaxPositionsPerDirection       = 1;              // Max Open Positions Per Direction
input int    InpMagicNumber                    = 1107;       // Magic Number

input group "Trailing"
input ENUM_TRAILING_TYPE InpTrailingType                = Trail_None; // Trailing Stop Type
input double             InpTrailingStopPoints          = 300.0;       // Trailing Stop Distance (Points)
input double             InpMinProfitToActivateTrail    = 1000.0;       // Min Profit to Start Trailing (Points)

input group "Visuals"
input bool   InpShowVisuals    = true;          // Draw Chart Objects
input color  InpNBarHighColor  = clrOrange;     // N-Bar High (Buy-Side Liquidity) Color
input color  InpNBarLowColor   = clrDodgerBlue; // N-Bar Low (Sell-Side Liquidity) Color
input color  InpSellSetupColor = clrCrimson;    // Sell Setup Color
input color  InpBuySetupColor  = C'0,150,0';   // Buy Setup Color

//+------------------------------------------------------------------+
//| Global Variables                                                 |
//+------------------------------------------------------------------+
CTrade   g_trade;                            // Trade execution object
datetime g_lastBarTime        = 0;           // Last processed signal-bar open time
datetime g_lastSellSignalTime = 0;           // Last sell signal bar time (deduplication guard)
datetime g_lastBuySignalTime  = 0;           // Last buy signal bar time (deduplication guard)
double   g_cachedRefHigh      = 0.0;         // Most recent lookback reference high price
double   g_cachedRefLow       = 0.0;         // Most recent lookback reference low price
string   OBJ_PREFIX           = "TSOUP_";    // Chart object name prefix for bulk cleanup

//+------------------------------------------------------------------+
//| Count active positions filtered by symbol, magic, and direction  |
//+------------------------------------------------------------------+
int CountActivePositions(ENUM_POSITION_TYPE positionType)
  {
   int count = 0;
   //--- Scan all open positions in reverse order
   for(int pos = PositionsTotal() - 1; pos >= 0; pos--)
     {
      //--- Retrieve ticket for this position slot
      ulong ticket = PositionGetTicket(pos);
      //--- Skip invalid or unselectable tickets
      if(ticket == 0) continue;
      //--- Count only positions matching this symbol, magic number, and direction
      if(PositionGetString(POSITION_SYMBOL)    == _Symbol
         && PositionGetInteger(POSITION_MAGIC) == InpMagicNumber
         && PositionGetInteger(POSITION_TYPE)  == positionType)
         count++;
     }
   //--- Return total matched positions
   return count;
  }

//+------------------------------------------------------------------+
//| Check that N consecutive closed bars are inside the level        |
//+------------------------------------------------------------------+
bool AllConfirmClosesInsideLevel(bool checkBelowLevel, double referenceLevel, int barsToConfirm)
  {
   //--- Test each confirmation bar from the most recent closed bar outward
   for(int barIdx = 1; barIdx <= barsToConfirm; barIdx++)
     {
      //--- Fetch closing price of this confirmation bar
      double closePrice = iClose(_Symbol, InpSignalTimeframe, barIdx);
      //--- Sell confirmation: close must be below the swept high
      if(checkBelowLevel)
        {
         //--- Fail immediately if any close is still above the level
         if(!(closePrice < referenceLevel)) return false;
        }
      else
        {
         //--- Buy confirmation: close must be above the swept low
         //--- Fail immediately if any close is still below the level
         if(!(closePrice > referenceLevel)) return false;
        }
     }
   //--- All confirmation bars closed on the correct side
   return true;
  }

//+------------------------------------------------------------------+
//| Draw a bounded horizontal price segment as an entry reference    |
//+------------------------------------------------------------------+
void DrawHorizontalSegment(string objName, datetime startTime, double price, datetime endTime,
                           color lineColor, ENUM_LINE_STYLE lineStyle, int lineWidth)
  {
   //--- Remove any prior object sharing this name
   ObjectDelete(ChartID(), objName);
   //--- Create a horizontal trend line anchored between startTime and endTime
   ObjectCreate(ChartID(), objName, OBJ_TREND, 0, startTime, price, endTime, price);
   //--- Apply visual properties
   ObjectSetInteger(ChartID(), objName, OBJPROP_COLOR,      lineColor);
   ObjectSetInteger(ChartID(), objName, OBJPROP_STYLE,      lineStyle);
   ObjectSetInteger(ChartID(), objName, OBJPROP_WIDTH,      lineWidth);
   //--- Disable rightward ray so segment stays bounded
   ObjectSetInteger(ChartID(), objName, OBJPROP_RAY_RIGHT,  false);
   //--- Lock the object from accidental user interaction
   ObjectSetInteger(ChartID(), objName, OBJPROP_SELECTABLE, false);
  }

//+------------------------------------------------------------------+
//| Draw a filled risk or reward rectangle behind the candles        |
//+------------------------------------------------------------------+
void DrawFilledTradeBox(string objName, datetime startTime, double priceA,
                        datetime endTime, double priceB, color fillColor)
  {
   //--- Remove any prior object sharing this name
   ObjectDelete(ChartID(), objName);
   //--- Create rectangle spanning entry price to SL or TP
   ObjectCreate(ChartID(), objName, OBJ_RECTANGLE, 0, startTime, priceA, endTime, priceB);
   //--- Apply solid fill and visual properties
   ObjectSetInteger(ChartID(), objName, OBJPROP_COLOR,      fillColor);
   ObjectSetInteger(ChartID(), objName, OBJPROP_FILL,       true);
   //--- Render behind candlesticks so price action stays readable
   ObjectSetInteger(ChartID(), objName, OBJPROP_BACK,       true);
   ObjectSetInteger(ChartID(), objName, OBJPROP_STYLE,      STYLE_SOLID);
   ObjectSetInteger(ChartID(), objName, OBJPROP_WIDTH,      1);
   //--- Lock the object from accidental user interaction
   ObjectSetInteger(ChartID(), objName, OBJPROP_SELECTABLE, false);
  }

//+------------------------------------------------------------------+
//| Draw a Spectra-style vertical signal arrow with rotated label    |
//+------------------------------------------------------------------+
void DrawSignalArrowAndLabel(string baseName, datetime signalTime, double anchorPrice,
                             bool isBuy, string labelText, color signalColor)
  {
   //--- Select Wingdings glyph: 217 = up arrow for buy, 218 = down arrow for sell
   int arrowCode  = isBuy ? 217 : 218;
   //--- Rotate label -90 degrees (upward) for buy, +90 degrees (downward) for sell
   double labelAngle = isBuy ? -90.0 : 90.0;

   //--- Build unique object names for the arrow and text components
   string arrowObjName = baseName + "_ARW";
   string textObjName  = baseName + "_TXT";

   //--- Remove any prior arrow object
   ObjectDelete(ChartID(), arrowObjName);
   //--- Create the directional arrow at the signal bar price
   ObjectCreate(ChartID(), arrowObjName, OBJ_ARROW, 0, signalTime, anchorPrice);
   ObjectSetInteger(ChartID(), arrowObjName, OBJPROP_ARROWCODE,  arrowCode);
   ObjectSetInteger(ChartID(), arrowObjName, OBJPROP_COLOR,      signalColor);
   ObjectSetInteger(ChartID(), arrowObjName, OBJPROP_WIDTH,      2);
   //--- Render in foreground so arrow sits above candles
   ObjectSetInteger(ChartID(), arrowObjName, OBJPROP_BACK,       false);
   //--- Anchor top of arrow below candle for buy; anchor bottom above candle for sell
   ObjectSetInteger(ChartID(), arrowObjName, OBJPROP_ANCHOR,     isBuy ? ANCHOR_TOP : ANCHOR_BOTTOM);
   ObjectSetInteger(ChartID(), arrowObjName, OBJPROP_SELECTABLE, false);

   //--- Remove any prior text label object
   ObjectDelete(ChartID(), textObjName);
   //--- Create the rotated label at the same coordinate as the arrow
   ObjectCreate(ChartID(), textObjName, OBJ_TEXT, 0, signalTime, anchorPrice);
   //--- Four leading spaces visually clear the arrow glyph before the label text
   ObjectSetString(ChartID(),  textObjName, OBJPROP_TEXT,        "    " + labelText);
   ObjectSetString(ChartID(),  textObjName, OBJPROP_FONT,        "Calibri Bold");
   ObjectSetInteger(ChartID(), textObjName, OBJPROP_FONTSIZE,    11);
   ObjectSetInteger(ChartID(), textObjName, OBJPROP_COLOR,       signalColor);
   //--- Apply vertical rotation to render the label upright beside the arrow
   ObjectSetDouble(ChartID(),  textObjName, OBJPROP_ANGLE,       labelAngle);
   ObjectSetInteger(ChartID(), textObjName, OBJPROP_ANCHOR,      ANCHOR_LEFT);
   ObjectSetInteger(ChartID(), textObjName, OBJPROP_SELECTABLE,  false);
  }

//+------------------------------------------------------------------+
//| Render or update a dotted horizontal price level line            |
//+------------------------------------------------------------------+
void RenderHorizontalLevel(string objName, double levelPrice, color levelColor, string tooltipText)
  {
   //--- Create the horizontal line only on the first call
   if(ObjectFind(ChartID(), objName) < 0)
     {
      ObjectCreate(ChartID(), objName, OBJ_HLINE, 0, 0, levelPrice);
      ObjectSetInteger(ChartID(), objName, OBJPROP_STYLE,   STYLE_DOT);
      ObjectSetString(ChartID(),  objName, OBJPROP_TOOLTIP, tooltipText);
     }
   //--- Update price and color on every subsequent call
   ObjectSetDouble(ChartID(),  objName, OBJPROP_PRICE, levelPrice);
   ObjectSetInteger(ChartID(), objName, OBJPROP_COLOR, levelColor);
   ChartRedraw(ChartID());
  }

//+------------------------------------------------------------------+
//| Create or replace a text label at a chart time/price coordinate  |
//+------------------------------------------------------------------+
void RenderPriceLabel(string objName, datetime labelTime, double labelPrice,
                      string labelText, color textColor, int anchorType)
  {
   //--- Always delete and recreate to guarantee position accuracy
   ObjectDelete(ChartID(), objName);
   ObjectCreate(ChartID(), objName, OBJ_TEXT, 0, labelTime, labelPrice);
   ObjectSetString(ChartID(),  objName, OBJPROP_TEXT,     labelText);
   ObjectSetInteger(ChartID(), objName, OBJPROP_COLOR,    textColor);
   ObjectSetInteger(ChartID(), objName, OBJPROP_ANCHOR,   anchorType);
   ObjectSetInteger(ChartID(), objName, OBJPROP_FONTSIZE, 10);
   ChartRedraw(ChartID());
  }

//+------------------------------------------------------------------+
//| Draw sweep box, filled R/R boxes, signal arrow, and price labels |
//+------------------------------------------------------------------+
void DrawTradeSetupVisuals(bool isBuy, double sweptLevel, double sweepExtreme, double entryPrice,
                           double stopLoss, double takeProfit, datetime signalBarTime)
  {
   //--- Build a unique object name suffix from the signal bar timestamp
   string timeSuffix = IntegerToString((long)signalBarTime);
   //--- Choose colors based on trade direction
   color setupColor = isBuy ? InpBuySetupColor : InpSellSetupColor;

   //--- Clamp sweep window to at least one bar
   int sweepWindowSize = MathMax(InpSweepWindowBars, 1);

   //--- Resolve the start time of the sweep window and the current bar time
   datetime sweepStartTime = iTime(_Symbol, InpSignalTimeframe, sweepWindowSize);
   datetime currentBarTime = iTime(_Symbol, InpSignalTimeframe, 0);
   //--- Project the trade annotation box eight bars into the future for readability
   datetime tradeBoxEndTime = currentBarTime + (datetime)(PeriodSeconds(InpSignalTimeframe) * 8);

   //--- Define annotation colors
   color slBorderColor  = clrCrimson;     // Stop loss label color
   color tpBorderColor  = C'0,140,0';    // Take profit label color (dark green)
   color entryLineColor = C'40,40,40';   // Entry line and label color (near-black)
   color riskBoxFill    = C'255,200,200'; // Risk zone fill (light red)
   color rewardBoxFill  = C'200,235,200'; // Reward zone fill (light green)
   color buyArrowColor  = C'0,150,0';    // Buy signal arrow color
   color sellArrowColor = clrCrimson;     // Sell signal arrow color

   //--- Compute sweep rectangle boundary prices
   double rectTop = MathMax(sweptLevel, sweepExtreme);
   double rectBot = MathMin(sweptLevel, sweepExtreme);

   //--- Draw the sweep zone rectangle from sweep window start to current bar
   string sweepRectName = OBJ_PREFIX + "Sweep_" + timeSuffix;
   ObjectCreate(ChartID(), sweepRectName, OBJ_RECTANGLE, 0, sweepStartTime, rectTop, currentBarTime, rectBot);
   ObjectSetInteger(ChartID(), sweepRectName, OBJPROP_COLOR, setupColor);
   ObjectSetInteger(ChartID(), sweepRectName, OBJPROP_FILL,  false);
   ObjectSetInteger(ChartID(), sweepRectName, OBJPROP_BACK,  true);
   ObjectSetInteger(ChartID(), sweepRectName, OBJPROP_STYLE, STYLE_DOT);
   ObjectSetInteger(ChartID(), sweepRectName, OBJPROP_WIDTH, 2);

   //--- Place the "Turtle Soup (sweep)" label centered vertically on the left edge of the box
   double sweepBoxMidPrice = (rectTop + rectBot) * 0.5;
   RenderPriceLabel(OBJ_PREFIX + "SwTxt_" + timeSuffix, sweepStartTime, sweepBoxMidPrice,
                    "Turtle Soup (sweep)  ", setupColor, ANCHOR_RIGHT);

   //--- Draw the filled risk box (entry to SL) and reward box (entry to TP)
   DrawFilledTradeBox(OBJ_PREFIX + "RiskBox_" + timeSuffix,
                      signalBarTime, entryPrice, tradeBoxEndTime, stopLoss,   riskBoxFill);
   DrawFilledTradeBox(OBJ_PREFIX + "RewBox_"  + timeSuffix,
                      signalBarTime, entryPrice, tradeBoxEndTime, takeProfit, rewardBoxFill);

   //--- Draw the entry reference line spanning the width of the trade box
   DrawHorizontalSegment(OBJ_PREFIX + "EnLine_" + timeSuffix,
                         signalBarTime, entryPrice, tradeBoxEndTime, entryLineColor, STYLE_SOLID, 2);

   //--- Anchor the signal arrow to bar low for buy, bar high for sell
   double signalArrowPrice = isBuy
                             ? iLow (_Symbol, InpSignalTimeframe, 1)
                             : iHigh(_Symbol, InpSignalTimeframe, 1);
   DrawSignalArrowAndLabel(OBJ_PREFIX + "Sig_" + timeSuffix,
                           signalBarTime, signalArrowPrice, isBuy,
                           isBuy ? "  Buy" : "  Sell",
                           isBuy ? buyArrowColor : sellArrowColor);

   //--- Compute SL distance in points and achieved R multiple for the labels
   double slDistancePoints = MathAbs(entryPrice - stopLoss) / _Point;
   double achievedRMultiple = (MathAbs(entryPrice - stopLoss) > 0.0)
                              ? MathAbs(takeProfit - entryPrice) / MathAbs(entryPrice - stopLoss)
                              : 0.0;

   //--- For buy: SL label anchors below, TP label anchors above; mirror for sell
   int slLabelAnchor = isBuy ? ANCHOR_RIGHT_UPPER : ANCHOR_RIGHT_LOWER;
   int tpLabelAnchor = isBuy ? ANCHOR_RIGHT_LOWER : ANCHOR_RIGHT_UPPER;

   //--- Render entry, SL, and TP price labels at the right edge of the trade box
   RenderPriceLabel(OBJ_PREFIX + "EnTxt_" + timeSuffix, tradeBoxEndTime, entryPrice,
                    "Entry " + DoubleToString(entryPrice, _Digits) + "  ",
                    entryLineColor, ANCHOR_RIGHT);
   RenderPriceLabel(OBJ_PREFIX + "SlTxt_" + timeSuffix, tradeBoxEndTime, stopLoss,
                    "SL " + DoubleToString(stopLoss, _Digits)
                    + " (" + DoubleToString(slDistancePoints, 0) + " pts)  ",
                    slBorderColor, slLabelAnchor);
   RenderPriceLabel(OBJ_PREFIX + "TpTxt_" + timeSuffix, tradeBoxEndTime, takeProfit,
                    "TP " + DoubleToString(takeProfit, _Digits)
                    + " (" + DoubleToString(achievedRMultiple, 2) + "R)  ",
                    tpBorderColor, tpLabelAnchor);

   ChartRedraw(ChartID());
  }

//+------------------------------------------------------------------+
//| Calculate SL/TP, place the market order, and log the result      |
//+------------------------------------------------------------------+
bool OpenTurtleSoupTrade(bool isBuy, double sweptLevel, double sweepExtreme,
                         double oppositeRangeLevel, double lookbackRange,
                         int extremeAgeBars, double sweepDepth, datetime signalBarTime)
  {
   //--- Gather current market prices and symbol properties
   double askPrice         = SymbolInfoDouble(_Symbol, SYMBOL_ASK);
   double bidPrice         = SymbolInfoDouble(_Symbol, SYMBOL_BID);
   double pointSize        = _Point;
   int    priceDigits      = (int)_Digits;
   long   brokerStopsLevel = SymbolInfoInteger(_Symbol, SYMBOL_TRADE_STOPS_LEVEL);
   //--- Convert broker stops level from points to price distance
   double minStopDistance  = (double)brokerStopsLevel * pointSize;

   double entryPrice, stopLoss, takeProfit, riskDistance;

   if(isBuy)
     {
      //--- Enter long at the current ask price
      entryPrice = askPrice;
      //--- Place SL below the sweep low with optional extra buffer (dynamic), or at a fixed distance (static)
      if(InpSLTPMethod == SLTP_Dynamic)
         stopLoss = sweepExtreme - InpSLBufferPoints * pointSize;
      else
         stopLoss = entryPrice - (InpStaticSLPoints + InpSLBufferPoints) * pointSize;
      //--- Calculate raw risk distance from entry to SL
      riskDistance = entryPrice - stopLoss;
      //--- Clamp risk distance to the broker minimum to avoid rejection
      if(riskDistance < minStopDistance || riskDistance <= 0.0)
        {
         riskDistance = minStopDistance;
         stopLoss     = entryPrice - riskDistance;
        }
      //--- Target the opposite side of the lookback range if that mode is active
      if(InpTPMode == TP_OppositeRange)
        {
         takeProfit = oppositeRangeLevel;
         //--- Fall back to RR ratio if the opposite level is too close to entry
         if(takeProfit - entryPrice < minStopDistance)
            takeProfit = entryPrice + riskDistance * InpRiskRewardRatio;
        }
      else
        {
         //--- Target a fixed RR multiple of the risk distance
         takeProfit = entryPrice + riskDistance * InpRiskRewardRatio;
        }
      //--- Enforce broker minimum stop distance on both SL and TP
      if(entryPrice - stopLoss    < minStopDistance) stopLoss   = entryPrice - minStopDistance;
      if(takeProfit - entryPrice  < minStopDistance) takeProfit = entryPrice + minStopDistance;
      //--- Round SL and TP to the symbol's decimal precision
      stopLoss   = NormalizeDouble(stopLoss,   priceDigits);
      takeProfit = NormalizeDouble(takeProfit, priceDigits);
      //--- Send the buy market order to the server
      if(!g_trade.Buy(InpLotSize, _Symbol, entryPrice, stopLoss, takeProfit, "Turtle Soup Buy"))
        {
         Print("Buy failed: ", g_trade.ResultRetcodeDescription());
         return false;
        }
      //--- Abort if the server did not confirm the fill
      if(g_trade.ResultRetcode() != TRADE_RETCODE_DONE) return false;
      //--- Log all relevant trade details to the journal
      Print("BUY (Turtle Soup): swept ", DoubleToString(InpLookbackBars), "-bar low ",
            DoubleToString(sweptLevel,  priceDigits), " by ",
            DoubleToString(sweepDepth / pointSize, 0), " pts (",
            DoubleToString(sweepDepth  / lookbackRange * 100.0, 1), "% of range). Low was ",
            extremeAgeBars, " bars old. Entry ", DoubleToString(entryPrice, priceDigits),
            " SL ", DoubleToString(stopLoss,    priceDigits),
            " TP ", DoubleToString(takeProfit,  priceDigits));
     }
   else
     {
      //--- Enter short at the current bid price
      entryPrice = bidPrice;
      //--- Place SL above the sweep high with optional extra buffer (dynamic), or at a fixed distance (static)
      if(InpSLTPMethod == SLTP_Dynamic)
         stopLoss = sweepExtreme + InpSLBufferPoints * pointSize;
      else
         stopLoss = entryPrice + (InpStaticSLPoints + InpSLBufferPoints) * pointSize;
      //--- Calculate raw risk distance from entry to SL
      riskDistance = stopLoss - entryPrice;
      //--- Clamp risk distance to the broker minimum to avoid rejection
      if(riskDistance < minStopDistance || riskDistance <= 0.0)
        {
         riskDistance = minStopDistance;
         stopLoss     = entryPrice + riskDistance;
        }
      //--- Target the opposite side of the lookback range if that mode is active
      if(InpTPMode == TP_OppositeRange)
        {
         takeProfit = oppositeRangeLevel;
         //--- Fall back to RR ratio if the opposite level is too close to entry
         if(entryPrice - takeProfit < minStopDistance)
            takeProfit = entryPrice - riskDistance * InpRiskRewardRatio;
        }
      else
        {
         //--- Target a fixed RR multiple of the risk distance
         takeProfit = entryPrice - riskDistance * InpRiskRewardRatio;
        }
      //--- Enforce broker minimum stop distance on both SL and TP
      if(stopLoss   - entryPrice  < minStopDistance) stopLoss   = entryPrice + minStopDistance;
      if(entryPrice - takeProfit  < minStopDistance) takeProfit = entryPrice - minStopDistance;
      //--- Round SL and TP to the symbol's decimal precision
      stopLoss   = NormalizeDouble(stopLoss,   priceDigits);
      takeProfit = NormalizeDouble(takeProfit, priceDigits);
      //--- Send the sell market order to the server
      if(!g_trade.Sell(InpLotSize, _Symbol, entryPrice, stopLoss, takeProfit, "Turtle Soup Sell"))
        {
         Print("Sell failed: ", g_trade.ResultRetcodeDescription());
         return false;
        }
      //--- Abort if the server did not confirm the fill
      if(g_trade.ResultRetcode() != TRADE_RETCODE_DONE) return false;
      //--- Log all relevant trade details to the journal
      Print("SELL (Turtle Soup): swept ", DoubleToString(InpLookbackBars), "-bar high ",
            DoubleToString(sweptLevel,  priceDigits), " by ",
            DoubleToString(sweepDepth / pointSize, 0), " pts (",
            DoubleToString(sweepDepth  / lookbackRange * 100.0, 1), "% of range). High was ",
            extremeAgeBars, " bars old. Entry ", DoubleToString(entryPrice, priceDigits),
            " SL ", DoubleToString(stopLoss,    priceDigits),
            " TP ", DoubleToString(takeProfit,  priceDigits));
     }

   //--- Draw the visual trade setup annotations on the chart
   if(InpShowVisuals)
      DrawTradeSetupVisuals(isBuy, sweptLevel, sweepExtreme,
                            entryPrice, stopLoss, takeProfit, signalBarTime);
   return true;
  }

//+------------------------------------------------------------------+
//| Scan for Turtle Soup setups on the most recently closed bar      |
//+------------------------------------------------------------------+
void ScanForTurtleSoupSetups()
  {
   //--- Clamp windowing parameters to their minimum legal values
   int sweepWindow   = MathMax(InpSweepWindowBars,   1);
   int confirmBars   = MathMax(InpConfirmCloseBars,  1);
   //--- Calculate the minimum number of bars required to run the scan
   int minBarsNeeded = InpLookbackBars + sweepWindow + 2;
   //--- Abort silently until enough bar history is available
   if(Bars(_Symbol, InpSignalTimeframe) < minBarsNeeded) return;

   //--- The reference extreme is the highest/lowest of InpLookbackBars bars before the sweep window
   int refWindowStartShift = 1 + sweepWindow;
   //--- Locate the bar indices of the reference high and low within the lookback range
   int refHighBarShift = iHighest(_Symbol, InpSignalTimeframe, MODE_HIGH, InpLookbackBars, refWindowStartShift);
   int refLowBarShift  = iLowest (_Symbol, InpSignalTimeframe, MODE_LOW,  InpLookbackBars, refWindowStartShift);
   //--- Abort if either extreme lookup returned an invalid index
   if(refHighBarShift < 0 || refLowBarShift < 0) return;

   //--- Read the reference high and low prices
   double refHighPrice  = iHigh(_Symbol, InpSignalTimeframe, refHighBarShift);
   double refLowPrice   = iLow (_Symbol, InpSignalTimeframe, refLowBarShift);
   //--- Compute the full height of the lookback range
   double lookbackRange = refHighPrice - refLowPrice;
   //--- Abort if the range is degenerate (zero or negative)
   if(lookbackRange <= 0.0) return;

   //--- Cache the reference extremes for potential external access
   g_cachedRefHigh = refHighPrice;
   g_cachedRefLow  = refLowPrice;

   //--- Render the N-bar high and low liquidity level lines and labels
   if(InpShowVisuals)
     {
      RenderHorizontalLevel(OBJ_PREFIX + "HighLevel", refHighPrice, InpNBarHighColor,
                            "N-Bar High (BSL - buy-side liquidity)");
      RenderHorizontalLevel(OBJ_PREFIX + "LowLevel",  refLowPrice,  InpNBarLowColor,
                            "N-Bar Low (SSL - sell-side liquidity)");
      //--- Fetch current bar time for label placement
      datetime currentTime = iTime(_Symbol, InpSignalTimeframe, 0);
      RenderPriceLabel(OBJ_PREFIX + "HighTxt", currentTime, refHighPrice,
                       IntegerToString(InpLookbackBars) + "-Bar High (BSL)", InpNBarHighColor, ANCHOR_RIGHT_LOWER);
      RenderPriceLabel(OBJ_PREFIX + "LowTxt",  currentTime, refLowPrice,
                       IntegerToString(InpLookbackBars) + "-Bar Low (SSL)",  InpNBarLowColor,  ANCHOR_RIGHT_UPPER);
     }

   //--- Find the highest high and lowest low inside the sweep window [shift 1 .. sweepWindow]
   int    sweepHighBarShift = iHighest(_Symbol, InpSignalTimeframe, MODE_HIGH, sweepWindow, 1);
   int    sweepLowBarShift  = iLowest (_Symbol, InpSignalTimeframe, MODE_LOW,  sweepWindow, 1);
   double sweepWindowHigh   = iHigh(_Symbol, InpSignalTimeframe, sweepHighBarShift);
   double sweepWindowLow    = iLow (_Symbol, InpSignalTimeframe, sweepLowBarShift);

   //--- Compute the age of each reference extreme in bars (relative to the most recently closed bar)
   int refHighAgeBars = refHighBarShift - 1;
   int refLowAgeBars  = refLowBarShift  - 1;

   //--- Record the open time of the signal/confirmation bar
   datetime signalBarTime = iTime(_Symbol, InpSignalTimeframe, 1);

   //--- Evaluate sell setup: fade a false breakout above the N-bar high
   bool sellHighSwept       = (sweepWindowHigh > refHighPrice);
   //--- Verify all confirmation closes are back below the reference high
   bool sellClosedBelow     = AllConfirmClosesInsideLevel(true, refHighPrice, confirmBars);
   //--- Optionally require the confirmation bar to close with a bearish body
   bool sellBearishBody     = (!InpRequireBearBullBody)
                              || (iClose(_Symbol, InpSignalTimeframe, 1) < iOpen(_Symbol, InpSignalTimeframe, 1));
   //--- Require the reference high to be old enough to represent a meaningful prior extreme
   bool sellExtremeOldEnough = (refHighAgeBars >= InpMinExtremeAgeBars);
   //--- Measure how far price swept beyond the reference high
   double sellSweepDepth    = sweepWindowHigh - refHighPrice;
   //--- Apply the optional sweep depth filter (absolute points and range percentage)
   bool sellDepthPasses     = (!InpUseSweepDepthFilter)
                              || (sellSweepDepth >= InpMinSweepDepthPoints * _Point
                                  && (sellSweepDepth / lookbackRange * 100.0) >= InpMinSweepDepthPctRange);
   //--- Trigger a sell trade only when all conditions pass, the signal is not a duplicate, and the position limit allows
   if(sellHighSwept && sellClosedBelow && sellBearishBody && sellExtremeOldEnough && sellDepthPasses
      && g_lastSellSignalTime != signalBarTime
      && CountActivePositions(POSITION_TYPE_SELL) < InpMaxPositionsPerDirection)
     {
      //--- Attempt to open the sell and mark the signal bar as processed on success
      if(OpenTurtleSoupTrade(false, refHighPrice, sweepWindowHigh, refLowPrice,
                             lookbackRange, refHighAgeBars, sellSweepDepth, signalBarTime))
         g_lastSellSignalTime = signalBarTime;
     }

   //--- Evaluate buy setup: fade a false breakout below the N-bar low
   bool buyLowSwept         = (sweepWindowLow < refLowPrice);
   //--- Verify all confirmation closes are back above the reference low
   bool buyClosedAbove      = AllConfirmClosesInsideLevel(false, refLowPrice, confirmBars);
   //--- Optionally require the confirmation bar to close with a bullish body
   bool buyBullishBody      = (!InpRequireBearBullBody)
                              || (iClose(_Symbol, InpSignalTimeframe, 1) > iOpen(_Symbol, InpSignalTimeframe, 1));
   //--- Require the reference low to be old enough to represent a meaningful prior extreme
   bool buyExtremeOldEnough  = (refLowAgeBars >= InpMinExtremeAgeBars);
   //--- Measure how far price swept below the reference low
   double buySweepDepth     = refLowPrice - sweepWindowLow;
   //--- Apply the optional sweep depth filter (absolute points and range percentage)
   bool buyDepthPasses      = (!InpUseSweepDepthFilter)
                              || (buySweepDepth >= InpMinSweepDepthPoints * _Point
                                  && (buySweepDepth / lookbackRange * 100.0) >= InpMinSweepDepthPctRange);
   //--- Trigger a buy trade only when all conditions pass, the signal is not a duplicate, and the position limit allows
   if(buyLowSwept && buyClosedAbove && buyBullishBody && buyExtremeOldEnough && buyDepthPasses
      && g_lastBuySignalTime != signalBarTime
      && CountActivePositions(POSITION_TYPE_BUY) < InpMaxPositionsPerDirection)
     {
      //--- Attempt to open the buy and mark the signal bar as processed on success
      if(OpenTurtleSoupTrade(true, refLowPrice, sweepWindowLow, refHighPrice,
                             lookbackRange, refLowAgeBars, buySweepDepth, signalBarTime))
         g_lastBuySignalTime = signalBarTime;
     }
  }

//+------------------------------------------------------------------+
//| Detect and record the opening of a new signal-timeframe bar      |
//+------------------------------------------------------------------+
bool IsNewSignalBarOpen()
  {
   //--- Read the open time of the current (forming) bar
   datetime currentBarTime = iTime(_Symbol, InpSignalTimeframe, 0);
   //--- Return false if the symbol/timeframe has no data yet
   if(currentBarTime == 0) return false;
   //--- Compare with the last recorded bar time to detect a new bar
   if(currentBarTime != g_lastBarTime)
     {
      //--- Store the new bar time and signal detection
      g_lastBarTime = currentBarTime;
      return true;
     }
   //--- Same bar is still forming
   return false;
  }

//+------------------------------------------------------------------+
//| Advance the trailing stop for all qualifying open positions      |
//+------------------------------------------------------------------+
void ApplyPointsBasedTrailingStop()
  {
   double pointSize = _Point;
   //--- Iterate all open positions in reverse order to allow safe modification
   for(int i = PositionsTotal() - 1; i >= 0; i--)
     {
      //--- Fetch the position ticket at this index
      ulong ticket = PositionGetTicket(i);
      //--- Skip unselectable or invalid tickets
      if(ticket == 0) continue;
      //--- Skip positions that belong to a different symbol or magic number
      if(PositionGetString(POSITION_SYMBOL)    != _Symbol
         || PositionGetInteger(POSITION_MAGIC) != InpMagicNumber) continue;

      //--- Read current SL, TP, and open price for this position
      double currentSL  = PositionGetDouble(POSITION_SL);
      double currentTP  = PositionGetDouble(POSITION_TP);
      double openPrice  = PositionGetDouble(POSITION_PRICE_OPEN);

      if(PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_BUY)
        {
         //--- Read current bid to measure floating profit
         double currentBid    = SymbolInfoDouble(_Symbol, SYMBOL_BID);
         //--- Propose a new SL one trailing distance below the current bid
         double newTrailingSL = NormalizeDouble(currentBid - InpTrailingStopPoints * pointSize, _Digits);
         //--- Move SL upward only if the new level is higher and minimum profit threshold is met
         if(newTrailingSL > currentSL
            && (currentBid - openPrice) > InpMinProfitToActivateTrail * pointSize)
            g_trade.PositionModify(ticket, newTrailingSL, currentTP);
        }
      else if(PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_SELL)
        {
         //--- Read current ask to measure floating profit
         double currentAsk    = SymbolInfoDouble(_Symbol, SYMBOL_ASK);
         //--- Propose a new SL one trailing distance above the current ask
         double newTrailingSL = NormalizeDouble(currentAsk + InpTrailingStopPoints * pointSize, _Digits);
         //--- Move SL downward only if the new level is lower (or SL is zero) and minimum profit threshold is met
         if((newTrailingSL < currentSL || currentSL == 0.0)
            && (openPrice - currentAsk) > InpMinProfitToActivateTrail * pointSize)
            g_trade.PositionModify(ticket, newTrailingSL, currentTP);
        }
     }
  }

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
   //--- Reject initialization if the lookback period is too short to form a range
   if(InpLookbackBars < 2)
     {
      Print("ERROR: InpLookbackBars must be >= 2");
      return(INIT_PARAMETERS_INCORRECT);
     }
   //--- Reject initialization if the sweep window is zero or negative
   if(InpSweepWindowBars < 1)
     {
      Print("ERROR: InpSweepWindowBars must be >= 1");
      return(INIT_PARAMETERS_INCORRECT);
     }
   //--- Reject initialization if the confirmation bar count is zero or negative
   if(InpConfirmCloseBars < 1)
     {
      Print("ERROR: InpConfirmCloseBars must be >= 1");
      return(INIT_PARAMETERS_INCORRECT);
     }
   //--- Reject initialization if RR ratio or lot size would produce invalid orders
   if(InpRiskRewardRatio <= 0.0 || InpLotSize <= 0.0)
     {
      Print("ERROR: InpRiskRewardRatio and InpLotSize must be > 0");
      return(INIT_PARAMETERS_INCORRECT);
     }
   //--- Configure the trade object with the EA's magic number and execution settings
   g_trade.SetExpertMagicNumber(InpMagicNumber);
   g_trade.SetMarginMode();
   g_trade.SetTypeFillingBySymbol(_Symbol);
   return(INIT_SUCCEEDED);
  }

//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   //--- Remove every chart object this EA created using the shared prefix
   ObjectsDeleteAll(ChartID(), OBJ_PREFIX);
   ChartRedraw(ChartID());
  }

//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
   //--- Apply trailing stop logic on every tick when trailing is enabled and positions are open
   if(InpTrailingType == Trail_Points && PositionsTotal() > 0)
      ApplyPointsBasedTrailingStop();
   //--- Execute setup detection logic only once per new signal-timeframe bar
   if(!IsNewSignalBarOpen()) return;
   ScanForTurtleSoupSetups();
  }
//+------------------------------------------------------------------+