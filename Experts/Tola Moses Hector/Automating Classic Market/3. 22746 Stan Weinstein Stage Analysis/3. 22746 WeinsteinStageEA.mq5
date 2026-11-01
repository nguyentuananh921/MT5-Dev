//+------------------------------------------------------------------+
//|                                           WeinsteinStageEA.mq5   |
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
#property description "Automating Classic Market Methods in MQL5 Part 3"
#property description "Stan Weinstein Stage Analysis EA"
#property description "Trades Stage 2 breakouts long and Stage 4 breakdowns short"
#property description "Daily timeframe recommended"

#include <Trade\Trade.mqh>

//+------------------------------------------------------------------+
//| Market Stage Enumeration                                         |
//+------------------------------------------------------------------+
enum ENUM_MARKET_STAGE
  {
   STAGE_UNKNOWN   = 0, // Stage cannot be determined
   STAGE_1_BASE    = 1, // Base: MA flattening, price sideways above or at MA
   STAGE_2_ADVANCE = 2, // Advance: MA rising, price above MA, higher highs
   STAGE_3_TOP     = 3, // Top: MA flattening, price oscillating around MA
   STAGE_4_DECLINE = 4  // Decline: MA falling, price below MA, lower lows
  };

//+------------------------------------------------------------------+
//| Input Parameters                                                 |
//+------------------------------------------------------------------+
input group "=== Stage Detection ==="
input int    InpMAPeriod         = 150;    // MA period (150 daily = 30 weekly)
input int    InpSlopeLookback    = 10;     // Bars to measure MA slope direction
input double InpSlopeThreshold   = 0.0001; // Minimum slope to classify as rising or falling
input int    InpHighLowLookback  = 20;     // Bars to check for higher highs and lower lows

input group "=== Breakout Conditions ==="
input double InpVolBreakoutMult  = 1.8;   // Volume multiplier required at breakout
input int    InpVolAvgPeriod     = 20;    // Bars for average volume calculation
input int    InpRSIPeriod        = 14;    // RSI period for momentum filter
input double InpRSIBullMin       = 50.0;  // Minimum RSI for Stage 2 entry
input double InpRSIBearMax       = 50.0;  // Maximum RSI for Stage 4 entry

input group "=== Entry and Risk ==="
input double InpRiskPercent      = 1.0;   // Risk per trade as percent of balance
input double InpRR               = 3.0;   // Risk-reward ratio
input int    InpATRPeriod        = 14;    // ATR period for stop placement
input double InpATRMult          = 2.0;   // ATR multiplier for stop distance

input group "=== Exit Conditions ==="
input int    InpExitMAPeriod     = 150;   // MA period for exit check
input double InpExitVolMult      = 1.5;   // Volume multiplier for MA break exit signal

input group "=== General ==="
input int    InpMagicNumber      = 999001; // Magic number
input int    InpSlippage         = 10;     // Slippage in points
input bool   InpShowLabels       = true;   // Draw stage labels on chart
input bool   InpTradeShorts      = true;   // Allow Stage 4 short trades
//+------------------------------------------------------------------+
//| Global Variables                                                 |
//+------------------------------------------------------------------+
CTrade             g_trade;                           // Trade execution object
int                g_ma_handle   = INVALID_HANDLE;    // MA indicator handle
int                g_atr_handle  = INVALID_HANDLE;    // ATR indicator handle
int                g_rsi_handle  = INVALID_HANDLE;    // RSI indicator handle
datetime           g_last_bar    = 0;                 // Last processed bar time
ENUM_MARKET_STAGE  g_prev_stage  = STAGE_UNKNOWN;     // Previous stage for transition detection
bool               g_in_trade    = false;             // Position tracking flag
//+------------------------------------------------------------------+
//| Returns pip size for the current symbol                          |
//+------------------------------------------------------------------+
double PipSize()
  {
   int digits = (int)SymbolInfoInteger(_Symbol, SYMBOL_DIGITS);  // Get symbol digits
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
//| Places a text label at the specified bar and price               |
//+------------------------------------------------------------------+
void DrawLabel(string name, datetime time, double price, string text, color clr)
  {
   if(!InpShowLabels)
      return;                                                               // Check flag
   string obj = "WST_" + name;                                              // Build object name
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
      if(StringFind(name, "WST_") == 0)
         ObjectDelete(0, name);                                             // Delete if EA's
     }
   ChartRedraw(0);                                                          // Redraw chart
  }
