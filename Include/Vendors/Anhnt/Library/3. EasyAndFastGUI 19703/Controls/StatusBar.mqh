//+------------------------------------------------------------------+
//|                                                    StatusBar.mqh |
//|                        Copyright 2015, MetaQuotes Software Corp. |
//|                                              http://www.mql5.com |
//+------------------------------------------------------------------+
#include "..\Element.mqh"
#include "TextLabel.mqh"
#include "SeparateLine.mqh"
//+------------------------------------------------------------------+
// | Class for creating a status line |
//+------------------------------------------------------------------+
class CStatusBar : public CElement
  {
private:
   // --- Objects for creating an element
   CTextLabel        m_items[];
   CSeparateLine     m_sep_line[];
   //---
public:
                     CStatusBar(void);
                    ~CStatusBar(void);
   // --- Methods for creating a status line
   bool              CreateStatusBar(const int x_gap,const int y_gap);
   //---
private:
   void              InitializeProperties(const int x_gap,const int y_gap);
   bool              CreateCanvas(void);
   bool              CreateItems(void);
   bool              CreateSeparateLine(const int line_index);
   //---
public:
   // --- Returns pointer and dividing line
   CTextLabel       *GetItemPointer(const uint index);
   CSeparateLine    *GetSeparateLinePointer(const uint index);
   // --- (1) Number of points and (2) dividing lines
   int               ItemsTotal(void)         const { return(::ArraySize(m_items));    }
   int               SeparateLinesTotal(void) const { return(::ArraySize(m_sep_line)); }
   // --- Adds an item with the specified properties before creating the status line
   void              AddItem(const string text,const int width);
   // --- Setting the value at the specified index
   void              SetValue(const uint index,const string value);
   //---
public:
   // ---Delete
   virtual void      Delete(void);
   // --- Draws an element
   virtual void      Draw(void);
   //---
private:
   // --- Calculation of element width
   int               CalculationXSize(void);
   // --- Calculation of the width of the first paragraph
   int               CalculationFirstItemXSize(void);
   // --- Calculate the X-coordinate of a point
   int               CalculationItemX(const int item_index=0);
   // --- Change the width along the right edge of the window
   virtual void      ChangeWidthByRightWindowSide(void);
  };
//+------------------------------------------------------------------+
//| Constructor                                                      |
//+------------------------------------------------------------------+
CStatusBar::CStatusBar(void)
  {
// --- Save the element class name in the base class
   CElementBase::ClassName(CLASS_NAME);
  }
//+------------------------------------------------------------------+
//| Destructor                                                       |
//+------------------------------------------------------------------+
CStatusBar::~CStatusBar(void)
  {
  }
//+------------------------------------------------------------------+
// | Creates a status line |
//+------------------------------------------------------------------+
bool CStatusBar::CreateStatusBar(const int x_gap,const int y_gap)
  {
// --- Quit if there is no pointer to the main element
   if(!CElement::CheckMainPointer())
      return(false);
// ---Initializing properties
   InitializeProperties(x_gap,y_gap);
// --- Creates an element
   if(!CreateCanvas())
      return(false);
   if(!CreateItems())
      return(false);
//---
   return(true);
  }
//+------------------------------------------------------------------+
// | Initializing properties |
//+------------------------------------------------------------------+
void CStatusBar::InitializeProperties(const int x_gap,const int y_gap)
  {
   m_x        =CElement::CalculateX(x_gap);
   m_y        =CElement::CalculateY(y_gap);
   m_x_size   =CalculationXSize();
   m_y_size   =(m_y_size<1)? 22 : m_y_size;
// ---Default properties
   m_back_color   =(m_back_color!=clrNONE)? m_back_color : C'225,225,225';
   m_border_color =(m_border_color!=clrNONE)? m_border_color : m_back_color;
   m_label_color  =(m_label_color!=clrNONE)? m_label_color : clrBlack;
   m_label_x_gap  =(m_label_x_gap!=WRONG_VALUE)? m_label_x_gap : 0;
   m_label_y_gap  =(m_label_y_gap!=WRONG_VALUE)? m_label_y_gap : 0;
// --- Indents from the extreme point
   CElementBase::XGap(x_gap);
   CElementBase::YGap(y_gap);
  }
