//+------------------------------------------------------------------+
//|                                                 TestTextEdit.mq5 |
//| Text and spin edits, blinking cursor and fast spin via OnTimer   |
//+------------------------------------------------------------------+
#property version "1.00"

#include <Vendors\Anhnt\Library\4. Combination Lib V2\Entities\Controls\Window.mqh>
#include <Vendors\Anhnt\Library\4. Combination Lib V2\Entities\Controls\TextEdit.mqh>

CWindow   m_window_main;
CTextEdit m_edit_comment;
CTextEdit m_edit_swing_strength;
CTextEdit m_edit_atr_multiplier;
CTextEdit m_edit_trailing_start;
CTextBox  m_box_read_only;

int OnInit(void)
  {
   const long chart_id=::ChartID();
   m_window_main.IsMovable(true);
   m_window_main.CloseButtonIsUsed(true);
   if(!m_window_main.CreateWindow(chart_id,0,"TEXT EDIT",60,40,300,200))
      return INIT_FAILED;

   m_edit_comment.SetText("Comment:");
   m_edit_comment.GetTextBoxPointer().DefaultText("type here...");
   m_edit_comment.GetTextBoxPointer().AutoSelectionMode(true);
   m_window_main.AddChild(&m_edit_comment);
   if(!m_edit_comment.CreateTextEdit(chart_id,0,"TestEditComment",10,30,280,20,150))
      return INIT_FAILED;

   m_edit_swing_strength.SetText("Swing strength (N):");
   m_edit_swing_strength.SpinEditMode(true);
   m_edit_swing_strength.MinValue(1);
   m_edit_swing_strength.MaxValue(50);
   m_edit_swing_strength.StepValue(1);
   m_window_main.AddChild(&m_edit_swing_strength);
   if(!m_edit_swing_strength.CreateTextEdit(chart_id,0,"TestEditSwing",10,60,280))
      return INIT_FAILED;
   m_edit_swing_strength.SetValue("5");

   m_edit_atr_multiplier.SetText("ATR multiplier:");
   m_edit_atr_multiplier.SpinEditMode(true);
   m_edit_atr_multiplier.MinValue(0.1);
   m_edit_atr_multiplier.MaxValue(10);
   m_edit_atr_multiplier.StepValue(0.1);
   m_edit_atr_multiplier.SetDigits(1);
   m_window_main.AddChild(&m_edit_atr_multiplier);
   if(!m_edit_atr_multiplier.CreateTextEdit(chart_id,0,"TestEditATR",10,90,280))
      return INIT_FAILED;
   m_edit_atr_multiplier.SetValue("1.5");

   m_edit_trailing_start.SetText("Trailing start");
   m_edit_trailing_start.CheckBoxMode(true);
   m_edit_trailing_start.SpinEditMode(true);
   m_edit_trailing_start.MinValue(-500);
   m_edit_trailing_start.MaxValue(500);
   m_edit_trailing_start.StepValue(10);
   m_window_main.AddChild(&m_edit_trailing_start);
   if(!m_edit_trailing_start.CreateTextEdit(chart_id,0,"TestEditTrailing",10,120,280))
      return INIT_FAILED;
   m_edit_trailing_start.SetValue("0");

   m_box_read_only.ReadOnlyMode(true);
   m_window_main.AddChild(&m_box_read_only);
   if(!m_box_read_only.CreateTextBox(chart_id,0,"TestBoxReadOnly",10,155,280))
      return INIT_FAILED;
   m_box_read_only.SetValue("Read only: "+::Symbol()+" "+::EnumToString((ENUM_TIMEFRAMES)::Period()));

   ::EventSetMillisecondTimer(TIMER_STEP_MSC);
   ::ChartRedraw(chart_id);
   return INIT_SUCCEEDED;
  }

void OnDeinit(const int reason)
  {
   ::EventKillTimer();
  }

void OnTick(void)
  {
  }

void OnTimer(void)
  {
   m_window_main.OnTimerEvent();
  }

void OnChartEvent(const int id,const long &lparam,const double &dparam,const string &sparam)
  {
   m_window_main.OnChartEvent(id,lparam,dparam,sparam);
   if(id==CHARTEVENT_CUSTOM+ON_END_EDIT || id==CHARTEVENT_CUSTOM+ON_CLICK_INC ||
      id==CHARTEVENT_CUSTOM+ON_CLICK_DEC || id==CHARTEVENT_CUSTOM+ON_CLICK_CHECKBOX)
      ::Print("MY DEBUG TestTextEdit::OnChartEvent: event=",id-CHARTEVENT_CUSTOM," id=",lparam," dparam=",dparam," sparam=",sparam,
              " (comment id=",m_edit_comment.ObjectID()," swing id=",m_edit_swing_strength.ObjectID(),
              " atr id=",m_edit_atr_multiplier.ObjectID()," trailing id=",m_edit_trailing_start.ObjectID(),")");
  }
