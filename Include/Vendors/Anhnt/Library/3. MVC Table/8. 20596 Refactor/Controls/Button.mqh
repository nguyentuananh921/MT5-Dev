//+------------------------------------------------------------------+
//|                                                     Button.mqh   |
//|                                  Copyright 2025, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//| MVC Paradigm in MQL5                                             |
//|                                                                  |
//|                           https://www.mql5.com/ru/articles/20596 |
//+------------------------------------------------------------------+
#property copyright "Copyright 2025, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
//+------------------------------------------------------------------+
//| Simple button class |
//+------------------------------------------------------------------+
#ifndef __BUTTON_MQH__
#define __BUTTON_MQH__
   //+------------------------------------------------------------------+
   //| Included Standard Libraries                                      |
   //+------------------------------------------------------------------+
   //#include <Arrays\List.mqh>
   //+------------------------------------------------------------------+
   //| Included Custome Libraries                                       |
   //+------------------------------------------------------------------+
   #include "..\Defines\BaseDefines.mqh"
   #include "..\Defines\BaseEnums.mqh"
   #include "..\Defines\ControlsDefines.mqh"
   #include "..\Defines\ControlsEnums.mqh"
   #include "Label.mqh"   
  class CButton : public CLabel
   {
      public:
      // ---Draws the appearance
         virtual void      Draw(const bool chart_redraw);

      // --- Virtual methods (1) compare, (2) save to file, (3) load from file, (4) object type
         virtual int       Compare(const CObject *node,const int mode=0) const;
         virtual bool      Save(const int file_handle)               { return CLabel::Save(file_handle); }
         virtual bool      Load(const int file_handle)               { return CLabel::Load(file_handle); }
         virtual int       Type(void)                          const { return(ELEMENT_TYPE_BUTTON);      }
         
      // --- Initialize (1) class object, (2) default object colors
         void              Init(const string text);
         virtual void      InitColors(void){}
         
      // --- Timer event handler
         virtual void      TimerEventHandler(void);
         
      // --- Constructors/destructor
                           CButton(void);
                           CButton(const string object_name, const string text, const long chart_id, const int wnd, const int x, const int y, const int w, const int h);
                           ~CButton (void) {}
   };
 #ifndef CBUTTON_IMPLEMENTATION
 #define CBUTTON_IMPLEMENTATION
   //+------------------------------------------------------------------+
   // | CButton::Default constructor. Builds a button in the main window |
   // | current chart in coordinates 0,0 with default sizes |
   //+------------------------------------------------------------------+
   CButton::CButton(void) : CLabel("Button","Button",::ChartID(),0,0,0,DEF_BUTTON_W,DEF_BUTTON_H)
   {
   // ---Initialization
      this.Init("");
   }
   //+---------------------------------------------------------------------+
   // | CButton::The constructor is parametric. Builds a button in the specified window|
   // | of the specified graphic with the specified text, coordinates and dimensions |
   //+---------------------------------------------------------------------+
   CButton::CButton(const string object_name,const string text,const long chart_id,const int wnd,const int x,const int y,const int w,const int h) :
      CLabel(object_name,text,chart_id,wnd,x,y,w,h)
   {
   // ---Initialization
      this.Init("");
   }
   //+------------------------------------------------------------------+
   // | CButton::Initialization |
   //+------------------------------------------------------------------+
   void CButton::Init(const string text)
   {
   // --- Set the default state
      this.SetState(ELEMENT_STATE_DEF);
   // ---Background and foreground - opaque
      this.SetAlpha(255);
   // --- Offset text from left edge of button by default
      this.m_text_x=2;
   // --- Auto-repeat is disabled
      this.m_autorepeat_flag=false;
   }
   //+------------------------------------------------------------------+
   // | CButton::Comparing two objects |
   //+------------------------------------------------------------------+
   int CButton::Compare(const CObject *node,const int mode=0) const
   {
      return CLabel::Compare(node,mode);
   }
   //+------------------------------------------------------------------+
   // | CButton::Draws appearance |
   //+------------------------------------------------------------------+
   void CButton::Draw(const bool chart_redraw)
   {
   // --- Fill the button with the background color, draw a frame and update the background canvas
      this.Fill(this.BackColor(),false);
      this.m_background.Rectangle(this.AdjX(0),this.AdjY(0),this.AdjX(this.Width()-1),this.AdjY(this.Height()-1),::ColorToARGB(this.BorderColor(),this.AlphaBG()));
      this.m_background.Update(false);
   // --- Display button text
      CLabel::Draw(false);
         
   // --- If indicated, update the schedule
      if(chart_redraw)
         ::ChartRedraw(this.m_chart_id);
   }
   //+------------------------------------------------------------------+
   // | Timer event handler |
   //+------------------------------------------------------------------+
   void CButton::TimerEventHandler(void)
   {
      if(this.m_autorepeat_flag)
         this.m_autorepeat.Process();
   }
 #endif // CBUTTON_IMPLEMENTATION
   //+------------------------------------------------------------------+
#endif // __BUTTON_MQH__

