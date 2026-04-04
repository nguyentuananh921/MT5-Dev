//+------------------------------------------------------------------+
//|                                            ButtonTriggered.mqh   |
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

#ifndef __BUTTONTRIGGERED_MQH__
#define __BUTTONTRIGGERED_MQH__
       //+------------------------------------------------------------------+
   // | Two-way button class |
   //+------------------------------------------------------------------+
   class CButtonTriggered : public CButton
      {
         public:
         // ---Draws the appearance
            virtual void      Draw(const bool chart_redraw);

         // --- Virtual methods (1) compare, (2) save to file, (3) load from file, (4) object type
            virtual int       Compare(const CObject *node,const int mode=0) const;
            virtual bool      Save(const int file_handle)               { return CButton::Save(file_handle);      }
            virtual bool      Load(const int file_handle)               { return CButton::Load(file_handle);      }
            virtual int       Type(void)                          const { return(ELEMENT_TYPE_BUTTON_TRIGGERED);  }
         
         // --- Event handler for mouse button clicks (Press)
            virtual void      OnPressEvent(const int id, const long lparam, const double dparam, const string sparam);

         // --- Initialize (1) class object, (2) default object colors
            void              Init(const string text);
            virtual void      InitColors(void);
            
         // --- Constructors/destructor
                              CButtonTriggered(void);
                              CButtonTriggered(const string object_name, const string text, const long chart_id, const int wnd, const int x, const int y, const int w, const int h);
                              ~CButtonTriggered (void) {}
      };
   #ifndef CBUTTONTRIGGERED_IMPLEMENTATION
   #define CBUTTONTRIGGERED_IMPLEMENTATION
      //+------------------------------------------------------------------+
      // | CButtonTriggered::Default constructor.                      |
      // | Builds a button in the main window of the current chart |
      // | at coordinates 0,0 with default dimensions |
      //+------------------------------------------------------------------+
      CButtonTriggered::CButtonTriggered(void) : CButton("Button","Button",::ChartID(),0,0,0,DEF_BUTTON_W,DEF_BUTTON_H)
      {
      // ---Initialization
         this.Init("");
      }
      //+------------------------------------------------------------------+
      // | CButtonTriggered::Parametric constructor.                   |
      // | Builds a button in the specified window of the specified chart |
      // | with specified text, coordinates and dimensions |
      //+------------------------------------------------------------------+
      CButtonTriggered::CButtonTriggered(const string object_name,const string text,const long chart_id,const int wnd,const int x,const int y,const int w,const int h) :
         CButton(object_name,text,chart_id,wnd,x,y,w,h)
      {
      // ---Initialization
         this.Init("");
      }
      //+------------------------------------------------------------------+
      // | CButtonTriggered::Initializing |
      //+------------------------------------------------------------------+
      void CButtonTriggered::Init(const string text)
      {
      // --- Initialize default colors
         this.InitColors();
      }
      //+------------------------------------------------------------------+
      // | CButtonTriggered::Initializing default object colors |
      //+------------------------------------------------------------------+
      void CButtonTriggered::InitColors(void)
      {
      // --- Initialize the background colors for normal and activated states and make it the current background color
         this.InitBackColors(clrWhiteSmoke);
         this.InitBackColorsAct(clrLightBlue);
         this.BackColorToDefault();
         
      // --- Initialize the foreground colors for normal and activated states and make it the current text color
         this.InitForeColors(clrBlack);
         this.InitForeColorsAct(clrBlack);
         this.ForeColorToDefault();
         
      // --- Initialize the border colors for the normal and activated states and make it the current border color
         this.InitBorderColors(clrDarkGray);
         this.InitBorderColorsAct(clrGreen);
         this.BorderColorToDefault();
         
      // --- Initialize the border color and foreground color for the blocked element
         this.InitBorderColorBlocked(clrLightGray);
         this.InitForeColorBlocked(clrSilver);
      }
      //+------------------------------------------------------------------+
      // | CButtonTriggered::Comparing two objects |
      //+------------------------------------------------------------------+
      int CButtonTriggered::Compare(const CObject *node,const int mode=0) const
      {
         return CButton::Compare(node,mode);
      }
      //+------------------------------------------------------------------+
      // | CButtonTriggered::Draws appearance |
      //+------------------------------------------------------------------+
      void CButtonTriggered::Draw(const bool chart_redraw)
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
      // | CButtonTriggered::Event handler for mouse button clicks (Press)|
      //+------------------------------------------------------------------+
      void CButtonTriggered::OnPressEvent(const int id,const long lparam,const double dparam,const string sparam)
      {
         // --- Set the button state opposite to the one already set
            ENUM_ELEMENT_STATE state=(this.State()==ELEMENT_STATE_DEF ? ELEMENT_STATE_ACT : ELEMENT_STATE_DEF);
            this.SetState(state);
            
         // --- Call the handler of the parent object indicating the identifier in lparam and the state in dparam
            CCanvasBase::OnPressEvent(id,this.m_id,this.m_state,sparam);
      }
      //+------------------------------------------------------------------+
   #endif // CBUTTONTRIGGERED_IMPLEMENTATION
   //+------------------------------------------------------------------+
#endif // __BUTTONTRIGGERED_MQH__


