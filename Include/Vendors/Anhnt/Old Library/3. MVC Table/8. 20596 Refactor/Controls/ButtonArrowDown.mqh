//+------------------------------------------------------------------+
//|                                            ButtonArrowDown.mqh   |
//|                                  Copyright 2025, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//| MVC Paradigm in MQL5                                             |
//|       Simple controls                                            |
//|                           https://www.mql5.com/en/articles/18221 |
//| Update                    https://www.mql5.com/en/articles/18658 |
//| Current                   https://www.mql5.com/ru/articles/20596 |
//+------------------------------------------------------------------+
#property copyright "Copyright 2025, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
//+------------------------------------------------------------------+
// | Down arrow button class |
//+------------------------------------------------------------------+
#ifndef __BUTTONARROWDOWN_MQH__
#define __BUTTONARROWDOWN_MQH__ 
   //+------------------------------------------------------------------+
   //| Included Standard Libraries                                      |
   //+------------------------------------------------------------------+
   #include <Arrays\List.mqh>
   //+------------------------------------------------------------------+
   //| Included Custome Libraries                                       |
   //+------------------------------------------------------------------+
   #include "Button.mqh"  
 class CButtonArrowDown : public CButton
  {
      public:
      // ---Draws the appearance
         virtual void      Draw(const bool chart_redraw);

      // --- Virtual methods (1) compare, (2) save to file, (3) load from file, (4) object type
         virtual int       Compare(const CObject *node,const int mode=0) const;
         virtual bool      Save(const int file_handle)               { return CButton::Save(file_handle);      }
         virtual bool      Load(const int file_handle)               { return CButton::Load(file_handle);      }
         virtual int       Type(void)                          const { return(ELEMENT_TYPE_BUTTON_ARROW_DOWN); }
         
      // --- Initialize (1) class object, (2) default object colors
         void              Init(const string text);
         virtual void      InitColors(void){}
         
      // --- Constructors/destructor
                           CButtonArrowDown(void);
                           CButtonArrowDown(const string object_name, const string text, const long chart_id, const int wnd, const int x, const int y, const int w, const int h);
                        ~CButtonArrowDown (void) {}
  };
   //+------------------------------------------------------------------+
  #ifndef CBUTTONARROWDOWN_IMPLEMENTATION
  #define CBUTTONARROWDOWN_IMPLEMENTATION
   //+------------------------------------------------------------------+
   // | CButtonArrowDown::Default constructor.                      |
   // | Builds a button in the main window of the current chart |
   // | at coordinates 0,0 with default dimensions |
   //+------------------------------------------------------------------+
   CButtonArrowDown::CButtonArrowDown(void) : CButton("Arrow Up Button","",::ChartID(),0,0,0,DEF_BUTTON_W,DEF_BUTTON_H)
    {
      // ---Initialization
         this.Init("");
    }
   //+------------------------------------------------------------------+
   // | CButtonArrowDown::Parametric constructor.                   |
   // | Builds a button in the specified window of the specified chart |
   // | with specified text, coordinates and dimensions |
   //+------------------------------------------------------------------+
   CButtonArrowDown::CButtonArrowDown(const string object_name,const string text,const long chart_id,const int wnd,const int x,const int y,const int w,const int h) :
      CButton(object_name,text,chart_id,wnd,x,y,w,h)
    {
      // ---Initialization
         this.Init("");
    }
   //+------------------------------------------------------------------+
   // | CButtonArrowDown::Initialization |
   //+------------------------------------------------------------------+
   void CButtonArrowDown::Init(const string text)
    {
      // --- Initialize default colors
         this.InitColors();
      // --- Set the offset and dimensions of the image area
         this.SetImageBound(1,1,this.Height()-2,this.Height()-2);

      // --- Initialize auto-repeat counters
         this.m_autorepeat_flag=true;

      // --- Initialize the properties of the event auto-repeat control object
         this.m_autorepeat.SetChartID(this.m_chart_id);
         this.m_autorepeat.SetID(0);
         this.m_autorepeat.SetName("ButtDownAutorepeatControl");
         this.m_autorepeat.SetDelay(DEF_AUTOREPEAT_DELAY);
         this.m_autorepeat.SetInterval(DEF_AUTOREPEAT_INTERVAL);
         this.m_autorepeat.SetEvent(CHARTEVENT_OBJECT_CLICK,0,0,this.NameFG());
    }
   //+------------------------------------------------------------------+
   // | CButtonArrowDown::Comparing two objects |
   //+------------------------------------------------------------------+
   int CButtonArrowDown::Compare(const CObject *node,const int mode=0) const
    {
      return CButton::Compare(node,mode);
    }
   //+------------------------------------------------------------------+
   // | CButtonArrowDown::Draws appearance |
   //+------------------------------------------------------------------+
   void CButtonArrowDown::Draw(const bool chart_redraw)
    {
     // --- Fill the button with the background color, draw a frame and update the background canvas
      this.Fill(this.BackColor(),false);
      this.m_background.Rectangle(this.AdjX(0),this.AdjY(0),this.AdjX(this.Width()-1),this.AdjY(this.Height()-1),::ColorToARGB(this.BorderColor(),this.AlphaBG()));
      this.m_background.Update(false);
     // --- Display button text
      CLabel::Draw(false);
     // --- Clear the drawing area
      this.m_painter.Clear(this.AdjX(this.m_painter.X()),this.AdjY(this.m_painter.Y()),this.m_painter.Width(),this.m_painter.Height(),false);
     // --- Set the arrow color for the normal and locked states of the button and draw a down arrow
      color clr=(!this.IsBlocked() ? this.GetForeColorControl().NewColor(this.ForeColor(),90,90,90) : this.ForeColor());
      this.m_painter.ArrowDown(this.AdjX(this.m_painter.X()),this.AdjY(this.m_painter.Y()),this.m_painter.Width(),this.m_painter.Height(),clr,this.AlphaFG(),true);
         
     // --- If indicated, update the schedule
      if(chart_redraw)
         ::ChartRedraw(this.m_chart_id);
    }
   //+------------------------------------------------------------------+
  #endif // CBUTTONARROWDOWN_IMPLEMENTATION
#endif // __BUTTONARROWDOWN_MQH__


