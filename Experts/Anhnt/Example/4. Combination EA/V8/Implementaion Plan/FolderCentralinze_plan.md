# Implementation Plan - Folder Path Centralization

Determine a single centralized folder path once at EA startup and distribute it to all child components (TimeSeriesEngine, SignalBridgeWriter, SignalLogger, JSONConfig, and SignalMarkers indicator).

This ensures that even if the EA is compiled under a different name (e.g., misspelled `"EA Ussing Combination Lib V8"` vs. correctly spelled `"EA Using Combination Lib V8"`), all components read/write to the correct folder.

## Proposed Changes

---

### Component: GUI Panel Core

#### [MODIFY] [GUIPannel.mqh](file:///c:/Users/nguye/AppData/Roaming/MetaQuotes/Terminal/D0E8209F77C8CF37AD8BF550E51FF075/MQL5/Experts/Anhnt/Example/4.%20Combination%20EA/V8/Anatoli%20Kazharski/GUIPannel.mqh)
- Declare private member variable `string m_data_folder;` to store the centralized folder name.
- Declare public static method `static string GetDataFolder(void);` to scan `MQL5/Files/` for matching folders.
- Declare public setter `void SetFolder(const string folder) { m_data_folder = folder; }` to receive the centralized path.

#### [MODIFY] [GUIPannel_Lifecycle.mqh](file:///c:/Users/nguye/AppData/Roaming/MetaQuotes/Terminal/D0E8209F77C8CF37AD8BF550E51FF075/MQL5/Experts/Anhnt/Example/4.%20Combination%20EA/V8/Anatoli%20Kazharski/GUIPannel_Lifecycle.mqh)
- Initialize `m_data_folder = "";` in the constructor.
- Implement `string CGUIPannel::GetDataFolder(void)`:
  - Scans directories in `MQL5/Files/` using `FileFindFirst("*", name)` and `FileFindNext()`.
  - Performs case-insensitive matching against `MQLInfoString(MQL_PROGRAM_NAME)` and its alternative spelling (swapping `"Using"` <-> `"Ussing"`).
  - Returns the matched folder name if found; otherwise, defaults to `MQLInfoString(MQL_PROGRAM_NAME)`.
- Update `OnInitEvent()`:
  - Remove the local retrieval of `ea_folder = MQLInfoString(MQL_PROGRAM_NAME)`.
  - Pass the centralized `m_data_folder` to `m_signal_logger.SetFolder()` and `m_bridge_writer.SetFolder()`.

---

### Component: Time Series Engine

#### [MODIFY] [TimeSeriesEngine.mqh](file:///c:/Users/nguye/AppData/Roaming/MetaQuotes/Terminal/D0E8209F77C8CF37AD8BF550E51FF075/MQL5/Experts/Anhnt/Example/4.%20Combination%20EA/V8/Artyom%20Trishkin/TimeSeriesEngine.mqh)
- Declare private static member variable `static string m_data_folder;`.
- Declare public static setter `static void SetFolder(const string folder) { m_data_folder = folder; }` so the EA can distribute the folder path to it before initialization.

#### [MODIFY] [TimeSeriesEngine_JSONConfig.mqh](file:///c:/Users/nguye/AppData/Roaming/MetaQuotes/Terminal/D0E8209F77C8CF37AD8BF550E51FF075/MQL5/Experts/Anhnt/Example/4.%20Combination%20EA/V8/Artyom%20Trishkin/TimeSeriesEngine_JSONConfig.mqh)
- Initialize `string CTimeSeriesEngine::m_data_folder = "";`.
- Update `LoadConfigurationFromJSON()`, `SaveConfigurationToJSON()`, and `RemoveSymbolTFFromConfigJSON()`:
  - Replace `string ea_folder = MQLInfoString(MQL_PROGRAM_NAME);` with `string ea_folder = (m_data_folder != "") ? m_data_folder : MQLInfoString(MQL_PROGRAM_NAME);`.

