//+------------------------------------------------------------------+
//|                                                   TrailingMA.mqh |
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
class CTrailingMA
  {
protected:
   int               m_handle;
   long              m_magic;
   string            m_symbol;

public:
                     CTrailingMA(const int handle, const string symbol, const long magic=-1);
                    ~CTrailingMA(void);

   void              TrailStops();
   static void       TrailStops(int handle, string symbol, long magic = -1);
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
CTrailingMA::CTrailingMA(const int handle, const string symbol, const long magic=-1):
   m_handle(handle),
   m_magic(magic),
   m_symbol(symbol)
  {

  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
CTrailingMA::~CTrailingMA(void)
  {

  }
//+------------------------------------------------------------------+
//| Trail open positions using a Moving Average.                     |
//|                                                                  |
//| The stop loss is adjusted to the current value of a Moving       |
//| Average indicator. 
//|                                                                  |
//| Parameters:                                                      |
//|   handle - Handle of the Moving Average indicator created using  |
//|            iMA() or IndicatorCreate().                           |
//|   symbol - Trading symbol whose positions will be managed.       |
//|   magic  - Magic number used to filter positions. Specify -1 to  |
//|            trail all positions on the specified symbol.          |
//|                                                                  |
//+------------------------------------------------------------------+
void CTrailingMA::TrailStops(int handle, string symbol, long magic = -1)
  {
   double point = SymbolInfoDouble(symbol, SYMBOL_POINT);
   CPositionInfo pos;

   CTrade trade;

//---

   double ma[];
   if(!CopyBuffer(handle, 0, 0, 1, ma))
      return;

   double ma_value = ma[0];

//---

   for(int i = PositionsTotal() - 1; i >= 0; i--)
     {
      if(!pos.SelectByIndex(i))
         continue;

      if(pos.Symbol() != symbol)
         continue;

      double sl = pos.StopLoss(),
             open_price = pos.PriceOpen();

      ulong ticket = pos.Ticket();
      ENUM_POSITION_TYPE type = pos.PositionType();
      double tp = pos.TakeProfit();

      //---

      switch(type)
        {
         case  POSITION_TYPE_BUY:
           {
            if(!isPositionModificationSameLevels(ticket, ma_value, tp))
               continue;

            //--- Modify only when the moving average is above the current sl
            if(sl != 0 && ma_value <= sl)
               continue;

            if(!isValidStoploss_Takeprofit(ORDER_TYPE_BUY, ma_value, tp, symbol))
               continue;

            trade.PositionModify(ticket, ma_value, tp);
           }
         break;
         case  POSITION_TYPE_SELL:
           {
            if(!isPositionModificationSameLevels(ticket, ma_value, tp))
               continue;

            //--- Modify only when the moving average is below the current sl
            if(sl != 0 && ma_value >= sl)
               continue;

            if(!isValidStoploss_Takeprofit(ORDER_TYPE_SELL, ma_value, tp, symbol))
               continue;

            trade.PositionModify(ticket, ma_value, tp);
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
void CTrailingMA::TrailStops()
  {
   CTrailingMA::TrailStops(m_handle, m_symbol, m_magic);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
