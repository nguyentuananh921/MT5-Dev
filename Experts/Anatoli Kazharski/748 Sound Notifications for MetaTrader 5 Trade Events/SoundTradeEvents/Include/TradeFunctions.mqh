//--- Connection with the main file of the Expert Advisor
#include "..\SoundTradeEvents.mq5"
//--- Include custom libraries
#include "Enums.mqh"
#include "Errors.mqh"
#include "TradeSignals.mqh"
#include "ToString.mqh"
#include "Auxiliary.mqh"
//--- Position properties
struct position_properties
  {
   uint              total_deals;      // Number of deals
   bool              exists;           // Flag of presence/absence of an open position
   string            symbol;           // Symbol
   long              magic;            // Magic number
   string            comment;          // Comment
   double            swap;             // Swap
   double            commission;       // Commission   
   double            first_deal_price; // Price of the first deal in the position
   double            price;            // Current position price
   double            current_price;    // Current price of the position symbol      
   double            last_deal_price;  // Price of the last deal in the position
   double            money_profit;     // Profit/Loss of the position in monetary terms
   double            points_profit;    // Profit/Loss of the position in monetary terms
   double            volume;           // Current position volume
   double            initial_volume;   // Initial position volume
   double            sl;               // Stop Loss of the position
   double            tp;               // Take Profit of the position
   datetime          time;             // Position opening time
   ulong             duration;         // Position duration in seconds
   long              id;               // Position identifier
   ENUM_POSITION_TYPE type;            // Position type
  };
//--- Symbol properties
struct symbol_properties
  {
   int               digits;           // Number of decimal places in the price
   int               spread;           // Spread in points
   int               stops_level;      // Stops level
   double            point;            // Point value
   double            ask;              // Ask price
   double            bid;              // Bid price
   double            volume_min;       // Minimum volume for a deal
   double            volume_max;       // Maximum volume for a deal
   double            volume_limit;     // Maximum permissible volume for a position and orders in one direction
   double            volume_step;      // Minimum volume change step for a deal
   double            offset;           // Offset from the maximum possible price for a transaction
   double            up_level;         // Upper Stop level price
   double            down_level;       // Lower Stop level price
   ENUM_SYMBOL_TRADE_EXECUTION execution_mode; // Execution mode
  };
//--- Deal properties in the history
struct history_deal_properties
  {
   string            symbol;     // Symbol
   string            comment;    // Comment
   ENUM_DEAL_TYPE    type;       // Deal type
   ENUM_DEAL_ENTRY   entry;      // Direction
   double            price;      // Price
   double            profit;     // Profit/Loss
   double            volume;     // Volume
   double            swap;       // Swap
   double            commission; // Commission
   datetime          time;       // Time
  };
//--- Variables for position properties and symbol deals
position_properties      pos;
symbol_properties        symb;
history_deal_properties  deal;
//+------------------------------------------------------------------+
//| Trading block                                                    |
//+------------------------------------------------------------------+
void TradingBlock()
  {
   ENUM_ORDER_TYPE      signal=WRONG_VALUE;                 // Variable for getting a signal
   string               comment="hello :)";                 // Position comment
   double               tp=0.0;                             // Take Profit
   double               sl=0.0;                             // Stop Loss
   double               lot=0.0;                            // Volume for position calculation in case of reverse position
   double               position_open_price=0.0;            // Position opening price
   ENUM_ORDER_TYPE      order_type=WRONG_VALUE;             // Order type for opening a position
   ENUM_POSITION_TYPE   opposite_position_type=WRONG_VALUE; // Opposite position type
//--- Get a signal
   signal=GetTradingSignal();
//--- If there is no signal, exit
   if(signal==WRONG_VALUE)
      return;
//--- Find out if there is a position
   pos.exists=PositionSelect(_Symbol);
//--- Get all symbol properties
   GetSymbolProperties(S_ALL);
//--- Determine values for trade variables
   switch(signal)
     {
      //--- Assign values to variables for a BUY
      case ORDER_TYPE_BUY  :
         position_open_price    =symb.ask;
         order_type             =ORDER_TYPE_BUY;
         opposite_position_type =POSITION_TYPE_SELL;
         break;
         //--- Assign values to variables for a SELL
      case ORDER_TYPE_SELL :
         position_open_price    =symb.bid;
         order_type             =ORDER_TYPE_SELL;
         opposite_position_type =POSITION_TYPE_BUY;
         break;
     }
//--- Calculate the Take Profit and Stop Loss levels
   sl=CalculateStopLoss(order_type);
   tp=CalculateTakeProfit(order_type);
//--- If there is no position
   if(!pos.exists)
     {
      //--- Adjust the volume
      lot=CalculateLot(Lot);
      //--- Open a position
      OpenPosition(lot,(ENUM_ORDER_TYPE)order_type,position_open_price,sl,tp,comment);
     }
//--- If there is a position
   else
     {
      //--- Get the position type
      GetPositionProperties(P_TYPE);
      //--- If the position is opposite to the signal and the position reverse is enabled
      if(pos.type==opposite_position_type && Reverse)
        {
         //--- Get the position volume
         GetPositionProperties(P_VOLUME);
         //--- Adjust the volume
         lot=pos.volume+CalculateLot(Lot);
         //--- Open a position
         OpenPosition(lot,(ENUM_ORDER_TYPE)order_type,position_open_price,sl,tp,comment);
        }
     }
//---
   return;
  }
