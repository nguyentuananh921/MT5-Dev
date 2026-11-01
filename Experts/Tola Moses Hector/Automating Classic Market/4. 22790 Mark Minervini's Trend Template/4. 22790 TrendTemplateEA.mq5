//+------------------------------------------------------------------+
//|                                              TrendTemplateEA.mq5 |
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
#property description "Automating Classic Market Methods in MQL5 Part 4"
#property description "Mark Minervini Trend Template EA"
#property description "All 8 conditions must pass simultaneously before entry"
#property description "Daily timeframe recommended"

#include <Trade\Trade.mqh>

//+------------------------------------------------------------------+
//| Input Parameters                                                 |
//+------------------------------------------------------------------+
input group "=== Trend Template MAs ==="
input int    InpMA50Period       = 50;    // 50-day moving average period
input int    InpMA150Period      = 150;   // 150-day moving average period
input int    InpMA200Period      = 200;   // 200-day moving average period
input int    InpMA200SlopeBars   = 20;    // Bars to confirm 200-day MA uptrend

input group "=== 52-Week Range ==="
input int    InpYearBars         = 250;   // Bars representing one year
input double InpMinAboveLowPct   = 25.0;  // Minimum percent above 52-week low
input double InpMaxBelowHighPct  = 25.0;  // Maximum percent below 52-week high

input group "=== Entry Trigger ==="
input int    InpBreakoutBars     = 20;    // Bars for breakout high calculation
input double InpVolBreakoutMult  = 1.5;   // Volume multiplier required at breakout
input int    InpVolAvgPeriod     = 20;    // Bars for average volume calculation
input int    InpRSIPeriod        = 14;    // RSI period for condition 8
input double InpRSIMin           = 50.0;  // Minimum RSI for entry

input group "=== Entry and Risk ==="
input double InpRiskPercent      = 1.0;   // Risk per trade as percent of balance
input double InpRR               = 3.0;   // Risk-reward ratio
input int    InpATRPeriod        = 14;    // ATR period for stop placement
input double InpATRMult          = 2.0;   // ATR multiplier for stop distance

input group "=== Exit ==="
input bool   InpExitBelowMA50   = true;   // Exit if close below 50-day MA
input bool   InpTradeShorts      = false;  // Trade short setups (mirror conditions)

input group "=== General ==="
input int    InpMagicNumber      = 111001; // Magic number
input int    InpSlippage         = 10;     // Slippage in points
input bool   InpShowLabels       = true;   // Draw labels on chart
//+------------------------------------------------------------------+
//| Global Variables                                                 |
//+------------------------------------------------------------------+
CTrade g_trade;                                    // Trade execution object
int    g_ma50_handle  = INVALID_HANDLE;            // 50-day MA handle
int    g_ma150_handle = INVALID_HANDLE;            // 150-day MA handle
int    g_ma200_handle = INVALID_HANDLE;            // 200-day MA handle
int    g_atr_handle   = INVALID_HANDLE;            // ATR handle
int    g_rsi_handle   = INVALID_HANDLE;            // RSI handle
datetime g_last_bar   = 0;                         // Last processed bar time
bool   g_in_trade     = false;                     // Position tracking flag
//+------------------------------------------------------------------+
//| Returns pip size for the current symbol                          |
//+------------------------------------------------------------------+
double PipSize()
  {
   int digits = (int)SymbolInfoInteger(_Symbol, SYMBOL_DIGITS); // Get symbol digits
   return (digits == 3 || digits == 5) ? _Point * 10.0 : _Point; // Return pip size
  }

