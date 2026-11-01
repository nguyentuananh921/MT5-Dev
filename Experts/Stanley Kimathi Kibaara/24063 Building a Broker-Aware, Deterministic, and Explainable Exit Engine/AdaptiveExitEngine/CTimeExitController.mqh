//+------------------------------------------------------------------+
//|                                          CTimeExitController.mqh |
//|                                  Copyright 2026, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2026, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
#property version   "1.00"

// --- Include the shared data types
#include "AdaptiveExitTypes.mqh"                                     // Shared enums and structures

//+------------------------------------------------------------------+
//| Time-Exit Controller - generates time-based exit proposals       |
//+------------------------------------------------------------------+
class CTimeExitController
  {
private:
   // --- Member variables
   int               m_max_lifetime_minutes;                         // Maximum position lifetime (minutes, 0 = disabled)
   bool              m_enabled;                                      // Whether time exit is enabled

public:
   // --- Constructor - stores lifetime and enabled flag
                     CTimeExitController(int max_lifetime_minutes, bool enabled)
     {
      m_max_lifetime_minutes = max_lifetime_minutes;                 // Store the lifetime (minutes)
      m_enabled = enabled;                                           // Store the enabled flag
     }

   // --- Generate a full-close proposal once the position lifetime is exceeded
   bool              GenerateProposal(SPositionSnapshot &position, SExitAdjustment &proposal, ENUM_EXIT_ERROR &error)
     {
      error = EXIT_OK;                                               // This module has no error path
      if(!m_enabled || m_max_lifetime_minutes <= 0)                  // Time exit disabled
         return false;                                               // No proposal

      long age_seconds = (long)(TimeCurrent() - position.open_time); // Position age (seconds)
      long limit_seconds = (long)m_max_lifetime_minutes * 60;        // Lifetime (minutes to seconds)
      if(age_seconds < limit_seconds)                                // Not expired yet
         return false;                                               // No proposal

      string age_text = IntegerToString(age_seconds / 60);           // Age as text (minutes)
      string limit_text = IntegerToString(m_max_lifetime_minutes);   // Lifetime as text (minutes)

      // --- The module sets the FULL_EXIT action itself, the engine never rewrites it
      ZeroMemory(proposal);                                          // Clear all fields
      proposal.ticket = position.ticket;                             // Same ticket
      proposal.action = EXIT_ACTION_FULL_EXIT;                       // Action: close the whole position
      proposal.proposed_sl = 0.0;                                    // Not used for full close
      proposal.proposed_tp = 0.0;                                    // Not used for full close
      proposal.close_volume = position.volume;                       // Close everything (lots)
      proposal.reason = EXIT_REASON_TIME;                            // Reason: time exit
      proposal.explanation = "Time exit: age " + age_text + " min";  // Explain the age
      proposal.explanation += " >= lifetime " + limit_text + " min"; // Explain the limit
      proposal.well_formed = (position.volume > 0);                  // A zero-volume close is malformed
      return true;                                                   // Indicate proposal generated
     }
  };

//+------------------------------------------------------------------+
