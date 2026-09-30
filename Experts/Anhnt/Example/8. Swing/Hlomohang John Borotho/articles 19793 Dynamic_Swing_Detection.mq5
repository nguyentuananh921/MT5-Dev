//+------------------------------------------------------------------+
//|                                      Dynamic Swing Detection.mq5 |
//|                        GIT under Copyright 2025, MetaQuotes Ltd. |
//|                     https://www.mql5.com/en/users/johnhlomohang/ |
//+------------------------------------------------------------------+
#property copyright "GIT under Copyright 2025, MetaQuotes Ltd."
#property link      "https://www.mql5.com/en/users/johnhlomohang/"
#property version   "1.00"
#include <Trade/Trade.mqh>

CTrade TradeManager;
MqlTick currentTick;

input group "General Trading Parameters"
input int     MinSwingBars = 7;          // Minimum bars for swing formation
input double  MinSwingDistance = 0.001;  // Minimum distance for swing (in points)
input bool    UseWickForTrade = false;   // Use wick or body for trade levels

input group "Trailing Stop Parameters"
input bool UseTrailingStop = true;              // Enable trailing stops
input int BreakEvenAtPips = 500;                // Move to breakeven at this profit (pips) 
input int TrailStartAtPips = 600;               // Start trailing at this profit (pips)
input int TrailStepPips = 100;                  // Trail by this many pips 

//+------------------------------------------------------------------+
//| Swing detection structure                                        |
//+------------------------------------------------------------------+
struct SwingPoint
{
    int       barIndex;
    double    price;
    datetime  time;
    bool      isHigh;
    double    bodyHigh;
    double    bodyLow;
};

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
{
    return(INIT_SUCCEEDED);
}

//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{
    // Clean up all objects on deinit
    ObjectsDeleteAll(0, -1, -1);
}

//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
{
    if(!isNewBar())
        return;
    
    // Detect swings and manage trading logic
    ManageTradingLogic();
    
    if(UseTrailingStop) ManageOpenTrades();
}

//+------------------------------------------------------------------+
//| Manage trading logic                                             |
//+------------------------------------------------------------------+
void ManageTradingLogic()
{
    static SwingPoint lastSwingLow = {-1, 0, 0, false, 0, 0};
    static SwingPoint lastSwingHigh = {-1, 0, 0, true, 0, 0};
    static bool lookingForHigh = false;
    static bool lookingForLow = false;
    
    // Detect current swings
    SwingPoint currentSwing;
    if(!DetectSwing(currentSwing))
        return;
    
    // Bullish scenario logic
    if(!lookingForHigh && !currentSwing.isHigh) // New swing low detected
    {
        lastSwingLow = currentSwing;
        lookingForHigh = true;
        lookingForLow = false;
        Print("Swing Low detected at: ", DoubleToString(currentSwing.price, _Digits), " Time: ", TimeToString(currentSwing.time));
        ExecuteTrade(ORDER_TYPE_BUY, "SwingLow_Buy");
        // Draw swing low
        string swingName = "SwingLow_" + IntegerToString(currentSwing.time);
        drawswing(swingName, currentSwing.time, currentSwing.price, 217, clrBlue, 1);
    }
    else if(lookingForHigh && currentSwing.isHigh) // Swing high after swing low
    {
        lastSwingHigh = currentSwing;
        lookingForHigh = false;
        Print("Swing High detected after Swing Low.");
        
        // Draw swing high
        string swingName = "SwingHigh_" + IntegerToString(currentSwing.time);
        drawswing(swingName, currentSwing.time, currentSwing.price, 218, clrRed, -1);
    }
    
    // Bearish scenario logic
    if(!lookingForLow && currentSwing.isHigh) // New swing high detected
    {
        lastSwingHigh = currentSwing;
        lookingForLow = true;
        lookingForHigh = false;
        Print("Swing High detected at: ", DoubleToString(currentSwing.price, _Digits), " Time: ", TimeToString(currentSwing.time));
        ExecuteTrade(ORDER_TYPE_SELL, "SwingHigh_Sell");
        // Draw swing high
        string swingName = "SwingHigh_" + IntegerToString(currentSwing.time);
        drawswing(swingName, currentSwing.time, currentSwing.price, 218, clrRed, -1);
    }
    else if(lookingForLow && !currentSwing.isHigh) // Swing low after swing high
    {
        lastSwingLow = currentSwing;
        lookingForLow = false;
        Print("Swing Low detected after Swing High.");
        
        // Draw swing low
        string swingName = "SwingLow_" + IntegerToString(currentSwing.time);
        drawswing(swingName, currentSwing.time, currentSwing.price, 217, clrBlue, 1);
    }
}

