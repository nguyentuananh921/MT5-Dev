//+------------------------------------------------------------------+
//|                                             AdaptiveExitDemo.mq5 |
//|                                  Copyright 2026, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2026, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
#property version   "1.00"

// --- Include the main engine
#include <AdaptiveExitEngine/AdaptiveExitEngine.mqh>                                             // Engine and all modules

//+------------------------------------------------------------------+
//| Input parameters                                                 |
//+------------------------------------------------------------------+
input long   MagicNumber             = 12345;                                                    // Magic number to filter positions
input int    ATRPeriod               = 14;                                                       // ATR period for the initial stop (bars)
input double ATRMultiplierStop       = 2.0;                                                      // ATR multiplier for the initial stop (from entry)
input int    StructuralLookback      = 20;                                                       // Closed bars scanned for swings (bars)
input int    PivotLeftBars           = 2;                                                        // Bars left of a pivot (bars)
input int    PivotRightBars          = 2;                                                        // Bars right of a pivot (bars)
input int    StructureRefreshSeconds = 300;                                                      // Swing refresh interval (seconds)
input double BreakevenRThreshold     = 0.5;                                                      // Current R that triggers breakeven (R-multiple)
input double BreakevenBufferPoints   = 2.0;                                                      // Buffer beyond entry (points)
input double TrailingActivationR     = 1.5;                                                      // Max favorable R that activates trailing (R-multiple)
input double TrailingStepPoints      = 10.0;                                                     // Trailing distance from price (points)
input double PartialCloseFraction    = 0.5;                                                      // Share of volume closed (decimal fraction)
input double PartialExitR            = 2.0;                                                      // Max favorable R that triggers partial exit (R-multiple)
input int    TimeExitMinutes         = 120;                                                      // Maximum lifetime (minutes)
input bool   EnablePartialExit       = true;                                                     // Enable partial exit
input bool   EnableTimeExit          = true;                                                     // Enable time-based exit
input ENUM_PRECEDENCE_MODE PrecedenceMode = PRECEDENCE_BY_REASON;                                // How conflicting proposals are ordered
input bool   EnablePersistence       = false;                                                    // Enable CSV logging
input string PersistenceFilename     = "ExitLog.csv";                                            // CSV file name (common data folder)
input int    PositionRefreshMs       = 1000;                                                     // Minimum time between scans (milliseconds)
input bool   DryRun                  = false;                                                    // If true, no actual trade operations
input double MinEffectiveSLChange    = 0.5;                                                      // Minimum SL change (points)
input int    MaxDeviationPoints      = 10;                                                       // Slippage allowed for closes (points)
input int    PendingTimeoutSeconds   = 30;                                                       // Wait for broker confirmation (seconds)
input bool   EnableDemoEntry         = false;                                                    // Open one market BUY without SL (demo accounts only)

//+------------------------------------------------------------------+
//| Global variables                                                 |
//+------------------------------------------------------------------+
CAdaptiveExitEngine *engine = NULL;                                                              // Pointer to the engine instance
bool demo_entry_done = false;                                                                    // True after the single demo entry attempt

//+------------------------------------------------------------------+
//| Build the engine configuration from the input parameters         |
//+------------------------------------------------------------------+
void BuildConfigFromInputs(SExitConfig &config)
  {
   ZeroMemory(config);                                                                           // Clear all fields
   config.magic_number = MagicNumber;                                                            // Magic number
   config.atr_period = ATRPeriod;                                                                // ATR period (bars)
   config.atr_multiplier_stop = ATRMultiplierStop;                                               // ATR stop multiplier
   config.structural_lookback = StructuralLookback;                                              // Structural lookback (bars)
   config.pivot_left_bars = PivotLeftBars;                                                       // Pivot left bars
   config.pivot_right_bars = PivotRightBars;                                                     // Pivot right bars
   config.structure_refresh_seconds = StructureRefreshSeconds;                                   // Structure refresh (seconds)
   config.breakeven_R_threshold = BreakevenRThreshold;                                           // Breakeven threshold (R-multiple)
   config.breakeven_buffer_points = BreakevenBufferPoints;                                       // Breakeven buffer (points)
   config.trailing_activation_R = TrailingActivationR;                                           // Trailing activation (R-multiple)
   config.trailing_step_points = TrailingStepPoints;                                             // Trailing step (points)
   config.partial_close_fraction = PartialCloseFraction;                                         // Partial close fraction
   config.partial_exit_R = PartialExitR;                                                         // Partial exit trigger (R-multiple)
   config.time_exit_minutes = TimeExitMinutes;                                                   // Time exit (minutes)
   config.enable_partial_exit = EnablePartialExit;                                               // Partial exit enabled flag
   config.enable_time_exit = EnableTimeExit;                                                     // Time exit enabled flag
   config.enable_persistence = EnablePersistence;                                                // Persistence enabled flag
   config.persistence_filename = PersistenceFilename;                                            // Persistence filename
   config.position_refresh_ms = PositionRefreshMs;                                               // Position refresh (milliseconds)
   config.dry_run = DryRun;                                                                      // Dry run flag
   config.min_effective_sl_change = MinEffectiveSLChange;                                        // Minimum SL change (points)
   config.max_deviation_points = MaxDeviationPoints;                                             // Allowed slippage (points)
   config.pending_timeout_seconds = PendingTimeoutSeconds;                                       // Confirmation timeout (seconds)
   config.precedence_mode = PrecedenceMode;                                                      // Ordering mode
   config.test_stop_level_points = 0;                                                            // 0 = use the real stop level
   config.test_freeze_level_points = 0;                                                          // 0 = use the real freeze level
   SetDefaultPriority(config);                                                                   // Time, Partial, Breakeven, Trailing, Structure, ATR
  }

