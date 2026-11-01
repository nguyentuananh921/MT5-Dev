//+------------------------------------------------------------------+
//|                                          BreakevenController.mqh |
//|                                  Copyright 2026, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2026, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
#property version   "1.00"

// --- Include the shared data types
#include "AdaptiveExitTypes.mqh"                                                   // Shared enums and structures

//+------------------------------------------------------------------+
//| Breakeven Controller - generates breakeven stop proposals        |
//+------------------------------------------------------------------+
class CBreakevenController
  {
private:
   // --- Member variables
   double            m_threshold_R;                                                // Current R that triggers breakeven (R-multiple, e.g., 0.5)
   double            m_buffer_points;                                              // Buffer beyond entry (points of the position symbol)

public:
   // --- Constructor - stores the threshold and buffer
                     CBreakevenController(double threshold_R, double buffer_points)
     {
      m_threshold_R = threshold_R;                                                 // Store the R threshold (R-multiple)
      m_buffer_points = buffer_points;                                             // Store the buffer (points)
     }

   // --- Generate a breakeven proposal once current R reaches the threshold
   bool              GenerateProposal(SPositionSnapshot &position, SExitAdjustment &proposal, ENUM_EXIT_ERROR &error)
     {
      // --- R is undefined until 1R exists, so a placeholder 0 is never compared with the threshold
      bool no_risk = (position.initial_risk_distance <= 0);                        // 1R distance unknown
      bool no_stop = ((position.flags & PSF_INITIAL_STOP) == 0);                   // Initial stop not confirmed
      if(no_risk || no_stop)                                                       // R not available
        {
         error = EXIT_NO_INITIAL_RISK;                                             // Set missing 1R error
         return false;                                                             // No proposal
        }

      if((position.flags & (PSF_BREAKEVEN | PSF_TRAILING)) != 0)                   // Breakeven done or trailing took over
        {
         error = EXIT_OK;                                                          // Nothing to do, not an error
         return false;                                                             // No proposal
        }

      if(position.current_R < m_threshold_R)                                       // Threshold not reached yet
        {
         error = EXIT_OK;                                                          // Nothing to do, not an error
         return false;                                                             // No proposal
        }

      // --- The buffer uses the point of the position symbol, not the chart _Point
      double buffer = m_buffer_points * ExitSymbolPoint(position.symbol);          // Buffer (price units)
      double new_sl;                                                               // New stop level (price units)
      if(position.direction == POSITION_TYPE_BUY)                                  // Long position
         new_sl = position.entry_price + buffer;                                   // Stop above entry
      else                                                                         // Short position
         new_sl = position.entry_price - buffer;                                   // Stop below entry

      string side = (position.direction == POSITION_TYPE_BUY) ? "+" : "-";         // Sign shown in the explanation
      string r_text = DoubleToString(position.current_R, 2);                       // Current R as text
      string th_text = DoubleToString(m_threshold_R, 2);                           // Threshold as text
      string buf_text = DoubleToString(m_buffer_points, 1);                        // Buffer as text

      ZeroMemory(proposal);                                                        // Clear all fields
      proposal.ticket = position.ticket;                                           // Same ticket
      proposal.action = EXIT_ACTION_STOP_MODIFICATION;                             // Action: modify SL/TP
      proposal.proposed_sl = new_sl;                                               // Stop at entry plus buffer
      proposal.proposed_tp = position.current_tp;                                  // Keep existing take profit
      proposal.close_volume = 0.0;                                                 // Stop modification carries no volume
      proposal.reason = EXIT_REASON_BREAKEVEN;                                     // Reason: breakeven move
      proposal.explanation = "Breakeven: R " + r_text + " >= " + th_text;          // Explain the trigger
      proposal.explanation += ", SL = entry " + side + " " + buf_text + " points"; // Explain the level
      proposal.well_formed = (new_sl > 0);                                         // A non-positive price is malformed
      error = EXIT_OK;                                                             // No error
      return true;                                                                 // Indicate proposal generated
     }
  };

//+------------------------------------------------------------------+
