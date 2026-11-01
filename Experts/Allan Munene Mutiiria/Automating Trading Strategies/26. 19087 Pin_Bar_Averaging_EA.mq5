//+------------------------------------------------------------------+
//|                                      a. Pin Bar Averaging EA.mq5 |
//|                           Copyright 2025, Allan Munene Mutiiria. |
//|                                   https://t.me/Forex_Algo_Trader |
//+------------------------------------------------------------------+
#property copyright   "Copyright 2025, Allan Munene Mutiiria."
#property link        "https://t.me/Forex_Algo_Trader"
#property version     "1.00"
#property strict

#include <Trade\Trade.mqh>                         //--- Include Trade library for trading operations
CTrade obj_Trade;                                  //--- Instantiate trade object

//+------------------------------------------------------------------+
//| Trading signal enumeration                                       |
//+------------------------------------------------------------------+
enum EnableTradingBySignal {                       //--- Define trading signal enum
   ENABLED  = 1,                                   // Enable trading signals
   DISABLED = 0                                    // Disable trading signals
};

//+------------------------------------------------------------------+
//| Input parameters                                                 |
//+------------------------------------------------------------------+
input bool   useSignalMode = DISABLED;             // Set signal mode (ENABLED/DISABLED)
input int    orderDistancePips = 50;               // Set order distance (pips)
input double lotMultiplier = 1;                    // Set lot size multiplier
input bool   useRSIFilter = false;                 // Enable RSI filter
input int    magicNumber = 123456789;              // Set magic number
input double initialLotSize = 0.01;                // Set initial lot size
input int    compoundPercent = 2;                  // Set compounding percent (0 for fixed lots)
input int    maxOrders = 5;                        // Set maximum orders
input double stopLossPips = 400;                   // Set stop loss (pips)
input double takeProfitPips = 200;                 // Set take profit (pips)
input bool   useAutoTakeProfit = true;             // Enable auto take profit
input bool   useTrailingStop = true;               // Enable trailing stop
input double trailingStartPips = 15;               // Set trailing start (pips)
input double breakevenPips = 10;                   // Set breakeven (pips)
input string orderComment = "Forex_Algo_Trader";   // Set order comment
input color  lineColor = clrBlue;                  // Set line color
input int    lineWidth = 2;                        // Set line width

//+------------------------------------------------------------------+
//| Global variables                                                 |
//+------------------------------------------------------------------+
bool   isTradingAllowed();                         //--- Declare trading allowed check
int    laterUseSL = 0;                         //--- Initialize for later use stop loss
double slBreakevenMinus = 0;                       //--- Initialize breakeven minus
double normalizedPoint;                            //--- Declare normalized point
ulong  currentTicket = 0;                          //--- Initialize current ticket
double buyCount, currentBuyLot, totalBuyLots;      //--- Declare buy metrics
double sellCount, currentSellLot, totalSellLots;   //--- Declare sell metrics
double totalSum, totalSwap;                        //--- Declare total sum and swap
double buyProfit, sellProfit, totalOperations;     //--- Declare profit and operations
double buyWeightedSum, sellWeightedSum;            //--- Declare weighted sums
double buyBreakEvenPrice, sellBreakEvenPrice;      //--- Declare breakeven prices
double minBuyLot, minSellLot;                      //--- Declare minimum lot sizes
double maxSellPrice, minBuyPrice;                  //--- Declare price extremes

//+------------------------------------------------------------------+
//| Expert initialization function                                    |
//+------------------------------------------------------------------+
int OnInit() {
   normalizedPoint = _Point;                       //--- Initialize point value
   if (_Digits == 5 || _Digits == 3) {             //--- Check for 5 or 3 digit symbols
      normalizedPoint *= 10;                       //--- Adjust point value
   }
   ChartSetInteger(0, CHART_SHOW_GRID, false);     //--- Disable chart grid
   obj_Trade.SetExpertMagicNumber(magicNumber);    //--- Set magic number for trade object
   obj_Trade.SetTypeFilling(ORDER_FILLING_IOC);    //--- Set order filling type
   return(INIT_SUCCEEDED);                         //--- Return success
}

//+------------------------------------------------------------------+
//| Expert deinitialization function                                  |
//+------------------------------------------------------------------+
void OnDeinit(const int reason) {
   ObjectsDeleteAll(0);                            //--- Delete all chart objects
   ChartRedraw(0);                                 //--- Redraw chart
}