//+------------------------------------------------------------------+
//| Opening a position                                               |
//+------------------------------------------------------------------+
void OpenPosition(double lot,
                  ENUM_ORDER_TYPE order_type,
                  double price,
                  double sl,
                  double tp,
                  string comment)
  {
//--- Set the magic number in the trading structure
   trade.SetExpertMagicNumber(0);
//--- Set the slippage in points
   trade.SetDeviationInPoints(CorrectValueBySymbolDigits(10));
//--- The Instant Execution and Market Execution modes
//    *** Starting with build 803, Stop Loss and Take Profit levels                             ***
//    *** can be set upon opening a position in the SYMBOL_TRADE_EXECUTION_MARKET mode ***
   if(symb.execution_mode==SYMBOL_TRADE_EXECUTION_INSTANT ||
      symb.execution_mode==SYMBOL_TRADE_EXECUTION_MARKET)
     {
      //--- If the position failed to open
      if(!trade.PositionOpen(_Symbol,order_type,lot,price,sl,tp,comment))
        {
         //--- Play the error sound and print the relevant message
         PlaySoundByID(SOUND_ERROR);
         Print("Error opening the position: ",GetLastError()," - ",ErrorDescription(GetLastError()));
        }
      //--- Otherwise play the position opening sound
      else
         PlaySoundByID(SOUND_OPEN_POSITION);
     }
  }
//+------------------------------------------------------------------+
//| Calculating position lot                                         |
//+------------------------------------------------------------------+
double CalculateLot(double lot)
  {
//--- To adjust as per the step
   double corrected_lot=0.0;
//---
   GetSymbolProperties(S_VOLUME_MIN);  // Get the minimum possible lot
   GetSymbolProperties(S_VOLUME_MAX);  // Get the maximum possible lot
   GetSymbolProperties(S_VOLUME_STEP); // Get the lot increase/decrease step
//--- Adjust as per the lot step
   corrected_lot=MathRound(lot/symb.volume_step)*symb.volume_step;
//--- If less than the minimum, return the minimum
   if(corrected_lot<symb.volume_min)
      return(NormalizeDouble(symb.volume_min,2));
//--- If greater than the maximum, return the maximum
   if(corrected_lot>symb.volume_max)
      return(NormalizeDouble(symb.volume_max,2));
//---
   return(NormalizeDouble(corrected_lot,2));
  }
//+------------------------------------------------------------------+
//| Calculating the Take Profit value                                |
//+------------------------------------------------------------------+
double CalculateTakeProfit(ENUM_ORDER_TYPE order_type)
  {
//--- If Take Profit is required
   if(TakeProfit>0)
     {
      //--- For the calculated Take Profit value
      double tp=0.0;
      //--- If you need to calculate the value for a SELL position
      if(order_type==ORDER_TYPE_SELL)
        {
         //--- Calculate the level
         tp=NormalizeDouble(symb.bid-CorrectValueBySymbolDigits(TakeProfit*symb.point),symb.digits);
         //--- Return the calculated value if it is lower than the lower limit of the Stops level
         //    If the value is higher or equal, return the adjusted value
         return(tp<symb.down_level ? tp : symb.down_level-symb.offset);
        }
      //--- If you need to calculate the value for a BUY position
      if(order_type==ORDER_TYPE_BUY)
        {
         //--- Calculate the level
         tp=NormalizeDouble(symb.ask+CorrectValueBySymbolDigits(TakeProfit*symb.point),symb.digits);
         //--- Return the calculated value if it is higher that the upper limit of the Stops level
         //    If the value is lower or equal, return the adjusted value
         return(tp>symb.up_level ? tp : symb.up_level+symb.offset);
        }
     }
//---
   return(0.0);
  }
