//+------------------------------------------------------------------+
//|                                            ATRStopCalculator.mqh |
//|                                  Copyright 2026, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2026, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
#property version   "1.00"

// --- Include the shared data types
#include "AdaptiveExitTypes.mqh"                                                  // Shared enums and structures

//+------------------------------------------------------------------+
//| ATR Stop Calculator - generates the initial stop from ATR        |
//+------------------------------------------------------------------+
class CATRStopCalculator
  {
private:
   // --- Member variables
   int               m_atr_handle;                                                // Handle to the ATR indicator (cached)
   int               m_atr_period;                                                // Period for ATR calculation (bars)
   double            m_multiplier_stop;                                           // ATR multiplier for the initial stop (e.g., 2.0)
   string            m_symbol;                                                    // Symbol the ATR handle was created for

public:
   // --- Constructor - creates the ATR indicator handle once and caches it
                     CATRStopCalculator(string symbol, ENUM_TIMEFRAMES tf, int period, double mult_stop)
     {
      m_symbol = symbol;                                                          // Store the symbol
      m_atr_period = period;                                                      // Store the ATR period (bars)
      m_multiplier_stop = mult_stop;                                              // Store stop multiplier
      m_atr_handle = iATR(symbol, tf, period);                                    // Create ATR handle (cached)
     }

   // --- Destructor - releases the ATR indicator handle to avoid leaks
                    ~CATRStopCalculator()
     {
      if(m_atr_handle != INVALID_HANDLE)                                          // Check if handle is valid
         IndicatorRelease(m_atr_handle);                                          // Release the ATR handle
     }

   // --- Symbol this calculator serves
   string            GetSymbol(void) const { return m_symbol; }

   // --- Read ATR of the last closed bar, which does not change within the bar
   bool              GetClosedBarATR(double &value, ENUM_EXIT_ERROR &error)
     {
      if(m_atr_handle == INVALID_HANDLE)                                          // If handle is not valid
        {
         error = EXIT_INVALID_CONFIG;                                             // Set configuration error
         return false;                                                            // Return failure
        }

      double atr[1];                                                              // Buffer for one ATR value
      if(CopyBuffer(m_atr_handle, 0, 1, 1, atr) != 1 || atr[0] <= 0)              // Shift 1 = last closed bar
        {
         error = EXIT_NOT_ENOUGH_DATA;                                            // Set insufficient data error
         return false;                                                            // Return failure
        }
      value = atr[0];                                                             // ATR value (price units)
      error = EXIT_OK;                                                            // No error
      return true;                                                                // Indicate success
     }

   // --- Generate the initial stop proposal, anchored to the entry price
   bool              GenerateProposal(SPositionSnapshot &position, SExitAdjustment &proposal, ENUM_EXIT_ERROR &error)
     {
      // --- The cached handle belongs to m_symbol and must not be applied to another instrument
      if(position.symbol != m_symbol)                                             // Position is on another symbol
        {
         error = EXIT_SYMBOL_MISMATCH;                                            // Set symbol mismatch error
         return false;                                                            // Return failure
        }

      double atr;                                                                 // ATR value (price units)
      if(!GetClosedBarATR(atr, error))                                            // Read ATR of the last closed bar
         return false;                                                            // Return failure (error already set)

      // --- ATR is already in price units, so it is not multiplied by _Point
      double distance = atr * m_multiplier_stop;                                  // Stop distance from entry (price units)

      // --- Anchoring to entry keeps the stop valid for the initial-stop rule (BUY below, SELL above entry)
      double new_sl;                                                              // New stop level (price units)
      if(position.direction == POSITION_TYPE_BUY)                                 // Long position
         new_sl = position.entry_price - distance;                                // Stop below entry
      else                                                                        // Short position
         new_sl = position.entry_price + distance;                                // Stop above entry

      int digits = ExitSymbolDigits(position.symbol);                             // Digits of the position symbol
      string side = (position.direction == POSITION_TYPE_BUY) ? "-" : "+";        // Sign shown in the explanation
      string mult_text = DoubleToString(m_multiplier_stop, 2);                    // Multiplier as text
      string period_text = IntegerToString(m_atr_period);                         // ATR period as text
      string sl_text = DoubleToString(new_sl, digits);                            // Stop level as text

      ZeroMemory(proposal);                                                       // Clear all fields
      proposal.ticket = position.ticket;                                          // Set the ticket
      proposal.action = EXIT_ACTION_STOP_MODIFICATION;                            // Action: modify SL/TP
      proposal.proposed_sl = new_sl;                                              // Proposed SL (price units)
      proposal.proposed_tp = position.current_tp;                                 // Keep existing TP
      proposal.close_volume = 0.0;                                                // Stop modification carries no volume
      proposal.reason = EXIT_REASON_ATR;                                          // Reason: ATR-based
      proposal.explanation = "ATR initial stop: entry " + side + " " + mult_text; // Explain the formula
      proposal.explanation += " x ATR(" + period_text + ") = " + sl_text;         // Explain the result
      proposal.well_formed = (new_sl > 0);                                        // A non-positive price is malformed
      error = EXIT_OK;                                                            // No error
      return true;                                                                // Indicate success
     }
  };

//+------------------------------------------------------------------+
