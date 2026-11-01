//+------------------------------------------------------------------+
//|                                                    WyckoffEA.mq5 |
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
#property description "Wyckoff Accumulation and Distribution EA"
#property description "Detects Spring + SOS for long entries (LPS)"
#property description "Detects Upthrust + SOW for short entries (LPSY)"
#property description "H4 timeframe recommended"

#include <Trade\Trade.mqh>

//+------------------------------------------------------------------+
//| EA State Machine                                                 |
//+------------------------------------------------------------------+
enum ENUM_WYCKOFF_STATE
  {
   STATE_IDLE,               // No structure active
   STATE_RANGE_FORMING,      // Valid range identified — locked, watching for Spring/UT
   STATE_SPRING_DETECTED,    // Spring confirmed, watching for SOS
   STATE_SOS_CONFIRMED,      // SOS confirmed, watching for LPS entry
   STATE_UPTHRUST_DETECTED,  // Upthrust confirmed, watching for SOW
   STATE_SOW_CONFIRMED,      // SOW confirmed, watching for LPSY entry
   STATE_IN_TRADE            // Position open
  };

//+------------------------------------------------------------------+
//| Input Parameters                                                 |
//+------------------------------------------------------------------+
input group "=== Range Detection ==="
input int    InpTrendBars       = 15;    // Bars of prior trend required
input int    InpMinRangeBars    = 10;    // Minimum bars to form range
input int    InpMaxRangeBars    = 60;    // Maximum bars to scan for range
input double InpMinRangePips    = 20.0;  // Minimum range height (pips)
input double InpMaxRangePips    = 400.0; // Maximum range height (pips)
input double InpSpringTolerance = 10.0;  // Pips below support for Spring
input int    InpRangeWatchBars  = 30;    // Max bars to watch range before reset

input group "=== Volume Settings ==="
input double InpHighVolMult     = 1.2;   // High-volume multiplier (SOS/SOW)
input double InpLowVolMult      = 1.2;   // Low-volume multiplier (Spring/Upthrust)

input group "=== Entry and Risk ==="
input double InpRiskPercent     = 1.0;   // Risk per trade (% of balance)
input double InpRR              = 2.0;   // Risk-reward ratio
input int    InpATRPeriod       = 14;    // ATR period for stop distance
input double InpATRMult         = 1.5;   // ATR multiplier for stop distance
input int    InpLPSBars         = 8;     // Bars to wait for LPS/LPSY pullback

input group "=== General ==="
input int    InpMagicNumber     = 777001; // Magic number
input int    InpSlippage        = 10;     // Slippage in points
input bool   InpShowLabels      = true;   // Draw event labels on chart

//+------------------------------------------------------------------+
//| Wyckoff Range Data Structure                                     |
//+------------------------------------------------------------------+
struct SWyckoffRange
  {
   double            support;        // Range support level
   double            resistance;     // Range resistance level
   int               start_bar;      // Bars back where range started
   double            avg_volume;     // Average tick volume within range
   bool              bullish_bias;   // true = accumulation, false = distribution
   double            spring_low;     // Low of the Spring bar
   double            sos_high;       // High of the SOS bar
   double            upthrust_high;  // High of the Upthrust bar
   double            sow_low;        // Low of the SOW bar
  };

//+------------------------------------------------------------------+
//| Global Variables                                                 |
//+------------------------------------------------------------------+
ENUM_WYCKOFF_STATE g_state          = STATE_IDLE;         // Current EA state
SWyckoffRange      g_range;                               // Current range data
CTrade             g_trade;                               // Trade execution object
int                g_atr_handle     = INVALID_HANDLE;     // ATR indicator handle
datetime           g_last_bar       = 0;                  // Last processed bar time
int                g_lps_count      = 0;                  // Bars waited after SOS
int                g_lpsy_count     = 0;                  // Bars waited after SOW
int                g_range_watch    = 0;                  // Bars watched in RANGE_FORMING

