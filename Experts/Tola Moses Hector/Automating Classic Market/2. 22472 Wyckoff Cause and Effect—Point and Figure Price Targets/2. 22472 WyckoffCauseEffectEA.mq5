//+------------------------------------------------------------------+
//|                                        WyckoffCauseEffectEA.mq5  |
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
#property description "Automating Classic Market Methods in MQL5 Part 2"
#property description "Wyckoff Cause and Effect — P&F Price Targets"
#property description "Extends Part 1 with structural take-profit calculation"
#property description "H4 timeframe recommended"

#include <Trade\Trade.mqh>

//+------------------------------------------------------------------+
//| State Machine                                                    |
//+------------------------------------------------------------------+
enum ENUM_WYCKOFF_STATE
  {
   STATE_IDLE,
   STATE_RANGE_FORMING,
   STATE_SPRING_DETECTED,
   STATE_SOS_CONFIRMED,
   STATE_UPTHRUST_DETECTED,
   STATE_SOW_CONFIRMED,
   STATE_IN_TRADE
  };

//+------------------------------------------------------------------+
//| Input Parameters                                                 |
//+------------------------------------------------------------------+
input group "=== Range Detection ==="
input int    InpTrendBars        = 15;    //--- Bars of prior trend required
input int    InpMinRangeBars     = 10;    //--- Minimum bars to form range
input int    InpMaxRangeBars     = 60;    //--- Maximum bars to scan for range
input double InpMinRangePips     = 20.0;  //--- Minimum range height in pips
input double InpMaxRangePips     = 400.0; //--- Maximum range height in pips
input double InpSpringTolerance  = 10.0;  //--- Pips below support for Spring
input int    InpRangeWatchBars   = 30;    //--- Max bars to watch range before reset

input group "=== Volume Settings ==="
input double InpHighVolMult      = 1.2;   //--- High-volume multiplier for SOS and SOW
input double InpLowVolMult       = 1.2;   //--- Low-volume multiplier for Spring and Upthrust

input group "=== P&F Target Settings ==="
input int    InpPFReversalBoxes  = 1;     //--- P&F reversal factor (1 = most conservative)
input double InpMinTargetPips    = 30.0;  //--- Minimum valid target distance in pips
input double InpMaxTargetPips    = 500.0; //--- Maximum valid target distance in pips

input group "=== Entry and Risk ==="
input double InpRiskPercent      = 1.0;   //--- Risk per trade as percent of balance
input int    InpATRPeriod        = 14;    //--- ATR period for stop and box size
input double InpATRMult          = 1.5;   //--- ATR multiplier for stop distance
input int    InpLPSBars          = 8;     //--- Bars to wait for LPS or LPSY pullback

input group "=== General ==="
input int    InpMagicNumber      = 888001; //--- Magic number
input int    InpSlippage         = 10;     //--- Slippage in points
input bool   InpShowLabels       = true;   //--- Draw event labels on chart

//+------------------------------------------------------------------+
//| P&F Column Structure                                             |
//+------------------------------------------------------------------+
struct SPFColumn
  {
   bool              is_up;        //--- true = X column (rising), false = O column (falling)
   double            extreme;      //--- Furthest price reached in this column
   double            base;         //--- Price where this column began
  };

//+------------------------------------------------------------------+
//| Wyckoff Range Structure                                          |
//+------------------------------------------------------------------+
struct SWyckoffRange
  {
   double            support;        //--- Range support level
   double            resistance;     //--- Range resistance level
   int               start_bar;      //--- Bars back where range started
   double            avg_volume;     //--- Average tick volume within range
   bool              bullish_bias;   //--- true = accumulation, false = distribution
   double            spring_low;     //--- Low of the Spring bar
   double            sos_high;       //--- High of the SOS bar
   double            upthrust_high;  //--- High of the Upthrust bar
   double            sow_low;        //--- Low of the SOW bar
   double            count_line;     //--- P&F count line price (LPS or LPSY level)
   double            range_atr;      //--- ATR averaged over range bars
  };

//+------------------------------------------------------------------+
//| Global Variables                                                 |
//+------------------------------------------------------------------+
ENUM_WYCKOFF_STATE g_state       = STATE_IDLE;        //--- Current EA state
SWyckoffRange      g_range;                           //--- Current range data
CTrade             g_trade;                           //--- Trade execution object
int                g_atr_handle  = INVALID_HANDLE;    //--- ATR indicator handle
datetime           g_last_bar    = 0;                 //--- Last processed bar time
int                g_lps_count   = 0;                 //--- Bars waited after SOS
int                g_lpsy_count  = 0;                 //--- Bars waited after SOW
int                g_range_watch = 0;                 //--- Bars watched in range state

//+------------------------------------------------------------------+
//| Returns pip size for the current symbol                          |
//+------------------------------------------------------------------+
double PipSize()
  {
   int digits = (int)SymbolInfoInteger(_Symbol, SYMBOL_DIGITS); //--- Get symbol digits
   return (digits == 3 || digits == 5) ? _Point * 10.0 : _Point; //--- Return pip size
  }

