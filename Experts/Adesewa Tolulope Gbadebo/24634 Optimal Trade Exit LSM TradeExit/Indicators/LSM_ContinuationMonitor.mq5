//+------------------------------------------------------------------+
//| LSM_ContinuationMonitor.mq5                                      |
//+------------------------------------------------------------------+
#property copyright "Adesewa"
#property link      "https://www.mql5.com"
#property version   "1.00"
#property description "Plots exercise vs. LSM continuation value for the open position"
#property indicator_separate_window
#property indicator_buffers 2
#property indicator_plots   2
#property indicator_label1  "Exercise value"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrDodgerBlue
#property indicator_width1  2
#property indicator_label2  "LSM continuation value"
#property indicator_type2   DRAW_LINE
#property indicator_color2  clrOrangeRed
#property indicator_width2  2
#include "..\..\Include\LSMTradeExit\LSMEngine.mqh"   // LSM continuation-value engine

//+------------------------------------------------------------------+
//| Purpose                                                          |
//| Visual companion to LSM_TradeExit_EA.mq5. Every closed bar, if a |
//|   position with the matching magic number is open, this indicator|
//|   re-runs the same EvaluateExit() call the EA itself would make  |
//|   and plots the two resulting values side by side. When the      |
//|   exercise line crosses above the continuation line, that is the |
//|   exact bar on which the EA would have closed the trade - the    |
//|   crossover is visible on the chart rather than only in the CSV  |
//|   log.                                                           |
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//| Inputs - must mirror the EA's LSM configuration                  |
//+------------------------------------------------------------------+
input int InpLSMPaths       = 500;      // Monte Carlo path count
input int InpLSMHorizonBars = 24;       // Forced-liquidation horizon ceiling (bars)
input double InpRidgeLambda = 0.000001; // Ridge penalty for OLS fit
input double InpAnnualRate  = 0.0;      // Nominal annual discount rate
input int InpCalibLookback  = 300;      // Bars used to calibrate drift/vol
input double InpCostPoints  = 35.0;     // Round-trip cost estimate, in points
input int InpMaxHoldingBars = 96;       // Must mirror the EA's hard holding backstop
input int InpMagicNumber    = 20260904; // Magic number of the position to monitor

//+------------------------------------------------------------------+
//| Globals                                                          |
//+------------------------------------------------------------------+
double         g_exercise_buf[];   // plot buffer 0: exercise value
double         g_continue_buf[];   // plot buffer 1: continuation value
CLSMExitEngine g_engine;           // LSM continuation-value engine, mirrors the EA's

//+------------------------------------------------------------------+
//| OnInit                                                           |
//| Binds the two plot buffers and configures the LSM engine with the|
//| same parameters as the EA so the plotted values are directly     |
//| comparable to what actually drove any historical exit.           |
//+------------------------------------------------------------------+
int OnInit(void)
  {
   SetIndexBuffer(0, g_exercise_buf, INDICATOR_DATA);
   SetIndexBuffer(1, g_continue_buf, INDICATOR_DATA);
   ArraySetAsSeries(g_exercise_buf, true);
   ArraySetAsSeries(g_continue_buf, true);
   PlotIndexSetDouble(0, PLOT_EMPTY_VALUE, EMPTY_VALUE);
   PlotIndexSetDouble(1, PLOT_EMPTY_VALUE, EMPTY_VALUE);

   int bar_seconds = PeriodSeconds(_Period);
   g_engine.Configure(InpLSMPaths, InpLSMHorizonBars, InpRidgeLambda,
                       InpAnnualRate, bar_seconds);

   return(INIT_SUCCEEDED);
  }

//+------------------------------------------------------------------+
//| OnCalculate                                                      |
//| Only ever recomputes the most recently closed bar (index 1 in    |
//|   series terms) rather than the whole visible history on every   |
//|   tick: each LSM pass is a full Monte Carlo simulation plus a    |
//|   backward induction, so re-running it for every historical bar  |
//|   on every tick would make the chart unusable. Bars in the       |
//|   middle of history are left as EMPTY_VALUE, matching how the    |
//|   article frames this as a live monitoring tool rather than a    |
//|   backtesting overlay.                                           |
//+------------------------------------------------------------------+
int OnCalculate(const int        rates_total,
                 const int        prev_calculated,
                 const datetime  &time[],
                 const double    &open[],
                 const double    &high[],
                 const double    &low[],
                 const double    &close[],
                 const long      &tick_volume[],
                 const long      &volume[],
                 const int       &spread[])
  {
   if(rates_total < 2)
      return(0);

//--- recalibrate once per call rather than caching across calls;
//--- this indicator only recomputes on new closed bars anyway (see
//--- the static guard below), so the extra CalibrateFromHistory
//--- cost is paid at most once per bar
   g_engine.CalibrateFromHistory(_Symbol, _Period, InpCalibLookback);

   static datetime last_processed = 0;
   datetime this_bar_time = time[rates_total - 1];
   if(this_bar_time == last_processed)
      return(rates_total);
   last_processed = this_bar_time;

   int idx = 0;                     //--- series-indexed: 0 = current bar
   g_exercise_buf[idx] = EMPTY_VALUE;
   g_continue_buf[idx] = EMPTY_VALUE;

   if(!PositionSelect(_Symbol))
      return(rates_total);
   if(PositionGetInteger(POSITION_MAGIC) != InpMagicNumber)
      return(rates_total);

   long   pos_type      = PositionGetInteger(POSITION_TYPE);
   double entry_price   = PositionGetDouble(POSITION_PRICE_OPEN);
   datetime open_time   = (datetime)PositionGetInteger(POSITION_TIME);
   double point         = SymbolInfoDouble(_Symbol, SYMBOL_POINT);
   double bid           = SymbolInfoDouble(_Symbol, SYMBOL_BID);
   double ask           = SymbolInfoDouble(_Symbol, SYMBOL_ASK);
   double current_price = (pos_type == POSITION_TYPE_BUY) ? bid : ask;
   double cost_points   = InpCostPoints * point;

//--- mirror the EA's own bars_remaining computation exactly, so the
//--- plotted continuation value matches what the EA itself would
//--- have used for the same position at the same bar
   int bars_held      = iBarShift(_Symbol, _Period, open_time, false);
   int bars_remaining = MathMax(1, InpMaxHoldingBars - bars_held);

   double exercise_value, continue_value;
   g_engine.EvaluateExit(current_price, entry_price, pos_type, cost_points,
                          bars_remaining, exercise_value, continue_value);

   g_exercise_buf[idx] = exercise_value;
   g_continue_buf[idx] = continue_value;

   return(rates_total);
  }
//+------------------------------------------------------------------+
//| End of file                                                      |
//+------------------------------------------------------------------+
