//+------------------------------------------------------------------+
//|                                         BreakEvenFixedPoints.mqh |
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
class CBreakEvenFixedPoints
  {
protected:
   string            m_symbol;
   long              m_magic;

public:
                     CBreakEvenFixedPoints(const string symbol, const long magic = -1);
                    ~CBreakEvenFixedPoints(void);

   void              BreakEven(double activation_points, double offset_points);
   static void       BreakEven(double activation_points, double offset_points, string symbol, long magic = -1);
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
CBreakEvenFixedPoints::CBreakEvenFixedPoints(const string symbol, const long magic = -1):
   m_symbol(symbol),
   m_magic(magic)
  {

  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
CBreakEvenFixedPoints::~CBreakEvenFixedPoints(void)
  {

  }
//+------------------------------------------------------------------+
//| Adjusts the stoploss to position's opening price + offset_points |
//|                                                                  |
//| Parameters:                                                      |
//|   symbol       - Trading symbol whose positions will be managed. |
//|   activation_points - Minimum profit (in points) required before |
//|                  break even begins.                              |
//|   offset_points  - Distance (in points) to add to the new        |
//|                  stoploss.                                       |
//|   magic        - Magic number used to filter positions. Specify  |
//|                  -1 to trail all positions on the symbol.        |
//|                                                                  |
//+------------------------------------------------------------------+
void CBreakEvenFixedPoints::BreakEven(double activation_points, double offset_points, string symbol, long magic = -1)
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
            if(bid - open_price <= activation_points * point)
               continue;

            double new_sl = open_price + offset_points * point; //breakeven sl

            //--- Prevent unwanted modifications
            if(new_sl <= open_price)
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

            //--- Ensure the postion has moved enough
            if(open_price - ask <= activation_points * point)
               continue;

            double new_sl = open_price - offset_points * point;

            //--- Prevent unwanted modifications
            if(new_sl >= open_price)
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
void CBreakEvenFixedPoints::BreakEven(double activation_points, double offset_points)
  {
   CBreakEvenFixedPoints::BreakEven(activation_points, offset_points, m_symbol, m_magic);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