//+------------------------------------------------------------------+
//| Calculates lot size from risk percent and stop distance in pips  |
//+------------------------------------------------------------------+
double CalcLots(double sl_pips)
  {
   double balance    = AccountInfoDouble(ACCOUNT_BALANCE);                  //--- Get balance
   double risk_money = balance * InpRiskPercent / 100.0;                    //--- Monetary risk
   double tick_val   = SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_VALUE);  //--- Tick value
   double tick_size  = SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_SIZE);   //--- Tick size
   double pip_size   = PipSize();                                           //--- Get pip size
   if(tick_size <= 0 || tick_val <= 0 || sl_pips <= 0)
      return 0;                                                             //--- Validate inputs
   double pip_value  = (pip_size / tick_size) * tick_val;                   //--- Pip monetary value
   double lots       = risk_money / (sl_pips * pip_value);                  //--- Raw lot size
   double step       = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_STEP);       //--- Volume step
   double min_lot    = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MIN);        //--- Minimum lot
   double max_lot    = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MAX);        //--- Maximum lot
   lots = MathFloor(lots / step) * step;                                    //--- Normalize to step
   return MathMax(min_lot, MathMin(max_lot, lots));                         //--- Clamp to limits
  }

//+------------------------------------------------------------------+
//| Returns true if EA has an open position on this symbol           |
//+------------------------------------------------------------------+
bool PositionOpen()
  {
   for(int i = PositionsTotal() - 1; i >= 0; i--)                          //--- Iterate positions
     {
      ulong ticket = PositionGetTicket(i);                                  //--- Get ticket
      if(!PositionSelectByTicket(ticket))
         continue;                                                          //--- Select position
      if(PositionGetString(POSITION_SYMBOL)  != _Symbol)
         continue;                                                          //--- Check symbol
      if(PositionGetInteger(POSITION_MAGIC)  != InpMagicNumber)
         continue;                                                          //--- Check magic
      return true;                                                          //--- Position found
     }
   return false;                                                            //--- No position
  }

//+------------------------------------------------------------------+
//| Draws a horizontal line at the specified price level             |
//+------------------------------------------------------------------+
void DrawHLine(string name, double price, color clr, ENUM_LINE_STYLE style)
  {
   if(!InpShowLabels)
      return;                                                               //--- Check flag
   string obj = "WYK2_" + name;                                             //--- Build object name
   ObjectDelete(0, obj);                                                    //--- Remove existing
   ObjectCreate(0, obj, OBJ_HLINE, 0, 0, price);                            //--- Create hline
   ObjectSetInteger(0, obj, OBJPROP_COLOR, clr);                            //--- Set color
   ObjectSetInteger(0, obj, OBJPROP_STYLE, style);                          //--- Set line style
   ObjectSetInteger(0, obj, OBJPROP_WIDTH, 1);                              //--- Set width
   ChartRedraw(0);                                                          //--- Redraw chart
  }

//+------------------------------------------------------------------+
//| Places a text label at the specified time and price              |
//+------------------------------------------------------------------+
void DrawLabel(string name, datetime time, double price, string text, color clr)
  {
   if(!InpShowLabels)
      return;                                                               //--- Check flag
   string obj = "WYK2_" + name;                                             //--- Build object name
   ObjectDelete(0, obj);                                                    //--- Remove existing
   ObjectCreate(0, obj, OBJ_TEXT, 0, time, price);                          //--- Create text object
   ObjectSetString(0, obj, OBJPROP_TEXT, text);                             //--- Set text content
   ObjectSetInteger(0, obj, OBJPROP_COLOR, clr);                            //--- Set color
   ObjectSetInteger(0, obj, OBJPROP_FONTSIZE, 9);                           //--- Set font size
   ChartRedraw(0);                                                          //--- Redraw chart
  }

//+------------------------------------------------------------------+
//| Removes all chart objects created by this EA                     |
//+------------------------------------------------------------------+
void ClearLabels()
  {
   int total = ObjectsTotal(0);                                             //--- Get object count
   for(int i = total - 1; i >= 0; i--)                                      //--- Iterate backwards
     {
      string name = ObjectName(0, i);                                       //--- Get object name
      if(StringFind(name, "WYK2_") == 0)
         ObjectDelete(0, name);                                             //--- Delete if EA's
     }
   ChartRedraw(0);                                                          //--- Redraw chart
  }

//+------------------------------------------------------------------+
//| Computes average ATR over the range period                       |
//+------------------------------------------------------------------+
double CalcRangeATR(int range_bars)
  {
   double atr_buf[];                                                        //--- ATR buffer
   ArraySetAsSeries(atr_buf, true);                                         //--- Set as series
   if(CopyBuffer(g_atr_handle, 0, 1, range_bars, atr_buf) < range_bars)
      return 0;                                                             //--- Copy ATR values
   double total = 0;                                                        //--- Accumulator
   for(int i = 0; i < range_bars; i++)
      total += atr_buf[i];                                                  //--- Sum ATR values
   return total / range_bars;                                               //--- Return average
  }

