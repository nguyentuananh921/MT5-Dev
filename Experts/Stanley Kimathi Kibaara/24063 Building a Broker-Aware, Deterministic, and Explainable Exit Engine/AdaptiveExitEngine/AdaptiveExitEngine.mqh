//+------------------------------------------------------------------+
//|                                           AdaptiveExitEngine.mqh |
//|                                  Copyright 2026, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2026, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
#property version   "1.00"

// --- Include all required modules
#include "AdaptiveExitTypes.mqh"                                                            // Shared types and structures
#include "PositionTracker.mqh"                                                              // Position snapshot provider
#include "ATRStopCalculator.mqh"                                                            // ATR initial stop proposals
#include "StructureAwareAdjuster.mqh"                                                       // Pivot-based initial stop proposals
#include "TrailingStopManager.mqh"                                                          // Trailing stop proposals
#include "BreakevenController.mqh"                                                          // Breakeven stop proposals
#include "PartialExitController.mqh"                                                        // Partial close proposals
#include "CTimeExitController.mqh"                                                          // Time-based full exit proposals
#include "ExitPolicyEngine.mqh"                                                             // Deterministic ranking of proposals
#include "ExitValidator.mqh"                                                                // Broker/risk validation of one candidate
#include "ExitExecutionAdapter.mqh"                                                         // The only component that sends orders
#include "ExitPersistence.mqh"                                                              // CSV logging for audit trail

