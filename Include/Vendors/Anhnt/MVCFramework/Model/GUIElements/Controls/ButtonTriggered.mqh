//+------------------------------------------------------------------+
//|                                             ButtonTriggered.mqh  |
//+------------------------------------------------------------------+
//| Trigger button class (two-state button)                          |
//+------------------------------------------------------------------+
#ifndef __BUTTONTRIGGERED_MQH__
#define __BUTTONTRIGGERED_MQH__
//+------------------------------------------------------------------+
//|Include stadard library                                           |
//+------------------------------------------------------------------+


//+------------------------------------------------------------------+
//|Include Custome library                                           |
//+------------------------------------------------------------------+
#include "Button.mqh"
//chain: CButton→Label.mqh→ElementBase.mqh→CanvasBase.mqh→BoundedObj.mqh→BaseObj.mqh→Object.mqh
//enums: ControlEnums.mqh

class CButtonTriggered : public CButton
  {
public:
//--- Draws the appearance
   virtual void      Draw(const bool chart_redraw);

//--- Virtual methods: (1) comparison, (2) saving to file, (3) loading from file, (4) object type
   virtual int       Compare(const CObject *node,const int mode=0) const;
   virtual bool      Save(const int file_handle)               { return CButton::Save(file_handle);      }
   virtual bool      Load(const int file_handle)               { return CButton::Load(file_handle);      }
   virtual int       Type(void)                          const { return(ELEMENT_TYPE_BUTTON_TRIGGERED);  }
  
//--- Mouse button press event handler (Press)
   virtual void      OnPressEvent(const int id, const long lparam, const double dparam, const string sparam);

//--- Initialization: (1) class object, (2) default object colors
   void              Init(const string text);
   virtual void      InitColors(void);
   
//--- Constructors/destructor
                     CButtonTriggered(void);
                     CButtonTriggered(const string object_name, const string text, const long chart_id, const int wnd, const int x, const int y, const int w, const int h);
                    ~CButtonTriggered (void) {}
  };
//+------------------------------------------------------------------+
//| CButtonTriggered::Default constructor.                           |
//| Creates a button in the main window of the current chart         |
//| at coordinates 0,0 with default sizes                            |
//+------------------------------------------------------------------+
CButtonTriggered::CButtonTriggered(void) : CButton("Button","Button",::ChartID(),0,0,0,DEF_BUTTON_W,DEF_BUTTON_H)
  {
//--- Initialization
   this.Init("");
  }
//+------------------------------------------------------------------+
//| CButtonTriggered::Parametric constructor.                        |
//| Creates a button in the specified window of the specified chart  |
//| with the specified text, coordinates, and sizes                  |
//+------------------------------------------------------------------+
CButtonTriggered::CButtonTriggered(const string object_name,const string text,const long chart_id,const int wnd,const int x,const int y,const int w,const int h) :
   CButton(object_name,text,chart_id,wnd,x,y,w,h)
  {
//--- Initialization
   this.Init("");
  }
//+------------------------------------------------------------------+
//| CButtonTriggered::Initialization                                 |
//+------------------------------------------------------------------+
void CButtonTriggered::Init(const string text)
  {
//--- Initialize default colors
   this.InitColors();
  }
//+------------------------------------------------------------------+
//| CButtonTriggered::Initialization of default object colors        |
//+------------------------------------------------------------------+
void CButtonTriggered::InitColors(void)
  {
//--- Initialize background colors for normal and activated states and make it the current background color
   this.InitBackColors(clrWhiteSmoke);
   this.InitBackColorsAct(clrLightBlue);
   this.BackColorToDefault();
   
//--- Initialize foreground colors for normal and activated states and make it the current text color
   this.InitForeColors(clrBlack);
   this.InitForeColorsAct(clrBlack);
   this.ForeColorToDefault();
   
//--- Initialize border colors for normal and activated states and make it the current border color
   this.InitBorderColors(clrDarkGray);
   this.InitBorderColorsAct(clrGreen);
   this.BorderColorToDefault();
   
//--- Initialize border color and foreground color for the blocked element
   this.InitBorderColorBlocked(clrLightGray);
   this.InitForeColorBlocked(clrSilver);
  }
//+------------------------------------------------------------------+
//| CButtonTriggered::Comparison of two objects                      |
//+------------------------------------------------------------------+
int CButtonTriggered::Compare(const CObject *node,const int mode=0) const
  {
   return CButton::Compare(node,mode);
  }
//+------------------------------------------------------------------+
//| CButtonTriggered::Draws the appearance                           |
//+------------------------------------------------------------------+
void CButtonTriggered::Draw(const bool chart_redraw)
  {
//--- Fill the button with background color, draw a frame, and update background canvas
   this.Fill(this.BackColor(),false);
   this.m_background.Rectangle(this.AdjX(0),this.AdjY(0),this.AdjX(this.Width()-1),this.AdjY(this.Height()-1),::ColorToARGB(this.BorderColor(),this.AlphaBG()));
   this.m_background.Update(false);
//--- Display button text
   CLabel::Draw(false);
      
//--- If specified - redraw the chart
   if(chart_redraw)
      ::ChartRedraw(this.m_chart_id);
  }
//+------------------------------------------------------------------+
//| CButtonTriggered::Mouse button press event handler (Press)       |
//+------------------------------------------------------------------+
void CButtonTriggered::OnPressEvent(const int id,const long lparam,const double dparam,const string sparam)
  {
//--- Set the button state to the opposite of the currently set state
   ENUM_ELEMENT_STATE state=(this.State()==ELEMENT_STATE_DEF ? ELEMENT_STATE_ACT : ELEMENT_STATE_DEF);
   this.SetState(state);
   
//--- Call the parent object handler specifying the ID in lparam and state in dparam
   CCanvasBase::OnPressEvent(id,this.m_id,this.m_state,sparam);
  }
#endif