//+------------------------------------------------------------------+
//| Calculates lot size from risk percent and stop distance in pips  |
//+------------------------------------------------------------------+
double CalcLots(double sl_pips)
  {
   double balance    = AccountInfoDouble(ACCOUNT_BALANCE);                  // Get balance
   double risk_money = balance * InpRiskPercent / 100.0;                    // Monetary risk
   double tick_val   = SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_VALUE);  // Tick value
   double tick_size  = SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_SIZE);   // Tick size
   double pip_size   = PipSize();                                           // Get pip size
   if(tick_size <= 0 || tick_val <= 0 || sl_pips <= 0)
      return 0;                                                             // Validate inputs
   double pip_value  = (pip_size / tick_size) * tick_val;                   // Pip monetary value
   double lots       = risk_money / (sl_pips * pip_value);                  // Raw lot size
   double step       = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_STEP);       // Volume step
   double min_lot    = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MIN);        // Minimum lot
   double max_lot    = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MAX);        // Maximum lot
   lots = MathFloor(lots / step) * step;                                    // Normalize to step
   return MathMax(min_lot, MathMin(max_lot, lots));                         // Clamp to limits
  }
//+------------------------------------------------------------------+
//| Places a text label at the specified time and price              |
//+------------------------------------------------------------------+
void DrawLabel(string name, datetime time, double price, string text, color clr)
  {
   if(!InpShowLabels)
      return;                                                               // Check flag
   string obj = "TTM_" + name;                                              // Build object name
   ObjectDelete(0, obj);                                                    // Remove existing
   ObjectCreate(0, obj, OBJ_TEXT, 0, time, price);                          // Create text object
   ObjectSetString(0, obj, OBJPROP_TEXT, text);                             // Set text content
   ObjectSetInteger(0, obj, OBJPROP_COLOR, clr);                            // Set color
   ObjectSetInteger(0, obj, OBJPROP_FONTSIZE, 9);                           // Set font size
   ChartRedraw(0);                                                          // Redraw chart
  }

//+------------------------------------------------------------------+
//| Removes all chart objects created by this EA                     |
//+------------------------------------------------------------------+
void ClearLabels()
  {
   int total = ObjectsTotal(0);                                             // Get object count
   for(int i = total - 1; i >= 0; i--)                                      // Iterate backwards
     {
      string name = ObjectName(0, i);                                       // Get object name
      if(StringFind(name, "TTM_") == 0)
         ObjectDelete(0, name);                                             // Delete if EA's
     }
   ChartRedraw(0);                                                          // Redraw chart
  }
