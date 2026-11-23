//+------------------------------------------------------------------+
//|                                                 ButtonsGroup.mqh |
//|                        Copyright 2015, MetaQuotes Software Corp. |
//|Library base on Link https://www.mql5.com/en/code/19703           |
//+------------------------------------------------------------------+
#property strict

#ifndef CBUTTONSGROUP_MQH
#define CBUTTONSGROUP_MQH
 #include "ButtonTriggered.mqh"
#ifndef CBUTTONSGROUP_MQH_DECLARATION
#define CBUTTONSGROUP_MQH_DECLARATION
//+------------------------------------------------------------------+
//| Group of two-state buttons, radio mode = only one pressed        |
//+------------------------------------------------------------------+
class CButtonsGroup : public CGElement
 {
  private:
    CButtonTriggered  m_buttons[];
    int               m_button_x_gap[];
    int               m_button_y_gap[];
    int               m_button_width[];
    color             m_button_color[];
    color             m_button_color_hover[];
    color             m_button_color_pressed[];
    bool              m_radio_buttons_mode;
    bool              m_radio_buttons_style;
    int               m_button_y_size;
    string            m_selected_button_text;
    int               m_selected_button_index;

    bool              CreateButtons(void);
    void              ApplyButtonColors(const int index);
    bool              OnClickButton(const long id);
  protected:
    virtual void      InitColors(void);
  public:
    bool              CreateButtonsGroup(const long chart_id,const int subwin,const string name,const int x,const int y);
    CButtonTriggered *GetButtonPointer(const uint index);
    int               ButtonsTotal(void)                       const { return(::ArraySize(m_buttons));  }
    void              ButtonYSize(const int y_size)                  { m_button_y_size=y_size;          }
    void              RadioButtonsMode(const bool flag)              { m_radio_buttons_mode=flag;       }
    void              RadioButtonsStyle(const bool flag)             { m_radio_buttons_style=flag;      }
    string            SelectedButtonText(void)                 const { return(m_selected_button_text);  }
    int               SelectedButtonIndex(void)                const { return(m_selected_button_index); }
    void              AddButton(const int x_gap,const int y_gap,const string text,const int width,
                                const color button_color=clrNONE,const color button_color_hover=clrNONE,const color button_color_pressed=clrNONE);
    void              SelectButton(const uint index);
    void              DeleteButtons(void);
    virtual void      OnChartEvent(const int id,const long &lparam,const double &dparam,const string &sparam);
                     CButtonsGroup(void);
                    ~CButtonsGroup(void) {}
 };
#endif // CBUTTONSGROUP_MQH_DECLARATION
#ifndef CBUTTONSGROUP_MQH_IMPLEMENTATION
#define CBUTTONSGROUP_MQH_IMPLEMENTATION
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
CButtonsGroup::CButtonsGroup(void) : m_radio_buttons_mode(false),
                                     m_radio_buttons_style(false),
                                     m_button_y_size(20),
                                     m_selected_button_text(""),
                                     m_selected_button_index(WRONG_VALUE)
 {
 }
//+------------------------------------------------------------------+
//| The group has no look of its own - transparent bounding box      |
//+------------------------------------------------------------------+
void CButtonsGroup::InitColors(void)
 {
  this.m_color_background.InitColors(clrNONE,clrNONE,clrNONE,clrNONE);
  this.m_color_foreground.InitColors(clrNONE,clrNONE,clrNONE,clrNONE);
  this.m_color_border.InitColors(clrNONE,clrNONE,clrNONE,clrNONE);
  this.m_color_background_act.InitColors(clrNONE,clrNONE,clrNONE,clrNONE);
  this.m_color_foreground_act.InitColors(clrNONE,clrNONE,clrNONE,clrNONE);
  this.m_color_border_act.InitColors(clrNONE,clrNONE,clrNONE,clrNONE);
 }
