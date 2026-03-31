//+------------------------------------------------------------------+
//|                      TrendFilter.mqh                             |
//|   Simple EMA-based trend constraint for strategies               |
//+------------------------------------------------------------------+
#ifndef __TREND_FILTER_MQH__
#define __TREND_FILTER_MQH__

class CTrendFilter
{
private:
   int                  m_period;
   ENUM_MA_METHOD       m_method;
   ENUM_APPLIED_PRICE   m_price;
   int                  m_handle;

public:
   CTrendFilter()
   {
      m_handle = INVALID_HANDLE;
   }

   bool Init(int period = 50,
             ENUM_MA_METHOD method = MODE_EMA,
             ENUM_APPLIED_PRICE price = PRICE_CLOSE)
   {
      m_period = period;
      m_method = method;
      m_price  = price;

      m_handle = iMA(_Symbol, _Period, m_period, 0, m_method, m_price);
      return (m_handle != INVALID_HANDLE);
   }

   double Value(int shift = 1)
   {
      if(m_handle == INVALID_HANDLE)
         return 0.0;

      double buffer[];
      if(CopyBuffer(m_handle, 0, shift, 1, buffer) <= 0)
         return 0.0;

      return buffer[0];
   }

   bool AllowBuy(double price)
   {
      double ma = Value(1);
      return (price > ma);
   }

   bool AllowSell(double price)
   {
      double ma = Value(1);
      return (price < ma);
   }

   void Release()
   {
      if(m_handle != INVALID_HANDLE)
      {
         IndicatorRelease(m_handle);
         m_handle = INVALID_HANDLE;
      }
   }
};

#endif // __TREND_FILTER_MQH__
