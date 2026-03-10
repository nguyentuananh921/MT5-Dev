//+------------------------------------------------------------------+
//|                                                      Button.mqh  |
//+------------------------------------------------------------------+
//|                   Tables in the MVC Paradigm in MQL5             |
//|                Customizable and sortable table columns           |
//|                           https://www.mql5.com/en/articles/19979 |
//+------------------------------------------------------------------+

#ifndef __BUTTON_MQH__
#define __BUTTON_MQH__
//+------------------------------------------------------------------+
//|Include stadard library                                           |
//+------------------------------------------------------------------+
#include <Object.mqh> 

//+------------------------------------------------------------------+
//|Include Custome library                                           |
//+------------------------------------------------------------------+
#include "ControlEnums.mqh"
#include "..\Base\BaseEnums.mqh"
#include "Label.mqh"
//+------------------------------------------------------------------+
class CButton : public CLabel
  {
public:
//--- Draw appearance
   virtual void      Draw(const bool chart_redraw);

//--- Virtual methods (1) comparison, (2) save to file, (3) load from file, (4) object type
   virtual int       Compare(const CObject *node,const int mode=0) const;
   virtual bool      Save(const int file_handle)               { return CLabel::Save(file_handle); }
   virtual bool      Load(const int file_handle)               { return CLabel::Load(file_handle); }
   virtual int       Type(void)                          const { return(ELEMENT_TYPE_BUTTON);      }
   
//--- Initialization (1) class object, (2) default object colors
   void              Init(const string text);
   virtual void      InitColors(void){}
   
//--- Timer event handler
   virtual void      TimerEventHandler(void);
   
//--- Constructors/destructor
                     CButton(void);
                     CButton(const string object_name, const string text, const long chart_id, const int wnd, const int x, const int y, const int w, const int h);
                    ~CButton (void) {}
  };

//+------------------------------------------------------------------+
//| CButton::Default constructor. Builds a button in the main window |
//| of the current chart at coordinates 0,0 with default size        |
//+------------------------------------------------------------------+
CButton::CButton(void) : CLabel("Button","Button",::ChartID(),0,0,0,DEF_BUTTON_W,DEF_BUTTON_H)
  {
//--- Initialization
   this.Init("");
  }

//+---------------------------------------------------------------------+
//| CButton::Parameterized constructor. Builds a button in the specified|
//| window of the specified chart with given text, coordinates and size |
//+---------------------------------------------------------------------+
CButton::CButton(const string object_name,const string text,const long chart_id,const int wnd,const int x,const int y,const int w,const int h) :
   CLabel(object_name,text,chart_id,wnd,x,y,w,h)
  {
//--- Initialization
   this.Init("");
  }

//+------------------------------------------------------------------+
//| CButton::Initialization                                          |
//+------------------------------------------------------------------+
void CButton::Init(const string text)
  {
//--- Set default state
   this.SetState(ELEMENT_STATE_DEF);
//--- Background and foreground are opaque
   this.SetAlpha(255);
//--- Default text offset from the left edge of the button
   this.m_text_x=2;
//--- Auto-repeat for button press disabled
   this.m_autorepeat_flag=false;
  }

//+------------------------------------------------------------------+
//| CButton::Compare two objects                                     |
//+------------------------------------------------------------------+
int CButton::Compare(const CObject *node,const int mode) const
  {
   return CLabel::Compare(node,mode);
  }

//+------------------------------------------------------------------+
//| CButton::Draw appearance                                         |
//+------------------------------------------------------------------+
void CButton::Draw(const bool chart_redraw)
  {
//--- Fill the button with background color, draw border and update background canvas
   this.Fill(this.BackColor(),false);
   this.m_background.Rectangle(this.AdjX(0),this.AdjY(0),this.AdjX(this.Width()-1),this.AdjY(this.Height()-1),::ColorToARGB(this.BorderColor(),this.AlphaBG()));
   this.m_background.Update(false);
//--- Draw button text
   CLabel::Draw(false);
      
//--- Redraw chart if requested
   if(chart_redraw)
      ::ChartRedraw(this.m_chart_id);
  }

//+------------------------------------------------------------------+
//| Timer event handler                                              |
//+------------------------------------------------------------------+
void CButton::TimerEventHandler(void)
  {
   if(this.m_autorepeat_flag)
      this.m_autorepeat.Process();
  }
//+------------------------------------------------------------------+

#endif // __BUTTON_MQH__