//+------------------------------------------------------------------+
//| Adaptive Exit Engine - orchestration facade                      |
//+------------------------------------------------------------------+
class CAdaptiveExitEngine
  {
private:
   // --- Configuration and component members
   SExitConfig           m_config;                                                          // Engine configuration
   CPositionTracker      m_tracker;                                                         // Fetches live position snapshots
   CATRStopCalculator    m_atr;                                                             // ATR initial stop proposals
   CStructureAwareAdjuster m_structure;                                                     // Structure initial stop proposals
   CTrailingStopManager  m_trail;                                                           // Trailing stop proposals
   CBreakevenController  m_breakeven;                                                       // Breakeven stop proposals
   CPartialExitController m_partial;                                                        // Partial close proposals
   CTimeExitController   m_timeExit;                                                        // Time-based full exit proposals
   CExitPolicyEngine     m_policy;                                                          // Ranks conflicting proposals
   CExitValidator        m_validator;                                                       // Validates candidates against broker/risk rules
   CExitExecutionAdapter m_executor;                                                        // Sends validated requests
   CExitPersistence      m_persistence;                                                     // Logs all decisions to CSV

   // --- Persistent management state (per position)
   SManagementState      m_states[EXIT_MAX_POSITIONS];                                      // States for up to 100 positions
   int                   m_state_count;                                                     // Number of active management states

   // --- Decision trace storage for ExplainDecision()
   SDecisionRecord       m_records[EXIT_MAX_POSITIONS];                                     // Last decision trace per position
   int                   m_record_count;                                                    // Number of stored traces

   bool                  m_test_mode;                                                       // Skip terminal queries and simulate outcomes
   bool                  m_test_force_exec_failure;                                         // Test hook: simulate a broker rejection

   // --- Find the management state of a ticket (-1 if not managed)
   int               FindState(ulong ticket)
     {
      for(int i = 0; i < m_state_count; i++)                                                // Every stored state
         if(m_states[i].ticket == ticket)                                                   // Ticket matches
            return i;                                                                       // Index of the state
      return -1;                                                                            // Not managed
     }

   // --- True if sl is a protective stop on the loss side of entry
   static bool       IsLossSideStop(SPositionSnapshot &pos, double sl)
     {
      if(sl <= 0)                                                                           // No stop at all
         return false;                                                                      // Not protective
      if(pos.direction == POSITION_TYPE_BUY)                                                // Long position
         return sl < pos.entry_price;                                                       // Stop below entry
      return sl > pos.entry_price;                                                          // Short: stop above entry
     }

   // --- Create the state of a new position; an existing loss-side stop defines 1R at once
   int               CreateState(SPositionSnapshot &pos)
     {
      if(m_state_count >= EXIT_MAX_POSITIONS)                                               // Table full
        {
         Print("Management state limit reached.");                                          // Warn about limit
         return -1;                                                                         // No state created
        }
      SManagementState st;                                                                  // New state
      ZeroMemory(st);                                                                       // No flags, not pending
      st.ticket = pos.ticket;                                                               // Position ticket
      st.last_update_time = TimeCurrent();                                                  // Creation time (timestamp)
      if(IsLossSideStop(pos, pos.current_sl))                                               // Entry logic already set a stop
        {
         st.initial_risk_distance = MathAbs(pos.entry_price - pos.current_sl);              // 1R (price units)
         st.flags |= PSF_INITIAL_STOP;                                                      // Initial stop established
        }
      m_states[m_state_count] = st;                                                         // Store the state
      m_state_count++;                                                                      // One more state
      return m_state_count - 1;                                                             // Index of the new state
     }

   // --- Remove the state of a closed position
   void              RemoveState(ulong ticket)
     {
      for(int i = 0; i < m_state_count; i++)                                                // Every stored state
         if(m_states[i].ticket == ticket)                                                   // Ticket matches
           {
            for(int j = i; j < m_state_count - 1; j++)                                      // Shift later entries left
               m_states[j] = m_states[j+1];                                                 // Move one entry
            m_state_count--;                                                                // One state less
            return;                                                                         // Done
           }
     }

   // --- Store the last trace of a ticket; the oldest record is replaced when the table is full
   void              StoreDecisionTrace(ulong ticket, string trace)
     {
      for(int i = 0; i < m_record_count; i++)                                               // Existing records
         if(m_records[i].ticket == ticket)                                                  // Ticket already has a record
           {
            m_records[i].trace = trace;                                                     // Replace trace
            m_records[i].timestamp = TimeCurrent();                                         // Update time (timestamp)
            return;                                                                         // Done
           }
      int slot = m_record_count;                                                            // Next free slot
      if(m_record_count >= EXIT_MAX_POSITIONS)                                              // Table full
        {
         slot = 0;                                                                          // Search the oldest record
         for(int i = 1; i < m_record_count; i++)                                            // Every record
            if(m_records[i].timestamp < m_records[slot].timestamp)                          // Older record found
               slot = i;                                                                    // Remember it
        }
      else                                                                                  // Free slot available
         m_record_count++;                                                                  // One more record
      m_records[slot].ticket = ticket;                                                      // Ticket
      m_records[slot].trace = trace;                                                        // Trace
      m_records[slot].timestamp = TimeCurrent();                                            // Time (timestamp)
     }

   // --- Read a position directly from the terminal (bypasses the tracker cache)
   bool              RefreshPositionSnapshot(ulong ticket, SPositionSnapshot &snap)
     {
      if(m_test_mode)                                                                       // Test mode has no terminal data
         return false;                                                                      // Not available
      return m_tracker.GetPositionByTicket(ticket, snap, true);                             // Forced refresh
     }

   // --- Copy persistent fields into the snapshot and update R; R stays 0 while 1R is unknown
   void              RefreshRMetrics(int idx, SPositionSnapshot &pos)
     {
      double risk = m_states[idx].initial_risk_distance;                                    // 1R (price units)
      bool has_stop = ((m_states[idx].flags & PSF_INITIAL_STOP) != 0);                      // Initial stop confirmed
      pos.current_R = 0.0;                                                                  // Default: R unknown
      if(has_stop && risk > 0)                                                              // 1R established
        {
         if(pos.direction == POSITION_TYPE_BUY)                                             // Long position
            pos.current_R = (pos.current_price - pos.entry_price) / risk;                   // Profit in R
         else                                                                               // Short position
            pos.current_R = (pos.entry_price - pos.current_price) / risk;                   // Profit in R
         if(pos.current_R > m_states[idx].max_favorable_R)                                  // New best R
            m_states[idx].max_favorable_R = pos.current_R;                                  // Persist it
        }
      pos.initial_risk_distance = risk;                                                     // Copy 1R (price units)
      pos.max_favorable_R = m_states[idx].max_favorable_R;                                  // Copy max favorable R
      pos.flags = m_states[idx].flags;                                                      // Copy flags
     }

   // --- Compare an existing broker-side position with the request that was sent
   ENUM_RECONCILE_OUTCOME CheckOutcome(ENUM_EXIT_ACTION action, double req_sl, double close_volume, double base_volume, SPositionSnapshot &actual)
     {
      double tick = SymbolInfoDouble(actual.symbol, SYMBOL_TRADE_TICK_SIZE);                // Tick size (price units)
      if(tick <= 0)                                                                         // Tick size not available
         tick = ExitSymbolPoint(actual.symbol);                                             // Use the point instead
      double vstep = SymbolInfoDouble(actual.symbol, SYMBOL_VOLUME_STEP);                   // Volume step (lots)
      double veps = (vstep > 0) ? vstep * 0.5 : 1e-8;                                       // Volume tolerance, half a step (lots)
      double expected_left = base_volume - close_volume;                                    // Volume expected after a close (lots)
      bool reduced = (actual.volume < base_volume - veps);                                  // Some volume was closed

      if(action == EXIT_ACTION_STOP_MODIFICATION)                                           // Stop modification
        {
         bool same_sl = (MathAbs(actual.current_sl - req_sl) <= tick * 0.5);                // Within half a tick
         return same_sl ? RECONCILE_CONFIRMED : RECONCILE_NOT_VISIBLE;                      // Stop visible or not
        }
      if(action == EXIT_ACTION_PARTIAL_EXIT)                                                // Partial close
        {
         if(actual.volume <= expected_left + veps)                                          // Requested volume closed
            return RECONCILE_CONFIRMED;                                                     // Confirmed
         return reduced ? RECONCILE_PARTIAL : RECONCILE_NOT_VISIBLE;                        // Part closed or nothing
        }
      return reduced ? RECONCILE_PARTIAL : RECONCILE_NOT_VISIBLE;                           // Full close, position still exists
     }

   // --- Apply a confirmed or partial outcome; the only place where flags change and 1R is set
   string            ApplyOutcome(int idx, ENUM_EXIT_ACTION action, ENUM_EXIT_REASON reason, ENUM_RECONCILE_OUTCOME outcome, SPositionSnapshot &actual)
     {
      int digits = ExitSymbolDigits(actual.symbol);                                         // Digits of the symbol
      string vol_text = DoubleToString(actual.volume, 2);                                   // Volume as text (lots)
      string d = "";                                                                        // Description for the trace
      m_states[idx].last_update_time = TimeCurrent();                                       // Update time (timestamp)

      if(action == EXIT_ACTION_STOP_MODIFICATION)                                           // Stop modification confirmed
        {
         d = "SL " + DoubleToString(actual.current_sl, digits) + " confirmed";              // Describe the stop
         bool first_stop = ((m_states[idx].flags & PSF_INITIAL_STOP) == 0);                 // 1R not established yet
         if(first_stop && IsLossSideStop(actual, actual.current_sl))                        // Confirmed loss-side stop
           {
            double risk = MathAbs(actual.entry_price - actual.current_sl);                  // 1R (price units)
            m_states[idx].initial_risk_distance = risk;                                     // Establish 1R
            m_states[idx].flags |= PSF_INITIAL_STOP;                                        // Initial stop established
            d += "; 1R established = " + DoubleToString(risk, digits);                      // Describe 1R
           }
         else
            if(first_stop)                                                                // Stop is not on the loss side
               d += "; not a loss-side stop, 1R not established";                              // Describe why
         if(reason == EXIT_REASON_BREAKEVEN)                                                // Breakeven move
            m_states[idx].flags |= PSF_BREAKEVEN;                                           // Breakeven done
         if(reason == EXIT_REASON_TRAILING)                                                 // Trailing move
            m_states[idx].flags |= PSF_TRAILING;                                            // Trailing active
         return d;                                                                          // Description
        }

      if(action == EXIT_ACTION_PARTIAL_EXIT)                                                // Partial close filled
        {
         m_states[idx].flags |= PSF_PARTIAL_TAKEN;                                          // Partial close taken
         bool full = (outcome == RECONCILE_CONFIRMED);                                      // Whole request filled
         d = full ? "partial close confirmed" : "partial close only partly filled";         // Describe fill
         return d + " (volume now " + vol_text + ")";                                       // Description
        }

      if(outcome == RECONCILE_CONFIRMED)                                                    // Full close, position gone
        {
         m_states[idx].flags |= PSF_CLOSED;                                                 // Position closed
         return "position closed";                                                          // Description
        }
      string rest = "full close only partly filled (volume now " + vol_text + ")";          // Partial fill
      return rest + ", re-evaluated next tick";                                             // Description
     }

   // --- Remember a request that was accepted but whose result is not visible yet
   void              SetPending(int idx, SExitAdjustment &req, double base_volume)
     {
      m_states[idx].pending = true;                                                         // Request outstanding
      m_states[idx].pending_action = req.action;                                            // Action
      m_states[idx].pending_reason = req.reason;                                            // Reason
      m_states[idx].pending_sl = req.proposed_sl;                                           // Requested SL (price units)
      m_states[idx].pending_close_volume = req.close_volume;                                // Requested close volume (lots)
      m_states[idx].pending_base_volume = base_volume;                                      // Volume when sent (lots)
      m_states[idx].pending_since = TimeCurrent();                                          // Send time (timestamp)
     }

   // --- Forget the outstanding request
   void              ClearPending(int idx)
     {
      m_states[idx].pending = false;                                                        // No request outstanding
     }

   // --- Append a proposal to the list
   void              Append(SExitAdjustment &list[], SExitAdjustment &p)
     {
      int size = ArraySize(list);                                                           // Current size
      ArrayResize(list, size + 1, EXIT_MAX_PROPOSALS);                                      // Reserve avoids reallocation
      list[size] = p;                                                                       // Append
     }

   // --- Trace line for a module that reported an error
   string            ModuleNote(string module, ENUM_EXIT_ERROR err)
     {
      if(err == EXIT_OK)                                                                    // No error
         return "";                                                                         // Nothing to report
      return "  - " + module + ": no proposal (" + EnumToString(err) + ")\n";               // Error line
     }

   // --- Collect proposals from all eligible modules and return their number
   int               CollectProposals(SPositionSnapshot &pos, SExitAdjustment &list[], string &notes)
     {
      ArrayResize(list, 0, EXIT_MAX_PROPOSALS);                                             // Start empty
      notes = "";                                                                           // No notes yet
      ENUM_EXIT_ERROR err = EXIT_OK;                                                        // Module error
      SExitAdjustment p;                                                                    // Proposal buffer

      if((pos.flags & PSF_INITIAL_STOP) == 0)                                               // No confirmed stop yet
        {
         // --- Only initial-stop modules run, R-based modules need 1R
         if(m_atr.GenerateProposal(pos, p, err))                                            // ATR initial stop
           {
            Append(list, p);                                                                // Append ATR proposal
            double atr_stop = p.proposed_sl;                                                // ATR stop passed explicitly
            SExitAdjustment sp;                                                             // Structure proposal
            if(m_structure.GenerateProposal(pos, atr_stop, sp, err))                        // Structure stop if tighter
               Append(list, sp);                                                            // Append structure proposal
            else                                                                            // No structure proposal
               notes += ModuleNote("STRUCTURE", err);                                       // Report error, if any
           }
         else                                                                               // No ATR proposal
            notes += ModuleNote("ATR", err);                                                // Report error
         notes += "  - BREAKEVEN/TRAILING/PARTIAL: not evaluated (1R not established)\n";   // Explain skip
        }
      else                                                                                  // 1R established
        {
         if(m_breakeven.GenerateProposal(pos, p, err))                                      // Breakeven
            Append(list, p);                                                                // Append proposal
         else                                                                               // No proposal
            notes += ModuleNote("BREAKEVEN", err);                                          // Report error, if any
         if(m_trail.GenerateProposal(pos, p, err))                                          // Trailing
            Append(list, p);                                                                // Append proposal
         else                                                                               // No proposal
            notes += ModuleNote("TRAILING", err);                                           // Report error, if any
         if(m_partial.GenerateProposal(pos, p, err))                                        // Partial close
            Append(list, p);                                                                // Append proposal
         else                                                                               // No proposal
            notes += ModuleNote("PARTIAL", err);                                            // Report error, if any
        }

      if(m_timeExit.GenerateProposal(pos, p, err))                                          // Time exit, always evaluated
         Append(list, p);                                                                   // Append proposal
      else                                                                                  // No proposal
         notes += ModuleNote("TIME", err);                                                  // Report error, if any
      return ArraySize(list);                                                               // Number of proposals
     }

   // --- Print a multi-line trace line by line
   void              PrintTrace(string trace)
     {
      string lines[];                                                                       // Trace lines
      int n = StringSplit(trace, '\n', lines);                                              // Split at line breaks
      for(int i = 0; i < n; i++)                                                            // Every line
         if(lines[i] != "")                                                                 // Skip empty lines
            Print(lines[i]);                                                                // Print one line
     }

   // --- Header lines of a decision trace
   string            TraceHeader(SPositionSnapshot &pos)
     {
      int digits = ExitSymbolDigits(pos.symbol);                                            // Digits of the symbol
      string dir = (pos.direction == POSITION_TYPE_BUY) ? "BUY" : "SELL";                   // Direction text
      string h = "Ticket: " + IntegerToString((long)pos.ticket);                            // Ticket
      h += " | " + pos.symbol + " " + dir;                                                  // Symbol and direction
      h += " | entry " + DoubleToString(pos.entry_price, digits);                           // Entry price
      h += " SL " + DoubleToString(pos.current_sl, digits);                                 // Current stop
      h += " price " + DoubleToString(pos.current_price, digits);                           // Current price
      h += " | volume " + DoubleToString(pos.volume, 2) + "\n";                             // Volume (lots)
      string one_r = "not established";                                                     // 1R text when unknown
      if(pos.initial_risk_distance > 0)                                                     // 1R known
         one_r = DoubleToString(pos.initial_risk_distance, digits);                         // 1R (price units)
      h += "R: " + DoubleToString(pos.current_R, 2);                                        // Current R
      h += " (max " + DoubleToString(pos.max_favorable_R, 2);                               // Max favorable R
      h += ", 1R = " + one_r + ")";                                                         // 1R distance
      h += " | Flags: " + PositionFlagsToString(pos.flags) + "\n";                          // Management flags
      return h;                                                                             // Header text
     }

public:
   // --- Validate ranked candidates in order and return the index of the first that passes (-1 if none)
   int               SelectFirstExecutable(SPositionSnapshot &pos, SExitAdjustment &ranked[], int n, SExitAdjustment &validated, ENUM_EXIT_RESULT &last_result, string &trace)
     {
      trace = "Validation:\n";                                                              // Section header
      last_result = EXIT_RESULT_NO_EXECUTABLE_CANDIDATE;                                    // Default result
      for(int k = 0; k < n; k++)                                                            // Candidates in rank order
        {
         SExitAdjustment v;                                                                 // Validated candidate
         string expl = "";                                                                  // Validator explanation
         ENUM_EXIT_RESULT r = m_validator.Validate(pos, ranked[k], v, expl);                // Validate this candidate
         string name = ReasonName(ranked[k].reason) + " " + ActionName(ranked[k].action);   // Candidate name
         trace += "  #" + IntegerToString(k + 1) + " " + name;                              // Candidate number and name
         trace += " -> " + ResultName(r) + ": " + expl + "\n";                              // Verdict
         last_result = r;                                                                   // Remember last verdict
         if(r != EXIT_RESULT_OK)                                                            // Rejected or no change
            continue;                                                                       // Try the next candidate
         validated = v;                                                                     // Broker-ready request
         if(k + 1 < n)                                                                      // Lower-ranked candidates remain
           {
            string from_k = IntegerToString(k + 2);                                         // First skipped candidate
            string to_k = IntegerToString(n);                                               // Last skipped candidate
            trace += "  #" + from_k + "..#" + to_k + " not validated\n";                    // Note
           }
         return k;                                                                          // Selected index
        }
      return -1;                                                                            // No candidate passed
     }

private:
   // --- Reconcile an outstanding request; returns false when the position must wait this tick
   bool              ReconcilePending(int idx, SPositionSnapshot &pos, string &trace)
     {
      if(!m_states[idx].pending)                                                            // Nothing outstanding
         return true;                                                                       // Continue normally
      ENUM_EXIT_ACTION act = m_states[idx].pending_action;                                  // Pending action
      ENUM_EXIT_REASON why = m_states[idx].pending_reason;                                  // Pending reason
      string what = ReasonName(why) + " " + ActionName(act);                                // Request name
      double sl = m_states[idx].pending_sl;                                                 // Requested SL (price units)
      double vol = m_states[idx].pending_close_volume;                                      // Requested close volume (lots)
      double base = m_states[idx].pending_base_volume;                                      // Volume when sent (lots)
      ENUM_RECONCILE_OUTCOME o = CheckOutcome(act, sl, vol, base, pos);                     // Compare with broker state

      if(o != RECONCILE_NOT_VISIBLE)                                                        // Result now visible
        {
         string d = ApplyOutcome(idx, act, why, o, pos);                                    // Apply the outcome
         ClearPending(idx);                                                                 // Request settled
         RefreshRMetrics(idx, pos);                                                         // Re-read R with the new state
         trace += "Reconciliation: pending " + what + " -> " + d + "\n";                    // Trace
         return true;                                                                       // Continue normally
        }

      long waited = (long)(TimeCurrent() - m_states[idx].pending_since);                    // Time since sending (seconds)
      if(waited < m_config.pending_timeout_seconds)                                         // Still within timeout
        {
         // --- No new request is sent until the previous one is visible or times out (idempotency)
         trace += "Reconciliation: awaiting broker confirmation of " + what;                // Trace
         trace += " (sent " + IntegerToString(waited) + "s ago), no new request.\n";        // Trace
         return false;                                                                      // Wait this tick
        }
      ClearPending(idx);                                                                    // Timeout passed
      trace += "Reconciliation: pending " + what;                                           // Trace
      trace += " not visible after timeout, re-evaluating.\n";                              // Trace
      return true;                                                                          // Continue normally
     }

   // --- Reconcile the request that was just executed; state changes only on a confirmed outcome
   string            ReconcileExecution(int idx, SPositionSnapshot &pos, SExitAdjustment &validated, SExitResult &exec)
     {
      if(!exec.success)                                                                     // Request not accepted
         return "Reconciliation: request not accepted, management state unchanged.\n";      // No change

      if(m_config.dry_run || m_test_mode)                                                   // No broker: simulate the result
        {
         SPositionSnapshot sim;                                                             // Simulated position
         sim = pos;                                                                         // Start from the fresh snapshot
         if(validated.action == EXIT_ACTION_STOP_MODIFICATION)                              // Stop modification
            sim.current_sl = validated.proposed_sl;                                         // Simulated SL (price units)
         else                                                                               // Partial or full close
            sim.volume = MathMax(0.0, pos.volume - validated.close_volume);                 // Simulated volume (lots)
         ENUM_EXIT_ACTION sim_act = validated.action;                                       // Executed action
         string d = ApplyOutcome(idx, sim_act, validated.reason, RECONCILE_CONFIRMED, sim); // Apply
         return "Reconciliation (simulated): " + d + "\n";                                  // Trace
        }

      SPositionSnapshot actual;                                                             // Position after execution
      bool exists = RefreshPositionSnapshot(pos.ticket, actual);                            // Real refresh
      ENUM_EXIT_ACTION act = validated.action;                                              // Executed action
      double sl = validated.proposed_sl;                                                    // Requested SL (price units)
      double vol = validated.close_volume;                                                  // Requested close volume (lots)
      ENUM_RECONCILE_OUTCOME o = RECONCILE_NOT_VISIBLE;                                     // Reconciliation outcome
      if(!exists && act == EXIT_ACTION_FULL_EXIT)                                           // Position gone after full close
         o = RECONCILE_CONFIRMED;                                                           // Close confirmed
      if(exists)                                                                            // Position still exists
         o = CheckOutcome(act, sl, vol, pos.volume, actual);                                // Compare with the request

      if(o == RECONCILE_NOT_VISIBLE)                                                        // Not visible yet (e.g. PLACED)
        {
         SetPending(idx, validated, pos.volume);                                            // Wait for confirmation
         string code = ResultName(exec.result_code);                                        // Execution result name
         string timeout = IntegerToString(m_config.pending_timeout_seconds);                // Timeout (seconds)
         string msg = "Reconciliation: " + code + " not yet visible";                       // Trace
         return msg + ", marked PENDING (timeout " + timeout + "s).\n";                     // Trace
        }
      string d;                                                                             // Outcome description
      if(exists)                                                                            // Use the refreshed position
         d = ApplyOutcome(idx, validated.action, validated.reason, o, actual);              // Apply
      else                                                                                  // Position gone after full close
         d = ApplyOutcome(idx, validated.action, validated.reason, o, pos);                 // Apply
      return "Reconciliation: " + d + "\n";                                                 // Trace
     }

   // --- Process a single position through the entire decision pipeline
   void              ProcessPosition(SPositionSnapshot &cached, int idx)
     {
      // --- One fresh snapshot is used for proposals, validation and execution
      SPositionSnapshot pos;                                                                // Fresh snapshot
      if(m_test_mode)                                                                       // Test mode
         pos = cached;                                                                      // Use the passed snapshot
      else
         if(!RefreshPositionSnapshot(cached.ticket, pos))                                   // Forced terminal refresh
            return;                                                                         // Closed between scan and now
      RefreshRMetrics(idx, pos);                                                            // Copy state and update R
      if((pos.flags & PSF_CLOSED) != 0)                                                     // Already closed
         return;                                                                            // Nothing to do

      string trace = TraceHeader(pos);                                                      // Start the decision trace
      if(!ReconcilePending(idx, pos, trace))                                                // Waiting for broker confirmation
        {
         StoreDecisionTrace(pos.ticket, trace);                                             // Keep the trace
         return;                                                                            // Nothing new this tick
        }

      // --- Proposals and deterministic ranking
      SExitAdjustment proposals[];                                                          // Module proposals
      string notes;                                                                         // Modules without proposal
      int count = CollectProposals(pos, proposals, notes);                                  // Collect proposals
      SExitAdjustment ranked[];                                                             // Ranked candidates
      string rank_trace;                                                                    // Candidate section
      int n = m_policy.Rank(pos, proposals, count, ranked, rank_trace);                     // Rank all proposals
      trace += rank_trace;                                                                  // Append candidates
      if(notes != "")                                                                       // Some modules gave no proposal
         trace += "Modules without proposal:\n" + notes;                                    // Append notes
      if(n == 0)                                                                            // Nothing to do
        {
         trace += "Selected: none (no proposals)\n";                                        // Trace
         StoreDecisionTrace(pos.ticket, trace);                                             // Keep the trace
         return;                                                                            // Done
        }

      // --- Validation in rank order with fallback to the next candidate
      SExitAdjustment validated;                                                            // Broker-ready request
      ENUM_EXIT_RESULT vres;                                                                // Last validation result
      string val_trace;                                                                     // Validation section
      int chosen = SelectFirstExecutable(pos, ranked, n, validated, vres, val_trace);       // First that passes
      trace += val_trace;                                                                   // Append verdicts
      if(chosen < 0)                                                                        // No candidate passed
        {
         trace += "Selected: none, no candidate passed validation\n";                       // Trace
         if(m_config.enable_persistence)                                                    // Log if enabled
           {
            SExitResult none;                                                               // Result for the log
            ZeroMemory(none);                                                               // Clear all fields
            none.result_code = EXIT_RESULT_NO_EXECUTABLE_CANDIDATE;                         // Nothing executable
            none.final_reason = EXIT_REASON_NONE;                                           // No reason
            none.error_message = "No candidate passed validation";                          // Message
            none.decision_trace = trace;                                                    // Full trace
            m_persistence.LogDecision(pos, ranked[0], vres, none);                          // Log the top candidate
           }
         StoreDecisionTrace(pos.ticket, trace);                                             // Keep the trace
         return;                                                                            // Done
        }
      string sel = ReasonName(validated.reason) + " " + ActionName(validated.action);       // Selected name
      trace += "Selected: #" + IntegerToString(chosen + 1) + " " + sel + "\n";              // Trace

      // --- Execution (test mode never sends real orders)
      bool simulate = (m_config.dry_run || m_test_mode);                                    // Simulation flag
      SExitResult exec = m_executor.Execute(pos, validated, simulate);                      // Execute or simulate
      if(m_test_mode && m_test_force_exec_failure)                                          // Test hook: simulated rejection
        {
         exec.success = false;                                                              // Not accepted
         exec.retcode = TRADE_RETCODE_REJECT;                                               // Rejected by the simulated broker
         exec.result_code = EXIT_RESULT_EXECUTION_ERROR;                                    // Execution error
         exec.error_message = "Test hook: request rejected by simulated broker";            // Message
        }
      trace += "Execution: " + exec.error_message + "\n";                                   // Trace
      trace += ReconcileExecution(idx, pos, validated, exec);                               // Reconcile with broker state
      trace += "Flags after: " + PositionFlagsToString(m_states[idx].flags) + "\n";         // Trace

      // --- Persist and store the trace
      exec.decision_trace = trace;                                                          // Attach full trace
      if(m_config.enable_persistence)                                                       // Log if enabled
         m_persistence.LogDecision(pos, validated, vres, exec);                             // CSV row
      StoreDecisionTrace(pos.ticket, trace);                                                // Keep the trace
      if(m_config.dry_run && !m_test_mode)                                                  // Dry-run output
         PrintTrace("== DRY RUN TRACE ==\n" + trace + "== END DRY RUN ==");                 // Journal
     }

public:
   // --- Constructor - initializes all components with the given config
                     CAdaptiveExitEngine(SExitConfig &config)
      :              m_tracker(Symbol(), config.magic_number,                               // Position tracker: symbol, magic
                               config.position_refresh_ms),                                 // and scan interval (milliseconds)
                     m_atr(Symbol(), PERIOD_CURRENT,                                        // ATR calculator: chart symbol
                           config.atr_period, config.atr_multiplier_stop),                  // ATR period (bars) and multiplier
                     m_structure(Symbol(), config.structural_lookback,                      // Structure: symbol, lookback (bars)
                                 config.pivot_left_bars,                                    // Left pivot bars
                                 config.pivot_right_bars,                                   // Right pivot bars
                                 config.structure_refresh_seconds),                         // Refresh interval (seconds)
                     m_trail(config.trailing_activation_R,                                  // Trailing: activation (R-multiple)
                             config.trailing_step_points),                                  // and step (points)
                     m_breakeven(config.breakeven_R_threshold,                              // Breakeven: threshold (R-multiple)
                                 config.breakeven_buffer_points),                           // and buffer (points)
                     m_partial(config.partial_exit_R,                                       // Partial exit: trigger (R-multiple)
                               config.partial_close_fraction,                               // fraction (decimal fraction)
                               config.enable_partial_exit),                                 // and enabled flag
                     m_timeExit(config.time_exit_minutes,                                   // Time exit: lifetime (minutes)
                                config.enable_time_exit),                                   // and enabled flag
                     m_policy(config),                                                      // Policy engine
                     m_validator(config),                                                   // Validator
                     m_executor(config.max_deviation_points),                               // Execution adapter
                     m_persistence(config.persistence_filename)                             // Persistence
     {
      m_config = config;                                                                    // Store configuration
      m_state_count = 0;                                                                    // No states initially
      m_record_count = 0;                                                                   // No records initially
      m_test_mode = false;                                                                  // Production mode
      m_test_force_exec_failure = false;                                                    // No simulated rejection
      string w = m_policy.ConfigWarnings();                                                 // Check the priority list
      if(w != "")                                                                           // Missing or duplicated reasons
         Print("AdaptiveExitEngine priority configuration: ", w);                           // Report them
     }

   // --- Destructor: nothing to clean up manually
                    ~CAdaptiveExitEngine() {}

   // --- Main tick handler: called from the EA OnTick
   void              OnTick()
     {
      SPositionSnapshot snapshots[];                                                        // Current positions
      if(!m_tracker.GetPositions(snapshots))                                                // Read positions
        {
         Print("Position tracker failed");                                                  // Report failure
         return;                                                                            // Try next tick
        }

      for(int i = 0; i < ArraySize(snapshots); i++)                                         // Every managed position
        {
         int idx = FindState(snapshots[i].ticket);                                          // Find state
         if(idx < 0)                                                                        // New position
            idx = CreateState(snapshots[i]);                                                // Create state
         if(idx < 0)                                                                        // Table full
            continue;                                                                       // Skip position
         ProcessPosition(snapshots[i], idx);                                                // Run the pipeline
        }

      // --- Remove the state of positions that no longer exist
      for(int i = m_state_count - 1; i >= 0; i--)                                           // Every state, backwards
        {
         bool found = false;                                                                // Position still open
         for(int j = 0; j < ArraySize(snapshots); j++)                                      // Search open positions
            if(m_states[i].ticket == snapshots[j].ticket)                                   // Ticket found
              {
               found = true;                                                                // Still open
               break;                                                                       // Stop searching
              }
         if(!found)                                                                         // Position closed
            RemoveState(m_states[i].ticket);                                                // Remove state
        }
     }

   // --- Last stored decision trace of a position
   string            ExplainDecision(ulong ticket)
     {
      for(int i = 0; i < m_record_count; i++)                                               // Every record
         if(m_records[i].ticket == ticket)                                                  // Ticket matches
            return m_records[i].trace;                                                      // Stored trace
      return "No decision recorded for this ticket.";                                       // Fallback
     }

   // --- Copy of the management state of a ticket (for tests and diagnostics)
   bool              GetManagementState(ulong ticket, SManagementState &state)
     {
      int idx = FindState(ticket);                                                          // Find state
      if(idx < 0)                                                                           // Not managed
         return false;                                                                      // Nothing copied
      state = m_states[idx];                                                                // Copy state
      return true;                                                                          // Copied
     }

   // --- Enable or disable test mode (testing only, never in production)
   void              EnableTestMode(bool enable)
     {
      m_test_mode = enable;                                                                 // Store flag
     }

   // --- Test hook: simulate a broker rejection of the next requests (test mode only)
   void              Test_ForceExecutionFailure(bool on)
     {
      m_test_force_exec_failure = on;                                                       // Store flag
     }

   // --- Test hook: run the full pipeline on a fake snapshot (integration testing)
   void              Test_RunPipeline(SPositionSnapshot &pos)
     {
      int idx = FindState(pos.ticket);                                                      // Find state
      if(idx < 0)                                                                           // New position
         idx = CreateState(pos);                                                            // Create state
      if(idx < 0)                                                                           // Table full
         return;                                                                            // Nothing to run
      bool old_test_mode = m_test_mode;                                                     // Save current mode
      m_test_mode = true;                                                                   // Enable test mode
      ProcessPosition(pos, idx);                                                            // Run the pipeline
      m_test_mode = old_test_mode;                                                          // Restore mode
     }
  };

//+------------------------------------------------------------------+
