//+------------------------------------------------------------------+
//|                                                     ComboBox.mqh |
//|                        Copyright 2015, MetaQuotes Software Corp. |
//|Library base on Link https://www.mql5.com/en/code/19703           |
//+------------------------------------------------------------------+
#property strict

#ifndef CCOMBOBOX_MQH
#define CCOMBOBOX_MQH
 #include "ButtonTriggered.mqh"
 #include "ListView.mqh"
#ifndef CCOMBOBOX_MQH_DECLARATION
#define CCOMBOBOX_MQH_DECLARATION
//+------------------------------------------------------------------+
//| Label + triggered button + dropdown list                         |
//+------------------------------------------------------------------+
class CComboBox : public CButton
 {
  private:
    CButtonTriggered  m_button;
    CListView         m_listview;
    bool              m_checkbox_mode;
  protected:
    virtual void      InitColors(void);
    virtual void      OnRelease(const int x,const int y);
  public:
    bool              CreateComboBox(const long chart_id,const int subwin,const string name,const int x,const int y,const int w,
                                     const int h=20,const int button_x_size=80,const int list_y_size=93);
    CButtonTriggered *GetButtonPointer(void)                   { return(::GetPointer(m_button));         }
    CListView        *GetListViewPointer(void)                 { return(::GetPointer(m_listview));       }
    CScrollV         *GetScrollVPointer(void)                  { return(m_listview.GetScrollVPointer()); }
    void              ItemsTotal(const int items_total)        { m_listview.ListSize(items_total);       }
    void              CheckBoxMode(const bool state)           { m_checkbox_mode=state;                  }
    void              SetValue(const int item_index,const string item_text) { m_listview.SetValue(item_index,item_text); }
    string            GetValue(void)                           { return(m_listview.SelectedItemText());  }
    void              SelectItem(const int item_index);
    void              ChangeComboBoxListState(void);
    virtual void      Show(void);
    virtual void      Hide(void);
    virtual void      OnChartEvent(const int id,const long &lparam,const double &dparam,const string &sparam);
                     CComboBox(void);
                    ~CComboBox(void) {}
 };
#endif // CCOMBOBOX_MQH_DECLARATION
#ifndef CCOMBOBOX_MQH_IMPLEMENTATION
#define CCOMBOBOX_MQH_IMPLEMENTATION
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
CComboBox::CComboBox(void) : m_checkbox_mode(false)
 {
  this.LabelXGap(0);
 }
//+------------------------------------------------------------------+
//| Kazharski combo box label: hover C'0,120,215', locked silver     |
//+------------------------------------------------------------------+
void CComboBox::InitColors(void)
 {
  this.m_color_background.InitColors(clrNONE,clrNONE,clrNONE,clrNONE);
  this.m_color_foreground.InitColors(clrBlack,C'0,120,215',clrBlack,clrSilver);
  this.m_color_border.InitColors(clrNONE,clrNONE,clrNONE,clrNONE);
  this.m_color_background_act.InitColors(clrNONE,clrNONE,clrNONE,clrNONE);
  this.m_color_foreground_act.InitColors(clrBlack,C'0,120,215',clrBlack,clrSilver);
  this.m_color_border_act.InitColors(clrNONE,clrNONE,clrNONE,clrNONE);
 }
//+------------------------------------------------------------------+
//| Label canvas, button on the right, hidden list under the button  |
//+------------------------------------------------------------------+
bool CComboBox::CreateComboBox(const long chart_id,const int subwin,const string name,const int x,const int y,const int w,
                               const int h=20,const int button_x_size=80,const int list_y_size=93)
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
  int button_x=w-button_x_size;
  this.AddChild(::GetPointer(this.m_button));
  this.m_button.IconFile(IMAGE_RESOURCE_BMP16_DOWN_THIN_BLACK_BMP);
  this.m_button.IconFileLocked(IMAGE_RESOURCE_BMP16_DOWN_THIN_BLACK_BMP);
  this.m_button.IconFilePressed(IMAGE_RESOURCE_BMP16_UP_THIN_BLACK_BMP);
  this.m_button.IconFilePressedLocked(IMAGE_RESOURCE_BMP16_UP_THIN_BLACK_BMP);
  this.m_button.IconXGap(button_x_size-18);
  this.m_button.LabelXGap(7);
  this.m_button.SetText(this.m_listview.SelectedItemText());
  if(!this.m_button.Create(chart_id,subwin,this.Name()+"_button",button_x,0,button_x_size,h))
     return(false);
  this.AddChild(::GetPointer(this.m_listview));
  if(!this.m_listview.CreateListView(chart_id,subwin,this.Name()+"_listview",button_x,h,button_x_size,list_y_size))
     return(false);
  this.m_listview.Hide();
  return(true);
 }