//+------------------------------------------------------------------+
//| Evaluates all 8 Trend Template conditions                        |
//| Returns true only if every condition passes simultaneously       |
//+------------------------------------------------------------------+
bool CheckTrendTemplate()
  {
//--- Copy all indicator values needed
   double ma50_buf[], ma150_buf[], ma200_buf[], rsi_buf[];
   ArraySetAsSeries(ma50_buf,  true);                                                 // Set as series
   ArraySetAsSeries(ma150_buf, true);                                                 // Set as series
   ArraySetAsSeries(ma200_buf, true);                                                 // Set as series
   ArraySetAsSeries(rsi_buf,   true);                                                 // Set as series
   int bars_needed = InpMA200SlopeBars + 2;                                           // Bars needed
   if(CopyBuffer(g_ma50_handle,  0, 1, bars_needed, ma50_buf)  < bars_needed)
      return false;                                                                   // Copy MA50
   if(CopyBuffer(g_ma150_handle, 0, 1, bars_needed, ma150_buf) < bars_needed)
      return false;                                                                   // Copy MA150
   if(CopyBuffer(g_ma200_handle, 0, 1, bars_needed, ma200_buf) < bars_needed)
      return false;                                                                   // Copy MA200
   if(CopyBuffer(g_rsi_handle,   0, 1, 1, rsi_buf)             < 1)
      return false;                                                                   // Copy RSI
   double price   = iClose(_Symbol, PERIOD_CURRENT, 1);                               // Last close
   double ma50    = ma50_buf[0];                                                      // Current MA50
   double ma150   = ma150_buf[0];                                                     // Current MA150
   double ma200   = ma200_buf[0];                                                     // Current MA200
   double ma200_past = ma200_buf[InpMA200SlopeBars];                                  // MA200 one month ago
   double rsi     = rsi_buf[0];                                                       // Current RSI
//--- Get 52-week high and low
   double high_buf[], low_buf[];                                                      // Year high/low buffers
   ArraySetAsSeries(high_buf, true);                                                  // Set as series
   ArraySetAsSeries(low_buf,  true);                                                  // Set as series
   if(CopyHigh(_Symbol, PERIOD_CURRENT, 1, InpYearBars, high_buf) < InpYearBars)
      return false;                                                                   // Copy highs
   if(CopyLow(_Symbol, PERIOD_CURRENT, 1, InpYearBars, low_buf)  < InpYearBars)
      return false;                                                                   // Copy lows
   double year_high = 0, year_low = DBL_MAX;                                          // Init year range
   for(int i = 0; i < InpYearBars; i++)                                               // Scan year bars
     {
      year_high = MathMax(year_high, high_buf[i]);                                    // Update year high
      year_low  = MathMin(year_low,  low_buf[i]);                                     // Update year low
     }
//--- Condition 1: Price above MA150 and MA200
   if(price <= ma150)
     { Print("TTM: C1 FAIL — price below MA150"); return false; }                     // Condition 1 failed
   if(price <= ma200)
     { Print("TTM: C1 FAIL — price below MA200"); return false; }                     // Condition 1 failed
//--- Condition 2: MA150 above MA200
   if(ma150 <= ma200)
     { Print("TTM: C2 FAIL — MA150 not above MA200"); return false; }                 // Condition 2 failed
//--- Condition 3: MA200 trending up for at least one month
   if(ma200 <= ma200_past)
     { Print("TTM: C3 FAIL — MA200 not rising"); return false; }                      // Condition 3 failed
//--- Condition 4: MA50 above MA150 and MA200
   if(ma50 <= ma150)
     { Print("TTM: C4 FAIL — MA50 not above MA150"); return false; }                  // Condition 4 failed
   if(ma50 <= ma200)
     { Print("TTM: C4 FAIL — MA50 not above MA200"); return false; }                  // Condition 4 failed
//--- Condition 5: Price above MA50
   if(price <= ma50)
     { Print("TTM: C5 FAIL — price below MA50"); return false; }                      // Condition 5 failed
//--- Condition 6: Price at least 25% above 52-week low
   if(year_low <= 0)
      return false;                                                                   // Invalid year low
   double above_low_pct = ((price - year_low) / year_low) * 100.0;                    // Percent above low
   if(above_low_pct < InpMinAboveLowPct)
     {
      Print(StringFormat("TTM: C6 FAIL — %.1f%% above low (need %.1f%%)",
                         above_low_pct, InpMinAboveLowPct));                          // Log failure
      return false;                                                                   // Condition 6 failed
     }
//--- Condition 7: Price within 25% of 52-week high
   if(year_high <= 0)
      return false;                                                                   // Invalid year high
   double below_high_pct = ((year_high - price) / year_high) * 100.0;                 // Percent below high
   if(below_high_pct > InpMaxBelowHighPct)
     {
      Print(StringFormat("TTM: C7 FAIL — %.1f%% below high (max %.1f%%)",
                         below_high_pct, InpMaxBelowHighPct));                        // Log failure
      return false;                                                                   // Condition 7 failed
     }
//--- Condition 8: RSI above minimum (momentum substitute for RS rating)
   if(rsi < InpRSIMin)
     {
      Print(StringFormat("TTM: C8 FAIL — RSI %.1f below %.1f", rsi, InpRSIMin));      // Log failure
      return false;                                                                   // Condition 8 failed
     }
   Print(StringFormat("TTM: ALL PASS | Price:%.5f | MA50:%.5f | MA150:%.5f | MA200:%.5f | AboveLow:%.1f%% | BelowHigh:%.1f%% | RSI:%.1f",
                      price, ma50, ma150, ma200, above_low_pct, below_high_pct, rsi));// Log pass
   return true;                                                                       // All conditions passed
  }
