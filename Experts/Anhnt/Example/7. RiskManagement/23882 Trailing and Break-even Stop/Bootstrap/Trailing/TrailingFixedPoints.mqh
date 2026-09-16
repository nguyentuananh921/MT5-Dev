//+------------------------------------------------------------------+
//|                                          CTrailingFixedPoints.mqh |
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
class CTrailingFixedPoints
  {
protected:
   string            m_symbol;
   long              m_magic;

public:
                     CTrailingFixedPoints(const string symbol, const long magic = -1);
                    ~CTrailingFixedPoints(void);

   void              TrailStops(double trail_points, double step_points);
   static void       TrailStops(string symbol, double trail_points, double step_points, long magic = -1);
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
CTrailingFixedPoints::CTrailingFixedPoints(const string symbol, const long magic = -1):
   m_symbol(symbol),
   m_magic(magic)
  {

  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
CTrailingFixedPoints::~CTrailingFixedPoints(void)
  {

  }
//+------------------------------------------------------------------+
//| Trail open positions using a fixed-point trailing stop.          |
//|                                                                  |
//| Once a position has moved in profit by at least `trail_points`,  |
//| the stop loss is automatically adjusted to remain                |
//| `step_points` behind the current market price. The stop loss is  |
//| updated only when the new level differs from the current one and |
//| satisfies the broker's stop level requirements.                  |
//|                                                                  |
//| Parameters:                                                      |
//|   symbol       - Trading symbol whose positions will be managed. |
//|   trail_points - Minimum profit (in points) required before      |
//|                  trailing begins.                                |
//|   step_points  - Distance (in points) maintained between the     |
//|                  current market price and the stop loss.         |
//|   magic        - Magic number used to filter positions. Specify  |
//|                  -1 to trail all positions on the symbol.        |
//|                                                                  |
//+------------------------------------------------------------------+
void CTrailingFixedPoints::TrailStops(string symbol, double trail_points, double step_points, long magic = -1)
  {
   double point = SymbolInfoDouble(symbol, SYMBOL_POINT);
   CPositionInfo pos;

   CTrade trade;

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

      ulong ticket = pos.Ticket();
      ENUM_POSITION_TYPE type = pos.PositionType();

      switch(type)
        {
         case  POSITION_TYPE_BUY:
           {
            //--- Ensure the position has moved enough
            double bid = SymbolInfoDouble(symbol, SYMBOL_BID);
            if(bid - open_price <= trail_points * point)
               continue;

            double new_sl = bid - step_points * point;

            //--- Never move the stop loss backwards
            if(sl != 0.0 && new_sl < sl)
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
            double ask = SymbolInfoDouble(symbol, SYMBOL_ASK);

            //--- Ensure the positoin has moved enough
            if(open_price - ask <= trail_points * point)
               continue;

            double new_sl = ask + step_points * point;

            //--- Never move the stop loss backwards
            if(sl != 0.0 && new_sl > sl)
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
void CTrailingFixedPoints::TrailStops(double trail_points, double step_points)
  {
   CTrailingFixedPoints::TrailStops(m_symbol, trail_points, step_points, m_magic);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
