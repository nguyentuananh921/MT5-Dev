//+------------------------------------------------------------------+
//|                                             ExitPolicyEngine.mqh |
//|                                  Copyright 2026, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2026, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
#property version   "1.00"

// --- Include the shared data types
#include "AdaptiveExitTypes.mqh"                                                      // Shared enums and structures

//+------------------------------------------------------------------+
//| Exit Policy Engine - ranks proposals in a strict total order     |
//+------------------------------------------------------------------+
class CExitPolicyEngine
  {
private:
   ENUM_PRECEDENCE_MODE m_mode;                                                       // Ordering mode
   ENUM_EXIT_REASON  m_priority[EXIT_PRIORITY_SLOTS];                                 // Copy of the reason priority list

public:
   // --- Rank of a reason: its index in the priority list, unlisted reasons share the lowest rank
   int               ReasonRank(ENUM_EXIT_REASON reason)
     {
      for(int p = 0; p < EXIT_PRIORITY_SLOTS; p++)                                    // Whole list, no hidden limit
         if(m_priority[p] == reason && reason != EXIT_REASON_NONE)                    // Reason listed at index p
            return p;                                                                 // Return its rank
      return EXIT_PRIORITY_SLOTS;                                                     // Unlisted reason
     }

private:
   // --- True if sl1 gives more protection than sl2
   bool              IsTighter(SPositionSnapshot &pos, double sl1, double sl2)
     {
      if(pos.direction == POSITION_TYPE_BUY)                                          // Long position
         return sl1 > sl2;                                                            // Higher SL protects a long better
      return sl1 < sl2;                                                               // Lower SL protects a short better
     }

   // --- Rank of an action, lower values are more decisive
   static int        ActionRank(ENUM_EXIT_ACTION a)
     {
      if(a == EXIT_ACTION_FULL_EXIT)                                                  // Full exit
         return 0;                                                                    // Ends the position
      if(a == EXIT_ACTION_PARTIAL_EXIT)                                               // Partial exit
         return 1;                                                                    // Reduces exposure
      return 2;                                                                       // Stop modification
     }

   // --- Order of two proposals: -1 = a first, +1 = b first, 0 = identical requests.
   // --- Every key is a property of the proposal, so module call order cannot change the result.
   int               Compare(SPositionSnapshot &pos, SExitAdjustment &a, SExitAdjustment &b)
     {
      bool by_reason = (m_mode == PRECEDENCE_BY_REASON);                              // Selected ordering mode
      int ra = ReasonRank(a.reason);                                                  // Reason rank of a
      int rb = ReasonRank(b.reason);                                                  // Reason rank of b
      int aa = ActionRank(a.action);                                                  // Action rank of a
      int ab = ActionRank(b.action);                                                  // Action rank of b
      int k1a = by_reason ? ra : aa;                                                  // Key 1 of a
      int k1b = by_reason ? rb : ab;                                                  // Key 1 of b
      int k2a = by_reason ? aa : ra;                                                  // Key 2 of a
      int k2b = by_reason ? ab : rb;                                                  // Key 2 of b

      if(k1a != k1b)                                                                  // Key 1 decides
         return (k1a < k1b) ? -1 : 1;                                                 // Lower rank first
      if(k2a != k2b)                                                                  // Key 2 decides
         return (k2a < k2b) ? -1 : 1;                                                 // Lower rank first
      if(a.reason != b.reason)                                                        // Key 3: reason value
         return ((int)a.reason < (int)b.reason) ? -1 : 1;                             // Orders reasons missing from the list

      // --- From here both proposals have the same action
      bool stops = (a.action == EXIT_ACTION_STOP_MODIFICATION);                       // Both are stop modifications
      bool partials = (a.action == EXIT_ACTION_PARTIAL_EXIT);                         // Both are partial closes
      if(stops && a.proposed_sl != b.proposed_sl)                                     // Key 4 for stops
         return IsTighter(pos, a.proposed_sl, b.proposed_sl) ? -1 : 1;                // Tighter stop first
      if(partials && a.close_volume != b.close_volume)                                // Key 4 for partials
         return (a.close_volume > b.close_volume) ? -1 : 1;                           // Larger close volume first

      int s = StringCompare(a.explanation, b.explanation);                            // Key 5: explanation text
      if(s != 0)                                                                      // Texts differ
         return (s < 0) ? -1 : 1;                                                     // Lexicographic order
      return 0;                                                                       // Identical requests
     }

   // --- One-line description of a proposal for the decision trace
   string            Describe(SPositionSnapshot &pos, SExitAdjustment &p)
     {
      string what;                                                                    // Level or volume text
      if(p.action == EXIT_ACTION_STOP_MODIFICATION)                                   // Stop modification
         what = "SL=" + DoubleToString(p.proposed_sl, ExitSymbolDigits(pos.symbol));  // Stop level
      else                                                                            // Partial or full close
         what = "close=" + DoubleToString(p.close_volume, 2);                         // Close volume (lots)
      string head = ReasonName(p.reason) + " " + ActionName(p.action);                // Reason and action
      string rank = " [rank " + IntegerToString(ReasonRank(p.reason)) + "] ";         // Priority rank
      return head + rank + what + " : " + p.explanation;                              // Full description
     }

public:
   // --- Constructor - stores the precedence mode and the priority list
                     CExitPolicyEngine(SExitConfig &config)
     {
      m_mode = config.precedence_mode;                                                // Store ordering mode
      for(int i = 0; i < EXIT_PRIORITY_SLOTS; i++)                                    // Copy all priority slots
         m_priority[i] = config.priority[i];                                          // Copy one slot
     }

   // --- Report missing or duplicated reasons in the priority list (empty string = OK)
   string            ConfigWarnings(void)
     {
      string w = "";                                                                  // Accumulated warnings
      for(int r = (int)EXIT_REASON_ATR; r <= (int)EXIT_REASON_TIME; r++)              // Every proposal reason
        {
         int hits = 0;                                                                // Slots holding this reason
         for(int p = 0; p < EXIT_PRIORITY_SLOTS; p++)                                 // Scan all slots
            if((int)m_priority[p] == r)                                               // Reason found in slot p
               hits++;                                                                // Count it
         string name = ReasonName((ENUM_EXIT_REASON)r);                               // Reason name
         if(hits == 0)                                                                // Reason missing
            w += name + " not in priority list (ranked last); ";                      // Add warning
         if(hits > 1)                                                                 // Reason duplicated
            w += name + " listed more than once (first slot used); ";                 // Add warning
        }
      return w;                                                                       // Return warnings
     }

   // --- Rank all well-formed proposals and return their number; 'trace' lists every proposal
   int               Rank(SPositionSnapshot &position, SExitAdjustment &adjustments[], int count, SExitAdjustment &ranked[], string &trace)
     {
      ArrayResize(ranked, count);                                                     // Single allocation for all candidates
      int n = 0;                                                                      // Number of ranked candidates
      string filtered = "";                                                           // Dropped proposals (for the trace)
      for(int i = 0; i < count; i++)                                                  // Every input proposal
        {
         if(!adjustments[i].well_formed)                                              // Malformed module output
           {
            filtered += "  - " + Describe(position, adjustments[i]);                  // Describe the proposal
            filtered += " (not well-formed, dropped)\n";                              // Mark it as dropped
            continue;                                                                 // Skip it
           }

         // --- Insertion sort: shift every candidate that must come after the new one
         int j = n;                                                                   // Insert position
         while(j > 0 && Compare(position, adjustments[i], ranked[j-1]) < 0)           // New one comes first
           {
            ranked[j] = ranked[j-1];                                                  // Shift right
            j--;                                                                      // Move left
           }
         ranked[j] = adjustments[i];                                                  // Insert
         n++;                                                                         // One more ranked candidate
        }
      ArrayResize(ranked, n);                                                         // Trim to the ranked count

      string mode = (m_mode == PRECEDENCE_BY_REASON) ? "BY_REASON" : "BY_ACTION";     // Mode name
      trace = "Candidates (" + IntegerToString(n) + " ranked, mode " + mode + "):\n"; // Section header
      for(int k = 0; k < n; k++)                                                      // One line per candidate
        {
         string line = Describe(position, ranked[k]);                                 // Candidate description
         trace += "  #" + IntegerToString(k + 1) + " " + line + "\n";                 // Numbered candidate line
        }
      if(n == 0)                                                                      // Nothing ranked
         trace += "  (none)\n";                                                       // Say so
      trace += filtered;                                                              // Append dropped proposals
      return n;                                                                       // Return ranked count
     }

   // --- Top-ranked proposal only, without the validation fallback
   bool              Resolve(SPositionSnapshot &position, SExitAdjustment &adjustments[], int count, SExitAdjustment &selected, string &decision_explanation, ENUM_EXIT_ERROR &error)
     {
      SExitAdjustment ranked[];                                                       // Ranked candidates
      int n = Rank(position, adjustments, count, ranked, decision_explanation);       // Rank all proposals
      error = EXIT_OK;                                                                // No error
      if(n == 0)                                                                      // Nothing to select
         return false;                                                                // No selection
      selected = ranked[0];                                                           // Top-ranked proposal
      return true;                                                                    // Selection made
     }
  };

//+------------------------------------------------------------------+
