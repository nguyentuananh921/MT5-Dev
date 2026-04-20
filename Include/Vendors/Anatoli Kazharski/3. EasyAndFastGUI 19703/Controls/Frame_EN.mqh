//+------------------------------------------------------------------+
//|                                                        Frame.mqh |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                              http://www.mql5.com |
//+------------------------------------------------------------------+
#include "..\Element.mqh"
#include "TextLabel.mqh"
//+------------------------------------------------------------------+
// | Class for creating an area for grouping elements |
//+------------------------------------------------------------------+
class CFrame : public CElement
  {
private:
   // --- Instances to create an element
   CTextLabel        m_text_label;
   //--- 
public:
                     CFrame(void);
                    ~CFrame(void);
   // --- Returns a text label pointer
   CTextLabel       *GetTextLabelPointer(void) { return(::GetPointer(m_text_label)); }
   // ---Methods for creating an area
   bool              CreateFrame(const string text,const int x_gap,const int y_gap);
   //---
private:
   void              InitializeProperties(const string text,const int x_gap,const int y_gap);
   bool              CreateCanvas(void);
   bool              CreateTextLabel(void);
   //---
public:
   // --- Draws an element
   virtual void      Draw(void);
   //---
private:
   // --- Change the width along the right edge of the window
   virtual void      ChangeWidthByRightWindowSide(void);
   // --- Change the height along the bottom edge of the window
   virtual void      ChangeHeightByBottomWindowSide(void);
  };
//+------------------------------------------------------------------+
//| Constructor                                                      |
//+------------------------------------------------------------------+
CFrame::CFrame(void)
  {
// --- Save the element class name in the base class
   CElementBase::ClassName(CLASS_NAME);
  }
//+------------------------------------------------------------------+
//| Destructor                                                       |
//+------------------------------------------------------------------+
CFrame::~CFrame(void)
  {
  }
//+------------------------------------------------------------------+
// | Creates a group of text input field objects |
//+------------------------------------------------------------------+
bool CFrame::CreateFrame(const string text,const int x_gap,const int y_gap)
  {
// --- Quit if there is no pointer to the main element
   if(!CElement::CheckMainPointer())
      return(false);
// --- Initializing properties
   InitializeProperties(text,x_gap,y_gap);
// --- Creating an element
   if(!CreateCanvas())
      return(false);
   if(!CreateTextLabel())
      return(false);
//---
   return(true);
  }
//+------------------------------------------------------------------+
// | Initializing properties |
//+------------------------------------------------------------------+
void CFrame::InitializeProperties(const string text,const int x_gap,const int y_gap)
  {
   m_x          =CElement::CalculateX(x_gap);
   m_y          =CElement::CalculateY(y_gap);
   m_x_size     =(m_x_size<1 || m_auto_xresize_mode)? m_main.X2()-m_x-m_auto_xresize_right_offset : m_x_size;
   m_y_size     =(m_y_size<1 || m_auto_yresize_mode)? m_main.Y2()-m_y-m_auto_yresize_bottom_offset : m_y_size;
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
bool CFrame::CreateCanvas(void)
  {
// --- Formation of object name
   string name=CElementBase::ElementName("frame");
// ---Create an object
   if(!CElement::CreateCanvas(name,m_x,m_y,m_x_size,m_y_size))
      return(false);
//---
   ShowTooltip(true);
   return(true);
  }
//+------------------------------------------------------------------+
// | Creates a text label |
//+------------------------------------------------------------------+
bool CFrame::CreateTextLabel(void)
  {
// --- Save a pointer to the parent element
   m_text_label.MainPointer(this);
// --- Coordinates
   int x=12;
   int y=-6;
// --- Properties
   if(m_label_text=="")
     {
      y=1;
      m_text_label.YSize(1);
      m_border_color=m_back_color;
     }
//---
   m_text_label.LabelXGap(5);
   m_text_label.Font(CElement::Font());
   m_text_label.FontSize(CElement::FontSize());
// ---Create an object
   if(!m_text_label.CreateTextLabel(m_label_text,x,y))
      return(false);
// --- Add element to array
   CElement::AddToArray(m_text_label);
   return(true);
  }
//+------------------------------------------------------------------+
// | Change the width along the right edge of the form |
//+------------------------------------------------------------------+
void CFrame::ChangeWidthByRightWindowSide(void)
  {
// --- Exit if snap to right side of window mode is enabled
   if(m_anchor_right_window_side)
      return;
// --- Dimensions
   int x_size=0;
// --- Calculate and set a new size for the element's background
   x_size=m_main.X2()-m_canvas.X()-m_auto_xresize_right_offset;
// --- Do not resize if less than the specified limit
   if(x_size==m_x_size)
      return;
//---
   CElementBase::XSize(x_size);
   m_canvas.XSize(x_size);
   m_canvas.Resize(x_size,m_y_size);
// --- Redraw element
   Draw();
// --- Update object position
   Moving();
  }
//+------------------------------------------------------------------+
// | Change the height along the bottom edge of the window |
//+------------------------------------------------------------------+
void CFrame::ChangeHeightByBottomWindowSide(void)
  {
// --- Exit if snap to bottom of window mode is enabled
   if(m_anchor_bottom_window_side)
      return;
// --- Dimensions
   int y_size=0;
// --- Calculate and set a new size for the element's background
   y_size=m_main.Y2()-m_canvas.Y()-m_auto_yresize_bottom_offset;
// --- Do not resize if less than the specified limit
   if(y_size==m_y_size)
      return;
//---
   CElementBase::YSize(y_size);
   m_canvas.YSize(y_size);
   m_canvas.Resize(m_x_size,y_size);
// --- Redraw element
   Draw();
// --- Update object position
   Moving();
  }
//+------------------------------------------------------------------+
// | Draws an element |
//+------------------------------------------------------------------+
void CFrame::Draw(void)
  {
// --- Draw background
   CElement::DrawBackground();
// --- Draw a frame
   CElement::DrawBorder();
  }
//+------------------------------------------------------------------+
