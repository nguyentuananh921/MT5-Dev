//+------------------------------------------------------------------+
//|                        Copyright 2025, Forex Algo-Trader, Allan. |
//|                                 "https://t.me/Forex_Algo_Trader" |
//+------------------------------------------------------------------+
#property copyright "Forex Algo-Trader, Allan"
#property link      "https://t.me/Forex_Algo_Trader"
#property version   "1.00"
#property description "This EA trades based on Grid Strategy"
#property strict

#include <Trade/Trade.mqh>                     //--- Include trading library
CTrade obj_Trade;                            //--- Trading object instance

//--- Closure Mode Enumeration and Inputs
enum ClosureMode {
   CLOSE_BY_PROFIT,      //--- Use total profit (in currency) to close positions
   CLOSE_BY_POINTS       //--- Use a points threshold from breakeven to close positions
};

input group "General EA Inputs"
input ClosureMode closureMode = CLOSE_BY_POINTS;    //Select closure mode

double breakevenPoints = 50 * _Point;                 //--- Points offset to add/subtract to/from breakeven

//--- Global Variables
double TakeProfit;                           //--- Current take profit level
double initialLotsize      = 0.1;            //--- Initial lot size for the first trade
double takeProfitPts       = 200 * _Point;    //--- Take profit distance in points
double profitTotal_inCurrency = 100;          //--- Profit target (in currency) to close positions

double gridSize;                             //--- Price level at which grid orders are triggered
double gridSize_Spacing   = 1000 * _Point;      //--- Grid spacing in points
double LotSize;                              //--- Current lot size (increased with grid orders)

bool isTradeAllowed      = true;              //--- Flag to allow trade on a new bar
int totalBars            = 0;                 //--- Count of bars seen so far
int handle;                                  //--- Handle for the Moving Average indicator
double maData[];                             //--- Array for Moving Average data

//--- Function Prototypes
void   CheckAndCloseProfitTargets();         //--- Closes all positions if total profit meets target
void   ExecuteInitialTrade(double ask, double bid); //--- Executes the initial BUY/SELL trade (initial positions)
void   ManageGridPositions(double ask, double bid); //--- Adds grid orders when market moves to grid level (grid positions)
void   UpdateMovingAverage();                //--- Updates MA indicator data from its buffer
bool   IsNewBar();                           //--- Checks if a new bar has formed
double CalculateWeightedBreakevenPrice();    //--- Calculates the weighted average entry price for positions
void   CheckBreakevenClose(double ask, double bid); //--- Closes positions if price meets breakeven+/- threshold
void   CloseAllPositions();                  //--- Closes all open positions

//+------------------------------------------------------------------+
//--- Expert initialization function
//+------------------------------------------------------------------+
int OnInit(){
   //--- Initialize the Moving Average indicator (Period: 21, SMA, Price: Close)
   handle = iMA(_Symbol, _Period, 21, 0, MODE_SMA, PRICE_CLOSE);
   if (handle == INVALID_HANDLE){
      Print("ERROR: UNABLE TO INITIALIZE THE INDICATOR. REVERTING NOW!");
      return (INIT_FAILED);
   }
   ArraySetAsSeries(maData, true);            //--- Ensure MA data array is in series order
   return(INIT_SUCCEEDED);
}

//+------------------------------------------------------------------+
//--- Expert deinitialization function
//+------------------------------------------------------------------+
void OnDeinit(const int reason){
   //--- No special deinitialization required.
}

//+------------------------------------------------------------------+
//--- Expert tick function
//+------------------------------------------------------------------+
void OnTick(){
   
   //--- Allow new trade signals on a new bar
   if(IsNewBar())
      isTradeAllowed = true;
   
   //--- Update the Moving Average data
   UpdateMovingAverage();
   
   //--- Reset lot size if no positions are open
   if(PositionsTotal() == 0)
      LotSize = initialLotsize;
   
   //--- Retrieve recent bar prices for trade signal logic
   double low1  = iLow(_Symbol, _Period, 1);
   double low2  = iLow(_Symbol, _Period, 2);
   double high1 = iHigh(_Symbol, _Period, 1);
   double high2 = iHigh(_Symbol, _Period, 2);
   
   //--- Get current Ask and Bid prices (normalized)
   double ask = NormalizeDouble(SymbolInfoDouble(_Symbol, SYMBOL_ASK), _Digits);
   double bid = NormalizeDouble(SymbolInfoDouble(_Symbol, SYMBOL_BID), _Digits);
   
   //--- If no positions are open and trading is allowed, check for an initial trade signal
   if(PositionsTotal() == 0 && isTradeAllowed){
      ExecuteInitialTrade(ask, bid);
   }
   
   //--- If positions exist, manage grid orders
   if(PositionsTotal() > 0){
      ManageGridPositions(ask, bid);
   }
   
   //--- Check if total profit meets the target (only used if closureMode == CLOSE_BY_PROFIT)
   if(closureMode == CLOSE_BY_PROFIT)
      CheckAndCloseProfitTargets();
   
   //--- If using CLOSE_BY_POINTS and more than one position exists (i.e. grid), check breakeven closure
   if(closureMode == CLOSE_BY_POINTS && PositionsTotal() > 1)
      CheckBreakevenClose(ask, bid);
}
  