//+------------------------------------------------------------------+
//| Selects the list item and shows it on the button                 |
//+------------------------------------------------------------------+
void CComboBox::SelectItem(const int item_index)
 {
  this.m_listview.SelectItem(item_index);
  this.m_button.SetText(this.m_listview.SelectedItemText());
  this.m_button.Draw(true);
 }
//+------------------------------------------------------------------+
//| Opens/closes the list after the button state, parent is told     |
//| to block/unblock the other controls                              |
//+------------------------------------------------------------------+
void CComboBox::ChangeComboBoxListState(void)
 {
  if(this.m_button.State())
    {
     this.m_listview.Show();
     this.SendEvent(ON_SET_AVAILABLE,0,"");
    }
  else
    {
     this.m_listview.Hide();
     this.SendEvent(ON_SET_AVAILABLE,1,"");
    }
  ::ChartRedraw(this.m_chart_id);
 }
//+------------------------------------------------------------------+
//| Click on the label flips the check in checkbox mode              |
//+------------------------------------------------------------------+
void CComboBox::OnRelease(const int x,const int y)
 {
  CGElement::OnRelease(x,y);
  if(!this.m_checkbox_mode || !this.m_mouse_focus)
     return;
  this.SetState(!this.m_state);
  this.SendEvent(ON_CLICK_CHECKBOX,(this.m_state ? 1 : 0),this.m_text);
 }
//+------------------------------------------------------------------+
//| Base Show cascades to the list, keep it closed                   |
//+------------------------------------------------------------------+
void CComboBox::Show(void)
 {
  CGElement::Show();
  this.m_listview.Hide();
  this.m_button.SetState(false);
 }
//+------------------------------------------------------------------+
//| Hiding an open combo box unblocks the other controls             |
//+------------------------------------------------------------------+
void CComboBox::Hide(void)
 {
  bool opened=this.m_button.State();
  CGElement::Hide();
  if(!opened)
     return;
  this.m_button.SetState(false);
  this.SendEvent(ON_SET_AVAILABLE,1,"");
 }
//+------------------------------------------------------------------+
//| Button toggles the list, item click selects and closes, a new    |
//| press outside or a chart change closes it                        |
//+------------------------------------------------------------------+
void CComboBox::OnChartEvent(const int id,const long &lparam,const double &dparam,const string &sparam)
 {
  bool prev_left=this.m_prev_left;
  CGElement::OnChartEvent(id,lparam,dparam,sparam);
  if(id==CHARTEVENT_CUSTOM+ON_CLICK_BUTTON)
    {
     if(lparam!=this.m_button.ObjectID())
        return;
     this.ChangeComboBoxListState();
     this.SendEvent(ON_CLICK_COMBOBOX_BUTTON,(this.m_button.State() ? 1 : 0),"");
     return;
    }
  if(id==CHARTEVENT_CUSTOM+ON_CLICK_LIST_ITEM)
    {
     if(lparam!=this.m_listview.ObjectID())
        return;
     this.m_button.SetText(this.m_listview.SelectedItemText());
     this.m_button.SetState(false);
     this.ChangeComboBoxListState();
     this.SendEvent(ON_CLICK_COMBOBOX_ITEM,this.m_listview.SelectedItemIndex(),this.m_listview.SelectedItemText());
     return;
    }
  if(!this.m_button.State() || !this.IsVisible())
     return;
  if(id==CHARTEVENT_CHART_CHANGE)
    {
     this.m_button.SetState(false);
     this.ChangeComboBoxListState();
     return;
    }
  if(id!=CHARTEVENT_MOUSE_MOVE || this.m_is_locked || !s_mouse.IsLeftBtn() || prev_left)
     return;
  if(this.m_mouse_focus || this.m_button.MouseFocus() || this.m_listview.MouseFocus())
     return;
  this.m_button.SetState(false);
  this.ChangeComboBoxListState();
 }
#endif // CCOMBOBOX_MQH_IMPLEMENTATION
#endif // CCOMBOBOX_MQH
