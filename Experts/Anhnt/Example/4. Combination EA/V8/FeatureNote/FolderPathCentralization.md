# Folder Path Centralization Issue & Solution

## Current Issue

**Problem**: SignalMarkers.mq5 indicator không render markers trên chart khi thay đổi Symbol vì không tìm được bridge file.

**Root Cause**:
- EA (GUIPannel_Lifecycle.mqh line 160) dùng `MQLInfoString(MQL_PROGRAM_NAME)` = `"EA Using Combination Lib V8"`
- Bridge files được viết vào folder: `MQL5/Files/EA Ussing Combination Lib V8/` (chính tả sai "Ussing")
- SignalMarkers.mq5 cố đọc từ: `MQL5/Files/EA Using Combination Lib V8/` (chính tả đúng)
- **Path mismatch** → FileOpen fail → no markers rendered

**Affected Components**:
1. SignalBridgeWriter - writes to wrong folder path
2. SignalLogger - writes to wrong folder path  
3. GUIPannel_JSONConfig - reads/writes config to wrong folder path
4. SignalMarkers.mq5 - reads bridge file from wrong folder path

## Solution Architecture

**EA as Centralization Point**: 
- EA (GUIPannel) will determine correct folder path **once at startup**
- EA distributes this folder path to all child components
- All components follow EA's designated folder path

## Implementation Plan

### Phase 1: EA Centralization (GUIPannel)
- [ ] Create `CGUIPannel::GetDataFolder()` method
  - Scans MQL5/Files to find actual folder (case-insensitive match or file-system scan)
  - Returns absolute path or relative folder name
  - Called once in `OnInitEvent()` before initializing any file writers

- [ ] Store result in `m_data_folder` member variable
  
- [ ] Update `GUIPannel_Lifecycle.mqh` OnInitEvent():
  ```cpp
  m_data_folder = GetDataFolder();  // ← Centralized determination
  m_signal_logger.SetFolder(m_data_folder);
  m_bridge_writer.SetFolder(m_data_folder);
  ```

### Phase 2: SignalMarkers.mq5 Indicator Integration
- [ ] GUIPannel_SignalMarkers.mqh `EnsureMarkerIndicatorAttached()` passes `m_data_folder` as 12th iCustom parameter
- [ ] SignalMarkers.mq5 receives folder path and uses it to locate bridge file

### Phase 3: GUIPannel_JSONConfig.mqh Update
- [ ] All file operations use `m_data_folder` instead of `MQL_PROGRAM_NAME`
- [ ] SavePatternAlertConfigToJSON() uses `m_data_folder`
- [ ] SaveMarkerSettingsToJSON() uses `m_data_folder`

## Status
- [x] Issue identified
- [ ] EA centralization method implemented
- [ ] All components updated to use EA-provided folder path
- [ ] Testing with SignalMarkers indicator

## Notes
- Folder discovery method TBD: scan filesystem vs. config file vs. MQL_PROGRAM_PATH parsing
- Current folder name discrepancy: "EA Using..." (code) vs "EA Ussing..." (physical)
