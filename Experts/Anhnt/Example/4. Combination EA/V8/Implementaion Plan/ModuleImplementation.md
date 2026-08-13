# Implementation Plan - GUIPannel.mqh Module Reorganization

## Goal
Clean up `GUIPannel.mqh` so that Properties and Methods belonging to the same Tab-group sit near each other and share the same indentation depth, making VS Code's indentation-based folding line up: folding a Tab's Properties block and folding its Methods block should feel like mirror images of each other.

Two working rules (confirmed with Anhnt 2026-08-10):
1. **Order**: the order of Tab-groups in the Methods block (`private:` section, then relevant `public:` setters) must mirror the order already established in the Properties block.
2. **Indentation**: normalize toward **+2 spaces per nesting level** (the majority style already used in Properties, e.g. line 61→62, 74→75) — not yet applied, pending explicit go-ahead per spot.

Reference Tab-group order (as laid out in Properties, `private:` lines 15-190):
1. Layer 1 Pure Data (pointers)
2. Main window (`m_window_main`, `m_treeview_SymbolTF`, `m_tabs_main`, `m_status_bar`)
3. TAB_TAB_MAIN_MONITOR
4. TAB_TAB_MAIN_POSITIONS
5. TAB_TAB_MAIN_SETTINGS — Indicator (treeview + add-form + template table)
6. TAB_TAB_MAIN_SETTINGS_CONFIG_SYMBOL_TF
7. TAB_TAB_MAIN_SETTINGS_CONFIG_CANDLE_PATTERN
8. TAB_TAB_MAIN_SETTINGS_CONFIG_MARKER
9. Candle info window (`m_window_candle_infomation`)
10. SoundAndMessageAlerts (live-signal tracking arrays)
11. Layer-3 chart-object observer
12. Layer-4 IO (signal bridge / logger)
13. GUI guard / trading bubble

> Note: `GUIPannel.mqh` is being hand-edited by Anhnt in the IDE in parallel with this review, so line numbers below already drifted once during the 2026-08-10 session and will likely drift again. Re-check line numbers against current file state before editing.

---

## Current State (as of 2026-08-10)

### Properties block (`private:` lines 15-190) — reviewed only, not yet fixed
Content/grouping is correct and matches the Tab order above. Found 5 indentation-drift spots (all cosmetic, no functional impact):

- **A** — Marker tab (header ~L92): sub-header "For Marker 8 independent shapes..." (~L93) sits 1 column shallower than its 5 sibling sub-headers (~L102, 112, 120, 122, 131).
- **B** — Settings-SymbolTF (~L81-84) and Settings-CandlePattern (~L87-91): properties jump 3 indent levels straight from their header with no intermediate grouping comment, unlike every other "leaf" group in the file (which jumps only 1 level).
- **C** — Main window block (~L29-36): header "For Main window..." (L29) is 1 level shallower than its 3 sibling sub-headers (TreeView/MainTab/StatusBar, ~L31/33/35), even though all four are peers.
- **D** — Layer-3 / Layer-4 / guard / trading-bubble (~L177-190): all 4 headers sit at the same column (peers), but their immediate properties jump inconsistently (+1 / +3 / +2 / +1 levels).
- **E** — Minor: a blank line (~L130) carries stray trailing indentation.

Decision: leave as-is for now (Anhnt: "chỗ ấy hơi lệch căn lề một tí, không sao đâu") — not blocking, revisit later if it starts bothering folding.

### Methods block (`private:` ~L192-333, `public:` ~L336-362) — reviewed, needs real reordering (not just indentation)
Content mostly matches the right Tab-group, but **overall order does not mirror Properties order**, and a few headers are stale or mis-nested.

1. **Order mismatch (main finding)**: Properties order is `...Positions(#4) → Settings-Indicator(#5) → Settings-SymbolTF(#6) → CandlePattern(#7) → Marker(#8) → CandleInfoWindow(#9) → SoundAlerts(#10)...`, but Methods currently has CandleInfo-popup / SignalMarker-attach / JSON-save-load / SoundAlerts methods inserted **between** Positions and Settings-Indicator, i.e. groups #9 and #10 are firing before #5-#8. The 4 Settings sub-tabs (Indicator→SymbolTF→CandlePattern→Marker) are internally in the right relative order, they just need to move up as a block to sit directly after the Positions methods.
2. **Stale/duplicate headers**: a run of ~4 comment lines duplicate earlier headers ("For nested config tabs...", "For TreeView...", "Handler for TreeView...", "For Indicator Table...") but sit above methods that are actually indicator/catalog-vs-chart sync helpers (`IsIndicatorShownOnChart`, `LineRepresentsIndicator`, `OwnedInstanceOfLine`, `DetachIndicatorFromChart`, `ImportForeignChartIndicators`, `BuildTemplateMatchKey`, `ApplyLoadedIndicatorBuySell`, `BuildIndicatorLabel`, `PurgeSignalArrowObjects`) — headers don't describe the content below them anymore.
3. **Settings-SymbolTF / CandlePattern / Marker headers demoted**: their top-level headers sit 1-2 levels deeper than their Settings-Indicator sibling, because they ended up nested under a `//----Unfininished` marker comment instead of getting their own top-level header (Properties has all 4 Settings sub-tab headers as clean peers).
4. **Indentation jump**: the block behind the stale headers in finding #2 jumps 3 levels with no intermediate comment (same shape as Properties finding B).
5. **Footnote, not a folding issue**: `m_tick_series` (Properties, live/uncommented pointer) has its only setter `SetTickSeriesCollection` commented out in the `public:` section — likely just "not wired yet," confirm before touching.

---

## Outstanding / Next Actions
- [ ] Decide whether to apply the Properties indentation normalization (A-E) — currently deferred per Anhnt.
- [ ] Move the CandleInfo-popup / SignalMarker-attach / JSON-save-load / SoundAlerts method block to *after* the Marker-settings group, so Settings-Indicator directly follows Positions (matches Properties #4→#5).
- [ ] Rewrite the stale duplicate headers (finding #2) to actually describe the indicator/catalog/chart-sync helpers underneath.
- [ ] Promote Settings-SymbolTF / CandlePattern / Marker headers back to top-level (peers of Settings-Indicator), drop or repurpose the `//----Unfininished` marker.
- [ ] Fix the orphaned indentation jump from finding #4 once the header above it is corrected.
- [ ] Confirm intent behind the commented-out `SetTickSeriesCollection` setter vs. the live `m_tick_series` property.

## Files
- `V8/Anatoli Kazharski/GUIPannel.mqh` — only file touched by this reorg; the `.mqh` module implementation files it declares for are unaffected (declaration-only cleanup).
