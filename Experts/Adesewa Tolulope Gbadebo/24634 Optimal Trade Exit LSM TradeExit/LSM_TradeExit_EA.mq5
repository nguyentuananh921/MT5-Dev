//+------------------------------------------------------------------+
//| LSM_TradeExit_EA.mq5                                             |
//+------------------------------------------------------------------+
#property copyright "Adesewa"
#property link      "https://www.mql5.com"
#property version   "1.00"
#property description "Longstaff-Schwartz LSM continuation-value exit engine"

//+------------------------------------------------------------------+
//| Includes                                                         |
//+------------------------------------------------------------------+
#include <Trade\Trade.mqh>                            // CTrade wrapper for order execution
#include "..\..\Include\LSMTradeExit\LSMEngine.mqh"   // LSM continuation-value engine

//+------------------------------------------------------------------+
//| Inputs - entry signal (MA cross, native recompute)               |
//+------------------------------------------------------------------+
 input int InpFastMAPeriod        = 12;       // Fast MA period
 input int InpSlowMAPeriod        = 48;       // Slow MA period
 input ENUM_MA_METHOD InpMAMethod = MODE_EMA; // MA smoothing method

//+------------------------------------------------------------------+
//| Inputs - LSM exit engine                                         |
//+------------------------------------------------------------------+
 input int InpLSMPaths       = 500;      // Monte Carlo path count
 input int InpLSMHorizonBars = 24;       // Forced-liquidation horizon (bars)
 input double InpRidgeLambda = 0.000001; // Ridge penalty for OLS fit
 input double InpAnnualRate  = 0.0;      // Nominal annual discount rate
 input int InpCalibLookback  = 300;      // Bars used to calibrate drift/vol
 input int InpRecalibEveryN  = 12;       // Recalibrate drift/vol every N bars
 input double InpCostPoints  = 35.0;     // Round-trip cost estimate, in points

//+------------------------------------------------------------------+
//| Inputs - trade management                                        |
//+------------------------------------------------------------------+
 input double InpLotSize       = 0.10;     // Fixed lot size
 input int InpMaxHoldingBars   = 96;       // Hard backstop: force-close after N bars
 input double InpBackstopSLPts = 600.0;    // Backstop stop-loss, in points
 input int InpMagicNumber      = 20260904; // EA magic number
 input bool InpEnableCsvLog    = true;     // Write per-decision diagnostics to CSV

//+------------------------------------------------------------------+
//| Globals                                                          |
//+------------------------------------------------------------------+
 CTrade         g_trade;              // order execution wrapper
 CLSMExitEngine g_engine;             // LSM continuation-value engine
 int            g_bars_since_calib;   // bars elapsed since last recalibration
 int            g_fast_ma_handle;     // fast MA indicator handle
 int            g_slow_ma_handle;     // slow MA indicator handle
 int            g_csv_handle;         // CSV diagnostics log file handle

//+------------------------------------------------------------------+
//| OnInit                                                           |
//| Creates the two native MA handles used purely for entry signal   |
//| generation (never fed into the exit logic, so the exit decision  |
//| can never inherit entry-indicator lag or repainting behaviour),  |
//| configures the LSM engine with its Monte Carlo and regression    |
//| settings, and opens the CSV diagnostics log if enabled.          |
//+------------------------------------------------------------------+
int OnInit(void)
  {
//--- entry-signal handles; kept separate from any exit computation
   g_fast_ma_handle = iMA(_Symbol, _Period, InpFastMAPeriod, 0, InpMAMethod, PRICE_CLOSE);
   g_slow_ma_handle = iMA(_Symbol, _Period, InpSlowMAPeriod, 0, InpMAMethod, PRICE_CLOSE);
   if(g_fast_ma_handle == INVALID_HANDLE || g_slow_ma_handle == INVALID_HANDLE)
     {
      Print("OnInit: failed to create MA handles, error ", GetLastError());
      return(INIT_FAILED);
     }

   g_trade.SetExpertMagicNumber(InpMagicNumber);

//--- bar_seconds derives the LSM engine's per-bar discount factor
//--- from the chart's own timeframe rather than a hardcoded value,
//--- so switching timeframes does not silently mis-scale the
//--- discount applied inside EvaluateExit()
   int bar_seconds = PeriodSeconds(_Period);
   g_engine.Configure(InpLSMPaths, InpLSMHorizonBars, InpRidgeLambda,
                       InpAnnualRate, bar_seconds);

//--- calibrate immediately on load rather than waiting for the
//--- first InpRecalibEveryN bars to elapse, so the very first exit
//--- check already has a real drift/vol estimate instead of the
//--- engine's zeroed constructor defaults
   g_engine.CalibrateFromHistory(_Symbol, _Period, InpCalibLookback);
   g_bars_since_calib = 0;

   if(InpEnableCsvLog)
     {
      //--- FILE_COMMON writes to the shared MetaQuotes\Terminal\Common\Files
      //--- folder rather than this terminal's own MQL5\Files, so the
      //--- log survives terminal reinstalls and is readable by any
      //--- offline Python diagnostic script pointed at the common path;
      //--- FILE_CSV output from MQL5 is UTF-16 by default (no FILE_ANSI
      //--- flag here), so the companion Python reader must open this
      //--- file with encoding="utf-16" rather than the platform default
      //--- - a plain open(path) misreads it as garbled ASCII
      string filename = "LSMTradeExit\\LSMTradeExit_ExitLog.csv";
      g_csv_handle = FileOpen(filename, FILE_WRITE | FILE_CSV | FILE_COMMON, ',');
      if(g_csv_handle != INVALID_HANDLE)
         FileWrite(g_csv_handle, "time", "ticket", "exercise_value",
                   "continue_value", "decision", "price");
     }

   return(INIT_SUCCEEDED);
  }

