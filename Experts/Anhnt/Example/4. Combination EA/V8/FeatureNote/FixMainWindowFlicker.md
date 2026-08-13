# Fix Plan: m_window_main Flicker on New TF (not in Config)

## Overview
When the user switches the active chart to a Timeframe that is **not yet registered** in the Symbol/TF Config, `m_window_main` flickers once (visible redraw blink). Switching to a TF that **is already** in Config does not flicker.

---

## Symptom
- Reported by Anhnt (2026-08-10): "Khi tớ đổi một TF mới trên Chart (không có trong Config ấy) thì cái m_window_main bị fliker nháy một cái ấy."
- Only happens for a genuinely new Symbol/TF combo — one that causes a new series/slot to be created.

---

## Confirmed Root Cause (2026-08-10, via MY DEBUG log capture)

Log capture (`MQL5\Logs\20260810.log`) on a real H4 switch (a genuinely new TF, first time ever selected on chart):
```
20:46:34.966  CTimeSeriesEngine::OnChartEvent - is_new_series=false sym=XAUUSDm tf=PERIOD_H4
20:46:43.200  CGUIPannel::PopulateSymbolTFTree - BEFORE AddTreeItem new slot, actual=H4 tf_cnt=6 child_count=5
20:46:43.344  CGUIPannel::PopulateSymbolTFTree - AFTER AddTreeItem+AddToElementsArray
20:46:43.477  CGUIPannel::PopulateTableSymbolTFSetting - BEFORE AddRow, sym=XAUUSDm tf=H4 row=5 placeholder_only=false
20:46:43.480  CGUIPannel::PopulateTableSymbolTFSetting - BEFORE Update(true)
20:46:43.578  CGUIPannel::PopulateTableSymbolTFSetting - AFTER Update(true)
```
Two findings that refined the original hypothesis:
1. **`is_new_series` was `false`** at the moment of the chart switch — the `CBarSeriesDE` for H4 already existed before `OnChartEvent` fired (created by some earlier/different path, not this handler). So `CTimeSeriesEngine::CreateSeries()` is **not** part of the flicker's critical path — ruled out.
2. The real trigger is entirely inside `PopulateTableSymbolTFSetting()` ([GUIPannel_TabSettingSymbolTF.mqh:107](../Anatoli%20Kazharski/GUIPannel_TabSettingSymbolTF.mqh)): an **unconditional** `m_table_indicator_SymbolTFSeting.Update(true)`, which only fires when a genuinely new row gets `AddRow`'d (i.e. exactly the "TF not in Config" case). Reading `CTable::Update()` in the vendor Library (`Table.mqh:1864-1900`) confirmed `Update(true)` runs a full rebuild — `AutoResizeColumns` → `ChangeMainSize/TableSize` → `DrawTable` (whole-table repaint) → canvas/table/headers/**both scrollbars** — a much heavier operation than the `Update(false)` path (which still flushes `m_canvas/m_table/m_headers.Update()`, just skips the geometry recalc + full repaint + scrollbar resize).

This is the same anti-pattern the project already fixed twice before (`GUIPannel_Lifecycle.mqh:658-660`, `:711-714`: unconditional full-canvas `Update(true)` = the `m_window_main` blink), just re-introduced in `PopulateTableSymbolTFSetting()` — a method added later as an "incremental sync" ([doc-comment L75-79](../Anatoli%20Kazharski/GUIPannel_TabSettingSymbolTF.mqh)) that fell outside the scope of both earlier fixes. `GUIPannel_Lifecycle.mqh:669`'s own comment confirms MT5 already redraws natively on a real chart-symbol/TF change, so the manual `Update(true)` here was redundant on top of being expensive.