//+------------------------------------------------------------------+
//| Builds P&F chart from bar data — returns column count            |
//+------------------------------------------------------------------+
int BuildPFChart(double range_support, double range_resistance,
                 int range_bars, double box_size,
                 int reversal_boxes, SPFColumn &columns[])
  {
   ArrayResize(columns, 0);                                                 //--- Clear array
   double high_buf[], low_buf[];                                            //--- Price buffers
   ArraySetAsSeries(high_buf, true);                                        //--- Set as series
   ArraySetAsSeries(low_buf,  true);                                        //--- Set as series
   if(CopyHigh(_Symbol, PERIOD_CURRENT, 1, range_bars, high_buf) < range_bars)
      return 0;                                                             //--- Copy highs
   if(CopyLow(_Symbol,  PERIOD_CURRENT, 1, range_bars, low_buf)  < range_bars)
      return 0;                                                             //--- Copy lows
   double reversal_dist = box_size * reversal_boxes;                        //--- Reversal distance
   bool   col_is_up     = (high_buf[range_bars - 1] > range_support + box_size); //--- First direction
   double col_extreme   = col_is_up ? high_buf[range_bars - 1] : low_buf[range_bars - 1]; //--- First extreme
   SPFColumn first_col;                                                     //--- First column
   first_col.is_up   = col_is_up;                                           //--- Set direction
   first_col.extreme = col_extreme;                                         //--- Set extreme
   first_col.base    = col_extreme;                                         //--- Set base
   ArrayResize(columns, 1);                                                 //--- Add first column
   columns[0] = first_col;                                                  //--- Store column
   int col_count = 1;                                                       //--- Column counter
   for(int i = range_bars - 2; i >= 0; i--)                                 //--- Scan bars oldest to newest
     {
      double bar_high = high_buf[i];                                        //--- Bar high
      double bar_low  = low_buf[i];                                         //--- Bar low
      if(col_is_up)                                                         //--- In up column
        {
         if(bar_high > col_extreme + box_size)                              //--- Extends column
           {
            col_extreme = MathFloor((bar_high - range_support) / box_size) * box_size + range_support; //--- Snap to grid
            columns[col_count - 1].extreme = col_extreme;                   //--- Update extreme
           }
         else
            if(bar_low <= col_extreme - reversal_dist)                      //--- Reversal
              {
               col_is_up   = false;                                         //--- Switch direction
               double new_base = col_extreme;                               //--- New base
               col_extreme = MathCeil((bar_low - range_support) / box_size) * box_size + range_support; //--- Snap low
               SPFColumn nc;                                                 //--- New column
               nc.is_up   = false;                                           //--- Down column
               nc.extreme = col_extreme;                                     //--- Set extreme
               nc.base    = new_base;                                        //--- Set base
               ArrayResize(columns, col_count + 1);                          //--- Expand array
               columns[col_count] = nc;                                      //--- Store column
               col_count++;                                                  //--- Increment count
              }
        }
      else                                                                  //--- In down column
        {
         if(bar_low < col_extreme - box_size)                               //--- Extends column
           {
            col_extreme = MathCeil((bar_low - range_support) / box_size) * box_size + range_support; //--- Snap to grid
            columns[col_count - 1].extreme = col_extreme;                   //--- Update extreme
           }
         else
            if(bar_high >= col_extreme + reversal_dist)                     //--- Reversal
              {
               col_is_up   = true;                                          //--- Switch direction
               double new_base = col_extreme;                               //--- New base
               col_extreme = MathFloor((bar_high - range_support) / box_size) * box_size + range_support; //--- Snap high
               SPFColumn nc;                                                 //--- New column
               nc.is_up   = true;                                            //--- Up column
               nc.extreme = col_extreme;                                     //--- Set extreme
               nc.base    = new_base;                                        //--- Set base
               ArrayResize(columns, col_count + 1);                          //--- Expand array
               columns[col_count] = nc;                                      //--- Store column
               col_count++;                                                  //--- Increment count
              }
        }
     }
   return col_count;                                                         //--- Return count
  }

//+------------------------------------------------------------------+
//| Counts columns passing through the count line level              |
//+------------------------------------------------------------------+
int CountColumnsAtLevel(const SPFColumn &columns[], int col_count, double count_line)
  {
   int count = 0;                                                           //--- Initialize counter
   for(int i = 0; i < col_count; i++)                                       //--- Iterate columns
     {
      double col_top = MathMax(columns[i].base, columns[i].extreme);        //--- Column top
      double col_bot = MathMin(columns[i].base, columns[i].extreme);        //--- Column bottom
      if(count_line >= col_bot && count_line <= col_top)                    //--- Passes through level
         count++;                                                           //--- Increment counter
     }
   return count;                                                            //--- Return count
  }

//+------------------------------------------------------------------+
//| Calculates P&F price target from the confirmed range             |
//+------------------------------------------------------------------+
double CalcPFTarget(bool is_long)
  {
   double box_size = g_range.range_atr * 0.25;                              //--- Box size = 0.25 ATR
   double pip      = PipSize();                                             //--- Get pip size
   if(box_size < pip * 3)
      box_size = pip * 3;                                                   //--- Minimum box size
   if(box_size <= 0)
      return 0;                                                             //--- Invalid box size
   SPFColumn columns[];                                                     //--- Column array
   int col_count = BuildPFChart(g_range.support, g_range.resistance,        //--- Build P&F chart
                                g_range.start_bar, box_size,
                                InpPFReversalBoxes, columns);
   if(col_count < 2)
     {
      Print("WyckoffP&F: Insufficient columns (", col_count, ") — skipping P&F target."); //--- Log
      return 0;                                                             //--- Not enough columns
     }
   int h_count = CountColumnsAtLevel(columns, col_count, g_range.count_line); //--- Count at level
   if(h_count < 2)
     {
      Print("WyckoffP&F: Horizontal count too small (", h_count, ") — skipping."); //--- Log
      return 0;                                                             //--- Count too small
     }
   double projected_move = h_count * box_size * InpPFReversalBoxes;         //--- Project move
   double target = is_long                                                  //--- Calculate target
                   ? g_range.count_line + projected_move
                   : g_range.count_line - projected_move;
   double target_pips = MathAbs(target - g_range.count_line) / pip;        //--- Target in pips
   if(target_pips < InpMinTargetPips || target_pips > InpMaxTargetPips)    //--- Validate range
     {
      Print(StringFormat("WyckoffP&F: Target %.1f pips outside valid range [%.0f, %.0f] — skipping.",
                         target_pips, InpMinTargetPips, InpMaxTargetPips)); //--- Log validation
      return 0;                                                             //--- Invalid target
     }
   Print(StringFormat("WyckoffP&F: Box:%.5f | Cols:%d | Count:%d | Move:%.5f | Target:%.5f",
                      box_size, col_count, h_count, projected_move, target)); //--- Log result
   return target;                                                           //--- Return target
  }

