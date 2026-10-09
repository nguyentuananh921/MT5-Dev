//+------------------------------------------------------------------+
//|                            GUIPannel_SettingWindows_TS_Swing.mqh |
//| Swing sub-tab: Strength/Wick controls + Show/Sound/Message table. |
//| Every value is read from / written to m_SwingSetting (EA owns) - |
//| this module holds no copy and does no JSON.                      |
//+------------------------------------------------------------------+
#ifndef __GUIPANNEL_SETTINGWINDOWS_TS_SWING_MQH__
#define __GUIPANNEL_SETTINGWINDOWS_TS_SWING_MQH__
 #define SETTING_BTN_SAVE_SWING_X_GAP 10
 #define SETTING_BTN_SAVE_SWING_Y_GAP 20
 #include "GUIPannel.mqh"
//+------------------------------------------------------------------+
//| Create Save button, param controls and m_table_SwingSetting -     |
//| 4 columns: Type / Show / Sound / Message, 2 fixed rows (Swing     |
//| High, Swing Low). IsSortMode(false) - row==index always.          |
//+------------------------------------------------------------------+
bool CGUIPannel::CreateTable_SwingSetting(const int x, const int y)
 {
   // Step 1: Create Save Button ABOVE the table
    m_btn_save_swing_config.MainPointer(m_tabs_setting_timeseries);
    m_tabs_setting_timeseries.AddToElementsArray(TAB_TAB_SETTING_TIMESERIES_SWING, m_btn_save_swing_config);
    m_btn_save_swing_config.AutoXResizeMode(false);
    m_btn_save_swing_config.XSize(80);
    m_btn_save_swing_config.YSize(M_CONTROL_HEIGHT);
    m_btn_save_swing_config.IconFile(IMAGE_RESOURCE_BMP16_SAVE_PNG);
    if(!m_btn_save_swing_config.CreateButton("Save", x+SETTING_BTN_SAVE_SWING_X_GAP, y+SETTING_BTN_SAVE_SWING_Y_GAP)) return false;
    CWndContainer::AddToElementsArray(WindowIdx(m_window_setting_timeseries), m_btn_save_swing_config);
    if(!CreateSwingParamControls(x + SETTING_BTN_SAVE_SWING_X_GAP + 80 + 20, y + SETTING_BTN_SAVE_SWING_Y_GAP)) return false;

   // Step 2: Create Table BELOW button
    int table_y = y + SETTING_BTN_SAVE_SWING_Y_GAP + M_CONTROL_HEIGHT + SETTING_BTN_SAVE_SWING_Y_GAP;
    m_table_SwingSetting.MainPointer(m_tabs_setting_timeseries);
    m_tabs_setting_timeseries.AddToElementsArray(TAB_TAB_SETTING_TIMESERIES_SWING, m_table_SwingSetting);
    m_table_SwingSetting.AutoXResizeMode(true);
    m_table_SwingSetting.AutoXResizeRightOffset(3);
    m_table_SwingSetting.AutoYResizeMode(true);
    m_table_SwingSetting.AutoYResizeBottomOffset(3);
    m_table_SwingSetting.LightsHover(true);
    m_table_SwingSetting.ShowHeaders(true);
    m_table_SwingSetting.SelectableRow(true);
    m_table_SwingSetting.IsSortMode(false);
    m_table_SwingSetting.TableSize(4, 2);
    int widths[4]    = {155, 30, 30, 30};
    int img_x_off[4] = {0, 10, 7, 7};
    int img_y_off[4] = {0, 3, 3, 3};
    ENUM_ALIGN_MODE align[4] = {ALIGN_LEFT,ALIGN_LEFT,ALIGN_LEFT,ALIGN_LEFT};
    m_table_SwingSetting.ColumnsWidth(widths);
    m_table_SwingSetting.ImageXOffset(img_x_off);
    m_table_SwingSetting.ImageYOffset(img_y_off);
    m_table_SwingSetting.TextAlign(align);
   // ← Create BEFORE SetHeaderText
    if(!m_table_SwingSetting.CreateTable(x, table_y)) return false;
    m_table_SwingSetting.SetHeaderText(0, "Swing");
    // Show - single column, no Buy/Sell split: a Swing High is always Sell-context and a
    // Swing Low always Buy-context, so the row's type already fixes the direction.
     uint resource_indices_show[] = {IMAGE_RESOURCE_BMP16_SIGNAL_PNG};
     m_table_SwingSetting.SetHeaderText(1, "");
     m_table_SwingSetting.SetHeaderImage(1, resource_indices_show);
    // Sound
     uint resource_indices_sound[] = {IMAGE_RESOURCE_BMP16_BELL_PNG};
     m_table_SwingSetting.SetHeaderText(2, "");
     m_table_SwingSetting.SetHeaderImage(2, resource_indices_sound);
    // Message
     uint resource_indices_message[] = {IMAGE_RESOURCE_BMP16_MESSAGE_PNG};
     m_table_SwingSetting.SetHeaderText(3, "");
     m_table_SwingSetting.SetHeaderImage(3, resource_indices_message);
    CWndContainer::AddToElementsArray(WindowIdx(m_window_setting_timeseries), m_table_SwingSetting);
    return true;
 }
