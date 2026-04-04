//+------------------------------------------------------------------+
//|                                                EnumsTables.mqh   |
//|                                  Copyright 2025, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//| MVC Paradigm in MQL5                                             |
//|                                                                  |
//|                           https://www.mql5.com/ru/articles/20596 |
//+------------------------------------------------------------------+
#property copyright "Copyright 2025, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
//+------------------------------------------------------------------+
// | Included Libraries |
//+------------------------------------------------------------------+
#include <Arrays\List.mqh>

#include "..\Collections\ListObj.mqh"
#include "..\Tables\CColumnCaption.mqh"
#include "..\Tables\MqlParamObj.mqh"
#include "..\Tables\Table.mqh"
#include "..\Tables\TableByParam.mqh"
#include "..\Tables\TableCell.mqh"
#include "..\Tables\TableHeader.mqh"
#include "..\Tables\TableModel.mqh"
#include "..\Tables\TableRow.mqh"

#ifndef __DELIB_MQH__
#define __DELIB_MQH__
   //+------------------------------------------------------------------+ 
   // | Functions |
   //+------------------------------------------------------------------+
   //+------------------------------------------------------------------+
   // |  Returns the object type as a string |
   //+------------------------------------------------------------------+
   string TypeDescription(const ENUM_OBJECT_TYPE type)
   {
      string array[];
      int total=StringSplit(EnumToString(type),StringGetCharacter("_",0),array);
      string result="";
      for(int i=2;i<total;i++)
      {
         array[i]+=" ";
         array[i].Lower();
         array[i].SetChar(0,ushort(array[i].GetChar(0)-0x20));
         result+=array[i];
      }
      result.TrimLeft();
      result.TrimRight();
      return result;
   }
      //+------------------------------------------------------------------+
   // | List item creation method |
   //+------------------------------------------------------------------+
   CObject *CListObj::CreateElement(void)
   {
    // --- Depending on the object type in m_element_type, create a new object
      switch(this.m_element_type)
      {
         case OBJECT_TYPE_TABLE_CELL      :  return new CTableCell();
         case OBJECT_TYPE_TABLE_ROW       :  return new CTableRow();
         case OBJECT_TYPE_TABLE_MODEL     :  return new CTableModel();
         case OBJECT_TYPE_COLUMN_CAPTION  :  return new CColumnCaption();
         case OBJECT_TYPE_TABLE_HEADER    :  return new CTableHeader();
         case OBJECT_TYPE_TABLE           :  return new CTable();
         case OBJECT_TYPE_TABLE_BY_PARAM  :  return new CTableByParam();
         default                          :  return NULL;
      }
   }
   //+------------------------------------------------------------------+
   // | List item creation method |
   //+------------------------------------------------------------------+
   CObject *CListElm::CreateElement(void)
      {
      // --- Depending on the object type in m_element_type, create a new object
      switch(this.m_element_type)
      {
         case ELEMENT_TYPE_BASE                       :  return new CBaseObj();           // Basic object of graphic elements
         case ELEMENT_TYPE_COLOR                      :  return new CColor();             // Color object
         case ELEMENT_TYPE_COLORS_ELEMENT             :  return new CColorElement();      // Graphics Element Colors Object
         case ELEMENT_TYPE_RECTANGLE_AREA             :  return new CBound();             // Rectangular element area
         case ELEMENT_TYPE_IMAGE_PAINTER              :  return new CImagePainter();      // Object for drawing images
         case ELEMENT_TYPE_CANVAS_BASE                :  return new CCanvasBase();        // Basic graphic element canvas object
         case ELEMENT_TYPE_ELEMENT_BASE               :  return new CElementBase();       // Basic object of graphic elements
         case ELEMENT_TYPE_HINT                       :  return new CVisualHint();        // Clue
         case ELEMENT_TYPE_LABEL                      :  return new CLabel();             // Text label
         case ELEMENT_TYPE_BUTTON                     :  return new CButton();            // Simple button
         case ELEMENT_TYPE_BUTTON_TRIGGERED           :  return new CButtonTriggered();   // Two-position button
         case ELEMENT_TYPE_BUTTON_ARROW_UP            :  return new CButtonArrowUp();     // Up arrow button
         case ELEMENT_TYPE_BUTTON_ARROW_DOWN          :  return new CButtonArrowDown();   // Down arrow button
         case ELEMENT_TYPE_BUTTON_ARROW_LEFT          :  return new CButtonArrowLeft();   // Left Arrow Button
         case ELEMENT_TYPE_BUTTON_ARROW_RIGHT         :  return new CButtonArrowRight();  // Right arrow button
         case ELEMENT_TYPE_CHECKBOX                   :  return new CCheckBox();          // CheckBox control
         case ELEMENT_TYPE_RADIOBUTTON                :  return new CRadioButton();       // RadioButton control
         case ELEMENT_TYPE_TABLE_CELL_VIEW            :  return new CTableCellView();     // Table cell (View)
         case ELEMENT_TYPE_TABLE_ROW_VIEW             :  return new CTableRowView();      // Table row (View)
         case ELEMENT_TYPE_TABLE_CAPTION_VIEW         :  return new CCaptionView();       // Basic header object (View)
         case ELEMENT_TYPE_TABLE_COLUMN_CAPTION_VIEW  :  return new CColumnCaptionView(); // Table Column Header (View)
         case ELEMENT_TYPE_TABLE_ROW_CAPTION_VIEW     :  return new CRowCaptionView();    // Table Row Header (View)
         case ELEMENT_TYPE_TABLE_HEADER_VIEW          :  return new CTableHeaderView();   // Table title (View)
         case ELEMENT_TYPE_TABLE_ROWS_HEADER_VIEW     :  return new CTableRowsHeaderView();// Vertical table header (View)
         case ELEMENT_TYPE_TABLE_VIEW                 :  return new CTableView();         // Table (View)
         case ELEMENT_TYPE_PANEL                      :  return new CPanel();             // Panel control
         case ELEMENT_TYPE_GROUPBOX                   :  return new CGroupBox();          // GroupBox control
         case ELEMENT_TYPE_CONTAINER                  :  return new CContainer();         // GroupBox control
         default                                      :  return NULL;
      }
      }
#endif // __DELIB_MQH__
