//+------------------------------------------------------------------+
//|                           1. Zone Recovery RSI EA Multi-Zone.mq5 |
//|                                  Copyright 2025, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2025, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
#property version   "1.00"

sinput group "General EA Settings"
input double inputlot = 0.01;
input double inputzonesizepts = 200;
input double inputzonetragetpts = 400;
input double inputlotmultiplier = 2.0;
input double inputTrailingStopPts = 50; // Trailing stop distance in points
input double inputMinimumProfitPts = 50; // Minimum profit points before trailing stop starts
input bool inputTrailingStopEnabled = true; // Enable or disable trailing stop
input bool inputEnablePositionsRestriction = true; // Enable Maximum positions restriction
input int inputMaximumPositions = 11; // Maximum number of positions


#include <Trade/Trade.mqh>
//--- Includes the MQL5 Trade library for handling trading operations.

//--- Global variables for RSI logic
int rsiPeriod = 14;                //--- The period used for calculating the RSI indicator.
int rsiHandle;                     //--- Handle for the RSI indicator, used to retrieve RSI values.
double rsiBuffer[];                //--- Array to store the RSI values retrieved from the indicator.
datetime lastBarTime = 0;          //--- Holds the time of the last processed bar to prevent duplicate signals.

//--- Struct to track individual position recovery states
struct PositionRecovery {
   CTrade trade;                    //--- Object to handle trading operations.
   double initialLotSize;           //--- Initial lot size for this position.
   double currentLotSize;           //--- Current lot size in the recovery sequence.
   double zoneSize;                 //--- Distance in points defining the recovery zone size.
   double targetSize;               //--- Distance in points defining the profit target range.
   double multiplier;               //--- Lot size multiplier for recovery trades.
   string symbol;                   //--- Trading symbol.
   ENUM_ORDER_TYPE lastOrderType;   //--- Type of the last order (BUY or SELL).
   double lastOrderPrice;           //--- Price of the last executed order.
   double zoneHigh;                 //--- Upper boundary of the recovery zone.
   double zoneLow;                  //--- Lower boundary of the recovery zone.
   double zoneTargetHigh;           //--- Upper boundary of the target range.
   double zoneTargetLow;            //--- Lower boundary of the target range.
   bool isRecovery;                 //--- Whether the recovery is active.
   ulong tickets[];                 //--- Array to store tickets of positions associated with this recovery.
   double trailingStop;             //--- Trailing stop level
   double initialEntryPrice;        //--- Initial entry price for trailing stop calculation

   //--- Initialize position recovery
   void Initialize(double lot, double zonePts, double targetPts, double lotMultiplier, string _symbol, ENUM_ORDER_TYPE type, double price) {
      initialLotSize = lot;             //--- Assign initial lot size.
      currentLotSize = lot;             //--- Set current lot size equal to initial lot size.
      zoneSize = zonePts * _Point;      //--- Calculate zone size in points.
      targetSize = targetPts * _Point;  //--- Calculate target size in points.
      multiplier = lotMultiplier;       //--- Assign lot size multiplier.
      symbol = _symbol;                 //--- Assign the trading symbol.
      lastOrderType = type;             //--- Set the type of the last order.
      lastOrderPrice = price;           //--- Record the price of the last executed order.
      isRecovery = false;               //--- Set recovery as inactive initially.
      ArrayResize(tickets, 0);          //--- Initialize the tickets array.
      trailingStop = 0;                 //--- Initialize trailing stop
      initialEntryPrice = price;        //--- Set initial entry price
      CalculateZones();                 //--- Calculate recovery and target zones.
   }

   //--- Calculate dynamic zones and targets
   void CalculateZones() {
      if (lastOrderType == ORDER_TYPE_BUY) { //--- If the last order was a BUY...
         zoneHigh = lastOrderPrice;         //--- Set upper boundary at the last order price.
         zoneLow = zoneHigh - zoneSize;     //--- Set lower boundary below the last order price.
         zoneTargetHigh = zoneHigh + targetSize; //--- Define target range above recovery zone.
         zoneTargetLow = zoneLow - targetSize;   //--- Define target range below recovery zone.
      } else if (lastOrderType == ORDER_TYPE_SELL) { //--- If the last order was a SELL...
         zoneLow = lastOrderPrice;                //--- Set lower boundary at the last order price.
         zoneHigh = zoneLow + zoneSize;           //--- Set upper boundary above the last order price.
         zoneTargetLow = zoneLow - targetSize;    //--- Define target range below recovery zone.
         zoneTargetHigh = zoneHigh + targetSize;  //--- Define target range above recovery zone.
      }
   }

