//+------------------------------------------------------------------+
//|                                              ExitPersistence.mqh |
//|                                  Copyright 2026, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2026, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
#property version   "1.00"

// --- Include the shared data types
#include "AdaptiveExitTypes.mqh"                                                     // Shared enums and structures

//+------------------------------------------------------------------+
//| Exit Persistence - appends one CSV row per decision              |
//+------------------------------------------------------------------+
class CExitPersistence
  {
private:
   // --- Member variables
   string            m_filename;                                                     // CSV file in the common data folder

   // --- Keep one decision on one CSV row (no delimiter or line break inside a field)
   string            Sanitize(string s)
     {
      StringReplace(s, "\r", "");                                                    // Remove carriage returns
      StringReplace(s, "\n", " / ");                                                 // Replace line breaks
      StringReplace(s, ",", ";");                                                    // Replace the CSV delimiter
      return s;                                                                      // Safe text
     }

public:
   // --- Constructor - stores the filename
                     CExitPersistence(string filename)
     {
      m_filename = filename;                                                         // CSV filename
     }

   // --- Append one decision to the CSV file
   bool              LogDecision(SPositionSnapshot &pos, SExitAdjustment &adj, ENUM_EXIT_RESULT validation_result, SExitResult &result)
     {
      if(m_filename == "")                                                           // Logging not configured
         return false;                                                               // Nothing written

      // --- FILE_READ together with FILE_WRITE opens without truncating the existing log
      int flags = FILE_READ | FILE_WRITE | FILE_CSV | FILE_COMMON | FILE_SHARE_READ; // Open flags
      int handle = FileOpen(m_filename, flags, ',');                                 // Open the CSV file
      if(handle == INVALID_HANDLE)                                                   // Open failed
         return false;                                                               // Nothing written
      FileSeek(handle, 0, SEEK_END);                                                 // Append at the end

      if(FileSize(handle) == 0)                                                      // New file needs a header
         FileWrite(handle,                                                           // Header row
                   "Timestamp", "Ticket", "Symbol", "Direction",                     // Identification columns
                   "EntryPrice", "CurrentSL", "NewSL",                               // Price columns (price units)
                   "Volume", "CloseVolume", "CurrentR", "Flags",                     // Volume (lots), R and state columns
                   "Action", "Reason", "ValidationResult",                           // Decision columns
                   "ExecutionResult", "Retcode", "Success",                          // Execution columns
                   "Message", "DecisionTrace");                                      // Text columns

      int digits = ExitSymbolDigits(pos.symbol);                                     // Digits of the position symbol
      string time_text = TimeToString(TimeCurrent(), TIME_DATE | TIME_SECONDS);      // Current time
      string ticket_text = IntegerToString((long)pos.ticket);                        // Ticket
      string dir_text = EnumToString(pos.direction);                                 // Direction
      string entry_text = DoubleToString(pos.entry_price, digits);                   // Entry price
      string sl_text = DoubleToString(pos.current_sl, digits);                       // Current SL
      string new_sl_text = DoubleToString(adj.proposed_sl, digits);                  // Proposed SL
      string vol_text = DoubleToString(pos.volume, 2);                               // Position volume (lots)
      string close_text = DoubleToString(adj.close_volume, 2);                       // Close volume (lots)
      string r_text = DoubleToString(pos.current_R, 2);                              // Current R (R-multiple)
      string flag_text = PositionFlagsToString(pos.flags);                           // Management flags
      string val_text = ResultName(validation_result);                               // Validation result
      string exec_text = ResultName(result.result_code);                             // Execution result
      string ret_text = IntegerToString((long)result.retcode);                       // Trade server return code
      string ok_text = result.success ? "TRUE" : "FALSE";                            // Success flag
      string msg_text = Sanitize(result.error_message);                              // Message on one line
      string trace_text = Sanitize(result.decision_trace);                           // Full trace on one line

      FileWrite(handle,                                                              // Data row
                time_text, ticket_text, pos.symbol, dir_text,                        // Identification
                entry_text, sl_text, new_sl_text,                                    // Prices (price units)
                vol_text, close_text, r_text, flag_text,                             // Volume (lots), R and state
                ActionName(adj.action), ReasonName(adj.reason),                      // Decision
                val_text, exec_text, ret_text, ok_text,                              // Validation and execution
                msg_text, trace_text);                                               // Message and full trace
      FileClose(handle);                                                             // Close the file
      return true;                                                                   // Row written
     }
  };

//+------------------------------------------------------------------+