//+------------------------------------------------------------------+
//| Returns pip size for the current symbol                          |
//+------------------------------------------------------------------+
double PipSize()
  {
   int digits = (int)SymbolInfoInteger(_Symbol, SYMBOL_DIGITS); // Get symbol digits
   return (digits == 3 || digits == 5) ? _Point * 10.0 : _Point; // Return pip size
  }

//+------------------------------------------------------------------+
//| Calculates lot size from risk percent and stop distance          |
//+------------------------------------------------------------------+
double CalcLots(double sl_pips)
  {
   double balance    = AccountInfoDouble(ACCOUNT_BALANCE);                    // Get balance
   double risk_money = balance * InpRiskPercent / 100.0;                      // Monetary risk
   double tick_val   = SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_VALUE);    // Tick value
   double tick_size  = SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_SIZE);     // Tick size
   double pip_size   = PipSize();                                             // Get pip size
   if(tick_size <= 0 || tick_val <= 0 || sl_pips <= 0)
      return 0;                                                               // Validate inputs
   double pip_value  = (pip_size / tick_size) * tick_val;                     // Pip monetary value
   double lots       = risk_money / (sl_pips * pip_value);                    // Raw lot size
   double step       = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_STEP);         // Volume step
   double min_lot    = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MIN);          // Minimum lot
   double max_lot    = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MAX);          // Maximum lot
   lots = MathFloor(lots / step) * step;                                      // Normalize to step
   return MathMax(min_lot, MathMin(max_lot, lots));                           // Clamp to limits
  }

//+------------------------------------------------------------------+
//| Checks if EA has an open position on this symbol                 |
//+------------------------------------------------------------------+
bool PositionOpen()
  {
   for(int i = PositionsTotal() - 1; i >= 0; i--)                             // Iterate positions
     {
      ulong ticket = PositionGetTicket(i);                                    // Get ticket
      if(!PositionSelectByTicket(ticket))
         continue;                                                            // Select position
      if(PositionGetString(POSITION_SYMBOL)  != _Symbol)
         continue;                                                            // Check symbol
      if(PositionGetInteger(POSITION_MAGIC)  != InpMagicNumber)
         continue;                                                            // Check magic
      return true;                                                            // Position found
     }
   return false;                                                              // No position
  }

//+------------------------------------------------------------------+
//| Draws a horizontal line at the specified price level             |
//+------------------------------------------------------------------+
void DrawHLine(string name, double price, color clr, ENUM_LINE_STYLE style)
  {
   if(!InpShowLabels)
      return;                                                                // Check flag
   string obj = "WYK_" + name;                                               // Build object name
   ObjectDelete(0, obj);                                                     // Remove existing
   ObjectCreate(0, obj, OBJ_HLINE, 0, 0, price);                             // Create hline
   ObjectSetInteger(0, obj, OBJPROP_COLOR, clr);                             // Set color
   ObjectSetInteger(0, obj, OBJPROP_STYLE, style);                           // Set style
   ObjectSetInteger(0, obj, OBJPROP_WIDTH, 1);                               // Set width
   ChartRedraw(0);                                                           // Redraw chart
  }

//+------------------------------------------------------------------+
//| Places a text label at the specified time and price              |
//+------------------------------------------------------------------+
void DrawLabel(string name, datetime time, double price, string text, color clr)
  {
   if(!InpShowLabels)
      return;                                                                // Check flag
   string obj = "WYK_" + name;                                               // Build object name
   ObjectDelete(0, obj);                                                     // Remove existing
   ObjectCreate(0, obj, OBJ_TEXT, 0, time, price);                           // Create text object
   ObjectSetString(0, obj, OBJPROP_TEXT, text);                              // Set text content
   ObjectSetInteger(0, obj, OBJPROP_COLOR, clr);                             // Set color
   ObjectSetInteger(0, obj, OBJPROP_FONTSIZE, 9);                            // Set font size
   ChartRedraw(0);                                                           // Redraw chart
  }

