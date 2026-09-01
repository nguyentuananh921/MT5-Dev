//+------------------------------------------------------------------+
//|                                GUIPannel_StopLostSettingWindow.mqh |
//| SL Setting popup window (Anhnt, 2026-09-01) - opened by clicking  |
//| the gear icon in m_table_pre_Trade_serversideInfo's SL column,    |
//| scoped to that row's own Symbol. A Symbol-scoped policy - not a   |
//| one-shot "distance for this new order" value - reused both when   |
//| sending a new order AND when Applying/correcting SL on an         |
//| already-open Position (even one opened outside the EA, e.g.       |
//| Mobile App with no SL). Event dispatch for this window's controls |
//| stays centralized in CGUIPannel::OnEvent() (GUIPannel_Lifecycle.  |
//| mqh), same convention as every other Window/Table in this class.  |
//+------------------------------------------------------------------+
#ifndef CGUIPANNEL_STOPLOSTSETTINGWINDOW_MQH
#define CGUIPANNEL_STOPLOSTSETTINGWINDOW_MQH
#include "GUIPannel.mqh"
//+------------------------------------------------------------------+
//| SL Setting popup window shell - CreateButtonsGroup_SLMode() below |
//| adds the Fixed/ATR toggle, and the 3 edit fields + Save button    |
//| are created directly against this window too.                     |
//+------------------------------------------------------------------+
bool CGUIPannel::CreateWindowStopLostSetting(const string caption_text)
 {
   CWndContainer::AddWindow(m_window_StopLost_Setting);
   m_window_StopLost_Setting.XSize(M_WINDOW_STOPLOST_SETTING_WIDTH);
   m_window_StopLost_Setting.YSize(150);
   m_window_StopLost_Setting.FontSize(M_WINDOW_STOPLOST_SETTING_HEIGHT);
   m_window_StopLost_Setting.IsMovable(true);
   m_window_StopLost_Setting.CloseButtonIsUsed(true);
   m_window_StopLost_Setting.WindowType(W_DIALOG);
   bool win_ok = m_window_StopLost_Setting.CreateWindow(m_chart_id, m_subwin, caption_text, M_WINDOW_STOPLOST_SETTING_XGAP, M_WINDOW_STOPLOST_SETTING_YGAP);
   CMessage::ToFile(g_ea_folder, "CGUIPannel", "CreateWindowStopLostSetting",
       "window CreateWindow=" + (string)win_ok + " id=" + (string)m_window_StopLost_Setting.Id() +
       " x=" + (string)m_window_StopLost_Setting.X() + " y=" + (string)m_window_StopLost_Setting.Y() +
       " xsize=" + (string)m_window_StopLost_Setting.XSize() + " ysize=" + (string)m_window_StopLost_Setting.YSize());
   if(!win_ok) return false;
   m_window_StopLost_Setting.IconFile(IMAGE_RESOURCE_BMP16_STOPLOSTRED_PNG);
   bool grp_ok = CreateButtonsGroup_SLMode(10, 35);
   CMessage::ToFile(g_ea_folder, "CGUIPannel", "CreateWindowStopLostSetting",
       "m_buttonsGroup_SLMode CreateButtonsGroup=" + (string)grp_ok + " id=" + (string)m_buttonsGroup_SLMode.Id() +
       " x=" + (string)m_buttonsGroup_SLMode.X() + " y=" + (string)m_buttonsGroup_SLMode.Y() +
       " buttons_total=" + (string)m_buttonsGroup_SLMode.ButtonsTotal());
   if(!grp_ok) return false;
  //--- Fixed mode field
   m_edit_StopLost_DistancePoints.MainPointer(m_window_StopLost_Setting);
   m_edit_StopLost_DistancePoints.XSize(80);
   m_edit_StopLost_DistancePoints.GetTextBoxPointer().XGap(1);
   bool dist_ok = m_edit_StopLost_DistancePoints.CreateTextEdit("100", 10, 65);
   CMessage::ToFile(g_ea_folder, "CGUIPannel", "CreateWindowStopLostSetting",
       "m_edit_StopLost_DistancePoints CreateTextEdit=" + (string)dist_ok + " id=" + (string)m_edit_StopLost_DistancePoints.Id() +
       " x=" + (string)m_edit_StopLost_DistancePoints.X() + " y=" + (string)m_edit_StopLost_DistancePoints.Y() +
       " visible=" + (string)m_edit_StopLost_DistancePoints.IsVisible());
   if(!dist_ok) return false;
   CWndContainer::AddToElementsArray(WindowIdx(m_window_StopLost_Setting), m_edit_StopLost_DistancePoints);
  //--- ATR mode fields
   m_edit_StopLost_ATRPeriod.MainPointer(m_window_StopLost_Setting);
   m_edit_StopLost_ATRPeriod.XSize(50);
   m_edit_StopLost_ATRPeriod.GetTextBoxPointer().XGap(1);
   bool period_ok = m_edit_StopLost_ATRPeriod.CreateTextEdit("14", 10, 65);
   CMessage::ToFile(g_ea_folder, "CGUIPannel", "CreateWindowStopLostSetting",
       "m_edit_StopLost_ATRPeriod CreateTextEdit=" + (string)period_ok + " id=" + (string)m_edit_StopLost_ATRPeriod.Id());
   if(!period_ok) return false;
   CWndContainer::AddToElementsArray(WindowIdx(m_window_StopLost_Setting), m_edit_StopLost_ATRPeriod);
   m_edit_StopLost_ATRMultiplier.MainPointer(m_window_StopLost_Setting);
   m_edit_StopLost_ATRMultiplier.XSize(50);
   m_edit_StopLost_ATRMultiplier.GetTextBoxPointer().XGap(1);
   bool mult_ok = m_edit_StopLost_ATRMultiplier.CreateTextEdit("1.5", 70, 65);
   CMessage::ToFile(g_ea_folder, "CGUIPannel", "CreateWindowStopLostSetting",
       "m_edit_StopLost_ATRMultiplier CreateTextEdit=" + (string)mult_ok + " id=" + (string)m_edit_StopLost_ATRMultiplier.Id());
   if(!mult_ok) return false;
   CWndContainer::AddToElementsArray(WindowIdx(m_window_StopLost_Setting), m_edit_StopLost_ATRMultiplier);
   m_edit_StopLost_ATRPeriod.Hide();
   m_edit_StopLost_ATRMultiplier.Hide();
  //--- Save button - own dedicated button (Anhnt, 2026-09-01), can't share m_btn_save_indicator,
  //--- a single CButton can't belong to 2 different windows/purposes at once.
   m_btn_save_StopLost_Setting.MainPointer(m_window_StopLost_Setting);
   m_btn_save_StopLost_Setting.XSize(80);
   m_btn_save_StopLost_Setting.IconFile(IMAGE_RESOURCE_BMP16_SAVE_PNG);
   bool save_ok = m_btn_save_StopLost_Setting.CreateButton("Save", 10, 100);
   CMessage::ToFile(g_ea_folder, "CGUIPannel", "CreateWindowStopLostSetting",
       "m_btn_save_StopLost_Setting CreateButton=" + (string)save_ok + " id=" + (string)m_btn_save_StopLost_Setting.Id());
   if(!save_ok) return false;
   CWndContainer::AddToElementsArray(WindowIdx(m_window_StopLost_Setting), m_btn_save_StopLost_Setting);
   m_window_StopLost_Setting.Hide();
   return true;
 }