//+------------------------------------------------------------------+
//| Returns true if last bar closed above the 20-bar high on volume  |
//+------------------------------------------------------------------+
bool IsBreakout(bool is_long)
  {
   double close1 = iClose(_Symbol, PERIOD_CURRENT, 1);                     // Last bar close
//--- Get breakout reference level
   if(is_long)
     {
      double high_buf[];                                                    // High buffer
      ArraySetAsSeries(high_buf, true);                                     // Set as series
      if(CopyHigh(_Symbol, PERIOD_CURRENT, 2, InpBreakoutBars, high_buf) < InpBreakoutBars)
         return false;                                                      // Copy highs
      double ref_high = 0;                                                  // Reference high
      for(int i = 0; i < InpBreakoutBars; i++)
         ref_high = MathMax(ref_high, high_buf[i]);                         // Find period high
      if(close1 <= ref_high)
         return false;                                                      // No breakout
     }
   else
     {
      double low_buf[];                                                     // Low buffer
      ArraySetAsSeries(low_buf, true);                                      // Set as series
      if(CopyLow(_Symbol, PERIOD_CURRENT, 2, InpBreakoutBars, low_buf) < InpBreakoutBars)
         return false;                                                      // Copy lows
      double ref_low = DBL_MAX;                                             // Reference low
      for(int i = 0; i < InpBreakoutBars; i++)
         ref_low = MathMin(ref_low, low_buf[i]);                            // Find period low
      if(close1 >= ref_low)
         return false;                                                      // No breakout
     }
//--- Check volume confirmation
   long vol_buf[];                                                          // Volume buffer
   ArraySetAsSeries(vol_buf, true);                                         // Set as series
   if(CopyTickVolume(_Symbol, PERIOD_CURRENT, 1, InpVolAvgPeriod + 1, vol_buf) < InpVolAvgPeriod + 1)
      return false;                                                         // Copy volumes
   long   breakout_vol = vol_buf[0];                                        // Breakout bar volume
   double avg_vol      = 0;                                                 // Average accumulator
   for(int i = 1; i <= InpVolAvgPeriod; i++)
      avg_vol += (double)vol_buf[i];                                        // Sum prior volumes
   avg_vol /= InpVolAvgPeriod;                                              // Compute average
   bool vol_ok = ((double)breakout_vol > avg_vol * InpVolBreakoutMult);     // Volume check
   Print(StringFormat("TTM: Breakout | BreakoutVol:%I64d | AvgVol:%.0f | Ratio:%.2f | VolOK:%s",
                      breakout_vol, avg_vol,
                      (double)breakout_vol / avg_vol, vol_ok ? "YES" : "NO")); // Log result
   return vol_ok;                                                           // Return result
  }
//+------------------------------------------------------------------+
//| Opens a long trade on Trend Template + breakout confirmation     |
//+------------------------------------------------------------------+
void OpenLong()
  {
   double atr_buf[];                                                        // ATR buffer
   ArraySetAsSeries(atr_buf, true);                                         // Set as series
   if(CopyBuffer(g_atr_handle, 0, 1, 1, atr_buf) < 1)
      return;                                                               // Copy ATR
   double atr    = atr_buf[0];                                              // ATR value
   double ask    = SymbolInfoDouble(_Symbol, SYMBOL_ASK);                   // Current ask
   double sl     = ask - atr * InpATRMult;                                  // Stop loss price
   double sl_pip = (ask - sl) / PipSize();                                  // Stop in pips
   double tp     = ask + sl_pip * InpRR * PipSize();                        // Take profit price
   double lots   = CalcLots(sl_pip);                                        // Calculate lot size
   if(lots <= 0)
      return;                                                               // Invalid lot size
   long   stop_lv  = SymbolInfoInteger(_Symbol, SYMBOL_TRADE_STOPS_LEVEL);  // Broker stop level
   double min_dist = stop_lv * _Point;                                      // Minimum distance
   if(ask - sl < min_dist)
      sl = ask - min_dist - _Point;                                         // Adjust SL if needed
   if(tp - ask < min_dist)
      tp = ask + min_dist + _Point;                                         // Adjust TP if needed
   if(g_trade.Buy(lots, _Symbol, ask, sl, tp, "Minervini TT Long"))         // Open long
     {
      datetime t1 = iTime(_Symbol, PERIOD_CURRENT, 1);                      // Get bar time
      DrawLabel("ENTRY", t1,
                iLow(_Symbol, PERIOD_CURRENT, 1) - PipSize() * 5,
                "TT LONG", clrDodgerBlue);                                  // Draw label
      Print(StringFormat("TTM: LONG opened | Lots:%.2f | Ask:%.5f | SL:%.5f | TP:%.5f",
                         lots, ask, sl, tp));                               // Log trade
      g_in_trade = true;                                                    // Update flag
     }
  }