//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick() {
   Display_Info();                                 //--- Display dashboard information
   double setPointValue = normalizedPoint;         //--- Set point value for calculations
   if (useTrailingStop && trailingStartPips > 0 && breakevenPips < trailingStartPips) { //--- Check trailing stop conditions
      double averageBuyPrice = rata_price(ORDER_TYPE_BUY); //--- Calculate average buy price
      double trailingReference = 0;                //--- Initialize trailing reference
      for (int iTrade = 0; iTrade < PositionsTotal(); iTrade++) { //--- Iterate through positions
         ulong ticket = PositionGetTicket(iTrade); //--- Get position ticket
         if (ticket == 0) continue;                //--- Skip invalid tickets
         if (PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_BUY && PositionGetString(POSITION_SYMBOL) == Symbol() && PositionGetInteger(POSITION_MAGIC) == magicNumber) { //--- Check buy position
            if (useAutoTakeProfit) {               //--- Check auto take profit
               trailingReference = averageBuyPrice; //--- Use average buy price
            } else {                               //--- Use open price
               trailingReference = PositionGetDouble(POSITION_PRICE_OPEN); //--- Set open price
            }
            if (SymbolInfoDouble(_Symbol, SYMBOL_BID) - trailingReference > trailingStartPips * setPointValue) { //--- Check trailing condition
               if (SymbolInfoDouble(_Symbol, SYMBOL_BID) - ((trailingStartPips - breakevenPips) * setPointValue) > PositionGetDouble(POSITION_SL)) { //--- Check stop loss adjustment
                  obj_Trade.PositionModify(ticket, SymbolInfoDouble(_Symbol, SYMBOL_BID) - ((trailingStartPips - breakevenPips) * setPointValue), PositionGetDouble(POSITION_TP)); //--- Modify position
               }
            }
         }
      }
      double averageSellPrice = rata_price(ORDER_TYPE_SELL); //--- Calculate average sell price
      for (int iTrade2 = 0; iTrade2 < PositionsTotal(); iTrade2++) { //--- Iterate through positions
         ulong ticket2 = PositionGetTicket(iTrade2); //--- Get position ticket
         if (ticket2 == 0) continue;               //--- Skip invalid tickets
         if (PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_SELL && PositionGetString(POSITION_SYMBOL) == Symbol() && PositionGetInteger(POSITION_MAGIC) == magicNumber) { //--- Check sell position
            if (useAutoTakeProfit) {               //--- Check auto take profit
               trailingReference = averageSellPrice; //--- Use average sell price
            } else {                               //--- Use open price
               trailingReference = PositionGetDouble(POSITION_PRICE_OPEN); //--- Set open price
            }
            if (trailingReference - SymbolInfoDouble(_Symbol, SYMBOL_ASK) > trailingStartPips * setPointValue) { //--- Check trailing condition
               if (SymbolInfoDouble(_Symbol, SYMBOL_ASK) + ((trailingStartPips - breakevenPips) * setPointValue) < PositionGetDouble(POSITION_SL) || PositionGetDouble(POSITION_SL) == 0) { //--- Check stop loss adjustment
                  obj_Trade.PositionModify(ticket2, SymbolInfoDouble(_Symbol, SYMBOL_ASK) + ((trailingStartPips - breakevenPips) * setPointValue), PositionGetDouble(POSITION_TP)); //--- Modify position
               }
            }
         }
      }
   }
   static datetime previousBarTime = 0;           //--- Store previous bar time
   if (previousBarTime != iTime(Symbol(), PERIOD_CURRENT, 0)) { //--- Check new bar
      previousBarTime = iTime(Symbol(), PERIOD_CURRENT, 0); //--- Update previous bar time
      ChartRedraw(0);                             //--- Redraw chart
   } else {
      return;                                     //--- Exit if not new bar
   }
   if (iVolume(Symbol(), PERIOD_H4, 0) > iVolume(Symbol(), PERIOD_H4, 1)) return; //--- Exit if volume increased
   double supportResistanceLevel = NormalizeDouble(iClose(Symbol(), PERIOD_H4, 1), _Digits); //--- Get support/resistance level
   ObjectDelete(0, "level");                      //--- Delete existing level line
   MakeLine(supportResistanceLevel);              //--- Draw support/resistance line
   if (SymbolInfoInteger(Symbol(), SYMBOL_SPREAD) > 150) return; //--- Exit if spread too high
   int totalBuyPositions = 0;                     //--- Initialize buy positions count
   int totalSellPositions = 0;                    //--- Initialize sell positions count
   for (int i = 0; i < PositionsTotal(); i++) {   //--- Iterate through positions
      ulong ticket = PositionGetTicket(i);         //--- Get position ticket
      if (ticket == 0) continue;                  //--- Skip invalid tickets
      if (PositionGetString(POSITION_SYMBOL) != Symbol() || PositionGetInteger(POSITION_MAGIC) != magicNumber) continue; //--- Skip non-matching positions
      if (PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_BUY) { //--- Check buy position
         totalBuyPositions++;                     //--- Increment buy count
      }
      if (PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_SELL) { //--- Check sell position
         totalSellPositions++;                    //--- Increment sell count
      }
   }
   if (CheckMarketBuyOrders() < 70 && CheckMarketSellOrders() < 70) { //--- Check order limits
      if (supportResistanceLevel > iOpen(Symbol(), PERIOD_CURRENT, 0) && useSignalMode == DISABLED) { //--- Check buy condition
         if (IsBuyPinbar() && totalBuyPositions < maxOrders && (isTradingAllowed() || totalBuyPositions > 0)) { //--- Check buy pinbar and limits
            double buyStopLoss = NormalizeDouble(SymbolInfoDouble(_Symbol, SYMBOL_ASK) - stopLossPips * normalizedPoint, _Digits); //--- Calculate buy stop loss
            double buyTakeProfit = NormalizeDouble(SymbolInfoDouble(_Symbol, SYMBOL_ASK) + takeProfitPips * normalizedPoint, _Digits); //--- Calculate buy take profit
            if (AccountFreeMarginCheck(Symbol(), ORDER_TYPE_BUY, GetLots()) > 0) { //--- Check margin
               obj_Trade.PositionOpen(Symbol(), ORDER_TYPE_BUY, GetLots(), SymbolInfoDouble(_Symbol, SYMBOL_ASK), buyStopLoss, buyTakeProfit, orderComment); //--- Open buy position
               if (useAutoTakeProfit) {             //--- Check auto take profit
                  ModifyTP(ORDER_TYPE_BUY, rata_price(ORDER_TYPE_BUY) + takeProfitPips * normalizedPoint); //--- Modify take profit
               }
               CloseSell();                         //--- Close sell positions
            }
         }
      }
      if (supportResistanceLevel < iOpen(Symbol(), PERIOD_CURRENT, 0) && useSignalMode == DISABLED) { //--- Check sell condition
         if (IsSellPinbar() && totalSellPositions < maxOrders && (isTradingAllowed() || totalSellPositions > 0)) { //--- Check sell pinbar and limits
            double sellStopLoss = NormalizeDouble(SymbolInfoDouble(_Symbol, SYMBOL_BID) + stopLossPips * normalizedPoint, _Digits); //--- Calculate sell stop loss
            double sellTakeProfit = NormalizeDouble(SymbolInfoDouble(_Symbol, SYMBOL_BID) - takeProfitPips * normalizedPoint, _Digits); //--- Calculate sell take profit
            if (AccountFreeMarginCheck(Symbol(), ORDER_TYPE_SELL, GetLots()) > 0) { //--- Check margin
               obj_Trade.PositionOpen(Symbol(), ORDER_TYPE_SELL, GetLots(), SymbolInfoDouble(_Symbol, SYMBOL_BID), sellStopLoss, sellTakeProfit, orderComment); //--- Open sell position
               if (useAutoTakeProfit) {             //--- Check auto take profit
                  ModifyTP(ORDER_TYPE_SELL, rata_price(ORDER_TYPE_SELL) - takeProfitPips * normalizedPoint); //--- Modify take profit
               }
               CloseBuy();                          //--- Close buy positions
            }
         }
      }
   }
   if (CountTrades() == 0) {                      //--- Check no trades
      if (supportResistanceLevel > iOpen(Symbol(), PERIOD_CURRENT, 0) && useSignalMode == ENABLED) { //--- Check buy signal mode
         if (IsBuyPinbar() && CountTrades() < maxOrders) { //--- Check buy pinbar and limit
            obj_Trade.PositionOpen(Symbol(), ORDER_TYPE_BUY, GetLots(), SymbolInfoDouble(_Symbol, SYMBOL_ASK), SymbolInfoDouble(_Symbol, SYMBOL_ASK) - stopLossPips * normalizedPoint, SymbolInfoDouble(_Symbol, SYMBOL_ASK) + (takeProfitPips * normalizedPoint), orderComment); //--- Open buy position
         }
      }
   }
   if (CountTrades() == 0) {                      //--- Check no trades
      if (supportResistanceLevel < iOpen(Symbol(), PERIOD_CURRENT, 0) && useSignalMode == ENABLED) { //--- Check sell signal mode
         if (IsSellPinbar() && CountTrades() < maxOrders) { //--- Check sell pinbar and limit
            obj_Trade.PositionOpen(Symbol(), ORDER_TYPE_SELL, GetLots(), SymbolInfoDouble(_Symbol, SYMBOL_BID), SymbolInfoDouble(_Symbol, SYMBOL_BID) + stopLossPips * normalizedPoint, SymbolInfoDouble(_Symbol, SYMBOL_BID) - (takeProfitPips * normalizedPoint), orderComment); //--- Open sell position
         }
      }
   }
   if (useRSIFilter == true) {                    //--- Check RSI filter
      if (supportResistanceLevel > iOpen(Symbol(), PERIOD_CURRENT, 0) && useSignalMode == ENABLED) { //--- Check buy condition
         if (IsBuyPinbar() && sellCount > 0) {    //--- Check buy pinbar and sell positions
            CloseSell();                          //--- Close sell positions
         }
      }
      if (supportResistanceLevel < iOpen(Symbol(), PERIOD_CURRENT, 0) && useSignalMode == ENABLED) { //--- Check sell condition
         if (IsSellPinbar() && buyCount > 0) {    //--- Check sell pinbar and buy positions
            CloseBuy();                           //--- Close buy positions
         }
      }
   }
   if (useSignalMode == ENABLED && CountTradesBuy() >= 1 && CountTradesBuy() < maxOrders && useAutoTakeProfit == false) { //--- Check buy averaging
      addAveragingOrder();                        //--- Add buy averaging order
   }
   if (useSignalMode == ENABLED && CountTradesSell() >= 1 && CountTradesSell() < maxOrders && useAutoTakeProfit == false) { //--- Check sell averaging
      addAveragingOrder();                        //--- Add sell averaging order
   }
   if (useSignalMode == ENABLED && CountTradesBuy() >= 1 && CountTradesBuy() < maxOrders && useAutoTakeProfit == true) { //--- Check buy averaging with auto TP
      addAveragingOrderWithAutoTP();              //--- Add buy averaging order with auto TP
   }
   if (useSignalMode == ENABLED && CountTradesSell() >= 1 && CountTradesSell() < maxOrders && useAutoTakeProfit == true) { //--- Check sell averaging with auto TP
      addAveragingOrderWithAutoTP();              //--- Add sell averaging order with auto TP
   }
}

//+------------------------------------------------------------------+
//| Count total trades                                               |
//+------------------------------------------------------------------+
int CountTrades() {
   int positionCount = 0;                         //--- Initialize position count
   for (int trade = PositionsTotal() - 1; trade >= 0; trade--) { //--- Iterate through positions
      ulong ticket = PositionGetTicket(trade);    //--- Get position ticket
      if (ticket == 0) continue;                  //--- Skip invalid tickets
      if (PositionGetString(POSITION_SYMBOL) != Symbol() || PositionGetInteger(POSITION_MAGIC) != magicNumber) continue; //--- Skip non-matching positions
      if (PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_SELL || PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_BUY) { //--- Check trade type
         positionCount++;                         //--- Increment position count
      }
   }
   return(positionCount);                         //--- Return total count
}

//+------------------------------------------------------------------+
//| Count buy trades                                                 |
//+------------------------------------------------------------------+
int CountTradesBuy() {
   int buyPositionCount = 0;                      //--- Initialize buy position count
   for (int trade = PositionsTotal() - 1; trade >= 0; trade--) { //--- Iterate through positions
      ulong ticket = PositionGetTicket(trade);    //--- Get position ticket
      if (ticket == 0) continue;                  //--- Skip invalid tickets
      if (PositionGetString(POSITION_SYMBOL) != Symbol() || PositionGetInteger(POSITION_MAGIC) != magicNumber) continue; //--- Skip non-matching positions
      if (PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_BUY) { //--- Check buy position
         buyPositionCount++;                      //--- Increment buy count
      }
   }
   return(buyPositionCount);                      //--- Return buy count
}

//+------------------------------------------------------------------+
//| Count sell trades                                                |
//+------------------------------------------------------------------+
int CountTradesSell() {
   int sellPositionCount = 0;                     //--- Initialize sell position count
   for (int trade = PositionsTotal() - 1; trade >= 0; trade--) { //--- Iterate through positions
      ulong ticket = PositionGetTicket(trade);    //--- Get position ticket
      if (ticket == 0) continue;                  //--- Skip invalid tickets
      if (PositionGetString(POSITION_SYMBOL) != Symbol() || PositionGetInteger(POSITION_MAGIC) != magicNumber) continue; //--- Skip non-matching positions
      if (PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_SELL) { //--- Check sell position
         sellPositionCount++;                     //--- Increment sell count
      }
   }
   return(sellPositionCount);                     //--- Return sell count
}

