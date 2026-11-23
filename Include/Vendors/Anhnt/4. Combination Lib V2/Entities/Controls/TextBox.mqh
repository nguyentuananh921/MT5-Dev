//+------------------------------------------------------------------+
//|                                                      TextBox.mqh |
//|                        Copyright 2015, MetaQuotes Software Corp. |
//|Library base on Link https://www.mql5.com/en/code/19703           |
//+------------------------------------------------------------------+
#property strict

#ifndef CTEXTBOX_MQH
#define CTEXTBOX_MQH
 #include "..\GBases\GElement.mqh"
 #include "..\..\Services\Keys.mqh"
 #include "..\..\Services\TimeCounter.mqh"
#ifndef CTEXTBOX_MQH_DECLARATION
#define CTEXTBOX_MQH_DECLARATION
//+------------------------------------------------------------------+
//| Single-line text input field                                     |
//+------------------------------------------------------------------+
class CTextBox : public CGElement
 {
  private:
    CKeys             m_keys;
    CTimeCounter      m_counter;
    string            m_text;
    string            m_temp_input_string;
    string            m_default_text;
    color             m_default_text_color;
    color             m_selected_back_color;
    color             m_selected_text_color;
    int               m_selected_symbol_from;
    int               m_selected_symbol_to;
    int               m_text_x_offset;
    int               m_text_cursor_x_pos;
    int               m_shift_x;
    bool              m_read_only_mode;
    bool              m_auto_selection_mode;
    bool              m_text_edit_state;
    bool              m_cursor_state;
    bool              m_saved_keyboard_control;
    bool              m_saved_quick_navigation;

    int               TextWidth(const int symbols_total);
    int               CursorPosByX(const int x);
    void              CorrectingShift(void);
    bool              DeleteSelectedText(void);
    void              ResetSelectedText(void)                  { m_selected_symbol_from=m_selected_symbol_to=WRONG_VALUE; }
    void              MoveTextCursorByWord(const bool to_right);
    bool              OnPressedKey(const long key_code);
  protected:
    virtual void      InitColors(void);
    virtual void      DrawContent(void);
    virtual void      OnPress(const int x,const int y);
  public:
    bool              CreateTextBox(const long chart_id,const int subwin,const string name,const int x,const int y,const int w,const int h=20);
    void              SetValue(const string value);
    string            GetValue(void)                     const { return(m_text);                }
    void              DefaultText(const string text)           { m_default_text=text;           }
    void              DefaultTextColor(const color clr)        { m_default_text_color=clr;      }
    void              SelectedBackColor(const color clr)       { m_selected_back_color=clr;     }
    void              SelectedTextColor(const color clr)       { m_selected_text_color=clr;     }
    void              TextXOffset(const int x_offset)          { m_text_x_offset=x_offset;      }
    bool              ReadOnlyMode(void)                 const { return(m_read_only_mode);      }
    void              ReadOnlyMode(const bool mode)            { m_read_only_mode=mode;         }
    void              AutoSelectionMode(const bool state)      { m_auto_selection_mode=state;   }
    bool              TextEditState(void)                const { return(m_text_edit_state);     }
    void              ActivateTextBox(const bool select_all=false);
    void              DeactivateTextBox(void);
    virtual void      Hide(void);
    virtual void      OnChartEvent(const int id,const long &lparam,const double &dparam,const string &sparam);
    virtual void      OnTimerEvent(void);
                     CTextBox(void);
                    ~CTextBox(void) {}
 };
#endif // CTEXTBOX_MQH_DECLARATION
#ifndef CTEXTBOX_MQH_IMPLEMENTATION
#define CTEXTBOX_MQH_IMPLEMENTATION
//+------------------------------------------------------------------+
//| Kazharski defaults                                               |
//+------------------------------------------------------------------+
CTextBox::CTextBox(void) : m_text(""),
                           m_temp_input_string(""),
                           m_default_text(""),
                           m_default_text_color(clrTomato),
                           m_selected_back_color(C'51,153,255'),
                           m_selected_text_color(clrWhite),
                           m_selected_symbol_from(WRONG_VALUE),
                           m_selected_symbol_to(WRONG_VALUE),
                           m_text_x_offset(5),
                           m_text_cursor_x_pos(0),
                           m_shift_x(0),
                           m_read_only_mode(false),
                           m_auto_selection_mode(false),
                           m_text_edit_state(false),
                           m_cursor_state(false),
                           m_saved_keyboard_control(true),
                           m_saved_quick_navigation(true)
 {
  this.m_counter.SetParameters(TIMER_STEP_MSC,200);
 }
