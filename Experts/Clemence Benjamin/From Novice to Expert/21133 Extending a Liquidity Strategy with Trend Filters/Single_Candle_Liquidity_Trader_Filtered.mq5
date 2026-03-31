//+------------------------------------------------------------------+
//|        Single_Candle_Liquidity_Trader_Filtered.mq5               |
//|   Liquidity Compression → Trend-Aligned Continuation             |
//+------------------------------------------------------------------+
#property copyright "Clemence Benjamin"
#property version   "1.10"
#property strict

#include <Trade/Trade.mqh>
#include <TrendFilter.mqh>

CTrade       trade;
CTrendFilter trend;

//-------------------- INPUTS
input double LotSize             = 0.10;
input int    MaxSpreadPoints     = 30;
input bool   AllowBuy            = true;
input bool   AllowSell           = true;
input double RatioMultiplier     = 3.0;
input double SL_Offset_Points    = 20;
input int    PendingExpiryHours  = 24;
input int    TrendMAPeriod       = 50;
input ulong  MagicNumber         = 777333;

//-------------------- GLOBALS
datetime lastBarTime = 0;

//+------------------------------------------------------------------+
//| Expert initialization                                           |
//+------------------------------------------------------------------+
int OnInit()
{
   if(!trend.Init(TrendMAPeriod))
   {
      Print("Failed to initialize trend filter");
      return INIT_FAILED;
   }
   return INIT_SUCCEEDED;
}

//+------------------------------------------------------------------+
//| Expert deinitialization                                         |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{
   trend.Release();
}

//+------------------------------------------------------------------+
//| Detect new bar                                                   |
//+------------------------------------------------------------------+
bool IsNewBar()
{
   datetime currentBar = iTime(_Symbol, _Period, 0);
   if(currentBar != lastBarTime)
   {
      lastBarTime = currentBar;
      return true;
   }
   return false;
}

//+------------------------------------------------------------------+
//| Candle range                                                     |
//+------------------------------------------------------------------+
double CandleRange(int index)
{
   return MathAbs(iHigh(_Symbol,_Period,index) -
                  iLow(_Symbol,_Period,index));
}

//+------------------------------------------------------------------+
//| Place Buy Limit orders                                          |
//+------------------------------------------------------------------+
void PlaceBuyLimits(double highB, double lowB, double sl, double tp, datetime expiry)
{
   double mid = (highB + lowB) / 2.0;

   trade.BuyLimit(LotSize, highB, _Symbol, sl, tp, ORDER_TIME_SPECIFIED, expiry);
   trade.BuyLimit(LotSize, mid,   _Symbol, sl, tp, ORDER_TIME_SPECIFIED, expiry);
   trade.BuyLimit(LotSize, lowB,  _Symbol, sl, tp, ORDER_TIME_SPECIFIED, expiry);
}

//+------------------------------------------------------------------+
//| Place Sell Limit orders                                         |
//+------------------------------------------------------------------+
void PlaceSellLimits(double highB, double lowB, double sl, double tp, datetime expiry)
{
   double mid = (highB + lowB) / 2.0;

   trade.SellLimit(LotSize, highB, _Symbol, sl, tp, ORDER_TIME_SPECIFIED, expiry);
   trade.SellLimit(LotSize, mid,   _Symbol, sl, tp, ORDER_TIME_SPECIFIED, expiry);
   trade.SellLimit(LotSize, lowB,  _Symbol, sl, tp, ORDER_TIME_SPECIFIED, expiry);
}

//+------------------------------------------------------------------+
//| Expert tick                                                      |
//+------------------------------------------------------------------+
void OnTick()
{
   if(!IsNewBar())
      return;

   if(SymbolInfoInteger(_Symbol, SYMBOL_SPREAD) > MaxSpreadPoints)
      return;

   trade.SetExpertMagicNumber(MagicNumber);

   int A = 1;   // Impulse candle
   int B = 2;   // Base candle

   double rangeA = CandleRange(A);
   double rangeB = CandleRange(B);

   if(rangeB > rangeA / RatioMultiplier)
      return;

   double openA  = iOpen(_Symbol,_Period,A);
   double closeA = iClose(_Symbol,_Period,A);
   double openB  = iOpen(_Symbol,_Period,B);
   double closeB = iClose(_Symbol,_Period,B);

   double highA = iHigh(_Symbol,_Period,A);
   double lowA  = iLow(_Symbol,_Period,A);
   double highB = iHigh(_Symbol,_Period,B);
   double lowB  = iLow(_Symbol,_Period,B);

   double point  = SymbolInfoDouble(_Symbol, SYMBOL_POINT);
   double offset = SL_Offset_Points * point;

   datetime expiry = TimeCurrent() + PendingExpiryHours * 3600;

   //==================== BULLISH SETUP ====================
   if(AllowBuy && closeA > openA && closeB > openB)
   {
      if(trend.AllowBuy(lowB))   // 🔒 trend constraint
      {
         double sl = lowB - offset;
         double tp = highA;

         PlaceBuyLimits(highB, lowB, sl, tp, expiry);
      }
   }

   //==================== BEARISH SETUP ====================
   if(AllowSell && closeA < openA && closeB < openB)
   {
      if(trend.AllowSell(highB)) // 🔒 trend constraint
      {
         double sl = highB + offset;
         double tp = lowA;

         PlaceSellLimits(highB, lowB, sl, tp, expiry);
      }
   }
}
