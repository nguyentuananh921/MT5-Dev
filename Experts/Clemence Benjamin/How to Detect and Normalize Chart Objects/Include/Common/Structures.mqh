//+------------------------------------------------------------------+
//|                                                 Structures.mqh   |
//|                                Copyright 2026, Clemence Benjamin |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2026, Clemence Benjamin"
#property link      "https://www.mql5.com"

//+------------------------------------------------------------------+
//| Swing point structure                                            |
//+------------------------------------------------------------------+
struct SSwingPoint
{
   int            bar;          // bar index
   datetime       time;         // bar time
   double         price;        // price at swing point
   bool           isHigh;       // true if swing high, false if swing low
};

//+------------------------------------------------------------------+
//| Market snapshot structure                                        |
//+------------------------------------------------------------------+
struct MarketSnapshot
{
   double         open;
   double         high;
   double         low;
   double         close;
   double         bid;
   double         ask;
   datetime       time;
};

//+------------------------------------------------------------------+
//| Trade signal structure                                           |
//| Enhanced for Part 5: Added signalTime for timestamp tracking    |
//+------------------------------------------------------------------+
struct TradeSignal
{
   string         objectName;
   ENUM_OBJECT    objectType;
   ENUM_ORDER_TYPE orderType;
   double         entryPrice;
   double         stopLoss;
   double         takeProfit;
   double         confidence;     // 0.0 to 1.0
   string         reason;
   bool           isValid;
   datetime       signalTime;     // Time when signal was generated
};