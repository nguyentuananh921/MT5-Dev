//+------------------------------------------------------------------+
//|                                             TestFrameTooltip.mq5 |
//| Frames holding SL/Trailing controls, attached and free tooltips  |
//+------------------------------------------------------------------+
#property version "1.00"

#include <Vendors\Anhnt\Library\4. Combination Lib V2\Entities\Controls\Window.mqh>
#include <Vendors\Anhnt\Library\4. Combination Lib V2\Entities\Controls\Frame.mqh>
#include <Vendors\Anhnt\Library\4. Combination Lib V2\Entities\Controls\Tooltip.mqh>
#include <Vendors\Anhnt\Library\4. Combination Lib V2\Entities\Controls\ComboBox.mqh>
#include <Vendors\Anhnt\Library\4. Combination Lib V2\Entities\Controls\TextEdit.mqh>
#include <Vendors\Anhnt\Library\4. Combination Lib V2\Entities\Controls\CheckBox.mqh>

CWindow   m_window_main;
CFrame    m_frame_sl;
CComboBox m_combo_sl_mode;
CTextEdit m_edit_sl_multiplier;
CTooltip  m_tooltip_sl_multiplier;
CTextEdit m_edit_sl_min_distance;
CFrame    m_frame_trailing;
CTextEdit m_edit_trailing_offset;
CTextEdit m_edit_trailing_start;
CTooltip  m_tooltip_trailing_start;
CTextEdit m_edit_trailing_step;
CCheckBox m_check_lock_sl;
CTooltip  m_tooltip_bar;
CKeys     m_keys;

bool CreateSpinEdit(CFrame &frame,CTextEdit &edit,const string name,const string text,const int y,const double min_value,const double max_value,const double step,const int digits,const string value)
  {
   edit.SetText(text);
   edit.SpinEditMode(true);
   edit.MinValue(min_value);
   edit.MaxValue(max_value);
   edit.StepValue(step);
   edit.SetDigits(digits);
   frame.AddChild(&edit);
   if(!edit.CreateTextEdit(::ChartID(),0,name,10,y,260))
      return false;
   edit.SetValue(value);
   return true;
  }

bool CreateTooltip(CGElement &element,CTooltip &tooltip,const string name,const string header,const string line1,const string line2)
  {
   tooltip.HeaderText(header);
   tooltip.AddString(line1);
   tooltip.AddString(line2);
   element.AddChild(&tooltip);
   return tooltip.CreateTooltip(::ChartID(),0,name,220,60);
  }