//+------------------------------------------------------------------+
//| Calculating the Stop Loss value                                  |
//+------------------------------------------------------------------+
double CalculateStopLoss(ENUM_ORDER_TYPE order_type)
  {
//--- If Stop Loss is required
   if(StopLoss>0)
     {
      //--- For the calculated Stop Loss value
      double sl=0.0;
      //--- If you need to calculate the value for a BUY position
      if(order_type==ORDER_TYPE_BUY)
        {
         // Calculate the level
         sl=NormalizeDouble(symb.ask-CorrectValueBySymbolDigits(StopLoss*symb.point),symb.digits);
         //--- Return the calculated value if it is lower than the lower limit of the Stops level
         //    If the value is higher or equal, return the adjusted value
         return(sl<symb.down_level ? sl : symb.down_level-symb.offset);
        }
      //--- If you need to calculate the value for a SELL position
      if(order_type==ORDER_TYPE_SELL)
        {
         //--- Calculate the level
         sl=NormalizeDouble(symb.bid+CorrectValueBySymbolDigits(StopLoss*symb.point),symb.digits);
         //--- Return the calculated value if it is higher that the upper limit of the Stops level
         //    If the value is lower or equal, return the adjusted value
         return(sl>symb.up_level ? sl : symb.up_level+symb.offset);
        }
     }
//---
   return(0.0);
  }
//+------------------------------------------------------------------+
//| Calculating the Trailing Stop value                              |
//+------------------------------------------------------------------+
double CalculateTrailingStop(ENUM_POSITION_TYPE position_type)
  {
//--- Variables for calculations
   double            level       =0.0;
   double            buy_point   =low_price[1];  // The Low value for a Buy
   double            sell_point  =high_price[1]; // The High value for a Sell
//--- Calculate the level for a BUY position
   if(position_type==POSITION_TYPE_BUY)
     {
      //--- Bar's low minus the specified number of points
      level=NormalizeDouble(buy_point-CorrectValueBySymbolDigits(StopLoss*symb.point),symb.digits);
      //--- If the calculated level is lower than the lower limit of the Stops level, 
      //    the calculation is complete, return the current value of the level
      if(level<symb.down_level)
         return(level);
      //--- If it is not lower, try to calculate based on the bid price
      else
        {
         level=NormalizeDouble(symb.bid-CorrectValueBySymbolDigits(StopLoss*symb.point),symb.digits);
         //--- If the calculated level is lower than the limit, return the current value of the level
         //    Otherwise set the nearest possible value
         return(level<symb.down_level ? level : symb.down_level-symb.offset);
        }
     }
//--- Calculate the level for a SELL position
   if(position_type==POSITION_TYPE_SELL)
     {
      //--- Bar's high plus the specified number of points
      level=NormalizeDouble(sell_point+CorrectValueBySymbolDigits(StopLoss*symb.point),symb.digits);
      //--- If the calculated level is higher than the upper limit of the Stops level, 
      //    the calculation is complete, return the current value of the level
      if(level>symb.up_level)
         return(level);
      //--- If it is not higher, try to calculate based on the ask price
      else
        {
         level=NormalizeDouble(symb.ask+CorrectValueBySymbolDigits(StopLoss*symb.point),symb.digits);
         //--- If the calculated level is higher than the limit, return the current value of the level
         //    Otherwise set the nearest possible value
         return(level>symb.up_level ? level : symb.up_level+symb.offset);
        }
     }
//---
   return(0.0);
  }
//+------------------------------------------------------------------+
//| Modifying the Trailing Stop level                                |
//+------------------------------------------------------------------+
void ModifyTrailingStop()
  {
//--- If the Trailing Stop and Stop Loss are set
   if(TrailingStop>0 && StopLoss>0)
     {
      double new_sl    =0.0;    // For calculating the new Stop Loss level
      bool   condition =false;  // For checking the modification condition
      //--- Get the flag of presence/absence of the position
      pos.exists=PositionSelect(_Symbol);
      //--- If the position exists
      if(pos.exists)
        {
         //--- Get the symbol properties
         GetSymbolProperties(S_ALL);
         //--- Get the position properties
         GetPositionProperties(P_ALL);
         //--- Get the Stop Loss level
         new_sl=CalculateTrailingStop(pos.type);
         //--- Depending on the position type, check the relevant condition for the Trailing Stop modification
         switch(pos.type)
           {
            case POSITION_TYPE_BUY  :
               //--- If the new Stop Loss value is higher
               //    than the current value plus the set step
               condition=new_sl>pos.sl+CorrectValueBySymbolDigits(TrailingStop*symb.point);
               break;
            case POSITION_TYPE_SELL :
               //--- If the new Stop Loss value is lower
               //    than the current value minus the set step
               condition=new_sl<pos.sl-CorrectValueBySymbolDigits(TrailingStop*symb.point);
               break;
           }
         //--- If there is a Stop Loss, compare the values before modification
         if(pos.sl>0)
           {
            //--- If the condition for the order modification is met, i.e. the new value is lower/higher 
            //    than the current one, modify the Trailing Stop of the position
            if(condition)
              {
               if(!trade.PositionModify(_Symbol,new_sl,pos.tp))
                  Print("Error modifying the position: ",GetLastError()," - ",ErrorDescription(GetLastError()));
              }
           }
         //--- If there is no Stop Loss, simply set it
         if(pos.sl==0)
           {
            if(!trade.PositionModify(_Symbol,new_sl,pos.tp))
               Print("Error modifying the position: ",GetLastError()," - ",ErrorDescription(GetLastError()));
           }
        }
     }
     //--- Order modification sound
     PlaySoundByID(SOUND_ADJUST_ORDER);
  }
