//+------------------------------------------------------------------+
//|                                    Breaker Block Strategy EA.mq5 |
//|                           Copyright 2025, Allan Munene Mutiiria. |
//|                                   https://t.me/Forex_Algo_Trader |
//+------------------------------------------------------------------+
#property copyright "Forex Algo-Trader, Allan"
#property link "https://t.me/Forex_Algo_Trader"
#property version "1.00"
#property strict

#include <Trade/Trade.mqh>                         //--- Include Trade library for position management
CTrade obj_Trade;                                  //--- Instantiate trade object for order operations

//+------------------------------------------------------------------+
//| Input Parameters                                                 |
//+------------------------------------------------------------------+
input double tradeLotSize = 0.01;                  // Trade size for each position in lots
input bool   enableTrading = true;                 // Toggle to enable or disable automated trading
input bool   enableTrailingStop = true;            // Toggle to enable or disable trailing stop
input double trailingStopPoints = 30;              // Distance in points for trailing stop adjustment
input double minProfitToTrail = 50;                // Minimum profit in points before trailing starts
input int    uniqueMagicNumber = 12345;            // Unique identifier for EA trades
input int    consolidationBars = 7;                // Number of bars to check for consolidation range
input double maxConsolidationSpread = 50;          // Maximum allowed spread in points for consolidation
input int    barsToWaitAfterBreakout = 3;          // Bars to wait after breakout before impulse check
input double impulseMultiplier = 1.0;              // Multiplier for detecting impulsive price moves
input double stopLossDistance = 1500;              // Stop loss distance in points from entry
input double takeProfitDistance = 1500;            // Take profit distance in points from entry
input double moveAwayDistance = 50;                // Distance in points for price to move away post-invalidation
input color  bullishColor = clrGreen;              // Base color for bullish order/breaker blocks
input color  bearishColor = clrRed;                // Base color for bearish order/breaker blocks
input color  labelTextColor = clrBlack;            // Color for text labels on blocks
input bool   enableSwingValidation = true;         // Enable validation of swing points for block invalidation
input bool   showSwingPoints = true;               // Show swing point labels if validation enabled
input color  swingLabelColor = clrWhite;           // Color for swing point labels
input int    swingFontSize = 10;                   // Font size for swing point labels

//+------------------------------------------------------------------+
//| Structure for price and index                                    |
//+------------------------------------------------------------------+
struct PriceAndIndex {                             //--- Define structure for price and index data
   double price;                                   //--- Store price value (high or low)
   int    index;                                   //--- Store bar index of price
};

//+------------------------------------------------------------------+
//| Global variables for market state tracking                       |
//+------------------------------------------------------------------+
PriceAndIndex rangeHighestHigh = {0, 0};           //--- Track highest high in consolidation range
PriceAndIndex rangeLowestLow = {0, 0};             //--- Track lowest low in consolidation range
bool   isBreakoutDetected = false;                 //--- Flag for breakout detection
double lastImpulseLow = 0.0;                       //--- Store low price after breakout for impulse
double lastImpulseHigh = 0.0;                      //--- Store high price after breakout for impulse
int    breakoutBarNumber = -1;                     //--- Store bar index of breakout
datetime breakoutTimestamp = 0;                    //--- Store timestamp of breakout
string   blockNames[];                             //--- Store names of block objects
datetime blockEndTimes[];                          //--- Store end times of blocks
bool     invalidatedStatus[];                      //--- Track invalidation status of blocks
string   blockTypes[];                             //--- Track block types (OB/BB, bullish/bearish)
bool     movedAwayStatus[];                        //--- Track if price moved away after invalidation
bool     retestedStatus[];                         //--- Track if block was retested
string   blockLabels[];                            //--- Store label object names for blocks
datetime creationTimes[];                          //--- Store creation times of blocks
datetime invalidationTimes[];                      //--- Store invalidation times of blocks
double   invalidationSwings[];                     //--- Store swing high/low at invalidation
bool     isBullishImpulse = false;                 //--- Flag for bullish impulsive move
bool     isBearishImpulse = false;                 //--- Flag for bearish impulsive move
#define OB_Prefix "OB REC "                        //--- Define prefix for order block names

//+------------------------------------------------------------------+
//| Darken color by factor                                           |
//+------------------------------------------------------------------+
color DarkenColor(color colorValue, double factor = 0.8) {
   int red = int((colorValue & 0xFF) * factor);   //--- Extract and darken red component
   int green = int(((colorValue >> 8) & 0xFF) * factor); //--- Extract and darken green component
   int blue = int(((colorValue >> 16) & 0xFF) * factor); //--- Extract and darken blue component
   return (color)(red | (green << 8) | (blue << 16)); //--- Combine components into color
}

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit() {
   obj_Trade.SetExpertMagicNumber(uniqueMagicNumber); //--- Set magic number for trade identification
   return(INIT_SUCCEEDED);                        //--- Return initialization success
}

