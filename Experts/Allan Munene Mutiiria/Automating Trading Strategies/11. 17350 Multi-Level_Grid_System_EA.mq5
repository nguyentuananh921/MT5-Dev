//+------------------------------------------------------------------+
//|                        Copyright 2025, Forex Algo-Trader, Allan. |
//|                                 "https://t.me/Forex_Algo_Trader" |
//+------------------------------------------------------------------+
#property copyright "Forex Algo-Trader, Allan"
#property link      "https://t.me/Forex_Algo_Trader"
#property version   "1.00"
#property description "This EA trades multiple signals with grid strategy using baskets"
#property strict

#include <Trade/Trade.mqh> //--- Includes the standard trading library for executing trades
CTrade obj_Trade; //--- Instantiates the CTrade object used for managing trade operations

//--- Closure Mode Enumeration and Inputs
enum ClosureMode {
   CLOSE_BY_PROFIT,      //--- Use total profit (in currency) to close positions
   CLOSE_BY_POINTS       //--- Use points threshold from breakeven to close positions
};

input group "General EA Settings"
input ClosureMode closureMode = CLOSE_BY_POINTS;
input double inpLotSize = 0.01;
input long inpMagicNo = 1234567;
input int inpTp_Points = 1000;
input int inpGridSize = 1000;
input double inpMultiplier = 2.0;
input int inpBreakevenPts = 50;
input int maxBaskets = 5;

input group "MA Indicator Settings"
input int inpMAPeriod = 21;

//--- Basket Structure
struct BasketInfo {
   int basketId;            //--- Unique basket identifier (e.g., 1, 2, 3...)
   long magic;              //--- Unique magic number for this basket to differentiate its trades
   int direction;           //--- Direction of the basket: POSITION_TYPE_BUY or POSITION_TYPE_SELL
   double initialLotSize;   //--- The initial lot size assigned to the basket
   double currentLotSize;   //--- The current lot size for subsequent grid trades
   double gridSize;         //--- The next grid level price for the basket
   double takeProfit;       //--- The current take-profit price for the basket
   datetime signalTime;     //--- Timestamp of the signal to avoid duplicate trade entries
};

BasketInfo baskets[];       //--- Dynamic array to store active basket information
int nextBasketId = 1;       //--- Counter for assigning unique IDs to new baskets
long baseMagic = inpMagicNo;//--- Base magic number obtained from user input
double takeProfitPts = inpTp_Points * _Point; //--- Convert take profit points into price units
double gridSize_Spacing = inpGridSize * _Point; //--- Convert grid size spacing from points into price units
double profitTotal_inCurrency = 100; //--- Target profit in account currency for closing positions

//--- Global Variables
int totalBars = 0;          //--- Stores the total number of bars processed so far
int handle;                 //--- Handle for the Moving Average indicator
double maData[];            //--- Array to store Moving Average indicator data

//--- Function Prototypes
void InitializeBaskets(); //--- Prototype for basket initialization function (if used)
void CheckAndCloseProfitTargets(); //--- Prototype to check and close positions if profit target is reached
void CheckForNewSignal(double ask, double bid); //--- Prototype to check for new trading signals based on price
bool ExecuteInitialTrade(int basketIdx, double ask, double bid, int direction); //--- Prototype to execute the initial trade for a basket
void ManageGridPositions(int basketIdx, double ask, double bid); //--- Prototype to manage and add grid positions for an active basket
void UpdateMovingAverage(); //--- Prototype to update the Moving Average indicator data
bool IsNewBar(); //--- Prototype to check whether a new bar has formed
double CalculateBreakevenPrice(int basketId); //--- Prototype to calculate the weighted breakeven price for a basket
void CheckBreakevenClose(int basketIdx, double ask, double bid); //--- Prototype to check and close positions based on breakeven criteria
void CloseBasketPositions(int basketId); //--- Prototype to close all positions within a basket
string GetPositionComment(int basketId, bool isInitial); //--- Prototype to generate a comment for a position based on basket and trade type
int CountBasketPositions(int basketId); //--- Prototype to count the number of open positions in a basket