//+------------------------------------------------------------------+
//| Detect swing points dynamically                                  |
//+------------------------------------------------------------------+
bool DetectSwing(SwingPoint &swing)
{
    swing.barIndex = -1;
    
    int barsToCheck = MinSwingBars * 2 + 1;
    if(Bars(_Symbol, _Period) < barsToCheck) 
        return false;
    
    // Check multiple recent bars for swings
    for(int i = MinSwingBars; i <= MinSwingBars + 5; i++)
    {
        if(i >= Bars(_Symbol, _Period)) break;
        
        // Check for swing high
        if(IsSwingHigh(i))
        {
            swing.barIndex = i;
            swing.price = UseWickForTrade ? iHigh(_Symbol, _Period, i) : 
                          MathMax(iOpen(_Symbol, _Period, i), iClose(_Symbol, _Period, i));
            swing.time = iTime(_Symbol, _Period, i);
            swing.isHigh = true;
            swing.bodyHigh = MathMax(iOpen(_Symbol, _Period, i), iClose(_Symbol, _Period, i));
            swing.bodyLow = MathMin(iOpen(_Symbol, _Period, i), iClose(_Symbol, _Period, i));
            return true;
        }
        // Check for swing low
        else if(IsSwingLow(i))
        {
            swing.barIndex = i;
            swing.price = UseWickForTrade ? iLow(_Symbol, _Period, i) : 
                          MathMin(iOpen(_Symbol, _Period, i), iClose(_Symbol, _Period, i));
            swing.time = iTime(_Symbol, _Period, i);
            swing.isHigh = false;
            swing.bodyHigh = MathMax(iOpen(_Symbol, _Period, i), iClose(_Symbol, _Period, i));
            swing.bodyLow = MathMin(iOpen(_Symbol, _Period, i), iClose(_Symbol, _Period, i));
            return true;
        }
    }
    
    return false;
}

//+------------------------------------------------------------------+
//| Check if bar is swing high                                       |
//+------------------------------------------------------------------+
bool IsSwingHigh(int barIndex)
{
    if(barIndex < MinSwingBars || barIndex >= Bars(_Symbol, _Period) - MinSwingBars)
        return false;
        
    double currentHigh = iHigh(_Symbol, _Period, barIndex);
    
    // Check left side
    for(int i = 1; i <= MinSwingBars; i++)
    {
        double leftHigh = iHigh(_Symbol, _Period, barIndex + i);
        if(leftHigh >= currentHigh - MinSwingDistance * _Point)
            return false;
    }
    
    // Check right side
    for(int i = 1; i <= MinSwingBars; i++)
    {
        double rightHigh = iHigh(_Symbol, _Period, barIndex - i);
        if(rightHigh >= currentHigh - MinSwingDistance * _Point)
            return false;
    }
    
    return true;
}

//+------------------------------------------------------------------+
//| Check if bar is swing low                                        |
//+------------------------------------------------------------------+
bool IsSwingLow(int barIndex)
{
    if(barIndex < MinSwingBars || barIndex >= Bars(_Symbol, _Period) - MinSwingBars)
        return false;
        
    double currentLow = iLow(_Symbol, _Period, barIndex);
    
    // Check left side
    for(int i = 1; i <= MinSwingBars; i++)
    {
        double leftLow = iLow(_Symbol, _Period, barIndex + i);
        if(leftLow <= currentLow + MinSwingDistance * _Point)
            return false;
    }
    
    // Check right side
    for(int i = 1; i <= MinSwingBars; i++)
    {
        double rightLow = iLow(_Symbol, _Period, barIndex - i);
        if(rightLow <= currentLow + MinSwingDistance * _Point)
            return false;
    }
    
    return true;
}