//+------------------------------------------------------------------+
//| Opens a short trade on inverted Trend Template + breakdown       |
//+------------------------------------------------------------------+
void OpenShort()
  {
   if(!InpTradeShorts)
      return;                                                               // Shorts disabled
   double atr_buf[];                                                        // ATR buffer
   ArraySetAsSeries(atr_buf, true);                                         // Set as series
   if(CopyBuffer(g_atr_handle, 0, 1, 1, atr_buf) < 1)
      return;                                                               // Copy ATR
   double atr    = atr_buf[0];                                              // ATR value
   double bid    = SymbolInfoDouble(_Symbol, SYMBOL_BID);                   // Current bid
   double sl     = bid + atr * InpATRMult;                                  // Stop loss price
   double sl_pip = (sl - bid) / PipSize();                                  // Stop in pips
   double tp     = bid - sl_pip * InpRR * PipSize();                        // Take profit price
   double lots   = CalcLots(sl_pip);                                        // Calculate lot size
   if(lots <= 0)
      return;                                                               // Invalid lot size
   long   stop_lv  = SymbolInfoInteger(_Symbol, SYMBOL_TRADE_STOPS_LEVEL);  // Broker stop level
   double min_dist = stop_lv * _Point;                                      // Minimum distance
   if(sl - bid < min_dist)
      sl = bid + min_dist + _Point;                                         // Adjust SL if needed
   if(bid - tp < min_dist)
      tp = bid - min_dist - _Point;                                         // Adjust TP if needed
   if(g_trade.Sell(lots, _Symbol, bid, sl, tp, "Minervini TT Short"))       // Open short
     {
      datetime t1 = iTime(_Symbol, PERIOD_CURRENT, 1);                      // Get bar time
      DrawLabel("ENTRY", t1,
                iHigh(_Symbol, PERIOD_CURRENT, 1) + PipSize() * 5,
                "TT SHORT", clrCrimson);                                    // Draw label
      Print(StringFormat("TTM: SHORT opened | Lots:%.2f | Bid:%.5f | SL:%.5f | TP:%.5f",
                         lots, bid, sl, tp));                               // Log trade
      g_in_trade = true;                                                    // Update flag
     }
  }
