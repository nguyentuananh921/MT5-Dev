#ifndef __CAPPSTATUSBAR_MQH__
#define __CAPPSTATUSBAR_MQH__
//Note forllow the link to build UI
//https://www.mql5.com/en/articles/2307

#include <Anhnt/UI/Controls/Element.mqh>
#include <Anhnt/UI/Controls/Window.mqh>
#include <Anhnt/UI/Controls/SeparateLine.mqh>

class CAppStatusBar : public CElement
  {
    private:
        //--- Pointer to the form to which the element is attached
        CWindow          *m_wnd;
        //--- Properties:
        //    Arrays for unique properties
        int               m_width[];
        //--- (1) Color of the background and (2) background frame
        color             m_area_color;
        color             m_area_border_color;
        //--- Text color
        color             m_label_color;
        //--- Priority of the left mouse button click
        int               m_zorder;
        //--- Colors for separation lines
        color             m_sepline_dark_color;
        color             m_sepline_light_color;
        //--- Object for creating a button
        CRectLabel        m_area;
        CEdit             m_items[];
        CSeparateLine     m_sep_line[];        
    public:
                          CAppStatusBar(void);
                          ~CAppStatusBar(void);
        //--- Attach window pointer
        void              WindowPointer(CWindow &object);
        //--- Methods for creating the status bar
        bool              CreateStatusBar(const long chart_id,const int subwin,const int x,const int y);
        //--- Setting the value by the specified index
        void              ValueToItem(const int index,const string value);        
    private:
        bool              CreateArea(void);
        bool              CreateItems(void);
        bool              CreateSeparateLine(const int line_number,const int x,const int y);        
    public:
        //--- Number of items
        int ItemsTotal(void) const { return(::ArraySize(m_width)); }        
        //--- Adds the item with specified properties before creating the status bar
        void              AddItem(const int width); 
  };
//+------------------------------------------------------------------+
//| Constructor                                                      |
//+------------------------------------------------------------------+
CAppStatusBar::CAppStatusBar(void) : m_area_color(C'240,240,240'),
                               m_area_border_color(clrSilver),
                               m_label_color(clrBlack),
                               m_sepline_dark_color(C'160,160,160'),
                               m_sepline_light_color(clrWhite)
  {
//--- Store the name of the element class in the base class  
   CElement::ClassName("CAppStatusBar");
//--- Set priorities of the left mouse button click
   m_zorder=2;
  }
//+------------------------------------------------------------------+
//| Destructor                                                       |
//+------------------------------------------------------------------+
CAppStatusBar::~CAppStatusBar(void)
  {
  }

bool CAppStatusBar::CreateItems(void)
  {
    int l_w=0;
    int l_x=m_x+1;
    int l_y=m_y+1;
    //--- Get the number of items
    int items_total=ItemsTotal();
    //--- If there are no items in the group, report and leave
   if(items_total<1)
     {
      ::Print(__FUNCTION__," > This method is to be called, "
              "if a group contains at least one item! Use the CAppStatusBar::AddItem() method");
      return(false);
     }
    //--- If the width of the first item is not set, then...
   if(m_width[0]<1)
     {
      //--- ...calculate it in relation to the common width of other items
      for(int i=1; i<items_total; i++)
         l_w+=m_width[i];
      //---
      m_width[0]=m_wnd.XSize()-l_w-(items_total+2);
     }
    //--- Resize arrays before use
    ArrayResize(m_items,items_total);
    ArrayResize(m_sep_line,items_total);
    //--- Create specified number of items
   for(int i=0; i<items_total; i++)
     {
      //--- Forming the object name
      string name=CElement::ProgramName()+"_statusbar_edit_"+string(i)+"__"+(string)CElement::Id();
      //--- X coordinate
      l_x=(i>0)? l_x+m_width[i-1] : l_x;
      //--- Creating an object
      if(!m_items[i].Create(m_chart_id,name,m_subwin,l_x,l_y,m_width[i],m_y_size-2))
         return(false);
      //--- Setting properties
      m_items[i].Description("");
      m_items[i].TextAlign(ALIGN_LEFT);
      m_items[i].Font(FONT);
      m_items[i].FontSize(FONT_SIZE);
      m_items[i].Color(m_label_color);
      m_items[i].BorderColor(m_area_color);
      m_items[i].BackColor(m_area_color);
      m_items[i].Corner(m_corner);
      m_items[i].Anchor(m_anchor);
      m_items[i].Selectable(false);
      m_items[i].Z_Order(m_zorder);
      m_items[i].ReadOnly(true);
      m_items[i].Tooltip("\n");
      //--- Margins from the edge of the panel
      m_items[i].XGap(l_x-m_wnd.X());
      m_items[i].YGap(l_y-m_wnd.Y());
      //--- Coordinates
      m_items[i].X(l_x);
      m_items[i].Y(l_y);
      //--- Size
      m_items[i].XSize(m_width[i]);
      m_items[i].YSize(m_y_size-2);
      //--- Store the object pointer
      CElement::AddToArray(m_items[i]);
     }
    //--- Creating separation lines
   for(int i=1; i<items_total; i++)
     {
      //--- X coordinate
      l_x=m_items[i].X();
      //--- Creating a line
      CreateSeparateLine(i,l_x,l_y+2);
     }    
   return(true);
  }

  void CAppStatusBar::ValueToItem(const int index,const string value)
  {
    //--- Checking for exceeding the array range
   int array_size=::ArraySize(m_items);
   if(array_size<1 || index<0 || index>=array_size)
      return;
    //--- Setting the passed text
   m_items[index].Description(value);
  } 
  bool CAppStatusBar::CreateStatusBar(const long chart_id,const int subwin,const int x,const int y)
  {
    //--- Check window pointer
   if(m_wnd==NULL)
    {
        Print(__FUNCTION__,": Window pointer not set. Call WindowPointer() first.");
        return(false);
    }
    m_chart_id = chart_id;
    m_subwin   = subwin;
    m_x        = x;
    m_y        = y;
    m_y_size   = 20;

    if(!CreateArea())
        return(false);

    if(!CreateItems())
        return(false);

    return(true);
  }
bool CAppStatusBar::CreateArea(void)
  {
    string name=CElement::ProgramName()+"_statusbar_area__"+(string)CElement::Id();

    if(!m_area.Create(m_chart_id,name,m_subwin,m_x,m_y,m_wnd.XSize(),m_y_size))
        return(false);

    m_area.Color(m_area_border_color);
    m_area.BackColor(m_area_color);
    m_area.Z_Order(m_zorder);

    CElement::AddToArray(m_area);

    return(true);
  }
  void CAppStatusBar::WindowPointer(CWindow &object)
  {
    m_wnd = ::GetPointer(object);
  }

//+------------------------------------------------------------------+

bool CAppStatusBar::CreateSeparateLine(const int line_number,const int x,const int y)
  {
    string name=ProgramName()+"_statusbar_line_"+string(line_number)+"__"+(string)Id();
    if(!m_sep_line[line_number].CreateSeparateLine(
        m_chart_id,
        m_subwin,
        line_number,
        x,
        y,
        1,
        m_y_size-4))
      return(false);
   
    m_sep_line[line_number].DarkColor(m_sepline_dark_color);
    m_sep_line[line_number].LightColor(m_sepline_light_color);   

    return(true);
  }

  void CAppStatusBar::AddItem(const int width)
  {
    int size = ArraySize(m_width);
    ArrayResize(m_width, size + 1);
    m_width[size] = width;
  }
#endif __CAPPSTATUSBAR_MQH__