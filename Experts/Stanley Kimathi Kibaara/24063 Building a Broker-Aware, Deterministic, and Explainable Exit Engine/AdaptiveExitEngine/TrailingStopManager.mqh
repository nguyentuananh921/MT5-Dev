//+------------------------------------------------------------------+
//|                                          TrailingStopManager.mqh |
//|                                  Copyright 2026, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2026, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
#property version   "1.00"

// --- Include the shared data types
#include "AdaptiveExitTypes.mqh"                                                    // Shared enums and structures

//+------------------------------------------------------------------+
//| Trailing Stop Manager - generates trailing stop proposals        |
//+------------------------------------------------------------------+
class CTrailingStopManager
  {
private:
   // --- Member variables
   double            m_activation_R;                                                // Max favorable R that activates trailing (R-multiple, e.g., 1.5)
   double            m_trail_step_points;                                           // Distance from current price (points of the position symbol)

public:
   // --- Constructor - stores activation threshold and trail step
                     CTrailingStopManager(double activation_R, double trail_step_points)
     {
      m_activation_R = activation_R;                                                // Store activation threshold (R-multiple)
      m_trail_step_points = trail_step_points;                                      // Store trail step (points)
     }

   // --- Generate a trailing stop proposal once the activation threshold is met
   bool              GenerateProposal(SPositionSnapshot &position, SExitAdjustment &proposal, ENUM_EXIT_ERROR &error)
     {
      // --- R is undefined until 1R exists
      bool no_risk = (position.initial_risk_distance <= 0);                         // 1R distance unknown
      bool no_stop = ((position.flags & PSF_INITIAL_STOP) == 0);                    // Initial stop not confirmed
      if(no_risk || no_stop)                                                        // R not available
        {
         error = EXIT_NO_INITIAL_RISK;                                              // Set missing 1R error
         return false;                                                              // No proposal
        }

      if(position.max_favorable_R < m_activation_R)                                 // Activation not reached yet
        {
         error = EXIT_OK;                                                           // Nothing to do, not an error
         return false;                                                              // No proposal
        }

      // --- The step uses the point of the position symbol, not the chart _Point
      double step = m_trail_step_points * ExitSymbolPoint(position.symbol);         // Trail distance (price units)
      double new_sl;                                                                // New stop level (price units)
      if(position.direction == POSITION_TYPE_BUY)                                   // Long position
         new_sl = position.current_price - step;                                    // Stop below current price
      else                                                                          // Short position
         new_sl = position.current_price + step;                                    // Stop above current price

      string side = (position.direction == POSITION_TYPE_BUY) ? "-" : "+";          // Sign shown in the explanation
      string r_text = DoubleToString(position.max_favorable_R, 2);                  // Max favorable R as text
      string act_text = DoubleToString(m_activation_R, 2);                          // Activation as text
      string step_text = DoubleToString(m_trail_step_points, 1);                    // Step as text

      ZeroMemory(proposal);                                                         // Clear all fields
      proposal.ticket = position.ticket;                                            // Same ticket
      proposal.action = EXIT_ACTION_STOP_MODIFICATION;                              // Action: modify SL/TP
      proposal.proposed_sl = new_sl;                                                // New trailing stop (price units)
      proposal.proposed_tp = position.current_tp;                                   // Keep existing take profit
      proposal.close_volume = 0.0;                                                  // Stop modification carries no volume
      proposal.reason = EXIT_REASON_TRAILING;                                       // Reason: trailing stop
      proposal.explanation = "Trailing: max R " + r_text + " >= " + act_text;       // Explain the trigger
      proposal.explanation += ", SL = price " + side + " " + step_text + " points"; // Explain the level
      proposal.well_formed = (new_sl > 0);                                          // A non-positive price is malformed
      error = EXIT_OK;                                                              // No error
      return true;                                                                  // Indicate proposal generated
     }
  };

//+------------------------------------------------------------------+