//+------------------------------------------------------------------+
//| Build a fixed test configuration (independent of the inputs)     |
//+------------------------------------------------------------------+
void BuildTestConfig(SExitConfig &config)
  {
   ZeroMemory(config);                                                                           // Clear all fields
   config.magic_number = MagicNumber;                                                            // Magic number
   config.atr_period = 14;                                                                       // ATR period (bars)
   config.atr_multiplier_stop = 2.0;                                                             // ATR stop multiplier
   config.structural_lookback = 20;                                                              // Structural lookback (bars)
   config.pivot_left_bars = 2;                                                                   // Pivot left bars
   config.pivot_right_bars = 2;                                                                  // Pivot right bars
   config.structure_refresh_seconds = 300;                                                       // Structure refresh (seconds)
   config.breakeven_R_threshold = 0.5;                                                           // Breakeven threshold (R-multiple)
   config.breakeven_buffer_points = 2.0;                                                         // Breakeven buffer (points)
   config.trailing_activation_R = 1.5;                                                           // Trailing activation (R-multiple)
   config.trailing_step_points = 10.0;                                                           // Trailing step (points)
   config.partial_close_fraction = 0.5;                                                          // Partial close fraction
   config.partial_exit_R = 2.0;                                                                  // Partial exit trigger (R-multiple)
   config.time_exit_minutes = 120;                                                               // Time exit (minutes)
   config.enable_partial_exit = true;                                                            // Enable partial exit
   config.enable_time_exit = true;                                                               // Enable time exit
   config.enable_persistence = false;                                                            // No persistence in tests
   config.persistence_filename = "";                                                             // Empty persistence filename
   config.position_refresh_ms = 1000;                                                            // Position refresh (milliseconds)
   config.dry_run = true;                                                                        // Tests never send orders
   config.min_effective_sl_change = 0.5;                                                         // Minimum SL change (points)
   config.max_deviation_points = 10;                                                             // Allowed slippage (points)
   config.pending_timeout_seconds = 30;                                                          // Confirmation timeout (seconds)
   config.precedence_mode = PRECEDENCE_BY_REASON;                                                // Reason priority first
   config.test_stop_level_points = 0;                                                            // 0 = use the real stop level
   config.test_freeze_level_points = 0;                                                          // 0 = use the real freeze level
   SetDefaultPriority(config);                                                                   // Fill all priority slots
  }

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
   SExitConfig config;                                                                           // Engine configuration
   BuildConfigFromInputs(config);                                                                // Fill from inputs
   engine = new CAdaptiveExitEngine(config);                                                     // Instantiate the engine

   if(!RunDeterministicTests())                                                                  // Execute all tests
     {
      Print("Deterministic test failed!");                                                       // Output failure message
      return INIT_FAILED;                                                                        // Stop the EA
     }

   Print("AdaptiveExitEngine initialised successfully.");                                        // Success message
   return(INIT_SUCCEEDED);                                                                       // Return success
  }

//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   if(engine != NULL)                                                                            // Engine instance exists
     {
      delete engine;                                                                             // Free memory
      engine = NULL;                                                                             // Clear the pointer
     }
   Print("AdaptiveExitEngine deinitialised.");                                                   // Log deinitialisation
  }

//+------------------------------------------------------------------+
//| Demo entry - one market BUY without SL for verification          |
//+------------------------------------------------------------------+
void DemoEntryOnce()
  {
   if(!EnableDemoEntry || demo_entry_done)                                                       // Disabled or already attempted
      return;                                                                                    // Nothing to do

// --- An existing managed position makes the demo entry unnecessary
   for(int i = 0; i < PositionsTotal(); i++)                                                     // Every open position
     {
      ulong t = PositionGetTicket(i);                                                            // Ticket of position i
      if(t == 0 || !PositionSelectByTicket(t))                                                   // Not selectable
         continue;                                                                               // Skip it
      bool same_symbol = (PositionGetString(POSITION_SYMBOL) == _Symbol);                        // Chart symbol
      bool same_magic = (PositionGetInteger(POSITION_MAGIC) == MagicNumber);                     // Managed by this EA
      if(same_symbol && same_magic)                                                              // Managed position found
        {
         demo_entry_done = true;                                                                 // No entry needed
         return;                                                                                 // Done
        }
     }

   MqlTradeRequest req;                                                                          // Trade request
   MqlTradeResult res;                                                                           // Trade result
   ZeroMemory(req);                                                                              // Clear request
   ZeroMemory(res);                                                                              // Clear result
   req.action = TRADE_ACTION_DEAL;                                                               // Market deal
   req.symbol = _Symbol;                                                                         // Chart symbol
   req.volume = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MIN);                                    // Minimum volume (lots)
   req.type = ORDER_TYPE_BUY;                                                                    // Buy
   req.price = SymbolInfoDouble(_Symbol, SYMBOL_ASK);                                            // Ask price
   req.deviation = (ulong)MaxDeviationPoints;                                                    // Allowed slippage (points)
   req.magic = (ulong)MagicNumber;                                                               // Magic number of managed positions
   req.type_filling = CExitExecutionAdapter::SelectFillingMode(_Symbol);                         // Supported filling mode
   req.comment = "AdaptiveExitDemo entry";                                                       // Order comment
   bool sent = OrderSend(req, res);                                                              // Send the order
   if(sent && res.retcode == TRADE_RETCODE_DONE)                                                 // Deal executed
      Print("Demo entry opened, deal ", res.deal);                                               // Report deal
   else                                                                                          // Not executed
      Print("Demo entry failed: retcode ", res.retcode, " ", res.comment);                       // Report failure
   demo_entry_done = true;                                                                       // One attempt per EA run
  }