   //--- Open a trade with comments for position type
   bool OpenTrade(ENUM_ORDER_TYPE type, string comment) {
      if (type == ORDER_TYPE_BUY) { //--- For a BUY order...
         if (trade.Buy(currentLotSize, symbol, 0, 0, 0, comment)) { //--- Attempt to place a BUY trade.
            lastOrderType = ORDER_TYPE_BUY;                        //--- Update the last order type.
            lastOrderPrice = SymbolInfoDouble(symbol, SYMBOL_BID); //--- Record the current price.
            ArrayResize(tickets, ArraySize(tickets) + 1);          //--- Resize the tickets array.
            tickets[ArraySize(tickets) - 1] = trade.ResultOrder(); //--- Store the new ticket.
            CalculateZones();                                      //--- Recalculate zones.
            isRecovery = false;                                    //--- Ensure recovery is inactive for initial trade.
            Print("Opened BUY Position, Ticket: ", tickets[ArraySize(tickets) - 1]);
            return true;                                           //--- Return success.
         }
      } else if (type == ORDER_TYPE_SELL) { //--- For a SELL order...
         if (trade.Sell(currentLotSize, symbol, 0, 0, 0, comment)) { //--- Attempt to place a SELL trade.
            lastOrderType = ORDER_TYPE_SELL;                        //--- Update the last order type.
            lastOrderPrice = SymbolInfoDouble(symbol, SYMBOL_BID);  //--- Record the current price.
            ArrayResize(tickets, ArraySize(tickets) + 1);           //--- Resize the tickets array.
            tickets[ArraySize(tickets) - 1] = trade.ResultOrder();  //--- Store the new ticket.
            CalculateZones();                                       //--- Recalculate zones.
            isRecovery = false;                                     //--- Ensure recovery is inactive for initial trade.
            Print("Opened SELL Position, Ticket: ", tickets[ArraySize(tickets) - 1]);
            return true;                                            //--- Return success.
         }
      }
      return false; //--- If the trade was not placed, return false.
   }

   //--- Get the entry price of a position by ticket
   double GetPositionEntryPrice(ulong ticket) {
      if (PositionSelectByTicket(ticket)) {
         return PositionGetDouble(POSITION_PRICE_OPEN);
      } else {
         Print("Failed to select position by ticket: ", ticket);
         return 0.0;
      }
   }

   //--- Manage zone recovery
   void ManageZones() {
      double currentPrice = SymbolInfoDouble(symbol, SYMBOL_BID); //--- Get the current price.
      if (lastOrderType == ORDER_TYPE_BUY && currentPrice <= zoneLow) { //--- If price drops below the recovery zone for a BUY...
         double previousLotSize = currentLotSize;                       //--- Store the current lot size temporarily.
         currentLotSize *= multiplier;                                 //--- Tentatively increase lot size.
         if (OpenTrade(ORDER_TYPE_SELL, "Recovery Position")) {        //--- Attempt to open a SELL recovery trade.
            isRecovery = true;                                         //--- Mark recovery as active if trade is successful.
         } else {
            currentLotSize = previousLotSize;                          //--- Revert the lot size if the trade fails.
         }
      } else if (lastOrderType == ORDER_TYPE_SELL && currentPrice >= zoneHigh) { //--- If price rises above the recovery zone for a SELL...
         double previousLotSize = currentLotSize;                       //--- Store the current lot size temporarily.
         currentLotSize *= multiplier;                                 //--- Tentatively increase lot size.
         if (OpenTrade(ORDER_TYPE_BUY, "Recovery Position")) {         //--- Attempt to open a BUY recovery trade.
            isRecovery = true;                                         //--- Mark recovery as active if trade is successful.
         } else {
            currentLotSize = previousLotSize;                          //--- Revert the lot size if the trade fails.
         }
      }
   }

