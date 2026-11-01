//+------------------------------------------------------------------+
//|                                         Supply and Demand EA.mq5 |
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
//| Enum for trading tested zones                                    |
//+------------------------------------------------------------------+
enum TradeTestedZonesMode {                        // Define modes for trading tested zones
   NoRetrade,                                      // Trade zones only once
   LimitedRetrade,                                 // Trade zones up to a maximum number of times
   UnlimitedRetrade                                // Trade zones as long as they are valid
};

//+------------------------------------------------------------------+
//| Enum for broken zones validation                                 |
//+------------------------------------------------------------------+
enum BrokenZonesMode {                             // Define modes for broken zones validation
   AllowBroken,                                    // Zones can be marked as broken
   NoBroken                                        // Zones remain testable regardless of price break
};

//+------------------------------------------------------------------+
//| Enum for zone size restriction                                   |
//+------------------------------------------------------------------+
enum ZoneSizeMode {                                // Define modes for zone size restrictions
   NoRestriction,                                  // No restriction on zone size
   EnforceLimits                                   // Enforce minimum and maximum zone points
};

//+------------------------------------------------------------------+
//| Enum for trend confirmation                                      |
//+------------------------------------------------------------------+
enum TrendConfirmationMode {                       // Define modes for trend confirmation
   NoConfirmation,                                 // No trend confirmation required
   ConfirmTrend                                    // Confirm trend before trading on tap
};

//+------------------------------------------------------------------+
//| Input Parameters                                                 |
//+------------------------------------------------------------------+
input double tradeLotSize = 0.01;                  // Trade size in lots
input bool   enableTrading = true;                 // Enable automated trading
input bool   enableTrailingStop = true;            // Enable trailing stop
input double trailingStopPoints = 30;              // Trailing stop points
input double minProfitToTrail = 50;                // Minimum trailing points
input int    uniqueMagicNumber = 12345;            // Magic Number
input int    consolidationBars = 5;                // Consolidation range bars
input double maxConsolidationSpread = 30;          // Maximum allowed spread in points for consolidation
input double stopLossDistance = 200;               // Stop loss in points
input double takeProfitDistance = 400;             // Take profit in points
input double minMoveAwayPoints = 50;               // Minimum points price must move away before zone is ready
input bool   deleteBrokenZonesFromChart = false;   // Delete broken zones from chart
input bool   deleteExpiredZonesFromChart = false;  // Delete expired zones from chart
input int    zoneExtensionBars = 150;              // Number of bars to extend zones to the right
input bool   enableImpulseValidation = true;       // Enable impulse move validation
input int    impulseCheckBars = 3;                 // Number of bars to check for impulsive move
input double impulseMultiplier = 1.0;              // Multiplier for impulsive threshold
input TradeTestedZonesMode tradeTestedMode = NoRetrade; // Mode for trading tested zones
input int    maxTradesPerZone = 2;                 // Maximum trades per zone for LimitedRetrade
input BrokenZonesMode brokenZoneMode = AllowBroken; // Mode for broken zones validation
input color  demandZoneColor = clrBlue;            // Color for untested demand zones
input color  supplyZoneColor = clrRed;             // Color for untested supply zones
input color  testedDemandZoneColor = clrBlueViolet; // Color for tested demand zones
input color  testedSupplyZoneColor = clrOrange;    // Color for tested supply zones
input color  brokenZoneColor = clrDarkGray;        // Color for broken zones
input color  labelTextColor = clrBlack;            // Color for text labels
input ZoneSizeMode zoneSizeRestriction = NoRestriction; // Zone size restriction mode
input double minZonePoints = 50;                   // Minimum zone size in points
input double maxZonePoints = 300;                  // Maximum zone size in points
input TrendConfirmationMode trendConfirmation = NoConfirmation; // Trend confirmation mode
input int    trendLookbackBars = 10;               // Number of bars for trend confirmation
input double minTrendPoints = 1;                   // Minimum points for trend confirmation

