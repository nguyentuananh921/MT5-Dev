//+------------------------------------------------------------------+
//|                                                     TextEdit.mqh |
//|                        Copyright 2015, MetaQuotes Software Corp. |
//|Library base on Link https://www.mql5.com/en/code/19703           |
//+------------------------------------------------------------------+
#property strict

#ifndef CTEXTEDIT_MQH
#define CTEXTEDIT_MQH
 #include "Button.mqh"
 #include "TextBox.mqh"
#ifndef CTEXTEDIT_MQH_DECLARATION
#define CTEXTEDIT_MQH_DECLARATION
//+------------------------------------------------------------------+
//| Label + text box, optional spin buttons for numbers              |
//+------------------------------------------------------------------+
class CTextEdit : public CButton
 {
  private:
    CTextBox          m_edit;
    CButton           m_button_inc;
    CButton           m_button_dec;
    bool              m_checkbox_mode;
    bool              m_spin_edit_mode;
    string            m_edit_value;
    double            m_min_value;
    double            m_max_value;
    double            m_step_value;
    int               m_timer_counter;

    bool              CreateSpinButton(CButton &button_obj,const int index,const int x,const int y,const int h);
    string            AdjustmentValue(const double value);
    void              Increment(const int direction);
  protected:
    virtual void      InitColors(void);
    virtual void      OnRelease(const int x,const int y);
  public:
    bool              CreateTextEdit(const long chart_id,const int subwin,const string name,const int x,const int y,const int w,
                                     const int h=20,const int edit_x_size=80);
    CTextBox         *GetTextBoxPointer(void)                  { return(::GetPointer(m_edit));       }
    CButton          *GetIncButtonPointer(void)                { return(::GetPointer(m_button_inc)); }
    CButton          *GetDecButtonPointer(void)                { return(::GetPointer(m_button_dec)); }
    void              CheckBoxMode(const bool state)           { m_checkbox_mode=state;              }
    bool              SpinEditMode(void)                 const { return(m_spin_edit_mode);           }
    void              SpinEditMode(const bool state)           { m_spin_edit_mode=state;             }
    double            MinValue(void)                     const { return(m_min_value);                }
    void              MinValue(const double value)             { m_min_value=value;                  }
    double            MaxValue(void)                     const { return(m_max_value);                }
    void              MaxValue(const double value)             { m_max_value=value;                  }
    double            StepValue(void)                    const { return(m_step_value);               }
    void              StepValue(const double value)            { m_step_value=(value<=0)? 1 : value; }
    string            GetValue(void)                     const { return(m_edit.GetValue());          }
    void              SetValue(const string value);
    virtual void      OnChartEvent(const int id,const long &lparam,const double &dparam,const string &sparam);
    virtual void      OnTimerEvent(void);
                     CTextEdit(void);
                    ~CTextEdit(void) {}
 };
#endif // CTEXTEDIT_MQH_DECLARATION
#ifndef CTEXTEDIT_MQH_IMPLEMENTATION
#define CTEXTEDIT_MQH_IMPLEMENTATION
//+------------------------------------------------------------------+
//| Kazharski defaults (min -DBL_MAX: Kazharski's DBL_MIN is > 0)    |
//+------------------------------------------------------------------+
CTextEdit::CTextEdit(void) : m_checkbox_mode(false),
                             m_spin_edit_mode(false),
                             m_edit_value(""),
                             m_min_value(-DBL_MAX),
                             m_max_value(DBL_MAX),
                             m_step_value(1),
                             m_timer_counter(SPIN_DELAY_MSC)
 {
  this.m_digits=0;
  this.LabelXGap(0);
 }
//+------------------------------------------------------------------+
//| Kazharski text edit label: hover C'0,120,215', locked silver     |
//+------------------------------------------------------------------+
void CTextEdit::InitColors(void)
 {
  this.m_color_background.InitColors(clrNONE,clrNONE,clrNONE,clrNONE);
  this.m_color_foreground.InitColors(clrBlack,C'0,120,215',clrBlack,clrSilver);
  this.m_color_border.InitColors(clrNONE,clrNONE,clrNONE,clrNONE);
  this.m_color_background_act.InitColors(clrNONE,clrNONE,clrNONE,clrNONE);
  this.m_color_foreground_act.InitColors(clrBlack,C'0,120,215',clrBlack,clrSilver);
  this.m_color_border_act.InitColors(clrNONE,clrNONE,clrNONE,clrNONE);
 }
//+------------------------------------------------------------------+
//| Label canvas, text box on the right, spin buttons after it       |
//+------------------------------------------------------------------+
bool CTextEdit::CreateTextEdit(const long chart_id,const int subwin,const string name,const int x,const int y,const int w,
                               const int h=20,const int edit_x_size=80)
 {
  if(this.m_checkbox_mode)
    {
     this.IconFile(IMAGE_RESOURCE_BMP16_CHECKBOX_OFF_G_PNG);
     this.IconFileLocked(IMAGE_RESOURCE_BMP16_CHECKBOX_OFF_LOCKED_BMP);
     this.IconFilePressed(IMAGE_RESOURCE_BMP16_CHECKBOX_ON_G_PNG);
     this.IconFilePressedLocked(IMAGE_RESOURCE_BMP16_CHECKBOX_ON_LOCKED_BMP);
    }
  if(!this.Create(chart_id,subwin,name,x,y,w,h))
     return(false);
  int edit_x=w-edit_x_size;
  int box_x_size=(this.m_spin_edit_mode ? edit_x_size-15 : edit_x_size);
  this.AddChild(::GetPointer(this.m_edit));
  if(!this.m_edit.CreateTextBox(chart_id,subwin,this.Name()+"_edit",edit_x,0,box_x_size,h))
     return(false);
  if(!this.m_spin_edit_mode)
     return(true);
  int half=h/2;
  if(!this.CreateSpinButton(this.m_button_inc,0,w-15,0,half))
     return(false);
  if(!this.CreateSpinButton(this.m_button_dec,1,w-15,half,h-half))
     return(false);
  return(true);
 }