//+------------------------------------------------------------------+
//| (Re)paint the 2 fixed rows from m_SwingSetting.                   |
//+------------------------------------------------------------------+
void CGUIPannel::InitializeTable_SwingSetting(void)
 {   
   m_table_SwingSetting.DeleteAllRows();
   m_table_SwingSetting.AddRow(0);

   uint chk[] = {IMAGE_RESOURCE_BMP16_CHECKBOX_ON_G_PNG,
                 IMAGE_RESOURCE_BMP16_CHECKBOX_OFF_BMP};
   ENUM_SWING_TYPE types[2] = {SWING_TYPE_HIGH, SWING_TYPE_LOW};
   for(int i = 0; i < 2; i++)
    {
      bool show  = (m_SwingSetting != NULL) && m_SwingSetting.SignalShow(types[i]);
      bool sound = (m_SwingSetting != NULL) && m_SwingSetting.SoundAlert(types[i]);
      bool msg   = (m_SwingSetting != NULL) && m_SwingSetting.MessageAlert(types[i]);
      m_table_SwingSetting.SetValue(0, i, SwingTypeDescription(types[i]));

      m_table_SwingSetting.CellType(1, i, CELL_CHECKBOX);
      m_table_SwingSetting.SetImages(1, i, chk);
      m_table_SwingSetting.ChangeImage(1, i, show ? CHECKBOX_STATE_ON : CHECKBOX_STATE_OFF);

      m_table_SwingSetting.CellType(2, i, CELL_CHECKBOX);
      m_table_SwingSetting.SetImages(2, i, chk);
      m_table_SwingSetting.ChangeImage(2, i, sound ? CHECKBOX_STATE_ON : CHECKBOX_STATE_OFF);

      m_table_SwingSetting.CellType(3, i, CELL_CHECKBOX);
      m_table_SwingSetting.SetImages(3, i, chk);
      m_table_SwingSetting.ChangeImage(3, i, msg ? CHECKBOX_STATE_ON : CHECKBOX_STATE_OFF);
    }
 }
//+------------------------------------------------------------------+
//| Checkbox toggle handler for m_table_SwingSetting - col 1=Show,    |
//| 2=Sound, 3=Message. row 0=High, 1=Low (IsSortMode(false)).        |
//| Commits straight onto m_SwingSetting (Single Source of Truth).    |
//+------------------------------------------------------------------+
void CGUIPannel::OnCheckTableSwingSetting(const int row, const int col)
 {
   if(m_SwingSetting == NULL || row < 0 || row > 1) return;
   ENUM_SWING_TYPE type = (row == 0) ? SWING_TYPE_HIGH : SWING_TYPE_LOW;
   bool on = ((int)m_table_SwingSetting.SelectedImageIndex(col, row) == CHECKBOX_STATE_ON);
   if(col == 1)      m_SwingSetting.SignalShow(type, on);
   else if(col == 2) m_SwingSetting.SoundAlert(type, on);
   else if(col == 3) m_SwingSetting.MessageAlert(type, on);
 }
