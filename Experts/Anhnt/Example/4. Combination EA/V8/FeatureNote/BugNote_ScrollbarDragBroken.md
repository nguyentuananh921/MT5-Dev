# CScrollV Thumb Drag Broken in ComboBox

**Date:** 2026-08-09  
**Status:** Open  
**Severity:** Medium — affects Sound file selection in Marker settings

## Issue
CScrollV (vertical scrollbar in Kazharski's GUI Lib) thumb drag does not work reliably. When a combobox (e.g., "Buy Sound") contains many items (30+), users cannot scroll to the bottom to select files because:

1. Dropdown height is capped at 300px (dòng 221 in GUIPannel_TabSettingMarker.mqh:CreateMarkerTabComboBox)
2. Small scrollbar thumb is hard to drag
3. Thumb drag sometimes freezes or doesn't respond

## Affected Code
- **Library:** `MQL5\Include\Vendors\Anhnt\Library\4. Combination Lib\GUI Lib\Controls\Scrolls.mqh` (CScrollV class)
- **EA File:** `GUIPannel_TabSettingMarker.mqh:CreateMarkerTabComboBox()` (dòng 220-221)
  ```cpp
  int list_h = 18 * n + 4;
  if(list_h > 300) list_h = 300;  // Hard cap
  combo.GetListViewPointer().YSize(list_h);
  ```

## User Feedback
User (Anhnt, 2026-07-17): "scrollbar khó kéo, chọn không được"

## Root Cause (CONFIRMED)
**File:** `Scrolls.mqh:CScrollV::ScrollBarControl()` (dòng 638-665)  
**Flow:**
1. Dòng 649: `CheckThumbFocus(x, y)` — update m_thumb_focus based on current mouse position (inside/outside thumb rect)
2. Dòng 651: `CheckMouseButtonState()` — if mouse left-btn pressed:
   - If m_thumb_focus = true → set m_scroll_state = true (line 390)
   - If m_thumb_focus = false → set m_scroll_state = false implicitly (line 385-386: m_clamping_area_mouse = PRESSED_OUTSIDE)
3. Dòng 656: `OnDragThumb(y)` — only executes if m_scroll_state = true

**The Bug:** When user drags thumb and mouse moves slightly outside thumb rect boundaries, CheckThumbFocus (line 649) sets m_thumb_focus = false. Then CheckMouseButtonState (line 651) implicitly resets m_scroll_state = false (no state saved for "already dragging"). Result: drag stops after few pixels.

**Why it's hard to drag:** Scrollbar thumb is small (15-30px), so even slight mouse movement outside rect breaks the drag.

## Fix Required (Library Edit)
CScrollV needs to track "currently dragging" state separate from "currently hovering" state:
- Keep m_scroll_state = true while dragging, even if mouse moves outside thumb rect
- Only reset m_scroll_state when mouse left-btn is RELEASED
- OR: Widen thumb "hit region" by ~5px on each side for easier drag (slop region)

## Workarounds (No Library Edit)
1. **Autodetect available height:** Calculate available screen/tab space and set dropdown height dynamically instead of hard cap 300px → no scroll needed → thumb drag not needed
2. **Alternative control:** Implement custom lightweight combobox for Sound files (bypass CScrollV)
3. **Increase cap height:** Set 400-500px cap instead of 300px (requires more vertical space in tab)

## Recommended Path
→ **Use autodetect height solution (Option 1)** — solves root problem (too many files, too little space), avoids Library edit, no scrollbar needed