//+------------------------------------------------------------------+
//| Draw swing point on chart                                        |
//+------------------------------------------------------------------+
void drawswing(string objName, datetime time, double price, int arrCode, color clr, int direction)
{
   if(ObjectFind(0, objName) < 0)
   {
      // Create arrow object
      if(!ObjectCreate(0, objName, OBJ_ARROW, 0, time, price))
      {
         Print("Error creating swing object: ", GetLastError());
         return;
      }
      
      ObjectSetInteger(0, objName, OBJPROP_ARROWCODE, arrCode);
      ObjectSetInteger(0, objName, OBJPROP_COLOR, clr);
      ObjectSetInteger(0, objName, OBJPROP_WIDTH, 3);
      ObjectSetInteger(0, objName, OBJPROP_BACK, false);
      
      if(direction > 0)
      {
         ObjectSetInteger(0, objName, OBJPROP_ANCHOR, ANCHOR_TOP);
      }
      else if(direction < 0)
      {
         ObjectSetInteger(0, objName, OBJPROP_ANCHOR, ANCHOR_BOTTOM);
      }
      
      // Create text label
      string textName = objName + "_Text";
      string text = DoubleToString(price, _Digits);
      
      if(ObjectCreate(0, textName, OBJ_TEXT, 0, time, price))
      {
         ObjectSetString(0, textName, OBJPROP_TEXT, text);
         ObjectSetInteger(0, textName, OBJPROP_COLOR, clr);
         ObjectSetInteger(0, textName, OBJPROP_FONTSIZE, 8);
         
         // Adjust text position based on direction
         double offset = (direction > 0) ? - (100 * _Point) : (100 * _Point);
         ObjectSetDouble(0, textName, OBJPROP_PRICE, price + offset);
      }
   }
}

//+------------------------------------------------------------------+
//| Helper functions                                                 |
//+------------------------------------------------------------------+
bool isNewBar()
{
   static datetime lastBar;
   datetime currentBar = iTime(_Symbol, _Period, 0);
   if(lastBar != currentBar)
   {
      lastBar = currentBar;
      return true;
   }
   return false;
}

//+------------------------------------------------------------------+
//| Execute trade with proper risk management                        |
//+------------------------------------------------------------------+
void ExecuteTrade(ENUM_ORDER_TYPE orderType, string comment)
{
   // Calculate position size based on risk
   double lotSize = 0.03;
   if(lotSize <= 0)
   {
      Print("Failed to calculate position size");
      return;
   }
   
   // Get current tick data
   if(!SymbolInfoTick(_Symbol, currentTick))
   {
      Print("Failed to get current tick data. Error: ", GetLastError());
      return;
   }
   
   // Define stop levels in points (adjust these values as needed)
   int stopLossPoints = 600;
   int takeProfitPoints = 2555;
   
   // Calculate stop loss and take profit prices
   double stopLoss = 0.0, takeProfit = 0.0;
   double point = SymbolInfoDouble(_Symbol, SYMBOL_POINT);
   int digits = (int)SymbolInfoInteger(_Symbol, SYMBOL_DIGITS);
   
   if(orderType == ORDER_TYPE_BUY)
   {
      stopLoss = NormalizeDouble(currentTick.bid - (stopLossPoints * point), digits);
      takeProfit = NormalizeDouble(currentTick.ask + (takeProfitPoints * point), digits);
   }
   else if(orderType == ORDER_TYPE_SELL)
   {
      stopLoss = NormalizeDouble(currentTick.ask + (stopLossPoints * point), digits);
      takeProfit = NormalizeDouble(currentTick.bid - (takeProfitPoints * point), digits);
   }
   
   // Validate stop levels before sending the trade
   if(!ValidateStopLevels(orderType, currentTick.ask, currentTick.bid, stopLoss, takeProfit))
   {
      Print("Invalid stop levels. Trade not executed.");
      return;
   }
   
   // Execute trade
   bool requestSent;
   if(orderType == ORDER_TYPE_BUY)
   {
      requestSent = TradeManager.Buy(lotSize, _Symbol, 0, stopLoss, takeProfit, comment);
   }
   else
   {
      requestSent = TradeManager.Sell(lotSize, _Symbol, 0, stopLoss, takeProfit, comment);
   }
   
   // Check if the request was sent successfully and then check the server's result
   if(requestSent)
   {
      // Check the server's return code from the trade operation
      uint result = TradeManager.ResultRetcode();
      if(result == TRADE_RETCODE_DONE || result == TRADE_RETCODE_DONE_PARTIAL)
      {
         Print("Trade executed successfully. Ticket: ", TradeManager.ResultDeal());
      }
      else if(result == TRADE_RETCODE_REQUOTE || result == TRADE_RETCODE_TIMEOUT || result == TRADE_RETCODE_PRICE_CHANGED)
      {
         Print("Trade failed due to price change. Consider implementing a retry logic. Retcode: ", TradeManager.ResultRetcodeDescription());
         // Here you can add logic to re-check prices and re-send the request
      }
      else
      {
         Print("Trade execution failed. Retcode: ", TradeManager.ResultRetcodeDescription());
         // Handle other specific errors like TRADE_RETCODE_INVALID_STOPS (10016)
      }
   }
   else
   {
      Print("Failed to send trade request. Last Error: ", GetLastError());
   }
}

