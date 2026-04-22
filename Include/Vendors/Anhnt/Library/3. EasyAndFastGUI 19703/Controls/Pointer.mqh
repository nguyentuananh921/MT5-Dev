//+------------------------------------------------------------------+
//|                                                      Pointer.mqh |
//|                        Copyright 2015, MetaQuotes Software Corp. |
//|                                              http://www.mql5.com |
//+------------------------------------------------------------------+
#ifndef __POINTER_MQH__
#define __POINTER_MQH__
#include "..\Element.mqh"
//+------------------------------------------------------------------+
// | Class for creating a mouse cursor |
//+------------------------------------------------------------------+
class CPointer : public CElement
  {
private:
   // --- Pictures for index
   string            m_file_on;
   string            m_file_off;
   // --- Pointer type
   ENUM_MOUSE_POINTER m_type;
   // --- Pointer state
   bool              m_state;
   //---
public:
                     CPointer(void);
                    ~CPointer(void);
   // --- Creates a pointer shortcut
   bool              CreatePointer(const long chart_id,const int subwin);
   //---
private:
   bool              CreateCanvas(void);
   //---
public:
   // --- Setting shortcuts for the pointer
   void              FileOn(const string file_path)       { m_file_on=file_path;  }
   void              FileOff(const string file_path)      { m_file_off=file_path; }
   // --- Return and set (1) pointer type, (2) pointer state
   ENUM_MOUSE_POINTER Type(void)                    const { return(m_type);       }
   void              Type(ENUM_MOUSE_POINTER type)        { m_type=type;          }
   bool              State(void)                    const { return(m_state);      }
   void              State(const bool state);
   // --- Coordinates update
   void              UpdateX(const int mouse_x)           { ::ObjectSetInteger(m_chart_id,m_canvas.ChartObjectName(),OBJPROP_XDISTANCE,mouse_x-CElementBase::XGap()); }
   void              UpdateY(const int mouse_y)           { ::ObjectSetInteger(m_chart_id,m_canvas.ChartObjectName(),OBJPROP_YDISTANCE,mouse_y-CElementBase::YGap()); }
   //---
public:
   // ---Move element
   virtual void      Moving(const int mouse_x,const int mouse_y);
   // --- Management
   virtual void      Show(void);
   virtual void      Hide(void);
   virtual void      Reset(void);
   virtual void      Delete(void);
   // --- Draws an element
   virtual void      Draw(void);
   //---
private:
   // --- Setting images for the mouse cursor
   void              SetPointerBmp(void);
  };
 #ifndef CPOINTER_MQH_IMPLEMENTATION
 #define CPOINTER_MQH_IMPLEMENTATION
   //+------------------------------------------------------------------+
   //| Constructor                                                      |
   //+------------------------------------------------------------------+
   CPointer::CPointer(void) : m_state(true),
                              m_file_on(""),
                              m_file_off(""),
                              m_type(MP_X_RESIZE)
     {
   // --- Save the element class name in the base class
      CElementBase::ClassName(CLASS_NAME);
   // --- Default element index value
      CElement::Index(0);
   // --- Transparent background
      m_alpha=0;
     }
   //+------------------------------------------------------------------+
   //| Destructor                                                       |
   //+------------------------------------------------------------------+
   CPointer::~CPointer(void)
     {
      Delete();
     }
   //+------------------------------------------------------------------+
   // | Creates a pointer |
   //+------------------------------------------------------------------+
   bool CPointer::CreatePointer(const long chart_id,const int subwin)
     {
   // --- Properties
      m_chart_id =chart_id;
      m_subwin   =subwin;
      m_x_size   =(m_x_size<1)? 16 : m_x_size;
      m_y_size   =(m_y_size<1)? 16 : m_y_size;
   // --- Save pointer to self
      CElement::MainPointer(this);
   // --- Setting pictures for the index
      SetPointerBmp();
   // --- Creates an element
      if(!CreateCanvas())
         return(false);
   // --- Hide element
      Hide();
      return(true);
     }
   //+------------------------------------------------------------------+
   // | Creates an object to draw |
   //+------------------------------------------------------------------+
   bool CPointer::CreateCanvas(void)
     {
   // --- Formation of object name
      string name=CElementBase::ElementName("pointer");
   // ---Create an object
      if(!CElement::CreateCanvas(name,m_x,m_y,m_x_size,m_y_size))
         return(false);
   // --- Disabled by default
      State(false);
      return(true);
     }
   //+------------------------------------------------------------------+
   // | Setting the pointer state |
   //+------------------------------------------------------------------+
   void CPointer::State(const bool state)
     {
   // --- Exit if repeat
      if(state==m_state)
         return;
   // ---Save state
      m_state=state;
   // --- Save index of selected image
      CElement::ChangeImage(0,CElement::SelectedImage());
   // --- Draw a picture
      Draw();
   // --- Apply
      CElement::Update(true);
     }
   //+------------------------------------------------------------------+
   // | Moving an element |
   //+------------------------------------------------------------------+
   void CPointer::Moving(const int mouse_x,const int mouse_y)
     {
      UpdateX(mouse_x);
      UpdateY(mouse_y);
     }
   //+------------------------------------------------------------------+
   // | Shows element |
   //+------------------------------------------------------------------+
   void CPointer::Show(void)
     {
   // --- Exit if element is already visible
      if(CElementBase::IsVisible())
         return;
   // --- Make all objects visible
      ::ObjectSetInteger(m_chart_id,m_canvas.ChartObjectName(),OBJPROP_TIMEFRAMES,OBJ_ALL_PERIODS);
   // --- Visibility state
      CElementBase::IsVisible(true);
     }
   //+------------------------------------------------------------------+
   // | Hides the element |
   //+------------------------------------------------------------------+
   void CPointer::Hide(void)
     {
   // --- Exit if element is hidden
      if(!CElementBase::IsVisible())
         return;
   // --- Hide objects
      ::ObjectSetInteger(m_chart_id,m_canvas.ChartObjectName(),OBJPROP_TIMEFRAMES,OBJ_NO_PERIODS);
   // --- Visibility state
      CElementBase::IsVisible(false);
     }
   //+------------------------------------------------------------------+
   // | Redraw |
   //+------------------------------------------------------------------+
   void CPointer::Reset(void)
     {
   // --- Hide and show
      Hide();
      Show();
     }
   //+------------------------------------------------------------------+
   // | Removal |
   //+------------------------------------------------------------------+
   void CPointer::Delete(void)
     {
      m_canvas.Destroy();
   // ---Save state
      m_state=true;
   // --- Visibility state
      CElementBase::IsVisible(true);
     }
   //+------------------------------------------------------------------+
   // | Draws an element |
   //+------------------------------------------------------------------+
   void CPointer::Draw(void)
     {
   // --- Draw background
      CElement::DrawBackground();
   // --- Draw a picture
      CElement::DrawImage();
     }
   //+------------------------------------------------------------------+
   // | Setting pictures for the index by index type |
   //+------------------------------------------------------------------+
   void CPointer::SetPointerBmp(void)
     {
      switch(m_type)
        {
         case MP_X_RESIZE :
            m_file_on  =(string)IMAGE_RESOURCE_CONTROLS_POINTER_X_RS_BMP;
            m_file_off =(string)IMAGE_RESOURCE_CONTROLS_POINTER_X_RS_BLUE_BMP;
            break;
         case MP_Y_RESIZE :
            m_file_on  =(string)IMAGE_RESOURCE_CONTROLS_POINTER_Y_RS_BMP;
            m_file_off =(string)IMAGE_RESOURCE_CONTROLS_POINTER_Y_RS_BLUE_BMP;
            break;
         case MP_XY1_RESIZE :
            m_file_on  =(string)IMAGE_RESOURCE_CONTROLS_POINTER_XY1_RS_BMP;
            m_file_off =(string)IMAGE_RESOURCE_CONTROLS_POINTER_XY1_RS_BLUE_BMP;
            break;
         case MP_XY2_RESIZE :
            m_file_on  =(string)IMAGE_RESOURCE_CONTROLS_POINTER_XY2_RS_BMP;
            m_file_off =(string)IMAGE_RESOURCE_CONTROLS_POINTER_XY2_RS_BLUE_BMP;
            break;
         case MP_WINDOW_RESIZE :
           {
            CElement::AddImagesGroup(0,0);
            CElement::AddImage(0,(string)IMAGE_RESOURCE_CONTROLS_POINTER_X_RS_BMP);
            CElement::AddImage(0,(string)IMAGE_RESOURCE_CONTROLS_POINTER_Y_RS_BMP);
            break;
           }
         case MP_X_RESIZE_RELATIVE :
            m_file_on  =(string)IMAGE_RESOURCE_CONTROLS_POINTER_X_RS_REL_BMP;
            m_file_off =(string)IMAGE_RESOURCE_CONTROLS_POINTER_X_RS_REL_BMP;
            break;
         case MP_Y_RESIZE_RELATIVE :
            m_file_on  =(string)IMAGE_RESOURCE_CONTROLS_POINTER_Y_RS_REL_BMP;
            m_file_off =(string)IMAGE_RESOURCE_CONTROLS_POINTER_Y_RS_REL_BMP;
            break;
         case MP_X_SCROLL :
            m_file_on  =(string)IMAGE_RESOURCE_CONTROLS_POINTER_X_SCROLL_BMP;
            m_file_off =(string)IMAGE_RESOURCE_CONTROLS_POINTER_X_SCROLL_BLUE_BMP;
            break;
         case MP_Y_SCROLL :
            m_file_on  =(string)IMAGE_RESOURCE_CONTROLS_POINTER_Y_SCROLL_BMP;
            m_file_off =(string)IMAGE_RESOURCE_CONTROLS_POINTER_Y_SCROLL_BLUE_BMP;
            break;
         case MP_TEXT_SELECT :
            m_file_on  =(string)IMAGE_RESOURCE_CONTROLS_POINTER_TEXT_SELECT_BMP;
            m_file_off =(string)IMAGE_RESOURCE_CONTROLS_POINTER_TEXT_SELECT_BMP;
            break;
        }
   // --- If a custom type is specified (MP_CUSTOM)
      if(m_type==MP_CUSTOM)
         if(m_file_on=="" || m_file_off=="")
            ::Print(__FUNCTION__," > Для указателя курсора нужно установить картинки!");
   // --- Set picture
      if(m_type!=MP_WINDOW_RESIZE)
        {
         CElement::IconFile((uint)m_file_on);
         CElement::IconFileLocked((uint)m_file_off);
        }
     }
   //+------------------------------------------------------------------+
 #endif // CPOINTER_MQH_IMPLEMENTATION
#endif // __POINTER_MQH__
