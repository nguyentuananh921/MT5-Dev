//+------------------------------------------------------------------+
//|                                                      ListElm.mqh |
//+------------------------------------------------------------------+
//|                   Tables in the MVC Paradigm in MQL5             |
//|                Customizable and sortable table columns           |
//|                           https://www.mql5.com/en/articles/19979 |
//+------------------------------------------------------------------+
//| Linked list class for graphical elements                         |
//+------------------------------------------------------------------+

#ifndef __LISTELM_MQH__
#define __LISTELM_MQH__

class CElementBase
//+------------------------------------------------------------------+
//|Include stadard library                                           |
//+------------------------------------------------------------------+
#include <Arrays\List.mqh>
#include <Object.mqh>
//+------------------------------------------------------------------+
//|Include Custom library                                           |
//+------------------------------------------------------------------+




//+------------------------------------------------------------------+
//| Include element classes                                          |
//+------------------------------------------------------------------+
   // Base
#include "../Base/BaseObj.mqh"
#include "../Base/Bound.mqh"
#include "../Base/BoundedObj.mqh"
#include "../Base/CanvasBase.mqh"
#include "../Base/Color.mqh"
#include "../Base/ColorElement.mqh"

// Controls
#include "ElementBase.mqh"
#include "Label.mqh"
#include "Button.mqh"
#include "ButtonTriggered.mqh"
#include "ButtonArrowUp.mqh"
#include "ButtonArrowDown.mqh"
#include "ButtonArrowLeft.mqh"
#include "ButtonArrowRight.mqh"
#include "CheckBox.mqh"
#include "RadioButton.mqh"
#include "ImagePainter.mqh"
#include "VisualHint.mqh"

// Table / Views
#include "ColumnCaptionView.mqh"
#include "TableCellView.mqh"
#include "TableRowView.mqh"
#include "TableHeaderView.mqh"
#include "TableView.mqh"


class CListElm : public CList
  {
protected:
   ENUM_ELEMENT_TYPE m_element_type;   // Type of object created in CreateElement()

public:
//--- Set element type
   void SetElementType(const ENUM_ELEMENT_TYPE type){ this.m_element_type=type; }

//--- Virtual methods (1) load list from file, (2) create list element
   virtual bool      Load(const int file_handle);
   virtual CObject  *CreateElement(void);
  };

//+------------------------------------------------------------------+
//| Load list from file                                              |
//+------------------------------------------------------------------+
bool CListElm::Load(const int file_handle)
  {
//--- Variables
   CObject *node;
   bool result=true;

//--- Check handle
   if(file_handle==INVALID_HANDLE)
      return(false);

//--- Load and verify start marker of the list - 0xFFFFFFFFFFFFFFFF
   if(::FileReadLong(file_handle)!=MARKER_START_DATA)
      return(false);

//--- Load and verify list type
   if(::FileReadInteger(file_handle,INT_VALUE)!=this.Type())
      return(false);

//--- Read list size (number of objects)
   uint num=::FileReadInteger(file_handle,INT_VALUE);

//--- Sequentially recreate list elements using node.Load()
   this.Clear();

   for(uint i=0;i<num;i++)
     {
      //--- Read and verify start marker of object data
      if(::FileReadLong(file_handle)!=MARKER_START_DATA)
         return false;

      //--- Read object type
      this.m_element_type=(ENUM_ELEMENT_TYPE)::FileReadInteger(file_handle,INT_VALUE);

      node=this.CreateElement();
      if(node==NULL)
         return false;

      this.Add(node);

      //--- File pointer currently shifted by 12 bytes (8 marker + 4 type)
      //--- Move pointer back and load object data using node.Load()
      if(!::FileSeek(file_handle,-12,SEEK_CUR))
         return false;

      result &=node.Load(file_handle);
     }

//--- Result
   return result;
  }

//+------------------------------------------------------------------+
//| Method for creating list element                                 |
//+------------------------------------------------------------------+
CObject *CListElm::CreateElement(void)
  {
//--- Create object based on m_element_type
   switch(this.m_element_type)
     {
      case ELEMENT_TYPE_BASE                      : return new CBaseObj();           
      case ELEMENT_TYPE_COLOR                     : return new CColor();             
      case ELEMENT_TYPE_COLORS_ELEMENT            : return new CColorElement();      
      case ELEMENT_TYPE_RECTANGLE_AREA            : return new CBound();             
      case ELEMENT_TYPE_IMAGE_PAINTER             : return new CImagePainter();      
      case ELEMENT_TYPE_CANVAS_BASE               : return new CCanvasBase();        
      case ELEMENT_TYPE_ELEMENT_BASE              : return new CElementBase();       
      case ELEMENT_TYPE_HINT                      : return new CVisualHint();        
      case ELEMENT_TYPE_LABEL                     : return new CLabel();             
      case ELEMENT_TYPE_BUTTON                    : return new CButton();            
      case ELEMENT_TYPE_BUTTON_TRIGGERED          : return new CButtonTriggered();   
      case ELEMENT_TYPE_BUTTON_ARROW_UP           : return new CButtonArrowUp();     
      case ELEMENT_TYPE_BUTTON_ARROW_DOWN         : return new CButtonArrowDown();   
      case ELEMENT_TYPE_BUTTON_ARROW_LEFT         : return new CButtonArrowLeft();   
      case ELEMENT_TYPE_BUTTON_ARROW_RIGHT        : return new CButtonArrowRight();  
      case ELEMENT_TYPE_CHECKBOX                  : return new CCheckBox();          
      case ELEMENT_TYPE_RADIOBUTTON               : return new CRadioButton();       
      case ELEMENT_TYPE_TABLE_CELL_VIEW           : return new CTableCellView();     
      case ELEMENT_TYPE_TABLE_ROW_VIEW            : return new CTableRowView();      
      case ELEMENT_TYPE_TABLE_COLUMN_CAPTION_VIEW : return new CColumnCaptionView(); 
      case ELEMENT_TYPE_TABLE_HEADER_VIEW         : return new CTableHeaderView();   
      case ELEMENT_TYPE_TABLE_VIEW                : return new CTableView();         
      case ELEMENT_TYPE_PANEL                     : return new CPanel();             
      case ELEMENT_TYPE_GROUPBOX                  : return new CGroupBox();          
      case ELEMENT_TYPE_CONTAINER                 : return new CContainer();         
      default                                     : return NULL;
     }
  }

#endif