//+------------------------------------------------------------------+
// | Creates an object to draw |
//+------------------------------------------------------------------+
bool CStatusBar::CreateCanvas(void)
  {
// --- Formation of object name
   string name=CElementBase::ElementName("statusbar");
// ---Create an object
   if(!CElement::CreateCanvas(name,m_x,m_y,m_x_size,m_y_size))
      return(false);
//---
   return(true);
  }
//+------------------------------------------------------------------+
// | Creates a list of status line items |
//+------------------------------------------------------------------+
bool CStatusBar::CreateItems(void)
  {
   int x=0,y=0;
// --- Get the number of points
   int items_total=ItemsTotal();
// --- If there is not a single item in the group, report it and exit
   if(items_total<1)
     {
      ::Print(__FUNCTION__," > Вызов этого метода нужно осуществлять, "
              "когда в группе есть хотя бы один пункт! Воспользуйтесь методом CStatusBar::AddItem()");
      return(false);
     }
// --- If the width of the first item is not specified, then we calculate it relative to the total width of other items
   if(m_items[0].XSize()<1)
      m_items[0].XSize(CalculationFirstItemXSize());
// --- Create the specified number of points
   for(int i=0; i<items_total; i++)
     {
      // --- Save a pointer to the parent element
      m_items[i].MainPointer(this);
      // --- X coordinate
      x=(i>0)? x+m_items[i-1].XSize() : 0;
      // --- Properties
      m_items[i].Index(i);
      m_items[i].YSize(m_y_size);
      m_items[i].Font(CElement::Font());
      m_items[i].FontSize(CElement::FontSize());
      m_items[i].LabelXGap(m_items[i].LabelXGap()<0? 7 : m_items[i].LabelXGap());
      m_items[i].LabelYGap(m_items[i].LabelYGap()<0? 5 : m_items[i].LabelYGap());
      // ---Create an object
      if(!m_items[i].CreateTextLabel(m_items[i].LabelText(),x,y))
         return(false);
      // --- Add element to array
      CElement::AddToArray(m_items[i]);
     }
// --- Creating dividing lines
   for(int i=1; i<items_total; i++)
      CreateSeparateLine(i);
//---
   return(true);
  }
//+------------------------------------------------------------------+
// | Creates a dividing line |
//+------------------------------------------------------------------+
bool CStatusBar::CreateSeparateLine(const int line_index)
  {
// --- Lines are established from the second (1) point
   if(line_index<1)
      return(false);
// --- Coordinates
   int x =m_items[line_index].XGap();
   int y =3;
// --- Index adjustment
   int i=line_index-1;
// --- Increase the line array by one element
   int array_size=::ArraySize(m_sep_line);
   ::ArrayResize(m_sep_line,array_size+1);
// --- Save the form pointer
   m_sep_line[i].MainPointer(this);
// --- Properties
   m_sep_line[i].Index(i);
   m_sep_line[i].TypeSepLine(V_SEP_LINE);
// ---Creating a line
   if(!m_sep_line[i].CreateSeparateLine(x,y,2,m_y_size-6))
      return(false);
// --- Add element to array
   CElement::AddToArray(m_sep_line[i]);
   return(true);
  }
//+------------------------------------------------------------------+
// | Returns the menu item pointer by index |
//+------------------------------------------------------------------+
CTextLabel *CStatusBar::GetItemPointer(const uint index)
  {
   uint array_size=::ArraySize(m_items);
// --- If there is not a single item in the context menu, report it
   if(array_size<1)
      ::Print(__FUNCTION__," > Вызов этого метода нужно осуществлять, когда есть хотя бы один пункт!");
// --- Adjustment in case of leaving the range
   uint i=(index>=array_size)? array_size-1 : index;
// --- Return pointer
   return(::GetPointer(m_items[i]));
  }
