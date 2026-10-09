//+------------------------------------------------------------------+
//|                                                    StatusBar.mqh |
//|                        Copyright 2015, MetaQuotes Software Corp. |
//|Library base on Link https://www.mql5.com/en/code/19703           |
//+------------------------------------------------------------------+
#property strict

#ifndef CSTATUSBAR_MQH
#define CSTATUSBAR_MQH
 #include "Label.mqh"
 #include "SeparateLine.mqh"
#ifndef CSTATUSBAR_MQH_DECLARATION
#define CSTATUSBAR_MQH_DECLARATION
//+------------------------------------------------------------------+
//| Row of CLabel parts split by vertical CSeparateLine; the first   |
//| part (width 0) takes the rest, follows the parent's right/bottom |
//+------------------------------------------------------------------+
class CStatusBar : public CGElement
 {
  private:
    CLabel            m_items[];
    CSeparateLine     m_sep_line[];
    string            m_text[];
    int               m_item_x_size[];
    int               m_bottom_gap;

    int               CalculationFirstItemXSize(void);
    void              ArrangeItems(void);
  protected:
    virtual void      InitColors(void);
  public:
    bool              CreateStatusBar(const long chart_id,const int subwin,const string name,const int x,const int y,const int w,const int h=22);
    CLabel           *GetItemPointer(const uint index);
    CSeparateLine    *GetSeparateLinePointer(const uint index);
    int               ItemsTotal(void)                      const { return(::ArraySize(m_text));     }
    int               SeparateLinesTotal(void)              const { return(::ArraySize(m_sep_line)); }
    void              AddItem(const string text,const int width);
    void              SetValue(const uint index,const string value);
    virtual void      ChangeWidthByRightWindowSide(void);
    virtual void      ChangeHeightByBottomWindowSide(void);
                     CStatusBar(void) : m_bottom_gap(WRONG_VALUE) {}
                    ~CStatusBar(void) {}
 };
#endif // CSTATUSBAR_MQH_DECLARATION
#ifndef CSTATUSBAR_MQH_IMPLEMENTATION
#define CSTATUSBAR_MQH_IMPLEMENTATION
//+------------------------------------------------------------------+
//| Kazharski: back C'225,225,225', border = back                    |
//+------------------------------------------------------------------+
void CStatusBar::InitColors(void)
 {
  color back=C'225,225,225';
  this.m_color_background.InitColors(back,back,back,back);
  this.m_color_foreground.InitColors(clrBlack,clrBlack,clrBlack,clrGray);
  this.m_color_border.InitColors(back,back,back,back);
  this.m_color_background_act.InitColors(back,back,back,back);
  this.m_color_foreground_act.InitColors(clrBlack,clrBlack,clrBlack,clrGray);
  this.m_color_border_act.InitColors(back,back,back,back);
 }
//+------------------------------------------------------------------+
//| Added before the bar is created                                  |
//+------------------------------------------------------------------+
void CStatusBar::AddItem(const string text,const int width)
 {
  int size=::ArraySize(this.m_text);
  ::ArrayResize(this.m_text,size+1);
  ::ArrayResize(this.m_item_x_size,size+1);
  this.m_text[size]       =text;
  this.m_item_x_size[size]=width;
 }
//+------------------------------------------------------------------+
//| Bar width minus the fixed parts                                  |
//+------------------------------------------------------------------+
int CStatusBar::CalculationFirstItemXSize(void)
 {
  int width=0;
  for(int i=1; i<this.ItemsTotal(); i++)
     width+=this.m_item_x_size[i];
  return(::MathMax(this.m_x_size-width,1));
 }
