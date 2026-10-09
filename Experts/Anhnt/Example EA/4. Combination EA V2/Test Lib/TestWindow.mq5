//+------------------------------------------------------------------+
//|                                                   TestWindow.mq5 |
//| Main window, modal dialog (locks main), Shift+move popup         |
//+------------------------------------------------------------------+
#property version "1.00"

#include <Vendors\Anhnt\Library\4. Combination Lib V2\Entities\Controls\Window.mqh>
#include <Vendors\Anhnt\Library\4. Combination Lib V2\Entities\Controls\CheckBox.mqh>
#include <Vendors\Anhnt\Library\4. Combination Lib V2\Services\Keys.mqh>

CWindow   m_window_main;
CButton   m_btn_open_dialog;
CCheckBox m_check_markers;
CWindow   m_window_dialog;
CLabel    m_dialog_label;
CWindow   m_window_popup;
CLabel    m_popup_label;
CKeys     m_keys;

int OnInit(void)
  {
   const long chart_id=::ChartID();
   m_window_main.IsMovable(true);
   m_window_main.ResizeMode(true);
   m_window_main.CloseButtonIsUsed(true);
   m_window_main.CollapseButtonIsUsed(true);
   m_window_main.FullscreenButtonIsUsed(true);
   m_window_main.TooltipsButtonIsUsed(true);
   if(!m_window_main.CreateWindow(chart_id,0,"EXPERT PANEL V2",60,40,300,180))
      return INIT_FAILED;
   m_window_main.AddChild(&m_btn_open_dialog);
   m_window_main.AddChild(&m_check_markers);
   m_btn_open_dialog.SetText("Open dialog");
   m_check_markers.SetText("Show markers");
   if(!m_btn_open_dialog.Create(chart_id,0,"TestOpenDialog",10,35,120,20))
      return INIT_FAILED;
   if(!m_check_markers.Create(chart_id,0,"TestCheckMarkers",10,65,150,20))
      return INIT_FAILED;

   m_window_dialog.IsMovable(true);
   m_window_dialog.ResizeMode(true);
   m_window_dialog.CloseButtonIsUsed(true);
   m_window_dialog.WindowType(W_DIALOG);
   if(!m_window_dialog.CreateWindow(chart_id,0,"Setting",400,80,250,120))
      return INIT_FAILED;
   m_window_dialog.AddChild(&m_dialog_label);
   m_dialog_label.SetText("Dialog content");
   if(!m_dialog_label.Create(chart_id,0,"TestDialogLabel",10,35,200,20))
      return INIT_FAILED;
   m_window_dialog.Hide();

   m_window_popup.WindowType(W_POPUP);
   if(!m_window_popup.CreateWindow(chart_id,0,"Signals at Bar",0,0,200,80))
      return INIT_FAILED;
   m_window_popup.AddChild(&m_popup_label);
   m_popup_label.SetText("Hold Shift + move over chart");
   if(!m_popup_label.Create(chart_id,0,"TestPopupLabel",10,35,180,20))
      return INIT_FAILED;
   m_window_popup.Hide();
   ::ChartRedraw(chart_id);
   return INIT_SUCCEEDED;
  }

void OnDeinit(const int reason)
  {
  }

void OnTick(void)
  {
  }

void OnChartEvent(const int id,const long &lparam,const double &dparam,const string &sparam)
  {
   m_window_main.OnChartEvent(id,lparam,dparam,sparam);
   m_window_dialog.OnChartEvent(id,lparam,dparam,sparam);
   m_window_popup.OnChartEvent(id,lparam,dparam,sparam);

   if(id==CHARTEVENT_MOUSE_MOVE && m_keys.KeyShiftState() && !m_window_popup.IsVisible() &&
      !m_window_main.MouseFocus() && !m_window_dialog.MouseFocus())
     {
      m_window_popup.Move((int)lparam-10,(int)dparam-10);
      m_window_popup.OpenWindow();
     }
   if(id==CHARTEVENT_CUSTOM+ON_CLICK_BUTTON && lparam==m_btn_open_dialog.ObjectID())
      m_window_dialog.OpenWindow();
   if(id==CHARTEVENT_CUSTOM+ON_OPEN_DIALOG_BOX && (int)dparam==W_DIALOG)
      m_window_main.IsLocked(true);
   if(id==CHARTEVENT_CUSTOM+ON_CLOSE_DIALOG_BOX && (int)dparam==W_DIALOG)
      m_window_main.IsLocked(false);
   if(id==CHARTEVENT_CUSTOM+ON_OPEN_DIALOG_BOX || id==CHARTEVENT_CUSTOM+ON_CLOSE_DIALOG_BOX)
      ::ChartRedraw();
   if(id>CHARTEVENT_CUSTOM && id!=CHARTEVENT_CUSTOM+ON_SCROLL_CHANGE)
      ::Print("MY DEBUG TestWindow::OnChartEvent: event=",id-CHARTEVENT_CUSTOM," id=",lparam," dparam=",dparam," sparam=",sparam);
  }
