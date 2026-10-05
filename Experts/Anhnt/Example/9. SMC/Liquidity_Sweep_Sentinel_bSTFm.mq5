//+------------------------------------------------------------------+
//|                               Liquidity Sweep Sentinel (STF).mq5 |
//|                                             © 2026, ChukwuBuikem |
//|                            https://www.mql5.com/en/users/bikeen  |
//|                            https://www.mql5.com/en/articles/22140|
//+------------------------------------------------------------------+
#property copyright "© 2026, ChukwuBuikem"
#property link      "https://www.mql5.com/en/users/bikeen"
#property version   "1.00"
#property indicator_chart_window
#property  indicator_plots 0

#include <ChartObjects\ChartObjectsTxtControls.mqh>
#include <ChartObjects\ChartObjectsLines.mqh>

#define PROG_NAME "Liquidity Sweep Sentinel (STF)"
#define TRENDLINE PROG_NAME + "_Trendline"
#define TEXT PROG_NAME + "_Text"
#define CHART_ID ChartID()
#define MIN_WICK_RATIO 45

//--- Custom data structure
struct st_LiquiditySweep
  {
   //---+
   double            swingPrice;  //Swing point price
   datetime          swingTime;   //Swing point timestamp
   bool              swept;       //Swing point sweep flag
   // constructor
                     st_LiquiditySweep(): swingPrice(EMPTY_VALUE),
                     swingTime(LONG_MIN), swept(false) {}
  };

//--- Indicator settings
input int rightLeftBars = 3;                //Pivot strength (bars on each side)
input color buyLiquidityColor = clrRed;     //Color for buy-side liquidity
input color sellLiquidityColor = clrPurple; //Color for sell-side liquidity

//--- Global state variables
CChartObjectText text;
CChartObjectTrend trendLine;
int barIndex = -1;
st_LiquiditySweep buySideLiquidity, sellSideLiquidity;
st_LiquiditySweep sweeps[], violates[];