//+------------------------------------------------------------------+
//| Structure for zone information                                  |
//+------------------------------------------------------------------+
struct SDZone {                                    //--- Define structure for supply/demand zones
   double   high;                                  //--- Store zone high price
   double   low;                                   //--- Store zone low price
   datetime startTime;                             //--- Store zone start time
   datetime endTime;                               //--- Store zone end time
   datetime breakoutTime;                          //--- Store breakout time
   bool     isDemand;                              //--- Indicate demand (true) or supply (false)
   bool     tested;                                //--- Track if zone was tested
   bool     broken;                                //--- Track if zone was broken
   bool     readyForTest;                          //--- Track if zone is ready for testing
   int      tradeCount;                            //--- Track number of trades on zone
   string   name;                                  //--- Store zone object name
};

//+------------------------------------------------------------------+
//| Global variables                                                 |
//+------------------------------------------------------------------+
SDZone zones[];                                    //--- Store active supply/demand zones
SDZone potentialZones[];                           //--- Store potential zones awaiting validation
int    maxZones = 50;                              //--- Set maximum number of zones to track

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
   ObjectsDeleteAll(0, "SDZone_");                //--- Remove all zone objects from chart
   ChartRedraw(0);                                //--- Redraw chart to clear objects
}

//+------------------------------------------------------------------+
//| Print zones for debugging                                        |
//+------------------------------------------------------------------+
void PrintZones(SDZone &arr[]) {
   Print("Current zones count: ", ArraySize(arr)); //--- Log total number of zones
   for (int i = 0; i < ArraySize(arr); i++) {     //--- Iterate through zones
      Print("Zone ", i, ": ", arr[i].name, " endTime: ", TimeToString(arr[i].endTime)); //--- Log zone details
   }
}

//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick() {
   if (enableTrailingStop) {                      //--- Check if trailing stop enabled
      ApplyTrailingStop();                        //--- Apply trailing stop to positions
   }
   static datetime lastBarTime = 0;               //--- Store last processed bar time
   datetime currentBarTime = iTime(_Symbol, _Period, 0); //--- Get current bar time
   bool isNewBar = (currentBarTime != lastBarTime); //--- Check for new bar
   if (isNewBar) {                                //--- Process new bar
      lastBarTime = currentBarTime;               //--- Update last bar time
      DetectZones();                              //--- Detect new zones
      ValidatePotentialZones();                   //--- Validate potential zones
      UpdateZones();                              //--- Update existing zones
   }
   if (enableTrading) {                           //--- Check if trading enabled
      TradeOnZones(isNewBar);                    //--- Execute trades on zones
   }
}

