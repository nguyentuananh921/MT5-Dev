//+------------------------------------------------------------------+
//|                                            AdaptiveExitTypes.mqh |
//|                                  Copyright 2026, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2026, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
#property version   "1.00"

//+------------------------------------------------------------------+
//| Constants                                                        |
//+------------------------------------------------------------------+
#define EXIT_PRIORITY_SLOTS   6                       // One priority slot per proposal reason
#define EXIT_MAX_PROPOSALS    8                       // Upper bound of proposals per position per tick
#define EXIT_MAX_POSITIONS    100                     // Capacity of the state and trace tables (positions)

//+------------------------------------------------------------------+
//| Enums                                                            |
//+------------------------------------------------------------------+
// --- Management flags of a position (bit mask, flags can be combined)
enum ENUM_POSITION_FLAG
  {
   PSF_INITIAL_STOP  = 1,                             // Confirmed protective stop exists and 1R is measured
   PSF_BREAKEVEN     = 2,                             // Breakeven stop move confirmed by the broker
   PSF_TRAILING      = 4,                             // At least one trailing stop move confirmed
   PSF_PARTIAL_TAKEN = 8,                             // Partial close filled (fully or partly)
   PSF_CLOSED        = 16                             // Full close confirmed
  };

// --- Action type for an exit proposal (what to do)
enum ENUM_EXIT_ACTION
  {
   EXIT_ACTION_STOP_MODIFICATION,                     // Modify SL/TP only
   EXIT_ACTION_PARTIAL_EXIT,                          // Close a fraction of volume
   EXIT_ACTION_FULL_EXIT                              // Close entire position
  };

// --- Reason why a proposal was generated (why to do it)
enum ENUM_EXIT_REASON
  {
   EXIT_REASON_NONE,                                  // No reason (default, empty priority slot)
   EXIT_REASON_ATR,                                   // Initial stop based on ATR
   EXIT_REASON_STRUCTURE,                             // Initial stop based on market structure
   EXIT_REASON_BREAKEVEN,                             // Breakeven move
   EXIT_REASON_TRAILING,                              // Trailing stop
   EXIT_REASON_PARTIAL,                               // Partial volume close
   EXIT_REASON_TIME                                   // Time-based exit
  };

// --- How the policy engine orders proposals
enum ENUM_PRECEDENCE_MODE
  {
   PRECEDENCE_BY_REASON,                              // Reason priority first, action type breaks ties (default)
   PRECEDENCE_BY_ACTION                               // Action type first (FULL, PARTIAL, STOP), reason breaks ties
  };

// --- Result categories from validation, execution and reconciliation
enum ENUM_EXIT_RESULT
  {
   EXIT_RESULT_OK,                                    // Validation passed, or execution done (DONE)
   EXIT_RESULT_NO_CHANGE,                             // No effective change needed (idempotency)
   EXIT_RESULT_INVALID_PRICE,                         // Price unavailable or level on the wrong side
   EXIT_RESULT_STOP_LEVEL_VIOLATION,                  // Stop closer to price than the stop level
   EXIT_RESULT_FREEZE_LEVEL_VIOLATION,                // Existing SL/TP inside the freeze level
   EXIT_RESULT_INVALID_VOLUME,                        // Volume out of range
   EXIT_RESULT_VOLUME_STEP_VIOLATION,                 // Volume not a multiple of the volume step
   EXIT_RESULT_RISK_REGRESSION,                       // Proposed stop worsens protection
   EXIT_RESULT_NO_EXECUTABLE_CANDIDATE,               // Every ranked candidate was rejected
   EXIT_RESULT_PENDING_CONFIRMATION,                  // Request accepted (PLACED), result not yet visible
   EXIT_RESULT_PARTIAL_FILL,                          // Only part of the volume filled (DONE_PARTIAL)
   EXIT_RESULT_EXECUTION_ERROR                        // Trade operation failed or was rejected
  };

// --- Module-level error codes (why a module produced no proposal)
enum ENUM_EXIT_ERROR
  {
   EXIT_OK,                                           // No error
   EXIT_INVALID_CONFIG,                               // Configuration missing or invalid
   EXIT_NOT_ENOUGH_DATA,                              // Insufficient bars for calculation
   EXIT_SYMBOL_MISMATCH,                              // Position symbol differs from the module symbol
   EXIT_NO_INITIAL_RISK                               // R-based module called before 1R was established
  };

// --- Outcome of comparing a request with the broker-side position
enum ENUM_RECONCILE_OUTCOME
  {
   RECONCILE_CONFIRMED,                               // Broker state shows the requested result
   RECONCILE_PARTIAL,                                 // Broker state shows only part of the result
   RECONCILE_NOT_VISIBLE                              // Broker state does not show the result yet
  };