//+------------------------------------------------------------------+
//| Getting position properties                                      |
//+------------------------------------------------------------------+
void GetPositionProperties(ENUM_POSITION_PROPERTIES position_property)
  {
//--- Find out if there is a position
   pos.exists=PositionSelect(_Symbol);
//--- If a position exists, get its properties
   if(pos.exists)
     {
      switch(position_property)
        {
         case P_TOTAL_DEALS      :
            pos.time=(datetime)PositionGetInteger(POSITION_TIME);
            pos.total_deals=CurrentPositionTotalDeals();                                           break;
         case P_SYMBOL           : pos.symbol=PositionGetString(POSITION_SYMBOL);                  break;
         case P_MAGIC            : pos.magic=PositionGetInteger(POSITION_MAGIC);                   break;
         case P_COMMENT          : pos.comment=PositionGetString(POSITION_COMMENT);                break;
         case P_SWAP             : pos.swap=PositionGetDouble(POSITION_SWAP);                      break;
         case P_COMMISSION       : pos.commission=PositionGetDouble(POSITION_COMMISSION);          break;
         case P_PRICE_FIRST_DEAL :
            pos.time=(datetime)PositionGetInteger(POSITION_TIME);
            pos.first_deal_price=CurrentPositionFirstDealPrice();                                  break;
         case P_PRICE_OPEN       : pos.price=PositionGetDouble(POSITION_PRICE_OPEN);               break;
         case P_PRICE_CURRENT    : pos.current_price=PositionGetDouble(POSITION_PRICE_CURRENT);    break;
         case P_PRICE_LAST_DEAL  :
            pos.time=(datetime)PositionGetInteger(POSITION_TIME);
            pos.last_deal_price=CurrentPositionLastDealPrice();                                    break;
         case P_MONEY_PROFIT     : pos.money_profit=PositionGetDouble(POSITION_PROFIT);            break;
         case P_POINTS_PROFIT    : pos.points_profit=CurrentPositionProfitInPoints();              break;
         case P_VOLUME           : pos.volume=PositionGetDouble(POSITION_VOLUME);                  break;
         case P_INITIAL_VOLUME   :
            pos.time=(datetime)PositionGetInteger(POSITION_TIME);
            pos.initial_volume=CurrentPositionInitialVolume();                                     break;
         case P_SL               : pos.sl=PositionGetDouble(POSITION_SL);                          break;
         case P_TP               : pos.tp=PositionGetDouble(POSITION_TP);                          break;
         case P_TIME             : pos.time=(datetime)PositionGetInteger(POSITION_TIME);           break;
         case P_DURATION         : pos.duration=CurrentPositionDuration(SECONDS);                  break;
         case P_ID               : pos.id=PositionGetInteger(POSITION_IDENTIFIER);                 break;
         case P_TYPE             : pos.type=(ENUM_POSITION_TYPE)PositionGetInteger(POSITION_TYPE); break;
         case P_ALL              :
            pos.symbol=PositionGetString(POSITION_SYMBOL);
            pos.magic=PositionGetInteger(POSITION_MAGIC);
            pos.comment=PositionGetString(POSITION_COMMENT);
            pos.swap=PositionGetDouble(POSITION_SWAP);
            pos.commission=PositionGetDouble(POSITION_COMMISSION);
            pos.price=PositionGetDouble(POSITION_PRICE_OPEN);
            pos.current_price=PositionGetDouble(POSITION_PRICE_CURRENT);
            pos.money_profit=PositionGetDouble(POSITION_PROFIT);
            pos.points_profit=CurrentPositionProfitInPoints();
            pos.volume=PositionGetDouble(POSITION_VOLUME);
            pos.sl=PositionGetDouble(POSITION_SL);
            pos.tp=PositionGetDouble(POSITION_TP);
            pos.time=(datetime)PositionGetInteger(POSITION_TIME);
            pos.id=PositionGetInteger(POSITION_IDENTIFIER);
            pos.type=(ENUM_POSITION_TYPE)PositionGetInteger(POSITION_TYPE);
            pos.total_deals=CurrentPositionTotalDeals();
            pos.first_deal_price=CurrentPositionFirstDealPrice();
            pos.last_deal_price=CurrentPositionLastDealPrice();
            pos.initial_volume=CurrentPositionInitialVolume();
            pos.duration=CurrentPositionDuration(SECONDS);                                      break;
         default: Print("The passed position property is not listed in the enumeration!");               return;
        }
     }
//--- If there is no position, zero out variables for position properties
   else
      ZeroPositionProperties();
  }
