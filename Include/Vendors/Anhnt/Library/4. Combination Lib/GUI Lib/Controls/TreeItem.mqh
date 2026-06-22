//+------------------------------------------------------------------+
//|                                                     TreeItem.mqh |
//|                        Copyright 2015, MetaQuotes Software Corp. |
//| Topic link https://www.mql5.com/en/articles/2539                 |
//| Lib Link https://www.mql5.com/en/code/19703                      |
//+------------------------------------------------------------------+
#ifndef __TREEITEM_MQH__
#define __TREEITEM_MQH__
#include "..\Element.mqh"
#include "Button.mqh"
//+------------------------------------------------------------------+
// | Class for creating a tree list item |
//+------------------------------------------------------------------+
class CTreeItem : public CButton
  {
   private:
     int               m_arrow_x_gap;     // ---Indentation for the arrow (indicating the presence of a list)
     ENUM_TYPE_TREE_ITEM m_item_type;     // ---Item type base on ENUM_TYPE_TREE_ITEM in enum.mqh
     int               m_list_index;      // --- Index of the item in the general list
     int               m_node_level;      // ---Node level
     string            m_item_text;       // --- Item text displayed
     bool              m_item_state;      // --- State of the item list (opened/collapsed)
     bool              m_is_active;       //Add Properties to highlight node
   public:
                     CTreeItem(void);
                    ~CTreeItem(void);
    // --- Methods for creating a tree list item
     bool              CreateTreeItem(const int x_gap,const int y_gap,const ENUM_TYPE_TREE_ITEM type,
                                      const int list_index,const int node_level,const string text,const bool item_state);
    //---
   private:
     void              InitializeProperties(const int x_gap,const int y_gap,const ENUM_TYPE_TREE_ITEM type,
                                          const int list_index,const int node_level,const string text,const bool item_state);
    // --- Draws a picture
     virtual void      DrawImage(void);                  
   public:
    // --- (1) Item status (collapsed/expanded), (2) item type, (3) item active
     void              ItemState(const int state);
     bool              ItemState(void) const { return(m_item_state); }     
     void IsActive(const bool active) { m_is_active = active; }

     //ENUM_TYPE_TREE_ITEM Type(void)    const { return(m_item_type);  }
     ENUM_TYPE_TREE_ITEM  ItemType(void)    const { return(m_item_type);  }
     void                 ItemType(const ENUM_TYPE_TREE_ITEM type) { m_item_type = type; }

     int NodeLevel(void) const { return m_node_level; }
    // --- Indent for arrow
     int               ArrowXGap(const int node_level);
     int               ArrowXGap(void) const { return(m_arrow_x_gap); }
    // --- Update coordinates and width
     void              UpdateX(const int x);
     void              UpdateY(const int y);
     void              UpdateWidth(const int width);
    // ---Graph event handler
     virtual void      OnEvent(const int id,const long &lparam,const double &dparam,const string &sparam);
    // --- Draws an element
     virtual void      Draw(void); 
   };
 #ifndef CTREEITEM_MQH_IMPLEMENTATION
 #define CTREEITEM_MQH_IMPLEMENTATION
   //+------------------------------------------------------------------+
   //| Constructor                                                      |
   //+------------------------------------------------------------------+
   CTreeItem::CTreeItem(void) : m_node_level(0),
                                m_arrow_x_gap(5),
                                m_item_type(TI_SIMPLE)
     {
      // --- Save the element class name in the base class
       CElementBase::ClassName(CLASS_NAME);
      // --- Item will be a drop-down item
       CElementBase::IsDropdown(true);
     }
   //+------------------------------------------------------------------+
   //| Destructor                                                       |
   //+------------------------------------------------------------------+
   CTreeItem::~CTreeItem(void)
     {
     }
   //+------------------------------------------------------------------+
   // | Event Handler |
   //+------------------------------------------------------------------+
   void CTreeItem::OnEvent(const int id,const long &lparam,const double &dparam,const string &sparam)
     {
      // --- Exit if the main element is not available
       if(!m_main.CElementBase::IsAvailable())
          return;
      // --- Handle the event in the base class
       CButton::OnEvent(id,lparam,dparam,sparam);
     }
   //+------------------------------------------------------------------+
   // | Creates a tree list item |
   //+------------------------------------------------------------------+
   bool CTreeItem::CreateTreeItem(const int x_gap,const int y_gap,const ENUM_TYPE_TREE_ITEM type,
                                  const int list_index,const int node_level,const string text,const bool item_state)
     {
      // --- Quit if there is no pointer to the main element
       if(!CElement::CheckMainPointer())
          return(false);
      // --- Initializing properties
       InitializeProperties(x_gap,y_gap,type,list_index,node_level,text,item_state);       
      // --- Set images if the item has a drop-down list      
      if(m_item_type==TI_HAS_ITEMS)
        {  
           CElement::AddImagesGroup(m_arrow_x_gap,2);
           CElement::AddImage(1, IMAGE_RESOURCE_BMP16_ARROWDOWN_BMP);   // (uint)4
           CElement::AddImage(1, IMAGE_RESOURCE_BMP16_ARROWRIGHT_BMP);  // (uint)10
          //Fix here to set Active Icon
           CElement::AddImage(1, IMAGE_RESOURCE_BMP16_ARROWDOWN_BLUE_BMP);   // 2
           CElement::AddImage(1, IMAGE_RESOURCE_BMP16_ARROWRIGHT_BLUE_BMP);  // 3
         // --- Select the appropriate image
         CButton::ChangeImage(1,(m_item_state)? 1 : 0);
        }
      // --- Properties
       CButton::TwoState(true);
      // --- Let's create a control
       if(!CButton::CreateButton(text,x_gap,y_gap))
          return(false);
      //---
      return(true);
     }
   //+------------------------------------------------------------------+
   // | Initializing properties |
   //+------------------------------------------------------------------+
   void CTreeItem::InitializeProperties(const int x_gap,const int y_gap,const ENUM_TYPE_TREE_ITEM type,
                                        const int list_index,const int node_level,const string text,const bool item_state)
     {
       m_x           =CElement::CalculateX(x_gap);
       m_y           =CElement::CalculateY(y_gap);
       m_item_type   =type;             //ENUM_TYPE_TREE_ITEM TI_SIMPLE    = 0,
                                        //                    TI_HAS_ITEMS = 1,
       m_list_index  =list_index;
       m_node_level  =node_level;
       m_item_text   =text;
       m_item_state  =item_state;
       m_label_text  =text;
      // ---Default properties
       m_back_color           =m_main.BackColor();
       m_back_color_hover     =C'229,243,255';
       m_back_color_pressed   =C'204,232,255';
       m_border_color         =m_main.BackColor();
       m_border_color_hover   =m_back_color_hover;
       m_border_color_pressed =C'153,209,255';
       m_label_color          =clrBlack;
       m_label_color_hover    =clrBlack;
       m_label_color_pressed  =clrBlack;
       //Fix here old code
          //m_label_x_gap          =(m_label_x_gap!=WRONG_VALUE)? m_icon_x_gap+m_label_x_gap : m_icon_x_gap+22;
        //New version
         m_label_x_gap = (type == TI_HAS_ITEMS) ? (m_arrow_x_gap + 22) : (m_icon_x_gap + 22);
       m_label_y_gap          =4;
      // --- Indents from the extreme point
       CElementBase::XGap(x_gap);
       CElementBase::YGap(y_gap);
     }
   //+------------------------------------------------------------------+
   // | Setting the item's state (collapsed/expanded) |
   //+------------------------------------------------------------------+
   void CTreeItem::ItemState(const int state)
     {
      m_item_state=state;   // --- State of the item list (opened/collapsed)
     }
   //+------------------------------------------------------------------+
   // | Arrow Indent |
   //+------------------------------------------------------------------+
   int CTreeItem::ArrowXGap(const int node_level)
     {
      //return((m_arrow_x_gap=(node_level>0)? (12*node_level)+5 : 5));
      //Fix here:  Old code has space for arrow at level 0. Now it has no space for arrow at level 0 
        return((m_arrow_x_gap=(node_level>0)? (12*node_level)+5 : 0));
     }
   //+------------------------------------------------------------------+
   // | X Coordinate Update |
   //+------------------------------------------------------------------+
   void CTreeItem::UpdateX(const int x)
     {
      // ---Updating global coordinates and offset from extreme point
         CElementBase::X(CElement::CalculateX(x));
         CElementBase::XGap(x);
      // --- Coordinates and offset
         m_canvas.X(x);
         m_canvas.XGap(x);
     }
   //+------------------------------------------------------------------+
   // | Y Coordinate Update |
   //+------------------------------------------------------------------+
   void CTreeItem::UpdateY(const int y)
     {
      // ---Updating global coordinates and offset from extreme point
         CElementBase::Y(CElement::CalculateY(y));
         CElementBase::YGap(y);
      // --- Coordinates and offset
         m_canvas.Y(y);
         m_canvas.YGap(y);
     }
   //+------------------------------------------------------------------+
   // | Update width |
   //+------------------------------------------------------------------+
   void CTreeItem::UpdateWidth(const int width)
     {
      // ---Background width
         CElementBase::XSize(width);
         m_canvas.XSize(width);
         m_canvas.Resize(width,m_y_size);
     }
   //+------------------------------------------------------------------+
   // | Draws an element |
   //+------------------------------------------------------------------+
   void CTreeItem::Draw(void)
     {
      // --- Draw background
         CButton::DrawBackground();
      // --- Draw a picture
         if(m_item_type==TI_HAS_ITEMS)
          {                     
            m_images_group[0].m_selected_image = WRONG_VALUE;
            CTreeItem::DrawImage();
          }            
         else
            CButton::DrawImage();
      // --- Draw text
         CElement::DrawText();
     }
   //+------------------------------------------------------------------+
   // | Draws a picture |
   //+------------------------------------------------------------------+
   void CTreeItem::DrawImage(void)
     {
      // --- Define the index 
         //uint image_index=(m_item_state)? 0 : 1;
      //Fix here Update to set Active Icon
        uint image_index = (m_item_state ? 0 : 1) + (m_is_active ? 2 : 0);
      // --- Save index of selected image
         CElement::ChangeImage(1,image_index);
      // --- Draw a picture
         CElement::DrawImage();
     }  
   //+------------------------------------------------------------------+
 #endif // CTREEITEM_MQH_IMPLEMENTATION
#endif // __TREEITEM_MQH__
