//+------------------------------------------------------------------+
//|                                                     TurtleEA.mq5 |
//|                                Copyright 2026, Tola Moses Hector |
//|                                          https://t.me/tolahector |
//+------------------------------------------------------------------+
//|Automating Classic Market                                         |
//|1. Wyckoff Accumulation and Distribution                          |
//|                           https://www.mql5.com/en/articles/22628 |
//|2. Wyckoff Cause and Effect—Point and Figure Price Targets        |
//|                           https://www.mql5.com/en/articles/22472 |
//|3.Stan Weinstein Stage Analysis                                   |
//|                           https://www.mql5.com/en/articles/22746 |
//|4.Mark Minervini's Trend Template                                |
//|                           https://www.mql5.com/en/articles/22790 |
//|5.The Original Turtle Trading Rules                               |
//|                           https://www.mql5.com/en/articles/23448 |
//|6.Jesse Livermore's Pivotal Point System                          |
//|                           https://www.mql5.com/en/articles/24075 |
//|7.The Nicolas Darvas Box System                                   |
//|                           https://www.mql5.com/en/articles/24111 |
//+------------------------------------------------------------------+
#property copyright "Copyright 2026, Tola Moses Hector"
#property link      "https://t.me/tolahector"
#property version   "1.00"
#property description "Original Turtle Trading Rules — System 1 and System 2"
#property description "N-based position sizing, four-unit pyramid, 2N stop"
#property description "Daily timeframe recommended"

#include <Trade\Trade.mqh>

//+------------------------------------------------------------------+
//| Which system to run                                              |
//+------------------------------------------------------------------+
enum ENUM_TURTLE_SYSTEM
  {
   SYSTEM_1,    // System 1 — 20-day breakout with skip rule
   SYSTEM_2,    // System 2 — 55-day breakout, no skip rule
   BOTH         // Run both simultaneously
  };

//+------------------------------------------------------------------+
//| Input Parameters                                                 |
//+------------------------------------------------------------------+
input group "=== System Selection ==="
input ENUM_TURTLE_SYSTEM InpSystem     = BOTH;       // Turtle system to use

input group "=== System 1 ==="
input int    InpS1Entry               = 20;          // System 1 entry breakout period
input int    InpS1Exit                = 10;          // System 1 exit breakout period

input group "=== System 2 ==="
input int    InpS2Entry               = 55;          // System 2 entry breakout period
input int    InpS2Exit                = 20;          // System 2 exit breakout period

input group "=== Risk and Sizing ==="
input double InpRiskPerUnit           = 1.0;         // Risk per unit as percent of equity
input int    InpMaxUnits              = 4;           // Maximum units per direction
input int    InpATRPeriod             = 20;          // N calculation period

input group "=== General ==="
input int    InpMagicNumber           = 333001;      // Magic number
input int    InpSlippage              = 10;          // Slippage in points
input bool   InpShowLabels            = true;        // Draw labels on chart

//+------------------------------------------------------------------+
//| State for one direction (long or short)                          |
//+------------------------------------------------------------------+
struct STurtleState
  {
   int               units_open;         // Number of units currently open (0-4)
   double            entry_prices[4];    // Entry price of each unit
   double            lots[4];            // Lot size of each unit
   ulong             tickets[4];         // Position ticket of each unit
   double            unified_stop;       // Current stop for all units
   double            last_n;             // N value at first entry
   bool              last_s1_winner;     // Was the last System 1 trade a winner?
   bool              active;             // Is this direction currently active?
  };

//+------------------------------------------------------------------+
//| Global Variables                                                 |
//+------------------------------------------------------------------+
STurtleState  g_long;                    // Long position state
STurtleState  g_short;                   // Short position state
CTrade        g_trade;                   // Trade execution
double        g_n         = 0;           // Current N value
datetime      g_last_bar  = 0;           // Last processed bar time

//+------------------------------------------------------------------+
//| Returns pip size for the current symbol                          |
//+------------------------------------------------------------------+
double PipSize()
  {
   int digits = (int)SymbolInfoInteger(_Symbol, SYMBOL_DIGITS);
   return (digits == 3 || digits == 5) ? _Point * 10.0 : _Point;
  }

