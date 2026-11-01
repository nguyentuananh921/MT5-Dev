//+------------------------------------------------------------------+
//| LSMEngine.mqh                                                    |
//+------------------------------------------------------------------+
#property copyright "Adesewa"
#property link      "https://www.mql5.com"
#include "MatrixSolver.mqh"

//+------------------------------------------------------------------+
//| Purpose                                                          |
//| Implements the Longstaff-Schwartz Least-Squares Monte Carlo (LSM)|
//|   algorithm, repurposed from American-option pricing to a live-  |
//|   trade exit decision. A live position is treated exactly like an|
//|   American                                                       |
//| option: at every instant the holder chooses between "exercise"   |
//|   (close the trade, bank the current unrealized payoff) and      |
//|   "continue" (hold, keep optionality on a better exit later). LSM|
//|   estimates the continuation value by simulating forward price   |
//|   paths, then regressing realized future payoffs on a small basis|
//|   of state variables at each backward step - this is what        |
//|   separates it from a naive "simulate and average" approach: the |
//|   regression lets the stopping decision depend on the *current*  |
//|   state of each simulated path, not just on time.                |
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//| CLSMExitEngine                                                   |
//| Encapsulates calibration, path simulation, and the backward      |
//| induction that produces an exercise/continue decision for a live |
//| position. One instance is reused across ticks; Configure() and   |
//| CalibrateFromHistory() are cheap to re-run periodically so the   |
//| engine tracks changing volatility regimes.                       |
//+------------------------------------------------------------------+
class CLSMExitEngine
  {
   private:
    int      m_paths;             // number of simulated Monte Carlo paths
    int      m_horizon_bars;      // configured ceiling on simulation horizon
    double   m_ridge_lambda;      // ridge penalty passed to SolveOLS
    double   m_drift_per_bar;     // calibrated mean log-return per bar
    double   m_sigma_per_bar;     // calibrated log-return stdev per bar
    double   m_discount_per_bar;  // per-bar discount factor (<= 1.0)
    bool     m_has_spare_normal;  // Box-Muller cache flag
    double   m_spare_normal;      // Box-Muller cached second draw

   //+------------------------------------------------------------------+
   //| NextUniform01                                                    |
   //| MQL5 has no built-in MathRandom() - its native generator is      |
   //| MathRand(), which returns a pseudo-random INTEGER in [0, 32767], |
   //| not a double in [0, 1). This wrapper is the single place that    |
   //| converts one into the other, dividing by 32768.0 (one past the   |
   //| maximum) rather than 32767.0 so the result is a proper half-open |
   //| [0, 1) interval and can never round up to exactly 1.0.           |
   //+------------------------------------------------------------------+
    double NextUniform01(void) { return((double)MathRand() / 32768.0); }

   //+------------------------------------------------------------------+
   //| NextStandardNormal                                               |
   //| Box-Muller transform converts two independent uniform(0,1) draws |
   //| into two independent standard-normal draws. Generating them in   |
   //| pairs and caching the second halves the number of NextUniform01()|
   //| and MathLog()/MathSqrt() calls compared to drawing one at a time,|
   //| which matters because a single exit decision calls this          |
   //| thousands of times (m_paths * m_horizon_bars draws per decision).|
   //+------------------------------------------------------------------+
   double NextStandardNormal(void)
     {
      if(m_has_spare_normal)
        {
         m_has_spare_normal = false;
         return(m_spare_normal);
        }

   //--- clamp away from exactly 0.0 to avoid MathLog(0) = -inf
      double u1 = MathMax(NextUniform01(), 1.0e-12);
      double u2 = NextUniform01();
      double r  = MathSqrt(-2.0 * MathLog(u1));
      double z0 = r * MathCos(2.0 * M_PI * u2);
      double z1 = r * MathSin(2.0 * M_PI * u2);

      m_spare_normal     = z1;
      m_has_spare_normal = true;
      return(z0);
     }

   //+------------------------------------------------------------------+
   //| ExercisePayoff                                                   |
   //| Payoff of closing the position right now at 'price', in price    |
   //| units, net of an estimated round-trip cost (spread + commission, |
   //| expressed in the same price units by the caller).                |
   //| Direction-aware: a long profits from price rising above entry,   |
   //| a short profits from price falling below entry.                  |
   //+------------------------------------------------------------------+
   double ExercisePayoff(const double price,
                          const double entry_price,
                          const long   pos_type,
                          const double cost_points) const
     {
      double raw = (pos_type == POSITION_TYPE_BUY)
                   ? (price - entry_price)
                   : (entry_price - price);
      return(raw - cost_points);
     }

   //+------------------------------------------------------------------+
   //| BuildBasisRow                                                    |
   //| Basis functions evaluated at the state of a single simulated path|
   //|   at a single time step. Six terms, matching SolveOLS's fixed    |
   //|   X[][6] layout:                                                 |
   //|                                                                  |
   //| row[0] = 1.0 - intercept                                         |
   //| row[1] = pnl_now - linear payoff term                            |
   //| row[2] = pnl_now^2 - curvature near the exercise boundary        |
   //|   (Longstaff-Schwartz's original basis uses this term for the    |
   //|   same reason: continuation value is not linear in moneyness)    |
   //| row[3] = time_frac - fraction of horizon elapsed; continuation   |
   //|   value decays as the forced-liquidation deadline nears          |
   //| row[4] = peak_pnl - best unrealized payoff seen so far on this   |
   //|   path; approximates a trailing/drawdown-from-peak effect without|
   //|   a full path-dependent state                                    |
   //| row[5] = pnl_now * time_frac - interaction term: how much the    |
   //|   payoff/time tradeoff matters depends on both together          |
   //+------------------------------------------------------------------+
   void BuildBasisRow(const double pnl_now,
                       const double peak_pnl,
                       const double time_frac,
                       double      &row[]) const
     {
      ArrayResize(row, 6);
      row[0] = 1.0;
      row[1] = pnl_now;
      row[2] = pnl_now * pnl_now;
      row[3] = time_frac;
      row[4] = peak_pnl;
      row[5] = pnl_now * time_frac;
     }

public:
   //+------------------------------------------------------------------+
   //| CLSMExitEngine (constructor)                                     |
   //| Sets conservative, self-consistent defaults so the engine is     |
   //| still safe to call even if Configure() is skipped by mistake -   |
   //| it will simply run a small, slow-to-adapt configuration rather   |
   //| than fail outright.                                              |
   //+------------------------------------------------------------------+
   CLSMExitEngine(void)
     {
   //--- defaults, all overwritten by Configure() in normal use
      m_paths             = 500;
      m_horizon_bars      = 24;
      m_ridge_lambda      = 1.0e-6;
      m_drift_per_bar     = 0.0;
      m_sigma_per_bar     = 0.0;
      m_discount_per_bar  = 1.0;
      m_has_spare_normal  = false;
      m_spare_normal      = 0.0;
     }

   //+------------------------------------------------------------------+
   //| Configure                                                        |
   //| paths        : Monte Carlo path count (accuracy vs. CPU tradeoff)|
   //| horizon_bars : forced-liquidation horizon used as the terminal   |
   //|   boundary condition for the backward induction                  |
   //| ridge_lambda : passed straight through to SolveOLS               |
   //| annual_rate  : nominal annual discount rate used only to derive a|
   //|   per-bar discount factor; kept near-neutral by default since    |
   //|   intraday exit horizons make the time value of money negligible,|
   //|   but included so the algorithm stays faithful to the original   |
   //|   discounted-cashflow formulation                                |
   //| bar_seconds  : seconds per bar of the trading timeframe, used    |
   //|   with annual_rate to derive the per-bar discount                |
   //+------------------------------------------------------------------+
   void Configure(const int    paths,
                  const int    horizon_bars,
                  const double ridge_lambda,
                  const double annual_rate,
                  const int    bar_seconds)
     {
      m_paths        = MathMax(paths, 50);
      m_horizon_bars = MathMax(horizon_bars, 2);
      m_ridge_lambda = MathMax(ridge_lambda, 0.0);

   //--- convert an annual rate to a per-bar discount factor;
   //--- seconds_per_year uses 252 trading days to stay consistent
   //--- with how the rest of the series annualizes intraday figures
      double seconds_per_year = 252.0 * 24.0 * 60.0 * 60.0;
      double bar_fraction     = (double)bar_seconds / seconds_per_year;
      m_discount_per_bar      = MathExp(-annual_rate * bar_fraction);
     }

   //+------------------------------------------------------------------+
   //| CalibrateFromHistory                                             |
   //| Estimates per-bar drift and volatility from recent closes so the |
   //| simulated paths reflect the instrument's current regime rather   |
   //| than a fixed, stale assumption. Returns false if not enough      |
   //| history is available yet (e.g. right after a fresh terminal      |
   //| start) so the caller can defer the exit check for that tick.     |
   //+------------------------------------------------------------------+
   bool CalibrateFromHistory(const string          symbol,
                              const ENUM_TIMEFRAMES tf,
                              const int             lookback_bars)
     {
      if(lookback_bars < 10)
         return(false);

      double closes[];
      ArraySetAsSeries(closes, true);
   //--- start at index 1 (not 0) so the still-forming current bar is
   //--- never folded into the calibration window - the same principle
   //--- ExportPriceHistory.mq5 applies to its own export
      int copied = CopyClose(symbol, tf, 1, lookback_bars, closes);
      if(copied < 10)
         return(false);

   //--- CopyClose fills a plain array chronologically (oldest to newest)
   //--- at the memory level - index 0 only means "most recent bar" once
   //--- ArraySetAsSeries(closes, true) is called BEFORE the copy, as
   //--- above. Skipping that call is the actual trap: the array still
   //--- compiles and returns data, just indexed the opposite way, which
   //--- silently flips the sign of every log-return computed from it -
   //--- log(closes[i] / closes[i+1]) is only the correct forward return
   //--- (older bar i+1 to newer bar i) because the array is explicitly
   //--- series-indexed here, not because of anything CopyClose does on
   //--- its own.
      int    n = copied - 1;
      double sum = 0.0;
      double returns[];
      ArrayResize(returns, n);
      for(int i = 0; i < n; i++)
        {
         returns[i] = MathLog(closes[i] / closes[i + 1]);
         sum       += returns[i];
        }
      double mean = sum / n;

      double sq_sum = 0.0;
      for(int i = 0; i < n; i++)
         sq_sum += (returns[i] - mean) * (returns[i] - mean);

   //--- sample variance (n-1 denominator) since this is an estimate
   //--- from a finite recent window, not the true population moment
      double variance = (n > 1) ? sq_sum / (n - 1) : 0.0;

      m_drift_per_bar = mean;
      m_sigma_per_bar = MathSqrt(MathMax(variance, 0.0));
      return(true);
     }

   //+------------------------------------------------------------------+
   //| EvaluateExit                                                     |
   //| Runs one full LSM pass conditioned on the position's current     |
   //|   state and returns true if immediate exercise (closing the trade|
   //|   now) beats the estimated continuation value.                   |
   //| current_price : latest tradeable price for this position's       |
   //|   closing direction (bid for a long, ask for a short - the caller|
   //|   is responsible for passing the correct side)                   |
   //| entry_price : the position's open price                          |
   //| pos_type : POSITION_TYPE_BUY or POSITION_TYPE_SELL               |
   //| cost_points : estimated round-trip cost in price units           |
   //|                                                                  |
   //| bars_remaining : bars left until the caller's own hard time-based|
   //|   backstop forces liquidation (e.g. InpMaxHoldingBars -          |
   //|   bars_held). The simulation horizon is clamped to this value    |
   //|   (never above the configured ceiling, m_horizon_bars, and never |
   //|   above bars_remaining itself, with no floor that could push it  |
   //|   back above the real deadline) so the continuation value        |
   //|   genuinely decays as the real deadline approaches, instead of   |
   //|   every call re-simulating a fresh full-length window regardless |
   //|   of how long the trade has already been open - a full ceiling-  |
   //|   length re-simulation every call is what silently made the LSM  |
   //|   comparison almost never win against the backstops in practice, |
   //|   since the continuation estimate never lost the "fresh          |
   //|   optionality" a full horizon implies                            |
   //| out_exercise_value : receives h(0), the current exercise payoff  |
   //| out_continue_value : receives the estimated continuation value   |
   //| Returns true when out_exercise_value >= out_continue_value.      |
   //+------------------------------------------------------------------+
   bool EvaluateExit(const double current_price,
                      const double entry_price,
                      const long   pos_type,
                      const double cost_points,
                      const int    bars_remaining,
                      double      &out_exercise_value,
                      double      &out_continue_value)
     {
   //--- shrink the simulated horizon toward the real deadline as
   //--- the position ages; H is never above bars_remaining, full
   //--- stop, with no floor that could push it back above the real
   //--- deadline - a very small bars_remaining near the deadline
   //--- still simulates safely without one
      int H = MathMin(m_horizon_bars, bars_remaining);
      int M = m_paths;

   //--- simulate M forward price paths of length H+1 (index 0 is
   //--- "now"); a plain array indexed [path * (H+1) + step] is used
   //--- instead of a native MQL5 matrix so the memory layout is
   //--- explicit and the loop below stays simple to reason about
      double prices[];
      ArrayResize(prices, M * (H + 1));

      double drift_term = m_drift_per_bar - 0.5 * m_sigma_per_bar * m_sigma_per_bar;
      for(int p = 0; p < M; p++)
        {
         prices[p * (H + 1)] = current_price;
         for(int t = 1; t <= H; t++)
           {
            double z = NextStandardNormal();
            double prev = prices[p * (H + 1) + t - 1];
            //--- geometric Brownian motion step; using log-returns
            //--- guarantees simulated prices stay strictly positive,
            //--- which a naive additive random walk does not
            prices[p * (H + 1) + t] = prev * MathExp(drift_term + m_sigma_per_bar * z);
           }
        }

   //--- pre-compute payoff and running-peak-payoff at every step of
   //--- every path once, rather than recomputing them inside the
   //--- backward loop, since both are needed repeatedly below
      double pnl[];
      double peak[];
      ArrayResize(pnl, M * (H + 1));
      ArrayResize(peak, M * (H + 1));
      for(int p = 0; p < M; p++)
        {
         double running_peak = -DBL_MAX;
         for(int t = 0; t <= H; t++)
           {
            double v = ExercisePayoff(prices[p * (H + 1) + t], entry_price, pos_type, cost_points);
            pnl[p * (H + 1) + t] = v;
            running_peak = MathMax(running_peak, v);
            peak[p * (H + 1) + t] = running_peak;
           }
        }

   //--- cash-flow array: initialized to the terminal, forced-exit
   //--- payoff at the horizon, then overwritten in place as the
   //--- backward induction below discovers earlier optimal stops
      double cf[];
      ArrayResize(cf, M);
      for(int p = 0; p < M; p++)
         cf[p] = pnl[p * (H + 1) + H];

   //--- backward induction from the last interior step down to 1;
   //--- step 0 ("now") is handled separately after this loop, since
   //--- it has only a single state (the actual current position),
   //--- not M simulated ones, so no regression is needed there
      for(int t = H - 1; t >= 1; t--)
        {
         //--- discount every path's cash flow back one bar before
         //--- deciding whether stopping at t beats it
         for(int p = 0; p < M; p++)
            cf[p] *= m_discount_per_bar;

         //--- restrict the regression to in-the-money paths only,
         //--- exactly as in the original Longstaff-Schwartz paper:
         //--- fitting on out-of-the-money paths wastes degrees of
         //--- freedom on states where exercise is never a real
         //--- candidate and can distort the fit near the boundary
         //--- that actually matters
         int itm_count = 0;
         for(int p = 0; p < M; p++)
            if(pnl[p * (H + 1) + t] > 0.0)
               itm_count++;

         if(itm_count < 8)
            continue;              //--- too few ITM paths - skip this
                                    //--- step's update and implicitly
                                    //--- treat it as "always continue"
                                    //--- rather than fit an unreliable
                                    //--- regression on a handful of points

         double X[][6];
         double y[];
         ArrayResize(X, itm_count);
         ArrayResize(y, itm_count);

         int    idx[];
         ArrayResize(idx, itm_count);
         int    row = 0;
         double time_frac = (double)t / (double)H;
         for(int p = 0; p < M; p++)
           {
            double v = pnl[p * (H + 1) + t];
            if(v <= 0.0)
               continue;
            double basis[];
            BuildBasisRow(v, peak[p * (H + 1) + t], time_frac, basis);
            for(int c = 0; c < 6; c++)
               X[row][c] = basis[c];
            y[row] = cf[p];
            idx[row] = p;
            row++;
           }

         double beta[];
         bool ok = SolveOLS(X, y, itm_count, 6, m_ridge_lambda, beta);
         if(!ok)
            continue;              //--- degenerate fit - same fallback
                                    //--- as the too-few-paths case above

         //--- compare fitted continuation value against immediate
         //--- exercise for each ITM path and overwrite cf[] in place
         //--- for the paths where exercising now is better
         for(int r = 0; r < itm_count; r++)
           {
            int p = idx[r];
            double basis[];
            BuildBasisRow(pnl[p * (H + 1) + t], peak[p * (H + 1) + t], time_frac, basis);
            double continuation_est = 0.0;
            for(int c = 0; c < 6; c++)
               continuation_est += basis[c] * beta[c];

            if(pnl[p * (H + 1) + t] >= continuation_est)
               cf[p] = pnl[p * (H + 1) + t];
           }
        }

   //--- bring the t=1 cash flows back to t=0 ("now") with one more
   //--- discount step, then average across paths to get the Monte
   //--- Carlo estimate of the continuation value at the current,
   //--- single, real state of the live position
      double sum_cf = 0.0;
      for(int p = 0; p < M; p++)
         sum_cf += cf[p] * m_discount_per_bar;
      out_continue_value = sum_cf / M;

      out_exercise_value = ExercisePayoff(current_price, entry_price, pos_type, cost_points);

      return(out_exercise_value >= out_continue_value);
     }
  };
//+------------------------------------------------------------------+
//| End of file                                                      |
//+------------------------------------------------------------------+