   //--- Check and close trades at targets
   void CheckCloseAtTargets() {
      double currentPrice = SymbolInfoDouble(symbol, SYMBOL_BID); //--- Get the current price.
      if (lastOrderType == ORDER_TYPE_BUY && currentPrice >= zoneTargetHigh) { //--- If price reaches the target for a BUY...
         ClosePositionsAtTarget();                               //--- Close positions that meet the target criteria.
      } else if (lastOrderType == ORDER_TYPE_SELL && currentPrice <= zoneTargetLow) { //--- If price reaches the target for a SELL...
         ClosePositionsAtTarget();                               //--- Close positions that meet the target criteria.
      }
   }

   //--- Apply trailing stop logic to initial positions
   void ApplyTrailingStop() {
      if (inputTrailingStopEnabled && ArraySize(tickets) == 1) { // Ensure trailing stop is enabled and there is only one position (initial position)
         ulong ticket = tickets[0]; // Get the ticket of the initial position
         double entryPrice = GetPositionEntryPrice(ticket); // Get the entry price of the position by ticket
         double currentPrice = SymbolInfoDouble(symbol, SYMBOL_BID); // Get the current price
         double newTrailingStop;

         if (lastOrderType == ORDER_TYPE_BUY) {
            if (currentPrice > entryPrice + (inputMinimumProfitPts + inputTrailingStopPts) * _Point) {
               newTrailingStop = currentPrice - inputTrailingStopPts * _Point; // Calculate new trailing stop for BUY
               if (newTrailingStop > trailingStop) {
                  trailingStop = newTrailingStop; // Update trailing stop if the new one is higher
                  Print("Trailing BUY Position, Ticket: ", ticket, " New Trailing Stop: ", trailingStop);
               }
            }

            if (trailingStop != 0 && currentPrice <= trailingStop) {
               Print("Trailed and closing BUY Position, Ticket: ", ticket);
               ClosePositionsAtTarget(); // Close position if the price falls below the trailing stop
            }
         } else if (lastOrderType == ORDER_TYPE_SELL) {
            if (currentPrice < entryPrice - (inputMinimumProfitPts + inputTrailingStopPts) * _Point) {
               newTrailingStop = currentPrice + inputTrailingStopPts * _Point; // Calculate new trailing stop for SELL
               if (newTrailingStop < trailingStop) {
                  trailingStop = newTrailingStop; // Update trailing stop if the new one is lower
                  Print("Trailing SELL Position, Ticket: ", ticket, " New Trailing Stop: ", trailingStop);
               }
            }

            if (trailingStop != 0 && currentPrice >= trailingStop) {
               Print("Trailed and closing SELL Position, Ticket: ", ticket);
               ClosePositionsAtTarget(); // Close position if the price rises above the trailing stop
            }
         }
      }
   }

   //--- Close positions that have reached the target
   void ClosePositionsAtTarget() {
      for (int i = ArraySize(tickets) - 1; i >= 0; i--) {              //--- Iterate through all tickets.
         ulong ticket = tickets[i];                                    //--- Get the position ticket.
         int retries = 10;                                             //--- Set retry count.
         while (retries > 0) {                                         //--- Retry until successful or retries exhausted.
            if (trade.PositionClose(ticket)) {                         //--- Attempt to close the position.
               Print("CLOSED # ", ticket, " Trailed and closed: ", (trailingStop != 0));
               ArrayRemove(tickets, i);                                //--- Remove the ticket from the array on success.
               retries = 0;                                            //--- Exit the loop on success.
            } else {
               retries--;                                              //--- Decrement retries on failure.
               Sleep(100);                                             //--- Wait before retrying.
            }
         }
      }
      if (ArraySize(tickets) == 0) {                                   //--- If all tickets are closed...
         Reset();                                                      //--- Reset recovery state after closing the target positions.
      }
   }

   //--- Reset recovery state
   void Reset() {
      currentLotSize = inputlot; //--- Reset lot size to initial value.
      lastOrderType = -1;              //--- Clear the last order type.
      lastOrderPrice = 0.0;            //--- Reset the last order price.
      isRecovery = false;              //--- Mark recovery as inactive.
      ArrayResize(tickets, 0);         //--- Clear the tickets array.
      trailingStop = 0;                //--- Reset trailing stop
      initialEntryPrice = 0.0;         //--- Reset initial entry price
      Print("Strategy BASKET reset after closing trades.");
   }
};

