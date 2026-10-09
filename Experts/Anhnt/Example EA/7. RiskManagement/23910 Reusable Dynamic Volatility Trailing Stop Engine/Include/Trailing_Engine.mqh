//+------------------------------------------------------------------+
//|                                              Trailing_Engine.mqh |
//|                                  Copyright 2026, MetaQuotes Ltd. |
//+------------------------------------------------------------------+
#property copyright "Open Source"
#property version   "2.10"

#include <Trade\Trade.mqh>

//--- Detailed trailing execution result status
 enum ENUM_TRAILING_STATUS
  {
   TRAILING_STATUS_NO_UPDATE = 0,       // No update needed
   TRAILING_STATUS_UPDATED,             // Successfully modified by trade server
   TRAILING_STATUS_SKIPPED_STEP,        // Change below minimum step
   TRAILING_STATUS_SKIPPED_OPEN_PRICE,  // Level not yet beyond open price (protection mode)
   TRAILING_STATUS_REJECTED_STOPSLEVEL, // Level closer than broker STOPS_LEVEL
   TRAILING_STATUS_REJECTED_FREEZELEVEL,// Active SL inside broker FREEZE_LEVEL
   TRAILING_STATUS_ERROR                // Execution or server rejection error
  };

//--- State structure to store and inspect individual evaluations
 struct TrailingState
  {
   ulong                ticket;         // Position ticket
   double               current_sl;     // Active stop loss
   double               proposed_sl;    // Calculated candidate stop loss
   bool                 should_update;  // Flag indicating modification necessity
   ENUM_TRAILING_STATUS status;         // Detailed status outcome
   uint                 retcode;        // Trade server return code
   string               message;        // Diagnostic message
  };

//--- Telemetry structure to track reproducible execution statistics
 struct TrailingTelemetry
  {
   int                  total_evaluations;      // Total positions processed
   int                  modifications_sent;     // Confirmed server modifications
   int                  skipped_min_step;       // Skipped due to minimum step filter
   int                  skipped_open_price;     // Skipped due to open-price guard
   int                  rejected_stops_level;   // Proactively rejected by Stops Level
   int                  rejected_freeze_level;  // Proactively rejected by Freeze Level
   int                  server_errors;          // Server rejections or execution errors
  };

//--- Production-oriented volatility trailing engine class
 class CVolatilityTrailing
  {
   private:
    string            m_symbol;          // Asset symbol
    ENUM_TIMEFRAMES   m_timeframe;       // Operation timeframe
    int               m_tr_period;       // True Range averaging period
    double            m_tr_multiplier;   // Volatility multiplier
    int               m_min_step_points; // Minimum step in points
    ulong             m_magic;           // Magic number identifier
    bool              m_only_in_profit;  // Require level beyond open price
    CTrade            m_trade;           // Trade execution object
    TrailingTelemetry m_telemetry;       // Internal telemetry accumulator

    double            CalculateSimpleTR(const MqlRates &rates[], int start_idx, int period);
    double            RoundToTickSize(double price, string symbol);
  public:
                     CVolatilityTrailing(string symbol, 
                                         ENUM_TIMEFRAMES tf, 
                                         int tr_period=14, 
                                         double tr_mult=2.0, 
                                         int min_step=10, 
                                         ulong magic=20260801,
                                         bool only_in_profit=true);
                    ~CVolatilityTrailing(void);
    bool              ProcessPosition(const ulong ticket, TrailingState &state);
    int               ProcessAllPositions(void);
    TrailingTelemetry GetTelemetry(void) const { return m_telemetry; }
    void              ResetTelemetry(void);
  };
//+------------------------------------------------------------------+
//| Constructor with comprehensive input validation                  |
//+------------------------------------------------------------------+
CVolatilityTrailing::CVolatilityTrailing(string symbol, 
                                         ENUM_TIMEFRAMES tf, 
                                         int tr_period, 
                                         double tr_mult, 
                                         int min_step, 
                                         ulong magic,
                                         bool only_in_profit)
  {
   m_symbol          = (symbol == "") ? _Symbol : symbol;
   m_timeframe       = tf;
   m_tr_period       = (tr_period > 0) ? tr_period : 14;
   m_tr_multiplier   = (tr_mult > 0.0) ? tr_mult : 2.0;
   m_min_step_points = (min_step >= 0) ? min_step : 0;
   m_magic           = magic;
   m_only_in_profit  = only_in_profit;

   m_trade.SetExpertMagicNumber(m_magic);
   ResetTelemetry();
  }

//+------------------------------------------------------------------+
//| Destructor                                                       |
//+------------------------------------------------------------------+
CVolatilityTrailing::~CVolatilityTrailing(void)
  {
  }

//+------------------------------------------------------------------+
//| Resets internal execution telemetry counters                     |
//+------------------------------------------------------------------+
void CVolatilityTrailing::ResetTelemetry(void)
  {
   m_telemetry.total_evaluations     = 0;
   m_telemetry.modifications_sent    = 0;
   m_telemetry.skipped_min_step      = 0;
   m_telemetry.skipped_open_price     = 0;
   m_telemetry.rejected_stops_level  = 0;
   m_telemetry.rejected_freeze_level = 0;
   m_telemetry.server_errors         = 0;
  }