//+------------------------------------------------------------------+
//| Returns true if a downtrend preceded the specified bar           |
//+------------------------------------------------------------------+
bool HasPriorDowntrend(int from_bar)
  {
   double high_buf[], low_buf[];                                            //--- Price buffers
   ArraySetAsSeries(high_buf, true);                                        //--- Set as series
   ArraySetAsSeries(low_buf,  true);                                        //--- Set as series
   if(CopyHigh(_Symbol, PERIOD_CURRENT, from_bar, InpTrendBars, high_buf) < InpTrendBars)
      return false;                                                         //--- Copy highs
   if(CopyLow(_Symbol,  PERIOD_CURRENT, from_bar, InpTrendBars, low_buf)  < InpTrendBars)
      return false;                                                         //--- Copy lows
   double first_high = 0, second_low = DBL_MAX;                            //--- Init comparators
   int half = InpTrendBars / 2;                                            //--- Split midpoint
   for(int i = 0; i < half; i++)
      first_high = MathMax(first_high, high_buf[i + half]);                //--- Find early high
   for(int i = 0; i < half; i++)
      second_low = MathMin(second_low, low_buf[i]);                        //--- Find recent low
   return first_high > second_low + PipSize() * InpMinRangePips * 0.3;     //--- Confirm descent
  }

//+------------------------------------------------------------------+
//| Returns true if an uptrend preceded the specified bar            |
//+------------------------------------------------------------------+
bool HasPriorUptrend(int from_bar)
  {
   double high_buf[], low_buf[];                                            //--- Price buffers
   ArraySetAsSeries(high_buf, true);                                        //--- Set as series
   ArraySetAsSeries(low_buf,  true);                                        //--- Set as series
   if(CopyHigh(_Symbol, PERIOD_CURRENT, from_bar, InpTrendBars, high_buf) < InpTrendBars)
      return false;                                                         //--- Copy highs
   if(CopyLow(_Symbol,  PERIOD_CURRENT, from_bar, InpTrendBars, low_buf)  < InpTrendBars)
      return false;                                                         //--- Copy lows
   double first_low = DBL_MAX, second_high = 0;                            //--- Init comparators
   int half = InpTrendBars / 2;                                            //--- Split midpoint
   for(int i = 0; i < half; i++)
      first_low   = MathMin(first_low,   low_buf[i + half]);               //--- Find early low
   for(int i = 0; i < half; i++)
      second_high = MathMax(second_high, high_buf[i]);                     //--- Find recent high
   return second_high > first_low + PipSize() * InpMinRangePips * 0.3;    //--- Confirm ascent
  }