//+------------------------------------------------------------------+
//| Kazharski CTextBox: white, border gray/black/CornflowerBlue      |
//+------------------------------------------------------------------+
void CTextBox::InitColors(void)
 {
  this.m_color_background.InitColors(clrWhite,clrWhite,clrWhite,clrWhiteSmoke);
  this.m_color_foreground.InitColors(clrBlack,clrBlack,clrBlack,clrSilver);
  this.m_color_border.InitColors(clrGray,clrBlack,clrCornflowerBlue,clrSilver);
  this.m_color_background_act.InitColors(clrWhite,clrWhite,clrWhite,clrWhiteSmoke);
  this.m_color_foreground_act.InitColors(clrBlack,clrBlack,clrBlack,clrSilver);
  this.m_color_border_act.InitColors(clrCornflowerBlue,clrCornflowerBlue,clrCornflowerBlue,clrSilver);
 }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CTextBox::CreateTextBox(const long chart_id,const int subwin,const string name,const int x,const int y,const int w,const int h=20)
 {
  return(this.Create(chart_id,subwin,name,x,y,w,h));
 }
//+------------------------------------------------------------------+
//| Replaces the text, cursor at the end only while editing          |
//+------------------------------------------------------------------+
void CTextBox::SetValue(const string value)
 {
  this.m_text=value;
  this.m_text_cursor_x_pos=(this.m_text_edit_state ? ::StringLen(value) : 0);
  this.ResetSelectedText();
  this.CorrectingShift();
  this.Draw(true);
 }
//+------------------------------------------------------------------+
//| Pixel width of the first symbols_total characters                |
//+------------------------------------------------------------------+
int CTextBox::TextWidth(const int symbols_total)
 {
  if(symbols_total<1)
     return(0);
  this.m_canvas.FontSet(this.m_font,-this.m_font_size*10);
  return(this.m_canvas.TextWidth(::StringSubstr(this.m_text,0,symbols_total)));
 }
//+------------------------------------------------------------------+
//| Nearest character boundary to chart x                            |
//+------------------------------------------------------------------+
int CTextBox::CursorPosByX(const int x)
 {
  int local=x-this.m_x-this.m_text_x_offset+this.m_shift_x;
  int len=::StringLen(this.m_text);
  int prev=0;
  for(int i=1; i<=len; i++)
    {
     int width=this.TextWidth(i);
     if(width>=local)
        return((width-local<local-prev) ? i : i-1);
     prev=width;
    }
  return(len);
 }
//+------------------------------------------------------------------+
//| Horizontal shift so the cursor stays inside the field            |
//+------------------------------------------------------------------+
void CTextBox::CorrectingShift(void)
 {
  int visible=this.m_x_size-2*this.m_text_x_offset;
  int cursor =this.TextWidth(this.m_text_cursor_x_pos);
  if(cursor-this.m_shift_x>visible)
     this.m_shift_x=cursor-visible;
  if(cursor<this.m_shift_x)
     this.m_shift_x=cursor;
  if(this.m_shift_x<0)
     this.m_shift_x=0;
 }
//+------------------------------------------------------------------+
//| Removes the selection, cursor at its start                       |
//+------------------------------------------------------------------+
bool CTextBox::DeleteSelectedText(void)
 {
  if(this.m_selected_symbol_from==WRONG_VALUE || this.m_selected_symbol_from==this.m_selected_symbol_to)
    {
     this.ResetSelectedText();
     return(false);
    }
  int from=::MathMin(this.m_selected_symbol_from,this.m_selected_symbol_to);
  int to  =::MathMax(this.m_selected_symbol_from,this.m_selected_symbol_to);
  this.m_text=::StringSubstr(this.m_text,0,from)+::StringSubstr(this.m_text,to);
  this.m_text_cursor_x_pos=from;
  this.ResetSelectedText();
  return(true);
 }
//+------------------------------------------------------------------+
//| Ctrl+Left/Right: to the previous/next word start                 |
//+------------------------------------------------------------------+
void CTextBox::MoveTextCursorByWord(const bool to_right)
 {
  int len=::StringLen(this.m_text);
  int pos=this.m_text_cursor_x_pos;
  if(to_right)
    {
     while(pos<len && ::StringGetCharacter(this.m_text,pos)!=' ')
        pos++;
     while(pos<len && ::StringGetCharacter(this.m_text,pos)==' ')
        pos++;
    }
  else
    {
     while(pos>0 && ::StringGetCharacter(this.m_text,pos-1)==' ')
        pos--;
     while(pos>0 && ::StringGetCharacter(this.m_text,pos-1)!=' ')
        pos--;
    }
  this.m_text_cursor_x_pos=pos;
 }