//+------------------------------------------------------------------+
//| Getting symbol properties                                        |
//+------------------------------------------------------------------+
void GetSymbolProperties(ENUM_SYMBOL_PROPERTIES symbol_property)
  {
   int lot_offset=1; // Number of points for the offset from the Stops level
//---
   switch(symbol_property)
     {
      case S_DIGITS        : symb.digits=(int)SymbolInfoInteger(_Symbol,SYMBOL_DIGITS);                                          break;
      case S_SPREAD        : symb.spread=(int)SymbolInfoInteger(_Symbol,SYMBOL_SPREAD);                                          break;
      case S_STOPSLEVEL    : symb.stops_level=(int)SymbolInfoInteger(_Symbol,SYMBOL_TRADE_STOPS_LEVEL);                          break;
      case S_POINT         : symb.point=SymbolInfoDouble(_Symbol,SYMBOL_POINT);                                                  break;
      //---
      case S_ASK           :
         symb.digits=(int)SymbolInfoInteger(_Symbol,SYMBOL_DIGITS);
         symb.ask=NormalizeDouble(SymbolInfoDouble(_Symbol,SYMBOL_ASK),symb.digits);                                             break;
      case S_BID           :
         symb.digits=(int)SymbolInfoInteger(_Symbol,SYMBOL_DIGITS);
         symb.bid=NormalizeDouble(SymbolInfoDouble(_Symbol,SYMBOL_BID),symb.digits);                                             break;
         //---
      case S_VOLUME_MIN    : symb.volume_min=SymbolInfoDouble(_Symbol,SYMBOL_VOLUME_MIN);                                        break;
      case S_VOLUME_MAX    : symb.volume_max=SymbolInfoDouble(_Symbol,SYMBOL_VOLUME_MAX);                                        break;
      case S_VOLUME_LIMIT  : symb.volume_limit=SymbolInfoDouble(_Symbol,SYMBOL_VOLUME_LIMIT);                                    break;
      case S_VOLUME_STEP   : symb.volume_step=SymbolInfoDouble(_Symbol,SYMBOL_VOLUME_STEP);                                      break;
      //---
      case S_FILTER        :
         symb.digits=(int)SymbolInfoInteger(_Symbol,SYMBOL_DIGITS);
         symb.point=SymbolInfoDouble(_Symbol,SYMBOL_POINT);
         symb.offset=NormalizeDouble(CorrectValueBySymbolDigits(lot_offset*symb.point),symb.digits);                             break;
         //---
      case S_UP_LEVEL      :
         symb.digits=(int)SymbolInfoInteger(_Symbol,SYMBOL_DIGITS);
         symb.stops_level=(int)SymbolInfoInteger(_Symbol,SYMBOL_TRADE_STOPS_LEVEL);
         symb.point=SymbolInfoDouble(_Symbol,SYMBOL_POINT);
         symb.ask=NormalizeDouble(SymbolInfoDouble(_Symbol,SYMBOL_ASK),symb.digits);
         symb.up_level=NormalizeDouble(symb.ask+symb.stops_level*symb.point,symb.digits);                                        break;
         //---
      case S_DOWN_LEVEL    :
         symb.digits=(int)SymbolInfoInteger(_Symbol,SYMBOL_DIGITS);
         symb.stops_level=(int)SymbolInfoInteger(_Symbol,SYMBOL_TRADE_STOPS_LEVEL);
         symb.point=SymbolInfoDouble(_Symbol,SYMBOL_POINT);
         symb.bid=NormalizeDouble(SymbolInfoDouble(_Symbol,SYMBOL_BID),symb.digits);
         symb.down_level=NormalizeDouble(symb.bid-symb.stops_level*symb.point,symb.digits);                                      break;
         //---
      case S_EXECUTION_MODE: symb.execution_mode=(ENUM_SYMBOL_TRADE_EXECUTION)SymbolInfoInteger(_Symbol,SYMBOL_TRADE_EXEMODE);   break;
      //---
      case S_ALL           :
         symb.digits=(int)SymbolInfoInteger(_Symbol,SYMBOL_DIGITS);
         symb.spread=(int)SymbolInfoInteger(_Symbol,SYMBOL_SPREAD);
         symb.stops_level=(int)SymbolInfoInteger(_Symbol,SYMBOL_TRADE_STOPS_LEVEL);
         symb.point=SymbolInfoDouble(_Symbol,SYMBOL_POINT);
         symb.ask=NormalizeDouble(SymbolInfoDouble(_Symbol,SYMBOL_ASK),symb.digits);
         symb.bid=NormalizeDouble(SymbolInfoDouble(_Symbol,SYMBOL_BID),symb.digits);
         symb.volume_min=SymbolInfoDouble(_Symbol,SYMBOL_VOLUME_MIN);
         symb.volume_max=SymbolInfoDouble(_Symbol,SYMBOL_VOLUME_MAX);
         symb.volume_limit=SymbolInfoDouble(_Symbol,SYMBOL_VOLUME_LIMIT);
         symb.volume_step=SymbolInfoDouble(_Symbol,SYMBOL_VOLUME_STEP);
         symb.offset=NormalizeDouble(CorrectValueBySymbolDigits(lot_offset*symb.point),symb.digits);
         symb.up_level=NormalizeDouble(symb.ask+symb.stops_level*symb.point,symb.digits);
         symb.down_level=NormalizeDouble(symb.bid-symb.stops_level*symb.point,symb.digits);
         symb.execution_mode=(ENUM_SYMBOL_TRADE_EXECUTION)SymbolInfoInteger(_Symbol,SYMBOL_TRADE_EXEMODE);                       break;
         //---
      default: Print("The passed symbol property is not listed in the enumeration!"); return;
     }
  }
