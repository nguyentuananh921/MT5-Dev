//+------------------------------------------------------------------+
//|                                                      Tooltip.mqh |
//|                        Copyright 2015, MetaQuotes Software Corp. |
//|Lib Link https://www.mql5.com/en/code/19703                       |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//| Class for creating a tooltip                                     |
//+------------------------------------------------------------------+
#ifndef __TOOLTIP_MQH__
#define __TOOLTIP_MQH__
 #include "..\Element.mqh"

 class CTooltip : public CElement
  {
   private:
    // --- Pointer to the element to which the tooltip is attached
     CElement         *m_element;
    // --- Header text and color
     string            m_header_text;
     color             m_header_color;
    // --- Array of tooltip text strings
     string            m_tooltip_lines[];
    //---
   public:
                     CTooltip(void);
                     ~CTooltip(void);
    // ---Methods for creating a tooltip
     bool              CreateTooltip(void);
    //---
   private:
      void              InitializeProperties(void);
      bool              CreateCanvas(void);
    //---
   public:
    // --- (1) Stores the element pointer, (2) the tooltip title
      void              ElementPointer(CElement &object) { m_element=::GetPointer(object); }
      void              HeaderText(const string text)    { m_header_text=text;             }
      void              HeaderColor(const color clr)     { m_header_color=clr;             }
    // --- Adds a line for a tooltip
      void              AddString(const string text);

    // --- (1) Shows and (2) hides the tooltip
      void              ShowTooltip(void);
      void              FadeOutTooltip(void);
    //---
      public:
    // ---Graph event handler
      virtual void      OnEvent(const int id,const long &lparam,const double &dparam,const string &sparam);
    // --- Management
      virtual void      Reset(void);
      virtual void      Delete(void);
  };
