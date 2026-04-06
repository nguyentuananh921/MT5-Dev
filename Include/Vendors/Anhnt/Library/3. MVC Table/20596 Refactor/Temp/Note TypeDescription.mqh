//+------------------------------------------------------------------+ 
// | Functions |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
// |  Returns the element type as a string |
//+------------------------------------------------------------------+
enum ENUM_ELEMENT_TYPE                    // Enumeration of types of graphic elements
   {
      ELEMENT_TYPE_BASE = 0x10000,           // Basic object of graphic elements
      ELEMENT_TYPE_COLOR,                    // Color object
      ELEMENT_TYPE_COLORS_ELEMENT,           // Graphics Element Colors Object
      ELEMENT_TYPE_RECTANGLE_AREA,           // Rectangular element area
      ELEMENT_TYPE_IMAGE_PAINTER,            // Object for drawing images
      ELEMENT_TYPE_COUNTER,                  // Counter object
      ELEMENT_TYPE_AUTOREPEAT_CONTROL,       // Auto-repeat event object
      ELEMENT_TYPE_BOUNDED_BASE,             // Basic object of dimensions of graphic elements
      ELEMENT_TYPE_CANVAS_BASE,              // Basic graphic element canvas object
      ELEMENT_TYPE_ELEMENT_BASE,             // Basic object of graphic elements
      ELEMENT_TYPE_HINT,                     // Clue
      ELEMENT_TYPE_LABEL,                    // Text label
      ELEMENT_TYPE_BUTTON,                   // Simple button
      ELEMENT_TYPE_BUTTON_TRIGGERED,         // Two-position button
      ELEMENT_TYPE_BUTTON_ARROW_UP,          // Up arrow button
      ELEMENT_TYPE_BUTTON_ARROW_DOWN,        // Down arrow button
      ELEMENT_TYPE_BUTTON_ARROW_LEFT,        // Left Arrow Button
      ELEMENT_TYPE_BUTTON_ARROW_RIGHT,       // Right arrow button
      ELEMENT_TYPE_CHECKBOX,                 // CheckBox control
      ELEMENT_TYPE_RADIOBUTTON,              // RadioButton control
      ELEMENT_TYPE_SCROLLBAR_THUMB_H,        // Horizontal scroll bar slider
      ELEMENT_TYPE_SCROLLBAR_THUMB_V,        // Vertical scroll bar slider
      ELEMENT_TYPE_SCROLLBAR_H,              // ScrollBarHorizontal control
      ELEMENT_TYPE_SCROLLBAR_V,              // ScrollBarVertical control
      ELEMENT_TYPE_TABLE_CELL_VIEW,          // Table cell (View)
      ELEMENT_TYPE_TABLE_ROW_VIEW,           // Table row (View)
      ELEMENT_TYPE_TABLE_CAPTION_VIEW,       // Basic header object (View)
      ELEMENT_TYPE_TABLE_COLUMN_CAPTION_VIEW,// Table Column Header (View)
      ELEMENT_TYPE_TABLE_ROW_CAPTION_VIEW,   // Table Row Header (View)
      ELEMENT_TYPE_TABLE_HEADER_VIEW,        // Table title (View)
      ELEMENT_TYPE_TABLE_ROWS_HEADER_VIEW,   // Table row header (View)
      ELEMENT_TYPE_TABLE_VIEW,               // Table (View)
      ELEMENT_TYPE_TABLE_CONTROL_VIEW,       // Table Control (View)
      ELEMENT_TYPE_PANEL,                    // Panel control
      ELEMENT_TYPE_GROUPBOX,                 // GroupBox control
      ELEMENT_TYPE_CONTAINER,                // Container control
   };
string ElementDescription(const ENUM_ELEMENT_TYPE type)
  {
   string array[];
   int total=StringSplit(EnumToString(type),StringGetCharacter("_",0),array);
   if(array[array.Size()-1]=="V")
      array[array.Size()-1]="Vertical";
   if(array[array.Size()-1]=="H")
      array[array.Size()-1]="Horisontal";
      
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
enum ENUM_OBJECT_TYPE               // Enumerating Object Types
    {
        OBJECT_TYPE_TABLE_CELL=10000,    // Table cell
        OBJECT_TYPE_TABLE_ROW,           // Table row
        OBJECT_TYPE_TABLE_MODEL,         // Table model
        OBJECT_TYPE_COLUMN_CAPTION,      // Table Column Header
        OBJECT_TYPE_TABLE_HEADER,        // Table title
        OBJECT_TYPE_TABLE,               // Table
        OBJECT_TYPE_TABLE_BY_PARAM,      // Table based on parameter array data
    };  
string CBaseObj::Description(void)
    {
        string nm=this.Name();
        string name=(nm!="" ? ::StringFormat(" \"%s\"",nm) : nm);
        return ::StringFormat("%s%s ID %d",ElementDescription((ENUM_ELEMENT_TYPE)this.Type()),name,this.ID());
    }