//+------------------------------------------------------------------+
//|                                                      Picture.mqh |
//|                        Copyright 2016, MetaQuotes Software Corp. |
//|                                              http://www.mql5.com |
//+------------------------------------------------------------------+
#ifndef __PICTURE_MQH__
#define __PICTURE_MQH__
#include "..\Element.mqh"
//+------------------------------------------------------------------+
// | Class for creating a picture |
//+------------------------------------------------------------------+
class CPicture : public CElement
  {
public:
                     CPicture(void);
                    ~CPicture(void);
   // --- Methods for creating a picture
   bool              CreatePicture(const int x_gap,const int y_gap);
   //---
private:
   void              InitializeProperties(const int x_gap,const int y_gap);
   bool              CreateCanvas(void);
   //---
public:
   // --- Draws an element
   virtual void      Draw(void);
  };
 #ifndef CPICTURE_MQH_IMPLEMENTATION
 #define CPICTURE_MQH_IMPLEMENTATION
   //+------------------------------------------------------------------+
   //| Constructor                                                      |
   //+------------------------------------------------------------------+
   CPicture::CPicture(void)

     {
   // --- Save the element class name in the base class
      CElementBase::ClassName(CLASS_NAME);
     }
   //+------------------------------------------------------------------+
   //| Destructor                                                       |
   //+------------------------------------------------------------------+
   CPicture::~CPicture(void)
     {
     }
   //+------------------------------------------------------------------+
   // | Creates an "Image" element |
   //+------------------------------------------------------------------+
   bool CPicture::CreatePicture(const int x_gap,const int y_gap)
     {
   // --- Quit if there is no pointer to the main element
      if(!CElement::CheckMainPointer())
         return(false);
   // --- Initializing properties
      InitializeProperties(x_gap,y_gap);
   // ---Creating an element
      if(!CreateCanvas())
         return(false);
   //---
      return(true);
     }
   //+------------------------------------------------------------------+
   // | Initializing properties |
   //+------------------------------------------------------------------+
   void CPicture::InitializeProperties(const int x_gap,const int y_gap)
     {
      m_x      =CElement::CalculateX(x_gap);
      m_y      =CElement::CalculateY(y_gap);
      m_x_size =(m_x_size<1)? 16 : m_x_size;
      m_y_size =(m_y_size<1)? 16 : m_y_size;
   // ---Default properties
      m_back_color =(m_back_color!=clrNONE)? m_back_color : m_main.BackColor();
   // --- Indents from the extreme point
      CElementBase::XGap(x_gap);
      CElementBase::YGap(y_gap);
     }
   //+------------------------------------------------------------------+
   // | Creates an object to draw |
   //+------------------------------------------------------------------+
   bool CPicture::CreateCanvas(void)
     {
   // --- Formation of object name
      string name=CElementBase::ElementName("icon");
   // ---Create an object
      if(!CElement::CreateCanvas(name,m_x,m_y,m_x_size,m_y_size))
         return(false);
   //---
      return(true);
     }
   //+------------------------------------------------------------------+
   // | Draws an element |
   //+------------------------------------------------------------------+
   void CPicture::Draw(void)
     {
   // --- Draw background
      CElement::DrawBackground();
   // --- Draw a picture
      CElement::DrawImage();
     }
   //+------------------------------------------------------------------+
 #endif // CPICTURE_MQH_IMPLEMENTATION
#endif // __PICTURE_MQH__