//+------------------------------------------------------------------+
//| Classifies the current market stage from MA, price, and volume   |
//+------------------------------------------------------------------+
ENUM_MARKET_STAGE ClassifyStage()
  {
   double ma_buf[];                                                         // MA buffer
   ArraySetAsSeries(ma_buf, true);                                          // Set as series
   int bars_needed = InpSlopeLookback + InpHighLowLookback + 5;             // Bars required
   if(CopyBuffer(g_ma_handle, 0, 1, bars_needed, ma_buf) < bars_needed)
      return STAGE_UNKNOWN;                                                 // Insufficient data
   double close1    = iClose(_Symbol, PERIOD_CURRENT, 1);                   // Last close
   double ma_now    = ma_buf[0];                                            // Current MA
   double ma_past   = ma_buf[InpSlopeLookback];                             // MA at lookback
   double slope     = (ma_now - ma_past) / InpSlopeLookback / close1;       // Normalized slope
   bool   ma_rising = slope >  InpSlopeThreshold;                           // MA rising
   bool   ma_falling= slope < -InpSlopeThreshold;                           // MA falling
   bool   ma_flat   = !ma_rising && !ma_falling;                            // MA flat
   bool   price_above_ma = close1 > ma_now;                                 // Price above MA
   bool   price_below_ma = close1 < ma_now;                                 // Price below MA
//--- Check for higher highs (Stage 2 characteristic)
   double high_recent = 0, high_older = 0;                                  // High comparators
   int half = InpHighLowLookback / 2;                                       // Split midpoint
   for(int i = 1; i <= half; i++)
      high_recent = MathMax(high_recent, iHigh(_Symbol, PERIOD_CURRENT, i)); // Recent highs
   for(int i = half + 1; i <= InpHighLowLookback; i++)
      high_older = MathMax(high_older, iHigh(_Symbol, PERIOD_CURRENT, i));   // Older highs
   bool higher_highs = high_recent > high_older;                             // Higher highs present
//--- Check for lower lows (Stage 4 characteristic)
   double low_recent = DBL_MAX, low_older = DBL_MAX;                         // Low comparators
   for(int i = 1; i <= half; i++)
      low_recent = MathMin(low_recent, iLow(_Symbol, PERIOD_CURRENT, i));    // Recent lows
   for(int i = half + 1; i <= InpHighLowLookback; i++)
      low_older = MathMin(low_older, iLow(_Symbol, PERIOD_CURRENT, i));      // Older lows
   bool lower_lows = low_recent < low_older;                                 // Lower lows present
//--- Stage classification logic
   if(ma_rising && price_above_ma && higher_highs)
      return STAGE_2_ADVANCE;                                               // Stage 2: advancing
   if(ma_falling && price_below_ma && lower_lows)
      return STAGE_4_DECLINE;                                               // Stage 4: declining
   if(ma_flat && price_above_ma)
      return STAGE_1_BASE;                                                  // Stage 1: basing
   if(ma_flat && price_below_ma)
      return STAGE_3_TOP;                                                   // Stage 3: topping
   if(ma_rising && price_below_ma)
      return STAGE_3_TOP;                                                   // Stage 3: early decline
   if(ma_falling && price_above_ma)
      return STAGE_1_BASE;                                                  // Stage 1: early base
   return STAGE_UNKNOWN;                                                    // Cannot classify
  }
//+------------------------------------------------------------------+
//| Returns true if volume confirms a valid Stage 2 breakout         |
//+------------------------------------------------------------------+
bool IsValidBreakout()
  {
   long vol_buf[];                                                          // Volume buffer
   ArraySetAsSeries(vol_buf, true);                                         // Set as series
   if(CopyTickVolume(_Symbol, PERIOD_CURRENT, 1, InpVolAvgPeriod + 1, vol_buf) < InpVolAvgPeriod + 1)
      return false;                                                         // Insufficient data
   long  breakout_vol = vol_buf[0];                                         // Breakout bar volume
   double avg_vol     = 0;                                                  // Volume accumulator
   for(int i = 1; i <= InpVolAvgPeriod; i++)
      avg_vol += (double)vol_buf[i];                                        // Sum prior volumes
   avg_vol /= InpVolAvgPeriod;                                              // Compute average
   bool vol_ok = ((double)breakout_vol > avg_vol * InpVolBreakoutMult);     // Volume check
   Print(StringFormat("Weinstein: BreakoutVol:%I64d AvgVol:%.0f Ratio:%.2f Required:%.1fx Valid:%s",
                      breakout_vol, avg_vol, (double)breakout_vol / avg_vol,
                      InpVolBreakoutMult, vol_ok ? "YES" : "NO"));          // Log result
   return vol_ok;                                                           // Return result
  }