//+------------------------------------------------------------------+
//| Validate stop levels against broker requirements                 |
//+------------------------------------------------------------------+
bool ValidateStopLevels(ENUM_ORDER_TYPE orderType, double ask, double bid, double &sl, double &tp)
{
   double spread = ask - bid;
   // Get the minimum allowed stop distance in points
   int stopLevel = (int)SymbolInfoInteger(_Symbol, SYMBOL_TRADE_STOPS_LEVEL);
   double minDist = stopLevel * SymbolInfoDouble(_Symbol, SYMBOL_POINT);
   
   if(orderType == ORDER_TYPE_BUY)
   {
      // Check if Stop Loss is too close to or above the current Bid price
      if(sl >= bid - minDist) 
      {
         // Option 1: Adjust SL to the minimum allowed distance
         sl = NormalizeDouble(bid - minDist, (int)SymbolInfoInteger(_Symbol, SYMBOL_DIGITS));
         Print("Buy Stop Loss adjusted to minimum allowed level.");
      }
      // Check if Take Profit is too close to or below the current Ask price
      if(tp <= ask + minDist)
      {
         // Option 1: Adjust TP to the minimum allowed distance
         tp = NormalizeDouble(ask + minDist, (int)SymbolInfoInteger(_Symbol, SYMBOL_DIGITS));
         Print("Buy Take Profit adjusted to minimum allowed level.");
      }
   }
   else // ORDER_TYPE_SELL
   {
      // Check if Stop Loss is too close to or below the current Ask price
      if(sl <= ask + minDist)
      {
         // Option 1: Adjust SL to the minimum allowed distance
         sl = NormalizeDouble(ask + minDist, (int)SymbolInfoInteger(_Symbol, SYMBOL_DIGITS));
         Print("Sell Stop Loss adjusted to minimum allowed level.");
      }
      // Check if Take Profit is too close to or above the current Bid price
      if(tp >= bid - minDist)
      {
         // Option 1: Adjust TP to the minimum allowed distance
         tp = NormalizeDouble(bid - minDist, (int)SymbolInfoInteger(_Symbol, SYMBOL_DIGITS));
         Print("Sell Take Profit adjusted to minimum allowed level.");
      }
   }
   
   return true;
}