//+------------------------------------------------------------------+
//| Detects a valid Wyckoff trading range                            |
//+------------------------------------------------------------------+
bool DetectRange()
  {
   double high_buf[], low_buf[];                                            //--- Price buffers
   long   vol_buf[];                                                        //--- Volume buffer
   ArraySetAsSeries(high_buf, true);                                        //--- Set as series
   ArraySetAsSeries(low_buf,  true);                                        //--- Set as series
   ArraySetAsSeries(vol_buf,  true);                                        //--- Set as series
   int bars = InpMaxRangeBars + InpTrendBars + 5;                           //--- Total bars needed
   if(CopyHigh(_Symbol,       PERIOD_CURRENT, 1, bars, high_buf) < bars)
      return false;                                                         //--- Copy highs
   if(CopyLow(_Symbol,        PERIOD_CURRENT, 1, bars, low_buf)  < bars)
      return false;                                                         //--- Copy lows
   if(CopyTickVolume(_Symbol, PERIOD_CURRENT, 1, bars, vol_buf)  < bars)
      return false;                                                         //--- Copy volumes
   double pip   = PipSize();                                                //--- Get pip size
   double min_h = InpMinRangePips * pip;                                    //--- Min height in price
   double max_h = InpMaxRangePips * pip;                                    //--- Max height in price
   for(int range_bars = InpMinRangeBars; range_bars <= InpMaxRangeBars; range_bars++) //--- Try lengths
     {
      double rh = 0, rl = DBL_MAX;                                          //--- Init bounds
      for(int i = 0; i < range_bars; i++)                                   //--- Scan range bars
        {
         rh = MathMax(rh, high_buf[i]);                                    //--- Update high
         rl = MathMin(rl, low_buf[i]);                                     //--- Update low
        }
      double height = rh - rl;                                              //--- Compute height
      if(height < min_h)
         continue;                                                          //--- Too narrow
      if(height > max_h)
         break;                                                             //--- Too wide
      double tol  = height * 0.25;                                          //--- Tolerance band
      bool   fits = true;                                                   //--- Fit flag
      for(int i = 0; i < range_bars; i++)                                   //--- Verify bars fit
        {
         if(high_buf[i] > rh + tol || low_buf[i] < rl - tol)               //--- Outside tolerance
           {
            fits = false;                                                   //--- Mark invalid
            break;
           }
        }
      if(!fits)
         continue;                                                          //--- Skip this length
      bool down_before = HasPriorDowntrend(range_bars + 1);                //--- Check downtrend
      bool up_before   = HasPriorUptrend(range_bars + 1);                  //--- Check uptrend
      if(!down_before && !up_before)
         continue;                                                          //--- No prior trend
      double avg_vol = 0;                                                   //--- Volume sum
      for(int i = 0; i < range_bars; i++)
         avg_vol += (double)vol_buf[i];                                    //--- Accumulate
      avg_vol /= range_bars;                                               //--- Compute average
      double range_atr = CalcRangeATR(range_bars);                         //--- Compute range ATR
      g_range.support      = rl;                                            //--- Store support
      g_range.resistance   = rh;                                            //--- Store resistance
      g_range.start_bar    = range_bars;                                    //--- Store bar count
      g_range.avg_volume   = avg_vol;                                       //--- Store average vol
      //--- When both trends detected, pick the more dominant one
      if(down_before && up_before)
        {
         //--- Measure which directional move was larger immediately before range
         double high_buf[], low_buf[];
         ArraySetAsSeries(high_buf, true);
         ArraySetAsSeries(low_buf,  true);
         int trend_bars = InpTrendBars;
         CopyHigh(_Symbol, PERIOD_CURRENT, range_bars + 1, trend_bars, high_buf);
         CopyLow(_Symbol, PERIOD_CURRENT, range_bars + 1, trend_bars, low_buf);
         double trend_high = 0, trend_low = DBL_MAX;
         for(int k = 0; k < trend_bars; k++)
           {
            trend_high = MathMax(trend_high, high_buf[k]);
            trend_low  = MathMin(trend_low,  low_buf[k]);
           }
         double first_close  = iClose(_Symbol, PERIOD_CURRENT, range_bars + trend_bars);
         double last_close   = iClose(_Symbol, PERIOD_CURRENT, range_bars + 1);
         //--- If price fell into the range = downtrend before = accumulation
         //--- If price rose into the range = uptrend before = distribution
         g_range.bullish_bias = (last_close < first_close);
        }
      else
         g_range.bullish_bias = down_before;                                //---Set Bias
      g_range.spring_low   = 0;                                             //--- Clear spring low
      g_range.sos_high     = 0;                                             //--- Clear SOS high
      g_range.upthrust_high= 0;                                             //--- Clear upthrust
      g_range.sow_low      = 0;                                             //--- Clear SOW low
      g_range.count_line   = 0;                                             //--- Clear count line
      g_range.range_atr    = range_atr;                                     //--- Store range ATR
      DrawHLine("SUPPORT",    g_range.support,    clrGreen, STYLE_DASH);    //--- Draw support
      DrawHLine("RESISTANCE", g_range.resistance, clrRed,   STYLE_DASH);    //--- Draw resistance
      Print(StringFormat("WyckoffEA: Range | Bias:%s | S:%.5f | R:%.5f | Bars:%d | ATR:%.5f",
                         g_range.bullish_bias ? "ACCUMULATION" : "DISTRIBUTION",
                         g_range.support, g_range.resistance, range_bars, range_atr)); //--- Log
      return true;                                                          //--- Range valid
     }
   return false;                                                            //--- No range found
  }

//+------------------------------------------------------------------+
//| Checks for a valid Spring on the last closed bar                 |
//+------------------------------------------------------------------+
bool CheckSpring()
  {
   double low1   = iLow(_Symbol, PERIOD_CURRENT, 1);                        //--- Last bar low
   double close1 = iClose(_Symbol, PERIOD_CURRENT, 1);                      //--- Last bar close
   double pip    = PipSize();                                               //--- Get pip size
   double thresh = g_range.support - InpSpringTolerance * pip;              //--- Spring threshold
   if(low1 < thresh && close1 > g_range.support)                            //--- Penetrate and recover
     {
      long vol1 = iTickVolume(_Symbol, PERIOD_CURRENT, 1);                 //--- Last bar volume
      if((double)vol1 < g_range.avg_volume * InpLowVolMult)                //--- Below threshold
        {
         g_range.spring_low  = low1;                                       //--- Store Spring low
         g_range.count_line  = low1 + (g_range.support - low1) * 0.5;      //--- Count line near LPS level
         datetime t1 = iTime(_Symbol, PERIOD_CURRENT, 1);                  //--- Get bar time
         DrawLabel("SPRING", t1, low1 - pip * 5, "SPRING", clrLime);       //--- Draw label
         Print(StringFormat("WyckoffEA: SPRING | Low:%.5f | Vol:%I64d | AvgVol:%.0f",
                            low1, vol1, g_range.avg_volume));              //--- Log event
         return true;                                                      //--- Spring confirmed
        }
     }
   return false;                                                            //--- Not a Spring
  }