//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
   DemoEntryOnce();                                                                              // Optional demo entry
   if(engine != NULL)                                                                            // Engine is valid
      engine.OnTick();                                                                           // Run the engine
  }

//+------------------------------------------------------------------+
//| MakeStop - fill a stop modification proposal for tests           |
//+------------------------------------------------------------------+
void MakeStop(SExitAdjustment &p, ulong ticket, ENUM_EXIT_REASON reason, double sl, string expl)
  {
   ZeroMemory(p);                                                                                // Clear all fields
   p.ticket = ticket;                                                                            // Ticket
   p.action = EXIT_ACTION_STOP_MODIFICATION;                                                     // Action: modify SL
   p.proposed_sl = sl;                                                                           // Proposed SL (price units)
   p.reason = reason;                                                                            // Reason
   p.explanation = expl;                                                                         // Explanation
   p.well_formed = true;                                                                         // Well-formed
  }

//+------------------------------------------------------------------+
//| MakeClose - fill a partial or full close proposal for tests      |
//+------------------------------------------------------------------+
void MakeClose(SExitAdjustment &p, ulong ticket, ENUM_EXIT_ACTION action, ENUM_EXIT_REASON reason, double vol, string expl)
  {
   ZeroMemory(p);                                                                                // Clear all fields
   p.ticket = ticket;                                                                            // Ticket
   p.action = action;                                                                            // Partial or full close
   p.close_volume = vol;                                                                         // Volume to close (lots)
   p.reason = reason;                                                                            // Reason
   p.explanation = expl;                                                                         // Explanation
   p.well_formed = true;                                                                         // Well-formed
  }

//+------------------------------------------------------------------+
//| MakeBuy - fill a synthetic BUY position for tests                |
//+------------------------------------------------------------------+
void MakeBuy(SPositionSnapshot &p, ulong ticket, double entry, double price, double sl)
  {
   ZeroMemory(p);                                                                                // Clear all fields
   p.ticket = ticket;                                                                            // Ticket
   p.symbol = _Symbol;                                                                           // Chart symbol
   p.magic = MagicNumber;                                                                        // Magic number
   p.direction = POSITION_TYPE_BUY;                                                              // Direction
   p.entry_price = entry;                                                                        // Entry price (price units)
   p.current_price = price;                                                                      // Current price (price units)
   p.current_sl = sl;                                                                            // Current SL (price units)
   p.current_tp = 0.0;                                                                           // No TP
   p.volume = 1.0;                                                                               // Volume (lots)
   p.open_time = TimeCurrent();                                                                  // Opened now (timestamp)
  }