//+------------------------------------------------------------------+
//--- Expert initialization function
//+------------------------------------------------------------------+
int OnInit() {
   handle = iMA(_Symbol, _Period, inpMAPeriod, 0, MODE_SMA, PRICE_CLOSE); //--- Initialize the Moving Average indicator with specified period and parameters
   if(handle == INVALID_HANDLE) {
      Print("ERROR: Unable to initialize Moving Average indicator!"); //--- Log error if indicator initialization fails
      return(INIT_FAILED); //--- Terminate initialization with a failure code
   }
   ArraySetAsSeries(maData, true); //--- Set the moving average data array as a time series (newest data at index 0)
   ArrayResize(baskets, 0); //--- Initialize the baskets array as empty at startup
   obj_Trade.SetExpertMagicNumber(baseMagic); //--- Set the default magic number for trade operations
   return(INIT_SUCCEEDED); //--- Signal that initialization completed successfully
}

//+------------------------------------------------------------------+
//--- Expert deinitialization function
//+------------------------------------------------------------------+
void OnDeinit(const int reason) {
   IndicatorRelease(handle); //--- Release the indicator handle to free up resources when the EA is removed
}

//+------------------------------------------------------------------+
//--- Expert tick function
//+------------------------------------------------------------------+
void OnTick() {
   if(IsNewBar()) { //--- Execute logic only when a new bar is detected
      UpdateMovingAverage(); //--- Update the Moving Average data for the current bar
      double ask = NormalizeDouble(SymbolInfoDouble(_Symbol, SYMBOL_ASK), _Digits); //--- Get and normalize the current ask price
      double bid = NormalizeDouble(SymbolInfoDouble(_Symbol, SYMBOL_BID), _Digits); //--- Get and normalize the current bid price

      //--- Check for new signals and create baskets accordingly
      CheckForNewSignal(ask, bid);

      //--- Loop through all active baskets to manage grid positions and potential closures
      for(int i = 0; i < ArraySize(baskets); i++) {
         ManageGridPositions(i, ask, bid); //--- Manage grid trading for the current basket
         if(closureMode == CLOSE_BY_PROFIT) CheckAndCloseProfitTargets(); //--- If using profit target closure mode, check for profit conditions
         if(closureMode == CLOSE_BY_POINTS && CountBasketPositions(baskets[i].basketId) > 1) {
            CheckBreakevenClose(i, ask, bid); //--- If using points-based closure and multiple positions exist, check breakeven conditions
         }
      }

      //--- Remove inactive baskets that no longer have any open positions
      for(int i = ArraySize(baskets) - 1; i >= 0; i--) {
         if(CountBasketPositions(baskets[i].basketId) == 0) {
            Print("Removing inactive basket ID: ", baskets[i].basketId); //--- Log the removal of an inactive basket
            for(int j = i; j < ArraySize(baskets) - 1; j++) {
               baskets[j] = baskets[j + 1]; //--- Shift basket elements down to fill the gap
            }
            ArrayResize(baskets, ArraySize(baskets) - 1); //--- Resize the baskets array to remove the empty slot
         }
      }
   }
}

