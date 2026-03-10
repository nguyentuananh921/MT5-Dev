//+------------------------------------------------------------------+
//|                                                      CheckBox.mqh|
//+------------------------------------------------------------------+
//|                   Tables in the MVC Paradigm in MQL5             |
//|                Customizable and sortable table columns           |
//|                   https://www.mql5.com/en/articles/19979         |
//+------------------------------------------------------------------+

#ifndef __CHECKBOX_MQH__
#define __CHECKBOX_MQH__
//+------------------------------------------------------------------+
//|Include stadard library                                           |
//+------------------------------------------------------------------+


//+------------------------------------------------------------------+
//|Include Custome library                                           |
//+------------------------------------------------------------------+
#include "ButtonTriggered.mqh"

//+------------------------------------------------------------------+
//| Checkbox control element class                                   |
//+------------------------------------------------------------------+
class CCheckBox : public CButtonTriggered
  {
public:
//--- Draw appearance
   virtual void Draw(const bool chart_redraw);

//--- Virtual methods: (1) compare, (2) save to file, (3) load from file, (4) object type
   virtual int  Compare(const CObject *node,const int mode=0) const;
   virtual bool Save(const int file_handle){ return CButton::Save(file_handle); }
   virtual bool Load(const int file_handle){ return CButton::Load(file_handle); }
   virtual int  Type(void) const { return(ELEMENT_TYPE_CHECKBOX); }

//--- Initialization: (1) class object, (2) default object colors
   void Init(const string text);
   virtual void InitColors(void);

//--- Constructors / destructor
   CCheckBox(void);
   CCheckBox(const string object_name,const string text,const long chart_id,const int wnd,const int x,const int y,const int w,const int h);
   ~CCheckBox(void){}
  };

//+------------------------------------------------------------------+
//| Default constructor                                              |
//| Builds element in main chart window at 0,0                       |
//| using default size                                               |
//+------------------------------------------------------------------+
CCheckBox::CCheckBox(void) :
CButtonTriggered("CheckBox","CheckBox",::ChartID(),0,0,0,DEF_BUTTON_W,DEF_BUTTON_H)
  {
   this.Init("");
  }

//+------------------------------------------------------------------+
//| Parameterized constructor                                        |
//| Builds element in specified chart window with given parameters   |
//+------------------------------------------------------------------+
CCheckBox::CCheckBox(const string object_name,const string text,const long chart_id,const int wnd,const int x,const int y,const int w,const int h) :
CButtonTriggered(object_name,text,chart_id,wnd,x,y,w,h)
  {
   this.Init("");
  }

//+------------------------------------------------------------------+
//| Initialization                                                   |
//+------------------------------------------------------------------+
void CCheckBox::Init(const string text)
  {
   this.InitColors();
   this.SetAlphaBG(0);
   this.SetAlphaFG(255);
   this.SetImageBound(1,1,this.Height()-2,this.Height()-2);
  }

//+------------------------------------------------------------------+
//| Initialize default colors                                        |
//+------------------------------------------------------------------+
void CCheckBox::InitColors(void)
  {
   this.InitBackColors(clrNULL);
   this.InitBackColorsAct(clrNULL);
   this.BackColorToDefault();

   this.InitForeColors(clrBlack);
   this.InitForeColorsAct(clrBlack);
   this.InitForeColorFocused(clrNavy);
   this.InitForeColorActFocused(clrNavy);
   this.ForeColorToDefault();

   this.InitBorderColors(clrNULL);
   this.InitBorderColorsAct(clrNULL);
   this.BorderColorToDefault();

   this.InitBorderColorBlocked(clrNULL);
   this.InitForeColorBlocked(clrSilver);
  }

//+------------------------------------------------------------------+
int CCheckBox::Compare(const CObject *node,const int mode=0) const
  {
   return CButtonTriggered::Compare(node,mode);
  }

//+------------------------------------------------------------------+
void CCheckBox::Draw(const bool chart_redraw)
  {
   this.Fill(this.BackColor(),false);
   this.m_background.Rectangle(this.AdjX(0),this.AdjY(0),this.AdjX(this.Width()-1),this.AdjY(this.Height()-1),
                                ::ColorToARGB(this.BorderColor(),this.AlphaBG()));
   this.m_background.Update(false);

   CLabel::Draw(false);

   this.m_painter.Clear(this.AdjX(this.m_painter.X()),this.AdjY(this.m_painter.Y()),
                        this.m_painter.Width(),this.m_painter.Height(),false);

   if(this.m_state)
      this.m_painter.CheckedBox(this.AdjX(this.m_painter.X()),this.AdjY(this.m_painter.Y()),
                                this.m_painter.Width(),this.m_painter.Height(),
                                this.ForeColor(),this.AlphaFG(),true);
   else
      this.m_painter.UncheckedBox(this.AdjX(this.m_painter.X()),this.AdjY(this.m_painter.Y()),
                                  this.m_painter.Width(),this.m_painter.Height(),
                                  this.ForeColor(),this.AlphaFG(),true);

   if(chart_redraw)
      ::ChartRedraw(this.m_chart_id);
  }

#endif