//+------------------------------------------------------------------+
//| Detect supply and demand zones                                   |
//+------------------------------------------------------------------+
void DetectZones() {
   int startIndex = consolidationBars + 1;        //--- Set start index for consolidation check
   if (iBars(_Symbol, _Period) < startIndex + 1) return; //--- Exit if insufficient bars
   bool isConsolidated = true;                    //--- Assume consolidation
   double highPrice = iHigh(_Symbol, _Period, startIndex); //--- Initialize high price
   double lowPrice = iLow(_Symbol, _Period, startIndex); //--- Initialize low price
   for (int i = startIndex - 1; i >= 2; i--) {   //--- Iterate through consolidation bars
      highPrice = MathMax(highPrice, iHigh(_Symbol, _Period, i)); //--- Update highest high
      lowPrice = MathMin(lowPrice, iLow(_Symbol, _Period, i)); //--- Update lowest low
      if (highPrice - lowPrice > maxConsolidationSpread * _Point) { //--- Check spread limit
         isConsolidated = false;                  //--- Mark as not consolidated
         break;                                   //--- Exit loop
      }
   }
   if (isConsolidated) {                          //--- Confirm consolidation
      double closePrice = iClose(_Symbol, _Period, 1); //--- Get last closed bar price
      double breakoutLow = iLow(_Symbol, _Period, 1); //--- Get breakout bar low
      double breakoutHigh = iHigh(_Symbol, _Period, 1); //--- Get breakout bar high
      bool isDemandZone = closePrice > highPrice && breakoutLow >= lowPrice; //--- Check demand zone
      bool isSupplyZone = closePrice < lowPrice && breakoutHigh <= highPrice; //--- Check supply zone
      if (isDemandZone || isSupplyZone) {         //--- Validate zone type
         double zoneSize = (highPrice - lowPrice) / _Point; //--- Calculate zone size
         if (zoneSizeRestriction == EnforceLimits && (zoneSize < minZonePoints || zoneSize > maxZonePoints)) return; //--- Check size restrictions
         datetime lastClosedBarTime = iTime(_Symbol, _Period, 1); //--- Get last bar time
         bool overlaps = false;                   //--- Initialize overlap flag
         for (int j = 0; j < ArraySize(zones); j++) { //--- Check existing zones
            if (lastClosedBarTime < zones[j].endTime) { //--- Check time overlap
               double maxLow = MathMax(lowPrice, zones[j].low); //--- Find max low
               double minHigh = MathMin(highPrice, zones[j].high); //--- Find min high
               if (maxLow <= minHigh) {           //--- Check price overlap
                  overlaps = true;                //--- Mark as overlapping
                  break;                          //--- Exit loop
               }
            }
         }
         bool duplicate = false;                  //--- Initialize duplicate flag
         for (int j = 0; j < ArraySize(zones); j++) { //--- Check for duplicates
            if (lastClosedBarTime < zones[j].endTime) { //--- Check time
               if (MathAbs(zones[j].high - highPrice) < _Point && MathAbs(zones[j].low - lowPrice) < _Point) { //--- Check price match
                  duplicate = true;               //--- Mark as duplicate
                  break;                          //--- Exit loop
               }
            }
         }
         if (overlaps || duplicate) return;       //--- Skip overlapping or duplicate zones
         if (enableImpulseValidation) {           //--- Check impulse validation
            bool pot_overlaps = false;            //--- Initialize potential overlap flag
            for (int j = 0; j < ArraySize(potentialZones); j++) { //--- Check potential zones
               if (lastClosedBarTime < potentialZones[j].endTime) { //--- Check time overlap
                  double maxLow = MathMax(lowPrice, potentialZones[j].low); //--- Find max low
                  double minHigh = MathMin(highPrice, potentialZones[j].high); //--- Find min high
                  if (maxLow <= minHigh) {        //--- Check price overlap
                     pot_overlaps = true;         //--- Mark as overlapping
                     break;                       //--- Exit loop
                  }
               }
            }
            bool pot_duplicate = false;           //--- Initialize potential duplicate flag
            for (int j = 0; j < ArraySize(potentialZones); j++) { //--- Check potential duplicates
               if (lastClosedBarTime < potentialZones[j].endTime) { //--- Check time
                  if (MathAbs(potentialZones[j].high - highPrice) < _Point && MathAbs(potentialZones[j].low - lowPrice) < _Point) { //--- Check price match
                     pot_duplicate = true;      //--- Mark as duplicate
                     break;                     //--- Exit loop
                  }
               }
            }
            if (pot_overlaps || pot_duplicate) return; //--- Skip overlapping or duplicate potential zones
            int potCount = ArraySize(potentialZones); //--- Get potential zones count
            ArrayResize(potentialZones, potCount + 1); //--- Resize potential zones array
            potentialZones[potCount].high = highPrice; //--- Set zone high
            potentialZones[potCount].low = lowPrice; //--- Set zone low
            potentialZones[potCount].startTime = iTime(_Symbol, _Period, startIndex); //--- Set start time
            potentialZones[potCount].endTime = TimeCurrent() + PeriodSeconds(_Period) * zoneExtensionBars; //--- Set end time
            potentialZones[potCount].breakoutTime = iTime(_Symbol, _Period, 1); //--- Set breakout time
            potentialZones[potCount].isDemand = isDemandZone; //--- Set zone type
            potentialZones[potCount].tested = false; //--- Set untested
            potentialZones[potCount].broken = false; //--- Set not broken
            potentialZones[potCount].readyForTest = false; //--- Set not ready
            potentialZones[potCount].tradeCount = 0; //--- Initialize trade count
            potentialZones[potCount].name = "PotentialZone_" + TimeToString(potentialZones[potCount].startTime, TIME_DATE|TIME_SECONDS); //--- Set zone name
            Print("Potential zone created: ", (isDemandZone ? "Demand" : "Supply"), " at ", lowPrice, " - ", highPrice, " endTime: ", TimeToString(potentialZones[potCount].endTime)); //--- Log potential zone
         } else {                                 //--- No impulse validation
            int zoneCount = ArraySize(zones);     //--- Get zones count
            if (zoneCount >= maxZones) {          //--- Check max zones limit
               ArrayRemove(zones, 0, 1);          //--- Remove oldest zone
               zoneCount--;                       //--- Decrease count
            }
            ArrayResize(zones, zoneCount + 1);    //--- Resize zones array
            zones[zoneCount].high = highPrice;    //--- Set zone high
            zones[zoneCount].low = lowPrice;      //--- Set zone low
            zones[zoneCount].startTime = iTime(_Symbol, _Period, startIndex); //--- Set start time
            zones[zoneCount].endTime = TimeCurrent() + PeriodSeconds(_Period) * zoneExtensionBars; //--- Set end time
            zones[zoneCount].breakoutTime = iTime(_Symbol, _Period, 1); //--- Set breakout time
            zones[zoneCount].isDemand = isDemandZone; //--- Set zone type
            zones[zoneCount].tested = false;      //--- Set untested
            zones[zoneCount].broken = false;      //--- Set not broken
            zones[zoneCount].readyForTest = false; //--- Set not ready
            zones[zoneCount].tradeCount = 0;      //--- Initialize trade count
            zones[zoneCount].name = "SDZone_" + TimeToString(zones[zoneCount].startTime, TIME_DATE|TIME_SECONDS); //--- Set zone name
            Print("Zone created: ", (isDemandZone ? "Demand" : "Supply"), " zone: ", zones[zoneCount].name, " at ", lowPrice, " - ", highPrice, " endTime: ", TimeToString(zones[zoneCount].endTime)); //--- Log zone creation
            PrintZones(zones);                    //--- Print zones for debugging
         }
      }
   }
}