//+------------------------------------------------------------------+
//| Add averaging order                                              |
//+------------------------------------------------------------------+
void addAveragingOrder() {
   int positionIndex = 0;                         //--- Initialize position index
   double lastOpenPrice = 0;                      //--- Initialize last open price
   double lastLotSize = 0;                        //--- Initialize last lot size
   bool isLastBuy = false;                        //--- Initialize buy flag
   int totalBuyPositions = 0;                     //--- Initialize buy positions count
   int totalSellPositions = 0;                    //--- Initialize sell positions count
   long currentSpread = SymbolInfoInteger(Symbol(), SYMBOL_SPREAD); //--- Get current spread
   double supportResistanceLevel = iClose(Symbol(), PERIOD_H4, 1); //--- Get support/resistance level
   for (positionIndex = 0; positionIndex < PositionsTotal(); positionIndex++) { //--- Iterate through positions
      ulong ticket = PositionGetTicket(positionIndex); //--- Get position ticket
      if (ticket == 0) continue;                  //--- Skip invalid tickets
      if (PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_BUY && PositionGetString(POSITION_SYMBOL) == Symbol() && PositionGetInteger(POSITION_MAGIC) == magicNumber) { //--- Check buy position
         if (lastOpenPrice == 0) {                //--- Check initial price
            lastOpenPrice = PositionGetDouble(POSITION_PRICE_OPEN); //--- Set initial price
         }
         if (lastOpenPrice > PositionGetDouble(POSITION_PRICE_OPEN)) { //--- Check lower price
            lastOpenPrice = PositionGetDouble(POSITION_PRICE_OPEN); //--- Update last price
         }
         if (lastLotSize < PositionGetDouble(POSITION_VOLUME)) { //--- Check larger lot
            lastLotSize = PositionGetDouble(POSITION_VOLUME); //--- Update lot size
         }
         isLastBuy = true;                        //--- Set buy flag
         totalBuyPositions++;                     //--- Increment buy count
      }
      if (PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_SELL && PositionGetString(POSITION_SYMBOL) == Symbol() && PositionGetInteger(POSITION_MAGIC) == magicNumber) { //--- Check sell position
         if (lastOpenPrice == 0) {                //--- Check initial price
            lastOpenPrice = PositionGetDouble(POSITION_PRICE_OPEN); //--- Set initial price
         }
         if (lastOpenPrice < PositionGetDouble(POSITION_PRICE_OPEN)) { //--- Check higher price
            lastOpenPrice = PositionGetDouble(POSITION_PRICE_OPEN); //--- Update last price
         }
         if (lastLotSize < PositionGetDouble(POSITION_VOLUME)) { //--- Check larger lot
            lastLotSize = PositionGetDouble(POSITION_VOLUME); //--- Update lot size
         }
         isLastBuy = false;                       //--- Clear buy flag
         totalSellPositions++;                    //--- Increment sell count
      }
   }
   if (isLastBuy) {                               //--- Check buy position
      if (supportResistanceLevel > iOpen(Symbol(), PERIOD_CURRENT, 0)) { //--- Check buy condition
         if (IsBuyPinbar() && SymbolInfoDouble(_Symbol, SYMBOL_BID) <= lastOpenPrice - (orderDistancePips * _Point)) { //--- Check buy pinbar and distance
            obj_Trade.PositionOpen(Symbol(), ORDER_TYPE_BUY, NormalizeDouble((lastLotSize * lotMultiplier), fnGetLotDigit()), SymbolInfoDouble(_Symbol, SYMBOL_ASK), SymbolInfoDouble(_Symbol, SYMBOL_ASK) - stopLossPips * normalizedPoint, SymbolInfoDouble(_Symbol, SYMBOL_ASK) + (takeProfitPips * normalizedPoint), orderComment); //--- Open buy position
            isLastBuy = false;                    //--- Clear buy flag
            return;                               //--- Exit function
         }
      }
   } else if (!isLastBuy) {                       //--- Check sell position
      if (supportResistanceLevel < iOpen(Symbol(), PERIOD_CURRENT, 0)) { //--- Check sell condition
         if (IsSellPinbar() && SymbolInfoDouble(_Symbol, SYMBOL_ASK) >= lastOpenPrice + (orderDistancePips * _Point)) { //--- Check sell pinbar and distance
            obj_Trade.PositionOpen(Symbol(), ORDER_TYPE_SELL, NormalizeDouble((lastLotSize * lotMultiplier), fnGetLotDigit()), SymbolInfoDouble(_Symbol, SYMBOL_BID), SymbolInfoDouble(_Symbol, SYMBOL_BID) + stopLossPips * normalizedPoint, SymbolInfoDouble(_Symbol, SYMBOL_BID) - (takeProfitPips * normalizedPoint), orderComment); //--- Open sell position
            return;                               //--- Exit function
         }
      }
   }
}

//+------------------------------------------------------------------+
//| Add averaging order with auto take profit                        |
//+------------------------------------------------------------------+
void addAveragingOrderWithAutoTP() {
   int positionIndex = 0;                         //--- Initialize position index
   double lastOpenPrice = 0;                      //--- Initialize last open price
   double lastLotSize = 0;                        //--- Initialize last lot size
   bool isLastBuy = false;                        //--- Initialize buy flag
   int totalBuyPositions = 0;                     //--- Initialize buy positions count
   int totalSellPositions = 0;                    //--- Initialize sell positions count
   long currentSpread = SymbolInfoInteger(Symbol(), SYMBOL_SPREAD); //--- Get current spread
   double supportResistanceLevel = iClose(Symbol(), PERIOD_H4, 1); //--- Get support/resistance level
   for (positionIndex = 0; positionIndex < PositionsTotal(); positionIndex++) { //--- Iterate through positions
      ulong ticket = PositionGetTicket(positionIndex); //--- Get position ticket
      if (ticket == 0) continue;                  //--- Skip invalid tickets
      if (PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_BUY && PositionGetString(POSITION_SYMBOL) == Symbol() && PositionGetInteger(POSITION_MAGIC) == magicNumber) { //--- Check buy position
         if (lastOpenPrice == 0) {                //--- Check initial price
            lastOpenPrice = PositionGetDouble(POSITION_PRICE_OPEN); //--- Set initial price
         }
         if (lastOpenPrice > PositionGetDouble(POSITION_PRICE_OPEN)) { //--- Check lower price
            lastOpenPrice = PositionGetDouble(POSITION_PRICE_OPEN); //--- Update last price
         }
         if (lastLotSize < PositionGetDouble(POSITION_VOLUME)) { //--- Check larger lot
            lastLotSize = PositionGetDouble(POSITION_VOLUME); //--- Update lot size
         }
         isLastBuy = true;                        //--- Set buy flag
         totalBuyPositions++;                     //--- Increment buy count
      }
      if (PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_SELL && PositionGetString(POSITION_SYMBOL) == Symbol() && PositionGetInteger(POSITION_MAGIC) == magicNumber) { //--- Check sell position
         if (lastOpenPrice == 0) {                //--- Check initial price
            lastOpenPrice = PositionGetDouble(POSITION_PRICE_OPEN); //--- Set initial price
         }
         if (lastOpenPrice < PositionGetDouble(POSITION_PRICE_OPEN)) { //--- Check higher price
            lastOpenPrice = PositionGetDouble(POSITION_PRICE_OPEN); //--- Update last price
         }
         if (lastLotSize < PositionGetDouble(POSITION_VOLUME)) { //--- Check larger lot
            lastLotSize = PositionGetDouble(POSITION_VOLUME); //--- Update lot size
         }
         isLastBuy = false;                       //--- Clear buy flag
         totalSellPositions++;                    //--- Increment sell count
      }
   }
   if (isLastBuy) {                               //--- Check buy position
      if (supportResistanceLevel > iOpen(Symbol(), PERIOD_CURRENT, 0)) { //--- Check buy condition
         if (IsBuyPinbar() && SymbolInfoDouble(_Symbol, SYMBOL_BID) <= lastOpenPrice - (orderDistancePips * _Point)) { //--- Check buy pinbar and distance
            obj_Trade.PositionOpen(Symbol(), ORDER_TYPE_BUY, NormalizeDouble((lastLotSize * lotMultiplier), fnGetLotDigit()), SymbolInfoDouble(_Symbol, SYMBOL_ASK), 0, 0, orderComment); //--- Open buy position
            calculatePositionMetrics();            //--- Calculate position metrics
            updateStopLossTakeProfit();           //--- Update stop loss and take profit
            isLastBuy = false;                    //--- Clear buy flag
            return;                               //--- Exit function
         }
      }
   } else if (!isLastBuy) {                       //--- Check sell position
      if (supportResistanceLevel < iOpen(Symbol(), PERIOD_CURRENT, 0)) { //--- Check sell condition
         if (IsSellPinbar() && SymbolInfoDouble(_Symbol, SYMBOL_ASK) >= lastOpenPrice + (orderDistancePips * _Point)) { //--- Check sell pinbar and distance
            obj_Trade.PositionOpen(Symbol(), ORDER_TYPE_SELL, NormalizeDouble((lastLotSize * lotMultiplier), fnGetLotDigit()), SymbolInfoDouble(_Symbol, SYMBOL_BID), 0, 0, orderComment); //--- Open sell position
            calculatePositionMetrics();            //--- Calculate position metrics
            updateStopLossTakeProfit();           //--- Update stop loss and take profit
            return;                               //--- Exit function
         }
      }
   }
}

//+------------------------------------------------------------------+
//| Calculate position metrics                                       |
//+------------------------------------------------------------------+
void calculatePositionMetrics() {
   buyCount = 0;                                  //--- Reset buy count
   currentBuyLot = 0;                             //--- Reset current buy lot
   totalBuyLots = 0;                              //--- Reset total buy lots
   sellCount = 0;                                 //--- Reset sell count
   currentSellLot = 0;                            //--- Reset current sell lot
   totalSellLots = 0;                             //--- Reset total sell lots
   totalSum = 0;                                  //--- Reset total sum
   totalSwap = 0;                                 //--- Reset total swap
   buyProfit = 0;                                 //--- Reset buy profit
   sellProfit = 0;                                //--- Reset sell profit
   buyWeightedSum = 0;                            //--- Reset buy weighted sum
   sellWeightedSum = 0;                           //--- Reset sell weighted sum
   buyBreakEvenPrice = 0;                         //--- Reset buy breakeven price
   sellBreakEvenPrice = 0;                        //--- Reset sell breakeven price
   minBuyLot = 9999;                             //--- Initialize min buy lot
   minSellLot = 9999;                            //--- Initialize min sell lot
   maxSellPrice = 0;                              //--- Initialize max sell price
   minBuyPrice = 999999999;                      //--- Initialize min buy price
   for (int i = 0; i < PositionsTotal(); i++) {   //--- Iterate through positions
      ulong ticket = PositionGetTicket(i);         //--- Get position ticket
      if (ticket == 0) continue;                  //--- Skip invalid tickets
      if (PositionGetString(POSITION_SYMBOL) != Symbol()) continue; //--- Skip non-matching symbols
      if (PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_BUY) { //--- Check buy position
         buyCount++;                              //--- Increment buy count
         totalOperations++;                       //--- Increment total operations
         currentBuyLot = PositionGetDouble(POSITION_VOLUME); //--- Set current buy lot
         buyProfit += PositionGetDouble(POSITION_PROFIT); //--- Add buy profit
         totalBuyLots += PositionGetDouble(POSITION_VOLUME); //--- Add to total buy lots
         minBuyLot = MathMin(minBuyLot, PositionGetDouble(POSITION_VOLUME)); //--- Update min buy lot
         buyWeightedSum += PositionGetDouble(POSITION_VOLUME) * PositionGetDouble(POSITION_PRICE_OPEN); //--- Add weighted open price
         minBuyPrice = MathMin(minBuyPrice, PositionGetDouble(POSITION_PRICE_OPEN)); //--- Update min buy price
      }
      if (PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_SELL) { //--- Check sell position
         sellCount++;                             //--- Increment sell count
         totalOperations++;                       //--- Increment total operations
         currentSellLot = PositionGetDouble(POSITION_VOLUME); //--- Set current sell lot
         sellProfit += PositionGetDouble(POSITION_PROFIT); //--- Add sell profit
         totalSellLots += PositionGetDouble(POSITION_VOLUME); //--- Add to total sell lots
         minSellLot = MathMin(minSellLot, PositionGetDouble(POSITION_VOLUME)); //--- Update min sell lot
         sellWeightedSum += PositionGetDouble(POSITION_VOLUME) * PositionGetDouble(POSITION_PRICE_OPEN); //--- Add weighted open price
         maxSellPrice = MathMax(maxSellPrice, PositionGetDouble(POSITION_PRICE_OPEN)); //--- Update max sell price
      }
   }
   if (totalBuyLots > 0) {                        //--- Check buy lots
      buyBreakEvenPrice = buyWeightedSum / totalBuyLots; //--- Calculate buy breakeven
   }
   if (totalSellLots > 0) {                       //--- Check sell lots
      sellBreakEvenPrice = sellWeightedSum / totalSellLots; //--- Calculate sell breakeven
   }
}

