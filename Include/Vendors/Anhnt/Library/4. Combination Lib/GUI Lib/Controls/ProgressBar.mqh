//+------------------------------------------------------------------+
//|                                                  ProgressBar.mqh |
//|                        Copyright 2015, MetaQuotes Software Corp. |
//| Introduction at https://www.mql5.com/en/articles/2580            |
//|Library base on Link https://www.mql5.com/en/code/19703           |
//+------------------------------------------------------------------+
#ifndef __PROGRESSBAR_MQH__
#define __PROGRESSBAR_MQH__
#include "..\Element.mqh"
//+------------------------------------------------------------------+
// | Class for creating a progress bar |
//+------------------------------------------------------------------+
class CProgressBar : public CElement
  {
   private:
    //Private properties:
     // --- Progress bar background and background frame colors
      color             m_bar_back_color;
     // --- Progress bar dimensions
      int               m_bar_x_size;
      int               m_bar_y_size;
     // --- Progress bar displacement along two axes
      int               m_bar_x_gap;
      int               m_bar_y_gap;
     // --- Thickness of the progress bar frame
      int               m_bar_border_width;
     // ---Indicator color
      color             m_indicator_color;
     // --- Percentage label offset
      int               m_percent_x_gap;
      int               m_percent_y_gap;
     // --- Number of decimal places
      int               m_digits;
     // ---Number of range steps
      double            m_steps_total;
     // --- Current indicator position
      double            m_current_index;
    //Private methods:   
      void              InitializeProperties(const string text,const int x_gap,const int y_gap);
      bool              CreateCanvas(void);
     // --- Draws an indicator
      void              DrawIndicator(void);
     // --- Draws a progress percentage display
      void              DrawPercent(void);
     // --- Setting new values ​​for the indicator
      void              CurrentIndex(const int index);
      void              StepsTotal(const int total);
     // --- Change the width along the right edge of the window
      virtual void      ChangeWidthByRightWindowSide(void);     
   public:
                        CProgressBar(void);
                     ~CProgressBar(void);
    // --- Methods for creating an element
      bool              CreateProgressBar(const string text,const int x_gap,const int y_gap);      
    // --- Color of (1) background and (2) frame of the progress bar, (3) color of the indicator
      void              IndicatorBackColor(const color clr) { m_bar_back_color=clr;     }
      void              IndicatorColor(const color clr)     { m_indicator_color=clr;    }
    // --- (1) Frame thickness, (2) Y-dimension of indicator area
      void              BarBorderWidth(const int width)     { m_bar_border_width=width; }
      void              BarYSize(const int y_size)          { m_bar_y_size=y_size;      }
    // --- (1) Shift of the progress bar along two axes, (2) Shift of the percentage indicator label
      void              BarXGap(const int x_gap)            { m_bar_x_gap=x_gap;        }
      void              BarYGap(const int y_gap)            { m_bar_y_gap=y_gap;        }
    // --- (1) Text label offset (process percentage), (2) number of decimal places
      void              PercentXGap(const int x_gap)        { m_percent_x_gap=x_gap;    }
      void              PercentYGap(const int y_gap)        { m_percent_y_gap=y_gap;    }
      void              SetDigits(const int digits)         { m_digits=::fabs(digits);  }
    // --- Updating the indicator using the specified values
      void              Update(const int index,const int total);
    // --- Draws an element
      virtual void      Draw(void);      
  };
 #ifndef CPROGRESSBAR_MQH_IMPLEMENTATION
 #define CPROGRESSBAR_MQH_IMPLEMENTATION
   //+------------------------------------------------------------------+
   //| Constructor                                                      |
   //+------------------------------------------------------------------+
   CProgressBar::CProgressBar(void) : m_digits(0),
                                      m_steps_total(1),
                                      m_current_index(0),
                                      m_bar_x_gap(0),
                                      m_bar_y_gap(0),
                                      m_bar_border_width(0),
                                      m_percent_x_gap(7),
                                      m_percent_y_gap(0),
                                      m_bar_back_color(C'225,225,225'),
                                      m_indicator_color(clrMediumSeaGreen)
     {
   // --- Save the element class name in the base class
      CElementBase::ClassName(CLASS_NAME);
     }
   //+------------------------------------------------------------------+
   //| Destructor                                                       |
   //+------------------------------------------------------------------+
   CProgressBar::~CProgressBar(void)
     {
     }
   //+------------------------------------------------------------------+
   // | Creates a "Progress Indicator" element |
   //+------------------------------------------------------------------+
   bool CProgressBar::CreateProgressBar(const string text,const int x_gap,const int y_gap)
     {
   // --- Quit if there is no pointer to the main element
      if(!CElement::CheckMainPointer())
         return(false);
   // ---Initializing properties
      InitializeProperties(text,x_gap,y_gap);
   // ---Creating an element
      if(!CreateCanvas())
         return(false);
   //---
      return(true);
     }
   //+------------------------------------------------------------------+
   // | Initializing properties |
   //+------------------------------------------------------------------+
   void CProgressBar::InitializeProperties(const string text,const int x_gap,const int y_gap)
     {
      m_x          =CElement::CalculateX(x_gap);
      m_y          =CElement::CalculateY(y_gap);
      m_label_text =text;
      m_x_size     =(m_x_size<1 || m_auto_xresize_mode)? m_main.X2()-m_x-m_auto_xresize_right_offset : m_x_size;
   // ---Default properties
      m_back_color  =(m_back_color!=clrNONE)? m_back_color : m_main.BackColor();
      m_label_color =(m_label_color!=clrNONE)? m_label_color : clrBlack;
      m_label_y_gap =(m_label_y_gap!=WRONG_VALUE)? m_label_y_gap : 0;
   // --- Indents from the extreme point
      CElementBase::XGap(x_gap);
      CElementBase::YGap(y_gap);
     }
   //+------------------------------------------------------------------+
   // | Creates an object to draw |
   //+------------------------------------------------------------------+
   bool CProgressBar::CreateCanvas(void)
     {
   // --- Formation of object name
      string name=CElementBase::ElementName("progress");
   // ---Create an object
      if(!CElement::CreateCanvas(name,m_x,m_y,m_x_size,m_y_size))
         return(false);
   //---
      return(true);
     }
   //+------------------------------------------------------------------+
   // | Updates progress bar |
   //+------------------------------------------------------------------+
   void CProgressBar::Update(const int index,const int total)
     {
   // --- Set new index
      CurrentIndex(index);
   // --- Set new range
      StepsTotal(total);
   // --- Redraw element
      CElement::Update(true);
     }
   //+------------------------------------------------------------------+
   // | Draws an element |
   //+------------------------------------------------------------------+
   void CProgressBar::Draw(void)
     {
   // --- Draw background
      CElement::DrawBackground();
   // --- Draw a picture
      CElement::DrawImage();
   // ---Draw indicator
      DrawIndicator();
   // --- Draw a frame if the color is specified
      if(m_border_color!=clrNONE)
        CElement::DrawBorder();
   // --- Draw text
      CElement::DrawText();
   // --- Draw progress in percentage terms
      DrawPercent();
     }
   //+------------------------------------------------------------------+
   // | Draws an indicator |
   //+------------------------------------------------------------------+
   void CProgressBar::DrawIndicator(void)
     {
      int x1 =m_bar_x_gap;
      int y1 =m_bar_y_gap;
      int x2 =m_x_size; // -40
      int y2 =m_bar_y_gap+m_bar_y_size;
   // --- Indicator background size
      m_bar_x_size=x2-m_bar_x_gap;
   // ---Draw indicator background
      m_canvas.FillRectangle(x1,y1,x2,y2,::ColorToARGB(m_bar_back_color));
   // --- Calculate the width of the indicator
      double new_width=(m_current_index/m_steps_total)*m_bar_x_size;
   // ---Adjust if less than 1
      if((int)new_width<1)
         new_width=1;
      else
        {
         // ---Adjust based on frame width
         int x_size=m_bar_x_size-(m_bar_border_width*2);
         // ---Adjust if going abroad
         if((int)new_width>=x_size)
            new_width=x_size;
        }
   // --- Set the indicator to a new width
      x1 =x1+m_bar_border_width;
      y1 =y1+m_bar_border_width;
      x2 =x1+(int)new_width;
      y2 =y2-m_bar_border_width;
   // ---Draw indicator
      m_canvas.FillRectangle(x1,y1,x2,y2,::ColorToARGB(m_indicator_color));
     }
   //+------------------------------------------------------------------+
   // | Draws progress percentage display |
   //+------------------------------------------------------------------+
   void CProgressBar::DrawPercent(void)
     {
      int x =m_x_size-m_percent_x_gap;
      int y =m_percent_y_gap;
   // --- Calculate the percentage and create a line
      double percent =m_current_index/m_steps_total*100;
      string text    =::DoubleToString((percent>100)? 100 : percent,m_digits)+"%";
   // --- Draw text
      m_canvas.TextOut(x,y,text,::ColorToARGB(m_label_color),TA_RIGHT);
     }
   //+------------------------------------------------------------------+
   // | Number of steps progress bar |
   //+------------------------------------------------------------------+
   void CProgressBar::StepsTotal(const int total)
     {
   // --- Adjust if less than 0
      m_steps_total=(total<1)? 1 : total;
   // --- Adjust index if out of range
      if(m_current_index>m_steps_total)
         m_current_index=m_steps_total;
     }
   //+------------------------------------------------------------------+
   // | Current indicator position |
   //+------------------------------------------------------------------+
   void CProgressBar::CurrentIndex(const int index)
     {
   // --- Adjust if less than 0
      if(index<0)
         m_current_index=1;
   // --- Adjust index if out of range
      else
         m_current_index=(index>m_steps_total)? m_steps_total : index;
     }
   //+------------------------------------------------------------------+
   // | Change the width along the right edge of the form |
   //+------------------------------------------------------------------+
   void CProgressBar::ChangeWidthByRightWindowSide(void)
     {
   // --- Dimensions
      int x_size=0;
   // --- Calculate and set a new size for the element's background
      x_size=m_main.X2()-m_canvas.X()-m_auto_xresize_right_offset;
      CElementBase::XSize(x_size);
      m_canvas.XSize(x_size);
      m_canvas.Resize(x_size,m_y_size);
   // --- Redraw element
      CElementBase::Update(true);
   // --- Update object position
      Moving();
     }
   //+------------------------------------------------------------------+
 #endif // CPROGRESSBAR_MQH_IMPLEMENTATION
#endif // __PROGRESSBAR_MQH__