//+------------------------------------------------------------------+
//| Computes N using Wilder smoothing — correct Turtle method        |
//+------------------------------------------------------------------+
double ComputeN()
  {
   int bars_needed = InpATRPeriod * 3 + 2;
   double high[], low[], close[];
   ArraySetAsSeries(high,  true);
   ArraySetAsSeries(low,   true);
   ArraySetAsSeries(close, true);
   if(CopyHigh(_Symbol,  PERIOD_CURRENT, 1, bars_needed, high)  < bars_needed)
      return g_n;
   if(CopyLow(_Symbol,   PERIOD_CURRENT, 1, bars_needed, low)   < bars_needed)
      return g_n;
   if(CopyClose(_Symbol, PERIOD_CURRENT, 1, bars_needed, close) < bars_needed)
      return g_n;
//--- Compute true ranges oldest to newest (index 0 = most recent bar 1)
   double tr[];
   ArrayResize(tr, bars_needed);
   for(int i = bars_needed - 2; i >= 0; i--)
     {
      double hl  = high[i] - low[i];
      double hpc = MathAbs(high[i]  - close[i + 1]);
      double lpc = MathAbs(low[i]   - close[i + 1]);
      tr[i] = MathMax(hl, MathMax(hpc, lpc));
     }
//--- Seed: simple average of oldest InpATRPeriod true ranges
   int    start = bars_needed - 2; // oldest valid bar (needs prev close)
   double seed  = 0;
   for(int i = 0; i < InpATRPeriod; i++)
      seed += tr[start - i];
   seed /= InpATRPeriod;
//--- Wilder smoothing forward to bar 1
   double n = seed;
   for(int i = start - InpATRPeriod; i >= 0; i--)
      n = (n * (InpATRPeriod - 1) + tr[i]) / InpATRPeriod;
   return n;
  }

//+------------------------------------------------------------------+
//| Computes one unit lot size — risk 1% on a 2N stop                |
//+------------------------------------------------------------------+
double CalcUnitLots(double n_value)
  {
   if(n_value <= 0)
      return 0;
   double equity    = AccountInfoDouble(ACCOUNT_EQUITY);
   double risk_amt  = equity * InpRiskPerUnit / 100.0;
   double tick_val  = SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_VALUE);
   double tick_size = SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_SIZE);
   if(tick_size <= 0 || tick_val <= 0)
      return 0;
   double n_dollars = (n_value / tick_size) * tick_val; // monetary value of 1N per lot
   if(n_dollars <= 0)
      return 0;
   double lots = risk_amt / (n_dollars * 2.0); // 2N stop distance
   double step    = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_STEP);
   double min_lot = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MIN);
   double max_lot = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MAX);
   lots = MathFloor(lots / step) * step;
   return MathMax(min_lot, MathMin(max_lot, lots));
  }

//+------------------------------------------------------------------+
//| Highest high of bars [from_bar .. from_bar+period-1]             |
//| from_bar=1 means start at last completed bar                     |
//| from_bar=2 means EXCLUDE last bar — used for breakout comparison |
//+------------------------------------------------------------------+
double GetHighest(int from_bar, int period)
  {
   double high[];
   ArraySetAsSeries(high, true);
   if(CopyHigh(_Symbol, PERIOD_CURRENT, from_bar, period, high) < period)
      return 0;
   double result = high[0];
   for(int i = 1; i < period; i++)
      if(high[i] > result)
         result = high[i];
   return result;
  }

//+------------------------------------------------------------------+
//| Lowest low of bars [from_bar .. from_bar+period-1]               |
//+------------------------------------------------------------------+
double GetLowest(int from_bar, int period)
  {
   double low[];
   ArraySetAsSeries(low, true);
   if(CopyLow(_Symbol, PERIOD_CURRENT, from_bar, period, low) < period)
      return DBL_MAX;
   double result = low[0];
   for(int i = 1; i < period; i++)
      if(low[i] < result)
         result = low[i];
   return result;
  }

//+------------------------------------------------------------------+
//| Places a text label on the chart                                 |
//+------------------------------------------------------------------+
void DrawLabel(string name, datetime time, double price, string text, color clr)
  {
   if(!InpShowLabels)
      return;
   string obj = "TRT_" + name;
   ObjectDelete(0, obj);
   ObjectCreate(0, obj, OBJ_TEXT, 0, time, price);
   ObjectSetString(0,  obj, OBJPROP_TEXT, text);
   ObjectSetInteger(0, obj, OBJPROP_COLOR, clr);
   ObjectSetInteger(0, obj, OBJPROP_FONTSIZE, 9);
   ChartRedraw(0);
  }

//+------------------------------------------------------------------+
//| Removes all chart objects created by this EA                     |
//+------------------------------------------------------------------+
void ClearLabels()
  {
   int total = ObjectsTotal(0);
   for(int i = total - 1; i >= 0; i--)
     {
      string name = ObjectName(0, i);
      if(StringFind(name, "TRT_") == 0)
         ObjectDelete(0, name);
     }
   ChartRedraw(0);
  }