//+------------------------------------------------------------------+
//| Kazharski: parts at x = sum of previous widths, text gap 7,      |
//| separator at each part start from the second one                 |
//+------------------------------------------------------------------+
bool CStatusBar::CreateStatusBar(const long chart_id,const int subwin,const string name,const int x,const int y,const int w,const int h=22)
 {
  int items_total=this.ItemsTotal();
  if(items_total<1 || !this.Create(chart_id,subwin,name,x,y,w,h))
     return(false);
  CGElement *parent=dynamic_cast<CGElement *>(this.m_parent);
  if(parent!=NULL)
     this.m_bottom_gap=parent.Height()-(y+h);
  if(this.m_item_x_size[0]<1)
     this.m_item_x_size[0]=this.CalculationFirstItemXSize();
  ::ArrayResize(this.m_items,items_total);
  ::ArrayResize(this.m_sep_line,items_total-1);
  int ix=0;
  for(int i=0; i<items_total; i++)
    {
     this.AddChild(::GetPointer(this.m_items[i]));
     this.m_items[i].SetText(this.m_text[i]);
     this.m_items[i].LabelXGap(7);
     if(!this.m_items[i].Create(chart_id,subwin,this.Name()+"_item_"+(string)i,ix,0,this.m_item_x_size[i],h))
        return(false);
     if(i>0)
       {
        this.AddChild(::GetPointer(this.m_sep_line[i-1]));
        this.m_sep_line[i-1].TypeSepLine(V_SEP_LINE);
        if(!this.m_sep_line[i-1].CreateSeparateLine(chart_id,subwin,this.Name()+"_sep_"+(string)(i-1),ix,3,2,h-6))
           return(false);
       }
     ix+=this.m_item_x_size[i];
    }
  return(true);
 }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
CLabel *CStatusBar::GetItemPointer(const uint index)
 {
  return(index<(uint)::ArraySize(this.m_items) ? ::GetPointer(this.m_items[index]) : NULL);
 }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
CSeparateLine *CStatusBar::GetSeparateLinePointer(const uint index)
 {
  return(index<(uint)::ArraySize(this.m_sep_line) ? ::GetPointer(this.m_sep_line[index]) : NULL);
 }
//+------------------------------------------------------------------+
//| New text, the part is redrawn without chart redraw               |
//+------------------------------------------------------------------+
void CStatusBar::SetValue(const uint index,const string value)
 {
  if(index>=(uint)::ArraySize(this.m_items))
     return;
  this.m_items[index].SetText(value);
  this.m_items[index].Draw(false);
 }
//+------------------------------------------------------------------+
//| First part takes the new width, the others and separators move   |
//+------------------------------------------------------------------+
void CStatusBar::ArrangeItems(void)
 {
  int items_total=::ArraySize(this.m_items);
  if(items_total<1)
     return;
  this.m_item_x_size[0]=this.CalculationFirstItemXSize();
  this.m_items[0].Resize(this.m_item_x_size[0],this.m_y_size);
  int ix=this.m_item_x_size[0];
  for(int i=1; i<items_total; i++)
    {
     this.m_items[i].Move(this.m_x+ix,this.m_y);
     this.m_sep_line[i-1].Move(this.m_x+ix,this.m_y+3);
     ix+=this.m_item_x_size[i];
    }
 }
//+------------------------------------------------------------------+
//| Right edge 1px inside the parent (Kazharski auto x-resize)       |
//+------------------------------------------------------------------+
void CStatusBar::ChangeWidthByRightWindowSide(void)
 {
  CGElement *parent=dynamic_cast<CGElement *>(this.m_parent);
  if(parent==NULL)
     return;
  this.Resize(parent.Width()-this.m_x_gap-1,this.m_y_size);
  this.ArrangeItems();
  this.Draw(false);
 }
//+------------------------------------------------------------------+
//| Keeps the same distance to the parent's bottom                   |
//+------------------------------------------------------------------+
void CStatusBar::ChangeHeightByBottomWindowSide(void)
 {
  CGElement *parent=dynamic_cast<CGElement *>(this.m_parent);
  if(parent==NULL || this.m_bottom_gap==WRONG_VALUE)
     return;
  this.Move(this.m_x,parent.Y()+parent.Height()-this.m_y_size-this.m_bottom_gap);
 }
#endif // CSTATUSBAR_MQH_IMPLEMENTATION
#endif // CSTATUSBAR_MQH
