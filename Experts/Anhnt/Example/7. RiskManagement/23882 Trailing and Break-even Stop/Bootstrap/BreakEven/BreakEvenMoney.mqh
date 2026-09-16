//+------------------------------------------------------------------+
//|                                               BreakEvenMoney.mqh |
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
class CBreakEvenMoney
  {
protected:
   string            m_symbol;
   long              m_magic;

public:
                     CBreakEvenMoney(string symbol, long magic = -1);
                    ~CBreakEvenMoney(void);

   static void       BreakEven(double activation_money, double offset_money, string symbol, long magic = -1);
   void              BreakEven(double activation_money, double offset_money);
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
CBreakEvenMoney::CBreakEvenMoney(string symbol, long magic = -1):
   m_symbol(symbol),
   m_magic(magic)
  {

  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
CBreakEvenMoney::~CBreakEvenMoney(void)
  {

  }
//+------------------------------------------------------------------+
//| Move the stop loss to break-even based on monetary profit.       |
//|                                                                  |
//| Parameters:                                                      |
//|   activation_money - Minimum profit in account currency required |
//|                      before break-even is activated.             |
//|   offset_money     - Profit in account currency to lock after    |
//|                      moving the stop loss.                       |
//|   magic            - Magic number used to filter positions.      |
//|                      Use -1 to manage all positions.             |
//|   symbol           - Trading symbol whose positions are managed. |
//|                                                                  |
//+------------------------------------------------------------------+
void CBreakEvenMoney::BreakEven(double activation_money,
                                double offset_money,
                                string symbol,
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
      double distance = offset_money * tick_size / (tick_value * volume);

      double tp = pos.TakeProfit(), sl = pos.StopLoss(), open_price = pos.PriceOpen();
      ulong ticket = pos.Ticket();

      switch(pos.PositionType())
        {
         case POSITION_TYPE_BUY:
           {
            double new_sl = open_price + distance;

            if(sl >= open_price)
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
            double new_sl = open_price - distance;

            if(sl <= open_price)
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
void CBreakEvenMoney::BreakEven(double activation_money, double offset_money)
  {
   CBreakEvenMoney::BreakEven(activation_money, offset_money, m_symbol, m_magic);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