//+------------------------------------------------------------------+
//| Checks for a Sign of Strength on the last closed bar             |
//+------------------------------------------------------------------+
bool CheckSOS()
  {
   double close1 = iClose(_Symbol, PERIOD_CURRENT, 1);                     //--- Last bar close
   double high1  = iHigh(_Symbol, PERIOD_CURRENT, 1);                      //--- Last bar high
   if(close1 > g_range.resistance)                                         //--- Close above resistance
     {
      long vol1 = iTickVolume(_Symbol, PERIOD_CURRENT, 1);                 //--- Last bar volume
      if((double)vol1 > g_range.avg_volume * InpHighVolMult)               //--- High volume confirms
        {
         g_range.sos_high = high1;                                         //--- Store SOS high
         datetime t1 = iTime(_Symbol, PERIOD_CURRENT, 1);                  //--- Get bar time
         DrawLabel("SOS", t1, high1 + PipSize() * 5, "SOS", clrDodgerBlue); //--- Draw label
         Print(StringFormat("WyckoffEA: SOS | Close:%.5f | Vol:%I64d | AvgVol:%.0f",
                            close1, vol1, g_range.avg_volume));            //--- Log event
         return true;                                                      //--- SOS confirmed
        }
     }
   return false;                                                            //--- Not a SOS
  }

//+------------------------------------------------------------------+
//| Checks for a valid Upthrust on the last closed bar               |
//+------------------------------------------------------------------+
bool CheckUpthrust()
  {
   double high1  = iHigh(_Symbol, PERIOD_CURRENT, 1);                      //--- Last bar high
   double close1 = iClose(_Symbol, PERIOD_CURRENT, 1);                     //--- Last bar close
   double pip    = PipSize();                                               //--- Get pip size
   double thresh = g_range.resistance + InpSpringTolerance * pip;          //--- Upthrust threshold
   if(high1 > thresh && close1 < g_range.resistance)                       //--- Penetrate and reverse
     {
      long vol1 = iTickVolume(_Symbol, PERIOD_CURRENT, 1);                 //--- Last bar volume
      if((double)vol1 < g_range.avg_volume * InpLowVolMult)                //--- Below threshold
        {
         g_range.upthrust_high = high1;                                    //--- Store Upthrust high
         g_range.count_line    = high1 - (high1 - g_range.resistance) * 0.5; //--- Count line near LPSY level
         datetime t1 = iTime(_Symbol, PERIOD_CURRENT, 1);                  //--- Get bar time
         DrawLabel("UT", t1, high1 + pip * 5, "UPTHRUST", clrOrangeRed);  //--- Draw label
         Print(StringFormat("WyckoffEA: UPTHRUST | High:%.5f | Vol:%I64d | AvgVol:%.0f",
                            high1, vol1, g_range.avg_volume));             //--- Log event
         return true;                                                      //--- Upthrust confirmed
        }
     }
   return false;                                                            //--- Not an Upthrust
  }

//+------------------------------------------------------------------+
//| Checks for a Sign of Weakness on the last closed bar             |
//+------------------------------------------------------------------+
bool CheckSOW()
  {
   double close1 = iClose(_Symbol, PERIOD_CURRENT, 1);                     //--- Last bar close
   double low1   = iLow(_Symbol, PERIOD_CURRENT, 1);                       //--- Last bar low
   if(close1 < g_range.support)                                            //--- Close below support
     {
      long vol1 = iTickVolume(_Symbol, PERIOD_CURRENT, 1);                 //--- Last bar volume
      if((double)vol1 > g_range.avg_volume * InpHighVolMult)               //--- High volume confirms
        {
         g_range.sow_low = low1;                                           //--- Store SOW low
         datetime t1 = iTime(_Symbol, PERIOD_CURRENT, 1);                  //--- Get bar time
         DrawLabel("SOW", t1, low1 - PipSize() * 5, "SOW", clrCrimson);   //--- Draw label
         Print(StringFormat("WyckoffEA: SOW | Close:%.5f | Vol:%I64d | AvgVol:%.0f",
                            close1, vol1, g_range.avg_volume));            //--- Log event
         return true;                                                      //--- SOW confirmed
        }
     }
   return false;                                                            //--- Not a SOW
  }