//+------------------------------------------------------------------+
//| SL Setting - Fixed/Indicator mode toggle (Anhnt, 2026-09-01). A   |
//| Symbol-scoped policy reused for both new orders and Applying SL   |
//| to already-open Positions. Attaches to m_window_StopLost_Setting. |
//+------------------------------------------------------------------+
bool CGUIPannel::CreateButtonsGroup_SLMode(const int x, const int y)
 {
   m_buttonsGroup_SLMode.MainPointer(m_window_StopLost_Setting);
   m_buttonsGroup_SLMode.RadioButtonsMode(true);
  //--- x_gap is an ABSOLUTE per-button offset, NOT auto-accumulated (ButtonsGroup.mqh
  //--- CreateButtons(): x=m_buttons[i].XGap()) - passing (0,0) for every button stacks them
  //--- all on top of each other (confirmed bug, Anhnt 2026-09-01: "ATR" was drawn over
  //--- "Fixed", hiding it entirely). Must manually accumulate each button's own width.
   m_buttonsGroup_SLMode.AddButton(0, 0, "Fixed", 50);
   m_buttonsGroup_SLMode.AddButton(50, 0, "Indicator", 70);
   if(!m_buttonsGroup_SLMode.CreateButtonsGroup(x, y)) return false;
   CWndContainer::AddToElementsArray(WindowIdx(m_window_StopLost_Setting), m_buttonsGroup_SLMode);
   return true;
 }
