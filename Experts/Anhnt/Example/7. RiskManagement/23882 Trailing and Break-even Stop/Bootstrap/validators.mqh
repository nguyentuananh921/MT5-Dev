//+------------------------------------------------------------------+
//|                                                   validators.mqh |
//|                                     Copyright 2026, Omega Joctan |
//|                 https://www.mql5.com/en/users/omegajoctan/seller |
//+------------------------------------------------------------------+
#property copyright "Copyright 2026, Omega Joctan"
#property link      "https://www.mql5.com/en/users/omegajoctan/seller"
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
#include <Trade\OrderInfo.mqh>
#include <Trade\PositionInfo.mqh>
//+------------------------------------------------------------------+
//|  Function to validate Lot size                                   |
//+------------------------------------------------------------------+
double NormalizeLotSize(const double volume, string symbol = "")
  {
   if(symbol == NULL || symbol == "")
      symbol = Symbol();

//--- Get the minimum, maximum, and step size for the symbol

   double min_volume = SymbolInfoDouble(symbol, SYMBOL_VOLUME_MIN);
   double max_volume = SymbolInfoDouble(symbol, SYMBOL_VOLUME_MAX);
   double step_volume = SymbolInfoDouble(symbol, SYMBOL_VOLUME_STEP);

//--- Check if the volume is less than the minimum
   if(volume < min_volume)
      return min_volume;

//--- Check if the volume is greater than the maximum

   if(volume > max_volume)
      return max_volume;

//--- Check if the volume is a multiple of the step size

   int ratio = (int) MathRound(volume / step_volume);
   double adjusted_volume = ratio * step_volume;

   if(MathAbs(adjusted_volume - volume) > 0.0000001)
      return adjusted_volume;

   return adjusted_volume;
  }
//+------------------------------------------------------------------+
//| Checks if a given lotsize (volume) value is appropriate according|
//| to instrument's specs.                                           |
//+------------------------------------------------------------------+
bool isValidLotsize(double volume, string symbol = NULL, bool verbose = false)
  {
   if(symbol == NULL || symbol == "")
      symbol = Symbol();

//--- minimal allowed volume for trade operations
   double min_volume = SymbolInfoDouble(Symbol(), SYMBOL_VOLUME_MIN);
   if(volume < min_volume)
     {
      if(verbose)
         printf("Volume is less than the minimal allowed SYMBOL_VOLUME_MIN=%.2f", min_volume);
      return(false);
     }

//--- maximal allowed volume of trade operations
   double max_volume = SymbolInfoDouble(Symbol(), SYMBOL_VOLUME_MAX);
   if(volume > max_volume)
     {
      if(verbose)
         printf("Volume is greater than the maximal allowed SYMBOL_VOLUME_MAX=%.2f", max_volume);
      return(false);
     }

//--- get minimal step of volume changing
   double volume_step = SymbolInfoDouble(Symbol(), SYMBOL_VOLUME_STEP);

   int ratio = (int)MathRound(volume / volume_step);
   if(MathAbs(ratio * volume_step - volume) > 0.0000001)
     {
      if(verbose)
         printf("Volume is not a multiple of the minimal step SYMBOL_VOLUME_STEP=%.2f, the closest correct volume is %.2f", volume_step, ratio * volume_step);
      return(false);
     }

   return true;
  }
//+------------------------------------------------------------------+
//| Normalizes the price of a particular symbol considering instrument's
//| digits.                                                          |
//+------------------------------------------------------------------+
double NormalizePrice(double price, string symbol = NULL)
  {
   if(symbol == NULL || symbol == "")
      symbol = Symbol();

   int digits = (int)SymbolInfoInteger(symbol, SYMBOL_DIGITS);

   return NormalizeDouble(price, digits);
  }
//+------------------------------------------------------------------+
//| Checks if a given price is valid                                 |
//+------------------------------------------------------------------+
bool isValidPrice(double price)
  {
   return (price > 0 && MathIsValidNumber(price));
  }