//+------------------------------------------------------------------+
//| OnDeinit                                                         |
//| Releases indicator handles and closes the CSV log so the file    |
//| handle is not left open across EA reloads or terminal shutdown.  |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   IndicatorRelease(g_fast_ma_handle);
   IndicatorRelease(g_slow_ma_handle);
   if(g_csv_handle != INVALID_HANDLE)
      FileClose(g_csv_handle);
  }

//+------------------------------------------------------------------+
//| GetEntrySignal                                                   |
//| Reads the two MA buffers on the two most recently closed bars and|
//|   returns +1 for a fresh bullish cross, -1 for a fresh bearish   |
//|   cross, 0 otherwise. Recomputed from scratch on every call via  |
//|   CopyBuffer - no cached state - so the signal can never drift   |
//|   out of sync with the chart's own indicator values.             |
//+------------------------------------------------------------------+
int GetEntrySignal(void)
  {
   double fast[], slow[];
   ArraySetAsSeries(fast, true);
   ArraySetAsSeries(slow, true);

   if(CopyBuffer(g_fast_ma_handle, 0, 0, 3, fast) < 3)
      return(0);
   if(CopyBuffer(g_slow_ma_handle, 0, 0, 3, slow) < 3)
      return(0);

//--- compare the two most recently CLOSED bars (index 1 vs 2),
//--- never the still-forming bar at index 0, to avoid acting on a
//--- cross that can still repaint before the bar closes
   bool was_below = fast[2] <= slow[2];
   bool now_above = fast[1] >  slow[1];
   bool was_above = fast[2] >= slow[2];
   bool now_below = fast[1] <  slow[1];

   if(was_below && now_above)
      return(1);
   if(was_above && now_below)
      return(-1);
   return(0);
  }

//+------------------------------------------------------------------+
//| HasOpenPosition                                                  |
//| Returns true and fills pos_type/entry_price/open_time when this  |
//| EA's magic number has an open position on the current symbol.    |
//+------------------------------------------------------------------+
bool HasOpenPosition(long &pos_type, double &entry_price, datetime &open_time)
  {
   if(!PositionSelect(_Symbol))
      return(false);
   if(PositionGetInteger(POSITION_MAGIC) != InpMagicNumber)
      return(false);

   pos_type    = PositionGetInteger(POSITION_TYPE);
   entry_price = PositionGetDouble(POSITION_PRICE_OPEN);
   open_time   = (datetime)PositionGetInteger(POSITION_TIME);
   return(true);
  }

