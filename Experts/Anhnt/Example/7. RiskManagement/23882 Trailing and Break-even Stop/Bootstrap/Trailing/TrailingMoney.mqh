//+------------------------------------------------------------------+
//|                                                TrailingMoney.mqh |
//|                                     Copyright 2026, Omega Joctan |
//|                 https://www.mql5.com/en/users/omegajoctan/seller |
//+------------------------------------------------------------------+
#property copyright "Copyright 2026, Omega Joctan"
#property link      "https://www.mql5.com/en/users/omegajoctan/seller"
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
#include "Base.mqh"
//+------------------------------------------------------------------+
//| defines                                                          |
//+------------------------------------------------------------------+
class CTrailingMoney
  {
protected:
   string            m_symbol;
   long              m_magic;

public:
                     CTrailingMoney(string symbol, long magic = -1);
                    ~CTrailingMoney(void);

   static void       TrailStops(string symbol, double activation_money, double trail_money, long magic = -1);
   void              TrailStops(double activation_money, double trail_money);
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
CTrailingMoney::CTrailingMoney(string symbol, long magic = -1):
   m_symbol(symbol),
   m_magic(magic)
  {

  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
CTrailingMoney::~CTrailingMoney(void)
  {

  }
//+------------------------------------------------------------------+
//| Trail open positions based on monetary profit.                   |
//|                                                                  |
//| This trailing stop method adjusts the stop loss based on the     |
//| actual monetary value of the position rather than a fixed price  |
//| distance, indicator value, or number of points. Once a position  |
//| reaches the specified profit threshold, the stop loss is moved   |
//| to maintain a defined monetary distance from the current market  |
//| price.                                                           |
//|                                                                  |
//| Parameters:                                                      |
//|   symbol           - Trading symbol whose positions will be      |
//|                      managed.                                    |
//|   activation_money - Minimum profit in account currency required |
//|                      before the trailing stop is activated.      |
//|   trail_money      - Amount of profit in account currency to     |
//|                      maintain as the trailing distance.          |
//|   magic            - Magic number used to filter positions.      |
//|                      Specify -1 to trail all positions on the    |
//|                      specified symbol.                           |
//|                                                                  |
//+------------------------------------------------------------------+
void CTrailingMoney::TrailStops(string symbol,
                                double activation_money,
                                double trail_money,
                                long magic = -1)
  {
   CPositionInfo pos;
   CTrade trade;

   for(int i = PositionsTotal() - 1; i >= 0; i--)
     {
      if(!pos.SelectByIndex(i))
         continue;

      if(pos.Symbol() != symbol)
         continue;

      if(magic != -1 && pos.Magic() != magic)
         continue;

      double profit = pos.Profit();

      // Wait until the desired profit is reached
      if(profit < activation_money)
         continue;

      double volume     = pos.Volume();
      double tick_size  = SymbolInfoDouble(symbol, SYMBOL_TRADE_TICK_SIZE);
      double tick_value = SymbolInfoDouble(symbol, SYMBOL_TRADE_TICK_VALUE);

      if(tick_size <= 0 || tick_value <= 0)
         continue;

      // Convert money into a price distance
      double distance = trail_money * tick_size / (tick_value * volume);

      double tp = pos.TakeProfit();
      double sl = pos.StopLoss();
      ulong ticket = pos.Ticket();

      int digits = (int)SymbolInfoInteger(symbol, SYMBOL_DIGITS);

      switch(pos.PositionType())
        {
         case POSITION_TYPE_BUY:
           {
            double bid = SymbolInfoDouble(symbol, SYMBOL_BID);

            double new_sl = NormalizeDouble(bid - distance, digits);

            if(sl != 0 && new_sl <= sl)
               continue;

            if(!isPositionModificationSameLevels(ticket, new_sl, tp))
               continue;

            if(!isValidStoploss_Takeprofit(ORDER_TYPE_BUY, new_sl, tp, symbol))
               continue;

            if(!trade.PositionModify(ticket, new_sl, tp))
               Print(trade.ResultRetcodeDescription());
           }
         break;

         case POSITION_TYPE_SELL:
           {
            double ask = SymbolInfoDouble(symbol, SYMBOL_ASK);
            double new_sl = NormalizeDouble(ask + distance, digits);

            if(sl != 0 && new_sl >= sl)
               continue;

            if(!isPositionModificationSameLevels(ticket, new_sl, tp))
               continue;

            if(!isValidStoploss_Takeprofit(ORDER_TYPE_SELL, new_sl, tp, symbol))
               continue;

            if(!trade.PositionModify(ticket, new_sl, tp))
               Print(trade.ResultRetcodeDescription());
           }
         break;
        }
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CTrailingMoney::TrailStops(double activation_money, double trail_money)
  {
   CTrailingMoney::TrailStops(m_symbol, activation_money, trail_money, m_magic);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