//+------------------------------------------------------------------+
//| Checks if either, a given SL or TP is valid.                     |
//+------------------------------------------------------------------+
bool isValidStoploss_Takeprofit(ENUM_ORDER_TYPE type, double SL, double TP, string symbol = "", bool verbose = false)
  {

   if(symbol == NULL || symbol == "")
      symbol = Symbol();

//--- get the SYMBOL_TRADE_STOPS_LEVEL level

   int stops_level = (int)SymbolInfoInteger(symbol, SYMBOL_TRADE_STOPS_LEVEL);
   if(stops_level != 0)
     {
      if(verbose)
         PrintFormat("SYMBOL_TRADE_STOPS_LEVEL=%d: StopLoss and TakeProfit must" +
                     " not be nearer than %d points from the closing price", stops_level, stops_level);
     }

//---

   MqlTick ticks;
   if(!SymbolInfoTick(symbol, ticks))
     {
      printf("Failed to obtain ticks from %s. Error = %d", symbol, GetLastError());
      return false;
     }

   double ask = ticks.ask, bid = ticks.bid;
   double point = SymbolInfoDouble(symbol, SYMBOL_POINT);

//---
   bool SL_check = false, TP_check = false;
//--- check only two order types
   switch(type)
     {
      //--- Buy operation
      case  ORDER_TYPE_BUY:
        {
         //--- check the StopLoss
         SL_check = (bid - SL > stops_level * point);
         if(!SL_check)
            if(verbose)
               PrintFormat("For order %s StopLoss=%.5f must be less than %.5f" +
                           " (bid=%.5f - SYMBOL_TRADE_STOPS_LEVEL=%d points)",
                           EnumToString(type), SL, bid - stops_level * point, bid, stops_level);
         //--- check the TakeProfit
         TP_check = (TP==0.0) || (TP - bid > stops_level * point);
         if(!TP_check)
            if(verbose)
               PrintFormat("For order %s TakeProfit=%.5f must be greater than %.5f" +
                           " (bid=%.5f + SYMBOL_TRADE_STOPS_LEVEL=%d points)",
                           EnumToString(type), TP, bid + stops_level * point, bid, stops_level);
         //--- return the result of checking
         return(SL_check && TP_check);
        }
      //--- Sell operation
      case  ORDER_TYPE_SELL:
        {
         //--- check the StopLoss
         SL_check = (SL - ask > stops_level * point);
         if(!SL_check)
            if(verbose)
               PrintFormat("For order %s StopLoss=%.5f must be greater than %.5f " +
                           " (ask=%.5f + SYMBOL_TRADE_STOPS_LEVEL=%d points)",
                           EnumToString(type), SL, ask + stops_level * point, ask, stops_level);
         //--- check the TakeProfit
         TP_check = (TP==0.0) || (ask - TP > stops_level * point);
         if(!TP_check)
            if(verbose)
               PrintFormat("For order %s TakeProfit=%.5f must be less than %.5f " +
                           " (ask=%.5f - SYMBOL_TRADE_STOPS_LEVEL=%d points)",
                           EnumToString(type), TP, ask - stops_level * point, ask, stops_level);
         //--- return the result of checking
         return(TP_check && SL_check);
        }
      break;
     }
//--- a slightly different function is required for pending orders
   return false;
  }