//+------------------------------------------------------------------+
//| Returns true if RSI confirms momentum at the breakout bar        |
//+------------------------------------------------------------------+
bool RSIConfirmsBreakout(bool is_long)
  {
   double rsi_buf[];                                                        // RSI buffer
   ArraySetAsSeries(rsi_buf, true);                                         // Set as series
   if(CopyBuffer(g_rsi_handle, 0, 1, 1, rsi_buf) < 1)
      return false;                                                         // Insufficient data
   double rsi = rsi_buf[0];                                                 // RSI value
   bool ok = is_long ? rsi >= InpRSIBullMin : rsi <= InpRSIBearMax;         // Check threshold
   Print(StringFormat("Weinstein: RSI:%.1f Required:%s%.1f Valid:%s",
                      rsi, is_long ? ">=" : "<=",
                      is_long ? InpRSIBullMin : InpRSIBearMax,
                      ok ? "YES" : "NO"));                                  // Log result
   return ok;                                                               // Return result
  }
//+------------------------------------------------------------------+
//| Opens a Stage 2 long trade on confirmed breakout                 |
//+------------------------------------------------------------------+
void OpenLong()
  {
   if(!IsValidBreakout())
     {
      Print("Weinstein: Stage 2 breakout — volume insufficient. Skipping.");  // Log skip
      return;                                                                 // Volume not confirmed
     }
   if(!RSIConfirmsBreakout(true))
     {
      Print("Weinstein: Stage 2 breakout — RSI not confirming. Skipping."); // Log skip
      return;                                                               // Momentum not confirmed
     }
   double atr_buf[];                                                        // ATR buffer
   ArraySetAsSeries(atr_buf, true);                                         // Set as series
   if(CopyBuffer(g_atr_handle, 0, 1, 1, atr_buf) < 1)
      return;                                                               // Copy ATR
   double atr    = atr_buf[0];                                              // ATR value
   double ask    = SymbolInfoDouble(_Symbol, SYMBOL_ASK);                   // Current ask
   double sl     = ask - atr * InpATRMult;                                  // Stop below recent ATR
   double sl_pip = (ask - sl) / PipSize();                                  // Stop in pips
   double tp     = ask + sl_pip * InpRR * PipSize();                        // Take profit at RR
   double lots   = CalcLots(sl_pip);                                        // Calculate lot size
   if(lots <= 0)
      return;                                                               // Invalid lot size
   long   stop_lv  = SymbolInfoInteger(_Symbol, SYMBOL_TRADE_STOPS_LEVEL);  // Broker stop level
   double min_dist = stop_lv * _Point;                                      // Minimum distance
   if(ask - sl < min_dist)
      sl = ask - min_dist - _Point;                                         // Adjust SL if needed
   if(tp - ask < min_dist)
      tp = ask + min_dist + _Point;                                         // Adjust TP if needed
   CTrade trade;                                                            // Trade object
   trade.SetExpertMagicNumber(InpMagicNumber);                              // Set magic number
   trade.SetDeviationInPoints(InpSlippage);                                 // Set slippage
   if(trade.Buy(lots, _Symbol, ask, sl, tp, "Weinstein Stage 2 Long"))      // Open long
     {
      datetime t1 = iTime(_Symbol, PERIOD_CURRENT, 1);                      // Get bar time
      DrawLabel("S2ENTRY", t1, iLow(_Symbol, PERIOD_CURRENT, 1) - PipSize() * 5,
                "STAGE 2", clrDodgerBlue);                                  // Draw label
      Print(StringFormat("Weinstein: LONG opened | Lots:%.2f | Ask:%.5f | SL:%.5f | TP:%.5f",
                         lots, ask, sl, tp));                               // Log trade
      g_in_trade = true;                                                    // Mark as in trade
     }
  }

