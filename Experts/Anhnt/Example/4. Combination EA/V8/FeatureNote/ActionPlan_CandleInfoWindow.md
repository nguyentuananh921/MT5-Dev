# Action Plan: Candle Information Window Display (m_window_candle_infomation)

## Overview
Enhance or refactor the Candle Information Window (`GUIPannel_CandleInfoWindow.mqh`) to display indicator + pattern signals in the info table.

---

## Current State
[From `GUIPannel_CandleInfoWindow.mqh`]

### RefreshCandleInfoWindow() - Lines 208-317
1. **Indicator Signals Collection** (lines 208-283):
   - Iterates indicators by symbol & timeframe
   - Collects signal history flips within [bar_time, next_bar_time)
   - Extracts: indicator label, TF text, direction (BUY/SELL), time
   - Special handling for BBands: Upper/Lower line crosses (skip Mid)

2. **Pattern Signals Collection** (lines 285-317):
   - Iterates `GetListAllPatterns()` → all patterns
   - Filters by symbol
   - Checks time span [bar_time, next_bar_time)
   - Extracts: pattern name + candle count "[2B] Engulfing", TF, direction, time
   - Combines patterns with same direction into one signal?

3. **Display** (lines 318-349):
   - Collects all rows (indicator + pattern)
   - Sorts by time ascending
   - Renders in table with arrow icons + color coding

---

## Questions / Observations
- **Pattern Aggregation**: When multiple patterns on same bar → are they combined into 1 row or separate rows?
  - Code suggests separate rows (each pattern gets its own ArrayResize)
  - But implementation_planCandlePattern says "1 signal per bar" for bridge file — does this also apply to UI display?
  
- **Candle Prefix Format**: Pattern names show `[candles]` prefix (e.g., "[2B] Engulfing")
  - Is this the final format, or just a draft?

- **Pattern Direction Mapping**: 
  ```cpp
  ENUM_SIGNAL_DIR dir = (pdir == PATTERN_DIRECTION_BULLISH) ? SIGNAL_BUY :
                        (pdir == PATTERN_DIRECTION_BEARISH) ? SIGNAL_SELL : SIGNAL_NONE;
  ```
  - Correctly maps PATTERN_DIRECTION → SIGNAL_DIR

---

## Proposed Tasks

### Task 1: Reorganize Table Columns
**Goal**: Move TF column to position 1 (left side) and add source icon

**Current Structure** (CreateWindowCandleInfo, lines 135-153):
- Col 0: Time (55px)
- Col 1: Information + Direction Arrow icon (150px)
- Col 2: TF (45px)

**New Structure**:
- Col 0: Time (55px)
- Col 1: TF + Source Icon (45px) — **dịch sang trái, thêm icon**
- Col 2: Information + Direction Arrow icon (150px)

**Changes**:
1. **CreateWindowCandleInfo()** (lines 135-153):
   - Reorder columns: [Time, TF, Information]
   - Update TableSize(), ColumnsWidth(), header text order
   - Adjust image/text offsets for col 1 (TF icon column)

2. **RefreshCandleInfoWindow()** (lines 212-358):
   - Add `row_source[]` array to track source type (Indicator vs Pattern)
   - During collection (lines 217-317):
     - Indicator signals → row_source[count] = INDICATOR
     - Pattern signals → row_source[count] = PATTERN
   - During render (lines 344-355):
     - Col 1 SetImages: [IMAGE_RESOURCE_BMP16_INDICATOR_BMP, IMAGE_RESOURCE_BMP16_CANDLE_PNG, ...]
     - Col 1 ChangeImage: use row_source[row] to select indicator (69) or pattern (42) icon
     - Col 0: Time (unchanged)
     - Col 2: Information + Direction Arrow (unchanged)

---

## Files to Modify
- `GUIPannel_CandleInfoWindow.mqh` — CreateWindowCandleInfo() + RefreshCandleInfoWindow()

---

## Implementation Notes
- Source icons: 
  - Indicator = `IMAGE_RESOURCE_BMP16_INDICATOR_BMP` (69)
  - Pattern = `IMAGE_RESOURCE_BMP16_CANDLE_PNG` (42)
- Direction arrow still renders on Col 2 (Information column) as before
- Time column layout unchanged
