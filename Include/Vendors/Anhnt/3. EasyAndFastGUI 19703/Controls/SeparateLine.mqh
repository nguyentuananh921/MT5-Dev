//+------------------------------------------------------------------+
//|                                                 SeparateLine.mqh |
//|                        Copyright 2015, MetaQuotes Software Corp. |
//|                                              http://www.mql5.com |
//+------------------------------------------------------------------+
#ifndef __SEPARATELINE_MQH__
#define __SEPARATELINE_MQH__
#include "..\Element.mqh"
//+------------------------------------------------------------------+
// | Class for creating a dividing line |
//+------------------------------------------------------------------+
class CSeparateLine : public CElement
  {
private:
   // --- Properties
   ENUM_TYPE_SEP_LINE m_type_sep_line;   
   color             m_dark_color;
   color             m_light_color;
   //---
public:
                     CSeparateLine(void);
                    ~CSeparateLine(void);
   // ---Creating a dividing line
   bool              CreateSeparateLine(const int x_gap,const int y_gap,const int x_size,const int y_size);
   //---
private:
   // --- Creates a canvas for drawing a dividing line
   bool              CreateSepLine(void);
   //---
public:
   // --- (1) Line type, (2) line colors
   void              TypeSepLine(const ENUM_TYPE_SEP_LINE type) { m_type_sep_line=type; }
   void              DarkColor(const color clr)                 { m_dark_color=clr;     }
   void              LightColor(const color clr)                { m_light_color=clr;    }
   //---
public:
   // --- Draws an element
   virtual void      Draw(void);
  };
 #ifndef CSEPARATELINE_MQH_IMPLEMENTATION
 #define CSEPARATELINE_MQH_IMPLEMENTATION
   //+------------------------------------------------------------------+
   //| Constructor                                                      |
   //+------------------------------------------------------------------+
   CSeparateLine::CSeparateLine(void) : m_type_sep_line(H_SEP_LINE),
                                        m_dark_color(C'160,160,160'),
                                        m_light_color(clrWhite)
     {
   // --- Save the element class name in the base class
      CElementBase::ClassName(CLASS_NAME);
     }
   //+------------------------------------------------------------------+
   //| Destructor                                                       |
   //+------------------------------------------------------------------+
   CSeparateLine::~CSeparateLine(void)
     {
     }
   //+------------------------------------------------------------------+
   // | Creates a dividing line |
   //+------------------------------------------------------------------+
   bool CSeparateLine::CreateSeparateLine(const int x_gap,const int y_gap,const int x_size,const int y_size)
     {
   // --- Quit if there is no pointer to the main element
      if(!CElement::CheckMainPointer())
         return(false);
   // --- Initializing properties
      m_x      =CElement::CalculateX(x_gap);
      m_y      =CElement::CalculateY(y_gap);
      m_x_size =x_size;
      m_y_size =y_size;
   // --- Indents from the extreme point
      CElementBase::XGap(x_gap);
      CElementBase::YGap(y_gap);
   // ---Creating an element
      if(!CreateSepLine())
         return(false);
   //---
      return(true);
     }
   //+------------------------------------------------------------------+
   // | Creates a canvas for drawing a dividing line |
   //+------------------------------------------------------------------+
   bool CSeparateLine::CreateSepLine(void)
     {
   // --- Formation of object name
      string name=CElementBase::ElementName("separate_line");
   // ---Create an object
      if(!CElement::CreateCanvas(name,m_x,m_y,m_x_size,m_y_size))
        return(false);
   //---
      return(true);
     }
   //+------------------------------------------------------------------+
   // | Draws an element |
   //+------------------------------------------------------------------+
   void CSeparateLine::Draw(void)
     {
   // --- Coordinates for lines
      int x1=0,x2=0,y1=0,y2=0;
   // ---Canvas sizes
      int x_size =(int)::ObjectGetInteger(m_chart_id,m_canvas.ChartObjectName(),OBJPROP_XSIZE)-1;
      int y_size =(int)::ObjectGetInteger(m_chart_id,m_canvas.ChartObjectName(),OBJPROP_YSIZE)-1;
   // --- Clear canvas
      m_canvas.Erase(::ColorToARGB(clrNONE,0));
   // --- If the line is horizontal
      if(m_type_sep_line==H_SEP_LINE)
        {
         // --- Dark line on top
         x1=0; y1=0; x2=x_size; y2=0;
         m_canvas.Line(x1,y1,x2,y2,::ColorToARGB(m_dark_color));
         // --- Light line below
         x1=0; x2=x_size; y1=y_size; y2=y_size;
         m_canvas.Line(x1,y1,x2,y2,::ColorToARGB(m_light_color));
        }
   // --- If the line is vertical
      else
        {
         // --- Dark line on the left
         x1=0; x2=0; y1=0; y2=y_size;
         m_canvas.Line(x1,y1,x2,y2,::ColorToARGB(m_dark_color));
         // --- Light line on the right
         x1=x_size; y1=0; x2=x_size; y2=y_size;
         m_canvas.Line(x1,y1,x2,y2,::ColorToARGB(m_light_color));
        }
     }
   //+------------------------------------------------------------------+
 #endif // CSEPARATELINE_MQH_IMPLEMENTATION
#endif // __SEPARATELINE_MQH__