//+------------------------------------------------------------------+
//| Opens a Stage 4 short trade on confirmed breakdown               |
//+------------------------------------------------------------------+
void OpenShort()
  {
   if(!InpTradeShorts)
      return;                                                                 // Shorts disabled
   if(!IsValidBreakout())
     {
      Print("Weinstein: Stage 4 breakdown — volume insufficient. Skipping."); // Log skip
      return;                                                                 // Volume not confirmed
     }
   if(!RSIConfirmsBreakout(false))
     {
      Print("Weinstein: Stage 4 breakdown — RSI not confirming. Skipping."); // Log skip
      return;                                                               // Momentum not confirmed
     }
   double atr_buf[];                                                        // ATR buffer
   ArraySetAsSeries(atr_buf, true);                                         // Set as series
   if(CopyBuffer(g_atr_handle, 0, 1, 1, atr_buf) < 1)
      return;                                                               // Copy ATR
   double atr    = atr_buf[0];                                              // ATR value
   double bid    = SymbolInfoDouble(_Symbol, SYMBOL_BID);                   // Current bid
   double sl     = bid + atr * InpATRMult;                                  // Stop above recent ATR
   double sl_pip = (sl - bid) / PipSize();                                  // Stop in pips
   double tp     = bid - sl_pip * InpRR * PipSize();                        // Take profit at RR
   double lots   = CalcLots(sl_pip);                                        // Calculate lot size
   if(lots <= 0)
      return;                                                               // Invalid lot size
   long   stop_lv  = SymbolInfoInteger(_Symbol, SYMBOL_TRADE_STOPS_LEVEL);  // Broker stop level
   double min_dist = stop_lv * _Point;                                      // Minimum distance
   if(sl - bid < min_dist)
      sl = bid + min_dist + _Point;                                         // Adjust SL if needed
   if(bid - tp < min_dist)
      tp = bid - min_dist - _Point;                                         // Adjust TP if needed
   CTrade trade;                                                            // Trade object
   trade.SetExpertMagicNumber(InpMagicNumber);                              // Set magic number
   trade.SetDeviationInPoints(InpSlippage);                                 // Set slippage
   if(trade.Sell(lots, _Symbol, bid, sl, tp, "Weinstein Stage 4 Short"))    // Open short
     {
      datetime t1 = iTime(_Symbol, PERIOD_CURRENT, 1);                      // Get bar time
      DrawLabel("S4ENTRY", t1, iHigh(_Symbol, PERIOD_CURRENT, 1) + PipSize() * 5,
                "STAGE 4", clrCrimson);                                     // Draw label
      Print(StringFormat("Weinstein: SHORT opened | Lots:%.2f | Bid:%.5f | SL:%.5f | TP:%.5f",
                         lots, bid, sl, tp));                               // Log trade
      g_in_trade = true;                                                    // Mark as in trade
     }
  }
//+------------------------------------------------------------------+
//| Checks exit conditions for open positions                        |
//+------------------------------------------------------------------+
void CheckExit()
  {
   for(int i = PositionsTotal() - 1; i >= 0; i--)                           // Iterate positions
     {
      ulong ticket = PositionGetTicket(i);                                  // Get ticket
      if(!PositionSelectByTicket(ticket))
         continue;                                                          // Select position
      if(PositionGetString(POSITION_SYMBOL)  != _Symbol)
         continue;                                                          // Check symbol
      if(PositionGetInteger(POSITION_MAGIC)  != InpMagicNumber)
         continue;                                                          // Check magic
      long pos_type = PositionGetInteger(POSITION_TYPE);                    // Get position type
      double ma_buf[];                                                      // MA buffer
      ArraySetAsSeries(ma_buf, true);                                       // Set as series
      if(CopyBuffer(g_ma_handle, 0, 1, 1, ma_buf) < 1)
         continue;                                                          // Copy MA
      double ma_now  = ma_buf[0];                                           // Current MA
      double close1  = iClose(_Symbol, PERIOD_CURRENT, 1);                  // Last close
      long   vol_buf[];                                                     // Volume buffer
      ArraySetAsSeries(vol_buf, true);                                      // Set as series
      bool vol_ok = false;                                                  // Volume flag
      if(CopyTickVolume(_Symbol, PERIOD_CURRENT, 1, InpVolAvgPeriod + 1, vol_buf) >= InpVolAvgPeriod + 1)
        {
         double avg_vol = 0;                                                // Average accumulator
         for(int j = 1; j <= InpVolAvgPeriod; j++)
            avg_vol += (double)vol_buf[j];                                  // Sum volumes
         avg_vol /= InpVolAvgPeriod;                                        // Compute average
         vol_ok = ((double)vol_buf[0] > avg_vol * InpExitVolMult);          // Volume check
        }
      bool exit_long  = (pos_type == POSITION_TYPE_BUY  && close1 < ma_now && vol_ok); // Long exit signal
      bool exit_short = (pos_type == POSITION_TYPE_SELL && close1 > ma_now && vol_ok); // Short exit signal
      if(exit_long || exit_short)                                           // Exit condition met
        {
         CTrade trade;                                                      // Trade object
         trade.SetExpertMagicNumber(InpMagicNumber);                        // Set magic
         trade.SetDeviationInPoints(InpSlippage);                           // Set slippage
         if(trade.PositionClose(ticket))                                    // Close position
           {
            string dir = (pos_type == POSITION_TYPE_BUY) ? "LONG" : "SHORT"; // Direction label
            Print(StringFormat("Weinstein: %s closed — MA breach on volume. Ticket:%I64u",
                               dir, ticket));                               // Log exit
            g_in_trade = false;                                             // Update flag
           }
        }
     }
  }
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
   g_ma_handle  = iMA(_Symbol, PERIOD_CURRENT, InpMAPeriod, 0, MODE_SMA, PRICE_CLOSE); // Create MA handle
   g_atr_handle = iATR(_Symbol, PERIOD_CURRENT, InpATRPeriod);              // Create ATR handle
   g_rsi_handle = iRSI(_Symbol, PERIOD_CURRENT, InpRSIPeriod, PRICE_CLOSE); // Create RSI handle
   if(g_ma_handle  == INVALID_HANDLE ||                                     // Check MA handle
      g_atr_handle == INVALID_HANDLE ||                                     // Check ATR handle
      g_rsi_handle == INVALID_HANDLE)                                       // Check RSI handle
     {
      Print("WeinsteinStageEA: Indicator handle creation failed.");         // Log error
      return INIT_FAILED;                                                   // Return failure
     }
   g_trade.SetExpertMagicNumber(InpMagicNumber);                            // Set magic number
   g_trade.SetDeviationInPoints(InpSlippage);                               // Set slippage
   g_prev_stage = STAGE_UNKNOWN;                                            // Initialize prev stage
   g_in_trade   = false;                                                    // No initial position
   g_last_bar   = 0;                                                        // Initialize bar time
   Print("WeinsteinStageEA initialized | Symbol:", _Symbol,
         " | TF:", EnumToString(Period()),
         " | MA Period:", InpMAPeriod);                                     // Log initialization
   return INIT_SUCCEEDED;                                                   // Return success
  }

