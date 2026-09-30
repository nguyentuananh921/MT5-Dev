//+------------------------------------------------------------------+
//|                            GUIPannel_SettingWindows_TS_Swing.mqh |
//| Swing tab: Strength/Wick controls + Show/Sound/Message table,    |
//| every value lives in m_SwingSetting (EA owns)                    |
//+------------------------------------------------------------------+
#ifndef __GUIPANNEL_SETTINGWINDOWS_TS_SWING_MQH__
#define __GUIPANNEL_SETTINGWINDOWS_TS_SWING_MQH__
 #define SETTING_BTN_SAVE_SWING_X_GAP 10
 #define SETTING_BTN_SAVE_SWING_Y_GAP 20
 #define COLUMNS_SWING_TOTAL          4
 #include "GUIPannel.mqh"
//--- 4 columns: Type / Show / Sound / Message, 2 fixed rows (High, Low), row == index
bool CGUIPannel::CreateTable_SwingSetting(const int x, const int y)
 {
  m_btn_save_swing_config.SetText("Save");
  m_btn_save_swing_config.IconFile(IMAGE_RESOURCE_BMP16_SAVE_PNG);
  m_tabs_setting_timeseries.AddToElementsArray(TAB_TAB_SETTING_TIMESERIES_SWING, m_btn_save_swing_config);
  if(!m_btn_save_swing_config.Create(m_chart_id, m_subwin, "BtnSaveSwing", x + SETTING_BTN_SAVE_SWING_X_GAP,
                                     y + SETTING_BTN_SAVE_SWING_Y_GAP, 80, M_CONTROL_HEIGHT)) return false;
  if(!CreateSwingParamControls(x + SETTING_BTN_SAVE_SWING_X_GAP + 80 + 20, y + SETTING_BTN_SAVE_SWING_Y_GAP)) return false;
  int table_y = y + SETTING_BTN_SAVE_SWING_Y_GAP + M_CONTROL_HEIGHT + SETTING_BTN_SAVE_SWING_Y_GAP;
  m_table_SwingSetting.TableSize(COLUMNS_SWING_TOTAL, 0);
  m_table_SwingSetting.View().ShowHeaders(true);
  m_table_SwingSetting.View().SelectableRow(true);
  m_table_SwingSetting.View().LightsHover(true);
  m_table_SwingSetting.View().IsSortMode(false);
  m_table_SwingSetting.AutoXResizeMode(true);
  m_table_SwingSetting.AutoXResizeRightOffset(3);
  m_table_SwingSetting.AutoYResizeMode(true);
  m_table_SwingSetting.AutoYResizeBottomOffset(3);
  m_tabs_setting_timeseries.AddToElementsArray(TAB_TAB_SETTING_TIMESERIES_SWING, m_table_SwingSetting);
  if(!m_table_SwingSetting.CreateTable(m_chart_id, m_subwin, "TableSwing", x, table_y)) return false;
  int widths[COLUMNS_SWING_TOTAL]            = {155, M_ICON16_WIDTH, M_ICON16_WIDTH, M_ICON16_WIDTH};
  int image_x[COLUMNS_SWING_TOTAL]           = {0, 2, 2, 2};
  ENUM_ALIGN_MODE align[COLUMNS_SWING_TOTAL] = {ALIGN_LEFT, ALIGN_LEFT, ALIGN_LEFT, ALIGN_LEFT};
  CTableHeaderView *header = m_table_SwingSetting.View().GetHeaderViewPointer();
  header.ColumnsWidth(widths);
  header.TextAlign(align);
  header.ImageXOffset(image_x);
  m_table_SwingSetting.SetHeaderText(0, "Swing");
  uint img_show[]    = {IMAGE_RESOURCE_BMP16_SIGNAL_PNG};
  uint img_sound[]   = {IMAGE_RESOURCE_BMP16_BELL_PNG};
  uint img_message[] = {IMAGE_RESOURCE_BMP16_MESSAGE_PNG};
  m_table_SwingSetting.SetHeaderText(1, "");  m_table_SwingSetting.SetHeaderImage(1, img_show);
  m_table_SwingSetting.SetHeaderText(2, "");  m_table_SwingSetting.SetHeaderImage(2, img_sound);
  m_table_SwingSetting.SetHeaderText(3, "");  m_table_SwingSetting.SetHeaderImage(3, img_message);
  m_table_SwingSetting.View().Rebuild(false);
  return true;
 }
void CGUIPannel::InitializeTable_SwingSetting(void)
 {
  m_table_SwingSetting.DeleteAllRows();
  ENUM_SWING_TYPE types[2] = {SWING_TYPE_HIGH, SWING_TYPE_LOW};
  for(int i = 0; i < 2; i++)
     m_table_SwingSetting.AddRow();
  for(int i = 0; i < 2; i++)
   {
    bool flags[3];
    flags[0] = (m_SwingSetting != NULL) && m_SwingSetting.SignalShow(types[i]);
    flags[1] = (m_SwingSetting != NULL) && m_SwingSetting.SoundAlert(types[i]);
    flags[2] = (m_SwingSetting != NULL) && m_SwingSetting.MessageAlert(types[i]);
    m_table_SwingSetting.SetValue(0, i, SwingTypeDescription(types[i]));
    for(int c = 0; c < 3; c++)
     {
      m_table_SwingSetting.CellView(c + 1, i).CellType(CELL_CHECKBOX);
      m_table_SwingSetting.SetValue(c + 1, i, (long)(flags[c] ? CANV_ELEMENT_CHEK_STATE_CHECKED : CANV_ELEMENT_CHEK_STATE_UNCHECKED));
     }
   }
  m_table_SwingSetting.View().Rebuild(true);
 }