//+------------------------------------------------------------------+
//| Validate potential zones based on impulsive move                 |
//+------------------------------------------------------------------+
void ValidatePotentialZones() {
   datetime lastClosedBarTime = iTime(_Symbol, _Period, 1); //--- Get last closed bar time
   for (int p = ArraySize(potentialZones) - 1; p >= 0; p--) { //--- Iterate potential zones backward
      if (lastClosedBarTime >= potentialZones[p].endTime) { //--- Check for expired zone
         Print("Potential zone expired and removed from array: ", potentialZones[p].name, " endTime: ", TimeToString(potentialZones[p].endTime)); //--- Log expiration
         ArrayRemove(potentialZones, p, 1);    //--- Remove expired zone
         continue;                             //--- Skip to next
      }
      if (TimeCurrent() > potentialZones[p].breakoutTime + impulseCheckBars * PeriodSeconds(_Period)) { //--- Check impulse window
         bool isImpulsive = false;             //--- Initialize impulsive flag
         int breakoutShift = iBarShift(_Symbol, _Period, potentialZones[p].breakoutTime, false); //--- Get breakout bar shift
         double range = potentialZones[p].high - potentialZones[p].low; //--- Calculate zone range
         double threshold = range * impulseMultiplier; //--- Calculate impulse threshold
         for (int shift = 1; shift <= impulseCheckBars; shift++) { //--- Check bars after breakout
            if (shift + breakoutShift >= iBars(_Symbol, _Period)) continue; //--- Skip out-of-bounds
            double cl = iClose(_Symbol, _Period, shift); //--- Get close price
            if (potentialZones[p].isDemand) {  //--- Check demand zone
               if (cl >= potentialZones[p].high + threshold) { //--- Check bullish impulse
                  isImpulsive = true;          //--- Set impulsive flag
                  break;                       //--- Exit loop
               }
            } else {                           //--- Check supply zone
               if (cl <= potentialZones[p].low - threshold) { //--- Check bearish impulse
                  isImpulsive = true;          //--- Set impulsive flag
                  break;                       //--- Exit loop
               }
            }
         }
         if (isImpulsive) {                    //--- Process impulsive zone
            double zoneSize = (potentialZones[p].high - potentialZones[p].low) / _Point; //--- Calculate zone size
            if (zoneSizeRestriction == EnforceLimits && (zoneSize < minZonePoints || zoneSize > maxZonePoints)) { //--- Check size limits
               ArrayRemove(potentialZones, p, 1); //--- Remove invalid zone
               continue;                       //--- Skip to next
            }
            bool overlaps = false;             //--- Initialize overlap flag
            for (int j = 0; j < ArraySize(zones); j++) { //--- Check existing zones
               if (lastClosedBarTime < zones[j].endTime) { //--- Check time overlap
                  double maxLow = MathMax(potentialZones[p].low, zones[j].low); //--- Find max low
                  double minHigh = MathMin(potentialZones[p].high, zones[j].high); //--- Find min high
                  if (maxLow <= minHigh) {     //--- Check price overlap
                     overlaps = true;          //--- Mark as overlapping
                     break;                    //--- Exit loop
                  }
               }
            }
            bool duplicate = false;            //--- Initialize duplicate flag
            for (int j = 0; j < ArraySize(zones); j++) { //--- Check for duplicates
               if (lastClosedBarTime < zones[j].endTime) { //--- Check time
                  if (MathAbs(zones[j].high - potentialZones[p].high) < _Point && MathAbs(zones[j].low - potentialZones[p].low) < _Point) { //--- Check price match
                     duplicate = true;         //--- Mark as duplicate
                     break;                    //--- Exit loop
                  }
               }
            }
            if (overlaps || duplicate) {       //--- Check overlap or duplicate
               Print("Validated zone overlaps or duplicates, discarded: ", potentialZones[p].low, " - ", potentialZones[p].high); //--- Log discard
               ArrayRemove(potentialZones, p, 1); //--- Remove zone
               continue;                       //--- Skip to next
            }
            int zoneCount = ArraySize(zones);  //--- Get zones count
            if (zoneCount >= maxZones) {       //--- Check max zones limit
               ArrayRemove(zones, 0, 1);       //--- Remove oldest zone
               zoneCount--;                    //--- Decrease count
            }
            ArrayResize(zones, zoneCount + 1); //--- Resize zones array
            zones[zoneCount] = potentialZones[p]; //--- Copy potential zone
            zones[zoneCount].name = "SDZone_" + TimeToString(zones[zoneCount].startTime, TIME_DATE|TIME_SECONDS); //--- Set zone name
            zones[zoneCount].endTime = TimeCurrent() + PeriodSeconds(_Period) * zoneExtensionBars; //--- Update end time
            Print("Zone validated: ", (zones[zoneCount].isDemand ? "Demand" : "Supply"), " zone: ", zones[zoneCount].name, " at ", zones[zoneCount].low, " - ", zones[zoneCount].high, " endTime: ", TimeToString(zones[zoneCount].endTime)); //--- Log validation
            ArrayRemove(potentialZones, p, 1); //--- Remove validated zone
            PrintZones(zones);                 //--- Print zones for debugging
         } else {                              //--- Zone not impulsive
            Print("Potential zone not impulsive, discarded: ", potentialZones[p].low, " - ", potentialZones[p].high); //--- Log discard
            ArrayRemove(potentialZones, p, 1); //--- Remove non-impulsive zone
         }
      }
   }
}