//+------------------------------------------------------------------+
//| Removes all chart objects created by this EA                     |
//+------------------------------------------------------------------+
void ClearLabels()
  {
   int total = ObjectsTotal(0);                                              // Get object count
   for(int i = total - 1; i >= 0; i--)                                       // Iterate backwards
     {
      string name = ObjectName(0, i);                                        // Get object name
      if(StringFind(name, "WYK_") == 0)
         ObjectDelete(0, name);                                              // Delete if EA's
     }
   ChartRedraw(0);                                                           // Redraw chart
  }

//+------------------------------------------------------------------+
//| Returns true if a downtrend preceded the specified bar           |
//+------------------------------------------------------------------+
bool HasPriorDowntrend(int from_bar)
  {
   double high_buf[], low_buf[];                                             // Price buffers
   ArraySetAsSeries(high_buf, true);                                         // Set as series
   ArraySetAsSeries(low_buf,  true);                                         // Set as series
   if(CopyHigh(_Symbol, PERIOD_CURRENT, from_bar, InpTrendBars, high_buf) < InpTrendBars)
      return false;                                                          // Copy highs
   if(CopyLow(_Symbol, PERIOD_CURRENT, from_bar, InpTrendBars, low_buf)  < InpTrendBars)
      return false;                                                          // Copy lows
   double first_high = 0, second_low = DBL_MAX;                              // Init comparators
   int half = InpTrendBars / 2;                                              // Split midpoint
   for(int i = 0; i < half; i++)
      first_high = MathMax(first_high, high_buf[i + half]);                  // Find early high
   for(int i = 0; i < half; i++)
      second_low = MathMin(second_low, low_buf[i]);                          // Find recent low
   return first_high > second_low + PipSize() * InpMinRangePips * 0.3;       // Confirm descent
  }

//+------------------------------------------------------------------+
//| Returns true if an uptrend preceded the specified bar            |
//+------------------------------------------------------------------+
bool HasPriorUptrend(int from_bar)
  {
   double high_buf[], low_buf[];                                              // Price buffers
   ArraySetAsSeries(high_buf, true);                                          // Set as series
   ArraySetAsSeries(low_buf,  true);                                          // Set as series
   if(CopyHigh(_Symbol, PERIOD_CURRENT, from_bar, InpTrendBars, high_buf) < InpTrendBars)
      return false;                                                          // Copy highs
   if(CopyLow(_Symbol, PERIOD_CURRENT, from_bar, InpTrendBars, low_buf)  < InpTrendBars)
      return false;                                                          // Copy lows
   double first_low = DBL_MAX, second_high = 0;                              // Init comparators
   int half = InpTrendBars / 2;                                              // Split midpoint
   for(int i = 0; i < half; i++)
      first_low   = MathMin(first_low,   low_buf[i + half]);                 // Find early low
   for(int i = 0; i < half; i++)
      second_high = MathMax(second_high, high_buf[i]);                       // Find recent high
   return second_high > first_low + PipSize() * InpMinRangePips * 0.3;       // Confirm ascent
  }