//+------------------------------------------------------------------+
//| Structures                                                       |
//+------------------------------------------------------------------+
// --- Snapshot of a position at a given moment (transient live data)
struct SPositionSnapshot
  {
   ulong             ticket;                          // Unique position ticket
   string            symbol;                          // Trading symbol (e.g., EURUSD)
   long              magic;                           // Expert Advisor magic number
   ENUM_POSITION_TYPE direction;                      // POSITION_TYPE_BUY or SELL
   double            entry_price;                     // Open price (price units)
   double            current_price;                   // Bid for long, ask for short (price units)
   double            current_sl;                      // Current stop-loss (price units, 0 if none)
   double            current_tp;                      // Current take-profit (price units, 0 if none)
   double            volume;                          // Position volume (lots)
   datetime          open_time;                       // Open time (timestamp)
   double            initial_risk_distance;           // 1R distance |entry - initial SL| (price units)
   double            current_R;                       // Unrealized profit/loss (R-multiple)
   double            max_favorable_R;                 // Highest current R reached (R-multiple)
   uint              flags;                           // ENUM_POSITION_FLAG bits from management state
  };

// --- Persistent management state for a position (stored separately)
struct SManagementState
  {
   ulong             ticket;                          // Position ticket (key for lookup)
   double            initial_risk_distance;           // 1R from a confirmed loss-side stop (price units)
   double            max_favorable_R;                 // Highest R reached (R-multiple)
   uint              flags;                           // ENUM_POSITION_FLAG bits, source of truth for state
   datetime          last_update_time;                // Last state update (timestamp)
   bool              pending;                         // True while a request waits for broker confirmation
   ENUM_EXIT_ACTION  pending_action;                  // Action of the outstanding request
   ENUM_EXIT_REASON  pending_reason;                  // Reason of the outstanding request
   double            pending_sl;                      // Requested stop-loss (price units)
   double            pending_close_volume;            // Requested close volume (lots)
   double            pending_base_volume;             // Position volume when the request was sent (lots)
   datetime          pending_since;                   // Time the request was sent (timestamp)
  };

// --- Proposal generated by an exit module (ranked later by the policy engine)
struct SExitAdjustment
  {
   ulong             ticket;                          // Position ticket to which this proposal applies
   ENUM_EXIT_ACTION  action;                          // Action to perform
   double            proposed_sl;                     // New stop-loss for STOP_MODIFICATION (price units)
   double            proposed_tp;                     // Take-profit to keep for STOP_MODIFICATION (price units)
   double            close_volume;                    // Volume to close for PARTIAL/FULL_EXIT (lots)
   ENUM_EXIT_REASON  reason;                          // Why this proposal was generated
   string            explanation;                     // Human-readable description of the proposal logic
   bool              well_formed;                     // Module-level sanity only, not broker validity
  };

// --- Configuration parameters for the entire engine
struct SExitConfig
  {
   long              magic_number;                    // Magic number of managed positions
   int               atr_period;                      // ATR period for the initial stop (bars)
   double            atr_multiplier_stop;             // ATR multiplier for the initial stop
   int               structural_lookback;             // Closed bars scanned for swings (bars)
   int               pivot_left_bars;                 // Bars to the left of a pivot (bars)
   int               pivot_right_bars;                // Bars to the right of a pivot (bars)
   int               structure_refresh_seconds;       // Swing refresh interval (seconds)
   double            breakeven_R_threshold;           // Current R that triggers breakeven (R-multiple)
   double            breakeven_buffer_points;         // Buffer beyond entry (points)
   double            trailing_activation_R;           // Max favorable R that activates trailing (R-multiple)
   double            trailing_step_points;            // Trailing distance from price (points)
   double            partial_close_fraction;          // Fraction of volume closed (decimal fraction)
   double            partial_exit_R;                  // Max favorable R that triggers partial exit (R-multiple)
   int               time_exit_minutes;               // Maximum lifetime (minutes, 0 = disabled)
   bool              enable_partial_exit;             // Whether partial exit is enabled
   bool              enable_time_exit;                // Whether time-based exit is enabled
   bool              enable_persistence;              // Whether to log to CSV file
   string            persistence_filename;            // CSV filename for logging
   int               position_refresh_ms;             // Minimum time between position scans (milliseconds)
   bool              dry_run;                         // If true, no actual trade operations are executed
   double            min_effective_sl_change;         // Minimum effective SL change (points)
   int               max_deviation_points;            // Allowed slippage for market closes (points)
   int               pending_timeout_seconds;         // Wait for broker confirmation (seconds)
   ENUM_PRECEDENCE_MODE precedence_mode;              // How proposals are ordered
   ENUM_EXIT_REASON  priority[EXIT_PRIORITY_SLOTS];   // Reason priority list (index 0 = highest)
   int               test_stop_level_points;          // Synthetic stop level for tests (points, 0 = real)
   int               test_freeze_level_points;        // Synthetic freeze level for tests (points, 0 = real)
  };