//+------------------------------------------------------------------+
//--- Check for New Crossover Signal
//+------------------------------------------------------------------+
void CheckForNewSignal(double ask, double bid) {
   double close1 = iClose(_Symbol, _Period, 1); //--- Retrieve the close price of the previous bar
   double close2 = iClose(_Symbol, _Period, 2); //--- Retrieve the close price of the bar before the previous one
   datetime currentBarTime = iTime(_Symbol, _Period, 1); //--- Get the time of the current bar

   if(ArraySize(baskets) >= maxBaskets) return; //--- Exit if the maximum allowed baskets are already active

   //--- Buy signal: current bar closes above the MA while the previous closed below it
   if(close1 > maData[1] && close2 < maData[1]) {
      //--- Check if this signal was already processed by comparing signal times in existing baskets
      for(int i = 0; i < ArraySize(baskets); i++) {
         if(baskets[i].signalTime == currentBarTime) return; //--- Signal already acted upon; exit the function
      }
      int basketIdx = ArraySize(baskets); //--- Index for the new basket equals the current array size
      ArrayResize(baskets, basketIdx + 1); //--- Increase the size of the baskets array to add a new basket
      if (ExecuteInitialTrade(basketIdx, ask, bid, POSITION_TYPE_BUY)){
         baskets[basketIdx].signalTime = currentBarTime; //--- Record the time of the signal after a successful trade
      }
   }
   //--- Sell signal: current bar closes below the MA while the previous closed above it
   else if(close1 < maData[1] && close2 > maData[1]) {
      //--- Check for duplicate signals by verifying the signal time in active baskets
      for(int i = 0; i < ArraySize(baskets); i++) {
         if(baskets[i].signalTime == currentBarTime) return; //--- Signal already acted upon; exit the function
      }
      int basketIdx = ArraySize(baskets); //--- Determine the index for the new basket
      ArrayResize(baskets, basketIdx + 1); //--- Resize the baskets array to accommodate the new basket
      if (ExecuteInitialTrade(basketIdx, ask, bid, POSITION_TYPE_SELL)){
         baskets[basketIdx].signalTime = currentBarTime; //--- Record the signal time for the new sell basket
      }
   }
}

//+------------------------------------------------------------------+
//--- Execute Initial Trade
//+------------------------------------------------------------------+
bool ExecuteInitialTrade(int basketIdx, double ask, double bid, int direction) {
   baskets[basketIdx].basketId = nextBasketId++; //--- Assign a unique basket ID and increment the counter
   baskets[basketIdx].magic = baseMagic + baskets[basketIdx].basketId * 10000; //--- Calculate a unique magic number for the basket
   baskets[basketIdx].initialLotSize = inpLotSize; //--- Set the initial lot size for the basket from input
   baskets[basketIdx].currentLotSize = inpLotSize; //--- Initialize current lot size to the same as the initial lot size
   baskets[basketIdx].direction = direction; //--- Set the trade direction (buy or sell) for the basket
   bool isTradeExecuted = false; //--- Initialize flag to track if the trade was successfully executed
   string comment = GetPositionComment(baskets[basketIdx].basketId, true); //--- Generate a comment string indicating an initial trade
   obj_Trade.SetExpertMagicNumber(baskets[basketIdx].magic); //--- Set the trade object's magic number to the basket's unique value

   if(direction == POSITION_TYPE_BUY) {
      baskets[basketIdx].gridSize = ask - gridSize_Spacing; //--- Set the grid level for subsequent buy orders below the current ask price
      baskets[basketIdx].takeProfit = ask + takeProfitPts; //--- Calculate the take profit level for the buy order
      if(obj_Trade.Buy(baskets[basketIdx].currentLotSize, _Symbol, ask, 0, baskets[basketIdx].takeProfit, comment)) {
         Print("Basket ", baskets[basketIdx].basketId, ": Initial BUY at ", ask, " | Magic: ", baskets[basketIdx].magic); //--- Log the successful buy order details
         isTradeExecuted = true; //--- Mark the trade as executed successfully
      } else {
         Print("Basket ", baskets[basketIdx].basketId, ": Initial BUY failed, error: ", GetLastError()); //--- Log the error if the buy order fails
         ArrayResize(baskets, ArraySize(baskets) - 1); //--- Remove the basket if trade execution fails
      }
   } else if(direction == POSITION_TYPE_SELL) {
      baskets[basketIdx].gridSize = bid + gridSize_Spacing; //--- Set the grid level for subsequent sell orders above the current bid price
      baskets[basketIdx].takeProfit = bid - takeProfitPts; //--- Calculate the take profit level for the sell order
      if(obj_Trade.Sell(baskets[basketIdx].currentLotSize, _Symbol, bid, 0, baskets[basketIdx].takeProfit, comment)) {
         Print("Basket ", baskets[basketIdx].basketId, ": Initial SELL at ", bid, " | Magic: ", baskets[basketIdx].magic); //--- Log the successful sell order details
         isTradeExecuted = true; //--- Mark the trade as executed successfully
      } else {
         Print("Basket ", baskets[basketIdx].basketId, ": Initial SELL failed, error: ", GetLastError()); //--- Log the error if the sell order fails
         ArrayResize(baskets, ArraySize(baskets) - 1); //--- Remove the basket if trade execution fails
      }
   }
   return (isTradeExecuted); //--- Return the status of the trade execution
}