//+------------------------------------------------------------------+
//| Deterministic [D] and Broker-Aware [B] Module Tests              |
//+------------------------------------------------------------------+
bool RunDeterministicTests()
  {
   Print("=== Starting Deterministic and Broker-Aware Module Tests ===");                        // Start marker
   bool all_pass = true;                                                                         // Assume all tests pass

   string symbol = Symbol();                                                                     // Chart symbol
   double point = ExitSymbolPoint(symbol);                                                       // Point size (price units)
   double tick = SymbolInfoDouble(symbol, SYMBOL_TRADE_TICK_SIZE);                               // Tick size (price units)
   if(tick <= 0)                                                                                 // Tick size not available
      tick = point;                                                                              // Use the point instead
   int digits = ExitSymbolDigits(symbol);                                                        // Symbol digits
   double bid = SymbolInfoDouble(symbol, SYMBOL_BID);                                            // Current bid (price units)
   ENUM_EXIT_ERROR err;                                                                          // Module error
   string t;                                                                                     // Trace or explanation buffer

   SExitConfig testConfig;                                                                       // Test configuration
   BuildTestConfig(testConfig);                                                                  // Fixed test values

// --- Test 1: the ATR initial stop is anchored to entry (live ATR data)
   Print("Test 1 [B]: ATR initial stop anchored to entry");                                      // Test description
   CATRStopCalculator atr(symbol, PERIOD_CURRENT, 14, 2.0);                                      // ATR calculator
   SPositionSnapshot atrPos;                                                                     // Test position
   MakeBuy(atrPos, 1001, bid, bid + 50 * point, 0.0);                                            // Price already 50 points above entry
   SExitAdjustment atrProp;                                                                      // Proposal
   bool atr_ok = atr.GenerateProposal(atrPos, atrProp, err);                                     // Generate proposal
   double atr_sl = atrProp.proposed_sl;                                                          // Proposed stop (price units)
   bool atr_below = (atr_sl > 0 && atr_sl < atrPos.entry_price);                                 // Below entry
   if(atr_ok && atr_below && atrProp.close_volume == 0.0)                                        // Correct stop, no volume
      Print("  PASS: ATR stop below entry, no volume");                                          // Pass
   else                                                                                          // Wrong result
     {
      Print("  FAIL: ATR proposal wrong or missing: ", EnumToString(err));                       // Fail
      all_pass = false;                                                                          // Mark test as failed
     }

// --- Test 2: ATR refuses a position on another symbol
   Print("Test 2 [D]: ATR symbol mismatch");                                                     // Test description
   SPositionSnapshot otherPos;                                                                   // Test position
   MakeBuy(otherPos, 1002, 100.0, 100.0, 0.0);                                                   // Synthetic position
   otherPos.symbol = symbol + "_OTHER";                                                          // Different symbol
   SExitAdjustment otherProp;                                                                    // Proposal
   bool other_ok = atr.GenerateProposal(otherPos, otherProp, err);                               // Must be refused
   if(!other_ok && err == EXIT_SYMBOL_MISMATCH)                                                  // Refused with the right code
      Print("  PASS: Mismatched symbol rejected");                                               // Pass
   else                                                                                          // Accepted
     {
      Print("  FAIL: Mismatched symbol not rejected");                                           // Fail
      all_pass = false;                                                                          // Mark test as failed
     }

// --- Test 3: structure proposal with injected swing data
   Print("Test 3 [D]: Structure proposal (injected swings)");                                    // Test description
   CStructureAwareAdjuster structure(symbol, 20, 2, 2, 300);                                     // Structure adjuster
   structure.SetSwingData(101.00, 99.20);                                                        // Controlled swing data
   SPositionSnapshot structPos;                                                                  // Test position
   MakeBuy(structPos, 1003, 100.0, 100.0, 0.0);                                                  // BUY at 100
   SExitAdjustment structProp;                                                                   // Proposal
   bool st_ok = structure.GenerateProposal(structPos, 99.00, structProp, err);                   // ATR stop at 99.00
   if(st_ok && MathAbs(structProp.proposed_sl - 99.20) < point * 0.5)                            // Pivot low 99.20 is tighter
      Print("  PASS: Structure selected the injected pivot low (99.20)");                        // Pass
   else                                                                                          // Wrong result
     {
      Print("  FAIL: Structure selection wrong");                                                // Fail
      all_pass = false;                                                                          // Mark test as failed
     }
   st_ok = structure.GenerateProposal(structPos, 99.50, structProp, err);                        // ATR stop at 99.50 is tighter
   if(!st_ok && err == EXIT_OK)                                                                  // No duplicate proposal
      Print("  PASS: No duplicate proposal when structure is not tighter");                      // Pass
   else                                                                                          // Duplicate produced
     {
      Print("  FAIL: Structure produced a proposal that is not tighter");                        // Fail
      all_pass = false;                                                                          // Mark test as failed
     }

// --- Test 4: breakeven with 1R established
   Print("Test 4 [D]: Breakeven proposal");                                                      // Test description
   CBreakevenController be(0.5, 2.0);                                                            // Threshold 0.5 R, buffer 2 points
   SPositionSnapshot pos;                                                                        // Shared position for tests 4 to 11
   MakeBuy(pos, 1004, 100.0, 100.6, 99.0);                                                       // BUY at 100 with SL 99
   pos.initial_risk_distance = 1.0;                                                              // 1R = 1.0 (price units)
   pos.flags = PSF_INITIAL_STOP;                                                                 // Initial stop established
   pos.current_R = 0.6;                                                                          // Above the threshold (R-multiple)
   SExitAdjustment beProp;                                                                       // Proposal
   bool be_ok = be.GenerateProposal(pos, beProp, err);                                           // Generate proposal
   if(be_ok && MathAbs(beProp.proposed_sl - (100.0 + 2.0 * point)) < point * 0.5)                // Entry plus buffer
      Print("  PASS: Breakeven correct");                                                        // Pass
   else                                                                                          // Wrong result
     {
      Print("  FAIL: Breakeven not triggered or SL wrong");                                      // Fail
      all_pass = false;                                                                          // Mark test as failed
     }

// --- Test 5: breakeven before 1R exists
   Print("Test 5 [D]: Breakeven before 1R");                                                     // Test description
   SPositionSnapshot noRiskPos;                                                                  // Position without 1R
   noRiskPos = pos;                                                                              // Copy shared position
   noRiskPos.initial_risk_distance = 0.0;                                                        // 1R unknown
   noRiskPos.flags = 0;                                                                          // No initial stop
   be_ok = be.GenerateProposal(noRiskPos, beProp, err);                                          // Must not propose
   if(!be_ok && err == EXIT_NO_INITIAL_RISK)                                                     // Refused with the right code
      Print("  PASS: No R-based proposal without 1R");                                           // Pass
   else                                                                                          // Proposed anyway
     {
      Print("  FAIL: Breakeven proposed without 1R");                                            // Fail
      all_pass = false;                                                                          // Mark test as failed
     }

// --- Test 6: trailing proposal
   Print("Test 6 [D]: Trailing proposal");                                                       // Test description
   CTrailingStopManager trail(1.5, 10.0);                                                        // Activation 1.5 R, step 10 points
   SPositionSnapshot trailPos;                                                                   // Test position
   trailPos = pos;                                                                               // Copy shared position
   trailPos.max_favorable_R = 2.0;                                                               // Above activation (R-multiple)
   trailPos.current_price = 102.0;                                                               // Current price (price units)
   SExitAdjustment trailProp;                                                                    // Proposal
   bool tr_ok = trail.GenerateProposal(trailPos, trailProp, err);                                // Generate proposal
   if(tr_ok && MathAbs(trailProp.proposed_sl - (102.0 - 10.0 * point)) < point * 0.5)            // Price minus step
      Print("  PASS: Trailing correct");                                                         // Pass
   else                                                                                          // Wrong result
     {
      Print("  FAIL: Trailing not activated or SL wrong");                                       // Fail
      all_pass = false;                                                                          // Mark test as failed
     }

// --- Test 7: partial close volume is rounded down to the volume step
   Print("Test 7 [B]: Partial exit volume");                                                     // Test description
   CPartialExitController partial(2.0, 0.5, true);                                               // Trigger 2.0 R, close half
   SPositionSnapshot partPos;                                                                    // Test position
   partPos = pos;                                                                                // Copy shared position
   partPos.max_favorable_R = 2.1;                                                                // Trigger reached (R-multiple)
   SExitAdjustment partProp;                                                                     // Proposal
   bool pe_ok = partial.GenerateProposal(partPos, partProp, err);                                // Generate proposal
   double vstep = SymbolInfoDouble(symbol, SYMBOL_VOLUME_STEP);                                  // Volume step (lots)
   double steps = (vstep > 0) ? partProp.close_volume / vstep : 0.0;                             // Close volume in steps
   bool aligned = (vstep <= 0 || MathAbs(steps - MathRound(steps)) < 1e-6);                      // Whole number of steps
   bool in_range = (partProp.close_volume > 0 && partProp.close_volume <= 0.5 + 1e-9);           // At most half
   if(pe_ok && partProp.action == EXIT_ACTION_PARTIAL_EXIT && aligned && in_range)               // Correct proposal
      Print("  PASS: Close volume <= 50% and aligned to volume step");                           // Pass
   else                                                                                          // Wrong result
     {
      Print("  FAIL: Partial close volume wrong or missing");                                    // Fail
      all_pass = false;                                                                          // Mark test as failed
     }

// --- Test 8: reason priority decides, independent of action type and input order
   Print("Test 8 [D]: Reason priority beats action type (order independent)");                   // Test description
   SExitConfig reasonConfig;                                                                     // Strategy: breakeven before time exit
   reasonConfig = testConfig;                                                                    // Copy test configuration
   reasonConfig.priority[0] = EXIT_REASON_BREAKEVEN;                                             // Priority 0: Breakeven
   reasonConfig.priority[1] = EXIT_REASON_TIME;                                                  // Priority 1: Time
   reasonConfig.priority[2] = EXIT_REASON_PARTIAL;                                               // Priority 2: Partial
   reasonConfig.priority[3] = EXIT_REASON_TRAILING;                                              // Priority 3: Trailing
   reasonConfig.priority[4] = EXIT_REASON_STRUCTURE;                                             // Priority 4: Structure
   reasonConfig.priority[5] = EXIT_REASON_ATR;                                                   // Priority 5: ATR
   CExitPolicyEngine reasonPolicy(reasonConfig);                                                 // Policy in BY_REASON mode
   SExitAdjustment orderA[2];                                                                    // Input order A
   SExitAdjustment orderB[2];                                                                    // Input order B (reversed)
   SExitAdjustment rankedA[];                                                                    // Ranked from order A
   SExitAdjustment rankedB[];                                                                    // Ranked from order B
   MakeStop(orderA[0], 1004, EXIT_REASON_BREAKEVEN, 100.0002, "be");                             // Breakeven stop
   MakeClose(orderA[1], 1004, EXIT_ACTION_FULL_EXIT, EXIT_REASON_TIME, 1.0, "time");             // Time full exit
   orderB[0] = orderA[1];                                                                        // Reverse order
   orderB[1] = orderA[0];                                                                        // Reverse order
   reasonPolicy.Rank(pos, orderA, 2, rankedA, t);                                                // Rank order A
   reasonPolicy.Rank(pos, orderB, 2, rankedB, t);                                                // Rank order B
   bool be_first_a = (rankedA[0].reason == EXIT_REASON_BREAKEVEN);                               // Winner from order A
   bool be_first_b = (rankedB[0].reason == EXIT_REASON_BREAKEVEN);                               // Winner from order B
   if(be_first_a && be_first_b)                                                                  // Same winner in both orders
      Print("  PASS: BREAKEVEN ranked first in both input orders");                              // Pass
   else                                                                                          // Order or action type decided
     {
      Print("  FAIL: Ranking depends on action type or input order");                            // Fail
      all_pass = false;                                                                          // Mark test as failed
     }

// --- Test 9: BY_ACTION mode puts the full exit first only when configured
   Print("Test 9 [D]: BY_ACTION mode");                                                          // Test description
   reasonConfig.precedence_mode = PRECEDENCE_BY_ACTION;                                          // Action type first
   CExitPolicyEngine actionPolicy(reasonConfig);                                                 // Policy in BY_ACTION mode
   actionPolicy.Rank(pos, orderA, 2, rankedA, t);                                                // Rank order A
   if(rankedA[0].action == EXIT_ACTION_FULL_EXIT)                                                // Full exit first
      Print("  PASS: FULL_EXIT first in BY_ACTION mode");                                        // Pass
   else                                                                                          // Wrong order
     {
      Print("  FAIL: BY_ACTION mode did not put FULL_EXIT first");                               // Fail
      all_pass = false;                                                                          // Mark test as failed
     }

// --- Test 10: all six reasons have a slot, unlisted reasons rank last
   Print("Test 10 [D]: Priority list covers all reasons");                                       // Test description
   CExitPolicyEngine fullPolicy(testConfig);                                                     // Default priority list
   bool no_warning = (fullPolicy.ConfigWarnings() == "");                                        // Complete list
   int partial_rank = fullPolicy.ReasonRank(EXIT_REASON_PARTIAL);                                // Rank of PARTIAL
   int atr_rank = fullPolicy.ReasonRank(EXIT_REASON_ATR);                                        // Rank of ATR
   bool partial_ranked = (partial_rank < EXIT_PRIORITY_SLOTS);                                   // PARTIAL listed
   bool atr_ranked = (atr_rank < EXIT_PRIORITY_SLOTS);                                           // ATR listed
   if(no_warning && partial_ranked && atr_ranked)                                                // All reasons ranked
      Print("  PASS: PARTIAL and ATR are ranked (no 5-slot limit)");                             // Pass
   else                                                                                          // List incomplete
     {
      Print("  FAIL: Priority list incomplete");                                                 // Fail
      all_pass = false;                                                                          // Mark test as failed
     }
   SExitConfig missingConfig;                                                                    // Configuration without ATR
   missingConfig = testConfig;                                                                   // Copy test configuration
   missingConfig.priority[5] = EXIT_REASON_NONE;                                                 // Remove ATR from the list
   CExitPolicyEngine missingPolicy(missingConfig);                                               // Policy with ATR missing
   MakeStop(orderA[0], 1004, EXIT_REASON_ATR, 99.0, "atr");                                      // ATR stop
   MakeStop(orderA[1], 1004, EXIT_REASON_STRUCTURE, 99.2, "structure");                          // Structure stop
   orderB[0] = orderA[1];                                                                        // Reverse order
   orderB[1] = orderA[0];                                                                        // Reverse order
   missingPolicy.Rank(pos, orderA, 2, rankedA, t);                                               // Rank order A
   missingPolicy.Rank(pos, orderB, 2, rankedB, t);                                               // Rank order B
   bool warned = (missingPolicy.ConfigWarnings() != "");                                         // Missing reason reported
   bool atr_last_a = (rankedA[1].reason == EXIT_REASON_ATR);                                     // ATR last in order A
   bool atr_last_b = (rankedB[1].reason == EXIT_REASON_ATR);                                     // ATR last in order B
   bool atr_last = (atr_last_a && atr_last_b);                                                   // ATR last in both orders
   if(warned && atr_last)                                                                        // Deterministic handling
      Print("  PASS: Unlisted ATR ranked last in both orders and reported");                     // Pass
   else                                                                                          // Wrong handling
     {
      Print("  FAIL: Unlisted reason not handled deterministically");                            // Fail
      all_pass = false;                                                                          // Mark test as failed
     }

// --- Test 11: same reason, the tighter stop wins regardless of input order
   Print("Test 11 [D]: Tie-breaker for equal reasons");                                          // Test description
   MakeStop(orderA[0], 1004, EXIT_REASON_TRAILING, 101.0, "a");                                  // Looser trailing stop
   MakeStop(orderA[1], 1004, EXIT_REASON_TRAILING, 101.5, "b");                                  // Tighter trailing stop
   orderB[0] = orderA[1];                                                                        // Reverse order
   orderB[1] = orderA[0];                                                                        // Reverse order
   fullPolicy.Rank(pos, orderA, 2, rankedA, t);                                                  // Rank order A
   fullPolicy.Rank(pos, orderB, 2, rankedB, t);                                                  // Rank order B
   if(rankedA[0].proposed_sl == 101.5 && rankedB[0].proposed_sl == 101.5)                        // Tighter BUY stop first
      Print("  PASS: Tighter BUY stop (101.5) first in both orders");                            // Pass
   else                                                                                          // Order decided
     {
      Print("  FAIL: Tie-breaker depends on input order");                                       // Fail
      all_pass = false;                                                                          // Mark test as failed
     }

// --- Validator tests use a BUY at 100 with SL 99.50 and price 102
   CExitValidator validator(testConfig);                                                         // Validator with real broker levels
   SPositionSnapshot valPos;                                                                     // Test position
   MakeBuy(valPos, 1005, 100.0, 102.0, 99.50);                                                   // BUY at 100, SL 99.50, price 102
   SExitAdjustment valProp;                                                                      // Proposal to validate
   SExitAdjustment validated;                                                                    // Validated proposal
   ENUM_EXIT_RESULT vres;                                                                        // Validation result

// --- Test 12: idempotency
   Print("Test 12 [B]: Idempotency check");                                                      // Test description
   MakeStop(valProp, 1005, EXIT_REASON_TRAILING, 99.50 + 0.1 * point, "tiny");                   // Change below threshold
   vres = validator.Validate(valPos, valProp, validated, t);                                     // Validate
   if(vres == EXIT_RESULT_NO_CHANGE)                                                             // No change detected
      Print("  PASS: Idempotency detected");                                                     // Pass
   else                                                                                          // Not detected
     {
      Print("  FAIL: No-change not detected: ", ResultName(vres));                               // Fail
      all_pass = false;                                                                          // Mark test as failed
     }

// --- Test 13: risk regression
   Print("Test 13 [B]: Risk regression rejection");                                              // Test description
   MakeStop(valProp, 1005, EXIT_REASON_TRAILING, 99.40, "worse");                                // Lower stop for a BUY
   vres = validator.Validate(valPos, valProp, validated, t);                                     // Validate
   if(vres == EXIT_RESULT_RISK_REGRESSION)                                                       // Regression detected
      Print("  PASS: Risk regression detected");                                                 // Pass
   else                                                                                          // Not detected
     {
      Print("  FAIL: Risk regression not detected: ", ResultName(vres));                         // Fail
      all_pass = false;                                                                          // Mark test as failed
     }

// --- Test 14: tick-size normalization happens before the checks
   Print("Test 14 [B]: Tick-size normalization");                                                // Test description
   MakeStop(valProp, 1005, EXIT_REASON_BREAKEVEN, 100.0 + 0.3 * tick, "unaligned");              // Off the tick grid
   vres = validator.Validate(valPos, valProp, validated, t);                                     // Validate
   double expected = NormalizeDouble(100.0, digits);                                             // Stop on the tick grid
   bool on_grid = (MathAbs(validated.proposed_sl - expected) < tick * 0.01);                     // Normalized
   if(vres == EXIT_RESULT_OK && on_grid && validated.close_volume == 0.0)                        // Normalized and accepted
      Print("  PASS: Unaligned SL normalized and accepted");                                     // Pass
   else                                                                                          // Wrong result
     {
      Print("  FAIL: Normalization failed: ", ResultName(vres), " ", t);                         // Fail
      all_pass = false;                                                                          // Mark test as failed
     }

// --- Test 15: synthetic stop level
   Print("Test 15 [B]: Validator broker constraints (synthetic stop level)");                    // Test description
   SExitConfig synthConfig;                                                                      // Synthetic broker configuration
   synthConfig = testConfig;                                                                     // Copy test configuration
   synthConfig.test_stop_level_points = 20;                                                      // Stop level (points)
   synthConfig.test_freeze_level_points = 10;                                                    // Freeze level (points)
   CExitValidator validatorSynth(synthConfig);                                                   // Validator with synthetic levels
   MakeStop(valProp, 1005, EXIT_REASON_TRAILING, 102.0 - 10 * point, "too close");               // 10 points from price
   vres = validatorSynth.Validate(valPos, valProp, validated, t);                                // Validate
   if(vres == EXIT_RESULT_STOP_LEVEL_VIOLATION)                                                  // Violation detected
      Print("  PASS: Stop-level violation detected with synthetic level 20 points");             // Pass
   else                                                                                          // Not detected
     {
      Print("  FAIL: Stop-level not detected. Got result: ", ResultName(vres));                  // Fail
      all_pass = false;                                                                          // Mark test as failed
     }

// --- Test 16: the first candidate is rejected, so the next one is selected
   Print("Test 16 [B]: Re-selection after validation failure");                                  // Test description
   CAdaptiveExitEngine synthEngine(synthConfig);                                                 // Engine with synthetic stop level
   SExitAdjustment candidates[2];                                                                // Ranked candidates
   MakeStop(candidates[0], 1005, EXIT_REASON_TRAILING, 102.0 - 10 * point, "too close");         // Violates stop level
   MakeStop(candidates[1], 1005, EXIT_REASON_BREAKEVEN, 100.0 + 2 * point, "breakeven");         // Valid
   int k = synthEngine.SelectFirstExecutable(valPos, candidates, 2, validated, vres, t);         // Validate in order
   if(k == 1 && validated.reason == EXIT_REASON_BREAKEVEN)                                       // Second candidate selected
      Print("  PASS: Second candidate selected after first was rejected");                       // Pass
   else                                                                                          // No fallback
     {
      Print("  FAIL: No fallback to the next candidate: ", t);                                   // Fail
      all_pass = false;                                                                          // Mark test as failed
     }

// --- Test 17: retcode classification
   Print("Test 17 [D]: Retcode classification");                                                 // Test description
   ENUM_EXIT_RESULT r_done = CExitExecutionAdapter::ClassifyRetcode(TRADE_RETCODE_DONE);         // DONE
   ENUM_EXIT_RESULT r_part = CExitExecutionAdapter::ClassifyRetcode(TRADE_RETCODE_DONE_PARTIAL); // DONE_PARTIAL
   ENUM_EXIT_RESULT r_placed = CExitExecutionAdapter::ClassifyRetcode(TRADE_RETCODE_PLACED);     // PLACED
   ENUM_EXIT_RESULT r_reject = CExitExecutionAdapter::ClassifyRetcode(TRADE_RETCODE_REJECT);     // REJECT
   bool c_done = (r_done == EXIT_RESULT_OK);                                                     // Executed
   bool c_part = (r_part == EXIT_RESULT_PARTIAL_FILL);                                           // Partly executed
   bool c_placed = (r_placed == EXIT_RESULT_PENDING_CONFIRMATION);                               // Needs confirmation
   bool c_reject = (r_reject == EXIT_RESULT_EXECUTION_ERROR);                                    // Failure
   if(c_done && c_part && c_placed && c_reject)                                                  // All four mappings correct
      Print("  PASS: DONE=OK, DONE_PARTIAL=PARTIAL_FILL, PLACED=PENDING, REJECT=ERROR");         // Pass
   else                                                                                          // Wrong mapping
     {
      Print("  FAIL: Retcode classification wrong");                                             // Fail
      all_pass = false;                                                                          // Mark test as failed
     }

// --- Test 18: execution adapter dry-run
   Print("Test 18 [D]: Execution adapter dry-run");                                              // Test description
   CExitExecutionAdapter executor(10);                                                           // Deviation 10 points
   MakeStop(valProp, 1005, EXIT_REASON_BREAKEVEN, 100.0, "be");                                  // Proposal to simulate
   SExitResult res = executor.Execute(valPos, valProp, true);                                    // Dry-run execution
   if(res.success && res.result_code == EXIT_RESULT_OK && res.retcode == 0)                      // Simulated, nothing sent
      Print("  PASS: Dry-run successful");                                                       // Pass
   else                                                                                          // Wrong result
     {
      Print("  FAIL: Dry-run failed");                                                           // Fail
      all_pass = false;                                                                          // Mark test as failed
     }

// --- Test 19: full pipeline trace with candidates, validation, execution and reconciliation
   Print("Test 19 [B]: ExplainDecision - Full pipeline integration test");                       // Test description
   CAdaptiveExitEngine testEngine(testConfig);                                                   // Local engine
   SPositionSnapshot fakePos;                                                                    // Fake position
   MakeBuy(fakePos, 9999, bid, bid, 0.0);                                                        // New BUY without SL
   testEngine.Test_RunPipeline(fakePos);                                                         // Run the pipeline
   string dec = testEngine.ExplainDecision(9999);                                                // Decision trace
   SManagementState st;                                                                          // State after the run
   bool have = testEngine.GetManagementState(9999, st);                                          // Read state
   bool has_cand = (StringFind(dec, "Candidates") >= 0);                                         // Candidate section present
   bool has_val = (StringFind(dec, "Validation") >= 0);                                          // Validation section present
   bool has_sel = (StringFind(dec, "Selected") >= 0);                                            // Selection present
   bool has_rec = (StringFind(dec, "Reconciliation") >= 0);                                      // Reconciliation present
   if(has_cand && has_val && has_sel && has_rec)                                                 // Full trace
      Print("  PASS: ExplainDecision returned a full pipeline trace:\n", dec);                   // Pass
   else                                                                                          // Incomplete trace
     {
      Print("  FAIL: ExplainDecision trace incomplete. Got: ", dec);                             // Fail
      all_pass = false;                                                                          // Mark test as failed
     }
   if(have && (st.flags & PSF_INITIAL_STOP) != 0 && st.initial_risk_distance > 0)                // 1R after the stop
      Print("  PASS: 1R established after the (simulated) confirmed stop");                      // Pass
   else                                                                                          // 1R missing
     {
      Print("  FAIL: 1R not established after the confirmed stop");                              // Fail
      all_pass = false;                                                                          // Mark test as failed
     }

// --- Test 20: a rejected request must not change the state or establish 1R
   Print("Test 20 [B]: Rejected request leaves state unchanged");                                // Test description
   CAdaptiveExitEngine rejectEngine(testConfig);                                                 // Local engine
   rejectEngine.Test_ForceExecutionFailure(true);                                                // Simulate broker rejection
   SPositionSnapshot rejectPos;                                                                  // Fake position
   MakeBuy(rejectPos, 9998, bid, bid, 0.0);                                                      // New BUY without SL
   rejectEngine.Test_RunPipeline(rejectPos);                                                     // Run the pipeline
   have = rejectEngine.GetManagementState(9998, st);                                             // Read state
   if(have && (st.flags & PSF_INITIAL_STOP) == 0 && st.initial_risk_distance == 0)               // Nothing established
      Print("  PASS: No INITIAL_STOP flag and no 1R after rejection");                           // Pass
   else                                                                                          // State changed
     {
      Print("  FAIL: State changed after a rejected request");                                   // Fail
      all_pass = false;                                                                          // Mark test as failed
     }

// --- Test 21: an existing loss-side stop is adopted as 1R
   Print("Test 21 [D]: Existing stop adopted as 1R");                                            // Test description
   CAdaptiveExitEngine adoptEngine(testConfig);                                                  // Local engine
   SPositionSnapshot adoptPos;                                                                   // Fake position
   MakeBuy(adoptPos, 9997, 100.0, 100.0, 99.0);                                                  // BUY at 100 with SL 99
   adoptEngine.Test_RunPipeline(adoptPos);                                                       // Run the pipeline
   have = adoptEngine.GetManagementState(9997, st);                                              // Read state
   bool one_r_ok = (MathAbs(st.initial_risk_distance - 1.0) < 1e-9);                             // 1R equals |100 - 99|
   if(have && (st.flags & PSF_INITIAL_STOP) != 0 && one_r_ok)                                    // Existing stop adopted
      Print("  PASS: 1R = |entry - existing SL| = 1.0 (price units)");                           // Pass
   else                                                                                          // Not adopted
     {
      Print("  FAIL: Existing stop not adopted as 1R");                                          // Fail
      all_pass = false;                                                                          // Mark test as failed
     }

// --- Test 22: initial SELL stop above entry is accepted
   Print("Test 22 [B]: Initial SELL stop validation");                                           // Test description
   SPositionSnapshot sellPos;                                                                    // Test position
   ZeroMemory(sellPos);                                                                          // Clear all fields
   sellPos.ticket = 1006;                                                                        // Ticket
   sellPos.symbol = symbol;                                                                      // Chart symbol
   sellPos.direction = POSITION_TYPE_SELL;                                                       // Direction
   sellPos.entry_price = 100.00;                                                                 // Entry price (price units)
   sellPos.current_price = 100.00;                                                               // Current price (price units)
   sellPos.current_sl = 0.0;                                                                     // No SL
   sellPos.volume = 1.0;                                                                         // Volume (lots)
   MakeStop(valProp, 1006, EXIT_REASON_ATR, 101.00, "sell stop");                                // Stop above entry
   vres = validator.Validate(sellPos, valProp, validated, t);                                    // Validate
   if(vres == EXIT_RESULT_OK)                                                                    // Accepted
      Print("  PASS: Initial SELL stop accepted");                                               // Pass
   else                                                                                          // Rejected
     {
      Print("  FAIL: Initial SELL stop rejected: ", t);                                          // Fail
      all_pass = false;                                                                          // Mark test as failed
     }

// --- Test 23: initial SELL stop below entry is rejected
   Print("Test 23 [B]: Invalid initial SELL stop");                                              // Test description
   MakeStop(valProp, 1006, EXIT_REASON_ATR, 99.00, "wrong side");                                // Stop below entry
   vres = validator.Validate(sellPos, valProp, validated, t);                                    // Validate
   if(vres == EXIT_RESULT_INVALID_PRICE)                                                         // Rejected
      Print("  PASS: Invalid initial SELL stop rejected");                                       // Pass
   else                                                                                          // Accepted
     {
      Print("  FAIL: Invalid initial SELL stop not rejected");                                   // Fail
      all_pass = false;                                                                          // Mark test as failed
     }

   Print("=== Deterministic and Broker-Aware Module Tests Complete ===");                        // Completion marker
   return all_pass;                                                                              // Overall result
  }

//+------------------------------------------------------------------+
