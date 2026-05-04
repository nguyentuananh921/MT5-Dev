//+------------------------------------------------------------------+
//|                                                     CheckBox.mqh |
//|                        Copyright 2015, MetaQuotes Software Corp. |
//|Library base on Link https://www.mql5.com/en/code/19703           |
//+------------------------------------------------------------------+
#ifndef __CHECKBOX_MQH__
#define __CHECKBOX_MQH__
#include "..\Element.mqh"
//+------------------------------------------------------------------+
// | Class for creating a checkbox |
//+------------------------------------------------------------------+
class CCheckBox : public CElement
  {
   private:
      void              InitializeProperties(const string text,const int x_gap,const int y_gap);
      bool              CreateCanvas(void);
      // --- Handling clicks on an element
      bool              OnClickCheckbox(const string pressed_object);
      // --- Draws a picture
      virtual void      DrawImage(void);
   public:
                      CCheckBox(void);
                     ~CCheckBox(void);
    // --- Methods for creating a checkbox
      bool              CreateCheckBox(const string text,const int x_gap,const int y_gap);      
    // --- Button state (pressed/released)
      bool              IsPressed(void) const { return(m_is_pressed); }
      void              IsPressed(const bool state);      
    // ---Graph event handler
      virtual void      OnEvent(const int id,const long &lparam,const double &dparam,const string &sparam);
    // --- Draws an element
      virtual void      Draw(void);      
  };
 #ifndef CCHECKBOX_MQH_IMPLEMENTATION
 #define CCHECKBOX_MQH_IMPLEMENTATION
   //+------------------------------------------------------------------+
   //| Constructor                                                      |
   //+------------------------------------------------------------------+
   CCheckBox::CCheckBox(void)

     {
   // --- Save the element class name in the base class
      CElementBase::ClassName(CLASS_NAME);
     }
   //+------------------------------------------------------------------+
   //| Destructor                                                       |
   //+------------------------------------------------------------------+
   CCheckBox::~CCheckBox(void)
     {
     }
   //+------------------------------------------------------------------+
   // | Event Handling |
   //+------------------------------------------------------------------+
   void CCheckBox::OnEvent(const int id,const long &lparam,const double &dparam,const string &sparam)
     {
   // --- Handling the cursor movement event
      if(id==CHARTEVENT_MOUSE_MOVE)
        {
         // --- Redraw element
         if(CheckCrossingBorder())
            Update(true);
         //---
         return;
        }
   // --- Handling the event of pressing the left mouse button on an object
      if(id==CHARTEVENT_OBJECT_CLICK)
        {
         // --- Click on the checkbox
         if(OnClickCheckbox(sparam))
            return;
        }
     }
   //+------------------------------------------------------------------+
   // | Creates a group of checkbox objects |
   //+------------------------------------------------------------------+
   bool CCheckBox::CreateCheckBox(const string text,const int x_gap,const int y_gap)
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
   void CCheckBox::InitializeProperties(const string text,const int x_gap,const int y_gap)
     {
      m_x          =CElement::CalculateX(x_gap);
      m_y          =CElement::CalculateY(y_gap);
      m_x_size     =(m_x_size<1)? 100 : m_x_size;
      m_y_size     =(m_y_size<1)? 14 : m_y_size;
      m_label_text =text;
   // ---Default background color
      m_back_color=(m_back_color!=clrNONE)? m_back_color : m_main.BackColor();
   // --- Indentation and color of text label
      m_label_x_gap         =(m_label_x_gap!=WRONG_VALUE)? m_label_x_gap : 18;
      m_label_y_gap         =(m_label_y_gap!=WRONG_VALUE)? m_label_y_gap : 0;
      m_label_color         =(m_label_color!=clrNONE)? m_label_color : clrBlack;
      m_label_color_hover   =(m_label_color_hover!=clrNONE)? m_label_color_hover : C'0,120,215';
      m_label_color_locked  =(m_label_color_locked!=clrNONE)? m_label_color_locked : clrSilver;
      m_label_color_pressed =(m_label_color_pressed!=clrNONE)? m_label_color_pressed : clrBlack;
   // --- Indents from the extreme point
      CElementBase::XGap(x_gap);
      CElementBase::YGap(y_gap);
     }
   //+------------------------------------------------------------------+
   // | Creates an object to draw |
   //+------------------------------------------------------------------+
   bool CCheckBox::CreateCanvas(void)
     {
   // --- Formation of object name
      string name=CElementBase::ElementName("checkbox");
   // --- Installation of images
      IconFile(IMAGE_RESOURCE_CONTROLS_CHECKBOX_OFF_BMP);
      IconFileLocked(IMAGE_RESOURCE_CONTROLS_CHECKBOX_OFF_LOCKED_BMP);
      IconFilePressed(IMAGE_RESOURCE_CONTROLS_CHECKBOX_ON_BMP);
      IconFilePressedLocked(IMAGE_RESOURCE_CONTROLS_CHECKBOX_ON_LOCKED_BMP);
   // ---Create an object
      if(!CElement::CreateCanvas(name,m_x,m_y,m_x_size,m_y_size))
         return(false);
   //---
      return(true);
     }
   //+------------------------------------------------------------------+
   // | Setting the element state (pressed/released) |
   //+------------------------------------------------------------------+
   void CCheckBox::IsPressed(const bool state)
     {
   // --- Exit if (1) the element is blocked or (2) the element is already in this state
      if(CElementBase::IsLocked() || m_is_pressed==state)
         return;
   // ---Status setting
      m_is_pressed=state;
   // --- Set the corresponding picture
      CElement::ChangeImage(0,!m_is_pressed? 0 : 2);
     }
   //+------------------------------------------------------------------+
   // | Clicking on an element |
   //+------------------------------------------------------------------+
   bool CCheckBox::OnClickCheckbox(const string pressed_object)
     {
   // --- Exit if (1) the object name is foreign or (2) the element is locked
      if(m_canvas.ChartObjectName()!=pressed_object || CElementBase::IsLocked())
         return(false);
   // --- Switch to the opposite state
      IsPressed(!(IsPressed()));
   // --- Redraw element
      Update(true);
   // --- We will send a message about this
      ::EventChartCustom(m_chart_id,ON_CLICK_CHECKBOX,CElementBase::Id(),0,m_label_text);
      return(true);
     }
   //+------------------------------------------------------------------+
   // | Draws an element |
   //+------------------------------------------------------------------+
   void CCheckBox::Draw(void)
     {
   // --- Draw background
      CElement::DrawBackground();
   // --- Draw a picture
      CCheckBox::DrawImage();
   // --- Draw text
      CElement::DrawText();
     }
   //+------------------------------------------------------------------+
   // | Draws a picture |
   //+------------------------------------------------------------------+
   void CCheckBox::DrawImage(void)
     {
   // --- Define the index
      uint image_index=(m_is_pressed)? 2 : 0;
   // --- If the element is not locked
      if(!CElementBase::IsLocked())
        {
         if(CElementBase::MouseFocus())
            image_index=(m_is_pressed)? 2 : 0;
        }
      else
         image_index=(m_is_pressed)? 3 : 1;
   // --- Set the corresponding picture
      CElement::ChangeImage(0,image_index);
   // --- Draw a picture
      CElement::DrawImage();
     }
   //+------------------------------------------------------------------+
 #endif // CCHECKBOX_MQH_IMPLEMENTATION
#endif // __CHECKBOX_MQH__
