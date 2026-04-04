//+------------------------------------------------------------------+
//|                                                 VisualHint.mqh   |
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

#ifndef __VISUALHINT_MQH__
#define __VISUALHINT_MQH__
       //+------------------------------------------------------------------+
   //| Tooltip class |
   //+------------------------------------------------------------------+
   class CVisualHint : public CButton
   {
      protected:
         ENUM_HINT_TYPE    m_hint_type;                              // Tooltip type

      // --- Draws (1) tooltip, (2) horizontal, (3) vertical arrow,
      // --- arrows (4) top-left --- bottom-right, (5) bottom-left --- top-right,
      // --- displacement arrows along (6) horizontal, (7) vertical
         void              DrawTooltip(void);
         void              DrawArrHorz(void);
         void              DrawArrVert(void);
         void              DrawArrNWSE(void);
         void              DrawArrNESW(void);
         void              DrawArrShiftHorz(void);
         void              DrawArrShiftVert(void);
         
      // --- Initialize colors for tooltip type (1) Tooltip, (2) arrows
         void              InitColorsTooltip(void);
         void              InitColorsArrowed(void);
         
      public:
      // --- (1) Sets, (2) returns the tooltip type
         void              SetHintType(const ENUM_HINT_TYPE type);
         ENUM_HINT_TYPE    HintType(void)                      const { return this.m_hint_type;             }

      // ---Draws the appearance
         virtual void      Draw(const bool chart_redraw);

      // --- Virtual methods (1) compare, (2) save to file, (3) load from file, (4) object type
         virtual int       Compare(const CObject *node,const int mode=0) const;
         virtual bool      Save(const int file_handle)               { return CButton::Save(file_handle);   }
         virtual bool      Load(const int file_handle)               { return CButton::Load(file_handle);   }
         virtual int       Type(void)                          const { return(ELEMENT_TYPE_HINT);           }
         
      // --- Initialize (1) class object, (2) default object colors
         void              Init(const string text);
         virtual void      InitColors(void);
         
      // --- Constructors/destructor
                           CVisualHint(void);
                           CVisualHint(const string object_name, const long chart_id, const int wnd, const int x, const int y, const int w, const int h);
                        ~CVisualHint (void) {}
   };
   #ifndef CVISUALHINT_IMPLEMENTATION
   #define CVISUALHINT_IMPLEMENTATION
      //+------------------------------------------------------------------+
      // | CVisualHint::Default constructor.                     |
      // | Plots an element in the main window of the current chart |
      // | at coordinates 0,0 with default dimensions |
      //+------------------------------------------------------------------+
      CVisualHint::CVisualHint(void) : CButton("HintObject","",::ChartID(),0,0,0,DEF_BUTTON_W,DEF_BUTTON_H)
         {
         // ---Initialization
            this.Init("");
         }
      //+------------------------------------------------------------------+
      // | CVisualHint::The constructor is parametric.                        |
      // | Plots an element in the specified window of the specified chart |
      // | with specified text, coordinates and dimensions |
      //+------------------------------------------------------------------+
      CVisualHint::CVisualHint(const string object_name,const long chart_id,const int wnd,const int x,const int y,const int w,const int h) :
         CButton(object_name,"",chart_id,wnd,x,y,w,h)
         {
         // ---Initialization
            this.Init("");
         }
      //+------------------------------------------------------------------+
      // | CVisualHint::Initialization |
      //+------------------------------------------------------------------+
      void CVisualHint::Init(const string text)
         {
         // --- Initialize default colors
            this.InitColors();
         // --- Set the offset and dimensions of the image area
            this.SetImageBound(0,0,this.Width(),this.Height());

         // --- Object is not clipped to container boundaries
            this.m_trim_flag=false;
            
         // --- Initialize auto-repeat counters
            this.m_autorepeat_flag=true;

         // --- Initialize the properties of the event auto-repeat control object
            this.m_autorepeat.SetChartID(this.m_chart_id);
            this.m_autorepeat.SetID(0);
            this.m_autorepeat.SetName("VisualHintAutorepeatControl");
            this.m_autorepeat.SetDelay(DEF_AUTOREPEAT_DELAY);
            this.m_autorepeat.SetInterval(DEF_AUTOREPEAT_INTERVAL);
            this.m_autorepeat.SetEvent(CHARTEVENT_OBJECT_CLICK,0,0,this.NameFG());
         }
      //+------------------------------------------------------------------+
      // | CVisualHint::Initializing colors for the Tooltip hint type |
      //+------------------------------------------------------------------+
      void CVisualHint::InitColorsTooltip(void)
         {
         // ---Background and foreground opaque
            this.SetAlpha(255);
            
         // --- Initialize the background colors for normal and activated states and make it the current background color
            this.InitBackColors(clrWhiteSmoke,clrWhiteSmoke,clrWhiteSmoke,clrWhiteSmoke);
            this.InitBackColorsAct(clrWhiteSmoke,clrWhiteSmoke,clrWhiteSmoke,clrWhiteSmoke);
            this.BackColorToDefault();
            
         // --- Initialize the foreground colors for normal and activated states and make it the current text color
            this.InitForeColors(clrBlack,clrBlack,clrBlack,clrSilver);
            this.InitForeColorsAct(clrBlack,clrBlack,clrBlack,clrSilver);
            this.ForeColorToDefault();
            
         // --- Initialize the border colors for the normal and activated states and make it the current border color
            this.InitBorderColors(clrLightGray,clrLightGray,clrLightGray,clrLightGray);
            this.InitBorderColorsAct(clrLightGray,clrLightGray,clrLightGray,clrLightGray);
            this.BorderColorToDefault();
            
         // --- Initialize the border color and foreground color for the locked element
            this.InitBorderColorBlocked(clrNULL);
            this.InitForeColorBlocked(clrNULL);
         }
      //+------------------------------------------------------------------+
      // | CVisualHint::Initializing colors for the Arrowed hint type |
      //+------------------------------------------------------------------+
      void CVisualHint::InitColorsArrowed(void)
         {
         // --- Background is transparent, foreground is opaque
            this.SetAlphaBG(0);
            this.SetAlphaFG(255);
            
         // --- Initialize the background colors for normal and activated states and make it the current background color
            this.InitBackColors(clrNULL,clrNULL,clrNULL,clrNULL);
            this.InitBackColorsAct(clrNULL,clrNULL,clrNULL,clrNULL);
            this.BackColorToDefault();
            
         // --- Initialize the foreground colors for normal and activated states and make it the current text color
            this.InitForeColors(clrBlack,clrBlack,clrBlack,clrSilver);
            this.InitForeColorsAct(clrBlack,clrBlack,clrBlack,clrSilver);
            this.ForeColorToDefault();
            
         // --- Initialize the border colors for the normal and activated states and make it the current border color
            this.InitBorderColors(clrNULL,clrNULL,clrNULL,clrNULL);
            this.InitBorderColorsAct(clrNULL,clrNULL,clrNULL,clrNULL);
            this.BorderColorToDefault();
            
         // --- Initialize the border color and foreground color for the blocked element
            this.InitBorderColorBlocked(clrNULL);
            this.InitForeColorBlocked(clrNULL);
         }
      //+------------------------------------------------------------------+
      // | CVisualHint::Initializing default object colors |
      //+------------------------------------------------------------------+
      void CVisualHint::InitColors(void)
         {
            if(this.m_hint_type==HINT_TYPE_TOOLTIP)
               this.InitColorsTooltip();
            else
               this.InitColorsArrowed();
         }
      //+------------------------------------------------------------------+
      // | CVisualHint::Comparing two objects |
      //+------------------------------------------------------------------+
      int CVisualHint::Compare(const CObject *node,const int mode=0) const
         {
            return CButton::Compare(node,mode);
         }
      //+------------------------------------------------------------------+
      // | CVisualHint::Sets the hint type |
      //+------------------------------------------------------------------+
      void CVisualHint::SetHintType(const ENUM_HINT_TYPE type)
         {
         // --- If the passed type matches the set one, we leave
            if(this.m_hint_type==type)
               return;
         // --- Installing a new tooltip type
            this.m_hint_type=type;
         // --- Depending on the type of tooltip, set the size of the object
            switch(this.m_hint_type)
            {
               case HINT_TYPE_ARROW_HORZ        :  this.Resize(17,7);   break;
               case HINT_TYPE_ARROW_VERT        :  this.Resize(7,17);   break;
               case HINT_TYPE_ARROW_NESW        :
               case HINT_TYPE_ARROW_NWSE        :  this.Resize(13,13);  break;
               case HINT_TYPE_ARROW_SHIFT_HORZ  :
               case HINT_TYPE_ARROW_SHIFT_VERT  :  this.Resize(18,18);  break;
               default                          :  break;
            }
         // --- Set the offset and dimensions of the image area,
         // --- initialize the colors based on the tooltip type
            this.SetImageBound(0,0,this.Width(),this.Height());
            this.InitColors();
         }
      //+------------------------------------------------------------------+
      // | CVisualHint::Draws the appearance |
      //+------------------------------------------------------------------+
      void CVisualHint::Draw(const bool chart_redraw)
         {
         // --- Depending on the type of tooltip, call the corresponding drawing method
            switch(this.m_hint_type)
            {
               case HINT_TYPE_ARROW_HORZ        :  this.DrawArrHorz();        break;
               case HINT_TYPE_ARROW_VERT        :  this.DrawArrVert();        break;
               case HINT_TYPE_ARROW_NESW        :  this.DrawArrNESW();        break;
               case HINT_TYPE_ARROW_NWSE        :  this.DrawArrNWSE();        break;
               case HINT_TYPE_ARROW_SHIFT_HORZ  :  this.DrawArrShiftHorz();   break;
               case HINT_TYPE_ARROW_SHIFT_VERT  :  this.DrawArrShiftVert();   break;
               default                          :  this.DrawTooltip();        break;
            }

         // --- If indicated, update the schedule
            if(chart_redraw)
               ::ChartRedraw(this.m_chart_id);
         }
      //+------------------------------------------------------------------+
      // | CVisualHint::Draws a tooltip |
      //+------------------------------------------------------------------+
      void CVisualHint::DrawTooltip(void)
         {
         // --- Fill the object with the background color, draw a frame and update the background canvas
            this.Fill(this.BackColor(),false);
            this.m_background.Rectangle(this.AdjX(0),this.AdjY(0),this.AdjX(this.Width()-1),this.AdjY(this.Height()-1),::ColorToARGB(this.BorderColor(),this.AlphaBG()));
            this.m_background.Update(false);
         }
      //+------------------------------------------------------------------+
      // | CVisualHint::Draws a horizontal arrow |
      //+------------------------------------------------------------------+
      void CVisualHint::DrawArrHorz(void)
         {
         // --- Clear the drawing area
            this.m_painter.Clear(this.AdjX(this.m_painter.X()),this.AdjY(this.m_painter.Y()),this.m_painter.Width(),this.m_painter.Height(),false);
         // --- Draw a double horizontal arrow
            this.m_painter.ArrowHorz(this.AdjX(this.m_painter.X()),this.AdjY(this.m_painter.Y()),this.m_painter.Width(),this.m_painter.Height(),this.ForeColor(),this.AlphaFG(),true);
         }
      //+------------------------------------------------------------------+
      // | CVisualHint::Draws a vertical arrow |
      //+------------------------------------------------------------------+
      void CVisualHint::DrawArrVert(void)
         {
         // --- Clear the drawing area
            this.m_painter.Clear(this.AdjX(this.m_painter.X()),this.AdjY(this.m_painter.Y()),this.m_painter.Width(),this.m_painter.Height(),false);
         // --- Draw a double vertical arrow
            this.m_painter.ArrowVert(this.AdjX(this.m_painter.X()),this.AdjY(this.m_painter.Y()),this.m_painter.Width(),this.m_painter.Height(),this.ForeColor(),this.AlphaFG(),true);
         }
      //+------------------------------------------------------------------+
      // | CVisualHint::Draws arrows top-left --- bottom-right |
      //+------------------------------------------------------------------+
      void CVisualHint::DrawArrNWSE(void)
         {
         // --- Clear the drawing area
            this.m_painter.Clear(this.AdjX(this.m_painter.X()),this.AdjY(this.m_painter.Y()),this.m_painter.Width(),this.m_painter.Height(),false);
         // --- Draw a double diagonal arrow from top to left --- down to right
            this.m_painter.ArrowNWSE(this.AdjX(this.m_painter.X()),this.AdjY(this.m_painter.Y()),this.m_painter.Width(),this.m_painter.Height(),this.ForeColor(),this.AlphaFG(),true);
         }
      //+------------------------------------------------------------------+
      // | CVisualHint::Draws arrows bottom-left --- top-right |
      //+------------------------------------------------------------------+
      void CVisualHint::DrawArrNESW(void)
         {
         // --- Clear the drawing area
            this.m_painter.Clear(this.AdjX(this.m_painter.X()),this.AdjY(this.m_painter.Y()),this.m_painter.Width(),this.m_painter.Height(),false);
         // --- Draw a double diagonal arrow from bottom to left --- top to right
            this.m_painter.ArrowNESW(this.AdjX(this.m_painter.X()),this.AdjY(this.m_painter.Y()),this.m_painter.Width(),this.m_painter.Height(),this.ForeColor(),this.AlphaFG(),true);
         }
      //+------------------------------------------------------------------+
      // | CVisualHint::Draws horizontal offset arrows |
      //+------------------------------------------------------------------+
      void CVisualHint::DrawArrShiftHorz(void)
         {
         // --- Clear the drawing area
            this.m_painter.Clear(this.AdjX(this.m_painter.X()),this.AdjY(this.m_painter.Y()),this.m_painter.Width(),this.m_painter.Height(),false);
         // --- Draw horizontal displacement arrows
            this.m_painter.ArrowShiftHorz(this.AdjX(this.m_painter.X()),this.AdjY(this.m_painter.Y()),this.m_painter.Width(),this.m_painter.Height(),this.ForeColor(),this.AlphaFG(),true);
         }
      //+------------------------------------------------------------------+
      // | CVisualHint::Draws vertical offset arrows |
      //+------------------------------------------------------------------+
      void CVisualHint::DrawArrShiftVert(void)
         {
         // --- Clear the drawing area
            this.m_painter.Clear(this.AdjX(this.m_painter.X()),this.AdjY(this.m_painter.Y()),this.m_painter.Width(),this.m_painter.Height(),false);
         // --- Draw horizontal displacement arrows
            this.m_painter.ArrowShiftVert(this.AdjX(this.m_painter.X()),this.AdjY(this.m_painter.Y()),this.m_painter.Width(),this.m_painter.Height(),this.ForeColor(),this.AlphaFG(),true);
         }
      //+------------------------------------------------------------------+
   #endif // CVISUALHINT_IMPLEMENTATION
#endif // __VISUALHINT_MQH__