//+------------------------------------------------------------------+
//--- Manage Grid Positions
//+------------------------------------------------------------------+
void ManageGridPositions(int basketIdx, double ask, double bid) {
   bool newPositionOpened = false; //--- Flag to track if a new grid position has been opened
   string comment = GetPositionComment(baskets[basketIdx].basketId, false); //--- Generate a comment for grid trades in this basket
   obj_Trade.SetExpertMagicNumber(baskets[basketIdx].magic); //--- Ensure the trade object uses the basket's unique magic number

   if(baskets[basketIdx].direction == POSITION_TYPE_BUY) {
      if(ask <= baskets[basketIdx].gridSize) { //--- Check if the ask price has reached the grid level for a buy order
         baskets[basketIdx].currentLotSize *= inpMultiplier; //--- Increase the lot size based on the defined multiplier
         if(obj_Trade.Buy(baskets[basketIdx].currentLotSize, _Symbol, ask, 0, baskets[basketIdx].takeProfit, comment)) {
            newPositionOpened = true; //--- Set flag if the grid buy order is successfully executed
            Print("Basket ", baskets[basketIdx].basketId, ": Grid BUY at ", ask); //--- Log the grid buy execution details
            baskets[basketIdx].gridSize = ask - gridSize_Spacing; //--- Adjust the grid level for the next potential buy order
         } else {
            Print("Basket ", baskets[basketIdx].basketId, ": Grid BUY failed, error: ", GetLastError()); //--- Log an error if the grid buy order fails
         }
      }
   } else if(baskets[basketIdx].direction == POSITION_TYPE_SELL) {
      if(bid >= baskets[basketIdx].gridSize) { //--- Check if the bid price has reached the grid level for a sell order
         baskets[basketIdx].currentLotSize *= inpMultiplier; //--- Increase the lot size based on the multiplier for grid orders
         if(obj_Trade.Sell(baskets[basketIdx].currentLotSize, _Symbol, bid, 0, baskets[basketIdx].takeProfit, comment)) {
            newPositionOpened = true; //--- Set flag if the grid sell order is successfully executed
            Print("Basket ", baskets[basketIdx].basketId, ": Grid SELL at ", bid); //--- Log the grid sell execution details
            baskets[basketIdx].gridSize = bid + gridSize_Spacing; //--- Adjust the grid level for the next potential sell order
         } else {
            Print("Basket ", baskets[basketIdx].basketId, ": Grid SELL failed, error: ", GetLastError()); //--- Log an error if the grid sell order fails
         }
      }
   }

   //--- If a new grid position was opened and there are multiple positions, adjust the take profit to breakeven
   if(newPositionOpened && CountBasketPositions(baskets[basketIdx].basketId) > 1) {
      double breakevenPrice = CalculateBreakevenPrice(baskets[basketIdx].basketId); //--- Calculate the weighted breakeven price for the basket
      double newTP = (baskets[basketIdx].direction == POSITION_TYPE_BUY) ?
                     breakevenPrice + (inpBreakevenPts * _Point) : //--- Set new TP for buy positions
                     breakevenPrice - (inpBreakevenPts * _Point);  //--- Set new TP for sell positions
      baskets[basketIdx].takeProfit = newTP; //--- Update the basket's take profit level with the new value
      for(int j = PositionsTotal() - 1; j >= 0; j--) { //--- Loop through all open positions to update TP where necessary
         ulong ticket = PositionGetTicket(j); //--- Get the ticket number for the current position
         if(PositionSelectByTicket(ticket) && 
            PositionGetString(POSITION_SYMBOL) == _Symbol && 
            PositionGetInteger(POSITION_MAGIC) == baskets[basketIdx].magic) { //--- Identify positions that belong to the current basket
            if(!obj_Trade.PositionModify(ticket, 0, newTP)) { //--- Attempt to modify the position's take profit level
               Print("Basket ", baskets[basketIdx].basketId, ": Failed to modify TP for ticket ", ticket); //--- Log error if modifying TP fails
            }
         }
      }
      Print("Basket ", baskets[basketIdx].basketId, ": Breakeven = ", breakevenPrice, ", New TP = ", newTP); //--- Log the new breakeven and take profit levels
   }
}