//+------------------------------------------------------------------+
//| Checks if the new order modification price isn't smaller than the|
//| freeze level value set by the broker.                            |
//+------------------------------------------------------------------+
bool OrderFreezeLevelCheck(ulong order_ticket, double new_price, bool verbose = true)
  {
//--- Get the order

   COrderInfo order;
   if(!order.Select(order_ticket))
     {
      printf("Failed to select an order with ticket %I64u. LastError = %d", order_ticket, GetLastError());
      return false;
     }

   string symbol = order.Symbol();

   MqlTick ticks;
   if(!SymbolInfoTick(symbol, ticks))
     {
      printf("Failed to obtain ticks from %s. Error = %d", symbol, GetLastError());
      return false;
     }

   double ask = ticks.ask, bid = ticks.bid;
   int freeze_level = (int)SymbolInfoInteger(symbol, SYMBOL_TRADE_FREEZE_LEVEL);
   double point = SymbolInfoDouble(symbol, SYMBOL_POINT);

   ENUM_ORDER_TYPE order_type = order.OrderType();

//--- check the order type

   bool check = false;
   switch(order_type)
     {
      //--- BuyLimit pending order
      case  ORDER_TYPE_BUY_LIMIT:
        {
         //--- check the distance from the opening price to the activation price
         if(!(ask - new_price) > freeze_level * point)
           {
            if(verbose)
               PrintFormat("Order %s #%d cannot be modified: ask-Open=%d points < SYMBOL_TRADE_FREEZE_LEVEL=%d points",
                           EnumToString(order_type), order_ticket, (int)((ask - new_price) / point), freeze_level);
            return false;
           }
        }
      break;
      case  ORDER_TYPE_SELL_LIMIT://--- BuyLimit pending order
        {
         //--- check the distance from the opening price to the activation price
         if(!(new_price - bid) > freeze_level * point)
           {
            if(verbose)
               PrintFormat("Order %s #%d cannot be modified: Open-bid=%d points < SYMBOL_TRADE_FREEZE_LEVEL=%d points",
                           EnumToString(order_type), order_ticket, (int)((new_price - bid) / point), freeze_level);

            return false;
           }
        }
      break;
      case  ORDER_TYPE_BUY_STOP: //--- BuyStop pending order
        {
         //--- check the distance from the opening price to the activation price
         if(!(new_price - ask) > freeze_level * point)
           {
            if(verbose)
               PrintFormat("Order %s #%d cannot be modified: ask-Open=%d points < SYMBOL_TRADE_FREEZE_LEVEL=%d points",
                           EnumToString(order_type), order_ticket, (int)((new_price - ask) / point), freeze_level);

            return false;
           }
        }
      break;
      case  ORDER_TYPE_SELL_STOP: //--- SellStop pending order
        {
         //--- check the distance from the opening price to the activation price
         if(!(bid - new_price) > freeze_level * point)
           {
            if(verbose)
               PrintFormat("Order %s #%d cannot be modified: bid-Open=%d points < SYMBOL_TRADE_FREEZE_LEVEL=%d points",
                           EnumToString(order_type), order_ticket, (int)((bid - new_price) / point), freeze_level);
            return false;
           }
        }
      break;
     }

   return true;
  }
//+------------------------------------------------------------------+
//| Checking the new values of levels before order modification      |
//+------------------------------------------------------------------+
bool isOrderModificationSameLevels(ulong ticket, double new_price, double new_sl, double new_tp, bool verbosity = false)
  {
   COrderInfo order;

//--- select order by ticket
   if(order.Select(ticket))
     {
      //--- point size and name of the symbol, for which a pending order was placed
      string symbol = order.Symbol();
      double point = SymbolInfoDouble(symbol, SYMBOL_POINT);
      int digits = (int)SymbolInfoInteger(symbol, SYMBOL_DIGITS);

      //--- check if there are changes in the Open price
      bool PriceOpenChanged = (MathAbs(order.PriceOpen() - new_price) > point);
      //--- check if there are changes in the StopLoss level
      bool StopLossChanged = (MathAbs(order.StopLoss() - new_sl) > point);
      //--- check if there are changes in the Takeprofit level
      bool TakeProfitChanged = (MathAbs(order.TakeProfit() - new_tp) > point);
      //--- if there are any changes in levels
      if(PriceOpenChanged || StopLossChanged || TakeProfitChanged)
         return(true);  // order can be modified

      //--- there are no changes in the Open, StopLoss and Takeprofit levels
      else
        {
         //--- notify about the error
         if(verbosity)
            PrintFormat("Order #%d already has levels of Open=%.5f SL=%.5f TP=%.5f", ticket, order.PriceOpen(), order.StopLoss(), order.TakeProfit());
        }
     }
//--- came to the end, no changes for the order
   return(false);       // no point in modifying
  }
//+------------------------------------------------------------------+
//| Checks whether order's modification attempt is valid or not.     |
//+------------------------------------------------------------------+
bool OrderModificationCheck(ulong ticket, double new_price, double new_sl, double new_tp, bool verbosity = false)
  {
   if(!OrderFreezeLevelCheck(ticket, new_price, verbosity))
      return false;
   if(!isOrderModificationSameLevels(ticket, new_price, new_sl, new_tp, verbosity))
      return false;

   return true;
  }