//+------------------------------------------------------------------+
//| Edit mode: chart keyboard and quick navigation off; select_all   |
//| (programmatic start) also selects the text and redraws           |
//+------------------------------------------------------------------+
void CTextBox::ActivateTextBox(const bool select_all=false)
 {
  if(this.m_text_edit_state)
     return;
  this.m_saved_keyboard_control=(bool)::ChartGetInteger(this.m_chart_id,CHART_KEYBOARD_CONTROL);
  this.m_saved_quick_navigation=(bool)::ChartGetInteger(this.m_chart_id,CHART_QUICK_NAVIGATION);
  ::ChartSetInteger(this.m_chart_id,CHART_KEYBOARD_CONTROL,false);
  ::ChartSetInteger(this.m_chart_id,CHART_QUICK_NAVIGATION,false);
  this.m_temp_input_string=this.m_text;
  this.m_text_edit_state=true;
  this.m_state=true;
  if(!select_all)
     return;
  this.m_selected_symbol_from=0;
  this.m_selected_symbol_to  =::StringLen(this.m_text);
  this.m_text_cursor_x_pos   =this.m_selected_symbol_to;
  this.CorrectingShift();
  this.m_cursor_state=true;
  this.m_counter.ZeroTimeCounter();
  this.Draw(true);
 }
//+------------------------------------------------------------------+
//| Leaves edit mode, restores the chart keyboard                    |
//+------------------------------------------------------------------+
void CTextBox::DeactivateTextBox(void)
 {
  if(!this.m_text_edit_state)
     return;
  this.m_text_edit_state=false;
  ::ChartSetInteger(this.m_chart_id,CHART_KEYBOARD_CONTROL,this.m_saved_keyboard_control);
  ::ChartSetInteger(this.m_chart_id,CHART_QUICK_NAVIGATION,this.m_saved_quick_navigation);
  this.ResetSelectedText();
  this.m_text_cursor_x_pos=0;
  this.m_shift_x=0;
  this.m_state=false;
  this.Draw(true);
 }
//+------------------------------------------------------------------+
//| Press starts editing (select all in auto selection mode) or      |
//| moves the cursor                                                 |
//+------------------------------------------------------------------+
void CTextBox::OnPress(const int x,const int y)
 {
  CGElement::OnPress(x,y);
  if(this.m_read_only_mode)
     return;
  bool activated=!this.m_text_edit_state;
  if(activated)
     this.ActivateTextBox();
  if(activated && this.m_auto_selection_mode)
    {
     this.m_selected_symbol_from=0;
     this.m_selected_symbol_to  =::StringLen(this.m_text);
     this.m_text_cursor_x_pos   =this.m_selected_symbol_to;
    }
  else
    {
     this.ResetSelectedText();
     this.m_text_cursor_x_pos=this.CursorPosByX(x);
    }
  this.CorrectingShift();
  this.m_cursor_state=true;
  this.m_counter.ZeroTimeCounter();
  this.Draw(true);
 }
//+------------------------------------------------------------------+
//| Keys while editing; Enter commits, Esc restores                  |
//+------------------------------------------------------------------+
bool CTextBox::OnPressedKey(const long key_code)
 {
  int len=::StringLen(this.m_text);
  if(key_code==KEY_ENTER)
    {
     this.DeactivateTextBox();
     this.SendEvent(ON_END_EDIT,0,this.m_text);
     return(true);
    }
  if(key_code==KEY_ESC)
    {
     this.m_text=this.m_temp_input_string;
     this.DeactivateTextBox();
     return(true);
    }
  if(key_code==KEY_BACKSPACE)
    {
     if(!this.DeleteSelectedText() && this.m_text_cursor_x_pos>0)
       {
        this.m_text=::StringSubstr(this.m_text,0,this.m_text_cursor_x_pos-1)+::StringSubstr(this.m_text,this.m_text_cursor_x_pos);
        this.m_text_cursor_x_pos--;
       }
    }
  else if(key_code==KEY_DELETE)
    {
     if(!this.DeleteSelectedText() && this.m_text_cursor_x_pos<len)
        this.m_text=::StringSubstr(this.m_text,0,this.m_text_cursor_x_pos)+::StringSubstr(this.m_text,this.m_text_cursor_x_pos+1);
    }
  else if(key_code==KEY_LEFT)
    {
     this.ResetSelectedText();
     if(this.m_keys.KeyCtrlState())
        this.MoveTextCursorByWord(false);
     else if(this.m_text_cursor_x_pos>0)
        this.m_text_cursor_x_pos--;
    }
  else if(key_code==KEY_RIGHT)
    {
     this.ResetSelectedText();
     if(this.m_keys.KeyCtrlState())
        this.MoveTextCursorByWord(true);
     else if(this.m_text_cursor_x_pos<len)
        this.m_text_cursor_x_pos++;
    }
  else if(key_code==KEY_HOME)
    {
     this.ResetSelectedText();
     this.m_text_cursor_x_pos=0;
    }
  else if(key_code==KEY_END)
    {
     this.ResetSelectedText();
     this.m_text_cursor_x_pos=len;
    }
  else
    {
     string symbol=this.m_keys.KeySymbol(key_code);
     if(symbol=="")
        return(false);
     this.DeleteSelectedText();
     this.m_text=::StringSubstr(this.m_text,0,this.m_text_cursor_x_pos)+symbol+::StringSubstr(this.m_text,this.m_text_cursor_x_pos);
     this.m_text_cursor_x_pos+=::StringLen(symbol);
    }
  this.CorrectingShift();
  this.m_cursor_state=true;
  this.m_counter.ZeroTimeCounter();
  this.Draw(true);
  return(true);
 }