//+------------------------------------------------------------------+
//--- Function: CheckAndCloseProfitTargets
//--- Description: Closes all positions if the combined profit meets or exceeds
//---              the user-defined profit target.
//+------------------------------------------------------------------+
void CheckAndCloseProfitTargets(){
   if(PositionsTotal() > 1){
      double totalProfit = 0;
      for(int i = PositionsTotal()-1; i >= 0; i--){
         ulong tkt = PositionGetTicket(i);
         if(PositionSelectByTicket(tkt))
            totalProfit += PositionGetDouble(POSITION_PROFIT);
      }
      if(totalProfit >= profitTotal_inCurrency){
         Print("Profit target reached (", totalProfit, "). Closing all positions.");
         CloseAllPositions();
      }
   }
}
  
//+------------------------------------------------------------------+
//--- Function: ExecuteInitialTrade
//--- Description: Executes the initial BUY or SELL trade based on MA criteria.
//---              (These are considered "initial positions.")
//+------------------------------------------------------------------+
void ExecuteInitialTrade(double ask, double bid){
   //--- BUY Signal: previous bar's low above MA and bar before that below MA
   if(iLow(_Symbol, _Period, 1) > maData[1] && iLow(_Symbol, _Period, 2) < maData[1]){
      gridSize = ask - gridSize_Spacing;     //--- Set grid trigger below current ask
      TakeProfit = ask + takeProfitPts;      //--- Set TP for BUY
      if(obj_Trade.Buy(LotSize, _Symbol, ask, 0, TakeProfit,"Initial Buy"))
         Print("Initial BUY order executed at ", ask, " with LotSize: ", LotSize);
      else
         Print("Initial BUY order failed at ", ask);
      isTradeAllowed = false;
   }
   //--- SELL Signal: previous bar's high below MA and bar before that above MA
   else if(iHigh(_Symbol, _Period, 1) < maData[1] && iHigh(_Symbol, _Period, 2) > maData[1]){
      gridSize = bid + gridSize_Spacing;     //--- Set grid trigger above current bid
      TakeProfit = bid - takeProfitPts;      //--- Set TP for SELL
      if(obj_Trade.Sell(LotSize, _Symbol, bid, 0, TakeProfit,"Initial Sell"))
         Print("Initial SELL order executed at ", bid, " with LotSize: ", LotSize);
      else
         Print("Initial SELL order failed at ", bid);
      isTradeAllowed = false;
   }
}
  
//+------------------------------------------------------------------+
//--- Function: ManageGridPositions
//--- Description: When an initial position exists, grid orders are added 
//---              if the market moves to the grid level. (These orders are 
//---              considered "grid positions.") The lot size is doubled 
//---              with each grid order.
//+------------------------------------------------------------------+
void ManageGridPositions(double ask, double bid){
   for(int i = PositionsTotal()-1; i >= 0; i--){
      ulong ticket = PositionGetTicket(i);
      if(PositionSelectByTicket(ticket)){
         int positionType = (int)PositionGetInteger(POSITION_TYPE);
         //--- Grid management for BUY positions
         if(positionType == POSITION_TYPE_BUY){
            if(ask <= gridSize){
               LotSize *= 2;              //--- Increase lot size for grid order
               if(obj_Trade.Buy(LotSize, _Symbol, ask, 0, TakeProfit,"Grid Position BUY"))
                  Print("Grid BUY order executed at ", ask, " with LotSize: ", LotSize);
               else
                  Print("Grid BUY order failed at ", ask);
               gridSize = ask - gridSize_Spacing; //--- Update grid trigger
            }
         }
         //--- Grid management for SELL positions
         else if(positionType == POSITION_TYPE_SELL){
            if(bid >= gridSize){
               LotSize *= 2;              //--- Increase lot size for grid order
               if(obj_Trade.Sell(LotSize, _Symbol, bid, 0, TakeProfit,"Grid Position SELL"))
                  Print("Grid SELL order executed at ", bid, " with LotSize: ", LotSize);
               else
                  Print("Grid SELL order failed at ", bid);
               gridSize = bid + gridSize_Spacing; //--- Update grid trigger
            }
         }
      }
   }
}
  