//+------------------------------------------------------------------+
//| Normalize price                                                  |
//+------------------------------------------------------------------+
double NormalizePrice(double price) {
   return(NormalizeDouble(price, _Digits));       //--- Normalize price to symbol digits
}

//+------------------------------------------------------------------+
//| Update stop loss and take profit                                 |
//+------------------------------------------------------------------+
void updateStopLossTakeProfit() {
   for (int i = PositionsTotal() - 1; i >= 0; i--) { //--- Iterate through positions
      ulong ticket = PositionGetTicket(i);         //--- Get position ticket
      if (ticket == 0) continue;                  //--- Skip invalid tickets
      if (PositionGetString(POSITION_SYMBOL) != Symbol()) continue; //--- Skip non-matching symbols
      if (PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_BUY) { //--- Check buy position
         double buyTakeProfitLevel = (buyBreakEvenPrice + takeProfitPips * _Point) * (takeProfitPips > 0); //--- Calculate buy take profit
         double buyStopLossLevel = PositionGetDouble(POSITION_SL); //--- Get current stop loss
         if (slBreakevenMinus > 0) {              //--- Check breakeven adjustment
            buyStopLossLevel = (buyBreakEvenPrice - slBreakevenMinus * _Point); //--- Set breakeven stop loss
         }
         if (buyCount == 1) {                     //--- Check single buy position
            buyTakeProfitLevel = NormalizePrice(PositionGetDouble(POSITION_PRICE_OPEN) + takeProfitPips * _Point) * (takeProfitPips > 0); //--- Set take profit
            if (laterUseSL > 0) {             //--- Check unused stop loss
               buyStopLossLevel = (PositionGetDouble(POSITION_PRICE_OPEN) - laterUseSL * _Point); //--- Set stop loss
            }
         }
         buyTakeProfitLevel = NormalizePrice(buyTakeProfitLevel); //--- Normalize take profit
         buyStopLossLevel = NormalizePrice(buyStopLossLevel); //--- Normalize stop loss
         if (SymbolInfoDouble(_Symbol, SYMBOL_BID) >= buyTakeProfitLevel && buyTakeProfitLevel > 0) { //--- Check take profit hit
            obj_Trade.PositionClose(ticket);      //--- Close position
         }
         if (SymbolInfoDouble(_Symbol, SYMBOL_BID) <= buyStopLossLevel) { //--- Check stop loss hit
            obj_Trade.PositionClose(ticket);      //--- Close position
         }
         if (NormalizePrice(PositionGetDouble(POSITION_TP)) != buyTakeProfitLevel || NormalizePrice(PositionGetDouble(POSITION_SL)) != buyStopLossLevel) { //--- Check modification needed
            obj_Trade.PositionModify(ticket, buyStopLossLevel, buyTakeProfitLevel); //--- Modify position
         }
      }
      if (PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_SELL) { //--- Check sell position
         double sellTakeProfitLevel = (sellBreakEvenPrice - takeProfitPips * _Point) * (takeProfitPips > 0); //--- Calculate sell take profit
         double sellStopLossLevel = PositionGetDouble(POSITION_SL); //--- Get current stop loss
         if (slBreakevenMinus > 0) {              //--- Check breakeven adjustment
            sellStopLossLevel = (sellBreakEvenPrice + slBreakevenMinus * _Point); //--- Set breakeven stop loss
         }
         if (sellCount == 1) {                    //--- Check single sell position
            sellTakeProfitLevel = (PositionGetDouble(POSITION_PRICE_OPEN) - takeProfitPips * _Point) * (takeProfitPips > 0); //--- Set take profit
            if (laterUseSL > 0) {             //--- Check unused stop loss
               sellStopLossLevel = (PositionGetDouble(POSITION_PRICE_OPEN) + laterUseSL * _Point); //--- Set stop loss
            }
         }
         sellTakeProfitLevel = NormalizePrice(sellTakeProfitLevel); //--- Normalize take profit
         sellStopLossLevel = NormalizePrice(sellStopLossLevel); //--- Normalize stop loss
         if (SymbolInfoDouble(_Symbol, SYMBOL_ASK) <= sellTakeProfitLevel) { //--- Check take profit hit
            obj_Trade.PositionClose(ticket);      //--- Close position
         }
         if (SymbolInfoDouble(_Symbol, SYMBOL_ASK) >= sellStopLossLevel && sellStopLossLevel > 0) { //--- Check stop loss hit
            obj_Trade.PositionClose(ticket);      //--- Close position
         }
         if (NormalizePrice(PositionGetDouble(POSITION_TP)) != sellTakeProfitLevel || NormalizePrice(PositionGetDouble(POSITION_SL)) != sellStopLossLevel) { //--- Check modification needed
            obj_Trade.PositionModify(ticket, sellStopLossLevel, sellTakeProfitLevel); //--- Modify position
         }
      }
   }
}

//+------------------------------------------------------------------+
//| Get lot digit for normalization                                  |
//+------------------------------------------------------------------+
int fnGetLotDigit() {
   double lotStepValue = SymbolInfoDouble(Symbol(), SYMBOL_VOLUME_STEP); //--- Get lot step value
   if (lotStepValue == 1) return(0);              //--- Return 0 for step 1
   if (lotStepValue == 0.1) return(1);            //--- Return 1 for step 0.1
   if (lotStepValue == 0.01) return(2);           //--- Return 2 for step 0.01
   if (lotStepValue == 0.001) return(3);          //--- Return 3 for step 0.001
   if (lotStepValue == 0.0001) return(4);         //--- Return 4 for step 0.0001
   return(1);                                     //--- Default to 1
}

//+------------------------------------------------------------------+
//| Check buy orders for specific magic number                       |
//+------------------------------------------------------------------+
int CheckBuyOrders(int magic) {
   int buyOrderCount = 0;                         //--- Initialize buy order count
   for (int i = PositionsTotal() - 1; i >= 0; i--) { //--- Iterate through positions
      ulong ticket = PositionGetTicket(i);         //--- Get position ticket
      if (ticket == 0) continue;                  //--- Skip invalid tickets
      if (PositionGetInteger(POSITION_MAGIC) != magic) continue; //--- Skip non-matching magic
      if (PositionGetString(POSITION_SYMBOL) == Symbol()) { //--- Check symbol
         if (PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_BUY) { //--- Check buy position
            buyOrderCount++;                      //--- Increment buy count
            break;                                //--- Exit loop
         }
      }
   }
   return(buyOrderCount);                         //--- Return buy order count
}

//+------------------------------------------------------------------+
//| Check sell orders for specific magic number                      |
//+------------------------------------------------------------------+
int CheckSellOrders(int magic) {
   int sellOrderCount = 0;                        //--- Initialize sell order count
   for (int i = PositionsTotal() - 1; i >= 0; i--) { //--- Iterate through positions
      ulong ticket = PositionGetTicket(i);         //--- Get position ticket
      if (ticket == 0) continue;                  //--- Skip invalid tickets
      if (PositionGetInteger(POSITION_MAGIC) != magic) continue; //--- Skip non-matching magic
      if (PositionGetString(POSITION_SYMBOL) == Symbol()) { //--- Check symbol
         if (PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_SELL) { //--- Check sell position
            sellOrderCount++;                     //--- Increment sell count
            break;                                //--- Exit loop
         }
      }
   }
   return(sellOrderCount);                        //--- Return sell order count
}

//+------------------------------------------------------------------+
//| Check total buy orders                                           |
//+------------------------------------------------------------------+
int CheckTotalBuyOrders(int magic) {
   int totalBuyOrderCount = 0;                    //--- Initialize total buy order count
   for (int i = PositionsTotal() - 1; i >= 0; i--) { //--- Iterate through positions
      ulong ticket = PositionGetTicket(i);         //--- Get position ticket
      if (ticket == 0) continue;                  //--- Skip invalid tickets
      if (PositionGetInteger(POSITION_MAGIC) != magic) continue; //--- Skip non-matching magic
      if (PositionGetString(POSITION_SYMBOL) == Symbol()) { //--- Check symbol
         if (PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_BUY) { //--- Check buy position
            totalBuyOrderCount++;                 //--- Increment buy count
         }
      }
   }
   return(totalBuyOrderCount);                    //--- Return total buy count
}