//+------------------------------------------------------------------+
//| Strength (N) spin-edit + Wick/Body checkbox, on the Save button's |
//| row. Initial values come from m_SwingSetting (already loaded from |
//| JSON by CTimeSeriesEngine::OnInitEvent, which runs first).        |
//+------------------------------------------------------------------+
bool CGUIPannel::CreateSwingParamControls(const int x, const int y)
 {
    int  strength = (m_SwingSetting != NULL) ? m_SwingSetting.Strength() : 5;
    bool use_wick = (m_SwingSetting == NULL) || (m_SwingSetting.PriceBasis() == SWING_PRICE_BASIS_WICK);

    m_label_swing_strength.MainPointer(m_tabs_setting_timeseries);
    m_tabs_setting_timeseries.AddToElementsArray(TAB_TAB_SETTING_TIMESERIES_SWING, m_label_swing_strength);
    m_label_swing_strength.XSize(60);
    m_label_swing_strength.YSize(M_CONTROL_HEIGHT);
    if(!m_label_swing_strength.CreateTextLabel("Strength", x, y)) return false;
    CWndContainer::AddToElementsArray(WindowIdx(m_window_setting_timeseries), m_label_swing_strength);

    m_edit_swing_strength.MainPointer(m_tabs_setting_timeseries);
    m_tabs_setting_timeseries.AddToElementsArray(TAB_TAB_SETTING_TIMESERIES_SWING, m_edit_swing_strength);
    m_edit_swing_strength.XSize(60);
    m_edit_swing_strength.YSize(M_CONTROL_HEIGHT);
    m_edit_swing_strength.SpinEditMode(true);
    m_edit_swing_strength.MinValue(1);
    m_edit_swing_strength.MaxValue(50);
    m_edit_swing_strength.StepValue(1);
    m_edit_swing_strength.SetDigits(0);
    m_edit_swing_strength.GetTextBoxPointer().XGap(1);
    if(!m_edit_swing_strength.CreateTextEdit("", x + 60, y)) return false;
    m_edit_swing_strength.SetValue((string)strength);   // CreateTextEdit()'s text param doesn't populate the box
    CWndContainer::AddToElementsArray(WindowIdx(m_window_setting_timeseries), m_edit_swing_strength);

    m_checkbox_swing_wick.MainPointer(m_tabs_setting_timeseries);
    m_tabs_setting_timeseries.AddToElementsArray(TAB_TAB_SETTING_TIMESERIES_SWING, m_checkbox_swing_wick);
    m_checkbox_swing_wick.XSize(80);
    m_checkbox_swing_wick.YSize(M_CONTROL_HEIGHT);
    if(!m_checkbox_swing_wick.CreateCheckBox("Use Wick", x + 60 + 60 + 15, y)) return false;
    CWndContainer::AddToElementsArray(WindowIdx(m_window_setting_timeseries), m_checkbox_swing_wick);
    m_checkbox_swing_wick.IconFilePressed(IMAGE_RESOURCE_BMP16_CHECKBOX_ON_G_PNG);   // match the _G_ OFF icon, same as the Trading tab's checkboxes
    m_checkbox_swing_wick.IsPressed(use_wick);
    return true;
 }
//+------------------------------------------------------------------+
//| Push N/PriceBasis into m_SwingSetting (source of truth for series |
//| created later) AND every CBarSwingControl already alive - each   |
//| setter clears + rescans its own Symbol+TF only on a real change.  |
//+------------------------------------------------------------------+
void CGUIPannel::ApplySwingParams(const int strength, const ENUM_SWING_PRICE_BASIS basis)
 {
   if(m_SwingSetting == NULL) return;
   bool changed = (m_SwingSetting.Strength() != strength || m_SwingSetting.PriceBasis() != basis);
   m_SwingSetting.Strength(strength);
   m_SwingSetting.PriceBasis(basis);
   if(!changed || m_BarTimeSeriesCollection == NULL) return;
   CArrayObj *list_bts = m_BarTimeSeriesCollection.GetList();
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
       if(ctrl == NULL) continue;
       ctrl.Strength(m_SwingSetting.Strength());
       ctrl.PriceBasis(m_SwingSetting.PriceBasis());
      }
    }
   m_SwingSetting.NotifyChanged();   // every series rescanned - bridge must be rebuilt from scratch
 }
//+------------------------------------------------------------------+
//| GUI -> params (spin-edit Enter/inc/dec or checkbox click)         |
//+------------------------------------------------------------------+
void CGUIPannel::OnChangeSwingParams(void)
 {
   int n = (int)StringToInteger(m_edit_swing_strength.GetValue());
   if(n < 1) { n = 1; m_edit_swing_strength.SetValue("1"); }
   ApplySwingParams(n, m_checkbox_swing_wick.IsPressed() ? SWING_PRICE_BASIS_WICK : SWING_PRICE_BASIS_BODY);
 }
#endif // __GUIPANNEL_SETTINGWINDOWS_TS_SWING_MQH__
