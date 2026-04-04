//+------------------------------------------------------------------+
//|                                                   CheckBox.mqh   |
//|                                  Copyright 2025, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//| MVC Paradigm in MQL5                                             |
//|                                                                  |
//|                           https://www.mql5.com/ru/articles/20596 |
//+------------------------------------------------------------------+
#property copyright "Copyright 2025, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
//+------------------------------------------------------------------+
// | Included Libraries |
//+------------------------------------------------------------------+
#include <Arrays\List.mqh>

#ifndef __CHECKBOX_MQH__
#define __CHECKBOX_MQH__
       //+------------------------------------------------------------------+
   // | Checkbox Control Class |
   //+------------------------------------------------------------------+
   class CCheckBox : public CButtonTriggered
   {
      public:
      // ---Draws the appearance
         virtual void      Draw(const bool chart_redraw);

      // --- Virtual methods (1) compare, (2) save to file, (3) load from file, (4) object type
         virtual int       Compare(const CObject *node,const int mode=0) const;
         virtual bool      Save(const int file_handle)               { return CButton::Save(file_handle);   }
         virtual bool      Load(const int file_handle)               { return CButton::Load(file_handle);   }
         virtual int       Type(void)                          const { return(ELEMENT_TYPE_CHECKBOX);       }
      
      // --- Initialize (1) class object, (2) default object colors
         void              Init(const string text);
         virtual void      InitColors(void);
         
      // --- Constructors/destructor
                           CCheckBox(void);
                           CCheckBox(const string object_name, const string text, const long chart_id, const int wnd, const int x, const int y, const int w, const int h);
                           ~CCheckBox (void) {}
   };
   //+------------------------------------------------------------------+
   #ifndef CCHECKBOX_IMPLEMENTATION
   #define CCHECKBOX_IMPLEMENTATION
      //+------------------------------------------------------------------+
      // | CCheckBox::Default constructor.                             |
      // | Plots an element in the main window of the current chart |
      // | at coordinates 0,0 with default dimensions |
      //+------------------------------------------------------------------+
      CCheckBox::CCheckBox(void) : CButtonTriggered("CheckBox","CheckBox",::ChartID(),0,0,0,DEF_BUTTON_W,DEF_BUTTON_H)
      {
         // ---Initialization
            this.Init("");
      }
      //+------------------------------------------------------------------+
      // | CCheckBox::Parametric constructor.                          |
      // | Plots an element in the specified window of the specified chart |
      // | with specified text, coordinates and dimensions |
      //+------------------------------------------------------------------+
      CCheckBox::CCheckBox(const string object_name,const string text,const long chart_id,const int wnd,const int x,const int y,const int w,const int h) :
         CButtonTriggered(object_name,text,chart_id,wnd,x,y,w,h)
      {
         // ---Initialization
            this.Init("");
      }
      //+------------------------------------------------------------------+
      // | CCheckBox::Initialization |
      //+------------------------------------------------------------------+
      void CCheckBox::Init(const string text)
      {
         // --- Set default colors, transparency for background and foreground,
         // --- and coordinates and boundaries of the button icon drawing area
            this.InitColors();
            this.SetAlphaBG(0);
            this.SetAlphaFG(255);
            this.SetImageBound(1,1,this.Height()-2,this.Height()-2);
      }
      //+------------------------------------------------------------------+
      // | CCheckBox::Initializing default object colors |
      //+------------------------------------------------------------------+
      void CCheckBox::InitColors(void)
      {
      // --- Initialize the background colors for normal and activated states and make it the current background color
         this.InitBackColors(clrNULL);
         this.InitBackColorsAct(clrNULL);
         this.BackColorToDefault();
         
      // --- Initialize the foreground colors for normal and activated states and make it the current text color
         this.InitForeColors(clrBlack);
         this.InitForeColorsAct(clrBlack);
         this.InitForeColorFocused(clrNavy);
         this.InitForeColorActFocused(clrNavy);
         this.ForeColorToDefault();
         
      // --- Initialize the border colors for the normal and activated states and make it the current border color
         this.InitBorderColors(clrNULL);
         this.InitBorderColorsAct(clrNULL);
         this.BorderColorToDefault();

      // --- Initialize the border color and foreground color for the locked element
         this.InitBorderColorBlocked(clrNULL);
         this.InitForeColorBlocked(clrSilver);
      }
      //+------------------------------------------------------------------+
      // | CCheckBox::Comparing two objects |
      //+------------------------------------------------------------------+
      int CCheckBox::Compare(const CObject *node,const int mode=0) const
      {
         return CButtonTriggered::Compare(node,mode);
      }
      //+------------------------------------------------------------------+
      // | CCheckBox::Draws appearance |
      //+------------------------------------------------------------------+
      void CCheckBox::Draw(const bool chart_redraw)
      {
         // --- Fill the button with the background color, draw a frame and update the background canvas
            this.Fill(this.BackColor(),false);
            this.m_background.Rectangle(this.AdjX(0),this.AdjY(0),this.AdjX(this.Width()-1),this.AdjY(this.Height()-1),::ColorToARGB(this.BorderColor(),this.AlphaBG()));
            this.m_background.Update(false);
         // --- Display button text
            CLabel::Draw(false);
            
         // --- Clear the drawing area
            this.m_painter.Clear(this.AdjX(this.m_painter.X()),this.AdjY(this.m_painter.Y()),this.m_painter.Width(),this.m_painter.Height(),false);
         // --- Draw a marked icon for the active state of the button,
            if(this.m_state)
               this.m_painter.CheckedBox(this.AdjX(this.m_painter.X()),this.AdjY(this.m_painter.Y()),this.m_painter.Width(),this.m_painter.Height(),this.ForeColor(),this.AlphaFG(),true);
         // --- and unchecked - for inactive
            else
               this.m_painter.UncheckedBox(this.AdjX(this.m_painter.X()),this.AdjY(this.m_painter.Y()),this.m_painter.Width(),this.m_painter.Height(),this.ForeColor(),this.AlphaFG(),true);
               
         // --- If indicated, update the schedule
            if(chart_redraw)
               ::ChartRedraw(this.m_chart_id);
      }
      //+------------------------------------------------------------------+
   #endif // CCHECKBOX_IMPLEMENTATION
#endif // __CHECKBOX_MQH__