//+------------------------------------------------------------------+
//| Waits for LPS pullback, calculates P&F target, opens long        |
//+------------------------------------------------------------------+
void CheckLPSEntry()
  {
   g_lps_count++;                                                           //--- Increment wait counter
   if(g_lps_count > InpLPSBars)                                            //--- Wait window expired
     {
      Print("WyckoffEA: LPS window expired — resetting.");                 //--- Log expiry
      g_state = STATE_IDLE;                                                //--- Reset state
      ClearLabels();                                                       //--- Clear chart
      return;
     }
   double close1 = iClose(_Symbol, PERIOD_CURRENT, 1);                     //--- Last bar close
   long   vol1   = iTickVolume(_Symbol, PERIOD_CURRENT, 1);                //--- Last bar volume
   bool pulled_back = (close1 < g_range.sos_high && close1 > g_range.support); //--- Pullback check
   bool low_vol     = ((double)vol1 < g_range.avg_volume * InpHighVolMult);    //--- Volume check
   Print(StringFormat("WyckoffEA: LPS check %d/%d | Close:%.5f | PulledBack:%s | LowVol:%s",
                      g_lps_count, InpLPSBars, close1,
                      pulled_back ? "YES" : "NO", low_vol ? "YES" : "NO")); //--- Log check
   if(pulled_back && low_vol)                                              //--- LPS conditions met
     {
      g_range.count_line = close1;                                         //--- Update count line to LPS close
      double pf_target   = CalcPFTarget(true);                             //--- Calculate P&F target
      double atr_buf[];                                                    //--- ATR buffer
      ArraySetAsSeries(atr_buf, true);                                     //--- Set as series
      if(CopyBuffer(g_atr_handle, 0, 1, 1, atr_buf) < 1)
         return;                                                           //--- Copy ATR
      double atr    = atr_buf[0];                                          //--- ATR value
      double ask    = SymbolInfoDouble(_Symbol, SYMBOL_ASK);               //--- Current ask
      double sl     = ask - atr * InpATRMult;                              //--- Stop loss price
      double sl_pip = (ask - sl) / PipSize();                              //--- Stop in pips
      double tp     = (pf_target > 0) ? pf_target : ask + sl_pip * 2.0 * PipSize(); //--- P&F target or 2R fallback
      double lots   = CalcLots(sl_pip);                                    //--- Calculate lot size
      if(lots <= 0)
         return;                                                           //--- Invalid lot size
      long   stop_lv  = SymbolInfoInteger(_Symbol, SYMBOL_TRADE_STOPS_LEVEL); //--- Broker stop level
      double min_dist = stop_lv * _Point;                                  //--- Minimum distance
      if(ask - sl < min_dist)
         sl = ask - min_dist - _Point;                                     //--- Adjust SL if needed
      if(tp < ask + min_dist)
         tp = ask + min_dist + _Point;                                     //--- Adjust TP if needed
      if(g_trade.Buy(lots, _Symbol, ask, sl, tp, "Wyckoff LPS Long"))     //--- Open long
        {
         string tp_label = (pf_target > 0) ? "P&F" : "2R";               //--- Target label
         DrawHLine("TARGET", tp, clrGold, STYLE_DOT);                     //--- Draw target line
         datetime t1 = iTime(_Symbol, PERIOD_CURRENT, 1);                 //--- Get bar time
         DrawLabel("LPS", t1, iLow(_Symbol, PERIOD_CURRENT, 1) - PipSize() * 3, "LPS", clrGold); //--- Draw LPS label
         Print(StringFormat("WyckoffEA: LONG | Lots:%.2f | SL:%.5f | TP:%.5f (%s)",
                            lots, sl, tp, tp_label));                     //--- Log trade
         g_state = STATE_IN_TRADE;                                         //--- Update state
        }
     }
  }

//+------------------------------------------------------------------+
//| Waits for LPSY rally, calculates P&F target, opens short         |
//+------------------------------------------------------------------+
void CheckLPSYEntry()
  {
   g_lpsy_count++;                                                          //--- Increment wait counter
   if(g_lpsy_count > InpLPSBars)                                           //--- Wait window expired
     {
      Print("WyckoffEA: LPSY window expired — resetting.");                //--- Log expiry
      g_state = STATE_IDLE;                                                //--- Reset state
      ClearLabels();                                                       //--- Clear chart
      return;
     }
   double close1 = iClose(_Symbol, PERIOD_CURRENT, 1);                     //--- Last bar close
   long   vol1   = iTickVolume(_Symbol, PERIOD_CURRENT, 1);                //--- Last bar volume
   bool rallied = (close1 > g_range.sow_low && close1 < g_range.resistance); //--- Rally check
   bool low_vol = ((double)vol1 < g_range.avg_volume * InpHighVolMult);       //--- Volume check
   Print(StringFormat("WyckoffEA: LPSY check %d/%d | Close:%.5f | Rallied:%s | LowVol:%s",
                      g_lpsy_count, InpLPSBars, close1,
                      rallied ? "YES" : "NO", low_vol ? "YES" : "NO"));   //--- Log check
   if(rallied && low_vol)                                                  //--- LPSY conditions met
     {
      g_range.count_line = close1;                                         //--- Update count line to LPSY close
      double pf_target   = CalcPFTarget(false);                            //--- Calculate P&F target
      double atr_buf[];                                                    //--- ATR buffer
      ArraySetAsSeries(atr_buf, true);                                     //--- Set as series
      if(CopyBuffer(g_atr_handle, 0, 1, 1, atr_buf) < 1)
         return;                                                           //--- Copy ATR
      double atr    = atr_buf[0];                                          //--- ATR value
      double bid    = SymbolInfoDouble(_Symbol, SYMBOL_BID);               //--- Current bid
      double sl     = bid + atr * InpATRMult;                              //--- Stop loss price
      double sl_pip = (sl - bid) / PipSize();                              //--- Stop in pips
      double tp     = (pf_target > 0) ? pf_target : bid - sl_pip * 2.0 * PipSize(); //--- P&F target or 2R fallback
      double lots   = CalcLots(sl_pip);                                    //--- Calculate lot size
      if(lots <= 0)
         return;                                                           //--- Invalid lot size
      long   stop_lv  = SymbolInfoInteger(_Symbol, SYMBOL_TRADE_STOPS_LEVEL); //--- Broker stop level
      double min_dist = stop_lv * _Point;                                  //--- Minimum distance
      if(sl - bid < min_dist)
         sl = bid + min_dist + _Point;                                     //--- Adjust SL if needed
      if(bid - tp < min_dist)
         tp = bid - min_dist - _Point;                                     //--- Adjust TP if needed
      if(g_trade.Sell(lots, _Symbol, bid, sl, tp, "Wyckoff LPSY Short"))  //--- Open short
        {
         string tp_label = (pf_target > 0) ? "P&F" : "2R";               //--- Target label
         DrawHLine("TARGET", tp, clrGold, STYLE_DOT);                     //--- Draw target line
         datetime t1 = iTime(_Symbol, PERIOD_CURRENT, 1);                 //--- Get bar time
         DrawLabel("LPSY", t1, iHigh(_Symbol, PERIOD_CURRENT, 1) + PipSize() * 3, "LPSY", clrGold); //--- Draw LPSY label
         Print(StringFormat("WyckoffEA: SHORT | Lots:%.2f | SL:%.5f | TP:%.5f (%s)",
                            lots, sl, tp, tp_label));                     //--- Log trade
         g_state = STATE_IN_TRADE;                                         //--- Update state
        }
     }
  }

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
   g_atr_handle = iATR(_Symbol, PERIOD_CURRENT, InpATRPeriod);             //--- Create ATR handle
   if(g_atr_handle == INVALID_HANDLE)                                      //--- Check handle
     {
      Print("WyckoffCauseEffectEA: ATR handle creation failed.");          //--- Log error
      return INIT_FAILED;                                                  //--- Return failure
     }
   g_trade.SetExpertMagicNumber(InpMagicNumber);                           //--- Set magic number
   g_trade.SetDeviationInPoints(InpSlippage);                              //--- Set slippage
   g_state       = STATE_IDLE;                                             //--- Initialize state
   g_lps_count   = 0;                                                      //--- Initialize LPS counter
   g_lpsy_count  = 0;                                                      //--- Initialize LPSY counter
   g_range_watch = 0;                                                      //--- Initialize watch counter
   g_last_bar    = 0;                                                      //--- Initialize bar time
   Print("WyckoffCauseEffectEA initialized | Symbol:", _Symbol,
         " | TF:", EnumToString(Period()),
         " | Magic:", InpMagicNumber);                                     //--- Log initialization
   return INIT_SUCCEEDED;                                                  //--- Return success
  }

