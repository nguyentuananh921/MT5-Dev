//+------------------------------------------------------------------+
//|                                                  TrailingSAR.mqh |
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
class CTrailingSAR
  {
protected:
   int               m_handle;
   string            m_symbol;
   long            m_magic;

public:
                     CTrailingSAR(int handle, string symbol, long magic = -1);
                    ~CTrailingSAR(void);

   void              TrailStops();
   static void       TrailStops(int handle, string symbol, long magic = -1);
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
CTrailingSAR::CTrailingSAR(int handle, string symbol, long magic = -1):
 m_handle(handle),
 m_symbol(symbol),
 m_magic(magic)
  {

  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
CTrailingSAR::~CTrailingSAR(void)
  {

  }
//+------------------------------------------------------------------+
//| Trail open positions using the Parabolic SAR indicator.          |
//|                                                                  |
//| The stop loss is adjusted to the latest value of the Parabolic   |
//| SAR (Stop and Reverse) indicator.                                |
//|                                                                  |
//| Parameters:                                                      |
//|   handle - Handle of the Parabolic SAR indicator created using   |
//|            iSAR() or IndicatorCreate().                          |
//|   symbol - Trading symbol whose positions will be managed.       |
//|   magic  - Magic number used to filter positions. Specify -1 to  |
//|            trail all positions on the specified symbol.          |
//|                                                                  |
//+------------------------------------------------------------------+
void CTrailingSAR::TrailStops(int handle, string symbol, long magic = -1)
  {
   double point = SymbolInfoDouble(symbol, SYMBOL_POINT);
   CPositionInfo pos;

   CTrade trade;

//---

   double sar_buff[];
   if(!CopyBuffer(handle, 0, 0, 1, sar_buff))
      return;

   double sar_value = sar_buff[0];

//---

   for(int i = PositionsTotal() - 1; i >= 0; i--)
     {
      if(!pos.SelectByIndex(i))
         continue;

      if(pos.Symbol() != symbol)
         continue;

      double sl = pos.StopLoss(), tp = pos.TakeProfit(), open_price = pos.PriceOpen();

      ulong ticket = pos.Ticket();
      ENUM_POSITION_TYPE type = pos.PositionType();

      //---

      switch(type)
        {
         case  POSITION_TYPE_BUY:
           {
            if(!isPositionModificationSameLevels(ticket, sar_value, tp))
               continue;

            //--- Modify only when the SAR is above the current sl
            if(sl != 0 && sar_value <= sl)
               continue;

            if(!isValidStoploss_Takeprofit(ORDER_TYPE_BUY, sar_value, tp, symbol))
               continue;

            trade.PositionModify(ticket, sar_value, tp);
           }
         break;
         case  POSITION_TYPE_SELL:
           {
            if(!isPositionModificationSameLevels(ticket, sar_value, tp))
               continue;

            //--- Modify only when the SAR is below the current sl
            if(sl != 0 && sar_value >= sl)
               continue;

            if(!isValidStoploss_Takeprofit(ORDER_TYPE_SELL, sar_value, tp, symbol))
               continue;

            trade.PositionModify(ticket, sar_value, tp);
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
void CTrailingSAR::TrailStops()
  {
   CTrailingSAR::TrailStops(m_handle, m_symbol, m_magic);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
