//+------------------------------------------------------------------+
//|                                 ExpertStdDevChannel.mq5          |
//|                        Copyright 2025, Clemence Benjamin         |
//|                           https://www.mql5.com/en/articles/20041 |
//+------------------------------------------------------------------+
#property copyright "Copyright 2025, Clemence Benjamin"
#property link      "https://www.mql5.com/go?link=https://www.mql5.com/en/users/billionaire2024/seller"
#property version   "1.00"
#property strict    

#include <ChartObjects\ChartObjectsChannels.mqh>
#include <Trade\Trade.mqh>  // For CTrade

//--- Inputs
input double   Deviation    = 2.0;        // StdDev multiplier
input int      PeriodBars   = 50;         // Bars for channel calculation
input double   LotSize      = 0.1;        // Trade size
input int      Magic        = 12345;      // EA identifier
input double   SLBuffer     = 20.0;       // Points buffer for SL (increased for min distance)
input bool     EnableSells  = true;       // Enable sell trades (set to false for buys only)
input bool     EnableBuys   = true;       // Enable buy trades
input bool     DrawGraphical= true;       // Draw channel object for visualization (disable for faster backtest)
input bool     UseMeanReversion = true;   // True: Mean reversion (bounce buys/sells); False: Breakout (break buys/sells)

//--- Global objects
CTrade         trade;
CChartObjectStdDevChannel *channel;       // Optional for drawing
double         g_upper, g_lower, g_median; // Manually computed levels
bool           g_levels_valid = false;    // Flag for valid computation

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
{
   trade.SetExpertMagicNumber(Magic);
   
   if (DrawGraphical)
   {
      channel = new CChartObjectStdDevChannel();
      if (!channel.Create(0, "StdDevChannel", 0,
                          iTime(_Symbol, PERIOD_CURRENT, PeriodBars),
                          iTime(_Symbol, PERIOD_CURRENT, 0),
                          Deviation))
      {
         Print("Failed to create graphical StdDev channel (continuing without viz)");
         delete channel;
         channel = NULL;
      }
      else
      {
         channel.Deviations(Deviation);
         Print("Graphical channel created for visualization");
      }
   }
   
   // Initial calculation
   if (UpdateChannel())
      g_levels_valid = true;
   else
      Print("Initial channel calculation failed - need more bars");
   
   Print("Channel EA initialized successfully. Mode: ", (UseMeanReversion ? "Mean Reversion" : "Breakout"));
   return INIT_SUCCEEDED;
}

