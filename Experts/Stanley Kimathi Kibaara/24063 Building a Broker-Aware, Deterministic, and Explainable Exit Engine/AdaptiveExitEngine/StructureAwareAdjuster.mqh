//+------------------------------------------------------------------+
//|                                       StructureAwareAdjuster.mqh |
//|                                  Copyright 2026, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2026, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
#property version   "1.00"

// --- Include the shared data types
#include "AdaptiveExitTypes.mqh"                                                // Shared enums and structures

//+------------------------------------------------------------------+
//| Structure Aware Adjuster - pivot-based swing detection           |
//+------------------------------------------------------------------+
class CStructureAwareAdjuster
  {
private:
   // --- Member variables
   string            m_symbol;                                                  // Symbol to analyse
   int               m_lookback;                                                // Number of closed bars to scan (bars)
   int               m_left_bars;                                               // Bars to the left of a potential pivot (bars)
   int               m_right_bars;                                              // Bars to the right of a potential pivot (bars)
   int               m_refresh_seconds;                                         // Swing data refresh interval (seconds)
   bool              m_dirty;                                                   // True when swing data needs a refresh
   double            m_last_high;                                               // Most recent pivot high or lookback maximum (price units)
   double            m_last_low;                                                // Most recent pivot low or lookback minimum (price units)
   datetime          m_last_update;                                             // Time of the last swing update (timestamp)

   // --- Update swing levels using pivot detection on closed bars only
   void              UpdateSwings()
     {
      double high[], low[];                                                     // Price buffers (index 0 = oldest)
      int bars = CopyHigh(m_symbol, PERIOD_CURRENT, 1, m_lookback, high);       // Copy highs from bar 1
      int bars_low = CopyLow(m_symbol, PERIOD_CURRENT, 1, m_lookback, low);     // Copy lows from bar 1
      if(bars < m_lookback || bars_low < m_lookback)                            // Not enough history yet
        {
         m_dirty = true;                                                        // Try again later
         return;                                                                // Exit
        }

      int pivot_high_idx = -1, pivot_low_idx = -1;                              // -1 means no pivot found
      double pivot_high = 0, pivot_low = 0;                                     // Pivot prices (price units)

      // --- Scan from oldest to newest, so the last match is the most recent pivot
      for(int i = m_left_bars; i < m_lookback - m_right_bars; i++)              // Interior bars only
        {
         bool is_high = true;                                                   // Assume a pivot high
         for(int j = 1; j <= m_left_bars && is_high; j++)                       // Compare with left neighbours
            if(high[i] <= high[i-j])                                            // Not higher than neighbour
               is_high = false;                                                 // Not a pivot high
         for(int j = 1; j <= m_right_bars && is_high; j++)                      // Compare with right neighbours
            if(high[i] <= high[i+j])                                            // Not higher than neighbour
               is_high = false;                                                 // Not a pivot high
         if(is_high)                                                            // Confirmed pivot high
           {
            pivot_high = high[i];                                               // Record the high value
            pivot_high_idx = i;                                                 // Record the index
           }

         bool is_low = true;                                                    // Assume a pivot low
         for(int j = 1; j <= m_left_bars && is_low; j++)                        // Compare with left neighbours
            if(low[i] >= low[i-j])                                              // Not lower than neighbour
               is_low = false;                                                  // Not a pivot low
         for(int j = 1; j <= m_right_bars && is_low; j++)                       // Compare with right neighbours
            if(low[i] >= low[i+j])                                              // Not lower than neighbour
               is_low = false;                                                  // Not a pivot low
         if(is_low)                                                             // Confirmed pivot low
           {
            pivot_low = low[i];                                                 // Record the low value
            pivot_low_idx = i;                                                  // Record the index
           }
        }

      // --- Without a pivot, the lookback extreme is used as the structural level
      double highest = high[ArrayMaximum(high)];                                // Highest high in lookback
      double lowest = low[ArrayMinimum(low)];                                   // Lowest low in lookback
      m_last_high = (pivot_high_idx != -1) ? pivot_high : highest;              // Pivot high or fallback
      m_last_low = (pivot_low_idx != -1) ? pivot_low : lowest;                  // Pivot low or fallback
      m_last_update = TimeCurrent();                                            // Record update time
      m_dirty = false;                                                          // Data is now fresh
     }

public:
   // --- Constructor - stores symbol, lookback and pivot parameters
                     CStructureAwareAdjuster(string symbol, int lookback, int left_bars, int right_bars, int refresh_seconds=300)
     {
      m_symbol = symbol;                                                        // Store the symbol
      m_lookback = lookback;                                                    // Store the lookback (bars)
      m_left_bars = left_bars;                                                  // Store left bars (bars)
      m_right_bars = right_bars;                                                // Store right bars (bars)
      m_refresh_seconds = refresh_seconds;                                      // Store refresh interval (seconds)
      m_dirty = true;                                                           // No data yet
      m_last_update = 0;                                                        // No previous update
      m_last_high = 0;                                                          // No high yet
      m_last_low = 0;                                                           // No low yet
     }

   // --- Inject swing data for deterministic testing
   void              SetSwingData(double high, double low)
     {
      m_last_high = high;                                                       // Injected high (price units)
      m_last_low = low;                                                         // Injected low (price units)
      m_dirty = false;                                                          // Mark data as fresh
      m_last_update = TimeCurrent();                                            // Avoid recalculating
     }

   // --- Propose a structural stop only when the swing level is a valid, tighter alternative to ATR
   bool              GenerateProposal(SPositionSnapshot &position, double atr_stop, SExitAdjustment &proposal, ENUM_EXIT_ERROR &error)
     {
      if(position.symbol != m_symbol)                                           // Swing data belongs to m_symbol
        {
         error = EXIT_SYMBOL_MISMATCH;                                          // Set symbol mismatch error
         return false;                                                          // Return failure
        }

      bool expired = (TimeCurrent() - m_last_update > m_refresh_seconds);       // Data older than refresh interval
      if(m_dirty || expired)                                                    // Refresh needed
         UpdateSwings();                                                        // Update swing levels
      if(m_dirty)                                                               // Still no data
        {
         error = EXIT_NOT_ENOUGH_DATA;                                          // Set insufficient data error
         return false;                                                          // Return failure
        }

      double entry = position.entry_price;                                      // Entry price (price units)
      double structural_level;                                                  // Structural stop level (price units)
      double dist_atr, dist_struct;                                             // Distances from entry (price units)
      if(position.direction == POSITION_TYPE_BUY)                               // Long position
        {
         structural_level = m_last_low;                                         // Support (swing low)
         dist_atr = entry - atr_stop;                                           // Entry to ATR stop
         dist_struct = entry - structural_level;                                // Entry to swing low
        }
      else                                                                      // Short position
        {
         structural_level = m_last_high;                                        // Resistance (swing high)
         dist_atr = atr_stop - entry;                                           // Entry to ATR stop
         dist_struct = structural_level - entry;                                // Entry to swing high
        }

      // --- A level that is not tighter would only duplicate the ATR proposal under another reason
      if(!(dist_struct > 0 && dist_struct < dist_atr))                          // Not on the loss side or not tighter
        {
         error = EXIT_OK;                                                       // Not an error, structure is not better
         return false;                                                          // No proposal
        }

      int digits = ExitSymbolDigits(position.symbol);                           // Digits of the position symbol
      string side = (position.direction == POSITION_TYPE_BUY) ? "low" : "high"; // Swing side for the text
      string level_text = DoubleToString(structural_level, digits);             // Structural level as text
      string atr_text = DoubleToString(atr_stop, digits);                       // ATR stop as text

      ZeroMemory(proposal);                                                     // Clear all fields
      proposal.ticket = position.ticket;                                        // Set ticket
      proposal.action = EXIT_ACTION_STOP_MODIFICATION;                          // Action: modify SL/TP
      proposal.proposed_sl = structural_level;                                  // Proposed stop (price units)
      proposal.proposed_tp = position.current_tp;                               // Keep existing take profit
      proposal.close_volume = 0.0;                                              // Stop modification carries no volume
      proposal.reason = EXIT_REASON_STRUCTURE;                                  // Reason: structural adjustment
      proposal.explanation = "Structural pivot " + side + " at " + level_text;  // Explain the level
      proposal.explanation += " is tighter than ATR stop " + atr_text;          // Explain the comparison
      proposal.well_formed = (structural_level > 0);                            // A non-positive price is malformed
      error = EXIT_OK;                                                          // No error
      return true;                                                              // Indicate proposal generated
     }
  };

//+------------------------------------------------------------------+