---

### Component: EA Main Entry

#### [MODIFY] [EA Ussing Combination Lib V8.mq5](file:///c:/Users/nguye/AppData/Roaming/MetaQuotes/Terminal/D0E8209F77C8CF37AD8BF550E51FF075/MQL5/Experts/Anhnt/Example/4.%20Combination%20EA/V8/EA%20Ussing%20Combination%20Lib%20V8.mq5)
- In `OnInit()`:
  - Call `CGUIPannel::GetDataFolder()` to scan and retrieve the actual data folder.
  - Distribute it to the engine: `CTimeSeriesEngine::SetFolder(data_folder)`.
  - Distribute it to the GUI: `mGUIPannel.SetFolder(data_folder)`.
  - (Proceed with `timeSeriesEngine.OnInitEvent()` and `mGUIPannel.OnInitEvent()` calls).

---

### Component: GUI Panel Features & Configs

#### [MODIFY] [GUIPannel_JSONConfig.mqh](file:///c:/Users/nguye/AppData/Roaming/MetaQuotes/Terminal/D0E8209F77C8CF37AD8BF550E51FF075/MQL5/Experts/Anhnt/Example/4.%20Combination%20EA/V8/Anatoli%20Kazharski/GUIPannel_JSONConfig.mqh)
- In `SavePatternAlertConfigToJSON()` and `SaveMarkerSettingsToJSON()`:
  - Replace `ea_folder = MQLInfoString(MQL_PROGRAM_NAME)` with `ea_folder = (m_data_folder != "") ? m_data_folder : MQLInfoString(MQL_PROGRAM_NAME)`.
- In `LoadMarkerSettingsFromJSON()` and `LoadPatternAlertConfigFromJSON()`:
  - Construct the correct file path using `m_data_folder` (e.g., `m_data_folder + "/Config_Setting.json"`) instead of reading from root `"Config_Setting.json"`.

#### [MODIFY] [GUIPannel_SignalMarkers.mqh](file:///c:/Users/nguye/AppData/Roaming/MetaQuotes/Terminal/D0E8209F77C8CF37AD8BF550E51FF075/MQL5/Experts/Anhnt/Example/4.%20Combination%20EA/V8/Anatoli%20Kazharski/GUIPannel_SignalMarkers.mqh)
- In `EnsureMarkerIndicatorAttached()`:
  - Determine folder: `string folder = (m_data_folder != "") ? m_data_folder : MQLInfoString(MQL_PROGRAM_NAME);`.
  - Pass `folder` to the 12th parameter of the `iCustom()` call instead of `ea_folder`.

#### [MODIFY] [GUIPannel_SoundAndMessageAlerts.mqh](file:///c:/Users/nguye/AppData/Roaming/MetaQuotes/Terminal/D0E8209F77C8CF37AD8BF550E51FF075/MQL5/Experts/Anhnt/Example/4.%20Combination%20EA/V8/Anatoli%20Kazharski/GUIPannel_SoundAndMessageAlerts.mqh)
- In `CheckCandlePatternAlerts()`:
  - Replace `ea_folder = MQLInfoString(MQL_PROGRAM_NAME)` with `ea_folder = (m_data_folder != "") ? m_data_folder : MQLInfoString(MQL_PROGRAM_NAME)`.

---

## Verification Plan

### Manual Verification
- Check if EA compilation is successful.
- Run the EA on a chart. Check the terminal logs to ensure `Config_Setting.json` is successfully loaded and saved into the folder `MQL5/Files/EA Ussing Combination Lib V8/`.
- Change chart symbols and check if `SignalMarkers.mq5` starts rendering marker arrows on the chart.
- Verify that `SignalMarkers.mq5` logs in the Experts tab show it successfully reading from `MQL5/Files/EA Ussing Combination Lib V8/SignalBridge_*.dat`.