//+------------------------------------------------------------------+
//| Scans recent bars once to identify a valid Wyckoff range         |
//+------------------------------------------------------------------+
bool DetectRange()
  {
   double high_buf[], low_buf[];                                             // Price buffers
   long   vol_buf[];                                                         // Volume buffer
   ArraySetAsSeries(high_buf, true);                                         // Set as series
   ArraySetAsSeries(low_buf,  true);                                         // Set as series
   ArraySetAsSeries(vol_buf,  true);                                         // Set as series
   int bars = InpMaxRangeBars + InpTrendBars + 5;                            // Total bars needed
   if(CopyHigh(_Symbol, PERIOD_CURRENT, 1, bars, high_buf)     < bars)
      return false;                                                          // Copy highs
   if(CopyLow(_Symbol, PERIOD_CURRENT, 1, bars, low_buf)      < bars)
      return false;                                                          // Copy lows
   if(CopyTickVolume(_Symbol, PERIOD_CURRENT, 1, bars, vol_buf) < bars)
      return false;                                                          // Copy volumes
   double pip   = PipSize();                                                 // Get pip size
   double min_h = InpMinRangePips * pip;                                     // Min height in price
   double max_h = InpMaxRangePips * pip;                                     // Max height in price
//--- Try each possible range length from minimum to maximum
   for(int range_bars = InpMinRangeBars; range_bars <= InpMaxRangeBars; range_bars++)   // Try lengths
     {
      double rh = 0, rl = DBL_MAX;                                           // Init bounds
      for(int i = 0; i < range_bars; i++)                                    // Scan range bars
        {
         rh = MathMax(rh, high_buf[i]);                                      // Update range high
         rl = MathMin(rl, low_buf[i]);                                       // Update range low
        }
      double height = rh - rl;                                               // Compute height
      if(height < min_h)
         continue;                                                           // Too narrow, try longer
      if(height > max_h)
         break;                                                              // Too wide, stop
      //--- Check that all bars stay within 25% tolerance of range height
      double tol  = height * 0.25;                                           // Tolerance band
      bool   fits = true;                                                    // Fit flag
      for(int i = 0; i < range_bars; i++)                                    // Check each bar
        {
         if(high_buf[i] > rh + tol || low_buf[i] < rl - tol)                // Bar outside range
           {
            fits = false;                                                    // Mark as not fitting
            break;                                                           // Stop checking
           }
        }
      if(!fits)
         continue;                                                          // Skip this length
      //--- Confirm a prior trend before the range
      bool down_before = HasPriorDowntrend(range_bars + 1);                 // Check downtrend
      bool up_before   = HasPriorUptrend(range_bars + 1);                   // Check uptrend
      if(!down_before && !up_before)
         continue;                                                          // No prior trend
      //--- Compute average volume within the range
      double avg_vol = 0;                                                   // Volume sum
      for(int i = 0; i < range_bars; i++)
         avg_vol += (double)vol_buf[i];                                     // Accumulate
      avg_vol /= range_bars;                                                // Compute average
      //--- Populate the range struct
      g_range.support       = rl;                                            // Store support
      g_range.resistance    = rh;                                            // Store resistance
      g_range.start_bar     = range_bars;                                    // Store bar count
      g_range.avg_volume    = avg_vol;                                       // Store average vol
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
         g_range.bullish_bias = down_before;                                 // Set Bias
      g_range.spring_low    = 0;                                             // Clear spring low
      g_range.sos_high      = 0;                                             // Clear SOS high
      g_range.upthrust_high = 0;                                             // Clear upthrust
      g_range.sow_low       = 0;                                             // Clear SOW low
      DrawHLine("SUPPORT",    g_range.support,    clrGreen, STYLE_DASH);     // Draw support
      DrawHLine("RESISTANCE", g_range.resistance, clrRed,   STYLE_DASH);     // Draw resistance
      Print(StringFormat("WyckoffEA: Range locked | Bias: %s | S: %.5f | R: %.5f | Bars: %d | AvgVol: %.0f",
                         g_range.bullish_bias ? "ACCUMULATION" : "DISTRIBUTION",
                         g_range.support, g_range.resistance, range_bars, avg_vol));     // Log result
      return true;                                                           // Range valid
     }
   return false;                                                             // No range found
  }

//+------------------------------------------------------------------+
//| Checks the last closed bar for a valid Spring                    |
//+------------------------------------------------------------------+
bool CheckSpring()
  {
   double low1   = iLow(_Symbol, PERIOD_CURRENT, 1);                         // Last bar low
   double close1 = iClose(_Symbol, PERIOD_CURRENT, 1);                       // Last bar close
   double pip    = PipSize();                                                 // Get pip size
   double thresh = g_range.support - InpSpringTolerance * pip;               // Spring threshold
   if(low1 < thresh && close1 > g_range.support)                             // Penetrate and recover
     {
      long vol1 = iTickVolume(_Symbol, PERIOD_CURRENT, 1);                   // Last bar volume
      if((double)vol1 < g_range.avg_volume * InpLowVolMult)                  // Below volume threshold
        {
         g_range.spring_low = low1;                                          // Store Spring low
         datetime t1 = iTime(_Symbol, PERIOD_CURRENT, 1);                    // Get bar time
         DrawLabel("SPRING", t1, low1 - pip * 5, "SPRING", clrLime);         // Draw label
         Print(StringFormat("WyckoffEA: SPRING | Low: %.5f | Close: %.5f | Vol: %I64d | AvgVol: %.0f",
                            low1, close1, vol1, g_range.avg_volume));                     // Log event
         return true;                                                        // Spring confirmed
        }
     }
   return false;                                                              // Not a Spring
  }