//+------------------------------------------------------------------+
//--- Function: CalculateWeightedBreakevenPrice
//--- Description: Calculates the weighted average entry price (breakeven)
//---              of all open positions (assumed to be in the same direction).
//+------------------------------------------------------------------+
double CalculateWeightedBreakevenPrice(){
   double totalCost = 0;
   double totalVolume = 0;
   int posType = -1;
   //--- Determine the type from the first position
   for(int i = 0; i < PositionsTotal(); i++){
      ulong ticket = PositionGetTicket(i);
      if(PositionSelectByTicket(ticket)){
         posType = (int)PositionGetInteger(POSITION_TYPE);
         break;
      }
   }
   //--- Sum the cost and volume for positions matching the type
   for(int i = 0; i < PositionsTotal(); i++){
      ulong ticket = PositionGetTicket(i);
      if(PositionSelectByTicket(ticket)){
         if(PositionGetInteger(POSITION_TYPE) == posType){
            double price = PositionGetDouble(POSITION_PRICE_OPEN);
            double volume = PositionGetDouble(POSITION_VOLUME);
            totalCost += price * volume;
            totalVolume += volume;
         }
      }
   }
   if(totalVolume > 0)
      return(totalCost / totalVolume);
   else
      return(0);
}
  
//+------------------------------------------------------------------+
//--- Function: CheckBreakevenClose
//--- Description: When using CLOSE_BY_POINTS and multiple positions exist,
//---              calculates the weighted breakeven price and checks if the
//---              current price has moved the specified points in a profitable
//---              direction relative to breakeven. If so, closes all positions.
//+------------------------------------------------------------------+
void CheckBreakevenClose(double ask, double bid){
   //--- Ensure we have more than one position (grid positions)
   if(PositionsTotal() <= 1)
      return;
      
   double weightedBreakeven = CalculateWeightedBreakevenPrice();
   int posType = -1;
   //--- Determine the trade type from one of the positions
   for(int i = 0; i < PositionsTotal(); i++){
      ulong ticket = PositionGetTicket(i);
      if(PositionSelectByTicket(ticket)){
         posType = (int)PositionGetInteger(POSITION_TYPE);
         break;
      }
   }
   if(posType == -1)
      return;
      
   //--- For BUY positions, profit when Bid >= breakeven + threshold
   if(posType == POSITION_TYPE_BUY){
      if(bid >= weightedBreakeven + breakevenPoints){
         Print("Closing BUY positions: Bid (", bid, ") >= Breakeven (", weightedBreakeven, ") + ", breakevenPoints);
         CloseAllPositions();
      }
   }
   //--- For SELL positions, profit when Ask <= breakeven - threshold
   else if(posType == POSITION_TYPE_SELL){
      if(ask <= weightedBreakeven - breakevenPoints){
         Print("Closing SELL positions: Ask (", ask, ") <= Breakeven (", weightedBreakeven, ") - ", breakevenPoints);
         CloseAllPositions();
      }
   }
}
  
//+------------------------------------------------------------------+
//--- Function: CloseAllPositions
//--- Description: Iterates through and closes all open positions.
//+------------------------------------------------------------------+
void CloseAllPositions(){
   for(int i = PositionsTotal()-1; i >= 0; i--){
      ulong posTkt = PositionGetTicket(i);
      if(PositionSelectByTicket(posTkt)){
         if(obj_Trade.PositionClose(posTkt))
            Print("Closed position ticket: ", posTkt);
         else
            Print("Failed to close position ticket: ", posTkt);
      }
   }
}
  
//+------------------------------------------------------------------+
//--- Function: UpdateMovingAverage
//--- Description: Copies the latest data from the MA indicator buffer.
//+------------------------------------------------------------------+
void UpdateMovingAverage(){
   if(CopyBuffer(handle, 0, 1, 3, maData) < 0)
      Print("Error: Unable to update Moving Average data.");
}
  
//+------------------------------------------------------------------+
//--- Function: IsNewBar
//--- Description: Checks if a new bar has been formed.
//+------------------------------------------------------------------+
bool IsNewBar(){
   int bars = iBars(_Symbol, _Period);
   if(bars > totalBars){
      totalBars = bars;
      return true;
   }
   return false;
}