//+------------------------------------------------------------------+
//| Getting deal properties by ticket                                |
//+------------------------------------------------------------------+
void GetHistoryDealProperties(ulong ticket,ENUM_DEAL_PROPERTIES history_deal_property)
  {
   switch(history_deal_property)
     {
      case D_SYMBOL     : deal.symbol=HistoryDealGetString(ticket,DEAL_SYMBOL);                 break;
      case D_COMMENT    : deal.comment=HistoryDealGetString(ticket,DEAL_COMMENT);               break;
      case D_TYPE       : deal.type=(ENUM_DEAL_TYPE)HistoryDealGetInteger(ticket,DEAL_TYPE);    break;
      case D_ENTRY      : deal.entry=(ENUM_DEAL_ENTRY)HistoryDealGetInteger(ticket,DEAL_ENTRY); break;
      case D_PRICE      : deal.price=HistoryDealGetDouble(ticket,DEAL_PRICE);                   break;
      case D_PROFIT     : deal.profit=HistoryDealGetDouble(ticket,DEAL_PROFIT);                 break;
      case D_VOLUME     : deal.volume=HistoryDealGetDouble(ticket,DEAL_VOLUME);                 break;
      case D_SWAP       : deal.swap=HistoryDealGetDouble(ticket,DEAL_SWAP);                     break;
      case D_COMMISSION : deal.commission=HistoryDealGetDouble(ticket,DEAL_COMMISSION);         break;
      case D_TIME       : deal.time=(datetime)HistoryDealGetInteger(ticket,DEAL_TIME);          break;
      case D_ALL        :
         deal.symbol=HistoryDealGetString(ticket,DEAL_SYMBOL);
         deal.comment=HistoryDealGetString(ticket,DEAL_COMMENT);
         deal.type=(ENUM_DEAL_TYPE)HistoryDealGetInteger(ticket,DEAL_TYPE);
         deal.entry=(ENUM_DEAL_ENTRY)HistoryDealGetInteger(ticket,DEAL_ENTRY);
         deal.price=HistoryDealGetDouble(ticket,DEAL_PRICE);
         deal.profit=HistoryDealGetDouble(ticket,DEAL_PROFIT);
         deal.volume=HistoryDealGetDouble(ticket,DEAL_VOLUME);
         deal.swap=HistoryDealGetDouble(ticket,DEAL_SWAP);
         deal.commission=HistoryDealGetDouble(ticket,DEAL_COMMISSION);
         deal.time=(datetime)HistoryDealGetInteger(ticket,DEAL_TIME);                           break;
         //---
      default: Print("The passed deal property is not listed in the enumeration!");                   return;
     }
  }
//+------------------------------------------------------------------+
//| Zeroing out variables for position properties                    |
//+------------------------------------------------------------------+
void ZeroPositionProperties()
  {
   pos.symbol        ="";
   pos.comment       ="";
   pos.magic         =0;
   pos.price         =0.0;
   pos.current_price =0.0;
   pos.sl            =0.0;
   pos.tp            =0.0;
   pos.type          =WRONG_VALUE;
   pos.volume        =0.0;
   pos.commission    =0.0;
   pos.swap          =0.0;
   pos.money_profit  =0.0;
   pos.points_profit =0.0;
   pos.time          =NULL;
   pos.id            =0;
  }