//+------------------------------------------------------------------+
//| Checks the last closed bar for a valid Upthrust                  |
//+------------------------------------------------------------------+
bool CheckUpthrust()
  {
   double high1  = iHigh(_Symbol, PERIOD_CURRENT, 1);                        // Last bar high
   double close1 = iClose(_Symbol, PERIOD_CURRENT, 1);                       // Last bar close
   double pip    = PipSize();                                                // Get pip size
   double thresh = g_range.resistance + InpSpringTolerance * pip;            // Upthrust threshold
   if(high1 > thresh && close1 < g_range.resistance)                         // Penetrate and reverse
     {
      long vol1 = iTickVolume(_Symbol, PERIOD_CURRENT, 1);                   // Last bar volume
      if((double)vol1 < g_range.avg_volume * InpLowVolMult)                  // Below volume threshold
        {
         g_range.upthrust_high = high1;                                      // Store Upthrust high
         datetime t1 = iTime(_Symbol, PERIOD_CURRENT, 1);                    // Get bar time
         DrawLabel("UT", t1, high1 + pip * 5, "UPTHRUST", clrOrangeRed);    // Draw label
         Print(StringFormat("WyckoffEA: UPTHRUST | High: %.5f | Close: %.5f | Vol: %I64d | AvgVol: %.0f",
                            high1, close1, vol1, g_range.avg_volume));                    // Log event
         return true;                                                        // Upthrust confirmed
        }
     }
   return false;                                                              // Not an Upthrust
  }

//+------------------------------------------------------------------+
//| Checks the last closed bar for a Sign of Strength                |
//+------------------------------------------------------------------+
bool CheckSOS()
  {
   double close1 = iClose(_Symbol, PERIOD_CURRENT, 1);                       // Last bar close
   double high1  = iHigh(_Symbol, PERIOD_CURRENT, 1);                        // Last bar high
   if(close1 > g_range.resistance)                                           // Close above resistance
     {
      long vol1 = iTickVolume(_Symbol, PERIOD_CURRENT, 1);                   // Last bar volume
      if((double)vol1 > g_range.avg_volume * InpHighVolMult)                 // Above volume threshold
        {
         g_range.sos_high = high1;                                           // Store SOS high
         datetime t1 = iTime(_Symbol, PERIOD_CURRENT, 1);                    // Get bar time
         DrawLabel("SOS", t1, high1 + PipSize() * 5, "SOS", clrDodgerBlue); // Draw label
         Print(StringFormat("WyckoffEA: SOS | Close: %.5f | Vol: %I64d | AvgVol: %.0f",
                            close1, vol1, g_range.avg_volume));              // Log event
         return true;                                                        // SOS confirmed
        }
     }
   return false;                                                              // Not a SOS
  }

//+------------------------------------------------------------------+
//| Checks the last closed bar for a Sign of Weakness                |
//+------------------------------------------------------------------+
bool CheckSOW()
  {
   double close1 = iClose(_Symbol, PERIOD_CURRENT, 1);                       // Last bar close
   double low1   = iLow(_Symbol, PERIOD_CURRENT, 1);                         // Last bar low
   if(close1 < g_range.support)                                              // Close below support
     {
      long vol1 = iTickVolume(_Symbol, PERIOD_CURRENT, 1);                   // Last bar volume
      if((double)vol1 > g_range.avg_volume * InpHighVolMult)                 // Above volume threshold
        {
         g_range.sow_low = low1;                                             // Store SOW low
         datetime t1 = iTime(_Symbol, PERIOD_CURRENT, 1);                    // Get bar time
         DrawLabel("SOW", t1, low1 - PipSize() * 5, "SOW", clrCrimson);     // Draw label
         Print(StringFormat("WyckoffEA: SOW | Close: %.5f | Vol: %I64d | AvgVol: %.0f",
                            close1, vol1, g_range.avg_volume));               // Log event
         return true;                                                        // SOW confirmed
        }
     }
   return false;                                                              // Not a SOW
  }