//+------------------------------------------------------------------+
//| CheckLSMExit                                                     |
//| Runs the LSM engine against the currently open position and      |
//|   closes it if immediate exercise beats the estimated            |
//|   continuation value. The simulation horizon passed to the engine|
//|   shrinks as the position ages toward InpMaxHoldingBars, so the  |
//|   continuation-value estimate genuinely decays as the hard       |
//|   deadline approaches rather than always reflecting a fresh full-|
//|   length window. Also enforces two hard backstops that never     |
//|   depend on the LSM engine succeeding: a maximum holding period  |
//|   and a fixed stop-loss distance, so a degenerate or slow-to-    |
//|   converge regression can never leave the account exposed        |
//|   indefinitely.                                                  |
//+------------------------------------------------------------------+
void CheckLSMExit(void)
  {
   long     pos_type;
   double   entry_price;
   datetime open_time;
   if(!HasOpenPosition(pos_type, entry_price, open_time))
      return;

//--- backstop 1: hard time-based liquidation, independent of LSM
   int bars_held = iBarShift(_Symbol, _Period, open_time, false);
   if(bars_held >= InpMaxHoldingBars)
     {
      g_trade.PositionClose(_Symbol);
      LogDecision(entry_price, entry_price, 0.0, "BACKSTOP_TIME");
      return;
     }

//--- backstop 2: hard price-based stop, independent of LSM
   double bid = SymbolInfoDouble(_Symbol, SYMBOL_BID);
   double ask = SymbolInfoDouble(_Symbol, SYMBOL_ASK);
   double point = SymbolInfoDouble(_Symbol, SYMBOL_POINT);
   double current_price = (pos_type == POSITION_TYPE_BUY) ? bid : ask;

   double adverse_move = (pos_type == POSITION_TYPE_BUY)
                          ? (entry_price - current_price)
                          : (current_price - entry_price);
   if(adverse_move >= InpBackstopSLPts * point)
     {
      g_trade.PositionClose(_Symbol);
      LogDecision(current_price, current_price, 0.0, "BACKSTOP_SL");
      return;
     }

//--- periodic recalibration: re-estimating drift/vol on every tick
//--- would be wasteful and would make consecutive decisions noisier
//--- rather than more accurate, since the underlying regime does
//--- not meaningfully change tick-to-tick
//--- gate the counter on an actual new closed bar - without this,
//--- g_bars_since_calib counts calls to CheckLSMExit(), which runs
//--- every tick, not every bar, and InpRecalibEveryN would silently
//--- mean "every N ticks" instead of "every N bars"
   static datetime s_last_calib_bar_time = 0;
   datetime current_bar_time = iTime(_Symbol, _Period, 0);
   if(current_bar_time != s_last_calib_bar_time)
     {
      s_last_calib_bar_time = current_bar_time;
      g_bars_since_calib++;
      if(g_bars_since_calib >= InpRecalibEveryN)
        {
         g_engine.CalibrateFromHistory(_Symbol, _Period, InpCalibLookback);
         g_bars_since_calib = 0;
        }
     }

   double cost_points = InpCostPoints * point;
   int bars_remaining = InpMaxHoldingBars - bars_held;   //--- guaranteed > 0
                                                          //--- here: backstop 1
                                                          //--- above already
                                                          //--- returned if
                                                          //--- bars_held reached
                                                          //--- InpMaxHoldingBars
   double exercise_value, continue_value;
   bool should_exit = g_engine.EvaluateExit(current_price, entry_price, pos_type,
                                            cost_points, bars_remaining,
                                            exercise_value, continue_value);

   LogDecision(exercise_value, continue_value, current_price,
               should_exit ? "LSM_EXIT" : "LSM_HOLD");

   if(should_exit)
      g_trade.PositionClose(_Symbol);
  }

//+------------------------------------------------------------------+
//| LogDecision                                                      |
//| Appends one diagnostic row to the CSV log if logging is enabled. |
//|   Kept as a single narrow function so every call site in         |
//|   CheckLSMExit writes the same column layout - drift between call|
//|   sites is a common source of an unparseable diagnostics file.   |
//+------------------------------------------------------------------+
void LogDecision(const double exercise_value,
                  const double continue_value,
                  const double price,
                  const string decision)
  {
   if(!InpEnableCsvLog || g_csv_handle == INVALID_HANDLE)
      return;

   ulong ticket = PositionSelect(_Symbol) ? PositionGetInteger(POSITION_TICKET) : 0;
   FileWrite(g_csv_handle, TimeToString(TimeCurrent(), TIME_DATE | TIME_SECONDS),
             ticket, DoubleToString(exercise_value, 5),
             DoubleToString(continue_value, 5), decision,
             DoubleToString(price, 5));
   FileFlush(g_csv_handle);
  }

//+------------------------------------------------------------------+
//| OnTick                                                           |
//| Entry point: manages the exit of any open position first (this is|
//|   the article's subject and takes priority every tick), then     |
//|   looks for a fresh entry signal only when flat. Signal detection|
//|   is throttled to once per closed bar via a static last-bar      |
//|   guard, since an MA cross is a bar-close event and re-checking  |
//|   it intra-bar would only add noise.                             |
//+------------------------------------------------------------------+
void OnTick(void)
  {
   CheckLSMExit();

   long     pos_type;
   double   entry_price;
   datetime open_time;
   if(HasOpenPosition(pos_type, entry_price, open_time))
      return;                       //--- stay flat-checking logic below
                                     //--- skipped while a position is open

   static datetime last_bar_time = 0;
   datetime current_bar_time = iTime(_Symbol, _Period, 0);
   if(current_bar_time == last_bar_time)
      return;
   last_bar_time = current_bar_time;

   int signal = GetEntrySignal();
   if(signal == 0)
      return;

   double ask = SymbolInfoDouble(_Symbol, SYMBOL_ASK);
   double bid = SymbolInfoDouble(_Symbol, SYMBOL_BID);

   if(signal > 0)
      g_trade.Buy(InpLotSize, _Symbol, ask, 0.0, 0.0, "LSM_TradeExit entry");
   else
      g_trade.Sell(InpLotSize, _Symbol, bid, 0.0, 0.0, "LSM_TradeExit entry");
  }
//+------------------------------------------------------------------+
//| End of file                                                      |
//+------------------------------------------------------------------+
