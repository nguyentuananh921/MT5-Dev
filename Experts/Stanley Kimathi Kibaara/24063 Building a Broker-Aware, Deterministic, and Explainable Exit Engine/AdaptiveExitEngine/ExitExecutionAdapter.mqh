//+------------------------------------------------------------------+
//|                                         ExitExecutionAdapter.mqh |
//|                                  Copyright 2026, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2026, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
#property version   "1.00"

// --- Include the shared data types
#include "AdaptiveExitTypes.mqh"                                                                // Shared enums and structures

//+------------------------------------------------------------------+
//| Exit Execution Adapter - executes validated trade decisions      |
//+------------------------------------------------------------------+
class CExitExecutionAdapter
  {
private:
   int               m_deviation_points;                                                        // Allowed slippage for market closes (points)

public:
   // --- Constructor - stores the allowed deviation
                     CExitExecutionAdapter(int deviation_points = 10)
     {
      m_deviation_points = deviation_points;                                                    // Allowed slippage (points)
     }

   // --- Choose a filling mode the symbol supports (FOK, then IOC, then RETURN)
   static ENUM_ORDER_TYPE_FILLING SelectFillingMode(string symbol)
     {
      long modes = SymbolInfoInteger(symbol, SYMBOL_FILLING_MODE);                              // Filling modes allowed by the symbol
      if((modes & SYMBOL_FILLING_FOK) == SYMBOL_FILLING_FOK)                                    // Fill or Kill allowed
         return ORDER_FILLING_FOK;                                                              // All or nothing, simplest to reconcile
      if((modes & SYMBOL_FILLING_IOC) == SYMBOL_FILLING_IOC)                                    // Immediate or Cancel allowed
         return ORDER_FILLING_IOC;                                                              // May fill partially (DONE_PARTIAL)
      return ORDER_FILLING_RETURN;                                                              // Exchange or request execution fallback
     }

   // --- Map a return code to an engine result; DONE_PARTIAL and PLACED still need reconciliation
   static ENUM_EXIT_RESULT ClassifyRetcode(uint retcode)
     {
      switch(retcode)                                                                           // Branch on return code
        {
         case TRADE_RETCODE_DONE:                                                               // Request completed
            return EXIT_RESULT_OK;                                                              // Executed
         case TRADE_RETCODE_DONE_PARTIAL:                                                       // Only part of the volume filled
            return EXIT_RESULT_PARTIAL_FILL;                                                    // Partly executed
         case TRADE_RETCODE_PLACED:                                                             // Order placed, not filled yet
            return EXIT_RESULT_PENDING_CONFIRMATION;                                            // Outcome not visible yet
         default:                                                                               // Any other code
            return EXIT_RESULT_EXECUTION_ERROR;                                                 // Failure
        }
     }

   // --- Execute a validated proposal or simulate it in dry-run mode
   SExitResult       Execute(SPositionSnapshot &position, SExitAdjustment &proposal, bool dry_run)
     {
      SExitResult result;                                                                       // Result to be returned
      ZeroMemory(result);                                                                       // Clear all fields
      result.success = false;                                                                   // Failure until proven otherwise
      result.retcode = 0;                                                                       // No return code yet
      result.final_sl = position.current_sl;                                                    // Preserve current SL (price units)
      result.final_tp = position.current_tp;                                                    // Preserve current TP (price units)
      result.final_volume = position.volume;                                                    // Preserve current volume (lots)
      result.final_reason = proposal.reason;                                                    // Reason of the proposal
      result.result_code = EXIT_RESULT_EXECUTION_ERROR;                                         // Default error code

      // --- Expected outcome, used for dry-run and as the target of reconciliation
      bool is_stop = (proposal.action == EXIT_ACTION_STOP_MODIFICATION);                        // True for SL/TP modification
      double left = MathMax(0.0, position.volume - proposal.close_volume);                      // Volume left after a close (lots)
      double expected_sl = is_stop ? proposal.proposed_sl : position.current_sl;                // Expected SL (price units)
      double expected_tp = is_stop ? proposal.proposed_tp : position.current_tp;                // Expected TP (price units)
      double expected_volume = is_stop ? position.volume : left;                                // Expected volume (lots)

      if(dry_run)                                                                               // Simulation only
        {
         result.success = true;                                                                 // Simulated success
         result.final_sl = expected_sl;                                                         // Expected SL
         result.final_tp = expected_tp;                                                         // Expected TP
         result.final_volume = expected_volume;                                                 // Expected volume
         result.result_code = EXIT_RESULT_OK;                                                   // Mark as OK
         result.error_message = "Dry-run: simulated, nothing sent.";                            // Explain simulation
         return result;                                                                         // Nothing sent
        }

      MqlTradeRequest req;                                                                      // Trade request
      MqlTradeResult res;                                                                       // Trade result
      ZeroMemory(req);                                                                          // Clear request
      ZeroMemory(res);                                                                          // Clear result
      req.position = position.ticket;                                                           // Target position
      req.symbol = position.symbol;                                                             // Position symbol
      req.magic = (ulong)position.magic;                                                        // Keep the position magic

      if(is_stop)                                                                               // Stop/TP modification
        {
         req.action = TRADE_ACTION_SLTP;                                                        // Modify SL/TP
         req.sl = proposal.proposed_sl;                                                         // New stop loss (price units)
         req.tp = proposal.proposed_tp;                                                         // Take profit to keep (price units)
        }
      else                                                                                      // Full or partial close
        {
         bool bad_volume = (proposal.close_volume <= 0);                                        // Nothing to close
         double max_close = position.volume + 1e-10;                                            // Position volume plus float tolerance (lots)
         bool too_large = (proposal.close_volume > max_close);                                  // More than the position holds
         if(bad_volume || too_large)                                                            // Close volume not usable
           {
            result.result_code = EXIT_RESULT_INVALID_VOLUME;                                    // Invalid volume code
            result.error_message = "Invalid close volume.";                                     // Error message
            return result;                                                                      // Nothing sent
           }
         req.action = TRADE_ACTION_DEAL;                                                        // Market deal against the position
         req.volume = proposal.close_volume;                                                    // Volume to close (lots)
         if(position.direction == POSITION_TYPE_BUY)                                            // Long position
           {
            req.type = ORDER_TYPE_SELL;                                                         // Close a long by selling
            req.price = SymbolInfoDouble(position.symbol, SYMBOL_BID);                          // Bid price
           }
         else                                                                                   // Short position
           {
            req.type = ORDER_TYPE_BUY;                                                          // Close a short by buying
            req.price = SymbolInfoDouble(position.symbol, SYMBOL_ASK);                          // Ask price
           }
         req.deviation = (ulong)m_deviation_points;                                             // Allowed slippage (points)
         req.type_filling = SelectFillingMode(position.symbol);                                 // Filling mode supported by the symbol
        }

      ResetLastError();                                                                         // Clear previous error
      bool sent = OrderSend(req, res);                                                          // Send the request
      result.retcode = res.retcode;                                                             // Raw return code
      result.result_code = ClassifyRetcode(res.retcode);                                        // Engine result

      if(!sent || result.result_code == EXIT_RESULT_EXECUTION_ERROR)                            // Not accepted
        {
         int last_error = GetLastError();                                                       // Terminal error code
         result.success = false;                                                                // Failure
         result.result_code = EXIT_RESULT_EXECUTION_ERROR;                                      // Execution error
         string detail = StringFormat("retcode %u (%s)", res.retcode, res.comment);             // Server answer
         string err_text = IntegerToString(last_error);                                         // Terminal error as text
         result.error_message = "Rejected: " + detail + ", last error " + err_text;             // Details
         return result;                                                                         // Return error
        }

      // --- Values below are expected; the engine confirms them by reconciliation
      result.success = true;                                                                    // Request accepted
      result.final_sl = expected_sl;                                                            // Expected SL
      result.final_tp = expected_tp;                                                            // Expected TP
      result.final_volume = expected_volume;                                                    // Expected volume
      if(result.result_code == EXIT_RESULT_PARTIAL_FILL)                                        // Only part was filled
         result.final_volume = MathMax(0.0, position.volume - res.volume);                      // res.volume is the filled part (lots)
      string code_name = ResultName(result.result_code);                                        // Result name
      result.error_message = StringFormat("Accepted: retcode %u (%s)", res.retcode, code_name); // Success message
      return result;                                                                            // Return result
     }
  };

//+------------------------------------------------------------------+