//+------------------------------------------------------------------+
//| Update and draw zones                                            |
//+------------------------------------------------------------------+
void UpdateZones() {
   datetime lastClosedBarTime = iTime(_Symbol, _Period, 1); //--- Get last closed bar time
   for (int i = ArraySize(zones) - 1; i >= 0; i--) { //--- Iterate zones backward
      if (lastClosedBarTime >= zones[i].endTime) { //--- Check for expired zone
         Print("Zone expired and removed from array: ", zones[i].name, " endTime: ", TimeToString(zones[i].endTime)); //--- Log expiration
         if (deleteExpiredZonesFromChart) {    //--- Check if deleting expired
            ObjectDelete(0, zones[i].name);    //--- Delete zone rectangle
            ObjectDelete(0, zones[i].name + "Label"); //--- Delete zone label
         }
         ArrayRemove(zones, i, 1);             //--- Remove expired zone
         continue;                             //--- Skip to next
      }
      bool wasReady = zones[i].readyForTest;   //--- Store previous ready status
      if (!zones[i].readyForTest) {            //--- Check if not ready
         double currentClose = iClose(_Symbol, _Period, 1); //--- Get current close
         double zoneLevel = zones[i].isDemand ? zones[i].high : zones[i].low; //--- Get zone level
         double distance = zones[i].isDemand ? (currentClose - zoneLevel) : (zoneLevel - currentClose); //--- Calculate distance
         if (distance > minMoveAwayPoints * _Point) { //--- Check move away distance
            zones[i].readyForTest = true;      //--- Set ready for test
         }
      }
      if (!wasReady && zones[i].readyForTest) { //--- Check if newly ready
         Print("Zone ready for test: ", zones[i].name); //--- Log ready status
      }
      if (brokenZoneMode == AllowBroken && !zones[i].tested) { //--- Check if breakable
         double currentClose = iClose(_Symbol, _Period, 1); //--- Get current close
         bool wasBroken = zones[i].broken;     //--- Store previous broken status
         if (zones[i].isDemand) {              //--- Check demand zone
            if (currentClose < zones[i].low) { //--- Check if broken
               zones[i].broken = true;         //--- Mark as broken
            }
         } else {                              //--- Check supply zone
            if (currentClose > zones[i].high) { //--- Check if broken
               zones[i].broken = true;         //--- Mark as broken
            }
         }
         if (!wasBroken && zones[i].broken) {  //--- Check if newly broken
            Print("Zone broken in UpdateZones: ", zones[i].name); //--- Log broken zone
            ObjectSetInteger(0, zones[i].name, OBJPROP_COLOR, brokenZoneColor); //--- Update zone color
            string labelName = zones[i].name + "Label"; //--- Get label name
            string labelText = zones[i].isDemand ? "Demand Zone (Broken)" : "Supply Zone (Broken)"; //--- Set broken label
            ObjectSetString(0, labelName, OBJPROP_TEXT, labelText); //--- Update label text
            if (deleteBrokenZonesFromChart) {  //--- Check if deleting broken
               ObjectDelete(0, zones[i].name); //--- Delete zone rectangle
               ObjectDelete(0, labelName);     //--- Delete zone label
            }
         }
      }
      if (ObjectFind(0, zones[i].name) >= 0 || (!zones[i].broken || !deleteBrokenZonesFromChart)) { //--- Check if drawable
         color zoneColor;                        //--- Initialize zone color
         if (zones[i].tested) {                  //--- Check if tested
            zoneColor = zones[i].isDemand ? testedDemandZoneColor : testedSupplyZoneColor; //--- Set tested color
         } else if (zones[i].broken) {           //--- Check if broken
            zoneColor = brokenZoneColor;         //--- Set broken color
         } else {                                //--- Untested zone
            zoneColor = zones[i].isDemand ? demandZoneColor : supplyZoneColor; //--- Set untested color
         }
         ObjectCreate(0, zones[i].name, OBJ_RECTANGLE, 0, zones[i].startTime, zones[i].high, zones[i].endTime, zones[i].low); //--- Create zone rectangle
         ObjectSetInteger(0, zones[i].name, OBJPROP_COLOR, zoneColor); //--- Set zone color
         ObjectSetInteger(0, zones[i].name, OBJPROP_FILL, true); //--- Enable fill
         ObjectSetInteger(0, zones[i].name, OBJPROP_BACK, true); //--- Set to background
         string labelName = zones[i].name + "Label"; //--- Generate label name
         string labelText = zones[i].isDemand ? "Demand Zone" : "Supply Zone"; //--- Set base label
         if (zones[i].tested) labelText += " (Tested)"; //--- Append tested status
         else if (zones[i].broken) labelText += " (Broken)"; //--- Append broken status
         datetime labelTime = zones[i].startTime + (zones[i].endTime - zones[i].startTime) / 2; //--- Calculate label time
         double labelPrice = (zones[i].high + zones[i].low) / 2; //--- Calculate label price
         ObjectCreate(0, labelName, OBJ_TEXT, 0, labelTime, labelPrice); //--- Create label
         ObjectSetString(0, labelName, OBJPROP_TEXT, labelText); //--- Set label text
         ObjectSetInteger(0, labelName, OBJPROP_COLOR, labelTextColor); //--- Set label color
         ObjectSetInteger(0, labelName, OBJPROP_ANCHOR, ANCHOR_CENTER); //--- Set label anchor
      }
   }
   ChartRedraw(0);                                //--- Redraw chart
}