//+------------------------------------------------------------------+
//| Show/Hide m_window_StopLost_Setting, scoped to one row's Symbol  |
//| (Anhnt, 2026-09-01) - populates every field from the per-Symbol   |
//| cache (or Fixed-mode defaults if this Symbol has no entry yet).   |
//+------------------------------------------------------------------+
void CGUIPannel::ShowWindowStopLostSetting(const string symbol)
 {
   m_string_StopLost_setting_current_symbol = symbol;
   int idx = GetStopLostCacheIndex(symbol, false);
   ENUM_SL_MODE mode = (idx >= 0) ? m_enum_StopLost_cache_mode[idx] : SL_MODE_FIXED;
   int distance_pts  = (idx >= 0) ? m_int_StopLost_cache_distance_pts[idx]    : 100;
   int atr_period     = (idx >= 0) ? m_int_StopLost_cache_atr_period[idx]     : 14;
   double atr_mult     = (idx >= 0) ? m_double_StopLost_cache_atr_multiplier[idx] : 1.5;
   m_buttonsGroup_SLMode.SelectButton((uint)mode);
   m_edit_StopLost_DistancePoints.SetValue((string)distance_pts);
   m_edit_StopLost_ATRPeriod.SetValue((string)atr_period);
   m_edit_StopLost_ATRMultiplier.SetValue((string)atr_mult);
   if(mode == SL_MODE_FIXED)
    {
     m_edit_StopLost_DistancePoints.Show();
     m_edit_StopLost_ATRPeriod.Hide();
     m_edit_StopLost_ATRMultiplier.Hide();
    }
   else
    {
     m_edit_StopLost_DistancePoints.Hide();
     m_edit_StopLost_ATRPeriod.Show();
     m_edit_StopLost_ATRMultiplier.Show();
    }
   CMessage::ToFile(g_ea_folder, "CGUIPannel", "ShowWindowStopLostSetting",
       "BEFORE OpenWindow: symbol=" + symbol + " mode=" + (string)mode +
       " win_visible=" + (string)m_window_StopLost_Setting.IsVisible() +
       " grp_visible=" + (string)m_buttonsGroup_SLMode.IsVisible() +
       " grp_btn0_visible=" + (string)m_buttonsGroup_SLMode.GetButtonPointer(0).IsVisible() +
       " grp_btn1_visible=" + (string)m_buttonsGroup_SLMode.GetButtonPointer(1).IsVisible() +
       " dist_visible=" + (string)m_edit_StopLost_DistancePoints.IsVisible() +
       " save_visible=" + (string)m_btn_save_StopLost_Setting.IsVisible());
   m_window_StopLost_Setting.OpenWindow();
  //--- Force a repaint (Anhnt, 2026-09-01) - the Show()/Hide() toggling just above (and inside
  //--- CreateWindowStopLostSetting()'s own initial Hide() calls, much earlier at OnInit) sets
  //--- the right flags, but nothing actually blits it to screen without an explicit redraw -
  //--- confirmed: m_buttonsGroup_SLMode invisible + the WRONG field showing (stale paint from
  //--- creation time) until this fires.
   ::ChartRedraw();
   CMessage::ToFile(g_ea_folder, "CGUIPannel", "ShowWindowStopLostSetting",
       "AFTER OpenWindow+Redraw: win_visible=" + (string)m_window_StopLost_Setting.IsVisible() +
       " win_x=" + (string)m_window_StopLost_Setting.X() + " win_y=" + (string)m_window_StopLost_Setting.Y() +
       " grp_visible=" + (string)m_buttonsGroup_SLMode.IsVisible() +
       " grp_x=" + (string)m_buttonsGroup_SLMode.X() + " grp_y=" + (string)m_buttonsGroup_SLMode.Y() +
       " grp_btn0_visible=" + (string)m_buttonsGroup_SLMode.GetButtonPointer(0).IsVisible() +
       " grp_btn0_x=" + (string)m_buttonsGroup_SLMode.GetButtonPointer(0).X() +
       " grp_btn0_y=" + (string)m_buttonsGroup_SLMode.GetButtonPointer(0).Y() +
       " grp_btn1_visible=" + (string)m_buttonsGroup_SLMode.GetButtonPointer(1).IsVisible() +
       " dist_visible=" + (string)m_edit_StopLost_DistancePoints.IsVisible() +
       " dist_x=" + (string)m_edit_StopLost_DistancePoints.X() +
       " dist_y=" + (string)m_edit_StopLost_DistancePoints.Y() +
       " save_visible=" + (string)m_btn_save_StopLost_Setting.IsVisible() +
       " save_x=" + (string)m_btn_save_StopLost_Setting.X() +
       " save_y=" + (string)m_btn_save_StopLost_Setting.Y());
 }