//--- CTable already flipped the checkbox cell; Show changes the markers, so the bridge is told
void CGUIPannel::OnCheckTableSwingSetting(const int row, const int col)
 {
  if(m_SwingSetting == NULL || row < 0 || row > 1) return;
  ENUM_SWING_TYPE type = (row == 0) ? SWING_TYPE_HIGH : SWING_TYPE_LOW;
  bool on = (m_table_SwingSetting.Cell(col, row).ValueL() == CANV_ELEMENT_CHEK_STATE_CHECKED);
  if(col == 1)
   {
    if(m_SwingSetting.SignalShow(type, on))
       ::EventChartCustom(::ChartID(), (ushort)SWING_SETTING_EVENT_CHANGED, 0, 0.0, "");
   }
  else if(col == 2) m_SwingSetting.SoundAlert(type, on);
  else if(col == 3) m_SwingSetting.MessageAlert(type, on);
 }
//--- Strength spin-edit (caption built in) + Use Wick checkbox on the Save button's row
bool CGUIPannel::CreateSwingParamControls(const int x, const int y)
 {
  int  strength = (m_SwingSetting != NULL) ? m_SwingSetting.Strength() : 5;
  bool use_wick = (m_SwingSetting == NULL) || (m_SwingSetting.PriceBasis() == SWING_PRICE_BASIS_WICK);
  m_edit_swing_strength.SetText("Strength");
  m_edit_swing_strength.SpinEditMode(true);
  m_edit_swing_strength.MinValue(1);
  m_edit_swing_strength.MaxValue(50);
  m_edit_swing_strength.StepValue(1);
  m_tabs_setting_timeseries.AddToElementsArray(TAB_TAB_SETTING_TIMESERIES_SWING, m_edit_swing_strength);
  if(!m_edit_swing_strength.CreateTextEdit(m_chart_id, m_subwin, "EditSwingStrength", x, y, 120, M_CONTROL_HEIGHT, 60)) return false;
  m_edit_swing_strength.SetValue((string)strength);
  m_checkbox_swing_wick.SetText("Use Wick");
  m_tabs_setting_timeseries.AddToElementsArray(TAB_TAB_SETTING_TIMESERIES_SWING, m_checkbox_swing_wick);
  if(!m_checkbox_swing_wick.Create(m_chart_id, m_subwin, "CheckSwingWick", x + 120 + 15, y, M_SYMBOL_WIDTH, M_CONTROL_HEIGHT)) return false;
  m_checkbox_swing_wick.SetState(use_wick);
  return true;
 }
//--- CBarSwingControl reads N/PriceBasis from m_SwingSetting itself: update it, rescan every series
void CGUIPannel::ApplySwingParams(const int strength, const ENUM_SWING_PRICE_BASIS basis)
 {
  if(m_SwingSetting == NULL) return;
  bool changed = (m_SwingSetting.Strength() != strength || m_SwingSetting.PriceBasis() != basis);
  if(!changed) return;
  m_SwingSetting.Strength(strength);
  m_SwingSetting.PriceBasis(basis);
  CArrayObj *list_bts = (m_BarTimeSeriesCollection != NULL) ? m_BarTimeSeriesCollection.GetList() : NULL;
  int bts_total = (list_bts != NULL) ? list_bts.Total() : 0;
  for(int i = 0; i < bts_total; i++)
   {
    CBarTimeSeriesDE *bts = list_bts.At(i);
    CArrayObj *list_series = (bts != NULL) ? bts.GetListSeries() : NULL;
    int series_total = (list_series != NULL) ? list_series.Total() : 0;
    for(int j = 0; j < series_total; j++)
     {
      CBarSeriesDE *s = list_series.At(j);
      CBarSwingControl *ctrl = (s != NULL) ? s.GetSwingCtrlObj() : NULL;
      if(ctrl != NULL) ctrl.Rescan();
     }
   }
  ::EventChartCustom(::ChartID(), (ushort)SWING_SETTING_EVENT_CHANGED, 0, 0.0, "");
 }
void CGUIPannel::OnChangeSwingParams(void)
 {
  int n = (int)::StringToInteger(m_edit_swing_strength.GetValue());
  if(n < 1) { n = 1; m_edit_swing_strength.SetValue("1"); }
  ApplySwingParams(n, m_checkbox_swing_wick.State() ? SWING_PRICE_BASIS_WICK : SWING_PRICE_BASIS_BODY);
 }
#endif // __GUIPANNEL_SETTINGWINDOWS_TS_SWING_MQH__