//+------------------------------------------------------------------+
//| Adds a button; after the group is created it is created at once  |
//+------------------------------------------------------------------+
void CButtonsGroup::AddButton(const int x_gap,const int y_gap,const string text,const int width,
                              const color button_color=clrNONE,const color button_color_hover=clrNONE,const color button_color_pressed=clrNONE)
 {
  int index=::ArraySize(this.m_buttons);
  ::ArrayResize(this.m_buttons,index+1,100);
  ::ArrayResize(this.m_button_x_gap,index+1,100);
  ::ArrayResize(this.m_button_y_gap,index+1,100);
  ::ArrayResize(this.m_button_width,index+1,100);
  ::ArrayResize(this.m_button_color,index+1,100);
  ::ArrayResize(this.m_button_color_hover,index+1,100);
  ::ArrayResize(this.m_button_color_pressed,index+1,100);
  this.m_buttons[index].SetText(text);
  this.m_button_x_gap[index]=x_gap;
  this.m_button_y_gap[index]=y_gap;
  this.m_button_width[index]=width;
  this.m_button_color[index]        =button_color;
  this.m_button_color_hover[index]  =button_color_hover;
  this.m_button_color_pressed[index]=button_color_pressed;
  if(this.m_radio_buttons_style)
    {
     this.m_buttons[index].IconFile(IMAGE_RESOURCE_BMP16_RADIO_BUTTON_OFF_BMP);
     this.m_buttons[index].IconFileLocked(IMAGE_RESOURCE_BMP16_RADIO_BUTTON_OFF_LOCKED_BMP);
     this.m_buttons[index].IconFilePressed(IMAGE_RESOURCE_BMP16_RADIO_BUTTON_ON_BMP);
     this.m_buttons[index].IconFilePressedLocked(IMAGE_RESOURCE_BMP16_RADIO_BUTTON_ON_LOCKED_BMP);
    }
  if(this.m_canvas.ChartObjectName()=="")
     return;
  //--- Group already on the chart: grow the box and create the button now
  this.Resize(::MathMax(this.m_x_size,x_gap+width),::MathMax(this.m_y_size,y_gap+this.m_button_y_size));
  this.AddChild(::GetPointer(this.m_buttons[index]));
  if(!this.m_buttons[index].Create(this.m_chart_id,this.m_subwindow,this.Name()+"_"+(string)index,x_gap,y_gap,width,this.m_button_y_size))
     return;
  this.ApplyButtonColors(index);
  if(!this.IsVisible())
     this.m_buttons[index].Hide();
 }
//+------------------------------------------------------------------+
//| Group box = bounding box of all buttons, buttons as children     |
//+------------------------------------------------------------------+
bool CButtonsGroup::CreateButtonsGroup(const long chart_id,const int subwin,const string name,const int x,const int y)
 {
  int total=this.ButtonsTotal();
  if(total<1)
    {
     ::Print(__FUNCTION__," > You must call this method when there is at least one button in the group! Use the method CButtonsGroup::AddButton()");
     return(false);
    }
  int w=1,h=1;
  for(int i=0; i<total; i++)
    {
     w=::MathMax(w,this.m_button_x_gap[i]+this.m_button_width[i]);
     h=::MathMax(h,this.m_button_y_gap[i]+this.m_button_y_size);
    }
  if(this.m_radio_buttons_mode && this.m_selected_button_index==WRONG_VALUE)
     this.m_selected_button_index=0;
  if(!this.Create(chart_id,subwin,name,x,y,w,h))
     return(false);
  return(this.CreateButtons());
 }
//+------------------------------------------------------------------+
//| Creates the buttons at the offsets given in AddButton            |
//+------------------------------------------------------------------+
bool CButtonsGroup::CreateButtons(void)
 {
  int total=this.ButtonsTotal();
  for(int i=0; i<total; i++)
    {
     this.AddChild(::GetPointer(this.m_buttons[i]));
     if(!this.m_buttons[i].Create(this.m_chart_id,this.m_subwindow,this.Name()+"_"+(string)i,this.m_button_x_gap[i],this.m_button_y_gap[i],this.m_button_width[i],this.m_button_y_size))
        return(false);
     this.ApplyButtonColors(i);
    }
  if(this.m_selected_button_index!=WRONG_VALUE)
     this.SelectButton(this.m_selected_button_index);
  return(true);
 }