//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
{
   // Static counter for skip logging (moved to function scope to avoid undeclared identifier)
   static int skip_count = 0;
   
   // Update on new bar
   if (IsNewBar())
   {
      if (!UpdateChannel())
      {
         Print("Channel update failed - skipping until valid");
         g_levels_valid = false;
         return;
      }
      g_levels_valid = true;
   }
   
   if (!g_levels_valid)
   {
      // Fallback: Recalc on tick if needed (rare)
      CalculateStdDevChannel();
      if (g_upper == 0.0 || g_lower == 0.0 || g_upper <= g_lower)
      {
         if (++skip_count % 100 == 0)  // Log every 100 ticks to avoid spam
            Print("Invalid manual channel values (", skip_count, " ticks skipped)");
         return;
      }
      // Reset counter on successful recalc
      skip_count = 0;
      g_levels_valid = true;
   }
   
   double bid = SymbolInfoDouble(_Symbol, SYMBOL_BID);
   double ask = SymbolInfoDouble(_Symbol, SYMBOL_ASK);
   double point = SymbolInfoDouble(_Symbol, SYMBOL_POINT);
   int digits = (int)SymbolInfoInteger(_Symbol, SYMBOL_DIGITS);
   
   // Validate levels
   if (g_upper <= g_lower)
   {
      Print("Invalid channel levels: Upper=", g_upper, " Lower=", g_lower, " - skipping tick");
      return;
   }
   
   // Get minimum stop distance
   long minStopLevel = SymbolInfoInteger(_Symbol, SYMBOL_TRADE_STOPS_LEVEL);
   double minDist = minStopLevel * point;
   
   // No open positions (check for this symbol and magic)
   if (PositionsTotalByMagic() == 0)
   {
      if (EnableBuys)
      {
         bool buySignal = false;
         if (UseMeanReversion)
         {
            // Mean reversion buy: Bounce off lower (current > lower, prior low <= lower)
            double prevLow = iLow(_Symbol, PERIOD_CURRENT, 1);
            buySignal = (bid > g_lower && prevLow <= g_lower);
         }
         else
         {
            // Breakout buy: Break above upper
            buySignal = (ask > g_upper);
         }
         
         if (buySignal)
         {
            double entry = ask;
            double sl = NormalizeDouble(g_lower - (SLBuffer * point), digits);
            double tp = NormalizeDouble(g_upper, digits);
            
            // Adjust SL to meet min distance
            if (entry - sl < minDist)
               sl = NormalizeDouble(entry - minDist, digits);
            
            // Check TP min distance
            if (tp - entry < minDist)
            {
               Print("TP too close for buy (dist=", (tp - entry)/point, " < ", minDist/point, ") - skipping");
            }
            else if (trade.Buy(LotSize, _Symbol, entry, sl, tp, "Channel Buy"))
            {
               Print("Buy order placed: Entry=", entry, " SL=", sl, " TP=", tp, " (TP > SL)");
            }
            else
            {
               Print("Buy order failed: ", trade.ResultRetcode(), " - ", trade.ResultRetcodeDescription());
            }
         }
      }
      
      if (EnableSells)
      {
         bool sellSignal = false;
         if (UseMeanReversion)
         {
            // Mean reversion sell: Bounce off upper (current < upper, prior high >= upper)
            double prevHigh = iHigh(_Symbol, PERIOD_CURRENT, 1);
            sellSignal = (ask < g_upper && prevHigh >= g_upper);
         }
         else
         {
            // Breakout sell: Break below lower
            sellSignal = (bid < g_lower);
         }
         
         if (sellSignal)
         {
            double entry = bid;
            double sl = NormalizeDouble(g_upper + (SLBuffer * point), digits);
            double tp = NormalizeDouble(g_lower, digits);
            
            // For sells: Ensure TP < SL (lower < upper + buffer, always true)
            if (tp >= sl)
            {
               Print("Invalid TP/SL for sell (TP=", tp, " >= SL=", sl, ") - logic error");
               return;
            }
            
            // Adjust SL to meet min distance
            if (sl - entry < minDist)
               sl = NormalizeDouble(entry + minDist, digits);
            
            // Check TP min distance (entry - tp >= minDist)
            double profitDist = entry - tp;
            if (profitDist < minDist)
            {
               Print("TP too close for sell (profit dist=", profitDist/point, " < ", minDist/point, ") - skipping");
            }
            else if (trade.Sell(LotSize, _Symbol, entry, sl, tp, "Channel Sell"))
            {
               Print("Sell order placed: Entry=", entry, " SL=", sl, " TP=", tp, " (TP < SL)");
            }
            else
            {
               Print("Sell order failed: ", trade.ResultRetcode(), " - ", trade.ResultRetcodeDescription());
               Print("Sell details: Entry=", entry, " SL=", sl, " TP=", tp, " MinDist=", minDist/point);
            }
         }
      }
   }
}