//+------------------------------------------------------------------+
//| Resets one state structure to empty                              |
//+------------------------------------------------------------------+
void ResetState(STurtleState &state)
  {
   state.units_open   = 0;
   state.unified_stop = 0;
   state.last_n       = 0;
   state.active       = false;
   for(int i = 0; i < 4; i++)
     {
      state.entry_prices[i] = 0;
      state.lots[i]         = 0;
      state.tickets[i]      = 0;
     }
  }

//+------------------------------------------------------------------+
//| Opens one unit and updates the state structure                   |
//+------------------------------------------------------------------+
bool OpenUnit(STurtleState &state, bool is_long, double n_value, string label)
  {
   if(state.units_open >= InpMaxUnits)
      return false;
   double lots = CalcUnitLots(n_value);
   if(lots <= 0)
      return false;
   double ask = SymbolInfoDouble(_Symbol, SYMBOL_ASK);
   double bid = SymbolInfoDouble(_Symbol, SYMBOL_BID);
   double entry_price = is_long ? ask : bid;
   double stop_dist   = n_value * 2.0;
   double new_stop    = is_long
                        ? NormalizeDouble(entry_price - stop_dist, _Digits)
                        : NormalizeDouble(entry_price + stop_dist, _Digits);
   long   stop_lv  = SymbolInfoInteger(_Symbol, SYMBOL_TRADE_STOPS_LEVEL);
   double min_dist = stop_lv * _Point;
   if(is_long  && entry_price - new_stop < min_dist)
      new_stop = NormalizeDouble(entry_price - min_dist - _Point, _Digits);
   if(!is_long && new_stop - entry_price < min_dist)
      new_stop = NormalizeDouble(entry_price + min_dist + _Point, _Digits);
   bool ok = is_long
             ? g_trade.Buy(lots,  _Symbol, ask, new_stop, 0, "Turtle " + label)
             : g_trade.Sell(lots, _Symbol, bid, new_stop, 0, "Turtle " + label);
   if(!ok)
     {
      Print("TurtleEA: Order failed | Retcode:", g_trade.ResultRetcode(),
            " | Error:", GetLastError());
      return false;
     }
//--- Capture position ticket via deal record (reliable on hedging)
   ulong ticket = 0;
   ulong deal   = g_trade.ResultDeal();
   if(deal > 0 && HistoryDealSelect(deal))
      ticket = (ulong)HistoryDealGetInteger(deal, DEAL_POSITION_ID);
   if(ticket == 0)
      ticket = g_trade.ResultOrder();
   int idx = state.units_open;
   state.entry_prices[idx] = entry_price;
   state.lots[idx]         = lots;
   state.tickets[idx]      = ticket;
   state.unified_stop      = new_stop;
   if(state.units_open == 0)
      state.last_n = n_value; // store N at first entry only
   state.units_open++;
   state.active = true;
   Print(StringFormat("TurtleEA: Unit %d opened | %s | Entry:%.5f | Stop:%.5f | Lots:%.2f | N:%.5f",
                      state.units_open, label, entry_price, new_stop, lots, n_value));
   datetime t = iTime(_Symbol, PERIOD_CURRENT, 1);
   DrawLabel(label + IntegerToString(state.units_open), t,
             is_long ? iLow(_Symbol, PERIOD_CURRENT, 1)  - PipSize() * 5
             : iHigh(_Symbol, PERIOD_CURRENT, 1) + PipSize() * 5,
             "U" + IntegerToString(state.units_open),
             is_long ? clrDodgerBlue : clrOrangeRed);
   return true;
  }

//+------------------------------------------------------------------+
//| Moves the stop for all open units — only advances, never retreats|
//+------------------------------------------------------------------+
void MoveUnifiedStop(STurtleState &state, bool is_long, double new_stop)
  {
   if(is_long  && new_stop <= state.unified_stop)
      return;
   if(!is_long && state.unified_stop > 0 && new_stop >= state.unified_stop)
      return;
   bool all_ok = true;
   for(int i = 0; i < state.units_open; i++)
     {
      if(!PositionSelectByTicket(state.tickets[i]))
         continue;
      double cur_sl = PositionGetDouble(POSITION_SL);
      if(is_long  && new_stop <= cur_sl)
         continue;
      if(!is_long && cur_sl > 0 && new_stop >= cur_sl)
         continue;
      if(!g_trade.PositionModify(state.tickets[i], new_stop, 0))
        {
         Print("TurtleEA: Stop modify failed | Ticket:", state.tickets[i],
               " | Retcode:", g_trade.ResultRetcode());
         all_ok = false;
        }
     }
   if(all_ok)
     {
      state.unified_stop = new_stop;
      Print("TurtleEA: Unified stop moved to ", DoubleToString(new_stop, _Digits));
     }
  }