//+------------------------------------------------------------------+
//--- Calculate Weighted Breakeven Price for a Basket
//+------------------------------------------------------------------+
double CalculateBreakevenPrice(int basketId) {
   double weightedSum = 0.0; //--- Initialize sum for weighted prices
   double totalLots = 0.0;   //--- Initialize sum for total lot sizes
   for(int i = 0; i < PositionsTotal(); i++) { //--- Loop over all open positions
      ulong ticket = PositionGetTicket(i); //--- Retrieve the ticket for the current position
      if(PositionSelectByTicket(ticket) && PositionGetString(POSITION_SYMBOL) == _Symbol && 
         StringFind(PositionGetString(POSITION_COMMENT), "Basket_" + IntegerToString(basketId)) >= 0) { //--- Check if the position belongs to the specified basket
         double lot = PositionGetDouble(POSITION_VOLUME); //--- Get the lot size of the position
         double openPrice = PositionGetDouble(POSITION_PRICE_OPEN); //--- Get the open price of the position
         weightedSum += openPrice * lot; //--- Add the weighted price to the sum
         totalLots += lot; //--- Add the lot size to the total lots
      }
   }
   return (totalLots > 0) ? (weightedSum / totalLots) : 0; //--- Return the weighted average price (breakeven) or 0 if no positions found
}

//+------------------------------------------------------------------+
//--- Check Breakeven Close
//+------------------------------------------------------------------+
void CheckBreakevenClose(int basketIdx, double ask, double bid) {
   double breakevenPrice = CalculateBreakevenPrice(baskets[basketIdx].basketId); //--- Calculate the breakeven price for the basket
   if(baskets[basketIdx].direction == POSITION_TYPE_BUY) {
      if(bid >= breakevenPrice + (inpBreakevenPts * _Point)) { //--- Check if the bid price exceeds breakeven plus threshold for buy positions
         Print("Basket ", baskets[basketIdx].basketId, ": Closing BUY positions at breakeven + points"); //--- Log that breakeven condition is met for closing positions
         CloseBasketPositions(baskets[basketIdx].basketId); //--- Close all positions for the basket
      }
   } else if(baskets[basketIdx].direction == POSITION_TYPE_SELL) {
      if(ask <= breakevenPrice - (inpBreakevenPts * _Point)) { //--- Check if the ask price is below breakeven minus threshold for sell positions
         Print("Basket ", baskets[basketIdx].basketId, ": Closing SELL positions at breakeven + points"); //--- Log that breakeven condition is met for closing positions
         CloseBasketPositions(baskets[basketIdx].basketId); //--- Close all positions for the basket
      }
   }
}