//+------------------------------------------------------------------+
//| Checks whether open positions should be exited                   |
//+------------------------------------------------------------------+
void CheckExit()
  {
   for(int i = PositionsTotal() - 1; i >= 0; i--)                                            // Iterate positions
     {
      ulong ticket = PositionGetTicket(i);                                                   // Get ticket
      if(!PositionSelectByTicket(ticket))
         continue;                                                                           // Select position
      if(PositionGetString(POSITION_SYMBOL)  != _Symbol)
         continue;                                                                           // Check symbol
      if(PositionGetInteger(POSITION_MAGIC)  != InpMagicNumber)
         continue;                                                                           // Check magic
      long   pos_type = PositionGetInteger(POSITION_TYPE);                                   // Position type
      double close1   = iClose(_Symbol, PERIOD_CURRENT, 1);                                  // Last close
      double ma50_buf[];                                                                     // MA50 buffer
      ArraySetAsSeries(ma50_buf, true);                                                      // Set as series
      if(CopyBuffer(g_ma50_handle, 0, 1, 1, ma50_buf) < 1)
         continue;                                                                           // Copy MA50
      double ma50 = ma50_buf[0];                                                             // Current MA50
      bool exit_long  = InpExitBelowMA50 && pos_type == POSITION_TYPE_BUY  && close1 < ma50; // Long exit
      bool exit_short = InpExitBelowMA50 && pos_type == POSITION_TYPE_SELL && close1 > ma50; // Short exit
      if(exit_long || exit_short)                                                            // Exit condition met
        {
         if(g_trade.PositionClose(ticket))                                                   // Close position
           {
            string dir = (pos_type == POSITION_TYPE_BUY) ? "LONG" : "SHORT";                 // Direction
            Print(StringFormat("TTM: %s closed — MA50 breach. Ticket:%I64u", dir, ticket));  // Log exit
            g_in_trade = false;                                                              // Update flag
            ClearLabels();                                                                   // Clear chart
           }
        }
     }
  }
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
   g_ma50_handle  = iMA(_Symbol, PERIOD_CURRENT, InpMA50Period,  0, MODE_SMA, PRICE_CLOSE); // Create MA50
   g_ma150_handle = iMA(_Symbol, PERIOD_CURRENT, InpMA150Period, 0, MODE_SMA, PRICE_CLOSE); // Create MA150
   g_ma200_handle = iMA(_Symbol, PERIOD_CURRENT, InpMA200Period, 0, MODE_SMA, PRICE_CLOSE); // Create MA200
   g_atr_handle   = iATR(_Symbol, PERIOD_CURRENT, InpATRPeriod);                            // Create ATR
   g_rsi_handle   = iRSI(_Symbol, PERIOD_CURRENT, InpRSIPeriod, PRICE_CLOSE);               // Create RSI
   if(g_ma50_handle  == INVALID_HANDLE ||                                                   // Check MA50
      g_ma150_handle == INVALID_HANDLE ||                                                   // Check MA150
      g_ma200_handle == INVALID_HANDLE ||                                                   // Check MA200
      g_atr_handle   == INVALID_HANDLE ||                                                   // Check ATR
      g_rsi_handle   == INVALID_HANDLE)                                                     // Check RSI
     {
      Print("TrendTemplateEA: Indicator handle creation failed.");                          // Log error
      return INIT_FAILED;                                                                   // Return failure
     }
   g_trade.SetExpertMagicNumber(InpMagicNumber);                                            // Set magic number
   g_trade.SetDeviationInPoints(InpSlippage);                                               // Set slippage
   g_in_trade = false;                                                                      // No initial trade
   g_last_bar = 0;                                                                          // Initialize bar time
   Print("TrendTemplateEA initialized | Symbol:", _Symbol,
         " | TF:", EnumToString(Period()),
         " | Magic:", InpMagicNumber);                                                      // Log initialization
   return INIT_SUCCEEDED;                                                                   // Return success
  }

//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   IndicatorRelease(g_ma50_handle);                                                         // Release MA50
   IndicatorRelease(g_ma150_handle);                                                        // Release MA150
   IndicatorRelease(g_ma200_handle);                                                        // Release MA200
   IndicatorRelease(g_atr_handle);                                                          // Release ATR
   IndicatorRelease(g_rsi_handle);                                                          // Release RSI
   ClearLabels();                                                                           // Remove chart objects
  }

//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
   datetime current_bar = iTime(_Symbol, PERIOD_CURRENT, 0);                                // Current bar open time
   if(current_bar == g_last_bar)
      return;                                                                               // Skip if same bar
   g_last_bar = current_bar;                                                                // Update last bar time
//--- Check exit conditions for any open position
   CheckExit();                                                                             // Check exit signals
   if(g_in_trade)
      return;                                                                               // No new entry while in trade
//--- Evaluate Trend Template for long setup
   if(CheckTrendTemplate())                                                                 // All 8 conditions pass
     {
      if(IsBreakout(true))                                                                  // Breakout confirmed
        {
         OpenLong();                                                                        // Enter long
         return;                                                                            // Exit tick
        }
     }
//--- Evaluate inverse template for short setup
   if(InpTradeShorts && CheckInverseTemplate())                                             // Inverse conditions pass
     {
      if(IsBreakout(false))                                                                 // Breakdown confirmed
         OpenShort();                                                                       // Enter short
     }
  }