//+------------------------------------------------------------------+
//| Closes all open units and records whether the trade was a winner |
//+------------------------------------------------------------------+
void CloseAllUnits(STurtleState &state, bool is_long, bool &was_winner)
  {
   double total_profit = 0;
   for(int i = state.units_open - 1; i >= 0; i--)
     {
      if(!PositionSelectByTicket(state.tickets[i]))
         continue;
      total_profit += PositionGetDouble(POSITION_PROFIT);
      if(!g_trade.PositionClose(state.tickets[i]))
         Print("TurtleEA: Close failed | Ticket:", state.tickets[i]);
     }
   was_winner = (total_profit > 0);
   Print(StringFormat("TurtleEA: %s closed | Units:%d | P&L:%.2f | Winner:%s",
                      is_long ? "LONG" : "SHORT",
                      state.units_open, total_profit,
                      was_winner ? "YES" : "NO"));
   ResetState(state);
   ClearLabels();
  }

//+------------------------------------------------------------------+
//| Processes System 1 for the current bar                           |
//+------------------------------------------------------------------+
void ProcessSystem1()
  {
//--- Breakout levels: exclude bar 1 from the lookback (from_bar=2)
//--- so we compare bar 1's price against the prior N bars, not itself
   double high_20 = GetHighest(2, InpS1Entry);             // highest of bars 2..21
   double low_20  = GetLowest(2,  InpS1Entry);             // lowest  of bars 2..21
   double high_10 = GetHighest(2, InpS1Exit);              // highest of bars 2..11
   double low_10  = GetLowest(2,  InpS1Exit);              // lowest  of bars 2..11
   double bar1_high  = iHigh(_Symbol,  PERIOD_CURRENT, 1); // last bar high
   double bar1_low   = iLow(_Symbol,   PERIOD_CURRENT, 1); // last bar low
   double bar1_close = iClose(_Symbol, PERIOD_CURRENT, 1); // last bar close
//--- Exit long: close crosses below 10-day low
   if(g_long.active && bar1_close < low_10)
     {
      bool winner = false;
      CloseAllUnits(g_long, true, winner);
      g_long.last_s1_winner = winner;
      return;
     }
//--- Exit short: close crosses above 10-day high
   if(g_short.active && bar1_close > high_10)
     {
      bool winner = false;
      CloseAllUnits(g_short, false, winner);
      g_short.last_s1_winner = winner;
      return;
     }
//--- Pyramid long: add unit every N/2 in favor
   if(g_long.active && g_long.units_open < InpMaxUnits)
     {
      double last_entry = g_long.entry_prices[g_long.units_open - 1];
      if(bar1_close >= last_entry + g_n * 0.5)
        {
         if(OpenUnit(g_long, true, g_n, "S1L"))
           {
            double new_stop = NormalizeDouble(
                                 g_long.entry_prices[g_long.units_open - 1] - g_n * 2.0, _Digits);
            MoveUnifiedStop(g_long, true, new_stop);
           }
        }
      return;
     }
//--- Pyramid short: add unit every N/2 in favor
   if(g_short.active && g_short.units_open < InpMaxUnits)
     {
      double last_entry = g_short.entry_prices[g_short.units_open - 1];
      if(bar1_close <= last_entry - g_n * 0.5)
        {
         if(OpenUnit(g_short, false, g_n, "S1S"))
           {
            double new_stop = NormalizeDouble(
                                 g_short.entry_prices[g_short.units_open - 1] + g_n * 2.0, _Digits);
            MoveUnifiedStop(g_short, false, new_stop);
           }
        }
      return;
     }
//--- New entry: only when no position open in either direction
   if(!g_long.active && !g_short.active)
     {
      //--- Long: bar1 high exceeded prior 20-day high and skip rule permits
      if(bar1_high > high_20 && !g_long.last_s1_winner)
        {
         if(OpenUnit(g_long, true, g_n, "S1L"))
           {
            double new_stop = NormalizeDouble(
                                 g_long.entry_prices[0] - g_n * 2.0, _Digits);
            g_long.unified_stop = new_stop;
           }
        }
      //--- Short: bar1 low exceeded prior 20-day low and skip rule permits
      else
         if(bar1_low < low_20 && !g_short.last_s1_winner)
           {
            if(OpenUnit(g_short, false, g_n, "S1S"))
              {
               double new_stop = NormalizeDouble(
                                    g_short.entry_prices[0] + g_n * 2.0, _Digits);
               g_short.unified_stop = new_stop;
              }
           }
     }
  }