//+------------------------------------------------------------------+
//| Check total sell orders                                          |
//+------------------------------------------------------------------+
int CheckTotalSellOrders(int magic) {
   int totalSellOrderCount = 0;                   //--- Initialize total sell order count
   for (int i = PositionsTotal() - 1; i >= 0; i--) { //--- Iterate through positions
      ulong ticket = PositionGetTicket(i);         //--- Get position ticket
      if (ticket == 0) continue;                  //--- Skip invalid tickets
      if (PositionGetInteger(POSITION_MAGIC) != magic) continue; //--- Skip non-matching magic
      if (PositionGetString(POSITION_SYMBOL) == Symbol()) { //--- Check symbol
         if (PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_SELL) { //--- Check sell position
            totalSellOrderCount++;                //--- Increment sell count
         }
      }
   }
   return(totalSellOrderCount);                   //--- Return total sell count
}

//+------------------------------------------------------------------+
//| Check market buy orders                                          |
//+------------------------------------------------------------------+
int CheckMarketBuyOrders() {
   int marketBuyCount = 0;                        //--- Initialize market buy count
   for (int i = PositionsTotal() - 1; i >= 0; i--) { //--- Iterate through positions
      ulong ticket = PositionGetTicket(i);         //--- Get position ticket
      if (ticket == 0) continue;                  //--- Skip invalid tickets
      if (PositionGetInteger(POSITION_MAGIC) != magicNumber) continue; //--- Skip non-matching magic
      if (PositionGetString(POSITION_SYMBOL) == Symbol()) { //--- Check symbol
         if (PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_BUY) { //--- Check buy position
            marketBuyCount++;                     //--- Increment buy count
         }
      }
   }
   return(marketBuyCount);                        //--- Return market buy count
}

//+------------------------------------------------------------------+
//| Check market sell orders                                         |
//+------------------------------------------------------------------+
int CheckMarketSellOrders() {
   int marketSellCount = 0;                       //--- Initialize market sell count
   for (int i = PositionsTotal() - 1; i >= 0; i--) { //--- Iterate through positions
      ulong ticket = PositionGetTicket(i);         //--- Get position ticket
      if (ticket == 0) continue;                  //--- Skip invalid tickets
      if (PositionGetInteger(POSITION_MAGIC) != magicNumber) continue; //--- Skip non-matching magic
      if (PositionGetString(POSITION_SYMBOL) == Symbol()) { //--- Check symbol
         if (PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_SELL) { //--- Check sell position
            marketSellCount++;                    //--- Increment sell count
         }
      }
   }
   return(marketSellCount);                       //--- Return market sell count
}

//+------------------------------------------------------------------+
//| Close all buy positions                                          |
//+------------------------------------------------------------------+
void CloseBuy() {
   while (CheckMarketBuyOrders() > 0) {           //--- Check buy orders exist
      for (int i = PositionsTotal() - 1; i >= 0; i--) { //--- Iterate through positions
         ulong ticket = PositionGetTicket(i);      //--- Get position ticket
         if (ticket == 0) continue;               //--- Skip invalid tickets
         if (PositionGetString(POSITION_SYMBOL) == Symbol() && PositionGetInteger(POSITION_MAGIC) == magicNumber) { //--- Check symbol and magic
            if (PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_BUY) { //--- Check buy position
               obj_Trade.PositionClose(ticket);   //--- Close position
            }
         }
      }
   }
}

//+------------------------------------------------------------------+
//| Close all sell positions                                         |
//+------------------------------------------------------------------+
void CloseSell() {
   while (CheckMarketSellOrders() > 0) {          //--- Check sell orders exist
      for (int i = PositionsTotal() - 1; i >= 0; i--) { //--- Iterate through positions
         ulong ticket = PositionGetTicket(i);      //--- Get position ticket
         if (ticket == 0) continue;               //--- Skip invalid tickets
         if (PositionGetString(POSITION_SYMBOL) == Symbol() && PositionGetInteger(POSITION_MAGIC) == magicNumber) { //--- Check symbol and magic
            if (PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_SELL) { //--- Check sell position
               obj_Trade.PositionClose(ticket);   //--- Close position
            }
         }
      }
   }
}

//+------------------------------------------------------------------+
//| Calculate lot size                                               |
//+------------------------------------------------------------------+
double GetLots() {
   double calculatedLot;                          //--- Initialize calculated lot
   double minLot = SymbolInfoDouble(Symbol(), SYMBOL_VOLUME_MIN); //--- Get minimum lot
   double maxLot = SymbolInfoDouble(Symbol(), SYMBOL_VOLUME_MAX); //--- Get maximum lot
   if (compoundPercent != 0) {                    //--- Check compounding
      calculatedLot = NormalizeDouble(AccountInfoDouble(ACCOUNT_BALANCE) * compoundPercent / 100 / 10000, fnGetLotDigit()); //--- Calculate compounded lot
      if (calculatedLot < minLot) calculatedLot = minLot; //--- Enforce minimum lot
      if (calculatedLot > maxLot) calculatedLot = maxLot; //--- Enforce maximum lot
   } else {
      calculatedLot = initialLotSize;             //--- Use fixed lot size
   }
   return(calculatedLot);                         //--- Return calculated lot
}

//+------------------------------------------------------------------+
//| Analyze candlestick patterns                                     |
//+------------------------------------------------------------------+
string CandleStick_Analyzer() {
   string candlePattern, comment1 = "", comment2 = "", comment3 = ""; //--- Initialize pattern strings
   string comment4 = "", comment5 = "", comment6 = "", comment7 = ""; //--- Initialize pattern strings
   string comment8 = "", comment9 = "";           //--- Initialize pattern strings
   if (BullishEngulfingExists()) comment1 = " Bullish Engulfing "; //--- Check bullish engulfing
   if (BullishHaramiExists()) comment2 = " Bullish Harami "; //--- Check bullish harami
   if (LongUpCandleExists()) comment3 = " Bullish LongUp "; //--- Check long up candle
   if (DojiAtBottomExists()) comment4 = " MorningStar Doji "; //--- Check morning star doji
   if (DojiAtTopExists()) comment5 = " EveningStar Doji "; //--- Check evening star doji
   if (BearishHaramiExists()) comment6 = " Bearish Harami "; //--- Check bearish harami
   if (BearishEngulfingExists()) comment7 = " Bearish Engulfing "; //--- Check bearish engulfing
   if (LongDownCandleExists()) comment8 = " Bearish LongDown "; //--- Check long down candle
   candlePattern = comment1 + comment2 + comment3 + comment4 + comment5 + comment6 + comment7 + comment8 + comment9; //--- Combine patterns
   return(candlePattern);                         //--- Return combined pattern
}

//+------------------------------------------------------------------+
//| Check bullish engulfing pattern                                  |
//+------------------------------------------------------------------+
bool BullishEngulfingExists() {
   if (iOpen(Symbol(), PERIOD_CURRENT, 1) <= iClose(Symbol(), PERIOD_CURRENT, 2) && iClose(Symbol(), PERIOD_CURRENT, 1) >= iOpen(Symbol(), PERIOD_CURRENT, 2) && iOpen(Symbol(), PERIOD_CURRENT, 2) - iClose(Symbol(), PERIOD_CURRENT, 2) >= 10 * _Point && iClose(Symbol(), PERIOD_CURRENT, 1) - iOpen(Symbol(), PERIOD_CURRENT, 1) >= 10 * _Point) { //--- Check bullish engulfing conditions
      return(true);                               //--- Return true
   }
   return(false);                                 //--- Return false
}

//+------------------------------------------------------------------+
//| Check bullish harami pattern                                     |
//+------------------------------------------------------------------+
bool BullishHaramiExists() {
   if (iClose(Symbol(), PERIOD_CURRENT, 2) < iOpen(Symbol(), PERIOD_CURRENT, 2) && iOpen(Symbol(), PERIOD_CURRENT, 1) < iClose(Symbol(), PERIOD_CURRENT, 1) && iOpen(Symbol(), PERIOD_CURRENT, 2) - iClose(Symbol(), PERIOD_CURRENT, 2) > MyiATR(Symbol(), PERIOD_CURRENT, 14, 2) && iOpen(Symbol(), PERIOD_CURRENT, 2) - iClose(Symbol(), PERIOD_CURRENT, 2) > 4 * (iClose(Symbol(), PERIOD_CURRENT, 1) - iOpen(Symbol(), PERIOD_CURRENT, 1))) { //--- Check bullish harami conditions
      return(true);                               //--- Return true
   }
   return(false);                                 //--- Return false
}

//+------------------------------------------------------------------+
//| Check doji at bottom pattern                                     |
//+------------------------------------------------------------------+
bool DojiAtBottomExists() {
   if (iOpen(Symbol(), PERIOD_CURRENT, 3) - iClose(Symbol(), PERIOD_CURRENT, 3) >= 8 * _Point && MathAbs(iClose(Symbol(), PERIOD_CURRENT, 2) - iOpen(Symbol(), PERIOD_CURRENT, 2)) <= 1 * _Point && iClose(Symbol(), PERIOD_CURRENT, 1) - iOpen(Symbol(), PERIOD_CURRENT, 1) >= 8 * _Point) { //--- Check doji at bottom conditions
      return(true);                               //--- Return true
   }
   return(false);                                 //--- Return false
}

//+------------------------------------------------------------------+
//| Check doji at top pattern                                        |
//+------------------------------------------------------------------+
bool DojiAtTopExists() {
   if (iClose(Symbol(), PERIOD_CURRENT, 3) - iOpen(Symbol(), PERIOD_CURRENT, 3) >= 8 * _Point && MathAbs(iClose(Symbol(), PERIOD_CURRENT, 2) - iOpen(Symbol(), PERIOD_CURRENT, 2)) <= 1 * _Point && iOpen(Symbol(), PERIOD_CURRENT, 1) - iClose(Symbol(), PERIOD_CURRENT, 1) >= 8 * _Point) { //--- Check doji at top conditions
      return(true);                               //--- Return true
   }
   return(false);                                 //--- Return false
}