//+------------------------------------------------------------------+
//| Colors given in AddButton, or the Kazharski radio-style look     |
//+------------------------------------------------------------------+
void CButtonsGroup::ApplyButtonColors(const int index)
 {
  CButtonTriggered *button=::GetPointer(this.m_buttons[index]);
  if(this.m_radio_buttons_style)
    {
     button.GetBackColorControl().InitColors(clrNONE,clrNONE,clrNONE,clrNONE);
     button.GetBorderColorControl().InitColors(clrNONE,clrNONE,clrNONE,clrNONE);
     button.GetForeColorControl().InitColors(clrBlack,C'0,120,215',clrBlack,clrGray);
     button.GetBackColorActControl().InitColors(clrNONE,clrNONE,clrNONE,clrNONE);
     button.GetBorderColorActControl().InitColors(clrNONE,clrNONE,clrNONE,clrNONE);
     button.GetForeColorActControl().InitColors(clrBlack,C'0,120,215',clrBlack,clrGray);
    }
  else
    {
     CColorElement *back    =button.GetBackColorControl();
     CColorElement *back_act=button.GetBackColorActControl();
     color normal =(this.m_button_color[index]!=clrNONE)         ? this.m_button_color[index]         : back.GetDefault();
     color hover  =(this.m_button_color_hover[index]!=clrNONE)   ? this.m_button_color_hover[index]   : back.GetFocused();
     color pressed=(this.m_button_color_pressed[index]!=clrNONE) ? this.m_button_color_pressed[index] : back.GetPressed();
     back.InitColors(normal,hover,pressed,back.GetBlocked());
     back_act.InitColors(pressed,pressed,pressed,back_act.GetBlocked());
    }
  button.ColorChange(COLOR_STATE_DEFAULT);
  button.Draw(false);
 }
//+------------------------------------------------------------------+
//| Returns a pointer to the button at the specified index           |
//+------------------------------------------------------------------+
CButtonTriggered *CButtonsGroup::GetButtonPointer(const uint index)
 {
  uint array_size=::ArraySize(this.m_buttons);
  if(array_size<1)
    {
     ::Print(__FUNCTION__," > There is no button in the group!");
     return(NULL);
    }
  uint i=(index>=array_size) ? array_size-1 : index;
  return(::GetPointer(this.m_buttons[i]));
 }
//+------------------------------------------------------------------+
//| Presses the button at index, releases all the others             |
//+------------------------------------------------------------------+
void CButtonsGroup::SelectButton(const uint index)
 {
  int total=this.ButtonsTotal();
  if(total<1)
     return;
  uint correct_index=(index>=(uint)total) ? total-1 : index;
  for(int i=0; i<total; i++)
     this.m_buttons[i].SetState(i==(int)correct_index);
  this.m_selected_button_index=(int)correct_index;
  this.m_selected_button_text =this.m_buttons[correct_index].Text();
 }
//+------------------------------------------------------------------+
//| Removes every button; AddButton then rebuilds the group live     |
//+------------------------------------------------------------------+
void CButtonsGroup::DeleteButtons(void)
 {
  int total=this.ButtonsTotal();
  for(int i=0; i<total; i++)
    {
     this.m_buttons[i].Destroy();
     this.DeleteChild(::GetPointer(this.m_buttons[i]));
    }
  ::ArrayResize(this.m_buttons,0,100);
  ::ArrayResize(this.m_button_x_gap,0,100);
  ::ArrayResize(this.m_button_y_gap,0,100);
  ::ArrayResize(this.m_button_width,0,100);
  ::ArrayResize(this.m_button_color,0,100);
  ::ArrayResize(this.m_button_color_hover,0,100);
  ::ArrayResize(this.m_button_color_pressed,0,100);
  this.m_selected_button_index=WRONG_VALUE;
  this.m_selected_button_text ="";
  this.Resize(1,1);
 }
//+------------------------------------------------------------------+
//| A button of this group was clicked                               |
//+------------------------------------------------------------------+
bool CButtonsGroup::OnClickButton(const long id)
 {
  int total=this.ButtonsTotal();
  int index=WRONG_VALUE;
  for(int i=0; i<total; i++)
     if(this.m_buttons[i].ObjectID()==id)
       {
        index=i;
        break;
       }
  if(index==WRONG_VALUE)
     return(false);
  if(this.m_radio_buttons_mode || this.m_buttons[index].State())
     this.SelectButton(index);
  else
    {
     this.m_selected_button_index=WRONG_VALUE;
     this.m_selected_button_text ="";
    }
  this.SendEvent(ON_CLICK_GROUP_BUTTON,this.m_selected_button_index,this.m_selected_button_text);
  return(true);
 }
//+------------------------------------------------------------------+
//| Children and mouse first, then clicks of own buttons             |
//+------------------------------------------------------------------+
void CButtonsGroup::OnChartEvent(const int id,const long &lparam,const double &dparam,const string &sparam)
 {
  CGElement::OnChartEvent(id,lparam,dparam,sparam);
  if(id==CHARTEVENT_CUSTOM+ON_CLICK_BUTTON && !this.m_is_locked)
     this.OnClickButton(lparam);
 }
#endif // CBUTTONSGROUP_MQH_IMPLEMENTATION
#endif // CBUTTONSGROUP_MQH