//+------------------------------------------------------------------+
//| Evaluates the inverse of all 8 conditions for short setups       |
//+------------------------------------------------------------------+
bool CheckInverseTemplate()
  {
   double ma50_buf[], ma150_buf[], ma200_buf[], rsi_buf[];
   ArraySetAsSeries(ma50_buf,  true);                                       // Set as series
   ArraySetAsSeries(ma150_buf, true);                                       // Set as series
   ArraySetAsSeries(ma200_buf, true);                                       // Set as series
   ArraySetAsSeries(rsi_buf,   true);                                       // Set as series
   int bars_needed = InpMA200SlopeBars + 2;                                 // Bars needed
   if(CopyBuffer(g_ma50_handle,  0, 1, bars_needed, ma50_buf)  < bars_needed)
      return false;                                                         // Copy MA50
   if(CopyBuffer(g_ma150_handle, 0, 1, bars_needed, ma150_buf) < bars_needed)
      return false;                                                         // Copy MA150
   if(CopyBuffer(g_ma200_handle, 0, 1, bars_needed, ma200_buf) < bars_needed)
      return false;                                                         // Copy MA200
   if(CopyBuffer(g_rsi_handle,   0, 1, 1, rsi_buf)             < 1)
      return false;                                                         // Copy RSI
   double price      = iClose(_Symbol, PERIOD_CURRENT, 1);                  // Last close
   double ma50       = ma50_buf[0];                                         // Current MA50
   double ma150      = ma150_buf[0];                                        // Current MA150
   double ma200      = ma200_buf[0];                                        // Current MA200
   double ma200_past = ma200_buf[InpMA200SlopeBars];                        // MA200 one month ago
   double rsi        = rsi_buf[0];                                          // Current RSI
   double high_buf[], low_buf[];
   ArraySetAsSeries(high_buf, true);                                        // Set as series
   ArraySetAsSeries(low_buf,  true);                                        // Set as series
   if(CopyHigh(_Symbol, PERIOD_CURRENT, 1, InpYearBars, high_buf) < InpYearBars)
      return false;                                                         // Copy highs
   if(CopyLow(_Symbol, PERIOD_CURRENT, 1, InpYearBars, low_buf)  < InpYearBars)
      return false;                                                         // Copy lows
   double year_high = 0, year_low = DBL_MAX;                                // Init year range
   for(int i = 0; i < InpYearBars; i++)
     {
      year_high = MathMax(year_high, high_buf[i]);                          // Update year high
      year_low  = MathMin(year_low,  low_buf[i]);                           // Update year low
     }
//--- Inverse conditions: price below MAs, MAs stacked downward, MA200 declining
   if(price >= ma150)
      return false;                                                         // Price above MA150 — skip
   if(price >= ma200)
      return false;                                                         // Price above MA200 — skip
   if(ma150 >= ma200)
      return false;                                                         // MA150 not below MA200 — skip
   if(ma200 >= ma200_past)
      return false;                                                         // MA200 not declining — skip
   if(ma50  >= ma150)
      return false;                                                         // MA50 not below MA150 — skip
   if(ma50  >= ma200)
      return false;                                                         // MA50 not below MA200 — skip
   if(price >= ma50)
      return false;                                                         // Price above MA50 — skip
   if(year_high <= 0)
      return false;                                                         // Invalid year high
   double below_high_pct = ((year_high - price) / year_high) * 100.0;       // Percent below high
   if(below_high_pct < InpMinAboveLowPct)
      return false;                                                         // Not far enough below high
   if(year_low <= 0)
      return false;                                                         // Invalid year low
   double above_low_pct = ((price - year_low) / year_low) * 100.0;          // Percent above low
   if(above_low_pct > InpMaxBelowHighPct)
      return false;                                                         // Too far above low
   if(rsi > (100.0 - InpRSIMin))
      return false;                                                         // RSI too high for short
   Print("TTM: INVERSE ALL PASS — short setup confirmed");                  // Log pass
   return true;                                                             // All inverse conditions passed
  }
//+------------------------------------------------------------------+