//+------------------------------------------------------------------+
//| Check bearish harami pattern                                     |
//+------------------------------------------------------------------+
bool BearishHaramiExists() {
   if (iClose(Symbol(), PERIOD_CURRENT, 2) > iClose(Symbol(), PERIOD_CURRENT, 1) && iOpen(Symbol(), PERIOD_CURRENT, 2) < iOpen(Symbol(), PERIOD_CURRENT, 1) && iClose(Symbol(), PERIOD_CURRENT, 2) > iOpen(Symbol(), PERIOD_CURRENT, 2) && iOpen(Symbol(), PERIOD_CURRENT, 1) > iClose(Symbol(), PERIOD_CURRENT, 1) && iClose(Symbol(), PERIOD_CURRENT, 2) - iOpen(Symbol(), PERIOD_CURRENT, 2) > MyiATR(Symbol(), PERIOD_CURRENT, 14, 2) && iClose(Symbol(), PERIOD_CURRENT, 2) - iOpen(Symbol(), PERIOD_CURRENT, 2) > 4 * (iOpen(Symbol(), PERIOD_CURRENT, 1) - iClose(Symbol(), PERIOD_CURRENT, 1))) { //--- Check bearish harami conditions
      return(true);                               //--- Return true
   }
   return(false);                                 //--- Return false
}

//+------------------------------------------------------------------+
//| Check long up candle pattern                                     |
//+------------------------------------------------------------------+
bool LongUpCandleExists() {
   if (iOpen(Symbol(), PERIOD_CURRENT, 2) < iClose(Symbol(), PERIOD_CURRENT, 2) && iHigh(Symbol(), PERIOD_CURRENT, 2) - iLow(Symbol(), PERIOD_CURRENT, 2) >= 40 * _Point && iHigh(Symbol(), PERIOD_CURRENT, 2) - iLow(Symbol(), PERIOD_CURRENT, 2) > 2.5 * MyiATR(Symbol(), PERIOD_CURRENT, 14, 2) && iClose(Symbol(), PERIOD_CURRENT, 1) < iOpen(Symbol(), PERIOD_CURRENT, 1) && iOpen(Symbol(), PERIOD_CURRENT, 1) - iClose(Symbol(), PERIOD_CURRENT, 1) > 10 * _Point) { //--- Check long up candle conditions
      return(true);                               //--- Return true
   }
   return(false);                                 //--- Return false
}

//+------------------------------------------------------------------+
//| Check long down candle pattern                                   |
//+------------------------------------------------------------------+
bool LongDownCandleExists() {
   if (iOpen(Symbol(), PERIOD_CURRENT, 1) > iClose(Symbol(), PERIOD_CURRENT, 1) && iHigh(Symbol(), PERIOD_CURRENT, 1) - iLow(Symbol(), PERIOD_CURRENT, 1) >= 40 * _Point && iHigh(Symbol(), PERIOD_CURRENT, 1) - iLow(Symbol(), PERIOD_CURRENT, 1) > 2.5 * MyiATR(Symbol(), PERIOD_CURRENT, 14, 1)) { //--- Check long down candle conditions
      return(true);                               //--- Return true
   }
   return(false);                                 //--- Return false
}

//+------------------------------------------------------------------+
//| Check bearish engulfing pattern                                  |
//+------------------------------------------------------------------+
bool BearishEngulfingExists() {
   if (iOpen(Symbol(), PERIOD_CURRENT, 1) >= iClose(Symbol(), PERIOD_CURRENT, 2) && iClose(Symbol(), PERIOD_CURRENT, 1) <= iOpen(Symbol(), PERIOD_CURRENT, 2) && iOpen(Symbol(), PERIOD_CURRENT, 2) - iClose(Symbol(), PERIOD_CURRENT, 2) >= 10 * _Point && iClose(Symbol(), PERIOD_CURRENT, 1) - iOpen(Symbol(), PERIOD_CURRENT, 1) >= 10 * _Point) { //--- Check bearish engulfing conditions
      return(true);                               //--- Return true
   }
   return(false);                                 //--- Return false
}

//+------------------------------------------------------------------+
//| Draw support/resistance line                                     |
//+------------------------------------------------------------------+
void MakeLine(double price) {
   string name = "level";                         //--- Set line name
   if (ObjectFind(0, name) != -1) {               //--- Check if line exists
      ObjectMove(0, name, 0, iTime(Symbol(), PERIOD_CURRENT, 0), price); //--- Move line
      return;                                     //--- Exit function
   }
   ObjectCreate(0, name, OBJ_HLINE, 0, 0, price); //--- Create horizontal line
   ObjectSetInteger(0, name, OBJPROP_COLOR, lineColor); //--- Set color
   ObjectSetInteger(0, name, OBJPROP_STYLE, STYLE_SOLID); //--- Set style
   ObjectSetInteger(0, name, OBJPROP_WIDTH, lineWidth); //--- Set width
   ObjectSetInteger(0, name, OBJPROP_BACK, true); //--- Set to background
}

//+------------------------------------------------------------------+
//| Check buy pinbar                                                |
//+------------------------------------------------------------------+
bool IsBuyPinbar() {
   double currentOpen, currentClose, currentHigh, currentLow; //--- Declare current candle variables
   double previousHigh, previousLow, previousClose, previousOpen; //--- Declare previous candle variables
   double currentRange, previousRange, currentHigherPart, currentHigherPart1; //--- Declare range variables
   currentOpen = iOpen(Symbol(), PERIOD_CURRENT, 1); //--- Get current open
   currentClose = iClose(Symbol(), PERIOD_CURRENT, 1); //--- Get current close
   currentHigh = iHigh(Symbol(), PERIOD_CURRENT, 0); //--- Get current high
   currentLow = iLow(Symbol(), PERIOD_CURRENT, 1); //--- Get current low
   previousOpen = iOpen(Symbol(), PERIOD_CURRENT, 2); //--- Get previous open
   previousClose = iClose(Symbol(), PERIOD_CURRENT, 2); //--- Get previous close
   previousHigh = iHigh(Symbol(), PERIOD_CURRENT, 2); //--- Get previous high
   previousLow = iLow(Symbol(), PERIOD_CURRENT, 2); //--- Get previous low
   currentRange = currentHigh - currentLow;       //--- Calculate current range
   previousRange = previousHigh - previousLow;    //--- Calculate previous range
   currentHigherPart = currentHigh - currentRange * 0.4; //--- Calculate higher part
   currentHigherPart1 = currentHigh - currentRange * 0.4; //--- Calculate higher part
   double averageDailyRange = AveRange4();        //--- Get average daily range
   if ((currentClose > currentHigherPart1 && currentOpen > currentHigherPart) && //--- Check close/open in higher third
       (currentRange > averageDailyRange * 0.5) && //--- Check pinbar size
       (currentLow + currentRange * 0.25 < previousLow)) { //--- Check nose length
      double lowArray[3];                         //--- Declare low array
      CopyLow(Symbol(), PERIOD_CURRENT, 3, 3, lowArray); //--- Copy low prices
      int minIndex = ArrayMinimum(lowArray);      //--- Find minimum low index
      if (lowArray[minIndex] > currentLow) return(true); //--- Confirm buy pinbar
   }
   return(false);                                 //--- Return false
}

//+------------------------------------------------------------------+
//| Check sell pinbar                                               |
//+------------------------------------------------------------------+
bool IsSellPinbar() {
   double currentOpen, currentClose, currentHigh, currentLow; //--- Declare current candle variables
   double previousHigh, previousLow, previousClose, previousOpen; //--- Declare previous candle variables
   double currentRange, previousRange, currentLowerPart, currentLowerPart1; //--- Declare range variables
   currentOpen = iOpen(Symbol(), PERIOD_CURRENT, 1); //--- Get current open
   currentClose = iClose(Symbol(), PERIOD_CURRENT, 1); //--- Get current close
   currentHigh = iHigh(Symbol(), PERIOD_CURRENT, 1); //--- Get current high
   currentLow = iLow(Symbol(), PERIOD_CURRENT, 1); //--- Get current low
   previousOpen = iOpen(Symbol(), PERIOD_CURRENT, 2); //--- Get previous open
   previousClose = iClose(Symbol(), PERIOD_CURRENT, 2); //--- Get previous close
   previousHigh = iHigh(Symbol(), PERIOD_CURRENT, 2); //--- Get previous high
   previousLow = iLow(Symbol(), PERIOD_CURRENT, 2); //--- Get previous low
   currentRange = currentHigh - currentLow;       //--- Calculate current range
   previousRange = previousHigh - previousLow;    //--- Calculate previous range
   currentLowerPart = currentLow + currentRange * 0.4; //--- Calculate lower part
   currentLowerPart1 = currentLow + currentRange * 0.4; //--- Calculate lower part
   double averageDailyRange = AveRange4();        //--- Get average daily range
   if ((currentClose < currentLowerPart1 && currentOpen < currentLowerPart) && //--- Check close/open in lower third
       (currentRange > averageDailyRange * 0.5) && //--- Check pinbar size
       (currentHigh - currentRange * 0.25 > previousHigh)) { //--- Check nose length
      double highArray[3];                        //--- Declare high array
      CopyHigh(Symbol(), PERIOD_CURRENT, 3, 3, highArray); //--- Copy high prices
      int maxIndex = ArrayMaximum(highArray);     //--- Find maximum high index
      if (highArray[maxIndex] < currentHigh) return(true); //--- Confirm sell pinbar
   }
   return(false);                                 //--- Return false
}