//+------------------------------------------------------------------+
//| Waits for LPS pullback and opens long position                   |
//+------------------------------------------------------------------+
void CheckLPSEntry()
  {
   g_lps_count++;                                                            // Increment wait counter
   if(g_lps_count > InpLPSBars)                                              // Wait window expired
     {
      Print("WyckoffEA: LPS window expired — resetting.");                   // Log expiry
      g_state = STATE_IDLE;                                                  // Reset state
      ClearLabels();                                                         // Clear chart
      return;                                                                // Exit function
     }
   double close1 = iClose(_Symbol, PERIOD_CURRENT, 1);                       // Last bar close
   long   vol1   = iTickVolume(_Symbol, PERIOD_CURRENT, 1);                  // Last bar volume
   bool pulled_back = (close1 < g_range.sos_high && close1 > g_range.support); // Pullback check
   bool low_vol     = ((double)vol1 < g_range.avg_volume * InpHighVolMult);     // Volume check
   Print(StringFormat("WyckoffEA: LPS check %d/%d | Close: %.5f | PulledBack: %s | LowVol: %s",
                      g_lps_count, InpLPSBars, close1,
                      pulled_back ? "YES" : "NO", low_vol ? "YES" : "NO"));  // Log check
   if(pulled_back && low_vol)                                                // LPS conditions met
     {
      double atr_buf[];                                                      // ATR buffer
      ArraySetAsSeries(atr_buf, true);                                       // Set as series
      if(CopyBuffer(g_atr_handle, 0, 1, 1, atr_buf) < 1)
         return;                                                             // Copy ATR value
      double atr    = atr_buf[0];                                            // ATR value
      double ask    = SymbolInfoDouble(_Symbol, SYMBOL_ASK);                 // Current ask
      double sl     = ask - atr * InpATRMult;                                // Stop loss price
      double sl_pip = (ask - sl) / PipSize();                                // Stop in pips
      double tp     = ask + sl_pip * InpRR * PipSize();                      // Take profit price
      double lots   = CalcLots(sl_pip);                                      // Calculate lot size
      if(lots <= 0)
         return;                                                             // Invalid lot size
      long   stop_lv  = SymbolInfoInteger(_Symbol, SYMBOL_TRADE_STOPS_LEVEL); // Broker stop level
      double min_dist = stop_lv * _Point;                                    // Minimum distance
      if(ask - sl < min_dist)
         sl = ask - min_dist - _Point;                                      // Adjust SL if needed
      if(tp - ask < min_dist)
         tp = ask + min_dist + _Point;                                      // Adjust TP if needed
      if(g_trade.Buy(lots, _Symbol, ask, sl, tp, "Wyckoff LPS Long"))       // Open long
        {
         datetime t1 = iTime(_Symbol, PERIOD_CURRENT, 1);                    // Get bar time
         DrawLabel("LPS", t1, iLow(_Symbol, PERIOD_CURRENT, 1) - PipSize() * 3, "LPS", clrGold); // Draw label
         Print(StringFormat("WyckoffEA: LONG opened | Lots: %.2f | Ask: %.5f | SL: %.5f | TP: %.5f",
                            lots, ask, sl, tp));                                          // Log trade
         g_state = STATE_IN_TRADE;                                           // Update state
        }
     }
  }