//+------------------------------------------------------------------+
//|                   Initialization function                        |
//+------------------------------------------------------------------+
int OnInit()
  {
//---
   MqlRates rates[];
   ArraySetAsSeries(rates, true);
   if(CopyRates(_Symbol, PERIOD_CURRENT, 0, iBars(_Symbol, PERIOD_CURRENT), rates) > 0)
     {
      if((barIndex = getNextSwingHighIndex(rightLeftBars, iHigh(_Symbol, PERIOD_CURRENT, 1))) != -1)
        {
         buySideLiquidity.swept = false;
         buySideLiquidity.swingPrice = rates[barIndex].high;
         buySideLiquidity.swingTime = rates[barIndex].time;
        }
      if((barIndex = getNextSwingLowIndex(rightLeftBars, iLow(_Symbol, PERIOD_CURRENT, 1))) != -1)
        {
         sellSideLiquidity.swept = false;
         sellSideLiquidity.swingPrice = rates[barIndex].low;
         sellSideLiquidity.swingTime = rates[barIndex].time;
        }
     }
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//|                   Deinitialization function                      |
//+------------------------------------------------------------------+
void OnDeinit(const int32_t reason)
  {
//--- Clear chart
   ObjectsDeleteAll(CHART_ID, PROG_NAME);
   ChartRedraw(CHART_ID);
  }
//+------------------------------------------------------------------+
//|               Core Engine (OnCalculate)                          |
//+------------------------------------------------------------------+
int OnCalculate(const int32_t rates_total,
                const int32_t prev_calculated,
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int32_t &spread[])
  {
//---
   if(isNewCandle(time[rates_total - 1]))
     {
      ArraySetAsSeries(open, true);
      ArraySetAsSeries(high, true);
      ArraySetAsSeries(low, true);
      ArraySetAsSeries(close, true);
      ArraySetAsSeries(time, true);
      //--- SWEEP DETECTION
      //--- Buy-side liquidity sweeps: Wick and Dual-candle sweep
      if((!buySideLiquidity.swept &&  high[1] >= buySideLiquidity.swingPrice &&
          close[1] < buySideLiquidity.swingPrice && open[1] < buySideLiquidity.swingPrice &&
          upperWickRatio(open[1], high[1], low[1], close[1]) >= MIN_WICK_RATIO) ||
         (!buySideLiquidity.swept &&  close[2] > buySideLiquidity.swingPrice &&
          close[1] < buySideLiquidity.swingPrice && isBearishEngulfing(open[1], close[1], open[2], close[2])))
        {
         if(!isExist(buySideLiquidity.swingTime, sweeps) && !isExist(buySideLiquidity.swingTime, violates))
           {
            buySideLiquidity.swept = true;
            //--- Append to sweep array
            if(!append(buySideLiquidity, sweeps))
              {
               Print("[RUNTIME]: Failed to append buy-side LQ to sweep array.");
              }
            //--- Mark level with trendline and text
            drawTrendline(TRENDLINE + "Buy-side", buySideLiquidity.swingTime, buySideLiquidity.swingPrice, time[1],
                          buySideLiquidity.swingPrice, buyLiquidityColor, 2, "Buy-side LQ");
            createText(TEXT + "Buy-side", buySideLiquidity.swingTime + PeriodSeconds(),
                       buySideLiquidity.swingPrice + (20 * _Point), buyLiquidityColor, "Buy-side LQ");
            ChartRedraw(CHART_ID);
           }
         //--- Scan for older swing high (next liquidity target)
         if((barIndex = getNextSwingHighIndex(iBarShift(_Symbol, PERIOD_CURRENT, buySideLiquidity.swingTime),
                                              buySideLiquidity.swingPrice)) != -1)
           {
            buySideLiquidity.swingPrice = high[barIndex];
            buySideLiquidity.swingTime = time[barIndex];
            buySideLiquidity.swept = false;
           }
         return rates_total;
        }
      //--- Sell-side liquidity sweeps: Wick and Dual-candle sweep
      if((!sellSideLiquidity.swept && low[1] <= sellSideLiquidity.swingPrice &&
          close[1] > sellSideLiquidity.swingPrice && open[1] > sellSideLiquidity.swingPrice &&
          lowerWickRatio(open[1], high[1], low[1], close[1]) >= MIN_WICK_RATIO) ||
         (!sellSideLiquidity.swept && close[2] < sellSideLiquidity.swingPrice &&
          close[1] > sellSideLiquidity.swingPrice && isBullishEngulfing(open[1], close[1], open[2], close[2])))
        {
         if(!isExist(sellSideLiquidity.swingTime, sweeps) && !isExist(sellSideLiquidity.swingTime, violates))
           {
            sellSideLiquidity.swept = true;
            //--- Append to sweep array
            if(!append(sellSideLiquidity, sweeps))
              {
               Print("[RUNTIME]: Failed to append sell-side LQ to sweep array.");
              }
            //--- Mark level with trendline and text
            drawTrendline(TRENDLINE + "Sell-Side", sellSideLiquidity.swingTime, sellSideLiquidity.swingPrice, time[1],
                          sellSideLiquidity.swingPrice, sellLiquidityColor, 2, "Sell-side LQ");
            createText(TEXT + "Sell-Side", sellSideLiquidity.swingTime + PeriodSeconds(),
                       sellSideLiquidity.swingPrice - (10 * _Point), sellLiquidityColor, "Sell-side LQ");
            ChartRedraw(CHART_ID);
           }
         //--- Scan for older swing low (next liquidity target)
         if((barIndex = getNextSwingLowIndex(iBarShift(_Symbol, PERIOD_CURRENT, sellSideLiquidity.swingTime),
                                             sellSideLiquidity.swingPrice)) != -1)
           {
            sellSideLiquidity.swingPrice = low[barIndex];
            sellSideLiquidity.swingTime = time[barIndex];
            sellSideLiquidity.swept = false;
           }
         return rates_total;
        }
      //--- SWEEP VIOLATION
      //--- Buy-side liquidity violation
      if((!buySideLiquidity.swept && close[2] > buySideLiquidity.swingPrice && close[1] > buySideLiquidity.swingPrice) ||
         (!buySideLiquidity.swept &&  close[2] > buySideLiquidity.swingPrice && close[1] < buySideLiquidity.swingPrice &&
          !isBearishEngulfing(open[1], close[1], open[2], close[2])) ||
         (!buySideLiquidity.swept && close[1] > buySideLiquidity.swingPrice))
        {
         buySideLiquidity.swept = true;
         //--- Append to violate array
         if(!append(buySideLiquidity, violates))
           {
            Print("[RUNTIME]: Failed to append buy-side LQ to violate array.");
           }
         //--- Scan for older swing high (next liquidity target)
         if((barIndex = getNextSwingHighIndex(iBarShift(_Symbol, PERIOD_CURRENT, buySideLiquidity.swingTime),
                                              buySideLiquidity.swingPrice)) != -1)
           {
            //--- Update buy side liquidity structure
            buySideLiquidity.swingPrice = high[barIndex];
            buySideLiquidity.swingTime = time[barIndex];
            buySideLiquidity.swept = false;
           }
         return rates_total;
        }
      //--- Sell-side liquidity violation
      if((!sellSideLiquidity.swept && close[2] < sellSideLiquidity.swingPrice && close[1] < sellSideLiquidity.swingPrice) ||
         (!sellSideLiquidity.swept &&  close[2] < sellSideLiquidity.swingPrice && close[1] > buySideLiquidity.swingPrice &&
          !isBullishEngulfing(open[1], close[1], open[2], close[2])) ||
         (!sellSideLiquidity.swept && close[1] < sellSideLiquidity.swingPrice))
        {
         sellSideLiquidity.swept = true;
         //--- Append to violate array
         if(!append(sellSideLiquidity, violates))
           {
            Print("[RUNTIME]: Failed to append sell-side LQ to violate array.");
           }
         //--- Scan for older swing low (next liquidity target)
         if((barIndex = getNextSwingLowIndex(iBarShift(_Symbol, PERIOD_CURRENT, sellSideLiquidity.swingTime),
                                             sellSideLiquidity.swingPrice)) != -1)
           {
            //--- Update sell side liquidity structure
            sellSideLiquidity.swingPrice = low[barIndex];
            sellSideLiquidity.swingTime = time[barIndex];
            sellSideLiquidity.swept = false;
           }
         return rates_total;
        }
      //--- NEWER SWING POINT SEARCH
      //--- Scan for swing highs closer to market price
      if((barIndex = getNextSwingHighIndex(rightLeftBars, iHigh(_Symbol, PERIOD_CURRENT, 1)))
         != -1 && time[barIndex] > buySideLiquidity.swingTime)
        {
         //--- Update buy side liquidity structure
         buySideLiquidity.swingPrice = high[barIndex];
         buySideLiquidity.swingTime = time[barIndex];
         buySideLiquidity.swept = false;
         return rates_total;
        }
      //--- Scan for swing lows closer to market price
      if((barIndex = getNextSwingLowIndex(rightLeftBars, iLow(_Symbol, PERIOD_CURRENT, 1)))
         != -1 && time[barIndex] > sellSideLiquidity.swingTime)
        {
         //--- Update sell side liquidity structure
         sellSideLiquidity.swingPrice = low[barIndex];
         sellSideLiquidity.swingTime = time[barIndex];
         sellSideLiquidity.swept = false;
         return rates_total;
        }
     }
   return(rates_total);
  }
//+------------------------------------------------------------------+
//|                  New candle detection                            |
//+------------------------------------------------------------------+
bool isNewCandle(const datetime newOpenTime)
  {
//---
   static datetime lastOpenTime = LONG_MIN;
   if(lastOpenTime == LONG_MIN)
     {
      lastOpenTime = newOpenTime;
      return false;
     }
   if(lastOpenTime != newOpenTime)
     {
      lastOpenTime = newOpenTime;
      return true;
     }
   return false;
  }
//+------------------------------------------------------------------+
//|                Swing high detection                              |
//+------------------------------------------------------------------+
bool isSwingHigh(const int index, const MqlRates &rates[])
  {
//---
   int totalBars = ArraySize(rates);
//--- Index boundary validation
   if(index < rightLeftBars)
      return false;
   if(index >= totalBars - rightLeftBars)
      return false;

   for(int w = 1; w <= rightLeftBars && (index - w) >= 1; w++)
     {
      //--- Look right
      if(rates[index].high < rates[index - w].high)
         return false;
      //--- Look left
      if(rates[index].high < rates[index + w].high)
         return false;
     }
   return true;
  }
//+------------------------------------------------------------------+
//|                 Swing low detection                              |
//+------------------------------------------------------------------+
bool isSwingLow(const int index, const MqlRates &rates[])
  {
//---
   int totalBars = ArraySize(rates);
//--- Index boundary validation
   if(index < rightLeftBars)
      return false;
   if(index >= totalBars - rightLeftBars)
      return false;

   for(int w = 1; w <= rightLeftBars && (index - w) >= 1; w++)
     {
      if(index - w < 1)
         return false;
      //--- Look right
      if(rates[index].low > rates[index - w].low)
         return false;
      //--- Look left
      if(rates[index].low > rates[index + w].low)
         return false;
     }
   return true;
  }
//+------------------------------------------------------------------+
//|            Obtain the index of next swing high                   |
//+------------------------------------------------------------------+
int getNextSwingHighIndex(const int startIndex, const double minPrice)
  {
//---
   MqlRates rates[] = {};
   ArraySetAsSeries(rates, true);
   int bars = Bars(_Symbol, PERIOD_CURRENT);
   if(CopyRates(_Symbol, PERIOD_CURRENT, 0, bars, rates) < bars)
      return -1;

   for(int w = startIndex + 1; w <= bars - (rightLeftBars + 1); w++)
     {
      if(isSwingHigh(w, rates))
         //--- High must be higher than minimum price
         if(rates[w].high > minPrice)
            return w;
     }
   return -1;// Invalid index
  }
//+------------------------------------------------------------------+
//|            Obtain the index of next swing low                    |
//+------------------------------------------------------------------+
int getNextSwingLowIndex(const int startIndex, const double maxPrice)
  {
//---
   MqlRates rates[] = {};
   ArraySetAsSeries(rates, true);
   int bars = Bars(_Symbol, PERIOD_CURRENT);

   if(CopyRates(_Symbol, PERIOD_CURRENT, 0, bars, rates) < bars)
      return -1;

   for(int w = startIndex + 1; w <= bars - (rightLeftBars + 1); w++)
     {
      if(isSwingLow(w, rates))
         //--- Low must be lower than Maximum price
         if(rates[w].low < maxPrice)
            return w;
     }
   return -1;// Invalid index
  }
//+------------------------------------------------------------------+
//|              Bullish engulfing detection                         |
//+------------------------------------------------------------------+
bool isBullishEngulfing(const double currOpen, const double currClose,
                        const double prevOpen, const double prevClose)
  {
//---
   return (prevClose < prevOpen && currClose > currOpen
           && currOpen <= prevClose && currClose > prevOpen);
  }
//+------------------------------------------------------------------+
//|              Bearish engulfing detection                         |
//+------------------------------------------------------------------+
bool isBearishEngulfing(const double currOpen, const double currClose,
                        const double prevOpen, const double prevClose)
  {
//---
   return (prevClose > prevOpen && currClose < currOpen &&
           currOpen >= prevClose && currClose < prevOpen);
  }
//+------------------------------------------------------------------+
//|             Upper wick ratio validation                          |
//+------------------------------------------------------------------+
int upperWickRatio(const double open, const double high,
                   const double low, const double close)
  {
//---
   double candleRange = high - low;
   double ratio = (high - MathMax(open, close)) / candleRange;
   ratio = NormalizeDouble(ratio, 2);

   return (int)(ratio * 100);
  }
//+------------------------------------------------------------------+
//|                Lower wick ratio validation                       |
//+------------------------------------------------------------------+
int lowerWickRatio(const double open, const double high,
                   const double low, const double close)
  {
//---
   double candleRange = high - low;
   double ratio = (MathMin(open, close) - low) / candleRange;
   ratio = NormalizeDouble(ratio, 2);

   return (int)(ratio * 100);
  }
//+------------------------------------------------------------------+
//|                     Storage helper                               |
//+------------------------------------------------------------------+
bool append(const st_LiquiditySweep &value, st_LiquiditySweep &destArr[])
  {
//---
   if(ArrayResize(destArr, ArraySize(destArr) + 1) == -1)
      return false;

   destArr[ArraySize(destArr) - 1] = value;

   return true;
  }
//+------------------------------------------------------------------+
//|                        Search helper                             |
//+------------------------------------------------------------------+
bool isExist(const datetime swingTime, const st_LiquiditySweep &searchArr[])
  {
//---
   for(int w = ArraySize(searchArr) - 1; w >= 0; w--)
     {
      if(searchArr[w].swingTime == swingTime)
        {
         return true;
        }
     }
   return false;
  }
//+------------------------------------------------------------------+
//|                   Trendline creation                             |
//+------------------------------------------------------------------+
void drawTrendline(const string objName, const datetime time1,
                   const double price1, const datetime time2,
                   const double price2, const color clr,
                   const int width, const string tooltip)
  {
//---
   if(trendLine.Create(CHART_ID, objName, 0, time1, price1, time2, price2))
     {
      trendLine.Color(clr);
      trendLine.Width(width);
      trendLine.Tooltip(tooltip);
      trendLine.SetInteger(OBJPROP_HIDDEN, true);
     }
  }
//+------------------------------------------------------------------+
//|                     Text creation                                |
//+------------------------------------------------------------------+
void createText(const string objName, const datetime time,
                const double price, const color clr, const string display,
                const int fontSize = 10, const string font = "Arial")
  {
//---
   if(text.Create(CHART_ID, objName, 0, time, price))
     {
      text.Color(clr);
      text.Font(font);
      text.FontSize(fontSize);
      text.Tooltip(display);
      text.SetString(OBJPROP_TEXT, display);
      text.SetInteger(OBJPROP_HIDDEN, true);
     }
  }
//+------------------------------------------------------------------+
