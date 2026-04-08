//+------------------------------------------------------------------+
//|                                              ButtonArrowUp.mqh   |
//|                                  Copyright 2025, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//| MVC Paradigm in MQL5                                             |
//| First See in             https://www.mql5.com/en/articles/18221  |
//| Current                   https://www.mql5.com/ru/articles/20596 |
//+------------------------------------------------------------------+
#property copyright "Copyright 2025, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
//+------------------------------------------------------------------+
//| Up arrow button class |
//+------------------------------------------------------------------+
#ifndef __BUTTONARROWUP_MQH__
#define __BUTTONARROWUP_MQH__ 
   //+------------------------------------------------------------------+
   //| Included Standard Libraries                                      |
   //+------------------------------------------------------------------+
   //#include <Arrays\List.mqh>
   //+------------------------------------------------------------------+
   //| Included Custome Libraries                                       |
   //+------------------------------------------------------------------+
   #include "Button.mqh"  
 class CButtonArrowUp : public CButton
   {
    public:
    // ---Draws the appearance
      virtual void      Draw(const bool chart_redraw);

    // --- Virtual methods (1) compare, (2) save to file, (3) load from file, (4) object type
      virtual int       Compare(const CObject *node,const int mode=0) const;
      virtual bool      Save(const int file_handle)               { return CButton::Save(file_handle);   }
      virtual bool      Load(const int file_handle)               { return CButton::Load(file_handle);   }
      virtual int       Type(void)                          const { return(ELEMENT_TYPE_BUTTON_ARROW_UP);}
      
    // --- Initialize (1) class object, (2) default object colors
      void              Init(const string text);
      virtual void      InitColors(void){}
      
    // --- Constructors/destructor
                        CButtonArrowUp(void);
                        CButtonArrowUp(const string object_name, const string text, const long chart_id, const int wnd, const int x, const int y, const int w, const int h);
                     ~CButtonArrowUp (void) {}
   };
  #ifndef CBUTTONARROWUP_IMPLEMENTATION
  #define CBUTTONARROWUP_IMPLEMENTATION
      //+------------------------------------------------------------------+
   // | CButtonArrowUp::Default constructor.                        |
   // | Builds a button in the main window of the current chart |
   // | at coordinates 0,0 with default dimensions |
   //+------------------------------------------------------------------+
   CButtonArrowUp::CButtonArrowUp(void) : CButton("Arrow Up Button","",::ChartID(),0,0,0,DEF_BUTTON_W,DEF_BUTTON_H)
    {
      // ---Initialization
      this.Init("");
    }
   //+------------------------------------------------------------------+
   // | CButtonArrowUp::Parametric constructor.                     |
   // | Builds a button in the specified window of the specified chart |
   // | with specified text, coordinates and dimensions |
   //+------------------------------------------------------------------+
   CButtonArrowUp::CButtonArrowUp(const string object_name, const string text,const long chart_id,const int wnd,const int x,const int y,const int w,const int h) :
      CButton(object_name,text,chart_id,wnd,x,y,w,h)
    {
      // ---Initialization
      this.Init("");
    }
   //+------------------------------------------------------------------+
   //| CButtonArrowUp::Initialization |
   //+------------------------------------------------------------------+
   void CButtonArrowUp::Init(const string text)
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
         this.m_autorepeat.SetName("ButtUpAutorepeatControl");
         this.m_autorepeat.SetDelay(DEF_AUTOREPEAT_DELAY);
         this.m_autorepeat.SetInterval(DEF_AUTOREPEAT_INTERVAL);
         this.m_autorepeat.SetEvent(CHARTEVENT_OBJECT_CLICK,0,0,this.NameFG());
    }
   //+------------------------------------------------------------------+
   //| CButtonArrowUp::Comparing two objects |
   //+------------------------------------------------------------------+
   int CButtonArrowUp::Compare(const CObject *node,const int mode=0) const
    {
      return CButton::Compare(node,mode);
    }
   //+------------------------------------------------------------------+
   // | CButtonArrowUp::Draws appearance |
   //+------------------------------------------------------------------+
   void CButtonArrowUp::Draw(const bool chart_redraw)
    {
      // --- Fill the button with the background color, draw a frame and update the background canvas
         this.Fill(this.BackColor(),false);
         this.m_background.Rectangle(this.AdjX(0),this.AdjY(0),this.AdjX(this.Width()-1),this.AdjY(this.Height()-1),::ColorToARGB(this.BorderColor(),this.AlphaBG()));
         this.m_background.Update(false);
      // --- Display button text
         CLabel::Draw(false);
      // --- Clear the drawing area
         this.m_painter.Clear(this.AdjX(this.m_painter.X()),this.AdjY(this.m_painter.Y()),this.m_painter.Width(),this.m_painter.Height(),false);
      // --- Set the arrow color for the normal and locked states of the button and draw an up arrow
         color clr=(!this.IsBlocked() ? this.GetForeColorControl().NewColor(this.ForeColor(),90,90,90) : this.ForeColor());
         this.m_painter.ArrowUp(this.AdjX(this.m_painter.X()),this.AdjY(this.m_painter.Y()),this.m_painter.Width(),this.m_painter.Height(),clr,this.AlphaFG(),true);
            
      // --- If indicated, update the schedule
         if(chart_redraw)
            ::ChartRedraw(this.m_chart_id);
    }
   //+------------------------------------------------------------------+
  #endif // CBUTTONARROWUP_IMPLEMENTATION
#endif // __BUTTONARROWUP_MQH__

