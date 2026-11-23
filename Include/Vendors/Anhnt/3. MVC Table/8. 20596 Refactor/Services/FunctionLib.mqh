//+------------------------------------------------------------------+
//|                                                FunctionLib.mqh   |
//|                                  Copyright 2025, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//| MVC Paradigm in MQL5                                             |
//|                                                                  |
//|                           https://www.mql5.com/ru/articles/20596 |
//+------------------------------------------------------------------+
#property copyright "Copyright 2025, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
//+------------------------------------------------------------------+ 
//| Functions                                                        |
//+------------------------------------------------------------------+

#ifndef __FUNCTIONLIB_MQH__
#define __FUNCTIONLIB_MQH__
  //+------------------------------------------------------------------+
  //| Included Standard Libraries                                      |
  //+------------------------------------------------------------------+
  #include <Arrays\List.mqh>
  //+------------------------------------------------------------------+
  //| Included Custome Libraries                                       |
  //+------------------------------------------------------------------+
  #include "..\Defines\TableDefines.mqh"
  #include "..\Defines\TableEnums.mqh"
  #include "..\Defines\BaseDefines.mqh"
  #include "..\Defines\BaseEnums.mqh"
  //+------------------------------------------------------------------+
  // |  Returns the object type as a string |
  //+------------------------------------------------------------------+
#ifndef __MOVE_TO_CBASEOBJ__
#define __MOVE_TO_CBASEOBJ__
  //  string TypeDescription(const ENUM_OBJECT_TYPE type)
  //   {
  //    string array[];
  //    int total=StringSplit(EnumToString(type),StringGetCharacter("_",0),array);
  //    string result="";
  //    for(int i=2;i<total;i++)
  //    {
  //       array[i]+=" ";
  //       array[i].Lower();
  //       array[i].SetChar(0,ushort(array[i].GetChar(0)-0x20));
  //       result+=array[i];
  //    }
  //    result.TrimLeft();
  //    result.TrimRight();
  //    return result;
  //   }
  //+------------------------------------------------------------------+
  //|  Returns the element type as a string |
  //+------------------------------------------------------------------+
  // string ElementDescription(const ENUM_ELEMENT_TYPE type)
  //   {
  //    string array[];
  //    int total=StringSplit(EnumToString(type),StringGetCharacter("_",0),array);
  //    if(array[array.Size()-1]=="V")
  //       array[array.Size()-1]="Vertical";
  //    if(array[array.Size()-1]=="H")
  //       array[array.Size()-1]="Horisontal";
        
  //    string result="";
  //    for(int i=2;i<total;i++)
  //      {
  //       array[i]+=" ";
  //       array[i].Lower();
  //       array[i].SetChar(0,ushort(array[i].GetChar(0)-0x20));
  //       result+=array[i];
  //      }
  //    result.TrimLeft();
  //    result.TrimRight();
  //    return result;
  //   }

  //+------------------------------------------------------------------+
  //|  Returns the short name of an element by type                    |
  //+------------------------------------------------------------------+
  // string ElementShortName(const ENUM_ELEMENT_TYPE type)
  //   {
  //    switch(type)
  //      {
  //       case ELEMENT_TYPE_ELEMENT_BASE               :  return "BASE";    // Basic object of graphic elements
  //       case ELEMENT_TYPE_HINT                       :  return "HNT";     // Clue
  //       case ELEMENT_TYPE_LABEL                      :  return "LBL";     // Text label
  //       case ELEMENT_TYPE_BUTTON                     :  return "SBTN";    // Simple button
  //       case ELEMENT_TYPE_BUTTON_TRIGGERED           :  return "TBTN";    // Two-position button
  //       case ELEMENT_TYPE_BUTTON_ARROW_UP            :  return "BTARU";   // Up arrow button
  //       case ELEMENT_TYPE_BUTTON_ARROW_DOWN          :  return "BTARD";   // Down arrow button
  //       case ELEMENT_TYPE_BUTTON_ARROW_LEFT          :  return "BTARL";   // Left Arrow Button
  //       case ELEMENT_TYPE_BUTTON_ARROW_RIGHT         :  return "BTARR";   // Right arrow button
  //       case ELEMENT_TYPE_CHECKBOX                   :  return "CHKB";    // CheckBox control
  //       case ELEMENT_TYPE_RADIOBUTTON                :  return "RBTN";    // RadioButton control
  //       case ELEMENT_TYPE_SCROLLBAR_THUMB_H          :  return "THMBH";   // Horizontal scroll bar slider
  //       case ELEMENT_TYPE_SCROLLBAR_THUMB_V          :  return "THMBV";   // Vertical scroll bar slider
  //       case ELEMENT_TYPE_SCROLLBAR_H                :  return "SCBH";    // ScrollBarHorizontal control
  //       case ELEMENT_TYPE_SCROLLBAR_V                :  return "SCBV";    // ScrollBarVertical control
  //       case ELEMENT_TYPE_TABLE_CELL_VIEW            :  return "TCELL";   // Table cell (View)
  //       case ELEMENT_TYPE_TABLE_ROW_VIEW             :  return "TROW";    // Table row (View)
  //       case ELEMENT_TYPE_TABLE_CAPTION_VIEW         :  return "TCAPT";   // Basic header object (View)
  //       case ELEMENT_TYPE_TABLE_COLUMN_CAPTION_VIEW  :  return "TCCAPT";  // Table Column Header (View)
  //       case ELEMENT_TYPE_TABLE_ROW_CAPTION_VIEW     :  return "TRCAPT";  // Table Row Header (View)
  //       case ELEMENT_TYPE_TABLE_HEADER_VIEW          :  return "TCHDR";   // Table title (View)
  //       case ELEMENT_TYPE_TABLE_ROWS_HEADER_VIEW     :  return "TRHDR";   // Table row header (View)
  //       case ELEMENT_TYPE_TABLE_VIEW                 :  return "TABLE";   // Table (View)
  //       case ELEMENT_TYPE_TABLE_CONTROL_VIEW         :  return "TBLCTRL"; // Table Control (View)
  //       case ELEMENT_TYPE_PANEL                      :  return "PNL";     // Panel control
  //       case ELEMENT_TYPE_GROUPBOX                   :  return "GRBX";    // GroupBox control
  //       case ELEMENT_TYPE_CONTAINER                  :  return "CNTR";    // Container control
  //       default                                      :  return "Unknown"; // Unknown
  //      }
  //   }

  // //+------------------------------------------------------------------+
  // //| Returns an array of element hierarchy names                      |
  // //+------------------------------------------------------------------+
  // int GetElementNames(string value, string sep, string &array[])
  //   {
  //   if(value=="" || value==NULL)
  //     {
  //       PrintFormat("%s: Error. Empty string passed");
  //       return 0;
  //     }
  //   ResetLastError();
  //   int res=StringSplit(value, StringGetCharacter(sep,0),array);
  //   if(res==WRONG_VALUE)
  //     {
  //       PrintFormat("%s: StringSplit() failed. Error %d",__FUNCTION__, GetLastError());
  //       return WRONG_VALUE;
  //     }
  //   return res;
  //   }
#endif // MOVE_TO_CBASEOBJ__



#endif // __FUNCTIONLIB_MQH__


