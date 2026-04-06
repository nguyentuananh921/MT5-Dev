//+------------------------------------------------------------------+
//|                                                RadioButton.mqh   |
//|                                  Copyright 2025, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//| MVC Paradigm in MQL5                                             |
//| First See in             https://www.mql5.com/en/articles/18221  |
//| Current                   https://www.mql5.com/ru/articles/20596 |
//+------------------------------------------------------------------+
#property copyright "Copyright 2025, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
//+------------------------------------------------------------------+
//| Radio Button Control Class |
//+------------------------------------------------------------------+
#ifndef __RADIOBUTTON_MQH__
#define __RADIOBUTTON_MQH__
   //+------------------------------------------------------------------+
   //| Included Standard Libraries                                      |
   //+------------------------------------------------------------------+
   //#include <Arrays\List.mqh>
   //+------------------------------------------------------------------+
   //| Included Custome Libraries                                       |
   //+------------------------------------------------------------------+
   #include "CheckBox.mqh"
 class CRadioButton : public CCheckBox
  {
   public:
   // ---Draws the appearance
      virtual void      Draw(const bool chart_redraw);

   // --- Virtual methods (1) compare, (2) save to file, (3) load from file, (4) object type
      virtual int       Compare(const CObject *node,const int mode=0) const;
      virtual bool      Save(const int file_handle)               { return CButton::Save(file_handle);   }
      virtual bool      Load(const int file_handle)               { return CButton::Load(file_handle);   }
      virtual int       Type(void)                          const { return(ELEMENT_TYPE_RADIOBUTTON);    }

   // --- Initialize (1) class object, (2) default object colors
      void              Init(const string text);
      virtual void      InitColors(void){}
      
   // --- Event handler for mouse button clicks (Press)
      virtual void      OnPressEvent(const int id, const long lparam, const double dparam, const string sparam);

   // --- Constructors/destructor
                        CRadioButton(void);
                        CRadioButton(const string object_name, const string text, const long chart_id, const int wnd, const int x, const int y, const int w, const int h);
                        ~CRadioButton (void) {}
  };
   //+------------------------------------------------------------------+
 #ifndef CRADIOBUTTON_IMPLEMENTATION
 #define CRADIOBUTTON_IMPLEMENTATION
   //+------------------------------------------------------------------+
   // | CRadioButton::Default constructor.                          |
   // | Plots an element in the main window of the current chart |
   // | at coordinates 0,0 with default dimensions |
   //+------------------------------------------------------------------+
   CRadioButton::CRadioButton(void) : CCheckBox("RadioButton","",::ChartID(),0,0,0,DEF_BUTTON_H,DEF_BUTTON_H)
    {
      // ---Initialization
         this.Init("");
    }
   //+------------------------------------------------------------------+
   // | CRadioButton::Parametric constructor.                       |
   // | Plots an element in the specified window of the specified chart |
   // | with specified text, coordinates and dimensions |
   //+------------------------------------------------------------------+
   CRadioButton::CRadioButton(const string object_name,const string text,const long chart_id,const int wnd,const int x,const int y,const int w,const int h) :
      CCheckBox(object_name,text,chart_id,wnd,x,y,w,h)
    {
      // ---Initialization
         this.Init("");
    }
   //+------------------------------------------------------------------+
   // | CRadioButton::Initialization |
   //+------------------------------------------------------------------+
   void CRadioButton::Init(const string text)
    {
         return;
    }
   //+------------------------------------------------------------------+
   // | CRadioButton::Comparing two objects |
   //+------------------------------------------------------------------+
   int CRadioButton::Compare(const CObject *node,const int mode=0) const
    {
         return CCheckBox::Compare(node,mode);
    }
   //+------------------------------------------------------------------+
   // | CRadioButton::Draws appearance |
   //+------------------------------------------------------------------+
   void CRadioButton::Draw(const bool chart_redraw)
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
            this.m_painter.CheckedRadioButton(this.AdjX(this.m_painter.X()),this.AdjY(this.m_painter.Y()),this.m_painter.Width(),this.m_painter.Height(),this.ForeColor(),this.AlphaFG(),true);
      // --- and unchecked - for inactive
         else
            this.m_painter.UncheckedRadioButton(this.AdjX(this.m_painter.X()),this.AdjY(this.m_painter.Y()),this.m_painter.Width(),this.m_painter.Height(),this.ForeColor(),this.AlphaFG(),true);
            
      // --- If indicated, update the schedule
         if(chart_redraw)
            ::ChartRedraw(this.m_chart_id);
    }
   //+------------------------------------------------------------------+
   // | CRadioButton::Event handler for mouse button clicks (Press) |
   //+------------------------------------------------------------------+
   void CRadioButton::OnPressEvent(const int id,const long lparam,const double dparam,const string sparam)
    {
      // --- If the button is already marked, we leave
         if(this.m_state)
         
            return;
      // --- Set the button state opposite to the one already set
         ENUM_ELEMENT_STATE state=(this.State()==ELEMENT_STATE_DEF ? ELEMENT_STATE_ACT : ELEMENT_STATE_DEF);
         this.SetState(state);         
      // --- Call the handler of the parent object indicating the identifier in lparam and the state in dparam
         CCanvasBase::OnPressEvent(id,this.m_id,this.m_state,sparam);
    }
   //+------------------------------------------------------------------+
  #endif // CRADIOBUTTON_IMPLEMENTATION
#endif // __RADIOBUTTON_MQH__