#ifndef TOOLTIP_IMPLEMENTATION
#define TOOLTIP_IMPLEMENTATION
 //+------------------------------------------------------------------+
 //| Constructor                                                      |
 //+------------------------------------------------------------------+
 CTooltip::CTooltip(void) : m_header_text(""),
                           m_header_color(C'50,50,50')
  {
   // --- Save the element class name in the base class
    CElement::ClassName(CLASS_NAME);
   // --- Initially completely transparent
    CElement::Alpha(0);
  }
 //+------------------------------------------------------------------+
 //| Destructor                                                       |
 //+------------------------------------------------------------------+
 CTooltip::~CTooltip(void)
   {
   }
 //+------------------------------------------------------------------+
 // | Graphics Event Handler |
 //+------------------------------------------------------------------+
 void CTooltip::OnEvent(const int id,const long &lparam,const double &dparam,const string &sparam)
  {
   // --- Handling the cursor movement event
   if(id==CHARTEVENT_MOUSE_MOVE)
    {
      // --- Exit if element is hidden
      if(!CElement::IsVisible())
         return;
      // --- Exit if the tooltip button on the form is disabled
      if(!m_wnd.IsTooltip())
         return;
      // --- If the form is locked, hide the tooltip
      if(m_main.CElementBase::IsLocked())
         {
         FadeOutTooltip();
         return;
         }
      // --- If there is focus on an element, show a tooltip
      if(m_element.MouseFocus())
         ShowTooltip();
      // ---If there is no focus, hide the tooltip
      else
         FadeOutTooltip();
      //---
      return;
    }
  }
 //+------------------------------------------------------------------+
 // | Creates a Tooltip object |
 //+------------------------------------------------------------------+
 bool CTooltip::CreateTooltip(void)
  {
   // --- Quit if there is no pointer to the main element
   if(!CElement::CheckMainPointer())
      return(false);
   // --- Exit if there is no pointer to element
   if(::CheckPointer(m_element)==POINTER_INVALID)
    {
      ::Print(__FUNCTION__," > Перед созданием всплывающей подсказки классу нужно передать "
               "указатель на элемент: CTooltip::ElementPointer(CElement &object).");
      return(false);
    }
   // --- Initializing properties
     InitializeProperties();
   // --- Creates a tooltip
     if(!CreateCanvas())
      return(false);
   //---
   return(true);
  }
  //+------------------------------------------------------------------+
  // | Initializing properties |
  //+------------------------------------------------------------------+
  void CTooltip::InitializeProperties(void)
   {
      m_x        =CElement::CalculateX(m_element.XGap());
      m_y        =CElement::CalculateY(m_element.YGap()+m_element.YSize()+1);
      m_x_size   =(m_x_size<1)? 100 : m_x_size;
      m_y_size   =(m_y_size<1)? 50 : m_y_size;

      // ---Default colors
      //m_border_color =(m_border_color!=clrNONE)? m_border_color : C'150,170,180';
      //m_border_color = (m_border_color != clrNONE && (int)m_border_color != -1)? m_border_color : C'150,170,180';
      if(m_border_color == clrNONE)
         m_border_color = C'150,170,180';
      
      m_label_color  =(m_label_color!=clrNONE)? m_label_color : clrDimGray;
      // --- Indents from the extreme point
      CElement::XGap(CElement::CalculateXGap(m_x));
      CElement::YGap(CElement::CalculateYGap(m_y));
   }
  //+------------------------------------------------------------------+
  // | Creates a canvas for drawing |
  //+------------------------------------------------------------------+
  bool CTooltip::CreateCanvas(void)
   {
      // --- Formation of object name
      string name=CElementBase::ElementName("tooltip");
      // ---Create an object
      if(!CElement::CreateCanvas(name,m_x,m_y,m_x_size,m_y_size))
         return(false);
      // --- Clearing the drawing canvas
      m_canvas.Erase(::ColorToARGB(clrNONE,0));
      m_canvas.Update();
      // --- Reset push priority
      Z_Order(WRONG_VALUE);
      return(true);
   }
   //+------------------------------------------------------------------+
   // | Adds the line |
   //+------------------------------------------------------------------+
   void CTooltip::AddString(const string text)
   {
   // --- Increase the size of the arrays by one element
   int array_size=::ArraySize(m_tooltip_lines);
   ::ArrayResize(m_tooltip_lines,array_size+1);
   // --- Save the values ​​of the passed parameters
   m_tooltip_lines[array_size]=text;
   }
   //+------------------------------------------------------------------+
   // | Displays tooltip |
   //+------------------------------------------------------------------+
   void CTooltip::ShowTooltip(void)
    {
      // --- Quit if the tooltip is 100% visible
         if(m_alpha>=255)
            return;
      // --- Coordinates and indentation for the title
         int x=5,y=5;
         int y_offset=15;
      // --- Fully visible tooltip sign
         m_alpha=255;
      // --- Draw the background and frame
         //DrawBackground(); // ✅ Thay vì DrawBackground() — erase trong suốt trước, rồi vẽ box tooltip
            m_canvas.Erase(::ColorToARGB(clrNONE, 0));  // xóa sạch
         //DrawBorder();  //Remove to Draw transparent Tooltips
      // --- Draw the title (if installed)
      if(m_header_text!="")
         {
         // --- Set font parameters
         m_canvas.FontSet(CElement::Font(),-CElement::FontSize()*10,FW_BLACK);
         // --- Drawing the title text
         m_canvas.TextOut(x,y,m_header_text,::ColorToARGB(m_header_color),TA_LEFT|TA_TOP);
         }
      // --- Coordinates for the main text of the tooltip (taking into account the presence of a title)
      x =(m_header_text!="")? 15 : 5;
      y =(m_header_text!="")? 25 : 5;
      // --- Set font parameters
      m_canvas.FontSet(CElement::Font(),-CElement::FontSize()*10,FW_THIN);
      // --- Drawing the main text of the tooltip
      int lines_total=::ArraySize(m_tooltip_lines);
      for(int i=0; i<lines_total; i++)
         {
         m_canvas.TextOut(x,y,m_tooltip_lines[i],::ColorToARGB(m_label_color),TA_LEFT|TA_TOP);
         y=y+y_offset;
         }
      // --- Refresh canvas
      m_canvas.Update();
    }
   //+------------------------------------------------------------------+
   // | Fade out tooltip |
   //+------------------------------------------------------------------+
   void CTooltip::FadeOutTooltip(void)
   {
   // --- Quit if the tooltip is 100% hidden
   if(m_alpha<1)
      return;
   // --- Indent for header
   int y_offset=15;
   // --- Transparency step
   uchar fadeout_step=7;
   // --- Initial value
   uchar alpha=m_alpha;
   // --- Smooth disappearance of tooltip
   for(uchar a=alpha; a>=0; a-=fadeout_step)
      {
      m_alpha=a;
      // --- If the next step is negative, stop the cycle
      if(a-fadeout_step<0)
         {
         m_alpha=0;
         m_canvas.Erase(::ColorToARGB(clrNONE,m_alpha));
         m_canvas.Update();
         break;
         }
      // --- Coordinates for header
      int x=5,y=5;
      // --- Draw the background and frame
      DrawBackground();
      DrawBorder();
      // --- Draw the title (if installed)
      if(m_header_text!="")
         {
         // --- Set font parameters
         m_canvas.FontSet(CElement::Font(),-CElement::FontSize()*10,FW_BLACK);
         // --- Drawing the title text
         m_canvas.TextOut(x,y,m_header_text,::ColorToARGB(m_header_color,m_alpha),TA_LEFT|TA_TOP);
         }
      // --- Coordinates for the main text of the tooltip (taking into account the presence of a title)
      x =(m_header_text!="")? 15 : 5;
      y =(m_header_text!="")? 25 : 5;
      // --- Set font parameters
      m_canvas.FontSet(CElement::Font(),-CElement::FontSize()*10,FW_THIN);
      // --- Drawing the main text of the tooltip
      int lines_total=::ArraySize(m_tooltip_lines);
      for(int i=0; i<lines_total; i++)
         {
         m_canvas.TextOut(x,y,m_tooltip_lines[i],::ColorToARGB(m_label_color,m_alpha),TA_LEFT|TA_TOP);
         y=y+y_offset;
         }
      // --- Refresh canvas
      m_canvas.Update();
      }
   }
   //+------------------------------------------------------------------+
   // | Redraw |
   //+------------------------------------------------------------------+
   void CTooltip::Reset(void)
   {
   Hide();
   Show();
   }
   //+------------------------------------------------------------------+
   // | Removal |
   //+------------------------------------------------------------------+
   void CTooltip::Delete(void)
   {
   // --- Deleting objects
   CElement::Delete();
   // --- Freeing element arrays
   ::ArrayFree(m_tooltip_lines);
   }
   //+------------------------------------------------------------------+
#endif // TOOLTIP_IMPLEMENTATION
#endif // __TOOLTIP_MQH__