//+------------------------------------------------------------------+
// | Returns the dividing line pointer at index |
//+------------------------------------------------------------------+
CSeparateLine *CStatusBar::GetSeparateLinePointer(const uint index)
  {
   uint array_size=::ArraySize(m_sep_line);
// --- If there is not a single item in the context menu, report it
   if(array_size<1)
      return(NULL);
// --- Adjustment in case of leaving the range
   uint i=(index>=array_size)? array_size-1 : index;
// --- Return pointer
   return(::GetPointer(m_sep_line[i]));
  }
//+------------------------------------------------------------------+
// | Adds a menu item |
//+------------------------------------------------------------------+
void CStatusBar::AddItem(const string text,const int width)
  {
// --- Increase the size of the arrays by one element
   int array_size=::ArraySize(m_items);
   ::ArrayResize(m_items,array_size+1);
// --- Save the values ​​of the passed parameters
   m_items[array_size].XSize(width);
   m_items[array_size].LabelText(text);
  }
//+------------------------------------------------------------------+
// | Sets the value at the specified index |
//+------------------------------------------------------------------+
void CStatusBar::SetValue(const uint index,const string value)
  {
// --- Check for out of range
   uint array_size=::ArraySize(m_items);
   if(array_size<1)
      return;
// --- Adjust index value if out of range
   uint correct_index=(index>=array_size)? array_size-1 : index;
// --- Setting the transmitted text
   m_items[correct_index].LabelText(value);
  }
//+------------------------------------------------------------------+
// | Removal |
//+------------------------------------------------------------------+
void CStatusBar::Delete(void)
  {
   CElement::Delete();
// --- Freeing element arrays
   ::ArrayFree(m_items);
   ::ArrayFree(m_sep_line);
  }
//+------------------------------------------------------------------+
// | Calculation of element width |
//+------------------------------------------------------------------+
int CStatusBar::CalculationXSize(void)
  {
   return((m_x_size<1 || m_auto_xresize_mode)? m_main.X2()-m_x-m_auto_xresize_right_offset : m_x_size);
  }
//+------------------------------------------------------------------+
// | Calculation of the width of the first paragraph |
//+------------------------------------------------------------------+
int CStatusBar::CalculationFirstItemXSize(void)
  {
   int width=0;
// --- Get the number of points
   int items_total=ItemsTotal();
   if(items_total<1)
      return(0);
// --- Calculate the width relative to the total width of the remaining points
   for(int i=1; i<items_total; i++)
      width+=m_items[i].XSize();
//---
   return(m_x_size-width);
  }
//+------------------------------------------------------------------+
// | Change the width along the right edge of the form |
//+------------------------------------------------------------------+
void CStatusBar::ChangeWidthByRightWindowSide(void)
  {
// --- Exit if the mode of fixing to the right edge of the form is enabled
   if(m_anchor_right_window_side)
      return;
// --- Coordinates and width
   int x=0;
// --- Calculate and set a new overall size
   int x_size=m_main.X2()-m_canvas.X()-m_auto_xresize_right_offset;
   CElementBase::XSize(x_size);
   m_canvas.XSize(x_size);
   m_canvas.Resize(x_size,m_y_size);
// --- Calculate and set a new size for the first item
   x_size=CalculationFirstItemXSize();
   m_items[0].XSize(x_size);
   m_items[0].CanvasPointer().XSize(x_size);
   m_items[0].CanvasPointer().Resize(x_size,m_y_size);
   m_items[0].Update(true);
// --- Get the number of points
   int items_total=ItemsTotal();
// --- Set the coordinate and indentation for all points except the first
   for(int i=1; i<items_total; i++)
     {
      x=x+m_items[i-1].XSize();
      m_items[i].XGap(x);
      m_sep_line[i-1].XGap(x);
      m_items[i].CanvasPointer().XGap(x);
      m_sep_line[i-1].CanvasPointer().XGap(x);
     }
// --- Redraw element
   Draw();
// --- Update object position
   Moving();
  }
//+------------------------------------------------------------------+
// | Draws an element |
//+------------------------------------------------------------------+
void CStatusBar::Draw(void)
  {
// --- Draw background
   CElement::DrawBackground();
  }
//+------------------------------------------------------------------+