//+------------------------------------------------------------------+
//| Kazharski spin colors: text box back, hover C'225,225,225'       |
//+------------------------------------------------------------------+
bool CTextEdit::CreateSpinButton(CButton &button_obj,const int index,const int x,const int y,const int h)
 {
  uint file=(index==0 ? IMAGE_RESOURCE_BMP16_SPIN_INC_BMP : IMAGE_RESOURCE_BMP16_SPIN_DEC_BMP);
  this.AddChild(::GetPointer(button_obj));
  button_obj.IconFile(file);
  button_obj.IconFileLocked(file);
  button_obj.IconFilePressed(file);
  button_obj.IconFilePressedLocked(file);
  button_obj.IconXGap(5);
  if(!button_obj.Create(this.m_chart_id,this.m_subwindow,this.Name()+(index==0 ? "_spin_inc" : "_spin_dec"),x,y,15,h))
     return(false);
  button_obj.GetBackColorControl().InitColors(clrWhite,C'225,225,225',clrLightGray,clrLightGray);
  button_obj.GetBorderColorControl().InitColors(clrWhite,C'225,225,225',clrLightGray,clrLightGray);
  button_obj.ColorChange(COLOR_STATE_DEFAULT);
  button_obj.Draw(false);
  return(true);
 }
//+------------------------------------------------------------------+
//| Rounded to the step, clamped, formatted with m_digits            |
//+------------------------------------------------------------------+
string CTextEdit::AdjustmentValue(const double value)
 {
  double corrected_value=::MathRound(value/this.m_step_value)*this.m_step_value;
  if(corrected_value<this.m_min_value)
     corrected_value=this.m_min_value;
  if(corrected_value>this.m_max_value)
     corrected_value=this.m_max_value;
  this.m_edit_value=::DoubleToString(corrected_value,this.m_digits);
  return(this.m_edit_value);
 }
//+------------------------------------------------------------------+
//| Spin mode adjusts the value                                      |
//+------------------------------------------------------------------+
void CTextEdit::SetValue(const string value)
 {
  this.m_edit.SetValue(this.m_spin_edit_mode ? this.AdjustmentValue(::StringToDouble(value)) : value);
 }
//+------------------------------------------------------------------+
//| One step up (+1) or down (-1), shouts ON_CLICK_INC/DEC           |
//+------------------------------------------------------------------+
void CTextEdit::Increment(const int direction)
 {
  this.SetValue(::DoubleToString(::StringToDouble(this.m_edit.GetValue())+direction*this.m_step_value,8));
  if(direction>0)
     this.SendEvent(ON_CLICK_INC,::StringToDouble(this.m_edit.GetValue()),this.m_edit.GetValue());
  else
     this.SendEvent(ON_CLICK_DEC,::StringToDouble(this.m_edit.GetValue()),this.m_edit.GetValue());
 }
//+------------------------------------------------------------------+
//| Click on the label flips the check in checkbox mode              |
//+------------------------------------------------------------------+
void CTextEdit::OnRelease(const int x,const int y)
 {
  CGElement::OnRelease(x,y);
  if(!this.m_checkbox_mode || !this.m_mouse_focus)
     return;
  this.SetState(!this.m_state);
  this.SendEvent(ON_CLICK_CHECKBOX,(this.m_state ? 1 : 0),this.m_text);
 }
//+------------------------------------------------------------------+
//| Box end edit re-shouted with this id, spin button clicks         |
//+------------------------------------------------------------------+
void CTextEdit::OnChartEvent(const int id,const long &lparam,const double &dparam,const string &sparam)
 {
  CGElement::OnChartEvent(id,lparam,dparam,sparam);
  if(id==CHARTEVENT_CUSTOM+ON_END_EDIT && lparam==this.m_edit.ObjectID())
    {
     this.SetValue(this.m_edit.GetValue());
     this.SendEvent(ON_END_EDIT,::StringToDouble(this.m_edit.GetValue()),this.m_edit.GetValue());
     return;
    }
  if(!this.m_spin_edit_mode || id!=CHARTEVENT_CUSTOM+ON_CLICK_BUTTON)
     return;
  if(lparam==this.m_button_inc.ObjectID())
     this.Increment(1);
  else if(lparam==this.m_button_dec.ObjectID())
     this.Increment(-1);
 }
//+------------------------------------------------------------------+
//| Kazharski FastSwitching: holding a spin button repeats the step  |
//| after SPIN_DELAY_MSC                                             |
//+------------------------------------------------------------------+
void CTextEdit::OnTimerEvent(void)
 {
  CGElement::OnTimerEvent();
  if(!this.m_spin_edit_mode || !this.IsVisible() || this.m_is_locked)
     return;
  bool on_inc=this.m_button_inc.MouseFocus();
  bool on_dec=this.m_button_dec.MouseFocus();
  if(!s_mouse.IsLeftBtn() || (!on_inc && !on_dec))
    {
     this.m_timer_counter=SPIN_DELAY_MSC;
     return;
    }
  this.m_timer_counter+=TIMER_STEP_MSC;
  if(this.m_timer_counter<0)
     return;
  this.Increment(on_inc ? 1 : -1);
 }
#endif // CTEXTEDIT_MQH_IMPLEMENTATION
#endif // CTEXTEDIT_MQH