//+------------------------------------------------------------------+
//| Trailing stop function                                           |
//+------------------------------------------------------------------+
void ManageOpenTrades()
{
   if(!UseTrailingStop) return;

   int total = PositionsTotal();
   for(int i = total - 1; i >= 0; i--)
   {
      // get ticket (PositionGetTicket returns ulong; it also selects the position)
      ulong ticket = PositionGetTicket(i);
      if(ticket == 0) continue;

      // ensure the position is selected (recommended)
      if(!PositionSelectByTicket(ticket)) continue;

      // Optional: only operate on same symbol or your EA's magic number
      if(PositionGetString(POSITION_SYMBOL) != _Symbol) continue;
      // if(PositionGetInteger(POSITION_MAGIC) != MyMagicNumber) continue;

      // read position properties AFTER selecting
      double open_price   = PositionGetDouble(POSITION_PRICE_OPEN);
      double current_price= PositionGetDouble(POSITION_PRICE_CURRENT);
      double current_sl   = PositionGetDouble(POSITION_SL);
      double current_tp   = PositionGetDouble(POSITION_TP);
      ENUM_POSITION_TYPE pos_type = (ENUM_POSITION_TYPE)PositionGetInteger(POSITION_TYPE);

      // pip size
      double pip_price = PipsToPrice(1);

      // profit in pips (use current_price returned above)
      double profit_price = (pos_type == POSITION_TYPE_BUY) ? (current_price - open_price)
                                                             : (open_price - current_price);
      double profit_pips = profit_price / pip_price;
      if(profit_pips <= 0) continue;

      // get broker min stop distance (in price units)
      double point = SymbolInfoDouble(_Symbol, SYMBOL_POINT);
      double stop_level_points = (double)SymbolInfoInteger(_Symbol, SYMBOL_TRADE_STOPS_LEVEL);
      double stopLevelPrice = stop_level_points * point;

      // get market Bid/Ask for stop-level checks
      double bid = SymbolInfoDouble(_Symbol, SYMBOL_BID);
      double ask = SymbolInfoDouble(_Symbol, SYMBOL_ASK);

      // -------------------------
      // 1) Move to breakeven
      // -------------------------
      if(profit_pips >= BreakEvenAtPips)
      {
         double breakeven = open_price;
         // small adjustment to help account for spread/commissions (optional)
         if(pos_type == POSITION_TYPE_BUY)  breakeven += point; 
         else                                breakeven -= point;

         // Check stop-level rules: for BUY SL must be >= (bid - stopLevelPrice) distance below bid
         if(pos_type == POSITION_TYPE_BUY)
         {
            if((bid - breakeven) >= stopLevelPrice) // allowed by server
            {
               if(breakeven > current_sl) // only move SL up
               {
                  if(!TradeManager.PositionModify(ticket, NormalizeDouble(breakeven, _Digits), current_tp))
                     PrintFormat("PositionModify failed (BE) ticket %I64u error %d", ticket, GetLastError());
               }
            }
         }
         else // SELL
         {
            if((breakeven - ask) >= stopLevelPrice)
            {
               if(current_sl == 0.0 || breakeven < current_sl) // move SL down
               {
                  if(!TradeManager.PositionModify(ticket, NormalizeDouble(breakeven, _Digits), current_tp))
                     PrintFormat("PositionModify failed (BE) ticket %I64u error %d", ticket, GetLastError());
               }
            }
         }
      } // end breakeven

      // -------------------------
      // 2) Trailing in steps after TrailStartAtPips
      // -------------------------
      if(profit_pips >= TrailStartAtPips)
      {
         double extra_pips = profit_pips - TrailStartAtPips;
         int step_count = (int)(extra_pips / TrailStepPips);

         // compute desired SL relative to open_price (as per your original request)
         double desiredOffsetPips = (double)(TrailStartAtPips + step_count * TrailStepPips);
         double new_sl_price;

         if(pos_type == POSITION_TYPE_BUY)
         {
            new_sl_price = open_price + PipsToPrice((int)desiredOffsetPips);
            // ensure new SL respects server min distance from current Bid
            if((bid - new_sl_price) < stopLevelPrice)
               new_sl_price = bid - stopLevelPrice;

            if(new_sl_price > current_sl) // only move SL up
            {
               if(!TradeManager.PositionModify(ticket, NormalizeDouble(new_sl_price, _Digits), current_tp))
                  PrintFormat("PositionModify failed (Trail Buy) ticket %I64u error %d", ticket, GetLastError());
            }
         }
         else // SELL
         {
            new_sl_price = open_price - PipsToPrice((int)desiredOffsetPips);
            // ensure new SL respects server min distance from current Ask
            if((new_sl_price - ask) < stopLevelPrice)
               new_sl_price = ask + stopLevelPrice;

            if(current_sl == 0.0 || new_sl_price < current_sl) // only move SL down (more profitable)
            {
               if(!TradeManager.PositionModify(ticket, NormalizeDouble(new_sl_price, _Digits), current_tp))
                  PrintFormat("PositionModify failed (Trail Sell) ticket %I64u error %d", ticket, GetLastError());
            }
         }
      }
   } 
}

//+------------------------------------------------------------------+
//| Helper: convert pips -> price (taking 3/5-digit fractional pips) |
//+------------------------------------------------------------------+
double PipsToPrice(int pips)
{
   double point = SymbolInfoDouble(_Symbol, SYMBOL_POINT);
   int digits   = (int)SymbolInfoInteger(_Symbol, SYMBOL_DIGITS);
   double pip   = (digits == 3 || digits == 5) ? point * 10.0 : point;
   return(pips * pip);
}
//+------------------------------------------------------------------+