//+------------------------------------------------------------------+
//| Waits for LPSY rally and opens short position                    |
//+------------------------------------------------------------------+
void CheckLPSYEntry()
  {
   g_lpsy_count++;                                                           // Increment wait counter
   if(g_lpsy_count > InpLPSBars)                                             // Wait window expired
     {
      Print("WyckoffEA: LPSY window expired — resetting.");                  // Log expiry
      g_state = STATE_IDLE;                                                  // Reset state
      ClearLabels();                                                         // Clear chart
      return;                                                                // Exit function
     }
   double close1 = iClose(_Symbol, PERIOD_CURRENT, 1);                       // Last bar close
   long   vol1   = iTickVolume(_Symbol, PERIOD_CURRENT, 1);                  // Last bar volume
   bool rallied = (close1 > g_range.sow_low && close1 < g_range.resistance); // Rally check
   bool low_vol = ((double)vol1 < g_range.avg_volume * InpHighVolMult);      // Volume check
   Print(StringFormat("WyckoffEA: LPSY check %d/%d | Close: %.5f | Rallied: %s | LowVol: %s",
                      g_lpsy_count, InpLPSBars, close1,
                      rallied ? "YES" : "NO", low_vol ? "YES" : "NO"));      // Log check
   if(rallied && low_vol)                                                    // LPSY conditions met
     {
      double atr_buf[];                                                      // ATR buffer
      ArraySetAsSeries(atr_buf, true);                                       // Set as series
      if(CopyBuffer(g_atr_handle, 0, 1, 1, atr_buf) < 1)
         return;                                                             // Copy ATR value
      double atr    = atr_buf[0];                                            // ATR value
      double bid    = SymbolInfoDouble(_Symbol, SYMBOL_BID);                 // Current bid
      double sl     = bid + atr * InpATRMult;                                // Stop loss price
      double sl_pip = (sl - bid) / PipSize();                                // Stop in pips
      double tp     = bid - sl_pip * InpRR * PipSize();                      // Take profit price
      double lots   = CalcLots(sl_pip);                                      // Calculate lot size
      if(lots <= 0)
         return;                                                             // Invalid lot size
      long   stop_lv  = SymbolInfoInteger(_Symbol, SYMBOL_TRADE_STOPS_LEVEL); // Broker stop level
      double min_dist = stop_lv * _Point;                                    // Minimum distance
      if(sl - bid < min_dist)
         sl = bid + min_dist + _Point;                                       // Adjust SL if needed
      if(bid - tp < min_dist)
         tp = bid - min_dist - _Point;                                       // Adjust TP if needed
      if(g_trade.Sell(lots, _Symbol, bid, sl, tp, "Wyckoff LPSY Short"))     // Open short
        {
         datetime t1 = iTime(_Symbol, PERIOD_CURRENT, 1);                    // Get bar time
         DrawLabel("LPSY", t1, iHigh(_Symbol, PERIOD_CURRENT, 1) + PipSize() * 3, "LPSY", clrGold); // Draw label
         Print(StringFormat("WyckoffEA: SHORT opened | Lots: %.2f | Bid: %.5f | SL: %.5f | TP: %.5f",
                            lots, bid, sl, tp));                                          // Log trade
         g_state = STATE_IN_TRADE;                                           // Update state
        }
     }
  }

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
   g_atr_handle = iATR(_Symbol, PERIOD_CURRENT, InpATRPeriod);               // Create ATR handle
   if(g_atr_handle == INVALID_HANDLE)                                        // Check handle
     {
      Print("WyckoffEA: ATR indicator handle creation failed.");             // Log error
      return INIT_FAILED;                                                    // Return failure
     }
   g_trade.SetExpertMagicNumber(InpMagicNumber);                             // Set magic number
   g_trade.SetDeviationInPoints(InpSlippage);                                // Set slippage
   g_state       = STATE_IDLE;                                               // Initialize state
   g_lps_count   = 0;                                                        // Initialize LPS counter
   g_lpsy_count  = 0;                                                        // Initialize LPSY counter
   g_range_watch = 0;                                                        // Initialize watch counter
   g_last_bar    = 0;                                                        // Initialize bar time
   Print("WyckoffEA initialized | Symbol: ", _Symbol,
         " | TF: ", EnumToString(Period()),
         " | Magic: ", InpMagicNumber);                                      // Log initialization
   return INIT_SUCCEEDED;                                                    // Return success
  }