//+------------------------------------------------------------------+
//| Calculate StdDev Channel manually (linear regression + residuals)|
//+------------------------------------------------------------------+
void CalculateStdDevChannel()
{
   MqlRates rates[];
   ArraySetAsSeries(rates, true);
   int copied = CopyRates(_Symbol, PERIOD_CURRENT, 0, PeriodBars + 1, rates);  // +1 for safety
   if (copied < PeriodBars)
   {
      Print("Insufficient bars for calculation: ", copied, " < ", PeriodBars);
      g_upper = g_lower = g_median = 0.0;
      return;
   }
   
   // Use completed bars: shift 1 (last complete) to PeriodBars (oldest)
   int n = PeriodBars;
   double sum_x = 0.0, sum_y = 0.0, sum_xy = 0.0, sum_x2 = 0.0;
   
   for (int i = 1; i <= n; i++)  // i=1: last complete bar (x=n-1), i=n: oldest (x=0)
   {
      double x = n - i;  // x=0 (oldest) to x=n-1 (newest completed)
      double y = rates[i].close;
      sum_x += x;
      sum_y += y;
      sum_xy += x * y;
      sum_x2 += x * x;
   }
   
   // Linear regression slope (a) and intercept (b)
   double denom = (n * sum_x2 - sum_x * sum_x);
   if (denom == 0.0)
   {
      Print("Division by zero in regression - flat data?");
      g_upper = g_lower = g_median = 0.0;
      return;
   }
   double a = (n * sum_xy - sum_x * sum_y) / denom;
   double b = (sum_y - a * sum_x) / n;
   
   // Median (regression) at newest completed bar (x = n-1)
   g_median = a * (n - 1) + b;
   
   // Residuals sum of squares
   double sum_e2 = 0.0;
   for (int i = 1; i <= n; i++)
   {
      double x = n - i;
      double y_reg = a * x + b;
      double e = rates[i].close - y_reg;
      sum_e2 += e * e;
   }
   
   // StdDev of residuals (population, df = n-2 for regression fit)
   double stddev = (n > 2) ? MathSqrt(sum_e2 / (n - 2)) : 0.0;
   double offset = Deviation * stddev;
   
   g_upper = g_median + offset;
   g_lower = g_median - offset;
   
   Print("Manual Channel Calc: Median=", g_median, " Upper=", g_upper, " Lower=", g_lower, " StdDev=", stddev, " Offset=", offset);
}

//+------------------------------------------------------------------+
//| Update channel (manual + optional graphical)                     |
//+------------------------------------------------------------------+
bool UpdateChannel()
{
   CalculateStdDevChannel();  // Always manual
   
   if (g_upper == 0.0 || g_lower == 0.0 || g_upper <= g_lower)
      return false;
   
   // Optional graphical update
   if (DrawGraphical && channel != NULL)
   {
      datetime time1 = iTime(_Symbol, PERIOD_CURRENT, PeriodBars);
      datetime time2 = iTime(_Symbol, PERIOD_CURRENT, 0);
      ObjectDelete(0, "StdDevChannel");
      if (!channel.Create(0, "StdDevChannel", 0, time1, time2, Deviation))
      {
         Print("Failed to update graphical channel");
      }
      else
      {
         channel.Deviations(Deviation);
         Print("Graphical channel updated");
      }
   }
   
   return true;
}

//+------------------------------------------------------------------+
//| Count positions for this EA                                      |
//+------------------------------------------------------------------+
int PositionsTotalByMagic()
{
   int count = 0;
   for (int i = 0; i < PositionsTotal(); i++)
   {
      if (PositionGetSymbol(i) == _Symbol && PositionGetInteger(POSITION_MAGIC) == Magic)
         count++;
   }
   return count;
}

//+------------------------------------------------------------------+
//| Check for new bar                                                |
//+------------------------------------------------------------------+
bool IsNewBar()
{
   static datetime lastBarTime = 0;
   datetime currentBarTime = iTime(_Symbol, PERIOD_CURRENT, 0);
   if (currentBarTime != lastBarTime)
   {
      lastBarTime = currentBarTime;
      return true;
   }
   return false;
}

//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{
   if (DrawGraphical && channel != NULL)
   {
      ObjectDelete(0, "StdDevChannel");
      delete channel;
   }
   Print("Channel EA deinitialized");
}