//+------------------------------------------------------------------+
//--- Close All Positions in a Basket
//+------------------------------------------------------------------+
void CloseBasketPositions(int basketId) {
   for(int i = PositionsTotal() - 1; i >= 0; i--) { //--- Loop backwards through all open positions
      ulong ticket = PositionGetTicket(i); //--- Retrieve the ticket of the current position
      if(PositionSelectByTicket(ticket) && 
         StringFind(PositionGetString(POSITION_COMMENT), "Basket_" + IntegerToString(basketId)) >= 0) { //--- Identify if the position belongs to the specified basket
         if(obj_Trade.PositionClose(ticket)) { //--- Attempt to close the position
            Print("Basket ", basketId, ": Closed position ticket ", ticket); //--- Log the successful closure of the position
         }
      }
   }
}

//+------------------------------------------------------------------+
//--- Count Positions in a Basket
//+------------------------------------------------------------------+
int CountBasketPositions(int basketId) {
   int count = 0; //--- Initialize the counter for positions in the basket
   for(int i = 0; i < PositionsTotal(); i++) { //--- Loop through all open positions
      ulong ticket = PositionGetTicket(i); //--- Retrieve the ticket for the current position
      if(PositionSelectByTicket(ticket) && 
         StringFind(PositionGetString(POSITION_COMMENT), "Basket_" + IntegerToString(basketId)) >= 0) { //--- Check if the position belongs to the specified basket
         count++; //--- Increment the counter if a matching position is found
      }
   }
   return count; //--- Return the total number of positions in the basket
}

//+------------------------------------------------------------------+
//--- Generate Position Comment
//+------------------------------------------------------------------+
string GetPositionComment(int basketId, bool isInitial) {
   return StringFormat("Basket_%d_%s", basketId, isInitial ? "Initial" : "Grid"); //--- Generate a standardized comment string for a position indicating basket ID and trade type
}

//+------------------------------------------------------------------+
//--- Check and Close Profit Targets (for CLOSE_BY_PROFIT mode)
//+------------------------------------------------------------------+
void CheckAndCloseProfitTargets() {
   for(int i = 0; i < ArraySize(baskets); i++) { //--- Loop through each active basket
      int posCount = CountBasketPositions(baskets[i].basketId); //--- Count how many positions belong to the current basket
      if(posCount <= 1) continue; //--- Skip baskets with only one position as profit target checks apply to multiple positions
      double totalProfit = 0; //--- Initialize the total profit accumulator for the basket
      for(int j = PositionsTotal() - 1; j >= 0; j--) { //--- Loop through all open positions to sum their profits
         ulong ticket = PositionGetTicket(j); //--- Get the ticket for the current position
         if(PositionSelectByTicket(ticket) && 
            StringFind(PositionGetString(POSITION_COMMENT), "Basket_" + IntegerToString(baskets[i].basketId)) >= 0) { //--- Check if the position is part of the current basket
            totalProfit += PositionGetDouble(POSITION_PROFIT); //--- Add the position's profit to the basket's total profit
         }
      }
      if(totalProfit >= profitTotal_inCurrency) { //--- Check if the accumulated profit meets or exceeds the profit target
         Print("Basket ", baskets[i].basketId, ": Profit target reached (", totalProfit, ")"); //--- Log that the profit target has been reached for the basket
         CloseBasketPositions(baskets[i].basketId); //--- Close all positions in the basket to secure the profits
      }
   }
}

//+------------------------------------------------------------------+
//--- Update Moving Average
//+------------------------------------------------------------------+
void UpdateMovingAverage() {
   if(CopyBuffer(handle, 0, 1, 3, maData) < 0) { //--- Copy the latest 3 values from the Moving Average indicator buffer into the maData array
      Print("Error: Unable to update Moving Average data."); //--- Log an error if copying the indicator data fails
   }
}

//+------------------------------------------------------------------+
//--- Check for New Bar
//+------------------------------------------------------------------+
bool IsNewBar() {
   int bars = iBars(_Symbol, _Period); //--- Get the current number of bars on the chart for the symbol and period
   if(bars > totalBars) { //--- Compare the current number of bars with the previously stored total
      totalBars = bars; //--- Update the stored bar count to the new value
      return true; //--- Return true to indicate a new bar has formed
   }
   return false; //--- Return false if no new bar has been detected
}