void CGUIPannel::HideWindowStopLostSetting(void)
 {
   m_window_StopLost_Setting.Hide();
   m_active_window_index = WindowIdx(m_window_main);
 }
//+------------------------------------------------------------------+
//| Per-Symbol SL Setting cache lookup (Anhnt, 2026-09-01) - shared   |
//| by ShowWindowStopLostSetting/the Save handler/FormatStopLostCache |
//| Value below, same parallel-array convention as the serverside     |
//| info cache in GUIPannel_MainWindows_TabPositions.mqh.             |
//+------------------------------------------------------------------+
int CGUIPannel::GetStopLostCacheIndex(const string symbol, const bool create_if_missing)
 {
   int total = ::ArraySize(m_string_StopLost_cache_symbol);
   for(int i = 0; i < total; i++)
      if(m_string_StopLost_cache_symbol[i] == symbol) return i;
   if(!create_if_missing) return -1;
   ::ArrayResize(m_string_StopLost_cache_symbol,          total + 1);
   ::ArrayResize(m_enum_StopLost_cache_mode,              total + 1);
   ::ArrayResize(m_int_StopLost_cache_distance_pts,       total + 1);
   ::ArrayResize(m_int_StopLost_cache_atr_period,         total + 1);
   ::ArrayResize(m_double_StopLost_cache_atr_multiplier,  total + 1);
   m_string_StopLost_cache_symbol[total]         = symbol;
   m_enum_StopLost_cache_mode[total]             = SL_MODE_FIXED;
   m_int_StopLost_cache_distance_pts[total]      = 100;
   m_int_StopLost_cache_atr_period[total]        = 14;
   m_double_StopLost_cache_atr_multiplier[total] = 1.5;
   return total;
 }
//+------------------------------------------------------------------+
//| "SL Value" column display text (Anhnt, 2026-09-01)               |
//+------------------------------------------------------------------+
string CGUIPannel::FormatStopLostCacheValue(const string symbol)
 {
   int idx = GetStopLostCacheIndex(symbol, false);
   if(idx < 0) return "-";
   if(m_enum_StopLost_cache_mode[idx] == SL_MODE_FIXED)
      return (string)m_int_StopLost_cache_distance_pts[idx] + " pts";
   return "ATR(" + (string)m_int_StopLost_cache_atr_period[idx] + ")x" +
          ::DoubleToString(m_double_StopLost_cache_atr_multiplier[idx], 2);
 }
#endif // CGUIPANNEL_STOPLOSTSETTINGWINDOW_MQH