//+------------------------------------------------------------------+
//| Default text, selection, text and cursor, border drawn again     |
//+------------------------------------------------------------------+
void CTextBox::DrawContent(void)
 {
  this.m_canvas.FontSet(this.m_font,-this.m_font_size*10);
  int x0=this.m_text_x_offset-this.m_shift_x;
  int ty=this.m_y_size/2;
  if(this.m_text=="" && !this.m_text_edit_state)
     this.m_canvas.TextOut(this.m_text_x_offset,ty,this.m_default_text,::ColorToARGB(this.m_default_text_color,255),TA_LEFT|TA_VCENTER);
  else
    {
     uint text_color=::ColorToARGB(this.ForeColor(),255);
     this.m_canvas.TextOut(x0,ty,this.m_text,text_color,TA_LEFT|TA_VCENTER);
     if(this.m_selected_symbol_from!=WRONG_VALUE && this.m_selected_symbol_from!=this.m_selected_symbol_to)
       {
        int from=::MathMin(this.m_selected_symbol_from,this.m_selected_symbol_to);
        int to  =::MathMax(this.m_selected_symbol_from,this.m_selected_symbol_to);
        int x1=x0+this.TextWidth(from);
        int x2=x0+this.TextWidth(to);
        this.m_canvas.FillRectangle(x1,2,x2,this.m_y_size-3,::ColorToARGB(this.m_selected_back_color,255));
        this.m_canvas.TextOut(x1,ty,::StringSubstr(this.m_text,from,to-from),::ColorToARGB(this.m_selected_text_color,255),TA_LEFT|TA_VCENTER);
       }
     if(this.m_text_edit_state && this.m_cursor_state)
       {
        int cx=x0+this.TextWidth(this.m_text_cursor_x_pos);
        this.m_canvas.Line(cx,3,cx,this.m_y_size-4,text_color);
       }
    }
  this.m_canvas.Rectangle(0,0,this.m_x_size-1,this.m_y_size-1,::ColorToARGB(this.BorderColor(),255));
 }
//+------------------------------------------------------------------+
//| Leaving edit mode when hidden                                    |
//+------------------------------------------------------------------+
void CTextBox::Hide(void)
 {
  this.DeactivateTextBox();
  CGElement::Hide();
 }
//+------------------------------------------------------------------+
//| Keys go to the field in edit mode; a new press outside commits   |
//+------------------------------------------------------------------+
void CTextBox::OnChartEvent(const int id,const long &lparam,const double &dparam,const string &sparam)
 {
  bool prev_left=this.m_prev_left;
  CGElement::OnChartEvent(id,lparam,dparam,sparam);
  if(!this.m_text_edit_state || !this.IsVisible())
     return;
  if(id==CHARTEVENT_KEYDOWN)
    {
     this.OnPressedKey(lparam);
     return;
    }
  if(id!=CHARTEVENT_MOUSE_MOVE || !s_mouse.IsLeftBtn() || prev_left || this.m_mouse_focus)
     return;
  this.DeactivateTextBox();
  this.SendEvent(ON_END_EDIT,0,this.m_text);
 }
//+------------------------------------------------------------------+
//| Blinking cursor while editing                                    |
//+------------------------------------------------------------------+
void CTextBox::OnTimerEvent(void)
 {
  CGElement::OnTimerEvent();
  if(!this.m_text_edit_state || !this.IsVisible() || !this.m_counter.CheckTimeCounter())
     return;
  this.m_cursor_state=!this.m_cursor_state;
  this.Draw(true);
 }
#endif // CTEXTBOX_MQH_IMPLEMENTATION
#endif // CTEXTBOX_MQH