**Scope check**: `Table.mqh`/`TreeView.mqh`/`TreeItem.mqh` live in the vendor Library (`Vendors\Anhnt\Library\4. Combination Lib\GUI Lib\Controls\`), NOT under `Combination EA/` — reading them for diagnosis was fine, but the actual fix did not need to touch them. The one line that needed changing, `GUIPannel_TabSettingSymbolTF.mqh:107`, is EA-local (Anhnt confirmed 2026-08-10 that everything under `Combination EA/` counts as EA-local).

## Fix Applied (2026-08-10)
```diff
- m_table_indicator_SymbolTFSeting.Update(true);
+ m_table_indicator_SymbolTFSeting.Update(false);
```
`GUIPannel_TabSettingSymbolTF.mqh` — `CGUIPannel::PopulateTableSymbolTFSetting()`. `Update(false)` still flushes the just-added row's cells (`m_canvas/m_table/m_headers.Update()`), just skips the full-table rebuild that was the actual flicker.

---

## Original Root Cause Hypothesis (superseded — kept for history, see Confirmed Root Cause above)

### TF already in Config — no flicker
- `CTimeSeriesEngine::OnChartEvent` (`Artyom Trishkin\TimeSeriesEngine_Lifecycle.mqh`) sees `IsAvailable(sym, tf) == true` → skips `CreateSeries()` entirely.
- `PopulateSymbolTFTree` (`Anatoli Kazharski\GUIPannel_MainWindows.mqh`) matches the existing tree node positionally → label/icon-only branch, no `AddTreeItem`.
- `PopulateTableSymbolTFSetting` (`Anatoli Kazharski\GUIPannel_TabSettingSymbolTF.mqh`) finds `HasTableSymbolTFSettingRow() == true` → `continue`, no `AddRow`.
- Net effect: only pixel-level icon swaps on **already-existing** canvas objects. Nothing creates a new native chart object, so there's no second implicit redraw.

### TF NOT in Config — flicker
1. `CTimeSeriesEngine::OnChartEvent` (`TimeSeriesEngine_Lifecycle.mqh:58-83`) listens directly to native `CHARTEVENT_CHART_CHANGE`. `IsAvailable() == false` → synchronously runs `CreateSeries()` + `SeriesApplyPatternRegistry()` + `AddAllIndicatorsToNewSeries()`.
2. GUI itself does **not** react to native `CHARTEVENT_CHART_CHANGE` (see comment `GUIPannel_Lifecycle.mqh:702-704` — this was the 2026-07-14 fix). Instead it polls `CChartObjCollection` diff events (`CHART_OBJ_EVENT_CHART_SYMB_CHANGE/TF_CHANGE/SYMB_TF_CHANGE`, `GUIPannel_Lifecycle.mqh:661-671`) → `PopulateSymbolTFTree()` → `SynSymbolTFTreeViewIcons()` → `PopulateTableSymbolTFSetting()` → `SyncTableSymbolTFSettingCurrentChartIcon()` → `UpdateGUI(false)`.
3. Because step 1 already created a new series before the GUI polls, `PopulateSymbolTFTree` (`GUIPannel_MainWindows.mqh:160-174`, "New slot" branch) calls `m_treeview_SymbolTF.AddTreeItem(...)` → `CTreeItem::CreateTreeItem` → `CButton::CreateButton(text, x_gap, y_gap)` (`TreeItem.mqh:119`) — a brand-new native chart bitmap-label object created/drawn **synchronously mid-handler**.
4. Simultaneously `PopulateTableSymbolTFSetting` (`GUIPannel_TabSettingSymbolTF.mqh:80-108`) finds no existing row → `AddRow(row, false)` then an **unconditional** `m_table_indicator_SymbolTFSeting.Update(true)` at line 107.

### Historical context (BugNote.md)
- 2026-07-10 fix: removed two unconditional `Update(true)` calls from `UpdateGUI` (treeview + indicator table).
- 2026-07-14 fix (`GUIPannel_Lifecycle.mqh:655-660`): moved the SymbolTF tree/table rebuild off the native `CHARTEVENT_CHART_CHANGE` handler because it duplicated the refresh and called `ChartRedraw()` a second time right after `OnInitEvent`'s `REASON_CHARTCHANGE` redraw.
- **Both prior fixes targeted repainting already-existing controls.** Neither touched the object-**creation** path (`AddTreeItem` → `CreateButton`, `AddRow`) — that path still creates fresh native chart objects synchronously inside the polled-event handler. This is the most likely re-emergence of the same double-redraw class, specific to the "TF not yet in Config" case.

---

## Debug Plan (pending Anhnt go-ahead before inserting)
Per `V8/README.md` Working Rule, every temp Print must be tagged `MY DEBUG CClassName::MethodName`. Proposed insertion points:

1. **`GUIPannel_MainWindows.mqh` ~L160-174** (`CGUIPannel::PopulateSymbolTFTree`, "New slot" branch)
   ```cpp
   ::Print("MY DEBUG CGUIPannel::PopulateSymbolTFTree - BEFORE AddTreeItem new slot, tf_cnt=", tf_cnt);
   m_treeview_SymbolTF.AddTreeItem(...);
   ...
   ::Print("MY DEBUG CGUIPannel::PopulateSymbolTFTree - AFTER AddTreeItem+AddToElementsArray");
   ```

2. **`GUIPannel_TabSettingSymbolTF.mqh` ~L103-107** (`CGUIPannel::PopulateTableSymbolTFSetting`)
   ```cpp
   ::Print("MY DEBUG CGUIPannel::PopulateTableSymbolTFSetting - BEFORE AddRow, sym=", sym, " tf=", tf_text);
   m_table_indicator_SymbolTFSeting.AddRow(row, false);
   ...
   ::Print("MY DEBUG CGUIPannel::PopulateTableSymbolTFSetting - BEFORE Update(true)");
   m_table_indicator_SymbolTFSeting.Update(true);
   ::Print("MY DEBUG CGUIPannel::PopulateTableSymbolTFSetting - AFTER Update(true)");
   ```

3. **`TimeSeriesEngine_Lifecycle.mqh` ~L66-76** (`CTimeSeriesEngine::OnChartEvent`, `is_new_series` branch)
   ```cpp
   ::Print("MY DEBUG CTimeSeriesEngine::OnChartEvent - is_new_series TRUE, sym=", sym, " tf=", EnumToString(curr));
   CreateSeries(...);
   ...
   ::Print("MY DEBUG CTimeSeriesEngine::OnChartEvent - CreateSeries done");
   ```

**Goal**: confirm all 3 fire within the same tick/event when switching to a new TF, and that `AddTreeItem`/`AddRow`+`Update(true)` are the synchronous object-creation calls causing the extra redraw — before touching any real code.

---

## Files Involved
- `V8/Anatoli Kazharski/GUIPannel_MainWindows.mqh` — `PopulateSymbolTFTree`
- `V8/Anatoli Kazharski/GUIPannel_TabSettingSymbolTF.mqh` — `PopulateTableSymbolTFSetting`
- `V8/Artyom Trishkin/TimeSeriesEngine_Lifecycle.mqh` — `OnChartEvent` (`is_new_series` branch)
- `V8/Anatoli Kazharski/GUIPannel_Lifecycle.mqh` — for reference, existing 2026-07-14 fix comment (L655-660, L702-704)

All EA-local (confirmed by Anhnt 2026-08-10 — everything under `Combination EA/` counts, including the `Anatoli Kazharski`/`Artyom Trishkin` subfolders). Still requires presenting the concrete diff and getting go-ahead before each edit, per standing working rule.

---

## Status
- [x] Root cause hypothesis formed via code read (agent investigation, 2026-08-10)
- [x] Debug Print() inserted (2026-08-10) — `GUIPannel_MainWindows.mqh` (`PopulateSymbolTFTree`), `GUIPannel_TabSettingSymbolTF.mqh` (`PopulateTableSymbolTFSetting`), `TimeSeriesEngine_Lifecycle.mqh` (`OnChartEvent`)
- [x] Confirmed via real log capture — H4 switch (2026-08-10 20:46), see "Confirmed Root Cause" above
- [x] Fix proposed and applied (2026-08-10) — `GUIPannel_TabSettingSymbolTF.mqh:107`, `Update(true)` → `Update(false)`
- [x] Debug `MY DEBUG` Print() lines removed (2026-08-10) — `GUIPannel_MainWindows.mqh`, `GUIPannel_TabSettingSymbolTF.mqh`, `TimeSeriesEngine_Lifecycle.mqh` all clean
- [ ] Verified flicker gone long-term (Anhnt to keep an eye out switching TFs going forward)
