//+------------------------------------------------------------------+
//|                                        PartialExitController.mqh |
//|                                  Copyright 2026, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2026, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
#property version   "1.00"

// --- Include the shared data types
#include "AdaptiveExitTypes.mqh"                                                     // Shared enums and structures

//+------------------------------------------------------------------+
//| Partial Exit Controller - generates partial close proposals      |
//+------------------------------------------------------------------+
class CPartialExitController
  {
private:
   // --- Member variables
   double            m_trigger_R;                                                    // Max favorable R that triggers the close (R-multiple)
   double            m_fraction;                                                     // Share of current volume to close (decimal fraction)
   bool              m_enabled;                                                      // Whether partial exit is enabled

public:
   // --- Constructor - stores trigger, fraction and enabled flag
                     CPartialExitController(double trigger_R, double fraction, bool enabled)
     {
      m_trigger_R = trigger_R;                                                       // Store the trigger (R-multiple)
      m_fraction = fraction;                                                         // Store the fraction (decimal fraction)
      m_enabled = enabled;                                                           // Store the enabled flag
     }

   // --- Generate a partial close proposal once the trigger is reached
   bool              GenerateProposal(SPositionSnapshot &position, SExitAdjustment &proposal, ENUM_EXIT_ERROR &error)
     {
      error = EXIT_OK;                                                               // Default: no error
      if(!m_enabled || m_fraction <= 0 || m_fraction >= 1)                           // Disabled or fraction outside (0, 1)
         return false;                                                               // No proposal

      // --- R is undefined until 1R exists
      bool no_risk = (position.initial_risk_distance <= 0);                          // 1R distance unknown
      bool no_stop = ((position.flags & PSF_INITIAL_STOP) == 0);                     // Initial stop not confirmed
      if(no_risk || no_stop)                                                         // R not available
        {
         error = EXIT_NO_INITIAL_RISK;                                               // Set missing 1R error
         return false;                                                               // No proposal
        }

      if((position.flags & PSF_PARTIAL_TAKEN) != 0)                                  // Only one partial close per position
         return false;                                                               // No proposal
      if(position.max_favorable_R < m_trigger_R)                                     // Trigger not reached yet
         return false;                                                               // No proposal

      // --- Rounding down to the volume step never closes more than intended
      double step = SymbolInfoDouble(position.symbol, SYMBOL_VOLUME_STEP);           // Volume step (lots)
      double min_vol = SymbolInfoDouble(position.symbol, SYMBOL_VOLUME_MIN);         // Minimum volume (lots)
      double raw = position.volume * m_fraction;                                     // Unrounded close volume (lots)
      double close_vol = raw;                                                        // Close volume (lots)
      if(step > 0)                                                                   // Step available
         close_vol = MathFloor(raw / step + 1e-9) * step;                            // Round down, 1e-9 absorbs float noise
      double remaining = position.volume - close_vol;                                // Volume left open (lots)
      if(close_vol < min_vol || remaining < min_vol)                                 // Volume cannot be split
         return false;                                                               // No proposal

      string r_text = DoubleToString(position.max_favorable_R, 2);                   // Max favorable R as text
      string trig_text = DoubleToString(m_trigger_R, 2);                             // Trigger as text
      string close_text = DoubleToString(close_vol, 2);                              // Close volume as text
      string vol_text = DoubleToString(position.volume, 2);                          // Position volume as text

      ZeroMemory(proposal);                                                          // Clear all fields
      proposal.ticket = position.ticket;                                             // Same ticket
      proposal.action = EXIT_ACTION_PARTIAL_EXIT;                                    // Action: close a fraction
      proposal.proposed_sl = 0.0;                                                    // Not used for closes
      proposal.proposed_tp = 0.0;                                                    // Not used for closes
      proposal.close_volume = close_vol;                                             // Volume to close (lots)
      proposal.reason = EXIT_REASON_PARTIAL;                                         // Reason: partial close
      proposal.explanation = "Partial close: max R " + r_text + " >= " + trig_text;  // Explain the trigger
      proposal.explanation += ", close " + close_text + " of " + vol_text + " lots"; // Explain the volume
      proposal.well_formed = (close_vol > 0);                                        // A zero-volume close is malformed
      return true;                                                                   // Indicate proposal generated
     }
  };

//+------------------------------------------------------------------+