//+------------------------------------------------------------------+
//| Calculate average range over 4 days                              |
//+------------------------------------------------------------------+
double AveRange4() {
   double rangeSum = 0;                           //--- Initialize range sum
   int count = 0;                                 //--- Initialize count
   int index = 1;                                 //--- Initialize index
   while (count < 4) {                            //--- Loop until 4 days
      MqlDateTime dateTime;                       //--- Declare datetime structure
      TimeToStruct(iTime(Symbol(), PERIOD_CURRENT, index), dateTime); //--- Convert time
      if (dateTime.day_of_week != 0) {            //--- Check non-Sunday
         rangeSum += iHigh(Symbol(), PERIOD_CURRENT, index) - iLow(Symbol(), PERIOD_CURRENT, index); //--- Add range
         count++;                                 //--- Increment count
      }
      index++;                                    //--- Increment index
   }
   return(rangeSum / 4.0);                        //--- Return average range
}

//+------------------------------------------------------------------+
//| Modify take profit for positions                                 |
//+------------------------------------------------------------------+
void ModifyTP(int orderType, double takeProfitLevel) {
   for (int positionIndex = PositionsTotal() - 1; positionIndex >= 0; positionIndex--) { //--- Iterate through positions
      ulong ticket = PositionGetTicket(positionIndex); //--- Get position ticket
      if (ticket == 0) continue;                  //--- Skip invalid tickets
      if (PositionGetString(POSITION_SYMBOL) == Symbol() && PositionGetInteger(POSITION_MAGIC) == magicNumber && PositionGetInteger(POSITION_TYPE) == orderType) { //--- Check position match
         if (NormalizeDouble(PositionGetDouble(POSITION_TP), _Digits) != NormalizeDouble(takeProfitLevel, _Digits)) { //--- Check take profit change
            obj_Trade.PositionModify(ticket, PositionGetDouble(POSITION_SL), NormalizeDouble(takeProfitLevel, _Digits)); //--- Modify take profit
         }
      }
   }
}

//+------------------------------------------------------------------+
//| Calculate average price for order type                           |
//+------------------------------------------------------------------+
double rata_price(int orderType) {
   double totalVolume = 0;                        //--- Initialize total volume
   double weightedOpenSum = 0;                    //--- Initialize weighted open sum
   double averagePrice = 0;                       //--- Initialize average price
   for (int positionIndex = 0; positionIndex < PositionsTotal(); positionIndex++) { //--- Iterate through positions
      ulong ticket = PositionGetTicket(positionIndex); //--- Get position ticket
      if (ticket == 0) continue;                  //--- Skip invalid tickets
      if (PositionGetString(POSITION_SYMBOL) == Symbol() && PositionGetInteger(POSITION_MAGIC) == magicNumber && (PositionGetInteger(POSITION_TYPE) == orderType)) { //--- Check position match
         totalVolume += PositionGetDouble(POSITION_VOLUME); //--- Add volume
         weightedOpenSum += (PositionGetDouble(POSITION_VOLUME) * PositionGetDouble(POSITION_PRICE_OPEN)); //--- Add weighted open
      }
   }
   if (totalVolume != 0) {                        //--- Check non-zero volume
      averagePrice = weightedOpenSum / totalVolume; //--- Calculate average price
   }
   return(averagePrice);                          //--- Return average price
}

//+------------------------------------------------------------------+
//| Display dashboard information                                    |
//+------------------------------------------------------------------+
void Display_Info() {
   buyCount = 0;                                  //--- Reset buy count
   currentBuyLot = 0;                             //--- Reset current buy lot
   totalBuyLots = 0;                              //--- Reset total buy lots
   sellCount = 0;                                 //--- Reset sell count
   currentSellLot = 0;                            //--- Reset current sell lot
   totalSellLots = 0;                             //--- Reset total sell lots
   totalSum = 0;                                  //--- Reset total sum
   totalSwap = 0;                                 //--- Reset total swap
   buyProfit = 0;                                 //--- Reset buy profit
   sellProfit = 0;                                //--- Reset sell profit
   buyWeightedSum = 0;                            //--- Reset buy weighted sum
   sellWeightedSum = 0;                           //--- Reset sell weighted sum
   buyBreakEvenPrice = 0;                         //--- Reset buy breakeven price
   sellBreakEvenPrice = 0;                        //--- Reset sell breakeven price
   minBuyLot = 9999;                             //--- Initialize min buy lot
   minSellLot = 9999;                            //--- Initialize min sell lot
   maxSellPrice = 0;                              //--- Initialize max sell price
   minBuyPrice = 999999999;                      //--- Initialize min buy price
   for (int i = 0; i < PositionsTotal(); i++) {   //--- Iterate through positions
      ulong ticket = PositionGetTicket(i);         //--- Get position ticket
      if (ticket == 0) continue;                  //--- Skip invalid tickets
      if (PositionGetString(POSITION_SYMBOL) != Symbol()) continue; //--- Skip non-matching symbols
      if (PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_BUY) { //--- Check buy position
         buyCount++;                              //--- Increment buy count
         totalOperations++;                       //--- Increment total operations
         currentBuyLot = PositionGetDouble(POSITION_VOLUME); //--- Set current buy lot
         buyProfit += PositionGetDouble(POSITION_PROFIT); //--- Add buy profit
         totalBuyLots += PositionGetDouble(POSITION_VOLUME); //--- Add to total buy lots
         minBuyLot = MathMin(minBuyLot, PositionGetDouble(POSITION_VOLUME)); //--- Update min buy lot
         buyWeightedSum += PositionGetDouble(POSITION_VOLUME) * PositionGetDouble(POSITION_PRICE_OPEN); //--- Add weighted open price
         minBuyPrice = MathMin(minBuyPrice, PositionGetDouble(POSITION_PRICE_OPEN)); //--- Update min buy price
      }
      if (PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_SELL) { //--- Check sell position
         sellCount++;                             //--- Increment sell count
         totalOperations++;                       //--- Increment total operations
         currentSellLot = PositionGetDouble(POSITION_VOLUME); //--- Set current sell lot
         sellProfit += PositionGetDouble(POSITION_PROFIT); //--- Add sell profit
         totalSellLots += PositionGetDouble(POSITION_VOLUME); //--- Add to total sell lots
         minSellLot = MathMin(minSellLot, PositionGetDouble(POSITION_VOLUME)); //--- Update min sell lot
         sellWeightedSum += PositionGetDouble(POSITION_VOLUME) * PositionGetDouble(POSITION_PRICE_OPEN); //--- Add weighted open price
         maxSellPrice = MathMax(maxSellPrice, PositionGetDouble(POSITION_PRICE_OPEN)); //--- Update max sell price
      }
   }
   if (totalBuyLots > 0) {                        //--- Check buy lots
      buyBreakEvenPrice = buyWeightedSum / totalBuyLots; //--- Calculate buy breakeven
   }
   if (totalSellLots > 0) {                       //--- Check sell lots
      sellBreakEvenPrice = sellWeightedSum / totalSellLots; //--- Calculate sell breakeven
   }
   int minutesRemaining, secondsRemaining;        //--- Declare time variables
   minutesRemaining = (int)(PeriodSeconds() - (TimeCurrent() - iTime(Symbol(), PERIOD_CURRENT, 0))); //--- Calculate remaining time
   secondsRemaining = minutesRemaining % 60;      //--- Calculate seconds
   minutesRemaining = minutesRemaining / 60;      //--- Calculate minutes
   long currentSpread = SymbolInfoInteger(Symbol(), SYMBOL_SPREAD); //--- Get current spread
   string spreadPrefix = "", minutesPrefix = "", secondsPrefix = ""; //--- Initialize prefixes
   if (currentSpread < 10) spreadPrefix = "..";   //--- Set spread prefix for single digit
   else if (currentSpread < 100) spreadPrefix = "."; //--- Set spread prefix for double digit
   if (minutesRemaining < 10) minutesPrefix = "0"; //--- Set minutes prefix
   if (secondsRemaining < 10) secondsPrefix = "0"; //--- Set seconds prefix
   int blinkingColorIndex;                        //--- Declare blinking color index
   color equityColor = clrGreen;                  //--- Initialize equity color
   if (AccountInfoDouble(ACCOUNT_EQUITY) - AccountInfoDouble(ACCOUNT_BALANCE) < 0.0) { //--- Check negative equity
      equityColor = clrRed;                       //--- Set equity color to red
   }
   color profitColor = (buyProfit + sellProfit >= 0) ? clrGreen : clrRed; //--- Set profit color
   MqlDateTime currentDateTime;                   //--- Declare datetime structure
   TimeToStruct(TimeCurrent(), currentDateTime);  //--- Convert current time
   if (currentDateTime.sec >= 0 && currentDateTime.sec < 10) { //--- Check first 10 seconds
      blinkingColorIndex = clrRed;                //--- Set red color
   }
   if (currentDateTime.sec >= 10 && currentDateTime.sec < 20) { //--- Check next 10 seconds
      blinkingColorIndex = clrOrange;             //--- Set orange color
   }
   if (currentDateTime.sec >= 20 && currentDateTime.sec < 30) { //--- Check next 10 seconds
      blinkingColorIndex = clrBlue;               //--- Set blue color
   }
   if (currentDateTime.sec >= 30 && currentDateTime.sec < 40) { //--- Check next 10 seconds
      blinkingColorIndex = clrDodgerBlue;         //--- Set dodger blue color
   }
   if (currentDateTime.sec >= 40 && currentDateTime.sec < 50) { //--- Check next 10 seconds
      blinkingColorIndex = clrYellow;             //--- Set yellow color
   }
   if (currentDateTime.sec >= 50 && currentDateTime.sec <= 59) { //--- Check last 10 seconds
      blinkingColorIndex = clrYellow;             //--- Set yellow color
   }
   if (ObjectFind(0, "DashboardBG") < 0) {        //--- Check dashboard background
      ObjectCreate(0, "DashboardBG", OBJ_RECTANGLE_LABEL, 0, 0, 0); //--- Create dashboard background
      ObjectSetInteger(0, "DashboardBG", OBJPROP_CORNER, 0); //--- Set corner
      ObjectSetInteger(0, "DashboardBG", OBJPROP_XDISTANCE, 100); //--- Set x distance
      ObjectSetInteger(0, "DashboardBG", OBJPROP_YDISTANCE, 20); //--- Set y distance
      ObjectSetInteger(0, "DashboardBG", OBJPROP_XSIZE, 260); //--- Set width
      ObjectSetInteger(0, "DashboardBG", OBJPROP_YSIZE, 300); //--- Set height
      ObjectSetInteger(0, "DashboardBG", OBJPROP_BGCOLOR, clrLightGray); //--- Set background color
      ObjectSetInteger(0, "DashboardBG", OBJPROP_BORDER_TYPE, BORDER_FLAT); //--- Set border type
      ObjectSetInteger(0, "DashboardBG", OBJPROP_COLOR, clrBlack); //--- Set border color
      ObjectSetInteger(0, "DashboardBG", OBJPROP_BACK, false); //--- Set to foreground
   }
   if (ObjectFind(0, "CLOSE ALL") < 0) {          //--- Check close all button
      ObjectCreate(0, "CLOSE ALL", OBJ_BUTTON, 0, 0, 0); //--- Create close all button
      ObjectSetInteger(0, "CLOSE ALL", OBJPROP_CORNER, 0); //--- Set corner
      ObjectSetInteger(0, "CLOSE ALL", OBJPROP_XDISTANCE, 110); //--- Set x distance
      ObjectSetInteger(0, "CLOSE ALL", OBJPROP_YDISTANCE, 280); //--- Set y distance
      ObjectSetInteger(0, "CLOSE ALL", OBJPROP_XSIZE, 240); //--- Set width
      ObjectSetInteger(0, "CLOSE ALL", OBJPROP_YSIZE, 25); //--- Set height
      ObjectSetString(0, "CLOSE ALL", OBJPROP_TEXT, "Close All Positions"); //--- Set button text
      ObjectSetInteger(0, "CLOSE ALL", OBJPROP_COLOR, clrWhite); //--- Set text color
      ObjectSetInteger(0, "CLOSE ALL", OBJPROP_BGCOLOR, clrRed); //--- Set background color
      ObjectSetInteger(0, "CLOSE ALL", OBJPROP_BORDER_COLOR, clrBlack); //--- Set border color
   }
   string headerText = "Pin Bar Averaging EA";    //--- Set header text
   LABEL("Header", "Impact", 20, 110, 20, clrNavy, 0, headerText); //--- Create header label
   string copyrightText = "Copyright 2025, Allan Munene Mutiiria"; //--- Set copyright text
   LABEL("Copyright", "Arial", 9, 110, 55, clrBlack, 0, copyrightText); //--- Create copyright label
   string linkText = "https://t.me/Forex_Algo_Trader"; //--- Set link text
   LABEL("Link", "Arial", 9, 110, 70, clrBlue, 0, linkText); //--- Create link label
   string accountHeader = "Account Information";  //--- Set account header
   LABEL("AccountHeader", "Arial Bold", 10, 110, 90, clrBlack, 0, accountHeader); //--- Create account header label
   string balanceText = "Balance: " + DoubleToString(AccountInfoDouble(ACCOUNT_BALANCE), 2); //--- Set balance text
   LABEL("Balance", "Arial", 9, 120, 105, clrBlack, 0, balanceText); //--- Create balance label
   string equityText = "Equity: " + DoubleToString(AccountInfoDouble(ACCOUNT_EQUITY), 2); //--- Set equity text
   LABEL("Equity", "Arial", 9, 120, 120, equityColor, 0, equityText); //--- Create equity label
   string marginText = "Free Margin: " + DoubleToString(AccountInfoDouble(ACCOUNT_MARGIN_FREE), 2); //--- Set margin text
   LABEL("Margin", "Arial", 9, 120, 135, clrBlack, 0, marginText); //--- Create margin label
   string profitText = "Open Profit: " + DoubleToString(buyProfit + sellProfit, 2); //--- Set profit text
   LABEL("Profit", "Arial", 9, 120, 150, profitColor, 0, profitText); //--- Create profit label
   string positionsText = "Buy Positions: " + IntegerToString((int)buyCount) + " Sell Positions: " + IntegerToString((int)sellCount); //--- Set positions text
   LABEL("Positions", "Arial", 9, 120, 165, clrBlack, 0, positionsText); //--- Create positions label
   string buyBEText = "Buy Break Even: " + (buyCount > 0 ? DoubleToString(buyBreakEvenPrice, _Digits) : "-"); //--- Set buy breakeven text
   LABEL("BuyBE", "Arial", 9, 120, 180, clrBlack, 0, buyBEText); //--- Create buy breakeven label
   string sellBEText = "Sell Break Even: " + (sellCount > 0 ? DoubleToString(sellBreakEvenPrice, _Digits) : "-"); //--- Set sell breakeven text
   LABEL("SellBE", "Arial", 9, 120, 195, clrBlack, 0, sellBEText); //--- Create sell breakeven label
   string spreadText = "Spread: " + spreadPrefix + IntegerToString((int)currentSpread) + " points"; //--- Set spread text
   LABEL("Spread", "Arial", 9, 120, 210, clrBlack, 0, spreadText); //--- Create spread label
   string timeText = "Time to next bar: " + minutesPrefix + IntegerToString(minutesRemaining) + ":" + secondsPrefix + IntegerToString(secondsRemaining); //--- Set time text
   LABEL("Time", "Arial", 9, 120, 225, clrBlack, 0, timeText); //--- Create time label
   string pinbarText;                             //--- Declare pinbar text
   if (IsBuyPinbar()) pinbarText = "Buy Pinbar";  //--- Check buy pinbar
   else if (IsSellPinbar()) pinbarText = "Sell Pinbar"; //--- Check sell pinbar
   else pinbarText = "None";                      //--- Set no pinbar
   LABEL("Pinbar", "Arial", 9, 120, 240, clrBlack, 0, "Pinbar Signal: " + pinbarText); //--- Create pinbar label
   string patternText = "Candle Pattern: " + CandleStick_Analyzer(); //--- Set candlestick pattern text
   LABEL("Pattern", "Arial", 9, 120, 255, clrBlack, 0, patternText); //--- Create pattern label
}

