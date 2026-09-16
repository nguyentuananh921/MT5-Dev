//+------------------------------------------------------------------+
//|                                   Trailing Stops & BreakEven.mq5 |
//|                                     Copyright 2026, Omega Joctan |
//|                 https://www.mql5.com/en/users/omegajoctan/seller |
//+------------------------------------------------------------------+
#property copyright "Copyright 2026, Omega Joctan"
#property link      "https://www.mql5.com/en/users/omegajoctan/seller"
#property version   "1.00"
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
#include "Bootstrap\Trailing\TrailingMA.mqh"
#include "Bootstrap\Trailing\TrailingSAR.mqh"
#include "Bootstrap\Trailing\TrailingATR.mqh"
#include "Bootstrap\Trailing\TrailingFixedPoints.mqh"
#include "Bootstrap\Trailing\TrailingPeriodic.mqh"
#include "Bootstrap\Trailing\TrailingMoney.mqh"
#include "Bootstrap\positions.mqh"
#include <Trade\SymbolInfo.mqh>

CTrade m_trade;
CSymbolInfo m_symbol;

#define sym Symbol()
#define MAGIC_NUMBER 112233
int ma_handle, sar_handle, atr_handle;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
input uint TRAILING_STEP = 200;
input uint TRAILING_STOP = 20;
input uint STOPLOSS = 500;
input uint TAKEPROFIT = 500;
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//---

   m_symbol.Name(sym);
   m_trade.SetExpertMagicNumber(MAGIC_NUMBER);
   m_trade.SetTypeFillingBySymbol(sym);
   m_trade.SetDeviationInPoints(100);


//---
   /*
      ma_handle = iMA(sym, PERIOD_CURRENT, 20, 0, MODE_SMA, PRICE_CLOSE);
      if(ma_handle == INVALID_HANDLE)
        {
         printf("Invalid MA handle. Error = %d", GetLastError());
         return INIT_FAILED;
        }

      ChartIndicatorAdd(0, 0, ma_handle); //Attach the indicator to the chart

   //---

   sar_handle = iSAR(sym, PERIOD_CURRENT, 0.02, 0.2);
   if(sar_handle == INVALID_HANDLE)
     {
      printf("Invalid SAR handle. Error = %d", GetLastError());
      return INIT_FAILED;
     }

   //ChartIndicatorAdd(0, 0, sar_handle);

   //---

      atr_handle = iATR(sym, PERIOD_CURRENT, 13);

      if(atr_handle == INVALID_HANDLE)
        {
         printf("Invalid ATR handle. Error = %d", GetLastError());
         return INIT_FAILED;
        }

      //ChartIndicatorAdd(0, 1, atr_handle);
   */

//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//---

  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {

   if(!m_symbol.RefreshRates())
      return;

//---

   double lots = m_symbol.LotsMin();
   double ask = m_symbol.Ask(), bid = m_symbol.Bid();
   double pts = m_symbol.Point();

//---

   if(!PositionExistsByType(POSITION_TYPE_BUY))
      m_trade.Buy(lots, sym, ask, ask - STOPLOSS * pts);

//CTrailingMA::TrailStops(ma_handle, sym, MAGIC_NUMBER); //Trailing stop based on the moving average
//CTrailingSAR::TrailStops(sar_handle, sym, MAGIC_NUMBER);
//CTrailingMoney::TrailStops(sym, 5, 1, MAGIC_NUMBER);

   CTrailingPeriodic::TrailStops(3600, 100, sym, MAGIC_NUMBER);

//if(!PositionExistsByType(POSITION_TYPE_SELL))
//   m_trade.Sell(lots, sym, bid, bid + STOPLOSS * pts);

//CTrailingPercent::TrailStops(sym, 30, 10, MAGIC_NUMBER);
//CTrailingATR::TrailStops(atr_handle, sym, 1, 0.4);
//CTrailingFixedPoints::TrailStops(sym, TRAILING_STOP, TRAILING_STEP, MAGIC_NUMBER);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
