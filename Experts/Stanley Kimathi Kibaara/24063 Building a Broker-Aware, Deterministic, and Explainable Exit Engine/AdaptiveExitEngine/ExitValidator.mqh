//+------------------------------------------------------------------+
//|                                                ExitValidator.mqh |
//|                                  Copyright 2026, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2026, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
#property version   "1.00"

// --- Include the shared data types
#include "AdaptiveExitTypes.mqh"                                                           // Shared enums and structures

//+------------------------------------------------------------------+
//| Exit Validator - validates one candidate against broker rules    |
//+------------------------------------------------------------------+
class CExitValidator
  {
private:
   SExitConfig       m_config;                                                             // Thresholds and synthetic broker levels

   // --- Normalize a price to the tick size of the symbol
   double            NormalizeToTickSize(string symbol, double price)
     {
      double tick_size = SymbolInfoDouble(symbol, SYMBOL_TRADE_TICK_SIZE);                 // Tick size (price units)
      int digits = ExitSymbolDigits(symbol);                                               // Digits of the symbol
      if(tick_size <= 0)                                                                   // Tick size not available
         return NormalizeDouble(price, digits);                                            // Round to digits only
      double ticks = MathRound(price / tick_size);                                         // Nearest whole number of ticks
      return NormalizeDouble(ticks * tick_size, digits);                                   // Price on the tick grid
     }

   // --- Check that a volume is a whole number of volume steps
   bool              IsVolumeAligned(string symbol, double volume)
     {
      double step = SymbolInfoDouble(symbol, SYMBOL_VOLUME_STEP);                          // Volume step (lots)
      if(step <= 0)                                                                        // Step not available
         return true;                                                                      // Nothing to check
      double ratio = volume / step;                                                        // Volume in steps
      return MathAbs(ratio - MathRound(ratio)) < 1e-6;                                     // 1e-6 absorbs float noise
     }

   // --- Check that a volume is inside the broker volume range
   bool              IsVolumeInRange(string symbol, double volume, string &msg)
     {
      double min_vol = SymbolInfoDouble(symbol, SYMBOL_VOLUME_MIN);                        // Minimum volume (lots)
      double max_vol = SymbolInfoDouble(symbol, SYMBOL_VOLUME_MAX);                        // Maximum volume (lots)
      bool below = (volume < min_vol - 1e-10);                                             // Below minimum (1e-10 tolerance)
      bool above = (max_vol > 0 && volume > max_vol + 1e-10);                              // Above maximum (1e-10 tolerance)
      if(below || above)                                                                   // Outside the range
        {
         msg = StringFormat("%.2f outside [%.2f, %.2f]", volume, min_vol, max_vol);        // Describe the range
         return false;                                                                     // Invalid volume
        }
      return true;                                                                         // Volume is valid
     }

   // --- Stop level: synthetic value for tests, otherwise the broker value
   long              StopLevelPoints(string symbol)
     {
      if(m_config.test_stop_level_points > 0)                                              // Synthetic level set
         return m_config.test_stop_level_points;                                           // Synthetic value (points)
      return SymbolInfoInteger(symbol, SYMBOL_TRADE_STOPS_LEVEL);                          // Broker value (points)
     }

   // --- Freeze level: synthetic value for tests, otherwise the broker value
   long              FreezeLevelPoints(string symbol)
     {
      if(m_config.test_freeze_level_points > 0)                                            // Synthetic level set
         return m_config.test_freeze_level_points;                                         // Synthetic value (points)
      return SymbolInfoInteger(symbol, SYMBOL_TRADE_FREEZE_LEVEL);                         // Broker value (points)
     }

   // --- Validate a full close; the close volume is always re-read from the fresh position
   ENUM_EXIT_RESULT  ValidateFullExit(SPositionSnapshot &position, SExitAdjustment &validated, string &explanation)
     {
      if(position.volume <= 0)                                                             // Nothing left to close
        {
         explanation = "Position volume is zero.";                                         // Set explanation
         return EXIT_RESULT_INVALID_VOLUME;                                                // Invalid volume
        }
      validated.close_volume = position.volume;                                            // Fresh volume (lots)
      validated.proposed_sl = 0.0;                                                         // Not used for closes
      validated.proposed_tp = 0.0;                                                         // Not used for closes
      validated.well_formed = true;                                                        // Broker-ready
      explanation = StringFormat("Full close of %.2f lots accepted.", position.volume);    // Set explanation
      return EXIT_RESULT_OK;                                                               // Accepted
     }

   // --- Validate a partial close; both the closed and the remaining volume must be tradable
   ENUM_EXIT_RESULT  ValidatePartialExit(SPositionSnapshot &position, SExitAdjustment &validated, string &explanation)
     {
      double close_vol = validated.close_volume;                                           // Volume to close (lots)
      double remaining = position.volume - close_vol;                                      // Volume left open (lots)
      string msg = "";                                                                     // Range message
      if(close_vol <= 0 || remaining <= 0)                                                 // Either volume not positive
        {
         explanation = StringFormat("Close volume %.2f invalid.", close_vol);              // Set explanation
         return EXIT_RESULT_INVALID_VOLUME;                                                // Invalid volume
        }
      bool close_ok = IsVolumeAligned(position.symbol, close_vol);                         // Close volume on the step grid
      bool rest_ok = IsVolumeAligned(position.symbol, remaining);                          // Remaining volume on the step grid
      if(!close_ok || !rest_ok)                                                            // Not multiples of the step
        {
         explanation = "Close or remaining volume not aligned to volume step.";            // Set explanation
         return EXIT_RESULT_VOLUME_STEP_VIOLATION;                                         // Step violation
        }
      if(!IsVolumeInRange(position.symbol, close_vol, msg))                                // Close volume range
        {
         explanation = "Close volume " + msg;                                              // Set explanation
         return EXIT_RESULT_INVALID_VOLUME;                                                // Invalid volume
        }
      if(!IsVolumeInRange(position.symbol, remaining, msg))                                // Remaining volume range
        {
         explanation = "Remaining volume " + msg;                                          // Set explanation
         return EXIT_RESULT_INVALID_VOLUME;                                                // Invalid volume
        }
      validated.proposed_sl = 0.0;                                                         // Not used for closes
      validated.proposed_tp = 0.0;                                                         // Not used for closes
      validated.well_formed = true;                                                        // Broker-ready
      string vol_text = DoubleToString(position.volume, 2);                                // Position volume as text (lots)
      string close_text = DoubleToString(close_vol, 2);                                    // Close volume as text (lots)
      explanation = "Partial close " + close_text + " of " + vol_text + " lots accepted."; // Set explanation
      return EXIT_RESULT_OK;                                                               // Accepted
     }

   // --- Validate a stop modification; normalization comes first so every check sees the sent price
   ENUM_EXIT_RESULT  ValidateStop(SPositionSnapshot &position, SExitAdjustment &validated, string &explanation)
     {
      double point = ExitSymbolPoint(position.symbol);                                     // Point of the symbol (price units)
      int digits = ExitSymbolDigits(position.symbol);                                      // Digits of the symbol
      double raw_sl = validated.proposed_sl;                                               // Stop as proposed (price units)
      double sl = NormalizeToTickSize(position.symbol, raw_sl);                            // Stop on the tick grid
      double tp = 0.0;                                                                     // Take profit to send
      if(validated.proposed_tp > 0)                                                        // Take profit present
         tp = NormalizeToTickSize(position.symbol, validated.proposed_tp);                 // Take profit on the tick grid
      string note = "";                                                                    // Normalization note for the trace
      if(MathAbs(sl - raw_sl) > 1e-12)                                                     // Normalization changed the stop
        {
         string from_text = DoubleToString(raw_sl, digits + 1);                            // Stop before rounding
         string to_text = DoubleToString(sl, digits);                                      // Stop after rounding
         note = " (SL normalized " + from_text + " -> " + to_text + ")";                   // Note for the trace
        }

      // --- Idempotency: a change smaller than the threshold is not worth a request
      if(position.current_sl != 0)                                                         // Existing stop present
        {
         double cur = NormalizeToTickSize(position.symbol, position.current_sl);           // Existing stop on the grid
         double diff = MathAbs(sl - cur);                                                  // Size of the change (price units)
         if(diff < m_config.min_effective_sl_change * point)                               // Below threshold (points)
           {
            string diff_text = DoubleToString(diff / point, 1);                            // Change as text (points)
            explanation = "SL change " + diff_text + " points below threshold.";           // Set explanation
            return EXIT_RESULT_NO_CHANGE;                                                  // Nothing to do
           }
        }

      // --- Risk invariants: an initial stop sits on the loss side, an existing stop may only improve
      bool is_buy = (position.direction == POSITION_TYPE_BUY);                             // Direction of the position
      if(position.current_sl == 0)                                                         // Initial stop
        {
         if(is_buy && sl >= position.entry_price)                                          // BUY stop must be below entry
           {
            explanation = "Initial BUY stop must be below entry.";                         // Set explanation
            return EXIT_RESULT_INVALID_PRICE;                                              // Wrong side
           }
         if(!is_buy && sl <= position.entry_price)                                         // SELL stop must be above entry
           {
            explanation = "Initial SELL stop must be above entry.";                        // Set explanation
            return EXIT_RESULT_INVALID_PRICE;                                              // Wrong side
           }
        }
      else                                                                                 // Existing stop
        {
         bool higher = (sl > position.current_sl);                                         // New stop above the current one
         bool lower = (sl < position.current_sl);                                          // New stop below the current one
         bool improves = is_buy ? higher : lower;                                          // Protection improves
         if(!improves)                                                                     // Stop would not improve
           {
            explanation = "Proposed stop worsens protection.";                             // Set explanation
            return EXIT_RESULT_RISK_REGRESSION;                                            // Risk regression
           }
        }

      // --- The stop must sit on the correct side of price and respect the stop level
      long stop_level_points = StopLevelPoints(position.symbol);                           // Stop level (points)
      double stop_level_price = stop_level_points * point;                                 // Stop level (price units)
      double distance;                                                                     // Price to stop distance (price units)
      if(is_buy)                                                                           // Long position
         distance = position.current_price - sl;                                           // Price above the stop
      else                                                                                 // Short position
         distance = sl - position.current_price;                                           // Stop above the price
      if(distance <= 0)                                                                    // Stop on the wrong side of price
        {
         explanation = "Stop is on the wrong side of the current price.";                  // Set explanation
         return EXIT_RESULT_INVALID_PRICE;                                                 // Wrong side
        }
      if(distance < stop_level_price)                                                      // Too close to price
        {
         string dist_text = DoubleToString(distance / point, 1);                           // Distance as text (points)
         string level_text = IntegerToString(stop_level_points);                           // Stop level as text (points)
         explanation = "Stop distance " + dist_text + " points";                           // Distance part
         explanation += " < stop level " + level_text + " points.";                        // Stop level part
         return EXIT_RESULT_STOP_LEVEL_VIOLATION;                                          // Stop level violation
        }

      // --- An existing SL or TP inside the freeze distance cannot be modified
      long freeze_level_points = FreezeLevelPoints(position.symbol);                       // Freeze level (points)
      double freeze_level_price = freeze_level_points * point;                             // Freeze level (price units)
      if(freeze_level_price > 0)                                                           // Broker uses a freeze level
        {
         double sl_gap = MathAbs(position.current_price - position.current_sl);            // Price to existing SL
         double tp_gap = MathAbs(position.current_tp - position.current_price);            // Price to existing TP
         if(position.current_sl != 0 && sl_gap < freeze_level_price)                       // Existing SL frozen
           {
            explanation = "Existing SL inside freeze level.";                              // Set explanation
            return EXIT_RESULT_FREEZE_LEVEL_VIOLATION;                                     // Freeze level violation
           }
         if(position.current_tp != 0 && tp_gap < freeze_level_price)                       // Existing TP frozen
           {
            explanation = "Existing TP inside freeze level.";                              // Set explanation
            return EXIT_RESULT_FREEZE_LEVEL_VIOLATION;                                     // Freeze level violation
           }
        }

      validated.proposed_sl = sl;                                                          // Normalized stop (price units)
      validated.proposed_tp = tp;                                                          // Normalized take profit (price units)
      validated.close_volume = 0.0;                                                        // Stop modifications carry no volume
      validated.well_formed = true;                                                        // Broker-ready
      explanation = "Stop modification accepted" + note + ".";                             // Set explanation
      return EXIT_RESULT_OK;                                                               // Accepted
     }

public:
   // --- Constructor - stores the configuration
                     CExitValidator(SExitConfig &config) : m_config(config) {}

   // --- Validate one candidate; on EXIT_RESULT_OK 'validated' holds the broker-ready request
   ENUM_EXIT_RESULT  Validate(SPositionSnapshot &position, SExitAdjustment &proposal, SExitAdjustment &validated, string &explanation)
     {
      validated = proposal;                                                                // Start from the proposal
      validated.well_formed = false;                                                       // Not broker-ready until all checks pass

      bool bad_snapshot = (position.ticket == 0 || position.symbol == "");                 // Snapshot incomplete
      bool other_ticket = (proposal.ticket != position.ticket);                            // Proposal for another position
      if(bad_snapshot || other_ticket)                                                     // Cannot validate
        {
         explanation = "Invalid snapshot or ticket mismatch.";                             // Set explanation
         return EXIT_RESULT_INVALID_PRICE;                                                 // Invalid input
        }

      double bid = SymbolInfoDouble(position.symbol, SYMBOL_BID);                          // Current bid (price units)
      double ask = SymbolInfoDouble(position.symbol, SYMBOL_ASK);                          // Current ask (price units)
      if(bid <= 0 || ask <= 0)                                                             // Prices not available
        {
         explanation = "Bid/Ask not available.";                                           // Set explanation
         return EXIT_RESULT_INVALID_PRICE;                                                 // Invalid price
        }

      if(proposal.action == EXIT_ACTION_FULL_EXIT)                                         // Full close
         return ValidateFullExit(position, validated, explanation);                        // Volume checks
      if(proposal.action == EXIT_ACTION_PARTIAL_EXIT)                                      // Partial close
         return ValidatePartialExit(position, validated, explanation);                     // Volume checks
      return ValidateStop(position, validated, explanation);                               // Stop modification checks
     }
  };

//+------------------------------------------------------------------+