//+------------------------------------------------------------------+
//| Normalizes candidate price strictly by symbol tick size          |
//+------------------------------------------------------------------+
double CVolatilityTrailing::RoundToTickSize(double price, string symbol)
  {
   double tick_size = SymbolInfoDouble(symbol, SYMBOL_TRADE_TICK_SIZE);
   int digits       = (int)SymbolInfoInteger(symbol, SYMBOL_DIGITS);

   if(tick_size > 0.0)
     {
      return NormalizeDouble(MathRound(price / tick_size) * tick_size, digits);
     }
   return NormalizeDouble(price, digits);
  }

//+------------------------------------------------------------------+
//| Computes Simple Arithmetic True Range over closed bars           |
//+------------------------------------------------------------------+
double CVolatilityTrailing::CalculateSimpleTR(const MqlRates &rates[], int start_idx, int period)
  {
   int size = ArraySize(rates);
   if(start_idx + period >= size) return 0.0;

   double sum = 0.0;
   for(int i = 0; i < period; i++)
     {
      int idx = start_idx + i;
      if(idx + 1 >= size) break;
      double high       = rates[idx].high;
      double low        = rates[idx].low;
      double prev_close = rates[idx + 1].close;
      double tr         = MathMax(high - low, MathMax(MathAbs(high - prev_close), MathAbs(low - prev_close)));
      sum += tr;
     }
   return (period > 0) ? (sum / period) : 0.0;
  }