//+------------------------------------------------------------------+
//| Checking the new values of levels before order modification      |
//+------------------------------------------------------------------+
bool isPositionModificationSameLevels(ulong ticket, double new_sl, double new_tp, bool verbosity = false)
  {
   CPositionInfo pos;
//--- select order by ticket
   if(pos.SelectByTicket(ticket))
     {
      //--- point size and name of the symbol, for which a pending order was placed
      string symbol = pos.Symbol();
      double point = SymbolInfoDouble(symbol, SYMBOL_POINT);
      //--- check if there are changes in the StopLoss level
      bool StopLossChanged = (MathAbs(pos.StopLoss() - new_sl) > point);
      //--- check if there are changes in the Takeprofit level
      bool TakeProfitChanged = (MathAbs(pos.TakeProfit() - new_tp) > point);
      //--- if there are any changes in levels
      if(StopLossChanged || TakeProfitChanged)
         return(true);  // position can be modified
      //--- there are no changes in the StopLoss and Takeprofit levels
      else
        {
         //--- notify about the error
         if(verbosity)
            PrintFormat("Position #%d already has levels of Open=%.5f SL=%.5f TP=%.5f", ticket, pos.PriceOpen(), pos.StopLoss(), pos.TakeProfit());
        }
     }
//--- came to the end, no changes for the order
   return(false);       // no point in modifying
  }
//+------------------------------------------------------------------+
//| Checks whether position modification attempt is valid or not.    |
//+------------------------------------------------------------------+
bool PositionModificationCheck(ulong ticket, double new_sl, double new_tp, bool verbosity = false)
  {
   if(!isPositionModificationSameLevels(ticket, new_sl, new_tp, verbosity))
      return false;

   return true;
  }
//+------------------------------------------------------------------+
//| Checks if there is enough money to open a new trade.             |
//+------------------------------------------------------------------+
bool isEnoughMoneyForTrade(string symb, double lots, ENUM_ORDER_TYPE type, bool verbosity = false)
  {
//--- Getting the opening price

   MqlTick ticks;
   if(!SymbolInfoTick(symb, ticks))
      printf("Failed to get tick information on %s. Error = %d", symb, GetLastError());

   double price = ticks.ask;
   if(type == ORDER_TYPE_SELL)
      price = ticks.bid;

//--- values of the required and free margin

   double margin, free_margin = AccountInfoDouble(ACCOUNT_MARGIN_FREE);

//--- margin calculations
   if(!OrderCalcMargin(type, symb, lots, price, margin))
     {
      Print("Failed to calculate margin Error= ", GetLastError());
      return(false);
     }

//--- if there are insufficient funds to perform the operation

   if(margin > free_margin)
     {
      //--- report the error and return false
      if(verbosity)
         printf("Not enough money for %s(%s, %.3f). Error = %d", EnumToString(type), symb, lots, GetLastError());
      return(false);
     }

//--- checking successful
   return(true);
  }
//+------------------------------------------------------------------+
//| Check if another order can be placed                             |
//+------------------------------------------------------------------+
bool isNewOrderAllowed()
  {
//--- get the number of pending orders allowed on the account
   int max_allowed_orders = (int)AccountInfoInteger(ACCOUNT_LIMIT_ORDERS);

//--- if there is no limitation, return true; you can send an order
   if(max_allowed_orders == 0)
      return(true);

//--- if we passed to this line, then there is a limitation; find out how many orders are already placed
   int orders = OrdersTotal();

//--- return the result of comparing
   return(orders < max_allowed_orders);
  }
//+------------------------------------------------------------------+
//| Checks if a new bar has just emerged                             |
//+------------------------------------------------------------------+
bool isNewBar(ENUM_TIMEFRAMES tf)
  {
   int tf_seconds = PeriodSeconds(tf);
   int current_time_seconds = (int)TimeCurrent();

   return current_time_seconds % tf_seconds == 0;
  }
//+------------------------------------------------------------------+
//| Checks if the instrument is tradable                             |
//+------------------------------------------------------------------+
bool isSymbolTradable(string symbol = NULL)
  {
   if(symbol == NULL || symbol == "")
      symbol = _Symbol;

   long trade_mode = SymbolInfoInteger(symbol, SYMBOL_TRADE_MODE);
   return trade_mode != SYMBOL_TRADE_MODE_DISABLED;
  }
//+------------------------------------------------------------------+
//| Checks whether today is Saturday or Sunday                       |
//+------------------------------------------------------------------+
bool isWeekend()
  {
   MqlDateTime dt;
   TimeToStruct(TimeCurrent(), dt);

   return (dt.day_of_week == 0 ||  // Sunday
           dt.day_of_week == 6);   // Saturday
  }
