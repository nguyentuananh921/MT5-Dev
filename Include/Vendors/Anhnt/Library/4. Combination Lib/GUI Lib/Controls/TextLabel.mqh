//+------------------------------------------------------------------+
//|                                                    TextLabel.mqh |
//|                        Copyright 2016, MetaQuotes Software Corp. |
//|                                              http://www.mql5.com |
//+------------------------------------------------------------------+
#ifndef __TEXTLABEL_MQH__
#define __TEXTLABEL_MQH__
#include "..\Element.mqh"
//+------------------------------------------------------------------+
// | Class for creating a text label |
//+------------------------------------------------------------------+
class CTextLabel : public CElement
  {
public:
                     CTextLabel(void);
                    ~CTextLabel(void);
   // --- Methods for creating a text label
   bool              CreateTextLabel(const string text,const int x_gap,const int y_gap);
   //---
private:
   void              InitializeProperties(const string text,const int x_gap,const int y_gap);
   bool              CreateCanvas(void);
   //---
public:
   // --- Draws an element
   virtual void      Draw(void);
  };
 #ifndef CTEXTLABEL_MQH_IMPLEMENTATION
 #define CTEXTLABEL_MQH_IMPLEMENTATION
   //+------------------------------------------------------------------+
   //| Constructor                                                      |
   //+------------------------------------------------------------------+
   CTextLabel::CTextLabel(void)
     {
   // --- Save the element class name in the base class
      CElementBase::ClassName(CLASS_NAME);
     }
   //+------------------------------------------------------------------+
   //| Destructor                                                       |
   //+------------------------------------------------------------------+
   CTextLabel::~CTextLabel(void)
     {
     }
   //+------------------------------------------------------------------+
   // | Creates a group of text input field objects |
   //+------------------------------------------------------------------+
   bool CTextLabel::CreateTextLabel(const string text,const int x_gap,const int y_gap)
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
   void CTextLabel::InitializeProperties(const string text,const int x_gap,const int y_gap)
     {
      m_x          =CElement::CalculateX(x_gap);
      m_y          =CElement::CalculateY(y_gap);
      m_x_size     =(m_x_size<1)? 100 : m_x_size;
      m_y_size     =(m_y_size<1)? 20 : m_y_size;
      m_label_text =text;
   // ---Default background color
      m_back_color=(m_back_color!=clrNONE)? m_back_color : m_main.BackColor();
   // --- Indentation and color of text label
      m_label_color =(m_label_color!=clrNONE)? m_label_color : clrBlack;
      m_label_x_gap =(m_label_x_gap!=WRONG_VALUE)? m_label_x_gap : 0;
      m_label_y_gap =(m_label_y_gap!=WRONG_VALUE)? m_label_y_gap : 0;
   // --- Indents from the extreme point
      CElementBase::XGap(x_gap);
      CElementBase::YGap(y_gap);
     }
   //+------------------------------------------------------------------+
   // | Creates an object to draw |
   //+------------------------------------------------------------------+
   bool CTextLabel::CreateCanvas(void)
     {
   // --- Formation of object name
      string name=CElementBase::ElementName("text_label");
   // ---Create an object
      if(!CElement::CreateCanvas(name,m_x,m_y,m_x_size,m_y_size))
         return(false);
   //---
      ShowTooltip(true);
      return(true);
     }
   //+------------------------------------------------------------------+
   // | Draws an element |
   //+------------------------------------------------------------------+
   void CTextLabel::Draw(void)
     {
   // --- Draw background
      CElement::DrawBackground();
   // --- Draw a picture
      CElement::DrawImage();
   // --- Draw text
      CElement::DrawText();
     }
   //+------------------------------------------------------------------+
 #endif // CTEXTLABEL_MQH_IMPLEMENTATION
#endif // __TEXTLABEL_MQH__
