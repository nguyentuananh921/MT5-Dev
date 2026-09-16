//+------------------------------------------------------------------+
//|                                           TrailingPercentage.mqh |
//|                                     Copyright 2026, Omega Joctan |
//|                 https://www.mql5.com/en/users/omegajoctan/seller |
//+------------------------------------------------------------------+
#property copyright "Copyright 2026, Omega Joctan"
#property link      "https://www.mql5.com/en/users/omegajoctan/seller"
//+------------------------------------------------------------------+
//| defines                                                          |
//+------------------------------------------------------------------+
#include "Base.mqh"
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class CTrailingPeriodic
  {
protected:
   string            m_symbol;
   long              m_magic;

public:
                     CTrailingPeriodic(const string symbol, const long magic = -1);
                    ~CTrailingPeriodic(void);

   void              TrailStops(ulong interval_seconds, double trail_step);
   static void       TrailStops(ulong interval_seconds, double trail_step, string symbol, long magic = -1);
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
CTrailingPeriodic::CTrailingPeriodic(const string symbol, const long magic = -1):
   m_symbol(symbol),
   m_magic(magic)
  {

  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
CTrailingPeriodic::~CTrailingPeriodic(void)
  {

  }
//+------------------------------------------------------------------+
//| Trail open positions at fixed time intervals.                    |
//|                                                                  |
//| This trailing stop method updates the stop loss only after a     |
//| specified amount of time has elapsed since the last position     |
//| modification. 
//|                                                                  |
//| Parameters:                                                      |
//|   interval_seconds - Minimum time in seconds required between    |
//|                      consecutive stop loss modifications.        |
//|   trail_step       - Number of points by which the stop loss is  |
//|                      moved on each update.                       |
//|   symbol           - Trading symbol whose positions will be      |
//|                      managed.                                    |
//|   magic            - Magic number used to filter positions.      |
//|                      Specify -1 to trail all positions on the    |
//|                      specified symbol.                           |
//|                                                                  |
//+------------------------------------------------------------------+
void CTrailingPeriodic::TrailStops(ulong interval_seconds, double trail_step, string symbol, long magic = -1)
  {
   CPositionInfo pos;
   CTrade trade;

   double point = SymbolInfoDouble(symbol, SYMBOL_POINT);

//---

   for(int i = PositionsTotal() - 1; i >= 0; i--)
     {
      if(!pos.SelectByIndex(i))
         continue;

      if(pos.Symbol() != symbol)
         continue;

      long pos_magic = pos.Magic();
      if(magic != -1)
         if(pos_magic != magic)
            continue;

      double sl = pos.StopLoss(), tp = pos.TakeProfit(), open_price = pos.PriceOpen();
      double sl_gap = fabs(open_price - sl);

      //---

      ulong ticket = pos.Ticket();
      ENUM_POSITION_TYPE type = pos.PositionType();
      ulong open_time = (ulong)pos.Time();
      ulong update_time = pos.TimeUpdate();

      //--- modify after a specified number of seconds has passed
      ulong time_diff = (long)TimeCurrent() - update_time;
      
      if(time_diff < interval_seconds)
         continue;

      switch(type)
        {
         case  POSITION_TYPE_BUY:
           {
            double new_sl = sl + trail_step * point; //increase the stoploss by a given number of points

            if(sl != 0 && new_sl <= sl)
               continue;

            if(!isPositionModificationSameLevels(ticket, new_sl, tp))
               continue;

            if(!isValidStoploss_Takeprofit(ORDER_TYPE_BUY, new_sl, tp, symbol))
               continue;

            trade.PositionModify(ticket, new_sl, tp);
           }
         break;
         case  POSITION_TYPE_SELL:
           {
            double new_sl = sl - trail_step * point; //reduce the stoploss by a given number of points

            if(sl != 0 && new_sl >= sl)
               continue;

            if(!isPositionModificationSameLevels(ticket, new_sl, tp))
               continue;

            if(!isValidStoploss_Takeprofit(ORDER_TYPE_SELL, new_sl, tp, symbol))
               continue;

            trade.PositionModify(ticket, new_sl, tp);
           }
         break;
         default:
            break;
        }
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CTrailingPeriodic::TrailStops(ulong interval_seconds, double trail_step)
  {
   CTrailingPeriodic::TrailStops(interval_seconds, trail_step, m_symbol, m_magic);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