//+------------------------------------------------------------------+
//| Processes System 2 for the current bar                           |
//+------------------------------------------------------------------+
void ProcessSystem2()
  {
   double high_55 = GetHighest(2, InpS2Entry); // prior 55-day high
   double low_55  = GetLowest(2,  InpS2Entry); // prior 55-day low
   double high_20 = GetHighest(2, InpS2Exit);  // prior 20-day high for exit
   double low_20  = GetLowest(2,  InpS2Exit);  // prior 20-day low for exit
   double bar1_high  = iHigh(_Symbol,  PERIOD_CURRENT, 1);
   double bar1_low   = iLow(_Symbol,   PERIOD_CURRENT, 1);
   double bar1_close = iClose(_Symbol, PERIOD_CURRENT, 1);
//--- Exit long
   if(g_long.active && bar1_close < low_20)
     {
      bool winner = false;
      CloseAllUnits(g_long, true, winner);
      return;
     }
//--- Exit short
   if(g_short.active && bar1_close > high_20)
     {
      bool winner = false;
      CloseAllUnits(g_short, false, winner);
      return;
     }
//--- Pyramid long
   if(g_long.active && g_long.units_open < InpMaxUnits)
     {
      double last_entry = g_long.entry_prices[g_long.units_open - 1];
      if(bar1_close >= last_entry + g_n * 0.5)
        {
         if(OpenUnit(g_long, true, g_n, "S2L"))
           {
            double new_stop = NormalizeDouble(
                                 g_long.entry_prices[g_long.units_open - 1] - g_n * 2.0, _Digits);
            MoveUnifiedStop(g_long, true, new_stop);
           }
        }
      return;
     }
//--- Pyramid short
   if(g_short.active && g_short.units_open < InpMaxUnits)
     {
      double last_entry = g_short.entry_prices[g_short.units_open - 1];
      if(bar1_close <= last_entry - g_n * 0.5)
        {
         if(OpenUnit(g_short, false, g_n, "S2S"))
           {
            double new_stop = NormalizeDouble(
                                 g_short.entry_prices[g_short.units_open - 1] + g_n * 2.0, _Digits);
            MoveUnifiedStop(g_short, false, new_stop);
           }
        }
      return;
     }
//--- New entry — no skip rule for System 2
   if(!g_long.active && !g_short.active)
     {
      if(bar1_high > high_55)
        {
         if(OpenUnit(g_long, true, g_n, "S2L"))
           {
            double new_stop = NormalizeDouble(
                                 g_long.entry_prices[0] - g_n * 2.0, _Digits);
            g_long.unified_stop = new_stop;
           }
        }
      else
         if(bar1_low < low_55)
           {
            if(OpenUnit(g_short, false, g_n, "S2S"))
              {
               double new_stop = NormalizeDouble(
                                    g_short.entry_prices[0] + g_n * 2.0, _Digits);
               g_short.unified_stop = new_stop;
              }
           }
     }
  }

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
   g_trade.SetExpertMagicNumber(InpMagicNumber);
   g_trade.SetDeviationInPoints(InpSlippage);
   ResetState(g_long);
   ResetState(g_short);
   g_long.last_s1_winner  = false;
   g_short.last_s1_winner = false;
   g_last_bar = 0;
   g_n        = 0;
   Print("TurtleEA initialized | Symbol:", _Symbol,
         " | TF:", EnumToString(Period()),
         " | System:", EnumToString(InpSystem),
         " | Magic:", InpMagicNumber);
   return INIT_SUCCEEDED;
  }

//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   ClearLabels();
  }

//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
   datetime current_bar = iTime(_Symbol, PERIOD_CURRENT, 0);
   if(current_bar == g_last_bar)
      return; // one execution per bar
   g_last_bar = current_bar;
   g_n = ComputeN(); // update N each bar
   if(g_n <= 0)
     {
      Print("TurtleEA: N not ready yet — waiting for more bars.");
      return;
     }
   if(InpSystem == SYSTEM_1 || InpSystem == BOTH)
      ProcessSystem1();
   if(InpSystem == SYSTEM_2 || InpSystem == BOTH)
      ProcessSystem2();
  }
//+------------------------------------------------------------------+
