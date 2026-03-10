//+------------------------------------------------------------------+
//|                                              ButtonArrowLeft.mqh |
//+------------------------------------------------------------------+
//| Button with arrow left class                                     |
//+------------------------------------------------------------------+
#ifndef __BUTTONARROWLEFT_MQH__
#define __BUTTONARROWLEFT_MQH__
//+------------------------------------------------------------------+
//|Include stadard library                                           |
//+------------------------------------------------------------------+


//+------------------------------------------------------------------+
//|Include Custome library                                           |
//+------------------------------------------------------------------+
#include "Button.mqh"
//chain: CButton→Label.mqh→ElementBase.mqh→CanvasBase.mqh→BoundedObj.mqh→BaseObj.mqh→Object.mqh
// enums: ControlEnums.mqh

class CButtonArrowLeft : public CButton
  {
public:
//--- Draws the appearance
   virtual void      Draw(const bool chart_redraw);

//--- Virtual methods: (1) comparison, (2) saving to file, (3) loading from file, (4) object type
   virtual int       Compare(const CObject *node,const int mode=0) const;
   virtual bool      Save(const int file_handle)               { return CButton::Save(file_handle);      }
   virtual bool      Load(const int file_handle)               { return CButton::Load(file_handle);      }
   virtual int       Type(void)                          const { return(ELEMENT_TYPE_BUTTON_ARROW_DOWN); }
   
//--- Initialization: (1) class object, (2) default object colors
   void              Init(const string text);
   virtual void      InitColors(void){}
   
//--- Constructors/destructor
                     CButtonArrowLeft(void);
                     CButtonArrowLeft(const string object_name, const string text, const long chart_id, const int wnd, const int x, const int y, const int w, const int h);
                    ~CButtonArrowLeft (void) {}
  };
//+------------------------------------------------------------------+
//| CButtonArrowLeft::Default constructor.                           |
//| Creates a button in the main window of the current chart         |
//| at coordinates 0,0 with default sizes                            |
//+------------------------------------------------------------------+
CButtonArrowLeft::CButtonArrowLeft(void) : CButton("Arrow Up Button","",::ChartID(),0,0,0,DEF_BUTTON_W,DEF_BUTTON_H)
  {
//--- Initialization
   this.Init("");
  }
//+------------------------------------------------------------------+
//| CButtonArrowLeft::Parametric constructor.                        |
//| Creates a button in the specified window of the specified chart  |
//| with the specified text, coordinates, and sizes                  |
//+------------------------------------------------------------------+
CButtonArrowLeft::CButtonArrowLeft(const string object_name,const string text,const long chart_id,const int wnd,const int x,const int y,const int w,const int h) :
   CButton(object_name,text,chart_id,wnd,x,y,w,h)
  {
//--- Initialization
   this.Init("");
  }
//+------------------------------------------------------------------+
//| CButtonArrowLeft::Initialization                                 |
//+------------------------------------------------------------------+
void CButtonArrowLeft::Init(const string text)
  {
//--- Initialize default colors
   this.InitColors();
//--- Set offset and size of the image area
   this.SetImageBound(1,1,this.Height()-2,this.Height()-2);

//--- Initialize auto-repeat flags
   this.m_autorepeat_flag=true;

//--- Initialize properties of the event auto-repeat control object
   this.m_autorepeat.SetChartID(this.m_chart_id);
   this.m_autorepeat.SetID(0);
   this.m_autorepeat.SetName("ButtLeftAutorepeatControl");
   this.m_autorepeat.SetDelay(DEF_AUTOREPEAT_DELAY);
   this.m_autorepeat.SetInterval(DEF_AUTOREPEAT_INTERVAL);
   this.m_autorepeat.SetEvent(CHARTEVENT_OBJECT_CLICK,0,0,this.NameFG());
  }
//+------------------------------------------------------------------+
//| CButtonArrowLeft::Comparison of two objects                      |
//+------------------------------------------------------------------+
int CButtonArrowLeft::Compare(const CObject *node,const int mode=0) const
  {
   return CButton::Compare(node,mode);
  }
//+------------------------------------------------------------------+
//| CButtonArrowLeft::Draws the appearance                           |
//+------------------------------------------------------------------+
void CButtonArrowLeft::Draw(const bool chart_redraw)
  {
//--- Fill the button with background color, draw a frame and update background canvas
   this.Fill(this.BackColor(),false);
   this.m_background.Rectangle(this.AdjX(0),this.AdjY(0),this.AdjX(this.Width()-1),this.AdjY(this.Height()-1),::ColorToARGB(this.BorderColor(),this.AlphaBG()));
   this.m_background.Update(false);
//--- Display button text
   CLabel::Draw(false);
//--- Clear the drawing area
   this.m_painter.Clear(this.AdjX(this.m_painter.X()),this.AdjY(this.m_painter.Y()),this.m_painter.Width(),this.m_painter.Height(),false);
//--- Set arrow color for normal and blocked states and draw arrow left
   color clr=(!this.IsBlocked() ? this.GetForeColorControl().NewColor(this.ForeColor(),90,90,90) : this.ForeColor());
   this.m_painter.ArrowLeft(this.AdjX(this.m_painter.X()),this.AdjY(this.m_painter.Y()),this.m_painter.Width(),this.m_painter.Height(),clr,this.AlphaFG(),true);
      
//--- If specified, redraw the chart
   if(chart_redraw)
      ::ChartRedraw(this.m_chart_id);
  }

#endif