//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason) {
   ObjectsDeleteAll(0, OB_Prefix);                //--- Remove all objects with OB prefix
   ChartRedraw(0);                                //--- Redraw chart to clear objects
}

//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick() {
   if (enableTrailingStop) {                      //--- Check if trailing stop enabled
      applyTrailingStop(trailingStopPoints, obj_Trade, uniqueMagicNumber); //--- Apply trailing stop
   }
   static bool isNewBar = false;                  //--- Track new bar status
   int currentBarCount = iBars(_Symbol, _Period); //--- Get current bar count
   static int previousBarCount = currentBarCount; //--- Store previous bar count
   if (previousBarCount == currentBarCount) {     //--- Check if no new bar
      isNewBar = false;                           //--- Set no new bar
   } else {                                       //--- New bar detected
      isNewBar = true;                            //--- Set new bar flag
      previousBarCount = currentBarCount;         //--- Update previous bar count
   }
   if (!isNewBar) return;                         //--- Exit if not new bar
   int startBarIndex = 1;                         //--- Set start index for analysis
   int chartScale = (int)ChartGetInteger(0, CHART_SCALE); //--- Get chart zoom scale
   int dynamicFontSize = 8 + (chartScale * 2);    //--- Calculate dynamic font size
   if (!isBreakoutDetected) {                     //--- Check if no breakout detected
      if (rangeHighestHigh.price == 0 && rangeLowestLow.price == 0) { //--- Check if range not set
         bool isConsolidated = true;              //--- Assume consolidation
         for (int i = startBarIndex; i < startBarIndex + consolidationBars - 1; i++) { //--- Iterate consolidation bars
            if (MathAbs(high(i) - high(i + 1)) > maxConsolidationSpread * Point() || MathAbs(low(i) - low(i + 1)) > maxConsolidationSpread * Point()) { //--- Check spread
               isConsolidated = false;            //--- Mark as not consolidated
               break;                             //--- Exit loop
            }
         }
         if (isConsolidated) {                    //--- Confirm consolidation
            rangeHighestHigh.price = high(startBarIndex); //--- Set initial high
            rangeHighestHigh.index = startBarIndex; //--- Set high index
            for (int i = startBarIndex + 1; i < startBarIndex + consolidationBars; i++) { //--- Find highest high
               if (high(i) > rangeHighestHigh.price) { //--- Check higher high
                  rangeHighestHigh.price = high(i); //--- Update highest high
                  rangeHighestHigh.index = i;    //--- Update high index
               }
            }
            rangeLowestLow.price = low(startBarIndex); //--- Set initial low
            rangeLowestLow.index = startBarIndex; //--- Set low index
            for (int i = startBarIndex + 1; i < startBarIndex + consolidationBars; i++) { //--- Find lowest low
               if (low(i) < rangeLowestLow.price) { //--- Check lower low
                  rangeLowestLow.price = low(i); //--- Update lowest low
                  rangeLowestLow.index = i;      //--- Update low index
               }
            }
            Print("Consolidation range established: Highest High = ", rangeHighestHigh.price, " at index ", rangeHighestHigh.index, " and Lowest Low = ", rangeLowestLow.price, " at index ", rangeLowestLow.index); //--- Log range
         }
      } else {                                    //--- Range already set
         double currentHigh = high(1);            //--- Get current high
         double currentLow = low(1);              //--- Get current low
         if (currentHigh <= rangeHighestHigh.price && currentLow >= rangeLowestLow.price) { //--- Check within range
            Print("Range extended: High = ", currentHigh, ", Low = ", currentLow); //--- Log range extension
         } else {                                 //--- Outside range
            Print("No extension: Bar outside range."); //--- Log no extension
         }
      }
   }
   if (rangeHighestHigh.price > 0 && rangeLowestLow.price > 0) { //--- Check if range defined
      double currentClosePrice = close(1);        //--- Get current close price
      if (currentClosePrice > rangeHighestHigh.price) { //--- Check upward breakout
         Print("Upward breakout at ", currentClosePrice, " > ", rangeHighestHigh.price); //--- Log breakout
         isBreakoutDetected = true;               //--- Set breakout flag
      } else if (currentClosePrice < rangeLowestLow.price) { //--- Check downward breakout
         Print("Downward breakout at ", currentClosePrice, " < ", rangeLowestLow.price); //--- Log breakout
         isBreakoutDetected = true;               //--- Set breakout flag
      }
   }
   if (isBreakoutDetected) {                      //--- Process breakout
      Print("Breakout detected. Resetting for the next range."); //--- Log reset
      breakoutBarNumber = 1;                      //--- Set breakout bar index
      breakoutTimestamp = TimeCurrent();          //--- Set breakout timestamp
      lastImpulseHigh = rangeHighestHigh.price;   //--- Store high for impulse check
      lastImpulseLow = rangeLowestLow.price;      //--- Store low for impulse check
      isBreakoutDetected = false;                 //--- Reset breakout flag
      rangeHighestHigh.price = 0;                 //--- Clear highest high
      rangeHighestHigh.index = 0;                 //--- Clear high index
      rangeLowestLow.price = 0;                   //--- Clear lowest low
      rangeLowestLow.index = 0;                   //--- Clear low index
   }
   if (breakoutBarNumber >= 0 && TimeCurrent() > breakoutTimestamp + barsToWaitAfterBreakout * PeriodSeconds()) { //--- Check impulse window
      double impulseRange = lastImpulseHigh - lastImpulseLow; //--- Calculate impulse range
      double impulseThresholdPrice = impulseRange * impulseMultiplier; //--- Calculate impulse threshold
      isBullishImpulse = false;                   //--- Reset bullish impulse flag
      isBearishImpulse = false;                   //--- Reset bearish impulse flag
      for (int i = 1; i <= barsToWaitAfterBreakout; i++) { //--- Check bars for impulse
         double closePrice = close(i);            //--- Get close price
         if (closePrice >= lastImpulseHigh + impulseThresholdPrice) { //--- Check bullish impulse
            isBullishImpulse = true;              //--- Set bullish impulse flag
            Print("Impulsive upward move: ", closePrice, " >= ", lastImpulseHigh + impulseThresholdPrice); //--- Log bullish impulse
            break;                                //--- Exit loop
         } else if (closePrice <= lastImpulseLow - impulseThresholdPrice) { //--- Check bearish impulse
            isBearishImpulse = true;              //--- Set bearish impulse flag
            Print("Impulsive downward move: ", closePrice, " <= ", lastImpulseLow - impulseThresholdPrice); //--- Log bearish impulse
            break;                                //--- Exit loop
         }
      }
      if (!isBullishImpulse && !isBearishImpulse) { //--- Check no impulse
         Print("No impulsive movement detected."); //--- Log no impulse
      }
      bool isOrderBlockValid = isBearishImpulse || isBullishImpulse; //--- Validate order block
      if (isOrderBlockValid) {                    //--- Process valid order block
         datetime blockStartTime = iTime(_Symbol, _Period, consolidationBars + barsToWaitAfterBreakout + 1); //--- Set block start time
         double blockTopPrice = lastImpulseHigh;  //--- Set block top price
         int visibleBarsOnChart = (int)ChartGetInteger(0, CHART_VISIBLE_BARS); //--- Get visible bars
         datetime blockEndTime = blockStartTime + (visibleBarsOnChart / 1) * PeriodSeconds(); //--- Set block end time
         double blockBottomPrice = lastImpulseLow; //--- Set block bottom price
         string blockName = OB_Prefix + "(" + TimeToString(blockStartTime) + ")"; //--- Generate block name
         color blockColor = isBullishImpulse ? bullishColor : bearishColor; //--- Set block color
         string blockLabel = isBullishImpulse ? "Bullish Order Block" : "Bearish Order Block"; //--- Set block label
         string blockType = isBullishImpulse ? "OB-bullish" : "OB-bearish"; //--- Set block type
         if (ObjectFind(0, blockName) < 0) {      //--- Check if block exists
            ObjectCreate(0, blockName, OBJ_RECTANGLE, 0, blockStartTime, blockTopPrice, blockEndTime, blockBottomPrice); //--- Create block rectangle
            ObjectSetInteger(0, blockName, OBJPROP_TIME, 0, blockStartTime); //--- Set start time
            ObjectSetDouble(0, blockName, OBJPROP_PRICE, 0, blockTopPrice); //--- Set top price
            ObjectSetInteger(0, blockName, OBJPROP_TIME, 1, blockEndTime); //--- Set end time
            ObjectSetDouble(0, blockName, OBJPROP_PRICE, 1, blockBottomPrice); //--- Set bottom price
            ObjectSetInteger(0, blockName, OBJPROP_FILL, true); //--- Enable fill
            ObjectSetInteger(0, blockName, OBJPROP_COLOR, blockColor); //--- Set block color
            ObjectSetInteger(0, blockName, OBJPROP_BACK, false); //--- Set to foreground
            datetime labelTime = blockStartTime + (blockEndTime - blockStartTime) / 2; //--- Calculate label time
            double labelPrice = (blockTopPrice + blockBottomPrice) / 2; //--- Calculate label price
            string labelObjectName = blockName + " Label"; //--- Generate label name
            ObjectCreate(0, labelObjectName, OBJ_TEXT, 0, labelTime, labelPrice); //--- Create label
            ObjectSetString(0, labelObjectName, OBJPROP_TEXT, blockLabel); //--- Set label text
            ObjectSetInteger(0, labelObjectName, OBJPROP_COLOR, labelTextColor); //--- Set label color
            ObjectSetInteger(0, labelObjectName, OBJPROP_FONTSIZE, dynamicFontSize); //--- Set label font size
            ObjectSetInteger(0, labelObjectName, OBJPROP_ANCHOR, ANCHOR_CENTER); //--- Set label anchor
            ChartRedraw(0);                       //--- Redraw chart
            ArrayResize(blockNames, ArraySize(blockNames) + 1); //--- Resize block names array
            blockNames[ArraySize(blockNames) - 1] = blockName; //--- Add block name
            ArrayResize(blockEndTimes, ArraySize(blockEndTimes) + 1); //--- Resize end times array
            blockEndTimes[ArraySize(blockEndTimes) - 1] = blockEndTime; //--- Add end time
            ArrayResize(invalidatedStatus, ArraySize(invalidatedStatus) + 1); //--- Resize invalidated status
            invalidatedStatus[ArraySize(invalidatedStatus) - 1] = false; //--- Set invalidated status
            ArrayResize(blockTypes, ArraySize(blockTypes) + 1); //--- Resize block types array
            blockTypes[ArraySize(blockTypes) - 1] = blockType; //--- Add block type
            ArrayResize(movedAwayStatus, ArraySize(movedAwayStatus) + 1); //--- Resize moved away status
            movedAwayStatus[ArraySize(movedAwayStatus) - 1] = false; //--- Set moved away status
            ArrayResize(retestedStatus, ArraySize(retestedStatus) + 1); //--- Resize retested status
            retestedStatus[ArraySize(retestedStatus) - 1] = false; //--- Set retested status
            ArrayResize(blockLabels, ArraySize(blockLabels) + 1); //--- Resize block labels array
            blockLabels[ArraySize(blockLabels) - 1] = labelObjectName; //--- Add label name
            ArrayResize(creationTimes, ArraySize(creationTimes) + 1); //--- Resize creation times
            creationTimes[ArraySize(creationTimes) - 1] = time(1); //--- Set creation time
            ArrayResize(invalidationTimes, ArraySize(invalidationTimes) + 1); //--- Resize invalidation times
            invalidationTimes[ArraySize(invalidationTimes) - 1] = 0; //--- Set invalidation time
            ArrayResize(invalidationSwings, ArraySize(invalidationSwings) + 1); //--- Resize invalidation swings
            invalidationSwings[ArraySize(invalidationSwings) - 1] = 0.0; //--- Set invalidation swing
            Print("Order Block created: ", blockName); //--- Log block creation
         }
      }
      breakoutBarNumber = -1;                     //--- Reset breakout bar
      breakoutTimestamp = 0;                      //--- Reset breakout timestamp
      lastImpulseHigh = 0;                        //--- Reset impulse high
      lastImpulseLow = 0;                         //--- Reset impulse low
      isBullishImpulse = false;                   //--- Reset bullish impulse
      isBearishImpulse = false;                   //--- Reset bearish impulse
   }
   for (int j = ArraySize(blockNames) - 1; j >= 0; j--) { //--- Iterate through blocks
      string currentBlockName = blockNames[j];    //--- Get current block name
      bool doesBlockExist = false;                //--- Initialize block existence flag
      double blockHigh = ObjectGetDouble(0, currentBlockName, OBJPROP_PRICE, 0); //--- Get block high
      double blockLow = ObjectGetDouble(0, currentBlockName, OBJPROP_PRICE, 1); //--- Get block low
      datetime blockStartTime = (datetime)ObjectGetInteger(0, currentBlockName, OBJPROP_TIME, 0); //--- Get block start
      datetime blockEndTime = (datetime)ObjectGetInteger(0, currentBlockName, OBJPROP_TIME, 1); //--- Get block end
      color blockCurrentColor = (color)ObjectGetInteger(0, currentBlockName, OBJPROP_COLOR); //--- Get block color
      if (time(1) < blockEndTime) {               //--- Check if block still valid
         doesBlockExist = true;                   //--- Set block exists
      }
      if (StringFind(blockTypes[j], "OB-") == 0 && !invalidatedStatus[j]) { //--- Check valid order block
         bool invalidated = false;                 //--- Initialize invalidation flag
         string newBlockType = "";                //--- Initialize new block type
         color invalidatedColor = clrNONE;         //--- Initialize invalidated color
         string newLabel = "";                    //--- Initialize new label
         bool isForBullishBB = false;             //--- Initialize bullish breaker block flag
         double breakPrice = 0.0;                 //--- Initialize break price
         int arrowCode = 0;                       //--- Initialize arrow code
         int anchor = 0;                          //--- Initialize anchor
         if (blockTypes[j] == "OB-bearish" && close(1) > blockHigh) { //--- Check bearish block invalidation
            isForBullishBB = true;                //--- Set bullish breaker block
            breakPrice = blockHigh;               //--- Set break price
            arrowCode = 233;                      //--- Set upward arrow
            anchor = ANCHOR_BOTTOM;               //--- Set bottom anchor
            newBlockType = "Invalidated-bearish"; //--- Set invalidated type
            invalidatedColor = DarkenColor(bearishColor); //--- Darken bearish color
            newLabel = "Invalidated Bearish Order Block"; //--- Set invalidated label
         } else if (blockTypes[j] == "OB-bullish" && close(1) < blockLow) { //--- Check bullish block invalidation
            isForBullishBB = false;               //--- Set bearish breaker block
            breakPrice = blockLow;                //--- Set break price
            arrowCode = 234;                      //--- Set downward arrow
            anchor = ANCHOR_TOP;                  //--- Set top anchor
            newBlockType = "Invalidated-bullish"; //--- Set invalidated type
            invalidatedColor = DarkenColor(bullishColor); //--- Darken bullish color
            newLabel = "Invalidated Bullish Order Block"; //--- Set invalidated label
         } else {                                 //--- No invalidation
            continue;                             //--- Skip to next block
         }
         bool validSwingForInvalidation = true;   //--- Assume valid swing
         int swingShift = -1;                     //--- Initialize swing shift
         double swingPrice = 0.0;                 //--- Initialize swing price
         if (enableSwingValidation) {             //--- Check swing validation
            int creationShift = iBarShift(_Symbol, _Period, creationTimes[j], false); //--- Get creation bar shift
            if (creationShift > 1) {              //--- Ensure enough bars
               double extreme = isForBullishBB ? blockLow : blockHigh; //--- Set extreme price
               bool isBearishOB = isForBullishBB; //--- Set bearish OB flag
               if (isBearishOB) {                 //--- Handle bearish OB
                  double minLow = extreme;        //--- Initialize minimum low
                  for (int k = creationShift - 1; k > 1; k--) { //--- Find lower low
                     if (low(k) < minLow) {       //--- Check lower low
                        minLow = low(k);          //--- Update minimum low
                        swingShift = k;           //--- Update swing shift
                     }
                  }
                  validSwingForInvalidation = minLow < extreme; //--- Validate swing
                  swingPrice = minLow;            //--- Set swing price
               } else {                           //--- Handle bullish OB
                  double maxHigh = extreme;       //--- Initialize maximum high
                  for (int k = creationShift - 1; k > 1; k--) { //--- Find higher high
                     if (high(k) > maxHigh) {     //--- Check higher high
                        maxHigh = high(k);        //--- Update maximum high
                        swingShift = k;           //--- Update swing shift
                     }
                  }
                  validSwingForInvalidation = maxHigh > extreme; //--- Validate swing
                  swingPrice = maxHigh;           //--- Set swing price
               }
            } else {                              //--- Insufficient bars
               validSwingForInvalidation = false; //--- Invalidate swing
            }
         }
         if (validSwingForInvalidation) {        //--- Confirm swing validation
            invalidated = true;                  //--- Set invalidated flag
         }
         if (invalidated) {                      //--- Process invalidation
            ObjectSetInteger(0, currentBlockName, OBJPROP_COLOR, invalidatedColor); //--- Update block color
            ObjectDelete(0, blockLabels[j]);     //--- Delete old label
            datetime labelTime = blockStartTime + (blockEndTime - blockStartTime) / 2; //--- Calculate new label time
            double labelPrice = (blockHigh + blockLow) / 2; //--- Calculate new label price
            string newLabelObjectName = currentBlockName + " Label"; //--- Generate new label name
            ObjectCreate(0, newLabelObjectName, OBJ_TEXT, 0, labelTime, labelPrice); //--- Create new label
            ObjectSetString(0, newLabelObjectName, OBJPROP_TEXT, newLabel); //--- Set label text
            ObjectSetInteger(0, newLabelObjectName, OBJPROP_COLOR, labelTextColor); //--- Set label color
            ObjectSetInteger(0, newLabelObjectName, OBJPROP_FONTSIZE, dynamicFontSize); //--- Set label font size
            ObjectSetInteger(0, newLabelObjectName, OBJPROP_ANCHOR, ANCHOR_CENTER); //--- Set label anchor
            string arrowName = currentBlockName + "_break_arrow"; //--- Generate arrow name
            if (ObjectFind(0, arrowName) < 0) {  //--- Check if arrow exists
               ObjectCreate(0, arrowName, OBJ_ARROW, 0, time(1), breakPrice); //--- Create break arrow
               ObjectSetInteger(0, arrowName, OBJPROP_ARROWCODE, arrowCode); //--- Set arrow code
               ObjectSetInteger(0, arrowName, OBJPROP_ANCHOR, anchor); //--- Set arrow anchor
               ObjectSetInteger(0, arrowName, OBJPROP_COLOR, invalidatedColor); //--- Set arrow color
            }
            if (enableSwingValidation && showSwingPoints && swingShift > 0) { //--- Check swing point display
               string swingLabelName = currentBlockName + "_invalid_swing"; //--- Generate swing label name
               if (ObjectFind(0, swingLabelName) < 0) { //--- Check if swing label exists
                  datetime swingTime = time(swingShift); //--- Get swing time
                  ObjectCreate(0, swingLabelName, OBJ_TEXT, 0, swingTime, swingPrice); //--- Create swing label
                  string swingText = isForBullishBB ? "LL" : "HH"; //--- Set swing text
                  ObjectSetString(0, swingLabelName, OBJPROP_TEXT, swingText); //--- Set swing label text
                  ObjectSetInteger(0, swingLabelName, OBJPROP_COLOR, swingLabelColor); //--- Set swing label color
                  ObjectSetInteger(0, swingLabelName, OBJPROP_FONTSIZE, swingFontSize); //--- Set swing label font size
                  ObjectSetInteger(0, swingLabelName, OBJPROP_ANCHOR, isForBullishBB ? ANCHOR_LEFT_UPPER : ANCHOR_LEFT_LOWER); //--- Set swing label anchor
               }
            }
            ChartRedraw(0);                       //--- Redraw chart
            invalidatedStatus[j] = true;          //--- Set invalidated status
            blockTypes[j] = newBlockType;         //--- Update block type
            movedAwayStatus[j] = false;           //--- Reset moved away status
            retestedStatus[j] = false;            //--- Reset retested status
            blockLabels[j] = newLabelObjectName;  //--- Update label name
            invalidationTimes[j] = time(1);       //--- Set invalidation time
            invalidationSwings[j] = isForBullishBB ? high(1) : low(1); //--- Set invalidation swing
            Print("Order Block invalidated: ", currentBlockName); //--- Log invalidation
         }
      }
      if (!doesBlockExist) {                     //--- Check if block expired
         ArrayRemove(blockNames, j, 1);          //--- Remove block name
         ArrayRemove(blockEndTimes, j, 1);       //--- Remove end time
         ArrayRemove(invalidatedStatus, j, 1);   //--- Remove invalidated status
         ArrayRemove(blockTypes, j, 1);          //--- Remove block type
         ArrayRemove(movedAwayStatus, j, 1);     //--- Remove moved away status
         ArrayRemove(retestedStatus, j, 1);      //--- Remove retested status
         ArrayRemove(blockLabels, j, 1);         //--- Remove label name
         ArrayRemove(creationTimes, j, 1);       //--- Remove creation time
         ArrayRemove(invalidationTimes, j, 1);   //--- Remove invalidation time
         ArrayRemove(invalidationSwings, j, 1);  //--- Remove invalidation swing
         Print("Removed expired block at index ", j); //--- Log block removal
      }
   }
   for (int j = ArraySize(blockNames) - 1; j >= 0; j--) { //--- Iterate invalidated blocks
      if (StringFind(blockTypes[j], "Invalidated-") != 0) continue; //--- Skip non-invalidated
      string currentBlockName = blockNames[j];    //--- Get current block name
      double blockHigh = ObjectGetDouble(0, currentBlockName, OBJPROP_PRICE, 0); //--- Get block high
      double blockLow = ObjectGetDouble(0, currentBlockName, OBJPROP_PRICE, 1); //--- Get block low
      datetime blockStartTime = (datetime)ObjectGetInteger(0, currentBlockName, OBJPROP_TIME, 0); //--- Get block start
      datetime blockEndTime = (datetime)ObjectGetInteger(0, currentBlockName, OBJPROP_TIME, 1); //--- Get block end
      bool isForBullishBB = (blockTypes[j] == "Invalidated-bearish"); //--- Check for bullish breaker block
      datetime currentBarTime = time(1);          //--- Get current bar time
      if (currentBarTime <= invalidationTimes[j]) continue; //--- Skip if same or earlier bar
      if (!movedAwayStatus[j]) {                  //--- Check if not moved away
         if (isForBullishBB && close(1) > blockHigh + moveAwayDistance * _Point) { //--- Check bullish move away
            movedAwayStatus[j] = true;           //--- Set moved away
            Print("Moved away for bullish BB setup: ", currentBlockName); //--- Log move away
         } else if (!isForBullishBB && close(1) < blockLow - moveAwayDistance * _Point) { //--- Check bearish move away
            movedAwayStatus[j] = true;           //--- Set moved away
            Print("Moved away for bearish BB setup: ", currentBlockName); //--- Log move away
         }
      }
      if (movedAwayStatus[j] && !retestedStatus[j]) { //--- Check for retest
         bool retestCondition = false;            //--- Initialize retest condition
         if (isForBullishBB && low(1) <= blockHigh && close(1) > blockHigh) { //--- Check bullish retest
            retestCondition = true;               //--- Set retest condition
         } else if (!isForBullishBB && high(1) >= blockLow && close(1) < blockLow) { //--- Check bearish retest
            retestCondition = true;               //--- Set retest condition
         }
         bool validSwingForRetest = true;         //--- Assume valid swing
         int swingShift = -1;                     //--- Initialize swing shift
         double swingPrice = 0.0;                 //--- Initialize swing price
         if (enableSwingValidation && retestCondition) { //--- Check swing validation
            int invalidShift = iBarShift(_Symbol, _Period, invalidationTimes[j], false); //--- Get invalidation shift
            if (invalidShift > 1) {               //--- Ensure enough bars
               double extreme = invalidationSwings[j]; //--- Get invalidation swing
               if (isForBullishBB) {              //--- Handle bullish breaker block
                  double maxHigh = extreme;       //--- Initialize maximum high
                  for (int k = invalidShift - 1; k > 1; k--) { //--- Find higher high
                     if (high(k) > maxHigh) {     //--- Check higher high
                        maxHigh = high(k);        //--- Update maximum high
                        swingShift = k;           //--- Update swing shift
                     }
                  }
                  validSwingForRetest = maxHigh > extreme; //--- Validate swing
                  swingPrice = maxHigh;           //--- Set swing price
               } else {                           //--- Handle bearish breaker block
                  double minLow = extreme;        //--- Initialize minimum low
                  for (int k = invalidShift - 1; k > 1; k--) { //--- Find lower low
                     if (low(k) < minLow) {       //--- Check lower low
                        minLow = low(k);          //--- Update minimum low
                        swingShift = k;           //--- Update swing shift
                     }
                  }
                  validSwingForRetest = minLow < extreme; //--- Validate swing
                  swingPrice = minLow;            //--- Set swing price
               }
            } else {                              //--- Insufficient bars
               validSwingForRetest = false;      //--- Invalidate swing
            }
         }
         if (retestCondition && validSwingForRetest) { //--- Confirm retest and swing
            if (enableTrading) {                  //--- Check trading enabled
               double entryPrice = 0.0;           //--- Initialize entry price
               double stopLossPrice = 0.0;        //--- Initialize stop loss
               double takeProfitPrice = 0.0;      //--- Initialize take profit
               if (isForBullishBB) {              //--- Handle bullish trade
                  entryPrice = NormalizeDouble(SymbolInfoDouble(_Symbol, SYMBOL_ASK), _Digits); //--- Set entry at ask
                  stopLossPrice = entryPrice - stopLossDistance * _Point; //--- Set stop loss
                  takeProfitPrice = entryPrice + takeProfitDistance * _Point; //--- Set take profit
                  obj_Trade.Buy(tradeLotSize, _Symbol, entryPrice, stopLossPrice, takeProfitPrice); //--- Execute buy trade
                  Print("Buy trade on bullish BB retest: ", currentBlockName); //--- Log buy trade
               } else {                           //--- Handle bearish trade
                  entryPrice = NormalizeDouble(SymbolInfoDouble(_Symbol, SYMBOL_BID), _Digits); //--- Set entry at bid
                  stopLossPrice = entryPrice + stopLossDistance * _Point; //--- Set stop loss
                  takeProfitPrice = entryPrice - takeProfitDistance * _Point; //--- Set take profit
                  obj_Trade.Sell(tradeLotSize, _Symbol, entryPrice, stopLossPrice, takeProfitPrice); //--- Execute sell trade
                  Print("Sell trade on bearish BB retest: ", currentBlockName); //--- Log sell trade
               }
            }
            color bbColor = isForBullishBB ? clrBlueViolet : clrOrange; //--- Set breaker block color
            ObjectSetInteger(0, currentBlockName, OBJPROP_COLOR, bbColor); //--- Update block color
            ObjectDelete(0, blockLabels[j]);     //--- Delete old label
            string newLabel = isForBullishBB ? "Bullish Breaker Block" : "Bearish Breaker Block"; //--- Set new label
            datetime labelTime = blockStartTime + (blockEndTime - blockStartTime) / 2; //--- Calculate label time
            double labelPrice = (blockHigh + blockLow) / 2; //--- Calculate label price
            string newLabelObjectName = currentBlockName + " Label"; //--- Generate new label name
            ObjectCreate(0, newLabelObjectName, OBJ_TEXT, 0, labelTime, labelPrice); //--- Create new label
            ObjectSetString(0, newLabelObjectName, OBJPROP_TEXT, newLabel); //--- Set label text
            ObjectSetInteger(0, newLabelObjectName, OBJPROP_COLOR, labelTextColor); //--- Set label color
            ObjectSetInteger(0, newLabelObjectName, OBJPROP_FONTSIZE, dynamicFontSize); //--- Set label font size
            ObjectSetInteger(0, newLabelObjectName, OBJPROP_ANCHOR, ANCHOR_CENTER); //--- Set label anchor
            if (enableSwingValidation && showSwingPoints && swingShift > 0) { //--- Check swing point display
               string swingLabelName = currentBlockName + "_retest_swing"; //--- Generate swing label name
               if (ObjectFind(0, swingLabelName) < 0) { //--- Check if swing label exists
                  datetime swingTime = time(swingShift); //--- Get swing time
                  ObjectCreate(0, swingLabelName, OBJ_TEXT, 0, swingTime, swingPrice); //--- Create swing label
                  string swingText = isForBullishBB ? "HH" : "LL"; //--- Set swing text
                  ObjectSetString(0, swingLabelName, OBJPROP_TEXT, swingText); //--- Set swing label text
                  ObjectSetInteger(0, swingLabelName, OBJPROP_COLOR, swingLabelColor); //--- Set swing label color
                  ObjectSetInteger(0, swingLabelName, OBJPROP_FONTSIZE, swingFontSize); //--- Set swing label font size
                  ObjectSetInteger(0, swingLabelName, OBJPROP_ANCHOR, isForBullishBB ? ANCHOR_LEFT_LOWER : ANCHOR_LEFT_UPPER); //--- Set swing label anchor
               }
            }
            ChartRedraw(0);                       //--- Redraw chart
            blockTypes[j] = isForBullishBB ? "BB-bullish" : "BB-bearish"; //--- Update block type
            retestedStatus[j] = true;             //--- Set retested status
            blockLabels[j] = newLabelObjectName;  //--- Update label name
            Print("Converted to ", newLabel, ": ", currentBlockName); //--- Log conversion
         }
      }
   }
}