//+------------------------------------------------------------------+
//| Processes trailing logic on a specific position ticket           |
//+------------------------------------------------------------------+
bool CVolatilityTrailing::ProcessPosition(const ulong ticket, TrailingState &state)
  {
   m_telemetry.total_evaluations++;
   state.ticket        = ticket;
   state.should_update = false;
   state.current_sl    = 0.0;
   state.proposed_sl   = 0.0;
   state.status        = TRAILING_STATUS_NO_UPDATE;
   state.retcode       = 0;
   state.message       = "";

   if(!PositionSelectByTicket(ticket))
     {
      state.status  = TRAILING_STATUS_ERROR;
      state.message = "Position ticket not found";
      m_telemetry.server_errors++;
      return false;
     }

   string pos_symbol = PositionGetString(POSITION_SYMBOL);
   if(pos_symbol != m_symbol)
     {
      state.status  = TRAILING_STATUS_ERROR;
      state.message = "Symbol mismatch";
      m_telemetry.server_errors++;
      return false;
     }

   ENUM_POSITION_TYPE pos_type = (ENUM_POSITION_TYPE)PositionGetInteger(POSITION_TYPE);
   double current_sl = PositionGetDouble(POSITION_SL);
   double open_price = PositionGetDouble(POSITION_PRICE_OPEN);
   state.current_sl  = current_sl;

   //--- Copy completed history: start at shift 1 in terminal history
   MqlRates rates[];
   int needed_bars = m_tr_period + 2; 
   ResetLastError();
   int copied = CopyRates(m_symbol, m_timeframe, 1, needed_bars, rates);
   if(copied < needed_bars)
     {
      state.status  = TRAILING_STATUS_ERROR;
      state.message = "Insufficient closed history bars";
      m_telemetry.server_errors++;
      return false;
     }

   //--- In rates[], index 0 now represents the most recently completed bar
   ArraySetAsSeries(rates, true);

   double tr_avg = CalculateSimpleTR(rates, 0, m_tr_period);
   if(tr_avg <= 0.0)
     {
      state.status  = TRAILING_STATUS_ERROR;
      state.message = "Invalid TR average calculation";
      m_telemetry.server_errors++;
      return false;
     }

   double point        = SymbolInfoDouble(m_symbol, SYMBOL_POINT);
   double offset       = tr_avg * m_tr_multiplier;
   double min_step     = m_min_step_points * point;
   long   stops_level  = SymbolInfoInteger(m_symbol, SYMBOL_TRADE_STOPS_LEVEL);
   long   freeze_level = SymbolInfoInteger(m_symbol, SYMBOL_TRADE_FREEZE_LEVEL);
   double stops_dist   = stops_level * point;
   double freeze_dist  = freeze_level * point;

   if(pos_type == POSITION_TYPE_BUY)
     {
      double bid = SymbolInfoDouble(m_symbol, SYMBOL_BID);
      double proposed = RoundToTickSize(bid - offset, m_symbol);

      // 1. Open price protection gate (if enabled)
      if(m_only_in_profit && proposed <= open_price)
        {
         state.status  = TRAILING_STATUS_SKIPPED_OPEN_PRICE;
         state.message = "Candidate below open price";
         m_telemetry.skipped_open_price++;
         return false;
        }

      // 2. Ratchet advancement and minimum step gate
      if(current_sl > 0.0 && proposed < current_sl + min_step)
        {
         state.status  = TRAILING_STATUS_SKIPPED_STEP;
         state.message = "Step advancement insufficient";
         m_telemetry.skipped_min_step++;
         return false;
        }

      // 3. Broker STOPS_LEVEL check (distance to current market price)
      if((bid - proposed) < stops_dist)
        {
         state.status  = TRAILING_STATUS_REJECTED_STOPSLEVEL;
         state.message = "Violates broker STOPS_LEVEL constraint";
         m_telemetry.rejected_stops_level++;
         return false;
        }

      // 4. Broker FREEZE_LEVEL check (distance to active SL)
      if(current_sl > 0.0 && MathAbs(bid - current_sl) <= freeze_dist)
        {
         state.status  = TRAILING_STATUS_REJECTED_FREEZELEVEL;
         state.message = "Inside broker FREEZE_LEVEL boundary";
         m_telemetry.rejected_freeze_level++;
         return false;
        }

      state.proposed_sl   = proposed;
      state.should_update = true;

      if(m_trade.PositionModify(ticket, proposed, PositionGetDouble(POSITION_TP)))
        {
         uint retcode = m_trade.ResultRetcode();
         if(retcode == TRADE_RETCODE_DONE || retcode == TRADE_RETCODE_PLACED)
           {
            state.status  = TRAILING_STATUS_UPDATED;
            state.retcode = retcode;
            state.message = "Stop-loss modified successfully";
            m_telemetry.modifications_sent++;
            return true;
           }
         else
           {
            state.status  = TRAILING_STATUS_ERROR;
            state.retcode = retcode;
            state.message = m_trade.ResultRetcodeDescription();
            m_telemetry.server_errors++;
            return false;
           }
        }
      else
        {
         state.status  = TRAILING_STATUS_ERROR;
         state.retcode = m_trade.ResultRetcode();
         state.message = m_trade.ResultRetcodeDescription();
         m_telemetry.server_errors++;
         return false;
        }
     }
   else if(pos_type == POSITION_TYPE_SELL)
     {
      double ask = SymbolInfoDouble(m_symbol, SYMBOL_ASK);
      double proposed = RoundToTickSize(ask + offset, m_symbol);

      // 1. Open price protection gate (if enabled)
      if(m_only_in_profit && proposed >= open_price)
        {
         state.status  = TRAILING_STATUS_SKIPPED_OPEN_PRICE;
         state.message = "Candidate above open price";
         m_telemetry.skipped_open_price++;
         return false;
        }

      // 2. Ratchet advancement and minimum step gate
      if(current_sl > 0.0 && proposed > current_sl - min_step)
        {
         state.status  = TRAILING_STATUS_SKIPPED_STEP;
         state.message = "Step advancement insufficient";
         m_telemetry.skipped_min_step++;
         return false;
        }

      // 3. Broker STOPS_LEVEL check (distance to current market price)
      if((proposed - ask) < stops_dist)
        {
         state.status  = TRAILING_STATUS_REJECTED_STOPSLEVEL;
         state.message = "Violates broker STOPS_LEVEL constraint";
         m_telemetry.rejected_stops_level++;
         return false;
        }

      // 4. Broker FREEZE_LEVEL check (distance to active SL)
      if(current_sl > 0.0 && MathAbs(ask - current_sl) <= freeze_dist)
        {
         state.status  = TRAILING_STATUS_REJECTED_FREEZELEVEL;
         state.message = "Inside broker FREEZE_LEVEL boundary";
         m_telemetry.rejected_freeze_level++;
         return false;
        }

      state.proposed_sl   = proposed;
      state.should_update = true;

      if(m_trade.PositionModify(ticket, proposed, PositionGetDouble(POSITION_TP)))
        {
         uint retcode = m_trade.ResultRetcode();
         if(retcode == TRADE_RETCODE_DONE || retcode == TRADE_RETCODE_PLACED)
           {
            state.status  = TRAILING_STATUS_UPDATED;
            state.retcode = retcode;
            state.message = "Stop-loss modified successfully";
            m_telemetry.modifications_sent++;
            return true;
           }
         else
           {
            state.status  = TRAILING_STATUS_ERROR;
            state.retcode = retcode;
            state.message = m_trade.ResultRetcodeDescription();
            m_telemetry.server_errors++;
            return false;
           }
        }
      else
        {
         state.status  = TRAILING_STATUS_ERROR;
         state.retcode = m_trade.ResultRetcode();
         state.message = m_trade.ResultRetcodeDescription();
         m_telemetry.server_errors++;
         return false;
        }
     }

   return false;
  }

//+------------------------------------------------------------------+
//| Scans and updates all positions belonging to this symbol & magic |
//+------------------------------------------------------------------+
int CVolatilityTrailing::ProcessAllPositions(void)
  {
   int updated_count = 0;
   for(int i = PositionsTotal() - 1; i >= 0; i--)
     {
      ulong ticket = PositionGetTicket(i);
      if(ticket > 0 && PositionSelectByTicket(ticket))
        {
         if(PositionGetString(POSITION_SYMBOL) == m_symbol && 
            PositionGetInteger(POSITION_MAGIC) == m_magic)
           {
            TrailingState state;
            if(ProcessPosition(ticket, state))
              {
               updated_count++;
              }
           }
        }
     }
   return updated_count;
  }