//+------------------------------------------------------------------+
//| Trade on zones                                                   |
//+------------------------------------------------------------------+
void TradeOnZones(bool isNewBar) {
   static datetime lastTradeCheck = 0;            //--- Store last trade check time
   datetime currentBarTime = iTime(_Symbol, _Period, 0); //--- Get current bar time
   if (!isNewBar || lastTradeCheck == currentBarTime) return; //--- Exit if not new bar or checked
   lastTradeCheck = currentBarTime;               //--- Update last trade check
   double currentBid = NormalizeDouble(SymbolInfoDouble(_Symbol, SYMBOL_BID), _Digits); //--- Get current bid
   double currentAsk = NormalizeDouble(SymbolInfoDouble(_Symbol, SYMBOL_ASK), _Digits); //--- Get current ask
   for (int i = 0; i < ArraySize(zones); i++) {  //--- Iterate through zones
      if (zones[i].broken) continue;              //--- Skip broken zones
      if (tradeTestedMode == NoRetrade && zones[i].tested) continue; //--- Skip tested zones
      if (tradeTestedMode == LimitedRetrade && zones[i].tested && zones[i].tradeCount >= maxTradesPerZone) continue; //--- Skip max trades
      if (!zones[i].readyForTest) continue;       //--- Skip not ready zones
      double prevHigh = iHigh(_Symbol, _Period, 1); //--- Get previous high
      double prevLow = iLow(_Symbol, _Period, 1); //--- Get previous low
      double prevClose = iClose(_Symbol, _Period, 1); //--- Get previous close
      bool tapped = false;                        //--- Initialize tap flag
      bool overlap = (prevLow <= zones[i].high && prevHigh >= zones[i].low); //--- Check candle overlap
      if (zones[i].isDemand) {                    //--- Check demand zone
         if (overlap && prevClose > zones[i].high) { //--- Confirm demand tap
            tapped = true;                        //--- Set tapped flag
         }
      } else {                                    //--- Check supply zone
         if (overlap && prevClose < zones[i].low) { //--- Confirm supply tap
            tapped = true;                        //--- Set tapped flag
         }
      }
      if (tapped) {                               //--- Process tapped zone
         bool trendConfirmed = (trendConfirmation == NoConfirmation); //--- Assume no trend confirmation
         if (trendConfirmation == ConfirmTrend) { //--- Check trend confirmation
            int oldShift = 2 + trendLookbackBars - 1; //--- Calculate lookback shift
            if (oldShift >= iBars(_Symbol, _Period)) continue; //--- Skip if insufficient bars
            double oldClose = iClose(_Symbol, _Period, oldShift); //--- Get old close
            double recentClose = iClose(_Symbol, _Period, 2); //--- Get recent close
            double minChange = minTrendPoints * _Point; //--- Calculate min trend change
            if (zones[i].isDemand) {              //--- Check demand trend
               trendConfirmed = (oldClose > recentClose + minChange); //--- Confirm downtrend
            } else {                              //--- Check supply trend
               trendConfirmed = (oldClose < recentClose - minChange); //--- Confirm uptrend
            }
         }
         if (!trendConfirmed) continue;         //--- Skip if trend not confirmed
         bool wasTested = zones[i].tested;      //--- Store previous tested status
         if (zones[i].isDemand) {               //--- Handle demand trade
            double entryPrice = currentAsk;     //--- Set entry at ask
            double stopLossPrice = NormalizeDouble(zones[i].low - stopLossDistance * _Point, _Digits); //--- Set stop loss
            double takeProfitPrice = NormalizeDouble(entryPrice + takeProfitDistance * _Point, _Digits); //--- Set take profit
            obj_Trade.Buy(tradeLotSize, _Symbol, entryPrice, stopLossPrice, takeProfitPrice, "Buy at Demand Zone"); //--- Execute buy trade
            Print("Buy trade entered at Demand Zone: ", zones[i].name); //--- Log buy trade
         } else {                               //--- Handle supply trade
            double entryPrice = currentBid;     //--- Set entry at bid
            double stopLossPrice = NormalizeDouble(zones[i].high + stopLossDistance * _Point, _Digits); //--- Set stop loss
            double takeProfitPrice = NormalizeDouble(entryPrice - takeProfitDistance * _Point, _Digits); //--- Set take profit
            obj_Trade.Sell(tradeLotSize, _Symbol, entryPrice, stopLossPrice, takeProfitPrice, "Sell at Supply Zone"); //--- Execute sell trade
            Print("Sell trade entered at Supply Zone: ", zones[i].name); //--- Log sell trade
         }
         zones[i].tested = true;                //--- Mark zone as tested
         zones[i].tradeCount++;                 //--- Increment trade count
         if (!wasTested && zones[i].tested) {   //--- Check if newly tested
            Print("Zone tested: ", zones[i].name, ", Trade count: ", zones[i].tradeCount); //--- Log tested zone
         }
         color zoneColor = zones[i].isDemand ? testedDemandZoneColor : testedSupplyZoneColor; //--- Set tested color
         ObjectSetInteger(0, zones[i].name, OBJPROP_COLOR, zoneColor); //--- Update zone color
         string labelName = zones[i].name + "Label"; //--- Get label name
         string labelText = zones[i].isDemand ? "Demand Zone (Tested)" : "Supply Zone (Tested)"; //--- Set tested label
         ObjectSetString(0, labelName, OBJPROP_TEXT, labelText); //--- Update label text
      }
   }
   ChartRedraw(0);                                //--- Redraw chart
}