//+------------------------------------------------------------------+
//| Returning the number of deals in the current position            |
//+------------------------------------------------------------------+
uint CurrentPositionTotalDeals()
  {
   int    total       =0;  // Total deals in the selected history list
   int    count       =0;  // Counter of deals by the position symbol
   string deal_symbol =""; // symbol of the deal
//--- If the position history is obtained
   if(HistorySelect(pos.time,TimeCurrent()))
     {
      //--- Get the number of deals in the obtained list
      total=HistoryDealsTotal();
      //--- Iterate over all the deals in the obtained list
      for(int i=0; i<total; i++)
        {
         //--- Get the symbol of the deal
         deal_symbol=HistoryDealGetString(HistoryDealGetTicket(i),DEAL_SYMBOL);
         //--- If the symbol of the deal and the current symbol are the same, increase the counter
         if(deal_symbol==_Symbol)
            count++;
        }
     }
//---
   return(count);
  }
//+------------------------------------------------------------------+
//| Returning the price of the first deal in the current position    |
//+------------------------------------------------------------------+
double CurrentPositionFirstDealPrice()
  {
   int      total       =0;    // Total deals in the selected history list
   string   deal_symbol ="";   // symbol of the deal
   double   deal_price  =0.0;  // Price of the deal
   datetime deal_time   =NULL; // Time of the deal
//--- If the position history is obtained
   if(HistorySelect(pos.time,TimeCurrent()))
     {
      //--- Get the number of deals in the obtained list
      total=HistoryDealsTotal();
      //--- Iterate over all the deals in the obtained list
      for(int i=0; i<total; i++)
        {
         //--- Get the price of the deal
         deal_price=HistoryDealGetDouble(HistoryDealGetTicket(i),DEAL_PRICE);
         //--- Get the symbol of the deal
         deal_symbol=HistoryDealGetString(HistoryDealGetTicket(i),DEAL_SYMBOL);
         //--- Get the time of the deal
         deal_time=(datetime)HistoryDealGetInteger(HistoryDealGetTicket(i),DEAL_TIME);
         //--- If the time of the deal equals the position opening time, 
         //    and if the symbol of the deal and the current symbol are the same, exit the loop
         if(deal_time==pos.time && deal_symbol==_Symbol)
            break;
        }
     }
//---
   return(deal_price);
  }
//+------------------------------------------------------------------+
//| Returning the price of the last deal in the current position     |
//+------------------------------------------------------------------+
double CurrentPositionLastDealPrice()
  {
   int    total       =0;   // Total deals in the selected history list
   string deal_symbol ="";  // Symbol of the deal 
   double deal_price  =0.0; // Price
//--- If the position history is obtained
   if(HistorySelect(pos.time,TimeCurrent()))
     {
      //--- Get the number of deals in the obtained list
      total=HistoryDealsTotal();
      //--- Iterate over all the deals in the obtained list from the last deal in the list to the first deal
      for(int i=total-1; i>=0; i--)
        {
         //--- Get the price of the deal
         deal_price=HistoryDealGetDouble(HistoryDealGetTicket(i),DEAL_PRICE);
         //--- Get the symbol of the deal
         deal_symbol=HistoryDealGetString(HistoryDealGetTicket(i),DEAL_SYMBOL);
         //--- If the symbol of the deal and the current symbol are the same, exit the loop
         if(deal_symbol==_Symbol)
            break;
        }
     }
//---
   return(deal_price);
  }