//--- Dynamic list to track multiple positions
PositionRecovery recoveryArray[]; //--- Dynamic array for recovery instances.

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit() {
   rsiHandle = iRSI(_Symbol, PERIOD_CURRENT, rsiPeriod, PRICE_CLOSE); //--- Create RSI indicator handle.
   if (rsiHandle == INVALID_HANDLE) {                                 //--- Check if handle creation failed.
      Print("Failed to create RSI handle. Error: ", GetLastError());  //--- Print error message.
      return(INIT_FAILED);                                            //--- Return initialization failure.
   }
   ArraySetAsSeries(rsiBuffer, true); //--- Set RSI buffer as a time series.
   Print("Multi-Zone Recovery Strategy initialized."); //--- Log initialization success.
   return(INIT_SUCCEEDED); //--- Return initialization success.
}

//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason) {
   if (rsiHandle != INVALID_HANDLE)             //--- Check if RSI handle is valid.
      IndicatorRelease(rsiHandle);              //--- Release the RSI handle.
   Print("Multi-Zone Recovery Strategy deinitialized."); //--- Log deinitialization.
}

//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick() {
   if (CopyBuffer(rsiHandle, 0, 1, 2, rsiBuffer) <= 0) { //--- Copy the RSI buffer values.
      Print("Failed to copy RSI buffer. Error: ", GetLastError()); //--- Print error on failure.
      return;                                                     //--- Exit on failure.
   }

   datetime currentBarTime = iTime(_Symbol, PERIOD_CURRENT, 0); //--- Get the time of the current bar.
   if (currentBarTime != lastBarTime) {                         //--- Check if a new bar has formed.
      lastBarTime = currentBarTime;                             //--- Update the last processed bar time.
      if (rsiBuffer[1] > 30 && rsiBuffer[0] <= 30) {            //--- Check for oversold RSI crossing up.
         Print("BUY SIGNAL");
         if (inputEnablePositionsRestriction == false || inputMaximumPositions > PositionsTotal()){
            PositionRecovery newRecovery;                          //--- Create a new recovery instance.
            newRecovery.Initialize(inputlot, inputzonesizepts, inputzonetragetpts, inputlotmultiplier, _Symbol, ORDER_TYPE_BUY, SymbolInfoDouble(_Symbol, SYMBOL_BID)); //--- Initialize the recovery.
            newRecovery.OpenTrade(ORDER_TYPE_BUY, "Initial Position"); //--- Open an initial BUY position.
            ArrayResize(recoveryArray, ArraySize(recoveryArray) + 1); //--- Resize the recovery array.
            recoveryArray[ArraySize(recoveryArray) - 1] = newRecovery; //--- Add the new recovery to the array.
         }
         else {
            Print("FAILED: Maximum positions threshold hit!");
         }
      } else if (rsiBuffer[1] < 70 && rsiBuffer[0] >= 70) {      //--- Check for overbought RSI crossing down.
         Print("SELL SIGNAL");
         if (inputEnablePositionsRestriction == false || inputMaximumPositions > PositionsTotal()){
            PositionRecovery newRecovery;                          //--- Create a new recovery instance.
            newRecovery.Initialize(inputlot, inputzonesizepts, inputzonetragetpts, inputlotmultiplier, _Symbol, ORDER_TYPE_SELL, SymbolInfoDouble(_Symbol, SYMBOL_BID)); //--- Initialize the recovery.
            newRecovery.OpenTrade(ORDER_TYPE_SELL, "Initial Position"); //--- Open an initial SELL position.
            ArrayResize(recoveryArray, ArraySize(recoveryArray) + 1); //--- Resize the recovery array.
            recoveryArray[ArraySize(recoveryArray) - 1] = newRecovery; //--- Add the new recovery to the array.
         }
         else {
            Print("FAILED: Maximum positions threshold hit!");
         }
      }
   }

   for (int i = 0; i < ArraySize(recoveryArray); i++) { //--- Iterate through all recovery instances.
      recoveryArray[i].ManageZones();                 //--- Manage zones for each recovery instance.
      recoveryArray[i].CheckCloseAtTargets();         //--- Check and close positions at targets.
      recoveryArray[i].ApplyTrailingStop();           //--- Apply trailing stop logic to initial positions.
   }
}