// --- Result of an execution attempt
struct SExitResult
  {
   bool              success;                         // True if the request was accepted or simulated
   uint              retcode;                         // Raw trade server return code (0 in dry-run)
   double            final_sl;                        // Expected stop-loss after the operation (price units)
   double            final_tp;                        // Expected take-profit after the operation (price units)
   double            final_volume;                    // Expected remaining volume (lots)
   ENUM_EXIT_REASON  final_reason;                    // Reason that led to this result
   ENUM_EXIT_RESULT  result_code;                     // OK, PARTIAL_FILL, PENDING_CONFIRMATION or an error
   string            decision_trace;                  // Full decision trace (for logging)
   string            error_message;                   // Human-readable message
  };

// --- For decision trace storage (used by ExplainDecision)
struct SDecisionRecord
  {
   ulong             ticket;                          // Position ticket
   string            trace;                           // Stored decision trace
   datetime          timestamp;                       // When the trace was stored (timestamp)
  };

//+------------------------------------------------------------------+
//| PositionFlagsToString - readable list of management flags        |
//+------------------------------------------------------------------+
string PositionFlagsToString(uint flags)
  {
   if(flags == 0)                                     // No flag set yet
      return "NEW";                                   // Position not managed yet
   string s = "";                                     // Accumulated flag names
   if((flags & PSF_INITIAL_STOP) != 0)                // Initial stop confirmed
      s += "INITIAL_STOP|";                           // Append flag name
   if((flags & PSF_BREAKEVEN) != 0)                   // Breakeven confirmed
      s += "BREAKEVEN|";                              // Append flag name
   if((flags & PSF_TRAILING) != 0)                    // Trailing confirmed
      s += "TRAILING|";                               // Append flag name
   if((flags & PSF_PARTIAL_TAKEN) != 0)               // Partial close filled
      s += "PARTIAL_TAKEN|";                          // Append flag name
   if((flags & PSF_CLOSED) != 0)                      // Full close confirmed
      s += "CLOSED|";                                 // Append flag name
   return StringSubstr(s, 0, StringLen(s) - 1);       // Drop the trailing separator
  }

//+------------------------------------------------------------------+
//| ReasonName - reason without the enum prefix (for traces)         |
//+------------------------------------------------------------------+
string ReasonName(ENUM_EXIT_REASON r)
  {
   string s = EnumToString(r);                        // Full enum name
   StringReplace(s, "EXIT_REASON_", "");              // Remove prefix
   return s;                                          // Short name
  }

//+------------------------------------------------------------------+
//| ActionName - action without the enum prefix (for traces)         |
//+------------------------------------------------------------------+
string ActionName(ENUM_EXIT_ACTION a)
  {
   string s = EnumToString(a);                        // Full enum name
   StringReplace(s, "EXIT_ACTION_", "");              // Remove prefix
   return s;                                          // Short name
  }

//+------------------------------------------------------------------+
//| ResultName - result without the enum prefix (for traces)         |
//+------------------------------------------------------------------+
string ResultName(ENUM_EXIT_RESULT r)
  {
   string s = EnumToString(r);                        // Full enum name
   StringReplace(s, "EXIT_RESULT_", "");              // Remove prefix
   return s;                                          // Short name
  }

//+------------------------------------------------------------------+
//| ExitSymbolDigits - digits of a symbol (chart digits fallback)    |
//+------------------------------------------------------------------+
int ExitSymbolDigits(string symbol)
  {
   long d = SymbolInfoInteger(symbol, SYMBOL_DIGITS); // Digits of the given symbol
   return (d > 0) ? (int)d : _Digits;                 // Fallback to chart digits
  }

//+------------------------------------------------------------------+
//| ExitSymbolPoint - point of a symbol (chart point fallback)       |
//+------------------------------------------------------------------+
double ExitSymbolPoint(string symbol)
  {
// --- _Point refers to the chart symbol, so modules use the position symbol point instead
   double p = SymbolInfoDouble(symbol, SYMBOL_POINT); // Point of the given symbol (price units)
   return (p > 0) ? p : _Point;                       // Fallback to chart point
  }

//+------------------------------------------------------------------+
//| SetDefaultPriority - fill all six priority slots                 |
//+------------------------------------------------------------------+
void SetDefaultPriority(SExitConfig &config)
  {
   config.priority[0] = EXIT_REASON_TIME;             // Highest priority: maximum lifetime
   config.priority[1] = EXIT_REASON_PARTIAL;          // Second: scaling out
   config.priority[2] = EXIT_REASON_BREAKEVEN;        // Third: protecting entry
   config.priority[3] = EXIT_REASON_TRAILING;         // Fourth: trailing
   config.priority[4] = EXIT_REASON_STRUCTURE;        // Fifth: initial stop from structure
   config.priority[5] = EXIT_REASON_ATR;              // Lowest: initial stop from ATR
  }

//+------------------------------------------------------------------+