//+------------------------------------------------------------------+
//| Create dashboard label                                           |
//+------------------------------------------------------------------+
void LABEL(string labelName, string fontName, int fontSize, int xPosition, int yPosition, color textColor, int corner, string labelText) {
   if (ObjectFind(0, labelName) < 0) {            //--- Check if label exists
      ObjectCreate(0, labelName, OBJ_LABEL, 0, 0, 0); //--- Create label
   }
   ObjectSetString(0, labelName, OBJPROP_TEXT, labelText); //--- Set label text
   ObjectSetString(0, labelName, OBJPROP_FONT, fontName); //--- Set font
   ObjectSetInteger(0, labelName, OBJPROP_FONTSIZE, fontSize); //--- Set font size
   ObjectSetInteger(0, labelName, OBJPROP_COLOR, textColor); //--- Set text color
   ObjectSetInteger(0, labelName, OBJPROP_CORNER, corner); //--- Set corner
   ObjectSetInteger(0, labelName, OBJPROP_XDISTANCE, xPosition); //--- Set x position
   ObjectSetInteger(0, labelName, OBJPROP_YDISTANCE, yPosition); //--- Set y position
}

//+------------------------------------------------------------------+
//| Handle chart events                                              |
//+------------------------------------------------------------------+
void OnChartEvent(const int id, const long &lparam, const double &dparam, const string &sparam) {
   if (id == CHARTEVENT_OBJECT_CLICK) {           //--- Check object click event
      if (sparam == "CLOSE ALL") {                //--- Check close all button
         ObjectSetInteger(0, "CLOSE ALL", OBJPROP_STATE, false); //--- Reset button state
         for (int positionIndex = PositionsTotal() - 1; positionIndex >= 0; positionIndex--) { //--- Iterate through positions
            ulong ticket = PositionGetTicket(positionIndex); //--- Get position ticket
            if (ticket == 0) continue;            //--- Skip invalid tickets
            if (PositionGetString(POSITION_SYMBOL) == Symbol()) { //--- Check symbol
               obj_Trade.PositionClose(ticket);   //--- Close position
            }
         }
      }
   }
}

//+------------------------------------------------------------------+
//| Check account free margin                                        |
//+------------------------------------------------------------------+
double AccountFreeMarginCheck(string symbol, int orderType, double volume) {
   double marginRequired = 0.0;                   //--- Initialize margin required
   double price = orderType == ORDER_TYPE_BUY ? SymbolInfoDouble(symbol, SYMBOL_ASK) : SymbolInfoDouble(symbol, SYMBOL_BID); //--- Get price
   double calculatedMargin;                       //--- Declare calculated margin
   bool success = OrderCalcMargin(orderType == ORDER_TYPE_BUY ? ORDER_TYPE_BUY : ORDER_TYPE_SELL, symbol, volume, price, calculatedMargin); //--- Calculate margin
   if (success) marginRequired = calculatedMargin; //--- Set margin if successful
   return AccountInfoDouble(ACCOUNT_MARGIN_FREE) - marginRequired; //--- Return free margin
}

//+------------------------------------------------------------------+
//| Calculate ATR indicator                                          |
//+------------------------------------------------------------------+
double MyiATR(string symbol, ENUM_TIMEFRAMES timeframe, int period, int shift) {
   int handle = iATR(symbol, timeframe, period);   //--- Create ATR handle
   if (handle == INVALID_HANDLE) return 0;        //--- Check invalid handle
   double buffer[1];                              //--- Declare buffer
   if (CopyBuffer(handle, 0, shift, 1, buffer) != 1) buffer[0] = 0; //--- Copy ATR value
   IndicatorRelease(handle);                      //--- Release handle
   return buffer[0];                              //--- Return ATR value
}

//+------------------------------------------------------------------+
//| Check if trading is allowed                                      |
//+------------------------------------------------------------------+
bool isTradingAllowed() {
   bool isAllowed = false;                        //--- Initialize allowed flag
   return(true);                                  //--- Return true
}

//+------------------------------------------------------------------+