//+------------------------------------------------------------------+
//| Apply trailing stop to open positions                            |
//+------------------------------------------------------------------+
void ApplyTrailingStop() {
   double point = _Point;                         //--- Get point value
   for (int i = PositionsTotal() - 1; i >= 0; i--) { //--- Iterate through positions
      if (PositionGetTicket(i) > 0) {             //--- Check valid ticket
         if (PositionGetString(POSITION_SYMBOL) == _Symbol && PositionGetInteger(POSITION_MAGIC) == uniqueMagicNumber) { //--- Verify symbol and magic
            double sl = PositionGetDouble(POSITION_SL); //--- Get current stop loss
            double tp = PositionGetDouble(POSITION_TP); //--- Get current take profit
            double openPrice = PositionGetDouble(POSITION_PRICE_OPEN); //--- Get open price
            if (PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_BUY) { //--- Check buy position
               double newSL = NormalizeDouble(SymbolInfoDouble(_Symbol, SYMBOL_BID) - trailingStopPoints * point, _Digits); //--- Calculate new stop loss
               if (newSL > sl && SymbolInfoDouble(_Symbol, SYMBOL_BID) - openPrice > minProfitToTrail * point) { //--- Check trailing condition
                  obj_Trade.PositionModify(PositionGetInteger(POSITION_TICKET), newSL, tp); //--- Update stop loss
               }
            } else if (PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_SELL) { //--- Check sell position
               double newSL = NormalizeDouble(SymbolInfoDouble(_Symbol, SYMBOL_ASK) + trailingStopPoints * point, _Digits); //--- Calculate new stop loss
               if (newSL < sl && openPrice - SymbolInfoDouble(_Symbol, SYMBOL_ASK) > minProfitToTrail * point) { //--- Check trailing condition
                  obj_Trade.PositionModify(PositionGetInteger(POSITION_TICKET), newSL, tp); //--- Update stop loss
               }
            }
         }
      }
   }
}

//+------------------------------------------------------------------+