//+------------------------------------------------------------------+
//| Checks if there is a nearby NFP event                            |
//+------------------------------------------------------------------+
bool isNewsTime(string currency, ENUM_CALENDAR_EVENT_IMPORTANCE importance, uint period_minutes = 60)
  {
   if(MQLInfoInteger(MQL_TESTER) || MQLInfoInteger(MQL_OPTIMIZATION))
      return false;

//---

   long current_time_seconds = (long)TimeCurrent();
   long next_time_seconds = current_time_seconds + (period_minutes * 60);

//---

   static MqlCalendarValue values[]; //https://www.mql5.com/en/docs/constants/structures/mqlcalendar#mqlcalendarvalue

   ResetLastError();
   int all_news = CalendarValueHistory(values, datetime(current_time_seconds), datetime(next_time_seconds), NULL, currency); //we obtain all the news with their values https://www.mql5.com/en/docs/calendar/calendarvaluehistory

   if(all_news <= 0)  //if CalendarValue History returns a value less than zero it is and indicator that thre is either an error or there are no news
     {
      if(GetLastError() > 0) //we check if there was an error
         printf("Failed to get the news for %s. Error=%d", currency, GetLastError());
      else //if there was no error then there are no news for this symbol available since not all symbols have news
         return false;
     }

//---

   for(int i = 0; i < all_news; i++) //we loop through all the news
     {
      MqlCalendarEvent event;
      CalendarEventById(values[i].event_id, event); //Here among all the news we select one after the other by its id https://www.mql5.com/en/docs/calendar/calendareventbyid

      MqlCalendarCountry country; //The couhtry where the currency pair originates
      CalendarCountryById(event.country_id, country); //https://www.mql5.com/en/docs/calendar/calendarcountrybyid

      if(event.importance == importance) //filter the news by importance
        {
         if((long)MathAbs(current_time_seconds - values[i].time) <= (period_minutes * 60)) //filter the news by time | do not trade 15 minutes before or after the news | NB: the difference it time when subtracted gives out seconds
            return true; //There is a high impact new(s) coming shortly
        }
     }

   return false;
  }
//+------------------------------------------------------------------+
//| Trading Sessions                                                 |
//+------------------------------------------------------------------+
enum ENUM_TRADING_SESSION
  {
   SESSION_SYDNEY, //Sydney Session
   SESSION_TOKYO, //Tokyo Session
   SESSION_LONDON, //London Session
   SESSION_NEWYORK, //Newyork Session
   SESSION_UNKNOWN //Unknown Session
  };
//+------------------------------------------------------------------+
//| Returns the trading session using UTC/GMT time                   |
//+------------------------------------------------------------------+
ENUM_TRADING_SESSION GetTradingSession(datetime utc_time = 0)
  {
   if(utc_time == 0)
      utc_time = TimeGMT();

   MqlDateTime dt;
   TimeToStruct(utc_time, dt);

   int hour = dt.hour;

//--- Sydney
   if(hour >= 22 || hour < 7)
      return SESSION_SYDNEY;

//--- Tokyo
   if(hour >= 0 && hour < 9)
      return SESSION_TOKYO;

//--- London
   if(hour >= 8 && hour < 17)
      return SESSION_LONDON;

//--- New York
   if(hour >= 13 && hour < 22)
      return SESSION_NEWYORK;

   return SESSION_UNKNOWN;
  }
//+------------------------------------------------------------------+
//|  Checks if the current session in the market is Sydney           |
//+------------------------------------------------------------------+
bool isSydneySession(datetime utc_time = 0)
  {
   return GetTradingSession(utc_time) == SESSION_SYDNEY;
  }
//+------------------------------------------------------------------+
//|  Checks if the current session in the market is Tokyo            |
//+------------------------------------------------------------------+
bool isTokyoSession(datetime utc_time = 0)
  {
   return GetTradingSession(utc_time) == SESSION_TOKYO;
  }
//+------------------------------------------------------------------+
//|  Checks if the current session in the market is London           |
//+------------------------------------------------------------------+
bool isLondonSession(datetime utc_time = 0)
  {
   return GetTradingSession(utc_time) == SESSION_LONDON;
  }
//+------------------------------------------------------------------+
//|  Checks if the current session in the market is New York         |
//+------------------------------------------------------------------+
bool isNewYorkSession(datetime utc_time = 0)
  {
   return GetTradingSession(utc_time) == SESSION_NEWYORK;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