//+------------------------------------------------------------------+
//| Returning the initial volume of the current position             |
//+------------------------------------------------------------------+
double CurrentPositionInitialVolume()
  {
   int             total       =0;           // Total deals in the selected history list
   ulong           ticket      =0;           // Ticket of the deal
   ENUM_DEAL_ENTRY deal_entry  =WRONG_VALUE; // Position modification method
   bool            inout       =false;       // Flag of position reversal
   double          sum_volume  =0.0;         // Counter of the aggregate volume of all deals, except for the first one
   double          deal_volume =0.0;         // Volume of the deal
   string          deal_symbol ="";          // Symbol of the deal 
   datetime        deal_time   =NULL;        // Deal execution time
//--- If the position history is obtained
   if(HistorySelect(pos.time,TimeCurrent()))
     {
      //--- Get the number of deals in the obtained list
      total=HistoryDealsTotal();
      //--- Iterate over all the deals in the obtained list from the last deal in the list to the first deal
      for(int i=total-1; i>=0; i--)
        {
         //--- If the order ticket by its position is obtained, then...
         if((ticket=HistoryDealGetTicket(i))>0)
           {
            //--- Get the volume of the deal
            deal_volume=HistoryDealGetDouble(ticket,DEAL_VOLUME);
            //--- Get the position modification method
            deal_entry=(ENUM_DEAL_ENTRY)HistoryDealGetInteger(ticket,DEAL_ENTRY);
            //--- Get the deal execution time
            deal_time=(datetime)HistoryDealGetInteger(ticket,DEAL_TIME);
            //--- Get the symbol of the deal
            deal_symbol=HistoryDealGetString(ticket,DEAL_SYMBOL);
            //--- When the deal execution time is less than or equal to the position opening time, exit the loop
            if(deal_time<=pos.time)
               break;
            //--- otherwise calculate the aggregate volume of deals by the position symbol, except for the first one
            if(deal_symbol==_Symbol)
               sum_volume+=deal_volume;
           }
        }
     }
//--- If the position modification method is a reversal
   if(deal_entry==DEAL_ENTRY_INOUT)
     {
      //--- If the position volume has been increased/decreased
      //    I.e. the number of deals is more than one
      if(fabs(sum_volume)>0)
        {
         //--- Current volume minus the volume of all deals except for the first one
         double result=pos.volume-sum_volume;
         //--- If the resulting value is greater than zero, return the result, otherwise return the current position volume         
         deal_volume=result>0 ? result : pos.volume;
        }
      //--- If there are no more deals, other than the entry,
      if(sum_volume==0)
         deal_volume=pos.volume; // return the current position volume
     }
//--- Return the initial position volume
   return(NormalizeDouble(deal_volume,2));
  }
//+------------------------------------------------------------------+
//| Returning profit in points                                       |
//+------------------------------------------------------------------+
double CurrentPositionProfitInPoints()
  {
   double profit_in_points=0.0;
//---
   SymbolInfoTick(_Symbol,last_tick);
//---
   GetPositionProperties(P_PRICE_OPEN);
   GetPositionProperties(P_TYPE);
//---
   if(pos.type==POSITION_TYPE_BUY)
      profit_in_points=(last_tick.bid-pos.price)/_Point;
//---
   if(pos.type==POSITION_TYPE_SELL)
      profit_in_points=(pos.price-last_tick.ask)/_Point;
//---
   return(NormalizeDouble(profit_in_points,2));
  }
//+------------------------------------------------------------------+
//| Returning the duration of the current position                   |
//+------------------------------------------------------------------+
ulong CurrentPositionDuration(ENUM_POSITION_DURATION mode)
  {
   ulong     result=0;   // End result
   ulong     seconds=0;  // Number of seconds
//--- Calculate the position duration in seconds
   seconds=TimeCurrent()-pos.time;
//---
   switch(mode)
     {
      case DAYS      : result=seconds/(60*60*24);   break; // Calculate the number of days
      case HOURS     : result=seconds/(60*60);      break; // Calculate the number of hours
      case MINUTES   : result=seconds/60;           break; // Calculate the number of minutes
      case SECONDS   : result=seconds;              break; // No calculations (number of seconds)
      //---
      default        :
         Print(__FUNCTION__,"(): Unknown duration mode passed!");
         return(0);
     }
//--- Return result
   return(result);
  }
//+------------------------------------------------------------------+
//| Checking for the new bar                                         |
//+------------------------------------------------------------------+
bool CheckNewBar()
  {
//--- Variable for storing the opening time of the current bar
   static datetime new_bar=NULL;
//--- Array for getting the opening time of the current bar
   static datetime time_last_bar[1]={0};
//--- Get the opening time of the current bar
//    If an error occurred when getting the time, print the relevant message
   if(CopyTime(_Symbol,Period(),0,1,time_last_bar)==-1)
     { Print(__FUNCTION__,": Error copying the opening time of the bar: "+IntegerToString(GetLastError())+""); }
//--- If this is a first function call
   if(new_bar==NULL)
     {
      //--- Set the time
      new_bar=time_last_bar[0];
      Print(__FUNCTION__,": Initialization ["+_Symbol+"][TF: "+TimeframeToString(Period())+"]["
            +TimeToString(time_last_bar[0],TIME_DATE|TIME_MINUTES|TIME_SECONDS)+"]");
      return(false); // Return false and exit 
     }
//--- If the time is different
   if(new_bar!=time_last_bar[0])
     {
      new_bar=time_last_bar[0]; // Set the time and exit 
      return(true); // Store the time and return true
     }
//--- If we have reached this line, then the bar is not new, return false
   return(false);
  }
//+------------------------------------------------------------------+