//+------------------------------------------------------------------+
//| Price data accessors                                            |
//+------------------------------------------------------------------+
double high(int index) {
   return iHigh(_Symbol, _Period, index);         //--- Return high price for specified index
}
double low(int index) {
   return iLow(_Symbol, _Period, index);          //--- Return low price for specified index
}
double close(int index) {
   return iClose(_Symbol, _Period, index);        //--- Return close price for specified index
}
datetime time(int index) {
   return iTime(_Symbol, _Period, index);         //--- Return time for specified index
}

//+------------------------------------------------------------------+
//| Apply trailing stop to open positions                            |
//+------------------------------------------------------------------+
void applyTrailingStop(double trailingPoints, CTrade &trade_object, int magicNo = 0) {
   double buyStopLoss = NormalizeDouble(SymbolInfoDouble(_Symbol, SYMBOL_BID) - trailingPoints * _Point, _Digits); //--- Calculate buy stop loss
   double sellStopLoss = NormalizeDouble(SymbolInfoDouble(_Symbol, SYMBOL_ASK) + trailingPoints * _Point, _Digits); //--- Calculate sell stop loss
   for (int i = PositionsTotal() - 1; i >= 0; i--) { //--- Iterate through open positions
      ulong ticket = PositionGetTicket(i);         //--- Get position ticket
      if (ticket > 0 && PositionGetString(POSITION_SYMBOL) == _Symbol && (magicNo == 0 || PositionGetInteger(POSITION_MAGIC) == magicNo)) { //--- Verify position
         if (PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_BUY && buyStopLoss > PositionGetDouble(POSITION_PRICE_OPEN) && (buyStopLoss > PositionGetDouble(POSITION_SL) || PositionGetDouble(POSITION_SL) == 0)) { //--- Check buy trailing
            trade_object.PositionModify(ticket, buyStopLoss, PositionGetDouble(POSITION_TP)); //--- Update buy stop loss
         } else if (PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_SELL && sellStopLoss < PositionGetDouble(POSITION_PRICE_OPEN) && (sellStopLoss < PositionGetDouble(POSITION_SL) || PositionGetDouble(POSITION_SL) == 0)) { //--- Check sell trailing
            trade_object.PositionModify(ticket, sellStopLoss, PositionGetDouble(POSITION_TP)); //--- Update sell stop loss
         }
      }
   }
}

//+------------------------------------------------------------------+