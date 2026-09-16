//+------------------------------------------------------------------+
//|                                                  TrailingATR.mqh |
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
class CTrailingATR
  {
protected:
   int               m_handle;
   string            m_symbol;
   long               m_magic;

public:
                     CTrailingATR(int handle, string symbol, long magic = -1);
                    ~CTrailingATR(void);

   static void       TrailStops(int handle, string symbol, double stop_atr_multiplier = 0.5, double step_atr_multiplier = 0.2, long magic = -1);
   void              TrailStops(double stop_atr_multiplier = 0.5, double step_atr_multiplier = 0.2);
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
CTrailingATR::CTrailingATR(int handle, string symbol, long magic = -1):
 m_handle(handle),
 m_symbol(symbol),
 m_magic(magic)
 {
 
 }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
CTrailingATR::~CTrailingATR(void)
 {
 
 }
//+------------------------------------------------------------------+
//| Trail open positions using the Average True Range (ATR).         |
//|                                                                  |
//| Trailing is based on the current market volatility as measured   |
//| by the Average True Range (ATR). 
//|                                                                  |
//| Parameters:                                                      |
//|   handle              - Handle of the ATR indicator created      |
//|                         using iATR() or IndicatorCreate().       |
//|   symbol              - Trading symbol whose positions will be   |
//|                         managed.                                 |
//|   stop_atr_multiplier - ATR multiple required before trailing    |
//|                         is activated.                            |
//|   step_atr_multiplier - ATR multiple maintained between the      |
//|                         current market price and the stop loss.  |
//|   magic               - Magic number used to filter positions.   |
//|                         Specify -1 to trail all positions on     |
//|                         the symbol.                              |
//|                                                                  |
//+------------------------------------------------------------------+
void CTrailingATR::TrailStops(int handle,
                              string symbol,
                              double stop_atr_multiplier = 0.5,
                              double step_atr_multiplier = 0.2,
                              long magic = -1)
  {
   CPositionInfo pos;
   CTrade trade;

//---

   double atr_buff[];
   if(!CopyBuffer(handle, 0, 0, 1, atr_buff))
      return;

   double atr_value = atr_buff[0];

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

      switch(type)
        {
         case  POSITION_TYPE_BUY:
           {
            //--- Ensure the position has moved enough
            double bid = SymbolInfoDouble(symbol, SYMBOL_BID);
            if(bid - open_price < atr_value * stop_atr_multiplier)
               continue;

            double new_sl = bid - atr_value * step_atr_multiplier;

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
            double ask = SymbolInfoDouble(symbol, SYMBOL_ASK);

            //--- Ensure the positoin has moved enough
            if(open_price - ask < atr_value * stop_atr_multiplier)
               continue;

            double new_sl = ask + atr_value * step_atr_multiplier;

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
void CTrailingATR::TrailStops(double stop_atr_multiplier=0.500000,double step_atr_multiplier=0.200000)
 {
   CTrailingATR::CTrailingATR(m_handle, m_symbol, m_magic);
 }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