int OnInit(void)
  {
   const long chart_id=::ChartID();
   m_window_main.IsMovable(true);
   m_window_main.ResizeMode(true);
   m_window_main.CloseButtonIsUsed(true);
   m_window_main.TooltipsButtonIsUsed(true);
   if(!m_window_main.CreateWindow(chart_id,0,"FRAME + TOOLTIP",60,40,300,330))
      return INIT_FAILED;
   m_window_main.GetTooltipButtonPointer().SetState(true);

   m_frame_sl.SetText("Stop Loss");
   m_frame_sl.AutoXResizeMode(true);
   m_frame_sl.AutoXResizeRightOffset(10);
   m_window_main.AddChild(&m_frame_sl);
   if(!m_frame_sl.CreateFrame(chart_id,0,"TestFrameSL",10,30,0,115))
      return INIT_FAILED;

   string modes[]={"Fixed","ATR","Indicator"};
   m_combo_sl_mode.ItemsTotal(ArraySize(modes));
   for(int i=0; i<ArraySize(modes); i++)
      m_combo_sl_mode.SetValue(i,modes[i]);
   m_combo_sl_mode.SetText("Mode:");
   m_frame_sl.AddChild(&m_combo_sl_mode);
   if(!m_combo_sl_mode.CreateComboBox(chart_id,0,"TestFrameSLMode",10,22,260))
      return INIT_FAILED;
   m_combo_sl_mode.SelectItem(0);
   if(!CreateSpinEdit(m_frame_sl,m_edit_sl_multiplier,"TestFrameSLMult","Multiplier:",52,0.1,10,0.1,1,"1.5"))
      return INIT_FAILED;
   if(!CreateTooltip(m_edit_sl_multiplier,m_tooltip_sl_multiplier,"TestTipSLMult","Multiplier","Fixed: SL = Spread x Multiplier","ATR: SL = ATR x Multiplier"))
      return INIT_FAILED;
   if(!CreateSpinEdit(m_frame_sl,m_edit_sl_min_distance,"TestFrameSLMin","Min distance (pt):",82,0,1000,1,0,"0"))
      return INIT_FAILED;

   m_frame_trailing.SetText("Trailing");
   m_frame_trailing.AutoXResizeMode(true);
   m_frame_trailing.AutoXResizeRightOffset(10);
   m_frame_trailing.AutoYResizeMode(true);
   m_frame_trailing.AutoYResizeBottomOffset(35);
   m_window_main.AddChild(&m_frame_trailing);
   if(!m_frame_trailing.CreateFrame(chart_id,0,"TestFrameTrailing",10,155))
      return INIT_FAILED;
   if(!CreateSpinEdit(m_frame_trailing,m_edit_trailing_offset,"TestFrameTrOffset","Offset (pt):",22,0,5000,10,0,"100"))
      return INIT_FAILED;
   if(!CreateSpinEdit(m_frame_trailing,m_edit_trailing_start,"TestFrameTrStart","Start (pt):",52,-5000,5000,10,0,"0"))
      return INIT_FAILED;
   if(!CreateTooltip(m_edit_trailing_start,m_tooltip_trailing_start,"TestTipTrStart","Start","Profit in points before","the stop starts to move"))
      return INIT_FAILED;
   if(!CreateSpinEdit(m_frame_trailing,m_edit_trailing_step,"TestFrameTrStep","Step (pt):",82,1,1000,1,0,"10"))
      return INIT_FAILED;

   m_check_lock_sl.SetText("Lock Stop Loss frame");
   m_window_main.AddChild(&m_check_lock_sl);
   if(!m_check_lock_sl.Create(chart_id,0,"TestFrameLockSL",10,330-28,200,20))
      return INIT_FAILED;

   if(!m_tooltip_bar.CreateTooltip(chart_id,0,"TestTipBar",170,45))
      return INIT_FAILED;

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
   m_tooltip_bar.OnTimerEvent();
  }

void ShowBarTooltip(const int x,const int y)
  {
   int      subwin=0;
   datetime time=0;
   double   price=0;
   if(!m_keys.KeyShiftState() || m_window_main.MouseFocus() || !::ChartXYToTimePrice(0,x,y,subwin,time,price))
     {
      m_tooltip_bar.FadeOutTooltip();
      return;
     }
   int shift=::iBarShift(::Symbol(),::Period(),time);
   m_tooltip_bar.ClearStrings();
   m_tooltip_bar.HeaderText(::TimeToString(::iTime(::Symbol(),::Period(),shift)));
   m_tooltip_bar.AddString("Close: "+::DoubleToString(::iClose(::Symbol(),::Period(),shift),::Digits()));
   m_tooltip_bar.Moving(x+15,y-50);
   m_tooltip_bar.ShowTooltip();
  }

void OnChartEvent(const int id,const long &lparam,const double &dparam,const string &sparam)
  {
   m_window_main.OnChartEvent(id,lparam,dparam,sparam);
   if(id==CHARTEVENT_MOUSE_MOVE)
      ShowBarTooltip((int)lparam,(int)dparam);
   if(id==CHARTEVENT_CUSTOM+ON_CLICK_CHECKBOX && lparam==m_check_lock_sl.ObjectID())
     {
      m_frame_sl.IsLocked(dparam!=0);
      ::ChartRedraw();
     }
   if(id==CHARTEVENT_CUSTOM+ON_END_EDIT || id==CHARTEVENT_CUSTOM+ON_CLICK_COMBOBOX_ITEM)
      ::Print("MY DEBUG TestFrameTooltip::OnChartEvent: event=",id-CHARTEVENT_CUSTOM," id=",lparam," dparam=",dparam," sparam=",sparam);
  }