//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   IndicatorRelease(g_atr_handle);                                            // Release ATR handle
   ClearLabels();                                                             // Remove chart objects
  }

//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
   datetime current_bar = iTime(_Symbol, PERIOD_CURRENT, 0);                 // Current bar open time
   if(current_bar == g_last_bar)
      return;                                                                // Skip if same bar
   g_last_bar = current_bar;                                                 // Update last bar time
   if(g_state == STATE_IN_TRADE)                                             // In trade state
     {
      if(!PositionOpen())                                                    // Position has closed
        {
         Print("WyckoffEA: Trade closed — returning to IDLE.");              // Log closure
         g_state       = STATE_IDLE;                                         // Reset state
         g_lps_count   = 0;                                                  // Reset LPS counter
         g_lpsy_count  = 0;                                                  // Reset LPSY counter
         g_range_watch = 0;                                                  // Reset watch counter
         ClearLabels();                                                      // Clear chart
        }
      return;                                                                // Exit tick
     }
   switch(g_state)                                                           // State machine switch
     {
      case STATE_IDLE:                                                       // Idle state
         if(DetectRange())                                                   // Range found
           {
            g_state       = STATE_RANGE_FORMING;                             // Advance state
            g_range_watch = 0;                                               // Reset watch counter
           }
         break;                                                              // End case
      case STATE_RANGE_FORMING:                                              // Range locked — watch only
         g_range_watch++;                                                    // Increment watch counter
         if(g_range_watch > InpRangeWatchBars)                               // Range stale
           {
            Print("WyckoffEA: Range watch expired — returning to IDLE.");    // Log expiry
            g_state = STATE_IDLE;                                            // Reset state
            ClearLabels();                                                   // Clear chart
            break;                                                           // End case
           }
         if(g_range.bullish_bias)                                            // Accumulation bias
           {
            if(CheckSpring())
               g_state = STATE_SPRING_DETECTED;                              // Spring found
           }
         else                                                                // Distribution bias
           {
            if(CheckUpthrust())
               g_state = STATE_UPTHRUST_DETECTED;                            // Upthrust found
           }
         break;                                                              // End case
      case STATE_SPRING_DETECTED:                                            // Spring detected
         if(CheckSOS())                                                      // SOS found
           {
            g_state     = STATE_SOS_CONFIRMED;                              // Advance state
            g_lps_count = 0;                                                // Reset LPS counter
           }
         else
            if(iClose(_Symbol, PERIOD_CURRENT, 1) < g_range.spring_low)   // Spring failed
              {
               Print("WyckoffEA: Spring invalidated — returning to IDLE.");    // Log failure
               g_state = STATE_IDLE;                                            // Reset state
               ClearLabels();                                                   // Clear chart
              }
         break;                                                              // End case
      case STATE_SOS_CONFIRMED:                                              // SOS confirmed
         CheckLPSEntry();                                                    // Check LPS entry
         break;                                                              // End case
      case STATE_UPTHRUST_DETECTED:                                          // Upthrust detected
         if(CheckSOW())                                                      // SOW found
           {
            g_state      = STATE_SOW_CONFIRMED;                             // Advance state
            g_lpsy_count = 0;                                               // Reset LPSY counter
           }
         else
            if(iClose(_Symbol, PERIOD_CURRENT, 1) > g_range.upthrust_high)   // Upthrust failed
              {
               Print("WyckoffEA: Upthrust invalidated — returning to IDLE.");  // Log failure
               g_state = STATE_IDLE;                                           // Reset state
               ClearLabels();                                                  // lear chart
              }
         break;                                                                // End case
      case STATE_SOW_CONFIRMED:                                                // SOW confirmed
         CheckLPSYEntry();                                                     // Check LPSY entry
         break;                                                                // End case
     }
  }
//+------------------------------------------------------------------+