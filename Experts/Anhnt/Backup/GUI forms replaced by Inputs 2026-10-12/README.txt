Removed on 2026-10-12 when the scalar settings became EA Inputs (same files are in git, commit 9679272):
 - GUIPannel_SettingWindows_Alert.mqh        the "Setting Marker and Sound" window
 - GUIPannel_SettingWindows_Alert_Marker.mqh the Marker tab (colour combos, Show Marker check boxes)
 - GUIPannel_SettingWindows_TS_Swing.mqh     the Smart Money tab (table, Strength, Wick)
 - MarkerSetting / SmartMoneySetting         the JSON versions
The GUI library (CWindow, CTable, CTabs, CFrame...) is untouched and still builds the list settings.