//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   IndicatorRelease(g_ma_handle);                                           // Release MA handle
   IndicatorRelease(g_atr_handle);                                          // Release ATR handle
   IndicatorRelease(g_rsi_handle);                                          // Release RSI handle
   ClearLabels();                                                           // Remove chart objects
  }

//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
   datetime current_bar = iTime(_Symbol, PERIOD_CURRENT, 0);               // Current bar open time
   if(current_bar == g_last_bar)
      return;                                                              // Skip if same bar
   g_last_bar = current_bar;                                               // Update last bar time
//--- Check exit conditions for any open position
   CheckExit();                                                            // Check exit signals
//--- Classify current stage
   ENUM_MARKET_STAGE current_stage = ClassifyStage();                      // Get current stage
   if(current_stage == STAGE_UNKNOWN)                                      // Cannot classify
     {
      g_prev_stage = STAGE_UNKNOWN;                                        // Reset previous stage
      return;                                                              // Exit tick
     }
//--- Log stage if changed
   if(current_stage != g_prev_stage)                                       // Stage changed
     {
      string stage_names[] = {"Unknown", "Stage 1 Base", "Stage 2 Advance", "Stage 3 Top", "Stage 4 Decline"}; // Stage names
      Print(StringFormat("Weinstein: Stage transition: %s", stage_names[current_stage])); // Log transition
      datetime t1 = iTime(_Symbol, PERIOD_CURRENT, 1);                      // Get bar time
      color stage_colors[] = {clrGray, clrYellow, clrDodgerBlue, clrOrange, clrCrimson}; // Stage colors
      DrawLabel("STAGE" + IntegerToString((int)current_stage),
                t1, iHigh(_Symbol, PERIOD_CURRENT, 1) + PipSize() * 8,
                stage_names[current_stage], stage_colors[current_stage]);    // Draw label
     }
//--- Enter on stage transition only — not on every bar within a stage
   if(!g_in_trade)                                                           // Only if no open trade
     {
      if(current_stage == STAGE_2_ADVANCE && g_prev_stage == STAGE_1_BASE)   // Stage 1 -> 2 transition
         OpenLong();                                                         // Enter long
      else
         if(current_stage == STAGE_4_DECLINE && g_prev_stage == STAGE_3_TOP) // Stage 3 -> 4 transition
            OpenShort();                                                     // Enter short
     }
   g_prev_stage = current_stage;                                             // Update previous stage
  }
//+------------------------------------------------------------------+