//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   IndicatorRelease(g_atr_handle);                                          //--- Release ATR handle
   ClearLabels();                                                           //--- Remove chart objects
  }

//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
   datetime current_bar = iTime(_Symbol, PERIOD_CURRENT, 0);               //--- Current bar open time
   if(current_bar == g_last_bar)
      return;                                                              //--- Skip if same bar
   g_last_bar = current_bar;                                               //--- Update last bar time
   if(g_state == STATE_IN_TRADE)                                           //--- In trade state
     {
      if(!PositionOpen())                                                  //--- Position has closed
        {
         Print("WyckoffCauseEffectEA: Trade closed — returning to IDLE."); //--- Log closure
         g_state       = STATE_IDLE;                                       //--- Reset state
         g_lps_count   = 0;                                                //--- Reset LPS counter
         g_lpsy_count  = 0;                                                //--- Reset LPSY counter
         g_range_watch = 0;                                                //--- Reset watch counter
         ClearLabels();                                                    //--- Clear chart
        }
      return;                                                              //--- Exit tick
     }
   switch(g_state)                                                         //--- State machine switch
     {
      case STATE_IDLE:                                                     //--- Idle state
         if(DetectRange())                                                 //--- Range found
           {
            g_state       = STATE_RANGE_FORMING;                          //--- Advance state
            g_range_watch = 0;                                             //--- Reset watch counter
           }
         break;
      case STATE_RANGE_FORMING:                                            //--- Range locked
         g_range_watch++;                                                  //--- Increment watch counter
         if(g_range_watch > InpRangeWatchBars)                            //--- Range stale
           {
            Print("WyckoffCauseEffectEA: Range watch expired — resetting."); //--- Log expiry
            g_state = STATE_IDLE;                                          //--- Reset state
            ClearLabels();                                                 //--- Clear chart
            break;
           }
         if(g_range.bullish_bias)                                         //--- Accumulation bias
           {
            if(CheckSpring())
               g_state = STATE_SPRING_DETECTED;                           //--- Spring found
           }
         else                                                              //--- Distribution bias
           {
            if(CheckUpthrust())
               g_state = STATE_UPTHRUST_DETECTED;                         //--- Upthrust found
           }
         break;
      case STATE_SPRING_DETECTED:                                          //--- Spring detected
         if(CheckSOS())                                                    //--- SOS found
           {
            g_state     = STATE_SOS_CONFIRMED;                            //--- Advance state
            g_lps_count = 0;                                               //--- Reset LPS counter
           }
         else
            if(iClose(_Symbol, PERIOD_CURRENT, 1) < g_range.spring_low)  //--- Spring invalidated
              {
               Print("WyckoffCauseEffectEA: Spring invalidated — resetting."); //--- Log failure
               g_state = STATE_IDLE;                                       //--- Reset state
               ClearLabels();                                              //--- Clear chart
              }
         break;
      case STATE_SOS_CONFIRMED:                                            //--- SOS confirmed
         CheckLPSEntry();                                                  //--- Check LPS entry
         break;
      case STATE_UPTHRUST_DETECTED:                                        //--- Upthrust detected
         if(CheckSOW())                                                    //--- SOW found
           {
            g_state      = STATE_SOW_CONFIRMED;                           //--- Advance state
            g_lpsy_count = 0;                                              //--- Reset LPSY counter
           }
         else
            if(iClose(_Symbol, PERIOD_CURRENT, 1) > g_range.upthrust_high) //--- Upthrust invalidated
              {
               Print("WyckoffCauseEffectEA: Upthrust invalidated — resetting."); //--- Log failure
               g_state = STATE_IDLE;                                       //--- Reset state
               ClearLabels();                                              //--- Clear chart
              }
         break;
      case STATE_SOW_CONFIRMED:                                            //--- SOW confirmed
         CheckLPSYEntry();                                                 //--- Check LPSY entry
         break;
     }
  }
//+------------------------------------------------------------------+